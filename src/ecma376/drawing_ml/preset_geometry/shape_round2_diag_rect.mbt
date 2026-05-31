// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `round2DiagRect`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `round2DiagRect` — rectangle with two diagonally
/// opposite corners rounded: the top-left and bottom-right corner
/// share the `adj1` radius, the top-right and bottom-left corner
/// share the `adj2` radius.
///
/// Spec path: `x1 = ss·a1/100000` is the top-left / bottom-right
/// radius, `a = ss·a2/100000` the top-right / bottom-left radius
/// (defaults `adj1 = 16667`, `adj2 = 0`). The clockwise path is
/// `(x1,t) → (x2,t) → arc(top-right r=a) → (r,y1) → arc(bottom-right
/// r=x1) → (a,b) → arc(bottom-left r=a) → (l,x1) → arc(top-left
/// r=x1) → close`.
pub fn build_round2_diag_rect(
  width : Int,
  height : Int,
  adj1? : Int = 16667,
  adj2? : Int = 0,
) -> ShapeGeometry {
  // §20.1.10.56 round2DiagRect gdLst: aN = pin 0 adjN 50000; radii ss·aN/100000.
  let ss = min_dim(width, height)
  // adj1 corner radius (top-left, bottom-right).
  let r1 = percent(ss, pin_int(adj1, 0, 50000))
  // adj2 corner radius (top-right, bottom-left).
  let r2 = percent(ss, pin_int(adj2, 0, 50000))
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(r1, 0))
  commands.push(LineTo(width - r2, 0))
  commands.push(ArcTo(r2, r2, 0, false, true, width, r2))
  commands.push(LineTo(width, height - r1))
  commands.push(ArcTo(r1, r1, 0, false, true, width - r1, height))
  commands.push(LineTo(r2, height))
  commands.push(ArcTo(r2, r2, 0, false, true, 0, height - r2))
  commands.push(LineTo(0, r1))
  commands.push(ArcTo(r1, r1, 0, false, true, r1, 0))
  commands.push(ClosePath)
  { commands, width, height }
}
