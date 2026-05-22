// White-box tests for `util/glyph`.  Each test pins the behaviour
// against the corresponding `@aurochs/glyph` reference in web-pptx
// so future regressions are caught immediately.

///|
test "is_cjk_code_point classifies Unicode ranges" {
  // CJK Unified Ideographs (e.g. 漢)
  assert_true(is_cjk_code_point(0x6F22))
  // Hiragana (e.g. あ)
  assert_true(is_cjk_code_point(0x3042))
  // Katakana (e.g. ア)
  assert_true(is_cjk_code_point(0x30A2))
  // Halfwidth / Fullwidth Forms (full-width digit ０ U+FF10)
  assert_true(is_cjk_code_point(0xFF10))
  // Latin 'A' must not be CJK.
  assert_false(is_cjk_code_point(0x0041))
  // ASCII space must not be CJK.
  assert_false(is_cjk_code_point(0x0020))
}

///|
test "get_font_category resolves common families" {
  inspect(get_font_category(Some("Arial")), content="SansSerif")
  inspect(get_font_category(Some("ARIAL, sans-serif")), content="SansSerif")
  inspect(get_font_category(Some("Times New Roman")), content="Serif")
  inspect(get_font_category(Some("Consolas")), content="Monospace")
  inspect(get_font_category(Some("Yu Gothic")), content="CJK")
  inspect(get_font_category(None), content="SansSerif")
}

///|
test "is_monospace identifies fixed-width families" {
  assert_true(is_monospace(Some("Consolas")))
  assert_true(is_monospace(Some("Courier New")))
  assert_false(is_monospace(Some("Arial")))
  assert_false(is_monospace(None))
}

///|
test "Calibri char widths match web-pptx values" {
  // Sample of Calibri overrides (from calibri.ts:30). Mostly we are
  // confirming the override table survived the port.
  let metrics = get_font_metrics(Some("Calibri"))
  inspect(metrics.char_widths.get('i'), content="Some(0.24)")
  inspect(metrics.char_widths.get(' '), content="Some(0.28)")
  inspect(metrics.ascender_ratio, content="Some(0.75)")
  inspect(metrics.width_scale, content="Some(1.08)")
}

///|
test "get_char_width applies bold scale" {
  // Calibri 'A' regular: latin override absent → latinAverage 0.52 × widthScale 1.08
  let regular = get_char_width('A', Some("Calibri"), false)
  // 'A' override is 0.65 from DEFAULT_CHAR_WIDTHS via medium_chars,
  // so width = 0.65 × 1.08 = 0.702.
  inspect(regular, content="0.7020000000000001")
  // Bold: × 1.05 default → 0.65 × 1.08 × 1.05.
  let bold = get_char_width('A', Some("Calibri"), false, font_weight=700)
  inspect(bold, content="0.7371000000000001")
}

///|
test "get_kerning_adjustment for known sans-serif pair" {
  // SANS_SERIF_KERNING tightens AV to -0.1 (from common_kerning_pairs' -0.08).
  inspect(get_kerning_adjustment("AV", Some("Arial")), content="-0.1")
  // Calibri also uses SANS_SERIF_KERNING so same value.
  inspect(get_kerning_adjustment("AV", Some("Calibri")), content="-0.1")
  // Unknown pair → 0
  inspect(get_kerning_adjustment("XQ", Some("Calibri")), content="0")
  // Non-pair input → 0
  inspect(get_kerning_adjustment("A", Some("Calibri")), content="0")
}

///|
test "get_ascender_ratio resolves common families" {
  inspect(get_ascender_ratio(Some("Calibri")), content="0.75")
  inspect(get_ascender_ratio(Some("Times New Roman")), content="0.8")
  inspect(get_ascender_ratio(None), content="0.8")
  // Substring match: "Hiragino Kaku Gothic ProN" → no exact key, but
  // none of the ASCENDER_RATIOS keys appear as substring → default
  // 0.8.
  inspect(get_ascender_ratio(Some("UnknownFamily")), content="0.8")
}

///|
test "measure_text_width returns positive width for ASCII" {
  // Width must be > 0 for non-empty Latin text. We don't pin an
  // exact value — the algorithm is documented elsewhere.
  let w = measure_text_width(
    "Hello",
    font_size_pt=24.0,
    letter_spacing_px=0.0,
    font_family=Some("Calibri"),
  )
  assert_true(w > 0.0)
}

///|
test "measure_text_width is zero for empty string" {
  inspect(
    measure_text_width(
      "",
      font_size_pt=24.0,
      letter_spacing_px=0.0,
      font_family=Some("Calibri"),
    ),
    content="0",
  )
}

///|
test "measure_text_detailed yields per-char positions" {
  let m = measure_text_detailed(
    "AB",
    font_size_pt=24.0,
    letter_spacing_px=0.0,
    font_family=Some("Calibri"),
  )
  inspect(m.char_widths.length(), content="2")
  inspect(m.positions.length(), content="2")
  // First char always starts at 0.
  inspect(m.positions[0], content="0")
  // Second char starts at first char's total width.
  assert_true(m.positions[1] > 0.0)
}

///|
test "is_monospace disables kerning in calculate_char_width" {
  // 'fi' has -0.02 kerning in sans-serif but 0 in monospace because
  // resolve_kerning_adjust short-circuits.
  let mono = calculate_char_width(
    'i',
    prev_char=Some('f'),
    font_size_pt=24.0,
    font_family=Some("Consolas"),
  )
  inspect(mono.kerning_adjust, content="0")
  let sans = calculate_char_width(
    'i',
    prev_char=Some('f'),
    font_size_pt=24.0,
    font_family=Some("Arial"),
  )
  assert_true(sans.kerning_adjust < 0.0)
}
