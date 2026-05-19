///|
/// Part 1 §17.16.4.3 — apply the `\*` general-formatting switch to a
/// text value. Supported switch arguments (case-insensitive on the
/// switch name itself, per §17.16.4.3):
///
/// - `Upper`, `Lower`, `FirstCap`, `Caps` — text casing transforms.
/// - `Arabic`, `ArabicDash`, `Roman`, `roman`, `AlphabeticUpper`,
///   `alphabetic`, `CardText`, `OrdText`, `Ordinal`, `Hex`,
///   `DollarText` — numeric formats (delegated to
///   `@domain.ST_NumberFormat::format` so this evaluator does not
///   duplicate the roman / letter / ordinal logic).
/// - `MERGEFORMAT`, `CHARFORMAT` — no-ops at the text level
///   (they tell the renderer to inherit formatting from the field
///   result or the field code respectively).
///
/// Returns the input unchanged when the switch argument is not
/// recognised.
pub fn apply_general_switch(value : String, switch_arg : String) -> String {
  match switch_arg {
    "Upper" => value.to_upper()
    "Lower" => value.to_lower()
    "FirstCap" => first_cap(value)
    "Caps" => caps_each_word(value)
    "Arabic" => format_number_switch(value, @domain.NumFmtDecimal)
    "ArabicDash" =>
      "- " + format_number_switch(value, @domain.NumFmtDecimal) + " -"
    "Roman" => format_number_switch(value, @domain.NumFmtUpperRoman)
    "roman" => format_number_switch(value, @domain.NumFmtLowerRoman)
    "AlphabeticUpper" => format_number_switch(value, @domain.NumFmtUpperLetter)
    "alphabetic" => format_number_switch(value, @domain.NumFmtLowerLetter)
    "CardText" => format_number_switch(value, @domain.NumFmtCardinalText)
    "OrdText" => format_number_switch(value, @domain.NumFmtOrdinalText)
    "Ordinal" => format_number_switch(value, @domain.NumFmtOrdinal)
    "Hex" => format_hex(value)
    "DollarText" => format_dollar_text(value)
    "MERGEFORMAT" => value
    "CHARFORMAT" => value
    _ => value
  }
}

///|
/// Apply every `\*` switch in document order. Each switch sees the
/// previous switch's output, so chained switches like
/// `\* Upper \* MERGEFORMAT` first upper-case then pass through.
pub fn apply_general_switches(
  value : String,
  switches : Array[FieldSwitch],
) -> String {
  let mut current = value
  for entry in switches {
    if entry.flag == '*' {
      match entry.argument {
        Some(arg) => current = apply_general_switch(current, arg)
        None => ()
      }
    }
  }
  current
}

///|
fn first_cap(value : String) -> String {
  if value.length() == 0 {
    return value
  }
  let first_unit = value.code_unit_at(0).to_int()
  let upper_first = ascii_upper(first_unit)
  let buf = StringBuilder::new()
  buf.write_char(upper_first.to_char().unwrap())
  if value.length() > 1 {
    let rest = value.unsafe_substring(start=1, end=value.length())
    buf.write_string(rest.to_lower())
  }
  buf.to_string()
}

///|
fn caps_each_word(value : String) -> String {
  let buf = StringBuilder::new()
  let mut at_word_start = true
  for i in 0..<value.length() {
    let unit = value.code_unit_at(i).to_int()
    let is_space = unit == 0x20 || unit == 0x09 || unit == 0x0A || unit == 0x0D
    if is_space {
      buf.write_char(unit.to_char().unwrap())
      at_word_start = true
    } else if at_word_start {
      buf.write_char(ascii_upper(unit).to_char().unwrap())
      at_word_start = false
    } else {
      buf.write_char(ascii_lower(unit).to_char().unwrap())
    }
  }
  buf.to_string()
}

///|
fn ascii_upper(unit : Int) -> Int {
  if unit >= 0x61 && unit <= 0x7A {
    unit - 0x20
  } else {
    unit
  }
}

///|
fn ascii_lower(unit : Int) -> Int {
  if unit >= 0x41 && unit <= 0x5A {
    unit + 0x20
  } else {
    unit
  }
}

///|
fn format_number_switch(
  value : String,
  format : @domain.ST_NumberFormat,
) -> String {
  match parse_int_lenient(value) {
    Some(n) => format.format(n)
    None => value
  }
}

///|
fn format_hex(value : String) -> String {
  match parse_int_lenient(value) {
    Some(n) => int_to_hex(n)
    None => value
  }
}

///|
fn int_to_hex(value : Int) -> String {
  if value == 0 {
    return "0"
  }
  let buf = StringBuilder::new()
  let mut remaining = if value < 0 { -value } else { value }
  let digits : Array[Char] = []
  while remaining > 0 {
    let nibble = remaining % 16
    let ch = if nibble < 10 {
      (0x30 + nibble).to_char().unwrap()
    } else {
      (0x41 + nibble - 10).to_char().unwrap()
    }
    digits.push(ch)
    remaining = remaining / 16
  }
  if value < 0 {
    buf.write_char('-')
  }
  let mut i = digits.length() - 1
  while i >= 0 {
    buf.write_char(digits[i])
    i = i - 1
  }
  buf.to_string()
}

///|
fn format_dollar_text(value : String) -> String {
  match parse_int_lenient(value) {
    Some(n) => @domain.NumFmtCardinalText.format(n) + " and 00/100"
    None => value
  }
}

///|
fn parse_int_lenient(text : String) -> Int? {
  let trimmed = trim_text(text)
  if trimmed.length() == 0 {
    return None
  }
  let mut start = 0
  let mut negative = false
  let first = trimmed.code_unit_at(0).to_int()
  if first == 0x2D {
    negative = true
    start = 1
  } else if first == 0x2B {
    start = 1
  }
  if start >= trimmed.length() {
    return None
  }
  let mut value = 0
  for i in start..<trimmed.length() {
    let unit = trimmed.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10 + (unit - 0x30)
  }
  if negative {
    Some(-value)
  } else {
    Some(value)
  }
}

///|
fn trim_text(text : String) -> String {
  let mut start = 0
  while start < text.length() {
    let unit = text.code_unit_at(start).to_int()
    if unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D {
      break
    }
    start = start + 1
  }
  let mut end = text.length()
  while end > start {
    let unit = text.code_unit_at(end - 1).to_int()
    if unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D {
      break
    }
    end = end - 1
  }
  text.unsafe_substring(start~, end~)
}
