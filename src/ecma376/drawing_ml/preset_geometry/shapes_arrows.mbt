///|
/// Part 1 §20.1.10.56 `rightArrow` — block arrow pointing right. Per
/// the spec gdLst the arrowhead length `dx1 = ss·a2/100000` is a
/// fraction of the SHORTER side `ss = min(w, h)` (NOT the width;
/// `a2 = pin 0 adj2 maxAdj2`, `maxAdj2 = 100000·w/ss`, default 50000),
/// and the shaft thickness `2·dy1 = h·a1/100000` (`a1 = pin 0 adj1
/// 100000`, default 50000). The head spans the full height to the tip
/// at `(r, vc)`.
pub fn build_right_arrow(
  width : Int,
  height : Int,
  adj1~ : Int = 50000,
  adj2~ : Int = 50000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(100000, width, ss) }
  let head_w = percent(ss, pin_int(adj2, 0, max_adj2))
  let shaft_h = percent(height, pin_int(adj1, 0, 100000))
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let head_base_x = width - head_w
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, shaft_top))
  commands.push(LineTo(head_base_x, shaft_top))
  commands.push(LineTo(head_base_x, 0))
  commands.push(LineTo(width, height / 2))
  commands.push(LineTo(head_base_x, height))
  commands.push(LineTo(head_base_x, shaft_bottom))
  commands.push(LineTo(0, shaft_bottom))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `leftArrow` — mirror of `rightArrow` across the
/// vertical axis (same `ss`-based head length and `adj` guides).
pub fn build_left_arrow(
  width : Int,
  height : Int,
  adj1~ : Int = 50000,
  adj2~ : Int = 50000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(100000, width, ss) }
  let head_w = percent(ss, pin_int(adj2, 0, max_adj2))
  let shaft_h = percent(height, pin_int(adj1, 0, 100000))
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let head_base_x = head_w
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(width, shaft_top))
  commands.push(LineTo(head_base_x, shaft_top))
  commands.push(LineTo(head_base_x, 0))
  commands.push(LineTo(0, height / 2))
  commands.push(LineTo(head_base_x, height))
  commands.push(LineTo(head_base_x, shaft_bottom))
  commands.push(LineTo(width, shaft_bottom))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `upArrow` — block arrow pointing up. Mirrors
/// `rightArrow` rotated 90° counter-clockwise; constructed directly to
/// keep coordinates monotone for the renderer.
pub fn build_up_arrow(
  width : Int,
  height : Int,
  adj1~ : Int = 50000,
  adj2~ : Int = 50000,
) -> ShapeGeometry {
  // §20.1.10.56: head length dy1 = ss·a2/100000 (ss-based, maxAdj2 =
  // 100000·h/ss); shaft thickness 2·dx1 = w·a1/100000.
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(100000, height, ss) }
  let head_h = percent(ss, pin_int(adj2, 0, max_adj2))
  let shaft_w = percent(width, pin_int(adj1, 0, 100000))
  let shaft_left = (width - shaft_w) / 2
  let shaft_right = (width + shaft_w) / 2
  let head_base_y = head_h
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(shaft_left, height))
  commands.push(LineTo(shaft_left, head_base_y))
  commands.push(LineTo(0, head_base_y))
  commands.push(LineTo(width / 2, 0))
  commands.push(LineTo(width, head_base_y))
  commands.push(LineTo(shaft_right, head_base_y))
  commands.push(LineTo(shaft_right, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `downArrow` — block arrow pointing down. Mirror
/// of `upArrow` across the horizontal axis (same `ss`-based head
/// length and `adj` guides).
pub fn build_down_arrow(
  width : Int,
  height : Int,
  adj1~ : Int = 50000,
  adj2~ : Int = 50000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(100000, height, ss) }
  let head_h = percent(ss, pin_int(adj2, 0, max_adj2))
  let shaft_w = percent(width, pin_int(adj1, 0, 100000))
  let shaft_left = (width - shaft_w) / 2
  let shaft_right = (width + shaft_w) / 2
  let head_base_y = height - head_h
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(shaft_left, 0))
  commands.push(LineTo(shaft_right, 0))
  commands.push(LineTo(shaft_right, head_base_y))
  commands.push(LineTo(width, head_base_y))
  commands.push(LineTo(width / 2, height))
  commands.push(LineTo(0, head_base_y))
  commands.push(LineTo(shaft_left, head_base_y))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `leftRightArrow` — bidirectional horizontal
/// arrow with heads on both sides of a centred shaft. Per the spec
/// gdLst each head length `x2 = ss·a2/100000` is `ss`-based
/// (`a2 = pin 0 adj2 maxAdj2`, `maxAdj2 = 50000·w/ss`, default 50000),
/// and the shaft thickness `2·dy = h·a1/100000` (`a1 = pin 0 adj1
/// 100000`, default 50000). The right head base sits at `x3 = w − x2`.
pub fn build_left_right_arrow(
  width : Int,
  height : Int,
  adj1~ : Int = 50000,
  adj2~ : Int = 50000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(50000, width, ss) }
  let head_w = percent(ss, pin_int(adj2, 0, max_adj2))
  let shaft_h = percent(height, pin_int(adj1, 0, 100000))
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let left_base_x = head_w
  let right_base_x = width - head_w
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, height / 2))
  commands.push(LineTo(left_base_x, 0))
  commands.push(LineTo(left_base_x, shaft_top))
  commands.push(LineTo(right_base_x, shaft_top))
  commands.push(LineTo(right_base_x, 0))
  commands.push(LineTo(width, height / 2))
  commands.push(LineTo(right_base_x, height))
  commands.push(LineTo(right_base_x, shaft_bottom))
  commands.push(LineTo(left_base_x, shaft_bottom))
  commands.push(LineTo(left_base_x, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `upDownArrow` — bidirectional vertical arrow.
/// Mirror of `leftRightArrow` rotated 90°.
pub fn build_up_down_arrow(
  width : Int,
  height : Int,
  adj1~ : Int = 50000,
  adj2~ : Int = 50000,
) -> ShapeGeometry {
  // §20.1.10.56: head length = ss·a2/100000 (ss-based, maxAdj2 =
  // 50000·h/ss); shaft thickness = w·a1/100000.
  let ss = min_dim(width, height)
  let max_adj2 = if ss == 0 { 0 } else { fraction(50000, height, ss) }
  let head_h = percent(ss, pin_int(adj2, 0, max_adj2))
  let shaft_w = percent(width, pin_int(adj1, 0, 100000))
  let shaft_left = (width - shaft_w) / 2
  let shaft_right = (width + shaft_w) / 2
  let top_base_y = head_h
  let bottom_base_y = height - head_h
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(width / 2, 0))
  commands.push(LineTo(width, top_base_y))
  commands.push(LineTo(shaft_right, top_base_y))
  commands.push(LineTo(shaft_right, bottom_base_y))
  commands.push(LineTo(width, bottom_base_y))
  commands.push(LineTo(width / 2, height))
  commands.push(LineTo(0, bottom_base_y))
  commands.push(LineTo(shaft_left, bottom_base_y))
  commands.push(LineTo(shaft_left, top_base_y))
  commands.push(LineTo(0, top_base_y))
  commands.push(ClosePath)
  { commands, width, height }
}
