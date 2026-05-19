///|
/// Part 1 §20.1.10.56 `rightArrow` — block arrow pointing right. Two
/// adjustment guides drive the shape: `adj1` = head height as a
/// fraction of the bounding height (default 50000 = 50%), `adj2` =
/// head width as a fraction of the bounding width (default 50000 =
/// 50%). The shaft height is derived from `adj1`.
pub fn build_right_arrow(width : Int, height : Int) -> ShapeGeometry {
  let head_height_fraction = 100000
  let head_width_fraction = 50000
  let shaft_thickness_fraction = 50000
  let head_h = percent(height, head_height_fraction)
  let head_w = percent(width, head_width_fraction)
  let shaft_h = percent(height, shaft_thickness_fraction)
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let head_top = (height - head_h) / 2
  let head_bottom = (height + head_h) / 2
  let head_base_x = width - head_w
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, shaft_top))
  commands.push(LineTo(head_base_x, shaft_top))
  commands.push(LineTo(head_base_x, head_top))
  commands.push(LineTo(width, height / 2))
  commands.push(LineTo(head_base_x, head_bottom))
  commands.push(LineTo(head_base_x, shaft_bottom))
  commands.push(LineTo(0, shaft_bottom))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `leftArrow` — mirror of `rightArrow` across the
/// vertical axis.
pub fn build_left_arrow(width : Int, height : Int) -> ShapeGeometry {
  let head_height_fraction = 100000
  let head_width_fraction = 50000
  let shaft_thickness_fraction = 50000
  let head_h = percent(height, head_height_fraction)
  let head_w = percent(width, head_width_fraction)
  let shaft_h = percent(height, shaft_thickness_fraction)
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let head_top = (height - head_h) / 2
  let head_bottom = (height + head_h) / 2
  let head_base_x = head_w
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(width, shaft_top))
  commands.push(LineTo(head_base_x, shaft_top))
  commands.push(LineTo(head_base_x, head_top))
  commands.push(LineTo(0, height / 2))
  commands.push(LineTo(head_base_x, head_bottom))
  commands.push(LineTo(head_base_x, shaft_bottom))
  commands.push(LineTo(width, shaft_bottom))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `upArrow` — block arrow pointing up. Mirrors
/// `rightArrow` rotated 90° counter-clockwise; constructed directly to
/// keep coordinates monotone for the renderer.
pub fn build_up_arrow(width : Int, height : Int) -> ShapeGeometry {
  let head_w_fraction = 100000
  let head_h_fraction = 50000
  let shaft_thickness_fraction = 50000
  let head_w = percent(width, head_w_fraction)
  let head_h = percent(height, head_h_fraction)
  let shaft_w = percent(width, shaft_thickness_fraction)
  let shaft_left = (width - shaft_w) / 2
  let shaft_right = (width + shaft_w) / 2
  let head_left = (width - head_w) / 2
  let head_right = (width + head_w) / 2
  let head_base_y = head_h
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(shaft_left, height))
  commands.push(LineTo(shaft_left, head_base_y))
  commands.push(LineTo(head_left, head_base_y))
  commands.push(LineTo(width / 2, 0))
  commands.push(LineTo(head_right, head_base_y))
  commands.push(LineTo(shaft_right, head_base_y))
  commands.push(LineTo(shaft_right, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `downArrow` — block arrow pointing down. Mirror
/// of `upArrow` across the horizontal axis.
pub fn build_down_arrow(width : Int, height : Int) -> ShapeGeometry {
  let head_w_fraction = 100000
  let head_h_fraction = 50000
  let shaft_thickness_fraction = 50000
  let head_w = percent(width, head_w_fraction)
  let head_h = percent(height, head_h_fraction)
  let shaft_w = percent(width, shaft_thickness_fraction)
  let shaft_left = (width - shaft_w) / 2
  let shaft_right = (width + shaft_w) / 2
  let head_left = (width - head_w) / 2
  let head_right = (width + head_w) / 2
  let head_base_y = height - head_h
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(shaft_left, 0))
  commands.push(LineTo(shaft_right, 0))
  commands.push(LineTo(shaft_right, head_base_y))
  commands.push(LineTo(head_right, head_base_y))
  commands.push(LineTo(width / 2, height))
  commands.push(LineTo(head_left, head_base_y))
  commands.push(LineTo(shaft_left, head_base_y))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `leftRightArrow` — bidirectional horizontal
/// arrow with heads on both sides of a centred shaft.
pub fn build_left_right_arrow(width : Int, height : Int) -> ShapeGeometry {
  let head_height_fraction = 100000
  let head_width_fraction = 25000
  let shaft_thickness_fraction = 50000
  let head_h = percent(height, head_height_fraction)
  let head_w = percent(width, head_width_fraction)
  let shaft_h = percent(height, shaft_thickness_fraction)
  let shaft_top = (height - shaft_h) / 2
  let shaft_bottom = (height + shaft_h) / 2
  let head_top = (height - head_h) / 2
  let head_bottom = (height + head_h) / 2
  let left_base_x = head_w
  let right_base_x = width - head_w
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, height / 2))
  commands.push(LineTo(left_base_x, head_top))
  commands.push(LineTo(left_base_x, shaft_top))
  commands.push(LineTo(right_base_x, shaft_top))
  commands.push(LineTo(right_base_x, head_top))
  commands.push(LineTo(width, height / 2))
  commands.push(LineTo(right_base_x, head_bottom))
  commands.push(LineTo(right_base_x, shaft_bottom))
  commands.push(LineTo(left_base_x, shaft_bottom))
  commands.push(LineTo(left_base_x, head_bottom))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `upDownArrow` — bidirectional vertical arrow.
/// Mirror of `leftRightArrow` rotated 90°.
pub fn build_up_down_arrow(width : Int, height : Int) -> ShapeGeometry {
  let head_w_fraction = 100000
  let head_h_fraction = 25000
  let shaft_thickness_fraction = 50000
  let head_w = percent(width, head_w_fraction)
  let head_h = percent(height, head_h_fraction)
  let shaft_w = percent(width, shaft_thickness_fraction)
  let shaft_left = (width - shaft_w) / 2
  let shaft_right = (width + shaft_w) / 2
  let head_left = (width - head_w) / 2
  let head_right = (width + head_w) / 2
  let top_base_y = head_h
  let bottom_base_y = height - head_h
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(width / 2, 0))
  commands.push(LineTo(head_right, top_base_y))
  commands.push(LineTo(shaft_right, top_base_y))
  commands.push(LineTo(shaft_right, bottom_base_y))
  commands.push(LineTo(head_right, bottom_base_y))
  commands.push(LineTo(width / 2, height))
  commands.push(LineTo(head_left, bottom_base_y))
  commands.push(LineTo(shaft_left, bottom_base_y))
  commands.push(LineTo(shaft_left, top_base_y))
  commands.push(LineTo(head_left, top_base_y))
  commands.push(ClosePath)
  { commands, width, height }
}
