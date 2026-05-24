// White-box tests for the low-level `FontMeasurer` API.
//
// These tests exercise the parser and the per-glyph metric helpers
// using `subset.ttf`, a small bundled fixture that ships with the
// package for parser-self-testing only (NOT a renderer font).
// Renderer-facing tests inject real fonts via the `FontResolver`
// instead of touching `make_font_measurer` directly.

///|
/// Read the parser fixture shipped under `src/util/glyph/fixtures/`.
/// `moon test` resolves paths relative to the workspace root.
fn load_subset_font() -> Bytes raise @fs.IOError {
  @fs.read_file_to_bytes("src/util/glyph/fixtures/subset.ttf")
}

///|
test "make_font_measurer rejects garbage bytes" {
  match make_font_measurer(b"not a font") {
    None => ()
    Some(_) => fail("Expected None for invalid font bytes")
  }
}

///|
test "make_font_measurer parses subset.ttf" {
  let bytes = load_subset_font()
  guard make_font_measurer(bytes) is Some(m) else {
    fail("Failed to parse subset.ttf")
  }
  // subset.ttf is built with units_per_em = 1000.
  inspect(m.units_per_em, content="1000")
}

///|
test "FontMeasurer::char_advance scales linearly with font size" {
  let bytes = load_subset_font()
  guard make_font_measurer(bytes) is Some(m) else {
    fail("Failed to parse subset.ttf")
  }
  let w12 = m.char_advance('A', font_size_pt=12.0)
  let w24 = m.char_advance('A', font_size_pt=24.0)
  assert_true(w12 > 0.0)
  let diff = w24 - 2.0 * w12
  let abs_diff = if diff < 0.0 { -diff } else { diff }
  assert_true(abs_diff < 1.0e-6)
}

///|
test "FontMeasurer::ascender_ratio is in (0, 1.5]" {
  let bytes = load_subset_font()
  guard make_font_measurer(bytes) is Some(m) else {
    fail("Failed to parse subset.ttf")
  }
  let ratio = m.ascender_ratio()
  assert_true(ratio > 0.0)
  // Ascent > 1.5 em is unheard of in real fonts; this guards
  // against units_per_em decoding regressions.
  assert_true(ratio <= 1.5)
}

///|
test "make_font_measurer_at returns None when ttc_index is out of range on a TTF" {
  let bytes = load_subset_font()
  // subset.ttf is a single-face TTF, not a TTC, so requesting any
  // non-trivial index must fail rather than silently return face 0.
  match make_font_measurer_at(bytes, Some(0)) {
    None => () // Expected: parse_font_at refuses non-TTC bytes.
    Some(_) => fail("Expected None for ttc_index on non-TTC bytes")
  }
}

///|
test "FontMeasurer::with_gpos_kern attaches a non-empty map" {
  let bytes = load_subset_font()
  guard make_font_measurer(bytes) is Some(base) else {
    fail("Failed to parse subset.ttf")
  }
  // subset.ttf likely has no GPOS kerning, so we attach a synthetic
  // entry and verify the map flows through to kerning_adjust.
  let synthetic : Array[GposKernEntry] = [
    { first: 'A'.to_int(), second: 'V'.to_int(), x_advance: -100 },
  ]
  let m = base.with_gpos_kern(synthetic)
  // 'AV' should now produce a negative kerning value (the legacy
  // kern table doesn't override it for subset.ttf).
  let adjust = m.kerning_adjust('A', 'V', font_size_pt=12.0)
  assert_true(adjust < 0.0)
}
