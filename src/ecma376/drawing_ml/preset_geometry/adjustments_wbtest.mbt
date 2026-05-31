///|
/// §20.1.9.18 — with no `avLst` override, the adjustment-aware path is
/// byte-identical to the spec-default `build_geometry` for every
/// preset (the zero-regression guarantee the wiring relies on).
test "§20.1.9.18 build_geometry_with_adjustments defaults match build_geometry" {
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeRoundRect, 100, 100, []),
    build_geometry(ShapeRoundRect, 100, 100),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapePlaque, 80, 120, []),
    build_geometry(ShapePlaque, 80, 120),
  )
  // The whole rounded / snipped rectangle family is default-equivalent.
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeRound1Rect, 90, 60, []),
    build_geometry(ShapeRound1Rect, 90, 60),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeRound2SameRect, 90, 60, []),
    build_geometry(ShapeRound2SameRect, 90, 60),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeRound2DiagRect, 90, 60, []),
    build_geometry(ShapeRound2DiagRect, 90, 60),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeSnip1Rect, 90, 60, []),
    build_geometry(ShapeSnip1Rect, 90, 60),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeSnip2SameRect, 90, 60, []),
    build_geometry(ShapeSnip2SameRect, 90, 60),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeSnip2DiagRect, 90, 60, []),
    build_geometry(ShapeSnip2DiagRect, 90, 60),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeSnipRoundRect, 90, 60, []),
    build_geometry(ShapeSnipRoundRect, 90, 60),
  )
  // A preset with no adjustment-aware builder delegates unchanged.
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeEllipse, 64, 40, []),
    build_geometry(ShapeEllipse, 64, 40),
  )
}

///|
/// §20.1.10.56 parallelogram / trapezoid — the slant / inset is a
/// fraction of the SHORTER side `ss = min(w, h)`, not of the width
/// (spec gdLst `x2 = ss·a/100000`). On a wide 200×100 box `ss = 100`,
/// so the default `adj = 25000` slant is `100·0.25 = 25`, NOT the
/// `200·0.25 = 50` the old width-based code produced. The first
/// command `MoveTo(slant, 0)` carries that value.
test "§20.1.10.56 parallelogram/trapezoid slant is ss-based, not width-based" {
  assert_true(build_parallelogram(200, 100).commands[0] is MoveTo(25, 0))
  assert_true(build_trapezoid(200, 100).commands[0] is MoveTo(25, 0))
  // A square box is unchanged (ss == width).
  assert_true(build_parallelogram(100, 100).commands[0] is MoveTo(25, 0))
  // A custom adj flows through and stays ss-based.
  assert_true(
    build_geometry_with_adjustments(ShapeParallelogram, 100, 100, [
      { name: "adj", raw_formula: "val 40000", value: Some(40000) },
    ]).commands[0]
    is MoveTo(40, 0),
  )
  // Default-equivalence holds for both shapes.
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeParallelogram, 200, 100, []),
    build_geometry(ShapeParallelogram, 200, 100),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeTrapezoid, 200, 100, []),
    build_geometry(ShapeTrapezoid, 200, 100),
  )
}

///|
/// §20.1.10.56 block arrows — the arrowhead length is `ss·a2/100000`
/// (shorter side), not width/height-based. On a wide 200×100
/// rightArrow `ss = 100`, so the head is 50 long and its base sits at
/// x = 150 — not the x = 100 the old width-based code produced. The
/// shaft top stays at 25 (shaft thickness 50, centred).
test "§20.1.10.56 block arrow head length is ss-based, honours adj guides" {
  assert_true(build_right_arrow(200, 100).commands[1] is LineTo(150, 25))
  // A square arrow is unchanged (ss == width).
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeRightArrow, 100, 100, []),
    build_geometry(ShapeRightArrow, 100, 100),
  )
  // adj2 shortens the head: 25000 → head 25 → base x 75.
  assert_true(
    build_geometry_with_adjustments(ShapeRightArrow, 100, 100, [
      { name: "adj2", raw_formula: "val 25000", value: Some(25000) },
    ]).commands[1]
    is LineTo(75, 25),
  )
  // upArrow head length is also ss-based: on a tall 100×200 box ss=100
  // so the head base sits at y=50, not the old height-based y=100.
  assert_true(build_up_arrow(100, 200).commands[1] is LineTo(25, 50))
}

///|
/// §20.1.10.56 notched/striped right arrows — head length is
/// `ss·a2/100000`; defaults unchanged, custom adj2 resizes the head.
test "§20.1.10.56 notched/striped right arrows honour adj guides" {
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeNotchedRightArrow, 100, 100, []),
    build_geometry(ShapeNotchedRightArrow, 100, 100),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeStripedRightArrow, 100, 100, []),
    build_geometry(ShapeStripedRightArrow, 100, 100),
  )
  // A wide notchedRightArrow head is ss-based: on 200×100 ss=100 →
  // head 50 → head base x = 150 (commands[1] LineTo(150, shaft_top)).
  assert_true(
    build_notched_right_arrow(200, 100).commands[1] is LineTo(150, 25),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeNotchedRightArrow, 100, 100, [
      { name: "adj2", raw_formula: "val 25000", value: Some(25000) },
    ]) !=
    build_geometry(ShapeNotchedRightArrow, 100, 100),
  )
}

///|
/// §20.1.10.56 rightArrowCallout — box + arrow, all radii ss-based.
/// On a 100×100 box: a1=a2=a3=25000, a4=64977 ⇒ box right edge x2=64,
/// head base x3=75, shaft band y∈[38,62], head band y∈[25,75]. The
/// spec path runs (l,t)→(x2,t)→(x2,y2)→(x3,y2)→(x3,y1)→(r,vc)→…
test "§20.1.10.56 rightArrowCallout uses ss-based spec geometry" {
  let geo = build_right_arrow_callout(100, 100)
  assert_true(geo.commands[1] is LineTo(64, 0)) // (x2, t)
  assert_true(geo.commands[4] is LineTo(75, 25)) // (x3, y1)
  assert_true(geo.commands[5] is LineTo(100, 50)) // (r, vc) arrow tip
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeRightArrowCallout, 100, 100, []),
    build_geometry(ShapeRightArrowCallout, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeRightArrowCallout, 100, 100, [
      { name: "adj4", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeRightArrowCallout, 100, 100),
  )
  // leftArrowCallout is the mirror: arrow tip at (0, vc) = (0, 50).
  assert_true(build_left_arrow_callout(100, 100).commands[5] is LineTo(0, 50))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeLeftArrowCallout, 100, 100, []),
    build_geometry(ShapeLeftArrowCallout, 100, 100),
  )
  // Vertical callouts: up tip at (hc, 0) = (50, 0); down tip at (50, 100).
  assert_true(build_up_arrow_callout(100, 100).commands[5] is LineTo(50, 0))
  assert_true(build_down_arrow_callout(100, 100).commands[6] is LineTo(50, 100))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeUpArrowCallout, 100, 100, []),
    build_geometry(ShapeUpArrowCallout, 100, 100),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeDownArrowCallout, 100, 100, []),
    build_geometry(ShapeDownArrowCallout, 100, 100),
  )
  // Bidirectional callouts default-equivalence (completes the family).
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeLeftRightArrowCallout, 100, 100, []),
    build_geometry(ShapeLeftRightArrowCallout, 100, 100),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeUpDownArrowCallout, 100, 100, []),
    build_geometry(ShapeUpDownArrowCallout, 100, 100),
  )
  // leftRight: left arrow tip at (0, vc) = (0, 50); right at (100, 50).
  assert_true(
    build_left_right_arrow_callout(100, 100).commands[14] is LineTo(0, 50),
  )
  // upDown: up arrow tip at (hc, 0) = (50, 0).
  assert_true(
    build_up_down_arrow_callout(100, 100).commands[0] is MoveTo(50, 0),
  )
}

///|
/// §20.1.10.56 leftBrace — faithful spec arc transcription via the
/// verified `rel_arc` helper. On a 100×100 box (a1=8333→y1=8,
/// a2=50000→y3=50): the bottom arm tip is MoveTo(100,100), the middle
/// pinch arc ends at the left tip (0, 50), and the top arc ends at the
/// top arm tip (100, 0).
test "§20.1.10.56 leftBrace transcribes the spec arcs (rel_arc)" {
  let geo = build_left_brace(100, 100)
  assert_true(geo.commands[0] is MoveTo(100, 100))
  assert_true(geo.commands[3] is ArcTo(50, 8, 0, false, false, 0, 50))
  assert_true(geo.commands[6] is ArcTo(50, 8, 0, false, true, 100, 0))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeLeftBrace, 100, 100, []),
    build_geometry(ShapeLeftBrace, 100, 100),
  )
  // A custom adj1 (curl radius) changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeLeftBrace, 100, 100, [
      { name: "adj1", raw_formula: "val 20000", value: Some(20000) },
    ]) !=
    build_geometry(ShapeLeftBrace, 100, 100),
  )
}

///|
/// §20.1.10.56 bracePair — faithful spec transcription of the open
/// two-subpath `{ }` stroke outline via `rel_arc`. On a 100×100 box
/// (a=8333 ⇒ x1=8, x2=16, x3=84, x4=92, y2=42, y3=58, y4=92): the left
/// brace starts at its bottom arm MoveTo(16,100) with its pinch tip
/// arc ending at (0,50); the right brace subpath starts at MoveTo(84,0)
/// (command[7]) with its pinch tip arc ending at (100,50).
test "§20.1.10.56 bracePair transcribes the open two-subpath outline" {
  let geo = build_brace_pair(100, 100)
  assert_true(geo.commands[0] is MoveTo(16, 100))
  assert_true(geo.commands[3] is ArcTo(8, 8, 0, false, false, 0, 50)) // left pinch
  assert_true(geo.commands[7] is MoveTo(84, 0)) // right brace subpath
  assert_true(geo.commands[10] is ArcTo(8, 8, 0, false, false, 100, 50)) // right pinch
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeBracePair, 100, 100, []),
    build_geometry(ShapeBracePair, 100, 100),
  )
  // A custom curl radius (adj) changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeBracePair, 100, 100, [
      { name: "adj", raw_formula: "val 20000", value: Some(20000) },
    ]) !=
    build_geometry(ShapeBracePair, 100, 100),
  )
}

///|
/// §20.1.10.56 rightBrace — the `}` mirror of leftBrace, faithful spec
/// arc transcription via `rel_arc`. On a 100×100 box (a1=8333→y1=8,
/// a2=50000→y3=50, y2=42, y4=92): the top arm tip is MoveTo(0,0), the
/// middle pinch arc ends at the right tip (100, 50), and the bottom arc
/// ends at the bottom arm tip (0, 100).
test "§20.1.10.56 rightBrace transcribes the spec arcs (rel_arc)" {
  let geo = build_right_brace(100, 100)
  assert_true(geo.commands[0] is MoveTo(0, 0))
  assert_true(geo.commands[3] is ArcTo(50, 8, 0, false, false, 100, 50))
  assert_true(geo.commands[6] is ArcTo(50, 8, 0, false, true, 0, 100))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeRightBrace, 100, 100, []),
    build_geometry(ShapeRightBrace, 100, 100),
  )
  // A custom adj1 (curl radius) changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeRightBrace, 100, 100, [
      { name: "adj1", raw_formula: "val 20000", value: Some(20000) },
    ]) !=
    build_geometry(ShapeRightBrace, 100, 100),
  )
}

///|
/// §20.1.9 rel_arc — the DrawingML relative-arc → SVG `ArcTo`
/// conversion, verified against KNOWN arc maths (independent of any
/// preset, so it is a non-circular reference the brace/curved-arrow
/// transcriptions can build on).
test "§20.1.9 rel_arc converts relative arcs against known arc maths" {
  // 90° arc from (100,100) starting at 90°, radii 50×50: centre (100,50),
  // end at 180° is (50,50).
  let (cmd1, ex1, ey1) = rel_arc(100, 100, 50, 50, 5400000, 5400000)
  @debug.assert_eq((ex1, ey1), (50, 50))
  assert_true(cmd1 is ArcTo(50, 50, 0, false, true, 50, 50))
  // 90° arc from (0,0) starting at 0°: centre (-50,0), end at 90° = (-50,50).
  let (_, ex2, ey2) = rel_arc(0, 0, 50, 50, 0, 5400000)
  @debug.assert_eq((ex2, ey2), (-50, 50))
  // −90° sweep clears `sweep` and `largeArc`.
  assert_true(
    rel_arc(100, 0, 50, 50, 0, -5400000).0 is ArcTo(_, _, _, false, false, _, _),
  )
  // 270° sweep sets `largeArc` and `sweep`.
  assert_true(
    rel_arc(100, 0, 50, 50, 0, 16200000).0 is ArcTo(_, _, _, true, true, _, _),
  )
}

///|
/// §20.1.10.56 curvedRightArrow — faithful spec guide-chain + path
/// transcription. On a 100×100 box the integer guides resolve to
/// hd2=50, q1=18 ⇒ hR=32; th=25, aw=50; ah=25 ⇒ x1=75; dy=30 ⇒ y4=50,
/// y7=87; aw2=25 ⇒ y6=75 (tip on the right edge). The lnTo points are
/// integer-exact (the float-derived arc endpoints are only checked to
/// be ArcTo); this verifies the guide arithmetic is transcribed 1:1.
test "§20.1.10.56 curvedRightArrow transcribes the spec guide chain" {
  let geo = build_curved_right_arrow(100, 100)
  assert_true(geo.commands[0] is MoveTo(0, 32))
  assert_true(geo.commands[1] is ArcTo(_, _, _, _, _, _, _))
  assert_true(geo.commands[2] is LineTo(75, 50))
  assert_true(geo.commands[3] is LineTo(100, 75)) // tip on right edge (r, y6)
  assert_true(geo.commands[5] is LineTo(75, 87))
  assert_true(geo.commands[6] is ArcTo(_, _, _, _, _, _, _))
  assert_true(geo.commands[7] is ClosePath)
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeCurvedRightArrow, 100, 100, []),
    build_geometry(ShapeCurvedRightArrow, 100, 100),
  )
  // A custom shaft thickness (adj1) changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeCurvedRightArrow, 100, 100, [
      { name: "adj1", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeCurvedRightArrow, 100, 100),
  )
}

///|
/// §20.1.10.56 curvedLeftArrow — faithful spec guide-chain + path
/// transcription (horizontal mirror of curvedRightArrow). On a 100×100
/// box: y6=75 (tip side), x1=ah=25, y4=50, y5=62, y8=99. The lnTo
/// points are integer-exact; the two body arcs are checked to be
/// ArcTo.
test "§20.1.10.56 curvedLeftArrow transcribes the spec guide chain" {
  let geo = build_curved_left_arrow(100, 100)
  assert_true(geo.commands[0] is MoveTo(0, 75))
  assert_true(geo.commands[1] is LineTo(25, 50))
  assert_true(geo.commands[2] is LineTo(25, 62))
  assert_true(geo.commands[3] is ArcTo(_, _, _, _, _, _, _))
  assert_true(geo.commands[4] is ArcTo(_, _, _, _, _, _, _))
  assert_true(geo.commands[5] is LineTo(25, 99))
  assert_true(geo.commands[6] is ClosePath)
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeCurvedLeftArrow, 100, 100, []),
    build_geometry(ShapeCurvedLeftArrow, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeCurvedLeftArrow, 100, 100, [
      { name: "adj1", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeCurvedLeftArrow, 100, 100),
  )
}

///|
/// §20.1.10.56 curvedUpArrow — faithful spec guide-chain + path
/// transcription (vertical analogue; w↔h swapped). On a 100×100 box:
/// x6=75 (tip on top edge), y1=ah=25, x8=99, x7=87, x4=50. The lnTo
/// points are integer-exact; the two body arcs are checked to be
/// ArcTo.
test "§20.1.10.56 curvedUpArrow transcribes the spec guide chain" {
  let geo = build_curved_up_arrow(100, 100)
  assert_true(geo.commands[0] is MoveTo(75, 0))
  assert_true(geo.commands[1] is LineTo(99, 25))
  assert_true(geo.commands[2] is LineTo(87, 25))
  assert_true(geo.commands[3] is ArcTo(_, _, _, _, _, _, _))
  assert_true(geo.commands[4] is ArcTo(_, _, _, _, _, _, _))
  assert_true(geo.commands[5] is LineTo(50, 25))
  assert_true(geo.commands[6] is ClosePath)
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeCurvedUpArrow, 100, 100, []),
    build_geometry(ShapeCurvedUpArrow, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeCurvedUpArrow, 100, 100, [
      { name: "adj1", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeCurvedUpArrow, 100, 100),
  )
}

///|
/// §20.1.10.56 curvedDownArrow — faithful spec guide-chain + path
/// transcription (vertical mirror of curvedUpArrow). On a 100×100 box:
/// x6=75, y1=b−ah=75, x4=50, x5=62, x3=57 (top), x8=99. The lnTo
/// points are integer-exact; the two body arcs are checked to be
/// ArcTo.
test "§20.1.10.56 curvedDownArrow transcribes the spec guide chain" {
  let geo = build_curved_down_arrow(100, 100)
  assert_true(geo.commands[0] is MoveTo(75, 100))
  assert_true(geo.commands[1] is LineTo(50, 75))
  assert_true(geo.commands[2] is LineTo(62, 75))
  assert_true(geo.commands[3] is ArcTo(_, _, _, _, _, _, _))
  assert_true(geo.commands[4] is LineTo(57, 0))
  assert_true(geo.commands[5] is ArcTo(_, _, _, _, _, _, _))
  assert_true(geo.commands[6] is LineTo(99, 75))
  assert_true(geo.commands[7] is ClosePath)
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeCurvedDownArrow, 100, 100, []),
    build_geometry(ShapeCurvedDownArrow, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeCurvedDownArrow, 100, 100, [
      { name: "adj1", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeCurvedDownArrow, 100, 100),
  )
}

///|
/// §20.1.10.56 moon — faithful spec transcription. On a 100×100 box
/// (a=50000): the guide chain resolves to g18w=125, dy1=62 (the inner
/// arc radii) and dx2p=75. The outer half-ellipse arc (radii w×hd2)
/// runs (r,b)→(r,t); the inner concave arc uses radii (g18w,dy1) and
/// the at2-derived sweep. The outer arc and inner radii verify the bulk
/// of the chain (g0..g18w); the angles come from the verified `at2`.
test "§20.1.10.56 moon transcribes the spec crescent outline" {
  let geo = build_moon(100, 100)
  assert_eq(geo.commands.length(), 4)
  assert_true(geo.commands[0] is MoveTo(100, 100))
  assert_true(geo.commands[1] is ArcTo(100, 50, 0, false, true, 100, 0))
  // Inner concave arc: spec radii g18w=125, dy1=62.
  assert_true(geo.commands[2] is ArcTo(125, 62, 0, _, _, _, _))
  assert_true(geo.commands[3] is ClosePath)
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeMoon, 100, 100, []),
    build_geometry(ShapeMoon, 100, 100),
  )
  // A custom adj changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeMoon, 100, 100, [
      { name: "adj", raw_formula: "val 20000", value: Some(20000) },
    ]) !=
    build_geometry(ShapeMoon, 100, 100),
  )
}

///|
/// §20.1.10.56 sun — faithful integer transcription of the eight-ray
/// disc. On a 100×100 box (adj=25000 ⇒ g0=25000): the east ray is the
/// triangle (r,vc)=(100,50) → (x15,y18)=(79,57) → (x15,y14)=(79,42);
/// the central disc has radii wR=hR=25 starting at (x19,vc)=(25,50).
/// All coordinates are exact integer guide values.
test "§20.1.10.56 sun transcribes the eight-ray disc" {
  let geo = build_sun(100, 100)
  // 8 rays × 4 commands + disc (4 commands) = 36.
  assert_eq(geo.commands.length(), 36)
  // East ray.
  assert_true(geo.commands[0] is MoveTo(100, 50))
  assert_true(geo.commands[1] is LineTo(79, 57))
  assert_true(geo.commands[2] is LineTo(79, 42))
  // North ray tip at the top-mid.
  assert_true(geo.commands[8] is MoveTo(50, 0))
  // Central disc: left point (x19, vc) and radii (wR, hR) = (25, 25).
  assert_true(geo.commands[32] is MoveTo(25, 50))
  assert_true(geo.commands[33] is ArcTo(25, 25, 0, false, true, 75, 50))
  assert_true(geo.commands[35] is ClosePath)
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeSun, 100, 100, []),
    build_geometry(ShapeSun, 100, 100),
  )
  // A custom adj changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeSun, 100, 100, [
      { name: "adj", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeSun, 100, 100),
  )
}

///|
/// §20.1.9 at2 / sqrt guide primitives — verified against KNOWN angles
/// and squares (independent of any preset), so the curved-arrow guide
/// chains that depend on them are correct by construction.
test "§20.1.9 at2 and isqrt evaluate guide primitives exactly" {
  // at2(x, y) = atan2(y, x) in 60000ths of a degree (y-down ⇒ clockwise
  // positive), matching the stAng/swAng unit.
  @debug.assert_eq(at2(1, 0), 0) // +x → 0°
  @debug.assert_eq(at2(0, 1), 5400000) // +y → 90°
  @debug.assert_eq(at2(-1, 0), 10800000) // -x → 180°
  @debug.assert_eq(at2(1, 1), 2700000) // diagonal → 45°
  @debug.assert_eq(at2(0, -1), -5400000) // -y → -90°
  // isqrt = floor square root; negatives clamp to 0.
  @debug.assert_eq(isqrt(10000), 100)
  @debug.assert_eq(isqrt(9375), 96)
  @debug.assert_eq(isqrt(0), 0)
  @debug.assert_eq(isqrt(-5), 0)
}

///|
/// §20.1.10.56 cloud — faithful transcription of the spec's eleven-arc
/// bump outline (43200×43200 frame, literal arc radii/angles), scaled
/// into the box and emitted via `rel_arc`. On a 100×100 box the start
/// is MoveTo(3900·100/43200, 14370·100/43200) = (9, 33); the outline is
/// 1 MoveTo + 11 arcs + ClosePath = 13 commands.
test "§20.1.10.56 cloud transcribes the eleven-arc bump outline" {
  let geo = build_cloud(100, 100)
  assert_eq(geo.commands.length(), 13)
  assert_true(geo.commands[0] is MoveTo(9, 33))
  assert_true(geo.commands[1] is ArcTo(_, _, _, _, _, _, _))
  assert_true(geo.commands[11] is ArcTo(_, _, _, _, _, _, _))
  assert_true(geo.commands[12] is ClosePath)
}

///|
/// §20.1.10.56 mathDivide — faithful transcription of the ÷ sign. On a
/// 100×100 box: a1=23520 ⇒ dy1=11; a3=11760 ⇒ rad=11; adj2=5880 clamps
/// to maxAdj2=2930 ⇒ yg=2; dx1=36. So y3=39, y2 = y3−yg−rad = 26 (top
/// dot centre), bottom dot centre h−y2=74, bar (x1,y3)-(x3,y4) =
/// (14,39)-(86,61). push_circle starts each dot at its left point
/// (cx−r, cy). Two dots (4 cmds each) + bar (5) = 13 commands.
test "§20.1.10.56 mathDivide transcribes the divide sign" {
  let geo = build_divide(100, 100)
  assert_eq(geo.commands.length(), 13)
  // Top dot: push_circle from the left point (hc−rad, y2) = (39, 26).
  assert_true(geo.commands[0] is MoveTo(39, 26))
  assert_true(geo.commands[1] is ArcTo(11, 11, 0, false, true, 61, 26))
  // Bottom dot left point (39, 74).
  assert_true(geo.commands[4] is MoveTo(39, 74))
  // Bar top-left (x1, y3) = (14, 39).
  assert_true(geo.commands[8] is MoveTo(14, 39))
  assert_true(geo.commands[12] is ClosePath)
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeMathDivide, 100, 100, []),
    build_geometry(ShapeMathDivide, 100, 100),
  )
  // A custom adj3 (dot radius) changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeMathDivide, 100, 100, [
      { name: "adj3", raw_formula: "val 8000", value: Some(8000) },
    ]) !=
    build_geometry(ShapeMathDivide, 100, 100),
  )
}

///|
/// §20.1.10.56 actionButtonHelp — faithful transcription of the "?"
/// glyph. On a 100×100 box (ss=100 ⇒ dx2=37, g9=g11=13, g13=75): the
/// hook starts MoveTo(g33,g27)=(29,34), its first curl is
/// arc(g16,g16,180°,180°) ending at (71,34); the dot is the full circle
/// MoveTo(hc,g31)=(50,71) radius g42=8. Face (5) + hook (11) + dot (4)
/// = 20 commands.
test "§20.1.10.56 actionButtonHelp transcribes the question-mark arcs" {
  let geo = build_action_button_help(100, 100)
  assert_eq(geo.commands.length(), 20)
  assert_true(geo.commands[0] is MoveTo(0, 0)) // button face
  assert_true(geo.commands[5] is MoveTo(29, 34)) // hook start (g33, g27)
  assert_true(geo.commands[6] is ArcTo(21, 21, 0, false, true, 71, 34))
  assert_true(geo.commands[9] is LineTo(55, 69)) // (g37, g30)
  assert_true(geo.commands[16] is MoveTo(50, 71)) // dot start (hc, g31)
  assert_true(geo.commands[17] is ArcTo(8, 8, 0, false, true, 50, 87))
  assert_true(geo.commands[19] is ClosePath)
}

///|
/// §20.1.10.56 actionButtonReturn — faithful transcription of the
/// looping return arrow. On a 100×100 box (ss=100): the glyph starts
/// MoveTo(g12,g21)=(87,31); the first notch curl is arc(g27,g27,0°,90°)
/// ending at (50,68); the lower-left loop curl is arc(g17,g17,180°,−90°)
/// ending at (41,87). Face (5) + arrow (16) = 21 commands.
test "§20.1.10.56 actionButtonReturn transcribes the looping arrow" {
  let geo = build_action_button_return(100, 100)
  assert_eq(geo.commands.length(), 21)
  assert_true(geo.commands[5] is MoveTo(87, 31)) // (g12, g21)
  assert_true(geo.commands[10] is ArcTo(9, 9, 0, false, true, 50, 68))
  assert_true(geo.commands[16] is ArcTo(28, 28, 0, false, false, 41, 87))
  assert_true(geo.commands[20] is ClosePath)
}

///|
/// §20.1.10.56 cloudCallout — faithful transcription: the eleven-arc
/// cloud body (13 commands, MoveTo(9,33) on a 100×100 box) followed by
/// three full-circle tail bubbles whose radii are integer-exact (for
/// ss=100: g26=2, g25=5, g12=8). Body + 3×4 bubble commands = 25, with
/// 4 MoveTo commands (1 body + 3 bubbles).
test "§20.1.10.56 cloudCallout transcribes the cloud body + tail bubbles" {
  let geo = build_cloud_callout(100, 100)
  assert_eq(geo.commands.length(), 25)
  // Cloud body start (shared with build_cloud).
  assert_true(geo.commands[0] is MoveTo(9, 33))
  // First (smallest) tail bubble: radius g26 = ss·600/21600 = 2.
  assert_true(geo.commands[14] is ArcTo(2, 2, 0, false, true, _, _))
  // Last (largest) tail bubble: radius g12 = ss·1800/21600 = 8.
  assert_true(geo.commands[22] is ArcTo(8, 8, 0, false, true, _, _))
  // 4 MoveTo commands (cloud body + three bubbles).
  let mut moves = 0
  for cmd in geo.commands {
    if cmd is MoveTo(_, _) {
      moves = moves + 1
    }
  }
  assert_eq(moves, 4)
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeCloudCallout, 100, 100, []),
    build_geometry(ShapeCloudCallout, 100, 100),
  )
  // A custom adj1 (tail tip x) changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeCloudCallout, 100, 100, [
      { name: "adj1", raw_formula: "val -40000", value: Some(-40000) },
    ]) !=
    build_geometry(ShapeCloudCallout, 100, 100),
  )
}

///|
/// §20.1.9 cos / sin / mod guide primitives — `cos x y` = x·cos(y),
/// `sin x y` = x·sin(y) (y in 60000ths-deg), `mod x y z` =
/// √(x²+y²+z²). Verified against known values independent of any
/// preset.
test "§20.1.9 gcos / gsin / gmod evaluate guide primitives exactly" {
  @debug.assert_eq(gcos(100, 0), 100) // 100·cos 0° = 100
  @debug.assert_eq(gcos(100, 5400000), 0) // 100·cos 90° = 0
  @debug.assert_eq(gsin(100, 5400000), 100) // 100·sin 90° = 100
  @debug.assert_eq(gsin(100, 0), 0) // 100·sin 0° = 0
  @debug.assert_eq(gmod(3, 4, 0), 5) // √(9+16) = 5
  @debug.assert_eq(gmod(2, 3, 6), 7) // √(4+9+36) = 7
}

///|
/// §20.1.10.56 noSmoking — faithful spec transcription. On a 100×100
/// box (adj=18750 ⇒ dr=18, iwd2=ihd2=32): the outer ring is the full
/// ellipse (radii 50×50) walked as four quarter arcs; the diagonal bar
/// is two inner-ellipse (radii 32×32) slices whose endpoints are
/// (hc+dx1, vc+dy1)=(78,66) and (hc−dx1, vc−dy1)=(22,34).
test "§20.1.10.56 noSmoking transcribes the ring + bar slices" {
  let geo = build_no_smoking(100, 100)
  assert_true(geo.commands[0] is MoveTo(0, 50))
  assert_true(geo.commands[1] is ArcTo(50, 50, 0, false, true, 50, 0))
  assert_true(geo.commands[5] is ClosePath)
  // Bar slice 1 from (78, 66) on the inner ellipse (radii 32×32).
  assert_true(geo.commands[6] is MoveTo(78, 66))
  assert_true(geo.commands[7] is ArcTo(32, 32, 0, _, _, _, _))
  // Bar slice 2 from (22, 34).
  assert_true(geo.commands[9] is MoveTo(22, 34))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeNoSmoking, 100, 100, []),
    build_geometry(ShapeNoSmoking, 100, 100),
  )
  // A custom ring thickness (adj) changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeNoSmoking, 100, 100, [
      { name: "adj", raw_formula: "val 30000", value: Some(30000) },
    ]) !=
    build_geometry(ShapeNoSmoking, 100, 100),
  )
}

///|
/// §20.1.10.56 leftRightUpArrow — left+right+up triple arrow. On a
/// 100×100 box: left tip (0, y4)=(0,75), right tip (r, y4)=(100,75),
/// up tip (hc, 0)=(50,0). The up tip is command[6] LineTo(50, 0).
test "§20.1.10.56 leftRightUpArrow uses spec ss-based layout" {
  let geo = build_left_right_up_arrow(100, 100)
  assert_true(geo.commands[0] is MoveTo(0, 75))
  assert_true(geo.commands[6] is LineTo(50, 0))
  assert_true(geo.commands[12] is LineTo(100, 75))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeLeftRightUpArrow, 100, 100, []),
    build_geometry(ShapeLeftRightUpArrow, 100, 100),
  )
}

///|
/// §20.1.10.56 leftUpArrow — left+up double arrow. On a 100×100 box
/// the spec layout gives left tip (0, y4)=(0,75), up tip (x4,0)=(75,0),
/// head length x1=25. The path starts at MoveTo(0, 75); the up tip is
/// command[6] LineTo(75, 0).
test "§20.1.10.56 leftUpArrow uses spec ss-based layout" {
  let geo = build_left_up_arrow(100, 100)
  assert_true(geo.commands[0] is MoveTo(0, 75))
  assert_true(geo.commands[6] is LineTo(75, 0))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeLeftUpArrow, 100, 100, []),
    build_geometry(ShapeLeftUpArrow, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeLeftUpArrow, 100, 100, [
      { name: "adj3", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeLeftUpArrow, 100, 100),
  )
}

///|
/// §20.1.10.56 left/right brackets — corner radius `ss·a/100000`
/// (default ss·0.08333). Defaults unchanged; a custom adj resizes the
/// rounded corners (the ArcTo radius). On a 100×100 box default r=8.
test "§20.1.10.56 left/right brackets honour the corner-radius adj" {
  // Default: the first ArcTo radius is r=8.
  assert_true(
    build_left_bracket(100, 100).commands[1] is ArcTo(8, 8, _, _, _, _, _),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeLeftBracket, 100, 100, []),
    build_geometry(ShapeLeftBracket, 100, 100),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeRightBracket, 100, 100, []),
    build_geometry(ShapeRightBracket, 100, 100),
  )
  // adj=30000 → r=30.
  assert_true(
    build_geometry_with_adjustments(ShapeLeftBracket, 100, 100, [
      { name: "adj", raw_formula: "val 30000", value: Some(30000) },
    ]).commands[1]
    is ArcTo(30, 30, _, _, _, _, _),
  )
  // (noSmoking has its own dedicated test — see the ring + bar slices
  // transcription above.)
  // donut ring thickness from adj (default ss·0.25); zero-regression.
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeDonut, 100, 100, []),
    build_geometry(ShapeDonut, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeDonut, 100, 100, [
      { name: "adj", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeDonut, 100, 100),
  )
  // bracketPair default r=16 (ss·0.16667); zero-regression.
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeBracketPair, 100, 100, []),
    build_geometry(ShapeBracketPair, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeBracketPair, 100, 100, [
      { name: "adj", raw_formula: "val 30000", value: Some(30000) },
    ]) !=
    build_geometry(ShapeBracketPair, 100, 100),
  )
}

///|
/// §20.1.10.56 wave — now guide-driven, but reproduces the EXACT
/// known-correct default geometry (the prior 21600-frame constants):
/// MoveTo(0,12), CurveTo(33,-29,66,54,100,12), LineTo(100,87),
/// CurveTo(66,129,33,45,0,87). This verifies the compound-fraction
/// transcription against a non-circular reference, and a custom adj1
/// (amplitude) then changes the geometry.
test "§20.1.10.56 wave reproduces the spec default and honours adj1" {
  let geo = build_wave(100, 100)
  assert_true(geo.commands[0] is MoveTo(0, 12))
  assert_true(geo.commands[1] is CurveTo(33, -29, 66, 54, 100, 12))
  assert_true(geo.commands[2] is LineTo(100, 87))
  assert_true(geo.commands[3] is CurveTo(66, 129, 33, 45, 0, 87))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeWave, 100, 100, []),
    build_geometry(ShapeWave, 100, 100),
  )
  // adj1=20000 (max amplitude) deepens the wave → different geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeWave, 100, 100, [
      { name: "adj1", raw_formula: "val 20000", value: Some(20000) },
    ]) !=
    build_geometry(ShapeWave, 100, 100),
  )
  // doubleWave reproduces its exact known-correct default too.
  let dw = build_double_wave(100, 100)
  assert_true(dw.commands[0] is MoveTo(0, 6))
  assert_true(dw.commands[1] is CurveTo(16, -14, 33, 27, 50, 6))
  assert_true(dw.commands[2] is CurveTo(66, -14, 83, 27, 100, 6))
  assert_true(dw.commands[5] is CurveTo(33, 114, 16, 72, 0, 93))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeDoubleWave, 100, 100, []),
    build_geometry(ShapeDoubleWave, 100, 100),
  )
}

///|
/// §20.1.10.56 bentUpArrow — L-shaped arrow. On a 100×100 box the
/// spec layout gives tip x3=75, vertical shaft [x2,x4]=[63,87], left
/// barb x1=50, arrowhead base y1=25, horizontal shaft top y2=75. The
/// tip command is LineTo(75, 0).
test "§20.1.10.56 bentUpArrow uses spec ss-based layout" {
  let geo = build_bent_up_arrow(100, 100)
  assert_true(geo.commands[1] is LineTo(63, 75)) // (x2, y2)
  assert_true(geo.commands[4] is LineTo(75, 0)) // (x3, t) tip
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeBentUpArrow, 100, 100, []),
    build_geometry(ShapeBentUpArrow, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeBentUpArrow, 100, 100, [
      { name: "adj2", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeBentUpArrow, 100, 100),
  )
}

///|
/// §20.1.10.56 quadArrow — the arrowhead half-width is `dx2 =
/// ss·a2/100000` measured ABSOLUTELY from the centre, not added to the
/// shaft. On a 100×100 box `head_barb = 22`, so the left arrowhead's
/// top barb sits at y = vc − 22 = 28, not the old additive y = 17.
test "§20.1.10.56 quadArrow head barb is absolute (not shaft+barb)" {
  assert_true(build_quad_arrow(100, 100).commands[1] is LineTo(22, 28))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeQuadArrow, 100, 100, []),
    build_geometry(ShapeQuadArrow, 100, 100),
  )
  // A narrower head (adj2) moves the barb edge inward.
  assert_true(
    build_geometry_with_adjustments(ShapeQuadArrow, 100, 100, [
      { name: "adj2", raw_formula: "val 10000", value: Some(10000) },
    ]).commands[1]
    is LineTo(22, 40),
  )
}

///|
/// §20.1.10.56 star5 — per-star `hf`/`vf` scale factors push the
/// points to the box edges (hf=105146, vf=110557), and `adj` (default
/// 19098, the golden-ratio sharpness) sets the inner radius. The top
/// point of a 100×100 star5 sits at y = vc − hd2·vf/100000 = 50 − 55 =
/// −5 (the spec lets the points overshoot slightly).
test "§20.1.10.56 star5 uses spec hf/vf scaling + adj point sharpness" {
  assert_true(
    build_geometry(ShapeStar5, 100, 100).commands[0] is MoveTo(50, -5),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeStar5, 100, 100, []),
    build_geometry(ShapeStar5, 100, 100),
  )
  // A custom adj (sharper / blunter points) changes the geometry.
  assert_true(
    build_geometry_with_adjustments(ShapeStar5, 100, 100, [
      { name: "adj", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeStar5, 100, 100),
  )
  // star_params returns None for a non-star preset.
  assert_true(star_params(ShapeEllipse) is None)
}

///|
/// §20.1.10.56 teardrop — `adj` pulls the corner point: dx1 =
/// w·a/200000, dy1 = h·a/200000 (the √2/cos45 factors cancel).
/// Default a=100000 → the pulled point is the top-right corner (w, 0);
/// adj=0 collapses it to the centre, making a plain ellipse-ish drop.
test "§20.1.10.56 teardrop pull point honours adj" {
  // Default pulled point reaches the corner: the first QuadTo ends at
  // (x1, y1) = (100, 0) on a 100×100 box. commands[2] is that QuadTo.
  assert_true(build_teardrop(100, 100).commands[2] is QuadTo(_, _, 100, 0))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeTeardrop, 100, 100, []),
    build_geometry(ShapeTeardrop, 100, 100),
  )
  // adj=50000 → dx1 = 25, dy1 = 25 → pulled point (75, 25).
  assert_true(
    build_geometry_with_adjustments(ShapeTeardrop, 100, 100, [
      { name: "adj", raw_formula: "val 50000", value: Some(50000) },
    ]).commands[2]
    is QuadTo(_, _, 75, 25),
  )
}

///|
/// §20.1.10.56 blockArc — start/inner-start angles (adj1/adj2) and
/// ring thickness (adj3, ss-based, default ss/4). Defaults unchanged;
/// a custom ring thickness resizes the inner radius.
test "§20.1.10.56 blockArc honours angle + ring-thickness guides" {
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeBlockArc, 100, 100, []),
    build_geometry(ShapeBlockArc, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeBlockArc, 100, 100, [
      { name: "adj3", raw_formula: "val 40000", value: Some(40000) },
    ]) !=
    build_geometry(ShapeBlockArc, 100, 100),
  )
}

///|
/// §20.1.10.56 pie/arc/chord — `adj1`/`adj2` are the start/end angles
/// (60000ths of a degree). The default pie starts at 0° → `MoveTo` at
/// the 3-o'clock point (w, h/2); a custom end angle changes the sweep.
test "§20.1.10.56 pie/arc/chord honour start/end angle guides" {
  assert_true(build_pie(100, 100).commands[0] is MoveTo(100, 50))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapePie, 100, 100, []),
    build_geometry(ShapePie, 100, 100),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeArc, 100, 100, []),
    build_geometry(ShapeArc, 100, 100),
  )
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeChord, 100, 100, []),
    build_geometry(ShapeChord, 100, 100),
  )
  // A custom end angle (90°) changes the pie geometry.
  assert_true(
    build_geometry_with_adjustments(ShapePie, 100, 100, [
      { name: "adj2", raw_formula: "val 5400000", value: Some(5400000) },
    ]) !=
    build_geometry(ShapePie, 100, 100),
  )
}

///|
/// §20.1.10.56 cube depth (ss-based, default ss/4) and can cap radius
/// (ss-based `ss·a/200000`). On a square 100×100 box cube depth = 25;
/// the can cap radius on a wide 200×100 box is ss·0.125 = 12 (not the
/// old height-based h·0.125 = 12 — same when h=ss, but differs when
/// w<h). A custom adj resizes them.
test "§20.1.10.56 cube depth and can cap are ss-based, honour adj" {
  // cube front face starts at (0, depth); default depth 25.
  assert_true(build_cube(100, 100).commands[0] is MoveTo(0, 25))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeCube, 100, 100, []),
    build_geometry(ShapeCube, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeCube, 100, 100, [
      { name: "adj", raw_formula: "val 40000", value: Some(40000) },
    ]).commands[0]
    is MoveTo(0, 40),
  )
  // can cap is ss-based: on a tall 100×200 box ss=100 → ry = 12, so
  // the body starts at (0, 12), not the old height-based (0, 25).
  assert_true(build_can(100, 200).commands[0] is MoveTo(0, 12))
}

///|
/// §20.1.10.56 bevel / foldedCorner — single `adj` band/fold width
/// `ss·a/100000`. Defaults unchanged (bevel ss/8 = 12, fold ss·0.16667
/// = 16 on a 100×100 box); a custom adj resizes them.
test "§20.1.10.56 bevel/foldedCorner honour the adj guide" {
  // bevel inner rectangle starts at (b, b); default b = 12.
  assert_true(build_bevel(100, 100).commands[5] is MoveTo(12, 12))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeBevel, 100, 100, []),
    build_geometry(ShapeBevel, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeBevel, 100, 100, [
      { name: "adj", raw_formula: "val 30000", value: Some(30000) },
    ]).commands[5]
    is MoveTo(30, 30),
  )
  // foldedCorner default unchanged; custom adj resizes the fold.
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeFoldedCorner, 100, 100, []),
    build_geometry(ShapeFoldedCorner, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeFoldedCorner, 100, 100, []) !=
    build_geometry_with_adjustments(ShapeFoldedCorner, 100, 100, [
      { name: "adj", raw_formula: "val 40000", value: Some(40000) },
    ]),
  )
}

///|
/// §20.1.10.56 diagStripe — the diagonal offset is `w·a/100000`
/// (width) / `h·a/100000` (height); `adj` default 50000. On a 100×100
/// box the default upper diagonal passes through (0,50)→(50,0); a
/// custom adj moves it.
test "§20.1.10.56 diagStripe offset honours adj" {
  assert_true(build_diag_stripe(100, 100).commands[0] is MoveTo(0, 50))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeDiagStripe, 100, 100, []),
    build_geometry(ShapeDiagStripe, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeDiagStripe, 100, 100, [
      { name: "adj", raw_formula: "val 25000", value: Some(25000) },
    ]).commands[1]
    is LineTo(25, 0),
  )
}

///|
/// §20.1.10.56 corner — both L-gnomon bands are `ss`-based. On a wide
/// 200×100 box ss=100, so the vertical band is 50 wide (not the
/// width-based 100 the old code produced).
test "§20.1.10.56 corner bands are ss-based, honour adj guides" {
  assert_true(build_corner(200, 100).commands[1] is LineTo(50, 0))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeCorner, 100, 100, []),
    build_geometry(ShapeCorner, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeCorner, 100, 100, [
      { name: "adj2", raw_formula: "val 25000", value: Some(25000) },
    ]).commands[1]
    is LineTo(25, 0),
  )
}

///|
/// §20.1.10.56 frame — the band thickness is `ss·a1/100000` (default
/// `adj1 = 12500` → ss/8). A custom adj1 changes the inner rectangle:
/// on a 100×100 box adj1=25000 → band 25 → inner starts at (25, 25).
test "§20.1.10.56 frame band thickness honours adj1" {
  // Default unchanged: band ss/8 = 12 → inner MoveTo(12, 12) (6th cmd).
  assert_true(build_frame(100, 100).commands[5] is MoveTo(12, 12))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeFrame, 100, 100, []),
    build_geometry(ShapeFrame, 100, 100),
  )
  assert_true(
    build_geometry_with_adjustments(ShapeFrame, 100, 100, [
      { name: "adj1", raw_formula: "val 25000", value: Some(25000) },
    ]).commands[5]
    is MoveTo(25, 25),
  )
}

///|
/// §20.1.10.56 bidirectional arrows — each head length is `ss·a2/100000`.
/// On a wide 400×100 leftRightArrow `ss=100`, so each head is 50 long
/// (left base x=50), not the `w·0.25 = 100` the old code produced.
test "§20.1.10.56 leftRight/upDown arrow heads are ss-based" {
  assert_true(build_left_right_arrow(400, 100).commands[1] is LineTo(50, 0))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeLeftRightArrow, 400, 100, []),
    build_geometry(ShapeLeftRightArrow, 400, 100),
  )
  // upDownArrow on a tall 100×400 box: head 50 long → top base y=50.
  assert_true(build_up_down_arrow(100, 400).commands[1] is LineTo(100, 50))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeUpDownArrow, 100, 400, []),
    build_geometry(ShapeUpDownArrow, 100, 400),
  )
}

///|
/// §20.1.10.56 homePlate / chevron — the point depth is `ss·a/100000`
/// (default `adj = 50000` → half the shorter side). A custom adj moves
/// the point base: on a 100×100 box adj=25000 → depth 25 → base_x 75.
/// The default is unchanged (base_x 50), so existing renders are safe.
test "§20.1.10.56 homePlate/chevron honour the adj point-depth guide" {
  // Default unchanged.
  assert_true(build_home_plate(100, 100).commands[1] is LineTo(50, 0))
  @debug.assert_eq(
    build_geometry_with_adjustments(ShapeHomePlate, 100, 100, []),
    build_geometry(ShapeHomePlate, 100, 100),
  )
  // Custom adj moves the point base.
  assert_true(
    build_geometry_with_adjustments(ShapeHomePlate, 100, 100, [
      { name: "adj", raw_formula: "val 25000", value: Some(25000) },
    ]).commands[1]
    is LineTo(75, 0),
  )
  // chevron: x2 = w - x1; default x1 = 50 → x2 = 50.
  assert_true(build_chevron(100, 100).commands[1] is LineTo(50, 0))
  // chevron left notch apex sits at (x1, vc); custom adj=20000 → x1=20.
  let chev = build_geometry_with_adjustments(ShapeChevron, 100, 100, [
    { name: "adj", raw_formula: "val 20000", value: Some(20000) },
  ])
  assert_true(chev.commands[1] is LineTo(80, 0))
  assert_true(chev.commands[5] is LineTo(20, 50))
}

///|
/// §20.1.10.56 mathEqual — two 73.5%-wide centred bars. On a 100×100
/// box: dx1=36 → x1=14; a1=23520 → dy1=23; a2=11760 → dy2=5; so the
/// top bar starts at (x1, y1) = (14, 22), not the full-width (0, …)
/// the old swapped-guide code produced.
test "§20.1.10.56 mathEqual bars are 73.5% wide centred with correct guides" {
  assert_true(build_equal(100, 100).commands[0] is MoveTo(14, 22))
  @debug.assert_eq(
    build_geometry(ShapeMathEqual, 100, 100),
    build_equal(100, 100),
  )
  // Two closed bars → 10 commands (2 × MoveTo+3 LineTo+ClosePath).
  @debug.assert_eq(build_equal(100, 100).commands.length(), 10)
  // A thicker adj1 grows the bar height (50000 → dy1 50, but pinned to
  // 36745 max → dy1 = 36; y1 = y2 - 36).
  let geo = build_geometry_with_adjustments(ShapeMathEqual, 100, 100, [
    { name: "adj1", raw_formula: "val 50000", value: Some(50000) },
  ])
  // a1 pinned to 36745 → dy1 = 36; dy2 with mAdj2=100000-73490=26510,
  // a2=11760 → dy2 = 5; y2 = 45; y1 = 45 - 36 = 9.
  assert_true(geo.commands[0] is MoveTo(14, 9))
}

///|
/// §20.1.10.56 plus — arms reach the edges with thickness `w − 2·x1`
/// where `x1 = ss·a/100000` (default `adj = 25000` → `x1 = ss/4`).
/// The spec path starts at `(l, x1) = (0, 25)` on a 100×100 box, not
/// at the `MoveTo(37, 0)` the old too-thin centred cross produced.
/// `mathPlus` / `mathMultiply` keep their established (separate)
/// rendering.
test "§20.1.10.56 plus arms span w-2·x1; mathPlus/mathMultiply unchanged" {
  assert_true(build_plus(100, 100).commands[0] is MoveTo(0, 25))
  // The vertical arm now spans x ∈ [25, 75] (thickness 50), not [37, 62].
  assert_true(build_plus(100, 100).commands[3] is LineTo(75, 0))
  // A custom adj reduces the inset → thicker arms (adj 10000 → x1 = 10).
  assert_true(
    build_geometry_with_adjustments(ShapePlus, 100, 100, [
      { name: "adj", raw_formula: "val 10000", value: Some(10000) },
    ]).commands[0]
    is MoveTo(0, 10),
  )
  // mathPlus is the spec CENTRED cross: on a 100×100 box dx1=36,
  // dx2=11 (a1=23520) → first point (x1,y2) = (14, 39), distinct from
  // the box-filling `plus`.
  assert_true(
    build_geometry(ShapeMathPlus, 100, 100).commands[0] is MoveTo(14, 39),
  )
  @debug.assert_eq(
    build_geometry(ShapeMathPlus, 100, 100),
    build_math_plus(100, 100),
  )
  // mathPlus does NOT reach the edges, unlike the box-filling plus.
  assert_true(
    build_geometry(ShapeMathPlus, 100, 100) !=
    build_geometry(ShapePlus, 100, 100),
  )
  // mathMultiply: for a SQUARE box ang = at2(w,h) = 45° (cos=sin=7071),
  // so the rotation is unchanged — first command MoveTo(32, 18).
  assert_true(
    build_geometry(ShapeMathMultiply, 100, 100).commands[0] is MoveTo(32, 18),
  )
  // For a NON-square box the cross slants along the box diagonal, so
  // the geometry differs from a naive 45° rotation.
  assert_true(
    build_geometry(ShapeMathMultiply, 200, 100).commands[0] is MoveTo(39, 9),
  )
}

///|
/// §20.1.10.56 mathMinus — the bar is `w·73490/100000` wide (≈73.5 %)
/// centred at `hc`, NOT full-width. On a 200×100 box `dx1 = 73`, `hc =
/// 100`, so the bar spans x ∈ [27, 173]: the first command is
/// `MoveTo(27, 38)`, not `MoveTo(0, …)`. A custom `adj1` changes the
/// bar height (50000 → 50 px tall → top_y 25).
test "§20.1.10.56 mathMinus bar is 73.5% width centred, not full width" {
  assert_true(build_minus(200, 100).commands[0] is MoveTo(27, 38))
  @debug.assert_eq(
    build_geometry(ShapeMathMinus, 200, 100),
    build_minus(200, 100),
  )
  let tall = build_geometry_with_adjustments(ShapeMathMinus, 200, 100, [
    { name: "adj1", raw_formula: "val 50000", value: Some(50000) },
  ])
  assert_true(tall.commands[0] is MoveTo(27, 25))
}

///|
/// §20.1.10.56 flowChartInputOutput — a FIXED parallelogram with slant
/// `w/5` (20 % of width), distinct from the adjustable `ss`-based
/// `parallelogram`. On a 200-wide box the slant is `40`.
test "§20.1.10.56 flowChartInputOutput uses the fixed w/5 slant" {
  assert_true(
    build_flowchart_input_output(200, 100).commands[0] is MoveTo(40, 0),
  )
  // Dispatched through build_geometry by the ST_ShapeType enum.
  @debug.assert_eq(
    build_geometry(ShapeFlowChartInputOutput, 200, 100),
    build_flowchart_input_output(200, 100),
  )
  // It is NOT the same as the parallelogram (40 vs 25 slant).
  assert_true(
    build_geometry(ShapeFlowChartInputOutput, 200, 100) !=
    build_geometry(ShapeParallelogram, 200, 100),
  )
}

///|
/// §20.1.10.56 — the two-guide snipRoundRect honours both `adj1` (the
/// rounded top-left radius) and `adj2` (the top-right snip size). On a
/// 100×100 box `ss = 100`, so each guide value `N` yields `N/1000` px.
/// The first command `MoveTo(r, 0)` carries the rounded radius (adj1).
test "§20.1.9.18 snipRoundRect honours independent adj1/adj2 guides" {
  // adj1 = 40000 → r = 40; differs from the default (r = 16).
  let geo = build_geometry_with_adjustments(ShapeSnipRoundRect, 100, 100, [
    { name: "adj1", raw_formula: "val 40000", value: Some(40000) },
  ])
  assert_true(geo.commands[0] is MoveTo(40, 0))
  // The default keeps r = 16 (adj1 default 16667 → 16).
  assert_true(
    build_geometry_with_adjustments(ShapeSnipRoundRect, 100, 100, []).commands[0]
    is MoveTo(16, 0),
  )
}

///|
/// §20.1.10.56 roundRect gdLst — `a = pin 0 adj 50000`; corner radius
/// `x1 = ss·a/100000` with `ss = min(w, h)`. The first command
/// `MoveTo(r, 0)` carries the radius, so a custom `adj` is observable
/// there. On a 100×100 box `ss = 100` and `r = adj/1000` (integer).
test "§20.1.9.11 roundRect honours a custom adj guide with pinning" {
  // Default adj=16667 → r = 100*16667/100000 = 16 (truncated).
  assert_true(build_round_rect(100, 100).commands[0] is MoveTo(16, 0))
  // adj=30000 → r = 30.
  assert_true(
    build_round_rect(100, 100, adj=30000).commands[0] is MoveTo(30, 0),
  )
  // adj above the 50000 pin → clamped, r = 50 (a full semicircle end).
  assert_true(
    build_round_rect(100, 100, adj=90000).commands[0] is MoveTo(50, 0),
  )
  // Negative adj pins to 0 → square corners (r = 0).
  assert_true(build_round_rect(100, 100, adj=-5000).commands[0] is MoveTo(0, 0))
}

///|
/// §20.1.9.18 — a decoded `adj` override flows through
/// `build_geometry_with_adjustments` into the roundRect radius.
test "§20.1.9.18 adjustment override flows into build_geometry_with_adjustments" {
  let adjustments : Array[Adjustment] = [
    { name: "adj", raw_formula: "val 30000", value: Some(30000) },
  ]
  let geo = build_geometry_with_adjustments(
    ShapeRoundRect,
    100,
    100,
    adjustments,
  )
  assert_true(geo.commands[0] is MoveTo(30, 0))
}

///|
/// §20.1.9.11 — `adjustment_value` resolves a named guide, falls back
/// to the default when absent or when the formula is not the `val n`
/// form, and `pin_int` clamps to the guide's documented range.
test "§20.1.9.11 adjustment_value + pin_int helpers" {
  let adjustments : Array[Adjustment] = [
    { name: "adj1", raw_formula: "val 25000", value: Some(25000) },
    { name: "adj2", raw_formula: "val 12500", value: Some(12500) },
  ]
  @debug.assert_eq(adjustment_value(adjustments, "adj1", 0), 25000)
  @debug.assert_eq(adjustment_value(adjustments, "adj2", 0), 12500)
  @debug.assert_eq(adjustment_value(adjustments, "adj3", 99), 99)
  // Guide present but a non-`val` formula (value None) → default.
  let non_val : Array[Adjustment] = [
    { name: "adj", raw_formula: "*/ h 2 3", value: None },
  ]
  @debug.assert_eq(adjustment_value(non_val, "adj", 16667), 16667)
  @debug.assert_eq(pin_int(90000, 0, 50000), 50000)
  @debug.assert_eq(pin_int(-3, 0, 50000), 0)
  @debug.assert_eq(pin_int(20000, 0, 50000), 20000)
}

///|
/// §20.1.9.5 avLst — `read_adjustments_lenient` extracts the guide
/// overrides from a `prstGeom` element and skips any `gd` missing the
/// required `@name`/`@fmla` rather than raising.
test "§20.1.9.5 read_adjustments_lenient parses avLst and skips malformed gd" {
  let el = parse_root(
    "<a:prstGeom xmlns:a=\"x\" prst=\"roundRect\">" +
    "<a:avLst>" +
    "<a:gd name=\"adj\" fmla=\"val 30000\"/>" +
    "<a:gd fmla=\"val 1\"/>" +
    "<a:gd name=\"bad\"/>" +
    "</a:avLst>" +
    "</a:prstGeom>",
  )
  let adj = read_adjustments_lenient(el)
  @debug.assert_eq(adj.length(), 1)
  @debug.assert_eq(adj[0].name, "adj")
  @debug.assert_eq(adj[0].value, Some(30000))
}
