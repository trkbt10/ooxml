// §21.2.2.103 ST_MarkerStyle — the stroke-based marker glyphs
// (x / plus / star / dash) must render as `<path>` strokes rather than
// falling back to the default filled circle, and "dot" must be a
// smaller filled circle than "circle".

///|
/// Count occurrences of `needle` in `s`.
fn marker_count_substr(s : String, needle : String) -> Int {
  let mut count = 0
  let mut idx = 0
  let nlen = needle.length()
  while idx + nlen <= s.length() {
    if s[idx:idx + nlen].to_owned() == needle {
      count = count + 1
      idx = idx + nlen
    } else {
      idx = idx + 1
    }
  }
  count
}

///|
/// Serialise a single marker glyph to SVG text.
fn marker_svg(symbol : String) -> String {
  match render_marker(10.0, 10.0, 5.0, symbol, "#123456") {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
}

///|
test "§21.2.2.103 x/plus/star/dash markers render as stroked paths" {
  // Each stroke glyph is a single <path> painting the series colour as
  // the STROKE (not fill) since it has no enclosed area.
  for sym in ["x", "plus", "star", "dash"] {
    let svg = marker_svg(sym)
    assert_true(svg.contains("<path"))
    assert_true(svg.contains("fill=\"none\""))
    assert_true(svg.contains("stroke=\"#123456\""))
  }
  // §21.2.2.103 — the asterisk "star" overlays the orthogonal cross on
  // the diagonal cross: 4 subpaths (4 "M " move commands).  "plus" and
  // "x" are 2-stroke crosses; "dash" is a single bar.
  assert_eq(marker_count_substr(marker_svg("star"), "M "), 4)
  assert_eq(marker_count_substr(marker_svg("plus"), "M "), 2)
  assert_eq(marker_count_substr(marker_svg("x"), "M "), 2)
  assert_eq(marker_count_substr(marker_svg("dash"), "M "), 1)
}

///|
test "§21.2.2.103 dot marker is a smaller circle than circle/default" {
  // "dot" → filled circle at 60% of the marker radius.
  let dot = marker_svg("dot")
  assert_true(dot.contains("<circle"))
  assert_true(dot.contains("r=\"" + format_double(5.0 * 0.6) + "\""))
  assert_true(dot.contains("fill=\"#123456\""))
  // The default / "circle" glyph keeps the full marker radius.
  let circle = marker_svg("circle")
  assert_true(circle.contains("<circle"))
  assert_true(circle.contains("r=\"" + format_double(5.0) + "\""))
  // "none" emits an empty group, never a visible glyph.
  let none = marker_svg("none")
  assert_true(!none.contains("<circle"))
  assert_true(!none.contains("<path"))
}
