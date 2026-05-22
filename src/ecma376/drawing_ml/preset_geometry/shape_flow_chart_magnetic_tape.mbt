// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartMagneticTape`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartMagneticTape` — a circle with a short
/// straight "foot" extending out of its lower-right side, denoting a
/// magnetic tape in a flow chart.
///
/// Spec path: the body sweeps 270° around the bounding-box ellipse
/// from the bottom point (hc,b) anticlockwise through the left and
/// top to the right point (r,vc), then a partial arc of `ang1 =
/// atan2(w,h)`, then lnTo (r,ib) and lnTo (r,b) forming the foot.
///
/// Approximation: the trailing partial `arcTo` of `ang1` (whose
/// sweep depends on the box aspect ratio) is replaced by a short
/// convex arc from (r,vc) straight down the right edge to (r,ib),
/// followed by the straight foot edges to (r,b) and back to (hc,b).
/// The silhouette — a circle with a small rectangular foot in the
/// lower-right — is preserved; only the precise foot-junction curve
/// is simplified. `ib = vc + sin(45°)·hd2`.
pub fn build_flow_chart_magnetic_tape(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  // ib: inset point where the circle meets the 45° diagonal below
  // centre (sin45° ≈ 0.70711, expressed as 70711/100000).
  let ib = cy + fraction(ry, 70711, 100000)
  let commands : Array[PathCommand] = [
    // 270° arc: bottom → left → top → right (anticlockwise).
    MoveTo(cx, height),
    ArcTo(rx, ry, 0, true, false, width, cy),
    // Short arc continuing down the right edge to the foot junction.
    ArcTo(rx, ry, 0, false, false, width, ib),
    // Straight foot.
    LineTo(width, height),
    ClosePath,
  ]
  { commands, width, height }
}
