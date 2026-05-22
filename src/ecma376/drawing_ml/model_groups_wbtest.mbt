///|
test "EG_ShadeProperties typed projection of gradient fill children" {
  let value = read_gradient_fill_properties(
    b"<a:gradFill xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:gsLst/><a:lin/></a:gradFill>",
  )
  // The <a:lin/> child is a CT_LinearShadeProperties — the typed
  // projection should report exactly that arm via
  // `find_shade_properties_child`.
  let found = find_shade_properties_child(value.element)
  match found {
    Some(Lin(_)) => assert_true(true)
    _ => fail("expected Lin(...) from EG_ShadeProperties")
  }
}

///|
test "EG_ShadeProperties typed projection of path-shaded gradient" {
  let value = read_gradient_fill_properties(
    b"<a:gradFill xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:gsLst/><a:path path=\"rect\"/></a:gradFill>",
  )
  let found = find_shade_properties_child(value.element)
  match found {
    Some(Path(_)) => assert_true(true)
    _ => fail("expected Path(...) from EG_ShadeProperties")
  }
}

///|
test "collect DrawingML blob attribute group names" {
  let value = read_blip(
    b"<a:blip xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" xmlns:r=\"http://purl.oclc.org/ooxml/officeDocument/relationships\" r:embed=\"rId1\" cstate=\"print\"/>",
  )
  let group = AG_Blob::new(value.element)
  assert_true(group.has_attribute("embed"))
  assert_eq(group.attribute_names().length(), 2)
}
