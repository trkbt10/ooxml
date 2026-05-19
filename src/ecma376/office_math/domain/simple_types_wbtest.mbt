///|
test "OMML integer simple types parse to typed values and enforce bounds" {
  // ST_Integer255 — closed range [1, 255] per §22.1.3.6.
  assert_eq((try! ST_Integer255::parse("255")).to_int(), 255)
  assert_eq((try! ST_Integer255::parse("1")).to_int(), 1)
  assert_eq((try! ST_Integer255::parse("12")).to_string(), "12")
  assert_true((try? ST_Integer255::parse("x")) is Err(SchemaViolation(_)))
  assert_true((try? ST_Integer255::parse("0")) is Err(SchemaViolation(_)))
  assert_true((try? ST_Integer255::parse("256")) is Err(SchemaViolation(_)))
  assert_true((try? ST_Integer255::parse("-1")) is Err(SchemaViolation(_)))

  // ST_Integer2 — closed range [-2, +2] per §22.1.3.5. Leading `+` is a
  // valid xsd:integer lexical form but the canonical to_string drops it.
  assert_eq((try! ST_Integer2::parse("-2")).to_int(), -2)
  assert_eq((try! ST_Integer2::parse("+2")).to_int(), 2)
  assert_eq((try! ST_Integer2::parse("+2")).to_string(), "2")
  assert_eq((try! ST_Integer2::parse("0")).to_string(), "0")
  assert_true((try? ST_Integer2::parse("")) is Err(SchemaViolation(_)))
  assert_true((try? ST_Integer2::parse("3")) is Err(SchemaViolation(_)))
  assert_true((try? ST_Integer2::parse("-3")) is Err(SchemaViolation(_)))

  // ST_SpacingRule — closed range [0, 4] per §22.1.3.11. Note: the
  // spec models this as an xsd:integer, not a string enumeration.
  assert_eq((try! ST_SpacingRule::parse("+1")).to_int(), 1)
  assert_eq((try! ST_SpacingRule::parse("+1")).to_string(), "1")
  assert_eq((try! ST_SpacingRule::parse("0")).to_int(), 0)
  assert_eq((try! ST_SpacingRule::parse("4")).to_int(), 4)
  assert_true((try? ST_SpacingRule::parse("1.5")) is Err(SchemaViolation(_)))
  assert_true((try? ST_SpacingRule::parse("-1")) is Err(SchemaViolation(_)))
  assert_true((try? ST_SpacingRule::parse("5")) is Err(SchemaViolation(_)))

  // ST_UnSignedInteger — xsd:unsignedInt per §22.1.3.14.
  assert_eq((try! ST_UnSignedInteger::parse("42")).to_uint(), 42U)
  assert_eq((try! ST_UnSignedInteger::parse("0")).to_uint(), 0U)
  assert_eq(
    (try! ST_UnSignedInteger::parse("4294967295")).to_uint(),
    4294967295U,
  )
  assert_eq((try! ST_UnSignedInteger::parse("42")).to_string(), "42")
  assert_true((try? ST_UnSignedInteger::parse("-1")) is Err(SchemaViolation(_)))
  assert_true(
    (try? ST_UnSignedInteger::parse("4294967296")) is Err(SchemaViolation(_)),
  )
  assert_true((try? ST_UnSignedInteger::parse("")) is Err(SchemaViolation(_)))

  // ST_Char — xsd:string max length 1 per §22.1.3.3. The character is
  // exposed through a typed `Char` accessor; non-BMP scalars survive
  // the UTF-16 surrogate-pair round-trip.
  assert_eq((try! ST_Char::parse("\u{00af}")).to_char(), '\u{00af}')
  assert_eq((try! ST_Char::parse("{")).to_string(), "{")
  assert_eq((try! ST_Char::parse("\u{1D400}")).to_char(), '\u{1D400}')
  assert_eq((try! ST_Char::parse("\u{1D400}")).to_string(), "\u{1D400}")
  assert_true((try? ST_Char::parse("")) is Err(SchemaViolation(_)))
  assert_true((try? ST_Char::parse("ab")) is Err(SchemaViolation(_)))
}

///|
test "OMML enum simple types parse and reject invalid tokens" {
  assert_true(try! (ST_Shp::parse("centered") == Centered))
  assert_true((try? ST_Shp::parse("left")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_FType::parse("noBar")).to_string(), "noBar")
  assert_true((try? ST_FType::parse("solid")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_LimLoc::parse("undOvr")).to_string(), "undOvr")
  assert_true((try? ST_LimLoc::parse("over")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_TopBot::parse("bot")).to_string(), "bot")
  assert_true((try? ST_TopBot::parse("bottom")) is Err(SchemaViolation(_)))
  assert_eq(
    (try! ST_Script::parse("double-struck")).to_string(),
    "double-struck",
  )
  assert_true((try? ST_Script::parse("serif")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_Style::parse("bi")).to_string(), "bi")
  assert_true((try? ST_Style::parse("bold")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_Jc::parse("centerGroup")).to_string(), "centerGroup")
  assert_true((try? ST_Jc::parse("justify")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_BreakBin::parse("repeat")).to_string(), "repeat")
  assert_true((try? ST_BreakBin::parse("none")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_BreakBinSub::parse("+-")).to_string(), "+-")
  assert_true((try? ST_BreakBinSub::parse("++")) is Err(SchemaViolation(_)))
}
