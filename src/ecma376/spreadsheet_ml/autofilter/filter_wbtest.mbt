///|
fn n(value : Double) -> @formula.FormulaValue {
  @formula.FormulaValue::VNumber(value)
}

///|
fn s(value : String) -> @formula.FormulaValue {
  @formula.FormulaValue::VString(value)
}

///|
fn row(index : Int, values : Array[@formula.FormulaValue]) -> CandidateRow {
  { values, row_index: index }
}

///|
fn system() -> @date_serial.DateSystem {
  @date_serial.DateSystem::Serial1900
}

///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "§18.3.2 filters literal keeps exact text" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A3"),
    columns: [
      {
        column_id: 0,
        hidden_button: false,
        rule: Filters([Literal("foo")], false),
      },
    ],
  }
  assert_true(filter.row_visible(row(0, [s("foo")]), system()))
  assert_true(!filter.row_visible(row(1, [s("bar")]), system()))
}

///|
test "§18.3.2 filters blank_included keeps empty cells" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A3"),
    columns: [
      {
        column_id: 0,
        hidden_button: false,
        rule: Filters([Literal("foo")], true),
      },
    ],
  }
  assert_true(
    filter.row_visible(row(0, [@formula.FormulaValue::VEmpty]), system()),
  )
  assert_true(filter.row_visible(row(1, [s("")]), system()))
  assert_true(!filter.row_visible(row(2, [s("bar")]), system()))
}

///|
test "§18.3.2 dateGroupItem year level" {
  let serial = try! @date_serial.date_time_to_serial(
    {
      year: 2006,
      month: 5,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    },
    system(),
  )
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A3"),
    columns: [
      {
        column_id: 0,
        hidden_button: false,
        rule: Filters(
          [
            DateGroup({
              year: 2006,
              month: None,
              day: None,
              hour: None,
              minute: None,
              second: None,
              group_by: Year,
            }),
          ],
          false,
        ),
      },
    ],
  }
  assert_true(filter.row_visible(row(0, [n(serial)]), system()))
  assert_true(!filter.row_visible(row(1, [n(0.0)]), system()))
}

///|
test "§18.3.2 customFilters numeric AND range" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A12"),
    columns: [
      {
        column_id: 0,
        hidden_button: false,
        rule: CustomFilters(
          [
            { operator: GreaterThan, value: "5" },
            { operator: LessThan, value: "10" },
          ],
          true,
        ),
      },
    ],
  }
  let rows = [
    row(0, [n(5.0)]),
    row(1, [n(6.0)]),
    row(2, [n(9.0)]),
    row(3, [n(10.0)]),
  ]
  assert_eq(filter.filter_rows(rows, system()), [1, 2])
}

///|
test "§18.3.2 customFilters star wildcard" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A3"),
    columns: [
      {
        column_id: 0,
        hidden_button: false,
        rule: CustomFilters([{ operator: Equal, value: "*foo*" }], false),
      },
    ],
  }
  assert_true(filter.row_visible(row(0, [s("before foo after")]), system()))
  assert_true(!filter.row_visible(row(1, [s("bar")]), system()))
}

///|
test "§18.3.2 customFilters question wildcard" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A3"),
    columns: [
      {
        column_id: 0,
        hidden_button: false,
        rule: CustomFilters([{ operator: Equal, value: "?bar" }], false),
      },
    ],
  }
  assert_true(filter.row_visible(row(0, [s("xbar")]), system()))
  assert_true(!filter.row_visible(row(1, [s("xxbar")]), system()))
}

///|
test "§18.3.2 dynamicFilter today uses deterministic serial-zero anchor" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A3"),
    columns: [
      {
        column_id: 0,
        hidden_button: false,
        rule: DynamicFilter(Today, None, None),
      },
    ],
  }
  assert_true(filter.row_visible(row(0, [n(0.25)]), system()))
  assert_true(!filter.row_visible(row(1, [n(1.25)]), system()))
}

///|
test "§18.3.2 dynamicFilter aboveAverage uses full row set" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A4"),
    columns: [
      {
        column_id: 0,
        hidden_button: false,
        rule: DynamicFilter(AboveAverage, None, None),
      },
    ],
  }
  let rows = [
    row(0, [n(1.0)]),
    row(1, [n(2.0)]),
    row(2, [n(8.0)]),
    row(3, [n(9.0)]),
  ]
  assert_eq(filter.filter_rows(rows, system()), [2, 3])
}

///|
test "§18.3.2 colorFilter stub is false without style tags" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A1"),
    columns: [
      { column_id: 0, hidden_button: false, rule: ColorFilter(1, true) },
    ],
  }
  assert_true(!filter.row_visible(row(0, [s("foo")]), system()))
}

///|
test "§18.3.2 top10 top three numeric values" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A5"),
    columns: [
      { column_id: 0, hidden_button: false, rule: Top10(true, false, 3.0) },
    ],
  }
  let rows = [
    row(0, [n(1.0)]),
    row(1, [n(9.0)]),
    row(2, [n(4.0)]),
    row(3, [n(7.0)]),
    row(4, [n(3.0)]),
  ]
  assert_eq(filter.filter_rows(rows, system()), [1, 2, 3])
}

///|
test "§18.3.2 top10 bottom twenty-five percent" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A8"),
    columns: [
      { column_id: 0, hidden_button: false, rule: Top10(false, true, 25.0) },
    ],
  }
  let rows = [
    row(0, [n(8.0)]),
    row(1, [n(7.0)]),
    row(2, [n(6.0)]),
    row(3, [n(5.0)]),
    row(4, [n(4.0)]),
    row(5, [n(3.0)]),
    row(6, [n(2.0)]),
    row(7, [n(1.0)]),
  ]
  assert_eq(filter.filter_rows(rows, system()), [6, 7])
}

///|
test "§18.3.2 multi-column filters intersect" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:B4"),
    columns: [
      {
        column_id: 0,
        hidden_button: false,
        rule: Filters([Literal("foo")], false),
      },
      {
        column_id: 1,
        hidden_button: false,
        rule: CustomFilters([{ operator: GreaterThan, value: "5" }], false),
      },
    ],
  }
  let rows = [
    row(0, [s("foo"), n(6.0)]),
    row(1, [s("foo"), n(4.0)]),
    row(2, [s("bar"), n(9.0)]),
  ]
  assert_eq(filter.filter_rows(rows, system()), [0])
}

///|
test "§18.3.2 from_element parses XML fragment" {
  let document = try! @xml.parse(
    bytes(
      "<autoFilter ref=\"A1:B3\"><filterColumn colId=\"1\" hiddenButton=\"1\"><customFilters and=\"1\"><customFilter operator=\"greaterThanOrEqual\" val=\"5\"/><customFilter operator=\"lessThan\" val=\"10\"/></customFilters></filterColumn></autoFilter>",
    ),
  )
  let filter = try! AutoFilter::from_element(document.root)
  assert_eq(filter.range.to_a1(), "A1:B3")
  assert_eq(filter.columns.length(), 1)
  assert_eq(filter.columns[0].column_id, 1)
  assert_true(filter.columns[0].hidden_button)
  assert_eq(
    filter.filter_rows(
      [row(0, [s("x"), n(5.0)]), row(1, [s("x"), n(10.0)])],
      system(),
    ),
    [0],
  )
}

///|
test "§18.3.2 filter_rows returns sorted row indices" {
  let filter = AutoFilter::{
    range: try! @address.CellRange::parse_a1("A1:A4"),
    columns: [
      {
        column_id: 0,
        hidden_button: false,
        rule: Filters([Literal("keep")], false),
      },
    ],
  }
  let rows = [row(3, [s("keep")]), row(7, [s("drop")]), row(9, [s("keep")])]
  assert_eq(filter.filter_rows(rows, system()), [3, 9])
}
