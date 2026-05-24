// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `funnel`.

///|
/// §20.1.10.56 `funnel` — a funnel: a wide ellipse rim at the top that
/// tapers down to a narrow vertical tube at the bottom.
///
/// The spec describes the silhouette with two sub-paths: the funnel
/// body (rim ellipse → tapered side walls → narrow spout ellipse) and
/// the elliptical rim opening drawn on top. The spec geometry depends
/// on the `<gd>` guide `d = ss/20` (the rim wall thickness) and a
/// computed taper angle.
///
/// This generator renders a faithful silhouette: the rim is an ellipse
/// of full width occupying the top quarter of the box; the tube has
/// width `2*rw3` (a quarter of the box width) and its mouth ellipse
/// sits near the bottom. The taper walls are straight `LineTo` edges
/// joining the rim's widest point to the tube mouth — a recognisable
/// funnel outline. The rim opening is emitted as a second closed
/// sub-path (an ellipse) so renderers can show the hollow throat.
pub fn build_funnel(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  // Rim: a full-width ellipse whose vertical radius is one eighth of
  // the height (so the rim band occupies the top quarter of the box).
  let rim_rx = width / 2
  let rim_ry = height / 8
  let rim_cy = rim_ry
  // Spout: a narrow ellipse, a quarter of the box width, near the
  // bottom edge. `tube_ry` mirrors the rim's flattening ratio.
  let tube_rx = width / 8
  let tube_ry = height / 16
  let tube_cy = height - tube_ry
  let commands : Array[PathCommand] = []
  // Funnel body: start at the rim's left extreme, sweep the lower half
  // of the rim ellipse across to the right extreme, taper down the
  // right wall to the spout, sweep the lower half of the spout
  // ellipse back, then taper up the left wall.
  commands.push(MoveTo(cx - rim_rx, rim_cy))
  commands.push(ArcTo(rim_rx, rim_ry, 0, false, true, cx + rim_rx, rim_cy))
  commands.push(LineTo(cx + tube_rx, tube_cy))
  commands.push(ArcTo(tube_rx, tube_ry, 0, false, true, cx - tube_rx, tube_cy))
  commands.push(LineTo(cx - rim_rx, rim_cy))
  commands.push(ClosePath)
  // Rim opening: the elliptical mouth of the funnel, a full ellipse
  // drawn as two half-arcs so renderers can fill it as the throat.
  commands.push(MoveTo(cx - rim_rx, rim_cy))
  commands.push(ArcTo(rim_rx, rim_ry, 0, false, true, cx + rim_rx, rim_cy))
  commands.push(ArcTo(rim_rx, rim_ry, 0, false, true, cx - rim_rx, rim_cy))
  commands.push(ClosePath)
  { commands, width, height }
}
