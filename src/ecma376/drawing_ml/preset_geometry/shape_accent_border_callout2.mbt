// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `accentBorderCallout2`.
//
// One preset shape per file. Dispatched from `build_geometry` and
// reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `accentBorderCallout2` — a full-bounding-box rectangle
/// body, a vertical accent bar at the body edge, and a two-segment
/// (single-elbow) leader line.
///
/// The path geometry is identical to `accentCallout2`: the `border`
/// distinction is a render-time stroke attribute, not a path change.
///
/// Spec guides (percent-of-side `avLst` defaults): `adj1 = 18750`,
/// `adj2 = -8333`, `adj3 = 18750`, `adj4 = -16667`, `adj5 = 112500`,
/// `adj6 = -46667`. The accent bar spans `(x1,t)`..`(x1,b)`; the leader
/// runs through `(x1,y1)`, elbow `(x2,y2)`, and target `(x3,y3)`.
pub fn build_accent_border_callout2(width : Int, height : Int) -> ShapeGeometry {
  let body = build_rect(width, height)
  let commands : Array[PathCommand] = []
  for cmd in body.commands {
    commands.push(cmd)
  }
  let x1 = percent(width, -8333)
  let y1 = percent(height, 18750)
  let x2 = percent(width, -16667)
  let y2 = percent(height, 18750)
  let x3 = percent(width, -46667)
  let y3 = percent(height, 112500)
  // Accent bar: vertical segment at x1 spanning the body height.
  commands.push(MoveTo(x1, 0))
  commands.push(LineTo(x1, height))
  // Leader line.
  commands.push(MoveTo(x1, y1))
  commands.push(LineTo(x2, y2))
  commands.push(LineTo(x3, y3))
  { commands, width, height }
}
