///|
test "round-trip graphical object" {
  let value = read_graphical_object(
    bytes(
      "<a:graphic xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:graphicData uri=\"http://example.invalid/drawing\"><a:payload/></a:graphicData></a:graphic>",
    ),
  )
  assert_eq(value.element.name.local_name, "graphic")
  let reparsed = read_graphical_object(write_graphical_object(value))
  assert_eq(reparsed.element.name.local_name, "graphic")
}

///|
test "round-trip drawing table" {
  let value = read_table(
    bytes(
      "<a:tbl xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:tblPr firstRow=\"1\" bandRow=\"1\"><a:tableStyleId>{11111111-1111-1111-1111-111111111111}</a:tableStyleId></a:tblPr><a:tblGrid><a:gridCol w=\"914400\"/></a:tblGrid><a:tr h=\"370840\"><a:tc gridSpan=\"1\"><a:txBody><a:bodyPr/><a:p><a:r><a:t>Cell</a:t></a:r></a:p></a:txBody><a:tcPr marL=\"91440\" anchor=\"ctr\"/></a:tc></a:tr></a:tbl>",
    ),
  )
  assert_eq(value.element.name.local_name, "tbl")
  let reparsed = read_table(write_table(value))
  assert_eq(reparsed.element.name.local_name, "tbl")
}

///|
test "round-trip table style list" {
  let value = read_table_style_list(
    bytes(
      "<a:tblStyleLst xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" def=\"{11111111-1111-1111-1111-111111111111}\"><a:tblStyle styleId=\"{22222222-2222-2222-2222-222222222222}\" styleName=\"Plain\"><a:wholeTbl><a:tcTxStyle b=\"1\" i=\"0\"/><a:tcStyle><a:tcBdr/></a:tcStyle></a:wholeTbl></a:tblStyle></a:tblStyleLst>",
    ),
  )
  assert_eq(value.element.name.local_name, "tblStyleLst")
  let reparsed = read_table_style_list(write_table_style_list(value))
  assert_eq(reparsed.element.name.local_name, "tblStyleLst")
}

///|
test "reject wrong graphical object root" {
  try {
    read_graphical_object(
      bytes("<a:tbl xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"/>"),
    )
    |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
