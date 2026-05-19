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
  // §21.4.4.4 colorsDefHdr requires @uniqueId plus at least one
  // <title> and one <desc> child per dml-diagram.xsd CT_ColorTransformHeader.
  let value = read_colors_def_hdr(
    bytes(
      "<dgm:colorsDefHdr xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"" +
      " uniqueId=\"urn:test:colorsDefHdr\">" +
      "<dgm:title val=\"Colors Header\"/>" +
      "<dgm:desc val=\"Colors Header Description\"/>" +
      "</dgm:colorsDefHdr>",
    ),
  )
  assert_eq(value.element.name.local_name, "colorsDefHdr")
  assert_eq(value.unique_id, "urn:test:colorsDefHdr")
  let reparsed = read_colors_def_hdr(write_colors_def_hdr(value))
  assert_eq(reparsed.element.name.local_name, "colorsDefHdr")
  assert_eq(reparsed.unique_id, "urn:test:colorsDefHdr")
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
  // §21.4.2.10 dataModel requires <ptLst> child per
  // dml-diagram.xsd CT_DataModel (ptLst has minOccurs=1).
  let value = read_data_model(
    bytes(
      "<dgm:dataModel xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\">" +
      "<dgm:ptLst/>" +
      "</dgm:dataModel>",
    ),
  )
  assert_eq(value.element.name.local_name, "dataModel")
  assert_eq(value.pt_lst.pt.length(), 0)
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
  // §21.4.2.17 layoutDefHdr requires @uniqueId plus at least one
  // <title>/<desc> per dml-diagram.xsd CT_DiagramDefinitionHeader.
  let value = read_layout_def_hdr(
    bytes(
      "<dgm:layoutDefHdr xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"" +
      " uniqueId=\"urn:test:layoutDefHdr\">" +
      "<dgm:title val=\"Layout Header\"/>" +
      "<dgm:desc val=\"Layout Header Description\"/>" +
      "</dgm:layoutDefHdr>",
    ),
  )
  assert_eq(value.element.name.local_name, "layoutDefHdr")
  assert_eq(value.unique_id, "urn:test:layoutDefHdr")
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
  // §21.4.2.22 relIds requires r:dm, r:lo, r:qs, r:cs attributes
  // per dml-diagram.xsd CT_RelIds.
  let value = read_rel_ids(
    bytes(
      "<dgm:relIds xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"" +
      " xmlns:r=\"http://purl.oclc.org/ooxml/officeDocument/relationships\"" +
      " r:dm=\"rId1\" r:lo=\"rId2\" r:qs=\"rId3\" r:cs=\"rId4\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "relIds")
  assert_eq(value.dm, "rId1")
  assert_eq(value.lo, "rId2")
  assert_eq(value.qs, "rId3")
  assert_eq(value.cs, "rId4")
  let reparsed = read_rel_ids(write_rel_ids(value))
  assert_eq(reparsed.element.name.local_name, "relIds")
  assert_eq(reparsed.dm, "rId1")
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
  // §21.4.5.8 styleDefHdr requires @uniqueId plus at least one
  // <title>/<desc> per dml-diagram.xsd CT_StyleDefinitionHeader.
  let value = read_style_def_hdr(
    bytes(
      "<dgm:styleDefHdr xmlns:dgm=\"http://purl.oclc.org/ooxml/drawingml/diagram\"" +
      " uniqueId=\"urn:test:styleDefHdr\">" +
      "<dgm:title val=\"Style Header\"/>" +
      "<dgm:desc val=\"Style Header Description\"/>" +
      "</dgm:styleDefHdr>",
    ),
  )
  assert_eq(value.element.name.local_name, "styleDefHdr")
  assert_eq(value.unique_id, "urn:test:styleDefHdr")
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
