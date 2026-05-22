// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `circularArrow`.

///|
/// §20.1.10.56 `circularArrow` — an arrow bent around a near-full
/// circle: a thick curved band that sweeps most of the way round a
/// ring and terminates in an arrowhead.
///
/// The spec geometry is exceptionally elaborate — it solves a
/// quadratic for the line/ellipse intersection that places the
/// arrowhead tangent to the ring (the `q1`..`q22`, `u1`..`u21`,
/// `v1`..`v22` guide cascades). Rendering that verbatim is out of
/// proportion to the visual payoff, so this generator implements a
/// faithful, recognisable **approximation**: a concentric two-arc
/// band swept ~270° plus a triangular arrowhead at the band's end.
///
/// Defaults from the spec `avLst` drive the proportions: `adj1 =
/// 12500` (band thickness `th` as parts-per-100000 of `ss`), `adj5 =
/// 12500` (arrowhead overhang `thh`), `adj3`/`adj4` set the end and
/// start angles of the sweep (start ≈ 270°, sweeping clockwise almost
/// the whole way round). The band here starts just past the top and
/// sweeps clockwise 270°, leaving a gap where the arrowhead points
/// inward toward the ring centre.
pub fn build_circular_arrow(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let ss = min_dim(width, height)
  // Band thickness and arrowhead overhang from the spec adj defaults.
  let th = percent(ss, 12500)
  let thh = percent(ss, 12500)
  // Outer rim sits on the bounding box; the inner rim is `th` inside.
  let outer_rx = width / 2
  let outer_ry = height / 2
  let inner_rx = outer_rx - th
  let inner_ry = outer_ry - th
  // Mid radius for the arrowhead tip placement.
  let mid_rx = outer_rx - th / 2
  let mid_ry = outer_ry - th / 2

  // Place a point on the ring at `deg` (degrees, clockwise, y-down).
  fn pt(deg : Int, rx : Int, ry : Int) -> (Int, Int) {
    (
      cx + fraction(rx, cos10000(deg), 10000),
      cy + fraction(ry, sin10000(deg), 10000),
    )
  }

  // The band sweeps clockwise from `start` to `endd` (270°). The
  // remaining 90° gap is bridged by the arrowhead.
  let start = -60
  let endd = 210
  let commands : Array[PathCommand] = []
  // Outer rim from start angle to end angle.
  let (ox0, oy0) = pt(start, outer_rx, outer_ry)
  let (ox1, oy1) = pt(endd, outer_rx, outer_ry)
  commands.push(MoveTo(ox0, oy0))
  commands.push(ArcTo(outer_rx, outer_ry, 0, true, true, ox1, oy1))
  // Arrowhead: the band's outer end flares out to a barb, the tip
  // points along the ring tangent, then the inner barb tucks back.
  let (bx_out, by_out) = pt(endd, outer_rx + thh, outer_ry + thh)
  let (tipx, tipy) = pt(endd + 30, mid_rx, mid_ry)
  let (bx_in, by_in) = pt(endd, inner_rx - thh, inner_ry - thh)
  commands.push(LineTo(bx_out, by_out))
  commands.push(LineTo(tipx, tipy))
  commands.push(LineTo(bx_in, by_in))
  // Inner rim back from end angle to start angle (counter-clockwise).
  let (ix0, iy0) = pt(endd, inner_rx, inner_ry)
  let (ix1, iy1) = pt(start, inner_rx, inner_ry)
  commands.push(LineTo(ix0, iy0))
  commands.push(ArcTo(inner_rx, inner_ry, 0, true, false, ix1, iy1))
  commands.push(ClosePath)
  { commands, width, height }
}
