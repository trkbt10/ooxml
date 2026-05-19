# G8 — Pivot Table Materialization (Phase 1)

Tracks the Tier-2 gap "Pivot table materialization / aggregation" from
`.indexion/plans/shallow-audit/audit.md`. Depends on G2 (SST lookup),
G3 (date serial), G5 (cell value coercion), and G16 (cell address),
all completed.

This is Phase 1 of a multi-commit closure. Phase 1 covers the minimum
scope required to **materialize a non-OLAP PivotTable** from its
PivotCache: definition + records → 2-D `(row axis, col axis,
dataField)` matrix populated with `ST_DataConsolidateFunction`
aggregates. OLAP, hierarchies, calculated members, KPIs, grouping,
SmartTags, and PivotChart formats are deferred to Phase 2.

## Source sections

- Part 1 §18.10.1.67 `pivotCacheDefinition` — top-level cache part:
  `cacheSource`, `cacheFields`, refresh metadata (`refreshedBy`,
  `refreshedDateIso`, `recordCount`, `createdVersion`).
- Part 1 §18.10.1.7 `cacheSource` — `@type` (worksheet | external |
  consolidation | scenario) and the embedded `worksheetSource`
  (§18.10.1.95 — `@ref`, `@name`, `@sheet`).
- Part 1 §18.10.1.95 `worksheetSource` — A1 range / named-range
  reference into the workbook for the source data.
- Part 1 §18.10.1.4 `cacheFields` and §18.10.1.3 `cacheField` — a
  column in the source data with `@name`, `@numFmtId`,
  `@databaseField`, and an optional `<sharedItems>` child.
- Part 1 §18.10.1.90 `sharedItems` — the per-field shared values:
  `@containsString`, `@containsNumber`, `@containsInteger`,
  `@containsDate`, `@containsBlank`, `@containsSemiMixedTypes`,
  `@containsMixedTypes`, `@count`, `@minValue`, `@maxValue`,
  `@minDate`, `@maxDate`, and the value children `<s>` (string),
  `<n>` (numeric per §18.10.1.60), `<d>` (date per §18.10.1.21),
  `<b>` (bool per §18.10.1.2), `<e>` (error per §18.10.1.27),
  `<m>` (missing per §18.10.1.50).
- Part 1 §18.10.1.68 `pivotCacheRecords` — the materialized records
  table: `@count` and a sequence of `<r>` rows. Each `<r>` holds one
  child per cacheField: either an `<x v=...>` index into the
  matching field's shared items, or an inline literal (`<s>`, `<n>`,
  `<d>`, `<b>`, `<e>`, `<m>`).
- Part 1 §18.10.1.73 `pivotTableDefinition` — table layout: `@name`,
  `@dataCaption`, `@cacheId`, `@rowGrandTotals`, `@colGrandTotals`,
  plus the `<location>` (§18.10.1.49), `<pivotFields>`
  (§18.10.1.70), `<rowFields>` (§18.10.1.83), `<rowItems>`
  (§18.10.1.44 i), `<colFields>` (§18.10.1.14), `<colItems>`
  (§18.10.1.17 i), `<pageFields>` (§18.10.1.63), and `<dataFields>`
  (§18.10.1.23) children.
- Part 1 §18.10.1.22 `dataField` — one value-region field: `@name`,
  `@fld`, `@subtotal` (the consolidation function, default `sum`),
  `@baseField`, `@baseItem`, `@showDataAs`.
- Part 1 §18.10.1.29 `field` — one (row|col) axis pointer: `@x`
  (cacheFields index; `-2` is the "data" pseudo-field marking the
  position where the data-field captions are placed when there is
  more than one dataField).
- Part 1 §18.10.1.62 `pageField` — one filter-region field:
  `@fld`, `@item`, `@hier`, `@name`.
- Part 1 §18.18.17 `ST_DataConsolidateFunction` — the 11-value
  enumeration of aggregation functions consumed by `dataField`:
  `average`, `count`, `countNums`, `max`, `min`, `product`, `stdDev`,
  `stdDevp`, `sum`, `var`, `varp`.

## Functional requirements

### Requirement 1: typed PivotCacheDefinition decoder

The package shall expose
`decode_pivot_cache_definition(@domain.CT_PivotCacheDefinition)`
returning a typed `PivotCacheDefinition` carrying:

- `cache_source : CacheSource` — `type` discriminator and any
  embedded `WorksheetSource { sheet?, name?, ref? }`.
- `cache_fields : Array[CacheField]` — typed cache fields in document
  order (the position is the field index used by `rowFields`,
  `colFields`, `dataField/@fld`, and the per-record `<x>` indices).
- `refreshed_by : String?`, `refreshed_date_iso : String?`,
  `record_count : Int?`, `created_version : Int?`,
  `refreshed_version : Int?`, `min_refreshable_version : Int?`,
  `save_data : Bool` (default true).

Attribute parsing failures shall raise `@opc_errors.SchemaViolation`
with the offending attribute name.

### Requirement 2: typed CacheField decoder

Each `CacheField` shall carry:

- `name : String`
- `caption : String?`
- `num_fmt_id : Int?`
- `database_field : Bool` (default true)
- `formula : String?` (calculated-field text)
- `shared_items : SharedItems` (always populated; empty when the
  source XML omits the element)

`SharedItems` shall carry the §18.10.1.90 type-witness booleans
(`contains_string`, `contains_number`, `contains_integer`,
`contains_date`, `contains_blank`, `contains_semi_mixed_types`,
`contains_mixed_types`, `long_text`), the optional `min_value` /
`max_value` numerics, the optional `min_date` / `max_date` ISO
date-time text, and `items : Array[SharedItemValue]` decoded from
the `<s>` / `<n>` / `<d>` / `<b>` / `<e>` / `<m>` children in
document order.

### Requirement 3: SharedItemValue typed view

`SharedItemValue` is the union of the six pivotcache value forms
(§18.10.1.60 `n`, §18.10.1.21 `d`, §18.10.1.2 `b`, §18.10.1.27 `e`,
§18.10.1.50 `m`, plus `<s>` string). Each variant shall carry the
`@v` value when present, plus the shared per-item caption (`@c`)
and the `@u` (unused) / `@f` (calculated) / `@cp` (member-property
count) flags for downstream rendering — even though Phase 1 does
not use them.

The decoder shall promote each `SharedItemValue` to a canonical
`@formula.FormulaValue` via `shared_item_to_formula_value` so the
aggregator does not need to re-discriminate the variants.

### Requirement 4: PivotCacheRecords decoder

`decode_pivot_cache_records(@domain.CT_PivotCacheRecords,
Array[CacheField])` returns a `PivotCacheRecords` with `count : Int?`
and `rows : Array[PivotCacheRow]`. Each `PivotCacheRow` carries one
`PivotRecordCell` per cacheField, in field order, with two cases:

- `RefShared(item_index : Int)` — the `<x v=…>` form: an index into
  the corresponding `CacheField.shared_items.items` table.
- `Inline(SharedItemValue)` — an inline literal where the field
  does not use shared items.

A helper `pivot_record_cell_to_formula_value(cell, field)` shall
project a record cell back into its `@formula.FormulaValue` regardless
of whether the value is shared or inline. Out-of-range shared indices
shall raise `SchemaViolation` with the field name in the path.

### Requirement 5: PivotTableDefinition decoder

`decode_pivot_table_definition(@domain.CT_pivotTableDefinition)`
returns a `PivotTableDefinition` with:

- `name : String`, `data_caption : String?`, `cache_id : Int?`,
  `row_grand_totals : Bool` (default true), `col_grand_totals : Bool`
  (default true), `data_on_rows : Bool` (default false; from
  `@dataOnRows`).
- `location : PivotLocation?` — the §18.10.1.49 `<location>` payload
  if present (`ref` parsed via `@address.CellRange`, plus the four
  `firstHeaderRow` / `firstDataRow` / `firstDataCol` /
  `rowPageCount` / `colPageCount` integers).
- `pivot_fields : Array[PivotFieldDef]` — one per cacheField (in the
  same order as `cacheFields`); each carries `axis : PivotAxis?`
  (`AxisRow` / `AxisCol` / `AxisPage` / `AxisValues`, decoded per
  §18.18.1 ST_Axis), `data_field : Bool`, `include_new_items_in_filter
  : Bool`, plus the `<items>` child — each `<item>` has `@x`,
  `@t : ItemType?` (default | sum | countA | …), `@h` (hidden), `@s`
  (character), `@n` (caption).
- `row_fields : Array[Int]`, `col_fields : Array[Int]`,
  `page_fields : Array[PageFieldDef]` — the field indices placed on
  each axis, in display order. The value `-2` (encoded as the
  unsigned wraparound `4294967294`) denotes the data-field pseudo
  position.
- `row_items : Array[PivotAxisItem]`, `col_items : Array[PivotAxisItem]`
  — the §18.10.1.44 `<i>` rows / `<i>` cols sequences with `@r`
  (repeat count from prior), `@t : ItemType?`, `@i` (data-field
  index), and the `<x v="...">` item indices.
- `data_fields : Array[DataFieldDef]` — `name`, `fld`, `subtotal`
  (`ST_DataConsolidateFunction`, default `sum`), `base_field`,
  `base_item`.

### Requirement 6: ST_DataConsolidateFunction decoder

A `DataConsolidateFunction` enum shall carry the 11 §18.18.17 values
(`Average`, `Count`, `CountNums`, `Max`, `Min`, `Product`, `StdDev`,
`StdDevP`, `Sum`, `Var`, `VarP`) plus a `from_attr` decoder that
raises on out-of-vocabulary text.

### Requirement 7: pivot materialization

`materialize_pivot_table(definition : PivotTableDefinition,
cache : PivotCacheDefinition, records : PivotCacheRecords)`
shall return a `PivotMaterialization` whose body is a
`Array[PivotResultCell]`, one per `(row_axis_key, col_axis_key,
data_field_index)` combination, where:

- `row_axis_key` is the tuple of item indices for the rowFields
  (length = `definition.row_fields.length()`).
- `col_axis_key` is the tuple of item indices for the colFields.
- `data_field_index` is the position into `definition.data_fields`.

Each cell carries the `aggregated_value : @formula.FormulaValue`
computed from the records whose rowField / colField cell values
match the keys, applying the `dataField.subtotal` consolidation
function.

The materializer shall also expose:

- `row_keys : Array[PivotAxisKey]` — the distinct row-axis keys in
  the order they first appear in the records (insertion order, which
  matches the §18.10.1.45 `items` collection default).
- `col_keys : Array[PivotAxisKey]` — likewise for col-axis keys.
- Grand totals: when `row_grand_totals` is true, a single `RowGrand`
  pseudo-key shall appear at the end of `row_keys` with values
  aggregated over every row. Same for `col_grand_totals` →
  `ColGrand` pseudo-key.

### Requirement 8: aggregation functions

`aggregate(values : Array[@formula.FormulaValue], fn :
DataConsolidateFunction)` shall implement at minimum:

- `Sum` — `sum_of_numbers(values)`; returns `VNumber(0.0)` when no
  numeric values present (Excel reports a blank cell, modelled as
  `VEmpty`).
- `Count` — counts every non-blank value (COUNTA semantics per
  §18.18.17 note).
- `CountNums` — counts only `VNumber`, `VBool`, and `VString` values
  that successfully parse as a number (COUNT semantics).
- `Average` — `Sum / CountNums`; returns `VError(DivZero)` when the
  count is zero.
- `Max`, `Min` — over the numeric coercions; returns `VEmpty` on no
  numeric input.
- `Product` — repeated multiplication; returns `VNumber(0.0)` when no
  numeric input (Excel returns 0).
- `StdDev`, `StdDevP`, `Var`, `VarP` — sample / population standard
  deviation and variance over the numeric coercions, with the
  textbook formulas:
  * `Var = sum((x - mean)^2) / (n - 1)`
  * `VarP = sum((x - mean)^2) / n`
  * `StdDev = sqrt(Var)`, `StdDevP = sqrt(VarP)`
  Returns `VError(DivZero)` when the input is too small to define
  the divisor.

`Sum`, `Count`, `CountNums`, `Average`, `Min`, `Max`, `Product` are
the spec-cited "consolidation functions" the audit requires for the
Phase 1 minimum. `StdDev*` / `Var*` are included to cover the
remaining §18.18.17 values and round out the enum.

### Requirement 9: page-field filter pre-pass

Before aggregation, the materializer shall apply the pageField
filter: for each entry in `definition.page_fields` that has
`item : Some(i)` (i.e. a single concrete shared-item index), only
records whose corresponding field value matches that shared item
index shall be considered. `item: None` (the "(All)" selection per
§18.10.1.62) keeps every record.

### Requirement 10: schema-violation reporting

Every decoder, the materializer, and the aggregator shall raise
`@opc_errors.SchemaViolation` with the §-section anchor in `path`
when:

- An attribute marked required by the spec is missing
  (e.g. `pivotTableDefinition/@name`).
- An attribute value is outside the enumerated set
  (e.g. `dataField/@subtotal=foobar`).
- A `<r>` row in the records part has a different child count from
  the cacheFields list.
- A `dataField/@fld` index is out of range of the cacheFields list.

## Non-functional requirements

- All public types live in
  `src/ecma376/spreadsheet_ml/pivot_table/` and carry doc comments
  citing the specific §-section that defines each construct, so the
  indexion vocab gate sees them.
- `pub fn` bodies satisfy the indexion SHALLOW gate (>4 lines of
  non-trivial logic) so `spec align status --fail-on any` passes.
- White-box tests cover:
  * Empty PivotTable (zero records).
  * One rowField + one dataField with `sum`.
  * Two rowFields + one colField with `sum`, `count`, `average` on
    one shared-string field and one numeric field.
  * Shared-string field decoded from `<sharedItems>` + `<x>` indices
    in records.
  * pageField pre-pass.
  * Each of the eight Phase-1 aggregation functions (`Sum`, `Count`,
    `CountNums`, `Average`, `Min`, `Max`, `Product`, `StdDev`).
  * Schema-violation raises for unknown `subtotal`, missing `@name`,
    and out-of-range `fld`.

## Out of scope (Phase 2)

- OLAP cube data sources: `cacheHierarchies` / `cacheHierarchy`,
  `dimensions`, `measureGroup`, `members`, `kpi`, `mp`, `mpMap`,
  `mps`, `calculatedMember`, `tpl`, `tpls`, `tupleCache` — Phase 1
  emits `None` for these and refuses to materialize a pivot whose
  `cacheSource/@type` is not `worksheet`, `external`, or
  `consolidation`.
- Field grouping (`fieldGroup`, `discretePr`, `rangePr`, `groupItems`,
  `groupLevel`, `groupMember`) — Phase 1 treats grouped fields as a
  flat list of pre-grouped items.
- `formats`, `chartFormats`, `conditionalFormats` collections inside
  the pivot table — Phase 1 leaves these to the renderer and the
  G6 conditional formatting evaluator.
- `pivotTableStyleInfo` — purely presentation.
- `pivotHierarchies`, `rowHierarchiesUsage`, `colHierarchiesUsage` —
  OLAP only.
- `showDataAs` calculations (% of total, % of column, running total,
  etc. — §18.18.70). Phase 1 reads the attribute but the materializer
  applies only the raw consolidation function.
- Pivot-table conditional formatting (`pivot=true` on a
  `conditionalFormatting` block) — already partially handled by the
  G6 cfRule evaluator, but the cross-wiring through pivot positions
  is Phase 2.

## References

- `.indexion/plans/shallow-audit/audit.md` Tier 2 #10.
- `references/spec/part1/part1.full.txt` §18.10 (line ~89870+).
- `src/ecma376/spreadsheet_ml/cf_rule_eval/` — sibling pattern.
- `src/ecma376/spreadsheet_ml/domain/pivot_types.mbt` — existing
  CT_* wrappers consumed by this package.
