// ECMA-376 Part 1 §20.1.2.2 DrawingML animation build-properties and
// supplemental DrawingML cross-package types. These complex types are
// shared between PresentationML (§19.3.1 bldChart/bldDgm/graphicEl/bldSub
// references), DiagramML whole-formatting (§21.4.3.9), DrawingML clipboard
// theme (Annex A.4.1 §2358), and WordprocessingDrawingML content-part
// non-visual properties (§20.4.2.24 cNvContentPartPr). The XSD definitions
// live in Annex A.4.1 lines 835..938 / 2358 and the prose §-anchors below
// pin each element wrapper.
//
// Per the ct-typing protocol each CT_X is projected as a typed struct
// with explicit attribute / child-element fields decoded from the
// source `@xml.Element`. The element is also preserved so the builder
// can round-trip unmodelled content (the `to_element` writer just
// returns the captured element).

///|
/// XSD complex type CT_AnimationDgmElement — Part 1 §20.1.2.2.12 dgm
/// (Diagram to Animate). Annex A.4.1 lines 870..874. No child
/// elements; two optional attributes with schema-declared defaults.
pub(all) struct CT_AnimationDgmElement {
  /// @id (s:ST_Guid, optional, default "{00000000-0000-0000-0000-000000000000}").
  id : String
  /// @bldStep (ST_DgmBuildStep, optional, default "sp").
  bld_step : ST_DgmBuildStep
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationDgmElement::new(
  element : @xml.Element,
) -> CT_AnimationDgmElement raise SchemaViolation {
  let id = ct_optional_string(
    element,
    "id",
    default="{00000000-0000-0000-0000-000000000000}",
  )
  let bld_step = match ct_attr(element, "bldStep") {
    Some(v) => ST_DgmBuildStep::parse(v)
    None => DgmBuildSp
  }
  { id, bld_step, element }
}

///|
/// Round-trip the preserved source element so the builder can replay
/// unmodelled content verbatim.
pub fn CT_AnimationDgmElement::to_element(
  self : CT_AnimationDgmElement,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AnimationChartElement — Part 1 §20.1.2.2.3 chart
/// (Chart to Animate). Annex A.4.1 lines 875..879. No child elements;
/// two optional integer attributes with default `-1` plus the required
/// ST_ChartBuildStep `bldStep`.
pub(all) struct CT_AnimationChartElement {
  /// @seriesIdx (xsd:int, optional, default -1).
  series_idx : Int
  /// @categoryIdx (xsd:int, optional, default -1).
  category_idx : Int
  /// @bldStep (ST_ChartBuildStep, required).
  bld_step : ST_ChartBuildStep
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationChartElement::new(
  element : @xml.Element,
) -> CT_AnimationChartElement raise SchemaViolation {
  let series_idx = ct_optional_int(
    element,
    "seriesIdx",
    default=-1,
    "CT_AnimationChartElement/@seriesIdx",
  )
  let category_idx = ct_optional_int(
    element,
    "categoryIdx",
    default=-1,
    "CT_AnimationChartElement/@categoryIdx",
  )
  let bld_step_lex = ct_required_string(
    element, "bldStep", "CT_AnimationChartElement/@bldStep",
  )
  let bld_step = ST_ChartBuildStep::parse(bld_step_lex)
  { series_idx, category_idx, bld_step, element }
}

///|
pub fn CT_AnimationChartElement::to_element(
  self : CT_AnimationChartElement,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AnimationElementChoice — Part 1 §20.1.2.2
/// graphicEl. Annex A.4.1 lines 880..884. Choice between `dgm`
/// (CT_AnimationDgmElement) and `chart` (CT_AnimationChartElement);
/// minOccurs=1, maxOccurs=1. Referenced by PresentationML
/// graphicEl (§19.5.41).
pub(all) struct CT_AnimationElementChoice {
  /// <dgm> child (CT_AnimationDgmElement) when the choice arm is taken.
  dgm : CT_AnimationDgmElement?
  /// <chart> child (CT_AnimationChartElement) when the choice arm is taken.
  chart : CT_AnimationChartElement?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationElementChoice::new(
  element : @xml.Element,
) -> CT_AnimationElementChoice raise SchemaViolation {
  let dgm = match ct_first_child(element, "dgm") {
    Some(c) => Some(CT_AnimationDgmElement::new(c))
    None => None
  }
  let chart = match ct_first_child(element, "chart") {
    Some(c) => Some(CT_AnimationChartElement::new(c))
    None => None
  }
  { dgm, chart, element }
}

///|
pub fn CT_AnimationElementChoice::to_element(
  self : CT_AnimationElementChoice,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AnimationDgmBuildProperties — Part 1
/// §20.1.2.2.2 bldDgm. Annex A.4.1 lines 901..904. No child elements;
/// optional `bld` (ST_AnimationDgmBuildType, default allAtOnce) and
/// `rev` (xsd:boolean, default false).
pub(all) struct CT_AnimationDgmBuildProperties {
  /// @bld (ST_AnimationDgmBuildType, optional, default allAtOnce).
  bld : ST_AnimationDgmBuildType
  /// @rev (xsd:boolean, optional, default false).
  rev : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationDgmBuildProperties::new(
  element : @xml.Element,
) -> CT_AnimationDgmBuildProperties raise SchemaViolation {
  let bld = match ct_attr(element, "bld") {
    Some(v) => ST_AnimationDgmBuildType::parse(v)
    None => DgmBuildAllAtOnce
  }
  let rev = ct_optional_bool(
    element,
    "rev",
    default=false,
    "CT_AnimationDgmBuildProperties/@rev",
  )
  { bld, rev, element }
}

///|
pub fn CT_AnimationDgmBuildProperties::to_element(
  self : CT_AnimationDgmBuildProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AnimationChartBuildProperties — Part 1
/// §20.1.2.2.1 bldChart. Annex A.4.1 lines 916..919. No child
/// elements; optional `bld` (ST_AnimationChartBuildType, default
/// allAtOnce) and `animBg` (xsd:boolean, default true).
pub(all) struct CT_AnimationChartBuildProperties {
  /// @bld (ST_AnimationChartBuildType, optional, default allAtOnce).
  bld : ST_AnimationChartBuildType
  /// @animBg (xsd:boolean, optional, default true).
  anim_bg : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationChartBuildProperties::new(
  element : @xml.Element,
) -> CT_AnimationChartBuildProperties raise SchemaViolation {
  let bld = match ct_attr(element, "bld") {
    Some(v) => ST_AnimationChartBuildType::parse(v)
    None => ChartBuildAllAtOnce
  }
  let anim_bg = ct_optional_bool(
    element,
    "animBg",
    default=true,
    "CT_AnimationChartBuildProperties/@animBg",
  )
  { bld, anim_bg, element }
}

///|
pub fn CT_AnimationChartBuildProperties::to_element(
  self : CT_AnimationChartBuildProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AnimationGraphicalObjectBuildProperties —
/// Part 1 §20.1.2.2 bldSub. Annex A.4.1 lines 920..925. Choice
/// between `bldDgm` (CT_AnimationDgmBuildProperties) and `bldChart`
/// (CT_AnimationChartBuildProperties). Referenced by PresentationML
/// bldSub (§19.5.14).
pub(all) struct CT_AnimationGraphicalObjectBuildProperties {
  /// <bldDgm> child when the choice arm is taken.
  bld_dgm : CT_AnimationDgmBuildProperties?
  /// <bldChart> child when the choice arm is taken.
  bld_chart : CT_AnimationChartBuildProperties?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimationGraphicalObjectBuildProperties::new(
  element : @xml.Element,
) -> CT_AnimationGraphicalObjectBuildProperties raise SchemaViolation {
  let bld_dgm = match ct_first_child(element, "bldDgm") {
    Some(c) => Some(CT_AnimationDgmBuildProperties::new(c))
    None => None
  }
  let bld_chart = match ct_first_child(element, "bldChart") {
    Some(c) => Some(CT_AnimationChartBuildProperties::new(c))
    None => None
  }
  { bld_dgm, bld_chart, element }
}

///|
pub fn CT_AnimationGraphicalObjectBuildProperties::to_element(
  self : CT_AnimationGraphicalObjectBuildProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WholeE2oFormatting — Part 1 §21.4.3.9 whole
/// (Whole E2O Formatting). Annex A.4.1 lines 932..937. Sequence:
/// optional `ln` (CT_LineProperties) and the EG_EffectProperties
/// group (`effectLst` | `effectDag`). Both children are stored as
/// raw `@xml.Element` because the relevant CT_LineProperties /
/// effect projections live outside chunk1.
pub(all) struct CT_WholeE2oFormatting {
  /// <ln> child (CT_LineProperties, optional minOccurs=0). Retained
  /// as raw element until the line-properties typed projection lands.
  ln : @xml.Element?
  /// EG_EffectProperties group (`effectLst` or `effectDag`) when
  /// present. Captured as raw element pending the typed effect-list
  /// projection.
  effect_props : @xml.Element?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WholeE2oFormatting::new(
  element : @xml.Element,
) -> CT_WholeE2oFormatting raise SchemaViolation {
  let ln = ct_first_child(element, "ln")
  let effect_props = match ct_first_child(element, "effectLst") {
    Some(c) => Some(c)
    None => ct_first_child(element, "effectDag")
  }
  { ln, effect_props, element }
}

///|
pub fn CT_WholeE2oFormatting::to_element(
  self : CT_WholeE2oFormatting,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NonVisualContentPartProperties — Part 1
/// §20.4.2.24 cNvContentPartPr. Annex A.4.1 lines 835..841. Sequence:
/// optional `cpLocks` (CT_ContentPartLocking) and `extLst`
/// (CT_OfficeArtExtensionList); optional attribute `isComment`
/// (xsd:boolean, default true).
pub(all) struct CT_NonVisualContentPartProperties {
  /// <cpLocks> child (CT_ContentPartLocking, optional). Stored as
  /// raw element — the typed CT_ContentPartLocking projection is
  /// owned by a later chunk.
  cp_locks : @xml.Element?
  /// <extLst> child (CT_OfficeArtExtensionList, optional). Stored
  /// as raw element pending the typed extension-list projection.
  ext_lst : @xml.Element?
  /// @isComment (xsd:boolean, optional, default true).
  is_comment : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualContentPartProperties::new(
  element : @xml.Element,
) -> CT_NonVisualContentPartProperties raise SchemaViolation {
  let cp_locks = ct_first_child(element, "cpLocks")
  let ext_lst = ct_first_child(element, "extLst")
  let is_comment = ct_optional_bool(
    element,
    "isComment",
    default=true,
    "CT_NonVisualContentPartProperties/@isComment",
  )
  { cp_locks, ext_lst, is_comment, element }
}

///|
pub fn CT_NonVisualContentPartProperties::to_element(
  self : CT_NonVisualContentPartProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ClipboardStyleSheet — Part 1 Annex A.4.1 lines
/// 2338..2343 (DrawingML Main clipboard theme transport). Sequence:
/// required `themeElements` (CT_BaseStyles) and `clrMap`
/// (CT_ColorMapping). Used when copying themed content across
/// documents via the clipboard so theme element resolution and color
/// mapping travel with the payload.
pub(all) struct CT_ClipboardStyleSheet {
  /// <themeElements> child (CT_BaseStyles, required). Stored as raw
  /// element until the typed CT_BaseStyles projection lands; the
  /// element name is enforced by the schema so callers can re-decode.
  theme_elements : @xml.Element?
  /// <clrMap> child (CT_ColorMapping, required). Stored as the typed
  /// CT_ColorMapping when present.
  clr_map : CT_ColorMapping?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ClipboardStyleSheet::new(
  element : @xml.Element,
) -> CT_ClipboardStyleSheet raise SchemaViolation {
  let theme_elements = ct_first_child(element, "themeElements")
  let clr_map = match ct_first_child(element, "clrMap") {
    Some(c) => Some(CT_ColorMapping::new(c))
    None => None
  }
  { theme_elements, clr_map, element }
}

///|
pub fn CT_ClipboardStyleSheet::to_element(
  self : CT_ClipboardStyleSheet,
) -> @xml.Element {
  self.element
}
