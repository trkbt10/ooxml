///|
/// Part 1 §17.16.4.2 — apply a WordprocessingML field numeric-picture
/// switch (`\#`) to a numeric field value. This is scoped deliberately to
/// field instructions; SpreadsheetML cell `numFmt` remains owned by
/// SpreadsheetML and is not a source of truth for WML field switches.
fn format_numeric_picture(value : Double, picture : String) -> String {
  if value.is_nan() || value.is_inf() {
    return value.to_string()
  }
  let (section, automatic_negative) = select_numeric_picture_section(
    value, picture,
  )
  let clean_section = strip_numeric_picture_directives(section)
  match numeric_picture_span(clean_section) {
    Some(span) => {
      let (start, end_) = span
      let prefix = numeric_picture_literal(clean_section, 0, start)
      let core = clean_section.unsafe_substring(start~, end=end_)
      let suffix = numeric_picture_literal(
        clean_section,
        end_,
        clean_section.length(),
      )
      let sign = if automatic_negative && value < 0.0 { "-" } else { "" }
      let magnitude = if value < 0.0 { -value } else { value }
      let percent_count = count_percent_markers(clean_section)
      let scaled = scale_for_percent_markers(magnitude, percent_count)
      sign + prefix + format_numeric_picture_core(scaled, core) + suffix
    }
    None => numeric_picture_literal(clean_section, 0, clean_section.length())
  }
}

///|
fn select_numeric_picture_section(
  value : Double,
  picture : String,
) -> (String, Bool) {
  let sections = split_numeric_picture_sections(picture)
  if value < 0.0 && sections.length() >= 2 {
    (sections[1], false)
  } else if value == 0.0 && sections.length() >= 3 {
    (sections[2], false)
  } else if sections.length() > 0 {
    (sections[0], true)
  } else {
    (picture, true)
  }
}

///|
fn split_numeric_picture_sections(picture : String) -> Array[String] {
  let sections : Array[String] = []
  let buf = StringBuilder::new()
  let mut in_quote = false
  let mut i = 0
  while i < picture.length() {
    let c = picture.code_unit_at(i).to_int()
    if c == 0x5C && i + 1 < picture.length() {
      buf.write_char(c.to_char().unwrap())
      i = i + 1
      buf.write_char(picture.code_unit_at(i).to_int().to_char().unwrap())
    } else if c == 0x22 {
      in_quote = !in_quote
      buf.write_char('"')
    } else if c == 0x3B && !in_quote {
      sections.push(buf.to_string())
      buf.reset()
    } else {
      buf.write_char(c.to_char().unwrap())
    }
    i = i + 1
  }
  sections.push(buf.to_string())
  sections
}

///|
fn strip_numeric_picture_directives(section : String) -> String {
  let out = StringBuilder::new()
  let mut i = 0
  while i < section.length() {
    let c = section.code_unit_at(i).to_int()
    if c == 0x5B {
      i = i + 1
      while i < section.length() && section.code_unit_at(i).to_int() != 0x5D {
        i = i + 1
      }
    } else {
      out.write_char(c.to_char().unwrap())
    }
    i = i + 1
  }
  out.to_string()
}

///|
fn numeric_picture_span(section : String) -> (Int, Int)? {
  let mut first = -1
  let mut last = -1
  for i in 0..<section.length() {
    let c = section.code_unit_at(i).to_int()
    if c == 0x30 || c == 0x23 || c == 0x3F {
      if first < 0 {
        first = i
      }
      last = i
    }
  }
  if first < 0 {
    None
  } else {
    let mut start = first
    while start > 0 {
      let c = section.code_unit_at(start - 1).to_int()
      if c == 0x2C || c == 0x2E {
        start = start - 1
      } else {
        break
      }
    }
    let mut end_ = last + 1
    while end_ < section.length() {
      let c = section.code_unit_at(end_).to_int()
      if c == 0x2C || c == 0x2E {
        end_ = end_ + 1
      } else {
        break
      }
    }
    Some((start, end_))
  }
}

///|
fn numeric_picture_literal(section : String, start : Int, end_ : Int) -> String {
  let out = StringBuilder::new()
  let mut i = start
  while i < end_ {
    let c = section.code_unit_at(i).to_int()
    if c == 0x22 {
      i = i + 1
      while i < end_ && section.code_unit_at(i).to_int() != 0x22 {
        out.write_char(section.code_unit_at(i).to_int().to_char().unwrap())
        i = i + 1
      }
    } else if c == 0x5C && i + 1 < end_ {
      i = i + 1
      out.write_char(section.code_unit_at(i).to_int().to_char().unwrap())
    } else if (c == 0x5F || c == 0x2A) && i + 1 < end_ {
      i = i + 1
    } else {
      out.write_char(c.to_char().unwrap())
    }
    i = i + 1
  }
  out.to_string()
}

///|
fn count_percent_markers(section : String) -> Int {
  let mut count = 0
  let mut in_quote = false
  let mut i = 0
  while i < section.length() {
    let c = section.code_unit_at(i).to_int()
    if c == 0x5C && i + 1 < section.length() {
      i = i + 2
      continue
    }
    if c == 0x22 {
      in_quote = !in_quote
    } else if c == 0x25 && !in_quote {
      count = count + 1
    }
    i = i + 1
  }
  count
}

///|
fn scale_for_percent_markers(value : Double, count : Int) -> Double {
  let mut scaled = value
  for _ in 0..<count {
    scaled = scaled * 100.0
  }
  scaled
}

///|
fn format_numeric_picture_core(value : Double, core : String) -> String {
  let decimal = decimal_point_index(core)
  let integer_pattern = match decimal {
    Some(i) => core.unsafe_substring(start=0, end=i)
    None => core
  }
  let fraction_pattern = match decimal {
    Some(i) => core.unsafe_substring(start=i + 1, end=core.length())
    None => ""
  }
  let frac_digits = count_digit_placeholders(fraction_pattern)
  let min_frac_digits = count_mandatory_placeholders(fraction_pattern)
  let scale = pow10_int64(frac_digits)
  let rounded = (value * scale.to_double()).round().to_int64()
  let integer_part = rounded / scale
  let fraction_part = rounded % scale
  let min_integer_digits = count_mandatory_placeholders(integer_pattern)
  let mut integer_text = integer_part.to_string()
  if integer_part == 0L && min_integer_digits == 0 && frac_digits > 0 {
    integer_text = ""
  }
  while integer_text.length() < min_integer_digits {
    integer_text = "0" + integer_text
  }
  if integer_pattern_uses_grouping(integer_pattern) {
    integer_text = group_integer_digits(integer_text)
  }
  if frac_digits == 0 {
    return integer_text
  }
  let mut fraction_text = fraction_part.to_string()
  while fraction_text.length() < frac_digits {
    fraction_text = "0" + fraction_text
  }
  while fraction_text.length() > min_frac_digits &&
        fraction_text.code_unit_at(fraction_text.length() - 1).to_int() == 0x30 {
    fraction_text = fraction_text.unsafe_substring(
      start=0,
      end=fraction_text.length() - 1,
    )
  }
  if fraction_text.length() == 0 {
    integer_text
  } else {
    integer_text + "." + fraction_text
  }
}

///|
fn decimal_point_index(core : String) -> Int? {
  for i in 0..<core.length() {
    if core.code_unit_at(i).to_int() == 0x2E {
      return Some(i)
    }
  }
  None
}

///|
fn count_digit_placeholders(pattern : String) -> Int {
  let mut count = 0
  for i in 0..<pattern.length() {
    let c = pattern.code_unit_at(i).to_int()
    if c == 0x30 || c == 0x23 || c == 0x3F {
      count = count + 1
    }
  }
  count
}

///|
fn count_mandatory_placeholders(pattern : String) -> Int {
  let mut count = 0
  for i in 0..<pattern.length() {
    if pattern.code_unit_at(i).to_int() == 0x30 {
      count = count + 1
    }
  }
  count
}

///|
fn integer_pattern_uses_grouping(pattern : String) -> Bool {
  for i in 0..<pattern.length() {
    if pattern.code_unit_at(i).to_int() == 0x2C {
      return true
    }
  }
  false
}

///|
fn group_integer_digits(text : String) -> String {
  if text.length() <= 3 {
    return text
  }
  let out = StringBuilder::new()
  let first_group = text.length() % 3
  let mut i = 0
  if first_group > 0 {
    out.write_string(text.unsafe_substring(start=0, end=first_group))
    i = first_group
    if i < text.length() {
      out.write_char(',')
    }
  }
  while i < text.length() {
    out.write_string(text.unsafe_substring(start=i, end=i + 3))
    i = i + 3
    if i < text.length() {
      out.write_char(',')
    }
  }
  out.to_string()
}

///|
fn pow10_int64(digits : Int) -> Int64 {
  let mut value = 1L
  for _ in 0..<digits {
    value = value * 10L
  }
  value
}

///|
fn parse_field_numeric_value(text : String) -> Double? {
  let trimmed = trim_text(text)
  if trimmed.length() == 0 {
    return None
  }
  let mut i = 0
  let mut negative = false
  let first = trimmed.code_unit_at(0).to_int()
  if first == 0x2D {
    negative = true
    i = 1
  } else if first == 0x2B {
    i = 1
  }
  let mut saw_digit = false
  let mut value = 0.0
  while i < trimmed.length() {
    let c = trimmed.code_unit_at(i).to_int()
    if c == 0x2C {
      i = i + 1
      continue
    }
    if c == 0x2E {
      i = i + 1
      break
    }
    if c < 0x30 || c > 0x39 {
      return None
    }
    saw_digit = true
    value = value * 10.0 + (c - 0x30).to_double()
    i = i + 1
  }
  let mut place = 0.1
  while i < trimmed.length() {
    let c = trimmed.code_unit_at(i).to_int()
    if c < 0x30 || c > 0x39 {
      return None
    }
    saw_digit = true
    value = value + (c - 0x30).to_double() * place
    place = place / 10.0
    i = i + 1
  }
  if !saw_digit {
    None
  } else if negative {
    Some(-value)
  } else {
    Some(value)
  }
}
