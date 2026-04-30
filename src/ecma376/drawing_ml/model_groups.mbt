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
/// XSD model group EG_Media (§20.1): audioCd, wavAudioFile, audioFile, videoFile, quickTimeFile.
pub(all) struct EG_Media {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_Media::new(element : @xml.Element) -> EG_Media {
  { element, }
}

///|
pub fn EG_Media::child_names(self : EG_Media) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_Media::has_child(self : EG_Media, name : String) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_ColorTransform (§20.1): tint, shade, comp, inv, gray, alpha, alphaOff, alphaMod, hue, hueOff, hueMod, sat, satOff, satMod, lum, lumOff, lumMod, red, redOff, redMod, green, greenOff, greenMod, blue, blueOff, blueMod, gamma, invGamma.
pub(all) struct EG_ColorTransform {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ColorTransform::new(element : @xml.Element) -> EG_ColorTransform {
  { element, }
}

///|
pub fn EG_ColorTransform::child_names(
  self : EG_ColorTransform,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_ColorTransform::has_child(
  self : EG_ColorTransform,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_OfficeArtExtensionList (§20.1): ext.
pub(all) struct EG_OfficeArtExtensionList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_OfficeArtExtensionList::new(
  element : @xml.Element,
) -> EG_OfficeArtExtensionList {
  { element, }
}

///|
pub fn EG_OfficeArtExtensionList::child_names(
  self : EG_OfficeArtExtensionList,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_OfficeArtExtensionList::has_child(
  self : EG_OfficeArtExtensionList,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_ColorChoice (§20.1): scrgbClr, srgbClr, hslClr, sysClr, schemeClr, prstClr.
pub(all) struct EG_ColorChoice {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ColorChoice::new(element : @xml.Element) -> EG_ColorChoice {
  { element, }
}

///|
pub fn EG_ColorChoice::child_names(self : EG_ColorChoice) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_ColorChoice::has_child(self : EG_ColorChoice, name : String) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_Text3D (§20.1): sp3d, flatTx.
pub(all) struct EG_Text3D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_Text3D::new(element : @xml.Element) -> EG_Text3D {
  { element, }
}

///|
pub fn EG_Text3D::child_names(self : EG_Text3D) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_Text3D::has_child(self : EG_Text3D, name : String) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_ShadeProperties (§20.1): lin, path.
pub(all) struct EG_ShadeProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ShadeProperties::new(element : @xml.Element) -> EG_ShadeProperties {
  { element, }
}

///|
pub fn EG_ShadeProperties::child_names(
  self : EG_ShadeProperties,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_ShadeProperties::has_child(
  self : EG_ShadeProperties,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_FillModeProperties (§20.1): tile, stretch.
pub(all) struct EG_FillModeProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_FillModeProperties::new(
  element : @xml.Element,
) -> EG_FillModeProperties {
  { element, }
}

///|
pub fn EG_FillModeProperties::child_names(
  self : EG_FillModeProperties,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_FillModeProperties::has_child(
  self : EG_FillModeProperties,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_FillProperties (§20.1): noFill, solidFill, gradFill, blipFill, pattFill, grpFill.
pub(all) struct EG_FillProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_FillProperties::new(element : @xml.Element) -> EG_FillProperties {
  { element, }
}

///|
pub fn EG_FillProperties::child_names(
  self : EG_FillProperties,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_FillProperties::has_child(
  self : EG_FillProperties,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_Effect (§20.1): cont, effect, alphaBiLevel, alphaCeiling, alphaFloor, alphaInv, alphaMod, alphaModFix, alphaOutset, alphaRepl, biLevel, blend, blur, clrChange, clrRepl, duotone, fill, fillOverlay, glow, grayscl, hsl, innerShdw, lum, outerShdw, prstShdw, reflection, relOff, softEdge, tint, xfrm.
pub(all) struct EG_Effect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_Effect::new(element : @xml.Element) -> EG_Effect {
  { element, }
}

///|
pub fn EG_Effect::child_names(self : EG_Effect) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_Effect::has_child(self : EG_Effect, name : String) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_EffectProperties (§20.1): effectLst, effectDag.
pub(all) struct EG_EffectProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_EffectProperties::new(element : @xml.Element) -> EG_EffectProperties {
  { element, }
}

///|
pub fn EG_EffectProperties::child_names(
  self : EG_EffectProperties,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_EffectProperties::has_child(
  self : EG_EffectProperties,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_Geometry (§20.1): custGeom, prstGeom.
pub(all) struct EG_Geometry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_Geometry::new(element : @xml.Element) -> EG_Geometry {
  { element, }
}

///|
pub fn EG_Geometry::child_names(self : EG_Geometry) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_Geometry::has_child(self : EG_Geometry, name : String) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_TextGeometry (§20.1): custGeom, prstTxWarp.
pub(all) struct EG_TextGeometry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TextGeometry::new(element : @xml.Element) -> EG_TextGeometry {
  { element, }
}

///|
pub fn EG_TextGeometry::child_names(self : EG_TextGeometry) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_TextGeometry::has_child(
  self : EG_TextGeometry,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_LineFillProperties (§20.1): noFill, solidFill, gradFill, pattFill.
pub(all) struct EG_LineFillProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_LineFillProperties::new(
  element : @xml.Element,
) -> EG_LineFillProperties {
  { element, }
}

///|
pub fn EG_LineFillProperties::child_names(
  self : EG_LineFillProperties,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_LineFillProperties::has_child(
  self : EG_LineFillProperties,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_LineJoinProperties (§20.1): round, bevel, miter.
pub(all) struct EG_LineJoinProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_LineJoinProperties::new(
  element : @xml.Element,
) -> EG_LineJoinProperties {
  { element, }
}

///|
pub fn EG_LineJoinProperties::child_names(
  self : EG_LineJoinProperties,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_LineJoinProperties::has_child(
  self : EG_LineJoinProperties,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_LineDashProperties (§20.1): prstDash, custDash.
pub(all) struct EG_LineDashProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_LineDashProperties::new(
  element : @xml.Element,
) -> EG_LineDashProperties {
  { element, }
}

///|
pub fn EG_LineDashProperties::child_names(
  self : EG_LineDashProperties,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_LineDashProperties::has_child(
  self : EG_LineDashProperties,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_ThemeableFillStyle (§20.1): fill, fillRef.
pub(all) struct EG_ThemeableFillStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ThemeableFillStyle::new(
  element : @xml.Element,
) -> EG_ThemeableFillStyle {
  { element, }
}

///|
pub fn EG_ThemeableFillStyle::child_names(
  self : EG_ThemeableFillStyle,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_ThemeableFillStyle::has_child(
  self : EG_ThemeableFillStyle,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_ThemeableEffectStyle (§20.1): effect, effectRef.
pub(all) struct EG_ThemeableEffectStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ThemeableEffectStyle::new(
  element : @xml.Element,
) -> EG_ThemeableEffectStyle {
  { element, }
}

///|
pub fn EG_ThemeableEffectStyle::child_names(
  self : EG_ThemeableEffectStyle,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_ThemeableEffectStyle::has_child(
  self : EG_ThemeableEffectStyle,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_ThemeableFontStyles (§20.1): font, fontRef.
pub(all) struct EG_ThemeableFontStyles {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ThemeableFontStyles::new(
  element : @xml.Element,
) -> EG_ThemeableFontStyles {
  { element, }
}

///|
pub fn EG_ThemeableFontStyles::child_names(
  self : EG_ThemeableFontStyles,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_ThemeableFontStyles::has_child(
  self : EG_ThemeableFontStyles,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_TextAutofit (§20.1): noAutofit, normAutofit, spAutoFit.
pub(all) struct EG_TextAutofit {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TextAutofit::new(element : @xml.Element) -> EG_TextAutofit {
  { element, }
}

///|
pub fn EG_TextAutofit::child_names(self : EG_TextAutofit) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_TextAutofit::has_child(self : EG_TextAutofit, name : String) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_TextBulletColor (§20.1): buClrTx, buClr.
pub(all) struct EG_TextBulletColor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TextBulletColor::new(element : @xml.Element) -> EG_TextBulletColor {
  { element, }
}

///|
pub fn EG_TextBulletColor::child_names(
  self : EG_TextBulletColor,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_TextBulletColor::has_child(
  self : EG_TextBulletColor,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_TextBulletSize (§20.1): buSzTx, buSzPct, buSzPts.
pub(all) struct EG_TextBulletSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TextBulletSize::new(element : @xml.Element) -> EG_TextBulletSize {
  { element, }
}

///|
pub fn EG_TextBulletSize::child_names(
  self : EG_TextBulletSize,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_TextBulletSize::has_child(
  self : EG_TextBulletSize,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_TextBulletTypeface (§20.1): buFontTx, buFont.
pub(all) struct EG_TextBulletTypeface {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TextBulletTypeface::new(
  element : @xml.Element,
) -> EG_TextBulletTypeface {
  { element, }
}

///|
pub fn EG_TextBulletTypeface::child_names(
  self : EG_TextBulletTypeface,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_TextBulletTypeface::has_child(
  self : EG_TextBulletTypeface,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_TextBullet (§20.1): buNone, buAutoNum, buChar, buBlip.
pub(all) struct EG_TextBullet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TextBullet::new(element : @xml.Element) -> EG_TextBullet {
  { element, }
}

///|
pub fn EG_TextBullet::child_names(self : EG_TextBullet) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_TextBullet::has_child(self : EG_TextBullet, name : String) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_TextUnderlineLine (§20.1): uLnTx, uLn.
pub(all) struct EG_TextUnderlineLine {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TextUnderlineLine::new(
  element : @xml.Element,
) -> EG_TextUnderlineLine {
  { element, }
}

///|
pub fn EG_TextUnderlineLine::child_names(
  self : EG_TextUnderlineLine,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_TextUnderlineLine::has_child(
  self : EG_TextUnderlineLine,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_TextUnderlineFill (§20.1): uFillTx, uFill.
pub(all) struct EG_TextUnderlineFill {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TextUnderlineFill::new(
  element : @xml.Element,
) -> EG_TextUnderlineFill {
  { element, }
}

///|
pub fn EG_TextUnderlineFill::child_names(
  self : EG_TextUnderlineFill,
) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_TextUnderlineFill::has_child(
  self : EG_TextUnderlineFill,
  name : String,
) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}

///|
/// XSD model group EG_TextRun (§20.1): r, br, fld.
pub(all) struct EG_TextRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TextRun::new(element : @xml.Element) -> EG_TextRun {
  { element, }
}

///|
pub fn EG_TextRun::child_names(self : EG_TextRun) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}

///|
pub fn EG_TextRun::has_child(self : EG_TextRun, name : String) -> Bool {
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == name {
        return true
      }
    }
  }
  false
}
