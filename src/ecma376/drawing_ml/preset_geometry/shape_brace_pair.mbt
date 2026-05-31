// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `bracePair`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `bracePair` — a matched `{ }` pair framing the
/// bounding box: a left brace hugging the left edge and a right
/// brace hugging the right edge, each with a mid-height pinch
/// pointing toward the centre.
///
/// FAITHFUL transcription of the spec preset stroke `path`
/// (`fill="none"`) — two open subpaths, one per brace, matching the
/// open-stroke convention used by `leftBrace`/`rightBrace`. Every
/// guide is a 1:1 transcription of the spec `gdLst`: `a = pin 0 adj
/// 25000` (default 8333), the circular curl radius `x1 = ss·a/100000`,
/// the outer-arm inset `x2 = ss·a/50000` (= 2·x1), `x3 = r − x2`,
/// `x4 = r − x1`, `y2 = vc − x1`, `y3 = vc + x1`, `y4 = b − x1`. Each
/// brace is four circular `arcTo` edges (`wR = hR = x1`) joined by two
/// `lnTo` spine segments; the left brace's pinch tip reaches `(l, vc)`
/// and the right brace's reaches `(r, vc)`. All arcs are emitted
/// through the verified `rel_arc` helper, so the geometry is correct
/// by construction.
pub fn build_brace_pair(
  width : Int,
  height : Int,
  adj? : Int = 8333,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let cd4 = 5400000
  let cd2 = 10800000
  let c3d4 = 16200000
  let a = pin_int(adj, 0, 25000)
  let x1 = fraction(ss, a, 100000) // */ ss a 100000
  let x2 = fraction(ss, a, 50000) // */ ss a 50000 (= 2·x1)
  let vc = height / 2
  let x3 = width - x2 // +- r 0 x2
  let x4 = width - x1 // +- r 0 x1
  let y2 = vc - x1 // +- vc 0 x1
  let y3 = vc + x1 // +- vc x1 0
  let y4 = height - x1 // +- b 0 x1
  let commands : Array[PathCommand] = []
  // Left brace `{`: bottom arm → up the spine → pinch tip at (l, vc).
  commands.push(MoveTo(x2, height))
  let (c1, _, _) = rel_arc(x2, height, x1, x1, cd4, cd4)
  commands.push(c1)
  commands.push(LineTo(x1, y3))
  let (c2, e2x, e2y) = rel_arc(x1, y3, x1, x1, 0, -cd4)
  commands.push(c2)
  let (c3, _, _) = rel_arc(e2x, e2y, x1, x1, cd4, -cd4)
  commands.push(c3)
  commands.push(LineTo(x1, x1))
  let (c4, _, _) = rel_arc(x1, x1, x1, x1, cd2, cd4)
  commands.push(c4)
  // Second subpath — the right brace `}`: top arm → pinch tip at
  // (r, vc) → bottom arm.
  commands.push(MoveTo(x3, 0))
  let (c5, _, _) = rel_arc(x3, 0, x1, x1, c3d4, cd4)
  commands.push(c5)
  commands.push(LineTo(x4, y2))
  let (c6, e6x, e6y) = rel_arc(x4, y2, x1, x1, cd2, -cd4)
  commands.push(c6)
  let (c7, _, _) = rel_arc(e6x, e6y, x1, x1, c3d4, -cd4)
  commands.push(c7)
  commands.push(LineTo(x4, y4))
  let (c8, _, _) = rel_arc(x4, y4, x1, x1, 0, cd4)
  commands.push(c8)
  { commands, width, height }
}
