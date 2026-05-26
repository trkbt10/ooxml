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
  @debug.assert_eq(pg.adjustments[0].value, Some(25000))
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
  @debug.assert_eq(adj.value, Some(33333))
}

///|
test "§20.1.9.11 decode_adjustment preserves non-val formulas" {
  let element = parse_root("<gd name=\"y1\" fmla=\"*/ h 2 3\"/>")
  let adj = try! decode_adjustment(element)
  assert_eq(adj.name, "y1")
  @debug.assert_eq(adj.value, None)
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
test "rectangular_fallback emits the canonical bounding rectangle" {
  // Every ST_ShapeType preset now has a faithful generator, so the
  // fallback path is exercised by calling `rectangular_fallback`
  // directly — it backs any future preset that lacks a generator.
  let g = rectangular_fallback(100, 100)
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
  // Faithful generators now cover the gear / seal / curved-arrow set.
  assert_true(supports(ShapeFunnel))
  assert_true(supports(ShapeGear6))
  // The full ST_ShapeType enumeration is now faithfully covered,
  // including the formerly-approximated swoosh / circular arrows.
  assert_true(supports(ShapeSwooshArrow))
  assert_true(supports(ShapeLeftCircularArrow))
  assert_true(supports(ShapeLeftRightCircularArrow))
}

///|
test "build_geometry handles degenerate inputs without overflow" {
  let g0 = build_geometry(ShapeRect, 0, 100)
  assert_eq(g0.command_count(), 0)
  let g1 = build_geometry(ShapeRect, 100, -5)
  assert_eq(g1.command_count(), 0)
}

///|
test "build_geometry flowChartMerge emits a downward triangle" {
  let g = build_geometry(ShapeFlowChartMerge, 200, 100)
  // Triangle: MoveTo + 2 LineTo + ClosePath.
  assert_eq(g.command_count(), 4)
  assert_true(g.is_closed())
  assert_true(g.commands[0] is MoveTo(0, 0))
  assert_true(supports(ShapeFlowChartMerge))
}

///|
test "build_geometry flowChartSort emits diamond body + divider line" {
  let g = build_geometry(ShapeFlowChartSort, 200, 100)
  // Diamond body (MoveTo + 3 LineTo + ClosePath) plus a stroke-only
  // 2-vertex divider sub-path; the divider has no ClosePath.
  assert_eq(g.command_count(), 7)
  assert_true(g.commands[0] is MoveTo(0, _))
  assert_true(g.commands[4] is ClosePath)
  assert_true(supports(ShapeFlowChartSort))
}

///|
test "build_geometry flowChartOr emits ellipse body + two diameters" {
  let g = build_geometry(ShapeFlowChartOr, 200, 200)
  // Ellipse body (MoveTo + 2 ArcTo + ClosePath) plus two stroke-only
  // diameter sub-paths (MoveTo + LineTo each).
  assert_eq(g.command_count(), 8)
  assert_true(g.commands[1] is ArcTo(_, _, _, _, _, _, _))
  assert_true(g.commands[3] is ClosePath)
  assert_true(supports(ShapeFlowChartOr))
}

///|
test "supports() covers the flowchart preset family" {
  assert_true(supports(ShapeFlowChartMultidocument))
  assert_true(supports(ShapeFlowChartPreparation))
  assert_true(supports(ShapeFlowChartManualInput))
  assert_true(supports(ShapeFlowChartManualOperation))
  assert_true(supports(ShapeFlowChartExtract))
  assert_true(supports(ShapeFlowChartPunchedCard))
  assert_true(supports(ShapeFlowChartPunchedTape))
  assert_true(supports(ShapeFlowChartCollate))
  assert_true(supports(ShapeFlowChartSummingJunction))
  assert_true(supports(ShapeFlowChartOfflineStorage))
  assert_true(supports(ShapeFlowChartOnlineStorage))
  assert_true(supports(ShapeFlowChartMagneticDisk))
  assert_true(supports(ShapeFlowChartMagneticDrum))
  assert_true(supports(ShapeFlowChartMagneticTape))
  assert_true(supports(ShapeFlowChartDelay))
  assert_true(supports(ShapeFlowChartDisplay))
  assert_true(supports(ShapeFlowChartOffpageConnector))
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

///|
/// §20.1.10.56 — the polygon / block / chart-marker family now has
/// faithful geometry generators instead of the rectangular fallback.
/// `homePlate` is the canonical five-vertex point-right pentagon.
test "build_geometry homePlate emits a five-vertex pentagon" {
  let g = build_geometry(ShapeHomePlate, 200, 100)
  assert_eq(g.width, 200)
  assert_eq(g.height, 100)
  // MoveTo + 4 LineTo + ClosePath = 6.
  assert_eq(g.command_count(), 6)
  assert_true(g.is_closed())
  assert_true(g.commands[0] is MoveTo(0, 0))
  // The right-edge point sits at the vertical midline.
  assert_true(g.commands[2] is LineTo(200, 50))
  assert_true(supports(ShapeHomePlate))
}

///|
/// §20.1.10.56 `chevron` — a six-vertex arrow band: both the right
/// edge and the left edge carry a point / notch.
test "build_geometry chevron emits a six-vertex arrow band" {
  let g = build_geometry(ShapeChevron, 200, 100)
  // MoveTo + 5 LineTo + ClosePath = 7.
  assert_eq(g.command_count(), 7)
  assert_true(g.is_closed())
  assert_true(supports(ShapeChevron))
}

///|
/// §20.1.10.56 `frame` — a hollow rectangular band, emitted as an
/// outer rectangle plus a concentric inner rectangle (two sub-paths,
/// two ClosePath commands).
test "build_geometry frame emits a hollow band with two sub-paths" {
  let g = build_geometry(ShapeFrame, 200, 100)
  // Outer (MoveTo + 3 LineTo + Close) + inner (MoveTo + 3 LineTo +
  // Close) = 10.
  assert_eq(g.command_count(), 10)
  assert_true(supports(ShapeFrame))
}

///|
/// §20.1.10.56 `lightningBolt` / `irregularSeal1` — literal-vertex
/// polygons from the 21600-unit spec frame. The bolt is an
/// eleven-vertex closed polygon; seal 1 is twenty-four vertices.
test "build_geometry lightningBolt and seals emit literal polygons" {
  let bolt = build_geometry(ShapeLightningBolt, 216, 216)
  // MoveTo + 10 LineTo + ClosePath = 12.
  assert_eq(bolt.command_count(), 12)
  assert_true(bolt.is_closed())
  assert_true(bolt.commands[0] is MoveTo(84, 0))
  assert_true(supports(ShapeLightningBolt))
  let seal1 = build_geometry(ShapeIrregularSeal1, 216, 216)
  // MoveTo + 23 LineTo + ClosePath = 25.
  assert_eq(seal1.command_count(), 25)
  assert_true(seal1.is_closed())
  let seal2 = build_geometry(ShapeIrregularSeal2, 216, 216)
  // MoveTo + 27 LineTo + ClosePath = 29.
  assert_eq(seal2.command_count(), 29)
  assert_true(supports(ShapeIrregularSeal2))
}

///|
/// §20.1.10.56 `gear6` / `gear9` — gear wheels whose teeth are
/// four-vertex trapezoids placed circularly. Each tooth contributes
/// four path commands, plus the final `ClosePath`.
test "build_geometry gears emit per-tooth trapezoid vertices" {
  let g6 = build_geometry(ShapeGear6, 200, 200)
  // 6 teeth * 4 vertices + ClosePath = 25.
  assert_eq(g6.command_count(), 25)
  assert_true(g6.is_closed())
  assert_true(g6.commands[0] is MoveTo(_, _))
  assert_true(supports(ShapeGear6))
  let g9 = build_geometry(ShapeGear9, 200, 200)
  // 9 teeth * 4 vertices + ClosePath = 37.
  assert_eq(g9.command_count(), 37)
  assert_true(supports(ShapeGear9))
}

///|
/// §20.1.10.56 curved-arrow + `circularArrow` + `funnel` family —
/// each emits a closed multi-segment band with `ArcTo` rim edges.
test "build_geometry curved arrows and funnel emit closed arc bands" {
  for
    shape in [
      ShapeCurvedRightArrow,
      ShapeCurvedLeftArrow,
      ShapeCurvedUpArrow,
      ShapeCurvedDownArrow,
      ShapeCircularArrow,
      ShapeFunnel,
    ] {
    let g = build_geometry(shape, 200, 200)
    assert_eq(g.width, 200)
    assert_eq(g.height, 200)
    assert_true(g.is_closed())
    assert_true(g.commands[0] is MoveTo(_, _))
    assert_true(supports(shape))
  }
}

///|
/// §20.1.10.56 `cube` — an isometric cube drawn as three faces
/// (front, top, right), each a closed quadrilateral.
test "build_geometry cube emits three quadrilateral faces" {
  let g = build_geometry(ShapeCube, 200, 100)
  // Three faces × (MoveTo + 3 LineTo + Close) = 15.
  assert_eq(g.command_count(), 15)
  assert_true(supports(ShapeCube))
}

///|
/// §20.1.10.56 `chartStar` — a six-band asterisk marker: vertical +
/// horizontal + two diagonal bands, four closed sub-paths.
test "build_geometry chartStar emits four marker bands" {
  let g = build_geometry(ShapeChartStar, 120, 120)
  assert_true(g.is_closed())
  assert_true(supports(ShapeChartStar))
  // The first sub-path is the vertical band: MoveTo + 3 LineTo + Close.
  assert_true(g.commands[0] is MoveTo(_, _))
}

///|
/// §20.1.10.56 swooshArrow / leftCircularArrow / leftRightCircularArrow
/// — the final preset family. swoosh is a faithful tapered polygon;
/// the circular arrows are documented silhouette approximations.
test "build_geometry covers the swoosh / circular-arrow family" {
  let sw = build_geometry(ShapeSwooshArrow, 200, 100)
  assert_true(sw.is_closed())
  assert_true(supports(ShapeSwooshArrow))
  // 2 quad curves + 4 line segments + move + close.
  assert_eq(sw.command_count(), 8)
  let lc = build_geometry(ShapeLeftCircularArrow, 120, 120)
  assert_true(lc.is_closed())
  assert_true(supports(ShapeLeftCircularArrow))
  let lr = build_geometry(ShapeLeftRightCircularArrow, 120, 120)
  assert_true(lr.is_closed())
  assert_true(supports(ShapeLeftRightCircularArrow))
}

///|
/// §20.1.10.56 `round1Rect` / `snip1Rect` — corner-modified
/// rectangles. The rounded variant cuts its top-right corner with a
/// quarter-circle `ArcTo`; the snipped variant cuts the same corner
/// with a single diagonal `LineTo`. Both stay closed and faithful.
test "build_geometry round1Rect / snip1Rect cut the top-right corner" {
  let round = build_geometry(ShapeRound1Rect, 200, 100)
  assert_eq(round.width, 200)
  // MoveTo + LineTo + ArcTo + 2 LineTo + Close = 6.
  assert_eq(round.command_count(), 6)
  assert_true(round.is_closed())
  assert_true(round.commands[2] is ArcTo(_, _, _, _, _, _, _))
  assert_true(supports(ShapeRound1Rect))
  let snip = build_geometry(ShapeSnip1Rect, 200, 100)
  // MoveTo + 4 LineTo + Close = 6, all straight segments.
  assert_eq(snip.command_count(), 6)
  assert_true(snip.is_closed())
  assert_true(snip.commands[1] is LineTo(_, _))
  assert_true(snip.commands[2] is LineTo(200, _))
  assert_true(supports(ShapeSnip1Rect))
}

///|
/// §20.1.10.56 `wedgeRectCallout` — a rectangular speech bubble with
/// a triangular pointer spliced into the bottom edge; the tail tip
/// lies below the box for the default adjustments.
test "build_geometry wedgeRectCallout splices a wedge tail" {
  let g = build_geometry(ShapeWedgeRectCallout, 200, 100)
  // MoveTo + 6 LineTo + Close = 8; the wedge adds two extra vertices.
  assert_eq(g.command_count(), 8)
  assert_true(g.is_closed())
  // The tail tip sits below the bounding box (y > height).
  let mut saw_tail = false
  for cmd in g.commands {
    match cmd {
      LineTo(_, y) => if y > 100 { saw_tail = true }
      _ => ()
    }
  }
  assert_true(saw_tail)
  assert_true(supports(ShapeWedgeRectCallout))
}

///|
/// §20.1.10.56 `bracketPair` / `bracePair` — matched `[ ]` and `{ }`
/// decorations emitted as two open subpaths (no `ClosePath`).
test "build_geometry bracketPair / bracePair emit open paired outlines" {
  let brackets = build_geometry(ShapeBracketPair, 200, 100)
  assert_false(brackets.is_closed())
  assert_true(supports(ShapeBracketPair))
  // Two subpaths ⇒ two MoveTo commands.
  let mut moves = 0
  for cmd in brackets.commands {
    if cmd is MoveTo(_, _) {
      moves = moves + 1
    }
  }
  assert_eq(moves, 2)
  let braces = build_geometry(ShapeBracePair, 200, 100)
  assert_false(braces.is_closed())
  assert_true(supports(ShapeBracePair))
}

///|
test "build_geometry quadArrow emits a closed four-headed polygon" {
  let g = build_geometry(ShapeQuadArrow, 200, 200)
  assert_true(g.is_closed())
  assert_true(supports(ShapeQuadArrow))
  // The four arrowhead tips touch each edge midpoint.
  let mut saw_top = false
  let mut saw_bottom = false
  for cmd in g.commands {
    match cmd {
      LineTo(x, y) => {
        if x == 100 && y == 0 {
          saw_top = true
        }
        if x == 100 && y == 200 {
          saw_bottom = true
        }
      }
      _ => ()
    }
  }
  assert_true(saw_top)
  assert_true(saw_bottom)
}

///|
test "build_geometry rightArrowCallout has box plus arrowhead" {
  let g = build_geometry(ShapeRightArrowCallout, 200, 100)
  assert_true(g.is_closed())
  assert_true(supports(ShapeRightArrowCallout))
  // Outline starts at the box top-left corner.
  assert_true(g.commands[0] is MoveTo(0, 0))
  // The arrowhead tip reaches the right edge at the vertical centre.
  let mut saw_tip = false
  for cmd in g.commands {
    if cmd is LineTo(200, 50) {
      saw_tip = true
    }
  }
  assert_true(saw_tip)
}

///|
test "build_geometry stripedRightArrow emits three subpaths" {
  let g = build_geometry(ShapeStripedRightArrow, 200, 100)
  assert_true(supports(ShapeStripedRightArrow))
  // Two stripes plus the solid shaft ⇒ three MoveTo commands.
  let mut moves = 0
  for cmd in g.commands {
    if cmd is MoveTo(_, _) {
      moves = moves + 1
    }
  }
  assert_eq(moves, 3)
}

///|
test "build_geometry borderCallout1 emits rect body plus leader line" {
  let g = build_geometry(ShapeBorderCallout1, 200, 200)
  assert_true(supports(ShapeBorderCallout1))
  // Body = 5 rect commands; leader = MoveTo + LineTo ⇒ 7 total.
  assert_eq(g.command_count(), 7)
  // The body closes; the trailing open leader makes is_closed() false.
  assert_true(g.commands[0] is MoveTo(0, 0))
  assert_true(g.commands[4] is ClosePath)
  assert_true(!g.is_closed())
  assert_true(g.commands[6] is LineTo(_, _))
}

///|
test "build_geometry accentBorderCallout3 has accent bar and 3-bend leader" {
  let g = build_geometry(ShapeAccentBorderCallout3, 200, 200)
  assert_true(supports(ShapeAccentBorderCallout3))
  // 5 rect + 2 accent bar + 4 leader (MoveTo + 3 LineTo) = 11.
  assert_eq(g.command_count(), 11)
  // Three subpaths: body, accent bar, leader ⇒ three MoveTo commands.
  let mut moves = 0
  for cmd in g.commands {
    if cmd is MoveTo(_, _) {
      moves = moves + 1
    }
  }
  assert_eq(moves, 3)
}

///|
test "build_geometry cloudCallout emits cloud body and bubble trail" {
  let g = build_geometry(ShapeCloudCallout, 200, 200)
  assert_true(supports(ShapeCloudCallout))
  // Cloud body (1 MoveTo) plus three trailing bubbles (1 MoveTo each).
  let mut moves = 0
  for cmd in g.commands {
    if cmd is MoveTo(_, _) {
      moves = moves + 1
    }
  }
  assert_eq(moves, 4)
}

///|
/// §20.1.10.56 `actionButtonForwardNext` — a button face plus a
/// right-pointing triangle symbol. The face is 5 rect commands and
/// the triangle adds MoveTo + 2 LineTo + ClosePath, so the total
/// (9) exceeds the 5-command rectangular fallback.
test "build_geometry actionButtonForwardNext emits face plus triangle" {
  let g = build_geometry(ShapeActionButtonForwardNext, 200, 100)
  assert_eq(g.width, 200)
  assert_eq(g.height, 100)
  assert_true(supports(ShapeActionButtonForwardNext))
  // 5 face + 4 triangle commands ⇒ more than the 5-command fallback.
  assert_eq(g.command_count(), 9)
  assert_true(g.command_count() > 5)
  // Two subpaths: button face and symbol ⇒ two MoveTo commands.
  let mut moves = 0
  for cmd in g.commands {
    if cmd is MoveTo(_, _) {
      moves = moves + 1
    }
  }
  assert_eq(moves, 2)
}

///|
/// §20.1.10.56 `actionButtonHome` — the house symbol carries a roof
/// outline and a doorway cut-out as two distinct symbol subpaths, so
/// the geometry has three MoveTo commands and far exceeds the
/// fallback's 5 commands.
test "build_geometry actionButtonHome emits face plus house symbol" {
  let g = build_geometry(ShapeActionButtonHome, 200, 200)
  assert_true(supports(ShapeActionButtonHome))
  // 5 face + 12 house outline + 5 doorway = 22.
  assert_eq(g.command_count(), 22)
  assert_true(g.command_count() > 5)
  // Face + house outline + doorway ⇒ three MoveTo commands.
  let mut moves = 0
  for cmd in g.commands {
    if cmd is MoveTo(_, _) {
      moves = moves + 1
    }
  }
  assert_eq(moves, 3)
}

///|
/// §20.1.10.56 `actionButtonInformation` — the "i" symbol uses arc
/// sweeps for the disc and the dot, so the geometry contains ArcTo
/// commands and exceeds the rectangular fallback.
test "build_geometry actionButtonInformation emits arcs for the disc" {
  let g = build_geometry(ShapeActionButtonInformation, 200, 200)
  assert_true(supports(ShapeActionButtonInformation))
  assert_true(g.command_count() > 5)
  // The disc and dot are drawn with semicircle ArcTo sweeps.
  let mut arcs = 0
  for cmd in g.commands {
    if cmd is ArcTo(_, _, _, _, _, _, _) {
      arcs = arcs + 1
    }
  }
  assert_eq(arcs, 4)
}

///|
/// §20.1.10.56 `actionButtonBlank` — the lone action button with no
/// inner symbol; it is the bare bounding-box rectangle yet is still
/// reported as a faithful (non-fallback) geometry.
test "build_geometry actionButtonBlank emits a bare rectangle face" {
  let g = build_geometry(ShapeActionButtonBlank, 120, 80)
  assert_true(supports(ShapeActionButtonBlank))
  assert_eq(g.command_count(), 5)
  assert_true(g.is_closed())
  assert_true(g.commands[0] is MoveTo(0, 0))
}

///|
/// §20.1.10.56 `donut` — a hollow ring: an outer full ellipse and a
/// concentric inner full ellipse, each emitted as two 180° arcs.
test "build_geometry donut emits a hollow ring with two sub-paths" {
  let g = build_geometry(ShapeDonut, 200, 100)
  assert_eq(g.width, 200)
  assert_eq(g.height, 100)
  assert_true(supports(ShapeDonut))
  // Outer (MoveTo + 2 ArcTo + Close) + inner (MoveTo + 2 ArcTo +
  // Close) = 8.
  assert_eq(g.command_count(), 8)
  assert_true(g.is_closed())
  // Outer ellipse starts at the left-mid point (0, 50).
  assert_true(g.commands[0] is MoveTo(0, 50))
}

///|
/// §20.1.10.56 `pie` — an arc plus a line back to the centre. The
/// default 0°→270° slice starts at the right-mid point.
test "build_geometry pie emits an arc closed through the centre" {
  let g = build_geometry(ShapePie, 200, 100)
  assert_true(supports(ShapePie))
  // MoveTo + ArcTo + LineTo(centre) + Close = 4.
  assert_eq(g.command_count(), 4)
  assert_true(g.is_closed())
  assert_true(g.commands[0] is MoveTo(200, 50))
  assert_true(g.commands[2] is LineTo(100, 50))
}

///|
/// §20.1.10.56 `arc` — an open elliptical outline: a MoveTo and a
/// single ArcTo, with no closing segment.
test "build_geometry arc emits an open arc outline" {
  let g = build_geometry(ShapeArc, 200, 100)
  assert_true(supports(ShapeArc))
  // MoveTo + ArcTo, no ClosePath.
  assert_eq(g.command_count(), 2)
  assert_true(!g.is_closed())
  assert_true(g.commands[0] is MoveTo(_, _))
  assert_true(g.commands[1] is ArcTo(_, _, _, _, _, _, _))
}

///|
/// §20.1.10.56 `sun` — a central disc plus eight triangular rays.
test "build_geometry sun emits eight rays around a disc" {
  let g = build_geometry(ShapeSun, 200, 200)
  assert_true(supports(ShapeSun))
  // Eight rays (MoveTo + 2 LineTo + Close = 4 each) + disc (MoveTo +
  // 2 ArcTo + Close = 4) = 36.
  assert_eq(g.command_count(), 36)
  assert_true(g.is_closed())
  let mut moves = 0
  for cmd in g.commands {
    if cmd is MoveTo(_, _) {
      moves = moves + 1
    }
  }
  assert_eq(moves, 9)
}

///|
/// §20.1.10.56 `wave` / `doubleWave` — rectangles whose top and
/// bottom edges are sine waves drawn with cubic `CurveTo` segments.
/// `wave` carries one period per edge, `doubleWave` carries two.
test "build_geometry wave / doubleWave emit cubic sine edges" {
  let wave = build_geometry(ShapeWave, 200, 100)
  assert_eq(wave.width, 200)
  assert_true(supports(ShapeWave))
  // MoveTo + CurveTo + LineTo + CurveTo + Close = 5.
  assert_eq(wave.command_count(), 5)
  assert_true(wave.is_closed())
  assert_true(wave.commands[1] is CurveTo(_, _, _, _, _, _))
  assert_true(wave.commands[3] is CurveTo(_, _, _, _, _, _))
  let dbl = build_geometry(ShapeDoubleWave, 200, 100)
  assert_true(supports(ShapeDoubleWave))
  // MoveTo + 2 CurveTo + LineTo + 2 CurveTo + Close = 7.
  assert_eq(dbl.command_count(), 7)
  assert_true(dbl.is_closed())
}

///|
/// §20.1.10.56 `ribbon` / `ribbon2` — banner ribbons with folded
/// tails; the notch folds are small `ArcTo` rounds and the spec's
/// `fill="none"` fold shadow lines are emitted as extra sub-paths.
test "build_geometry ribbon / ribbon2 emit notch arcs and fold lines" {
  let down = build_geometry(ShapeRibbon, 200, 100)
  assert_eq(down.width, 200)
  assert_true(supports(ShapeRibbon))
  // Body closes, then four open fold-shadow sub-paths follow.
  assert_true(down.commands[0] is MoveTo(0, 0))
  let mut arcs = 0
  let mut moves = 0
  for cmd in down.commands {
    if cmd is ArcTo(_, _, _, _, _, _, _) {
      arcs = arcs + 1
    }
    if cmd is MoveTo(_, _) {
      moves = moves + 1
    }
  }
  // Six notch arcs; one body MoveTo plus four fold-line MoveTos.
  assert_eq(arcs, 6)
  assert_eq(moves, 5)
  let up = build_geometry(ShapeRibbon2, 200, 100)
  assert_true(supports(ShapeRibbon2))
  assert_true(up.commands[0] is MoveTo(0, 100))
}

///|
/// §20.1.10.56 `verticalScroll` / `horizontalScroll` — parchment
/// scrolls whose curled corner is drawn with `ArcTo` rolls; the body
/// closes and a second closed sub-path draws the curl disc.
test "build_geometry scrolls emit a body plus a curl disc sub-path" {
  let vs = build_geometry(ShapeVerticalScroll, 200, 200)
  assert_true(supports(ShapeVerticalScroll))
  // Two closed sub-paths ⇒ two MoveTo and two ClosePath commands.
  let mut moves = 0
  let mut closes = 0
  let mut arcs = 0
  for cmd in vs.commands {
    if cmd is MoveTo(_, _) {
      moves = moves + 1
    }
    if cmd is ClosePath {
      closes = closes + 1
    }
    if cmd is ArcTo(_, _, _, _, _, _, _) {
      arcs = arcs + 1
    }
  }
  assert_eq(moves, 2)
  assert_eq(closes, 2)
  assert_true(arcs > 0)
  let hs = build_geometry(ShapeHorizontalScroll, 200, 200)
  assert_true(supports(ShapeHorizontalScroll))
  assert_true(hs.is_closed())
}

///|
/// §20.1.10.56 `ellipseRibbon` / `ellipseRibbon2` / `leftRightRibbon`
/// — ellipse-bowed and two-way banner ribbons. The bowed edges use
/// quadratic `QuadTo` segments and the geometry stays non-trivial.
test "build_geometry ellipse + left-right ribbons emit curved bands" {
  let er = build_geometry(ShapeEllipseRibbon, 200, 100)
  assert_true(supports(ShapeEllipseRibbon))
  let mut quads = 0
  for cmd in er.commands {
    if cmd is QuadTo(_, _, _, _) {
      quads = quads + 1
    }
  }
  assert_true(quads > 0)
  let er2 = build_geometry(ShapeEllipseRibbon2, 200, 100)
  assert_true(supports(ShapeEllipseRibbon2))
  assert_true(er2.commands[0] is MoveTo(0, 100))
  let lr = build_geometry(ShapeLeftRightRibbon, 200, 100)
  assert_true(supports(ShapeLeftRightRibbon))
  assert_true(lr.command_count() > 5)
}

///|
/// §20.1.10.56 connectors — `line`, `straightConnector1` and the bent
/// connectors are open polylines: a leading `MoveTo`, only straight
/// `LineTo` segments, and no closing `ClosePath`.
test "build_geometry connectors emit open polylines" {
  let line = build_geometry(ShapeLine, 200, 100)
  assert_true(supports(ShapeLine))
  assert_eq(line.command_count(), 2)
  assert_false(line.is_closed())
  assert_true(line.commands[0] is MoveTo(0, 0))
  assert_true(line.commands[1] is LineTo(200, 100))
  // lineInv runs bottom-left to top-right.
  let inv = build_geometry(ShapeLineInv, 200, 100)
  assert_true(inv.commands[0] is MoveTo(0, 100))
  assert_true(inv.commands[1] is LineTo(200, 0))
  // bentConnector3 is a 3-segment elbow with the leg at the midpoint.
  let bent = build_geometry(ShapeBentConnector3, 200, 100)
  assert_true(supports(ShapeBentConnector3))
  assert_eq(bent.command_count(), 4)
  assert_false(bent.is_closed())
  assert_true(bent.commands[1] is LineTo(100, 0))
  assert_true(bent.commands[2] is LineTo(100, 100))
}

///|
/// §20.1.10.56 `curvedConnector3` — an S-curve connector built from
/// two cubic Bézier segments, open (no `ClosePath`).
test "build_geometry curvedConnector3 emits two cubic curves" {
  let g = build_geometry(ShapeCurvedConnector3, 200, 100)
  assert_true(supports(ShapeCurvedConnector3))
  assert_eq(g.command_count(), 3)
  assert_false(g.is_closed())
  assert_true(g.commands[0] is MoveTo(0, 0))
  assert_true(g.commands[1] is CurveTo(_, _, _, _, _, _))
  assert_true(g.commands[2] is CurveTo(_, _, _, _, 200, 100))
}

///|
/// §20.1.10.56 tabs / `nonIsoscelesTrapezoid` / `mathNotEqual` — the
/// tab presets emit four closed corner sub-paths; the trapezoid is a
/// single closed quad; the not-equal sign is a closed 20-vertex
/// polygon.
test "build_geometry tabs, trapezoid and notEqual emit closed paths" {
  // cornerTabs: 4 triangles → 4 × (MoveTo + 2 LineTo + ClosePath).
  let corner = build_geometry(ShapeCornerTabs, 200, 100)
  assert_true(supports(ShapeCornerTabs))
  assert_eq(corner.command_count(), 16)
  assert_true(corner.is_closed())
  // squareTabs: 4 squares → 4 × (MoveTo + 3 LineTo + ClosePath).
  let square = build_geometry(ShapeSquareTabs, 200, 100)
  assert_eq(square.command_count(), 20)
  // plaqueTabs: 4 concave tabs, each with one QuadTo arc.
  let plaque = build_geometry(ShapePlaqueTabs, 200, 100)
  assert_true(supports(ShapePlaqueTabs))
  let mut quads = 0
  for cmd in plaque.commands {
    if cmd is QuadTo(_, _, _, _) {
      quads = quads + 1
    }
  }
  assert_eq(quads, 4)
  // nonIsoscelesTrapezoid: closed quad with a full-width base.
  let trap = build_geometry(ShapeNonIsoscelesTrapezoid, 200, 100)
  assert_true(supports(ShapeNonIsoscelesTrapezoid))
  assert_eq(trap.command_count(), 5)
  assert_true(trap.is_closed())
  assert_true(trap.commands[0] is MoveTo(0, 100))
  // mathNotEqual: closed 20-vertex polygon.
  let neq = build_geometry(ShapeMathNotEqual, 200, 100)
  assert_true(supports(ShapeMathNotEqual))
  assert_eq(neq.command_count(), 21)
  assert_true(neq.is_closed())
}
