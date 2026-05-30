// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — the regular n-gon
// presets (pentagon / hexagon / heptagon / octagon / decagon /
// dodecagon).
//
// These are NOT plain regular polygons inscribed in a circle: the spec
// stretches them by per-shape `hf`/`vf` aspect factors (or, for hexagon
// / octagon, an `adj` chamfer guide) and pins specific vertices to the
// box edges — e.g. hexagon is flat-topped with points at left/right,
// octagon is a chamfered square. Each definition is copied VERBATIM
// from `presetShapeDefinitions.xml` and evaluated by the data-driven
// `guide_engine`, replacing the earlier generic-regular-polygon
// approximation (which had the wrong orientation/aspect).

///|
/// §20.1.10.56 `pentagon` — point up, `hf`/`vf` stretched.
fn pentagon_def() -> PresetGuideDef {
  {
    adjusts: [],
    guides: [
      ("hf", "val 105146"),
      ("vf", "val 110557"),
      ("swd2", "*/ wd2 hf 100000"),
      ("shd2", "*/ hd2 vf 100000"),
      ("svc", "*/ vc vf 100000"),
      ("dx1", "cos swd2 1080000"),
      ("dx2", "cos swd2 18360000"),
      ("dy1", "sin shd2 1080000"),
      ("dy2", "sin shd2 18360000"),
      ("x1", "+- hc 0 dx1"),
      ("x2", "+- hc 0 dx2"),
      ("x3", "+- hc dx2 0"),
      ("x4", "+- hc dx1 0"),
      ("y1", "+- svc 0 dy1"),
      ("y2", "+- svc 0 dy2"),
    ],
    path: [
      PMoveTo("x1", "y1"),
      PLnTo("hc", "t"),
      PLnTo("x4", "y1"),
      PLnTo("x3", "y2"),
      PLnTo("x2", "y2"),
      PClose,
    ],
  }
}

///|
/// §20.1.10.56 `hexagon` — flat-topped, points at left/right; `adj`
/// chamfers the corners, `vf = 115470` sets the regular aspect.
fn hexagon_def() -> PresetGuideDef {
  {
    adjusts: [("adj", 25000.0)],
    guides: [
      ("vf", "val 115470"),
      ("maxAdj", "*/ 50000 w ss"),
      ("a", "pin 0 adj maxAdj"),
      ("shd2", "*/ hd2 vf 100000"),
      ("x1", "*/ ss a 100000"),
      ("x2", "+- r 0 x1"),
      ("dy1", "sin shd2 3600000"),
      ("y1", "+- vc 0 dy1"),
      ("y2", "+- vc dy1 0"),
    ],
    path: [
      PMoveTo("l", "vc"),
      PLnTo("x1", "y1"),
      PLnTo("x2", "y1"),
      PLnTo("r", "vc"),
      PLnTo("x2", "y2"),
      PLnTo("x1", "y2"),
      PClose,
    ],
  }
}

///|
/// §20.1.10.56 `heptagon` — point up, `hf`/`vf` stretched with the
/// spec's 7-gon cosine ratios.
fn heptagon_def() -> PresetGuideDef {
  {
    adjusts: [],
    guides: [
      ("hf", "val 102572"),
      ("vf", "val 105210"),
      ("swd2", "*/ wd2 hf 100000"),
      ("shd2", "*/ hd2 vf 100000"),
      ("svc", "*/ vc vf 100000"),
      ("dx1", "*/ swd2 97493 100000"),
      ("dx2", "*/ swd2 78183 100000"),
      ("dx3", "*/ swd2 43388 100000"),
      ("dy1", "*/ shd2 62349 100000"),
      ("dy2", "*/ shd2 22252 100000"),
      ("dy3", "*/ shd2 90097 100000"),
      ("x1", "+- hc 0 dx1"),
      ("x2", "+- hc 0 dx2"),
      ("x3", "+- hc 0 dx3"),
      ("x4", "+- hc dx3 0"),
      ("x5", "+- hc dx2 0"),
      ("x6", "+- hc dx1 0"),
      ("y1", "+- svc 0 dy1"),
      ("y2", "+- svc dy2 0"),
      ("y3", "+- svc dy3 0"),
    ],
    path: [
      PMoveTo("x1", "y2"),
      PLnTo("x2", "y1"),
      PLnTo("hc", "t"),
      PLnTo("x5", "y1"),
      PLnTo("x6", "y2"),
      PLnTo("x4", "y3"),
      PLnTo("x3", "y3"),
      PClose,
    ],
  }
}

///|
/// §20.1.10.56 `octagon` — a chamfered square; `adj = 29289` (≈ 1−1/√2)
/// sets the corner cut.
fn octagon_def() -> PresetGuideDef {
  {
    adjusts: [("adj", 29289.0)],
    guides: [
      ("a", "pin 0 adj 50000"),
      ("x1", "*/ ss a 100000"),
      ("x2", "+- r 0 x1"),
      ("y2", "+- b 0 x1"),
    ],
    path: [
      PMoveTo("l", "x1"),
      PLnTo("x1", "t"),
      PLnTo("x2", "t"),
      PLnTo("r", "x1"),
      PLnTo("r", "y2"),
      PLnTo("x2", "b"),
      PLnTo("x1", "b"),
      PLnTo("l", "y2"),
      PClose,
    ],
  }
}

///|
/// §20.1.10.56 `decagon` — point at left/right; `vf = 105146` aspect.
fn decagon_def() -> PresetGuideDef {
  {
    adjusts: [],
    guides: [
      ("vf", "val 105146"),
      ("shd2", "*/ hd2 vf 100000"),
      ("dx1", "cos wd2 2160000"),
      ("dx2", "cos wd2 4320000"),
      ("x1", "+- hc 0 dx1"),
      ("x2", "+- hc 0 dx2"),
      ("x3", "+- hc dx2 0"),
      ("x4", "+- hc dx1 0"),
      ("dy1", "sin shd2 4320000"),
      ("dy2", "sin shd2 2160000"),
      ("y1", "+- vc 0 dy1"),
      ("y2", "+- vc 0 dy2"),
      ("y3", "+- vc dy2 0"),
      ("y4", "+- vc dy1 0"),
    ],
    path: [
      PMoveTo("l", "vc"),
      PLnTo("x1", "y2"),
      PLnTo("x2", "y1"),
      PLnTo("x3", "y1"),
      PLnTo("x4", "y2"),
      PLnTo("r", "vc"),
      PLnTo("x4", "y3"),
      PLnTo("x3", "y4"),
      PLnTo("x2", "y4"),
      PLnTo("x1", "y3"),
      PClose,
    ],
  }
}

///|
/// §20.1.10.56 `dodecagon` — flat top/bottom/left/right; vertices at the
/// spec's 21600-frame fractions.
fn dodecagon_def() -> PresetGuideDef {
  {
    adjusts: [],
    guides: [
      ("x1", "*/ w 2894 21600"),
      ("x2", "*/ w 7906 21600"),
      ("x3", "*/ w 13694 21600"),
      ("x4", "*/ w 18706 21600"),
      ("y1", "*/ h 2894 21600"),
      ("y2", "*/ h 7906 21600"),
      ("y3", "*/ h 13694 21600"),
      ("y4", "*/ h 18706 21600"),
    ],
    path: [
      PMoveTo("l", "y2"),
      PLnTo("x1", "y1"),
      PLnTo("x2", "t"),
      PLnTo("x3", "t"),
      PLnTo("x4", "y1"),
      PLnTo("r", "y2"),
      PLnTo("r", "y3"),
      PLnTo("x4", "y4"),
      PLnTo("x3", "b"),
      PLnTo("x2", "b"),
      PLnTo("x1", "y4"),
      PLnTo("l", "y3"),
      PClose,
    ],
  }
}
