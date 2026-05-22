// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftRightUpArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `leftRightUpArrow` — a three-headed arrow with heads
/// pointing left, right and up, all joined at a common shaft junction.
///
/// Adjustment guides (defaults): `adj1` = arrowhead barb spread
/// (25000), `adj2` = arrowhead length (25000), `adj3` = shaft
/// thickness (25000). Heads are scaled against the smaller bounding
/// dimension so the three arms keep a consistent thickness.
pub fn build_left_right_up_arrow(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let smaller = min_dim(width, height)
  let shaft_t = percent(smaller, 25000)
  let head_len = percent(smaller, 25000)
  let head_barb = percent(smaller, 25000)
  // Horizontal shaft band runs along the bottom region; the up arm
  // rises from its centre.
  let mid_x = width / 2
  let shaft_bottom = height
  let shaft_top = height - shaft_t
  // Up-arrow shaft band, centred horizontally.
  let up_left = mid_x - shaft_t / 2
  let up_right = mid_x + shaft_t / 2
  // Up arrowhead.
  let up_head_left = mid_x - (shaft_t / 2 + head_barb)
  let up_head_right = mid_x + (shaft_t / 2 + head_barb)
  // Horizontal arrowheads.
  let left_tip = 0
  let right_tip = width
  let left_base = head_len
  let right_base = width - head_len
  let h_head_top = shaft_top - head_barb
  let h_head_bottom = shaft_bottom
  let h_mid_y = (h_head_top + shaft_bottom) / 2
  let commands : Array[PathCommand] = [
    // left arrowhead tip
    MoveTo(left_tip, h_mid_y),
    LineTo(left_base, h_head_top),
    LineTo(left_base, shaft_top),
    // up the left side of the up shaft
    LineTo(up_left, shaft_top),
    LineTo(up_left, head_len),
    LineTo(up_head_left, head_len),
    // up arrowhead tip
    LineTo(mid_x, 0),
    LineTo(up_head_right, head_len),
    LineTo(up_right, head_len),
    // down the right side of the up shaft
    LineTo(up_right, shaft_top),
    LineTo(right_base, shaft_top),
    LineTo(right_base, h_head_top),
    // right arrowhead tip
    LineTo(right_tip, h_mid_y),
    LineTo(right_base, h_head_bottom),
    LineTo(left_base, h_head_bottom),
    ClosePath,
  ]
  { commands, width, height }
}
