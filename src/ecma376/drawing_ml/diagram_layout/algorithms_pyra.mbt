///|
/// Part 1 §21.4.7.1 pyra — stack trapezoidal rows from
/// wide-at-base to narrow-at-top, one child per row. Each row's
/// height is `inner.height / n`; the row width at row `i` (0 =
/// top) interpolates linearly between the `pyraAcctRatio`
/// constraint value (top-width fraction, default `0.25`) and
/// `1.0` (bottom-width fraction).
///
/// The pyramid is built with index `0` at the **top** (narrowest)
/// and `n-1` at the **base** (widest), matching §21.4.2's
/// description of pyra as growing top-to-bottom along a vertical
/// path.
pub fn layout_pyra(
  inner : BoundsRect,
  constraints : Array[Constraint],
  child_count : Int,
) -> Array[BoundsRect] {
  let result : Array[BoundsRect] = []
  if child_count <= 0 {
    return result
  }
  let n = child_count
  let top_fraction = pyra_top_fraction(constraints)
  let row_h = inner.height / n.to_double()
  for i in 0..<n {
    let denom = if n == 1 { 1.0 } else { (n - 1).to_double() }
    let frac = top_fraction + (1.0 - top_fraction) * i.to_double() / denom
    let row_w = inner.width * frac
    let bounds = {
      x: inner.x + (inner.width - row_w) / 2.0,
      y: inner.y + i.to_double() * row_h,
      width: row_w,
      height: row_h,
    }
    result.push(bounds)
  }
  result
}

///|
/// Return the `pyraAcctRatio` constraint value or the default
/// `0.25`. The default is taken from the canonical Microsoft
/// pyramid layout where the top trapezoid is roughly a quarter
/// the width of the base.
pub fn pyra_top_fraction(constraints : Array[Constraint]) -> Double {
  for c in constraints {
    match c.kind {
      ConstrPyraAcctRatio =>
        match c.val {
          Some(value) => return value
          None => ()
        }
      _ => ()
    }
  }
  0.25
}
