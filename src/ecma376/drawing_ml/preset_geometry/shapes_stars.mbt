///|
/// Part 1 §20.1.10.56 `star{n}` — n-pointed star with alternating
/// outer and inner vertices. Per the spec gdLst the outer radii are
/// scaled by the per-star factors `hf` / `vf`
/// (`swd2 = wd2·hf/100000`, `shd2 = hd2·vf/100000`) so the points
/// reach the bounding box, and the inner radii are
/// `iwd2 = swd2·a/50000` / `ihd2 = shd2·a/50000` with
/// `a = pin 0 adj 50000` (each star carries its own `adj` default —
/// e.g. 19098 for star5, the golden-ratio point sharpness). The first
/// outer point sits at the top and successive vertices proceed
/// clockwise.
///
/// Returns a closed path of `2 * n` line segments plus the
/// `ClosePath` terminator.
pub fn build_star(
  points : Int,
  width : Int,
  height : Int,
  adj~ : Int,
  hf~ : Int = 100000,
  vf~ : Int = 100000,
) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let outer_rx = fraction(width / 2, hf, 100000)
  let outer_ry = fraction(height / 2, vf, 100000)
  let a = pin_int(adj, 0, 50000)
  let inner_rx = fraction(outer_rx, a, 50000)
  let inner_ry = fraction(outer_ry, a, 50000)
  let step = 360 / (points * 2)
  let commands : Array[PathCommand] = []
  for i in 0..<(points * 2) {
    let theta = -90 + i * step
    let (rx, ry) = if i % 2 == 0 {
      (outer_rx, outer_ry)
    } else {
      (inner_rx, inner_ry)
    }
    let x = cx + fraction(rx, cos10000(theta), 10000)
    let y = cy + fraction(ry, sin10000(theta), 10000)
    if i == 0 {
      commands.push(MoveTo(x, y))
    } else {
      commands.push(LineTo(x, y))
    }
  }
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// §20.1.10.56 — per-star `(points, default adj, hf, vf)` from the
/// spec preset definitions. `hf` / `vf` default to 100000 (no scale)
/// when the star omits them. Returns `None` for non-star presets.
pub fn star_params(shape : PresetShape) -> (Int, Int, Int, Int)? {
  match shape {
    ShapeStar4 => Some((4, 12500, 100000, 100000))
    ShapeStar5 => Some((5, 19098, 105146, 110557))
    ShapeStar6 => Some((6, 28868, 115470, 100000))
    ShapeStar7 => Some((7, 34601, 102572, 105210))
    ShapeStar8 => Some((8, 37500, 100000, 100000))
    ShapeStar10 => Some((10, 42533, 105146, 100000))
    ShapeStar12 => Some((12, 37500, 100000, 100000))
    ShapeStar16 => Some((16, 37500, 100000, 100000))
    ShapeStar24 => Some((24, 37500, 100000, 100000))
    ShapeStar32 => Some((32, 37500, 100000, 100000))
    _ => None
  }
}
