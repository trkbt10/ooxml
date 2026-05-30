// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftBracket`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `leftBracket` — a `[` shape: a vertical stem with a
/// short horizontal arm rounding off the top and the bottom.
///
/// Spec geometry: the corner radius is `y1 = ss·a/100000` with the
/// `adj` guide defaulting to 8333 (≈ 1/12 of the shorter side). The
/// spec open path runs `(r,b) → arc → (l,y1) → arc → (r,t)`: from
/// the bottom-right arm tip, around the rounded bottom-left corner,
/// up the left stem, around the rounded top-left corner, out to the
/// top-right arm tip. It is an open outline (no `close`), so the
/// generated geometry is an open stroke path.
pub fn build_left_bracket(width : Int, height : Int, adj~ : Int = 8333) -> ShapeGeometry {
  // §20.1.10.56 leftBracket: maxAdj = 50000·h/ss; a = pin 0 adj maxAdj;
  // corner radius y1 = ss·a/100000.
  let ss = min_dim(width, height)
  let max_adj = if ss == 0 { 0 } else { fraction(50000, height, ss) }
  let r = percent(ss, pin_int(adj, 0, max_adj))
  let commands : Array[PathCommand] = []
  // Bottom arm tip → rounded bottom-left corner.
  commands.push(MoveTo(width, height))
  commands.push(ArcTo(r, r, 0, false, false, 0, height - r))
  // Up the left stem.
  commands.push(LineTo(0, r))
  // Rounded top-left corner → top arm tip.
  commands.push(ArcTo(r, r, 0, false, false, width, 0))
  { commands, width, height }
}
