// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `round2SameRect`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `round2SameRect` — rectangle with the two top corners
/// rounded by `adj1` and the two bottom corners rounded by `adj2`.
///
/// Spec path: `tx1 = ss·a1/100000` is the top radius, `bx1 =
/// ss·a2/100000` the bottom radius (defaults `adj1 = 16667`, `adj2 =
/// 0`, each clamped by `pin 0 adj 50000`). The clockwise path is
/// `(tx1,t) → (tx2,t) → arc(top-right) → (r,by1) → arc(bottom-right)
/// → (bx1,b) → arc(bottom-left) → (l,tx1) → arc(top-left) → close`.
pub fn build_round2_same_rect(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let tr = percent(ss, 16667)
  let br = percent(ss, 0)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(tr, 0))
  commands.push(LineTo(width - tr, 0))
  commands.push(ArcTo(tr, tr, 0, false, true, width, tr))
  commands.push(LineTo(width, height - br))
  commands.push(ArcTo(br, br, 0, false, true, width - br, height))
  commands.push(LineTo(br, height))
  commands.push(ArcTo(br, br, 0, false, true, 0, height - br))
  commands.push(LineTo(0, tr))
  commands.push(ArcTo(tr, tr, 0, false, true, tr, 0))
  commands.push(ClosePath)
  { commands, width, height }
}
