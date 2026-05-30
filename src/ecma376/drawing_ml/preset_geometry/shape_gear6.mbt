// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `gear6` / `gear9`.

///|
/// §20.1.10.56 `gear6` — a gear wheel with six teeth. FAITHFUL: the
/// 107-guide spec chain (each tooth flank placed on the pitch ellipse
/// via `at2`/`mod`/`cos`/`sin`) is evaluated by the data-driven
/// `guide_engine` from its verbatim spec definition (`gear6_def`).
pub fn build_gear6(width : Int, height : Int) -> ShapeGeometry {
  build_from_definition(gear6_def(), width, height, [])
}

///|
/// §20.1.10.56 `gear9` — a gear wheel with nine teeth. FAITHFUL: the
/// 242-guide spec chain evaluated by the data-driven `guide_engine`
/// from its verbatim spec definition (`gear9_def`).
pub fn build_gear9(width : Int, height : Int) -> ShapeGeometry {
  build_from_definition(gear9_def(), width, height, [])
}
