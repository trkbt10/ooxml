// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `upArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `upArrowCallout` — a rectangular callout box with an
/// up-pointing arrow extending from the middle of its top edge.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb width (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box height fraction (64977).
/// `adj1`/`adj2` are taken against the bounding width.
pub fn build_up_arrow_callout(width : Int, height : Int) -> ShapeGeometry {
  let shaft_w = percent(width, 25000)
  let head_w = percent(width, 25000)
  let head_h = percent(height, 25000)
  let box_h = percent(height, 64977)
  let box_top = height - box_h
  let shaft_left = (width - shaft_w) / 2
  let shaft_right = (width + shaft_w) / 2
  let head_left = (width - (shaft_w + head_w * 2)) / 2
  let head_right = width - head_left
  let head_base_y = head_h
  let commands : Array[PathCommand] = [
    // box outline, plus arrow on the top edge
    MoveTo(0, height),
    LineTo(0, box_top),
    LineTo(shaft_left, box_top),
    LineTo(shaft_left, head_base_y),
    LineTo(head_left, head_base_y),
    LineTo(width / 2, 0),
    LineTo(head_right, head_base_y),
    LineTo(shaft_right, head_base_y),
    LineTo(shaft_right, box_top),
    LineTo(width, box_top),
    LineTo(width, height),
    ClosePath,
  ]
  { commands, width, height }
}
