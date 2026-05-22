// ECMA-376 Part 1 §20.1.10.56 — shared arc-endpoint helpers for the
// circular / arc shape family (`pie`, `chord`, `arc`, `blockArc`,
// `pieWedge`, `noSmoking`, `moon`). DrawingML expresses arcs as a
// start angle `stAng` and a swept angle `swAng`, both in 60000ths of a
// degree, on an ellipse of radii `wR`/`hR` centred at `(cx, cy)`. SVG's
// `ArcTo` instead needs the explicit end point plus `largeArc`/`sweep`
// flags. These helpers bridge the two representations using the
// integer trig tables from `geometry.mbt`.

///|
/// Convert a DrawingML angle (60000ths of a degree) to whole degrees.
/// Rounds to the nearest degree, which is the resolution of the
/// `sin10000` / `cos10000` tables.
fn dml_angle_to_degrees(angle60000 : Int) -> Int {
  // Round half away from zero.
  if angle60000 >= 0 {
    (angle60000 + 30000) / 60000
  } else {
    (angle60000 - 30000) / 60000
  }
}

///|
/// Point on the ellipse centred at `(cx, cy)` with radii `(rx, ry)` at
/// DrawingML angle `angle60000` (60000ths of a degree, measured
/// clockwise from the positive x-axis in the y-down coordinate frame).
fn ellipse_point(
  cx : Int,
  cy : Int,
  rx : Int,
  ry : Int,
  angle60000 : Int,
) -> (Int, Int) {
  let deg = dml_angle_to_degrees(angle60000)
  let x = cx + fraction(rx, cos10000(deg), 10000)
  let y = cy + fraction(ry, sin10000(deg), 10000)
  (x, y)
}

///|
/// Emit one `ArcTo` from the implied current point to the end of a
/// DrawingML arc segment. `stAng` is the start angle and `swAng` the
/// swept angle, both in 60000ths of a degree; a positive `swAng` sweeps
/// clockwise, which in the y-down frame is the SVG `sweep = true`
/// direction. `largeArc` is set when the absolute sweep exceeds 180°.
/// The caller is responsible for positioning the pen at the arc's start
/// point (`ellipse_point(cx, cy, rx, ry, stAng)`) beforehand.
fn arc_to_command(
  cx : Int,
  cy : Int,
  rx : Int,
  ry : Int,
  st_ang : Int,
  sw_ang : Int,
) -> PathCommand {
  let (ex, ey) = ellipse_point(cx, cy, rx, ry, st_ang + sw_ang)
  let large_arc = if sw_ang >= 0 { sw_ang > 10800000 } else { -sw_ang >
    10800000 }
  let sweep = sw_ang >= 0
  ArcTo(rx, ry, 0, large_arc, sweep, ex, ey)
}
