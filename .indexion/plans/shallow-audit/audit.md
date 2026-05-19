# ECMA-376 Shallow Representation Gap Audit (2026-05-02)

Source: shallow-audit sub-agent (id a5572d2939e521a0f).

## Why this matters

`indexion spec align` matches **vocabulary** (type names + doc-comment terms).
The current drift gate reports 22/22 PASS in strict mode (`--fail-on any`),
but the gate cannot detect "type defined, no logic". Example: SpreadsheetML
§18.17 Formulas — `ST_Formula = { value: String }` exists, drift gate sees
"formula" vocab in both spec and impl, MATCHED. But there is no parser,
no evaluator, no function library — Excel cannot evaluate the formula.

The user has committed to "complete ECMA-376", so every gap below must be
closed before the project can be called done.

## Audit scope

All `src/ecma376/` packages. Focus: any §-section whose normative text
contains an action verb (parse / evaluate / decode / resolve / inherit /
materialize / apply / render / transform) that has no corresponding
`pub fn` in the package's source tree.

Cross-referenced against web-pptx (`@aurochs-office/`) which has prior-art
TypeScript implementations of all these gaps.

## Gap table — sorted by criticality and dependency

| ID | Priority | Gap | §-section | Current state | LoC est | web-pptx ref |
|---|---|---|---|---|---|---|
| G1 | CRITICAL | Formula evaluation engine | SML §18.17 | Type-only (ST_Formula = String wrapper) | 5000+ | `xlsx/src/formula/` |
| G2 | CRITICAL | Shared string table (SST) lookup | SML §18.16 | Type-only (CT_Sst, CT_RElt) | 200 | yes |
| G3 | CRITICAL | Date serial conversion (1900/1904) | SML §15.2.4.6 | No logic | 150 | `xlsx/src/domain/date-serial.ts` |
| G4 | CRITICAL | Theme color resolution (scheme + tint/shade) | DML §20.1 | Type-only (CT_SchemeColor) | 800 | `drawing-ml/src/domain/color-resolution.ts` |
| G5 | HIGH | Cell value type coercion | SML §18.18.5 | Type-only (ST_CellType enum) | 300 | parser layer |
| G6 | HIGH | Conditional formatting rule evaluation | SML §18.8.21 | Type-only (CT_CfRule) | 1200 | partial; auto-filter parallel |
| G7 | HIGH | AutoFilter operator evaluation | SML §18.3.2 | Type-only (ST_FilterOperator) | 500 | `xlsx/src/domain/auto-filter-evaluator.ts` |
| G8 | HIGH | Pivot table materialization / aggregation | SML §18.10 | Type-only (CT_PivotCacheDefinition) | 3000 | `xlsx/src/parser/pivot/` |
| G9 | HIGH | WML style inheritance chain (basedOn) | WML §17.7 | Type-only (CT_Style) | 500 | `docx/src/adapters/docx-style-resolver.ts` |
| G10 | MEDIUM | SmartArt diagram layout algorithm | DML §21.4 | Type-only (CT_Algorithm/CT_LayoutNode) | 4000 | `diagram/src/layout-engine/` |
| G11 | MEDIUM | Preset shape geometry generation | DML §20.1.10 | Type-only (CT_PresetGeometry) | 2500 | `pptx/src/parser/graphics/` |
| G12 | MEDIUM | WML field code parsing/evaluation | WML §17.16 | Type-only | 1500 | `doc/src/extractor/field-extractor.ts` |
| G13 | MEDIUM | Numbering style level inheritance | WML §18 | Type-only | 600 | docx style chain |
| G14 | MEDIUM | PML slide layout/master placeholder inheritance | PML §19.5 | Type-only | 800 | `pptx/src/parser/theme` |
| G15 | MEDIUM | PML slide animations timing engine | PML §19.3.2 | Type-only (CT_TimeNodeBase) | 2000+ | partial |
| G16 | MEDIUM | Cell reference / range parsing (A1, R1C1, normalize) | SML §18.18.62 | Type-only (ST_Ref = String) | 400 | `xlsx/src/domain/cell/address.ts` |
| G17 | LOW | Drawing effects (blur/glow/shadow/reflection apply) | DML §20.1.4 | Type-only | 1500+ | partial |

**Total: ~27,500 LoC**

## Implementation order

The order minimises rework — each phase makes the next easier:

### Tier 0 — finish SoT consolidation first (in flight)

- ✅ Phase 1 sot-errors (commits 380869d + 44b699b)
- ✅ Phase 2 sot-namespaces (35054a5)
- ✅ Phase 3 sot-xml-escape (967323e)
- ✅ Phase 4 sot-part-name + fix-up (75f7585 + 8ea997e)
- 🔄 Phase 6 sot-package-mutator (codex pid 11456 in flight)
- ⏳ Phase 7 sot-zip-deflate

### Tier 1 — CRITICAL infrastructure

These unlock everything downstream. Sequence by dependency:

1. **G16 ST_Ref / cell address parsing** (400 LoC) — required by G1 (formula
   needs cell refs), G6 (cond format formulas), G7 (filter ranges).
2. **G3 date serial** (150 LoC) — required by formula DATE/TIME functions
   and by cell coercion.
3. **G2 SST lookup** (200 LoC) — required by G1 (formulas that reference
   string cells), G5 (text cell coercion).
4. **G5 cell value coercion** (300 LoC) — required by G1 (formula reads
   numeric/text/bool/error cells).
5. **G1 formula engine** (5000+ LoC) — depends on G2/G3/G5/G16.
   Sub-phases: tokenizer → parser → AST → evaluator → function library
   (62+ functions categorised as web-pptx).
6. **G4 theme color resolution** (800 LoC) — required by every renderer
   and by SML conditional formatting color scales (G6).

### Tier 2 — HIGH

7. ✅ **G7 AutoFilter evaluator** (500 LoC) — d8ac183 g7-autofilter-eval.
8. ✅ **G6 Conditional formatting** (1200 LoC) — 725025e g6-cf-rule-eval.
9. ✅ **G9 WML style inheritance** (500 LoC) — b562c36 g9-wml-style-inheritance.
10. ⏳ **G8 Pivot tables** (3000 LoC) — depends on G16, G5, G2. Best
    split into ≥3 commits: cache definition + pivot table definition +
    materialization.

### Tier 3 — MEDIUM

11. ✅ **G14 PML placeholder inheritance** (800 LoC) — 19e2589
    g14-pml-placeholder.
12. ✅ **G13 WML numbering inheritance** (600 LoC) — e627008
    g13-wml-numbering.
13. ⏳ **G11 Preset shape geometry** (2500 LoC) — independent of
    evaluators. Best split per shape family (rectangles / arrows /
    callouts / flowchart / connector / star+banner).
14. ⏳ **G12 WML field codes** (1500 LoC) — depends on G9 (style needed
    for field result formatting in some cases). Tokenizer + parser +
    ~15 most common instruction evaluators (PAGE, DATE, TIME, AUTHOR,
    HYPERLINK, REF, PAGEREF, NUMPAGES, SECTIONPAGES, SEQ, MERGEFIELD,
    TOC entry, IF, INCLUDETEXT).
15. ⏳ **G10 SmartArt layout** (4000 LoC) — depends on G11 (preset shapes),
    G4 (theme colors).
16. ⏳ **G15 PML animations timing** (2000+ LoC) — depends on G14.

### Tier 4 — LOW

17. ⏳ **G17 Drawing effects** (1500+ LoC) — primarily a renderer concern.

## Progress snapshot (2026-05-19)

Closed: G1, G2, G3, G4, G5, G6, G7, G9, G13, G14, G16 (11 / 17).
Remaining: G8, G10, G11, G12, G15, G17 (6 / 17). Each is ≥1500 LoC
and warrants its own multi-commit session per the SDD pattern
established by G1 (9 commits) and observed in the G13/G14/G6
single-commit closures above.

## Drift gate strategy

For each gap closed:

1. Expand `.kiro/specs/ecma376/<package>/spec.md` with the relevant §-text
   from `references/spec/part1/sections/<n.m>__<topic>.md` so that the
   shallow detection can fire on the new sub-section.
2. Run `bash .kiro/scripts/drift.sh --pkg <pkg> --layer raw --strict` to
   verify the spec.md update covers the source.
3. Implement the package under SDD discipline (requirements → design →
   tasks → impl with per-task gate `bash .kiro/scripts/drift.sh --pkg
   <pkg> --layer src --strict`).
4. Final gate: full `bash .kiro/scripts/drift.sh --strict` 22/22 PASS.

This way the drift gate's vocab match becomes a non-trivial signal because
the spec.md side now contains the action-verb vocabulary that requires
matching `pub fn` on the impl side. Empty type stubs will SHALLOW.
