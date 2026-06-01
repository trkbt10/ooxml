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
/// §21.4.7.49 `ar` (aspect ratio) is applied to the temporary child
/// constraint rectangle only. `ar = 0` keeps `inner` unchanged; a
/// non-zero width:height ratio shrinks whichever dimension is too
/// large and leaves the composite node's origin unchanged.
pub fn layout_composite(
  inner : BoundsRect,
  child_count : Int,
) -> Array[BoundsRect] {
  layout_composite_with_algorithm(
    inner,
    { kind: AlgComposite, params: [] },
    child_count,
  )
}

///|
fn layout_composite_with_algorithm(
  inner : BoundsRect,
  algorithm : Algorithm,
  child_count : Int,
) -> Array[BoundsRect] {
  let result : Array[BoundsRect] = []
  if child_count <= 0 {
    return result
  }
  let child_inner = apply_composite_aspect_ratio(inner, algorithm)
  for _ in 0..<child_count {
    result.push(child_inner)
  }
  result
}

///|
fn apply_composite_aspect_ratio(
  inner : BoundsRect,
  algorithm : Algorithm,
) -> BoundsRect {
  let ratio = match algorithm.param("ar") {
    Some(raw) =>
      try parse_double_string(raw, "alg/param[@type='ar']") catch {
        _ => 0.0
      } noraise {
        value => value
      }
    None => 0.0
  }
  if ratio <= 0.0 || inner.width <= 0.0 || inner.height <= 0.0 {
    return inner
  }
  let current = inner.width / inner.height
  if current > ratio {
    { ..inner, width: inner.height * ratio }
  } else if current < ratio {
    { ..inner, height: inner.width / ratio }
  } else {
    inner
  }
}
