///|
/// Write coreProperties and CT_CoreProperties XML.
pub fn write_core_properties(value : CoreProperties) -> Bytes {
  @xml.write(value.document)
}

///|
/// Write SignatureTime, CT_SignatureTime, ST_Format, and ST_Value XML.
pub fn write_signature_time(value : SignatureTime) -> Bytes {
  let doc : @xml.Document = {
    declaration: Some({
      version: "1.0",
      encoding: Some("UTF-8"),
      standalone: None,
    }),
    doctype: None,
    root: {
      name: {
        prefix: None,
        local_name: "SignatureTime",
        ns: Some(
          "http://schemas.openxmlformats.org/package/2006/digital-signature",
        ),
      },
      attributes: [],
      children: [
        Element(text_element("Format", value.format.value)),
        Element(text_element("Value", value.value.value)),
      ],
    },
  }
  @xml.write(doc)
}

///|
fn text_element(name : String, value : String) -> @xml.Element {
  {
    name: {
      prefix: None,
      local_name: name,
      ns: Some(
        "http://schemas.openxmlformats.org/package/2006/digital-signature",
      ),
    },
    attributes: [],
    children: [Text(value)],
  }
}
