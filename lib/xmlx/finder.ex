defmodule Xmlx.Finder do

  @moduledoc """
  Simple search functions
  """

  @s_key "(?<namespace>\{[a-zA-Z0-9\/\\.\\-\\:]+\})?(?<attribute_identifier>@)?(?<name>.+)"
  @re_key Regex.compile!(@s_key)

  @doc """
  Returns a filtered list itens based on attribute or element name.
  """
  def find([{key,value}|t], filter, result) when is_atom(filter) do
    result = if key == filter, do: result ++ [{key,value}], else: result
    result = find(value, filter, result)
    result = find(t, filter, result)
    result
  end

  @doc """
  Converts filter string to atom and returns a filtered list itens based on attribute or element name.
  """
  def find([{key,value}|t], filter, result) when is_bitstring(filter) do
    key_parsed = (@re_key |> Regex.scan(Atom.to_string(key), [capture: [:attribute_identifier, :name]]) |> List.to_string)
    filter_parsed = (@re_key |> Regex.scan(filter, [capture: [:attribute_identifier, :name]]) |> List.to_string)
    result = if key_parsed == filter_parsed, do: result ++ [{key,value}], else: result
    result = find(value, filter, result)
    result = find(t, filter, result)
    result
  end

  @doc """
  Returns a filtered itens list based on attribute or element name.
  """
  def find(_value, _filter, result) do
    result
  end

end
