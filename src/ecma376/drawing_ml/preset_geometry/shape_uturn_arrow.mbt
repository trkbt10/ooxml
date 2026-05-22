// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `uturnArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `uturnArrow` — a U-shaped arrow: a shaft rises on the
/// left, bends across a horizontal top bar, and comes back down the
/// right side ending in an arrowhead that points up.
///
/// Adjustment guides (defaults): `adj1` = shaft thickness (25000),
/// `adj2` = arrowhead barb spread (25000), `adj3` = arrowhead height
/// (25000), `adj4` = bend radius (43750), `adj5` = U-turn height
/// (75000). The spec rounds the bend with arcs; this generator emits
/// the square-cornered equivalent so the outline stays monotone.
pub fn build_uturn_arrow(width : Int, height : Int) -> ShapeGeometry {
  let smaller = min_dim(width, height)
  let shaft_t = percent(smaller, 25000)
  let head_h = percent(smaller, 25000)
  // Left (entry) leg occupies the left band; right (exit) leg with the
  // arrowhead occupies the right band.
  let left_inner = shaft_t
  let right_leg_w = shaft_t
  // The arrowhead head width is wider than the shaft; centre the head
  // band on the right leg.
  let head_w = shaft_t + percent(smaller, 25000)
  let right_outer = width
  let right_inner = right_outer - right_leg_w
  let head_left = right_inner - (head_w - right_leg_w) / 2
  let head_right = head_left + head_w
  let head_tip_x = (right_inner + right_outer) / 2
  // Horizontal top bar joins the two legs.
  let bar_bottom = shaft_t * 2
  let commands : Array[PathCommand] = [
    // up the outer side of the left leg
    MoveTo(0, height),
    LineTo(0, shaft_t),
    // across the top bar (outer edge)
    LineTo(right_outer, shaft_t),
    // down the right leg outer edge to the arrowhead barb
    LineTo(right_outer, head_h),
    LineTo(head_right, head_h),
    // arrowhead tip pointing up
    LineTo(head_tip_x, 0),
    LineTo(head_left, head_h),
    // back up the right leg inner edge
    LineTo(right_inner, head_h),
    // along the underside of the top bar
    LineTo(right_inner, bar_bottom),
    LineTo(left_inner, bar_bottom),
    // down the inner side of the left leg
    LineTo(left_inner, height),
    ClosePath,
  ]
  { commands, width, height }
}
