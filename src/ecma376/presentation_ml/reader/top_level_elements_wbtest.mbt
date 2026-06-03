///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn common_slide_data_xml() -> String {
  "<p:cSld>" +
  "<p:spTree>" +
  "<p:nvGrpSpPr>" +
  "<p:cNvPr/>" +
  "<p:cNvGrpSpPr/>" +
  "<p:nvPr/>" +
  "</p:nvGrpSpPr>" +
  "<p:grpSpPr/>" +
  "</p:spTree>" +
  "</p:cSld>"
}

///|
fn minimal_slide_bytes() -> Bytes {
  bytes("<p:sld xmlns:p=\"urn:p\">" + common_slide_data_xml() + "</p:sld>")
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

///|
test "PML slide reader rejects malformed transition booleans" {
  let result = try? read_sld(
    bytes(
      "<p:sld xmlns:p=\"urn:p\">" +
      common_slide_data_xml() +
      "<p:transition><p:cut thruBlk=\"maybe\"/></p:transition>" +
      "</p:sld>",
    ),
  )
  assert_true(result is Err(@domain.SchemaViolation(_)))
}

///|
test "PML layout and master readers reject malformed transition booleans" {
  let layout = try? read_sld_layout(
    bytes(
      "<p:sldLayout xmlns:p=\"urn:p\">" +
      common_slide_data_xml() +
      "<p:transition><p:fade thruBlk=\"maybe\"/></p:transition>" +
      "</p:sldLayout>",
    ),
  )
  assert_true(layout is Err(@domain.SchemaViolation(_)))
  let master = try? read_sld_master(
    bytes(
      "<p:sldMaster xmlns:p=\"urn:p\">" +
      common_slide_data_xml() +
      "<p:clrMap/>" +
      "<p:transition><p:cut thruBlk=\"maybe\"/></p:transition>" +
      "</p:sldMaster>",
    ),
  )
  assert_true(master is Err(@domain.SchemaViolation(_)))
}
