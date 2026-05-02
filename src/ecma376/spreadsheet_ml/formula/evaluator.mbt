///|
struct ReferenceRect {
  start_col : Int
  start_row : Int
  end_col : Int
  end_row : Int
  sheet : String?
} derive(Eq, Debug)

///|
/// §18.17 — evaluate a SpreadsheetML formula AST to a typed value. Evaluation
/// walks the tree, applies §18.17.2.2 operator semantics, dispatches registered
/// functions, and returns `VError` values for formula errors instead of raising.
pub fn evaluate(ast : FormulaAst, ctx : EvalContext) -> FormulaValue {
  match ast {
    Literal(value) => evaluate_literal(value)
    Reference(lexeme) => resolve_reference(lexeme, ctx)
    Function(name, args) => evaluate_function(name, args, ctx)
    Unary(op, inner) => evaluate_unary(op, evaluate(inner, ctx), ctx)
    Binary(op, left, right) => evaluate_binary(op, left, right, ctx)
    Array2D(rows) => evaluate_array_constant(rows, ctx)
  }
}

///|
/// §18.17.2.3 — resolve a formula reference lexeme through A1 address parsing
/// and caller-provided workbook lookup. Single cells produce a scalar, ranges
/// produce a row-major `VArray`, and unresolved defined names map to `#NAME?`.
pub fn resolve_reference(lexeme : String, ctx : EvalContext) -> FormulaValue {
  match reference_rect_from_lexeme(lexeme, ctx) {
    Some(rect) => materialize_rect(rect, ctx)
    None =>
      match (ctx.resolve_name)(lexeme) {
        Some(ast) => evaluate(ast, ctx)
        None =>
          if formula_looks_like_reference(lexeme) {
            VError(Ref)
          } else {
            VError(Name)
          }
      }
  }
}

///|
fn evaluate_literal(value : LiteralValue) -> FormulaValue {
  match value {
    LitNumber(value) => VNumber(value)
    LitString(value) => VString(value)
    LitBool(value) => VBool(value)
    LitError(value) =>
      match FormulaError::from_literal(value) {
        Some(err) => VError(err)
        None => VError(Value)
      }
  }
}

///|
fn evaluate_function(
  name : String,
  args : Array[FormulaAst],
  ctx : EvalContext,
) -> FormulaValue {
  match ctx.registry.lookup(name) {
    None => VError(Name)
    Some(Lazy(fn_impl)) => fn_impl(args, ctx)
    Some(Eager(fn_impl)) => {
      let values = Array::new(capacity=args.length())
      for arg in args {
        let value = evaluate(arg, ctx)
        if value is VError(_) {
          return value
        }
        values.push(value)
      }
      fn_impl(values, ctx)
    }
  }
}

///|
fn evaluate_unary(
  op : UnaryOp,
  value : FormulaValue,
  ctx : EvalContext,
) -> FormulaValue {
  match coerce_to_number(value, ctx.date_system) {
    VError(err) => VError(err)
    VNumber(number) =>
      match op {
        PrefixPlus => VNumber(number)
        PrefixMinus => VNumber(0.0 - number)
        PostfixPercent => VNumber(number / 100.0)
      }
    _ => VError(Value)
  }
}

///|
fn evaluate_binary(
  op : BinaryOp,
  left : FormulaAst,
  right : FormulaAst,
  ctx : EvalContext,
) -> FormulaValue {
  match op {
    Range => evaluate_range_operator(left, right, ctx)
    Intersect => evaluate_intersection_operator(left, right, ctx)
    Union => evaluate_union_operator(left, right, ctx)
    _ => {
      let lv = evaluate(left, ctx)
      if lv is VError(_) {
        return lv
      }
      let rv = evaluate(right, ctx)
      if rv is VError(_) {
        return rv
      }
      evaluate_scalar_binary(op, lv, rv, ctx)
    }
  }
}

///|
fn evaluate_scalar_binary(
  op : BinaryOp,
  left : FormulaValue,
  right : FormulaValue,
  ctx : EvalContext,
) -> FormulaValue {
  match op {
    Add | Sub | Mul | Div | Pow => evaluate_arithmetic(op, left, right, ctx)
    Concat => evaluate_concat(left, right)
    Eq | Neq | Lt | Gt | Le | Ge => evaluate_comparison(op, left, right)
    Range | Intersect | Union => VError(Value)
  }
}

///|
fn evaluate_arithmetic(
  op : BinaryOp,
  left : FormulaValue,
  right : FormulaValue,
  ctx : EvalContext,
) -> FormulaValue {
  let ln = coerce_to_number(left, ctx.date_system)
  if ln is VError(_) {
    return ln
  }
  let rn = coerce_to_number(right, ctx.date_system)
  if rn is VError(_) {
    return rn
  }
  match (ln, rn) {
    (VNumber(a), VNumber(b)) =>
      match op {
        Add => VNumber(a + b)
        Sub => VNumber(a - b)
        Mul => VNumber(a * b)
        Div => if b == 0.0 { VError(DivZero) } else { VNumber(a / b) }
        Pow =>
          if a < 0.0 && !formula_is_integer(b) {
            VError(Num)
          } else {
            let value = @math.pow(a, b)
            if value.is_nan() || value.is_inf() {
              VError(Num)
            } else {
              VNumber(value)
            }
          }
        _ => VError(Value)
      }
    _ => VError(Value)
  }
}

///|
fn evaluate_concat(left : FormulaValue, right : FormulaValue) -> FormulaValue {
  let lt = coerce_to_text(left)
  if lt is VError(_) {
    return lt
  }
  let rt = coerce_to_text(right)
  if rt is VError(_) {
    return rt
  }
  match (lt, rt) {
    (VString(a), VString(b)) => VString(a + b)
    _ => VError(Value)
  }
}

///|
fn evaluate_comparison(
  op : BinaryOp,
  left : FormulaValue,
  right : FormulaValue,
) -> FormulaValue {
  if left.first_error() is Some(err) {
    return VError(err)
  }
  if right.first_error() is Some(err) {
    return VError(err)
  }
  let cmp = compare_formula_values(left.first_scalar(), right.first_scalar())
  match op {
    Eq => VBool(cmp == 0)
    Neq => VBool(cmp != 0)
    Lt => VBool(cmp < 0)
    Gt => VBool(cmp > 0)
    Le => VBool(cmp <= 0)
    Ge => VBool(cmp >= 0)
    _ => VError(Value)
  }
}

///|
fn evaluate_array_constant(
  rows : Array[Array[FormulaAst]],
  ctx : EvalContext,
) -> FormulaValue {
  let values = Array::new(capacity=rows.length())
  for row in rows {
    let out_row = Array::new(capacity=row.length())
    for ast in row {
      let value = evaluate(ast, ctx)
      if value is VError(_) {
        return value
      }
      out_row.push(value)
    }
    values.push(out_row)
  }
  VArray(values)
}

///|
fn evaluate_range_operator(
  left : FormulaAst,
  right : FormulaAst,
  ctx : EvalContext,
) -> FormulaValue {
  match
    (reference_rect_from_ast(left, ctx), reference_rect_from_ast(right, ctx)) {
    (Some(a), Some(b)) => materialize_rect(combine_range_rects(a, b, ctx), ctx)
    _ => VError(Ref)
  }
}

///|
fn evaluate_intersection_operator(
  left : FormulaAst,
  right : FormulaAst,
  ctx : EvalContext,
) -> FormulaValue {
  match
    (reference_rect_from_ast(left, ctx), reference_rect_from_ast(right, ctx)) {
    (Some(a), Some(b)) =>
      match intersect_rects(a, b, ctx) {
        Some(rect) => materialize_rect(rect, ctx)
        None => VError(NullErr)
      }
    _ => VError(Ref)
  }
}

///|
fn evaluate_union_operator(
  left : FormulaAst,
  right : FormulaAst,
  ctx : EvalContext,
) -> FormulaValue {
  let lv = evaluate(left, ctx)
  if lv is VError(_) {
    return lv
  }
  let rv = evaluate(right, ctx)
  if rv is VError(_) {
    return rv
  }
  union_values(lv, rv)
}

///|
fn reference_rect_from_ast(
  ast : FormulaAst,
  ctx : EvalContext,
) -> ReferenceRect? {
  match ast {
    Reference(lexeme) => reference_rect_from_lexeme(lexeme, ctx)
    Binary(Range, left, right) =>
      match
        (
          reference_rect_from_ast(left, ctx),
          reference_rect_from_ast(right, ctx),
        ) {
        (Some(a), Some(b)) => Some(combine_range_rects(a, b, ctx))
        _ => None
      }
    _ => None
  }
}

///|
fn reference_rect_from_lexeme(
  lexeme : String,
  ctx : EvalContext,
) -> ReferenceRect? {
  let range : @address.CellRange? = Some(@address.CellRange::parse_a1(lexeme)) catch {
    _ => None
  }
  match range {
    Some(range) => range_to_rect(range, ctx)
    None => {
      let cell : @address.CellAddress? = Some(
        @address.CellAddress::parse_a1(lexeme),
      ) catch {
        _ => None
      }
      match cell {
        Some(cell) => Some(cell_to_rect(cell, ctx))
        None => None
      }
    }
  }
}

///|
fn range_to_rect(
  range : @address.CellRange,
  ctx : EvalContext,
) -> ReferenceRect? {
  match
    (
      range.start_col_zero_based,
      range.start_row_zero_based,
      range.end_col_zero_based,
      range.end_row_zero_based,
    ) {
    (Some(sc), Some(sr), Some(ec), Some(er)) =>
      Some({
        start_col: sc.min(ec),
        start_row: sr.min(er),
        end_col: sc.max(ec),
        end_row: sr.max(er),
        sheet: ctx.current_sheet_or(range.sheet),
      })
    _ => None
  }
}

///|
fn cell_to_rect(
  cell : @address.CellAddress,
  ctx : EvalContext,
) -> ReferenceRect {
  {
    start_col: cell.col_zero_based,
    start_row: cell.row_zero_based,
    end_col: cell.col_zero_based,
    end_row: cell.row_zero_based,
    sheet: ctx.current_sheet_or(cell.sheet),
  }
}

///|
fn combine_range_rects(
  left : ReferenceRect,
  right : ReferenceRect,
  ctx : EvalContext,
) -> ReferenceRect {
  let sheet = merge_rect_sheet(left.sheet, right.sheet, ctx.current_sheet)
  {
    start_col: left.start_col.min(right.start_col),
    start_row: left.start_row.min(right.start_row),
    end_col: left.end_col.max(right.end_col),
    end_row: left.end_row.max(right.end_row),
    sheet,
  }
}

///|
fn intersect_rects(
  left : ReferenceRect,
  right : ReferenceRect,
  ctx : EvalContext,
) -> ReferenceRect? {
  let sheet = merge_rect_sheet(left.sheet, right.sheet, ctx.current_sheet)
  if left.sheet != right.sheet &&
    left.sheet is Some(_) &&
    right.sheet is Some(_) {
    return None
  }
  let start_col = left.start_col.max(right.start_col)
  let start_row = left.start_row.max(right.start_row)
  let end_col = left.end_col.min(right.end_col)
  let end_row = left.end_row.min(right.end_row)
  if start_col > end_col || start_row > end_row {
    None
  } else {
    Some({ start_col, start_row, end_col, end_row, sheet })
  }
}

///|
fn materialize_rect(rect : ReferenceRect, ctx : EvalContext) -> FormulaValue {
  let rows = Array::new(capacity=rect.end_row - rect.start_row + 1)
  for row_idx in rect.start_row..<=rect.end_row {
    let row = Array::new(capacity=rect.end_col - rect.start_col + 1)
    for col_idx in rect.start_col..<=rect.end_col {
      row.push(
        (ctx.resolve_cell)(@address.CellAddress::{
          col_zero_based: col_idx,
          row_zero_based: row_idx,
          col_absolute: true,
          row_absolute: true,
          sheet: rect.sheet,
        }),
      )
    }
    rows.push(row)
  }
  if rows.length() == 1 && rows[0].length() == 1 {
    rows[0][0]
  } else {
    VArray(rows)
  }
}

///|
fn union_values(left : FormulaValue, right : FormulaValue) -> FormulaValue {
  let la = value_to_array(left)
  let ra = value_to_array(right)
  if la.length() == ra.length() {
    let out = Array::new(capacity=la.length())
    for i in 0..<la.length() {
      let row = la[i].copy()
      row.append(ra[i].view())
      out.push(row)
    }
    VArray(out)
  } else {
    let out = la.copy()
    out.append(ra.view())
    VArray(out)
  }
}

///|
fn value_to_array(value : FormulaValue) -> Array[Array[FormulaValue]] {
  match value {
    VArray(rows) => rows
    scalar => [[scalar]]
  }
}

///|
fn compare_formula_values(left : FormulaValue, right : FormulaValue) -> Int {
  let lr = comparison_rank(left)
  let rr = comparison_rank(right)
  if lr != rr {
    lr - rr
  } else {
    match (left, right) {
      (VNumber(a), VNumber(b)) => a.compare(b)
      (VString(a), VString(b)) => a.compare(b)
      (VBool(a), VBool(b)) => a.compare(b)
      (VEmpty, VEmpty) => 0
      (VEmpty, VNumber(b)) => 0.0.compare(b)
      (VNumber(a), VEmpty) => a.compare(0.0)
      _ => lr - rr
    }
  }
}

///|
fn comparison_rank(value : FormulaValue) -> Int {
  match value {
    VEmpty | VNumber(_) => 0
    VString(_) => 1
    VBool(_) => 2
    VError(_) => 3
    VArray(_) => 4
  }
}

///|
fn merge_rect_sheet(
  left : String?,
  right : String?,
  current : String,
) -> String? {
  match (left, right) {
    (Some(a), Some(b)) => if a == b { Some(a) } else { Some(current) }
    (Some(a), None) => Some(a)
    (None, Some(b)) => Some(b)
    (None, None) => if current == "" { None } else { Some(current) }
  }
}

///|
fn formula_looks_like_reference(lexeme : String) -> Bool {
  let body = match lexeme.rev_split_once("!") {
    Some((_, rest)) => rest.to_owned()
    None => lexeme
  }
  body.contains_char('$') || body.contains_char(':') || formula_has_digit(body)
}

///|
fn formula_has_digit(value : String) -> Bool {
  for ch in value {
    if ch >= '0' && ch <= '9' {
      return true
    }
  }
  false
}

///|
fn formula_is_integer(value : Double) -> Bool {
  value == value.trunc()
}

///|
fn formula_ascii_upper(value : String) -> String {
  value.to_upper()
}
