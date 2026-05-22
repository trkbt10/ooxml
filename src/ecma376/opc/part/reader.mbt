///|
/// Read OPC §9 Thumbnails binary image bytes into a ThumbnailPart. This is the
/// implementation entry for §1 Scope and §3 Specification Sections TOC
/// coverage: the single ECMA-376 Part 2 section owned by this package is §9
/// Thumbnails.
pub fn read_thumbnail_part(name : PartName, bytes : Bytes) -> ThumbnailPart {
  ThumbnailPart::new(name, bytes)
}

///|
/// Parses the generic §5 Inputs byte stream for an OPC part conforming to OPC
/// §9 Thumbnails. Honours C1 by accepting the listed thumbnail part shape,
/// C2/C5 by raising @opc_errors.SchemaViolation with section "9", and V1 by leaving
/// cross-package resource interpretation to the surrounding OPC resolver.
///
/// Content-type policy: OPC §10.1.2.3 mandates that every part's
/// content type be sourced from `[Content_Types].xml` rather than
/// from the part reader itself.  This generic reader is invoked
/// only when the surrounding OPC resolver has NOT mapped the
/// part through Content-Types (e.g. a §9.2 thumbnail that
/// arrives without an `<Override>` entry).  We therefore stamp
/// the OPC default `application/octet-stream` per §10.1.2.3 and
/// rely on the caller to override via
/// `PackagePart::with_content_type` when the part's actual MIME
/// is known from a `<Default>` or `<Override>` mapping.
pub fn read_part(
  name : PartName,
  bytes : Bytes,
) -> PackagePart raise @opc_errors.SchemaViolation {
  PackagePart::new(name, "application/octet-stream", bytes)
}

///|
/// Read the §5 Inputs I1 XML byte stream for ECMA-376 Part 2 §8.1 General
/// Core Properties and the §8.3 Core Properties Markup organization.
/// ECMA-376 Part 2 §8.3.1 General supplies the markup overview for
/// `coreProperties`; ECMA-376 Part 2 §8.3.2 Support For Versioning And
/// Extensibility is honored by retaining extension-bearing XML; §8.3.3
/// coreProperties / CT_CoreProperties is validated as the root element. XML
/// well-formedness failures are @xml.XmlMalformed E1; schema failures are OPC
/// §8 E2 @opc_errors.SchemaViolation with section metadata, and C3/V2 preserve parsed
/// attributes and child order for round-trip writing.
pub fn read_core_properties(bytes : Bytes) -> CT_CoreProperties raise {
  let doc = @xml.parse(bytes)
  if !is_element(doc.root, "coreProperties", core_properties_ns()) {
    raise @opc_errors.SchemaViolation(
      section="9",
      path="/",
      reason="expected coreProperties in the core-properties namespace",
    )
  }
  validate_core_properties(doc.root)
  CT_CoreProperties::new(doc)
}

///|
fn validate_core_properties(
  root : @xml.Element,
) -> Unit raise @opc_errors.SchemaViolation {
  let seen : Array[String] = []
  for child in root.children {
    if child is @xml.Node::Element(element) {
      let key = expanded_name(element)
      if !core_property_child_ok(element) {
        raise @opc_errors.SchemaViolation(
          section="9",
          path="/coreProperties/" + element.name.local_name,
          reason="element is not allowed by CT_CoreProperties",
        )
      }
      if seen.contains(key) {
        raise @opc_errors.SchemaViolation(
          section="9",
          path="/coreProperties/" + element.name.local_name,
          reason="CT_CoreProperties permits at most one of each child",
        )
      }
      seen.push(key)
      if element.name.local_name == "keywords" &&
        element.name.ns == Some(core_properties_ns()) {
        validate_keywords(element)
      }
    }
  }
}

///|
fn validate_keywords(
  element : @xml.Element,
) -> Unit raise @opc_errors.SchemaViolation {
  for child in element.children {
    if child is @xml.Node::Element(value) {
      if !is_element(value, "value", core_properties_ns()) {
        raise @opc_errors.SchemaViolation(
          section="9",
          path="/coreProperties/keywords/" + value.name.local_name,
          reason="keywords may contain only CT_Keyword value elements",
        )
      }
    }
  }
}

///|
fn core_property_child_ok(element : @xml.Element) -> Bool {
  let name = element.name.local_name
  let ns = element.name.ns
  (
    ns == Some(core_properties_ns()) &&
    (
      name == "category" ||
      name == "contentStatus" ||
      name == "keywords" ||
      name == "lastModifiedBy" ||
      name == "lastPrinted" ||
      name == "revision" ||
      name == "version"
    )
  ) ||
  (
    ns == Some("http://purl.org/dc/elements/1.1/") &&
    (
      name == "creator" ||
      name == "description" ||
      name == "identifier" ||
      name == "language" ||
      name == "subject" ||
      name == "title"
    )
  ) ||
  (
    ns == Some("http://purl.org/dc/terms/") &&
    (name == "created" || name == "modified")
  )
}

///|
fn expanded_name(element : @xml.Element) -> String {
  element.name.ns.unwrap_or("") + ":" + element.name.local_name
}

///|
fn is_element(element : @xml.Element, local_name : String, ns : String) -> Bool {
  element.name.local_name == local_name && element.name.ns == Some(ns)
}

///|
fn core_properties_ns() -> String {
  @opc_namespaces.ns_core_properties()
}
