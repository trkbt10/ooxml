///|
/// Evaluator-side context. The caller supplies a "today" anchor so
/// §18.18.82 ST_TimePeriod evaluation is deterministic, the active
/// date system for §15.2.4.6 serial conversion, and a closure that
/// evaluates a `<formula>` string as a `@formula.FormulaValue` for
/// `expression` and `cellIs` rules. This struct is evaluator-runtime
/// only and intentionally does not correspond to a spec CT_*/ST_*
/// identifier.
pub(all) struct EvalContext {
  today : @date_serial.CalendarDateTime
  date_system : @date_serial.DateSystem
  evaluate_formula : (String) -> @formula.FormulaValue
}

///|
/// EvalContext::new — convenience constructor that wraps a
/// `@formula.WorksheetSnapshot` and uses a single-cell evaluator for
/// the rule's `<formula>` text. The closure recomputes the formula
/// once per call; callers that batch rules should memoise externally.
pub fn EvalContext::new(
  today : @date_serial.CalendarDateTime,
  date_system : @date_serial.DateSystem,
  evaluate_formula : (String) -> @formula.FormulaValue,
) -> EvalContext {
  { today, date_system, evaluate_formula }
}

///|
/// One match record produced by `evaluate_cf_block`. Carries the
/// matched cell, the rule that fired, and any precomputed
/// presentation hints (colorScale ARGB, bar fill ratio, icon bucket
/// index). `dxf_id` is hoisted for convenience so the renderer does
/// not need to re-inspect the rule. This struct is evaluator-runtime
/// only and intentionally does not correspond to a spec CT_*/ST_*
/// identifier.
pub(all) struct MatchHit {
  cell : @address.CellAddress
  rule_priority : Int
  cf_type : @domain.ST_CfType
  dxf_id : Int?
  argb : @domain.CT_Color?
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

///|
/// Part 1 §18.18.12 — decode a ST_CfType lexical attribute value to a
/// typed `@domain.ST_CfType`. Raises SchemaViolation for any non-spec
/// lexical value so callers see the offending text in the report.
pub fn decode_cf_type(
  value : String,
) -> @domain.ST_CfType raise @opc_errors.SchemaViolation {
  match value {
    "aboveAverage" => @domain.AboveAverage
    "beginsWith" => @domain.BeginsWith
    "cellIs" => @domain.CellIs
    "colorScale" => @domain.ColorScale
    "containsBlanks" => @domain.ContainsBlanks
    "containsErrors" => @domain.ContainsErrors
    "containsText" => @domain.ContainsText
    "dataBar" => @domain.DataBar
    "duplicateValues" => @domain.DuplicateValues
    "endsWith" => @domain.EndsWith
    "expression" => @domain.Expression
    "iconSet" => @domain.IconSet
    "notContainsBlanks" => @domain.NotContainsBlanks
    "notContainsErrors" => @domain.NotContainsErrors
    "notContainsText" => @domain.NotContainsText
    "timePeriod" => @domain.TimePeriod
    "top10" => @domain.Top10
    "uniqueValues" => @domain.UniqueValues
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path="cfRule/@type",
        reason="unknown ST_CfType enumeration value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.15 — decode a ST_ConditionalFormattingOperator lexical
/// attribute value. Raises SchemaViolation for any value not in the
/// §18.18.15 enumeration.
pub fn decode_cf_operator(
  value : String,
) -> @domain.ST_ConditionalFormattingOperator raise @opc_errors.SchemaViolation {
  match value {
    "beginsWith" => @domain.OpBeginsWith
    "between" => @domain.OpBetween
    "containsText" => @domain.OpContainsText
    "endsWith" => @domain.OpEndsWith
    "equal" => @domain.OpEqual
    "greaterThan" => @domain.OpGreaterThan
    "greaterThanOrEqual" => @domain.OpGreaterThanOrEqual
    "lessThan" => @domain.OpLessThan
    "lessThanOrEqual" => @domain.OpLessThanOrEqual
    "notBetween" => @domain.OpNotBetween
    "notContains" => @domain.OpNotContains
    "notEqual" => @domain.OpNotEqual
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path="cfRule/@operator",
        reason="unknown ST_ConditionalFormattingOperator value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.82 — decode a ST_TimePeriod lexical value.
pub fn decode_time_period(
  value : String,
) -> @domain.ST_TimePeriod raise @opc_errors.SchemaViolation {
  match value {
    "today" => @domain.Today
    "yesterday" => @domain.Yesterday
    "tomorrow" => @domain.Tomorrow
    "last7Days" => @domain.Last7Days
    "lastWeek" => @domain.LastWeek
    "thisWeek" => @domain.ThisWeek
    "nextWeek" => @domain.NextWeek
    "lastMonth" => @domain.LastMonth
    "thisMonth" => @domain.ThisMonth
    "nextMonth" => @domain.NextMonth
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cf_rule_section,
        path="cfRule/@timePeriod",
        reason="unknown ST_TimePeriod value: " + value,
      )
  }
}

///|
/// Part 1 §18.18.13 — decode a ST_CfvoType lexical value. Raises
/// SchemaViolation if the value is not one of the six spec values.
pub fn decode_cfvo_type(
  value : String,
) -> @domain.ST_CfvoType raise @opc_errors.SchemaViolation {
  match value {
    "num" => @domain.CfvoNum
    "min" => @domain.CfvoMin
    "max" => @domain.CfvoMax
    "percent" => @domain.CfvoPercent
    "percentile" => @domain.CfvoPercentile
    "formula" => @domain.CfvoFormula
    _ =>
      raise @opc_errors.SchemaViolation(
        section=cfvo_section,
        path="cfvo/@type",
        reason="unknown ST_CfvoType value: " + value,
      )
  }
}
