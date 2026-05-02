///|
fn register_builtin_text_functions(registry : FunctionRegistry) -> Unit {
  registry.register("CONCAT", Eager(fn_concat))
  registry.register("CONCATENATE", Eager(fn_concatenate))
  registry.register("LEN", Eager(fn_len))
  registry.register("LEFT", Eager(fn_left))
  registry.register("RIGHT", Eager(fn_right))
  registry.register("MID", Eager(fn_mid))
  registry.register("UPPER", Eager(fn_upper))
  registry.register("LOWER", Eager(fn_lower))
  registry.register("PROPER", Eager(fn_proper))
  registry.register("TRIM", Eager(fn_trim))
  registry.register("FIND", Eager(fn_find))
  registry.register("SEARCH", Eager(fn_search))
  registry.register("SUBSTITUTE", Eager(fn_substitute))
  registry.register("REPLACE", Eager(fn_replace))
  registry.register("REPT", Eager(fn_rept))
  registry.register("TEXT", Eager(fn_text))
  registry.register("VALUE", Eager(fn_value))
  registry.register("EXACT", Eager(fn_exact))
  registry.register("CHAR", Eager(fn_char))
  registry.register("CODE", Eager(fn_code))
}

///|
/// §18.17.7.CONCAT — concatenate text from scalar and range arguments.
fn fn_concat(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    return VError(Value)
  }
  let out = StringBuilder::new()
  for arg in args {
    match append_text_value(out, arg, true) {
      Some(err) => return VError(err)
      None => ()
    }
  }
  VString(out.to_string())
}

///|
/// §18.17.7.CONCATENATE — concatenate scalar text arguments.
fn fn_concatenate(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  if args.length() == 0 {
    return VError(Value)
  }
  let out = StringBuilder::new()
  for arg in args {
    match append_text_value(out, arg, false) {
      Some(err) => return VError(err)
      None => ()
    }
  }
  VString(out.to_string())
}

///|
/// §18.17.7.LEN — return the character count of text.
fn fn_len(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  match one_text(args) {
    VString(text) => VNumber(text_char_length(text).to_double())
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.LEFT — return the leftmost characters from text.
fn fn_left(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 && args.length() != 2 {
    return VError(Value)
  }
  let text = scalar_text(args[0])
  let count = optional_count(args, 1, 1.0)
  match (text, count) {
    (VString(value), VNumber(n)) =>
      if n < 0.0 {
        VError(Value)
      } else {
        VString(text_left(value, n.trunc().to_int()))
      }
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.RIGHT — return the rightmost characters from text.
fn fn_right(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 && args.length() != 2 {
    return VError(Value)
  }
  let text = scalar_text(args[0])
  let count = optional_count(args, 1, 1.0)
  match (text, count) {
    (VString(value), VNumber(n)) =>
      if n < 0.0 {
        VError(Value)
      } else {
        VString(text_right(value, n.trunc().to_int()))
      }
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.MID — return characters from a 1-based position in text.
fn fn_mid(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 {
    return VError(Value)
  }
  let text = scalar_text(args[0])
  let start = scalar_integer(args[1])
  let count = scalar_integer(args[2])
  match (text, start, count) {
    (VString(value), VNumber(start_num), VNumber(num_chars)) =>
      if start_num < 1.0 || num_chars < 0.0 {
        VError(Value)
      } else {
        VString(text_mid(value, start_num.to_int() - 1, num_chars.to_int()))
      }
    (VError(err), _, _) | (_, VError(err), _) | (_, _, VError(err)) =>
      VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.UPPER — return an uppercase copy of text.
fn fn_upper(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  match one_text(args) {
    VString(text) => VString(text.to_upper())
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.LOWER — return a lowercase copy of text.
fn fn_lower(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  match one_text(args) {
    VString(text) => VString(text.to_lower())
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.PROPER — uppercase the first letter of each word.
fn fn_proper(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  match one_text(args) {
    VString(text) => VString(text_proper(text))
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.TRIM — strip ends and collapse internal spaces.
fn fn_trim(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  match one_text(args) {
    VString(text) => VString(text_trim_spaces(text))
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.FIND — find case-sensitive text from a 1-based start position.
fn fn_find(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 && args.length() != 3 {
    return VError(Value)
  }
  let needle = scalar_text(args[0])
  let haystack = scalar_text(args[1])
  let start = optional_count(args, 2, 1.0)
  match (needle, haystack, start) {
    (VString(find_text), VString(within_text), VNumber(start_num)) =>
      find_text_position(find_text, within_text, start_num, true)
    (VError(err), _, _) | (_, VError(err), _) | (_, _, VError(err)) =>
      VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.SEARCH — find case-insensitive text with ? and * wildcards.
fn fn_search(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 && args.length() != 3 {
    return VError(Value)
  }
  let needle = scalar_text(args[0])
  let haystack = scalar_text(args[1])
  let start = optional_count(args, 2, 1.0)
  match (needle, haystack, start) {
    (VString(find_text), VString(within_text), VNumber(start_num)) =>
      search_text_position(find_text, within_text, start_num)
    (VError(err), _, _) | (_, VError(err), _) | (_, _, VError(err)) =>
      VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.SUBSTITUTE — replace all or the Nth occurrence of text.
fn fn_substitute(
  args : Array[FormulaValue],
  _ctx : EvalContext,
) -> FormulaValue {
  if args.length() != 3 && args.length() != 4 {
    return VError(Value)
  }
  let text = scalar_text(args[0])
  let old_text = scalar_text(args[1])
  let new_text = scalar_text(args[2])
  let occurrence = if args.length() == 4 {
    scalar_integer(args[3])
  } else {
    VEmpty
  }
  match (text, old_text, new_text, occurrence) {
    (VString(value), VString(old), VString(new), VEmpty) =>
      VString(text_substitute(value, old, new, 0))
    (VString(value), VString(old), VString(new), VNumber(instance)) =>
      if instance < 1.0 {
        VError(Value)
      } else {
        VString(text_substitute(value, old, new, instance.to_int()))
      }
    (VError(err), _, _, _)
    | (_, VError(err), _, _)
    | (_, _, VError(err), _)
    | (_, _, _, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.REPLACE — replace characters at a 1-based position.
fn fn_replace(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 4 {
    return VError(Value)
  }
  let text = scalar_text(args[0])
  let start = scalar_integer(args[1])
  let count = scalar_integer(args[2])
  let new_text = scalar_text(args[3])
  match (text, start, count, new_text) {
    (VString(value), VNumber(start_num), VNumber(num_chars), VString(new)) =>
      if start_num < 1.0 || num_chars < 0.0 {
        VError(Value)
      } else {
        VString(
          text_replace(value, start_num.to_int() - 1, num_chars.to_int(), new),
        )
      }
    (VError(err), _, _, _)
    | (_, VError(err), _, _)
    | (_, _, VError(err), _)
    | (_, _, _, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.REPT — repeat text a non-negative number of times.
fn fn_rept(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let text = scalar_text(args[0])
  let count = scalar_integer(args[1])
  match (text, count) {
    (VString(value), VNumber(times)) =>
      if times < 0.0 {
        VError(Value)
      } else {
        VString(text_repeat(value, times.to_int()))
      }
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.TEXT — format a number or date as text.
fn fn_text(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let format = scalar_text(args[1])
  match (args[0].first_scalar(), format) {
    (VError(err), _) | (_, VError(err)) => VError(err)
    (VNumber(value), VString(fmt)) =>
      VString(format_text_value(value, fmt, ctx))
    (value, VString(_)) => coerce_to_text(value)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.VALUE — parse text as a number.
fn fn_value(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  match one_text(args) {
    VString(text) => {
      let number : Double = try
        @strconv.from_str(text.trim().to_owned())
      catch {
        _ => return VError(Value)
      } noraise {
        parsed => parsed
      }
      if number.is_nan() || number.is_inf() {
        VError(Value)
      } else {
        VNumber(number)
      }
    }
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.EXACT — compare two text values case-sensitively.
fn fn_exact(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let left = scalar_text(args[0])
  let right = scalar_text(args[1])
  match (left, right) {
    (VString(a), VString(b)) => VBool(a == b)
    (VError(err), _) | (_, VError(err)) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.CHAR — return a single character for a codepoint.
fn fn_char(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match scalar_integer(args[0]) {
    VNumber(number) =>
      if number < 0.0 || number > 1114111.0 {
        VError(Value)
      } else {
        let out = StringBuilder::new()
        out.write_char(number.to_int().unsafe_to_char())
        VString(out.to_string())
      }
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.CODE — return the codepoint of the first character.
fn fn_code(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  match one_text(args) {
    VString(text) =>
      if text.length() == 0 {
        VError(Value)
      } else {
        VNumber(text.code_unit_at(0).to_int().to_double())
      }
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
fn one_text(args : Array[FormulaValue]) -> FormulaValue {
  if args.length() != 1 {
    VError(Value)
  } else {
    scalar_text(args[0])
  }
}

///|
fn scalar_text(value : FormulaValue) -> FormulaValue {
  coerce_to_text(value)
}

///|
fn scalar_integer(value : FormulaValue) -> FormulaValue {
  match coerce_to_number(value, @date_serial.DateSystem::Serial1900) {
    VNumber(number) => VNumber(number.trunc())
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
fn optional_count(
  args : Array[FormulaValue],
  index : Int,
  default : Double,
) -> FormulaValue {
  if args.length() <= index {
    VNumber(default)
  } else {
    scalar_integer(args[index])
  }
}

///|
fn append_text_value(
  out : StringBuilder,
  value : FormulaValue,
  allow_ranges : Bool,
) -> FormulaError? {
  match value {
    VArray(rows) =>
      if !allow_ranges && !is_singleton_array(rows) {
        Some(Value)
      } else {
        for row in rows {
          for item in row {
            match coerce_to_text(item) {
              VString(text) => out.write_string(text)
              VError(err) => return Some(err)
              _ => return Some(Value)
            }
          }
        }
        None
      }
    other =>
      match coerce_to_text(other) {
        VString(text) => {
          out.write_string(text)
          None
        }
        VError(err) => Some(err)
        _ => Some(Value)
      }
  }
}

///|
fn is_singleton_array(rows : Array[Array[FormulaValue]]) -> Bool {
  rows.length() == 1 && rows[0].length() == 1
}

///|
fn text_char_length(text : String) -> Int {
  let mut count = 0
  for _ch in text {
    count += 1
  }
  count
}

///|
fn text_left(text : String, count : Int) -> String {
  if count <= 0 {
    ""
  } else if count >= text.length() {
    text
  } else {
    text.unsafe_substring(start=0, end=count)
  }
}

///|
fn text_right(text : String, count : Int) -> String {
  if count <= 0 {
    ""
  } else if count >= text.length() {
    text
  } else {
    text.unsafe_substring(start=text.length() - count, end=text.length())
  }
}

///|
fn text_mid(text : String, start : Int, count : Int) -> String {
  if count <= 0 || start >= text.length() {
    ""
  } else {
    let safe_start = start.max(0)
    let end = (safe_start + count).min(text.length())
    text.unsafe_substring(start=safe_start, end~)
  }
}

///|
fn text_proper(text : String) -> String {
  let out = StringBuilder::new()
  let mut in_word = false
  for ch in text {
    if is_formula_letter(ch) {
      if in_word {
        out.write_char(
          ch.to_string().to_lower().code_unit_at(0).to_char().unwrap(),
        )
      } else {
        out.write_char(
          ch.to_string().to_upper().code_unit_at(0).to_char().unwrap(),
        )
        in_word = true
      }
    } else {
      out.write_char(ch)
      in_word = false
    }
  }
  out.to_string()
}

///|
fn text_trim_spaces(text : String) -> String {
  let out = StringBuilder::new()
  let mut pending_space = false
  let mut wrote = false
  for ch in text {
    if is_formula_space(ch) {
      if wrote {
        pending_space = true
      }
    } else {
      if pending_space {
        out.write_char(' ')
      }
      out.write_char(ch)
      pending_space = false
      wrote = true
    }
  }
  out.to_string()
}

///|
fn find_text_position(
  find_text : String,
  within_text : String,
  start_num : Double,
  case_sensitive : Bool,
) -> FormulaValue {
  if start_num < 1.0 || start_num > within_text.length().to_double() + 1.0 {
    return VError(Value)
  }
  let needle = if case_sensitive { find_text } else { find_text.to_upper() }
  let haystack = if case_sensitive {
    within_text
  } else {
    within_text.to_upper()
  }
  if needle.length() == 0 {
    return VNumber(start_num.trunc())
  }
  let start = start_num.trunc().to_int() - 1
  for pos in start..<=(haystack.length() - needle.length()) {
    if text_matches_at(haystack, needle, pos) {
      return VNumber((pos + 1).to_double())
    }
  }
  VError(Value)
}

///|
fn search_text_position(
  find_text : String,
  within_text : String,
  start_num : Double,
) -> FormulaValue {
  if start_num < 1.0 || start_num > within_text.length().to_double() + 1.0 {
    return VError(Value)
  }
  let pattern = find_text.to_upper()
  let haystack = within_text.to_upper()
  if pattern.length() == 0 {
    return VNumber(start_num.trunc())
  }
  let start = start_num.trunc().to_int() - 1
  for pos in start..<haystack.length() {
    if wildcard_match_at(pattern, haystack, 0, pos) {
      return VNumber((pos + 1).to_double())
    }
  }
  VError(Value)
}

///|
fn text_matches_at(haystack : String, needle : String, pos : Int) -> Bool {
  if pos + needle.length() > haystack.length() {
    return false
  }
  for i in 0..<needle.length() {
    if haystack.code_unit_at(pos + i) != needle.code_unit_at(i) {
      return false
    }
  }
  true
}

///|
fn wildcard_match_at(
  pattern : String,
  text : String,
  pi : Int,
  ti : Int,
) -> Bool {
  if pi == pattern.length() {
    return true
  }
  if pattern.code_unit_at(pi) == '*' {
    for next in ti..<=text.length() {
      if wildcard_match_at(pattern, text, pi + 1, next) {
        return true
      }
    }
    false
  } else if ti < text.length() &&
    (
      pattern.code_unit_at(pi) == '?' ||
      pattern.code_unit_at(pi) == text.code_unit_at(ti)
    ) {
    wildcard_match_at(pattern, text, pi + 1, ti + 1)
  } else {
    false
  }
}

///|
fn text_substitute(
  text : String,
  old_text : String,
  new_text : String,
  occurrence : Int,
) -> String {
  if old_text.length() == 0 {
    return text
  }
  let out = StringBuilder::new()
  let mut pos = 0
  let mut seen = 0
  while pos < text.length() {
    if text_matches_at(text, old_text, pos) {
      seen += 1
      if occurrence == 0 || occurrence == seen {
        out.write_string(new_text)
      } else {
        out.write_string(old_text)
      }
      pos += old_text.length()
    } else {
      out.write_char(text.code_unit_at(pos).to_char().unwrap())
      pos += 1
    }
  }
  out.to_string()
}

///|
fn text_replace(
  text : String,
  start : Int,
  count : Int,
  new_text : String,
) -> String {
  let safe_start = start.min(text.length()).max(0)
  let safe_end = (safe_start + count).min(text.length())
  text.unsafe_substring(start=0, end=safe_start) +
  new_text +
  text.unsafe_substring(start=safe_end, end=text.length())
}

///|
fn text_repeat(text : String, times : Int) -> String {
  let out = StringBuilder::new()
  for _i in 0..<times {
    out.write_string(text)
  }
  out.to_string()
}

///|
fn format_text_value(
  value : Double,
  format : String,
  ctx : EvalContext,
) -> String {
  match format {
    "0" => format_integer(round_unit(value, HalfAway).to_int())
    "0.00" => format_fixed2(value)
    "#,##0" => format_thousands(round_unit(value, HalfAway).to_int())
    "0%" => format_integer(round_unit(value * 100.0, HalfAway).to_int()) + "%"
    "yyyy-mm-dd" => format_serial_date(value, ctx.date_system)
    _ => value.to_string()
  }
}

///|
fn format_integer(value : Int) -> String {
  value.to_string()
}

///|
fn format_fixed2(value : Double) -> String {
  let scaled = round_unit(value * 100.0, HalfAway).to_int()
  let sign = if scaled < 0 { "-" } else { "" }
  let abs_scaled = scaled.abs()
  sign + (abs_scaled / 100).to_string() + "." + pad2(abs_scaled % 100)
}

///|
fn format_thousands(value : Int) -> String {
  let sign = if value < 0 { "-" } else { "" }
  let digits = value.abs().to_string()
  let out = StringBuilder::new()
  for i in 0..<digits.length() {
    if i > 0 && (digits.length() - i) % 3 == 0 {
      out.write_char(',')
    }
    out.write_char(digits.code_unit_at(i).to_char().unwrap())
  }
  sign + out.to_string()
}

///|
fn format_serial_date(
  value : Double,
  system : @date_serial.DateSystem,
) -> String {
  let dt : @date_serial.CalendarDateTime? = Some(
    @date_serial.serial_to_date_time(value, system),
  ) catch {
    _ => None
  }
  match dt {
    Some(date) =>
      pad4(date.year) + "-" + pad2(date.month) + "-" + pad2(date.day)
    None => value.to_string()
  }
}

///|
fn pad2(value : Int) -> String {
  if value < 10 {
    "0" + value.to_string()
  } else {
    value.to_string()
  }
}

///|
fn pad4(value : Int) -> String {
  if value < 10 {
    "000" + value.to_string()
  } else if value < 100 {
    "00" + value.to_string()
  } else if value < 1000 {
    "0" + value.to_string()
  } else {
    value.to_string()
  }
}

///|
fn is_formula_letter(ch : Char) -> Bool {
  (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z')
}

///|
fn is_formula_space(ch : Char) -> Bool {
  ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r'
}
