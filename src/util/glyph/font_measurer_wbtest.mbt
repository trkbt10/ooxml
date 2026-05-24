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
/// Cross-pipeline width regression: our `@glyph` measurer's Carlito
/// 11 pt advance for "Lorem ipsum dolor sit amet," must match (within
/// 1 px) the same metric obtained from LibreOffice's PDF render of
/// the section-cols-3-equal fixture (167.23 px = 125.422 pt) and the
/// rsvg-convert + PANGOCAIRO_BACKEND=fontconfig raster of the same
/// string at the same size (≈ 168 px).
///
/// Why this exists: before snapshot.sh exported
/// `PANGOCAIRO_BACKEND=fontconfig` (Round 13), rsvg-convert on macOS
/// silently substituted Carlito with Liberation Sans, producing a
/// raster ~13 px (≈ 8 %) wider than our measurer and LO's PDF on the
/// same string. The width gap looked like a measurer bug but was
/// actually a Pango/CoreText font-discovery gap. This test pins the
/// measurer side of the contract so a regression there would surface
/// independently of the snapshot harness.
test "Carlito 11pt 'Lorem ipsum dolor sit amet,' width matches LO PDF" {
  let w = measure_text_width(
    "Lorem ipsum dolor sit amet,",
    font_size_pt=11.0,
    letter_spacing_px=0.0,
    font_family=Some("Carlito"),
  )
  // LO's PDF places this exact string with xMax-xMin = 125.422 pt
  // (verified via `pdftotext -bbox-layout` on
  // .snapshots/fixtures/docx/section/section-cols-3-equal.docx).
  // 125.422 pt × (96/72) = 167.229 px.
  let lo_pdf_px = 125.422 * 96.0 / 72.0
  let diff = w - lo_pdf_px
  let abs_diff = if diff < 0.0 { -diff } else { diff }
  // Allow 0.5 px slack for PDF round-tripping.
  assert_true(abs_diff < 0.5)
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
