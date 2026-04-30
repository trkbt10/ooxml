///|
/// Schema validation error for ECMA-376 VML Drawing schemas (§20.1.16).
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
fn require_local(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != local_name {
    raise SchemaViolation(
      schema="vml-main.xsd",
      path~,
      reason="unexpected element name",
    )
  }
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}

///|
fn read_vml_root(bytes : Bytes, local_name : String) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  require_local(root, local_name, local_name)
  validate_vml_element(root)
  root
}

///|
fn validate_vml_element(element : @xml.Element) -> Unit raise SchemaViolation {
  for attribute in element.attributes {
    if attribute.value.length() == 0 {
      raise SchemaViolation(
        schema="vml-main.xsd",
        path=attribute.name.local_name,
        reason="empty attribute value",
      )
    }
  }
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      validate_vml_element(child_element)
    }
  }
}

///|
fn validate_token(
  type_name : String,
  value : String,
  allowed : Array[String],
) -> Unit raise SchemaViolation {
  if allowed.length() == 0 {
    if value.length() == 0 {
      raise SchemaViolation(
        schema=type_name,
        path="value",
        reason="empty value",
      )
    }
  } else {
    for item in allowed {
      if item == value {
        return
      }
    }
    raise SchemaViolation(
      schema=type_name,
      path="value",
      reason="unknown value",
    )
  }
}
