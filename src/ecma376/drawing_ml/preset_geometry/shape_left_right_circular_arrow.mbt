// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry —
// `leftRightCircularArrow`.

///|
/// §20.1.10.56 `leftRightCircularArrow` — a curved arrow band swept
/// around a ring with an arrowhead at *both* ends, so it reads as a
/// two-way circular arrow.
///
/// As with `circularArrow` / `leftCircularArrow`, the spec geometry
/// solves a quadratic for each arrowhead/ring tangent. This generator
/// implements a faithful, recognisable **approximation**: a
/// concentric two-arc band swept ~240°, capped by a triangular
/// arrowhead at each end. Defaults `adj1 = 12500` / `adj5 = 12500`
/// drive the band thickness and arrowhead overhang.
pub fn build_left_right_circular_arrow(
  width : Int,
  height : Int,
) -> ShapeGeometry {
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

  // The band sweeps clockwise from `start` to `endd` (~240°); a
  // 30°-tangent arrowhead caps each end.
  let start = -30
  let endd = 210
  let commands : Array[PathCommand] = []
  // Outer rim, clockwise.
  let (ox0, oy0) = pt(start, outer_rx, outer_ry)
  let (ox1, oy1) = pt(endd, outer_rx, outer_ry)
  commands.push(MoveTo(ox0, oy0))
  commands.push(ArcTo(outer_rx, outer_ry, 0, true, true, ox1, oy1))
  // Arrowhead at the clockwise (end) terminal.
  let (e_out_x, e_out_y) = pt(endd, outer_rx + thh, outer_ry + thh)
  let (e_tip_x, e_tip_y) = pt(endd + 30, mid_rx, mid_ry)
  let (e_in_x, e_in_y) = pt(endd, inner_rx - thh, inner_ry - thh)
  commands.push(LineTo(e_out_x, e_out_y))
  commands.push(LineTo(e_tip_x, e_tip_y))
  commands.push(LineTo(e_in_x, e_in_y))
  // Inner rim back, counter-clockwise.
  let (ix0, iy0) = pt(endd, inner_rx, inner_ry)
  let (ix1, iy1) = pt(start, inner_rx, inner_ry)
  commands.push(LineTo(ix0, iy0))
  commands.push(ArcTo(inner_rx, inner_ry, 0, true, false, ix1, iy1))
  // Arrowhead at the counter-clockwise (start) terminal.
  let (s_in_x, s_in_y) = pt(start, inner_rx - thh, inner_ry - thh)
  let (s_tip_x, s_tip_y) = pt(start - 30, mid_rx, mid_ry)
  let (s_out_x, s_out_y) = pt(start, outer_rx + thh, outer_ry + thh)
  commands.push(LineTo(s_in_x, s_in_y))
  commands.push(LineTo(s_tip_x, s_tip_y))
  commands.push(LineTo(s_out_x, s_out_y))
  commands.push(ClosePath)
  { commands, width, height }
}
