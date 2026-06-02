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
test "FontMeasurer::char_advance reads .notdef hmtx for missing CJK glyphs" {
  let bytes = load_subset_font()
  guard make_font_measurer(bytes) is Some(m) else {
    fail("Failed to parse subset.ttf")
  }
  let cjk = Int::unsafe_to_char(0x6F22)
  @debug.assert_eq(m.glyph_index(cjk.to_int()), 0)
  let font_size_pt = 12.0
  let scale = font_size_pt * pt_to_px / m.units_per_em.to_double()
  let expected = m.ttfont.glyph_metrics(0).advance_width.to_double() * scale
  let actual = m.char_advance(cjk, font_size_pt~)
  assert_true((actual - expected).abs() < 1.0e-6)
  assert_true(actual != font_size_pt * pt_to_px)
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
test "FontMeasurer::char_outline_contours flattens a glyph into pixel points" {
  let bytes = load_subset_font()
  guard make_font_measurer(bytes) is Some(m) else {
    fail("Failed to parse subset.ttf")
  }
  let contours = m.char_outline_contours(
    'A',
    font_size_pt=72.0,
    pen_x=0.0,
    tolerance=0.5,
  )
  // 'A' has at least one outer contour with a handful of vertices.
  assert_true(contours.length() >= 1)
  let mut total_pts = 0
  let mut max_y = -1.0e18
  for c in contours {
    total_pts = total_pts + c.length()
    for p in c {
      // Baseline at y=0, ascenders go NEGATIVE (screen y-down flip).
      if p.1 > max_y {
        max_y = p.1
      }
    }
  }
  assert_true(total_pts >= 3)
  // A capital 'A' sits on the baseline, so its lowest point is ~0
  // (not far below); just assert the flip produced finite extents.
  assert_true(max_y <= 1.0)
}

///|
test "FontMeasurer::char_outline_contours offsets x by the pen position" {
  let bytes = load_subset_font()
  guard make_font_measurer(bytes) is Some(m) else {
    fail("Failed to parse subset.ttf")
  }
  fn min_x(pen : Double) -> Double {
    let cs = m.char_outline_contours(
      'A',
      font_size_pt=48.0,
      pen_x=pen,
      tolerance=0.5,
    )
    let mut mn = 1.0e18
    for c in cs {
      for p in c {
        if p.0 < mn {
          mn = p.0
        }
      }
    }
    mn
  }

  // Shifting the pen by 100 px shifts every outline point by 100 px.
  let shift = min_x(100.0) - min_x(0.0)
  assert_true((shift - 100.0).abs() < 1.0e-6)
}

///|
test "text_outline_contours lays glyphs left-to-right at advances" {
  let bytes = load_subset_font()
  glyph_test_set_font(bytes)
  let one = (try? text_outline_contours(
    "A",
    family="Noto Sans",
    font_size_pt=48.0,
  )).unwrap_or([])
  let two = (try? text_outline_contours(
    "AA",
    family="Noto Sans",
    font_size_pt=48.0,
  )).unwrap_or([])
  assert_true(one.length() >= 1)
  // The second 'A' contributes additional contours past the first.
  assert_true(two.length() > one.length())
  // …and its points reach farther right than the single glyph.
  fn max_x(cs : Array[Array[(Double, Double)]]) -> Double {
    let mut mx = -1.0e18
    for c in cs {
      for p in c {
        if p.0 > mx {
          mx = p.0
        }
      }
    }
    mx
  }

  assert_true(max_x(two) > max_x(one))
}

///|
/// Register `bytes` as the default "Noto Sans" face for the package
/// tests that exercise the resolver-backed `text_outline_contours`.
fn glyph_test_set_font(bytes : Bytes) -> Unit {
  set_default_font_set(
    FontSet::new(
      resolver=FontResolver::in_memory(Map([("Noto Sans", bytes)], capacity=1)),
    ),
  )
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
