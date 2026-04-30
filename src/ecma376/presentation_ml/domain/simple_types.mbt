///|
/// Schema validation error for PresentationML simple types (§19).
pub suberror SchemaViolation {
  SchemaViolation(type_name~ : String, value~ : String, reason~ : String)
} derive(Debug)

///|
pub fn raise_schema_violation(
  type_name : String,
  value : String,
  reason : String,
) -> Unit raise SchemaViolation {
  raise SchemaViolation(type_name~, value~, reason~)
}

///|
fn[T] invalid_simple_type(
  type_name : String,
  value : String,
  reason : String,
) -> T raise SchemaViolation {
  raise SchemaViolation(type_name~, value~, reason~)
}

///|
fn validate_pml_simple_type(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    invalid_simple_type(type_name, value, "empty lexical value")
  }
  let allowed = pml_simple_type_values(type_name)
  if allowed.length() > 0 && !allowed.contains(";" + value + ";") {
    invalid_simple_type(type_name, value, "unknown enumeration value")
  }
}

///|
fn pml_simple_type_values(type_name : String) -> String {
  match type_name {
    "ST_TransitionSideDirectionType" => ";l;u;r;d;"
    "ST_TransitionCornerDirectionType" => ";lu;ru;ld;rd;"
    "ST_TransitionInOutDirectionType" => ";out;in;"
    "ST_TransitionSpeed" => ";slow;med;fast;"
    "ST_TLTimeIndefinite" => ";indefinite;"
    "ST_IterateType" => ";el;wd;lt;"
    "ST_TLChartSubelementType" =>
      ";gridLegend;series;category;ptInSeries;ptInCategory;"
    "ST_TLTriggerRuntimeNode" => ";first;last;all;"
    "ST_TLTriggerEvent" =>
      ";onBegin;onEnd;begin;end;onClick;onDblClick;onMouseOver;onMouseOut;onNext;onPrev;onStopAudio;"
    "ST_TLTimeNodePresetClassType" => ";entr;exit;emph;path;verb;mediacall;"
    "ST_TLTimeNodeRestartType" => ";always;whenNotActive;never;"
    "ST_TLTimeNodeFillType" => ";remove;freeze;hold;transition;"
    "ST_TLTimeNodeSyncType" => ";canSlip;locked;"
    "ST_TLTimeNodeMasterRelation" => ";sameClick;lastClick;nextClick;"
    "ST_TLTimeNodeType" =>
      ";clickEffect;withEffect;afterEffect;mainSeq;interactiveSeq;clickPar;withGroup;afterGroup;tmRoot;"
    "ST_TLNextActionType" => ";none;seek;"
    "ST_TLPreviousActionType" => ";none;skipTimed;"
    "ST_TLBehaviorAdditiveType" => ";base;sum;repl;mult;none;"
    "ST_TLBehaviorAccumulateType" => ";none;always;"
    "ST_TLBehaviorTransformType" => ";pt;img;"
    "ST_TLBehaviorOverrideType" => ";normal;childStyle;"
    "ST_TLAnimateBehaviorCalcMode" => ";discrete;lin;fmla;"
    "ST_TLAnimateBehaviorValueType" => ";str;num;clr;"
    "ST_TLAnimateColorSpace" => ";rgb;hsl;"
    "ST_TLAnimateColorDirection" => ";cw;ccw;"
    "ST_TLAnimateEffectTransition" => ";in;out;none;"
    "ST_TLAnimateMotionBehaviorOrigin" => ";parent;layout;"
    "ST_TLAnimateMotionPathEditMode" => ";relative;fixed;"
    "ST_TLCommandType" => ";evt;call;verb;"
    "ST_TLParaBuildType" => ";allAtOnce;p;cust;whole;"
    "ST_TLDiagramBuildType" =>
      ";whole;depthByNode;depthByBranch;breadthByNode;breadthByLvl;cw;cwIn;cwOut;ccw;ccwIn;ccwOut;inByRing;outByRing;up;down;allAtOnce;cust;"
    "ST_TLOleChartBuildType" =>
      ";allAtOnce;series;category;seriesEl;categoryEl;"
    "ST_Direction" => ";horz;vert;"
    "ST_OleObjectFollowColorScheme" => ";none;full;textAndBackground;"
    "ST_PhotoAlbumLayout" =>
      ";fitToSlide;1pic;2pic;4pic;1picTitle;2picTitle;4picTitle;"
    "ST_PhotoAlbumFrameShape" =>
      ";frameStyle1;frameStyle2;frameStyle3;frameStyle4;frameStyle5;frameStyle6;frameStyle7;"
    "ST_SlideSizeType" =>
      ";screen4x3;letter;A4;35mm;overhead;banner;custom;ledger;A3;B4ISO;B5ISO;B4JIS;B5JIS;hagakiCard;screen16x9;screen16x10;"
    "ST_PrintWhat" =>
      ";slides;handouts1;handouts2;handouts3;handouts4;handouts6;handouts9;notes;outline;"
    "ST_PrintColorMode" => ";bw;gray;clr;"
    "ST_PlaceholderType" =>
      ";title;body;ctrTitle;subTitle;dt;sldNum;ftr;hdr;obj;chart;tbl;clipArt;dgm;media;sldImg;pic;"
    "ST_PlaceholderSize" => ";full;half;quarter;"
    "ST_SlideLayoutType" =>
      ";title;tx;twoColTx;tbl;txAndChart;chartAndTx;dgm;chart;txAndClipArt;clipArtAndTx;titleOnly;blank;txAndObj;objAndTx;objOnly;obj;txAndMedia;mediaAndTx;objOverTx;txOverObj;txAndTwoObj;twoObjAndTx;twoObjOverTx;fourObj;vertTx;clipArtAndVertTx;vertTitleAndTx;vertTitleAndTxOverChart;twoObj;objAndTwoObj;twoObjAndObj;cust;secHead;twoTxTwoObj;objTx;picTx;"
    "ST_SplitterBarState" => ";minimized;restored;maximized;"
    "ST_ViewType" =>
      ";sldView;sldMasterView;notesView;handoutView;notesMasterView;outlineView;sldSorterView;sldThumbnailView;"
    "ST_WebColorType" =>
      ";none;browser;presentationText;presentationAccent;whiteTextOnBlack;blackTextOnWhite;"
    "ST_WebScreenSize" =>
      ";544x376;640x480;720x512;800x600;1024x768;1152x882;1152x900;1280x1024;1600x1200;1800x1400;1920x1200;"
    _ => ""
  }
}

///|
/// XSD simple type ST_TransitionSideDirectionType from pml.xsd (§19).
pub struct ST_TransitionSideDirectionType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TransitionSideDirectionType::parse(
  s : String,
) -> ST_TransitionSideDirectionType raise SchemaViolation {
  validate_pml_simple_type("ST_TransitionSideDirectionType", s)
  { value: s }
}

///|
pub fn ST_TransitionSideDirectionType::new(
  s : String,
) -> ST_TransitionSideDirectionType raise SchemaViolation {
  ST_TransitionSideDirectionType::parse(s)
}

///|
pub fn ST_TransitionSideDirectionType::to_string(
  self : ST_TransitionSideDirectionType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TransitionCornerDirectionType from pml.xsd (§19).
pub struct ST_TransitionCornerDirectionType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TransitionCornerDirectionType::parse(
  s : String,
) -> ST_TransitionCornerDirectionType raise SchemaViolation {
  validate_pml_simple_type("ST_TransitionCornerDirectionType", s)
  { value: s }
}

///|
pub fn ST_TransitionCornerDirectionType::new(
  s : String,
) -> ST_TransitionCornerDirectionType raise SchemaViolation {
  ST_TransitionCornerDirectionType::parse(s)
}

///|
pub fn ST_TransitionCornerDirectionType::to_string(
  self : ST_TransitionCornerDirectionType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TransitionInOutDirectionType from pml.xsd (§19).
pub struct ST_TransitionInOutDirectionType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TransitionInOutDirectionType::parse(
  s : String,
) -> ST_TransitionInOutDirectionType raise SchemaViolation {
  validate_pml_simple_type("ST_TransitionInOutDirectionType", s)
  { value: s }
}

///|
pub fn ST_TransitionInOutDirectionType::new(
  s : String,
) -> ST_TransitionInOutDirectionType raise SchemaViolation {
  ST_TransitionInOutDirectionType::parse(s)
}

///|
pub fn ST_TransitionInOutDirectionType::to_string(
  self : ST_TransitionInOutDirectionType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TransitionEightDirectionType from pml.xsd (§19).
pub struct ST_TransitionEightDirectionType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TransitionEightDirectionType::parse(
  s : String,
) -> ST_TransitionEightDirectionType raise SchemaViolation {
  validate_pml_simple_type("ST_TransitionEightDirectionType", s)
  { value: s }
}

///|
pub fn ST_TransitionEightDirectionType::new(
  s : String,
) -> ST_TransitionEightDirectionType raise SchemaViolation {
  ST_TransitionEightDirectionType::parse(s)
}

///|
pub fn ST_TransitionEightDirectionType::to_string(
  self : ST_TransitionEightDirectionType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TransitionSpeed from pml.xsd (§19).
pub struct ST_TransitionSpeed {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TransitionSpeed::parse(
  s : String,
) -> ST_TransitionSpeed raise SchemaViolation {
  validate_pml_simple_type("ST_TransitionSpeed", s)
  { value: s }
}

///|
pub fn ST_TransitionSpeed::new(
  s : String,
) -> ST_TransitionSpeed raise SchemaViolation {
  ST_TransitionSpeed::parse(s)
}

///|
pub fn ST_TransitionSpeed::to_string(self : ST_TransitionSpeed) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTimeIndefinite from pml.xsd (§19).
pub struct ST_TLTimeIndefinite {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTimeIndefinite::parse(
  s : String,
) -> ST_TLTimeIndefinite raise SchemaViolation {
  validate_pml_simple_type("ST_TLTimeIndefinite", s)
  { value: s }
}

///|
pub fn ST_TLTimeIndefinite::new(
  s : String,
) -> ST_TLTimeIndefinite raise SchemaViolation {
  ST_TLTimeIndefinite::parse(s)
}

///|
pub fn ST_TLTimeIndefinite::to_string(self : ST_TLTimeIndefinite) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTime from pml.xsd (§19).
pub struct ST_TLTime {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTime::parse(s : String) -> ST_TLTime raise SchemaViolation {
  validate_pml_simple_type("ST_TLTime", s)
  { value: s }
}

///|
pub fn ST_TLTime::new(s : String) -> ST_TLTime raise SchemaViolation {
  ST_TLTime::parse(s)
}

///|
pub fn ST_TLTime::to_string(self : ST_TLTime) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTimeNodeID from pml.xsd (§19).
pub struct ST_TLTimeNodeID {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeID::parse(
  s : String,
) -> ST_TLTimeNodeID raise SchemaViolation {
  validate_pml_simple_type("ST_TLTimeNodeID", s)
  { value: s }
}

///|
pub fn ST_TLTimeNodeID::new(
  s : String,
) -> ST_TLTimeNodeID raise SchemaViolation {
  ST_TLTimeNodeID::parse(s)
}

///|
pub fn ST_TLTimeNodeID::to_string(self : ST_TLTimeNodeID) -> String {
  self.value
}

///|
/// XSD simple type ST_IterateType from pml.xsd (§19).
pub struct ST_IterateType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_IterateType::parse(
  s : String,
) -> ST_IterateType raise SchemaViolation {
  validate_pml_simple_type("ST_IterateType", s)
  { value: s }
}

///|
pub fn ST_IterateType::new(s : String) -> ST_IterateType raise SchemaViolation {
  ST_IterateType::parse(s)
}

///|
pub fn ST_IterateType::to_string(self : ST_IterateType) -> String {
  self.value
}

///|
/// XSD simple type ST_TLChartSubelementType from pml.xsd (§19).
pub struct ST_TLChartSubelementType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLChartSubelementType::parse(
  s : String,
) -> ST_TLChartSubelementType raise SchemaViolation {
  validate_pml_simple_type("ST_TLChartSubelementType", s)
  { value: s }
}

///|
pub fn ST_TLChartSubelementType::new(
  s : String,
) -> ST_TLChartSubelementType raise SchemaViolation {
  ST_TLChartSubelementType::parse(s)
}

///|
pub fn ST_TLChartSubelementType::to_string(
  self : ST_TLChartSubelementType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTriggerRuntimeNode from pml.xsd (§19).
pub struct ST_TLTriggerRuntimeNode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTriggerRuntimeNode::parse(
  s : String,
) -> ST_TLTriggerRuntimeNode raise SchemaViolation {
  validate_pml_simple_type("ST_TLTriggerRuntimeNode", s)
  { value: s }
}

///|
pub fn ST_TLTriggerRuntimeNode::new(
  s : String,
) -> ST_TLTriggerRuntimeNode raise SchemaViolation {
  ST_TLTriggerRuntimeNode::parse(s)
}

///|
pub fn ST_TLTriggerRuntimeNode::to_string(
  self : ST_TLTriggerRuntimeNode,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTriggerEvent from pml.xsd (§19).
pub struct ST_TLTriggerEvent {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTriggerEvent::parse(
  s : String,
) -> ST_TLTriggerEvent raise SchemaViolation {
  validate_pml_simple_type("ST_TLTriggerEvent", s)
  { value: s }
}

///|
pub fn ST_TLTriggerEvent::new(
  s : String,
) -> ST_TLTriggerEvent raise SchemaViolation {
  ST_TLTriggerEvent::parse(s)
}

///|
pub fn ST_TLTriggerEvent::to_string(self : ST_TLTriggerEvent) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTimeNodePresetClassType from pml.xsd (§19).
pub struct ST_TLTimeNodePresetClassType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodePresetClassType::parse(
  s : String,
) -> ST_TLTimeNodePresetClassType raise SchemaViolation {
  validate_pml_simple_type("ST_TLTimeNodePresetClassType", s)
  { value: s }
}

///|
pub fn ST_TLTimeNodePresetClassType::new(
  s : String,
) -> ST_TLTimeNodePresetClassType raise SchemaViolation {
  ST_TLTimeNodePresetClassType::parse(s)
}

///|
pub fn ST_TLTimeNodePresetClassType::to_string(
  self : ST_TLTimeNodePresetClassType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTimeNodeRestartType from pml.xsd (§19).
pub struct ST_TLTimeNodeRestartType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeRestartType::parse(
  s : String,
) -> ST_TLTimeNodeRestartType raise SchemaViolation {
  validate_pml_simple_type("ST_TLTimeNodeRestartType", s)
  { value: s }
}

///|
pub fn ST_TLTimeNodeRestartType::new(
  s : String,
) -> ST_TLTimeNodeRestartType raise SchemaViolation {
  ST_TLTimeNodeRestartType::parse(s)
}

///|
pub fn ST_TLTimeNodeRestartType::to_string(
  self : ST_TLTimeNodeRestartType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTimeNodeFillType from pml.xsd (§19).
pub struct ST_TLTimeNodeFillType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeFillType::parse(
  s : String,
) -> ST_TLTimeNodeFillType raise SchemaViolation {
  validate_pml_simple_type("ST_TLTimeNodeFillType", s)
  { value: s }
}

///|
pub fn ST_TLTimeNodeFillType::new(
  s : String,
) -> ST_TLTimeNodeFillType raise SchemaViolation {
  ST_TLTimeNodeFillType::parse(s)
}

///|
pub fn ST_TLTimeNodeFillType::to_string(self : ST_TLTimeNodeFillType) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTimeNodeSyncType from pml.xsd (§19).
pub struct ST_TLTimeNodeSyncType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeSyncType::parse(
  s : String,
) -> ST_TLTimeNodeSyncType raise SchemaViolation {
  validate_pml_simple_type("ST_TLTimeNodeSyncType", s)
  { value: s }
}

///|
pub fn ST_TLTimeNodeSyncType::new(
  s : String,
) -> ST_TLTimeNodeSyncType raise SchemaViolation {
  ST_TLTimeNodeSyncType::parse(s)
}

///|
pub fn ST_TLTimeNodeSyncType::to_string(self : ST_TLTimeNodeSyncType) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTimeNodeMasterRelation from pml.xsd (§19).
pub struct ST_TLTimeNodeMasterRelation {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeMasterRelation::parse(
  s : String,
) -> ST_TLTimeNodeMasterRelation raise SchemaViolation {
  validate_pml_simple_type("ST_TLTimeNodeMasterRelation", s)
  { value: s }
}

///|
pub fn ST_TLTimeNodeMasterRelation::new(
  s : String,
) -> ST_TLTimeNodeMasterRelation raise SchemaViolation {
  ST_TLTimeNodeMasterRelation::parse(s)
}

///|
pub fn ST_TLTimeNodeMasterRelation::to_string(
  self : ST_TLTimeNodeMasterRelation,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTimeNodeType from pml.xsd (§19).
pub struct ST_TLTimeNodeType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeType::parse(
  s : String,
) -> ST_TLTimeNodeType raise SchemaViolation {
  validate_pml_simple_type("ST_TLTimeNodeType", s)
  { value: s }
}

///|
pub fn ST_TLTimeNodeType::new(
  s : String,
) -> ST_TLTimeNodeType raise SchemaViolation {
  ST_TLTimeNodeType::parse(s)
}

///|
pub fn ST_TLTimeNodeType::to_string(self : ST_TLTimeNodeType) -> String {
  self.value
}

///|
/// XSD simple type ST_TLNextActionType from pml.xsd (§19).
pub struct ST_TLNextActionType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLNextActionType::parse(
  s : String,
) -> ST_TLNextActionType raise SchemaViolation {
  validate_pml_simple_type("ST_TLNextActionType", s)
  { value: s }
}

///|
pub fn ST_TLNextActionType::new(
  s : String,
) -> ST_TLNextActionType raise SchemaViolation {
  ST_TLNextActionType::parse(s)
}

///|
pub fn ST_TLNextActionType::to_string(self : ST_TLNextActionType) -> String {
  self.value
}

///|
/// XSD simple type ST_TLPreviousActionType from pml.xsd (§19).
pub struct ST_TLPreviousActionType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLPreviousActionType::parse(
  s : String,
) -> ST_TLPreviousActionType raise SchemaViolation {
  validate_pml_simple_type("ST_TLPreviousActionType", s)
  { value: s }
}

///|
pub fn ST_TLPreviousActionType::new(
  s : String,
) -> ST_TLPreviousActionType raise SchemaViolation {
  ST_TLPreviousActionType::parse(s)
}

///|
pub fn ST_TLPreviousActionType::to_string(
  self : ST_TLPreviousActionType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLBehaviorAdditiveType from pml.xsd (§19).
pub struct ST_TLBehaviorAdditiveType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLBehaviorAdditiveType::parse(
  s : String,
) -> ST_TLBehaviorAdditiveType raise SchemaViolation {
  validate_pml_simple_type("ST_TLBehaviorAdditiveType", s)
  { value: s }
}

///|
pub fn ST_TLBehaviorAdditiveType::new(
  s : String,
) -> ST_TLBehaviorAdditiveType raise SchemaViolation {
  ST_TLBehaviorAdditiveType::parse(s)
}

///|
pub fn ST_TLBehaviorAdditiveType::to_string(
  self : ST_TLBehaviorAdditiveType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLBehaviorAccumulateType from pml.xsd (§19).
pub struct ST_TLBehaviorAccumulateType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLBehaviorAccumulateType::parse(
  s : String,
) -> ST_TLBehaviorAccumulateType raise SchemaViolation {
  validate_pml_simple_type("ST_TLBehaviorAccumulateType", s)
  { value: s }
}

///|
pub fn ST_TLBehaviorAccumulateType::new(
  s : String,
) -> ST_TLBehaviorAccumulateType raise SchemaViolation {
  ST_TLBehaviorAccumulateType::parse(s)
}

///|
pub fn ST_TLBehaviorAccumulateType::to_string(
  self : ST_TLBehaviorAccumulateType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLBehaviorTransformType from pml.xsd (§19).
pub struct ST_TLBehaviorTransformType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLBehaviorTransformType::parse(
  s : String,
) -> ST_TLBehaviorTransformType raise SchemaViolation {
  validate_pml_simple_type("ST_TLBehaviorTransformType", s)
  { value: s }
}

///|
pub fn ST_TLBehaviorTransformType::new(
  s : String,
) -> ST_TLBehaviorTransformType raise SchemaViolation {
  ST_TLBehaviorTransformType::parse(s)
}

///|
pub fn ST_TLBehaviorTransformType::to_string(
  self : ST_TLBehaviorTransformType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLBehaviorOverrideType from pml.xsd (§19).
pub struct ST_TLBehaviorOverrideType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLBehaviorOverrideType::parse(
  s : String,
) -> ST_TLBehaviorOverrideType raise SchemaViolation {
  validate_pml_simple_type("ST_TLBehaviorOverrideType", s)
  { value: s }
}

///|
pub fn ST_TLBehaviorOverrideType::new(
  s : String,
) -> ST_TLBehaviorOverrideType raise SchemaViolation {
  ST_TLBehaviorOverrideType::parse(s)
}

///|
pub fn ST_TLBehaviorOverrideType::to_string(
  self : ST_TLBehaviorOverrideType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLTimeAnimateValueTime from pml.xsd (§19).
pub struct ST_TLTimeAnimateValueTime {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLTimeAnimateValueTime::parse(
  s : String,
) -> ST_TLTimeAnimateValueTime raise SchemaViolation {
  validate_pml_simple_type("ST_TLTimeAnimateValueTime", s)
  { value: s }
}

///|
pub fn ST_TLTimeAnimateValueTime::new(
  s : String,
) -> ST_TLTimeAnimateValueTime raise SchemaViolation {
  ST_TLTimeAnimateValueTime::parse(s)
}

///|
pub fn ST_TLTimeAnimateValueTime::to_string(
  self : ST_TLTimeAnimateValueTime,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLAnimateBehaviorCalcMode from pml.xsd (§19).
pub struct ST_TLAnimateBehaviorCalcMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateBehaviorCalcMode::parse(
  s : String,
) -> ST_TLAnimateBehaviorCalcMode raise SchemaViolation {
  validate_pml_simple_type("ST_TLAnimateBehaviorCalcMode", s)
  { value: s }
}

///|
pub fn ST_TLAnimateBehaviorCalcMode::new(
  s : String,
) -> ST_TLAnimateBehaviorCalcMode raise SchemaViolation {
  ST_TLAnimateBehaviorCalcMode::parse(s)
}

///|
pub fn ST_TLAnimateBehaviorCalcMode::to_string(
  self : ST_TLAnimateBehaviorCalcMode,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLAnimateBehaviorValueType from pml.xsd (§19).
pub struct ST_TLAnimateBehaviorValueType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateBehaviorValueType::parse(
  s : String,
) -> ST_TLAnimateBehaviorValueType raise SchemaViolation {
  validate_pml_simple_type("ST_TLAnimateBehaviorValueType", s)
  { value: s }
}

///|
pub fn ST_TLAnimateBehaviorValueType::new(
  s : String,
) -> ST_TLAnimateBehaviorValueType raise SchemaViolation {
  ST_TLAnimateBehaviorValueType::parse(s)
}

///|
pub fn ST_TLAnimateBehaviorValueType::to_string(
  self : ST_TLAnimateBehaviorValueType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLAnimateColorSpace from pml.xsd (§19).
pub struct ST_TLAnimateColorSpace {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateColorSpace::parse(
  s : String,
) -> ST_TLAnimateColorSpace raise SchemaViolation {
  validate_pml_simple_type("ST_TLAnimateColorSpace", s)
  { value: s }
}

///|
pub fn ST_TLAnimateColorSpace::new(
  s : String,
) -> ST_TLAnimateColorSpace raise SchemaViolation {
  ST_TLAnimateColorSpace::parse(s)
}

///|
pub fn ST_TLAnimateColorSpace::to_string(
  self : ST_TLAnimateColorSpace,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLAnimateColorDirection from pml.xsd (§19).
pub struct ST_TLAnimateColorDirection {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateColorDirection::parse(
  s : String,
) -> ST_TLAnimateColorDirection raise SchemaViolation {
  validate_pml_simple_type("ST_TLAnimateColorDirection", s)
  { value: s }
}

///|
pub fn ST_TLAnimateColorDirection::new(
  s : String,
) -> ST_TLAnimateColorDirection raise SchemaViolation {
  ST_TLAnimateColorDirection::parse(s)
}

///|
pub fn ST_TLAnimateColorDirection::to_string(
  self : ST_TLAnimateColorDirection,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLAnimateEffectTransition from pml.xsd (§19).
pub struct ST_TLAnimateEffectTransition {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateEffectTransition::parse(
  s : String,
) -> ST_TLAnimateEffectTransition raise SchemaViolation {
  validate_pml_simple_type("ST_TLAnimateEffectTransition", s)
  { value: s }
}

///|
pub fn ST_TLAnimateEffectTransition::new(
  s : String,
) -> ST_TLAnimateEffectTransition raise SchemaViolation {
  ST_TLAnimateEffectTransition::parse(s)
}

///|
pub fn ST_TLAnimateEffectTransition::to_string(
  self : ST_TLAnimateEffectTransition,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLAnimateMotionBehaviorOrigin from pml.xsd (§19).
pub struct ST_TLAnimateMotionBehaviorOrigin {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateMotionBehaviorOrigin::parse(
  s : String,
) -> ST_TLAnimateMotionBehaviorOrigin raise SchemaViolation {
  validate_pml_simple_type("ST_TLAnimateMotionBehaviorOrigin", s)
  { value: s }
}

///|
pub fn ST_TLAnimateMotionBehaviorOrigin::new(
  s : String,
) -> ST_TLAnimateMotionBehaviorOrigin raise SchemaViolation {
  ST_TLAnimateMotionBehaviorOrigin::parse(s)
}

///|
pub fn ST_TLAnimateMotionBehaviorOrigin::to_string(
  self : ST_TLAnimateMotionBehaviorOrigin,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLAnimateMotionPathEditMode from pml.xsd (§19).
pub struct ST_TLAnimateMotionPathEditMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateMotionPathEditMode::parse(
  s : String,
) -> ST_TLAnimateMotionPathEditMode raise SchemaViolation {
  validate_pml_simple_type("ST_TLAnimateMotionPathEditMode", s)
  { value: s }
}

///|
pub fn ST_TLAnimateMotionPathEditMode::new(
  s : String,
) -> ST_TLAnimateMotionPathEditMode raise SchemaViolation {
  ST_TLAnimateMotionPathEditMode::parse(s)
}

///|
pub fn ST_TLAnimateMotionPathEditMode::to_string(
  self : ST_TLAnimateMotionPathEditMode,
) -> String {
  self.value
}

///|
/// XSD simple type ST_TLCommandType from pml.xsd (§19).
pub struct ST_TLCommandType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLCommandType::parse(
  s : String,
) -> ST_TLCommandType raise SchemaViolation {
  validate_pml_simple_type("ST_TLCommandType", s)
  { value: s }
}

///|
pub fn ST_TLCommandType::new(
  s : String,
) -> ST_TLCommandType raise SchemaViolation {
  ST_TLCommandType::parse(s)
}

///|
pub fn ST_TLCommandType::to_string(self : ST_TLCommandType) -> String {
  self.value
}

///|
/// XSD simple type ST_TLParaBuildType from pml.xsd (§19).
pub struct ST_TLParaBuildType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLParaBuildType::parse(
  s : String,
) -> ST_TLParaBuildType raise SchemaViolation {
  validate_pml_simple_type("ST_TLParaBuildType", s)
  { value: s }
}

///|
pub fn ST_TLParaBuildType::new(
  s : String,
) -> ST_TLParaBuildType raise SchemaViolation {
  ST_TLParaBuildType::parse(s)
}

///|
pub fn ST_TLParaBuildType::to_string(self : ST_TLParaBuildType) -> String {
  self.value
}

///|
/// XSD simple type ST_TLDiagramBuildType from pml.xsd (§19).
pub struct ST_TLDiagramBuildType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLDiagramBuildType::parse(
  s : String,
) -> ST_TLDiagramBuildType raise SchemaViolation {
  validate_pml_simple_type("ST_TLDiagramBuildType", s)
  { value: s }
}

///|
pub fn ST_TLDiagramBuildType::new(
  s : String,
) -> ST_TLDiagramBuildType raise SchemaViolation {
  ST_TLDiagramBuildType::parse(s)
}

///|
pub fn ST_TLDiagramBuildType::to_string(self : ST_TLDiagramBuildType) -> String {
  self.value
}

///|
/// XSD simple type ST_TLOleChartBuildType from pml.xsd (§19).
pub struct ST_TLOleChartBuildType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TLOleChartBuildType::parse(
  s : String,
) -> ST_TLOleChartBuildType raise SchemaViolation {
  validate_pml_simple_type("ST_TLOleChartBuildType", s)
  { value: s }
}

///|
pub fn ST_TLOleChartBuildType::new(
  s : String,
) -> ST_TLOleChartBuildType raise SchemaViolation {
  ST_TLOleChartBuildType::parse(s)
}

///|
pub fn ST_TLOleChartBuildType::to_string(
  self : ST_TLOleChartBuildType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_Name from pml.xsd (§19).
pub struct ST_Name {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Name::parse(s : String) -> ST_Name raise SchemaViolation {
  validate_pml_simple_type("ST_Name", s)
  { value: s }
}

///|
pub fn ST_Name::new(s : String) -> ST_Name raise SchemaViolation {
  ST_Name::parse(s)
}

///|
pub fn ST_Name::to_string(self : ST_Name) -> String {
  self.value
}

///|
/// XSD simple type ST_Direction from pml.xsd (§19).
pub struct ST_Direction {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Direction::parse(s : String) -> ST_Direction raise SchemaViolation {
  validate_pml_simple_type("ST_Direction", s)
  { value: s }
}

///|
pub fn ST_Direction::new(s : String) -> ST_Direction raise SchemaViolation {
  ST_Direction::parse(s)
}

///|
pub fn ST_Direction::to_string(self : ST_Direction) -> String {
  self.value
}

///|
/// XSD simple type ST_Index from pml.xsd (§19).
pub struct ST_Index {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Index::parse(s : String) -> ST_Index raise SchemaViolation {
  validate_pml_simple_type("ST_Index", s)
  { value: s }
}

///|
pub fn ST_Index::new(s : String) -> ST_Index raise SchemaViolation {
  ST_Index::parse(s)
}

///|
pub fn ST_Index::to_string(self : ST_Index) -> String {
  self.value
}

///|
/// XSD simple type ST_OleObjectFollowColorScheme from pml.xsd (§19).
pub struct ST_OleObjectFollowColorScheme {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_OleObjectFollowColorScheme::parse(
  s : String,
) -> ST_OleObjectFollowColorScheme raise SchemaViolation {
  validate_pml_simple_type("ST_OleObjectFollowColorScheme", s)
  { value: s }
}

///|
pub fn ST_OleObjectFollowColorScheme::new(
  s : String,
) -> ST_OleObjectFollowColorScheme raise SchemaViolation {
  ST_OleObjectFollowColorScheme::parse(s)
}

///|
pub fn ST_OleObjectFollowColorScheme::to_string(
  self : ST_OleObjectFollowColorScheme,
) -> String {
  self.value
}

///|
/// XSD simple type ST_SlideId from pml.xsd (§19).
pub struct ST_SlideId {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SlideId::parse(s : String) -> ST_SlideId raise SchemaViolation {
  validate_pml_simple_type("ST_SlideId", s)
  { value: s }
}

///|
pub fn ST_SlideId::new(s : String) -> ST_SlideId raise SchemaViolation {
  ST_SlideId::parse(s)
}

///|
pub fn ST_SlideId::to_string(self : ST_SlideId) -> String {
  self.value
}

///|
/// XSD simple type ST_SlideMasterId from pml.xsd (§19).
pub struct ST_SlideMasterId {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SlideMasterId::parse(
  s : String,
) -> ST_SlideMasterId raise SchemaViolation {
  validate_pml_simple_type("ST_SlideMasterId", s)
  { value: s }
}

///|
pub fn ST_SlideMasterId::new(
  s : String,
) -> ST_SlideMasterId raise SchemaViolation {
  ST_SlideMasterId::parse(s)
}

///|
pub fn ST_SlideMasterId::to_string(self : ST_SlideMasterId) -> String {
  self.value
}

///|
/// XSD simple type ST_PhotoAlbumLayout from pml.xsd (§19).
pub struct ST_PhotoAlbumLayout {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PhotoAlbumLayout::parse(
  s : String,
) -> ST_PhotoAlbumLayout raise SchemaViolation {
  validate_pml_simple_type("ST_PhotoAlbumLayout", s)
  { value: s }
}

///|
pub fn ST_PhotoAlbumLayout::new(
  s : String,
) -> ST_PhotoAlbumLayout raise SchemaViolation {
  ST_PhotoAlbumLayout::parse(s)
}

///|
pub fn ST_PhotoAlbumLayout::to_string(self : ST_PhotoAlbumLayout) -> String {
  self.value
}

///|
/// XSD simple type ST_PhotoAlbumFrameShape from pml.xsd (§19).
pub struct ST_PhotoAlbumFrameShape {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PhotoAlbumFrameShape::parse(
  s : String,
) -> ST_PhotoAlbumFrameShape raise SchemaViolation {
  validate_pml_simple_type("ST_PhotoAlbumFrameShape", s)
  { value: s }
}

///|
pub fn ST_PhotoAlbumFrameShape::new(
  s : String,
) -> ST_PhotoAlbumFrameShape raise SchemaViolation {
  ST_PhotoAlbumFrameShape::parse(s)
}

///|
pub fn ST_PhotoAlbumFrameShape::to_string(
  self : ST_PhotoAlbumFrameShape,
) -> String {
  self.value
}

///|
/// XSD simple type ST_SlideSizeCoordinate from pml.xsd (§19).
pub struct ST_SlideSizeCoordinate {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SlideSizeCoordinate::parse(
  s : String,
) -> ST_SlideSizeCoordinate raise SchemaViolation {
  validate_pml_simple_type("ST_SlideSizeCoordinate", s)
  { value: s }
}

///|
pub fn ST_SlideSizeCoordinate::new(
  s : String,
) -> ST_SlideSizeCoordinate raise SchemaViolation {
  ST_SlideSizeCoordinate::parse(s)
}

///|
pub fn ST_SlideSizeCoordinate::to_string(
  self : ST_SlideSizeCoordinate,
) -> String {
  self.value
}

///|
/// XSD simple type ST_SlideSizeType from pml.xsd (§19).
pub struct ST_SlideSizeType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SlideSizeType::parse(
  s : String,
) -> ST_SlideSizeType raise SchemaViolation {
  validate_pml_simple_type("ST_SlideSizeType", s)
  { value: s }
}

///|
pub fn ST_SlideSizeType::new(
  s : String,
) -> ST_SlideSizeType raise SchemaViolation {
  ST_SlideSizeType::parse(s)
}

///|
pub fn ST_SlideSizeType::to_string(self : ST_SlideSizeType) -> String {
  self.value
}

///|
/// XSD simple type ST_BookmarkIdSeed from pml.xsd (§19).
pub struct ST_BookmarkIdSeed {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_BookmarkIdSeed::parse(
  s : String,
) -> ST_BookmarkIdSeed raise SchemaViolation {
  validate_pml_simple_type("ST_BookmarkIdSeed", s)
  { value: s }
}

///|
pub fn ST_BookmarkIdSeed::new(
  s : String,
) -> ST_BookmarkIdSeed raise SchemaViolation {
  ST_BookmarkIdSeed::parse(s)
}

///|
pub fn ST_BookmarkIdSeed::to_string(self : ST_BookmarkIdSeed) -> String {
  self.value
}

///|
/// XSD simple type ST_PrintWhat from pml.xsd (§19).
pub struct ST_PrintWhat {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PrintWhat::parse(s : String) -> ST_PrintWhat raise SchemaViolation {
  validate_pml_simple_type("ST_PrintWhat", s)
  { value: s }
}

///|
pub fn ST_PrintWhat::new(s : String) -> ST_PrintWhat raise SchemaViolation {
  ST_PrintWhat::parse(s)
}

///|
pub fn ST_PrintWhat::to_string(self : ST_PrintWhat) -> String {
  self.value
}

///|
/// XSD simple type ST_PrintColorMode from pml.xsd (§19).
pub struct ST_PrintColorMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PrintColorMode::parse(
  s : String,
) -> ST_PrintColorMode raise SchemaViolation {
  validate_pml_simple_type("ST_PrintColorMode", s)
  { value: s }
}

///|
pub fn ST_PrintColorMode::new(
  s : String,
) -> ST_PrintColorMode raise SchemaViolation {
  ST_PrintColorMode::parse(s)
}

///|
pub fn ST_PrintColorMode::to_string(self : ST_PrintColorMode) -> String {
  self.value
}

///|
/// XSD simple type ST_PlaceholderType from pml.xsd (§19).
pub struct ST_PlaceholderType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PlaceholderType::parse(
  s : String,
) -> ST_PlaceholderType raise SchemaViolation {
  validate_pml_simple_type("ST_PlaceholderType", s)
  { value: s }
}

///|
pub fn ST_PlaceholderType::new(
  s : String,
) -> ST_PlaceholderType raise SchemaViolation {
  ST_PlaceholderType::parse(s)
}

///|
pub fn ST_PlaceholderType::to_string(self : ST_PlaceholderType) -> String {
  self.value
}

///|
/// XSD simple type ST_PlaceholderSize from pml.xsd (§19).
pub struct ST_PlaceholderSize {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PlaceholderSize::parse(
  s : String,
) -> ST_PlaceholderSize raise SchemaViolation {
  validate_pml_simple_type("ST_PlaceholderSize", s)
  { value: s }
}

///|
pub fn ST_PlaceholderSize::new(
  s : String,
) -> ST_PlaceholderSize raise SchemaViolation {
  ST_PlaceholderSize::parse(s)
}

///|
pub fn ST_PlaceholderSize::to_string(self : ST_PlaceholderSize) -> String {
  self.value
}

///|
/// XSD simple type ST_SlideLayoutType from pml.xsd (§19).
pub struct ST_SlideLayoutType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SlideLayoutType::parse(
  s : String,
) -> ST_SlideLayoutType raise SchemaViolation {
  validate_pml_simple_type("ST_SlideLayoutType", s)
  { value: s }
}

///|
pub fn ST_SlideLayoutType::new(
  s : String,
) -> ST_SlideLayoutType raise SchemaViolation {
  ST_SlideLayoutType::parse(s)
}

///|
pub fn ST_SlideLayoutType::to_string(self : ST_SlideLayoutType) -> String {
  self.value
}

///|
/// XSD simple type ST_SlideLayoutId from pml.xsd (§19).
pub struct ST_SlideLayoutId {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SlideLayoutId::parse(
  s : String,
) -> ST_SlideLayoutId raise SchemaViolation {
  validate_pml_simple_type("ST_SlideLayoutId", s)
  { value: s }
}

///|
pub fn ST_SlideLayoutId::new(
  s : String,
) -> ST_SlideLayoutId raise SchemaViolation {
  ST_SlideLayoutId::parse(s)
}

///|
pub fn ST_SlideLayoutId::to_string(self : ST_SlideLayoutId) -> String {
  self.value
}

///|
/// XSD simple type ST_SplitterBarState from pml.xsd (§19).
pub struct ST_SplitterBarState {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SplitterBarState::parse(
  s : String,
) -> ST_SplitterBarState raise SchemaViolation {
  validate_pml_simple_type("ST_SplitterBarState", s)
  { value: s }
}

///|
pub fn ST_SplitterBarState::new(
  s : String,
) -> ST_SplitterBarState raise SchemaViolation {
  ST_SplitterBarState::parse(s)
}

///|
pub fn ST_SplitterBarState::to_string(self : ST_SplitterBarState) -> String {
  self.value
}

///|
/// XSD simple type ST_ViewType from pml.xsd (§19).
pub struct ST_ViewType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ViewType::parse(s : String) -> ST_ViewType raise SchemaViolation {
  validate_pml_simple_type("ST_ViewType", s)
  { value: s }
}

///|
pub fn ST_ViewType::new(s : String) -> ST_ViewType raise SchemaViolation {
  ST_ViewType::parse(s)
}

///|
pub fn ST_ViewType::to_string(self : ST_ViewType) -> String {
  self.value
}

///|
/// XSD simple type ST_WebColorType from pml.xsd (Part 4 §16).
pub struct ST_WebColorType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_WebColorType::parse(
  s : String,
) -> ST_WebColorType raise SchemaViolation {
  validate_pml_simple_type("ST_WebColorType", s)
  { value: s }
}

///|
pub fn ST_WebColorType::new(
  s : String,
) -> ST_WebColorType raise SchemaViolation {
  ST_WebColorType::parse(s)
}

///|
pub fn ST_WebColorType::to_string(self : ST_WebColorType) -> String {
  self.value
}

///|
/// XSD simple type ST_WebScreenSize from pml.xsd (Part 4 §16).
pub struct ST_WebScreenSize {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_WebScreenSize::parse(
  s : String,
) -> ST_WebScreenSize raise SchemaViolation {
  validate_pml_simple_type("ST_WebScreenSize", s)
  { value: s }
}

///|
pub fn ST_WebScreenSize::new(
  s : String,
) -> ST_WebScreenSize raise SchemaViolation {
  ST_WebScreenSize::parse(s)
}

///|
pub fn ST_WebScreenSize::to_string(self : ST_WebScreenSize) -> String {
  self.value
}

///|
/// XSD simple type ST_WebEncoding from pml.xsd (Part 4 §16).
pub struct ST_WebEncoding {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_WebEncoding::parse(
  s : String,
) -> ST_WebEncoding raise SchemaViolation {
  validate_pml_simple_type("ST_WebEncoding", s)
  { value: s }
}

///|
pub fn ST_WebEncoding::new(s : String) -> ST_WebEncoding raise SchemaViolation {
  ST_WebEncoding::parse(s)
}

///|
pub fn ST_WebEncoding::to_string(self : ST_WebEncoding) -> String {
  self.value
}
