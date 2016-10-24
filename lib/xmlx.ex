defmodule Xmlx do

  alias Xmlx.Common
  alias Xmlx.Parser
  alias Xmlx.Finder

  @moduledoc """
  XML Utility Functions
  """

  @doc """
  Minify XML adding all elements inline whithout spaces or break lines.
  """
  @spec minify(String) :: String
  def minify(xml) do
    Common.minify(xml)
  end

  @doc """
  Parse XML in a structured list with key values
  """
  @spec parse(String) :: List
  def parse(xml) do
    Parser.parse(xml)
  end

  @doc """
  Return a key/value list with namespace declarations.
  """
  @spec get_namespaces(String) :: List
  def get_namespaces(xml) do
    Common.get_namespaces(xml)
  end

  @doc """
  Return a filtered list itens
  """
  @spec find(List, Atom) :: List
  def find(document, filter) do
    Finder.find(document, filter, []);
  end

end
