// vml-presentationDrawing.xsd typed CT projections — Part 4 §A.6.62..§A.6.63.
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
/// XSD complex type CT_Empty — Part 4 §A.6.62 (vml-presentationDrawing.xsd).
/// Sentinel empty element with no attributes or children. Used by
/// `pvml:iscomment` to flag a shape as a comment marker.
pub(all) struct CT_Empty {
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Empty::new(element : @xml.Element) -> CT_Empty {
  { raw_element: element }
}

///|
pub fn CT_Empty::to_element(self : CT_Empty) -> @xml.Element {
  self.raw_element
}

///|
/// XSD complex type CT_Rel — Part 4 §A.6.63 (vml-presentationDrawing.xsd).
/// Single optional relationship `@id` attribute. Used by `pvml:textdata`
/// to attach an OPC relationship to the shape text payload.
pub(all) struct CT_Rel {
  /// @id (xsd:string, optional).
  id : String?
  raw_element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rel::new(element : @xml.Element) -> CT_Rel {
  let id = pvml_attr(element, "id")
  { id, raw_element: element }
}

///|
pub fn CT_Rel::to_element(self : CT_Rel) -> @xml.Element {
  self.raw_element
}
