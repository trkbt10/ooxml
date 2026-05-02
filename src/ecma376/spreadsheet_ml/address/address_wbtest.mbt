///|
test "ST_CellRef A1 absolute markers parse and round trip" {
  let a1 = try! CellAddress::parse_a1("A1")
  assert_eq(a1.col_zero_based, 0)
  assert_eq(a1.row_zero_based, 0)
  assert_eq(a1.to_a1(), "A1")
  assert_eq((try! CellAddress::parse_a1("$A$1")).to_a1(), "$A$1")
  assert_eq((try! CellAddress::parse_a1("A$1")).to_a1(), "A$1")
  assert_eq((try! CellAddress::parse_a1("$A1")).to_a1(), "$A1")
}

///|
test "ST_CellRef A1 sheet qualifiers parse and quote" {
  assert_eq((try! CellAddress::parse_a1("Sheet1!A1")).to_a1(), "Sheet1!A1")
  let quoted = try! CellAddress::parse_a1("'Bob''s sheet'!A1")
  assert_true(quoted.sheet == Some("Bob's sheet"))
  assert_eq(quoted.to_a1(), "'Bob''s sheet'!A1")
}

///|
test "ST_CellRef A1 column and row limits normalize lowercase" {
  assert_eq((try! CellAddress::parse_a1("aa1")).to_a1(), "AA1")
  assert_eq((try! CellAddress::parse_a1("XFD1048576")).to_a1(), "XFD1048576")
  assert_true(
    (try? CellAddress::parse_a1("XFE1")) is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? CellAddress::parse_a1("A1048577"))
    is Err(@opc_errors.SchemaViolation(_)),
  )
}

///|
test "ST_Ref parses cell row and column ranges" {
  assert_eq((try! CellRange::parse_a1("A1:B10")).to_a1(), "A1:B10")
  assert_eq((try! CellRange::parse_a1("1:5")).to_a1(), "1:5")
  assert_eq((try! CellRange::parse_a1("A:C")).to_a1(), "A:C")
}

///|
test "ST_Ref normalizes reversed ranges" {
  assert_eq((try! CellRange::parse_a1("B10:A1")).to_a1(), "A1:B10")
  assert_eq((try! CellRange::parse_a1("5:1")).to_a1(), "1:5")
  assert_eq((try! CellRange::parse_a1("C:A")).to_a1(), "A:C")
}

///|
test "ST_Sqref splits on ASCII spaces and formats references" {
  let sqref = try! Sqref::parse_a1("A1 B2 C3:D4")
  assert_eq(sqref.ranges.length(), 3)
  assert_eq(sqref.to_a1(), "A1 B2 C3:D4")
}

///|
test "ST_CellRef R1C1 absolute and relative forms parse and round trip" {
  assert_eq((try! CellAddress::parse_r1c1("R1C1")).to_r1c1(), "R1C1")
  assert_eq((try! CellAddress::parse_r1c1("R[1]C")).to_r1c1(), "R[1]C")
  assert_eq((try! CellAddress::parse_r1c1("RC[-2]")).to_r1c1(), "RC[-2]")
  assert_eq((try! CellAddress::parse_r1c1("R5C5")).to_r1c1(), "R5C5")
}

///|
test "ST_CellRef round trip parse format parse equality" {
  let first = try! CellAddress::parse_a1("'Bob''s sheet'!$AA$10")
  let second = try! CellAddress::parse_a1(first.to_a1())
  assert_true(first == second)
  let r1c1 = try! CellAddress::parse_r1c1("R[-1]C[2]")
  assert_true((try! CellAddress::parse_r1c1(r1c1.to_r1c1())) == r1c1)
}

///|
test "ST_Ref rejects malformed absolute markers and mixed range shapes" {
  assert_true(
    (try? CellAddress::parse_a1("$1")) is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? CellAddress::parse_a1("A$$1")) is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? CellRange::parse_a1("A1:5")) is Err(@opc_errors.SchemaViolation(_)),
  )
}

///|
test "ST_CellRef supports external workbook sheet qualifier text" {
  let cell = try! CellAddress::parse_a1("[Book.xlsx]Sheet1!C3")
  assert_true(cell.sheet == Some("[Book.xlsx]Sheet1"))
  assert_eq(cell.to_a1(), "[Book.xlsx]Sheet1!C3")
}

///|
test "ST_CellRef column helper maps boundary letters" {
  assert_eq(try! column_letter_to_index("A"), 0)
  assert_eq(try! column_letter_to_index("Z"), 25)
  assert_eq(try! column_letter_to_index("AA"), 26)
  assert_eq(try! column_index_to_letter(16383), "XFD")
}

///|
test "ST_Sqref rejects empty tokens from repeated spaces" {
  assert_true(
    (try? Sqref::parse_a1("A1  B2")) is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true((try? Sqref::parse_a1("")) is Err(@opc_errors.SchemaViolation(_)))
}
