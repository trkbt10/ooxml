// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `stripedRightArrow`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.

///|
/// §20.1.10.56 `stripedRightArrow` — a right-pointing block arrow whose
/// tail is broken into striped segments: a thin bar, a wider bar, then
/// the solid shaft leading into the arrowhead.
///
/// Two adjustment guides: `adj1` = shaft thickness as a fraction of the
/// bounding height (default 50000 = 50%), `adj2` = head width as a
/// fraction of the smaller bounding dimension (default 50000 = 50%).
/// The stripe geometry comes from the spec gdLst: the head height is
/// `min(w,h)/32` units of stride, with stripes at the 1/32 and 3/32
/// marks of the smaller dimension.
pub fn build_striped_right_arrow(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let shaft_h = percent(height, 50000)
  let smaller = min_dim(width, height)
  let head_w = percent(smaller, 50000)
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let head_base_x = width - head_w
  // Stripe stride: the spec places stripe edges at 1/32, 1/16 and
  // 3/32 of the smaller dimension.
  let stripe1 = fraction(smaller, 1, 32)
  let stripe2 = fraction(smaller, 1, 16)
  let stripe3 = fraction(smaller, 5, 32)
  let commands : Array[PathCommand] = [
    // thin stripe
    MoveTo(0, shaft_top),
    LineTo(stripe1, shaft_top),
    LineTo(stripe1, shaft_bottom),
    LineTo(0, shaft_bottom),
    ClosePath,
    // wider stripe
    MoveTo(stripe2, shaft_top),
    LineTo(stripe3, shaft_top),
    LineTo(stripe3, shaft_bottom),
    LineTo(stripe2, shaft_bottom),
    ClosePath,
    // solid shaft + arrowhead
    MoveTo(stripe3, shaft_top),
    LineTo(head_base_x, shaft_top),
    LineTo(head_base_x, 0),
    LineTo(width, height / 2),
    LineTo(head_base_x, height),
    LineTo(head_base_x, shaft_bottom),
    LineTo(stripe3, shaft_bottom),
    ClosePath,
  ]
  { commands, width, height }
}
