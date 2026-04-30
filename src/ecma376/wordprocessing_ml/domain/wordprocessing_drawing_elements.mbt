///|
/// Construct top-level dml-wordprocessingDrawing element wpc as CT_WordprocessingCanvas (§20.4).
pub fn wpc(element : @xml.Element) -> CT_WordprocessingCanvas {
  CT_WordprocessingCanvas::new(element)
}

///|
/// Construct top-level dml-wordprocessingDrawing element wgp as CT_WordprocessingGroup (§20.4).
pub fn wgp(element : @xml.Element) -> CT_WordprocessingGroup {
  CT_WordprocessingGroup::new(element)
}

///|
/// Construct top-level dml-wordprocessingDrawing element wsp as CT_WordprocessingShape (§20.4).
pub fn wsp(element : @xml.Element) -> CT_WordprocessingShape {
  CT_WordprocessingShape::new(element)
}

///|
/// Construct top-level dml-wordprocessingDrawing element inline as CT_Inline (§20.4).
pub fn inline(element : @xml.Element) -> CT_Inline {
  CT_Inline::new(element)
}

///|
/// Construct top-level dml-wordprocessingDrawing element anchor as CT_Anchor (§20.4).
pub fn anchor(element : @xml.Element) -> CT_Anchor {
  CT_Anchor::new(element)
}
