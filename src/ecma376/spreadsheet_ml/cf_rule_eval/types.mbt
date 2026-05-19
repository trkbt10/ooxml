///|
/// Part 1 §18.18.12 ST_CfType — conditional format rule type. Sixteen
/// enumeration values cover comparison, text predicate, blank/error,
/// duplicate/unique, top10, aboveAverage, timePeriod, expression,
/// colorScale, dataBar, and iconSet rules.
pub(all) enum CfType {
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
/// Part 1 §18.18.12 — decode a ST_CfType lexical attribute value to a
/// typed `CfType`. Raises SchemaViolation for any non-spec lexical
/// value so callers see the offending text in the report.
pub fn CfType::from_attr(
  value : String,
) -> CfType raise @opc_errors.SchemaViolation {
  match value {
    "aboveAverage" => AboveAverage
    "beginsWith" => BeginsWith
    "cellIs" => CellIs
    "colorScale" => ColorScale
    "containsBlanks" => ContainsBlanks
    "containsErrors" => ContainsErrors
    "containsText" => ContainsText
    "dataBar" => DataBar
    "duplicateValues" => DuplicateValues
    "endsWith" => EndsWith
    "expression" => Expression
    "iconSet" => IconSet
    "notContainsBlanks" => NotContainsBlanks
    "notContainsErrors" => NotContainsErrors
    "notContainsText" => NotContainsText
    "timePeriod" => TimePeriod
    "top10" => Top10
    "uniqueValues" => UniqueValues
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path="cfRule/@type",
        reason="unknown ST_CfType enumeration value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.15 ST_ConditionalFormattingOperator — operator applied
/// in `cellIs` rules. Twelve enumeration values: equal, notEqual,
/// greaterThan, greaterThanOrEqual, lessThan, lessThanOrEqual, between,
/// notBetween, containsText, notContains, beginsWith, endsWith.
pub(all) enum CfOperator {
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
/// Part 1 §18.18.15 — decode a ST_ConditionalFormattingOperator lexical
/// attribute value to a `CfOperator`. Raises SchemaViolation for any
/// value not in the §18.18.15 enumeration.
pub fn CfOperator::from_attr(
  value : String,
) -> CfOperator raise @opc_errors.SchemaViolation {
  match value {
    "beginsWith" => OpBeginsWith
    "between" => OpBetween
    "containsText" => OpContainsText
    "endsWith" => OpEndsWith
    "equal" => OpEqual
    "greaterThan" => OpGreaterThan
    "greaterThanOrEqual" => OpGreaterThanOrEqual
    "lessThan" => OpLessThan
    "lessThanOrEqual" => OpLessThanOrEqual
    "notBetween" => OpNotBetween
    "notContains" => OpNotContains
    "notEqual" => OpNotEqual
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path="cfRule/@operator",
        reason="unknown ST_ConditionalFormattingOperator value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.82 ST_TimePeriod — dynamic date window for the
/// `timePeriod` rule type. Ten enumeration values: today, yesterday,
/// tomorrow, last7Days, lastWeek, thisWeek, nextWeek, lastMonth,
/// thisMonth, nextMonth.
pub(all) enum TimePeriod {
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
/// Part 1 §18.18.82 — decode a ST_TimePeriod lexical value.
pub fn TimePeriod::from_attr(
  value : String,
) -> TimePeriod raise @opc_errors.SchemaViolation {
  match value {
    "today" => Today
    "yesterday" => Yesterday
    "tomorrow" => Tomorrow
    "last7Days" => Last7Days
    "lastWeek" => LastWeek
    "thisWeek" => ThisWeek
    "nextWeek" => NextWeek
    "lastMonth" => LastMonth
    "thisMonth" => ThisMonth
    "nextMonth" => NextMonth
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path="cfRule/@timePeriod",
        reason="unknown ST_TimePeriod value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.13 ST_CfvoType — threshold mode for a cfvo entry
/// inside colorScale / dataBar / iconSet. Six enumeration values:
/// num, min, max, percent, percentile, formula.
pub(all) enum CfvoType {
  CfvoNum
  CfvoMin
  CfvoMax
  CfvoPercent
  CfvoPercentile
  CfvoFormula
} derive(Eq, Debug)

///|
/// Part 1 §18.18.13 — decode a ST_CfvoType lexical value. Raises
/// SchemaViolation if the value is not one of the six spec values.
pub fn CfvoType::from_attr(
  value : String,
) -> CfvoType raise @opc_errors.SchemaViolation {
  match value {
    "num" => CfvoNum
    "min" => CfvoMin
    "max" => CfvoMax
    "percent" => CfvoPercent
    "percentile" => CfvoPercentile
    "formula" => CfvoFormula
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cfvo_section,
        path="cfvo/@type",
        reason="unknown ST_CfvoType value: " + value,
      )
  }
}

///|
/// Part 1 §18.3.1.11 cfvo — a single conditional formatting value
/// object: a (type, raw value text) pair that the evaluator resolves
/// against the population to produce a numeric threshold.
pub(all) struct CfvoThreshold {
  kind : CfvoType
  value_text : String?
} derive(Eq, Debug)

///|
/// Part 1 §18.3.1.15 color — ARGB triple plus theme/tint metadata for
/// colorScale and dataBar entries. Theme/index lookups are out of scope
/// for the evaluator; the renderer feeds resolved ARGB tuples in.
pub(all) struct CfArgb {
  alpha : Int
  red : Int
  green : Int
  blue : Int
} derive(Eq, Debug)

///|
/// CfArgb::new — construct a clamped ARGB tuple. Each channel is forced
/// into the 0..255 range so interpolation cannot escape the spec gamut
/// of §18.3.1.15.
pub fn CfArgb::new(alpha : Int, red : Int, green : Int, blue : Int) -> CfArgb {
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
/// Part 1 §18.3.1.16 colorScale — gradient between cfvo thresholds and
/// matching colors. The two arrays are positionally paired per §18.3.1.16
/// ("first cfvo corresponds with first color, and so on") and the
/// evaluator interpolates linearly between adjacent stops.
pub(all) struct CfColorScale {
  thresholds : Array[CfvoThreshold]
  colors : Array[CfArgb]
} derive(Eq, Debug)

///|
/// Part 1 §18.3.1.28 dataBar — bar length thresholds (min/max cfvo
/// pair) and bar fill color.
pub(all) struct CfDataBar {
  min_threshold : CfvoThreshold
  max_threshold : CfvoThreshold
  color : CfArgb
} derive(Eq, Debug)

///|
/// Part 1 §18.3.1.49 iconSet — discrete icon bucketing. `cfvo_count`
/// equals the number of icons in the set; the evaluator returns the
/// bucket index (0..cfvo_count-1) per cell.
pub(all) struct CfIconSet {
  set_name : String
  thresholds : Array[CfvoThreshold]
  reverse : Bool
  show_value : Bool
} derive(Eq, Debug)

///|
/// Part 1 §18.3.1.10 cfRule — typed view of one conditional formatting
/// rule. Attributes only meaningful for specific @type values are
/// captured as `Option`s; the evaluator ignores them when @type does
/// not match the spec gating (see §18.3.1.10 column descriptions).
pub(all) struct CfRule {
  cf_type : CfType
  dxf_id : Int?
  priority : Int
  stop_if_true : Bool
  operator : CfOperator?
  text : String?
  time_period : TimePeriod?
  rank : Int?
  bottom : Bool
  percent : Bool
  above_average : Bool
  equal_average : Bool
  std_dev : Int?
  formulas : Array[String]
  color_scale : CfColorScale?
  data_bar : CfDataBar?
  icon_set : CfIconSet?
} derive(Eq, Debug)

///|
/// CfRule::is_population_rule — true when the rule's spec semantics
/// require the full sqref population (top10, aboveAverage, duplicate /
/// unique values, colorScale, dataBar, iconSet). Per-cell rules (cellIs,
/// containsText, …) return false so callers can skip the population
/// scan. Cited from §18.18.12 ST_CfType — those entries that explicitly
/// say "in the range" require population.
pub fn CfRule::is_population_rule(self : CfRule) -> Bool {
  match self.cf_type {
    Top10 => true
    AboveAverage => true
    DuplicateValues => true
    UniqueValues => true
    ColorScale => true
    DataBar => true
    IconSet => true
    _ => false
  }
}

///|
/// CfRule::has_dxf — true when @dxfId is set and the rule applies a
/// differential format (per §18.3.1.10, the dxfId references a dxf in
/// the Styles part). ColorScale / dataBar / iconSet draw their own
/// visualisation and may have no dxfId; the renderer uses these to
/// decide whether to look up a dxf entry.
pub fn CfRule::has_dxf(self : CfRule) -> Bool {
  if self.dxf_id is Some(_) {
    true
  } else {
    false
  }
}

///|
/// Part 1 §18.3.1.18 conditionalFormatting — outer collection: the
/// `pivot` flag, the `sqref` ranges, and the typed rules. The decoder
/// pre-sorts rules ascending by `priority` so §18.3.1.10's "lower
/// numeric values are higher priority" ordering is enforced once.
pub(all) struct CfBlock {
  pivot : Bool
  sqref : @address.Sqref
  rules : Array[CfRule]
} derive(Eq, Debug)

///|
/// Evaluator-side context. The caller supplies a "today" anchor so
/// §18.18.82 ST_TimePeriod evaluation is deterministic, the active
/// date system for §15.2.4.6 serial conversion, and a closure that
/// evaluates a `<formula>` string as a `@formula.FormulaValue` for
/// `expression` and `cellIs` rules.
pub(all) struct CfEvalContext {
  today : @date_serial.CalendarDateTime
  date_system : @date_serial.DateSystem
  evaluate_formula : (String) -> @formula.FormulaValue
}

///|
/// CfEvalContext::new — convenience constructor that wraps a
/// `@formula.WorksheetSnapshot` and uses a single-cell evaluator for
/// the rule's `<formula>` text. The closure recomputes the formula
/// once per call; callers that batch rules should memoise externally.
pub fn CfEvalContext::new(
  today : @date_serial.CalendarDateTime,
  date_system : @date_serial.DateSystem,
  evaluate_formula : (String) -> @formula.FormulaValue,
) -> CfEvalContext {
  { today, date_system, evaluate_formula }
}

///|
/// One match record produced by `evaluate_cf_block`. Carries the
/// matched cell, the rule that fired, and any precomputed
/// presentation hints (colorScale ARGB, bar fill ratio, icon bucket
/// index). `dxf_id` is hoisted for convenience so the renderer does
/// not need to re-inspect the rule.
pub(all) struct CfHit {
  cell : @address.CellAddress
  rule_priority : Int
  cf_type : CfType
  dxf_id : Int?
  argb : CfArgb?
  bar_ratio : Double?
  icon_index : Int?
} derive(Eq, Debug)

///|
let cf_rule_section : String = "Part 1 §18.3.1.10 / §18.18.12"

///|
let cfvo_section : String = "Part 1 §18.3.1.11 / §18.18.13"

///|
/// §18.3.1.10 — citation helper exported so callers can include the
/// spec anchor in their own diagnostics. Returns the canonical
/// "Part 1 §18.3.1.10 / §18.18.12" string.
pub fn cf_rule_part1_18_3_1_10_section_name() -> String {
  cf_rule_section
}

///|
/// §18.3.1.18 — citation helper for the outer conditionalFormatting
/// element.
pub fn cf_rule_part1_18_3_1_18_section_name() -> String {
  "Part 1 §18.3.1.18 / §18.18.12"
}
