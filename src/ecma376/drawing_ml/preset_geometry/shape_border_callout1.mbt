// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `borderCallout1`.
//
// One preset shape per file. Dispatched from `build_geometry` and
// reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `borderCallout1` — a full-bounding-box rectangle body
/// (the `border` family strokes the body outline) plus a single-segment
/// leader line running from the body edge to the callout target.
///
/// Spec guides (percent-of-side `avLst` defaults): `adj1 = 18750`,
/// `adj2 = -8333`, `adj3 = 112500`, `adj4 = -38333`. The leader runs
/// from `(x1,y1) = (w*adj2, h*adj1)` — a point on the left body edge —
/// to `(x2,y2) = (w*adj4, h*adj3)`, the target outside the box.
///
/// The leader is a `fill="none"` open polyline: emitted as `MoveTo`
/// followed by `LineTo` with no `ClosePath`.
pub fn build_border_callout1(width : Int, height : Int) -> ShapeGeometry {
  let body = build_rect(width, height)
  let commands : Array[PathCommand] = []
  for cmd in body.commands {
    commands.push(cmd)
  }
  let x1 = percent(width, -8333)
  let y1 = percent(height, 18750)
  let x2 = percent(width, -38333)
  let y2 = percent(height, 112500)
  commands.push(MoveTo(x1, y1))
  commands.push(LineTo(x2, y2))
  { commands, width, height }
}
