defmodule XmlxTest do
  use ExUnit.Case
  doctest Xmlx

  test "Parse a Simple XML" do
    File.read!("test/simple.xml") |> Xmlx.parse
  end

  test "Parse a Simple XML With CDATA" do
    File.read!("test/cdata.xml") |> Xmlx.parse
  end

  test "Parse a Simple WSDL" do
    File.read!("test/simple.wsdl") |> Xmlx.parse
  end

  test "Find by Element" do
    assert File.read!("test/simple.xml") |> Xmlx.parse |> Xmlx.find(:heading) == [heading: [text: "Reminder"]]
  end

  test "Find by Element and Get Text" do
    assert File.read!("test/simple.xml") |> Xmlx.parse |> Xmlx.find(:heading) |> Xmlx.find(:text) == [text: "Reminder"]
  end

  test "Find by Element and Get Text Value" do
    assert File.read!("test/simple.xml") |> Xmlx.parse |> Xmlx.find(:heading) |> Xmlx.find(:text) |> Keyword.get(:text) == "Reminder"
  end

  test "Find by Attribute" do
    assert File.read!("test/simple.wsdl") |> Xmlx.parse |> Xmlx.find(:"@location") == ["@location": "http://www.snowboard-info.com/EndorsementSearch"]
  end

  test "Find by Attribute and Get Value" do
    assert File.read!("test/simple.wsdl") |> Xmlx.parse |> Xmlx.find(:"@location") |> Keyword.get(:"@location") == "http://www.snowboard-info.com/EndorsementSearch"
  end

end
