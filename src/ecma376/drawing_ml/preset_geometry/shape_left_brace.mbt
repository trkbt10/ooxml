// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftBrace`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `leftBrace` — a `{` curly brace: a vertical spine on
/// the right half of the box, two arms curling right at the top and
/// bottom, and a pinch point jutting left at mid-height.
///
/// Now a FAITHFUL transcription of the spec stroke path using the
/// independently-verified `rel_arc` (DrawingML relative `arcTo`)
/// helper. The curl radius is `y1 = ss·a1/100000` (`a1 = pin 0 adj1
/// maxAdj1`, default `adj1 = 8333`); the pinch sits at `y3 = h·a2/100000`
/// (`a2 = pin 0 adj2 100000`, default 50000), with `y4 = y3 + y1`. The
/// spec outline is `moveTo(r,b) → arc(wd2,y1,90°,+90°) → lnTo(hc,y4) →
/// arc(wd2,y1,0°,−90°) → arc(wd2,y1,90°,−90°) → lnTo(hc,y1) →
/// arc(wd2,y1,180°,+90°)`, drawn open (stroke path) so the renderer
/// strokes the `{` glyph.
pub fn build_left_brace(
  width : Int,
  height : Int,
  adj1? : Int = 8333,
  adj2? : Int = 50000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let a2 = pin_int(adj2, 0, 100000)
  let q1 = 100000 - a2
  let q2 = if q1 < a2 { q1 } else { a2 }
  let max_adj1 = if ss == 0 { 0 } else { fraction(q2 / 2, height, ss) }
  let a1 = pin_int(adj1, 0, max_adj1)
  let y1 = fraction(ss, a1, 100000)
  let y4 = fraction(height, a2, 100000) + y1
  let wd2 = width / 2
  let hc = width / 2
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(width, height))
  let (c1, _, _) = rel_arc(width, height, wd2, y1, 5400000, 5400000)
  commands.push(c1)
  commands.push(LineTo(hc, y4))
  let (c2, x2, yb) = rel_arc(hc, y4, wd2, y1, 0, -5400000)
  commands.push(c2)
  let (c3, _, _) = rel_arc(x2, yb, wd2, y1, 5400000, -5400000)
  commands.push(c3)
  commands.push(LineTo(hc, y1))
  let (c4, _, _) = rel_arc(hc, y1, wd2, y1, 10800000, 5400000)
  commands.push(c4)
  { commands, width, height }
}
