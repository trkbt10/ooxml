// Inter-script spacing (和欧間隔) — THE source of truth for the extra
// space JIS X 4051 / ECMA-376 insert between East Asian text and
// adjacent Western letters or digits.
//
// ECMA-376 represents this as two paragraph toggles (§17.3.1.10/.11):
//   * <w:autoSpaceDE> — auto space between East Asian and *alphabet*
//     (Latin) characters.
//   * <w:autoSpaceDN> — auto space between East Asian and *numbers*.
// Both default ON.  JIS X 4051 §4.3 prescribes a 四分アキ (one-quarter
// em) gap at such a boundary, which is the value Word approximates.
//
// This module classifies the two character sides and yields the gap in
// EM units so every consumer (measurement AND glyph positioning, in
// every viewer) derives the same amount from one place.

///|
/// The 四分アキ gap, in em, inserted at an East-Asian↔Western boundary.
/// JIS X 4051 §4.3 specifies one quarter of the em square.
pub let inter_script_gap_em : Double = 0.25

///|
/// True when `c` is an East Asian character that participates in 和欧間隔
/// — a kanji ideograph or a kana.  CJK punctuation is excluded (it has
/// its own spacing class) and so are the half/fullwidth *Latin* forms.
fn is_east_asian_for_spacing(c : Char) -> Bool {
  let cp = c.to_int()
  // Kanji: CJK Unified Ideographs (+ Extension A).
  (cp >= 0x4E00 && cp <= 0x9FFF) ||
  (cp >= 0x3400 && cp <= 0x4DBF) ||
  // Hiragana / Katakana (full-width block, excluding the U+3040 gap).
  (cp >= 0x3041 && cp <= 0x309F) ||
  (cp >= 0x30A0 && cp <= 0x30FF) ||
  // Half-width katakana (U+FF66..U+FF9D), East-Asian by nature.
  (cp >= 0xFF66 && cp <= 0xFF9D)
}

///|
/// True when `c` is a Western *letter* governed by `autoSpaceDE` — an
/// ASCII or Latin-1 / Latin-Extended alphabetic character.
fn is_western_letter(c : Char) -> Bool {
  let cp = c.to_int()
  (cp >= 0x41 && cp <= 0x5A) ||
  (cp >= 0x61 && cp <= 0x7A) ||
  // Latin-1 Supplement letters + Latin Extended-A (À..ſ), excluding
  // the U+00D7 / U+00F7 math signs.
  (cp >= 0x00C0 && cp <= 0x024F && cp != 0x00D7 && cp != 0x00F7)
}

///|
/// True when `c` is a Western *digit* governed by `autoSpaceDN` — an
/// ASCII decimal digit.
fn is_western_digit(c : Char) -> Bool {
  let cp = c.to_int()
  cp >= 0x30 && cp <= 0x39
}

///|
/// The inter-script gap (in em) to insert between adjacent characters
/// `prev` and `next`, honouring the two ECMA-376 toggles:
///   * `auto_space_de` gates the East-Asian↔letter gap,
///   * `auto_space_dn` gates the East-Asian↔digit gap.
/// Returns `inter_script_gap_em` when exactly one side is East Asian
/// and the other is an enabled Western letter / digit, else `0`.
pub fn inter_script_space_em(
  prev : Char,
  next : Char,
  auto_space_de~ : Bool = true,
  auto_space_dn~ : Bool = true,
) -> Double {
  let prev_ea = is_east_asian_for_spacing(prev)
  let next_ea = is_east_asian_for_spacing(next)
  // Exactly one side East Asian (a boundary), the other Western.
  if prev_ea == next_ea {
    return 0.0
  }
  let western = if prev_ea { next } else { prev }
  if auto_space_de && is_western_letter(western) {
    inter_script_gap_em
  } else if auto_space_dn && is_western_digit(western) {
    inter_script_gap_em
  } else {
    0.0
  }
}

///|
/// Total extra advance (in px) `text` accrues from 和欧間隔 at its
/// internal East-Asian↔Western boundaries, at `font_size_pt`.  Used by
/// the measurement path so line breaking and alignment account for the
/// same spacing the renderer draws.
pub fn inter_script_advance_px(
  text : String,
  font_size_pt~ : Double,
  auto_space_de~ : Bool = true,
  auto_space_dn~ : Bool = true,
) -> Double {
  let mut total = 0.0
  let mut prev : Char? = None
  for c in text {
    match prev {
      Some(p) =>
        total = total +
          inter_script_space_em(p, c, auto_space_de~, auto_space_dn~)
      None => ()
    }
    prev = Some(c)
  }
  total * font_size_pt
}
