// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `round1Rect`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `round1Rect` — rectangle whose top-right corner alone
/// is rounded; the other three corners stay square.
///
/// Spec path: the corner radius derives from the single `adj` guide
/// (default 16667 ≈ 1/6 of the shorter side, after the `pin 0 adj
/// 50000` clamp): `dx1 = ss·a/100000`. The path runs
/// `(l,t) → (x1,t) → arc → (r,b) → (l,b) → close`, where `x1 = r −
/// dx1`. Going clockwise the rounded corner is rendered as a
/// quarter-circle `ArcTo` from the top edge inset point down to the
/// right edge inset point.
pub fn build_round1_rect(
  width : Int,
  height : Int,
  adj? : Int = 16667,
) -> ShapeGeometry {
  // §20.1.10.56 round1Rect gdLst: a = pin 0 adj 50000; dx1 = ss·a/100000.
  let r = percent(min_dim(width, height), pin_int(adj, 0, 50000))
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, 0))
  commands.push(LineTo(width - r, 0))
  // Top-right rounded corner: quarter arc to the right edge.
  commands.push(ArcTo(r, r, 0, false, true, width, r))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}
