# G14 — tasks

1. Create `src/ecma376/presentation_ml/placeholder_resolver/moon.pkg`
   importing `@xml`, `@opc_errors`, `@domain`.
2. `types.mbt` — `PlaceholderType` (16), `PlaceholderSize` (3),
   `PlaceholderOrient` (2), `Placeholder`, `EffectivePlaceholder`,
   `ResolvedShape`, `SlideChain` + non-trivial `from_attr` methods
   for each enum and `placeholder_part1_19_3_1_36_section_name`.
3. `decode.mbt` — `decode_placeholder(@domain.CT_Placeholder)`,
   `decode_shape_placeholder(@xml.Element)` (walks
   nvSpPr/nvPr/ph), shape-tree iterator helpers.
4. `chain.mbt` — `SlideChain::from_slide(master, layout?, slide?)`,
   `slide_shapes`, `layout_shapes`, `master_shapes` (return
   `Array[@xml.Element]` of `p:sp` from `p:cSld/p:spTree`).
5. `resolver.mbt` — `resolve_placeholder`, `resolve_shape`,
   `merge_effective`, `lookup_by_idx`, `lookup_by_type`,
   `type_for_master_lookup`.
6. `resolver_wbtest.mbt` — six test blocks (see design plan).
7. `moon fmt && moon info && moon check --target native &&
   moon test`. Inspect new pkg.generated.mbti.
8. `.kiro/scripts/drift.sh --pkg ecma376/presentation_ml --strict`.
   Goal: SPEC_ONLY → 0, SHALLOW → 0.
9. Commit as `g14-pml-placeholder: §19.3.1.36 placeholder inheritance`.
