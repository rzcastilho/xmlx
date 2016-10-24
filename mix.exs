defmodule Xmlx.Mixfile do
  use Mix.Project

  @description "Xmlx is a XML parser that enables search using attribute or element names."
  @version "0.0.1"

  def project do
    [app: :xmlx,
     name: "Xmlx",
     version: @version,
     description: @description,
     elixir: "~> 1.3",
     package: package,
     deps: deps(),
     source_url: "https://github.com/rodrigozc/xmlx"]
  end

  def application do
    [ applications: [:logger] ]
  end

  defp deps do
    []
  end

  defp package do
    %{
      maintainers: ["Rodrigo Zampieri Castilho"],
      licenses: ["MIT"],
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      links: %{
        "GitHub" => "https://github.com/rodrigozc/xmlx",
        "Docs"   => "http://hexdocs.pm/xmlx"
      }
    }
  end

end
