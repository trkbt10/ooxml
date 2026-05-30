// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftRightArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `leftRightArrowCallout` — a rectangular callout box with
/// arrows extending from the middle of both the left and right edges.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb height (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box width fraction (48123).
pub fn build_left_right_arrow_callout(
  width : Int,
  height : Int,
  adj1~ : Int = 25000,
  adj2~ : Int = 25000,
  adj3~ : Int = 25000,
  adj4~ : Int = 48123,
) -> ShapeGeometry {
  // §20.1.10.56 — a centred box with arrows on both sides. ss-based:
  //   a2 = pin 0 adj2 (50000·h/ss); a1 = pin 0 adj1 (2·a2);
  //   a3 = pin 0 adj3 (50000·w/ss); a4 = pin 0 adj4 (100000 − 2·a3·ss/w).
  // dy1 = ss·a2/100000 (head half-height); dy2 = ss·a1/200000 (shaft
  // half-thickness); head length x1 = ss·a3/100000; box half-width
  // dx2 = w·a4/200000.
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(50000, height, ss) }
  let a2 = pin_int(adj2, 0, max_adj2)
  let a1 = pin_int(adj1, 0, 2 * a2)
  let max_adj3 = if ss == 0 { 0 } else { fraction(50000, width, ss) }
  let a3 = pin_int(adj3, 0, max_adj3)
  let q2 = if width == 0 { 0 } else { fraction(2 * a3, ss, width) }
  let a4 = pin_int(adj4, 0, 100000 - q2)
  let hc = width / 2
  let vc = height / 2
  let dy1 = fraction(ss, a2, 100000)
  let dy2 = fraction(ss, a1, 200000)
  let dx2 = fraction(width, a4, 200000)
  let box_left = hc - dx2
  let box_right = hc + dx2
  let shaft_top = vc - dy2
  let shaft_bottom = vc + dy2
  let head_top = vc - dy1
  let head_bottom = vc + dy1
  let left_base_x = fraction(ss, a3, 100000)
  let right_base_x = width - left_base_x
  let commands : Array[PathCommand] = [
    // top edge of the box
    MoveTo(box_left, 0),
    LineTo(box_right, 0),
    // right side down to the right arrow shaft
    LineTo(box_right, shaft_top),
    LineTo(right_base_x, shaft_top),
    LineTo(right_base_x, head_top),
    LineTo(width, height / 2),
    LineTo(right_base_x, head_bottom),
    LineTo(right_base_x, shaft_bottom),
    LineTo(box_right, shaft_bottom),
    // bottom edge of the box
    LineTo(box_right, height),
    LineTo(box_left, height),
    // left side up to the left arrow shaft
    LineTo(box_left, shaft_bottom),
    LineTo(left_base_x, shaft_bottom),
    LineTo(left_base_x, head_bottom),
    LineTo(0, height / 2),
    LineTo(left_base_x, head_top),
    LineTo(left_base_x, shaft_top),
    LineTo(box_left, shaft_top),
    ClosePath,
  ]
  { commands, width, height }
}
