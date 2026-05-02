///|
/// Write the §6 Outputs O2 XML byte stream for `[Content_Types].xml` from the
/// O1 Types domain tree. The emitted CT_Types document preserves the stored
/// Default and Override order required by §7 Invariants V2 so later OPC
/// package save/open cycles can rediscover §10 digital-signature content.
pub fn write_content_types(value : Types) -> Bytes {
  @xml.write({
    declaration: Some(default_xml_declaration()),
    doctype: None,
    root: {
      name: content_types_name("Types"),
      attributes: [],
      children: rules_to_nodes(value.rules),
    },
  })
}

///|
fn rules_to_nodes(rules : Array[ContentTypeRule]) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for rule in rules {
    match rule {
      Default(default) => nodes.push(Element(default_to_element(default)))
      Override(override_rule) =>
        nodes.push(Element(override_to_element(override_rule)))
    }
  }
  nodes
}

///|
fn default_to_element(value : Default) -> @xml.Element {
  {
    name: content_types_name("Default"),
    attributes: [
      { name: unqualified_name("Extension"), value: value.extension.value },
      { name: unqualified_name("ContentType"), value: value.content_type.value },
    ],
    children: [],
  }
}

///|
fn override_to_element(value : Override) -> @xml.Element {
  {
    name: content_types_name("Override"),
    attributes: [
      { name: unqualified_name("PartName"), value: value.part_name.value },
      { name: unqualified_name("ContentType"), value: value.content_type.value },
    ],
    children: [],
  }
}

///|
fn content_types_name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: Some(@opc_namespaces.ns_content_types()) }
}

///|
fn unqualified_name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
fn default_xml_declaration() -> @xml.XmlDeclaration {
  { version: "1.0", encoding: Some("UTF-8"), standalone: None }
}
