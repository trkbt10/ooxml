///|
/// OPC Part 2 §6.5 Relationships namespace.
pub fn ns_relationships() -> String {
  "http://schemas.openxmlformats.org/package/2006/relationships"
}

///|
/// OPC Part 2 §7.3.7 Content Types stream namespace.
pub fn ns_content_types() -> String {
  "http://schemas.openxmlformats.org/package/2006/content-types"
}

///|
/// OPC Part 2 §10 Digital Signatures markup namespace.
pub fn ns_digital_signature() -> String {
  "http://schemas.openxmlformats.org/package/2006/digital-signature"
}

///|
/// OPC Part 2 §13.2 Core Properties namespace.
pub fn ns_core_properties() -> String {
  "http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
}

///|
/// OPC Part 2 §10.6 Relationships Transform Algorithm identifier.
pub fn ns_relationships_transform() -> String {
  "http://schemas.openxmlformats.org/package/2006/RelationshipTransform"
}

///|
/// W3C XML-Signature Syntax and Processing §4 XML Signature namespace.
pub fn ns_xmldsig() -> String {
  "http://www.w3.org/2000/09/xmldsig#"
}

///|
/// W3C XML Encryption Syntax and Processing §5.7 SHA-256 algorithm identifier.
pub fn ns_xmlenc_sha256() -> String {
  "http://www.w3.org/2001/04/xmlenc#sha256"
}

///|
/// W3C Canonical XML 1.0 canonicalization algorithm identifier.
pub fn ns_c14n() -> String {
  "http://www.w3.org/TR/2001/REC-xml-c14n-20010315"
}

///|
/// W3C XML Namespaces 1.0 §3 prebound `xml` prefix namespace.
pub fn ns_xml_1998() -> String {
  @xml.ns_xml_1998()
}

///|
/// OPC Part 2 §9.1 package relationship type for the Office Document start part.
pub fn relationship_type_office_document() -> String {
  "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
}

///|
/// DrawingML §20.5 SpreadsheetDrawing namespace.
pub fn ns_spreadsheet_drawing() -> String {
  "http://purl.oclc.org/ooxml/drawingml/spreadsheetDrawing"
}
