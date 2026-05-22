// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartMagneticDisk`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartMagneticDisk` — a cylinder seen from the
/// side (a "database can"): a rectangle whose top and bottom edges
/// are elliptical rims, denoting a magnetic disk in a flow chart.
///
/// Spec path (6×6 frame): the filled body runs moveTo (0,1) → top
/// rim arc (wR=3,hR=1) to (6,1) → lnTo (6,5) → bottom rim arc to
/// (0,5) → close. A stroke-only detail sub-path draws the visible
/// lower half of the top ellipse from (6,1) curving down to (0,1).
/// All rim arcs are convex 180° half-ellipses (sweep=true in the
/// y-down SVG frame).
pub fn build_flow_chart_magnetic_disk(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 6)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 6)
  }

  // Rim radii: rx is half the width, ry is 1/6 of the height.
  let rx = fraction(width, 3, 6)
  let ry = fraction(height, 1, 6)
  let commands : Array[PathCommand] = [
    // Body — top rim, right side, bottom rim, left side.
    MoveTo(sx(0), sy(1)),
    ArcTo(rx, ry, 0, false, true, sx(6), sy(1)),
    LineTo(sx(6), sy(5)),
    ArcTo(rx, ry, 0, false, true, sx(0), sy(5)),
    ClosePath,
    // Stroke-only detail — front rim of the top ellipse.
    MoveTo(sx(6), sy(1)),
    ArcTo(rx, ry, 0, false, true, sx(0), sy(1)),
  ]
  { commands, width, height }
}
