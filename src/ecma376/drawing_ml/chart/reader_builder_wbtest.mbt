///|
test "chartSpace round trip" {
  let bytes = b"<chartSpace xmlns=\"http://purl.oclc.org/ooxml/drawingml/chart\"><chart/></chartSpace>"
  let parsed = read_chart_space(bytes)
  assert_eq(write_chart_space(parsed), bytes)
}

///|
test "userShapes round trip" {
  let bytes = b"<userShapes xmlns=\"http://purl.oclc.org/ooxml/drawingml/chart\"/>"
  let parsed = read_user_shapes(bytes)
  assert_eq(write_user_shapes(parsed), bytes)
}

///|
test "chart round trip" {
  let bytes = b"<chart xmlns=\"http://purl.oclc.org/ooxml/drawingml/chart\"><plotArea/></chart>"
  let parsed = read_chart(bytes)
  assert_eq(write_chart(parsed), bytes)
}

///|
test "relSizeAnchor requires one chartDrawing object choice" {
  let missing = @xml.parse(b"<relSizeAnchor><from/><to/></relSizeAnchor>").root
  assert_true((try? CT_RelSizeAnchor::new(missing)) is Err(SchemaViolation(_)))
  let valid = @xml.parse(b"<relSizeAnchor><from/><to/><sp/></relSizeAnchor>").root
  let parsed = CT_RelSizeAnchor::new(valid)
  assert_true(parsed.sp is Some(_))
}

///|
test "absSizeAnchor rejects multiple chartDrawing object choices" {
  let multiple = @xml.parse(
      b"<absSizeAnchor><from/><ext/><sp/><pic/></absSizeAnchor>",
    ).root
  assert_true((try? CT_AbsSizeAnchor::new(multiple)) is Err(SchemaViolation(_)))
}
