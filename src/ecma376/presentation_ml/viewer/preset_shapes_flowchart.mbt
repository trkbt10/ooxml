// Preset flowchart shapes — 29 ECMA-376 Part 1 §20.1.10.56 flowChart*
// preset shape generators ported from web-pptx.
//
// Owned presets: every preset whose name begins with "flowChart".
//
// @source web-pptx packages/@aurochs-renderer/drawing-ml/src/svg/
//         geometry/preset-shapes.ts:3124-3428

///|
/// Dispatcher for flowChart* presets.  Returns `Some(path_data)` for
/// the 29 presets we own and `None` otherwise.
fn dispatch_flowchart(
  preset : String,
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String? {
  // `ctx` is unused for flowChart presets — none of them consume
  // adjust values in the TS reference implementation.  Silence the
  // unused-parameter lint while keeping the dispatcher signature in
  // line with the rest of the geometry package.
  let _ = ctx
  match preset {
    "flowChartMerge" => Some(flowchart_merge(w, h))
    "flowChartExtract" => Some(flowchart_extract(w, h))
    "flowChartDelay" => Some(flowchart_delay(w, h))
    "flowChartProcess" => Some(flowchart_process(w, h))
    "flowChartDecision" => Some(flowchart_decision(w, h))
    "flowChartTerminator" => Some(flowchart_terminator(w, h))
    "flowChartConnector" => Some(flowchart_connector(w, h))
    "flowChartInputOutput" => Some(flowchart_input_output(w, h))
    "flowChartDocument" => Some(flowchart_document(w, h))
    "flowChartAlternateProcess" => Some(flowchart_alternate_process(w, h))
    "flowChartPredefinedProcess" => Some(flowchart_predefined_process(w, h))
    "flowChartInternalStorage" => Some(flowchart_internal_storage(w, h))
    "flowChartMultidocument" => Some(flowchart_multidocument(w, h))
    "flowChartPreparation" => Some(flowchart_preparation(w, h))
    "flowChartManualInput" => Some(flowchart_manual_input(w, h))
    "flowChartManualOperation" => Some(flowchart_manual_operation(w, h))
    "flowChartPunchedCard" => Some(flowchart_punched_card(w, h))
    "flowChartPunchedTape" => Some(flowchart_punched_tape(w, h))
    "flowChartSummingJunction" => Some(flowchart_summing_junction(w, h))
    "flowChartOr" => Some(flowchart_or(w, h))
    "flowChartCollate" => Some(flowchart_collate(w, h))
    "flowChartSort" => Some(flowchart_sort(w, h))
    "flowChartOfflineStorage" => Some(flowchart_offline_storage(w, h))
    "flowChartOnlineStorage" => Some(flowchart_online_storage(w, h))
    "flowChartMagneticTape" => Some(flowchart_magnetic_tape(w, h))
    "flowChartMagneticDisk" => Some(flowchart_magnetic_disk(w, h))
    "flowChartMagneticDrum" => Some(flowchart_magnetic_drum(w, h))
    "flowChartDisplay" => Some(flowchart_display(w, h))
    "flowChartOffpageConnector" => Some(flowchart_offpage_connector(w, h))
    _ => None
  }
}

///|
/// `flowChartMerge` — inverted triangle (apex at bottom centre).
/// @source preset-shapes.ts:3124
fn flowchart_merge(w : Double, h : Double) -> String {
  "M 0 0 L " + fmt(w) + " 0 L " + fmt(w / 2.0) + " " + fmt(h) + " Z"
}

///|
/// `flowChartExtract` — triangle pointing up (apex at top centre).
/// @source preset-shapes.ts:3131
fn flowchart_extract(w : Double, h : Double) -> String {
  "M " +
  fmt(w / 2.0) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `flowChartDelay` — half-ellipse (D shape) facing right.
/// @source preset-shapes.ts:3138
fn flowchart_delay(w : Double, h : Double) -> String {
  let rx = w / 2.0
  let ry = h / 2.0
  "M 0 0 L " +
  fmt(rx) +
  " 0 A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 1 " +
  fmt(rx) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `flowChartProcess` — full rectangle.
/// @source preset-shapes.ts:3149
fn flowchart_process(w : Double, h : Double) -> String {
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `flowChartDecision` — diamond (rhombus inscribed in the box).
/// @source preset-shapes.ts:3156
fn flowchart_decision(w : Double, h : Double) -> String {
  "M " +
  fmt(w / 2.0) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h / 2.0) +
  " L " +
  fmt(w / 2.0) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h / 2.0) +
  " Z"
}

///|
/// `flowChartTerminator` — stadium/pill shape (rounded ends).
/// @source preset-shapes.ts:3163
fn flowchart_terminator(w : Double, h : Double) -> String {
  let r = h / 2.0
  "M " +
  fmt(r) +
  " 0 L " +
  fmt(w - r) +
  " 0 A " +
  fmt(r) +
  " " +
  fmt(r) +
  " 0 0 1 " +
  fmt(w - r) +
  " " +
  fmt(h) +
  " L " +
  fmt(r) +
  " " +
  fmt(h) +
  " A " +
  fmt(r) +
  " " +
  fmt(r) +
  " 0 0 1 " +
  fmt(r) +
  " 0 Z"
}

///|
/// `flowChartConnector` — full circle/ellipse via two arc-tos.
/// @source preset-shapes.ts:3173
fn flowchart_connector(w : Double, h : Double) -> String {
  let rx = w / 2.0
  let ry = h / 2.0
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
  " 0 Z"
}

///|
/// `flowChartInputOutput` — parallelogram (top inset by 20% of width).
/// @source preset-shapes.ts:3184
fn flowchart_input_output(w : Double, h : Double) -> String {
  let offset = w * 0.2
  "M " +
  fmt(offset) +
  " 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w - offset) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `flowChartDocument` — §20.1.10.56 rectangle whose bottom edge is
/// an S-curve, asymmetric: the right half curves UP into the body
/// (a notch), the left half curves DOWN below the midline (an
/// extension), so the bottom-right corner sits ABOVE `wave_y` and
/// the bottom-left BELOW it — matching the standard PowerPoint /
/// LibreOffice render.  The earlier code placed both control points
/// on the same side, producing a "hump down both ends" shape that
/// looked like a flag bottom, not a document bottom.
fn flowchart_document(w : Double, h : Double) -> String {
  let wave_height = h * 0.1
  let wave_y = h - wave_height
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(wave_y) +
  " Q " +
  fmt(w * 0.75) +
  " " +
  fmt(wave_y - wave_height) +
  " " +
  fmt(w / 2.0) +
  " " +
  fmt(wave_y) +
  " Q " +
  fmt(w * 0.25) +
  " " +
  fmt(wave_y + wave_height) +
  " 0 " +
  fmt(wave_y) +
  " Z"
}

///|
/// `flowChartAlternateProcess` — rounded rectangle (r = 18% of min(w,h)).
/// @source preset-shapes.ts:3205
fn flowchart_alternate_process(w : Double, h : Double) -> String {
  let ss = if w < h { w } else { h }
  let r = ss * 0.18
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
/// `flowChartPredefinedProcess` — rectangle with two inner vertical lines.
/// @source preset-shapes.ts:3215
fn flowchart_predefined_process(w : Double, h : Double) -> String {
  let bar = w * 0.1
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z M " +
  fmt(bar) +
  " 0 L " +
  fmt(bar) +
  " " +
  fmt(h) +
  " M " +
  fmt(w - bar) +
  " 0 L " +
  fmt(w - bar) +
  " " +
  fmt(h)
}

///|
/// `flowChartInternalStorage` — rectangle with a top/left corner pair of lines.
/// @source preset-shapes.ts:3226
fn flowchart_internal_storage(w : Double, h : Double) -> String {
  let ss = if w < h { w } else { h }
  let offset = ss * 0.15
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z M " +
  fmt(offset) +
  " 0 L " +
  fmt(offset) +
  " " +
  fmt(h) +
  " M 0 " +
  fmt(offset) +
  " L " +
  fmt(w) +
  " " +
  fmt(offset)
}

///|
/// `flowChartMultidocument` — three stacked document shapes (offset cascade).
/// @source preset-shapes.ts:3237
fn flowchart_multidocument(w : Double, h : Double) -> String {
  let offset = w * 0.08
  let wave_height = h * 0.1
  let doc_h = h - offset * 2.0
  let wave_y = doc_h - wave_height
  // Back document
  let back = "M " +
    fmt(offset * 2.0) +
    " 0 L " +
    fmt(w) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(wave_y - offset * 2.0) +
    " Q " +
    fmt(w - w * 0.125) +
    " " +
    fmt(wave_y - offset * 2.0 + wave_height) +
    " " +
    fmt(w - w * 0.25) +
    " " +
    fmt(wave_y - offset * 2.0) +
    " Q " +
    fmt(w - w * 0.375) +
    " " +
    fmt(wave_y - offset * 2.0 - wave_height) +
    " " +
    fmt(w - w * 0.5) +
    " " +
    fmt(wave_y - offset * 2.0) +
    " L " +
    fmt(offset * 2.0) +
    " " +
    fmt(wave_y - offset * 2.0) +
    " Z "
  // Middle document
  let mid = "M " +
    fmt(offset) +
    " " +
    fmt(offset) +
    " L " +
    fmt(w - offset) +
    " " +
    fmt(offset) +
    " L " +
    fmt(w - offset) +
    " " +
    fmt(wave_y - offset) +
    " Q " +
    fmt(w - offset - w * 0.125) +
    " " +
    fmt(wave_y - offset + wave_height) +
    " " +
    fmt(w - offset - w * 0.25) +
    " " +
    fmt(wave_y - offset) +
    " Q " +
    fmt(w - offset - w * 0.375) +
    " " +
    fmt(wave_y - offset - wave_height) +
    " " +
    fmt(w - offset - w * 0.5) +
    " " +
    fmt(wave_y - offset) +
    " L " +
    fmt(offset) +
    " " +
    fmt(wave_y - offset) +
    " Z "
  // Front document
  let front = "M 0 " +
    fmt(offset * 2.0) +
    " L " +
    fmt(w - offset * 2.0) +
    " " +
    fmt(offset * 2.0) +
    " L " +
    fmt(w - offset * 2.0) +
    " " +
    fmt(wave_y) +
    " Q " +
    fmt(w - offset * 2.0 - w * 0.125) +
    " " +
    fmt(wave_y + wave_height) +
    " " +
    fmt(w - offset * 2.0 - w * 0.25) +
    " " +
    fmt(wave_y) +
    " Q " +
    fmt(w - offset * 2.0 - w * 0.375) +
    " " +
    fmt(wave_y - wave_height) +
    " " +
    fmt(w - offset * 2.0 - w * 0.5) +
    " " +
    fmt(wave_y) +
    " L 0 " +
    fmt(wave_y) +
    " Z"
  back + mid + front
}

///|
/// `flowChartPreparation` — horizontal hexagon (point on each short side).
/// @source preset-shapes.ts:3257
fn flowchart_preparation(w : Double, h : Double) -> String {
  let offset = w * 0.2
  "M " +
  fmt(offset) +
  " 0 L " +
  fmt(w - offset) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h / 2.0) +
  " L " +
  fmt(w - offset) +
  " " +
  fmt(h) +
  " L " +
  fmt(offset) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h / 2.0) +
  " Z"
}

///|
/// `flowChartManualInput` — trapezoid with slanted top (left low → right high).
/// @source preset-shapes.ts:3267
fn flowchart_manual_input(w : Double, h : Double) -> String {
  let slant = h * 0.2
  "M 0 " +
  fmt(slant) +
  " L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `flowChartManualOperation` — inverted trapezoid (wider at top).
/// @source preset-shapes.ts:3277
fn flowchart_manual_operation(w : Double, h : Double) -> String {
  let offset = w * 0.2
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w - offset) +
  " " +
  fmt(h) +
  " L " +
  fmt(offset) +
  " " +
  fmt(h) +
  " Z"
}

///|
/// `flowChartPunchedCard` — rectangle with top-left corner clipped.
/// @source preset-shapes.ts:3287
fn flowchart_punched_card(w : Double, h : Double) -> String {
  let ss = if w < h { w } else { h }
  let cut = ss * 0.2
  "M " +
  fmt(cut) +
  " 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " L 0 " +
  fmt(cut) +
  " Z"
}

///|
/// `flowChartPunchedTape` — wavy top and bottom edges (tape reel section).
/// @source preset-shapes.ts:3297
fn flowchart_punched_tape(w : Double, h : Double) -> String {
  let wave = h * 0.15
  "M 0 " +
  fmt(wave) +
  " Q " +
  fmt(w * 0.25) +
  " 0 " +
  fmt(w * 0.5) +
  " " +
  fmt(wave) +
  " Q " +
  fmt(w * 0.75) +
  " " +
  fmt(wave * 2.0) +
  " " +
  fmt(w) +
  " " +
  fmt(wave) +
  " L " +
  fmt(w) +
  " " +
  fmt(h - wave) +
  " Q " +
  fmt(w * 0.75) +
  " " +
  fmt(h) +
  " " +
  fmt(w * 0.5) +
  " " +
  fmt(h - wave) +
  " Q " +
  fmt(w * 0.25) +
  " " +
  fmt(h - wave * 2.0) +
  " 0 " +
  fmt(h - wave) +
  " Z"
}

///|
/// `flowChartSummingJunction` — circle/ellipse with an X drawn through it.
/// @source preset-shapes.ts:3307
fn flowchart_summing_junction(w : Double, h : Double) -> String {
  let rx = w / 2.0
  let ry = h / 2.0
  let cx = rx
  let cy = ry
  // cos(45°) ≈ 0.707 — TS uses the literal directly for the X arms.
  let min_r = if rx < ry { rx } else { ry }
  let offset = min_r * 0.707
  "M " +
  fmt(cx + rx) +
  " " +
  fmt(cy) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(cx - rx) +
  " " +
  fmt(cy) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(cx + rx) +
  " " +
  fmt(cy) +
  " Z M " +
  fmt(cx - offset) +
  " " +
  fmt(cy - offset) +
  " L " +
  fmt(cx + offset) +
  " " +
  fmt(cy + offset) +
  " M " +
  fmt(cx + offset) +
  " " +
  fmt(cy - offset) +
  " L " +
  fmt(cx - offset) +
  " " +
  fmt(cy + offset)
}

///|
/// `flowChartOr` — circle/ellipse with axis-aligned cross.
/// @source preset-shapes.ts:3322
fn flowchart_or(w : Double, h : Double) -> String {
  let rx = w / 2.0
  let ry = h / 2.0
  let cx = rx
  let cy = ry
  "M " +
  fmt(cx + rx) +
  " " +
  fmt(cy) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(cx - rx) +
  " " +
  fmt(cy) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(cx + rx) +
  " " +
  fmt(cy) +
  " Z M " +
  fmt(cx) +
  " 0 L " +
  fmt(cx) +
  " " +
  fmt(h) +
  " M 0 " +
  fmt(cy) +
  " L " +
  fmt(w) +
  " " +
  fmt(cy)
}

///|
/// `flowChartCollate` — two triangles forming an hourglass / bow-tie.
/// @source preset-shapes.ts:3336
fn flowchart_collate(w : Double, h : Double) -> String {
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w / 2.0) +
  " " +
  fmt(h / 2.0) +
  " L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " L " +
  fmt(w / 2.0) +
  " " +
  fmt(h / 2.0) +
  " Z"
}

///|
/// `flowChartSort` — diamond with a horizontal divider line.
/// @source preset-shapes.ts:3346
fn flowchart_sort(w : Double, h : Double) -> String {
  "M " +
  fmt(w / 2.0) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h / 2.0) +
  " L " +
  fmt(w / 2.0) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h / 2.0) +
  " Z M 0 " +
  fmt(h / 2.0) +
  " L " +
  fmt(w) +
  " " +
  fmt(h / 2.0)
}

///|
/// `flowChartOfflineStorage` — inverted triangle sitting beneath a strip rect.
/// @source preset-shapes.ts:3356
fn flowchart_offline_storage(w : Double, h : Double) -> String {
  let top_offset = h * 0.15
  "M 0 " +
  fmt(top_offset) +
  " L " +
  fmt(w) +
  " " +
  fmt(top_offset) +
  " L " +
  fmt(w / 2.0) +
  " " +
  fmt(h) +
  " Z M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(top_offset) +
  " L 0 " +
  fmt(top_offset) +
  " Z"
}

///|
/// `flowChartOnlineStorage` — half-pipe / cylinder side view.
/// @source preset-shapes.ts:3366
fn flowchart_online_storage(w : Double, h : Double) -> String {
  let curve = w * 0.2
  "M " +
  fmt(curve) +
  " 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L " +
  fmt(curve) +
  " " +
  fmt(h) +
  " Q 0 " +
  fmt(h * 0.5) +
  " " +
  fmt(curve) +
  " 0 Z"
}

///|
/// `flowChartMagneticTape` — circle with a small rectangular tail bottom-right.
/// @source preset-shapes.ts:3376
fn flowchart_magnetic_tape(w : Double, h : Double) -> String {
  let rx = w / 2.0
  let ry = h / 2.0
  let cx = rx
  let cy = ry
  "M " +
  fmt(cx + rx) +
  " " +
  fmt(cy) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(cx + rx * 0.1) +
  " " +
  fmt(cy + ry * 0.995) +
  " L " +
  fmt(cx + rx * 0.1) +
  " " +
  fmt(h) +
  " L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L " +
  fmt(w) +
  " " +
  fmt(cy + ry * 0.8) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 0 " +
  fmt(cx + rx) +
  " " +
  fmt(cy) +
  " Z"
}

///|
/// `flowChartMagneticDisk` — vertical cylinder (disk stack side view).
/// @source preset-shapes.ts:3390
fn flowchart_magnetic_disk(w : Double, h : Double) -> String {
  let ellipse_h = h * 0.15
  let rx = w / 2.0
  let ry = ellipse_h
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
  " L " +
  fmt(w) +
  " " +
  fmt(h - ry) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 1 0 " +
  fmt(h - ry) +
  " Z M 0 " +
  fmt(ry) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 0 " +
  fmt(w) +
  " " +
  fmt(ry)
}

///|
/// `flowChartMagneticDrum` — horizontal cylinder (drum side view).
/// @source preset-shapes.ts:3402
fn flowchart_magnetic_drum(w : Double, h : Double) -> String {
  let ellipse_w = w * 0.15
  let rx = ellipse_w
  let ry = h / 2.0
  "M " +
  fmt(rx) +
  " 0 L " +
  fmt(w - rx) +
  " 0 A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 1 " +
  fmt(w - rx) +
  " " +
  fmt(h) +
  " L " +
  fmt(rx) +
  " " +
  fmt(h) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 1 " +
  fmt(rx) +
  " 0 Z M " +
  fmt(w - rx) +
  " 0 A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 0 0 " +
  fmt(w - rx) +
  " " +
  fmt(h)
}

///|
/// `flowChartDisplay` — display screen with rounded right side and pointed left.
/// @source preset-shapes.ts:3414
fn flowchart_display(w : Double, h : Double) -> String {
  let left_point = w * 0.15
  let right_curve = w * 0.25
  "M " +
  fmt(left_point) +
  " 0 L " +
  fmt(w - right_curve) +
  " 0 Q " +
  fmt(w) +
  " 0 " +
  fmt(w) +
  " " +
  fmt(h / 2.0) +
  " Q " +
  fmt(w) +
  " " +
  fmt(h) +
  " " +
  fmt(w - right_curve) +
  " " +
  fmt(h) +
  " L " +
  fmt(left_point) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h / 2.0) +
  " Z"
}

///|
/// `flowChartOffpageConnector` — pentagon/home-plate with arrow on bottom.
/// @source preset-shapes.ts:3425
fn flowchart_offpage_connector(w : Double, h : Double) -> String {
  let arrow_h = h * 0.3
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h - arrow_h) +
  " L " +
  fmt(w / 2.0) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h - arrow_h) +
  " Z"
}
