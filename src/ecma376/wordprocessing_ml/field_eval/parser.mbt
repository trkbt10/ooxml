///|
/// Part 1 §17.16.1 — parse an instruction string into a typed `Field`.
/// The first non-switch token is the instruction name; subsequent
/// non-switch tokens are positional `field-argument`s; `\X` switches
/// consume the following non-switch token as their argument when one
/// is present.
pub fn parse_instruction(
  text : String,
) -> Field raise @opc_errors.SchemaViolation {
  let tokens = tokenize_instruction(text)
  if tokens.length() == 0 {
    raise @opc_errors.SchemaViolation(
      section=field_section,
      path="field/instr",
      reason="empty instruction",
    )
  }
  let instruction = FieldInstruction::from_name(token_text(tokens[0]))
  let arguments : Array[String] = []
  let switches : Array[FieldSwitch] = []
  let mut i = 1
  while i < tokens.length() {
    match tokens[i] {
      TSwitch(flag) => {
        let mut argument : String? = None
        if i + 1 < tokens.length() {
          match tokens[i + 1] {
            TWord(value) => {
              argument = Some(value)
              i = i + 1
            }
            TQuoted(value) => {
              argument = Some(value)
              i = i + 1
            }
            _ => ()
          }
        }
        switches.push({ flag, argument })
      }
      TWord(value) => arguments.push(value)
      TQuoted(value) => arguments.push(value)
    }
    i = i + 1
  }
  { instr_text: text, instruction, arguments, switches }
}

///|
fn token_text(token : InstructionToken) -> String {
  match token {
    TWord(value) => value
    TQuoted(value) => value
    TSwitch(flag) => "\\" + flag.to_string()
  }
}
