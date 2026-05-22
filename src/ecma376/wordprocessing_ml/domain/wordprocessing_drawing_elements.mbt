///|
/// Construct top-level dml-wordprocessingDrawing element wpc as
/// CT_WordprocessingCanvas (§20.4.2.29).
pub fn wpc(
  element : @xml.Element,
) -> CT_WordprocessingCanvas raise SchemaViolation {
  CT_WordprocessingCanvas::new(element)
}

///|
/// Construct top-level dml-wordprocessingDrawing element wgp as
/// CT_WordprocessingGroup (§20.4.2.28).
pub fn wgp(
  element : @xml.Element,
) -> CT_WordprocessingGroup raise SchemaViolation {
  CT_WordprocessingGroup::new(element)
}

///|
/// Construct top-level dml-wordprocessingDrawing element wsp as
/// CT_WordprocessingShape (§20.4.2.26).
pub fn wsp(
  element : @xml.Element,
) -> CT_WordprocessingShape raise SchemaViolation {
  CT_WordprocessingShape::new(element)
}

///|
/// Construct top-level dml-wordprocessingDrawing element inline as
/// CT_Inline (§20.4.2.8).
pub fn inline(element : @xml.Element) -> CT_Inline raise SchemaViolation {
  CT_Inline::new(element)
}

///|
/// Construct top-level dml-wordprocessingDrawing element anchor as
/// CT_Anchor (§20.4.2.3).
pub fn anchor(element : @xml.Element) -> CT_Anchor raise SchemaViolation {
  CT_Anchor::new(element)
}
