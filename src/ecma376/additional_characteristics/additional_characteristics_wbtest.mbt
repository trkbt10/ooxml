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

///|
test "read_additional_characteristics parses §22.6.2.1 sample" {
  let xml =
    #|<?xml version="1.0" encoding="UTF-8"?>
    #|<additionalCharacteristics xmlns="http://schemas.openxmlformats.org/officeDocument/2006/characteristics">
    #|  <characteristic name="Years" relation="ge" val="3"/>
    #|  <characteristic name="Title" relation="eq" val="Manager" vocabulary="http://example.com/voc"/>
    #|</additionalCharacteristics>
  let bytes = @utf8.encode(xml[:])
  let root = try! read_additional_characteristics(bytes)
  assert_eq(root.characteristics.length(), 2)
  assert_eq(root.characteristics[0].name, "Years")
  assert_true(root.characteristics[0].relation == Ge)
  assert_eq(root.characteristics[0].val, "3")
  assert_eq(root.characteristics[1].name, "Title")
  assert_true(
    root.characteristics[1].vocabulary == Some("http://example.com/voc"),
  )
}

///|
test "read_additional_characteristics rejects wrong root element" {
  let xml =
    #|<?xml version="1.0" encoding="UTF-8"?>
    #|<wrong xmlns="http://schemas.openxmlformats.org/officeDocument/2006/characteristics"/>
  let bytes = @utf8.encode(xml[:])
  try {
    read_additional_characteristics(bytes) |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
/// §22.6.2.1 — write/read round-trip: build a typed value,
/// serialise it via the new write_additional_characteristics
/// builder, and re-parse it.  The resulting typed value must
/// be observationally identical.
test "write_additional_characteristics round-trips through read_additional_characteristics" {
  let ch = CT_Characteristic::new(
    name="meta:numWords",
    relation=ST_Relation::parse("eq"),
    val="42",
    vocabulary=Some("http://example.com/vocab"),
  )
  let typed = CT_AdditionalCharacteristics::new([ch])
  let bytes = write_additional_characteristics(typed)
  let reparsed = read_additional_characteristics(bytes)
  let chars : Array[CT_Characteristic] = []
  for c in reparsed.iter() {
    chars.push(c)
  }
  assert_eq(chars.length(), 1)
  assert_eq(chars[0].name, "meta:numWords")
  assert_eq(chars[0].val, "42")
  inspect(chars[0].vocabulary, content="Some(http://example.com/vocab)")
  // relation enum survives.
  assert_eq(chars[0].relation.to_string(), "eq")
}
