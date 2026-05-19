// trkbt10/ooxml/ecma376/drawing_ml — typed CT_ helpers
//
// ECMA-376 Part 1 §20.1 DrawingML Main typed-decoder support. Shared
// attribute / child-element accessors used by the typed CT_* projections
// (replacing the legacy `pub struct CT_X { element : @xml.Element }`
// element-only wrappers per the ct-typing protocol).
//
// The helpers raise `SchemaViolation` (declared in `schema_error.mbt`)
// with `schema="dml-main.xsd"` so all diagnostics point back at the
// canonical Part 1 §20.1 Annex A.4.1 schema.

///|
/// Find an attribute on `element` by local name (any namespace) and
/// return its raw lexical string. Returns None when the attribute is
/// absent. Used as the foundation for every typed attribute accessor.
fn ct_attr(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return Some(attribute.value)
    }
  }
  None
}

///|
/// Decode a required xsd:string attribute. Raises SchemaViolation with
/// `path` (typically "CT_X/@attr") when the attribute is absent.
fn ct_required_string(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> String raise SchemaViolation {
  match ct_attr(element, local_name) {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path~,
        reason="missing required attribute @" + local_name,
      )
  }
}

///|
/// Decode an optional xsd:string attribute, falling back to the
/// schema-declared default when the attribute is absent.
fn ct_optional_string(
  element : @xml.Element,
  local_name : String,
  default~ : String,
) -> String {
  match ct_attr(element, local_name) {
    Some(v) => v
    None => default
  }
}

///|
/// Parse a lexical xsd:int value (optional leading sign, digits only).
/// Empty or non-digit lexical forms raise SchemaViolation.
fn ct_parse_int_lex(value : String, path : String) -> Int raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="empty xsd:int lexical form",
    )
  }
  let mut i = 0
  let mut sign = 1
  let first = value.code_unit_at(0).to_int()
  if first == '-'.to_int() {
    sign = -1
    i = 1
  } else if first == '+'.to_int() {
    i = 1
  }
  if i >= value.length() {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="invalid xsd:int lexical form: " + value,
    )
  }
  let mut acc = 0
  while i < value.length() {
    let code = value.code_unit_at(i).to_int()
    if code < '0'.to_int() || code > '9'.to_int() {
      raise SchemaViolation(
        schema="dml-main.xsd",
        path~,
        reason="invalid xsd:int lexical form: " + value,
      )
    }
    acc = acc * 10 + (code - '0'.to_int())
    i = i + 1
  }
  acc * sign
}

///|
/// Parse a lexical xsd:unsignedInt value. Empty or non-digit forms
/// raise SchemaViolation.
fn ct_parse_uint_lex(
  value : String,
  path : String,
) -> UInt raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="empty xsd:unsignedInt lexical form",
    )
  }
  let mut acc : UInt = 0U
  for i in 0..<value.length() {
    let code = value.code_unit_at(i).to_int()
    if code < '0'.to_int() || code > '9'.to_int() {
      raise SchemaViolation(
        schema="dml-main.xsd",
        path~,
        reason="invalid xsd:unsignedInt lexical form: " + value,
      )
    }
    acc = acc * 10U + (code - '0'.to_int()).reinterpret_as_uint()
  }
  acc
}

///|
/// Parse a lexical xsd:unsignedByte value (0..255). Raises
/// SchemaViolation on invalid form or out-of-range value.
fn ct_parse_ubyte_lex(
  value : String,
  path : String,
) -> Int raise SchemaViolation {
  let n = ct_parse_uint_lex(value, path)
  if n > 255U {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="xsd:unsignedByte out of range: " + value,
    )
  }
  n.reinterpret_as_int()
}

///|
/// Parse a lexical xsd:byte value (signed 8-bit, -128..127). Raises
/// SchemaViolation on invalid form or out-of-range value. Accepts an
/// optional leading sign.
fn ct_parse_byte_lex(
  value : String,
  path : String,
) -> Int raise SchemaViolation {
  let n = ct_parse_int_lex(value, path)
  if n < -128 || n > 127 {
    raise SchemaViolation(
      schema="dml-main.xsd",
      path~,
      reason="xsd:byte out of range: " + value,
    )
  }
  n
}

///|
/// Parse a lexical xsd:boolean value. Accepts the four canonical forms
/// `true`, `false`, `1`, `0` per the XSD §3.2.2 specification.
fn ct_parse_bool_lex(
  value : String,
  path : String,
) -> Bool raise SchemaViolation {
  match value {
    "true" | "1" => true
    "false" | "0" => false
    _ =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path~,
        reason="invalid xsd:boolean lexical form: " + value,
      )
  }
}

///|
/// Decode an optional xsd:int attribute with a schema-declared default.
fn ct_optional_int(
  element : @xml.Element,
  local_name : String,
  default~ : Int,
  path : String,
) -> Int raise SchemaViolation {
  match ct_attr(element, local_name) {
    Some(v) => ct_parse_int_lex(v, path)
    None => default
  }
}

///|
/// Decode an optional xsd:unsignedInt attribute with a default.
fn ct_optional_uint(
  element : @xml.Element,
  local_name : String,
  default~ : UInt,
  path : String,
) -> UInt raise SchemaViolation {
  match ct_attr(element, local_name) {
    Some(v) => ct_parse_uint_lex(v, path)
    None => default
  }
}

///|
/// Decode a required xsd:unsignedByte attribute (1-byte unsigned int).
fn ct_required_ubyte(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int raise SchemaViolation {
  let lex = ct_required_string(element, local_name, path)
  ct_parse_ubyte_lex(lex, path)
}

///|
/// Decode an optional xsd:boolean attribute with a default.
fn ct_optional_bool(
  element : @xml.Element,
  local_name : String,
  default~ : Bool,
  path : String,
) -> Bool raise SchemaViolation {
  match ct_attr(element, local_name) {
    Some(v) => ct_parse_bool_lex(v, path)
    None => default
  }
}

///|
/// Return the first child element with the supplied local name, or
/// None when no such child is present. Non-element nodes (text,
/// comment, processing-instruction) are skipped.
fn ct_first_child(element : @xml.Element, local_name : String) -> @xml.Element? {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        if child.name.local_name == local_name {
          return Some(child)
        }
      _ => ()
    }
  }
  None
}

///|
/// Return every child element with the supplied local name in
/// document order.
fn ct_children(
  element : @xml.Element,
  local_name : String,
) -> Array[@xml.Element] {
  let result : Array[@xml.Element] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        if child.name.local_name == local_name {
          result.push(child)
        }
      _ => ()
    }
  }
  result
}
