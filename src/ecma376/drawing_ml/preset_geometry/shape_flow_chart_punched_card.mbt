// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartPunchedCard`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartPunchedCard` — a rectangle with the
/// top-left corner clipped off, denoting a punched card in a flow
/// chart.
///
/// Spec path (5×5 frame): vertices at (0,1) (1,0) (5,0) (5,5) (0,5).
pub fn build_flow_chart_punched_card(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 5)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 5)
  }

  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(1)),
    LineTo(sx(1), sy(0)),
    LineTo(sx(5), sy(0)),
    LineTo(sx(5), sy(5)),
    LineTo(sx(0), sy(5)),
    ClosePath,
  ]
  { commands, width, height }
}
