// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `notchedRightArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `notchedRightArrow` — a right-pointing block arrow whose
/// tail edge is cut inward with a V-shaped notch.
///
/// Two adjustment guides: `adj1` = head height as a fraction of the
/// bounding height (default 50000 = 50%, the shaft thickness), `adj2`
/// = head width as a fraction of the smaller bounding dimension
/// (default 50000 = 50%). The notch depth mirrors the head width.
pub fn build_notched_right_arrow(
  width : Int,
  height : Int,
  adj1? : Int = 50000,
  adj2? : Int = 50000,
) -> ShapeGeometry {
  // §20.1.10.56: shaft thickness = h·a1/100000; head length dx2 =
  // ss·a2/100000 (maxAdj2 = 100000·w/ss); notch x1 = dy1·dx2/hd2.
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(100000, width, ss) }
  let shaft_h = percent(height, pin_int(adj1, 0, 100000))
  let head_w = percent(ss, pin_int(adj2, 0, max_adj2))
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let head_base_x = width - head_w
  // §20.1.10.56 — the notch point depth is `x1 = dy1 * dx2 / hd2`,
  // i.e. the shaft half-height scaled by the head-width / half-
  // height ratio, so the V mirrors the arrow head's slope.
  let notch_x = if height > 0 { shaft_h * head_w / height } else { 0 }
  let commands : Array[PathCommand] = [
    MoveTo(0, shaft_top),
    LineTo(head_base_x, shaft_top),
    LineTo(head_base_x, 0),
    LineTo(width, height / 2),
    LineTo(head_base_x, height),
    LineTo(head_base_x, shaft_bottom),
    LineTo(0, shaft_bottom),
    LineTo(notch_x, height / 2),
    ClosePath,
  ]
  { commands, width, height }
}
