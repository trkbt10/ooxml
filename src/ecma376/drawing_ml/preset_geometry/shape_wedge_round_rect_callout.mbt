// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `wedgeRoundRectCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `wedgeRoundRectCallout` — a rounded-rectangle speech
/// bubble with a triangular pointer ("wedge") tail attached to one
/// edge.
///
/// Spec geometry: identical to `wedgeRectCallout` for the wedge —
/// the tail tip is `(xPos, yPos)` with `xPos = hc + w·adj1/100000`
/// and `yPos = vc + h·adj2/100000` (default `adj1 = -20833`,
/// `adj2 = 62500`) — but the four body corners are rounded with
/// radius `u1 = ss·adj3/100000` (default `adj3 = 16667`). With the
/// default adjustments the wedge erupts from the bottom edge between
/// the guide points `x1 = w·2/12` and `x2 = w·5/12`; each rounded
/// corner is a quarter-circle `ArcTo`.
pub fn build_wedge_round_rect_callout(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let r = percent(min_dim(width, height), 16667)
  // Tail tip from the default avLst adjustments.
  let tip_x = width / 2 + percent(width, -20833)
  let tip_y = height / 2 + percent(height, 62500)
  // Default `adj2 > 0` ⇒ wedge on the bottom edge; base spans the
  // guide points x1..x2.
  let base_left = fraction(width, 2, 12)
  let base_right = fraction(width, 5, 12)
  let commands : Array[PathCommand] = []
  // Clockwise from just past the rounded top-left corner.
  commands.push(MoveTo(r, 0))
  commands.push(LineTo(width - r, 0))
  commands.push(ArcTo(r, r, 0, false, true, width, r))
  commands.push(LineTo(width, height - r))
  commands.push(ArcTo(r, r, 0, false, true, width - r, height))
  // Wedge spliced into the bottom edge.
  commands.push(LineTo(base_right, height))
  commands.push(LineTo(tip_x, tip_y))
  commands.push(LineTo(base_left, height))
  commands.push(LineTo(r, height))
  commands.push(ArcTo(r, r, 0, false, true, 0, height - r))
  commands.push(LineTo(0, r))
  commands.push(ArcTo(r, r, 0, false, true, r, 0))
  commands.push(ClosePath)
  { commands, width, height }
}
