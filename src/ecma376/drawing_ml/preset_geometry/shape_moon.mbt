// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `moon`.

///|
/// §20.1.10.56 `moon` — a crescent moon: a half-ellipse outer edge and
/// a concave inner arc that carves the crescent bite.
///
/// Spec path: `moveTo(r,b)` → `arcTo(w,hd2,cd4,cd2)` (the outer edge —
/// a half-ellipse from bottom-right round to top-right) →
/// `arcTo(g18w,dy1,stAng1,swAng1)` (the inner concave edge back down to
/// the start) → `close`.
///
/// The inner arc's radii and angles in the spec come from `at2`/`sqrt`
/// guide formulas that the integer guide engine here does not
/// evaluate. The default `adj = 50000` produces a half-moon. This
/// generator reproduces the silhouette with the exact outer
/// half-ellipse (bulging left, filling the box) and a single inner
/// `ArcTo` whose horizontal radius is `adj` percent of the width — a
/// shallower left-bulge that carves the crescent opening to the right.
/// A larger `adj` leaves a thinner crescent; a smaller `adj` leaves a
/// fatter one.
pub fn build_moon(width : Int, height : Int) -> ShapeGeometry {
  let cy = height / 2
  // adj = 50000: the inner edge's horizontal radius. Both edges run
  // between the top-right and bottom-right corners; the outer edge
  // bulges fully left to x = 0, the inner edge only to
  // x = width - inner_rx, so the gap between them is the crescent.
  let inner_rx = percent(width, 50000)
  let commands : Array[PathCommand] = []
  // Bottom-right start.
  commands.push(MoveTo(width, height))
  // Outer edge: left-bulging half-ellipse (radii w × hd2) from
  // bottom-right to top-right. sweep = false bows it into the box,
  // through the left-mid point (0, cy).
  commands.push(ArcTo(width, cy, 0, false, false, width, 0))
  // Inner concave edge: a shallower left-bulging arc back down to the
  // start, through (width - inner_rx, cy). This carves the crescent.
  commands.push(ArcTo(inner_rx, cy, 0, false, false, width, height))
  commands.push(ClosePath)
  { commands, width, height }
}
