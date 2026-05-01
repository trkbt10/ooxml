///|
test "empty WordprocessingML context has no relationship resolver" {
  let context = Context::new()
  assert_true(context.resolve_relationship("rId1") == None)
  assert_true(context.current_style_id == None)
  assert_true(context.current_numbering_id == None)
}
