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
pub fn build_teardrop(
  width : Int,
  height : Int,
  adj? : Int = 100000,
) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  // §20.1.10.56 teardrop: a = pin 0 adj 200000. The pulled point is
  // (hc + dx1, vc − dy1) where dx1 = cos(45°)·(wd2·√2·a/100000) and
  // dy1 = sin(45°)·(hd2·√2·a/100000); since cos45 = sin45 = √2/2 the
  // √2 factors cancel, giving dx1 = w·a/200000, dy1 = h·a/200000 (no
  // trig needed). Default a = 100000 ⇒ the corner (r, t).
  let a = pin_int(adj, 0, 200000)
  let x1 = cx + fraction(width, a, 200000)
  let y1 = cy - fraction(height, a, 200000)
  let x2 = (cx + x1) / 2
  let y2 = (cy + y1) / 2
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
