///|
/// Schema validation error for ECMA-376 DrawingML chart (§21.2/§21.3).
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// XSD simple type ST_LayoutTarget — Part 1 §21.2.3.21.
/// Restriction of xsd:string to {inner, outer}.
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
/// XSD simple type ST_LayoutMode — Part 1 §21.2.3.20.
/// Restriction of xsd:string to {edge, factor}.
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
/// XSD simple type ST_RotX — Part 1 §21.2.3.38.
/// Restriction of xsd:byte to -90..90 inclusive (X-axis rotation, degrees).
pub struct ST_RotX {
  degrees : Int
} derive(Eq, Debug)

///|
/// Parse the ST_RotX schema lexical value into the typed degree count.
pub fn ST_RotX::parse(s : String) -> ST_RotX raise SchemaViolation {
  let n = parse_signed_int("dml-chart.xsd", "ST_RotX", s)
  if n < -90 || n > 90 {
    invalid("dml-chart.xsd", "ST_RotX", s)
  }
  { degrees: n }
}

///|
/// Construct ST_RotX while enforcing the dml-chart.xsd -90..90 range.
pub fn ST_RotX::new(s : String) -> ST_RotX raise SchemaViolation {
  ST_RotX::parse(s)
}

///|
/// Read the rotation as a signed degree integer (-90..90).
pub fn ST_RotX::degrees(self : ST_RotX) -> Int {
  self.degrees
}

///|
/// Return the canonical lexical value for ST_RotX.
pub fn ST_RotX::to_string(self : ST_RotX) -> String {
  self.degrees.to_string()
}

///|
/// XSD simple type ST_HPercent — Part 1 §21.2.3.19.
/// xsd:union over ST_HPercentWithSymbol (height percentage 5%..500%).
pub struct ST_HPercent {
  percent : ST_HPercentWithSymbol
} derive(Eq, Debug)

///|
/// Parse the ST_HPercent schema lexical value.
pub fn ST_HPercent::parse(s : String) -> ST_HPercent raise SchemaViolation {
  { percent: ST_HPercentWithSymbol::parse(s) }
}

///|
/// Construct ST_HPercent while enforcing the dml-chart.xsd union.
pub fn ST_HPercent::new(s : String) -> ST_HPercent raise SchemaViolation {
  ST_HPercent::parse(s)
}

///|
/// Read the typed height percentage integer (5..500).
pub fn ST_HPercent::percent(self : ST_HPercent) -> Int {
  self.percent.percent()
}

///|
/// Return the canonical lexical value for ST_HPercent.
pub fn ST_HPercent::to_string(self : ST_HPercent) -> String {
  self.percent.to_string()
}

///|
/// XSD simple type ST_HPercentWithSymbol — Part 1 §21.2.3.52.
/// xsd:string pattern `0*(([5-9])|([1-9][0-9])|([1-4][0-9][0-9])|500)%`
/// — percent integer between 5 and 500 followed by `%`.
pub struct ST_HPercentWithSymbol {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_HPercentWithSymbol lexical pattern.
pub fn ST_HPercentWithSymbol::parse(
  s : String,
) -> ST_HPercentWithSymbol raise SchemaViolation {
  let n = parse_percent_literal(
    "dml-chart.xsd",
    "ST_HPercentWithSymbol",
    s,
    allow_negative=false,
  )
  if n < 5 || n > 500 {
    invalid("dml-chart.xsd", "ST_HPercentWithSymbol", s)
  }
  { percent: n }
}

///|
/// Construct ST_HPercentWithSymbol while enforcing the dml-chart.xsd pattern.
pub fn ST_HPercentWithSymbol::new(
  s : String,
) -> ST_HPercentWithSymbol raise SchemaViolation {
  ST_HPercentWithSymbol::parse(s)
}

///|
/// Read the typed percentage integer (5..500).
pub fn ST_HPercentWithSymbol::percent(self : ST_HPercentWithSymbol) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value (no leading zeros, with `%`).
pub fn ST_HPercentWithSymbol::to_string(self : ST_HPercentWithSymbol) -> String {
  self.percent.to_string() + "%"
}

///|
/// XSD simple type ST_RotY — Part 1 §21.2.3.39.
/// Restriction of xsd:unsignedShort to 0..360 inclusive (Y-axis rotation).
pub struct ST_RotY {
  degrees : Int
} derive(Eq, Debug)

///|
/// Parse the ST_RotY schema lexical value into the typed degree count.
pub fn ST_RotY::parse(s : String) -> ST_RotY raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_RotY", s)
  if n < 0 || n > 360 {
    invalid("dml-chart.xsd", "ST_RotY", s)
  }
  { degrees: n }
}

///|
/// Construct ST_RotY while enforcing the dml-chart.xsd 0..360 range.
pub fn ST_RotY::new(s : String) -> ST_RotY raise SchemaViolation {
  ST_RotY::parse(s)
}

///|
/// Read the rotation as an unsigned degree integer (0..360).
pub fn ST_RotY::degrees(self : ST_RotY) -> Int {
  self.degrees
}

///|
/// Return the canonical lexical value for ST_RotY.
pub fn ST_RotY::to_string(self : ST_RotY) -> String {
  self.degrees.to_string()
}

///|
/// XSD simple type ST_DepthPercent — Part 1 §21.2.3.9.
/// xsd:union over ST_DepthPercentWithSymbol (depth percentage 20%..2000%).
pub struct ST_DepthPercent {
  percent : ST_DepthPercentWithSymbol
} derive(Eq, Debug)

///|
/// Parse the ST_DepthPercent schema lexical value.
pub fn ST_DepthPercent::parse(
  s : String,
) -> ST_DepthPercent raise SchemaViolation {
  { percent: ST_DepthPercentWithSymbol::parse(s) }
}

///|
/// Construct ST_DepthPercent while enforcing the dml-chart.xsd union.
pub fn ST_DepthPercent::new(
  s : String,
) -> ST_DepthPercent raise SchemaViolation {
  ST_DepthPercent::parse(s)
}

///|
/// Read the typed depth percentage integer (20..2000).
pub fn ST_DepthPercent::percent(self : ST_DepthPercent) -> Int {
  self.percent.percent()
}

///|
/// Return the canonical lexical value for ST_DepthPercent.
pub fn ST_DepthPercent::to_string(self : ST_DepthPercent) -> String {
  self.percent.to_string()
}

///|
/// XSD simple type ST_DepthPercentWithSymbol — Part 1 §21.2.3.51.
/// xsd:string pattern
/// `0*(([2-9][0-9])|([1-9][0-9][0-9])|(1[0-9][0-9][0-9])|2000)%`
/// — percent integer between 20 and 2000 followed by `%`.
pub struct ST_DepthPercentWithSymbol {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_DepthPercentWithSymbol lexical pattern.
pub fn ST_DepthPercentWithSymbol::parse(
  s : String,
) -> ST_DepthPercentWithSymbol raise SchemaViolation {
  let n = parse_percent_literal(
    "dml-chart.xsd",
    "ST_DepthPercentWithSymbol",
    s,
    allow_negative=false,
  )
  if n < 20 || n > 2000 {
    invalid("dml-chart.xsd", "ST_DepthPercentWithSymbol", s)
  }
  { percent: n }
}

///|
/// Construct ST_DepthPercentWithSymbol while enforcing the dml-chart.xsd pattern.
pub fn ST_DepthPercentWithSymbol::new(
  s : String,
) -> ST_DepthPercentWithSymbol raise SchemaViolation {
  ST_DepthPercentWithSymbol::parse(s)
}

///|
/// Read the typed percentage integer (20..2000).
pub fn ST_DepthPercentWithSymbol::percent(
  self : ST_DepthPercentWithSymbol,
) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value (no leading zeros, with `%`).
pub fn ST_DepthPercentWithSymbol::to_string(
  self : ST_DepthPercentWithSymbol,
) -> String {
  self.percent.to_string() + "%"
}

///|
/// XSD simple type ST_Perspective — Part 1 §21.2.3.34.
/// Restriction of xsd:unsignedByte to 0..240 inclusive (perspective percent).
pub struct ST_Perspective {
  value : Int
} derive(Eq, Debug)

///|
/// Parse the ST_Perspective schema lexical value.
pub fn ST_Perspective::parse(
  s : String,
) -> ST_Perspective raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_Perspective", s)
  if n < 0 || n > 240 {
    invalid("dml-chart.xsd", "ST_Perspective", s)
  }
  { value: n }
}

///|
/// Construct ST_Perspective while enforcing the dml-chart.xsd 0..240 range.
pub fn ST_Perspective::new(s : String) -> ST_Perspective raise SchemaViolation {
  ST_Perspective::parse(s)
}

///|
/// Read the perspective percentage (0..240).
pub fn ST_Perspective::value(self : ST_Perspective) -> Int {
  self.value
}

///|
/// Return the canonical lexical value for ST_Perspective.
pub fn ST_Perspective::to_string(self : ST_Perspective) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_Thickness — Part 1 §21.2.3.59.
/// xsd:union over ST_ThicknessPercent (a free `[0-9]+%` percentage).
pub struct ST_Thickness {
  percent : ST_ThicknessPercent
} derive(Eq, Debug)

///|
/// Parse the ST_Thickness schema lexical value.
pub fn ST_Thickness::parse(s : String) -> ST_Thickness raise SchemaViolation {
  { percent: ST_ThicknessPercent::parse(s) }
}

///|
/// Construct ST_Thickness while enforcing the dml-chart.xsd union.
pub fn ST_Thickness::new(s : String) -> ST_Thickness raise SchemaViolation {
  ST_Thickness::parse(s)
}

///|
/// Read the typed thickness percentage integer.
pub fn ST_Thickness::percent(self : ST_Thickness) -> Int {
  self.percent.percent()
}

///|
/// Return the canonical lexical value for ST_Thickness.
pub fn ST_Thickness::to_string(self : ST_Thickness) -> String {
  self.percent.to_string()
}

///|
/// XSD simple type ST_ThicknessPercent — Part 1 §21.2.3.60.
/// xsd:string pattern `([0-9]+)%` — any non-negative integer percent.
pub struct ST_ThicknessPercent {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_ThicknessPercent lexical pattern.
pub fn ST_ThicknessPercent::parse(
  s : String,
) -> ST_ThicknessPercent raise SchemaViolation {
  let n = parse_percent_literal_strict_digits(
    "dml-chart.xsd", "ST_ThicknessPercent", s,
  )
  { percent: n }
}

///|
/// Construct ST_ThicknessPercent while enforcing the dml-chart.xsd pattern.
pub fn ST_ThicknessPercent::new(
  s : String,
) -> ST_ThicknessPercent raise SchemaViolation {
  ST_ThicknessPercent::parse(s)
}

///|
/// Read the typed thickness percentage integer.
pub fn ST_ThicknessPercent::percent(self : ST_ThicknessPercent) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value (no leading zeros, with `%`).
pub fn ST_ThicknessPercent::to_string(self : ST_ThicknessPercent) -> String {
  self.percent.to_string() + "%"
}

///|
/// XSD simple type ST_GapAmount — Part 1 §21.2.3.16.
/// xsd:union over ST_GapAmountPercent (gap percentage 0%..500%).
pub struct ST_GapAmount {
  percent : ST_GapAmountPercent
} derive(Eq, Debug)

///|
/// Parse the ST_GapAmount schema lexical value.
pub fn ST_GapAmount::parse(s : String) -> ST_GapAmount raise SchemaViolation {
  { percent: ST_GapAmountPercent::parse(s) }
}

///|
/// Construct ST_GapAmount while enforcing the dml-chart.xsd union.
pub fn ST_GapAmount::new(s : String) -> ST_GapAmount raise SchemaViolation {
  ST_GapAmount::parse(s)
}

///|
/// Read the typed gap percentage integer (0..500).
pub fn ST_GapAmount::percent(self : ST_GapAmount) -> Int {
  self.percent.percent()
}

///|
/// Return the canonical lexical value for ST_GapAmount.
pub fn ST_GapAmount::to_string(self : ST_GapAmount) -> String {
  self.percent.to_string()
}

///|
/// XSD simple type ST_GapAmountPercent — Part 1 §21.2.3.53.
/// xsd:string pattern
/// `0*(([0-9])|([1-9][0-9])|([1-4][0-9][0-9])|500)%` — percent integer
/// between 0 and 500 followed by `%`.
pub struct ST_GapAmountPercent {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_GapAmountPercent lexical pattern.
pub fn ST_GapAmountPercent::parse(
  s : String,
) -> ST_GapAmountPercent raise SchemaViolation {
  let n = parse_percent_literal(
    "dml-chart.xsd",
    "ST_GapAmountPercent",
    s,
    allow_negative=false,
  )
  if n < 0 || n > 500 {
    invalid("dml-chart.xsd", "ST_GapAmountPercent", s)
  }
  { percent: n }
}

///|
/// Construct ST_GapAmountPercent while enforcing the dml-chart.xsd pattern.
pub fn ST_GapAmountPercent::new(
  s : String,
) -> ST_GapAmountPercent raise SchemaViolation {
  ST_GapAmountPercent::parse(s)
}

///|
/// Read the typed percentage integer (0..500).
pub fn ST_GapAmountPercent::percent(self : ST_GapAmountPercent) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value (no leading zeros, with `%`).
pub fn ST_GapAmountPercent::to_string(self : ST_GapAmountPercent) -> String {
  self.percent.to_string() + "%"
}

///|
/// XSD simple type ST_Overlap — Part 1 §21.2.3.31.
/// xsd:union over ST_OverlapPercent (overlap percentage -100%..100%).
pub struct ST_Overlap {
  percent : ST_OverlapPercent
} derive(Eq, Debug)

///|
/// Parse the ST_Overlap schema lexical value.
pub fn ST_Overlap::parse(s : String) -> ST_Overlap raise SchemaViolation {
  { percent: ST_OverlapPercent::parse(s) }
}

///|
/// Construct ST_Overlap while enforcing the dml-chart.xsd union.
pub fn ST_Overlap::new(s : String) -> ST_Overlap raise SchemaViolation {
  ST_Overlap::parse(s)
}

///|
/// Read the typed overlap percentage integer (-100..100).
pub fn ST_Overlap::percent(self : ST_Overlap) -> Int {
  self.percent.percent()
}

///|
/// Return the canonical lexical value for ST_Overlap.
pub fn ST_Overlap::to_string(self : ST_Overlap) -> String {
  self.percent.to_string()
}

///|
/// XSD simple type ST_OverlapPercent — Part 1 §21.2.3.57.
/// xsd:string pattern `(-?0*(([0-9])|([1-9][0-9])|100))%` — signed
/// percent integer between -100 and 100 followed by `%`.
pub struct ST_OverlapPercent {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_OverlapPercent lexical pattern.
pub fn ST_OverlapPercent::parse(
  s : String,
) -> ST_OverlapPercent raise SchemaViolation {
  let n = parse_percent_literal(
    "dml-chart.xsd",
    "ST_OverlapPercent",
    s,
    allow_negative=true,
  )
  if n < -100 || n > 100 {
    invalid("dml-chart.xsd", "ST_OverlapPercent", s)
  }
  { percent: n }
}

///|
/// Construct ST_OverlapPercent while enforcing the dml-chart.xsd pattern.
pub fn ST_OverlapPercent::new(
  s : String,
) -> ST_OverlapPercent raise SchemaViolation {
  ST_OverlapPercent::parse(s)
}

///|
/// Read the typed percentage integer (-100..100).
pub fn ST_OverlapPercent::percent(self : ST_OverlapPercent) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value (no leading zeros, with `%`).
pub fn ST_OverlapPercent::to_string(self : ST_OverlapPercent) -> String {
  self.percent.to_string() + "%"
}

///|
/// XSD simple type ST_BubbleScale — Part 1 §21.2.3.5.
/// xsd:union over ST_BubbleScalePercent (bubble scale 0%..300%).
pub struct ST_BubbleScale {
  percent : ST_BubbleScalePercent
} derive(Eq, Debug)

///|
/// Parse the ST_BubbleScale schema lexical value.
pub fn ST_BubbleScale::parse(
  s : String,
) -> ST_BubbleScale raise SchemaViolation {
  { percent: ST_BubbleScalePercent::parse(s) }
}

///|
/// Construct ST_BubbleScale while enforcing the dml-chart.xsd union.
pub fn ST_BubbleScale::new(s : String) -> ST_BubbleScale raise SchemaViolation {
  ST_BubbleScale::parse(s)
}

///|
/// Read the typed bubble scale percentage integer (0..300).
pub fn ST_BubbleScale::percent(self : ST_BubbleScale) -> Int {
  self.percent.percent()
}

///|
/// Return the canonical lexical value for ST_BubbleScale.
pub fn ST_BubbleScale::to_string(self : ST_BubbleScale) -> String {
  self.percent.to_string()
}

///|
/// XSD simple type ST_BubbleScalePercent — Part 1 §21.2.3.58.
/// xsd:string pattern
/// `0*(([0-9])|([1-9][0-9])|([1-2][0-9][0-9])|300)%` — percent integer
/// between 0 and 300 followed by `%`.
pub struct ST_BubbleScalePercent {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_BubbleScalePercent lexical pattern.
pub fn ST_BubbleScalePercent::parse(
  s : String,
) -> ST_BubbleScalePercent raise SchemaViolation {
  let n = parse_percent_literal(
    "dml-chart.xsd",
    "ST_BubbleScalePercent",
    s,
    allow_negative=false,
  )
  if n < 0 || n > 300 {
    invalid("dml-chart.xsd", "ST_BubbleScalePercent", s)
  }
  { percent: n }
}

///|
/// Construct ST_BubbleScalePercent while enforcing the dml-chart.xsd pattern.
pub fn ST_BubbleScalePercent::new(
  s : String,
) -> ST_BubbleScalePercent raise SchemaViolation {
  ST_BubbleScalePercent::parse(s)
}

///|
/// Read the typed percentage integer (0..300).
pub fn ST_BubbleScalePercent::percent(self : ST_BubbleScalePercent) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value (no leading zeros, with `%`).
pub fn ST_BubbleScalePercent::to_string(self : ST_BubbleScalePercent) -> String {
  self.percent.to_string() + "%"
}

///|
/// XSD simple type ST_SizeRepresents — Part 1 §21.2.3.43.
/// Restriction of xsd:string to {area, w}.
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
/// XSD simple type ST_FirstSliceAng — Part 1 §21.2.3.15.
/// Restriction of xsd:unsignedShort to 0..360 inclusive (degrees of the
/// first slice in a pie chart).
pub struct ST_FirstSliceAng {
  degrees : Int
} derive(Eq, Debug)

///|
/// Parse the ST_FirstSliceAng schema lexical value.
pub fn ST_FirstSliceAng::parse(
  s : String,
) -> ST_FirstSliceAng raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_FirstSliceAng", s)
  if n < 0 || n > 360 {
    invalid("dml-chart.xsd", "ST_FirstSliceAng", s)
  }
  { degrees: n }
}

///|
/// Construct ST_FirstSliceAng while enforcing the dml-chart.xsd 0..360 range.
pub fn ST_FirstSliceAng::new(
  s : String,
) -> ST_FirstSliceAng raise SchemaViolation {
  ST_FirstSliceAng::parse(s)
}

///|
/// Read the first-slice angle in degrees (0..360).
pub fn ST_FirstSliceAng::degrees(self : ST_FirstSliceAng) -> Int {
  self.degrees
}

///|
/// Return the canonical lexical value for ST_FirstSliceAng.
pub fn ST_FirstSliceAng::to_string(self : ST_FirstSliceAng) -> String {
  self.degrees.to_string()
}

///|
/// XSD simple type ST_HoleSize — Part 1 §21.2.3.18.
/// xsd:union over ST_HoleSizePercent (doughnut hole 1%..90%).
pub struct ST_HoleSize {
  percent : ST_HoleSizePercent
} derive(Eq, Debug)

///|
/// Parse the ST_HoleSize schema lexical value.
pub fn ST_HoleSize::parse(s : String) -> ST_HoleSize raise SchemaViolation {
  { percent: ST_HoleSizePercent::parse(s) }
}

///|
/// Construct ST_HoleSize while enforcing the dml-chart.xsd union.
pub fn ST_HoleSize::new(s : String) -> ST_HoleSize raise SchemaViolation {
  ST_HoleSize::parse(s)
}

///|
/// Read the typed hole-size percentage integer (1..90).
pub fn ST_HoleSize::percent(self : ST_HoleSize) -> Int {
  self.percent.percent()
}

///|
/// Return the canonical lexical value for ST_HoleSize.
pub fn ST_HoleSize::to_string(self : ST_HoleSize) -> String {
  self.percent.to_string()
}

///|
/// XSD simple type ST_HoleSizePercent — Part 1 §21.2.3.55.
/// xsd:string pattern `0*([1-9]|([1-8][0-9])|90)%` — percent integer
/// between 1 and 90 followed by `%`.
pub struct ST_HoleSizePercent {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_HoleSizePercent lexical pattern.
pub fn ST_HoleSizePercent::parse(
  s : String,
) -> ST_HoleSizePercent raise SchemaViolation {
  let n = parse_percent_literal(
    "dml-chart.xsd",
    "ST_HoleSizePercent",
    s,
    allow_negative=false,
  )
  if n < 1 || n > 90 {
    invalid("dml-chart.xsd", "ST_HoleSizePercent", s)
  }
  { percent: n }
}

///|
/// Construct ST_HoleSizePercent while enforcing the dml-chart.xsd pattern.
pub fn ST_HoleSizePercent::new(
  s : String,
) -> ST_HoleSizePercent raise SchemaViolation {
  ST_HoleSizePercent::parse(s)
}

///|
/// Read the typed percentage integer (1..90).
pub fn ST_HoleSizePercent::percent(self : ST_HoleSizePercent) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value (no leading zeros, with `%`).
pub fn ST_HoleSizePercent::to_string(self : ST_HoleSizePercent) -> String {
  self.percent.to_string() + "%"
}

///|
/// XSD simple type ST_SplitType — Part 1 §21.2.3.45.
/// Restriction of xsd:string to {auto, cust, percent, pos, val}.
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
/// XSD simple type ST_SecondPieSize — Part 1 §21.2.3.41.
/// xsd:union over ST_SecondPieSizePercent (second pie 5%..200%).
pub struct ST_SecondPieSize {
  percent : ST_SecondPieSizePercent
} derive(Eq, Debug)

///|
/// Parse the ST_SecondPieSize schema lexical value.
pub fn ST_SecondPieSize::parse(
  s : String,
) -> ST_SecondPieSize raise SchemaViolation {
  { percent: ST_SecondPieSizePercent::parse(s) }
}

///|
/// Construct ST_SecondPieSize while enforcing the dml-chart.xsd union.
pub fn ST_SecondPieSize::new(
  s : String,
) -> ST_SecondPieSize raise SchemaViolation {
  ST_SecondPieSize::parse(s)
}

///|
/// Read the typed percentage integer (5..200).
pub fn ST_SecondPieSize::percent(self : ST_SecondPieSize) -> Int {
  self.percent.percent()
}

///|
/// Return the canonical lexical value for ST_SecondPieSize.
pub fn ST_SecondPieSize::to_string(self : ST_SecondPieSize) -> String {
  self.percent.to_string()
}

///|
/// XSD simple type ST_SecondPieSizePercent — Part 1 §21.2.3.54.
/// xsd:string pattern
/// `0*(([5-9])|([1-9][0-9])|(1[0-9][0-9])|200)%` — percent integer
/// between 5 and 200 followed by `%`.
pub struct ST_SecondPieSizePercent {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_SecondPieSizePercent lexical pattern.
pub fn ST_SecondPieSizePercent::parse(
  s : String,
) -> ST_SecondPieSizePercent raise SchemaViolation {
  let n = parse_percent_literal(
    "dml-chart.xsd",
    "ST_SecondPieSizePercent",
    s,
    allow_negative=false,
  )
  if n < 5 || n > 200 {
    invalid("dml-chart.xsd", "ST_SecondPieSizePercent", s)
  }
  { percent: n }
}

///|
/// Construct ST_SecondPieSizePercent while enforcing the dml-chart.xsd pattern.
pub fn ST_SecondPieSizePercent::new(
  s : String,
) -> ST_SecondPieSizePercent raise SchemaViolation {
  ST_SecondPieSizePercent::parse(s)
}

///|
/// Read the typed percentage integer (5..200).
pub fn ST_SecondPieSizePercent::percent(self : ST_SecondPieSizePercent) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value (no leading zeros, with `%`).
pub fn ST_SecondPieSizePercent::to_string(
  self : ST_SecondPieSizePercent,
) -> String {
  self.percent.to_string() + "%"
}

///|
/// XSD simple type ST_LblAlgn — Part 1 §21.2.3.22.
/// Restriction of xsd:string to {ctr, l, r}.
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
/// XSD simple type ST_DLblPos — Part 1 §21.2.3.11.
/// Restriction of xsd:string to data-label positions.
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
/// XSD simple type ST_MarkerStyle — Part 1 §21.2.3.27.
/// Restriction of xsd:string to marker glyph names.
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
/// XSD simple type ST_MarkerSize — Part 1 §21.2.3.26.
/// Restriction of xsd:unsignedByte to 2..72 inclusive (point size).
pub struct ST_MarkerSize {
  points : Int
} derive(Eq, Debug)

///|
/// Parse the ST_MarkerSize schema lexical value.
pub fn ST_MarkerSize::parse(s : String) -> ST_MarkerSize raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_MarkerSize", s)
  if n < 2 || n > 72 {
    invalid("dml-chart.xsd", "ST_MarkerSize", s)
  }
  { points: n }
}

///|
/// Construct ST_MarkerSize while enforcing the dml-chart.xsd 2..72 range.
pub fn ST_MarkerSize::new(s : String) -> ST_MarkerSize raise SchemaViolation {
  ST_MarkerSize::parse(s)
}

///|
/// Read the marker size in points (2..72).
pub fn ST_MarkerSize::points(self : ST_MarkerSize) -> Int {
  self.points
}

///|
/// Return the canonical lexical value for ST_MarkerSize.
pub fn ST_MarkerSize::to_string(self : ST_MarkerSize) -> String {
  self.points.to_string()
}

///|
/// XSD simple type ST_TrendlineType — Part 1 §21.2.3.50.
/// Restriction of xsd:string to trendline curve families.
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
/// XSD simple type ST_Order — Part 1 §21.2.3.29.
/// Restriction of xsd:unsignedByte to 2..6 inclusive (polynomial order).
pub struct ST_Order {
  value : Int
} derive(Eq, Debug)

///|
/// Parse the ST_Order schema lexical value.
pub fn ST_Order::parse(s : String) -> ST_Order raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_Order", s)
  if n < 2 || n > 6 {
    invalid("dml-chart.xsd", "ST_Order", s)
  }
  { value: n }
}

///|
/// Construct ST_Order while enforcing the dml-chart.xsd 2..6 range.
pub fn ST_Order::new(s : String) -> ST_Order raise SchemaViolation {
  ST_Order::parse(s)
}

///|
/// Read the polynomial order (2..6).
pub fn ST_Order::value(self : ST_Order) -> Int {
  self.value
}

///|
/// Return the canonical lexical value for ST_Order.
pub fn ST_Order::to_string(self : ST_Order) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_Period — Part 1 §21.2.3.33.
/// Restriction of xsd:unsignedInt to values greater than or equal to 2
/// (moving-average period). Stored as Int64 to cover the full
/// unsignedInt range.
pub struct ST_Period {
  value : Int64
} derive(Eq, Debug)

///|
/// Parse the ST_Period schema lexical value.
pub fn ST_Period::parse(s : String) -> ST_Period raise SchemaViolation {
  let n = parse_unsigned_int64("dml-chart.xsd", "ST_Period", s)
  if n < 2L || n > 4294967295L {
    invalid("dml-chart.xsd", "ST_Period", s)
  }
  { value: n }
}

///|
/// Construct ST_Period while enforcing the dml-chart.xsd ≥2 floor.
pub fn ST_Period::new(s : String) -> ST_Period raise SchemaViolation {
  ST_Period::parse(s)
}

///|
/// Read the moving-average period (≥2).
pub fn ST_Period::value(self : ST_Period) -> Int64 {
  self.value
}

///|
/// Return the canonical lexical value for ST_Period.
pub fn ST_Period::to_string(self : ST_Period) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_ErrDir — Part 1 §21.2.3.13.
/// Restriction of xsd:string to {x, y}.
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
/// XSD simple type ST_ErrBarType — Part 1 §21.2.3.12.
/// Restriction of xsd:string to {both, minus, plus}.
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
/// XSD simple type ST_ErrValType — Part 1 §21.2.3.14.
/// Restriction of xsd:string to error-bar magnitude rules.
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
/// XSD simple type ST_Grouping — Part 1 §21.2.3.17.
/// Restriction of xsd:string to {percentStacked, standard, stacked}.
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
/// XSD simple type ST_ScatterStyle — Part 1 §21.2.3.40.
/// Restriction of xsd:string to scatter chart styles.
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
/// XSD simple type ST_RadarStyle — Part 1 §21.2.3.37.
/// Restriction of xsd:string to {standard, marker, filled}.
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
/// XSD simple type ST_BarGrouping — Part 1 §21.2.3.4.
/// Restriction of xsd:string to {percentStacked, clustered, standard, stacked}.
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
/// XSD simple type ST_BarDir — Part 1 §21.2.3.3.
/// Restriction of xsd:string to {bar, col}.
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
/// XSD simple type ST_Shape — Part 1 §21.2.3.42.
/// Restriction of xsd:string to 3-D data-marker shapes.
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
/// XSD simple type ST_OfPieType — Part 1 §21.2.3.28.
/// Restriction of xsd:string to {pie, bar}.
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
/// XSD simple type ST_AxPos — Part 1 §21.2.3.2.
/// Restriction of xsd:string to {b, l, r, t}.
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
/// XSD simple type ST_Crosses — Part 1 §21.2.3.8.
/// Restriction of xsd:string to {autoZero, max, min}.
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
/// XSD simple type ST_CrossBetween — Part 1 §21.2.3.7.
/// Restriction of xsd:string to {between, midCat}.
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
/// XSD simple type ST_TickMark — Part 1 §21.2.3.48.
/// Restriction of xsd:string to {cross, in, none, out}. The `in`
/// variant is suffixed `Value` to avoid colliding with the Moonbit
/// `in` keyword spelling.
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
/// XSD simple type ST_TickLblPos — Part 1 §21.2.3.47.
/// Restriction of xsd:string to {high, low, nextTo, none}.
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
/// XSD simple type ST_Skip — Part 1 §21.2.3.44.
/// Restriction of xsd:unsignedInt to values greater than or equal to 1
/// (category-axis label skip). Stored as Int64 to span the full
/// unsignedInt range.
pub struct ST_Skip {
  value : Int64
} derive(Eq, Debug)

///|
/// Parse the ST_Skip schema lexical value.
pub fn ST_Skip::parse(s : String) -> ST_Skip raise SchemaViolation {
  let n = parse_unsigned_int64("dml-chart.xsd", "ST_Skip", s)
  if n < 1L || n > 4294967295L {
    invalid("dml-chart.xsd", "ST_Skip", s)
  }
  { value: n }
}

///|
/// Construct ST_Skip while enforcing the dml-chart.xsd ≥1 floor.
pub fn ST_Skip::new(s : String) -> ST_Skip raise SchemaViolation {
  ST_Skip::parse(s)
}

///|
/// Read the typed label-skip count (≥1).
pub fn ST_Skip::value(self : ST_Skip) -> Int64 {
  self.value
}

///|
/// Return the canonical lexical value for ST_Skip.
pub fn ST_Skip::to_string(self : ST_Skip) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_TimeUnit — Part 1 §21.2.3.49.
/// Restriction of xsd:string to {days, months, years}.
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
/// XSD simple type ST_AxisUnit — Part 1 §21.2.3.1.
/// Restriction of xsd:double to positive values (axis major/minor unit).
pub struct ST_AxisUnit {
  value : Double
} derive(Eq, Debug)

///|
/// Parse the ST_AxisUnit schema lexical value.
pub fn ST_AxisUnit::parse(s : String) -> ST_AxisUnit raise SchemaViolation {
  let v = parse_double("dml-chart.xsd", "ST_AxisUnit", s)
  if !(v > 0.0) {
    invalid("dml-chart.xsd", "ST_AxisUnit", s)
  }
  { value: v }
}

///|
/// Construct ST_AxisUnit while enforcing the dml-chart.xsd `>0` floor.
pub fn ST_AxisUnit::new(s : String) -> ST_AxisUnit raise SchemaViolation {
  ST_AxisUnit::parse(s)
}

///|
/// Read the axis unit value (>0).
pub fn ST_AxisUnit::value(self : ST_AxisUnit) -> Double {
  self.value
}

///|
/// Return the canonical lexical value for ST_AxisUnit.
pub fn ST_AxisUnit::to_string(self : ST_AxisUnit) -> String {
  format_decimal(self.value)
}

///|
/// XSD simple type ST_BuiltInUnit — Part 1 §21.2.3.6.
/// Restriction of xsd:string to nine built-in unit names.
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
/// XSD simple type ST_PictureFormat — Part 1 §21.2.3.35.
/// Restriction of xsd:string to {stretch, stack, stackScale}.
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
/// XSD simple type ST_PictureStackUnit — Part 1 §21.2.3.36.
/// Restriction of xsd:double to positive values (picture stack unit).
pub struct ST_PictureStackUnit {
  value : Double
} derive(Eq, Debug)

///|
/// Parse the ST_PictureStackUnit schema lexical value.
pub fn ST_PictureStackUnit::parse(
  s : String,
) -> ST_PictureStackUnit raise SchemaViolation {
  let v = parse_double("dml-chart.xsd", "ST_PictureStackUnit", s)
  if !(v > 0.0) {
    invalid("dml-chart.xsd", "ST_PictureStackUnit", s)
  }
  { value: v }
}

///|
/// Construct ST_PictureStackUnit while enforcing the dml-chart.xsd `>0` floor.
pub fn ST_PictureStackUnit::new(
  s : String,
) -> ST_PictureStackUnit raise SchemaViolation {
  ST_PictureStackUnit::parse(s)
}

///|
/// Read the picture stack unit value (>0).
pub fn ST_PictureStackUnit::value(self : ST_PictureStackUnit) -> Double {
  self.value
}

///|
/// Return the canonical lexical value for ST_PictureStackUnit.
pub fn ST_PictureStackUnit::to_string(self : ST_PictureStackUnit) -> String {
  format_decimal(self.value)
}

///|
/// XSD simple type ST_Orientation — Part 1 §21.2.3.30.
/// Restriction of xsd:string to {maxMin, minMax}.
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
/// XSD simple type ST_LogBase — Part 1 §21.2.3.25.
/// Restriction of xsd:double to 2..1000 inclusive (axis log base).
pub struct ST_LogBase {
  value : Double
} derive(Eq, Debug)

///|
/// Parse the ST_LogBase schema lexical value.
pub fn ST_LogBase::parse(s : String) -> ST_LogBase raise SchemaViolation {
  let v = parse_double("dml-chart.xsd", "ST_LogBase", s)
  if v < 2.0 || v > 1000.0 {
    invalid("dml-chart.xsd", "ST_LogBase", s)
  }
  { value: v }
}

///|
/// Construct ST_LogBase while enforcing the dml-chart.xsd 2..1000 range.
pub fn ST_LogBase::new(s : String) -> ST_LogBase raise SchemaViolation {
  ST_LogBase::parse(s)
}

///|
/// Read the log base (2..1000).
pub fn ST_LogBase::value(self : ST_LogBase) -> Double {
  self.value
}

///|
/// Return the canonical lexical value for ST_LogBase.
pub fn ST_LogBase::to_string(self : ST_LogBase) -> String {
  format_decimal(self.value)
}

///|
/// XSD simple type ST_LblOffset — Part 1 §21.2.3.23.
/// xsd:union over ST_LblOffsetPercent (label offset 0%..1000%).
pub struct ST_LblOffset {
  percent : ST_LblOffsetPercent
} derive(Eq, Debug)

///|
/// Parse the ST_LblOffset schema lexical value.
pub fn ST_LblOffset::parse(s : String) -> ST_LblOffset raise SchemaViolation {
  { percent: ST_LblOffsetPercent::parse(s) }
}

///|
/// Construct ST_LblOffset while enforcing the dml-chart.xsd union.
pub fn ST_LblOffset::new(s : String) -> ST_LblOffset raise SchemaViolation {
  ST_LblOffset::parse(s)
}

///|
/// Read the typed label-offset percentage integer (0..1000).
pub fn ST_LblOffset::percent(self : ST_LblOffset) -> Int {
  self.percent.percent()
}

///|
/// Return the canonical lexical value for ST_LblOffset.
pub fn ST_LblOffset::to_string(self : ST_LblOffset) -> String {
  self.percent.to_string()
}

///|
/// XSD simple type ST_LblOffsetPercent — Part 1 §21.2.3.56.
/// xsd:string pattern
/// `0*(([0-9])|([1-9][0-9])|([1-9][0-9][0-9])|1000)%` — percent integer
/// between 0 and 1000 followed by `%`.
pub struct ST_LblOffsetPercent {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_LblOffsetPercent lexical pattern.
pub fn ST_LblOffsetPercent::parse(
  s : String,
) -> ST_LblOffsetPercent raise SchemaViolation {
  let n = parse_percent_literal(
    "dml-chart.xsd",
    "ST_LblOffsetPercent",
    s,
    allow_negative=false,
  )
  if n < 0 || n > 1000 {
    invalid("dml-chart.xsd", "ST_LblOffsetPercent", s)
  }
  { percent: n }
}

///|
/// Construct ST_LblOffsetPercent while enforcing the dml-chart.xsd pattern.
pub fn ST_LblOffsetPercent::new(
  s : String,
) -> ST_LblOffsetPercent raise SchemaViolation {
  ST_LblOffsetPercent::parse(s)
}

///|
/// Read the typed percentage integer (0..1000).
pub fn ST_LblOffsetPercent::percent(self : ST_LblOffsetPercent) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value (no leading zeros, with `%`).
pub fn ST_LblOffsetPercent::to_string(self : ST_LblOffsetPercent) -> String {
  self.percent.to_string() + "%"
}

///|
/// XSD simple type ST_LegendPos — Part 1 §21.2.3.24.
/// Restriction of xsd:string to {b, tr, l, r, t}.
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
/// XSD simple type ST_DispBlanksAs — Part 1 §21.2.3.10.
/// Restriction of xsd:string to {span, gap, zero}.
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
/// XSD simple type ST_Style — Part 1 §21.2.3.46.
/// Restriction of xsd:unsignedByte to 1..48 inclusive (chart preset).
pub struct ST_Style {
  value : Int
} derive(Eq, Debug)

///|
/// Parse the ST_Style schema lexical value.
pub fn ST_Style::parse(s : String) -> ST_Style raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_Style", s)
  if n < 1 || n > 48 {
    invalid("dml-chart.xsd", "ST_Style", s)
  }
  { value: n }
}

///|
/// Construct ST_Style while enforcing the dml-chart.xsd 1..48 range.
pub fn ST_Style::new(s : String) -> ST_Style raise SchemaViolation {
  ST_Style::parse(s)
}

///|
/// Read the chart style preset (1..48).
pub fn ST_Style::value(self : ST_Style) -> Int {
  self.value
}

///|
/// Return the canonical lexical value for ST_Style.
pub fn ST_Style::to_string(self : ST_Style) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_PageSetupOrientation — Part 1 §21.2.3.32.
/// Restriction of xsd:string to {default, portrait, landscape}.
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
/// XSD simple type ST_MarkerCoordinate — Part 1 §21.3.3.1.
/// Restriction of xsd:double to 0.0..1.0 inclusive (fractional chart
/// position used to anchor chart-drawing markers).
pub struct ST_MarkerCoordinate {
  value : Double
} derive(Eq, Debug)

///|
/// Parse the ST_MarkerCoordinate schema lexical value.
pub fn ST_MarkerCoordinate::parse(
  s : String,
) -> ST_MarkerCoordinate raise SchemaViolation {
  let v = parse_double("dml-chartDrawing.xsd", "ST_MarkerCoordinate", s)
  if v < 0.0 || v > 1.0 {
    invalid("dml-chartDrawing.xsd", "ST_MarkerCoordinate", s)
  }
  { value: v }
}

///|
/// Construct ST_MarkerCoordinate while enforcing the dml-chartDrawing.xsd 0..1 range.
pub fn ST_MarkerCoordinate::new(
  s : String,
) -> ST_MarkerCoordinate raise SchemaViolation {
  ST_MarkerCoordinate::parse(s)
}

///|
/// Read the marker coordinate as a fractional value in [0.0, 1.0].
pub fn ST_MarkerCoordinate::value(self : ST_MarkerCoordinate) -> Double {
  self.value
}

///|
/// Return the canonical lexical value for ST_MarkerCoordinate.
pub fn ST_MarkerCoordinate::to_string(self : ST_MarkerCoordinate) -> String {
  format_decimal(self.value)
}

///|
/// XSD simple type ST_BubbleScaleUInt — Part 1 §21.2 (dml-chart.xsd).
/// Restriction of xsd:unsignedInt to 0..300 inclusive (bubble-chart
/// size scale in raw percent points; the ST_BubbleScale union also
/// admits the `<integer>%` lexical branch).
pub struct ST_BubbleScaleUInt {
  value : Int
} derive(Eq, Debug)

///|
pub fn ST_BubbleScaleUInt::parse(
  s : String,
) -> ST_BubbleScaleUInt raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_BubbleScaleUInt", s)
  if n > 300 {
    invalid("dml-chart.xsd", "ST_BubbleScaleUInt", s)
  }
  { value: n }
}

///|
pub fn ST_BubbleScaleUInt::new(
  s : String,
) -> ST_BubbleScaleUInt raise SchemaViolation {
  ST_BubbleScaleUInt::parse(s)
}

///|
pub fn ST_BubbleScaleUInt::value(self : ST_BubbleScaleUInt) -> Int {
  self.value
}

///|
pub fn ST_BubbleScaleUInt::to_string(self : ST_BubbleScaleUInt) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_DepthPercentUShort — Part 1 §21.2 (dml-chart.xsd).
/// Restriction of xsd:unsignedShort to 20..2000 inclusive (3D chart
/// depth percent as a raw integer).
pub struct ST_DepthPercentUShort {
  value : Int
} derive(Eq, Debug)

///|
pub fn ST_DepthPercentUShort::parse(
  s : String,
) -> ST_DepthPercentUShort raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_DepthPercentUShort", s)
  if n < 20 || n > 2000 {
    invalid("dml-chart.xsd", "ST_DepthPercentUShort", s)
  }
  { value: n }
}

///|
pub fn ST_DepthPercentUShort::new(
  s : String,
) -> ST_DepthPercentUShort raise SchemaViolation {
  ST_DepthPercentUShort::parse(s)
}

///|
pub fn ST_DepthPercentUShort::value(self : ST_DepthPercentUShort) -> Int {
  self.value
}

///|
pub fn ST_DepthPercentUShort::to_string(self : ST_DepthPercentUShort) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_GapAmountUShort — Part 1 §21.2 (dml-chart.xsd).
/// Restriction of xsd:unsignedShort to 0..500 inclusive (bar/column
/// chart gap percent as a raw integer).
pub struct ST_GapAmountUShort {
  value : Int
} derive(Eq, Debug)

///|
pub fn ST_GapAmountUShort::parse(
  s : String,
) -> ST_GapAmountUShort raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_GapAmountUShort", s)
  if n > 500 {
    invalid("dml-chart.xsd", "ST_GapAmountUShort", s)
  }
  { value: n }
}

///|
pub fn ST_GapAmountUShort::new(
  s : String,
) -> ST_GapAmountUShort raise SchemaViolation {
  ST_GapAmountUShort::parse(s)
}

///|
pub fn ST_GapAmountUShort::value(self : ST_GapAmountUShort) -> Int {
  self.value
}

///|
pub fn ST_GapAmountUShort::to_string(self : ST_GapAmountUShort) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_HPercentUShort — Part 1 §21.2 (dml-chart.xsd).
/// Restriction of xsd:unsignedShort to 5..500 inclusive (height percent
/// as a raw integer).
pub struct ST_HPercentUShort {
  value : Int
} derive(Eq, Debug)

///|
pub fn ST_HPercentUShort::parse(
  s : String,
) -> ST_HPercentUShort raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_HPercentUShort", s)
  if n < 5 || n > 500 {
    invalid("dml-chart.xsd", "ST_HPercentUShort", s)
  }
  { value: n }
}

///|
pub fn ST_HPercentUShort::new(
  s : String,
) -> ST_HPercentUShort raise SchemaViolation {
  ST_HPercentUShort::parse(s)
}

///|
pub fn ST_HPercentUShort::value(self : ST_HPercentUShort) -> Int {
  self.value
}

///|
pub fn ST_HPercentUShort::to_string(self : ST_HPercentUShort) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_HoleSizeUByte — Part 1 §21.2 (dml-chart.xsd).
/// Restriction of xsd:unsignedByte to 1..90 inclusive (doughnut chart
/// hole size percent as a raw integer).
pub struct ST_HoleSizeUByte {
  value : Int
} derive(Eq, Debug)

///|
pub fn ST_HoleSizeUByte::parse(
  s : String,
) -> ST_HoleSizeUByte raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_HoleSizeUByte", s)
  if n < 1 || n > 90 {
    invalid("dml-chart.xsd", "ST_HoleSizeUByte", s)
  }
  { value: n }
}

///|
pub fn ST_HoleSizeUByte::new(
  s : String,
) -> ST_HoleSizeUByte raise SchemaViolation {
  ST_HoleSizeUByte::parse(s)
}

///|
pub fn ST_HoleSizeUByte::value(self : ST_HoleSizeUByte) -> Int {
  self.value
}

///|
pub fn ST_HoleSizeUByte::to_string(self : ST_HoleSizeUByte) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_LblOffsetUShort — Part 1 §21.2 (dml-chart.xsd).
/// Restriction of xsd:unsignedShort to 0..1000 inclusive (axis label
/// offset percent as a raw integer).
pub struct ST_LblOffsetUShort {
  value : Int
} derive(Eq, Debug)

///|
pub fn ST_LblOffsetUShort::parse(
  s : String,
) -> ST_LblOffsetUShort raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_LblOffsetUShort", s)
  if n > 1000 {
    invalid("dml-chart.xsd", "ST_LblOffsetUShort", s)
  }
  { value: n }
}

///|
pub fn ST_LblOffsetUShort::new(
  s : String,
) -> ST_LblOffsetUShort raise SchemaViolation {
  ST_LblOffsetUShort::parse(s)
}

///|
pub fn ST_LblOffsetUShort::value(self : ST_LblOffsetUShort) -> Int {
  self.value
}

///|
pub fn ST_LblOffsetUShort::to_string(self : ST_LblOffsetUShort) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_OverlapByte — Part 1 §21.2 (dml-chart.xsd).
/// Restriction of xsd:byte to -100..100 inclusive (bar/column series
/// overlap percent as a raw signed integer).
pub struct ST_OverlapByte {
  value : Int
} derive(Eq, Debug)

///|
pub fn ST_OverlapByte::parse(
  s : String,
) -> ST_OverlapByte raise SchemaViolation {
  let n = parse_signed_int("dml-chart.xsd", "ST_OverlapByte", s)
  if n < -100 || n > 100 {
    invalid("dml-chart.xsd", "ST_OverlapByte", s)
  }
  { value: n }
}

///|
pub fn ST_OverlapByte::new(s : String) -> ST_OverlapByte raise SchemaViolation {
  ST_OverlapByte::parse(s)
}

///|
pub fn ST_OverlapByte::value(self : ST_OverlapByte) -> Int {
  self.value
}

///|
pub fn ST_OverlapByte::to_string(self : ST_OverlapByte) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_SecondPieSizeUShort — Part 1 §21.2 (dml-chart.xsd).
/// Restriction of xsd:unsignedShort to 5..200 inclusive (pie-of-pie /
/// bar-of-pie second-plot size percent as a raw integer).
pub struct ST_SecondPieSizeUShort {
  value : Int
} derive(Eq, Debug)

///|
pub fn ST_SecondPieSizeUShort::parse(
  s : String,
) -> ST_SecondPieSizeUShort raise SchemaViolation {
  let n = parse_unsigned_int("dml-chart.xsd", "ST_SecondPieSizeUShort", s)
  if n < 5 || n > 200 {
    invalid("dml-chart.xsd", "ST_SecondPieSizeUShort", s)
  }
  { value: n }
}

///|
pub fn ST_SecondPieSizeUShort::new(
  s : String,
) -> ST_SecondPieSizeUShort raise SchemaViolation {
  ST_SecondPieSizeUShort::parse(s)
}

///|
pub fn ST_SecondPieSizeUShort::value(self : ST_SecondPieSizeUShort) -> Int {
  self.value
}

///|
pub fn ST_SecondPieSizeUShort::to_string(
  self : ST_SecondPieSizeUShort,
) -> String {
  self.value.to_string()
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
/// Parse a signed xsd:byte/xsd:short/xsd:int-style integer lexical
/// form (optional leading `+`/`-`, decimal digits) into Int. Empty
/// strings and non-digit characters raise.
fn parse_signed_int(
  schema : String,
  type_name : String,
  value : String,
) -> Int raise SchemaViolation {
  if value.length() == 0 {
    invalid(schema, type_name, value)
  }
  let mut i = 0
  let mut negative = false
  if value[0:1] == "-" {
    negative = true
    i = 1
  } else if value[0:1] == "+" {
    i = 1
  }
  if i >= value.length() {
    invalid(schema, type_name, value)
  }
  let mut n = 0
  while i < value.length() {
    let ch = value[i:i + 1]
    if ch < "0" || ch > "9" {
      invalid(schema, type_name, value)
    }
    let d = ch[0].to_int() - "0"[0].to_int()
    n = n * 10 + d
    i = i + 1
  }
  if negative {
    -n
  } else {
    n
  }
}

///|
/// Parse a xsd:unsignedByte/unsignedShort-style lexical integer (no
/// sign, decimal digits) into Int. Empty strings and signs raise.
fn parse_unsigned_int(
  schema : String,
  type_name : String,
  value : String,
) -> Int raise SchemaViolation {
  if value.length() == 0 {
    invalid(schema, type_name, value)
  }
  let mut i = 0
  let mut n = 0
  while i < value.length() {
    let ch = value[i:i + 1]
    if ch < "0" || ch > "9" {
      invalid(schema, type_name, value)
    }
    let d = ch[0].to_int() - "0"[0].to_int()
    n = n * 10 + d
    i = i + 1
  }
  n
}

///|
/// Parse a xsd:unsignedInt-style lexical integer (no sign, decimal
/// digits) into Int64 to cover the full 0..2^32-1 range.
fn parse_unsigned_int64(
  schema : String,
  type_name : String,
  value : String,
) -> Int64 raise SchemaViolation {
  if value.length() == 0 {
    invalid(schema, type_name, value)
  }
  let mut i = 0
  let mut n : Int64 = 0L
  while i < value.length() {
    let ch = value[i:i + 1]
    if ch < "0" || ch > "9" {
      invalid(schema, type_name, value)
    }
    let d = (ch[0].to_int() - "0"[0].to_int()).to_int64()
    n = n * 10L + d
    i = i + 1
  }
  n
}

///|
/// Parse an `(optionally-signed 0-padded integer)%` lexical form into
/// the typed percent integer. `allow_negative` mirrors the union
/// member's regex (only ST_OverlapPercent permits a sign).
fn parse_percent_literal(
  schema : String,
  type_name : String,
  value : String,
  allow_negative~ : Bool,
) -> Int raise SchemaViolation {
  let len = value.length()
  if len < 2 || value[len - 1:len] != "%" {
    invalid(schema, type_name, value)
  }
  let body = value[0:len - 1]
  let body_len = body.length()
  let mut i = 0
  let mut negative = false
  if allow_negative && body_len > 0 && body[0:1] == "-" {
    negative = true
    i = 1
  }
  // Spec patterns all permit leading zeros (`0*`). Reject if there is
  // nothing after the sign.
  if i >= body_len {
    invalid(schema, type_name, value)
  }
  let mut n = 0
  while i < body_len {
    let ch = body[i:i + 1]
    if ch < "0" || ch > "9" {
      invalid(schema, type_name, value)
    }
    let d = ch[0].to_int() - "0"[0].to_int()
    n = n * 10 + d
    i = i + 1
  }
  if negative {
    -n
  } else {
    n
  }
}

///|
/// Parse a `([0-9]+)%` lexical form (the ST_ThicknessPercent pattern —
/// no sign, no `0*` prefix sugar special-cased; a single leading zero
/// is permitted because `[0-9]+` admits it).
fn parse_percent_literal_strict_digits(
  schema : String,
  type_name : String,
  value : String,
) -> Int raise SchemaViolation {
  let len = value.length()
  if len < 2 || value[len - 1:len] != "%" {
    invalid(schema, type_name, value)
  }
  let body = value[0:len - 1]
  let body_len = body.length()
  if body_len == 0 {
    invalid(schema, type_name, value)
  }
  let mut i = 0
  let mut n = 0
  while i < body_len {
    let ch = body[i:i + 1]
    if ch < "0" || ch > "9" {
      invalid(schema, type_name, value)
    }
    let d = ch[0].to_int() - "0"[0].to_int()
    n = n * 10 + d
    i = i + 1
  }
  n
}

///|
/// Parse a xsd:double lexical form (`[-+]?\d+(\.\d+)?`). The chart
/// schema does not exercise the scientific-notation tail, so we stay
/// in decimal land.
fn parse_double(
  schema : String,
  type_name : String,
  value : String,
) -> Double raise SchemaViolation {
  if value.length() == 0 || !looks_like_number(value, allow_decimal=true) {
    invalid(schema, type_name, value)
  }
  let mut i = 0
  let mut negative = false
  if value[0:1] == "-" {
    negative = true
    i = 1
  } else if value[0:1] == "+" {
    i = 1
  }
  let mut whole : Int64 = 0L
  while i < value.length() && value[i:i + 1] != "." {
    let ch = value[i:i + 1]
    let d = (ch[0].to_int() - "0"[0].to_int()).to_int64()
    whole = whole * 10L + d
    i = i + 1
  }
  let mut frac : Double = 0.0
  let mut scale : Double = 1.0
  if i < value.length() && value[i:i + 1] == "." {
    i = i + 1
    while i < value.length() {
      let ch = value[i:i + 1]
      let d = (ch[0].to_int() - "0"[0].to_int()).to_double()
      scale = scale * 10.0
      frac = frac + d / scale
      i = i + 1
    }
  }
  let magnitude = whole.to_double() + frac
  if negative {
    -magnitude
  } else {
    magnitude
  }
}

///|
/// Render a Double back to the canonical xsd:double lexical form ECMA-376
/// emits. Mathematically integral values become bare integer strings;
/// everything else falls through to the platform Double::to_string.
fn format_decimal(value : Double) -> String {
  if value == value.trunc() && value.abs() < 1.0e15 {
    value.to_int64().to_string()
  } else {
    value.to_string()
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
