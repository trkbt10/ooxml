///|
fn register_builtin_math_trig_functions(registry : FunctionRegistry) -> Unit {
  registry.register("SIN", Eager(fn_sin))
  registry.register("COS", Eager(fn_cos))
  registry.register("TAN", Eager(fn_tan))
  registry.register("ASIN", Eager(fn_asin))
  registry.register("ACOS", Eager(fn_acos))
  registry.register("ATAN", Eager(fn_atan))
  registry.register("ATAN2", Eager(fn_atan2))
  registry.register("SINH", Eager(fn_sinh))
  registry.register("COSH", Eager(fn_cosh))
  registry.register("TANH", Eager(fn_tanh))
  registry.register("ASINH", Eager(fn_asinh))
  registry.register("ACOSH", Eager(fn_acosh))
  registry.register("ATANH", Eager(fn_atanh))
  registry.register("DEGREES", Eager(fn_degrees))
  registry.register("RADIANS", Eager(fn_radians))
  registry.register("COMBIN", Eager(fn_combin))
  registry.register("PERMUT", Eager(fn_permut))
  registry.register("EVEN", Eager(fn_even))
  registry.register("ODD", Eager(fn_odd))
  registry.register("FACT", Eager(fn_fact))
  registry.register("FACTDOUBLE", Eager(fn_factdouble))
  registry.register("GCD", Eager(fn_gcd))
  registry.register("LCM", Eager(fn_lcm))
  registry.register("MROUND", Eager(fn_mround))
  registry.register("MULTINOMIAL", Eager(fn_multinomial))
  registry.register("QUOTIENT", Eager(fn_quotient))
  registry.register("RANDBETWEEN", Eager(fn_randbetween))
  registry.register("ROMAN", Eager(fn_roman))
  registry.register("SQRTPI", Eager(fn_sqrtpi))
  registry.register("SUBTOTAL", Eager(fn_subtotal))
  registry.register("SUMSQ", Eager(fn_sumsq))
  registry.register("SUMX2MY2", Eager(fn_sumx2my2))
  registry.register("SUMX2PY2", Eager(fn_sumx2py2))
  registry.register("SUMXMY2", Eager(fn_sumxmy2))
  registry.register("ECMA.CEILING", Eager(fn_ecma_ceiling))
  registry.register("ISO.CEILING", Eager(fn_iso_ceiling))
  registry.register("SERIESSUM", Eager(fn_seriessum))
  registry.register("MDETERM", Eager(fn_mdeterm))
  registry.register("MINVERSE", Eager(fn_minverse))
  registry.register("MMULT", Eager(fn_mmult))
}

// ---------------------------------------------------------------------------
// Trig primitives — no sin/cos in MoonBit core; McLaurin series with
// Clenshaw summation, range-reduced to [-π, π].
// ---------------------------------------------------------------------------

let trig_pi : Double = 3.14159265358979323846

fn reduce_angle(x : Double) -> Double {
  let two_pi = 2.0 * trig_pi
  let mut r = x % two_pi
  if r > trig_pi {
    r = r - two_pi
  }
  if r < -trig_pi {
    r = r + two_pi
  }
  r
}

fn sin_raw(x : Double) -> Double {
  let r = reduce_angle(x)
  let r2 = r * r
  let mut term = r
  let mut sum = r
  for i in 1..=12 {
    term = -term * r2 / ((2 * i).to_double() * (2 * i + 1).to_double())
    sum = sum + term
  }
  sum
}

fn cos_raw(x : Double) -> Double {
  let r = reduce_angle(x)
  let r2 = r * r
  let mut term = 1.0
  let mut sum = 1.0
  for i in 1..=12 {
    term = -term * r2 / ((2 * i - 1).to_double() * (2 * i).to_double())
    sum = sum + term
  }
  sum
}

fn atan_raw(x : Double) -> Double {
  if x > 1.0 {
    return trig_pi / 2.0 - atan_raw(1.0 / x)
  }
  if x < -1.0 {
    return -trig_pi / 2.0 - atan_raw(1.0 / x)
  }
  // For |x| > 0.4, use the identity: atan(x) = atan(c) + atan((x-c)/(1+x*c))
  // with c chosen so the argument to the second atan is small.
  if x > 0.4 {
    let c = 0.5
    let atan_c = 0.4636476090008061
    let u = (x - c) / (1.0 + x * c)
    return atan_c + atan_series(u)
  }
  if x < -0.4 {
    return -atan_raw(-x)
  }
  atan_series(x)
}

fn atan_series(x : Double) -> Double {
  let x2 = x * x
  let mut term = x
  let mut sum = x
  for i in 1..=25 {
    term = -term * x2
    sum = sum + term / (2 * i + 1).to_double()
  }
  sum
}

fn atan2_raw(y : Double, x : Double) -> Double {
  if x > 0.0 {
    return atan_raw(y / x)
  }
  if x < 0.0 {
    if y >= 0.0 {
      return atan_raw(y / x) + trig_pi
    } else {
      return atan_raw(y / x) - trig_pi
    }
  }
  if y > 0.0 {
    trig_pi / 2.0
  } else if y < 0.0 {
    -trig_pi / 2.0
  } else {
    0.0
  }
}

fn fn_sin(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => checked_number(sin_raw(n))
    other => other
  }
}

fn fn_cos(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => checked_number(cos_raw(n))
    other => other
  }
}

fn fn_tan(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => {
      let c = cos_raw(n)
      if c.abs() < 1.0e-15 {
        VError(Num)
      } else {
        checked_number(sin_raw(n) / c)
      }
    }
    other => other
  }
}

fn fn_asin(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      if n < -1.0 || n > 1.0 {
        VError(Num)
      } else if n == 1.0 {
        VNumber(trig_pi / 2.0)
      } else if n == -1.0 {
        VNumber(-trig_pi / 2.0)
      } else {
        VNumber(atan2_raw(n, (1.0 - n * n).sqrt()))
      }
    other => other
  }
}

fn fn_acos(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      if n < -1.0 || n > 1.0 {
        VError(Num)
      } else {
        VNumber(atan2_raw((1.0 - n * n).sqrt(), n))
      }
    other => other
  }
}

fn fn_atan(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => VNumber(atan_raw(n))
    other => other
  }
}

fn fn_atan2(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(x), VNumber(y)) =>
          if x == 0.0 && y == 0.0 {
            VError(DivZero)
          } else {
            VNumber(atan2_raw(y, x))
          }
        (VError(e), _) | (_, VError(e)) => VError(e)
        _ => VError(Value)
      }
    other => other
  }
}

// ---------------------------------------------------------------------------
// Hyperbolic functions — built from exp/ln which exist in @math.
// ---------------------------------------------------------------------------

fn fn_sinh(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      checked_number((@math.exp(n) - @math.exp(-n)) / 2.0)
    other => other
  }
}

fn fn_cosh(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      checked_number((@math.exp(n) + @math.exp(-n)) / 2.0)
    other => other
  }
}

fn fn_tanh(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => {
      let ep = @math.exp(n)
      let em = @math.exp(-n)
      checked_number((ep - em) / (ep + em))
    }
    other => other
  }
}

fn fn_asinh(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => checked_number(@math.ln(n + (n * n + 1.0).sqrt()))
    other => other
  }
}

fn fn_acosh(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      if n < 1.0 {
        VError(Num)
      } else {
        checked_number(@math.ln(n + (n * n - 1.0).sqrt()))
      }
    other => other
  }
}

fn fn_atanh(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      if n <= -1.0 || n >= 1.0 {
        VError(Num)
      } else {
        checked_number(0.5 * @math.ln((1.0 + n) / (1.0 - n)))
      }
    other => other
  }
}

// ---------------------------------------------------------------------------
// Angle conversion
// ---------------------------------------------------------------------------

fn fn_degrees(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => VNumber(n * 180.0 / trig_pi)
    other => other
  }
}

fn fn_radians(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => VNumber(n * trig_pi / 180.0)
    other => other
  }
}

// ---------------------------------------------------------------------------
// Combinatorics
// ---------------------------------------------------------------------------

fn fn_combin(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n_d), VNumber(k_d)) => {
          let n = n_d.trunc().to_int()
          let k = k_d.trunc().to_int()
          if n < 0 || k < 0 || k > n {
            VError(Num)
          } else {
            VNumber(combin_int(n, k))
          }
        }
        (VError(e), _) | (_, VError(e)) => VError(e)
        _ => VError(Value)
      }
    other => other
  }
}

fn combin_int(n : Int, k : Int) -> Double {
  let k = if k > n - k { n - k } else { k }
  let mut result = 1.0
  for i in 0..<k {
    result = result * (n - i).to_double() / (i + 1).to_double()
  }
  result
}

fn fn_permut(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n_d), VNumber(k_d)) => {
          let n = n_d.trunc().to_int()
          let k = k_d.trunc().to_int()
          if n < 0 || k < 0 || k > n {
            VError(Num)
          } else {
            let mut result = 1.0
            for i in 0..<k {
              result = result * (n - i).to_double()
            }
            VNumber(result)
          }
        }
        (VError(e), _) | (_, VError(e)) => VError(e)
        _ => VError(Value)
      }
    other => other
  }
}

// ---------------------------------------------------------------------------
// Rounding variants
// ---------------------------------------------------------------------------

fn fn_even(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => {
      let c = if n >= 0.0 { n.ceil() } else { n.floor() }
      let ci = c.to_int()
      let result = if ci % 2 == 0 {
        c
      } else if n >= 0.0 {
        c + 1.0
      } else {
        c - 1.0
      }
      VNumber(result)
    }
    other => other
  }
}

fn fn_odd(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      if n == 0.0 {
        VNumber(1.0)
      } else {
        let c = if n > 0.0 { n.ceil() } else { n.floor() }
        let ci = c.to_int().abs()
        let result = if ci % 2 == 1 {
          c
        } else if n > 0.0 {
          c + 1.0
        } else {
          c - 1.0
        }
        VNumber(result)
      }
    other => other
  }
}

// ---------------------------------------------------------------------------
// Factorials
// ---------------------------------------------------------------------------

fn fn_fact(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => {
      let k = n.trunc().to_int()
      if k < 0 {
        VError(Num)
      } else {
        let mut result = 1.0
        for i in 2..=k {
          result = result * i.to_double()
        }
        checked_number(result)
      }
    }
    other => other
  }
}

fn fn_factdouble(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => {
      let k = n.trunc().to_int()
      if k < -1 {
        VError(Num)
      } else if k <= 0 {
        VNumber(1.0)
      } else {
        let mut result = 1.0
        let mut i = k
        while i > 1 {
          result = result * i.to_double()
          i = i - 2
        }
        checked_number(result)
      }
    }
    other => other
  }
}

// ---------------------------------------------------------------------------
// GCD / LCM
// ---------------------------------------------------------------------------

fn gcd_pair(a : Double, b : Double) -> Double {
  let mut a = a.abs().trunc()
  let mut b = b.abs().trunc()
  while b > 0.0 {
    let t = b
    b = a % b
    a = t
  }
  a
}

fn fn_gcd(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    return VError(Value)
  }
  let mut result = 0.0
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) =>
        if n < 0.0 {
          return VError(Num)
        } else {
          result = gcd_pair(result, n)
        }
      VError(e) => return VError(e)
      _ => ()
    }
  }
  VNumber(result)
}

fn fn_lcm(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    return VError(Value)
  }
  let mut result = 1.0
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) =>
        if n < 0.0 {
          return VError(Num)
        } else {
          let n = n.trunc()
          if n == 0.0 {
            return VNumber(0.0)
          }
          let g = gcd_pair(result, n)
          result = result / g * n
        }
      VError(e) => return VError(e)
      _ => ()
    }
  }
  checked_number(result)
}

// ---------------------------------------------------------------------------
// MROUND, QUOTIENT, RANDBETWEEN
// ---------------------------------------------------------------------------

fn fn_mround(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n), VNumber(m)) =>
          if m == 0.0 {
            VNumber(0.0)
          } else if n * m < 0.0 {
            VError(Num)
          } else {
            VNumber((n / m + 0.5).floor() * m)
          }
        (VError(e), _) | (_, VError(e)) => VError(e)
        _ => VError(Value)
      }
    other => other
  }
}

fn fn_quotient(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n), VNumber(d)) =>
          if d == 0.0 {
            VError(DivZero)
          } else {
            VNumber((n / d).trunc())
          }
        (VError(e), _) | (_, VError(e)) => VError(e)
        _ => VError(Value)
      }
    other => other
  }
}

fn fn_randbetween(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(lo), VNumber(hi)) => {
          let lo = lo.ceil()
          let hi = hi.floor()
          if lo > hi {
            VError(Num)
          } else {
            let range = hi - lo + 1.0
            VNumber((fn_rand_value() * range).floor() + lo)
          }
        }
        (VError(e), _) | (_, VError(e)) => VError(e)
        _ => VError(Value)
      }
    other => other
  }
}

fn fn_rand_value() -> Double {
  0.5
}

// ---------------------------------------------------------------------------
// MULTINOMIAL
// ---------------------------------------------------------------------------

fn fn_multinomial(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    return VError(Value)
  }
  let mut sum = 0
  let mut denom = 1.0
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => {
        let k = n.trunc().to_int()
        if k < 0 {
          return VError(Num)
        }
        sum = sum + k
        let mut f = 1.0
        for i in 2..=k {
          f = f * i.to_double()
        }
        denom = denom * f
      }
      VError(e) => return VError(e)
      _ => ()
    }
  }
  let mut num = 1.0
  for i in 2..=sum {
    num = num * i.to_double()
  }
  checked_number(num / denom)
}

// ---------------------------------------------------------------------------
// ROMAN
// ---------------------------------------------------------------------------

fn fn_roman(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => {
      let k = n.trunc().to_int()
      if k < 0 || k > 3999 {
        VError(Value)
      } else if k == 0 {
        VString("")
      } else {
        VString(to_roman(k))
      }
    }
    other => other
  }
}

fn to_roman(n : Int) -> String {
  let vals : FixedArray[Int] = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
  let syms : FixedArray[String] = [
    "M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I",
  ]
  let buf = StringBuilder::new()
  let mut rem = n
  for i in 0..<vals.length() {
    while rem >= vals[i] {
      buf.write_string(syms[i])
      rem = rem - vals[i]
    }
  }
  buf.to_string()
}

// ---------------------------------------------------------------------------
// SQRTPI
// ---------------------------------------------------------------------------

fn fn_sqrtpi(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      if n < 0.0 {
        VError(Num)
      } else {
        checked_number((n * trig_pi).sqrt())
      }
    other => other
  }
}

// ---------------------------------------------------------------------------
// SUBTOTAL — dispatch to aggregate function by function_num
// ---------------------------------------------------------------------------

fn fn_subtotal(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 2 {
    return VError(Value)
  }
  match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(fn_num_d) => {
      let fn_num = fn_num_d.trunc().to_int()
      let sub_args : Array[FormulaValue] = []
      for i in 1..<args.length() {
        sub_args.push(args[i])
      }
      match fn_num {
        1 | 101 => fn_subtotal_average(sub_args, ctx)
        2 | 102 => fn_subtotal_count(sub_args, ctx)
        3 | 103 => fn_subtotal_counta(sub_args, ctx)
        4 | 104 => fn_subtotal_max(sub_args, ctx)
        5 | 105 => fn_subtotal_min(sub_args, ctx)
        6 | 106 => fn_subtotal_product(sub_args, ctx)
        7 | 107 => fn_subtotal_stdev(sub_args, ctx)
        9 | 109 => fn_subtotal_sum(sub_args, ctx)
        10 | 110 => fn_subtotal_var(sub_args, ctx)
        11 | 111 => fn_subtotal_count(sub_args, ctx)
        _ => VError(Value)
      }
    }
    VError(e) => VError(e)
    _ => VError(Value)
  }
}

fn fn_subtotal_sum(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let mut total = 0.0
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => total = total + n
      VError(e) => return VError(e)
      _ => ()
    }
  }
  VNumber(total)
}

fn fn_subtotal_count(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  let mut count = 0
  for arg in args {
    match arg.first_scalar() {
      VNumber(_) => count = count + 1
      _ => ()
    }
  }
  VNumber(count.to_double())
}

fn fn_subtotal_counta(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  let mut count = 0
  for arg in args {
    match arg.first_scalar() {
      VEmpty => ()
      _ => count = count + 1
    }
  }
  VNumber(count.to_double())
}

fn fn_subtotal_average(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let mut total = 0.0
  let mut count = 0
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => {
        total = total + n
        count = count + 1
      }
      VError(e) => return VError(e)
      _ => ()
    }
  }
  if count == 0 {
    VError(DivZero)
  } else {
    VNumber(total / count.to_double())
  }
}

fn fn_subtotal_max(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let mut result = -1.0 / 0.0
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => if n > result { result = n }
      VError(e) => return VError(e)
      _ => ()
    }
  }
  if result.is_inf() { VNumber(0.0) } else { VNumber(result) }
}

fn fn_subtotal_min(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let mut result = 1.0 / 0.0
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => if n < result { result = n }
      VError(e) => return VError(e)
      _ => ()
    }
  }
  if result.is_inf() { VNumber(0.0) } else { VNumber(result) }
}

fn fn_subtotal_product(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let mut result = 1.0
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => result = result * n
      VError(e) => return VError(e)
      _ => ()
    }
  }
  VNumber(result)
}

fn fn_subtotal_stdev(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let values : Array[Double] = []
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => values.push(n)
      VError(e) => return VError(e)
      _ => ()
    }
  }
  if values.length() < 2 {
    return VError(DivZero)
  }
  let mut sum = 0.0
  for v in values {
    sum = sum + v
  }
  let mean = sum / values.length().to_double()
  let mut ss = 0.0
  for v in values {
    let d = v - mean
    ss = ss + d * d
  }
  checked_number((ss / (values.length() - 1).to_double()).sqrt())
}

fn fn_subtotal_var(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let values : Array[Double] = []
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => values.push(n)
      VError(e) => return VError(e)
      _ => ()
    }
  }
  if values.length() < 2 {
    return VError(DivZero)
  }
  let mut sum = 0.0
  for v in values {
    sum = sum + v
  }
  let mean = sum / values.length().to_double()
  let mut ss = 0.0
  for v in values {
    let d = v - mean
    ss = ss + d * d
  }
  VNumber(ss / (values.length() - 1).to_double())
}

// ---------------------------------------------------------------------------
// SUMSQ, SUMX2MY2, SUMX2PY2, SUMXMY2
// ---------------------------------------------------------------------------

fn fn_sumsq(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let mut total = 0.0
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => total = total + n * n
      VError(e) => return VError(e)
      _ => ()
    }
  }
  VNumber(total)
}

fn extract_number_array(
  v : FormulaValue,
  ds : @date_serial.DateSystem,
) -> Array[Double] {
  let out : Array[Double] = []
  match v {
    VArray(rows) =>
      for row in rows {
        for cell in row {
          match coerce_to_number(cell, ds) {
            VNumber(n) => out.push(n)
            _ => ()
          }
        }
      }
    VNumber(n) => out.push(n)
    _ => ()
  }
  out
}

fn fn_sumx2my2(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let xs = extract_number_array(args[0], ctx.date_system)
  let ys = extract_number_array(args[1], ctx.date_system)
  let n = if xs.length() < ys.length() { xs.length() } else { ys.length() }
  if n == 0 {
    return VError(Value)
  }
  let mut total = 0.0
  for i in 0..<n {
    total = total + xs[i] * xs[i] - ys[i] * ys[i]
  }
  VNumber(total)
}

fn fn_sumx2py2(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let xs = extract_number_array(args[0], ctx.date_system)
  let ys = extract_number_array(args[1], ctx.date_system)
  let n = if xs.length() < ys.length() { xs.length() } else { ys.length() }
  if n == 0 {
    return VError(Value)
  }
  let mut total = 0.0
  for i in 0..<n {
    total = total + xs[i] * xs[i] + ys[i] * ys[i]
  }
  VNumber(total)
}

fn fn_sumxmy2(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let xs = extract_number_array(args[0], ctx.date_system)
  let ys = extract_number_array(args[1], ctx.date_system)
  let n = if xs.length() < ys.length() { xs.length() } else { ys.length() }
  if n == 0 {
    return VError(Value)
  }
  let mut total = 0.0
  for i in 0..<n {
    let d = xs[i] - ys[i]
    total = total + d * d
  }
  VNumber(total)
}

// ---------------------------------------------------------------------------
// ECMA.CEILING / ISO.CEILING
// ---------------------------------------------------------------------------

fn fn_ecma_ceiling(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match two_numbers(args, ctx) {
    VArray(rows) =>
      match (rows[0][0], rows[0][1]) {
        (VNumber(n), VNumber(sig)) =>
          if sig == 0.0 {
            VNumber(0.0)
          } else {
            VNumber((n / sig.abs()).ceil() * sig.abs())
          }
        (VError(e), _) | (_, VError(e)) => VError(e)
        _ => VError(Value)
      }
    other => other
  }
}

fn fn_iso_ceiling(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 {
    return VError(Value)
  }
  let n = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(v) => v
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let sig = if args.length() == 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(v) => v.abs()
      VError(e) => return VError(e)
      _ => return VError(Value)
    }
  } else {
    1.0
  }
  if sig == 0.0 {
    VNumber(0.0)
  } else {
    VNumber((n / sig).ceil() * sig)
  }
}

// ---------------------------------------------------------------------------
// SERIESSUM
// ---------------------------------------------------------------------------

fn fn_seriessum(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 4 {
    return VError(Value)
  }
  let x = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(v) => v
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let n = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(v) => v
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let m = match coerce_to_number(args[2].first_scalar(), ctx.date_system) {
    VNumber(v) => v
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let coeffs = extract_number_array(args[3], ctx.date_system)
  if coeffs.length() == 0 {
    return VError(Value)
  }
  let mut result = 0.0
  for i, c in coeffs {
    result = result + c * @math.pow(x, n + m * i.to_double())
  }
  checked_number(result)
}

// ---------------------------------------------------------------------------
// Matrix: MDETERM, MINVERSE, MMULT
// ---------------------------------------------------------------------------

fn to_matrix(v : FormulaValue, ds : @date_serial.DateSystem) -> Array[Array[Double]]? {
  match v {
    VArray(rows) => {
      let out : Array[Array[Double]] = []
      for row in rows {
        let r : Array[Double] = []
        for cell in row {
          match coerce_to_number(cell, ds) {
            VNumber(n) => r.push(n)
            _ => return None
          }
        }
        out.push(r)
      }
      Some(out)
    }
    VNumber(n) => Some([[n]])
    _ => None
  }
}

fn fn_mdeterm(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match to_matrix(args[0], ctx.date_system) {
    None => VError(Value)
    Some(mat) => {
      let n = mat.length()
      if n == 0 {
        return VError(Value)
      }
      for row in mat {
        if row.length() != n {
          return VError(Value)
        }
      }
      checked_number(determinant(mat, n))
    }
  }
}

fn determinant(mat : Array[Array[Double]], n : Int) -> Double {
  let a : Array[Array[Double]] = []
  for row in mat {
    let r : Array[Double] = []
    for v in row {
      r.push(v)
    }
    a.push(r)
  }
  let mut det = 1.0
  for col in 0..<n {
    let mut pivot = col
    for row in (col + 1)..<n {
      if a[row][col].abs() > a[pivot][col].abs() {
        pivot = row
      }
    }
    if pivot != col {
      let tmp = a[col]
      a[col] = a[pivot]
      a[pivot] = tmp
      det = -det
    }
    if a[col][col].abs() < 1.0e-15 {
      return 0.0
    }
    det = det * a[col][col]
    for row in (col + 1)..<n {
      let factor = a[row][col] / a[col][col]
      for j in col..<n {
        a[row][j] = a[row][j] - factor * a[col][j]
      }
    }
  }
  det
}

fn fn_minverse(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match to_matrix(args[0], ctx.date_system) {
    None => VError(Value)
    Some(mat) => {
      let n = mat.length()
      if n == 0 {
        return VError(Value)
      }
      for row in mat {
        if row.length() != n {
          return VError(Value)
        }
      }
      match invert_matrix(mat, n) {
        None => VError(Num)
        Some(inv) => {
          let rows : Array[Array[FormulaValue]] = []
          for row in inv {
            let r : Array[FormulaValue] = []
            for v in row {
              r.push(VNumber(v))
            }
            rows.push(r)
          }
          VArray(rows)
        }
      }
    }
  }
}

fn invert_matrix(mat : Array[Array[Double]], n : Int) -> Array[Array[Double]]? {
  let a : Array[Array[Double]] = []
  for i in 0..<n {
    let r : Array[Double] = []
    for j in 0..<n {
      r.push(mat[i][j])
    }
    for j in 0..<n {
      r.push(if i == j { 1.0 } else { 0.0 })
    }
    a.push(r)
  }
  for col in 0..<n {
    let mut pivot = col
    for row in (col + 1)..<n {
      if a[row][col].abs() > a[pivot][col].abs() {
        pivot = row
      }
    }
    if a[pivot][col].abs() < 1.0e-15 {
      return None
    }
    if pivot != col {
      let tmp = a[col]
      a[col] = a[pivot]
      a[pivot] = tmp
    }
    let diag = a[col][col]
    let nn = 2 * n
    for j in 0..<nn {
      a[col][j] = a[col][j] / diag
    }
    for row in 0..<n {
      if row != col {
        let factor = a[row][col]
        for j in 0..<nn {
          a[row][j] = a[row][j] - factor * a[col][j]
        }
      }
    }
  }
  let result : Array[Array[Double]] = []
  let nn = 2 * n
  for i in 0..<n {
    let r : Array[Double] = []
    for j in n..<nn {
      r.push(a[i][j])
    }
    result.push(r)
  }
  Some(result)
}

fn fn_mmult(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  match (to_matrix(args[0], ctx.date_system), to_matrix(args[1], ctx.date_system)) {
    (Some(a), Some(b)) => {
      let m = a.length()
      if m == 0 {
        return VError(Value)
      }
      let k = a[0].length()
      let n = b[0].length()
      if b.length() != k {
        return VError(Value)
      }
      let rows : Array[Array[FormulaValue]] = []
      for i in 0..<m {
        let row : Array[FormulaValue] = []
        for j in 0..<n {
          let mut sum = 0.0
          for p in 0..<k {
            sum = sum + a[i][p] * b[p][j]
          }
          row.push(VNumber(sum))
        }
        rows.push(row)
      }
      VArray(rows)
    }
    _ => VError(Value)
  }
}

