// Whitebox tests for the §20.1.9 data-driven guide engine.

///|
/// The engine resolves built-ins (`w`, `h`), evaluates guide formulas
/// in order, and materialises literal/guide-referencing path commands.
test "§20.1.9 guide engine evaluates a data-driven preset" {
  let def : PresetGuideDef = {
    adjusts: [("adj1", 25000.0)],
    guides: [
      ("hw", "*/ w 1 2"), // 50
      ("hh", "*/ h 1 2"), // 50
      ("q", "*/ w adj1 100000"), // w·25000/100000 = 25
    ],
    path: [
      PMoveTo("0", "0"),
      PLnTo("w", "0"),
      PLnTo("hw", "hh"),
      PLnTo("q", "h"),
      PClose,
    ],
  }
  let geo = build_from_definition(def, 100, 100, [])
  assert_true(geo.commands[0] is MoveTo(0, 0))
  assert_true(geo.commands[1] is LineTo(100, 0))
  assert_true(geo.commands[2] is LineTo(50, 50))
  assert_true(geo.commands[3] is LineTo(25, 100))
  assert_true(geo.commands[4] is ClosePath)
  // A user avLst adjustment overrides the default.
  let geo2 = build_from_definition(def, 100, 100, [
    { name: "adj1", raw_formula: "val 40000", value: Some(40000) },
  ])
  assert_true(geo2.commands[3] is LineTo(40, 100)) // q = w·40000/100000 = 40
}

///|
/// The relative `arcTo` materialisation matches the verified `rel_arc`:
/// a quarter arc of radii 50×50 from the left-mid point sweeping +90°.
test "§20.1.9 guide engine materialises relative arcTo" {
  let def : PresetGuideDef = {
    adjusts: [],
    guides: [("rad", "*/ w 1 2")],
    path: [
      PMoveTo("0", "vc"), // (0, 50)
      PArcTo("rad", "rad", "cd2", "cd4"), // 180°, +90°
    ],
  }
  let geo = build_from_definition(def, 100, 100, [])
  assert_true(geo.commands[0] is MoveTo(0, 50))
  // rel_arc(0,50,50,50,180°,90°) ends at (50, 0); sweep true, large false.
  assert_true(geo.commands[1] is ArcTo(50, 50, 0, false, true, 50, 0))
}

///|
/// A full-revolution `arcTo` (|swAng| ≥ 360°) has coincident endpoints
/// that SVG's `A` cannot draw, so the engine splits it into two
/// half-sweep arcs (matching the `build_ellipse` two-semicircle idiom).
test "§20.1.9 guide engine splits a full-circle arcTo into two arcs" {
  let def : PresetGuideDef = {
    adjusts: [],
    guides: [("rad", "*/ w 1 2")],
    path: [PMoveTo("0", "vc"), PArcTo("rad", "rad", "cd2", "-21600000"), PClose],
  }
  let geo = build_from_definition(def, 100, 100, [])
  assert_eq(geo.commands.length(), 4) // MoveTo + 2 arcs + Close
  assert_true(geo.commands[0] is MoveTo(0, 50))
  assert_true(geo.commands[1] is ArcTo(50, 50, 0, _, _, _, _))
  assert_true(geo.commands[2] is ArcTo(50, 50, 0, _, _, 0, 50)) // back to start
  assert_true(geo.commands[3] is ClosePath)
}

///|
/// §20.1.10.56 circularArrow — the data-driven 192-guide definition.
/// On a 200×200 box the early chain resolves to th=25, thh=25, th2=12.5
/// ⇒ outer band radii rw1=rh1=87.5 (round 88) and inner rw2=rh2=62.5
/// (round 63). The path is moveTo → outer arc(rw1,rh1) → 3 arrowhead
/// lines → inner arc(rw2,rh2) → close (8 commands). The arc radii
/// verify the early guide chain; the arrowhead/intersection points come
/// from the verified engine evaluating the verbatim spec formulas.
test "§20.1.10.56 circularArrow evaluates the verbatim spec definition" {
  let geo = build_geometry(ShapeCircularArrow, 200, 200)
  assert_eq(geo.commands.length(), 8)
  assert_true(geo.commands[0] is MoveTo(_, _))
  assert_true(geo.commands[1] is ArcTo(88, 88, 0, _, _, _, _)) // outer rim rw1/rh1
  assert_true(geo.commands[2] is LineTo(_, _))
  assert_true(geo.commands[6] is ArcTo(63, 63, 0, _, _, _, _)) // inner rim rw2/rh2
  assert_true(geo.commands[7] is ClosePath)
  assert_true(supports(ShapeCircularArrow))
  // A custom band thickness (adj1) changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeCircularArrow, 200, 200, [
      { name: "adj1", raw_formula: "val 20000", value: Some(20000) },
    ]) !=
    build_geometry(ShapeCircularArrow, 200, 200),
  )
}

///|
/// §20.1.10.56 leftCircularArrow — the data-driven 205-guide mirror.
/// Same early chain (rw1=rh1=87.5→88, rw2=rh2=62.5→63). Path is moveTo
/// → lnTo → inner arc(rw2,rh2) → 3 arrowhead lines → outer
/// arc(rw1,rh1) → close = 9 commands.
test "§20.1.10.56 leftCircularArrow evaluates the verbatim spec definition" {
  let geo = build_geometry(ShapeLeftCircularArrow, 200, 200)
  assert_eq(geo.commands.length(), 9)
  assert_true(geo.commands[0] is MoveTo(_, _))
  assert_true(geo.commands[2] is ArcTo(63, 63, 0, _, _, _, _)) // inner rim
  assert_true(geo.commands[7] is ArcTo(88, 88, 0, _, _, _, _)) // outer rim
  assert_true(geo.commands[8] is ClosePath)
  assert_true(supports(ShapeLeftCircularArrow))
}

///|
/// §20.1.10.56 leftRightCircularArrow — the data-driven 230-guide
/// double-headed mirror. Same early chain (rw1=88, rw2=63). Path is
/// moveTo → lnTo → lnTo → outer arc(rw1) → 3 lines → inner arc(rw2) →
/// lnTo → close = 11 commands.
test "§20.1.10.56 leftRightCircularArrow evaluates the spec definition" {
  let geo = build_geometry(ShapeLeftRightCircularArrow, 200, 200)
  assert_eq(geo.commands.length(), 11)
  assert_true(geo.commands[0] is MoveTo(_, _))
  assert_true(geo.commands[3] is ArcTo(88, 88, 0, _, _, _, _)) // outer rim
  assert_true(geo.commands[8] is ArcTo(63, 63, 0, _, _, _, _)) // inner rim
  assert_true(geo.commands[10] is ClosePath)
  assert_true(supports(ShapeLeftRightCircularArrow))
}

///|
/// §20.1.10.56 gear6 — the data-driven 107-guide six-tooth gear. The
/// path is moveTo + (3 lnTo + 1 root arc) × 6 + close = 26 commands;
/// the six root fillets all use the pitch-circle radii rw=rh (the box
/// minus the tooth height th = ss·adj1/100000). On a 200×200 box
/// (adj1=15000): th=30 ⇒ rw=rh=70, so each arc is ArcTo(70, 70, …).
test "§20.1.10.56 gear6 evaluates the verbatim spec definition" {
  let geo = build_geometry(ShapeGear6, 200, 200)
  assert_eq(geo.commands.length(), 26)
  assert_true(geo.commands[0] is MoveTo(_, _))
  assert_true(geo.commands[4] is ArcTo(70, 70, 0, _, _, _, _)) // root fillet rw/rh
  assert_true(geo.commands[24] is ArcTo(70, 70, 0, _, _, _, _))
  assert_true(geo.commands[25] is ClosePath)
  assert_true(supports(ShapeGear6))
  // A custom tooth height (adj1) changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeGear6, 200, 200, [
      { name: "adj1", raw_formula: "val 18000", value: Some(18000) },
    ]) !=
    build_geometry(ShapeGear6, 200, 200),
  )
}
