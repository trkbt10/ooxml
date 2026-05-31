///|
/// §18.17.2.4 — function implementation shape for SpreadsheetML formula calls.
/// Eager functions receive already evaluated arguments; lazy functions receive
/// raw AST arguments with the evaluation context for short-circuit behavior.
pub(all) enum FunctionDef {
  Eager((Array[FormulaValue], EvalContext) -> FormulaValue)
  Lazy((Array[FormulaAst], EvalContext) -> FormulaValue)
}

///|
/// §18.17.2.4 — mutable registry of formula functions keyed by uppercased
/// function name. It starts empty so built-in libraries can be registered by
/// later phases without changing evaluator traversal.
pub(all) struct FunctionRegistry {
  entries : @hashmap.HashMap[String, FunctionDef]
}

///|
/// §18.17.2.4 — construct an empty SpreadsheetML function registry. No built-in
/// functions are preloaded in this phase; callers and tests register only the
/// functions they want to expose.
pub fn FunctionRegistry::new() -> FunctionRegistry {
  let entries : @hashmap.HashMap[String, FunctionDef] = @hashmap.HashMap(
    [],
    capacity=0,
  )
  { entries, }
}

///|
/// §18.17.2.4 — register or replace a SpreadsheetML formula function. Names are
/// canonicalized with ASCII uppercasing so formula calls are case-insensitive
/// while preserving a single dispatch table entry per function.
pub fn FunctionRegistry::register(
  self : FunctionRegistry,
  name : String,
  def : FunctionDef,
) -> Unit {
  let key = formula_ascii_upper(name)
  if key != "" {
    self.entries.set(key, def)
  } else {
    self.entries.set(name, def)
  }
}

///|
/// §18.17.2.4 — look up a SpreadsheetML formula function by case-insensitive
/// name. The evaluator maps a missing entry to `#NAME?` rather than raising.
pub fn FunctionRegistry::lookup(
  self : FunctionRegistry,
  name : String,
) -> FunctionDef? {
  let key = formula_ascii_upper(name)
  match self.entries.get(key) {
    Some(def) => Some(def)
    None => if key == name { None } else { self.entries.get(name) }
  }
}
