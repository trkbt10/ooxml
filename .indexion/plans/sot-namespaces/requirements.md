# SoT Namespaces Requirements

## Scope

Centralize OPC, XML-Signature, XML-Encryption, XML C14N, Office Document relationship type, and SpreadsheetDrawing namespace URI declarations in `src/ecma376/opc/namespaces`.

## Requirements

- Preserve existing OOXML behavior and public parsing/building semantics.
- Replace scattered source-level namespace URI literals with registry calls outside XML test fixture input data.
- Keep the W3C XML 1.0 prebound `xml` namespace owned by `src/xml` and expose it for downstream packages.
- Attach section-citing doc comments to every registry declaration so SDD alignment keeps stable anchors.
- Keep `.kiro/specs/ecma376/` unchanged.
- Pass drift, `moon test` on native, wasm-gc, wasm, and js, and the refactor duplicate-literal report.
