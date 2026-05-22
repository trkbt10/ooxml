// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `nonIsoscelesTrapezoid`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `nonIsoscelesTrapezoid` — a trapezoid with a full-width
/// base whose top edge is inset by *different* amounts on the left
/// and right, so the two slanted sides are unequal.
///
/// Spec geometry (`ss = min(w, h)`): `maxAdj = 50000·w/ss`,
/// `a1 = pin(0, adj1, maxAdj)` and `a2 = pin(0, adj2, maxAdj)` with
/// `adj1 = adj2 = 25000` by default. The top edge runs from
/// `x2 = ss·a1/100000` to `x3 = r − ss·a2/100000`. The path is
/// `moveTo (l, b)` → `lnTo (x2, t)` → `lnTo (x3, t)` →
/// `lnTo (r, b)` → `close`, a closed quadrilateral.
pub fn build_non_isosceles_trapezoid(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  fn pin(lo : Int, v : Int, hi : Int) -> Int {
    if v < lo {
      lo
    } else if v > hi {
      hi
    } else {
      v
    }
  }

  let ss = min_dim(width, height)
  // maxAdj = 50000 * w / ss.
  let max_adj = fraction(50000, width, ss)
  // adj1 = adj2 = 25000 default; pinned into [0, maxAdj].
  let a1 = pin(0, 25000, max_adj)
  let a2 = pin(0, 25000, max_adj)
  // x2 = ss * a1 / 100000; dx3 = ss * a2 / 100000; x3 = r - dx3.
  let x2 = fraction(ss, a1, 100000)
  let dx3 = fraction(ss, a2, 100000)
  let x3 = width - dx3
  let commands : Array[PathCommand] = [
    MoveTo(0, height),
    LineTo(x2, 0),
    LineTo(x3, 0),
    LineTo(width, height),
    ClosePath,
  ]
  { commands, width, height }
}
