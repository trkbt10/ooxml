///|
/// Part 1 §18.10 — materialize a non-OLAP PivotTable. Given a
/// decoded `PivotCacheDefinition`, `PivotCacheRecords`, and
/// `PivotTableDefinition`, this function produces a
/// `PivotMaterialization` whose `cells` array carries one entry
/// per `(row_key, col_key, data_field_index)` combination derived
/// from the underlying record rows.
///
/// Algorithm:
///
/// 1. Apply record-level filters from the PivotTable definition:
///    §18.10.1.62 page-field selections and §18.10.1.45 hidden
///    pivotField items.
/// 2. Walk the surviving rows, extract the row-axis key from
///    `def.row_fields` and the column-axis key from
///    `def.col_fields`, and intern the keys in record-discovery
///    order for bucket indexing.
/// 3. Bucket each `(row_idx, col_idx, data_field_index)` slot's
///    values, then apply the data field's `subtotal`
///    consolidation function (§18.18.17) via `aggregate`.
/// 4. Expand §18.10.1.44 `rowItems` / `colItems` into the public
///    `row_keys` / `col_keys` order, falling back to discovery
///    order when the item list is absent.
/// 5. When `row_grand_totals` / `col_grand_totals` is true (their
///    spec defaults), include the matching `RowGrand` / `ColGrand`
///    sentinel and emit the aggregated cells for the full
///    population.
/// 6. Apply supported §18.10.1.22 `dataField/@showDataAs`
///    display transforms to the materialized cells. This is done
///    inside the materializer so renderers and GETPIVOTDATA keep
///    consuming the same result-cell SoT.
///
/// Out-of-range `dataField/@fld` or `pageField/@fld` values raise
/// `@opc_errors.SchemaViolation` so a malformed file surfaces a
/// readable diagnostic rather than panicking.
pub fn materialize_pivot_table(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  records : PivotCacheRecords,
) -> PivotMaterialization raise @opc_errors.SchemaViolation {
  let field_count = cache.field_count()
  validate_field_indices(definition, field_count)
  let kept_rows = apply_record_filters(definition, cache, records)
  let row_field_positions = extract_real_field_positions(definition.row_fields)
  let col_field_positions = extract_real_field_positions(definition.col_fields)
  let lut = AxisLookup::new()
  let buckets : Array[Array[Array[Array[@formula.FormulaValue]]]] = []
  let data_field_count = definition.data_fields.length()
  for row in kept_rows {
    let row_key = build_axis_key(row, row_field_positions)
    let col_key = build_axis_key(row, col_field_positions)
    let row_idx = lut.intern_row(row_key)
    let col_idx = lut.intern_col(col_key)
    ensure_bucket_shape(buckets, row_idx, col_idx, data_field_count)
    let mut d_idx = 0
    for data_field in definition.data_fields {
      // §18.10.1.3 — a calculated field has no per-record value; skip
      // the bucket fill (also avoids indexing `row.cells` at a field
      // the records don't store).  Its cells are derived later by
      // `append_calculated_field_cells`.
      if is_calc_data_field(definition, cache, d_idx) {
        d_idx = d_idx + 1
        continue
      }
      let cell = row.cells[data_field.fld]
      let value = pivot_record_cell_to_formula_value(
        cell,
        cache.cache_fields[data_field.fld],
      )
      buckets[row_idx][col_idx][d_idx].push(value)
      d_idx = d_idx + 1
    }
  }
  let axis_filter = apply_pivot_aggregate_filters(
    definition,
    cache,
    kept_rows,
    lut.row_keys,
    lut.col_keys,
    buckets,
    row_field_positions,
    col_field_positions,
    data_field_count,
  )
  let row_keys = select_axis_keys(lut.row_keys, axis_filter.row_indices)
  let col_keys = select_axis_keys(lut.col_keys, axis_filter.col_indices)
  let buckets = select_axis_buckets(
    buckets,
    axis_filter.row_indices,
    axis_filter.col_indices,
    data_field_count,
  )
  let cells : Array[PivotResultCell] = []
  // Emit one cell per (row_key, col_key, data_field_index) that
  // has at least one record contributing to it. Empty buckets are
  // dropped so the renderer can branch on `find()` returning None.
  // Some (row_idx, col_idx) slots were never visited during the
  // bucket-fill pass (the corresponding cross of items never
  // appeared in a single record) — for those, `buckets[r_idx]`
  // is short of `col_idx` or absent entirely, and we skip them.
  let mut r_idx = 0
  for row_key in row_keys {
    let mut c_idx = 0
    for col_key in col_keys {
      let mut d_idx = 0
      for data_field in definition.data_fields {
        if r_idx < buckets.length() &&
          c_idx < buckets[r_idx].length() &&
          d_idx < buckets[r_idx][c_idx].length() {
          let bucket = buckets[r_idx][c_idx][d_idx]
          if bucket.length() > 0 {
            let aggregated = aggregate(bucket, data_field.subtotal)
            cells.push({
              row_key,
              col_key,
              data_field_index: d_idx,
              aggregated_value: aggregated,
            })
          }
        }
        d_idx = d_idx + 1
      }
      c_idx = c_idx + 1
    }
    r_idx = r_idx + 1
  }
  // §18.10.1.44 rowItems / colItems define the display order of
  // axis tuples. The materializer owns this ordering so renderers and
  // formula lookup consume one PivotMaterialization SoT.
  let row_keys_final = order_axis_keys(
    row_keys,
    definition.row_items,
    row_field_positions.length(),
    RowGrand,
    definition.row_grand_totals && row_keys.length() > 0,
  )
  let col_keys_final = order_axis_keys(
    col_keys,
    definition.col_items,
    col_field_positions.length(),
    ColGrand,
    definition.col_grand_totals && col_keys.length() > 0,
  )
  if definition.col_grand_totals && col_keys.length() > 0 {
    emit_col_grand_totals(
      cells, definition, buckets, row_keys, col_keys, data_field_count,
    )
  }
  if definition.row_grand_totals && row_keys.length() > 0 {
    emit_row_grand_totals(
      cells, definition, buckets, row_keys, col_keys, data_field_count,
    )
  }
  if definition.row_grand_totals &&
    definition.col_grand_totals &&
    row_keys.length() > 0 &&
    col_keys.length() > 0 {
    emit_overall_grand_total(
      cells, definition, buckets, row_keys, col_keys, data_field_count,
    )
  }
  // §18.10.1.3 calculated fields — the per-record bucket pass leaves a
  // calculated field's cells empty (it has no stored per-record value);
  // derive them here from the kept rows.  No-op when the pivot has no
  // calculated field, so ordinary pivots are unaffected.
  append_calculated_field_cells(
    cells, definition, cache, kept_rows, row_field_positions, col_field_positions,
    row_keys, col_keys,
  )
  let show_data_as_basis = build_show_data_as_basis(
    cells, definition, cache, kept_rows, row_field_positions, col_field_positions,
    buckets, row_keys, col_keys, data_field_count,
  )
  apply_show_data_as(cells, definition, show_data_as_basis)
  {
    row_keys: row_keys_final,
    col_keys: col_keys_final,
    cells,
    data_field_count,
  }
}

///|
/// Validate that every `dataField/@fld`, `pageField/@fld`, and
/// PivotTable `filter/@fld`
/// index falls inside the cacheFields collection. Surfacing this
/// early gives renderers a stable error rather than an out-of-bound
/// panic later on.
fn validate_field_indices(
  definition : PivotTableDefinition,
  field_count : Int,
) -> Unit raise @opc_errors.SchemaViolation {
  for data_field in definition.data_fields {
    if data_field.fld < 0 || data_field.fld >= field_count {
      raise @opc_errors.SchemaViolation(
        section=pivot_table_definition_part1_18_10_1_73_section_name(),
        path="dataField/@fld",
        reason="data field index " +
          data_field.fld.to_string() +
          " is out of range (cacheFields count " +
          field_count.to_string() +
          ")",
      )
    }
  }
  for page_field in definition.page_fields {
    if page_field.fld < 0 || page_field.fld >= field_count {
      raise @opc_errors.SchemaViolation(
        section=pivot_table_definition_part1_18_10_1_73_section_name(),
        path="pageField/@fld",
        reason="page field index " +
          page_field.fld.to_string() +
          " is out of range (cacheFields count " +
          field_count.to_string() +
          ")",
      )
    }
  }
  for filter in definition.filters {
    if filter.fld < 0 || filter.fld >= field_count {
      raise @opc_errors.SchemaViolation(
        section=pivot_table_definition_part1_18_10_1_73_section_name(),
        path="filter/@fld",
        reason="pivot filter field index " +
          filter.fld.to_string() +
          " is out of range (cacheFields count " +
          field_count.to_string() +
          ")",
      )
    }
  }
  for axis_idx in definition.row_fields {
    if axis_idx != -2 && (axis_idx < 0 || axis_idx >= field_count) {
      raise @opc_errors.SchemaViolation(
        section=pivot_table_definition_part1_18_10_1_73_section_name(),
        path="rowFields/field/@x",
        reason="row field index " +
          axis_idx.to_string() +
          " is out of range (cacheFields count " +
          field_count.to_string() +
          ")",
      )
    }
  }
  for axis_idx in definition.col_fields {
    if axis_idx != -2 && (axis_idx < 0 || axis_idx >= field_count) {
      raise @opc_errors.SchemaViolation(
        section=pivot_table_definition_part1_18_10_1_73_section_name(),
        path="colFields/field/@x",
        reason="column field index " +
          axis_idx.to_string() +
          " is out of range (cacheFields count " +
          field_count.to_string() +
          ")",
      )
    }
  }
}

///|
/// Apply PivotTable record filters before axis-key discovery. The
/// materializer is the SoT for filtered records, so renderers and
/// GETPIVOTDATA consume the same row/column keys and totals.
fn apply_record_filters(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  records : PivotCacheRecords,
) -> Array[PivotCacheRow] raise @opc_errors.SchemaViolation {
  let kept : Array[PivotCacheRow] = []
  for row in records.rows {
    if row_matches_page_fields(definition, row) &&
      row_matches_visible_pivot_items(definition, row) {
      kept.push(row)
    }
  }
  apply_pivot_advanced_filters(definition, cache, kept)
}

///|
/// §18.10.1.62 page-field selection. Each `pageField/@item` that is
/// `Some(i)` requires the record's `field[pageField.fld]` cell to
/// resolve to shared item `i`; `None` means "(All)".
fn row_matches_page_fields(
  definition : PivotTableDefinition,
  row : PivotCacheRow,
) -> Bool {
  for page_field in definition.page_fields {
    match page_field.item {
      Some(expected) => {
        let cell = row.cells[page_field.fld]
        match pivot_record_cell_shared_index(cell) {
          Some(actual) => if actual != expected { return false }
          None => return false
        }
      }
      None => ()
    }
  }
  true
}

///|
/// §18.10.1.45 `item/@h` hides a shared item in its pivotField. Hidden
/// item state is stored on the typed PivotTable definition; this
/// predicate only projects the current record through that SoT.
fn row_matches_visible_pivot_items(
  definition : PivotTableDefinition,
  row : PivotCacheRow,
) -> Bool {
  for field_idx in 0..<definition.pivot_fields.length() {
    if field_idx >= row.cells.length() {
      continue
    }
    match pivot_record_cell_shared_index(row.cells[field_idx]) {
      Some(item_idx) =>
        if pivot_item_is_hidden(definition.pivot_fields[field_idx], item_idx) {
          return false
        }
      None => ()
    }
  }
  true
}

///|
fn pivot_item_is_hidden(field : PivotFieldDef, item_idx : Int) -> Bool {
  for item in field.items {
    if item.hidden && item.item_index == Some(item_idx) {
      return true
    }
  }
  false
}

///|
/// §18.10.1.33 / §18.10.1.34 — apply PivotTable advanced filters that
/// target raw field captions or date members. Aggregate value filters
/// (`sum`, `count`, `percent`, and `value*`) are intentionally left for
/// a materialized-measure pass; applying them here would use raw cache
/// records instead of PivotTable aggregate values.
fn apply_pivot_advanced_filters(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  rows : Array[PivotCacheRow],
) -> Array[PivotCacheRow] raise @opc_errors.SchemaViolation {
  let mut current = rows
  for filter in definition.filters {
    if pivot_filter_targets_raw_records(filter) {
      current = apply_pivot_auto_filter(cache, current, filter)
    }
  }
  current
}

///|
fn apply_pivot_auto_filter(
  cache : PivotCacheDefinition,
  rows : Array[PivotCacheRow],
  filter : PivotFilterDef,
) -> Array[PivotCacheRow] raise @opc_errors.SchemaViolation {
  let candidates = pivot_filter_candidate_rows(cache, rows, filter)
  let visible_indices = @autofilter.filter_rows(
    filter.auto_filter,
    candidates,
    @date_serial.DateSystem::Serial1900,
  )
  let out : Array[PivotCacheRow] = []
  for index in visible_indices {
    match rows.get(index) {
      Some(row) => out.push(row)
      None => ()
    }
  }
  out
}

///|
fn pivot_filter_candidate_rows(
  cache : PivotCacheDefinition,
  rows : Array[PivotCacheRow],
  filter : PivotFilterDef,
) -> Array[@autofilter.CandidateRow] raise @opc_errors.SchemaViolation {
  let candidates : Array[@autofilter.CandidateRow] = []
  let mut row_index = 0
  for row in rows {
    let value = if filter.fld < row.cells.length() {
      pivot_record_cell_to_formula_value(
        row.cells[filter.fld],
        cache.cache_fields[filter.fld],
      )
    } else {
      @formula.FormulaValue::VEmpty
    }
    candidates.push({
      values: pivot_filter_candidate_values(filter, value),
      row_index,
    })
    row_index = row_index + 1
  }
  candidates
}

///|
fn pivot_filter_candidate_column_count(filter : @domain.CT_AutoFilter) -> Int {
  let mut count = 1
  for column in filter.filter_columns {
    if column.col_id + 1 > count {
      count = column.col_id + 1
    }
  }
  count
}

///|
fn pivot_filter_targets_raw_records(filter : PivotFilterDef) -> Bool {
  match filter.type_ {
    "captionEqual"
    | "captionNotEqual"
    | "captionBeginsWith"
    | "captionNotBeginsWith"
    | "captionEndsWith"
    | "captionNotEndsWith"
    | "captionContains"
    | "captionNotContains"
    | "captionGreaterThan"
    | "captionGreaterThanOrEqual"
    | "captionLessThan"
    | "captionLessThanOrEqual"
    | "captionBetween"
    | "captionNotBetween"
    | "dateEqual"
    | "dateNotEqual"
    | "dateOlderThan"
    | "dateOlderThanOrEqual"
    | "dateNewerThan"
    | "dateNewerThanOrEqual"
    | "dateBetween"
    | "dateNotBetween"
    | "tomorrow"
    | "today"
    | "yesterday"
    | "nextWeek"
    | "thisWeek"
    | "lastWeek"
    | "nextMonth"
    | "thisMonth"
    | "lastMonth"
    | "nextQuarter"
    | "thisQuarter"
    | "lastQuarter"
    | "nextYear"
    | "thisYear"
    | "lastYear"
    | "yearToDate"
    | "Q1"
    | "Q2"
    | "Q3"
    | "Q4"
    | "M1"
    | "M2"
    | "M3"
    | "M4"
    | "M5"
    | "M6"
    | "M7"
    | "M8"
    | "M9"
    | "M10"
    | "M11"
    | "M12" => true
    _ => false
  }
}

///|
priv struct PivotAggregateFilterState {
  row_indices : Array[Int]
  col_indices : Array[Int]
}

///|
/// §18.10.1.33 / ST_PivotFilterType aggregate and value filters operate
/// on PivotTable measure results, not raw cache records. This pass keeps
/// AutoFilter as the comparison SoT by projecting each candidate axis item
/// into a one-row `@autofilter.CandidateRow` whose value is the relevant
/// materialized aggregate.
fn apply_pivot_aggregate_filters(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  kept_rows : Array[PivotCacheRow],
  row_keys : Array[PivotAxisKey],
  col_keys : Array[PivotAxisKey],
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  row_field_positions : Array[Int],
  col_field_positions : Array[Int],
  data_field_count : Int,
) -> PivotAggregateFilterState raise @opc_errors.SchemaViolation {
  let mut row_indices = axis_indices(row_keys.length())
  let mut col_indices = axis_indices(col_keys.length())
  if row_indices.length() == 0 || col_indices.length() == 0 {
    return { row_indices, col_indices }
  }
  let calc_fields = collect_calc_fields(definition, cache)
  let axis_projection = build_pivot_row_axis_projection(
    kept_rows, row_field_positions, col_field_positions,
  )
  for filter in definition.filters {
    if !pivot_filter_targets_aggregate_values(filter) {
      continue
    }
    let data_field_index = match
      pivot_filter_measure_index(definition, filter) {
      Some(index) => index
      None => continue
    }
    if data_field_index < 0 || data_field_index >= data_field_count {
      continue
    }
    let calc_field = calc_field_for_data_index(calc_fields, data_field_index)
    if field_index_in_positions(row_field_positions, filter.fld) {
      row_indices = filter_row_axis_indices(
        definition, cache, buckets, kept_rows, axis_projection, row_keys, col_keys,
        row_indices, col_indices, data_field_index, calc_field, filter,
      )
    } else if field_index_in_positions(col_field_positions, filter.fld) {
      col_indices = filter_col_axis_indices(
        definition, cache, buckets, kept_rows, axis_projection, row_keys, col_keys,
        row_indices, col_indices, data_field_index, calc_field, filter,
      )
    }
  }
  { row_indices, col_indices }
}

///|
fn pivot_filter_targets_aggregate_values(filter : PivotFilterDef) -> Bool {
  match filter.type_ {
    "count"
    | "percent"
    | "sum"
    | "valueEqual"
    | "valueNotEqual"
    | "valueGreaterThan"
    | "valueGreaterThanOrEqual"
    | "valueLessThan"
    | "valueLessThanOrEqual"
    | "valueBetween"
    | "valueNotBetween" => true
    _ => false
  }
}

///|
fn pivot_filter_measure_index(
  definition : PivotTableDefinition,
  filter : PivotFilterDef,
) -> Int? {
  match filter.i_measure_fld {
    Some(index) => {
      if index >= 0 && index < definition.data_fields.length() {
        return Some(index)
      }
      let mut data_index = 0
      for data_field in definition.data_fields {
        if data_field.fld == index {
          return Some(data_index)
        }
        data_index = data_index + 1
      }
      None
    }
    None => if definition.data_fields.length() > 0 { Some(0) } else { None }
  }
}

///|
fn field_index_in_positions(positions : Array[Int], fld : Int) -> Bool {
  for position in positions {
    if position == fld {
      return true
    }
  }
  false
}

///|
fn filter_row_axis_indices(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  kept_rows : Array[PivotCacheRow],
  axis_projection : PivotRowAxisProjection,
  row_keys : Array[PivotAxisKey],
  col_keys : Array[PivotAxisKey],
  row_indices : Array[Int],
  col_indices : Array[Int],
  data_field_index : Int,
  calc_field : CalcField?,
  filter : PivotFilterDef,
) -> Array[Int] raise @opc_errors.SchemaViolation {
  let candidates : Array[@autofilter.CandidateRow] = []
  let selected_col_keys = select_axis_keys(col_keys, col_indices)
  let mut candidate_index = 0
  for row_index in row_indices {
    let value = match calc_field {
      Some(calc) =>
        match row_keys.get(row_index) {
          Some(row_key) =>
            calc_row_axis_value(
              calc, cache, kept_rows, axis_projection, row_key, selected_col_keys,
            )
          None => @formula.FormulaValue::VEmpty
        }
      None =>
        aggregate_row_axis_value(
          definition, buckets, row_index, col_indices, data_field_index,
        )
    }
    candidates.push({
      values: pivot_filter_candidate_values(filter, value),
      row_index: candidate_index,
    })
    candidate_index = candidate_index + 1
  }
  let visible = @autofilter.filter_rows(
    filter.auto_filter,
    candidates,
    @date_serial.DateSystem::Serial1900,
  )
  let out : Array[Int] = []
  for index in visible {
    match row_indices.get(index) {
      Some(row_index) => out.push(row_index)
      None => ()
    }
  }
  out
}

///|
fn filter_col_axis_indices(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  kept_rows : Array[PivotCacheRow],
  axis_projection : PivotRowAxisProjection,
  row_keys : Array[PivotAxisKey],
  col_keys : Array[PivotAxisKey],
  row_indices : Array[Int],
  col_indices : Array[Int],
  data_field_index : Int,
  calc_field : CalcField?,
  filter : PivotFilterDef,
) -> Array[Int] raise @opc_errors.SchemaViolation {
  let candidates : Array[@autofilter.CandidateRow] = []
  let selected_row_keys = select_axis_keys(row_keys, row_indices)
  let mut candidate_index = 0
  for col_index in col_indices {
    let value = match calc_field {
      Some(calc) =>
        match col_keys.get(col_index) {
          Some(col_key) =>
            calc_col_axis_value(
              calc, cache, kept_rows, axis_projection, selected_row_keys, col_key,
            )
          None => @formula.FormulaValue::VEmpty
        }
      None =>
        aggregate_col_axis_value(
          definition, buckets, row_indices, col_index, data_field_index,
        )
    }
    candidates.push({
      values: pivot_filter_candidate_values(filter, value),
      row_index: candidate_index,
    })
    candidate_index = candidate_index + 1
  }
  let visible = @autofilter.filter_rows(
    filter.auto_filter,
    candidates,
    @date_serial.DateSystem::Serial1900,
  )
  let out : Array[Int] = []
  for index in visible {
    match col_indices.get(index) {
      Some(col_index) => out.push(col_index)
      None => ()
    }
  }
  out
}

///|
fn calc_row_axis_value(
  calc : CalcField,
  cache : PivotCacheDefinition,
  kept_rows : Array[PivotCacheRow],
  axis_projection : PivotRowAxisProjection,
  row_key : PivotAxisKey,
  col_keys : Array[PivotAxisKey],
) -> @formula.FormulaValue raise @opc_errors.SchemaViolation {
  calc_axis_value(
    calc,
    cache,
    kept_rows,
    axis_projection,
    [Some(row_key)],
    pivot_axis_key_options(col_keys),
  )
}

///|
fn calc_col_axis_value(
  calc : CalcField,
  cache : PivotCacheDefinition,
  kept_rows : Array[PivotCacheRow],
  axis_projection : PivotRowAxisProjection,
  row_keys : Array[PivotAxisKey],
  col_key : PivotAxisKey,
) -> @formula.FormulaValue raise @opc_errors.SchemaViolation {
  calc_axis_value(
    calc,
    cache,
    kept_rows,
    axis_projection,
    pivot_axis_key_options(row_keys),
    [Some(col_key)],
  )
}

///|
fn calc_axis_value(
  calc : CalcField,
  cache : PivotCacheDefinition,
  kept_rows : Array[PivotCacheRow],
  axis_projection : PivotRowAxisProjection,
  row_keys : Array[PivotAxisKey?],
  col_keys : Array[PivotAxisKey?],
) -> @formula.FormulaValue raise @opc_errors.SchemaViolation {
  let rows : Array[PivotCacheRow] = []
  for row_key in row_keys {
    for col_key in col_keys {
      for
        row in pivot_rows_for_axis_subset(
          kept_rows, axis_projection, row_key, col_key,
        ) {
        rows.push(row)
      }
    }
  }
  if rows.length() == 0 {
    @formula.FormulaValue::VEmpty
  } else {
    eval_calc_field_over_rows(calc, rows, cache)
  }
}

///|
fn pivot_axis_key_options(keys : Array[PivotAxisKey]) -> Array[PivotAxisKey?] {
  let out : Array[PivotAxisKey?] = []
  for key in keys {
    out.push(Some(key))
  }
  out
}

///|
fn aggregate_row_axis_value(
  definition : PivotTableDefinition,
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  row_index : Int,
  col_indices : Array[Int],
  data_field_index : Int,
) -> @formula.FormulaValue {
  let combined : Array[@formula.FormulaValue] = []
  for col_index in col_indices {
    push_bucket_values(
      combined, buckets, row_index, col_index, data_field_index,
    )
  }
  aggregate_axis_values(definition, combined, data_field_index)
}

///|
fn aggregate_col_axis_value(
  definition : PivotTableDefinition,
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  row_indices : Array[Int],
  col_index : Int,
  data_field_index : Int,
) -> @formula.FormulaValue {
  let combined : Array[@formula.FormulaValue] = []
  for row_index in row_indices {
    push_bucket_values(
      combined, buckets, row_index, col_index, data_field_index,
    )
  }
  aggregate_axis_values(definition, combined, data_field_index)
}

///|
fn aggregate_axis_values(
  definition : PivotTableDefinition,
  values : Array[@formula.FormulaValue],
  data_field_index : Int,
) -> @formula.FormulaValue {
  if values.length() == 0 {
    @formula.FormulaValue::VEmpty
  } else {
    aggregate(values, definition.aggregation_function_for(data_field_index))
  }
}

///|
fn push_bucket_values(
  out : Array[@formula.FormulaValue],
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  row_index : Int,
  col_index : Int,
  data_field_index : Int,
) -> Unit {
  if row_index < buckets.length() &&
    col_index < buckets[row_index].length() &&
    data_field_index < buckets[row_index][col_index].length() {
    for value in buckets[row_index][col_index][data_field_index] {
      out.push(value)
    }
  }
}

///|
fn pivot_filter_candidate_values(
  filter : PivotFilterDef,
  value : @formula.FormulaValue,
) -> Array[@formula.FormulaValue] {
  let col_count = pivot_filter_candidate_column_count(filter.auto_filter)
  let values : Array[@formula.FormulaValue] = []
  for _ in 0..<col_count {
    values.push(@formula.FormulaValue::VEmpty)
  }
  for column in filter.auto_filter.filter_columns {
    if column.col_id >= 0 && column.col_id < values.length() {
      values[column.col_id] = value
    }
  }
  values
}

///|
fn axis_indices(count : Int) -> Array[Int] {
  let indices : Array[Int] = []
  for index in 0..<count {
    indices.push(index)
  }
  indices
}

///|
fn select_axis_keys(
  keys : Array[PivotAxisKey],
  indices : Array[Int],
) -> Array[PivotAxisKey] {
  let selected : Array[PivotAxisKey] = []
  for index in indices {
    match keys.get(index) {
      Some(key) => selected.push(key)
      None => ()
    }
  }
  selected
}

///|
fn select_axis_buckets(
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  row_indices : Array[Int],
  col_indices : Array[Int],
  data_field_count : Int,
) -> Array[Array[Array[Array[@formula.FormulaValue]]]] {
  let selected : Array[Array[Array[Array[@formula.FormulaValue]]]] = []
  for row_index in row_indices {
    let selected_row : Array[Array[Array[@formula.FormulaValue]]] = []
    for col_index in col_indices {
      let selected_cell : Array[Array[@formula.FormulaValue]] = []
      for data_field_index in 0..<data_field_count {
        let values : Array[@formula.FormulaValue] = []
        push_bucket_values(
          values, buckets, row_index, col_index, data_field_index,
        )
        selected_cell.push(values)
      }
      selected_row.push(selected_cell)
    }
    selected.push(selected_row)
  }
  selected
}

///|
/// Drop the `-2` data-field pseudo position from an axis field
/// list, returning the cacheField indices that actually partition
/// the rows or columns.
fn extract_real_field_positions(field_list : Array[Int]) -> Array[Int] {
  let positions : Array[Int] = []
  for entry in field_list {
    if entry != -2 {
      positions.push(entry)
    }
  }
  positions
}

///|
/// Build a `PivotAxisKey` from a record row by looking up each
/// real field position and using the shared-items index when
/// available, falling back to a sentinel `-1` when the cell is
/// an inline literal. Inline literals are rare in practice — the
/// shared-items table holds the unique values for any field that
/// participates on an axis — but the materializer keeps working
/// against them by treating each distinct inline literal as a
/// distinct axis bucket.
fn build_axis_key(row : PivotCacheRow, positions : Array[Int]) -> PivotAxisKey {
  let indices : Array[Int] = []
  for position in positions {
    let cell = row.cells[position]
    match pivot_record_cell_shared_index(cell) {
      Some(idx) => indices.push(idx)
      None => indices.push(-1)
    }
  }
  Items(indices)
}

///|
/// §18.10.1.44 — project `<rowItems>` / `<colItems>` into the
/// materialized axis-key order. If the source XML omits an item list,
/// retain record-discovery order. If it supplies a partial list, use
/// the document order for listed tuples and append any discovered
/// tuples that were not listed so data is not lost.
fn order_axis_keys(
  discovered : Array[PivotAxisKey],
  items : Array[PivotAxisItem],
  real_field_count : Int,
  grand_key : PivotAxisKey,
  include_grand : Bool,
) -> Array[PivotAxisKey] {
  let ordered : Array[PivotAxisKey] = []
  let seen : @hashmap.HashMap[String, Bool] = @hashmap.HashMap::from_array([])
  if discovered.length() == 0 {
    return ordered
  }
  if items.length() > 0 {
    let mut previous : Array[Int] = []
    for item in items {
      match axis_item_to_key(item, previous, real_field_count, grand_key) {
        Some(key) => {
          let is_grand_key = key.is_grand()
          if !is_grand_key || include_grand {
            push_unique_axis_key(ordered, seen, key)
          }
          if key is Items(indices) {
            previous = indices
          }
        }
        None => ()
      }
    }
  }
  for key in discovered {
    push_unique_axis_key(ordered, seen, key)
  }
  if include_grand {
    push_unique_axis_key(ordered, seen, grand_key)
  }
  ordered
}

///|
/// §18.10.1.44 CT_I: `@r` repeats that many leading item indices
/// from the previous axis tuple, then the `<x>` children supply the
/// remaining item indices. Grand-total entries are represented by
/// the caller-supplied sentinel key for the relevant axis.
fn axis_item_to_key(
  item : PivotAxisItem,
  previous : Array[Int],
  real_field_count : Int,
  grand_key : PivotAxisKey,
) -> PivotAxisKey? {
  match item.item_type {
    Some(Grand) => return Some(grand_key)
    _ => ()
  }
  let indices : Array[Int] = []
  let repeat_limit = min_int(item.repeat_count, real_field_count)
  let repeat = min_int(repeat_limit, previous.length())
  for i in 0..<repeat {
    indices.push(previous[i])
  }
  for value in item.item_indices {
    if indices.length() < real_field_count {
      indices.push(value)
    }
  }
  if indices.length() == real_field_count {
    Some(Items(indices))
  } else {
    None
  }
}

///|
fn push_unique_axis_key(
  ordered : Array[PivotAxisKey],
  seen : @hashmap.HashMap[String, Bool],
  key : PivotAxisKey,
) -> Unit {
  let serial = key.serialize()
  match seen.get(serial) {
    Some(true) => ()
    _ => {
      ordered.push(key)
      seen.set(serial, true)
    }
  }
}

///|
fn min_int(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Grow the `buckets` 3-D matrix so that
/// `buckets[row_idx][col_idx]` exists and has `data_field_count`
/// empty per-data-field lists. The materializer calls this lazily
/// because the row / col counts are not known up-front: they grow
/// as we discover new axis keys.
fn ensure_bucket_shape(
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  row_idx : Int,
  col_idx : Int,
  data_field_count : Int,
) -> Unit {
  while buckets.length() <= row_idx {
    buckets.push([])
  }
  while buckets[row_idx].length() <= col_idx {
    let per_data : Array[Array[@formula.FormulaValue]] = []
    let mut i = 0
    while i < data_field_count {
      per_data.push([])
      i = i + 1
    }
    buckets[row_idx].push(per_data)
  }
  // Defensive: if a previous row at this (row_idx, col_idx) was
  // created with a different data_field_count we extend it. In
  // practice `data_field_count` is constant for a given pivot, so
  // this is a no-op after the first allocation.
  while buckets[row_idx][col_idx].length() < data_field_count {
    buckets[row_idx][col_idx].push([])
  }
}

///|
/// Insertion-order key interning. The materializer needs O(1) key
/// lookup but also needs to preserve the order in which keys first
/// appear in the records (matches the §18.10.1.45 default item
/// ordering). We keep both a hashmap (for the lookup) and an array
/// (for the order) and let them stay consistent by construction.
priv struct AxisLookup {
  row_keys : Array[PivotAxisKey]
  col_keys : Array[PivotAxisKey]
  row_lut : @hashmap.HashMap[String, Int]
  col_lut : @hashmap.HashMap[String, Int]
}

///|
fn AxisLookup::new() -> AxisLookup {
  {
    row_keys: [],
    col_keys: [],
    row_lut: @hashmap.HashMap::from_array([]),
    col_lut: @hashmap.HashMap::from_array([]),
  }
}

///|
fn AxisLookup::intern_row(self : AxisLookup, key : PivotAxisKey) -> Int {
  let serial = key.serialize()
  match self.row_lut.get(serial) {
    Some(idx) => idx
    None => {
      let new_idx = self.row_keys.length()
      self.row_keys.push(key)
      self.row_lut.set(serial, new_idx)
      new_idx
    }
  }
}

///|
fn AxisLookup::intern_col(self : AxisLookup, key : PivotAxisKey) -> Int {
  let serial = key.serialize()
  match self.col_lut.get(serial) {
    Some(idx) => idx
    None => {
      let new_idx = self.col_keys.length()
      self.col_keys.push(key)
      self.col_lut.set(serial, new_idx)
      new_idx
    }
  }
}

///|
/// Emit one `ColGrand` cell per (row_key, data_field_index) by
/// flattening every column bucket for that row.
fn emit_col_grand_totals(
  cells : Array[PivotResultCell],
  definition : PivotTableDefinition,
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  row_keys : Array[PivotAxisKey],
  col_keys : Array[PivotAxisKey],
  data_field_count : Int,
) -> Unit {
  let mut r_idx = 0
  for row_key in row_keys {
    let mut d_idx = 0
    while d_idx < data_field_count {
      let combined : Array[@formula.FormulaValue] = []
      let mut c_idx = 0
      while c_idx < col_keys.length() {
        if r_idx < buckets.length() &&
          c_idx < buckets[r_idx].length() &&
          d_idx < buckets[r_idx][c_idx].length() {
          for value in buckets[r_idx][c_idx][d_idx] {
            combined.push(value)
          }
        }
        c_idx = c_idx + 1
      }
      if combined.length() > 0 {
        let function = definition.aggregation_function_for(d_idx)
        cells.push({
          row_key,
          col_key: ColGrand,
          data_field_index: d_idx,
          aggregated_value: aggregate(combined, function),
        })
      }
      d_idx = d_idx + 1
    }
    r_idx = r_idx + 1
  }
}

///|
/// Emit one `RowGrand` cell per (col_key, data_field_index) by
/// flattening every row bucket for that column.
fn emit_row_grand_totals(
  cells : Array[PivotResultCell],
  definition : PivotTableDefinition,
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  row_keys : Array[PivotAxisKey],
  col_keys : Array[PivotAxisKey],
  data_field_count : Int,
) -> Unit {
  let mut c_idx = 0
  for col_key in col_keys {
    let mut d_idx = 0
    while d_idx < data_field_count {
      let combined : Array[@formula.FormulaValue] = []
      let mut r_idx = 0
      while r_idx < row_keys.length() {
        if r_idx < buckets.length() &&
          c_idx < buckets[r_idx].length() &&
          d_idx < buckets[r_idx][c_idx].length() {
          for value in buckets[r_idx][c_idx][d_idx] {
            combined.push(value)
          }
        }
        r_idx = r_idx + 1
      }
      if combined.length() > 0 {
        let function = definition.aggregation_function_for(d_idx)
        cells.push({
          row_key: RowGrand,
          col_key,
          data_field_index: d_idx,
          aggregated_value: aggregate(combined, function),
        })
      }
      d_idx = d_idx + 1
    }
    c_idx = c_idx + 1
  }
}

///|
/// Emit the single `(RowGrand, ColGrand)` cell per data field —
/// the overall aggregate over every record that survived the
/// page-field filter.
fn emit_overall_grand_total(
  cells : Array[PivotResultCell],
  definition : PivotTableDefinition,
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  row_keys : Array[PivotAxisKey],
  col_keys : Array[PivotAxisKey],
  data_field_count : Int,
) -> Unit {
  let mut d_idx = 0
  while d_idx < data_field_count {
    let combined : Array[@formula.FormulaValue] = []
    let mut r_idx = 0
    while r_idx < row_keys.length() {
      let mut c_idx = 0
      while c_idx < col_keys.length() {
        if r_idx < buckets.length() &&
          c_idx < buckets[r_idx].length() &&
          d_idx < buckets[r_idx][c_idx].length() {
          for value in buckets[r_idx][c_idx][d_idx] {
            combined.push(value)
          }
        }
        c_idx = c_idx + 1
      }
      r_idx = r_idx + 1
    }
    if combined.length() > 0 {
      let function = definition.aggregation_function_for(d_idx)
      cells.push({
        row_key: RowGrand,
        col_key: ColGrand,
        data_field_index: d_idx,
        aggregated_value: aggregate(combined, function),
      })
    }
    d_idx = d_idx + 1
  }
}

///|
/// Build the hidden total basis used by `showDataAs` percentage modes.
/// Grand total visibility is a presentation flag; the denominator for
/// `% of row/column/total` still follows the same aggregate/calculated
/// field paths that visible grand totals use. This helper therefore
/// reuses the existing grand-total emitters and calculated-field pass,
/// then keeps those cells internal to the display transform rather than
/// adding hidden totals to the returned materialization.
fn build_show_data_as_basis(
  cells : Array[PivotResultCell],
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  kept_rows : Array[PivotCacheRow],
  row_field_positions : Array[Int],
  col_field_positions : Array[Int],
  buckets : Array[Array[Array[Array[@formula.FormulaValue]]]],
  row_keys : Array[PivotAxisKey],
  col_keys : Array[PivotAxisKey],
  data_field_count : Int,
) -> Array[PivotResultCell] raise @opc_errors.SchemaViolation {
  let basis = cells.copy()
  if row_keys.length() == 0 || col_keys.length() == 0 {
    return basis
  }
  let forced_definition = {
    ..definition,
    row_grand_totals: true,
    col_grand_totals: true,
  }
  let totals : Array[PivotResultCell] = []
  emit_col_grand_totals(
    totals, forced_definition, buckets, row_keys, col_keys, data_field_count,
  )
  emit_row_grand_totals(
    totals, forced_definition, buckets, row_keys, col_keys, data_field_count,
  )
  emit_overall_grand_total(
    totals, forced_definition, buckets, row_keys, col_keys, data_field_count,
  )
  append_calculated_field_cells(
    totals, forced_definition, cache, kept_rows, row_field_positions, col_field_positions,
    row_keys, col_keys,
  )
  for cell in totals {
    push_missing_pivot_result_cell(basis, cell)
  }
  basis
}

///|
fn push_missing_pivot_result_cell(
  cells : Array[PivotResultCell],
  cell : PivotResultCell,
) -> Unit {
  match
    find_pivot_result_cell(
      cells,
      cell.row_key,
      cell.col_key,
      cell.data_field_index,
    ) {
    Some(_) => ()
    None => cells.push(cell)
  }
}

///|
/// §18.10.1.22 `dataField/@showDataAs` display transforms. The
/// aggregate pass above remains the only place that computes bucket
/// values; this pass projects those already-materialized values into
/// supported percentage display modes. Because it mutates
/// `PivotResultCell.aggregated_value` before returning the
/// `PivotMaterialization`, rendering and GETPIVOTDATA share the same
/// display-value source.
fn apply_show_data_as(
  cells : Array[PivotResultCell],
  definition : PivotTableDefinition,
  basis_cells : Array[PivotResultCell],
) -> Unit {
  if cells.length() == 0 {
    return
  }
  for i in 0..<cells.length() {
    let cell = cells[i]
    match show_data_as_mode(definition, cell.data_field_index) {
      Some("difference") =>
        cells[i] = {
          ..cell,
          aggregated_value: difference_from_base(cell, definition, basis_cells),
        }
      Some("percent") =>
        cells[i] = {
          ..cell,
          aggregated_value: percent_of_base(cell, definition, basis_cells),
        }
      Some("percentDiff") =>
        cells[i] = {
          ..cell,
          aggregated_value: percent_difference_from_base(
            cell, definition, basis_cells,
          ),
        }
      Some("runTotal") =>
        cells[i] = {
          ..cell,
          aggregated_value: running_total(cell, definition, basis_cells),
        }
      Some("percentOfRow") =>
        cells[i] = {
          ..cell,
          aggregated_value: percent_of_row(cell, basis_cells),
        }
      Some("percentOfCol") =>
        cells[i] = {
          ..cell,
          aggregated_value: percent_of_col(cell, basis_cells),
        }
      Some("percentOfTotal") =>
        cells[i] = {
          ..cell,
          aggregated_value: percent_of_total(cell, basis_cells),
        }
      Some("index") =>
        cells[i] = { ..cell, aggregated_value: index_value(cell, basis_cells) }
      _ => ()
    }
  }
}

///|
fn show_data_as_mode(
  definition : PivotTableDefinition,
  data_field_index : Int,
) -> String? {
  if data_field_index < 0 || data_field_index >= definition.data_fields.length() {
    return None
  }
  match definition.data_fields[data_field_index].show_data_as {
    Some(mode) => Some(mode.to_string())
    None => None
  }
}

///|
fn difference_from_base(
  cell : PivotResultCell,
  definition : PivotTableDefinition,
  base_cells : Array[PivotResultCell],
) -> @formula.FormulaValue {
  match
    (
      pivot_cell_number(cell),
      base_axis_cell_number(cell, definition, base_cells),
    ) {
    (Some(value), Some(base)) => @formula.VNumber(value - base)
    _ => cell.aggregated_value
  }
}

///|
fn percent_of_base(
  cell : PivotResultCell,
  definition : PivotTableDefinition,
  base_cells : Array[PivotResultCell],
) -> @formula.FormulaValue {
  match
    (
      pivot_cell_number(cell),
      base_axis_cell_number(cell, definition, base_cells),
    ) {
    (Some(value), Some(base)) => pivot_ratio(value, base)
    _ => cell.aggregated_value
  }
}

///|
fn percent_difference_from_base(
  cell : PivotResultCell,
  definition : PivotTableDefinition,
  base_cells : Array[PivotResultCell],
) -> @formula.FormulaValue {
  match
    (
      pivot_cell_number(cell),
      base_axis_cell_number(cell, definition, base_cells),
    ) {
    (Some(value), Some(base)) => pivot_ratio(value - base, base)
    _ => cell.aggregated_value
  }
}

///|
fn running_total(
  cell : PivotResultCell,
  definition : PivotTableDefinition,
  base_cells : Array[PivotResultCell],
) -> @formula.FormulaValue {
  match base_axis_position(definition, cell.data_field_index) {
    Some(axis) =>
      match pivot_cell_number(cell) {
        Some(_) => running_total_for_axis(cell, axis, base_cells)
        None => cell.aggregated_value
      }
    None => cell.aggregated_value
  }
}

///|
fn index_value(
  cell : PivotResultCell,
  base_cells : Array[PivotResultCell],
) -> @formula.FormulaValue {
  match pivot_cell_number(cell) {
    Some(value) =>
      match row_total_number(base_cells, cell) {
        Some(row_total) =>
          match col_total_number(base_cells, cell) {
            Some(col_total) =>
              match overall_total_number(base_cells, cell.data_field_index) {
                Some(grand_total) =>
                  pivot_ratio(value * grand_total, row_total * col_total)
                None => cell.aggregated_value
              }
            None => cell.aggregated_value
          }
        None => cell.aggregated_value
      }
    None => cell.aggregated_value
  }
}

///|
priv enum BaseAxisPosition {
  RowAxis(Int)
  ColAxis(Int)
}

///|
fn base_axis_cell_number(
  cell : PivotResultCell,
  definition : PivotTableDefinition,
  base_cells : Array[PivotResultCell],
) -> Double? {
  let data_field = match definition.data_fields.get(cell.data_field_index) {
    Some(value) => value
    None => return None
  }
  let base_item = match data_field.base_item {
    Some(value) => value
    None => return None
  }
  match base_axis_position(definition, cell.data_field_index) {
    Some(RowAxis(position)) =>
      match replace_axis_item(cell.row_key, position, base_item) {
        Some(row_key) =>
          find_pivot_cell_number(
            base_cells,
            row_key,
            cell.col_key,
            cell.data_field_index,
          )
        None => None
      }
    Some(ColAxis(position)) =>
      match replace_axis_item(cell.col_key, position, base_item) {
        Some(col_key) =>
          find_pivot_cell_number(
            base_cells,
            cell.row_key,
            col_key,
            cell.data_field_index,
          )
        None => None
      }
    None => None
  }
}

///|
fn base_axis_position(
  definition : PivotTableDefinition,
  data_field_index : Int,
) -> BaseAxisPosition? {
  let data_field = match definition.data_fields.get(data_field_index) {
    Some(value) => value
    None => return None
  }
  let base_field = match data_field.base_field {
    Some(value) => value
    None => return None
  }
  match
    axis_field_position(
      extract_real_field_positions(definition.row_fields),
      base_field,
    ) {
    Some(position) => Some(RowAxis(position))
    None =>
      match
        axis_field_position(
          extract_real_field_positions(definition.col_fields),
          base_field,
        ) {
        Some(position) => Some(ColAxis(position))
        None => None
      }
  }
}

///|
fn axis_field_position(fields : Array[Int], field : Int) -> Int? {
  for index in 0..<fields.length() {
    if fields[index] == field {
      return Some(index)
    }
  }
  None
}

///|
fn replace_axis_item(
  key : PivotAxisKey,
  position : Int,
  item : Int,
) -> PivotAxisKey? {
  match key {
    Items(indices) =>
      if position >= 0 && position < indices.length() {
        let out = indices.copy()
        out[position] = item
        Some(Items(out))
      } else {
        None
      }
    _ => None
  }
}

///|
fn running_total_for_axis(
  cell : PivotResultCell,
  axis : BaseAxisPosition,
  base_cells : Array[PivotResultCell],
) -> @formula.FormulaValue {
  let current_item = match axis_item_at(cell, axis) {
    Some(item) => item
    None => return cell.aggregated_value
  }
  let mut total = 0.0
  let mut saw_value = false
  for candidate in base_cells {
    if candidate.data_field_index == cell.data_field_index &&
      same_axis_except_position(candidate, cell, axis) {
      match axis_item_at(candidate, axis) {
        Some(item) =>
          if item <= current_item {
            match pivot_cell_number(candidate) {
              Some(value) => {
                total += value
                saw_value = true
              }
              None => ()
            }
          }
        None => ()
      }
    }
  }
  if saw_value {
    @formula.VNumber(total)
  } else {
    cell.aggregated_value
  }
}

///|
fn axis_item_at(cell : PivotResultCell, axis : BaseAxisPosition) -> Int? {
  match axis {
    RowAxis(position) => axis_key_item_at(cell.row_key, position)
    ColAxis(position) => axis_key_item_at(cell.col_key, position)
  }
}

///|
fn axis_key_item_at(key : PivotAxisKey, position : Int) -> Int? {
  match key {
    Items(indices) =>
      if position >= 0 && position < indices.length() {
        Some(indices[position])
      } else {
        None
      }
    _ => None
  }
}

///|
fn same_axis_except_position(
  candidate : PivotResultCell,
  cell : PivotResultCell,
  axis : BaseAxisPosition,
) -> Bool {
  match axis {
    RowAxis(position) =>
      candidate.col_key == cell.col_key &&
      axis_key_matches_except(candidate.row_key, cell.row_key, position)
    ColAxis(position) =>
      candidate.row_key == cell.row_key &&
      axis_key_matches_except(candidate.col_key, cell.col_key, position)
  }
}

///|
fn axis_key_matches_except(
  left : PivotAxisKey,
  right : PivotAxisKey,
  skip : Int,
) -> Bool {
  match (left, right) {
    (Items(left_items), Items(right_items)) => {
      if left_items.length() != right_items.length() {
        return false
      }
      for index in 0..<left_items.length() {
        if index != skip && left_items[index] != right_items[index] {
          return false
        }
      }
      true
    }
    _ => left == right
  }
}

///|
fn percent_of_row(
  cell : PivotResultCell,
  base_cells : Array[PivotResultCell],
) -> @formula.FormulaValue {
  match pivot_cell_number(cell) {
    Some(numerator) =>
      match row_total_number(base_cells, cell) {
        Some(denominator) => pivot_ratio(numerator, denominator)
        None => cell.aggregated_value
      }
    None => cell.aggregated_value
  }
}

///|
fn percent_of_col(
  cell : PivotResultCell,
  base_cells : Array[PivotResultCell],
) -> @formula.FormulaValue {
  match pivot_cell_number(cell) {
    Some(numerator) =>
      match col_total_number(base_cells, cell) {
        Some(denominator) => pivot_ratio(numerator, denominator)
        None => cell.aggregated_value
      }
    None => cell.aggregated_value
  }
}

///|
fn percent_of_total(
  cell : PivotResultCell,
  base_cells : Array[PivotResultCell],
) -> @formula.FormulaValue {
  match pivot_cell_number(cell) {
    Some(numerator) =>
      match overall_total_number(base_cells, cell.data_field_index) {
        Some(denominator) => pivot_ratio(numerator, denominator)
        None => cell.aggregated_value
      }
    None => cell.aggregated_value
  }
}

///|
fn row_total_number(
  cells : Array[PivotResultCell],
  cell : PivotResultCell,
) -> Double? {
  match
    find_pivot_cell_number(cells, cell.row_key, ColGrand, cell.data_field_index) {
    Some(value) => Some(value)
    None =>
      if cell.col_key == ColGrand {
        pivot_cell_number(cell)
      } else {
        None
      }
  }
}

///|
fn col_total_number(
  cells : Array[PivotResultCell],
  cell : PivotResultCell,
) -> Double? {
  match
    find_pivot_cell_number(cells, RowGrand, cell.col_key, cell.data_field_index) {
    Some(value) => Some(value)
    None =>
      if cell.row_key == RowGrand {
        pivot_cell_number(cell)
      } else {
        None
      }
  }
}

///|
fn overall_total_number(
  cells : Array[PivotResultCell],
  data_field_index : Int,
) -> Double? {
  find_pivot_cell_number(cells, RowGrand, ColGrand, data_field_index)
}

///|
fn find_pivot_cell_number(
  cells : Array[PivotResultCell],
  row_key : PivotAxisKey,
  col_key : PivotAxisKey,
  data_field_index : Int,
) -> Double? {
  match find_pivot_result_cell(cells, row_key, col_key, data_field_index) {
    Some(cell) => pivot_cell_number(cell)
    None => None
  }
}

///|
fn pivot_cell_number(cell : PivotResultCell) -> Double? {
  coerce_value_to_number(cell.aggregated_value)
}

///|
fn pivot_ratio(
  numerator : Double,
  denominator : Double,
) -> @formula.FormulaValue {
  if denominator == 0.0 {
    @formula.VError(@formula.FormulaError::DivZero)
  } else {
    @formula.VNumber(numerator / denominator)
  }
}
