///|
/// Part 1 §18.18.17 ST_DataConsolidateFunction — the eleven
/// consolidation functions referenced by `dataField/@subtotal`
/// (§18.10.1.22) and by `pivotField/@*Subtotal` flags (§18.10.1.69).
/// Phase 1 implements all eleven; the materializer only uses the
/// `subtotal` choice on `dataField`, but the enum is shared with
/// downstream renderers that surface field-level subtotal markers.
pub(all) enum DataConsolidateFunction {
  /// §18.18.17 average — arithmetic mean of the numeric values.
  Average
  /// §18.18.17 count — COUNTA semantics: count every non-blank
  /// value in the bucket.
  Count
  /// §18.18.17 countNums — COUNT semantics: count only the values
  /// that successfully coerce to a number.
  CountNums
  /// §18.18.17 max — largest numeric value.
  Max
  /// §18.18.17 min — smallest numeric value.
  Min
  /// §18.18.17 product — repeated multiplication of the numeric
  /// values.
  Product
  /// §18.18.17 stdDev — sample standard deviation
  /// (sqrt(sum((x-mean)^2) / (n-1))).
  StdDev
  /// §18.18.17 stdDevp — population standard deviation
  /// (sqrt(sum((x-mean)^2) / n)).
  StdDevP
  /// §18.18.17 sum — sum of the numeric values.
  Sum
  /// §18.18.17 var — sample variance
  /// (sum((x-mean)^2) / (n-1)).
  Var
  /// §18.18.17 varp — population variance
  /// (sum((x-mean)^2) / n).
  VarP
} derive(Eq, Debug)

///|
/// Part 1 §18.18.17 — decode a ST_DataConsolidateFunction lexical
/// attribute value to a `DataConsolidateFunction`. The spec gives
/// `dataField/@subtotal` a default of `"sum"`, which the caller
/// applies before invoking this decoder.
pub fn DataConsolidateFunction::from_attr(
  value : String,
) -> DataConsolidateFunction raise @opc_errors.SchemaViolation {
  match value {
    "average" => Average
    "count" => Count
    "countNums" => CountNums
    "max" => Max
    "min" => Min
    "product" => Product
    "stdDev" => StdDev
    "stdDevp" => StdDevP
    "sum" => Sum
    "var" => Var
    "varp" => VarP
    _ =>
      raise @opc_errors.SchemaViolation(
        section=data_consolidate_function_section,
        path="dataField/@subtotal",
        reason="unknown ST_DataConsolidateFunction value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.1 ST_Axis — the four pivot regions a
/// `pivotField/@axis` attribute can resolve to. The materializer
/// derives the row / col / page placements from the
/// `<rowFields>`, `<colFields>`, `<pageFields>` collections rather
/// than the per-field axis, but the enum is decoded so renderers
/// can highlight the axis assignment when it differs.
pub(all) enum PivotAxis {
  /// §18.18.1 axisRow — field is placed on the row axis.
  AxisRow
  /// §18.18.1 axisCol — field is placed on the column axis.
  AxisCol
  /// §18.18.1 axisPage — field is placed in the report-filter
  /// (page) area.
  AxisPage
  /// §18.18.1 axisValues — field is placed in the values area.
  AxisValues
} derive(Eq, Debug)

///|
/// Part 1 §18.18.1 — decode an ST_Axis attribute. Returns `None`
/// when the attribute is absent (the caller distinguishes "no axis
/// assignment" from a hard schema violation).
pub fn PivotAxis::from_attr(
  value : String,
) -> PivotAxis raise @opc_errors.SchemaViolation {
  match value {
    "axisRow" => AxisRow
    "axisCol" => AxisCol
    "axisPage" => AxisPage
    "axisValues" => AxisValues
    _ =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.18.1",
        path="pivotField/@axis",
        reason="unknown ST_Axis value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.43 ST_ItemType — the discriminator on
/// `<item>` (§18.10.1.45) and `<i>` (§18.10.1.44) entries. Most
/// values are subtotal markers. The materializer keeps the
/// subtotal semantics in the PivotTable result SoT rather than
/// duplicating them in renderers.
pub(all) enum ItemType {
  /// §18.18.43 data — caption row/column for the data field name
  /// when there is more than one data field.
  Data
  /// §18.18.43 default — grand total marker.
  Default
  /// §18.18.43 sum — sum subtotal marker.
  Sum
  /// §18.18.43 countA — countA subtotal marker.
  CountA
  /// §18.18.43 avg — average subtotal marker.
  Avg
  /// §18.18.43 max — max subtotal marker.
  Max
  /// §18.18.43 min — min subtotal marker.
  Min
  /// §18.18.43 product — product subtotal marker.
  Product
  /// §18.18.43 count — count subtotal marker.
  Count
  /// §18.18.43 stdDev — sample standard deviation subtotal marker.
  StdDev
  /// §18.18.43 stdDevP — population standard deviation marker.
  StdDevP
  /// §18.18.43 var — sample variance subtotal marker.
  Var
  /// §18.18.43 varP — population variance subtotal marker.
  VarP
  /// §18.18.43 grand — grand total marker (for axes that emit
  /// multiple grand-total rows).
  Grand
  /// §18.18.43 blank — blank row separator.
  Blank
} derive(Eq, Debug)

///|
/// Part 1 §18.18.43 — decode an ST_ItemType lexical value. Raises
/// SchemaViolation for any non-spec value.
pub fn ItemType::from_attr(
  value : String,
) -> ItemType raise @opc_errors.SchemaViolation {
  match value {
    "data" => Data
    "default" => Default
    "sum" => Sum
    "countA" => CountA
    "avg" => Avg
    "max" => Max
    "min" => Min
    "product" => Product
    "count" => Count
    "stdDev" => StdDev
    "stdDevP" => StdDevP
    "var" => Var
    "varP" => VarP
    "grand" => Grand
    "blank" => Blank
    _ =>
      raise @opc_errors.SchemaViolation(
        section="Part 1 §18.18.43",
        path="item/@t",
        reason="unknown ST_ItemType value: " + value,
      )
  }
}

///|
/// Part 1 §18.10.1.50 m, §18.10.1.60 n, §18.10.1.2 b, §18.10.1.21 d,
/// §18.10.1.27 e, plus `<s>` string — the six lexical forms a
/// pivot-cache value can take. The variants preserve the
/// discriminator so renderers can tell apart `<n v="42"/>` from
/// `<s v="42"/>`, even though the aggregator only sees the
/// projected `@formula.FormulaValue`.
pub(all) enum SharedItemValue {
  /// `<s v="…"/>` — string value (no spec section number; the
  /// element name is the discriminator).
  SharedString(String)
  /// §18.10.1.60 n — numeric value carried as an IEEE 754 double.
  SharedNumber(Double)
  /// §18.10.1.2 b — boolean value.
  SharedBool(Bool)
  /// §18.10.1.21 d — ISO 8601 dateTime literal.
  SharedDate(String)
  /// §18.10.1.27 e — error literal (`#DIV/0!`, `#N/A`, …).
  SharedError(String)
  /// §18.10.1.50 m — missing / no value.
  SharedMissing
} derive(Eq, Debug)

///|
/// `SharedItemValue::to_formula_value` — projects a shared-items
/// value into the canonical `@formula.FormulaValue` consumed by
/// the aggregator. Date and error variants fall through to a
/// best-effort coercion: dates surface as their ISO text (so a
/// SUM aggregation reads `VEmpty` if it cannot parse the date),
/// errors surface as `VError` using the
/// `@formula.FormulaError::from_literal` table.
pub fn SharedItemValue::to_formula_value(
  self : SharedItemValue,
) -> @formula.FormulaValue {
  match self {
    SharedString(s) => @formula.VString(s)
    SharedNumber(n) => @formula.VNumber(n)
    SharedBool(b) => @formula.VBool(b)
    SharedDate(iso) => @formula.VString(iso)
    SharedError(lit) =>
      match @formula.FormulaError::from_literal(lit) {
        Some(err) => @formula.VError(err)
        None => @formula.VError(@formula.FormulaError::Value)
      }
    SharedMissing => @formula.VEmpty
  }
}

///|
/// Part 1 §18.10.1.90 sharedItems — the per-field shared values
/// plus the type-witness booleans the application is required to
/// keep current. Phase 1 surfaces every boolean so the renderer can
/// decide how to format the column header, but the materializer
/// only consumes `items`.
pub(all) struct SharedItems {
  /// §18.10.1.90 — `<s>`, `<n>`, `<d>`, `<b>`, `<e>`, `<m>` child
  /// values in document order.
  items : Array[SharedItemValue]
  /// §18.10.1.90 containsBlank — field has at least one blank value.
  contains_blank : Bool
  /// §18.10.1.90 containsDate — field has at least one date value.
  contains_date : Bool
  /// §18.10.1.90 containsInteger — every numeric value is integral.
  contains_integer : Bool
  /// §18.10.1.90 containsMixedTypes — field has more than one type.
  contains_mixed_types : Bool
  /// §18.10.1.90 containsNonDate — field has at least one non-date.
  contains_non_date : Bool
  /// §18.10.1.90 containsNumber — field has at least one number.
  contains_number : Bool
  /// §18.10.1.90 containsSemiMixedTypes — text mixed with other
  /// data and blanks.
  contains_semi_mixed_types : Bool
  /// §18.10.1.90 containsString — field has at least one string.
  contains_string : Bool
  /// §18.10.1.90 longText — string values exceed 255 chars.
  long_text : Bool
  /// §18.10.1.90 minValue — minimum numeric value seen.
  min_value : Double?
  /// §18.10.1.90 maxValue — maximum numeric value seen.
  max_value : Double?
  /// §18.10.1.90 minDate — minimum date value seen (ISO text).
  min_date : String?
  /// §18.10.1.90 maxDate — maximum date value seen (ISO text).
  max_date : String?
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.3 cacheField — typed view of a single
/// PivotCache field: name, optional format, optional calculated
/// formula, and the (always-present, possibly empty) shared items
/// table. The position in the parent `cache_fields` array is the
/// field index referenced by `dataField/@fld`, `rowFields/field/@x`,
/// `colFields/field/@x`, `pageField/@fld`, and the per-record
/// `<x v="…"/>` indices in `pivotCacheRecords`.
pub(all) struct CacheField {
  /// §18.10.1.3 @name — field name (required).
  name : String
  /// §18.10.1.3 @caption — display caption (optional).
  caption : String?
  /// §18.10.1.3 @numFmtId — index into Styles dxf number formats.
  num_fmt_id : Int?
  /// §18.10.1.3 @databaseField — true when the field is sourced
  /// from the underlying database, false for calculated fields.
  database_field : Bool
  /// §18.10.1.3 @formula — calculated-field expression text.
  formula : String?
  /// §18.10.1.90 sharedItems child (always populated; empty when
  /// the source XML omits the element).
  shared_items : SharedItems
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.95 worksheetSource — the worksheet location
/// from which the cache was built. All four attributes are
/// optional in the schema; in practice either `name` (a named
/// range) or (`sheet`, `ref`) are supplied.
pub(all) struct WorksheetSource {
  /// §18.10.1.95 @sheet — worksheet name.
  sheet : String?
  /// §18.10.1.95 @name — named-range name.
  name : String?
  /// §18.10.1.95 @ref — A1 range parsed via `@address`.
  ref_range : @address.CellRange?
  /// §18.10.1.95 @r:id — relationship id when the source lives in
  /// a related part.
  relationship_id : String?
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.7 cacheSource — the @type discriminator plus
/// the embedded worksheetSource child when `type=worksheet`. The
/// other variants (external / consolidation / scenario) only carry
/// metadata (`connectionId`) which we surface but do not consume.
pub(all) struct CacheSource {
  /// §18.18.75 ST_SourceType — `worksheet`, `external`,
  /// `consolidation`, `scenario`. Phase 1 only materializes
  /// `worksheet` and `consolidation` sources; the field is kept
  /// verbatim so renderers can branch on it.
  source_type : String
  /// §18.10.1.7 @connectionId — workbook connection id when
  /// `type=external`.
  connection_id : Int?
  /// §18.10.1.95 worksheetSource child when `type=worksheet`.
  worksheet_source : WorksheetSource?
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.67 pivotCacheDefinition — typed view of the
/// PivotCache definition part. Carries the cacheSource, the
/// ordered list of cacheFields, and the refresh-metadata
/// attributes the spec specifies on the root element.
pub(all) struct PivotCacheDefinition {
  /// §18.10.1.7 cacheSource child.
  cache_source : CacheSource
  /// §18.10.1.4 cacheFields child — one entry per source column,
  /// in document order.
  cache_fields : Array[CacheField]
  /// §18.10.1.67 @refreshedBy — name of the user who last
  /// refreshed the cache.
  refreshed_by : String?
  /// §18.10.1.67 @refreshedDateIso — ISO 8601 dateTime of the
  /// last refresh.
  refreshed_date_iso : String?
  /// §18.10.1.67 @recordCount — number of records (rows) in the
  /// cache.
  record_count : Int?
  /// §18.10.1.67 @createdVersion — application version that
  /// created the cache.
  created_version : Int?
  /// §18.10.1.67 @refreshedVersion — application version that
  /// last refreshed the cache.
  refreshed_version : Int?
  /// §18.10.1.67 @minRefreshableVersion — earliest application
  /// version that can refresh the cache.
  min_refreshable_version : Int?
  /// §18.10.1.67 @saveData — true when the records are persisted
  /// (default true).
  save_data : Bool
  /// §18.10.1.67 @invalid — true when the cache needs refresh.
  invalid : Bool
  /// §18.10.1.67 @refreshOnLoad — true when the app should refresh
  /// on workbook open.
  refresh_on_load : Bool
} derive(Eq, Debug)

///|
/// `PivotCacheDefinition::field_count` — convenience for callers
/// validating record row widths. Returns the size of the
/// `cache_fields` collection, which equals the expected number of
/// per-row cells in `pivotCacheRecords`.
pub fn PivotCacheDefinition::field_count(self : PivotCacheDefinition) -> Int {
  let mut count = 0
  for _ in self.cache_fields {
    count = count + 1
  }
  count
}

///|
/// Part 1 §18.10.1.68 — one cell inside a `<r>` row of the
/// pivotCacheRecords part. Either an `<x v=…>` shared-items index
/// or one of the inline `<s>`, `<n>`, `<d>`, `<b>`, `<e>`, `<m>`
/// literal cells.
pub(all) enum PivotRecordCell {
  /// `<x v="…"/>` — index into the matching `CacheField.shared_items.items`.
  RefShared(Int)
  /// `<s>` / `<n>` / `<d>` / `<b>` / `<e>` / `<m>` — inline literal.
  Inline(SharedItemValue)
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.68 — a single `<r>` row: one cell per
/// cacheField, in field order.
pub(all) struct PivotCacheRow {
  cells : Array[PivotRecordCell]
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.68 — the materialized pivotCacheRecords part.
pub(all) struct PivotCacheRecords {
  /// §18.10.1.68 @count — number of `<r>` rows (informational).
  count : Int?
  /// Per-row cells in document order.
  rows : Array[PivotCacheRow]
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.49 location — typed view of the PivotTable
/// rectangle in the worksheet plus the four offsets describing
/// where the header / data area / filter area begin within it.
pub(all) struct PivotLocation {
  /// §18.10.1.49 @ref — rectangle covering the entire PivotTable.
  ref_range : @address.CellRange
  /// §18.10.1.49 @firstHeaderRow — first row of the header,
  /// relative to the top-left of `ref_range`.
  first_header_row : Int
  /// §18.10.1.49 @firstDataRow — first row of the data area.
  first_data_row : Int
  /// §18.10.1.49 @firstDataCol — first column of the data area.
  first_data_col : Int
  /// §18.10.1.49 @rowPageCount — rows reserved for the filter area.
  row_page_count : Int
  /// §18.10.1.49 @colPageCount — columns reserved for the filter area.
  col_page_count : Int
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.45 item — one entry inside a pivotField's
/// `<items>` collection. The materializer only needs `@x` and
/// `@t` to skip subtotal / grand markers; `@h` and `@n` are
/// surfaced for renderers.
pub(all) struct PivotItemDef {
  /// §18.10.1.45 @x — index into the cacheField's shared items.
  /// `None` when the entry is a default / subtotal marker.
  item_index : Int?
  /// §18.10.1.45 @t — item type (default / sum / countA / …).
  item_type : ItemType?
  /// §18.10.1.45 @h — hidden flag.
  hidden : Bool
  /// §18.10.1.45 @n — user-supplied caption override.
  caption : String?
  /// §18.10.1.45 @s — character flag.
  character : Bool
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.69 pivotField — typed view of a single
/// PivotTable field. Phase 1 surfaces the axis assignment, the
/// data-field flag, and the items collection; the renderer-only
/// presentation flags (`compact`, `outline`, `subtotalTop`, …) are
/// preserved on the raw `@xml.Element` if a Phase 2 renderer needs
/// them.
pub(all) struct PivotFieldDef {
  /// §18.10.1.69 @axis — pivot region this field occupies (when
  /// the renderer surfaces it).
  axis : PivotAxis?
  /// §18.10.1.69 @dataField — true when the field is in the data
  /// region.
  data_field : Bool
  /// §18.10.1.69 @includeNewItemsInFilter — auto-include flag.
  include_new_items_in_filter : Bool
  /// §18.10.1.69 @name — user-supplied caption override.
  name : String?
  /// §18.10.1.69 @subtotalCaption — custom label text for subtotal rows.
  subtotal_caption : String?
  /// §18.10.1.69 @outline — outline layout flag. `subtotalTop`
  /// only controls row subtotal placement when this flag is true.
  outline : Bool
  /// §18.10.1.69 @subtotalTop — render subtotals above the group
  /// rather than below when outline layout is active.
  subtotal_top : Bool
  /// §18.10.1.69 @defaultSubtotal — display the default subtotal.
  default_subtotal : Bool
  /// §18.10.1.46 items child — per-field item dictionary in
  /// display order.
  items : Array[PivotItemDef]
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.22 dataField — one value-region field. The
/// `subtotal` choice is the §18.18.17 consolidation function the
/// materializer applies to the per-bucket values.
pub(all) struct DataFieldDef {
  /// §18.10.1.22 @name — display name for the data field.
  name : String?
  /// §18.10.1.22 @fld — index into cacheFields whose values are
  /// being summarised.
  fld : Int
  /// §18.10.1.22 @subtotal — consolidation function (default sum).
  subtotal : DataConsolidateFunction
  /// §18.10.1.22 @baseField — base-field index for
  /// `showDataAs` modes.
  base_field : Int?
  /// §18.10.1.22 @baseItem — base-item index for `showDataAs`.
  base_item : Int?
  /// §18.10.1.22 @numFmtId — number format index.
  num_fmt_id : Int?
  /// §18.10.1.22 @showDataAs — ST_ShowDataAs display-mode discriminator.
  show_data_as : @sml_types.ST_ShowDataAs?
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.62 pageField — one report-filter field entry.
/// When `item` is `Some(i)` the materializer filters the records
/// to those whose `@fld` cell value equals shared item `i`.
pub(all) struct PageFieldDef {
  /// §18.10.1.62 @fld — index into cacheFields.
  fld : Int
  /// §18.10.1.62 @item — shared-item index of the current
  /// selection (`None` means "(All)").
  item : Int?
  /// §18.10.1.62 @hier — hierarchy index (OLAP only).
  hier : Int?
  /// §18.10.1.62 @name — user-supplied caption override.
  name : String?
  /// §18.10.1.62 @cap — display caption.
  caption : String?
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.33 filter — one PivotTable advanced filter. The
/// child `<autoFilter>` is decoded to the shared SpreadsheetML AutoFilter
/// domain type; PivotTable code supplies only candidate values and does
/// not reimplement AutoFilter rule semantics.
pub(all) struct PivotFilterDef {
  /// §18.10.1.33 @fld — cache-field index to which the filter belongs.
  fld : Int
  /// §18.10.1.33 @mpFld — member-property field index for label filters.
  mp_fld : Int?
  /// §18.10.1.33 @type — ST_PivotFilterType lexical token.
  type_ : String
  /// §18.10.1.33 @evalOrder — zero-based evaluation order.
  eval_order : Int
  /// §18.10.1.33 @id — unique PivotTable filter id.
  id : Int
  /// §18.10.1.33 @iMeasureHier — OLAP measure hierarchy index.
  i_measure_hier : Int?
  /// §18.10.1.33 @iMeasureFld — relational value-filter measure field.
  i_measure_fld : Int?
  /// §18.10.1.33 @name — optional display name.
  name : String?
  /// §18.10.1.33 @description — optional description.
  description : String?
  /// §18.10.1.33 @stringValue1 — label-filter comparand.
  string_value1 : String?
  /// §18.10.1.33 @stringValue2 — label-filter second comparand.
  string_value2 : String?
  /// §18.10.1.33 autoFilter child.
  auto_filter : @domain.CT_AutoFilter
} derive(Eq, Debug)

///|
/// Runtime scope for a PivotTable AutoFilter candidate that may carry
/// resolved cell-format facts. These scopes are not ECMA-376 XML types;
/// they identify which pivot materialization candidate a caller is
/// describing when the source worksheet / conditional-format pipeline can
/// provide fill, font, or icon facts.
pub(all) enum PivotFilterCandidateScope {
  /// Candidate built from one original pivot-cache record index.
  PivotFilterRawRecord(Int)
  /// Candidate built from one materialized row-axis item index.
  PivotFilterRowAxis(Int)
  /// Candidate built from one materialized column-axis item index.
  PivotFilterColAxis(Int)
} derive(Eq, Debug)

///|
/// Runtime request for formatting facts attached to one AutoFilter
/// candidate cell. `value` is the materializer's projected candidate value;
/// facts providers must not use a different value as a second source of
/// truth. The materializer keeps this value when it constructs the
/// `@autofilter.FormattedCandidateRow`.
pub(all) struct PivotFilterFormatRequest {
  /// §18.10.1.33 `filter/@id`.
  filter_id : Int
  /// §18.10.1.33 `filter/@fld`.
  field_index : Int
  /// §18.10.1.33 `filter/@type`.
  filter_type : String
  /// Raw record, row-axis, or column-axis candidate identity.
  candidate : PivotFilterCandidateScope
  /// `autoFilter/filterColumn/@colId` projected by this candidate cell.
  column_id : Int
  /// Materializer-owned candidate value for this column.
  value : @formula.FormulaValue
} derive(Eq, Debug)

///|
/// Runtime facts used when PivotTable filters contain SpreadsheetML
/// `colorFilter` or `iconFilter` rules. The provider resolves formatting
/// from its own source of truth; PivotTable materialization only forwards
/// those facts to `spreadsheet_ml/autofilter`, which remains the single
/// comparison implementation.
pub(all) struct PivotFilterFormatFacts {
  dxf_formats : Array[@autofilter.FilterDxfFormat]
  cell_format_for : (PivotFilterFormatRequest) -> @autofilter.CandidateCellFormat?
}

///|
pub fn PivotFilterFormatFacts::none() -> PivotFilterFormatFacts {
  { dxf_formats: [], cell_format_for: fn(_) { None } }
}

///|
/// Part 1 §18.10.1.44 i — one row / column axis tuple inside
/// `rowItems` / `colItems`. The semantics are positional: the
/// `<x>` children represent item indices for the axis fields, and
/// `@r` reuses that many leading entries from the previous tuple
/// (so the renderer can avoid repeating values across grouped
/// rows / columns).
pub(all) struct PivotAxisItem {
  /// §18.10.1.44 @r — number of leading item indices to repeat
  /// from the previous tuple (default 0).
  repeat_count : Int
  /// §18.10.1.44 @t — item type (default / grand).
  item_type : ItemType?
  /// §18.10.1.44 @i — index into the dataFields collection when
  /// multiple data fields are present.
  data_field_index : Int?
  /// `<x v="…">` children — item indices for the axis fields.
  /// Combined with `repeat_count` against the previous tuple to
  /// produce the full axis key.
  item_indices : Array[Int]
} derive(Eq, Debug)

///|
/// Part 1 §18.10.1.73 pivotTableDefinition — typed view of the
/// entire PivotTable. Carries the layout choices (`row_grand_totals`,
/// `col_grand_totals`, `data_on_rows`), the rectangle (`location`),
/// the field dictionary (`pivot_fields`), the axis assignments
/// (`row_fields`, `col_fields`), the materialized row/col tuples
/// (`row_items`, `col_items`), the filter selections
/// (`page_fields`, `filters`), and the value-region definitions
/// (`data_fields`).
pub(all) struct PivotTableDefinition {
  /// §18.10.1.73 @name — required PivotTable name.
  name : String
  /// §18.10.1.73 @dataCaption — caption for the data area when
  /// the data fields occupy a single axis position.
  data_caption : String?
  /// §18.10.1.73 @cacheId — id of the pivotCacheDefinition.
  cache_id : Int?
  /// §18.10.1.73 @rowGrandTotals — emit a grand-total row
  /// (default true).
  row_grand_totals : Bool
  /// §18.10.1.73 @colGrandTotals — emit a grand-total column
  /// (default true).
  col_grand_totals : Bool
  /// §18.10.1.73 @dataOnRows — true when the data fields are
  /// placed on the row axis instead of the column axis.
  data_on_rows : Bool
  /// §18.10.1.49 location child.
  location : PivotLocation?
  /// §18.10.1.70 pivotFields child — one entry per cacheField.
  pivot_fields : Array[PivotFieldDef]
  /// §18.10.1.83 rowFields child — cacheField indices that
  /// partition the rows of the result. The sentinel `-2`
  /// (encoded `4294967294` in the source XML) denotes the
  /// data-field pseudo-position.
  row_fields : Array[Int]
  /// §18.10.1.14 colFields child — cacheField indices that
  /// partition the columns of the result.
  col_fields : Array[Int]
  /// §18.10.1.44 rowItems child — display ordering of the row
  /// axis tuples. The materializer expands these tuples into
  /// `PivotMaterialization.row_keys`.
  row_items : Array[PivotAxisItem]
  /// §18.10.1.17 colItems child — same for the column axis.
  col_items : Array[PivotAxisItem]
  /// §18.10.1.63 pageFields child.
  page_fields : Array[PageFieldDef]
  /// §18.10.1.34 filters child — advanced PivotTable filters.
  filters : Array[PivotFilterDef]
  /// §18.10.1.23 dataFields child.
  data_fields : Array[DataFieldDef]
  /// §18.10.1.74 pivotTableStyleInfo child — the referenced table-style
  /// name + band/header toggles.  `None` when absent.
  style_info : PivotTableStyleInfo?
} derive(Eq, Debug)

///|
/// §18.10.1.74 CT_PivotTableStyle — the `<pivotTableStyleInfo>` entry.
/// The built-in table-style colours (`PivotStyleMedium9`, …) are
/// application-defined and live outside the file, so the renderer
/// surfaces the style name + band/header toggles as spec-anchored
/// metadata (mirroring the iconSet handling) for a consumer to apply,
/// rather than fabricating stripe colours that the file does not carry.
pub(all) struct PivotTableStyleInfo {
  name : String?
  show_row_headers : Bool
  show_col_headers : Bool
  show_row_stripes : Bool
  show_col_stripes : Bool
  show_last_column : Bool
} derive(Eq, Debug)

///|
/// `PivotTableDefinition::aggregation_function_for` — convenience
/// accessor that returns the `DataConsolidateFunction` for the
/// data field at index `idx`, with the `Sum` default per
/// §18.10.1.22 when the index is out of range.
pub fn PivotTableDefinition::aggregation_function_for(
  self : PivotTableDefinition,
  idx : Int,
) -> DataConsolidateFunction {
  if idx < 0 {
    return Sum
  }
  let mut i = 0
  for entry in self.data_fields {
    if i == idx {
      return entry.subtotal
    }
    i = i + 1
  }
  Sum
}

///|
/// Pivot axis key — one cell's position along the row axis or the
/// column axis after the materializer extracts the per-record
/// item indices for the non-sentinel fields of that axis. Subtotal
/// and grand-total buckets carry sentinel variants so the result
/// table reads as a regular `Array[PivotResultCell]`.
pub(all) enum PivotAxisKey {
  /// `Items(indices)` — concrete axis tuple. `indices.length()`
  /// equals the number of non-sentinel entries in the
  /// corresponding `row_fields` / `col_fields`.
  Items(Array[Int])
  /// `RowSubtotal(prefix)` — default subtotal bucket for a row-axis
  /// field group. The prefix identifies the parent tuple being
  /// subtotaled; e.g. `[0]` for the first Region group in a
  /// `(Region, Product)` row axis.
  RowSubtotal(Array[Int])
  /// `RowGrand` — the grand-total bucket along the row axis.
  RowGrand
  /// `ColGrand` — the grand-total bucket along the column axis.
  ColGrand
} derive(Eq, Debug)

///|
/// `PivotAxisKey::serialize` — produce a stable string form used
/// as a HashMap key when interning row / col tuples. The encoding
/// joins each integer index with `|` and prefixes the variant with
/// `i`, `S`, `R`, or `C` so subtotal/grand sentinels can never
/// collide with a concrete tuple that happens to spell out the
/// same characters.
pub fn PivotAxisKey::serialize(self : PivotAxisKey) -> String {
  match self {
    Items(indices) => {
      let buf = StringBuilder::new()
      buf.write_string("i")
      let mut first = true
      for index in indices {
        if !first {
          buf.write_string("|")
        }
        buf.write_string(index.to_string())
        first = false
      }
      buf.to_string()
    }
    RowSubtotal(prefix) => {
      let buf = StringBuilder::new()
      buf.write_string("S")
      let mut first = true
      for index in prefix {
        if !first {
          buf.write_string("|")
        }
        buf.write_string(index.to_string())
        first = false
      }
      buf.to_string()
    }
    RowGrand => "R"
    ColGrand => "C"
  }
}

///|
/// `PivotAxisKey::is_grand` — true when this is one of the
/// grand-total sentinels. Useful for renderers that paint the
/// grand row / column differently.
pub fn PivotAxisKey::is_grand(self : PivotAxisKey) -> Bool {
  match self {
    RowGrand => true
    ColGrand => true
    _ => false
  }
}

///|
/// One cell in the materialized PivotTable: identified by its
/// row axis key, column axis key, and the index into the
/// `data_fields` collection. `aggregated_value` is the result of
/// applying the data field's `subtotal` consolidation function to
/// the bucket of values picked up from the cached records.
pub(all) struct PivotResultCell {
  row_key : PivotAxisKey
  col_key : PivotAxisKey
  data_field_index : Int
  aggregated_value : @formula.FormulaValue
} derive(Eq, Debug)

///|
/// Output of `materialize_pivot_table`. `row_keys` and `col_keys`
/// follow §18.10.1.44 `rowItems` / `colItems` when present, falling
/// back to record-discovery order otherwise. `cells` carries one
/// entry per `(row_key, col_key, data_field_index)` combination —
/// the renderer can index into it via `find()` or scan it linearly.
pub(all) struct PivotMaterialization {
  row_keys : Array[PivotAxisKey]
  col_keys : Array[PivotAxisKey]
  cells : Array[PivotResultCell]
  data_field_count : Int
} derive(Eq, Debug)

///|
/// Workbook/context-facing bundle for a PivotTable after cache decoding and
/// materialization. This package owns the bundle so formula lookup and
/// rendering consume the same `(definition, cache, materialization)` source
/// instead of carrying parallel viewer-only copies.
pub(all) struct MaterializedPivotTable {
  definition : PivotTableDefinition
  cache : PivotCacheDefinition
  materialization : PivotMaterialization
} derive(Eq, Debug)

///|
/// `PivotMaterialization::find` — linear lookup for a specific
/// `(row_key, col_key, data_field_index)` cell. Returns `None`
/// when the combination is absent (the materializer only emits a
/// cell when at least one record falls in the bucket; empty
/// buckets are dropped to keep the array sparse).
pub fn PivotMaterialization::find(
  self : PivotMaterialization,
  row_key : PivotAxisKey,
  col_key : PivotAxisKey,
  data_field_index : Int,
) -> PivotResultCell? {
  find_pivot_result_cell(self.cells, row_key, col_key, data_field_index)
}

///|
/// Package-local cell lookup shared by public materialization lookup and
/// display transforms. Keep the `(row_key, col_key, data_field_index)`
/// identity test in one place so value rendering and formula lookup do
/// not grow parallel match logic.
fn find_pivot_result_cell(
  cells : Array[PivotResultCell],
  row_key : PivotAxisKey,
  col_key : PivotAxisKey,
  data_field_index : Int,
) -> PivotResultCell? {
  for cell in cells {
    if cell.data_field_index == data_field_index &&
      cell.row_key == row_key &&
      cell.col_key == col_key {
      return Some(cell)
    }
  }
  None
}

///|
/// §18.18.17 — return the canonical "Sum"/"Count"/… prefix used by
/// spreadsheet applications when auto-naming a data field.
pub fn consolidate_function_prefix(fn_ : DataConsolidateFunction) -> String {
  match fn_ {
    Sum => "Sum"
    Average => "Average"
    Count => "Count"
    CountNums => "Count"
    Max => "Max"
    Min => "Min"
    Product => "Product"
    StdDev => "StdDev"
    StdDevP => "StdDevp"
    Var => "Var"
    VarP => "Varp"
  }
}

///|
/// Format a double using the PivotTable renderer's General-format
/// heuristic: drop the fractional component when the value is integral.
pub fn format_pivot_number(value : Double) -> String {
  if value == value.to_int().to_double() && value.abs() < 1.0e15 {
    value.to_int().to_string()
  } else {
    value.to_string()
  }
}

///|
/// Project a shared-items value into its PivotTable display caption.
pub fn shared_item_value_to_caption(value : SharedItemValue) -> String {
  match value {
    SharedString(s) => s
    SharedNumber(n) => format_pivot_number(n)
    SharedBool(b) => if b { "TRUE" } else { "FALSE" }
    SharedDate(iso) => iso
    SharedError(lit) => lit
    SharedMissing => "(blank)"
  }
}

///|
/// Find the caption for a shared-items entry in cache field `field_idx`.
pub fn PivotCacheDefinition::shared_item_caption(
  self : PivotCacheDefinition,
  field_idx : Int,
  item_idx : Int,
) -> String {
  if field_idx < 0 || field_idx >= self.cache_fields.length() {
    return ""
  }
  let items = self.cache_fields[field_idx].shared_items.items
  if item_idx < 0 || item_idx >= items.length() {
    return ""
  }
  shared_item_value_to_caption(items[item_idx])
}

///|
/// §18.10.1.22 — display name for one data field. The `@name`
/// attribute overrides; fallback uses the source cache field name
/// prefixed by the consolidation function.
pub fn data_field_display_name(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  data_field_index : Int,
) -> String? {
  if data_field_index < 0 || data_field_index >= definition.data_fields.length() {
    return None
  }
  let data_field = definition.data_fields[data_field_index]
  match data_field.name {
    Some(name) => Some(name)
    None => {
      let base = if data_field.fld >= 0 &&
        data_field.fld < cache.cache_fields.length() {
        cache.cache_fields[data_field.fld].name
      } else {
        ""
      }
      Some(consolidate_function_prefix(data_field.subtotal) + " of " + base)
    }
  }
}

///|
/// §18.10.1.22 — collect display names for every data field.
pub fn data_field_display_names(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
) -> Array[String] {
  let names : Array[String] = []
  for idx in 0..<definition.data_fields.length() {
    match data_field_display_name(definition, cache, idx) {
      Some(name) => names.push(name)
      None => ()
    }
  }
  names
}

///|
let data_consolidate_function_section : String = "Part 1 §18.18.17"

///|
let pivot_cache_definition_section : String = "Part 1 §18.10.1.67"

///|
let pivot_cache_records_section : String = "Part 1 §18.10.1.68"

///|
let pivot_table_definition_section : String = "Part 1 §18.10.1.73"

///|
/// §18.10.1.67 — citation helper exported so callers can include
/// the spec anchor in their own diagnostics.
pub fn pivot_cache_definition_part1_18_10_1_67_section_name() -> String {
  pivot_cache_definition_section
}

///|
/// §18.10.1.68 — citation helper for the pivotCacheRecords part.
pub fn pivot_cache_records_part1_18_10_1_68_section_name() -> String {
  pivot_cache_records_section
}

///|
/// §18.10.1.73 — citation helper for the pivotTableDefinition root.
pub fn pivot_table_definition_part1_18_10_1_73_section_name() -> String {
  pivot_table_definition_section
}

///|
/// §18.18.17 — citation helper for ST_DataConsolidateFunction.
pub fn data_consolidate_function_part1_18_18_17_section_name() -> String {
  data_consolidate_function_section
}
