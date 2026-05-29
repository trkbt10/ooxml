// JIS X 4051 line-composition (禁則処理 / kinsoku shori) character
// classification for Japanese text layout.
//
// JIS X 4051:2004 「日本語文書の組版方法」 assigns every character to a
// composition class; two of those classes constrain where a line break
// may legally fall and are essential for correct Japanese wrapping:
//
//   * 行頭禁則文字 (characters prohibited at the START of a line) — a
//     break must NOT be placed immediately *before* such a character,
//     because that would leave it stranded at the head of the next
//     line.  Covers closing brackets (cl-02), the comma/period class
//     (cl-06/07), middle dots and colons (cl-05), the iteration marks,
//     the prolonged-sound mark (cl-10), small kana (cl-11/12), and the
//     trailing-symbol class (cl-13: %, ℃, ′, ″, …).
//
//   * 行末禁則文字 (characters prohibited at the END of a line) — a
//     break must NOT be placed immediately *after* such a character.
//     Covers the opening-bracket class (cl-01).
//
// The standard also defines 分離禁止 (inseparable) runs such as the
// 2-em dash and the 3-dot leader; those are handled by treating the
// characters as non-breakable on both sides (start- AND end-prohibited)
// so a break never splits a `——` or `……` pair.
//
// Reference renderers (Word, PowerPoint) implement the same constraint
// set; ECMA-376 itself defers line composition to the consuming
// application, so matching JIS X 4051 is the correct behaviour for
// Japanese documents.

///|
/// Code points that may NOT begin a line (行頭禁則文字).  Listed by
/// JIS X 4051 class; see the file header for the class meanings.
let line_start_prohibited : Array[Int] = [
  // cl-02 closing brackets — ASCII, fullwidth, CJK, halfwidth, guillemets
  0x0029, 0x005D, 0x007D, // ) ] }
  0xFF09, 0xFF3D, 0xFF5D, // ）］｝
  0x300D, 0x300F, 0x3011, 0x3015, 0x3009, 0x300B, // 」』】〕〉》
  0x3017, 0x3019, 0x301B, // 〗〙〛
  0xFF60, 0xFF63, // ｠｣ (halfwidth)
  0x203A, 0x00BB, // › »
  0x301F, // 〟 closing double prime quote
  // cl-06/07 commas and periods
  0x3001, 0x3002, // 、。
  0xFF0C, 0xFF0E, // ，．
  0xFF64, 0xFF61, // ､｡ (halfwidth)
  // cl-05 middle dots / colons / semicolons
  0x30FB, 0xFF1A, 0xFF1B, 0xFF65, // ・：；･
  // cl-04 question / exclamation
  0xFF1F, 0xFF01, // ？！
  // iteration marks
  0x3005, 0x303B, 0x309D, 0x309E, 0x30FD, 0x30FE, // 々〻ゝゞヽヾ
  // small hiragana (cl-11)
  0x3041, 0x3043, 0x3045, 0x3047, 0x3049, // ぁぃぅぇぉ
  0x3063, 0x3083, 0x3085, 0x3087, 0x308E, 0x3095, 0x3096, // っゃゅょゎゕゖ
  // small katakana (cl-12)
  0x30A1, 0x30A3, 0x30A5, 0x30A7, 0x30A9, // ァィゥェォ
  0x30C3, 0x30E3, 0x30E5, 0x30E7, 0x30EE, 0x30F5, 0x30F6, // ッャュョヮヵヶ
  // halfwidth small katakana
  0xFF67, 0xFF68, 0xFF69, 0xFF6A, 0xFF6B, // ｧｨｩｪｫ
  0xFF6C, 0xFF6D, 0xFF6E, 0xFF6F, // ｬｭｮｯ
  // cl-10 prolonged sound mark, sound marks
  0x30FC, 0xFF70, // ー ｰ
  0xFF9E, 0xFF9F, // ﾞ ﾟ (halfwidth voiced/semi-voiced marks)
  // cl-13 trailing symbols
  0x00B0, 0x2032, 0x2033, 0x2103, 0x2030, 0xFF05, // ° ′ ″ ℃ ‰ ％
  // 分離禁止: 2-em dash / 3-dot leader / 2-dot leader pieces also
  // forbidden at line start (their leading half must not start a line)
  0x2014, 0x2015, 0x2026, 0x2025, // — ― … ‥
]

///|
/// Code points that may NOT end a line (行末禁則文字 — cl-01 opening
/// brackets, plus the inseparable-run characters).
let line_end_prohibited : Array[Int] = [
  // cl-01 opening brackets — ASCII, fullwidth, CJK, halfwidth, guillemets
  0x0028, 0x005B, 0x007B, // ( [ {
  0xFF08, 0xFF3B, 0xFF5B, // （［｛
  0x300C, 0x300E, 0x3010, 0x3014, 0x3008, 0x300A, // 「『【〔〈《
  0x3016, 0x3018, 0x301A, // 〖〘〚
  0xFF62, // ｢ (halfwidth)
  0x2039, 0x00AB, // ‹ «
  0x301D, // 〝 opening double prime quote
  // 分離禁止: leading half of dash / leader runs must not end a line
  0x2014, 0x2015, 0x2026, 0x2025, // — ― … ‥
]

///|
/// True when `c` is a 行頭禁則文字 — a character JIS X 4051 forbids at
/// the start of a line.  A line break must therefore not be placed
/// immediately before `c`.
pub fn is_line_start_prohibited(c : Char) -> Bool {
  let cp = c.to_int()
  for x in line_start_prohibited {
    if x == cp {
      return true
    }
  }
  false
}

///|
/// True when `c` is a 行末禁則文字 — a character JIS X 4051 forbids at
/// the end of a line.  A line break must therefore not be placed
/// immediately after `c`.
pub fn is_line_end_prohibited(c : Char) -> Bool {
  let cp = c.to_int()
  for x in line_end_prohibited {
    if x == cp {
      return true
    }
  }
  false
}

///|
/// True when a line break is permitted between `prev` (the last
/// character of the candidate line) and `next` (the first character of
/// the candidate next line) under JIS X 4051.  The break is forbidden
/// when `next` may not begin a line, or `prev` may not end one.
pub fn kinsoku_break_allowed(prev : Char, next : Char) -> Bool {
  !is_line_start_prohibited(next) && !is_line_end_prohibited(prev)
}

///|
/// ASCII soft-wrap break characters (UAX #14 classes SP / BA): the
/// space, the tab, and the hyphen-minus.  A line break is permitted
/// *after* such a character.  This is the single source of truth for
/// every viewer's "is this an ASCII break opportunity" test — WML, PML
/// and SML all defer here rather than re-listing the set.
pub fn is_ascii_break_char(c : Char) -> Bool {
  c == ' ' || c == '\t' || c == '-'
}

///|
/// THE source of truth for line-break opportunities between two
/// adjacent characters.  Every viewer's line breaker consults this one
/// function so the line-composition policy is defined in exactly one
/// place (and so a refinement — e.g. a new kinsoku class — lands
/// everywhere at once instead of being bolted onto each breaker).
///
/// A break may fall between `prev` and `next` when BOTH hold:
///
///  1. There is a *break opportunity* — either `prev` is an ASCII
///     break character (UAX #14: break after SP / tab / hyphen), or
///     either side is a CJK ideograph / kana (UAX #14 class ID: a
///     break is allowed before and after every ideographic char).
///
///  2. JIS X 4051 *kinsoku* permits it — `next` is not a
///     line-start-prohibited character and `prev` is not a
///     line-end-prohibited one.
pub fn break_allowed_between(prev : Char, next : Char) -> Bool {
  let opportunity = is_ascii_break_char(prev) ||
    is_cjk_char(prev) ||
    is_cjk_char(next)
  opportunity && kinsoku_break_allowed(prev, next)
}
