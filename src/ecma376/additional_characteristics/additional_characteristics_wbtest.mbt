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

///|
test "CT_Characteristic captures required attributes" {
  let c = try! CT_Characteristic::new(
    name="Years",
    relation=Eq,
    val="3",
    vocabulary=Some("http://example.com/voc"),
  )
  assert_eq(c.name, "Years")
  assert_eq(c.val, "3")
  assert_true(c.relation == Eq)
  assert_true(c.vocabulary == Some("http://example.com/voc"))
}

///|
test "CT_Characteristic rejects missing name or val" {
  try {
    CT_Characteristic::new(name="", relation=Eq, val="x") |> ignore
    fail("expected name violation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
  try {
    CT_Characteristic::new(name="n", relation=Eq, val="") |> ignore
    fail("expected val violation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "CT_AdditionalCharacteristics preserves child order" {
  let a = try! CT_Characteristic::new(name="A", relation=Eq, val="1")
  let b = try! CT_Characteristic::new(name="B", relation=Lt, val="2")
  let root = CT_AdditionalCharacteristics::new([a, b])
  let collected : Array[String] = []
  for child in root.iter() {
    collected.push(child.name)
  }
  assert_eq(collected.length(), 2)
  assert_eq(collected[0], "A")
  assert_eq(collected[1], "B")
}
