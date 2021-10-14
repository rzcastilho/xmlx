defmodule Xmlx do

  alias Xmlx.{Common, Finder, Parser}
  
  @moduledoc """
  Xmlx simple XML parser library
  """

  @doc """
  Minify XML adding all elements inline whithout spaces or break lines.
  """
  @spec minify(String.t()) :: String.t()
  def minify(xml) do
    Common.minify(xml)
  end

  @doc """
  Parse XML in a structured key/values list.
  """
  @spec parse(String.t()) :: List.t()
  def parse(xml) do
    Parser.parse(xml)
  end

  @doc """
  Return a key/value list with namespace declarations.
  """
  @spec get_namespaces(String.t()) :: List.t()
  def get_namespaces(xml) do
    Common.get_namespaces(xml)
  end

  @doc """
  Simple search to return a filtered list itens based on attribute or element name.
  """
  @spec find(List.t(), Atom.t()) :: List.t()
  def find(document, filter) do
    Finder.find(document, filter, []);
  end

end
