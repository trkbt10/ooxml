// XSD 1.0 `xsd:boolean` parser — used pervasively across
// SpreadsheetML attributes (`@hidden`, `@customHeight`, `@bestFit`,
// `@thickTop`, `@thickBot`, `@s`, ...).  The four spec-permitted
// lexical forms are `0`, `1`, `false`, `true`; every other value
// is a schema violation.

///|
/// Parse an XSD boolean attribute value.  Returns the boolean
/// literal when the value is one of `0`, `1`, `false`, `true`;
/// returns None for either an absent attribute or a schema-
/// violating literal.
pub fn parse_xsd_boolean(v : String?) -> Bool? {
  match v {
    None => None
    // XML Schema 1.0 §3.2.2.1 — exactly 4 lexical forms.
    Some("1") => Some(true)
    Some("true") => Some(true)
    Some("0") => Some(false)
    Some("false") => Some(false)
    // Schema violation — unknown lexical form for xsd:boolean.
    Some(_) => None
  }
}

///|
pub fn parse_xsd_boolean_or(v : String?, default_value : Bool) -> Bool {
  match parse_xsd_boolean(v) {
    Some(b) => b
    None => default_value
  }
}
