# SoT Errors Tasks

## Completed

- [x] Created `.kiro/specs/sot-errors`.
- [x] Captured baseline drift gate and native test output.
- [x] Audited duplicated OPC error declarations and helper visibility.
- [x] Verified that suberror type aliases do not preserve old
      package-qualified constructor patterns.
- [x] Verified that direct subpackage imports of the OPC facade create an
      import loop in the current package graph.
- [x] Added the canonical OPC §8 errors package.
- [x] Removed duplicated suberror declarations from the five former OPC
      `errors.mbt` declaration files.
- [x] Migrated OPC raises and catch-sites to `@opc_errors`.
- [x] Removed duplicate helper wrappers and migrated in-repository helper tests
      to `@opc_errors`.

## Verification

- [x] `moon check --target native`
- [x] `moon test --target native`
- [x] `moon info && moon fmt`
- [x] `bash .kiro/scripts/drift.sh`
- [x] `moon test --target wasm-gc`
- [x] `moon test --target wasm`
- [x] `moon test --target js`
- [x] `indexion plan refactor --threshold=0.9 --include='*.mbt' --exclude='*_wbtest.mbt' src/`
