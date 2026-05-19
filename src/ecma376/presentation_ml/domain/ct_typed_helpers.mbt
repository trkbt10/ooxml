// =============================================================================
// Local helpers for chunk2 element-only wrapper → typed-struct promotion.
//
// PresentationML attributes use the no-namespace `attributeForm` per pml.xsd
// (the `r:id` reference is the documented exception, qualified with the
// relationships namespace but resolved by local name in our codebase). So a
// local-name lookup suffices for every attribute lookup below.
//
// The `pml_*` helpers are intentionally distinct from the `ttt_*` helpers in
// `transition_timing_types.mbt` so that the two files remain independently
// rewritable.
// =============================================================================

///|
/// First-attribute lookup by local name.
fn pml_attr(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
/// Required attribute lookup. Raises SchemaViolation with `path` as the
/// canonical "CT_X/@foo" anchor when the attribute is missing.
fn pml_require_attr(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> String raise SchemaViolation {
  match pml_attr(element, local_name) {
    Some(v) => v
    None =>
      raise SchemaViolation(
        type_name=path,
        value="",
        reason="required attribute missing",
      )
  }
}

///|
/// Decode a required xsd:unsignedInt attribute. Raises SchemaViolation when
/// the attribute is missing or malformed.
fn pml_require_unsigned_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> UInt raise SchemaViolation {
  let raw = pml_require_attr(element, local_name, path)
  match parse_xsd_unsigned_int(raw) {
    Some(n) => n
    None =>
      raise SchemaViolation(
        type_name=path,
        value=raw,
        reason="expected xsd:unsignedInt",
      )
  }
}

///|
/// Decode an optional xsd:unsignedInt attribute. Returns None when absent
/// and raises when the lexical form is invalid.
fn pml_optional_unsigned_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> UInt? raise SchemaViolation {
  match pml_attr(element, local_name) {
    None => None
    Some(raw) =>
      match parse_xsd_unsigned_int(raw) {
        Some(n) => Some(n)
        None =>
          raise SchemaViolation(
            type_name=path,
            value=raw,
            reason="expected xsd:unsignedInt",
          )
      }
  }
}

///|
/// Decode an optional xsd:int attribute.
fn pml_optional_int(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Int? raise SchemaViolation {
  match pml_attr(element, local_name) {
    None => None
    Some(raw) =>
      match pml_parse_int(raw) {
        Some(n) => Some(n)
        None =>
          raise SchemaViolation(
            type_name=path,
            value=raw,
            reason="expected xsd:int",
          )
      }
  }
}

///|
/// xsd:int lexical decoder. ASCII decimal with optional leading sign.
fn pml_parse_int(s : String) -> Int? {
  if s.length() == 0 {
    return None
  }
  let (sign, start) = if s.code_unit_at(0).to_int() == 0x2D {
    (-1, 1)
  } else if s.code_unit_at(0).to_int() == 0x2B {
    (1, 1)
  } else {
    (1, 0)
  }
  if start >= s.length() {
    return None
  }
  let mut value : Int = 0
  for i in start..<s.length() {
    let unit = s.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10 + (unit - 0x30)
  }
  Some(value * sign)
}

///|
/// xsd:boolean lexical decoder. Lexical space is `true|false|1|0` per W3C
/// XML Schema Part 2 §3.2.2.
fn pml_parse_bool(s : String) -> Bool? {
  match s {
    "true" => Some(true)
    "1" => Some(true)
    "false" => Some(false)
    "0" => Some(false)
    _ => None
  }
}

///|
/// Decode an optional xsd:boolean attribute. Returns None when absent and
/// raises when the lexical form is invalid.
fn pml_optional_bool(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Bool? raise SchemaViolation {
  match pml_attr(element, local_name) {
    None => None
    Some(raw) =>
      match pml_parse_bool(raw) {
        Some(b) => Some(b)
        None =>
          raise SchemaViolation(
            type_name=path,
            value=raw,
            reason="expected xsd:boolean",
          )
      }
  }
}

///|
/// First element child whose local name equals `local_name`.
fn pml_first_child(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Element(e) => if e.name.local_name == local_name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
/// All direct element children whose local name equals `local_name`, in
/// document order.
fn pml_children(
  element : @xml.Element,
  local_name : String,
) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => if e.name.local_name == local_name { out.push(e) }
      _ => ()
    }
  }
  out
}

///|
/// First element child whose local name is in `local_names`, returning the
/// element and the matched local-name. Used for `xsd:choice` decoding.
fn pml_first_choice(
  element : @xml.Element,
  local_names : Array[String],
) -> (@xml.Element, String)? {
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let ln = e.name.local_name
        for candidate in local_names {
          if ln == candidate {
            return Some((e, candidate))
          }
        }
      }
      _ => ()
    }
  }
  None
}
