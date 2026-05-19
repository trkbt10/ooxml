///|
/// Part 1 §20.1.10.56 `rect` — four-corner rectangle covering the full
/// bounding box. Path order goes clockwise starting from the top-left
/// (renderer convention) and closes back to the origin.
pub fn build_rect(width : Int, height : Int) -> ShapeGeometry {
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, 0))
  commands.push(LineTo(width, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `plaque` — rectangle with the four corners
/// scalloped inward by the `adj` guide. The default `adj` is 16667 (≈
/// 1/6 of the side length) and is the value the spec image is drawn
/// against. The implementation uses quadratic Beziers along the
/// diagonals so the SVG-style ArcTo command stays unused; the
/// renderer can refine to true arcs later.
pub fn build_plaque(width : Int, height : Int) -> ShapeGeometry {
  let r = percent(min_dim(width, height), 16667)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(r, 0))
  commands.push(LineTo(width - r, 0))
  commands.push(QuadTo(width, 0, width, r))
  commands.push(LineTo(width, height - r))
  commands.push(QuadTo(width, height, width - r, height))
  commands.push(LineTo(r, height))
  commands.push(QuadTo(0, height, 0, height - r))
  commands.push(LineTo(0, r))
  commands.push(QuadTo(0, 0, r, 0))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `roundRect` — rectangle with four equal rounded
/// corners. The default `adj` guide is 16667 ≈ 1/6 of the shorter
/// side. The corner is rendered as a quadratic Bezier whose control
/// point sits at the un-rounded corner; this is the same construction
/// MS PowerPoint uses for shallow corner radii.
pub fn build_round_rect(width : Int, height : Int) -> ShapeGeometry {
  let r = percent(min_dim(width, height), 16667)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(r, 0))
  commands.push(LineTo(width - r, 0))
  commands.push(QuadTo(width, 0, width, r))
  commands.push(LineTo(width, height - r))
  commands.push(QuadTo(width, height, width - r, height))
  commands.push(LineTo(r, height))
  commands.push(QuadTo(0, height, 0, height - r))
  commands.push(LineTo(0, r))
  commands.push(QuadTo(0, 0, r, 0))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `ellipse` — full ellipse inscribed in the
/// bounding box. Two ArcTo commands sweep top-half then bottom-half
/// so the SVG-style `large_arc` flag stays false and renderers that
/// only handle 180°-or-less arcs still draw the full shape.
pub fn build_ellipse(width : Int, height : Int) -> ShapeGeometry {
  let rx = width / 2
  let ry = height / 2
  let cx = width / 2
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, ry))
  commands.push(ArcTo(rx, ry, 0, false, true, cx * 2, ry))
  commands.push(ArcTo(rx, ry, 0, false, true, 0, ry))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `triangle` — isoceles triangle with the apex on
/// the top edge centred horizontally, base on the bottom edge.
pub fn build_triangle(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(cx, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `rtTriangle` — right triangle with the right
/// angle at the bottom-left corner, hypotenuse from top-left to
/// bottom-right.
pub fn build_right_triangle(width : Int, height : Int) -> ShapeGeometry {
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `parallelogram` — leaning rectangle whose top
/// and bottom edges are horizontal but whose left and right edges
/// slant by the `adj` guide (default 25000 = 25% of the width).
pub fn build_parallelogram(width : Int, height : Int) -> ShapeGeometry {
  let slant = percent(width, 25000)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(slant, 0))
  commands.push(LineTo(width, 0))
  commands.push(LineTo(width - slant, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `trapezoid` — isoceles trapezoid with the wider
/// base on the bottom edge. The default `adj` guide is 25000 (top
/// edge is 50% of the width, inset 25% from each side).
pub fn build_trapezoid(width : Int, height : Int) -> ShapeGeometry {
  let inset = percent(width, 25000)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(inset, 0))
  commands.push(LineTo(width - inset, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `diamond` — diamond / rhombus inscribed in the
/// bounding box with corners at the midpoint of each side.
pub fn build_diamond(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(cx, 0))
  commands.push(LineTo(width, cy))
  commands.push(LineTo(cx, height))
  commands.push(LineTo(0, cy))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 — regular n-gon inscribed in the bounding box.
/// The first vertex sits at the top of the inscribing ellipse and the
/// remaining vertices are placed at equal angular intervals going
/// clockwise. Used for `pentagon`, `hexagon`, `heptagon`, `octagon`,
/// `decagon`, and `dodecagon`.
pub fn build_regular_polygon(
  sides : Int,
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  let commands : Array[PathCommand] = []
  for i in 0..<sides {
    let theta = -90 + i * 360 / sides
    let x = cx + fraction(rx, cos10000(theta), 10000)
    let y = cy + fraction(ry, sin10000(theta), 10000)
    if i == 0 {
      commands.push(MoveTo(x, y))
    } else {
      commands.push(LineTo(x, y))
    }
  }
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `heart` — heart shape rendered with two cubic
/// Bezier lobes meeting at the top-centre dimple and a single cubic
/// sweeping down to the apex. The control points follow the
/// canonical 1:1 aspect-ratio heart used by the spec image.
pub fn build_heart(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let lobe_y = percent(height, 30000)
  let apex_y = height
  let side_x = percent(width, 90000)
  let inner_x = percent(width, 25000)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(cx, percent(height, 25000)))
  // Left lobe
  commands.push(
    CurveTo(
      percent(width, 35000),
      -percent(height, 10000),
      -percent(width, 25000),
      percent(height, 40000),
      width - side_x,
      lobe_y,
    ),
  )
  // Down to apex along left side
  commands.push(
    CurveTo(
      inner_x,
      percent(height, 55000),
      percent(width, 35000),
      percent(height, 80000),
      cx,
      apex_y,
    ),
  )
  // Up from apex along right side
  commands.push(
    CurveTo(
      percent(width, 65000),
      percent(height, 80000),
      width - inner_x,
      percent(height, 55000),
      side_x,
      lobe_y,
    ),
  )
  // Right lobe
  commands.push(
    CurveTo(
      width + percent(width, 25000),
      percent(height, 40000),
      percent(width, 65000),
      -percent(height, 10000),
      cx,
      percent(height, 25000),
    ),
  )
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `cloud` — cloud silhouette built from eight
/// quadratic Bezier bumps around the bounding box. The construction
/// keeps every control point on the bounding box edges so the cloud
/// fills the supplied dimensions without overshooting.
pub fn build_cloud(width : Int, height : Int) -> ShapeGeometry {
  let q = percent(width, 25000)
  let q2 = percent(width, 50000)
  let q3 = percent(width, 75000)
  let bump = percent(height, 30000)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(q, height - bump))
  commands.push(QuadTo(0, height - bump, 0, percent(height, 60000)))
  commands.push(QuadTo(0, percent(height, 25000), q, percent(height, 25000)))
  commands.push(QuadTo(q, 0, q2, percent(height, 15000)))
  commands.push(QuadTo(q2, 0, q3, percent(height, 20000)))
  commands.push(QuadTo(width, 0, width, percent(height, 40000)))
  commands.push(QuadTo(width, percent(height, 70000), q3, height - bump))
  commands.push(QuadTo(q3, height, q2, height - bump))
  commands.push(QuadTo(q, height, q, height - bump))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `smileyFace` — circular face boundary with two
/// dots for eyes and a curved mouth. Each feature is its own
/// subpath; the renderer treats the combined commands as a single
/// even-odd or non-zero fill region.
pub fn build_smiley_face(width : Int, height : Int) -> ShapeGeometry {
  let face = build_ellipse(width, height)
  let commands : Array[PathCommand] = []
  for cmd in face.commands {
    commands.push(cmd)
  }
  // Left eye
  let eye_rx = percent(width, 6000)
  let eye_ry = percent(height, 8000)
  let left_eye_cx = percent(width, 33000)
  let right_eye_cx = percent(width, 67000)
  let eye_cy = percent(height, 33000)
  commands.push(MoveTo(left_eye_cx - eye_rx, eye_cy))
  commands.push(
    ArcTo(eye_rx, eye_ry, 0, false, true, left_eye_cx + eye_rx, eye_cy),
  )
  commands.push(
    ArcTo(eye_rx, eye_ry, 0, false, true, left_eye_cx - eye_rx, eye_cy),
  )
  commands.push(ClosePath)
  commands.push(MoveTo(right_eye_cx - eye_rx, eye_cy))
  commands.push(
    ArcTo(eye_rx, eye_ry, 0, false, true, right_eye_cx + eye_rx, eye_cy),
  )
  commands.push(
    ArcTo(eye_rx, eye_ry, 0, false, true, right_eye_cx - eye_rx, eye_cy),
  )
  commands.push(ClosePath)
  // Mouth — quadratic smile from 25% to 75% width at 65% height with
  // control point at the bottom centre.
  let mouth_left_x = percent(width, 25000)
  let mouth_right_x = percent(width, 75000)
  let mouth_y = percent(height, 65000)
  let mouth_cp_y = percent(height, 85000)
  commands.push(MoveTo(mouth_left_x, mouth_y))
  commands.push(QuadTo(width / 2, mouth_cp_y, mouth_right_x, mouth_y))
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `plus` / `mathPlus` — plus sign with arm width
/// controlled by the `adj` guide (default 25000 = 25% of the shorter
/// side). Construction goes clockwise from the top-left corner of
/// the vertical arm.
pub fn build_plus(width : Int, height : Int) -> ShapeGeometry {
  let arm = percent(min_dim(width, height), 25000)
  let left_x = (width - arm) / 2
  let right_x = (width + arm) / 2
  let top_y = (height - arm) / 2
  let bottom_y = (height + arm) / 2
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(left_x, 0))
  commands.push(LineTo(right_x, 0))
  commands.push(LineTo(right_x, top_y))
  commands.push(LineTo(width, top_y))
  commands.push(LineTo(width, bottom_y))
  commands.push(LineTo(right_x, bottom_y))
  commands.push(LineTo(right_x, height))
  commands.push(LineTo(left_x, height))
  commands.push(LineTo(left_x, bottom_y))
  commands.push(LineTo(0, bottom_y))
  commands.push(LineTo(0, top_y))
  commands.push(LineTo(left_x, top_y))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `mathMinus` — horizontal bar centred in the
/// bounding box. The `adj` guide controls the bar height (default
/// 23520 ≈ 23.5% of the shorter side).
pub fn build_minus(width : Int, height : Int) -> ShapeGeometry {
  let bar_h = percent(height, 23520)
  let top_y = (height - bar_h) / 2
  let bottom_y = (height + bar_h) / 2
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, top_y))
  commands.push(LineTo(width, top_y))
  commands.push(LineTo(width, bottom_y))
  commands.push(LineTo(0, bottom_y))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `mathMultiply` — multiplication sign rendered
/// as a rotated plus. The implementation walks the 12 vertices of
/// the cross and rotates each by 45° around the centre using the
/// integer sine/cosine helpers from `geometry.mbt`.
pub fn build_multiply(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let plus = build_plus(width, height)
  let commands : Array[PathCommand] = []
  let cos45 = cos10000(45)
  let sin45 = sin10000(45)
  for cmd in plus.commands {
    match cmd {
      MoveTo(x, y) => {
        let (rx, ry) = rotate_about(x, y, cx, cy, cos45, sin45)
        commands.push(MoveTo(rx, ry))
      }
      LineTo(x, y) => {
        let (rx, ry) = rotate_about(x, y, cx, cy, cos45, sin45)
        commands.push(LineTo(rx, ry))
      }
      ClosePath => commands.push(ClosePath)
      other => commands.push(other)
    }
  }
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `mathDivide` — divide sign rendered as a
/// horizontal bar with a centred dot above and below it. The dots
/// are quadratic-Bezier circles around the bar's vertical midpoint.
pub fn build_divide(width : Int, height : Int) -> ShapeGeometry {
  let bar_h = percent(height, 11760)
  let bar_top = (height - bar_h) / 2
  let bar_bottom = (height + bar_h) / 2
  let dot_r = percent(min_dim(width, height), 7000)
  let cx = width / 2
  let top_dot_cy = percent(height, 25000)
  let bottom_dot_cy = percent(height, 75000)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, bar_top))
  commands.push(LineTo(width, bar_top))
  commands.push(LineTo(width, bar_bottom))
  commands.push(LineTo(0, bar_bottom))
  commands.push(ClosePath)
  push_circle(commands, cx, top_dot_cy, dot_r)
  push_circle(commands, cx, bottom_dot_cy, dot_r)
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `mathEqual` — two parallel horizontal bars.
/// Default bar height is the §20.1.9.11 `adj1` guide value of 11760.
pub fn build_equal(width : Int, height : Int) -> ShapeGeometry {
  let bar_h = percent(height, 11760)
  let gap = percent(height, 25000)
  let top_bar_top = (height - gap) / 2 - bar_h
  let top_bar_bottom = top_bar_top + bar_h
  let bottom_bar_top = (height + gap) / 2
  let bottom_bar_bottom = bottom_bar_top + bar_h
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, top_bar_top))
  commands.push(LineTo(width, top_bar_top))
  commands.push(LineTo(width, top_bar_bottom))
  commands.push(LineTo(0, top_bar_bottom))
  commands.push(ClosePath)
  commands.push(MoveTo(0, bottom_bar_top))
  commands.push(LineTo(width, bottom_bar_top))
  commands.push(LineTo(width, bottom_bar_bottom))
  commands.push(LineTo(0, bottom_bar_bottom))
  commands.push(ClosePath)
  { commands, width, height }
}

///|
fn min_dim(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn rotate_about(
  x : Int,
  y : Int,
  cx : Int,
  cy : Int,
  cos10000_value : Int,
  sin10000_value : Int,
) -> (Int, Int) {
  let dx = x - cx
  let dy = y - cy
  let nx = cx +
    fraction(dx, cos10000_value, 10000) -
    fraction(dy, sin10000_value, 10000)
  let ny = cy +
    fraction(dx, sin10000_value, 10000) +
    fraction(dy, cos10000_value, 10000)
  (nx, ny)
}

///|
fn push_circle(
  commands : Array[PathCommand],
  cx : Int,
  cy : Int,
  r : Int,
) -> Unit {
  commands.push(MoveTo(cx - r, cy))
  commands.push(ArcTo(r, r, 0, false, true, cx + r, cy))
  commands.push(ArcTo(r, r, 0, false, true, cx - r, cy))
  commands.push(ClosePath)
}
