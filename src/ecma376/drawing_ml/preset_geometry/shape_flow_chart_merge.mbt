// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartMerge`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartMerge` — a downward-pointing triangle,
/// denoting a merge operation in a flow chart.
///
/// Spec path (2×2 frame): vertices at (0,0) (2,0) (1,2).
pub fn build_flow_chart_merge(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 2)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 2)
  }

  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(0)),
    LineTo(sx(2), sy(0)),
    LineTo(sx(1), sy(2)),
    ClosePath,
  ]
  { commands, width, height }
}
