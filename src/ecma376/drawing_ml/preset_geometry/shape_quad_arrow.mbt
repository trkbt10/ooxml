// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `quadArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `quadArrow` — a four-headed arrow with heads pointing
/// up, down, left and right from a common central junction.
///
/// Per the spec gdLst (defaults all 22500): `adj1` = shaft thickness
/// (`a1 = pin 0 adj1 2·a2`, half-thickness `dx3 = ss·a1/200000`),
/// `adj2` = arrowhead half-width (`a2 = pin 0 adj2 50000`, `dx2 =
/// ss·a2/100000` measured ABSOLUTELY from the centre — NOT added to
/// the shaft), and `adj3` = arrowhead length (`a3 = pin 0 adj3
/// (50000−a2)`, `x1 = ss·a3/100000`). All are `ss`-based.
pub fn build_quad_arrow(
  width : Int,
  height : Int,
  adj1? : Int = 22500,
  adj2? : Int = 22500,
  adj3? : Int = 22500,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let a2 = pin_int(adj2, 0, 50000)
  let a1 = pin_int(adj1, 0, 2 * a2)
  let a3 = pin_int(adj3, 0, 50000 - a2)
  let head_barb = percent(ss, a2)
  let shaft_half = fraction(ss, a1, 200000)
  let head_len = percent(ss, a3)
  let cx = width / 2
  let cy = height / 2
  // Shaft band edges, centred on each axis.
  let h_top = cy - shaft_half
  let h_bottom = cy + shaft_half
  let v_left = cx - shaft_half
  let v_right = cx + shaft_half
  // Arrowhead barb edges — absolute half-width `dx2` from the centre.
  let head_top = cy - head_barb
  let head_bottom = cy + head_barb
  let head_left = cx - head_barb
  let head_right = cx + head_barb
  // Arrowhead base offsets from each edge.
  let left_base = head_len
  let right_base = width - head_len
  let top_base = head_len
  let bottom_base = height - head_len
  let commands : Array[PathCommand] = [
    // left arrowhead
    MoveTo(0, cy),
    LineTo(left_base, head_top),
    LineTo(left_base, h_top),
    // up to the up arrowhead
    LineTo(v_left, h_top),
    LineTo(v_left, top_base),
    LineTo(head_left, top_base),
    LineTo(cx, 0),
    LineTo(head_right, top_base),
    LineTo(v_right, top_base),
    // down to the right arrowhead
    LineTo(v_right, h_top),
    LineTo(right_base, h_top),
    LineTo(right_base, head_top),
    LineTo(width, cy),
    LineTo(right_base, head_bottom),
    LineTo(right_base, h_bottom),
    // back to the down arrowhead
    LineTo(v_right, h_bottom),
    LineTo(v_right, bottom_base),
    LineTo(head_right, bottom_base),
    LineTo(cx, height),
    LineTo(head_left, bottom_base),
    LineTo(v_left, bottom_base),
    // up to the left arrowhead
    LineTo(v_left, h_bottom),
    LineTo(left_base, h_bottom),
    LineTo(left_base, head_bottom),
    ClosePath,
  ]
  { commands, width, height }
}
