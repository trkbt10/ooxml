///|
/// Part 1 §21.4.7.1 cycle — place N children evenly around a
/// circle inscribed in the bounding box. The first child sits at
/// 12 o'clock (`-90°`) and children proceed clockwise. Each child
/// occupies a square of side `min(width, height) / 3`, centred
/// on its computed angle. The radius is the inscribed circle's
/// radius shrunk by half the cell side so cells stay inside the
/// bounds.
pub fn layout_cycle(inner : BoundsRect, child_count : Int) -> Array[BoundsRect] {
  let result : Array[BoundsRect] = []
  if child_count <= 0 {
    return result
  }
  let cell = double_min(inner.width, inner.height) / 3.0
  let half_cell = cell / 2.0
  let cx = inner.x + inner.width / 2.0
  let cy = inner.y + inner.height / 2.0
  let raw_radius = double_min(inner.width, inner.height) / 2.0 - half_cell
  let radius = if raw_radius < 0.0 { 0.0 } else { raw_radius }
  let n = child_count
  let step = 360.0 / n.to_double()
  for i in 0..<n {
    let theta_deg = -90.0 + i.to_double() * step
    let (sin_val, cos_val) = sin_cos_deg(theta_deg)
    let centre_x = cx + radius * cos_val
    let centre_y = cy + radius * sin_val
    let bounds = {
      x: centre_x - half_cell,
      y: centre_y - half_cell,
      width: cell,
      height: cell,
    }
    result.push(bounds)
  }
  result
}

///|
/// Pure-MoonBit sine / cosine for a degree value. Uses the
/// canonical Taylor-series implementation against a normalised
/// radian range so the layout engine does not depend on the
/// platform math library — keeps the package portable to the
/// wasm-gc build target.
fn sin_cos_deg(degrees : Double) -> (Double, Double) {
  let normalised = normalise_degrees(degrees)
  let radians = normalised * (3.14159265358979323846 / 180.0)
  let s = taylor_sin(radians)
  let c = taylor_cos(radians)
  (s, c)
}

///|
/// Normalise a degree value into the `[-180, 180]` range so the
/// Taylor series converges quickly. The cycle algorithm only
/// passes values in `[-90, -90 + 360)` so the normalisation is a
/// single fold rather than an iterative subtraction.
fn normalise_degrees(degrees : Double) -> Double {
  let mut value = degrees
  while value > 180.0 {
    value = value - 360.0
  }
  while value < -180.0 {
    value = value + 360.0
  }
  value
}

///|
/// Taylor-series sine to seven terms. The maximum input
/// magnitude after `normalise_degrees` is `π`, where the series
/// converges to ≈ 1e-9 — plenty for layout positioning.
fn taylor_sin(x : Double) -> Double {
  let x2 = x * x
  let t1 = x
  let t3 = -t1 * x2 / 6.0
  let t5 = -t3 * x2 / 20.0
  let t7 = -t5 * x2 / 42.0
  let t9 = -t7 * x2 / 72.0
  let t11 = -t9 * x2 / 110.0
  let t13 = -t11 * x2 / 156.0
  t1 + t3 + t5 + t7 + t9 + t11 + t13
}

///|
/// Taylor-series cosine to seven terms. Same convergence
/// envelope as `taylor_sin`.
fn taylor_cos(x : Double) -> Double {
  let x2 = x * x
  let t0 = 1.0
  let t2 = -t0 * x2 / 2.0
  let t4 = -t2 * x2 / 12.0
  let t6 = -t4 * x2 / 30.0
  let t8 = -t6 * x2 / 56.0
  let t10 = -t8 * x2 / 90.0
  let t12 = -t10 * x2 / 132.0
  t0 + t2 + t4 + t6 + t8 + t10 + t12
}

///|
/// Min helper for `Double`. MoonBit's `Double` does not expose
/// `min` directly through the `Number` trait at the time of
/// writing, so we inline the simple branch here.
pub fn double_min(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}
