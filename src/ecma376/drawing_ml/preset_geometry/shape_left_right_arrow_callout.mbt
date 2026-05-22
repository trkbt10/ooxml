// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftRightArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `leftRightArrowCallout` — a rectangular callout box with
/// arrows extending from the middle of both the left and right edges.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb height (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box width fraction (48123).
pub fn build_left_right_arrow_callout(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let shaft_h = percent(height, 25000)
  let head_h = percent(height, 25000)
  let head_w = percent(width, 25000)
  let box_w = percent(width, 48123)
  let box_left = (width - box_w) / 2
  let box_right = (width + box_w) / 2
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let head_top = (height - (shaft_h + head_h * 2)) / 2
  let head_bottom = height - head_top
  let left_base_x = head_w
  let right_base_x = width - head_w
  let commands : Array[PathCommand] = [
    // top edge of the box
    MoveTo(box_left, 0),
    LineTo(box_right, 0),
    // right side down to the right arrow shaft
    LineTo(box_right, shaft_top),
    LineTo(right_base_x, shaft_top),
    LineTo(right_base_x, head_top),
    LineTo(width, height / 2),
    LineTo(right_base_x, head_bottom),
    LineTo(right_base_x, shaft_bottom),
    LineTo(box_right, shaft_bottom),
    // bottom edge of the box
    LineTo(box_right, height),
    LineTo(box_left, height),
    // left side up to the left arrow shaft
    LineTo(box_left, shaft_bottom),
    LineTo(left_base_x, shaft_bottom),
    LineTo(left_base_x, head_bottom),
    LineTo(0, height / 2),
    LineTo(left_base_x, head_top),
    LineTo(left_base_x, shaft_top),
    LineTo(box_left, shaft_top),
    ClosePath,
  ]
  { commands, width, height }
}
