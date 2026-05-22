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
/// Body rectangle offset by `accent_w * 2`, used by accent callouts.
fn callout_rect_path_offset(
  accent_w : Double,
  box_w : Double,
  box_h : Double,
) -> String {
  " M " +
  fmt(accent_w * 2.0) +
  " 0 L " +
  fmt(box_w) +
  " 0 L " +
  fmt(box_w) +
  " " +
  fmt(box_h) +
  " L " +
  fmt(accent_w * 2.0) +
  " " +
  fmt(box_h) +
  " Z"
}

///|
/// `wedgeRectCallout` — rectangle body with a single triangular tail
/// pointing to (tail_x, tail_y).  preset-shapes.ts:3439
fn callout_wedge_rect(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let main_h = h * 0.7
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(main_h) +
  " L " +
  fmt(w * 0.6) +
  " " +
  fmt(main_h) +
  " L " +
  fmt(tail_x) +
  " " +
  fmt(tail_y) +
  " L " +
  fmt(w * 0.4) +
  " " +
  fmt(main_h) +
  " L 0 " +
  fmt(main_h) +
  " Z"
}

///|
/// `wedgeRoundRectCallout` — rounded-corner rectangle body with tail.
/// preset-shapes.ts:3451
fn callout_wedge_round_rect(
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let main_h = h * 0.7
  let min_dim = if w < main_h { w } else { main_h }
  let r = min_dim * 0.1
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
  fmt(main_h - r) +
  " Q " +
  fmt(w) +
  " " +
  fmt(main_h) +
  " " +
  fmt(w - r) +
  " " +
  fmt(main_h) +
  " L " +
  fmt(w * 0.6) +
  " " +
  fmt(main_h) +
  " L " +
  fmt(tail_x) +
  " " +
  fmt(tail_y) +
  " L " +
  fmt(w * 0.4) +
  " " +
  fmt(main_h) +
  " L " +
  fmt(r) +
  " " +
  fmt(main_h) +
  " Q 0 " +
  fmt(main_h) +
  " 0 " +
  fmt(main_h - r) +
  " L 0 " +
  fmt(r) +
  " Q 0 0 " +
  fmt(r) +
  " 0 Z"
}

///|
/// `wedgeEllipseCallout` — elliptical body with tail.
/// preset-shapes.ts:3464
fn callout_wedge_ellipse(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let rx = w / 2.0
  let ry = h * 0.35
  "M " +
  fmt(rx) +
  " 0 A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(rx) +
  " " +
  fmt(ry * 2.0) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 1 " +
  fmt(w * 0.6) +
  " " +
  fmt(ry * 1.9) +
  " L " +
  fmt(tail_x) +
  " " +
  fmt(tail_y) +
  " L " +
  fmt(w * 0.4) +
  " " +
  fmt(ry * 1.9) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 1 " +
  fmt(rx) +
  " 0 Z"
}

///|
/// `cloudCallout` — cloud body plus three trailing bubbles leading to
/// the tail.  preset-shapes.ts:3497
fn callout_cloud(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let cloud_h = h * 0.7
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
  // Trailing thought bubbles — three circles of decreasing radius from
  // the cloud body toward the tail tip.
  let bubble1_x = w * 0.4
  let bubble1_y = cloud_h * 0.95
  let bubble1_r = w * 0.04
  let bubble2_x = (bubble1_x + tail_x) / 2.0
  let bubble2_y = (bubble1_y + tail_y) / 2.0
  let bubble2_r = w * 0.025
  let bubble3_x = tail_x
  let bubble3_y = tail_y
  let bubble3_r = w * 0.015
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
/// `callout1` — plain rectangle with a single straight line to the
/// tail tip.  preset-shapes.ts:3540
fn callout_1(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let (box_w, box_h) = callout_box(w, h, ctx)
  let rect = callout_rect_path(box_w, box_h)
  let line = " M " +
    fmt(box_w / 2.0) +
    " " +
    fmt(box_h) +
    " L " +
    fmt(tail_x) +
    " " +
    fmt(tail_y)
  rect + line
}

///|
/// `callout2` — rectangle with a once-bent leader line: bottom-centre →
/// (mid, bendY) → (tail_x, tail_y).  preset-shapes.ts:3560
fn callout_2(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let (box_w, box_h) = callout_box(w, h, ctx)
  let bend_y = h * ctx.get("adj5").unwrap_or(50000.0) / 100000.0
  let rect = callout_rect_path(box_w, box_h)
  let mid_x = box_w / 2.0
  let line = " M " +
    fmt(mid_x) +
    " " +
    fmt(box_h) +
    " L " +
    fmt(mid_x) +
    " " +
    fmt(bend_y) +
    " L " +
    fmt(tail_x) +
    " " +
    fmt(tail_y)
  rect + line
}

///|
/// `callout3` — rectangle with a twice-bent leader line.
/// preset-shapes.ts:3582
fn callout_3(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let (box_w, box_h) = callout_box(w, h, ctx)
  let bend_y1 = h * ctx.get("adj5").unwrap_or(50000.0) / 100000.0
  let bend_x = w * ctx.get("adj6").unwrap_or(50000.0) / 100000.0
  let rect = callout_rect_path(box_w, box_h)
  let mid_x = box_w / 2.0
  let line = " M " +
    fmt(mid_x) +
    " " +
    fmt(box_h) +
    " L " +
    fmt(mid_x) +
    " " +
    fmt(bend_y1) +
    " L " +
    fmt(bend_x) +
    " " +
    fmt(bend_y1) +
    " L " +
    fmt(tail_x) +
    " " +
    fmt(tail_y)
  rect + line
}

///|
/// `accentCallout1` — `callout1` prefixed with a thin accent bar on
/// the left edge.  preset-shapes.ts:3605
fn callout_accent_1(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let (box_w, box_h) = callout_box(w, h, ctx)
  let accent_w = w * 0.02
  let accent = accent_path(accent_w, box_h)
  let rect = callout_rect_path_offset(accent_w, box_w, box_h)
  let line = " M " +
    fmt(box_w / 2.0) +
    " " +
    fmt(box_h) +
    " L " +
    fmt(tail_x) +
    " " +
    fmt(tail_y)
  accent + rect + line
}

///|
/// `accentCallout2` — `callout2` with accent bar.
/// preset-shapes.ts:3629
fn callout_accent_2(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let (box_w, box_h) = callout_box(w, h, ctx)
  let bend_y = h * ctx.get("adj5").unwrap_or(50000.0) / 100000.0
  let accent_w = w * 0.02
  let accent = accent_path(accent_w, box_h)
  let rect = callout_rect_path_offset(accent_w, box_w, box_h)
  let mid_x = box_w / 2.0
  let line = " M " +
    fmt(mid_x) +
    " " +
    fmt(box_h) +
    " L " +
    fmt(mid_x) +
    " " +
    fmt(bend_y) +
    " L " +
    fmt(tail_x) +
    " " +
    fmt(tail_y)
  accent + rect + line
}

///|
/// `accentCallout3` — `callout3` with accent bar.
/// preset-shapes.ts:3655
fn callout_accent_3(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let (box_w, box_h) = callout_box(w, h, ctx)
  let bend_y1 = h * ctx.get("adj5").unwrap_or(50000.0) / 100000.0
  let bend_x = w * ctx.get("adj6").unwrap_or(50000.0) / 100000.0
  let accent_w = w * 0.02
  let accent = accent_path(accent_w, box_h)
  let rect = callout_rect_path_offset(accent_w, box_w, box_h)
  let mid_x = box_w / 2.0
  let line = " M " +
    fmt(mid_x) +
    " " +
    fmt(box_h) +
    " L " +
    fmt(mid_x) +
    " " +
    fmt(bend_y1) +
    " L " +
    fmt(bend_x) +
    " " +
    fmt(bend_y1) +
    " L " +
    fmt(tail_x) +
    " " +
    fmt(tail_y)
  accent + rect + line
}

///|
/// `borderCallout1` — visually identical path data to `callout1`; the
/// border styling differs only in stroke attributes applied higher up
/// the pipeline.  preset-shapes.ts:3682
fn callout_border_1(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let (box_w, box_h) = callout_box(w, h, ctx)
  let rect = callout_rect_path(box_w, box_h)
  let line = " M " +
    fmt(box_w / 2.0) +
    " " +
    fmt(box_h) +
    " L " +
    fmt(tail_x) +
    " " +
    fmt(tail_y)
  rect + line
}

///|
/// `borderCallout2` — same path data as `callout2`.
/// preset-shapes.ts:3702
fn callout_border_2(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let (box_w, box_h) = callout_box(w, h, ctx)
  let bend_y = h * ctx.get("adj5").unwrap_or(50000.0) / 100000.0
  let rect = callout_rect_path(box_w, box_h)
  let mid_x = box_w / 2.0
  let line = " M " +
    fmt(mid_x) +
    " " +
    fmt(box_h) +
    " L " +
    fmt(mid_x) +
    " " +
    fmt(bend_y) +
    " L " +
    fmt(tail_x) +
    " " +
    fmt(tail_y)
  rect + line
}

///|
/// `borderCallout3` — same path data as `callout3`.
/// preset-shapes.ts:3724
fn callout_border_3(w : Double, h : Double, ctx : GuideContext) -> String {
  let (tail_x, tail_y) = callout_tail(w, h, ctx)
  let (box_w, box_h) = callout_box(w, h, ctx)
  let bend_y1 = h * ctx.get("adj5").unwrap_or(50000.0) / 100000.0
  let bend_x = w * ctx.get("adj6").unwrap_or(50000.0) / 100000.0
  let rect = callout_rect_path(box_w, box_h)
  let mid_x = box_w / 2.0
  let line = " M " +
    fmt(mid_x) +
    " " +
    fmt(box_h) +
    " L " +
    fmt(mid_x) +
    " " +
    fmt(bend_y1) +
    " L " +
    fmt(bend_x) +
    " " +
    fmt(bend_y1) +
    " L " +
    fmt(tail_x) +
    " " +
    fmt(tail_y)
  rect + line
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
