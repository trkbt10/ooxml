///|
fn register_builtin_financial_functions(registry : FunctionRegistry) -> Unit {
  registry.register("PMT", Eager(fn_pmt))
  registry.register("PV", Eager(fn_pv))
  registry.register("FV", Eager(fn_fv))
  registry.register("NPER", Eager(fn_nper))
  registry.register("RATE", Eager(fn_rate))
  registry.register("NPV", Eager(fn_npv))
  registry.register("IRR", Eager(fn_irr))
  registry.register("MIRR", Eager(fn_mirr))
  registry.register("IPMT", Eager(fn_ipmt))
  registry.register("PPMT", Eager(fn_ppmt))
  registry.register("CUMIPMT", Eager(fn_cumipmt))
  registry.register("CUMPRINC", Eager(fn_cumprinc))
  registry.register("SLN", Eager(fn_sln))
  registry.register("SYD", Eager(fn_syd))
  registry.register("DB", Eager(fn_db))
  registry.register("DDB", Eager(fn_ddb))
  registry.register("EFFECT", Eager(fn_effect))
  registry.register("NOMINAL", Eager(fn_nominal))
}

///|
priv struct TvmArgs {
  rate : Double
  nper : Double
  pv : Double
  fv : Double
  payment_type : Double
}

///|
/// §18.17.7.PMT — compute the periodic payment for an annuity.
fn fn_pmt(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 5 {
    return VError(Value)
  }
  match financial_numbers(args, ctx, 3, [0.0, 0.0]) {
    VArray(rows) => {
      let v = rows[0]
      let tvm = {
        rate: v[0].number_or_zero(),
        nper: v[1].number_or_zero(),
        pv: v[2].number_or_zero(),
        fv: v[3].number_or_zero(),
        payment_type: v[4].number_or_zero(),
      }
      if !valid_payment_type(tvm.payment_type) || tvm.nper == 0.0 {
        VError(Num)
      } else {
        checked_number(
          tvm_pmt(tvm.rate, tvm.nper, tvm.pv, tvm.fv, tvm.payment_type),
        )
      }
    }
    other => other
  }
}

///|
/// §18.17.7.PV — compute the present value of an investment.
fn fn_pv(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 5 {
    return VError(Value)
  }
  match financial_numbers(args, ctx, 3, [0.0, 0.0]) {
    VArray(rows) => {
      let v = rows[0]
      let rate = v[0].number_or_zero()
      let nper = v[1].number_or_zero()
      let pmt = v[2].number_or_zero()
      let fv = v[3].number_or_zero()
      let payment_type = v[4].number_or_zero()
      if !valid_payment_type(payment_type) {
        VError(Num)
      } else {
        checked_number(tvm_pv(rate, nper, pmt, fv, payment_type))
      }
    }
    other => other
  }
}

///|
/// §18.17.7.FV — compute the future value of an investment.
fn fn_fv(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 5 {
    return VError(Value)
  }
  match financial_numbers(args, ctx, 3, [0.0, 0.0]) {
    VArray(rows) => {
      let v = rows[0]
      let rate = v[0].number_or_zero()
      let nper = v[1].number_or_zero()
      let pmt = v[2].number_or_zero()
      let pv = v[3].number_or_zero()
      let payment_type = v[4].number_or_zero()
      if !valid_payment_type(payment_type) {
        VError(Num)
      } else {
        checked_number(tvm_fv(rate, nper, pmt, pv, payment_type))
      }
    }
    other => other
  }
}

///|
/// §18.17.7.NPER — compute the number of payment periods.
fn fn_nper(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 5 {
    return VError(Value)
  }
  match financial_numbers(args, ctx, 3, [0.0, 0.0]) {
    VArray(rows) => {
      let v = rows[0]
      let rate = v[0].number_or_zero()
      let pmt = v[1].number_or_zero()
      let pv = v[2].number_or_zero()
      let fv = v[3].number_or_zero()
      let payment_type = v[4].number_or_zero()
      if !valid_payment_type(payment_type) {
        return VError(Num)
      }
      if rate == 0.0 {
        if pmt == 0.0 {
          VError(Num)
        } else {
          checked_number(-(pv + fv) / pmt)
        }
      } else {
        let adjusted = pmt * (1.0 + rate * payment_type) / rate
        let numerator = adjusted - fv
        let denominator = pv + adjusted
        if numerator <= 0.0 || denominator <= 0.0 {
          VError(Num)
        } else {
          checked_number(
            @math.ln(numerator / denominator) / @math.ln(1.0 + rate),
          )
        }
      }
    }
    other => other
  }
}

///|
/// §18.17.7.RATE — solve the periodic interest rate by Newton-Raphson.
fn fn_rate(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 6 {
    return VError(Value)
  }
  match financial_numbers(args, ctx, 3, [0.0, 0.0, 0.1]) {
    VArray(rows) => {
      let v = rows[0]
      let nper = v[0].number_or_zero()
      let pmt = v[1].number_or_zero()
      let pv = v[2].number_or_zero()
      let fv = v[3].number_or_zero()
      let payment_type = v[4].number_or_zero()
      let guess = v[5].number_or_zero()
      if !valid_payment_type(payment_type) || nper == 0.0 {
        return VError(Num)
      }
      newton_solve(guess, fn(rate) {
        tvm_equation(rate, nper, pmt, pv, fv, payment_type)
      })
    }
    other => other
  }
}

///|
/// §18.17.7.NPV — compute net present value from a rate and cash flows.
fn fn_npv(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 2 {
    return VError(Value)
  }
  let rate = scalar_number(args[0], ctx)
  match rate {
    VNumber(r) => {
      if r == -1.0 {
        return VError(DivZero)
      }
      let values = collect_financial_cashflows(args, 1, ctx)
      match values.error {
        Some(err) => VError(err)
        None => {
          let mut total = 0.0
          for i in 0..<values.values.length() {
            total += values.values[i] / @math.pow(1.0 + r, (i + 1).to_double())
          }
          checked_number(total)
        }
      }
    }
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.IRR — solve the internal rate of return for periodic cash flows.
fn fn_irr(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 {
    return VError(Value)
  }
  let values = collect_financial_cashflows(args, 0, ctx, stop=1)
  match values.error {
    Some(err) => VError(err)
    None => {
      let guess = if args.length() == 2 {
        match scalar_number(args[1], ctx) {
          VNumber(n) => n
          VError(err) => return VError(err)
          _ => return VError(Value)
        }
      } else {
        0.1
      }
      if !cashflows_have_both_signs(values.values) {
        return VError(Num)
      }
      newton_solve(guess, fn(rate) { irr_equation(rate, values.values) })
    }
  }
}

///|
/// §18.17.7.MIRR — compute modified internal rate of return.
fn fn_mirr(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 {
    return VError(Value)
  }
  let values = collect_financial_cashflows(args, 0, ctx, stop=1)
  let finance_rate = scalar_number(args[1], ctx)
  let reinvest_rate = scalar_number(args[2], ctx)
  match (values.error, finance_rate, reinvest_rate) {
    (Some(err), _, _) => VError(err)
    (None, VNumber(fr), VNumber(rr)) => {
      if values.values.length() < 2 || !cashflows_have_both_signs(values.values) {
        return VError(Num)
      }
      let n = values.values.length()
      let mut pos_fv = 0.0
      let mut neg_pv = 0.0
      for i in 0..<n {
        let value = values.values[i]
        if value > 0.0 {
          pos_fv += value * @math.pow(1.0 + rr, (n - i - 1).to_double())
        } else if value < 0.0 {
          neg_pv += value / @math.pow(1.0 + fr, i.to_double())
        }
      }
      if neg_pv == 0.0 || pos_fv == 0.0 {
        VError(DivZero)
      } else {
        checked_number(
          @math.pow(-pos_fv / neg_pv, 1.0 / (n - 1).to_double()) - 1.0,
        )
      }
    }
    (None, VError(err), _) | (None, _, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.IPMT — compute the interest portion of a payment period.
fn fn_ipmt(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  financial_payment_part(args, ctx, interest=true)
}

///|
/// §18.17.7.PPMT — compute the principal portion of a payment period.
fn fn_ppmt(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  financial_payment_part(args, ctx, interest=false)
}

///|
/// §18.17.7.CUMIPMT — compute cumulative interest over a period span.
fn fn_cumipmt(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  cumulative_payment_part(args, ctx, interest=true)
}

///|
/// §18.17.7.CUMPRINC — compute cumulative principal over a period span.
fn fn_cumprinc(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  cumulative_payment_part(args, ctx, interest=false)
}

///|
/// §18.17.7.SLN — compute straight-line depreciation.
fn fn_sln(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match financial_numbers_exact(args, ctx, 3) {
    VArray(rows) => {
      let v = rows[0]
      let life = v[2].number_or_zero()
      if life == 0.0 {
        VError(DivZero)
      } else {
        checked_number((v[0].number_or_zero() - v[1].number_or_zero()) / life)
      }
    }
    other => other
  }
}

///|
/// §18.17.7.SYD — compute sum-of-years' digits depreciation.
fn fn_syd(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match financial_numbers_exact(args, ctx, 4) {
    VArray(rows) => {
      let v = rows[0]
      let life = v[2].number_or_zero()
      let per = v[3].number_or_zero()
      if life <= 0.0 || per <= 0.0 || per > life {
        VError(Num)
      } else {
        checked_number(
          (v[0].number_or_zero() - v[1].number_or_zero()) *
          (life - per + 1.0) *
          2.0 /
          (life * (life + 1.0)),
        )
      }
    }
    other => other
  }
}

///|
/// §18.17.7.DB — compute fixed declining-balance depreciation.
fn fn_db(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 4 || args.length() > 5 {
    return VError(Value)
  }
  match financial_numbers(args, ctx, 4, [12.0]) {
    VArray(rows) => {
      let v = rows[0]
      let cost = v[0].number_or_zero()
      let salvage = v[1].number_or_zero()
      let life = v[2].number_or_zero().trunc().to_int()
      let period = v[3].number_or_zero().trunc().to_int()
      let month = v[4].number_or_zero()
      if cost <= 0.0 ||
        salvage < 0.0 ||
        life <= 0 ||
        period <= 0 ||
        period > life ||
        month <= 0.0 ||
        month > 12.0 {
        return VError(Num)
      }
      let rate = financial_round_unit(
        1.0 - @math.pow(salvage / cost, 1.0 / life.to_double()),
      )
      let mut book = cost
      let mut dep = cost * rate * month / 12.0
      for p in 2..<=period {
        book -= dep
        dep = if p == life {
          book * rate * (12.0 - month) / 12.0
        } else {
          book * rate
        }
      }
      checked_number(dep)
    }
    other => other
  }
}

///|
/// §18.17.7.DDB — compute double-declining balance depreciation.
fn fn_ddb(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 4 || args.length() > 5 {
    return VError(Value)
  }
  match financial_numbers(args, ctx, 4, [2.0]) {
    VArray(rows) => {
      let v = rows[0]
      let cost = v[0].number_or_zero()
      let salvage = v[1].number_or_zero()
      let life = v[2].number_or_zero()
      let period = v[3].number_or_zero().trunc().to_int()
      let factor = v[4].number_or_zero()
      if cost < 0.0 ||
        salvage < 0.0 ||
        life <= 0.0 ||
        period <= 0 ||
        factor <= 0.0 {
        return VError(Num)
      }
      let mut book = cost
      let mut dep = 0.0
      for _ in 1..<=period {
        dep = (book * factor / life).min(book - salvage)
        if dep < 0.0 {
          dep = 0.0
        }
        book -= dep
      }
      checked_number(dep)
    }
    other => other
  }
}

///|
/// §18.17.7.EFFECT — compute the effective annual interest rate.
fn fn_effect(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match financial_numbers_exact(args, ctx, 2) {
    VArray(rows) => {
      let nominal = rows[0][0].number_or_zero()
      let npery = rows[0][1].number_or_zero().trunc()
      if nominal <= 0.0 || npery < 1.0 {
        VError(Num)
      } else {
        checked_number(@math.pow(1.0 + nominal / npery, npery) - 1.0)
      }
    }
    other => other
  }
}

///|
/// §18.17.7.NOMINAL — compute nominal annual interest from an effective rate.
fn fn_nominal(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match financial_numbers_exact(args, ctx, 2) {
    VArray(rows) => {
      let effect = rows[0][0].number_or_zero()
      let npery = rows[0][1].number_or_zero().trunc()
      if effect <= 0.0 || npery < 1.0 {
        VError(Num)
      } else {
        checked_number(npery * (@math.pow(effect + 1.0, 1.0 / npery) - 1.0))
      }
    }
    other => other
  }
}

///|
priv struct FinancialValues {
  values : Array[Double]
  error : FormulaError?
}

///|
fn financial_numbers_exact(
  args : Array[FormulaValue],
  ctx : EvalContext,
  count : Int,
) -> FormulaValue {
  if args.length() != count {
    return VError(Value)
  }
  financial_numbers(args, ctx, count, [])
}

///|
fn financial_numbers(
  args : Array[FormulaValue],
  ctx : EvalContext,
  required : Int,
  defaults : Array[Double],
) -> FormulaValue {
  let out = Array::new()
  for i in 0..<required {
    match scalar_number(args[i], ctx) {
      VNumber(n) => out.push(VNumber(n))
      VError(err) => return VError(err)
      _ => return VError(Value)
    }
  }
  for i in required..<(required + defaults.length()) {
    if i < args.length() {
      match scalar_number(args[i], ctx) {
        VNumber(n) => out.push(VNumber(n))
        VError(err) => return VError(err)
        _ => return VError(Value)
      }
    } else {
      out.push(VNumber(defaults[i - required]))
    }
  }
  VArray([out])
}

///|
fn FormulaValue::number_or_zero(self : FormulaValue) -> Double {
  match self {
    VNumber(n) => n
    _ => 0.0
  }
}

///|
fn valid_payment_type(payment_type : Double) -> Bool {
  payment_type == 0.0 || payment_type == 1.0
}

///|
fn tvm_pmt(
  rate : Double,
  nper : Double,
  pv : Double,
  fv : Double,
  payment_type : Double,
) -> Double {
  if rate == 0.0 {
    -(pv + fv) / nper
  } else {
    let factor = @math.pow(1.0 + rate, nper)
    -(pv * factor + fv) * rate / ((1.0 + rate * payment_type) * (factor - 1.0))
  }
}

///|
fn tvm_pv(
  rate : Double,
  nper : Double,
  pmt : Double,
  fv : Double,
  payment_type : Double,
) -> Double {
  if rate == 0.0 {
    -fv - pmt * nper
  } else {
    let factor = @math.pow(1.0 + rate, nper)
    -(fv + pmt * (1.0 + rate * payment_type) * (factor - 1.0) / rate) / factor
  }
}

///|
fn tvm_fv(
  rate : Double,
  nper : Double,
  pmt : Double,
  pv : Double,
  payment_type : Double,
) -> Double {
  if rate == 0.0 {
    -pv - pmt * nper
  } else {
    let factor = @math.pow(1.0 + rate, nper)
    -pv * factor - pmt * (1.0 + rate * payment_type) * (factor - 1.0) / rate
  }
}

///|
fn tvm_equation(
  rate : Double,
  nper : Double,
  pmt : Double,
  pv : Double,
  fv : Double,
  payment_type : Double,
) -> Double {
  if rate == 0.0 {
    pv + pmt * nper + fv
  } else {
    let factor = @math.pow(1.0 + rate, nper)
    pv * factor + pmt * (1.0 + rate * payment_type) * (factor - 1.0) / rate + fv
  }
}

///|
fn irr_equation(rate : Double, values : Array[Double]) -> Double {
  let mut total = 0.0
  for i in 0..<values.length() {
    total += values[i] / @math.pow(1.0 + rate, i.to_double())
  }
  total
}

///|
fn newton_solve(guess : Double, f : (Double) -> Double) -> FormulaValue {
  let mut x = guess
  for _ in 0..<50 {
    let y = f(x)
    if y.abs() < 0.0000001 {
      return checked_number(x)
    }
    let step = 0.000001
    let derivative = (f(x + step) - f(x - step)) / (2.0 * step)
    if derivative.abs() < 0.000000000001 {
      return VError(Num)
    }
    let next = x - y / derivative
    if next.is_nan() || next.is_inf() || next <= -1.0 {
      return VError(Num)
    }
    if (next - x).abs() < 0.0000001 {
      return checked_number(next)
    }
    x = next
  }
  VError(Num)
}

///|
fn collect_financial_cashflows(
  args : Array[FormulaValue],
  start : Int,
  ctx : EvalContext,
  stop? : Int = args.length(),
) -> FinancialValues {
  let values = Array::new()
  for i in start..<stop {
    match args[i] {
      VArray(rows) =>
        for row in rows {
          for cell in row {
            match cell {
              VNumber(n) => values.push(n)
              VError(err) => return { values, error: Some(err) }
              _ => ()
            }
          }
        }
      other =>
        match scalar_number(other, ctx) {
          VNumber(n) => values.push(n)
          VError(err) => return { values, error: Some(err) }
          _ => ()
        }
    }
  }
  { values, error: None }
}

///|
fn cashflows_have_both_signs(values : Array[Double]) -> Bool {
  let mut pos = false
  let mut neg = false
  for value in values {
    if value > 0.0 {
      pos = true
    }
    if value < 0.0 {
      neg = true
    }
  }
  pos && neg
}

///|
fn financial_payment_part(
  args : Array[FormulaValue],
  ctx : EvalContext,
  interest~ : Bool,
) -> FormulaValue {
  if args.length() < 4 || args.length() > 6 {
    return VError(Value)
  }
  match financial_numbers(args, ctx, 4, [0.0, 0.0]) {
    VArray(rows) => {
      let v = rows[0]
      let rate = v[0].number_or_zero()
      let per = v[1].number_or_zero().trunc().to_int()
      let nper = v[2].number_or_zero()
      let pv = v[3].number_or_zero()
      let fv = v[4].number_or_zero()
      let payment_type = v[5].number_or_zero()
      if !valid_payment_type(payment_type) || per < 1 || per.to_double() > nper {
        return VError(Num)
      }
      let pmt = tvm_pmt(rate, nper, pv, fv, payment_type)
      let ip = period_interest(rate, per, nper, pv, fv, payment_type, pmt)
      checked_number(if interest { ip } else { pmt - ip })
    }
    other => other
  }
}

///|
fn cumulative_payment_part(
  args : Array[FormulaValue],
  ctx : EvalContext,
  interest~ : Bool,
) -> FormulaValue {
  if args.length() != 6 {
    return VError(Value)
  }
  match financial_numbers_exact(args, ctx, 6) {
    VArray(rows) => {
      let v = rows[0]
      let rate = v[0].number_or_zero()
      let nper = v[1].number_or_zero()
      let pv = v[2].number_or_zero()
      let start = v[3].number_or_zero().trunc().to_int()
      let end = v[4].number_or_zero().trunc().to_int()
      let payment_type = v[5].number_or_zero()
      if rate <= 0.0 ||
        nper <= 0.0 ||
        pv <= 0.0 ||
        start < 1 ||
        end < start ||
        end.to_double() > nper ||
        !valid_payment_type(payment_type) {
        return VError(Num)
      }
      let pmt = tvm_pmt(rate, nper, pv, 0.0, payment_type)
      let mut total = 0.0
      for per in start..<=end {
        let ip = period_interest(rate, per, nper, pv, 0.0, payment_type, pmt)
        total += if interest { ip } else { pmt - ip }
      }
      checked_number(total)
    }
    other => other
  }
}

///|
fn period_interest(
  rate : Double,
  per : Int,
  nper : Double,
  pv : Double,
  fv : Double,
  payment_type : Double,
  pmt : Double,
) -> Double {
  let _ = nper
  let _ = fv
  if rate == 0.0 {
    0.0
  } else if payment_type == 1.0 && per == 1 {
    0.0
  } else {
    let previous = if payment_type == 1.0 {
      tvm_fv(rate, (per - 2).to_double(), pmt, pv, 1.0) + pmt
    } else {
      tvm_fv(rate, (per - 1).to_double(), pmt, pv, 0.0)
    }
    previous * rate
  }
}

///|
fn financial_round_unit(value : Double) -> Double {
  (value * 1000.0 + 0.5).floor() / 1000.0
}
