// ECMA-376 Part 1 §20.1.4 / §20.1.5 / §20.1.3 / §20.1.8 DrawingML
// 3-D, style-matrix, shape-style, and theme-style complex types. XSD
// definitions live in Annex A.4.1 dml-main.xsd at the following line
// ranges:
//
//   CT_EffectStyleItem            lines  127..133
//   CT_FillStyleList              lines  142..146
//   CT_LineStyleList              lines  147..151
//   CT_EffectStyleList            lines  152..157
//   CT_BackgroundFillStyleList    lines  158..162
//   CT_StyleMatrix                lines  163..172
//   CT_BackgroundFormatting       lines  926..931
//   CT_Camera                     lines 1105..1112
//   CT_LightRig                   lines 1156..1162
//   CT_Scene3D                    lines 1163..1170
//   CT_Backdrop                   lines 1171..1178
//   CT_Bevel                      lines 1195..1199
//   CT_Shape3D                    lines 1219..1232
//   CT_FlatText                   lines 1233..1235
//   CT_StyleMatrixReference       lines 2246..2251
//   CT_ShapeStyle                 lines 2258..2265
//   CT_DefaultShapeDefinition     lines 2266..2274
//   CT_ObjectStyleDefaults        lines 2275..2282
//   CT_Headers                    lines 2370..2374
//   CT_Cell3D                     lines 2431..2439
//   CT_ThemeableLineStyle         lines 2446..2451
//
// Per the ct-typing protocol each CT_X is projected as a typed struct
// with explicit attribute / child-element fields decoded from the
// source `@xml.Element`. The element is preserved so the builder can
// round-trip unmodelled content (the `to_element` writer returns the
// captured element verbatim).

///|
/// XSD complex type CT_Bevel — Part 1 §20.1.8.5 bevelT / bevelB /
/// `bevel` (3-D bevel geometry). Annex A.4.1 lines 1195..1199. No
/// children; three optional attributes with schema-declared defaults.
pub(all) struct CT_Bevel {
  /// @w — ST_PositiveCoordinate (optional, default 76200 EMU).
  w : ST_PositiveCoordinate
  /// @h — ST_PositiveCoordinate (optional, default 76200 EMU).
  h : ST_PositiveCoordinate
  /// @prst — ST_BevelPresetType (optional, default "circle").
  prst : ST_BevelPresetType
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Bevel::new(element : @xml.Element) -> CT_Bevel raise SchemaViolation {
  let w = match ct_attr(element, "w") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("76200")
  }
  let h = match ct_attr(element, "h") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("76200")
  }
  let prst = match ct_attr(element, "prst") {
    Some(v) => ST_BevelPresetType::parse(v)
    None => BevelCircle
  }
  { w, h, prst, element }
}

///|
pub fn CT_Bevel::to_element(self : CT_Bevel) -> @xml.Element {
  self.element
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
/// XSD complex type CT_FlatText — Part 1 §20.1.5.8 flatTx (Flat Text
/// 3-D Setting). Annex A.4.1 lines 1233..1235. No children; one optional
/// attribute `z` (ST_Coordinate, default 0).
pub(all) struct CT_FlatText {
  /// @z — ST_Coordinate (optional, default 0).
  z : ST_Coordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FlatText::new(
  element : @xml.Element,
) -> CT_FlatText raise SchemaViolation {
  let z = match ct_attr(element, "z") {
    Some(v) => ST_Coordinate::parse(v)
    None => ST_Coordinate::parse("0")
  }
  { z, element }
}

///|
pub fn CT_FlatText::to_element(self : CT_FlatText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Backdrop — Part 1 §20.1.5.2 backdrop (3-D
/// Backdrop). Annex A.4.1 lines 1171..1178. Sequence: `anchor`
/// (CT_Point3D, required), `norm` (CT_Vector3D, required), `up`
/// (CT_Vector3D, required), `extLst` (CT_OfficeArtExtensionList,
/// optional). No attributes.
pub(all) struct CT_Backdrop {
  /// <anchor> (CT_Point3D) — required.
  anchor : CT_Point3D
  /// <norm> (CT_Vector3D) — required.
  norm : CT_Vector3D
  /// <up> (CT_Vector3D) — required.
  up : CT_Vector3D
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Backdrop::new(
  element : @xml.Element,
) -> CT_Backdrop raise SchemaViolation {
  let anchor = match ct_first_child(element, "anchor") {
    Some(c) => CT_Point3D::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Backdrop/anchor",
        reason="missing required child element",
      )
  }
  let norm = match ct_first_child(element, "norm") {
    Some(c) => CT_Vector3D::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Backdrop/norm",
        reason="missing required child element",
      )
  }
  let up = match ct_first_child(element, "up") {
    Some(c) => CT_Vector3D::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Backdrop/up",
        reason="missing required child element",
      )
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { anchor, norm, up, ext_lst, element }
}

///|
pub fn CT_Backdrop::to_element(self : CT_Backdrop) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Camera — Part 1 §20.1.5.5 camera (3-D Camera).
/// Annex A.4.1 lines 1105..1112. Sequence: `rot` (CT_SphereCoords,
/// optional). Required `prst` (ST_PresetCameraType); optional `fov`
/// (ST_FOVAngle); optional `zoom` (ST_PositivePercentage, default 100%).
pub(all) struct CT_Camera {
  /// <rot> (CT_SphereCoords) — optional.
  rot : CT_SphereCoords?
  /// @prst — ST_PresetCameraType (required).
  prst : ST_PresetCameraType
  /// @fov — ST_FOVAngle (optional).
  fov : ST_FOVAngle?
  /// @zoom — ST_PositivePercentage (optional, default 100%).
  zoom : ST_PositivePercentage
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Camera::new(
  element : @xml.Element,
) -> CT_Camera raise SchemaViolation {
  let rot = match ct_first_child(element, "rot") {
    Some(c) => Some(CT_SphereCoords::new(c))
    None => None
  }
  let prst_lex = ct_required_string(element, "prst", "CT_Camera/@prst")
  let prst = ST_PresetCameraType::parse(prst_lex)
  let fov = match ct_attr(element, "fov") {
    Some(v) => Some(ST_FOVAngle::parse(v))
    None => None
  }
  let zoom = match ct_attr(element, "zoom") {
    Some(v) => ST_PositivePercentage::parse(v)
    None => ST_PositivePercentage::parse("100%")
  }
  { rot, prst, fov, zoom, element }
}

///|
pub fn CT_Camera::to_element(self : CT_Camera) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LightRig — Part 1 §20.1.5.13 lightRig (3-D
/// Light Rig). Annex A.4.1 lines 1156..1162. Sequence: `rot`
/// (CT_SphereCoords, optional). Required `rig` (ST_LightRigType) and
/// `dir` (ST_LightRigDirection).
pub(all) struct CT_LightRig {
  /// <rot> (CT_SphereCoords) — optional.
  rot : CT_SphereCoords?
  /// @rig — ST_LightRigType (required).
  rig : ST_LightRigType
  /// @dir — ST_LightRigDirection (required).
  dir : ST_LightRigDirection
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LightRig::new(
  element : @xml.Element,
) -> CT_LightRig raise SchemaViolation {
  let rot = match ct_first_child(element, "rot") {
    Some(c) => Some(CT_SphereCoords::new(c))
    None => None
  }
  let rig_lex = ct_required_string(element, "rig", "CT_LightRig/@rig")
  let rig = ST_LightRigType::parse(rig_lex)
  let dir_lex = ct_required_string(element, "dir", "CT_LightRig/@dir")
  let dir = ST_LightRigDirection::parse(dir_lex)
  { rot, rig, dir, element }
}

///|
pub fn CT_LightRig::to_element(self : CT_LightRig) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Cell3D — Part 1 §20.1.3.2 cell3D (3-D Cell
/// Properties). Annex A.4.1 lines 2431..2439. Sequence: `bevel`
/// (CT_Bevel, required), `lightRig` (CT_LightRig, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). One optional attribute
/// `prstMaterial` (ST_PresetMaterialType, default "plastic").
pub(all) struct CT_Cell3D {
  /// <bevel> (CT_Bevel) — required.
  bevel : CT_Bevel
  /// <lightRig> (CT_LightRig) — optional.
  light_rig : CT_LightRig?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @prstMaterial — ST_PresetMaterialType (optional, default "plastic").
  prst_material : ST_PresetMaterialType
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Cell3D::new(
  element : @xml.Element,
) -> CT_Cell3D raise SchemaViolation {
  let bevel = match ct_first_child(element, "bevel") {
    Some(c) => CT_Bevel::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Cell3D/bevel",
        reason="missing required child element",
      )
  }
  let light_rig = match ct_first_child(element, "lightRig") {
    Some(c) => Some(CT_LightRig::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let prst_material = match ct_attr(element, "prstMaterial") {
    Some(v) => ST_PresetMaterialType::parse(v)
    None => MaterialPlastic
  }
  { bevel, light_rig, ext_lst, prst_material, element }
}

///|
pub fn CT_Cell3D::to_element(self : CT_Cell3D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Shape3D — Part 1 §20.1.5.18 sp3d (Shape 3-D).
/// Annex A.4.1 lines 1219..1232. Sequence: `bevelT` (CT_Bevel,
/// optional), `bevelB` (CT_Bevel, optional), `extrusionClr` (CT_Color,
/// optional), `contourClr` (CT_Color, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). Four optional attributes
/// with schema-declared defaults.
pub(all) struct CT_Shape3D {
  /// <bevelT> (CT_Bevel) — optional top bevel.
  bevel_t : CT_Bevel?
  /// <bevelB> (CT_Bevel) — optional bottom bevel.
  bevel_b : CT_Bevel?
  /// <extrusionClr> (CT_Color) — optional extrusion colour.
  extrusion_clr : CT_Color?
  /// <contourClr> (CT_Color) — optional contour colour.
  contour_clr : CT_Color?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @z — ST_Coordinate (optional, default 0).
  z : ST_Coordinate
  /// @extrusionH — ST_PositiveCoordinate (optional, default 0).
  extrusion_h : ST_PositiveCoordinate
  /// @contourW — ST_PositiveCoordinate (optional, default 0).
  contour_w : ST_PositiveCoordinate
  /// @prstMaterial — ST_PresetMaterialType (optional, default "warmMatte").
  prst_material : ST_PresetMaterialType
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shape3D::new(
  element : @xml.Element,
) -> CT_Shape3D raise SchemaViolation {
  let bevel_t = match ct_first_child(element, "bevelT") {
    Some(c) => Some(CT_Bevel::new(c))
    None => None
  }
  let bevel_b = match ct_first_child(element, "bevelB") {
    Some(c) => Some(CT_Bevel::new(c))
    None => None
  }
  let extrusion_clr = match ct_first_child(element, "extrusionClr") {
    Some(c) => Some(CT_Color::new(c))
    None => None
  }
  let contour_clr = match ct_first_child(element, "contourClr") {
    Some(c) => Some(CT_Color::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let z = match ct_attr(element, "z") {
    Some(v) => ST_Coordinate::parse(v)
    None => ST_Coordinate::parse("0")
  }
  let extrusion_h = match ct_attr(element, "extrusionH") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let contour_w = match ct_attr(element, "contourW") {
    Some(v) => ST_PositiveCoordinate::parse(v)
    None => ST_PositiveCoordinate::parse("0")
  }
  let prst_material = match ct_attr(element, "prstMaterial") {
    Some(v) => ST_PresetMaterialType::parse(v)
    None => MaterialWarmMatte
  }
  {
    bevel_t,
    bevel_b,
    extrusion_clr,
    contour_clr,
    ext_lst,
    z,
    extrusion_h,
    contour_w,
    prst_material,
    element,
  }
}

///|
pub fn CT_Shape3D::to_element(self : CT_Shape3D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Scene3D — Part 1 §20.1.5.17 scene3d (3-D
/// Scene). Annex A.4.1 lines 1163..1170. Sequence: `camera` (CT_Camera,
/// required), `lightRig` (CT_LightRig, required), `backdrop`
/// (CT_Backdrop, optional), `extLst` (CT_OfficeArtExtensionList,
/// optional). No attributes.
pub(all) struct CT_Scene3D {
  /// <camera> (CT_Camera) — required.
  camera : CT_Camera
  /// <lightRig> (CT_LightRig) — required.
  light_rig : CT_LightRig
  /// <backdrop> (CT_Backdrop) — optional.
  backdrop : CT_Backdrop?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Scene3D::new(
  element : @xml.Element,
) -> CT_Scene3D raise SchemaViolation {
  let camera = match ct_first_child(element, "camera") {
    Some(c) => CT_Camera::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Scene3D/camera",
        reason="missing required child element",
      )
  }
  let light_rig = match ct_first_child(element, "lightRig") {
    Some(c) => CT_LightRig::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Scene3D/lightRig",
        reason="missing required child element",
      )
  }
  let backdrop = match ct_first_child(element, "backdrop") {
    Some(c) => Some(CT_Backdrop::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { camera, light_rig, backdrop, ext_lst, element }
}

///|
pub fn CT_Scene3D::to_element(self : CT_Scene3D) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Headers — Part 1 §20.1.3.5 headers (Header List).
/// Annex A.4.1 lines 2370..2374. Sequence containing zero or more
/// `header` (xsd:string) repetitions in document order.
pub(all) struct CT_Headers {
  /// <header>* (xsd:string) — header strings in document order.
  headers : Array[String]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Headers::new(element : @xml.Element) -> CT_Headers {
  let headers : Array[String] = []
  for child in ct_children(element, "header") {
    headers.push(ct_header_text(child))
  }
  { headers, element }
}

///|
pub fn CT_Headers::to_element(self : CT_Headers) -> @xml.Element {
  self.element
}

///|
/// Decode the lexical content of a `<header>` element: concatenate
/// every text / CData child verbatim per XSD `xsd:string` semantics.
fn ct_header_text(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for node in element.children {
    match node {
      @xml.Text(s) => buf.write_string(s)
      @xml.CData(s) => buf.write_string(s)
      _ => ()
    }
  }
  buf.to_string()
}

///|
/// XSD complex type CT_BackgroundFormatting — Part 1 §20.1.4.1.1
/// bg (Diagram Background Formatting). Annex A.4.1 lines 926..931.
/// Sequence: EG_FillProperties choice (optional), EG_EffectProperties
/// choice (optional). No attributes.
pub(all) struct CT_BackgroundFormatting {
  /// EG_FillProperties choice — optional via CT_FillProperties wrapper.
  fill : CT_FillProperties?
  /// EG_EffectProperties choice — optional via CT_EffectProperties wrapper.
  effect : CT_EffectProperties?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BackgroundFormatting::new(
  element : @xml.Element,
) -> CT_BackgroundFormatting raise SchemaViolation {
  let fill = if ct_first_child(element, "noFill") is Some(_) ||
    ct_first_child(element, "solidFill") is Some(_) ||
    ct_first_child(element, "gradFill") is Some(_) ||
    ct_first_child(element, "blipFill") is Some(_) ||
    ct_first_child(element, "pattFill") is Some(_) ||
    ct_first_child(element, "grpFill") is Some(_) {
    Some(CT_FillProperties::new(element))
  } else {
    None
  }
  let effect = if ct_first_child(element, "effectLst") is Some(_) ||
    ct_first_child(element, "effectDag") is Some(_) {
    Some(CT_EffectProperties::new(element))
  } else {
    None
  }
  { fill, effect, element }
}

///|
pub fn CT_BackgroundFormatting::to_element(
  self : CT_BackgroundFormatting,
) -> @xml.Element {
  self.element
}

///|
/// EG_FillProperties choice projection captured by CT_FillStyleList /
/// CT_BackgroundFillStyleList entries. Each entry is one of six fill
/// arms per Part 1 §20.1.8.
pub(all) enum CT_FillStyleList_Entry {
  /// <noFill> (CT_NoFillProperties) choice arm.
  FillStyleNone(CT_NoFillProperties)
  /// <solidFill> (CT_SolidColorFillProperties) choice arm.
  FillStyleSolid(CT_SolidColorFillProperties)
  /// <gradFill> (CT_GradientFillProperties) choice arm.
  FillStyleGradient(CT_GradientFillProperties)
  /// <blipFill> (CT_BlipFillProperties) choice arm.
  FillStyleBlip(CT_BlipFillProperties)
  /// <pattFill> (CT_PatternFillProperties) choice arm.
  FillStylePattern(CT_PatternFillProperties)
  /// <grpFill> (CT_GroupFillProperties) choice arm.
  FillStyleGroup(CT_GroupFillProperties)
} derive(Eq, Debug)

///|
/// Decode every direct child of `element` as an EG_FillProperties arm
/// preserving document order. Non-fill children are skipped (they
/// belong to neighbouring sequence positions). Raises SchemaViolation
/// when fewer than three entries are present (XSD minOccurs=3).
fn decode_fill_style_list_entries(
  element : @xml.Element,
  path : String,
) -> Array[CT_FillStyleList_Entry] raise SchemaViolation {
  let entries : Array[CT_FillStyleList_Entry] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match child.name.local_name {
          "noFill" =>
            entries.push(FillStyleNone(CT_NoFillProperties::new(child)))
          "solidFill" =>
            entries.push(
              FillStyleSolid(CT_SolidColorFillProperties::new(child)),
            )
          "gradFill" =>
            entries.push(
              FillStyleGradient(CT_GradientFillProperties::new(child)),
            )
          "blipFill" =>
            entries.push(FillStyleBlip(CT_BlipFillProperties::new(child)))
          "pattFill" =>
            entries.push(FillStylePattern(CT_PatternFillProperties::new(child)))
          "grpFill" =>
            entries.push(FillStyleGroup(CT_GroupFillProperties::new(child)))
          _ => ()
        }
      _ => ()
    }
  }
  if entries.length() < 3 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="EG_FillProperties minOccurs=3 unmet; observed: " +
        entries.length().to_string(),
    )
  }
  entries
}

///|
/// XSD complex type CT_FillStyleList — Part 1 §20.1.4.1.13
/// fillStyleLst (Fill Style List). Annex A.4.1 lines 142..146.
/// Sequence containing EG_FillProperties choices three or more times.
pub(all) struct CT_FillStyleList {
  /// EG_FillProperties choices in document order (three or more).
  entries : Array[CT_FillStyleList_Entry]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FillStyleList::new(
  element : @xml.Element,
) -> CT_FillStyleList raise SchemaViolation {
  let entries = decode_fill_style_list_entries(element, "CT_FillStyleList")
  { entries, element }
}

///|
pub fn CT_FillStyleList::to_element(self : CT_FillStyleList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LineStyleList — Part 1 §20.1.4.1.21
/// lnStyleLst (Line Style List). Annex A.4.1 lines 147..151. Sequence
/// containing `ln` (CT_LineProperties) three or more times.
pub(all) struct CT_LineStyleList {
  /// <ln>+ (CT_LineProperties) — three or more line style entries.
  entries : Array[CT_LineProperties]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineStyleList::new(
  element : @xml.Element,
) -> CT_LineStyleList raise SchemaViolation {
  let entries : Array[CT_LineProperties] = []
  for child in ct_children(element, "ln") {
    entries.push(CT_LineProperties::new(child))
  }
  if entries.length() < 3 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path="CT_LineStyleList",
      reason="ln minOccurs=3 unmet; observed: " + entries.length().to_string(),
    )
  }
  { entries, element }
}

///|
pub fn CT_LineStyleList::to_element(self : CT_LineStyleList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EffectStyleItem — Part 1 §20.1.4.1.11
/// effectStyle (Effect Style Item). Annex A.4.1 lines 127..133.
/// Sequence: EG_EffectProperties choice (required), `scene3d`
/// (CT_Scene3D, optional), `sp3d` (CT_Shape3D, optional). No attributes.
pub(all) struct CT_EffectStyleItem {
  /// EG_EffectProperties choice — required via CT_EffectProperties wrapper.
  effect : CT_EffectProperties
  /// <scene3d> (CT_Scene3D) — optional.
  scene3d : CT_Scene3D?
  /// <sp3d> (CT_Shape3D) — optional.
  sp3d : CT_Shape3D?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectStyleItem::new(
  element : @xml.Element,
) -> CT_EffectStyleItem raise SchemaViolation {
  let effect = if ct_first_child(element, "effectLst") is Some(_) ||
    ct_first_child(element, "effectDag") is Some(_) {
    CT_EffectProperties::new(element)
  } else {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path="CT_EffectStyleItem/EG_EffectProperties",
      reason="missing required EG_EffectProperties choice (effectLst or effectDag)",
    )
  }
  let scene3d = match ct_first_child(element, "scene3d") {
    Some(c) => Some(CT_Scene3D::new(c))
    None => None
  }
  let sp3d = match ct_first_child(element, "sp3d") {
    Some(c) => Some(CT_Shape3D::new(c))
    None => None
  }
  { effect, scene3d, sp3d, element }
}

///|
pub fn CT_EffectStyleItem::to_element(
  self : CT_EffectStyleItem,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EffectStyleList — Part 1 §20.1.4.1.12
/// effectStyleLst (Effect Style List). Annex A.4.1 lines 152..157.
/// Sequence containing `effectStyle` (CT_EffectStyleItem) three or
/// more times.
pub(all) struct CT_EffectStyleList {
  /// <effectStyle>+ (CT_EffectStyleItem) — three or more entries.
  entries : Array[CT_EffectStyleItem]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EffectStyleList::new(
  element : @xml.Element,
) -> CT_EffectStyleList raise SchemaViolation {
  let entries : Array[CT_EffectStyleItem] = []
  for child in ct_children(element, "effectStyle") {
    entries.push(CT_EffectStyleItem::new(child))
  }
  if entries.length() < 3 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path="CT_EffectStyleList",
      reason="effectStyle minOccurs=3 unmet; observed: " +
        entries.length().to_string(),
    )
  }
  { entries, element }
}

///|
pub fn CT_EffectStyleList::to_element(
  self : CT_EffectStyleList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BackgroundFillStyleList — Part 1 §20.1.4.1.7
/// bgFillStyleLst (Background Fill Style List). Annex A.4.1
/// lines 158..162. Sequence containing EG_FillProperties choices three
/// or more times.
pub(all) struct CT_BackgroundFillStyleList {
  /// EG_FillProperties choices in document order (three or more).
  entries : Array[CT_FillStyleList_Entry]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BackgroundFillStyleList::new(
  element : @xml.Element,
) -> CT_BackgroundFillStyleList raise SchemaViolation {
  let entries = decode_fill_style_list_entries(
    element, "CT_BackgroundFillStyleList",
  )
  { entries, element }
}

///|
pub fn CT_BackgroundFillStyleList::to_element(
  self : CT_BackgroundFillStyleList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StyleMatrix — Part 1 §20.1.4.1.14
/// fmtScheme (Format Scheme). Annex A.4.1 lines 163..172. Sequence:
/// `fillStyleLst` (CT_FillStyleList, required), `lnStyleLst`
/// (CT_LineStyleList, required), `effectStyleLst`
/// (CT_EffectStyleList, required), `bgFillStyleLst`
/// (CT_BackgroundFillStyleList, required). Optional `name` (xsd:string,
/// default "").
pub(all) struct CT_StyleMatrix {
  /// <fillStyleLst> (CT_FillStyleList) — required.
  fill_style_lst : CT_FillStyleList
  /// <lnStyleLst> (CT_LineStyleList) — required.
  ln_style_lst : CT_LineStyleList
  /// <effectStyleLst> (CT_EffectStyleList) — required.
  effect_style_lst : CT_EffectStyleList
  /// <bgFillStyleLst> (CT_BackgroundFillStyleList) — required.
  bg_fill_style_lst : CT_BackgroundFillStyleList
  /// @name — xsd:string (optional, default "").
  name : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StyleMatrix::new(
  element : @xml.Element,
) -> CT_StyleMatrix raise SchemaViolation {
  let fill_style_lst = match ct_first_child(element, "fillStyleLst") {
    Some(c) => CT_FillStyleList::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_StyleMatrix/fillStyleLst",
        reason="missing required child element",
      )
  }
  let ln_style_lst = match ct_first_child(element, "lnStyleLst") {
    Some(c) => CT_LineStyleList::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_StyleMatrix/lnStyleLst",
        reason="missing required child element",
      )
  }
  let effect_style_lst = match ct_first_child(element, "effectStyleLst") {
    Some(c) => CT_EffectStyleList::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_StyleMatrix/effectStyleLst",
        reason="missing required child element",
      )
  }
  let bg_fill_style_lst = match ct_first_child(element, "bgFillStyleLst") {
    Some(c) => CT_BackgroundFillStyleList::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_StyleMatrix/bgFillStyleLst",
        reason="missing required child element",
      )
  }
  let name = ct_optional_string(element, "name", default="")
  {
    fill_style_lst,
    ln_style_lst,
    effect_style_lst,
    bg_fill_style_lst,
    name,
    element,
  }
}

///|
pub fn CT_StyleMatrix::to_element(self : CT_StyleMatrix) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ThemeableLineStyle — Part 1 §20.1.3.20
/// txStyles / spStyles / lnStyles content. Annex A.4.1
/// lines 2446..2451. Choice between `ln` (CT_LineProperties) and
/// `lnRef` (CT_StyleMatrixReference).
pub(all) struct CT_ThemeableLineStyle {
  /// <ln> (CT_LineProperties) choice arm.
  ln : CT_LineProperties?
  /// <lnRef> (CT_StyleMatrixReference) choice arm.
  ln_ref : CT_StyleMatrixReference?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ThemeableLineStyle::new(
  element : @xml.Element,
) -> CT_ThemeableLineStyle raise SchemaViolation {
  let ln = match ct_first_child(element, "ln") {
    Some(c) => Some(CT_LineProperties::new(c))
    None => None
  }
  let ln_ref = match ct_first_child(element, "lnRef") {
    Some(c) => Some(CT_StyleMatrixReference::new(c))
    None => None
  }
  { ln, ln_ref, element }
}

///|
pub fn CT_ThemeableLineStyle::to_element(
  self : CT_ThemeableLineStyle,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StyleMatrixReference — Part 1 §20.1.4.2.18
/// lnRef / fillRef / effectRef (Style Matrix Reference). Annex A.4.1
/// lines 2246..2251. Sequence: EG_ColorChoice (optional). Required
/// attribute `idx` (ST_StyleMatrixColumnIndex).
pub(all) struct CT_StyleMatrixReference {
  /// EG_ColorChoice projected as a CT_Color when present.
  color : CT_Color?
  /// @idx — ST_StyleMatrixColumnIndex (required, xsd:unsignedInt index).
  idx : ST_StyleMatrixColumnIndex
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StyleMatrixReference::new(
  element : @xml.Element,
) -> CT_StyleMatrixReference raise SchemaViolation {
  let color = if ct_first_child(element, "scrgbClr") is Some(_) ||
    ct_first_child(element, "srgbClr") is Some(_) ||
    ct_first_child(element, "hslClr") is Some(_) ||
    ct_first_child(element, "sysClr") is Some(_) ||
    ct_first_child(element, "schemeClr") is Some(_) ||
    ct_first_child(element, "prstClr") is Some(_) {
    Some(CT_Color::new(element))
  } else {
    None
  }
  let idx_lex = ct_required_string(
    element, "idx", "CT_StyleMatrixReference/@idx",
  )
  let idx = ST_StyleMatrixColumnIndex::parse(idx_lex)
  { color, idx, element }
}

///|
pub fn CT_StyleMatrixReference::to_element(
  self : CT_StyleMatrixReference,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShapeStyle — Part 1 §20.1.2.2.31 style
/// (Shape Style). Annex A.4.1 lines 2258..2265. Sequence: `lnRef`
/// (CT_StyleMatrixReference, required), `fillRef`
/// (CT_StyleMatrixReference, required), `effectRef`
/// (CT_StyleMatrixReference, required), `fontRef` (CT_FontReference,
/// required). No attributes.
pub(all) struct CT_ShapeStyle {
  /// <lnRef> (CT_StyleMatrixReference) — required.
  ln_ref : CT_StyleMatrixReference
  /// <fillRef> (CT_StyleMatrixReference) — required.
  fill_ref : CT_StyleMatrixReference
  /// <effectRef> (CT_StyleMatrixReference) — required.
  effect_ref : CT_StyleMatrixReference
  /// <fontRef> (CT_FontReference) — required.
  font_ref : CT_FontReference
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeStyle::new(
  element : @xml.Element,
) -> CT_ShapeStyle raise SchemaViolation {
  let ln_ref = match ct_first_child(element, "lnRef") {
    Some(c) => CT_StyleMatrixReference::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_ShapeStyle/lnRef",
        reason="missing required child element",
      )
  }
  let fill_ref = match ct_first_child(element, "fillRef") {
    Some(c) => CT_StyleMatrixReference::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_ShapeStyle/fillRef",
        reason="missing required child element",
      )
  }
  let effect_ref = match ct_first_child(element, "effectRef") {
    Some(c) => CT_StyleMatrixReference::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_ShapeStyle/effectRef",
        reason="missing required child element",
      )
  }
  let font_ref = match ct_first_child(element, "fontRef") {
    Some(c) => CT_FontReference::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_ShapeStyle/fontRef",
        reason="missing required child element",
      )
  }
  { ln_ref, fill_ref, effect_ref, font_ref, element }
}

///|
pub fn CT_ShapeStyle::to_element(self : CT_ShapeStyle) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DefaultShapeDefinition — Part 1 §20.1.4.1.27
/// spDef / lnDef / txDef body shared by CT_ObjectStyleDefaults. Annex
/// A.4.1 lines 2266..2274. Sequence: `spPr` (CT_ShapeProperties,
/// required), `bodyPr` (CT_TextBodyProperties, required), `lstStyle`
/// (CT_TextListStyle, required), `style` (CT_ShapeStyle, optional),
/// `extLst` (CT_OfficeArtExtensionList, optional). No attributes.
pub(all) struct CT_DefaultShapeDefinition {
  /// <spPr> (CT_ShapeProperties) — required.
  sp_pr : CT_ShapeProperties
  /// <bodyPr> (CT_TextBodyProperties) — required.
  body_pr : CT_TextBodyProperties
  /// <lstStyle> (CT_TextListStyle) — required.
  lst_style : CT_TextListStyle
  /// <style> (CT_ShapeStyle) — optional.
  style : CT_ShapeStyle?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DefaultShapeDefinition::new(
  element : @xml.Element,
) -> CT_DefaultShapeDefinition raise SchemaViolation {
  let sp_pr = match ct_first_child(element, "spPr") {
    Some(c) => CT_ShapeProperties::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_DefaultShapeDefinition/spPr",
        reason="missing required child element",
      )
  }
  let body_pr = match ct_first_child(element, "bodyPr") {
    Some(c) => CT_TextBodyProperties::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_DefaultShapeDefinition/bodyPr",
        reason="missing required child element",
      )
  }
  let lst_style = match ct_first_child(element, "lstStyle") {
    Some(c) => CT_TextListStyle::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_DefaultShapeDefinition/lstStyle",
        reason="missing required child element",
      )
  }
  let style = match ct_first_child(element, "style") {
    Some(c) => Some(CT_ShapeStyle::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { sp_pr, body_pr, lst_style, style, ext_lst, element }
}

///|
pub fn CT_DefaultShapeDefinition::to_element(
  self : CT_DefaultShapeDefinition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ObjectStyleDefaults — Part 1 §20.1.4.1.28
/// objectDefaults (Object Style Defaults). Annex A.4.1
/// lines 2275..2282. Sequence: `spDef` (CT_DefaultShapeDefinition,
/// optional), `lnDef` (CT_DefaultShapeDefinition, optional), `txDef`
/// (CT_DefaultShapeDefinition, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). No attributes.
pub(all) struct CT_ObjectStyleDefaults {
  /// <spDef> (CT_DefaultShapeDefinition) — optional.
  sp_def : CT_DefaultShapeDefinition?
  /// <lnDef> (CT_DefaultShapeDefinition) — optional.
  ln_def : CT_DefaultShapeDefinition?
  /// <txDef> (CT_DefaultShapeDefinition) — optional.
  tx_def : CT_DefaultShapeDefinition?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ObjectStyleDefaults::new(
  element : @xml.Element,
) -> CT_ObjectStyleDefaults raise SchemaViolation {
  let sp_def = match ct_first_child(element, "spDef") {
    Some(c) => Some(CT_DefaultShapeDefinition::new(c))
    None => None
  }
  let ln_def = match ct_first_child(element, "lnDef") {
    Some(c) => Some(CT_DefaultShapeDefinition::new(c))
    None => None
  }
  let tx_def = match ct_first_child(element, "txDef") {
    Some(c) => Some(CT_DefaultShapeDefinition::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { sp_def, ln_def, tx_def, ext_lst, element }
}

///|
pub fn CT_ObjectStyleDefaults::to_element(
  self : CT_ObjectStyleDefaults,
) -> @xml.Element {
  self.element
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
