///|
/// Part 1 §17.16.2 — decode a `w:fldSimple` element into a `Field`.
/// The instruction text lives in the `w:instr` attribute (or its
/// namespace-stripped form `instr`).
pub fn decode_simple_field(
  field : @domain.CT_SimpleField,
) -> Field raise @opc_errors.SchemaViolation {
  let element = field.element
  let instr = match attr(element, "instr") {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=field_section,
        path="fldSimple/@instr",
        reason="fldSimple is missing required @instr attribute",
      )
  }
  parse_instruction(instr)
}

///|
/// Part 1 §17.16.2 — paired `(Field, cached_runs)` returned by the
/// `w:fldChar` decoder. `cached_runs` is the slice of `w:r` CT_R
/// projections that appeared between `w:fldCharType="separate"` and
/// `w:fldCharType="end"`; renderers can drop back to these runs when
/// the evaluator declines to produce a result.
pub(all) struct DecodedField {
  field : Field
  cached_runs : Array[@domain.CT_R]
} derive(Eq, Debug)

///|
/// Part 1 §17.16.2 — decoded complex field plus source-run range.
/// `start_run`, `separate_run`, and `end_run` are indexes into the
/// run array passed to `decode_field_run_ranges`, allowing renderers
/// to replace exactly the field's original run span without re-parsing
/// the instruction text locally.
pub(all) struct DecodedFieldRange {
  field : Field
  cached_runs : Array[@domain.CT_R]
  start_run : Int
  separate_run : Int?
  end_run : Int
} derive(Eq, Debug)

///|
/// Part 1 §17.16.2 — walk a run sequence and decode every begin /
/// separate / end field. Nested fields are supported: the inner field
/// is decoded first and its decoded form is appended to the outer
/// list. Mismatched begin / end markers raise SchemaViolation.
pub fn decode_field_run_sequence(
  runs : Array[@domain.CT_R],
) -> Array[DecodedField] raise @opc_errors.SchemaViolation {
  let ranges = decode_field_run_ranges(runs)
  let result : Array[DecodedField] = []
  for entry in ranges {
    result.push({ field: entry.field, cached_runs: entry.cached_runs })
  }
  result
}

///|
/// Part 1 §17.16.2 — walk a run sequence and decode every begin /
/// separate / end field, including the original source-run range for
/// each field. Renderers use the range to decide which original runs to
/// replace when a field evaluator produces a live result.
pub fn decode_field_run_ranges(
  runs : Array[@domain.CT_R],
) -> Array[DecodedFieldRange] raise @opc_errors.SchemaViolation {
  let result : Array[DecodedFieldRange] = []
  let stack : Array[FieldFrame] = []
  for run_idx, run in runs {
    let mut contains_field_marker = false
    for child in run.element.children {
      match child {
        @xml.Element(child_element) => {
          let local_name = child_element.name.local_name
          if local_name == "fldChar" {
            contains_field_marker = true
            let kind = attr(child_element, "fldCharType")
            match kind {
              Some("begin") =>
                stack.push({
                  instr_buf: StringBuilder::new(),
                  cached_runs: [],
                  start_run: run_idx,
                  separate_run: None,
                  past_separate: false,
                })
              Some("separate") => {
                let top = stack_top(stack)
                top.past_separate = true
                top.separate_run = Some(run_idx)
              }
              Some("end") => {
                let top = stack_pop(stack)
                let field = parse_instruction(top.instr_buf.to_string())
                result.push({
                  field,
                  cached_runs: top.cached_runs,
                  start_run: top.start_run,
                  separate_run: top.separate_run,
                  end_run: run_idx,
                })
              }
              _ => ()
            }
          } else if local_name == "instrText" {
            contains_field_marker = true
            if stack.length() > 0 {
              let top = stack_top(stack)
              top.instr_buf.write_string(text_content(child_element))
            }
          }
        }
        _ => ()
      }
    }
    if stack.length() > 0 && !contains_field_marker {
      let top = stack_top(stack)
      if top.past_separate {
        top.cached_runs.push(run)
      }
    }
  }
  if stack.length() != 0 {
    raise @opc_errors.SchemaViolation(
      section=field_section,
      path="fldChar",
      reason="unmatched fldChar begin marker",
    )
  }
  result
}

///|
priv struct FieldFrame {
  instr_buf : StringBuilder
  cached_runs : Array[@domain.CT_R]
  start_run : Int
  mut separate_run : Int?
  mut past_separate : Bool
}

///|
fn stack_top(stack : Array[FieldFrame]) -> FieldFrame {
  stack[stack.length() - 1]
}

///|
fn stack_pop(stack : Array[FieldFrame]) -> FieldFrame {
  let top = stack[stack.length() - 1]
  let _ = stack.pop()
  top
}

///|
fn attr(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
fn text_content(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for child in element.children {
    match child {
      @xml.Text(text) => buf.write_string(text)
      @xml.CData(text) => buf.write_string(text)
      _ => ()
    }
  }
  buf.to_string()
}
