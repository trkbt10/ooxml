// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `rightArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `rightArrowCallout` — a rectangular callout box with a
/// right-pointing arrow extending from the middle of its right edge.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb height (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box width as a fraction of the
/// bounding width (64977). `adj1`/`adj2` are taken against the
/// bounding height.
pub fn build_right_arrow_callout(width : Int, height : Int) -> ShapeGeometry {
  let shaft_h = percent(height, 25000)
  let head_h = percent(height, 25000)
  let head_w = percent(width, 25000)
  let box_w = percent(width, 64977)
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let head_top = (height - (shaft_h + head_h * 2)) / 2
  let head_bottom = height - head_top
  let head_base_x = width - head_w
  let commands : Array[PathCommand] = [
    // box outline, clockwise from top-left
    MoveTo(0, 0),
    LineTo(box_w, 0),
    // down the right side of the box to the arrow shaft
    LineTo(box_w, shaft_top),
    LineTo(head_base_x, shaft_top),
    LineTo(head_base_x, head_top),
    // arrowhead tip
    LineTo(width, height / 2),
    LineTo(head_base_x, head_bottom),
    LineTo(head_base_x, shaft_bottom),
    LineTo(box_w, shaft_bottom),
    // down the rest of the box right side
    LineTo(box_w, height),
    LineTo(0, height),
    ClosePath,
  ]
  { commands, width, height }
}
