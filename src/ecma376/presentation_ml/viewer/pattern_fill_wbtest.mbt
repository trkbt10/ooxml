// §20.1.10.51 ST_PresetPatternVal — geometric preset hatches render
// as real tile geometry (lines / grids / checks / diamonds / dots),
// not a single coverage stripe.

///|
fn patt_svg(prst : String) -> String {
  let node = build_text_pattern_def("p", prst, "#ff0000", "#ffffff")
  match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
}

///|
test "line presets emit stroked lines, not a coverage rect" {
  // Horizontal / vertical / diagonal all draw a <line>.
  for p in ["horz", "vert", "dnDiag", "upDiag", "narVert", "dkHorz"] {
    let svg = patt_svg(p)
    assert_true(svg.contains("<line "))
    assert_true(svg.contains("stroke=\"#ff0000\""))
  }
}

///|
test "dashed line presets carry a dash pattern" {
  for p in ["dashHorz", "dashVert", "dashDnDiag", "dashUpDiag"] {
    let svg = patt_svg(p)
    assert_true(svg.contains("stroke-dasharray=\"3 3\""))
  }
}

///|
test "cross and diagCross emit two crossing lines" {
  // cross = a horizontal line (y1=y2=4) plus a vertical line (x1=x2=4).
  let svg = patt_svg("cross")
  assert_true(svg.contains("x1=\"0\"") && svg.contains("y1=\"4\""))
  assert_true(svg.contains("x1=\"4\"") && svg.contains("y1=\"0\""))
  // diagCross = both diagonals.
  let dc = patt_svg("diagCross")
  assert_true(dc.contains("x1=\"0\"") && dc.contains("y2=\"8\""))
  assert_true(dc.contains("y1=\"8\"") && dc.contains("y2=\"0\""))
}

///|
test "checkerboard and diamond presets emit shapes" {
  // Checkerboard → background rect + two quadrant rects = 3 rects.
  assert_true(patt_svg("lgCheck").contains("<rect "))
  // Solid diamond → a filled polygon.
  let dmnd = patt_svg("solidDmnd")
  assert_true(dmnd.contains("<polygon "))
  assert_true(dmnd.contains("fill=\"#ff0000\""))
  // Open diamond → stroked, fill none.
  let open = patt_svg("openDmnd")
  assert_true(open.contains("fill=\"none\""))
  assert_true(open.contains("stroke=\"#ff0000\""))
}

///|
test "dot-based presets emit circles" {
  for p in ["dotGrid", "dotDmnd", "smConfetti", "lgConfetti"] {
    assert_true(patt_svg(p).contains("<circle "))
  }
}

///|
test "percentage presets render a density dot via the shared source" {
  // pct* now resolves through the shared `pattern_tile_marks`, which
  // renders the percentage as a centred dot whose area tracks the
  // density (more faithful than the old coverage stripe).
  let svg = patt_svg("pct25")
  assert_true(svg.contains("<rect ")) // background panel
  assert_true(svg.contains("<circle "))
}

///|
test "an unknown text preset degrades to a coverage stripe" {
  let svg = patt_svg("notARealPreset")
  // Two rects: the background panel + the 50% coverage stripe.
  assert_true(svg.contains("height=\"8\""))
  assert_true(svg.contains("height=\"4\""))
  assert_true(!svg.contains("<line "))
  assert_true(!svg.contains("<circle "))
}
