// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `flowChartSummingJunction`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `flowChartSummingJunction` — a circle crossed by an X
/// (the two diagonals), denoting a summing junction in a flow chart.
///
/// Spec path: the body is the bounding-box ellipse, built from the
/// four quarter `arcTo` commands in the preset definition and drawn
/// here as two 180° SVG arcs from the left-middle point. The X is
/// drawn between the four inset points where the circle meets the
/// 45° diagonals: `idx = cos(45°)·wd2`, `idy = sin(45°)·hd2`, with
/// `il = hc-idx`, `ir = hc+idx`, `it = vc-idy`, `ib = vc+idy`.
/// cos(45°) = sin(45°) ≈ 0.70711 (expressed as 70711/100000).
pub fn build_flow_chart_summing_junction(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let rx = width / 2
  let ry = height / 2
  let cx = width / 2
  let cy = height / 2
  // Inset offsets along the 45° diagonals (cos45° = sin45° ≈ 0.70711).
  let idx = fraction(rx, 70711, 100000)
  let idy = fraction(ry, 70711, 100000)
  let il = cx - idx
  let ir = cx + idx
  let it = cy - idy
  let ib = cy + idy
  let commands : Array[PathCommand] = [
    // Ellipse body — left-middle, round the bottom, round the top.
    MoveTo(0, cy),
    ArcTo(rx, ry, 0, false, true, width, cy),
    ArcTo(rx, ry, 0, false, true, 0, cy),
    ClosePath,
    // Stroke-only diagonal: top-left to bottom-right.
    MoveTo(il, it),
    LineTo(ir, ib),
    // Stroke-only diagonal: top-right to bottom-left.
    MoveTo(ir, it),
    LineTo(il, ib),
  ]
  { commands, width, height }
}
