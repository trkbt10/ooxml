// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartOnlineStorage`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartOnlineStorage` — a rectangle whose right
/// edge curves inward (a concave half-ellipse) and whose left edge
/// bulges outward, denoting online storage in a flow chart.
///
/// Spec path (6×6 frame): moveTo (1,0) → lnTo (6,0) → arcTo
/// (wR=1,hR=3, stAng=270°, swAng=-180°) ending at (6,6) → lnTo (1,6)
/// → arcTo (wR=1,hR=3, stAng=90°, swAng=180°) ending at (1,0). The
/// right cap is concave (sweep=false in the y-down SVG frame); the
/// left cap is convex (sweep=true).
pub fn build_flow_chart_online_storage(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 6)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 6)
  }

  // Cap radii: rx is 1/6 of the width, ry is half the height.
  let rx = fraction(width, 1, 6)
  let ry = fraction(height, 3, 6)
  let commands : Array[PathCommand] = [
    MoveTo(sx(1), sy(0)),
    LineTo(sx(6), sy(0)),
    // Right cap — concave half-ellipse curving inward.
    ArcTo(rx, ry, 0, false, false, sx(6), sy(6)),
    LineTo(sx(1), sy(6)),
    // Left cap — convex half-ellipse bulging outward.
    ArcTo(rx, ry, 0, false, true, sx(1), sy(0)),
    ClosePath,
  ]
  { commands, width, height }
}
