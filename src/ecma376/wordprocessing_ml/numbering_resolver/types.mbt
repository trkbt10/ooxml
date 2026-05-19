// Runtime-only types for the §17.9 numbering resolver. All
// spec-named CT_*/ST_* types live in `@domain`; this file keeps the
// evaluator-internal provenance markers that the spec does not name.

///|
/// LevelOrigin — provenance of a resolved level. Used by renderers
/// that want to audit whether the level came from a num's
/// lvlOverride, from the directly-referenced abstractNum, or from a
/// numStyleLink chain follow-up.
pub(all) enum LevelOrigin {
  /// §17.9.8 lvlOverride — the resolved level came from a CT_NumLvl
  /// override carried directly on the num.
  SourceOverride
  /// §17.9.1 abstractNum — the resolved level came from the abstract
  /// definition referenced by the num.
  SourceAbstract
  /// §17.9.21 numStyleLink — the resolved level came from a second
  /// abstract definition reached by following `numStyleLink ->
  /// styleLink`.
  SourceLinkedAbstract
} derive(Eq, Debug)

///|
/// Result of `CT_Numbering::resolve_level`. Carries the chosen
/// CT_Lvl plus the origin for diagnostics.
pub(all) struct ResolvedLvl {
  /// §17.9.6 lvl — the resolved level definition.
  lvl : @domain.CT_Lvl
  /// Provenance of the resolution path; see `LevelOrigin`.
  origin : LevelOrigin
} derive(Eq, Debug)

///|
let numbering_section : String = "Part 1 §17.9"

///|
/// Part 1 §17.9 — citation helper exposed so callers can include the
/// canonical section anchor in their own diagnostics.
pub fn numbering_part1_17_9_section_name() -> String {
  numbering_section
}
