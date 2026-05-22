// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedUpArrow`.

///|
/// §20.1.10.56 `curvedUpArrow` — a block arrow whose shaft curves
/// along an arc and whose head points upward. It is the vertical
/// analogue of `curvedRightArrow`.
///
/// The spec path builds the shaft from two concentric `arcTo` edges
/// and the arrowhead from straight `lnTo` edges. The curve is the
/// upper half of an ellipse centred on the bottom edge.
///
/// Defaults from the spec `avLst`: `adj1 = 25000` (shaft thickness
/// `th`), `adj2 = 50000` (arrow head width `aw`), `adj3 = 25000`
/// (head length `ah`).
///
/// This generator renders a faithful silhouette: the curved shaft is
/// the upper half of an ellipse band whose centre is on the bottom
/// edge; the arrowhead is a triangle at the top-right whose tip
/// points up along the box's right edge.
pub fn build_curved_up_arrow(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let th = percent(ss, 25000)
  let aw = percent(ss, 50000)
  let ah = percent(ss, 25000)
  // Ellipse centred on the bottom edge at the horizontal centre; the
  // shaft sweeps over the upper half of that ellipse.
  let cx = width / 2
  let cy = height
  let outer_rx = width / 2
  let outer_ry = height
  let inner_rx = width / 2
  let inner_ry = height - th
  // The arrowhead tip sits on the top edge; the band terminates at
  // `band_y` so the head flares above it.
  let band_y = ah
  let commands : Array[PathCommand] = []
  // Outer rim: left edge sweeping the outer arc up to the band
  // terminus near the top-right.
  commands.push(MoveTo(cx - outer_rx, cy))
  commands.push(ArcTo(outer_rx, outer_ry, 0, false, true, cx + aw / 2, band_y))
  // Arrowhead: outer flare → tip → inner flare.
  commands.push(LineTo(cx + aw, band_y))
  commands.push(LineTo(cx + aw / 2, 0))
  commands.push(LineTo(cx - aw / 2, band_y))
  commands.push(LineTo(cx - aw / 2 + th, band_y))
  // Inner rim: sweep back down the inner arc to the left edge.
  commands.push(ArcTo(inner_rx, inner_ry, 0, false, false, cx - inner_rx, cy))
  commands.push(ClosePath)
  { commands, width, height }
}
