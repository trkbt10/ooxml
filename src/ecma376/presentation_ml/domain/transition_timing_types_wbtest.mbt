///|
fn pml_test_element(source : String) -> @xml.Element {
  try! @xml.parse(@utf8.encode(source[:])).root
}

///|
test "§19.5 anim variant wrappers reject missing required val" {
  let bool_result = try? CT_TLAnimVariantBooleanVal::new(
    pml_test_element("<p:boolVal xmlns:p=\"urn:p\"/>"),
  )
  assert_true(bool_result is Err(SchemaViolation(_)))
  let int_result = try? CT_TLAnimVariantIntegerVal::new(
    pml_test_element("<p:intVal xmlns:p=\"urn:p\"/>"),
  )
  assert_true(int_result is Err(SchemaViolation(_)))
  let float_result = try? CT_TLAnimVariantFloatVal::new(
    pml_test_element("<p:fltVal xmlns:p=\"urn:p\"/>"),
  )
  assert_true(float_result is Err(SchemaViolation(_)))
  let string_result = try? CT_TLAnimVariantStringVal::new(
    pml_test_element("<p:strVal xmlns:p=\"urn:p\"/>"),
  )
  assert_true(string_result is Err(SchemaViolation(_)))
}

///|
test "§19.5 anim variant wrappers reject malformed typed val" {
  let bool_result = try? CT_TLAnimVariantBooleanVal::new(
    pml_test_element("<p:boolVal xmlns:p=\"urn:p\" val=\"maybe\"/>"),
  )
  assert_true(bool_result is Err(SchemaViolation(_)))
  let int_result = try? CT_TLAnimVariantIntegerVal::new(
    pml_test_element("<p:intVal xmlns:p=\"urn:p\" val=\"NaN\"/>"),
  )
  assert_true(int_result is Err(SchemaViolation(_)))
  let float_result = try? CT_TLAnimVariantFloatVal::new(
    pml_test_element("<p:fltVal xmlns:p=\"urn:p\" val=\"not-a-float\"/>"),
  )
  assert_true(float_result is Err(SchemaViolation(_)))
}
