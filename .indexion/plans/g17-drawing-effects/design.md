# G17 Drawing Effects Design

## Package

`src/ecma376/drawing_ml/effects` is a self-contained DrawingML subpackage
sitting alongside `color_resolution`. It owns the public `Effect` enum,
geometric `RenderEffect` records, and the `apply_effects` /
`apply_effects_to_color` API.

## Type Model

```
pub(all) enum Effect {
  Blur({ rad : Int, grow : Bool })
  Glow({ rad : Int, color : @color.Rgba8 })
  InnerShadow(InnerShadowParams)
  OuterShadow(OuterShadowParams)
  PresetShadow(PresetShadowParams)
  Reflection(ReflectionParams)
  SoftEdge({ rad : Int })
  Tint({ amt : Int, hue : Int })
  Duotone({ first : @color.Rgba8, second : @color.Rgba8 })
  Lum({ bright : Int, contrast : Int })
  Hsl({ hue : Int, sat : Int, lum : Int })
  FillOverlay({ blend : BlendMode })
  AlphaMod  // container reference, treated as identity in this pass
  AlphaModFix({ amt : Int })
  AlphaCeiling
  AlphaFloor
  AlphaInv({ color : @color.Rgba8? })
  AlphaReplace({ a : Int })
  AlphaOutset({ rad : Int })
  AlphaBiLevel({ thresh : Int })
  BiLevel({ thresh : Int })
  Blend({ blend : BlendMode })
  ClrChange({ from : @color.Rgba8, to : @color.Rgba8, use_alpha : Bool })
  ClrRepl({ color : @color.Rgba8 })
  Grayscale
  RelativeOffset({ tx : Int, ty : Int })
  Transform(TransformParams)
}
```

`BlendMode` mirrors §20.1.10.11 (`Over`, `Mult`, `Screen`, `Darken`,
`Lighten`). Shadow alignment uses §20.1.10.53
(`ShadowAlign::{ Tl, T, Tr, L, Ctr, R, Bl, B, Br }`).

`RenderEffect` is a thin descriptor that downstream renderers use:

```
pub(all) enum RenderEffect {
  BlurRender({ rad : Int, grow : Bool })
  GlowRender({ rad : Int, color : @color.Rgba8 })
  InnerShadowRender(InnerShadowParams)
  OuterShadowRender(OuterShadowParams)
  PresetShadowRender(PresetShadowParams)
  ReflectionRender(ReflectionParams)
  SoftEdgeRender({ rad : Int })
  FillOverlayRender({ blend : BlendMode })
  BlendRender({ blend : BlendMode })
  AlphaOutsetRender({ rad : Int })
  AlphaBiLevelRender({ thresh : Int })
  BiLevelRender({ thresh : Int })
  RelativeOffsetRender({ tx : Int, ty : Int })
  TransformRender(TransformParams)
}
```

The split is intentional: color-only effects (`Tint`, `Duotone`, `Lum`,
`Hsl`, `AlphaMod*`, `ClrChange`, `ClrRepl`, `Grayscale`) never appear in
`rendered` because they fold into the final ARGB; geometric effects
never mutate the working color but appear in `rendered` in declared
order.

## Decoder

`decode_effect_list(@dml_effects.CT_EffectList) -> Array[Effect]` walks
`element.children`, dispatches on `local_name`, and reads attributes via
small helpers (`parse_int_attr`, `parse_percentage_attr`,
`parse_bool_attr`). Color children (`outerShdw>srgbClr`, etc.) are
decoded by calling `@color.read_color_ref` and immediately resolving
against a caller-supplied placeholder color and theme scheme.

`decode_effect_list` accepts a `Context` struct holding the active
`@color.ColorScheme` and an optional placeholder `@color.Rgba8`. This
mirrors how §20.1.6 + §20.1.2.3 already work in `color_resolution`.

## Application

```
pub fn apply_effects(
  effects : Array[Effect],
  source : @color.Rgba8,
) -> ResolvedEffectChain
```

walks `effects`, mutating an accumulator `Rgba8` for color-mutating
entries and pushing `RenderEffect` records for geometric entries.
`ResolvedEffectChain` is `{ rendered : Array[RenderEffect], final_color :
@color.Rgba8 }`.

Color math notes:

- `Tint(amt, hue)`: shift hue toward the target by `amt` (signed
  percentage in HSL hue space). Implemented as
  `H' = lerp(H, hue, |amt|/100000)`.
- `Lum(bright, contrast)`: brightness is `L' = clamp(L + bright/100000)`;
  contrast multiplies `(L - 0.5) * (1 + contrast/100000) + 0.5`.
- `Hsl(hue, sat, lum)`: relative adjustment, each shifts the
  corresponding channel by the percentage.
- `Duotone({first, second})`: `output = mix(first, second, luminance)`.
- `ClrChange`: pixel-exact map; only single-color sources match (the
  decoded source ARGB equals `from`).
- `ClrRepl`: pixel becomes `to.rgb`; alpha is preserved (per spec).
- `Grayscale`: 0.2126/0.7152/0.0722 luminance, applied to RGB.
- `AlphaModFix(amt)`: `A' = clamp(A * amt/100000)`.
- `AlphaReplace(a)`: `A' = a/100000 * 255`.
- `AlphaMod` (container reference): identity in this pass; the spec
  requires re-applying child effect tree's alpha, which is renderer
  territory.

## Reuse Boundary

The implementation reuses `color_resolution`'s `Rgba8`, `parse_srgb_hex`,
and `read_color_ref` + `resolve_color`. The HSL math required for `Tint`,
`Lum`, `Hsl`, `Duotone`, and `Grayscale` is duplicated locally — the
`color_resolution` package only exposes the transform interpreter, not
the raw HSL conversion helpers. A `// TODO(consolidate)` note in
`color_transforms.mbt` flags the future merge.

## Out of Scope

- Animations (§20.1.8 frame interpolation).
- Effect DAG composition (`effectDag`, `cont`, `effect`) — only the
  flat `effectLst` form is in scope.
- Actual pixel rasterisation — the geometric effects emit metadata only.
