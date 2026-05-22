// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartPunchedTape`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartPunchedTape` — a rectangle whose top edge is
/// a concave-then-convex wave and whose bottom edge mirrors it,
/// denoting punched tape in a flow chart.
///
/// Spec path (20×20 frame): moveTo (0,2) → top-left arc (wR=5,hR=2)
/// dipping down to (10,2) → top-right arc humping up to (20,2) →
/// lnTo (20,18) → bottom-right arc dipping up to (10,18) →
/// bottom-left arc humping down to (0,18) → close. Each arc is a
/// 180° half-ellipse; sweep alternates concave/convex in the y-down
/// SVG frame.
pub fn build_flow_chart_punched_tape(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 20)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 20)
  }

  // Wave radii: rx is 1/4 of the width, ry is 1/10 of the height.
  let rx = fraction(width, 5, 20)
  let ry = fraction(height, 2, 20)
  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(2)),
    // Top-left: concave dip downward.
    ArcTo(rx, ry, 0, false, true, sx(10), sy(2)),
    // Top-right: convex hump upward.
    ArcTo(rx, ry, 0, false, false, sx(20), sy(2)),
    LineTo(sx(20), sy(18)),
    // Bottom-right: concave dip upward.
    ArcTo(rx, ry, 0, false, false, sx(10), sy(18)),
    // Bottom-left: convex hump downward.
    ArcTo(rx, ry, 0, false, true, sx(0), sy(18)),
    ClosePath,
  ]
  { commands, width, height }
}
