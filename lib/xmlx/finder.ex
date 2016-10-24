defmodule Xmlx.Finder do

  @moduledoc """

  """
  @doc """

  """
  def find([{key,value}|t], filter, result) do
    result = if key == filter, do: result ++ [{key,value}], else: result
    result = find(value, filter, result)
    result = find(t, filter, result)
    result
  end

  @doc """
  
  """
  def find(_value, _filter, result) do
    result
  end

end
