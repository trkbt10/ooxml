///|
priv enum AggregateNumberMode {
  DirectOrArray
}

///|
priv struct AggregateNumbers {
  values : Array[Double]
  error : FormulaError?
}

///|
/// §18.17.7 — register the built-in SpreadsheetML functions implemented in
/// this build into the supplied registry.
pub fn register_builtin_functions(registry : FunctionRegistry) -> Unit {
  registry.register("SUM", Eager(fn_sum))
  registry.register("AVERAGE", Eager(fn_average))
  registry.register("COUNT", Eager(fn_count))
  registry.register("COUNTA", Eager(fn_counta))
  registry.register("COUNTBLANK", Eager(fn_countblank))
  registry.register("MIN", Eager(fn_min))
  registry.register("MAX", Eager(fn_max))
  registry.register("PRODUCT", Eager(fn_product))
  registry.register("SUMPRODUCT", Eager(fn_sumproduct))
  register_builtin_math_functions(registry)
  register_builtin_math_trig_functions(registry)
  register_builtin_logical_functions(registry)
  register_builtin_text_functions(registry)
  register_builtin_info_functions(registry)
  register_builtin_lookup_functions(registry)
  register_builtin_reference_functions(registry)
  register_builtin_datetime_functions(registry)
  register_builtin_financial_functions(registry)
  register_builtin_statistical_functions(registry)
  register_builtin_statistical_dist_functions(registry)
  register_builtin_text_extended_functions(registry)
  register_builtin_engineering_functions(registry)
  register_builtin_database_functions(registry)
  register_builtin_datetime_extended_functions(registry)
  register_builtin_financial_bond_functions(registry)
}

///|
/// §18.17.7.SUM — add the numeric values of the arguments.
fn fn_sum(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_aggregate_numbers(args, ctx, DirectOrArray)
  match scan.error {
    Some(err) => VError(err)
    None => {
      let mut total = 0.0
      for value in scan.values {
        total += value
      }
      VNumber(total)
    }
  }
}

///|
/// §18.17.7.AVERAGE — compute the arithmetic mean of numeric arguments.
fn fn_average(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_aggregate_numbers(args, ctx, DirectOrArray)
  match scan.error {
    Some(err) => VError(err)
    None =>
      if scan.values.length() == 0 {
        VError(DivZero)
      } else {
        let mut total = 0.0
        for value in scan.values {
          total += value
        }
        VNumber(total / scan.values.length().to_double())
      }
  }
}

///|
/// §18.17.7.COUNT — count numeric values in the arguments.
fn fn_count(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_aggregate_numbers(args, ctx, DirectOrArray)
  match scan.error {
    Some(err) => VError(err)
    None => VNumber(scan.values.length().to_double())
  }
}

///|
/// §18.17.7.COUNTA — count non-empty values in the arguments.
fn fn_counta(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  let mut count = 0
  for arg in args {
    match counta_value(arg) {
      VError(err) => return VError(err)
      VNumber(n) => count += n.to_int()
      _ => ()
    }
  }
  VNumber(count.to_double())
}

///|
/// §18.17.7.COUNTBLANK — count empty cells in a range argument.
fn fn_countblank(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_error() {
    Some(err) => VError(err)
    None => VNumber(count_blank_value(args[0]).to_double())
  }
}

///|
/// §18.17.7.MIN — return the smallest numeric argument, or zero if none exist.
fn fn_min(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_aggregate_numbers(args, ctx, DirectOrArray)
  match scan.error {
    Some(err) => VError(err)
    None =>
      if scan.values.length() == 0 {
        VNumber(0.0)
      } else {
        let mut best = scan.values[0]
        for value in scan.values {
          if value < best {
            best = value
          }
        }
        VNumber(best)
      }
  }
}

///|
/// §18.17.7.MAX — return the largest numeric argument, or zero if none exist.
fn fn_max(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_aggregate_numbers(args, ctx, DirectOrArray)
  match scan.error {
    Some(err) => VError(err)
    None =>
      if scan.values.length() == 0 {
        VNumber(0.0)
      } else {
        let mut best = scan.values[0]
        for value in scan.values {
          if value > best {
            best = value
          }
        }
        VNumber(best)
      }
  }
}

///|
/// §18.17.7.PRODUCT — multiply the numeric values of the arguments.
fn fn_product(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_aggregate_numbers(args, ctx, DirectOrArray)
  match scan.error {
    Some(err) => VError(err)
    None =>
      if scan.values.length() == 0 {
        VNumber(0.0)
      } else {
        let mut product = 1.0
        for value in scan.values {
          product *= value
        }
        VNumber(product)
      }
  }
}

///|
/// §18.17.7.SUMPRODUCT — sum products of corresponding array elements.
fn fn_sumproduct(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  if args.length() == 0 {
    return VError(Value)
  }
  let arrays = Array::new(capacity=args.length())
  for arg in args {
    if arg.first_error() is Some(err) {
      return VError(err)
    }
    arrays.push(value_to_array(arg))
  }
  let rows = arrays[0].length()
  let cols = if rows == 0 { 0 } else { arrays[0][0].length() }
  for array in arrays {
    if array.length() != rows {
      return VError(Num)
    }
    for row in array {
      if row.length() != cols {
        return VError(Num)
      }
    }
  }
  let mut total = 0.0
  for row_idx in 0..<rows {
    for col_idx in 0..<cols {
      let mut product = 1.0
      for array in arrays {
        product *= sumproduct_number(array[row_idx][col_idx])
      }
      total += product
    }
  }
  VNumber(total)
}

///|
fn collect_aggregate_numbers(
  args : Array[FormulaValue],
  ctx : EvalContext,
  mode : AggregateNumberMode,
) -> AggregateNumbers {
  let values = Array::new()
  for arg in args {
    match collect_aggregate_arg(arg, ctx, mode, values) {
      Some(err) => return { values, error: Some(err) }
      None => ()
    }
  }
  { values, error: None }
}

///|
fn collect_aggregate_arg(
  value : FormulaValue,
  ctx : EvalContext,
  mode : AggregateNumberMode,
  values : Array[Double],
) -> FormulaError? {
  match value {
    VArray(rows) =>
      for row in rows {
        for cell in row {
          match cell {
            VError(err) => return Some(err)
            VNumber(n) => values.push(n)
            _ => ()
          }
        }
      }
    VError(err) => return Some(err)
    VNumber(n) => values.push(n)
    VString(_) =>
      if mode is DirectOrArray {
        match coerce_to_number(value, ctx.date_system) {
          VNumber(n) => values.push(n)
          VError(Value) => ()
          VError(err) => return Some(err)
          _ => ()
        }
      }
    _ => ()
  }
  None
}

///|
fn counta_value(value : FormulaValue) -> FormulaValue {
  match value {
    VArray(rows) => {
      let mut count = 0
      for row in rows {
        for cell in row {
          match cell {
            VError(err) => return VError(err)
            VEmpty => ()
            VString(text) => if text != "" { count += 1 }
            _ => count += 1
          }
        }
      }
      VNumber(count.to_double())
    }
    VError(err) => VError(err)
    VEmpty => VNumber(0.0)
    _ => VNumber(1.0)
  }
}

///|
fn count_blank_value(value : FormulaValue) -> Int {
  match value {
    VArray(rows) => {
      let mut count = 0
      for row in rows {
        for cell in row {
          if cell is VEmpty {
            count += 1
          } else if cell is VString(text) && text == "" {
            count += 1
          }
        }
      }
      count
    }
    VEmpty => 1
    VString(text) => if text == "" { 1 } else { 0 }
    _ => 0
  }
}

///|
fn sumproduct_number(value : FormulaValue) -> Double {
  match value {
    VNumber(n) => n
    _ => 0.0
  }
}
