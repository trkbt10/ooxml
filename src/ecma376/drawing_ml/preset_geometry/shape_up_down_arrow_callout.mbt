// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `upDownArrowCallout`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `upDownArrowCallout` — a rectangular callout box with
/// arrows extending from the middle of both the top and bottom edges.
///
/// Adjustment guides (defaults): `adj1` = arrow shaft thickness
/// (25000), `adj2` = arrowhead barb width (25000), `adj3` = arrowhead
/// length (25000), `adj4` = callout box height fraction (48123).
pub fn build_up_down_arrow_callout(
  width : Int,
  height : Int,
  adj1? : Int = 25000,
  adj2? : Int = 25000,
  adj3? : Int = 25000,
  adj4? : Int = 48123,
) -> ShapeGeometry {
  // §20.1.10.56 — vertical analog of leftRightArrowCallout: centred box
  // with arrows up and down. ss-based pin chain; head half-width dx1 =
  // ss·a2/100000, shaft half-thickness dx2 = ss·a1/200000, head length
  // y1 = ss·a3/100000, box half-height dy2 = h·a4/200000.
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(50000, width, ss) }
  let a2 = pin_int(adj2, 0, max_adj2)
  let a1 = pin_int(adj1, 0, 2 * a2)
  let max_adj3 = if ss == 0 { 0 } else { fraction(50000, height, ss) }
  let a3 = pin_int(adj3, 0, max_adj3)
  let q2 = if height == 0 { 0 } else { fraction(2 * a3, ss, height) }
  let a4 = pin_int(adj4, 0, 100000 - q2)
  let hc = width / 2
  let vc = height / 2
  let dx1 = fraction(ss, a2, 100000)
  let dx2 = fraction(ss, a1, 200000)
  let dy2 = fraction(height, a4, 200000)
  let box_top = vc - dy2
  let box_bottom = vc + dy2
  let shaft_left = hc - dx2
  let shaft_right = hc + dx2
  let head_left = hc - dx1
  let head_right = hc + dx1
  let top_base_y = fraction(ss, a3, 100000)
  let bottom_base_y = height - top_base_y
  let commands : Array[PathCommand] = [
    // up arrowhead tip
    MoveTo(width / 2, 0),
    LineTo(head_right, top_base_y),
    LineTo(shaft_right, top_base_y),
    // down to the box top edge
    LineTo(shaft_right, box_top),
    LineTo(width, box_top),
    // right side of the box
    LineTo(width, box_bottom),
    LineTo(shaft_right, box_bottom),
    // down to the down arrowhead
    LineTo(shaft_right, bottom_base_y),
    LineTo(head_right, bottom_base_y),
    LineTo(width / 2, height),
    LineTo(head_left, bottom_base_y),
    LineTo(shaft_left, bottom_base_y),
    // up to the box bottom edge
    LineTo(shaft_left, box_bottom),
    LineTo(0, box_bottom),
    // left side of the box
    LineTo(0, box_top),
    LineTo(shaft_left, box_top),
    // up to the up arrowhead
    LineTo(shaft_left, top_base_y),
    LineTo(head_left, top_base_y),
    ClosePath,
  ]
  { commands, width, height }
}
