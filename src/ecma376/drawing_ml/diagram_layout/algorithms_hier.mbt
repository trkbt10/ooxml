///|
/// Part 1 §21.4.7.1 hierRoot / hierChild — produce per-child
/// bounds for a hierarchy diagram. The root sits across the top
/// 30 % of the bounding box; the remaining 70 % is shared among
/// the children, each becoming its own sub-tree which the engine
/// recurses into.
///
/// The function returns a tuple `(root_bounds, child_bounds[])`
/// so the engine can dispatch the root layout to one child and
/// the children layout to another (matching the `hierRoot`
/// algorithm's child ordering: first child = root, second child
/// = children container).
pub fn layout_hier(
  inner : BoundsRect,
  child_count : Int,
) -> (BoundsRect, Array[BoundsRect]) {
  let root_height_ratio = 0.30
  let root_h = inner.height * root_height_ratio
  let root_bounds = {
    x: inner.x,
    y: inner.y,
    width: inner.width,
    height: root_h,
  }
  let children : Array[BoundsRect] = []
  if child_count <= 0 {
    return (root_bounds, children)
  }
  let n = child_count
  let children_y = inner.y + root_h
  let children_h = inner.height - root_h
  let child_w = inner.width / n.to_double()
  for i in 0..<n {
    let bounds = {
      x: inner.x + i.to_double() * child_w,
      y: children_y,
      width: child_w,
      height: children_h,
    }
    children.push(bounds)
  }
  (root_bounds, children)
}
