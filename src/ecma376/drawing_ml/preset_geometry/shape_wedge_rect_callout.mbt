// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `wedgeRectCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `wedgeRectCallout` — a plain rectangular speech bubble
/// with a triangular pointer ("wedge") tail attached to one edge.
///
/// Spec geometry: the tail tip sits at `(xPos, yPos)` where
/// `xPos = hc + w·adj1/100000` and `yPos = vc + h·adj2/100000`
/// (default `adj1 = -20833`, `adj2 = 62500`, so the tip is below
/// the box, down-left of centre). The spec selects which of the
/// four edges carries the wedge from the sign of `dxPos`/`dyPos`;
/// with the default adjustments the wedge erupts from the bottom
/// edge between the guide points `x1 = w·2/12` and `x2 = w·5/12`.
/// The body rectangle stays unmodified on the other three edges.
pub fn build_wedge_rect_callout(width : Int, height : Int) -> ShapeGeometry {
  // Tail tip from the default avLst adjustments.
  let tip_x = width / 2 + percent(width, -20833)
  let tip_y = height / 2 + percent(height, 62500)
  // Default `adj2 > 0` ⇒ wedge on the bottom edge; base spans the
  // guide points x1..x2 (with dxPos < 0 the spec picks 2/12, 5/12).
  let base_left = fraction(width, 2, 12)
  let base_right = fraction(width, 5, 12)
  let commands : Array[PathCommand] = []
  // Body, clockwise from the top-left, with the wedge spliced into
  // the bottom edge.
  commands.push(MoveTo(0, 0))
  commands.push(LineTo(width, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(base_right, height))
  commands.push(LineTo(tip_x, tip_y))
  commands.push(LineTo(base_left, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}
