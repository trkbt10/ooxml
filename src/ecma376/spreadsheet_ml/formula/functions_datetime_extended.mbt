///|
fn register_builtin_datetime_extended_functions(
  registry : FunctionRegistry,
) -> Unit {
  registry.register("DATEDIF", Eager(fn_datedif))
  registry.register("DAYS360", Eager(fn_days360))
  registry.register("WEEKNUM", Eager(fn_weeknum))
  registry.register("NETWORKDAYS", Eager(fn_networkdays))
  registry.register("NETWORKDAYS.INTL", Eager(fn_networkdays_intl))
  registry.register("WORKDAY", Eager(fn_workday))
  registry.register("WORKDAY.INTL", Eager(fn_workday_intl))
  registry.register("YEARFRAC", Eager(fn_yearfrac))
}

///|
fn serial_to_ymd(
  serial : Double,
  ds : @date_serial.DateSystem,
) -> (Int, Int, Int)? {
  try @date_serial.serial_to_date_time(serial, ds) catch {
    _ => None
  } noraise {
    dt => Some((dt.year, dt.month, dt.day))
  }
}

///|
fn ymd_to_serial(
  y : Int,
  m : Int,
  d : Int,
  ds : @date_serial.DateSystem,
) -> Double {
  let dt : @date_serial.CalendarDateTime = {
    year: y,
    month: m,
    day: d,
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
  }
  try @date_serial.date_time_to_serial(dt, ds) catch {
    _ => 0.0
  } noraise {
    n => n
  }
}

///|
fn fn_datedif(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 {
    return VError(Value)
  }
  let start = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let end = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let unit = match coerce_to_text(args[2].first_scalar()) {
    VString(s) => s
    _ => return VError(Value)
  }
  if start > end {
    return VError(Num)
  }
  let (sy, sm, sd) = match serial_to_ymd(start, ctx.date_system) {
    Some(v) => v
    None => return VError(Value)
  }
  let (ey, em, ed) = match serial_to_ymd(end, ctx.date_system) {
    Some(v) => v
    None => return VError(Value)
  }
  match unit {
    "Y" | "y" =>
      VNumber(
        (ey - sy - (if em < sm || (em == sm && ed < sd) { 1 } else { 0 })).to_double(),
      )
    "M" | "m" => {
      let months = (ey - sy) * 12 + (em - sm) - (if ed < sd { 1 } else { 0 })
      VNumber(months.to_double())
    }
    "D" | "d" => VNumber(end.trunc() - start.trunc())
    "MD" | "md" => {
      let d = ed - sd
      VNumber((if d < 0 { d + 30 } else { d }).to_double())
    }
    "YM" | "ym" => {
      let m = em - sm - (if ed < sd { 1 } else { 0 })
      VNumber((if m < 0 { m + 12 } else { m }).to_double())
    }
    "YD" | "yd" => {
      let end_in_start_year = ymd_to_serial(sy, em, ed, ctx.date_system)
      let diff = if end_in_start_year >= start {
        end_in_start_year - start
      } else {
        let end_next = ymd_to_serial(sy + 1, em, ed, ctx.date_system)
        end_next - start
      }
      VNumber(diff)
    }
    _ => VError(Num)
  }
}

///|
fn fn_days360(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 2 || args.length() > 3 {
    return VError(Value)
  }
  let start = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  let end = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  let european = if args.length() == 3 {
    match args[2].first_scalar() {
      VBool(b) => b
      VNumber(n) => n != 0.0
      _ => false
    }
  } else {
    false
  }
  let (sy, sm, sd_raw) = match serial_to_ymd(start, ctx.date_system) {
    Some(v) => v
    None => return VError(Value)
  }
  let (ey, em, ed_raw) = match serial_to_ymd(end, ctx.date_system) {
    Some(v) => v
    None => return VError(Value)
  }
  let (sd_val, ed_val) = if european {
    let sd2 = if sd_raw == 31 { 30 } else { sd_raw }
    let ed2 = if ed_raw == 31 { 30 } else { ed_raw }
    (sd2, ed2)
  } else {
    let sd2 = if sd_raw == 31 { 30 } else { sd_raw }
    let ed2 = if ed_raw == 31 && sd2 >= 30 { 30 } else { ed_raw }
    (sd2, ed2)
  }
  let days = (ey - sy) * 360 + (em - sm) * 30 + (ed_val - sd_val)
  VNumber(days.to_double())
}

///|
fn fn_weeknum(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 {
    return VError(Value)
  }
  let serial = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  let (y, _, _) = match serial_to_ymd(serial, ctx.date_system) {
    Some(v) => v
    None => return VError(Value)
  }
  let jan1 = ymd_to_serial(y, 1, 1, ctx.date_system)
  let day_of_year = serial.trunc() - jan1 + 1.0
  VNumber(((day_of_year + 6.0) / 7.0).ceil())
}

///|
fn is_weekend_day(serial : Double, ds : @date_serial.DateSystem) -> Bool {
  let dow = serial_day_of_week(serial, ds)
  dow == 0 || dow == 6
}

///|
fn serial_day_of_week(serial : Double, ds : @date_serial.DateSystem) -> Int {
  let base = match ds {
    @date_serial.DateSystem::Serial1900 => 0
    @date_serial.DateSystem::Serial1904 => 5
  }
  ((serial.trunc().to_int() + base) % 7 + 7) % 7
}

///|
fn fn_networkdays(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() < 2 || args.length() > 3 {
    return VError(Value)
  }
  let start = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc()
    _ => return VError(Value)
  }
  let end = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc()
    _ => return VError(Value)
  }
  let holidays = if args.length() == 3 {
    extract_number_array(args[2], ctx.date_system)
  } else {
    []
  }
  let (lo, hi, sign) = if start <= end {
    (start, end, 1.0)
  } else {
    (end, start, -1.0)
  }
  let mut count = 0.0
  let mut d = lo
  while d <= hi {
    if !is_weekend_day(d, ctx.date_system) {
      let mut is_holiday = false
      for h in holidays {
        if h.trunc() == d {
          is_holiday = true
          break
        }
      }
      if !is_holiday {
        count = count + 1.0
      }
    }
    d = d + 1.0
  }
  VNumber(sign * count)
}

///|
fn fn_networkdays_intl(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  fn_networkdays(args, ctx)
}

///|
fn fn_workday(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 2 || args.length() > 3 {
    return VError(Value)
  }
  let start = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc()
    _ => return VError(Value)
  }
  let days = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc().to_int()
    _ => return VError(Value)
  }
  let holidays = if args.length() == 3 {
    extract_number_array(args[2], ctx.date_system)
  } else {
    []
  }
  let step = if days >= 0 { 1.0 } else { -1.0 }
  let mut remaining = days.abs()
  let mut d = start
  while remaining > 0 {
    d = d + step
    if !is_weekend_day(d, ctx.date_system) {
      let mut is_holiday = false
      for h in holidays {
        if h.trunc() == d {
          is_holiday = true
          break
        }
      }
      if !is_holiday {
        remaining = remaining - 1
      }
    }
  }
  VNumber(d)
}

///|
fn fn_workday_intl(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  fn_workday(args, ctx)
}

///|
fn fn_yearfrac(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 2 || args.length() > 3 {
    return VError(Value)
  }
  let start = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  let end = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  let basis = if args.length() == 3 {
    match coerce_to_number(args[2].first_scalar(), ctx.date_system) {
      VNumber(n) => n.trunc().to_int()
      _ => return VError(Value)
    }
  } else {
    0
  }
  let days = (end - start).abs()
  match basis {
    0 => {
      let (sy, sm, sd_raw) = match serial_to_ymd(start, ctx.date_system) {
        Some(v) => v
        None => return VError(Value)
      }
      let (ey, em, ed_raw) = match serial_to_ymd(end, ctx.date_system) {
        Some(v) => v
        None => return VError(Value)
      }
      let sd_v = if sd_raw == 31 { 30 } else { sd_raw }
      let ed_v = if ed_raw == 31 && sd_v == 30 { 30 } else { ed_raw }
      let d360 = ((ey - sy) * 360 + (em - sm) * 30 + (ed_v - sd_v)).to_double()
      VNumber(d360.abs() / 360.0)
    }
    1 => {
      let avg_year = days / ((end - start).abs() / 365.25).max(1.0)
      VNumber(days / avg_year)
    }
    2 => VNumber(days / 360.0)
    3 => VNumber(days / 365.0)
    4 => {
      let (sy, sm, sd_raw) = match serial_to_ymd(start, ctx.date_system) {
        Some(v) => v
        None => return VError(Value)
      }
      let (ey, em, ed_raw) = match serial_to_ymd(end, ctx.date_system) {
        Some(v) => v
        None => return VError(Value)
      }
      let sd_v = if sd_raw == 31 { 30 } else { sd_raw }
      let ed_v = if ed_raw == 31 { 30 } else { ed_raw }
      let d360 = ((ey - sy) * 360 + (em - sm) * 30 + (ed_v - sd_v)).to_double()
      VNumber(d360.abs() / 360.0)
    }
    _ => VError(Num)
  }
}
