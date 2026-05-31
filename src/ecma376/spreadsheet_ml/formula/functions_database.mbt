///|
fn register_builtin_database_functions(registry : FunctionRegistry) -> Unit {
  registry.register("DSUM", Lazy(fn_dsum))
  registry.register("DAVERAGE", Lazy(fn_daverage))
  registry.register("DCOUNT", Lazy(fn_dcount))
  registry.register("DCOUNTA", Lazy(fn_dcounta))
  registry.register("DMAX", Lazy(fn_dmax))
  registry.register("DMIN", Lazy(fn_dmin))
  registry.register("DPRODUCT", Lazy(fn_dproduct))
  registry.register("DGET", Lazy(fn_dget))
  registry.register("DSTDEV", Lazy(fn_dstdev))
  registry.register("DSTDEVP", Lazy(fn_dstdevp))
  registry.register("DVAR", Lazy(fn_dvar))
  registry.register("DVARP", Lazy(fn_dvarp))
  registry.register("TRANSPOSE", Eager(fn_transpose))
  registry.register("HYPERLINK", Eager(fn_hyperlink))
  registry.register("GETPIVOTDATA", Eager(fn_getpivotdata))
  registry.register("RTD", Eager(fn_rtd))
  registry.register("CELL", Lazy(fn_cell))
  registry.register("INFO", Eager(fn_info))
  registry.register("ISREF", Lazy(fn_isref))
  // Cube functions — OLAP server dependent, return #N/A
  registry.register("CUBEKPIMEMBER", Eager(fn_cube_stub))
  registry.register("CUBEMEMBER", Eager(fn_cube_stub))
  registry.register("CUBEMEMBERPROPERTY", Eager(fn_cube_stub))
  registry.register("CUBERANKEDMEMBER", Eager(fn_cube_stub))
  registry.register("CUBESET", Eager(fn_cube_stub))
  registry.register("CUBESETCOUNT", Eager(fn_cube_stub))
  registry.register("CUBEVALUE", Eager(fn_cube_stub))
}

///|
fn d_function(
  args : Array[FormulaAst],
  ctx : EvalContext,
  agg : (Array[Double]) -> FormulaValue,
) -> FormulaValue {
  if args.length() != 3 {
    return VError(Value)
  }
  let db = evaluate(args[0], ctx)
  let field_arg = evaluate(args[1], ctx)
  let criteria = evaluate(args[2], ctx)
  let db_rows = match db {
    VArray(rows) => rows
    _ => return VError(Value)
  }
  let crit_rows = match criteria {
    VArray(rows) => rows
    _ => return VError(Value)
  }
  if db_rows.length() < 2 || crit_rows.length() < 2 {
    return VError(Value)
  }
  let headers : Array[String] = []
  for cell in db_rows[0] {
    match cell {
      VString(s) => headers.push(s)
      _ => headers.push("")
    }
  }
  let field_idx = match field_arg {
    VNumber(n) => n.trunc().to_int() - 1
    VString(s) => {
      let mut idx = -1
      for i, h in headers {
        if h == s {
          idx = i
          break
        }
      }
      idx
    }
    _ => return VError(Value)
  }
  if field_idx < 0 || field_idx >= headers.length() {
    return VError(Value)
  }
  let crit_headers : Array[String] = []
  for cell in crit_rows[0] {
    match cell {
      VString(s) => crit_headers.push(s)
      _ => crit_headers.push("")
    }
  }
  let crit_col_indices : Array[Int] = []
  for ch in crit_headers {
    let mut found = -1
    for i, h in headers {
      if h == ch {
        found = i
        break
      }
    }
    crit_col_indices.push(found)
  }
  let values : Array[Double] = []
  for row_idx in 1..<db_rows.length() {
    let row = db_rows[row_idx]
    let mut matches = false
    for crit_row_idx in 1..<crit_rows.length() {
      let crit_row = crit_rows[crit_row_idx]
      let mut row_match = true
      for ci in 0..<crit_col_indices.length() {
        let col = crit_col_indices[ci]
        if col < 0 {
          continue
        }
        if ci >= crit_row.length() {
          continue
        }
        match crit_row[ci] {
          VEmpty => ()
          crit_val => {
            let cell_val = if col < row.length() { row[col] } else { VEmpty }
            if !d_criteria_match(cell_val, crit_val) {
              row_match = false
            }
          }
        }
      }
      if row_match {
        matches = true
        break
      }
    }
    if matches {
      if field_idx < row.length() {
        match row[field_idx] {
          VNumber(n) => values.push(n)
          _ => ()
        }
      }
    }
  }
  agg(values)
}

///|
fn d_criteria_match(cell : FormulaValue, crit : FormulaValue) -> Bool {
  match (cell, crit) {
    (VNumber(a), VNumber(b)) => a == b
    (VString(a), VString(b)) => a == b
    (VBool(a), VBool(b)) => a == b
    _ => false
  }
}

///|
fn fn_dsum(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) {
    let mut sum = 0.0
    for v in vals {
      sum = sum + v
    }
    VNumber(sum)
  })
}

///|
fn fn_daverage(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) {
    if vals.length() == 0 {
      return VError(DivZero)
    }
    let mut sum = 0.0
    for v in vals {
      sum = sum + v
    }
    VNumber(sum / vals.length().to_double())
  })
}

///|
fn fn_dcount(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) { VNumber(vals.length().to_double()) })
}

///|
fn fn_dcounta(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) { VNumber(vals.length().to_double()) })
}

///|
fn fn_dmax(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) {
    if vals.length() == 0 {
      return VNumber(0.0)
    }
    let mut m = vals[0]
    for v in vals {
      if v > m {
        m = v
      }
    }
    VNumber(m)
  })
}

///|
fn fn_dmin(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) {
    if vals.length() == 0 {
      return VNumber(0.0)
    }
    let mut m = vals[0]
    for v in vals {
      if v < m {
        m = v
      }
    }
    VNumber(m)
  })
}

///|
fn fn_dproduct(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) {
    let mut p = 1.0
    for v in vals {
      p = p * v
    }
    VNumber(p)
  })
}

///|
fn fn_dget(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) {
    if vals.length() == 1 {
      VNumber(vals[0])
    } else if vals.length() == 0 {
      VError(Value)
    } else {
      VError(Num)
    }
  })
}

///|
fn fn_dstdev(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) {
    if vals.length() < 2 {
      return VError(DivZero)
    }
    VNumber(sample_variance(vals).sqrt())
  })
}

///|
fn fn_dstdevp(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) {
    if vals.length() < 1 {
      return VError(DivZero)
    }
    let n = vals.length().to_double()
    let mut sum = 0.0
    for v in vals {
      sum = sum + v
    }
    let mean = sum / n
    let mut ss = 0.0
    for v in vals {
      let d = v - mean
      ss = ss + d * d
    }
    VNumber((ss / n).sqrt())
  })
}

///|
fn fn_dvar(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) {
    if vals.length() < 2 {
      return VError(DivZero)
    }
    VNumber(sample_variance(vals))
  })
}

///|
fn fn_dvarp(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  d_function(args, ctx, fn(vals) {
    if vals.length() < 1 {
      return VError(DivZero)
    }
    let n = vals.length().to_double()
    let mut sum = 0.0
    for v in vals {
      sum = sum + v
    }
    let mean = sum / n
    let mut ss = 0.0
    for v in vals {
      let d = v - mean
      ss = ss + d * d
    }
    VNumber(ss / n)
  })
}

///|
fn fn_transpose(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0] {
    VArray(rows) => {
      if rows.length() == 0 {
        return VArray([])
      }
      let nrows = rows.length()
      let ncols = rows[0].length()
      let result : Array[Array[FormulaValue]] = []
      for j in 0..<ncols {
        let row : Array[FormulaValue] = []
        for i in 0..<nrows {
          row.push(if j < rows[i].length() { rows[i][j] } else { VEmpty })
        }
        result.push(row)
      }
      VArray(result)
    }
    other => other
  }
}

///|
fn fn_hyperlink(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 {
    return VError(Value)
  }
  if args.length() == 2 {
    match args[1].first_scalar() {
      VString(s) => VString(s)
      _ =>
        match args[0].first_scalar() {
          VString(s) => VString(s)
          _ => VError(Value)
        }
    }
  } else {
    match args[0].first_scalar() {
      VString(s) => VString(s)
      _ => VError(Value)
    }
  }
}

///|
fn fn_getpivotdata(
  _args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  VError(Ref)
}

///|
fn fn_rtd(_args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  VError(NotApplicable)
}

///|
fn fn_cube_stub(
  _args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  VError(NotApplicable)
}

///|
/// §18.17.7 CELL — information about the formatting, location, or
/// contents of the upper-left cell of `reference` (or of the cell
/// containing the formula when `reference` is omitted, matching the
/// ROW()/COLUMN() default).
///
/// Registered `Lazy` so the reference argument keeps its address:
/// eager evaluation collapses a reference to a bare value and loses
/// the coordinates `address` / `col` / `row` need. The
/// reference-derived info types (`address`, `col`, `row`, `contents`,
/// `type`) are computed exactly. The format / protection / display
/// types (`format`, `color`, `parentheses`, `prefix`, `protect`,
/// `width`) need per-cell format metadata the formula `EvalContext`
/// does not carry, and `filename` needs the workbook path; these
/// return the spec's neutral defaults rather than fabricated values.
fn fn_cell(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 {
    return VError(Value)
  }
  let info_type = match evaluate(args[0], ctx).first_scalar() {
    VString(s) => s.to_lower()
    VError(err) => return VError(err)
    _ => return VError(Value)
  }
  // §18.17.7 — the reference defaults to the cell containing the
  // formula when the second argument is omitted.
  let rect = if args.length() == 2 {
    match reference_rect_from_ast(args[1], ctx) {
      Some(r) => r
      None =>
        // Not a reference — surface a propagated error, else #VALUE!.
        match evaluate(args[1], ctx).first_error() {
          Some(err) => return VError(err)
          None => return VError(Value)
        }
    }
  } else {
    cell_to_rect(ctx.current_cell, ctx)
  }
  let upper_left = @address.CellAddress::{
    col_zero_based: rect.start_col,
    row_zero_based: rect.start_row,
    col_absolute: false,
    row_absolute: false,
    sheet: rect.sheet,
  }
  match info_type {
    // §18.17.7 — absolute A1 reference of the upper-left cell as text.
    "address" =>
      build_address_text(
        rect.start_row + 1,
        rect.start_col + 1,
        1,
        true,
        VEmpty,
      )
    "col" => VNumber((rect.start_col + 1).to_double())
    "row" => VNumber((rect.start_row + 1).to_double())
    "contents" => (ctx.resolve_cell)(upper_left)
    // §18.17.7 — "b" blank, "l" text label, "v" any other value.
    "type" =>
      match (ctx.resolve_cell)(upper_left).first_scalar() {
        VEmpty => VString("b")
        VString("") => VString("b")
        VString(_) => VString("l")
        _ => VString("v")
      }
    // Format / protection / display metadata is not carried by the
    // formula EvalContext; return the spec's neutral defaults.
    "prefix" => VString("")
    "format" => VString("G")
    "color" => VNumber(0.0)
    "parentheses" => VNumber(0.0)
    // §18.3.1.36 `@locked` defaults true → cells are locked by default.
    "protect" => VNumber(1.0)
    "filename" => VString("")
    "width" => VNumber(8.0)
    _ => VError(Value)
  }
}

///|
fn fn_info(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VString(info_type) =>
      match info_type {
        "directory" => VString("")
        "numfile" => VNumber(1.0)
        "origin" => VString("$A:$A$1")
        "osversion" => VString("ECMA-376")
        "recalc" => VString("Automatic")
        "release" => VString("16.0")
        "system" => VString("pcdos")
        _ => VError(Value)
      }
    _ => VError(Value)
  }
}

///|
/// §18.17.2 ISREF — TRUE when the argument is a reference (a cell or
/// a range), FALSE otherwise. Registered `Lazy` so a single-cell
/// reference (e.g. `ISREF(A1)`), which eager evaluation would
/// collapse to a bare scalar indistinguishable from a literal, is
/// detected by its AST shape. A function returning a multi-cell
/// reference evaluates to an array and is also treated as a reference.
fn fn_isref(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  // A direct cell or range reference is detectable from the AST.
  if reference_rect_from_ast(args[0], ctx) is Some(_) {
    return VBool(true)
  }
  // A function returning a multi-cell reference evaluates to an array.
  match evaluate(args[0], ctx) {
    VArray(_) => VBool(true)
    _ => VBool(false)
  }
}
