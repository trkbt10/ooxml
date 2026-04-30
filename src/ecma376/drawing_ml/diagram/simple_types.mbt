///|
/// Schema dml-diagram.xsd validation error for DrawingML Diagram (§21.4).
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// XSD simple type ST_ClrAppMethod (§21.4.x).
pub(all) enum ST_ClrAppMethod {
  ClrAppMethodSpan
  ClrAppMethodCycle
  ClrAppMethodRepeat
} derive(Eq, Debug)

///|
/// Parse the ST_ClrAppMethod schema lexical value.
pub fn ST_ClrAppMethod::parse(
  s : String,
) -> ST_ClrAppMethod raise SchemaViolation {
  match s {
    "span" => ClrAppMethodSpan
    "cycle" => ClrAppMethodCycle
    "repeat" => ClrAppMethodRepeat
    _ => invalid("ST_ClrAppMethod", s)
  }
}

///|
/// Construct ST_ClrAppMethod and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ClrAppMethod::new(
  s : String,
) -> ST_ClrAppMethod raise SchemaViolation {
  ST_ClrAppMethod::parse(s)
}

///|
/// Return the schema lexical value for ST_ClrAppMethod.
pub fn ST_ClrAppMethod::to_string(self : ST_ClrAppMethod) -> String {
  match self {
    ClrAppMethodSpan => "span"
    ClrAppMethodCycle => "cycle"
    ClrAppMethodRepeat => "repeat"
  }
}

///|
/// XSD simple type ST_HueDir (§21.4.x).
pub(all) enum ST_HueDir {
  HueDirCw
  HueDirCcw
} derive(Eq, Debug)

///|
/// Parse the ST_HueDir schema lexical value.
pub fn ST_HueDir::parse(s : String) -> ST_HueDir raise SchemaViolation {
  match s {
    "cw" => HueDirCw
    "ccw" => HueDirCcw
    _ => invalid("ST_HueDir", s)
  }
}

///|
/// Construct ST_HueDir and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_HueDir::new(s : String) -> ST_HueDir raise SchemaViolation {
  ST_HueDir::parse(s)
}

///|
/// Return the schema lexical value for ST_HueDir.
pub fn ST_HueDir::to_string(self : ST_HueDir) -> String {
  match self {
    HueDirCw => "cw"
    HueDirCcw => "ccw"
  }
}

///|
/// XSD simple type ST_PtType (§21.4.x).
pub(all) enum ST_PtType {
  PtTypeNode
  PtTypeAsst
  PtTypeDoc
  PtTypePres
  PtTypeParTrans
  PtTypeSibTrans
} derive(Eq, Debug)

///|
/// Parse the ST_PtType schema lexical value.
pub fn ST_PtType::parse(s : String) -> ST_PtType raise SchemaViolation {
  match s {
    "node" => PtTypeNode
    "asst" => PtTypeAsst
    "doc" => PtTypeDoc
    "pres" => PtTypePres
    "parTrans" => PtTypeParTrans
    "sibTrans" => PtTypeSibTrans
    _ => invalid("ST_PtType", s)
  }
}

///|
/// Construct ST_PtType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_PtType::new(s : String) -> ST_PtType raise SchemaViolation {
  ST_PtType::parse(s)
}

///|
/// Return the schema lexical value for ST_PtType.
pub fn ST_PtType::to_string(self : ST_PtType) -> String {
  match self {
    PtTypeNode => "node"
    PtTypeAsst => "asst"
    PtTypeDoc => "doc"
    PtTypePres => "pres"
    PtTypeParTrans => "parTrans"
    PtTypeSibTrans => "sibTrans"
  }
}

///|
/// XSD simple type ST_CxnType (§21.4.x).
pub(all) enum ST_CxnType {
  CxnTypeParOf
  CxnTypePresOf
  CxnTypePresParOf
  CxnTypeUnknownRelationship
} derive(Eq, Debug)

///|
/// Parse the ST_CxnType schema lexical value.
pub fn ST_CxnType::parse(s : String) -> ST_CxnType raise SchemaViolation {
  match s {
    "parOf" => CxnTypeParOf
    "presOf" => CxnTypePresOf
    "presParOf" => CxnTypePresParOf
    "unknownRelationship" => CxnTypeUnknownRelationship
    _ => invalid("ST_CxnType", s)
  }
}

///|
/// Construct ST_CxnType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_CxnType::new(s : String) -> ST_CxnType raise SchemaViolation {
  ST_CxnType::parse(s)
}

///|
/// Return the schema lexical value for ST_CxnType.
pub fn ST_CxnType::to_string(self : ST_CxnType) -> String {
  match self {
    CxnTypeParOf => "parOf"
    CxnTypePresOf => "presOf"
    CxnTypePresParOf => "presParOf"
    CxnTypeUnknownRelationship => "unknownRelationship"
  }
}

///|
/// XSD simple type ST_LayoutShapeType (§21.4.x).
pub struct ST_LayoutShapeType {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_LayoutShapeType schema lexical value.
pub fn ST_LayoutShapeType::parse(
  s : String,
) -> ST_LayoutShapeType raise SchemaViolation {
  validate_ST_LayoutShapeType(s)
  { value: s }
}

///|
/// Construct ST_LayoutShapeType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_LayoutShapeType::new(
  s : String,
) -> ST_LayoutShapeType raise SchemaViolation {
  ST_LayoutShapeType::parse(s)
}

///|
/// Return the schema lexical value for ST_LayoutShapeType.
pub fn ST_LayoutShapeType::to_string(self : ST_LayoutShapeType) -> String {
  self.value
}

///|
/// XSD simple type ST_Index1 (§21.4.x).
pub struct ST_Index1 {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_Index1 schema lexical value.
pub fn ST_Index1::parse(s : String) -> ST_Index1 raise SchemaViolation {
  validate_ST_Index1(s)
  { value: s }
}

///|
/// Construct ST_Index1 and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_Index1::new(s : String) -> ST_Index1 raise SchemaViolation {
  ST_Index1::parse(s)
}

///|
/// Return the schema lexical value for ST_Index1.
pub fn ST_Index1::to_string(self : ST_Index1) -> String {
  self.value
}

///|
/// XSD simple type ST_ParameterVal (§21.4.x).
pub struct ST_ParameterVal {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_ParameterVal schema lexical value.
pub fn ST_ParameterVal::parse(
  s : String,
) -> ST_ParameterVal raise SchemaViolation {
  validate_ST_ParameterVal(s)
  { value: s }
}

///|
/// Construct ST_ParameterVal and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ParameterVal::new(
  s : String,
) -> ST_ParameterVal raise SchemaViolation {
  ST_ParameterVal::parse(s)
}

///|
/// Return the schema lexical value for ST_ParameterVal.
pub fn ST_ParameterVal::to_string(self : ST_ParameterVal) -> String {
  self.value
}

///|
/// XSD simple type ST_ModelId (§21.4.x).
pub struct ST_ModelId {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_ModelId schema lexical value.
pub fn ST_ModelId::parse(s : String) -> ST_ModelId raise SchemaViolation {
  validate_ST_ModelId(s)
  { value: s }
}

///|
/// Construct ST_ModelId and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ModelId::new(s : String) -> ST_ModelId raise SchemaViolation {
  ST_ModelId::parse(s)
}

///|
/// Return the schema lexical value for ST_ModelId.
pub fn ST_ModelId::to_string(self : ST_ModelId) -> String {
  self.value
}

///|
/// XSD simple type ST_PrSetCustVal (§21.4.x).
pub struct ST_PrSetCustVal {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_PrSetCustVal schema lexical value.
pub fn ST_PrSetCustVal::parse(
  s : String,
) -> ST_PrSetCustVal raise SchemaViolation {
  validate_ST_PrSetCustVal(s)
  { value: s }
}

///|
/// Construct ST_PrSetCustVal and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_PrSetCustVal::new(
  s : String,
) -> ST_PrSetCustVal raise SchemaViolation {
  ST_PrSetCustVal::parse(s)
}

///|
/// Return the schema lexical value for ST_PrSetCustVal.
pub fn ST_PrSetCustVal::to_string(self : ST_PrSetCustVal) -> String {
  self.value
}

///|
/// XSD simple type ST_Direction (§21.4.x).
pub(all) enum ST_Direction {
  DirectionNorm
  DirectionRev
} derive(Eq, Debug)

///|
/// Parse the ST_Direction schema lexical value.
pub fn ST_Direction::parse(s : String) -> ST_Direction raise SchemaViolation {
  match s {
    "norm" => DirectionNorm
    "rev" => DirectionRev
    _ => invalid("ST_Direction", s)
  }
}

///|
/// Construct ST_Direction and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_Direction::new(s : String) -> ST_Direction raise SchemaViolation {
  ST_Direction::parse(s)
}

///|
/// Return the schema lexical value for ST_Direction.
pub fn ST_Direction::to_string(self : ST_Direction) -> String {
  match self {
    DirectionNorm => "norm"
    DirectionRev => "rev"
  }
}

///|
/// XSD simple type ST_HierBranchStyle (§21.4.x).
pub(all) enum ST_HierBranchStyle {
  HierBranchStyleL
  HierBranchStyleR
  HierBranchStyleHang
  HierBranchStyleStd
  HierBranchStyleInit
} derive(Eq, Debug)

///|
/// Parse the ST_HierBranchStyle schema lexical value.
pub fn ST_HierBranchStyle::parse(
  s : String,
) -> ST_HierBranchStyle raise SchemaViolation {
  match s {
    "l" => HierBranchStyleL
    "r" => HierBranchStyleR
    "hang" => HierBranchStyleHang
    "std" => HierBranchStyleStd
    "init" => HierBranchStyleInit
    _ => invalid("ST_HierBranchStyle", s)
  }
}

///|
/// Construct ST_HierBranchStyle and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_HierBranchStyle::new(
  s : String,
) -> ST_HierBranchStyle raise SchemaViolation {
  ST_HierBranchStyle::parse(s)
}

///|
/// Return the schema lexical value for ST_HierBranchStyle.
pub fn ST_HierBranchStyle::to_string(self : ST_HierBranchStyle) -> String {
  match self {
    HierBranchStyleL => "l"
    HierBranchStyleR => "r"
    HierBranchStyleHang => "hang"
    HierBranchStyleStd => "std"
    HierBranchStyleInit => "init"
  }
}

///|
/// XSD simple type ST_AnimOneStr (§21.4.x).
pub(all) enum ST_AnimOneStr {
  AnimOneStrNone
  AnimOneStrOne
  AnimOneStrBranch
} derive(Eq, Debug)

///|
/// Parse the ST_AnimOneStr schema lexical value.
pub fn ST_AnimOneStr::parse(s : String) -> ST_AnimOneStr raise SchemaViolation {
  match s {
    "none" => AnimOneStrNone
    "one" => AnimOneStrOne
    "branch" => AnimOneStrBranch
    _ => invalid("ST_AnimOneStr", s)
  }
}

///|
/// Construct ST_AnimOneStr and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_AnimOneStr::new(s : String) -> ST_AnimOneStr raise SchemaViolation {
  ST_AnimOneStr::parse(s)
}

///|
/// Return the schema lexical value for ST_AnimOneStr.
pub fn ST_AnimOneStr::to_string(self : ST_AnimOneStr) -> String {
  match self {
    AnimOneStrNone => "none"
    AnimOneStrOne => "one"
    AnimOneStrBranch => "branch"
  }
}

///|
/// XSD simple type ST_AnimLvlStr (§21.4.x).
pub(all) enum ST_AnimLvlStr {
  AnimLvlStrNone
  AnimLvlStrLvl
  AnimLvlStrCtr
} derive(Eq, Debug)

///|
/// Parse the ST_AnimLvlStr schema lexical value.
pub fn ST_AnimLvlStr::parse(s : String) -> ST_AnimLvlStr raise SchemaViolation {
  match s {
    "none" => AnimLvlStrNone
    "lvl" => AnimLvlStrLvl
    "ctr" => AnimLvlStrCtr
    _ => invalid("ST_AnimLvlStr", s)
  }
}

///|
/// Construct ST_AnimLvlStr and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_AnimLvlStr::new(s : String) -> ST_AnimLvlStr raise SchemaViolation {
  ST_AnimLvlStr::parse(s)
}

///|
/// Return the schema lexical value for ST_AnimLvlStr.
pub fn ST_AnimLvlStr::to_string(self : ST_AnimLvlStr) -> String {
  match self {
    AnimLvlStrNone => "none"
    AnimLvlStrLvl => "lvl"
    AnimLvlStrCtr => "ctr"
  }
}

///|
/// XSD simple type ST_NodeCount (§21.4.x).
pub struct ST_NodeCount {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_NodeCount schema lexical value.
pub fn ST_NodeCount::parse(s : String) -> ST_NodeCount raise SchemaViolation {
  validate_ST_NodeCount(s)
  { value: s }
}

///|
/// Construct ST_NodeCount and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_NodeCount::new(s : String) -> ST_NodeCount raise SchemaViolation {
  ST_NodeCount::parse(s)
}

///|
/// Return the schema lexical value for ST_NodeCount.
pub fn ST_NodeCount::to_string(self : ST_NodeCount) -> String {
  self.value
}

///|
/// XSD simple type ST_ResizeHandlesStr (§21.4.x).
pub(all) enum ST_ResizeHandlesStr {
  ResizeHandlesStrExact
  ResizeHandlesStrRel
} derive(Eq, Debug)

///|
/// Parse the ST_ResizeHandlesStr schema lexical value.
pub fn ST_ResizeHandlesStr::parse(
  s : String,
) -> ST_ResizeHandlesStr raise SchemaViolation {
  match s {
    "exact" => ResizeHandlesStrExact
    "rel" => ResizeHandlesStrRel
    _ => invalid("ST_ResizeHandlesStr", s)
  }
}

///|
/// Construct ST_ResizeHandlesStr and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ResizeHandlesStr::new(
  s : String,
) -> ST_ResizeHandlesStr raise SchemaViolation {
  ST_ResizeHandlesStr::parse(s)
}

///|
/// Return the schema lexical value for ST_ResizeHandlesStr.
pub fn ST_ResizeHandlesStr::to_string(self : ST_ResizeHandlesStr) -> String {
  match self {
    ResizeHandlesStrExact => "exact"
    ResizeHandlesStrRel => "rel"
  }
}

///|
/// XSD simple type ST_AlgorithmType (§21.4.x).
pub(all) enum ST_AlgorithmType {
  AlgorithmTypeComposite
  AlgorithmTypeConn
  AlgorithmTypeCycle
  AlgorithmTypeHierChild
  AlgorithmTypeHierRoot
  AlgorithmTypePyra
  AlgorithmTypeLin
  AlgorithmTypeSp
  AlgorithmTypeTx
  AlgorithmTypeSnake
} derive(Eq, Debug)

///|
/// Parse the ST_AlgorithmType schema lexical value.
pub fn ST_AlgorithmType::parse(
  s : String,
) -> ST_AlgorithmType raise SchemaViolation {
  match s {
    "composite" => AlgorithmTypeComposite
    "conn" => AlgorithmTypeConn
    "cycle" => AlgorithmTypeCycle
    "hierChild" => AlgorithmTypeHierChild
    "hierRoot" => AlgorithmTypeHierRoot
    "pyra" => AlgorithmTypePyra
    "lin" => AlgorithmTypeLin
    "sp" => AlgorithmTypeSp
    "tx" => AlgorithmTypeTx
    "snake" => AlgorithmTypeSnake
    _ => invalid("ST_AlgorithmType", s)
  }
}

///|
/// Construct ST_AlgorithmType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_AlgorithmType::new(
  s : String,
) -> ST_AlgorithmType raise SchemaViolation {
  ST_AlgorithmType::parse(s)
}

///|
/// Return the schema lexical value for ST_AlgorithmType.
pub fn ST_AlgorithmType::to_string(self : ST_AlgorithmType) -> String {
  match self {
    AlgorithmTypeComposite => "composite"
    AlgorithmTypeConn => "conn"
    AlgorithmTypeCycle => "cycle"
    AlgorithmTypeHierChild => "hierChild"
    AlgorithmTypeHierRoot => "hierRoot"
    AlgorithmTypePyra => "pyra"
    AlgorithmTypeLin => "lin"
    AlgorithmTypeSp => "sp"
    AlgorithmTypeTx => "tx"
    AlgorithmTypeSnake => "snake"
  }
}

///|
/// XSD simple type ST_AxisType (§21.4.x).
pub(all) enum ST_AxisType {
  AxisTypeSelf
  AxisTypeCh
  AxisTypeDes
  AxisTypeDesOrSelf
  AxisTypePar
  AxisTypeAncst
  AxisTypeAncstOrSelf
  AxisTypeFollowSib
  AxisTypePrecedSib
  AxisTypeFollow
  AxisTypePreced
  AxisTypeRoot
  AxisTypeNone
} derive(Eq, Debug)

///|
/// Parse the ST_AxisType schema lexical value.
pub fn ST_AxisType::parse(s : String) -> ST_AxisType raise SchemaViolation {
  match s {
    "self" => AxisTypeSelf
    "ch" => AxisTypeCh
    "des" => AxisTypeDes
    "desOrSelf" => AxisTypeDesOrSelf
    "par" => AxisTypePar
    "ancst" => AxisTypeAncst
    "ancstOrSelf" => AxisTypeAncstOrSelf
    "followSib" => AxisTypeFollowSib
    "precedSib" => AxisTypePrecedSib
    "follow" => AxisTypeFollow
    "preced" => AxisTypePreced
    "root" => AxisTypeRoot
    "none" => AxisTypeNone
    _ => invalid("ST_AxisType", s)
  }
}

///|
/// Construct ST_AxisType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_AxisType::new(s : String) -> ST_AxisType raise SchemaViolation {
  ST_AxisType::parse(s)
}

///|
/// Return the schema lexical value for ST_AxisType.
pub fn ST_AxisType::to_string(self : ST_AxisType) -> String {
  match self {
    AxisTypeSelf => "self"
    AxisTypeCh => "ch"
    AxisTypeDes => "des"
    AxisTypeDesOrSelf => "desOrSelf"
    AxisTypePar => "par"
    AxisTypeAncst => "ancst"
    AxisTypeAncstOrSelf => "ancstOrSelf"
    AxisTypeFollowSib => "followSib"
    AxisTypePrecedSib => "precedSib"
    AxisTypeFollow => "follow"
    AxisTypePreced => "preced"
    AxisTypeRoot => "root"
    AxisTypeNone => "none"
  }
}

///|
/// XSD simple type ST_AxisTypes (§21.4.x).
pub struct ST_AxisTypes {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_AxisTypes schema lexical value.
pub fn ST_AxisTypes::parse(s : String) -> ST_AxisTypes raise SchemaViolation {
  validate_ST_AxisTypes(s)
  { value: s }
}

///|
/// Construct ST_AxisTypes and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_AxisTypes::new(s : String) -> ST_AxisTypes raise SchemaViolation {
  ST_AxisTypes::parse(s)
}

///|
/// Return the schema lexical value for ST_AxisTypes.
pub fn ST_AxisTypes::to_string(self : ST_AxisTypes) -> String {
  self.value
}

///|
/// XSD simple type ST_BoolOperator (§21.4.x).
pub(all) enum ST_BoolOperator {
  BoolOperatorNone
  BoolOperatorEqu
  BoolOperatorGte
  BoolOperatorLte
} derive(Eq, Debug)

///|
/// Parse the ST_BoolOperator schema lexical value.
pub fn ST_BoolOperator::parse(
  s : String,
) -> ST_BoolOperator raise SchemaViolation {
  match s {
    "none" => BoolOperatorNone
    "equ" => BoolOperatorEqu
    "gte" => BoolOperatorGte
    "lte" => BoolOperatorLte
    _ => invalid("ST_BoolOperator", s)
  }
}

///|
/// Construct ST_BoolOperator and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_BoolOperator::new(
  s : String,
) -> ST_BoolOperator raise SchemaViolation {
  ST_BoolOperator::parse(s)
}

///|
/// Return the schema lexical value for ST_BoolOperator.
pub fn ST_BoolOperator::to_string(self : ST_BoolOperator) -> String {
  match self {
    BoolOperatorNone => "none"
    BoolOperatorEqu => "equ"
    BoolOperatorGte => "gte"
    BoolOperatorLte => "lte"
  }
}

///|
/// XSD simple type ST_ChildOrderType (§21.4.x).
pub(all) enum ST_ChildOrderType {
  ChildOrderTypeB
  ChildOrderTypeT
} derive(Eq, Debug)

///|
/// Parse the ST_ChildOrderType schema lexical value.
pub fn ST_ChildOrderType::parse(
  s : String,
) -> ST_ChildOrderType raise SchemaViolation {
  match s {
    "b" => ChildOrderTypeB
    "t" => ChildOrderTypeT
    _ => invalid("ST_ChildOrderType", s)
  }
}

///|
/// Construct ST_ChildOrderType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ChildOrderType::new(
  s : String,
) -> ST_ChildOrderType raise SchemaViolation {
  ST_ChildOrderType::parse(s)
}

///|
/// Return the schema lexical value for ST_ChildOrderType.
pub fn ST_ChildOrderType::to_string(self : ST_ChildOrderType) -> String {
  match self {
    ChildOrderTypeB => "b"
    ChildOrderTypeT => "t"
  }
}

///|
/// XSD simple type ST_ConstraintType (§21.4.x).
pub(all) enum ST_ConstraintType {
  ConstraintTypeNone
  ConstraintTypeAlignOff
  ConstraintTypeBegMarg
  ConstraintTypeBendDist
  ConstraintTypeBegPad
  ConstraintTypeB
  ConstraintTypeBMarg
  ConstraintTypeBOff
  ConstraintTypeCtrX
  ConstraintTypeCtrXOff
  ConstraintTypeCtrY
  ConstraintTypeCtrYOff
  ConstraintTypeConnDist
  ConstraintTypeDiam
  ConstraintTypeEndMarg
  ConstraintTypeEndPad
  ConstraintTypeH
  ConstraintTypeHArH
  ConstraintTypeHOff
  ConstraintTypeL
  ConstraintTypeLMarg
  ConstraintTypeLOff
  ConstraintTypeR
  ConstraintTypeRMarg
  ConstraintTypeROff
  ConstraintTypePrimFontSz
  ConstraintTypePyraAcctRatio
  ConstraintTypeSecFontSz
  ConstraintTypeSibSp
  ConstraintTypeSecSibSp
  ConstraintTypeSp
  ConstraintTypeStemThick
  ConstraintTypeT
  ConstraintTypeTMarg
  ConstraintTypeTOff
  ConstraintTypeUserA
  ConstraintTypeUserB
  ConstraintTypeUserC
  ConstraintTypeUserD
  ConstraintTypeUserE
  ConstraintTypeUserF
  ConstraintTypeUserG
  ConstraintTypeUserH
  ConstraintTypeUserI
  ConstraintTypeUserJ
  ConstraintTypeUserK
  ConstraintTypeUserL
  ConstraintTypeUserM
  ConstraintTypeUserN
  ConstraintTypeUserO
  ConstraintTypeUserP
  ConstraintTypeUserQ
  ConstraintTypeUserR
  ConstraintTypeUserS
  ConstraintTypeUserT
  ConstraintTypeUserU
  ConstraintTypeUserV
  ConstraintTypeUserW
  ConstraintTypeUserX
  ConstraintTypeUserY
  ConstraintTypeUserZ
  ConstraintTypeW
  ConstraintTypeWArH
  ConstraintTypeWOff
} derive(Eq, Debug)

///|
/// Parse the ST_ConstraintType schema lexical value.
pub fn ST_ConstraintType::parse(
  s : String,
) -> ST_ConstraintType raise SchemaViolation {
  match s {
    "none" => ConstraintTypeNone
    "alignOff" => ConstraintTypeAlignOff
    "begMarg" => ConstraintTypeBegMarg
    "bendDist" => ConstraintTypeBendDist
    "begPad" => ConstraintTypeBegPad
    "b" => ConstraintTypeB
    "bMarg" => ConstraintTypeBMarg
    "bOff" => ConstraintTypeBOff
    "ctrX" => ConstraintTypeCtrX
    "ctrXOff" => ConstraintTypeCtrXOff
    "ctrY" => ConstraintTypeCtrY
    "ctrYOff" => ConstraintTypeCtrYOff
    "connDist" => ConstraintTypeConnDist
    "diam" => ConstraintTypeDiam
    "endMarg" => ConstraintTypeEndMarg
    "endPad" => ConstraintTypeEndPad
    "h" => ConstraintTypeH
    "hArH" => ConstraintTypeHArH
    "hOff" => ConstraintTypeHOff
    "l" => ConstraintTypeL
    "lMarg" => ConstraintTypeLMarg
    "lOff" => ConstraintTypeLOff
    "r" => ConstraintTypeR
    "rMarg" => ConstraintTypeRMarg
    "rOff" => ConstraintTypeROff
    "primFontSz" => ConstraintTypePrimFontSz
    "pyraAcctRatio" => ConstraintTypePyraAcctRatio
    "secFontSz" => ConstraintTypeSecFontSz
    "sibSp" => ConstraintTypeSibSp
    "secSibSp" => ConstraintTypeSecSibSp
    "sp" => ConstraintTypeSp
    "stemThick" => ConstraintTypeStemThick
    "t" => ConstraintTypeT
    "tMarg" => ConstraintTypeTMarg
    "tOff" => ConstraintTypeTOff
    "userA" => ConstraintTypeUserA
    "userB" => ConstraintTypeUserB
    "userC" => ConstraintTypeUserC
    "userD" => ConstraintTypeUserD
    "userE" => ConstraintTypeUserE
    "userF" => ConstraintTypeUserF
    "userG" => ConstraintTypeUserG
    "userH" => ConstraintTypeUserH
    "userI" => ConstraintTypeUserI
    "userJ" => ConstraintTypeUserJ
    "userK" => ConstraintTypeUserK
    "userL" => ConstraintTypeUserL
    "userM" => ConstraintTypeUserM
    "userN" => ConstraintTypeUserN
    "userO" => ConstraintTypeUserO
    "userP" => ConstraintTypeUserP
    "userQ" => ConstraintTypeUserQ
    "userR" => ConstraintTypeUserR
    "userS" => ConstraintTypeUserS
    "userT" => ConstraintTypeUserT
    "userU" => ConstraintTypeUserU
    "userV" => ConstraintTypeUserV
    "userW" => ConstraintTypeUserW
    "userX" => ConstraintTypeUserX
    "userY" => ConstraintTypeUserY
    "userZ" => ConstraintTypeUserZ
    "w" => ConstraintTypeW
    "wArH" => ConstraintTypeWArH
    "wOff" => ConstraintTypeWOff
    _ => invalid("ST_ConstraintType", s)
  }
}

///|
/// Construct ST_ConstraintType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ConstraintType::new(
  s : String,
) -> ST_ConstraintType raise SchemaViolation {
  ST_ConstraintType::parse(s)
}

///|
/// Return the schema lexical value for ST_ConstraintType.
pub fn ST_ConstraintType::to_string(self : ST_ConstraintType) -> String {
  match self {
    ConstraintTypeNone => "none"
    ConstraintTypeAlignOff => "alignOff"
    ConstraintTypeBegMarg => "begMarg"
    ConstraintTypeBendDist => "bendDist"
    ConstraintTypeBegPad => "begPad"
    ConstraintTypeB => "b"
    ConstraintTypeBMarg => "bMarg"
    ConstraintTypeBOff => "bOff"
    ConstraintTypeCtrX => "ctrX"
    ConstraintTypeCtrXOff => "ctrXOff"
    ConstraintTypeCtrY => "ctrY"
    ConstraintTypeCtrYOff => "ctrYOff"
    ConstraintTypeConnDist => "connDist"
    ConstraintTypeDiam => "diam"
    ConstraintTypeEndMarg => "endMarg"
    ConstraintTypeEndPad => "endPad"
    ConstraintTypeH => "h"
    ConstraintTypeHArH => "hArH"
    ConstraintTypeHOff => "hOff"
    ConstraintTypeL => "l"
    ConstraintTypeLMarg => "lMarg"
    ConstraintTypeLOff => "lOff"
    ConstraintTypeR => "r"
    ConstraintTypeRMarg => "rMarg"
    ConstraintTypeROff => "rOff"
    ConstraintTypePrimFontSz => "primFontSz"
    ConstraintTypePyraAcctRatio => "pyraAcctRatio"
    ConstraintTypeSecFontSz => "secFontSz"
    ConstraintTypeSibSp => "sibSp"
    ConstraintTypeSecSibSp => "secSibSp"
    ConstraintTypeSp => "sp"
    ConstraintTypeStemThick => "stemThick"
    ConstraintTypeT => "t"
    ConstraintTypeTMarg => "tMarg"
    ConstraintTypeTOff => "tOff"
    ConstraintTypeUserA => "userA"
    ConstraintTypeUserB => "userB"
    ConstraintTypeUserC => "userC"
    ConstraintTypeUserD => "userD"
    ConstraintTypeUserE => "userE"
    ConstraintTypeUserF => "userF"
    ConstraintTypeUserG => "userG"
    ConstraintTypeUserH => "userH"
    ConstraintTypeUserI => "userI"
    ConstraintTypeUserJ => "userJ"
    ConstraintTypeUserK => "userK"
    ConstraintTypeUserL => "userL"
    ConstraintTypeUserM => "userM"
    ConstraintTypeUserN => "userN"
    ConstraintTypeUserO => "userO"
    ConstraintTypeUserP => "userP"
    ConstraintTypeUserQ => "userQ"
    ConstraintTypeUserR => "userR"
    ConstraintTypeUserS => "userS"
    ConstraintTypeUserT => "userT"
    ConstraintTypeUserU => "userU"
    ConstraintTypeUserV => "userV"
    ConstraintTypeUserW => "userW"
    ConstraintTypeUserX => "userX"
    ConstraintTypeUserY => "userY"
    ConstraintTypeUserZ => "userZ"
    ConstraintTypeW => "w"
    ConstraintTypeWArH => "wArH"
    ConstraintTypeWOff => "wOff"
  }
}

///|
/// XSD simple type ST_ConstraintRelationship (§21.4.x).
pub(all) enum ST_ConstraintRelationship {
  ConstraintRelationshipSelf
  ConstraintRelationshipCh
  ConstraintRelationshipDes
} derive(Eq, Debug)

///|
/// Parse the ST_ConstraintRelationship schema lexical value.
pub fn ST_ConstraintRelationship::parse(
  s : String,
) -> ST_ConstraintRelationship raise SchemaViolation {
  match s {
    "self" => ConstraintRelationshipSelf
    "ch" => ConstraintRelationshipCh
    "des" => ConstraintRelationshipDes
    _ => invalid("ST_ConstraintRelationship", s)
  }
}

///|
/// Construct ST_ConstraintRelationship and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ConstraintRelationship::new(
  s : String,
) -> ST_ConstraintRelationship raise SchemaViolation {
  ST_ConstraintRelationship::parse(s)
}

///|
/// Return the schema lexical value for ST_ConstraintRelationship.
pub fn ST_ConstraintRelationship::to_string(
  self : ST_ConstraintRelationship,
) -> String {
  match self {
    ConstraintRelationshipSelf => "self"
    ConstraintRelationshipCh => "ch"
    ConstraintRelationshipDes => "des"
  }
}

///|
/// XSD simple type ST_ElementType (§21.4.x).
pub(all) enum ST_ElementType {
  ElementTypeAll
  ElementTypeDoc
  ElementTypeNode
  ElementTypeNorm
  ElementTypeNonNorm
  ElementTypeAsst
  ElementTypeNonAsst
  ElementTypeParTrans
  ElementTypePres
  ElementTypeSibTrans
} derive(Eq, Debug)

///|
/// Parse the ST_ElementType schema lexical value.
pub fn ST_ElementType::parse(
  s : String,
) -> ST_ElementType raise SchemaViolation {
  match s {
    "all" => ElementTypeAll
    "doc" => ElementTypeDoc
    "node" => ElementTypeNode
    "norm" => ElementTypeNorm
    "nonNorm" => ElementTypeNonNorm
    "asst" => ElementTypeAsst
    "nonAsst" => ElementTypeNonAsst
    "parTrans" => ElementTypeParTrans
    "pres" => ElementTypePres
    "sibTrans" => ElementTypeSibTrans
    _ => invalid("ST_ElementType", s)
  }
}

///|
/// Construct ST_ElementType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ElementType::new(s : String) -> ST_ElementType raise SchemaViolation {
  ST_ElementType::parse(s)
}

///|
/// Return the schema lexical value for ST_ElementType.
pub fn ST_ElementType::to_string(self : ST_ElementType) -> String {
  match self {
    ElementTypeAll => "all"
    ElementTypeDoc => "doc"
    ElementTypeNode => "node"
    ElementTypeNorm => "norm"
    ElementTypeNonNorm => "nonNorm"
    ElementTypeAsst => "asst"
    ElementTypeNonAsst => "nonAsst"
    ElementTypeParTrans => "parTrans"
    ElementTypePres => "pres"
    ElementTypeSibTrans => "sibTrans"
  }
}

///|
/// XSD simple type ST_ElementTypes (§21.4.x).
pub struct ST_ElementTypes {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_ElementTypes schema lexical value.
pub fn ST_ElementTypes::parse(
  s : String,
) -> ST_ElementTypes raise SchemaViolation {
  validate_ST_ElementTypes(s)
  { value: s }
}

///|
/// Construct ST_ElementTypes and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ElementTypes::new(
  s : String,
) -> ST_ElementTypes raise SchemaViolation {
  ST_ElementTypes::parse(s)
}

///|
/// Return the schema lexical value for ST_ElementTypes.
pub fn ST_ElementTypes::to_string(self : ST_ElementTypes) -> String {
  self.value
}

///|
/// XSD simple type ST_ParameterId (§21.4.x).
pub(all) enum ST_ParameterId {
  ParameterIdHorzAlign
  ParameterIdVertAlign
  ParameterIdChDir
  ParameterIdChAlign
  ParameterIdSecChAlign
  ParameterIdLinDir
  ParameterIdSecLinDir
  ParameterIdStElem
  ParameterIdBendPt
  ParameterIdConnRout
  ParameterIdBegSty
  ParameterIdEndSty
  ParameterIdDim
  ParameterIdRotPath
  ParameterIdCtrShpMap
  ParameterIdNodeHorzAlign
  ParameterIdNodeVertAlign
  ParameterIdFallback
  ParameterIdTxDir
  ParameterIdPyraAcctPos
  ParameterIdPyraAcctTxMar
  ParameterIdTxBlDir
  ParameterIdTxAnchorHorz
  ParameterIdTxAnchorVert
  ParameterIdTxAnchorHorzCh
  ParameterIdTxAnchorVertCh
  ParameterIdParTxLTRAlign
  ParameterIdParTxRTLAlign
  ParameterIdShpTxLTRAlignCh
  ParameterIdShpTxRTLAlignCh
  ParameterIdAutoTxRot
  ParameterIdGrDir
  ParameterIdFlowDir
  ParameterIdContDir
  ParameterIdBkpt
  ParameterIdOff
  ParameterIdHierAlign
  ParameterIdBkPtFixedVal
  ParameterIdStBulletLvl
  ParameterIdStAng
  ParameterIdSpanAng
  ParameterIdAr
  ParameterIdLnSpPar
  ParameterIdLnSpAfParP
  ParameterIdLnSpCh
  ParameterIdLnSpAfChP
  ParameterIdRtShortDist
  ParameterIdAlignTx
  ParameterIdPyraLvlNode
  ParameterIdPyraAcctBkgdNode
  ParameterIdPyraAcctTxNode
  ParameterIdSrcNode
  ParameterIdDstNode
  ParameterIdBegPts
  ParameterIdEndPts
} derive(Eq, Debug)

///|
/// Parse the ST_ParameterId schema lexical value.
pub fn ST_ParameterId::parse(
  s : String,
) -> ST_ParameterId raise SchemaViolation {
  match s {
    "horzAlign" => ParameterIdHorzAlign
    "vertAlign" => ParameterIdVertAlign
    "chDir" => ParameterIdChDir
    "chAlign" => ParameterIdChAlign
    "secChAlign" => ParameterIdSecChAlign
    "linDir" => ParameterIdLinDir
    "secLinDir" => ParameterIdSecLinDir
    "stElem" => ParameterIdStElem
    "bendPt" => ParameterIdBendPt
    "connRout" => ParameterIdConnRout
    "begSty" => ParameterIdBegSty
    "endSty" => ParameterIdEndSty
    "dim" => ParameterIdDim
    "rotPath" => ParameterIdRotPath
    "ctrShpMap" => ParameterIdCtrShpMap
    "nodeHorzAlign" => ParameterIdNodeHorzAlign
    "nodeVertAlign" => ParameterIdNodeVertAlign
    "fallback" => ParameterIdFallback
    "txDir" => ParameterIdTxDir
    "pyraAcctPos" => ParameterIdPyraAcctPos
    "pyraAcctTxMar" => ParameterIdPyraAcctTxMar
    "txBlDir" => ParameterIdTxBlDir
    "txAnchorHorz" => ParameterIdTxAnchorHorz
    "txAnchorVert" => ParameterIdTxAnchorVert
    "txAnchorHorzCh" => ParameterIdTxAnchorHorzCh
    "txAnchorVertCh" => ParameterIdTxAnchorVertCh
    "parTxLTRAlign" => ParameterIdParTxLTRAlign
    "parTxRTLAlign" => ParameterIdParTxRTLAlign
    "shpTxLTRAlignCh" => ParameterIdShpTxLTRAlignCh
    "shpTxRTLAlignCh" => ParameterIdShpTxRTLAlignCh
    "autoTxRot" => ParameterIdAutoTxRot
    "grDir" => ParameterIdGrDir
    "flowDir" => ParameterIdFlowDir
    "contDir" => ParameterIdContDir
    "bkpt" => ParameterIdBkpt
    "off" => ParameterIdOff
    "hierAlign" => ParameterIdHierAlign
    "bkPtFixedVal" => ParameterIdBkPtFixedVal
    "stBulletLvl" => ParameterIdStBulletLvl
    "stAng" => ParameterIdStAng
    "spanAng" => ParameterIdSpanAng
    "ar" => ParameterIdAr
    "lnSpPar" => ParameterIdLnSpPar
    "lnSpAfParP" => ParameterIdLnSpAfParP
    "lnSpCh" => ParameterIdLnSpCh
    "lnSpAfChP" => ParameterIdLnSpAfChP
    "rtShortDist" => ParameterIdRtShortDist
    "alignTx" => ParameterIdAlignTx
    "pyraLvlNode" => ParameterIdPyraLvlNode
    "pyraAcctBkgdNode" => ParameterIdPyraAcctBkgdNode
    "pyraAcctTxNode" => ParameterIdPyraAcctTxNode
    "srcNode" => ParameterIdSrcNode
    "dstNode" => ParameterIdDstNode
    "begPts" => ParameterIdBegPts
    "endPts" => ParameterIdEndPts
    _ => invalid("ST_ParameterId", s)
  }
}

///|
/// Construct ST_ParameterId and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ParameterId::new(s : String) -> ST_ParameterId raise SchemaViolation {
  ST_ParameterId::parse(s)
}

///|
/// Return the schema lexical value for ST_ParameterId.
pub fn ST_ParameterId::to_string(self : ST_ParameterId) -> String {
  match self {
    ParameterIdHorzAlign => "horzAlign"
    ParameterIdVertAlign => "vertAlign"
    ParameterIdChDir => "chDir"
    ParameterIdChAlign => "chAlign"
    ParameterIdSecChAlign => "secChAlign"
    ParameterIdLinDir => "linDir"
    ParameterIdSecLinDir => "secLinDir"
    ParameterIdStElem => "stElem"
    ParameterIdBendPt => "bendPt"
    ParameterIdConnRout => "connRout"
    ParameterIdBegSty => "begSty"
    ParameterIdEndSty => "endSty"
    ParameterIdDim => "dim"
    ParameterIdRotPath => "rotPath"
    ParameterIdCtrShpMap => "ctrShpMap"
    ParameterIdNodeHorzAlign => "nodeHorzAlign"
    ParameterIdNodeVertAlign => "nodeVertAlign"
    ParameterIdFallback => "fallback"
    ParameterIdTxDir => "txDir"
    ParameterIdPyraAcctPos => "pyraAcctPos"
    ParameterIdPyraAcctTxMar => "pyraAcctTxMar"
    ParameterIdTxBlDir => "txBlDir"
    ParameterIdTxAnchorHorz => "txAnchorHorz"
    ParameterIdTxAnchorVert => "txAnchorVert"
    ParameterIdTxAnchorHorzCh => "txAnchorHorzCh"
    ParameterIdTxAnchorVertCh => "txAnchorVertCh"
    ParameterIdParTxLTRAlign => "parTxLTRAlign"
    ParameterIdParTxRTLAlign => "parTxRTLAlign"
    ParameterIdShpTxLTRAlignCh => "shpTxLTRAlignCh"
    ParameterIdShpTxRTLAlignCh => "shpTxRTLAlignCh"
    ParameterIdAutoTxRot => "autoTxRot"
    ParameterIdGrDir => "grDir"
    ParameterIdFlowDir => "flowDir"
    ParameterIdContDir => "contDir"
    ParameterIdBkpt => "bkpt"
    ParameterIdOff => "off"
    ParameterIdHierAlign => "hierAlign"
    ParameterIdBkPtFixedVal => "bkPtFixedVal"
    ParameterIdStBulletLvl => "stBulletLvl"
    ParameterIdStAng => "stAng"
    ParameterIdSpanAng => "spanAng"
    ParameterIdAr => "ar"
    ParameterIdLnSpPar => "lnSpPar"
    ParameterIdLnSpAfParP => "lnSpAfParP"
    ParameterIdLnSpCh => "lnSpCh"
    ParameterIdLnSpAfChP => "lnSpAfChP"
    ParameterIdRtShortDist => "rtShortDist"
    ParameterIdAlignTx => "alignTx"
    ParameterIdPyraLvlNode => "pyraLvlNode"
    ParameterIdPyraAcctBkgdNode => "pyraAcctBkgdNode"
    ParameterIdPyraAcctTxNode => "pyraAcctTxNode"
    ParameterIdSrcNode => "srcNode"
    ParameterIdDstNode => "dstNode"
    ParameterIdBegPts => "begPts"
    ParameterIdEndPts => "endPts"
  }
}

///|
/// XSD simple type ST_Ints (§21.4): value type exposes ST_Ints for a dml-diagram.xsd whitespace-separated xsd:int list.
pub struct ST_Ints {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_Ints schema lexical value.
pub fn ST_Ints::parse(s : String) -> ST_Ints raise SchemaViolation {
  validate_ST_Ints(s)
  { value: s }
}

///|
/// Construct ST_Ints and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_Ints::new(s : String) -> ST_Ints raise SchemaViolation {
  ST_Ints::parse(s)
}

///|
/// Return the schema lexical value for ST_Ints.
pub fn ST_Ints::to_string(self : ST_Ints) -> String {
  self.value
}

///|
/// XSD simple type ST_UnsignedInts (§21.4.x).
pub struct ST_UnsignedInts {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_UnsignedInts schema lexical value.
pub fn ST_UnsignedInts::parse(
  s : String,
) -> ST_UnsignedInts raise SchemaViolation {
  validate_ST_UnsignedInts(s)
  { value: s }
}

///|
/// Construct ST_UnsignedInts and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_UnsignedInts::new(
  s : String,
) -> ST_UnsignedInts raise SchemaViolation {
  ST_UnsignedInts::parse(s)
}

///|
/// Return the schema lexical value for ST_UnsignedInts.
pub fn ST_UnsignedInts::to_string(self : ST_UnsignedInts) -> String {
  self.value
}

///|
/// XSD simple type ST_Booleans (§21.4.x).
pub struct ST_Booleans {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_Booleans schema lexical value.
pub fn ST_Booleans::parse(s : String) -> ST_Booleans raise SchemaViolation {
  validate_ST_Booleans(s)
  { value: s }
}

///|
/// Construct ST_Booleans and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_Booleans::new(s : String) -> ST_Booleans raise SchemaViolation {
  ST_Booleans::parse(s)
}

///|
/// Return the schema lexical value for ST_Booleans.
pub fn ST_Booleans::to_string(self : ST_Booleans) -> String {
  self.value
}

///|
/// XSD simple type ST_FunctionType (§21.4.x).
pub(all) enum ST_FunctionType {
  FunctionTypeCnt
  FunctionTypePos
  FunctionTypeRevPos
  FunctionTypePosEven
  FunctionTypePosOdd
  FunctionTypeVar
  FunctionTypeDepth
  FunctionTypeMaxDepth
} derive(Eq, Debug)

///|
/// Parse the ST_FunctionType schema lexical value.
pub fn ST_FunctionType::parse(
  s : String,
) -> ST_FunctionType raise SchemaViolation {
  match s {
    "cnt" => FunctionTypeCnt
    "pos" => FunctionTypePos
    "revPos" => FunctionTypeRevPos
    "posEven" => FunctionTypePosEven
    "posOdd" => FunctionTypePosOdd
    "var" => FunctionTypeVar
    "depth" => FunctionTypeDepth
    "maxDepth" => FunctionTypeMaxDepth
    _ => invalid("ST_FunctionType", s)
  }
}

///|
/// Construct ST_FunctionType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_FunctionType::new(
  s : String,
) -> ST_FunctionType raise SchemaViolation {
  ST_FunctionType::parse(s)
}

///|
/// Return the schema lexical value for ST_FunctionType.
pub fn ST_FunctionType::to_string(self : ST_FunctionType) -> String {
  match self {
    FunctionTypeCnt => "cnt"
    FunctionTypePos => "pos"
    FunctionTypeRevPos => "revPos"
    FunctionTypePosEven => "posEven"
    FunctionTypePosOdd => "posOdd"
    FunctionTypeVar => "var"
    FunctionTypeDepth => "depth"
    FunctionTypeMaxDepth => "maxDepth"
  }
}

///|
/// XSD simple type ST_FunctionOperator (§21.4.x).
pub(all) enum ST_FunctionOperator {
  FunctionOperatorEqu
  FunctionOperatorNeq
  FunctionOperatorGt
  FunctionOperatorLt
  FunctionOperatorGte
  FunctionOperatorLte
} derive(Eq, Debug)

///|
/// Parse the ST_FunctionOperator schema lexical value.
pub fn ST_FunctionOperator::parse(
  s : String,
) -> ST_FunctionOperator raise SchemaViolation {
  match s {
    "equ" => FunctionOperatorEqu
    "neq" => FunctionOperatorNeq
    "gt" => FunctionOperatorGt
    "lt" => FunctionOperatorLt
    "gte" => FunctionOperatorGte
    "lte" => FunctionOperatorLte
    _ => invalid("ST_FunctionOperator", s)
  }
}

///|
/// Construct ST_FunctionOperator and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_FunctionOperator::new(
  s : String,
) -> ST_FunctionOperator raise SchemaViolation {
  ST_FunctionOperator::parse(s)
}

///|
/// Return the schema lexical value for ST_FunctionOperator.
pub fn ST_FunctionOperator::to_string(self : ST_FunctionOperator) -> String {
  match self {
    FunctionOperatorEqu => "equ"
    FunctionOperatorNeq => "neq"
    FunctionOperatorGt => "gt"
    FunctionOperatorLt => "lt"
    FunctionOperatorGte => "gte"
    FunctionOperatorLte => "lte"
  }
}

///|
/// XSD simple type ST_DiagramHorizontalAlignment (§21.4.x).
pub(all) enum ST_DiagramHorizontalAlignment {
  DiagramHorizontalAlignmentL
  DiagramHorizontalAlignmentCtr
  DiagramHorizontalAlignmentR
  DiagramHorizontalAlignmentNone
} derive(Eq, Debug)

///|
/// Parse the ST_DiagramHorizontalAlignment schema lexical value.
pub fn ST_DiagramHorizontalAlignment::parse(
  s : String,
) -> ST_DiagramHorizontalAlignment raise SchemaViolation {
  match s {
    "l" => DiagramHorizontalAlignmentL
    "ctr" => DiagramHorizontalAlignmentCtr
    "r" => DiagramHorizontalAlignmentR
    "none" => DiagramHorizontalAlignmentNone
    _ => invalid("ST_DiagramHorizontalAlignment", s)
  }
}

///|
/// Construct ST_DiagramHorizontalAlignment and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_DiagramHorizontalAlignment::new(
  s : String,
) -> ST_DiagramHorizontalAlignment raise SchemaViolation {
  ST_DiagramHorizontalAlignment::parse(s)
}

///|
/// Return the schema lexical value for ST_DiagramHorizontalAlignment.
pub fn ST_DiagramHorizontalAlignment::to_string(
  self : ST_DiagramHorizontalAlignment,
) -> String {
  match self {
    DiagramHorizontalAlignmentL => "l"
    DiagramHorizontalAlignmentCtr => "ctr"
    DiagramHorizontalAlignmentR => "r"
    DiagramHorizontalAlignmentNone => "none"
  }
}

///|
/// XSD simple type ST_VerticalAlignment (§21.4.x).
pub(all) enum ST_VerticalAlignment {
  VerticalAlignmentT
  VerticalAlignmentMid
  VerticalAlignmentB
  VerticalAlignmentNone
} derive(Eq, Debug)

///|
/// Parse the ST_VerticalAlignment schema lexical value.
pub fn ST_VerticalAlignment::parse(
  s : String,
) -> ST_VerticalAlignment raise SchemaViolation {
  match s {
    "t" => VerticalAlignmentT
    "mid" => VerticalAlignmentMid
    "b" => VerticalAlignmentB
    "none" => VerticalAlignmentNone
    _ => invalid("ST_VerticalAlignment", s)
  }
}

///|
/// Construct ST_VerticalAlignment and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_VerticalAlignment::new(
  s : String,
) -> ST_VerticalAlignment raise SchemaViolation {
  ST_VerticalAlignment::parse(s)
}

///|
/// Return the schema lexical value for ST_VerticalAlignment.
pub fn ST_VerticalAlignment::to_string(self : ST_VerticalAlignment) -> String {
  match self {
    VerticalAlignmentT => "t"
    VerticalAlignmentMid => "mid"
    VerticalAlignmentB => "b"
    VerticalAlignmentNone => "none"
  }
}

///|
/// XSD simple type ST_ChildDirection (§21.4.x).
pub(all) enum ST_ChildDirection {
  ChildDirectionHorz
  ChildDirectionVert
} derive(Eq, Debug)

///|
/// Parse the ST_ChildDirection schema lexical value.
pub fn ST_ChildDirection::parse(
  s : String,
) -> ST_ChildDirection raise SchemaViolation {
  match s {
    "horz" => ChildDirectionHorz
    "vert" => ChildDirectionVert
    _ => invalid("ST_ChildDirection", s)
  }
}

///|
/// Construct ST_ChildDirection and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ChildDirection::new(
  s : String,
) -> ST_ChildDirection raise SchemaViolation {
  ST_ChildDirection::parse(s)
}

///|
/// Return the schema lexical value for ST_ChildDirection.
pub fn ST_ChildDirection::to_string(self : ST_ChildDirection) -> String {
  match self {
    ChildDirectionHorz => "horz"
    ChildDirectionVert => "vert"
  }
}

///|
/// XSD simple type ST_ChildAlignment (§21.4.x).
pub(all) enum ST_ChildAlignment {
  ChildAlignmentT
  ChildAlignmentB
  ChildAlignmentL
  ChildAlignmentR
} derive(Eq, Debug)

///|
/// Parse the ST_ChildAlignment schema lexical value.
pub fn ST_ChildAlignment::parse(
  s : String,
) -> ST_ChildAlignment raise SchemaViolation {
  match s {
    "t" => ChildAlignmentT
    "b" => ChildAlignmentB
    "l" => ChildAlignmentL
    "r" => ChildAlignmentR
    _ => invalid("ST_ChildAlignment", s)
  }
}

///|
/// Construct ST_ChildAlignment and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ChildAlignment::new(
  s : String,
) -> ST_ChildAlignment raise SchemaViolation {
  ST_ChildAlignment::parse(s)
}

///|
/// Return the schema lexical value for ST_ChildAlignment.
pub fn ST_ChildAlignment::to_string(self : ST_ChildAlignment) -> String {
  match self {
    ChildAlignmentT => "t"
    ChildAlignmentB => "b"
    ChildAlignmentL => "l"
    ChildAlignmentR => "r"
  }
}

///|
/// XSD simple type ST_SecondaryChildAlignment (§21.4.x).
pub(all) enum ST_SecondaryChildAlignment {
  SecondaryChildAlignmentNone
  SecondaryChildAlignmentT
  SecondaryChildAlignmentB
  SecondaryChildAlignmentL
  SecondaryChildAlignmentR
} derive(Eq, Debug)

///|
/// Parse the ST_SecondaryChildAlignment schema lexical value.
pub fn ST_SecondaryChildAlignment::parse(
  s : String,
) -> ST_SecondaryChildAlignment raise SchemaViolation {
  match s {
    "none" => SecondaryChildAlignmentNone
    "t" => SecondaryChildAlignmentT
    "b" => SecondaryChildAlignmentB
    "l" => SecondaryChildAlignmentL
    "r" => SecondaryChildAlignmentR
    _ => invalid("ST_SecondaryChildAlignment", s)
  }
}

///|
/// Construct ST_SecondaryChildAlignment and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_SecondaryChildAlignment::new(
  s : String,
) -> ST_SecondaryChildAlignment raise SchemaViolation {
  ST_SecondaryChildAlignment::parse(s)
}

///|
/// Return the schema lexical value for ST_SecondaryChildAlignment.
pub fn ST_SecondaryChildAlignment::to_string(
  self : ST_SecondaryChildAlignment,
) -> String {
  match self {
    SecondaryChildAlignmentNone => "none"
    SecondaryChildAlignmentT => "t"
    SecondaryChildAlignmentB => "b"
    SecondaryChildAlignmentL => "l"
    SecondaryChildAlignmentR => "r"
  }
}

///|
/// XSD simple type ST_LinearDirection (§21.4.x).
pub(all) enum ST_LinearDirection {
  LinearDirectionFromL
  LinearDirectionFromR
  LinearDirectionFromT
  LinearDirectionFromB
} derive(Eq, Debug)

///|
/// Parse the ST_LinearDirection schema lexical value.
pub fn ST_LinearDirection::parse(
  s : String,
) -> ST_LinearDirection raise SchemaViolation {
  match s {
    "fromL" => LinearDirectionFromL
    "fromR" => LinearDirectionFromR
    "fromT" => LinearDirectionFromT
    "fromB" => LinearDirectionFromB
    _ => invalid("ST_LinearDirection", s)
  }
}

///|
/// Construct ST_LinearDirection and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_LinearDirection::new(
  s : String,
) -> ST_LinearDirection raise SchemaViolation {
  ST_LinearDirection::parse(s)
}

///|
/// Return the schema lexical value for ST_LinearDirection.
pub fn ST_LinearDirection::to_string(self : ST_LinearDirection) -> String {
  match self {
    LinearDirectionFromL => "fromL"
    LinearDirectionFromR => "fromR"
    LinearDirectionFromT => "fromT"
    LinearDirectionFromB => "fromB"
  }
}

///|
/// XSD simple type ST_SecondaryLinearDirection (§21.4.x).
pub(all) enum ST_SecondaryLinearDirection {
  SecondaryLinearDirectionNone
  SecondaryLinearDirectionFromL
  SecondaryLinearDirectionFromR
  SecondaryLinearDirectionFromT
  SecondaryLinearDirectionFromB
} derive(Eq, Debug)

///|
/// Parse the ST_SecondaryLinearDirection schema lexical value.
pub fn ST_SecondaryLinearDirection::parse(
  s : String,
) -> ST_SecondaryLinearDirection raise SchemaViolation {
  match s {
    "none" => SecondaryLinearDirectionNone
    "fromL" => SecondaryLinearDirectionFromL
    "fromR" => SecondaryLinearDirectionFromR
    "fromT" => SecondaryLinearDirectionFromT
    "fromB" => SecondaryLinearDirectionFromB
    _ => invalid("ST_SecondaryLinearDirection", s)
  }
}

///|
/// Construct ST_SecondaryLinearDirection and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_SecondaryLinearDirection::new(
  s : String,
) -> ST_SecondaryLinearDirection raise SchemaViolation {
  ST_SecondaryLinearDirection::parse(s)
}

///|
/// Return the schema lexical value for ST_SecondaryLinearDirection.
pub fn ST_SecondaryLinearDirection::to_string(
  self : ST_SecondaryLinearDirection,
) -> String {
  match self {
    SecondaryLinearDirectionNone => "none"
    SecondaryLinearDirectionFromL => "fromL"
    SecondaryLinearDirectionFromR => "fromR"
    SecondaryLinearDirectionFromT => "fromT"
    SecondaryLinearDirectionFromB => "fromB"
  }
}

///|
/// XSD simple type ST_StartingElement (§21.4.x).
pub(all) enum ST_StartingElement {
  StartingElementNode
  StartingElementTrans
} derive(Eq, Debug)

///|
/// Parse the ST_StartingElement schema lexical value.
pub fn ST_StartingElement::parse(
  s : String,
) -> ST_StartingElement raise SchemaViolation {
  match s {
    "node" => StartingElementNode
    "trans" => StartingElementTrans
    _ => invalid("ST_StartingElement", s)
  }
}

///|
/// Construct ST_StartingElement and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_StartingElement::new(
  s : String,
) -> ST_StartingElement raise SchemaViolation {
  ST_StartingElement::parse(s)
}

///|
/// Return the schema lexical value for ST_StartingElement.
pub fn ST_StartingElement::to_string(self : ST_StartingElement) -> String {
  match self {
    StartingElementNode => "node"
    StartingElementTrans => "trans"
  }
}

///|
/// XSD simple type ST_RotationPath (§21.4.x).
pub(all) enum ST_RotationPath {
  RotationPathNone
  RotationPathAlongPath
} derive(Eq, Debug)

///|
/// Parse the ST_RotationPath schema lexical value.
pub fn ST_RotationPath::parse(
  s : String,
) -> ST_RotationPath raise SchemaViolation {
  match s {
    "none" => RotationPathNone
    "alongPath" => RotationPathAlongPath
    _ => invalid("ST_RotationPath", s)
  }
}

///|
/// Construct ST_RotationPath and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_RotationPath::new(
  s : String,
) -> ST_RotationPath raise SchemaViolation {
  ST_RotationPath::parse(s)
}

///|
/// Return the schema lexical value for ST_RotationPath.
pub fn ST_RotationPath::to_string(self : ST_RotationPath) -> String {
  match self {
    RotationPathNone => "none"
    RotationPathAlongPath => "alongPath"
  }
}

///|
/// XSD simple type ST_CenterShapeMapping (§21.4.x).
pub(all) enum ST_CenterShapeMapping {
  CenterShapeMappingNone
  CenterShapeMappingFNode
} derive(Eq, Debug)

///|
/// Parse the ST_CenterShapeMapping schema lexical value.
pub fn ST_CenterShapeMapping::parse(
  s : String,
) -> ST_CenterShapeMapping raise SchemaViolation {
  match s {
    "none" => CenterShapeMappingNone
    "fNode" => CenterShapeMappingFNode
    _ => invalid("ST_CenterShapeMapping", s)
  }
}

///|
/// Construct ST_CenterShapeMapping and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_CenterShapeMapping::new(
  s : String,
) -> ST_CenterShapeMapping raise SchemaViolation {
  ST_CenterShapeMapping::parse(s)
}

///|
/// Return the schema lexical value for ST_CenterShapeMapping.
pub fn ST_CenterShapeMapping::to_string(self : ST_CenterShapeMapping) -> String {
  match self {
    CenterShapeMappingNone => "none"
    CenterShapeMappingFNode => "fNode"
  }
}

///|
/// XSD simple type ST_BendPoint (§21.4.x).
pub(all) enum ST_BendPoint {
  BendPointBeg
  BendPointDef
  BendPointEnd
} derive(Eq, Debug)

///|
/// Parse the ST_BendPoint schema lexical value.
pub fn ST_BendPoint::parse(s : String) -> ST_BendPoint raise SchemaViolation {
  match s {
    "beg" => BendPointBeg
    "def" => BendPointDef
    "end" => BendPointEnd
    _ => invalid("ST_BendPoint", s)
  }
}

///|
/// Construct ST_BendPoint and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_BendPoint::new(s : String) -> ST_BendPoint raise SchemaViolation {
  ST_BendPoint::parse(s)
}

///|
/// Return the schema lexical value for ST_BendPoint.
pub fn ST_BendPoint::to_string(self : ST_BendPoint) -> String {
  match self {
    BendPointBeg => "beg"
    BendPointDef => "def"
    BendPointEnd => "end"
  }
}

///|
/// XSD simple type ST_ConnectorRouting (§21.4.x).
pub(all) enum ST_ConnectorRouting {
  ConnectorRoutingStra
  ConnectorRoutingBend
  ConnectorRoutingCurve
  ConnectorRoutingLongCurve
} derive(Eq, Debug)

///|
/// Parse the ST_ConnectorRouting schema lexical value.
pub fn ST_ConnectorRouting::parse(
  s : String,
) -> ST_ConnectorRouting raise SchemaViolation {
  match s {
    "stra" => ConnectorRoutingStra
    "bend" => ConnectorRoutingBend
    "curve" => ConnectorRoutingCurve
    "longCurve" => ConnectorRoutingLongCurve
    _ => invalid("ST_ConnectorRouting", s)
  }
}

///|
/// Construct ST_ConnectorRouting and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ConnectorRouting::new(
  s : String,
) -> ST_ConnectorRouting raise SchemaViolation {
  ST_ConnectorRouting::parse(s)
}

///|
/// Return the schema lexical value for ST_ConnectorRouting.
pub fn ST_ConnectorRouting::to_string(self : ST_ConnectorRouting) -> String {
  match self {
    ConnectorRoutingStra => "stra"
    ConnectorRoutingBend => "bend"
    ConnectorRoutingCurve => "curve"
    ConnectorRoutingLongCurve => "longCurve"
  }
}

///|
/// XSD simple type ST_ArrowheadStyle (§21.4.x).
pub(all) enum ST_ArrowheadStyle {
  ArrowheadStyleAuto
  ArrowheadStyleArr
  ArrowheadStyleNoArr
} derive(Eq, Debug)

///|
/// Parse the ST_ArrowheadStyle schema lexical value.
pub fn ST_ArrowheadStyle::parse(
  s : String,
) -> ST_ArrowheadStyle raise SchemaViolation {
  match s {
    "auto" => ArrowheadStyleAuto
    "arr" => ArrowheadStyleArr
    "noArr" => ArrowheadStyleNoArr
    _ => invalid("ST_ArrowheadStyle", s)
  }
}

///|
/// Construct ST_ArrowheadStyle and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ArrowheadStyle::new(
  s : String,
) -> ST_ArrowheadStyle raise SchemaViolation {
  ST_ArrowheadStyle::parse(s)
}

///|
/// Return the schema lexical value for ST_ArrowheadStyle.
pub fn ST_ArrowheadStyle::to_string(self : ST_ArrowheadStyle) -> String {
  match self {
    ArrowheadStyleAuto => "auto"
    ArrowheadStyleArr => "arr"
    ArrowheadStyleNoArr => "noArr"
  }
}

///|
/// XSD simple type ST_ConnectorDimension (§21.4.x).
pub(all) enum ST_ConnectorDimension {
  ConnectorDimensionOneD
  ConnectorDimensionTwoD
  ConnectorDimensionCust
} derive(Eq, Debug)

///|
/// Parse the ST_ConnectorDimension schema lexical value.
pub fn ST_ConnectorDimension::parse(
  s : String,
) -> ST_ConnectorDimension raise SchemaViolation {
  match s {
    "1D" => ConnectorDimensionOneD
    "2D" => ConnectorDimensionTwoD
    "cust" => ConnectorDimensionCust
    _ => invalid("ST_ConnectorDimension", s)
  }
}

///|
/// Construct ST_ConnectorDimension and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ConnectorDimension::new(
  s : String,
) -> ST_ConnectorDimension raise SchemaViolation {
  ST_ConnectorDimension::parse(s)
}

///|
/// Return the schema lexical value for ST_ConnectorDimension.
pub fn ST_ConnectorDimension::to_string(self : ST_ConnectorDimension) -> String {
  match self {
    ConnectorDimensionOneD => "1D"
    ConnectorDimensionTwoD => "2D"
    ConnectorDimensionCust => "cust"
  }
}

///|
/// XSD simple type ST_ConnectorPoint (§21.4.x).
pub(all) enum ST_ConnectorPoint {
  ConnectorPointAuto
  ConnectorPointBCtr
  ConnectorPointCtr
  ConnectorPointMidL
  ConnectorPointMidR
  ConnectorPointTCtr
  ConnectorPointBL
  ConnectorPointBR
  ConnectorPointTL
  ConnectorPointTR
  ConnectorPointRadial
} derive(Eq, Debug)

///|
/// Parse the ST_ConnectorPoint schema lexical value.
pub fn ST_ConnectorPoint::parse(
  s : String,
) -> ST_ConnectorPoint raise SchemaViolation {
  match s {
    "auto" => ConnectorPointAuto
    "bCtr" => ConnectorPointBCtr
    "ctr" => ConnectorPointCtr
    "midL" => ConnectorPointMidL
    "midR" => ConnectorPointMidR
    "tCtr" => ConnectorPointTCtr
    "bL" => ConnectorPointBL
    "bR" => ConnectorPointBR
    "tL" => ConnectorPointTL
    "tR" => ConnectorPointTR
    "radial" => ConnectorPointRadial
    _ => invalid("ST_ConnectorPoint", s)
  }
}

///|
/// Construct ST_ConnectorPoint and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ConnectorPoint::new(
  s : String,
) -> ST_ConnectorPoint raise SchemaViolation {
  ST_ConnectorPoint::parse(s)
}

///|
/// Return the schema lexical value for ST_ConnectorPoint.
pub fn ST_ConnectorPoint::to_string(self : ST_ConnectorPoint) -> String {
  match self {
    ConnectorPointAuto => "auto"
    ConnectorPointBCtr => "bCtr"
    ConnectorPointCtr => "ctr"
    ConnectorPointMidL => "midL"
    ConnectorPointMidR => "midR"
    ConnectorPointTCtr => "tCtr"
    ConnectorPointBL => "bL"
    ConnectorPointBR => "bR"
    ConnectorPointTL => "tL"
    ConnectorPointTR => "tR"
    ConnectorPointRadial => "radial"
  }
}

///|
/// XSD simple type ST_NodeHorizontalAlignment (§21.4.x).
pub(all) enum ST_NodeHorizontalAlignment {
  NodeHorizontalAlignmentL
  NodeHorizontalAlignmentCtr
  NodeHorizontalAlignmentR
} derive(Eq, Debug)

///|
/// Parse the ST_NodeHorizontalAlignment schema lexical value.
pub fn ST_NodeHorizontalAlignment::parse(
  s : String,
) -> ST_NodeHorizontalAlignment raise SchemaViolation {
  match s {
    "l" => NodeHorizontalAlignmentL
    "ctr" => NodeHorizontalAlignmentCtr
    "r" => NodeHorizontalAlignmentR
    _ => invalid("ST_NodeHorizontalAlignment", s)
  }
}

///|
/// Construct ST_NodeHorizontalAlignment and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_NodeHorizontalAlignment::new(
  s : String,
) -> ST_NodeHorizontalAlignment raise SchemaViolation {
  ST_NodeHorizontalAlignment::parse(s)
}

///|
/// Return the schema lexical value for ST_NodeHorizontalAlignment.
pub fn ST_NodeHorizontalAlignment::to_string(
  self : ST_NodeHorizontalAlignment,
) -> String {
  match self {
    NodeHorizontalAlignmentL => "l"
    NodeHorizontalAlignmentCtr => "ctr"
    NodeHorizontalAlignmentR => "r"
  }
}

///|
/// XSD simple type ST_NodeVerticalAlignment (§21.4.x).
pub(all) enum ST_NodeVerticalAlignment {
  NodeVerticalAlignmentT
  NodeVerticalAlignmentMid
  NodeVerticalAlignmentB
} derive(Eq, Debug)

///|
/// Parse the ST_NodeVerticalAlignment schema lexical value.
pub fn ST_NodeVerticalAlignment::parse(
  s : String,
) -> ST_NodeVerticalAlignment raise SchemaViolation {
  match s {
    "t" => NodeVerticalAlignmentT
    "mid" => NodeVerticalAlignmentMid
    "b" => NodeVerticalAlignmentB
    _ => invalid("ST_NodeVerticalAlignment", s)
  }
}

///|
/// Construct ST_NodeVerticalAlignment and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_NodeVerticalAlignment::new(
  s : String,
) -> ST_NodeVerticalAlignment raise SchemaViolation {
  ST_NodeVerticalAlignment::parse(s)
}

///|
/// Return the schema lexical value for ST_NodeVerticalAlignment.
pub fn ST_NodeVerticalAlignment::to_string(
  self : ST_NodeVerticalAlignment,
) -> String {
  match self {
    NodeVerticalAlignmentT => "t"
    NodeVerticalAlignmentMid => "mid"
    NodeVerticalAlignmentB => "b"
  }
}

///|
/// XSD simple type ST_FallbackDimension (§21.4.x).
pub(all) enum ST_FallbackDimension {
  FallbackDimensionOneD
  FallbackDimensionTwoD
} derive(Eq, Debug)

///|
/// Parse the ST_FallbackDimension schema lexical value.
pub fn ST_FallbackDimension::parse(
  s : String,
) -> ST_FallbackDimension raise SchemaViolation {
  match s {
    "1D" => FallbackDimensionOneD
    "2D" => FallbackDimensionTwoD
    _ => invalid("ST_FallbackDimension", s)
  }
}

///|
/// Construct ST_FallbackDimension and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_FallbackDimension::new(
  s : String,
) -> ST_FallbackDimension raise SchemaViolation {
  ST_FallbackDimension::parse(s)
}

///|
/// Return the schema lexical value for ST_FallbackDimension.
pub fn ST_FallbackDimension::to_string(self : ST_FallbackDimension) -> String {
  match self {
    FallbackDimensionOneD => "1D"
    FallbackDimensionTwoD => "2D"
  }
}

///|
/// XSD simple type ST_TextDirection (§21.4.x).
pub(all) enum ST_TextDirection {
  TextDirectionFromT
  TextDirectionFromB
} derive(Eq, Debug)

///|
/// Parse the ST_TextDirection schema lexical value.
pub fn ST_TextDirection::parse(
  s : String,
) -> ST_TextDirection raise SchemaViolation {
  match s {
    "fromT" => TextDirectionFromT
    "fromB" => TextDirectionFromB
    _ => invalid("ST_TextDirection", s)
  }
}

///|
/// Construct ST_TextDirection and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_TextDirection::new(
  s : String,
) -> ST_TextDirection raise SchemaViolation {
  ST_TextDirection::parse(s)
}

///|
/// Return the schema lexical value for ST_TextDirection.
pub fn ST_TextDirection::to_string(self : ST_TextDirection) -> String {
  match self {
    TextDirectionFromT => "fromT"
    TextDirectionFromB => "fromB"
  }
}

///|
/// XSD simple type ST_PyramidAccentPosition (§21.4.x).
pub(all) enum ST_PyramidAccentPosition {
  PyramidAccentPositionBef
  PyramidAccentPositionAft
} derive(Eq, Debug)

///|
/// Parse the ST_PyramidAccentPosition schema lexical value.
pub fn ST_PyramidAccentPosition::parse(
  s : String,
) -> ST_PyramidAccentPosition raise SchemaViolation {
  match s {
    "bef" => PyramidAccentPositionBef
    "aft" => PyramidAccentPositionAft
    _ => invalid("ST_PyramidAccentPosition", s)
  }
}

///|
/// Construct ST_PyramidAccentPosition and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_PyramidAccentPosition::new(
  s : String,
) -> ST_PyramidAccentPosition raise SchemaViolation {
  ST_PyramidAccentPosition::parse(s)
}

///|
/// Return the schema lexical value for ST_PyramidAccentPosition.
pub fn ST_PyramidAccentPosition::to_string(
  self : ST_PyramidAccentPosition,
) -> String {
  match self {
    PyramidAccentPositionBef => "bef"
    PyramidAccentPositionAft => "aft"
  }
}

///|
/// XSD simple type ST_PyramidAccentTextMargin (§21.4.x).
pub(all) enum ST_PyramidAccentTextMargin {
  PyramidAccentTextMarginStep
  PyramidAccentTextMarginStack
} derive(Eq, Debug)

///|
/// Parse the ST_PyramidAccentTextMargin schema lexical value.
pub fn ST_PyramidAccentTextMargin::parse(
  s : String,
) -> ST_PyramidAccentTextMargin raise SchemaViolation {
  match s {
    "step" => PyramidAccentTextMarginStep
    "stack" => PyramidAccentTextMarginStack
    _ => invalid("ST_PyramidAccentTextMargin", s)
  }
}

///|
/// Construct ST_PyramidAccentTextMargin and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_PyramidAccentTextMargin::new(
  s : String,
) -> ST_PyramidAccentTextMargin raise SchemaViolation {
  ST_PyramidAccentTextMargin::parse(s)
}

///|
/// Return the schema lexical value for ST_PyramidAccentTextMargin.
pub fn ST_PyramidAccentTextMargin::to_string(
  self : ST_PyramidAccentTextMargin,
) -> String {
  match self {
    PyramidAccentTextMarginStep => "step"
    PyramidAccentTextMarginStack => "stack"
  }
}

///|
/// XSD simple type ST_TextBlockDirection (§21.4.x).
pub(all) enum ST_TextBlockDirection {
  TextBlockDirectionHorz
  TextBlockDirectionVert
} derive(Eq, Debug)

///|
/// Parse the ST_TextBlockDirection schema lexical value.
pub fn ST_TextBlockDirection::parse(
  s : String,
) -> ST_TextBlockDirection raise SchemaViolation {
  match s {
    "horz" => TextBlockDirectionHorz
    "vert" => TextBlockDirectionVert
    _ => invalid("ST_TextBlockDirection", s)
  }
}

///|
/// Construct ST_TextBlockDirection and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_TextBlockDirection::new(
  s : String,
) -> ST_TextBlockDirection raise SchemaViolation {
  ST_TextBlockDirection::parse(s)
}

///|
/// Return the schema lexical value for ST_TextBlockDirection.
pub fn ST_TextBlockDirection::to_string(self : ST_TextBlockDirection) -> String {
  match self {
    TextBlockDirectionHorz => "horz"
    TextBlockDirectionVert => "vert"
  }
}

///|
/// XSD simple type ST_TextAnchorHorizontal (§21.4.x).
pub(all) enum ST_TextAnchorHorizontal {
  TextAnchorHorizontalNone
  TextAnchorHorizontalCtr
} derive(Eq, Debug)

///|
/// Parse the ST_TextAnchorHorizontal schema lexical value.
pub fn ST_TextAnchorHorizontal::parse(
  s : String,
) -> ST_TextAnchorHorizontal raise SchemaViolation {
  match s {
    "none" => TextAnchorHorizontalNone
    "ctr" => TextAnchorHorizontalCtr
    _ => invalid("ST_TextAnchorHorizontal", s)
  }
}

///|
/// Construct ST_TextAnchorHorizontal and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_TextAnchorHorizontal::new(
  s : String,
) -> ST_TextAnchorHorizontal raise SchemaViolation {
  ST_TextAnchorHorizontal::parse(s)
}

///|
/// Return the schema lexical value for ST_TextAnchorHorizontal.
pub fn ST_TextAnchorHorizontal::to_string(
  self : ST_TextAnchorHorizontal,
) -> String {
  match self {
    TextAnchorHorizontalNone => "none"
    TextAnchorHorizontalCtr => "ctr"
  }
}

///|
/// XSD simple type ST_TextAnchorVertical (§21.4.x).
pub(all) enum ST_TextAnchorVertical {
  TextAnchorVerticalT
  TextAnchorVerticalMid
  TextAnchorVerticalB
} derive(Eq, Debug)

///|
/// Parse the ST_TextAnchorVertical schema lexical value.
pub fn ST_TextAnchorVertical::parse(
  s : String,
) -> ST_TextAnchorVertical raise SchemaViolation {
  match s {
    "t" => TextAnchorVerticalT
    "mid" => TextAnchorVerticalMid
    "b" => TextAnchorVerticalB
    _ => invalid("ST_TextAnchorVertical", s)
  }
}

///|
/// Construct ST_TextAnchorVertical and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_TextAnchorVertical::new(
  s : String,
) -> ST_TextAnchorVertical raise SchemaViolation {
  ST_TextAnchorVertical::parse(s)
}

///|
/// Return the schema lexical value for ST_TextAnchorVertical.
pub fn ST_TextAnchorVertical::to_string(self : ST_TextAnchorVertical) -> String {
  match self {
    TextAnchorVerticalT => "t"
    TextAnchorVerticalMid => "mid"
    TextAnchorVerticalB => "b"
  }
}

///|
/// XSD simple type ST_DiagramTextAlignment (§21.4.x).
pub(all) enum ST_DiagramTextAlignment {
  DiagramTextAlignmentL
  DiagramTextAlignmentCtr
  DiagramTextAlignmentR
} derive(Eq, Debug)

///|
/// Parse the ST_DiagramTextAlignment schema lexical value.
pub fn ST_DiagramTextAlignment::parse(
  s : String,
) -> ST_DiagramTextAlignment raise SchemaViolation {
  match s {
    "l" => DiagramTextAlignmentL
    "ctr" => DiagramTextAlignmentCtr
    "r" => DiagramTextAlignmentR
    _ => invalid("ST_DiagramTextAlignment", s)
  }
}

///|
/// Construct ST_DiagramTextAlignment and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_DiagramTextAlignment::new(
  s : String,
) -> ST_DiagramTextAlignment raise SchemaViolation {
  ST_DiagramTextAlignment::parse(s)
}

///|
/// Return the schema lexical value for ST_DiagramTextAlignment.
pub fn ST_DiagramTextAlignment::to_string(
  self : ST_DiagramTextAlignment,
) -> String {
  match self {
    DiagramTextAlignmentL => "l"
    DiagramTextAlignmentCtr => "ctr"
    DiagramTextAlignmentR => "r"
  }
}

///|
/// XSD simple type ST_AutoTextRotation (§21.4.x).
pub(all) enum ST_AutoTextRotation {
  AutoTextRotationNone
  AutoTextRotationUpr
  AutoTextRotationGrav
} derive(Eq, Debug)

///|
/// Parse the ST_AutoTextRotation schema lexical value.
pub fn ST_AutoTextRotation::parse(
  s : String,
) -> ST_AutoTextRotation raise SchemaViolation {
  match s {
    "none" => AutoTextRotationNone
    "upr" => AutoTextRotationUpr
    "grav" => AutoTextRotationGrav
    _ => invalid("ST_AutoTextRotation", s)
  }
}

///|
/// Construct ST_AutoTextRotation and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_AutoTextRotation::new(
  s : String,
) -> ST_AutoTextRotation raise SchemaViolation {
  ST_AutoTextRotation::parse(s)
}

///|
/// Return the schema lexical value for ST_AutoTextRotation.
pub fn ST_AutoTextRotation::to_string(self : ST_AutoTextRotation) -> String {
  match self {
    AutoTextRotationNone => "none"
    AutoTextRotationUpr => "upr"
    AutoTextRotationGrav => "grav"
  }
}

///|
/// XSD simple type ST_GrowDirection (§21.4.x).
pub(all) enum ST_GrowDirection {
  GrowDirectionTL
  GrowDirectionTR
  GrowDirectionBL
  GrowDirectionBR
} derive(Eq, Debug)

///|
/// Parse the ST_GrowDirection schema lexical value.
pub fn ST_GrowDirection::parse(
  s : String,
) -> ST_GrowDirection raise SchemaViolation {
  match s {
    "tL" => GrowDirectionTL
    "tR" => GrowDirectionTR
    "bL" => GrowDirectionBL
    "bR" => GrowDirectionBR
    _ => invalid("ST_GrowDirection", s)
  }
}

///|
/// Construct ST_GrowDirection and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_GrowDirection::new(
  s : String,
) -> ST_GrowDirection raise SchemaViolation {
  ST_GrowDirection::parse(s)
}

///|
/// Return the schema lexical value for ST_GrowDirection.
pub fn ST_GrowDirection::to_string(self : ST_GrowDirection) -> String {
  match self {
    GrowDirectionTL => "tL"
    GrowDirectionTR => "tR"
    GrowDirectionBL => "bL"
    GrowDirectionBR => "bR"
  }
}

///|
/// XSD simple type ST_FlowDirection (§21.4.x).
pub(all) enum ST_FlowDirection {
  FlowDirectionRow
  FlowDirectionCol
} derive(Eq, Debug)

///|
/// Parse the ST_FlowDirection schema lexical value.
pub fn ST_FlowDirection::parse(
  s : String,
) -> ST_FlowDirection raise SchemaViolation {
  match s {
    "row" => FlowDirectionRow
    "col" => FlowDirectionCol
    _ => invalid("ST_FlowDirection", s)
  }
}

///|
/// Construct ST_FlowDirection and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_FlowDirection::new(
  s : String,
) -> ST_FlowDirection raise SchemaViolation {
  ST_FlowDirection::parse(s)
}

///|
/// Return the schema lexical value for ST_FlowDirection.
pub fn ST_FlowDirection::to_string(self : ST_FlowDirection) -> String {
  match self {
    FlowDirectionRow => "row"
    FlowDirectionCol => "col"
  }
}

///|
/// XSD simple type ST_ContinueDirection (§21.4.x).
pub(all) enum ST_ContinueDirection {
  ContinueDirectionRevDir
  ContinueDirectionSameDir
} derive(Eq, Debug)

///|
/// Parse the ST_ContinueDirection schema lexical value.
pub fn ST_ContinueDirection::parse(
  s : String,
) -> ST_ContinueDirection raise SchemaViolation {
  match s {
    "revDir" => ContinueDirectionRevDir
    "sameDir" => ContinueDirectionSameDir
    _ => invalid("ST_ContinueDirection", s)
  }
}

///|
/// Construct ST_ContinueDirection and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ContinueDirection::new(
  s : String,
) -> ST_ContinueDirection raise SchemaViolation {
  ST_ContinueDirection::parse(s)
}

///|
/// Return the schema lexical value for ST_ContinueDirection.
pub fn ST_ContinueDirection::to_string(self : ST_ContinueDirection) -> String {
  match self {
    ContinueDirectionRevDir => "revDir"
    ContinueDirectionSameDir => "sameDir"
  }
}

///|
/// XSD simple type ST_Breakpoint (§21.4.x).
pub(all) enum ST_Breakpoint {
  BreakpointEndCnv
  BreakpointBal
  BreakpointFixed
} derive(Eq, Debug)

///|
/// Parse the ST_Breakpoint schema lexical value.
pub fn ST_Breakpoint::parse(s : String) -> ST_Breakpoint raise SchemaViolation {
  match s {
    "endCnv" => BreakpointEndCnv
    "bal" => BreakpointBal
    "fixed" => BreakpointFixed
    _ => invalid("ST_Breakpoint", s)
  }
}

///|
/// Construct ST_Breakpoint and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_Breakpoint::new(s : String) -> ST_Breakpoint raise SchemaViolation {
  ST_Breakpoint::parse(s)
}

///|
/// Return the schema lexical value for ST_Breakpoint.
pub fn ST_Breakpoint::to_string(self : ST_Breakpoint) -> String {
  match self {
    BreakpointEndCnv => "endCnv"
    BreakpointBal => "bal"
    BreakpointFixed => "fixed"
  }
}

///|
/// XSD simple type ST_Offset (§21.4.x).
pub(all) enum ST_Offset {
  OffsetCtr
  OffsetOff
} derive(Eq, Debug)

///|
/// Parse the ST_Offset schema lexical value.
pub fn ST_Offset::parse(s : String) -> ST_Offset raise SchemaViolation {
  match s {
    "ctr" => OffsetCtr
    "off" => OffsetOff
    _ => invalid("ST_Offset", s)
  }
}

///|
/// Construct ST_Offset and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_Offset::new(s : String) -> ST_Offset raise SchemaViolation {
  ST_Offset::parse(s)
}

///|
/// Return the schema lexical value for ST_Offset.
pub fn ST_Offset::to_string(self : ST_Offset) -> String {
  match self {
    OffsetCtr => "ctr"
    OffsetOff => "off"
  }
}

///|
/// XSD simple type ST_HierarchyAlignment (§21.4.x).
pub(all) enum ST_HierarchyAlignment {
  HierarchyAlignmentTL
  HierarchyAlignmentTR
  HierarchyAlignmentTCtrCh
  HierarchyAlignmentTCtrDes
  HierarchyAlignmentBL
  HierarchyAlignmentBR
  HierarchyAlignmentBCtrCh
  HierarchyAlignmentBCtrDes
  HierarchyAlignmentLT
  HierarchyAlignmentLB
  HierarchyAlignmentLCtrCh
  HierarchyAlignmentLCtrDes
  HierarchyAlignmentRT
  HierarchyAlignmentRB
  HierarchyAlignmentRCtrCh
  HierarchyAlignmentRCtrDes
} derive(Eq, Debug)

///|
/// Parse the ST_HierarchyAlignment schema lexical value.
pub fn ST_HierarchyAlignment::parse(
  s : String,
) -> ST_HierarchyAlignment raise SchemaViolation {
  match s {
    "tL" => HierarchyAlignmentTL
    "tR" => HierarchyAlignmentTR
    "tCtrCh" => HierarchyAlignmentTCtrCh
    "tCtrDes" => HierarchyAlignmentTCtrDes
    "bL" => HierarchyAlignmentBL
    "bR" => HierarchyAlignmentBR
    "bCtrCh" => HierarchyAlignmentBCtrCh
    "bCtrDes" => HierarchyAlignmentBCtrDes
    "lT" => HierarchyAlignmentLT
    "lB" => HierarchyAlignmentLB
    "lCtrCh" => HierarchyAlignmentLCtrCh
    "lCtrDes" => HierarchyAlignmentLCtrDes
    "rT" => HierarchyAlignmentRT
    "rB" => HierarchyAlignmentRB
    "rCtrCh" => HierarchyAlignmentRCtrCh
    "rCtrDes" => HierarchyAlignmentRCtrDes
    _ => invalid("ST_HierarchyAlignment", s)
  }
}

///|
/// Construct ST_HierarchyAlignment and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_HierarchyAlignment::new(
  s : String,
) -> ST_HierarchyAlignment raise SchemaViolation {
  ST_HierarchyAlignment::parse(s)
}

///|
/// Return the schema lexical value for ST_HierarchyAlignment.
pub fn ST_HierarchyAlignment::to_string(self : ST_HierarchyAlignment) -> String {
  match self {
    HierarchyAlignmentTL => "tL"
    HierarchyAlignmentTR => "tR"
    HierarchyAlignmentTCtrCh => "tCtrCh"
    HierarchyAlignmentTCtrDes => "tCtrDes"
    HierarchyAlignmentBL => "bL"
    HierarchyAlignmentBR => "bR"
    HierarchyAlignmentBCtrCh => "bCtrCh"
    HierarchyAlignmentBCtrDes => "bCtrDes"
    HierarchyAlignmentLT => "lT"
    HierarchyAlignmentLB => "lB"
    HierarchyAlignmentLCtrCh => "lCtrCh"
    HierarchyAlignmentLCtrDes => "lCtrDes"
    HierarchyAlignmentRT => "rT"
    HierarchyAlignmentRB => "rB"
    HierarchyAlignmentRCtrCh => "rCtrCh"
    HierarchyAlignmentRCtrDes => "rCtrDes"
  }
}

///|
/// XSD simple type ST_FunctionValue (§21.4.x).
pub struct ST_FunctionValue {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_FunctionValue schema lexical value.
pub fn ST_FunctionValue::parse(
  s : String,
) -> ST_FunctionValue raise SchemaViolation {
  validate_ST_FunctionValue(s)
  { value: s }
}

///|
/// Construct ST_FunctionValue and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_FunctionValue::new(
  s : String,
) -> ST_FunctionValue raise SchemaViolation {
  ST_FunctionValue::parse(s)
}

///|
/// Return the schema lexical value for ST_FunctionValue.
pub fn ST_FunctionValue::to_string(self : ST_FunctionValue) -> String {
  self.value
}

///|
/// XSD simple type ST_VariableType (§21.4.x).
pub(all) enum ST_VariableType {
  VariableTypeNone
  VariableTypeOrgChart
  VariableTypeChMax
  VariableTypeChPref
  VariableTypeBulEnabled
  VariableTypeDir
  VariableTypeHierBranch
  VariableTypeAnimOne
  VariableTypeAnimLvl
  VariableTypeResizeHandles
} derive(Eq, Debug)

///|
/// Parse the ST_VariableType schema lexical value.
pub fn ST_VariableType::parse(
  s : String,
) -> ST_VariableType raise SchemaViolation {
  match s {
    "none" => VariableTypeNone
    "orgChart" => VariableTypeOrgChart
    "chMax" => VariableTypeChMax
    "chPref" => VariableTypeChPref
    "bulEnabled" => VariableTypeBulEnabled
    "dir" => VariableTypeDir
    "hierBranch" => VariableTypeHierBranch
    "animOne" => VariableTypeAnimOne
    "animLvl" => VariableTypeAnimLvl
    "resizeHandles" => VariableTypeResizeHandles
    _ => invalid("ST_VariableType", s)
  }
}

///|
/// Construct ST_VariableType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_VariableType::new(
  s : String,
) -> ST_VariableType raise SchemaViolation {
  ST_VariableType::parse(s)
}

///|
/// Return the schema lexical value for ST_VariableType.
pub fn ST_VariableType::to_string(self : ST_VariableType) -> String {
  match self {
    VariableTypeNone => "none"
    VariableTypeOrgChart => "orgChart"
    VariableTypeChMax => "chMax"
    VariableTypeChPref => "chPref"
    VariableTypeBulEnabled => "bulEnabled"
    VariableTypeDir => "dir"
    VariableTypeHierBranch => "hierBranch"
    VariableTypeAnimOne => "animOne"
    VariableTypeAnimLvl => "animLvl"
    VariableTypeResizeHandles => "resizeHandles"
  }
}

///|
/// XSD simple type ST_FunctionArgument (§21.4.x).
pub struct ST_FunctionArgument {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_FunctionArgument schema lexical value.
pub fn ST_FunctionArgument::parse(
  s : String,
) -> ST_FunctionArgument raise SchemaViolation {
  validate_ST_FunctionArgument(s)
  { value: s }
}

///|
/// Construct ST_FunctionArgument and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_FunctionArgument::new(
  s : String,
) -> ST_FunctionArgument raise SchemaViolation {
  ST_FunctionArgument::parse(s)
}

///|
/// Return the schema lexical value for ST_FunctionArgument.
pub fn ST_FunctionArgument::to_string(self : ST_FunctionArgument) -> String {
  self.value
}

///|
/// XSD simple type ST_OutputShapeType (§21.4.x).
pub(all) enum ST_OutputShapeType {
  OutputShapeTypeNone
  OutputShapeTypeConn
} derive(Eq, Debug)

///|
/// Parse the ST_OutputShapeType schema lexical value.
pub fn ST_OutputShapeType::parse(
  s : String,
) -> ST_OutputShapeType raise SchemaViolation {
  match s {
    "none" => OutputShapeTypeNone
    "conn" => OutputShapeTypeConn
    _ => invalid("ST_OutputShapeType", s)
  }
}

///|
/// Construct ST_OutputShapeType and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_OutputShapeType::new(
  s : String,
) -> ST_OutputShapeType raise SchemaViolation {
  ST_OutputShapeType::parse(s)
}

///|
/// Return the schema lexical value for ST_OutputShapeType.
pub fn ST_OutputShapeType::to_string(self : ST_OutputShapeType) -> String {
  match self {
    OutputShapeTypeNone => "none"
    OutputShapeTypeConn => "conn"
  }
}

///|
fn[T] invalid(type_name : String, value : String) -> T raise SchemaViolation {
  raise SchemaViolation(
    schema="dml-diagram.xsd",
    path=type_name,
    reason="invalid value: " + value,
  )
}

///|
fn validate_ST_LayoutShapeType(s : String) -> Unit raise SchemaViolation {
  if s.length() == 0 {
    invalid("ST_LayoutShapeType", s)
  }
}

///|
fn validate_ST_Index1(s : String) -> Unit raise SchemaViolation {
  if !is_unsigned_int(s) || numeric_is_zero(s) {
    invalid("ST_Index1", s)
  }
}

///|
fn validate_ST_ParameterVal(s : String) -> Unit raise SchemaViolation {
  if s.length() == 0 {
    invalid("ST_ParameterVal", s)
  }
}

///|
fn validate_ST_ModelId(s : String) -> Unit raise SchemaViolation {
  if s.length() == 0 {
    invalid("ST_ModelId", s)
  }
}

///|
fn validate_ST_PrSetCustVal(s : String) -> Unit raise SchemaViolation {
  if s.length() == 0 {
    invalid("ST_PrSetCustVal", s)
  }
}

///|
fn validate_ST_NodeCount(s : String) -> Unit raise SchemaViolation {
  if !is_int(s) {
    invalid("ST_NodeCount", s)
  }
}

///|
fn validate_ST_AxisTypes(s : String) -> Unit raise SchemaViolation {
  validate_enum_list("ST_AxisTypes", s, ST_AxisType::parse)
}

///|
fn validate_ST_ElementTypes(s : String) -> Unit raise SchemaViolation {
  validate_enum_list("ST_ElementTypes", s, ST_ElementType::parse)
}

///|
fn validate_ST_Ints(s : String) -> Unit raise SchemaViolation {
  validate_list("ST_Ints", s, is_int)
}

///|
fn validate_ST_UnsignedInts(s : String) -> Unit raise SchemaViolation {
  validate_list("ST_UnsignedInts", s, is_unsigned_int)
}

///|
fn validate_ST_Booleans(s : String) -> Unit raise SchemaViolation {
  validate_list("ST_Booleans", s, is_bool_token)
}

///|
fn validate_ST_FunctionValue(s : String) -> Unit raise SchemaViolation {
  if s.length() == 0 {
    invalid("ST_FunctionValue", s)
  }
}

///|
fn validate_ST_FunctionArgument(s : String) -> Unit raise SchemaViolation {
  ST_VariableType::parse(s) |> ignore
}

///|
fn[T] validate_enum_list(
  type_name : String,
  s : String,
  parser : (String) -> T raise SchemaViolation,
) -> Unit raise SchemaViolation {
  let parts = s.split(" ")
  let mut count = 0
  for part in parts {
    count = count + 1
    if part.length() == 0 {
      invalid(type_name, s)
    }
    parser(part.to_owned()) |> ignore
  }
  if count == 0 {
    invalid(type_name, s)
  }
}

///|
fn validate_list(
  type_name : String,
  s : String,
  pred : (String) -> Bool,
) -> Unit raise SchemaViolation {
  let parts = s.split(" ")
  let mut count = 0
  for part in parts {
    count = count + 1
    let value = part.to_owned()
    if value.length() == 0 || !pred(value) {
      invalid(type_name, s)
    }
  }
  if count == 0 {
    invalid(type_name, s)
  }
}

///|
fn is_int(s : String) -> Bool {
  if s.length() == 0 {
    false
  } else {
    let mut start = 0
    if s[0:1] == "-" || s[0:1] == "+" {
      start = 1
    }
    start < s.length() && digits(s, start, s.length())
  }
}

///|
fn is_unsigned_int(s : String) -> Bool {
  s.length() > 0 && digits(s, 0, s.length())
}

///|
fn numeric_is_zero(s : String) -> Bool {
  let mut ok = true
  for i in 0..<s.length() {
    ok = ok && s[i:i + 1] == "0"
  }
  ok
}

///|
fn is_bool_token(s : String) -> Bool {
  s == "true" || s == "false" || s == "1" || s == "0"
}

///|
fn digits(s : String, start : Int, end : Int) -> Bool {
  let mut ok = start >= 0 && end <= s.length() && start < end
  for i in start..<end {
    let ch = s[i:i + 1]
    ok = ok && ch >= "0" && ch <= "9"
  }
  ok
}

///|
/// Parse XSD simple type ST_Ints (§21.4) from a whitespace-separated xsd:int list.
pub fn parse_st_ints(s : String) -> ST_Ints raise SchemaViolation {
  ST_Ints::parse(s)
}
