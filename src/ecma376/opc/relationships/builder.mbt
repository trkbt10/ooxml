///|
/// Write the §6 Outputs O2 XML byte stream for CT_Relationships.
pub fn write_relationships(value : CT_Relationships) -> Bytes {
  @xml.write({
    declaration: Some(default_xml_declaration()),
    doctype: None,
    root: {
      name: relationships_name("Relationships"),
      attributes: [],
      children: relationships_to_nodes(value.relationships),
    },
  })
}

///|
fn relationships_to_nodes(
  relationships : Array[CT_Relationship],
) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for relationship in relationships {
    nodes.push(Element(relationship_to_element(relationship)))
  }
  nodes
}

///|
fn relationship_to_element(value : CT_Relationship) -> @xml.Element {
  let attributes : Array[@xml.Attribute] = [
    { name: unqualified_name("Id"), value: value.id },
    { name: unqualified_name("Type"), value: value.type_uri },
    { name: unqualified_name("Target"), value: value.target },
  ]
  if value.target_mode == External {
    attributes.push({
      name: unqualified_name("TargetMode"),
      value: value.target_mode.to_string(),
    })
  }
  { name: relationships_name("Relationship"), attributes, children: [] }
}

///|
fn relationships_name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: Some(@opc_namespaces.ns_relationships()) }
}

///|
fn unqualified_name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
fn default_xml_declaration() -> @xml.XmlDeclaration {
  { version: "1.0", encoding: Some("UTF-8"), standalone: None }
}
