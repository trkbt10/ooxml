///|
/// XML Namespaces 1.0 §3 NCName validator. `xsd:ID` is derived from
/// `xsd:NCName`, so ECMA-376 packages use this single XML-level
/// predicate instead of re-implementing name lexical checks locally.
pub fn is_ncname(value : String) -> Bool {
  let chars = value.to_array()
  if chars.length() == 0 || !is_ncname_start_char(chars[0]) {
    false
  } else {
    let mut ok = true
    for i in 1..<chars.length() {
      ok = ok && is_ncname_char(chars[i])
    }
    ok
  }
}

///|
fn is_ncname_start_char(ch : Char) -> Bool {
  let code = ch.to_int()
  code == 0x5F ||
  (code >= 0x41 && code <= 0x5A) ||
  (code >= 0x61 && code <= 0x7A) ||
  (code >= 0xC0 && code <= 0xD6) ||
  (code >= 0xD8 && code <= 0xF6) ||
  (code >= 0xF8 && code <= 0x2FF) ||
  (code >= 0x370 && code <= 0x37D) ||
  (code >= 0x37F && code <= 0x1FFF) ||
  (code >= 0x200C && code <= 0x200D) ||
  (code >= 0x2070 && code <= 0x218F) ||
  (code >= 0x2C00 && code <= 0x2FEF) ||
  (code >= 0x3001 && code <= 0xD7FF) ||
  (code >= 0xF900 && code <= 0xFDCF) ||
  (code >= 0xFDF0 && code <= 0xFFFD) ||
  (code >= 0x10000 && code <= 0xEFFFF)
}

///|
fn is_ncname_char(ch : Char) -> Bool {
  let code = ch.to_int()
  is_ncname_start_char(ch) ||
  (code >= 0x30 && code <= 0x39) ||
  code == 0x2D ||
  code == 0x2E ||
  code == 0xB7 ||
  (code >= 0x0300 && code <= 0x036F) ||
  (code >= 0x203F && code <= 0x2040)
}
