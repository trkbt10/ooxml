// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `rightArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `rightArrowCallout` — a rectangular callout box with a
/// right-pointing arrow extending from the middle of its right edge.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb height (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box width as a fraction of the
/// bounding width (64977). `adj1`/`adj2` are taken against the
/// bounding height.
pub fn build_right_arrow_callout(
  width : Int,
  height : Int,
  adj1? : Int = 25000,
  adj2? : Int = 25000,
  adj3? : Int = 25000,
  adj4? : Int = 64977,
) -> ShapeGeometry {
  // §20.1.10.56 gdLst pin chain (all radii ss-based):
  //   a2 = pin 0 adj2 (50000·h/ss); a1 = pin 0 adj1 (2·a2);
  //   a3 = pin 0 adj3 (100000·w/ss); a4 = pin 0 adj4 (100000 − a3·ss/w).
  // dy1 = ss·a2/100000 (head half-height); dy2 = ss·a1/200000 (shaft
  // half-thickness); dx3 = ss·a3/100000 (head length); x2 = w·a4/100000.
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
  let box_w = fraction(width, a4, 100000)
  let shaft_top = vc - dy2
  let shaft_bottom = vc + dy2
  let head_top = vc - dy1
  let head_bottom = vc + dy1
  let head_base_x = width - fraction(ss, a3, 100000)
  let commands : Array[PathCommand] = [
    // box outline, clockwise from top-left
    MoveTo(0, 0),
    LineTo(box_w, 0),
    // down the right side of the box to the arrow shaft
    LineTo(box_w, shaft_top),
    LineTo(head_base_x, shaft_top),
    LineTo(head_base_x, head_top),
    // arrowhead tip
    LineTo(width, height / 2),
    LineTo(head_base_x, head_bottom),
    LineTo(head_base_x, shaft_bottom),
    LineTo(box_w, shaft_bottom),
    // down the rest of the box right side
    LineTo(box_w, height),
    LineTo(0, height),
    ClosePath,
  ]
  { commands, width, height }
}
