// @source web-pptx packages/@aurochs-renderer/drawing-ml/src/svg/geometry/preset-shapes.ts
//
// Preset arrow shapes — direct port of every arrow / chevron / homePlate
// generator in `preset-shapes.ts`.  The TS implementation builds its own
// local `GuideContext` (independent of the caller's) for each shape; we
// mirror that by cloning the incoming context into a local `Map` so that
// guide bindings introduced here do not leak back into the dispatcher.
//
// Owned presets (31):
//   rightArrow, leftArrow, upArrow, downArrow,
//   leftRightArrow, upDownArrow,
//   stripedRightArrow, notchedRightArrow, bentUpArrow, bentArrow,
//   leftUpArrow, leftRightUpArrow, quadArrow,
//   leftArrowCallout, rightArrowCallout, upArrowCallout,
//   downArrowCallout, leftRightArrowCallout, upDownArrowCallout,
//   quadArrowCallout, uturnArrow, circularArrow, leftCircularArrow,
//   leftRightCircularArrow, curvedRightArrow, curvedLeftArrow,
//   curvedUpArrow, curvedDownArrow, swooshArrow, chevron, homePlate.
//
// ECMA-376 references:
//   §20.1.10.55  ST_ShapeType
//   §20.1.10.56  Preset shape built-ins

// ============================================================================
// Helpers — local context cloning and arc segment generation
// ============================================================================

///|
/// Clone every binding from `src` into a new `GuideContext`.  Mirrors
/// the TS pattern where each `render*Path` builds an entirely fresh
/// `createGuideContext(w, h, [...])` rather than reusing the dispatcher's
/// context.  Caller then overrides whatever adjust values are relevant.
fn clone_ctx(src : GuideContext) -> GuideContext {
  let dst : GuideContext = Map([], capacity=0)
  for k, v in src {
    dst[k] = v
  }
  dst
}

///|
/// Read a guide value, defaulting to `0.0` if unset.  The TS code throws
/// on `undefined`; the renderer prefers to emit a path with zero-valued
/// coordinates so the rest of the slide still renders.
fn g(ctx : GuideContext, name : String) -> Double {
  ctx.get(name).unwrap_or(0.0)
}

///|
/// One path command from the TS `buildPresetPath` repertoire.  Mirrors
/// `PresetPathCommand` in `preset-shapes.ts:1001`.
priv enum ArrowCmd {
  MoveTo(Double, Double)
  LineTo(Double, Double)
  ArcTo(Double, Double, Double, Double) // wR, hR, stAng, swAng
  Close
}

///|
/// ECMA-376 angle units → radians.  Same constant as
/// `ANGLE_TO_RADIANS` in `preset-shapes.ts:1008`.
let arrow_angle_to_rad : Double = 3.141592653589793 / (180.0 * 60000.0)

///|
/// Half-circle in ECMA angle units, for the SVG `large-arc-flag`
/// decision in `preset-shapes.ts:1053`.
let arrow_half_circle : Double = 10800000.0

///|
/// Build an SVG path string from a list of arrow commands.  Tracks the
/// "current" pen position the same way `buildPresetPath` does so that
/// `arcTo` can convert ECMA polar arcs into SVG elliptical arcs.
fn build_arrow_path(commands : Array[ArrowCmd]) -> String {
  let segments : Array[String] = []
  let mut cx = 0.0
  let mut cy = 0.0
  for cmd in commands {
    match cmd {
      MoveTo(x, y) => {
        cx = x
        cy = y
        segments.push("M " + fmt(x) + " " + fmt(y))
      }
      LineTo(x, y) => {
        cx = x
        cy = y
        segments.push("L " + fmt(x) + " " + fmt(y))
      }
      ArcTo(w_r, h_r, st_ang, sw_ang) => {
        let start_rad = st_ang * arrow_angle_to_rad
        let end_rad = (st_ang + sw_ang) * arrow_angle_to_rad
        let center_x = cx - w_r * @math.cos(start_rad)
        let center_y = cy - h_r * @math.sin(start_rad)
        let end_x = center_x + w_r * @math.cos(end_rad)
        let end_y = center_y + h_r * @math.sin(end_rad)
        let abs_sw = if sw_ang < 0.0 { -sw_ang } else { sw_ang }
        let large_arc = if abs_sw > arrow_half_circle { 1 } else { 0 }
        let sweep = if sw_ang >= 0.0 { 1 } else { 0 }
        segments.push(
          "A " +
          fmt(w_r) +
          " " +
          fmt(h_r) +
          " 0 " +
          large_arc.to_string() +
          " " +
          sweep.to_string() +
          " " +
          fmt(end_x) +
          " " +
          fmt(end_y),
        )
        cx = end_x
        cy = end_y
      }
      Close => segments.push("Z")
    }
  }
  let buf = StringBuilder::new()
  for i in 0..<segments.length() {
    if i > 0 {
      buf.write_string(" ")
    }
    buf.write_string(segments[i])
  }
  buf.to_string()
}

// ============================================================================
// Curved-arrow (curved{Right,Left,Up,Down}Arrow) — body + darkenLess overlay
//
// The reference renderer draws these four legacy presets as a 3-D
// ribbon-loop, not the literal §20.1.10.24 silhouette.  Empirical
// analysis of the reference SVG for the curved-arrows family (default
// adj 25 000 / 50 000 / 25 000) shows that the whole silhouette is
// parametrised by exactly TWO axis-aligned ellipses that share rx, ry
// and differ only by a `th`-sized translation in the perpendicular
// direction:
//
//   E1 (inner) — centre on the spec's centre-line: (w, hR) for Right
//   E2 (outer) — translated by (0, +th) so its centre is (w, y3 = hR + th)
//
// The orange front-ribbon traces the LOWER halves of both ellipses (start at
// (l, hR), sweep CCW on E1 to (x1, hR+dy), through the arrowhead notch and
// tip, then sweep CW on E2 back to (l, y3)).  The brown `darkenLess` back-
// ribbon traces the UPPER halves of both ellipses, with a tiny corner-cap
// arc connecting the two halves at the spec's pre-defined intersection
// point (ix, iy) = ((hR+y3)/2, w-idx).
//
// The spec's published swAng / stAng formulas are GEOMETRICALLY INCONSISTENT
// for these presets — `y5 = hR - dy` and `y4 = y5 - dh` produce negative
// coordinates for the default adjustments, and the published arcTo angles
// only sweep ~39° instead of the ~79° actually needed to land on (x1, hR+dy).
// The reference renderer silently corrects this.  We do the same
// here: compute the arc angles directly from the geometry rather
// than the spec's formulas.
//
// Symmetry:
//   - Left = Right mirrored across the vertical centre-line  (x → w - x)
//   - Up   = Right rotated 90° CW (and roles of w/h, hR/wR swap)
//   - Down = Right rotated 90° CCW
// ============================================================================

///|
/// Convert radians to OOXML angle units (60 000 × degrees).
fn curved_arrow_rad_to_units(rad : Double) -> Double {
  rad * 180.0 * 60000.0 / 3.141592653589793
}

///|
/// `acos(arg / rx)` in OOXML angle units.  Used for the main body arc
/// sweep, which is the angle on the body ellipse subtended by the band-
/// end at distance `arg` from the centre along the ellipse's major axis.
fn curved_arrow_acos_units(arg : Double, rx : Double) -> Double {
  let ratio = arg / rx
  let clamped = if ratio > 1.0 {
    1.0
  } else if ratio < -1.0 {
    -1.0
  } else {
    ratio
  }
  curved_arrow_rad_to_units(@math.acos(clamped))
}

///|
/// Angle from an axis-aligned ellipse's centre to the point
/// `(centre_x + dx_along, centre_y + dy_perp)` (signed, in OOXML units).
/// `atan2((dy_perp)/ry, (dx_along)/rx)`.
fn curved_arrow_atan2_units(
  dy_perp : Double,
  dx_along : Double,
  ry : Double,
  rx : Double,
) -> Double {
  curved_arrow_rad_to_units(@math.atan2(dy_perp / ry, dx_along / rx))
}

///|
/// Normalise an OOXML angle-units sweep into the equivalent SHORT-arc
/// value in [-180°, +180°] (= 21 600 000 / -21 600 000 OOXML units),
/// preserving sign.  The output's absolute value is <= 180°.
fn curved_arrow_normalise_sweep(sweep_units : Double) -> Double {
  let full = 360.0 * 60000.0
  let half = 180.0 * 60000.0
  let mut s = sweep_units
  while s > half {
    s = s - full
  }
  while s < -half {
    s = s + full
  }
  s
}

///|
/// `curvedRightArrow` — ECMA-376 §20.1.10.24.  Body path matches the
/// reference renderer by treating E1 (centre (w, hR)) as the inner ribbon edge and
/// E2 (centre (w, y3)) as the outer, with the corrected `+dy` end-point.
fn arrow_curved_right_arrow(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local_ctx = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local_ctx["adj1"] = adj1
  local_ctx["adj2"] = adj2
  local_ctx["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 h ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "a1", formula: "pin 0 adj1 a2" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw", formula: "*/ ss a2 100000" },
    { name: "q1", formula: "+/ th aw 4" },
    { name: "hR", formula: "+- hd2 0 q1" },
    { name: "q7", formula: "*/ hR 2 1" },
    { name: "q8", formula: "*/ q7 q7 1" },
    { name: "q9", formula: "*/ th th 1" },
    { name: "q10", formula: "+- q8 0 q9" },
    { name: "q11", formula: "sqrt q10" },
    { name: "idx", formula: "*/ q11 w q7" },
    { name: "maxAdj3", formula: "*/ 100000 idx ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "ah", formula: "*/ ss a3 100000" },
    { name: "q2", formula: "*/ w w 1" },
    { name: "q3", formula: "*/ ah ah 1" },
    { name: "q4", formula: "+- q2 0 q3" },
    { name: "q5", formula: "sqrt q4" },
    { name: "dy", formula: "*/ q5 hR w" },
    { name: "q6", formula: "+- aw 0 th" },
    { name: "dh", formula: "*/ q6 1 2" },
    { name: "aw2", formula: "*/ aw 1 2" },
    { name: "y6", formula: "+- b 0 aw2" },
    { name: "x1", formula: "+- r 0 ah" },
    { name: "y3", formula: "+- hR th 0" },
  ]
  evaluate_guides(guides, local_ctx)
  let l = g(local_ctx, "l")
  let r = g(local_ctx, "r")
  let width = g(local_ctx, "w")
  let h_r = g(local_ctx, "hR")
  let th = g(local_ctx, "th")
  let dy = g(local_ctx, "dy")
  let dh = g(local_ctx, "dh")
  let ah = g(local_ctx, "ah")
  let x1 = g(local_ctx, "x1")
  let y3 = g(local_ctx, "y3")
  let y6 = g(local_ctx, "y6")
  let cd2 = g(local_ctx, "cd2")
  // Reference-corrected band endpoints at the arrowhead side.  Inner ribbon edge
  // (on E1) ends at `(x1, hR + dy)`; outer edge (on E2) ends at `(x1, y3
  // + dy)`.  Arrowhead notch wings extend `dh` past those band-ends.
  let inner_end_y = h_r + dy
  let outer_start_y = y3 + dy
  let notch_top_y = inner_end_y - dh
  let notch_bot_y = outer_start_y + dh
  // Main-body arc sweep.  Spec writes `at2 ah dy` (≈39°); the geometric
  // value is `acos(ah / w)` (≈79° at default adj) — the angle subtended
  // by the band-end on either ellipse.
  let sw_main = curved_arrow_acos_units(ah, width)
  let _ = th // keep `th` in scope; used implicitly via y3 = hR+th
  build_arrow_path([
    MoveTo(l, h_r),
    // Inner edge (on E1, centre (w, hR)) — sweep CCW from 180° by -sw_main
    // (since the arc goes to (x1, hR+dy) at angle 180°-sw_main ≈ 100.8°
    // in OOXML's y-down angle convention).
    ArcTo(width, h_r, cd2, -sw_main),
    LineTo(x1, notch_top_y),
    LineTo(r, y6),
    LineTo(x1, notch_bot_y),
    LineTo(x1, outer_start_y),
    // Outer edge (on E2, centre (w, y3)) — sweep CW from (cd2-sw_main)
    // back to cd2 to land at (l, y3).  current point is (x1, y3+dy), so
    // start angle satisfies cos = -ah/w, sin = +dy/hR (Q2 ≈ 100.8°).
    ArcTo(width, h_r, cd2 - sw_main, sw_main),
    Close,
  ])
}

///|
/// `curvedLeftArrow` — horizontal flip of `curvedRightArrow`.  Body wraps
/// around the RIGHT half; arrowhead points LEFT (tip at (l, y6)).  Ellipses:
///
///   E1 (inner) — centre (l, hR)
///   E2 (outer) — centre (l, y3) = (l, hR + th)
///
/// Like Up arrow, the spec writes the body with both arcs CONSECUTIVE so
/// the reference renderer traces inner-E1 from the band-end through the RIGHT-side (ix, iy)
/// intersection, then outer-E2 back to the other band-end.
fn arrow_curved_left_arrow(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local_ctx = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local_ctx["adj1"] = adj1
  local_ctx["adj2"] = adj2
  local_ctx["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 h ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "a1", formula: "pin 0 adj1 a2" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw", formula: "*/ ss a2 100000" },
    { name: "q1", formula: "+/ th aw 4" },
    { name: "hR", formula: "+- hd2 0 q1" },
    { name: "q7", formula: "*/ hR 2 1" },
    { name: "q8", formula: "*/ q7 q7 1" },
    { name: "q9", formula: "*/ th th 1" },
    { name: "q10", formula: "+- q8 0 q9" },
    { name: "q11", formula: "sqrt q10" },
    { name: "idx", formula: "*/ q11 w q7" },
    { name: "maxAdj3", formula: "*/ 100000 idx ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "ah", formula: "*/ ss a3 100000" },
    { name: "q2", formula: "*/ w w 1" },
    { name: "q3", formula: "*/ ah ah 1" },
    { name: "q4", formula: "+- q2 0 q3" },
    { name: "q5", formula: "sqrt q4" },
    { name: "dy", formula: "*/ q5 hR w" },
    { name: "q6", formula: "+- aw 0 th" },
    { name: "dh", formula: "*/ q6 1 2" },
    { name: "aw2", formula: "*/ aw 1 2" },
    { name: "y6", formula: "+- b 0 aw2" },
    { name: "x1", formula: "+- l ah 0" },
    { name: "y3", formula: "+- hR th 0" },
    { name: "ix", formula: "+- l idx 0" },
    { name: "iy", formula: "+/ hR y3 2" },
  ]
  evaluate_guides(guides, local_ctx)
  let l = g(local_ctx, "l")
  let width = g(local_ctx, "w")
  let h_r = g(local_ctx, "hR")
  let dy = g(local_ctx, "dy")
  let dh = g(local_ctx, "dh")
  let _ah = g(local_ctx, "ah")
  let x1 = g(local_ctx, "x1") // = l + ah
  let y3 = g(local_ctx, "y3")
  let y6 = g(local_ctx, "y6")
  let ix = g(local_ctx, "ix") // l + idx — intersection x on the right side
  let iy = g(local_ctx, "iy")
  let inner_end_y = h_r + dy
  let outer_start_y = y3 + dy
  let notch_top_y = inner_end_y - dh
  let notch_bot_y = outer_start_y + dh
  // Inner arc on E1 (centre (l, hR)) from (x1, hR+dy) at angle
  //   atan2(dy/hR, ah/w)
  // CW (positive sweep) to (ix, iy) at angle
  //   atan2((iy-hR)/hR, (ix-l)/w) = atan2((th/2)/hR, idx/w).
  let st_inner = curved_arrow_atan2_units(dy, x1 - l, h_r, width)
  let en_inner = curved_arrow_atan2_units(iy - h_r, ix - l, h_r, width)
  let sw_inner = en_inner - st_inner
  // Outer arc on E2 (centre (l, y3)) from (ix, iy) at angle
  //   atan2(-(th/2)/hR, idx/w)  (since iy < y3 by th/2)
  // CCW (negative sweep) to (x1, y3+dy) at angle atan2(dy/hR, ah/w).
  let st_outer = curved_arrow_atan2_units(iy - y3, ix - l, h_r, width)
  let en_outer = curved_arrow_atan2_units(dy, x1 - l, h_r, width)
  let sw_outer = en_outer - st_outer
  // Reference path order: tip → top notch → inner band-end → inner arc →
  // (ix, iy) → outer arc → outer band-end → bottom notch → close.
  build_arrow_path([
    MoveTo(l, y6),
    LineTo(x1, notch_top_y),
    LineTo(x1, inner_end_y),
    ArcTo(width, h_r, st_inner, sw_inner),
    ArcTo(width, h_r, st_outer, sw_outer),
    LineTo(x1, notch_bot_y),
    Close,
  ])
}

///|
/// `curvedUpArrow` — body wraps around the BOTTOM-LEFT; arrowhead points
/// UP (tip at (x6, t)).  Ellipses E1/E2 have their major axes vertical
/// (rx = wR, ry = h) and are translated horizontally by `th`:
///
///   E1 (inner) — centre (x3, t) = (wR + th, t)
///   E2 (outer) — centre (wR, t)
///
/// The spec writes the main body with both arcs CONSECUTIVE (no arrowhead
/// in between), so the reference renderer traces inner-E1 from the
/// band-end through the (ix, iy) ellipse intersection, then outer-E2
/// back to the other band-end — a 90.64° sweep on E1 and a 60.4°
/// sweep on E2 at default adj.
fn arrow_curved_up_arrow(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local_ctx = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local_ctx["adj1"] = adj1
  local_ctx["adj2"] = adj2
  local_ctx["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 w ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw", formula: "*/ ss a2 100000" },
    { name: "q1", formula: "+/ th aw 4" },
    { name: "wR", formula: "+- wd2 0 q1" },
    { name: "q7", formula: "*/ wR 2 1" },
    { name: "q8", formula: "*/ q7 q7 1" },
    { name: "q9", formula: "*/ th th 1" },
    { name: "q10", formula: "+- q8 0 q9" },
    { name: "q11", formula: "sqrt q10" },
    { name: "idy", formula: "*/ q11 h q7" },
    { name: "maxAdj3", formula: "*/ 100000 idy ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "ah", formula: "*/ ss adj3 100000" },
    { name: "x3", formula: "+- wR th 0" },
    { name: "q2", formula: "*/ h h 1" },
    { name: "q3", formula: "*/ ah ah 1" },
    { name: "q4", formula: "+- q2 0 q3" },
    { name: "q5", formula: "sqrt q4" },
    { name: "dx", formula: "*/ q5 wR h" },
    { name: "q6", formula: "+- aw 0 th" },
    { name: "dh", formula: "*/ q6 1 2" },
    { name: "aw2", formula: "*/ aw 1 2" },
    { name: "x6", formula: "+- r 0 aw2" },
    { name: "y1", formula: "+- t ah 0" },
    { name: "ix", formula: "+/ wR x3 2" },
    { name: "iy", formula: "+- t idy 0" },
  ]
  evaluate_guides(guides, local_ctx)
  let t = g(local_ctx, "t")
  let w_r = g(local_ctx, "wR")
  let height = g(local_ctx, "h")
  let th = g(local_ctx, "th")
  let dx = g(local_ctx, "dx")
  let dh = g(local_ctx, "dh")
  let ah = g(local_ctx, "ah")
  let idy = g(local_ctx, "idy")
  let x3 = g(local_ctx, "x3")
  let x6 = g(local_ctx, "x6")
  let y1 = g(local_ctx, "y1")
  let ix = g(local_ctx, "ix")
  let iy = g(local_ctx, "iy")
  // Band-end x-coords at the arrowhead side (y = y1):
  //   inner edge on E1 ends at (x3 + dx, y1)
  //   outer edge on E2 starts at (wR + dx, y1)
  let inner_end_x = x3 + dx
  let outer_start_x = w_r + dx
  // Arrowhead notch positions (perpendicular to arrowhead axis):
  let notch_right_x = inner_end_x + dh
  let notch_left_x = outer_start_x - dh
  // Inner arc on E1 from (inner_end_x, y1) at angle atan2(ah/h, dx/wR)
  // CW (positive sweep in OOXML) to (ix, iy) at angle
  // atan2(idy/h, -(th/2)/wR) ≈ 105°.
  let st_inner = curved_arrow_atan2_units(ah, dx, height, w_r)
  let en_inner = curved_arrow_atan2_units(idy, ix - x3, height, w_r)
  let sw_inner = en_inner - st_inner
  // Outer arc on E2 from (ix, iy) at angle atan2(idy/h, +(th/2)/wR)
  // ≈ 75° CCW (negative sweep) to (outer_start_x, y1) at angle
  // atan2(ah/h, dx/wR) ≈ 14°.
  let st_outer = curved_arrow_atan2_units(idy, ix - w_r, height, w_r)
  let en_outer = curved_arrow_atan2_units(ah, dx, height, w_r)
  let sw_outer = en_outer - st_outer
  let _ = (iy, th) // captured for ellipse derivation; not used in path
  // Reference path order: tip → right notch → inner band-end → inner arc →
  // (ix, iy) → outer arc → outer band-end → left notch → close.
  build_arrow_path([
    MoveTo(x6, t),
    LineTo(notch_right_x, y1),
    LineTo(inner_end_x, y1),
    ArcTo(w_r, height, st_inner, sw_inner),
    ArcTo(w_r, height, st_outer, sw_outer),
    LineTo(notch_left_x, y1),
    Close,
  ])
}

///|
/// `curvedDownArrow` — vertical flip of `curvedUpArrow`.  Body wraps around
/// the TOP; arrowhead points DOWN (tip at (x6, b)).  Note the inner/outer
/// roles are SWAPPED relative to Up because the flip exchanges which side
/// of the band-axis the arrowhead notch lands on:
///
///   E1 (inner) — centre (wR, b)
///   E2 (outer) — centre (x3, b) = (wR + th, b)
///
/// The spec's main body uses TWO arcs SEPARATED by `lnTo (x3, t)` — the
/// top-flat connector across the th gap between the two ellipses.
fn arrow_curved_down_arrow(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local_ctx = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local_ctx["adj1"] = adj1
  local_ctx["adj2"] = adj2
  local_ctx["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 w ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw", formula: "*/ ss a2 100000" },
    { name: "q1", formula: "+/ th aw 4" },
    { name: "wR", formula: "+- wd2 0 q1" },
    { name: "q7", formula: "*/ wR 2 1" },
    { name: "q8", formula: "*/ q7 q7 1" },
    { name: "q9", formula: "*/ th th 1" },
    { name: "q10", formula: "+- q8 0 q9" },
    { name: "q11", formula: "sqrt q10" },
    { name: "idy", formula: "*/ q11 h q7" },
    { name: "maxAdj3", formula: "*/ 100000 idy ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "ah", formula: "*/ ss adj3 100000" },
    { name: "x3", formula: "+- wR th 0" },
    { name: "q2", formula: "*/ h h 1" },
    { name: "q3", formula: "*/ ah ah 1" },
    { name: "q4", formula: "+- q2 0 q3" },
    { name: "q5", formula: "sqrt q4" },
    { name: "dx", formula: "*/ q5 wR h" },
    { name: "q6", formula: "+- aw 0 th" },
    { name: "dh", formula: "*/ q6 1 2" },
    { name: "aw2", formula: "*/ aw 1 2" },
    { name: "x6", formula: "+- r 0 aw2" },
    { name: "y1", formula: "+- b 0 ah" },
  ]
  evaluate_guides(guides, local_ctx)
  let t = g(local_ctx, "t")
  let b = g(local_ctx, "b")
  let w_r = g(local_ctx, "wR")
  let height = g(local_ctx, "h")
  let dx = g(local_ctx, "dx")
  let dh = g(local_ctx, "dh")
  let ah = g(local_ctx, "ah")
  let x3 = g(local_ctx, "x3")
  let x6 = g(local_ctx, "x6")
  let y1 = g(local_ctx, "y1") // = b - ah; arrowhead notch y
  // Band-end x-coords at the arrowhead side (y = y1):
  //   inner edge on E1 (centre (wR, b)): point at (wR + dx, y1)
  //   outer edge on E2 (centre (x3, b)): point at (x3 + dx, y1)
  let inner_end_x = w_r + dx
  let outer_end_x = x3 + dx
  let notch_left_x = inner_end_x - dh
  let notch_right_x = outer_end_x + dh
  // Inner arc on E1 from (inner_end_x, y1) at angle
  //   atan2((y1-b)/h, dx/wR) ≈ -14.48° (Q4)
  // CCW (decreasing angle, OOXML-negative sweep) to (wR, t) at angle -90°.
  let st_inner = curved_arrow_atan2_units(y1 - b, dx, height, w_r)
  let en_inner = curved_arrow_rad_to_units(-3.141592653589793 / 2.0)
  let sw_inner = en_inner - st_inner
  // Outer arc on E2 from (x3, t) at -90° CW (positive sweep) to
  // (outer_end_x, y1) at angle atan2((y1-b)/h, dx/wR) ≈ -14.48°.
  let st_outer = curved_arrow_rad_to_units(-3.141592653589793 / 2.0)
  let en_outer = curved_arrow_atan2_units(y1 - b, dx, height, w_r)
  let sw_outer = en_outer - st_outer
  let _ = ah // captured for completeness; used implicitly via y1 = b-ah
  // Reference path order: tip → left notch → inner band-end → inner arc on E1 →
  // (wR, t) → connector → (x3, t) → outer arc on E2 → outer band-end →
  // right notch → close (back to tip).
  build_arrow_path([
    MoveTo(x6, b),
    LineTo(notch_left_x, y1),
    LineTo(inner_end_x, y1),
    ArcTo(w_r, height, st_inner, sw_inner),
    LineTo(x3, t),
    ArcTo(w_r, height, st_outer, sw_outer),
    LineTo(notch_right_x, y1),
    Close,
  ])
}

// ============================================================================
// Curved-arrow layered builders — main body + darkenLess overlay
//
// The dark overlay is the BACK-half of the 3-D ribbon — the part of the
// underlying cylinder cap that's "behind" the front-ribbon body.  It
// traces the upper-halves of E1 and E2 (the two ellipses defining the
// ribbon edges), connected at the (ix, iy) intersection of the two.
//
// For each direction the overlay structure is:
//   Move to one band-edge endpoint  (where the dark overlay begins)
//   Arc on E2 (outer) sweeping over the "back" of the ellipse to (ix, iy)
//   Arc on E1 (inner) sweeping from (ix, iy) over the "back" to the other
//     band-edge endpoint
//   Line closing back to start.
// ============================================================================

///|
/// `curvedRightArrow` dark overlay traces the BACK (upper) half of the
/// 3-D ribbon: from (r, th) over the top of E2 to (ix, iy), then from
/// (ix, iy) through (l, hR) and around the top of E1 to (r, 0), then
/// a line back to (r, th) closes it.
fn curved_right_arrow_layers(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> Array[PresetLayer] {
  let local_ctx = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local_ctx["adj1"] = adj1
  local_ctx["adj2"] = adj2
  local_ctx["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 h ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "a1", formula: "pin 0 adj1 a2" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw", formula: "*/ ss a2 100000" },
    { name: "q1", formula: "+/ th aw 4" },
    { name: "hR", formula: "+- hd2 0 q1" },
    { name: "q7", formula: "*/ hR 2 1" },
    { name: "q8", formula: "*/ q7 q7 1" },
    { name: "q9", formula: "*/ th th 1" },
    { name: "q10", formula: "+- q8 0 q9" },
    { name: "q11", formula: "sqrt q10" },
    { name: "idx", formula: "*/ q11 w q7" },
    { name: "ix", formula: "+- r 0 idx" },
    { name: "y3", formula: "+- hR th 0" },
    { name: "iy", formula: "+/ hR y3 2" },
  ]
  evaluate_guides(guides, local_ctx)
  let r = g(local_ctx, "r")
  let width = g(local_ctx, "w")
  let h_r = g(local_ctx, "hR")
  let th = g(local_ctx, "th")
  let ix = g(local_ctx, "ix")
  let iy = g(local_ctx, "iy")
  let y3 = g(local_ctx, "y3")
  let three_cd4 = g(local_ctx, "3cd4")
  let cd2 = g(local_ctx, "cd2")
  let cd4 = g(local_ctx, "cd4")
  // Arc 1 (on E2, centre (w, y3)): start (r, th) at angle 3cd4 (= 270°),
  // sweep CCW (negative sweep) to (ix, iy).
  // (iy - y3) = -th/2, (ix - r) = ix - w = -idx ⇒ atan2 gives Q3 angle
  // ≈ -156.4°; we WANT sweep equivalent to -66.4° (short way).
  let en_e2 = curved_arrow_atan2_units(iy - y3, ix - r, h_r, width)
  let sw_e2 = curved_arrow_normalise_sweep(en_e2 - three_cd4)
  // Arc 2 (on E1, centre (w, hR)): one big arc from (ix, iy) at angle
  // ≈ 156.4° (Q2) sweeping CW through (l, hR) at 180° and (r, 0) at
  // 270° (= -90°).  We trace this as a single ~113.6° CW sweep.
  let dang_e1 = curved_arrow_atan2_units(iy - h_r, ix - r, h_r, width)
  let st_e1 = dang_e1
  // End angle on E1 = -90° (going CW); sweep = -90 - 156.4 = -246.4° which
  // normalises to +113.6° (the short CW way).
  let sw_e1 = curved_arrow_normalise_sweep(-90.0 * 60000.0 - dang_e1)
  let _ = (cd2, cd4) // resolved via guide engine
  let dark = build_arrow_path([
    MoveTo(r, th),
    ArcTo(width, h_r, three_cd4, sw_e2),
    ArcTo(width, h_r, st_e1, sw_e1),
    LineTo(r, th),
    Close,
  ])
  [
    { path: arrow_curved_right_arrow(_w, _h, ctx), fill_mod: 0.0 },
    { path: dark, fill_mod: -0.20 },
  ]
}

///|
/// `curvedLeftArrow` dark overlay — implements the literal spec path.
/// Two 90° arcs connected by vertical lines at the right and left edges.
fn curved_left_arrow_layers(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> Array[PresetLayer] {
  let local_ctx = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local_ctx["adj1"] = adj1
  local_ctx["adj2"] = adj2
  local_ctx["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 h ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "a1", formula: "pin 0 adj1 a2" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw", formula: "*/ ss a2 100000" },
    { name: "q1", formula: "+/ th aw 4" },
    { name: "hR", formula: "+- hd2 0 q1" },
    { name: "y3", formula: "+- hR th 0" },
  ]
  evaluate_guides(guides, local_ctx)
  let l = g(local_ctx, "l")
  let r = g(local_ctx, "r")
  let t = g(local_ctx, "t")
  let width = g(local_ctx, "w")
  let h_r = g(local_ctx, "hR")
  let y3 = g(local_ctx, "y3")
  let three_cd4 = g(local_ctx, "3cd4")
  let cd4 = g(local_ctx, "cd4")
  // Spec: M (r, y3)
  //       arcTo (w, hR, 0, -cd4)   — half-arc on E2 → (l, th)
  //       lnTo (l, t)
  //       arcTo (w, hR, 3cd4, cd4) — half-arc on E1 → (r, hR)
  //       close
  let dark = build_arrow_path([
    MoveTo(r, y3),
    ArcTo(width, h_r, 0.0, -cd4),
    LineTo(l, t),
    ArcTo(width, h_r, three_cd4, cd4),
    Close,
  ])
  [
    { path: arrow_curved_left_arrow(_w, _h, ctx), fill_mod: 0.0 },
    { path: dark, fill_mod: -0.20 },
  ]
}

///|
/// `curvedUpArrow` dark overlay — implements the literal spec path which
/// already matches the reference renderer for Up arrow.  Two 90° arcs joined by horizontal
/// connectors at top and bottom.
fn curved_up_arrow_layers(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> Array[PresetLayer] {
  let local_ctx = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local_ctx["adj1"] = adj1
  local_ctx["adj2"] = adj2
  local_ctx["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 w ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw", formula: "*/ ss a2 100000" },
    { name: "q1", formula: "+/ th aw 4" },
    { name: "wR", formula: "+- wd2 0 q1" },
  ]
  evaluate_guides(guides, local_ctx)
  let t = g(local_ctx, "t")
  let b = g(local_ctx, "b")
  let w_r = g(local_ctx, "wR")
  let height = g(local_ctx, "h")
  let th = g(local_ctx, "th")
  let cd4 = g(local_ctx, "cd4")
  let cd2 = g(local_ctx, "cd2")
  // Spec: M (wR, b)
  //       arcTo (wR, h, cd4, cd4)   — 90° arc on E2 → (l, t)
  //       lnTo (th, t)
  //       arcTo (wR, h, cd2, -cd4)  — -90° arc on E1 → (x3, b)
  //       close
  let dark = build_arrow_path([
    MoveTo(w_r, b),
    ArcTo(w_r, height, cd4, cd4),
    LineTo(th, t),
    ArcTo(w_r, height, cd2, -cd4),
    Close,
  ])
  [
    { path: arrow_curved_up_arrow(_w, _h, ctx), fill_mod: 0.0 },
    { path: dark, fill_mod: -0.20 },
  ]
}

///|
/// `curvedDownArrow` dark overlay — the BACK-half of the 3-D ribbon.  The
/// spec literally writes:
///
///   M (ix, iy)
///   arcTo wR=wR hR=h stAng=stAng2 swAng=swAng2   — non-axis-aligned!
///   lnTo (l, b)
///   arcTo wR=wR hR=h stAng=cd2  swAng=swAng3    — axis-aligned
///   close
///
/// where `stAng2 = 3cd4 - dang2`, `dang2 = at2 idy q12`, `q12 = th/2`.
/// The non-axis-aligned `stAng2` is a CARTESIAN polar angle (the angle
/// from +x to the vector `(ix-x3, iy-b)`), NOT a parametric/eccentric
/// angle — but our `build_arrow_path` interprets `ArcTo`'s `stAng` as
/// parametric.  Passing the spec angle directly yields the wrong implied
/// centre `(2505, 3916)` instead of E2's centre `(x3=2749, b=3812)`,
/// stretching the arc endpoint by ~9 % of `th` away from `(th, b)`.
///
/// Fix: derive both arc start/end angles directly as PARAMETRIC angles
/// on their respective ellipses, matching the body code's pattern:
///   - Arc 1 on E2 (centre (x3, b), radii (wR, h)) from (ix, iy) to
///     (th, b).  Parametric start = atan2((iy-b)/h, (ix-x3)/wR); end =
///     cd2 (axis-aligned (th, b) = (x3-wR, b)).  Sweep is short-way CW.
///   - Arc 2 on E1 (centre (wR, b), radii (wR, h)) from (l, b) to
///     (ix, iy).  Parametric start = cd2 (axis-aligned); end =
///     atan2((iy-b)/h, (ix-wR)/wR).  Sweep is short-way CCW.
fn curved_down_arrow_layers(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> Array[PresetLayer] {
  let local_ctx = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local_ctx["adj1"] = adj1
  local_ctx["adj2"] = adj2
  local_ctx["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 w ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw", formula: "*/ ss a2 100000" },
    { name: "q1", formula: "+/ th aw 4" },
    { name: "wR", formula: "+- wd2 0 q1" },
    { name: "q7", formula: "*/ wR 2 1" },
    { name: "q8", formula: "*/ q7 q7 1" },
    { name: "q9", formula: "*/ th th 1" },
    { name: "q10", formula: "+- q8 0 q9" },
    { name: "q11", formula: "sqrt q10" },
    { name: "idy", formula: "*/ q11 h q7" },
    { name: "x3", formula: "+- wR th 0" },
    { name: "ix", formula: "+/ wR x3 2" },
    { name: "iy", formula: "+- b 0 idy" },
  ]
  evaluate_guides(guides, local_ctx)
  let l = g(local_ctx, "l")
  let b = g(local_ctx, "b")
  let w_r = g(local_ctx, "wR")
  let height = g(local_ctx, "h")
  let x3 = g(local_ctx, "x3")
  let ix = g(local_ctx, "ix")
  let iy = g(local_ctx, "iy")
  let cd2 = g(local_ctx, "cd2")
  // Arc 1 on E2 (centre (x3, b), radii (wR, h)): start at (ix, iy)
  // (parametric ≈ -105.4°), end at (th, b) which is the axis-aligned
  // 180° point on E2.  Short-way sweep is CW (negative in OOXML units
  // because (ix, iy) sits above-right of the leftmost point).
  let st_e2 = curved_arrow_atan2_units(iy - b, ix - x3, height, w_r)
  let sw_e2 = curved_arrow_normalise_sweep(cd2 - st_e2)
  // Arc 2 on E1 (centre (wR, b), radii (wR, h)): start at (l, b)
  // (axis-aligned cd2 = 180°), end at (ix, iy) (parametric ≈ -74.6° or
  // equivalently 285.4°).  Short-way sweep is CCW (positive).
  let en_e1 = curved_arrow_atan2_units(iy - b, ix - w_r, height, w_r)
  let sw_e1 = curved_arrow_normalise_sweep(en_e1 - cd2)
  let dark = build_arrow_path([
    MoveTo(ix, iy),
    ArcTo(w_r, height, st_e2, sw_e2),
    LineTo(l, b),
    ArcTo(w_r, height, cd2, sw_e1),
    Close,
  ])
  [
    { path: arrow_curved_down_arrow(_w, _h, ctx), fill_mod: 0.0 },
    { path: dark, fill_mod: -0.20 },
  ]
}
