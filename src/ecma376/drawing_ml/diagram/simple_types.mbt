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
/// XSD simple type ST_LayoutShapeType — Part 1 §21.4.7.41. Lexical union of
/// ST_OutputShapeType (§21.4.7.48, "none" | "conn") and DrawingML
/// ST_ShapeType (§20.1.10.56, the preset-geometry token set). The
/// `Output` variant holds the typed enum from this package; the
/// `Preset` variant holds the §20.1.10.56 token verbatim because that
/// vocabulary lives in the drawing_ml package and is not importable
/// here without crossing the diagram package boundary.
pub(all) enum ST_LayoutShapeType {
  LayoutShapeTypeOutput(ST_OutputShapeType)
  LayoutShapeTypePreset(String)
} derive(Eq, Debug)

///|
/// Parse the ST_LayoutShapeType schema lexical value. Try the typed
/// ST_OutputShapeType branch first; otherwise accept any non-empty
/// xsd:token as an ST_ShapeType preset name.
pub fn ST_LayoutShapeType::parse(
  s : String,
) -> ST_LayoutShapeType raise SchemaViolation {
  if s.length() == 0 {
    invalid("ST_LayoutShapeType", s)
  }
  match s {
    "none" => LayoutShapeTypeOutput(OutputShapeTypeNone)
    "conn" => LayoutShapeTypeOutput(OutputShapeTypeConn)
    _ => LayoutShapeTypePreset(s)
  }
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
  match self {
    LayoutShapeTypeOutput(v) => v.to_string()
    LayoutShapeTypePreset(s) => s
  }
}

///|
/// XSD simple type ST_Index1 — Part 1 §21.4.7.39. xsd:unsignedInt
/// restricted by minInclusive=1, so it stores a positive unsigned
/// integer in the closed range [1, 2^32 - 1].
pub struct ST_Index1 {
  value : UInt
} derive(Eq, Debug)

///|
/// Parse the ST_Index1 schema lexical value.
pub fn ST_Index1::parse(s : String) -> ST_Index1 raise SchemaViolation {
  if !is_unsigned_int(s) {
    invalid("ST_Index1", s)
  }
  let value = parse_uint(s, "ST_Index1")
  if value == 0U {
    invalid("ST_Index1", s)
  }
  { value, }
}

///|
/// Construct ST_Index1 and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_Index1::new(s : String) -> ST_Index1 raise SchemaViolation {
  ST_Index1::parse(s)
}

///|
/// Return the schema lexical value for ST_Index1.
pub fn ST_Index1::to_string(self : ST_Index1) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_ParameterVal — Part 1 §21.4.7.50. Lexical union
/// of every diagram parameter enumeration plus the W3C XML Schema
/// boolean / int / double / string member types. The variants below
/// follow the xsd:union memberTypes order in Annex A.5.3
/// (DiagramHorizontalAlignment, VerticalAlignment, ChildDirection,
/// ChildAlignment, SecondaryChildAlignment, LinearDirection,
/// SecondaryLinearDirection, StartingElement, BendPoint,
/// ConnectorRouting, ArrowheadStyle, ConnectorDimension, RotationPath,
/// CenterShapeMapping, NodeHorizontalAlignment, NodeVerticalAlignment,
/// FallbackDimension, TextDirection, PyramidAccentPosition,
/// PyramidAccentTextMargin, TextBlockDirection, TextAnchorHorizontal,
/// TextAnchorVertical, DiagramTextAlignment, AutoTextRotation,
/// GrowDirection, FlowDirection, ContinueDirection, Breakpoint,
/// Offset, HierarchyAlignment, xsd:int, xsd:double, xsd:boolean,
/// xsd:string, ConnectorPoint). The xsd:string fallback only fires
/// after every typed branch has been tried so the typed variants take
/// precedence.
pub(all) enum ST_ParameterVal {
  ParameterValDiagramHorizontalAlignment(ST_DiagramHorizontalAlignment)
  ParameterValVerticalAlignment(ST_VerticalAlignment)
  ParameterValChildDirection(ST_ChildDirection)
  ParameterValChildAlignment(ST_ChildAlignment)
  ParameterValSecondaryChildAlignment(ST_SecondaryChildAlignment)
  ParameterValLinearDirection(ST_LinearDirection)
  ParameterValSecondaryLinearDirection(ST_SecondaryLinearDirection)
  ParameterValStartingElement(ST_StartingElement)
  ParameterValBendPoint(ST_BendPoint)
  ParameterValConnectorRouting(ST_ConnectorRouting)
  ParameterValArrowheadStyle(ST_ArrowheadStyle)
  ParameterValConnectorDimension(ST_ConnectorDimension)
  ParameterValRotationPath(ST_RotationPath)
  ParameterValCenterShapeMapping(ST_CenterShapeMapping)
  ParameterValNodeHorizontalAlignment(ST_NodeHorizontalAlignment)
  ParameterValNodeVerticalAlignment(ST_NodeVerticalAlignment)
  ParameterValFallbackDimension(ST_FallbackDimension)
  ParameterValTextDirection(ST_TextDirection)
  ParameterValPyramidAccentPosition(ST_PyramidAccentPosition)
  ParameterValPyramidAccentTextMargin(ST_PyramidAccentTextMargin)
  ParameterValTextBlockDirection(ST_TextBlockDirection)
  ParameterValTextAnchorHorizontal(ST_TextAnchorHorizontal)
  ParameterValTextAnchorVertical(ST_TextAnchorVertical)
  ParameterValDiagramTextAlignment(ST_DiagramTextAlignment)
  ParameterValAutoTextRotation(ST_AutoTextRotation)
  ParameterValGrowDirection(ST_GrowDirection)
  ParameterValFlowDirection(ST_FlowDirection)
  ParameterValContinueDirection(ST_ContinueDirection)
  ParameterValBreakpoint(ST_Breakpoint)
  ParameterValOffset(ST_Offset)
  ParameterValHierarchyAlignment(ST_HierarchyAlignment)
  ParameterValConnectorPoint(ST_ConnectorPoint)
  ParameterValBool(Bool)
  ParameterValInt(Int)
  ParameterValDouble(String)
  ParameterValString(String)
} derive(Eq, Debug)

///|
/// Parse the ST_ParameterVal schema lexical value.
pub fn ST_ParameterVal::parse(
  s : String,
) -> ST_ParameterVal raise SchemaViolation {
  if s.length() == 0 {
    invalid("ST_ParameterVal", s)
  }
  // Try typed enum branches first; on success, return that variant.
  match (try? ST_DiagramHorizontalAlignment::parse(s)) {
    Ok(v) => return ParameterValDiagramHorizontalAlignment(v)
    Err(_) => ()
  }
  match (try? ST_VerticalAlignment::parse(s)) {
    Ok(v) => return ParameterValVerticalAlignment(v)
    Err(_) => ()
  }
  match (try? ST_ChildDirection::parse(s)) {
    Ok(v) => return ParameterValChildDirection(v)
    Err(_) => ()
  }
  match (try? ST_ChildAlignment::parse(s)) {
    Ok(v) => return ParameterValChildAlignment(v)
    Err(_) => ()
  }
  match (try? ST_SecondaryChildAlignment::parse(s)) {
    Ok(v) => return ParameterValSecondaryChildAlignment(v)
    Err(_) => ()
  }
  match (try? ST_LinearDirection::parse(s)) {
    Ok(v) => return ParameterValLinearDirection(v)
    Err(_) => ()
  }
  match (try? ST_SecondaryLinearDirection::parse(s)) {
    Ok(v) => return ParameterValSecondaryLinearDirection(v)
    Err(_) => ()
  }
  match (try? ST_StartingElement::parse(s)) {
    Ok(v) => return ParameterValStartingElement(v)
    Err(_) => ()
  }
  match (try? ST_BendPoint::parse(s)) {
    Ok(v) => return ParameterValBendPoint(v)
    Err(_) => ()
  }
  match (try? ST_ConnectorRouting::parse(s)) {
    Ok(v) => return ParameterValConnectorRouting(v)
    Err(_) => ()
  }
  match (try? ST_ArrowheadStyle::parse(s)) {
    Ok(v) => return ParameterValArrowheadStyle(v)
    Err(_) => ()
  }
  match (try? ST_ConnectorDimension::parse(s)) {
    Ok(v) => return ParameterValConnectorDimension(v)
    Err(_) => ()
  }
  match (try? ST_RotationPath::parse(s)) {
    Ok(v) => return ParameterValRotationPath(v)
    Err(_) => ()
  }
  match (try? ST_CenterShapeMapping::parse(s)) {
    Ok(v) => return ParameterValCenterShapeMapping(v)
    Err(_) => ()
  }
  match (try? ST_NodeHorizontalAlignment::parse(s)) {
    Ok(v) => return ParameterValNodeHorizontalAlignment(v)
    Err(_) => ()
  }
  match (try? ST_NodeVerticalAlignment::parse(s)) {
    Ok(v) => return ParameterValNodeVerticalAlignment(v)
    Err(_) => ()
  }
  match (try? ST_FallbackDimension::parse(s)) {
    Ok(v) => return ParameterValFallbackDimension(v)
    Err(_) => ()
  }
  match (try? ST_TextDirection::parse(s)) {
    Ok(v) => return ParameterValTextDirection(v)
    Err(_) => ()
  }
  match (try? ST_PyramidAccentPosition::parse(s)) {
    Ok(v) => return ParameterValPyramidAccentPosition(v)
    Err(_) => ()
  }
  match (try? ST_PyramidAccentTextMargin::parse(s)) {
    Ok(v) => return ParameterValPyramidAccentTextMargin(v)
    Err(_) => ()
  }
  match (try? ST_TextBlockDirection::parse(s)) {
    Ok(v) => return ParameterValTextBlockDirection(v)
    Err(_) => ()
  }
  match (try? ST_TextAnchorHorizontal::parse(s)) {
    Ok(v) => return ParameterValTextAnchorHorizontal(v)
    Err(_) => ()
  }
  match (try? ST_TextAnchorVertical::parse(s)) {
    Ok(v) => return ParameterValTextAnchorVertical(v)
    Err(_) => ()
  }
  match (try? ST_DiagramTextAlignment::parse(s)) {
    Ok(v) => return ParameterValDiagramTextAlignment(v)
    Err(_) => ()
  }
  match (try? ST_AutoTextRotation::parse(s)) {
    Ok(v) => return ParameterValAutoTextRotation(v)
    Err(_) => ()
  }
  match (try? ST_GrowDirection::parse(s)) {
    Ok(v) => return ParameterValGrowDirection(v)
    Err(_) => ()
  }
  match (try? ST_FlowDirection::parse(s)) {
    Ok(v) => return ParameterValFlowDirection(v)
    Err(_) => ()
  }
  match (try? ST_ContinueDirection::parse(s)) {
    Ok(v) => return ParameterValContinueDirection(v)
    Err(_) => ()
  }
  match (try? ST_Breakpoint::parse(s)) {
    Ok(v) => return ParameterValBreakpoint(v)
    Err(_) => ()
  }
  match (try? ST_Offset::parse(s)) {
    Ok(v) => return ParameterValOffset(v)
    Err(_) => ()
  }
  match (try? ST_HierarchyAlignment::parse(s)) {
    Ok(v) => return ParameterValHierarchyAlignment(v)
    Err(_) => ()
  }
  match (try? ST_ConnectorPoint::parse(s)) {
    Ok(v) => return ParameterValConnectorPoint(v)
    Err(_) => ()
  }
  if s == "true" || s == "1" {
    return ParameterValBool(true)
  }
  if s == "false" || s == "0" {
    return ParameterValBool(false)
  }
  if is_int(s) {
    return ParameterValInt(parse_int(s, "ST_ParameterVal"))
  }
  if is_double(s) {
    return ParameterValDouble(s)
  }
  ParameterValString(s)
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
  match self {
    ParameterValDiagramHorizontalAlignment(v) => v.to_string()
    ParameterValVerticalAlignment(v) => v.to_string()
    ParameterValChildDirection(v) => v.to_string()
    ParameterValChildAlignment(v) => v.to_string()
    ParameterValSecondaryChildAlignment(v) => v.to_string()
    ParameterValLinearDirection(v) => v.to_string()
    ParameterValSecondaryLinearDirection(v) => v.to_string()
    ParameterValStartingElement(v) => v.to_string()
    ParameterValBendPoint(v) => v.to_string()
    ParameterValConnectorRouting(v) => v.to_string()
    ParameterValArrowheadStyle(v) => v.to_string()
    ParameterValConnectorDimension(v) => v.to_string()
    ParameterValRotationPath(v) => v.to_string()
    ParameterValCenterShapeMapping(v) => v.to_string()
    ParameterValNodeHorizontalAlignment(v) => v.to_string()
    ParameterValNodeVerticalAlignment(v) => v.to_string()
    ParameterValFallbackDimension(v) => v.to_string()
    ParameterValTextDirection(v) => v.to_string()
    ParameterValPyramidAccentPosition(v) => v.to_string()
    ParameterValPyramidAccentTextMargin(v) => v.to_string()
    ParameterValTextBlockDirection(v) => v.to_string()
    ParameterValTextAnchorHorizontal(v) => v.to_string()
    ParameterValTextAnchorVertical(v) => v.to_string()
    ParameterValDiagramTextAlignment(v) => v.to_string()
    ParameterValAutoTextRotation(v) => v.to_string()
    ParameterValGrowDirection(v) => v.to_string()
    ParameterValFlowDirection(v) => v.to_string()
    ParameterValContinueDirection(v) => v.to_string()
    ParameterValBreakpoint(v) => v.to_string()
    ParameterValOffset(v) => v.to_string()
    ParameterValHierarchyAlignment(v) => v.to_string()
    ParameterValConnectorPoint(v) => v.to_string()
    ParameterValBool(true) => "true"
    ParameterValBool(false) => "false"
    ParameterValInt(v) => v.to_string()
    ParameterValDouble(s) => s
    ParameterValString(s) => s
  }
}

///|
/// XSD simple type ST_ModelId — Part 1 §21.4.7.43. Lexical union of
/// xsd:int and the shared ST_Guid type (§22.9.2.4, the
/// brace-delimited UUID form). The `Int` variant holds the parsed
/// xsd:int value; the `Guid` variant preserves the original
/// `{HHHHHHHH-HHHH-HHHH-HHHH-HHHHHHHHHHHH}` lexical form because
/// ST_Guid's typed encoding lives in the shared simple_types package
/// and is not imported here.
pub(all) enum ST_ModelId {
  ModelIdInt(Int)
  ModelIdGuid(String)
} derive(Eq, Debug)

///|
/// Parse the ST_ModelId schema lexical value.
pub fn ST_ModelId::parse(s : String) -> ST_ModelId raise SchemaViolation {
  if s.length() == 0 {
    invalid("ST_ModelId", s)
  }
  if is_int(s) {
    return ModelIdInt(parse_int(s, "ST_ModelId"))
  }
  if is_guid(s) {
    return ModelIdGuid(s)
  }
  invalid("ST_ModelId", s)
}

///|
/// Construct ST_ModelId and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_ModelId::new(s : String) -> ST_ModelId raise SchemaViolation {
  ST_ModelId::parse(s)
}

///|
/// Return the schema lexical value for ST_ModelId.
pub fn ST_ModelId::to_string(self : ST_ModelId) -> String {
  match self {
    ModelIdInt(v) => v.to_string()
    ModelIdGuid(s) => s
  }
}

///|
/// XSD simple type ST_PrSetCustVal — Part 1 §21.4.7.66. Lexical union
/// of the shared ST_Percentage type (§22.9.2.9, `<decimal>%`). Stored
/// as the signed decimal magnitude scaled by 1000 — matching
/// ST_Percentage's canonical thousandths-of-percent encoding — so
/// callers compare and round-trip at integer precision without
/// re-parsing the lexical form.
pub struct ST_PrSetCustVal {
  /// 1000ths of a percent. e.g. "12.345%" -> 12345.
  thousandths : Int64
} derive(Eq, Debug)

///|
/// Parse the ST_PrSetCustVal schema lexical value.
pub fn ST_PrSetCustVal::parse(
  s : String,
) -> ST_PrSetCustVal raise SchemaViolation {
  if !is_percentage_lexical(s) {
    invalid("ST_PrSetCustVal", s)
  }
  let magnitude = s.unsafe_substring(start=0, end=s.length() - 1)
  let thousandths = parse_decimal_scaled(magnitude, 3, "ST_PrSetCustVal")
  { thousandths, }
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
  format_scaled_decimal(self.thousandths, 3) + "%"
}

///|
/// Numeric accessor for downstream calculations.
pub fn ST_PrSetCustVal::thousandths_of_percent(self : ST_PrSetCustVal) -> Int64 {
  self.thousandths
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
/// XSD simple type ST_NodeCount — Part 1 §21.4.7.44. xsd:int
/// restricted by minInclusive=-1; the spec text notes that -1 carries
/// the sentinel meaning "unbounded".
pub struct ST_NodeCount {
  value : Int
} derive(Eq, Debug)

///|
/// Parse the ST_NodeCount schema lexical value.
pub fn ST_NodeCount::parse(s : String) -> ST_NodeCount raise SchemaViolation {
  if !is_int(s) {
    invalid("ST_NodeCount", s)
  }
  let value = parse_int(s, "ST_NodeCount")
  if value < -1 {
    invalid("ST_NodeCount", s)
  }
  { value, }
}

///|
/// Construct ST_NodeCount and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_NodeCount::new(s : String) -> ST_NodeCount raise SchemaViolation {
  ST_NodeCount::parse(s)
}

///|
/// Return the schema lexical value for ST_NodeCount.
pub fn ST_NodeCount::to_string(self : ST_NodeCount) -> String {
  self.value.to_string()
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
/// XSD simple type ST_AxisTypes — Part 1 §21.4.7.7. xsd:list whose
/// itemType is ST_AxisType (§21.4.7.6). The whitespace-separated
/// lexical form is decoded into the parsed item enum values.
pub struct ST_AxisTypes {
  values : Array[ST_AxisType]
} derive(Eq, Debug)

///|
/// Parse the ST_AxisTypes schema lexical value.
pub fn ST_AxisTypes::parse(s : String) -> ST_AxisTypes raise SchemaViolation {
  let values = parse_typed_list("ST_AxisTypes", s, ST_AxisType::parse)
  { values, }
}

///|
/// Construct ST_AxisTypes and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_AxisTypes::new(s : String) -> ST_AxisTypes raise SchemaViolation {
  ST_AxisTypes::parse(s)
}

///|
/// Return the schema lexical value for ST_AxisTypes.
pub fn ST_AxisTypes::to_string(self : ST_AxisTypes) -> String {
  format_typed_list(self.values, fn(item) { item.to_string() })
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
/// XSD simple type ST_ElementTypes — Part 1 §21.4.7.28. xsd:list whose
/// itemType is ST_ElementType (§21.4.7.27). The whitespace-separated
/// lexical form is decoded into the parsed item enum values.
pub struct ST_ElementTypes {
  values : Array[ST_ElementType]
} derive(Eq, Debug)

///|
/// Parse the ST_ElementTypes schema lexical value.
pub fn ST_ElementTypes::parse(
  s : String,
) -> ST_ElementTypes raise SchemaViolation {
  let values = parse_typed_list("ST_ElementTypes", s, ST_ElementType::parse)
  { values, }
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
  format_typed_list(self.values, fn(item) { item.to_string() })
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
/// XSD simple type ST_Ints — Part 1 §21.4.7.40. xsd:list whose
/// itemType is xsd:int. The whitespace-separated lexical form is
/// decoded into typed signed 32-bit integer items.
pub struct ST_Ints {
  values : Array[Int]
} derive(Eq, Debug)

///|
/// Parse the ST_Ints schema lexical value.
pub fn ST_Ints::parse(s : String) -> ST_Ints raise SchemaViolation {
  let values = parse_typed_list("ST_Ints", s, fn(item) {
    if !is_int(item) {
      invalid("ST_Ints", s)
    }
    parse_int(item, "ST_Ints")
  })
  { values, }
}

///|
/// Construct ST_Ints and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_Ints::new(s : String) -> ST_Ints raise SchemaViolation {
  ST_Ints::parse(s)
}

///|
/// Return the schema lexical value for ST_Ints.
pub fn ST_Ints::to_string(self : ST_Ints) -> String {
  format_typed_list(self.values, fn(v) { v.to_string() })
}

///|
/// XSD simple type ST_UnsignedInts — Part 1 §21.4.7.63. xsd:list whose
/// itemType is xsd:unsignedInt. The whitespace-separated lexical form
/// is decoded into typed unsigned 32-bit integer items.
pub struct ST_UnsignedInts {
  values : Array[UInt]
} derive(Eq, Debug)

///|
/// Parse the ST_UnsignedInts schema lexical value.
pub fn ST_UnsignedInts::parse(
  s : String,
) -> ST_UnsignedInts raise SchemaViolation {
  let values = parse_typed_list("ST_UnsignedInts", s, fn(item) {
    if !is_unsigned_int(item) {
      invalid("ST_UnsignedInts", s)
    }
    parse_uint(item, "ST_UnsignedInts")
  })
  { values, }
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
  format_typed_list(self.values, fn(v) { v.to_string() })
}

///|
/// XSD simple type ST_Booleans — Part 1 §21.4.7.9. xsd:list whose
/// itemType is xsd:boolean. Each whitespace-separated item is decoded
/// into a typed Bool; both `true`/`false` and `1`/`0` lexical forms
/// are accepted on parse, and `to_string` renders the canonical
/// `true`/`false` forms.
pub struct ST_Booleans {
  values : Array[Bool]
} derive(Eq, Debug)

///|
/// Parse the ST_Booleans schema lexical value.
pub fn ST_Booleans::parse(s : String) -> ST_Booleans raise SchemaViolation {
  let values = parse_typed_list("ST_Booleans", s, fn(item) {
    match item {
      "true" | "1" => true
      "false" | "0" => false
      _ => invalid("ST_Booleans", s)
    }
  })
  { values, }
}

///|
/// Construct ST_Booleans and enforce the dml-diagram.xsd lexical constraint.
pub fn ST_Booleans::new(s : String) -> ST_Booleans raise SchemaViolation {
  ST_Booleans::parse(s)
}

///|
/// Return the schema lexical value for ST_Booleans.
pub fn ST_Booleans::to_string(self : ST_Booleans) -> String {
  format_typed_list(self.values, fn(v) { if v { "true" } else { "false" } })
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
/// XSD simple type ST_FunctionValue — Part 1 §21.4.7.34. Lexical union
/// of (in Annex A.5.3 order) xsd:int, xsd:boolean, ST_Direction
/// (§21.4.7.26), ST_HierBranchStyle (§21.4.7.37), ST_AnimOneStr
/// (§21.4.7.3), ST_AnimLvlStr (§21.4.7.2), and ST_ResizeHandlesStr
/// (§21.4.7.54). Disambiguation: xsd:int wins over the enum branches
/// when the literal parses as a signed integer; xsd:boolean wins over
/// `true`/`false`/`1`/`0` because every enum member type is a token
/// vocabulary disjoint from those tokens.
pub(all) enum ST_FunctionValue {
  FunctionValueInt(Int)
  FunctionValueBool(Bool)
  FunctionValueDirection(ST_Direction)
  FunctionValueHierBranchStyle(ST_HierBranchStyle)
  FunctionValueAnimOneStr(ST_AnimOneStr)
  FunctionValueAnimLvlStr(ST_AnimLvlStr)
  FunctionValueResizeHandlesStr(ST_ResizeHandlesStr)
} derive(Eq, Debug)

///|
/// Parse the ST_FunctionValue schema lexical value.
pub fn ST_FunctionValue::parse(
  s : String,
) -> ST_FunctionValue raise SchemaViolation {
  if s.length() == 0 {
    invalid("ST_FunctionValue", s)
  }
  if is_int(s) {
    return FunctionValueInt(parse_int(s, "ST_FunctionValue"))
  }
  if s == "true" || s == "1" {
    return FunctionValueBool(true)
  }
  if s == "false" || s == "0" {
    return FunctionValueBool(false)
  }
  match (try? ST_Direction::parse(s)) {
    Ok(v) => return FunctionValueDirection(v)
    Err(_) => ()
  }
  match (try? ST_HierBranchStyle::parse(s)) {
    Ok(v) => return FunctionValueHierBranchStyle(v)
    Err(_) => ()
  }
  match (try? ST_AnimOneStr::parse(s)) {
    Ok(v) => return FunctionValueAnimOneStr(v)
    Err(_) => ()
  }
  match (try? ST_AnimLvlStr::parse(s)) {
    Ok(v) => return FunctionValueAnimLvlStr(v)
    Err(_) => ()
  }
  match (try? ST_ResizeHandlesStr::parse(s)) {
    Ok(v) => return FunctionValueResizeHandlesStr(v)
    Err(_) => ()
  }
  invalid("ST_FunctionValue", s)
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
  match self {
    FunctionValueInt(v) => v.to_string()
    FunctionValueBool(true) => "true"
    FunctionValueBool(false) => "false"
    FunctionValueDirection(v) => v.to_string()
    FunctionValueHierBranchStyle(v) => v.to_string()
    FunctionValueAnimOneStr(v) => v.to_string()
    FunctionValueAnimLvlStr(v) => v.to_string()
    FunctionValueResizeHandlesStr(v) => v.to_string()
  }
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
/// XSD simple type ST_FunctionArgument — Part 1 §21.4.7.31. xsd:union
/// whose only memberType is ST_VariableType (§21.4.7.64), so every
/// valid value is one of that enum's lexical tokens.
pub(all) enum ST_FunctionArgument {
  FunctionArgumentVariable(ST_VariableType)
} derive(Eq, Debug)

///|
/// Parse the ST_FunctionArgument schema lexical value.
pub fn ST_FunctionArgument::parse(
  s : String,
) -> ST_FunctionArgument raise SchemaViolation {
  match (try? ST_VariableType::parse(s)) {
    Ok(v) => FunctionArgumentVariable(v)
    Err(_) => invalid("ST_FunctionArgument", s)
  }
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
  match self {
    FunctionArgumentVariable(v) => v.to_string()
  }
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
/// Decode an xsd:list lexical form ("a b c") into a typed item array.
/// Empty lists raise SchemaViolation in line with xsd:list semantics
/// requiring at least one item, and the per-item `parser` enforces the
/// itemType constraint.
fn[T] parse_typed_list(
  type_name : String,
  s : String,
  parser : (String) -> T raise SchemaViolation,
) -> Array[T] raise SchemaViolation {
  let parts = s.split(" ")
  let items : Array[T] = []
  for part in parts {
    let value = part.to_owned()
    if value.length() == 0 {
      invalid(type_name, s)
    }
    items.push(parser(value))
  }
  if items.length() == 0 {
    invalid(type_name, s)
  }
  items
}

///|
/// Render a typed item array back to the canonical xsd:list lexical
/// form by joining the per-item `formatter` output with single spaces.
fn[T] format_typed_list(items : Array[T], formatter : (T) -> String) -> String {
  let buf = StringBuilder::new()
  let mut first = true
  for item in items {
    if !first {
      buf.write_char(' ')
    }
    first = false
    buf.write_string(formatter(item))
  }
  buf.to_string()
}

///|
/// Lexical predicate for xsd:int: optional sign followed by digits.
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
/// Lexical predicate for xsd:unsignedInt: at least one digit, no sign.
fn is_unsigned_int(s : String) -> Bool {
  s.length() > 0 && digits(s, 0, s.length())
}

///|
/// Lexical predicate for xsd:double restricted to the common decimal
/// subset used by DiagramML attributes — optional sign, integer part,
/// optional fractional part. Excludes scientific notation and special
/// values (INF/NaN) because the spec attributes never carry them.
fn is_double(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut i = 0
  if s[0:1] == "-" || s[0:1] == "+" {
    i = 1
  }
  let start = i
  let mut digit_count = 0
  while i < s.length() && s[i:i + 1] >= "0" && s[i:i + 1] <= "9" {
    digit_count = digit_count + 1
    i = i + 1
  }
  if i < s.length() && s[i:i + 1] == "." {
    i = i + 1
    while i < s.length() && s[i:i + 1] >= "0" && s[i:i + 1] <= "9" {
      digit_count = digit_count + 1
      i = i + 1
    }
  }
  if digit_count == 0 {
    return false
  }
  i == s.length() && start < s.length()
}

///|
/// Lexical predicate for ST_Percentage (§22.9.2.9): `<decimal>%` with
/// optional sign, at least one digit, and an optional fractional part.
fn is_percentage_lexical(s : String) -> Bool {
  if s.length() < 2 {
    return false
  }
  if s[s.length() - 1:s.length()] != "%" {
    return false
  }
  is_decimal(s.unsafe_substring(start=0, end=s.length() - 1))
}

///|
/// Lexical predicate for ST_Guid (§22.9.2.4): brace-delimited UUID
/// with the canonical 4-2-2-2-6 hex grouping
/// `{HHHHHHHH-HHHH-HHHH-HHHH-HHHHHHHHHHHH}`.
fn is_guid(s : String) -> Bool {
  if s.length() != 38 {
    return false
  }
  if s[0:1] != "{" || s[37:38] != "}" {
    return false
  }
  if s[9:10] != "-" || s[14:15] != "-" || s[19:20] != "-" || s[24:25] != "-" {
    return false
  }
  let groups = [(1, 9), (10, 14), (15, 19), (20, 24), (25, 37)]
  for entry in groups {
    let (start, end) = entry
    for i in start..<end {
      if !is_hex_digit(s[i:i + 1]) {
        return false
      }
    }
  }
  true
}

///|
fn is_hex_digit(ch : StringView) -> Bool {
  (ch >= "0" && ch <= "9") ||
  (ch >= "a" && ch <= "f") ||
  (ch >= "A" && ch <= "F")
}

///|
/// Lexical predicate for xsd:decimal: optional sign, at least one
/// digit, optional fractional part. Matches the magnitude portion of
/// an ST_Percentage lexical form.
fn is_decimal(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut i = 0
  if s[0:1] == "-" || s[0:1] == "+" {
    i = 1
  }
  let mut digit_count = 0
  while i < s.length() && s[i:i + 1] >= "0" && s[i:i + 1] <= "9" {
    digit_count = digit_count + 1
    i = i + 1
  }
  if i < s.length() && s[i:i + 1] == "." {
    i = i + 1
    while i < s.length() && s[i:i + 1] >= "0" && s[i:i + 1] <= "9" {
      digit_count = digit_count + 1
      i = i + 1
    }
  }
  digit_count > 0 && i == s.length()
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
/// Parse an xsd:int lexical form into a signed 32-bit Int. The caller
/// must have already validated the lexical form (e.g. via `is_int`);
/// any conversion failure is reported via SchemaViolation.
fn parse_int(s : String, type_name : String) -> Int raise SchemaViolation {
  let mut i = 0
  let mut negative = false
  if s.length() > 0 && s[0:1] == "-" {
    negative = true
    i = 1
  } else if s.length() > 0 && s[0:1] == "+" {
    i = 1
  }
  let mut value = 0
  while i < s.length() {
    let digit = s[i:i + 1][0].to_int() - "0"[0].to_int()
    if digit < 0 || digit > 9 {
      invalid(type_name, s)
    }
    value = value * 10 + digit
    i = i + 1
  }
  if negative {
    -value
  } else {
    value
  }
}

///|
/// Parse an xsd:unsignedInt lexical form into a UInt. The caller must
/// have already validated the lexical form via `is_unsigned_int`.
fn parse_uint(s : String, type_name : String) -> UInt raise SchemaViolation {
  if s.length() == 0 {
    invalid(type_name, s)
  }
  let mut value : UInt = 0U
  for i in 0..<s.length() {
    let digit = s[i:i + 1][0].to_int() - "0"[0].to_int()
    if digit < 0 || digit > 9 {
      invalid(type_name, s)
    }
    value = value * 10U + digit.reinterpret_as_uint()
  }
  value
}

///|
/// Convert a signed decimal magnitude string into the integer scaled
/// by 10^`scale`. e.g. parse_decimal_scaled("12.345", 3, _) -> 12345.
/// The fractional part is padded with zeros or rejected when it is
/// longer than `scale` so the encoding stays lossless.
fn parse_decimal_scaled(
  s : String,
  scale : Int,
  type_name : String,
) -> Int64 raise SchemaViolation {
  if s.length() == 0 {
    invalid(type_name, s)
  }
  let mut i = 0
  let mut negative = false
  if s[0:1] == "-" {
    negative = true
    i = 1
  } else if s[0:1] == "+" {
    i = 1
  }
  let mut int_part : Int64 = 0L
  let mut int_digits = 0
  while i < s.length() && s[i:i + 1] != "." {
    let digit = s[i:i + 1][0].to_int() - "0"[0].to_int()
    if digit < 0 || digit > 9 {
      invalid(type_name, s)
    }
    int_part = int_part * 10L + digit.to_int64()
    int_digits = int_digits + 1
    i = i + 1
  }
  let mut frac_part : Int64 = 0L
  let mut frac_digits = 0
  if i < s.length() && s[i:i + 1] == "." {
    i = i + 1
    while i < s.length() {
      let digit = s[i:i + 1][0].to_int() - "0"[0].to_int()
      if digit < 0 || digit > 9 {
        invalid(type_name, s)
      }
      if frac_digits >= scale {
        if digit != 0 {
          invalid(type_name, s)
        }
      } else {
        frac_part = frac_part * 10L + digit.to_int64()
      }
      frac_digits = frac_digits + 1
      i = i + 1
    }
  }
  if int_digits + frac_digits == 0 {
    invalid(type_name, s)
  }
  let used_digits = if frac_digits > scale { scale } else { frac_digits }
  let mut multiplier : Int64 = 1L
  for _ in 0..<(scale - used_digits) {
    multiplier = multiplier * 10L
  }
  frac_part = frac_part * multiplier
  let mut scale_pow : Int64 = 1L
  for _ in 0..<scale {
    scale_pow = scale_pow * 10L
  }
  let magnitude = int_part * scale_pow + frac_part
  if negative {
    -magnitude
  } else {
    magnitude
  }
}

///|
/// Render a scaled integer back to its decimal lexical form with the
/// canonical sign placement. Trailing fractional zeros are trimmed,
/// and an empty fractional part is dropped (i.e. `0` not `0.`).
fn format_scaled_decimal(value : Int64, scale : Int) -> String {
  let mut magnitude = value
  let buf = StringBuilder::new()
  if magnitude < 0L {
    buf.write_char('-')
    magnitude = -magnitude
  }
  let mut scale_pow : Int64 = 1L
  for _ in 0..<scale {
    scale_pow = scale_pow * 10L
  }
  let int_part = magnitude / scale_pow
  let frac_part = magnitude % scale_pow
  buf.write_string(int_part.to_string())
  if frac_part != 0L {
    buf.write_char('.')
    let frac_str = frac_part.to_string()
    for _ in 0..<(scale - frac_str.length()) {
      buf.write_char('0')
    }
    // Trim trailing zeros from the fractional segment.
    let mut end = frac_str.length()
    while end > 0 && frac_str[end - 1:end] == "0" {
      end = end - 1
    }
    buf.write_string(frac_str.unsafe_substring(start=0, end~))
  }
  buf.to_string()
}

///|
/// Parse XSD simple type ST_Ints (§21.4) from a whitespace-separated xsd:int list.
pub fn parse_st_ints(s : String) -> ST_Ints raise SchemaViolation {
  ST_Ints::parse(s)
}
