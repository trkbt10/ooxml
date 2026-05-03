///|
fn register_builtin_reference_functions(registry : FunctionRegistry) -> Unit {
  registry.register("ROW", Lazy(fn_row))
  registry.register("COLUMN", Lazy(fn_column))
  registry.register("ROWS", Eager(fn_rows))
  registry.register("COLUMNS", Eager(fn_columns))
  registry.register("ADDRESS", Eager(fn_address))
  registry.register("AREAS", Eager(fn_areas))
}

///|
/// §18.17.7.ROW — return the 1-based row number of a reference or current cell.
fn fn_row(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  if args.length() > 1 {
    return VError(Value)
  }
  if args.length() == 0 {
    return VNumber((ctx.current_cell.row_zero_based + 1).to_double())
  }
  match reference_rect_from_ast(args[0], ctx) {
    Some(rect) => VNumber((rect.start_row + 1).to_double())
    None => {
      let value = evaluate(args[0], ctx)
      match value.first_error() {
        Some(err) => VError(err)
        None => VError(Ref)
      }
    }
  }
}

///|
/// §18.17.7.COLUMN — return the 1-based column number of a reference or current cell.
fn fn_column(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  if args.length() > 1 {
    return VError(Value)
  }
  if args.length() == 0 {
    return VNumber((ctx.current_cell.col_zero_based + 1).to_double())
  }
  match reference_rect_from_ast(args[0], ctx) {
    Some(rect) => VNumber((rect.start_col + 1).to_double())
    None => {
      let value = evaluate(args[0], ctx)
      match value.first_error() {
        Some(err) => VError(err)
        None => VError(Ref)
      }
    }
  }
}

///|
/// §18.17.7.ROWS — return the number of rows in an array or range value.
fn fn_rows(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_error() {
    Some(err) => VError(err)
    None => {
      let rows = value_to_array(args[0])
      VNumber(rows.length().to_double())
    }
  }
}

///|
/// §18.17.7.COLUMNS — return the number of columns in an array or range value.
fn fn_columns(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_error() {
    Some(err) => VError(err)
    None => {
      let rows = value_to_array(args[0])
      let cols = if rows.length() == 0 { 0 } else { rows[0].length() }
      VNumber(cols.to_double())
    }
  }
}

///|
/// §18.17.7.ADDRESS — build a text address from 1-based row and column coordinates.
fn fn_address(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 2 || args.length() > 5 {
    return VError(Value)
  }
  let row_num = lookup_positive_index(args[0], ctx)
  let col_num = lookup_positive_index(args[1], ctx)
  let abs_num = if args.length() >= 3 {
    lookup_positive_index(args[2], ctx)
  } else {
    VNumber(1.0)
  }
  let a1 = lookup_optional_bool(args, 3, true)
  let sheet = if args.length() >= 5 { scalar_text(args[4]) } else { VEmpty }
  match (row_num, col_num, abs_num, a1, sheet) {
    (VNumber(row), VNumber(col), VNumber(abs), VBool(use_a1), sheet_value) =>
      build_address_text(
        row.to_int(),
        col.to_int(),
        abs.to_int(),
        use_a1,
        sheet_value,
      )
    (VError(err), _, _, _, _)
    | (_, VError(err), _, _, _)
    | (_, _, VError(err), _, _)
    | (_, _, _, VError(err), _)
    | (_, _, _, _, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.AREAS — return the number of areas represented by a reference value.
fn fn_areas(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_error() {
    Some(err) => VError(err)
    None => VNumber(1.0)
  }
}

///|
fn build_address_text(
  row : Int,
  col : Int,
  abs_num : Int,
  use_a1 : Bool,
  sheet_value : FormulaValue,
) -> FormulaValue {
  if row < 1 || col < 1 || abs_num < 1 || abs_num > 4 {
    return VError(Value)
  }
  let sheet = match sheet_value {
    VString(text) => if text == "" { None } else { Some(text) }
    VEmpty => None
    _ => return VError(Value)
  }
  let col_abs = abs_num == 1 || abs_num == 3
  let row_abs = abs_num == 1 || abs_num == 2
  let cell = @address.CellAddress::{
    col_zero_based: col - 1,
    row_zero_based: row - 1,
    col_absolute: col_abs,
    row_absolute: row_abs,
    sheet,
  }
  if use_a1 {
    VString(cell.to_a1())
  } else {
    VString(cell.to_r1c1())
  }
}
