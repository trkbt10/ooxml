///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "read and write DML diagram colorsDef element" {
  let value = read_colors_def(
    bytes(
      "<dgm:colorsDef xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "colorsDef")
  let reparsed = read_colors_def(write_colors_def(value))
  assert_eq(reparsed.element.name.local_name, "colorsDef")
}

///|
test "read and write DML diagram colorsDefHdr element" {
  let value = read_colors_def_hdr(
    bytes(
      "<dgm:colorsDefHdr xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "colorsDefHdr")
  let reparsed = read_colors_def_hdr(write_colors_def_hdr(value))
  assert_eq(reparsed.element.name.local_name, "colorsDefHdr")
}

///|
test "read and write DML diagram colorsDefHdrLst element" {
  let value = read_colors_def_hdr_lst(
    bytes(
      "<dgm:colorsDefHdrLst xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "colorsDefHdrLst")
  let reparsed = read_colors_def_hdr_lst(write_colors_def_hdr_lst(value))
  assert_eq(reparsed.element.name.local_name, "colorsDefHdrLst")
}

///|
test "read and write DML diagram dataModel element" {
  let value = read_data_model(
    bytes(
      "<dgm:dataModel xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "dataModel")
  let reparsed = read_data_model(write_data_model(value))
  assert_eq(reparsed.element.name.local_name, "dataModel")
}

///|
test "read and write DML diagram layoutDef element" {
  let value = read_layout_def(
    bytes(
      "<dgm:layoutDef xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "layoutDef")
  let reparsed = read_layout_def(write_layout_def(value))
  assert_eq(reparsed.element.name.local_name, "layoutDef")
}

///|
test "read and write DML diagram layoutDefHdr element" {
  let value = read_layout_def_hdr(
    bytes(
      "<dgm:layoutDefHdr xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "layoutDefHdr")
  let reparsed = read_layout_def_hdr(write_layout_def_hdr(value))
  assert_eq(reparsed.element.name.local_name, "layoutDefHdr")
}

///|
test "read and write DML diagram layoutDefHdrLst element" {
  let value = read_layout_def_hdr_lst(
    bytes(
      "<dgm:layoutDefHdrLst xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "layoutDefHdrLst")
  let reparsed = read_layout_def_hdr_lst(write_layout_def_hdr_lst(value))
  assert_eq(reparsed.element.name.local_name, "layoutDefHdrLst")
}

///|
test "read and write DML diagram relIds element" {
  let value = read_rel_ids(
    bytes(
      "<dgm:relIds xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "relIds")
  let reparsed = read_rel_ids(write_rel_ids(value))
  assert_eq(reparsed.element.name.local_name, "relIds")
}

///|
test "read and write DML diagram styleDef element" {
  let value = read_style_def(
    bytes(
      "<dgm:styleDef xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "styleDef")
  let reparsed = read_style_def(write_style_def(value))
  assert_eq(reparsed.element.name.local_name, "styleDef")
}

///|
test "read and write DML diagram styleDefHdr element" {
  let value = read_style_def_hdr(
    bytes(
      "<dgm:styleDefHdr xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "styleDefHdr")
  let reparsed = read_style_def_hdr(write_style_def_hdr(value))
  assert_eq(reparsed.element.name.local_name, "styleDefHdr")
}

///|
test "read and write DML diagram styleDefHdrLst element" {
  let value = read_style_def_hdr_lst(
    bytes(
      "<dgm:styleDefHdrLst xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "styleDefHdrLst")
  let reparsed = read_style_def_hdr_lst(write_style_def_hdr_lst(value))
  assert_eq(reparsed.element.name.local_name, "styleDefHdrLst")
}
