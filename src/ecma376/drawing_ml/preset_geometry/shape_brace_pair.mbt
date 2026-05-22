// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `bracePair`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `bracePair` — a matched `{ }` pair framing the
/// bounding box: a left brace hugging the left edge and a right
/// brace hugging the right edge, each with a mid-height pinch
/// pointing toward the centre.
///
/// Spec geometry: the curl radius is `x1 = ss·a/100000` with the
/// `adj` guide defaulting to 8333 (clamped by `pin 0 adj 25000`).
/// The left brace's spine sits at `x = x1`, its arms reach `x = l`,
/// its pinch tip points right; the right brace mirrors it at the
/// other edge. The spec draws curls as quarter / reflex arcs; this
/// generator approximates them with quadratic Béziers and emits the
/// two braces as two open subpaths so a renderer draws the `{ }`
/// pair.
pub fn build_brace_pair(width : Int, height : Int) -> ShapeGeometry {
  let h25 = percent(height, 25000)
  let h50 = percent(height, 50000)
  let h75 = percent(height, 75000)
  let pinch_off = percent(height, 6000)
  // Spine insets: each brace's spine sits one-quarter of the way in.
  let lsp = percent(width, 12000)
  let rsp = width - percent(width, 12000)
  let commands : Array[PathCommand] = []
  // Left brace `{`: bottom arm at the left edge, spine at `lsp`,
  // pinch tip pointing right toward the centre.
  commands.push(MoveTo(0, height))
  commands.push(QuadTo(lsp, height, lsp, h75))
  commands.push(LineTo(lsp, h50 + pinch_off))
  commands.push(QuadTo(lsp, h50, lsp * 2, h50))
  commands.push(QuadTo(lsp, h50, lsp, h50 - pinch_off))
  commands.push(LineTo(lsp, h25))
  commands.push(QuadTo(lsp, 0, 0, 0))
  // Right brace `}`: top arm at the right edge, spine at `rsp`,
  // pinch tip pointing left toward the centre.
  commands.push(MoveTo(width, 0))
  commands.push(QuadTo(rsp, 0, rsp, h25))
  commands.push(LineTo(rsp, h50 - pinch_off))
  commands.push(QuadTo(rsp, h50, rsp - (width - rsp), h50))
  commands.push(QuadTo(rsp, h50, rsp, h50 + pinch_off))
  commands.push(LineTo(rsp, h75))
  commands.push(QuadTo(rsp, height, width, height))
  { commands, width, height }
}
