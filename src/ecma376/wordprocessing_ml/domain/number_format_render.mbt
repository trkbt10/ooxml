// WordprocessingML §17.18.59 ST_NumberFormat counter rendering.
// Methods on ST_NumberFormat must live in the type's owning package;
// the lvlText substitution and resolver pipeline both live in
// numbering_resolver and depend on this format() helper.

///|
/// Part 1 §17.18.59 ST_NumberFormat — render an integer counter using
/// this format. Bullet and none return the empty string so callers can
/// substitute the literal lvlText for bullets and skip the counter for
/// none. Formats outside the directly supported numeric / letter /
/// roman / ordinal / english-text repertoire fall back to decimal so
/// renderers always get a non-empty value; the spec's regional script
/// formats (japanese, hindi, thai, ...) are placeholders pending
/// per-locale glyph tables.
pub fn ST_NumberFormat::format(self : ST_NumberFormat, value : Int) -> String {
  match self {
    NumFmtDecimal => value.to_string()
    NumFmtDecimalZero =>
      if value < 10 {
        "0" + value.to_string()
      } else {
        value.to_string()
      }
    NumFmtUpperRoman => render_roman(value, true)
    NumFmtLowerRoman => render_roman(value, false)
    NumFmtUpperLetter => render_letter(value, true)
    NumFmtLowerLetter => render_letter(value, false)
    NumFmtOrdinal => render_ordinal(value)
    NumFmtCardinalText => render_cardinal_text(value)
    NumFmtOrdinalText => render_ordinal_text(value)
    NumFmtBullet => ""
    NumFmtNone => ""
    _ => value.to_string()
  }
}

///|
/// Roman-numeral conversion shared by `NumFmtUpperRoman` /
/// `NumFmtLowerRoman`. Supports 1..3999 with the standard subtractive
/// notation; values outside that range fall back to decimal so callers
/// always get a non-empty string.
fn render_roman(value : Int, upper : Bool) -> String {
  if value < 1 || value > 3999 {
    return value.to_string()
  }
  let symbols_upper = [
    "M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I",
  ]
  let symbols_lower = [
    "m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i",
  ]
  let values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
  let symbols = if upper { symbols_upper } else { symbols_lower }
  let buf = StringBuilder::new()
  let mut remaining = value
  for i in 0..<values.length() {
    while remaining >= values[i] {
      buf.write_string(symbols[i])
      remaining = remaining - values[i]
    }
  }
  buf.to_string()
}

///|
/// Spreadsheet-style letter conversion shared by `NumFmtUpperLetter` /
/// `NumFmtLowerLetter`. 1 -> A, 26 -> Z, 27 -> AA, 53 -> BA, ...
fn render_letter(value : Int, upper : Bool) -> String {
  if value < 1 {
    return value.to_string()
  }
  let base : Int = if upper { 0x41 } else { 0x61 }
  let buf : Array[Int] = []
  let mut remaining = value
  while remaining > 0 {
    let zero_based = (remaining - 1) % 26
    buf.push(base + zero_based)
    remaining = (remaining - 1) / 26
  }
  let chars : Array[Char] = []
  let mut i = buf.length() - 1
  while i >= 0 {
    chars.push(buf[i].to_char().unwrap())
    i = i - 1
  }
  let sb = StringBuilder::new()
  for ch in chars {
    sb.write_char(ch)
  }
  sb.to_string()
}

///|
/// English ordinal suffix table. Word's `ordinal` rule: 1st, 2nd, 3rd,
/// 4th, ... with the 11/12/13 exception.
fn render_ordinal(value : Int) -> String {
  let suffix = ordinal_suffix(value)
  value.to_string() + suffix
}

///|
fn ordinal_suffix(value : Int) -> String {
  let abs_v = if value < 0 { -value } else { value }
  let last_two = abs_v % 100
  if last_two >= 11 && last_two <= 13 {
    return "th"
  }
  let last = abs_v % 10
  if last == 1 {
    "st"
  } else if last == 2 {
    "nd"
  } else if last == 3 {
    "rd"
  } else {
    "th"
  }
}

///|
/// English cardinal text for the 0..20 range. Outside that range the
/// formatter falls back to decimal because the spec's "cardinalText"
/// behaviour beyond 20 is locale-dependent.
fn render_cardinal_text(value : Int) -> String {
  let table = [
    "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
    "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen",
    "Eighteen", "Nineteen", "Twenty",
  ]
  if value >= 0 && value < table.length() {
    table[value]
  } else {
    value.to_string()
  }
}

///|
/// English ordinal text for the 0..20 range with the same fall-back.
fn render_ordinal_text(value : Int) -> String {
  let table = [
    "Zeroth", "First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh",
    "Eighth", "Ninth", "Tenth", "Eleventh", "Twelfth", "Thirteenth", "Fourteenth",
    "Fifteenth", "Sixteenth", "Seventeenth", "Eighteenth", "Nineteenth", "Twentieth",
  ]
  if value >= 0 && value < table.length() {
    table[value]
  } else {
    value.to_string()
  }
}
