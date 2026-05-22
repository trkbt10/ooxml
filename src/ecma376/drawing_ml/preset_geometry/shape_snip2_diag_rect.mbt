// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `snip2DiagRect`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `snip2DiagRect` — rectangle with two diagonally
/// opposite corners snipped: the top-left and bottom-right corner
/// share the `adj1` snip size, the top-right and bottom-left corner
/// share the `adj2` snip size.
///
/// Spec path: `lx1 = ss·a1/100000` is the top-left / bottom-right
/// snip, `rx1 = ss·a2/100000` the top-right / bottom-left snip
/// (defaults `adj1 = 0`, `adj2 = 16667`). The clockwise outline is
/// `(lx1,t) → (rx2,t) → (r,rx1) → (r,ly1) → (lx2,b) → (rx1,b) →
/// (l,ry1) → (l,lx1) → close`.
pub fn build_snip2_diag_rect(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  // adj1 snip (top-left, bottom-right); adj2 snip (top-right,
  // bottom-left).
  let s1 = percent(ss, 0)
  let s2 = percent(ss, 16667)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(s1, 0))
  commands.push(LineTo(width - s2, 0))
  commands.push(LineTo(width, s2))
  commands.push(LineTo(width, height - s1))
  commands.push(LineTo(width - s1, height))
  commands.push(LineTo(s2, height))
  commands.push(LineTo(0, height - s2))
  commands.push(LineTo(0, s1))
  commands.push(ClosePath)
  { commands, width, height }
}
