// §17.18.99 / §21.1.2.3.32 ST_Underline — dotted / dashed / dash-dot
// underline variants paint a real stroke-dasharray pattern (no longer
// degrading to a solid line).

///|
test "underline_dasharray maps dash/dotted variants to patterns" {
  // dotted: [1,2] × w.  w=2 → "2 4".
  match underline_dasharray("dotted", 2.0) {
    Some(p) => inspect(p, content="2 4")
    None => fail("expected dotted dasharray")
  }
  // dash: [4,3] × w.  w=1 → "4 3".
  match underline_dasharray("dash", 1.0) {
    Some(p) => inspect(p, content="4 3")
    None => fail("expected dash dasharray")
  }
  // dotDash: [4,3,1,3] × w.  w=1 → "4 3 1 3".
  match underline_dasharray("dotDash", 1.0) {
    Some(p) => inspect(p, content="4 3 1 3")
    None => fail("expected dotDash dasharray")
  }
  // dashLongHeavy maps the same as dashLong.
  match underline_dasharray("dashLongHeavy", 1.0) {
    Some(p) => inspect(p, content="8 3")
    None => fail("expected dashLong dasharray")
  }
}

///|
test "underline_dasharray returns None for solid variants" {
  for s in ["sng", "single", "words", "thick", "heavy", "dbl"] {
    match underline_dasharray(s, 1.0) {
      None => ()
      Some(p) => fail("solid variant \{s} unexpectedly dashed: " + p)
    }
  }
}

///|
test "build_underline_line emits stroke-dasharray when dashed" {
  let node = build_underline_line(
    0.0, 100.0, 10.0, 1.0, "#000000", dasharray=Some("4 3"),
  )
  let svg = match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
  assert_true(svg.contains("stroke-dasharray=\"4 3\""))
  assert_true(svg.contains("stroke-linecap=\"round\""))
}

///|
test "build_underline_line stays solid without a dash pattern" {
  let node = build_underline_line(0.0, 100.0, 10.0, 1.0, "#000000")
  let svg = match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
  assert_true(!svg.contains("stroke-dasharray"))
}
