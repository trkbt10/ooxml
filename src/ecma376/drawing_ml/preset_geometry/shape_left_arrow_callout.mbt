// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `leftArrowCallout` — a rectangular callout box with a
/// left-pointing arrow extending from the middle of its left edge.
/// Mirror of `rightArrowCallout` across the vertical axis.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb height (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box width fraction (64977).
pub fn build_left_arrow_callout(
  width : Int,
  height : Int,
  adj1~ : Int = 25000,
  adj2~ : Int = 25000,
  adj3~ : Int = 25000,
  adj4~ : Int = 64977,
) -> ShapeGeometry {
  // §20.1.10.56 — mirror of rightArrowCallout: arrow on the left, box
  // on the right. Same ss-based pin chain; head base x1 = ss·a3/100000,
  // box left edge x2 = w − w·a4/100000.
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(50000, height, ss) }
  let a2 = pin_int(adj2, 0, max_adj2)
  let a1 = pin_int(adj1, 0, 2 * a2)
  let max_adj3 = if ss == 0 { 0 } else { fraction(100000, width, ss) }
  let a3 = pin_int(adj3, 0, max_adj3)
  let q2 = if width == 0 { 0 } else { fraction(a3, ss, width) }
  let a4 = pin_int(adj4, 0, 100000 - q2)
  let vc = height / 2
  let dy1 = fraction(ss, a2, 100000)
  let dy2 = fraction(ss, a1, 200000)
  let box_left = width - fraction(width, a4, 100000)
  let shaft_top = vc - dy2
  let shaft_bottom = vc + dy2
  let head_top = vc - dy1
  let head_bottom = vc + dy1
  let head_base_x = fraction(ss, a3, 100000)
  let commands : Array[PathCommand] = [
    MoveTo(width, 0),
    LineTo(box_left, 0),
    LineTo(box_left, shaft_top),
    LineTo(head_base_x, shaft_top),
    LineTo(head_base_x, head_top),
    LineTo(0, height / 2),
    LineTo(head_base_x, head_bottom),
    LineTo(head_base_x, shaft_bottom),
    LineTo(box_left, shaft_bottom),
    LineTo(box_left, height),
    LineTo(width, height),
    ClosePath,
  ]
  { commands, width, height }
}
