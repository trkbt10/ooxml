///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "locked canvas round trips through reader and writer" {
  // §20.3.2.1 CT_GvmlLockedCanvas requires <nvGrpSpPr> and <grpSpPr>
  // (a:CT_GvmlGroupShape). nvGrpSpPr in turn requires <cNvPr id=..
  // name=..> and <cNvGrpSpPr/>, so the minimal valid lockedCanvas
  // has those four children with the required cNvPr attributes set.
  let source = bytes(
    "<lc:lockedCanvas xmlns:lc=\"http://purl.oclc.org/ooxml/drawingml/lockedCanvas\" xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\">" +
    "<a:nvGrpSpPr><a:cNvPr id=\"1\" name=\"canvas\"/><a:cNvGrpSpPr/></a:nvGrpSpPr>" +
    "<a:grpSpPr/>" +
    "</lc:lockedCanvas>",
  )
  let parsed = try! read_locked_canvas(source)
  assert_eq(parsed.element.name.local_name, "lockedCanvas")
  let reparsed = try! read_locked_canvas(write_locked_canvas(parsed))
  assert_true(reparsed == parsed)
}
