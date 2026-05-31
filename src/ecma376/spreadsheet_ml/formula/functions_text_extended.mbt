///|
fn register_builtin_text_extended_functions(
  registry : FunctionRegistry,
) -> Unit {
  registry.register("CLEAN", Eager(fn_clean))
  registry.register("DOLLAR", Eager(fn_dollar))
  registry.register("USDOLLAR", Eager(fn_dollar))
  registry.register("FIXED", Eager(fn_fixed))
  registry.register("ASC", Eager(fn_asc))
  registry.register("JIS", Eager(fn_jis))
  registry.register("PHONETIC", Eager(fn_phonetic))
  registry.register("BAHTTEXT", Eager(fn_bahttext))
  registry.register("FINDB", Eager(fn_findb))
  registry.register("LEFTB", Eager(fn_leftb))
  registry.register("LENB", Eager(fn_lenb))
  registry.register("MIDB", Eager(fn_midb))
  registry.register("REPLACEB", Eager(fn_replaceb))
  registry.register("RIGHTB", Eager(fn_rightb))
  registry.register("SEARCHB", Eager(fn_searchb))
}

///|
fn fn_clean(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VString(s) => {
      let buf = StringBuilder::new()
      for ch in s {
        if ch.to_int() >= 32 {
          buf.write_char(ch)
        }
      }
      VString(buf.to_string())
    }
    VError(e) => VError(e)
    _ => VString("")
  }
}

///|
fn fn_dollar(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 {
    return VError(Value)
  }
  let num = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let decimals = if args.length() == 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n.trunc().to_int()
      _ => return VError(Value)
    }
  } else {
    2
  }
  let factor = @math.pow(10.0, decimals.to_double())
  let rounded = (num.abs() * factor + 0.5).floor() / factor
  let formatted = format_fixed_dec(rounded, decimals)
  let sign = if num < 0.0 { "($" } else { "$" }
  let close = if num < 0.0 { ")" } else { "" }
  VString(sign + formatted + close)
}

///|
fn fn_fixed(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 3 {
    return VError(Value)
  }
  let num = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let decimals = if args.length() >= 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n.trunc().to_int()
      _ => return VError(Value)
    }
  } else {
    2
  }
  let factor = @math.pow(10.0, decimals.to_double())
  let rounded = (num.abs() * factor + 0.5).floor() / factor
  let formatted = format_fixed_dec(rounded, decimals)
  let sign = if num < 0.0 { "-" } else { "" }
  VString(sign + formatted)
}

///|
fn format_fixed_dec(num : Double, decimals : Int) -> String {
  if decimals <= 0 {
    return num.trunc().to_int().to_string()
  }
  let int_part = num.trunc().to_int()
  let frac = num - int_part.to_double()
  let frac_scaled = (frac * @math.pow(10.0, decimals.to_double()) + 0.5)
    .floor()
    .to_int()
  let frac_str = frac_scaled.to_string()
  let pad = StringBuilder::new()
  for _i in 0..<(decimals - frac_str.length()) {
    pad.write_char('0')
  }
  int_part.to_string() + "." + pad.to_string() + frac_str
}

///|
fn fn_asc(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VString(s) => {
      let buf = StringBuilder::new()
      for ch in s {
        let c = ch.to_int()
        if c >= 0xFF01 && c <= 0xFF5E {
          buf.write_char(Char::from_int(c - 0xFF01 + 0x21))
        } else if c == 0x3000 {
          buf.write_char(' ')
        } else {
          buf.write_char(ch)
        }
      }
      VString(buf.to_string())
    }
    VError(e) => VError(e)
    _ => VString("")
  }
}

///|
fn fn_jis(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VString(s) => {
      let buf = StringBuilder::new()
      for ch in s {
        let c = ch.to_int()
        if c >= 0x21 && c <= 0x7E {
          buf.write_char(Char::from_int(c - 0x21 + 0xFF01))
        } else if c == 0x20 {
          buf.write_char(Char::from_int(0x3000))
        } else {
          buf.write_char(ch)
        }
      }
      VString(buf.to_string())
    }
    VError(e) => VError(e)
    _ => VString("")
  }
}

///|
fn fn_phonetic(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VString(s) => VString(s)
    VError(e) => VError(e)
    _ => VString("")
  }
}

///|
fn fn_bahttext(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => VString(n.to_string() + " Baht")
    other => other
  }
}

///|
fn char_byte_len(ch : Char) -> Int {
  let c = ch.to_int()
  if c < 0x80 {
    1
  } else if c < 0x800 {
    2
  } else if c < 0x10000 {
    3
  } else {
    4
  }
}

///|
fn fn_lenb(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match coerce_to_text(args[0].first_scalar()) {
    VString(s) => {
      let mut count = 0
      for ch in s {
        count = count + char_byte_len(ch)
      }
      VNumber(count.to_double())
    }
    other => other
  }
}

///|
fn fn_leftb(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 {
    return VError(Value)
  }
  let s = match coerce_to_text(args[0].first_scalar()) {
    VString(s) => s
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let nb = if args.length() == 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n.trunc().to_int()
      _ => return VError(Value)
    }
  } else {
    1
  }
  if nb < 0 {
    return VError(Value)
  }
  let mut bytes = 0
  let mut chars = 0
  for ch in s {
    let cb = char_byte_len(ch)
    if bytes + cb > nb {
      break
    }
    bytes = bytes + cb
    chars = chars + 1
  }
  VString(s.unsafe_substring(start=0, end=chars))
}

///|
fn fn_rightb(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 {
    return VError(Value)
  }
  let s = match coerce_to_text(args[0].first_scalar()) {
    VString(s) => s
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let nb = if args.length() == 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n.trunc().to_int()
      _ => return VError(Value)
    }
  } else {
    1
  }
  if nb < 0 {
    return VError(Value)
  }
  let char_bytes : Array[(Char, Int)] = []
  for ch in s {
    char_bytes.push((ch, char_byte_len(ch)))
  }
  let mut bytes = 0
  let mut start = char_bytes.length()
  while start > 0 {
    start = start - 1
    let (_, cb) = char_bytes[start]
    if bytes + cb > nb {
      start = start + 1
      break
    }
    bytes = bytes + cb
  }
  VString(s.unsafe_substring(start~, end=s.length()))
}

///|
fn fn_midb(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 {
    return VError(Value)
  }
  let s = match coerce_to_text(args[0].first_scalar()) {
    VString(s) => s
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let start_byte = match
    coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc().to_int()
    _ => return VError(Value)
  }
  let num_bytes = match
    coerce_to_number(args[2].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc().to_int()
    _ => return VError(Value)
  }
  if start_byte < 1 || num_bytes < 0 {
    return VError(Value)
  }
  let mut bytes = 0
  let mut start_char = 0
  let mut found_start = false
  let mut end_char = 0
  let mut end_bytes = 0
  let mut idx = 0
  for ch in s {
    let cb = char_byte_len(ch)
    if !found_start {
      if bytes >= start_byte - 1 {
        start_char = idx
        found_start = true
      }
      bytes = bytes + cb
      if !found_start {
        idx = idx + 1
        continue
      }
    }
    if found_start {
      if end_bytes + cb > num_bytes {
        break
      }
      end_bytes = end_bytes + cb
      end_char = idx + 1
    }
    idx = idx + 1
  }
  if !found_start {
    start_char = s.length()
  }
  VString(s.unsafe_substring(start=start_char, end=end_char.min(s.length())))
}

///|
fn fn_findb(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 2 || args.length() > 3 {
    return VError(Value)
  }
  let find_text = match coerce_to_text(args[0].first_scalar()) {
    VString(s) => s
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let within_text = match coerce_to_text(args[1].first_scalar()) {
    VString(s) => s
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let _ = ctx
  match within_text.find(find_text) {
    Some(idx) => {
      let mut byte_pos = 1
      let mut ci = 0
      for ch in within_text {
        if ci >= idx {
          break
        }
        byte_pos = byte_pos + char_byte_len(ch)
        ci = ci + 1
      }
      VNumber(byte_pos.to_double())
    }
    None => VError(Value)
  }
}

///|
fn fn_replaceb(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 4 {
    return VError(Value)
  }
  let old_text = match coerce_to_text(args[0].first_scalar()) {
    VString(s) => s
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let start_byte = match
    coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc().to_int()
    _ => return VError(Value)
  }
  let num_bytes = match
    coerce_to_number(args[2].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc().to_int()
    _ => return VError(Value)
  }
  let new_text = match coerce_to_text(args[3].first_scalar()) {
    VString(s) => s
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  if start_byte < 1 || num_bytes < 0 {
    return VError(Value)
  }
  let mut bytes = 0
  let mut start_char = 0
  let mut found_start = false
  let mut end_char = 0
  let mut end_bytes = 0
  let mut idx = 0
  for ch in old_text {
    let cb = char_byte_len(ch)
    if !found_start {
      if bytes >= start_byte - 1 {
        start_char = idx
        found_start = true
      }
      if !found_start {
        bytes = bytes + cb
        idx = idx + 1
        continue
      }
    }
    if found_start {
      if end_bytes >= num_bytes {
        break
      }
      end_bytes = end_bytes + cb
      end_char = idx + 1
    }
    idx = idx + 1
  }
  if !found_start {
    start_char = old_text.length()
  }
  let before = old_text.unsafe_substring(start=0, end=start_char)
  let after = old_text.unsafe_substring(
    start=end_char.min(old_text.length()),
    end=old_text.length(),
  )
  VString(before + new_text + after)
}

///|
fn fn_searchb(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  fn_findb(args, ctx)
}
