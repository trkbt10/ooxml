///|
/// 6. Outputs writer for the opc-digSig RelationshipReference top-level
/// element and CT_RelationshipReference XML. It converts the O1 typed domain
/// value into an O2 XML byte stream that re-validates against the XSD schema.
pub fn write_relationship_reference(value : RelationshipReference) -> Bytes {
  @xml.write({
    declaration: Some(default_xml_declaration()),
    doctype: None,
    root: {
      name: digital_signature_name("RelationshipReference"),
      attributes: [
        {
          name: { prefix: None, local_name: "SourceId", ns: None },
          value: value.source_id,
        },
      ],
      children: [],
    },
  })
}

///|
/// 6. Outputs O1/O2 round-trip writer for the opc-digSig
/// RelationshipsGroupReference top-level element and
/// CT_RelationshipsGroupReference XML.
pub fn write_relationships_group_reference(
  value : RelationshipsGroupReference,
) -> Bytes {
  @xml.write({
    declaration: Some(default_xml_declaration()),
    doctype: None,
    root: {
      name: digital_signature_name("RelationshipsGroupReference"),
      attributes: [
        {
          name: { prefix: None, local_name: "SourceType", ns: None },
          value: value.source_type,
        },
      ],
      children: [],
    },
  })
}

///|
/// 6. Outputs writer for SignatureTime, CT_SignatureTime, ST_Format, and
/// ST_Value XML. It emits the O2 XML byte stream in schema order from the O1
/// typed domain value and preserves round-trip identity for parsed
/// element/attribute data.
pub fn write_signature_time(value : SignatureTime) -> Bytes {
  let doc : @xml.Document = {
    declaration: Some(default_xml_declaration()),
    doctype: None,
    root: {
      name: digital_signature_name("SignatureTime"),
      attributes: [],
      children: [
        Element(text_element("Format", value.format.to_string())),
        Element(text_element("Value", value.value.to_string())),
      ],
    },
  }
  @xml.write(doc)
}

///|
fn text_element(name : String, value : String) -> @xml.Element {
  {
    name: digital_signature_name(name),
    attributes: [],
    children: [Text(value)],
  }
}

///|
fn digital_signature_name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: Some(digital_signature_ns()) }
}

///|
fn default_xml_declaration() -> @xml.XmlDeclaration {
  { version: "1.0", encoding: Some("UTF-8"), standalone: None }
}
