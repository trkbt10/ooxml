///|
/// Read the §5 Inputs XML byte stream for `[Content_Types].xml`, accepting the
/// §4 Types top-level element with Default and Override children. This is the
/// §1 Scope entry point for content-type discovery and the §3 TOC coverage
/// point for OPC §10 digital-signature package parts: the function identifies
/// content types for §10.4.2 Digital Signature Origin part, §10.4.3 Digital
/// Signature XML Signature part, and §10.4.4 Digital Signature Certificate
/// part without parsing those payloads inline.
pub fn read_content_types(bytes : Bytes) -> Types raise {
  let doc = @xml.parse(bytes)
  if !is_element(doc.root, "Types", content_types_ns()) {
    raise @opc_errors.SchemaViolation(
      section="10.1",
      path="/",
      reason="expected Types in the content-types namespace",
    )
  }
  let rules : Array[ContentTypeRule] = []
  for child in element_children(doc.root, "/Types") {
    if is_element(child, "Default", content_types_ns()) {
      rules.push(Default(read_default(child)))
    } else if is_element(child, "Override", content_types_ns()) {
      rules.push(Override(read_override(child)))
    } else {
      raise @opc_errors.SchemaViolation(
        section="10.1",
        path="/Types/" + child.name.local_name,
        reason="Types may contain only Default or Override elements",
      )
    }
  }
  Types::new(rules)
}

///|
fn read_default(
  element : @xml.Element,
) -> Default raise @opc_errors.SchemaViolation {
  ensure_no_element_children(element, "/Types/Default")
  Default::new(
    Extension::parse(
      required_attribute(element, "Extension", "/Types/Default/@Extension"),
    ),
    ContentType::parse(
      required_attribute(element, "ContentType", "/Types/Default/@ContentType"),
    ),
  )
}

///|
fn read_override(
  element : @xml.Element,
) -> Override raise @opc_errors.SchemaViolation {
  ensure_no_element_children(element, "/Types/Override")
  Override::new(
    PartName::parse(
      required_attribute(element, "PartName", "/Types/Override/@PartName"),
    ),
    ContentType::parse(
      required_attribute(element, "ContentType", "/Types/Override/@ContentType"),
    ),
  )
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
          section="10.1",
          path~,
          reason="required attribute must not be empty",
        )
      }
      return attr.value
    }
  }
  raise @opc_errors.SchemaViolation(
    section="10.1",
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
        section="10.1",
        path=path + "/" + nested.name.local_name,
        reason="content-types declarations must not contain child elements",
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
            section="10.1",
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
fn content_types_ns() -> String {
  "http://schemas.openxmlformats.org/package/2006/content-types"
}
