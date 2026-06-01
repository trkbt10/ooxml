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
/// the switch via `Field::find_switch`); `\#` and `\*` are applied
/// here in document order.
fn apply_switches(result : FieldResult, field : Field) -> FieldResult {
  let switches = field.switches
  let formatted_text = match result {
    Literal(text) => apply_text_field_switches(text, switches)
    Number(value) => apply_number_field_switches(value, switches)
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
fn apply_text_field_switches(
  value : String,
  switches : Array[FieldSwitch],
) -> String {
  let mut current = value
  for entry in switches {
    match entry.flag {
      '#' =>
        match (entry.argument, parse_field_numeric_value(current)) {
          (Some(picture), Some(number)) =>
            current = format_numeric_picture(number, picture)
          _ => ()
        }
      '*' =>
        match entry.argument {
          Some(arg) => current = apply_general_switch(current, arg)
          None => ()
        }
      _ => ()
    }
  }
  current
}

///|
fn apply_number_field_switches(
  value : Double,
  switches : Array[FieldSwitch],
) -> String {
  let mut current = format_number_base(value)
  for entry in switches {
    match entry.flag {
      '#' =>
        match entry.argument {
          Some(picture) => current = format_numeric_picture(value, picture)
          None => ()
        }
      '*' =>
        match entry.argument {
          Some(arg) => current = apply_general_switch(current, arg)
          None => ()
        }
      _ => ()
    }
  }
  current
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
