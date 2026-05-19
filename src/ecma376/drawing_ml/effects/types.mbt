///|
/// §20.1.10.11 ST_BlendMode discriminator. Used by `blend` (§20.1.8.12)
/// and `fillOverlay` (§20.1.8.29).
pub(all) enum BlendMode {
  /// Composites the source over the destination (default).
  Over
  /// Multiplies the source and destination colors.
  Mult
  /// Inverts both inputs, multiplies, then inverts again.
  Screen
  /// Picks the darker of source and destination per channel.
  Darken
  /// Picks the lighter of source and destination per channel.
  Lighten
} derive(Eq, Debug)

///|
/// §20.1.10.53 ST_RectAlignment discriminator. Used by `outerShdw`
/// (§20.1.8.45) and `reflection` (§20.1.8.50) via `algn`.
pub(all) enum ShadowAlign {
  /// `tl` top-left.
  Tl
  /// `t` top-center.
  T
  /// `tr` top-right.
  Tr
  /// `l` middle-left.
  L
  /// `ctr` center.
  Ctr
  /// `r` middle-right.
  R
  /// `bl` bottom-left.
  Bl
  /// `b` bottom-center.
  B
  /// `br` bottom-right.
  Br
} derive(Eq, Debug)

///|
/// §20.1.10.52 ST_PresetShadowVal discriminator. Used by `prstShdw`
/// (§20.1.8.49).
pub(all) enum PresetShadowKind {
  Shdw1
  Shdw2
  Shdw3
  Shdw4
  Shdw5
  Shdw6
  Shdw7
  Shdw8
  Shdw9
  Shdw10
  Shdw11
  Shdw12
  Shdw13
  Shdw14
  Shdw15
  Shdw16
  Shdw17
  Shdw18
  Shdw19
  Shdw20
} derive(Eq, Debug)

///|
/// §20.1.8.40 innerShdw parameters.
pub(all) struct InnerShadowParams {
  blur_rad : Int
  dist : Int
  dir : Int
  color : @color.Rgba8
} derive(Eq, Debug)

///|
/// §20.1.8.45 outerShdw parameters.
pub(all) struct OuterShadowParams {
  blur_rad : Int
  dist : Int
  dir : Int
  sx : Int
  sy : Int
  kx : Int
  ky : Int
  algn : ShadowAlign
  rot_with_shape : Bool
  color : @color.Rgba8
} derive(Eq, Debug)

///|
/// §20.1.8.49 prstShdw parameters. The `prst` discriminator selects one
/// of 20 preset outer-shadow templates; `dir`, `dist`, and `color` carry
/// per-instance overrides.
pub(all) struct PresetShadowParams {
  prst : PresetShadowKind
  dir : Int
  dist : Int
  color : @color.Rgba8
} derive(Eq, Debug)

///|
/// §20.1.8.50 reflection parameters.
pub(all) struct ReflectionParams {
  blur_rad : Int
  st_a : Int
  st_pos : Int
  end_a : Int
  end_pos : Int
  dist : Int
  dir : Int
  fade_dir : Int
  sx : Int
  sy : Int
  kx : Int
  ky : Int
  algn : ShadowAlign
  rot_with_shape : Bool
} derive(Eq, Debug)

///|
/// §20.1.8.61 xfrm parameters.
pub(all) struct TransformParams {
  sx : Int
  sy : Int
  kx : Int
  ky : Int
  tx : Int
  ty : Int
} derive(Eq, Debug)

///|
/// §20.1.8 decoded effect entry. Color-only effects (Tint, Duotone,
/// Lum, Hsl, AlphaMod, AlphaModFix, AlphaReplace, ClrChange, ClrRepl,
/// Grayscale) fold into the final ARGB; geometric / opacity / blend
/// effects emit a matching `RenderEffect` for the renderer.
pub(all) enum Effect {
  /// §20.1.8.15 blur.
  Blur(Int, Bool)
  /// §20.1.8.32 glow.
  Glow(Int, @color.Rgba8)
  /// §20.1.8.40 innerShdw.
  InnerShadow(InnerShadowParams)
  /// §20.1.8.45 outerShdw.
  OuterShadow(OuterShadowParams)
  /// §20.1.8.49 prstShdw.
  PresetShadow(PresetShadowParams)
  /// §20.1.8.50 reflection.
  Reflection(ReflectionParams)
  /// §20.1.8.53 softEdge.
  SoftEdge(Int)
  /// §20.1.8.60 tint(amt, hue).
  Tint(Int, Int)
  /// §20.1.8.23 duotone(first, second).
  Duotone(@color.Rgba8, @color.Rgba8)
  /// §20.1.8.42 lum(bright, contrast).
  Lum(Int, Int)
  /// §20.1.8.39 hsl(hue, sat, lum).
  Hsl(Int, Int, Int)
  /// §20.1.8.29 fillOverlay(blend).
  FillOverlay(BlendMode)
  /// §20.1.8.5 alphaMod: container reference, treated as identity in
  /// this pass.
  AlphaModEffect
  /// §20.1.8.6 alphaModFix(amt).
  AlphaModFix(Int)
  /// §20.1.8.2 alphaCeiling.
  AlphaCeiling
  /// §20.1.8.3 alphaFloor.
  AlphaFloor
  /// §20.1.8.4 alphaInv(optional color override).
  AlphaInverse(@color.Rgba8?)
  /// §20.1.8.8 alphaRepl(a).
  AlphaReplace(Int)
  /// §20.1.8.7 alphaOutset(rad).
  AlphaOutset(Int)
  /// §20.1.8.1 alphaBiLevel(thresh).
  AlphaBiLevel(Int)
  /// §20.1.8.11 biLevel(thresh).
  BiLevel(Int)
  /// §20.1.8.12 blend(blend).
  Blend(BlendMode)
  /// §20.1.8.16 clrChange(from, to, useA).
  ClrChange(@color.Rgba8, @color.Rgba8, Bool)
  /// §20.1.8.18 clrRepl(color).
  ClrRepl(@color.Rgba8)
  /// §20.1.8.34 grayscl.
  Grayscale
  /// §20.1.8.51 relOff(tx, ty).
  RelativeOffset(Int, Int)
  /// §20.1.8.61 xfrm.
  Transform(TransformParams)
} derive(Eq, Debug)

///|
/// §20.1.8 effect entry that a renderer must draw (anything that is not
/// purely a per-pixel color/alpha mutation). Emitted in declared order
/// by `apply_effects`.
pub(all) enum RenderEffect {
  /// §20.1.8.15 blur.
  BlurRender(Int, Bool)
  /// §20.1.8.32 glow.
  GlowRender(Int, @color.Rgba8)
  /// §20.1.8.40 innerShdw.
  InnerShadowRender(InnerShadowParams)
  /// §20.1.8.45 outerShdw.
  OuterShadowRender(OuterShadowParams)
  /// §20.1.8.49 prstShdw.
  PresetShadowRender(PresetShadowParams)
  /// §20.1.8.50 reflection.
  ReflectionRender(ReflectionParams)
  /// §20.1.8.53 softEdge.
  SoftEdgeRender(Int)
  /// §20.1.8.29 fillOverlay.
  FillOverlayRender(BlendMode)
  /// §20.1.8.12 blend.
  BlendRender(BlendMode)
  /// §20.1.8.7 alphaOutset.
  AlphaOutsetRender(Int)
  /// §20.1.8.1 alphaBiLevel.
  AlphaBiLevelRender(Int)
  /// §20.1.8.11 biLevel.
  BiLevelRender(Int)
  /// §20.1.8.51 relOff.
  RelativeOffsetRender(Int, Int)
  /// §20.1.8.61 xfrm.
  TransformRender(TransformParams)
} derive(Eq, Debug)

///|
/// §20.1.8.26 result of applying a decoded effect list against a source
/// ARGB color. `rendered` lists the geometric / blend / outset effects
/// in declared order so a downstream renderer can paint them; the
/// caller is expected to draw them in the §20.1.8.26 default order
/// (shape fill → fillOverlay → innerShdw / prstShdw → softEdge → blur
/// → glow → outerShdw → reflection).
pub(all) struct ResolvedEffectChain {
  rendered : Array[RenderEffect]
  final_color : @color.Rgba8
} derive(Eq, Debug)
