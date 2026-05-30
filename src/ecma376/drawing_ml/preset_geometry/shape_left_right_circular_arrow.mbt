// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry —
// `leftRightCircularArrow`.

///|
/// §20.1.10.56 `leftRightCircularArrow` — a curved arrow band swept
/// around a ring with an arrowhead at *both* ends, so it reads as a
/// two-way circular arrow.
///
/// As with `circularArrow` / `leftCircularArrow`, the spec solves the
/// line/ellipse intersections for each arrowhead/ring tangent — here
/// for BOTH ends (a 230-guide chain). That chain is evaluated by the
/// data-driven `guide_engine` from its verbatim spec definition
/// (`left_right_circular_arrow_def`) — correct by construction from
/// the engine's verified operators.
pub fn build_left_right_circular_arrow(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  build_from_definition(left_right_circular_arrow_def(), width, height, [])
}
