// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `leftArrowCallout` — a rectangular callout box with a
/// left-pointing arrow extending from the middle of its left edge.
/// Mirror of `rightArrowCallout` across the vertical axis.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb height (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box width fraction (64977).
pub fn build_left_arrow_callout(width : Int, height : Int) -> ShapeGeometry {
  let shaft_h = percent(height, 25000)
  let head_h = percent(height, 25000)
  let head_w = percent(width, 25000)
  let box_w = percent(width, 64977)
  let box_left = width - box_w
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let head_top = (height - (shaft_h + head_h * 2)) / 2
  let head_bottom = height - head_top
  let head_base_x = head_w
  let commands : Array[PathCommand] = [
    MoveTo(width, 0),
    LineTo(box_left, 0),
    LineTo(box_left, shaft_top),
    LineTo(head_base_x, shaft_top),
    LineTo(head_base_x, head_top),
    LineTo(0, height / 2),
    LineTo(head_base_x, head_bottom),
    LineTo(head_base_x, shaft_bottom),
    LineTo(box_left, shaft_bottom),
    LineTo(box_left, height),
    LineTo(width, height),
    ClosePath,
  ]
  { commands, width, height }
}
