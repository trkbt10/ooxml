# G17 Drawing Effects Requirements

## Scope

- Implement DrawingML §20.1.8 drawing effects application in
  `src/ecma376/drawing_ml/effects`.
- Decode every effect element found inside `effectLst` (§20.1.8.26) into
  a typed `Effect` discriminated enum with the attributes mandated by
  §20.1.8.1 through §20.1.8.61.
- Apply color-modifying effects to an input ARGB color, producing a final
  ARGB plus an ordered list of `RenderEffect` entries describing the
  geometric effects (blur, shadow, glow, soft edges, reflection,
  transform, relative offset, fill overlay, blend, alpha-bilevel,
  alpha-outset) that downstream renderers must draw.

## Conformance Requirements

- The decoder MUST recognise every element listed in the audit task
  (`blur`, `glow`, `innerShdw`, `outerShdw`, `prstShdw`, `reflection`,
  `softEdge`, `tint`, `duotone`, `lum`, `hsl`, `fillOverlay`, `alphaMod`,
  `alphaModFix`, `alphaCeiling`, `alphaFloor`, `alphaInv`,
  `alphaRepl`, `alphaOutset`, `alphaBiLevel`, `biLevel`, `blend`,
  `clrChange`, `clrRepl`, `grayscl`, `relOff`, `xfrm`). Unknown
  elements raise `@opc_errors.SchemaViolation`.
- Attribute defaults follow the spec:
  * `blur`: `rad=0`, `grow=true` per §20.1.8.15.
  * `outerShdw`: `blurRad=0`, `dist=0`, `dir=0`, `sx=100000`, `sy=100000`,
    `kx=0`, `ky=0`, `rotWithShape=true`, `algn=b`.
  * `innerShdw`: `blurRad=0`, `dist=0`, `dir=0`.
  * `glow`: `rad=0`.
  * `reflection`: same defaults as `outerShdw` plus `stA=100%`, `stPos=0`,
    `endA=0`, `endPos=100%`, `fadeDir=5400000`.
  * `softEdge`: `rad=0`.
  * `tint`: `amt=0`, `hue=0`.
  * `lum`: `bright=0`, `contrast=0`.
  * `hsl`: `hue=0`, `sat=0`, `lum=0`.
  * `relOff`: `tx=0`, `ty=0`.
  * `xfrm`: `sx=100000`, `sy=100000`, `kx=0`, `ky=0`, `tx=0`, `ty=0`.
  * `alphaBiLevel`, `biLevel`: `thresh` required.
  * `alphaModFix`: `amt` required.
  * `alphaRepl`: `a` required.
  * `alphaOutset`: `rad=0`.
  * `blend`, `fillOverlay`: `blend` attribute required.
  * `clrChange`: `useA=true`.
- `apply_effects_to_color` MUST apply color-mutating effects in declared
  order, producing a final `CfArgb`. Geometric effects MUST be collected
  in declared order in the returned `ResolvedEffectChain.rendered`
  array so a renderer can draw them in the spec sequence (fill →
  fillOverlay → innerShdw → prstShdw → softEdge → blur → glow →
  outerShdw → reflection).
- Required-but-missing attributes raise `SchemaViolation`. Unknown enum
  values (e.g. unknown `blend`, `algn`, preset shadow name) raise
  `SchemaViolation` rather than silently defaulting.
- The package imports only `@opc_errors`, `@xml`, `@drawing_ml/domain`
  (`@dml_effects`), `@drawing_ml/color_resolution` (`@color`),
  and core libraries.

## Gates

- `moon check --target native`
- `moon test --target native -p trkbt10/ooxml/ecma376/drawing_ml/effects`
- `moon info && moon fmt`
- `bash .kiro/scripts/drift.sh --pkg ecma376/drawing_ml`
