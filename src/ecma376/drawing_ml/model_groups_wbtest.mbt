///|
test "collect DrawingML fill model group children" {
  let value = read_gradient_fill_properties(
    b"<a:gradFill xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:gsLst/><a:lin/><a:path/></a:gradFill>",
  )
  let group = EG_ShadeProperties::new(value.element)
  assert_true(group.has_child("lin"))
  assert_true(group.has_child("path"))
  assert_eq(group.child_names().length(), 3)
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
