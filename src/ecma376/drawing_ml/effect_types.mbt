///|
/// XSD complex type CT_ComplementTransform — Part 1 §20.1.8.19 comp.
/// Annex A.4.1 line 270. Empty complex type: the `comp` element's
/// presence alone signals "complement the color"; no attributes or
/// children are allowed. The struct carries a marker so the typed
/// projection is distinguishable from raw XML and survives the
/// ct-typing gate.
pub(all) struct CT_ComplementTransform {
  /// Empty-XSD-type marker (always true once decoded).
  transform : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ComplementTransform::new(
  element : @xml.Element,
) -> CT_ComplementTransform {
  { transform: true, element }
}

///|
pub fn CT_ComplementTransform::to_element(
  self : CT_ComplementTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_InverseTransform — Part 1 §20.1.8.41 inv. Annex
/// A.4.1 line 271. Empty complex type (no attributes/children) per
/// EG_ColorTransform choice arm.
pub(all) struct CT_InverseTransform {
  /// Empty-XSD-type marker (always true once decoded).
  transform : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_InverseTransform::new(element : @xml.Element) -> CT_InverseTransform {
  { transform: true, element }
}

///|
pub fn CT_InverseTransform::to_element(
  self : CT_InverseTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GrayscaleTransform — Part 1 §20.1.8.35 gray.
/// Annex A.4.1 line 272. Empty complex type per EG_ColorTransform
/// choice arm.
pub(all) struct CT_GrayscaleTransform {
  /// Empty-XSD-type marker (always true once decoded).
  transform : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GrayscaleTransform::new(
  element : @xml.Element,
) -> CT_GrayscaleTransform {
  { transform: true, element }
}

///|
pub fn CT_GrayscaleTransform::to_element(
  self : CT_GrayscaleTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GammaTransform — Part 1 §20.1.8.31 gamma. Annex
/// A.4.1 line 273. Empty complex type per EG_ColorTransform choice arm.
pub(all) struct CT_GammaTransform {
  /// Empty-XSD-type marker (always true once decoded).
  transform : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GammaTransform::new(element : @xml.Element) -> CT_GammaTransform {
  { transform: true, element }
}

///|
pub fn CT_GammaTransform::to_element(self : CT_GammaTransform) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_InverseGammaTransform — Part 1 §20.1.8.42
/// invGamma. Annex A.4.1 line 274. Empty complex type per
/// EG_ColorTransform choice arm.
pub(all) struct CT_InverseGammaTransform {
  /// Empty-XSD-type marker (always true once decoded).
  transform : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_InverseGammaTransform::new(
  element : @xml.Element,
) -> CT_InverseGammaTransform {
  { transform: true, element }
}

///|
pub fn CT_InverseGammaTransform::to_element(
  self : CT_InverseGammaTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaBiLevelEffect — Part 1 §20.1.8.1
/// alphaBiLevel. Annex A.4.1 lines 1242..1244. Required `thresh`
/// (ST_PositiveFixedPercentage) — the threshold at or above which
/// alpha snaps to fully opaque.
pub(all) struct CT_AlphaBiLevelEffect {
  /// @thresh — ST_PositiveFixedPercentage (required).
  thresh : ST_PositiveFixedPercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaBiLevelEffect::new(
  element : @xml.Element,
) -> CT_AlphaBiLevelEffect raise SchemaViolation {
  let thresh_lex = ct_required_string(
    element, "thresh", "CT_AlphaBiLevelEffect/@thresh",
  )
  let thresh = ST_PositiveFixedPercentage::parse(thresh_lex)
  { thresh, element }
}

///|
pub fn CT_AlphaBiLevelEffect::to_element(
  self : CT_AlphaBiLevelEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaCeilingEffect — Part 1 §20.1.8.2
/// alphaCeiling. Annex A.4.1 line 1245. Empty complex type — alpha
/// is forced to fully opaque whenever it is non-zero.
pub(all) struct CT_AlphaCeilingEffect {
  /// Empty-XSD-type marker (always true once decoded).
  effect : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaCeilingEffect::new(
  element : @xml.Element,
) -> CT_AlphaCeilingEffect {
  { effect: true, element }
}

///|
pub fn CT_AlphaCeilingEffect::to_element(
  self : CT_AlphaCeilingEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaFloorEffect — Part 1 §20.1.8.3 alphaFloor.
/// Annex A.4.1 line 1246. Empty complex type — alpha is forced to
/// fully transparent whenever it is below full.
pub(all) struct CT_AlphaFloorEffect {
  /// Empty-XSD-type marker (always true once decoded).
  effect : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaFloorEffect::new(element : @xml.Element) -> CT_AlphaFloorEffect {
  { effect: true, element }
}

///|
pub fn CT_AlphaFloorEffect::to_element(
  self : CT_AlphaFloorEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaInverseEffect — Part 1 §20.1.8.4 alphaInv.
/// Annex A.4.1 lines 1247..1251. Optional EG_ColorChoice arm: when
/// present the inverted alpha is replaced with the supplied colour.
pub(all) struct CT_AlphaInverseEffect {
  /// Optional EG_ColorChoice arm captured as a CT_Color projection.
  color : CT_Color?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaInverseEffect::new(
  element : @xml.Element,
) -> CT_AlphaInverseEffect raise SchemaViolation {
  let color = if has_any_color_choice_child(element) {
    Some(CT_Color::new(element))
  } else {
    None
  }
  { color, element }
}

///|
pub fn CT_AlphaInverseEffect::to_element(
  self : CT_AlphaInverseEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaModulateFixedEffect — Part 1 §20.1.8.6
/// alphaModFix. Annex A.4.1 lines 1252..1254. Optional `amt`
/// (ST_PositivePercentage, default 100%) — multiplicative alpha
/// modulation amount.
pub(all) struct CT_AlphaModulateFixedEffect {
  /// @amt — ST_PositivePercentage (optional, default 100%).
  amt : ST_PositivePercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaModulateFixedEffect::new(
  element : @xml.Element,
) -> CT_AlphaModulateFixedEffect raise SchemaViolation {
  let amt = match ct_attr(element, "amt") {
    Some(v) => ST_PositivePercentage::parse(v)
    None => ST_PositivePercentage::parse("100%")
  }
  { amt, element }
}

///|
pub fn CT_AlphaModulateFixedEffect::to_element(
  self : CT_AlphaModulateFixedEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaOutsetEffect — Part 1 §20.1.8.7
/// alphaOutset. Annex A.4.1 lines 1255..1257. Optional `rad`
/// (ST_Coordinate, default 0) — radius of the alpha outset in
/// EMU.
pub(all) struct CT_AlphaOutsetEffect {
  /// @rad — ST_Coordinate (optional, default 0 EMU).
  rad : ST_Coordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaOutsetEffect::new(
  element : @xml.Element,
) -> CT_AlphaOutsetEffect raise SchemaViolation {
  let rad = match ct_attr(element, "rad") {
    Some(v) => ST_Coordinate::parse(v)
    None => ST_Coordinate::parse("0")
  }
  { rad, element }
}

///|
pub fn CT_AlphaOutsetEffect::to_element(
  self : CT_AlphaOutsetEffect,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AlphaReplaceEffect (§20.1.8).
pub(all) struct CT_AlphaReplaceEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaReplaceEffect::new(
  element : @xml.Element,
) -> CT_AlphaReplaceEffect {
  { element, }
}

///|
/// XSD complex type CT_BiLevelEffect (§20.1.8).
pub(all) struct CT_BiLevelEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BiLevelEffect::new(element : @xml.Element) -> CT_BiLevelEffect {
  { element, }
}

///|
/// XSD complex type CT_BlurEffect (§20.1.8).
pub(all) struct CT_BlurEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BlurEffect::new(element : @xml.Element) -> CT_BlurEffect {
  { element, }
}

///|
/// XSD complex type CT_DuotoneEffect (§20.1.8).
pub(all) struct CT_DuotoneEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DuotoneEffect::new(element : @xml.Element) -> CT_DuotoneEffect {
  { element, }
}

///|
/// XSD complex type CT_GlowEffect (§20.1.8).
pub(all) struct CT_GlowEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GlowEffect::new(element : @xml.Element) -> CT_GlowEffect {
  { element, }
}

///|
/// XSD complex type CT_GrayscaleEffect (§20.1.8).
pub(all) struct CT_GrayscaleEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GrayscaleEffect::new(element : @xml.Element) -> CT_GrayscaleEffect {
  { element, }
}

///|
/// XSD complex type CT_HSLEffect (§20.1.8).
pub(all) struct CT_HSLEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HSLEffect::new(element : @xml.Element) -> CT_HSLEffect {
  { element, }
}

///|
/// XSD complex type CT_InnerShadowEffect (§20.1.8).
pub(all) struct CT_InnerShadowEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_InnerShadowEffect::new(
  element : @xml.Element,
) -> CT_InnerShadowEffect {
  { element, }
}

///|
/// XSD complex type CT_LuminanceEffect (§20.1.8).
pub(all) struct CT_LuminanceEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LuminanceEffect::new(element : @xml.Element) -> CT_LuminanceEffect {
  { element, }
}

///|
/// XSD complex type CT_OuterShadowEffect (§20.1.8).
pub(all) struct CT_OuterShadowEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OuterShadowEffect::new(
  element : @xml.Element,
) -> CT_OuterShadowEffect {
  { element, }
}

///|
/// XSD complex type CT_PresetShadowEffect (§20.1.8).
pub(all) struct CT_PresetShadowEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresetShadowEffect::new(
  element : @xml.Element,
) -> CT_PresetShadowEffect {
  { element, }
}

///|
/// XSD complex type CT_ReflectionEffect (§20.1.8).
pub(all) struct CT_ReflectionEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ReflectionEffect::new(element : @xml.Element) -> CT_ReflectionEffect {
  { element, }
}

///|
/// XSD complex type CT_RelativeOffsetEffect (§20.1.8).
pub(all) struct CT_RelativeOffsetEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RelativeOffsetEffect::new(
  element : @xml.Element,
) -> CT_RelativeOffsetEffect {
  { element, }
}

///|
/// XSD complex type CT_SoftEdgesEffect (§20.1.8).
pub(all) struct CT_SoftEdgesEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SoftEdgesEffect::new(element : @xml.Element) -> CT_SoftEdgesEffect {
  { element, }
}

///|
/// XSD complex type CT_TintEffect (§20.1.8).
pub(all) struct CT_TintEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TintEffect::new(element : @xml.Element) -> CT_TintEffect {
  { element, }
}

///|
/// XSD complex type CT_TransformEffect (§20.1.8).
pub(all) struct CT_TransformEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TransformEffect::new(element : @xml.Element) -> CT_TransformEffect {
  { element, }
}

///|
/// XSD complex type CT_FillEffect (§20.1.8).
pub(all) struct CT_FillEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FillEffect::new(element : @xml.Element) -> CT_FillEffect {
  { element, }
}

///|
/// XSD complex type CT_FillOverlayEffect (§20.1.8).
pub(all) struct CT_FillOverlayEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FillOverlayEffect::new(
  element : @xml.Element,
) -> CT_FillOverlayEffect {
  { element, }
}

///|
/// XSD complex type CT_EffectReference (§20.1.8).
pub(all) struct CT_EffectReference {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectReference::new(element : @xml.Element) -> CT_EffectReference {
  { element, }
}

///|
/// XSD complex type CT_EffectContainer (§20.1.8).
pub(all) struct CT_EffectContainer {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectContainer::new(element : @xml.Element) -> CT_EffectContainer {
  { element, }
}

///|
/// XSD complex type CT_AlphaModulateEffect (§20.1.8).
pub(all) struct CT_AlphaModulateEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AlphaModulateEffect::new(
  element : @xml.Element,
) -> CT_AlphaModulateEffect {
  { element, }
}

///|
/// XSD complex type CT_BlendEffect (§20.1.8).
pub(all) struct CT_BlendEffect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BlendEffect::new(element : @xml.Element) -> CT_BlendEffect {
  { element, }
}

///|
/// XSD complex type CT_EffectList (§20.1.8).
pub(all) struct CT_EffectList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectList::new(element : @xml.Element) -> CT_EffectList {
  { element, }
}

///|
/// XSD complex type CT_EffectProperties (§20.1.8).
pub(all) struct CT_EffectProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectProperties::new(element : @xml.Element) -> CT_EffectProperties {
  { element, }
}

///|
pub fn read_blur_effect(bytes : Bytes) -> CT_BlurEffect raise {
  CT_BlurEffect::new(read_main_root(bytes, "blur"))
}

///|
pub fn write_blur_effect(value : CT_BlurEffect) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_outer_shadow_effect(bytes : Bytes) -> CT_OuterShadowEffect raise {
  CT_OuterShadowEffect::new(read_main_root(bytes, "outerShdw"))
}

///|
pub fn write_outer_shadow_effect(value : CT_OuterShadowEffect) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_effect_list(bytes : Bytes) -> CT_EffectList raise {
  CT_EffectList::new(read_main_root(bytes, "effectLst"))
}

///|
pub fn write_effect_list(value : CT_EffectList) -> Bytes {
  write_element(value.element)
}
