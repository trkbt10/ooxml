// §17.18.69 ST_OnOff parser.
//
// WordprocessingML toggle properties (<w:b>, <w:i>, <w:strike>,
// <w:caps>, <w:smallCaps>, …) all carry a ST_OnOff `@val` whose
// lexical space is exactly six values: `0`, `1`, `false`, `true`,
// `off`, `on`.  Anything else is a schema violation.
//
// The previous `has_toggle` accepted any non-`{0,false,off}`
// value (including arbitrary garbage) as "on".  We tighten the
// match to the closed enum and treat schema-violating literals as
// the spec default for a toggle: `true` when the element is
// present, mirroring the bullet of §17.3 toggle semantics ("if
// @val is missing the property is enabled").

///|
/// Parse a ST_OnOff attribute value.  Returns the boolean literal
/// for any of the 6 spec-permitted forms; returns None for either
/// an absent attribute or a schema-violating literal.
pub fn parse_xsd_on_off(v : String?) -> Bool? {
  match v {
    None => None
    Some("1") => Some(true)
    Some("true") => Some(true)
    Some("on") => Some(true)
    Some("0") => Some(false)
    Some("false") => Some(false)
    Some("off") => Some(false)
    // Schema violation — value is outside ST_OnOff.
    Some(_) => None
  }
}

///|
/// Convenience: parse with the per-attribute spec default.  When
/// the attribute is absent ST_OnOff toggles default to `true` per
/// §17.3 wording, but the caller may override the default for
/// non-toggle attributes (e.g. `<w:noProof @val>` where the
/// container's presence does NOT imply enablement).
pub fn parse_xsd_on_off_or(v : String?, default_value : Bool) -> Bool {
  match parse_xsd_on_off(v) {
    Some(b) => b
    None => default_value
  }
}
