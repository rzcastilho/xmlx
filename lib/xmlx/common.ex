defmodule Xmlx.Common do

  @moduledoc """
  Reusable funtions through Xmlx library.
  """

  @doc """
  Minify XML putting all elements inline whithout spaces and break lines.
  """
  @spec minify(String) :: String
  def minify(xml) do
    xml
      |> String.strip
      |> String.replace(~r/>[[:blank:]\n]+</, "><")
  end

  @doc """
  Return a list with all namespace declarations from passed string.
  """
  @spec get_namespaces(String) :: List
  def get_namespaces(xml) do
    ~r/[[:blank:]]+xmlns(:(?<alias>[a-zA-Z0-9]+))?=("(?<namespace_double>[^"]+)"|'(?<namespace_single>[^']+)')/
      |> Regex.scan(xml, [capture: [:alias, :namespace_double, :namespace_single]])
      |> Enum.map(&({String.to_atom(Enum.at(&1, 0)), (if Enum.at(&1, 1) != "", do: Enum.at(&1, 1), else: Enum.at(&1, 2))}))
      |> Enum.uniq
  end

end
