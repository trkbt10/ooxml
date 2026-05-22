// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartPreparation`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartPreparation` — an elongated hexagon (a
/// rectangle with both vertical ends pinched into a point), denoting
/// a preparation step in a flow chart.
///
/// Spec path (10×10 frame): vertices at (0,5) (2,0) (8,0) (10,5)
/// (8,10) (2,10).
pub fn build_flow_chart_preparation(
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
    MoveTo(sx(0), sy(5)),
    LineTo(sx(2), sy(0)),
    LineTo(sx(8), sy(0)),
    LineTo(sx(10), sy(5)),
    LineTo(sx(8), sy(10)),
    LineTo(sx(2), sy(10)),
    ClosePath,
  ]
  { commands, width, height }
}
