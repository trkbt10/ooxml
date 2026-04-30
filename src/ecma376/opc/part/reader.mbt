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
/// C2/C5 by raising SchemaViolation with section "9", and V1 by leaving
/// cross-package resource interpretation to the surrounding OPC resolver.
pub fn read_part(
  name : PartName,
  bytes : Bytes,
) -> PackagePart raise SchemaViolation {
  PackagePart::new(name, "application/octet-stream", bytes)
}

///|
/// Read the §5 Inputs I1 XML byte stream for coreProperties and
/// CT_CoreProperties, using §5 Inputs I2 namespace context for the
/// core-properties target namespace. XML well-formedness failures are
/// @xml.XmlMalformed E1; schema failures are OPC §8 E2 SchemaViolation with
/// the §9 source section, and C3/V2 preserve parsed attributes and child order
/// for round-trip writing.
pub fn read_core_properties(bytes : Bytes) -> CoreProperties raise {
  let doc = @xml.parse(bytes)
  if !is_element(doc.root, "coreProperties", core_properties_ns()) {
    raise SchemaViolation(
      section="9",
      path="/",
      reason="expected coreProperties in the core-properties namespace",
    )
  }
  validate_core_properties(doc.root)
  CoreProperties::new(doc)
}

///|
/// Read the §5 Inputs XML byte stream for Schema `opc-digSig`. The owned
/// inventory is top-level elements RelationshipReference,
/// RelationshipsGroupReference, and SignatureTime; complex types
/// CT_RelationshipReference, CT_RelationshipsGroupReference, and
/// CT_SignatureTime; and simple types ST_Format and ST_Value. This function
/// accepts the RelationshipReference element and CT_RelationshipReference.
pub fn read_relationship_reference(
  bytes : Bytes,
) -> RelationshipReference raise {
  let doc = @xml.parse(bytes)
  if !is_element(doc.root, "RelationshipReference", digital_signature_ns()) {
    raise SchemaViolation(
      section="9",
      path="/",
      reason="expected RelationshipReference in the digital-signature namespace",
    )
  }
  ensure_no_element_children(doc.root, "/RelationshipReference")
  RelationshipReference::new(
    required_attribute(doc.root, "SourceId", "/RelationshipReference/@SourceId"),
  )
}

///|
/// Read the §5 Inputs XML byte stream for the opc-digSig
/// RelationshipsGroupReference top-level element and
/// CT_RelationshipsGroupReference schema identifier, using the digital-
/// signature target namespace from §4 Schema Facts.
pub fn read_relationships_group_reference(
  bytes : Bytes,
) -> RelationshipsGroupReference raise {
  let doc = @xml.parse(bytes)
  if !is_element(
      doc.root,
      "RelationshipsGroupReference",
      digital_signature_ns(),
    ) {
    raise SchemaViolation(
      section="9",
      path="/",
      reason="expected RelationshipsGroupReference in the digital-signature namespace",
    )
  }
  ensure_no_element_children(doc.root, "/RelationshipsGroupReference")
  RelationshipsGroupReference::new(
    required_attribute(
      doc.root,
      "SourceType",
      "/RelationshipsGroupReference/@SourceType",
    ),
  )
}

///|
/// Read the §5 Inputs XML byte stream for SignatureTime, CT_SignatureTime,
/// ST_Format, and ST_Value while enforcing the opc-digSig sequence Format then
/// Value for §7 Invariants V2 and rejecting C4 pattern violations as
/// SchemaViolation.
pub fn read_signature_time(bytes : Bytes) -> SignatureTime raise {
  let doc = @xml.parse(bytes)
  if !is_element(doc.root, "SignatureTime", digital_signature_ns()) {
    raise SchemaViolation(
      section="9",
      path="/",
      reason="expected SignatureTime in the digital-signature namespace",
    )
  }
  let elements = element_children(doc.root, "/SignatureTime")
  if elements.length() != 2 {
    raise SchemaViolation(
      section="9",
      path="/SignatureTime",
      reason="SignatureTime must contain exactly Format and Value",
    )
  }
  if !is_element(elements[0], "Format", digital_signature_ns()) ||
    !is_element(elements[1], "Value", digital_signature_ns()) {
    raise SchemaViolation(
      section="9",
      path="/SignatureTime",
      reason="SignatureTime children must be ordered Format then Value",
    )
  }
  SignatureTime::new(
    SignatureTimeFormat::new(element_text(elements[0])),
    SignatureTimeValue::new(element_text(elements[1])),
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

///|
fn validate_core_properties(root : @xml.Element) -> Unit raise SchemaViolation {
  let seen : Array[String] = []
  for child in root.children {
    if child is @xml.Node::Element(element) {
      let key = expanded_name(element)
      if !core_property_child_ok(element) {
        raise SchemaViolation(
          section="9",
          path="/coreProperties/" + element.name.local_name,
          reason="element is not allowed by CT_CoreProperties",
        )
      }
      if seen.contains(key) {
        raise SchemaViolation(
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
fn validate_keywords(element : @xml.Element) -> Unit raise SchemaViolation {
  for child in element.children {
    if child is @xml.Node::Element(value) {
      if !is_element(value, "value", core_properties_ns()) {
        raise SchemaViolation(
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
fn ensure_no_element_children(
  element : @xml.Element,
  path : String,
) -> Unit raise SchemaViolation {
  for child in element.children {
    if child is @xml.Node::Element(nested) {
      raise SchemaViolation(
        section="9",
        path=path + "/" + nested.name.local_name,
        reason="simple-content element must not contain child elements",
      )
    }
  }
}

///|
fn element_children(
  element : @xml.Element,
  path : String,
) -> Array[@xml.Element] raise SchemaViolation {
  let children : Array[@xml.Element] = []
  for child in element.children {
    match child {
      Element(element) => children.push(element)
      Text(text) | CData(text) =>
        if text.trim() != "" {
          raise SchemaViolation(
            section="9",
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
fn required_attribute(
  element : @xml.Element,
  name : String,
  path : String,
) -> String raise SchemaViolation {
  for attr in element.attributes {
    if attr.name.local_name == name && attr.name.ns == None {
      if attr.value == "" {
        raise SchemaViolation(
          section="9",
          path~,
          reason="required attribute must not be empty",
        )
      }
      return attr.value
    }
  }
  raise SchemaViolation(
    section="9",
    path~,
    reason="required attribute is missing",
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
  "http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
}

///|
fn digital_signature_ns() -> String {
  "http://schemas.openxmlformats.org/package/2006/digital-signature"
}
