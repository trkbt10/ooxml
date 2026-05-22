// =============================================================================
// placeholder_resolver runtime types — Part 1 §19.3.1.36 ph inheritance.
//
// The decoder and the typed `CT_Placeholder` view live in
// `@domain.CT_Placeholder` (`presentation_ml/domain/placeholder_types.mbt`,
// XSD complex type CT_Placeholder — Part 1 §19.3.1.36). This file keeps
// only the runtime types the resolver needs:
//
// * `EffectivePlaceholder` — slide / layout / master merged view with
//   defaults applied per §19.7.9 / §19.7.10 / §19.3.1.36. Not a spec
//   complex type — it is the evaluator's resolution result.
// * `ResolvedShape` — the element references that contributed at each
//   chain level, plus the merged `EffectivePlaceholder` and convenience
//   accessors for `p:spPr`, `p:txBody`, `p:nvSpPr`.
// * `SlideChain` — the slide / layout / master triple used as the
//   lookup scope (§19.3.1.38 / §19.3.1.39 / §19.3.1.42).
// =============================================================================

///|
/// Effective placeholder after slide → layout → master inheritance.
/// `ph_type` defaults to `PhBody` and `size` to `PlaceholderFull` per
/// the implicit-defaults rule in §19.7.9 / §19.7.10. `orient` defaults
/// to `DirectionHorz` per §19.3.1.36. `idx` is preserved from whichever
/// level supplied it. Not a spec complex type — see header comment.
pub(all) struct EffectivePlaceholder {
  idx : Int?
  ph_type : @domain.ST_PlaceholderType
  size : @domain.ST_PlaceholderSize
  orient : @domain.ST_Direction
  has_custom_prompt : Bool
} derive(Eq, Debug)

///|
/// EffectivePlaceholder::section_name — canonical Part 1 §19.3.1.36
/// citation string for diagnostics.
pub fn EffectivePlaceholder::section_name(
  self : EffectivePlaceholder,
) -> String {
  let _ = self
  @domain.ct_placeholder_section_name()
}

///|
/// Result of resolving a single slide shape against its layout / master
/// chain. The CT_Shape projections survive so callers can pass them
/// into the DML inheritance pass (spPr / txBody / nvSpPr merge).
///
/// `effective_placeholder` is `Some` when the shape is a placeholder
/// (its `nvSpPr/nvPr/ph` is non-empty) and `None` for ordinary shapes.
pub(all) struct ResolvedShape {
  slide_shape : @domain.CT_Shape?
  layout_shape : @domain.CT_Shape?
  master_shape : @domain.CT_Shape?
  effective_placeholder : EffectivePlaceholder?
  sp_pr : @a.CT_ShapeProperties?
  tx_body : @a.CT_TextBody?
  nv_sp_pr : @domain.CT_ShapeNonVisual?
} derive(Eq, Debug)

///|
/// Slide / layout / master chain used as the lookup scope. The slide
/// and layout are optional so layout-only and master-only chains are
/// also supported (e.g. notes pages or layout previews).
pub(all) struct SlideChain {
  slide : @domain.CT_Slide?
  layout : @domain.CT_SlideLayout?
  master : @domain.CT_SlideMaster
} derive(Eq, Debug)

///|
/// SlideChain::from_parts — construct a chain from a master, an
/// optional layout, and an optional slide.
pub fn SlideChain::from_parts(
  master : @domain.CT_SlideMaster,
  layout : @domain.CT_SlideLayout?,
  slide : @domain.CT_Slide?,
) -> SlideChain {
  { master, layout, slide }
}

///|
/// Part 1 §19.3.1.36 — citation helper exposed so callers can include
/// the canonical section anchor in their own diagnostics. Returns the
/// string "Part 1 §19.3.1.36". Delegates to `@domain` so the citation
/// has a single source of truth.
pub fn placeholder_part1_19_3_1_36_section_name() -> String {
  @domain.ct_placeholder_section_name()
}
