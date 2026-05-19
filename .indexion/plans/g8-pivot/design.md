# G8 — Design (Phase 1)

New package: `src/ecma376/spreadsheet_ml/pivot_table/`.

## File layout

```
pivot_table/
  moon.pkg                 -- depends on @xml, @opc_errors, @domain,
                              @address, @date_serial, @formula,
                              moonbitlang/core/strconv,
                              moonbitlang/core/hashmap
  types.mbt                -- typed enums + structs:
                              DataConsolidateFunction, PivotAxis,
                              ItemType, SharedItemValue,
                              SharedItems, CacheField,
                              WorksheetSource, CacheSource,
                              PivotCacheDefinition,
                              PivotRecordCell, PivotCacheRow,
                              PivotCacheRecords,
                              PivotLocation, PivotItemDef,
                              PivotFieldDef, DataFieldDef,
                              PageFieldDef, PivotAxisItem,
                              PivotTableDefinition,
                              PivotAxisKey, PivotResultCell,
                              PivotMaterialization
                              + from_attr methods for
                              DataConsolidateFunction (11-arm),
                              PivotAxis (4-arm), ItemType (12-arm).
                              + helpers SharedItemValue::to_formula_value,
                              PivotAxisKey::is_grand,
                              PivotMaterialization::find.
  decode.mbt               -- attribute / element helpers + the four
                              top-level decoders:
                              decode_pivot_cache_definition,
                              decode_cache_field,
                              decode_shared_items,
                              decode_shared_item_value,
                              decode_pivot_cache_records,
                              decode_pivot_table_definition,
                              decode_pivot_field, decode_data_field,
                              decode_page_field, decode_axis_items,
                              decode_field_list, decode_location.
                              All raise SchemaViolation on malformed
                              attributes / unknown enumeration values.
  aggregate.mbt            -- DataConsolidateFunction implementation:
                              aggregate, sum_of_numbers, count_total,
                              count_nums, average, min/max/product,
                              std_dev_pop, std_dev_sample, var_pop,
                              var_sample, collect_numbers (re-uses
                              @formula numeric coercion).
  materialize.mbt          -- materialize_pivot_table:
                              page-field filter pre-pass,
                              row/col axis key extraction,
                              insertion-order key tables,
                              dataField subtotal application,
                              grand-total row/col injection.
  materialize_wbtest.mbt   -- white-box tests for the 12 cases
                              listed in requirements §non-functional.
```

The file split mirrors `cf_rule_eval/`: enums + structs in `types.mbt`
with non-trivial methods to satisfy the SHALLOW gate, decoder funcs
in `decode.mbt`, evaluator logic in `aggregate.mbt` /
`materialize.mbt`, white-box tests consolidated in one `_wbtest.mbt`.

## Cross-package contracts

- Cell values flow through `@formula.FormulaValue`. The decoders
  produce `SharedItemValue` (which preserves the §18.10.1.x discriminator
  so the renderer can tell apart a numeric `<n>` from a string `<s>`),
  but `aggregate.mbt` works exclusively on `FormulaValue` (a strict
  subset is reachable: `VNumber`, `VString`, `VBool`, `VError`,
  `VEmpty`; `VArray` is never produced here).
- Date strings inside `<d>` are passed through `@date_serial` only
  by `to_formula_value` when the cell flows into a numeric aggregation;
  the raw ISO text is preserved on `SharedDate.date_iso` so renderers
  can format it directly.
- A1 ranges inside `worksheetSource/@ref` and `location/@ref` are
  parsed with `@address.CellRange::parse_a1` so out-of-range strings
  surface as `SchemaViolation` immediately.
- The package imports `@domain` only to consume the `element` field
  of the `CT_*` wrappers — no `@domain` types are re-exported.

## Aggregation algorithm

```
materialize_pivot_table(def, cache, records):
  page_keep[i] = true for all i in 0..records.rows.length()
  for each page_field where page_field.item is Some(j):
    fld = page_field.fld
    expected_index = j
    for each row in records.rows:
      cell_value = pivot_record_shared_index(row[fld])
      if cell_value != Some(expected_index):
        page_keep[i] = false

  row_keys_lut : HashMap[String, Int] = new
  col_keys_lut : HashMap[String, Int] = new
  row_keys : Array[PivotAxisKey] = []
  col_keys : Array[PivotAxisKey] = []
  buckets : Array[Array[Array[FormulaValue]]] = [] -- [row_idx][col_idx][data_idx]

  for i, row in enumerate(records.rows):
    if not page_keep[i]: continue
    row_key = extract_axis_key(def.row_fields, row, cache)
    col_key = extract_axis_key(def.col_fields, row, cache)
    row_idx = intern(row_keys_lut, row_keys, row_key)
    col_idx = intern(col_keys_lut, col_keys, col_key)
    ensure_bucket(buckets, row_idx, col_idx, def.data_fields.length())
    for d_idx, data_field in enumerate(def.data_fields):
      value = pivot_record_cell_to_formula_value(row[data_field.fld],
                                                 cache.cache_fields[data_field.fld])
      buckets[row_idx][col_idx][d_idx].push(value)

  // Grand totals are computed as separate buckets indexed by the
  // sentinel PivotAxisKey::RowGrand / ColGrand.
  if def.row_grand_totals: emit_grand_row(buckets, def.data_fields)
  if def.col_grand_totals: emit_grand_col(buckets, def.data_fields)

  // Final pass: convert each bucket to a PivotResultCell with the
  // data field's subtotal applied via aggregate().
  cells : Array[PivotResultCell] = []
  for r_idx, row_key in enumerate(row_keys):
    for c_idx, col_key in enumerate(col_keys):
      for d_idx, data_field in enumerate(def.data_fields):
        cells.push({
          row_key,
          col_key,
          data_field_index: d_idx,
          aggregated_value: aggregate(buckets[r_idx][c_idx][d_idx],
                                       data_field.subtotal),
        })

  return { row_keys, col_keys, cells, data_field_count: def.data_fields.length() }
```

`extract_axis_key` skips `field/@x = -2` entries (the data-field
pseudo position) because those are positional rather than dimensional
— when multiple dataFields exist the renderer places them at the
`-2` position but they do not partition the row buckets.

## PivotAxisKey design

```
pub(all) enum PivotAxisKey {
  Items(Array[Int])    -- one item-index per non-pseudo field
  RowGrand
  ColGrand
} derive(Eq)
```

A `String` key serialisation (used by the HashMap) is built by
joining the item indices with `""` so two distinct integer
keys never collide. The serialisation lives in
`PivotAxisKey::serialize` so it is a single, audited place if the
collision strategy needs to change.

## SharedItemValue → FormulaValue

```
SharedString(s)   -> VString(s)
SharedNumber(n)   -> VNumber(n)
SharedBool(b)     -> VBool(b)
SharedError(lit)  -> VError(FormulaError::from_literal(lit) ?? Value)
SharedDate(iso)   -> VString(iso)   -- aggregations that need it
                                       call coerce_to_number via
                                       @date_serial::date_time_to_serial
                                       in a follow-up commit; Phase 1
                                       passes the ISO string through.
SharedMissing     -> VEmpty
```

This is the same projection table that `@cell_value` uses for cell
values; we keep it inline rather than reaching into a private
helper to keep the pivot package self-contained.

## SHALLOW resolution

Each `types.mbt` enum / struct file includes non-trivial methods
(>4 lines) so the indexion gate sees logic in the same file as the
type. Specifically:

- `DataConsolidateFunction::from_attr(String) -> Self raise
  SchemaViolation` (11-arm match).
- `PivotAxis::from_attr(String) -> PivotAxis raise SchemaViolation`
  (4-arm match for `axisRow`, `axisCol`, `axisPage`, `axisValues`).
- `ItemType::from_attr(String) -> ItemType raise SchemaViolation`
  (12-arm match for the §18.18.43 ST_ItemType lexicons:
  `data`, `default`, `sum`, `countA`, `avg`, `max`, `min`, `product`,
  `count`, `stdDev`, `stdDevP`, `var`, `varP`, `grand`, `blank`).
- `SharedItemValue::to_formula_value(self) -> FormulaValue` (6-arm
  match dispatching the variants listed above).
- `PivotAxisKey::serialize(self) -> String` (3-arm match with the
  per-int join).
- `PivotMaterialization::find(self, row_key, col_key, data_idx) ->
  PivotResultCell?` (linear scan with a 3-condition predicate).

## Test strategy (materialize_wbtest.mbt)

Each test builds a small XML literal, parses it via `@xml.parse`,
wraps it in the matching `CT_*` constructor, decodes it, and then
calls `materialize_pivot_table`. The literals are kept compact
(~10 lines each) and inlined in the test bodies.

| Test                              | Coverage                              |
|---|---|
| `decode_pivot_cache_definition`   | refresh metadata + cacheSource decode |
| `decode_cache_field shared items` | shared `<s>` + `<n>` decoding         |
| `decode_pivot_cache_records`      | mix of `<x>` and inline `<n>` cells   |
| `materialize empty`               | zero records → zero cells             |
| `materialize sum single row`      | 1 row-field × 1 data-field sum        |
| `materialize multi-row col`       | 2 row × 1 col × 1 data with sum       |
| `materialize count + average`     | 1 row × 2 data-fields                 |
| `aggregate Sum`                   | direct aggregator unit test           |
| `aggregate Count CountNums`       | mixed string + number                 |
| `aggregate Average`               | with empty bucket → #DIV/0!           |
| `aggregate Min Max Product`       | simple numeric                        |
| `aggregate StdDev VarP`           | known three-value population          |
| `pageField filter`                | one page index reduces the population |
| `schema_violation unknown subtotal` | `dataField/@subtotal=foobar` raises |
| `schema_violation out-of-range fld` | `dataField/@fld=99` raises          |
| `grand totals on/off`             | toggle `rowGrandTotals`               |

The total comes to ~16 white-box tests. Each test asserts both the
row/col key count and at least one concrete aggregated value.

## Risks

- `pivotCacheRecords` is unbounded in real workbooks (Excel allows
  >1M rows). The materializer is `O(rows * (rowFields + colFields +
  dataFields))` and uses `HashMap`-backed interning; no quadratic
  scans. Hot loops are written without per-iteration allocation
  beyond what the schema requires.
- The `field/@x = -2` sentinel is encoded as `4294967294` in the
  source XML because xsd:unsignedInt has no negative range. The
  decoder shall recognise both `"4294967294"` and `"-2"` for
  robustness.
- `ST_ItemType` has more lexical values than the type currently
  surfaces (`data`, `default`, `sum`, …). Phase 1 stores them as
  the typed enum but only `Data` and `Default` change the
  materializer's behaviour (the others are subtotal markers used
  only by the renderer).
- The OLAP `cacheHierarchies` and `dimensions` paths are not yet
  decoded. Phase 1 ignores them silently to keep the renderer
  working on non-OLAP files; Phase 2 will gate the materializer
  with a `SchemaViolation` when the cache is OLAP.
