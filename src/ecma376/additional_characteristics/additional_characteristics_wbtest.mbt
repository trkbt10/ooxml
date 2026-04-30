///|
test "ST_Relation parses schema enumerations" {
  assert_true(ST_Relation::parse("ge") == Ge)
  assert_true(ST_Relation::parse("le") == Le)
  assert_true(ST_Relation::parse("gt") == Gt)
  assert_true(ST_Relation::parse("lt") == Lt)
  assert_true(ST_Relation::parse("eq") == Eq)
  assert_eq(ST_Relation::parse("eq").to_string(), "eq")
}

///|
test "ST_Relation rejects values outside the schema enumeration" {
  try {
    ST_Relation::parse("noteq") |> ignore
    fail("expected ST_Relation rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
