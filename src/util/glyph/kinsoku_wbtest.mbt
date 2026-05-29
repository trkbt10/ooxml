// Tests for JIS X 4051 禁則 (kinsoku) classification.

///|
test "line-start prohibited: closing punctuation and brackets" {
  // 。、）」』】 and small kana must never begin a line.
  for c in "。、，．）」』】〕》！？・：；ー々っゃ".iter() {
    assert_true(is_line_start_prohibited(c))
  }
}

///|
test "line-start prohibited: halfwidth and ASCII closing forms" {
  for c in "｡､｣)]}".iter() {
    assert_true(is_line_start_prohibited(c))
  }
}

///|
test "line-end prohibited: opening brackets" {
  for c in "（「『【〔《([{｢".iter() {
    assert_true(is_line_end_prohibited(c))
  }
}

///|
test "ordinary kanji / kana are not prohibited at either edge" {
  for c in "日本語あいうアイウ漢字".iter() {
    assert_true(!is_line_start_prohibited(c))
    assert_true(!is_line_end_prohibited(c))
  }
}

///|
test "kinsoku_break_allowed forbids break before line-start char" {
  // …お|。…  — break before 。 is illegal (。 would start the line).
  assert_true(!kinsoku_break_allowed('お', '。'))
  // …あ|い…  — break between two ordinary kana is fine.
  assert_true(kinsoku_break_allowed('あ', 'い'))
}

///|
test "kinsoku_break_allowed forbids break after line-end char" {
  // …（|あ… — break after （ is illegal (（ would end the line).
  assert_true(!kinsoku_break_allowed('（', 'あ'))
}

///|
/// First / last char of a segment, for the segmentation tests.
fn t_first(s : String) -> Char {
  for c in s {
    return c
  }
  ' '
}

///|
fn t_last(s : String) -> Char {
  let mut last = ' '
  for c in s {
    last = c
  }
  last
}

///|
/// No boundary produced by `linebreak_segments` may be a kinsoku-illegal
/// break point.
fn assert_segments_legal(text : String) -> Unit {
  let segs = linebreak_segments(text)
  for i in 1..<segs.length() {
    if !kinsoku_break_allowed(t_last(segs[i - 1]), t_first(segs[i])) {
      abort("illegal boundary '\{segs[i - 1]}' | '\{segs[i]}'")
    }
  }
}

///|
test "linebreak_segments: ordinary CJK breaks per glyph" {
  inspect(linebreak_segments("日本語").length(), content="3")
}

///|
test "linebreak_segments: 行頭禁則 char glues to its anchor" {
  for s in linebreak_segments("本日。") {
    assert_true(t_first(s) != '。')
  }
  assert_segments_legal("本日。")
}

///|
test "linebreak_segments: opening bracket glues forward" {
  for s in linebreak_segments("見（晴") {
    assert_true(t_last(s) != '（')
  }
  assert_segments_legal("見（晴")
}

///|
test "linebreak_segments: ASCII words stay split, boundaries legal" {
  inspect(linebreak_segments("the lazy dog").length(), content="5")
  assert_segments_legal("the lazy dog")
}

///|
test "linebreak_segments: realistic mixed sentence is all-legal" {
  assert_segments_legal("本日は、晴天なり。（晴れ）また「明日」も雨。続く……")
}

///|
test "linebreak_segments: round-trips to the original text" {
  let text = "本日は、晴天なり。（晴れ）ABC def……"
  let joined = StringBuilder::new()
  for s in linebreak_segments(text) {
    joined.write_string(s)
  }
  inspect(joined.to_string() == text, content="true")
}

///|
test "inseparable dash / leader runs are protected on both edges" {
  // A break must not split — — or … … runs.
  assert_true(is_line_start_prohibited('—'))
  assert_true(is_line_end_prohibited('—'))
  assert_true(is_line_start_prohibited('…'))
  assert_true(is_line_end_prohibited('…'))
}
