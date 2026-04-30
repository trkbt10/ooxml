///|
/// OPC §6 Outputs O1/O2 round-trip writer for OPC §9 Thumbnails; thumbnail
/// image bytes are emitted unchanged.
pub fn write_thumbnail_part(value : ThumbnailPart) -> Bytes {
  value.data
}

///|
/// OPC §6 Outputs O1/O2 round-trip writer for generic OPC §9 package part
/// bytes supplied by the resolver.
pub fn write_part(value : PackagePart) -> Bytes {
  value.data
}

///|
/// OPC §6 Outputs O1/O2 round-trip writer for coreProperties and
/// CT_CoreProperties XML, preserving the parsed document and its attributes.
pub fn write_core_properties(value : CoreProperties) -> Bytes {
  @xml.write(value.document)
}

///|
/// OPC §6 Outputs O1/O2 round-trip writer for the opc-digSig
/// RelationshipReference top-level element and CT_RelationshipReference XML.
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
/// OPC §6 Outputs O1/O2 round-trip writer for the opc-digSig
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
/// OPC §6 Outputs O1/O2 round-trip writer for SignatureTime, CT_SignatureTime,
/// ST_Format, and ST_Value XML.
pub fn write_signature_time(value : SignatureTime) -> Bytes {
  let doc : @xml.Document = {
    declaration: Some(default_xml_declaration()),
    doctype: None,
    root: {
      name: digital_signature_name("SignatureTime"),
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
    name: digital_signature_name(name),
    attributes: [],
    children: [Text(value)],
  }
}

///|
fn digital_signature_name(local_name : String) -> @xml.QName {
  {
    prefix: None,
    local_name,
    ns: Some("http://schemas.openxmlformats.org/package/2006/digital-signature"),
  }
}

///|
fn default_xml_declaration() -> @xml.XmlDeclaration {
  { version: "1.0", encoding: Some("UTF-8"), standalone: None }
}
