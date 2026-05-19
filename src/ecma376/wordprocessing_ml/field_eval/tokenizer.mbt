///|
/// Part 1 §17.16.1 — instruction token discriminator. The tokenizer
/// emits one `InstructionToken` per lexical element: bare word /
/// quoted text / switch flag (with optional immediately-following
/// argument).
pub(all) enum InstructionToken {
  TWord(String)
  TQuoted(String)
  /// Switch flag character. The optional argument is the next
  /// `TWord` / `TQuoted` that follows on the source side; the
  /// parser is responsible for stitching them together.
  TSwitch(Char)
} derive(Eq, Debug)

///|
/// Part 1 §17.16.1 — lex an instruction string into the typed token
/// stream. Whitespace separates tokens; quoted strings honour `\"`
/// and `\\` escapes; switches start with a single `\` followed by one
/// non-whitespace, non-backslash character.
///
/// Raises `@opc_errors.SchemaViolation` when a quoted string is
/// unterminated.
pub fn tokenize_instruction(
  text : String,
) -> Array[InstructionToken] raise @opc_errors.SchemaViolation {
  let tokens : Array[InstructionToken] = []
  let mut i = 0
  while i < text.length() {
    let unit = text.code_unit_at(i).to_int()
    if unit == 0x20 || unit == 0x09 || unit == 0x0A || unit == 0x0D {
      i = i + 1
      continue
    }
    if unit == 0x5C {
      // Backslash → switch flag.
      if i + 1 >= text.length() {
        raise @opc_errors.SchemaViolation(
          section=field_section,
          path="field/instr",
          reason="trailing backslash with no switch flag",
        )
      }
      let flag_unit = text.code_unit_at(i + 1).to_int()
      let flag = flag_unit.to_char().unwrap()
      tokens.push(TSwitch(flag))
      i = i + 2
      continue
    }
    if unit == 0x22 {
      // Quoted string.
      let (value, next_i) = read_quoted(text, i + 1)
      tokens.push(TQuoted(value))
      i = next_i
      continue
    }
    // Bare word — runs up to whitespace, backslash, or quote.
    let start = i
    while i < text.length() {
      let unit_inner = text.code_unit_at(i).to_int()
      if unit_inner == 0x20 ||
        unit_inner == 0x09 ||
        unit_inner == 0x0A ||
        unit_inner == 0x0D ||
        unit_inner == 0x5C ||
        unit_inner == 0x22 {
        break
      }
      i = i + 1
    }
    tokens.push(TWord(text.unsafe_substring(start~, end=i)))
  }
  tokens
}

///|
fn read_quoted(
  text : String,
  start : Int,
) -> (String, Int) raise @opc_errors.SchemaViolation {
  let buf = StringBuilder::new()
  let mut i = start
  while i < text.length() {
    let unit = text.code_unit_at(i).to_int()
    if unit == 0x22 {
      return (buf.to_string(), i + 1)
    }
    if unit == 0x5C && i + 1 < text.length() {
      let next_unit = text.code_unit_at(i + 1).to_int()
      if next_unit == 0x22 {
        buf.write_char('"')
        i = i + 2
        continue
      }
      if next_unit == 0x5C {
        buf.write_char('\\')
        i = i + 2
        continue
      }
    }
    buf.write_char(unit.to_char().unwrap())
    i = i + 1
  }
  raise @opc_errors.SchemaViolation(
    section=field_section,
    path="field/instr",
    reason="unterminated quoted string in instruction",
  )
}
