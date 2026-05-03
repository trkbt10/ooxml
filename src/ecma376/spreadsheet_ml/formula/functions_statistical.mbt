///|
fn register_builtin_statistical_functions(registry : FunctionRegistry) -> Unit {
  registry.register("STDEV", Eager(fn_stdev))
  registry.register("STDEV.S", Eager(fn_stdev))
  registry.register("STDEVP", Eager(fn_stdevp))
  registry.register("STDEV.P", Eager(fn_stdevp))
  registry.register("VAR", Eager(fn_var))
  registry.register("VAR.S", Eager(fn_var))
  registry.register("VARP", Eager(fn_varp))
  registry.register("VAR.P", Eager(fn_varp))
  registry.register("MEDIAN", Eager(fn_median))
  registry.register("MODE", Eager(fn_mode))
  registry.register("MODE.SNGL", Eager(fn_mode))
  registry.register("PERCENTILE", Eager(fn_percentile_inc))
  registry.register("PERCENTILE.INC", Eager(fn_percentile_inc))
  registry.register("PERCENTILE.EXC", Eager(fn_percentile_exc))
  registry.register("QUARTILE", Eager(fn_quartile_inc))
  registry.register("QUARTILE.INC", Eager(fn_quartile_inc))
  registry.register("QUARTILE.EXC", Eager(fn_quartile_exc))
  registry.register("RANK", Eager(fn_rank_eq))
  registry.register("RANK.EQ", Eager(fn_rank_eq))
  registry.register("RANK.AVG", Eager(fn_rank_avg))
  registry.register("LARGE", Eager(fn_large))
  registry.register("SMALL", Eager(fn_small))
  registry.register("CORREL", Eager(fn_correl))
  registry.register("COVAR", Eager(fn_covar))
  registry.register("COVARIANCE.P", Eager(fn_covar))
  registry.register("COVARIANCE.S", Eager(fn_covariance_s))
  registry.register("SLOPE", Eager(fn_slope))
  registry.register("INTERCEPT", Eager(fn_intercept))
  registry.register("TREND", Eager(fn_trend))
  registry.register("FORECAST", Eager(fn_forecast))
  registry.register("GROWTH", Eager(fn_growth))
  registry.register("GEOMEAN", Eager(fn_geomean))
  registry.register("HARMEAN", Eager(fn_harmean))
  registry.register("AVEDEV", Eager(fn_avedev))
  registry.register("DEVSQ", Eager(fn_devsq))
  registry.register("SUMIF", Eager(fn_sumif))
  registry.register("SUMIFS", Eager(fn_sumifs))
  registry.register("COUNTIF", Eager(fn_countif))
  registry.register("COUNTIFS", Eager(fn_countifs))
  registry.register("AVERAGEIF", Eager(fn_averageif))
  registry.register("AVERAGEIFS", Eager(fn_averageifs))
}

///|
priv struct StatNumbers {
  values : Array[Double]
  error : FormulaError?
}

///|
priv struct Regression {
  slope : Double
  intercept : Double
  error : FormulaError?
}

///|
priv enum PercentileMode {
  Inclusive
  Exclusive
}

///|
priv enum CriteriaOp {
  CriteriaEq
  CriteriaNe
  CriteriaLt
  CriteriaLe
  CriteriaGt
  CriteriaGe
}

///|
priv struct Criterion {
  op : CriteriaOp
  value : FormulaValue
}

///|
/// §18.17.7.STDEV — compute sample standard deviation.
fn fn_stdev(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  variance_value(args, ctx, sample=true, sqrt_result=true)
}

///|
/// §18.17.7.STDEVP — compute population standard deviation.
fn fn_stdevp(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  variance_value(args, ctx, sample=false, sqrt_result=true)
}

///|
/// §18.17.7.VAR — compute sample variance.
fn fn_var(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  variance_value(args, ctx, sample=true, sqrt_result=false)
}

///|
/// §18.17.7.VARP — compute population variance.
fn fn_varp(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  variance_value(args, ctx, sample=false, sqrt_result=false)
}

///|
/// §18.17.7.MEDIAN — compute the middle numeric value.
fn fn_median(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_stat_numbers(args, ctx)
  match scan.error {
    Some(err) => VError(err)
    None =>
      if scan.values.length() == 0 {
        VError(Num)
      } else {
        let values = sorted_numbers(scan.values)
        let n = values.length()
        if n % 2 == 1 {
          VNumber(values[n / 2])
        } else {
          VNumber((values[n / 2 - 1] + values[n / 2]) / 2.0)
        }
      }
  }
}

///|
/// §18.17.7.MODE — return the most frequent numeric value.
fn fn_mode(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_stat_numbers(args, ctx)
  match scan.error {
    Some(err) => VError(err)
    None => {
      let values = sorted_numbers(scan.values)
      let mut best_count = 1
      let mut best = 0.0
      let mut run_count = 0
      let mut prev = 0.0
      for i in 0..<values.length() {
        if i == 0 || values[i] != prev {
          prev = values[i]
          run_count = 1
        } else {
          run_count += 1
          if run_count > best_count {
            best_count = run_count
            best = prev
          }
        }
      }
      if best_count < 2 {
        VError(NotApplicable)
      } else {
        VNumber(best)
      }
    }
  }
}

///|
/// §18.17.7.PERCENTILE.INC — interpolate the inclusive percentile.
fn fn_percentile_inc(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  percentile_function(args, ctx, Inclusive)
}

///|
/// §18.17.7.PERCENTILE.EXC — interpolate the exclusive percentile.
fn fn_percentile_exc(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  percentile_function(args, ctx, Exclusive)
}

///|
/// §18.17.7.QUARTILE.INC — return an inclusive quartile.
fn fn_quartile_inc(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  quartile_function(args, ctx, Inclusive)
}

///|
/// §18.17.7.QUARTILE.EXC — return an exclusive quartile.
fn fn_quartile_exc(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  quartile_function(args, ctx, Exclusive)
}

///|
/// §18.17.7.RANK.EQ — return the 1-based rank of a value.
fn fn_rank_eq(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  rank_function(args, ctx, average=false)
}

///|
/// §18.17.7.RANK.AVG — return the average 1-based rank for ties.
fn fn_rank_avg(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  rank_function(args, ctx, average=true)
}

///|
/// §18.17.7.LARGE — return the kth largest numeric value.
fn fn_large(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  kth_function(args, ctx, largest=true)
}

///|
/// §18.17.7.SMALL — return the kth smallest numeric value.
fn fn_small(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  kth_function(args, ctx, largest=false)
}

///|
/// §18.17.7.CORREL — compute the Pearson correlation coefficient.
fn fn_correl(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let pair = paired_numbers(args[0], args[1], ctx)
  match pair.error {
    Some(err) => VError(err)
    None => {
      let xs = pair.xs
      let ys = pair.ys
      if xs.length() < 2 {
        return VError(DivZero)
      }
      let xmean = mean(xs)
      let ymean = mean(ys)
      let mut num = 0.0
      let mut sx = 0.0
      let mut sy = 0.0
      for i in 0..<xs.length() {
        let dx = xs[i] - xmean
        let dy = ys[i] - ymean
        num += dx * dy
        sx += dx * dx
        sy += dy * dy
      }
      if sx == 0.0 || sy == 0.0 {
        VError(DivZero)
      } else {
        checked_number(num / (sx * sy).sqrt())
      }
    }
  }
}

///|
/// §18.17.7.COVAR — compute population covariance.
fn fn_covar(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  covariance_function(args, ctx, sample=false)
}

///|
/// §18.17.7.COVARIANCE.S — compute sample covariance.
fn fn_covariance_s(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  covariance_function(args, ctx, sample=true)
}

///|
/// §18.17.7.SLOPE — compute linear regression slope.
fn fn_slope(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  regression_function(args, ctx, want_intercept=false)
}

///|
/// §18.17.7.INTERCEPT — compute linear regression intercept.
fn fn_intercept(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  regression_function(args, ctx, want_intercept=true)
}

///|
/// §18.17.7.TREND — compute linear regression predictions.
fn fn_trend(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  trend_like(args, ctx, exponential=false)
}

///|
/// §18.17.7.FORECAST — predict a value from linear regression.
fn fn_forecast(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 {
    return VError(Value)
  }
  let x = scalar_number(args[0], ctx)
  let reg = regression_from_values(
    args[2],
    args[1],
    ctx,
    const_flag=true,
    exponential=false,
  )
  match (x, reg.error) {
    (VNumber(n), None) => checked_number(reg.slope * n + reg.intercept)
    (VError(err), _) | (_, Some(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.GROWTH — compute exponential regression predictions.
fn fn_growth(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  trend_like(args, ctx, exponential=true)
}

///|
/// §18.17.7.GEOMEAN — compute the geometric mean.
fn fn_geomean(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_stat_numbers(args, ctx)
  match scan.error {
    Some(err) => VError(err)
    None =>
      if scan.values.length() == 0 {
        VError(Num)
      } else {
        let mut total = 0.0
        for value in scan.values {
          if value <= 0.0 {
            return VError(Num)
          }
          total += @math.ln(value)
        }
        checked_number(@math.exp(total / scan.values.length().to_double()))
      }
  }
}

///|
/// §18.17.7.HARMEAN — compute the harmonic mean.
fn fn_harmean(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_stat_numbers(args, ctx)
  match scan.error {
    Some(err) => VError(err)
    None =>
      if scan.values.length() == 0 {
        VError(Num)
      } else {
        let mut denom = 0.0
        for value in scan.values {
          if value <= 0.0 {
            return VError(Num)
          }
          denom += 1.0 / value
        }
        checked_number(scan.values.length().to_double() / denom)
      }
  }
}

///|
/// §18.17.7.AVEDEV — compute average absolute deviation from the mean.
fn fn_avedev(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_stat_numbers(args, ctx)
  match scan.error {
    Some(err) => VError(err)
    None =>
      if scan.values.length() == 0 {
        VError(Num)
      } else {
        let avg = mean(scan.values)
        let mut total = 0.0
        for value in scan.values {
          total += (value - avg).abs()
        }
        checked_number(total / scan.values.length().to_double())
      }
  }
}

///|
/// §18.17.7.DEVSQ — compute sum of squared deviations from the mean.
fn fn_devsq(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  let scan = collect_stat_numbers(args, ctx)
  match scan.error {
    Some(err) => VError(err)
    None =>
      if scan.values.length() == 0 {
        VError(Num)
      } else {
        let avg = mean(scan.values)
        let mut total = 0.0
        for value in scan.values {
          total += (value - avg) * (value - avg)
        }
        checked_number(total)
      }
  }
}

///|
/// §18.17.7.SUMIF — sum values whose paired range values satisfy a criterion.
fn fn_sumif(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 && args.length() != 3 {
    return VError(Value)
  }
  let range = flatten_values(args[0])
  let sum_range = if args.length() == 3 {
    flatten_values(args[2])
  } else {
    range
  }
  let criterion = parse_criterion(args[1], ctx)
  match criterion {
    VError(err) => VError(err)
    _ => {
      let crit = criterion_to_record(criterion)
      conditional_total(range, sum_range, [crit], ctx, mode="sum")
    }
  }
}

///|
/// §18.17.7.SUMIFS — sum values matching all criteria ranges.
fn fn_sumifs(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  conditional_multi(args, ctx, mode="sum")
}

///|
/// §18.17.7.COUNTIF — count values satisfying a criterion.
fn fn_countif(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let range = flatten_values(args[0])
  let criterion = parse_criterion(args[1], ctx)
  match criterion {
    VError(err) => VError(err)
    _ =>
      conditional_total(
        range,
        range,
        [criterion_to_record(criterion)],
        ctx,
        mode="count",
      )
  }
}

///|
/// §18.17.7.COUNTIFS — count values matching all criteria ranges.
fn fn_countifs(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  conditional_multi(args, ctx, mode="count")
}

///|
/// §18.17.7.AVERAGEIF — average values whose paired range values satisfy a criterion.
fn fn_averageif(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 && args.length() != 3 {
    return VError(Value)
  }
  let range = flatten_values(args[0])
  let average_range = if args.length() == 3 {
    flatten_values(args[2])
  } else {
    range
  }
  let criterion = parse_criterion(args[1], ctx)
  match criterion {
    VError(err) => VError(err)
    _ =>
      conditional_total(
        range,
        average_range,
        [criterion_to_record(criterion)],
        ctx,
        mode="average",
      )
  }
}

///|
/// §18.17.7.AVERAGEIFS — average values matching all criteria ranges.
fn fn_averageifs(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  conditional_multi(args, ctx, mode="average")
}

///|
fn variance_value(
  args : Array[FormulaValue],
  ctx : EvalContext,
  sample~ : Bool,
  sqrt_result~ : Bool,
) -> FormulaValue {
  let scan = collect_stat_numbers(args, ctx)
  match scan.error {
    Some(err) => VError(err)
    None => {
      let n = scan.values.length()
      let denom = if sample { n - 1 } else { n }
      if denom <= 0 {
        return VError(DivZero)
      }
      let avg = mean(scan.values)
      let mut total = 0.0
      for value in scan.values {
        total += (value - avg) * (value - avg)
      }
      let variance = total / denom.to_double()
      checked_number(if sqrt_result { variance.sqrt() } else { variance })
    }
  }
}

///|
fn collect_stat_numbers(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> StatNumbers {
  let values = Array::new()
  for arg in args {
    match collect_stat_arg(arg, ctx, values) {
      Some(err) => return { values, error: Some(err) }
      None => ()
    }
  }
  { values, error: None }
}

///|
fn collect_stat_arg(
  value : FormulaValue,
  ctx : EvalContext,
  values : Array[Double],
) -> FormulaError? {
  match value {
    VArray(rows) =>
      for row in rows {
        for cell in row {
          match cell {
            VNumber(n) => values.push(n)
            VError(err) => return Some(err)
            _ => ()
          }
        }
      }
    VError(err) => return Some(err)
    VNumber(n) => values.push(n)
    VString(_) | VBool(_) | VEmpty =>
      match scalar_number(value, ctx) {
        VNumber(n) => values.push(n)
        VError(Value) => ()
        VError(err) => return Some(err)
        _ => ()
      }
  }
  None
}

///|
fn mean(values : Array[Double]) -> Double {
  let mut total = 0.0
  for value in values {
    total += value
  }
  total / values.length().to_double()
}

///|
fn sorted_numbers(values : Array[Double]) -> Array[Double] {
  let out = values.copy()
  for i in 1..<out.length() {
    let key = out[i]
    let mut j = i
    while j > 0 && out[j - 1] > key {
      out[j] = out[j - 1]
      j -= 1
    }
    out[j] = key
  }
  out
}

///|
fn percentile_function(
  args : Array[FormulaValue],
  ctx : EvalContext,
  mode : PercentileMode,
) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let values = collect_stat_numbers([args[0]], ctx)
  let k = scalar_number(args[1], ctx)
  match (values.error, k) {
    (Some(err), _) => VError(err)
    (None, VNumber(p)) => percentile_from_values(values.values, p, mode)
    (None, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
fn percentile_from_values(
  values : Array[Double],
  k : Double,
  mode : PercentileMode,
) -> FormulaValue {
  if values.length() == 0 {
    return VError(Num)
  }
  let sorted = sorted_numbers(values)
  let n = sorted.length()
  let rank = match mode {
    Inclusive =>
      if k < 0.0 || k > 1.0 {
        return VError(Num)
      } else {
        k * (n - 1).to_double()
      }
    Exclusive =>
      if k <= 0.0 || k >= 1.0 {
        return VError(Num)
      } else {
        k * (n + 1).to_double() - 1.0
      }
  }
  if rank < 0.0 || rank > (n - 1).to_double() {
    return VError(Num)
  }
  let lower = rank.floor().to_int()
  let upper = rank.ceil().to_int()
  if lower == upper {
    VNumber(sorted[lower])
  } else {
    let fraction = rank - lower.to_double()
    VNumber(sorted[lower] + (sorted[upper] - sorted[lower]) * fraction)
  }
}

///|
fn quartile_function(
  args : Array[FormulaValue],
  ctx : EvalContext,
  mode : PercentileMode,
) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let quart = scalar_number(args[1], ctx)
  match quart {
    VNumber(q) => {
      let qi = q.trunc().to_int()
      if q != qi.to_double() || qi < 0 || qi > 4 {
        VError(Num)
      } else {
        percentile_function([args[0], VNumber(qi.to_double() / 4.0)], ctx, mode)
      }
    }
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
fn rank_function(
  args : Array[FormulaValue],
  ctx : EvalContext,
  average~ : Bool,
) -> FormulaValue {
  if args.length() != 2 && args.length() != 3 {
    return VError(Value)
  }
  let number = scalar_number(args[0], ctx)
  let scan = collect_stat_numbers([args[1]], ctx)
  let order = if args.length() == 3 {
    scalar_number(args[2], ctx)
  } else {
    VNumber(0.0)
  }
  match (number, scan.error, order) {
    (VNumber(n), None, VNumber(o)) => {
      let mut better = 0
      let mut equal = 0
      for value in scan.values {
        if value == n {
          equal += 1
        } else if (o == 0.0 && value > n) || (o != 0.0 && value < n) {
          better += 1
        }
      }
      if equal == 0 {
        VError(NotApplicable)
      } else if average {
        VNumber(better.to_double() + 1.0 + (equal - 1).to_double() / 2.0)
      } else {
        VNumber((better + 1).to_double())
      }
    }
    (VError(err), _, _) | (_, Some(err), _) | (_, _, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
fn kth_function(
  args : Array[FormulaValue],
  ctx : EvalContext,
  largest~ : Bool,
) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let scan = collect_stat_numbers([args[0]], ctx)
  let k = scalar_number(args[1], ctx)
  match (scan.error, k) {
    (Some(err), _) => VError(err)
    (None, VNumber(kn)) => {
      let idx = kn.trunc().to_int()
      if kn != idx.to_double() || idx < 1 || idx > scan.values.length() {
        return VError(Num)
      }
      let sorted = sorted_numbers(scan.values)
      VNumber(
        if largest {
          sorted[sorted.length() - idx]
        } else {
          sorted[idx - 1]
        },
      )
    }
    (None, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
priv struct PairNumbers {
  xs : Array[Double]
  ys : Array[Double]
  error : FormulaError?
}

///|
fn paired_numbers(
  left : FormulaValue,
  right : FormulaValue,
  ctx : EvalContext,
) -> PairNumbers {
  let xs = collect_stat_numbers([left], ctx)
  let ys = collect_stat_numbers([right], ctx)
  match (xs.error, ys.error) {
    (Some(err), _) | (_, Some(err)) => { xs: [], ys: [], error: Some(err) }
    (None, None) =>
      if xs.values.length() != ys.values.length() || xs.values.length() == 0 {
        { xs: [], ys: [], error: Some(NotApplicable) }
      } else {
        { xs: xs.values, ys: ys.values, error: None }
      }
  }
}

///|
fn covariance_function(
  args : Array[FormulaValue],
  ctx : EvalContext,
  sample~ : Bool,
) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let pair = paired_numbers(args[0], args[1], ctx)
  match pair.error {
    Some(err) => VError(err)
    None => {
      let n = pair.xs.length()
      let denom = if sample { n - 1 } else { n }
      if denom <= 0 {
        return VError(DivZero)
      }
      let xmean = mean(pair.xs)
      let ymean = mean(pair.ys)
      let mut total = 0.0
      for i in 0..<n {
        total += (pair.xs[i] - xmean) * (pair.ys[i] - ymean)
      }
      checked_number(total / denom.to_double())
    }
  }
}

///|
fn regression_function(
  args : Array[FormulaValue],
  ctx : EvalContext,
  want_intercept~ : Bool,
) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let reg = regression_from_values(
    args[1],
    args[0],
    ctx,
    const_flag=true,
    exponential=false,
  )
  match reg.error {
    Some(err) => VError(err)
    None =>
      checked_number(if want_intercept { reg.intercept } else { reg.slope })
  }
}

///|
fn regression_from_values(
  xs_value : FormulaValue,
  ys_value : FormulaValue,
  ctx : EvalContext,
  const_flag~ : Bool,
  exponential~ : Bool,
) -> Regression {
  let pair = paired_numbers(xs_value, ys_value, ctx)
  match pair.error {
    Some(err) => { slope: 0.0, intercept: 0.0, error: Some(err) }
    None => {
      let xs = pair.xs
      let ys = Array::new(capacity=pair.ys.length())
      for y in pair.ys {
        if exponential {
          if y <= 0.0 {
            return { slope: 0.0, intercept: 0.0, error: Some(Num) }
          }
          ys.push(@math.ln(y))
        } else {
          ys.push(y)
        }
      }
      let xmean = mean(xs)
      let ymean = mean(ys)
      let mut sxx = 0.0
      let mut sxy = 0.0
      for i in 0..<xs.length() {
        sxx += (xs[i] - xmean) * (xs[i] - xmean)
        sxy += (xs[i] - xmean) * (ys[i] - ymean)
      }
      if sxx == 0.0 {
        return { slope: 0.0, intercept: 0.0, error: Some(DivZero) }
      }
      let slope = sxy / sxx
      let intercept = if const_flag { ymean - slope * xmean } else { 0.0 }
      if exponential {
        {
          slope: @math.exp(slope),
          intercept: @math.exp(intercept),
          error: None,
        }
      } else {
        { slope, intercept, error: None }
      }
    }
  }
}

///|
fn trend_like(
  args : Array[FormulaValue],
  ctx : EvalContext,
  exponential~ : Bool,
) -> FormulaValue {
  if args.length() < 1 || args.length() > 4 {
    return VError(Value)
  }
  let ys = args[0]
  let ycount = flatten_values(ys).length()
  let known_xs = if args.length() >= 2 {
    args[1]
  } else {
    sequence_array(ycount)
  }
  let new_xs = if args.length() >= 3 { args[2] } else { known_xs }
  let const_flag = if args.length() == 4 {
    match coerce_to_bool(args[3]) {
      VBool(b) => b
      VError(err) => return VError(err)
      _ => return VError(Value)
    }
  } else {
    true
  }
  let reg = regression_from_values(known_xs, ys, ctx, const_flag~, exponential~)
  match reg.error {
    Some(err) => VError(err)
    None => {
      let xs = collect_stat_numbers([new_xs], ctx)
      match xs.error {
        Some(err) => VError(err)
        None => {
          let out = Array::new()
          for x in xs.values {
            let y = if exponential {
              reg.intercept * @math.pow(reg.slope, x)
            } else {
              reg.slope * x + reg.intercept
            }
            out.push([VNumber(y)])
          }
          if out.length() == 1 {
            out[0][0]
          } else {
            VArray(out)
          }
        }
      }
    }
  }
}

///|
fn sequence_array(count : Int) -> FormulaValue {
  let out = Array::new()
  for i in 1..<=count {
    out.push([VNumber(i.to_double())])
  }
  VArray(out)
}

///|
fn flatten_values(value : FormulaValue) -> Array[FormulaValue] {
  let out = Array::new()
  match value {
    VArray(rows) =>
      for row in rows {
        for cell in row {
          out.push(cell)
        }
      }
    scalar => out.push(scalar)
  }
  out
}

///|
fn parse_criterion(value : FormulaValue, ctx : EvalContext) -> FormulaValue {
  match value.first_scalar() {
    VString(text) => {
      let s = text.trim().to_owned()
      let ops = [">=", "<=", "<>", ">", "<", "="]
      for op in ops {
        if string_has_prefix(s, op) {
          let body = s.unsafe_substring(start=op.length(), end=s.length())
          let parsed = parse_criterion_operand(body, ctx)
          return VArray([[VString(op), parsed]])
        }
      }
      VArray([[VString("="), parse_criterion_operand(s, ctx)]])
    }
    VError(err) => VError(err)
    other => VArray([[VString("="), other]])
  }
}

///|
fn parse_criterion_operand(text : String, ctx : EvalContext) -> FormulaValue {
  let number : Double = try @strconv.from_str(text.trim().to_owned()) catch {
    _ => return VString(text)
  } noraise {
    parsed => parsed
  }
  let _ = ctx
  if number.is_nan() || number.is_inf() {
    VString(text)
  } else {
    VNumber(number)
  }
}

///|
fn criterion_to_record(value : FormulaValue) -> Criterion {
  match value {
    VArray([[VString(op), operand]]) => {
      let parsed_op = match op {
        "<>" => CriteriaNe
        "<" => CriteriaLt
        "<=" => CriteriaLe
        ">" => CriteriaGt
        ">=" => CriteriaGe
        _ => CriteriaEq
      }
      { op: parsed_op, value: operand }
    }
    other => { op: CriteriaEq, value: other }
  }
}

///|
fn conditional_multi(
  args : Array[FormulaValue],
  ctx : EvalContext,
  mode~ : String,
) -> FormulaValue {
  if mode == "count" {
    if args.length() < 2 || args.length() % 2 != 0 {
      return VError(Value)
    }
  } else if args.length() < 3 || args.length() % 2 != 1 {
    return VError(Value)
  }
  let sum_range = if mode == "count" {
    flatten_values(args[0])
  } else {
    flatten_values(args[0])
  }
  let criteria = Array::new()
  let ranges = Array::new()
  let mut i = if mode == "count" { 0 } else { 1 }
  while i < args.length() {
    ranges.push(flatten_values(args[i]))
    let parsed = parse_criterion(args[i + 1], ctx)
    match parsed {
      VError(err) => return VError(err)
      _ => criteria.push(criterion_to_record(parsed))
    }
    i += 2
  }
  conditional_total_multi(sum_range, ranges, criteria, ctx, mode)
}

///|
fn conditional_total(
  range : Array[FormulaValue],
  sum_range : Array[FormulaValue],
  criteria : Array[Criterion],
  ctx : EvalContext,
  mode~ : String,
) -> FormulaValue {
  conditional_total_multi(sum_range, [range], criteria, ctx, mode)
}

///|
fn conditional_total_multi(
  sum_range : Array[FormulaValue],
  ranges : Array[Array[FormulaValue]],
  criteria : Array[Criterion],
  ctx : EvalContext,
  mode : String,
) -> FormulaValue {
  let count = sum_range.length()
  for range in ranges {
    if range.length() != count {
      return VError(Value)
    }
  }
  let mut total = 0.0
  let mut matched = 0
  for i in 0..<count {
    let mut ok = true
    for j in 0..<ranges.length() {
      if !criterion_matches(ranges[j][i], criteria[j], ctx) {
        ok = false
      }
    }
    if ok {
      matched += 1
      if mode != "count" {
        match scalar_number(sum_range[i], ctx) {
          VNumber(n) => total += n
          VError(err) => return VError(err)
          _ => ()
        }
      }
    }
  }
  if mode == "count" {
    VNumber(matched.to_double())
  } else if mode == "average" {
    if matched == 0 {
      VError(DivZero)
    } else {
      checked_number(total / matched.to_double())
    }
  } else {
    checked_number(total)
  }
}

///|
fn criterion_matches(
  value : FormulaValue,
  criterion : Criterion,
  ctx : EvalContext,
) -> Bool {
  let left = match criterion.value {
    VNumber(_) => scalar_number(value, ctx)
    _ => value.first_scalar()
  }
  match (left, criterion.value) {
    (VError(_), _) => false
    (VNumber(a), VNumber(b)) => compare_by_op(a.compare(b), criterion.op)
    (VString(a), VString(b)) => compare_by_op(a.compare(b), criterion.op)
    (VBool(a), VBool(b)) => compare_by_op(a.compare(b), criterion.op)
    (VEmpty, VString(b)) => compare_by_op("".compare(b), criterion.op)
    (VEmpty, VNumber(b)) => compare_by_op(0.0.compare(b), criterion.op)
    _ => false
  }
}

///|
fn compare_by_op(cmp : Int, op : CriteriaOp) -> Bool {
  match op {
    CriteriaEq => cmp == 0
    CriteriaNe => cmp != 0
    CriteriaLt => cmp < 0
    CriteriaLe => cmp <= 0
    CriteriaGt => cmp > 0
    CriteriaGe => cmp >= 0
  }
}

///|
fn string_has_prefix(value : String, prefix : String) -> Bool {
  value.length() >= prefix.length() &&
  value.unsafe_substring(start=0, end=prefix.length()) == prefix
}
