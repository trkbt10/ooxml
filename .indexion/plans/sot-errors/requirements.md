# SoT Errors Requirements

## Introduction

The OPC packages currently declare byte-identical `SchemaViolation`,
`UnsupportedFeature`, and `ResourceMissing` suberrors in five `errors.mbt`
files:

- `src/ecma376/opc/errors.mbt`
- `src/ecma376/opc/content_types/errors.mbt`
- `src/ecma376/opc/digital_signatures/errors.mbt`
- `src/ecma376/opc/part/errors.mbt`
- `src/ecma376/opc/relationships/errors.mbt`

This creates separate catchable suberror types even though the payloads and
helper behavior are identical. The refactor must consolidate the declarations
without changing ECMA-376 Part 2 §8 error behavior or drifting SDD coverage.

## Requirements

### R1: Single Source Of Truth

When the refactor is complete, the codebase shall contain exactly one
declaration of each `SchemaViolation`, `UnsupportedFeature`, and
`ResourceMissing` suberror type.

When subpackages need to expose those names, they shall do so without declaring
new suberror types.

### R2: Payload Compatibility

When an error is raised, the `SchemaViolation` payload shall remain
`section~ : String`, `path~ : String`, `reason~ : String`.

When an error is raised, the `UnsupportedFeature` payload shall remain
`section~ : String`, `path~ : String`, `reason~ : String`.

When an error is raised, the `ResourceMissing` payload shall remain
`section~ : String`, `path~ : String`, `target~ : String`.

### R3: Catch-Site Compatibility

When a prior in-repository caller catches `@<subpkg>.SchemaViolation(...)`, the
call-site shall be migrated to the canonical OPC §8 constructor and destructure
the same fields.

When a prior in-repository caller catches `@<subpkg>.UnsupportedFeature(...)`,
the call-site shall be migrated to the canonical OPC §8 constructor and
destructure the same fields.

When a prior in-repository caller catches `@<subpkg>.ResourceMissing(...)`, the
call-site shall be migrated to the canonical OPC §8 constructor and destructure
the same fields.

### R4: Helper Compatibility

When an in-repository caller needs the former `require_supported_feature`
behaviour, the call-site shall invoke the canonical OPC §8 helper and raise
`UnsupportedFeature` under the same condition with identical field values.

When an in-repository caller needs the former `require_resource` behaviour, the
call-site shall invoke the canonical OPC §8 helper and raise `ResourceMissing`
under the same condition with identical field values.

### R5: SDD Anchors

When duplicated declarations are removed, each owning package's §8 Errors
vocabulary anchor shall remain present as a doc comment in that package or in
the canonical error declaration.

### R6: Drift Gate

When `bash .kiro/scripts/drift.sh` is run after the refactor, every package
shall retain PASS status with the same matched, drifted, and spec_only counts
as the baseline run.

### R7: Backend Tests

When `moon test --target native` is run, it shall pass with zero failures.

When `moon test --target wasm-gc` is run, it shall pass with zero failures.

When `moon test --target wasm` is run, it shall pass with zero failures.

When `moon test --target js` is run, it shall pass with zero failures.

### R8: Digital Signatures Helper Visibility

When the consolidation is complete, `digital_signatures/errors.mbt` shall not
retain private duplicate helper declarations; helper behaviour shall be covered
by the canonical OPC §8 package.

## Baseline

Baseline `bash .kiro/scripts/drift.sh` on 2026-05-02 reported PASS for all 22
packages. The OPC row counts were:

- `raw -> kiro` `ecma376/opc`: matched 30, drifted 0, spec_only 0
- `raw -> kiro` `ecma376/opc/content_types`: matched 1, drifted 0, spec_only 0
- `raw -> kiro` `ecma376/opc/digital_signatures`: matched 30, drifted 0, spec_only 0
- `raw -> kiro` `ecma376/opc/part`: matched 21, drifted 0, spec_only 0
- `raw -> kiro` `ecma376/opc/relationships`: matched 6, drifted 0, spec_only 0
- `kiro -> src` `ecma376/opc`: matched 30, drifted 0, spec_only 0
- `kiro -> src` `ecma376/opc/content_types`: matched 10, drifted 0, spec_only 0
- `kiro -> src` `ecma376/opc/digital_signatures`: matched 39, drifted 0, spec_only 0
- `kiro -> src` `ecma376/opc/part`: matched 26, drifted 0, spec_only 0
- `kiro -> src` `ecma376/opc/relationships`: matched 14, drifted 0, spec_only 0

Baseline `moon test --target native` passed 336 tests with zero failures.
