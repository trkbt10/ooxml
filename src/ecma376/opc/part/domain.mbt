///|
/// OPC §9 Thumbnails use PartName to identify the image part reached from a
/// package or part relationship. The canonical ECMA-376 Part 2 §6.2.2.2
/// grammar and §7.3.3 ZIP item mapping live in `src/ecma376/opc/part_name`.
pub type PartName = @opc_part_name.PartName

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
/// Generic OPC package part record used by the surrounding OPC resolver. It
/// participates in OPC facade coverage for ECMA-376 Part 2 §6.2.1 General,
/// §6.3.1 General, §6.4.1 General, §7.1 General, and §7.3.1 General while it
/// supplies embedded §8 Core Properties and §9 Thumbnails payloads.
/// Source anchor: references/spec/part2/sections/8.1__general.md, owned by
/// src/ecma376/opc/part.
pub(all) struct PackagePart {
  name : PartName
  content_type : String
  data : Bytes
} derive(Eq, Debug)

///|
/// Create an OPC §9 Thumbnails PackagePart. ECMA-376 Part 2 §8.1 General.
/// Source anchor: references/spec/part2/sections/8.1__general.md, owned by
/// src/ecma376/opc/part. The OPC facade also records §6.2.4 Growth Hint and
/// §7.1 General physical package context without interpreting growth-hint
/// metadata.
fn PackagePart::new(
  name : PartName,
  content_type : String,
  data : Bytes,
) -> PackagePart raise @opc_errors.SchemaViolation {
  if content_type == "" {
    raise @opc_errors.SchemaViolation(
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
/// target namespace. It contributes to ECMA-376 Part 2 §8.3.1 General Core
/// Properties Markup through the coreProperties top-level element and the
/// CT_Keywords container. Source anchor:
/// references/spec/part2/sections/8.3.1__general.md, owned by
/// src/ecma376/opc/part.
pub(all) struct CoreKeyword {
  value : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Keyword is the opc-coreProperties.xsd wrapper for one
/// CoreKeyword value.
pub type CT_Keyword = CoreKeyword

///|
/// CT_Keywords container from schema bundle opc-coreProperties.xsd in the
/// http://schemas.openxmlformats.org/package/2006/metadata/core-properties
/// target namespace. The values array preserves the CT_Keyword value sequence
/// exposed by the coreProperties element.
pub(all) struct CoreKeywords {
  values : Array[CoreKeyword]
} derive(Eq, Debug)

///|
/// ECMA-376 Part 2 §8.1 General Core Properties domain value for the package
/// metadata part. ECMA-376 Part 2 §8.3.1 General is the Core Properties
/// Markup overview for the `coreProperties` root. ECMA-376 Part 2 §8.3.2
/// Support For Versioning And Extensibility is represented by preserving the
/// versioning and extensibility markup carried by the parsed XML document.
/// Source anchor: references/spec/part2/sections/8.3.2__support-for-versioning-and-extensibility.md,
/// owned by src/ecma376/opc/part. §8.3.3 coreProperties element /
/// CT_CoreProperties preserve attributes and child ordering for read/write
/// round trip.
pub(all) struct CoreProperties {
  document : @xml.Document
} derive(Eq, Debug)

///|
/// Create a §8.3.3 coreProperties CT_CoreProperties wrapper around validated
/// XML already checked against ECMA-376 Part 2 §8.3.1 General markup overview
/// and §8.3.2 versioning/extensibility allowance. Source anchor:
/// references/spec/part2/sections/8.3.1__general.md, owned by
/// src/ecma376/opc/part.
fn CoreProperties::new(document : @xml.Document) -> CoreProperties {
  { document, }
}
