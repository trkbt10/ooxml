// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartSort`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartSort` — a diamond bisected by a horizontal
/// line, denoting a sort operation in a flow chart.
///
/// Spec path (2×2 frame): the filled diamond body has vertices at
/// (0,1) (1,0) (2,1) (1,2); a stroke-only sub-path draws the dividing
/// line from (0,1) to (2,1).
pub fn build_flow_chart_sort(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 2)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 2)
  }

  let commands : Array[PathCommand] = [
    // Diamond body.
    MoveTo(sx(0), sy(1)),
    LineTo(sx(1), sy(0)),
    LineTo(sx(2), sy(1)),
    LineTo(sx(1), sy(2)),
    ClosePath,
    // Stroke-only dividing line.
    MoveTo(sx(0), sy(1)),
    LineTo(sx(2), sy(1)),
  ]
  { commands, width, height }
}
