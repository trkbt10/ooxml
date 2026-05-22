// XSD 1.0 `xsd:boolean` parser — used pervasively across DrawingML
// and PresentationML attributes (`@b`, `@i`, `@rtl`, `@dirty`,
// `@anchorCtr`, `@useBgFill`, ...).  The four spec-permitted
// lexical forms are `0`, `1`, `false`, `true`; every other value
// is a schema violation.
//
// We centralise the parse so every viewer call site uses the same
// 4-value exhaustive match instead of the ad-hoc
// `Some("1") | Some("true") => …` pattern which silently classified
// any other value as `false`.

///|
/// Parse an XSD boolean attribute value.  Returns the boolean
/// literal when the value is one of `0`, `1`, `false`, `true`;
/// returns None for either an absent attribute (`Option::None`)
/// or a schema-violating literal — the caller can choose between
/// the spec default (almost always `false`) and surfacing the
/// violation upstream.
pub fn parse_xsd_boolean(v : String?) -> Bool? {
  match v {
    None => None
    // §3.2.2.1 (XML Schema 1.0) — exactly 4 lexical forms.
    Some("1") => Some(true)
    Some("true") => Some(true)
    Some("0") => Some(false)
    Some("false") => Some(false)
    // Schema violation — unknown lexical form for xsd:boolean.
    // Return None so the caller substitutes the per-attribute
    // spec default rather than silently classifying as false.
    Some(_) => None
  }
}

///|
/// Convenience wrapper: parse with a per-attribute spec default.
/// Used by call sites that need a `Bool` result and have already
/// committed to the spec-mandated default for their attribute.
pub fn parse_xsd_boolean_or(v : String?, default_value : Bool) -> Bool {
  match parse_xsd_boolean(v) {
    Some(b) => b
    None => default_value
  }
}
