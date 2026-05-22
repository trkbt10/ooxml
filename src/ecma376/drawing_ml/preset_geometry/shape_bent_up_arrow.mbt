// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `bentUpArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `bentUpArrow` — an arrow with a right-angle bend: a
/// horizontal shaft running from the bottom-left turns 90° upward at
/// the right and ends in an arrowhead pointing up.
///
/// Adjustment guides (defaults): `adj1` = arrowhead width fraction
/// (25000), `adj2` = arrowhead height fraction (25000), `adj3` = shaft
/// thickness fraction (25000). All are taken against the smaller
/// bounding dimension so the elbow stays square.
pub fn build_bent_up_arrow(width : Int, height : Int) -> ShapeGeometry {
  let smaller = min_dim(width, height)
  let head_w = percent(smaller, 25000)
  let head_h = percent(smaller, 25000)
  let shaft_t = percent(smaller, 25000)
  // Vertical arm runs up the right side; arrowhead barbs spread
  // symmetrically about the vertical shaft band.
  let barb = (head_w - shaft_t) / 2
  let arm_left = width - barb - shaft_t
  let arm_right = width - barb
  let head_left = width - head_w
  let head_right = width
  // Horizontal shaft sits along the bottom edge.
  let shaft_top = height - shaft_t
  let shaft_bottom = height
  let commands : Array[PathCommand] = [
    MoveTo(0, shaft_top),
    LineTo(arm_left, shaft_top),
    LineTo(arm_left, head_h),
    LineTo(head_left, head_h),
    LineTo((head_left + head_right) / 2, 0),
    LineTo(head_right, head_h),
    LineTo(arm_right, head_h),
    LineTo(arm_right, shaft_bottom),
    LineTo(0, shaft_bottom),
    ClosePath,
  ]
  { commands, width, height }
}
