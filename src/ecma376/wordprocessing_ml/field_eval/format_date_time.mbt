///|
/// Part 1 §17.16.4.1 — render a CalendarDateTime using a `\@` switch
/// format string. Recognised placeholders:
///
/// - `yyyy` / `yy` — 4 / 2-digit year.
/// - `MMMM` / `MMM` / `MM` / `M` — full / short month name, padded /
///   bare numeric month.
/// - `dddd` / `ddd` — full / short weekday name.
/// - `dd` / `d` — padded / bare day-of-month.
/// - `HH` / `H` — 24-hour, padded / bare.
/// - `hh` / `h` — 12-hour, padded / bare.
/// - `mm` / `m` — minute, padded / bare (only after `H*`/`h*`).
/// - `ss` / `s` — second, padded / bare (only after `m*`).
/// - `am/pm` / `AM/PM` (case-insensitive) — meridian marker.
/// - `'literal'` — single-quoted literal text passed through verbatim.
///
/// Anything not matched is emitted literally.
pub fn format_date_time(
  template : String,
  date : @date_serial.CalendarDateTime,
) -> String {
  let buf = StringBuilder::new()
  let mut i = 0
  let mut after_hour = false
  let mut after_minute = false
  while i < template.length() {
    if try_match(template, i, "'") {
      let (literal, next_i) = read_single_quoted(template, i + 1)
      buf.write_string(literal)
      i = next_i
      continue
    }
    if try_match(template, i, "am/pm") {
      buf.write_string(meridian(date, false))
      i = i + 5
      continue
    }
    if try_match(template, i, "AM/PM") {
      buf.write_string(meridian(date, true))
      i = i + 5
      continue
    }
    if try_match(template, i, "yyyy") {
      buf.write_string(pad_int(date.year, 4))
      i = i + 4
      continue
    }
    if try_match(template, i, "yy") {
      buf.write_string(pad_int(date.year % 100, 2))
      i = i + 2
      continue
    }
    if try_match(template, i, "MMMM") {
      buf.write_string(full_month_name(date.month))
      i = i + 4
      continue
    }
    if try_match(template, i, "MMM") {
      buf.write_string(short_month_name(date.month))
      i = i + 3
      continue
    }
    if try_match(template, i, "MM") {
      buf.write_string(pad_int(date.month, 2))
      i = i + 2
      continue
    }
    if try_match(template, i, "M") {
      buf.write_string(date.month.to_string())
      i = i + 1
      continue
    }
    if try_match(template, i, "dddd") {
      buf.write_string(full_weekday_name(date))
      i = i + 4
      continue
    }
    if try_match(template, i, "ddd") {
      buf.write_string(short_weekday_name(date))
      i = i + 3
      continue
    }
    if try_match(template, i, "dd") {
      buf.write_string(pad_int(date.day, 2))
      i = i + 2
      continue
    }
    if try_match(template, i, "d") {
      buf.write_string(date.day.to_string())
      i = i + 1
      continue
    }
    if try_match(template, i, "HH") {
      buf.write_string(pad_int(date.hour, 2))
      after_hour = true
      after_minute = false
      i = i + 2
      continue
    }
    if try_match(template, i, "H") {
      buf.write_string(date.hour.to_string())
      after_hour = true
      after_minute = false
      i = i + 1
      continue
    }
    if try_match(template, i, "hh") {
      buf.write_string(pad_int(hour_12(date.hour), 2))
      after_hour = true
      after_minute = false
      i = i + 2
      continue
    }
    if try_match(template, i, "h") {
      buf.write_string(hour_12(date.hour).to_string())
      after_hour = true
      after_minute = false
      i = i + 1
      continue
    }
    if after_hour {
      if try_match(template, i, "mm") {
        buf.write_string(pad_int(date.minute, 2))
        after_minute = true
        after_hour = false
        i = i + 2
        continue
      }
      if try_match(template, i, "m") {
        buf.write_string(date.minute.to_string())
        after_minute = true
        after_hour = false
        i = i + 1
        continue
      }
    }
    if after_minute {
      if try_match(template, i, "ss") {
        buf.write_string(pad_int(date.second, 2))
        after_minute = false
        i = i + 2
        continue
      }
      if try_match(template, i, "s") {
        buf.write_string(date.second.to_string())
        after_minute = false
        i = i + 1
        continue
      }
    }
    let unit = template.code_unit_at(i).to_int()
    buf.write_char(unit.to_char().unwrap())
    i = i + 1
  }
  buf.to_string()
}

///|
fn try_match(template : String, pos : Int, needle : String) -> Bool {
  if pos + needle.length() > template.length() {
    return false
  }
  for i in 0..<needle.length() {
    if template.code_unit_at(pos + i) != needle.code_unit_at(i) {
      return false
    }
  }
  true
}

///|
fn read_single_quoted(template : String, start : Int) -> (String, Int) {
  let buf = StringBuilder::new()
  let mut i = start
  while i < template.length() {
    let unit = template.code_unit_at(i).to_int()
    if unit == 0x27 {
      return (buf.to_string(), i + 1)
    }
    buf.write_char(unit.to_char().unwrap())
    i = i + 1
  }
  (buf.to_string(), i)
}

///|
fn pad_int(value : Int, width : Int) -> String {
  let text = value.to_string()
  if text.length() >= width {
    text
  } else {
    let buf = StringBuilder::new()
    for _ in 0..<(width - text.length()) {
      buf.write_char('0')
    }
    buf.write_string(text)
    buf.to_string()
  }
}

///|
fn hour_12(hour : Int) -> Int {
  let h = hour % 12
  if h == 0 {
    12
  } else {
    h
  }
}

///|
fn meridian(date : @date_serial.CalendarDateTime, upper : Bool) -> String {
  if date.hour < 12 {
    if upper {
      "AM"
    } else {
      "am"
    }
  } else if upper {
    "PM"
  } else {
    "pm"
  }
}

///|
fn full_month_name(month : Int) -> String {
  match month {
    1 => "January"
    2 => "February"
    3 => "March"
    4 => "April"
    5 => "May"
    6 => "June"
    7 => "July"
    8 => "August"
    9 => "September"
    10 => "October"
    11 => "November"
    12 => "December"
    _ => month.to_string()
  }
}

///|
fn short_month_name(month : Int) -> String {
  match month {
    1 => "Jan"
    2 => "Feb"
    3 => "Mar"
    4 => "Apr"
    5 => "May"
    6 => "Jun"
    7 => "Jul"
    8 => "Aug"
    9 => "Sep"
    10 => "Oct"
    11 => "Nov"
    12 => "Dec"
    _ => month.to_string()
  }
}

///|
fn full_weekday_name(date : @date_serial.CalendarDateTime) -> String {
  match weekday_index(date) {
    0 => "Sunday"
    1 => "Monday"
    2 => "Tuesday"
    3 => "Wednesday"
    4 => "Thursday"
    5 => "Friday"
    6 => "Saturday"
    _ => ""
  }
}

///|
fn short_weekday_name(date : @date_serial.CalendarDateTime) -> String {
  match weekday_index(date) {
    0 => "Sun"
    1 => "Mon"
    2 => "Tue"
    3 => "Wed"
    4 => "Thu"
    5 => "Fri"
    6 => "Sat"
    _ => ""
  }
}

///|
/// Sunday-anchored weekday index for a CalendarDateTime using the
/// Fliegel/Van Flandern Julian day formula. Returns 0..6 with 0 =
/// Sunday.
fn weekday_index(date : @date_serial.CalendarDateTime) -> Int {
  let a = (14 - date.month) / 12
  let y = date.year + 4800 - a
  let m = date.month + 12 * a - 3
  let jdn = date.day +
    (153 * m + 2) / 5 +
    365 * y +
    y / 4 -
    y / 100 +
    y / 400 -
    32045
  (jdn + 1) % 7
}
