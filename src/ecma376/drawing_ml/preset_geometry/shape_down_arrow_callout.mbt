// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `downArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `downArrowCallout` — a rectangular callout box with a
/// down-pointing arrow extending from the middle of its bottom edge.
/// Mirror of `upArrowCallout` across the horizontal axis.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb width (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box height fraction (64977).
pub fn build_down_arrow_callout(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let shaft_w = percent(width, 25000)
  let head_w = percent(width, 25000)
  let head_h = percent(height, 25000)
  let box_h = percent(height, 64977)
  let shaft_left = (width - shaft_w) / 2
  let shaft_right = (width + shaft_w) / 2
  let head_left = (width - (shaft_w + head_w * 2)) / 2
  let head_right = width - head_left
  let head_base_y = height - head_h
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, box_h),
    LineTo(shaft_right, box_h),
    LineTo(shaft_right, head_base_y),
    LineTo(head_right, head_base_y),
    LineTo(width / 2, height),
    LineTo(head_left, head_base_y),
    LineTo(shaft_left, head_base_y),
    LineTo(shaft_left, box_h),
    LineTo(0, box_h),
    ClosePath,
  ]
  { commands, width, height }
}
