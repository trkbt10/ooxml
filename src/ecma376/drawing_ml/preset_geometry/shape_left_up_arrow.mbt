// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftUpArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `leftUpArrow` — a two-headed arrow with heads pointing
/// left and up, joined at a square L-junction at the bottom-right.
///
/// Adjustment guides (defaults): `adj1` = arrowhead barb spread
/// (25000), `adj2` = arrowhead length (25000), `adj3` = shaft
/// thickness (25000). Heads are scaled against the smaller bounding
/// dimension so both arms keep a consistent thickness.
pub fn build_left_up_arrow(width : Int, height : Int) -> ShapeGeometry {
  let smaller = min_dim(width, height)
  let shaft_t = percent(smaller, 25000)
  let head_len = percent(smaller, 25000)
  let head_barb = percent(smaller, 25000)
  // Vertical arm rises on the right; horizontal arm runs along the
  // bottom. They meet in a shaft_t × shaft_t corner block.
  let up_left = width - shaft_t
  let up_right = width
  let up_head_left = up_left - head_barb
  let up_head_right = up_right + head_barb
  // Clamp the up arrowhead within the right edge.
  let up_head_right_c = if up_head_right > width { width } else { up_head_right }
  let up_tip_x = (up_left + up_right) / 2
  let left_tip = 0
  let left_base = head_len
  let shaft_top = height - shaft_t
  let shaft_bottom = height
  let left_head_top = shaft_top - head_barb
  let left_mid_y = (left_head_top + shaft_bottom) / 2
  let commands : Array[PathCommand] = [
    // left arrowhead tip
    MoveTo(left_tip, left_mid_y),
    LineTo(left_base, left_head_top),
    LineTo(left_base, shaft_top),
    // up the inner edge of the vertical arm
    LineTo(up_left, shaft_top),
    LineTo(up_left, head_len),
    LineTo(up_head_left, head_len),
    // up arrowhead tip
    LineTo(up_tip_x, 0),
    LineTo(up_head_right_c, head_len),
    LineTo(up_right, head_len),
    // down the outer edge of the vertical arm
    LineTo(up_right, shaft_bottom),
    // back along the bottom edge to the left head barb
    LineTo(left_base, shaft_bottom),
    ClosePath,
  ]
  { commands, width, height }
}
