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

///|
/// `curvedRightArrow` — preset-shapes.ts:2089
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
    { name: "y3", formula: "+- hR th 0" },
    { name: "q2", formula: "*/ w w 1" },
    { name: "q3", formula: "*/ ah ah 1" },
    { name: "q4", formula: "+- q2 0 q3" },
    { name: "q5", formula: "sqrt q4" },
    { name: "dy", formula: "*/ q5 hR w" },
    { name: "y5", formula: "+- hR dy 0" },
    { name: "y7", formula: "+- y3 dy 0" },
    { name: "q6", formula: "+- aw 0 th" },
    { name: "dh", formula: "*/ q6 1 2" },
    { name: "y4", formula: "+- y5 0 dh" },
    { name: "y8", formula: "+- y7 dh 0" },
    { name: "aw2", formula: "*/ aw 1 2" },
    { name: "y6", formula: "+- b 0 aw2" },
    { name: "x1", formula: "+- r 0 ah" },
    { name: "swAng", formula: "at2 ah dy" },
    { name: "stAng", formula: "+- cd2 0 swAng" },
    { name: "mswAng", formula: "+- 0 0 swAng" },
    { name: "ix", formula: "+- r 0 idx" },
    { name: "iy", formula: "+/ hR y3 2" },
    { name: "q12", formula: "*/ th 1 2" },
    { name: "dang2", formula: "at2 idx q12" },
    { name: "swAng2", formula: "+- dang2 0 cd4" },
    { name: "swAng3", formula: "+- cd4 dang2 0" },
    { name: "stAng3", formula: "+- cd2 0 dang2" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let r = g(local, "r")
  let width = g(local, "w")
  let h_r = g(local, "hR")
  let x1 = g(local, "x1")
  let y4 = g(local, "y4")
  let y6 = g(local, "y6")
  let y7 = g(local, "y7")
  let y8 = g(local, "y8")
  let st_ang = g(local, "stAng")
  let sw_ang = g(local, "swAng")
  let msw_ang = g(local, "mswAng")
  let cd2 = g(local, "cd2")
  build_arrow_path([
    MoveTo(l, h_r),
    ArcTo(width, h_r, cd2, msw_ang, 0.0, 0.0),
    LineTo(x1, y4),
    LineTo(r, y6),
    LineTo(x1, y8),
    LineTo(x1, y7),
    ArcTo(width, h_r, st_ang, sw_ang, 0.0, 0.0),
    Close,
  ])
}

///|
/// `curvedLeftArrow` — preset-shapes.ts:2175
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
    { name: "y3", formula: "+- hR th 0" },
    { name: "q2", formula: "*/ w w 1" },
    { name: "q3", formula: "*/ ah ah 1" },
    { name: "q4", formula: "+- q2 0 q3" },
    { name: "q5", formula: "sqrt q4" },
    { name: "dy", formula: "*/ q5 hR w" },
    { name: "y5", formula: "+- hR dy 0" },
    { name: "y7", formula: "+- y3 dy 0" },
    { name: "q6", formula: "+- aw 0 th" },
    { name: "dh", formula: "*/ q6 1 2" },
    { name: "y4", formula: "+- y5 0 dh" },
    { name: "y8", formula: "+- y7 dh 0" },
    { name: "aw2", formula: "*/ aw 1 2" },
    { name: "y6", formula: "+- b 0 aw2" },
    { name: "x1", formula: "+- l ah 0" },
    { name: "swAng", formula: "at2 ah dy" },
    { name: "mswAng", formula: "+- 0 0 swAng" },
    { name: "ix", formula: "+- l idx 0" },
    { name: "iy", formula: "+/ hR y3 2" },
    { name: "q12", formula: "*/ th 1 2" },
    { name: "dang2", formula: "at2 idx q12" },
    { name: "swAng2", formula: "+- dang2 0 swAng" },
    { name: "swAng3", formula: "+- swAng dang2 0" },
    { name: "stAng3", formula: "+- 0 0 dang2" },
  ]
  evaluate_guides(guides, local)
  let l = g(local, "l")
  let width = g(local, "w")
  let h_r = g(local, "hR")
  let x1 = g(local, "x1")
  let y4 = g(local, "y4")
  let y5 = g(local, "y5")
  let y6 = g(local, "y6")
  let y8 = g(local, "y8")
  let sw_ang = g(local, "swAng")
  let sw_ang2 = g(local, "swAng2")
  let st_ang3 = g(local, "stAng3")
  let sw_ang3 = g(local, "swAng3")
  build_arrow_path([
    MoveTo(l, y6),
    LineTo(x1, y4),
    LineTo(x1, y5),
    ArcTo(width, h_r, sw_ang, sw_ang2, 0.0, 0.0),
    ArcTo(width, h_r, st_ang3, sw_ang3, 0.0, 0.0),
    LineTo(x1, y8),
    Close,
  ])
}

///|
/// `curvedUpArrow` — preset-shapes.ts:2258
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
    { name: "x5", formula: "+- wR dx 0" },
    { name: "x7", formula: "+- x3 dx 0" },
    { name: "q6", formula: "+- aw 0 th" },
    { name: "dh", formula: "*/ q6 1 2" },
    { name: "x4", formula: "+- x5 0 dh" },
    { name: "x8", formula: "+- x7 dh 0" },
    { name: "aw2", formula: "*/ aw 1 2" },
    { name: "x6", formula: "+- r 0 aw2" },
    { name: "y1", formula: "+- t ah 0" },
    { name: "swAng", formula: "at2 ah dx" },
    { name: "mswAng", formula: "+- 0 0 swAng" },
    { name: "iy", formula: "+- t idy 0" },
    { name: "ix", formula: "+/ wR x3 2" },
    { name: "q12", formula: "*/ th 1 2" },
    { name: "dang2", formula: "at2 idy q12" },
    { name: "swAng2", formula: "+- dang2 0 swAng" },
    { name: "mswAng2", formula: "+- 0 0 swAng2" },
    { name: "stAng3", formula: "+- cd4 0 swAng" },
    { name: "swAng3", formula: "+- swAng dang2 0" },
    { name: "stAng2", formula: "+- cd4 0 dang2" },
  ]
  evaluate_guides(guides, local)
  let t = g(local, "t")
  let x6 = g(local, "x6")
  let x8 = g(local, "x8")
  let x7 = g(local, "x7")
  let y1 = g(local, "y1")
  let w_r = g(local, "wR")
  let height = g(local, "h")
  let st_ang3 = g(local, "stAng3")
  let sw_ang3 = g(local, "swAng3")
  let st_ang2 = g(local, "stAng2")
  let sw_ang2 = g(local, "swAng2")
  let x4 = g(local, "x4")
  build_arrow_path([
    MoveTo(x6, t),
    LineTo(x8, y1),
    LineTo(x7, y1),
    ArcTo(w_r, height, st_ang3, sw_ang3, 0.0, 0.0),
    ArcTo(w_r, height, st_ang2, sw_ang2, 0.0, 0.0),
    LineTo(x4, y1),
    Close,
  ])
}

///|
/// `curvedDownArrow` — preset-shapes.ts:2343
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
    { name: "x5", formula: "+- wR dx 0" },
    { name: "x7", formula: "+- x3 dx 0" },
    { name: "q6", formula: "+- aw 0 th" },
    { name: "dh", formula: "*/ q6 1 2" },
    { name: "x4", formula: "+- x5 0 dh" },
    { name: "x8", formula: "+- x7 dh 0" },
    { name: "aw2", formula: "*/ aw 1 2" },
    { name: "x6", formula: "+- r 0 aw2" },
    { name: "y1", formula: "+- b 0 ah" },
    { name: "swAng", formula: "at2 ah dx" },
    { name: "mswAng", formula: "+- 0 0 swAng" },
    { name: "iy", formula: "+- b 0 idy" },
    { name: "ix", formula: "+/ wR x3 2" },
    { name: "q12", formula: "*/ th 1 2" },
    { name: "dang2", formula: "at2 idy q12" },
    { name: "stAng", formula: "+- 3cd4 swAng 0" },
    { name: "stAng2", formula: "+- 3cd4 0 dang2" },
    { name: "swAng2", formula: "+- dang2 0 cd4" },
    { name: "swAng3", formula: "+- cd4 dang2 0" },
  ]
  evaluate_guides(guides, local)
  let b = g(local, "b")
  let x6 = g(local, "x6")
  let x4 = g(local, "x4")
  let x5 = g(local, "x5")
  let y1 = g(local, "y1")
  let w_r = g(local, "wR")
  let height = g(local, "h")
  let st_ang = g(local, "stAng")
  let msw_ang = g(local, "mswAng")
  let x3 = g(local, "x3")
  let sw_ang = g(local, "swAng")
  let x8 = g(local, "x8")
  let three_cd4 = g(local, "3cd4")
  let t = g(local, "t")
  build_arrow_path([
    MoveTo(x6, b),
    LineTo(x4, y1),
    LineTo(x5, y1),
    ArcTo(w_r, height, st_ang, msw_ang, 0.0, 0.0),
    LineTo(x3, t),
    ArcTo(w_r, height, three_cd4, sw_ang, 0.0, 0.0),
    LineTo(x8, y1),
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
