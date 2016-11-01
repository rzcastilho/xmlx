defmodule Xmlx.Parser do

  @moduledoc """
  Parser functions
  """

  import Xmlx.Common

  @s_char "[" <> <<0x9 :: utf8>> <> "|" <> <<0xA :: utf8>> <> "|" <> <<0xD :: utf8>> <> "|" <> <<0x20 :: utf8>> <> "-" <> <<0xD7FF :: utf8>> <> "|" <> <<0xE000 :: utf8>> <> "-" <> <<0xFFFD :: utf8>> <> "|" <> <<0x10000 :: utf8>> <> "-" <> <<0x10FFFF :: utf8>> <> "]"
  @s_tag_open_content_close "(?<open><[^\\!\\?>]+>)(?<value><\\!\\[CDATA\\[" <> @s_char <> "*\\]\\]>|[^<>]+)(?<close><\/[^>]+>)"
  @s_tag_close "<\/[^>]+>"
  @s_tag_open "<[^\\!\\?>]+>"
  @s_tags @s_tag_open_content_close <> "|" <> @s_tag_close <> "|" <> @s_tag_open

  @re_tags Regex.compile!(@s_tags, [:unicode])
  @re_tag_open_content_close Regex.compile!(@s_tag_open_content_close, [:unicode])
  @re_attributes ~r/[[:blank:]]+(?<name>[^=]+)="(?<value_double>[^"]+)"|'(?<value_single>[^']+)'/
  @re_namespace ~r/[[:blank:]]+xmlns(:[a-zA-Z0-9]+)?=("[^"]+"|'[^']+')/

  @doc """
  Parse XML in a structured list with key values
  """
  @spec parse(String) :: List
  def parse(xml) do
    xml
      |> minify
      |> (&(Regex.scan(@re_tags, &1))).()
      |> Enum.map(
        fn(token) ->
          cond do
            String.match?(Enum.at(token, 0), ~r/^<\//) ->
              {:close, Enum.at(token, 0) }
            String.match?(Enum.at(token, 0), ~r/\/>$/) ->
              {:open_close, Enum.at(token, 0) }
            String.match?(Enum.at(token, 0), ~r/^<([^\/][^<>]+|[^<>]+)>$/) ->
              {:open, Enum.at(token, 0) }
            true ->
              Regex.scan(@re_tag_open_content_close, Enum.at(token, 0), [capture: [:open, :value, :close]])
                |> Enum.map(&([{:open, Enum.at(&1, 0)}, {:value, Enum.at(&1, 1)}, {:close, Enum.at(&1, 2)}]))
          end
        end
      )
      |> List.flatten
      |> build
  end

  defp build([{_action, value}|t]) do
    [ns_alias, name] = ~r/<((?<alias>[a-zA-Z0-9_\-\.]+)(?<separator>:))?(?<name>[^\n[:blank:]>]+)/
      |> Regex.scan(value, [capture: [:alias, :name]])
      |> List.flatten
    nss = [] ++ [get_namespaces(value)]
    attrs = get_attributes(value, nss)
    namespace = resolve_namespace_from_alias(nss, String.to_atom(ns_alias))
    name = if namespace != nil, do: "{" <> namespace <> "}" <> name, else: name
    build(t, [String.to_atom(name)], nss, build_node_structure(name, attrs))
  end

  defp build([{:open, value}|t], path, ns_stack, result) do
    [ns_alias, name] = ~r/<((?<alias>[a-zA-Z0-9_\-\.]+)(?<separator>:))?(?<name>[^\n[:blank:]>]+)/
      |> Regex.scan(value, [capture: [:alias, :name]])
      |> List.flatten
    nss = [get_namespaces(value)] ++ ns_stack
    attrs = get_attributes(value, nss)
    namespace = resolve_namespace_from_alias(nss, String.to_atom(ns_alias))
    name = if namespace != nil, do: "{" <> namespace <> "}" <> name, else: name
    build(t, path ++ [String.to_atom(name)], nss, put(result, path, name, attrs, namespace, :open))
  end

  defp build([{:close, value}|t], path, ns_stack, result) do
    [ns_alias, name] = ~r/<\/((?<alias>[a-zA-Z0-9_\-\.]+)(?<separator>:))?(?<name>[^\n[:blank:]>]+)>/
      |> Regex.scan(value, [capture: [:alias, :name]])
      |> List.flatten
    namespace = resolve_namespace_from_alias(ns_stack, String.to_atom(ns_alias))
    name = if namespace != nil, do: "{" <> namespace <> "}" <> name, else: name
    nss = Enum.drop(ns_stack, 1)
    build(t, path -- [String.to_atom(name)], nss, result)
  end

  defp build([{:open_close, value}|t], path, ns_stack, result) do
    [ns_alias, name] = ~r/<((?<alias>[a-zA-Z0-9_\-\.]+)(?<separator>:))?(?<name>[^\/\n[:blank:]]+)/
      |> Regex.scan(value, [capture: [:alias, :name]])
      |> List.flatten
    nss = [get_namespaces(value)] ++ ns_stack
    attrs = get_attributes(value, nss)
    namespace = resolve_namespace_from_alias(nss, String.to_atom(ns_alias))
    name = if namespace != nil, do: "{" <> namespace <> "}" <> name, else: name
    build(t, path, ns_stack, put(result, path, name, attrs, namespace, :open_close))
  end

  defp build([{action, value}|t], path, ns_stack, result) do
    build(t, path, ns_stack, put(result, path, value, [], "", action))
  end

  defp build([], _path, _ns_stack, result) do
    result
  end

  defp put(result, [], name, attrs, namespace, action, current_key, stack) do
    node = result ++ if action == :value, do: [{:text, name}], else: build_node_structure(name, attrs)
    if Enum.count(stack) == 1 do
      [{current_key, node}]
    else
      List.keyreplace(stack, current_key, 0, {current_key, node})
        |> Enum.reduce(fn (element, acc_element) ->
          key_acc = elem(acc_element, 0)
          value_acc = elem(acc_element, 1)
          key = elem(element, 0)
          value = Enum.reverse(Keyword.delete_first(Enum.reverse(elem(element, 1)), key_acc))
          { key, value ++ [{key_acc, value_acc}] }
        end)
        |> (fn(v) -> [v] end).()
    end
  end

  defp put(result, path, name, attrs, namespace, action \\ "", _current_key \\ "", stack \\ []) do
    node = [{List.first(path), Keyword.get(result, List.first(path))}]
    put(List.last(Keyword.get_values(result, List.first(path))), path -- [List.first(path)], name, attrs, namespace, action, List.first(path), node ++ stack)
  end

  defp build_node_structure(node_name, []) do
    [{String.to_atom(node_name), []}]
  end

  defp build_node_structure(node_name, attrs) do
    #[{String.to_atom(node_name), [{:__attrs__, attrs}]}]
    [{String.to_atom(node_name), attrs}]
  end

  defp resolve_namespace_from_alias([], _ns_alias) do
    nil
  end

  defp resolve_namespace_from_alias([h|t], ns_alias) do
    namespace = Keyword.get(h, ns_alias)
    if namespace != nil, do: namespace, else: resolve_namespace_from_alias(t, ns_alias)
  end

  defp get_attributes(fragment, namespaces) do
    @re_attributes
      |> Regex.scan(String.replace(fragment, @re_namespace, ""), [capture: [:name, :value_double, :value_single]])
      |> Enum.map(&(List.delete(&1, "") |> (fn(v) -> {String.to_atom(resolve_alias_attribute(Enum.at(v, 0), namespaces, :attr_name)), resolve_alias_attribute(Enum.at(v, 1), namespaces)} end).()))
  end

  defp resolve_alias_attribute(attr, namespaces) do
    attr
  end

  defp resolve_alias_attribute(attr, namespaces, :attr_name) do
    if String.contains?(attr, ":") do
      namespace = resolve_namespace_from_alias(namespaces, String.to_atom(attr |> String.split(":") |> Enum.at(0)))
      "{" <> namespace <> "}" <> "@" <> (attr |> String.split(":") |> Enum.at(1))
    else
      "@" <> attr
    end
  end

end
