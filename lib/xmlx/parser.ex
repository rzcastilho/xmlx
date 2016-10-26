defmodule Xmlx.Parser do

  @moduledoc """
  Xmlx.Parser Module
  """

  import Xmlx.Common

  @doc """
  Parse XML in a structured list with key values
  """
  @spec parse(String) :: List
  def parse(xml) do
    xml
      |> minify
      |> (&(Regex.scan(~r/<[^!\?][^>]+>[^<>]+<\/[^>]+>|<\/[^>]+>|<[^!\?][^>]+>/, &1))).()
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
              Regex.scan(~r/(?<open><[^>]+>)(?<value>[^<>]+)(?<close><\/[^>]+>)/, Enum.at(token, 0), [capture: [:open, :value, :close]])
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
    attrs = ~r/[[:blank:]]+(?<name>[^=]+)="(?<value_double>[^"]+)"|'(?<value_single>[^']+)'/
      |> Regex.scan(String.replace(value, ~r/ xmlns(:[a-zA-Z0-9]+)?=("[^"]+"|'[^']+')/, ""), [capture: [:name, :value_double, :value_single]])
      |> Enum.map(&(List.delete(&1, "") |> (fn(v) -> {String.to_atom(Enum.at(v, 0)), Enum.at(v, 1)} end).()))
    nss = [] ++ [get_namespaces(value)]
    namespace = resolve_namespace_from_alias(nss, String.to_atom(ns_alias))
    build(t, [String.to_atom(name)], nss, build_node_structure(name, namespace, attrs))
  end

  defp build([{:open, value}|t], path, ns_stack, result) do
    [ns_alias, name] = ~r/<((?<alias>[a-zA-Z0-9_\-\.]+)(?<separator>:))?(?<name>[^\n[:blank:]>]+)/
      |> Regex.scan(value, [capture: [:alias, :name]])
      |> List.flatten
    attrs = ~r/[[:blank:]]+(?<name>[^=]+)="(?<value_double>[^"]+)"|'(?<value_single>[^']+)'/
      |> Regex.scan(String.replace(value, ~r/ xmlns(:[a-zA-Z0-9]+)?=("[^"]+"|'[^']+')/, ""), [capture: [:name, :value_double, :value_single]])
      |> Enum.map(&(List.delete(&1, "") |> (fn(v) -> {String.to_atom(Enum.at(v, 0)), Enum.at(v, 1)} end).()))
    nss = [get_namespaces(value)] ++ ns_stack
    namespace = resolve_namespace_from_alias(nss, String.to_atom(ns_alias))
    build(t, path ++ [String.to_atom(name)], nss, put(result, path, name, attrs, namespace, :open))
  end

  defp build([{:close, value}|t], path, ns_stack, result) do
    [_ns_alias, name] = ~r/<\/((?<alias>[a-zA-Z0-9_\-\.]+)(?<separator>:))?(?<name>[^\n[:blank:]>]+)>/
      |> Regex.scan(value, [capture: [:alias, :name]])
      |> List.flatten
    nss = Enum.drop(ns_stack, 1)
    build(t, path -- [String.to_atom(name)], nss, result)
  end

  defp build([{:open_close, value}|t], path, ns_stack, result) do
    [ns_alias, name] = ~r/<((?<alias>[a-zA-Z0-9_\-\.]+)(?<separator>:))?(?<name>[^\/\n[:blank:]]+)/
      |> Regex.scan(value, [capture: [:alias, :name]])
      |> List.flatten
    attrs = ~r/[[:blank:]]+(?<name>[^=]+)="(?<value_double>[^"]+)"|'(?<value_single>[^']+)'/
      |> Regex.scan(String.replace(value, ~r/ xmlns(:[a-zA-Z0-9]+)?=("[^"]+"|'[^']+')/, ""), [capture: [:name, :value_double, :value_single]])
      |> Enum.map(&(List.delete(&1, "") |> (fn(v) -> {String.to_atom(Enum.at(v, 0)), Enum.at(v, 1)} end).()))
    nss = [get_namespaces(value)] ++ ns_stack
    namespace = resolve_namespace_from_alias(nss, String.to_atom(ns_alias))
    build(t, path, ns_stack, put(result, path, name, attrs, namespace, :open_close))
  end

  defp build([{action, value}|t], path, ns_stack, result) do
    build(t, path, ns_stack, put(result, path, String.to_atom(value), [], "", action))
  end

  defp build([], _path, _ns_stack, result) do
    result
  end

  defp put(result, [], name, attrs, namespace, action, current_key, stack) do
    node = result ++ if action == :value, do: [{:text, Atom.to_string(name)}], else: build_node_structure(name, namespace, attrs)
    if Enum.count(stack) == 1 do
      [{current_key, node}]
    else
      Keyword.put(stack, current_key, node)
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

  defp build_node_structure(node_name, nil, []) do
    [{String.to_atom(node_name), []}]
  end

  defp build_node_structure(node_name, namespace, []) do
    [{String.to_atom(node_name), [{:__namespace__, namespace}]}]
  end

  defp build_node_structure(node_name, nil, attrs) do
    [{String.to_atom(node_name), [{:__attrs__, attrs}]}]
  end

  defp build_node_structure(node_name, namespace, attrs) do
    [{String.to_atom(node_name), [{:__namespace__, namespace}, {:__attrs__, attrs}]}]
  end

  defp resolve_namespace_from_alias([], _ns_alias) do
    nil
  end

  defp resolve_namespace_from_alias([h|t], ns_alias) do
    namespace = Keyword.get(h, ns_alias)
    if namespace != nil, do: namespace, else: resolve_namespace_from_alias(t, ns_alias)
  end

end
