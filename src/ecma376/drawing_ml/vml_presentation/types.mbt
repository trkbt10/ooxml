// vml-presentationDrawing.xsd typed CT projections — Part 4 §A.7.5.
// Target namespace: urn:schemas-microsoft-com:office:powerpoint (`pvml:` prefix).
//
// XSD elements:
//   <xsd:element name="iscomment" type="CT_Empty"/>
//   <xsd:element name="textdata" type="CT_Rel"/>

///|
/// Schema validation error raised by the typed CT readers in this
/// package.
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// Look up an attribute on an element by local name. PVML's only
/// schema attribute is `@id` (unqualified) on CT_Rel.
fn pvml_attr(element : @xml.Element, name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == name {
      return Some(attribute.value)
    }
  }
  None
}

///|
/// XSD complex type CT_Empty — Part 4 §A.7.5 (vml-presentationDrawing.xsd).
/// Sentinel empty element with no attributes or children. Used by
/// `pvml:iscomment` to flag a shape as a comment marker.
pub(all) struct CT_Empty {
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
/// Validate the empty content model and produce a `CT_Empty`.
/// Per Part 4 §A.7.5, `pvml:iscomment` is an empty complex type with
/// no attributes and no element children; raises `SchemaViolation` if
/// the source element carries either.
pub fn CT_Empty::new(element : @xml.Element) -> CT_Empty raise SchemaViolation {
  if element.attributes.length() > 0 {
    raise SchemaViolation(
      schema="vml-presentationDrawing.xsd",
      path="CT_Empty/@*",
      reason="CT_Empty must not declare any attributes",
    )
  }
  for child in element.children {
    if child is @xml.Node::Element(_) {
      raise SchemaViolation(
        schema="vml-presentationDrawing.xsd",
        path="CT_Empty/*",
        reason="CT_Empty must not contain element children",
      )
    }
  }
  { raw_element: element }
}

///|
pub fn CT_Empty::to_element(self : CT_Empty) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Rel — Part 4 §A.7.5 (vml-presentationDrawing.xsd).
/// Single optional relationship `@id` attribute. Used by `pvml:textdata`
/// to attach an OPC relationship to the shape text payload.
pub(all) struct CT_Rel {
  /// @id (xsd:string, optional).
  id : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
/// Validate the relationship-shaped content model and produce a
/// `CT_Rel`. Per Part 4 §A.7.5, `pvml:textdata` carries at most the
/// optional `@id` attribute and no element children; raises
/// `SchemaViolation` if any other attribute or any element child is
/// present.
pub fn CT_Rel::new(element : @xml.Element) -> CT_Rel raise SchemaViolation {
  for attribute in element.attributes {
    if attribute.name.local_name != "id" {
      raise SchemaViolation(
        schema="vml-presentationDrawing.xsd",
        path="CT_Rel/@" + attribute.name.local_name,
        reason="CT_Rel only permits the optional @id attribute",
      )
    }
  }
  for child in element.children {
    if child is @xml.Node::Element(_) {
      raise SchemaViolation(
        schema="vml-presentationDrawing.xsd",
        path="CT_Rel/*",
        reason="CT_Rel must not contain element children",
      )
    }
  }
  let id = pvml_attr(element, "id")
  { id, raw_element: element }
}

///|
pub fn CT_Rel::to_element(self : CT_Rel) -> @xml.Element {
  self.raw_element
}
