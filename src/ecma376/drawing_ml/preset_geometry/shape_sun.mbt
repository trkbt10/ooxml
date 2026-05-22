// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `sun`.

///|
/// §20.1.10.56 `sun` — a central disc with eight triangular rays at
/// 45° intervals.
///
/// Spec path: eight `moveTo`/`lnTo`/`lnTo`/`close` triangles (the rays)
/// followed by a `moveTo(x19,vc)` → `arcTo(wR,hR,cd2,21600000)` →
/// `close` full-circle disc. The ray tips and bases are derived from a
/// long chain of `g0`..`g18` guides keyed off the `adj` value.
///
/// The default `adj = 25000` gives a disc radius `g0 = 50000 - adj =
/// 25000` (25% of the box). This generator reproduces the silhouette
/// with that exact disc radius and eight isoceles triangular rays:
/// each ray's two base points sit on the disc and its tip reaches the
/// bounding ellipse. The disc is emitted as two 180° arcs so the
/// `large_arc` flag stays false (matching `build_ellipse`).
pub fn build_sun(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  // Disc radius: g0 = 50000 - adj = 25000 ⇒ 25% of each axis.
  let disc_rx = percent(width, 25000)
  let disc_ry = percent(height, 25000)
  // Ray tips reach the bounding ellipse (half width / height).
  let tip_rx = width / 2
  let tip_ry = height / 2
  // Half-angular width of each ray's base on the disc.
  let ray_half_deg = 18
  let commands : Array[PathCommand] = []
  // Eight rays at 45° intervals starting from the +x axis.
  for i in 0..<8 {
    let centre_deg = i * 45
    let a0 = centre_deg - ray_half_deg
    let a1 = centre_deg + ray_half_deg
    let base0x = cx + fraction(disc_rx, cos10000(a0), 10000)
    let base0y = cy + fraction(disc_ry, sin10000(a0), 10000)
    let base1x = cx + fraction(disc_rx, cos10000(a1), 10000)
    let base1y = cy + fraction(disc_ry, sin10000(a1), 10000)
    let tipx = cx + fraction(tip_rx, cos10000(centre_deg), 10000)
    let tipy = cy + fraction(tip_ry, sin10000(centre_deg), 10000)
    commands.push(MoveTo(base0x, base0y))
    commands.push(LineTo(tipx, tipy))
    commands.push(LineTo(base1x, base1y))
    commands.push(ClosePath)
  }
  // Central disc — two 180° arcs.
  commands.push(MoveTo(cx - disc_rx, cy))
  commands.push(ArcTo(disc_rx, disc_ry, 0, false, true, cx + disc_rx, cy))
  commands.push(ArcTo(disc_rx, disc_ry, 0, false, true, cx - disc_rx, cy))
  commands.push(ClosePath)
  { commands, width, height }
}
