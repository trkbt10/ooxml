// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftRightUpArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `leftRightUpArrow` — a three-headed arrow with heads
/// pointing left, right and up, all joined at a common shaft junction.
///
/// Per the spec gdLst (all `ss`-based, defaults 25000): `a2` =
/// arrowhead length (`x1 = ss·a3/100000`; horizontal head half-width
/// `dx2 = ss·a2/100000`; vertical barb spread `dy2 = ss·a2/50000`),
/// `a1` = shaft thickness (`dx3 = ss·a1/200000`). With `x2/x5 = hc ∓
/// dx2`, `x3/x4 = hc ∓ dx3`, `x6 = r − x1`, `y4 = b − dx2`, `y2 = b −
/// dy2`, `y3/y5 = y4 ∓ dx3`, the spec outline is
/// `(l,y4)→(x1,y2)→(x1,y3)→(x3,y3)→(x3,x1)→(x2,x1)→(hc,t)→(x5,x1)→
/// (x4,x1)→(x4,y3)→(x6,y3)→(x6,y2)→(r,y4)→(x6,b)→(x6,y5)→(x1,y5)→
/// (x1,b)` — `x1` doubles as the up-arrowhead base Y.
pub fn build_left_right_up_arrow(
  width : Int,
  height : Int,
  adj1~ : Int = 25000,
  adj2~ : Int = 25000,
  adj3~ : Int = 25000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let a2 = pin_int(adj2, 0, 50000)
  let a1 = pin_int(adj1, 0, 2 * a2)
  let a3 = pin_int(adj3, 0, (100000 - 2 * a2) / 2)
  let hc = width / 2
  let x1 = fraction(ss, a3, 100000)
  let dx2 = fraction(ss, a2, 100000)
  let x2 = hc - dx2
  let x5 = hc + dx2
  let dx3 = fraction(ss, a1, 200000)
  let x3 = hc - dx3
  let x4 = hc + dx3
  let x6 = width - x1
  let dy2 = fraction(ss, a2, 50000)
  let y2 = height - dy2
  let y4 = height - dx2
  let y3 = y4 - dx3
  let y5 = y4 + dx3
  let commands : Array[PathCommand] = [
    MoveTo(0, y4),
    LineTo(x1, y2),
    LineTo(x1, y3),
    LineTo(x3, y3),
    LineTo(x3, x1),
    LineTo(x2, x1),
    LineTo(hc, 0),
    LineTo(x5, x1),
    LineTo(x4, x1),
    LineTo(x4, y3),
    LineTo(x6, y3),
    LineTo(x6, y2),
    LineTo(width, y4),
    LineTo(x6, height),
    LineTo(x6, y5),
    LineTo(x1, y5),
    LineTo(x1, height),
    ClosePath,
  ]
  { commands, width, height }
}
