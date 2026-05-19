///|
/// Read the §5 Inputs XML byte stream for Schema `opc-digSig`. The owned
/// inventory is top-level elements RelationshipReference,
/// RelationshipsGroupReference, and SignatureTime; complex types
/// CT_RelationshipReference, CT_RelationshipsGroupReference, and
/// CT_SignatureTime; and simple types ST_Format and ST_Value. This function
/// accepts the RelationshipReference element and CT_RelationshipReference.
pub fn read_relationship_reference(
  bytes : Bytes,
) -> CT_RelationshipReference raise {
  let doc = @xml.parse(bytes)
  if !is_element(doc.root, "RelationshipReference", digital_signature_ns()) {
    raise @opc_errors.SchemaViolation(
      section="10",
      path="/",
      reason="expected RelationshipReference in the digital-signature namespace",
    )
  }
  ensure_no_element_children(doc.root, "/RelationshipReference")
  CT_RelationshipReference::new(
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
) -> CT_RelationshipsGroupReference raise {
  let doc = @xml.parse(bytes)
  if !is_element(
      doc.root,
      "RelationshipsGroupReference",
      digital_signature_ns(),
    ) {
    raise @opc_errors.SchemaViolation(
      section="10",
      path="/",
      reason="expected RelationshipsGroupReference in the digital-signature namespace",
    )
  }
  ensure_no_element_children(doc.root, "/RelationshipsGroupReference")
  CT_RelationshipsGroupReference::new(
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
/// Value for 7. Invariants V2 and rejecting C4 pattern violations as
/// @opc_errors.SchemaViolation.
pub fn read_signature_time(bytes : Bytes) -> CT_SignatureTime raise {
  let doc = @xml.parse(bytes)
  if !is_element(doc.root, "SignatureTime", digital_signature_ns()) {
    raise @opc_errors.SchemaViolation(
      section="10",
      path="/",
      reason="expected SignatureTime in the digital-signature namespace",
    )
  }
  let elements = element_children(doc.root, "/SignatureTime")
  if elements.length() != 2 {
    raise @opc_errors.SchemaViolation(
      section="10",
      path="/SignatureTime",
      reason="SignatureTime must contain exactly Format and Value",
    )
  }
  if !is_element(elements[0], "Format", digital_signature_ns()) ||
    !is_element(elements[1], "Value", digital_signature_ns()) {
    raise @opc_errors.SchemaViolation(
      section="10",
      path="/SignatureTime",
      reason="SignatureTime children must be ordered Format then Value",
    )
  }
  CT_SignatureTime::new(
    ST_Format::new(element_text(elements[0])),
    ST_Value::new(element_text(elements[1])),
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
fn ensure_no_element_children(
  element : @xml.Element,
  path : String,
) -> Unit raise @opc_errors.SchemaViolation {
  for child in element.children {
    if child is @xml.Node::Element(nested) {
      raise @opc_errors.SchemaViolation(
        section="10",
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
) -> Array[@xml.Element] raise @opc_errors.SchemaViolation {
  let children : Array[@xml.Element] = []
  for child in element.children {
    match child {
      Element(element) => children.push(element)
      Text(text) | CData(text) =>
        if text.trim() != "" {
          raise @opc_errors.SchemaViolation(
            section="10",
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
) -> String raise @opc_errors.SchemaViolation {
  for attr in element.attributes {
    if attr.name.local_name == name && attr.name.ns == None {
      if attr.value == "" {
        raise @opc_errors.SchemaViolation(
          section="10",
          path~,
          reason="required attribute must not be empty",
        )
      }
      return attr.value
    }
  }
  raise @opc_errors.SchemaViolation(
    section="10",
    path~,
    reason="required attribute is missing",
  )
}

///|
fn is_element(element : @xml.Element, local_name : String, ns : String) -> Bool {
  element.name.local_name == local_name && element.name.ns == Some(ns)
}
