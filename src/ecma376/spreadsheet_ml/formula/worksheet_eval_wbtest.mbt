///|
fn worksheet_eval_test_bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn worksheet_eval_test_cell(source : String) -> @domain.CT_Cell {
  @domain.CT_Cell::new(try! @xml.parse(worksheet_eval_test_bytes(source)).root)
}

///|
fn worksheet_eval_test_sst(source : String) -> @domain.CT_Sst {
  @domain.CT_Sst::new(try! @xml.parse(worksheet_eval_test_bytes(source)).root)
}

///|
fn worksheet_eval_test_worksheet(source : String) -> @domain.CT_Worksheet {
  try! @domain.CT_Worksheet::new(
    try! @xml.parse(worksheet_eval_test_bytes(source)).root,
  )
}

///|
fn worksheet_eval_test_addr(source : String) -> @address.CellAddress {
  try! @address.CellAddress::parse_a1(source)
}

///|
fn worksheet_eval_test_snapshot() -> WorksheetSnapshot {
  WorksheetSnapshot::new("Sheet1", @date_serial.DateSystem::Serial1900)
}

///|
fn worksheet_eval_test_with_cell(
  snapshot : WorksheetSnapshot,
  address : String,
  cell_xml : String,
) -> WorksheetSnapshot {
  snapshot.with_cell(
    worksheet_eval_test_addr(address),
    worksheet_eval_test_cell(cell_xml),
  )
}

///|
fn worksheet_eval_test_eval(
  snapshot : WorksheetSnapshot,
  address : String,
) -> FormulaValue {
  evaluate_cell(snapshot, worksheet_eval_test_addr(address))
}

///|
fn worksheet_eval_test_serial(year : Int, month : Int, day : Int) -> Double {
  try! @date_serial.date_time_to_serial(
    { year, month, day, hour: 0, minute: 0, second: 0, millisecond: 0 },
    @date_serial.DateSystem::Serial1900,
  )
}

///|
test "§18.3 / §18.17 worksheet eval decodes literal numeric cell" {
  let snapshot = worksheet_eval_test_with_cell(
    worksheet_eval_test_snapshot(),
    "A1",
    (
      #|<c r="A1" t="n"><v>42</v></c>
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "A1") == VNumber(42.0))
}

///|
test "§18.3 / §18.17 worksheet eval sums a worksheet range" {
  let snapshot = worksheet_eval_test_snapshot().with_worksheet(
    worksheet_eval_test_worksheet(
      (
        #|<worksheet><sheetData><row r="1">
        #|  <c r="A1"><v>1</v></c>
        #|  <c r="B1"><f>SUM(A1:A3)</f></c>
        #|</row><row r="2">
        #|  <c r="A2"><v>2</v></c>
        #|</row><row r="3">
        #|  <c r="A3"><v>3</v></c>
        #|</row></sheetData></worksheet>
      ),
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "B1") == VNumber(6.0))
}

///|
test "§18.3 / §18.17 worksheet eval resolves shared strings" {
  let sst = worksheet_eval_test_sst(
    (
      #|<sst><si><t>hello</t></si></sst>
    ),
  )
  let snapshot = worksheet_eval_test_with_cell(
    worksheet_eval_test_snapshot().with_sst(sst),
    "C1",
    (
      #|<c r="C1" t="s"><v>0</v></c>
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "C1") == VString("hello"))
}

///|
test "§18.3 / §18.17 worksheet eval resolves cross-cell arithmetic" {
  let snapshot = worksheet_eval_test_snapshot().with_worksheet(
    worksheet_eval_test_worksheet(
      (
        #|<worksheet><sheetData><row r="1">
        #|  <c r="A1"><v>2</v></c>
        #|  <c r="B1"><v>3</v></c>
        #|  <c r="C1"><f>A1*B1</f></c>
        #|</row></sheetData></worksheet>
      ),
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "C1") == VNumber(6.0))
}

///|
test "§18.3 / §18.17 worksheet eval follows a formula chain" {
  let snapshot = worksheet_eval_test_snapshot().with_worksheet(
    worksheet_eval_test_worksheet(
      (
        #|<worksheet><sheetData>
        #|  <row r="1"><c r="A1"><v>1</v></c></row>
        #|  <row r="2"><c r="A2"><f>A1+1</f></c></row>
        #|  <row r="3"><c r="A3"><f>A2+1</f></c></row>
        #|  <row r="4"><c r="A4"><f>A3+1</f></c></row>
        #|  <row r="5"><c r="A5"><f>A4+1</f></c></row>
        #|</sheetData></worksheet>
      ),
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "A5") == VNumber(5.0))
}

///|
test "§18.3 / §18.17 worksheet eval runs conditional formulas" {
  let snapshot = worksheet_eval_test_snapshot().with_worksheet(
    worksheet_eval_test_worksheet(
      (
        #|<worksheet><sheetData><row r="1">
        #|  <c r="A1"><v>10</v></c>
        #|  <c r="B1"><f>IF(A1&gt;5,"big","small")</f></c>
        #|</row></sheetData></worksheet>
      ),
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "B1") == VString("big"))
}

///|
test "§18.3 / §18.17 worksheet eval runs lookup formulas" {
  let snapshot = worksheet_eval_test_snapshot().with_worksheet(
    worksheet_eval_test_worksheet(
      (
        #|<worksheet><sheetData>
        #|  <row r="1"><c r="A1" t="str"><v>x</v></c><c r="B1"><v>1</v></c><c r="C1"><f>VLOOKUP("y",A1:B3,2,FALSE)</f></c></row>
        #|  <row r="2"><c r="A2" t="str"><v>y</v></c><c r="B2"><v>2</v></c></row>
        #|  <row r="3"><c r="A3" t="str"><v>z</v></c><c r="B3"><v>3</v></c></row>
        #|</sheetData></worksheet>
      ),
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "C1") == VNumber(2.0))
}

///|
test "§18.3 / §18.17 worksheet eval uses workbook date system" {
  let snapshot = worksheet_eval_test_with_cell(
    worksheet_eval_test_snapshot(),
    "A1",
    (
      #|<c r="A1"><f>DATE(2024,12,31)</f></c>
    ),
  )
  assert_true(
    worksheet_eval_test_eval(snapshot, "A1") ==
    VNumber(worksheet_eval_test_serial(2024, 12, 31)),
  )
}

///|
test "§18.3 / §18.17 worksheet eval expands shared formulas" {
  let snapshot = worksheet_eval_test_snapshot().with_worksheet(
    worksheet_eval_test_worksheet(
      (
        #|<worksheet><sheetData>
        #|  <row r="1"><c r="A1"><f t="shared" si="0" ref="A1:A3">B1+1</f></c><c r="B1"><v>10</v></c></row>
        #|  <row r="2"><c r="A2"><f t="shared" si="0"/></c><c r="B2"><v>20</v></c></row>
        #|  <row r="3"><c r="A3"><f t="shared" si="0"/></c><c r="B3"><v>30</v></c></row>
        #|</sheetData></worksheet>
      ),
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "A1") == VNumber(11.0))
  assert_true(worksheet_eval_test_eval(snapshot, "A2") == VNumber(21.0))
  assert_true(worksheet_eval_test_eval(snapshot, "A3") == VNumber(31.0))
}

///|
test "§18.3 / §18.17 worksheet eval detects cycles as Ref errors" {
  let snapshot = worksheet_eval_test_snapshot().with_worksheet(
    worksheet_eval_test_worksheet(
      (
        #|<worksheet><sheetData><row r="1">
        #|  <c r="A1"><f>B1</f></c>
        #|  <c r="B1"><f>A1</f></c>
        #|</row></sheetData></worksheet>
      ),
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "A1") == VError(Ref))
  assert_true(worksheet_eval_test_eval(snapshot, "B1") == VError(Ref))
}

///|
test "§18.3 / §18.17 worksheet eval treats missing cells as empty" {
  let snapshot = worksheet_eval_test_with_cell(
    worksheet_eval_test_snapshot(),
    "B1",
    (
      #|<c r="B1"><f>A1+1</f></c>
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "B1") == VNumber(1.0))
}

///|
test "§18.3 / §18.17 worksheet eval propagates errors" {
  let snapshot = worksheet_eval_test_snapshot().with_worksheet(
    worksheet_eval_test_worksheet(
      (
        #|<worksheet><sheetData><row r="1">
        #|  <c r="A1"><f>1/0</f></c>
        #|  <c r="B1"><f>A1+5</f></c>
        #|</row></sheetData></worksheet>
      ),
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "A1") == VError(DivZero))
  assert_true(worksheet_eval_test_eval(snapshot, "B1") == VError(DivZero))
}

///|
test "§18.3 / §18.17 evaluate_sheet returns all formula cells" {
  let snapshot = worksheet_eval_test_snapshot().with_worksheet(
    worksheet_eval_test_worksheet(
      (
        #|<worksheet><sheetData><row r="1">
        #|  <c r="A1"><v>2</v></c>
        #|  <c r="B1"><f>A1+3</f></c>
        #|  <c r="C1"><f>SUM(A1:B1)</f></c>
        #|</row></sheetData></worksheet>
      ),
    ),
  )
  let results = evaluate_sheet(snapshot)
  assert_true(results.get("B1") == Some(VNumber(5.0)))
  assert_true(results.get("C1") == Some(VNumber(7.0)))
}

///|
test "§18.3 / §18.17 worksheet eval handles composite real-world formula" {
  let snapshot = worksheet_eval_test_snapshot().with_worksheet(
    worksheet_eval_test_worksheet(
      (
        #|<worksheet><sheetData>
        #|  <row r="1"><c r="A1"><v>1</v></c><c r="B1"><v>2</v></c><c r="X1" t="str"><v>bar</v></c><c r="Y1"><v>10</v></c><c r="Z1"><f>SUM(A1:A10)+B1*VLOOKUP("foo",X1:Y20,2,FALSE)</f></c></row>
        #|  <row r="2"><c r="A2"><v>2</v></c><c r="X2" t="str"><v>foo</v></c><c r="Y2"><v>5</v></c></row>
        #|  <row r="3"><c r="A3"><v>3</v></c></row>
        #|  <row r="4"><c r="A4"><v>4</v></c></row>
        #|  <row r="5"><c r="A5"><v>5</v></c></row>
        #|  <row r="6"><c r="A6"><v>6</v></c></row>
        #|  <row r="7"><c r="A7"><v>7</v></c></row>
        #|  <row r="8"><c r="A8"><v>8</v></c></row>
        #|  <row r="9"><c r="A9"><v>9</v></c></row>
        #|  <row r="10"><c r="A10"><v>10</v></c></row>
        #|</sheetData></worksheet>
      ),
    ),
  )
  assert_true(worksheet_eval_test_eval(snapshot, "Z1") == VNumber(65.0))
}
