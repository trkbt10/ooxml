# G8 — tasks (Phase 1)

1. Create `src/ecma376/spreadsheet_ml/pivot_table/` with `moon.pkg`
   importing `moonbitlang/core/strconv`, `moonbitlang/core/hashmap`,
   `@xml`, `@opc_errors`, `@domain`, `@address`, `@date_serial`,
   `@formula`. Add the `@utf8` wbtest import for XML literal tests.
2. `types.mbt` — define `DataConsolidateFunction`, `PivotAxis`,
   `ItemType`, `SharedItemValue`, `SharedItems`, `CacheField`,
   `WorksheetSource`, `CacheSource`, `PivotCacheDefinition`,
   `PivotRecordCell`, `PivotCacheRow`, `PivotCacheRecords`,
   `PivotLocation`, `PivotItemDef`, `PivotFieldDef`, `DataFieldDef`,
   `PageFieldDef`, `PivotAxisItem`, `PivotTableDefinition`,
   `PivotAxisKey`, `PivotResultCell`, `PivotMaterialization`.
   Implement `from_attr` for `DataConsolidateFunction` (11-arm),
   `PivotAxis` (4-arm), `ItemType` (15-arm). Add
   `SharedItemValue::to_formula_value`,
   `PivotAxisKey::serialize`,
   `PivotMaterialization::find` so the SHALLOW gate sees logic in
   the type file.
3. `decode.mbt` — implement the attribute helpers (`attr`, `attr_or`,
   `require_attr`, `decode_bool_attr`, `decode_required_int`,
   `decode_optional_int`, `decode_optional_double`, `text_content`)
   then the public decoders listed in design.md §"File layout".
   Each raises `SchemaViolation` with the §-section anchor on
   malformed input. The `field/@x = -2` sentinel handler lives here
   too.
4. `aggregate.mbt` — implement `aggregate` (dispatch on
   `DataConsolidateFunction`), `sum_of_numbers`, `count_total`,
   `count_nums`, `aggregate_average`, `aggregate_min`,
   `aggregate_max`, `aggregate_product`, `aggregate_var_pop`,
   `aggregate_var_sample`, `aggregate_std_dev_pop`,
   `aggregate_std_dev_sample`, `coerce_value_to_number`.
5. `materialize.mbt` — implement `materialize_pivot_table` per
   the algorithm in design.md, plus the `PivotAxisKey`-based
   interning helpers and the grand-total injection helpers.
6. `materialize_wbtest.mbt` — 16 white-box tests as listed in
   design.md §"Test strategy".
7. Run `moon fmt && moon info && moon check --target native &&
   moon test --target native -p
   trkbt10/ooxml/ecma376/spreadsheet_ml/pivot_table`. Inspect the
   generated `pkg.generated.mbti` for the new surface.
8. Run `.kiro/scripts/drift.sh --pkg ecma376/spreadsheet_ml`. The
   package vocab around `pivotCacheDefinition`, `pivotCacheRecords`,
   `pivotTableDefinition`, `cacheField`, `sharedItems`, `dataField`,
   `rowFields`, `colFields`, `pageField`, `subtotal`,
   `ST_DataConsolidateFunction` shall move from SPEC_ONLY / SHALLOW
   to MATCHED. Expected outcome: 0 drifted, 0 spec_only, 0 shallow.
9. Commit as `g8-pivot: §18.10 pivot table materialization` with a
   message body that lists the §-sections covered (§18.10.1.67,
   §18.10.1.68, §18.10.1.73, §18.10.1.3, §18.10.1.4, §18.10.1.7,
   §18.10.1.14, §18.10.1.17, §18.10.1.22, §18.10.1.23, §18.10.1.29,
   §18.10.1.44, §18.10.1.45, §18.10.1.49, §18.10.1.62, §18.10.1.90,
   §18.10.1.95, §18.18.17), the test count, and the drift gate
   status, mirroring the `725025e` g6-cf-rule-eval message format.
   Do not include emoji or marketing fluff; just spec anchors and
   facts.
