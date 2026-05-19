# G15 — tasks

1. Create `src/ecma376/presentation_ml/animation_eval/moon.pkg`
   importing `@xml`, `@opc_errors`, `@domain` (and `@utf8` for the
   wbtest target).
2. `types.mbt` — enum definitions, structs, citation helper.
   Include non-trivial `from_attr` decoders for each enum so the
   shallow gate sees logic in the same file as the type defs.
3. `decode.mbt` — `decode_timing`, `decode_time_node_list`,
   per-kind decoders (`decode_par/seq/excl/anim/animClr/animMotion/
   animRot/animScale/set/cmd`), `decode_cbhvr`, `decode_condition`,
   `decode_anim_variant`, `decode_tav` plus XML helpers.
4. `interpolate.mbt` — `ease_progress`, `interpolate_numeric_tav`,
   `interpolate_variant`, `effective_progress` (repeat / autoRev).
5. `scheduler.mbt` — `TimingEngine::new`, `schedule`, `animate`,
   `place_node`, `flatten_leaves`.
6. `scheduler_wbtest.mbt` — at least seven test blocks per the
   plan's test list.
7. `moon fmt && moon info && moon check --target native && moon
   test --target native -p
   trkbt10/ooxml/ecma376/presentation_ml/animation_eval`.
   Inspect new `pkg.generated.mbti`.
8. `bash .kiro/scripts/drift.sh --pkg ecma376/presentation_ml`.
   Goal: SPEC_ONLY → 0, SHALLOW → 0, PASS.
9. Commit as
   `g15-animations: §19.5 PML animation timing engine`.
