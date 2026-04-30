///|
/// Write top-level dml-wordprocessingDrawing element wpc from CT_WordprocessingCanvas (§20.4).
pub fn write_wpc(value : @domain.CT_WordprocessingCanvas) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level dml-wordprocessingDrawing element wgp from CT_WordprocessingGroup (§20.4).
pub fn write_wgp(value : @domain.CT_WordprocessingGroup) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level dml-wordprocessingDrawing element wsp from CT_WordprocessingShape (§20.4).
pub fn write_wsp(value : @domain.CT_WordprocessingShape) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level dml-wordprocessingDrawing element inline from CT_Inline (§20.4).
pub fn write_inline(value : @domain.CT_Inline) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level dml-wordprocessingDrawing element anchor from CT_Anchor (§20.4).
pub fn write_anchor(value : @domain.CT_Anchor) -> Bytes {
  write_element(value.element)
}
