///|
/// Part 1 §20.1.10.56 `callout1` — rectangular body with a single
/// leader line segment ending at the §20.1.9.11 `adj4/adj5` anchor
/// point (defaults `(-83333, 24385)` in the canonical preset). The
/// body fills the upper portion of the bounding box and the leader
/// segment extends down-left from the bottom-left corner.
pub fn build_callout1(width : Int, height : Int) -> ShapeGeometry {
  let body_height = percent(height, 75000)
  let body = build_rect(width, body_height)
  let commands : Array[PathCommand] = []
  for cmd in body.commands {
    commands.push(cmd)
  }
  // Leader: bottom-left of body → outside anchor at (~-25% width,
  // bottom of bounding box).
  let anchor_x = -percent(width, 25000)
  let anchor_y = height
  let leader_start_x = percent(width, 25000)
  let leader_start_y = body_height
  commands.push(MoveTo(leader_start_x, leader_start_y))
  commands.push(LineTo(anchor_x, anchor_y))
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `callout2` — rectangular body with a
/// two-segment leader (an elbow). The intermediate joint sits at the
/// `adj4/adj5` anchor and the leader continues to `adj6/adj7`.
pub fn build_callout2(width : Int, height : Int) -> ShapeGeometry {
  let body_height = percent(height, 65000)
  let body = build_rect(width, body_height)
  let commands : Array[PathCommand] = []
  for cmd in body.commands {
    commands.push(cmd)
  }
  let leader_start_x = percent(width, 25000)
  let leader_start_y = body_height
  let joint_x = -percent(width, 5000)
  let joint_y = percent(height, 85000)
  let tip_x = -percent(width, 25000)
  let tip_y = height
  commands.push(MoveTo(leader_start_x, leader_start_y))
  commands.push(LineTo(joint_x, joint_y))
  commands.push(LineTo(tip_x, tip_y))
  { commands, width, height }
}

///|
/// Part 1 §20.1.10.56 `callout3` — rectangular body with a
/// three-segment leader. The construction follows the same pattern
/// as `callout2` but adds a second elbow before the tip.
pub fn build_callout3(width : Int, height : Int) -> ShapeGeometry {
  let body_height = percent(height, 55000)
  let body = build_rect(width, body_height)
  let commands : Array[PathCommand] = []
  for cmd in body.commands {
    commands.push(cmd)
  }
  let leader_start_x = percent(width, 25000)
  let leader_start_y = body_height
  let joint1_x = percent(width, 10000)
  let joint1_y = percent(height, 75000)
  let joint2_x = -percent(width, 10000)
  let joint2_y = percent(height, 85000)
  let tip_x = -percent(width, 25000)
  let tip_y = height
  commands.push(MoveTo(leader_start_x, leader_start_y))
  commands.push(LineTo(joint1_x, joint1_y))
  commands.push(LineTo(joint2_x, joint2_y))
  commands.push(LineTo(tip_x, tip_y))
  { commands, width, height }
}
