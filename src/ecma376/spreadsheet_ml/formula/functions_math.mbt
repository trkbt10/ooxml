///|
fn register_builtin_math_functions(registry : FunctionRegistry) -> Unit {
  registry.register("ABS", Eager(fn_abs))
  registry.register("INT", Eager(fn_int))
  registry.register("ROUND", Eager(fn_round))
  registry.register("ROUNDUP", Eager(fn_roundup))
  registry.register("ROUNDDOWN", Eager(fn_rounddown))
  registry.register("SQRT", Eager(fn_sqrt))
  registry.register("POWER", Eager(fn_power))
  registry.register("MOD", Eager(fn_mod))
  registry.register("SIGN", Eager(fn_sign))
  registry.register("CEILING", Eager(fn_ceiling))
  registry.register("FLOOR", Eager(fn_floor))
  registry.register("EXP", Eager(fn_exp))
  registry.register("LN", Eager(fn_ln))
  registry.register("LOG", Eager(fn_log))
  registry.register("LOG10", Eager(fn_log10))
  registry.register("PI", Eager(fn_pi))
  registry.register("RAND", Eager(fn_rand))
  registry.register("TRUNC", Eager(fn_trunc))
}

///|
/// §18.17.7.ABS — return the absolute value of a number.
fn fn_abs(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => VNumber(n.abs())
    other => other
  }
}

///|
/// §18.17.7.INT — round a number toward negative infinity.
fn fn_int(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => VNumber(n.floor())
    other => other
  }
}

///|
/// §18.17.7.TRUNC — truncate a number toward zero.
fn fn_trunc(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match number_and_optional_digits(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n), VNumber(digits)) =>
          VNumber(round_scaled(n, digits, TowardZero))
        (VError(err), _) | (_, VError(err)) => VError(err)
        _ => VError(Value)
      }
    other => other
  }
}

///|
/// §18.17.7.ROUND — round a number with digits 0-4 down and 5-9 up.
fn fn_round(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n), VNumber(digits)) =>
          VNumber(round_scaled(n, digits, HalfAway))
        (VError(err), _) | (_, VError(err)) => VError(err)
        _ => VError(Value)
      }
    other => other
  }
}

///|
/// §18.17.7.ROUNDUP — round a number away from zero.
fn fn_roundup(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n), VNumber(digits)) =>
          VNumber(round_scaled(n, digits, AwayFromZero))
        (VError(err), _) | (_, VError(err)) => VError(err)
        _ => VError(Value)
      }
    other => other
  }
}

///|
/// §18.17.7.ROUNDDOWN — round a number toward zero.
fn fn_rounddown(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n), VNumber(digits)) =>
          VNumber(round_scaled(n, digits, TowardZero))
        (VError(err), _) | (_, VError(err)) => VError(err)
        _ => VError(Value)
      }
    other => other
  }
}

///|
/// §18.17.7.SQRT — return the positive square root of a number.
fn fn_sqrt(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => if n < 0.0 { VError(Num) } else { VNumber(n.sqrt()) }
    other => other
  }
}

///|
/// §18.17.7.POWER — raise a base number to an exponent.
fn fn_power(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(base), VNumber(exp)) =>
          if base == 0.0 && exp <= 0.0 {
            VError(DivZero)
          } else if base < 0.0 && !formula_is_integer(exp) {
            VError(Num)
          } else {
            checked_number(@math.pow(base, exp))
          }
        (VError(err), _) | (_, VError(err)) => VError(err)
        _ => VError(Value)
      }
    other => other
  }
}

///|
/// §18.17.7.MOD — return the remainder after division.
fn fn_mod(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n), VNumber(divisor)) =>
          if divisor == 0.0 {
            VError(DivZero)
          } else {
            VNumber(n - divisor * (n / divisor).floor())
          }
        (VError(err), _) | (_, VError(err)) => VError(err)
        _ => VError(Value)
      }
    other => other
  }
}

///|
/// §18.17.7.SIGN — return -1, 0, or 1 according to the sign of a number.
fn fn_sign(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      if n > 0.0 {
        VNumber(1.0)
      } else if n < 0.0 {
        VNumber(-1.0)
      } else {
        VNumber(0.0)
      }
    other => other
  }
}

///|
/// §18.17.7.CEILING — round a number up to a multiple of significance.
fn fn_ceiling(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n), VNumber(significance)) =>
          round_to_multiple(n, significance, AwayFromZero)
        (VError(err), _) | (_, VError(err)) => VError(err)
        _ => VError(Value)
      }
    other => other
  }
}

///|
/// §18.17.7.FLOOR — round a number down to a multiple of significance.
fn fn_floor(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n), VNumber(significance)) =>
          round_to_multiple(n, significance, TowardZero)
        (VError(err), _) | (_, VError(err)) => VError(err)
        _ => VError(Value)
      }
    other => other
  }
}

///|
/// §18.17.7.EXP — raise e to the supplied power.
fn fn_exp(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => checked_number(@math.exp(n))
    other => other
  }
}

///|
/// §18.17.7.LN — return the natural logarithm of a number.
fn fn_ln(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      if n <= 0.0 {
        VError(Num)
      } else {
        checked_number(@math.ln(n))
      }
    other => other
  }
}

///|
/// §18.17.7.LOG — return the logarithm of a number for the supplied base.
fn fn_log(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 && args.length() != 2 {
    return VError(Value)
  }
  let n = scalar_number(args[0], ctx)
  if n is VError(_) {
    return n
  }
  let base = if args.length() == 1 {
    VNumber(10.0)
  } else {
    scalar_number(args[1], ctx)
  }
  match (n, base) {
    (VNumber(value), VNumber(base_value)) =>
      if value <= 0.0 || base_value <= 0.0 || base_value == 1.0 {
        VError(Num)
      } else {
        checked_number(@math.ln(value) / @math.ln(base_value))
      }
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.LOG10 — return the base-10 logarithm of a number.
fn fn_log10(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      if n <= 0.0 {
        VError(Num)
      } else {
        checked_number(@math.log10(n))
      }
    other => other
  }
}

///|
/// §18.17.7.PI — return the value of pi.
fn fn_pi(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    VNumber(3.14159265358979)
  } else {
    VError(Value)
  }
}

///|
/// §18.17.7.RAND — return a deterministic real number greater than or equal to
/// zero and less than one.
fn fn_rand(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 0 {
    return VError(Value)
  }
  let row = ctx.current_cell.row_zero_based + 1
  let col = ctx.current_cell.col_zero_based + 1
  let sheet = ctx.current_sheet.length()
  let seed = row * 1109 + col * 9176 + sheet * 379
  VNumber((seed % 1000000).to_double() / 1000000.0)
}

///|
priv enum RoundMode {
  HalfAway
  AwayFromZero
  TowardZero
}

///|
fn one_number(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    VError(Value)
  } else {
    scalar_number(args[0], ctx)
  }
}

///|
fn two_numbers(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  VArray([[scalar_number(args[0], ctx), scalar_number(args[1], ctx)]])
}

///|
fn number_and_optional_digits(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 1 && args.length() != 2 {
    return VError(Value)
  }
  let digits = if args.length() == 1 {
    VNumber(0.0)
  } else {
    scalar_number(args[1], ctx)
  }
  VArray([[scalar_number(args[0], ctx), digits]])
}

///|
fn scalar_number(value : FormulaValue, ctx : EvalContext) -> FormulaValue {
  coerce_to_number(value, ctx.date_system)
}

///|
fn round_scaled(value : Double, digits : Double, mode : RoundMode) -> Double {
  let places = digits.trunc()
  let factor = @math.pow(10.0, places.abs())
  if places >= 0.0 {
    round_unit(value * factor, mode) / factor
  } else {
    round_unit(value / factor, mode) * factor
  }
}

///|
fn round_unit(value : Double, mode : RoundMode) -> Double {
  let sign = if value < 0.0 { -1.0 } else { 1.0 }
  let magnitude = value.abs()
  let rounded = match mode {
    HalfAway => (magnitude + 0.5 + 0.000000000001).floor()
    AwayFromZero => magnitude.ceil()
    TowardZero => magnitude.trunc()
  }
  sign * rounded
}

///|
fn round_to_multiple(
  value : Double,
  significance : Double,
  mode : RoundMode,
) -> FormulaValue {
  if significance == 0.0 {
    return VNumber(0.0)
  }
  if value != 0.0 &&
    significance != 0.0 &&
    ((value < 0.0 && significance > 0.0) || (value > 0.0 && significance < 0.0)) {
    return VError(Num)
  }
  let quotient = value / significance
  VNumber(round_unit(quotient, mode) * significance)
}

///|
fn checked_number(value : Double) -> FormulaValue {
  if value.is_nan() || value.is_inf() {
    VError(Num)
  } else {
    VNumber(value)
  }
}
