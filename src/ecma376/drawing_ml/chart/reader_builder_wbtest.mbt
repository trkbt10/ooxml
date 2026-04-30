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
