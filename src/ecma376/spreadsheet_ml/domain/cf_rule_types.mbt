///|
/// SpreadsheetML conditional formatting typed domain. Per the
/// ECMA-376 Part 1 §18.3.1.10 (cfRule) / §18.3.1.18 (conditionalFormatting)
/// / §18.18.12-.82 (ST_CfType / ST_ConditionalFormattingOperator /
/// ST_CfvoType / ST_TimePeriod) family. Decoders and evaluators in
/// `cf_rule_eval` consume the typed records defined here, so the
/// spec-mandated `CT_CfRule`, `CT_ConditionalFormatting`, `CT_ColorScale`,
/// `CT_DataBar`, `CT_IconSet`, `CT_Cfvo` identifiers stay canonical
/// in `@domain`. The internal ARGB tuple used during cf evaluation
/// is `CT_ColorArgb` (different from the schema CT_Color in
/// style_types.mbt).

///|
/// XSD simple type ST_CfType — Part 1 §18.18.12. Conditional format rule
/// type. Eighteen enumeration values cover comparison, text predicate,
/// blank/error, duplicate/unique, top10, aboveAverage, timePeriod,
/// expression, colorScale, dataBar, and iconSet rules.
pub(all) enum ST_CfType {
  /// §18.18.12 aboveAverage — highlights cells above/below the mean.
  AboveAverage
  /// §18.18.12 beginsWith — equivalent to LEFT() match.
  BeginsWith
  /// §18.18.12 cellIs — compares cell to formula via @operator.
  CellIs
  /// §18.18.12 colorScale — gradated background color.
  ColorScale
  /// §18.18.12 containsBlanks — LEN(TRIM(value)) = 0.
  ContainsBlanks
  /// §18.18.12 containsErrors — ISERROR(value) = TRUE.
  ContainsErrors
  /// §18.18.12 containsText — SEARCH(text, value) match.
  ContainsText
  /// §18.18.12 dataBar — gradated bar across the cell.
  DataBar
  /// §18.18.12 duplicateValues — value appears more than once.
  DuplicateValues
  /// §18.18.12 endsWith — equivalent to RIGHT() match.
  EndsWith
  /// §18.18.12 expression — boolean result of the rule's @formula.
  Expression
  /// §18.18.12 iconSet — value-bucket icon assignment.
  IconSet
  /// §18.18.12 notContainsBlanks — LEN(TRIM(value)) > 0.
  NotContainsBlanks
  /// §18.18.12 notContainsErrors — ISERROR(value) = FALSE.
  NotContainsErrors
  /// §18.18.12 notContainsText — SEARCH(text, value) is no match.
  NotContainsText
  /// §18.18.12 timePeriod — date in a §18.18.82 ST_TimePeriod window.
  TimePeriod
  /// §18.18.12 top10 — top or bottom N (or N percent) of population.
  Top10
  /// §18.18.12 uniqueValues — value appears exactly once.
  UniqueValues
} derive(Eq, Debug)

///|
/// XSD simple type ST_ConditionalFormattingOperator — Part 1 §18.18.15.
/// Operator applied in `cellIs` rules. Twelve enumeration values:
/// equal, notEqual, greaterThan, greaterThanOrEqual, lessThan,
/// lessThanOrEqual, between, notBetween, containsText, notContains,
/// beginsWith, endsWith.
pub(all) enum ST_ConditionalFormattingOperator {
  OpBeginsWith
  OpBetween
  OpContainsText
  OpEndsWith
  OpEqual
  OpGreaterThan
  OpGreaterThanOrEqual
  OpLessThan
  OpLessThanOrEqual
  OpNotBetween
  OpNotContains
  OpNotEqual
} derive(Eq, Debug)

///|
/// XSD simple type ST_TimePeriod — Part 1 §18.18.82. Dynamic date window
/// for the `timePeriod` rule type. Ten enumeration values: today,
/// yesterday, tomorrow, last7Days, lastWeek, thisWeek, nextWeek,
/// lastMonth, thisMonth, nextMonth.
pub(all) enum ST_TimePeriod {
  Today
  Yesterday
  Tomorrow
  Last7Days
  LastWeek
  ThisWeek
  NextWeek
  LastMonth
  ThisMonth
  NextMonth
} derive(Eq, Debug)

///|
/// XSD simple type ST_CfvoType — Part 1 §18.18.13. Threshold mode for a
/// cfvo entry inside colorScale / dataBar / iconSet. Six enumeration
/// values: num, min, max, percent, percentile, formula.
pub(all) enum ST_CfvoType {
  CfvoNum
  CfvoMin
  CfvoMax
  CfvoPercent
  CfvoPercentile
  CfvoFormula
} derive(Eq, Debug)

///|
/// XSD complex type CT_Cfvo — Part 1 §18.3.1.11. A single conditional
/// formatting value object: a (type, raw value text) pair that the
/// evaluator resolves against the population to produce a numeric
/// threshold.
pub(all) struct CT_Cfvo {
  kind : ST_CfvoType
  value_text : String?
} derive(Eq, Debug)

///|
/// Domain-internal ARGB tuple used by the conditional-formatting
/// evaluator (§18.3.1.10 / §18.3.1.16 / §18.3.1.28). This is *not* the
/// schema CT_Color (§18.8.3) — that's `CT_Color` in style_types.mbt
/// and carries five attributes (auto/indexed/rgb/theme/tint). The
/// cf-eval pipeline pre-resolves all theme/indexed/tint lookups
/// during decode (see cf_rule_eval/decode.mbt::parse_argb_hex) and
/// only ever materialises this 4-channel carrier for blending and
/// bucket selection.
pub(all) struct CT_ColorArgb {
  alpha : Int
  red : Int
  green : Int
  blue : Int
} derive(Eq, Debug)

///|
/// CT_ColorArgb::new — construct a clamped ARGB tuple. Each channel is
/// forced into the 0..255 range so interpolation cannot escape the
/// spec gamut of §18.3.1.15.
pub fn CT_ColorArgb::new(
  alpha : Int,
  red : Int,
  green : Int,
  blue : Int,
) -> CT_ColorArgb {
  let clamp = fn(x : Int) -> Int {
    if x < 0 {
      0
    } else if x > 255 {
      255
    } else {
      x
    }
  }
  {
    alpha: clamp(alpha),
    red: clamp(red),
    green: clamp(green),
    blue: clamp(blue),
  }
}

///|
/// XSD complex type CT_ColorScale — Part 1 §18.3.1.16. Gradient between
/// cfvo thresholds and matching colors. The two arrays are positionally
/// paired per §18.3.1.16 ("first cfvo corresponds with first color, and
/// so on") and the evaluator interpolates linearly between adjacent
/// stops.
pub(all) struct CT_ColorScale {
  thresholds : Array[CT_Cfvo]
  colors : Array[CT_ColorArgb]
} derive(Eq, Debug)

///|
/// XSD complex type CT_DataBar — Part 1 §18.3.1.28. Bar length
/// thresholds (min/max cfvo pair) plus bar fill color. The spec
/// also defines several `@*Color`, `@axisPosition`, `@direction`,
/// `@showValue`, `@minLength`, `@maxLength`, `@gradient`,
/// `@border` attributes; the viewer surfaces these via the raw
/// `element` until a typed projection is wired in.
pub(all) struct CT_DataBar {
  /// Source element preserved so renderers can read the §18.3.1.28
  /// attributes the typed projection does not yet capture
  /// (negativeFillColor / axisPosition / direction / etc.).
  element : @xml.Element
  min_threshold : CT_Cfvo
  max_threshold : CT_Cfvo
  color : CT_ColorArgb
} derive(Eq, Debug)

///|
/// XSD complex type CT_IconSet — Part 1 §18.3.1.49. Discrete icon
/// bucketing. The number of thresholds equals the number of icons in
/// the set; the evaluator returns the bucket index (0..thresholds-1)
/// per cell.
pub(all) struct CT_IconSet {
  set_name : String
  thresholds : Array[CT_Cfvo]
  reverse : Bool
  show_value : Bool
} derive(Eq, Debug)

///|
/// XSD complex type CT_CfRule — Part 1 §18.3.1.10. Typed view of one
/// conditional formatting rule. Attributes only meaningful for specific
/// @type values are captured as `Option`s; the evaluator ignores them
/// when @type does not match the spec gating (see §18.3.1.10 column
/// descriptions). `@type` itself is `use="optional"` in the XSD: a
/// `<cfRule>` with no `@type` is well-formed, so `cf_type` is an
/// `Option`. A type-less rule is inert — the evaluator applies no
/// format and the renderer draws nothing for it.
pub(all) struct CT_CfRule {
  cf_type : ST_CfType?
  dxf_id : Int?
  priority : Int
  stop_if_true : Bool
  operator : ST_ConditionalFormattingOperator?
  text : String?
  time_period : ST_TimePeriod?
  rank : Int?
  bottom : Bool
  percent : Bool
  above_average : Bool
  equal_average : Bool
  std_dev : Int?
  formulas : Array[String]
  color_scale : CT_ColorScale?
  data_bar : CT_DataBar?
  icon_set : CT_IconSet?
} derive(Eq, Debug)

///|
/// CT_CfRule::is_population_rule — true when the rule's spec semantics
/// require the full sqref population (top10, aboveAverage, duplicate /
/// unique values, colorScale, dataBar, iconSet). Per-cell rules
/// (cellIs, containsText, …) return false so callers can skip the
/// population scan. Cited from §18.18.12 ST_CfType — those entries
/// that explicitly say "in the range" require population. A type-less
/// rule (`@type` absent, §18.3.1.10 `use="optional"`) is inert and
/// requires no population, so it returns false.
pub fn CT_CfRule::is_population_rule(self : CT_CfRule) -> Bool {
  match self.cf_type {
    Some(Top10) => true
    Some(AboveAverage) => true
    Some(DuplicateValues) => true
    Some(UniqueValues) => true
    Some(ColorScale) => true
    Some(DataBar) => true
    Some(IconSet) => true
    _ => false
  }
}

///|
/// CT_CfRule::has_dxf — true when @dxfId is set and the rule applies a
/// differential format (per §18.3.1.10, the dxfId references a dxf in
/// the Styles part). ColorScale / dataBar / iconSet draw their own
/// visualisation and may have no dxfId; the renderer uses these to
/// decide whether to look up a dxf entry.
pub fn CT_CfRule::has_dxf(self : CT_CfRule) -> Bool {
  if self.dxf_id is Some(_) {
    true
  } else {
    false
  }
}

///|
/// XSD complex type CT_ConditionalFormatting — Part 1 §18.3.1.18. Outer
/// collection: the `pivot` flag, the `sqref` ranges, and the typed
/// rules. The decoder pre-sorts rules ascending by `priority` so
/// §18.3.1.10's "lower numeric values are higher priority" ordering is
/// enforced once.
pub(all) struct CT_ConditionalFormatting {
  pivot : Bool
  sqref : @address.Sqref
  rules : Array[CT_CfRule]
} derive(Eq, Debug)
