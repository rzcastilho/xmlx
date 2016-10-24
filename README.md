# Xmlx

Xmlx is a XML parser that enables search using attribute or element names.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `xmlx` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:xmlx, "~> 0.0.1"}]
    end
    ```

  2. Ensure `xmlx` is started before your application:

    ```elixir
    def application do
      [applications: [:xmlx]]
    end
    ```

## Usage

  XML Example
  ```xml
<?xml version="1.0" encoding="UTF-8"?>
<note>
  <to>Tove</to>
  <from>Jani</from>
  <heading>Reminder</heading>
  <body>Don't forget me this weekend!</body>
</note>
  ```

  1. Document parse
    ```elixir
    File.read!("simple.xml") |> Xmlx.parse()
    ```
    ```
[note: [__namespace__: nil, __attrs__: [],
  to: [__namespace__: nil, __attrs__: [], text: "Tove"],
  from: [__namespace__: nil, __attrs__: [], text: "Jani"],
  heading: [__namespace__: nil, __attrs__: [], text: "Reminder"],
  body: [__namespace__: nil, __attrs__: [],
   text: "Don't forget me this weekend!"]]]
    ```

  2. Find element/attribute
    ```elixir
    File.read!("simple.xml") |> Xmlx.parse() |> Xmlx.find(:from)
    ```
    ```
[from: [__namespace__: nil, __attrs__: [], text: "Jani"]]
    ```
