// ECMA-376 Part 1 §20.1.2.2 DrawingML animation build-properties and
// supplemental DrawingML cross-package types. These complex types are
// shared between PresentationML (§19.3.1 bldChart/bldDgm/graphicEl/bldSub
// references), DiagramML whole-formatting (§21.4.3.9), DrawingML clipboard
// theme (Annex A.4.1 §2358), and WordprocessingDrawingML content-part
// non-visual properties (§20.4.2.24 cNvContentPartPr). The XSD definitions
// live in Annex A.4.1 lines 835..938 / 2358 and the prose §-anchors below
// pin each element wrapper.
//
// Like the other DrawingML CT_* wrappers, these preserve the source
// @xml.Element so callers can inspect or pass through namespace data
// without lossy re-serialization.

///|
/// XSD complex type CT_AnimationDgmElement — Part 1 §20.1.2.2.12 dgm
/// (Diagram to Animate). Attributes: id? (s:ST_Guid, default
/// {00000000-...}), bldStep? (ST_DgmBuildStep, default sp). Annex A.4.1
/// line 870.
pub(all) struct CT_AnimationDgmElement {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationDgmElement::new(
  element : @xml.Element,
) -> CT_AnimationDgmElement {
  { element, }
}

///|
/// XSD complex type CT_AnimationChartElement — Part 1 §20.1.2.2.3 chart
/// (Chart to Animate). Attributes: seriesIdx? (xsd:int, default -1),
/// categoryIdx? (xsd:int, default -1), bldStep (ST_ChartBuildStep,
/// required). Annex A.4.1 line 875.
pub(all) struct CT_AnimationChartElement {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationChartElement::new(
  element : @xml.Element,
) -> CT_AnimationChartElement {
  { element, }
}

///|
/// XSD complex type CT_AnimationElementChoice — Part 1 §20.1.2.2 graphic
/// element animation choice. Single choice between dgm
/// (CT_AnimationDgmElement) and chart (CT_AnimationChartElement); referenced
/// by PresentationML graphicEl (§19.5.41). Annex A.4.1 line 880.
pub(all) struct CT_AnimationElementChoice {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationElementChoice::new(
  element : @xml.Element,
) -> CT_AnimationElementChoice {
  { element, }
}

///|
/// XSD complex type CT_AnimationDgmBuildProperties — Part 1 §20.1.2.2.2
/// bldDgm (Build Diagram). Attributes: bld? (ST_AnimationDgmBuildType,
/// default allAtOnce), rev? (xsd:boolean, default false). Annex A.4.1 line
/// 901.
pub(all) struct CT_AnimationDgmBuildProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationDgmBuildProperties::new(
  element : @xml.Element,
) -> CT_AnimationDgmBuildProperties {
  { element, }
}

///|
/// XSD complex type CT_AnimationChartBuildProperties — Part 1 §20.1.2.2.1
/// bldChart (Build Chart). Attributes: bld? (ST_AnimationChartBuildType,
/// default allAtOnce), animBg? (xsd:boolean, default true). Annex A.4.1
/// line 916.
pub(all) struct CT_AnimationChartBuildProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationChartBuildProperties::new(
  element : @xml.Element,
) -> CT_AnimationChartBuildProperties {
  { element, }
}

///|
/// XSD complex type CT_AnimationGraphicalObjectBuildProperties — Part 1
/// §20.1.2.2 build-sub choice. Choice: bldDgm
/// (CT_AnimationDgmBuildProperties) | bldChart
/// (CT_AnimationChartBuildProperties); referenced by PresentationML bldSub
/// (§19.5.14). Annex A.4.1 line 921.
pub(all) struct CT_AnimationGraphicalObjectBuildProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationGraphicalObjectBuildProperties::new(
  element : @xml.Element,
) -> CT_AnimationGraphicalObjectBuildProperties {
  { element, }
}

///|
/// XSD complex type CT_WholeE2oFormatting — Part 1 §21.4.3.9 whole (Whole
/// E2O Formatting). Sequence: ln? (CT_LineProperties), EG_EffectProperties
/// group (effectLst | effectDag). Used by DiagramML drawing whole and
/// data-model formatting. Annex A.4.1 line 933.
pub(all) struct CT_WholeE2oFormatting {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WholeE2oFormatting::new(
  element : @xml.Element,
) -> CT_WholeE2oFormatting {
  { element, }
}

///|
/// XSD complex type CT_NonVisualContentPartProperties — Part 1 §20.4.2.24
/// cNvContentPartPr (Non-Visual Content Part Drawing Properties).
/// Sequence: cpLocks? (CT_ContentPartLocking), extLst?
/// (CT_OfficeArtExtensionList). Attribute: isComment? (xsd:boolean,
/// default true). Annex A.4.1 line 835.
pub(all) struct CT_NonVisualContentPartProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualContentPartProperties::new(
  element : @xml.Element,
) -> CT_NonVisualContentPartProperties {
  { element, }
}

///|
/// XSD complex type CT_ClipboardStyleSheet — Part 1 Annex A.4.1 line 2358
/// (DrawingML Main clipboard theme transport). Sequence: themeElements
/// (CT_BaseStyles), clrMap (CT_ColorMapping). Used when copying themed
/// content across documents via the clipboard so that theme element
/// resolution and color mapping travel with the payload.
pub(all) struct CT_ClipboardStyleSheet {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ClipboardStyleSheet::new(
  element : @xml.Element,
) -> CT_ClipboardStyleSheet {
  { element, }
}
