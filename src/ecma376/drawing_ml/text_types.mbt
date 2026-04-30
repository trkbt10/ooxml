///|
/// XSD complex type CT_TextParagraph (§20.1.10): children pPr, r, br, fld, endParaRPr.
pub(all) struct CT_TextParagraph {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextParagraph::new(element : @xml.Element) -> CT_TextParagraph {
  { element, }
}

///|
/// XSD complex type CT_TextListStyle (§20.1.10): paragraph defaults for levels 1 through 9.
pub(all) struct CT_TextListStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextListStyle::new(element : @xml.Element) -> CT_TextListStyle {
  { element, }
}

///|
/// XSD complex type CT_TextNormalAutofit (§20.1.10): attributes fontScale, lnSpcReduction.
pub(all) struct CT_TextNormalAutofit {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextNormalAutofit::new(
  element : @xml.Element,
) -> CT_TextNormalAutofit {
  { element, }
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
