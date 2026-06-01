///|
let millis_per_day = 86400000.0

///|
let millis_per_hour = 3600000

///|
let millis_per_minute = 60000

///|
let millis_per_second = 1000

///|
let days_unix_to_1900_base : Int = days_from_civil(1899, 12, 30)

///|
let days_unix_to_1904_base : Int = days_from_civil(1904, 1, 1)

///|
/// §18.17.4.1 — serial bounds derived from the proleptic
/// Gregorian calendar range 0001-01-01..9999-12-31 (the spec
/// permits any date in this window):
///
///   serial1900_min = days_from_civil(   1, 1, 1) - 1
///                  = -693593.0
///   serial1900_max = days_from_civil(9999,12,31) + (1 - 1/86_400_000)
///                  = 2958465 + 0.9999884... ≈ 2958465.9999884
///   serial1904_min = serial1900_min - days_from_civil(1904, 1, 1)
///                  = -695055.0
///   serial1904_max = serial1900_max - days_from_civil(1904, 1, 1)
///                  ≈ 2957003.9999884
///
/// The 0.9999884... fractional cap is `1 − 1ms` expressed as a
/// fraction of a day (`1 − 1/86_400_000 ≈ 0.99998842592...`)
/// which keeps the round-trip from `DateTime` to serial and
/// back from rolling over to the next day at exactly midnight.
let serial1900_min = -693593.0

///|
let serial1900_max = 2958465.9999884

///|
let serial1904_min = -695055.0

///|
let serial1904_max = 2957003.9999884

///|
priv struct CivilDate {
  year : Int
  month : Int
  day : Int
}

///|
/// §18.2 CT_WorkbookPr/@date1904 selector. Workbook-level toggle that
/// determines which §18.17.4.1 serial date-time base applies.
pub(all) enum DateSystem {
  /// §18.17.4.1 1900 system, base 1899-12-30, with Lotus leap bug.
  Serial1900
  /// §18.17.4.1 1904 system, base 1904-01-01.
  Serial1904
} derive(Eq, Debug)

///|
/// Calendar date-time in the proleptic Gregorian calendar for §18.17.4.1
/// conversion. Year is constrained to 1..=9999 by §18.17.4 Dates and Times.
pub(all) struct CalendarDateTime {
  year : Int
  month : Int
  day : Int
  hour : Int
  minute : Int
  second : Int
  millisecond : Int
} derive(Eq, Debug)

///|
/// Time-of-day component in the §18.17.4 ISO 8601 lexical space.
/// Midnight is represented as hour 0; hour 24 and leap seconds are
/// rejected by the parser.
pub(all) struct TimeOfDay {
  hour : Int
  minute : Int
  second : Int
  millisecond : Int
} derive(Eq, Debug)

///|
priv enum IsoLexicalKind {
  IsoDateTime
  IsoTimeOfDay
}

///|
/// Parse the §18.17.4 ISO 8601 lexical form used by `t="d"` cells:
/// `YYYY-MM-DD`, `YYYY-MM-DDTHH:MM`, `YYYY-MM-DDTHH:MM:SS`, or
/// `YYYY-MM-DDTHH:MM:SS.fff...`. SpreadsheetML serial dates are local
/// date-times; timezone designators are rejected instead of normalized.
/// The repository stores millisecond precision, so fractional seconds
/// beyond three digits are truncated.
pub fn parse_iso8601_date_time(
  raw : String,
) -> CalendarDateTime raise @opc_errors.SchemaViolation {
  let n = raw.length()
  if n < 10 {
    invalid_iso8601_date_time("date-time is shorter than YYYY-MM-DD")
  }
  let year = parse_iso_fixed_int(raw, 0, 4, "year", IsoDateTime)
  require_iso_char(raw, 4, '-', "date separator", IsoDateTime)
  let month = parse_iso_fixed_int(raw, 5, 7, "month", IsoDateTime)
  require_iso_char(raw, 7, '-', "date separator", IsoDateTime)
  let day = parse_iso_fixed_int(raw, 8, 10, "day", IsoDateTime)
  let mut hour = 0
  let mut minute = 0
  let mut second = 0
  let mut millisecond = 0
  if n == 10 {
    ()
  } else {
    require_iso_char(raw, 10, 'T', "date/time separator", IsoDateTime)
    let time = parse_iso8601_time_fields(raw, 11, n, IsoDateTime)
    hour = time.hour
    minute = time.minute
    second = time.second
    millisecond = time.millisecond
  }
  let dt = CalendarDateTime::{
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
  }
  validate_iso8601_calendar_date_time(dt)
  dt
}

///|
pub fn parse_iso8601_date_time_opt(raw : String) -> CalendarDateTime? {
  try parse_iso8601_date_time(raw) catch {
    _ => None
  } noraise {
    value => Some(value)
  }
}

///|
/// Parse the §18.17.4 ISO 8601 lexical form for a time-of-day-only
/// value: `HH:MM`, `HH:MM:SS`, or `HH:MM:SS.fff...`.
pub fn parse_iso8601_time_of_day(
  raw : String,
) -> TimeOfDay raise @opc_errors.SchemaViolation {
  parse_iso8601_time_fields(raw, 0, raw.length(), IsoTimeOfDay)
}

///|
pub fn parse_iso8601_time_of_day_opt(raw : String) -> TimeOfDay? {
  try parse_iso8601_time_of_day(raw) catch {
    _ => None
  } noraise {
    value => Some(value)
  }
}

///|
/// Convert a §18.17.4 time-of-day component into the fractional part
/// of a serial date-time as defined by §18.17.4.2.
pub fn time_of_day_to_serial_fraction(
  value : TimeOfDay,
) -> Double raise @opc_errors.SchemaViolation {
  validate_time_of_day_value(value)
  let total_millis = value.hour * millis_per_hour +
    value.minute * millis_per_minute +
    value.second * millis_per_second +
    value.millisecond
  total_millis.to_double() / millis_per_day
}

///|
let max_calendar_date_time : CalendarDateTime = {
  year: 9999,
  month: 12,
  day: 31,
  hour: 23,
  minute: 59,
  second: 59,
  millisecond: 999,
}

///|
/// True if the calendar year is a leap year in the proleptic Gregorian
/// calendar used by §18.17.4.1. This reports true Gregorian leap-year status;
/// the §18.17.4.1 1900 date system's Lotus 1-2-3 compatibility phantom day is
/// handled only by serial conversion.
pub fn is_leap_year_gregorian(year : Int) -> Bool {
  year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}

///|
/// True if the §18.17.4.1 serial value falls in the valid temporal range for
/// the selected §18.2 workbookPr/@date1904 date system.
pub fn is_valid_serial(serial : Double, system : DateSystem) -> Bool {
  if serial.is_nan() || serial.is_inf() {
    return false
  }
  match system {
    Serial1900 => serial >= serial1900_min && serial <= serial1900_max
    Serial1904 => serial >= serial1904_min && serial <= serial1904_max
  }
}

///|
/// Convert a §18.17.4.1 serial date-time to a CalendarDateTime under the
/// selected §18.2 workbookPr/@date1904 date system. Raises SchemaViolation
/// when the serial is outside the selected date system's temporal range.
pub fn serial_to_date_time(
  serial : Double,
  system : DateSystem,
) -> CalendarDateTime raise @opc_errors.SchemaViolation {
  require_valid_serial(serial, system)
  if serial == max_serial(system) {
    return max_calendar_date_time
  }
  let day_serial = serial.floor().to_int()
  let fraction = serial - day_serial.to_double()
  let total_millis = (fraction * millis_per_day).round().to_int()
  let carry_days = total_millis / millis_per_day.to_int()
  let millis_in_day = total_millis % millis_per_day.to_int()
  let effective_serial_day = day_serial + carry_days
  let civil = if system == Serial1900 && effective_serial_day == 60 {
    CivilDate::{ year: 1900, month: 2, day: 29 }
  } else {
    civil_from_days(serial_day_to_calendar_day(effective_serial_day, system))
  }
  CalendarDateTime::{
    year: civil.year,
    month: civil.month,
    day: civil.day,
    hour: millis_in_day / millis_per_hour,
    minute: millis_in_day % millis_per_hour / millis_per_minute,
    second: millis_in_day % millis_per_minute / millis_per_second,
    millisecond: millis_in_day % millis_per_second,
  }
}

///|
/// Convert a CalendarDateTime to its §18.17.4.1 serial date-time under the
/// selected §18.2 workbookPr/@date1904 date system. Raises SchemaViolation for
/// dates outside the valid range or invalid calendar dates; in the 1900 system,
/// the normative Lotus 1-2-3 compatibility date 1900-02-29 is accepted as
/// serial 60.
pub fn date_time_to_serial(
  dt : CalendarDateTime,
  system : DateSystem,
) -> Double raise @opc_errors.SchemaViolation {
  validate_date_time(dt, system)
  if dt == max_calendar_date_time {
    return max_serial(system)
  }
  let day_serial = if is_lotus_1900_phantom(dt, system) {
    60
  } else {
    let absolute_day = days_from_civil(dt.year, dt.month, dt.day)
    calendar_day_to_serial_day(absolute_day, system)
  }
  let day_millis = dt.hour * millis_per_hour +
    dt.minute * millis_per_minute +
    dt.second * millis_per_second +
    dt.millisecond
  let serial = day_serial.to_double() + day_millis.to_double() / millis_per_day
  if !is_valid_serial(serial, system) {
    raise @opc_errors.SchemaViolation(
      section="Part 1 §18.17.4.1",
      path="serial date-time",
      reason="date-time is outside the selected date system range",
    )
  }
  serial
}

///|
fn max_serial(system : DateSystem) -> Double {
  match system {
    Serial1900 => serial1900_max
    Serial1904 => serial1904_max
  }
}

///|
fn base_day(system : DateSystem) -> Int {
  match system {
    Serial1900 => days_unix_to_1900_base
    Serial1904 => days_unix_to_1904_base
  }
}

///|
fn require_valid_serial(
  serial : Double,
  system : DateSystem,
) -> Unit raise @opc_errors.SchemaViolation {
  if !is_valid_serial(serial, system) {
    raise @opc_errors.SchemaViolation(
      section="Part 1 §18.17.4.1",
      path="serial date-time",
      reason="serial date-time is outside the selected date system range",
    )
  }
}

///|
fn validate_date_time(
  dt : CalendarDateTime,
  system : DateSystem,
) -> Unit raise @opc_errors.SchemaViolation {
  if is_lotus_1900_phantom(dt, system) {
    validate_time_of_day(dt)
    return
  }
  if dt.year < 1 || dt.year > 9999 || dt.month < 1 || dt.month > 12 {
    invalid_date_time("year or month is outside the §18.17.4.1 range")
  }
  let max_day = days_in_month(dt.year, dt.month)
  if dt.day < 1 || dt.day > max_day {
    invalid_date_time("day is not valid for the calendar month")
  }
  validate_time_of_day(dt)
}

///|
fn validate_time_of_day(
  dt : CalendarDateTime,
) -> Unit raise @opc_errors.SchemaViolation {
  validate_time_of_day_fields(dt.hour, dt.minute, dt.second, dt.millisecond)
}

///|
fn validate_time_of_day_value(
  value : TimeOfDay,
) -> Unit raise @opc_errors.SchemaViolation {
  validate_time_of_day_fields(
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
  )
}

///|
fn validate_time_of_day_fields(
  hour : Int,
  minute : Int,
  second : Int,
  millisecond : Int,
) -> Unit raise @opc_errors.SchemaViolation {
  if hour < 0 ||
    hour > 23 ||
    minute < 0 ||
    minute > 59 ||
    second < 0 ||
    second > 59 ||
    millisecond < 0 ||
    millisecond > 999 {
    invalid_date_time("time-of-day is outside the §18.17.4 range")
  }
}

///|
fn invalid_date_time(reason : String) -> Unit raise @opc_errors.SchemaViolation {
  raise @opc_errors.SchemaViolation(
    section="Part 1 §18.17.4.1",
    path="CalendarDateTime",
    reason~,
  )
}

///|
fn validate_iso8601_calendar_date_time(
  dt : CalendarDateTime,
) -> Unit raise @opc_errors.SchemaViolation {
  if dt.year < 1 || dt.year > 9999 || dt.month < 1 || dt.month > 12 {
    invalid_iso8601_date_time("year or month is outside the §18.17.4 range")
  }
  let max_day = days_in_month(dt.year, dt.month)
  if dt.day < 1 || dt.day > max_day {
    invalid_iso8601_date_time("day is not valid for the calendar month")
  }
  validate_iso8601_time_of_day_fields(
    dt.hour,
    dt.minute,
    dt.second,
    dt.millisecond,
    IsoDateTime,
  )
}

///|
fn parse_iso8601_time_fields(
  raw : String,
  start : Int,
  end : Int,
  kind : IsoLexicalKind,
) -> TimeOfDay raise @opc_errors.SchemaViolation {
  if end - start < 5 {
    invalid_iso8601(kind, "time-of-day is shorter than HH:MM")
  }
  let hour = parse_iso_fixed_int(raw, start, start + 2, "hour", kind)
  require_iso_char(raw, start + 2, ':', "time separator", kind)
  let minute = parse_iso_fixed_int(raw, start + 3, start + 5, "minute", kind)
  let mut second = 0
  let mut millisecond = 0
  if end == start + 5 {
    ()
  } else {
    require_iso_char(raw, start + 5, ':', "time separator", kind)
    if end - start < 8 {
      invalid_iso8601(kind, "time-of-day is shorter than HH:MM:SS")
    }
    second = parse_iso_fixed_int(raw, start + 6, start + 8, "second", kind)
    if end == start + 8 {
      ()
    } else {
      require_iso_char(raw, start + 8, '.', "fractional second separator", kind)
      millisecond = parse_iso_fraction_millis(raw, start + 9, end, kind)
    }
  }
  let value = TimeOfDay::{ hour, minute, second, millisecond }
  validate_iso8601_time_of_day(value, kind)
  value
}

///|
fn validate_iso8601_time_of_day(
  value : TimeOfDay,
  kind : IsoLexicalKind,
) -> Unit raise @opc_errors.SchemaViolation {
  validate_iso8601_time_of_day_fields(
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    kind,
  )
}

///|
fn validate_iso8601_time_of_day_fields(
  hour : Int,
  minute : Int,
  second : Int,
  millisecond : Int,
  kind : IsoLexicalKind,
) -> Unit raise @opc_errors.SchemaViolation {
  if hour < 0 ||
    hour > 23 ||
    minute < 0 ||
    minute > 59 ||
    second < 0 ||
    second > 59 ||
    millisecond < 0 ||
    millisecond > 999 {
    invalid_iso8601(kind, "time-of-day is outside the §18.17.4 range")
  }
}

///|
fn parse_iso_fixed_int(
  raw : String,
  start : Int,
  end : Int,
  field : String,
  kind : IsoLexicalKind,
) -> Int raise @opc_errors.SchemaViolation {
  if raw.length() < end {
    invalid_iso8601(kind, "value is truncated while reading " + field)
  }
  let mut out = 0
  for index in start..<end {
    let ch = raw.code_unit_at(index)
    if ch < '0' || ch > '9' {
      invalid_iso8601(kind, field + " contains a non-digit")
    }
    out = out * 10 + (ch.to_int() - '0'.to_int())
  }
  out
}

///|
fn require_iso_char(
  raw : String,
  index : Int,
  expected : Char,
  field : String,
  kind : IsoLexicalKind,
) -> Unit raise @opc_errors.SchemaViolation {
  if raw.length() <= index ||
    raw.code_unit_at(index).to_int() != expected.to_int() {
    invalid_iso8601(kind, "invalid " + field)
  }
}

///|
fn parse_iso_fraction_millis(
  raw : String,
  start : Int,
  end : Int,
  kind : IsoLexicalKind,
) -> Int raise @opc_errors.SchemaViolation {
  if start >= end {
    invalid_iso8601(kind, "fractional second is empty")
  }
  let mut millis = 0
  let mut scale = 100
  for index in start..<end {
    let ch = raw.code_unit_at(index)
    if ch < '0' || ch > '9' {
      invalid_iso8601(kind, "fractional second contains a non-digit")
    }
    if scale > 0 {
      millis = millis + (ch.to_int() - '0'.to_int()) * scale
      scale = scale / 10
    }
  }
  millis
}

///|
fn invalid_iso8601(
  kind : IsoLexicalKind,
  reason : String,
) -> Unit raise @opc_errors.SchemaViolation {
  match kind {
    IsoDateTime => invalid_iso8601_date_time(reason)
    IsoTimeOfDay => invalid_iso8601_time_of_day(reason)
  }
}

///|
fn invalid_iso8601_date_time(
  reason : String,
) -> Unit raise @opc_errors.SchemaViolation {
  raise @opc_errors.SchemaViolation(
    section="Part 1 §18.17.4",
    path="ISO 8601 date-time",
    reason~,
  )
}

///|
fn invalid_iso8601_time_of_day(
  reason : String,
) -> Unit raise @opc_errors.SchemaViolation {
  raise @opc_errors.SchemaViolation(
    section="Part 1 §18.17.4",
    path="ISO 8601 time-of-day",
    reason~,
  )
}

///|
fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 => if is_leap_year_gregorian(year) { 29 } else { 28 }
    _ => 0
  }
}

///|
fn is_lotus_1900_phantom(dt : CalendarDateTime, system : DateSystem) -> Bool {
  system == Serial1900 && dt.year == 1900 && dt.month == 2 && dt.day == 29
}

///|
fn serial_day_to_calendar_day(serial_day : Int, system : DateSystem) -> Int {
  match system {
    Serial1900 => base_day(system) + serial_day
    Serial1904 => base_day(system) + serial_day
  }
}

///|
fn calendar_day_to_serial_day(day : Int, system : DateSystem) -> Int {
  day - base_day(system)
}

///|
fn days_from_civil(year : Int, month : Int, day : Int) -> Int {
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
fn civil_from_days(z : Int) -> CivilDate {
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
  { year: year + (if month <= 2 { 1 } else { 0 }), month, day }
}
