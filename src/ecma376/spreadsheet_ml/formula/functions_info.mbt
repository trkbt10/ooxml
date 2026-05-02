///|
fn register_builtin_info_functions(registry : FunctionRegistry) -> Unit {
  registry.register("ISBLANK", Eager(fn_isblank))
  registry.register("ISNUMBER", Eager(fn_isnumber))
  registry.register("ISTEXT", Eager(fn_istext))
  registry.register("ISLOGICAL", Eager(fn_islogical))
  registry.register("ISERROR", Eager(fn_iserror))
  registry.register("ISNA", Eager(fn_isna))
  registry.register("ISERR", Eager(fn_iserr))
  registry.register("TYPE", Eager(fn_type))
  registry.register("NA", Eager(fn_na))
  registry.register("N", Eager(fn_n))
  registry.register("T", Eager(fn_t))
}

///|
/// §18.17.7.ISBLANK — test whether a value is empty.
fn fn_isblank(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VEmpty => VBool(true)
    _ => VBool(false)
  }
}

///|
/// §18.17.7.ISNUMBER — test whether a value is numeric.
fn fn_isnumber(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VNumber(_) => VBool(true)
    _ => VBool(false)
  }
}

///|
/// §18.17.7.ISTEXT — test whether a value is text.
fn fn_istext(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VString(_) => VBool(true)
    _ => VBool(false)
  }
}

///|
/// §18.17.7.ISLOGICAL — test whether a value is logical.
fn fn_islogical(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VBool(_) => VBool(true)
    _ => VBool(false)
  }
}

///|
/// §18.17.7.ISERROR — test whether a value is any error.
fn fn_iserror(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VError(_) => VBool(true)
    _ => VBool(false)
  }
}

///|
/// §18.17.7.ISNA — test whether a value is #N/A.
fn fn_isna(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VError(NotApplicable) => VBool(true)
    _ => VBool(false)
  }
}

///|
/// §18.17.7.ISERR — test whether a value is an error other than #N/A.
fn fn_iserr(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VError(NotApplicable) => VBool(false)
    VError(_) => VBool(true)
    _ => VBool(false)
  }
}

///|
/// §18.17.7.TYPE — return the numeric type code for a value.
fn fn_type(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0] {
    VArray(_) => VNumber(64.0)
    other =>
      match other.first_scalar() {
        VNumber(_) => VNumber(1.0)
        VString(_) => VNumber(2.0)
        VBool(_) => VNumber(4.0)
        VError(_) => VNumber(16.0)
        VEmpty => VNumber(1.0)
        VArray(_) => VNumber(64.0)
      }
  }
}

///|
/// §18.17.7.NA — return the #N/A error value.
fn fn_na(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    VError(NotApplicable)
  } else {
    VError(Value)
  }
}

///|
/// §18.17.7.N — coerce a value to a number, propagating errors.
fn fn_n(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VNumber(value) => VNumber(value)
    VBool(value) => VNumber(if value { 1.0 } else { 0.0 })
    VError(err) => VError(err)
    VString(_) | VEmpty => VNumber(0.0)
    VArray(_) => VNumber(0.0)
  }
}

///|
/// §18.17.7.T — return text values and the empty string for non-text values.
fn fn_t(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match args[0].first_scalar() {
    VString(value) => VString(value)
    VError(err) => VError(err)
    _ => VString("")
  }
}
