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
  let dst : GuideContext = Map::new()
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
enum ArrowCmd {
  MoveTo(Double, Double)
  LineTo(Double, Double)
  QuadTo(Double, Double, Double, Double)
  ArcTo(Double, Double, Double, Double, Double, Double) // wR, hR, stAng, swAng, currentX, currentY
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
      QuadTo(qx, qy, x, y) => {
        cx = x
        cy = y
        segments.push(
          "Q " + fmt(qx) + " " + fmt(qy) + " " + fmt(x) + " " + fmt(y),
        )
      }
      ArcTo(w_r, h_r, st_ang, sw_ang, _, _) => {
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
// Dispatcher
// ============================================================================

///|
fn dispatch_arrow(
  preset : String,
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String? {
  match preset {
    "rightArrow" => Some(arrow_right_arrow(w, h, ctx))
    "leftArrow" => Some(arrow_left_arrow(w, h, ctx))
    "upArrow" => Some(arrow_up_arrow(w, h, ctx))
    "downArrow" => Some(arrow_down_arrow(w, h, ctx))
    "leftRightArrow" => Some(arrow_left_right_arrow(w, h, ctx))
    "upDownArrow" => Some(arrow_up_down_arrow(w, h, ctx))
    "stripedRightArrow" => Some(arrow_striped_right_arrow(w, h, ctx))
    "notchedRightArrow" => Some(arrow_notched_right_arrow(w, h, ctx))
    "bentUpArrow" => Some(arrow_bent_up_arrow(w, h, ctx))
    "bentArrow" => Some(arrow_bent_arrow(w, h, ctx))
    "leftUpArrow" => Some(arrow_left_up_arrow(w, h, ctx))
    "leftRightUpArrow" => Some(arrow_left_right_up_arrow(w, h, ctx))
    "quadArrow" => Some(arrow_quad_arrow(w, h, ctx))
    "leftArrowCallout" => Some(arrow_left_arrow_callout(w, h, ctx))
    "rightArrowCallout" => Some(arrow_right_arrow_callout(w, h, ctx))
    "upArrowCallout" => Some(arrow_up_arrow_callout(w, h, ctx))
    "downArrowCallout" => Some(arrow_down_arrow_callout(w, h, ctx))
    "leftRightArrowCallout" => Some(arrow_left_right_arrow_callout(w, h, ctx))
    "upDownArrowCallout" => Some(arrow_up_down_arrow_callout(w, h, ctx))
    "quadArrowCallout" => Some(arrow_quad_arrow_callout(w, h, ctx))
    "uturnArrow" => Some(arrow_uturn_arrow(w, h, ctx))
    "circularArrow" => Some(arrow_circular_arrow(w, h, ctx))
    "leftCircularArrow" => Some(arrow_left_circular_arrow(w, h, ctx))
    "leftRightCircularArrow" => Some(arrow_left_right_circular_arrow(w, h, ctx))
    "curvedRightArrow" => Some(arrow_curved_right_arrow(w, h, ctx))
    "curvedLeftArrow" => Some(arrow_curved_left_arrow(w, h, ctx))
    "curvedUpArrow" => Some(arrow_curved_up_arrow(w, h, ctx))
    "curvedDownArrow" => Some(arrow_curved_down_arrow(w, h, ctx))
    "swooshArrow" => Some(arrow_swoosh_arrow(w, h, ctx))
    "chevron" => Some(arrow_chevron(w, h, ctx))
    "homePlate" => Some(arrow_home_plate(w, h, ctx))
    _ => None
  }
}

// ============================================================================
// Individual arrow generators — one per preset, ordered to match
// `preset-shapes.ts` definition order where practical.
// ============================================================================

///|
/// `rightArrow` — preset-shapes.ts:19
fn arrow_right_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(50000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 100000 w ss" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "dx1", formula: "*/ ss a2 100000" },
    { name: "x1", formula: "+- r 0 dx1" },
    { name: "dy1", formula: "*/ h a1 200000" },
    { name: "y1", formula: "+- vc 0 dy1" },
    { name: "y2", formula: "+- vc dy1 0" },
    { name: "dx2", formula: "*/ y1 dx1 hd2" },
    { name: "x2", formula: "+- x1 dx2 0" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let vc = g(local, "vc")
  let x1 = g(local, "x1")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  "M " +
  fmt(l) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x1) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x1) +
  " " +
  fmt(b) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y2) +
  " L " +
  fmt(l) +
  " " +
  fmt(y2) +
  " Z"
}

///|
/// `downArrow` — preset-shapes.ts:64
fn arrow_down_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(50000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 100000 h ss" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "dy1", formula: "*/ ss a2 100000" },
    { name: "y1", formula: "+- b 0 dy1" },
    { name: "dx1", formula: "*/ w a1 200000" },
    { name: "x1", formula: "+- hc 0 dx1" },
    { name: "x2", formula: "+- hc dx1 0" },
    { name: "dy2", formula: "*/ x1 dy1 wd2" },
    { name: "y2", formula: "+- y1 dy2 0" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let hc = g(local, "hc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let y1 = g(local, "y1")
  "M " +
  fmt(l) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x1) +
  " " +
  fmt(t) +
  " L " +
  fmt(x2) +
  " " +
  fmt(t) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y1) +
  " L " +
  fmt(r) +
  " " +
  fmt(y1) +
  " L " +
  fmt(hc) +
  " " +
  fmt(b) +
  " Z"
}

///|
/// `upArrow` — TS source has no `renderUpArrowPath`; this is the
/// canonical ECMA-376 §20.1.10.56 upArrow definition (mirror of
/// downArrow across the horizontal midline).
fn arrow_up_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(50000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 100000 h ss" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "dy2", formula: "*/ ss a2 100000" },
    { name: "y2", formula: "+- t dy2 0" },
    { name: "dx1", formula: "*/ w a1 200000" },
    { name: "x1", formula: "+- hc 0 dx1" },
    { name: "x2", formula: "+- hc dx1 0" },
    { name: "dx2", formula: "*/ x1 dy2 wd2" },
    { name: "y1", formula: "+- y2 0 dx2" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let hc = g(local, "hc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let y2 = g(local, "y2")
  "M " +
  fmt(l) +
  " " +
  fmt(y2) +
  " L " +
  fmt(hc) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(b) +
  " L " +
  fmt(x1) +
  " " +
  fmt(b) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y2) +
  " Z"
}

///|
/// `leftArrow` — preset-shapes.ts:109
fn arrow_left_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(50000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 100000 w ss" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "dx2", formula: "*/ ss a2 100000" },
    { name: "x2", formula: "+- l dx2 0" },
    { name: "dy1", formula: "*/ h a1 200000" },
    { name: "y1", formula: "+- vc 0 dy1" },
    { name: "y2", formula: "+- vc dy1 0" },
    { name: "dx1", formula: "*/ y1 dx2 hd2" },
    { name: "x1", formula: "+- x2 0 dx1" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let vc = g(local, "vc")
  let x2 = g(local, "x2")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  "M " +
  fmt(l) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x2) +
  " " +
  fmt(t) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y1) +
  " L " +
  fmt(r) +
  " " +
  fmt(y1) +
  " L " +
  fmt(r) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(b) +
  " Z"
}

///|
/// `leftRightArrow` — preset-shapes.ts:154
fn arrow_left_right_arrow(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(50000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 w ss" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "x2", formula: "*/ ss a2 100000" },
    { name: "x3", formula: "+- r 0 x2" },
    { name: "dy", formula: "*/ h a1 200000" },
    { name: "y1", formula: "+- vc 0 dy" },
    { name: "y2", formula: "+- vc dy 0" },
    { name: "dx1", formula: "*/ y1 x2 hd2" },
    { name: "x1", formula: "+- x2 0 dx1" },
    { name: "x4", formula: "+- x3 dx1 0" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let vc = g(local, "vc")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  "M " +
  fmt(l) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x2) +
  " " +
  fmt(t) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x3) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x3) +
  " " +
  fmt(b) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(b) +
  " Z"
}

///|
/// `upDownArrow` — preset-shapes.ts:202
fn arrow_up_down_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(50000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 h ss" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "y2", formula: "*/ ss a2 100000" },
    { name: "y3", formula: "+- b 0 y2" },
    { name: "dx1", formula: "*/ w a1 200000" },
    { name: "x1", formula: "+- hc 0 dx1" },
    { name: "x2", formula: "+- hc dx1 0" },
    { name: "dy1", formula: "*/ x1 y2 wd2" },
    { name: "y1", formula: "+- y2 0 dy1" },
    { name: "y4", formula: "+- y3 dy1 0" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let hc = g(local, "hc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let y2 = g(local, "y2")
  let y3 = g(local, "y3")
  "M " +
  fmt(l) +
  " " +
  fmt(y2) +
  " L " +
  fmt(hc) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y3) +
  " L " +
  fmt(r) +
  " " +
  fmt(y3) +
  " L " +
  fmt(hc) +
  " " +
  fmt(b) +
  " L " +
  fmt(l) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y2) +
  " Z"
}

///|
/// `stripedRightArrow` — preset-shapes.ts:2604
fn arrow_striped_right_arrow(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(50000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 84375 w ss" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "x4", formula: "*/ ss 5 32" },
    { name: "dx5", formula: "*/ ss a2 100000" },
    { name: "x5", formula: "+- r 0 dx5" },
    { name: "dy1", formula: "*/ h a1 200000" },
    { name: "y1", formula: "+- vc 0 dy1" },
    { name: "y2", formula: "+- vc dy1 0" },
    { name: "dx6", formula: "*/ dy1 dx5 hd2" },
    { name: "x6", formula: "+- r 0 dx6" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let vc = g(local, "vc")
  let ssd32 = g(local, "ssd32")
  let ssd16 = g(local, "ssd16")
  let ssd8 = g(local, "ssd8")
  let x4 = g(local, "x4")
  let x5 = g(local, "x5")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  "M " +
  fmt(l) +
  " " +
  fmt(y1) +
  " L " +
  fmt(ssd32) +
  " " +
  fmt(y1) +
  " L " +
  fmt(ssd32) +
  " " +
  fmt(y2) +
  " L " +
  fmt(l) +
  " " +
  fmt(y2) +
  " Z " +
  "M " +
  fmt(ssd16) +
  " " +
  fmt(y1) +
  " L " +
  fmt(ssd8) +
  " " +
  fmt(y1) +
  " L " +
  fmt(ssd8) +
  " " +
  fmt(y2) +
  " L " +
  fmt(ssd16) +
  " " +
  fmt(y2) +
  " Z " +
  "M " +
  fmt(x4) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x5) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x5) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x5) +
  " " +
  fmt(b) +
  " L " +
  fmt(x5) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y2) +
  " Z"
}

///|
/// `notchedRightArrow` — preset-shapes.ts:644
fn arrow_notched_right_arrow(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(50000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 100000 w ss" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "dx2", formula: "*/ ss a2 100000" },
    { name: "x2", formula: "+- r 0 dx2" },
    { name: "dy1", formula: "*/ h a1 200000" },
    { name: "y1", formula: "+- vc 0 dy1" },
    { name: "y2", formula: "+- vc dy1 0" },
    { name: "x1", formula: "*/ dy1 dx2 hd2" },
    { name: "x3", formula: "+- r 0 x1" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let vc = g(local, "vc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  "M " +
  fmt(l) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x2) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x2) +
  " " +
  fmt(b) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(l) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x1) +
  " " +
  fmt(vc) +
  " Z"
}

///|
/// `chevron` — preset-shapes.ts:2689
fn arrow_chevron(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(50000.0)
  let point = w * (adj / 100000.0)
  "M 0 0 L " +
  fmt(w - point) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h / 2.0) +
  " L " +
  fmt(w - point) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " L " +
  fmt(point) +
  " " +
  fmt(h / 2.0) +
  " Z"
}

///|
/// `homePlate` — preset-shapes.ts:2699
fn arrow_home_plate(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(50000.0)
  let point = w * (adj / 100000.0)
  "M 0 0 L " +
  fmt(w - point) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h / 2.0) +
  " L " +
  fmt(w - point) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `leftArrowCallout` — preset-shapes.ts:250
fn arrow_left_arrow_callout(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  let adj4 = ctx.get("adj4").unwrap_or(64977.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 h ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "maxAdj3", formula: "*/ 100000 w ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "q2", formula: "*/ a3 ss w" },
    { name: "maxAdj4", formula: "+- 100000 0 q2" },
    { name: "a4", formula: "pin 0 adj4 maxAdj4" },
    { name: "dy1", formula: "*/ ss a2 100000" },
    { name: "dy2", formula: "*/ ss a1 200000" },
    { name: "y1", formula: "+- vc 0 dy1" },
    { name: "y2", formula: "+- vc 0 dy2" },
    { name: "y3", formula: "+- vc dy2 0" },
    { name: "y4", formula: "+- vc dy1 0" },
    { name: "x1", formula: "*/ ss a3 100000" },
    { name: "dx2", formula: "*/ w a4 100000" },
    { name: "x2", formula: "+- r 0 dx2" },
    { name: "x3", formula: "+/ x2 r 2" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let vc = g(local, "vc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  let y3 = g(local, "y3")
  let y4 = g(local, "y4")
  "M " +
  fmt(l) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(b) +
  " L " +
  fmt(x2) +
  " " +
  fmt(b) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y4) +
  " Z"
}

///|
/// `rightArrowCallout` — preset-shapes.ts:314
fn arrow_right_arrow_callout(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  let adj4 = ctx.get("adj4").unwrap_or(64977.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 h ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "maxAdj3", formula: "*/ 100000 w ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "q2", formula: "*/ a3 ss w" },
    { name: "maxAdj4", formula: "+- 100000 0 q2" },
    { name: "a4", formula: "pin 0 adj4 maxAdj4" },
    { name: "dy1", formula: "*/ ss a2 100000" },
    { name: "dy2", formula: "*/ ss a1 200000" },
    { name: "y1", formula: "+- vc 0 dy1" },
    { name: "y2", formula: "+- vc 0 dy2" },
    { name: "y3", formula: "+- vc dy2 0" },
    { name: "y4", formula: "+- vc dy1 0" },
    { name: "dx3", formula: "*/ ss a3 100000" },
    { name: "x3", formula: "+- r 0 dx3" },
    { name: "x2", formula: "*/ w a4 100000" },
    { name: "x1", formula: "*/ x2 1 2" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let vc = g(local, "vc")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  let y3 = g(local, "y3")
  let y4 = g(local, "y4")
  "M " +
  fmt(l) +
  " " +
  fmt(t) +
  " L " +
  fmt(x2) +
  " " +
  fmt(t) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y1) +
  " L " +
  fmt(r) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x2) +
  " " +
  fmt(b) +
  " L " +
  fmt(l) +
  " " +
  fmt(b) +
  " Z"
}

///|
/// `upArrowCallout` — preset-shapes.ts:378
fn arrow_up_arrow_callout(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  let adj4 = ctx.get("adj4").unwrap_or(64977.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 w ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "maxAdj3", formula: "*/ 100000 h ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "q2", formula: "*/ a3 ss h" },
    { name: "maxAdj4", formula: "+- 100000 0 q2" },
    { name: "a4", formula: "pin 0 adj4 maxAdj4" },
    { name: "dx1", formula: "*/ ss a2 100000" },
    { name: "dx2", formula: "*/ ss a1 200000" },
    { name: "x1", formula: "+- hc 0 dx1" },
    { name: "x2", formula: "+- hc 0 dx2" },
    { name: "x3", formula: "+- hc dx2 0" },
    { name: "x4", formula: "+- hc dx1 0" },
    { name: "y1", formula: "*/ ss a3 100000" },
    { name: "dy2", formula: "*/ h a4 100000" },
    { name: "y2", formula: "+- b 0 dy2" },
    { name: "y3", formula: "+/ y2 b 2" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let hc = g(local, "hc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  "M " +
  fmt(l) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " L " +
  fmt(hc) +
  " " +
  fmt(t) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y2) +
  " L " +
  fmt(r) +
  " " +
  fmt(y2) +
  " L " +
  fmt(r) +
  " " +
  fmt(b) +
  " L " +
  fmt(l) +
  " " +
  fmt(b) +
  " Z"
}

///|
/// `downArrowCallout` — preset-shapes.ts:442
fn arrow_down_arrow_callout(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  let adj4 = ctx.get("adj4").unwrap_or(64977.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 w ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "maxAdj3", formula: "*/ 100000 h ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "q2", formula: "*/ a3 ss h" },
    { name: "maxAdj4", formula: "+- 100000 0 q2" },
    { name: "a4", formula: "pin 0 adj4 maxAdj4" },
    { name: "dx1", formula: "*/ ss a2 100000" },
    { name: "dx2", formula: "*/ ss a1 200000" },
    { name: "x1", formula: "+- hc 0 dx1" },
    { name: "x2", formula: "+- hc 0 dx2" },
    { name: "x3", formula: "+- hc dx2 0" },
    { name: "x4", formula: "+- hc dx1 0" },
    { name: "dy3", formula: "*/ ss a3 100000" },
    { name: "y3", formula: "+- b 0 dy3" },
    { name: "y2", formula: "*/ h a4 100000" },
    { name: "y1", formula: "*/ y2 1 2" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let hc = g(local, "hc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let y2 = g(local, "y2")
  let y3 = g(local, "y3")
  "M " +
  fmt(l) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y3) +
  " L " +
  fmt(hc) +
  " " +
  fmt(b) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(l) +
  " " +
  fmt(y2) +
  " Z"
}

///|
/// `leftRightArrowCallout` — preset-shapes.ts:506
fn arrow_left_right_arrow_callout(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  let adj4 = ctx.get("adj4").unwrap_or(48123.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 h ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "maxAdj3", formula: "*/ 50000 w ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "q2", formula: "*/ a3 ss wd2" },
    { name: "maxAdj4", formula: "+- 100000 0 q2" },
    { name: "a4", formula: "pin 0 adj4 maxAdj4" },
    { name: "dy1", formula: "*/ ss a2 100000" },
    { name: "dy2", formula: "*/ ss a1 200000" },
    { name: "y1", formula: "+- vc 0 dy1" },
    { name: "y2", formula: "+- vc 0 dy2" },
    { name: "y3", formula: "+- vc dy2 0" },
    { name: "y4", formula: "+- vc dy1 0" },
    { name: "x1", formula: "*/ ss a3 100000" },
    { name: "x4", formula: "+- r 0 x1" },
    { name: "dx2", formula: "*/ w a4 200000" },
    { name: "x2", formula: "+- hc 0 dx2" },
    { name: "x3", formula: "+- hc dx2 0" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let vc = g(local, "vc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  let y3 = g(local, "y3")
  let y4 = g(local, "y4")
  "M " +
  fmt(l) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(t) +
  " L " +
  fmt(x3) +
  " " +
  fmt(t) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y1) +
  " L " +
  fmt(r) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x3) +
  " " +
  fmt(b) +
  " L " +
  fmt(x2) +
  " " +
  fmt(b) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y4) +
  " Z"
}

///|
/// `upDownArrowCallout` — preset-shapes.ts:575
fn arrow_up_down_arrow_callout(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  let adj4 = ctx.get("adj4").unwrap_or(48123.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 w ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "maxAdj3", formula: "*/ 50000 h ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "q2", formula: "*/ a3 ss hd2" },
    { name: "maxAdj4", formula: "+- 100000 0 q2" },
    { name: "a4", formula: "pin 0 adj4 maxAdj4" },
    { name: "dx1", formula: "*/ ss a2 100000" },
    { name: "dx2", formula: "*/ ss a1 200000" },
    { name: "x1", formula: "+- hc 0 dx1" },
    { name: "x2", formula: "+- hc 0 dx2" },
    { name: "x3", formula: "+- hc dx2 0" },
    { name: "x4", formula: "+- hc dx1 0" },
    { name: "y1", formula: "*/ ss a3 100000" },
    { name: "y4", formula: "+- b 0 y1" },
    { name: "dy2", formula: "*/ h a4 200000" },
    { name: "y2", formula: "+- vc 0 dy2" },
    { name: "y3", formula: "+- vc dy2 0" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let hc = g(local, "hc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  let y3 = g(local, "y3")
  let y4 = g(local, "y4")
  "M " +
  fmt(l) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " L " +
  fmt(hc) +
  " " +
  fmt(t) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y2) +
  " L " +
  fmt(r) +
  " " +
  fmt(y2) +
  " L " +
  fmt(r) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y4) +
  " L " +
  fmt(hc) +
  " " +
  fmt(b) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y3) +
  " L " +
  fmt(l) +
  " " +
  fmt(y3) +
  " Z"
}

///|
/// `quadArrowCallout` — preset-shapes.ts:691
fn arrow_quad_arrow_callout(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(18515.0)
  let adj2 = ctx.get("adj2").unwrap_or(18515.0)
  let adj3 = ctx.get("adj3").unwrap_or(18515.0)
  let adj4 = ctx.get("adj4").unwrap_or(48123.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  let guides : Array[GuideEntry] = [
    { name: "a2", formula: "pin 0 adj2 50000" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "maxAdj3", formula: "+- 50000 0 a2" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "q2", formula: "*/ a3 2 1" },
    { name: "maxAdj4", formula: "+- 100000 0 q2" },
    { name: "a4", formula: "pin a1 adj4 maxAdj4" },
    { name: "dx2", formula: "*/ ss a2 100000" },
    { name: "dx3", formula: "*/ ss a1 200000" },
    { name: "ah", formula: "*/ ss a3 100000" },
    { name: "dx1", formula: "*/ w a4 200000" },
    { name: "dy1", formula: "*/ h a4 200000" },
    { name: "x8", formula: "+- r 0 ah" },
    { name: "x2", formula: "+- hc 0 dx1" },
    { name: "x7", formula: "+- hc dx1 0" },
    { name: "x3", formula: "+- hc 0 dx2" },
    { name: "x6", formula: "+- hc dx2 0" },
    { name: "x4", formula: "+- hc 0 dx3" },
    { name: "x5", formula: "+- hc dx3 0" },
    { name: "y8", formula: "+- b 0 ah" },
    { name: "y2", formula: "+- vc 0 dy1" },
    { name: "y7", formula: "+- vc dy1 0" },
    { name: "y3", formula: "+- vc 0 dx2" },
    { name: "y6", formula: "+- vc dx2 0" },
    { name: "y4", formula: "+- vc 0 dx3" },
    { name: "y5", formula: "+- vc dx3 0" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let hc = g(local, "hc")
  let vc = g(local, "vc")
  let ah = g(local, "ah")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let x5 = g(local, "x5")
  let x6 = g(local, "x6")
  let x7 = g(local, "x7")
  let x8 = g(local, "x8")
  let y2 = g(local, "y2")
  let y3 = g(local, "y3")
  let y4 = g(local, "y4")
  let y5 = g(local, "y5")
  let y6 = g(local, "y6")
  let y7 = g(local, "y7")
  let y8 = g(local, "y8")
  "M " +
  fmt(l) +
  " " +
  fmt(vc) +
  " L " +
  fmt(ah) +
  " " +
  fmt(y3) +
  " L " +
  fmt(ah) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x4) +
  " " +
  fmt(ah) +
  " L " +
  fmt(x3) +
  " " +
  fmt(ah) +
  " L " +
  fmt(hc) +
  " " +
  fmt(t) +
  " L " +
  fmt(x6) +
  " " +
  fmt(ah) +
  " L " +
  fmt(x5) +
  " " +
  fmt(ah) +
  " L " +
  fmt(x5) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x7) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x7) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x8) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x8) +
  " " +
  fmt(y3) +
  " L " +
  fmt(r) +
  " " +
  fmt(vc) +
  " L " +
  fmt(x8) +
  " " +
  fmt(y6) +
  " L " +
  fmt(x8) +
  " " +
  fmt(y5) +
  " L " +
  fmt(x7) +
  " " +
  fmt(y5) +
  " L " +
  fmt(x7) +
  " " +
  fmt(y7) +
  " L " +
  fmt(x5) +
  " " +
  fmt(y7) +
  " L " +
  fmt(x5) +
  " " +
  fmt(y8) +
  " L " +
  fmt(x6) +
  " " +
  fmt(y8) +
  " L " +
  fmt(hc) +
  " " +
  fmt(b) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y8) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y8) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y7) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y7) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y5) +
  " L " +
  fmt(ah) +
  " " +
  fmt(y5) +
  " L " +
  fmt(ah) +
  " " +
  fmt(y6) +
  " Z"
}

///|
/// `bentArrow` — preset-shapes.ts:783
fn arrow_bent_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  let adj4 = ctx.get("adj4").unwrap_or(43750.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  let guides : Array[GuideEntry] = [
    { name: "a2", formula: "pin 0 adj2 50000" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "a3", formula: "pin 0 adj3 50000" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw2", formula: "*/ ss a2 100000" },
    { name: "th2", formula: "*/ th 1 2" },
    { name: "dh2", formula: "+- aw2 0 th2" },
    { name: "ah", formula: "*/ ss a3 100000" },
    { name: "bw", formula: "+- r 0 ah" },
    { name: "bh", formula: "+- b 0 dh2" },
    { name: "bs", formula: "min bw bh" },
    { name: "maxAdj4", formula: "*/ 100000 bs ss" },
    { name: "a4", formula: "pin 0 adj4 maxAdj4" },
    { name: "bd", formula: "*/ ss a4 100000" },
    { name: "bd3", formula: "+- bd 0 th" },
    { name: "bd2", formula: "max bd3 0" },
    { name: "x3", formula: "+- th bd2 0" },
    { name: "x4", formula: "+- r 0 ah" },
    { name: "y3", formula: "+- dh2 th 0" },
    { name: "y4", formula: "+- y3 dh2 0" },
    { name: "y5", formula: "+- dh2 bd 0" },
    { name: "y6", formula: "+- y3 bd2 0" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let th = g(local, "th")
  let aw2 = g(local, "aw2")
  let bd = g(local, "bd")
  let bd2 = g(local, "bd2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let y3 = g(local, "y3")
  let y4 = g(local, "y4")
  let y5 = g(local, "y5")
  let y6 = g(local, "y6")
  "M " +
  fmt(l) +
  " " +
  fmt(b) +
  " L " +
  fmt(l) +
  " " +
  fmt(y5) +
  " A " +
  fmt(bd) +
  " " +
  fmt(bd) +
  " 0 0 1 " +
  fmt(bd) +
  " " +
  fmt(y6) +
  " L " +
  fmt(x4) +
  " " +
  fmt(aw2) +
  " L " +
  fmt(x4) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(aw2) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y3) +
  " L " +
  fmt(x3) +
  " " +
  fmt(y3) +
  " A " +
  fmt(bd2) +
  " " +
  fmt(bd2) +
  " 0 0 0 " +
  fmt(th) +
  " " +
  fmt(y6) +
  " L " +
  fmt(th) +
  " " +
  fmt(b) +
  " Z"
}

///|
/// `bentUpArrow` — preset-shapes.ts:857
fn arrow_bent_up_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "a1", formula: "pin 0 adj1 50000" },
    { name: "a2", formula: "pin 0 adj2 50000" },
    { name: "a3", formula: "pin 0 adj3 50000" },
    { name: "y1", formula: "*/ ss a3 100000" },
    { name: "dx1", formula: "*/ ss a2 50000" },
    { name: "x1", formula: "+- r 0 dx1" },
    { name: "dx3", formula: "*/ ss a2 100000" },
    { name: "x3", formula: "+- r 0 dx3" },
    { name: "dx2", formula: "*/ ss a1 200000" },
    { name: "x2", formula: "+- x3 0 dx2" },
    { name: "x4", formula: "+- x3 dx2 0" },
    { name: "dy2", formula: "*/ ss a1 100000" },
    { name: "y2", formula: "+- b 0 dy2" },
    { name: "x0", formula: "*/ x4 1 2" },
    { name: "y3", formula: "+/ y2 b 2" },
    { name: "y15", formula: "+/ y1 b 2" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let y1 = g(local, "y1")
  let y2 = g(local, "y2")
  "M " +
  fmt(l) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x3) +
  " " +
  fmt(t) +
  " L " +
  fmt(r) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x4) +
  " " +
  fmt(y1) +
  " L " +
  fmt(x4) +
  " " +
  fmt(b) +
  " L " +
  fmt(l) +
  " " +
  fmt(b) +
  " Z"
}

///|
/// `uturnArrow` — preset-shapes.ts:914
fn arrow_uturn_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  let adj4 = ctx.get("adj4").unwrap_or(43750.0)
  let adj5 = ctx.get("adj5").unwrap_or(75000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  local["adj5"] = adj5
  let guides : Array[GuideEntry] = [
    { name: "a2", formula: "pin 0 adj2 25000" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "q2", formula: "*/ a1 ss h" },
    { name: "q3", formula: "+- 100000 0 q2" },
    { name: "maxAdj3", formula: "*/ q3 h ss" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "q1", formula: "+- a3 a1 0" },
    { name: "minAdj5", formula: "*/ q1 ss h" },
    { name: "a5", formula: "pin minAdj5 adj5 100000" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw2", formula: "*/ ss a2 100000" },
    { name: "th2", formula: "*/ th 1 2" },
    { name: "dh2", formula: "+- aw2 0 th2" },
    { name: "y5", formula: "*/ h a5 100000" },
    { name: "ah", formula: "*/ ss a3 100000" },
    { name: "y4", formula: "+- y5 0 ah" },
    { name: "x9", formula: "+- r 0 dh2" },
    { name: "bw", formula: "*/ x9 1 2" },
    { name: "bs", formula: "min bw y4" },
    { name: "maxAdj4", formula: "*/ bs 100000 ss" },
    { name: "a4", formula: "pin 0 adj4 maxAdj4" },
    { name: "bd", formula: "*/ ss a4 100000" },
    { name: "bd3", formula: "+- bd 0 th" },
    { name: "bd2", formula: "max bd3 0" },
    { name: "x3", formula: "+- th bd2 0" },
    { name: "x8", formula: "+- r 0 aw2" },
    { name: "x6", formula: "+- x8 0 aw2" },
    { name: "x7", formula: "+- x6 dh2 0" },
    { name: "x4", formula: "+- x9 0 bd" },
    { name: "x5", formula: "+- x7 0 bd2" },
    { name: "cx", formula: "+/ th x7 2" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let th = g(local, "th")
  let bd = g(local, "bd")
  let bd2 = g(local, "bd2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let x6 = g(local, "x6")
  let x7 = g(local, "x7")
  let x8 = g(local, "x8")
  let x9 = g(local, "x9")
  let y4 = g(local, "y4")
  let y5 = g(local, "y5")
  "M " +
  fmt(l) +
  " " +
  fmt(b) +
  " L " +
  fmt(l) +
  " " +
  fmt(bd) +
  " A " +
  fmt(bd) +
  " " +
  fmt(bd) +
  " 0 0 1 " +
  fmt(bd) +
  " " +
  fmt(t) +
  " L " +
  fmt(x4) +
  " " +
  fmt(t) +
  " A " +
  fmt(bd) +
  " " +
  fmt(bd) +
  " 0 0 1 " +
  fmt(x9) +
  " " +
  fmt(y4) +
  " L " +
  fmt(r) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x8) +
  " " +
  fmt(y5) +
  " L " +
  fmt(x6) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x7) +
  " " +
  fmt(y4) +
  " L " +
  fmt(x7) +
  " " +
  fmt(x3) +
  " A " +
  fmt(bd2) +
  " " +
  fmt(bd2) +
  " 0 0 0 " +
  fmt(x3) +
  " " +
  fmt(th) +
  " A " +
  fmt(bd2) +
  " " +
  fmt(bd2) +
  " 0 0 0 " +
  fmt(th) +
  " " +
  fmt(b) +
  " Z"
}

///|
/// `leftUpArrow` — preset-shapes.ts:1074
fn arrow_left_up_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "a2", formula: "pin 0 adj2 50000" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "maxAdj3", formula: "+- 100000 0 maxAdj1" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "x1", formula: "*/ ss a3 100000" },
    { name: "dx2", formula: "*/ ss a2 50000" },
    { name: "x2", formula: "+- r 0 dx2" },
    { name: "y2", formula: "+- b 0 dx2" },
    { name: "dx4", formula: "*/ ss a2 100000" },
    { name: "x4", formula: "+- r 0 dx4" },
    { name: "y4", formula: "+- b 0 dx4" },
    { name: "dx3", formula: "*/ ss a1 200000" },
    { name: "x3", formula: "+- x4 0 dx3" },
    { name: "x5", formula: "+- x4 dx3 0" },
    { name: "y3", formula: "+- y4 0 dx3" },
    { name: "y5", formula: "+- y4 dx3 0" },
    { name: "il", formula: "*/ dx3 x1 dx4" },
    { name: "cx1", formula: "+/ x1 x5 2" },
    { name: "cy1", formula: "+/ x1 y5 2" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let x5 = g(local, "x5")
  let y2 = g(local, "y2")
  let y3 = g(local, "y3")
  let y4 = g(local, "y4")
  let y5 = g(local, "y5")
  build_arrow_path([
    MoveTo(l, y4),
    LineTo(x1, y2),
    LineTo(x1, y3),
    LineTo(x3, y3),
    LineTo(x3, x1),
    LineTo(x2, x1),
    LineTo(x4, t),
    LineTo(r, x1),
    LineTo(x5, x1),
    LineTo(x5, y5),
    LineTo(x1, y5),
    LineTo(x1, b),
    Close,
  ])
}

///|
/// `leftRightUpArrow` — preset-shapes.ts:1130
fn arrow_left_right_up_arrow(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(25000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "a2", formula: "pin 0 adj2 50000" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "q1", formula: "+- 100000 0 maxAdj1" },
    { name: "maxAdj3", formula: "*/ q1 1 2" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "x1", formula: "*/ ss a3 100000" },
    { name: "dx2", formula: "*/ ss a2 100000" },
    { name: "x2", formula: "+- hc 0 dx2" },
    { name: "x5", formula: "+- hc dx2 0" },
    { name: "dx3", formula: "*/ ss a1 200000" },
    { name: "x3", formula: "+- hc 0 dx3" },
    { name: "x4", formula: "+- hc dx3 0" },
    { name: "x6", formula: "+- r 0 x1" },
    { name: "dy2", formula: "*/ ss a2 50000" },
    { name: "y2", formula: "+- b 0 dy2" },
    { name: "y4", formula: "+- b 0 dx2" },
    { name: "y3", formula: "+- y4 0 dx3" },
    { name: "y5", formula: "+- y4 dx3 0" },
    { name: "il", formula: "*/ dx3 x1 dx2" },
    { name: "ir", formula: "+- r 0 il" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let hc = g(local, "hc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let x5 = g(local, "x5")
  let x6 = g(local, "x6")
  let y2 = g(local, "y2")
  let y3 = g(local, "y3")
  let y4 = g(local, "y4")
  let y5 = g(local, "y5")
  build_arrow_path([
    MoveTo(l, y4),
    LineTo(x1, y2),
    LineTo(x1, y3),
    LineTo(x3, y3),
    LineTo(x3, x1),
    LineTo(x2, x1),
    LineTo(hc, t),
    LineTo(x5, x1),
    LineTo(x4, x1),
    LineTo(x4, y3),
    LineTo(x6, y3),
    LineTo(x6, y2),
    LineTo(r, y4),
    LineTo(x6, b),
    LineTo(x6, y5),
    LineTo(x1, y5),
    LineTo(x1, b),
    Close,
  ])
}

///|
/// `quadArrow` — preset-shapes.ts:1192
fn arrow_quad_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(22500.0)
  let adj2 = ctx.get("adj2").unwrap_or(22500.0)
  let adj3 = ctx.get("adj3").unwrap_or(22500.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "a2", formula: "pin 0 adj2 50000" },
    { name: "maxAdj1", formula: "*/ a2 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "q1", formula: "+- 100000 0 maxAdj1" },
    { name: "maxAdj3", formula: "*/ q1 1 2" },
    { name: "a3", formula: "pin 0 adj3 maxAdj3" },
    { name: "x1", formula: "*/ ss a3 100000" },
    { name: "dx2", formula: "*/ ss a2 100000" },
    { name: "x2", formula: "+- hc 0 dx2" },
    { name: "x5", formula: "+- hc dx2 0" },
    { name: "dx3", formula: "*/ ss a1 200000" },
    { name: "x3", formula: "+- hc 0 dx3" },
    { name: "x4", formula: "+- hc dx3 0" },
    { name: "x6", formula: "+- r 0 x1" },
    { name: "y2", formula: "+- vc 0 dx2" },
    { name: "y5", formula: "+- vc dx2 0" },
    { name: "y3", formula: "+- vc 0 dx3" },
    { name: "y4", formula: "+- vc dx3 0" },
    { name: "y6", formula: "+- b 0 x1" },
    { name: "il", formula: "*/ dx3 x1 dx2" },
    { name: "ir", formula: "+- r 0 il" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let hc = g(local, "hc")
  let vc = g(local, "vc")
  let x1 = g(local, "x1")
  let x2 = g(local, "x2")
  let x3 = g(local, "x3")
  let x4 = g(local, "x4")
  let x5 = g(local, "x5")
  let x6 = g(local, "x6")
  let y2 = g(local, "y2")
  let y3 = g(local, "y3")
  let y4 = g(local, "y4")
  let y5 = g(local, "y5")
  let y6 = g(local, "y6")
  build_arrow_path([
    MoveTo(l, vc),
    LineTo(x1, y2),
    LineTo(x1, y3),
    LineTo(x3, y3),
    LineTo(x3, x1),
    LineTo(x2, x1),
    LineTo(hc, t),
    LineTo(x5, x1),
    LineTo(x4, x1),
    LineTo(x4, y3),
    LineTo(x6, y3),
    LineTo(x6, y2),
    LineTo(r, vc),
    LineTo(x6, y5),
    LineTo(x6, y4),
    LineTo(x4, y4),
    LineTo(x4, y6),
    LineTo(x5, y6),
    LineTo(hc, b),
    LineTo(x2, y6),
    LineTo(x3, y6),
    LineTo(x3, y4),
    LineTo(x1, y4),
    LineTo(x1, y5),
    Close,
  ])
}

///|
/// `circularArrow` — preset-shapes.ts:1261
fn arrow_circular_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(12500.0)
  let adj2 = ctx.get("adj2").unwrap_or(1142319.0)
  let adj3 = ctx.get("adj3").unwrap_or(20457681.0)
  let adj4 = ctx.get("adj4").unwrap_or(10800000.0)
  let adj5 = ctx.get("adj5").unwrap_or(12500.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  local["adj5"] = adj5
  let guides : Array[GuideEntry] = [
    { name: "a5", formula: "pin 0 adj5 25000" },
    { name: "maxAdj1", formula: "*/ a5 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "enAng", formula: "pin 1 adj3 21599999" },
    { name: "stAng", formula: "pin 0 adj4 21599999" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "thh", formula: "*/ ss a5 100000" },
    { name: "th2", formula: "*/ th 1 2" },
    { name: "rw1", formula: "+- wd2 th2 thh" },
    { name: "rh1", formula: "+- hd2 th2 thh" },
    { name: "rw2", formula: "+- rw1 0 th" },
    { name: "rh2", formula: "+- rh1 0 th" },
    { name: "rw3", formula: "+- rw2 th2 0" },
    { name: "rh3", formula: "+- rh2 th2 0" },
    { name: "wtH", formula: "sin rw3 enAng" },
    { name: "htH", formula: "cos rh3 enAng" },
    { name: "dxH", formula: "cat2 rw3 htH wtH" },
    { name: "dyH", formula: "sat2 rh3 htH wtH" },
    { name: "xH", formula: "+- hc dxH 0" },
    { name: "yH", formula: "+- vc dyH 0" },
    { name: "rI", formula: "min rw2 rh2" },
    { name: "u1", formula: "*/ dxH dxH 1" },
    { name: "u2", formula: "*/ dyH dyH 1" },
    { name: "u3", formula: "*/ rI rI 1" },
    { name: "u4", formula: "+- u1 0 u3" },
    { name: "u5", formula: "+- u2 0 u3" },
    { name: "u6", formula: "*/ u4 u5 u1" },
    { name: "u7", formula: "*/ u6 1 u2" },
    { name: "u8", formula: "+- 1 0 u7" },
    { name: "u9", formula: "sqrt u8" },
    { name: "u10", formula: "*/ u4 1 dxH" },
    { name: "u11", formula: "*/ u10 1 dyH" },
    { name: "u12", formula: "+/ 1 u9 u11" },
    { name: "u13", formula: "at2 1 u12" },
    { name: "u14", formula: "+- u13 21600000 0" },
    { name: "u15", formula: "?: u13 u13 u14" },
    { name: "u16", formula: "+- u15 0 enAng" },
    { name: "u17", formula: "+- u16 21600000 0" },
    { name: "u18", formula: "?: u16 u16 u17" },
    { name: "u19", formula: "+- u18 0 cd2" },
    { name: "u20", formula: "+- u18 0 21600000" },
    { name: "u21", formula: "?: u19 u20 u18" },
    { name: "maxAng", formula: "abs u21" },
    { name: "aAng", formula: "pin 0 adj2 maxAng" },
    { name: "ptAng", formula: "+- enAng aAng 0" },
    { name: "wtA", formula: "sin rw3 ptAng" },
    { name: "htA", formula: "cos rh3 ptAng" },
    { name: "dxA", formula: "cat2 rw3 htA wtA" },
    { name: "dyA", formula: "sat2 rh3 htA wtA" },
    { name: "xA", formula: "+- hc dxA 0" },
    { name: "yA", formula: "+- vc dyA 0" },
    { name: "wtE", formula: "sin rw1 stAng" },
    { name: "htE", formula: "cos rh1 stAng" },
    { name: "dxE", formula: "cat2 rw1 htE wtE" },
    { name: "dyE", formula: "sat2 rh1 htE wtE" },
    { name: "xE", formula: "+- hc dxE 0" },
    { name: "yE", formula: "+- vc dyE 0" },
    { name: "dxG", formula: "cos thh ptAng" },
    { name: "dyG", formula: "sin thh ptAng" },
    { name: "xG", formula: "+- xH dxG 0" },
    { name: "yG", formula: "+- yH dyG 0" },
    { name: "dxB", formula: "cos thh ptAng" },
    { name: "dyB", formula: "sin thh ptAng" },
    { name: "xB", formula: "+- xH 0 dxB 0" },
    { name: "yB", formula: "+- yH 0 dyB 0" },
    { name: "sx1", formula: "+- xB 0 hc" },
    { name: "sy1", formula: "+- yB 0 vc" },
    { name: "sx2", formula: "+- xG 0 hc" },
    { name: "sy2", formula: "+- yG 0 vc" },
    { name: "rO", formula: "min rw1 rh1" },
    { name: "x1O", formula: "*/ sx1 rO rw1" },
    { name: "y1O", formula: "*/ sy1 rO rh1" },
    { name: "x2O", formula: "*/ sx2 rO rw1" },
    { name: "y2O", formula: "*/ sy2 rO rh1" },
    { name: "dxO", formula: "+- x2O 0 x1O" },
    { name: "dyO", formula: "+- y2O 0 y1O" },
    { name: "dO", formula: "mod dxO dyO 0" },
    { name: "q1", formula: "*/ x1O y2O 1" },
    { name: "q2", formula: "*/ x2O y1O 1" },
    { name: "DO", formula: "+- q1 0 q2" },
    { name: "q3", formula: "*/ rO rO 1" },
    { name: "q4", formula: "*/ dO dO 1" },
    { name: "q5", formula: "*/ q3 q4 1" },
    { name: "q6", formula: "*/ DO DO 1" },
    { name: "q7", formula: "+- q5 0 q6" },
    { name: "q8", formula: "max q7 0" },
    { name: "sdelO", formula: "sqrt q8" },
    { name: "ndyO", formula: "*/ dyO -1 1" },
    { name: "sdyO", formula: "?: ndyO -1 1" },
    { name: "q9", formula: "*/ sdyO dxO 1" },
    { name: "q10", formula: "*/ q9 sdelO 1" },
    { name: "q11", formula: "*/ DO dyO 1" },
    { name: "dxF1", formula: "+/ q11 q10 q4" },
    { name: "q12", formula: "+- q11 0 q10" },
    { name: "dxF2", formula: "*/ q12 1 q4" },
    { name: "adyO", formula: "abs dyO" },
    { name: "q13", formula: "*/ adyO sdelO 1" },
    { name: "q14", formula: "*/ DO dxO -1" },
    { name: "dyF1", formula: "+/ q14 q13 q4" },
    { name: "q15", formula: "+- q14 0 q13" },
    { name: "dyF2", formula: "*/ q15 1 q4" },
    { name: "q16", formula: "+- x2O 0 dxF1" },
    { name: "q17", formula: "+- x2O 0 dxF2" },
    { name: "q18", formula: "+- y2O 0 dyF1" },
    { name: "q19", formula: "+- y2O 0 dyF2" },
    { name: "q20", formula: "mod q16 q18 0" },
    { name: "q21", formula: "mod q17 q19 0" },
    { name: "q22", formula: "+- q21 0 q20" },
    { name: "dxF", formula: "?: q22 dxF1 dxF2" },
    { name: "dyF", formula: "?: q22 dyF1 dyF2" },
    { name: "sdxF", formula: "*/ dxF rw1 rO" },
    { name: "sdyF", formula: "*/ dyF rh1 rO" },
    { name: "xF", formula: "+- hc sdxF 0" },
    { name: "yF", formula: "+- vc sdyF 0" },
    { name: "x1I", formula: "*/ sx1 rI rw2" },
    { name: "y1I", formula: "*/ sy1 rI rh2" },
    { name: "x2I", formula: "*/ sx2 rI rw2" },
    { name: "y2I", formula: "*/ sy2 rI rh2" },
    { name: "dxI", formula: "+- x2I 0 x1I" },
    { name: "dyI", formula: "+- y2I 0 y1I" },
    { name: "dI", formula: "mod dxI dyI 0" },
    { name: "v1", formula: "*/ x1I y2I 1" },
    { name: "v2", formula: "*/ x2I y1I 1" },
    { name: "DI", formula: "+- v1 0 v2" },
    { name: "v3", formula: "*/ rI rI 1" },
    { name: "v4", formula: "*/ dI dI 1" },
    { name: "v5", formula: "*/ v3 v4 1" },
    { name: "v6", formula: "*/ DI DI 1" },
    { name: "v7", formula: "+- v5 0 v6" },
    { name: "v8", formula: "max v7 0" },
    { name: "sdelI", formula: "sqrt v8" },
    { name: "v9", formula: "*/ sdyO dxI 1" },
    { name: "v10", formula: "*/ v9 sdelI 1" },
    { name: "v11", formula: "*/ DI dyI 1" },
    { name: "dxC1", formula: "+/ v11 v10 v4" },
    { name: "v12", formula: "+- v11 0 v10" },
    { name: "dxC2", formula: "*/ v12 1 v4" },
    { name: "adyI", formula: "abs dyI" },
    { name: "v13", formula: "*/ adyI sdelI 1" },
    { name: "v14", formula: "*/ DI dxI -1" },
    { name: "dyC1", formula: "+/ v14 v13 v4" },
    { name: "v15", formula: "+- v14 0 v13" },
    { name: "dyC2", formula: "*/ v15 1 v4" },
    { name: "v16", formula: "+- x1I 0 dxC1" },
    { name: "v17", formula: "+- x1I 0 dxC2" },
    { name: "v18", formula: "+- y1I 0 dyC1" },
    { name: "v19", formula: "+- y1I 0 dyC2" },
    { name: "v20", formula: "mod v16 v18 0" },
    { name: "v21", formula: "mod v17 v19 0" },
    { name: "v22", formula: "+- v21 0 v20" },
    { name: "dxC", formula: "?: v22 dxC1 dxC2" },
    { name: "dyC", formula: "?: v22 dyC1 dyC2" },
    { name: "sdxC", formula: "*/ dxC rw2 rI" },
    { name: "sdyC", formula: "*/ dyC rh2 rI" },
    { name: "xC", formula: "+- hc sdxC 0" },
    { name: "yC", formula: "+- vc sdyC 0" },
    { name: "ist0", formula: "at2 sdxC sdyC" },
    { name: "ist1", formula: "+- ist0 21600000 0" },
    { name: "istAng", formula: "?: ist0 ist0 ist1" },
    { name: "isw1", formula: "+- stAng 0 istAng" },
    { name: "isw2", formula: "+- isw1 0 21600000" },
    { name: "iswAng", formula: "?: isw1 isw2 isw1" },
    { name: "p1", formula: "+- xF 0 xC" },
    { name: "p2", formula: "+- yF 0 yC" },
    { name: "p3", formula: "mod p1 p2 0" },
    { name: "p4", formula: "*/ p3 1 2" },
    { name: "p5", formula: "+- p4 0 thh" },
    { name: "xGp", formula: "?: p5 xF xG" },
    { name: "yGp", formula: "?: p5 yF yG" },
    { name: "xBp", formula: "?: p5 xC xB" },
    { name: "yBp", formula: "?: p5 yC yB" },
    { name: "en0", formula: "at2 sdxF sdyF" },
    { name: "en1", formula: "+- en0 21600000 0" },
    { name: "en2", formula: "?: en0 en0 en1" },
    { name: "sw0", formula: "+- en2 0 stAng" },
    { name: "sw1", formula: "+- sw0 21600000 0" },
    { name: "swAng", formula: "?: sw0 sw0 sw1" },
    { name: "wtI", formula: "sin rw3 stAng" },
    { name: "htI", formula: "cos rh3 stAng" },
    { name: "dxI", formula: "cat2 rw3 htI wtI" },
    { name: "dyI", formula: "sat2 rh3 htI wtI" },
    { name: "xI", formula: "+- hc dxI 0" },
    { name: "yI", formula: "+- vc dyI 0" },
    { name: "aI", formula: "+- stAng 0 cd4" },
    { name: "aA", formula: "+- ptAng cd4 0" },
    { name: "aB", formula: "+- ptAng cd2 0" },
    { name: "idx", formula: "cos rw1 2700000" },
    { name: "idy", formula: "sin rh1 2700000" },
    { name: "il", formula: "+- hc 0 idx" },
    { name: "ir", formula: "+- hc idx 0" },
    { name: "it", formula: "+- vc 0 idy" },
    { name: "ib", formula: "+- vc idy 0" },
  ]
  evaluate_guides(guides, local)
  let xe = g(local, "xE")
  let ye = g(local, "yE")
  let rw1 = g(local, "rw1")
  let rh1 = g(local, "rh1")
  let st_ang = g(local, "stAng")
  let sw_ang = g(local, "swAng")
  let xgp = g(local, "xGp")
  let ygp = g(local, "yGp")
  let xa = g(local, "xA")
  let ya = g(local, "yA")
  let xbp = g(local, "xBp")
  let ybp = g(local, "yBp")
  let xc = g(local, "xC")
  let yc = g(local, "yC")
  let rw2 = g(local, "rw2")
  let rh2 = g(local, "rh2")
  let ist_ang = g(local, "istAng")
  let isw_ang = g(local, "iswAng")
  build_arrow_path([
    MoveTo(xe, ye),
    ArcTo(rw1, rh1, st_ang, sw_ang, 0.0, 0.0),
    LineTo(xgp, ygp),
    LineTo(xa, ya),
    LineTo(xbp, ybp),
    LineTo(xc, yc),
    ArcTo(rw2, rh2, ist_ang, isw_ang, 0.0, 0.0),
    Close,
  ])
}

///|
/// `leftCircularArrow` — preset-shapes.ts:1508
fn arrow_left_circular_arrow(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(12500.0)
  let adj2 = ctx.get("adj2").unwrap_or(-1142319.0)
  let adj3 = ctx.get("adj3").unwrap_or(1142319.0)
  let adj4 = ctx.get("adj4").unwrap_or(10800000.0)
  let adj5 = ctx.get("adj5").unwrap_or(12500.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  local["adj5"] = adj5
  let guides : Array[GuideEntry] = [
    { name: "a5", formula: "pin 0 adj5 25000" },
    { name: "maxAdj1", formula: "*/ a5 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "enAng", formula: "pin 1 adj3 21599999" },
    { name: "stAng", formula: "pin 0 adj4 21599999" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "thh", formula: "*/ ss a5 100000" },
    { name: "th2", formula: "*/ th 1 2" },
    { name: "rw1", formula: "+- wd2 th2 thh" },
    { name: "rh1", formula: "+- hd2 th2 thh" },
    { name: "rw2", formula: "+- rw1 0 th" },
    { name: "rh2", formula: "+- rh1 0 th" },
    { name: "rw3", formula: "+- rw2 th2 0" },
    { name: "rh3", formula: "+- rh2 th2 0" },
    { name: "wtH", formula: "sin rw3 enAng" },
    { name: "htH", formula: "cos rh3 enAng" },
    { name: "dxH", formula: "cat2 rw3 htH wtH" },
    { name: "dyH", formula: "sat2 rh3 htH wtH" },
    { name: "xH", formula: "+- hc dxH 0" },
    { name: "yH", formula: "+- vc dyH 0" },
    { name: "rI", formula: "min rw2 rh2" },
    { name: "u1", formula: "*/ dxH dxH 1" },
    { name: "u2", formula: "*/ dyH dyH 1" },
    { name: "u3", formula: "*/ rI rI 1" },
    { name: "u4", formula: "+- u1 0 u3" },
    { name: "u5", formula: "+- u2 0 u3" },
    { name: "u6", formula: "*/ u4 u5 u1" },
    { name: "u7", formula: "*/ u6 1 u2" },
    { name: "u8", formula: "+- 1 0 u7" },
    { name: "u9", formula: "sqrt u8" },
    { name: "u10", formula: "*/ u4 1 dxH" },
    { name: "u11", formula: "*/ u10 1 dyH" },
    { name: "u12", formula: "+/ 1 u9 u11" },
    { name: "u13", formula: "at2 1 u12" },
    { name: "u14", formula: "+- u13 21600000 0" },
    { name: "u15", formula: "?: u13 u13 u14" },
    { name: "u16", formula: "+- u15 0 enAng" },
    { name: "u17", formula: "+- u16 21600000 0" },
    { name: "u18", formula: "?: u16 u16 u17" },
    { name: "u19", formula: "+- u18 0 cd2" },
    { name: "u20", formula: "+- u18 0 21600000" },
    { name: "u21", formula: "?: u19 u20 u18" },
    { name: "u22", formula: "abs u21" },
    { name: "minAng", formula: "*/ u22 -1 1" },
    { name: "u23", formula: "abs adj2" },
    { name: "a2", formula: "*/ u23 -1 1" },
    { name: "aAng", formula: "pin minAng a2 0" },
    { name: "ptAng", formula: "+- enAng aAng 0" },
    { name: "wtA", formula: "sin rw3 ptAng" },
    { name: "htA", formula: "cos rh3 ptAng" },
    { name: "dxA", formula: "cat2 rw3 htA wtA" },
    { name: "dyA", formula: "sat2 rh3 htA wtA" },
    { name: "xA", formula: "+- hc dxA 0" },
    { name: "yA", formula: "+- vc dyA 0" },
    { name: "wtE", formula: "sin rw1 stAng" },
    { name: "htE", formula: "cos rh1 stAng" },
    { name: "dxE", formula: "cat2 rw1 htE wtE" },
    { name: "dyE", formula: "sat2 rh1 htE wtE" },
    { name: "xE", formula: "+- hc dxE 0" },
    { name: "yE", formula: "+- vc dyE 0" },
    { name: "wtD", formula: "sin rw2 stAng" },
    { name: "htD", formula: "cos rh2 stAng" },
    { name: "dxD", formula: "cat2 rw2 htD wtD" },
    { name: "dyD", formula: "sat2 rh2 htD wtD" },
    { name: "xD", formula: "+- hc dxD 0" },
    { name: "yD", formula: "+- vc dyD 0" },
    { name: "dxG", formula: "cos thh ptAng" },
    { name: "dyG", formula: "sin thh ptAng" },
    { name: "xG", formula: "+- xH dxG 0" },
    { name: "yG", formula: "+- yH dyG 0" },
    { name: "dxB", formula: "cos thh ptAng" },
    { name: "dyB", formula: "sin thh ptAng" },
    { name: "xB", formula: "+- xH 0 dxB 0" },
    { name: "yB", formula: "+- yH 0 dyB 0" },
    { name: "sx1", formula: "+- xB 0 hc" },
    { name: "sy1", formula: "+- yB 0 vc" },
    { name: "sx2", formula: "+- xG 0 hc" },
    { name: "sy2", formula: "+- yG 0 vc" },
    { name: "rO", formula: "min rw1 rh1" },
    { name: "x1O", formula: "*/ sx1 rO rw1" },
    { name: "y1O", formula: "*/ sy1 rO rh1" },
    { name: "x2O", formula: "*/ sx2 rO rw1" },
    { name: "y2O", formula: "*/ sy2 rO rh1" },
    { name: "dxO", formula: "+- x2O 0 x1O" },
    { name: "dyO", formula: "+- y2O 0 y1O" },
    { name: "dO", formula: "mod dxO dyO 0" },
    { name: "q1", formula: "*/ x1O y2O 1" },
    { name: "q2", formula: "*/ x2O y1O 1" },
    { name: "DO", formula: "+- q1 0 q2" },
    { name: "q3", formula: "*/ rO rO 1" },
    { name: "q4", formula: "*/ dO dO 1" },
    { name: "q5", formula: "*/ q3 q4 1" },
    { name: "q6", formula: "*/ DO DO 1" },
    { name: "q7", formula: "+- q5 0 q6" },
    { name: "q8", formula: "max q7 0" },
    { name: "sdelO", formula: "sqrt q8" },
    { name: "ndyO", formula: "*/ dyO -1 1" },
    { name: "sdyO", formula: "?: ndyO -1 1" },
    { name: "q9", formula: "*/ sdyO dxO 1" },
    { name: "q10", formula: "*/ q9 sdelO 1" },
    { name: "q11", formula: "*/ DO dyO 1" },
    { name: "dxF1", formula: "+/ q11 q10 q4" },
    { name: "q12", formula: "+- q11 0 q10" },
    { name: "dxF2", formula: "*/ q12 1 q4" },
    { name: "adyO", formula: "abs dyO" },
    { name: "q13", formula: "*/ adyO sdelO 1" },
    { name: "q14", formula: "*/ DO dxO -1" },
    { name: "dyF1", formula: "+/ q14 q13 q4" },
    { name: "q15", formula: "+- q14 0 q13" },
    { name: "dyF2", formula: "*/ q15 1 q4" },
    { name: "q16", formula: "+- x2O 0 dxF1" },
    { name: "q17", formula: "+- x2O 0 dxF2" },
    { name: "q18", formula: "+- y2O 0 dyF1" },
    { name: "q19", formula: "+- y2O 0 dyF2" },
    { name: "q20", formula: "mod q16 q18 0" },
    { name: "q21", formula: "mod q17 q19 0" },
    { name: "q22", formula: "+- q21 0 q20" },
    { name: "dxF", formula: "?: q22 dxF1 dxF2" },
    { name: "dyF", formula: "?: q22 dyF1 dyF2" },
    { name: "sdxF", formula: "*/ dxF rw1 rO" },
    { name: "sdyF", formula: "*/ dyF rh1 rO" },
    { name: "xF", formula: "+- hc sdxF 0" },
    { name: "yF", formula: "+- vc sdyF 0" },
    { name: "x1I", formula: "*/ sx1 rI rw2" },
    { name: "y1I", formula: "*/ sy1 rI rh2" },
    { name: "x2I", formula: "*/ sx2 rI rw2" },
    { name: "y2I", formula: "*/ sy2 rI rh2" },
    { name: "dxI", formula: "+- x2I 0 x1I" },
    { name: "dyI", formula: "+- y2I 0 y1I" },
    { name: "dI", formula: "mod dxI dyI 0" },
    { name: "v1", formula: "*/ x1I y2I 1" },
    { name: "v2", formula: "*/ x2I y1I 1" },
    { name: "DI", formula: "+- v1 0 v2" },
    { name: "v3", formula: "*/ rI rI 1" },
    { name: "v4", formula: "*/ dI dI 1" },
    { name: "v5", formula: "*/ v3 v4 1" },
    { name: "v6", formula: "*/ DI DI 1" },
    { name: "v7", formula: "+- v5 0 v6" },
    { name: "v8", formula: "max v7 0" },
    { name: "sdelI", formula: "sqrt v8" },
    { name: "v9", formula: "*/ sdyO dxI 1" },
    { name: "v10", formula: "*/ v9 sdelI 1" },
    { name: "v11", formula: "*/ DI dyI 1" },
    { name: "dxC1", formula: "+/ v11 v10 v4" },
    { name: "v12", formula: "+- v11 0 v10" },
    { name: "dxC2", formula: "*/ v12 1 v4" },
    { name: "adyI", formula: "abs dyI" },
    { name: "v13", formula: "*/ adyI sdelI 1" },
    { name: "v14", formula: "*/ DI dxI -1" },
    { name: "dyC1", formula: "+/ v14 v13 v4" },
    { name: "v15", formula: "+- v14 0 v13" },
    { name: "dyC2", formula: "*/ v15 1 v4" },
    { name: "v16", formula: "+- x1I 0 dxC1" },
    { name: "v17", formula: "+- x1I 0 dxC2" },
    { name: "v18", formula: "+- y1I 0 dyC1" },
    { name: "v19", formula: "+- y1I 0 dyC2" },
    { name: "v20", formula: "mod v16 v18 0" },
    { name: "v21", formula: "mod v17 v19 0" },
    { name: "v22", formula: "+- v21 0 v20" },
    { name: "dxC", formula: "?: v22 dxC1 dxC2" },
    { name: "dyC", formula: "?: v22 dyC1 dyC2" },
    { name: "sdxC", formula: "*/ dxC rw2 rI" },
    { name: "sdyC", formula: "*/ dyC rh2 rI" },
    { name: "xC", formula: "+- hc sdxC 0" },
    { name: "yC", formula: "+- vc sdyC 0" },
    { name: "ist0", formula: "at2 sdxC sdyC" },
    { name: "ist1", formula: "+- ist0 21600000 0" },
    { name: "istAng0", formula: "?: ist0 ist0 ist1" },
    { name: "isw1", formula: "+- stAng 0 istAng0" },
    { name: "isw2", formula: "+- isw1 21600000 0" },
    { name: "iswAng0", formula: "?: isw1 isw1 isw2" },
    { name: "istAng", formula: "+- istAng0 iswAng0 0" },
    { name: "iswAng", formula: "+- 0 0 iswAng0" },
    { name: "p1", formula: "+- xF 0 xC" },
    { name: "p2", formula: "+- yF 0 yC" },
    { name: "p3", formula: "mod p1 p2 0" },
    { name: "p4", formula: "*/ p3 1 2" },
    { name: "p5", formula: "+- p4 0 thh" },
    { name: "xGp", formula: "?: p5 xF xG" },
    { name: "yGp", formula: "?: p5 yF yG" },
    { name: "xBp", formula: "?: p5 xC xB" },
    { name: "yBp", formula: "?: p5 yC yB" },
    { name: "en0", formula: "at2 sdxF sdyF" },
    { name: "en1", formula: "+- en0 21600000 0" },
    { name: "en2", formula: "?: en0 en0 en1" },
    { name: "sw0", formula: "+- en2 0 stAng" },
    { name: "sw1", formula: "+- sw0 0 21600000" },
    { name: "swAng", formula: "?: sw0 sw0 sw1" },
    { name: "stAng0", formula: "+- stAng swAng 0" },
    { name: "swAng0", formula: "+- 0 0 swAng" },
    { name: "wtI", formula: "sin rw3 stAng" },
    { name: "htI", formula: "cos rh3 stAng" },
    { name: "dxI", formula: "cat2 rw3 htI wtI" },
    { name: "dyI", formula: "sat2 rh3 htI wtI" },
    { name: "xI", formula: "+- hc dxI 0" },
    { name: "yI", formula: "+- vc dyI 0" },
    { name: "aI", formula: "+- stAng cd4 0" },
    { name: "aA", formula: "+- ptAng 0 cd4" },
    { name: "aB", formula: "+- ptAng cd2 0" },
    { name: "idx", formula: "cos rw1 2700000" },
    { name: "idy", formula: "sin rh1 2700000" },
    { name: "il", formula: "+- hc 0 idx" },
    { name: "ir", formula: "+- hc idx 0" },
    { name: "it", formula: "+- vc 0 idy" },
    { name: "ib", formula: "+- vc idy 0" },
  ]
  evaluate_guides(guides, local)
  let xe = g(local, "xE")
  let ye = g(local, "yE")
  let xd = g(local, "xD")
  let yd = g(local, "yD")
  let rw2 = g(local, "rw2")
  let rh2 = g(local, "rh2")
  let ist_ang = g(local, "istAng")
  let isw_ang = g(local, "iswAng")
  let xbp = g(local, "xBp")
  let ybp = g(local, "yBp")
  let xa = g(local, "xA")
  let ya = g(local, "yA")
  let xgp = g(local, "xGp")
  let ygp = g(local, "yGp")
  let xf = g(local, "xF")
  let yf = g(local, "yF")
  let rw1 = g(local, "rw1")
  let rh1 = g(local, "rh1")
  let st_ang0 = g(local, "stAng0")
  let sw_ang0 = g(local, "swAng0")
  build_arrow_path([
    MoveTo(xe, ye),
    LineTo(xd, yd),
    ArcTo(rw2, rh2, ist_ang, isw_ang, 0.0, 0.0),
    LineTo(xbp, ybp),
    LineTo(xa, ya),
    LineTo(xgp, ygp),
    LineTo(xf, yf),
    ArcTo(rw1, rh1, st_ang0, sw_ang0, 0.0, 0.0),
    Close,
  ])
}

///|
/// `leftRightCircularArrow` — preset-shapes.ts:1771
fn arrow_left_right_circular_arrow(
  _w : Double,
  _h : Double,
  ctx : GuideContext,
) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(12500.0)
  let adj2 = ctx.get("adj2").unwrap_or(1142319.0)
  let adj3 = ctx.get("adj3").unwrap_or(20457681.0)
  let adj4 = ctx.get("adj4").unwrap_or(11942319.0)
  let adj5 = ctx.get("adj5").unwrap_or(12500.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  local["adj4"] = adj4
  local["adj5"] = adj5
  let guides : Array[GuideEntry] = [
    { name: "a5", formula: "pin 0 adj5 25000" },
    { name: "maxAdj1", formula: "*/ a5 2 1" },
    { name: "a1", formula: "pin 0 adj1 maxAdj1" },
    { name: "enAng", formula: "pin 1 adj3 21599999" },
    { name: "stAng", formula: "pin 0 adj4 21599999" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "thh", formula: "*/ ss a5 100000" },
    { name: "th2", formula: "*/ th 1 2" },
    { name: "rw1", formula: "+- wd2 th2 thh" },
    { name: "rh1", formula: "+- hd2 th2 thh" },
    { name: "rw2", formula: "+- rw1 0 th" },
    { name: "rh2", formula: "+- rh1 0 th" },
    { name: "rw3", formula: "+- rw2 th2 0" },
    { name: "rh3", formula: "+- rh2 th2 0" },
    { name: "wtH", formula: "sin rw3 enAng" },
    { name: "htH", formula: "cos rh3 enAng" },
    { name: "dxH", formula: "cat2 rw3 htH wtH" },
    { name: "dyH", formula: "sat2 rh3 htH wtH" },
    { name: "xH", formula: "+- hc dxH 0" },
    { name: "yH", formula: "+- vc dyH 0" },
    { name: "rI", formula: "min rw2 rh2" },
    { name: "u1", formula: "*/ dxH dxH 1" },
    { name: "u2", formula: "*/ dyH dyH 1" },
    { name: "u3", formula: "*/ rI rI 1" },
    { name: "u4", formula: "+- u1 0 u3" },
    { name: "u5", formula: "+- u2 0 u3" },
    { name: "u6", formula: "*/ u4 u5 u1" },
    { name: "u7", formula: "*/ u6 1 u2" },
    { name: "u8", formula: "+- 1 0 u7" },
    { name: "u9", formula: "sqrt u8" },
    { name: "u10", formula: "*/ u4 1 dxH" },
    { name: "u11", formula: "*/ u10 1 dyH" },
    { name: "u12", formula: "+/ 1 u9 u11" },
    { name: "u13", formula: "at2 1 u12" },
    { name: "u14", formula: "+- u13 21600000 0" },
    { name: "u15", formula: "?: u13 u13 u14" },
    { name: "u16", formula: "+- u15 0 enAng" },
    { name: "u17", formula: "+- u16 21600000 0" },
    { name: "u18", formula: "?: u16 u16 u17" },
    { name: "u19", formula: "+- u18 0 cd2" },
    { name: "u20", formula: "+- u18 0 21600000" },
    { name: "u21", formula: "?: u19 u20 u18" },
    { name: "maxAng", formula: "abs u21" },
    { name: "aAng", formula: "pin 0 adj2 maxAng" },
    { name: "ptAng", formula: "+- enAng aAng 0" },
    { name: "wtA", formula: "sin rw3 ptAng" },
    { name: "htA", formula: "cos rh3 ptAng" },
    { name: "dxA", formula: "cat2 rw3 htA wtA" },
    { name: "dyA", formula: "sat2 rh3 htA wtA" },
    { name: "xA", formula: "+- hc dxA 0" },
    { name: "yA", formula: "+- vc dyA 0" },
    { name: "dxG", formula: "cos thh ptAng" },
    { name: "dyG", formula: "sin thh ptAng" },
    { name: "xG", formula: "+- xH dxG 0" },
    { name: "yG", formula: "+- yH dyG 0" },
    { name: "dxB", formula: "cos thh ptAng" },
    { name: "dyB", formula: "sin thh ptAng" },
    { name: "xB", formula: "+- xH 0 dxB 0" },
    { name: "yB", formula: "+- yH 0 dyB 0" },
    { name: "sx1", formula: "+- xB 0 hc" },
    { name: "sy1", formula: "+- yB 0 vc" },
    { name: "sx2", formula: "+- xG 0 hc" },
    { name: "sy2", formula: "+- yG 0 vc" },
    { name: "rO", formula: "min rw1 rh1" },
    { name: "x1O", formula: "*/ sx1 rO rw1" },
    { name: "y1O", formula: "*/ sy1 rO rh1" },
    { name: "x2O", formula: "*/ sx2 rO rw1" },
    { name: "y2O", formula: "*/ sy2 rO rh1" },
    { name: "dxO", formula: "+- x2O 0 x1O" },
    { name: "dyO", formula: "+- y2O 0 y1O" },
    { name: "dO", formula: "mod dxO dyO 0" },
    { name: "q1", formula: "*/ x1O y2O 1" },
    { name: "q2", formula: "*/ x2O y1O 1" },
    { name: "DO", formula: "+- q1 0 q2" },
    { name: "q3", formula: "*/ rO rO 1" },
    { name: "q4", formula: "*/ dO dO 1" },
    { name: "q5", formula: "*/ q3 q4 1" },
    { name: "q6", formula: "*/ DO DO 1" },
    { name: "q7", formula: "+- q5 0 q6" },
    { name: "q8", formula: "max q7 0" },
    { name: "sdelO", formula: "sqrt q8" },
    { name: "ndyO", formula: "*/ dyO -1 1" },
    { name: "sdyO", formula: "?: ndyO -1 1" },
    { name: "q9", formula: "*/ sdyO dxO 1" },
    { name: "q10", formula: "*/ q9 sdelO 1" },
    { name: "q11", formula: "*/ DO dyO 1" },
    { name: "dxF1", formula: "+/ q11 q10 q4" },
    { name: "q12", formula: "+- q11 0 q10" },
    { name: "dxF2", formula: "*/ q12 1 q4" },
    { name: "adyO", formula: "abs dyO" },
    { name: "q13", formula: "*/ adyO sdelO 1" },
    { name: "q14", formula: "*/ DO dxO -1" },
    { name: "dyF1", formula: "+/ q14 q13 q4" },
    { name: "q15", formula: "+- q14 0 q13" },
    { name: "dyF2", formula: "*/ q15 1 q4" },
    { name: "q16", formula: "+- x2O 0 dxF1" },
    { name: "q17", formula: "+- x2O 0 dxF2" },
    { name: "q18", formula: "+- y2O 0 dyF1" },
    { name: "q19", formula: "+- y2O 0 dyF2" },
    { name: "q20", formula: "mod q16 q18 0" },
    { name: "q21", formula: "mod q17 q19 0" },
    { name: "q22", formula: "+- q21 0 q20" },
    { name: "dxF", formula: "?: q22 dxF1 dxF2" },
    { name: "dyF", formula: "?: q22 dyF1 dyF2" },
    { name: "sdxF", formula: "*/ dxF rw1 rO" },
    { name: "sdyF", formula: "*/ dyF rh1 rO" },
    { name: "xF", formula: "+- hc sdxF 0" },
    { name: "yF", formula: "+- vc sdyF 0" },
    { name: "x1I", formula: "*/ sx1 rI rw2" },
    { name: "y1I", formula: "*/ sy1 rI rh2" },
    { name: "x2I", formula: "*/ sx2 rI rw2" },
    { name: "y2I", formula: "*/ sy2 rI rh2" },
    { name: "dxI", formula: "+- x2I 0 x1I" },
    { name: "dyI", formula: "+- y2I 0 y1I" },
    { name: "dI", formula: "mod dxI dyI 0" },
    { name: "v1", formula: "*/ x1I y2I 1" },
    { name: "v2", formula: "*/ x2I y1I 1" },
    { name: "DI", formula: "+- v1 0 v2" },
    { name: "v3", formula: "*/ rI rI 1" },
    { name: "v4", formula: "*/ dI dI 1" },
    { name: "v5", formula: "*/ v3 v4 1" },
    { name: "v6", formula: "*/ DI DI 1" },
    { name: "v7", formula: "+- v5 0 v6" },
    { name: "v8", formula: "max v7 0" },
    { name: "sdelI", formula: "sqrt v8" },
    { name: "v9", formula: "*/ sdyO dxI 1" },
    { name: "v10", formula: "*/ v9 sdelI 1" },
    { name: "v11", formula: "*/ DI dyI 1" },
    { name: "dxC1", formula: "+/ v11 v10 v4" },
    { name: "v12", formula: "+- v11 0 v10" },
    { name: "dxC2", formula: "*/ v12 1 v4" },
    { name: "adyI", formula: "abs dyI" },
    { name: "v13", formula: "*/ adyI sdelI 1" },
    { name: "v14", formula: "*/ DI dxI -1" },
    { name: "dyC1", formula: "+/ v14 v13 v4" },
    { name: "v15", formula: "+- v14 0 v13" },
    { name: "dyC2", formula: "*/ v15 1 v4" },
    { name: "v16", formula: "+- x1I 0 dxC1" },
    { name: "v17", formula: "+- x1I 0 dxC2" },
    { name: "v18", formula: "+- y1I 0 dyC1" },
    { name: "v19", formula: "+- y1I 0 dyC2" },
    { name: "v20", formula: "mod v16 v18 0" },
    { name: "v21", formula: "mod v17 v19 0" },
    { name: "v22", formula: "+- v21 0 v20" },
    { name: "dxC", formula: "?: v22 dxC1 dxC2" },
    { name: "dyC", formula: "?: v22 dyC1 dyC2" },
    { name: "sdxC", formula: "*/ dxC rw2 rI" },
    { name: "sdyC", formula: "*/ dyC rh2 rI" },
    { name: "xC", formula: "+- hc sdxC 0" },
    { name: "yC", formula: "+- vc sdyC 0" },
    { name: "wtI", formula: "sin rw3 stAng" },
    { name: "htI", formula: "cos rh3 stAng" },
    { name: "dxI", formula: "cat2 rw3 htI wtI" },
    { name: "dyI", formula: "sat2 rh3 htI wtI" },
    { name: "xI", formula: "+- hc dxI 0" },
    { name: "yI", formula: "+- vc dyI 0" },
    { name: "lptAng", formula: "+- stAng 0 aAng" },
    { name: "wtL", formula: "sin rw3 lptAng" },
    { name: "htL", formula: "cos rh3 lptAng" },
    { name: "dxL", formula: "cat2 rw3 htL wtL" },
    { name: "dyL", formula: "sat2 rh3 htL wtL" },
    { name: "xL", formula: "+- hc dxL 0" },
    { name: "yL", formula: "+- vc dyL 0" },
    { name: "dxK", formula: "cos thh lptAng" },
    { name: "dyK", formula: "sin thh lptAng" },
    { name: "xK", formula: "+- xI dxK 0" },
    { name: "yK", formula: "+- yI dyK 0" },
    { name: "dxJ", formula: "cos thh lptAng" },
    { name: "dyJ", formula: "sin thh lptAng" },
    { name: "xJ", formula: "+- xI 0 dxJ 0" },
    { name: "yJ", formula: "+- yI 0 dyJ 0" },
    { name: "p1", formula: "+- xF 0 xC" },
    { name: "p2", formula: "+- yF 0 yC" },
    { name: "p3", formula: "mod p1 p2 0" },
    { name: "p4", formula: "*/ p3 1 2" },
    { name: "p5", formula: "+- p4 0 thh" },
    { name: "xGp", formula: "?: p5 xF xG" },
    { name: "yGp", formula: "?: p5 yF yG" },
    { name: "xBp", formula: "?: p5 xC xB" },
    { name: "yBp", formula: "?: p5 yC yB" },
    { name: "en0", formula: "at2 sdxF sdyF" },
    { name: "en1", formula: "+- en0 21600000 0" },
    { name: "en2", formula: "?: en0 en0 en1" },
    { name: "od0", formula: "+- en2 0 enAng" },
    { name: "od1", formula: "+- od0 21600000 0" },
    { name: "od2", formula: "?: od0 od0 od1" },
    { name: "st0", formula: "+- stAng 0 od2" },
    { name: "st1", formula: "+- st0 21600000 0" },
    { name: "st2", formula: "?: st0 st0 st1" },
    { name: "sw0", formula: "+- en2 0 st2" },
    { name: "sw1", formula: "+- sw0 21600000 0" },
    { name: "swAng", formula: "?: sw0 sw0 sw1" },
    { name: "ist0", formula: "at2 sdxC sdyC" },
    { name: "ist1", formula: "+- ist0 21600000 0" },
    { name: "istAng", formula: "?: ist0 ist0 ist1" },
    { name: "id0", formula: "+- istAng 0 enAng" },
    { name: "id1", formula: "+- id0 0 21600000" },
    { name: "id2", formula: "?: id0 id1 id0" },
    { name: "ien0", formula: "+- stAng 0 id2" },
    { name: "ien1", formula: "+- ien0 0 21600000" },
    { name: "ien2", formula: "?: ien1 ien1 ien0" },
    { name: "isw1", formula: "+- ien2 0 istAng" },
    { name: "isw2", formula: "+- isw1 0 21600000" },
    { name: "iswAng", formula: "?: isw1 isw2 isw1" },
    { name: "wtE", formula: "sin rw1 st2" },
    { name: "htE", formula: "cos rh1 st2" },
    { name: "dxE", formula: "cat2 rw1 htE wtE" },
    { name: "dyE", formula: "sat2 rh1 htE wtE" },
    { name: "xE", formula: "+- hc dxE 0" },
    { name: "yE", formula: "+- vc dyE 0" },
    { name: "wtD", formula: "sin rw2 ien2" },
    { name: "htD", formula: "cos rh2 ien2" },
    { name: "dxD", formula: "cat2 rw2 htD wtD" },
    { name: "dyD", formula: "sat2 rh2 htD wtD" },
    { name: "xD", formula: "+- hc dxD 0" },
    { name: "yD", formula: "+- vc dyD 0" },
    { name: "xKp", formula: "?: p5 xE xK" },
    { name: "yKp", formula: "?: p5 yE yK" },
    { name: "xJp", formula: "?: p5 xD xJ" },
    { name: "yJp", formula: "?: p5 yD yJ" },
    { name: "aL", formula: "+- lptAng 0 cd4" },
    { name: "aA", formula: "+- ptAng cd4 0" },
    { name: "aB", formula: "+- ptAng cd2 0" },
    { name: "aJ", formula: "+- lptAng cd2 0" },
    { name: "idx", formula: "cos rw1 2700000" },
    { name: "idy", formula: "sin rh1 2700000" },
    { name: "il", formula: "+- hc 0 idx" },
    { name: "ir", formula: "+- hc idx 0" },
    { name: "it", formula: "+- vc 0 idy" },
    { name: "ib", formula: "+- vc idy 0" },
  ]
  evaluate_guides(guides, local)
  let xl = g(local, "xL")
  let yl = g(local, "yL")
  let xkp = g(local, "xKp")
  let ykp = g(local, "yKp")
  let xe = g(local, "xE")
  let ye = g(local, "yE")
  let rw1 = g(local, "rw1")
  let rh1 = g(local, "rh1")
  let st2 = g(local, "st2")
  let sw_ang = g(local, "swAng")
  let xgp = g(local, "xGp")
  let ygp = g(local, "yGp")
  let xa = g(local, "xA")
  let ya = g(local, "yA")
  let xbp = g(local, "xBp")
  let ybp = g(local, "yBp")
  let xc = g(local, "xC")
  let yc = g(local, "yC")
  let rw2 = g(local, "rw2")
  let rh2 = g(local, "rh2")
  let ist_ang = g(local, "istAng")
  let isw_ang = g(local, "iswAng")
  let xjp = g(local, "xJp")
  let yjp = g(local, "yJp")
  build_arrow_path([
    MoveTo(xl, yl),
    LineTo(xkp, ykp),
    LineTo(xe, ye),
    ArcTo(rw1, rh1, st2, sw_ang, 0.0, 0.0),
    LineTo(xgp, ygp),
    LineTo(xa, ya),
    LineTo(xbp, ybp),
    LineTo(xc, yc),
    ArcTo(rw2, rh2, ist_ang, isw_ang, 0.0, 0.0),
    LineTo(xjp, yjp),
    Close,
  ])
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
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
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
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let width = g(local, "w")
  let h_r = g(local, "hR")
  let th = g(local, "th")
  let dy = g(local, "dy")
  let dh = g(local, "dh")
  let ah = g(local, "ah")
  let x1 = g(local, "x1")
  let y3 = g(local, "y3")
  let y6 = g(local, "y6")
  let cd2 = g(local, "cd2")
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
    ArcTo(width, h_r, cd2, -sw_main, 0.0, 0.0),
    LineTo(x1, notch_top_y),
    LineTo(r, y6),
    LineTo(x1, notch_bot_y),
    LineTo(x1, outer_start_y),
    // Outer edge (on E2, centre (w, y3)) — sweep CW from (cd2-sw_main)
    // back to cd2 to land at (l, y3).  current point is (x1, y3+dy), so
    // start angle satisfies cos = -ah/w, sin = +dy/hR (Q2 ≈ 100.8°).
    ArcTo(width, h_r, cd2 - sw_main, sw_main, 0.0, 0.0),
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
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
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
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let width = g(local, "w")
  let h_r = g(local, "hR")
  let dy = g(local, "dy")
  let dh = g(local, "dh")
  let ah = g(local, "ah")
  let x1 = g(local, "x1") // = l + ah
  let y3 = g(local, "y3")
  let y6 = g(local, "y6")
  let ix = g(local, "ix") // l + idx — intersection x on the right side
  let iy = g(local, "iy")
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
    ArcTo(width, h_r, st_inner, sw_inner, 0.0, 0.0),
    ArcTo(width, h_r, st_outer, sw_outer, 0.0, 0.0),
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
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
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
  evaluate_guides(guides, local)
  let t = g(local, "t")
  let w_r = g(local, "wR")
  let height = g(local, "h")
  let th = g(local, "th")
  let dx = g(local, "dx")
  let dh = g(local, "dh")
  let ah = g(local, "ah")
  let idy = g(local, "idy")
  let x3 = g(local, "x3")
  let x6 = g(local, "x6")
  let y1 = g(local, "y1")
  let ix = g(local, "ix")
  let iy = g(local, "iy")
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
    ArcTo(w_r, height, st_inner, sw_inner, 0.0, 0.0),
    ArcTo(w_r, height, st_outer, sw_outer, 0.0, 0.0),
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
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
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
  evaluate_guides(guides, local)
  let t = g(local, "t")
  let b = g(local, "b")
  let w_r = g(local, "wR")
  let height = g(local, "h")
  let dx = g(local, "dx")
  let dh = g(local, "dh")
  let ah = g(local, "ah")
  let x3 = g(local, "x3")
  let x6 = g(local, "x6")
  let y1 = g(local, "y1") // = b - ah; arrowhead notch y
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
    ArcTo(w_r, height, st_inner, sw_inner, 0.0, 0.0),
    LineTo(x3, t),
    ArcTo(w_r, height, st_outer, sw_outer, 0.0, 0.0),
    LineTo(notch_right_x, y1),
    Close,
  ])
}

///|
/// `swooshArrow` — preset-shapes.ts:2429
fn arrow_swoosh_arrow(_w : Double, _h : Double, ctx : GuideContext) -> String {
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(16667.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  let guides : Array[GuideEntry] = [
    { name: "a1", formula: "pin 1 adj1 75000" },
    { name: "maxAdj2", formula: "*/ 70000 w ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "ad1", formula: "*/ h a1 100000" },
    { name: "ad2", formula: "*/ ss a2 100000" },
    { name: "xB", formula: "+- r 0 ad2" },
    { name: "yB", formula: "+- t ssd8 0" },
    { name: "alfa", formula: "*/ cd4 1 14" },
    { name: "dx0", formula: "tan ssd8 alfa" },
    { name: "xC", formula: "+- xB 0 dx0" },
    { name: "dx1", formula: "tan ad1 alfa" },
    { name: "yF", formula: "+- yB ad1 0" },
    { name: "xF", formula: "+- xB dx1 0" },
    { name: "xE", formula: "+- xF dx0 0" },
    { name: "yE", formula: "+- yF ssd8 0" },
    { name: "dy2", formula: "+- yE 0 t" },
    { name: "dy22", formula: "*/ dy2 1 2" },
    { name: "dy3", formula: "*/ h 1 20" },
    { name: "yD", formula: "+- t dy22 dy3" },
    { name: "dy4", formula: "*/ hd6 1 1" },
    { name: "yP1", formula: "+- hd6 dy4 0" },
    { name: "xP1", formula: "val wd6" },
    { name: "dy5", formula: "*/ hd6 1 2" },
    { name: "yP2", formula: "+- yF dy5 0" },
    { name: "xP2", formula: "val wd4" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let b = g(local, "b")
  let xp1 = g(local, "xP1")
  let yp1 = g(local, "yP1")
  let xb = g(local, "xB")
  let yb = g(local, "yB")
  let xc = g(local, "xC")
  let yd = g(local, "yD")
  let xe = g(local, "xE")
  let ye = g(local, "yE")
  let xf = g(local, "xF")
  let yf = g(local, "yF")
  let xp2 = g(local, "xP2")
  let yp2 = g(local, "yP2")
  build_arrow_path([
    MoveTo(l, b),
    QuadTo(xp1, yp1, xb, yb),
    LineTo(xc, t),
    LineTo(r, yd),
    LineTo(xe, ye),
    LineTo(xf, yf),
    QuadTo(xp2, yp2, l, b),
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
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
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
  evaluate_guides(guides, local)
  let r = g(local, "r")
  let width = g(local, "w")
  let h_r = g(local, "hR")
  let th = g(local, "th")
  let ix = g(local, "ix")
  let iy = g(local, "iy")
  let y3 = g(local, "y3")
  let three_cd4 = g(local, "3cd4")
  let cd2 = g(local, "cd2")
  let cd4 = g(local, "cd4")
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
    ArcTo(width, h_r, three_cd4, sw_e2, 0.0, 0.0),
    ArcTo(width, h_r, st_e1, sw_e1, 0.0, 0.0),
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
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
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
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let t = g(local, "t")
  let width = g(local, "w")
  let h_r = g(local, "hR")
  let y3 = g(local, "y3")
  let three_cd4 = g(local, "3cd4")
  let cd4 = g(local, "cd4")
  // Spec: M (r, y3)
  //       arcTo (w, hR, 0, -cd4)   — half-arc on E2 → (l, th)
  //       lnTo (l, t)
  //       arcTo (w, hR, 3cd4, cd4) — half-arc on E1 → (r, hR)
  //       close
  let dark = build_arrow_path([
    MoveTo(r, y3),
    ArcTo(width, h_r, 0.0, -cd4, 0.0, 0.0),
    LineTo(l, t),
    ArcTo(width, h_r, three_cd4, cd4, 0.0, 0.0),
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
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
  let guides : Array[GuideEntry] = [
    { name: "maxAdj2", formula: "*/ 50000 w ss" },
    { name: "a2", formula: "pin 0 adj2 maxAdj2" },
    { name: "a1", formula: "pin 0 adj1 100000" },
    { name: "th", formula: "*/ ss a1 100000" },
    { name: "aw", formula: "*/ ss a2 100000" },
    { name: "q1", formula: "+/ th aw 4" },
    { name: "wR", formula: "+- wd2 0 q1" },
  ]
  evaluate_guides(guides, local)
  let t = g(local, "t")
  let b = g(local, "b")
  let w_r = g(local, "wR")
  let height = g(local, "h")
  let th = g(local, "th")
  let cd4 = g(local, "cd4")
  let cd2 = g(local, "cd2")
  // Spec: M (wR, b)
  //       arcTo (wR, h, cd4, cd4)   — 90° arc on E2 → (l, t)
  //       lnTo (th, t)
  //       arcTo (wR, h, cd2, -cd4)  — -90° arc on E1 → (x3, b)
  //       close
  let dark = build_arrow_path([
    MoveTo(w_r, b),
    ArcTo(w_r, height, cd4, cd4, 0.0, 0.0),
    LineTo(th, t),
    ArcTo(w_r, height, cd2, -cd4, 0.0, 0.0),
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
  let local = clone_ctx(ctx)
  let adj1 = ctx.get("adj1").unwrap_or(25000.0)
  let adj2 = ctx.get("adj2").unwrap_or(50000.0)
  let adj3 = ctx.get("adj3").unwrap_or(25000.0)
  local["adj1"] = adj1
  local["adj2"] = adj2
  local["adj3"] = adj3
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
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let b = g(local, "b")
  let w_r = g(local, "wR")
  let height = g(local, "h")
  let x3 = g(local, "x3")
  let ix = g(local, "ix")
  let iy = g(local, "iy")
  let cd2 = g(local, "cd2")
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
    ArcTo(w_r, height, st_e2, sw_e2, 0.0, 0.0),
    LineTo(l, b),
    ArcTo(w_r, height, cd2, sw_e1, 0.0, 0.0),
    Close,
  ])
  [
    { path: arrow_curved_down_arrow(_w, _h, ctx), fill_mod: 0.0 },
    { path: dark, fill_mod: -0.20 },
  ]
}
