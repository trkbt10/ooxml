///|
test "part name rejects ECMA-376 Part 2 6.2.2.2 malformed percent encoding" {
  assert_true(
    (try? PartName::parse("/foo%ZZ"))
    is Err(
      @opc_errors.SchemaViolation(
        section="6.2.2.2",
        path="PartName",
        reason="malformed percent-encoding"
      )
    ),
  )
}

///|
test "part name rejects ECMA-376 Part 2 6.2.2.2 percent encoded slash" {
  assert_true(
    (try? PartName::parse("/foo%2Fbar"))
    is Err(
      @opc_errors.SchemaViolation(
        section="6.2.2.2",
        path="PartName",
        reason="percent-encoded forbidden character"
      )
    ),
  )
}

///|
test "part name rejects ECMA-376 Part 2 6.2.2.2 segment ending dot" {
  assert_true(
    (try? PartName::parse("/foo."))
    is Err(
      @opc_errors.SchemaViolation(
        section="6.2.2.2",
        path="PartName",
        reason="part name segment must not end with ."
      )
    ),
  )
}

///|
test "part name rejects ECMA-376 Part 2 6.5.2.3 reserved relationship part names" {
  assert_true(
    (try? PartName::parse("/_rels/foo.rels"))
    is Err(
      @opc_errors.SchemaViolation(section="6.5.2.3", path="PartName", reason=_)
    ),
  )
  assert_true(
    (try? PartName::parse("/path/_rels/sheet.xml.rels"))
    is Err(
      @opc_errors.SchemaViolation(section="6.5.2.3", path="PartName", reason=_)
    ),
  )
}

///|
test "trusted OPC constructor accepts ECMA-376 Part 2 6.5.2.2 package relationships part" {
  let part = try! PartName::__from_trusted("/_rels/.rels")
  assert_eq(part.to_string(), "/_rels/.rels")
  assert_true(!part.is_user_creatable())
}

///|
test "relationship targets normalize through canonical part name logic" {
  assert_eq(
    try! resolve_target("/xl/workbook.xml", "worksheets/../sharedStrings.xml"),
    "/xl/sharedStrings.xml",
  )
  assert_eq(try! normalize_part_name("/xl/./styles.xml"), "/xl/styles.xml")
}
