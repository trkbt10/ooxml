// @source web-pptx packages/@aurochs-renderer/drawing-ml/src/svg/geometry/preset-shapes.ts
//
// Preset callout shapes.  Each renderer mirrors the corresponding TS
// arrow function in `preset-shapes.ts` 1:1; line numbers in each
// `@source` tag refer to that file.
//
// Owned presets:
//   wedgeRectCallout, wedgeRoundRectCallout, wedgeEllipseCallout,
//   cloudCallout,
//   callout1, callout2, callout3,
//   accentCallout1, accentCallout2, accentCallout3,
//   borderCallout1, borderCallout2, borderCallout3,
//   accentBorderCallout1, accentBorderCallout2, accentBorderCallout3.
//
// Adjust-value conventions (all numbers are ECMA-376 1/1000 of a
// percent, i.e. 100000 == 100%):
//   adj1 — tail X offset from horizontal centre (default -20833)
//   adj2 — tail Y position as percent of height  (default  62500)
//   adj3 — box width as percent of w             (default 100000)
//   adj4 — box height as percent of h            (default 100000)
//   adj5 — bend Y as percent of height           (default  50000)
//   adj6 — bend X as percent of width            (default  50000)

///|
/// Common tail-coordinate helper — `tailX = w * (adj1/100000 + 0.5)`,
/// `tailY = h * (adj2/100000)`.
fn callout_tail(w : Double, h : Double, ctx : GuideContext) -> (Double, Double) {
  let adj1 = ctx.get("adj1").unwrap_or(-20833.0)
  let adj2 = ctx.get("adj2").unwrap_or(62500.0)
  let tail_x = w * (adj1 / 100000.0 + 0.5)
  let tail_y = h * (adj2 / 100000.0)
  (tail_x, tail_y)
}

///|
/// Common box-dimension helper — `boxW = w * adj3/100000`,
/// `boxH = h * adj4/100000`.
fn callout_box(w : Double, h : Double, ctx : GuideContext) -> (Double, Double) {
  let adj3 = ctx.get("adj3").unwrap_or(100000.0)
  let adj4 = ctx.get("adj4").unwrap_or(100000.0)
  (w * adj3 / 100000.0, h * adj4 / 100000.0)
}

///|
/// Plain rectangle path used by every callout body.
fn callout_rect_path(box_w : Double, box_h : Double) -> String {
  "M 0 0 L " +
  fmt(box_w) +
  " 0 L " +
  fmt(box_w) +
  " " +
  fmt(box_h) +
  " L 0 " +
  fmt(box_h) +
  " Z"
}

///|
/// Accent-bar prefix used by accent / accentBorder callouts.
fn accent_path(accent_w : Double, box_h : Double) -> String {
  "M 0 0 L " +
  fmt(accent_w) +
  " 0 L " +
  fmt(accent_w) +
  " " +
  fmt(box_h) +
  " L 0 " +
  fmt(box_h) +
  " Z"
}

///|
/// Body rectangle abutting the accent bar, used by accent callouts.
/// Earlier revisions used `accent_w * 2.0` as the body's left edge so
/// the accent bar visually sat apart from the body, but LibreOffice
/// renders the accent variants as ONE contiguous fill with no gap (the
/// accent bar takes the same brush as the body, so any unfilled
/// strip between the two paints as a white stripe inside the shape).
/// The body now starts exactly at `accent_w` so the two sub-paths
/// share an edge.
fn callout_rect_path_offset(
  accent_w : Double,
  box_w : Double,
  box_h : Double,
) -> String {
  " M " +
  fmt(accent_w) +
  " 0 L " +
  fmt(box_w) +
  " 0 L " +
  fmt(box_w) +
  " " +
  fmt(box_h) +
  " L " +
  fmt(accent_w) +
  " " +
  fmt(box_h) +
  " Z"
}

///|
/// Spec-conformant tail tip for the wedge presets — `tipX = w/2 +
/// w*adj1/100000`, `tipY = h/2 + h*adj2/100000`. Distinct from
/// `callout_tail` which uses the leader-line callouts' convention
/// where `adj2` is an absolute Y. With the default avLst
/// (`adj1=-20833, adj2=62500`) the tip lands at `(0.291w, 1.125h)`,
/// i.e. below the body.
fn wedge_tip(w : Double, h : Double, ctx : GuideContext) -> (Double, Double) {
  let adj1 = ctx.get("adj1").unwrap_or(-20833.0)
  let adj2 = ctx.get("adj2").unwrap_or(62500.0)
  let tip_x = w * (adj1 / 100000.0 + 0.5)
  let tip_y = h * (adj2 / 100000.0 + 0.5)
  (tip_x, tip_y)
}

///|
/// Wedge-base helper — picks two guide points on the body edge nearest
/// the tip direction. With the spec defaults the tip sits below the
/// body, so the base spans the bottom edge between `w·2/12` and
/// `w·5/12` (see §20.1.10.56 `wedgeRectCallout` guide list).
fn wedge_base_bottom(w : Double) -> (Double, Double) {
  (w * 2.0 / 12.0, w * 5.0 / 12.0)
}

///|
/// `wedgeRectCallout` — rectangle body with a single triangular tail
/// pointing to (tip_x, tip_y).  §20.1.10.56.  The body fills the
/// entire `w×h` frame; the wedge is spliced into whichever edge faces
/// the tip (bottom edge for the default adjustments).
fn callout_wedge_rect(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tip_x, tip_y) = wedge_tip(w, h, ctx)
  let (base_left, base_right) = wedge_base_bottom(w)
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L " +
  fmt(base_right) +
  " " +
  fmt(h) +
  " L " +
  fmt(tip_x) +
  " " +
  fmt(tip_y) +
  " L " +
  fmt(base_left) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `wedgeRoundRectCallout` — rounded-corner rectangle body with tail.
/// §20.1.10.56.  Same wedge placement as `wedgeRectCallout`; the
/// corners use radius `ss·adj3/100000` with `ss = min(w,h)` and a
/// default `adj3 = 16667`.
fn callout_wedge_round_rect(
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String {
  let (tip_x, tip_y) = wedge_tip(w, h, ctx)
  let (base_left, base_right) = wedge_base_bottom(w)
  let ss = if w < h { w } else { h }
  let adj3 = ctx.get("adj3").unwrap_or(16667.0)
  let r = ss * adj3 / 100000.0
  "M " +
  fmt(r) +
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
  fmt(base_right) +
  " " +
  fmt(h) +
  " L " +
  fmt(tip_x) +
  " " +
  fmt(tip_y) +
  " L " +
  fmt(base_left) +
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
  " L 0 " +
  fmt(r) +
  " Q 0 0 " +
  fmt(r) +
  " 0 Z"
}

///|
/// `wedgeEllipseCallout` — elliptical body with tail.  §20.1.10.56.
///
/// The body fills the full `w×h` frame (centre `(w/2, h/2)`, radii
/// `(w/2, h/2)`). The wedge base is the two perimeter points 6°
/// either side of the centre→tip direction. The path traces from the
/// tip to the first base point, sweeps the ellipse the long way round
/// in two ≤180° arcs (via the perimeter point diametrically opposite
/// the tip direction), then closes back to the tip.
fn callout_wedge_ellipse(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tip_x, tip_y) = wedge_tip(w, h, ctx)
  let cx = w / 2.0
  let cy = h / 2.0
  let rx = w / 2.0
  let ry = h / 2.0
  // Direction centre→tip in degrees, computed in the ellipse's own
  // metric (scale tip offsets by 1/rx, 1/ry before atan2). dy>0
  // (tip below) maps to ang≈90° in the SVG screen frame.
  let dx = tip_x - cx
  let dy = tip_y - cy
  let ang = atan2_deg(dy / ry, dx / rx)
  let a1 = ang - 6.0
  let a2 = ang + 6.0
  let bx1 = cx + rx * cos_deg(a1)
  let by1 = cy + ry * sin_deg(a1)
  let bx2 = cx + rx * cos_deg(a2)
  let by2 = cy + ry * sin_deg(a2)
  let amid = ang + 180.0
  let mx = cx + rx * cos_deg(amid)
  let my = cy + ry * sin_deg(amid)
  "M " +
  fmt(tip_x) +
  " " +
  fmt(tip_y) +
  " L " +
  fmt(bx1) +
  " " +
  fmt(by1) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 0 " +
  fmt(mx) +
  " " +
  fmt(my) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 0 " +
  fmt(bx2) +
  " " +
  fmt(by2) +
  " L " +
  fmt(tip_x) +
  " " +
  fmt(tip_y) +
  " Z"
}

///|
/// Floating-point arctan2 in degrees, range [-180, 180]. Used only by
/// callout renderers.
fn atan2_deg(y : Double, x : Double) -> Double {
  let rad = @math.atan2(y, x)
  rad * 180.0 / 3.141592653589793
}

///|
/// Cosine of an angle expressed in degrees.
fn cos_deg(deg : Double) -> Double {
  @math.cos(deg * 3.141592653589793 / 180.0)
}

///|
/// Sine of an angle expressed in degrees.
fn sin_deg(deg : Double) -> Double {
  @math.sin(deg * 3.141592653589793 / 180.0)
}

///|
/// `cloudCallout` — cloud body plus three trailing bubbles leading to
/// the tail.  §20.1.10.56.
///
/// The cloud body occupies the full `w×h` frame; the trailing bubbles
/// extend from the cloud edge toward the target point `(tip_x, tip_y)`
/// computed with the offset-from-centre convention (see `wedge_tip`).
/// With the default avLst the target sits below the cloud, so the
/// bubbles march downward.
fn callout_cloud(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = wedge_tip(w, h, ctx)
  let cloud_h = h
  let buf = StringBuilder::new()
  // Cloud body — same cubic-bezier sequence as the `cloud` preset but
  // scaled vertically to `cloud_h`.
  buf.write_string("M " + fmt(w * 0.15) + " " + fmt(cloud_h * 0.6) + " ")
  buf.write_string(
    "C " +
    fmt(w * -0.05) +
    " " +
    fmt(cloud_h * 0.6) +
    " " +
    fmt(w * -0.05) +
    " " +
    fmt(cloud_h * 0.25) +
    " " +
    fmt(w * 0.15) +
    " " +
    fmt(cloud_h * 0.25) +
    " ",
  )
  buf.write_string(
    "C " +
    fmt(w * 0.1) +
    " " +
    fmt(cloud_h * 0.05) +
    " " +
    fmt(w * 0.3) +
    " " +
    fmt(cloud_h * -0.05) +
    " " +
    fmt(w * 0.4) +
    " " +
    fmt(cloud_h * 0.15) +
    " ",
  )
  buf.write_string(
    "C " +
    fmt(w * 0.45) +
    " " +
    fmt(cloud_h * -0.05) +
    " " +
    fmt(w * 0.65) +
    " " +
    fmt(cloud_h * -0.05) +
    " " +
    fmt(w * 0.7) +
    " " +
    fmt(cloud_h * 0.15) +
    " ",
  )
  buf.write_string(
    "C " +
    fmt(w * 0.85) +
    " " +
    fmt(cloud_h * 0.0) +
    " " +
    fmt(w * 1.1) +
    " " +
    fmt(cloud_h * 0.2) +
    " " +
    fmt(w * 0.9) +
    " " +
    fmt(cloud_h * 0.45) +
    " ",
  )
  buf.write_string(
    "C " +
    fmt(w * 1.1) +
    " " +
    fmt(cloud_h * 0.55) +
    " " +
    fmt(w * 1.05) +
    " " +
    fmt(cloud_h * 0.85) +
    " " +
    fmt(w * 0.8) +
    " " +
    fmt(cloud_h * 0.8) +
    " ",
  )
  buf.write_string(
    "C " +
    fmt(w * 0.8) +
    " " +
    fmt(cloud_h * 1.0) +
    " " +
    fmt(w * 0.55) +
    " " +
    fmt(cloud_h * 1.05) +
    " " +
    fmt(w * 0.45) +
    " " +
    fmt(cloud_h * 0.85) +
    " ",
  )
  buf.write_string(
    "C " +
    fmt(w * 0.3) +
    " " +
    fmt(cloud_h * 1.0) +
    " " +
    fmt(w * 0.1) +
    " " +
    fmt(cloud_h * 0.95) +
    " " +
    fmt(w * 0.15) +
    " " +
    fmt(cloud_h * 0.6) +
    " Z",
  )
  // Trailing thought bubbles — three circles of decreasing radius
  // marching from a point on the cloud's lower edge toward the
  // callout target. The first bubble sits just below the cloud near
  // the cloud-edge anchor; the third sits AT the target.
  let anchor_x = w * 0.45
  let anchor_y = cloud_h * 0.92
  let bubble1_x = anchor_x + (tail_x - anchor_x) * 0.35
  let bubble1_y = anchor_y + (tail_y - anchor_y) * 0.35
  let bubble1_r = w * 0.035
  let bubble2_x = anchor_x + (tail_x - anchor_x) * 0.7
  let bubble2_y = anchor_y + (tail_y - anchor_y) * 0.7
  let bubble2_r = w * 0.022
  let bubble3_x = tail_x
  let bubble3_y = tail_y
  let bubble3_r = w * 0.013
  buf.write_string(
    " M " +
    fmt(bubble1_x + bubble1_r) +
    " " +
    fmt(bubble1_y) +
    " A " +
    fmt(bubble1_r) +
    " " +
    fmt(bubble1_r) +
    " 0 1 1 " +
    fmt(bubble1_x - bubble1_r) +
    " " +
    fmt(bubble1_y) +
    " A " +
    fmt(bubble1_r) +
    " " +
    fmt(bubble1_r) +
    " 0 1 1 " +
    fmt(bubble1_x + bubble1_r) +
    " " +
    fmt(bubble1_y) +
    " Z",
  )
  buf.write_string(
    " M " +
    fmt(bubble2_x + bubble2_r) +
    " " +
    fmt(bubble2_y) +
    " A " +
    fmt(bubble2_r) +
    " " +
    fmt(bubble2_r) +
    " 0 1 1 " +
    fmt(bubble2_x - bubble2_r) +
    " " +
    fmt(bubble2_y) +
    " A " +
    fmt(bubble2_r) +
    " " +
    fmt(bubble2_r) +
    " 0 1 1 " +
    fmt(bubble2_x + bubble2_r) +
    " " +
    fmt(bubble2_y) +
    " Z",
  )
  buf.write_string(
    " M " +
    fmt(bubble3_x + bubble3_r) +
    " " +
    fmt(bubble3_y) +
    " A " +
    fmt(bubble3_r) +
    " " +
    fmt(bubble3_r) +
    " 0 1 1 " +
    fmt(bubble3_x - bubble3_r) +
    " " +
    fmt(bubble3_y) +
    " A " +
    fmt(bubble3_r) +
    " " +
    fmt(bubble3_r) +
    " 0 1 1 " +
    fmt(bubble3_x + bubble3_r) +
    " " +
    fmt(bubble3_y) +
    " Z",
  )
  buf.to_string()
}

///|
/// `callout1` — plain rectangle body.  preset-shapes.ts:3540
///
/// ECMA-376 specifies a stroked leader line from the body to the tail
/// tip, but the renderer paints every preset as a single filled path
/// with no stroke override per sub-element. Concatenating a `M ... L`
/// leader onto a closed body fills the triangular wedge between the
/// edge crossing and the tail with the body brush — visible as a
/// stripe or notch inside or outside the box.  LibreOffice and
/// PowerPoint do not draw the leader as a fill either; with their
/// default styling the leader simply isn't visible. We mirror that by
/// emitting JUST the body rectangle — every callout1/2/3 + accent +
/// border variant (which all share these helpers) drops the leader.
fn callout_1(w : Double, h : Double, ctx : GuideContext) -> String {
  let (_, _) = callout_tail(w, h, ctx)
  let (box_w, box_h) = callout_box(w, h, ctx)
  callout_rect_path(box_w, box_h)
}

///|
/// `callout2` — rectangle body.  preset-shapes.ts:3560.  See
/// `callout_1` for why the bent leader is omitted.
fn callout_2(w : Double, h : Double, ctx : GuideContext) -> String {
  let _ = ctx
  let (box_w, box_h) = callout_box(w, h, ctx)
  callout_rect_path(box_w, box_h)
}

///|
/// `callout3` — rectangle body.  preset-shapes.ts:3582. See
/// `callout_1` for why the twice-bent leader is omitted.
fn callout_3(w : Double, h : Double, ctx : GuideContext) -> String {
  let _ = ctx
  let (box_w, box_h) = callout_box(w, h, ctx)
  callout_rect_path(box_w, box_h)
}

///|
/// `accentCallout1` — `callout1` prefixed with a thin accent bar on
/// the left edge.  preset-shapes.ts:3605. See `callout_1` for why
/// the leader is omitted entirely.
fn callout_accent_1(w : Double, h : Double, ctx : GuideContext) -> String {
  let _ = ctx
  let (box_w, box_h) = callout_box(w, h, ctx)
  let accent_w = w * 0.02
  let accent = accent_path(accent_w, box_h)
  let rect = callout_rect_path_offset(accent_w, box_w, box_h)
  accent + rect
}

///|
/// `accentCallout2` — `callout2` with accent bar.
/// preset-shapes.ts:3629. See `callout_1` for why the leader is omitted.
fn callout_accent_2(w : Double, h : Double, ctx : GuideContext) -> String {
  let _ = ctx
  let (box_w, box_h) = callout_box(w, h, ctx)
  let accent_w = w * 0.02
  let accent = accent_path(accent_w, box_h)
  let rect = callout_rect_path_offset(accent_w, box_w, box_h)
  accent + rect
}

///|
/// `accentCallout3` — `callout3` with accent bar.
/// preset-shapes.ts:3655. See `callout_1` for why the leader is omitted.
fn callout_accent_3(w : Double, h : Double, ctx : GuideContext) -> String {
  let _ = ctx
  let (box_w, box_h) = callout_box(w, h, ctx)
  let accent_w = w * 0.02
  let accent = accent_path(accent_w, box_h)
  let rect = callout_rect_path_offset(accent_w, box_w, box_h)
  accent + rect
}

///|
/// `borderCallout1` — visually identical path data to `callout1`; the
/// border styling differs only in stroke attributes applied higher up
/// the pipeline.  preset-shapes.ts:3682. See `callout_1` for why
/// the leader is omitted.
fn callout_border_1(w : Double, h : Double, ctx : GuideContext) -> String {
  let _ = ctx
  let (box_w, box_h) = callout_box(w, h, ctx)
  callout_rect_path(box_w, box_h)
}

///|
/// `borderCallout2` — same path data as `callout2`.
/// preset-shapes.ts:3702. See `callout_1` for why the leader is omitted.
fn callout_border_2(w : Double, h : Double, ctx : GuideContext) -> String {
  let _ = ctx
  let (box_w, box_h) = callout_box(w, h, ctx)
  callout_rect_path(box_w, box_h)
}

///|
/// `borderCallout3` — same path data as `callout3`.
/// preset-shapes.ts:3724. See `callout_1` for why the leader is omitted.
fn callout_border_3(w : Double, h : Double, ctx : GuideContext) -> String {
  let _ = ctx
  let (box_w, box_h) = callout_box(w, h, ctx)
  callout_rect_path(box_w, box_h)
}

///|
/// `accentBorderCallout1` — same path data as `accentCallout1`.
/// preset-shapes.ts:3747
fn callout_accent_border_1(
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String {
  callout_accent_1(w, h, ctx)
}

///|
/// `accentBorderCallout2` — same path data as `accentCallout2`.
/// preset-shapes.ts:3771
fn callout_accent_border_2(
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String {
  callout_accent_2(w, h, ctx)
}

///|
/// `accentBorderCallout3` — same path data as `accentCallout3`.
/// preset-shapes.ts:3797
fn callout_accent_border_3(
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String {
  callout_accent_3(w, h, ctx)
}

///|
/// Dispatcher entry point.  Returns `Some(path)` for every callout
/// preset listed at the top of the file, `None` otherwise.
fn dispatch_callout(
  preset : String,
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String? {
  match preset {
    "wedgeRectCallout" => Some(callout_wedge_rect(w, h, ctx))
    "wedgeRoundRectCallout" => Some(callout_wedge_round_rect(w, h, ctx))
    "wedgeEllipseCallout" => Some(callout_wedge_ellipse(w, h, ctx))
    "cloudCallout" => Some(callout_cloud(w, h, ctx))
    "callout1" => Some(callout_1(w, h, ctx))
    "callout2" => Some(callout_2(w, h, ctx))
    "callout3" => Some(callout_3(w, h, ctx))
    "accentCallout1" => Some(callout_accent_1(w, h, ctx))
    "accentCallout2" => Some(callout_accent_2(w, h, ctx))
    "accentCallout3" => Some(callout_accent_3(w, h, ctx))
    "borderCallout1" => Some(callout_border_1(w, h, ctx))
    "borderCallout2" => Some(callout_border_2(w, h, ctx))
    "borderCallout3" => Some(callout_border_3(w, h, ctx))
    "accentBorderCallout1" => Some(callout_accent_border_1(w, h, ctx))
    "accentBorderCallout2" => Some(callout_accent_border_2(w, h, ctx))
    "accentBorderCallout3" => Some(callout_accent_border_3(w, h, ctx))
    _ => None
  }
}
