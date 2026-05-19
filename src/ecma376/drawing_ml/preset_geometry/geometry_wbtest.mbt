///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
fn parse_root(source : String) -> @xml.Element {
  try! @xml.parse(bytes(source)).root
}

///|
test "§20.1.10.56 ST_ShapeType decoder accepts every canonical preset" {
  // Spot-check across families: rectangular, arrow, callout, star,
  // flow-chart, action-button, banner, math.
  assert_true(try! (PresetShape::from_attr("rect") is ShapeRect))
  assert_true(try! (PresetShape::from_attr("roundRect") is ShapeRoundRect))
  assert_true(try! (PresetShape::from_attr("ellipse") is ShapeEllipse))
  assert_true(try! (PresetShape::from_attr("triangle") is ShapeTriangle))
  assert_true(try! (PresetShape::from_attr("diamond") is ShapeDiamond))
  assert_true(try! (PresetShape::from_attr("rightArrow") is ShapeRightArrow))
  assert_true(try! (PresetShape::from_attr("star5") is ShapeStar5))
  assert_true(try! (PresetShape::from_attr("callout1") is ShapeCallout1))
  assert_true(
    try! (PresetShape::from_attr("flowChartProcess") is ShapeFlowChartProcess),
  )
  assert_true(try! (PresetShape::from_attr("mathPlus") is ShapeMathPlus))
  assert_true(try! (PresetShape::from_attr("heart") is ShapeHeart))
  assert_true(try! (PresetShape::from_attr("cloud") is ShapeCloud))
}

///|
test "§20.1.10.56 ST_ShapeType decoder rejects unknown lexical values" {
  let bad = try? PresetShape::from_attr("definitely-not-a-shape")
  assert_true(bad is Err(_))
}

///|
test "§20.1.10.56 PresetShape::family classifies every family bucket" {
  assert_true(ShapeRect.family() == FamilyRectangular)
  assert_true(ShapeRightArrow.family() == FamilyArrow)
  assert_true(ShapeCallout1.family() == FamilyCallout)
  assert_true(ShapeStar5.family() == FamilyStar)
  assert_true(ShapeFlowChartProcess.family() == FamilyFlowChart)
  assert_true(ShapeActionButtonHome.family() == FamilyActionButton)
  assert_true(ShapeStraightConnector1.family() == FamilyConnector)
  assert_true(ShapeLeftBracket.family() == FamilyBracket)
  assert_true(ShapeMathPlus.family() == FamilyMath)
  assert_true(ShapeRibbon.family() == FamilyBanner)
}

///|
test "§20.1.9.18 decode_preset_geometry reads prst + avLst overrides" {
  let element = parse_root(
    "<a:prstGeom xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" prst=\"roundRect\"><a:avLst><a:gd name=\"adj\" fmla=\"val 25000\"/></a:avLst></a:prstGeom>",
  )
  let pg = try! decode_preset_geometry(element)
  assert_true(pg.shape is ShapeRoundRect)
  assert_eq(pg.adjustments.length(), 1)
  assert_eq(pg.adjustments[0].name, "adj")
  assert_eq(pg.adjustments[0].value, Some(25000))
}

///|
test "§20.1.9.18 decode_preset_geometry handles missing avLst" {
  let element = parse_root(
    "<a:prstGeom xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" prst=\"rect\"/>",
  )
  let pg = try! decode_preset_geometry(element)
  assert_true(pg.shape is ShapeRect)
  assert_eq(pg.adjustments.length(), 0)
}

///|
test "§20.1.9.18 decode_preset_geometry rejects missing @prst" {
  let element = parse_root(
    "<a:prstGeom xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"/>",
  )
  let bad = try? decode_preset_geometry(element)
  assert_true(bad is Err(_))
}

///|
test "§20.1.9.18 decode_preset_geometry rejects empty @prst" {
  let element = parse_root(
    "<a:prstGeom xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" prst=\"\"/>",
  )
  let bad = try? decode_preset_geometry(element)
  assert_true(bad is Err(_))
}

///|
test "§20.1.9.18 decode_preset_geometry rejects unknown @prst" {
  let element = parse_root(
    "<a:prstGeom xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" prst=\"notARealShape\"/>",
  )
  let bad = try? decode_preset_geometry(element)
  assert_true(bad is Err(_))
}

///|
test "§20.1.9.11 decode_adjustment parses val n formulas" {
  let element = parse_root("<gd name=\"adj1\" fmla=\"val 33333\"/>")
  let adj = try! decode_adjustment(element)
  assert_eq(adj.name, "adj1")
  assert_eq(adj.raw_formula, "val 33333")
  assert_eq(adj.value, Some(33333))
}

///|
test "§20.1.9.11 decode_adjustment preserves non-val formulas" {
  let element = parse_root("<gd name=\"y1\" fmla=\"*/ h 2 3\"/>")
  let adj = try! decode_adjustment(element)
  assert_eq(adj.name, "y1")
  assert_eq(adj.value, None)
  assert_eq(adj.raw_formula, "*/ h 2 3")
}

///|
test "§20.1.9.11 decode_adjustment rejects missing attributes" {
  let no_name = parse_root("<gd fmla=\"val 0\"/>")
  let bad1 = try? decode_adjustment(no_name)
  assert_true(bad1 is Err(_))
  let no_fmla = parse_root("<gd name=\"adj1\"/>")
  let bad2 = try? decode_adjustment(no_fmla)
  assert_true(bad2 is Err(_))
}

///|
test "build_geometry rect emits 4 vertices and closes" {
  let g = build_geometry(ShapeRect, 200, 100)
  assert_eq(g.width, 200)
  assert_eq(g.height, 100)
  assert_eq(g.command_count(), 5)
  assert_true(g.is_closed())
  assert_true(g.commands[0] is MoveTo(0, 0))
  assert_true(g.commands[1] is LineTo(200, 0))
  assert_true(g.commands[2] is LineTo(200, 100))
  assert_true(g.commands[3] is LineTo(0, 100))
}

///|
test "build_geometry ellipse emits two ArcTo halves" {
  let g = build_geometry(ShapeEllipse, 200, 100)
  // MoveTo + ArcTo + ArcTo + ClosePath = 4
  assert_eq(g.command_count(), 4)
  assert_true(g.is_closed())
  assert_true(g.commands[0] is MoveTo(_, _))
  assert_true(g.commands[1] is ArcTo(_, _, _, _, _, _, _))
  assert_true(g.commands[2] is ArcTo(_, _, _, _, _, _, _))
}

///|
test "build_geometry triangle emits three sides and closes" {
  let g = build_geometry(ShapeTriangle, 100, 100)
  assert_eq(g.command_count(), 4)
  assert_true(g.is_closed())
  assert_true(g.commands[0] is MoveTo(50, 0))
  assert_true(g.commands[1] is LineTo(100, 100))
  assert_true(g.commands[2] is LineTo(0, 100))
}

///|
test "build_geometry rightArrow emits 7-vertex outline" {
  let g = build_geometry(ShapeRightArrow, 200, 100)
  // MoveTo + 6 LineTo + ClosePath = 8
  assert_eq(g.command_count(), 8)
  assert_true(g.is_closed())
  assert_true(g.commands[0] is MoveTo(_, _))
  // Tip is at the right edge (x = width).
  let mut saw_tip = false
  for cmd in g.commands {
    match cmd {
      LineTo(x, _) => if x == 200 { saw_tip = true }
      _ => ()
    }
  }
  assert_true(saw_tip)
}

///|
test "build_geometry star5 emits 10 alternating vertices" {
  let g = build_geometry(ShapeStar5, 100, 100)
  // MoveTo + 9 LineTo + ClosePath = 11
  assert_eq(g.command_count(), 11)
  assert_true(g.is_closed())
  // First vertex is the top outer point at y ≈ 0.
  match g.commands[0] {
    MoveTo(x, y) => {
      assert_true(x == 50)
      assert_true(y <= 5)
    }
    _ => fail("expected MoveTo at the top of star5")
  }
}

///|
test "build_geometry callout1 emits rectangular body + leader" {
  let g = build_geometry(ShapeCallout1, 200, 200)
  // Body = 5 commands (rect). Plus MoveTo + LineTo for leader = 7.
  assert_eq(g.command_count(), 7)
  // The closing ClosePath is on the body, not the leader; the
  // leader segment after the close means is_closed() returns false.
  assert_true(!g.is_closed())
  // First five commands form the closed body rectangle.
  assert_true(g.commands[0] is MoveTo(0, 0))
  assert_true(g.commands[4] is ClosePath)
  // The last command is the leader line.
  assert_true(g.commands[6] is LineTo(_, _))
}

///|
test "build_geometry pentagon emits 5 vertices + close" {
  let g = build_geometry(ShapePentagon, 100, 100)
  assert_eq(g.command_count(), 6)
  assert_true(g.is_closed())
}

///|
test "build_geometry hexagon emits 6 vertices + close" {
  let g = build_geometry(ShapeHexagon, 100, 100)
  assert_eq(g.command_count(), 7)
  assert_true(g.is_closed())
}

///|
test "build_geometry diamond emits 4 vertices + close" {
  let g = build_geometry(ShapeDiamond, 100, 100)
  assert_eq(g.command_count(), 5)
  assert_true(g.is_closed())
}

///|
test "build_geometry flowChartProcess delegates to rect" {
  let g = build_geometry(ShapeFlowChartProcess, 100, 50)
  assert_eq(g.command_count(), 5)
  assert_true(g.is_closed())
  assert_true(g.commands[0] is MoveTo(0, 0))
}

///|
test "build_geometry flowChartDecision delegates to diamond" {
  let g = build_geometry(ShapeFlowChartDecision, 100, 100)
  assert_eq(g.command_count(), 5)
  assert_true(g.is_closed())
}

///|
test "build_geometry flowChartConnector delegates to ellipse" {
  let g = build_geometry(ShapeFlowChartConnector, 100, 100)
  assert_eq(g.command_count(), 4)
  assert_true(g.is_closed())
}

///|
test "build_geometry fallback used for unsupported preset" {
  let g = build_geometry(ShapeFunnel, 100, 100)
  assert_eq(g.command_count(), 5)
  assert_true(g.is_closed())
  assert_true(g.commands[0] is MoveTo(0, 0))
  // The fallback is the canonical rectangle: opposite corner at
  // (width, height).
  assert_true(g.commands[2] is LineTo(100, 100))
}

///|
test "supports() reports faithful coverage for the canonical 30+" {
  assert_true(supports(ShapeRect))
  assert_true(supports(ShapeRoundRect))
  assert_true(supports(ShapeEllipse))
  assert_true(supports(ShapeTriangle))
  assert_true(supports(ShapeDiamond))
  assert_true(supports(ShapePentagon))
  assert_true(supports(ShapeStar5))
  assert_true(supports(ShapeRightArrow))
  assert_true(supports(ShapeCallout1))
  assert_true(supports(ShapeHeart))
  assert_true(supports(ShapePlus))
  assert_true(supports(ShapeMathEqual))
  assert_true(supports(ShapeFlowChartProcess))
  assert_true(supports(ShapeFlowChartDecision))
  assert_true(supports(ShapeFlowChartConnector))
  assert_true(supports(ShapeFlowChartInputOutput))
  // Not supported: should fall back.
  assert_true(!supports(ShapeFunnel))
  assert_true(!supports(ShapeGear6))
}

///|
test "build_geometry handles degenerate inputs without overflow" {
  let g0 = build_geometry(ShapeRect, 0, 100)
  assert_eq(g0.command_count(), 0)
  let g1 = build_geometry(ShapeRect, 100, -5)
  assert_eq(g1.command_count(), 0)
}

///|
test "§20.1.10.56 section-name accessor" {
  assert_eq(
    preset_geometry_part1_20_1_10_56_section_name(),
    "Part 1 §20.1.10.56",
  )
}

///|
test "ShapeGeometry::is_closed reports false for empty" {
  let g : ShapeGeometry = { commands: [], width: 0, height: 0 }
  assert_true(!g.is_closed())
}

///|
test "flowchart_family_section helper string" {
  assert_eq(flowchart_family_section(), "Part 1 §20.1.10.56 flowChart*")
}
