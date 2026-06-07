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
fn pivot_test_pivot_field(
  default_subtotal : Bool,
  outline : Bool,
  subtotal_caption : String?,
) -> @pivot_table.PivotFieldDef {
  {
    axis: None,
    data_field: false,
    include_new_items_in_filter: false,
    name: None,
    subtotal_caption,
    outline,
    subtotal_top: true,
    default_subtotal,
    items: [],
    items_declared_count: None,
    auto_sort_scope: None,
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
test "§18.10 pivot overflow columns reuse worksheet Normal-style MDW" {
  let layout = {
    ..pivot_test_layout(),
    total_width: 20.0,
    column_positions: [0.0],
    column_widths: [20.0],
    column_count: 1,
  }
  let options = default_render_options()
  let mdw = 10.0
  let expected = column_width_to_pixels(
    options.default_column_width,
    mdw_px=mdw,
  )
  let (x, w) = pivot_column_geometry(layout, options, 2, max_digit_width_px=mdw)
  assert_true(w == expected)
  assert_true(x == 20.0 + expected)
  assert_true(
    w != column_width_to_pixels(options.default_column_width, mdw_px=7.0),
  )
}

///|
fn pivot_test_xml_name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
fn pivot_test_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: pivot_test_xml_name(local_name), value }
}

///|
fn pivot_test_parse_xml(source : String) -> @xml.Element {
  try! @xml.parse(@utf8.encode(source[:])).root
}

///|
fn pivot_test_normal_style(
  family : String,
  size_pt : String,
) -> @domain.CT_Stylesheet {
  try! @domain.CT_Stylesheet::new({
    name: pivot_test_xml_name("styleSheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: pivot_test_xml_name("fonts"),
        attributes: [pivot_test_attr("count", "1")],
        children: [
          @xml.Node::Element({
            name: pivot_test_xml_name("font"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: pivot_test_xml_name("name"),
                attributes: [pivot_test_attr("val", family)],
                children: [],
              }),
              @xml.Node::Element({
                name: pivot_test_xml_name("sz"),
                attributes: [pivot_test_attr("val", size_pt)],
                children: [],
              }),
            ],
          }),
        ],
      }),
      @xml.Node::Element({
        name: pivot_test_xml_name("cellStyleXfs"),
        attributes: [pivot_test_attr("count", "1")],
        children: [
          @xml.Node::Element({
            name: pivot_test_xml_name("xf"),
            attributes: [pivot_test_attr("fontId", "0")],
            children: [],
          }),
        ],
      }),
      @xml.Node::Element({
        name: pivot_test_xml_name("cellStyles"),
        attributes: [pivot_test_attr("count", "1")],
        children: [
          @xml.Node::Element({
            name: pivot_test_xml_name("cellStyle"),
            attributes: [
              pivot_test_attr("name", "Normal"),
              pivot_test_attr("xfId", "0"),
              pivot_test_attr("builtinId", "0"),
            ],
            children: [],
          }),
        ],
      }),
    ],
  })
}

///|
fn pivot_test_dxf_fill_styles(rgb : String) -> @domain.CT_Stylesheet {
  try! @domain.CT_Stylesheet::new(
    pivot_test_parse_xml(
      "<styleSheet><dxfs count=\"1\"><dxf><fill><patternFill patternType=\"solid\"><fgColor rgb=\"" +
      rgb +
      "\"/></patternFill></fill></dxf></dxfs></styleSheet>",
    ),
  )
}

///|
test "§18.10.1.69 row subtotal key renders as subtotal row" {
  let cache : @pivot_table.PivotCacheDefinition = {
    cache_source: {
      source_type: "worksheet",
      connection_id: None,
      worksheet_source: None,
    },
    cache_fields: [
      pivot_test_cache_field("Region", [
        @pivot_table.SharedItemValue::SharedString("North"),
      ]),
      pivot_test_cache_field("Product", [
        @pivot_table.SharedItemValue::SharedString("Apple"),
        @pivot_table.SharedItemValue::SharedString("Bread"),
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
    cache_hierarchies: None,
    kpis: None,
    tuple_cache: None,
    calculated_items: None,
    calculated_members: None,
    dimensions: None,
    measure_groups: None,
    maps: None,
  }
  let apple = @pivot_table.PivotAxisKey::Items([0, 0])
  let bread = @pivot_table.PivotAxisKey::Items([0, 1])
  let north_total = @pivot_table.PivotAxisKey::RowSubtotal([0])
  let col = @pivot_table.PivotAxisKey::Items([])
  let definition : @pivot_table.PivotTableDefinition = {
    name: "PT",
    data_caption: Some("Values"),
    cache_id: Some(0),
    row_grand_totals: false,
    col_grand_totals: false,
    data_on_rows: false,
    location: Some({
      ref_range: try! @address.CellRange::parse_a1("A1:C4"),
      first_header_row: 0,
      first_data_row: 1,
      first_data_col: 1,
      row_page_count: 0,
      col_page_count: 0,
    }),
    pivot_fields: [
      pivot_test_pivot_field(true, false, None),
      pivot_test_pivot_field(true, true, None),
      pivot_test_pivot_field(false, true, None),
    ],
    row_fields: [0, 1],
    col_fields: [],
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
    formats: None,
    conditional_formats: None,
    chart_formats: None,
    pivot_hierarchies: None,
    row_hierarchies_usage: None,
    col_hierarchies_usage: None,
    style_info: None,
  }
  let materialization : @pivot_table.PivotMaterialization = {
    row_keys: [apple, bread, north_total],
    col_keys: [col],
    data_field_count: 1,
    cells: [
      {
        row_key: apple,
        col_key: col,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(100.0),
      },
      {
        row_key: bread,
        col_key: col,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(50.0),
      },
      {
        row_key: north_total,
        col_key: col,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(150.0),
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
      SmlThemeFontMap::empty(),
      max_digit_width_px=7.0,
    ),
  )
  assert_true(svg.contains(">North Result<"))
  assert_true(svg.contains(">150<"))
  assert_true(svg.contains("font-weight=\"bold\""))
  assert_true(svg.contains("fill=\"#F2F2F2\""))
}

///|
test "§18.10 pivot format reference x applies dxf to matching value cell" {
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
    cache_hierarchies: None,
    kpis: None,
    tuple_cache: None,
    calculated_items: None,
    calculated_members: None,
    dimensions: None,
    measure_groups: None,
    maps: None,
  }
  let east = @pivot_table.PivotAxisKey::Items([0])
  let west = @pivot_table.PivotAxisKey::Items([1])
  let col = @pivot_table.PivotAxisKey::Items([])
  let formats = try! @domain.CT_Formats::new(
    pivot_test_parse_xml(
      "<formats count=\"1\"><format action=\"formatting\" dxfId=\"0\"><pivotArea field=\"0\" type=\"data\"><references count=\"1\"><reference field=\"0\" count=\"1\"><x v=\"1\"/></reference></references></pivotArea></format></formats>",
    ),
  )
  let definition : @pivot_table.PivotTableDefinition = {
    name: "PT",
    data_caption: Some("Values"),
    cache_id: Some(0),
    row_grand_totals: false,
    col_grand_totals: false,
    data_on_rows: false,
    location: Some({
      ref_range: try! @address.CellRange::parse_a1("A1:B3"),
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
    formats: Some(formats),
    conditional_formats: None,
    chart_formats: None,
    pivot_hierarchies: None,
    row_hierarchies_usage: None,
    col_hierarchies_usage: None,
    style_info: None,
  }
  let materialization : @pivot_table.PivotMaterialization = {
    row_keys: [east, west],
    col_keys: [col],
    data_field_count: 1,
    cells: [
      {
        row_key: east,
        col_key: col,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(10.0),
      },
      {
        row_key: west,
        col_key: col,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(20.0),
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
      Some(pivot_test_dxf_fill_styles("FFFFCC00")),
      None,
      SmlThemeColorMap::empty(),
      SmlThemeFontMap::empty(),
      max_digit_width_px=7.0,
    ),
  )
  assert_true(
    svg.contains("data-ooxml-pivot-format-0-area-reference-0-x-0-v=\"1\""),
  )
  assert_true(
    svg.contains(
      "<rect x=\"50\" y=\"20\" width=\"50\" height=\"20\" fill=\"#FFFFFF\"",
    ),
  )
  assert_true(
    svg.contains(
      "<rect x=\"50\" y=\"40\" width=\"50\" height=\"20\" fill=\"#FFCC00\"",
    ),
  )
  assert_true(svg.contains(">20<"))
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
    cache_hierarchies: None,
    kpis: None,
    tuple_cache: None,
    calculated_items: None,
    calculated_members: None,
    dimensions: None,
    measure_groups: None,
    maps: None,
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
    formats: None,
    conditional_formats: None,
    chart_formats: None,
    pivot_hierarchies: None,
    row_hierarchies_usage: None,
    col_hierarchies_usage: None,
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
  set_sml_fixture_font_faces(["Calibri"])
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
test "render_svg passes Normal-style MDW to pivot overflow geometry" {
  set_sml_fixture_font_faces(["Noto Sans"])
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
            attributes: [pivot_test_attr("r", "1")],
            children: [
              @xml.Node::Element({
                name: pivot_test_xml_name("c"),
                attributes: [pivot_test_attr("r", "A1")],
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
  let normal_font : ResolvedFont = {
    family: "Noto Sans",
    charset: None,
    size: 20.0,
    bold: false,
    italic: false,
    underline: false,
    strikethrough: false,
    outline: false,
    shadow: false,
    condense: false,
    extend: false,
    color: None,
    vertical_align: "baseline",
  }
  let mdw = match normal_style_max_digit_width_px(normal_font) {
    Some(w) => w
    None => abort("fixture font did not resolve")
  }
  let default_w = column_width_to_pixels(8.43, mdw_px=mdw)
  let explicit_other_w = column_width_to_pixels(8.43, mdw_px=7.0)
  assert_true(default_w != explicit_other_w)
  let result = render_svg(
    worksheet,
    styles=Some(pivot_test_normal_style("Noto Sans", "20")),
    pivots=[pivot_test_basic_materialized("C1:D2")],
  )
  assert_true(result.warnings.length() == 0)
  assert_true(result.svg.contains("Noto Sans"))
  assert_true(
    result.svg.contains(
      "<rect x=\"" +
      format_d(default_w * 2.0) +
      "\" y=\"0\" width=\"" +
      format_d(default_w * 2.0) +
      "\" height=\"34\" fill=\"none\" stroke=\"#808080\"",
    ),
  )
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
    cache_hierarchies: None,
    kpis: None,
    tuple_cache: None,
    calculated_items: None,
    calculated_members: None,
    dimensions: None,
    measure_groups: None,
    maps: None,
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
    formats: None,
    conditional_formats: None,
    chart_formats: None,
    pivot_hierarchies: None,
    row_hierarchies_usage: None,
    col_hierarchies_usage: None,
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
      SmlThemeFontMap::empty(),
      max_digit_width_px=7.0,
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
test "§18.10 pivot metadata branches emit typed group metadata" {
  let base = pivot_test_basic_materialized("A1:C3")
  let formats = try! @domain.CT_Formats::new(
    pivot_test_parse_xml(
      "<formats count=\"1\"><format action=\"formatting\" dxfId=\"2\"><pivotArea field=\"0\" type=\"data\"><references count=\"1\"><reference field=\"0\" count=\"1\"><x v=\"0\"/></reference></references></pivotArea></format></formats>",
    ),
  )
  let conditional_formats = try! @domain.CT_ConditionalFormats::new(
    pivot_test_parse_xml(
      "<conditionalFormats count=\"1\"><conditionalFormat scope=\"data\" type=\"all\" priority=\"3\"><pivotAreas count=\"1\"><pivotArea field=\"1\" axis=\"axisRow\"/></pivotAreas></conditionalFormat></conditionalFormats>",
    ),
  )
  let chart_formats = try! @domain.CT_ChartFormats::new(
    pivot_test_parse_xml(
      "<chartFormats count=\"1\"><chartFormat chart=\"2\" format=\"4\" series=\"1\"><pivotArea field=\"2\"/></chartFormat></chartFormats>",
    ),
  )
  let hierarchies = try! @domain.CT_PivotHierarchies::new(
    pivot_test_parse_xml(
      "<pivotHierarchies count=\"1\"><pivotHierarchy caption=\"Calendar\" outline=\"1\"><mps count=\"1\"><mp field=\"0\" name=\"Fiscal\" showCell=\"1\" showTip=\"1\"/></mps><members count=\"1\" level=\"0\"><member name=\"FY2026\"/></members></pivotHierarchy></pivotHierarchies>",
    ),
  )
  let row_usage = try! @domain.CT_RowHierarchiesUsage::new(
    pivot_test_parse_xml(
      "<rowHierarchiesUsage count=\"1\"><rowHierarchyUsage hierarchyUsage=\"5\"/></rowHierarchiesUsage>",
    ),
  )
  let col_usage = try! @domain.CT_ColHierarchiesUsage::new(
    pivot_test_parse_xml(
      "<colHierarchiesUsage count=\"1\"><colHierarchyUsage hierarchyUsage=\"6\"/></colHierarchiesUsage>",
    ),
  )
  let dimensions = try! @domain.CT_Dimensions::new(
    pivot_test_parse_xml(
      "<dimensions count=\"1\"><dimension name=\"Dim\" uniqueName=\"[Dim]\" caption=\"Dimension\" measure=\"1\"/></dimensions>",
    ),
  )
  let measure_groups = try! @domain.CT_MeasureGroups::new(
    pivot_test_parse_xml(
      "<measureGroups count=\"1\"><measureGroup name=\"Sales\" caption=\"Sales\"/></measureGroups>",
    ),
  )
  let maps = try! @domain.CT_MeasureDimensionMaps::new(
    pivot_test_parse_xml(
      "<maps count=\"1\"><map measureGroup=\"0\" dimension=\"0\"/></maps>",
    ),
  )
  let definition = {
    ..base.definition,
    formats: Some(formats),
    conditional_formats: Some(conditional_formats),
    chart_formats: Some(chart_formats),
    pivot_hierarchies: Some(hierarchies),
    row_hierarchies_usage: Some(row_usage),
    col_hierarchies_usage: Some(col_usage),
  }
  let cache = {
    ..base.cache,
    dimensions: Some(dimensions),
    measure_groups: Some(measure_groups),
    maps: Some(maps),
  }
  let pivot : @pivot_table.MaterializedPivotTable = {
    definition,
    cache,
    materialization: base.materialization,
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
      SmlThemeFontMap::empty(),
      max_digit_width_px=7.0,
    ),
  )
  assert_true(svg.contains("data-ooxml-pivot-formats-count=\"1\""))
  assert_true(svg.contains("data-ooxml-pivot-format-0-dxf-id=\"2\""))
  assert_true(
    svg.contains("data-ooxml-pivot-format-0-area-references-count=\"1\""),
  )
  assert_true(
    svg.contains("data-ooxml-pivot-conditional-format-0-priority=\"3\""),
  )
  assert_true(svg.contains("data-ooxml-pivot-chart-format-0-chart=\"2\""))
  assert_true(svg.contains("data-ooxml-pivot-hierarchy-0-caption=\"Calendar\""))
  assert_true(svg.contains("data-ooxml-pivot-hierarchy-0-mp-0-name=\"Fiscal\""))
  assert_true(
    svg.contains(
      "data-ooxml-pivot-hierarchy-0-members-0-member-0-name=\"FY2026\"",
    ),
  )
  assert_true(
    svg.contains("data-ooxml-pivot-row-hierarchy-usage-0-hierarchy-usage=\"5\""),
  )
  assert_true(
    svg.contains("data-ooxml-pivot-col-hierarchy-usage-0-hierarchy-usage=\"6\""),
  )
  assert_true(
    svg.contains("data-ooxml-pivot-cache-dimension-0-caption=\"Dimension\""),
  )
  assert_true(
    svg.contains("data-ooxml-pivot-cache-measure-group-0-name=\"Sales\""),
  )
  assert_true(svg.contains("data-ooxml-pivot-cache-map-0-dimension=\"0\""))
}

///|
test "§18.10.1.62 pageFields render reserved filter dropdown" {
  let cache : @pivot_table.PivotCacheDefinition = {
    cache_source: {
      source_type: "worksheet",
      connection_id: None,
      worksheet_source: None,
    },
    cache_fields: [
      pivot_test_cache_field("Region", [
        @pivot_table.SharedItemValue::SharedString("North"),
        @pivot_table.SharedItemValue::SharedString("South"),
      ]),
      pivot_test_cache_field("Product", [
        @pivot_table.SharedItemValue::SharedString("Apple"),
        @pivot_table.SharedItemValue::SharedString("Bread"),
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
    cache_hierarchies: None,
    kpis: None,
    tuple_cache: None,
    calculated_items: None,
    calculated_members: None,
    dimensions: None,
    measure_groups: None,
    maps: None,
  }
  let north = @pivot_table.PivotAxisKey::Items([0])
  let south = @pivot_table.PivotAxisKey::Items([1])
  let col = @pivot_table.PivotAxisKey::Items([])
  let definition : @pivot_table.PivotTableDefinition = {
    name: "PT",
    data_caption: Some("Values"),
    cache_id: Some(0),
    row_grand_totals: false,
    col_grand_totals: false,
    data_on_rows: false,
    location: Some({
      ref_range: try! @address.CellRange::parse_a1("E1:F4"),
      first_header_row: 1,
      first_data_row: 2,
      first_data_col: 1,
      row_page_count: 1,
      col_page_count: 0,
    }),
    pivot_fields: [],
    row_fields: [0],
    col_fields: [],
    row_items: [],
    col_items: [],
    page_fields: [
      {
        fld: 1,
        item: Some(0),
        hier: None,
        name: Some("Product"),
        caption: None,
      },
    ],
    filters: [],
    data_fields: [
      pivot_test_data_field(
        "Sum of Sales",
        2,
        @pivot_table.DataConsolidateFunction::Sum,
      ),
    ],
    formats: None,
    conditional_formats: None,
    chart_formats: None,
    pivot_hierarchies: None,
    row_hierarchies_usage: None,
    col_hierarchies_usage: None,
    style_info: None,
  }
  let materialization : @pivot_table.PivotMaterialization = {
    row_keys: [north, south],
    col_keys: [col],
    data_field_count: 1,
    cells: [
      {
        row_key: north,
        col_key: col,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(100.0),
      },
      {
        row_key: south,
        col_key: col,
        data_field_index: 0,
        aggregated_value: @formula.VNumber(80.0),
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
      SmlThemeFontMap::empty(),
      max_digit_width_px=7.0,
    ),
  )
  assert_true(svg.contains("class=\"pivot-page-fields\""))
  assert_true(svg.contains(">Product<"))
  assert_true(svg.contains(">Apple<"))
  assert_true(svg.contains("data-ooxml-autofilter=\"button\""))
  assert_true(
    svg.contains(
      "<rect x=\"200\" y=\"20\" width=\"100\" height=\"60\" fill=\"none\" stroke=\"#808080\"",
    ),
  )
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
    cache_hierarchies: None,
    kpis: None,
    tuple_cache: None,
    calculated_items: None,
    calculated_members: None,
    dimensions: None,
    measure_groups: None,
    maps: None,
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
    formats: None,
    conditional_formats: None,
    chart_formats: None,
    pivot_hierarchies: None,
    row_hierarchies_usage: None,
    col_hierarchies_usage: None,
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
  let mdw = 10.0
  let overflow_w = column_width_to_pixels(
    default_render_options().default_column_width,
    mdw_px=mdw,
  )
  let layout = {
    ..pivot_test_layout(),
    total_width: 20.0,
    column_positions: [0.0],
    column_widths: [20.0],
    column_count: 1,
  }
  let svg = pivot_test_svg(
    render_pivot_overlay(
      pivot,
      layout,
      default_render_options(),
      [],
      [],
      None,
      None,
      SmlThemeColorMap::empty(),
      SmlThemeFontMap::empty(),
      max_digit_width_px=mdw,
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
      "<rect x=\"0\" y=\"0\" width=\"" +
      format_d(20.0 + overflow_w * 3.0) +
      "\" height=\"100\" fill=\"none\" stroke=\"#808080\"",
    ),
  )
}
