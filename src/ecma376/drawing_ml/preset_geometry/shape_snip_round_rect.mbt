// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `snipRoundRect`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `snipRoundRect` — rectangle with the top-left corner
/// rounded by `adj1` and the top-right corner snipped by `adj2`; the
/// two bottom corners stay square.
///
/// Spec path: `x1 = ss·a1/100000` is the rounded-corner radius,
/// `dx2 = ss·a2/100000` the snip size (both default 16667). The
/// clockwise outline is `(x1,t) → (x2,t) → (r,dx2) → (r,b) → (l,b)
/// → (l,x1) → arc(top-left) → close`, where `x2 = r − dx2`; the
/// `(x2,t) → (r,dx2)` segment is the diagonal snip and the closing
/// `ArcTo` rounds the top-left corner.
pub fn build_snip_round_rect(
  width : Int,
  height : Int,
  adj1? : Int = 16667,
  adj2? : Int = 16667,
) -> ShapeGeometry {
  // §20.1.10.56 snipRoundRect gdLst: aN = pin 0 adjN 50000;
  // x1 = ss·a1/100000 (rounded top-left), dx2 = ss·a2/100000 (snip top-right).
  let ss = min_dim(width, height)
  let r = percent(ss, pin_int(adj1, 0, 50000))
  let s = percent(ss, pin_int(adj2, 0, 50000))
  let commands : Array[PathCommand] = []
  // Start just past the rounded top-left corner.
  commands.push(MoveTo(r, 0))
  commands.push(LineTo(width - s, 0))
  // Diagonal snip across the top-right corner.
  commands.push(LineTo(width, s))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(LineTo(0, r))
  // Rounded top-left corner: quarter arc back to the start point.
  commands.push(ArcTo(r, r, 0, false, true, r, 0))
  commands.push(ClosePath)
  { commands, width, height }
}
