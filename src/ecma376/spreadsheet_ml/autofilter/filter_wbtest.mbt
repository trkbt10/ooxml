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
fn dt(year : Int, month : Int, day : Int) -> @date_serial.CalendarDateTime {
  { year, month, day, hour: 0, minute: 0, second: 0, millisecond: 0 }
}

///|
fn serial_date(year : Int, month : Int, day : Int) -> Double {
  try! @date_serial.date_time_to_serial(dt(year, month, day), system())
}

///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn parsed_auto_filter(source : String) -> @domain.CT_AutoFilter raise {
  let document = try! @xml.parse(bytes(source))
  parse_auto_filter(document.root)
}

///|
fn assert_auto_filter_schema_violation(source : String) -> Unit raise {
  let document = try! @xml.parse(bytes(source))
  assert_true(
    (try? parse_auto_filter(document.root))
    is Err(@opc_errors.SchemaViolation(_)),
  )
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
          calendar_type: "none",
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
        Filters({
          filters: [{ val: "foo" }],
          date_group_items: [],
          blank: true,
          calendar_type: "none",
        }),
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
          calendar_type: "none",
        }),
      ),
    ],
  }
  assert_true(row_visible(filter, row(0, [n(serial)]), system()))
  assert_true(!row_visible(filter, row(1, [n(0.0)]), system()))
}

///|
test "§18.3.2 dateGroupItem honors Gregorian calendarType family only" {
  let serial = serial_date(2006, 5, 1)
  let gregorian_filter : @domain.CT_AutoFilter = {
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
          calendar_type: "gregorianUs",
        }),
      ),
    ],
  }
  let hijri_filter : @domain.CT_AutoFilter = {
    ..gregorian_filter,
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
          calendar_type: "hijri",
        }),
      ),
    ],
  }
  assert_true(row_visible(gregorian_filter, row(0, [n(serial)]), system()))
  assert_true(!row_visible(hijri_filter, row(0, [n(serial)]), system()))
}

///|
test "§18.3.2 filters calendarType validates ST_CalendarType" {
  assert_auto_filter_schema_violation(
    "<autoFilter ref=\"A1:A2\"><filterColumn colId=\"0\"><filters calendarType=\"lunar\"><dateGroupItem year=\"2006\" dateTimeGrouping=\"year\"/></filters></filterColumn></autoFilter>",
  )
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
test "§18.3.2 dynamicFilter today legacy API uses deterministic serial-zero anchor" {
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
test "§18.3.2 dynamicFilter today uses explicit reference date" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(0, false, DynamicFilter({ kind: Today, val: None, max_val: None })),
    ],
  }
  let today = dt(2024, 3, 15)
  assert_true(
    row_visible_at(
      filter,
      row(0, [n(serial_date(2024, 3, 15) + 0.25)]),
      system(),
      today,
    ),
  )
  assert_true(
    !row_visible_at(
      filter,
      row(1, [n(serial_date(2024, 3, 16) + 0.25)]),
      system(),
      today,
    ),
  )
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
test "§18.3.2 value-only colorFilter is false without formatting context" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A1"),
    filter_columns: [
      column(0, false, ColorFilter({ dxf_id: Some(1), cell_color: true })),
    ],
  }
  assert_true(!row_visible(filter, row(0, [s("foo")]), system()))
}

///|
test "§18.3.2 value-only iconFilter is false without formatting context" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A1"),
    filter_columns: [
      column(
        0,
        false,
        IconFilter({ icon_set: "3TrafficLights1", icon_id: Some(2) }),
      ),
    ],
  }
  assert_true(!row_visible(filter, row(0, [n(30.0)]), system()))
}

///|
test "§18.3.2 formatted rows evaluate colorFilter inside AutoFilter SoT" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(0, false, ColorFilter({ dxf_id: Some(1), cell_color: true })),
    ],
  }
  let rows : Array[FormattedCandidateRow] = [
    {
      row_index: 2,
      cells: [
        {
          value: s("keep"),
          fill_color: Some("#ff0000"),
          font_color: None,
          rich_text_font_colors: [],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
    {
      row_index: 3,
      cells: [
        {
          value: s("drop"),
          fill_color: Some("#00ff00"),
          font_color: None,
          rich_text_font_colors: [],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
  ]
  let dxf_formats : Array[FilterDxfFormat] = [
    { dxf_id: 1, fill_color: Some("FFFF0000"), font_color: None },
  ]
  @debug.assert_eq(filter_formatted_rows(filter, rows, dxf_formats, system()), [
    2,
  ])
}

///|
test "§18.3.2 formatted rows use candidate order, not row-index lookup" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(0, false, ColorFilter({ dxf_id: Some(1), cell_color: true })),
    ],
  }
  let rows : Array[FormattedCandidateRow] = [
    {
      row_index: 7,
      cells: [
        {
          value: s("first"),
          fill_color: Some("#ff0000"),
          font_color: None,
          rich_text_font_colors: [],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
    {
      row_index: 7,
      cells: [
        {
          value: s("second"),
          fill_color: Some("#00ff00"),
          font_color: None,
          rich_text_font_colors: [],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
  ]
  let dxf_formats : Array[FilterDxfFormat] = [
    { dxf_id: 1, fill_color: Some("FFFF0000"), font_color: None },
  ]
  @debug.assert_eq(filter_formatted_rows(filter, rows, dxf_formats, system()), [
    7,
  ])
}

///|
test "§18.3.2 formatted rows evaluate font colorFilter inside AutoFilter SoT" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(0, false, ColorFilter({ dxf_id: Some(2), cell_color: false })),
    ],
  }
  let rows : Array[FormattedCandidateRow] = [
    {
      row_index: 2,
      cells: [
        {
          value: s("keep"),
          fill_color: None,
          font_color: Some("#112233"),
          rich_text_font_colors: [],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
    {
      row_index: 3,
      cells: [
        {
          value: s("drop"),
          fill_color: None,
          font_color: Some("#445566"),
          rich_text_font_colors: [],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
  ]
  let dxf_formats : Array[FilterDxfFormat] = [
    { dxf_id: 2, fill_color: None, font_color: Some("112233") },
  ]
  @debug.assert_eq(filter_formatted_rows(filter, rows, dxf_formats, system()), [
    2,
  ])
}

///|
test "§18.3.2 font colorFilter matches rich text run colors inside AutoFilter SoT" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(0, false, ColorFilter({ dxf_id: Some(2), cell_color: false })),
    ],
  }
  let rows : Array[FormattedCandidateRow] = [
    {
      row_index: 2,
      cells: [
        {
          value: s("keep"),
          fill_color: None,
          font_color: Some("#000000"),
          rich_text_font_colors: ["#445566", "FF112233"],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
    {
      row_index: 3,
      cells: [
        {
          value: s("drop"),
          fill_color: None,
          font_color: Some("#000000"),
          rich_text_font_colors: ["#445566"],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
  ]
  let dxf_formats : Array[FilterDxfFormat] = [
    { dxf_id: 2, fill_color: None, font_color: Some("112233") },
  ]
  @debug.assert_eq(filter_formatted_rows(filter, rows, dxf_formats, system()), [
    2,
  ])
}

///|
test "§18.3.2 formatted rows evaluate iconFilter inside AutoFilter SoT" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A3"),
    filter_columns: [
      column(
        0,
        false,
        IconFilter({ icon_set: "3TrafficLights1", icon_id: Some(2) }),
      ),
    ],
  }
  let rows : Array[FormattedCandidateRow] = [
    {
      row_index: 2,
      cells: [
        {
          value: n(10.0),
          fill_color: None,
          font_color: None,
          rich_text_font_colors: [],
          icon_set: Some("3TrafficLights1"),
          icon_id: Some(1),
        },
      ],
    },
    {
      row_index: 3,
      cells: [
        {
          value: n(30.0),
          fill_color: None,
          font_color: None,
          rich_text_font_colors: [],
          icon_set: Some("3TrafficLights1"),
          icon_id: Some(2),
        },
      ],
    },
  ]
  @debug.assert_eq(filter_formatted_rows(filter, rows, [], system()), [3])
}

///|
test "§18.3.2 iconFilter without iconId matches no-icon facts for the same set" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A4"),
    filter_columns: [
      column(
        0,
        false,
        IconFilter({ icon_set: "3TrafficLights1", icon_id: None }),
      ),
    ],
  }
  let rows : Array[FormattedCandidateRow] = [
    {
      row_index: 2,
      cells: [
        {
          value: n(10.0),
          fill_color: None,
          font_color: None,
          rich_text_font_colors: [],
          icon_set: Some("3TrafficLights1"),
          icon_id: None,
        },
      ],
    },
    {
      row_index: 3,
      cells: [
        {
          value: n(30.0),
          fill_color: None,
          font_color: None,
          rich_text_font_colors: [],
          icon_set: Some("3TrafficLights1"),
          icon_id: Some(2),
        },
      ],
    },
    {
      row_index: 4,
      cells: [
        {
          value: n(20.0),
          fill_color: None,
          font_color: None,
          rich_text_font_colors: [],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
  ]
  @debug.assert_eq(filter_formatted_rows(filter, rows, [], system()), [2])
}

///|
test "§18.3.2 formatted colorFilter fails without matching dxf fact" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A2"),
    filter_columns: [
      column(0, false, ColorFilter({ dxf_id: Some(9), cell_color: true })),
    ],
  }
  let rows : Array[FormattedCandidateRow] = [
    {
      row_index: 2,
      cells: [
        {
          value: s("red"),
          fill_color: Some("#ff0000"),
          font_color: None,
          rich_text_font_colors: [],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
  ]
  let dxf_formats : Array[FilterDxfFormat] = [
    { dxf_id: 1, fill_color: Some("FFFF0000"), font_color: None },
  ]
  @debug.assert_eq(filter_formatted_rows(filter, rows, dxf_formats, system()), [])
}

///|
test "§18.3.2 formatted colorFilter fails without candidate color fact" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A2"),
    filter_columns: [
      column(0, false, ColorFilter({ dxf_id: Some(1), cell_color: true })),
    ],
  }
  let rows : Array[FormattedCandidateRow] = [
    {
      row_index: 2,
      cells: [
        {
          value: s("unstyled"),
          fill_color: None,
          font_color: None,
          rich_text_font_colors: [],
          icon_set: None,
          icon_id: None,
        },
      ],
    },
  ]
  let dxf_formats : Array[FilterDxfFormat] = [
    { dxf_id: 1, fill_color: Some("FFFF0000"), font_color: None },
  ]
  @debug.assert_eq(filter_formatted_rows(filter, rows, dxf_formats, system()), [])
}

///|
test "§18.3.2 formatted iconFilter requires matching icon set and id" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A2"),
    filter_columns: [
      column(
        0,
        false,
        IconFilter({ icon_set: "3TrafficLights1", icon_id: Some(2) }),
      ),
    ],
  }
  let rows : Array[FormattedCandidateRow] = [
    {
      row_index: 2,
      cells: [
        {
          value: n(50.0),
          fill_color: None,
          font_color: None,
          rich_text_font_colors: [],
          icon_set: Some("3Arrows"),
          icon_id: Some(2),
        },
      ],
    },
  ]
  @debug.assert_eq(filter_formatted_rows(filter, rows, [], system()), [])
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
test "§18.3.2 top10 uses filterVal as persisted threshold" {
  let filter : @domain.CT_AutoFilter = {
    range: try! @address.CellRange::parse_a1("A1:A6"),
    filter_columns: [
      column(
        0,
        false,
        Top10({ top: true, percent: true, val: 50.0, filter_val: Some(6.0) }),
      ),
    ],
  }
  let rows = [
    row(0, [n(1.0)]),
    row(1, [n(2.0)]),
    row(2, [n(3.0)]),
    row(3, [n(4.0)]),
    row(4, [n(5.0)]),
    row(5, [n(6.0)]),
  ]
  @debug.assert_eq(filter_rows(filter, rows, system()), [5])
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
          calendar_type: "none",
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
  let filter = try! parsed_auto_filter(
    "<autoFilter ref=\"A1:B3\"><filterColumn colId=\"1\" hiddenButton=\"1\"><customFilters and=\"1\"><customFilter operator=\"greaterThanOrEqual\" val=\"5\"/><customFilter operator=\"lessThan\" val=\"10\"/></customFilters></filterColumn></autoFilter>",
  )
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
test "§18.3.1.2 parses caller default ref for table AutoFilter" {
  let document = try! @xml.parse(
    bytes(
      "<autoFilter><filterColumn colId=\"0\" showButton=\"0\"/></autoFilter>",
    ),
  )
  let filter = try! parse_auto_filter_with_default_ref(document.root, "C2:D4")
  @debug.assert_eq(filter.range.to_a1(), "C2:D4")
  @debug.assert_eq(filter.filter_columns.length(), 1)
  assert_true(!filter.filter_columns[0].show_button)
}

///|
test "§18.3.2 from_element parses colorFilter and iconFilter attributes" {
  let filter = try! parsed_auto_filter(
    "<autoFilter ref=\"A1:B3\"><filterColumn colId=\"0\"><colorFilter dxfId=\"2\"/></filterColumn><filterColumn colId=\"1\"><iconFilter iconSet=\"3TrafficLights1\" iconId=\"2\"/></filterColumn></autoFilter>",
  )
  @debug.assert_eq(filter.filter_columns.length(), 2)
  match filter.filter_columns[0].rule {
    Some(ColorFilter(color)) => {
      @debug.assert_eq(color.dxf_id, Some(2))
      assert_true(color.cell_color)
    }
    _ => fail("expected colorFilter")
  }
  match filter.filter_columns[1].rule {
    Some(IconFilter(icon)) => {
      @debug.assert_eq(icon.icon_set, "3TrafficLights1")
      @debug.assert_eq(icon.icon_id, Some(2))
    }
    _ => fail("expected iconFilter")
  }
}

///|
test "§18.3.2 from_element accepts optional colorFilter dxfId and iconFilter iconId" {
  let filter = try! parsed_auto_filter(
    "<autoFilter ref=\"A1:B3\"><filterColumn colId=\"0\"><colorFilter/></filterColumn><filterColumn colId=\"1\"><iconFilter iconSet=\"3TrafficLights1\"/></filterColumn></autoFilter>",
  )
  match filter.filter_columns[0].rule {
    Some(ColorFilter(color)) => @debug.assert_eq(color.dxf_id, None)
    _ => fail("expected colorFilter")
  }
  match filter.filter_columns[1].rule {
    Some(IconFilter(icon)) => @debug.assert_eq(icon.icon_id, None)
    _ => fail("expected iconFilter")
  }
}

///|
test "§18.3.2 from_element rejects missing or invalid iconFilter iconSet" {
  assert_auto_filter_schema_violation(
    "<autoFilter ref=\"A1:A2\"><filterColumn colId=\"0\"><iconFilter iconId=\"1\"/></filterColumn></autoFilter>",
  )
  assert_auto_filter_schema_violation(
    "<autoFilter ref=\"A1:A2\"><filterColumn colId=\"0\"><iconFilter iconSet=\"NoSuchSet\" iconId=\"1\"/></filterColumn></autoFilter>",
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
          calendar_type: "none",
        }),
      ),
    ],
  }
  let rows = [row(3, [s("keep")]), row(7, [s("drop")]), row(9, [s("keep")])]
  @debug.assert_eq(filter_rows(filter, rows, system()), [3, 9])
}
