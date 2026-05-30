// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftCircularArrow`.

///|
/// §20.1.10.56 `leftCircularArrow` — a curved arrow swept around a
/// ring, the mirror of `circularArrow`: the arrowhead sits at the
/// counter-clockwise (left) end of the band.
///
/// Like `circularArrow`, the spec solves two line/ellipse
/// intersections to place the arrowhead tangent to the band (the
/// 205-guide chain with `adj2`/`adj3` as the signed sweep limits).
/// That chain is evaluated by the data-driven `guide_engine` from its
/// verbatim spec definition (`left_circular_arrow_def`) — correct by
/// construction from the engine's verified operators.
pub fn build_left_circular_arrow(width : Int, height : Int) -> ShapeGeometry {
  build_from_definition(left_circular_arrow_def(), width, height, [])
}
