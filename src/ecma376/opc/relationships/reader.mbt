///|
/// Read a `.rels` §5 Inputs XML byte stream into CT_Relationships.
pub fn read_relationships(bytes : Bytes) -> Relationships raise {
  let doc = @xml.parse(bytes)
  if !is_element(doc.root, "Relationships", relationships_ns()) {
    raise @opc_errors.SchemaViolation(
      section="",
      path="/",
      reason="expected Relationships in the relationships namespace",
    )
  }
  let relationships : Array[Relationship] = []
  for child in element_children(doc.root, "/Relationships") {
    if !is_element(child, "Relationship", relationships_ns()) {
      raise @opc_errors.SchemaViolation(
        section="",
        path="/Relationships/" + child.name.local_name,
        reason="Relationships may contain only Relationship elements",
      )
    }
    relationships.push(read_relationship(child))
  }
  Relationships::new(relationships)
}

///|
fn read_relationship(element : @xml.Element) -> Relationship raise {
  ensure_no_element_children(element, "/Relationships/Relationship")
  Relationship::new(
    required_attribute(element, "Id", "/Relationships/Relationship/@Id"),
    required_attribute(element, "Type", "/Relationships/Relationship/@Type"),
    required_attribute(element, "Target", "/Relationships/Relationship/@Target"),
    optional_target_mode(element),
  )
}

///|
fn optional_target_mode(element : @xml.Element) -> TargetMode raise {
  for attr in element.attributes {
    if attr.name.local_name == "TargetMode" && attr.name.ns == None {
      return TargetMode::parse(attr.value)
    }
  }
  Internal
}

///|
fn required_attribute(
  element : @xml.Element,
  name : String,
  path : String,
) -> String raise @opc_errors.SchemaViolation {
  for attr in element.attributes {
    if attr.name.local_name == name && attr.name.ns == None {
      if attr.value == "" {
        raise @opc_errors.SchemaViolation(
          section="",
          path~,
          reason="required attribute must not be empty",
        )
      }
      return attr.value
    }
  }
  raise @opc_errors.SchemaViolation(
    section="",
    path~,
    reason="required attribute is missing",
  )
}

///|
fn ensure_no_element_children(
  element : @xml.Element,
  path : String,
) -> Unit raise @opc_errors.SchemaViolation {
  for child in element.children {
    if child is @xml.Node::Element(nested) {
      raise @opc_errors.SchemaViolation(
        section="",
        path=path + "/" + nested.name.local_name,
        reason="Relationship must not contain child elements",
      )
    }
  }
}

///|
fn element_children(
  element : @xml.Element,
  path : String,
) -> Array[@xml.Element] raise @opc_errors.SchemaViolation {
  let children : Array[@xml.Element] = []
  for child in element.children {
    match child {
      Element(element) => children.push(element)
      Text(text) | CData(text) =>
        if text.trim() != "" {
          raise @opc_errors.SchemaViolation(
            section="",
            path~,
            reason="element-only content contains non-whitespace text",
          )
        }
      _ => ()
    }
  }
  children
}

///|
fn is_element(element : @xml.Element, local_name : String, ns : String) -> Bool {
  element.name.local_name == local_name && element.name.ns == Some(ns)
}

///|
fn relationships_ns() -> String {
  @opc_namespaces.ns_relationships()
}
