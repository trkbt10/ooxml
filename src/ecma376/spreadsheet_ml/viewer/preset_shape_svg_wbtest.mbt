// §20.1.10.55 ST_ShapeType — verify that the SML preset dispatcher
// routes every enumerated preset through the shared geometry
// builder.  We don't pin the exact SVG `d=` body for each (the
// builder owns those tests under preset_geometry/) — we only
// assert that the dispatcher returns Some(d) for spec values and
// None for schema violations.

///|
test "render_preset_shape_d resolves rectangular family" {
  // §20.1.10.55 rectangular family — 9 presets.
  for
    prst in [
      "rect", "roundRect", "round1Rect", "round2SameRect", "round2DiagRect", "snipRoundRect",
      "snip1Rect", "snip2SameRect", "snip2DiagRect",
    ] {
    let result = render_preset_shape_d(prst, 100.0, 50.0)
    assert_true(result is Some(_))
  }
}

///|
test "render_preset_shape_d resolves arrow family" {
  for
    prst in [
      "rightArrow", "leftArrow", "upArrow", "downArrow", "leftRightArrow", "upDownArrow",
      "bentArrow", "uturnArrow", "circularArrow",
    ] {
    let result = render_preset_shape_d(prst, 100.0, 50.0)
    assert_true(result is Some(_))
  }
}

///|
test "render_preset_shape_d resolves callout family" {
  for
    prst in [
      "callout1", "callout2", "callout3", "wedgeRectCallout", "wedgeRoundRectCallout",
      "wedgeEllipseCallout", "cloudCallout",
    ] {
    let result = render_preset_shape_d(prst, 100.0, 50.0)
    assert_true(result is Some(_))
  }
}

///|
test "render_preset_shape_d resolves star family" {
  for
    prst in [
      "star4", "star5", "star6", "star7", "star8", "star10", "star12", "star16",
      "star24", "star32",
    ] {
    let result = render_preset_shape_d(prst, 100.0, 50.0)
    assert_true(result is Some(_))
  }
}

///|
test "render_preset_shape_d resolves flowchart family" {
  for
    prst in [
      "flowChartProcess", "flowChartDecision", "flowChartInputOutput", "flowChartPredefinedProcess",
      "flowChartInternalStorage", "flowChartDocument", "flowChartMultidocument",
      "flowChartTerminator", "flowChartPreparation", "flowChartManualInput", "flowChartManualOperation",
      "flowChartConnector", "flowChartPunchedCard", "flowChartOffpageConnector",
    ] {
    let result = render_preset_shape_d(prst, 100.0, 50.0)
    assert_true(result is Some(_))
  }
}

///|
test "render_preset_shape_d resolves action button family" {
  for
    prst in [
      "actionButtonBlank", "actionButtonHome", "actionButtonHelp", "actionButtonInformation",
      "actionButtonForwardNext", "actionButtonBackPrevious", "actionButtonEnd", "actionButtonBeginning",
      "actionButtonReturn", "actionButtonDocument", "actionButtonSound", "actionButtonMovie",
    ] {
    let result = render_preset_shape_d(prst, 100.0, 50.0)
    assert_true(result is Some(_))
  }
}

///|
test "render_preset_shape_d resolves geometric primitives" {
  for
    prst in [
      "triangle", "rtTriangle", "diamond", "parallelogram", "trapezoid", "pentagon",
      "hexagon", "heptagon", "octagon", "decagon", "dodecagon", "ellipse", "teardrop",
      "homePlate", "chevron", "plus", "moon", "sun", "heart", "smileyFace", "cube",
      "can", "lightningBolt",
    ] {
    let result = render_preset_shape_d(prst, 100.0, 50.0)
    assert_true(result is Some(_))
  }
}

///|
test "render_preset_shape_d returns None for schema violation" {
  // §20.1.10.55 — `unknownShape` is not in ST_ShapeType.
  @debug.debug_inspect(render_preset_shape_d("unknownShape", 100.0, 50.0), content="None")
  @debug.debug_inspect(render_preset_shape_d("", 100.0, 50.0), content="None")
}

///|
test "render_preset_shape_d returns None for zero-sized bbox" {
  @debug.debug_inspect(render_preset_shape_d("rect", 0.0, 50.0), content="None")
  @debug.debug_inspect(render_preset_shape_d("rect", 100.0, 0.0), content="None")
  @debug.debug_inspect(render_preset_shape_d("rect", -10.0, 50.0), content="None")
}

///|
test "render_preset_shape_d emits SVG path syntax" {
  // §20.1.10.55 rect — produces a closed rectangular path.
  let d = render_preset_shape_d("rect", 100.0, 50.0).unwrap()
  // The path must start with a MoveTo command and end with a
  // ClosePath (the spec-mandated `Z`).
  assert_true(d.has_prefix("M "))
  assert_true(d.has_suffix("Z"))
}

///|
/// §18.18.55 ST_PatternType — verify the density family produces
/// the spec-mandated coloured-pixel count.  Each <rect width="1">
/// contributes one pixel to the 64-pixel tile, so we count the
/// rect occurrences in the generated pattern body.
test "build_pattern_def density family matches spec coverage" {
  // Helper — count occurrences of the substring "<rect " in the
  // generated pattern body (one per coloured pixel).
  let count_dots = fn(s : String) -> Int {
    let needle = "<rect x=\""
    let mut count = 0
    let mut idx = 0
    let nlen = needle.length()
    while idx + nlen <= s.length() {
      let slice = s[idx:idx + nlen].to_owned()
      if slice == needle {
        count = count + 1
        idx = idx + nlen
      } else {
        idx = idx + 1
      }
    }
    // The background rect uses `<rect width=…>` (no `x=` attr),
    // so the needle only matches the density-dot squares.
    count
  }
  // §18.18.55 — `build_pattern_def` returns an `@xml.Element` tree
  // (or `None`); serialise it once so the pixel-count assertion can
  // inspect the rendered `<rect>` squares.
  let render = fn(name : String) -> String {
    match build_pattern_def("pat-test", name, "#000000", "#ffffff") {
      Some(@xml.Node::Element(e)) => @markup.serialize(e)
      _ => ""
    }
  }
  // 6.25 % → 4/64
  @debug.assert_eq(count_dots(render("gray0625")), 4)
  // 12.5 % → 8/64
  @debug.assert_eq(count_dots(render("gray125")), 8)
  // 25 % → 16/64
  @debug.assert_eq(count_dots(render("lightGray")), 16)
  // 50 % → 32/64
  @debug.assert_eq(count_dots(render("mediumGray")), 32)
  // 75 % → 48/64
  @debug.assert_eq(count_dots(render("darkGray")), 48)
}

///|
test "build_pattern_def returns empty for schema-violating name" {
  assert_true(
    build_pattern_def("p", "unknownPattern", "#000000", "#ffffff") is None,
  )
  assert_true(build_pattern_def("p", "", "#000000", "#ffffff") is None)
}
