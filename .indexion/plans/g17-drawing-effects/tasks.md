# G17 Drawing Effects Tasks

- [x] Read §20.1.8.1 through §20.1.8.61 to inventory effect elements and
      attributes.
- [x] Add `src/ecma376/drawing_ml/effects` package skeleton.
- [x] Define `Effect`, `RenderEffect`, blend mode, shadow align,
      preset shadow, and parameter records in `types.mbt`.
- [x] Implement attribute helpers, color child decoding, and
      `decode_effect_list` in `decode.mbt`.
- [x] Implement HSL conversion helpers and color-mutating math in
      `color_transforms.mbt`.
- [x] Implement `apply_effects` chain in `apply.mbt`, returning a
      `ResolvedEffectChain { rendered, final_color }`.
- [x] White-box tests under `apply_wbtest.mbt` covering:
      - per-effect decode (every recognised element).
      - tint/lum/grayscale/clrChange/clrRepl/alphaModFix color math.
      - chain ordering for outerShdw + glow + reflection
        (3 RenderEffect entries, correct discriminator).
      - schema error on missing required attribute and unknown element.
- [x] `moon info && moon fmt`.
- [x] `moon check --target native`, `moon test --target native -p
      trkbt10/ooxml/ecma376/drawing_ml/effects`.
- [x] `bash .kiro/scripts/drift.sh --pkg ecma376/drawing_ml`.
- [x] Single commit `g17-drawing-effects: §20.1.8 drawing effects
      application`.
