// @source web-pptx packages/@aurochs/glyph/src/metrics/cjk.ts
//
// CJK character detection using Unicode-block ranges.

///|
/// Inclusive Unicode ranges that classify a code point as CJK
/// (Chinese/Japanese/Korean) for the purposes of text layout.
///
/// Mirrors the table in `cjk.ts:10` of `@aurochs/glyph`:
///   - U+4E00..U+9FFF  CJK Unified Ideographs
///   - U+3400..U+4DBF  CJK Unified Ideographs Extension A
///   - U+3000..U+303F  CJK Symbols and Punctuation
///   - U+3040..U+309F  Hiragana
///   - U+30A0..U+30FF  Katakana
///   - U+FF00..U+FFEF  Halfwidth and Fullwidth Forms
let cjk_ranges : Array[(Int, Int)] = [
  (0x4E00, 0x9FFF),
  (0x3400, 0x4DBF),
  (0x3000, 0x303F),
  (0x3040, 0x309F),
  (0x30A0, 0x30FF),
  (0xFF00, 0xFFEF),
]

///|
/// True iff `char_code` falls inside any of `cjk_ranges`.
///
/// @source web-pptx `cjk.ts:25 isCjkCodePoint`
pub fn is_cjk_code_point(char_code : Int) -> Bool {
  for range in cjk_ranges {
    let (start, end) = range
    if char_code >= start && char_code <= end {
      return true
    }
  }
  false
}

///|
/// True iff the first code unit of `char` is CJK.  Mirrors
/// `isCjkChar(char)` in `cjk.ts:41` which only looks at the first
/// UTF-16 code unit; the renderer never feeds surrogate pairs here.
pub fn is_cjk_char(char : Char) -> Bool {
  is_cjk_code_point(char.to_int())
}
