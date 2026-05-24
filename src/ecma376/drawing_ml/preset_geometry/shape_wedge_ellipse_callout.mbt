// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `wedgeEllipseCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `wedgeEllipseCallout` — an elliptical speech bubble
/// with a triangular pointer ("wedge") tail.
///
/// Spec geometry: the tail tip sits at `(xPos, yPos)` with
/// `xPos = hc + w·adj1/100000` and `yPos = vc + h·adj2/100000`
/// (default `adj1 = -20833`, `adj2 = 62500`). The spec finds the
/// angle `pang` from the centre to the tip, places the wedge base
/// at the two ellipse-perimeter points `pang ± 6°`
/// (`660000 / 60000`), then sweeps the rest of the ellipse with an
/// `arcTo`. The path is `moveTo(tip) → lnTo(base1) → arc → close`.
///
/// The implementation reproduces this: the two base points are taken
/// 6° either side of the centre→tip direction, the bubble outline is
/// drawn as two `ArcTo` half-sweeps so the SVG `large_arc` flag stays
/// false, and the wedge is two straight legs to the tip.
pub fn build_wedge_ellipse_callout(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  // Tail tip from the default avLst adjustments.
  let tip_x = cx + percent(width, -20833)
  let tip_y = cy + percent(height, 62500)
  // Direction centre→tip, quantised to whole degrees for the integer
  // sine/cosine tables. The spec uses dxPos·h / dyPos·w to keep the
  // angle in the ellipse's own metric; the same scaling is applied
  // here before the atan lookup.
  let ang = atan2_degrees(percent(height, 62500), percent(width, -20833))
  // Wedge base half-spread: 6° either side of the tip direction.
  let a1 = ang - 6
  let a2 = ang + 6
  let bx1 = cx + fraction(rx, cos10000(a1), 10000)
  let by1 = cy + fraction(ry, sin10000(a1), 10000)
  let bx2 = cx + fraction(rx, cos10000(a2), 10000)
  let by2 = cy + fraction(ry, sin10000(a2), 10000)
  // Point on the perimeter diametrically opposite the wedge base,
  // used as the midpoint so each ArcTo half stays ≤ 180°.
  let amid = ang + 180
  let mx = cx + fraction(rx, cos10000(amid), 10000)
  let my = cy + fraction(ry, sin10000(amid), 10000)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(tip_x, tip_y))
  // Leg down to the first base point.
  commands.push(LineTo(bx1, by1))
  // Sweep the ellipse the long way round in two ≤180° arcs.
  commands.push(ArcTo(rx, ry, 0, false, false, mx, my))
  commands.push(ArcTo(rx, ry, 0, false, false, bx2, by2))
  // Leg back up to the tip.
  commands.push(LineTo(tip_x, tip_y))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Integer four-quadrant arc-tangent returning whole degrees in
/// `[0, 360)`, measured clockwise from the positive x-axis in the
/// SVG screen frame (y grows downward). Used by
/// `build_wedge_ellipse_callout` to aim the wedge at the tail tip
/// without pulling in floating-point math. The result is found by a
/// coarse scan of the shared `sin10000` / `cos10000` tables — one
/// degree of resolution is ample for placing a wedge base.
fn atan2_degrees(dy : Int, dx : Int) -> Int {
  if dx == 0 && dy == 0 {
    return 0
  }
  let mut best = 0
  let mut best_err : Int64 = -1L
  // Scan whole degrees, ranking by the cross-product residual.
  for deg in 0..<360 {
    let c = cos10000(deg)
    let s = sin10000(deg)
    // Squared distance between the unit vector at `deg` and the
    // normalised direction is monotone in the angular error; compare
    // via the cross/dot residual instead to avoid a sqrt.
    let cross = (s.to_int64() * dx.to_int64() - c.to_int64() * dy.to_int64()).abs()
    let dot = c.to_int64() * dx.to_int64() + s.to_int64() * dy.to_int64()
    if dot >= 0L {
      let err = cross
      if best_err < 0L || err < best_err {
        best_err = err
        best = deg
      }
    }
  }
  best
}
