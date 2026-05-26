// §17.18.69 ST_OnOff parser tests.

///|
test "parse_xsd_on_off accepts all 6 spec-permitted lexical forms" {
  @debug.debug_inspect(parse_xsd_on_off(Some("1")), content="Some(true)")
  @debug.debug_inspect(parse_xsd_on_off(Some("true")), content="Some(true)")
  @debug.debug_inspect(parse_xsd_on_off(Some("on")), content="Some(true)")
  @debug.debug_inspect(parse_xsd_on_off(Some("0")), content="Some(false)")
  @debug.debug_inspect(parse_xsd_on_off(Some("false")), content="Some(false)")
  @debug.debug_inspect(parse_xsd_on_off(Some("off")), content="Some(false)")
}

///|
test "parse_xsd_on_off returns None for absent or schema-violating values" {
  @debug.debug_inspect(parse_xsd_on_off(None), content="None")
  @debug.debug_inspect(parse_xsd_on_off(Some("")), content="None")
  @debug.debug_inspect(parse_xsd_on_off(Some("yes")), content="None") // not in ST_OnOff
  @debug.debug_inspect(parse_xsd_on_off(Some("TRUE")), content="None") // case-sensitive
  @debug.debug_inspect(parse_xsd_on_off(Some("garbage")), content="None")
}

///|
test "parse_xsd_on_off_or returns default for absent / violation" {
  // §17.3 toggle semantics: absent element → false; element present
  // but @val invalid → default to true so the property survives.
  assert_eq(parse_xsd_on_off_or(None, true), true)
  assert_eq(parse_xsd_on_off_or(None, false), false)
  assert_eq(parse_xsd_on_off_or(Some("xyz"), true), true)
  assert_eq(parse_xsd_on_off_or(Some("xyz"), false), false)
  // Spec-permitted values override the default.
  assert_eq(parse_xsd_on_off_or(Some("0"), true), false)
  assert_eq(parse_xsd_on_off_or(Some("on"), false), true)
}
