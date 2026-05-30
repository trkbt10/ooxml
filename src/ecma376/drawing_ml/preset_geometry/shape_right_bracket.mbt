// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `rightBracket`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `rightBracket` — a `]` shape: a vertical stem with a
/// short horizontal arm rounding off the top and the bottom.
///
/// Spec geometry: the corner radius is `y1 = ss·a/100000` with the
/// `adj` guide defaulting to 8333 (≈ 1/12 of the shorter side). The
/// spec open path runs `(l,t) → arc → (r,y1) → arc → (l,b)`: from
/// the top-left arm tip, around the rounded top-right corner, down
/// the right stem, around the rounded bottom-right corner, back to
/// the bottom-left arm tip. It is an open outline (no `close`).
pub fn build_right_bracket(width : Int, height : Int, adj~ : Int = 8333) -> ShapeGeometry {
  // §20.1.10.56 rightBracket: maxAdj = 50000·h/ss; a = pin 0 adj maxAdj;
  // corner radius y1 = ss·a/100000.
  let ss = min_dim(width, height)
  let max_adj = if ss == 0 { 0 } else { fraction(50000, height, ss) }
  let r = percent(ss, pin_int(adj, 0, max_adj))
  let commands : Array[PathCommand] = []
  // Top arm tip → rounded top-right corner.
  commands.push(MoveTo(0, 0))
  commands.push(ArcTo(r, r, 0, false, true, width, r))
  // Down the right stem.
  commands.push(LineTo(width, height - r))
  // Rounded bottom-right corner → bottom arm tip.
  commands.push(ArcTo(r, r, 0, false, true, 0, height))
  { commands, width, height }
}
