// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `noSmoking`.

///|
/// §20.1.10.56 `noSmoking` — the prohibition ("no") symbol: a circular
/// ring with a diagonal bar crossing the inner opening.
///
/// The spec builds this as a full outer ellipse, then two arc-bounded
/// slices that together form the diagonal bar inside the inner circle.
/// The exact slice boundaries depend on `at2`/`mod`/`sqrt` guide
/// formulas that the integer guide engine here does not evaluate, so
/// this generator reproduces the *silhouette* faithfully with a
/// simpler, documented construction:
///
///   * an outer ellipse and a concentric inner ellipse (the ring), and
///   * a diagonal bar — a thin rotated rectangle — drawn across the
///     inner opening from the top-left to the bottom-right of the
///     inner circle, its width equal to the ring thickness `dr`.
///
/// The default `adj` guide is 18750, so `dr = ss * 18750 / 100000`.
pub fn build_no_smoking(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  let dr = percent(min_dim(width, height), 18750)
  let irx = rx - dr
  let iry = ry - dr
  let commands : Array[PathCommand] = []
  // Outer ellipse — clockwise.
  commands.push(MoveTo(cx - rx, cy))
  commands.push(ArcTo(rx, ry, 0, false, true, cx + rx, cy))
  commands.push(ArcTo(rx, ry, 0, false, true, cx - rx, cy))
  commands.push(ClosePath)
  // Inner ellipse — counter-clockwise so the ring stays hollow.
  commands.push(MoveTo(cx - irx, cy))
  commands.push(ArcTo(irx, iry, 0, false, false, cx + irx, cy))
  commands.push(ArcTo(irx, iry, 0, false, false, cx - irx, cy))
  commands.push(ClosePath)
  // Diagonal bar across the inner opening. The bar runs from the
  // top-left to the bottom-right of the inner circle; its half-width
  // (perpendicular offset) is dr/2. The diagonal direction is the
  // 45°/-135° axis of the inner ellipse.
  let cos45 = cos10000(45)
  let sin45 = sin10000(45)
  // Endpoints on the inner circle along the −45° diagonal (top-left,
  // bottom-right). y grows downward, so the top-left endpoint uses a
  // negative y offset.
  let ax = cx - fraction(irx, cos45, 10000)
  let ay = cy - fraction(iry, sin45, 10000)
  let bx = cx + fraction(irx, cos45, 10000)
  let by = cy + fraction(iry, sin45, 10000)
  // Perpendicular offset vector (length dr/2) — perpendicular to the
  // diagonal, i.e. along the +45° direction.
  let half = dr / 2
  let ox = fraction(half, cos45, 10000)
  let oy = -fraction(half, sin45, 10000)
  commands.push(MoveTo(ax + ox, ay + oy))
  commands.push(LineTo(bx + ox, by + oy))
  commands.push(LineTo(bx - ox, by - oy))
  commands.push(LineTo(ax - ox, ay - oy))
  commands.push(ClosePath)
  { commands, width, height }
}
