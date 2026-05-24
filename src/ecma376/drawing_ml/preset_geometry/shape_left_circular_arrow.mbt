// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftCircularArrow`.

///|
/// §20.1.10.56 `leftCircularArrow` — a curved arrow swept around a
/// ring, the mirror of `circularArrow`: the arrowhead sits at the
/// counter-clockwise (left) end of the band.
///
/// Like `circularArrow`, the spec geometry solves a quadratic for the
/// arrowhead/ring tangent (`adj1..adj5` with `adj2`/`adj3` as the
/// signed sweep limits). Rendering that verbatim is out of proportion
/// to the visual payoff, so this generator implements a faithful,
/// recognisable **approximation**: a concentric two-arc band swept
/// ~270° with a triangular arrowhead at the band's leading (left)
/// end. Defaults `adj1 = 12500` / `adj5 = 12500` drive the band
/// thickness and arrowhead overhang.
pub fn build_left_circular_arrow(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let ss = min_dim(width, height)
  let th = percent(ss, 12500)
  let thh = percent(ss, 12500)
  let outer_rx = width / 2
  let outer_ry = height / 2
  let inner_rx = outer_rx - th
  let inner_ry = outer_ry - th
  let mid_rx = outer_rx - th / 2
  let mid_ry = outer_ry - th / 2
  fn pt(deg : Int, rx : Int, ry : Int) -> (Int, Int) {
    (
      cx + fraction(rx, cos10000(deg), 10000),
      cy + fraction(ry, sin10000(deg), 10000),
    )
  }

  // The band sweeps counter-clockwise from `start` to `endd`; the
  // arrowhead caps the leading (counter-clockwise) end.
  let start = 210
  let endd = -60
  let commands : Array[PathCommand] = []
  let (ox0, oy0) = pt(start, outer_rx, outer_ry)
  let (ox1, oy1) = pt(endd, outer_rx, outer_ry)
  commands.push(MoveTo(ox0, oy0))
  // Counter-clockwise outer rim.
  commands.push(ArcTo(outer_rx, outer_ry, 0, true, false, ox1, oy1))
  // Arrowhead at the leading end, pointing along the ring tangent.
  let (bx_out, by_out) = pt(endd, outer_rx + thh, outer_ry + thh)
  let (tipx, tipy) = pt(endd - 30, mid_rx, mid_ry)
  let (bx_in, by_in) = pt(endd, inner_rx - thh, inner_ry - thh)
  commands.push(LineTo(bx_out, by_out))
  commands.push(LineTo(tipx, tipy))
  commands.push(LineTo(bx_in, by_in))
  let (ix0, iy0) = pt(endd, inner_rx, inner_ry)
  let (ix1, iy1) = pt(start, inner_rx, inner_ry)
  commands.push(LineTo(ix0, iy0))
  // Clockwise inner rim back to the start.
  commands.push(ArcTo(inner_rx, inner_ry, 0, true, true, ix1, iy1))
  commands.push(ClosePath)
  { commands, width, height }
}
