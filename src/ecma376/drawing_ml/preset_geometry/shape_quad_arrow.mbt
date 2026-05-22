// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `quadArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `quadArrow` — a four-headed arrow with heads pointing
/// up, down, left and right from a common central junction.
///
/// Adjustment guides (defaults): `adj1` = arrowhead barb spread
/// (22500), `adj2` = arrowhead length (22500), `adj3` = shaft
/// thickness (22500). All are taken against the smaller bounding
/// dimension so the four arms keep a consistent thickness.
pub fn build_quad_arrow(width : Int, height : Int) -> ShapeGeometry {
  let smaller = min_dim(width, height)
  let shaft_t = percent(smaller, 22500)
  let head_len = percent(smaller, 22500)
  let head_barb = percent(smaller, 22500)
  let cx = width / 2
  let cy = height / 2
  // Shaft band edges, centred on each axis.
  let h_top = cy - shaft_t / 2
  let h_bottom = cy + shaft_t / 2
  let v_left = cx - shaft_t / 2
  let v_right = cx + shaft_t / 2
  // Arrowhead barb edges (wider than the shaft).
  let head_top = cy - (shaft_t / 2 + head_barb)
  let head_bottom = cy + (shaft_t / 2 + head_barb)
  let head_left = cx - (shaft_t / 2 + head_barb)
  let head_right = cx + (shaft_t / 2 + head_barb)
  // Arrowhead base offsets from each edge.
  let left_base = head_len
  let right_base = width - head_len
  let top_base = head_len
  let bottom_base = height - head_len
  let commands : Array[PathCommand] = [
    // left arrowhead
    MoveTo(0, cy),
    LineTo(left_base, head_top),
    LineTo(left_base, h_top),
    // up to the up arrowhead
    LineTo(v_left, h_top),
    LineTo(v_left, top_base),
    LineTo(head_left, top_base),
    LineTo(cx, 0),
    LineTo(head_right, top_base),
    LineTo(v_right, top_base),
    // down to the right arrowhead
    LineTo(v_right, h_top),
    LineTo(right_base, h_top),
    LineTo(right_base, head_top),
    LineTo(width, cy),
    LineTo(right_base, head_bottom),
    LineTo(right_base, h_bottom),
    // back to the down arrowhead
    LineTo(v_right, h_bottom),
    LineTo(v_right, bottom_base),
    LineTo(head_right, bottom_base),
    LineTo(cx, height),
    LineTo(head_left, bottom_base),
    LineTo(v_left, bottom_base),
    // up to the left arrowhead
    LineTo(v_left, h_bottom),
    LineTo(left_base, h_bottom),
    LineTo(left_base, head_bottom),
    ClosePath,
  ]
  { commands, width, height }
}
