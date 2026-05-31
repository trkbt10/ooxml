// §18.10.1.3 calculated fields — a `<cacheField>` carrying a `@formula`
// (with `databaseField="0"`) is a CALCULATED field: its value is not
// stored per record but derived from a formula over the OTHER fields.
//
// Per the reference implementation's documented behaviour a calculated
// field evaluates its formula against the AGGREGATED (summed) operands
// of each cell, NOT per record — e.g. a `=Price*Units` field shows
// SUM(Price)·SUM(Units) for every (row, col) cell, not SUM(Price·Units).
// This module evaluates that as an additive pass over the materialized
// grid: the main aggregation leaves calculated-field cells absent (their
// per-record bucket is empty), and `append_calculated_field_cells`
// re-derives them from the kept records.  Pivots with no calculated
// field skip this entirely, so their output is unchanged.

///|
/// A calculated data field ready for evaluation: its index within
/// `definition.data_fields`, the parsed formula AST, and the map of
/// referenced cache-field NAME → cache-field INDEX (only lexemes that
/// match a real cache field; cell-like lexemes are ignored).
priv struct CalcField {
  data_field_index : Int
  ast : @formula.FormulaAst
  refs : Map[String, Int]
}

///|
/// §18.10.1.3 — true when the data field at `data_field_index` points
/// at a calculated cache field (carries a `@formula`).  Such fields
/// have no per-record value, so the main bucket-fill skips them (and
/// avoids indexing `row.cells` at a field the records don't store);
/// `append_calculated_field_cells` derives their cells instead.
fn is_calc_data_field(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  data_field_index : Int,
) -> Bool {
  guard data_field_index >= 0 &&
    data_field_index < definition.data_fields.length() else {
    return false
  }
  let fld = definition.data_fields[data_field_index].fld
  guard fld >= 0 && fld < cache.cache_fields.length() else { return false }
  cache.cache_fields[fld].formula is Some(_)
}

///|
/// Detect calculated data fields and pre-parse their formulas.  A
/// formula that fails to parse is skipped (its cells stay blank — the
/// honest fallback rather than a wrong value).
fn collect_calc_fields(
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
) -> Array[CalcField] {
  let out : Array[CalcField] = []
  let name_to_idx : Map[String, Int] = Map(
    [],
    capacity=cache.cache_fields.length(),
  )
  for i, cf in cache.cache_fields {
    name_to_idx[cf.name] = i
  }
  for d, df in definition.data_fields {
    if df.fld < 0 || df.fld >= cache.cache_fields.length() {
      continue
    }
    let cf = cache.cache_fields[df.fld]
    guard cf.formula is Some(src) else { continue }
    let ast = (try? @formula.parse_formula(src)).to_option()
    match ast {
      Some(a) => {
        let refs : Map[String, Int] = Map([], capacity=0)
        collect_reference_names(a, fn(name) {
          match name_to_idx.get(name) {
            Some(idx) => refs[name] = idx
            None => ()
          }
        })
        out.push({ data_field_index: d, ast: a, refs })
      }
      None => ()
    }
  }
  out
}

///|
/// Walk `ast`, invoking `visit` for every reference lexeme (cell ref or
/// name).  The caller filters lexemes that match a cache-field name.
fn collect_reference_names(
  ast : @formula.FormulaAst,
  visit : (String) -> Unit,
) -> Unit {
  match ast {
    @formula.Reference(lex) => visit(lex)
    @formula.Function(_, args) =>
      for a in args {
        collect_reference_names(a, visit)
      }
    @formula.Unary(_, inner) => collect_reference_names(inner, visit)
    @formula.Binary(_, l, r) => {
      collect_reference_names(l, visit)
      collect_reference_names(r, visit)
    }
    @formula.Array2D(rows) =>
      for row in rows {
        for a in row {
          collect_reference_names(a, visit)
        }
      }
    @formula.Literal(_) => ()
  }
}

///|
/// Evaluate one calculated field over a subset of cache rows: each
/// referenced field is summed across the subset (the documented
/// calc-field semantics), then the formula is evaluated with those
/// sums substituted for the field names.
fn eval_calc_field_over_rows(
  calc : CalcField,
  rows : Array[PivotCacheRow],
  cache : PivotCacheDefinition,
) -> @formula.FormulaValue raise @opc_errors.SchemaViolation {
  let agg : Map[String, @formula.FormulaValue] = Map(
    [],
    capacity=calc.refs.size(),
  )
  for name, fld in calc.refs {
    let vals : Array[@formula.FormulaValue] = []
    for row in rows {
      if fld >= 0 && fld < row.cells.length() {
        vals.push(
          pivot_record_cell_to_formula_value(
            row.cells[fld],
            cache.cache_fields[fld],
          ),
        )
      }
    }
    agg[name] = aggregate(vals, Sum)
  }
  let ctx : @formula.EvalContext = {
    current_sheet: "",
    current_cell: {
      col_zero_based: 0,
      row_zero_based: 0,
      col_absolute: false,
      row_absolute: false,
      sheet: None,
    },
    sst: None,
    date_system: @date_serial.DateSystem::Serial1900,
    registry: @formula.FunctionRegistry::new(),
    resolve_cell: fn(_addr) { @formula.VEmpty },
    resolve_name: fn(name) {
      match agg.get(name) {
        Some(@formula.VNumber(n)) =>
          Some(@formula.Literal(@formula.LitNumber(n)))
        Some(@formula.VString(s)) =>
          Some(@formula.Literal(@formula.LitString(s)))
        Some(@formula.VBool(b)) => Some(@formula.Literal(@formula.LitBool(b)))
        // An empty / non-scalar operand contributes zero (Excel treats
        // a blank pivot operand as 0 in arithmetic).
        _ => Some(@formula.Literal(@formula.LitNumber(0.0)))
      }
    },
  }
  @formula.evaluate(calc.ast, ctx)
}

///|
/// Append calculated-field result cells to `cells`.  For every
/// (row_key, col_key) body combination — plus the requested grand-total
/// sentinels — the calc field is evaluated over the matching kept rows.
/// Called only when `collect_calc_fields` finds at least one calc field,
/// so non-calc pivots are unaffected.
fn append_calculated_field_cells(
  cells : Array[PivotResultCell],
  definition : PivotTableDefinition,
  cache : PivotCacheDefinition,
  kept_rows : Array[PivotCacheRow],
  row_field_positions : Array[Int],
  col_field_positions : Array[Int],
  row_keys : Array[PivotAxisKey],
  col_keys : Array[PivotAxisKey],
) -> Unit raise @opc_errors.SchemaViolation {
  let calc_fields = collect_calc_fields(definition, cache)
  if calc_fields.length() == 0 {
    return
  }
  // Pre-compute each kept row's (row_key, col_key) so subset selection
  // is a single linear scan per cell.
  let row_axis : Array[PivotAxisKey] = []
  let col_axis : Array[PivotAxisKey] = []
  for row in kept_rows {
    row_axis.push(build_axis_key(row, row_field_positions))
    col_axis.push(build_axis_key(row, col_field_positions))
  }
  // Collect the rows matching a (row_key?, col_key?) predicate; `None`
  // matches any key on that axis (used for grand totals).
  fn subset(rk : PivotAxisKey?, ck : PivotAxisKey?) -> Array[PivotCacheRow] {
    let out : Array[PivotCacheRow] = []
    for i, row in kept_rows {
      let row_ok = match rk {
        Some(k) => row_axis[i] == k
        None => true
      }
      let col_ok = match ck {
        Some(k) => col_axis[i] == k
        None => true
      }
      if row_ok && col_ok {
        out.push(row)
      }
    }
    out
  }

  for calc in calc_fields {
    // Body cells.
    for rk in row_keys {
      for ck in col_keys {
        let rows = subset(Some(rk), Some(ck))
        if rows.length() == 0 {
          continue
        }
        cells.push({
          row_key: rk,
          col_key: ck,
          data_field_index: calc.data_field_index,
          aggregated_value: eval_calc_field_over_rows(calc, rows, cache),
        })
      }
    }
    // §18.10.1.73 grand totals — match the sentinels the main pass
    // appends so the renderer's `find()` lands on them.
    if definition.col_grand_totals && col_keys.length() > 0 {
      for rk in row_keys {
        let rows = subset(Some(rk), None)
        if rows.length() == 0 {
          continue
        }
        cells.push({
          row_key: rk,
          col_key: ColGrand,
          data_field_index: calc.data_field_index,
          aggregated_value: eval_calc_field_over_rows(calc, rows, cache),
        })
      }
    }
    if definition.row_grand_totals && row_keys.length() > 0 {
      for ck in col_keys {
        let rows = subset(None, Some(ck))
        if rows.length() == 0 {
          continue
        }
        cells.push({
          row_key: RowGrand,
          col_key: ck,
          data_field_index: calc.data_field_index,
          aggregated_value: eval_calc_field_over_rows(calc, rows, cache),
        })
      }
    }
    if definition.row_grand_totals &&
      definition.col_grand_totals &&
      row_keys.length() > 0 &&
      col_keys.length() > 0 {
      let rows = subset(None, None)
      if rows.length() > 0 {
        cells.push({
          row_key: RowGrand,
          col_key: ColGrand,
          data_field_index: calc.data_field_index,
          aggregated_value: eval_calc_field_over_rows(calc, rows, cache),
        })
      }
    }
  }
}
