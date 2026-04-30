///|
/// OPC §9 Thumbnails use PartName to identify the image part reached from a
/// package or part relationship.
pub(all) struct PartName {
  value : String
} derive(Eq, Debug)

///|
/// Parse a package part name for OPC §9 Thumbnails. This enforces §2
/// Conformance C2 by rejecting malformed part names that violate structural
/// constraints, and C5 by reporting SchemaViolation with the §9 section
/// reference and local path.
pub fn PartName::parse(value : String) -> PartName raise SchemaViolation {
  if !value.has_prefix("/") {
    raise SchemaViolation(
      section="9",
      path="PartName",
      reason="part name must start with /",
    )
  }
  if value.contains("\\") ||
    value.contains("//") ||
    value.has_suffix("/") ||
    value.contains("/../") ||
    value.contains("/./") {
    raise SchemaViolation(
      section="9",
      path="PartName",
      reason="part name contains a disallowed segment",
    )
  }
  { value, }
}

///|
/// Return the OPC §6 Outputs O1 typed domain value as the lexical part-name
/// attribute used by §9 Thumbnails relationship targets.
pub fn PartName::to_string(self : PartName) -> String {
  self.value
}

///|
/// OPC §9 Thumbnails binary image part identified by a package relationship
/// or a part relationship.
pub(all) struct ThumbnailPart {
  name : PartName
  data : Bytes
} derive(Eq, Debug)

///|
/// Build an OPC §9 Thumbnails binary image part without XML parsing; the
/// writer returns these bytes unchanged.
fn ThumbnailPart::new(name : PartName, data : Bytes) -> ThumbnailPart {
  { name, data }
}

///|
/// OPC §9 Thumbnails generic package part record used by the surrounding OPC
/// resolver when it supplies embedded resources.
pub(all) struct PackagePart {
  name : PartName
  content_type : String
  data : Bytes
} derive(Eq, Debug)

///|
/// Create an OPC §9 Thumbnails PackagePart.
fn PackagePart::new(
  name : PartName,
  content_type : String,
  data : Bytes,
) -> PackagePart raise SchemaViolation {
  if content_type == "" {
    raise SchemaViolation(
      section="9",
      path="PackagePart/@contentType",
      reason="content type must not be empty",
    )
  }
  { name, content_type, data }
}

///|
/// CT_Keyword value from schema bundle opc-coreProperties.xsd in the
/// http://schemas.openxmlformats.org/package/2006/metadata/core-properties
/// target namespace. It contributes to the coreProperties top-level element
/// and the CT_Keywords container.
pub(all) struct CoreKeyword {
  value : String
} derive(Eq, Debug)

///|
/// CT_Keywords container from schema bundle opc-coreProperties.xsd in the
/// http://schemas.openxmlformats.org/package/2006/metadata/core-properties
/// target namespace. The values array preserves the CT_Keyword value sequence
/// exposed by the coreProperties element.
pub(all) struct CoreKeywords {
  values : Array[CoreKeyword]
} derive(Eq, Debug)

///|
/// coreProperties element and CT_CoreProperties preserve the parsed XML
/// document so C3 attributes and child ordering survive read/write round trip.
pub(all) struct CoreProperties {
  document : @xml.Document
} derive(Eq, Debug)

///|
/// Create a coreProperties CT_CoreProperties wrapper around validated XML.
fn CoreProperties::new(document : @xml.Document) -> CoreProperties {
  { document, }
}
