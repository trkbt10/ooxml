// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartOfflineStorage`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartOfflineStorage` — a downward-pointing triangle
/// crossed near its base by a short horizontal line, denoting offline
/// storage in a flow chart.
///
/// Spec path: the filled body is a downward triangle in a 2×2 frame
/// with vertices (0,0) (2,0) (1,2); the stroke-only detail line is
/// given in a separate 5×5 frame from (2,4) to (3,4).
pub fn build_flow_chart_offline_storage(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  // Triangle body scales from the 2×2 frame.
  fn tx(v : Int) -> Int {
    fraction(width, v, 2)
  }

  fn ty(v : Int) -> Int {
    fraction(height, v, 2)
  }

  // Detail line scales from the 5×5 frame.
  fn dx(v : Int) -> Int {
    fraction(width, v, 5)
  }

  fn dy(v : Int) -> Int {
    fraction(height, v, 5)
  }

  let commands : Array[PathCommand] = [
    // Triangle body.
    MoveTo(tx(0), ty(0)),
    LineTo(tx(2), ty(0)),
    LineTo(tx(1), ty(2)),
    ClosePath,
    // Stroke-only detail line near the base.
    MoveTo(dx(2), dy(4)),
    LineTo(dx(3), dy(4)),
  ]
  { commands, width, height }
}
