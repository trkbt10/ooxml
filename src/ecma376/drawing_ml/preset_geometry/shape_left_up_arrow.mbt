// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftUpArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `leftUpArrow` — a two-headed arrow with heads pointing
/// left and up, joined at a square L-junction at the bottom-right.
///
/// Per the spec gdLst (all `ss`-based, defaults 25000): `a2` =
/// arrowhead length (`x1 = ss·a3/100000`, barb spread `dx2 =
/// ss·a2/50000`, head half-width `dx4 = ss·a2/100000`), `a1` = shaft
/// thickness (`dx3 = ss·a1/200000`). The spec outline (with `x4 = r −
/// dx4`, `y4 = b − dx4`, `x3/x5 = x4 ∓ dx3`, `y3/y5 = y4 ∓ dx3`,
/// `x2 = r − dx2`, `y2 = b − dx2`) is
/// `(l,y4)→(x1,y2)→(x1,y3)→(x3,y3)→(x3,x1)→(x2,x1)→(x4,t)→(r,x1)→
/// (x5,x1)→(x5,y5)→(x1,y5)→(x1,b)` — note `x1` doubles as a Y value.
pub fn build_left_up_arrow(
  width : Int,
  height : Int,
  adj1? : Int = 25000,
  adj2? : Int = 25000,
  adj3? : Int = 25000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let a2 = pin_int(adj2, 0, 50000)
  let a1 = pin_int(adj1, 0, 2 * a2)
  let a3 = pin_int(adj3, 0, 100000 - 2 * a2)
  let x1 = fraction(ss, a3, 100000)
  let dx2 = fraction(ss, a2, 50000)
  let x2 = width - dx2
  let y2 = height - dx2
  let dx4 = fraction(ss, a2, 100000)
  let x4 = width - dx4
  let y4 = height - dx4
  let dx3 = fraction(ss, a1, 200000)
  let x3 = x4 - dx3
  let x5 = x4 + dx3
  let y3 = y4 - dx3
  let y5 = y4 + dx3
  let commands : Array[PathCommand] = [
    MoveTo(0, y4),
    LineTo(x1, y2),
    LineTo(x1, y3),
    LineTo(x3, y3),
    LineTo(x3, x1),
    LineTo(x2, x1),
    LineTo(x4, 0),
    LineTo(width, x1),
    LineTo(x5, x1),
    LineTo(x5, y5),
    LineTo(x1, y5),
    LineTo(x1, height),
    ClosePath,
  ]
  { commands, width, height }
}
