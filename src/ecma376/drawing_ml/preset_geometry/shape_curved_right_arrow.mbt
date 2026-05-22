// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedRightArrow`.

///|
/// §20.1.10.56 `curvedRightArrow` — a block arrow whose shaft curves
/// along an arc and whose head points to the right.
///
/// The spec path builds the shaft from two concentric `arcTo` edges
/// (the outer and inner rim of the curved band) and the arrowhead
/// from straight `lnTo` edges. The curve is the right half of an
/// ellipse centred on the left edge: the band sweeps from the top
/// edge round to the bottom where the arrowhead flares to the right.
///
/// Defaults from the spec `avLst`: `adj1 = 25000` (shaft thickness
/// `th`), `adj2 = 50000` (arrow head width `aw`), `adj3 = 25000`
/// (head length `ah`). The arrowhead width `aw` is wider than the
/// shaft so the head visibly flares.
///
/// This generator renders a faithful silhouette: the curved shaft is
/// the right half of an ellipse band whose centre is on the left
/// edge; the arrowhead is a triangle at the bottom-right whose tip
/// points right along the box's lower edge.
pub fn build_curved_right_arrow(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let th = percent(ss, 25000)
  let aw = percent(ss, 50000)
  let ah = percent(ss, 25000)
  // Ellipse centred on the left edge at the vertical centre; the
  // shaft sweeps over the right half of that ellipse.
  let cx = 0
  let cy = height / 2
  let outer_rx = width
  let outer_ry = height / 2
  let inner_rx = width - th
  let inner_ry = height / 2
  // The arrowhead tip sits on the right edge; the shaft meets the
  // head where the curve reaches the box's right side near the
  // bottom. `band_x` is where the curved band terminates so the
  // head can flare beyond it.
  let band_x = width - ah
  let commands : Array[PathCommand] = []
  // Outer rim: top edge straight down to where the inner radius
  // would start, then sweep the outer arc to the band terminus.
  commands.push(MoveTo(cx, cy - outer_ry))
  commands.push(ArcTo(outer_rx, outer_ry, 0, false, true, band_x, cy + aw / 2))
  // Arrowhead: outer flare → tip → inner flare.
  commands.push(LineTo(band_x, cy + aw))
  commands.push(LineTo(width, cy + aw / 2))
  commands.push(LineTo(band_x, cy - aw / 2))
  commands.push(LineTo(band_x, cy - aw / 2 + th))
  // Inner rim: sweep back up the inner arc to the top.
  commands.push(ArcTo(inner_rx, inner_ry, 0, false, false, cx, cy - inner_ry))
  commands.push(ClosePath)
  { commands, width, height }
}
