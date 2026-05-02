///|
fn register_builtin_logical_functions(registry : FunctionRegistry) -> Unit {
  registry.register("IF", Lazy(fn_if))
  registry.register("IFERROR", Lazy(fn_iferror))
  registry.register("IFNA", Lazy(fn_ifna))
  registry.register("AND", Lazy(fn_and))
  registry.register("OR", Lazy(fn_or))
  registry.register("NOT", Eager(fn_not))
  registry.register("XOR", Eager(fn_xor))
  registry.register("TRUE", Eager(fn_true))
  registry.register("FALSE", Eager(fn_false))
}

///|
/// §18.17.7.IF — choose one branch according to a logical condition.
fn fn_if(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 && args.length() != 3 {
    return VError(Value)
  }
  match coerce_to_bool(evaluate(args[0], ctx)) {
    VBool(true) => evaluate(args[1], ctx)
    VBool(false) =>
      if args.length() == 3 {
        evaluate(args[2], ctx)
      } else {
        VBool(false)
      }
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.IFERROR — return an alternate value only when value is an error.
fn fn_iferror(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let value = evaluate(args[0], ctx)
  match value {
    VError(_) => evaluate(args[1], ctx)
    other => other
  }
}

///|
/// §18.17.7.IFNA — return an alternate value only when value is #N/A.
fn fn_ifna(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  if args.length() != 2 {
    return VError(Value)
  }
  let value = evaluate(args[0], ctx)
  match value {
    VError(NotApplicable) => evaluate(args[1], ctx)
    other => other
  }
}

///|
/// §18.17.7.AND — return TRUE if every logical argument is TRUE.
fn fn_and(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    return VError(Value)
  }
  for arg in args {
    match coerce_to_bool(evaluate(arg, ctx)) {
      VBool(false) => return VBool(false)
      VBool(true) => ()
      VError(err) => return VError(err)
      _ => return VError(Value)
    }
  }
  VBool(true)
}

///|
/// §18.17.7.OR — return TRUE if any logical argument is TRUE.
fn fn_or(args : Array[FormulaAst], ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    return VError(Value)
  }
  for arg in args {
    match coerce_to_bool(evaluate(arg, ctx)) {
      VBool(true) => return VBool(true)
      VBool(false) => ()
      VError(err) => return VError(err)
      _ => return VError(Value)
    }
  }
  VBool(false)
}

///|
/// §18.17.7.NOT — invert a logical value.
fn fn_not(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() != 1 {
    return VError(Value)
  }
  match coerce_to_bool(args[0]) {
    VBool(value) => VBool(!value)
    VError(err) => VError(err)
    _ => VError(Value)
  }
}

///|
/// §18.17.7.XOR — return TRUE when an odd count of arguments is TRUE.
fn fn_xor(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    return VError(Value)
  }
  let mut true_count = 0
  for arg in args {
    match coerce_to_bool(arg) {
      VBool(true) => true_count += 1
      VBool(false) => ()
      VError(err) => return VError(err)
      _ => return VError(Value)
    }
  }
  VBool(true_count % 2 == 1)
}

///|
/// §18.17.7.TRUE — return the logical value TRUE.
fn fn_true(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    VBool(true)
  } else {
    VError(Value)
  }
}

///|
/// §18.17.7.FALSE — return the logical value FALSE.
fn fn_false(args : Array[FormulaValue], _ctx : EvalContext) -> FormulaValue {
  if args.length() == 0 {
    VBool(false)
  } else {
    VError(Value)
  }
}
