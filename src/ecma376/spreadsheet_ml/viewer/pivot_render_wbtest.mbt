///|
fn pivot_test_shared_items(
  items : Array[@pivot_table.SharedItemValue],
) -> @pivot_table.SharedItems {
  {
    items,
    contains_blank: false,
    contains_date: false,
    contains_integer: false,
    contains_mixed_types: false,
    contains_non_date: true,
    contains_number: false,
    contains_semi_mixed_types: true,
    contains_string: true,
    long_text: false,
    min_value: None,
    max_value: None,
    min_date: None,
    max_date: None,
  }
}

///|
fn pivot_test_cache_field(
  name : String,
  shared : Array[@pivot_table.SharedItemValue],
) -> @pivot_table.CacheField {
  {
    name,
    caption: None,
    num_fmt_id: None,
    database_field: true,
    formula: None,
    shared_items: pivot_test_shared_items(shared),
  }
}

///|
fn pivot_test_data_field(
  name : String,
  fld : Int,
  subtotal : @pivot_table.DataConsolidateFunction,
) -> @pivot_table.DataFieldDef {
  {
    name: Some(name),
    fld,
    subtotal,
    base_field: None,
    base_item: None,
    num_fmt_id: None,
    show_data_as: None,
  }
}

///|
fn pivot_test_layout() -> SheetLayout {
  {
    cells: [],
    total_width: 300.0,
    total_height: 140.0,
    column_positions: [0.0, 50.0, 100.0, 150.0, 200.0, 250.0],
    row_positions: [0.0, 20.0, 40.0, 60.0, 80.0, 100.0, 120.0],
    column_widths: [50.0, 50.0, 50.0, 50.0, 50.0, 50.0],
    row_heights: [20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0],
    column_count: 6,
    row_count: 7,
    merge_map: {},
  }
}

///|
fn pivot_test_svg(nodes : Array[@xml.Node]) -> String {
  match nodes[0] {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
}

///|
fn pivot_test_xml_name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
fn pivot_test_basic_materialized(
  location_ref : String,
) -> @pivot_table.MaterializedPivotTable {
  let cache : @pivot_table.PivotCacheDefinition = {
    cache_source: {
      source_type: "worksheet",
      connection_id: None,
      worksheet_source: None,
    },
    cache_fields: [
      pivot_test_cache_field("Region", [
        @pivot_table.SharedItemValue::SharedString("East"),
      ]),
      pivot_test_cache_field("Sales", []),
    ],
    refreshed_by: None,
    refreshed_date_iso: None,
    record_count: None,
    created_version: None,
    refreshed_version: None,
    min_refreshable_version: None,
    save_data: true,
    invalid: false,
    refresh_on_load: false,
  }
  let east = @pivot_table.PivotAxisKey::Items([0])
  let col = @pivot_table.PivotAxisKey::Items([])
  let definition : @pivot_table.PivotTableDefinition = {
    name: "PT",
    data_caption: Some("Values"),
    cache_id: Some(0),
    row_grand_totals: false,
    col_grand_totals: false,
    data_on_rows: false,
    location: Some({
      ref_range: try! @address.CellRange::parse_a1(location_ref),
      first_header_row: 0,
      first_data_row: 1,
      first_data_col: 1,
      row_page_count: 0,
      col_page_count: 0,
    }),
    pivot_fields: [],
    row_fields: [0],
    col_fields: [],
    row_items: [],
    col_items: [],
    page_fields: [],
    filters: [],
    data_fields: [
      pivot_test_data_field(
        "Sum of Sales",
        1,
        @pivot_table.DataConsolidateFunction::Sum,
      ),
    ],
    style_info: None,
  }
  let materialization : @pivot_table.PivotMaterialization = {
    row_keys: [east],
    col_keys: [col],
    data_field_count: 1,
    cells: [
      {
        row_key: east,
        col_key: col,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(100.0),
      },
    ],
  }
  { definition, cache, materialization }
}

///|
test "render_svg viewBox extends to pivot overlay outside sheet dimension" {
  let worksheet = @domain.CT_Worksheet::new({
    name: pivot_test_xml_name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: pivot_test_xml_name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: pivot_test_xml_name("row"),
            attributes: [{ name: pivot_test_xml_name("r"), value: "1" }],
            children: [
              @xml.Node::Element({
                name: pivot_test_xml_name("c"),
                attributes: [{ name: pivot_test_xml_name("r"), value: "A1" }],
                children: [
                  @xml.Node::Element({
                    name: pivot_test_xml_name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("1")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let result = render_svg(worksheet, pivots=[
    pivot_test_basic_materialized("E1:F2"),
  ])
  assert_true(result.svg.contains("class=\"pivot-tables\""))
  assert_true(result.svg.contains(">100<"))
  assert_true(result.width > 500.0)
}

///|
test "§18.10.1.74 pivotTableStyleInfo emits style metadata" {
  let cache : @pivot_table.PivotCacheDefinition = {
    cache_source: {
      source_type: "worksheet",
      connection_id: None,
      worksheet_source: None,
    },
    cache_fields: [
      pivot_test_cache_field("Region", [
        @pivot_table.SharedItemValue::SharedString("East"),
      ]),
      pivot_test_cache_field("Product", [
        @pivot_table.SharedItemValue::SharedString("Bike"),
      ]),
      pivot_test_cache_field("Sales", []),
    ],
    refreshed_by: None,
    refreshed_date_iso: None,
    record_count: None,
    created_version: None,
    refreshed_version: None,
    min_refreshable_version: None,
    save_data: true,
    invalid: false,
    refresh_on_load: false,
  }
  let east = @pivot_table.PivotAxisKey::Items([0])
  let bike = @pivot_table.PivotAxisKey::Items([0])
  let definition : @pivot_table.PivotTableDefinition = {
    name: "PT",
    data_caption: Some("Values"),
    cache_id: Some(0),
    row_grand_totals: false,
    col_grand_totals: false,
    data_on_rows: false,
    location: Some({
      ref_range: try! @address.CellRange::parse_a1("A1:C3"),
      first_header_row: 0,
      first_data_row: 1,
      first_data_col: 1,
      row_page_count: 0,
      col_page_count: 0,
    }),
    pivot_fields: [],
    row_fields: [0],
    col_fields: [1],
    row_items: [],
    col_items: [],
    page_fields: [],
    filters: [],
    data_fields: [
      pivot_test_data_field(
        "Sum of Sales",
        2,
        @pivot_table.DataConsolidateFunction::Sum,
      ),
    ],
    style_info: Some({
      name: Some("PivotStyleMedium9"),
      show_row_headers: true,
      show_col_headers: true,
      show_row_stripes: true,
      show_col_stripes: true,
      show_last_column: true,
    }),
  }
  let materialization : @pivot_table.PivotMaterialization = {
    row_keys: [east],
    col_keys: [bike],
    data_field_count: 1,
    cells: [
      {
        row_key: east,
        col_key: bike,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(10.0),
      },
    ],
  }
  let pivot : @pivot_table.MaterializedPivotTable = {
    definition,
    cache,
    materialization,
  }
  let svg = pivot_test_svg(
    render_pivot_overlay(
      pivot,
      pivot_test_layout(),
      default_render_options(),
      [],
      [],
      None,
      None,
      SmlThemeColorMap::empty(),
    ),
  )
  assert_true(svg.contains("data-ooxml-pivot-style=\"PivotStyleMedium9\""))
  assert_true(svg.contains("data-ooxml-pivot-row-stripes=\"1\""))
  assert_true(svg.contains("data-ooxml-pivot-col-stripes=\"1\""))
  assert_true(svg.contains("data-ooxml-pivot-row-headers=\"1\""))
  assert_true(svg.contains("data-ooxml-pivot-col-headers=\"1\""))
  assert_true(svg.contains("data-ooxml-pivot-last-column=\"1\""))
}

///|
test "§18.10.1.73 dataOnRows renders data fields on row axis" {
  let cache : @pivot_table.PivotCacheDefinition = {
    cache_source: {
      source_type: "worksheet",
      connection_id: None,
      worksheet_source: None,
    },
    cache_fields: [
      pivot_test_cache_field("Region", [
        @pivot_table.SharedItemValue::SharedString("East"),
        @pivot_table.SharedItemValue::SharedString("West"),
      ]),
      pivot_test_cache_field("Product", [
        @pivot_table.SharedItemValue::SharedString("Bike"),
        @pivot_table.SharedItemValue::SharedString("Helmet"),
      ]),
      pivot_test_cache_field("Sales", []),
    ],
    refreshed_by: None,
    refreshed_date_iso: None,
    record_count: None,
    created_version: None,
    refreshed_version: None,
    min_refreshable_version: None,
    save_data: true,
    invalid: false,
    refresh_on_load: false,
  }
  let east = @pivot_table.PivotAxisKey::Items([0])
  let west = @pivot_table.PivotAxisKey::Items([1])
  let bike = @pivot_table.PivotAxisKey::Items([0])
  let helmet = @pivot_table.PivotAxisKey::Items([1])
  let definition : @pivot_table.PivotTableDefinition = {
    name: "PT",
    data_caption: Some("Values"),
    cache_id: Some(0),
    row_grand_totals: false,
    col_grand_totals: false,
    data_on_rows: true,
    location: Some({
      ref_range: try! @address.CellRange::parse_a1("A1:D5"),
      first_header_row: 0,
      first_data_row: 1,
      first_data_col: 1,
      row_page_count: 0,
      col_page_count: 0,
    }),
    pivot_fields: [],
    row_fields: [0, -2],
    col_fields: [1],
    row_items: [],
    col_items: [],
    page_fields: [],
    filters: [],
    data_fields: [
      pivot_test_data_field(
        "Sum of Sales",
        2,
        @pivot_table.DataConsolidateFunction::Sum,
      ),
      pivot_test_data_field(
        "Count of Sales",
        2,
        @pivot_table.DataConsolidateFunction::Count,
      ),
    ],
    style_info: None,
  }
  let materialization : @pivot_table.PivotMaterialization = {
    row_keys: [east, west],
    col_keys: [bike, helmet],
    data_field_count: 2,
    cells: [
      {
        row_key: east,
        col_key: bike,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(10.0),
      },
      {
        row_key: east,
        col_key: bike,
        data_field_index: 1,
        aggregated_value: @formula.VNumber(1.0),
      },
      {
        row_key: east,
        col_key: helmet,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(20.0),
      },
      {
        row_key: east,
        col_key: helmet,
        data_field_index: 1,
        aggregated_value: @formula.VNumber(1.0),
      },
    ],
  }
  let pivot : @pivot_table.MaterializedPivotTable = {
    definition,
    cache,
    materialization,
  }
  let svg = pivot_test_svg(
    render_pivot_overlay(
      pivot,
      pivot_test_layout(),
      default_render_options(),
      [],
      [],
      None,
      None,
      SmlThemeColorMap::empty(),
    ),
  )
  assert_true(svg.contains(">Values<"))
  assert_true(svg.contains(">Sum of Sales<"))
  assert_true(svg.contains(">Count of Sales<"))
  assert_true(svg.contains(">Bike<"))
  assert_true(svg.contains(">Helmet<"))
  // dataOnRows uses two leading columns (Region + Values) and one value
  // column per column-key, while expanding the two data fields vertically.
  assert_true(
    svg.contains(
      "<rect x=\"0\" y=\"0\" width=\"200\" height=\"100\" fill=\"none\" stroke=\"#808080\"",
    ),
  )
}
