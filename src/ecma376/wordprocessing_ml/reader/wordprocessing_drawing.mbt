///|
/// Read top-level dml-wordprocessingDrawing element wpc as CT_WordprocessingCanvas (§20.4).
pub fn read_wpc(bytes : Bytes) -> @domain.CT_WordprocessingCanvas raise {
  @domain.wpc(read_wordprocessing_drawing_root(bytes, "wpc"))
}

///|
/// Read top-level dml-wordprocessingDrawing element wgp as CT_WordprocessingGroup (§20.4).
pub fn read_wgp(bytes : Bytes) -> @domain.CT_WordprocessingGroup raise {
  @domain.wgp(read_wordprocessing_drawing_root(bytes, "wgp"))
}

///|
/// Read top-level dml-wordprocessingDrawing element wsp as CT_WordprocessingShape (§20.4).
pub fn read_wsp(bytes : Bytes) -> @domain.CT_WordprocessingShape raise {
  @domain.wsp(read_wordprocessing_drawing_root(bytes, "wsp"))
}

///|
/// Read top-level dml-wordprocessingDrawing element inline as CT_Inline (§20.4).
pub fn read_inline(bytes : Bytes) -> @domain.CT_Inline raise {
  @domain.inline(read_wordprocessing_drawing_root(bytes, "inline"))
}

///|
/// Read top-level dml-wordprocessingDrawing element anchor as CT_Anchor (§20.4).
pub fn read_anchor(bytes : Bytes) -> @domain.CT_Anchor raise {
  @domain.anchor(read_wordprocessing_drawing_root(bytes, "anchor"))
}

///|
fn read_wordprocessing_drawing_root(
  bytes : Bytes,
  local_name : String,
) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  if root.name.local_name != local_name {
    @domain.raise_schema_violation(
      "dml-wordprocessingDrawing.xsd top-level element",
      root.name.local_name,
      "expected " + local_name,
    )
  }
  root
}
