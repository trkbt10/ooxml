// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `accentBorderCallout1`.
//
// One preset shape per file. Dispatched from `build_geometry` and
// reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `accentBorderCallout1` — a full-bounding-box rectangle
/// body (the `border` family strokes the body outline), a vertical
/// accent bar at the body edge, and a single-segment leader line.
///
/// The path geometry is identical to `accentCallout1`: the `border`
/// vs. non-border distinction is purely a render-time stroke attribute
/// on the body subpath, not a difference in path commands.
///
/// Spec guides (percent-of-side `avLst` defaults): `adj1 = 18750`,
/// `adj2 = -8333`, `adj3 = 112500`, `adj4 = -38333`. The accent bar
/// spans `(x1,t)`..`(x1,b)` with `x1 = w*adj2`; the leader runs from
/// `(x1,y1)` to the target `(x2,y2) = (w*adj4, h*adj3)`.
pub fn build_accent_border_callout1(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let body = build_rect(width, height)
  let commands : Array[PathCommand] = []
  for cmd in body.commands {
    commands.push(cmd)
  }
  let x1 = percent(width, -8333)
  let y1 = percent(height, 18750)
  let x2 = percent(width, -38333)
  let y2 = percent(height, 112500)
  // Accent bar: vertical segment at x1 spanning the body height.
  commands.push(MoveTo(x1, 0))
  commands.push(LineTo(x1, height))
  // Leader line.
  commands.push(MoveTo(x1, y1))
  commands.push(LineTo(x2, y2))
  { commands, width, height }
}
