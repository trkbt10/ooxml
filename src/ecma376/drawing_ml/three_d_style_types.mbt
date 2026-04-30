///|
/// XSD complex type CT_Bevel (§20.1.8): 3D bevel geometry used by bevelT,
/// bevelB, and table cell bevel; attributes w, h, prst and no child elements.
pub(all) struct CT_Bevel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Bevel::new(element : @xml.Element) -> CT_Bevel {
  { element, }
}

///|
pub fn read_bevel(bytes : Bytes) -> CT_Bevel raise {
  CT_Bevel::new(read_main_root(bytes, "bevel"))
}

///|
pub fn write_bevel(value : CT_Bevel) -> Bytes {
  write_element(value.element)
}

///|
/// XSD complex type CT_FlatText (§20.1.8): attribute z.
pub(all) struct CT_FlatText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FlatText::new(element : @xml.Element) -> CT_FlatText {
  { element, }
}

///|
/// XSD complex type CT_Backdrop (§20.1.8): children anchor, norm, up, extLst.
pub(all) struct CT_Backdrop {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Backdrop::new(element : @xml.Element) -> CT_Backdrop {
  { element, }
}

///|
/// XSD complex type CT_Camera (§20.1.8): attributes prst, fov, zoom; child rot.
pub(all) struct CT_Camera {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Camera::new(element : @xml.Element) -> CT_Camera {
  { element, }
}

///|
/// XSD complex type CT_LightRig (§20.1.8): attributes rig, dir; child rot.
pub(all) struct CT_LightRig {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LightRig::new(element : @xml.Element) -> CT_LightRig {
  { element, }
}

///|
/// XSD complex type CT_Cell3D (§20.1.3): attribute prstMaterial; children bevel, lightRig, extLst.
pub(all) struct CT_Cell3D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Cell3D::new(element : @xml.Element) -> CT_Cell3D {
  { element, }
}

///|
/// XSD complex type CT_Shape3D (§20.1.8): attributes z, extrusionH, contourW, prstMaterial; bevel and color children.
pub(all) struct CT_Shape3D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shape3D::new(element : @xml.Element) -> CT_Shape3D {
  { element, }
}

///|
/// XSD complex type CT_Scene3D (§20.1.8): children camera, lightRig, backdrop, extLst.
pub(all) struct CT_Scene3D {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Scene3D::new(element : @xml.Element) -> CT_Scene3D {
  { element, }
}

///|
/// XSD complex type CT_Headers (§20.1.3): repeated header string children.
pub(all) struct CT_Headers {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Headers::new(element : @xml.Element) -> CT_Headers {
  { element, }
}

///|
/// XSD complex type CT_BackgroundFormatting (§20.1.4): background formatting choice.
pub(all) struct CT_BackgroundFormatting {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BackgroundFormatting::new(
  element : @xml.Element,
) -> CT_BackgroundFormatting {
  { element, }
}

///|
/// XSD complex type CT_FillStyleList (§20.1.4): fill style choices.
pub(all) struct CT_FillStyleList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FillStyleList::new(element : @xml.Element) -> CT_FillStyleList {
  { element, }
}

///|
/// XSD complex type CT_LineStyleList (§20.1.4): child ln.
pub(all) struct CT_LineStyleList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineStyleList::new(element : @xml.Element) -> CT_LineStyleList {
  { element, }
}

///|
/// XSD complex type CT_EffectStyleItem (§20.1.4): effect list, scene3d, and sp3d children.
pub(all) struct CT_EffectStyleItem {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectStyleItem::new(element : @xml.Element) -> CT_EffectStyleItem {
  { element, }
}

///|
/// XSD complex type CT_EffectStyleList (§20.1.4): child effectStyle.
pub(all) struct CT_EffectStyleList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectStyleList::new(element : @xml.Element) -> CT_EffectStyleList {
  { element, }
}

///|
/// XSD complex type CT_BackgroundFillStyleList (§20.1.4): background fill style choices.
pub(all) struct CT_BackgroundFillStyleList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BackgroundFillStyleList::new(
  element : @xml.Element,
) -> CT_BackgroundFillStyleList {
  { element, }
}

///|
/// XSD complex type CT_StyleMatrix (§20.1.4): attribute name; fill, line, effect, and background fill lists.
pub(all) struct CT_StyleMatrix {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StyleMatrix::new(element : @xml.Element) -> CT_StyleMatrix {
  { element, }
}

///|
/// XSD complex type CT_ThemeableLineStyle (§20.1.3): children ln and lnRef.
pub(all) struct CT_ThemeableLineStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ThemeableLineStyle::new(
  element : @xml.Element,
) -> CT_ThemeableLineStyle {
  { element, }
}

///|
/// XSD complex type CT_StyleMatrixReference (§20.1.4): attribute idx and color choice.
pub(all) struct CT_StyleMatrixReference {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StyleMatrixReference::new(
  element : @xml.Element,
) -> CT_StyleMatrixReference {
  { element, }
}

///|
/// XSD complex type CT_ShapeStyle (§20.1.5): children lnRef, fillRef, effectRef, fontRef.
pub(all) struct CT_ShapeStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeStyle::new(element : @xml.Element) -> CT_ShapeStyle {
  { element, }
}

///|
/// XSD complex type CT_DefaultShapeDefinition (§20.1.5): children spPr, bodyPr, lstStyle, style, extLst.
pub(all) struct CT_DefaultShapeDefinition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DefaultShapeDefinition::new(
  element : @xml.Element,
) -> CT_DefaultShapeDefinition {
  { element, }
}

///|
/// XSD complex type CT_ObjectStyleDefaults (§20.1.5): children spDef, lnDef, txDef, extLst.
pub(all) struct CT_ObjectStyleDefaults {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ObjectStyleDefaults::new(
  element : @xml.Element,
) -> CT_ObjectStyleDefaults {
  { element, }
}

///|
pub fn read_scene3d(bytes : Bytes) -> CT_Scene3D raise {
  CT_Scene3D::new(read_main_root(bytes, "scene3d"))
}

///|
pub fn write_scene3d(value : CT_Scene3D) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_shape3d(bytes : Bytes) -> CT_Shape3D raise {
  CT_Shape3D::new(read_main_root(bytes, "sp3d"))
}

///|
pub fn write_shape3d(value : CT_Shape3D) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_style_matrix(bytes : Bytes) -> CT_StyleMatrix raise {
  CT_StyleMatrix::new(read_main_root(bytes, "fmtScheme"))
}

///|
pub fn write_style_matrix(value : CT_StyleMatrix) -> Bytes {
  write_element(value.element)
}
