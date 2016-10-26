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
    ```
[from: [text: "Jani"]]
    ```

### WSDL Example (simple.wsdl)
  ```xml
<?xml version="1.0"?>
<definitions xmlns="http://schemas.xmlsoap.org/wsdl/" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:tns="http://www.examples.com/wsdl/HelloService.wsdl" xmlns:xsd="http://www.w3.org/2001/XMLSchema" name="HelloService" targetNamespace="http://www.examples.com/wsdl/HelloService.wsdl">
  <message name="SayHelloRequest">
    <part name="firstName" type="xsd:string"/>
  </message>
  <message name="SayHelloResponse">
    <part name="greeting" type="xsd:string"/>
  </message>
  <portType name="Hello_PortType">
    <operation name="sayHello">
      <input message="tns:SayHelloRequest"/>
      <output message="tns:SayHelloResponse"/>
    </operation>
  </portType>
  <binding name="Hello_Binding" type="tns:Hello_PortType">
    <soap:binding style="rpc" transport="http://schemas.xmlsoap.org/soap/http"/>
    <operation name="sayHello">
      <soap:operation soapAction="sayHello"/>
      <input>
        <soap:body encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" namespace="urn:examples:helloservice" use="encoded"/>
      </input>
      <output>
        <soap:body encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" namespace="urn:examples:helloservice" use="encoded"/>
      </output>
    </operation>
  </binding>
  <service name="Hello_Service">
    <documentation>WSDL File for HelloService</documentation>
    <port binding="tns:Hello_Binding" name="Hello_Port">
      <soap:address location="http://www.examples.com/SayHello/"/>
    </port>
  </service>
</definitions>
  ```

  1. Document parse
    ```elixir
    File.read!("simple.wsdl") |> Xmlx.parse()
    ```
    ```
[definitions: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
  __attrs__: [name: "HelloService",
   targetNamespace: "http://www.examples.com/wsdl/HelloService.wsdl"],
  message: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
   __attrs__: [name: "SayHelloRequest"],
   part: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
    __attrs__: [name: "firstName", type: "xsd:string"]]],
  message: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
   __attrs__: [name: "SayHelloResponse"],
   part: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
    __attrs__: [name: "greeting", type: "xsd:string"]]],
  portType: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
   __attrs__: [name: "Hello_PortType"],
   operation: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
    __attrs__: [name: "sayHello"],
    input: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
     __attrs__: [message: "tns:SayHelloRequest"]],
    output: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
     __attrs__: [message: "tns:SayHelloResponse"]]]],
  binding: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
   __attrs__: [name: "Hello_Binding", type: "tns:Hello_PortType"],
   binding: [__namespace__: "http://schemas.xmlsoap.org/wsdl/soap/",
    __attrs__: [style: "rpc",
     transport: "http://schemas.xmlsoap.org/soap/http"]],
   operation: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
    __attrs__: [name: "sayHello"],
    operation: [__namespace__: "http://schemas.xmlsoap.org/wsdl/soap/",
     __attrs__: [soapAction: "sayHello"]],
    input: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
     body: [__namespace__: "http://schemas.xmlsoap.org/wsdl/soap/",
      __attrs__: [encodingStyle: "http://schemas.xmlsoap.org/soap/encoding/",
       namespace: "urn:examples:helloservice", use: "encoded"]]],
    output: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
     body: [__namespace__: "http://schemas.xmlsoap.org/wsdl/soap/",
      __attrs__: [encodingStyle: "http://schemas.xmlsoap.org/soap/encoding/",
       namespace: "urn:examples:helloservice", use: "encoded"]]]]],
  service: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
   __attrs__: [name: "Hello_Service"],
   documentation: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
    text: "WSDL File for HelloService"],
   port: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
    __attrs__: [binding: "tns:Hello_Binding", name: "Hello_Port"],
    address: [__namespace__: "http://schemas.xmlsoap.org/wsdl/soap/",
     __attrs__: [location: "http://www.examples.com/SayHello/"]]]]]]
    ```

  2. Find element/attribute
    ```elixir
    File.read!("simple.wsdl") |> Xmlx.parse() |> Xmlx.find(:port)
    ```
    ```
[port: [__namespace__: "http://schemas.xmlsoap.org/wsdl/",
  __attrs__: [binding: "tns:Hello_Binding", name: "Hello_Port"],
  address: [__namespace__: "http://schemas.xmlsoap.org/wsdl/soap/",
   __attrs__: [location: "http://www.examples.com/SayHello/"]]]]
    ```
