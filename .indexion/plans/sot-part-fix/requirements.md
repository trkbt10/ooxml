# Requirements

## Goal

Restore strict Source-of-Truth drift compliance for `ecma376/opc/part` after
Phase 4 introduced `PartName` as a public type alias and lowered
`src/ecma376/opc/part/domain.mbt` below indexion's per-file shallow threshold.

## Functional Requirements

- Add non-trivial public functions in `src/ecma376/opc/part/domain.mbt`, the
  same file that defines the §8 Core Properties and §9 Thumbnails domain types.
- Cover the shallow §8 Core Properties requirements for `CoreProperties`,
  `CT_CoreProperties`, `CoreKeywords`, `CoreKeyword`, and core property
  elements by walking `@xml.Document` / `@xml.Element` DOM nodes.
- Cover the shallow §9 Thumbnails and `PackagePart` requirements by inspecting
  part bytes, content type, and reserved relationship part names.
- Keep the implementation package-local to `src/ecma376/opc/part/`.
- Preserve existing read/write round-trip behavior.

## Constraints

- Do not modify `.kiro/specs/ecma376/`.
- Do not touch packages outside `src/ecma376/opc/part/`.
- Do not move the new logic into another file because indexion shallow checks
  are per-file.
- Do not add stub or accessor-only functions; each public helper must perform
  real validation, iteration, lookup, or byte inspection.

## Verification

- `moon check --target native`
- `moon test --target native`
- `moon test --target wasm-gc`
- `moon test --target wasm`
- `moon test --target js`
- `bash .kiro/scripts/drift.sh --strict`
