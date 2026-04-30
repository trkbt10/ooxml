///|
test "chart simple type parse and format" {
  assert_eq(ST_LayoutTarget::parse("inner").to_string(), "inner")
  assert_eq(ST_BarDir::parse("col").to_string(), "col")
  assert_true((try? ST_BarDir::parse("sideways")) is Err(SchemaViolation(_)))
  assert_eq(ST_RotX::parse("45").to_string(), "45")
  assert_true((try? ST_RotX::parse("north")) is Err(SchemaViolation(_)))
}
