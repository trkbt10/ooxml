// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `borderCallout2`.
//
// One preset shape per file. Dispatched from `build_geometry` and
// reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `borderCallout2` — a full-bounding-box rectangle body
/// plus a two-segment (single-elbow) leader line.
///
/// Spec guides (percent-of-side `avLst` defaults): `adj1 = 18750`,
/// `adj2 = -8333`, `adj3 = 18750`, `adj4 = -16667`, `adj5 = 112500`,
/// `adj6 = -46667`. The leader runs through three points:
/// `(x1,y1) = (w*adj2, h*adj1)`, the elbow `(x2,y2) = (w*adj4, h*adj3)`,
/// and the target `(x3,y3) = (w*adj6, h*adj5)`.
///
/// The leader is a `fill="none"` open polyline: `MoveTo` then two
/// `LineTo`s, no `ClosePath`.
pub fn build_border_callout2(width : Int, height : Int) -> ShapeGeometry {
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
  commands.push(MoveTo(x1, y1))
  commands.push(LineTo(x2, y2))
  commands.push(LineTo(x3, y3))
  { commands, width, height }
}
