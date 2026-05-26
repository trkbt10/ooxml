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
fn column(
  id : Int,
  hidden_button : Bool,
  rule : @domain.CT_FilterColumn_Choice,
) -> @domain.CT_FilterColumn {
  { col_id: id, hidden_button, show_button: true, rule: Some(rule) }
}

///|
test "§18.3.2 filters literal keeps exact text" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(
        0,
        false,
        Filters({
          filters: [{ val: "foo" }],
          date_group_items: [],
          blank: false,
        }),
      ),
    ],
  }
  assert_true(row_visible(filter, row(0, [s("foo")]), system()))
  assert_true(!row_visible(filter, row(1, [s("bar")]), system()))
}

///|
test "§18.3.2 filters blank_included keeps empty cells" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(
        0,
        false,
        Filters({ filters: [{ val: "foo" }], date_group_items: [], blank: true }),
      ),
    ],
  }
  assert_true(
    row_visible(filter, row(0, [@formula.FormulaValue::VEmpty]), system()),
  )
  assert_true(row_visible(filter, row(1, [s("")]), system()))
  assert_true(!row_visible(filter, row(2, [s("bar")]), system()))
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
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(
        0,
        false,
        Filters({
          filters: [],
          date_group_items: [
            {
              year: 2006,
              month: None,
              day: None,
              hour: None,
              minute: None,
              second: None,
              date_time_grouping: Year,
            },
          ],
          blank: false,
        }),
      ),
    ],
  }
  assert_true(row_visible(filter, row(0, [n(serial)]), system()))
  assert_true(!row_visible(filter, row(1, [n(0.0)]), system()))
}

///|
test "§18.3.2 customFilters numeric AND range" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A12"),
    filter_columns: [
      column(
        0,
        false,
        CustomFilters({
          criteria: [
            { operator: GreaterThan, val: "5" },
            { operator: LessThan, val: "10" },
          ],
          and_op: true,
        }),
      ),
    ],
  }
  let rows = [
    row(0, [n(5.0)]),
    row(1, [n(6.0)]),
    row(2, [n(9.0)]),
    row(3, [n(10.0)]),
  ]
  @debug.assert_eq(filter_rows(filter, rows, system()), [1, 2])
}

///|
test "§18.3.2 customFilters star wildcard" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(
        0,
        false,
        CustomFilters({
          criteria: [{ operator: Equal, val: "*foo*" }],
          and_op: false,
        }),
      ),
    ],
  }
  assert_true(row_visible(filter, row(0, [s("before foo after")]), system()))
  assert_true(!row_visible(filter, row(1, [s("bar")]), system()))
}

///|
test "§18.3.2 customFilters question wildcard" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(
        0,
        false,
        CustomFilters({
          criteria: [{ operator: Equal, val: "?bar" }],
          and_op: false,
        }),
      ),
    ],
  }
  assert_true(row_visible(filter, row(0, [s("xbar")]), system()))
  assert_true(!row_visible(filter, row(1, [s("xxbar")]), system()))
}

///|
test "§18.3.2 dynamicFilter today uses deterministic serial-zero anchor" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(0, false, DynamicFilter({ kind: Today, val: None, max_val: None })),
    ],
  }
  assert_true(row_visible(filter, row(0, [n(0.25)]), system()))
  assert_true(!row_visible(filter, row(1, [n(1.25)]), system()))
}

///|
test "§18.3.2 dynamicFilter aboveAverage uses full row set" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A4"),
    filter_columns: [
      column(
        0,
        false,
        DynamicFilter({ kind: AboveAverage, val: None, max_val: None }),
      ),
    ],
  }
  let rows = [
    row(0, [n(1.0)]),
    row(1, [n(2.0)]),
    row(2, [n(8.0)]),
    row(3, [n(9.0)]),
  ]
  @debug.assert_eq(filter_rows(filter, rows, system()), [2, 3])
}

///|
test "§18.3.2 colorFilter stub is false without style tags" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A1"),
    filter_columns: [
      column(0, false, ColorFilter({ dxf_id: 1, cell_color: true })),
    ],
  }
  assert_true(!row_visible(filter, row(0, [s("foo")]), system()))
}

///|
test "§18.3.2 top10 top three numeric values" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A5"),
    filter_columns: [
      column(
        0,
        false,
        Top10({ top: true, percent: false, val: 3.0, filter_val: None }),
      ),
    ],
  }
  let rows = [
    row(0, [n(1.0)]),
    row(1, [n(9.0)]),
    row(2, [n(4.0)]),
    row(3, [n(7.0)]),
    row(4, [n(3.0)]),
  ]
  @debug.assert_eq(filter_rows(filter, rows, system()), [1, 2, 3])
}

///|
test "§18.3.2 top10 bottom twenty-five percent" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A8"),
    filter_columns: [
      column(
        0,
        false,
        Top10({ top: false, percent: true, val: 25.0, filter_val: None }),
      ),
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
  @debug.assert_eq(filter_rows(filter, rows, system()), [6, 7])
}

///|
test "§18.3.2 multi-column filters intersect" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:B4"),
    filter_columns: [
      column(
        0,
        false,
        Filters({
          filters: [{ val: "foo" }],
          date_group_items: [],
          blank: false,
        }),
      ),
      column(
        1,
        false,
        CustomFilters({
          criteria: [{ operator: GreaterThan, val: "5" }],
          and_op: false,
        }),
      ),
    ],
  }
  let rows = [
    row(0, [s("foo"), n(6.0)]),
    row(1, [s("foo"), n(4.0)]),
    row(2, [s("bar"), n(9.0)]),
  ]
  @debug.assert_eq(filter_rows(filter, rows, system()), [0])
}

///|
test "§18.3.2 from_element parses XML fragment" {
  let document = try! @xml.parse(
    bytes(
      "<autoFilter ref=\"A1:B3\"><filterColumn colId=\"1\" hiddenButton=\"1\"><customFilters and=\"1\"><customFilter operator=\"greaterThanOrEqual\" val=\"5\"/><customFilter operator=\"lessThan\" val=\"10\"/></customFilters></filterColumn></autoFilter>",
    ),
  )
  let filter = try! parse_auto_filter(document.root)
  @debug.assert_eq(filter.range.to_a1(), "A1:B3")
  @debug.assert_eq(filter.filter_columns.length(), 1)
  @debug.assert_eq(filter.filter_columns[0].col_id, 1)
  assert_true(filter.filter_columns[0].hidden_button)
  @debug.assert_eq(
    filter_rows(
      filter,
      [row(0, [s("x"), n(5.0)]), row(1, [s("x"), n(10.0)])],
      system(),
    ),
    [0],
  )
}

///|
test "§18.3.2 filter_rows returns sorted row indices" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A4"),
    filter_columns: [
      column(
        0,
        false,
        Filters({
          filters: [{ val: "keep" }],
          date_group_items: [],
          blank: false,
        }),
      ),
    ],
  }
  let rows = [row(3, [s("keep")]), row(7, [s("drop")]), row(9, [s("keep")])]
  @debug.assert_eq(filter_rows(filter, rows, system()), [3, 9])
}
