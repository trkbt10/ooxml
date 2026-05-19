///|
/// §20.1.8.26 applies a decoded effect list to a source ARGB color.
///
/// Color-mutating effects (Tint, Duotone, Lum, Hsl, AlphaModFix,
/// AlphaReplace, AlphaCeiling, AlphaFloor, AlphaInverse, ClrChange,
/// ClrRepl, Grayscale) fold into the running ARGB. Geometric, blend, or
/// outset effects (Blur, Glow, InnerShadow, OuterShadow, PresetShadow,
/// Reflection, SoftEdge, FillOverlay, Blend, AlphaOutset, AlphaBiLevel,
/// BiLevel, RelativeOffset, Transform) are emitted as `RenderEffect`
/// records in declared order. `AlphaMod` (container reference) is
/// treated as identity until effectDag composition is implemented.
pub fn apply_effects(
  effects : Array[Effect],
  source : @color.Rgba8,
) -> ResolvedEffectChain {
  let rendered : Array[RenderEffect] = []
  let mut color = source
  for effect in effects {
    match effect {
      Blur(rad, grow) => rendered.push(RenderEffect::BlurRender(rad, grow))
      Glow(rad, c) => rendered.push(RenderEffect::GlowRender(rad, c))
      InnerShadow(params) =>
        rendered.push(RenderEffect::InnerShadowRender(params))
      OuterShadow(params) =>
        rendered.push(RenderEffect::OuterShadowRender(params))
      PresetShadow(params) =>
        rendered.push(RenderEffect::PresetShadowRender(params))
      Reflection(params) =>
        rendered.push(RenderEffect::ReflectionRender(params))
      SoftEdge(rad) => rendered.push(RenderEffect::SoftEdgeRender(rad))
      FillOverlay(blend) =>
        rendered.push(RenderEffect::FillOverlayRender(blend))
      Blend(blend) => rendered.push(RenderEffect::BlendRender(blend))
      AlphaOutset(rad) => rendered.push(RenderEffect::AlphaOutsetRender(rad))
      AlphaBiLevel(thresh) =>
        rendered.push(RenderEffect::AlphaBiLevelRender(thresh))
      BiLevel(thresh) => rendered.push(RenderEffect::BiLevelRender(thresh))
      RelativeOffset(tx, ty) =>
        rendered.push(RenderEffect::RelativeOffsetRender(tx, ty))
      Transform(params) => rendered.push(RenderEffect::TransformRender(params))
      AlphaModEffect => ()
      AlphaModFix(amt) => color = apply_alpha_mod_fix(color, amt)
      AlphaCeiling => color = apply_alpha_ceiling(color)
      AlphaFloor => color = apply_alpha_floor(color)
      AlphaInverse(replacement) =>
        color = apply_alpha_inverse(color, replacement)
      AlphaReplace(a) => color = apply_alpha_replace(color, a)
      Tint(amt, hue) => color = apply_tint(color, amt, hue)
      Duotone(first, second) => color = apply_duotone(color, first, second)
      Lum(bright, contrast) => color = apply_lum(color, bright, contrast)
      Hsl(hue, sat, lum) => color = apply_hsl(color, hue, sat, lum)
      ClrChange(from, to, use_alpha) =>
        color = apply_clr_change(color, from, to, use_alpha)
      ClrRepl(c) => color = apply_clr_repl(color, c)
      Grayscale => color = apply_grayscale(color)
    }
  }
  { rendered, final_color: color }
}

///|
/// §20.1.8 fold the color-mutating subset of the effect list into the
/// supplied source color, discarding geometric metadata. Convenience
/// shortcut for callers that only care about the final ARGB.
pub fn apply_effects_to_color(
  effects : Array[Effect],
  source : @color.Rgba8,
) -> @color.Rgba8 {
  apply_effects(effects, source).final_color
}
