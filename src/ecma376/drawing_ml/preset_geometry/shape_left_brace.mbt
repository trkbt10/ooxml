// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftBrace`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `leftBrace` — a `{` curly brace: a vertical spine on
/// the right half of the box, two arms curling right at the top and
/// bottom, and a pinch point jutting left at mid-height.
///
/// Spec geometry: the curl radius is `y1 = ss·a1/100000` (`adj1`
/// default 8333), and the pinch sits at height `y3 = h·a2/100000`
/// (`adj2` default 50000 ⇒ `y3 = h/2`). The spec spine runs along
/// `x = hc`, the arms reach `x = r`, and the pinch tip reaches
/// `x = l`. The spec draws four quarter / reflex arcs; this
/// generator approximates the four curls with quadratic Béziers
/// (the renderer treats them as smooth corners) — the silhouette is
/// the canonical `{` glyph. Open outline (no `close`).
pub fn build_left_brace(width : Int, height : Int) -> ShapeGeometry {
  let hc = width / 2
  let pinch_y = percent(height, 50000)
  let commands : Array[PathCommand] = []
  // Bottom arm tip → curl up to the spine.
  commands.push(MoveTo(width, height))
  commands.push(QuadTo(hc, height, hc, percent(height, 75000)))
  // Spine up to just below the pinch.
  commands.push(LineTo(hc, pinch_y + percent(height, 6000)))
  // Pinch: curl out to the left tip at mid-height, then back in.
  commands.push(QuadTo(hc, pinch_y, 0, pinch_y))
  commands.push(QuadTo(hc, pinch_y, hc, pinch_y - percent(height, 6000)))
  // Spine up toward the top curl.
  commands.push(LineTo(hc, percent(height, 25000)))
  // Top curl out to the top arm tip.
  commands.push(QuadTo(hc, 0, width, 0))
  { commands, width, height }
}
