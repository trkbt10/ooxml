///|
fn register_builtin_lookup_functions(registry : FunctionRegistry) -> Unit {
  registry.register("VLOOKUP", Eager(fn_vlookup))
  registry.register("HLOOKUP", Eager(fn_hlookup))
  registry.register("LOOKUP", Eager(fn_lookup))
  registry.register("MATCH", Eager(fn_match))
  registry.register("INDEX", Eager(fn_index))
  registry.register("CHOOSE", Eager(fn_choose))
  registry.register("OFFSET", Lazy(fn_offset))
  registry.register("INDIRECT", Eager(fn_indirect))
}

///|
/// §18.17.7.VLOOKUP — find a value in the first table column and return from a selected column.
fn fn_vlookup(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 && args.length() != 4 {
    return VError(Value)
  }
  let table = value_to_array(args[1])
  if table.length() == 0 || table[0].length() == 0 {
    return VError(NotApplicable)
  }
  let col_index = lookup_positive_index(args[2], ctx)
  let approximate = lookup_optional_bool(args, 3, true)
  match (col_index, approximate) {
    (VNumber(col), VBool(range_lookup)) => {
      let col_idx = col.to_int() - 1
      if col_idx < 0 || col_idx >= table[0].length() {
        return VError(Ref)
      }
      let pos = lookup_match_in_column(args[0], table, 0, range_lookup)
      match pos {
        Some(row_idx) => table[row_idx][col_idx]
        None => VError(NotApplicable)
      }
    }
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.HLOOKUP — find a value in the first table row and return from a selected row.
fn fn_hlookup(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 && args.length() != 4 {
    return VError(Value)
  }
  let table = value_to_array(args[1])
  if table.length() == 0 || table[0].length() == 0 {
    return VError(NotApplicable)
  }
  let row_index = lookup_positive_index(args[2], ctx)
  let approximate = lookup_optional_bool(args, 3, true)
  match (row_index, approximate) {
    (VNumber(row), VBool(range_lookup)) => {
      let row_idx = row.to_int() - 1
      if row_idx < 0 || row_idx >= table.length() {
        return VError(Ref)
      }
      let pos = lookup_match_in_row(args[0], table, 0, range_lookup)
      match pos {
        Some(col_idx) => table[row_idx][col_idx]
        None => VError(NotApplicable)
      }
    }
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.LOOKUP — find an approximate match in one vector and return the paired result.
fn fn_lookup(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 && args.length() != 3 {
    return VError(Value)
  }
  let lookup_vector = flatten_lookup_vector(args[1])
  let result_vector = if args.length() == 3 {
    flatten_lookup_vector(args[2])
  } else {
    lookup_vector
  }
  if lookup_vector.length() == 0 || result_vector.length() == 0 {
    return VError(NotApplicable)
  }
  let limit = lookup_vector.length().min(result_vector.length())
  let mut best : Int? = None
  for i in 0..<limit {
    let candidate = lookup_vector[i].first_scalar()
    if candidate is VError(err) {
      return VError(err)
    }
    if compare_formula_values(candidate, args[0].first_scalar()) <= 0 {
      best = Some(i)
    }
  }
  match best {
    Some(idx) => result_vector[idx]
    None => VError(NotApplicable)
  }
}

///|
/// §18.17.7.MATCH — return the 1-based position of a value in a vector.
fn fn_match(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 && args.length() != 3 {
    return VError(Value)
  }
  let match_type = if args.length() == 3 {
    match scalar_number(args[2], ctx) {
      VNumber(n) => n.trunc().to_int()
      VError(err) => return VError(err)
      _ => return VError(Value)
    }
  } else {
    1
  }
  if match_type != -1 && match_type != 0 && match_type != 1 {
    return VError(NotApplicable)
  }
  let vector = flatten_lookup_vector(args[1])
  match lookup_match_position(args[0], vector, match_type) {
    Some(idx) => VNumber((idx + 1).to_double())
    None => VError(NotApplicable)
  }
}

///|
/// §18.17.7.INDEX — return a 1-based item or whole column from an array.
fn fn_index(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 && args.length() != 3 {
    return VError(Value)
  }
  let rows = value_to_array(args[0])
  if rows.length() == 0 {
    return VError(Ref)
  }
  let row_num = lookup_integer_arg(args[1], ctx)
  let col_num = if args.length() == 3 {
    lookup_integer_arg(args[2], ctx)
  } else {
    VNumber(1.0)
  }
  match (row_num, col_num) {
    (VNumber(row), VNumber(col)) =>
      index_from_array(rows, row.to_int(), col.to_int())
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.CHOOSE — select the Nth value argument by 1-based index.
fn fn_choose(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 2 {
    return VError(Value)
  }
  let index = lookup_positive_index(args[0], ctx)
  match index {
    VNumber(n) => {
      let idx = n.to_int()
      if idx < 1 || idx >= args.length() {
        VError(Value)
      } else {
        args[idx]
      }
    }
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.OFFSET — return a reference shifted by rows and columns with optional size.
fn fn_offset(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 && args.length() != 4 && args.length() != 5 {
    return VError(Value)
  }
  let base = match reference_rect_from_ast(args[0], ctx) {
    Some(rect) => rect
    None => return VError(Ref)
  }
  let rows = lookup_eval_integer_arg(args[1], ctx)
  let cols = lookup_eval_integer_arg(args[2], ctx)
  let height = if args.length() >= 4 {
    lookup_eval_integer_arg(args[3], ctx)
  } else {
    VNumber((base.end_row - base.start_row + 1).to_double())
  }
  let width = if args.length() >= 5 {
    lookup_eval_integer_arg(args[4], ctx)
  } else {
    VNumber((base.end_col - base.start_col + 1).to_double())
  }
  match (rows, cols, height, width) {
    (VNumber(r), VNumber(c), VNumber(h), VNumber(w)) =>
      materialize_offset_rect(
        base,
        r.to_int(),
        c.to_int(),
        h.to_int(),
        w.to_int(),
        ctx,
      )
    (VError(err), _, _, _)
    | (_, VError(err), _, _)
    | (_, _, VError(err), _)
    | (_, _, _, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.INDIRECT — resolve text as an A1 or R1C1 cell reference.
fn fn_indirect(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 && args.length() != 2 {
    return VError(Value)
  }
  let text = scalar_text(args[0])
  let a1 = lookup_optional_bool(args, 1, true)
  match (text, a1) {
    (VString(ref_text), VBool(use_a1)) => {
      let cell : @address.CellAddress? = if use_a1 {
        Some(@address.CellAddress::parse_a1(ref_text)) catch {
          _ => None
        }
      } else {
        Some(@address.CellAddress::parse_r1c1(ref_text)) catch {
          _ => None
        }
      }
      match cell {
        Some(address) =>
          (ctx.resolve_cell)(normalize_indirect_cell(address, use_a1, ctx))
        None => VError(Ref)
      }
    }
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
fn lookup_match_in_column(
  lookup_value : FormulaValue,
  table : Array[Array[FormulaValue]],
  col_idx : Int,
  approximate : Bool,
) -> Int? {
  let vector = Array::new(capacity=table.length())
  for row in table {
    if col_idx >= row.length() {
      return None
    }
    vector.push(row[col_idx])
  }
  lookup_match_position(lookup_value, vector, if approximate { 1 } else { 0 })
}

///|
fn lookup_match_in_row(
  lookup_value : FormulaValue,
  table : Array[Array[FormulaValue]],
  row_idx : Int,
  approximate : Bool,
) -> Int? {
  if row_idx >= table.length() {
    return None
  }
  lookup_match_position(
    lookup_value,
    table[row_idx],
    if approximate {
      1
    } else {
      0
    },
  )
}

///|
fn lookup_match_position(
  lookup_value : FormulaValue,
  vector : Array[FormulaValue],
  match_type : Int,
) -> Int? {
  let needle = lookup_value.first_scalar()
  if needle is VError(_) {
    return None
  }
  if match_type == 0 {
    for i in 0..<vector.length() {
      if compare_formula_values(vector[i].first_scalar(), needle) == 0 {
        return Some(i)
      }
    }
    None
  } else if match_type > 0 {
    let mut best : Int? = None
    for i in 0..<vector.length() {
      if compare_formula_values(vector[i].first_scalar(), needle) <= 0 {
        best = Some(i)
      }
    }
    best
  } else {
    let mut best : Int? = None
    for i in 0..<vector.length() {
      if compare_formula_values(vector[i].first_scalar(), needle) >= 0 {
        best = Some(i)
      }
    }
    best
  }
}

///|
fn flatten_lookup_vector(value : FormulaValue) -> Array[FormulaValue] {
  let rows = value_to_array(value)
  let out = Array::new()
  if rows.length() == 1 {
    for item in rows[0] {
      out.push(item)
    }
  } else {
    for row in rows {
      if row.length() > 0 {
        out.push(row[0])
      }
    }
  }
  out
}

///|
fn index_from_array(
  rows : Array[Array[FormulaValue]],
  row_num : Int,
  col_num : Int,
) -> FormulaValue {
  if col_num < 1 {
    return VError(Ref)
  }
  if row_num == 0 {
    let out = Array::new(capacity=rows.length())
    for row in rows {
      if col_num > row.length() {
        return VError(Ref)
      }
      out.push([row[col_num - 1]])
    }
    return VArray(out)
  }
  if row_num < 1 || row_num > rows.length() {
    return VError(Ref)
  }
  if col_num > rows[row_num - 1].length() {
    return VError(Ref)
  }
  rows[row_num - 1][col_num - 1]
}

///|
fn materialize_offset_rect(
  base : ReferenceRect,
  rows : Int,
  cols : Int,
  height : Int,
  width : Int,
  ctx : EvalContext,
) -> FormulaValue {
  if height <= 0 || width <= 0 {
    return VError(Ref)
  }
  let rect = ReferenceRect::{
    start_col: base.start_col + cols,
    start_row: base.start_row + rows,
    end_col: base.start_col + cols + width - 1,
    end_row: base.start_row + rows + height - 1,
    sheet: base.sheet,
  }
  if rect.start_col < 0 || rect.start_row < 0 {
    VError(Ref)
  } else {
    materialize_rect(rect, ctx)
  }
}

///|
fn normalize_indirect_cell(
  cell : @address.CellAddress,
  use_a1 : Bool,
  ctx : EvalContext,
) -> @address.CellAddress {
  @address.CellAddress::{
    col_zero_based: if use_a1 || cell.col_absolute {
      cell.col_zero_based
    } else {
      ctx.current_cell.col_zero_based + cell.col_zero_based
    },
    row_zero_based: if use_a1 || cell.row_absolute {
      cell.row_zero_based
    } else {
      ctx.current_cell.row_zero_based + cell.row_zero_based
    },
    col_absolute: true,
    row_absolute: true,
    sheet: ctx.current_sheet_or(cell.sheet),
  }
}

///|
fn lookup_positive_index(
  value : FormulaValue,
  ctx : EvalContext,
) -> FormulaValue {
  match scalar_number(value, ctx) {
    VNumber(n) => if n < 1.0 { VError(Value) } else { VNumber(n.trunc()) }
    other => other
  }
}

///|
fn lookup_integer_arg(value : FormulaValue, ctx : EvalContext) -> FormulaValue {
  match scalar_number(value, ctx) {
    VNumber(n) => VNumber(n.trunc())
    other => other
  }
}

///|
fn lookup_eval_integer_arg(ast : FormulaAst, ctx : EvalContext) -> FormulaValue {
  lookup_integer_arg(evaluate(ast, ctx), ctx)
}

///|
fn lookup_optional_bool(
  args : Array[FormulaValue],
  index : Int,
  default : Bool,
) -> FormulaValue {
  if args.length() <= index {
    VBool(default)
  } else {
    coerce_to_bool(args[index])
  }
}
