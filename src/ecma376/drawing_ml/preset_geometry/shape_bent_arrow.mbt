// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `bentArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `bentArrow` — an arrow with a right-angle bend: a
/// vertical shaft rising from the bottom-left turns 90° and runs
/// rightward into an arrowhead at the right edge.
///
/// Adjustment guides (defaults): `adj1` = arrowhead height fraction
/// (25000), `adj2` = shaft thickness fraction (25000), `adj3` =
/// arrowhead width fraction (25000), `adj4` = bend radius fraction
/// (43750). The spec rounds the inner/outer corners with arcs; this
/// generator emits the equivalent square-cornered elbow polygon so the
/// renderer receives a faithful, monotone outline.
pub fn build_bent_arrow(width : Int, height : Int) -> ShapeGeometry {
  let smaller = min_dim(width, height)
  let head_h = percent(smaller, 25000)
  let shaft_t = percent(smaller, 25000)
  let head_w = percent(smaller, 25000)
  // Horizontal arm runs along the top; the arrowhead is centred on
  // the shaft so its barbs spread (head_h - shaft_t)/2 above and
  // below the shaft band.
  let barb = (head_h - shaft_t) / 2
  let head_base_x = width - head_w
  let arm_top = barb
  let arm_bottom = barb + shaft_t
  let head_top = 0
  let head_bottom = head_h
  let shaft_left = 0
  let shaft_right = shaft_t
  let commands : Array[PathCommand] = [
    MoveTo(shaft_left, height),
    LineTo(shaft_left, arm_bottom),
    LineTo(head_base_x, arm_bottom),
    LineTo(head_base_x, head_bottom),
    LineTo(width, head_h / 2),
    LineTo(head_base_x, head_top),
    LineTo(head_base_x, arm_top),
    LineTo(shaft_right, arm_top),
    LineTo(shaft_right, height),
    ClosePath,
  ]
  { commands, width, height }
}
