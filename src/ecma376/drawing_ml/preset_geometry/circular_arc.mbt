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
/// DrawingML guide formula `at2 x y` (§20.1.9 guide language): the
/// angle of the vector `(x, y)` measured clockwise from the positive
/// x-axis in the y-down coordinate frame, returned in 60000ths of a
/// degree — the unit DrawingML uses for `stAng`/`swAng`. This is
/// `atan2(y, x)` scaled to 60000ths of a degree (round half away from
/// zero). It is verified in the wbtest against the cardinal and 45°
/// diagonal angles, so it serves as a non-circular primitive when
/// transcribing preset guide chains that need angular adjustments
/// (e.g. the curved-arrow family).
fn at2(x : Int, y : Int) -> Int {
  let rad = @math.atan2(y.to_double(), x.to_double())
  let units = rad * 180.0 / @math.PI * 60000.0
  if units >= 0.0 {
    (units + 0.5).to_int()
  } else {
    (units - 0.5).to_int()
  }
}

///|
/// DrawingML guide formula `cos x y` (§20.1.9): `x · cos(y)` where `y`
/// is an angle in 60000ths of a degree. Evaluated with the integer
/// `cos10000` table so it stays exact at the cardinal angles.
fn gcos(scalar : Int, angle60000 : Int) -> Int {
  fraction(scalar, cos10000(dml_angle_to_degrees(angle60000)), 10000)
}

///|
/// DrawingML guide formula `sin x y` (§20.1.9): `x · sin(y)`, `y` in
/// 60000ths of a degree, via the integer `sin10000` table.
fn gsin(scalar : Int, angle60000 : Int) -> Int {
  fraction(scalar, sin10000(dml_angle_to_degrees(angle60000)), 10000)
}

///|
/// DrawingML guide formula `cat2 x y z` (§20.1.9): `x · cos(at2(y, z))`
/// = `x · cos(atan2(z, y))` — the "cosine arctangent" used to project a
/// scalar onto the x-axis of a direction vector `(y, z)`. Composed from
/// the verified `at2` and `gcos` primitives.
fn gcat2(x : Int, y : Int, z : Int) -> Int {
  gcos(x, at2(y, z))
}

///|
/// DrawingML guide formula `sat2 x y z` (§20.1.9): `x · sin(at2(y, z))`
/// = `x · sin(atan2(z, y))` — the "sine arctangent" counterpart of
/// `cat2`, projecting onto the y-axis of the direction `(y, z)`.
fn gsat2(x : Int, y : Int, z : Int) -> Int {
  gsin(x, at2(y, z))
}

///|
/// DrawingML guide formula `mod x y z` (§20.1.9): the Euclidean
/// magnitude `√(x² + y² + z²)` of the 3-vector. Used by the preset
/// guide chains to normalise direction vectors (e.g. the `noSmoking`
/// bar slice radii). Computed via the verified integer `isqrt`.
fn gmod(x : Int, y : Int, z : Int) -> Int {
  isqrt(x * x + y * y + z * z)
}

///|
/// Integer floor square root for DrawingML `sqrt` guide formulas.
/// Negative inputs clamp to 0 (the spec guides only take `sqrt` of
/// non-negative quantities such as `w² − ah²`). Computed via the
/// double-precision `sqrt` then truncated, matching the integer guide
/// arithmetic used throughout this package.
fn isqrt(n : Int) -> Int {
  if n <= 0 {
    0
  } else {
    n.to_double().sqrt().to_int()
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
  let large_arc = if sw_ang >= 0 {
    sw_ang > 10800000
  } else {
    -sw_ang > 10800000
  }
  let sweep = sw_ang >= 0
  ArcTo(rx, ry, 0, large_arc, sweep, ex, ey)
}

///|
/// Emit a DrawingML *relative* `<a:arcTo wR hR stAng swAng>`: the pen is
/// already at a point ON the implied ellipse at angle `st_ang`, so the
/// centre is `current − (wR·cos stAng, hR·sin stAng)` and the end is
/// `current + (wR·(cos(stAng+swAng) − cos stAng), hR·(sin(stAng+swAng) −
/// sin stAng))`. Returns the SVG `ArcTo` plus the new current point so a
/// caller can chain. Angles are in 60000ths of a degree; `sweep =
/// swAng > 0`, `largeArc = |swAng| > 180°`. This is the inverse of
/// `arc_to_command` (which takes an explicit centre); it is verified
/// independently of any preset in the wbtest against known arc maths.
fn rel_arc(
  cur_x : Int,
  cur_y : Int,
  wr : Int,
  hr : Int,
  st_ang : Int,
  sw_ang : Int,
) -> (PathCommand, Int, Int) {
  let st_deg = dml_angle_to_degrees(st_ang)
  let end_deg = dml_angle_to_degrees(st_ang + sw_ang)
  let end_x = cur_x + fraction(wr, cos10000(end_deg) - cos10000(st_deg), 10000)
  let end_y = cur_y + fraction(hr, sin10000(end_deg) - sin10000(st_deg), 10000)
  let abs_sw = if sw_ang < 0 { -sw_ang } else { sw_ang }
  let large_arc = abs_sw > 10800000
  let sweep = sw_ang > 0
  (ArcTo(wr, hr, 0, large_arc, sweep, end_x, end_y), end_x, end_y)
}
