///|
/// Schema validation error for ECMA-376 DrawingML chart (§21.2/§21.3).
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// XSD simple type ST_LayoutTarget (§21.2, dml-chart.xsd).
pub(all) enum ST_LayoutTarget {
  LayoutTargetInner
  LayoutTargetOuter
} derive(Eq, Debug)

///|
/// Parse the ST_LayoutTarget schema lexical value.
pub fn ST_LayoutTarget::parse(
  s : String,
) -> ST_LayoutTarget raise SchemaViolation {
  match s {
    "inner" => LayoutTargetInner
    "outer" => LayoutTargetOuter
    _ => invalid("dml-chart.xsd", "ST_LayoutTarget", s)
  }
}

///|
/// Construct ST_LayoutTarget while enforcing the dml-chart.xsd enumeration.
pub fn ST_LayoutTarget::new(
  s : String,
) -> ST_LayoutTarget raise SchemaViolation {
  ST_LayoutTarget::parse(s)
}

///|
/// Return the schema lexical value for ST_LayoutTarget.
pub fn ST_LayoutTarget::to_string(self : ST_LayoutTarget) -> String {
  match self {
    LayoutTargetInner => "inner"
    LayoutTargetOuter => "outer"
  }
}

///|
/// XSD simple type ST_LayoutMode (§21.2, dml-chart.xsd).
pub(all) enum ST_LayoutMode {
  LayoutModeEdge
  LayoutModeFactor
} derive(Eq, Debug)

///|
/// Parse the ST_LayoutMode schema lexical value.
pub fn ST_LayoutMode::parse(s : String) -> ST_LayoutMode raise SchemaViolation {
  match s {
    "edge" => LayoutModeEdge
    "factor" => LayoutModeFactor
    _ => invalid("dml-chart.xsd", "ST_LayoutMode", s)
  }
}

///|
/// Construct ST_LayoutMode while enforcing the dml-chart.xsd enumeration.
pub fn ST_LayoutMode::new(s : String) -> ST_LayoutMode raise SchemaViolation {
  ST_LayoutMode::parse(s)
}

///|
/// Return the schema lexical value for ST_LayoutMode.
pub fn ST_LayoutMode::to_string(self : ST_LayoutMode) -> String {
  match self {
    LayoutModeEdge => "edge"
    LayoutModeFactor => "factor"
  }
}

///|
/// XSD simple type ST_RotX (§21.2, dml-chart.xsd) with base xsd:byte.
pub struct ST_RotX {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_RotX schema lexical value.
pub fn ST_RotX::parse(s : String) -> ST_RotX raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_RotX", s)
  { value: s }
}

///|
/// Construct ST_RotX while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_RotX::new(s : String) -> ST_RotX raise SchemaViolation {
  ST_RotX::parse(s)
}

///|
/// Return the schema lexical value for ST_RotX.
pub fn ST_RotX::to_string(self : ST_RotX) -> String {
  self.value
}

///|
/// XSD simple type ST_HPercent (§21.2, dml-chart.xsd) with base schema-restricted numeric value.
pub struct ST_HPercent {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_HPercent schema lexical value.
pub fn ST_HPercent::parse(s : String) -> ST_HPercent raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_HPercent", s)
  { value: s }
}

///|
/// Construct ST_HPercent while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_HPercent::new(s : String) -> ST_HPercent raise SchemaViolation {
  ST_HPercent::parse(s)
}

///|
/// Return the schema lexical value for ST_HPercent.
pub fn ST_HPercent::to_string(self : ST_HPercent) -> String {
  self.value
}

///|
/// XSD simple type ST_HPercentWithSymbol (§21.2, dml-chart.xsd) with base xsd:string.
pub struct ST_HPercentWithSymbol {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_HPercentWithSymbol schema lexical value.
pub fn ST_HPercentWithSymbol::parse(
  s : String,
) -> ST_HPercentWithSymbol raise SchemaViolation {
  validate_non_empty("dml-chart.xsd", "ST_HPercentWithSymbol", s)
  { value: s }
}

///|
/// Construct ST_HPercentWithSymbol while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_HPercentWithSymbol::new(
  s : String,
) -> ST_HPercentWithSymbol raise SchemaViolation {
  ST_HPercentWithSymbol::parse(s)
}

///|
/// Return the schema lexical value for ST_HPercentWithSymbol.
pub fn ST_HPercentWithSymbol::to_string(self : ST_HPercentWithSymbol) -> String {
  self.value
}

///|
/// XSD simple type ST_RotY (§21.2, dml-chart.xsd) with base xsd:unsignedShort.
pub struct ST_RotY {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_RotY schema lexical value.
pub fn ST_RotY::parse(s : String) -> ST_RotY raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_RotY", s)
  { value: s }
}

///|
/// Construct ST_RotY while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_RotY::new(s : String) -> ST_RotY raise SchemaViolation {
  ST_RotY::parse(s)
}

///|
/// Return the schema lexical value for ST_RotY.
pub fn ST_RotY::to_string(self : ST_RotY) -> String {
  self.value
}

///|
/// XSD simple type ST_DepthPercent (§21.2, dml-chart.xsd) with base schema-restricted numeric value.
pub struct ST_DepthPercent {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_DepthPercent schema lexical value.
pub fn ST_DepthPercent::parse(
  s : String,
) -> ST_DepthPercent raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_DepthPercent", s)
  { value: s }
}

///|
/// Construct ST_DepthPercent while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_DepthPercent::new(
  s : String,
) -> ST_DepthPercent raise SchemaViolation {
  ST_DepthPercent::parse(s)
}

///|
/// Return the schema lexical value for ST_DepthPercent.
pub fn ST_DepthPercent::to_string(self : ST_DepthPercent) -> String {
  self.value
}

///|
/// XSD simple type ST_DepthPercentWithSymbol (§21.2, dml-chart.xsd) with base xsd:string.
pub struct ST_DepthPercentWithSymbol {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_DepthPercentWithSymbol schema lexical value.
pub fn ST_DepthPercentWithSymbol::parse(
  s : String,
) -> ST_DepthPercentWithSymbol raise SchemaViolation {
  validate_non_empty("dml-chart.xsd", "ST_DepthPercentWithSymbol", s)
  { value: s }
}

///|
/// Construct ST_DepthPercentWithSymbol while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_DepthPercentWithSymbol::new(
  s : String,
) -> ST_DepthPercentWithSymbol raise SchemaViolation {
  ST_DepthPercentWithSymbol::parse(s)
}

///|
/// Return the schema lexical value for ST_DepthPercentWithSymbol.
pub fn ST_DepthPercentWithSymbol::to_string(
  self : ST_DepthPercentWithSymbol,
) -> String {
  self.value
}

///|
/// XSD simple type ST_Perspective (§21.2, dml-chart.xsd) with base xsd:unsignedByte.
pub struct ST_Perspective {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_Perspective schema lexical value.
pub fn ST_Perspective::parse(
  s : String,
) -> ST_Perspective raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_Perspective", s)
  { value: s }
}

///|
/// Construct ST_Perspective while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_Perspective::new(s : String) -> ST_Perspective raise SchemaViolation {
  ST_Perspective::parse(s)
}

///|
/// Return the schema lexical value for ST_Perspective.
pub fn ST_Perspective::to_string(self : ST_Perspective) -> String {
  self.value
}

///|
/// XSD simple type ST_Thickness (§21.2, dml-chart.xsd) with base schema-restricted numeric value.
pub struct ST_Thickness {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_Thickness schema lexical value.
pub fn ST_Thickness::parse(s : String) -> ST_Thickness raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_Thickness", s)
  { value: s }
}

///|
/// Construct ST_Thickness while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_Thickness::new(s : String) -> ST_Thickness raise SchemaViolation {
  ST_Thickness::parse(s)
}

///|
/// Return the schema lexical value for ST_Thickness.
pub fn ST_Thickness::to_string(self : ST_Thickness) -> String {
  self.value
}

///|
/// XSD simple type ST_ThicknessPercent (§21.2, dml-chart.xsd) with base xsd:string.
pub struct ST_ThicknessPercent {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_ThicknessPercent schema lexical value.
pub fn ST_ThicknessPercent::parse(
  s : String,
) -> ST_ThicknessPercent raise SchemaViolation {
  validate_non_empty("dml-chart.xsd", "ST_ThicknessPercent", s)
  { value: s }
}

///|
/// Construct ST_ThicknessPercent while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_ThicknessPercent::new(
  s : String,
) -> ST_ThicknessPercent raise SchemaViolation {
  ST_ThicknessPercent::parse(s)
}

///|
/// Return the schema lexical value for ST_ThicknessPercent.
pub fn ST_ThicknessPercent::to_string(self : ST_ThicknessPercent) -> String {
  self.value
}

///|
/// XSD simple type ST_GapAmount (§21.2, dml-chart.xsd) with base schema-restricted numeric value.
pub struct ST_GapAmount {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_GapAmount schema lexical value.
pub fn ST_GapAmount::parse(s : String) -> ST_GapAmount raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_GapAmount", s)
  { value: s }
}

///|
/// Construct ST_GapAmount while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_GapAmount::new(s : String) -> ST_GapAmount raise SchemaViolation {
  ST_GapAmount::parse(s)
}

///|
/// Return the schema lexical value for ST_GapAmount.
pub fn ST_GapAmount::to_string(self : ST_GapAmount) -> String {
  self.value
}

///|
/// XSD simple type ST_GapAmountPercent (§21.2, dml-chart.xsd) with base xsd:string.
pub struct ST_GapAmountPercent {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_GapAmountPercent schema lexical value.
pub fn ST_GapAmountPercent::parse(
  s : String,
) -> ST_GapAmountPercent raise SchemaViolation {
  validate_non_empty("dml-chart.xsd", "ST_GapAmountPercent", s)
  { value: s }
}

///|
/// Construct ST_GapAmountPercent while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_GapAmountPercent::new(
  s : String,
) -> ST_GapAmountPercent raise SchemaViolation {
  ST_GapAmountPercent::parse(s)
}

///|
/// Return the schema lexical value for ST_GapAmountPercent.
pub fn ST_GapAmountPercent::to_string(self : ST_GapAmountPercent) -> String {
  self.value
}

///|
/// XSD simple type ST_Overlap (§21.2, dml-chart.xsd) with base schema-restricted numeric value.
pub struct ST_Overlap {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_Overlap schema lexical value.
pub fn ST_Overlap::parse(s : String) -> ST_Overlap raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_Overlap", s)
  { value: s }
}

///|
/// Construct ST_Overlap while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_Overlap::new(s : String) -> ST_Overlap raise SchemaViolation {
  ST_Overlap::parse(s)
}

///|
/// Return the schema lexical value for ST_Overlap.
pub fn ST_Overlap::to_string(self : ST_Overlap) -> String {
  self.value
}

///|
/// XSD simple type ST_OverlapPercent (§21.2, dml-chart.xsd) with base xsd:string.
pub struct ST_OverlapPercent {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_OverlapPercent schema lexical value.
pub fn ST_OverlapPercent::parse(
  s : String,
) -> ST_OverlapPercent raise SchemaViolation {
  validate_non_empty("dml-chart.xsd", "ST_OverlapPercent", s)
  { value: s }
}

///|
/// Construct ST_OverlapPercent while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_OverlapPercent::new(
  s : String,
) -> ST_OverlapPercent raise SchemaViolation {
  ST_OverlapPercent::parse(s)
}

///|
/// Return the schema lexical value for ST_OverlapPercent.
pub fn ST_OverlapPercent::to_string(self : ST_OverlapPercent) -> String {
  self.value
}

///|
/// XSD simple type ST_BubbleScale (§21.2, dml-chart.xsd) with base schema-restricted numeric value.
pub struct ST_BubbleScale {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_BubbleScale schema lexical value.
pub fn ST_BubbleScale::parse(
  s : String,
) -> ST_BubbleScale raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_BubbleScale", s)
  { value: s }
}

///|
/// Construct ST_BubbleScale while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_BubbleScale::new(s : String) -> ST_BubbleScale raise SchemaViolation {
  ST_BubbleScale::parse(s)
}

///|
/// Return the schema lexical value for ST_BubbleScale.
pub fn ST_BubbleScale::to_string(self : ST_BubbleScale) -> String {
  self.value
}

///|
/// XSD simple type ST_BubbleScalePercent (§21.2, dml-chart.xsd) with base xsd:string.
pub struct ST_BubbleScalePercent {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_BubbleScalePercent schema lexical value.
pub fn ST_BubbleScalePercent::parse(
  s : String,
) -> ST_BubbleScalePercent raise SchemaViolation {
  validate_non_empty("dml-chart.xsd", "ST_BubbleScalePercent", s)
  { value: s }
}

///|
/// Construct ST_BubbleScalePercent while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_BubbleScalePercent::new(
  s : String,
) -> ST_BubbleScalePercent raise SchemaViolation {
  ST_BubbleScalePercent::parse(s)
}

///|
/// Return the schema lexical value for ST_BubbleScalePercent.
pub fn ST_BubbleScalePercent::to_string(self : ST_BubbleScalePercent) -> String {
  self.value
}

///|
/// XSD simple type ST_SizeRepresents (§21.2, dml-chart.xsd).
pub(all) enum ST_SizeRepresents {
  SizeRepresentsArea
  SizeRepresentsW
} derive(Eq, Debug)

///|
/// Parse the ST_SizeRepresents schema lexical value.
pub fn ST_SizeRepresents::parse(
  s : String,
) -> ST_SizeRepresents raise SchemaViolation {
  match s {
    "area" => SizeRepresentsArea
    "w" => SizeRepresentsW
    _ => invalid("dml-chart.xsd", "ST_SizeRepresents", s)
  }
}

///|
/// Construct ST_SizeRepresents while enforcing the dml-chart.xsd enumeration.
pub fn ST_SizeRepresents::new(
  s : String,
) -> ST_SizeRepresents raise SchemaViolation {
  ST_SizeRepresents::parse(s)
}

///|
/// Return the schema lexical value for ST_SizeRepresents.
pub fn ST_SizeRepresents::to_string(self : ST_SizeRepresents) -> String {
  match self {
    SizeRepresentsArea => "area"
    SizeRepresentsW => "w"
  }
}

///|
/// XSD simple type ST_FirstSliceAng (§21.2, dml-chart.xsd) with base xsd:unsignedShort.
pub struct ST_FirstSliceAng {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_FirstSliceAng schema lexical value.
pub fn ST_FirstSliceAng::parse(
  s : String,
) -> ST_FirstSliceAng raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_FirstSliceAng", s)
  { value: s }
}

///|
/// Construct ST_FirstSliceAng while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_FirstSliceAng::new(
  s : String,
) -> ST_FirstSliceAng raise SchemaViolation {
  ST_FirstSliceAng::parse(s)
}

///|
/// Return the schema lexical value for ST_FirstSliceAng.
pub fn ST_FirstSliceAng::to_string(self : ST_FirstSliceAng) -> String {
  self.value
}

///|
/// XSD simple type ST_HoleSize (§21.2, dml-chart.xsd) with base schema-restricted numeric value.
pub struct ST_HoleSize {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_HoleSize schema lexical value.
pub fn ST_HoleSize::parse(s : String) -> ST_HoleSize raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_HoleSize", s)
  { value: s }
}

///|
/// Construct ST_HoleSize while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_HoleSize::new(s : String) -> ST_HoleSize raise SchemaViolation {
  ST_HoleSize::parse(s)
}

///|
/// Return the schema lexical value for ST_HoleSize.
pub fn ST_HoleSize::to_string(self : ST_HoleSize) -> String {
  self.value
}

///|
/// XSD simple type ST_HoleSizePercent (§21.2, dml-chart.xsd) with base xsd:string.
pub struct ST_HoleSizePercent {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_HoleSizePercent schema lexical value.
pub fn ST_HoleSizePercent::parse(
  s : String,
) -> ST_HoleSizePercent raise SchemaViolation {
  validate_non_empty("dml-chart.xsd", "ST_HoleSizePercent", s)
  { value: s }
}

///|
/// Construct ST_HoleSizePercent while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_HoleSizePercent::new(
  s : String,
) -> ST_HoleSizePercent raise SchemaViolation {
  ST_HoleSizePercent::parse(s)
}

///|
/// Return the schema lexical value for ST_HoleSizePercent.
pub fn ST_HoleSizePercent::to_string(self : ST_HoleSizePercent) -> String {
  self.value
}

///|
/// XSD simple type ST_SplitType (§21.2, dml-chart.xsd).
pub(all) enum ST_SplitType {
  SplitTypeAuto
  SplitTypeCust
  SplitTypePercent
  SplitTypePos
  SplitTypeVal
} derive(Eq, Debug)

///|
/// Parse the ST_SplitType schema lexical value.
pub fn ST_SplitType::parse(s : String) -> ST_SplitType raise SchemaViolation {
  match s {
    "auto" => SplitTypeAuto
    "cust" => SplitTypeCust
    "percent" => SplitTypePercent
    "pos" => SplitTypePos
    "val" => SplitTypeVal
    _ => invalid("dml-chart.xsd", "ST_SplitType", s)
  }
}

///|
/// Construct ST_SplitType while enforcing the dml-chart.xsd enumeration.
pub fn ST_SplitType::new(s : String) -> ST_SplitType raise SchemaViolation {
  ST_SplitType::parse(s)
}

///|
/// Return the schema lexical value for ST_SplitType.
pub fn ST_SplitType::to_string(self : ST_SplitType) -> String {
  match self {
    SplitTypeAuto => "auto"
    SplitTypeCust => "cust"
    SplitTypePercent => "percent"
    SplitTypePos => "pos"
    SplitTypeVal => "val"
  }
}

///|
/// XSD simple type ST_SecondPieSize (§21.2, dml-chart.xsd) with base schema-restricted numeric value.
pub struct ST_SecondPieSize {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_SecondPieSize schema lexical value.
pub fn ST_SecondPieSize::parse(
  s : String,
) -> ST_SecondPieSize raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_SecondPieSize", s)
  { value: s }
}

///|
/// Construct ST_SecondPieSize while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_SecondPieSize::new(
  s : String,
) -> ST_SecondPieSize raise SchemaViolation {
  ST_SecondPieSize::parse(s)
}

///|
/// Return the schema lexical value for ST_SecondPieSize.
pub fn ST_SecondPieSize::to_string(self : ST_SecondPieSize) -> String {
  self.value
}

///|
/// XSD simple type ST_SecondPieSizePercent (§21.2, dml-chart.xsd) with base xsd:string.
pub struct ST_SecondPieSizePercent {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_SecondPieSizePercent schema lexical value.
pub fn ST_SecondPieSizePercent::parse(
  s : String,
) -> ST_SecondPieSizePercent raise SchemaViolation {
  validate_non_empty("dml-chart.xsd", "ST_SecondPieSizePercent", s)
  { value: s }
}

///|
/// Construct ST_SecondPieSizePercent while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_SecondPieSizePercent::new(
  s : String,
) -> ST_SecondPieSizePercent raise SchemaViolation {
  ST_SecondPieSizePercent::parse(s)
}

///|
/// Return the schema lexical value for ST_SecondPieSizePercent.
pub fn ST_SecondPieSizePercent::to_string(
  self : ST_SecondPieSizePercent,
) -> String {
  self.value
}

///|
/// XSD simple type ST_LblAlgn (§21.2, dml-chart.xsd).
pub(all) enum ST_LblAlgn {
  LblAlgnCtr
  LblAlgnL
  LblAlgnR
} derive(Eq, Debug)

///|
/// Parse the ST_LblAlgn schema lexical value.
pub fn ST_LblAlgn::parse(s : String) -> ST_LblAlgn raise SchemaViolation {
  match s {
    "ctr" => LblAlgnCtr
    "l" => LblAlgnL
    "r" => LblAlgnR
    _ => invalid("dml-chart.xsd", "ST_LblAlgn", s)
  }
}

///|
/// Construct ST_LblAlgn while enforcing the dml-chart.xsd enumeration.
pub fn ST_LblAlgn::new(s : String) -> ST_LblAlgn raise SchemaViolation {
  ST_LblAlgn::parse(s)
}

///|
/// Return the schema lexical value for ST_LblAlgn.
pub fn ST_LblAlgn::to_string(self : ST_LblAlgn) -> String {
  match self {
    LblAlgnCtr => "ctr"
    LblAlgnL => "l"
    LblAlgnR => "r"
  }
}

///|
/// XSD simple type ST_DLblPos (§21.2, dml-chart.xsd).
pub(all) enum ST_DLblPos {
  DLblPosBestFit
  DLblPosB
  DLblPosCtr
  DLblPosInBase
  DLblPosInEnd
  DLblPosL
  DLblPosOutEnd
  DLblPosR
  DLblPosT
} derive(Eq, Debug)

///|
/// Parse the ST_DLblPos schema lexical value.
pub fn ST_DLblPos::parse(s : String) -> ST_DLblPos raise SchemaViolation {
  match s {
    "bestFit" => DLblPosBestFit
    "b" => DLblPosB
    "ctr" => DLblPosCtr
    "inBase" => DLblPosInBase
    "inEnd" => DLblPosInEnd
    "l" => DLblPosL
    "outEnd" => DLblPosOutEnd
    "r" => DLblPosR
    "t" => DLblPosT
    _ => invalid("dml-chart.xsd", "ST_DLblPos", s)
  }
}

///|
/// Construct ST_DLblPos while enforcing the dml-chart.xsd enumeration.
pub fn ST_DLblPos::new(s : String) -> ST_DLblPos raise SchemaViolation {
  ST_DLblPos::parse(s)
}

///|
/// Return the schema lexical value for ST_DLblPos.
pub fn ST_DLblPos::to_string(self : ST_DLblPos) -> String {
  match self {
    DLblPosBestFit => "bestFit"
    DLblPosB => "b"
    DLblPosCtr => "ctr"
    DLblPosInBase => "inBase"
    DLblPosInEnd => "inEnd"
    DLblPosL => "l"
    DLblPosOutEnd => "outEnd"
    DLblPosR => "r"
    DLblPosT => "t"
  }
}

///|
/// XSD simple type ST_MarkerStyle (§21.2, dml-chart.xsd).
pub(all) enum ST_MarkerStyle {
  MarkerStyleCircle
  MarkerStyleDash
  MarkerStyleDiamond
  MarkerStyleDot
  MarkerStyleNone
  MarkerStylePicture
  MarkerStylePlus
  MarkerStyleSquare
  MarkerStyleStar
  MarkerStyleTriangle
  MarkerStyleX
  MarkerStyleAuto
} derive(Eq, Debug)

///|
/// Parse the ST_MarkerStyle schema lexical value.
pub fn ST_MarkerStyle::parse(
  s : String,
) -> ST_MarkerStyle raise SchemaViolation {
  match s {
    "circle" => MarkerStyleCircle
    "dash" => MarkerStyleDash
    "diamond" => MarkerStyleDiamond
    "dot" => MarkerStyleDot
    "none" => MarkerStyleNone
    "picture" => MarkerStylePicture
    "plus" => MarkerStylePlus
    "square" => MarkerStyleSquare
    "star" => MarkerStyleStar
    "triangle" => MarkerStyleTriangle
    "x" => MarkerStyleX
    "auto" => MarkerStyleAuto
    _ => invalid("dml-chart.xsd", "ST_MarkerStyle", s)
  }
}

///|
/// Construct ST_MarkerStyle while enforcing the dml-chart.xsd enumeration.
pub fn ST_MarkerStyle::new(s : String) -> ST_MarkerStyle raise SchemaViolation {
  ST_MarkerStyle::parse(s)
}

///|
/// Return the schema lexical value for ST_MarkerStyle.
pub fn ST_MarkerStyle::to_string(self : ST_MarkerStyle) -> String {
  match self {
    MarkerStyleCircle => "circle"
    MarkerStyleDash => "dash"
    MarkerStyleDiamond => "diamond"
    MarkerStyleDot => "dot"
    MarkerStyleNone => "none"
    MarkerStylePicture => "picture"
    MarkerStylePlus => "plus"
    MarkerStyleSquare => "square"
    MarkerStyleStar => "star"
    MarkerStyleTriangle => "triangle"
    MarkerStyleX => "x"
    MarkerStyleAuto => "auto"
  }
}

///|
/// XSD simple type ST_MarkerSize (§21.2, dml-chart.xsd) with base xsd:unsignedByte.
pub struct ST_MarkerSize {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_MarkerSize schema lexical value.
pub fn ST_MarkerSize::parse(s : String) -> ST_MarkerSize raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_MarkerSize", s)
  { value: s }
}

///|
/// Construct ST_MarkerSize while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_MarkerSize::new(s : String) -> ST_MarkerSize raise SchemaViolation {
  ST_MarkerSize::parse(s)
}

///|
/// Return the schema lexical value for ST_MarkerSize.
pub fn ST_MarkerSize::to_string(self : ST_MarkerSize) -> String {
  self.value
}

///|
/// XSD simple type ST_TrendlineType (§21.2, dml-chart.xsd).
pub(all) enum ST_TrendlineType {
  TrendlineTypeExp
  TrendlineTypeLinear
  TrendlineTypeLog
  TrendlineTypeMovingAvg
  TrendlineTypePoly
  TrendlineTypePower
} derive(Eq, Debug)

///|
/// Parse the ST_TrendlineType schema lexical value.
pub fn ST_TrendlineType::parse(
  s : String,
) -> ST_TrendlineType raise SchemaViolation {
  match s {
    "exp" => TrendlineTypeExp
    "linear" => TrendlineTypeLinear
    "log" => TrendlineTypeLog
    "movingAvg" => TrendlineTypeMovingAvg
    "poly" => TrendlineTypePoly
    "power" => TrendlineTypePower
    _ => invalid("dml-chart.xsd", "ST_TrendlineType", s)
  }
}

///|
/// Construct ST_TrendlineType while enforcing the dml-chart.xsd enumeration.
pub fn ST_TrendlineType::new(
  s : String,
) -> ST_TrendlineType raise SchemaViolation {
  ST_TrendlineType::parse(s)
}

///|
/// Return the schema lexical value for ST_TrendlineType.
pub fn ST_TrendlineType::to_string(self : ST_TrendlineType) -> String {
  match self {
    TrendlineTypeExp => "exp"
    TrendlineTypeLinear => "linear"
    TrendlineTypeLog => "log"
    TrendlineTypeMovingAvg => "movingAvg"
    TrendlineTypePoly => "poly"
    TrendlineTypePower => "power"
  }
}

///|
/// XSD simple type ST_Order (§21.2, dml-chart.xsd) with base xsd:unsignedByte.
pub struct ST_Order {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_Order schema lexical value.
pub fn ST_Order::parse(s : String) -> ST_Order raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_Order", s)
  { value: s }
}

///|
/// Construct ST_Order while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_Order::new(s : String) -> ST_Order raise SchemaViolation {
  ST_Order::parse(s)
}

///|
/// Return the schema lexical value for ST_Order.
pub fn ST_Order::to_string(self : ST_Order) -> String {
  self.value
}

///|
/// XSD simple type ST_Period (§21.2, dml-chart.xsd) with base xsd:unsignedInt.
pub struct ST_Period {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_Period schema lexical value.
pub fn ST_Period::parse(s : String) -> ST_Period raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_Period", s)
  { value: s }
}

///|
/// Construct ST_Period while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_Period::new(s : String) -> ST_Period raise SchemaViolation {
  ST_Period::parse(s)
}

///|
/// Return the schema lexical value for ST_Period.
pub fn ST_Period::to_string(self : ST_Period) -> String {
  self.value
}

///|
/// XSD simple type ST_ErrDir (§21.2, dml-chart.xsd).
pub(all) enum ST_ErrDir {
  ErrDirX
  ErrDirY
} derive(Eq, Debug)

///|
/// Parse the ST_ErrDir schema lexical value.
pub fn ST_ErrDir::parse(s : String) -> ST_ErrDir raise SchemaViolation {
  match s {
    "x" => ErrDirX
    "y" => ErrDirY
    _ => invalid("dml-chart.xsd", "ST_ErrDir", s)
  }
}

///|
/// Construct ST_ErrDir while enforcing the dml-chart.xsd enumeration.
pub fn ST_ErrDir::new(s : String) -> ST_ErrDir raise SchemaViolation {
  ST_ErrDir::parse(s)
}

///|
/// Return the schema lexical value for ST_ErrDir.
pub fn ST_ErrDir::to_string(self : ST_ErrDir) -> String {
  match self {
    ErrDirX => "x"
    ErrDirY => "y"
  }
}

///|
/// XSD simple type ST_ErrBarType (§21.2, dml-chart.xsd).
pub(all) enum ST_ErrBarType {
  ErrBarTypeBoth
  ErrBarTypeMinus
  ErrBarTypePlus
} derive(Eq, Debug)

///|
/// Parse the ST_ErrBarType schema lexical value.
pub fn ST_ErrBarType::parse(s : String) -> ST_ErrBarType raise SchemaViolation {
  match s {
    "both" => ErrBarTypeBoth
    "minus" => ErrBarTypeMinus
    "plus" => ErrBarTypePlus
    _ => invalid("dml-chart.xsd", "ST_ErrBarType", s)
  }
}

///|
/// Construct ST_ErrBarType while enforcing the dml-chart.xsd enumeration.
pub fn ST_ErrBarType::new(s : String) -> ST_ErrBarType raise SchemaViolation {
  ST_ErrBarType::parse(s)
}

///|
/// Return the schema lexical value for ST_ErrBarType.
pub fn ST_ErrBarType::to_string(self : ST_ErrBarType) -> String {
  match self {
    ErrBarTypeBoth => "both"
    ErrBarTypeMinus => "minus"
    ErrBarTypePlus => "plus"
  }
}

///|
/// XSD simple type ST_ErrValType (§21.2, dml-chart.xsd).
pub(all) enum ST_ErrValType {
  ErrValTypeCust
  ErrValTypeFixedVal
  ErrValTypePercentage
  ErrValTypeStdDev
  ErrValTypeStdErr
} derive(Eq, Debug)

///|
/// Parse the ST_ErrValType schema lexical value.
pub fn ST_ErrValType::parse(s : String) -> ST_ErrValType raise SchemaViolation {
  match s {
    "cust" => ErrValTypeCust
    "fixedVal" => ErrValTypeFixedVal
    "percentage" => ErrValTypePercentage
    "stdDev" => ErrValTypeStdDev
    "stdErr" => ErrValTypeStdErr
    _ => invalid("dml-chart.xsd", "ST_ErrValType", s)
  }
}

///|
/// Construct ST_ErrValType while enforcing the dml-chart.xsd enumeration.
pub fn ST_ErrValType::new(s : String) -> ST_ErrValType raise SchemaViolation {
  ST_ErrValType::parse(s)
}

///|
/// Return the schema lexical value for ST_ErrValType.
pub fn ST_ErrValType::to_string(self : ST_ErrValType) -> String {
  match self {
    ErrValTypeCust => "cust"
    ErrValTypeFixedVal => "fixedVal"
    ErrValTypePercentage => "percentage"
    ErrValTypeStdDev => "stdDev"
    ErrValTypeStdErr => "stdErr"
  }
}

///|
/// XSD simple type ST_Grouping (§21.2, dml-chart.xsd).
pub(all) enum ST_Grouping {
  GroupingPercentStacked
  GroupingStandard
  GroupingStacked
} derive(Eq, Debug)

///|
/// Parse the ST_Grouping schema lexical value.
pub fn ST_Grouping::parse(s : String) -> ST_Grouping raise SchemaViolation {
  match s {
    "percentStacked" => GroupingPercentStacked
    "standard" => GroupingStandard
    "stacked" => GroupingStacked
    _ => invalid("dml-chart.xsd", "ST_Grouping", s)
  }
}

///|
/// Construct ST_Grouping while enforcing the dml-chart.xsd enumeration.
pub fn ST_Grouping::new(s : String) -> ST_Grouping raise SchemaViolation {
  ST_Grouping::parse(s)
}

///|
/// Return the schema lexical value for ST_Grouping.
pub fn ST_Grouping::to_string(self : ST_Grouping) -> String {
  match self {
    GroupingPercentStacked => "percentStacked"
    GroupingStandard => "standard"
    GroupingStacked => "stacked"
  }
}

///|
/// XSD simple type ST_ScatterStyle (§21.2, dml-chart.xsd).
pub(all) enum ST_ScatterStyle {
  ScatterStyleNone
  ScatterStyleLine
  ScatterStyleLineMarker
  ScatterStyleMarker
  ScatterStyleSmooth
  ScatterStyleSmoothMarker
} derive(Eq, Debug)

///|
/// Parse the ST_ScatterStyle schema lexical value.
pub fn ST_ScatterStyle::parse(
  s : String,
) -> ST_ScatterStyle raise SchemaViolation {
  match s {
    "none" => ScatterStyleNone
    "line" => ScatterStyleLine
    "lineMarker" => ScatterStyleLineMarker
    "marker" => ScatterStyleMarker
    "smooth" => ScatterStyleSmooth
    "smoothMarker" => ScatterStyleSmoothMarker
    _ => invalid("dml-chart.xsd", "ST_ScatterStyle", s)
  }
}

///|
/// Construct ST_ScatterStyle while enforcing the dml-chart.xsd enumeration.
pub fn ST_ScatterStyle::new(
  s : String,
) -> ST_ScatterStyle raise SchemaViolation {
  ST_ScatterStyle::parse(s)
}

///|
/// Return the schema lexical value for ST_ScatterStyle.
pub fn ST_ScatterStyle::to_string(self : ST_ScatterStyle) -> String {
  match self {
    ScatterStyleNone => "none"
    ScatterStyleLine => "line"
    ScatterStyleLineMarker => "lineMarker"
    ScatterStyleMarker => "marker"
    ScatterStyleSmooth => "smooth"
    ScatterStyleSmoothMarker => "smoothMarker"
  }
}

///|
/// XSD simple type ST_RadarStyle (§21.2, dml-chart.xsd).
pub(all) enum ST_RadarStyle {
  RadarStyleStandard
  RadarStyleMarker
  RadarStyleFilled
} derive(Eq, Debug)

///|
/// Parse the ST_RadarStyle schema lexical value.
pub fn ST_RadarStyle::parse(s : String) -> ST_RadarStyle raise SchemaViolation {
  match s {
    "standard" => RadarStyleStandard
    "marker" => RadarStyleMarker
    "filled" => RadarStyleFilled
    _ => invalid("dml-chart.xsd", "ST_RadarStyle", s)
  }
}

///|
/// Construct ST_RadarStyle while enforcing the dml-chart.xsd enumeration.
pub fn ST_RadarStyle::new(s : String) -> ST_RadarStyle raise SchemaViolation {
  ST_RadarStyle::parse(s)
}

///|
/// Return the schema lexical value for ST_RadarStyle.
pub fn ST_RadarStyle::to_string(self : ST_RadarStyle) -> String {
  match self {
    RadarStyleStandard => "standard"
    RadarStyleMarker => "marker"
    RadarStyleFilled => "filled"
  }
}

///|
/// XSD simple type ST_BarGrouping (§21.2, dml-chart.xsd).
pub(all) enum ST_BarGrouping {
  BarGroupingPercentStacked
  BarGroupingClustered
  BarGroupingStandard
  BarGroupingStacked
} derive(Eq, Debug)

///|
/// Parse the ST_BarGrouping schema lexical value.
pub fn ST_BarGrouping::parse(
  s : String,
) -> ST_BarGrouping raise SchemaViolation {
  match s {
    "percentStacked" => BarGroupingPercentStacked
    "clustered" => BarGroupingClustered
    "standard" => BarGroupingStandard
    "stacked" => BarGroupingStacked
    _ => invalid("dml-chart.xsd", "ST_BarGrouping", s)
  }
}

///|
/// Construct ST_BarGrouping while enforcing the dml-chart.xsd enumeration.
pub fn ST_BarGrouping::new(s : String) -> ST_BarGrouping raise SchemaViolation {
  ST_BarGrouping::parse(s)
}

///|
/// Return the schema lexical value for ST_BarGrouping.
pub fn ST_BarGrouping::to_string(self : ST_BarGrouping) -> String {
  match self {
    BarGroupingPercentStacked => "percentStacked"
    BarGroupingClustered => "clustered"
    BarGroupingStandard => "standard"
    BarGroupingStacked => "stacked"
  }
}

///|
/// XSD simple type ST_BarDir (§21.2, dml-chart.xsd).
pub(all) enum ST_BarDir {
  BarDirBar
  BarDirCol
} derive(Eq, Debug)

///|
/// Parse the ST_BarDir schema lexical value.
pub fn ST_BarDir::parse(s : String) -> ST_BarDir raise SchemaViolation {
  match s {
    "bar" => BarDirBar
    "col" => BarDirCol
    _ => invalid("dml-chart.xsd", "ST_BarDir", s)
  }
}

///|
/// Construct ST_BarDir while enforcing the dml-chart.xsd enumeration.
pub fn ST_BarDir::new(s : String) -> ST_BarDir raise SchemaViolation {
  ST_BarDir::parse(s)
}

///|
/// Return the schema lexical value for ST_BarDir.
pub fn ST_BarDir::to_string(self : ST_BarDir) -> String {
  match self {
    BarDirBar => "bar"
    BarDirCol => "col"
  }
}

///|
/// XSD simple type ST_Shape (§21.2, dml-chart.xsd).
pub(all) enum ST_Shape {
  ShapeCone
  ShapeConeToMax
  ShapeBox
  ShapeCylinder
  ShapePyramid
  ShapePyramidToMax
} derive(Eq, Debug)

///|
/// Parse the ST_Shape schema lexical value.
pub fn ST_Shape::parse(s : String) -> ST_Shape raise SchemaViolation {
  match s {
    "cone" => ShapeCone
    "coneToMax" => ShapeConeToMax
    "box" => ShapeBox
    "cylinder" => ShapeCylinder
    "pyramid" => ShapePyramid
    "pyramidToMax" => ShapePyramidToMax
    _ => invalid("dml-chart.xsd", "ST_Shape", s)
  }
}

///|
/// Construct ST_Shape while enforcing the dml-chart.xsd enumeration.
pub fn ST_Shape::new(s : String) -> ST_Shape raise SchemaViolation {
  ST_Shape::parse(s)
}

///|
/// Return the schema lexical value for ST_Shape.
pub fn ST_Shape::to_string(self : ST_Shape) -> String {
  match self {
    ShapeCone => "cone"
    ShapeConeToMax => "coneToMax"
    ShapeBox => "box"
    ShapeCylinder => "cylinder"
    ShapePyramid => "pyramid"
    ShapePyramidToMax => "pyramidToMax"
  }
}

///|
/// Parse ST_Shape chart shape values: cone, coneToMax, box, cylinder, pyramid, and pyramidToMax.
pub fn parse_st_shape(s : String) -> ST_Shape raise SchemaViolation {
  ST_Shape::parse(s)
}

///|
/// XSD simple type ST_OfPieType (§21.2, dml-chart.xsd).
pub(all) enum ST_OfPieType {
  OfPieTypePie
  OfPieTypeBar
} derive(Eq, Debug)

///|
/// Parse the ST_OfPieType schema lexical value.
pub fn ST_OfPieType::parse(s : String) -> ST_OfPieType raise SchemaViolation {
  match s {
    "pie" => OfPieTypePie
    "bar" => OfPieTypeBar
    _ => invalid("dml-chart.xsd", "ST_OfPieType", s)
  }
}

///|
/// Construct ST_OfPieType while enforcing the dml-chart.xsd enumeration.
pub fn ST_OfPieType::new(s : String) -> ST_OfPieType raise SchemaViolation {
  ST_OfPieType::parse(s)
}

///|
/// Return the schema lexical value for ST_OfPieType.
pub fn ST_OfPieType::to_string(self : ST_OfPieType) -> String {
  match self {
    OfPieTypePie => "pie"
    OfPieTypeBar => "bar"
  }
}

///|
/// XSD simple type ST_AxPos (§21.2, dml-chart.xsd).
pub(all) enum ST_AxPos {
  AxPosB
  AxPosL
  AxPosR
  AxPosT
} derive(Eq, Debug)

///|
/// Parse the ST_AxPos schema lexical value.
pub fn ST_AxPos::parse(s : String) -> ST_AxPos raise SchemaViolation {
  match s {
    "b" => AxPosB
    "l" => AxPosL
    "r" => AxPosR
    "t" => AxPosT
    _ => invalid("dml-chart.xsd", "ST_AxPos", s)
  }
}

///|
/// Construct ST_AxPos while enforcing the dml-chart.xsd enumeration.
pub fn ST_AxPos::new(s : String) -> ST_AxPos raise SchemaViolation {
  ST_AxPos::parse(s)
}

///|
/// Return the schema lexical value for ST_AxPos.
pub fn ST_AxPos::to_string(self : ST_AxPos) -> String {
  match self {
    AxPosB => "b"
    AxPosL => "l"
    AxPosR => "r"
    AxPosT => "t"
  }
}

///|
/// XSD simple type ST_Crosses (§21.2, dml-chart.xsd).
pub(all) enum ST_Crosses {
  CrossesAutoZero
  CrossesMax
  CrossesMin
} derive(Eq, Debug)

///|
/// Parse the ST_Crosses schema lexical value.
pub fn ST_Crosses::parse(s : String) -> ST_Crosses raise SchemaViolation {
  match s {
    "autoZero" => CrossesAutoZero
    "max" => CrossesMax
    "min" => CrossesMin
    _ => invalid("dml-chart.xsd", "ST_Crosses", s)
  }
}

///|
/// Construct ST_Crosses while enforcing the dml-chart.xsd enumeration.
pub fn ST_Crosses::new(s : String) -> ST_Crosses raise SchemaViolation {
  ST_Crosses::parse(s)
}

///|
/// Return the schema lexical value for ST_Crosses.
pub fn ST_Crosses::to_string(self : ST_Crosses) -> String {
  match self {
    CrossesAutoZero => "autoZero"
    CrossesMax => "max"
    CrossesMin => "min"
  }
}

///|
/// XSD simple type ST_CrossBetween (§21.2, dml-chart.xsd).
pub(all) enum ST_CrossBetween {
  CrossBetweenBetween
  CrossBetweenMidCat
} derive(Eq, Debug)

///|
/// Parse the ST_CrossBetween schema lexical value.
pub fn ST_CrossBetween::parse(
  s : String,
) -> ST_CrossBetween raise SchemaViolation {
  match s {
    "between" => CrossBetweenBetween
    "midCat" => CrossBetweenMidCat
    _ => invalid("dml-chart.xsd", "ST_CrossBetween", s)
  }
}

///|
/// Construct ST_CrossBetween while enforcing the dml-chart.xsd enumeration.
pub fn ST_CrossBetween::new(
  s : String,
) -> ST_CrossBetween raise SchemaViolation {
  ST_CrossBetween::parse(s)
}

///|
/// Return the schema lexical value for ST_CrossBetween.
pub fn ST_CrossBetween::to_string(self : ST_CrossBetween) -> String {
  match self {
    CrossBetweenBetween => "between"
    CrossBetweenMidCat => "midCat"
  }
}

///|
/// XSD simple type ST_TickMark (§21.2, dml-chart.xsd).
pub(all) enum ST_TickMark {
  TickMarkCross
  TickMarkInValue
  TickMarkNone
  TickMarkOut
} derive(Eq, Debug)

///|
/// Parse the ST_TickMark schema lexical value.
pub fn ST_TickMark::parse(s : String) -> ST_TickMark raise SchemaViolation {
  match s {
    "cross" => TickMarkCross
    "in" => TickMarkInValue
    "none" => TickMarkNone
    "out" => TickMarkOut
    _ => invalid("dml-chart.xsd", "ST_TickMark", s)
  }
}

///|
/// Construct ST_TickMark while enforcing the dml-chart.xsd enumeration.
pub fn ST_TickMark::new(s : String) -> ST_TickMark raise SchemaViolation {
  ST_TickMark::parse(s)
}

///|
/// Return the schema lexical value for ST_TickMark.
pub fn ST_TickMark::to_string(self : ST_TickMark) -> String {
  match self {
    TickMarkCross => "cross"
    TickMarkInValue => "in"
    TickMarkNone => "none"
    TickMarkOut => "out"
  }
}

///|
/// XSD simple type ST_TickLblPos (§21.2, dml-chart.xsd).
pub(all) enum ST_TickLblPos {
  TickLblPosHigh
  TickLblPosLow
  TickLblPosNextTo
  TickLblPosNone
} derive(Eq, Debug)

///|
/// Parse the ST_TickLblPos schema lexical value.
pub fn ST_TickLblPos::parse(s : String) -> ST_TickLblPos raise SchemaViolation {
  match s {
    "high" => TickLblPosHigh
    "low" => TickLblPosLow
    "nextTo" => TickLblPosNextTo
    "none" => TickLblPosNone
    _ => invalid("dml-chart.xsd", "ST_TickLblPos", s)
  }
}

///|
/// Construct ST_TickLblPos while enforcing the dml-chart.xsd enumeration.
pub fn ST_TickLblPos::new(s : String) -> ST_TickLblPos raise SchemaViolation {
  ST_TickLblPos::parse(s)
}

///|
/// Return the schema lexical value for ST_TickLblPos.
pub fn ST_TickLblPos::to_string(self : ST_TickLblPos) -> String {
  match self {
    TickLblPosHigh => "high"
    TickLblPosLow => "low"
    TickLblPosNextTo => "nextTo"
    TickLblPosNone => "none"
  }
}

///|
/// XSD simple type ST_Skip (§21.2, dml-chart.xsd) with base xsd:unsignedInt.
pub struct ST_Skip {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_Skip schema lexical value.
pub fn ST_Skip::parse(s : String) -> ST_Skip raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_Skip", s)
  { value: s }
}

///|
/// Construct ST_Skip while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_Skip::new(s : String) -> ST_Skip raise SchemaViolation {
  ST_Skip::parse(s)
}

///|
/// Return the schema lexical value for ST_Skip.
pub fn ST_Skip::to_string(self : ST_Skip) -> String {
  self.value
}

///|
/// XSD simple type ST_TimeUnit (§21.2, dml-chart.xsd).
pub(all) enum ST_TimeUnit {
  TimeUnitDays
  TimeUnitMonths
  TimeUnitYears
} derive(Eq, Debug)

///|
/// Parse the ST_TimeUnit schema lexical value.
pub fn ST_TimeUnit::parse(s : String) -> ST_TimeUnit raise SchemaViolation {
  match s {
    "days" => TimeUnitDays
    "months" => TimeUnitMonths
    "years" => TimeUnitYears
    _ => invalid("dml-chart.xsd", "ST_TimeUnit", s)
  }
}

///|
/// Construct ST_TimeUnit while enforcing the dml-chart.xsd enumeration.
pub fn ST_TimeUnit::new(s : String) -> ST_TimeUnit raise SchemaViolation {
  ST_TimeUnit::parse(s)
}

///|
/// Return the schema lexical value for ST_TimeUnit.
pub fn ST_TimeUnit::to_string(self : ST_TimeUnit) -> String {
  match self {
    TimeUnitDays => "days"
    TimeUnitMonths => "months"
    TimeUnitYears => "years"
  }
}

///|
/// XSD simple type ST_AxisUnit (§21.2, dml-chart.xsd) with base xsd:double.
pub struct ST_AxisUnit {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_AxisUnit schema lexical value.
pub fn ST_AxisUnit::parse(s : String) -> ST_AxisUnit raise SchemaViolation {
  validate_double("dml-chart.xsd", "ST_AxisUnit", s)
  { value: s }
}

///|
/// Construct ST_AxisUnit while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_AxisUnit::new(s : String) -> ST_AxisUnit raise SchemaViolation {
  ST_AxisUnit::parse(s)
}

///|
/// Return the schema lexical value for ST_AxisUnit.
pub fn ST_AxisUnit::to_string(self : ST_AxisUnit) -> String {
  self.value
}

///|
/// XSD simple type ST_BuiltInUnit (§21.2, dml-chart.xsd).
pub(all) enum ST_BuiltInUnit {
  BuiltInUnitHundreds
  BuiltInUnitThousands
  BuiltInUnitTenThousands
  BuiltInUnitHundredThousands
  BuiltInUnitMillions
  BuiltInUnitTenMillions
  BuiltInUnitHundredMillions
  BuiltInUnitBillions
  BuiltInUnitTrillions
} derive(Eq, Debug)

///|
/// Parse the ST_BuiltInUnit schema lexical value.
pub fn ST_BuiltInUnit::parse(
  s : String,
) -> ST_BuiltInUnit raise SchemaViolation {
  match s {
    "hundreds" => BuiltInUnitHundreds
    "thousands" => BuiltInUnitThousands
    "tenThousands" => BuiltInUnitTenThousands
    "hundredThousands" => BuiltInUnitHundredThousands
    "millions" => BuiltInUnitMillions
    "tenMillions" => BuiltInUnitTenMillions
    "hundredMillions" => BuiltInUnitHundredMillions
    "billions" => BuiltInUnitBillions
    "trillions" => BuiltInUnitTrillions
    _ => invalid("dml-chart.xsd", "ST_BuiltInUnit", s)
  }
}

///|
/// Construct ST_BuiltInUnit while enforcing the dml-chart.xsd enumeration.
pub fn ST_BuiltInUnit::new(s : String) -> ST_BuiltInUnit raise SchemaViolation {
  ST_BuiltInUnit::parse(s)
}

///|
/// Return the schema lexical value for ST_BuiltInUnit.
pub fn ST_BuiltInUnit::to_string(self : ST_BuiltInUnit) -> String {
  match self {
    BuiltInUnitHundreds => "hundreds"
    BuiltInUnitThousands => "thousands"
    BuiltInUnitTenThousands => "tenThousands"
    BuiltInUnitHundredThousands => "hundredThousands"
    BuiltInUnitMillions => "millions"
    BuiltInUnitTenMillions => "tenMillions"
    BuiltInUnitHundredMillions => "hundredMillions"
    BuiltInUnitBillions => "billions"
    BuiltInUnitTrillions => "trillions"
  }
}

///|
/// XSD simple type ST_PictureFormat (§21.2, dml-chart.xsd).
pub(all) enum ST_PictureFormat {
  PictureFormatStretch
  PictureFormatStack
  PictureFormatStackScale
} derive(Eq, Debug)

///|
/// Parse the ST_PictureFormat schema lexical value.
pub fn ST_PictureFormat::parse(
  s : String,
) -> ST_PictureFormat raise SchemaViolation {
  match s {
    "stretch" => PictureFormatStretch
    "stack" => PictureFormatStack
    "stackScale" => PictureFormatStackScale
    _ => invalid("dml-chart.xsd", "ST_PictureFormat", s)
  }
}

///|
/// Construct ST_PictureFormat while enforcing the dml-chart.xsd enumeration.
pub fn ST_PictureFormat::new(
  s : String,
) -> ST_PictureFormat raise SchemaViolation {
  ST_PictureFormat::parse(s)
}

///|
/// Return the schema lexical value for ST_PictureFormat.
pub fn ST_PictureFormat::to_string(self : ST_PictureFormat) -> String {
  match self {
    PictureFormatStretch => "stretch"
    PictureFormatStack => "stack"
    PictureFormatStackScale => "stackScale"
  }
}

///|
/// XSD simple type ST_PictureStackUnit (§21.2, dml-chart.xsd) with base xsd:double.
pub struct ST_PictureStackUnit {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_PictureStackUnit schema lexical value.
pub fn ST_PictureStackUnit::parse(
  s : String,
) -> ST_PictureStackUnit raise SchemaViolation {
  validate_double("dml-chart.xsd", "ST_PictureStackUnit", s)
  { value: s }
}

///|
/// Construct ST_PictureStackUnit while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_PictureStackUnit::new(
  s : String,
) -> ST_PictureStackUnit raise SchemaViolation {
  ST_PictureStackUnit::parse(s)
}

///|
/// Return the schema lexical value for ST_PictureStackUnit.
pub fn ST_PictureStackUnit::to_string(self : ST_PictureStackUnit) -> String {
  self.value
}

///|
/// XSD simple type ST_Orientation (§21.2, dml-chart.xsd).
pub(all) enum ST_Orientation {
  OrientationMaxMin
  OrientationMinMax
} derive(Eq, Debug)

///|
/// Parse the ST_Orientation schema lexical value.
pub fn ST_Orientation::parse(
  s : String,
) -> ST_Orientation raise SchemaViolation {
  match s {
    "maxMin" => OrientationMaxMin
    "minMax" => OrientationMinMax
    _ => invalid("dml-chart.xsd", "ST_Orientation", s)
  }
}

///|
/// Construct ST_Orientation while enforcing the dml-chart.xsd enumeration.
pub fn ST_Orientation::new(s : String) -> ST_Orientation raise SchemaViolation {
  ST_Orientation::parse(s)
}

///|
/// Return the schema lexical value for ST_Orientation.
pub fn ST_Orientation::to_string(self : ST_Orientation) -> String {
  match self {
    OrientationMaxMin => "maxMin"
    OrientationMinMax => "minMax"
  }
}

///|
/// XSD simple type ST_LogBase (§21.2, dml-chart.xsd) with base xsd:double.
pub struct ST_LogBase {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_LogBase schema lexical value.
pub fn ST_LogBase::parse(s : String) -> ST_LogBase raise SchemaViolation {
  validate_double("dml-chart.xsd", "ST_LogBase", s)
  { value: s }
}

///|
/// Construct ST_LogBase while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_LogBase::new(s : String) -> ST_LogBase raise SchemaViolation {
  ST_LogBase::parse(s)
}

///|
/// Return the schema lexical value for ST_LogBase.
pub fn ST_LogBase::to_string(self : ST_LogBase) -> String {
  self.value
}

///|
/// XSD simple type ST_LblOffset (§21.2, dml-chart.xsd) with base schema-restricted numeric value.
pub struct ST_LblOffset {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_LblOffset schema lexical value.
pub fn ST_LblOffset::parse(s : String) -> ST_LblOffset raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_LblOffset", s)
  { value: s }
}

///|
/// Construct ST_LblOffset while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_LblOffset::new(s : String) -> ST_LblOffset raise SchemaViolation {
  ST_LblOffset::parse(s)
}

///|
/// Return the schema lexical value for ST_LblOffset.
pub fn ST_LblOffset::to_string(self : ST_LblOffset) -> String {
  self.value
}

///|
/// XSD simple type ST_LblOffsetPercent (§21.2, dml-chart.xsd) with base xsd:string.
pub struct ST_LblOffsetPercent {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_LblOffsetPercent schema lexical value.
pub fn ST_LblOffsetPercent::parse(
  s : String,
) -> ST_LblOffsetPercent raise SchemaViolation {
  validate_non_empty("dml-chart.xsd", "ST_LblOffsetPercent", s)
  { value: s }
}

///|
/// Construct ST_LblOffsetPercent while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_LblOffsetPercent::new(
  s : String,
) -> ST_LblOffsetPercent raise SchemaViolation {
  ST_LblOffsetPercent::parse(s)
}

///|
/// Return the schema lexical value for ST_LblOffsetPercent.
pub fn ST_LblOffsetPercent::to_string(self : ST_LblOffsetPercent) -> String {
  self.value
}

///|
/// XSD simple type ST_LegendPos (§21.2, dml-chart.xsd).
pub(all) enum ST_LegendPos {
  LegendPosB
  LegendPosTr
  LegendPosL
  LegendPosR
  LegendPosT
} derive(Eq, Debug)

///|
/// Parse the ST_LegendPos schema lexical value.
pub fn ST_LegendPos::parse(s : String) -> ST_LegendPos raise SchemaViolation {
  match s {
    "b" => LegendPosB
    "tr" => LegendPosTr
    "l" => LegendPosL
    "r" => LegendPosR
    "t" => LegendPosT
    _ => invalid("dml-chart.xsd", "ST_LegendPos", s)
  }
}

///|
/// Construct ST_LegendPos while enforcing the dml-chart.xsd enumeration.
pub fn ST_LegendPos::new(s : String) -> ST_LegendPos raise SchemaViolation {
  ST_LegendPos::parse(s)
}

///|
/// Return the schema lexical value for ST_LegendPos.
pub fn ST_LegendPos::to_string(self : ST_LegendPos) -> String {
  match self {
    LegendPosB => "b"
    LegendPosTr => "tr"
    LegendPosL => "l"
    LegendPosR => "r"
    LegendPosT => "t"
  }
}

///|
/// XSD simple type ST_DispBlanksAs (§21.2, dml-chart.xsd).
pub(all) enum ST_DispBlanksAs {
  DispBlanksAsSpan
  DispBlanksAsGap
  DispBlanksAsZero
} derive(Eq, Debug)

///|
/// Parse the ST_DispBlanksAs schema lexical value.
pub fn ST_DispBlanksAs::parse(
  s : String,
) -> ST_DispBlanksAs raise SchemaViolation {
  match s {
    "span" => DispBlanksAsSpan
    "gap" => DispBlanksAsGap
    "zero" => DispBlanksAsZero
    _ => invalid("dml-chart.xsd", "ST_DispBlanksAs", s)
  }
}

///|
/// Construct ST_DispBlanksAs while enforcing the dml-chart.xsd enumeration.
pub fn ST_DispBlanksAs::new(
  s : String,
) -> ST_DispBlanksAs raise SchemaViolation {
  ST_DispBlanksAs::parse(s)
}

///|
/// Return the schema lexical value for ST_DispBlanksAs.
pub fn ST_DispBlanksAs::to_string(self : ST_DispBlanksAs) -> String {
  match self {
    DispBlanksAsSpan => "span"
    DispBlanksAsGap => "gap"
    DispBlanksAsZero => "zero"
  }
}

///|
/// XSD simple type ST_Style (§21.2, dml-chart.xsd) with base xsd:unsignedByte.
pub struct ST_Style {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_Style schema lexical value.
pub fn ST_Style::parse(s : String) -> ST_Style raise SchemaViolation {
  validate_number("dml-chart.xsd", "ST_Style", s)
  { value: s }
}

///|
/// Construct ST_Style while enforcing its dml-chart.xsd lexical constraint.
pub fn ST_Style::new(s : String) -> ST_Style raise SchemaViolation {
  ST_Style::parse(s)
}

///|
/// Return the schema lexical value for ST_Style.
pub fn ST_Style::to_string(self : ST_Style) -> String {
  self.value
}

///|
/// XSD simple type ST_PageSetupOrientation (§21.2, dml-chart.xsd).
pub(all) enum ST_PageSetupOrientation {
  PageSetupOrientationDefaultValue
  PageSetupOrientationPortrait
  PageSetupOrientationLandscape
} derive(Eq, Debug)

///|
/// Parse the ST_PageSetupOrientation schema lexical value.
pub fn ST_PageSetupOrientation::parse(
  s : String,
) -> ST_PageSetupOrientation raise SchemaViolation {
  match s {
    "default" => PageSetupOrientationDefaultValue
    "portrait" => PageSetupOrientationPortrait
    "landscape" => PageSetupOrientationLandscape
    _ => invalid("dml-chart.xsd", "ST_PageSetupOrientation", s)
  }
}

///|
/// Construct ST_PageSetupOrientation while enforcing the dml-chart.xsd enumeration.
pub fn ST_PageSetupOrientation::new(
  s : String,
) -> ST_PageSetupOrientation raise SchemaViolation {
  ST_PageSetupOrientation::parse(s)
}

///|
/// Return the schema lexical value for ST_PageSetupOrientation.
pub fn ST_PageSetupOrientation::to_string(
  self : ST_PageSetupOrientation,
) -> String {
  match self {
    PageSetupOrientationDefaultValue => "default"
    PageSetupOrientationPortrait => "portrait"
    PageSetupOrientationLandscape => "landscape"
  }
}

///|
/// XSD simple type ST_MarkerCoordinate (§21.3, dml-chartDrawing.xsd) with base xsd:double.
pub struct ST_MarkerCoordinate {
  value : String
} derive(Eq, Debug)

///|
/// Parse the ST_MarkerCoordinate schema lexical value.
pub fn ST_MarkerCoordinate::parse(
  s : String,
) -> ST_MarkerCoordinate raise SchemaViolation {
  validate_double("dml-chartDrawing.xsd", "ST_MarkerCoordinate", s)
  { value: s }
}

///|
/// Construct ST_MarkerCoordinate while enforcing its dml-chartDrawing.xsd lexical constraint.
pub fn ST_MarkerCoordinate::new(
  s : String,
) -> ST_MarkerCoordinate raise SchemaViolation {
  ST_MarkerCoordinate::parse(s)
}

///|
/// Return the schema lexical value for ST_MarkerCoordinate.
pub fn ST_MarkerCoordinate::to_string(self : ST_MarkerCoordinate) -> String {
  self.value
}

///|
fn[T] invalid(
  schema : String,
  type_name : String,
  value : String,
) -> T raise SchemaViolation {
  raise SchemaViolation(
    schema~,
    path=type_name,
    reason="invalid value: " + value,
  )
}

///|
fn validate_non_empty(
  schema : String,
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    invalid(schema, type_name, value)
  }
}

///|
fn validate_number(
  schema : String,
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 || !looks_like_number(value, allow_decimal=false) {
    invalid(schema, type_name, value)
  }
}

///|
fn validate_double(
  schema : String,
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 || !looks_like_number(value, allow_decimal=true) {
    invalid(schema, type_name, value)
  }
}

///|
fn looks_like_number(s : String, allow_decimal~ : Bool) -> Bool {
  let mut i = 0
  let mut saw_digit = false
  let mut saw_dot = false
  if s.length() > 0 && (s[0:1] == "-" || s[0:1] == "+") {
    i = 1
  }
  while i < s.length() {
    let ch = s[i:i + 1]
    if ch >= "0" && ch <= "9" {
      saw_digit = true
    } else if allow_decimal && ch == "." && !saw_dot {
      saw_dot = true
    } else {
      return false
    }
    i = i + 1
  }
  saw_digit
}
