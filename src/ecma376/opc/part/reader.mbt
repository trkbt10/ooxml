///|
/// Read coreProperties and CT_CoreProperties XML.
pub fn read_core_properties(bytes : Bytes) -> CoreProperties raise {
  let doc = @xml.parse(bytes)
  if doc.root.name.local_name != "coreProperties" {
    raise PartError::SchemaViolation(
      section="9",
      path="/",
      reason="expected coreProperties",
    )
  }
  CoreProperties::new(doc)
}

///|
/// Read SignatureTime, CT_SignatureTime, ST_Format, and ST_Value XML.
pub fn read_signature_time(bytes : Bytes) -> SignatureTime raise {
  let doc = @xml.parse(bytes)
  if doc.root.name.local_name != "SignatureTime" {
    raise PartError::SchemaViolation(
      section="9",
      path="/",
      reason="expected SignatureTime",
    )
  }
  let mut format = ""
  let mut value = ""
  for child in doc.root.children {
    if child is @xml.Node::Element(element) {
      if element.name.local_name == "Format" {
        format = element_text(element)
      } else if element.name.local_name == "Value" {
        value = element_text(element)
      }
    }
  }
  SignatureTime::new(
    SignatureTimeFormat::new(format),
    SignatureTimeValue::new(value),
  )
}

///|
fn element_text(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Text(text) | CData(text) => out.write_string(text)
      _ => ()
    }
  }
  out.to_string()
}
