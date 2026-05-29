// §18.3.1.49 iconSet — the conditional-format icon glyphs render as
// real SVG primitives (arrows / circles / bars / stars / pies), not
// metadata-only placeholders.

///|
fn icon_layout() -> CellLayout {
  {
    x: 10.0,
    y: 20.0,
    width: 80.0,
    height: 18.0,
    colspan: 1,
    rowspan: 1,
    is_merge_origin: false,
    is_hidden_by_merge: false,
  }
}

///|
fn icon_count_substr(s : String, needle : String) -> Int {
  let n = needle.length()
  if n == 0 {
    return 0
  }
  let mut count = 0
  let mut i = 0
  while i + n <= s.length() {
    if s[i:i + n] == needle {
      count = count + 1
      i = i + n
    } else {
      i = i + 1
    }
  }
  count
}

///|
fn icon_svg(set_name : String, bucket : Int) -> (String, Double) {
  let (nodes, reserved) = render_cell_icon_glyph(icon_layout(), set_name, bucket)
  let sb = StringBuilder::new()
  for n in nodes {
    match n {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  (sb.to_string(), reserved)
}

///|
test "arrow icon sets render a rotated polygon, graded by band" {
  let (svg, reserved) = icon_svg("3Arrows", 2)
  assert_true(svg.contains("<polygon "))
  assert_true(svg.contains("transform=\"rotate("))
  // highest band → green grade.
  assert_true(svg.contains("#4ca030"))
  // glyph reserves horizontal space for the text shift.
  assert_true(reserved > 0.0)
  // metadata is preserved on the group.
  assert_true(svg.contains("data-ooxml-icon=\"3Arrows\""))
  assert_true(svg.contains("data-ooxml-bucket=\"2\""))
  // gray variant uses grey, not the grade colour.
  assert_true(icon_svg("3ArrowsGray", 2).0.contains("#808080"))
}

///|
test "traffic-light / sign / flag sets render a graded circle" {
  for s in ["3TrafficLights1", "3TrafficLights2", "3Signs", "3Flags", "3Symbols"] {
    let (svg, _) = icon_svg(s, 0)
    assert_true(svg.contains("<circle "))
    // lowest band → red grade.
    assert_true(svg.contains("#e03030"))
  }
}

///|
test "RedToBlack runs the circle colour from black (low) to red (high)" {
  // 4RedToBlack, lowest band → black-ish.
  assert_true(icon_svg("4RedToBlack", 0).0.contains("#000000"))
  // highest band → red.
  assert_true(icon_svg("4RedToBlack", 3).0.contains("#e03030"))
}

///|
test "rating / boxes sets render a segmented bar" {
  let (svg, _) = icon_svg("5Rating", 2)
  // count=5 segments → five <rect>.
  assert_eq(icon_count_substr(svg, "<rect"), 5)
  assert_true(icon_svg("5Boxes", 1).0.contains("<rect "))
}

///|
test "5Quarters renders a pie circle + sector path" {
  let (svg, _) = icon_svg("5Quarters", 2)
  assert_true(svg.contains("<circle "))
  assert_true(svg.contains("<path "))
  // full band → a solid filled circle (no partial sector needed).
  assert_true(icon_svg("5Quarters", 4).0.contains("<circle "))
}

///|
test "3Stars renders a row of star polygons" {
  let (svg, _) = icon_svg("3Stars", 1)
  // three star polygons.
  assert_eq(icon_count_substr(svg, "<polygon"), 3)
  // the lowest two bands are gold-filled, the rest grey.
  assert_true(svg.contains("#f0b000"))
  assert_true(svg.contains("#d0d0d0"))
}
