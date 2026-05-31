// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `upArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `upArrowCallout` — a rectangular callout box with an
/// up-pointing arrow extending from the middle of its top edge.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb width (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box height fraction (64977).
/// `adj1`/`adj2` are taken against the bounding width.
pub fn build_up_arrow_callout(
  width : Int,
  height : Int,
  adj1? : Int = 25000,
  adj2? : Int = 25000,
  adj3? : Int = 25000,
  adj4? : Int = 64977,
) -> ShapeGeometry {
  // §20.1.10.56 — vertical analog of rightArrowCallout (swap w↔h):
  //   a2 = pin 0 adj2 (50000·w/ss); a1 = pin 0 adj1 (2·a2);
  //   a3 = pin 0 adj3 (100000·h/ss); a4 = pin 0 adj4 (100000 − a3·ss/h).
  // dx1 = ss·a2/100000 (head half-width); dx2 = ss·a1/200000 (shaft
  // half-thickness); head length y1 = ss·a3/100000; box height = h·a4/100000.
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(50000, width, ss) }
  let a2 = pin_int(adj2, 0, max_adj2)
  let a1 = pin_int(adj1, 0, 2 * a2)
  let max_adj3 = if ss == 0 { 0 } else { fraction(100000, height, ss) }
  let a3 = pin_int(adj3, 0, max_adj3)
  let q2 = if height == 0 { 0 } else { fraction(a3, ss, height) }
  let a4 = pin_int(adj4, 0, 100000 - q2)
  let hc = width / 2
  let dx1 = fraction(ss, a2, 100000)
  let dx2 = fraction(ss, a1, 200000)
  let box_top = height - fraction(height, a4, 100000)
  let shaft_left = hc - dx2
  let shaft_right = hc + dx2
  let head_left = hc - dx1
  let head_right = hc + dx1
  let head_base_y = fraction(ss, a3, 100000)
  let commands : Array[PathCommand] = [
    // box outline, plus arrow on the top edge
    MoveTo(0, height),
    LineTo(0, box_top),
    LineTo(shaft_left, box_top),
    LineTo(shaft_left, head_base_y),
    LineTo(head_left, head_base_y),
    LineTo(width / 2, 0),
    LineTo(head_right, head_base_y),
    LineTo(shaft_right, head_base_y),
    LineTo(shaft_right, box_top),
    LineTo(width, box_top),
    LineTo(width, height),
    ClosePath,
  ]
  { commands, width, height }
}
