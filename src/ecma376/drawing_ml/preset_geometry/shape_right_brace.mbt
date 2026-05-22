// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `rightBrace`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `rightBrace` — a `}` curly brace: a vertical spine on
/// the left half of the box, two arms curling left at the top and
/// bottom, and a pinch point jutting right at mid-height.
///
/// Spec geometry: the curl radius is `y1 = ss·a1/100000` (`adj1`
/// default 8333), and the pinch sits at height `y3 = h·a2/100000`
/// (`adj2` default 50000 ⇒ `y3 = h/2`). The spec spine runs along
/// `x = hc`, the arms reach `x = l`, and the pinch tip reaches
/// `x = r`. The spec draws four quarter / reflex arcs; this
/// generator approximates the four curls with quadratic Béziers —
/// the silhouette is the canonical `}` glyph. Open outline (no
/// `close`).
pub fn build_right_brace(width : Int, height : Int) -> ShapeGeometry {
  let hc = width / 2
  let pinch_y = percent(height, 50000)
  let commands : Array[PathCommand] = []
  // Top arm tip → curl down to the spine.
  commands.push(MoveTo(0, 0))
  commands.push(QuadTo(hc, 0, hc, percent(height, 25000)))
  // Spine down to just above the pinch.
  commands.push(LineTo(hc, pinch_y - percent(height, 6000)))
  // Pinch: curl out to the right tip at mid-height, then back in.
  commands.push(QuadTo(hc, pinch_y, width, pinch_y))
  commands.push(QuadTo(hc, pinch_y, hc, pinch_y + percent(height, 6000)))
  // Spine down toward the bottom curl.
  commands.push(LineTo(hc, percent(height, 75000)))
  // Bottom curl out to the bottom arm tip.
  commands.push(QuadTo(hc, height, 0, height))
  { commands, width, height }
}
