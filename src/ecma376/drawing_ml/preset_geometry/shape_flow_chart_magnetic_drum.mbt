// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartMagneticDrum`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartMagneticDrum` — a cylinder lying on its
/// side: flat top and bottom edges with elliptical left and right
/// caps, denoting a magnetic drum in a flow chart.
///
/// Spec path (6×6 frame): the filled body runs moveTo (1,0) → lnTo
/// (5,0) → right cap arc (wR=1,hR=3) to (5,6) → lnTo (1,6) → left
/// cap arc to (1,0) → close. A stroke-only detail sub-path draws the
/// visible front rim of the right cap from (5,6) curving to (5,0).
/// All caps are convex 180° half-ellipses (sweep=true in the y-down
/// SVG frame).
pub fn build_flow_chart_magnetic_drum(
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
    // Body — top, right cap, bottom, left cap.
    MoveTo(sx(1), sy(0)),
    LineTo(sx(5), sy(0)),
    ArcTo(rx, ry, 0, false, true, sx(5), sy(6)),
    LineTo(sx(1), sy(6)),
    ArcTo(rx, ry, 0, false, true, sx(1), sy(0)),
    ClosePath,
    // Stroke-only detail — front rim of the right cap.
    MoveTo(sx(5), sy(6)),
    ArcTo(rx, ry, 0, false, true, sx(5), sy(0)),
  ]
  { commands, width, height }
}
