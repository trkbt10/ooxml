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
/// 1. Apply the §18.10.1.62 page-field filter: for each
///    `pageField/@item` that is `Some(i)`, keep only the rows whose
///    `field[pageField.fld]` cell resolves to shared item `i`.
/// 2. Walk the surviving rows, extract the row-axis key from
///    `def.row_fields` and the column-axis key from
///    `def.col_fields`, and intern the keys in insertion order so
///    the resulting `row_keys` / `col_keys` arrays preserve the
///    original record ordering (matches the §18.10.1.45 items
///    default).
/// 3. Bucket each `(row_idx, col_idx, data_field_index)` slot's
///    values, then apply the data field's `subtotal`
///    consolidation function (§18.18.17) via `aggregate`.
/// 4. When `row_grand_totals` / `col_grand_totals` is true (their
///    spec defaults), append the matching `RowGrand` / `ColGrand`
///    sentinel and emit the aggregated cells for the full
///    population.
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
  let kept_rows = apply_page_filter(definition, records)
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
  let row_keys = lut.row_keys
  let col_keys = lut.col_keys
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
  // §18.10.1.73 row/col grand totals — appended as sentinel
  // axis keys so the renderer can paint them differently.
  let row_keys_final : Array[PivotAxisKey] = []
  for entry in row_keys {
    row_keys_final.push(entry)
  }
  let col_keys_final : Array[PivotAxisKey] = []
  for entry in col_keys {
    col_keys_final.push(entry)
  }
  if definition.col_grand_totals && col_keys.length() > 0 {
    emit_col_grand_totals(
      cells, definition, buckets, row_keys, col_keys, data_field_count,
    )
    col_keys_final.push(ColGrand)
  }
  if definition.row_grand_totals && row_keys.length() > 0 {
    emit_row_grand_totals(
      cells, definition, buckets, row_keys, col_keys, data_field_count,
    )
    row_keys_final.push(RowGrand)
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
  {
    row_keys: row_keys_final,
    col_keys: col_keys_final,
    cells,
    data_field_count,
  }
}

///|
/// Validate that every `dataField/@fld` and `pageField/@fld`
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
/// Apply the §18.10.1.62 page-field selection to the records.
/// Each `pageField/@item` that is `Some(i)` requires the record's
/// `field[pageField.fld]` cell to resolve to shared item `i`;
/// `None` means "(All)" and keeps every record.
fn apply_page_filter(
  definition : PivotTableDefinition,
  records : PivotCacheRecords,
) -> Array[PivotCacheRow] {
  let kept : Array[PivotCacheRow] = []
  for row in records.rows {
    let mut keep = true
    for page_field in definition.page_fields {
      match page_field.item {
        Some(expected) => {
          let cell = row.cells[page_field.fld]
          match pivot_record_cell_shared_index(cell) {
            Some(actual) => if actual != expected { keep = false }
            None => keep = false
          }
        }
        None => ()
      }
    }
    if keep {
      kept.push(row)
    }
  }
  kept
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
