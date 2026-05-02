# SoT Package Mutator Requirements

## Goal

Move duplicated package mutation and optional-read helpers from the `docx`,
`pptx`, and `xlsx` facades into the OPC package source of truth:
`src/ecma376/opc/package.mbt`.

## Functional Requirements

1. `Package::with_part(name, data)` replaces the payload of an existing part
   while preserving the part name, content type, and package ordering.
2. `Package::with_optional_part(name, value, writer)` replaces the part only
   when `value` is present and leaves the package unchanged when absent.
3. `Package::required_part(name, section~, source_path~)` returns an existing
   part or raises `@opc_errors.ResourceMissing`.
4. `Package::read_optional(name, reader)` parses an existing part with the
   supplied reader or returns `None` when the part is absent.
5. `docx`, `pptx`, and `xlsx` facades must use the OPC-owned methods and must
   not define local copies of these helpers.

## Constraints

1. Preserve current facade behavior except for routing required-part misses
   through the existing OPC error translation path.
2. Do not edit `.kiro/specs/ecma376/`.
3. Do not edit existing `*_wbtest.mbt` XML body fixtures.
4. Keep dependencies flowing from public facades to `ecma376/opc`; do not add
   reverse dependencies.
5. Each new public OPC method must carry an ECMA-376 Part 2 section citation in
   its doc comment.

## Verification

1. `moon test --target native`
2. `moon test --target wasm-gc`
3. `moon test --target wasm`
4. `moon test --target js`
5. `bash .kiro/scripts/drift.sh --strict`
6. `indexion plan refactor --threshold=0.9 --include='*.mbt' --exclude='*_wbtest.mbt' --exclude='*moon.pkg*' --exclude='*pkg.generated*' src/`
