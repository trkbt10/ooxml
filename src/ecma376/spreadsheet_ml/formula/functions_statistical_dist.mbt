///|
fn register_builtin_statistical_dist_functions(
  registry : FunctionRegistry,
) -> Unit {
  registry.register("NORMDIST", Eager(fn_normdist))
  registry.register("NORMINV", Eager(fn_norminv))
  registry.register("NORMSDIST", Eager(fn_normsdist))
  registry.register("NORMSINV", Eager(fn_normsinv))
  registry.register("BETADIST", Eager(fn_betadist))
  registry.register("BETAINV", Eager(fn_betainv))
  registry.register("BINOMDIST", Eager(fn_binomdist))
  registry.register("NEGBINOMDIST", Eager(fn_negbinomdist))
  registry.register("CHIDIST", Eager(fn_chidist))
  registry.register("CHIINV", Eager(fn_chiinv))
  registry.register("CHITEST", Eager(fn_chitest))
  registry.register("CONFIDENCE", Eager(fn_confidence))
  registry.register("CRITBINOM", Eager(fn_critbinom))
  registry.register("EXPONDIST", Eager(fn_expondist))
  registry.register("FDIST", Eager(fn_fdist))
  registry.register("FINV", Eager(fn_finv))
  registry.register("FTEST", Eager(fn_ftest))
  registry.register("GAMMADIST", Eager(fn_gammadist))
  registry.register("GAMMAINV", Eager(fn_gammainv))
  registry.register("GAMMALN", Eager(fn_gammaln))
  registry.register("HYPGEOMDIST", Eager(fn_hypgeomdist))
  registry.register("LOGINV", Eager(fn_loginv))
  registry.register("LOGNORMDIST", Eager(fn_lognormdist))
  registry.register("POISSON", Eager(fn_poisson))
  registry.register("TDIST", Eager(fn_tdist))
  registry.register("TINV", Eager(fn_tinv))
  registry.register("WEIBULL", Eager(fn_weibull))
  registry.register("ZTEST", Eager(fn_ztest))
  registry.register("FISHER", Eager(fn_fisher))
  registry.register("FISHERINV", Eager(fn_fisherinv))
  registry.register("STANDARDIZE", Eager(fn_standardize))
  registry.register("PERCENTRANK", Eager(fn_percentrank))
  registry.register("KURT", Eager(fn_kurt))
  registry.register("SKEW", Eager(fn_skew))
  registry.register("TRIMMEAN", Eager(fn_trimmean))
  registry.register("PROB", Eager(fn_prob))
  registry.register("AVERAGEA", Eager(fn_averagea))
  registry.register("MAXA", Eager(fn_maxa))
  registry.register("MINA", Eager(fn_mina))
  registry.register("STDEVA", Eager(fn_stdeva))
  registry.register("STDEVPA", Eager(fn_stdevpa))
  registry.register("VARA", Eager(fn_vara))
  registry.register("VARPA", Eager(fn_varpa))
  registry.register("PEARSON", Eager(fn_pearson))
  registry.register("RSQ", Eager(fn_rsq))
  registry.register("STEYX", Eager(fn_steyx))
  registry.register("TTEST", Eager(fn_ttest))
  registry.register("FREQUENCY", Eager(fn_frequency))
  registry.register("ERROR.TYPE", Eager(fn_error_type))
  registry.register("ISEVEN", Eager(fn_iseven))
  registry.register("ISODD", Eager(fn_isodd))
  registry.register("ISNONTEXT", Eager(fn_isnontext))
  registry.register("LINEST", Eager(fn_linest))
  registry.register("LOGEST", Eager(fn_logest))
}

fn stat_dist_numbers(
  args : Array[FormulaValue],
  ctx : EvalContext,
  count : Int,
) -> Array[Double]? {
  if args.length() != count {
    return None
  }
  let out : Array[Double] = []
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => out.push(n)
      _ => return None
    }
  }
  Some(out)
}

fn fn_normdist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 4 { return VError(Value) }
  let first3 : Array[FormulaValue] = [args[0], args[1], args[2]]
  match stat_dist_numbers(first3, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let (x, mean, sd) = (ns[0], ns[1], ns[2])
      if sd <= 0.0 { return VError(Num) }
      let cumul = match args[3].first_scalar() {
        VBool(b) => b
        VNumber(n) => n != 0.0
        _ => return VError(Value)
      }
      if cumul {
        VNumber(norm_cdf((x - mean) / sd))
      } else {
        let z = (x - mean) / sd
        checked_number(
          @math.exp(-0.5 * z * z) / (sd * (2.0 * trig_pi).sqrt()),
        )
      }
    }
  }
}

fn fn_norminv(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let (p, mean, sd) = (ns[0], ns[1], ns[2])
      if p <= 0.0 || p >= 1.0 || sd <= 0.0 { return VError(Num) }
      VNumber(mean + sd * norm_inv(p))
    }
  }
}

fn fn_normsdist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(z) => VNumber(norm_cdf(z))
    other => other
  }
}

fn fn_normsinv(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(p) =>
      if p <= 0.0 || p >= 1.0 { VError(Num) } else { VNumber(norm_inv(p)) }
    other => other
  }
}

fn fn_betadist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() < 3 || args.length() > 5 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let x = nums[0]
  let alpha = nums[1]
  let beta_p = nums[2]
  let a = if nums.length() > 3 { nums[3] } else { 0.0 }
  let b = if nums.length() > 4 { nums[4] } else { 1.0 }
  if alpha <= 0.0 || beta_p <= 0.0 || x < a || x > b || a == b {
    return VError(Num)
  }
  VNumber(beta_regularized((x - a) / (b - a), alpha, beta_p))
}

fn fn_betainv(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() < 3 || args.length() > 5 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let prob = nums[0]
  let alpha = nums[1]
  let beta_p = nums[2]
  let a = if nums.length() > 3 { nums[3] } else { 0.0 }
  let b = if nums.length() > 4 { nums[4] } else { 1.0 }
  if prob <= 0.0 || prob >= 1.0 || alpha <= 0.0 || beta_p <= 0.0 {
    return VError(Num)
  }
  let mut lo = 0.0
  let mut hi = 1.0
  for _i in 0..<100 {
    let mid = (lo + hi) / 2.0
    if beta_regularized(mid, alpha, beta_p) < prob {
      lo = mid
    } else {
      hi = mid
    }
  }
  VNumber(a + (lo + hi) / 2.0 * (b - a))
}

fn fn_binomdist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 4 { return VError(Value) }
  let nums : Array[Double] = []
  for i in 0..<3 {
    match coerce_to_number(args[i].first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let cumul = match args[3].first_scalar() {
    VBool(b) => b
    VNumber(n) => n != 0.0
    _ => return VError(Value)
  }
  let k = nums[0].trunc().to_int()
  let n = nums[1].trunc().to_int()
  let p = nums[2]
  if k < 0 || n < 0 || k > n || p < 0.0 || p > 1.0 { return VError(Num) }
  if cumul {
    VNumber(binom_cdf(k, n, p))
  } else {
    VNumber(binom_pmf(k, n, p))
  }
}

fn fn_negbinomdist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let f = ns[0].trunc().to_int()
      let s = ns[1].trunc().to_int()
      let p = ns[2]
      if f < 0 || s < 1 || p <= 0.0 || p >= 1.0 { return VError(Num) }
      let n = f + s - 1
      checked_number(
        combin_int(n, s - 1) * @math.pow(p, s.to_double()) *
          @math.pow(1.0 - p, f.to_double()),
      )
    }
  }
}

fn fn_chidist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 2) {
    None => VError(Value)
    Some(ns) => {
      if ns[0] < 0.0 || ns[1] < 1.0 { return VError(Num) }
      VNumber(1.0 - chi2_cdf(ns[0], ns[1].trunc()))
    }
  }
}

fn fn_chiinv(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 2) {
    None => VError(Value)
    Some(ns) => {
      let (p, df) = (ns[0], ns[1].trunc())
      if p < 0.0 || p > 1.0 || df < 1.0 { return VError(Num) }
      let mut lo = 0.0
      let mut hi = 1000.0
      for _i in 0..<100 {
        let mid = (lo + hi) / 2.0
        if 1.0 - chi2_cdf(mid, df) > p { lo = mid } else { hi = mid }
      }
      VNumber((lo + hi) / 2.0)
    }
  }
}

fn fn_chitest(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 2 { return VError(Value) }
  let obs = extract_number_array(args[0], ctx.date_system)
  let exp = extract_number_array(args[1], ctx.date_system)
  if obs.length() != exp.length() || obs.length() == 0 { return VError(NotApplicable) }
  let mut chi2 = 0.0
  for i in 0..<obs.length() {
    if exp[i] == 0.0 { return VError(DivZero) }
    let d = obs[i] - exp[i]
    chi2 = chi2 + d * d / exp[i]
  }
  let df = (obs.length() - 1).to_double().max(1.0)
  VNumber(1.0 - chi2_cdf(chi2, df))
}

fn fn_confidence(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let (alpha, sd, n) = (ns[0], ns[1], ns[2].trunc())
      if alpha <= 0.0 || alpha >= 1.0 || sd <= 0.0 || n < 1.0 {
        return VError(Num)
      }
      VNumber(norm_inv(1.0 - alpha / 2.0) * sd / n.sqrt())
    }
  }
}

fn fn_critbinom(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let n = ns[0].trunc().to_int()
      let p = ns[1]
      let alpha = ns[2]
      if n < 0 || p < 0.0 || p > 1.0 || alpha < 0.0 || alpha > 1.0 {
        return VError(Num)
      }
      let mut cum = 0.0
      for k in 0..=n {
        cum = cum + binom_pmf(k, n, p)
        if cum >= alpha {
          return VNumber(k.to_double())
        }
      }
      VNumber(n.to_double())
    }
  }
}

fn fn_expondist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 3 { return VError(Value) }
  let nums : Array[Double] = []
  for i in 0..<2 {
    match coerce_to_number(args[i].first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let cumul = match args[2].first_scalar() {
    VBool(b) => b
    VNumber(n) => n != 0.0
    _ => return VError(Value)
  }
  let (x, lambda) = (nums[0], nums[1])
  if x < 0.0 || lambda <= 0.0 { return VError(Num) }
  if cumul {
    VNumber(1.0 - @math.exp(-lambda * x))
  } else {
    checked_number(lambda * @math.exp(-lambda * x))
  }
}

fn fn_fdist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      if ns[0] < 0.0 || ns[1] < 1.0 || ns[2] < 1.0 { return VError(Num) }
      VNumber(1.0 - f_cdf(ns[0], ns[1].trunc(), ns[2].trunc()))
    }
  }
}

fn fn_finv(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let (p, df1, df2) = (ns[0], ns[1].trunc(), ns[2].trunc())
      if p < 0.0 || p > 1.0 || df1 < 1.0 || df2 < 1.0 { return VError(Num) }
      let mut lo = 0.0
      let mut hi = 1000.0
      for _i in 0..<100 {
        let mid = (lo + hi) / 2.0
        if 1.0 - f_cdf(mid, df1, df2) > p { lo = mid } else { hi = mid }
      }
      VNumber((lo + hi) / 2.0)
    }
  }
}

fn fn_ftest(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 2 { return VError(Value) }
  let a1 = extract_number_array(args[0], ctx.date_system)
  let a2 = extract_number_array(args[1], ctx.date_system)
  if a1.length() < 2 || a2.length() < 2 { return VError(DivZero) }
  let var1 = sample_variance(a1)
  let var2 = sample_variance(a2)
  if var1 == 0.0 || var2 == 0.0 { return VError(DivZero) }
  let f_val = var1 / var2
  let df1 = (a1.length() - 1).to_double()
  let df2 = (a2.length() - 1).to_double()
  let p = if f_val >= 1.0 {
    1.0 - f_cdf(f_val, df1, df2)
  } else {
    1.0 - f_cdf(1.0 / f_val, df2, df1)
  }
  VNumber(2.0 * p.min(1.0))
}

fn sample_variance(arr : Array[Double]) -> Double {
  let n = arr.length().to_double()
  let mut sum = 0.0
  for v in arr { sum = sum + v }
  let mean = sum / n
  let mut ss = 0.0
  for v in arr {
    let d = v - mean
    ss = ss + d * d
  }
  ss / (n - 1.0)
}

fn fn_gammadist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 4 { return VError(Value) }
  let nums : Array[Double] = []
  for i in 0..<3 {
    match coerce_to_number(args[i].first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let cumul = match args[3].first_scalar() {
    VBool(b) => b
    VNumber(n) => n != 0.0
    _ => return VError(Value)
  }
  let (x, alpha, beta_p) = (nums[0], nums[1], nums[2])
  if x < 0.0 || alpha <= 0.0 || beta_p <= 0.0 { return VError(Num) }
  if cumul {
    VNumber(lower_gamma_regularized(alpha, x / beta_p))
  } else {
    checked_number(
      @math.exp(
        (alpha - 1.0) * @math.ln(x) - x / beta_p - alpha * @math.ln(beta_p) -
          gamma_ln(alpha),
      ),
    )
  }
}

fn fn_gammainv(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let (p, alpha, beta_p) = (ns[0], ns[1], ns[2])
      if p < 0.0 || p >= 1.0 || alpha <= 0.0 || beta_p <= 0.0 {
        return VError(Num)
      }
      let mut lo = 0.0
      let mut hi = alpha * beta_p * 100.0
      for _i in 0..<200 {
        let mid = (lo + hi) / 2.0
        if lower_gamma_regularized(alpha, mid / beta_p) < p {
          lo = mid
        } else {
          hi = mid
        }
      }
      VNumber((lo + hi) / 2.0)
    }
  }
}

fn fn_gammaln(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) =>
      if n <= 0.0 { VError(Num) } else { checked_number(gamma_ln(n)) }
    other => other
  }
}

fn fn_hypgeomdist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 4) {
    None => VError(Value)
    Some(ns) => {
      let (s, n_s, pop_s, pop_n) = (
        ns[0].trunc().to_int(),
        ns[1].trunc().to_int(),
        ns[2].trunc().to_int(),
        ns[3].trunc().to_int(),
      )
      if s < 0 || n_s < 0 || pop_s < 0 || pop_n < 0 || s > n_s ||
        s > pop_s ||
        n_s > pop_n ||
        pop_s > pop_n {
        return VError(Num)
      }
      checked_number(
        combin_int(pop_s, s) * combin_int(pop_n - pop_s, n_s - s) / combin_int(
          pop_n, n_s,
        ),
      )
    }
  }
}

fn fn_loginv(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let (p, mean, sd) = (ns[0], ns[1], ns[2])
      if p <= 0.0 || p >= 1.0 || sd <= 0.0 { return VError(Num) }
      checked_number(@math.exp(mean + sd * norm_inv(p)))
    }
  }
}

fn fn_lognormdist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let (x, mean, sd) = (ns[0], ns[1], ns[2])
      if x <= 0.0 || sd <= 0.0 { return VError(Num) }
      VNumber(norm_cdf((@math.ln(x) - mean) / sd))
    }
  }
}

fn fn_poisson(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 3 { return VError(Value) }
  let nums : Array[Double] = []
  for i in 0..<2 {
    match coerce_to_number(args[i].first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let cumul = match args[2].first_scalar() {
    VBool(b) => b
    VNumber(n) => n != 0.0
    _ => return VError(Value)
  }
  let (x, mean) = (nums[0].trunc().to_int(), nums[1])
  if x < 0 || mean < 0.0 { return VError(Num) }
  if cumul {
    VNumber(poisson_cdf(x, mean))
  } else {
    VNumber(poisson_pmf(x, mean))
  }
}

fn fn_tdist(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let (x, df, tails) = (ns[0], ns[1].trunc(), ns[2].trunc().to_int())
      if x < 0.0 || df < 1.0 || (tails != 1 && tails != 2) {
        return VError(Num)
      }
      let p = 1.0 - t_cdf(x, df)
      VNumber(p * tails.to_double())
    }
  }
}

fn fn_tinv(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 2) {
    None => VError(Value)
    Some(ns) => {
      let (p, df) = (ns[0], ns[1].trunc())
      if p <= 0.0 || p > 1.0 || df < 1.0 { return VError(Num) }
      let target = 1.0 - p / 2.0
      let mut lo = 0.0
      let mut hi = 1000.0
      for _i in 0..<100 {
        let mid = (lo + hi) / 2.0
        if t_cdf(mid, df) < target { lo = mid } else { hi = mid }
      }
      VNumber((lo + hi) / 2.0)
    }
  }
}

fn fn_weibull(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 4 { return VError(Value) }
  let nums : Array[Double] = []
  for i in 0..<3 {
    match coerce_to_number(args[i].first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let cumul = match args[3].first_scalar() {
    VBool(b) => b
    VNumber(n) => n != 0.0
    _ => return VError(Value)
  }
  let (x, alpha, beta_p) = (nums[0], nums[1], nums[2])
  if x < 0.0 || alpha <= 0.0 || beta_p <= 0.0 { return VError(Num) }
  if cumul {
    VNumber(1.0 - @math.exp(-@math.pow(x / beta_p, alpha)))
  } else {
    checked_number(
      alpha / @math.pow(beta_p, alpha) *
        @math.pow(x, alpha - 1.0) *
        @math.exp(-@math.pow(x / beta_p, alpha)),
    )
  }
}

fn fn_ztest(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() < 2 || args.length() > 3 { return VError(Value) }
  let data = extract_number_array(args[0], ctx.date_system)
  if data.length() == 0 { return VError(NotApplicable) }
  let mu = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  let sigma = if args.length() == 3 {
    match coerce_to_number(args[2].first_scalar(), ctx.date_system) {
      VNumber(n) => n
      _ => return VError(Value)
    }
  } else {
    sample_variance(data).sqrt()
  }
  if sigma <= 0.0 { return VError(DivZero) }
  let mut sum = 0.0
  for v in data { sum = sum + v }
  let mean = sum / data.length().to_double()
  let z = (mean - mu) / (sigma / data.length().to_double().sqrt())
  VNumber(1.0 - norm_cdf(z))
}

fn fn_fisher(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(x) =>
      if x <= -1.0 || x >= 1.0 {
        VError(Num)
      } else {
        VNumber(0.5 * @math.ln((1.0 + x) / (1.0 - x)))
      }
    other => other
  }
}

fn fn_fisherinv(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(y) => {
      let e2y = @math.exp(2.0 * y)
      VNumber((e2y - 1.0) / (e2y + 1.0))
    }
    other => other
  }
}

fn fn_standardize(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      if ns[2] <= 0.0 { return VError(Num) }
      VNumber((ns[0] - ns[1]) / ns[2])
    }
  }
}

fn fn_percentrank(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() < 2 || args.length() > 3 { return VError(Value) }
  let data = extract_number_array(args[0], ctx.date_system)
  let x = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  if data.length() == 0 { return VError(NotApplicable) }
  let sorted = data.copy()
  sorted.sort_by(fn(a, b) { a.compare(b) })
  let mut below = 0
  let mut equal = 0
  for v in sorted {
    if v < x { below = below + 1 } else if v == x { equal = equal + 1 }
  }
  if equal == 0 {
    if x < sorted[0] || x > sorted[sorted.length() - 1] {
      return VError(NotApplicable)
    }
    let mut lo_idx = 0
    for i in 0..<sorted.length() {
      if sorted[i] < x { lo_idx = i }
    }
    let lo_val = sorted[lo_idx]
    let hi_val = sorted[lo_idx + 1]
    let frac = (x - lo_val) / (hi_val - lo_val)
    let rank = (lo_idx.to_double() + frac) / (sorted.length() - 1).to_double()
    VNumber(rank)
  } else {
    VNumber(below.to_double() / (sorted.length() - 1).to_double())
  }
}

fn fn_kurt(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let data : Array[Double] = []
  for arg in args {
    for v in extract_number_array(arg, ctx.date_system) {
      data.push(v)
    }
  }
  let n = data.length()
  if n < 4 { return VError(DivZero) }
  let nf = n.to_double()
  let mut sum = 0.0
  for v in data { sum = sum + v }
  let mean = sum / nf
  let mut m2 = 0.0
  let mut m4 = 0.0
  for v in data {
    let d = v - mean
    m2 = m2 + d * d
    m4 = m4 + d * d * d * d
  }
  let s2 = m2 / (nf - 1.0)
  if s2 == 0.0 { return VError(DivZero) }
  let adj = nf * (nf + 1.0) / ((nf - 1.0) * (nf - 2.0) * (nf - 3.0))
  let sub = 3.0 * (nf - 1.0) * (nf - 1.0) / ((nf - 2.0) * (nf - 3.0))
  VNumber(adj * m4 / (s2 * s2) - sub)
}

fn fn_skew(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let data : Array[Double] = []
  for arg in args {
    for v in extract_number_array(arg, ctx.date_system) {
      data.push(v)
    }
  }
  let n = data.length()
  if n < 3 { return VError(DivZero) }
  let nf = n.to_double()
  let mut sum = 0.0
  for v in data { sum = sum + v }
  let mean = sum / nf
  let mut m2 = 0.0
  let mut m3 = 0.0
  for v in data {
    let d = v - mean
    m2 = m2 + d * d
    m3 = m3 + d * d * d
  }
  let sd = (m2 / (nf - 1.0)).sqrt()
  if sd == 0.0 { return VError(DivZero) }
  VNumber(nf / ((nf - 1.0) * (nf - 2.0)) * m3 / (sd * sd * sd))
}

fn fn_trimmean(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 2 { return VError(Value) }
  let data = extract_number_array(args[0], ctx.date_system)
  let pct = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  if pct < 0.0 || pct >= 1.0 || data.length() == 0 { return VError(Num) }
  let sorted = data.copy()
  sorted.sort_by(fn(a, b) { a.compare(b) })
  let trim = (sorted.length().to_double() * pct / 2.0).floor().to_int()
  let mut sum = 0.0
  let mut count = 0
  for i in trim..<(sorted.length() - trim) {
    sum = sum + sorted[i]
    count = count + 1
  }
  if count == 0 { VError(Num) } else { VNumber(sum / count.to_double()) }
}

fn fn_prob(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() < 3 || args.length() > 4 { return VError(Value) }
  let x_range = extract_number_array(args[0], ctx.date_system)
  let p_range = extract_number_array(args[1], ctx.date_system)
  if x_range.length() != p_range.length() || x_range.length() == 0 {
    return VError(NotApplicable)
  }
  let lo = match coerce_to_number(args[2].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  let hi = if args.length() == 4 {
    match coerce_to_number(args[3].first_scalar(), ctx.date_system) {
      VNumber(n) => n
      _ => return VError(Value)
    }
  } else {
    lo
  }
  let mut total = 0.0
  for i in 0..<x_range.length() {
    if x_range[i] >= lo && x_range[i] <= hi {
      total = total + p_range[i]
    }
  }
  VNumber(total)
}

// ---------------------------------------------------------------------------
// A-variant aggregate functions (include booleans/text in aggregation)
// ---------------------------------------------------------------------------

fn coerce_a_value(v : FormulaValue) -> Double? {
  match v {
    VNumber(n) => Some(n)
    VBool(b) => Some(if b { 1.0 } else { 0.0 })
    VString(_) => Some(0.0)
    _ => None
  }
}

fn fn_averagea(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let mut sum = 0.0
  let mut count = 0
  for arg in args {
    match coerce_a_value(arg.first_scalar()) {
      Some(n) => { sum = sum + n; count = count + 1 }
      None =>
        match arg.first_scalar() {
          VError(e) => return VError(e)
          _ => ()
        }
    }
  }
  if count == 0 { VError(DivZero) } else { VNumber(sum / count.to_double()) }
}

fn fn_maxa(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let mut result = -1.0 / 0.0
  let mut any = false
  for arg in args {
    match coerce_a_value(arg.first_scalar()) {
      Some(n) => { if n > result { result = n }; any = true }
      None =>
        match arg.first_scalar() {
          VError(e) => return VError(e)
          _ => ()
        }
    }
  }
  if any { VNumber(result) } else { VNumber(0.0) }
}

fn fn_mina(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  let mut result = 1.0 / 0.0
  let mut any = false
  for arg in args {
    match coerce_a_value(arg.first_scalar()) {
      Some(n) => { if n < result { result = n }; any = true }
      None =>
        match arg.first_scalar() {
          VError(e) => return VError(e)
          _ => ()
        }
    }
  }
  if any { VNumber(result) } else { VNumber(0.0) }
}

fn a_variant_stats(
  args : Array[FormulaValue],
) -> (Array[Double], FormulaError?) {
  let data : Array[Double] = []
  for arg in args {
    match arg.first_scalar() {
      VNumber(n) => data.push(n)
      VBool(b) => data.push(if b { 1.0 } else { 0.0 })
      VString(_) => data.push(0.0)
      VError(e) => return (data, Some(e))
      _ => ()
    }
  }
  (data, None)
}

fn fn_stdeva(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  let (data, err) = a_variant_stats(args)
  match err {
    Some(e) => return VError(e)
    None => ()
  }
  if data.length() < 2 { return VError(DivZero) }
  VNumber(sample_variance(data).sqrt())
}

fn fn_stdevpa(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  let (data, err) = a_variant_stats(args)
  match err {
    Some(e) => return VError(e)
    None => ()
  }
  if data.length() < 1 { return VError(DivZero) }
  let n = data.length().to_double()
  let mut sum = 0.0
  for v in data { sum = sum + v }
  let mean = sum / n
  let mut ss = 0.0
  for v in data { let d = v - mean; ss = ss + d * d }
  VNumber((ss / n).sqrt())
}

fn fn_vara(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  let (data, err) = a_variant_stats(args)
  match err {
    Some(e) => return VError(e)
    None => ()
  }
  if data.length() < 2 { return VError(DivZero) }
  VNumber(sample_variance(data))
}

fn fn_varpa(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  let (data, err) = a_variant_stats(args)
  match err {
    Some(e) => return VError(e)
    None => ()
  }
  if data.length() < 1 { return VError(DivZero) }
  let n = data.length().to_double()
  let mut sum = 0.0
  for v in data { sum = sum + v }
  let mean = sum / n
  let mut ss = 0.0
  for v in data { let d = v - mean; ss = ss + d * d }
  VNumber(ss / n)
}

fn fn_pearson(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 2 { return VError(Value) }
  let xs = extract_number_array(args[0], ctx.date_system)
  let ys = extract_number_array(args[1], ctx.date_system)
  let n = if xs.length() < ys.length() { xs.length() } else { ys.length() }
  if n < 1 { return VError(NotApplicable) }
  let mut sx = 0.0
  let mut sy = 0.0
  for i in 0..<n { sx = sx + xs[i]; sy = sy + ys[i] }
  let mx = sx / n.to_double()
  let my = sy / n.to_double()
  let mut sxy = 0.0
  let mut sxx = 0.0
  let mut syy = 0.0
  for i in 0..<n {
    let dx = xs[i] - mx
    let dy = ys[i] - my
    sxy = sxy + dx * dy
    sxx = sxx + dx * dx
    syy = syy + dy * dy
  }
  if sxx == 0.0 || syy == 0.0 { return VError(DivZero) }
  VNumber(sxy / (sxx * syy).sqrt())
}

fn fn_rsq(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match fn_pearson(args, ctx) {
    VNumber(r) => VNumber(r * r)
    other => other
  }
}

fn fn_steyx(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 2 { return VError(Value) }
  let ys = extract_number_array(args[0], ctx.date_system)
  let xs = extract_number_array(args[1], ctx.date_system)
  let n = if xs.length() < ys.length() { xs.length() } else { ys.length() }
  if n < 3 { return VError(DivZero) }
  let mut sx = 0.0
  let mut sy = 0.0
  for i in 0..<n { sx = sx + xs[i]; sy = sy + ys[i] }
  let mx = sx / n.to_double()
  let my = sy / n.to_double()
  let mut sxy = 0.0
  let mut sxx = 0.0
  let mut syy = 0.0
  for i in 0..<n {
    let dx = xs[i] - mx
    let dy = ys[i] - my
    sxy = sxy + dx * dy
    sxx = sxx + dx * dx
    syy = syy + dy * dy
  }
  if sxx == 0.0 { return VError(DivZero) }
  let b = sxy / sxx
  let sse = syy - b * sxy
  checked_number((sse / (n - 2).to_double()).sqrt())
}

fn fn_ttest(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 4 { return VError(Value) }
  let a1 = extract_number_array(args[0], ctx.date_system)
  let a2 = extract_number_array(args[1], ctx.date_system)
  let tails = match coerce_to_number(args[2].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc().to_int()
    _ => return VError(Value)
  }
  let ttype = match coerce_to_number(args[3].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc().to_int()
    _ => return VError(Value)
  }
  if (tails != 1 && tails != 2) || ttype < 1 || ttype > 3 {
    return VError(Num)
  }
  if a1.length() < 2 || a2.length() < 2 { return VError(NotApplicable) }
  let n1 = a1.length().to_double()
  let n2 = a2.length().to_double()
  let mut s1 = 0.0
  let mut s2 = 0.0
  for v in a1 { s1 = s1 + v }
  for v in a2 { s2 = s2 + v }
  let m1 = s1 / n1
  let m2 = s2 / n2
  let v1 = sample_variance(a1)
  let v2 = sample_variance(a2)
  let (t_stat, df) = match ttype {
    1 => {
      if a1.length() != a2.length() { return VError(NotApplicable) }
      let diffs : Array[Double] = []
      for i in 0..<a1.length() { diffs.push(a1[i] - a2[i]) }
      let vd = sample_variance(diffs)
      let md = m1 - m2
      let t = md / (vd / n1).sqrt()
      (t, n1 - 1.0)
    }
    2 => {
      let sp = ((n1 - 1.0) * v1 + (n2 - 1.0) * v2) / (n1 + n2 - 2.0)
      let t = (m1 - m2) / (sp * (1.0 / n1 + 1.0 / n2)).sqrt()
      (t, n1 + n2 - 2.0)
    }
    _ => {
      let se = (v1 / n1 + v2 / n2).sqrt()
      if se == 0.0 { return VError(DivZero) }
      let t = (m1 - m2) / se
      let num = (v1 / n1 + v2 / n2) * (v1 / n1 + v2 / n2)
      let den = v1 * v1 / (n1 * n1 * (n1 - 1.0)) +
        v2 * v2 / (n2 * n2 * (n2 - 1.0))
      (t, num / den)
    }
  }
  let p = 1.0 - t_cdf(t_stat.abs(), df)
  VNumber(p * tails.to_double())
}

fn fn_frequency(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 2 { return VError(Value) }
  let data = extract_number_array(args[0], ctx.date_system)
  let bins = extract_number_array(args[1], ctx.date_system)
  let sorted_bins = bins.copy()
  sorted_bins.sort_by(fn(a, b) { a.compare(b) })
  let counts : Array[FormulaValue] = Array::make(bins.length() + 1, VNumber(0.0))
  for v in data {
    let mut placed = false
    for i in 0..<sorted_bins.length() {
      if v <= sorted_bins[i] {
        match counts[i] {
          VNumber(c) => counts[i] = VNumber(c + 1.0)
          _ => ()
        }
        placed = true
        break
      }
    }
    if !placed {
      let last = sorted_bins.length()
      match counts[last] {
        VNumber(c) => counts[last] = VNumber(c + 1.0)
        _ => ()
      }
    }
  }
  let rows : Array[Array[FormulaValue]] = []
  for c in counts {
    rows.push([c])
  }
  VArray(rows)
}

// ---------------------------------------------------------------------------
// Info functions missing from the existing info module
// ---------------------------------------------------------------------------

fn fn_error_type(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VError(NullErr) => VNumber(1.0)
    VError(DivZero) => VNumber(2.0)
    VError(Value) => VNumber(3.0)
    VError(Ref) => VNumber(4.0)
    VError(Name) => VNumber(5.0)
    VError(Num) => VNumber(6.0)
    VError(NotApplicable) => VNumber(7.0)
    VError(GettingData) => VNumber(8.0)
    _ => VError(NotApplicable)
  }
}

fn fn_iseven(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => VBool(n.trunc().to_int() % 2 == 0)
    other => other
  }
}

fn fn_isodd(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => VBool(n.trunc().to_int() % 2 != 0)
    other => other
  }
}

fn fn_isnontext(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(_) => VBool(false)
    _ => VBool(true)
  }
}

// ---------------------------------------------------------------------------
// LINEST / LOGEST — simplified single-variable versions
// ---------------------------------------------------------------------------

fn fn_linest(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() < 1 || args.length() > 4 { return VError(Value) }
  let ys = extract_number_array(args[0], ctx.date_system)
  let xs = if args.length() >= 2 {
    extract_number_array(args[1], ctx.date_system)
  } else {
    let out : Array[Double] = []
    for i in 0..<ys.length() { out.push((i + 1).to_double()) }
    out
  }
  let n = if xs.length() < ys.length() { xs.length() } else { ys.length() }
  if n < 2 { return VError(Value) }
  let mut sx = 0.0
  let mut sy = 0.0
  for i in 0..<n { sx = sx + xs[i]; sy = sy + ys[i] }
  let mx = sx / n.to_double()
  let my = sy / n.to_double()
  let mut sxy = 0.0
  let mut sxx = 0.0
  for i in 0..<n {
    let dx = xs[i] - mx
    sxy = sxy + dx * (ys[i] - my)
    sxx = sxx + dx * dx
  }
  if sxx == 0.0 { return VError(DivZero) }
  let slope = sxy / sxx
  let intercept = my - slope * mx
  VArray([[VNumber(slope), VNumber(intercept)]])
}

fn fn_logest(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() < 1 || args.length() > 4 { return VError(Value) }
  let ys = extract_number_array(args[0], ctx.date_system)
  let xs = if args.length() >= 2 {
    extract_number_array(args[1], ctx.date_system)
  } else {
    let out : Array[Double] = []
    for i in 0..<ys.length() { out.push((i + 1).to_double()) }
    out
  }
  let log_ys : Array[Double] = []
  for y in ys {
    if y <= 0.0 { return VError(Num) }
    log_ys.push(@math.ln(y))
  }
  let n = if xs.length() < log_ys.length() {
    xs.length()
  } else {
    log_ys.length()
  }
  if n < 2 { return VError(Value) }
  let mut sx = 0.0
  let mut sy = 0.0
  for i in 0..<n { sx = sx + xs[i]; sy = sy + log_ys[i] }
  let mx = sx / n.to_double()
  let my = sy / n.to_double()
  let mut sxy = 0.0
  let mut sxx = 0.0
  for i in 0..<n {
    let dx = xs[i] - mx
    sxy = sxy + dx * (log_ys[i] - my)
    sxx = sxx + dx * dx
  }
  if sxx == 0.0 { return VError(DivZero) }
  let slope = sxy / sxx
  let intercept = my - slope * mx
  VArray([[VNumber(@math.exp(slope)), VNumber(@math.exp(intercept))]])
}
