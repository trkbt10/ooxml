// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartOr`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartOr` — a circle crossed by a vertical and a
/// horizontal diameter (a plus inside a circle), denoting a logical
/// OR in a flow chart.
///
/// Spec path: the body is the bounding-box ellipse, built from the
/// four quarter `arcTo` commands in the preset definition. The
/// circle is drawn here as two 180° SVG arcs from the left-middle
/// point. The stroke-only sub-paths add the vertical diameter
/// (hc,t)→(hc,b) and the horizontal diameter (l,vc)→(r,vc).
pub fn build_flow_chart_or(width : Int, height : Int) -> ShapeGeometry {
  let rx = width / 2
  let ry = height / 2
  let cx = width / 2
  let cy = height / 2
  let commands : Array[PathCommand] = [
    // Ellipse body — left-middle, round the bottom, round the top.
    MoveTo(0, cy),
    ArcTo(rx, ry, 0, false, true, width, cy),
    ArcTo(rx, ry, 0, false, true, 0, cy),
    ClosePath,
    // Stroke-only vertical diameter.
    MoveTo(cx, 0),
    LineTo(cx, height),
    // Stroke-only horizontal diameter.
    MoveTo(0, cy),
    LineTo(width, cy),
  ]
  { commands, width, height }
}
