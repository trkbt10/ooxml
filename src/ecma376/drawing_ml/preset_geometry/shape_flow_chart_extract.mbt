// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartExtract`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartExtract` — an upward-pointing triangle,
/// denoting an extract operation in a flow chart.
///
/// Spec path (2×2 frame): vertices at (0,2) (1,0) (2,2).
pub fn build_flow_chart_extract(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 2)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 2)
  }

  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(2)),
    LineTo(sx(1), sy(0)),
    LineTo(sx(2), sy(2)),
    ClosePath,
  ]
  { commands, width, height }
}
