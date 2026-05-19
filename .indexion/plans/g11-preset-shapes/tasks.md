# G11 — tasks

1. Create `src/ecma376/drawing_ml/preset_geometry/moon.pkg` importing
   `@xml`, `@opc_errors`.
2. `types.mbt` — `PresetShape` (187 variants), `PresetShapeFamily`
   (11), `Adjustment`, `PathCommand`, `ShapeGeometry`,
   `PresetGeometry` + non-trivial `from_attr` / `family` methods and
   `preset_geometry_part1_20_1_10_56_section_name`.
3. `decode.mbt` — `decode_preset_geometry(@xml.Element)`,
   `decode_adjustment(@xml.Element)`, `parse_val_formula(String)`,
   shared attr / unsigned-int helpers.
4. `geometry.mbt` — `build_geometry` dispatcher, `supports`,
   `rectangular_fallback`, shared helpers (fraction, polygon vertex
   table).
5. `shapes_rect.mbt` — rectangular family geometry constructors.
6. `shapes_arrows.mbt` — arrow family.
7. `shapes_callouts.mbt` — callout family.
8. `shapes_stars.mbt` — star family + shared `n_pointed_star` helper.
9. `shapes_flowchart.mbt` — flowchart family.
10. `geometry_wbtest.mbt` — at least 13 test blocks covering the
    decoder happy / error paths, family classification, every
    in-scope shape family, the rectangular fallback, and the
    section-name accessor.
11. `moon fmt && moon info && moon check --target native && moon test
    --target native -p trkbt10/ooxml/ecma376/drawing_ml/preset_geometry`.
    Inspect the new `pkg.generated.mbti`.
12. `.kiro/scripts/drift.sh --pkg ecma376/drawing_ml`. Goal: PASS.
13. Single commit `g11-preset-shapes: §20.1.10 preset shape geometry`.
