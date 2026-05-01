///|
test "empty PresentationML context has no relationship resolver" {
  let context = Context::new()
  assert_true(context.resolve_relationship("rId1") == None)
  assert_true(context.slide_master == None)
  assert_true(context.slide_layout == None)
}
