# Xmlx

[![Build status](https://travis-ci.org/rodrigozc/xmlx.svg?branch=master)](https://travis-ci.org/rodrigozc/xmlx)
[![xmlx version](https://img.shields.io/hexpm/v/xmlx.svg)](https://hex.pm/packages/xmlx)
[![Hex.pm](https://img.shields.io/hexpm/dt/xmlx.svg)](https://hex.pm/packages/xmlx)

Elixir native XML parser that enables search using attribute or element names

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

### XML Example (simple.xml)
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
[note: [to: [text: "Tove"], from: [text: "Jani"], heading: [text: "Reminder"],
  body: [text: "Don't forget me this weekend!"]]]
    ```

  2. Find element/attribute
    ```elixir
    File.read!("simple.xml") |> Xmlx.parse() |> Xmlx.find(:from)
    ```
    or
    ```elixir
    File.read!("simple.xml") |> Xmlx.parse() |> Xmlx.find("from")
    ```
    ```
[from: [text: "Jani"]]
    ```

### WSDL Example (simple.wsdl)
  ```xml
<?xml version="1.0"?>
<definitions name="EndorsementSearch"
  targetNamespace="http://namespaces.snowboard-info.com"
  xmlns:es="http://www.snowboard-info.com/EndorsementSearch.wsdl"
  xmlns:esxsd="http://schemas.snowboard-info.com/EndorsementSearch.xsd"
  xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
  xmlns="http://schemas.xmlsoap.org/wsdl/"
>

  <!-- omitted types section with content model schema info -->

  <message name="GetEndorsingBoarderRequest">
    <part name="body" element="esxsd:GetEndorsingBoarder"/>
  </message>

  <message name="GetEndorsingBoarderResponse">
    <part name="body" element="esxsd:GetEndorsingBoarderResponse"/>
  </message>

  <portType name="GetEndorsingBoarderPortType">
    <operation name="GetEndorsingBoarder">
      <input message="es:GetEndorsingBoarderRequest"/>
      <output message="es:GetEndorsingBoarderResponse"/>
      <fault message="es:GetEndorsingBoarderFault"/>
    </operation>
  </portType>

  <binding name="EndorsementSearchSoapBinding"
           type="es:GetEndorsingBoarderPortType">
    <soap:binding style="document"
                  transport="http://schemas.xmlsoap.org/soap/http"/>
    <operation name="GetEndorsingBoarder">
      <soap:operation
        soapAction="http://www.snowboard-info.com/EndorsementSearch"/>
      <input>
        <soap:body use="literal"
          namespace="http://schemas.snowboard-info.com/EndorsementSearch.xsd"/>
      </input>
      <output>
        <soap:body use="literal"
          namespace="http://schemas.snowboard-info.com/EndorsementSearch.xsd"/>
      </output>
      <fault>
        <soap:body use="literal"
          namespace="http://schemas.snowboard-info.com/EndorsementSearch.xsd"/>
      </fault>
    </operation>
  </binding>

  <service name="EndorsementSearchService">
    <documentation>snowboarding-info.com Endorsement Service</documentation>
    <port name="GetEndorsingBoarderPort"
          binding="es:EndorsementSearchSoapBinding">
      <soap:address location="http://www.snowboard-info.com/EndorsementSearch"/>
    </port>
  </service>

</definitions>
  ```

  1. Document parse
    ```elixir
    File.read!("simple.wsdl") |> Xmlx.parse()
    ```
    ```
["{http://schemas.xmlsoap.org/wsdl/}definitions": ["@name": "EndorsementSearch",
  "@targetNamespace": "http://namespaces.snowboard-info.com",
  "{http://schemas.xmlsoap.org/wsdl/}message": ["@name": "GetEndorsingBoarderRequest",
   "{http://schemas.xmlsoap.org/wsdl/}part": ["@name": "body",
    "@element": "esxsd:GetEndorsingBoarder"]],
  "{http://schemas.xmlsoap.org/wsdl/}message": ["@name": "GetEndorsingBoarderResponse",
   "{http://schemas.xmlsoap.org/wsdl/}part": ["@name": "body",
    "@element": "esxsd:GetEndorsingBoarderResponse"]],
  "{http://schemas.xmlsoap.org/wsdl/}portType": ["@name": "GetEndorsingBoarderPortType",
   "{http://schemas.xmlsoap.org/wsdl/}operation": ["@name": "GetEndorsingBoarder",
    "{http://schemas.xmlsoap.org/wsdl/}input": ["@message": "es:GetEndorsingBoarderRequest"],
    "{http://schemas.xmlsoap.org/wsdl/}output": ["@message": "es:GetEndorsingBoarderResponse"],
    "{http://schemas.xmlsoap.org/wsdl/}fault": ["@message": "es:GetEndorsingBoarderFault"]]],
  "{http://schemas.xmlsoap.org/wsdl/}binding": ["@name": "EndorsementSearchSoapBinding",
   "@type": "es:GetEndorsingBoarderPortType",
   "{http://schemas.xmlsoap.org/wsdl/soap/}binding": ["@style": "document",
    "@transport": "http://schemas.xmlsoap.org/soap/http"],
   "{http://schemas.xmlsoap.org/wsdl/}operation": ["@name": "GetEndorsingBoarder",
    "{http://schemas.xmlsoap.org/wsdl/soap/}operation": ["@soapAction": "http://www.snowboard-info.com/EndorsementSearch"],
    "{http://schemas.xmlsoap.org/wsdl/}input": ["{http://schemas.xmlsoap.org/wsdl/soap/}body": ["@use": "literal",
      "@namespace": "http://schemas.snowboard-info.com/EndorsementSearch.xsd"]],
    "{http://schemas.xmlsoap.org/wsdl/}output": ["{http://schemas.xmlsoap.org/wsdl/soap/}body": ["@use": "literal",
      "@namespace": "http://schemas.snowboard-info.com/EndorsementSearch.xsd"]],
    "{http://schemas.xmlsoap.org/wsdl/}fault": ["{http://schemas.xmlsoap.org/wsdl/soap/}body": ["@use": "literal",
      "@namespace": "http://schemas.snowboard-info.com/EndorsementSearch.xsd"]]]],
  "{http://schemas.xmlsoap.org/wsdl/}service": ["@name": "EndorsementSearchService",
   "{http://schemas.xmlsoap.org/wsdl/}documentation": [text: "snowboarding-info.com Endorsement Service"],
   "{http://schemas.xmlsoap.org/wsdl/}port": ["@name": "GetEndorsingBoarderPort",
    "@binding": "es:EndorsementSearchSoapBinding",
    "{http://schemas.xmlsoap.org/wsdl/soap/}address": ["@location": "http://www.snowboard-info.com/EndorsementSearch"]]]]]
    ```

  2. Find by element name
    ```elixir
    File.read!("simple.wsdl") |> Xmlx.parse() |> Xmlx.find(:"{http://schemas.xmlsoap.org/wsdl/}port")
    ```
    or
    ```elixir
    File.read!("simple.wsdl") |> Xmlx.parse() |> Xmlx.find("{http://schemas.xmlsoap.org/wsdl/}port")
    ```
    or
    ```elixir
    File.read!("simple.wsdl") |> Xmlx.parse() |> Xmlx.find("port")
    ```
    ```
["{http://schemas.xmlsoap.org/wsdl/}port": ["@name": "GetEndorsingBoarderPort",
  "@binding": "es:EndorsementSearchSoapBinding",
  "{http://schemas.xmlsoap.org/wsdl/soap/}address": ["@location": "http://www.snowboard-info.com/EndorsementSearch"]]]
    ```

  3. Find by attribute name
    ```elixir
    File.read!("simple.wsdl") |> Xmlx.parse() |> Xmlx.find(:"@location")
    ```
    or
    ```elixir
    File.read!("simple.wsdl") |> Xmlx.parse() |> Xmlx.find("@location")
    ```
    ```
["@location": "http://www.snowboard-info.com/EndorsementSearch"]
    ```
