defmodule Xmlx.Finder do

  @moduledoc """
  Xmlx.Finder Module
  """

  @doc """
  Return a filtered itens list based on attribute or element name.
  """
  def find([{key,value}|t], filter, result) do
    result = if key == filter, do: result ++ [{key,value}], else: result
    result = find(value, filter, result)
    result = find(t, filter, result)
    result
  end

  @doc """
  Return a filtered itens list based on attribute or element name.
  """
  def find(_value, _filter, result) do
    result
  end

end
