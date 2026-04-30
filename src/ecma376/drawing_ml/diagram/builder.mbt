///|
/// Write top-level XSD element colorsDef.
pub fn write_colors_def(value : ColorsDef) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element colorsDefHdr.
pub fn write_colors_def_hdr(value : ColorsDefHdr) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element colorsDefHdrLst.
pub fn write_colors_def_hdr_lst(value : ColorsDefHdrLst) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element dataModel.
pub fn write_data_model(value : DataModel) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element layoutDef.
pub fn write_layout_def(value : LayoutDef) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element layoutDefHdr.
pub fn write_layout_def_hdr(value : LayoutDefHdr) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element layoutDefHdrLst.
pub fn write_layout_def_hdr_lst(value : LayoutDefHdrLst) -> Bytes {
  write_element(value.element)
}

///|
/// §21.4 RelIds writer for top-level XSD element relIds.
pub fn write_rel_ids(value : RelIds) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element styleDef.
pub fn write_style_def(value : StyleDef) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element styleDefHdr.
pub fn write_style_def_hdr(value : StyleDefHdr) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element styleDefHdrLst.
pub fn write_style_def_hdr_lst(value : StyleDefHdrLst) -> Bytes {
  write_element(value.element)
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}
