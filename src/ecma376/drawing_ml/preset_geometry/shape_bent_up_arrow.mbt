// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `bentUpArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `bentUpArrow` — an arrow with a right-angle bend: a
/// horizontal shaft running from the bottom-left turns 90° upward at
/// the right and ends in an arrowhead pointing up.
///
/// Per the spec gdLst (all `ss`-based, defaults 25000): `a1` = shaft
/// thickness (`dy2 = ss·a1/100000` horizontal, `dx2 = ss·a1/200000`
/// vertical half-thickness), `a2` = arrowhead width (`dx1 = ss·a2/50000`
/// barb spread, tip `x3 = r − ss·a2/100000`), `a3` = arrowhead height
/// (`y1 = ss·a3/100000`). The spec outline is
/// `(l,y2)→(x2,y2)→(x2,y1)→(x1,y1)→(x3,t)→(r,y1)→(x4,y1)→(x4,b)→(l,b)`
/// with `x2 = x3 − dx2`, `x4 = x3 + dx2`, `x1 = r − dx1`.
pub fn build_bent_up_arrow(
  width : Int,
  height : Int,
  adj1? : Int = 25000,
  adj2? : Int = 25000,
  adj3? : Int = 25000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let a1 = pin_int(adj1, 0, 50000)
  let a2 = pin_int(adj2, 0, 50000)
  let a3 = pin_int(adj3, 0, 50000)
  let y1 = fraction(ss, a3, 100000)
  let x1 = width - fraction(ss, a2, 50000)
  let x3 = width - fraction(ss, a2, 100000)
  let dx2 = fraction(ss, a1, 200000)
  let x2 = x3 - dx2
  let x4 = x3 + dx2
  let y2 = height - fraction(ss, a1, 100000)
  let commands : Array[PathCommand] = [
    MoveTo(0, y2),
    LineTo(x2, y2),
    LineTo(x2, y1),
    LineTo(x1, y1),
    LineTo(x3, 0),
    LineTo(width, y1),
    LineTo(x4, y1),
    LineTo(x4, height),
    LineTo(0, height),
    ClosePath,
  ]
  { commands, width, height }
}
