// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartDocument`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartDocument` — a rectangle whose bottom edge is
/// a wavy curve, denoting a document in a flow chart.
///
/// Spec path (21600×21600 frame): top-left → top-right → down to
/// y=17322, then a cubic Bézier wave back to the left edge at
/// y=20172 (control points at 10800,17322 and 10800,23922).
pub fn build_flow_chart_document(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  // Scale the 21600-unit spec coordinates into the pixel frame.
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(0)),
    LineTo(sx(21600), sy(0)),
    LineTo(sx(21600), sy(17322)),
    CurveTo(
      sx(10800),
      sy(17322),
      sx(10800),
      sy(23922),
      sx(0),
      sy(20172),
    ),
    ClosePath,
  ]
  { commands, width, height }
}
