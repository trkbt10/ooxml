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
  argb : @domain.CT_ColorArgb?
  bar_ratio : Double?
  icon_index : Int?
} derive(Eq, Debug)

///|
let cf_rule_section : String = "Part 1 §18.3.1.10 / §18.18.12"

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
/// Part 1 §18.18.12 — decode a ST_CfType lexical attribute. Thin
/// re-export of `@domain.decode_cf_type`.
pub fn decode_cf_type(
  value : String,
) -> @domain.ST_CfType raise @opc_errors.SchemaViolation {
  @domain.decode_cf_type(value)
}

///|
/// Part 1 §18.18.15 — decode a ST_ConditionalFormattingOperator
/// lexical attribute. Thin re-export of
/// `@domain.decode_cf_operator`.
pub fn decode_cf_operator(
  value : String,
) -> @domain.ST_ConditionalFormattingOperator raise @opc_errors.SchemaViolation {
  @domain.decode_cf_operator(value)
}

///|
/// Part 1 §18.18.82 — decode a ST_TimePeriod lexical value. Thin
/// re-export of `@domain.decode_time_period`.
pub fn decode_time_period(
  value : String,
) -> @domain.ST_TimePeriod raise @opc_errors.SchemaViolation {
  @domain.decode_time_period(value)
}

///|
/// Part 1 §18.18.13 — decode a ST_CfvoType lexical value. Thin
/// re-export of `@domain.decode_cfvo_type`.
pub fn decode_cfvo_type(
  value : String,
) -> @domain.ST_CfvoType raise @opc_errors.SchemaViolation {
  @domain.decode_cfvo_type(value)
}
