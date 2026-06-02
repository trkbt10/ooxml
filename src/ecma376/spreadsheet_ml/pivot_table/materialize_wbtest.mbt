///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn parse_xml(source : String) -> @xml.Element {
  try! @xml.parse(bytes(source)).root
}

///|
fn n(value : Double) -> @formula.FormulaValue {
  @formula.FormulaValue::VNumber(value)
}

///|
fn s(value : String) -> @formula.FormulaValue {
  @formula.FormulaValue::VString(value)
}

///|
fn empty_value() -> @formula.FormulaValue {
  @formula.FormulaValue::VEmpty
}

///|
fn div_zero() -> @formula.FormulaValue {
  @formula.FormulaValue::VError(@formula.FormulaError::DivZero)
}

///|
/// `assert_fv_eq` — wrapper around `assert_true` so the per-cell
/// FormulaValue equality assertions stay readable. `@formula.FormulaValue`
/// derives Eq but not Show, so `assert_eq` cannot diff it.
fn assert_fv_eq(
  actual : @formula.FormulaValue,
  expected : @formula.FormulaValue,
) -> Unit raise {
  assert_true(actual == expected)
}

///|
/// `assert_fv_near` — compare a FormulaValue with a target Double
/// within an absolute tolerance. Used by the variance / standard
/// deviation tests where rounding makes exact equality fragile.
fn assert_fv_near(
  actual : @formula.FormulaValue,
  expected : Double,
  tolerance : Double,
) -> Unit raise {
  match actual {
    @formula.VNumber(value) => {
      let diff = if value > expected {
        value - expected
      } else {
        expected - value
      }
      assert_true(diff <= tolerance)
    }
    _ => assert_true(false)
  }
}

///|
fn cache_field_named(
  name : String,
  shared : Array[SharedItemValue],
) -> CacheField {
  let shared_items : SharedItems = {
    items: shared,
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
  {
    name,
    caption: None,
    num_fmt_id: None,
    database_field: true,
    formula: None,
    shared_items,
  }
}

///|
fn row_of(cells : Array[PivotRecordCell]) -> PivotCacheRow {
  { cells, }
}

///|
fn page_def(fld : Int, item : Int?) -> PageFieldDef {
  { fld, item, hier: None, name: None, caption: None }
}

///|
fn pivot_filter_def(
  fld : Int,
  type_ : String,
  auto_filter_xml : String,
) -> PivotFilterDef {
  {
    fld,
    mp_fld: None,
    type_,
    eval_order: 0,
    id: 1,
    i_measure_hier: None,
    i_measure_fld: None,
    name: None,
    description: None,
    string_value1: None,
    string_value2: None,
    auto_filter: try! @autofilter.parse_auto_filter(parse_xml(auto_filter_xml)),
  }
}

///|
fn pivot_candidate_format(
  value : @formula.FormulaValue,
  fill_color : String?,
  font_color : String?,
  icon_set : String?,
  icon_id : Int?,
) -> @autofilter.CandidateCellFormat {
  {
    value,
    fill_color,
    font_color,
    rich_text_font_colors: [],
    icon_set,
    icon_id,
  }
}

///|
fn pivot_item_def(item_index : Int, hidden : Bool) -> PivotItemDef {
  {
    item_index: Some(item_index),
    item_type: None,
    hidden,
    caption: None,
    character: false,
  }
}

///|
fn pivot_field_def(items : Array[PivotItemDef]) -> PivotFieldDef {
  {
    axis: None,
    data_field: false,
    include_new_items_in_filter: false,
    name: None,
    subtotal_top: true,
    default_subtotal: true,
    items,
  }
}

///|
fn data_def(fld : Int, subtotal : DataConsolidateFunction) -> DataFieldDef {
  {
    name: None,
    fld,
    subtotal,
    base_field: None,
    base_item: None,
    num_fmt_id: None,
    show_data_as: None,
  }
}

///|
fn data_def_show_as(
  fld : Int,
  subtotal : DataConsolidateFunction,
  mode : String,
) -> DataFieldDef {
  {
    ..data_def(fld, subtotal),
    show_data_as: Some(try! @sml_types.ST_ShowDataAs::parse(mode)),
  }
}

///|
fn data_def_show_as_base(
  fld : Int,
  subtotal : DataConsolidateFunction,
  mode : String,
  base_field : Int,
  base_item? : Int? = None,
) -> DataFieldDef {
  {
    ..data_def_show_as(fld, subtotal, mode),
    base_field: Some(base_field),
    base_item,
  }
}

///|
fn axis_item(
  indices : Array[Int],
  repeat_count : Int,
  item_type : ItemType?,
) -> PivotAxisItem {
  { repeat_count, item_type, data_field_index: None, item_indices: indices }
}

///|
fn definition(
  row_fields : Array[Int],
  col_fields : Array[Int],
  data_fields : Array[DataFieldDef],
  page_fields : Array[PageFieldDef],
  grand_rows : Bool,
  grand_cols : Bool,
) -> PivotTableDefinition {
  {
    name: "Test",
    data_caption: None,
    cache_id: Some(0),
    row_grand_totals: grand_rows,
    col_grand_totals: grand_cols,
    data_on_rows: false,
    location: None,
    pivot_fields: [],
    row_fields,
    col_fields,
    row_items: [],
    col_items: [],
    page_fields,
    filters: [],
    data_fields,
    style_info: None,
  }
}

///|
fn cache_with_fields(fields : Array[CacheField]) -> PivotCacheDefinition {
  {
    cache_source: {
      source_type: "worksheet",
      connection_id: None,
      worksheet_source: None,
    },
    cache_fields: fields,
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
}

///|
test "§18.10.1.67 decode_pivot_cache_definition reads refresh metadata" {
  let root = parse_xml(
    "<pivotCacheDefinition refreshedBy=\"alice\" refreshedDateIso=\"2026-05-19T12:00:00Z\" createdVersion=\"3\" refreshedVersion=\"6\" recordCount=\"2\" saveData=\"1\"><cacheSource type=\"worksheet\"><worksheetSource sheet=\"Sheet1\" ref=\"A1:B3\"/></cacheSource><cacheFields count=\"2\"><cacheField name=\"Region\"><sharedItems count=\"2\"><s v=\"East\"/><s v=\"West\"/></sharedItems></cacheField><cacheField name=\"Sales\"><sharedItems containsString=\"0\" containsNumber=\"1\" minValue=\"5\" maxValue=\"15\"/></cacheField></cacheFields></pivotCacheDefinition>",
  )
  let decoded = try! decode_pivot_cache_definition(
    @domain.CT_PivotCacheDefinition::new(root),
  )
  assert_eq(decoded.refreshed_by.unwrap(), "alice")
  assert_eq(decoded.refreshed_date_iso.unwrap(), "2026-05-19T12:00:00Z")
  assert_eq(decoded.created_version.unwrap(), 3)
  assert_eq(decoded.record_count.unwrap(), 2)
  assert_eq(decoded.cache_fields.length(), 2)
  assert_eq(decoded.cache_fields[0].name, "Region")
  assert_eq(decoded.cache_fields[0].shared_items.items.length(), 2)
  match decoded.cache_source.worksheet_source {
    Some(ws) => {
      assert_eq(ws.sheet.unwrap(), "Sheet1")
      assert_eq(ws.ref_range.unwrap().to_a1(), "A1:B3")
    }
    None => assert_true(false)
  }
}

///|
test "§18.10.1.3 cacheField decodes shared string and numeric items" {
  let root = parse_xml(
    "<pivotCacheDefinition><cacheSource type=\"worksheet\"><worksheetSource sheet=\"S\" ref=\"A1:A2\"/></cacheSource><cacheFields count=\"2\"><cacheField name=\"Region\"><sharedItems count=\"3\"><s v=\"East\"/><s v=\"West\"/><s v=\"North\"/></sharedItems></cacheField><cacheField name=\"Sales\"><sharedItems containsString=\"0\" containsNumber=\"1\" count=\"2\"><n v=\"10\"/><n v=\"20.5\"/></sharedItems></cacheField></cacheFields></pivotCacheDefinition>",
  )
  let decoded = try! decode_pivot_cache_definition(
    @domain.CT_PivotCacheDefinition::new(root),
  )
  let region = decoded.cache_fields[0]
  assert_eq(region.shared_items.items.length(), 3)
  match region.shared_items.items[1] {
    SharedString(text) => assert_eq(text, "West")
    _ => assert_true(false)
  }
  let sales = decoded.cache_fields[1]
  match sales.shared_items.items[0] {
    SharedNumber(value) => assert_eq(value, 10.0)
    _ => assert_true(false)
  }
  match sales.shared_items.items[1] {
    SharedNumber(value) => assert_eq(value, 20.5)
    _ => assert_true(false)
  }
}

///|
test "§18.10.1.68 decode_pivot_cache_records reads mixed cell forms" {
  let cache_fields = [
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Sales", []),
  ]
  let root = parse_xml(
    "<pivotCacheRecords count=\"3\"><r><x v=\"0\"/><n v=\"100\"/></r><r><x v=\"1\"/><n v=\"50.5\"/></r><r><x v=\"0\"/><n v=\"25\"/></r></pivotCacheRecords>",
  )
  let records = try! decode_pivot_cache_records(
    @domain.CT_PivotCacheRecords::new(root),
    cache_fields,
  )
  assert_eq(records.count.unwrap(), 3)
  assert_eq(records.rows.length(), 3)
  match records.rows[0].cells[0] {
    RefShared(index) => assert_eq(index, 0)
    _ => assert_true(false)
  }
  match records.rows[1].cells[1] {
    Inline(SharedNumber(value)) => assert_eq(value, 50.5)
    _ => assert_true(false)
  }
}

///|
test "materialize empty PivotTable yields no cells" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = { count: Some(0), rows: [] }
  let def = definition([0], [], [data_def(1, Sum)], [], true, true)
  let result = try! materialize_pivot_table(def, cache, records)
  assert_eq(result.row_keys.length(), 0)
  assert_eq(result.col_keys.length(), 0)
  assert_eq(result.cells.length(), 0)
  assert_eq(result.data_field_count, 1)
}

///|
test "materialize one row-field one data-field with Sum" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), Inline(SharedNumber(5.0))]),
    ],
  }
  let def = definition([0], [], [data_def(1, Sum)], [], false, false)
  let result = try! materialize_pivot_table(def, cache, records)
  assert_eq(result.row_keys.length(), 2)
  assert_eq(result.col_keys.length(), 1)
  let east_cell = result.find(Items([0]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(east_cell.aggregated_value, n(40.0))
  let west_cell = result.find(Items([1]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(west_cell.aggregated_value, n(25.0))
}

///|
test "materialize two row-fields one col-field with Sum" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Product", [SharedString("Bike"), SharedString("Helmet")]),
    cache_field_named("Year", [SharedString("2025"), SharedString("2026")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([
        RefShared(0),
        RefShared(0),
        RefShared(0),
        Inline(SharedNumber(100.0)),
      ]),
      row_of([
        RefShared(0),
        RefShared(0),
        RefShared(1),
        Inline(SharedNumber(120.0)),
      ]),
      row_of([
        RefShared(0),
        RefShared(1),
        RefShared(0),
        Inline(SharedNumber(40.0)),
      ]),
      row_of([
        RefShared(1),
        RefShared(0),
        RefShared(0),
        Inline(SharedNumber(50.0)),
      ]),
    ],
  }
  let def = definition([0, 1], [2], [data_def(3, Sum)], [], false, false)
  let result = try! materialize_pivot_table(def, cache, records)
  // East/Bike has both 2025 (100) and 2026 (120); East/Helmet has
  // 2025 (40); West/Bike has 2025 (50).
  let east_bike_2025 = result.find(Items([0, 0]), Items([0]), 0).unwrap()
  assert_fv_eq(east_bike_2025.aggregated_value, n(100.0))
  let east_bike_2026 = result.find(Items([0, 0]), Items([1]), 0).unwrap()
  assert_fv_eq(east_bike_2026.aggregated_value, n(120.0))
  let east_helmet_2025 = result.find(Items([0, 1]), Items([0]), 0).unwrap()
  assert_fv_eq(east_helmet_2025.aggregated_value, n(40.0))
  let west_bike_2025 = result.find(Items([1, 0]), Items([0]), 0).unwrap()
  assert_fv_eq(west_bike_2025.aggregated_value, n(50.0))
}

///|
test "§18.10.1.44 rowItems and colItems order materialized axis keys" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("North"), SharedString("South")]),
    cache_field_named("Product", [SharedString("Apple"), SharedString("Bread")]),
    cache_field_named("Year", [SharedString("2025"), SharedString("2026")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([
        RefShared(0),
        RefShared(0),
        RefShared(0),
        Inline(SharedNumber(10.0)),
      ]),
      row_of([
        RefShared(1),
        RefShared(0),
        RefShared(1),
        Inline(SharedNumber(20.0)),
      ]),
      row_of([
        RefShared(1),
        RefShared(1),
        RefShared(0),
        Inline(SharedNumber(30.0)),
      ]),
      row_of([
        RefShared(0),
        RefShared(1),
        RefShared(1),
        Inline(SharedNumber(40.0)),
      ]),
    ],
  }
  let def = {
    ..definition([0, 1], [2], [data_def(3, Sum)], [], false, false)
    // Deliberately different from record-discovery order. The second
    // row item uses §18.10.1.44 @r=1 to repeat the leading Region
    // item from the previous tuple.
    ,
    row_items: [
      axis_item([1, 0], 0, None),
      axis_item([1], 1, None),
      axis_item([0, 1], 0, None),
      axis_item([0, 0], 0, None),
    ],
    col_items: [axis_item([1], 0, None), axis_item([0], 0, None)],
  }
  let result = try! materialize_pivot_table(def, cache, records)
  assert_true(result.row_keys[0] == Items([1, 0]))
  assert_true(result.row_keys[1] == Items([1, 1]))
  assert_true(result.row_keys[2] == Items([0, 1]))
  assert_true(result.row_keys[3] == Items([0, 0]))
  assert_true(result.col_keys[0] == Items([1]))
  assert_true(result.col_keys[1] == Items([0]))
  let south_bread_2025 = result.find(Items([1, 1]), Items([0]), 0).unwrap()
  assert_fv_eq(south_bread_2025.aggregated_value, n(30.0))
  let north_apple_2025 = result.find(Items([0, 0]), Items([0]), 0).unwrap()
  assert_fv_eq(north_apple_2025.aggregated_value, n(10.0))
}

///|
test "§18.10.1.44 grand item position is preserved when totals enabled" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("North"), SharedString("South")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(2),
    rows: [
      row_of([RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(1), Inline(SharedNumber(20.0))]),
    ],
  }
  let def = {
    ..definition([0], [], [data_def(1, Sum)], [], true, false),
    row_items: [
      axis_item([], 0, Some(Grand)),
      axis_item([1], 0, None),
      axis_item([0], 0, None),
    ],
  }
  let result = try! materialize_pivot_table(def, cache, records)
  assert_true(result.row_keys[0] == RowGrand)
  assert_true(result.row_keys[1] == Items([1]))
  assert_true(result.row_keys[2] == Items([0]))
  let grand = result.find(RowGrand, result.col_keys[0], 0).unwrap()
  assert_fv_eq(grand.aggregated_value, n(30.0))
}

///|
test "materialize Count and Average across two data-fields" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), Inline(SharedNumber(40.0))]),
      row_of([RefShared(1), Inline(SharedNumber(60.0))]),
    ],
  }
  let def = definition(
    [0],
    [],
    [data_def(1, Count), data_def(1, Average)],
    [],
    false,
    false,
  )
  let result = try! materialize_pivot_table(def, cache, records)
  assert_eq(result.data_field_count, 2)
  let east_count = result.find(Items([0]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(east_count.aggregated_value, n(2.0))
  let east_avg = result.find(Items([0]), result.col_keys[0], 1).unwrap()
  assert_fv_eq(east_avg.aggregated_value, n(20.0))
  let west_count = result.find(Items([1]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(west_count.aggregated_value, n(2.0))
  let west_avg = result.find(Items([1]), result.col_keys[0], 1).unwrap()
  assert_fv_eq(west_avg.aggregated_value, n(50.0))
}

///|
test "§18.18.17 aggregate Sum returns 0 for empty bucket" {
  assert_fv_eq(aggregate([], Sum), n(0.0))
}

///|
test "§18.18.17 aggregate Sum sums numeric values" {
  assert_fv_eq(aggregate([n(1.0), n(2.5), n(-0.5)], Sum), n(3.0))
}

///|
test "§18.18.17 aggregate Count and CountNums separate text from numbers" {
  let values = [n(1.0), s("x"), n(2.0), s("3")]
  // Count = COUNTA = every non-blank / non-error cell (4)
  assert_fv_eq(aggregate(values, Count), n(4.0))
  // CountNums = COUNT = numbers + parseable text ("3") => 3
  assert_fv_eq(aggregate(values, CountNums), n(3.0))
}

///|
test "§18.18.17 aggregate Average returns #DIV/0! on empty" {
  assert_fv_eq(aggregate([], Average), div_zero())
}

///|
test "§18.18.17 aggregate Average divides Sum by CountNums" {
  let values = [n(2.0), n(4.0), n(6.0)]
  assert_fv_eq(aggregate(values, Average), n(4.0))
}

///|
test "§18.18.17 aggregate Min and Max ignore non-numeric values" {
  let values = [n(5.0), s("x"), n(-1.0), n(10.0), empty_value()]
  assert_fv_eq(aggregate(values, Min), n(-1.0))
  assert_fv_eq(aggregate(values, Max), n(10.0))
}

///|
test "§18.18.17 aggregate Min/Max return VEmpty on empty bucket" {
  assert_fv_eq(aggregate([], Min), empty_value())
  assert_fv_eq(aggregate([], Max), empty_value())
}

///|
test "§18.18.17 aggregate Product multiplies numeric values" {
  assert_fv_eq(aggregate([n(2.0), n(3.0), n(4.0)], Product), n(24.0))
  assert_fv_eq(aggregate([], Product), n(0.0))
}

///|
test "§18.18.17 aggregate StdDev and VarP over known population" {
  let values = [n(2.0), n(4.0), n(4.0), n(4.0), n(5.0), n(5.0), n(7.0), n(9.0)]
  // mean = 5, sum of squared deviations = 32
  // VarP = 32/8 = 4, StdDevP = 2
  // Var (sample) = 32/7 ≈ 4.5714, StdDev ≈ 2.1381
  assert_fv_near(aggregate(values, VarP), 4.0, 0.001)
  assert_fv_near(aggregate(values, StdDevP), 2.0, 0.001)
  assert_fv_near(aggregate(values, StdDev), 2.1381, 0.001)
}

///|
test "§18.10.1.62 pageField filter removes non-matching records" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Year", [SharedString("2025"), SharedString("2026")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(0), RefShared(1), Inline(SharedNumber(100.0))]),
      row_of([RefShared(1), RefShared(0), Inline(SharedNumber(20.0))]),
      row_of([RefShared(1), RefShared(1), Inline(SharedNumber(200.0))]),
    ],
  }
  // Filter Year = 2025 (shared item index 0)
  let def = definition(
    [0],
    [],
    [data_def(2, Sum)],
    [page_def(1, Some(0))],
    false,
    false,
  )
  let result = try! materialize_pivot_table(def, cache, records)
  assert_eq(result.row_keys.length(), 2)
  let east = result.find(Items([0]), result.col_keys[0], 0).unwrap()
  let west = result.find(Items([1]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(east.aggregated_value, n(10.0))
  assert_fv_eq(west.aggregated_value, n(20.0))
}

///|
test "§18.10.1.45 hidden pivot items remove matching records" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(3),
    rows: [
      row_of([RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(0), Inline(SharedNumber(5.0))]),
    ],
  }
  let def = {
    ..definition([0], [], [data_def(1, Sum)], [], false, false),
    pivot_fields: [
      pivot_field_def([pivot_item_def(0, false), pivot_item_def(1, true)]),
    ],
  }
  let result = try! materialize_pivot_table(def, cache, records)
  assert_eq(result.row_keys.length(), 1)
  assert_true(result.row_keys[0] == Items([0]))
  let east = result.find(Items([0]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(east.aggregated_value, n(15.0))
  assert_true(result.find(Items([1]), result.col_keys[0], 0) is None)
}

///|
test "§18.10.1.33 pivot filter decodes autoFilter child" {
  let root = parse_xml(
    "<pivotTableDefinition name=\"PT\" cacheId=\"0\"><location ref=\"A1:B3\" firstHeaderRow=\"0\" firstDataRow=\"1\" firstDataCol=\"1\"/><filters count=\"1\"><filter fld=\"0\" type=\"captionEqual\" evalOrder=\"2\" id=\"7\" stringValue1=\"East\"><autoFilter ref=\"A1\"><filterColumn colId=\"0\"><filters><filter val=\"East\"/></filters></filterColumn></autoFilter></filter></filters></pivotTableDefinition>",
  )
  let def = try! decode_pivot_table_definition(
    @domain.CT_pivotTableDefinition::new(root),
  )
  assert_eq(def.filters.length(), 1)
  let filter = def.filters[0]
  assert_eq(filter.fld, 0)
  assert_eq(filter.type_, "captionEqual")
  assert_eq(filter.eval_order, 2)
  assert_eq(filter.id, 7)
  assert_eq(filter.string_value1.unwrap(), "East")
  assert_eq(filter.auto_filter.filter_columns.length(), 1)
  assert_eq(filter.auto_filter.filter_columns[0].col_id, 0)
}

///|
test "§18.10.1.33 pivot caption autoFilter filters cache records through AutoFilter SoT" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let def = {
    ..definition([0], [], [data_def(1, Sum)], [], false, false),
    filters: [
      pivot_filter_def(
        0, "captionEqual", "<autoFilter ref=\"A1\"><filterColumn colId=\"0\"><filters><filter val=\"East\"/></filters></filterColumn></autoFilter>",
      ),
    ],
  }
  let result = try! materialize_pivot_table(def, cache, records)
  assert_eq(result.row_keys.length(), 1)
  assert_true(result.row_keys[0] == Items([0]))
  let east = result.find(Items([0]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(east.aggregated_value, n(40.0))
  assert_true(result.find(Items([1]), result.col_keys[0], 0) is None)
}

///|
test "§18.10.1.33 aggregate pivot filters project materialized measures through AutoFilter SoT" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(2),
    rows: [
      row_of([RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let def = {
    ..definition([0], [], [data_def(1, Sum)], [], false, false),
    filters: [
      pivot_filter_def(
        0, "sum", "<autoFilter ref=\"A1\"><filterColumn colId=\"0\"><customFilters><customFilter operator=\"greaterThan\" val=\"20\"/></customFilters></filterColumn></autoFilter>",
      ),
    ],
  }
  let result = try! materialize_pivot_table(def, cache, records)
  assert_eq(result.row_keys.length(), 1)
  assert_true(result.row_keys[0] == Items([1]))
  assert_true(result.find(Items([0]), result.col_keys[0], 0) is None)
  let west = result.find(Items([1]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(west.aggregated_value, n(40.0))
}

///|
test "§18.10.1.33 value pivot filters can filter column axis aggregate values" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Product", [SharedString("Bike"), SharedString("Helmet")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(0), RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(1), RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let def = {
    ..definition([0], [1], [data_def(2, Sum)], [], false, false),
    filters: [
      pivot_filter_def(
        1, "valueGreaterThan", "<autoFilter ref=\"A1\"><filterColumn colId=\"0\"><customFilters><customFilter operator=\"greaterThan\" val=\"40\"/></customFilters></filterColumn></autoFilter>",
      ),
    ],
  }
  let result = try! materialize_pivot_table(def, cache, records)
  assert_eq(result.col_keys.length(), 1)
  assert_true(result.col_keys[0] == Items([1]))
  assert_true(result.find(Items([0]), Items([0]), 0) is None)
  let east_helmet = result.find(Items([0]), Items([1]), 0).unwrap()
  let west_helmet = result.find(Items([1]), Items([1]), 0).unwrap()
  assert_fv_eq(east_helmet.aggregated_value, n(20.0))
  assert_fv_eq(west_helmet.aggregated_value, n(40.0))
}

///|
test "§18.10.1.33 pivot raw colorFilter uses supplied AutoFilter format facts" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let def = {
    ..definition([0], [], [data_def(1, Sum)], [], false, false),
    filters: [
      pivot_filter_def(
        0, "captionEqual", "<autoFilter ref=\"A1\"><filterColumn colId=\"0\"><colorFilter dxfId=\"1\" cellColor=\"1\"/></filterColumn></autoFilter>",
      ),
    ],
  }
  let without_facts = try! materialize_pivot_table(def, cache, records)
  assert_eq(without_facts.row_keys.length(), 0)
  let facts : PivotFilterFormatFacts = {
    dxf_formats: [{ dxf_id: 1, fill_color: Some("FFFF0000"), font_color: None }],
    cell_format_for: fn(request) {
      match request.candidate {
        PivotFilterRawRecord(0) | PivotFilterRawRecord(2) =>
          Some(
            pivot_candidate_format(
              request.value,
              Some("#ff0000"),
              None,
              None,
              None,
            ),
          )
        PivotFilterRawRecord(_) =>
          Some(
            pivot_candidate_format(
              request.value,
              Some("#00ff00"),
              None,
              None,
              None,
            ),
          )
        _ => None
      }
    },
  }
  let result = try! materialize_pivot_table_with_filter_formats(
    def, cache, records, facts,
  )
  assert_eq(result.row_keys.length(), 1)
  assert_true(result.row_keys[0] == Items([0]))
  let east = result.find(Items([0]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(east.aggregated_value, n(40.0))
  assert_true(result.find(Items([1]), result.col_keys[0], 0) is None)
}

///|
test "§18.10.1.33 row-axis aggregate font colorFilter uses supplied facts" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(2),
    rows: [
      row_of([RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let def = {
    ..definition([0], [], [data_def(1, Sum)], [], false, false),
    filters: [
      pivot_filter_def(
        0, "sum", "<autoFilter ref=\"A1\"><filterColumn colId=\"0\"><colorFilter dxfId=\"2\" cellColor=\"0\"/></filterColumn></autoFilter>",
      ),
    ],
  }
  let facts : PivotFilterFormatFacts = {
    dxf_formats: [{ dxf_id: 2, fill_color: None, font_color: Some("112233") }],
    cell_format_for: fn(request) {
      match request.candidate {
        PivotFilterRowAxis(1) =>
          Some(
            pivot_candidate_format(
              request.value,
              None,
              Some("#112233"),
              None,
              None,
            ),
          )
        PivotFilterRowAxis(_) =>
          Some(
            pivot_candidate_format(
              request.value,
              None,
              Some("#445566"),
              None,
              None,
            ),
          )
        _ => None
      }
    },
  }
  let result = try! materialize_pivot_table_with_filter_formats(
    def, cache, records, facts,
  )
  assert_eq(result.row_keys.length(), 1)
  assert_true(result.row_keys[0] == Items([1]))
  assert_true(result.find(Items([0]), result.col_keys[0], 0) is None)
  let west = result.find(Items([1]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(west.aggregated_value, n(40.0))
}

///|
test "§18.10.1.33 column-axis aggregate iconFilter uses supplied facts" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Product", [SharedString("Bike"), SharedString("Helmet")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(0), RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(1), RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let def = {
    ..definition([0], [1], [data_def(2, Sum)], [], false, false),
    filters: [
      pivot_filter_def(
        1, "valueGreaterThan", "<autoFilter ref=\"A1\"><filterColumn colId=\"0\"><iconFilter iconSet=\"3TrafficLights1\" iconId=\"2\"/></filterColumn></autoFilter>",
      ),
    ],
  }
  let facts : PivotFilterFormatFacts = {
    dxf_formats: [],
    cell_format_for: fn(request) {
      match request.candidate {
        PivotFilterColAxis(1) =>
          Some(
            pivot_candidate_format(
              request.value,
              None,
              None,
              Some("3TrafficLights1"),
              Some(2),
            ),
          )
        PivotFilterColAxis(_) =>
          Some(
            pivot_candidate_format(
              request.value,
              None,
              None,
              Some("3TrafficLights1"),
              Some(1),
            ),
          )
        _ => None
      }
    },
  }
  let result = try! materialize_pivot_table_with_filter_formats(
    def, cache, records, facts,
  )
  assert_eq(result.col_keys.length(), 1)
  assert_true(result.col_keys[0] == Items([1]))
  assert_true(result.find(Items([0]), Items([0]), 0) is None)
  let east_helmet = result.find(Items([0]), Items([1]), 0).unwrap()
  let west_helmet = result.find(Items([1]), Items([1]), 0).unwrap()
  assert_fv_eq(east_helmet.aggregated_value, n(20.0))
  assert_fv_eq(west_helmet.aggregated_value, n(40.0))
}

///|
test "§18.10.1.33 calculated aggregate filter uses calculated-field SoT" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Units", []),
    cache_field_named("Price", []),
    calc_cache_field("Revenue", "Units*Price"),
  ])
  let records : PivotCacheRecords = {
    count: Some(3),
    rows: [
      row_of([
        RefShared(0),
        Inline(SharedNumber(2.0)),
        Inline(SharedNumber(10.0)),
      ]),
      row_of([
        RefShared(0),
        Inline(SharedNumber(3.0)),
        Inline(SharedNumber(10.0)),
      ]),
      row_of([
        RefShared(1),
        Inline(SharedNumber(1.0)),
        Inline(SharedNumber(20.0)),
      ]),
    ],
  }
  let def = {
    ..definition([0], [], [data_def(3, Sum)], [], false, false),
    filters: [
      pivot_filter_def(
        0, "sum", "<autoFilter ref=\"A1\"><filterColumn colId=\"0\"><customFilters><customFilter operator=\"greaterThan\" val=\"75\"/></customFilters></filterColumn></autoFilter>",
      ),
    ],
  }
  let result = try! materialize_pivot_table(def, cache, records)
  assert_eq(result.row_keys.length(), 1)
  assert_true(result.row_keys[0] == Items([0]))
  let east = result.find(Items([0]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(east.aggregated_value, n(100.0))
  assert_true(result.find(Items([1]), result.col_keys[0], 0) is None)
}

///|
test "§18.10.1.33 calculated aggregate filter honors iMeasureFld data-field index" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Units", []),
    cache_field_named("Price", []),
    calc_cache_field("Revenue", "Units*Price"),
  ])
  let records : PivotCacheRecords = {
    count: Some(3),
    rows: [
      row_of([
        RefShared(0),
        Inline(SharedNumber(2.0)),
        Inline(SharedNumber(10.0)),
      ]),
      row_of([
        RefShared(0),
        Inline(SharedNumber(3.0)),
        Inline(SharedNumber(10.0)),
      ]),
      row_of([
        RefShared(1),
        Inline(SharedNumber(1.0)),
        Inline(SharedNumber(20.0)),
      ]),
    ],
  }
  let filter = {
    ..pivot_filter_def(
      0, "sum", "<autoFilter ref=\"A1\"><filterColumn colId=\"0\"><customFilters><customFilter operator=\"greaterThan\" val=\"75\"/></customFilters></filterColumn></autoFilter>",
    ),
    i_measure_fld: Some(1),
  }
  let def = {
    ..definition(
      [0],
      [],
      [data_def(1, Sum), data_def(3, Sum)],
      [],
      false,
      false,
    ),
    filters: [filter],
  }
  let result = try! materialize_pivot_table(def, cache, records)
  assert_eq(result.row_keys.length(), 1)
  assert_true(result.row_keys[0] == Items([0]))
  assert_true(result.find(Items([1]), result.col_keys[0], 1) is None)
  let east_units = result.find(Items([0]), result.col_keys[0], 0).unwrap()
  let east_revenue = result.find(Items([0]), result.col_keys[0], 1).unwrap()
  assert_fv_eq(east_units.aggregated_value, n(5.0))
  assert_fv_eq(east_revenue.aggregated_value, n(100.0))
}

///|
test "§18.10.1.73 row/col grand totals appended as sentinel keys" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Product", [SharedString("Bike"), SharedString("Helmet")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(0), RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(1), RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let def = definition([0], [1], [data_def(2, Sum)], [], true, true)
  let result = try! materialize_pivot_table(def, cache, records)
  // Both grand sentinels present + 2 row keys + 2 col keys.
  assert_eq(result.row_keys.length(), 3)
  assert_eq(result.col_keys.length(), 3)
  // Row grand for col Bike = 10 + 30 = 40
  let row_grand_bike = result.find(RowGrand, Items([0]), 0).unwrap()
  assert_fv_eq(row_grand_bike.aggregated_value, n(40.0))
  // Col grand for row East = 10 + 20 = 30
  let col_grand_east = result.find(Items([0]), ColGrand, 0).unwrap()
  assert_fv_eq(col_grand_east.aggregated_value, n(30.0))
  // Overall grand = 100
  let overall = result.find(RowGrand, ColGrand, 0).unwrap()
  assert_fv_eq(overall.aggregated_value, n(100.0))
}

///|
test "§18.10.1.22 showDataAs percentage modes use materialized totals" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Product", [SharedString("Bike"), SharedString("Helmet")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(0), RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(1), RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let def = definition(
    [0],
    [1],
    [
      data_def_show_as(2, Sum, "percentOfRow"),
      data_def_show_as(2, Sum, "percentOfCol"),
      data_def_show_as(2, Sum, "percentOfTotal"),
    ],
    [],
    true,
    true,
  )
  let result = try! materialize_pivot_table(def, cache, records)
  let east_bike_row = result.find(Items([0]), Items([0]), 0).unwrap()
  assert_fv_near(east_bike_row.aggregated_value, 10.0 / 30.0, 0.0001)
  let east_bike_col = result.find(Items([0]), Items([0]), 1).unwrap()
  assert_fv_near(east_bike_col.aggregated_value, 10.0 / 40.0, 0.0001)
  let east_bike_total = result.find(Items([0]), Items([0]), 2).unwrap()
  assert_fv_near(east_bike_total.aggregated_value, 10.0 / 100.0, 0.0001)
  let east_total_row = result.find(Items([0]), ColGrand, 0).unwrap()
  assert_fv_near(east_total_row.aggregated_value, 1.0, 0.0001)
  let bike_total_col = result.find(RowGrand, Items([0]), 1).unwrap()
  assert_fv_near(bike_total_col.aggregated_value, 1.0, 0.0001)
  let grand_total = result.find(RowGrand, ColGrand, 2).unwrap()
  assert_fv_near(grand_total.aggregated_value, 1.0, 0.0001)
}

///|
test "§18.10.1.22 showDataAs base and index modes use materialized cells" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Product", [SharedString("Bike"), SharedString("Helmet")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(0), RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(1), RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let def = definition(
    [0],
    [1],
    [
      data_def_show_as_base(2, Sum, "difference", 0, base_item=Some(0)),
      data_def_show_as_base(2, Sum, "percent", 0, base_item=Some(0)),
      data_def_show_as_base(2, Sum, "percentDiff", 0, base_item=Some(0)),
      data_def_show_as_base(2, Sum, "runTotal", 0),
      data_def_show_as(2, Sum, "index"),
    ],
    [],
    true,
    true,
  )
  let result = try! materialize_pivot_table(def, cache, records)
  let west_bike_diff = result.find(Items([1]), Items([0]), 0).unwrap()
  assert_fv_eq(west_bike_diff.aggregated_value, n(20.0))
  let west_bike_percent = result.find(Items([1]), Items([0]), 1).unwrap()
  assert_fv_near(west_bike_percent.aggregated_value, 3.0, 0.0001)
  let west_bike_percent_diff = result.find(Items([1]), Items([0]), 2).unwrap()
  assert_fv_near(west_bike_percent_diff.aggregated_value, 2.0, 0.0001)
  let west_bike_running = result.find(Items([1]), Items([0]), 3).unwrap()
  assert_fv_near(west_bike_running.aggregated_value, 40.0, 0.0001)
  let east_bike_index = result.find(Items([0]), Items([0]), 4).unwrap()
  assert_fv_near(
    east_bike_index.aggregated_value,
    10.0 * 100.0 / (30.0 * 40.0),
    0.0001,
  )
}

///|
test "§18.10.1.22 showDataAs percentages do not require visible grand totals" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Product", [SharedString("Bike"), SharedString("Helmet")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(0), RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(1), RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let def = definition(
    [0],
    [1],
    [
      data_def_show_as(2, Sum, "percentOfRow"),
      data_def_show_as(2, Sum, "percentOfCol"),
      data_def_show_as(2, Sum, "percentOfTotal"),
    ],
    [],
    false,
    false,
  )
  let result = try! materialize_pivot_table(def, cache, records)
  assert_true(result.find(Items([0]), ColGrand, 0) is None)
  assert_true(result.find(RowGrand, Items([0]), 1) is None)
  assert_true(result.find(RowGrand, ColGrand, 2) is None)
  let east_bike_row = result.find(Items([0]), Items([0]), 0).unwrap()
  assert_fv_near(east_bike_row.aggregated_value, 10.0 / 30.0, 0.0001)
  let east_bike_col = result.find(Items([0]), Items([0]), 1).unwrap()
  assert_fv_near(east_bike_col.aggregated_value, 10.0 / 40.0, 0.0001)
  let east_bike_total = result.find(Items([0]), Items([0]), 2).unwrap()
  assert_fv_near(east_bike_total.aggregated_value, 10.0 / 100.0, 0.0001)
}

///|
test "§18.18.17 unknown subtotal raises SchemaViolation" {
  let bad = try? DataConsolidateFunction::from_attr("notARealOne")
  assert_true(bad is Err(_))
}

///|
test "§18.10.1.73 missing @name raises SchemaViolation" {
  let root = parse_xml(
    "<pivotTableDefinition><location ref=\"A1:B2\"/></pivotTableDefinition>",
  )
  let result = try? decode_pivot_table_definition(
    @domain.CT_pivotTableDefinition::new(root),
  )
  assert_true(result is Err(_))
}

///|
test "§18.10.1.22 out-of-range fld raises SchemaViolation" {
  let cache = cache_with_fields([cache_field_named("OnlyField", [])])
  let records : PivotCacheRecords = { count: Some(0), rows: [] }
  // fld=5 but cacheFields only has 1 entry
  let def = definition([0], [], [data_def(5, Sum)], [], false, false)
  let result = try? materialize_pivot_table(def, cache, records)
  assert_true(result is Err(_))
}

///|
test "§18.10.1.73 decode_pivot_table_definition reads all axis lists" {
  let root = parse_xml(
    "<pivotTableDefinition name=\"P1\" dataCaption=\"Values\" cacheId=\"1\"><location ref=\"A3:C7\" firstHeaderRow=\"0\" firstDataRow=\"1\" firstDataCol=\"1\"/><pivotFields count=\"3\"><pivotField axis=\"axisRow\"/><pivotField axis=\"axisCol\"/><pivotField dataField=\"1\"/></pivotFields><rowFields count=\"1\"><field x=\"0\"/></rowFields><colFields count=\"1\"><field x=\"1\"/></colFields><dataFields count=\"1\"><dataField name=\"Sum of Sales\" fld=\"2\" subtotal=\"sum\"/></dataFields></pivotTableDefinition>",
  )
  let def = try! decode_pivot_table_definition(
    @domain.CT_pivotTableDefinition::new(root),
  )
  assert_eq(def.name, "P1")
  assert_eq(def.data_caption.unwrap(), "Values")
  assert_eq(def.cache_id.unwrap(), 1)
  assert_eq(def.row_fields.length(), 1)
  assert_eq(def.row_fields[0], 0)
  assert_eq(def.col_fields.length(), 1)
  assert_eq(def.col_fields[0], 1)
  assert_eq(def.data_fields.length(), 1)
  assert_eq(def.data_fields[0].fld, 2)
  match def.data_fields[0].subtotal {
    Sum => ()
    _ => assert_true(false)
  }
  assert_eq(def.pivot_fields.length(), 3)
  match def.pivot_fields[0].axis {
    Some(AxisRow) => ()
    _ => assert_true(false)
  }
  match def.location {
    Some(loc) => assert_eq(loc.ref_range.to_a1(), "A3:C7")
    None => assert_true(false)
  }
}

///|
test "§18.10.1.22 decode_pivot_table_definition reads showDataAs metadata" {
  let root = parse_xml(
    "<pivotTableDefinition name=\"P1\"><dataFields count=\"1\"><dataField name=\"Pct\" fld=\"2\" subtotal=\"sum\" showDataAs=\"percentOfTotal\" baseField=\"0\" baseItem=\"1\" numFmtId=\"10\"/></dataFields></pivotTableDefinition>",
  )
  let def = try! decode_pivot_table_definition(
    @domain.CT_pivotTableDefinition::new(root),
  )
  assert_eq(def.data_fields.length(), 1)
  let field = def.data_fields[0]
  assert_eq(field.show_data_as.unwrap().to_string(), "percentOfTotal")
  assert_eq(field.base_field.unwrap(), 0)
  assert_eq(field.base_item.unwrap(), 1)
  assert_eq(field.num_fmt_id.unwrap(), 10)
}

///|
test "§18.10.1.22 decode_pivot_table_definition validates showDataAs enum" {
  let root = parse_xml(
    "<pivotTableDefinition name=\"P1\"><dataFields count=\"1\"><dataField name=\"Bad\" fld=\"2\" showDataAs=\"not-a-mode\"/></dataFields></pivotTableDefinition>",
  )
  assert_true(
    (try? decode_pivot_table_definition(
      @domain.CT_pivotTableDefinition::new(root),
    ))
    is Err(@opc_errors.SchemaViolation(_)),
  )
}

///|
test "§18.18.43 ItemType::from_attr accepts every spec value" {
  let mappings : Array[(String, ItemType)] = [
    ("data", Data),
    ("default", Default),
    ("sum", Sum),
    ("countA", CountA),
    ("avg", Avg),
    ("max", Max),
    ("min", Min),
    ("product", Product),
    ("count", Count),
    ("stdDev", StdDev),
    ("stdDevP", StdDevP),
    ("var", Var),
    ("varP", VarP),
    ("grand", Grand),
    ("blank", Blank),
  ]
  for entry in mappings {
    let (lex, expected) = entry
    let got = try! ItemType::from_attr(lex)
    assert_true(got == expected)
  }
}

///|
test "PivotAxisKey::serialize distinguishes grand sentinels from items" {
  assert_eq(PivotAxisKey::Items([]).serialize(), "i")
  assert_eq(PivotAxisKey::Items([0]).serialize(), "i0")
  assert_eq(PivotAxisKey::Items([1, 2, 3]).serialize(), "i1|2|3")
  assert_eq(PivotAxisKey::RowGrand.serialize(), "R")
  assert_eq(PivotAxisKey::ColGrand.serialize(), "C")
}

///|
test "rowFields/-2 sentinel is parsed from XSD-unsigned representation" {
  let root = parse_xml(
    "<pivotTableDefinition name=\"P1\"><rowFields count=\"2\"><field x=\"0\"/><field x=\"4294967294\"/></rowFields><dataFields count=\"1\"><dataField fld=\"1\" subtotal=\"sum\"/></dataFields></pivotTableDefinition>",
  )
  let def = try! decode_pivot_table_definition(
    @domain.CT_pivotTableDefinition::new(root),
  )
  assert_eq(def.row_fields.length(), 2)
  assert_eq(def.row_fields[0], 0)
  assert_eq(def.row_fields[1], -2)
}

///|
test "§18.10.1.68 decoder expands records that omit calculated fields" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East")]),
    calc_cache_field("Revenue", "Units*Price"),
    cache_field_named("Units", []),
    cache_field_named("Price", []),
  ])
  let root = parse_xml(
    "<pivotCacheRecords count=\"1\"><r><x v=\"0\"/><n v=\"2\"/><n v=\"10\"/></r></pivotCacheRecords>",
  )
  let records = try! decode_pivot_cache_records(
    @domain.CT_PivotCacheRecords::new(root),
    cache.cache_fields,
  )
  assert_eq(records.rows.length(), 1)
  let cells = records.rows[0].cells
  assert_eq(cells.length(), 4)
  assert_true(cells[0] == RefShared(0))
  assert_true(cells[1] == Inline(SharedMissing))
  assert_true(cells[2] == Inline(SharedNumber(2.0)))
  assert_true(cells[3] == Inline(SharedNumber(10.0)))
}

///|
/// Build a calculated cache field (databaseField=0 + a formula).
fn calc_cache_field(name : String, formula : String) -> CacheField {
  {
    ..cache_field_named(name, []),
    database_field: false,
    formula: Some(formula),
  }
}

///|
/// §18.10.1.3 — a calculated field evaluates its formula over the
/// SUMMED operands of each cell (SUM(Units)·SUM(Price)), not per record.
test "calculated field = formula over summed operands" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Units", []),
    cache_field_named("Price", []),
    calc_cache_field("Revenue", "Units*Price"),
  ])
  // Records store only the three database fields (no Revenue cell).
  let records : PivotCacheRecords = {
    count: Some(3),
    rows: [
      row_of([
        RefShared(0),
        Inline(SharedNumber(2.0)),
        Inline(SharedNumber(10.0)),
      ]),
      row_of([
        RefShared(0),
        Inline(SharedNumber(3.0)),
        Inline(SharedNumber(10.0)),
      ]),
      row_of([
        RefShared(1),
        Inline(SharedNumber(1.0)),
        Inline(SharedNumber(20.0)),
      ]),
    ],
  }
  // The single data field references the calculated field (index 3).
  let def = definition([0], [], [data_def(3, Sum)], [], true, false)
  let result = try! materialize_pivot_table(def, cache, records)
  // East: SUM(Units)=5, SUM(Price)=20 → 100.  West: 1·20 = 20.
  let east = result.find(Items([0]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(east.aggregated_value, n(100.0))
  let west = result.find(Items([1]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(west.aggregated_value, n(20.0))
  // Row grand total: SUM(Units)=6, SUM(Price)=40 → 240 (formula over the
  // whole column's sums, the documented calc-field behaviour).
  let grand = result.find(RowGrand, result.col_keys[0], 0).unwrap()
  assert_fv_eq(grand.aggregated_value, n(240.0))
}

///|
/// §18.10.1.3 / §18.17.7 — calculated fields must use the same
/// SpreadsheetML built-in function registry as ordinary cell formulas.
test "calculated field formula can call SpreadsheetML builtins" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Units", []),
    cache_field_named("Price", []),
    calc_cache_field("Score", "SUM(Units,Price)"),
  ])
  let records : PivotCacheRecords = {
    count: Some(3),
    rows: [
      row_of([
        RefShared(0),
        Inline(SharedNumber(2.0)),
        Inline(SharedNumber(10.0)),
      ]),
      row_of([
        RefShared(0),
        Inline(SharedNumber(3.0)),
        Inline(SharedNumber(10.0)),
      ]),
      row_of([
        RefShared(1),
        Inline(SharedNumber(1.0)),
        Inline(SharedNumber(20.0)),
      ]),
    ],
  }
  let def = definition([0], [], [data_def(3, Sum)], [], true, false)
  let result = try! materialize_pivot_table(def, cache, records)
  let east = result.find(Items([0]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(east.aggregated_value, n(25.0))
  let west = result.find(Items([1]), result.col_keys[0], 0).unwrap()
  assert_fv_eq(west.aggregated_value, n(21.0))
  let grand = result.find(RowGrand, result.col_keys[0], 0).unwrap()
  assert_fv_eq(grand.aggregated_value, n(46.0))
}

///|
fn pivot_location(ref_text : String) -> PivotLocation {
  {
    ref_range: try! @address.CellRange::parse_a1(ref_text),
    first_header_row: 0,
    first_data_row: 1,
    first_data_col: 1,
    row_page_count: 0,
    col_page_count: 0,
  }
}

///|
/// §18.17.7 GETPIVOTDATA — lookup is backed by the same
/// `PivotMaterialization` cells used by rendering, not a second
/// aggregation path.
test "GETPIVOTDATA resolves through materialized PivotTable SoT" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Year", [SharedNumber(2026.0), SharedNumber(2027.0)]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(3),
    rows: [
      row_of([RefShared(0), RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(0), RefShared(1), Inline(SharedNumber(5.0))]),
      row_of([RefShared(1), RefShared(0), Inline(SharedNumber(7.0))]),
    ],
  }
  let def = {
    ..definition([0], [1], [data_def(2, Sum)], [], true, true),
    location: Some(pivot_location("A3:C8")),
  }
  let materialization = try! materialize_pivot_table(def, cache, records)
  let pivot : MaterializedPivotTable = {
    definition: def,
    cache,
    materialization,
  }
  let anchor = try! @address.CellAddress::parse_a1("A3")
  let exact = get_pivot_data([pivot], {
    data_field: "Sum of Sales",
    anchor,
    filters: [
      { field: "Region", item: "East" },
      { field: "Year", item: "2026" },
    ],
  })
  match exact {
    Some(value) => assert_fv_eq(value, n(10.0))
    None => assert_true(false)
  }
  let row_grand = get_pivot_data([pivot], {
    data_field: "Sales",
    anchor,
    filters: [{ field: "Region", item: "East" }],
  })
  match row_grand {
    Some(value) => assert_fv_eq(value, n(15.0))
    None => assert_true(false)
  }
  let overall = get_pivot_data([pivot], {
    data_field: "Sum of Sales",
    anchor,
    filters: [],
  })
  match overall {
    Some(value) => assert_fv_eq(value, n(22.0))
    None => assert_true(false)
  }
  let outside = get_pivot_data([pivot], {
    data_field: "Sum of Sales",
    anchor: try! @address.CellAddress::parse_a1("Z99"),
    filters: [],
  })
  assert_true(outside is None)
}

///|
test "GETPIVOTDATA returns showDataAs display values from PivotMaterialization" {
  let cache = cache_with_fields([
    cache_field_named("Region", [SharedString("East"), SharedString("West")]),
    cache_field_named("Product", [SharedString("Bike"), SharedString("Helmet")]),
    cache_field_named("Sales", []),
  ])
  let records : PivotCacheRecords = {
    count: Some(4),
    rows: [
      row_of([RefShared(0), RefShared(0), Inline(SharedNumber(10.0))]),
      row_of([RefShared(0), RefShared(1), Inline(SharedNumber(20.0))]),
      row_of([RefShared(1), RefShared(0), Inline(SharedNumber(30.0))]),
      row_of([RefShared(1), RefShared(1), Inline(SharedNumber(40.0))]),
    ],
  }
  let display_field = {
    ..data_def_show_as(2, Sum, "percentOfTotal"),
    name: Some("Pct of Total"),
  }
  let def = {
    ..definition([0], [1], [display_field], [], true, true),
    location: Some(pivot_location("A3:D8")),
  }
  let materialization = try! materialize_pivot_table(def, cache, records)
  let pivot : MaterializedPivotTable = {
    definition: def,
    cache,
    materialization,
  }
  let anchor = try! @address.CellAddress::parse_a1("A3")
  let value = get_pivot_data([pivot], {
    data_field: "Pct of Total",
    anchor,
    filters: [
      { field: "Region", item: "East" },
      { field: "Product", item: "Bike" },
    ],
  })
  match value {
    Some(actual) => assert_fv_near(actual, 0.1, 0.0001)
    None => assert_true(false)
  }
}

///|
/// §18.10.1.74 pivotTableStyleInfo — decode the style name + band /
/// header toggles so the renderer can surface them as metadata.
test "pivotTableStyleInfo decodes name and band toggles" {
  let root = parse_xml(
    "<pivotTableDefinition name=\"PT\" cacheId=\"0\"><location ref=\"A1:B3\" firstHeaderRow=\"1\" firstDataRow=\"1\" firstDataCol=\"1\"/><pivotTableStyleInfo name=\"PivotStyleMedium9\" showRowHeaders=\"1\" showColHeaders=\"1\" showRowStripes=\"1\" showColStripes=\"0\" showLastColumn=\"0\"/></pivotTableDefinition>",
  )
  let def = try! decode_pivot_table_definition(
    @domain.CT_pivotTableDefinition::new(root),
  )
  guard def.style_info is Some(si) else { fail("expected style_info") }
  assert_eq(si.name.unwrap(), "PivotStyleMedium9")
  assert_true(si.show_row_headers)
  assert_true(si.show_row_stripes)
  assert_true(!si.show_col_stripes)
  assert_true(!si.show_last_column)
}
