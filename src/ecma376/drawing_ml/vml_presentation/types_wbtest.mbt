///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn parse_element(source : String) -> @xml.Element raise {
  @xml.parse(bytes(source)).root
}

///|
test "CT_Empty accepts empty pvml:iscomment" {
  let element = parse_element(
    "<pvml:iscomment xmlns:pvml=\"urn:schemas-microsoft-com:office:powerpoint\"/>",
  )
  let value = CT_Empty::new(element)
  assert_eq(value.to_element().name.local_name, "iscomment")
}

///|
test "CT_Empty rejects attributes" {
  let element = parse_element(
    "<pvml:iscomment xmlns:pvml=\"urn:schemas-microsoft-com:office:powerpoint\" foo=\"bar\"/>",
  )
  try {
    CT_Empty::new(element) |> ignore
    fail("expected SchemaViolation for attribute on CT_Empty")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "CT_Empty rejects element children" {
  let element = parse_element(
    "<pvml:iscomment xmlns:pvml=\"urn:schemas-microsoft-com:office:powerpoint\"><pvml:nested/></pvml:iscomment>",
  )
  try {
    CT_Empty::new(element) |> ignore
    fail("expected SchemaViolation for child element on CT_Empty")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "CT_Rel accepts optional @id only" {
  let with_id = parse_element(
    "<pvml:textdata xmlns:pvml=\"urn:schemas-microsoft-com:office:powerpoint\" id=\"rId1\"/>",
  )
  let value = CT_Rel::new(with_id)
  match value.id {
    Some(id) => assert_eq(id, "rId1")
    None => fail("expected id to be Some")
  }
}

///|
test "CT_Rel rejects foreign attributes" {
  let element = parse_element(
    "<pvml:textdata xmlns:pvml=\"urn:schemas-microsoft-com:office:powerpoint\" foo=\"bar\"/>",
  )
  try {
    CT_Rel::new(element) |> ignore
    fail("expected SchemaViolation for foreign attribute on CT_Rel")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "CT_Rel rejects element children" {
  let element = parse_element(
    "<pvml:textdata xmlns:pvml=\"urn:schemas-microsoft-com:office:powerpoint\"><pvml:nested/></pvml:textdata>",
  )
  try {
    CT_Rel::new(element) |> ignore
    fail("expected SchemaViolation for child element on CT_Rel")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
