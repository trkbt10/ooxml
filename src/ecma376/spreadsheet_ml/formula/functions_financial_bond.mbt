///|
fn register_builtin_financial_bond_functions(
  registry : FunctionRegistry,
) -> Unit {
  registry.register("ACCRINT", Eager(fn_accrint))
  registry.register("ACCRINTM", Eager(fn_accrintm))
  registry.register("AMORDEGRC", Eager(fn_amordegrc))
  registry.register("AMORLINC", Eager(fn_amorlinc))
  registry.register("COUPDAYBS", Eager(fn_coupdaybs))
  registry.register("COUPDAYS", Eager(fn_coupdays))
  registry.register("COUPDAYSNC", Eager(fn_coupdaysnc))
  registry.register("COUPNCD", Eager(fn_coupncd))
  registry.register("COUPNUM", Eager(fn_coupnum))
  registry.register("COUPPCD", Eager(fn_couppcd))
  registry.register("DISC", Eager(fn_disc))
  registry.register("DOLLARDE", Eager(fn_dollarde))
  registry.register("DOLLARFR", Eager(fn_dollarfr))
  registry.register("DURATION", Eager(fn_duration))
  registry.register("MDURATION", Eager(fn_mduration))
  registry.register("FVSCHEDULE", Eager(fn_fvschedule))
  registry.register("INTRATE", Eager(fn_intrate))
  registry.register("ISPMT", Eager(fn_ispmt))
  registry.register("ODDFPRICE", Eager(fn_oddfprice))
  registry.register("ODDFYIELD", Eager(fn_oddfyield))
  registry.register("ODDLPRICE", Eager(fn_oddlprice))
  registry.register("ODDLYIELD", Eager(fn_oddlyield))
  registry.register("PRICE", Eager(fn_price))
  registry.register("PRICEDISC", Eager(fn_pricedisc))
  registry.register("PRICEMAT", Eager(fn_pricemat))
  registry.register("RECEIVED", Eager(fn_received))
  registry.register("TBILLEQ", Eager(fn_tbilleq))
  registry.register("TBILLPRICE", Eager(fn_tbillprice))
  registry.register("TBILLYIELD", Eager(fn_tbillyield))
  registry.register("VDB", Eager(fn_vdb))
  registry.register("XIRR", Eager(fn_xirr))
  registry.register("XNPV", Eager(fn_xnpv))
  registry.register("YIELD", Eager(fn_yield))
  registry.register("YIELDDISC", Eager(fn_yielddisc))
  registry.register("YIELDMAT", Eager(fn_yieldmat))
}

fn yearfrac_30_360(
  start : Double,
  end : Double,
  ds : @date_serial.DateSystem,
) -> Double {
  let s = try { @date_serial.serial_to_date_time(start, ds) } catch { _ => return 0.0 }
  let e = try { @date_serial.serial_to_date_time(end, ds) } catch { _ => return 0.0 }
  let mut sd = s.day
  let mut ed = e.day
  if sd == 31 { sd = 30 }
  if ed == 31 && sd == 30 { ed = 30 }
  ((e.year - s.year) * 360 + (e.month - s.month) * 30 + (ed - sd)).to_double() / 360.0
}

fn coup_days_in_period(freq : Int) -> Double {
  match freq {
    1 => 360.0
    2 => 180.0
    4 => 90.0
    _ => 360.0
  }
}

fn fn_accrint(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 6 || args.length() > 8 { return VError(Value) }
  let nums : Array[Double] = []
  for i in 0..<args.length().min(7) {
    match coerce_to_number(args[i].first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let (issue, _, settlement, rate) = (nums[0], nums[1], nums[2], nums[3])
  let par = if nums.length() > 4 { nums[4] } else { 1000.0 }
  let freq = if nums.length() > 5 { nums[5].trunc().to_int() } else { 2 }
  let yf = yearfrac_30_360(issue, settlement, ctx.date_system)
  VNumber(par * rate * yf * freq.to_double() / freq.to_double())
}

fn fn_accrintm(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 5 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let (issue, settlement, rate) = (nums[0], nums[1], nums[2])
  let par = if nums.length() > 3 { nums[3] } else { 1000.0 }
  let yf = yearfrac_30_360(issue, settlement, ctx.date_system)
  VNumber(par * rate * yf)
}

fn fn_amordegrc(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 6 || args.length() > 7 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let (cost, _, _, salvage, period, rate) = (nums[0], nums[1], nums[2], nums[3], nums[4].trunc().to_int(), nums[5])
  let coeff = if rate < 0.04 { 1.0 } else if rate < 0.08 { 1.5 } else { 2.0 }
  let dep_rate = rate * coeff
  let mut value = cost
  for i in 0..=period {
    let dep = if i == period { value - salvage } else { value * dep_rate }
    if value - dep < salvage {
      return VNumber(value - salvage)
    }
    value = value - dep
    if i == period { return VNumber(dep) }
  }
  VNumber(0.0)
}

fn fn_amorlinc(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 6 || args.length() > 7 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args {
    match coerce_to_number(arg.first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let (cost, _, _, salvage, period, rate) = (nums[0], nums[1], nums[2], nums[3], nums[4].trunc().to_int(), nums[5])
  let dep = cost * rate
  let mut value = cost
  for i in 0..=period {
    let d = if value - dep < salvage { value - salvage } else { dep }
    if i == period { return VNumber(d) }
    value = value - d
  }
  VNumber(0.0)
}

fn fn_coupdaybs(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 4 { return VError(Value) }
  let s = match coerce_to_number(args[0].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => return VError(Value) }
  let m = match coerce_to_number(args[1].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => return VError(Value) }
  let _ = m
  let freq = match coerce_to_number(args[2].first_scalar(), ctx.date_system) { VNumber(n) => n.trunc().to_int(); _ => return VError(Value) }
  let period = coup_days_in_period(freq)
  let days_in = (s.trunc().to_int() % period.to_int()).to_double()
  VNumber(days_in)
}

fn fn_coupdays(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 4 { return VError(Value) }
  let freq = match coerce_to_number(args[2].first_scalar(), ctx.date_system) { VNumber(n) => n.trunc().to_int(); _ => return VError(Value) }
  VNumber(coup_days_in_period(freq))
}

fn fn_coupdaysnc(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 4 { return VError(Value) }
  let s = match coerce_to_number(args[0].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => return VError(Value) }
  let freq = match coerce_to_number(args[2].first_scalar(), ctx.date_system) { VNumber(n) => n.trunc().to_int(); _ => return VError(Value) }
  let period = coup_days_in_period(freq)
  let days_in = (s.trunc().to_int() % period.to_int()).to_double()
  VNumber(period - days_in)
}

fn fn_coupncd(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 4 { return VError(Value) }
  let s = match coerce_to_number(args[0].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => return VError(Value) }
  let freq = match coerce_to_number(args[2].first_scalar(), ctx.date_system) { VNumber(n) => n.trunc().to_int(); _ => return VError(Value) }
  let period = coup_days_in_period(freq)
  let days_in = (s.trunc().to_int() % period.to_int()).to_double()
  VNumber(s.trunc() + (period - days_in))
}

fn fn_coupnum(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 4 { return VError(Value) }
  let s = match coerce_to_number(args[0].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => return VError(Value) }
  let m = match coerce_to_number(args[1].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => return VError(Value) }
  let freq = match coerce_to_number(args[2].first_scalar(), ctx.date_system) { VNumber(n) => n.trunc().to_int(); _ => return VError(Value) }
  let period = coup_days_in_period(freq)
  let remaining_days = m - s
  VNumber((remaining_days / period).ceil())
}

fn fn_couppcd(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 3 || args.length() > 4 { return VError(Value) }
  let s = match coerce_to_number(args[0].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => return VError(Value) }
  let freq = match coerce_to_number(args[2].first_scalar(), ctx.date_system) { VNumber(n) => n.trunc().to_int(); _ => return VError(Value) }
  let period = coup_days_in_period(freq)
  let days_in = (s.trunc().to_int() % period.to_int()).to_double()
  VNumber(s.trunc() - days_in)
}

fn fn_disc(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 4 || args.length() > 5 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args { match coerce_to_number(arg.first_scalar(), ctx.date_system) { VNumber(n) => nums.push(n); _ => return VError(Value) } }
  let (s, m, pr, redemption) = (nums[0], nums[1], nums[2], nums[3])
  let yf = yearfrac_30_360(s, m, ctx.date_system)
  if yf == 0.0 || redemption == 0.0 { return VError(Num) }
  VNumber((redemption - pr) / redemption / yf)
}

fn fn_dollarde(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 2) {
    None => VError(Value)
    Some(ns) => {
      let (dollar, frac) = (ns[0], ns[1].trunc().to_int())
      if frac <= 0 { return VError(DivZero) }
      let int_part = dollar.trunc()
      let dec_part = dollar - int_part
      let digits = dollarde_digits(frac)
      let pow10 = @math.pow(10.0, digits.to_double())
      let numerator = (dec_part * pow10 + 0.5).floor()
      VNumber(int_part + numerator / frac.to_double())
    }
  }
}

fn dollarde_digits(frac : Int) -> Int {
  let mut d = 1
  let mut p = 10
  while p <= frac {
    d = d + 1
    p = p * 10
  }
  d
}

fn fn_dollarfr(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 2) {
    None => VError(Value)
    Some(ns) => {
      let (dollar, frac) = (ns[0], ns[1].trunc().to_int())
      if frac <= 0 { return VError(DivZero) }
      let int_part = dollar.trunc()
      let dec_part = dollar - int_part
      let digits = dollarde_digits(frac)
      let pow10 = @math.pow(10.0, digits.to_double())
      let numerator = (dec_part * frac.to_double() + 0.5).floor()
      VNumber(int_part + numerator / pow10)
    }
  }
}

fn fn_duration(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 5 || args.length() > 6 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args { match coerce_to_number(arg.first_scalar(), ctx.date_system) { VNumber(n) => nums.push(n); _ => return VError(Value) } }
  let (s, m, coupon, yld, freq) = (nums[0], nums[1], nums[2], nums[3], nums[4].trunc().to_int())
  let n = ((m - s) / coup_days_in_period(freq)).ceil().to_int()
  let c = coupon / freq.to_double()
  let y = yld / freq.to_double()
  let mut pv_cf = 0.0
  let mut pv_total = 0.0
  for i in 1..=n {
    let cf = if i == n { c + 1.0 } else { c }
    let disc = @math.pow(1.0 + y, i.to_double())
    pv_cf = pv_cf + i.to_double() * cf / disc
    pv_total = pv_total + cf / disc
  }
  if pv_total == 0.0 { return VError(Num) }
  VNumber(pv_cf / pv_total / freq.to_double())
}

fn fn_mduration(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match fn_duration(args, ctx) {
    VNumber(dur) => {
      let yld = match coerce_to_number(args[3].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => return VError(Value) }
      let freq = match coerce_to_number(args[4].first_scalar(), ctx.date_system) { VNumber(n) => n.trunc().to_int(); _ => return VError(Value) }
      VNumber(dur / (1.0 + yld / freq.to_double()))
    }
    other => other
  }
}

fn fn_fvschedule(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 { return VError(Value) }
  let pv = match coerce_to_number(args[0].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => return VError(Value) }
  let rates = extract_number_array(args[1], ctx.date_system)
  let mut result = pv
  for r in rates { result = result * (1.0 + r) }
  VNumber(result)
}

fn fn_intrate(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 4 || args.length() > 5 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args { match coerce_to_number(arg.first_scalar(), ctx.date_system) { VNumber(n) => nums.push(n); _ => return VError(Value) } }
  let (s, m, investment, redemption) = (nums[0], nums[1], nums[2], nums[3])
  let yf = yearfrac_30_360(s, m, ctx.date_system)
  if yf == 0.0 || investment == 0.0 { return VError(Num) }
  VNumber((redemption - investment) / investment / yf)
}

fn fn_ispmt(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 4) {
    None => VError(Value)
    Some(ns) => {
      let (rate, per, nper, pv) = (ns[0], ns[1], ns[2], ns[3])
      if nper == 0.0 { return VError(DivZero) }
      VNumber(pv * rate * (per / nper - 1.0))
    }
  }
}

fn fn_price(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 6 || args.length() > 7 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args { match coerce_to_number(arg.first_scalar(), ctx.date_system) { VNumber(n) => nums.push(n); _ => return VError(Value) } }
  let (s, m, rate, yld, redemption, freq) = (nums[0], nums[1], nums[2], nums[3], nums[4], nums[5].trunc().to_int())
  let n = ((m - s) / coup_days_in_period(freq)).ceil().to_int().max(1)
  let c = rate * 100.0 / freq.to_double()
  let y = yld / freq.to_double()
  let mut pv = 0.0
  for i in 1..=n {
    let cf = if i == n { c + redemption } else { c }
    pv = pv + cf / @math.pow(1.0 + y, i.to_double())
  }
  VNumber(pv)
}

fn fn_pricedisc(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 4 || args.length() > 5 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args { match coerce_to_number(arg.first_scalar(), ctx.date_system) { VNumber(n) => nums.push(n); _ => return VError(Value) } }
  let (s, m, disc, redemption) = (nums[0], nums[1], nums[2], nums[3])
  let yf = yearfrac_30_360(s, m, ctx.date_system)
  VNumber(redemption * (1.0 - disc * yf))
}

fn fn_pricemat(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 5 || args.length() > 6 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args { match coerce_to_number(arg.first_scalar(), ctx.date_system) { VNumber(n) => nums.push(n); _ => return VError(Value) } }
  let (s, m, issue, rate, yld) = (nums[0], nums[1], nums[2], nums[3], nums[4])
  let dim = yearfrac_30_360(issue, m, ctx.date_system)
  let a = yearfrac_30_360(issue, s, ctx.date_system)
  let dsm = yearfrac_30_360(s, m, ctx.date_system)
  if 1.0 + dsm * yld == 0.0 { return VError(Num) }
  VNumber(100.0 * (1.0 + dim * rate) / (1.0 + dsm * yld) - 100.0 * a * rate)
}

fn fn_received(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 4 || args.length() > 5 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args { match coerce_to_number(arg.first_scalar(), ctx.date_system) { VNumber(n) => nums.push(n); _ => return VError(Value) } }
  let (s, m, investment, disc) = (nums[0], nums[1], nums[2], nums[3])
  let yf = yearfrac_30_360(s, m, ctx.date_system)
  let denom = 1.0 - disc * yf
  if denom == 0.0 { return VError(Num) }
  VNumber(investment / denom)
}

fn fn_tbilleq(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let dsm = ns[1] - ns[0]
      let disc = ns[2]
      if dsm <= 0.0 { return VError(Num) }
      let price = 100.0 * (1.0 - disc * dsm / 360.0)
      if price == 0.0 { return VError(Num) }
      VNumber(365.0 * disc / (360.0 - disc * dsm))
    }
  }
}

fn fn_tbillprice(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let dsm = ns[1] - ns[0]
      let disc = ns[2]
      VNumber(100.0 * (1.0 - disc * dsm / 360.0))
    }
  }
}

fn fn_tbillyield(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 3) {
    None => VError(Value)
    Some(ns) => {
      let dsm = ns[1] - ns[0]
      let pr = ns[2]
      if dsm <= 0.0 || pr <= 0.0 { return VError(Num) }
      VNumber((100.0 - pr) / pr * 360.0 / dsm)
    }
  }
}

fn fn_vdb(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 5 || args.length() > 7 { return VError(Value) }
  let nums : Array[Double] = []
  for i in 0..<5 {
    match coerce_to_number(args[i].first_scalar(), ctx.date_system) {
      VNumber(n) => nums.push(n)
      _ => return VError(Value)
    }
  }
  let (cost, salvage, life, start_period, end_period) = (nums[0], nums[1], nums[2], nums[3], nums[4])
  let factor = if args.length() >= 6 {
    match coerce_to_number(args[5].first_scalar(), ctx.date_system) {
      VNumber(n) => n
      _ => return VError(Value)
    }
  } else {
    2.0
  }
  if life <= 0.0 { return VError(Num) }
  let mut total_dep = 0.0
  let mut value = cost
  let rate = factor / life
  let periods = end_period.ceil().to_int()
  for i in 0..<periods {
    let p = (i + 1).to_double()
    if p <= start_period { continue }
    let dep = (value * rate).min(value - salvage).max(0.0)
    if p > start_period && p <= end_period {
      total_dep = total_dep + dep
    }
    value = value - dep
  }
  VNumber(total_dep)
}

fn fn_xnpv(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 { return VError(Value) }
  let rate = match coerce_to_number(args[0].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => return VError(Value) }
  let values = extract_number_array(args[1], ctx.date_system)
  let dates = extract_number_array(args[2], ctx.date_system)
  if values.length() != dates.length() || values.length() == 0 { return VError(Num) }
  let d0 = dates[0]
  let mut npv = 0.0
  for i in 0..<values.length() {
    let t = (dates[i] - d0) / 365.0
    npv = npv + values[i] / @math.pow(1.0 + rate, t)
  }
  VNumber(npv)
}

fn fn_xirr(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 2 || args.length() > 3 { return VError(Value) }
  let values = extract_number_array(args[0], ctx.date_system)
  let dates = extract_number_array(args[1], ctx.date_system)
  if values.length() != dates.length() || values.length() < 2 { return VError(Num) }
  let mut guess = if args.length() == 3 {
    match coerce_to_number(args[2].first_scalar(), ctx.date_system) { VNumber(n) => n; _ => 0.1 }
  } else {
    0.1
  }
  let d0 = dates[0]
  for _iter in 0..<200 {
    let mut f = 0.0
    let mut df = 0.0
    for i in 0..<values.length() {
      let t = (dates[i] - d0) / 365.0
      let disc = @math.pow(1.0 + guess, t)
      f = f + values[i] / disc
      if t != 0.0 { df = df - t * values[i] / (disc * (1.0 + guess)) }
    }
    if df.abs() < 1.0e-15 { break }
    let new_guess = guess - f / df
    if (new_guess - guess).abs() < 1.0e-10 { return VNumber(new_guess) }
    guess = new_guess
  }
  VNumber(guess)
}

fn fn_yield(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 6 || args.length() > 7 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args { match coerce_to_number(arg.first_scalar(), ctx.date_system) { VNumber(n) => nums.push(n); _ => return VError(Value) } }
  let (s, m, rate, pr, redemption, freq) = (nums[0], nums[1], nums[2], nums[3], nums[4], nums[5].trunc().to_int())
  let mut lo = -0.5
  let mut hi = 2.0
  for _i in 0..<100 {
    let mid = (lo + hi) / 2.0
    let new_args : Array[FormulaValue] = [
      VNumber(s), VNumber(m), VNumber(rate), VNumber(mid), VNumber(redemption), VNumber(freq.to_double()),
    ]
    match fn_price(new_args, ctx) {
      VNumber(p) => if p > pr { lo = mid } else { hi = mid }
      _ => return VError(Num)
    }
  }
  VNumber((lo + hi) / 2.0)
}

fn fn_yielddisc(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 4 || args.length() > 5 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args { match coerce_to_number(arg.first_scalar(), ctx.date_system) { VNumber(n) => nums.push(n); _ => return VError(Value) } }
  let (s, m, pr, redemption) = (nums[0], nums[1], nums[2], nums[3])
  let yf = yearfrac_30_360(s, m, ctx.date_system)
  if yf == 0.0 || pr == 0.0 { return VError(Num) }
  VNumber((redemption - pr) / pr / yf)
}

fn fn_yieldmat(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 5 || args.length() > 6 { return VError(Value) }
  let nums : Array[Double] = []
  for arg in args { match coerce_to_number(arg.first_scalar(), ctx.date_system) { VNumber(n) => nums.push(n); _ => return VError(Value) } }
  let (s, m, issue, rate, pr) = (nums[0], nums[1], nums[2], nums[3], nums[4])
  let dim = yearfrac_30_360(issue, m, ctx.date_system)
  let a = yearfrac_30_360(issue, s, ctx.date_system)
  let dsm = yearfrac_30_360(s, m, ctx.date_system)
  let denom = dsm * (pr / 100.0 + a * rate)
  if denom == 0.0 { return VError(Num) }
  VNumber((1.0 + dim * rate - (pr / 100.0 + a * rate)) / denom)
}

fn fn_oddfprice(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  fn_price(args, ctx)
}

fn fn_oddfyield(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  fn_yield(args, ctx)
}

fn fn_oddlprice(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  fn_price(args, ctx)
}

fn fn_oddlyield(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  fn_yield(args, ctx)
}
