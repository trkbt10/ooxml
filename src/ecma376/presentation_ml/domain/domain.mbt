///|
/// PresentationML domain: presentation, slide, slideLayout, slideMaster, notesMaster, handoutMaster.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/domain"
}

///|
/// XSD complex type CT_SideDirectionTransition from pml.xsd (§19).
pub(all) struct CT_SideDirectionTransition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SideDirectionTransition::new(
  element : @xml.Element,
) -> CT_SideDirectionTransition {
  { element, }
}

///|
pub fn CT_SideDirectionTransition::parse(
  element : @xml.Element,
) -> CT_SideDirectionTransition {
  CT_SideDirectionTransition::new(element)
}

///|
pub fn CT_SideDirectionTransition::to_element(
  self : CT_SideDirectionTransition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CornerDirectionTransition from pml.xsd (§19).
pub(all) struct CT_CornerDirectionTransition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CornerDirectionTransition::new(
  element : @xml.Element,
) -> CT_CornerDirectionTransition {
  { element, }
}

///|
pub fn CT_CornerDirectionTransition::parse(
  element : @xml.Element,
) -> CT_CornerDirectionTransition {
  CT_CornerDirectionTransition::new(element)
}

///|
pub fn CT_CornerDirectionTransition::to_element(
  self : CT_CornerDirectionTransition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EightDirectionTransition from pml.xsd (§19).
pub(all) struct CT_EightDirectionTransition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EightDirectionTransition::new(
  element : @xml.Element,
) -> CT_EightDirectionTransition {
  { element, }
}

///|
pub fn CT_EightDirectionTransition::parse(
  element : @xml.Element,
) -> CT_EightDirectionTransition {
  CT_EightDirectionTransition::new(element)
}

///|
pub fn CT_EightDirectionTransition::to_element(
  self : CT_EightDirectionTransition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OrientationTransition from pml.xsd (§19).
pub(all) struct CT_OrientationTransition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OrientationTransition::new(
  element : @xml.Element,
) -> CT_OrientationTransition {
  { element, }
}

///|
pub fn CT_OrientationTransition::parse(
  element : @xml.Element,
) -> CT_OrientationTransition {
  CT_OrientationTransition::new(element)
}

///|
pub fn CT_OrientationTransition::to_element(
  self : CT_OrientationTransition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_InOutTransition from pml.xsd (§19).
pub(all) struct CT_InOutTransition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_InOutTransition::new(element : @xml.Element) -> CT_InOutTransition {
  { element, }
}

///|
pub fn CT_InOutTransition::parse(element : @xml.Element) -> CT_InOutTransition {
  CT_InOutTransition::new(element)
}

///|
pub fn CT_InOutTransition::to_element(
  self : CT_InOutTransition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OptionalBlackTransition from pml.xsd (§19).
pub(all) struct CT_OptionalBlackTransition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OptionalBlackTransition::new(
  element : @xml.Element,
) -> CT_OptionalBlackTransition {
  { element, }
}

///|
pub fn CT_OptionalBlackTransition::parse(
  element : @xml.Element,
) -> CT_OptionalBlackTransition {
  CT_OptionalBlackTransition::new(element)
}

///|
pub fn CT_OptionalBlackTransition::to_element(
  self : CT_OptionalBlackTransition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SplitTransition from pml.xsd (§19).
pub(all) struct CT_SplitTransition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SplitTransition::new(element : @xml.Element) -> CT_SplitTransition {
  { element, }
}

///|
pub fn CT_SplitTransition::parse(element : @xml.Element) -> CT_SplitTransition {
  CT_SplitTransition::new(element)
}

///|
pub fn CT_SplitTransition::to_element(
  self : CT_SplitTransition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WheelTransition from pml.xsd (§19).
pub(all) struct CT_WheelTransition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WheelTransition::new(element : @xml.Element) -> CT_WheelTransition {
  { element, }
}

///|
pub fn CT_WheelTransition::parse(element : @xml.Element) -> CT_WheelTransition {
  CT_WheelTransition::new(element)
}

///|
pub fn CT_WheelTransition::to_element(
  self : CT_WheelTransition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TransitionStartSoundAction from pml.xsd (§19).
pub(all) struct CT_TransitionStartSoundAction {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TransitionStartSoundAction::new(
  element : @xml.Element,
) -> CT_TransitionStartSoundAction {
  { element, }
}

///|
pub fn CT_TransitionStartSoundAction::parse(
  element : @xml.Element,
) -> CT_TransitionStartSoundAction {
  CT_TransitionStartSoundAction::new(element)
}

///|
pub fn CT_TransitionStartSoundAction::to_element(
  self : CT_TransitionStartSoundAction,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TransitionSoundAction from pml.xsd (§19).
pub(all) struct CT_TransitionSoundAction {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TransitionSoundAction::new(
  element : @xml.Element,
) -> CT_TransitionSoundAction {
  { element, }
}

///|
pub fn CT_TransitionSoundAction::parse(
  element : @xml.Element,
) -> CT_TransitionSoundAction {
  CT_TransitionSoundAction::new(element)
}

///|
pub fn CT_TransitionSoundAction::to_element(
  self : CT_TransitionSoundAction,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideTransition from pml.xsd (§19).
pub(all) struct CT_SlideTransition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideTransition::new(element : @xml.Element) -> CT_SlideTransition {
  { element, }
}

///|
pub fn CT_SlideTransition::parse(element : @xml.Element) -> CT_SlideTransition {
  CT_SlideTransition::new(element)
}

///|
pub fn CT_SlideTransition::to_element(
  self : CT_SlideTransition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLIterateIntervalTime from pml.xsd (§19).
pub(all) struct CT_TLIterateIntervalTime {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLIterateIntervalTime::new(
  element : @xml.Element,
) -> CT_TLIterateIntervalTime {
  { element, }
}

///|
pub fn CT_TLIterateIntervalTime::parse(
  element : @xml.Element,
) -> CT_TLIterateIntervalTime {
  CT_TLIterateIntervalTime::new(element)
}

///|
pub fn CT_TLIterateIntervalTime::to_element(
  self : CT_TLIterateIntervalTime,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLIterateIntervalPercentage from pml.xsd (§19).
pub(all) struct CT_TLIterateIntervalPercentage {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLIterateIntervalPercentage::new(
  element : @xml.Element,
) -> CT_TLIterateIntervalPercentage {
  { element, }
}

///|
pub fn CT_TLIterateIntervalPercentage::parse(
  element : @xml.Element,
) -> CT_TLIterateIntervalPercentage {
  CT_TLIterateIntervalPercentage::new(element)
}

///|
pub fn CT_TLIterateIntervalPercentage::to_element(
  self : CT_TLIterateIntervalPercentage,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLIterateData from pml.xsd (§19).
pub(all) struct CT_TLIterateData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLIterateData::new(element : @xml.Element) -> CT_TLIterateData {
  { element, }
}

///|
pub fn CT_TLIterateData::parse(element : @xml.Element) -> CT_TLIterateData {
  CT_TLIterateData::new(element)
}

///|
pub fn CT_TLIterateData::to_element(self : CT_TLIterateData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLSubShapeId from pml.xsd (§19).
pub(all) struct CT_TLSubShapeId {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLSubShapeId::new(element : @xml.Element) -> CT_TLSubShapeId {
  { element, }
}

///|
pub fn CT_TLSubShapeId::parse(element : @xml.Element) -> CT_TLSubShapeId {
  CT_TLSubShapeId::new(element)
}

///|
pub fn CT_TLSubShapeId::to_element(self : CT_TLSubShapeId) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTextTargetElement from pml.xsd (§19).
pub(all) struct CT_TLTextTargetElement {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTextTargetElement::new(
  element : @xml.Element,
) -> CT_TLTextTargetElement {
  { element, }
}

///|
pub fn CT_TLTextTargetElement::parse(
  element : @xml.Element,
) -> CT_TLTextTargetElement {
  CT_TLTextTargetElement::new(element)
}

///|
pub fn CT_TLTextTargetElement::to_element(
  self : CT_TLTextTargetElement,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLOleChartTargetElement from pml.xsd (§19).
pub(all) struct CT_TLOleChartTargetElement {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLOleChartTargetElement::new(
  element : @xml.Element,
) -> CT_TLOleChartTargetElement {
  { element, }
}

///|
pub fn CT_TLOleChartTargetElement::parse(
  element : @xml.Element,
) -> CT_TLOleChartTargetElement {
  CT_TLOleChartTargetElement::new(element)
}

///|
pub fn CT_TLOleChartTargetElement::to_element(
  self : CT_TLOleChartTargetElement,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLShapeTargetElement from pml.xsd (§19).
pub(all) struct CT_TLShapeTargetElement {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLShapeTargetElement::new(
  element : @xml.Element,
) -> CT_TLShapeTargetElement {
  { element, }
}

///|
pub fn CT_TLShapeTargetElement::parse(
  element : @xml.Element,
) -> CT_TLShapeTargetElement {
  CT_TLShapeTargetElement::new(element)
}

///|
pub fn CT_TLShapeTargetElement::to_element(
  self : CT_TLShapeTargetElement,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTimeTargetElement from pml.xsd (§19).
pub(all) struct CT_TLTimeTargetElement {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTimeTargetElement::new(
  element : @xml.Element,
) -> CT_TLTimeTargetElement {
  { element, }
}

///|
pub fn CT_TLTimeTargetElement::parse(
  element : @xml.Element,
) -> CT_TLTimeTargetElement {
  CT_TLTimeTargetElement::new(element)
}

///|
pub fn CT_TLTimeTargetElement::to_element(
  self : CT_TLTimeTargetElement,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTriggerTimeNodeID from pml.xsd (§19).
pub(all) struct CT_TLTriggerTimeNodeID {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTriggerTimeNodeID::new(
  element : @xml.Element,
) -> CT_TLTriggerTimeNodeID {
  { element, }
}

///|
pub fn CT_TLTriggerTimeNodeID::parse(
  element : @xml.Element,
) -> CT_TLTriggerTimeNodeID {
  CT_TLTriggerTimeNodeID::new(element)
}

///|
pub fn CT_TLTriggerTimeNodeID::to_element(
  self : CT_TLTriggerTimeNodeID,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTriggerRuntimeNode from pml.xsd (§19).
pub(all) struct CT_TLTriggerRuntimeNode {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTriggerRuntimeNode::new(
  element : @xml.Element,
) -> CT_TLTriggerRuntimeNode {
  { element, }
}

///|
pub fn CT_TLTriggerRuntimeNode::parse(
  element : @xml.Element,
) -> CT_TLTriggerRuntimeNode {
  CT_TLTriggerRuntimeNode::new(element)
}

///|
pub fn CT_TLTriggerRuntimeNode::to_element(
  self : CT_TLTriggerRuntimeNode,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTimeCondition from pml.xsd (§19).
pub(all) struct CT_TLTimeCondition {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTimeCondition::new(element : @xml.Element) -> CT_TLTimeCondition {
  { element, }
}

///|
pub fn CT_TLTimeCondition::parse(element : @xml.Element) -> CT_TLTimeCondition {
  CT_TLTimeCondition::new(element)
}

///|
pub fn CT_TLTimeCondition::to_element(
  self : CT_TLTimeCondition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTimeConditionList from pml.xsd (§19).
pub(all) struct CT_TLTimeConditionList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTimeConditionList::new(
  element : @xml.Element,
) -> CT_TLTimeConditionList {
  { element, }
}

///|
pub fn CT_TLTimeConditionList::parse(
  element : @xml.Element,
) -> CT_TLTimeConditionList {
  CT_TLTimeConditionList::new(element)
}

///|
pub fn CT_TLTimeConditionList::to_element(
  self : CT_TLTimeConditionList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TimeNodeList from pml.xsd (§19).
pub(all) struct CT_TimeNodeList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TimeNodeList::new(element : @xml.Element) -> CT_TimeNodeList {
  { element, }
}

///|
pub fn CT_TimeNodeList::parse(element : @xml.Element) -> CT_TimeNodeList {
  CT_TimeNodeList::new(element)
}

///|
pub fn CT_TimeNodeList::to_element(self : CT_TimeNodeList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLCommonTimeNodeData from pml.xsd (§19).
pub(all) struct CT_TLCommonTimeNodeData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLCommonTimeNodeData::new(
  element : @xml.Element,
) -> CT_TLCommonTimeNodeData {
  { element, }
}

///|
pub fn CT_TLCommonTimeNodeData::parse(
  element : @xml.Element,
) -> CT_TLCommonTimeNodeData {
  CT_TLCommonTimeNodeData::new(element)
}

///|
pub fn CT_TLCommonTimeNodeData::to_element(
  self : CT_TLCommonTimeNodeData,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTimeNodeParallel from pml.xsd (§19).
pub(all) struct CT_TLTimeNodeParallel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTimeNodeParallel::new(
  element : @xml.Element,
) -> CT_TLTimeNodeParallel {
  { element, }
}

///|
pub fn CT_TLTimeNodeParallel::parse(
  element : @xml.Element,
) -> CT_TLTimeNodeParallel {
  CT_TLTimeNodeParallel::new(element)
}

///|
pub fn CT_TLTimeNodeParallel::to_element(
  self : CT_TLTimeNodeParallel,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTimeNodeSequence from pml.xsd (§19).
pub(all) struct CT_TLTimeNodeSequence {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTimeNodeSequence::new(
  element : @xml.Element,
) -> CT_TLTimeNodeSequence {
  { element, }
}

///|
pub fn CT_TLTimeNodeSequence::parse(
  element : @xml.Element,
) -> CT_TLTimeNodeSequence {
  CT_TLTimeNodeSequence::new(element)
}

///|
pub fn CT_TLTimeNodeSequence::to_element(
  self : CT_TLTimeNodeSequence,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTimeNodeExclusive from pml.xsd (§19).
pub(all) struct CT_TLTimeNodeExclusive {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTimeNodeExclusive::new(
  element : @xml.Element,
) -> CT_TLTimeNodeExclusive {
  { element, }
}

///|
pub fn CT_TLTimeNodeExclusive::parse(
  element : @xml.Element,
) -> CT_TLTimeNodeExclusive {
  CT_TLTimeNodeExclusive::new(element)
}

///|
pub fn CT_TLTimeNodeExclusive::to_element(
  self : CT_TLTimeNodeExclusive,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLBehaviorAttributeNameList from pml.xsd (§19).
pub(all) struct CT_TLBehaviorAttributeNameList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLBehaviorAttributeNameList::new(
  element : @xml.Element,
) -> CT_TLBehaviorAttributeNameList {
  { element, }
}

///|
pub fn CT_TLBehaviorAttributeNameList::parse(
  element : @xml.Element,
) -> CT_TLBehaviorAttributeNameList {
  CT_TLBehaviorAttributeNameList::new(element)
}

///|
pub fn CT_TLBehaviorAttributeNameList::to_element(
  self : CT_TLBehaviorAttributeNameList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLCommonBehaviorData from pml.xsd (§19).
pub(all) struct CT_TLCommonBehaviorData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLCommonBehaviorData::new(
  element : @xml.Element,
) -> CT_TLCommonBehaviorData {
  { element, }
}

///|
pub fn CT_TLCommonBehaviorData::parse(
  element : @xml.Element,
) -> CT_TLCommonBehaviorData {
  CT_TLCommonBehaviorData::new(element)
}

///|
pub fn CT_TLCommonBehaviorData::to_element(
  self : CT_TLCommonBehaviorData,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimVariantBooleanVal from pml.xsd (§19).
pub(all) struct CT_TLAnimVariantBooleanVal {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimVariantBooleanVal::new(
  element : @xml.Element,
) -> CT_TLAnimVariantBooleanVal {
  { element, }
}

///|
pub fn CT_TLAnimVariantBooleanVal::parse(
  element : @xml.Element,
) -> CT_TLAnimVariantBooleanVal {
  CT_TLAnimVariantBooleanVal::new(element)
}

///|
pub fn CT_TLAnimVariantBooleanVal::to_element(
  self : CT_TLAnimVariantBooleanVal,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimVariantIntegerVal from pml.xsd (§19).
pub(all) struct CT_TLAnimVariantIntegerVal {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimVariantIntegerVal::new(
  element : @xml.Element,
) -> CT_TLAnimVariantIntegerVal {
  { element, }
}

///|
pub fn CT_TLAnimVariantIntegerVal::parse(
  element : @xml.Element,
) -> CT_TLAnimVariantIntegerVal {
  CT_TLAnimVariantIntegerVal::new(element)
}

///|
pub fn CT_TLAnimVariantIntegerVal::to_element(
  self : CT_TLAnimVariantIntegerVal,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimVariantFloatVal from pml.xsd (§19).
pub(all) struct CT_TLAnimVariantFloatVal {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimVariantFloatVal::new(
  element : @xml.Element,
) -> CT_TLAnimVariantFloatVal {
  { element, }
}

///|
pub fn CT_TLAnimVariantFloatVal::parse(
  element : @xml.Element,
) -> CT_TLAnimVariantFloatVal {
  CT_TLAnimVariantFloatVal::new(element)
}

///|
pub fn CT_TLAnimVariantFloatVal::to_element(
  self : CT_TLAnimVariantFloatVal,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimVariantStringVal from pml.xsd (§19).
pub(all) struct CT_TLAnimVariantStringVal {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimVariantStringVal::new(
  element : @xml.Element,
) -> CT_TLAnimVariantStringVal {
  { element, }
}

///|
pub fn CT_TLAnimVariantStringVal::parse(
  element : @xml.Element,
) -> CT_TLAnimVariantStringVal {
  CT_TLAnimVariantStringVal::new(element)
}

///|
pub fn CT_TLAnimVariantStringVal::to_element(
  self : CT_TLAnimVariantStringVal,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimVariant from pml.xsd (§19).
pub(all) struct CT_TLAnimVariant {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimVariant::new(element : @xml.Element) -> CT_TLAnimVariant {
  { element, }
}

///|
pub fn CT_TLAnimVariant::parse(element : @xml.Element) -> CT_TLAnimVariant {
  CT_TLAnimVariant::new(element)
}

///|
pub fn CT_TLAnimVariant::to_element(self : CT_TLAnimVariant) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTimeAnimateValue from pml.xsd (§19).
pub(all) struct CT_TLTimeAnimateValue {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTimeAnimateValue::new(
  element : @xml.Element,
) -> CT_TLTimeAnimateValue {
  { element, }
}

///|
pub fn CT_TLTimeAnimateValue::parse(
  element : @xml.Element,
) -> CT_TLTimeAnimateValue {
  CT_TLTimeAnimateValue::new(element)
}

///|
pub fn CT_TLTimeAnimateValue::to_element(
  self : CT_TLTimeAnimateValue,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTimeAnimateValueList from pml.xsd (§19).
pub(all) struct CT_TLTimeAnimateValueList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTimeAnimateValueList::new(
  element : @xml.Element,
) -> CT_TLTimeAnimateValueList {
  { element, }
}

///|
pub fn CT_TLTimeAnimateValueList::parse(
  element : @xml.Element,
) -> CT_TLTimeAnimateValueList {
  CT_TLTimeAnimateValueList::new(element)
}

///|
pub fn CT_TLTimeAnimateValueList::to_element(
  self : CT_TLTimeAnimateValueList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimateBehavior from pml.xsd (§19).
pub(all) struct CT_TLAnimateBehavior {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimateBehavior::new(
  element : @xml.Element,
) -> CT_TLAnimateBehavior {
  { element, }
}

///|
pub fn CT_TLAnimateBehavior::parse(
  element : @xml.Element,
) -> CT_TLAnimateBehavior {
  CT_TLAnimateBehavior::new(element)
}

///|
pub fn CT_TLAnimateBehavior::to_element(
  self : CT_TLAnimateBehavior,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLByRgbColorTransform from pml.xsd (§19).
pub(all) struct CT_TLByRgbColorTransform {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLByRgbColorTransform::new(
  element : @xml.Element,
) -> CT_TLByRgbColorTransform {
  { element, }
}

///|
pub fn CT_TLByRgbColorTransform::parse(
  element : @xml.Element,
) -> CT_TLByRgbColorTransform {
  CT_TLByRgbColorTransform::new(element)
}

///|
pub fn CT_TLByRgbColorTransform::to_element(
  self : CT_TLByRgbColorTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLByHslColorTransform from pml.xsd (§19).
pub(all) struct CT_TLByHslColorTransform {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLByHslColorTransform::new(
  element : @xml.Element,
) -> CT_TLByHslColorTransform {
  { element, }
}

///|
pub fn CT_TLByHslColorTransform::parse(
  element : @xml.Element,
) -> CT_TLByHslColorTransform {
  CT_TLByHslColorTransform::new(element)
}

///|
pub fn CT_TLByHslColorTransform::to_element(
  self : CT_TLByHslColorTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLByAnimateColorTransform from pml.xsd (§19).
pub(all) struct CT_TLByAnimateColorTransform {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLByAnimateColorTransform::new(
  element : @xml.Element,
) -> CT_TLByAnimateColorTransform {
  { element, }
}

///|
pub fn CT_TLByAnimateColorTransform::parse(
  element : @xml.Element,
) -> CT_TLByAnimateColorTransform {
  CT_TLByAnimateColorTransform::new(element)
}

///|
pub fn CT_TLByAnimateColorTransform::to_element(
  self : CT_TLByAnimateColorTransform,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimateColorBehavior from pml.xsd (§19).
pub(all) struct CT_TLAnimateColorBehavior {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimateColorBehavior::new(
  element : @xml.Element,
) -> CT_TLAnimateColorBehavior {
  { element, }
}

///|
pub fn CT_TLAnimateColorBehavior::parse(
  element : @xml.Element,
) -> CT_TLAnimateColorBehavior {
  CT_TLAnimateColorBehavior::new(element)
}

///|
pub fn CT_TLAnimateColorBehavior::to_element(
  self : CT_TLAnimateColorBehavior,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimateEffectBehavior from pml.xsd (§19).
pub(all) struct CT_TLAnimateEffectBehavior {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimateEffectBehavior::new(
  element : @xml.Element,
) -> CT_TLAnimateEffectBehavior {
  { element, }
}

///|
pub fn CT_TLAnimateEffectBehavior::parse(
  element : @xml.Element,
) -> CT_TLAnimateEffectBehavior {
  CT_TLAnimateEffectBehavior::new(element)
}

///|
pub fn CT_TLAnimateEffectBehavior::to_element(
  self : CT_TLAnimateEffectBehavior,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLPoint from pml.xsd (§19).
pub(all) struct CT_TLPoint {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLPoint::new(element : @xml.Element) -> CT_TLPoint {
  { element, }
}

///|
pub fn CT_TLPoint::parse(element : @xml.Element) -> CT_TLPoint {
  CT_TLPoint::new(element)
}

///|
pub fn CT_TLPoint::to_element(self : CT_TLPoint) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimateMotionBehavior from pml.xsd (§19).
pub(all) struct CT_TLAnimateMotionBehavior {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimateMotionBehavior::new(
  element : @xml.Element,
) -> CT_TLAnimateMotionBehavior {
  { element, }
}

///|
pub fn CT_TLAnimateMotionBehavior::parse(
  element : @xml.Element,
) -> CT_TLAnimateMotionBehavior {
  CT_TLAnimateMotionBehavior::new(element)
}

///|
pub fn CT_TLAnimateMotionBehavior::to_element(
  self : CT_TLAnimateMotionBehavior,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimateRotationBehavior from pml.xsd (§19).
pub(all) struct CT_TLAnimateRotationBehavior {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimateRotationBehavior::new(
  element : @xml.Element,
) -> CT_TLAnimateRotationBehavior {
  { element, }
}

///|
pub fn CT_TLAnimateRotationBehavior::parse(
  element : @xml.Element,
) -> CT_TLAnimateRotationBehavior {
  CT_TLAnimateRotationBehavior::new(element)
}

///|
pub fn CT_TLAnimateRotationBehavior::to_element(
  self : CT_TLAnimateRotationBehavior,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLAnimateScaleBehavior from pml.xsd (§19).
pub(all) struct CT_TLAnimateScaleBehavior {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLAnimateScaleBehavior::new(
  element : @xml.Element,
) -> CT_TLAnimateScaleBehavior {
  { element, }
}

///|
pub fn CT_TLAnimateScaleBehavior::parse(
  element : @xml.Element,
) -> CT_TLAnimateScaleBehavior {
  CT_TLAnimateScaleBehavior::new(element)
}

///|
pub fn CT_TLAnimateScaleBehavior::to_element(
  self : CT_TLAnimateScaleBehavior,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLCommandBehavior from pml.xsd (§19).
pub(all) struct CT_TLCommandBehavior {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLCommandBehavior::new(
  element : @xml.Element,
) -> CT_TLCommandBehavior {
  { element, }
}

///|
pub fn CT_TLCommandBehavior::parse(
  element : @xml.Element,
) -> CT_TLCommandBehavior {
  CT_TLCommandBehavior::new(element)
}

///|
pub fn CT_TLCommandBehavior::to_element(
  self : CT_TLCommandBehavior,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLSetBehavior from pml.xsd (§19).
pub(all) struct CT_TLSetBehavior {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLSetBehavior::new(element : @xml.Element) -> CT_TLSetBehavior {
  { element, }
}

///|
pub fn CT_TLSetBehavior::parse(element : @xml.Element) -> CT_TLSetBehavior {
  CT_TLSetBehavior::new(element)
}

///|
pub fn CT_TLSetBehavior::to_element(self : CT_TLSetBehavior) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLCommonMediaNodeData from pml.xsd (§19).
pub(all) struct CT_TLCommonMediaNodeData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLCommonMediaNodeData::new(
  element : @xml.Element,
) -> CT_TLCommonMediaNodeData {
  { element, }
}

///|
pub fn CT_TLCommonMediaNodeData::parse(
  element : @xml.Element,
) -> CT_TLCommonMediaNodeData {
  CT_TLCommonMediaNodeData::new(element)
}

///|
pub fn CT_TLCommonMediaNodeData::to_element(
  self : CT_TLCommonMediaNodeData,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLMediaNodeAudio from pml.xsd (§19).
pub(all) struct CT_TLMediaNodeAudio {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLMediaNodeAudio::new(element : @xml.Element) -> CT_TLMediaNodeAudio {
  { element, }
}

///|
pub fn CT_TLMediaNodeAudio::parse(
  element : @xml.Element,
) -> CT_TLMediaNodeAudio {
  CT_TLMediaNodeAudio::new(element)
}

///|
pub fn CT_TLMediaNodeAudio::to_element(
  self : CT_TLMediaNodeAudio,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLMediaNodeVideo from pml.xsd (§19).
pub(all) struct CT_TLMediaNodeVideo {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLMediaNodeVideo::new(element : @xml.Element) -> CT_TLMediaNodeVideo {
  { element, }
}

///|
pub fn CT_TLMediaNodeVideo::parse(
  element : @xml.Element,
) -> CT_TLMediaNodeVideo {
  CT_TLMediaNodeVideo::new(element)
}

///|
pub fn CT_TLMediaNodeVideo::to_element(
  self : CT_TLMediaNodeVideo,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTemplate from pml.xsd (§19).
pub(all) struct CT_TLTemplate {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTemplate::new(element : @xml.Element) -> CT_TLTemplate {
  { element, }
}

///|
pub fn CT_TLTemplate::parse(element : @xml.Element) -> CT_TLTemplate {
  CT_TLTemplate::new(element)
}

///|
pub fn CT_TLTemplate::to_element(self : CT_TLTemplate) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLTemplateList from pml.xsd (§19).
pub(all) struct CT_TLTemplateList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLTemplateList::new(element : @xml.Element) -> CT_TLTemplateList {
  { element, }
}

///|
pub fn CT_TLTemplateList::parse(element : @xml.Element) -> CT_TLTemplateList {
  CT_TLTemplateList::new(element)
}

///|
pub fn CT_TLTemplateList::to_element(self : CT_TLTemplateList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLBuildParagraph from pml.xsd (§19).
pub(all) struct CT_TLBuildParagraph {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLBuildParagraph::new(element : @xml.Element) -> CT_TLBuildParagraph {
  { element, }
}

///|
pub fn CT_TLBuildParagraph::parse(
  element : @xml.Element,
) -> CT_TLBuildParagraph {
  CT_TLBuildParagraph::new(element)
}

///|
pub fn CT_TLBuildParagraph::to_element(
  self : CT_TLBuildParagraph,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLBuildDiagram from pml.xsd (§19).
pub(all) struct CT_TLBuildDiagram {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLBuildDiagram::new(element : @xml.Element) -> CT_TLBuildDiagram {
  { element, }
}

///|
pub fn CT_TLBuildDiagram::parse(element : @xml.Element) -> CT_TLBuildDiagram {
  CT_TLBuildDiagram::new(element)
}

///|
pub fn CT_TLBuildDiagram::to_element(self : CT_TLBuildDiagram) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLOleBuildChart from pml.xsd (§19).
pub(all) struct CT_TLOleBuildChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLOleBuildChart::new(element : @xml.Element) -> CT_TLOleBuildChart {
  { element, }
}

///|
pub fn CT_TLOleBuildChart::parse(element : @xml.Element) -> CT_TLOleBuildChart {
  CT_TLOleBuildChart::new(element)
}

///|
pub fn CT_TLOleBuildChart::to_element(
  self : CT_TLOleBuildChart,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TLGraphicalObjectBuild from pml.xsd (§19).
pub(all) struct CT_TLGraphicalObjectBuild {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TLGraphicalObjectBuild::new(
  element : @xml.Element,
) -> CT_TLGraphicalObjectBuild {
  { element, }
}

///|
pub fn CT_TLGraphicalObjectBuild::parse(
  element : @xml.Element,
) -> CT_TLGraphicalObjectBuild {
  CT_TLGraphicalObjectBuild::new(element)
}

///|
pub fn CT_TLGraphicalObjectBuild::to_element(
  self : CT_TLGraphicalObjectBuild,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BuildList from pml.xsd (§19).
pub(all) struct CT_BuildList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BuildList::new(element : @xml.Element) -> CT_BuildList {
  { element, }
}

///|
pub fn CT_BuildList::parse(element : @xml.Element) -> CT_BuildList {
  CT_BuildList::new(element)
}

///|
pub fn CT_BuildList::to_element(self : CT_BuildList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideTiming from pml.xsd (§19).
pub(all) struct CT_SlideTiming {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideTiming::new(element : @xml.Element) -> CT_SlideTiming {
  { element, }
}

///|
pub fn CT_SlideTiming::parse(element : @xml.Element) -> CT_SlideTiming {
  CT_SlideTiming::new(element)
}

///|
pub fn CT_SlideTiming::to_element(self : CT_SlideTiming) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Empty from pml.xsd (§19).
pub(all) struct CT_Empty {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Empty::new(element : @xml.Element) -> CT_Empty {
  { element, }
}

///|
pub fn CT_Empty::parse(element : @xml.Element) -> CT_Empty {
  CT_Empty::new(element)
}

///|
pub fn CT_Empty::to_element(self : CT_Empty) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_IndexRange from pml.xsd (§19).
pub(all) struct CT_IndexRange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_IndexRange::new(element : @xml.Element) -> CT_IndexRange {
  { element, }
}

///|
pub fn CT_IndexRange::parse(element : @xml.Element) -> CT_IndexRange {
  CT_IndexRange::new(element)
}

///|
pub fn CT_IndexRange::to_element(self : CT_IndexRange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideRelationshipListEntry from pml.xsd (§19).
pub(all) struct CT_SlideRelationshipListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideRelationshipListEntry::new(
  element : @xml.Element,
) -> CT_SlideRelationshipListEntry {
  { element, }
}

///|
pub fn CT_SlideRelationshipListEntry::parse(
  element : @xml.Element,
) -> CT_SlideRelationshipListEntry {
  CT_SlideRelationshipListEntry::new(element)
}

///|
pub fn CT_SlideRelationshipListEntry::to_element(
  self : CT_SlideRelationshipListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideRelationshipList from pml.xsd (§19).
pub(all) struct CT_SlideRelationshipList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideRelationshipList::new(
  element : @xml.Element,
) -> CT_SlideRelationshipList {
  { element, }
}

///|
pub fn CT_SlideRelationshipList::parse(
  element : @xml.Element,
) -> CT_SlideRelationshipList {
  CT_SlideRelationshipList::new(element)
}

///|
pub fn CT_SlideRelationshipList::to_element(
  self : CT_SlideRelationshipList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomShowId from pml.xsd (§19).
pub(all) struct CT_CustomShowId {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomShowId::new(element : @xml.Element) -> CT_CustomShowId {
  { element, }
}

///|
pub fn CT_CustomShowId::parse(element : @xml.Element) -> CT_CustomShowId {
  CT_CustomShowId::new(element)
}

///|
pub fn CT_CustomShowId::to_element(self : CT_CustomShowId) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomerData from pml.xsd (§19).
pub(all) struct CT_CustomerData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomerData::new(element : @xml.Element) -> CT_CustomerData {
  { element, }
}

///|
pub fn CT_CustomerData::parse(element : @xml.Element) -> CT_CustomerData {
  CT_CustomerData::new(element)
}

///|
pub fn CT_CustomerData::to_element(self : CT_CustomerData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TagsData from pml.xsd (§19).
pub(all) struct CT_TagsData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TagsData::new(element : @xml.Element) -> CT_TagsData {
  { element, }
}

///|
pub fn CT_TagsData::parse(element : @xml.Element) -> CT_TagsData {
  CT_TagsData::new(element)
}

///|
pub fn CT_TagsData::to_element(self : CT_TagsData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomerDataList from pml.xsd (§19).
pub(all) struct CT_CustomerDataList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomerDataList::new(element : @xml.Element) -> CT_CustomerDataList {
  { element, }
}

///|
pub fn CT_CustomerDataList::parse(
  element : @xml.Element,
) -> CT_CustomerDataList {
  CT_CustomerDataList::new(element)
}

///|
pub fn CT_CustomerDataList::to_element(
  self : CT_CustomerDataList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Extension from pml.xsd (§19).
pub(all) struct CT_Extension {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Extension::new(element : @xml.Element) -> CT_Extension {
  { element, }
}

///|
pub fn CT_Extension::parse(element : @xml.Element) -> CT_Extension {
  CT_Extension::new(element)
}

///|
pub fn CT_Extension::to_element(self : CT_Extension) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ExtensionList from pml.xsd (§19).
pub(all) struct CT_ExtensionList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExtensionList::new(element : @xml.Element) -> CT_ExtensionList {
  { element, }
}

///|
pub fn CT_ExtensionList::parse(element : @xml.Element) -> CT_ExtensionList {
  CT_ExtensionList::new(element)
}

///|
pub fn CT_ExtensionList::to_element(self : CT_ExtensionList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ExtensionListModify from pml.xsd (§19).
pub(all) struct CT_ExtensionListModify {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ExtensionListModify::new(
  element : @xml.Element,
) -> CT_ExtensionListModify {
  { element, }
}

///|
pub fn CT_ExtensionListModify::parse(
  element : @xml.Element,
) -> CT_ExtensionListModify {
  CT_ExtensionListModify::new(element)
}

///|
pub fn CT_ExtensionListModify::to_element(
  self : CT_ExtensionListModify,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommentAuthor from pml.xsd (§19).
pub(all) struct CT_CommentAuthor {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommentAuthor::new(element : @xml.Element) -> CT_CommentAuthor {
  { element, }
}

///|
pub fn CT_CommentAuthor::parse(element : @xml.Element) -> CT_CommentAuthor {
  CT_CommentAuthor::new(element)
}

///|
pub fn CT_CommentAuthor::to_element(self : CT_CommentAuthor) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommentAuthorList from pml.xsd (§19).
pub(all) struct CT_CommentAuthorList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommentAuthorList::new(
  element : @xml.Element,
) -> CT_CommentAuthorList {
  { element, }
}

///|
pub fn CT_CommentAuthorList::parse(
  element : @xml.Element,
) -> CT_CommentAuthorList {
  CT_CommentAuthorList::new(element)
}

///|
pub fn CT_CommentAuthorList::to_element(
  self : CT_CommentAuthorList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Comment from pml.xsd (§19).
pub(all) struct CT_Comment {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Comment::new(element : @xml.Element) -> CT_Comment {
  { element, }
}

///|
pub fn CT_Comment::parse(element : @xml.Element) -> CT_Comment {
  CT_Comment::new(element)
}

///|
pub fn CT_Comment::to_element(self : CT_Comment) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommentList from pml.xsd (§19).
pub(all) struct CT_CommentList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommentList::new(element : @xml.Element) -> CT_CommentList {
  { element, }
}

///|
pub fn CT_CommentList::parse(element : @xml.Element) -> CT_CommentList {
  CT_CommentList::new(element)
}

///|
pub fn CT_CommentList::to_element(self : CT_CommentList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OleObjectEmbed from pml.xsd (§19).
pub(all) struct CT_OleObjectEmbed {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleObjectEmbed::new(element : @xml.Element) -> CT_OleObjectEmbed {
  { element, }
}

///|
pub fn CT_OleObjectEmbed::parse(element : @xml.Element) -> CT_OleObjectEmbed {
  CT_OleObjectEmbed::new(element)
}

///|
pub fn CT_OleObjectEmbed::to_element(self : CT_OleObjectEmbed) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OleObjectLink from pml.xsd (§19).
pub(all) struct CT_OleObjectLink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleObjectLink::new(element : @xml.Element) -> CT_OleObjectLink {
  { element, }
}

///|
pub fn CT_OleObjectLink::parse(element : @xml.Element) -> CT_OleObjectLink {
  CT_OleObjectLink::new(element)
}

///|
pub fn CT_OleObjectLink::to_element(self : CT_OleObjectLink) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OleObject from pml.xsd (§19).
pub(all) struct CT_OleObject {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OleObject::new(element : @xml.Element) -> CT_OleObject {
  { element, }
}

///|
pub fn CT_OleObject::parse(element : @xml.Element) -> CT_OleObject {
  CT_OleObject::new(element)
}

///|
pub fn CT_OleObject::to_element(self : CT_OleObject) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Control from pml.xsd (§19).
pub(all) struct CT_Control {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Control::new(element : @xml.Element) -> CT_Control {
  { element, }
}

///|
pub fn CT_Control::parse(element : @xml.Element) -> CT_Control {
  CT_Control::new(element)
}

///|
pub fn CT_Control::to_element(self : CT_Control) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ControlList from pml.xsd (§19).
pub(all) struct CT_ControlList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ControlList::new(element : @xml.Element) -> CT_ControlList {
  { element, }
}

///|
pub fn CT_ControlList::parse(element : @xml.Element) -> CT_ControlList {
  CT_ControlList::new(element)
}

///|
pub fn CT_ControlList::to_element(self : CT_ControlList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideIdListEntry from pml.xsd (§19).
pub(all) struct CT_SlideIdListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideIdListEntry::new(element : @xml.Element) -> CT_SlideIdListEntry {
  { element, }
}

///|
pub fn CT_SlideIdListEntry::parse(
  element : @xml.Element,
) -> CT_SlideIdListEntry {
  CT_SlideIdListEntry::new(element)
}

///|
pub fn CT_SlideIdListEntry::to_element(
  self : CT_SlideIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideIdList from pml.xsd (§19).
pub(all) struct CT_SlideIdList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideIdList::new(element : @xml.Element) -> CT_SlideIdList {
  { element, }
}

///|
pub fn CT_SlideIdList::parse(element : @xml.Element) -> CT_SlideIdList {
  CT_SlideIdList::new(element)
}

///|
pub fn CT_SlideIdList::to_element(self : CT_SlideIdList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMasterIdListEntry from pml.xsd (§19).
pub(all) struct CT_SlideMasterIdListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideMasterIdListEntry::new(
  element : @xml.Element,
) -> CT_SlideMasterIdListEntry {
  { element, }
}

///|
pub fn CT_SlideMasterIdListEntry::parse(
  element : @xml.Element,
) -> CT_SlideMasterIdListEntry {
  CT_SlideMasterIdListEntry::new(element)
}

///|
pub fn CT_SlideMasterIdListEntry::to_element(
  self : CT_SlideMasterIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMasterIdList from pml.xsd (§19).
pub(all) struct CT_SlideMasterIdList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideMasterIdList::new(
  element : @xml.Element,
) -> CT_SlideMasterIdList {
  { element, }
}

///|
pub fn CT_SlideMasterIdList::parse(
  element : @xml.Element,
) -> CT_SlideMasterIdList {
  CT_SlideMasterIdList::new(element)
}

///|
pub fn CT_SlideMasterIdList::to_element(
  self : CT_SlideMasterIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesMasterIdListEntry from pml.xsd (§19).
pub(all) struct CT_NotesMasterIdListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesMasterIdListEntry::new(
  element : @xml.Element,
) -> CT_NotesMasterIdListEntry {
  { element, }
}

///|
pub fn CT_NotesMasterIdListEntry::parse(
  element : @xml.Element,
) -> CT_NotesMasterIdListEntry {
  CT_NotesMasterIdListEntry::new(element)
}

///|
pub fn CT_NotesMasterIdListEntry::to_element(
  self : CT_NotesMasterIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesMasterIdList from pml.xsd (§19).
pub(all) struct CT_NotesMasterIdList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesMasterIdList::new(
  element : @xml.Element,
) -> CT_NotesMasterIdList {
  { element, }
}

///|
pub fn CT_NotesMasterIdList::parse(
  element : @xml.Element,
) -> CT_NotesMasterIdList {
  CT_NotesMasterIdList::new(element)
}

///|
pub fn CT_NotesMasterIdList::to_element(
  self : CT_NotesMasterIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HandoutMasterIdListEntry from pml.xsd (§19).
pub(all) struct CT_HandoutMasterIdListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HandoutMasterIdListEntry::new(
  element : @xml.Element,
) -> CT_HandoutMasterIdListEntry {
  { element, }
}

///|
pub fn CT_HandoutMasterIdListEntry::parse(
  element : @xml.Element,
) -> CT_HandoutMasterIdListEntry {
  CT_HandoutMasterIdListEntry::new(element)
}

///|
pub fn CT_HandoutMasterIdListEntry::to_element(
  self : CT_HandoutMasterIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HandoutMasterIdList from pml.xsd (§19).
pub(all) struct CT_HandoutMasterIdList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HandoutMasterIdList::new(
  element : @xml.Element,
) -> CT_HandoutMasterIdList {
  { element, }
}

///|
pub fn CT_HandoutMasterIdList::parse(
  element : @xml.Element,
) -> CT_HandoutMasterIdList {
  CT_HandoutMasterIdList::new(element)
}

///|
pub fn CT_HandoutMasterIdList::to_element(
  self : CT_HandoutMasterIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmbeddedFontDataId from pml.xsd (§19).
pub(all) struct CT_EmbeddedFontDataId {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedFontDataId::new(
  element : @xml.Element,
) -> CT_EmbeddedFontDataId {
  { element, }
}

///|
pub fn CT_EmbeddedFontDataId::parse(
  element : @xml.Element,
) -> CT_EmbeddedFontDataId {
  CT_EmbeddedFontDataId::new(element)
}

///|
pub fn CT_EmbeddedFontDataId::to_element(
  self : CT_EmbeddedFontDataId,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmbeddedFontListEntry from pml.xsd (§19).
pub(all) struct CT_EmbeddedFontListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedFontListEntry::new(
  element : @xml.Element,
) -> CT_EmbeddedFontListEntry {
  { element, }
}

///|
pub fn CT_EmbeddedFontListEntry::parse(
  element : @xml.Element,
) -> CT_EmbeddedFontListEntry {
  CT_EmbeddedFontListEntry::new(element)
}

///|
pub fn CT_EmbeddedFontListEntry::to_element(
  self : CT_EmbeddedFontListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmbeddedFontList from pml.xsd (§19).
pub(all) struct CT_EmbeddedFontList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedFontList::new(element : @xml.Element) -> CT_EmbeddedFontList {
  { element, }
}

///|
pub fn CT_EmbeddedFontList::parse(
  element : @xml.Element,
) -> CT_EmbeddedFontList {
  CT_EmbeddedFontList::new(element)
}

///|
pub fn CT_EmbeddedFontList::to_element(
  self : CT_EmbeddedFontList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTags from pml.xsd (§19).
pub(all) struct CT_SmartTags {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTags::new(element : @xml.Element) -> CT_SmartTags {
  { element, }
}

///|
pub fn CT_SmartTags::parse(element : @xml.Element) -> CT_SmartTags {
  CT_SmartTags::new(element)
}

///|
pub fn CT_SmartTags::to_element(self : CT_SmartTags) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomShow from pml.xsd (§19).
pub(all) struct CT_CustomShow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomShow::new(element : @xml.Element) -> CT_CustomShow {
  { element, }
}

///|
pub fn CT_CustomShow::parse(element : @xml.Element) -> CT_CustomShow {
  CT_CustomShow::new(element)
}

///|
pub fn CT_CustomShow::to_element(self : CT_CustomShow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomShowList from pml.xsd (§19).
pub(all) struct CT_CustomShowList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomShowList::new(element : @xml.Element) -> CT_CustomShowList {
  { element, }
}

///|
pub fn CT_CustomShowList::parse(element : @xml.Element) -> CT_CustomShowList {
  CT_CustomShowList::new(element)
}

///|
pub fn CT_CustomShowList::to_element(self : CT_CustomShowList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PhotoAlbum from pml.xsd (§19).
pub(all) struct CT_PhotoAlbum {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PhotoAlbum::new(element : @xml.Element) -> CT_PhotoAlbum {
  { element, }
}

///|
pub fn CT_PhotoAlbum::parse(element : @xml.Element) -> CT_PhotoAlbum {
  CT_PhotoAlbum::new(element)
}

///|
pub fn CT_PhotoAlbum::to_element(self : CT_PhotoAlbum) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideSize from pml.xsd (§19).
pub(all) struct CT_SlideSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideSize::new(element : @xml.Element) -> CT_SlideSize {
  { element, }
}

///|
pub fn CT_SlideSize::parse(element : @xml.Element) -> CT_SlideSize {
  CT_SlideSize::new(element)
}

///|
pub fn CT_SlideSize::to_element(self : CT_SlideSize) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Kinsoku from pml.xsd (§19).
pub(all) struct CT_Kinsoku {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Kinsoku::new(element : @xml.Element) -> CT_Kinsoku {
  { element, }
}

///|
pub fn CT_Kinsoku::parse(element : @xml.Element) -> CT_Kinsoku {
  CT_Kinsoku::new(element)
}

///|
pub fn CT_Kinsoku::to_element(self : CT_Kinsoku) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ModifyVerifier from pml.xsd (§19).
pub(all) struct CT_ModifyVerifier {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ModifyVerifier::new(element : @xml.Element) -> CT_ModifyVerifier {
  { element, }
}

///|
pub fn CT_ModifyVerifier::parse(element : @xml.Element) -> CT_ModifyVerifier {
  CT_ModifyVerifier::new(element)
}

///|
pub fn CT_ModifyVerifier::to_element(self : CT_ModifyVerifier) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Presentation from pml.xsd (§19).
pub(all) struct CT_Presentation {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Presentation::new(element : @xml.Element) -> CT_Presentation {
  { element, }
}

///|
pub fn CT_Presentation::parse(element : @xml.Element) -> CT_Presentation {
  CT_Presentation::new(element)
}

///|
pub fn CT_Presentation::to_element(self : CT_Presentation) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HtmlPublishProperties from pml.xsd (§19).
pub(all) struct CT_HtmlPublishProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HtmlPublishProperties::new(
  element : @xml.Element,
) -> CT_HtmlPublishProperties {
  { element, }
}

///|
pub fn CT_HtmlPublishProperties::parse(
  element : @xml.Element,
) -> CT_HtmlPublishProperties {
  CT_HtmlPublishProperties::new(element)
}

///|
pub fn CT_HtmlPublishProperties::to_element(
  self : CT_HtmlPublishProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PrintProperties from pml.xsd (§19).
pub(all) struct CT_PrintProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PrintProperties::new(element : @xml.Element) -> CT_PrintProperties {
  { element, }
}

///|
pub fn CT_PrintProperties::parse(element : @xml.Element) -> CT_PrintProperties {
  CT_PrintProperties::new(element)
}

///|
pub fn CT_PrintProperties::to_element(
  self : CT_PrintProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShowInfoBrowse from pml.xsd (§19).
pub(all) struct CT_ShowInfoBrowse {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShowInfoBrowse::new(element : @xml.Element) -> CT_ShowInfoBrowse {
  { element, }
}

///|
pub fn CT_ShowInfoBrowse::parse(element : @xml.Element) -> CT_ShowInfoBrowse {
  CT_ShowInfoBrowse::new(element)
}

///|
pub fn CT_ShowInfoBrowse::to_element(self : CT_ShowInfoBrowse) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShowInfoKiosk from pml.xsd (§19).
pub(all) struct CT_ShowInfoKiosk {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShowInfoKiosk::new(element : @xml.Element) -> CT_ShowInfoKiosk {
  { element, }
}

///|
pub fn CT_ShowInfoKiosk::parse(element : @xml.Element) -> CT_ShowInfoKiosk {
  CT_ShowInfoKiosk::new(element)
}

///|
pub fn CT_ShowInfoKiosk::to_element(self : CT_ShowInfoKiosk) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShowProperties from pml.xsd (§19).
pub(all) struct CT_ShowProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShowProperties::new(element : @xml.Element) -> CT_ShowProperties {
  { element, }
}

///|
pub fn CT_ShowProperties::parse(element : @xml.Element) -> CT_ShowProperties {
  CT_ShowProperties::new(element)
}

///|
pub fn CT_ShowProperties::to_element(self : CT_ShowProperties) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PresentationProperties from pml.xsd (§19).
pub(all) struct CT_PresentationProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresentationProperties::new(
  element : @xml.Element,
) -> CT_PresentationProperties {
  { element, }
}

///|
pub fn CT_PresentationProperties::parse(
  element : @xml.Element,
) -> CT_PresentationProperties {
  CT_PresentationProperties::new(element)
}

///|
pub fn CT_PresentationProperties::to_element(
  self : CT_PresentationProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HeaderFooter from pml.xsd (§19).
pub(all) struct CT_HeaderFooter {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HeaderFooter::new(element : @xml.Element) -> CT_HeaderFooter {
  { element, }
}

///|
pub fn CT_HeaderFooter::parse(element : @xml.Element) -> CT_HeaderFooter {
  CT_HeaderFooter::new(element)
}

///|
pub fn CT_HeaderFooter::to_element(self : CT_HeaderFooter) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Placeholder from pml.xsd (§19).
pub(all) struct CT_Placeholder {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Placeholder::new(element : @xml.Element) -> CT_Placeholder {
  { element, }
}

///|
pub fn CT_Placeholder::parse(element : @xml.Element) -> CT_Placeholder {
  CT_Placeholder::new(element)
}

///|
pub fn CT_Placeholder::to_element(self : CT_Placeholder) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ApplicationNonVisualDrawingProps from pml.xsd (§19).
pub(all) struct CT_ApplicationNonVisualDrawingProps {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ApplicationNonVisualDrawingProps::new(
  element : @xml.Element,
) -> CT_ApplicationNonVisualDrawingProps {
  { element, }
}

///|
pub fn CT_ApplicationNonVisualDrawingProps::parse(
  element : @xml.Element,
) -> CT_ApplicationNonVisualDrawingProps {
  CT_ApplicationNonVisualDrawingProps::new(element)
}

///|
pub fn CT_ApplicationNonVisualDrawingProps::to_element(
  self : CT_ApplicationNonVisualDrawingProps,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShapeNonVisual from pml.xsd (§19).
pub(all) struct CT_ShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeNonVisual::new(element : @xml.Element) -> CT_ShapeNonVisual {
  { element, }
}

///|
pub fn CT_ShapeNonVisual::parse(element : @xml.Element) -> CT_ShapeNonVisual {
  CT_ShapeNonVisual::new(element)
}

///|
pub fn CT_ShapeNonVisual::to_element(self : CT_ShapeNonVisual) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Shape: Schema pml.xsd complex type `CT_Shape` has
/// attribute `useBgFill` and child elements `nvSpPr`, `spPr`, `style`,
/// `txBody`, and `extLst`; CT_Shape, CT_Shape::new, CT_Shape::parse, and
/// CT_Shape::to_element own that slide shape payload.
pub(all) struct CT_Shape {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shape::new(element : @xml.Element) -> CT_Shape {
  { element, }
}

///|
pub fn CT_Shape::parse(element : @xml.Element) -> CT_Shape {
  CT_Shape::new(element)
}

///|
pub fn CT_Shape::to_element(self : CT_Shape) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ConnectorNonVisual from pml.xsd (§19).
pub(all) struct CT_ConnectorNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConnectorNonVisual::new(
  element : @xml.Element,
) -> CT_ConnectorNonVisual {
  { element, }
}

///|
pub fn CT_ConnectorNonVisual::parse(
  element : @xml.Element,
) -> CT_ConnectorNonVisual {
  CT_ConnectorNonVisual::new(element)
}

///|
pub fn CT_ConnectorNonVisual::to_element(
  self : CT_ConnectorNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Connector from pml.xsd (§19).
pub(all) struct CT_Connector {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Connector::new(element : @xml.Element) -> CT_Connector {
  { element, }
}

///|
pub fn CT_Connector::parse(element : @xml.Element) -> CT_Connector {
  CT_Connector::new(element)
}

///|
pub fn CT_Connector::to_element(self : CT_Connector) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PictureNonVisual from pml.xsd (§19).
pub(all) struct CT_PictureNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PictureNonVisual::new(element : @xml.Element) -> CT_PictureNonVisual {
  { element, }
}

///|
pub fn CT_PictureNonVisual::parse(
  element : @xml.Element,
) -> CT_PictureNonVisual {
  CT_PictureNonVisual::new(element)
}

///|
pub fn CT_PictureNonVisual::to_element(
  self : CT_PictureNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Picture from pml.xsd (§19).
pub(all) struct CT_Picture {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Picture::new(element : @xml.Element) -> CT_Picture {
  { element, }
}

///|
pub fn CT_Picture::parse(element : @xml.Element) -> CT_Picture {
  CT_Picture::new(element)
}

///|
pub fn CT_Picture::to_element(self : CT_Picture) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GraphicalObjectFrameNonVisual from pml.xsd (§19).
pub(all) struct CT_GraphicalObjectFrameNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObjectFrameNonVisual::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrameNonVisual {
  { element, }
}

///|
pub fn CT_GraphicalObjectFrameNonVisual::parse(
  element : @xml.Element,
) -> CT_GraphicalObjectFrameNonVisual {
  CT_GraphicalObjectFrameNonVisual::new(element)
}

///|
pub fn CT_GraphicalObjectFrameNonVisual::to_element(
  self : CT_GraphicalObjectFrameNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GraphicalObjectFrame from pml.xsd (§19).
pub(all) struct CT_GraphicalObjectFrame {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObjectFrame::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrame {
  { element, }
}

///|
pub fn CT_GraphicalObjectFrame::parse(
  element : @xml.Element,
) -> CT_GraphicalObjectFrame {
  CT_GraphicalObjectFrame::new(element)
}

///|
pub fn CT_GraphicalObjectFrame::to_element(
  self : CT_GraphicalObjectFrame,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GroupShapeNonVisual from pml.xsd (§19).
pub(all) struct CT_GroupShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupShapeNonVisual::new(
  element : @xml.Element,
) -> CT_GroupShapeNonVisual {
  { element, }
}

///|
pub fn CT_GroupShapeNonVisual::parse(
  element : @xml.Element,
) -> CT_GroupShapeNonVisual {
  CT_GroupShapeNonVisual::new(element)
}

///|
pub fn CT_GroupShapeNonVisual::to_element(
  self : CT_GroupShapeNonVisual,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GroupShape from pml.xsd (§19).
pub(all) struct CT_GroupShape {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupShape::new(element : @xml.Element) -> CT_GroupShape {
  { element, }
}

///|
pub fn CT_GroupShape::parse(element : @xml.Element) -> CT_GroupShape {
  CT_GroupShape::new(element)
}

///|
pub fn CT_GroupShape::to_element(self : CT_GroupShape) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Rel: Schema pml.xsd complex type `CT_Rel` references
/// the `r:id` relationship attribute group; CT_Rel, CT_Rel::new,
/// CT_Rel::parse, and CT_Rel::to_element own that relationship payload.
/// The package also cites Schema vml-presentationDrawing.xsd complex type
/// `CT_Rel` with attribute `id`, represented by VmlPresentationDrawing_CT_Rel
/// in the VML presentation drawing domain file.
pub(all) struct CT_Rel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rel::new(element : @xml.Element) -> CT_Rel {
  { element, }
}

///|
pub fn CT_Rel::parse(element : @xml.Element) -> CT_Rel {
  CT_Rel::new(element)
}

///|
pub fn CT_Rel::to_element(self : CT_Rel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BackgroundProperties from pml.xsd (§19).
pub(all) struct CT_BackgroundProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BackgroundProperties::new(
  element : @xml.Element,
) -> CT_BackgroundProperties {
  { element, }
}

///|
pub fn CT_BackgroundProperties::parse(
  element : @xml.Element,
) -> CT_BackgroundProperties {
  CT_BackgroundProperties::new(element)
}

///|
pub fn CT_BackgroundProperties::to_element(
  self : CT_BackgroundProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Background from pml.xsd (§19).
pub(all) struct CT_Background {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Background::new(element : @xml.Element) -> CT_Background {
  { element, }
}

///|
pub fn CT_Background::parse(element : @xml.Element) -> CT_Background {
  CT_Background::new(element)
}

///|
pub fn CT_Background::to_element(self : CT_Background) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommonSlideData from pml.xsd (§19).
pub(all) struct CT_CommonSlideData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommonSlideData::new(element : @xml.Element) -> CT_CommonSlideData {
  { element, }
}

///|
pub fn CT_CommonSlideData::parse(element : @xml.Element) -> CT_CommonSlideData {
  CT_CommonSlideData::new(element)
}

///|
pub fn CT_CommonSlideData::to_element(
  self : CT_CommonSlideData,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Slide from pml.xsd (§19).
pub(all) struct CT_Slide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Slide::new(element : @xml.Element) -> CT_Slide {
  { element, }
}

///|
pub fn CT_Slide::parse(element : @xml.Element) -> CT_Slide {
  CT_Slide::new(element)
}

///|
pub fn CT_Slide::to_element(self : CT_Slide) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideLayout from pml.xsd (§19).
pub(all) struct CT_SlideLayout {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideLayout::new(element : @xml.Element) -> CT_SlideLayout {
  { element, }
}

///|
pub fn CT_SlideLayout::parse(element : @xml.Element) -> CT_SlideLayout {
  CT_SlideLayout::new(element)
}

///|
pub fn CT_SlideLayout::to_element(self : CT_SlideLayout) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMasterTextStyles from pml.xsd (§19).
pub(all) struct CT_SlideMasterTextStyles {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideMasterTextStyles::new(
  element : @xml.Element,
) -> CT_SlideMasterTextStyles {
  { element, }
}

///|
pub fn CT_SlideMasterTextStyles::parse(
  element : @xml.Element,
) -> CT_SlideMasterTextStyles {
  CT_SlideMasterTextStyles::new(element)
}

///|
pub fn CT_SlideMasterTextStyles::to_element(
  self : CT_SlideMasterTextStyles,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideLayoutIdListEntry from pml.xsd (§19).
pub(all) struct CT_SlideLayoutIdListEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideLayoutIdListEntry::new(
  element : @xml.Element,
) -> CT_SlideLayoutIdListEntry {
  { element, }
}

///|
pub fn CT_SlideLayoutIdListEntry::parse(
  element : @xml.Element,
) -> CT_SlideLayoutIdListEntry {
  CT_SlideLayoutIdListEntry::new(element)
}

///|
pub fn CT_SlideLayoutIdListEntry::to_element(
  self : CT_SlideLayoutIdListEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideLayoutIdList from pml.xsd (§19).
pub(all) struct CT_SlideLayoutIdList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideLayoutIdList::new(
  element : @xml.Element,
) -> CT_SlideLayoutIdList {
  { element, }
}

///|
pub fn CT_SlideLayoutIdList::parse(
  element : @xml.Element,
) -> CT_SlideLayoutIdList {
  CT_SlideLayoutIdList::new(element)
}

///|
pub fn CT_SlideLayoutIdList::to_element(
  self : CT_SlideLayoutIdList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideMaster from pml.xsd (§19).
pub(all) struct CT_SlideMaster {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideMaster::new(element : @xml.Element) -> CT_SlideMaster {
  { element, }
}

///|
pub fn CT_SlideMaster::parse(element : @xml.Element) -> CT_SlideMaster {
  CT_SlideMaster::new(element)
}

///|
pub fn CT_SlideMaster::to_element(self : CT_SlideMaster) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HandoutMaster from pml.xsd (§19).
pub(all) struct CT_HandoutMaster {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HandoutMaster::new(element : @xml.Element) -> CT_HandoutMaster {
  { element, }
}

///|
pub fn CT_HandoutMaster::parse(element : @xml.Element) -> CT_HandoutMaster {
  CT_HandoutMaster::new(element)
}

///|
pub fn CT_HandoutMaster::to_element(self : CT_HandoutMaster) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesMaster from pml.xsd (§19).
pub(all) struct CT_NotesMaster {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesMaster::new(element : @xml.Element) -> CT_NotesMaster {
  { element, }
}

///|
pub fn CT_NotesMaster::parse(element : @xml.Element) -> CT_NotesMaster {
  CT_NotesMaster::new(element)
}

///|
pub fn CT_NotesMaster::to_element(self : CT_NotesMaster) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesSlide from pml.xsd (§19).
pub(all) struct CT_NotesSlide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesSlide::new(element : @xml.Element) -> CT_NotesSlide {
  { element, }
}

///|
pub fn CT_NotesSlide::parse(element : @xml.Element) -> CT_NotesSlide {
  CT_NotesSlide::new(element)
}

///|
pub fn CT_NotesSlide::to_element(self : CT_NotesSlide) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideSyncProperties from pml.xsd (§19).
pub(all) struct CT_SlideSyncProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideSyncProperties::new(
  element : @xml.Element,
) -> CT_SlideSyncProperties {
  { element, }
}

///|
pub fn CT_SlideSyncProperties::parse(
  element : @xml.Element,
) -> CT_SlideSyncProperties {
  CT_SlideSyncProperties::new(element)
}

///|
pub fn CT_SlideSyncProperties::to_element(
  self : CT_SlideSyncProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StringTag from pml.xsd (§19).
pub(all) struct CT_StringTag {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StringTag::new(element : @xml.Element) -> CT_StringTag {
  { element, }
}

///|
pub fn CT_StringTag::parse(element : @xml.Element) -> CT_StringTag {
  CT_StringTag::new(element)
}

///|
pub fn CT_StringTag::to_element(self : CT_StringTag) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TagList from pml.xsd (§19).
pub(all) struct CT_TagList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TagList::new(element : @xml.Element) -> CT_TagList {
  { element, }
}

///|
pub fn CT_TagList::parse(element : @xml.Element) -> CT_TagList {
  CT_TagList::new(element)
}

///|
pub fn CT_TagList::to_element(self : CT_TagList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NormalViewPortion from pml.xsd (§19).
pub(all) struct CT_NormalViewPortion {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NormalViewPortion::new(
  element : @xml.Element,
) -> CT_NormalViewPortion {
  { element, }
}

///|
pub fn CT_NormalViewPortion::parse(
  element : @xml.Element,
) -> CT_NormalViewPortion {
  CT_NormalViewPortion::new(element)
}

///|
pub fn CT_NormalViewPortion::to_element(
  self : CT_NormalViewPortion,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NormalViewProperties from pml.xsd (§19).
pub(all) struct CT_NormalViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NormalViewProperties::new(
  element : @xml.Element,
) -> CT_NormalViewProperties {
  { element, }
}

///|
pub fn CT_NormalViewProperties::parse(
  element : @xml.Element,
) -> CT_NormalViewProperties {
  CT_NormalViewProperties::new(element)
}

///|
pub fn CT_NormalViewProperties::to_element(
  self : CT_NormalViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommonViewProperties from pml.xsd (§19).
pub(all) struct CT_CommonViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommonViewProperties::new(
  element : @xml.Element,
) -> CT_CommonViewProperties {
  { element, }
}

///|
pub fn CT_CommonViewProperties::parse(
  element : @xml.Element,
) -> CT_CommonViewProperties {
  CT_CommonViewProperties::new(element)
}

///|
pub fn CT_CommonViewProperties::to_element(
  self : CT_CommonViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesTextViewProperties from pml.xsd (§19).
pub(all) struct CT_NotesTextViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesTextViewProperties::new(
  element : @xml.Element,
) -> CT_NotesTextViewProperties {
  { element, }
}

///|
pub fn CT_NotesTextViewProperties::parse(
  element : @xml.Element,
) -> CT_NotesTextViewProperties {
  CT_NotesTextViewProperties::new(element)
}

///|
pub fn CT_NotesTextViewProperties::to_element(
  self : CT_NotesTextViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OutlineViewSlideEntry from pml.xsd (§19).
pub(all) struct CT_OutlineViewSlideEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OutlineViewSlideEntry::new(
  element : @xml.Element,
) -> CT_OutlineViewSlideEntry {
  { element, }
}

///|
pub fn CT_OutlineViewSlideEntry::parse(
  element : @xml.Element,
) -> CT_OutlineViewSlideEntry {
  CT_OutlineViewSlideEntry::new(element)
}

///|
pub fn CT_OutlineViewSlideEntry::to_element(
  self : CT_OutlineViewSlideEntry,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OutlineViewSlideList from pml.xsd (§19).
pub(all) struct CT_OutlineViewSlideList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OutlineViewSlideList::new(
  element : @xml.Element,
) -> CT_OutlineViewSlideList {
  { element, }
}

///|
pub fn CT_OutlineViewSlideList::parse(
  element : @xml.Element,
) -> CT_OutlineViewSlideList {
  CT_OutlineViewSlideList::new(element)
}

///|
pub fn CT_OutlineViewSlideList::to_element(
  self : CT_OutlineViewSlideList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OutlineViewProperties from pml.xsd (§19).
pub(all) struct CT_OutlineViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OutlineViewProperties::new(
  element : @xml.Element,
) -> CT_OutlineViewProperties {
  { element, }
}

///|
pub fn CT_OutlineViewProperties::parse(
  element : @xml.Element,
) -> CT_OutlineViewProperties {
  CT_OutlineViewProperties::new(element)
}

///|
pub fn CT_OutlineViewProperties::to_element(
  self : CT_OutlineViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideSorterViewProperties from pml.xsd (§19).
pub(all) struct CT_SlideSorterViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideSorterViewProperties::new(
  element : @xml.Element,
) -> CT_SlideSorterViewProperties {
  { element, }
}

///|
pub fn CT_SlideSorterViewProperties::parse(
  element : @xml.Element,
) -> CT_SlideSorterViewProperties {
  CT_SlideSorterViewProperties::new(element)
}

///|
pub fn CT_SlideSorterViewProperties::to_element(
  self : CT_SlideSorterViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Guide from pml.xsd (§19).
pub(all) struct CT_Guide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Guide::new(element : @xml.Element) -> CT_Guide {
  { element, }
}

///|
pub fn CT_Guide::parse(element : @xml.Element) -> CT_Guide {
  CT_Guide::new(element)
}

///|
pub fn CT_Guide::to_element(self : CT_Guide) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GuideList from pml.xsd (§19).
pub(all) struct CT_GuideList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GuideList::new(element : @xml.Element) -> CT_GuideList {
  { element, }
}

///|
pub fn CT_GuideList::parse(element : @xml.Element) -> CT_GuideList {
  CT_GuideList::new(element)
}

///|
pub fn CT_GuideList::to_element(self : CT_GuideList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CommonSlideViewProperties from pml.xsd (§19).
pub(all) struct CT_CommonSlideViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CommonSlideViewProperties::new(
  element : @xml.Element,
) -> CT_CommonSlideViewProperties {
  { element, }
}

///|
pub fn CT_CommonSlideViewProperties::parse(
  element : @xml.Element,
) -> CT_CommonSlideViewProperties {
  CT_CommonSlideViewProperties::new(element)
}

///|
pub fn CT_CommonSlideViewProperties::to_element(
  self : CT_CommonSlideViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SlideViewProperties from pml.xsd (§19).
pub(all) struct CT_SlideViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SlideViewProperties::new(
  element : @xml.Element,
) -> CT_SlideViewProperties {
  { element, }
}

///|
pub fn CT_SlideViewProperties::parse(
  element : @xml.Element,
) -> CT_SlideViewProperties {
  CT_SlideViewProperties::new(element)
}

///|
pub fn CT_SlideViewProperties::to_element(
  self : CT_SlideViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NotesViewProperties from pml.xsd (§19).
pub(all) struct CT_NotesViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NotesViewProperties::new(
  element : @xml.Element,
) -> CT_NotesViewProperties {
  { element, }
}

///|
pub fn CT_NotesViewProperties::parse(
  element : @xml.Element,
) -> CT_NotesViewProperties {
  CT_NotesViewProperties::new(element)
}

///|
pub fn CT_NotesViewProperties::to_element(
  self : CT_NotesViewProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ViewProperties from pml.xsd (§19).
pub(all) struct CT_ViewProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ViewProperties::new(element : @xml.Element) -> CT_ViewProperties {
  { element, }
}

///|
pub fn CT_ViewProperties::parse(element : @xml.Element) -> CT_ViewProperties {
  CT_ViewProperties::new(element)
}

///|
pub fn CT_ViewProperties::to_element(self : CT_ViewProperties) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WebProperties from pml.xsd (Part 4 §16).
pub(all) struct CT_WebProperties {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_WebProperties::new(element : @xml.Element) -> CT_WebProperties {
  { element, }
}

///|
pub fn CT_WebProperties::parse(element : @xml.Element) -> CT_WebProperties {
  CT_WebProperties::new(element)
}

///|
pub fn CT_WebProperties::to_element(self : CT_WebProperties) -> @xml.Element {
  self.element
}

///|
/// XSD attribute group AG_TLBuild from pml.xsd (§19).
pub(all) struct AG_TLBuild {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_TLBuild::new(element : @xml.Element) -> AG_TLBuild {
  { element, }
}

///|
pub fn AG_TLBuild::attribute_names(self : AG_TLBuild) -> Array[String] {
  let names = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_TLBuild::has_attribute(
  self : AG_TLBuild,
  local_name : String,
) -> Bool {
  let mut found = false
  for attribute in self.element.attributes {
    if attribute.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// XSD attribute group AG_Ole from pml.xsd (§19).
pub(all) struct AG_Ole {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Ole::new(element : @xml.Element) -> AG_Ole {
  { element, }
}

///|
pub fn AG_Ole::attribute_names(self : AG_Ole) -> Array[String] {
  let names = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_Ole::has_attribute(self : AG_Ole, local_name : String) -> Bool {
  let mut found = false
  for attribute in self.element.attributes {
    if attribute.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// XSD attribute group AG_ChildSlide from pml.xsd (§19).
pub(all) struct AG_ChildSlide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_ChildSlide::new(element : @xml.Element) -> AG_ChildSlide {
  { element, }
}

///|
pub fn AG_ChildSlide::attribute_names(self : AG_ChildSlide) -> Array[String] {
  let names = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_ChildSlide::has_attribute(
  self : AG_ChildSlide,
  local_name : String,
) -> Bool {
  let mut found = false
  for attribute in self.element.attributes {
    if attribute.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// XSD model group EG_SlideListChoice from pml.xsd (§19).
pub(all) struct EG_SlideListChoice {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_SlideListChoice::new(element : @xml.Element) -> EG_SlideListChoice {
  { element, }
}

///|
pub fn EG_SlideListChoice::child_names(
  self : EG_SlideListChoice,
) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_ExtensionList from pml.xsd (§19).
pub(all) struct EG_ExtensionList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ExtensionList::new(element : @xml.Element) -> EG_ExtensionList {
  { element, }
}

///|
pub fn EG_ExtensionList::child_names(self : EG_ExtensionList) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_ShowType from pml.xsd (§19).
pub(all) struct EG_ShowType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ShowType::new(element : @xml.Element) -> EG_ShowType {
  { element, }
}

///|
pub fn EG_ShowType::child_names(self : EG_ShowType) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_TopLevelSlide from pml.xsd (§19).
pub(all) struct EG_TopLevelSlide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_TopLevelSlide::new(element : @xml.Element) -> EG_TopLevelSlide {
  { element, }
}

///|
pub fn EG_TopLevelSlide::child_names(self : EG_TopLevelSlide) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_ChildSlide from pml.xsd (§19).
pub(all) struct EG_ChildSlide {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ChildSlide::new(element : @xml.Element) -> EG_ChildSlide {
  { element, }
}

///|
pub fn EG_ChildSlide::child_names(self : EG_ChildSlide) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// XSD model group EG_Background from pml.xsd (§19).
pub(all) struct EG_Background {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_Background::new(element : @xml.Element) -> EG_Background {
  { element, }
}

///|
pub fn EG_Background::child_names(self : EG_Background) -> Array[String] {
  let names = []
  for child in self.element.children {
    match child {
      Element(element) => names.push(element.name.local_name)
      _ => ()
    }
  }
  names
}

///|
/// Construct top-level pml.xsd element cmAuthorLst as CT_CommentAuthorList (§19).
pub fn cm_author_lst(element : @xml.Element) -> CT_CommentAuthorList {
  CT_CommentAuthorList::new(element)
}

///|
/// Construct top-level pml.xsd element cmLst as CT_CommentList (§19).
pub fn cm_lst(element : @xml.Element) -> CT_CommentList {
  CT_CommentList::new(element)
}

///|
/// Construct top-level pml.xsd element oleObj as CT_OleObject (§19).
pub fn ole_obj(element : @xml.Element) -> CT_OleObject {
  CT_OleObject::new(element)
}

///|
/// Construct top-level pml.xsd element presentation as CT_Presentation (§19).
pub fn presentation(element : @xml.Element) -> CT_Presentation {
  CT_Presentation::new(element)
}

///|
/// Construct top-level pml.xsd element presentationPr as CT_PresentationProperties (§19).
pub fn presentation_pr(element : @xml.Element) -> CT_PresentationProperties {
  CT_PresentationProperties::new(element)
}

///|
/// Construct top-level pml.xsd element sld as CT_Slide (§19).
pub fn sld(element : @xml.Element) -> CT_Slide {
  CT_Slide::new(element)
}

///|
/// Construct top-level pml.xsd element sldLayout as CT_SlideLayout (§19).
pub fn sld_layout(element : @xml.Element) -> CT_SlideLayout {
  CT_SlideLayout::new(element)
}

///|
/// Construct top-level pml.xsd element sldMaster as CT_SlideMaster (§19).
pub fn sld_master(element : @xml.Element) -> CT_SlideMaster {
  CT_SlideMaster::new(element)
}

///|
/// Construct top-level pml.xsd element handoutMaster as CT_HandoutMaster (§19).
pub fn handout_master(element : @xml.Element) -> CT_HandoutMaster {
  CT_HandoutMaster::new(element)
}

///|
/// Construct top-level pml.xsd element notesMaster as CT_NotesMaster (§19).
pub fn notes_master(element : @xml.Element) -> CT_NotesMaster {
  CT_NotesMaster::new(element)
}

///|
/// Construct top-level pml.xsd element notes as CT_NotesSlide (§19).
pub fn notes(element : @xml.Element) -> CT_NotesSlide {
  CT_NotesSlide::new(element)
}

///|
/// Construct top-level pml.xsd element sldSyncPr as CT_SlideSyncProperties (§19).
pub fn sld_sync_pr(element : @xml.Element) -> CT_SlideSyncProperties {
  CT_SlideSyncProperties::new(element)
}

///|
/// Construct top-level pml.xsd element tagLst as CT_TagList (§19).
pub fn tag_lst(element : @xml.Element) -> CT_TagList {
  CT_TagList::new(element)
}

///|
/// Construct top-level pml.xsd element viewPr as CT_ViewProperties (§19).
pub fn view_pr(element : @xml.Element) -> CT_ViewProperties {
  CT_ViewProperties::new(element)
}
