///|
/// Part 1 §20.1.10.56 `star{n}` — n-pointed star with alternating
/// outer and inner vertices. The outer vertices sit on the
/// bounding-box-inscribed circle; the inner radius defaults to 40% of
/// the outer radius (the canonical PowerPoint default for `adj`
/// across the star presets). The first outer point sits at the top
/// of the bounding box and successive points proceed clockwise.
///
/// Returns a closed path of `2 * n` line segments plus the
/// `ClosePath` terminator.
pub fn build_star(points : Int, width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let outer_rx = width / 2
  let outer_ry = height / 2
  let inner_rx = percent(outer_rx, 40000)
  let inner_ry = percent(outer_ry, 40000)
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
