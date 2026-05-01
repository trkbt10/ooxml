///|
test "empty SpreadsheetML context has no relationship resolver" {
  let context = Context::new()
  assert_true(context.resolve_relationship("rId1") == None)
  assert_true(context.sst == None)
  assert_true(context.styles == None)
}
