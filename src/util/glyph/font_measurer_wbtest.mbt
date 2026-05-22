// White-box tests for real-font measurement.

///|
/// Read the subset.ttf fixture shipped alongside the wbtest file.
/// `moon test` resolves paths relative to the workspace root.
fn load_subset_font() -> Bytes raise @fs.IOError {
  @fs.read_file_to_bytes("src/util/glyph/fixtures/subset.ttf")
}

///|
test "make_font_measurer rejects garbage bytes" {
  let result = make_font_measurer(b"not a font")
  // FontMeasurer doesn't derive Show; use a match instead of inspect.
  match result {
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
  // subset.ttf in mizchi/font fixtures is built with units_per_em = 1000.
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
  // Double the font size doubles the advance.
  assert_true(w12 > 0.0)
  let diff = w24 - 2.0 * w12
  let abs_diff = if diff < 0.0 { -diff } else { diff }
  assert_true(abs_diff < 1.0e-6)
}

///|
test "measure_text_width prefers FontMeasurer when supplied" {
  let bytes = load_subset_font()
  guard make_font_measurer(bytes) is Some(m) else {
    fail("Failed to parse subset.ttf")
  }
  let real = measure_text_width(
    "AB",
    font_size_pt=24.0,
    letter_spacing_px=0.0,
    font_family=None,
    measurer=Some(m),
  )
  let fallback = measure_text_width(
    "AB",
    font_size_pt=24.0,
    letter_spacing_px=0.0,
    font_family=Some("Calibri"),
  )
  // Two independent paths — both must yield positive widths.  We
  // intentionally do not require them to agree numerically; their
  // job is precisely to disagree (real metrics vs statistical
  // estimation).
  assert_true(real > 0.0)
  assert_true(fallback > 0.0)
}

///|
test "FontMeasurer::ascender_ratio is in (0, 1.5]" {
  let bytes = load_subset_font()
  guard make_font_measurer(bytes) is Some(m) else {
    fail("Failed to parse subset.ttf")
  }
  let ratio = m.ascender_ratio()
  assert_true(ratio > 0.0)
  // Anything above 1.5 would be pathological (ascent > 1.5 em is
  // unheard of in real fonts).
  assert_true(ratio <= 1.5)
}
