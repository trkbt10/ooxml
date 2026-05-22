// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `snip2SameRect`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `snip2SameRect` — rectangle with the two top corners
/// snipped by `adj1` and the two bottom corners snipped by `adj2`.
///
/// Spec path: `tx1 = ss·a1/100000` is the top snip size, `bx1 =
/// ss·a2/100000` the bottom snip size (defaults `adj1 = 16667`,
/// `adj2 = 0`). The clockwise outline is `(tx1,t) → (tx2,t) →
/// (r,tx1) → (r,by1) → (bx2,b) → (bx1,b) → (l,by1) → (l,tx1) →
/// close`, where each snipped corner becomes a single diagonal cut.
pub fn build_snip2_same_rect(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let ts = percent(ss, 16667)
  let bs = percent(ss, 0)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(ts, 0))
  commands.push(LineTo(width - ts, 0))
  commands.push(LineTo(width, ts))
  commands.push(LineTo(width, height - bs))
  commands.push(LineTo(width - bs, height))
  commands.push(LineTo(bs, height))
  commands.push(LineTo(0, height - bs))
  commands.push(LineTo(0, ts))
  commands.push(ClosePath)
  { commands, width, height }
}
