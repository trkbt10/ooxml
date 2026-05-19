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
pub fn CT_TextParagraph::new(element : @xml.Element) -> CT_TextParagraph {
  let p_pr = ct_first_child(element, "pPr").map(CT_TextParagraphProperties::new)
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
  let end_para_r_pr = ct_first_child(element, "endParaRPr").map(
    CT_TextCharacterProperties::new,
  )
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
  let def_p_pr = ct_first_child(element, "defPPr").map(
    CT_TextParagraphProperties::new,
  )
  let lvl1p_pr = ct_first_child(element, "lvl1pPr").map(
    CT_TextParagraphProperties::new,
  )
  let lvl2p_pr = ct_first_child(element, "lvl2pPr").map(
    CT_TextParagraphProperties::new,
  )
  let lvl3p_pr = ct_first_child(element, "lvl3pPr").map(
    CT_TextParagraphProperties::new,
  )
  let lvl4p_pr = ct_first_child(element, "lvl4pPr").map(
    CT_TextParagraphProperties::new,
  )
  let lvl5p_pr = ct_first_child(element, "lvl5pPr").map(
    CT_TextParagraphProperties::new,
  )
  let lvl6p_pr = ct_first_child(element, "lvl6pPr").map(
    CT_TextParagraphProperties::new,
  )
  let lvl7p_pr = ct_first_child(element, "lvl7pPr").map(
    CT_TextParagraphProperties::new,
  )
  let lvl8p_pr = ct_first_child(element, "lvl8pPr").map(
    CT_TextParagraphProperties::new,
  )
  let lvl9p_pr = ct_first_child(element, "lvl9pPr").map(
    CT_TextParagraphProperties::new,
  )
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
/// XSD complex type CT_TextShapeAutofit (§20.1.10).
pub(all) struct CT_TextShapeAutofit {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextShapeAutofit::new(element : @xml.Element) -> CT_TextShapeAutofit {
  { element, }
}

///|
/// XSD complex type CT_TextNoAutofit (§20.1.10).
pub(all) struct CT_TextNoAutofit {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextNoAutofit::new(element : @xml.Element) -> CT_TextNoAutofit {
  { element, }
}

///|
/// XSD complex type CT_TextBodyProperties (§20.1.10): body layout, wrapping, columns, anchoring, and autofit settings.
pub(all) struct CT_TextBodyProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBodyProperties::new(
  element : @xml.Element,
) -> CT_TextBodyProperties {
  { element, }
}

///|
/// XSD complex type CT_TextBody (§20.1.10): bodyPr, lstStyle, and paragraph content.
pub(all) struct CT_TextBody {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBody::new(element : @xml.Element) -> CT_TextBody {
  { element, }
}

///|
/// XSD complex type CT_TextBulletSizeFollowText (§20.1.10).
pub(all) struct CT_TextBulletSizeFollowText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBulletSizeFollowText::new(
  element : @xml.Element,
) -> CT_TextBulletSizeFollowText {
  { element, }
}

///|
/// XSD complex type CT_TextBulletSizePercent (§20.1.10): attribute val.
pub(all) struct CT_TextBulletSizePercent {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBulletSizePercent::new(
  element : @xml.Element,
) -> CT_TextBulletSizePercent {
  { element, }
}

///|
/// XSD complex type CT_TextBulletSizePoint (§20.1.10): attribute val.
pub(all) struct CT_TextBulletSizePoint {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBulletSizePoint::new(
  element : @xml.Element,
) -> CT_TextBulletSizePoint {
  { element, }
}

///|
/// XSD complex type CT_TextBulletTypefaceFollowText (§20.1.10).
pub(all) struct CT_TextBulletTypefaceFollowText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBulletTypefaceFollowText::new(
  element : @xml.Element,
) -> CT_TextBulletTypefaceFollowText {
  { element, }
}

///|
/// XSD complex type CT_TextAutonumberBullet (§20.1.10): attributes type, startAt.
pub(all) struct CT_TextAutonumberBullet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextAutonumberBullet::new(
  element : @xml.Element,
) -> CT_TextAutonumberBullet {
  { element, }
}

///|
/// XSD complex type CT_TextCharBullet (§20.1.10): attribute char.
pub(all) struct CT_TextCharBullet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextCharBullet::new(element : @xml.Element) -> CT_TextCharBullet {
  { element, }
}

///|
/// XSD complex type CT_TextBlipBullet (§20.1.10): child blip.
pub(all) struct CT_TextBlipBullet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextBlipBullet::new(element : @xml.Element) -> CT_TextBlipBullet {
  { element, }
}

///|
/// XSD complex type CT_TextNoBullet (§20.1.10).
pub(all) struct CT_TextNoBullet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextNoBullet::new(element : @xml.Element) -> CT_TextNoBullet {
  { element, }
}

///|
/// XSD complex type CT_TextUnderlineLineFollowText (§20.1.10).
pub(all) struct CT_TextUnderlineLineFollowText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextUnderlineLineFollowText::new(
  element : @xml.Element,
) -> CT_TextUnderlineLineFollowText {
  { element, }
}

///|
/// XSD complex type CT_TextUnderlineFillFollowText (§20.1.10).
pub(all) struct CT_TextUnderlineFillFollowText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextUnderlineFillFollowText::new(
  element : @xml.Element,
) -> CT_TextUnderlineFillFollowText {
  { element, }
}

///|
/// XSD complex type CT_TextUnderlineFillGroupWrapper (§20.1.10).
pub(all) struct CT_TextUnderlineFillGroupWrapper {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextUnderlineFillGroupWrapper::new(
  element : @xml.Element,
) -> CT_TextUnderlineFillGroupWrapper {
  { element, }
}

///|
/// XSD complex type CT_TextCharacterProperties (§20.1.10): run styling, fill, underline, font, hyperlink, and extension children.
pub(all) struct CT_TextCharacterProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextCharacterProperties::new(
  element : @xml.Element,
) -> CT_TextCharacterProperties {
  { element, }
}

///|
/// XSD complex type CT_TextSpacingPercent (§20.1.10): attribute val.
pub(all) struct CT_TextSpacingPercent {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextSpacingPercent::new(
  element : @xml.Element,
) -> CT_TextSpacingPercent {
  { element, }
}

///|
/// XSD complex type CT_TextSpacingPoint (§20.1.10): attribute val.
pub(all) struct CT_TextSpacingPoint {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextSpacingPoint::new(element : @xml.Element) -> CT_TextSpacingPoint {
  { element, }
}

///|
/// XSD complex type CT_TextTabStop (§20.1.10): attributes pos, algn.
pub(all) struct CT_TextTabStop {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextTabStop::new(element : @xml.Element) -> CT_TextTabStop {
  { element, }
}

///|
/// XSD complex type CT_TextTabStopList (§20.1.10): child tab.
pub(all) struct CT_TextTabStopList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextTabStopList::new(element : @xml.Element) -> CT_TextTabStopList {
  { element, }
}

///|
/// XSD complex type CT_TextLineBreak (§20.1.10): child rPr.
pub(all) struct CT_TextLineBreak {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextLineBreak::new(element : @xml.Element) -> CT_TextLineBreak {
  { element, }
}

///|
/// XSD complex type CT_TextSpacing (§20.1.10): choice of spcPct or spcPts.
pub(all) struct CT_TextSpacing {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextSpacing::new(element : @xml.Element) -> CT_TextSpacing {
  { element, }
}

///|
/// XSD complex type CT_TextParagraphProperties (§20.1.10): paragraph margins, alignment, tabs, bullets, and default run properties.
pub(all) struct CT_TextParagraphProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextParagraphProperties::new(
  element : @xml.Element,
) -> CT_TextParagraphProperties {
  { element, }
}

///|
/// XSD complex type CT_TextField (§20.1.10): attributes id, type; children rPr, pPr, t.
pub(all) struct CT_TextField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextField::new(element : @xml.Element) -> CT_TextField {
  { element, }
}

///|
/// XSD complex type CT_RegularTextRun (§20.1.10): children rPr and t.
pub(all) struct CT_RegularTextRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RegularTextRun::new(element : @xml.Element) -> CT_RegularTextRun {
  { element, }
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
