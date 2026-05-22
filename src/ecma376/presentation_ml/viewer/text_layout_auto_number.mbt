// @source web-pptx packages/@aurochs-renderer/pptx/src/text-layout/auto-number.ts
//
// `<a:buAutoNum type="..." startAt="...">` formatter.  Mirrors all
// ECMA-376 §21.1.2.1.32 (ST_TextAutonumberScheme) values supported by
// the TS reference.  East-Asian / Hindi / Thai schemes fall back to
// Arabic numerals — the TS code does the same.

///|
/// Convert a positive integer 1-3999 to lowercase Roman numerals.
fn to_roman_lower(num : Int) -> String {
  if num <= 0 || num > 3999 {
    return num.to_string()
  }
  let values : Array[Int] = [
    1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1,
  ]
  let numerals : Array[String] = [
    "m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i",
  ]
  let buf = StringBuilder::new()
  let mut remaining = num
  for i in 0..<values.length() {
    let v = values[i]
    let n = numerals[i]
    while remaining >= v {
      buf.write_string(n)
      remaining = remaining - v
    }
  }
  buf.to_string()
}

///|
fn to_roman_upper(num : Int) -> String {
  to_roman_lower(num).to_upper()
}

///|
/// Convert a positive integer to lowercase alphabetic
/// (a, b, c, ..., z, aa, ab, ...).
fn to_alpha_lower(num : Int) -> String {
  if num <= 0 {
    return num.to_string()
  }
  let buf : Array[Char] = []
  let mut n = num
  while n > 0 {
    n = n - 1
    let code = 97 + n % 26
    let c = Char::from_int(code)
    buf.push(c)
    n = n / 26
  }
  // Reverse buf into a string.
  let out = StringBuilder::new()
  for i in 0..<buf.length() {
    out.write_char(buf[buf.length() - 1 - i])
  }
  out.to_string()
}

///|
fn to_alpha_upper(num : Int) -> String {
  to_alpha_lower(num).to_upper()
}

///|
/// Convert 1-20 to a Unicode "Circled Digit" character; otherwise
/// fall back to plain integer string.
fn to_circled_number(num : Int) -> String {
  if num >= 1 && num <= 20 {
    let buf = StringBuilder::new()
    buf.write_char(Char::from_int(0x2460 + num - 1))
    return buf.to_string()
  }
  num.to_string()
}

///|
fn to_black_circled_number(num : Int) -> String {
  if num >= 1 && num <= 10 {
    let buf = StringBuilder::new()
    buf.write_char(Char::from_int(0x2776 + num - 1))
    return buf.to_string()
  }
  if num >= 11 && num <= 20 {
    return to_circled_number(num)
  }
  num.to_string()
}

///|
/// Convert a positive integer to fullwidth ASCII digits
/// ('０'-'９', U+FF10..U+FF19).
fn to_double_byte_arabic(num : Int) -> String {
  substitute_decimal_digits(num, 0xFF10)
}

///|
/// Map each ASCII decimal digit of `num` onto a contiguous Unicode
/// digit block starting at `base` (the code point for digit zero).
/// A leading `-` is preserved verbatim.
fn substitute_decimal_digits(num : Int, base : Int) -> String {
  let s = num.to_string()
  let out = StringBuilder::new()
  for c in s {
    let code = c.to_int()
    if code >= 0x30 && code <= 0x39 {
      out.write_char(Char::from_int(base + (code - 0x30)))
    } else {
      out.write_char(c)
    }
  }
  out.to_string()
}

///|
/// §21.1.2.1.32 thaiNum* — Thai digits occupy U+0E50 (zero) through
/// U+0E59 (nine).
fn to_thai_digits(num : Int) -> String {
  substitute_decimal_digits(num, 0x0E50)
}

///|
/// §21.1.2.1.32 hindiNum* — the Devanagari digits used for Hindi
/// occupy U+0966 (zero) through U+096F (nine).
fn to_devanagari_digits(num : Int) -> String {
  substitute_decimal_digits(num, 0x0966)
}

///|
/// §21.1.2.1.32 hebrew* — render `num` (1..999) as a Hebrew
/// alphabetic numeral (gematria).  Hebrew numerals are additive:
///   units    א1 ב2 ג3 ד4 ה5 ו6 ז7 ח8 ט9
///   tens     י10 כ20 ל30 מ40 נ50 ס60 ע70 פ80 צ90
///   hundreds ק100 ר200 ש300 ת400  (500..900 compose ת+remainder)
/// Two values are special-cased by convention to avoid spelling
/// fragments of the divine name: 15 is טו (9+6) rather than יה
/// (10+5), and 16 is טז (9+7) rather than יו.  A gershayim (U+05F4)
/// is inserted before the final letter of a multi-letter numeral,
/// and a geresh (U+05F3) follows a single-letter numeral, per the
/// standard typographic convention.  Out-of-range values fall back
/// to the decimal string (mirrors the Roman-numeral cap).
fn to_hebrew_numeral(num : Int) -> String {
  if num <= 0 || num > 999 {
    return num.to_string()
  }
  // Letter code points for each additive value.
  let hundreds_cp = [0x05E7, 0x05E8, 0x05E9, 0x05EA] // ק ר ש ת = 100..400
  let tens_cp = [
    0x05D9, 0x05DB, 0x05DC, 0x05DE, 0x05E0, 0x05E1, 0x05E2, 0x05E4, 0x05E6,
  ] // י..צ = 10..90
  let units_cp = [
    0x05D0, 0x05D1, 0x05D2, 0x05D3, 0x05D4, 0x05D5, 0x05D6, 0x05D7, 0x05D8,
  ] // א..ט = 1..9
  let letters : Array[Int] = []
  let mut remaining = num
  // Hundreds: 100..400 are single letters; 500..900 prepend ת(400)
  // as many times as needed, then the residual hundreds letter.
  let mut hundreds = remaining / 100
  remaining = remaining % 100
  while hundreds > 4 {
    letters.push(hundreds_cp[3]) // ת = 400
    hundreds = hundreds - 4
  }
  if hundreds >= 1 {
    letters.push(hundreds_cp[hundreds - 1])
  }
  // 15 and 16 are written as 9+6 / 9+7 by convention.
  if remaining == 15 {
    letters.push(units_cp[8]) // ט = 9
    letters.push(units_cp[5]) // ו = 6
  } else if remaining == 16 {
    letters.push(units_cp[8]) // ט = 9
    letters.push(units_cp[6]) // ז = 7
  } else {
    let tens = remaining / 10
    let units = remaining % 10
    if tens >= 1 {
      letters.push(tens_cp[tens - 1])
    }
    if units >= 1 {
      letters.push(units_cp[units - 1])
    }
  }
  let out = StringBuilder::new()
  if letters.length() == 1 {
    out.write_char(Char::from_int(letters[0]))
    out.write_char(Char::from_int(0x05F3)) // geresh ׳
  } else {
    for idx in 0..<letters.length() {
      // Gershayim ״ precedes the final letter.
      if idx == letters.length() - 1 {
        out.write_char(Char::from_int(0x05F4))
      }
      out.write_char(Char::from_int(letters[idx]))
    }
  }
  out.to_string()
}

///|
/// The ten CJK ideographic digits 〇..九 (U+3007, then U+4E00…).
/// Index 0 is the placeholder zero 〇; 1..9 are 一..九.
let cjk_digits : Array[Int] = [
  0x3007, 0x4E00, 0x4E8C, 0x4E09, 0x56DB, 0x4E94, 0x516D, 0x4E03, 0x516B,
  0x4E5D,
]

///|
/// §21.1.2.1.32 ea1* — render `num` (1..999) as a CJK ideographic
/// numeral using the positional myriad notation shared by Chinese,
/// Japanese and the Sino-Korean numerals.
///
/// Place glyphs: 十 (U+5341) ten, 百 (U+767E) hundred.  Two
/// orthographic conventions differ between the East-Asian scripts
/// and are selected by `chinese`:
///
///  * Chinese style (`ea1Chs` / `ea1Cht`): the hundreds digit is
///    always written even when 1 (`一百`), a tens place of value 1
///    inside a larger number is written `一十`, and a skipped
///    interior place is filled with the zero glyph 〇 — e.g.
///    105 → 一百〇五, 110 → 一百一十.
///  * Japanese / Korean style (`ea1Jpn*`): a leading 1 in the
///    hundreds or tens place is elided (`百`, `十`) and no interior
///    zero glyph is written — e.g. 105 → 百五, 110 → 百十.
///
/// Values outside 1..999 fall back to the decimal string (the
/// myriad grouping for 1000+ is out of this renderer's range,
/// mirroring the Roman-numeral cap).
fn to_cjk_numeral(num : Int, chinese~ : Bool) -> String {
  if num <= 0 || num > 999 {
    return num.to_string()
  }
  let hundreds = num / 100
  let tens = num % 100 / 10
  let units = num % 10
  let out = StringBuilder::new()
  // Hundreds place.  A hundreds digit of 1 is written `一百` in
  // Chinese style but elided to a bare `百` in Japanese style;
  // 2..9 carry their digit in both styles.
  if hundreds >= 1 {
    if hundreds >= 2 || chinese {
      out.write_char(Char::from_int(cjk_digits[hundreds]))
    }
    out.write_char(Char::from_int(0x767E)) // 百
  }
  // Tens place.
  if tens >= 1 {
    // A tens digit of 1 is written `一十` in Chinese style only
    // when it follows a hundreds place; standalone 10..19 is
    // `十…` in both styles.
    if tens == 1 && (chinese && hundreds >= 1) {
      out.write_char(Char::from_int(cjk_digits[1])) // 一
    } else if tens >= 2 {
      out.write_char(Char::from_int(cjk_digits[tens]))
    }
    out.write_char(Char::from_int(0x5341)) // 十
  } else if units >= 1 && hundreds >= 1 && chinese {
    // Interior zero: a hundreds place with no tens but a units
    // digit takes the zero glyph in Chinese style (一百〇五).
    out.write_char(Char::from_int(cjk_digits[0])) // 〇
  }
  // Units place.
  if units >= 1 {
    out.write_char(Char::from_int(cjk_digits[units]))
  }
  out.to_string()
}

///|
/// Format an auto-number bullet according to ECMA-376
/// §21.1.2.1.32 (ST_TextAutonumberScheme).  `index` is 1-based;
/// `start_at` is the value of `<a:buAutoNum startAt="...">` (default 1).
/// Mirrors `formatAutoNumber` in `auto-number.ts:187`.
pub fn format_auto_number(
  scheme : String,
  index : Int,
  start_at? : Int = 1,
) -> String {
  let num = index + start_at - 1
  match scheme {
    // Lowercase alphabetic
    "alphaLcParenBoth" => "(" + to_alpha_lower(num) + ")"
    "alphaLcParenR" => to_alpha_lower(num) + ")"
    "alphaLcPeriod" => to_alpha_lower(num) + "."
    // Uppercase alphabetic
    "alphaUcParenBoth" => "(" + to_alpha_upper(num) + ")"
    "alphaUcParenR" => to_alpha_upper(num) + ")"
    "alphaUcPeriod" => to_alpha_upper(num) + "."
    // Arabic
    "arabicParenBoth" => "(" + num.to_string() + ")"
    "arabicParenR" => num.to_string() + ")"
    "arabicPeriod" => num.to_string() + "."
    "arabicPlain" => num.to_string()
    // Double-byte Arabic
    "arabicDbPeriod" => to_double_byte_arabic(num) + "."
    "arabicDbPlain" => to_double_byte_arabic(num)
    // Circled
    "circleNumDbPlain" | "circleNumWdWhitePlain" => to_circled_number(num)
    "circleNumWdBlackPlain" => to_black_circled_number(num)
    // Lowercase Roman
    "romanLcParenBoth" => "(" + to_roman_lower(num) + ")"
    "romanLcParenR" => to_roman_lower(num) + ")"
    "romanLcPeriod" => to_roman_lower(num) + "."
    // Uppercase Roman
    "romanUcParenBoth" => "(" + to_roman_upper(num) + ")"
    "romanUcParenR" => to_roman_upper(num) + ")"
    "romanUcPeriod" => to_roman_upper(num) + "."
    // East Asian — §21.1.2.1.32 ea1* CJK ideographic numerals.
    // `ea1Chs` / `ea1Cht` use the Chinese orthography (leading-1
    // hundreds, interior zero glyph); the `ea1Jpn*` family uses
    // the Japanese / Korean orthography.  The `*Period` schemes
    // append a full stop; `*Plain` schemes append nothing.
    "ea1ChsPeriod" | "ea1ChtPeriod" =>
      to_cjk_numeral(num, chinese=true) + "."
    "ea1ChsPlain" | "ea1ChtPlain" => to_cjk_numeral(num, chinese=true)
    "ea1JpnChsDbPeriod" | "ea1JpnKorPeriod" | "ea1JpnKorPlainPeriod" =>
      to_cjk_numeral(num, chinese=false) + "."
    "ea1JpnKorPlain" => to_cjk_numeral(num, chinese=false)
    // Arabic with minus suffix — §21.1.2.1.32 enumerates both
    // arabic1Minus and arabic2Minus; spec leaves the cosmetic
    // difference (1- vs 2-) to the consumer. We render plain
    // arabic numerals with a trailing minus for both.
    "arabic1Minus" | "arabic2Minus" => num.to_string() + "-"
    // Hebrew — §21.1.2.1.32 hebrew1Minus / hebrew2Minus. Both use
    // Hebrew alphabetic numbering (gematria); the 1-vs-2 cosmetic
    // difference is consumer-defined, like arabic1/arabic2 above.
    // The trailing minus is the scheme's ANSI separator.
    "hebrew1Minus" | "hebrew2Minus" => to_hebrew_numeral(num) + "-"
    // Hindi numeric variants — §21.1.2.1.32 hindiNum* use the
    // Devanagari digit block (U+0966-096F); these are pure digit
    // substitution and are rendered exactly.
    "hindiNumPeriod" => to_devanagari_digits(num) + "."
    "hindiNumParenR" => to_devanagari_digits(num) + ")"
    // Hindi alphabetic variants — hindiAlpha* require a Devanagari
    // alphabetic-numeral (consonant) table the viewer does not yet
    // implement; surfaced as plain Arabic with the spec suffix.
    "hindiAlpha1Period" | "hindiAlphaPeriod" => num.to_string() + "."
    // Thai numeric variants — §21.1.2.1.32 thaiNum* use the Thai
    // digit block (U+0E50-0E59); pure digit substitution.
    "thaiNumParenBoth" => "(" + to_thai_digits(num) + ")"
    "thaiNumParenR" => to_thai_digits(num) + ")"
    "thaiNumPeriod" => to_thai_digits(num) + "."
    // Thai alphabetic variants — thaiAlpha* require a Thai
    // consonant-numeral table not yet implemented; degraded to
    // plain Arabic with the spec suffix.
    "thaiAlphaParenBoth" => "(" + num.to_string() + ")"
    "thaiAlphaParenR" => num.to_string() + ")"
    "thaiAlphaPeriod" => num.to_string() + "."
    // §21.1.2.1.32 — schema violation: unknown scheme. Render the
    // numeric value with no decoration so the list is still
    // sequential; the scheme name should already have been
    // surfaced as data-ooxml-bullet-scheme metadata upstream.
    _ => num.to_string()
  }
}
