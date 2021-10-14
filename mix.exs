defmodule Xmlx.Mixfile do
  use Mix.Project

  @description "Elixir native XML parser that enables search using attribute or element names"
  @version "0.2.0"

  def project() do
    [
      app: :xmlx,
      name: "Xmlx",
      version: @version,
      description: @description,
      elixir: "~> 1.9",
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/rodrigozc/xmlx"
    ]
  end

  def application() do
    []
  end

  defp deps() do
    [
      {:excoveralls, "~> 0.14", only: :test},
      {:ex_doc, "~> 0.25", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      maintainers: ["Rodrigo Zampieri Castilho"],
      licenses: ["WTFPL"],
      files: ~w(lib mix.exs README.md LICENSE),
      links: %{
        "GitHub" => "https://github.com/rodrigozc/xmlx",
        "Docs"   => "http://hexdocs.pm/xmlx"
      }
    ]
  end

end
