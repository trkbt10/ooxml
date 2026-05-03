///|
fn register_builtin_datetime_functions(registry : FunctionRegistry) -> Unit {
  registry.register("DATE", Eager(fn_date))
  registry.register("TIME", Eager(fn_time))
  registry.register("DAY", Eager(fn_day))
  registry.register("MONTH", Eager(fn_month))
  registry.register("YEAR", Eager(fn_year))
  registry.register("HOUR", Eager(fn_hour))
  registry.register("MINUTE", Eager(fn_minute))
  registry.register("SECOND", Eager(fn_second))
  registry.register("WEEKDAY", Eager(fn_weekday))
  registry.register("NOW", Eager(fn_now))
  registry.register("TODAY", Eager(fn_today))
  registry.register("DATEVALUE", Eager(fn_datevalue))
  registry.register("TIMEVALUE", Eager(fn_timevalue))
  registry.register("DAYS", Eager(fn_days))
  registry.register("EDATE", Eager(fn_edate))
  registry.register("EOMONTH", Eager(fn_eomonth))
}

///|
/// §18.17.7.DATE — return the serial date for a year, month, and day.
fn fn_date(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 {
    return VError(Value)
  }
  let year = datetime_integer_arg(args[0], ctx)
  let month = datetime_integer_arg(args[1], ctx)
  let day = datetime_integer_arg(args[2], ctx)
  match (year, month, day) {
    (VNumber(y), VNumber(m), VNumber(d)) =>
      serial_from_ymd(y.to_int(), m.to_int(), d.to_int(), ctx)
    (VError(err), _, _) | (_, VError(err), _) | (_, _, VError(err)) =>
      VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.TIME — return the serial fraction for an hour, minute, and second.
fn fn_time(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 {
    return VError(Value)
  }
  let hour = datetime_integer_arg(args[0], ctx)
  let minute = datetime_integer_arg(args[1], ctx)
  let second = datetime_integer_arg(args[2], ctx)
  match (hour, minute, second) {
    (VNumber(h), VNumber(m), VNumber(s)) =>
      time_fraction(h.to_int(), m.to_int(), s.to_int())
    (VError(err), _, _) | (_, VError(err), _) | (_, _, VError(err)) =>
      VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.DAY — return the day-of-month from a serial date.
fn fn_day(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_serial_datetime(args, ctx) {
    VArray(rows) => {
      let dt = rows[0][0]
      match dt {
        VNumber(day) => VNumber(day)
        other => other
      }
    }
    other => other
  }
}

///|
/// §18.17.7.MONTH — return the month number from a serial date.
fn fn_month(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_datetime(args, ctx) {
    Some(dt) => VNumber(dt.month.to_double())
    None => datetime_serial_error(args, ctx)
  }
}

///|
/// §18.17.7.YEAR — return the year from a serial date.
fn fn_year(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_datetime(args, ctx) {
    Some(dt) => VNumber(dt.year.to_double())
    None => datetime_serial_error(args, ctx)
  }
}

///|
/// §18.17.7.HOUR — return the hour from a serial date-time.
fn fn_hour(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_datetime(args, ctx) {
    Some(dt) => VNumber(dt.hour.to_double())
    None => datetime_serial_error(args, ctx)
  }
}

///|
/// §18.17.7.MINUTE — return the minute from a serial date-time.
fn fn_minute(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_datetime(args, ctx) {
    Some(dt) => VNumber(dt.minute.to_double())
    None => datetime_serial_error(args, ctx)
  }
}

///|
/// §18.17.7.SECOND — return the second from a serial date-time.
fn fn_second(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_datetime(args, ctx) {
    Some(dt) => VNumber(dt.second.to_double())
    None => datetime_serial_error(args, ctx)
  }
}

///|
/// §18.17.7.WEEKDAY — return the day-of-week using the selected return type.
fn fn_weekday(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 && args.length() != 2 {
    return VError(Value)
  }
  let serial = scalar_number(args[0], ctx)
  let return_type = if args.length() == 2 {
    datetime_integer_arg(args[1], ctx)
  } else {
    VNumber(1.0)
  }
  match (serial, return_type) {
    (VNumber(s), VNumber(t)) => weekday_from_serial(s, t.to_int(), ctx)
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.NOW — return the deterministic current date-time serial.
fn fn_now(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    VNumber(0.0)
  } else {
    VError(Value)
  }
}

///|
/// §18.17.7.TODAY — return the deterministic current date serial.
fn fn_today(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    VNumber(0.0)
  } else {
    VError(Value)
  }
}

///|
/// §18.17.7.DATEVALUE — parse date text and return its serial value.
fn fn_datevalue(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match scalar_text(args[0]) {
    VString(text) =>
      match parse_iso_date(text.trim().to_owned()) {
        Some(dt) => datetime_to_value(dt, ctx)
        None => VError(Value)
      }
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.TIMEVALUE — parse time text and return its serial fraction.
fn fn_timevalue(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match scalar_text(args[0]) {
    VString(text) =>
      match parse_hms(text.trim().to_owned()) {
        Some((h, m, s)) => time_fraction(h, m, s)
        None => VError(Value)
      }
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.DAYS — return the number of days between two date serials.
fn fn_days(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let end_date = scalar_number(args[0], ctx)
  let start_date = scalar_number(args[1], ctx)
  match (end_date, start_date) {
    (VNumber(end_num), VNumber(start_num)) =>
      VNumber((end_num.floor() - start_num.floor()).to_int().to_double())
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.EDATE — return the serial date shifted by a number of months.
fn fn_edate(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let start_date = scalar_number(args[0], ctx)
  let months = datetime_integer_arg(args[1], ctx)
  match (start_date, months) {
    (VNumber(serial), VNumber(delta)) =>
      shift_month_serial(serial, delta.to_int(), false, ctx)
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.EOMONTH — return the last day of the month after a month shift.
fn fn_eomonth(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let start_date = scalar_number(args[0], ctx)
  let months = datetime_integer_arg(args[1], ctx)
  match (start_date, months) {
    (VNumber(serial), VNumber(delta)) =>
      shift_month_serial(serial, delta.to_int(), true, ctx)
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
fn one_serial_datetime(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  match one_datetime(args, ctx) {
    Some(dt) => VArray([[VNumber(dt.day.to_double())]])
    None => datetime_serial_error(args, ctx)
  }
}

///|
fn one_datetime(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> @date_serial.CalendarDateTime? {
  if args.length() != 1 {
    return None
  }
  match scalar_number(args[0], ctx) {
    VNumber(serial) =>
      Some(@date_serial.serial_to_date_time(serial, ctx.date_system)) catch {
        _ => None
      }
    _ => None
  }
}

///|
fn datetime_serial_error(
  args : Array[FormulaValue],
  ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match scalar_number(args[0], ctx) {
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
fn datetime_integer_arg(
  value : FormulaValue,
  ctx : EvalContext,
) -> FormulaValue {
  match scalar_number(value, ctx) {
    VNumber(n) => VNumber(n.trunc())
    other => other
  }
}

///|
fn serial_from_ymd(
  year : Int,
  month : Int,
  day : Int,
  ctx : EvalContext,
) -> FormulaValue {
  let normalized = normalize_ymd(year, month, day)
  datetime_to_value(
    @date_serial.CalendarDateTime::{
      year: normalized.year,
      month: normalized.month,
      day: normalized.day,
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    },
    ctx,
  )
}

///|
fn datetime_to_value(
  dt : @date_serial.CalendarDateTime,
  ctx : EvalContext,
) -> FormulaValue {
  let serial : Double = try
    @date_serial.date_time_to_serial(dt, ctx.date_system)
  catch {
    _ => return VError(Value)
  } noraise {
    value => value
  }
  VNumber(serial)
}

///|
fn time_fraction(hour : Int, minute : Int, second : Int) -> FormulaValue {
  if hour < 0 || minute < 0 || second < 0 {
    return VError(Num)
  }
  let total_seconds = hour * 3600 + minute * 60 + second
  let seconds_in_day = 86400
  VNumber(
    (total_seconds % seconds_in_day).to_double() / seconds_in_day.to_double(),
  )
}

///|
fn weekday_from_serial(
  serial : Double,
  return_type : Int,
  ctx : EvalContext,
) -> FormulaValue {
  let dt : @date_serial.CalendarDateTime = try
    @date_serial.serial_to_date_time(serial, ctx.date_system)
  catch {
    _ => return VError(Value)
  } noraise {
    value => value
  }
  let days = civil_day_number(dt.year, dt.month, dt.day)
  let monday_zero = (days + 3) % 7
  match return_type {
    1 => VNumber(((monday_zero + 1) % 7 + 1).to_double())
    2 => VNumber((monday_zero + 1).to_double())
    3 => VNumber(monday_zero.to_double())
    _ => VError(Num)
  }
}

///|
priv struct DateParts {
  year : Int
  month : Int
  day : Int
}

///|
fn normalize_ymd(year : Int, month : Int, day : Int) -> DateParts {
  let month_zero = month - 1
  let year_delta = floor_div(month_zero, 12)
  let normalized_month = month_zero - year_delta * 12 + 1
  let normalized_year = year + year_delta
  let base_day = civil_day_number(normalized_year, normalized_month, 1)
  civil_from_day_number(base_day + day - 1)
}

///|
fn shift_month_serial(
  serial : Double,
  months : Int,
  end_of_month : Bool,
  ctx : EvalContext,
) -> FormulaValue {
  let dt : @date_serial.CalendarDateTime = try
    @date_serial.serial_to_date_time(serial, ctx.date_system)
  catch {
    _ => return VError(Value)
  } noraise {
    value => value
  }
  let target = normalize_ymd(dt.year, dt.month + months, 1)
  let max_day = datetime_days_in_month(target.year, target.month)
  let day = if end_of_month { max_day } else { dt.day.min(max_day) }
  datetime_to_value(
    @date_serial.CalendarDateTime::{
      year: target.year,
      month: target.month,
      day,
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    },
    ctx,
  )
}

///|
fn parse_iso_date(text : String) -> @date_serial.CalendarDateTime? {
  if text.length() != 10 ||
    text.code_unit_at(4) != '-' ||
    text.code_unit_at(7) != '-' {
    return None
  }
  let year = parse_int_slice(text, 0, 4)
  let month = parse_int_slice(text, 5, 7)
  let day = parse_int_slice(text, 8, 10)
  match (year, month, day) {
    (Some(y), Some(m), Some(d)) =>
      Some(@date_serial.CalendarDateTime::{
        year: y,
        month: m,
        day: d,
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
      })
    _ => None
  }
}

///|
fn parse_hms(text : String) -> (Int, Int, Int)? {
  if text.length() != 8 ||
    text.code_unit_at(2) != ':' ||
    text.code_unit_at(5) != ':' {
    return None
  }
  let hour = parse_int_slice(text, 0, 2)
  let minute = parse_int_slice(text, 3, 5)
  let second = parse_int_slice(text, 6, 8)
  match (hour, minute, second) {
    (Some(h), Some(m), Some(s)) => Some((h, m, s))
    _ => None
  }
}

///|
fn parse_int_slice(text : String, start : Int, end : Int) -> Int? {
  let mut value = 0
  for i in start..<end {
    let code = text.code_unit_at(i).to_int()
    if code < 48 || code > 57 {
      return None
    }
    value = value * 10 + code - 48
  }
  Some(value)
}

///|
fn datetime_days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 => if @date_serial.is_leap_year_gregorian(year) { 29 } else { 28 }
    _ => 0
  }
}

///|
fn floor_div(value : Int, divisor : Int) -> Int {
  if value >= 0 {
    value / divisor
  } else {
    (value - divisor + 1) / divisor
  }
}

///|
fn civil_day_number(year : Int, month : Int, day : Int) -> Int {
  let adjusted_year = year - (if month <= 2 { 1 } else { 0 })
  let era = if adjusted_year >= 0 {
    adjusted_year / 400
  } else {
    (adjusted_year - 399) / 400
  }
  let year_of_era = adjusted_year - era * 400
  let month_prime = month + (if month > 2 { -3 } else { 9 })
  let day_of_year = (153 * month_prime + 2) / 5 + day - 1
  let day_of_era = year_of_era * 365 +
    year_of_era / 4 -
    year_of_era / 100 +
    day_of_year
  era * 146097 + day_of_era - 719468
}

///|
fn civil_from_day_number(z : Int) -> DateParts {
  let shifted = z + 719468
  let era = if shifted >= 0 {
    shifted / 146097
  } else {
    (shifted - 146096) / 146097
  }
  let day_of_era = shifted - era * 146097
  let year_of_era = (
      day_of_era - day_of_era / 1460 + day_of_era / 36524 - day_of_era / 146096
    ) /
    365
  let year = year_of_era + era * 400
  let day_of_year = day_of_era -
    (365 * year_of_era + year_of_era / 4 - year_of_era / 100)
  let month_prime = (5 * day_of_year + 2) / 153
  let day = day_of_year - (153 * month_prime + 2) / 5 + 1
  let month = month_prime + (if month_prime < 10 { 3 } else { -9 })
  DateParts::{ year: year + (if month <= 2 { 1 } else { 0 }), month, day }
}
