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
    data_fields,
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
