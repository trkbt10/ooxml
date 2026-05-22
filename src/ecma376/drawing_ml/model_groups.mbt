///|
/// XSD attribute group AG_Blob (§20.1): r:embed, r:link.
pub(all) struct AG_Blob {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Blob::new(element : @xml.Element) -> AG_Blob {
  { element, }
}

///|
pub fn AG_Blob::attribute_names(self : AG_Blob) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_Blob::has_attribute(self : AG_Blob, name : String) -> Bool {
  for attribute in self.element.attributes {
    if attribute.name.local_name == name {
      return true
    }
  }
  false
}

///|
/// XSD attribute group AG_Locking (§20.1): noGrp, noSelect, noRot, noChangeAspect, noMove, noResize, noEditPoints, noAdjustHandles, noChangeArrowheads, noChangeShapeType.
pub(all) struct AG_Locking {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Locking::new(element : @xml.Element) -> AG_Locking {
  { element, }
}

///|
pub fn AG_Locking::attribute_names(self : AG_Locking) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_Locking::has_attribute(self : AG_Locking, name : String) -> Bool {
  for attribute in self.element.attributes {
    if attribute.name.local_name == name {
      return true
    }
  }
  false
}

///|
/// XSD model group EG_Media — Part 1 §20.1.2.2.39 / Annex A.4.1
/// (dml-main.xsd). Single-choice group with 5 arms used by
/// CT_NonVisualPictureProperties and §21.1 text bodies to attach
/// embedded media to a picture / shape.
pub(all) enum EG_Media {
  /// <a:audioCd> — CT_AudioCD
  AudioCd(CT_AudioCD)
  /// <a:wavAudioFile> — CT_EmbeddedWAVAudioFile
  WavAudioFile(CT_EmbeddedWAVAudioFile)
  /// <a:audioFile> — CT_AudioFile
  AudioFile(CT_AudioFile)
  /// <a:videoFile> — CT_VideoFile
  VideoFile(CT_VideoFile)
  /// <a:quickTimeFile> — CT_QuickTimeFile
  QuickTimeFile(CT_QuickTimeFile)
} derive(Eq, Debug)

///|
/// Parse a single EG_Media child element. Returns `None` for unknown
/// local names (forward compatibility); known names with malformed
/// attributes raise SchemaViolation.
pub fn parse_media_child(
  element : @xml.Element,
) -> EG_Media? raise SchemaViolation {
  match element.name.local_name {
    "audioCd" => Some(AudioCd(CT_AudioCD::new(element)))
    "wavAudioFile" => Some(WavAudioFile(CT_EmbeddedWAVAudioFile::new(element)))
    "audioFile" => Some(AudioFile(CT_AudioFile::new(element)))
    "videoFile" => Some(VideoFile(CT_VideoFile::new(element)))
    "quickTimeFile" => Some(QuickTimeFile(CT_QuickTimeFile::new(element)))
    _ => None
  }
}

///|
/// Find an EG_Media child inside `element` (the typical container is
/// `<p:nvPicPr>/<p:cNvPicPr>` or similar). Returns the first matching
/// arm; `None` when no media child is present.
pub fn find_media_child(
  element : @xml.Element,
) -> EG_Media? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_media_child(child) {
          Some(m) => return Some(m)
          None => ()
        }
      _ => ()
    }
  }
  None
}

///|
/// XSD model group EG_ColorTransform — Part 1 §20.1.2.3.27 / Annex
/// A.4.1 lines 56..84 (dml-main.xsd). 28-arm choice every `CT_*Color`
/// repeats unboundedly. Each arm carries the typed projection of its
/// leaf complex type so callers compose color-transform chains
/// without re-parsing the underlying XML.
pub(all) enum EG_ColorTransform {
  /// <a:tint val="..."> — Annex A.4.1 line 57.
  Tint(CT_PositiveFixedPercentage)
  /// <a:shade val="..."> — Annex A.4.1 line 58.
  Shade(CT_PositiveFixedPercentage)
  /// <a:comp/> — Annex A.4.1 line 59 (CT_ComplementTransform, empty).
  Comp(CT_ComplementTransform)
  /// <a:inv/> — Annex A.4.1 line 60 (CT_InverseTransform, empty).
  Inv(CT_InverseTransform)
  /// <a:gray/> — Annex A.4.1 line 61 (CT_GrayscaleTransform, empty).
  Gray(CT_GrayscaleTransform)
  /// <a:alpha val="..."> — Annex A.4.1 line 62.
  Alpha(CT_PositiveFixedPercentage)
  /// <a:alphaOff val="..."> — Annex A.4.1 line 63.
  AlphaOff(CT_FixedPercentage)
  /// <a:alphaMod val="..."> — Annex A.4.1 line 64.
  AlphaMod(CT_PositivePercentage)
  /// <a:hue val="..."> — Annex A.4.1 line 65.
  Hue(CT_PositiveFixedAngle)
  /// <a:hueOff val="..."> — Annex A.4.1 line 66.
  HueOff(CT_Angle)
  /// <a:hueMod val="..."> — Annex A.4.1 line 67.
  HueMod(CT_PositivePercentage)
  /// <a:sat val="..."> — Annex A.4.1 line 68.
  Sat(CT_Percentage)
  /// <a:satOff val="..."> — Annex A.4.1 line 69.
  SatOff(CT_Percentage)
  /// <a:satMod val="..."> — Annex A.4.1 line 70.
  SatMod(CT_Percentage)
  /// <a:lum val="..."> — Annex A.4.1 line 71.
  Lum(CT_Percentage)
  /// <a:lumOff val="..."> — Annex A.4.1 line 72.
  LumOff(CT_Percentage)
  /// <a:lumMod val="..."> — Annex A.4.1 line 73.
  LumMod(CT_Percentage)
  /// <a:red val="..."> — Annex A.4.1 line 74.
  Red(CT_Percentage)
  /// <a:redOff val="..."> — Annex A.4.1 line 75.
  RedOff(CT_Percentage)
  /// <a:redMod val="..."> — Annex A.4.1 line 76.
  RedMod(CT_Percentage)
  /// <a:green val="..."> — Annex A.4.1 line 77.
  Green(CT_Percentage)
  /// <a:greenOff val="..."> — Annex A.4.1 line 78.
  GreenOff(CT_Percentage)
  /// <a:greenMod val="..."> — Annex A.4.1 line 79.
  GreenMod(CT_Percentage)
  /// <a:blue val="..."> — Annex A.4.1 line 80.
  Blue(CT_Percentage)
  /// <a:blueOff val="..."> — Annex A.4.1 line 81.
  BlueOff(CT_Percentage)
  /// <a:blueMod val="..."> — Annex A.4.1 line 82.
  BlueMod(CT_Percentage)
  /// <a:gamma/> — Annex A.4.1 line 83 (CT_GammaTransform, empty).
  Gamma(CT_GammaTransform)
  /// <a:invGamma/> — Annex A.4.1 line 84 (CT_InverseGammaTransform, empty).
  InvGamma(CT_InverseGammaTransform)
} derive(Eq, Debug)

///|
/// Parse a single EG_ColorTransform child element. Returns `None`
/// when the element's local name is not one of the 28 arms — the
/// caller then ignores it (xsd:any forward-compatibility). Known
/// arms with malformed leaf attributes raise SchemaViolation.
pub fn parse_color_transform_child(
  element : @xml.Element,
) -> EG_ColorTransform? raise SchemaViolation {
  match element.name.local_name {
    "tint" => Some(Tint(CT_PositiveFixedPercentage::new(element)))
    "shade" => Some(Shade(CT_PositiveFixedPercentage::new(element)))
    "comp" => Some(Comp(CT_ComplementTransform::new(element)))
    "inv" => Some(Inv(CT_InverseTransform::new(element)))
    "gray" => Some(Gray(CT_GrayscaleTransform::new(element)))
    "alpha" => Some(Alpha(CT_PositiveFixedPercentage::new(element)))
    "alphaOff" => Some(AlphaOff(CT_FixedPercentage::new(element)))
    "alphaMod" => Some(AlphaMod(CT_PositivePercentage::new(element)))
    "hue" => Some(Hue(CT_PositiveFixedAngle::new(element)))
    "hueOff" => Some(HueOff(CT_Angle::new(element)))
    "hueMod" => Some(HueMod(CT_PositivePercentage::new(element)))
    "sat" => Some(Sat(CT_Percentage::new(element)))
    "satOff" => Some(SatOff(CT_Percentage::new(element)))
    "satMod" => Some(SatMod(CT_Percentage::new(element)))
    "lum" => Some(Lum(CT_Percentage::new(element)))
    "lumOff" => Some(LumOff(CT_Percentage::new(element)))
    "lumMod" => Some(LumMod(CT_Percentage::new(element)))
    "red" => Some(Red(CT_Percentage::new(element)))
    "redOff" => Some(RedOff(CT_Percentage::new(element)))
    "redMod" => Some(RedMod(CT_Percentage::new(element)))
    "green" => Some(Green(CT_Percentage::new(element)))
    "greenOff" => Some(GreenOff(CT_Percentage::new(element)))
    "greenMod" => Some(GreenMod(CT_Percentage::new(element)))
    "blue" => Some(Blue(CT_Percentage::new(element)))
    "blueOff" => Some(BlueOff(CT_Percentage::new(element)))
    "blueMod" => Some(BlueMod(CT_Percentage::new(element)))
    "gamma" => Some(Gamma(CT_GammaTransform::new(element)))
    "invGamma" => Some(InvGamma(CT_InverseGammaTransform::new(element)))
    _ => None
  }
}

///|
/// Collect every EG_ColorTransform child of a color-bearing element
/// (CT_ScRgbColor / CT_SRgbColor / CT_HslColor / CT_SystemColor /
/// CT_SchemeColor / CT_PresetColor). Returns them in document order;
/// unknown / xsd:any children are silently skipped.
pub fn collect_color_transforms(
  element : @xml.Element,
) -> Array[EG_ColorTransform] raise SchemaViolation {
  let result : Array[EG_ColorTransform] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_color_transform_child(child) {
          Some(t) => result.push(t)
          None => ()
        }
      _ => ()
    }
  }
  result
}


// ─────────────────────────────────────────────────────────────────────
// EG_OfficeArtExtensionList — Part 1 §20.1.2.2.15 (extLst wrapper).
// Single arm <a:ext>* (CT_OfficeArtExtension, unbounded).
// ─────────────────────────────────────────────────────────────────────

///|
/// XSD model group EG_OfficeArtExtensionList — Annex A.4.1
/// (dml-main.xsd). Wraps an unbounded sequence of <a:ext>
/// (CT_OfficeArtExtension) children.
pub(all) struct EG_OfficeArtExtensionList {
  /// <a:ext>* — zero or more CT_OfficeArtExtension entries in
  /// document order.
  extensions : Array[CT_OfficeArtExtension]
} derive(Eq, Debug)

///|
pub fn EG_OfficeArtExtensionList::new(
  element : @xml.Element,
) -> EG_OfficeArtExtensionList raise SchemaViolation {
  let extensions : Array[CT_OfficeArtExtension] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "ext" {
        extensions.push(CT_OfficeArtExtension::new(child_element))
      }
    }
  }
  { extensions, }
}

// ─────────────────────────────────────────────────────────────────────
// EG_ColorChoice — Part 1 §20.1.2.3.4 (the 6-arm color choice).
// ─────────────────────────────────────────────────────────────────────

///|
/// XSD model group EG_ColorChoice — 6-arm choice (scrgbClr / srgbClr /
/// hslClr / sysClr / schemeClr / prstClr). Used by CT_Color,
/// CT_CustomColor, CT_ColorReplaceEffect, and CT_SolidColorFillProperties.
pub(all) enum EG_ColorChoice {
  ScrgbClr(CT_ScRgbColor)
  SrgbClr(CT_SRgbColor)
  HslClr(CT_HslColor)
  SysClr(CT_SystemColor)
  SchemeClr(CT_SchemeColor)
  PrstClr(CT_PresetColor)
} derive(Eq, Debug)

///|
pub fn parse_color_choice_child(
  element : @xml.Element,
) -> EG_ColorChoice? raise SchemaViolation {
  match element.name.local_name {
    "scrgbClr" => Some(ScrgbClr(CT_ScRgbColor::new(element)))
    "srgbClr" => Some(SrgbClr(CT_SRgbColor::new(element)))
    "hslClr" => Some(HslClr(CT_HslColor::new(element)))
    "sysClr" => Some(SysClr(CT_SystemColor::new(element)))
    "schemeClr" => Some(SchemeClr(CT_SchemeColor::new(element)))
    "prstClr" => Some(PrstClr(CT_PresetColor::new(element)))
    _ => None
  }
}

///|
pub fn find_color_choice_child(
  element : @xml.Element,
) -> EG_ColorChoice? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_color_choice_child(child) {
          Some(c) => return Some(c)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_Text3D — Part 1 §21.1.2.4 (sp3d / flatTx choice).
// ─────────────────────────────────────────────────────────────────────

///|
/// XSD model group EG_Text3D — 2-arm choice for <a:bodyPr>'s 3D facet.
pub(all) enum EG_Text3D {
  Sp3d(CT_Shape3D)
  FlatTx(CT_FlatText)
} derive(Eq, Debug)

///|
pub fn parse_text3d_child(
  element : @xml.Element,
) -> EG_Text3D? raise SchemaViolation {
  match element.name.local_name {
    "sp3d" => Some(Sp3d(CT_Shape3D::new(element)))
    "flatTx" => Some(FlatTx(CT_FlatText::new(element)))
    _ => None
  }
}

///|
pub fn find_text3d_child(
  element : @xml.Element,
) -> EG_Text3D? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_text3d_child(child) {
          Some(t) => return Some(t)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_ShadeProperties — Part 1 §20.1.8.33 (gradient shade kind).
// ─────────────────────────────────────────────────────────────────────

///|
/// XSD model group EG_ShadeProperties — 2-arm choice (lin / path).
pub(all) enum EG_ShadeProperties {
  Lin(CT_LinearShadeProperties)
  Path(CT_PathShadeProperties)
} derive(Eq, Debug)

///|
pub fn parse_shade_properties_child(
  element : @xml.Element,
) -> EG_ShadeProperties? raise SchemaViolation {
  match element.name.local_name {
    "lin" => Some(Lin(CT_LinearShadeProperties::new(element)))
    "path" => Some(Path(CT_PathShadeProperties::new(element)))
    _ => None
  }
}

///|
pub fn find_shade_properties_child(
  element : @xml.Element,
) -> EG_ShadeProperties? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_shade_properties_child(child) {
          Some(s) => return Some(s)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_FillModeProperties — Part 1 §20.1.8.13 (blipFill mode).
// ─────────────────────────────────────────────────────────────────────

///|
/// XSD model group EG_FillModeProperties — 2-arm choice (tile / stretch).
pub(all) enum EG_FillModeProperties {
  Tile(CT_TileInfoProperties)
  Stretch(CT_StretchInfoProperties)
} derive(Eq, Debug)

///|
pub fn parse_fill_mode_properties_child(
  element : @xml.Element,
) -> EG_FillModeProperties? raise SchemaViolation {
  match element.name.local_name {
    "tile" => Some(Tile(CT_TileInfoProperties::new(element)))
    "stretch" => Some(Stretch(CT_StretchInfoProperties::new(element)))
    _ => None
  }
}

///|
pub fn find_fill_mode_properties_child(
  element : @xml.Element,
) -> EG_FillModeProperties? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_fill_mode_properties_child(child) {
          Some(f) => return Some(f)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_FillProperties — Part 1 §20.1.8 (shape fill choice).
// 6 arms: noFill / solidFill / gradFill / blipFill / pattFill / grpFill.
// ─────────────────────────────────────────────────────────────────────

///|
/// XSD model group EG_FillProperties — Part 1 §20.1.8.
pub(all) enum EG_FillProperties {
  NoFill(CT_NoFillProperties)
  SolidFill(CT_SolidColorFillProperties)
  GradFill(CT_GradientFillProperties)
  BlipFill(CT_BlipFillProperties)
  PattFill(CT_PatternFillProperties)
  GrpFill(CT_GroupFillProperties)
} derive(Eq, Debug)

///|
pub fn parse_fill_properties_child(
  element : @xml.Element,
) -> EG_FillProperties? raise SchemaViolation {
  match element.name.local_name {
    "noFill" => Some(NoFill(CT_NoFillProperties::new(element)))
    "solidFill" => Some(SolidFill(CT_SolidColorFillProperties::new(element)))
    "gradFill" => Some(GradFill(CT_GradientFillProperties::new(element)))
    "blipFill" => Some(BlipFill(CT_BlipFillProperties::new(element)))
    "pattFill" => Some(PattFill(CT_PatternFillProperties::new(element)))
    "grpFill" => Some(GrpFill(CT_GroupFillProperties::new(element)))
    _ => None
  }
}

///|
pub fn find_fill_properties_child(
  element : @xml.Element,
) -> EG_FillProperties? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_fill_properties_child(child) {
          Some(f) => return Some(f)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_Effect — Part 1 §20.1.8 (effect container choice). 30 arms.
// ─────────────────────────────────────────────────────────────────────

///|
/// XSD model group EG_Effect — Part 1 §20.1.8.
pub(all) enum EG_Effect {
  Cont(CT_EffectContainer)
  Effect(CT_EffectReference)
  AlphaBiLevel(CT_AlphaBiLevelEffect)
  AlphaCeiling(CT_AlphaCeilingEffect)
  AlphaFloor(CT_AlphaFloorEffect)
  AlphaInv(CT_AlphaInverseEffect)
  AlphaMod(CT_AlphaModulateEffect)
  AlphaModFix(CT_AlphaModulateFixedEffect)
  AlphaOutset(CT_AlphaOutsetEffect)
  AlphaRepl(CT_AlphaReplaceEffect)
  BiLevel(CT_BiLevelEffect)
  Blend(CT_BlendEffect)
  Blur(CT_BlurEffect)
  ClrChange(CT_ColorChangeEffect)
  ClrRepl(CT_ColorReplaceEffect)
  Duotone(CT_DuotoneEffect)
  Fill(CT_FillEffect)
  FillOverlay(CT_FillOverlayEffect)
  Glow(CT_GlowEffect)
  Grayscl(CT_GrayscaleEffect)
  Hsl(CT_HSLEffect)
  InnerShdw(CT_InnerShadowEffect)
  Lum(CT_LuminanceEffect)
  OuterShdw(CT_OuterShadowEffect)
  PrstShdw(CT_PresetShadowEffect)
  Reflection(CT_ReflectionEffect)
  RelOff(CT_RelativeOffsetEffect)
  SoftEdge(CT_SoftEdgesEffect)
  Tint(CT_TintEffect)
  Xfrm(CT_TransformEffect)
} derive(Eq, Debug)

///|
pub fn parse_effect_child(
  element : @xml.Element,
) -> EG_Effect? raise SchemaViolation {
  match element.name.local_name {
    "cont" => Some(Cont(CT_EffectContainer::new(element)))
    "effect" => Some(Effect(CT_EffectReference::new(element)))
    "alphaBiLevel" => Some(AlphaBiLevel(CT_AlphaBiLevelEffect::new(element)))
    "alphaCeiling" => Some(AlphaCeiling(CT_AlphaCeilingEffect::new(element)))
    "alphaFloor" => Some(AlphaFloor(CT_AlphaFloorEffect::new(element)))
    "alphaInv" => Some(AlphaInv(CT_AlphaInverseEffect::new(element)))
    "alphaMod" => Some(AlphaMod(CT_AlphaModulateEffect::new(element)))
    "alphaModFix" => Some(AlphaModFix(CT_AlphaModulateFixedEffect::new(element)))
    "alphaOutset" => Some(AlphaOutset(CT_AlphaOutsetEffect::new(element)))
    "alphaRepl" => Some(AlphaRepl(CT_AlphaReplaceEffect::new(element)))
    "biLevel" => Some(BiLevel(CT_BiLevelEffect::new(element)))
    "blend" => Some(Blend(CT_BlendEffect::new(element)))
    "blur" => Some(Blur(CT_BlurEffect::new(element)))
    "clrChange" => Some(ClrChange(CT_ColorChangeEffect::new(element)))
    "clrRepl" => Some(ClrRepl(CT_ColorReplaceEffect::new(element)))
    "duotone" => Some(Duotone(CT_DuotoneEffect::new(element)))
    "fill" => Some(Fill(CT_FillEffect::new(element)))
    "fillOverlay" => Some(FillOverlay(CT_FillOverlayEffect::new(element)))
    "glow" => Some(Glow(CT_GlowEffect::new(element)))
    "grayscl" => Some(Grayscl(CT_GrayscaleEffect::new(element)))
    "hsl" => Some(Hsl(CT_HSLEffect::new(element)))
    "innerShdw" => Some(InnerShdw(CT_InnerShadowEffect::new(element)))
    "lum" => Some(Lum(CT_LuminanceEffect::new(element)))
    "outerShdw" => Some(OuterShdw(CT_OuterShadowEffect::new(element)))
    "prstShdw" => Some(PrstShdw(CT_PresetShadowEffect::new(element)))
    "reflection" => Some(Reflection(CT_ReflectionEffect::new(element)))
    "relOff" => Some(RelOff(CT_RelativeOffsetEffect::new(element)))
    "softEdge" => Some(SoftEdge(CT_SoftEdgesEffect::new(element)))
    "tint" => Some(Tint(CT_TintEffect::new(element)))
    "xfrm" => Some(Xfrm(CT_TransformEffect::new(element)))
    _ => None
  }
}

///|
pub fn collect_effects(
  element : @xml.Element,
) -> Array[EG_Effect] raise SchemaViolation {
  let result : Array[EG_Effect] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_effect_child(child) {
          Some(e) => result.push(e)
          None => ()
        }
      _ => ()
    }
  }
  result
}

// ─────────────────────────────────────────────────────────────────────
// EG_EffectProperties — Part 1 §20.1.8.34 (effectLst / effectDag).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_EffectProperties {
  EffectLst(CT_EffectList)
  EffectDag(CT_EffectContainer)
} derive(Eq, Debug)

///|
pub fn parse_effect_properties_child(
  element : @xml.Element,
) -> EG_EffectProperties? raise SchemaViolation {
  match element.name.local_name {
    "effectLst" => Some(EffectLst(CT_EffectList::new(element)))
    "effectDag" => Some(EffectDag(CT_EffectContainer::new(element)))
    _ => None
  }
}

///|
pub fn find_effect_properties_child(
  element : @xml.Element,
) -> EG_EffectProperties? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_effect_properties_child(child) {
          Some(e) => return Some(e)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_Geometry — Part 1 §20.1.9 (custGeom / prstGeom).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_Geometry {
  CustGeom(CT_CustomGeometry2D)
  PrstGeom(CT_PresetGeometry2D)
} derive(Eq, Debug)

///|
pub fn parse_geometry_child(
  element : @xml.Element,
) -> EG_Geometry? raise SchemaViolation {
  match element.name.local_name {
    "custGeom" => Some(CustGeom(CT_CustomGeometry2D::new(element)))
    "prstGeom" => Some(PrstGeom(CT_PresetGeometry2D::new(element)))
    _ => None
  }
}

///|
pub fn find_geometry_child(
  element : @xml.Element,
) -> EG_Geometry? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_geometry_child(child) {
          Some(g) => return Some(g)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_TextGeometry — Part 1 §21.1.2 (custGeom / prstTxWarp).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_TextGeometry {
  CustGeom(CT_CustomGeometry2D)
  PrstTxWarp(CT_PresetTextShape)
} derive(Eq, Debug)

///|
pub fn parse_text_geometry_child(
  element : @xml.Element,
) -> EG_TextGeometry? raise SchemaViolation {
  match element.name.local_name {
    "custGeom" => Some(CustGeom(CT_CustomGeometry2D::new(element)))
    "prstTxWarp" => Some(PrstTxWarp(CT_PresetTextShape::new(element)))
    _ => None
  }
}

///|
pub fn find_text_geometry_child(
  element : @xml.Element,
) -> EG_TextGeometry? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_text_geometry_child(child) {
          Some(g) => return Some(g)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_LineFillProperties — Part 1 §20.1.2.2.24 ln (line fill subset).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_LineFillProperties {
  NoFill(CT_NoFillProperties)
  SolidFill(CT_SolidColorFillProperties)
  GradFill(CT_GradientFillProperties)
  PattFill(CT_PatternFillProperties)
} derive(Eq, Debug)

///|
pub fn parse_line_fill_properties_child(
  element : @xml.Element,
) -> EG_LineFillProperties? raise SchemaViolation {
  match element.name.local_name {
    "noFill" => Some(NoFill(CT_NoFillProperties::new(element)))
    "solidFill" => Some(SolidFill(CT_SolidColorFillProperties::new(element)))
    "gradFill" => Some(GradFill(CT_GradientFillProperties::new(element)))
    "pattFill" => Some(PattFill(CT_PatternFillProperties::new(element)))
    _ => None
  }
}

///|
pub fn find_line_fill_properties_child(
  element : @xml.Element,
) -> EG_LineFillProperties? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_line_fill_properties_child(child) {
          Some(f) => return Some(f)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_LineJoinProperties — Part 1 §20.1.2.2.24 ln (join kind).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_LineJoinProperties {
  Round(CT_LineJoinRound)
  Bevel(CT_LineJoinBevel)
  Miter(CT_LineJoinMiterProperties)
} derive(Eq, Debug)

///|
pub fn parse_line_join_properties_child(
  element : @xml.Element,
) -> EG_LineJoinProperties? raise SchemaViolation {
  match element.name.local_name {
    "round" => Some(Round(CT_LineJoinRound::new(element)))
    "bevel" => Some(Bevel(CT_LineJoinBevel::new(element)))
    "miter" => Some(Miter(CT_LineJoinMiterProperties::new(element)))
    _ => None
  }
}

///|
pub fn find_line_join_properties_child(
  element : @xml.Element,
) -> EG_LineJoinProperties? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_line_join_properties_child(child) {
          Some(j) => return Some(j)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_LineDashProperties — Part 1 §20.1.10.49 ln (prstDash / custDash).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_LineDashProperties {
  PrstDash(CT_PresetLineDashProperties)
  CustDash(CT_DashStopList)
} derive(Eq, Debug)

///|
pub fn parse_line_dash_properties_child(
  element : @xml.Element,
) -> EG_LineDashProperties? raise SchemaViolation {
  match element.name.local_name {
    "prstDash" => Some(PrstDash(CT_PresetLineDashProperties::new(element)))
    "custDash" => Some(CustDash(CT_DashStopList::new(element)))
    _ => None
  }
}

///|
pub fn find_line_dash_properties_child(
  element : @xml.Element,
) -> EG_LineDashProperties? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_line_dash_properties_child(child) {
          Some(d) => return Some(d)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_ThemeableFillStyle / EG_ThemeableEffectStyle / EG_ThemeableFontStyles
// — Part 1 §20.1.4.1 (theme style references).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_ThemeableFillStyle {
  Fill(CT_FillProperties)
  FillRef(CT_StyleMatrixReference)
} derive(Eq, Debug)

///|
pub fn parse_themeable_fill_style_child(
  element : @xml.Element,
) -> EG_ThemeableFillStyle? raise SchemaViolation {
  match element.name.local_name {
    "fill" => Some(Fill(CT_FillProperties::new(element)))
    "fillRef" => Some(FillRef(CT_StyleMatrixReference::new(element)))
    _ => None
  }
}

///|
pub(all) enum EG_ThemeableEffectStyle {
  Effect(CT_EffectProperties)
  EffectRef(CT_StyleMatrixReference)
} derive(Eq, Debug)

///|
pub fn parse_themeable_effect_style_child(
  element : @xml.Element,
) -> EG_ThemeableEffectStyle? raise SchemaViolation {
  match element.name.local_name {
    "effect" => Some(Effect(CT_EffectProperties::new(element)))
    "effectRef" => Some(EffectRef(CT_StyleMatrixReference::new(element)))
    _ => None
  }
}

///|
pub(all) enum EG_ThemeableFontStyles {
  Font(CT_FontCollection)
  FontRef(CT_FontReference)
} derive(Eq, Debug)

///|
pub fn parse_themeable_font_styles_child(
  element : @xml.Element,
) -> EG_ThemeableFontStyles? raise SchemaViolation {
  match element.name.local_name {
    "font" => Some(Font(CT_FontCollection::new(element)))
    "fontRef" => Some(FontRef(CT_FontReference::new(element)))
    _ => None
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_TextAutofit — Part 1 §21.1.2.1.1 bodyPr autofit choice.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_TextAutofit {
  NoAutofit(CT_TextNoAutofit)
  NormAutofit(CT_TextNormalAutofit)
  SpAutoFit(CT_TextShapeAutofit)
} derive(Eq, Debug)

///|
pub fn parse_text_autofit_child(
  element : @xml.Element,
) -> EG_TextAutofit? raise SchemaViolation {
  match element.name.local_name {
    "noAutofit" => Some(NoAutofit(CT_TextNoAutofit::new(element)))
    "normAutofit" => Some(NormAutofit(CT_TextNormalAutofit::new(element)))
    "spAutoFit" => Some(SpAutoFit(CT_TextShapeAutofit::new(element)))
    _ => None
  }
}

///|
pub fn find_text_autofit_child(
  element : @xml.Element,
) -> EG_TextAutofit? raise SchemaViolation {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_text_autofit_child(child) {
          Some(a) => return Some(a)
          None => ()
        }
      _ => ()
    }
  }
  None
}

// ─────────────────────────────────────────────────────────────────────
// EG_TextBulletColor / EG_TextBulletSize / EG_TextBulletTypeface / EG_TextBullet.
// Part 1 §21.1.2.4 bullet model groups.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_TextBulletColor {
  BuClrTx(CT_TextBulletColorFollowText)
  BuClr(CT_Color)
} derive(Eq, Debug)

///|
pub fn parse_text_bullet_color_child(
  element : @xml.Element,
) -> EG_TextBulletColor? raise SchemaViolation {
  match element.name.local_name {
    "buClrTx" => Some(BuClrTx(CT_TextBulletColorFollowText::new(element)))
    "buClr" => Some(BuClr(CT_Color::new(element)))
    _ => None
  }
}

///|
pub(all) enum EG_TextBulletSize {
  BuSzTx(CT_TextBulletSizeFollowText)
  BuSzPct(CT_TextBulletSizePercent)
  BuSzPts(CT_TextBulletSizePoint)
} derive(Eq, Debug)

///|
pub fn parse_text_bullet_size_child(
  element : @xml.Element,
) -> EG_TextBulletSize? raise SchemaViolation {
  match element.name.local_name {
    "buSzTx" => Some(BuSzTx(CT_TextBulletSizeFollowText::new(element)))
    "buSzPct" => Some(BuSzPct(CT_TextBulletSizePercent::new(element)))
    "buSzPts" => Some(BuSzPts(CT_TextBulletSizePoint::new(element)))
    _ => None
  }
}

///|
pub(all) enum EG_TextBulletTypeface {
  BuFontTx(CT_TextBulletTypefaceFollowText)
  BuFont(CT_TextFont)
} derive(Eq, Debug)

///|
pub fn parse_text_bullet_typeface_child(
  element : @xml.Element,
) -> EG_TextBulletTypeface? raise SchemaViolation {
  match element.name.local_name {
    "buFontTx" => Some(BuFontTx(CT_TextBulletTypefaceFollowText::new(element)))
    "buFont" => Some(BuFont(CT_TextFont::new(element)))
    _ => None
  }
}

///|
pub(all) enum EG_TextBullet {
  BuNone(CT_TextNoBullet)
  BuAutoNum(CT_TextAutonumberBullet)
  BuChar(CT_TextCharBullet)
  BuBlip(CT_TextBlipBullet)
} derive(Eq, Debug)

///|
pub fn parse_text_bullet_child(
  element : @xml.Element,
) -> EG_TextBullet? raise SchemaViolation {
  match element.name.local_name {
    "buNone" => Some(BuNone(CT_TextNoBullet::new(element)))
    "buAutoNum" => Some(BuAutoNum(CT_TextAutonumberBullet::new(element)))
    "buChar" => Some(BuChar(CT_TextCharBullet::new(element)))
    "buBlip" => Some(BuBlip(CT_TextBlipBullet::new(element)))
    _ => None
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_TextUnderlineLine / EG_TextUnderlineFill — Part 1 §21.1.2.3.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_TextUnderlineLine {
  ULnTx(CT_TextUnderlineLineFollowText)
  ULn(CT_LineProperties)
} derive(Eq, Debug)

///|
pub fn parse_text_underline_line_child(
  element : @xml.Element,
) -> EG_TextUnderlineLine? raise SchemaViolation {
  match element.name.local_name {
    "uLnTx" => Some(ULnTx(CT_TextUnderlineLineFollowText::new(element)))
    "uLn" => Some(ULn(CT_LineProperties::new(element)))
    _ => None
  }
}

///|
pub(all) enum EG_TextUnderlineFill {
  UFillTx(CT_TextUnderlineFillFollowText)
  UFill(CT_TextUnderlineFillGroupWrapper)
} derive(Eq, Debug)

///|
pub fn parse_text_underline_fill_child(
  element : @xml.Element,
) -> EG_TextUnderlineFill? raise SchemaViolation {
  match element.name.local_name {
    "uFillTx" => Some(UFillTx(CT_TextUnderlineFillFollowText::new(element)))
    "uFill" => Some(UFill(CT_TextUnderlineFillGroupWrapper::new(element)))
    _ => None
  }
}
