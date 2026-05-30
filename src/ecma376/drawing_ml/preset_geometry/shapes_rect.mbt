///|
/// Part 1 §20.1.10.56 `rect` — four-corner rectangle covering the full
/// bounding box. Path order goes clockwise starting from the top-left
/// (renderer convention) and closes back to the origin.
pub fn build_rect(width : Int, height : Int) -> ShapeGeometry {
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, 0))
  commands.push(LineTo(width, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `plaque` — rectangle with the four corners
/// scalloped inward by the `adj` guide. The default `adj` is 16667 (≈
/// 1/6 of the side length) and is the value the spec image is drawn
/// against; a document `avLst` override is honoured here per the
/// §20.1.10.56 plaque gdLst (`a = pin 0 adj 50000`, scallop radius
/// `ss·a/100000`). The implementation uses quadratic Beziers along the
/// diagonals so the SVG-style ArcTo command stays unused; the
/// renderer can refine to true arcs later.
pub fn build_plaque(width : Int, height : Int, adj~ : Int = 16667) -> ShapeGeometry {
  let r = percent(min_dim(width, height), pin_int(adj, 0, 50000))
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(r, 0))
  commands.push(LineTo(width - r, 0))
  commands.push(QuadTo(width, 0, width, r))
  commands.push(LineTo(width, height - r))
  commands.push(QuadTo(width, height, width - r, height))
  commands.push(LineTo(r, height))
  commands.push(QuadTo(0, height, 0, height - r))
  commands.push(LineTo(0, r))
  commands.push(QuadTo(0, 0, r, 0))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `roundRect` — rectangle with four equal rounded
/// corners. The default `adj` guide is 16667 ≈ 1/6 of the shorter
/// side; a document `avLst` override is honoured here per the
/// §20.1.10.56 roundRect gdLst (`a = pin 0 adj 50000`, corner radius
/// `x1 = ss·a/100000` with `ss = min(w, h)`). The corner is rendered
/// as a quadratic Bezier whose control point sits at the un-rounded
/// corner; this is the same construction MS PowerPoint uses for
/// shallow corner radii.
pub fn build_round_rect(
  width : Int,
  height : Int,
  adj~ : Int = 16667,
) -> ShapeGeometry {
  let r = percent(min_dim(width, height), pin_int(adj, 0, 50000))
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(r, 0))
  commands.push(LineTo(width - r, 0))
  commands.push(QuadTo(width, 0, width, r))
  commands.push(LineTo(width, height - r))
  commands.push(QuadTo(width, height, width - r, height))
  commands.push(LineTo(r, height))
  commands.push(QuadTo(0, height, 0, height - r))
  commands.push(LineTo(0, r))
  commands.push(QuadTo(0, 0, r, 0))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `ellipse` — full ellipse inscribed in the
/// bounding box. Two ArcTo commands sweep top-half then bottom-half
/// so the SVG-style `large_arc` flag stays false and renderers that
/// only handle 180°-or-less arcs still draw the full shape.
pub fn build_ellipse(width : Int, height : Int) -> ShapeGeometry {
  let rx = width / 2
  let ry = height / 2
  let cx = width / 2
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, ry))
  commands.push(ArcTo(rx, ry, 0, false, true, cx * 2, ry))
  commands.push(ArcTo(rx, ry, 0, false, true, 0, ry))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `triangle` — isoceles triangle with the apex on
/// the top edge centred horizontally, base on the bottom edge.
pub fn build_triangle(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(cx, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `rtTriangle` — right triangle with the right
/// angle at the bottom-left corner, hypotenuse from top-left to
/// bottom-right.
pub fn build_right_triangle(width : Int, height : Int) -> ShapeGeometry {
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// §20.1.10.56 — the four-point parallelogram outline for a given
/// horizontal `slant` (the top edge is shifted right by `slant`, the
/// bottom edge left by the same): `(slant,0) → (w,0) → (w-slant,h) →
/// (0,h)`. Shared by `parallelogram` (adjustable, `ss`-based slant)
/// and `flowChartInputOutput` (fixed `w/5` slant).
fn parallelogram_path(width : Int, height : Int, slant : Int) -> ShapeGeometry {
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(slant, 0))
  commands.push(LineTo(width, 0))
  commands.push(LineTo(width - slant, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `parallelogram` — leaning rectangle whose top
/// and bottom edges are horizontal but whose left and right edges
/// slant by the `adj` guide. Per the spec gdLst, `maxAdj = 100000·w/ss`,
/// `a = pin 0 adj maxAdj`, and the slant `x2 = ss·a/100000` is a
/// fraction of the SHORTER side `ss = min(w, h)` (NOT of the width —
/// the two differ for non-square boxes). The default `adj` is 25000.
pub fn build_parallelogram(
  width : Int,
  height : Int,
  adj~ : Int = 25000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let max_adj = if ss == 0 { 0 } else { fraction(100000, width, ss) }
  parallelogram_path(width, height, percent(ss, pin_int(adj, 0, max_adj)))
}

///|
/// Part 1 §20.1.10.56 `flowChartInputOutput` — the data-I/O flowchart
/// symbol is a parallelogram with a FIXED slant (no `avLst`): the spec
/// path runs `(0,b) → (1,t) → (5,t) → (4,b)` on a 5-unit frame, i.e.
/// the slant is exactly `w/5` (20 % of the width). It is rendered
/// separately from `parallelogram` because the latter's slant is an
/// adjustable fraction of `ss`, not the fixed `w/5` used here.
pub fn build_flowchart_input_output(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  parallelogram_path(width, height, fraction(width, 1, 5))
}

///|
/// Part 1 §20.1.10.56 `trapezoid` — isoceles trapezoid with the wider
/// base on the bottom edge. Per the spec gdLst, `maxAdj = 50000·w/ss`,
/// `a = pin 0 adj maxAdj`, and each top-edge inset `x2 = ss·a/100000`
/// is a fraction of the SHORTER side `ss = min(w, h)` (NOT the width).
/// The default `adj` is 25000.
pub fn build_trapezoid(
  width : Int,
  height : Int,
  adj~ : Int = 25000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let max_adj = if ss == 0 { 0 } else { fraction(50000, width, ss) }
  let inset = percent(ss, pin_int(adj, 0, max_adj))
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(inset, 0))
  commands.push(LineTo(width - inset, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `diamond` — diamond / rhombus inscribed in the
/// bounding box with corners at the midpoint of each side.
pub fn build_diamond(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(cx, 0))
  commands.push(LineTo(width, cy))
  commands.push(LineTo(cx, height))
  commands.push(LineTo(0, cy))
  commands.push(ClosePath)
  { commands, width, height }
}

// (The former `build_regular_polygon` generic n-gon generator was
// removed: the §20.1.10.56 pentagon/hexagon/heptagon/octagon/decagon/
// dodecagon presets are NOT inscribed regular polygons — they carry
// per-shape hf/vf aspect factors and edge-pinned vertices — so they are
// now materialised faithfully from their spec definitions via the
// data-driven guide engine in `shape_polygons_def.mbt`.)

///|
/// Part 1 §20.1.10.56 `heart` — heart shape rendered with two cubic
/// Bezier lobes meeting at the top-centre dimple and a single cubic
/// sweeping down to the apex. The control points follow the
/// canonical 1:1 aspect-ratio heart used by the spec image.
pub fn build_heart(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let lobe_y = percent(height, 30000)
  let apex_y = height
  let side_x = percent(width, 90000)
  let inner_x = percent(width, 25000)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(cx, percent(height, 25000)))
  // Left lobe
  commands.push(
    CurveTo(
      percent(width, 35000),
      -percent(height, 10000),
      -percent(width, 25000),
      percent(height, 40000),
      width - side_x,
      lobe_y,
    ),
  )
  // Down to apex along left side
  commands.push(
    CurveTo(
      inner_x,
      percent(height, 55000),
      percent(width, 35000),
      percent(height, 80000),
      cx,
      apex_y,
    ),
  )
  // Up from apex along right side
  commands.push(
    CurveTo(
      percent(width, 65000),
      percent(height, 80000),
      width - inner_x,
      percent(height, 55000),
      side_x,
      lobe_y,
    ),
  )
  // Right lobe
  commands.push(
    CurveTo(
      width + percent(width, 25000),
      percent(height, 40000),
      percent(width, 65000),
      -percent(height, 10000),
      cx,
      percent(height, 25000),
    ),
  )
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `cloud` — FAITHFUL transcription of the spec
/// preset path. The spec outline is an eleven-arc bump path drawn in a
/// 43200×43200 coordinate frame; each `arcTo` carries literal radii
/// `(wR, hR)` and angles `(stAng, swAng)`. The path is scaled into the
/// caller's `(w, h)` box (x by `w/43200`, y by `h/43200`) and each arc
/// is emitted through the independently-verified `rel_arc` helper, so
/// the geometry is correct by construction. The spec's second
/// (`fill="none"`) detail-stroke subpath is decorative and omitted.
pub fn build_cloud(width : Int, height : Int) -> ShapeGeometry {
  let sx = fn(v : Int) -> Int { fraction(v, width, 43200) }
  let sy = fn(v : Int) -> Int { fraction(v, height, 43200) }
  // (wR, hR, stAng, swAng) for the eleven bump arcs, verbatim from the
  // spec presetShapeDefinitions cloud path.
  let arcs : Array[(Int, Int, Int, Int)] = [
    (6753, 9190, -11429249, 7426832),
    (5333, 7267, -8646143, 5396714),
    (4365, 5945, -8748475, 5983381),
    (4857, 6595, -7859164, 7034504),
    (5333, 7273, -4722533, 6541615),
    (6775, 9220, -2776035, 7816140),
    (5785, 7867, 37501, 6842000),
    (6752, 9215, 1347096, 6910353),
    (7720, 10543, 3974558, 4542661),
    (4360, 5918, -16496525, 8804134),
    (4345, 5945, -14809710, 9151131),
  ]
  let commands : Array[PathCommand] = []
  let mut cx = sx(3900)
  let mut cy = sy(14370)
  commands.push(MoveTo(cx, cy))
  for arc in arcs {
    let (wr, hr, st, sw) = arc
    let (cmd, ex, ey) = rel_arc(cx, cy, sx(wr), sy(hr), st, sw)
    commands.push(cmd)
    cx = ex
    cy = ey
  }
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `smileyFace` — circular face boundary with two
/// dots for eyes and a curved mouth. Each feature is its own
/// subpath; the renderer treats the combined commands as a single
/// even-odd or non-zero fill region.
pub fn build_smiley_face(width : Int, height : Int) -> ShapeGeometry {
  let face = build_ellipse(width, height)
  let commands : Array[PathCommand] = []
  for cmd in face.commands {
    commands.push(cmd)
  }
  // Left eye
  let eye_rx = percent(width, 6000)
  let eye_ry = percent(height, 8000)
  let left_eye_cx = percent(width, 33000)
  let right_eye_cx = percent(width, 67000)
  let eye_cy = percent(height, 33000)
  commands.push(MoveTo(left_eye_cx - eye_rx, eye_cy))
  commands.push(
    ArcTo(eye_rx, eye_ry, 0, false, true, left_eye_cx + eye_rx, eye_cy),
  )
  commands.push(
    ArcTo(eye_rx, eye_ry, 0, false, true, left_eye_cx - eye_rx, eye_cy),
  )
  commands.push(ClosePath)
  commands.push(MoveTo(right_eye_cx - eye_rx, eye_cy))
  commands.push(
    ArcTo(eye_rx, eye_ry, 0, false, true, right_eye_cx + eye_rx, eye_cy),
  )
  commands.push(
    ArcTo(eye_rx, eye_ry, 0, false, true, right_eye_cx - eye_rx, eye_cy),
  )
  commands.push(ClosePath)
  // Mouth — quadratic smile from 25% to 75% width at 65% height with
  // control point at the bottom centre.
  let mouth_left_x = percent(width, 25000)
  let mouth_right_x = percent(width, 75000)
  let mouth_y = percent(height, 65000)
  let mouth_cp_y = percent(height, 85000)
  commands.push(MoveTo(mouth_left_x, mouth_y))
  commands.push(QuadTo(width / 2, mouth_cp_y, mouth_right_x, mouth_y))
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `plus` — plus / cross filling the bounding box,
/// arms reaching all four edges. Per the spec gdLst `a = pin 0 adj
/// 50000`, `x1 = ss·a/100000` is the corner INSET (default `adj =
/// 25000` → `x1 = ss/4`); the arm thickness is therefore `w − 2·x1`
/// (vertical) and `h − 2·x1` (horizontal). The 12-point outline
/// follows the spec path `(l,x1) → (x1,x1) → (x1,t) → (x2,t) →
/// (x2,x1) → (r,x1) → (r,y2) → (x2,y2) → (x2,b) → (x1,b) → (x1,y2) →
/// (l,y2)` with `x2 = r − x1`, `y2 = b − x1`.
pub fn build_plus(width : Int, height : Int, adj~ : Int = 25000) -> ShapeGeometry {
  let x1 = percent(min_dim(width, height), pin_int(adj, 0, 50000))
  let x2 = width - x1
  let y2 = height - x1
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, x1))
  commands.push(LineTo(x1, x1))
  commands.push(LineTo(x1, 0))
  commands.push(LineTo(x2, 0))
  commands.push(LineTo(x2, x1))
  commands.push(LineTo(width, x1))
  commands.push(LineTo(width, y2))
  commands.push(LineTo(x2, y2))
  commands.push(LineTo(x2, height))
  commands.push(LineTo(x1, height))
  commands.push(LineTo(x1, y2))
  commands.push(LineTo(0, y2))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// §20.1.10.56 `mathPlus` — the math `+` operator is a CENTRED cross
/// that does NOT reach the bounding-box edges. Per the spec gdLst the
/// two bars are `2·dx1 = w·73490/100000` long horizontally and
/// `2·dy1 = h·73490/100000` long vertically, with a common arm
/// half-thickness `dx2 = ss·a1/200000` (`a1 = pin 0 adj1 73490`,
/// default 23520). The 12-point outline is
/// `(x1,y2)→(x2,y2)→(x2,y1)→(x3,y1)→(x3,y2)→(x4,y2)→(x4,y3)→(x3,y3)→
/// (x3,y4)→(x2,y4)→(x2,y3)→(x1,y3)` where `x1<x2<hc<x3<x4` and
/// `y1<y2<vc<y3<y4`. `mathMultiply` reuses this cross (rotated).
pub fn build_math_plus(
  width : Int,
  height : Int,
  adj1~ : Int = 23520,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let a1 = pin_int(adj1, 0, 73490)
  let dx1 = fraction(width, 73490, 200000) // half horizontal-bar length
  let dy1 = fraction(height, 73490, 200000) // half vertical-bar length
  let dx2 = fraction(ss, a1, 200000) // half arm thickness
  let hc = width / 2
  let vc = height / 2
  let x1 = hc - dx1
  let x2 = hc - dx2
  let x3 = hc + dx2
  let x4 = hc + dx1
  let y1 = vc - dy1
  let y2 = vc - dx2
  let y3 = vc + dx2
  let y4 = vc + dy1
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(x1, y2))
  commands.push(LineTo(x2, y2))
  commands.push(LineTo(x2, y1))
  commands.push(LineTo(x3, y1))
  commands.push(LineTo(x3, y2))
  commands.push(LineTo(x4, y2))
  commands.push(LineTo(x4, y3))
  commands.push(LineTo(x3, y3))
  commands.push(LineTo(x3, y4))
  commands.push(LineTo(x2, y4))
  commands.push(LineTo(x2, y3))
  commands.push(LineTo(x1, y3))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `mathMinus` — horizontal bar centred in the
/// bounding box. Per the spec gdLst the bar is `a1 = pin 0 adj1
/// 100000` tall (`2·dy1 = h·a1/100000`, default `adj1 = 23520`) and
/// `2·dx1 = w·73490/100000` wide (≈ 73.5 % of the width, centred at
/// `hc`) — NOT the full width. Both extents are centred via
/// `x1 = hc − dx1` / `y1 = vc − dy1`.
pub fn build_minus(width : Int, height : Int, adj~ : Int = 23520) -> ShapeGeometry {
  let bar_h = percent(height, pin_int(adj, 0, 100000))
  let top_y = (height - bar_h) / 2
  let bottom_y = (height + bar_h) / 2
  // §20.1.10.56 dx1 = w·73490/200000; the bar spans hc ± dx1.
  let dx1 = fraction(width, 73490, 200000)
  let hc = width / 2
  let left_x = hc - dx1
  let right_x = hc + dx1
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(left_x, top_y))
  commands.push(LineTo(right_x, top_y))
  commands.push(LineTo(right_x, bottom_y))
  commands.push(LineTo(left_x, bottom_y))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `mathMultiply` — multiplication sign rendered as
/// a rotated plus. Per the spec the rotation angle is `ang = at2 w h`
/// so the arms align with the box DIAGONALS (not a fixed 45°). Rather
/// than compute the angle, the rotation cosine/sine are taken directly
/// as `cos = w/diag`, `sin = h/diag` with `diag = √(w²+h²)`; for a
/// square box this is exactly `45°` (`cos = sin = 7071`), matching the
/// prior behaviour, while non-square boxes now slant correctly.
pub fn build_multiply(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let plus = build_math_plus(width, height)
  let diag = (width * width + height * height).to_double().sqrt()
  let (cos_ang, sin_ang) = if diag == 0.0 {
    (10000, 0)
  } else {
    (
      (width.to_double() * 10000.0 / diag).to_int(),
      (height.to_double() * 10000.0 / diag).to_int(),
    )
  }
  let commands : Array[PathCommand] = []
  for cmd in plus.commands {
    match cmd {
      MoveTo(x, y) => {
        let (rx, ry) = rotate_about(x, y, cx, cy, cos_ang, sin_ang)
        commands.push(MoveTo(rx, ry))
      }
      LineTo(x, y) => {
        let (rx, ry) = rotate_about(x, y, cx, cy, cos_ang, sin_ang)
        commands.push(LineTo(rx, ry))
      }
      ClosePath => commands.push(ClosePath)
      other => commands.push(other)
    }
  }
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `mathDivide` — the division sign `÷`: a
/// horizontal bar with a centred dot above and below it.
///
/// FAITHFUL transcription of the spec preset path and guide chain.
/// `a1 = pin 1000 adj1 36745` sets the half bar thickness
/// `dy1 = h·a1/200000`; `a3 = pin 1000 adj3 maxAdj3` (with
/// `maxAdj3 = min((73490−a1)/4, 36745·w/h)`) sets the dot radius
/// `rad = h·a3/100000`; `a2 = pin 0 adj2 maxAdj2` (with
/// `maxAdj2 = 73490 − 4·a3 − a1`) sets the dot-to-bar gap
/// `yg = h·a2/100000`. The bar spans `±dx1 = ±w·73490/200000` about
/// `hc`, its top/bottom at `vc ∓ dy1`; the dots sit at `vc − dy1 − yg
/// − rad` and its mirror. Every value is a 1:1 transcription of the
/// spec `gdLst`. Spec `avLst`: `adj1 = 23520`, `adj2 = 5880`,
/// `adj3 = 11760`.
pub fn build_divide(
  width : Int,
  height : Int,
  adj1~ : Int = 23520,
  adj2~ : Int = 5880,
  adj3~ : Int = 11760,
) -> ShapeGeometry {
  let w = width
  let h = height
  let hc = width / 2
  let vc = height / 2
  let a1 = pin_int(adj1, 1000, 36745)
  let ma3h = (73490 - a1) / 4 // +/ 73490 (-a1) 4
  let ma3w = if h == 0 { 0 } else { fraction(36745, w, h) } // */ 36745 w h
  let max_adj3 = if ma3h < ma3w { ma3h } else { ma3w }
  let a3 = pin_int(adj3, 1000, max_adj3)
  let max_adj2 = 73490 - 4 * a3 - a1 // +- 73490 (-4·a3) a1
  let a2 = pin_int(adj2, 0, max_adj2)
  let dy1 = fraction(h, a1, 200000) // half bar thickness
  let yg = fraction(h, a2, 100000) // dot-to-bar gap
  let rad = fraction(h, a3, 100000) // dot radius
  let dx1 = fraction(w, 73490, 200000) // half bar width
  let y3 = vc - dy1 // bar top
  let y4 = vc + dy1 // bar bottom
  let y2 = y3 - (yg + rad) // top dot centre
  let x1 = hc - dx1 // bar left
  let x3 = hc + dx1 // bar right
  let commands : Array[PathCommand] = []
  // Top dot, then its mirror below the bar.
  push_circle(commands, hc, y2, rad)
  push_circle(commands, hc, h - y2, rad)
  // Bar.
  commands.push(MoveTo(x1, y3))
  commands.push(LineTo(x3, y3))
  commands.push(LineTo(x3, y4))
  commands.push(LineTo(x1, y4))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `mathEqual` — two parallel horizontal bars,
/// each `w·73490/100000` wide (≈ 73.5 %) and centred at `hc`. Per the
/// spec gdLst: `a1 = pin 0 adj1 36745` (default 23520) sets each bar's
/// thickness `dy1 = h·a1/100000`; `a2 = pin 0 adj2 (100000−2·a1)`
/// (default 11760) sets the half-gap `dy2 = h·a2/200000` between the
/// bars, both measured from the vertical centre `vc`. The previous
/// code drew full-width bars with the thickness/gap guides swapped.
pub fn build_equal(
  width : Int,
  height : Int,
  adj1~ : Int = 23520,
  adj2~ : Int = 11760,
) -> ShapeGeometry {
  let a1 = pin_int(adj1, 0, 36745)
  let m_adj2 = 100000 - 2 * a1
  let a2 = pin_int(adj2, 0, m_adj2)
  let dy1 = percent(height, a1) // bar thickness
  let dy2 = fraction(height, a2, 200000) // half-gap from centre
  let dx1 = fraction(width, 73490, 200000) // half bar width
  let hc = width / 2
  let vc = height / 2
  let x1 = hc - dx1
  let x2 = hc + dx1
  let y2 = vc - dy2
  let y3 = vc + dy2
  let y1 = y2 - dy1
  let y4 = y3 + dy1
  let commands : Array[PathCommand] = []
  // Top bar.
  commands.push(MoveTo(x1, y1))
  commands.push(LineTo(x2, y1))
  commands.push(LineTo(x2, y2))
  commands.push(LineTo(x1, y2))
  commands.push(ClosePath)
  // Bottom bar.
  commands.push(MoveTo(x1, y3))
  commands.push(LineTo(x2, y3))
  commands.push(LineTo(x2, y4))
  commands.push(LineTo(x1, y4))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
fn min_dim(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn rotate_about(
  x : Int,
  y : Int,
  cx : Int,
  cy : Int,
  cos10000_value : Int,
  sin10000_value : Int,
) -> (Int, Int) {
  let dx = x - cx
  let dy = y - cy
  let nx = cx +
    fraction(dx, cos10000_value, 10000) -
    fraction(dy, sin10000_value, 10000)
  let ny = cy +
    fraction(dx, sin10000_value, 10000) +
    fraction(dy, cos10000_value, 10000)
  (nx, ny)
}

///|
fn push_circle(
  commands : Array[PathCommand],
  cx : Int,
  cy : Int,
  r : Int,
) -> Unit {
  commands.push(MoveTo(cx - r, cy))
  commands.push(ArcTo(r, r, 0, false, true, cx + r, cy))
  commands.push(ArcTo(r, r, 0, false, true, cx - r, cy))
  commands.push(ClosePath)
}
