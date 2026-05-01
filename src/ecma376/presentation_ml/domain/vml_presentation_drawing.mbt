///|
/// XSD complex type VmlPresentationDrawing_CT_Empty from vml-presentationDrawing.xsd (Part 4 §16).
pub(all) struct VmlPresentationDrawing_CT_Empty {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn VmlPresentationDrawing_CT_Empty::new(
  element : @xml.Element,
) -> VmlPresentationDrawing_CT_Empty {
  { element, }
}

///|
pub fn VmlPresentationDrawing_CT_Empty::parse(
  element : @xml.Element,
) -> VmlPresentationDrawing_CT_Empty {
  VmlPresentationDrawing_CT_Empty::new(element)
}

///|
pub fn VmlPresentationDrawing_CT_Empty::to_element(
  self : VmlPresentationDrawing_CT_Empty,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Rel: Schema vml-presentationDrawing.xsd complex type
/// `CT_Rel` has attribute `id`; VmlPresentationDrawing_CT_Rel,
/// VmlPresentationDrawing_CT_Rel::new, VmlPresentationDrawing_CT_Rel::parse,
/// and VmlPresentationDrawing_CT_Rel::to_element own that VML relationship
/// payload.
pub(all) struct VmlPresentationDrawing_CT_Rel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn VmlPresentationDrawing_CT_Rel::new(
  element : @xml.Element,
) -> VmlPresentationDrawing_CT_Rel {
  { element, }
}

///|
pub fn VmlPresentationDrawing_CT_Rel::parse(
  element : @xml.Element,
) -> VmlPresentationDrawing_CT_Rel {
  VmlPresentationDrawing_CT_Rel::new(element)
}

///|
pub fn VmlPresentationDrawing_CT_Rel::to_element(
  self : VmlPresentationDrawing_CT_Rel,
) -> @xml.Element {
  self.element
}

///|
/// Construct top-level vml-presentationDrawing.xsd element iscomment as VmlPresentationDrawing_CT_Empty (Part 4 §16).
pub fn vml_presentation_drawing_iscomment(
  element : @xml.Element,
) -> VmlPresentationDrawing_CT_Empty {
  VmlPresentationDrawing_CT_Empty::new(element)
}

///|
/// Construct top-level vml-presentationDrawing.xsd element textdata as VmlPresentationDrawing_CT_Rel (Part 4 §16).
pub fn vml_presentation_drawing_textdata(
  element : @xml.Element,
) -> VmlPresentationDrawing_CT_Rel {
  VmlPresentationDrawing_CT_Rel::new(element)
}
