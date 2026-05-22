// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `quadArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `quadArrowCallout` — a rectangular callout box with
/// arrows extending from the middle of all four edges.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (18515), `adj2` = arrowhead barb spread (18515), `adj3` = arrowhead
/// length (18515), `adj4` = callout box side fraction (48123). Shaft
/// and head dimensions are taken against the smaller bounding
/// dimension so the four arms stay consistent.
pub fn build_quad_arrow_callout(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let smaller = min_dim(width, height)
  let shaft_t = percent(smaller, 18515)
  let head_barb = percent(smaller, 18515)
  let head_len = percent(smaller, 18515)
  let cx = width / 2
  let cy = height / 2
  // Centred box.
  let box_w = percent(width, 48123)
  let box_h = percent(height, 48123)
  let box_left = (width - box_w) / 2
  let box_right = (width + box_w) / 2
  let box_top = (height - box_h) / 2
  let box_bottom = (height + box_h) / 2
  // Shaft band edges.
  let h_top = cy - shaft_t / 2
  let h_bottom = cy + shaft_t / 2
  let v_left = cx - shaft_t / 2
  let v_right = cx + shaft_t / 2
  // Arrowhead barb edges.
  let head_top = cy - (shaft_t / 2 + head_barb)
  let head_bottom = cy + (shaft_t / 2 + head_barb)
  let head_left = cx - (shaft_t / 2 + head_barb)
  let head_right = cx + (shaft_t / 2 + head_barb)
  // Arrowhead bases.
  let left_base = head_len
  let right_base = width - head_len
  let top_base = head_len
  let bottom_base = height - head_len
  let commands : Array[PathCommand] = [
    // left arrowhead
    MoveTo(0, cy),
    LineTo(left_base, head_top),
    LineTo(left_base, h_top),
    // up the box left side to the up arrow
    LineTo(box_left, h_top),
    LineTo(box_left, box_top),
    LineTo(v_left, box_top),
    LineTo(v_left, top_base),
    LineTo(head_left, top_base),
    LineTo(cx, 0),
    LineTo(head_right, top_base),
    LineTo(v_right, top_base),
    LineTo(v_right, box_top),
    // along box top to the right arrow
    LineTo(box_right, box_top),
    LineTo(box_right, h_top),
    LineTo(right_base, h_top),
    LineTo(right_base, head_top),
    LineTo(width, cy),
    LineTo(right_base, head_bottom),
    LineTo(right_base, h_bottom),
    LineTo(box_right, h_bottom),
    LineTo(box_right, box_bottom),
    // along box right to the down arrow
    LineTo(v_right, box_bottom),
    LineTo(v_right, bottom_base),
    LineTo(head_right, bottom_base),
    LineTo(cx, height),
    LineTo(head_left, bottom_base),
    LineTo(v_left, bottom_base),
    LineTo(v_left, box_bottom),
    // along box bottom back to the left arrow
    LineTo(box_left, box_bottom),
    LineTo(box_left, h_bottom),
    LineTo(left_base, h_bottom),
    LineTo(left_base, head_bottom),
    ClosePath,
  ]
  { commands, width, height }
}
