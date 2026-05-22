// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartOffpageConnector`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartOffpageConnector` — a rectangle whose bottom
/// edge tapers down to a central point (a home-plate pointing down),
/// denoting an off-page connector in a flow chart.
///
/// Spec path (10×10 frame): vertices at (0,0) (10,0) (10,8) (5,10)
/// (0,8).
pub fn build_flow_chart_offpage_connector(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 10)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 10)
  }

  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(0)),
    LineTo(sx(10), sy(0)),
    LineTo(sx(10), sy(8)),
    LineTo(sx(5), sy(10)),
    LineTo(sx(0), sy(8)),
    ClosePath,
  ]
  { commands, width, height }
}
