# SoT Package Mutator Tasks

## Completed

1. Baseline duplicate audit:
   `grep -n "fn @opc.Package::with_part\|fn @opc.Package::with_optional_part\|fn required_part\|fn\[T\] read_optional" src/docx/docx.mbt src/pptx/pptx.mbt src/xlsx/xlsx.mbt`
2. Add OPC-owned methods in `src/ecma376/opc/package.mbt`.
3. Remove duplicated local helpers from `src/docx/docx.mbt`.
4. Remove duplicated local helpers from `src/pptx/pptx.mbt`.
5. Remove duplicated local helpers from `src/xlsx/xlsx.mbt`.
6. Update facade call sites to use `@opc.Package` methods.
7. Run `moon check --target native`.

## Final Gates

1. Run `moon info && moon fmt`.
2. Run `moon test --target native`.
3. Run `moon test --target wasm-gc`.
4. Run `moon test --target wasm`.
5. Run `moon test --target js`.
6. Run `bash .kiro/scripts/drift.sh --strict`.
7. Run `indexion plan refactor --threshold=0.9 --include='*.mbt' --exclude='*_wbtest.mbt' --exclude='*moon.pkg*' --exclude='*pkg.generated*' src/`.
8. Commit as
   `sot-package-mutator: move with_part/required_part/read_optional onto Package`.
