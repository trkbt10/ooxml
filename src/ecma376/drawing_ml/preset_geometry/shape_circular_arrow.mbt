// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `circularArrow`.

///|
/// §20.1.10.56 `circularArrow` — an arrow bent around a near-full
/// circle: a thick curved band that sweeps most of the way round a
/// ring and terminates in an arrowhead.
///
/// The spec geometry solves two line/ellipse intersections (the
/// `q1`..`q22`, `u1`..`u21`, `v1`..`v22` guide cascades) to place the
/// arrowhead tangent to the curved band. That 192-guide chain is
/// evaluated by the data-driven `guide_engine` from its verbatim spec
/// definition (`circular_arrow_def`) rather than hand-transcribed —
/// the engine's operators are individually verified, so the geometry
/// is correct by construction. `adj1`/`adj5` set the band thickness
/// and arrowhead overhang, `adj2` the arrowhead angular width, and
/// `adj3`/`adj4` the sweep's end/start angles.
pub fn build_circular_arrow(width : Int, height : Int) -> ShapeGeometry {
  build_from_definition(circular_arrow_def(), width, height, [])
}
