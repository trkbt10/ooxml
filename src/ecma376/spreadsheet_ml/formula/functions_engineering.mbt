///|
fn register_builtin_engineering_functions(
  registry : FunctionRegistry,
) -> Unit {
  registry.register("DELTA", Eager(fn_delta))
  registry.register("GESTEP", Eager(fn_gestep))
  registry.register("ERF", Eager(fn_erf))
  registry.register("ERFC", Eager(fn_erfc))
  registry.register("BIN2DEC", Eager(fn_bin2dec))
  registry.register("BIN2HEX", Eager(fn_bin2hex))
  registry.register("BIN2OCT", Eager(fn_bin2oct))
  registry.register("DEC2BIN", Eager(fn_dec2bin))
  registry.register("DEC2HEX", Eager(fn_dec2hex))
  registry.register("DEC2OCT", Eager(fn_dec2oct))
  registry.register("HEX2BIN", Eager(fn_hex2bin))
  registry.register("HEX2DEC", Eager(fn_hex2dec))
  registry.register("HEX2OCT", Eager(fn_hex2oct))
  registry.register("OCT2BIN", Eager(fn_oct2bin))
  registry.register("OCT2DEC", Eager(fn_oct2dec))
  registry.register("OCT2HEX", Eager(fn_oct2hex))
  registry.register("COMPLEX", Eager(fn_complex))
  registry.register("IMABS", Eager(fn_imabs))
  registry.register("IMAGINARY", Eager(fn_imaginary))
  registry.register("IMREAL", Eager(fn_imreal))
  registry.register("IMARGUMENT", Eager(fn_imargument))
  registry.register("IMCONJUGATE", Eager(fn_imconjugate))
  registry.register("IMCOS", Eager(fn_imcos))
  registry.register("IMSIN", Eager(fn_imsin))
  registry.register("IMDIV", Eager(fn_imdiv))
  registry.register("IMEXP", Eager(fn_imexp))
  registry.register("IMLN", Eager(fn_imln))
  registry.register("IMLOG10", Eager(fn_imlog10))
  registry.register("IMLOG2", Eager(fn_imlog2))
  registry.register("IMPOWER", Eager(fn_impower))
  registry.register("IMPRODUCT", Eager(fn_improduct))
  registry.register("IMSQRT", Eager(fn_imsqrt))
  registry.register("IMSUB", Eager(fn_imsub))
  registry.register("IMSUM", Eager(fn_imsum))
  registry.register("CONVERT", Eager(fn_convert))
  registry.register("BESSELI", Eager(fn_besseli))
  registry.register("BESSELJ", Eager(fn_besselj))
  registry.register("BESSELK", Eager(fn_besselk))
  registry.register("BESSELY", Eager(fn_bessely))
}

fn fn_delta(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 { return VError(Value) }
  let a = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let b = if args.length() == 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n
      VError(e) => return VError(e)
      _ => return VError(Value)
    }
  } else {
    0.0
  }
  VNumber(if a == b { 1.0 } else { 0.0 })
}

fn fn_gestep(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 { return VError(Value) }
  let n = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let step = if args.length() == 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n
      VError(e) => return VError(e)
      _ => return VError(Value)
    }
  } else {
    0.0
  }
  VNumber(if n >= step { 1.0 } else { 0.0 })
}

fn fn_erf(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 { return VError(Value) }
  let lo = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  if args.length() == 2 {
    let hi = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n
      VError(e) => return VError(e)
      _ => return VError(Value)
    }
    VNumber(erf_raw(hi) - erf_raw(lo))
  } else {
    VNumber(erf_raw(lo))
  }
}

fn fn_erfc(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match one_number(args, ctx) {
    VNumber(n) => VNumber(erfc_raw(n))
    other => other
  }
}

// ---------------------------------------------------------------------------
// Base conversion: 10-digit two's complement for negative numbers
// ---------------------------------------------------------------------------

fn parse_base_string(s : String, base : Int) -> Int64? {
  let mut result : Int64 = 0L
  for i in 0..<s.length() {
    let c = s[i].to_int()
    let d = if c >= 48 && c <= 57 {
      c - 48
    } else if c >= 65 && c <= 70 {
      c - 55
    } else if c >= 97 && c <= 102 {
      c - 87
    } else {
      return None
    }
    if d >= base { return None }
    result = result * base.to_int64() + d.to_int64()
  }
  Some(result)
}

fn to_base_string(val : Int64, base : Int, places : Int) -> String {
  let digit_chars : FixedArray[Char] = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D',
    'E', 'F',
  ]
  if val == 0L {
    let buf = StringBuilder::new()
    let p = if places > 1 { places } else { 1 }
    for _i in 0..<p { buf.write_char('0') }
    return buf.to_string()
  }
  let mut n = if val < 0L {
    match base {
      2 => val + 1024L
      8 => val + 0x40000000L
      16 => val + 0x10000000000L
      _ => val
    }
  } else {
    val
  }
  let chars : Array[Char] = []
  while n > 0L {
    let d = (n % base.to_int64()).to_int()
    chars.push(digit_chars[d])
    n = n / base.to_int64()
  }
  let rev = StringBuilder::new()
  let pad = if places > chars.length() { places - chars.length() } else { 0 }
  for _i in 0..<pad { rev.write_char('0') }
  for i in 0..<chars.length() {
    rev.write_char(chars[chars.length() - 1 - i])
  }
  rev.to_string()
}

fn base_conv(
  args : Array[FormulaValue],
  ctx : EvalContext,
  from_base : Int,
  to_base : Int,
  max_digits : Int,
) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 { return VError(Value) }
  let s = match coerce_to_text(args[0].first_scalar()) {
    VString(s) => s
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let places = if args.length() == 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n.trunc().to_int()
      _ => return VError(Value)
    }
  } else {
    0
  }
  match parse_base_string(s, from_base) {
    None => VError(Num)
    Some(val) => {
      let mut v = val
      if from_base == 2 && s.length() == 10 && s[0] == '1' {
        v = val - 1024L
      } else if from_base == 8 && s.length() == 10 && s[0].to_int() >= 52 {
        v = val - 0x40000000L
      } else if from_base == 16 && s.length() == 10 && s[0].to_int() >= 56 {
        v = val - 0x10000000000L
      }
      if to_base == 10 {
        VNumber(v.to_double())
      } else {
        let _ = max_digits
        VString(to_base_string(v, to_base, places))
      }
    }
  }
}

fn fn_bin2dec(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  base_conv(args, ctx, 2, 10, 10)
}

fn fn_bin2hex(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  base_conv(args, ctx, 2, 16, 10)
}

fn fn_bin2oct(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  base_conv(args, ctx, 2, 8, 10)
}

fn fn_dec2bin(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 { return VError(Value) }
  let n = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc().to_int64()
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  if n < -512L || n > 511L { return VError(Num) }
  let places = if args.length() == 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n.trunc().to_int()
      _ => return VError(Value)
    }
  } else {
    0
  }
  VString(to_base_string(n, 2, places))
}

fn fn_dec2hex(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 { return VError(Value) }
  let n = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc().to_int64()
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let places = if args.length() == 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n.trunc().to_int()
      _ => return VError(Value)
    }
  } else {
    0
  }
  VString(to_base_string(n, 16, places))
}

fn fn_dec2oct(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 1 || args.length() > 2 { return VError(Value) }
  let n = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n.trunc().to_int64()
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let places = if args.length() == 2 {
    match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
      VNumber(n) => n.trunc().to_int()
      _ => return VError(Value)
    }
  } else {
    0
  }
  VString(to_base_string(n, 8, places))
}

fn fn_hex2bin(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  base_conv(args, ctx, 16, 2, 10)
}

fn fn_hex2dec(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  base_conv(args, ctx, 16, 10, 10)
}

fn fn_hex2oct(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  base_conv(args, ctx, 16, 8, 10)
}

fn fn_oct2bin(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  base_conv(args, ctx, 8, 2, 10)
}

fn fn_oct2dec(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  base_conv(args, ctx, 8, 10, 10)
}

fn fn_oct2hex(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  base_conv(args, ctx, 8, 16, 10)
}

// ---------------------------------------------------------------------------
// Complex number functions — "a+bi" string encoding
// ---------------------------------------------------------------------------

fn parse_complex(s : String) -> (Double, Double)? {
  if s == "" { return Some((0.0, 0.0)) }
  let last = s[s.length() - 1]
  if last != 'i' && last != 'j' {
    match (try? @strconv.parse_double(s)) {
      Ok(n) => return Some((n, 0.0))
      Err(_) => return None
    }
  }
  let body = s.substring(start=0, end=s.length() - 1)
  if body == "" || body == "+" { return Some((0.0, 1.0)) }
  if body == "-" { return Some((0.0, -1.0)) }
  let mut split_pos = -1
  for i in 1..<body.length() {
    if (body[i] == '+' || body[i] == '-') && split_pos < 0 {
      split_pos = i
    }
  }
  if split_pos < 0 {
    match (try? @strconv.parse_double(body)) {
      Ok(n) => Some((0.0, n))
      Err(_) => None
    }
  } else {
    let re_str = body.substring(start=0, end=split_pos)
    let im_str = body.substring(start=split_pos)
    match ((try? @strconv.parse_double(re_str)), (try? @strconv.parse_double(
      if im_str == "+" { "1" } else if im_str == "-" { "-1" } else { im_str },
    ))) {
      (Ok(re), Ok(im)) => Some((re, im))
      _ => None
    }
  }
}

fn format_complex(re : Double, im : Double) -> String {
  if im == 0.0 { return re.to_string() }
  let re_part = if re == 0.0 { "" } else { re.to_string() }
  let sign = if im > 0.0 && re != 0.0 { "+" } else if im < 0.0 {
    "-"
  } else {
    ""
  }
  let im_part = if im.abs() == 1.0 { "" } else { im.abs().to_string() }
  re_part + sign + im_part + "i"
}

fn fn_complex(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() < 2 || args.length() > 3 { return VError(Value) }
  let re = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  let im = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  VString(format_complex(re, im))
}

fn fn_imabs(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, im)) => VNumber((re * re + im * im).sqrt())
        None => VError(Num)
      }
    _ => VError(Value)
  }
}

fn fn_imaginary(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((_, im)) => VNumber(im)
        None => VError(Num)
      }
    VNumber(_) => VNumber(0.0)
    _ => VError(Value)
  }
}

fn fn_imreal(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, _)) => VNumber(re)
        None => VError(Num)
      }
    VNumber(n) => VNumber(n)
    _ => VError(Value)
  }
}

fn fn_imargument(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, im)) =>
          if re == 0.0 && im == 0.0 { VError(DivZero) } else {
            VNumber(atan2_raw(im, re))
          }
        None => VError(Num)
      }
    _ => VError(Value)
  }
}

fn fn_imconjugate(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, im)) => VString(format_complex(re, -im))
        None => VError(Num)
      }
    _ => VError(Value)
  }
}

fn fn_imcos(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, im)) => {
          let rr = cos_raw(re) * (@math.exp(im) + @math.exp(-im)) / 2.0
          let ri = -sin_raw(re) * (@math.exp(im) - @math.exp(-im)) / 2.0
          VString(format_complex(rr, ri))
        }
        None => VError(Num)
      }
    _ => VError(Value)
  }
}

fn fn_imsin(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, im)) => {
          let rr = sin_raw(re) * (@math.exp(im) + @math.exp(-im)) / 2.0
          let ri = cos_raw(re) * (@math.exp(im) - @math.exp(-im)) / 2.0
          VString(format_complex(rr, ri))
        }
        None => VError(Num)
      }
    _ => VError(Value)
  }
}

fn fn_imdiv(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 { return VError(Value) }
  let a = match args[0].first_scalar() {
    VString(s) => match parse_complex(s) { Some(c) => c; None => return VError(Num) }
    _ => return VError(Value)
  }
  let b = match args[1].first_scalar() {
    VString(s) => match parse_complex(s) { Some(c) => c; None => return VError(Num) }
    _ => return VError(Value)
  }
  let denom = b.0 * b.0 + b.1 * b.1
  if denom == 0.0 { return VError(Num) }
  VString(format_complex(
    (a.0 * b.0 + a.1 * b.1) / denom,
    (a.1 * b.0 - a.0 * b.1) / denom,
  ))
}

fn fn_imexp(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, im)) => {
          let r = @math.exp(re)
          VString(format_complex(r * cos_raw(im), r * sin_raw(im)))
        }
        None => VError(Num)
      }
    _ => VError(Value)
  }
}

fn fn_imln(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, im)) => {
          let r = (re * re + im * im).sqrt()
          if r == 0.0 { return VError(Num) }
          VString(format_complex(@math.ln(r), atan2_raw(im, re)))
        }
        None => VError(Num)
      }
    _ => VError(Value)
  }
}

fn fn_imlog10(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, im)) => {
          let r = (re * re + im * im).sqrt()
          if r == 0.0 { return VError(Num) }
          let ln10 = @math.ln(10.0)
          VString(format_complex(@math.ln(r) / ln10, atan2_raw(im, re) / ln10))
        }
        None => VError(Num)
      }
    _ => VError(Value)
  }
}

fn fn_imlog2(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, im)) => {
          let r = (re * re + im * im).sqrt()
          if r == 0.0 { return VError(Num) }
          let ln2 = @math.ln(2.0)
          VString(format_complex(@math.ln(r) / ln2, atan2_raw(im, re) / ln2))
        }
        None => VError(Num)
      }
    _ => VError(Value)
  }
}

fn fn_impower(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 { return VError(Value) }
  let c = match args[0].first_scalar() {
    VString(s) => match parse_complex(s) { Some(c) => c; None => return VError(Num) }
    _ => return VError(Value)
  }
  let n = match coerce_to_number(args[1].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    _ => return VError(Value)
  }
  let r = (c.0 * c.0 + c.1 * c.1).sqrt()
  if r == 0.0 { return VString(format_complex(0.0, 0.0)) }
  let theta = atan2_raw(c.1, c.0)
  let rn = @math.pow(r, n)
  VString(format_complex(rn * cos_raw(n * theta), rn * sin_raw(n * theta)))
}

fn fn_improduct(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  let mut re = 1.0
  let mut im = 0.0
  for arg in args {
    let c = match arg.first_scalar() {
      VString(s) => match parse_complex(s) { Some(c) => c; None => return VError(Num) }
      VNumber(n) => (n, 0.0)
      _ => return VError(Value)
    }
    let new_re = re * c.0 - im * c.1
    let new_im = re * c.1 + im * c.0
    re = new_re
    im = new_im
  }
  VString(format_complex(re, im))
}

fn fn_imsqrt(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 { return VError(Value) }
  match args[0].first_scalar() {
    VString(s) =>
      match parse_complex(s) {
        Some((re, im)) => {
          let r = (re * re + im * im).sqrt()
          let sqrt_r = r.sqrt()
          let theta = atan2_raw(im, re) / 2.0
          VString(format_complex(sqrt_r * cos_raw(theta), sqrt_r * sin_raw(theta)))
        }
        None => VError(Num)
      }
    _ => VError(Value)
  }
}

fn fn_imsub(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 { return VError(Value) }
  let a = match args[0].first_scalar() {
    VString(s) => match parse_complex(s) { Some(c) => c; None => return VError(Num) }
    VNumber(n) => (n, 0.0)
    _ => return VError(Value)
  }
  let b = match args[1].first_scalar() {
    VString(s) => match parse_complex(s) { Some(c) => c; None => return VError(Num) }
    VNumber(n) => (n, 0.0)
    _ => return VError(Value)
  }
  VString(format_complex(a.0 - b.0, a.1 - b.1))
}

fn fn_imsum(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  let mut re = 0.0
  let mut im = 0.0
  for arg in args {
    let c = match arg.first_scalar() {
      VString(s) => match parse_complex(s) { Some(c) => c; None => return VError(Num) }
      VNumber(n) => (n, 0.0)
      _ => return VError(Value)
    }
    re = re + c.0
    im = im + c.1
  }
  VString(format_complex(re, im))
}

fn fn_convert(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  if args.length() != 3 { return VError(Value) }
  let num = match coerce_to_number(args[0].first_scalar(), ctx.date_system) {
    VNumber(n) => n
    VError(e) => return VError(e)
    _ => return VError(Value)
  }
  let from = match coerce_to_text(args[1].first_scalar()) {
    VString(s) => s
    _ => return VError(Value)
  }
  let to = match coerce_to_text(args[2].first_scalar()) {
    VString(s) => s
    _ => return VError(Value)
  }
  match convert_unit(num, from, to) {
    Some(result) => VNumber(result)
    None => VError(NotApplicable)
  }
}

fn convert_unit(num : Double, from : String, to : String) -> Double? {
  let from_si = match unit_to_si(from) {
    Some(v) => v
    None => return None
  }
  let to_si = match unit_to_si(to) {
    Some(v) => v
    None => return None
  }
  let (from_factor, from_dim) = from_si
  let (to_factor, to_dim) = to_si
  if from_dim != to_dim { return None }
  Some(num * from_factor / to_factor)
}

fn unit_to_si(unit : String) -> (Double, String)? {
  match unit {
    "m" => Some((1.0, "m"))
    "mi" => Some((1609.344, "m"))
    "Nmi" => Some((1852.0, "m"))
    "in" => Some((0.0254, "m"))
    "ft" => Some((0.3048, "m"))
    "yd" => Some((0.9144, "m"))
    "ang" => Some((1.0e-10, "m"))
    "Pica" | "pica" => Some((0.00423333333, "m"))
    "cm" => Some((0.01, "m"))
    "mm" => Some((0.001, "m"))
    "km" => Some((1000.0, "m"))
    "g" => Some((0.001, "kg"))
    "kg" => Some((1.0, "kg"))
    "mg" => Some((1.0e-6, "kg"))
    "lbm" => Some((0.45359237, "kg"))
    "ozm" => Some((0.028349523125, "kg"))
    "sg" => Some((14.593903, "kg"))
    "ton" => Some((907.18474, "kg"))
    "s" | "sec" => Some((1.0, "s"))
    "mn" | "min" => Some((60.0, "s"))
    "hr" => Some((3600.0, "s"))
    "day" => Some((86400.0, "s"))
    "yr" => Some((31557600.0, "s"))
    "C" | "cel" => Some((1.0, "C"))
    "F" | "fah" => Some((1.0, "F"))
    "K" | "kel" => Some((1.0, "K"))
    "Pa" | "p" => Some((1.0, "Pa"))
    "atm" | "at" => Some((101325.0, "Pa"))
    "mmHg" => Some((133.322, "Pa"))
    "psi" => Some((6894.757, "Pa"))
    "N" => Some((1.0, "N"))
    "dyn" | "dy" => Some((1.0e-5, "N"))
    "lbf" => Some((4.4482216152605, "N"))
    "J" => Some((1.0, "J"))
    "cal" => Some((4.1868, "J"))
    "eV" | "ev" => Some((1.602176634e-19, "J"))
    "BTU" | "btu" => Some((1055.06, "J"))
    "W" | "w" => Some((1.0, "W"))
    "HP" | "hp" => Some((745.69987158227022, "W"))
    "l" | "L" | "lt" => Some((0.001, "m3"))
    "gal" => Some((0.003785411784, "m3"))
    "qt" => Some((0.000946352946, "m3"))
    "pt" => Some((0.000473176473, "m3"))
    "cup" => Some((0.000236588236, "m3"))
    "oz" => Some((2.95735295625e-5, "m3"))
    "tbs" => Some((1.47867647813e-5, "m3"))
    "tsp" => Some((4.92892159375e-6, "m3"))
    "m3" | "m^3" => Some((1.0, "m3"))
    "bit" => Some((1.0, "bit"))
    "byte" => Some((8.0, "bit"))
    _ => None
  }
}

// ---------------------------------------------------------------------------
// Bessel functions — series expansion
// ---------------------------------------------------------------------------

fn fn_besseli(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 2) {
    None => VError(Value)
    Some(ns) => {
      let (x, n) = (ns[0], ns[1].trunc().to_int())
      if n < 0 { return VError(Num) }
      checked_number(bessel_i(x, n))
    }
  }
}

fn fn_besselj(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 2) {
    None => VError(Value)
    Some(ns) => {
      let (x, n) = (ns[0], ns[1].trunc().to_int())
      if n < 0 { return VError(Num) }
      checked_number(bessel_j(x, n))
    }
  }
}

fn fn_besselk(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 2) {
    None => VError(Value)
    Some(ns) => {
      let (x, n) = (ns[0], ns[1].trunc().to_int())
      if n < 0 || x <= 0.0 { return VError(Num) }
      checked_number(bessel_k(x, n))
    }
  }
}

fn fn_bessely(args : Array[FormulaValue], ctx : EvalContext) -> FormulaValue {
  match stat_dist_numbers(args, ctx, 2) {
    None => VError(Value)
    Some(ns) => {
      let (x, n) = (ns[0], ns[1].trunc().to_int())
      if n < 0 || x <= 0.0 { return VError(Num) }
      checked_number(bessel_y(x, n))
    }
  }
}

fn bessel_j(x : Double, n : Int) -> Double {
  let mut sum = 0.0
  let mut term = 1.0 / gamma_func((n + 1).to_double())
  sum = term * @math.pow(x / 2.0, n.to_double())
  for m in 1..=50 {
    term = -term * (x / 2.0) * (x / 2.0) / (m.to_double() * (n + m).to_double())
    sum = sum + term
    if term.abs() < sum.abs() * 1.0e-15 { break }
  }
  sum
}

fn bessel_i(x : Double, n : Int) -> Double {
  let mut sum = 0.0
  let mut term = 1.0 / gamma_func((n + 1).to_double())
  sum = term * @math.pow(x / 2.0, n.to_double())
  for m in 1..=50 {
    term = term * (x / 2.0) * (x / 2.0) / (m.to_double() * (n + m).to_double())
    sum = sum + term
    if term.abs() < sum.abs() * 1.0e-15 { break }
  }
  sum
}

fn bessel_y(x : Double, n : Int) -> Double {
  if n == 0 {
    2.0 / trig_pi * ((@math.ln(x / 2.0) + 0.5772156649) * bessel_j(x, 0) + bessel_y0_series(x))
  } else if n == 1 {
    2.0 / trig_pi * ((@math.ln(x / 2.0) + 0.5772156649) * bessel_j(x, 1) + bessel_y1_correction(x))
  } else {
    let y0 = bessel_y(x, 0)
    let y1 = bessel_y(x, 1)
    let mut ym1 = y0
    let mut y_curr = y1
    for k in 1..<n {
      let y_next = 2.0 * k.to_double() / x * y_curr - ym1
      ym1 = y_curr
      y_curr = y_next
    }
    y_curr
  }
}

fn bessel_y0_series(x : Double) -> Double {
  let mut sum = 0.0
  let mut sign = -1.0
  let mut h = 0.0
  for k in 1..=30 {
    h = h + 1.0 / k.to_double()
    sign = -sign
    let term = sign * h * @math.pow(x / 2.0, (2 * k).to_double()) / gamma_func((k + 1).to_double()) / gamma_func((k + 1).to_double())
    sum = sum + term
    if term.abs() < 1.0e-15 { break }
  }
  sum
}

fn bessel_y1_correction(x : Double) -> Double {
  -1.0 / x + bessel_y0_series(x) * 0.5
}

fn bessel_k(x : Double, n : Int) -> Double {
  let k0 = -(@math.ln(x / 2.0) + 0.5772156649) * bessel_i(x, 0)
  if n == 0 { return k0 }
  let k1 = 1.0 / x + @math.ln(x / 2.0) * bessel_i(x, 1)
  if n == 1 { return k1 }
  let mut km1 = k0
  let mut k_curr = k1
  for k in 1..<n {
    let k_next = 2.0 * k.to_double() / x * k_curr + km1
    km1 = k_curr
    k_curr = k_next
  }
  k_curr
}
