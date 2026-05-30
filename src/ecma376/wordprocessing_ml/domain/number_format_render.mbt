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
    // §17.18.59 East-Asian ideograph formats — implemented with the
    // standard CJK place-value / digit-by-digit algorithms.
    NumFmtIdeographDigital => render_digit_glyphs(value, cjk_digits())
    NumFmtIdeographTraditional =>
      render_cjk_counting(
        value, cjk_digits(), cjk_units(), cjk_myriads_japanese(), false,
      )
    NumFmtIdeographZodiac => render_cycle(value, zodiac_branches())
    NumFmtIdeographZodiacTraditional => render_cycle(value, zodiac_branches())
    NumFmtIdeographLegalTraditional =>
      render_cjk_counting(
        value, cjk_legal_trad_digits(), cjk_legal_units(),
        cjk_myriads_traditional(), true,
      )
    NumFmtJapaneseCounting =>
      render_cjk_counting(
        value, cjk_digits(), cjk_units(), cjk_myriads_japanese(), false,
      )
    NumFmtJapaneseLegal =>
      render_cjk_counting(
        value, cjk_legal_trad_digits(), cjk_legal_units(),
        cjk_myriads_japanese(), true,
      )
    NumFmtJapaneseDigitalTenThousand => render_digit_glyphs(value, cjk_digits())
    NumFmtTaiwaneseCounting =>
      render_cjk_counting(
        value, cjk_digits(), cjk_units(), cjk_myriads_traditional(), false,
      )
    NumFmtTaiwaneseCountingThousand =>
      render_cjk_counting(
        value, cjk_digits(), cjk_units(), cjk_myriads_traditional(), false,
      )
    NumFmtTaiwaneseDigital => render_digit_glyphs(value, cjk_digits())
    NumFmtChineseCounting =>
      render_cjk_counting(
        value, cjk_digits(), cjk_units(), cjk_myriads_simplified(), false,
      )
    NumFmtChineseLegalSimplified =>
      render_cjk_counting(
        value, cjk_legal_simp_digits(), cjk_legal_units(),
        cjk_myriads_simplified(), true,
      )
    NumFmtChineseCountingThousand =>
      render_cjk_counting(
        value, cjk_digits(), cjk_units(), cjk_myriads_simplified(), false,
      )
    NumFmtKoreanDigital => render_digit_glyphs(value, cjk_digits())
    NumFmtKoreanDigital2 => render_digit_glyphs(value, hangul_digits())
    // §17.18.59 Indic / Thai positional digits — contiguous Unicode
    // script-digit blocks.
    NumFmtHindiNumbers => render_digit_range(value, 0x0966)
    NumFmtThaiNumbers => render_digit_range(value, 0x0E50)
    // §17.18.59 alphabetic-ordering and spelled-out script formats
    // (kana あ/い order, Hangul jamo, Cyrillic, Arabic abjad, Hebrew
    // gematria, Korean/Vietnamese/Hindi/Thai counting words) have
    // locale-specific collation the spec defers to fonts; rendered as
    // arabic digits, with the format name surfaced as
    // `data-ooxml-numfmt` metadata upstream for glyph substitution.
    NumFmtKoreanCounting => value.to_string()
    NumFmtKoreanLegal => value.to_string()
    NumFmtAiueo => value.to_string()
    NumFmtAiueoFullWidth => value.to_string()
    NumFmtIroha => value.to_string()
    NumFmtIrohaFullWidth => value.to_string()
    NumFmtGanada => value.to_string()
    NumFmtChosung => value.to_string()
    NumFmtVietnameseCounting => value.to_string()
    NumFmtRussianLower => value.to_string()
    NumFmtRussianUpper => value.to_string()
    NumFmtHebrew1 => value.to_string()
    NumFmtHebrew2 => value.to_string()
    NumFmtArabicAlpha => value.to_string()
    NumFmtArabicAbjad => value.to_string()
    NumFmtHindiVowels => value.to_string()
    NumFmtHindiConsonants => value.to_string()
    NumFmtHindiCounting => value.to_string()
    NumFmtThaiLetters => value.to_string()
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
/// §17.18.59 — substitute each base-10 digit of `value` with the
/// contiguous script-digit block starting at `zero_cp` (e.g. Devanagari
/// U+0966, Thai U+0E50).  Used by the positional non-CJK script digit
/// formats.
fn render_digit_range(value : Int, zero_cp : Int) -> String {
  if value < 0 {
    return "-" + render_digit_range(-value, zero_cp)
  }
  let decimal = value.to_string()
  let out = StringBuilder::new()
  for c in decimal {
    let code = c.to_int()
    if code >= 0x30 && code <= 0x39 {
      out.write_char((zero_cp + (code - 0x30)).unsafe_to_char())
    } else {
      out.write_char(c)
    }
  }
  out.to_string()
}

///|
/// §17.18.59 — render `value` digit-by-digit through a 10-glyph table
/// (`glyphs[0]`..`glyphs[9]`).  Used by the positional CJK / Hangul
/// digit formats (`ideographDigital`, `koreanDigital`, …).
fn render_digit_glyphs(value : Int, glyphs : Array[String]) -> String {
  if value < 0 {
    return "-" + render_digit_glyphs(-value, glyphs)
  }
  let decimal = value.to_string()
  let out = StringBuilder::new()
  for c in decimal {
    let code = c.to_int()
    if code >= 0x30 && code <= 0x39 {
      out.write_string(glyphs[code - 0x30])
    } else {
      out.write_char(c)
    }
  }
  out.to_string()
}

///|
/// §17.18.59 — render `value` (positive) as a CJK place-value numeral.
/// `digits` are the ten unit glyphs (index 0 = zero), `units` the four
/// within-group markers `["", 十, 百, 千]`, and `myriads` the
/// group separators `["", 万, 億, 兆]`. `legal` selects the formal
/// "always written" 大字 financial style (no leading-ten elision). The
/// universal convention is used (the leading 十 drops its 一; every
/// other place keeps its digit, e.g. 一百), with the standard inter-group
/// zero filler.  Implemented for the numbering range.
fn render_cjk_counting(
  value : Int,
  digits : Array[String],
  units : Array[String],
  myriads : Array[String],
  legal : Bool,
) -> String {
  if value == 0 {
    return digits[0]
  }
  if value < 0 {
    return "-" + render_cjk_counting(-value, digits, units, myriads, legal)
  }
  let groups : Array[Int] = []
  let mut v = value
  while v > 0 {
    groups.push(v % 10000)
    v = v / 10000
  }
  let out = StringBuilder::new()
  let mut gi = groups.length() - 1
  let mut started = false
  while gi >= 0 {
    let g = groups[gi]
    if g != 0 {
      if started && g < 1000 {
        out.write_string(digits[0])
      }
      out.write_string(render_cjk_group(g, digits, units, legal))
      if gi < myriads.length() {
        out.write_string(myriads[gi])
      }
      started = true
    }
    gi = gi - 1
  }
  out.to_string()
}

///|
/// Render a single 1..9999 group of a CJK place-value numeral.
fn render_cjk_group(
  g : Int,
  digits : Array[String],
  units : Array[String],
  legal : Bool,
) -> String {
  let out = StringBuilder::new()
  let mut place = 3
  let mut need_zero = false
  let mut emitted = false
  while place >= 0 {
    let p10 = match place {
      3 => 1000
      2 => 100
      1 => 10
      _ => 1
    }
    let d = g / p10 % 10
    if d == 0 {
      if emitted {
        need_zero = true
      }
    } else {
      if need_zero {
        out.write_string(digits[0])
        need_zero = false
      }
      // The leading 十 (10..19) drops its 一 in the informal forms.
      if d == 1 && !emitted && !legal && place == 1 {
        out.write_string(units[place])
      } else {
        out.write_string(digits[d])
        out.write_string(units[place])
      }
      emitted = true
    }
    place = place - 1
  }
  out.to_string()
}

///|
/// §17.18.59 `ideographZodiac` — map `value` onto a fixed cyclic glyph
/// table (the twelve Earthly Branches), wrapping beyond its length.
fn render_cycle(value : Int, glyphs : Array[String]) -> String {
  if value <= 0 {
    return value.to_string()
  }
  glyphs[(value - 1) % glyphs.length()]
}

///|
/// CJK unit glyphs (index 0 = zero) for the informal counting forms.
fn cjk_digits() -> Array[String] {
  ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
}

///|
/// Within-group place markers `["", 十, 百, 千]` (informal).
fn cjk_units() -> Array[String] {
  ["", "十", "百", "千"]
}

///|
/// Formal 大字 within-group place markers `["", 拾, 佰, 仟]`.
fn cjk_legal_units() -> Array[String] {
  ["", "拾", "佰", "仟"]
}

///|
/// Simplified-Chinese formal (大写) unit glyphs.
fn cjk_legal_simp_digits() -> Array[String] {
  ["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"]
}

///|
/// Traditional formal (大字) unit glyphs (Japanese / traditional Chinese).
fn cjk_legal_trad_digits() -> Array[String] {
  ["零", "壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖"]
}

///|
/// Hangul Sino-Korean digit glyphs (index 0 = zero).
fn hangul_digits() -> Array[String] {
  ["영", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구"]
}

///|
/// Myriad group separators for the simplified-Chinese forms.
fn cjk_myriads_simplified() -> Array[String] {
  ["", "万", "亿", "兆"]
}

///|
/// Myriad group separators for the Japanese forms (万 + 億 + 兆).
fn cjk_myriads_japanese() -> Array[String] {
  ["", "万", "億", "兆"]
}

///|
/// Myriad group separators for the traditional-Chinese forms (萬 …).
fn cjk_myriads_traditional() -> Array[String] {
  ["", "萬", "億", "兆"]
}

///|
/// The twelve Earthly Branches, in cycle order, for `ideographZodiac`.
fn zodiac_branches() -> Array[String] {
  ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
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
