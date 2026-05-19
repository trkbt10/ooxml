///|
/// Part 1 §17.16 — evaluator driver. Looks up the field's
/// instruction in the registry, evaluates it, and applies the
/// `\@` (date), `\#` (numeric — v1 placeholder), and `\*` (general)
/// formatting switches in document order.
///
/// Falls back to `FieldResult::Literal(field.instr_text)` when no
/// evaluator is registered for the instruction, so unknown fields
/// remain visible in the rendered document.
pub fn evaluate_field(
  field : Field,
  ctx : FieldContext,
  registry : FieldRegistry,
) -> FieldResult {
  let key = field.instruction.canonical_name()
  let raw = match registry.lookup(key) {
    Some(evaluator) => evaluator(field, ctx)
    None => Literal(field.instr_text)
  }
  apply_switches(raw, field)
}

///|
/// Apply formatting switches to a raw evaluator result. `\@` is
/// already applied by the date evaluators themselves (they receive
/// the switch via `Field::find_switch`); `\*` is applied here.
fn apply_switches(result : FieldResult, field : Field) -> FieldResult {
  let switches = field.switches
  let formatted_text = match result {
    Literal(text) => apply_general_switches(text, switches)
    Number(value) => {
      let base = format_number_base(value)
      apply_general_switches(base, switches)
    }
    DateResult(_, formatted) => apply_general_switches(formatted, switches)
    Hyperlink(url, display) => {
      let formatted_display = apply_general_switches(display, switches)
      return Hyperlink(url, formatted_display)
    }
    Empty => return Empty
  }
  match result {
    Literal(_) => Literal(formatted_text)
    Number(_) => Literal(formatted_text)
    DateResult(date, _) => DateResult(date, formatted_text)
    Hyperlink(_, _) => result
    Empty => Empty
  }
}

///|
fn format_number_base(value : Double) -> String {
  if value.is_nan() || value.is_inf() {
    return value.to_string()
  }
  if value == value.trunc() && value.abs() < 1.0e15 {
    value.to_int64().to_string()
  } else {
    value.to_string()
  }
}
