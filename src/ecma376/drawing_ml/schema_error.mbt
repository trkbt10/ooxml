///|
/// Schema validation error for ECMA-376 DrawingML Main (§20.1).
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
      schema="dml-main.xsd",
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
fn read_main_root(bytes : Bytes, local_name : String) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  require_local(root, local_name, local_name)
  validate_main_element(root)
  root
}

///|
fn validate_main_element(element : @xml.Element) -> Unit raise SchemaViolation {
  validate_main_attributes(element)
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      validate_main_element(child_element)
    }
  }
}

///|
fn validate_main_attributes(
  element : @xml.Element,
) -> Unit raise SchemaViolation {
  for attribute in element.attributes {
    let name = attribute.name.local_name
    let value = attribute.value
    match name {
      "x"
      | "y"
      | "cx"
      | "cy"
      | "chOff"
      | "chExt"
      | "w"
      | "h"
      | "l"
      | "t"
      | "r"
      | "b"
      | "rad"
      | "dist"
      | "blurRad"
      | "sx"
      | "sy"
      | "kx"
      | "ky"
      | "amt"
      | "pos"
      | "algn"
      | "rot"
      | "lat"
      | "lon"
      | "rev"
      | "ang"
      | "idx"
      | "fmla"
      | "prst"
      | "path"
      | "fill"
      | "name" => validate_non_empty_attr(name, value)
      _ => ()
    }
  }
}

///|
fn validate_non_empty_attr(
  path : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="empty attribute value",
    )
  }
}
