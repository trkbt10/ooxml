// White-box tests for the text-layout engine and its companion
// modules (measurer / line breaker / auto-number).

///|
/// Inject a deterministic test font so `measure_span` returns real
/// metrics regardless of the host font catalogue. Without this, hosts
/// that lack "Noto Sans" raise `FontUnresolvedError` on every
/// measurement call.
let test_font_ready : Ref[Bool] = { val: false }

fn ensure_test_font() -> Unit {
  if test_font_ready.val {
    return
  }
  test_font_ready.val = true
  let bytes = try @fs.read_file_to_bytes(
      "src/util/glyph/fixtures/subset.ttf",
    ) catch {
    _ => abort("Cannot load test font fixture src/util/glyph/fixtures/subset.ttf")
  } noraise {
    b => b
  }
  @glyph.set_default_font_set(
    @glyph.FontSet::new(
      resolver=@glyph.FontResolver::in_memory(
        Map([("Noto Sans", bytes)], capacity=1),
      ),
    ),
  )
}

///|
/// Build a plain LayoutSpan for testing.
fn tl_make_span(
  text : String,
  font_size? : Double = 18.0,
  font_family? : String = "Noto Sans",
) -> LayoutSpan {
  {
    text,
    font_size,
    font_family,
    font_family_east_asian: None,
    font_family_complex_script: None,
    font_family_symbol: None,
    font_weight: 400,
    font_style: "normal",
    text_decoration: None,
    color: "#000000",
    vertical_align: "baseline",
    baseline_pct: 0.0,
    letter_spacing: 0.0,
    is_break: false,
    direction: "ltr",
    highlight_color: None,
    text_transform: None,
    link_id: None,
    link_tooltip: None,
    mouse_over_link_id: None,
    mouse_over_link_tooltip: None,
    bookmark: None,
    text_outline: None,
    text_fill: None,
    kerning: None,
    underline_color: None,
    underline_style: None,
  }
}

///|
test "measure_span on a non-empty ASCII string" {
  ensure_test_font()
  let s = tl_make_span("Hello", font_size=24.0)
  let m = measure_span(s)
  assert_true(m.width > 0.0)
}

///|
test "measure_span returns 0 for a line break" {
  let s : LayoutSpan = { ..tl_make_span(""), is_break: true }
  let m = measure_span(s)
  inspect(m.width, content="0")
}

///|
test "format_auto_number — arabic period" {
  inspect(format_auto_number("arabicPeriod", 1), content="1.")
  inspect(format_auto_number("arabicPeriod", 5), content="5.")
  inspect(format_auto_number("arabicPeriod", 1, start_at=10), content="10.")
}

///|
test "format_auto_number — roman lowercase" {
  inspect(format_auto_number("romanLcParenR", 1), content="i)")
  inspect(format_auto_number("romanLcParenR", 4), content="iv)")
  inspect(format_auto_number("romanLcParenR", 9), content="ix)")
}

///|
test "format_auto_number — alphabetic upper" {
  inspect(format_auto_number("alphaUcPeriod", 1), content="A.")
  inspect(format_auto_number("alphaUcPeriod", 26), content="Z.")
  inspect(format_auto_number("alphaUcPeriod", 27), content="AA.")
}

///|
test "format_auto_number — circled numbers" {
  // U+2460 = ①, codepoint 9312
  inspect(format_auto_number("circleNumDbPlain", 1), content="①")
  inspect(format_auto_number("circleNumDbPlain", 20), content="⑳")
  // Out-of-range falls back to plain integer.
  inspect(format_auto_number("circleNumDbPlain", 21), content="21")
}

///|
test "format_auto_number — Thai numeric digit substitution" {
  // §21.1.2.1.32 thaiNum* — Thai digits U+0E50..U+0E59.
  // 1 -> ๑, 5 -> ๕, 12 -> ๑๒.
  inspect(format_auto_number("thaiNumPeriod", 1), content="๑.")
  inspect(format_auto_number("thaiNumParenR", 5), content="๕)")
  inspect(format_auto_number("thaiNumParenBoth", 12), content="(๑๒)")
}

///|
test "format_auto_number — Hindi numeric digit substitution" {
  // §21.1.2.1.32 hindiNum* — Devanagari digits U+0966..U+096F.
  // 1 -> १, 7 -> ७, 23 -> २३.
  inspect(format_auto_number("hindiNumPeriod", 1), content="१.")
  inspect(format_auto_number("hindiNumParenR", 7), content="७)")
  inspect(format_auto_number("hindiNumPeriod", 23), content="२३.")
}

///|
test "format_auto_number — Hebrew gematria numerals" {
  // §21.1.2.1.32 hebrew*Minus — Hebrew alphabetic numbering.
  // 1 -> א with geresh, then the scheme's trailing minus.
  inspect(format_auto_number("hebrew1Minus", 1), content="א׳-")
  // 11 -> yod(10) + alef(1), gershayim before the final letter.
  inspect(format_auto_number("hebrew2Minus", 11), content="י״א-")
  // 15 and 16 are special-cased to 9+6 / 9+7 by convention.
  inspect(format_auto_number("hebrew1Minus", 15), content="ט״ו-")
  inspect(format_auto_number("hebrew1Minus", 16), content="ט״ז-")
  // 123 -> qof(100) + kaf(20) + gimel(3).
  inspect(format_auto_number("hebrew2Minus", 123), content="קכ״ג-")
  // 500 -> tav(400) + qof(100).
  inspect(format_auto_number("hebrew1Minus", 500), content="ת״ק-")
}

///|
test "format_auto_number — CJK ideographic numerals (Chinese)" {
  // §21.1.2.1.32 ea1Chs / ea1Cht — Chinese orthography.
  inspect(format_auto_number("ea1ChsPlain", 1), content="一")
  inspect(format_auto_number("ea1ChsPlain", 10), content="十")
  inspect(format_auto_number("ea1ChsPlain", 11), content="十一")
  inspect(format_auto_number("ea1ChsPlain", 20), content="二十")
  inspect(format_auto_number("ea1ChsPeriod", 99), content="九十九.")
  // The hundreds digit is always written; 100 -> 一百.
  inspect(format_auto_number("ea1ChsPlain", 100), content="一百")
  // Interior zero: 105 -> 一百〇五 (zero glyph fills the empty tens).
  inspect(format_auto_number("ea1ChsPlain", 105), content="一百〇五")
  // A tens place of 1 inside a larger number is written 一十.
  inspect(format_auto_number("ea1ChtPlain", 110), content="一百一十")
  inspect(format_auto_number("ea1ChsPeriod", 123), content="一百二十三.")
  inspect(format_auto_number("ea1ChtPeriod", 999), content="九百九十九.")
}

///|
test "format_auto_number — CJK ideographic numerals (Japanese)" {
  // §21.1.2.1.32 ea1Jpn* — Japanese / Korean orthography: a
  // leading 1 in the hundreds / tens place is elided and no
  // interior zero glyph is written.
  inspect(format_auto_number("ea1JpnKorPlain", 10), content="十")
  inspect(format_auto_number("ea1JpnKorPeriod", 100), content="百.")
  // 105 -> 百五 (no interior zero), 110 -> 百十 (no 一 before 十).
  inspect(format_auto_number("ea1JpnKorPlain", 105), content="百五")
  inspect(format_auto_number("ea1JpnKorPlain", 110), content="百十")
  inspect(format_auto_number("ea1JpnChsDbPeriod", 123), content="百二十三.")
  inspect(
    format_auto_number("ea1JpnKorPlainPeriod", 999),
    content="九百九十九.",
  )
}

///|
test "format_auto_number — unknown scheme falls back" {
  // §21.1.2.1.32 — schema violation; we render the numeric value
  // with no decoration since we cannot infer which separator the
  // unknown scheme intended.  The raw scheme name should be
  // surfaced upstream as data-ooxml-bullet-scheme metadata.
  inspect(format_auto_number("notAScheme", 7), content="7")
}

///|
test "break_into_lines respects explicit line breaks" {
  ensure_test_font()
  let a = tl_make_span("Hello", font_size=18.0)
  let b : LayoutSpan = { ..tl_make_span("", font_size=18.0), is_break: true }
  let c = tl_make_span("World", font_size=18.0)
  let result = break_into_lines(
    measure_spans([a, b, c]),
    1000.0, // first_line_width
    1000.0, // next_line_width
    WrapSquare,
  )
  // Two lines: ["Hello"], ["World"]
  inspect(result.lines.length(), content="2")
}

///|
test "break_into_lines wraps long text" {
  ensure_test_font()
  // A very wide text on a very narrow box must wrap.
  let s = tl_make_span(
    "The quick brown fox jumps over the lazy dog",
    font_size=24.0,
  )
  let result = break_into_lines(
    measure_spans([s]),
    50.0, // narrow first_line_width
    50.0,
    WrapSquare,
  )
  assert_true(result.lines.length() > 1)
}

///|
/// `get_line_visible_width` trims trailing whitespace from the last
/// span before summing — needed so wrapped lines that retain the
/// space character that caused the wrap centre correctly. Without
/// this trim, every centred / right-aligned wrapped line drifts
/// half-a-space to the right.
test "get_line_visible_width trims trailing whitespace" {
  ensure_test_font()
  let s1 = tl_make_span("Hello ", font_size=24.0)
  let spans = measure_spans([s1])
  let full = get_line_width(spans)
  let visible = get_line_visible_width(spans)
  // The trimmed width must be strictly less than the full width by
  // exactly one space's advance at this font/size. We don't pin the
  // absolute pixel value — the metrics tables move — but the delta
  // has to be positive AND match the space's measured width.
  assert_true(full > visible)
  let space_w = @glyph.measure_text_width(
    " ",
    font_size_pt=24.0,
    letter_spacing_px=0.0,
    family="Noto Sans",
  )
  // Allow a 1e-6 epsilon because both sides come from the same
  // measurer and arithmetic should be exact.
  let delta = full - visible
  assert_true((delta - space_w).abs() < 1.0e-6)
}

///|
test "get_line_visible_width returns 0 for whitespace-only line" {
  ensure_test_font()
  // An empty span produces 0 width and is unaffected; a span that is
  // ALL whitespace gets trimmed down to zero — centring such a line
  // would otherwise place it left-of-centre by half-its-own-width.
  let only_ws = tl_make_span("   ", font_size=24.0)
  let spans = measure_spans([only_ws])
  inspect(get_line_visible_width(spans), content="0")
}

///|
test "get_line_visible_width preserves interior whitespace" {
  ensure_test_font()
  // Only the trailing run of whitespace is excluded — interior
  // spaces between visible glyphs must still count toward the
  // alignment width.
  let s = tl_make_span("Hi there", font_size=24.0)
  let spans = measure_spans([s])
  let full = get_line_width(spans)
  let visible = get_line_visible_width(spans)
  // No trailing whitespace → visible width equals full width.
  inspect(full == visible, content="true")
}

///|
test "layout_text_body lays out a single short line" {
  let s = tl_make_span("Hello", font_size=24.0)
  let para : LayoutParagraphInput = {
    spans: [s],
    alignment: AlignLeft,
    margin_left: 0.0,
    indent: 0.0,
    margin_right: 0.0,
    space_before: 0.0,
    space_after: 0.0,
    line_spacing: None,
    bullet: None,
    font_alignment: FontAlignBase,
    default_tab_size: 36.0,
    tab_stops: [],
    ea_line_break: true,
    latin_line_break: true,
    hanging_punctuation: false,
    end_para_font_size: None,
  }
  let input : LayoutInput = {
    text_box: {
      width: 200.0,
      height: 100.0,
      inset_left: 0.0,
      inset_right: 0.0,
      inset_top: 0.0,
      inset_bottom: 0.0,
      anchor: AnchorTop,
      anchor_center: false,
      wrap_mode: WrapSquare,
      auto_fit: AutoFitNone,
      horz_overflow: OverflowAllow,
      vert_overflow: VertOverflowAllow,
      compat_ln_spc: false,
      force_aa: false,
      rtl_col: false,
      spc_first_last_para: false,
      upright: false,
      vertical_type: VertHorz,
    },
    paragraphs: [para],
  }
  let result = layout_text_body(input)
  inspect(result.paragraphs.length(), content="1")
  inspect(result.paragraphs[0].lines.length(), content="1")
  // Baseline must be positive (above 0 in SVG y-down coordinates).
  assert_true(result.paragraphs[0].lines[0].y > 0.0)
}

///|
/// §21.1.2.1.32 hindiAlphaPeriod — Hindi vowels (§17.18.59
/// `hindiVowels`, 37-glyph set U+0915–U+0939) with the repeated-
/// letter algorithm: 1 → first glyph, 37 → last, 38 → doubled first.
test "format_auto_number — Hindi vowel alphabetic numbering" {
  // U+0915 क, U+0939 ह.
  inspect(format_auto_number("hindiAlphaPeriod", 1), content="क.")
  inspect(format_auto_number("hindiAlphaPeriod", 37), content="ह.")
  // 38 wraps: the first glyph written twice.
  inspect(format_auto_number("hindiAlphaPeriod", 38), content="कक.")
}

///|
/// §21.1.2.1.32 hindiAlpha1Period — Hindi consonants (§17.18.59
/// `hindiConsonants`, 18-glyph set: U+0905–U+0914 then U+0905+U+0902
/// and U+0905+U+0903).
test "format_auto_number — Hindi consonant alphabetic numbering" {
  // U+0905 अ, U+0914 औ.
  inspect(format_auto_number("hindiAlpha1Period", 1), content="अ.")
  inspect(format_auto_number("hindiAlpha1Period", 16), content="औ.")
  // Position 17 is U+0905 combined with U+0902.
  inspect(format_auto_number("hindiAlpha1Period", 17), content="अं.")
  // 19 wraps past the 18-glyph set: first glyph doubled.
  inspect(format_auto_number("hindiAlpha1Period", 19), content="अअ.")
}

///|
/// §21.1.2.1.32 thaiAlpha* — Thai letters (§17.18.59 `thaiLetters`,
/// 41-glyph set: U+0E01, U+0E02, U+0E04, U+0E07–U+0E23, U+0E25,
/// U+0E27–U+0E2E).
test "format_auto_number — Thai letter alphabetic numbering" {
  // U+0E01 ก, U+0E02 ข, U+0E04 ค.
  inspect(format_auto_number("thaiAlphaPeriod", 1), content="ก.")
  inspect(format_auto_number("thaiAlphaParenR", 2), content="ข)")
  inspect(format_auto_number("thaiAlphaParenBoth", 3), content="(ค)")
  // 42 wraps past the 41-glyph set: first glyph doubled.
  inspect(format_auto_number("thaiAlphaPeriod", 42), content="กก.")
}
