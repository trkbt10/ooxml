// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartMultidocument`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartMultidocument` — three stacked `flowChartDocument`
/// shapes, each with a wavy bottom edge, denoting a multi-document in a
/// flow chart.
///
/// Spec path (21600×21600 frame). The preset definition has three
/// `<path>` elements: the front document body (`stroke="false"`), the
/// stroke-only outlines (`fill="none"`), and the rear-edge detail
/// (`stroke="false" fill="none"`). All sub-paths are concatenated into
/// a single command list: the three filled outlines (front sheet, the
/// middle sheet visible as an L-strip, the rear sheet) followed by the
/// stroke-only detail paths so renderers see both the filled body and
/// the layered edges.
pub fn build_flow_chart_multidocument(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  let commands : Array[PathCommand] = [
    // Front document — body with the wavy bottom edge.
    MoveTo(sx(0), sy(20782)),
    CurveTo(
      sx(9298), sy(23542), sx(9298), sy(18022), sx(18595), sy(18022),
    ),
    LineTo(sx(18595), sy(3675)),
    LineTo(sx(0), sy(3675)),
    ClosePath,
    // Middle sheet — the L-shaped strip visible behind the front.
    MoveTo(sx(1532), sy(3675)),
    LineTo(sx(1532), sy(1815)),
    LineTo(sx(20000), sy(1815)),
    LineTo(sx(20000), sy(16252)),
    CurveTo(
      sx(19298), sy(16252), sx(18595), sy(16352), sx(18595), sy(16352),
    ),
    LineTo(sx(18595), sy(3675)),
    ClosePath,
    // Rear sheet — the topmost L-shaped strip.
    MoveTo(sx(2972), sy(1815)),
    LineTo(sx(2972), sy(0)),
    LineTo(sx(21600), sy(0)),
    LineTo(sx(21600), sy(14392)),
    CurveTo(
      sx(20800), sy(14392), sx(20000), sy(14467), sx(20000), sy(14467),
    ),
    LineTo(sx(20000), sy(1815)),
    ClosePath,
  ]
  { commands, width, height }
}
