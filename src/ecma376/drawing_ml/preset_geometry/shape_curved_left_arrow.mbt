// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedLeftArrow`.

///|
/// §20.1.10.56 `curvedLeftArrow` — a block arrow whose shaft curves
/// along an arc and whose head points to the left. It is the
/// horizontal mirror of `curvedRightArrow`.
///
/// The spec path builds the shaft from two concentric `arcTo` edges
/// and the arrowhead from straight `lnTo` edges. The curve is the
/// left half of an ellipse centred on the right edge.
///
/// Defaults from the spec `avLst`: `adj1 = 25000` (shaft thickness
/// `th`), `adj2 = 50000` (arrow head width `aw`), `adj3 = 25000`
/// (head length `ah`).
///
/// This generator renders a faithful silhouette: the curved shaft is
/// the left half of an ellipse band whose centre is on the right
/// edge; the arrowhead is a triangle at the bottom-left whose tip
/// points left along the box's lower edge.
pub fn build_curved_left_arrow(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let th = percent(ss, 25000)
  let aw = percent(ss, 50000)
  let ah = percent(ss, 25000)
  // Ellipse centred on the right edge at the vertical centre; the
  // shaft sweeps over the left half of that ellipse.
  let cx = width
  let cy = height / 2
  let outer_rx = width
  let outer_ry = height / 2
  let inner_rx = width - th
  let inner_ry = height / 2
  // The arrowhead tip sits on the left edge; the band terminates at
  // `band_x` so the head flares beyond it to the left.
  let band_x = ah
  let commands : Array[PathCommand] = []
  // Outer rim: top edge sweeping the outer arc down to the band
  // terminus near the bottom-left.
  commands.push(MoveTo(cx, cy - outer_ry))
  commands.push(ArcTo(outer_rx, outer_ry, 0, false, false, band_x, cy + aw / 2))
  // Arrowhead: outer flare → tip → inner flare.
  commands.push(LineTo(band_x, cy + aw))
  commands.push(LineTo(0, cy + aw / 2))
  commands.push(LineTo(band_x, cy - aw / 2))
  commands.push(LineTo(band_x, cy - aw / 2 + th))
  // Inner rim: sweep back up the inner arc to the top.
  commands.push(ArcTo(inner_rx, inner_ry, 0, false, true, cx, cy - inner_ry))
  commands.push(ClosePath)
  { commands, width, height }
}
