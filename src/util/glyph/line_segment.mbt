// Shared line-break segmentation — THE source of truth for decomposing
// a run of text into the atomic units a greedy line breaker may place
// or wrap, used by every viewer (WML, SML, and any future consumer) so
// the segmentation policy lives in exactly one place.
//
// A "segment" is a break unit: a line break may fall BETWEEN two
// segments but never inside one.  Decomposition rules:
//
//   * ASCII break characters (space / tab / hyphen, UAX #14 SP/BA) are
//     bucketed into their own run — a break is permitted after such a
//     run, and an all-whitespace run at the head of a wrapped line is
//     swallowed by the caller (CSS Text soft-wrap consumption).
//   * Each CJK ideograph / kana (UAX #14 class ID) is its own segment,
//     giving a per-glyph wrap opportunity before and after it.
//   * Everything else accumulates into "word" segments.
//
// Finally, JIS X 4051 禁則 is enforced structurally: any boundary that
// `kinsoku_break_allowed` forbids is removed by GLUING the offending
// character onto the neighbour it must stay with (a 行頭禁則 char glues
// to the preceding unit, a 行末禁則 char keeps the following unit
// attached).  Because the breaker only ever splits between segments,
// kinsoku-illegal breaks then become structurally impossible and the
// prohibited glyph is pushed out (追い出し) together with its anchor —
// no per-breaker kinsoku logic required.

///|
/// First / last `Char` of `s`, or `fallback` when `s` is empty.
fn seg_first_char(s : String, fallback : Char) -> Char {
  for c in s {
    return c
  }
  fallback
}

///|
fn seg_last_char(s : String, fallback : Char) -> Char {
  let mut last = fallback
  for c in s {
    last = c
  }
  last
}

///|
fn seg_chars_to_string(chars : Array[Char]) -> String {
  let b = StringBuilder::new()
  for c in chars {
    b.write_char(c)
  }
  b.to_string()
}

///|
/// Merge adjacent segments whose boundary JIS X 4051 forbids as a line
/// break, so every surviving boundary is a legal break point.
fn glue_kinsoku(segments : Array[String]) -> Array[String] {
  if segments.length() <= 1 {
    return segments
  }
  let out : Array[String] = []
  for seg in segments {
    if out.length() == 0 {
      out.push(seg)
      continue
    }
    let prev = out[out.length() - 1]
    if kinsoku_break_allowed(seg_last_char(prev, ' '), seg_first_char(seg, ' ')) {
      out.push(seg)
    } else {
      out[out.length() - 1] = prev + seg
    }
  }
  out
}

///|
/// Decompose `text` into kinsoku-aware line-break segments (see the
/// file header).  Concatenating the returned segments in order
/// reproduces `text` exactly.
pub fn linebreak_segments(text : String) -> Array[String] {
  let segments : Array[String] = []
  let word : Array[Char] = []
  let brk : Array[Char] = []
  fn flush_break() {
    if brk.length() > 0 {
      segments.push(seg_chars_to_string(brk))
      brk.clear()
    }
  }

  fn flush_word() {
    if word.length() > 0 {
      segments.push(seg_chars_to_string(word))
      word.clear()
    }
  }

  for c in text {
    if is_ascii_break_char(c) {
      flush_word()
      brk.push(c)
    } else if is_cjk_char(c) {
      flush_break()
      flush_word()
      segments.push(c.to_string())
    } else {
      flush_break()
      word.push(c)
    }
  }
  flush_break()
  flush_word()
  glue_kinsoku(segments)
}

///|
/// True when `seg` is composed entirely of soft-wrap whitespace
/// (U+0020 / U+0009) — the caller swallows such a segment at the head
/// of a wrapped line.  Hyphens are deliberately excluded: a hyphen is a
/// visible glyph the break may fall after, and it must stay on the line
/// above.
pub fn is_wrap_whitespace_segment(seg : String) -> Bool {
  if seg.length() == 0 {
    return false
  }
  for c in seg {
    if c != ' ' && c != '\t' {
      return false
    }
  }
  true
}
