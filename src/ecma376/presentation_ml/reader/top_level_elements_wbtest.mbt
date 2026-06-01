///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn minimal_slide_bytes() -> Bytes {
  bytes(
    "<p:sld xmlns:p=\"urn:p\">" +
    "<p:cSld>" +
    "<p:spTree>" +
    "<p:nvGrpSpPr>" +
    "<p:cNvPr/>" +
    "<p:cNvGrpSpPr/>" +
    "<p:nvPr/>" +
    "</p:nvGrpSpPr>" +
    "<p:grpSpPr/>" +
    "</p:spTree>" +
    "</p:cSld>" +
    "</p:sld>",
  )
}

///|
test "PML slide reader round trips a valid minimal slide" {
  let slide = read_sld(minimal_slide_bytes())
  assert_eq(read_sld(@builder.write_sld(slide)).element.name.local_name, "sld")
}

///|
test "PML slide reader rejects slides without required cSld" {
  let result = try? read_sld(bytes("<p:sld xmlns:p=\"urn:p\"/>"))
  assert_true(result is Err(@domain.SchemaViolation(_)))
}

///|
test "PML slide reader rejects common slide data without required spTree" {
  let result = try? read_sld(
    bytes("<p:sld xmlns:p=\"urn:p\"><p:cSld/></p:sld>"),
  )
  assert_true(result is Err(@domain.SchemaViolation(_)))
}
