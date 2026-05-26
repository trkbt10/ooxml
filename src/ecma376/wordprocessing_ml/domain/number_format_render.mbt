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
  // §17.18.59 ST_NumberFormat — closed-60 enum.  Every variant
  // is matched explicitly below; regional script systems that
  // require dedicated glyph tables (Hindi, Thai, Chinese,
  // Japanese kanji, Korean, Hebrew, Arabic, Vietnamese, …) fall
  // through to decimal with a comment marking them as
  // pending — the spec wording for these formats describes the
  // glyph mapping but defers to locale fonts, so the
  // arabic-digit fallback is the closest spec-permitted
  // degradation until the per-locale tables land.
  match self {
    // §17.18.59 numeric / latin formats — fully implemented.
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
    NumFmtHex => render_hex(value)
    NumFmtChicago => render_chicago(value)
    NumFmtDecimalFullWidth => render_full_width_digits(value)
    NumFmtDecimalFullWidth2 => render_full_width_digits(value)
    NumFmtDecimalHalfWidth => value.to_string()
    NumFmtDecimalEnclosedCircle => render_enclosed_circle(value)
    NumFmtDecimalEnclosedCircleChinese => render_enclosed_circle(value)
    NumFmtIdeographEnclosedCircle => render_enclosed_circle(value)
    NumFmtDecimalEnclosedFullstop => value.to_string() + "."
    NumFmtDecimalEnclosedParen => "(" + value.to_string() + ")"
    NumFmtNumberInDash => "- " + value.to_string() + " -"
    // §17.18.59 regional script formats — Hindi / Thai / CJK /
    // Hebrew / Arabic / Vietnamese / Russian require dedicated
    // glyph tables that we do not yet ship; render arabic
    // digits and surface the spec format name as
    // `data-ooxml-numfmt` metadata upstream so consumers can
    // substitute the correct glyphs themselves.
    NumFmtIdeographDigital => value.to_string()
    NumFmtIdeographTraditional => value.to_string()
    NumFmtIdeographZodiac => value.to_string()
    NumFmtIdeographZodiacTraditional => value.to_string()
    NumFmtIdeographLegalTraditional => value.to_string()
    NumFmtJapaneseCounting => value.to_string()
    NumFmtJapaneseLegal => value.to_string()
    NumFmtJapaneseDigitalTenThousand => value.to_string()
    NumFmtAiueo => value.to_string()
    NumFmtAiueoFullWidth => value.to_string()
    NumFmtIroha => value.to_string()
    NumFmtIrohaFullWidth => value.to_string()
    NumFmtGanada => value.to_string()
    NumFmtChosung => value.to_string()
    NumFmtTaiwaneseCounting => value.to_string()
    NumFmtTaiwaneseCountingThousand => value.to_string()
    NumFmtTaiwaneseDigital => value.to_string()
    NumFmtChineseCounting => value.to_string()
    NumFmtChineseLegalSimplified => value.to_string()
    NumFmtChineseCountingThousand => value.to_string()
    NumFmtKoreanDigital => value.to_string()
    NumFmtKoreanCounting => value.to_string()
    NumFmtKoreanLegal => value.to_string()
    NumFmtKoreanDigital2 => value.to_string()
    NumFmtVietnameseCounting => value.to_string()
    NumFmtRussianLower => value.to_string()
    NumFmtRussianUpper => value.to_string()
    NumFmtHebrew1 => value.to_string()
    NumFmtHebrew2 => value.to_string()
    NumFmtArabicAlpha => value.to_string()
    NumFmtArabicAbjad => value.to_string()
    NumFmtHindiVowels => value.to_string()
    NumFmtHindiConsonants => value.to_string()
    NumFmtHindiNumbers => value.to_string()
    NumFmtHindiCounting => value.to_string()
    NumFmtThaiLetters => value.to_string()
    NumFmtThaiNumbers => value.to_string()
    NumFmtThaiCounting => value.to_string()
    // §17.18.59 currency text formats — `bahtText` and
    // `dollarText` spell the value out as currency words; we
    // render arabic digits until the spell-out tables land.
    NumFmtBahtText => value.to_string()
    NumFmtDollarText => value.to_string()
    // §17.18.59 `custom` — the consumer supplies the format
    // string via `<w:lvlText>`.  Return the raw arabic digit so
    // the caller's substitution machinery has a non-empty token
    // to splice in.
    NumFmtCustom => value.to_string()
  }
}

///|
/// §17.18.59 `hex` — render the value in uppercase hexadecimal
/// without a `0x` prefix.  Spec example: `255` → `"FF"`.
fn render_hex(value : Int) -> String {
  if value < 0 {
    return "-" + render_hex(-value)
  }
  if value == 0 {
    return "0"
  }
  let buf : Array[Char] = []
  let mut n = value
  while n > 0 {
    let idx = n % 16
    let ch = if idx < 10 {
      (0x30 + idx).unsafe_to_char()
    } else {
      (0x41 + (idx - 10)).unsafe_to_char()
    }
    buf.push(ch)
    n = n / 16
  }
  let out = StringBuilder::new()
  for i in 0..<buf.length() {
    out.write_char(buf[buf.length() - 1 - i])
  }
  out.to_string()
}

///|
/// §17.18.59 `chicago` — Chicago Manual of Style footnote
/// sequence: `*`, `†`, `‡`, `§`, `‖`, `¶`, then doubled (`**`, …),
/// tripled, etc.  Index is 1-based.
fn render_chicago(value : Int) -> String {
  if value < 1 {
    return value.to_string()
  }
  let symbols = ["*", "†", "‡", "§", "‖", "¶"]
  let n = symbols.length()
  let group = (value - 1) / n + 1
  let pos = (value - 1) % n
  let sym = symbols[pos]
  let buf = StringBuilder::new()
  for _i in 0..<group {
    buf.write_string(sym)
  }
  buf.to_string()
}

///|
/// §17.18.59 `decimalFullWidth` / `decimalFullWidth2` — emit
/// full-width arabic digits (U+FF10..U+FF19) for each base-10
/// digit of the value.
fn render_full_width_digits(value : Int) -> String {
  if value < 0 {
    return "-" + render_full_width_digits(-value)
  }
  let decimal = value.to_string()
  let out = StringBuilder::new()
  for c in decimal {
    let code = c.to_int()
    if code >= 0x30 && code <= 0x39 {
      out.write_char((0xFF10 + (code - 0x30)).unsafe_to_char())
    } else {
      out.write_char(c)
    }
  }
  out.to_string()
}

///|
/// §17.18.59 `decimalEnclosedCircle` — circled digits (U+2460..
/// U+2473 for 1..20).  Outside the supported range we fall back
/// to plain arabic so the counter still increments.
fn render_enclosed_circle(value : Int) -> String {
  if value >= 1 && value <= 20 {
    let buf = StringBuilder::new()
    buf.write_char((0x2460 + value - 1).unsafe_to_char())
    return buf.to_string()
  }
  value.to_string()
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
