// @source web-pptx packages/@aurochs-renderer/drawing-ml/src/svg/geometry/preset-shapes.ts
//
// Preset actionButton* shapes.  Each function below is a direct port of
// the corresponding TS render lambda living in `preset-shapes.ts`; line
// numbers in the per-function `@source` comments reference that file.
//
// Action buttons share a common outer frame: a full bounding rectangle
// plus an inset bevel border whose thickness is `min(w, h) * 0.1`.  The
// glyph (house, arrow, ?, etc.) is then drawn centred inside the bevel.
// Because the TS code computes every coordinate as plain arithmetic on
// `w` and `h` (no guide formulas are evaluated by the lambdas
// themselves), `GuideContext` is only threaded through here for
// signature uniformity with the other `dispatch_*` helpers.
//
// Owned presets (12):
//   actionButtonBlank, actionButtonHome, actionButtonHelp,
//   actionButtonInformation, actionButtonForwardNext,
//   actionButtonBackPrevious, actionButtonEnd, actionButtonBeginning,
//   actionButtonReturn, actionButtonDocument, actionButtonSound,
//   actionButtonMovie.
//
// ECMA-376 references:
//   §20.1.10.55  ST_ShapeType (enumeration values listed above)
//   §20.1.10.56  built-in shape guides shared by every preset

///|
/// `min(w, h)` helper.
fn ab_min(w : Double, h : Double) -> Double {
  if w < h {
    w
  } else {
    h
  }
}

///|
/// Render the outer bounding rectangle.  Shared first segment of every
/// action-button path.
fn ab_outer_rect(w : Double, h : Double) -> String {
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z "
}

///|
/// Render the inset bevel rectangle.  Shared second segment of every
/// action-button path.  `border = min(w, h) * 0.1`.
fn ab_bevel_rect(w : Double, h : Double, border : Double) -> String {
  "M " +
  fmt(border) +
  " " +
  fmt(border) +
  " L " +
  fmt(w - border) +
  " " +
  fmt(border) +
  " L " +
  fmt(w - border) +
  " " +
  fmt(h - border) +
  " L " +
  fmt(border) +
  " " +
  fmt(h - border) +
  " Z "
}

///|
/// `actionButtonBlank` — outer rectangle + inset bevel only.
/// @source preset-shapes.ts:3982
fn action_button_blank(w : Double, h : Double, _ctx : GuideContext) -> String {
  let border = ab_min(w, h) * 0.1
  // The TS version omits the trailing space on this preset because the
  // bevel is the final segment.
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z M " +
  fmt(border) +
  " " +
  fmt(border) +
  " L " +
  fmt(w - border) +
  " " +
  fmt(border) +
  " L " +
  fmt(w - border) +
  " " +
  fmt(h - border) +
  " L " +
  fmt(border) +
  " " +
  fmt(h - border) +
  " Z"
}

///|
/// `actionButtonHome` — house glyph (triangular roof + rectangular
/// body) on the bevel-framed background.
/// @source preset-shapes.ts:4809
fn action_button_home(w : Double, h : Double, _ctx : GuideContext) -> String {
  let border = ab_min(w, h) * 0.1
  let icon_margin = ab_min(w, h) * 0.25
  let cx = w / 2.0
  // House icon — roof
  let roof_top = icon_margin
  let roof_bottom = h * 0.45
  let house_left = icon_margin
  let house_right = w - icon_margin
  let house_bottom = h - icon_margin
  // House body — 15 % inset from the roof footprint.
  let body_left = house_left + (house_right - house_left) * 0.15
  let body_right = house_right - (house_right - house_left) * 0.15
  ab_outer_rect(w, h) +
  ab_bevel_rect(w, h, border) +
  // Roof triangle
  "M " +
  fmt(cx) +
  " " +
  fmt(roof_top) +
  " L " +
  fmt(house_right) +
  " " +
  fmt(roof_bottom) +
  " L " +
  fmt(house_left) +
  " " +
  fmt(roof_bottom) +
  " Z " +
  // House body rectangle
  "M " +
  fmt(body_left) +
  " " +
  fmt(roof_bottom) +
  " L " +
  fmt(body_right) +
  " " +
  fmt(roof_bottom) +
  " L " +
  fmt(body_right) +
  " " +
  fmt(house_bottom) +
  " L " +
  fmt(body_left) +
  " " +
  fmt(house_bottom) +
  " Z"
}

///|
/// Shared helper for the two question-mark / info presets: draws an
/// inset circle centred at (cx, cy) with radius r as two arc-to halves.
fn ab_circle_path(cx : Double, cy : Double, r : Double) -> String {
  // Two semicircles starting/ending at the rightmost point — matches
  // the TS template literal exactly.
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
  " Z"
}

///|
/// `actionButtonHelp` — question-mark stand-in: bevel + centred circle.
/// The TS source renders the same primitive shape as Information; it
/// relies on the caller to overlay a glyph if one is desired.
/// @source preset-shapes.ts:4836
fn action_button_help(w : Double, h : Double, _ctx : GuideContext) -> String {
  let border = ab_min(w, h) * 0.1
  let cx = w / 2.0
  let cy = h / 2.0
  let r = ab_min(w, h) * 0.25
  ab_outer_rect(w, h) + ab_bevel_rect(w, h, border) + ab_circle_path(cx, cy, r)
}

///|
/// `actionButtonInformation` — bevel + centred circle (identical
/// primitive geometry to Help in the TS source).
/// @source preset-shapes.ts:4854
fn action_button_information(
  w : Double,
  h : Double,
  _ctx : GuideContext,
) -> String {
  let border = ab_min(w, h) * 0.1
  let cx = w / 2.0
  let cy = h / 2.0
  let r = ab_min(w, h) * 0.25
  ab_outer_rect(w, h) + ab_bevel_rect(w, h, border) + ab_circle_path(cx, cy, r)
}

///|
/// `actionButtonForwardNext` — right-pointing triangle inside the bevel.
/// @source preset-shapes.ts:4872
fn action_button_forward_next(
  w : Double,
  h : Double,
  _ctx : GuideContext,
) -> String {
  let border = ab_min(w, h) * 0.1
  let icon_margin = ab_min(w, h) * 0.25
  let cy = h / 2.0
  ab_outer_rect(w, h) +
  ab_bevel_rect(w, h, border) +
  "M " +
  fmt(icon_margin) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(cy) +
  " L " +
  fmt(icon_margin) +
  " " +
  fmt(h - icon_margin) +
  " Z"
}

///|
/// `actionButtonBackPrevious` — left-pointing triangle inside the
/// bevel.  Mirror image of forwardNext.
/// @source preset-shapes.ts:4889
fn action_button_back_previous(
  w : Double,
  h : Double,
  _ctx : GuideContext,
) -> String {
  let border = ab_min(w, h) * 0.1
  let icon_margin = ab_min(w, h) * 0.25
  let cy = h / 2.0
  ab_outer_rect(w, h) +
  ab_bevel_rect(w, h, border) +
  "M " +
  fmt(w - icon_margin) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(icon_margin) +
  " " +
  fmt(cy) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(h - icon_margin) +
  " Z"
}

///|
/// `actionButtonEnd` — forward triangle plus a thin vertical end-bar
/// (15 % of the icon's horizontal extent).
/// @source preset-shapes.ts:4906
fn action_button_end(w : Double, h : Double, _ctx : GuideContext) -> String {
  let border = ab_min(w, h) * 0.1
  let icon_margin = ab_min(w, h) * 0.25
  let cy = h / 2.0
  let bar_width = (w - 2.0 * icon_margin) * 0.15
  ab_outer_rect(w, h) +
  ab_bevel_rect(w, h, border) +
  // Forward triangle (tip stops short of the end bar)
  "M " +
  fmt(icon_margin) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(w - icon_margin - bar_width) +
  " " +
  fmt(cy) +
  " L " +
  fmt(icon_margin) +
  " " +
  fmt(h - icon_margin) +
  " Z " +
  // End bar (rectangle hugging the right inset edge)
  "M " +
  fmt(w - icon_margin - bar_width) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(h - icon_margin) +
  " L " +
  fmt(w - icon_margin - bar_width) +
  " " +
  fmt(h - icon_margin) +
  " Z"
}

///|
/// `actionButtonBeginning` — left bar plus a backward triangle.  Mirror
/// of `actionButtonEnd`.
/// @source preset-shapes.ts:4925
fn action_button_beginning(
  w : Double,
  h : Double,
  _ctx : GuideContext,
) -> String {
  let border = ab_min(w, h) * 0.1
  let icon_margin = ab_min(w, h) * 0.25
  let cy = h / 2.0
  let bar_width = (w - 2.0 * icon_margin) * 0.15
  ab_outer_rect(w, h) +
  ab_bevel_rect(w, h, border) +
  // Left bar
  "M " +
  fmt(icon_margin) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(icon_margin + bar_width) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(icon_margin + bar_width) +
  " " +
  fmt(h - icon_margin) +
  " L " +
  fmt(icon_margin) +
  " " +
  fmt(h - icon_margin) +
  " Z " +
  // Backward triangle (tip touching the right edge of the bar)
  "M " +
  fmt(w - icon_margin) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(icon_margin + bar_width) +
  " " +
  fmt(cy) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(h - icon_margin) +
  " Z"
}

///|
/// `actionButtonReturn` — hooked "return" arrow.
/// @source preset-shapes.ts:4944
fn action_button_return(w : Double, h : Double, _ctx : GuideContext) -> String {
  let border = ab_min(w, h) * 0.1
  let icon_margin = ab_min(w, h) * 0.25
  let arrow_height = (h - 2.0 * icon_margin) * 0.4
  let cy = h / 2.0
  ab_outer_rect(w, h) +
  ab_bevel_rect(w, h, border) +
  // Arrow head tip at (iconMargin, cy)
  "M " +
  fmt(icon_margin) +
  " " +
  fmt(cy) +
  " L " +
  fmt(icon_margin + arrow_height) +
  " " +
  fmt(cy - arrow_height) +
  " L " +
  fmt(icon_margin + arrow_height) +
  " " +
  fmt(cy - arrow_height / 2.0) +
  " " +
  // Top of the shaft and right hook
  "L " +
  fmt(w - icon_margin) +
  " " +
  fmt(cy - arrow_height / 2.0) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(cy + arrow_height / 2.0) +
  " L " +
  fmt(icon_margin + arrow_height) +
  " " +
  fmt(cy + arrow_height / 2.0) +
  " " +
  // Bottom edge of the arrow head
  "L " +
  fmt(icon_margin + arrow_height) +
  " " +
  fmt(cy + arrow_height) +
  " Z"
}

///|
/// `actionButtonDocument` — page with a turned corner.
/// @source preset-shapes.ts:4964
fn action_button_document(
  w : Double,
  h : Double,
  _ctx : GuideContext,
) -> String {
  let border = ab_min(w, h) * 0.1
  let icon_margin = ab_min(w, h) * 0.25
  let fold_size = (w - 2.0 * icon_margin) * 0.25
  ab_outer_rect(w, h) +
  ab_bevel_rect(w, h, border) +
  // Page outline (with the top-right corner snipped diagonally)
  "M " +
  fmt(icon_margin) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(w - icon_margin - fold_size) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(icon_margin + fold_size) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(h - icon_margin) +
  " L " +
  fmt(icon_margin) +
  " " +
  fmt(h - icon_margin) +
  " Z " +
  // Folded-corner triangle (open path — no Z)
  "M " +
  fmt(w - icon_margin - fold_size) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(w - icon_margin - fold_size) +
  " " +
  fmt(icon_margin + fold_size) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(icon_margin + fold_size)
}

///|
/// `actionButtonSound` — speaker cone glyph (no sound waves rendered).
/// @source preset-shapes.ts:4982
fn action_button_sound(w : Double, h : Double, _ctx : GuideContext) -> String {
  let border = ab_min(w, h) * 0.1
  let icon_margin = ab_min(w, h) * 0.25
  let cy = h / 2.0
  let speaker_width = (w - 2.0 * icon_margin) * 0.4
  let speaker_height = (h - 2.0 * icon_margin) * 0.6
  let speaker_base_width = speaker_width * 0.4
  ab_outer_rect(w, h) +
  ab_bevel_rect(w, h, border) +
  "M " +
  fmt(icon_margin) +
  " " +
  fmt(cy - speaker_height * 0.25) +
  " " +
  "L " +
  fmt(icon_margin + speaker_base_width) +
  " " +
  fmt(cy - speaker_height * 0.25) +
  " " +
  "L " +
  fmt(icon_margin + speaker_width) +
  " " +
  fmt(cy - speaker_height * 0.5) +
  " " +
  "L " +
  fmt(icon_margin + speaker_width) +
  " " +
  fmt(cy + speaker_height * 0.5) +
  " " +
  "L " +
  fmt(icon_margin + speaker_base_width) +
  " " +
  fmt(cy + speaker_height * 0.25) +
  " " +
  "L " +
  fmt(icon_margin) +
  " " +
  fmt(cy + speaker_height * 0.25) +
  " Z"
}

///|
/// Render one sprocket hole as a square `2*holeSize` on a side centred
/// at `(cx, cy)`.  Used by `actionButtonMovie`.
fn ab_movie_hole(cx : Double, cy : Double, hole_size : Double) -> String {
  "M " +
  fmt(cx - hole_size) +
  " " +
  fmt(cy - hole_size) +
  " L " +
  fmt(cx + hole_size) +
  " " +
  fmt(cy - hole_size) +
  " L " +
  fmt(cx + hole_size) +
  " " +
  fmt(cy + hole_size) +
  " L " +
  fmt(cx - hole_size) +
  " " +
  fmt(cy + hole_size) +
  " Z"
}

///|
/// `actionButtonMovie` — filmstrip rectangle with two columns of three
/// sprocket holes.
/// @source preset-shapes.ts:5008
fn action_button_movie(w : Double, h : Double, _ctx : GuideContext) -> String {
  let border = ab_min(w, h) * 0.1
  let icon_margin = ab_min(w, h) * 0.25
  let film_width = w - 2.0 * icon_margin
  let film_height = h - 2.0 * icon_margin
  let hole_size = film_width * 0.08
  let hole_spacing = film_width * 0.15
  // Y coordinates of the three sprocket rows.
  let hole_y1 = icon_margin + film_height * 0.2
  let hole_y2 = icon_margin + film_height * 0.5
  let hole_y3 = icon_margin + film_height * 0.8
  // X centres of the left and right sprocket columns.
  let cx_left = icon_margin + hole_spacing
  let cx_right = w - icon_margin - hole_spacing
  ab_outer_rect(w, h) +
  ab_bevel_rect(w, h, border) +
  // Filmstrip rectangle
  "M " +
  fmt(icon_margin) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(icon_margin) +
  " L " +
  fmt(w - icon_margin) +
  " " +
  fmt(h - icon_margin) +
  " L " +
  fmt(icon_margin) +
  " " +
  fmt(h - icon_margin) +
  " Z " +
  // Left column sprockets
  ab_movie_hole(cx_left, hole_y1, hole_size) +
  " " +
  ab_movie_hole(cx_left, hole_y2, hole_size) +
  " " +
  ab_movie_hole(cx_left, hole_y3, hole_size) +
  " " +
  // Right column sprockets
  ab_movie_hole(cx_right, hole_y1, hole_size) +
  " " +
  ab_movie_hole(cx_right, hole_y2, hole_size) +
  " " +
  ab_movie_hole(cx_right, hole_y3, hole_size)
}

///|
/// Per-preset dispatcher.  Returns `Some(d)` for every preset whose
/// name begins with `actionButton`; otherwise `None` so that the parent
/// dispatcher can try the next category.
fn dispatch_action_button(
  preset : String,
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String? {
  match preset {
    "actionButtonBlank" => Some(action_button_blank(w, h, ctx))
    "actionButtonHome" => Some(action_button_home(w, h, ctx))
    "actionButtonHelp" => Some(action_button_help(w, h, ctx))
    "actionButtonInformation" => Some(action_button_information(w, h, ctx))
    "actionButtonForwardNext" => Some(action_button_forward_next(w, h, ctx))
    "actionButtonBackPrevious" => Some(action_button_back_previous(w, h, ctx))
    "actionButtonEnd" => Some(action_button_end(w, h, ctx))
    "actionButtonBeginning" => Some(action_button_beginning(w, h, ctx))
    "actionButtonReturn" => Some(action_button_return(w, h, ctx))
    "actionButtonDocument" => Some(action_button_document(w, h, ctx))
    "actionButtonSound" => Some(action_button_sound(w, h, ctx))
    "actionButtonMovie" => Some(action_button_movie(w, h, ctx))
    _ => None
  }
}
