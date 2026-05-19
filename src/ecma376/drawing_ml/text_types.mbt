// ECMA-376 Part 1 §20.1.10 DrawingML text complex types. XSD definitions
// live in Annex A.4.1 dml-main.xsd at the following line ranges:
//
//   CT_TextShapeAutofit              line  2616
//   CT_TextNoAutofit                 line  2617
//   CT_TextBodyProperties            lines 2625..2652
//   CT_TextBody                      lines 2653..2659
//   CT_TextBulletSizeFollowText      line  2726
//   CT_TextBulletSizePercent         lines 2727..2729
//   CT_TextBulletSizePoint           lines 2730..2732
//   CT_TextBulletTypefaceFollowText  line  2740
//   CT_TextAutonumberBullet          lines 2747..2750
//   CT_TextCharBullet                lines 2751..2753
//   CT_TextBlipBullet                lines 2754..2758
//   CT_TextNoBullet                  line  2759
//   CT_TextUnderlineLineFollowText   line  2842
//   CT_TextUnderlineFillFollowText   line  2843
//   CT_TextUnderlineFillGroupWrapper lines 2844..2846
//   CT_TextCharacterProperties       lines 2873..2909
//   CT_TextSpacingPercent            lines 2922..2924
//   CT_TextSpacingPoint              lines 2925..2927
//   CT_TextTabStop                   lines 2948..2951
//   CT_TextTabStopList               lines 2952..2956
//   CT_TextLineBreak                 lines 2957..2961
//   CT_TextSpacing                   lines 2962..2967
//   CT_TextParagraphProperties       lines 2994..3018
//   CT_TextField                     lines 3019..3027
//   CT_RegularTextRun                lines 3035..3040
//
// Per the ct-typing protocol each CT_X is projected as a typed struct
// with explicit attribute / child-element fields decoded from the
// source `@xml.Element`. The element is preserved so the builder can
// round-trip unmodelled content (the `to_element` writer returns the
// captured element verbatim).

///|
/// CT_TextParagraph_Run — projection of the EG_TextRun choice arm
/// (Part 1 §20.1.10) for one of `r` (regular text run), `br` (line
/// break), `fld` (field). The element-only `EG_TextRun` wrapper in
/// `model_groups.mbt` is a separate, untyped model-group container
/// owned by an unrelated chunk; this enum is the typed projection
/// embedded inside CT_TextParagraph so document order survives.
pub(all) enum CT_TextParagraph_Run {
  /// <r> (CT_RegularTextRun).
  TextRunRegular(CT_RegularTextRun)
  /// <br> (CT_TextLineBreak).
  TextRunBreak(CT_TextLineBreak)
  /// <fld> (CT_TextField).
  TextRunField(CT_TextField)
} derive(Eq, Debug)

///|
/// XSD complex type CT_TextParagraph — Part 1 §20.1.2.2.6 p (Text
/// Paragraph). Annex A.4.1 lines 2540..2546. Sequence: `pPr`
/// (CT_TextParagraphProperties, optional), EG_TextRun choice
/// (`r` | `br` | `fld`, zero or more), `endParaRPr`
/// (CT_TextCharacterProperties, optional). No attributes.
pub(all) struct CT_TextParagraph {
  /// <pPr> (CT_TextParagraphProperties) — optional.
  p_pr : CT_TextParagraphProperties?
  /// EG_TextRun choice* — zero or more runs in document order.
  runs : Array[CT_TextParagraph_Run]
  /// <endParaRPr> (CT_TextCharacterProperties) — optional.
  end_para_r_pr : CT_TextCharacterProperties?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextParagraph::new(
  element : @xml.Element,
) -> CT_TextParagraph raise SchemaViolation {
  let p_pr = match ct_first_child(element, "pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let runs : Array[CT_TextParagraph_Run] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match child.name.local_name {
          "r" => runs.push(TextRunRegular(CT_RegularTextRun::new(child)))
          "br" => runs.push(TextRunBreak(CT_TextLineBreak::new(child)))
          "fld" => runs.push(TextRunField(CT_TextField::new(child)))
          _ => ()
        }
      _ => ()
    }
  }
  let end_para_r_pr = match ct_first_child(element, "endParaRPr") {
    Some(c) => Some(CT_TextCharacterProperties::new(c))
    None => None
  }
  { p_pr, runs, end_para_r_pr, element }
}

///|
pub fn CT_TextParagraph::to_element(self : CT_TextParagraph) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextListStyle — Part 1 §20.1.2.2.4 lstStyle
/// (Text List Style). Annex A.4.1 lines 2592..2606. Sequence: `defPPr`
/// (CT_TextParagraphProperties, optional), `lvl1pPr` .. `lvl9pPr`
/// (CT_TextParagraphProperties, all optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). No attributes.
pub(all) struct CT_TextListStyle {
  /// <defPPr> (CT_TextParagraphProperties) — optional.
  def_p_pr : CT_TextParagraphProperties?
  /// <lvl1pPr> (CT_TextParagraphProperties) — optional.
  lvl1p_pr : CT_TextParagraphProperties?
  /// <lvl2pPr> (CT_TextParagraphProperties) — optional.
  lvl2p_pr : CT_TextParagraphProperties?
  /// <lvl3pPr> (CT_TextParagraphProperties) — optional.
  lvl3p_pr : CT_TextParagraphProperties?
  /// <lvl4pPr> (CT_TextParagraphProperties) — optional.
  lvl4p_pr : CT_TextParagraphProperties?
  /// <lvl5pPr> (CT_TextParagraphProperties) — optional.
  lvl5p_pr : CT_TextParagraphProperties?
  /// <lvl6pPr> (CT_TextParagraphProperties) — optional.
  lvl6p_pr : CT_TextParagraphProperties?
  /// <lvl7pPr> (CT_TextParagraphProperties) — optional.
  lvl7p_pr : CT_TextParagraphProperties?
  /// <lvl8pPr> (CT_TextParagraphProperties) — optional.
  lvl8p_pr : CT_TextParagraphProperties?
  /// <lvl9pPr> (CT_TextParagraphProperties) — optional.
  lvl9p_pr : CT_TextParagraphProperties?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextListStyle::new(
  element : @xml.Element,
) -> CT_TextListStyle raise SchemaViolation {
  let def_p_pr = match ct_first_child(element, "defPPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let lvl1p_pr = match ct_first_child(element, "lvl1pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let lvl2p_pr = match ct_first_child(element, "lvl2pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let lvl3p_pr = match ct_first_child(element, "lvl3pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let lvl4p_pr = match ct_first_child(element, "lvl4pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let lvl5p_pr = match ct_first_child(element, "lvl5pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let lvl6p_pr = match ct_first_child(element, "lvl6pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let lvl7p_pr = match ct_first_child(element, "lvl7pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let lvl8p_pr = match ct_first_child(element, "lvl8pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let lvl9p_pr = match ct_first_child(element, "lvl9pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  {
    def_p_pr,
    lvl1p_pr,
    lvl2p_pr,
    lvl3p_pr,
    lvl4p_pr,
    lvl5p_pr,
    lvl6p_pr,
    lvl7p_pr,
    lvl8p_pr,
    lvl9p_pr,
    ext_lst,
    element,
  }
}

///|
pub fn CT_TextListStyle::to_element(self : CT_TextListStyle) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextNormalAutofit — Part 1 §20.1.10.30
/// normAutofit (Normal Autofit). Annex A.4.1 lines 2610..2615. Two
/// optional attributes: `fontScale`
/// (ST_TextFontScalePercentOrPercentString, default 100%) and
/// `lnSpcReduction` (ST_TextSpacingPercentOrPercentString, default 0%).
pub(all) struct CT_TextNormalAutofit {
  /// @fontScale — ST_TextFontScalePercentOrPercentString (optional,
  /// default 100%).
  font_scale : ST_TextFontScalePercentOrPercentString
  /// @lnSpcReduction — ST_TextSpacingPercentOrPercentString (optional,
  /// default 0%).
  ln_spc_reduction : ST_TextSpacingPercentOrPercentString
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextNormalAutofit::new(
  element : @xml.Element,
) -> CT_TextNormalAutofit raise SchemaViolation {
  let font_scale = match ct_attr(element, "fontScale") {
    Some(v) => ST_TextFontScalePercentOrPercentString::parse(v)
    None => ST_TextFontScalePercentOrPercentString::parse("100%")
  }
  let ln_spc_reduction = match ct_attr(element, "lnSpcReduction") {
    Some(v) => ST_TextSpacingPercentOrPercentString::parse(v)
    None => ST_TextSpacingPercentOrPercentString::parse("0%")
  }
  { font_scale, ln_spc_reduction, element }
}

///|
pub fn CT_TextNormalAutofit::to_element(
  self : CT_TextNormalAutofit,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextShapeAutofit — Part 1 §20.1.10.78 spAutoFit
/// (Shape Autofit). Annex A.4.1 line 2616. Empty complex type — presence
/// alone selects the "shape autofit" branch of the EG_TextAutofit choice.
pub(all) struct CT_TextShapeAutofit {
  /// Empty-XSD-type marker (always true once decoded).
  autofit : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextShapeAutofit::new(element : @xml.Element) -> CT_TextShapeAutofit {
  { autofit: true, element }
}

///|
pub fn CT_TextShapeAutofit::to_element(
  self : CT_TextShapeAutofit,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextNoAutofit — Part 1 §20.1.10.29 noAutofit (No
/// Autofit). Annex A.4.1 line 2617. Empty complex type — presence alone
/// selects the "no autofit" branch of the EG_TextAutofit choice.
pub(all) struct CT_TextNoAutofit {
  /// Empty-XSD-type marker (always true once decoded).
  autofit : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextNoAutofit::new(element : @xml.Element) -> CT_TextNoAutofit {
  { autofit: true, element }
}

///|
pub fn CT_TextNoAutofit::to_element(self : CT_TextNoAutofit) -> @xml.Element {
  self.element
}

///|
/// EG_TextAutofit choice projection — Part 1 §20.1.10 (sequence
/// element in CT_TextBodyProperties). The XSD group `EG_TextAutofit`
/// selects one of `noAutofit`, `normAutofit`, `spAutoFit`.
pub(all) enum CT_TextBodyProperties_Autofit {
  /// <noAutofit> (CT_TextNoAutofit) choice arm.
  TextAutofitNone(CT_TextNoAutofit)
  /// <normAutofit> (CT_TextNormalAutofit) choice arm.
  TextAutofitNormal(CT_TextNormalAutofit)
  /// <spAutoFit> (CT_TextShapeAutofit) choice arm.
  TextAutofitShape(CT_TextShapeAutofit)
} derive(Eq, Debug)

///|
/// EG_Text3D choice projection — Part 1 §20.1.10 (sequence element in
/// CT_TextBodyProperties). The XSD group `EG_Text3D` selects one of
/// `sp3d` (CT_Shape3D) or `flatTx` (CT_FlatText).
pub(all) enum CT_TextBodyProperties_Text3D {
  /// <sp3d> (CT_Shape3D) choice arm.
  Text3DShape(CT_Shape3D)
  /// <flatTx> (CT_FlatText) choice arm.
  Text3DFlat(CT_FlatText)
} derive(Eq, Debug)

///|
/// XSD complex type CT_TextBodyProperties — Part 1 §20.1.10.4 bodyPr
/// (Body Properties). Annex A.4.1 lines 2625..2652. Sequence:
/// `prstTxWarp` (CT_PresetTextShape, optional), EG_TextAutofit choice
/// (optional), `scene3d` (CT_Scene3D, optional), EG_Text3D choice
/// (optional), `extLst` (CT_OfficeArtExtensionList, optional). 23
/// optional attributes for rotation, overflow, inset, columns, and
/// anchoring; `upright` defaults `false`.
pub(all) struct CT_TextBodyProperties {
  /// <prstTxWarp> (CT_PresetTextShape) — optional.
  prst_tx_warp : CT_PresetTextShape?
  /// EG_TextAutofit choice — optional one of noAutofit / normAutofit / spAutoFit.
  autofit : CT_TextBodyProperties_Autofit?
  /// <scene3d> (CT_Scene3D) — optional.
  scene3d : CT_Scene3D?
  /// EG_Text3D choice — optional one of sp3d / flatTx.
  text3d : CT_TextBodyProperties_Text3D?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @rot — ST_Angle (optional).
  rot : ST_Angle?
  /// @spcFirstLastPara — xsd:boolean (optional).
  spc_first_last_para : Bool?
  /// @vertOverflow — ST_TextVertOverflowType (optional).
  vert_overflow : ST_TextVertOverflowType?
  /// @horzOverflow — ST_TextHorzOverflowType (optional).
  horz_overflow : ST_TextHorzOverflowType?
  /// @vert — ST_TextVerticalType (optional).
  vert : ST_TextVerticalType?
  /// @wrap — ST_TextWrappingType (optional).
  wrap : ST_TextWrappingType?
  /// @lIns — ST_Coordinate32 (optional).
  l_ins : ST_Coordinate32?
  /// @tIns — ST_Coordinate32 (optional).
  t_ins : ST_Coordinate32?
  /// @rIns — ST_Coordinate32 (optional).
  r_ins : ST_Coordinate32?
  /// @bIns — ST_Coordinate32 (optional).
  b_ins : ST_Coordinate32?
  /// @numCol — ST_TextColumnCount (optional).
  num_col : ST_TextColumnCount?
  /// @spcCol — ST_PositiveCoordinate32 (optional).
  spc_col : ST_PositiveCoordinate32?
  /// @rtlCol — xsd:boolean (optional).
  rtl_col : Bool?
  /// @fromWordArt — xsd:boolean (optional).
  from_word_art : Bool?
  /// @anchor — ST_TextAnchoringType (optional).
  anchor : ST_TextAnchoringType?
  /// @anchorCtr — xsd:boolean (optional).
  anchor_ctr : Bool?
  /// @forceAA — xsd:boolean (optional).
  force_aa : Bool?
  /// @upright — xsd:boolean (optional, default false).
  upright : Bool
  /// @compatLnSpc — xsd:boolean (optional).
  compat_ln_spc : Bool?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBodyProperties::new(
  element : @xml.Element,
) -> CT_TextBodyProperties raise SchemaViolation {
  let prst_tx_warp = match ct_first_child(element, "prstTxWarp") {
    Some(c) => Some(CT_PresetTextShape::new(c))
    None => None
  }
  let autofit : CT_TextBodyProperties_Autofit? = match
    ct_first_child(element, "noAutofit") {
    Some(c) => Some(TextAutofitNone(CT_TextNoAutofit::new(c)))
    None =>
      match ct_first_child(element, "normAutofit") {
        Some(c) => Some(TextAutofitNormal(CT_TextNormalAutofit::new(c)))
        None =>
          match ct_first_child(element, "spAutoFit") {
            Some(c) => Some(TextAutofitShape(CT_TextShapeAutofit::new(c)))
            None => None
          }
      }
  }
  let scene3d = match ct_first_child(element, "scene3d") {
    Some(c) => Some(CT_Scene3D::new(c))
    None => None
  }
  let text3d : CT_TextBodyProperties_Text3D? = match
    ct_first_child(element, "sp3d") {
    Some(c) => Some(Text3DShape(CT_Shape3D::new(c)))
    None =>
      match ct_first_child(element, "flatTx") {
        Some(c) => Some(Text3DFlat(CT_FlatText::new(c)))
        None => None
      }
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let rot = match ct_attr(element, "rot") {
    Some(v) => Some(ST_Angle::parse(v))
    None => None
  }
  let spc_first_last_para = match ct_attr(element, "spcFirstLastPara") {
    Some(v) =>
      Some(ct_parse_bool_lex(v, "CT_TextBodyProperties/@spcFirstLastPara"))
    None => None
  }
  let vert_overflow = match ct_attr(element, "vertOverflow") {
    Some(v) => Some(ST_TextVertOverflowType::parse(v))
    None => None
  }
  let horz_overflow = match ct_attr(element, "horzOverflow") {
    Some(v) => Some(ST_TextHorzOverflowType::parse(v))
    None => None
  }
  let vert = match ct_attr(element, "vert") {
    Some(v) => Some(ST_TextVerticalType::parse(v))
    None => None
  }
  let wrap = match ct_attr(element, "wrap") {
    Some(v) => Some(ST_TextWrappingType::parse(v))
    None => None
  }
  let l_ins = match ct_attr(element, "lIns") {
    Some(v) => Some(ST_Coordinate32::parse(v))
    None => None
  }
  let t_ins = match ct_attr(element, "tIns") {
    Some(v) => Some(ST_Coordinate32::parse(v))
    None => None
  }
  let r_ins = match ct_attr(element, "rIns") {
    Some(v) => Some(ST_Coordinate32::parse(v))
    None => None
  }
  let b_ins = match ct_attr(element, "bIns") {
    Some(v) => Some(ST_Coordinate32::parse(v))
    None => None
  }
  let num_col = match ct_attr(element, "numCol") {
    Some(v) => Some(ST_TextColumnCount::parse(v))
    None => None
  }
  let spc_col = match ct_attr(element, "spcCol") {
    Some(v) => Some(ST_PositiveCoordinate32::parse(v))
    None => None
  }
  let rtl_col = match ct_attr(element, "rtlCol") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_TextBodyProperties/@rtlCol"))
    None => None
  }
  let from_word_art = match ct_attr(element, "fromWordArt") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_TextBodyProperties/@fromWordArt"))
    None => None
  }
  let anchor = match ct_attr(element, "anchor") {
    Some(v) => Some(ST_TextAnchoringType::parse(v))
    None => None
  }
  let anchor_ctr = match ct_attr(element, "anchorCtr") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_TextBodyProperties/@anchorCtr"))
    None => None
  }
  let force_aa = match ct_attr(element, "forceAA") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_TextBodyProperties/@forceAA"))
    None => None
  }
  let upright = ct_optional_bool(
    element,
    "upright",
    default=false,
    "CT_TextBodyProperties/@upright",
  )
  let compat_ln_spc = match ct_attr(element, "compatLnSpc") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_TextBodyProperties/@compatLnSpc"))
    None => None
  }
  {
    prst_tx_warp,
    autofit,
    scene3d,
    text3d,
    ext_lst,
    rot,
    spc_first_last_para,
    vert_overflow,
    horz_overflow,
    vert,
    wrap,
    l_ins,
    t_ins,
    r_ins,
    b_ins,
    num_col,
    spc_col,
    rtl_col,
    from_word_art,
    anchor,
    anchor_ctr,
    force_aa,
    upright,
    compat_ln_spc,
    element,
  }
}

///|
pub fn CT_TextBodyProperties::to_element(
  self : CT_TextBodyProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextBody — Part 1 §20.1.2.2.40 txBody (Shape
/// Text Body). Annex A.4.1 lines 2653..2659. Sequence: `bodyPr`
/// (CT_TextBodyProperties, required), `lstStyle` (CT_TextListStyle,
/// optional), `p` (CT_TextParagraph, one or more). No attributes.
pub(all) struct CT_TextBody {
  /// <bodyPr> (CT_TextBodyProperties) — required.
  body_pr : CT_TextBodyProperties
  /// <lstStyle> (CT_TextListStyle) — optional.
  lst_style : CT_TextListStyle?
  /// <p>+ (CT_TextParagraph) — one or more paragraphs in document order.
  paragraphs : Array[CT_TextParagraph]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBody::new(
  element : @xml.Element,
) -> CT_TextBody raise SchemaViolation {
  let body_pr = match ct_first_child(element, "bodyPr") {
    Some(c) => CT_TextBodyProperties::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_TextBody/bodyPr",
        reason="missing required child element",
      )
  }
  let lst_style = match ct_first_child(element, "lstStyle") {
    Some(c) => Some(CT_TextListStyle::new(c))
    None => None
  }
  let paragraphs : Array[CT_TextParagraph] = []
  for child in ct_children(element, "p") {
    paragraphs.push(CT_TextParagraph::new(child))
  }
  { body_pr, lst_style, paragraphs, element }
}

///|
pub fn CT_TextBody::to_element(self : CT_TextBody) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextBulletSizeFollowText — Part 1 §20.1.10.10
/// buSzTx (Bullet Size Follow Text). Annex A.4.1 line 2726. Empty
/// complex type — presence selects the "bullet size follows surrounding
/// text" branch of the EG_TextBulletSize choice.
pub(all) struct CT_TextBulletSizeFollowText {
  /// Empty-XSD-type marker (always true once decoded).
  follow : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBulletSizeFollowText::new(
  element : @xml.Element,
) -> CT_TextBulletSizeFollowText {
  { follow: true, element }
}

///|
pub fn CT_TextBulletSizeFollowText::to_element(
  self : CT_TextBulletSizeFollowText,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextBulletSizePercent — Part 1 §20.1.10.11
/// buSzPct (Bullet Size Percentage). Annex A.4.1 lines 2727..2729.
/// One required attribute: `val` (ST_TextBulletSizePercent).
pub(all) struct CT_TextBulletSizePercent {
  /// @val — ST_TextBulletSizePercent (required).
  val : ST_TextBulletSizePercent
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBulletSizePercent::new(
  element : @xml.Element,
) -> CT_TextBulletSizePercent raise SchemaViolation {
  let lex = ct_required_string(element, "val", "CT_TextBulletSizePercent/@val")
  let val = ST_TextBulletSizePercent::parse(lex)
  { val, element }
}

///|
pub fn CT_TextBulletSizePercent::to_element(
  self : CT_TextBulletSizePercent,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextBulletSizePoint — Part 1 §20.1.10.12
/// buSzPts (Bullet Size Points). Annex A.4.1 lines 2730..2732. One
/// required attribute: `val` (ST_TextFontSize).
pub(all) struct CT_TextBulletSizePoint {
  /// @val — ST_TextFontSize (required).
  val : ST_TextFontSize
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBulletSizePoint::new(
  element : @xml.Element,
) -> CT_TextBulletSizePoint raise SchemaViolation {
  let lex = ct_required_string(element, "val", "CT_TextBulletSizePoint/@val")
  let val = ST_TextFontSize::parse(lex)
  { val, element }
}

///|
pub fn CT_TextBulletSizePoint::to_element(
  self : CT_TextBulletSizePoint,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextBulletTypefaceFollowText — Part 1 §20.1.10.16
/// buFontTx (Bullet Typeface Follow Text). Annex A.4.1 line 2740. Empty
/// complex type — presence selects the "bullet typeface follows text"
/// branch of the EG_TextBulletTypeface choice.
pub(all) struct CT_TextBulletTypefaceFollowText {
  /// Empty-XSD-type marker (always true once decoded).
  follow : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBulletTypefaceFollowText::new(
  element : @xml.Element,
) -> CT_TextBulletTypefaceFollowText {
  { follow: true, element }
}

///|
pub fn CT_TextBulletTypefaceFollowText::to_element(
  self : CT_TextBulletTypefaceFollowText,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextAutonumberBullet — Part 1 §20.1.10.6
/// buAutoNum (Auto-numbered Bullet). Annex A.4.1 lines 2747..2750. One
/// required attribute `type` (ST_TextAutonumberScheme) and one optional
/// attribute `startAt` (ST_TextBulletStartAtNum, default 1).
pub(all) struct CT_TextAutonumberBullet {
  /// @type — ST_TextAutonumberScheme (required).
  type_ : ST_TextAutonumberScheme
  /// @startAt — ST_TextBulletStartAtNum (optional, default 1).
  start_at : ST_TextBulletStartAtNum
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextAutonumberBullet::new(
  element : @xml.Element,
) -> CT_TextAutonumberBullet raise SchemaViolation {
  let type_lex = ct_required_string(
    element, "type", "CT_TextAutonumberBullet/@type",
  )
  let type_ = ST_TextAutonumberScheme::parse(type_lex)
  let start_at = match ct_attr(element, "startAt") {
    Some(v) => ST_TextBulletStartAtNum::parse(v)
    None => ST_TextBulletStartAtNum::parse("1")
  }
  { type_, start_at, element }
}

///|
pub fn CT_TextAutonumberBullet::to_element(
  self : CT_TextAutonumberBullet,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextCharBullet — Part 1 §20.1.10.13 buChar
/// (Character Bullet). Annex A.4.1 lines 2751..2753. One required
/// attribute: `char` (xsd:string).
pub(all) struct CT_TextCharBullet {
  /// @char — xsd:string (required).
  char : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextCharBullet::new(
  element : @xml.Element,
) -> CT_TextCharBullet raise SchemaViolation {
  let char = ct_required_string(element, "char", "CT_TextCharBullet/@char")
  { char, element }
}

///|
pub fn CT_TextCharBullet::to_element(self : CT_TextCharBullet) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextBlipBullet — Part 1 §20.1.10.7 buBlip
/// (Picture Bullet). Annex A.4.1 lines 2754..2758. One required child
/// `blip` (CT_Blip).
pub(all) struct CT_TextBlipBullet {
  /// <blip> (CT_Blip) — required.
  blip : CT_Blip
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBlipBullet::new(
  element : @xml.Element,
) -> CT_TextBlipBullet raise SchemaViolation {
  let blip = match ct_first_child(element, "blip") {
    Some(c) => CT_Blip::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_TextBlipBullet/blip",
        reason="missing required child element",
      )
  }
  { blip, element }
}

///|
pub fn CT_TextBlipBullet::to_element(self : CT_TextBlipBullet) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextNoBullet — Part 1 §20.1.10.31 buNone (No
/// Bullet). Annex A.4.1 line 2759. Empty complex type — presence selects
/// the "no bullet" branch of the EG_TextBullet choice.
pub(all) struct CT_TextNoBullet {
  /// Empty-XSD-type marker (always true once decoded).
  none_bullet : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextNoBullet::new(element : @xml.Element) -> CT_TextNoBullet {
  { none_bullet: true, element }
}

///|
pub fn CT_TextNoBullet::to_element(self : CT_TextNoBullet) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextUnderlineLineFollowText — Part 1 §20.1.10.88
/// uLnTx (Underline Line Follow Text). Annex A.4.1 line 2842. Empty
/// complex type — presence selects the "underline line follows text"
/// branch of the EG_TextUnderlineLine choice.
pub(all) struct CT_TextUnderlineLineFollowText {
  /// Empty-XSD-type marker (always true once decoded).
  follow : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextUnderlineLineFollowText::new(
  element : @xml.Element,
) -> CT_TextUnderlineLineFollowText {
  { follow: true, element }
}

///|
pub fn CT_TextUnderlineLineFollowText::to_element(
  self : CT_TextUnderlineLineFollowText,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextUnderlineFillFollowText — Part 1 §20.1.10.86
/// uFillTx (Underline Fill Follow Text). Annex A.4.1 line 2843. Empty
/// complex type — presence selects the "underline fill follows text"
/// branch of the EG_TextUnderlineFill choice.
pub(all) struct CT_TextUnderlineFillFollowText {
  /// Empty-XSD-type marker (always true once decoded).
  follow : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextUnderlineFillFollowText::new(
  element : @xml.Element,
) -> CT_TextUnderlineFillFollowText {
  { follow: true, element }
}

///|
pub fn CT_TextUnderlineFillFollowText::to_element(
  self : CT_TextUnderlineFillFollowText,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextUnderlineFillGroupWrapper — Part 1
/// §20.1.10.87 uFill (Underline Fill). Annex A.4.1 lines 2844..2846.
/// Contains the EG_FillProperties choice required exactly once (one of
/// `noFill`, `solidFill`, `gradFill`, `blipFill`, `pattFill`, `grpFill`).
pub(all) struct CT_TextUnderlineFillGroupWrapper {
  /// <noFill> (CT_NoFillProperties) — EG_FillProperties choice arm.
  no_fill : CT_NoFillProperties?
  /// <solidFill> (CT_SolidColorFillProperties) — EG_FillProperties arm.
  solid_fill : CT_SolidColorFillProperties?
  /// <gradFill> (CT_GradientFillProperties) — EG_FillProperties arm.
  grad_fill : CT_GradientFillProperties?
  /// <blipFill> (CT_BlipFillProperties) — EG_FillProperties arm.
  blip_fill : CT_BlipFillProperties?
  /// <pattFill> (CT_PatternFillProperties) — EG_FillProperties arm.
  patt_fill : CT_PatternFillProperties?
  /// <grpFill> (CT_GroupFillProperties) — EG_FillProperties arm.
  grp_fill : CT_GroupFillProperties?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextUnderlineFillGroupWrapper::new(
  element : @xml.Element,
) -> CT_TextUnderlineFillGroupWrapper raise SchemaViolation {
  let no_fill = match ct_first_child(element, "noFill") {
    Some(c) => Some(CT_NoFillProperties::new(c))
    None => None
  }
  let solid_fill = match ct_first_child(element, "solidFill") {
    Some(c) => Some(CT_SolidColorFillProperties::new(c))
    None => None
  }
  let grad_fill = match ct_first_child(element, "gradFill") {
    Some(c) => Some(CT_GradientFillProperties::new(c))
    None => None
  }
  let blip_fill = match ct_first_child(element, "blipFill") {
    Some(c) => Some(CT_BlipFillProperties::new(c))
    None => None
  }
  let patt_fill = match ct_first_child(element, "pattFill") {
    Some(c) => Some(CT_PatternFillProperties::new(c))
    None => None
  }
  let grp_fill = match ct_first_child(element, "grpFill") {
    Some(c) => Some(CT_GroupFillProperties::new(c))
    None => None
  }
  { no_fill, solid_fill, grad_fill, blip_fill, patt_fill, grp_fill, element }
}

///|
pub fn CT_TextUnderlineFillGroupWrapper::to_element(
  self : CT_TextUnderlineFillGroupWrapper,
) -> @xml.Element {
  self.element
}

///|
/// EG_TextUnderlineLine choice projection — Part 1 §20.1.10. The XSD
/// group `EG_TextUnderlineLine` selects one of `uLnTx`
/// (CT_TextUnderlineLineFollowText) or `uLn` (CT_LineProperties).
pub(all) enum CT_TextCharacterProperties_UnderlineLine {
  /// <uLnTx> (CT_TextUnderlineLineFollowText) choice arm.
  UnderlineLineFollow(CT_TextUnderlineLineFollowText)
  /// <uLn> (CT_LineProperties) choice arm.
  UnderlineLineExplicit(CT_LineProperties)
} derive(Eq, Debug)

///|
/// EG_TextUnderlineFill choice projection — Part 1 §20.1.10. The XSD
/// group `EG_TextUnderlineFill` selects one of `uFillTx`
/// (CT_TextUnderlineFillFollowText) or `uFill`
/// (CT_TextUnderlineFillGroupWrapper).
pub(all) enum CT_TextCharacterProperties_UnderlineFill {
  /// <uFillTx> (CT_TextUnderlineFillFollowText) choice arm.
  UnderlineFillFollow(CT_TextUnderlineFillFollowText)
  /// <uFill> (CT_TextUnderlineFillGroupWrapper) choice arm.
  UnderlineFillExplicit(CT_TextUnderlineFillGroupWrapper)
} derive(Eq, Debug)

///|
/// XSD complex type CT_TextCharacterProperties — Part 1 §20.1.10.21
/// defRPr / rPr / endParaRPr (Text Run Properties). Annex A.4.1
/// lines 2873..2909. Sequence: `ln` (CT_LineProperties, optional),
/// EG_FillProperties (optional), EG_EffectProperties (optional),
/// `highlight` (CT_Color, optional), EG_TextUnderlineLine (optional),
/// EG_TextUnderlineFill (optional), `latin` / `ea` / `cs` / `sym`
/// (CT_TextFont, all optional), `hlinkClick` / `hlinkMouseOver`
/// (CT_Hyperlink, optional), `rtl` (CT_Boolean, optional, raw element
/// because CT_Boolean is not yet typed in this package), `extLst`
/// (CT_OfficeArtExtensionList, optional). Twenty optional attributes
/// for run styling.
pub(all) struct CT_TextCharacterProperties {
  /// <ln> (CT_LineProperties) — optional.
  ln : CT_LineProperties?
  /// EG_FillProperties choice — optional via CT_FillProperties wrapper.
  fill : CT_FillProperties?
  /// EG_EffectProperties choice — optional via CT_EffectProperties wrapper.
  effect : CT_EffectProperties?
  /// <highlight> (CT_Color) — optional.
  highlight : CT_Color?
  /// EG_TextUnderlineLine choice — optional.
  underline_line : CT_TextCharacterProperties_UnderlineLine?
  /// EG_TextUnderlineFill choice — optional.
  underline_fill : CT_TextCharacterProperties_UnderlineFill?
  /// <latin> (CT_TextFont) — optional.
  latin : CT_TextFont?
  /// <ea> (CT_TextFont) — optional.
  ea : CT_TextFont?
  /// <cs> (CT_TextFont) — optional.
  cs : CT_TextFont?
  /// <sym> (CT_TextFont) — optional.
  sym : CT_TextFont?
  /// <hlinkClick> (CT_Hyperlink) — optional.
  hlink_click : CT_Hyperlink?
  /// <hlinkMouseOver> (CT_Hyperlink) — optional.
  hlink_mouse_over : CT_Hyperlink?
  /// <rtl> (CT_Boolean) — optional. Raw element pending CT_Boolean
  /// typed projection in a future chunk.
  rtl : @xml.Element?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @kumimoji — xsd:boolean (optional).
  kumimoji : Bool?
  /// @lang — s:ST_Lang (optional, BCP-47 language tag lexical).
  lang : String?
  /// @altLang — s:ST_Lang (optional, BCP-47 language tag lexical).
  alt_lang : String?
  /// @sz — ST_TextFontSize (optional).
  sz : ST_TextFontSize?
  /// @b — xsd:boolean (optional).
  b : Bool?
  /// @i — xsd:boolean (optional).
  i : Bool?
  /// @u — ST_TextUnderlineType (optional).
  u : ST_TextUnderlineType?
  /// @strike — ST_TextStrikeType (optional).
  strike : ST_TextStrikeType?
  /// @kern — ST_TextNonNegativePoint (optional).
  kern : ST_TextNonNegativePoint?
  /// @cap — ST_TextCapsType (optional, default "none").
  cap : ST_TextCapsType
  /// @spc — ST_TextPoint (optional).
  spc : ST_TextPoint?
  /// @normalizeH — xsd:boolean (optional).
  normalize_h : Bool?
  /// @baseline — ST_Percentage (optional).
  baseline : ST_Percentage?
  /// @noProof — xsd:boolean (optional).
  no_proof : Bool?
  /// @dirty — xsd:boolean (optional, default true).
  dirty : Bool
  /// @err — xsd:boolean (optional, default false).
  err : Bool
  /// @smtClean — xsd:boolean (optional, default true).
  smt_clean : Bool
  /// @smtId — xsd:unsignedInt (optional, default 0).
  smt_id : UInt
  /// @bmk — xsd:string (optional).
  bmk : String?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextCharacterProperties::new(
  element : @xml.Element,
) -> CT_TextCharacterProperties raise SchemaViolation {
  let ln = match ct_first_child(element, "ln") {
    Some(c) => Some(CT_LineProperties::new(c))
    None => None
  }
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
  let highlight = match ct_first_child(element, "highlight") {
    Some(c) => Some(CT_Color::new(c))
    None => None
  }
  let underline_line : CT_TextCharacterProperties_UnderlineLine? = match
    ct_first_child(element, "uLnTx") {
    Some(c) => Some(UnderlineLineFollow(CT_TextUnderlineLineFollowText::new(c)))
    None =>
      match ct_first_child(element, "uLn") {
        Some(c) => Some(UnderlineLineExplicit(CT_LineProperties::new(c)))
        None => None
      }
  }
  let underline_fill : CT_TextCharacterProperties_UnderlineFill? = match
    ct_first_child(element, "uFillTx") {
    Some(c) => Some(UnderlineFillFollow(CT_TextUnderlineFillFollowText::new(c)))
    None =>
      match ct_first_child(element, "uFill") {
        Some(c) =>
          Some(UnderlineFillExplicit(CT_TextUnderlineFillGroupWrapper::new(c)))
        None => None
      }
  }
  let latin = match ct_first_child(element, "latin") {
    Some(c) => Some(CT_TextFont::new(c))
    None => None
  }
  let ea = match ct_first_child(element, "ea") {
    Some(c) => Some(CT_TextFont::new(c))
    None => None
  }
  let cs = match ct_first_child(element, "cs") {
    Some(c) => Some(CT_TextFont::new(c))
    None => None
  }
  let sym = match ct_first_child(element, "sym") {
    Some(c) => Some(CT_TextFont::new(c))
    None => None
  }
  let hlink_click = match ct_first_child(element, "hlinkClick") {
    Some(c) => Some(CT_Hyperlink::new(c))
    None => None
  }
  let hlink_mouse_over = match ct_first_child(element, "hlinkMouseOver") {
    Some(c) => Some(CT_Hyperlink::new(c))
    None => None
  }
  let rtl = ct_first_child(element, "rtl")
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let kumimoji = match ct_attr(element, "kumimoji") {
    Some(v) =>
      Some(ct_parse_bool_lex(v, "CT_TextCharacterProperties/@kumimoji"))
    None => None
  }
  let lang = ct_attr(element, "lang")
  let alt_lang = ct_attr(element, "altLang")
  let sz = match ct_attr(element, "sz") {
    Some(v) => Some(ST_TextFontSize::parse(v))
    None => None
  }
  let b = match ct_attr(element, "b") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_TextCharacterProperties/@b"))
    None => None
  }
  let i = match ct_attr(element, "i") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_TextCharacterProperties/@i"))
    None => None
  }
  let u = match ct_attr(element, "u") {
    Some(v) => Some(ST_TextUnderlineType::parse(v))
    None => None
  }
  let strike = match ct_attr(element, "strike") {
    Some(v) => Some(ST_TextStrikeType::parse(v))
    None => None
  }
  let kern = match ct_attr(element, "kern") {
    Some(v) => Some(ST_TextNonNegativePoint::parse(v))
    None => None
  }
  let cap = match ct_attr(element, "cap") {
    Some(v) => ST_TextCapsType::parse(v)
    None => ST_TextCapsType::parse("none")
  }
  let spc = match ct_attr(element, "spc") {
    Some(v) => Some(ST_TextPoint::parse(v))
    None => None
  }
  let normalize_h = match ct_attr(element, "normalizeH") {
    Some(v) =>
      Some(ct_parse_bool_lex(v, "CT_TextCharacterProperties/@normalizeH"))
    None => None
  }
  let baseline = match ct_attr(element, "baseline") {
    Some(v) => Some(ST_Percentage::parse(v))
    None => None
  }
  let no_proof = match ct_attr(element, "noProof") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_TextCharacterProperties/@noProof"))
    None => None
  }
  let dirty = ct_optional_bool(
    element,
    "dirty",
    default=true,
    "CT_TextCharacterProperties/@dirty",
  )
  let err = ct_optional_bool(
    element,
    "err",
    default=false,
    "CT_TextCharacterProperties/@err",
  )
  let smt_clean = ct_optional_bool(
    element,
    "smtClean",
    default=true,
    "CT_TextCharacterProperties/@smtClean",
  )
  let smt_id = ct_optional_uint(
    element,
    "smtId",
    default=0U,
    "CT_TextCharacterProperties/@smtId",
  )
  let bmk = ct_attr(element, "bmk")
  {
    ln,
    fill,
    effect,
    highlight,
    underline_line,
    underline_fill,
    latin,
    ea,
    cs,
    sym,
    hlink_click,
    hlink_mouse_over,
    rtl,
    ext_lst,
    kumimoji,
    lang,
    alt_lang,
    sz,
    b,
    i,
    u,
    strike,
    kern,
    cap,
    spc,
    normalize_h,
    baseline,
    no_proof,
    dirty,
    err,
    smt_clean,
    smt_id,
    bmk,
    element,
  }
}

///|
pub fn CT_TextCharacterProperties::to_element(
  self : CT_TextCharacterProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextSpacingPercent — Part 1 §20.1.10.81 spcPct
/// (Spacing Percent). Annex A.4.1 lines 2922..2924. One required
/// attribute: `val` (ST_TextSpacingPercentOrPercentString).
pub(all) struct CT_TextSpacingPercent {
  /// @val — ST_TextSpacingPercentOrPercentString (required).
  val : ST_TextSpacingPercentOrPercentString
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextSpacingPercent::new(
  element : @xml.Element,
) -> CT_TextSpacingPercent raise SchemaViolation {
  let lex = ct_required_string(element, "val", "CT_TextSpacingPercent/@val")
  let val = ST_TextSpacingPercentOrPercentString::parse(lex)
  { val, element }
}

///|
pub fn CT_TextSpacingPercent::to_element(
  self : CT_TextSpacingPercent,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextSpacingPoint — Part 1 §20.1.10.82 spcPts
/// (Spacing Points). Annex A.4.1 lines 2925..2927. One required
/// attribute: `val` (ST_TextSpacingPoint).
pub(all) struct CT_TextSpacingPoint {
  /// @val — ST_TextSpacingPoint (required).
  val : ST_TextSpacingPoint
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextSpacingPoint::new(
  element : @xml.Element,
) -> CT_TextSpacingPoint raise SchemaViolation {
  let lex = ct_required_string(element, "val", "CT_TextSpacingPoint/@val")
  let val = ST_TextSpacingPoint::parse(lex)
  { val, element }
}

///|
pub fn CT_TextSpacingPoint::to_element(
  self : CT_TextSpacingPoint,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextTabStop — Part 1 §20.1.10.84 tab (Tab Stop).
/// Annex A.4.1 lines 2948..2951. Two optional attributes: `pos`
/// (ST_Coordinate32) and `algn` (ST_TextTabAlignType).
pub(all) struct CT_TextTabStop {
  /// @pos — ST_Coordinate32 (optional).
  pos : ST_Coordinate32?
  /// @algn — ST_TextTabAlignType (optional).
  algn : ST_TextTabAlignType?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextTabStop::new(
  element : @xml.Element,
) -> CT_TextTabStop raise SchemaViolation {
  let pos = match ct_attr(element, "pos") {
    Some(v) => Some(ST_Coordinate32::parse(v))
    None => None
  }
  let algn = match ct_attr(element, "algn") {
    Some(v) => Some(ST_TextTabAlignType::parse(v))
    None => None
  }
  { pos, algn, element }
}

///|
pub fn CT_TextTabStop::to_element(self : CT_TextTabStop) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextTabStopList — Part 1 §20.1.10.85 tabLst
/// (Tab Stop List). Annex A.4.1 lines 2952..2956. Sequence containing
/// `tab` (CT_TextTabStop) zero up to 32 times.
pub(all) struct CT_TextTabStopList {
  /// <tab>* (CT_TextTabStop) — zero to 32 entries in document order.
  tabs : Array[CT_TextTabStop]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextTabStopList::new(
  element : @xml.Element,
) -> CT_TextTabStopList raise SchemaViolation {
  let tabs : Array[CT_TextTabStop] = []
  for child in ct_children(element, "tab") {
    tabs.push(CT_TextTabStop::new(child))
  }
  if tabs.length() > 32 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path="CT_TextTabStopList",
      reason="tab maxOccurs=32 exceeded: " + tabs.length().to_string(),
    )
  }
  { tabs, element }
}

///|
pub fn CT_TextTabStopList::to_element(
  self : CT_TextTabStopList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextLineBreak — Part 1 §20.1.10.27 br (Text
/// Line Break). Annex A.4.1 lines 2957..2961. One optional child `rPr`
/// (CT_TextCharacterProperties). No attributes.
pub(all) struct CT_TextLineBreak {
  /// <rPr> (CT_TextCharacterProperties) — optional run properties for the break.
  r_pr : CT_TextCharacterProperties?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextLineBreak::new(
  element : @xml.Element,
) -> CT_TextLineBreak raise SchemaViolation {
  let r_pr = match ct_first_child(element, "rPr") {
    Some(c) => Some(CT_TextCharacterProperties::new(c))
    None => None
  }
  { r_pr, element }
}

///|
pub fn CT_TextLineBreak::to_element(self : CT_TextLineBreak) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextSpacing — Part 1 §20.1.10.79 lnSpc / spcBef /
/// spcAft (Text Spacing). Annex A.4.1 lines 2962..2967. Choice between
/// `spcPct` (CT_TextSpacingPercent) and `spcPts` (CT_TextSpacingPoint).
pub(all) struct CT_TextSpacing {
  /// <spcPct> (CT_TextSpacingPercent) choice arm.
  spc_pct : CT_TextSpacingPercent?
  /// <spcPts> (CT_TextSpacingPoint) choice arm.
  spc_pts : CT_TextSpacingPoint?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextSpacing::new(
  element : @xml.Element,
) -> CT_TextSpacing raise SchemaViolation {
  let spc_pct = match ct_first_child(element, "spcPct") {
    Some(c) => Some(CT_TextSpacingPercent::new(c))
    None => None
  }
  let spc_pts = match ct_first_child(element, "spcPts") {
    Some(c) => Some(CT_TextSpacingPoint::new(c))
    None => None
  }
  { spc_pct, spc_pts, element }
}

///|
pub fn CT_TextSpacing::to_element(self : CT_TextSpacing) -> @xml.Element {
  self.element
}

///|
/// EG_TextBulletColor choice projection — Part 1 §20.1.10. Single arm
/// among `buClrTx` (color follows text, no typed CT_* yet so element
/// preserved raw) or `buClr` (typed CT_Color). Two-arm enum so callers
/// can distinguish at the schema-correct granularity.
pub(all) enum CT_TextParagraphProperties_BulletColor {
  /// <buClrTx> follow-text variant. Empty element; preserved raw.
  BulletColorFollow(@xml.Element)
  /// <buClr> typed colour.
  BulletColorExplicit(CT_Color)
} derive(Eq, Debug)

///|
/// EG_TextBulletSize choice projection — Part 1 §20.1.10. One of
/// `buSzTx` (CT_TextBulletSizeFollowText), `buSzPct`
/// (CT_TextBulletSizePercent), `buSzPts` (CT_TextBulletSizePoint).
pub(all) enum CT_TextParagraphProperties_BulletSize {
  /// <buSzTx> follow-text size.
  BulletSizeFollow(CT_TextBulletSizeFollowText)
  /// <buSzPct> percentage size.
  BulletSizePercent(CT_TextBulletSizePercent)
  /// <buSzPts> points size.
  BulletSizePoint(CT_TextBulletSizePoint)
} derive(Eq, Debug)

///|
/// EG_TextBulletTypeface choice projection — Part 1 §20.1.10. One of
/// `buFontTx` (CT_TextBulletTypefaceFollowText) or `buFont`
/// (CT_TextFont).
pub(all) enum CT_TextParagraphProperties_BulletTypeface {
  /// <buFontTx> typeface follows text.
  BulletTypefaceFollow(CT_TextBulletTypefaceFollowText)
  /// <buFont> explicit typeface.
  BulletTypefaceExplicit(CT_TextFont)
} derive(Eq, Debug)

///|
/// EG_TextBullet choice projection — Part 1 §20.1.10. One of `buNone`
/// (CT_TextNoBullet), `buAutoNum` (CT_TextAutonumberBullet), `buChar`
/// (CT_TextCharBullet), `buBlip` (CT_TextBlipBullet).
pub(all) enum CT_TextParagraphProperties_Bullet {
  /// <buNone> no-bullet variant.
  BulletNone(CT_TextNoBullet)
  /// <buAutoNum> auto-numbered variant.
  BulletAutoNum(CT_TextAutonumberBullet)
  /// <buChar> character variant.
  BulletChar(CT_TextCharBullet)
  /// <buBlip> picture variant.
  BulletBlip(CT_TextBlipBullet)
} derive(Eq, Debug)

///|
/// XSD complex type CT_TextParagraphProperties — Part 1 §20.1.10.59
/// pPr / defPPr / lvlNpPr (Text Paragraph Properties). Annex A.4.1
/// lines 2994..3018. Sequence: `lnSpc` / `spcBef` / `spcAft`
/// (CT_TextSpacing, all optional), EG_TextBulletColor /
/// EG_TextBulletSize / EG_TextBulletTypeface / EG_TextBullet (all
/// optional), `tabLst` (CT_TextTabStopList, optional), `defRPr`
/// (CT_TextCharacterProperties, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). Eleven optional attributes.
pub(all) struct CT_TextParagraphProperties {
  /// <lnSpc> (CT_TextSpacing) — optional.
  ln_spc : CT_TextSpacing?
  /// <spcBef> (CT_TextSpacing) — optional.
  spc_bef : CT_TextSpacing?
  /// <spcAft> (CT_TextSpacing) — optional.
  spc_aft : CT_TextSpacing?
  /// EG_TextBulletColor choice — optional.
  bullet_color : CT_TextParagraphProperties_BulletColor?
  /// EG_TextBulletSize choice — optional.
  bullet_size : CT_TextParagraphProperties_BulletSize?
  /// EG_TextBulletTypeface choice — optional.
  bullet_typeface : CT_TextParagraphProperties_BulletTypeface?
  /// EG_TextBullet choice — optional.
  bullet : CT_TextParagraphProperties_Bullet?
  /// <tabLst> (CT_TextTabStopList) — optional.
  tab_lst : CT_TextTabStopList?
  /// <defRPr> (CT_TextCharacterProperties) — optional default run props.
  def_r_pr : CT_TextCharacterProperties?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @marL — ST_TextMargin (optional).
  mar_l : ST_TextMargin?
  /// @marR — ST_TextMargin (optional).
  mar_r : ST_TextMargin?
  /// @lvl — ST_TextIndentLevelType (optional).
  lvl : ST_TextIndentLevelType?
  /// @indent — ST_TextIndent (optional).
  indent : ST_TextIndent?
  /// @algn — ST_TextAlignType (optional).
  algn : ST_TextAlignType?
  /// @defTabSz — ST_Coordinate32 (optional).
  def_tab_sz : ST_Coordinate32?
  /// @rtl — xsd:boolean (optional).
  rtl : Bool?
  /// @eaLnBrk — xsd:boolean (optional).
  ea_ln_brk : Bool?
  /// @fontAlgn — ST_TextFontAlignType (optional).
  font_algn : ST_TextFontAlignType?
  /// @latinLnBrk — xsd:boolean (optional).
  latin_ln_brk : Bool?
  /// @hangingPunct — xsd:boolean (optional).
  hanging_punct : Bool?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextParagraphProperties::new(
  element : @xml.Element,
) -> CT_TextParagraphProperties raise SchemaViolation {
  let ln_spc = match ct_first_child(element, "lnSpc") {
    Some(c) => Some(CT_TextSpacing::new(c))
    None => None
  }
  let spc_bef = match ct_first_child(element, "spcBef") {
    Some(c) => Some(CT_TextSpacing::new(c))
    None => None
  }
  let spc_aft = match ct_first_child(element, "spcAft") {
    Some(c) => Some(CT_TextSpacing::new(c))
    None => None
  }
  let bullet_color : CT_TextParagraphProperties_BulletColor? = match
    ct_first_child(element, "buClrTx") {
    Some(c) => Some(BulletColorFollow(c))
    None =>
      match ct_first_child(element, "buClr") {
        Some(c) => Some(BulletColorExplicit(CT_Color::new(c)))
        None => None
      }
  }
  let bullet_size : CT_TextParagraphProperties_BulletSize? = match
    ct_first_child(element, "buSzTx") {
    Some(c) => Some(BulletSizeFollow(CT_TextBulletSizeFollowText::new(c)))
    None =>
      match ct_first_child(element, "buSzPct") {
        Some(c) => Some(BulletSizePercent(CT_TextBulletSizePercent::new(c)))
        None =>
          match ct_first_child(element, "buSzPts") {
            Some(c) => Some(BulletSizePoint(CT_TextBulletSizePoint::new(c)))
            None => None
          }
      }
  }
  let bullet_typeface : CT_TextParagraphProperties_BulletTypeface? = match
    ct_first_child(element, "buFontTx") {
    Some(c) =>
      Some(BulletTypefaceFollow(CT_TextBulletTypefaceFollowText::new(c)))
    None =>
      match ct_first_child(element, "buFont") {
        Some(c) => Some(BulletTypefaceExplicit(CT_TextFont::new(c)))
        None => None
      }
  }
  let bullet : CT_TextParagraphProperties_Bullet? = match
    ct_first_child(element, "buNone") {
    Some(c) => Some(BulletNone(CT_TextNoBullet::new(c)))
    None =>
      match ct_first_child(element, "buAutoNum") {
        Some(c) => Some(BulletAutoNum(CT_TextAutonumberBullet::new(c)))
        None =>
          match ct_first_child(element, "buChar") {
            Some(c) => Some(BulletChar(CT_TextCharBullet::new(c)))
            None =>
              match ct_first_child(element, "buBlip") {
                Some(c) => Some(BulletBlip(CT_TextBlipBullet::new(c)))
                None => None
              }
          }
      }
  }
  let tab_lst = match ct_first_child(element, "tabLst") {
    Some(c) => Some(CT_TextTabStopList::new(c))
    None => None
  }
  let def_r_pr = match ct_first_child(element, "defRPr") {
    Some(c) => Some(CT_TextCharacterProperties::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let mar_l = match ct_attr(element, "marL") {
    Some(v) => Some(ST_TextMargin::parse(v))
    None => None
  }
  let mar_r = match ct_attr(element, "marR") {
    Some(v) => Some(ST_TextMargin::parse(v))
    None => None
  }
  let lvl = match ct_attr(element, "lvl") {
    Some(v) => Some(ST_TextIndentLevelType::parse(v))
    None => None
  }
  let indent = match ct_attr(element, "indent") {
    Some(v) => Some(ST_TextIndent::parse(v))
    None => None
  }
  let algn = match ct_attr(element, "algn") {
    Some(v) => Some(ST_TextAlignType::parse(v))
    None => None
  }
  let def_tab_sz = match ct_attr(element, "defTabSz") {
    Some(v) => Some(ST_Coordinate32::parse(v))
    None => None
  }
  let rtl = match ct_attr(element, "rtl") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_TextParagraphProperties/@rtl"))
    None => None
  }
  let ea_ln_brk = match ct_attr(element, "eaLnBrk") {
    Some(v) => Some(ct_parse_bool_lex(v, "CT_TextParagraphProperties/@eaLnBrk"))
    None => None
  }
  let font_algn = match ct_attr(element, "fontAlgn") {
    Some(v) => Some(ST_TextFontAlignType::parse(v))
    None => None
  }
  let latin_ln_brk = match ct_attr(element, "latinLnBrk") {
    Some(v) =>
      Some(ct_parse_bool_lex(v, "CT_TextParagraphProperties/@latinLnBrk"))
    None => None
  }
  let hanging_punct = match ct_attr(element, "hangingPunct") {
    Some(v) =>
      Some(ct_parse_bool_lex(v, "CT_TextParagraphProperties/@hangingPunct"))
    None => None
  }
  {
    ln_spc,
    spc_bef,
    spc_aft,
    bullet_color,
    bullet_size,
    bullet_typeface,
    bullet,
    tab_lst,
    def_r_pr,
    ext_lst,
    mar_l,
    mar_r,
    lvl,
    indent,
    algn,
    def_tab_sz,
    rtl,
    ea_ln_brk,
    font_algn,
    latin_ln_brk,
    hanging_punct,
    element,
  }
}

///|
pub fn CT_TextParagraphProperties::to_element(
  self : CT_TextParagraphProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextField — Part 1 §20.1.10.26 fld (Text Field).
/// Annex A.4.1 lines 3019..3027. Sequence: `rPr`
/// (CT_TextCharacterProperties, optional), `pPr`
/// (CT_TextParagraphProperties, optional), `t` (xsd:string, optional).
/// Required attribute `id` (s:ST_Guid lexical) and optional `type`
/// (xsd:string).
pub(all) struct CT_TextField {
  /// <rPr> (CT_TextCharacterProperties) — optional.
  r_pr : CT_TextCharacterProperties?
  /// <pPr> (CT_TextParagraphProperties) — optional.
  p_pr : CT_TextParagraphProperties?
  /// <t> (xsd:string) — optional field text content (lexical).
  t : String?
  /// @id — s:ST_Guid (required, lexical GUID string).
  id : String
  /// @type — xsd:string (optional).
  type_ : String?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextField::new(
  element : @xml.Element,
) -> CT_TextField raise SchemaViolation {
  let r_pr = match ct_first_child(element, "rPr") {
    Some(c) => Some(CT_TextCharacterProperties::new(c))
    None => None
  }
  let p_pr = match ct_first_child(element, "pPr") {
    Some(c) => Some(CT_TextParagraphProperties::new(c))
    None => None
  }
  let t = match ct_first_child(element, "t") {
    Some(c) => Some(ct_text_content(c))
    None => None
  }
  let id = ct_required_string(element, "id", "CT_TextField/@id")
  let type_ = ct_attr(element, "type")
  { r_pr, p_pr, t, id, type_, element }
}

///|
pub fn CT_TextField::to_element(self : CT_TextField) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RegularTextRun — Part 1 §20.1.10.66 r (Text Run).
/// Annex A.4.1 lines 3035..3040. Sequence: `rPr`
/// (CT_TextCharacterProperties, optional), `t` (xsd:string, required).
/// No attributes.
pub(all) struct CT_RegularTextRun {
  /// <rPr> (CT_TextCharacterProperties) — optional run properties.
  r_pr : CT_TextCharacterProperties?
  /// <t> (xsd:string) — required text content lexical.
  t : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RegularTextRun::new(
  element : @xml.Element,
) -> CT_RegularTextRun raise SchemaViolation {
  let r_pr = match ct_first_child(element, "rPr") {
    Some(c) => Some(CT_TextCharacterProperties::new(c))
    None => None
  }
  let t = match ct_first_child(element, "t") {
    Some(c) => ct_text_content(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_RegularTextRun/t",
        reason="missing required child element",
      )
  }
  { r_pr, t, element }
}

///|
pub fn CT_RegularTextRun::to_element(self : CT_RegularTextRun) -> @xml.Element {
  self.element
}

///|
/// Concatenate the lexical text-node children of `element` into a
/// single string. CData segments are included verbatim. Non-character
/// children are skipped (the typed `t` element only carries character
/// data per the schema).
fn ct_text_content(element : @xml.Element) -> String {
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
pub fn read_text_body(bytes : Bytes) -> CT_TextBody raise {
  CT_TextBody::new(read_main_root(bytes, "txBody"))
}

///|
pub fn write_text_body(value : CT_TextBody) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_text_body_properties(bytes : Bytes) -> CT_TextBodyProperties raise {
  CT_TextBodyProperties::new(read_main_root(bytes, "bodyPr"))
}

///|
pub fn write_text_body_properties(value : CT_TextBodyProperties) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_text_paragraph(bytes : Bytes) -> CT_TextParagraph raise {
  CT_TextParagraph::new(read_main_root(bytes, "p"))
}

///|
pub fn write_text_paragraph(value : CT_TextParagraph) -> Bytes {
  write_element(value.element)
}
