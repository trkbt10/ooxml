///|
/// §18.17.5 — the seven specified SpreadsheetML formula error values, plus
/// the residual lexical `#GETTING_DATA` value carried by the formula grammar.
pub(all) enum FormulaError {
  DivZero
  NotApplicable
  Name
  NullErr
  Num
  Ref
  Value
  GettingData
} derive(Eq, Debug)

///|
/// §18.17.5 — return the cell literal for a SpreadsheetML formula error value.
/// The spelling is the serialized token used in cell values and formula
/// constants, including the punctuation required by ST_Error.
pub fn FormulaError::to_literal(self : FormulaError) -> String {
  match self {
    DivZero => "#DIV/0!"
    NotApplicable => "#N/A"
    Name => "#NAME?"
    NullErr => "#NULL!"
    Num => "#NUM!"
    Ref => "#REF!"
    Value => "#VALUE!"
    GettingData => "#GETTING_DATA"
  }
}

///|
/// §18.17.5 — parse a SpreadsheetML formula error literal. Unknown strings are
/// rejected as `None` so callers can map malformed or unsupported formula
/// constants to `#VALUE!` without raising from formula evaluation.
pub fn FormulaError::from_literal(literal : String) -> FormulaError? {
  match literal {
    "#DIV/0!" => Some(DivZero)
    "#N/A" => Some(NotApplicable)
    "#NAME?" => Some(Name)
    "#NULL!" => Some(NullErr)
    "#NUM!" => Some(Num)
    "#REF!" => Some(Ref)
    "#VALUE!" => Some(Value)
    "#GETTING_DATA" => Some(GettingData)
    _ => None
  }
}
