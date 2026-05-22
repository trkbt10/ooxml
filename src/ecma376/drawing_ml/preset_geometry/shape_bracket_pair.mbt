// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `bracketPair`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `bracketPair` — a matched `[ ]` pair framing the
/// bounding box: a left bracket hugging the left edge and a right
/// bracket hugging the right edge.
///
/// Spec geometry: the corner radius is `x1 = ss·a/100000` with the
/// `adj` guide defaulting to 16667 (≈ 1/6 of the shorter side). The
/// spec's fill="none" stroke renders the pair as two open arcs — a
/// left `[` (`(x1,b) → arc → (l,x1) → arc → (x2,t)`) and a right `]`
/// (`(x2,t) → arc → (r,y2) → arc → (x1,b)`) — where `x2 = r − x1`
/// and `y2 = b − x1`. Each bracket carries a rounded corner of
/// radius `x1` at top and bottom; the two arms reach inward by `x1`.
///
/// The implementation emits the two brackets as two separate open
/// subpaths so a renderer draws them as the canonical `[ ]` glyphs.
pub fn build_bracket_pair(width : Int, height : Int) -> ShapeGeometry {
  let r = percent(min_dim(width, height), 16667)
  let commands : Array[PathCommand] = []
  // Left bracket `[`: bottom arm → rounded bottom-left → up the
  // stem → rounded top-left → top arm.
  commands.push(MoveTo(r, height))
  commands.push(ArcTo(r, r, 0, false, false, 0, height - r))
  commands.push(LineTo(0, r))
  commands.push(ArcTo(r, r, 0, false, false, r, 0))
  // Right bracket `]`: top arm → rounded top-right → down the
  // stem → rounded bottom-right → bottom arm.
  commands.push(MoveTo(width - r, 0))
  commands.push(ArcTo(r, r, 0, false, true, width, r))
  commands.push(LineTo(width, height - r))
  commands.push(ArcTo(r, r, 0, false, true, width - r, height))
  { commands, width, height }
}
