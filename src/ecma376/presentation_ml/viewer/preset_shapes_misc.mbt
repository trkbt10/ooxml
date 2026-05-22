// Preset miscellaneous shapes.  Faithful 1-to-1 port of the
// `PRESET_SHAPES[...]` entries in `web-pptx/packages/@aurochs-renderer/
// drawing-ml/src/svg/geometry/preset-shapes.ts`.
//
// Owned presets (77):
//   lineInv,
//   round1Rect, round2SameRect, round2DiagRect,
//   snipRoundRect, snip1Rect, snip2SameRect, snip2DiagRect,
//   nonIsoscelesTrapezoid, heptagon, decagon, dodecagon,
//   teardrop, plaque,
//   straightConnector1, bentConnector2..bentConnector5,
//   curvedConnector2..curvedConnector5,
//   cloud, leftBrace, rightBrace, leftBracket, rightBracket,
//   arc, pie, donut, sun, smileyFace,
//   ribbon, ribbon2, ellipseRibbon, ellipseRibbon2, leftRightRibbon,
//   wave, doubleWave, pieWedge, blockArc, noSmoking, cube, can,
//   lightningBolt, heart, moon, irregularSeal1, irregularSeal2,
//   foldedCorner, bevel, frame, halfFrame, corner, diagStripe, chord,
//   verticalScroll, horizontalScroll, gear6, gear9, funnel,
//   mathPlus, mathMinus, mathMultiply, mathDivide, mathEqual,
//   mathNotEqual,
//   cornerTabs, squareTabs, plaqueTabs,
//   chartX, chartStar, chartPlus, bracketPair, bracePair.

///|
/// Shorthand pi.  Defined locally so the helper inline-trig functions
/// here remain self-contained.
let misc_pi : Double = 3.141592653589793

///|
/// `Math.abs` equivalent for `Double`.
fn misc_abs(x : Double) -> Double {
  if x < 0.0 {
    -x
  } else {
    x
  }
}

///|
/// `Math.min` for `Double`.
fn misc_min(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// `cos` in radians.
fn misc_cos(x : Double) -> Double {
  @math.cos(x)
}

///|
/// `sin` in radians.
fn misc_sin(x : Double) -> Double {
  @math.sin(x)
}

///|
/// Build a path-data string from a sequence of pieces.
fn misc_join(parts : Array[String]) -> String {
  let buf = StringBuilder::new()
  for p in parts {
    buf.write_string(p)
  }
  buf.to_string()
}

// ============================================================================
// lineInv — preset-shapes.ts:2851
// ============================================================================

///|
fn misc_line_inv(w : Double, h : Double) -> String {
  "M 0 " + fmt(h) + " L " + fmt(w) + " 0"
}

// ============================================================================
// round1Rect — preset-shapes.ts:2858
// ============================================================================

///|
fn misc_round1_rect(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj_val = ctx.get("adj").unwrap_or(16667.0)
  let pct = if adj_val > 50000.0 { 50000.0 } else { adj_val }
  let ss = misc_min(w, h)
  let r = pct / 100000.0 * ss
  "M 0 0 L " +
  fmt(w - r) +
  " 0 Q " +
  fmt(w) +
  " 0 " +
  fmt(w) +
  " " +
  fmt(r) +
  " L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

// ============================================================================
// round2SameRect — preset-shapes.ts:2868
// ============================================================================

///|
fn misc_round2_same_rect(w : Double, h : Double, ctx : GuideContext) -> String {
  let a1 = ctx.get("adj1").unwrap_or(16667.0)
  let a2 = ctx.get("adj2").unwrap_or(0.0)
  let p1 = if a1 > 50000.0 { 50000.0 } else { a1 }
  let p2 = if a2 > 50000.0 { 50000.0 } else { a2 }
  let ss = misc_min(w, h)
  let r1 = p1 / 100000.0 * ss
  let r2 = p2 / 100000.0 * ss
  "M " +
  fmt(r1) +
  " 0 L " +
  fmt(w - r1) +
  " 0 Q " +
  fmt(w) +
  " 0 " +
  fmt(w) +
  " " +
  fmt(r1) +
  " L " +
  fmt(w) +
  " " +
  fmt(h - r2) +
  " Q " +
  fmt(w) +
  " " +
  fmt(h) +
  " " +
  fmt(w - r2) +
  " " +
  fmt(h) +
  " L " +
  fmt(r2) +
  " " +
  fmt(h) +
  " Q 0 " +
  fmt(h) +
  " 0 " +
  fmt(h - r2) +
  " L 0 " +
  fmt(r1) +
  " Q 0 0 " +
  fmt(r1) +
  " 0 Z"
}

// ============================================================================
// round2DiagRect — preset-shapes.ts:2879
// ============================================================================

///|
fn misc_round2_diag_rect(w : Double, h : Double, ctx : GuideContext) -> String {
  let a1 = ctx.get("adj1").unwrap_or(16667.0)
  let a2 = ctx.get("adj2").unwrap_or(0.0)
  let p1 = if a1 > 50000.0 { 50000.0 } else { a1 }
  let p2 = if a2 > 50000.0 { 50000.0 } else { a2 }
  let ss = misc_min(w, h)
  let r1 = p1 / 100000.0 * ss
  let r2 = p2 / 100000.0 * ss
  "M 0 0 L " +
  fmt(w - r1) +
  " 0 Q " +
  fmt(w) +
  " 0 " +
  fmt(w) +
  " " +
  fmt(r1) +
  " L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L " +
  fmt(r2) +
  " " +
  fmt(h) +
  " Q 0 " +
  fmt(h) +
  " 0 " +
  fmt(h - r2) +
  " L 0 0 Z"
}

// ============================================================================
// snipRoundRect — preset-shapes.ts:2890
// ============================================================================

///|
fn misc_snip_round_rect(w : Double, h : Double, ctx : GuideContext) -> String {
  let a1 = ctx.get("adj1").unwrap_or(16667.0)
  let a2 = ctx.get("adj2").unwrap_or(16667.0)
  let p1 = if a1 > 50000.0 { 50000.0 } else { a1 }
  let p2 = if a2 > 50000.0 { 50000.0 } else { a2 }
  let ss = misc_min(w, h)
  let snip = p1 / 100000.0 * ss
  let r = p2 / 100000.0 * ss
  "M 0 0 L " +
  fmt(w - snip) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(snip) +
  " L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L " +
  fmt(r) +
  " " +
  fmt(h) +
  " Q 0 " +
  fmt(h) +
  " 0 " +
  fmt(h - r) +
  " L 0 0 Z"
}

// ============================================================================
// snip1Rect — preset-shapes.ts:2901
// ============================================================================

///|
fn misc_snip1_rect(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj_val = ctx.get("adj").unwrap_or(16667.0)
  let pct = if adj_val > 50000.0 { 50000.0 } else { adj_val }
  let ss = misc_min(w, h)
  let snip = pct / 100000.0 * ss
  "M 0 0 L " +
  fmt(w - snip) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(snip) +
  " L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

// ============================================================================
// snip2SameRect — preset-shapes.ts:2911
// ============================================================================

///|
fn misc_snip2_same_rect(w : Double, h : Double, ctx : GuideContext) -> String {
  let a1 = ctx.get("adj1").unwrap_or(16667.0)
  let a2 = ctx.get("adj2").unwrap_or(0.0)
  let p1 = if a1 > 50000.0 { 50000.0 } else { a1 }
  let p2 = if a2 > 50000.0 { 50000.0 } else { a2 }
  let ss = misc_min(w, h)
  let s1 = p1 / 100000.0 * ss
  let s2 = p2 / 100000.0 * ss
  "M " +
  fmt(s1) +
  " 0 L " +
  fmt(w - s1) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(s1) +
  " L " +
  fmt(w) +
  " " +
  fmt(h - s2) +
  " L " +
  fmt(w - s2) +
  " " +
  fmt(h) +
  " L " +
  fmt(s2) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h - s2) +
  " L 0 " +
  fmt(s1) +
  " Z"
}

// ============================================================================
// snip2DiagRect — preset-shapes.ts:2922
// ============================================================================

///|
fn misc_snip2_diag_rect(w : Double, h : Double, ctx : GuideContext) -> String {
  let a1 = ctx.get("adj1").unwrap_or(16667.0)
  let a2 = ctx.get("adj2").unwrap_or(0.0)
  let p1 = if a1 > 50000.0 { 50000.0 } else { a1 }
  let p2 = if a2 > 50000.0 { 50000.0 } else { a2 }
  let ss = misc_min(w, h)
  let s1 = p1 / 100000.0 * ss
  let s2 = p2 / 100000.0 * ss
  "M 0 0 L " +
  fmt(w - s1) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(s1) +
  " L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L " +
  fmt(s2) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h - s2) +
  " Z"
}

// ============================================================================
// nonIsoscelesTrapezoid — preset-shapes.ts:2933
// ============================================================================

///|
fn misc_non_isosceles_trapezoid(
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String {
  let a1 = ctx.get("adj1").unwrap_or(25000.0)
  let a2 = ctx.get("adj2").unwrap_or(25000.0)
  let left_offset = a1 / 100000.0 * w
  let right_offset = a2 / 100000.0 * w
  "M " +
  fmt(left_offset) +
  " 0 L " +
  fmt(w - right_offset) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

// ============================================================================
// heptagon / decagon / dodecagon — preset-shapes.ts:2944, 2963, 2982
// ============================================================================

///|
/// Regular N-gon inscribed in the bounding box.
fn misc_regular_polygon(w : Double, h : Double, n : Int) -> String {
  let cx = w / 2.0
  let cy = h / 2.0
  let r = misc_min(w, h) / 2.0
  let buf = StringBuilder::new()
  for i in 0..<n {
    let angle = (i.to_double() * 360.0 / n.to_double() - 90.0) * misc_pi / 180.0
    let x = cx + r * misc_cos(angle)
    let y = cy + r * misc_sin(angle)
    if i == 0 {
      buf.write_string("M " + fmt(x) + " " + fmt(y))
    } else {
      buf.write_string(" L " + fmt(x) + " " + fmt(y))
    }
  }
  buf.write_string(" Z")
  buf.to_string()
}

// ============================================================================
// teardrop — preset-shapes.ts:3001
// ============================================================================

///|
fn misc_teardrop(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj_val = ctx.get("adj").unwrap_or(100000.0) / 100000.0
  let rx = w / 2.0
  let ry = h / 2.0
  let cx = rx
  let cy = ry
  let point_x = cx + rx * adj_val
  let point_y = cy - ry * adj_val
  "M " +
  fmt(cx) +
  " 0 Q " +
  fmt(point_x) +
  " 0 " +
  fmt(point_x) +
  " " +
  fmt(point_y) +
  " Q " +
  fmt(w) +
  " 0 " +
  fmt(w) +
  " " +
  fmt(cy) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(cx) +
  " 0 Z"
}

// ============================================================================
// plaque — preset-shapes.ts:3018
// ============================================================================

///|
fn misc_plaque(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj_val = ctx.get("adj").unwrap_or(16667.0)
  let pct = if adj_val > 50000.0 { 50000.0 } else { adj_val }
  let ss = misc_min(w, h)
  let r = pct / 100000.0 * ss
  "M " +
  fmt(r) +
  " 0 L " +
  fmt(w - r) +
  " 0 Q " +
  fmt(w) +
  " " +
  fmt(r) +
  " " +
  fmt(w) +
  " " +
  fmt(r) +
  " L " +
  fmt(w) +
  " " +
  fmt(h - r) +
  " Q " +
  fmt(w - r) +
  " " +
  fmt(h) +
  " " +
  fmt(w - r) +
  " " +
  fmt(h) +
  " L " +
  fmt(r) +
  " " +
  fmt(h) +
  " Q 0 " +
  fmt(h - r) +
  " 0 " +
  fmt(h - r) +
  " L 0 " +
  fmt(r) +
  " Q " +
  fmt(r) +
  " 0 " +
  fmt(r) +
  " 0 Z"
}

// ============================================================================
// straightConnector1 — preset-shapes.ts:3033
// ============================================================================

///|
fn misc_straight_connector1(w : Double, h : Double) -> String {
  "M 0 0 L " + fmt(w) + " " + fmt(h)
}

// ============================================================================
// bentConnector2..bentConnector5 — preset-shapes.ts:3040, 3047, 3057, 3068
// ============================================================================

///|
fn misc_bent_connector2(w : Double, h : Double) -> String {
  "M 0 0 L " + fmt(w) + " 0 L " + fmt(w) + " " + fmt(h)
}

///|
fn misc_bent_connector3(w : Double, h : Double, ctx : GuideContext) -> String {
  let mid_x = w * (ctx.get("adj1").unwrap_or(50000.0) / 100000.0)
  "M 0 0 L " +
  fmt(mid_x) +
  " 0 L " +
  fmt(mid_x) +
  " " +
  fmt(h) +
  " L " +
  fmt(w) +
  " " +
  fmt(h)
}

///|
fn misc_bent_connector4(w : Double, h : Double, ctx : GuideContext) -> String {
  let mid_x = w * (ctx.get("adj1").unwrap_or(50000.0) / 100000.0)
  let mid_y = h * (ctx.get("adj2").unwrap_or(50000.0) / 100000.0)
  "M 0 0 L " +
  fmt(mid_x) +
  " 0 L " +
  fmt(mid_x) +
  " " +
  fmt(mid_y) +
  " L " +
  fmt(w) +
  " " +
  fmt(mid_y) +
  " L " +
  fmt(w) +
  " " +
  fmt(h)
}

///|
fn misc_bent_connector5(w : Double, h : Double, ctx : GuideContext) -> String {
  let x1 = w * (ctx.get("adj1").unwrap_or(25000.0) / 100000.0)
  let y1 = h * (ctx.get("adj2").unwrap_or(50000.0) / 100000.0)
  let x2 = w * (ctx.get("adj3").unwrap_or(75000.0) / 100000.0)
  "M 0 0 L " +
  fmt(x1) +
  " 0 L " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x2) +
  " " +
  fmt(h) +
  " L " +
  fmt(w) +
  " " +
  fmt(h)
}

// ============================================================================
// curvedConnector2..curvedConnector5 — preset-shapes.ts:3080, 3087, 3097, 3108
// ============================================================================

///|
fn misc_curved_connector2(w : Double, h : Double) -> String {
  "M 0 0 Q " + fmt(w) + " 0 " + fmt(w) + " " + fmt(h)
}

///|
fn misc_curved_connector3(w : Double, h : Double, ctx : GuideContext) -> String {
  let mid_x = w * (ctx.get("adj1").unwrap_or(50000.0) / 100000.0)
  "M 0 0 Q " +
  fmt(mid_x) +
  " 0 " +
  fmt(mid_x) +
  " " +
  fmt(h / 2.0) +
  " Q " +
  fmt(mid_x) +
  " " +
  fmt(h) +
  " " +
  fmt(w) +
  " " +
  fmt(h)
}

///|
fn misc_curved_connector4(w : Double, h : Double, ctx : GuideContext) -> String {
  let mid_x = w * (ctx.get("adj1").unwrap_or(50000.0) / 100000.0)
  let mid_y = h * (ctx.get("adj2").unwrap_or(50000.0) / 100000.0)
  "M 0 0 C " +
  fmt(mid_x) +
  " 0 " +
  fmt(mid_x) +
  " " +
  fmt(mid_y) +
  " " +
  fmt(w / 2.0) +
  " " +
  fmt(mid_y) +
  " C " +
  fmt(w - mid_x) +
  " " +
  fmt(mid_y) +
  " " +
  fmt(w - mid_x) +
  " " +
  fmt(h) +
  " " +
  fmt(w) +
  " " +
  fmt(h)
}

///|
fn misc_curved_connector5(w : Double, h : Double, ctx : GuideContext) -> String {
  let x1 = w * (ctx.get("adj1").unwrap_or(25000.0) / 100000.0)
  let y1 = h * (ctx.get("adj2").unwrap_or(50000.0) / 100000.0)
  let x2 = w * (ctx.get("adj3").unwrap_or(75000.0) / 100000.0)
  let half_y1 = y1 / 2.0
  let mid_seg = y1 + (h - y1) / 2.0
  "M 0 0 C " +
  fmt(x1) +
  " 0 " +
  fmt(x1) +
  " " +
  fmt(half_y1) +
  " " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " C " +
  fmt(x1) +
  " " +
  fmt(mid_seg) +
  " " +
  fmt(x2) +
  " " +
  fmt(mid_seg) +
  " " +
  fmt(x2) +
  " " +
  fmt(h) +
  " L " +
  fmt(w) +
  " " +
  fmt(h)
}

// ============================================================================
// cloud — preset-shapes.ts:3478
// ============================================================================

///|
/// Internal helper: build the cloud body scaled to a cloud "canvas"
/// `(cw, ch)` — used by both `cloud` and `cloudCallout` (callout
/// implementation lives in `preset_shapes_callout.mbt`).
fn misc_cloud_body(cw : Double, ch : Double) -> String {
  // Cubic-bezier construction copied 1:1 from preset-shapes.ts:3481.
  "M " +
  fmt(cw * 0.15) +
  " " +
  fmt(ch * 0.6) +
  " C " +
  fmt(cw * -0.05) +
  " " +
  fmt(ch * 0.6) +
  " " +
  fmt(cw * -0.05) +
  " " +
  fmt(ch * 0.25) +
  " " +
  fmt(cw * 0.15) +
  " " +
  fmt(ch * 0.25) +
  " C " +
  fmt(cw * 0.1) +
  " " +
  fmt(ch * 0.05) +
  " " +
  fmt(cw * 0.3) +
  " " +
  fmt(ch * -0.05) +
  " " +
  fmt(cw * 0.4) +
  " " +
  fmt(ch * 0.15) +
  " C " +
  fmt(cw * 0.45) +
  " " +
  fmt(ch * -0.05) +
  " " +
  fmt(cw * 0.65) +
  " " +
  fmt(ch * -0.05) +
  " " +
  fmt(cw * 0.7) +
  " " +
  fmt(ch * 0.15) +
  " C " +
  fmt(cw * 0.85) +
  " " +
  fmt(ch * 0.0) +
  " " +
  fmt(cw * 1.1) +
  " " +
  fmt(ch * 0.2) +
  " " +
  fmt(cw * 0.9) +
  " " +
  fmt(ch * 0.45) +
  " C " +
  fmt(cw * 1.1) +
  " " +
  fmt(ch * 0.55) +
  " " +
  fmt(cw * 1.05) +
  " " +
  fmt(ch * 0.85) +
  " " +
  fmt(cw * 0.8) +
  " " +
  fmt(ch * 0.8) +
  " C " +
  fmt(cw * 0.8) +
  " " +
  fmt(ch * 1.0) +
  " " +
  fmt(cw * 0.55) +
  " " +
  fmt(ch * 1.05) +
  " " +
  fmt(cw * 0.45) +
  " " +
  fmt(ch * 0.85) +
  " C " +
  fmt(cw * 0.3) +
  " " +
  fmt(ch * 1.0) +
  " " +
  fmt(cw * 0.1) +
  " " +
  fmt(ch * 0.95) +
  " " +
  fmt(cw * 0.15) +
  " " +
  fmt(ch * 0.6) +
  " Z"
}

///|
fn misc_cloud(w : Double, h : Double) -> String {
  misc_cloud_body(w, h)
}

// ============================================================================
// leftBrace / rightBrace — preset-shapes.ts:3828, 3839
// ============================================================================

///|
fn misc_left_brace(w : Double, h : Double, ctx : GuideContext) -> String {
  let depth = w * (ctx.get("adj1").unwrap_or(8333.0) / 100000.0)
  let mid_y = h * (ctx.get("adj2").unwrap_or(50000.0) / 100000.0)
  "M " +
  fmt(w) +
  " 0 Q " +
  fmt(w - depth) +
  " 0 " +
  fmt(w - depth) +
  " " +
  fmt(depth) +
  " L " +
  fmt(w - depth) +
  " " +
  fmt(mid_y - depth) +
  " Q " +
  fmt(w - depth) +
  " " +
  fmt(mid_y) +
  " " +
  fmt(w - depth * 2.0) +
  " " +
  fmt(mid_y) +
  " Q " +
  fmt(w - depth) +
  " " +
  fmt(mid_y) +
  " " +
  fmt(w - depth) +
  " " +
  fmt(mid_y + depth) +
  " L " +
  fmt(w - depth) +
  " " +
  fmt(h - depth) +
  " Q " +
  fmt(w - depth) +
  " " +
  fmt(h) +
  " " +
  fmt(w) +
  " " +
  fmt(h)
}

///|
fn misc_right_brace(w : Double, h : Double, ctx : GuideContext) -> String {
  let depth = w * (ctx.get("adj1").unwrap_or(8333.0) / 100000.0)
  let mid_y = h * (ctx.get("adj2").unwrap_or(50000.0) / 100000.0)
  "M 0 0 Q " +
  fmt(depth) +
  " 0 " +
  fmt(depth) +
  " " +
  fmt(depth) +
  " L " +
  fmt(depth) +
  " " +
  fmt(mid_y - depth) +
  " Q " +
  fmt(depth) +
  " " +
  fmt(mid_y) +
  " " +
  fmt(depth * 2.0) +
  " " +
  fmt(mid_y) +
  " Q " +
  fmt(depth) +
  " " +
  fmt(mid_y) +
  " " +
  fmt(depth) +
  " " +
  fmt(mid_y + depth) +
  " L " +
  fmt(depth) +
  " " +
  fmt(h - depth) +
  " Q " +
  fmt(depth) +
  " " +
  fmt(h) +
  " 0 " +
  fmt(h)
}

// ============================================================================
// leftBracket / rightBracket — preset-shapes.ts:3850, 3860
// ============================================================================

///|
fn misc_left_bracket(w : Double, h : Double, ctx : GuideContext) -> String {
  let depth = w * (ctx.get("adj").unwrap_or(8333.0) / 100000.0)
  "M " +
  fmt(w) +
  " 0 L " +
  fmt(depth) +
  " 0 Q 0 0 0 " +
  fmt(depth) +
  " L 0 " +
  fmt(h - depth) +
  " Q 0 " +
  fmt(h) +
  " " +
  fmt(depth) +
  " " +
  fmt(h) +
  " L " +
  fmt(w) +
  " " +
  fmt(h)
}

///|
fn misc_right_bracket(w : Double, h : Double, ctx : GuideContext) -> String {
  let depth = w * (ctx.get("adj").unwrap_or(8333.0) / 100000.0)
  "M 0 0 L " +
  fmt(w - depth) +
  " 0 Q " +
  fmt(w) +
  " 0 " +
  fmt(w) +
  " " +
  fmt(depth) +
  " L " +
  fmt(w) +
  " " +
  fmt(h - depth) +
  " Q " +
  fmt(w) +
  " " +
  fmt(h) +
  " " +
  fmt(w - depth) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h)
}

// ============================================================================
// arc / pie / chord — preset-shapes.ts:3874, 3894, 4433
// ============================================================================

///|
fn misc_arc(w : Double, h : Double, ctx : GuideContext) -> String {
  let start_angle = ctx.get("adj1").unwrap_or(270.0 * 60000.0) /
    60000.0 *
    misc_pi /
    180.0
  let end_angle = ctx.get("adj2").unwrap_or(0.0) / 60000.0 * misc_pi / 180.0
  let rx = w / 2.0
  let ry = h / 2.0
  let cx = rx
  let cy = ry
  let x1 = cx + rx * misc_cos(start_angle)
  let y1 = cy + ry * misc_sin(start_angle)
  let x2 = cx + rx * misc_cos(end_angle)
  let y2 = cy + ry * misc_sin(end_angle)
  let large_arc = if misc_abs(end_angle - start_angle) > misc_pi {
    1
  } else {
    0
  }
  "M " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 " +
  large_arc.to_string() +
  " 1 " +
  fmt(x2) +
  " " +
  fmt(y2)
}

///|
fn misc_pie(w : Double, h : Double, ctx : GuideContext) -> String {
  let start_angle = ctx.get("adj1").unwrap_or(0.0) / 60000.0 * misc_pi / 180.0
  let end_angle = ctx.get("adj2").unwrap_or(270.0 * 60000.0) /
    60000.0 *
    misc_pi /
    180.0
  let rx = w / 2.0
  let ry = h / 2.0
  let cx = rx
  let cy = ry
  let x1 = cx + rx * misc_cos(start_angle)
  let y1 = cy + ry * misc_sin(start_angle)
  let x2 = cx + rx * misc_cos(end_angle)
  let y2 = cy + ry * misc_sin(end_angle)
  let sweep = end_angle - start_angle
  let large_arc = if misc_abs(sweep) > misc_pi { 1 } else { 0 }
  let sweep_dir = if sweep > 0.0 { 1 } else { 0 }
  "M " +
  fmt(cx) +
  " " +
  fmt(cy) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 " +
  large_arc.to_string() +
  " " +
  sweep_dir.to_string() +
  " " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " Z"
}

///|
fn misc_chord(w : Double, h : Double, ctx : GuideContext) -> String {
  let start_angle = ctx.get("adj1").unwrap_or(270.0 * 60000.0) /
    60000.0 *
    misc_pi /
    180.0
  let end_angle = ctx.get("adj2").unwrap_or(0.0) / 60000.0 * misc_pi / 180.0
  let rx = w / 2.0
  let ry = h / 2.0
  let cx = rx
  let cy = ry
  let x1 = cx + rx * misc_cos(start_angle)
  let y1 = cy + ry * misc_sin(start_angle)
  let x2 = cx + rx * misc_cos(end_angle)
  let y2 = cy + ry * misc_sin(end_angle)
  let sweep = end_angle - start_angle
  let large_arc = if misc_abs(sweep) > misc_pi { 1 } else { 0 }
  "M " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 " +
  large_arc.to_string() +
  " 1 " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " Z"
}

// ============================================================================
// donut — preset-shapes.ts:3916
// ============================================================================

///|
fn misc_donut(w : Double, h : Double, ctx : GuideContext) -> String {
  let hole_ratio = ctx.get("adj").unwrap_or(25000.0) / 100000.0
  let rx = w / 2.0
  let ry = h / 2.0
  let inner_rx = rx * hole_ratio
  let inner_ry = ry * hole_ratio
  "M " +
  fmt(rx) +
  " 0 A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(rx) +
  " " +
  fmt(h) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(rx) +
  " 0 Z " +
  "M " +
  fmt(rx) +
  " " +
  fmt(ry - inner_ry) +
  " A " +
  fmt(inner_rx) +
  " " +
  fmt(inner_ry) +
  " 0 1 0 " +
  fmt(rx) +
  " " +
  fmt(ry + inner_ry) +
  " A " +
  fmt(inner_rx) +
  " " +
  fmt(inner_ry) +
  " 0 1 0 " +
  fmt(rx) +
  " " +
  fmt(ry - inner_ry) +
  " Z"
}

// ============================================================================
// sun — preset-shapes.ts:3935
// ============================================================================

///|
fn misc_sun(w : Double, h : Double, ctx : GuideContext) -> String {
  let ray_length = misc_min(w, h) *
    (ctx.get("adj").unwrap_or(25000.0) / 100000.0)
  let cx = w / 2.0
  let cy = h / 2.0
  let outer_r = misc_min(w, h) / 2.0
  let inner_r = outer_r - ray_length
  let buf = StringBuilder::new()
  for i in 0..<16 {
    let angle = (i.to_double() * 22.5 - 90.0) * misc_pi / 180.0
    let r = if i % 2 == 0 { outer_r } else { inner_r }
    let x = cx + r * misc_cos(angle)
    let y = cy + r * misc_sin(angle)
    if i == 0 {
      buf.write_string("M " + fmt(x) + " " + fmt(y))
    } else {
      buf.write_string(" L " + fmt(x) + " " + fmt(y))
    }
  }
  buf.write_string(" Z")
  buf.to_string()
}

// ============================================================================
// smileyFace — preset-shapes.ts:3957
// ============================================================================

///|
fn misc_smiley_face(w : Double, h : Double) -> String {
  let cx = w / 2.0
  let cy = h / 2.0
  let r = misc_min(w, h) / 2.0
  let eye_r = r * 0.1
  let eye_y = cy - r * 0.2
  let left_eye_x = cx - r * 0.3
  let right_eye_x = cx + r * 0.3
  let smile_y = cy + r * 0.1
  let smile_r = r * 0.5
  // Face outline
  "M " +
  fmt(cx + r) +
  " " +
  fmt(cy) +
  " A " +
  fmt(r) +
  " " +
  fmt(r) +
  " 0 1 1 " +
  fmt(cx - r) +
  " " +
  fmt(cy) +
  " A " +
  fmt(r) +
  " " +
  fmt(r) +
  " 0 1 1 " +
  fmt(cx + r) +
  " " +
  fmt(cy) +
  " Z " +
  // Left eye
  "M " +
  fmt(left_eye_x + eye_r) +
  " " +
  fmt(eye_y) +
  " A " +
  fmt(eye_r) +
  " " +
  fmt(eye_r) +
  " 0 1 1 " +
  fmt(left_eye_x - eye_r) +
  " " +
  fmt(eye_y) +
  " A " +
  fmt(eye_r) +
  " " +
  fmt(eye_r) +
  " 0 1 1 " +
  fmt(left_eye_x + eye_r) +
  " " +
  fmt(eye_y) +
  " Z " +
  // Right eye
  "M " +
  fmt(right_eye_x + eye_r) +
  " " +
  fmt(eye_y) +
  " A " +
  fmt(eye_r) +
  " " +
  fmt(eye_r) +
  " 0 1 1 " +
  fmt(right_eye_x - eye_r) +
  " " +
  fmt(eye_y) +
  " A " +
  fmt(eye_r) +
  " " +
  fmt(eye_r) +
  " 0 1 1 " +
  fmt(right_eye_x + eye_r) +
  " " +
  fmt(eye_y) +
  " Z " +
  // Smile
  "M " +
  fmt(cx - smile_r) +
  " " +
  fmt(smile_y) +
  " Q " +
  fmt(cx) +
  " " +
  fmt(smile_y + smile_r) +
  " " +
  fmt(cx + smile_r) +
  " " +
  fmt(smile_y)
}

// ============================================================================
// ribbon / ribbon2 — preset-shapes.ts:3997, 4031
// ============================================================================

///|
fn misc_ribbon(w : Double, h : Double, ctx : GuideContext) -> String {
  let ribbon_height = h * (ctx.get("adj1").unwrap_or(16667.0) / 100000.0)
  let fold_width = w * (ctx.get("adj2").unwrap_or(50000.0) / 100000.0) * 0.2
  let fold_height = h * 0.15
  let main_top = fold_height
  let main_bottom = h - fold_height
  let band_height = ribbon_height
  misc_join([
    // Main ribbon body with curved ends
    "M " + fmt(fold_width) + " " + fmt(main_top) + " ",
    "L " + fmt(w - fold_width) + " " + fmt(main_top) + " ",
    "Q " +
    fmt(w) +
    " " +
    fmt(main_top) +
    " " +
    fmt(w) +
    " " +
    fmt(main_top + band_height / 2.0) +
    " ",
    "Q " +
    fmt(w) +
    " " +
    fmt(main_top + band_height) +
    " " +
    fmt(w - fold_width) +
    " " +
    fmt(main_top + band_height) +
    " ",
    "L " + fmt(w - fold_width) + " " + fmt(main_bottom - band_height) + " ",
    "Q " +
    fmt(w) +
    " " +
    fmt(main_bottom - band_height) +
    " " +
    fmt(w) +
    " " +
    fmt(main_bottom - band_height / 2.0) +
    " ",
    "Q " +
    fmt(w) +
    " " +
    fmt(main_bottom) +
    " " +
    fmt(w - fold_width) +
    " " +
    fmt(main_bottom) +
    " ",
    "L " + fmt(fold_width) + " " + fmt(main_bottom) + " ",
    "Q 0 " +
    fmt(main_bottom) +
    " 0 " +
    fmt(main_bottom - band_height / 2.0) +
    " ",
    "Q 0 " +
    fmt(main_bottom - band_height) +
    " " +
    fmt(fold_width) +
    " " +
    fmt(main_bottom - band_height) +
    " ",
    "L " + fmt(fold_width) + " " + fmt(main_top + band_height) + " ",
    "Q 0 " +
    fmt(main_top + band_height) +
    " 0 " +
    fmt(main_top + band_height / 2.0) +
    " ",
    "Q 0 " + fmt(main_top) + " " + fmt(fold_width) + " " + fmt(main_top) + " Z ",
    // Left fold
    "M 0 0 L " +
    fmt(fold_width) +
    " " +
    fmt(fold_height) +
    " L " +
    fmt(fold_width) +
    " " +
    fmt(h - fold_height) +
    " L 0 " +
    fmt(h) +
    " Z ",
    // Right fold
    "M " +
    fmt(w) +
    " 0 L " +
    fmt(w - fold_width) +
    " " +
    fmt(fold_height) +
    " L " +
    fmt(w - fold_width) +
    " " +
    fmt(h - fold_height) +
    " L " +
    fmt(w) +
    " " +
    fmt(h) +
    " Z",
  ])
}

///|
fn misc_ribbon2(w : Double, h : Double, ctx : GuideContext) -> String {
  let ribbon_height = h * (ctx.get("adj1").unwrap_or(16667.0) / 100000.0)
  let fold_width = w * (ctx.get("adj2").unwrap_or(50000.0) / 100000.0) * 0.2
  let fold_height = h * 0.15
  let main_top = 0.0
  let main_bottom = h
  let band_height = ribbon_height
  misc_join([
    "M 0 " + fmt(main_top + band_height) + " ",
    "Q 0 " + fmt(main_top) + " " + fmt(fold_width) + " " + fmt(main_top) + " ",
    "L " + fmt(w - fold_width) + " " + fmt(main_top) + " ",
    "Q " +
    fmt(w) +
    " " +
    fmt(main_top) +
    " " +
    fmt(w) +
    " " +
    fmt(main_top + band_height) +
    " ",
    "L " + fmt(w) + " " + fmt(main_bottom - band_height) + " ",
    "Q " +
    fmt(w) +
    " " +
    fmt(main_bottom) +
    " " +
    fmt(w - fold_width) +
    " " +
    fmt(main_bottom) +
    " ",
    "L " + fmt(fold_width) + " " + fmt(main_bottom) + " ",
    "Q 0 " + fmt(main_bottom) + " 0 " + fmt(main_bottom - band_height) + " Z ",
    // Left inner fold
    "M " +
    fmt(fold_width) +
    " " +
    fmt(fold_height) +
    " L " +
    fmt(fold_width * 2.0) +
    " " +
    fmt(fold_height * 2.0) +
    " L " +
    fmt(fold_width * 2.0) +
    " " +
    fmt(h - fold_height * 2.0) +
    " L " +
    fmt(fold_width) +
    " " +
    fmt(h - fold_height) +
    " Z ",
    // Right inner fold
    "M " +
    fmt(w - fold_width) +
    " " +
    fmt(fold_height) +
    " L " +
    fmt(w - fold_width * 2.0) +
    " " +
    fmt(fold_height * 2.0) +
    " L " +
    fmt(w - fold_width * 2.0) +
    " " +
    fmt(h - fold_height * 2.0) +
    " L " +
    fmt(w - fold_width) +
    " " +
    fmt(h - fold_height) +
    " Z",
  ])
}

// ============================================================================
// ellipseRibbon / ellipseRibbon2 — preset-shapes.ts:4060, 4084
// ============================================================================

///|
fn misc_ellipse_ribbon(w : Double, h : Double, ctx : GuideContext) -> String {
  let curve_depth = h * (ctx.get("adj2").unwrap_or(50000.0) / 100000.0) * 0.3
  let tab_width = w * 0.15
  let tab_height = h * 0.2
  let main_y = tab_height
  let main_bottom = h - tab_height
  misc_join([
    // Main curved ribbon body
    "M " + fmt(tab_width) + " " + fmt(main_y) + " ",
    "Q " +
    fmt(w / 2.0) +
    " " +
    fmt(main_y - curve_depth) +
    " " +
    fmt(w - tab_width) +
    " " +
    fmt(main_y) +
    " ",
    "L " + fmt(w - tab_width) + " " + fmt(main_bottom) + " ",
    "Q " +
    fmt(w / 2.0) +
    " " +
    fmt(main_bottom + curve_depth) +
    " " +
    fmt(tab_width) +
    " " +
    fmt(main_bottom) +
    " Z ",
    // Left tab
    "M 0 0 L " +
    fmt(tab_width) +
    " " +
    fmt(tab_height) +
    " L " +
    fmt(tab_width) +
    " " +
    fmt(h - tab_height) +
    " L 0 " +
    fmt(h) +
    " Z ",
    // Right tab
    "M " +
    fmt(w) +
    " 0 L " +
    fmt(w - tab_width) +
    " " +
    fmt(tab_height) +
    " L " +
    fmt(w - tab_width) +
    " " +
    fmt(h - tab_height) +
    " L " +
    fmt(w) +
    " " +
    fmt(h) +
    " Z",
  ])
}

///|
fn misc_ellipse_ribbon2(w : Double, h : Double, ctx : GuideContext) -> String {
  let curve_depth = h * (ctx.get("adj2").unwrap_or(50000.0) / 100000.0) * 0.3
  let tab_width = w * 0.15
  let tab_height = h * 0.2
  misc_join([
    // Main curved ribbon body (inverted curve direction)
    "M 0 " + fmt(tab_height) + " ",
    "Q " +
    fmt(w / 2.0) +
    " " +
    fmt(tab_height + curve_depth) +
    " " +
    fmt(w) +
    " " +
    fmt(tab_height) +
    " ",
    "L " + fmt(w) + " " + fmt(h - tab_height) + " ",
    "Q " +
    fmt(w / 2.0) +
    " " +
    fmt(h - tab_height - curve_depth) +
    " 0 " +
    fmt(h - tab_height) +
    " Z ",
    // Left inner tab
    "M " +
    fmt(tab_width) +
    " " +
    fmt(tab_height) +
    " L " +
    fmt(tab_width * 2.0) +
    " 0 L " +
    fmt(tab_width * 2.0) +
    " " +
    fmt(h) +
    " L " +
    fmt(tab_width) +
    " " +
    fmt(h - tab_height) +
    " Z ",
    // Right inner tab
    "M " +
    fmt(w - tab_width) +
    " " +
    fmt(tab_height) +
    " L " +
    fmt(w - tab_width * 2.0) +
    " 0 L " +
    fmt(w - tab_width * 2.0) +
    " " +
    fmt(h) +
    " L " +
    fmt(w - tab_width) +
    " " +
    fmt(h - tab_height) +
    " Z",
  ])
}

// ============================================================================
// leftRightRibbon — preset-shapes.ts:4106
// ============================================================================

///|
fn misc_left_right_ribbon(w : Double, h : Double, ctx : GuideContext) -> String {
  let ribbon_offset = h * (ctx.get("adj").unwrap_or(50000.0) / 100000.0) * 0.2
  let tab_width = w * 0.2
  let half_h = h / 2.0
  // Left ribbon going right
  let left_ribbon_path = "M 0 " +
    fmt(ribbon_offset) +
    " L " +
    fmt(w - tab_width) +
    " " +
    fmt(ribbon_offset) +
    " L " +
    fmt(w - tab_width) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(half_h / 2.0 + ribbon_offset / 2.0) +
    " L " +
    fmt(w - tab_width) +
    " " +
    fmt(half_h) +
    " L " +
    fmt(w - tab_width) +
    " " +
    fmt(half_h - ribbon_offset) +
    " L " +
    fmt(tab_width) +
    " " +
    fmt(half_h - ribbon_offset) +
    " L " +
    fmt(tab_width) +
    " " +
    fmt(half_h) +
    " L 0 " +
    fmt(half_h / 2.0 + ribbon_offset / 2.0) +
    " Z"
  // Right ribbon going left
  let right_ribbon_path = "M " +
    fmt(w) +
    " " +
    fmt(h - ribbon_offset) +
    " L " +
    fmt(tab_width) +
    " " +
    fmt(h - ribbon_offset) +
    " L " +
    fmt(tab_width) +
    " " +
    fmt(h) +
    " L 0 " +
    fmt(h - half_h / 2.0 - ribbon_offset / 2.0) +
    " L " +
    fmt(tab_width) +
    " " +
    fmt(half_h) +
    " L " +
    fmt(tab_width) +
    " " +
    fmt(half_h + ribbon_offset) +
    " L " +
    fmt(w - tab_width) +
    " " +
    fmt(half_h + ribbon_offset) +
    " L " +
    fmt(w - tab_width) +
    " " +
    fmt(half_h) +
    " L " +
    fmt(w) +
    " " +
    fmt(h - half_h / 2.0 - ribbon_offset / 2.0) +
    " Z"
  left_ribbon_path + " " + right_ribbon_path
}

// ============================================================================
// wave / doubleWave — preset-shapes.ts:4144, 4165
// ============================================================================

///|
fn misc_wave(w : Double, h : Double, ctx : GuideContext) -> String {
  let wave_depth = h * (ctx.get("adj1").unwrap_or(12500.0) / 100000.0)
  let wave_offset = w * (ctx.get("adj2").unwrap_or(0.0) / 100000.0)
  let cp1x = w * 0.25 + wave_offset
  let cp2x = w * 0.75 + wave_offset
  // Top wave (sine-shaped)
  "M 0 " +
  fmt(wave_depth) +
  " Q " +
  fmt(cp1x) +
  " 0 " +
  fmt(w / 2.0) +
  " " +
  fmt(wave_depth) +
  " Q " +
  fmt(cp2x) +
  " " +
  fmt(wave_depth * 2.0) +
  " " +
  fmt(w) +
  " " +
  fmt(wave_depth) +
  " L " +
  fmt(w) +
  " " +
  fmt(h - wave_depth) +
  " Q " +
  fmt(cp2x) +
  " " +
  fmt(h) +
  " " +
  fmt(w / 2.0) +
  " " +
  fmt(h - wave_depth) +
  " Q " +
  fmt(cp1x) +
  " " +
  fmt(h - wave_depth * 2.0) +
  " 0 " +
  fmt(h - wave_depth) +
  " Z"
}

///|
fn misc_double_wave(w : Double, h : Double, ctx : GuideContext) -> String {
  let wave_depth = h * (ctx.get("adj1").unwrap_or(6250.0) / 100000.0)
  let wave_offset = w * (ctx.get("adj2").unwrap_or(0.0) / 100000.0)
  let cp1x = w * 0.125 + wave_offset
  let cp2x = w * 0.375 + wave_offset
  let cp3x = w * 0.625 + wave_offset
  let cp4x = w * 0.875 + wave_offset
  misc_join([
    "M 0 " + fmt(wave_depth) + " ",
    "Q " + fmt(cp1x) + " 0 " + fmt(w * 0.25) + " " + fmt(wave_depth) + " ",
    "Q " +
    fmt(cp2x) +
    " " +
    fmt(wave_depth * 2.0) +
    " " +
    fmt(w * 0.5) +
    " " +
    fmt(wave_depth) +
    " ",
    "Q " + fmt(cp3x) + " 0 " + fmt(w * 0.75) + " " + fmt(wave_depth) + " ",
    "Q " +
    fmt(cp4x) +
    " " +
    fmt(wave_depth * 2.0) +
    " " +
    fmt(w) +
    " " +
    fmt(wave_depth) +
    " ",
    "L " + fmt(w) + " " + fmt(h - wave_depth) + " ",
    "Q " +
    fmt(cp4x) +
    " " +
    fmt(h) +
    " " +
    fmt(w * 0.75) +
    " " +
    fmt(h - wave_depth) +
    " ",
    "Q " +
    fmt(cp3x) +
    " " +
    fmt(h - wave_depth * 2.0) +
    " " +
    fmt(w * 0.5) +
    " " +
    fmt(h - wave_depth) +
    " ",
    "Q " +
    fmt(cp2x) +
    " " +
    fmt(h) +
    " " +
    fmt(w * 0.25) +
    " " +
    fmt(h - wave_depth) +
    " ",
    "Q " +
    fmt(cp1x) +
    " " +
    fmt(h - wave_depth * 2.0) +
    " 0 " +
    fmt(h - wave_depth) +
    " Z",
  ])
}

// ============================================================================
// pieWedge — preset-shapes.ts:4196
// ============================================================================

///|
fn misc_pie_wedge(w : Double, h : Double) -> String {
  "M " +
  fmt(w) +
  " " +
  fmt(h) +
  " L " +
  fmt(w) +
  " 0 A " +
  fmt(w) +
  " " +
  fmt(h) +
  " 0 0 0 0 " +
  fmt(h) +
  " Z"
}

// ============================================================================
// blockArc — preset-shapes.ts:4205
// ============================================================================

///|
fn misc_block_arc(w : Double, h : Double, ctx : GuideContext) -> String {
  let start_angle = ctx.get("adj1").unwrap_or(180.0 * 60000.0) /
    60000.0 *
    misc_pi /
    180.0
  let end_angle = ctx.get("adj2").unwrap_or(0.0) / 60000.0 * misc_pi / 180.0
  let thickness = ctx.get("adj3").unwrap_or(25000.0) / 100000.0
  let rx = w / 2.0
  let ry = h / 2.0
  let inner_rx = rx * (1.0 - thickness)
  let inner_ry = ry * (1.0 - thickness)
  let cx = rx
  let cy = ry
  let x1 = cx + rx * misc_cos(start_angle)
  let y1 = cy + ry * misc_sin(start_angle)
  let x2 = cx + rx * misc_cos(end_angle)
  let y2 = cy + ry * misc_sin(end_angle)
  let x3 = cx + inner_rx * misc_cos(end_angle)
  let y3 = cy + inner_ry * misc_sin(end_angle)
  let x4 = cx + inner_rx * misc_cos(start_angle)
  let y4 = cy + inner_ry * misc_sin(start_angle)
  let sweep = end_angle - start_angle
  let large_arc = if misc_abs(sweep) > misc_pi { 1 } else { 0 }
  "M " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 " +
  large_arc.to_string() +
  " 1 " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y3) +
  " A " +
  fmt(inner_rx) +
  " " +
  fmt(inner_ry) +
  " 0 " +
  large_arc.to_string() +
  " 0 " +
  fmt(x4) +
  " " +
  fmt(y4) +
  " Z"
}

// ============================================================================
// noSmoking — preset-shapes.ts:4235
// ============================================================================

///|
fn misc_no_smoking(w : Double, h : Double, ctx : GuideContext) -> String {
  let thickness = ctx.get("adj").unwrap_or(18750.0) / 100000.0
  let rx = w / 2.0
  let ry = h / 2.0
  let inner_rx = rx * (1.0 - thickness)
  let inner_ry = ry * (1.0 - thickness)
  let slash_thickness = misc_min(w, h) * thickness * 0.5
  let angle = misc_pi / 4.0
  let c = misc_cos(angle)
  let s = misc_sin(angle)
  let sx1 = rx - inner_rx * c
  let sy1 = ry - inner_ry * s
  let sx2 = rx + inner_rx * c
  let sy2 = ry + inner_ry * s
  let perp_x = slash_thickness * s / 2.0
  let perp_y = slash_thickness * c / 2.0
  misc_join([
    "M " +
    fmt(rx) +
    " 0 A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 1 1 " +
    fmt(rx) +
    " " +
    fmt(h) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 1 1 " +
    fmt(rx) +
    " 0 Z ",
    "M " +
    fmt(rx) +
    " " +
    fmt(ry - inner_ry) +
    " A " +
    fmt(inner_rx) +
    " " +
    fmt(inner_ry) +
    " 0 1 0 " +
    fmt(rx) +
    " " +
    fmt(ry + inner_ry) +
    " A " +
    fmt(inner_rx) +
    " " +
    fmt(inner_ry) +
    " 0 1 0 " +
    fmt(rx) +
    " " +
    fmt(ry - inner_ry) +
    " Z ",
    "M " +
    fmt(sx1 - perp_x) +
    " " +
    fmt(sy1 + perp_y) +
    " L " +
    fmt(sx2 - perp_x) +
    " " +
    fmt(sy2 + perp_y) +
    " L " +
    fmt(sx2 + perp_x) +
    " " +
    fmt(sy2 - perp_y) +
    " L " +
    fmt(sx1 + perp_x) +
    " " +
    fmt(sy1 - perp_y) +
    " Z",
  ])
}

// ============================================================================
// cube — preset-shapes.ts:4265
// ============================================================================

///|
fn misc_cube(w : Double, h : Double, ctx : GuideContext) -> String {
  let depth = ctx.get("adj").unwrap_or(25000.0) / 100000.0 * misc_min(w, h)
  misc_join([
    "M 0 " +
    fmt(depth) +
    " L " +
    fmt(w - depth) +
    " " +
    fmt(depth) +
    " L " +
    fmt(w - depth) +
    " " +
    fmt(h) +
    " L 0 " +
    fmt(h) +
    " Z ",
    "M 0 " +
    fmt(depth) +
    " L " +
    fmt(depth) +
    " 0 L " +
    fmt(w) +
    " 0 L " +
    fmt(w - depth) +
    " " +
    fmt(depth) +
    " Z ",
    "M " +
    fmt(w - depth) +
    " " +
    fmt(depth) +
    " L " +
    fmt(w) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(h - depth) +
    " L " +
    fmt(w - depth) +
    " " +
    fmt(h) +
    " Z",
  ])
}

// ============================================================================
// can — preset-shapes.ts:4281
// ============================================================================

///|
fn misc_can(w : Double, h : Double, ctx : GuideContext) -> String {
  let cap_height = ctx.get("adj").unwrap_or(25000.0) / 100000.0 * h
  let rx = w / 2.0
  let ry = cap_height / 2.0
  misc_join([
    "M 0 " + fmt(ry) + " L 0 " + fmt(h - ry) + " ",
    "A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 0 " +
    fmt(w) +
    " " +
    fmt(h - ry) +
    " ",
    "L " + fmt(w) + " " + fmt(ry) + " ",
    "A " + fmt(rx) + " " + fmt(ry) + " 0 0 0 0 " + fmt(ry) + " Z ",
    "M 0 " +
    fmt(ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 " +
    fmt(w) +
    " " +
    fmt(ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 0 " +
    fmt(ry) +
    " Z",
  ])
}

// ============================================================================
// lightningBolt — preset-shapes.ts:4301
// ============================================================================

///|
fn misc_lightning_bolt(w : Double, h : Double) -> String {
  "M " +
  fmt(w * 0.58) +
  " 0 L " +
  fmt(w * 0.42) +
  " " +
  fmt(h * 0.35) +
  " L " +
  fmt(w * 0.58) +
  " " +
  fmt(h * 0.35) +
  " L " +
  fmt(w * 0.25) +
  " " +
  fmt(h) +
  " L " +
  fmt(w * 0.42) +
  " " +
  fmt(h * 0.55) +
  " L " +
  fmt(w * 0.25) +
  " " +
  fmt(h * 0.55) +
  " L " +
  fmt(w * 0.58) +
  " 0 Z"
}

// ============================================================================
// heart — preset-shapes.ts:4310
// ============================================================================

///|
fn misc_heart(w : Double, h : Double) -> String {
  let cx = w / 2.0
  "M " +
  fmt(cx) +
  " " +
  fmt(h * 0.25) +
  " C " +
  fmt(cx) +
  " " +
  fmt(h * 0.1) +
  " " +
  fmt(w * 0.25) +
  " 0 0 " +
  fmt(h * 0.2) +
  " C 0 " +
  fmt(h * 0.5) +
  " " +
  fmt(cx) +
  " " +
  fmt(h * 0.6) +
  " " +
  fmt(cx) +
  " " +
  fmt(h) +
  " C " +
  fmt(cx) +
  " " +
  fmt(h * 0.6) +
  " " +
  fmt(w) +
  " " +
  fmt(h * 0.5) +
  " " +
  fmt(w) +
  " " +
  fmt(h * 0.2) +
  " C " +
  fmt(w * 0.75) +
  " 0 " +
  fmt(cx) +
  " " +
  fmt(h * 0.1) +
  " " +
  fmt(cx) +
  " " +
  fmt(h * 0.25) +
  " Z"
}

// ============================================================================
// moon — preset-shapes.ts:4320
// ============================================================================

///|
fn misc_moon(w : Double, h : Double, ctx : GuideContext) -> String {
  let inset = ctx.get("adj").unwrap_or(50000.0) / 100000.0 * w
  let rx = w / 2.0
  let ry = h / 2.0
  let inner_rx = rx - inset / 2.0
  "M " +
  fmt(rx) +
  " 0 A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(rx) +
  " " +
  fmt(h) +
  " A " +
  fmt(inner_rx) +
  " " +
  fmt(ry) +
  " 0 1 0 " +
  fmt(rx) +
  " 0 Z"
}

// ============================================================================
// irregularSeal1 / irregularSeal2 — preset-shapes.ts:4335, 4345
// ============================================================================

///|
fn misc_irregular_seal1(w : Double, h : Double) -> String {
  "M " +
  fmt(w * 0.4) +
  " 0 L " +
  fmt(w * 0.45) +
  " " +
  fmt(h * 0.2) +
  " L " +
  fmt(w * 0.65) +
  " " +
  fmt(h * 0.15) +
  " L " +
  fmt(w * 0.55) +
  " " +
  fmt(h * 0.3) +
  " L " +
  fmt(w) +
  " " +
  fmt(h * 0.35) +
  " L " +
  fmt(w * 0.7) +
  " " +
  fmt(h * 0.45) +
  " L " +
  fmt(w * 0.85) +
  " " +
  fmt(h * 0.7) +
  " L " +
  fmt(w * 0.6) +
  " " +
  fmt(h * 0.6) +
  " L " +
  fmt(w * 0.7) +
  " " +
  fmt(h) +
  " L " +
  fmt(w * 0.45) +
  " " +
  fmt(h * 0.75) +
  " L " +
  fmt(w * 0.25) +
  " " +
  fmt(h * 0.9) +
  " L " +
  fmt(w * 0.35) +
  " " +
  fmt(h * 0.65) +
  " L 0 " +
  fmt(h * 0.6) +
  " L " +
  fmt(w * 0.25) +
  " " +
  fmt(h * 0.5) +
  " L " +
  fmt(w * 0.1) +
  " " +
  fmt(h * 0.25) +
  " L " +
  fmt(w * 0.35) +
  " " +
  fmt(h * 0.35) +
  " Z"
}

///|
fn misc_irregular_seal2(w : Double, h : Double) -> String {
  "M " +
  fmt(w * 0.45) +
  " 0 L " +
  fmt(w * 0.5) +
  " " +
  fmt(h * 0.15) +
  " L " +
  fmt(w * 0.75) +
  " " +
  fmt(h * 0.05) +
  " L " +
  fmt(w * 0.65) +
  " " +
  fmt(h * 0.25) +
  " L " +
  fmt(w) +
  " " +
  fmt(h * 0.3) +
  " L " +
  fmt(w * 0.75) +
  " " +
  fmt(h * 0.4) +
  " L " +
  fmt(w * 0.95) +
  " " +
  fmt(h * 0.65) +
  " L " +
  fmt(w * 0.7) +
  " " +
  fmt(h * 0.55) +
  " L " +
  fmt(w * 0.8) +
  " " +
  fmt(h * 0.85) +
  " L " +
  fmt(w * 0.55) +
  " " +
  fmt(h * 0.7) +
  " L " +
  fmt(w * 0.5) +
  " " +
  fmt(h) +
  " L " +
  fmt(w * 0.4) +
  " " +
  fmt(h * 0.75) +
  " L " +
  fmt(w * 0.15) +
  " " +
  fmt(h * 0.9) +
  " L " +
  fmt(w * 0.3) +
  " " +
  fmt(h * 0.6) +
  " L 0 " +
  fmt(h * 0.5) +
  " L " +
  fmt(w * 0.2) +
  " " +
  fmt(h * 0.45) +
  " L " +
  fmt(w * 0.05) +
  " " +
  fmt(h * 0.2) +
  " L " +
  fmt(w * 0.3) +
  " " +
  fmt(h * 0.3) +
  " Z"
}

// ============================================================================
// foldedCorner — preset-shapes.ts:4354
// ============================================================================

///|
fn misc_folded_corner(w : Double, h : Double, ctx : GuideContext) -> String {
  let fold = ctx.get("adj").unwrap_or(16667.0) / 100000.0 * misc_min(w, h)
  misc_join([
    "M 0 0 L " +
    fmt(w) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(h - fold) +
    " L " +
    fmt(w - fold) +
    " " +
    fmt(h) +
    " L 0 " +
    fmt(h) +
    " Z ",
    "M " +
    fmt(w - fold) +
    " " +
    fmt(h) +
    " L " +
    fmt(w - fold) +
    " " +
    fmt(h - fold) +
    " L " +
    fmt(w) +
    " " +
    fmt(h - fold) +
    " Z",
  ])
}

// ============================================================================
// bevel — preset-shapes.ts:4369
// ============================================================================

///|
fn misc_bevel(w : Double, h : Double, ctx : GuideContext) -> String {
  let bevel_size = ctx.get("adj").unwrap_or(12500.0) / 100000.0 * misc_min(w, h)
  misc_join([
    "M 0 0 L " +
    fmt(w) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(h) +
    " L 0 " +
    fmt(h) +
    " Z ",
    "M " +
    fmt(bevel_size) +
    " " +
    fmt(bevel_size) +
    " L " +
    fmt(w - bevel_size) +
    " " +
    fmt(bevel_size) +
    " L " +
    fmt(w - bevel_size) +
    " " +
    fmt(h - bevel_size) +
    " L " +
    fmt(bevel_size) +
    " " +
    fmt(h - bevel_size) +
    " Z",
  ])
}

// ============================================================================
// frame — preset-shapes.ts:4384
// ============================================================================

///|
fn misc_frame(w : Double, h : Double, ctx : GuideContext) -> String {
  let frame_width = ctx.get("adj1").unwrap_or(12500.0) /
    100000.0 *
    misc_min(w, h)
  misc_join([
    "M 0 0 L " +
    fmt(w) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(h) +
    " L 0 " +
    fmt(h) +
    " Z ",
    "M " +
    fmt(frame_width) +
    " " +
    fmt(frame_width) +
    " L " +
    fmt(frame_width) +
    " " +
    fmt(h - frame_width) +
    " L " +
    fmt(w - frame_width) +
    " " +
    fmt(h - frame_width) +
    " L " +
    fmt(w - frame_width) +
    " " +
    fmt(frame_width) +
    " Z",
  ])
}

// ============================================================================
// halfFrame — preset-shapes.ts:4399
// ============================================================================

///|
fn misc_half_frame(w : Double, h : Double, ctx : GuideContext) -> String {
  let arm_width = ctx.get("adj1").unwrap_or(33333.0) / 100000.0 * w
  let arm_height = ctx.get("adj2").unwrap_or(33333.0) / 100000.0 * h
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(arm_height) +
  " L " +
  fmt(arm_width) +
  " " +
  fmt(arm_height) +
  " L " +
  fmt(arm_width) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

// ============================================================================
// corner — preset-shapes.ts:4410
// ============================================================================

///|
fn misc_corner(w : Double, h : Double, ctx : GuideContext) -> String {
  let arm_width = ctx.get("adj1").unwrap_or(50000.0) / 100000.0 * w
  let arm_height = ctx.get("adj2").unwrap_or(50000.0) / 100000.0 * h
  "M 0 0 L " +
  fmt(arm_width) +
  " 0 L " +
  fmt(arm_width) +
  " " +
  fmt(h - arm_height) +
  " L " +
  fmt(w) +
  " " +
  fmt(h - arm_height) +
  " L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

// ============================================================================
// diagStripe — preset-shapes.ts:4421
// ============================================================================

///|
fn misc_diag_stripe(w : Double, h : Double, ctx : GuideContext) -> String {
  let stripe_width = ctx.get("adj").unwrap_or(50000.0) / 100000.0
  let x1 = w * stripe_width
  let y1 = h * stripe_width
  "M 0 " +
  fmt(y1) +
  " L 0 0 L " +
  fmt(x1) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h - y1) +
  " L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L " +
  fmt(w - x1) +
  " " +
  fmt(h) +
  " Z"
}

// ============================================================================
// verticalScroll / horizontalScroll — preset-shapes.ts:4458, 4477
// ============================================================================

///|
fn misc_vertical_scroll(w : Double, h : Double, ctx : GuideContext) -> String {
  let scroll_width = w * (ctx.get("adj").unwrap_or(12500.0) / 100000.0)
  let r = scroll_width / 2.0
  misc_join([
    "M " + fmt(scroll_width) + " 0 L " + fmt(w - scroll_width) + " 0 ",
    "A " +
    fmt(r) +
    " " +
    fmt(r) +
    " 0 0 1 " +
    fmt(w) +
    " " +
    fmt(r) +
    " L " +
    fmt(w) +
    " " +
    fmt(h - scroll_width) +
    " ",
    "A " +
    fmt(r) +
    " " +
    fmt(r) +
    " 0 0 1 " +
    fmt(w - scroll_width) +
    " " +
    fmt(h) +
    " L " +
    fmt(scroll_width) +
    " " +
    fmt(h) +
    " ",
    "A " +
    fmt(r) +
    " " +
    fmt(r) +
    " 0 0 1 0 " +
    fmt(h - r) +
    " L 0 " +
    fmt(scroll_width) +
    " ",
    "A " + fmt(r) + " " + fmt(r) + " 0 0 1 " + fmt(scroll_width) + " 0 Z",
  ])
}

///|
fn misc_horizontal_scroll(w : Double, h : Double, ctx : GuideContext) -> String {
  let scroll_height = h * (ctx.get("adj").unwrap_or(12500.0) / 100000.0)
  let r = scroll_height / 2.0
  misc_join([
    "M 0 " + fmt(scroll_height) + " L 0 " + fmt(h - scroll_height) + " ",
    "A " +
    fmt(r) +
    " " +
    fmt(r) +
    " 0 0 0 " +
    fmt(scroll_height) +
    " " +
    fmt(h) +
    " L " +
    fmt(w - scroll_height) +
    " " +
    fmt(h) +
    " ",
    "A " +
    fmt(r) +
    " " +
    fmt(r) +
    " 0 0 0 " +
    fmt(w) +
    " " +
    fmt(h - scroll_height) +
    " L " +
    fmt(w) +
    " " +
    fmt(scroll_height) +
    " ",
    "A " +
    fmt(r) +
    " " +
    fmt(r) +
    " 0 0 0 " +
    fmt(w - scroll_height) +
    " 0 L " +
    fmt(scroll_height) +
    " 0 ",
    "A " + fmt(r) + " " + fmt(r) + " 0 0 0 0 " + fmt(scroll_height) + " Z",
  ])
}

// ============================================================================
// gear6 / gear9 — preset-shapes.ts:4496, 4534
// ============================================================================

///|
/// Generic N-tooth gear; `default_ratio` is the per-preset default
/// (15000 for gear6, 10000 for gear9).
fn misc_gear(
  w : Double,
  h : Double,
  ctx : GuideContext,
  teeth : Int,
  default_ratio : Double,
) -> String {
  let outer_ratio = ctx.get("adj1").unwrap_or(default_ratio) / 100000.0
  let cx = w / 2.0
  let cy = h / 2.0
  let outer_r = misc_min(w, h) / 2.0
  let inner_r = outer_r * (1.0 - outer_ratio)
  let step = 360.0 / teeth.to_double()
  let tooth_width = step / 3.0
  let half_step = step / 2.0
  let buf = StringBuilder::new()
  for i in 0..<teeth {
    let base_angle = i.to_double() * step
    let a1 = (base_angle - tooth_width / 2.0 - 90.0) * misc_pi / 180.0
    let a2 = (base_angle + tooth_width / 2.0 - 90.0) * misc_pi / 180.0
    let a3 = (base_angle + half_step - tooth_width / 2.0 - 90.0) *
      misc_pi /
      180.0
    let a4 = (base_angle + half_step + tooth_width / 2.0 - 90.0) *
      misc_pi /
      180.0
    let ox1 = cx + outer_r * misc_cos(a1)
    let oy1 = cy + outer_r * misc_sin(a1)
    let ox2 = cx + outer_r * misc_cos(a2)
    let oy2 = cy + outer_r * misc_sin(a2)
    let ix3 = cx + inner_r * misc_cos(a3)
    let iy3 = cy + inner_r * misc_sin(a3)
    let ix4 = cx + inner_r * misc_cos(a4)
    let iy4 = cy + inner_r * misc_sin(a4)
    if i == 0 {
      buf.write_string(
        "M " +
        fmt(ox1) +
        " " +
        fmt(oy1) +
        " L " +
        fmt(ox2) +
        " " +
        fmt(oy2) +
        " L " +
        fmt(ix3) +
        " " +
        fmt(iy3) +
        " L " +
        fmt(ix4) +
        " " +
        fmt(iy4) +
        " ",
      )
    } else {
      buf.write_string(
        "L " +
        fmt(ox2) +
        " " +
        fmt(oy2) +
        " L " +
        fmt(ix3) +
        " " +
        fmt(iy3) +
        " L " +
        fmt(ix4) +
        " " +
        fmt(iy4) +
        " ",
      )
    }
  }
  buf.write_string("Z")
  buf.to_string()
}

// ============================================================================
// funnel — preset-shapes.ts:4570
// ============================================================================

///|
fn misc_funnel(w : Double, h : Double, ctx : GuideContext) -> String {
  let neck_width = w * (ctx.get("adj1").unwrap_or(25000.0) / 100000.0)
  let neck_height = h * (ctx.get("adj2").unwrap_or(25000.0) / 100000.0)
  let cx = w / 2.0
  let rx = w / 2.0
  let ry = h * 0.15
  misc_join([
    "M 0 " +
    fmt(ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 " +
    fmt(w) +
    " " +
    fmt(ry) +
    " ",
    "L " + fmt(cx + neck_width / 2.0) + " " + fmt(h - neck_height) + " ",
    "L " +
    fmt(cx + neck_width / 2.0) +
    " " +
    fmt(h) +
    " L " +
    fmt(cx - neck_width / 2.0) +
    " " +
    fmt(h) +
    " L " +
    fmt(cx - neck_width / 2.0) +
    " " +
    fmt(h - neck_height) +
    " ",
    "L 0 " + fmt(ry) + " Z",
  ])
}

// ============================================================================
// mathPlus / mathMinus / mathMultiply / mathDivide / mathEqual / mathNotEqual
// preset-shapes.ts:4591, 4604, 4616, 4631, 4654, 4671
// ============================================================================

///|
fn misc_math_plus(w : Double, h : Double, ctx : GuideContext) -> String {
  let thickness = misc_min(w, h) *
    (ctx.get("adj1").unwrap_or(23520.0) / 100000.0)
  let cx = w / 2.0
  let cy = h / 2.0
  let hw = thickness / 2.0
  "M " +
  fmt(cx - hw) +
  " 0 L " +
  fmt(cx + hw) +
  " 0 L " +
  fmt(cx + hw) +
  " " +
  fmt(cy - hw) +
  " L " +
  fmt(w) +
  " " +
  fmt(cy - hw) +
  " L " +
  fmt(w) +
  " " +
  fmt(cy + hw) +
  " L " +
  fmt(cx + hw) +
  " " +
  fmt(cy + hw) +
  " L " +
  fmt(cx + hw) +
  " " +
  fmt(h) +
  " L " +
  fmt(cx - hw) +
  " " +
  fmt(h) +
  " L " +
  fmt(cx - hw) +
  " " +
  fmt(cy + hw) +
  " L 0 " +
  fmt(cy + hw) +
  " L 0 " +
  fmt(cy - hw) +
  " L " +
  fmt(cx - hw) +
  " " +
  fmt(cy - hw) +
  " Z"
}

///|
fn misc_math_minus(w : Double, h : Double, ctx : GuideContext) -> String {
  let thickness = h * (ctx.get("adj1").unwrap_or(23520.0) / 100000.0)
  let cy = h / 2.0
  let hw = thickness / 2.0
  "M 0 " +
  fmt(cy - hw) +
  " L " +
  fmt(w) +
  " " +
  fmt(cy - hw) +
  " L " +
  fmt(w) +
  " " +
  fmt(cy + hw) +
  " L 0 " +
  fmt(cy + hw) +
  " Z"
}

///|
fn misc_math_multiply(w : Double, h : Double, ctx : GuideContext) -> String {
  let thickness = misc_min(w, h) *
    (ctx.get("adj1").unwrap_or(23520.0) / 100000.0)
  let cx = w / 2.0
  let cy = h / 2.0
  let sqrt2 = (2.0 : Double).sqrt()
  let d = thickness / sqrt2 / 2.0
  let r = misc_min(w, h) / 2.0 - d
  "M " +
  fmt(cx - d) +
  " " +
  fmt(cy - r - d) +
  " L " +
  fmt(cx + d) +
  " " +
  fmt(cy - r - d) +
  " L " +
  fmt(cx + r + d) +
  " " +
  fmt(cy - d) +
  " L " +
  fmt(cx + r + d) +
  " " +
  fmt(cy + d) +
  " L " +
  fmt(cx + d) +
  " " +
  fmt(cy + r + d) +
  " L " +
  fmt(cx - d) +
  " " +
  fmt(cy + r + d) +
  " L " +
  fmt(cx - r - d) +
  " " +
  fmt(cy + d) +
  " L " +
  fmt(cx - r - d) +
  " " +
  fmt(cy - d) +
  " Z"
}

///|
fn misc_math_divide(w : Double, h : Double, ctx : GuideContext) -> String {
  let thickness = h * (ctx.get("adj1").unwrap_or(23520.0) / 100000.0)
  let dot_radius = misc_min(w, h) * 0.1
  let cx = w / 2.0
  let cy = h / 2.0
  let hw = thickness / 2.0
  let top_dot_y = cy - hw - dot_radius * 2.0
  let bottom_dot_y = cy + hw + dot_radius * 2.0
  misc_join([
    "M 0 " +
    fmt(cy - hw) +
    " L " +
    fmt(w) +
    " " +
    fmt(cy - hw) +
    " L " +
    fmt(w) +
    " " +
    fmt(cy + hw) +
    " L 0 " +
    fmt(cy + hw) +
    " Z ",
    "M " +
    fmt(cx + dot_radius) +
    " " +
    fmt(top_dot_y) +
    " A " +
    fmt(dot_radius) +
    " " +
    fmt(dot_radius) +
    " 0 1 1 " +
    fmt(cx - dot_radius) +
    " " +
    fmt(top_dot_y) +
    " A " +
    fmt(dot_radius) +
    " " +
    fmt(dot_radius) +
    " 0 1 1 " +
    fmt(cx + dot_radius) +
    " " +
    fmt(top_dot_y) +
    " Z ",
    "M " +
    fmt(cx + dot_radius) +
    " " +
    fmt(bottom_dot_y) +
    " A " +
    fmt(dot_radius) +
    " " +
    fmt(dot_radius) +
    " 0 1 1 " +
    fmt(cx - dot_radius) +
    " " +
    fmt(bottom_dot_y) +
    " A " +
    fmt(dot_radius) +
    " " +
    fmt(dot_radius) +
    " 0 1 1 " +
    fmt(cx + dot_radius) +
    " " +
    fmt(bottom_dot_y) +
    " Z",
  ])
}

///|
fn misc_math_equal(w : Double, h : Double, ctx : GuideContext) -> String {
  let thickness = h * (ctx.get("adj1").unwrap_or(23520.0) / 100000.0)
  let gap = h * (ctx.get("adj2").unwrap_or(11760.0) / 100000.0)
  let cy = h / 2.0
  let hg = gap / 2.0
  misc_join([
    "M 0 " +
    fmt(cy - hg - thickness) +
    " L " +
    fmt(w) +
    " " +
    fmt(cy - hg - thickness) +
    " L " +
    fmt(w) +
    " " +
    fmt(cy - hg) +
    " L 0 " +
    fmt(cy - hg) +
    " Z ",
    "M 0 " +
    fmt(cy + hg) +
    " L " +
    fmt(w) +
    " " +
    fmt(cy + hg) +
    " L " +
    fmt(w) +
    " " +
    fmt(cy + hg + thickness) +
    " L 0 " +
    fmt(cy + hg + thickness) +
    " Z",
  ])
}

///|
fn misc_math_not_equal(w : Double, h : Double, ctx : GuideContext) -> String {
  let thickness = h * (ctx.get("adj1").unwrap_or(23520.0) / 100000.0)
  let gap = h * (ctx.get("adj2").unwrap_or(11760.0) / 100000.0)
  let slash_thickness = w * 0.1
  let cy = h / 2.0
  let hg = gap / 2.0
  misc_join([
    "M 0 " +
    fmt(cy - hg - thickness) +
    " L " +
    fmt(w) +
    " " +
    fmt(cy - hg - thickness) +
    " L " +
    fmt(w) +
    " " +
    fmt(cy - hg) +
    " L 0 " +
    fmt(cy - hg) +
    " Z ",
    "M 0 " +
    fmt(cy + hg) +
    " L " +
    fmt(w) +
    " " +
    fmt(cy + hg) +
    " L " +
    fmt(w) +
    " " +
    fmt(cy + hg + thickness) +
    " L 0 " +
    fmt(cy + hg + thickness) +
    " Z ",
    "M " +
    fmt(w * 0.3) +
    " " +
    fmt(h) +
    " L " +
    fmt(w * 0.3 + slash_thickness) +
    " " +
    fmt(h) +
    " L " +
    fmt(w * 0.7 + slash_thickness) +
    " 0 L " +
    fmt(w * 0.7) +
    " 0 Z",
  ])
}

// ============================================================================
// cornerTabs / squareTabs / plaqueTabs — preset-shapes.ts:4690, 4706, 4722
// ============================================================================

///|
fn misc_corner_tabs(w : Double, h : Double) -> String {
  let tab_size = misc_min(w, h) * 0.2
  misc_join([
    "M 0 0 L " + fmt(tab_size) + " 0 L 0 " + fmt(tab_size) + " Z ",
    "M " +
    fmt(w - tab_size) +
    " 0 L " +
    fmt(w) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(tab_size) +
    " Z ",
    "M " +
    fmt(w) +
    " " +
    fmt(h - tab_size) +
    " L " +
    fmt(w) +
    " " +
    fmt(h) +
    " L " +
    fmt(w - tab_size) +
    " " +
    fmt(h) +
    " Z ",
    "M 0 " +
    fmt(h - tab_size) +
    " L 0 " +
    fmt(h) +
    " L " +
    fmt(tab_size) +
    " " +
    fmt(h) +
    " Z",
  ])
}

///|
fn misc_square_tabs(w : Double, h : Double) -> String {
  let tab_size = misc_min(w, h) * 0.2
  misc_join([
    "M 0 0 L " +
    fmt(tab_size) +
    " 0 L " +
    fmt(tab_size) +
    " " +
    fmt(tab_size) +
    " L 0 " +
    fmt(tab_size) +
    " Z ",
    "M " +
    fmt(w - tab_size) +
    " 0 L " +
    fmt(w) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(tab_size) +
    " L " +
    fmt(w - tab_size) +
    " " +
    fmt(tab_size) +
    " Z ",
    "M " +
    fmt(w - tab_size) +
    " " +
    fmt(h - tab_size) +
    " L " +
    fmt(w) +
    " " +
    fmt(h - tab_size) +
    " L " +
    fmt(w) +
    " " +
    fmt(h) +
    " L " +
    fmt(w - tab_size) +
    " " +
    fmt(h) +
    " Z ",
    "M 0 " +
    fmt(h - tab_size) +
    " L " +
    fmt(tab_size) +
    " " +
    fmt(h - tab_size) +
    " L " +
    fmt(tab_size) +
    " " +
    fmt(h) +
    " L 0 " +
    fmt(h) +
    " Z",
  ])
}

///|
fn misc_plaque_tabs(w : Double, h : Double) -> String {
  let tab_size = misc_min(w, h) * 0.2
  let r = tab_size
  misc_join([
    "M 0 0 L " +
    fmt(tab_size) +
    " 0 A " +
    fmt(r) +
    " " +
    fmt(r) +
    " 0 0 0 0 " +
    fmt(tab_size) +
    " Z ",
    "M " +
    fmt(w - tab_size) +
    " 0 L " +
    fmt(w) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(tab_size) +
    " A " +
    fmt(r) +
    " " +
    fmt(r) +
    " 0 0 0 " +
    fmt(w - tab_size) +
    " 0 Z ",
    "M " +
    fmt(w) +
    " " +
    fmt(h - tab_size) +
    " A " +
    fmt(r) +
    " " +
    fmt(r) +
    " 0 0 0 " +
    fmt(w - tab_size) +
    " " +
    fmt(h) +
    " L " +
    fmt(w) +
    " " +
    fmt(h) +
    " Z ",
    "M 0 " +
    fmt(h - tab_size) +
    " L 0 " +
    fmt(h) +
    " L " +
    fmt(tab_size) +
    " " +
    fmt(h) +
    " A " +
    fmt(r) +
    " " +
    fmt(r) +
    " 0 0 0 0 " +
    fmt(h - tab_size) +
    " Z",
  ])
}

// ============================================================================
// chartX / chartStar / chartPlus — preset-shapes.ts:4739, 4753, 4762
// ============================================================================

///|
fn misc_chart_x(w : Double, h : Double) -> String {
  let thickness = misc_min(w, h) * 0.2
  let d = thickness / 2.0.sqrt()
  let cx = w / 2.0
  let cy = h / 2.0
  "M " +
  fmt(d) +
  " 0 L " +
  fmt(cx) +
  " " +
  fmt(cy - d) +
  " L " +
  fmt(w - d) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(d) +
  " L " +
  fmt(cx + d) +
  " " +
  fmt(cy) +
  " L " +
  fmt(w) +
  " " +
  fmt(h - d) +
  " L " +
  fmt(w - d) +
  " " +
  fmt(h) +
  " L " +
  fmt(cx) +
  " " +
  fmt(cy + d) +
  " L " +
  fmt(d) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h - d) +
  " L " +
  fmt(cx - d) +
  " " +
  fmt(cy) +
  " L 0 " +
  fmt(d) +
  " Z"
}

///|
/// Build a star polygon mirroring `generateStar` in preset-shapes.ts:5037.
fn misc_generate_star(
  w : Double,
  h : Double,
  points : Int,
  inner_ratio : Double,
) -> String {
  let cx = w / 2.0
  let cy = h / 2.0
  let outer_r = misc_min(w, h) / 2.0
  let inner_r = outer_r * inner_ratio
  let buf = StringBuilder::new()
  let total = points * 2
  for i in 0..<total {
    let angle = (i.to_double() * 180.0 / points.to_double() - 90.0) *
      misc_pi /
      180.0
    let r = if i % 2 == 0 { outer_r } else { inner_r }
    let x = cx + r * misc_cos(angle)
    let y = cy + r * misc_sin(angle)
    if i == 0 {
      buf.write_string("M " + fmt(x) + " " + fmt(y))
    } else {
      buf.write_string(" L " + fmt(x) + " " + fmt(y))
    }
  }
  buf.write_string(" Z")
  buf.to_string()
}

///|
fn misc_chart_star(w : Double, h : Double) -> String {
  misc_generate_star(w, h, 6, 0.5)
}

///|
fn misc_chart_plus(w : Double, h : Double) -> String {
  let thickness = misc_min(w, h) * 0.3
  let cx = w / 2.0
  let cy = h / 2.0
  let hw = thickness / 2.0
  "M " +
  fmt(cx - hw) +
  " 0 L " +
  fmt(cx + hw) +
  " 0 L " +
  fmt(cx + hw) +
  " " +
  fmt(cy - hw) +
  " L " +
  fmt(w) +
  " " +
  fmt(cy - hw) +
  " L " +
  fmt(w) +
  " " +
  fmt(cy + hw) +
  " L " +
  fmt(cx + hw) +
  " " +
  fmt(cy + hw) +
  " L " +
  fmt(cx + hw) +
  " " +
  fmt(h) +
  " L " +
  fmt(cx - hw) +
  " " +
  fmt(h) +
  " L " +
  fmt(cx - hw) +
  " " +
  fmt(cy + hw) +
  " L 0 " +
  fmt(cy + hw) +
  " L 0 " +
  fmt(cy - hw) +
  " L " +
  fmt(cx - hw) +
  " " +
  fmt(cy - hw) +
  " Z"
}

// ============================================================================
// bracketPair / bracePair — preset-shapes.ts:4775, 4790
// ============================================================================

///|
fn misc_bracket_pair(w : Double, h : Double, ctx : GuideContext) -> String {
  let depth = w * (ctx.get("adj").unwrap_or(16667.0) / 100000.0)
  let r = misc_min(depth, h / 4.0)
  misc_join([
    "M " +
    fmt(depth) +
    " 0 L " +
    fmt(r) +
    " 0 Q 0 0 0 " +
    fmt(r) +
    " L 0 " +
    fmt(h - r) +
    " Q 0 " +
    fmt(h) +
    " " +
    fmt(r) +
    " " +
    fmt(h) +
    " L " +
    fmt(depth) +
    " " +
    fmt(h) +
    " ",
    "M " +
    fmt(w - depth) +
    " 0 L " +
    fmt(w - r) +
    " 0 Q " +
    fmt(w) +
    " 0 " +
    fmt(w) +
    " " +
    fmt(r) +
    " L " +
    fmt(w) +
    " " +
    fmt(h - r) +
    " Q " +
    fmt(w) +
    " " +
    fmt(h) +
    " " +
    fmt(w - r) +
    " " +
    fmt(h) +
    " L " +
    fmt(w - depth) +
    " " +
    fmt(h),
  ])
}

///|
fn misc_brace_pair(w : Double, h : Double, ctx : GuideContext) -> String {
  let depth = w * (ctx.get("adj").unwrap_or(8333.0) / 100000.0)
  let mid_y = h / 2.0
  misc_join([
    "M " +
    fmt(depth) +
    " 0 Q 0 0 0 " +
    fmt(depth) +
    " L 0 " +
    fmt(mid_y - depth) +
    " Q 0 " +
    fmt(mid_y) +
    " " +
    fmt(-depth * 0.5) +
    " " +
    fmt(mid_y) +
    " Q 0 " +
    fmt(mid_y) +
    " 0 " +
    fmt(mid_y + depth) +
    " L 0 " +
    fmt(h - depth) +
    " Q 0 " +
    fmt(h) +
    " " +
    fmt(depth) +
    " " +
    fmt(h) +
    " ",
    "M " +
    fmt(w - depth) +
    " 0 Q " +
    fmt(w) +
    " 0 " +
    fmt(w) +
    " " +
    fmt(depth) +
    " L " +
    fmt(w) +
    " " +
    fmt(mid_y - depth) +
    " Q " +
    fmt(w) +
    " " +
    fmt(mid_y) +
    " " +
    fmt(w + depth * 0.5) +
    " " +
    fmt(mid_y) +
    " Q " +
    fmt(w) +
    " " +
    fmt(mid_y) +
    " " +
    fmt(w) +
    " " +
    fmt(mid_y + depth) +
    " L " +
    fmt(w) +
    " " +
    fmt(h - depth) +
    " Q " +
    fmt(w) +
    " " +
    fmt(h) +
    " " +
    fmt(w - depth) +
    " " +
    fmt(h),
  ])
}

// ============================================================================
// Dispatcher
// ============================================================================

///|
fn dispatch_misc(
  preset : String,
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String? {
  match preset {
    "lineInv" => Some(misc_line_inv(w, h))
    "round1Rect" => Some(misc_round1_rect(w, h, ctx))
    "round2SameRect" => Some(misc_round2_same_rect(w, h, ctx))
    "round2DiagRect" => Some(misc_round2_diag_rect(w, h, ctx))
    "snipRoundRect" => Some(misc_snip_round_rect(w, h, ctx))
    "snip1Rect" => Some(misc_snip1_rect(w, h, ctx))
    "snip2SameRect" => Some(misc_snip2_same_rect(w, h, ctx))
    "snip2DiagRect" => Some(misc_snip2_diag_rect(w, h, ctx))
    "nonIsoscelesTrapezoid" => Some(misc_non_isosceles_trapezoid(w, h, ctx))
    "heptagon" => Some(misc_regular_polygon(w, h, 7))
    "decagon" => Some(misc_regular_polygon(w, h, 10))
    "dodecagon" => Some(misc_regular_polygon(w, h, 12))
    "teardrop" => Some(misc_teardrop(w, h, ctx))
    "plaque" => Some(misc_plaque(w, h, ctx))
    "straightConnector1" => Some(misc_straight_connector1(w, h))
    "bentConnector2" => Some(misc_bent_connector2(w, h))
    "bentConnector3" => Some(misc_bent_connector3(w, h, ctx))
    "bentConnector4" => Some(misc_bent_connector4(w, h, ctx))
    "bentConnector5" => Some(misc_bent_connector5(w, h, ctx))
    "curvedConnector2" => Some(misc_curved_connector2(w, h))
    "curvedConnector3" => Some(misc_curved_connector3(w, h, ctx))
    "curvedConnector4" => Some(misc_curved_connector4(w, h, ctx))
    "curvedConnector5" => Some(misc_curved_connector5(w, h, ctx))
    "cloud" => Some(misc_cloud(w, h))
    "leftBrace" => Some(misc_left_brace(w, h, ctx))
    "rightBrace" => Some(misc_right_brace(w, h, ctx))
    "leftBracket" => Some(misc_left_bracket(w, h, ctx))
    "rightBracket" => Some(misc_right_bracket(w, h, ctx))
    "arc" => Some(misc_arc(w, h, ctx))
    "pie" => Some(misc_pie(w, h, ctx))
    "donut" => Some(misc_donut(w, h, ctx))
    "sun" => Some(misc_sun(w, h, ctx))
    "smileyFace" => Some(misc_smiley_face(w, h))
    "ribbon" => Some(misc_ribbon(w, h, ctx))
    "ribbon2" => Some(misc_ribbon2(w, h, ctx))
    "ellipseRibbon" => Some(misc_ellipse_ribbon(w, h, ctx))
    "ellipseRibbon2" => Some(misc_ellipse_ribbon2(w, h, ctx))
    "leftRightRibbon" => Some(misc_left_right_ribbon(w, h, ctx))
    "wave" => Some(misc_wave(w, h, ctx))
    "doubleWave" => Some(misc_double_wave(w, h, ctx))
    "pieWedge" => Some(misc_pie_wedge(w, h))
    "blockArc" => Some(misc_block_arc(w, h, ctx))
    "noSmoking" => Some(misc_no_smoking(w, h, ctx))
    "cube" => Some(misc_cube(w, h, ctx))
    "can" => Some(misc_can(w, h, ctx))
    "lightningBolt" => Some(misc_lightning_bolt(w, h))
    "heart" => Some(misc_heart(w, h))
    "moon" => Some(misc_moon(w, h, ctx))
    "irregularSeal1" => Some(misc_irregular_seal1(w, h))
    "irregularSeal2" => Some(misc_irregular_seal2(w, h))
    "foldedCorner" => Some(misc_folded_corner(w, h, ctx))
    "bevel" => Some(misc_bevel(w, h, ctx))
    "frame" => Some(misc_frame(w, h, ctx))
    "halfFrame" => Some(misc_half_frame(w, h, ctx))
    "corner" => Some(misc_corner(w, h, ctx))
    "diagStripe" => Some(misc_diag_stripe(w, h, ctx))
    "chord" => Some(misc_chord(w, h, ctx))
    "verticalScroll" => Some(misc_vertical_scroll(w, h, ctx))
    "horizontalScroll" => Some(misc_horizontal_scroll(w, h, ctx))
    "gear6" => Some(misc_gear(w, h, ctx, 6, 15000.0))
    "gear9" => Some(misc_gear(w, h, ctx, 9, 10000.0))
    "funnel" => Some(misc_funnel(w, h, ctx))
    "mathPlus" => Some(misc_math_plus(w, h, ctx))
    "mathMinus" => Some(misc_math_minus(w, h, ctx))
    "mathMultiply" => Some(misc_math_multiply(w, h, ctx))
    "mathDivide" => Some(misc_math_divide(w, h, ctx))
    "mathEqual" => Some(misc_math_equal(w, h, ctx))
    "mathNotEqual" => Some(misc_math_not_equal(w, h, ctx))
    "cornerTabs" => Some(misc_corner_tabs(w, h))
    "squareTabs" => Some(misc_square_tabs(w, h))
    "plaqueTabs" => Some(misc_plaque_tabs(w, h))
    "chartX" => Some(misc_chart_x(w, h))
    "chartStar" => Some(misc_chart_star(w, h))
    "chartPlus" => Some(misc_chart_plus(w, h))
    "bracketPair" => Some(misc_bracket_pair(w, h, ctx))
    "bracePair" => Some(misc_brace_pair(w, h, ctx))
    _ => None
  }
}
