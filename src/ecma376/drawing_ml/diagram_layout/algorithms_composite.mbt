///|
/// Part 1 §21.4.7.1 composite — "The composite algorithm specifies
/// the size and position for all child layout nodes." Unlike `lin`
/// / `snake` / `cycle` / `pyra`, the composite algorithm performs NO
/// automatic spatial distribution of its children: every child is
/// sized and positioned solely by the composite node's own
/// `<constr for="ch" forName="…" type="l|t|w|h|r|b"/>` constraints
/// (and the child's own `<constrLst>`), each measured from the
/// composite node's origin.
///
/// The engine applies those child-targeting constraints in
/// `recurse_into_child` against the per-child base rectangle this
/// function returns. For the `l` / `t` offsets to resolve from the
/// composite origin — and for `w` / `h` to replace against the full
/// extent — every child's base rectangle is the composite's full
/// `inner` rectangle, NOT a carved-out share of it. This is the one
/// structural difference from `layout_lin`, whose per-child rects
/// are disjoint sub-bands; threading those sub-bands into a
/// composite node would shift each child's `l` / `t` anchor by the
/// preceding band offset, corrupting the layout.
///
/// A child carrying no targeting constraint therefore inherits the
/// whole composite box, matching PowerPoint's behaviour for a fully
/// constraint-driven composite node (e.g. a single shape that fills
/// its composite container).
///
/// Returns one rectangle per child, all equal to `inner`, so the
/// caller pairs them with the layout-node iteration result exactly
/// as it does for the distributing algorithms.
///
/// Scope note — the §21.4 composite `ar` (aspect-ratio) parameter,
/// which can temporarily shrink one dimension of the composite box
/// before the child constraints are computed, is not applied here.
/// `ar = 0` (the schema default, documented as "leave the width and
/// height constraints as is") is the common case and is handled
/// exactly. A non-zero `ar` still lays the children out against the
/// unshrunk box, which is bounds-correct and a strict improvement
/// over the former `lin` fallback; the ratio refinement is tracked
/// as a remaining §21.4.7.1 sub-gap.
pub fn layout_composite(
  inner : BoundsRect,
  child_count : Int,
) -> Array[BoundsRect] {
  let result : Array[BoundsRect] = []
  if child_count <= 0 {
    return result
  }
  for _ in 0..<child_count {
    result.push(inner)
  }
  result
}
