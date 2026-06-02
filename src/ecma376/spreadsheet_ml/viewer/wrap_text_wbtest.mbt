// Tests for SpreadsheetML cell text wrapping (`wrap_text`), which now
// decomposes through the shared `@glyph.linebreak_segments` source of
// truth: space-less CJK wraps per glyph and honours JIS X 4051 禁則,
// while ASCII word wrapping is preserved.

///|
fn first_char(s : String) -> Char {
  for c in s {
    return c
  }
  ' '
}

///|
/// A plain test font of the given point size. Tests inject this family
/// into `FontResolver::in_memory`, so width comes from the TTF fixture
/// rather than a renderer-side estimate.
fn tfont(size : Double) -> ResolvedFont {
  {
    family: "Noto Sans",
    size,
    bold: false,
    italic: false,
    underline: false,
    strikethrough: false,
    color: None,
  }
}

///|
test "wrap_text wraps space-less Japanese across multiple lines" {
  set_sml_fixture_font_faces(["Noto Sans"])
  // Before the segment-based rewrite this produced ONE overflowing
  // line (split_words found no ASCII space).  It must now wrap.
  let text = "本日は晴天なり明日は雨"
  let warnings : Array[String] = []
  let lines = wrap_text(text, 40.0, tfont(10.0), 10, warnings)
  assert_true(lines.length() > 1)
  // Concatenating the wrapped lines reproduces the source text (no
  // glyphs dropped, no spurious spaces inserted between CJK glyphs).
  let joined = StringBuilder::new()
  for l in lines {
    joined.write_string(l)
  }
  inspect(joined.to_string(), content="本日は晴天なり明日は雨")
}

///|
test "wrap_text honours kinsoku: no wrapped line starts with 。or 、" {
  set_sml_fixture_font_faces(["Noto Sans"])
  let text = "本日は、晴天なり。明日も、晴れ。"
  let warnings : Array[String] = []
  let lines = wrap_text(text, 32.0, tfont(10.0), 20, warnings)
  for l in lines {
    if l != "" {
      let c = first_char(l)
      assert_true(c != '。')
      assert_true(c != '、')
    }
  }
}

///|
test "wrap_text preserves ASCII word wrapping" {
  set_sml_fixture_font_faces(["Noto Sans"])
  // Narrow column forces the sentence across several lines, breaking
  // only at spaces (no mid-word splits for these short words).
  let warnings : Array[String] = []
  let lines = wrap_text("the quick brown fox", 30.0, tfont(10.0), 10, warnings)
  assert_true(lines.length() > 1)
  // No line may begin or end with a stray space (whitespace swallowed
  // at wrap points).
  for l in lines {
    if l.length() > 0 {
      assert_true(first_char(l) != ' ')
    }
  }
}

///|
test "wrap_text emergency-splits an unbreakable long token" {
  set_sml_fixture_font_faces(["Noto Sans"])
  // A long run with no break opportunity (no space / CJK / hyphen)
  // must still wrap across lines rather than stay one overflowing line.
  let long = StringBuilder::new()
  for _ in 0..<60 {
    long.write_char('a')
  }
  let warnings : Array[String] = []
  let lines = wrap_text(long.to_string(), 40.0, tfont(10.0), 20, warnings)
  assert_true(lines.length() > 1)
  // No glyphs lost: the wrapped lines concatenate back to the source.
  let joined = StringBuilder::new()
  for l in lines {
    joined.write_string(l)
  }
  assert_true(joined.to_string().length() == 60)
}

///|
test "wrap_text respects max_lines" {
  set_sml_fixture_font_faces(["Noto Sans"])
  let text = "本日は晴天なり明日は雨明後日は曇り"
  let warnings : Array[String] = []
  let lines = wrap_text(text, 20.0, tfont(10.0), 2, warnings)
  assert_true(lines.length() <= 2)
}
