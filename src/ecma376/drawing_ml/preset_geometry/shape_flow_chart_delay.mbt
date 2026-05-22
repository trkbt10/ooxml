// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartDelay`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartDelay` — a rectangle whose right edge is a
/// convex half-ellipse (a "D" lying flat), denoting a delay in a
/// flow chart.
///
/// Spec path: moveTo (l,t) → lnTo (hc,t) → arcTo (wR=wd2,hR=hd2,
/// stAng=270°, swAng=180°) ending at (hc,b) → lnTo (l,b) → close.
/// The right cap is a convex 180° half-ellipse bulging rightward
/// (sweep=true in the y-down SVG frame).
pub fn build_flow_chart_delay(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let rx = width / 2
  let ry = height / 2
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(cx, 0),
    // Right cap — convex half-ellipse bulging outward.
    ArcTo(rx, ry, 0, false, true, cx, height),
    LineTo(0, height),
    ClosePath,
  ]
  { commands, width, height }
}
