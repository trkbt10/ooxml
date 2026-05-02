# G4 Theme Color Requirements

## Scope

- Implement DrawingML §20.1.2.3 color resolution in `src/ecma376/drawing_ml/color_resolution`.
- Resolve `srgbClr`, `schemeClr`, `sysClr`, `prstClr`, and `hslClr` bases into final 8-bit RGBA.
- Read §20.1.6 `clrScheme` entries for `dk1`, `lt1`, `dk2`, `lt2`, `accent1..6`, `hlink`, and `folHlink`.
- Apply supported transform children in document order.

## Conformance Requirements

- `tint`, `shade`, `lumMod`, `lumOff`, and `satMod` operate in HSL space per §20.1.2.3.20, .21, .27, .31, and .34.
- `alpha`, `alphaMod`, and `alphaOff` operate on the alpha channel per §20.1.2.3.1-.3.
- `schemeClr val="phClr"` resolves only when the caller supplies an effective placeholder color; otherwise it raises `@opc_errors.SchemaViolation`.
- Invalid hex, missing required theme entries, unknown preset colors, and unsupported transform elements raise `@opc_errors.SchemaViolation`.
- The package imports only `@opc_errors`, `@xml`, and core libraries; it does not depend on public OOXML facades.

## Gates

- `moon check --target native`
- `moon test --target native`
- `moon test --target wasm-gc`
- `moon test --target wasm`
- `moon test --target js`
- `bash .kiro/scripts/drift.sh --pkg ecma376/drawing_ml --layer src --strict`
- `bash .kiro/scripts/drift.sh --strict`
