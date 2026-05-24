// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `upDownArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `upDownArrowCallout` — a rectangular callout box with
/// arrows extending from the middle of both the top and bottom edges.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb width (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box height fraction (48123).
pub fn build_up_down_arrow_callout(width : Int, height : Int) -> ShapeGeometry {
  let shaft_w = percent(width, 25000)
  let head_w = percent(width, 25000)
  let head_h = percent(height, 25000)
  let box_h = percent(height, 48123)
  let box_top = (height - box_h) / 2
  let box_bottom = (height + box_h) / 2
  let shaft_left = (width - shaft_w) / 2
  let shaft_right = (width + shaft_w) / 2
  let head_left = (width - (shaft_w + head_w * 2)) / 2
  let head_right = width - head_left
  let top_base_y = head_h
  let bottom_base_y = height - head_h
  let commands : Array[PathCommand] = [
    // up arrowhead tip
    MoveTo(width / 2, 0),
    LineTo(head_right, top_base_y),
    LineTo(shaft_right, top_base_y),
    // down to the box top edge
    LineTo(shaft_right, box_top),
    LineTo(width, box_top),
    // right side of the box
    LineTo(width, box_bottom),
    LineTo(shaft_right, box_bottom),
    // down to the down arrowhead
    LineTo(shaft_right, bottom_base_y),
    LineTo(head_right, bottom_base_y),
    LineTo(width / 2, height),
    LineTo(head_left, bottom_base_y),
    LineTo(shaft_left, bottom_base_y),
    // up to the box bottom edge
    LineTo(shaft_left, box_bottom),
    LineTo(0, box_bottom),
    // left side of the box
    LineTo(0, box_top),
    LineTo(shaft_left, box_top),
    // up to the up arrowhead
    LineTo(shaft_left, top_base_y),
    LineTo(head_left, top_base_y),
    ClosePath,
  ]
  { commands, width, height }
}
