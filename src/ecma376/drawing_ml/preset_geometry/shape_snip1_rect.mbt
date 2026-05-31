// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `snip1Rect`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `snip1Rect` — rectangle whose top-right corner alone
/// is snipped off by a straight diagonal cut; the other three corners
/// stay square.
///
/// Spec path: the snip size derives from the single `adj` guide
/// (default 16667, clamped by `pin 0 adj 50000`): `dx1 =
/// ss·a/100000`. The path runs `(l,t) → (x1,t) → (r,dx1) → (r,b) →
/// (l,b) → close`, with `x1 = r − dx1`; the segment `(x1,t) →
/// (r,dx1)` is the diagonal that cuts the corner.
pub fn build_snip1_rect(
  width : Int,
  height : Int,
  adj? : Int = 16667,
) -> ShapeGeometry {
  // §20.1.10.56 snip1Rect gdLst: a = pin 0 adj 50000; dx1 = ss·a/100000.
  let s = percent(min_dim(width, height), pin_int(adj, 0, 50000))
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, 0))
  commands.push(LineTo(width - s, 0))
  // Diagonal cut across the top-right corner.
  commands.push(LineTo(width, s))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}
