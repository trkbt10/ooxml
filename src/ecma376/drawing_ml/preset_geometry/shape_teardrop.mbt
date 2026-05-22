// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `teardrop`.

///|
/// §20.1.10.56 `teardrop` — a circle with its top-right corner pulled
/// out to a point, giving a teardrop / water-drop silhouette.
///
/// Spec path: `moveTo(l,vc)` → `arcTo(wd2,hd2,cd2,cd4)` (left-mid up to
/// top-mid) → `quadBezTo(x2,t, x1,y1)` (curve out to the pulled point)
/// → `quadBezTo(r,y2, r,vc)` (curve down to right-mid) →
/// `arcTo(wd2,hd2,0,cd4)` (right-mid to bottom-mid) →
/// `arcTo(wd2,hd2,cd4,cd4)` (bottom-mid back to left-mid) → `close`.
///
/// With the default `adj = 100000` the pulled point `(x1,y1)` lands on
/// the top-right corner `(r,t)`, and the quad control points are
/// `x2 = (hc + r)/2` and `y2 = (vc + t)/2`.
pub fn build_teardrop(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  // adj = 100000 → the pulled point is the top-right corner.
  let x1 = width
  let y1 = 0
  let x2 = (cx + width) / 2
  let y2 = (cy + 0) / 2
  let commands : Array[PathCommand] = []
  // Left-mid start.
  commands.push(MoveTo(0, cy))
  // Quarter arc up the left side to the top-mid point.
  commands.push(ArcTo(rx, ry, 0, false, true, cx, 0))
  // Quad out to the pulled corner point.
  commands.push(QuadTo(x2, 0, x1, y1))
  // Quad down to the right-mid point.
  commands.push(QuadTo(width, y2, width, cy))
  // Quarter arc down the right side to the bottom-mid point.
  commands.push(ArcTo(rx, ry, 0, false, true, cx, height))
  // Quarter arc back along the bottom to the left-mid start.
  commands.push(ArcTo(rx, ry, 0, false, true, 0, cy))
  commands.push(ClosePath)
  { commands, width, height }
}
