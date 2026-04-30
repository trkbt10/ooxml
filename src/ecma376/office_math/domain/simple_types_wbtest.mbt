///|
test "OMML integer simple types parse and reject invalid tokens" {
  assert_eq((try! ST_Integer255::parse("255")).to_string(), "255")
  assert_true((try? ST_Integer255::parse("x")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_Integer2::parse("-2")).to_string(), "-2")
  assert_true((try? ST_Integer2::parse("")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_SpacingRule::parse("+1")).to_string(), "+1")
  assert_true((try? ST_SpacingRule::parse("1.5")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_UnSignedInteger::parse("42")).to_string(), "42")
  assert_true((try? ST_UnSignedInteger::parse("-1")) is Err(SchemaViolation(_)))
  assert_eq((try! ST_Char::parse("\u{00af}")).to_string(), "\u{00af}")
  assert_true((try? ST_Char::parse("")) is Err(SchemaViolation(_)))
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
