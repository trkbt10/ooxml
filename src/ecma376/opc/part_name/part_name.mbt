///|
/// ECMA-376 Part 2 §6.2.2 part name lexical value. The value is stored in
/// package-name form with a leading slash; §7.3.3 Zip Item Names are derived
/// by stripping that leading slash at physical ZIP boundaries.
pub(all) struct PartName {
  value : String
} derive(Eq, Debug)

///|
/// Parse a user-supplied ECMA-376 Part 2 §6.2.2.2 part name. The user-facing
/// parser also rejects reserved relationship part names from §6.5.2.2 and
/// §6.5.2.3; OPC internals use PartName::__from_trusted for those names.
pub fn PartName::parse(
  value : String,
) -> PartName raise @opc_errors.SchemaViolation {
  validate_part_name_grammar(value)
  let part_name = { value, }
  if !part_name.is_user_creatable() {
    raise @opc_errors.SchemaViolation(
      section="6.5.2.3",
      path="PartName",
      reason="relationship part names are reserved",
    )
  }
  part_name
}

///|
/// Construct an OPC-internal ECMA-376 Part 2 §6.2.2.2 part name after grammar
/// validation while allowing §6.5.2.2 and §6.5.2.3 reserved relationship part
/// names such as `/_rels/.rels`.
pub fn PartName::__from_trusted(
  value : String,
) -> PartName raise @opc_errors.SchemaViolation {
  validate_part_name_grammar(value)
  { value, }
}

///|
/// Return the ECMA-376 Part 2 §6.2.2 part-name lexical value.
pub fn PartName::to_string(self : PartName) -> String {
  self.value
}

///|
/// Return the ECMA-376 Part 2 §7.3.3 Zip Item Names physical ZIP item name
/// corresponding to this part name.
pub fn PartName::zip_item_name(self : PartName) -> String {
  if self.value.has_prefix("/") {
    self.value[1:].to_owned()
  } else {
    self.value
  }
}

///|
/// ECMA-376 Part 2 §6.5.2.2 reserves `/_rels/.rels`, and §6.5.2.3 reserves
/// any relationship part name whose second-to-last segment is `_rels` and
/// whose final segment ends in `.rels`, using ASCII case-insensitive matching.
pub fn PartName::is_user_creatable(self : PartName) -> Bool {
  !is_reserved_relationship_part_name(self.value)
}

///|
/// Resolve an OPC relationship target against its owner part name using the
/// ECMA-376 Part 2 §6.4.2 Base IRIs model, returning a normalized §6.2.2 part
/// name string.
pub fn resolve_target(
  owner : String,
  target : String,
) -> String raise @opc_errors.SchemaViolation {
  if target.has_prefix("/") {
    normalize_part_name(target)
  } else if owner == "/" || owner == "" {
    normalize_part_name("/" + target)
  } else {
    let base = owner[0:last_slash(owner)].to_owned()
    normalize_part_name(base + "/" + target)
  }
}

///|
/// Normalize dot segments in an OPC relationship target into an ECMA-376 Part
/// 2 §6.2.2 part name string, then validate the resulting part-name grammar.
pub fn normalize_part_name(
  name : String,
) -> String raise @opc_errors.SchemaViolation {
  let pieces = name.split("/")
  let out : Array[String] = []
  for piece in pieces {
    if piece == "" || piece == "." {
      ()
    } else if piece == ".." {
      out.pop() |> ignore
    } else {
      out.push(piece.to_owned())
    }
  }
  let normalized = "/" + out.join("/")
  validate_part_name_grammar(normalized)
  normalized
}

///|
/// ECMA-376 Part 2 §6.2.2.2 part names must start with `/`, must not contain
/// backslash, empty segments, a trailing slash, or literal dot-only segments.
fn validate_part_name_grammar(
  value : String,
) -> Unit raise @opc_errors.SchemaViolation {
  if !value.has_prefix("/") {
    raise @opc_errors.SchemaViolation(
      section="6.2.2.2",
      path="PartName",
      reason="part name must start with /",
    )
  }
  if value.contains("\\") ||
    value.contains("//") ||
    value.has_suffix("/") ||
    value.contains("/../") ||
    value.contains("/./") {
    raise @opc_errors.SchemaViolation(
      section="6.2.2.2",
      path="PartName",
      reason="part name contains a disallowed segment",
    )
  }
  validate_percent_encoding(value)
  validate_segment_end_dots(value)
}

///|
/// ECMA-376 Part 2 §6.2.2.2 incorporates RFC 3986 pct-encoded syntax: each
/// percent sign must be followed by exactly two ASCII hex digits.
fn validate_percent_encoding(
  value : String,
) -> Unit raise @opc_errors.SchemaViolation {
  let chars = value.to_array()
  let mut i = 0
  while i < chars.length() {
    if chars[i] == '%' {
      if i + 2 >= chars.length() ||
        !is_ascii_hex(chars[i + 1]) ||
        !is_ascii_hex(chars[i + 2]) {
        raise @opc_errors.SchemaViolation(
          section="6.2.2.2",
          path="PartName",
          reason="malformed percent-encoding",
        )
      }
      let decoded = hex_value(chars[i + 1]) * 16 + hex_value(chars[i + 2])
      validate_percent_decoded_byte(decoded)
      i += 3
    } else {
      i += 1
    }
  }
}

///|
/// ECMA-376 Part 2 §6.2.2.2 forbids percent-encoded `/`, `\`, and characters
/// matching RFC 3987 iunreserved; ASCII unreserved bytes and UTF-8 non-ASCII
/// bytes are therefore rejected when encoded.
fn validate_percent_decoded_byte(
  decoded : Int,
) -> Unit raise @opc_errors.SchemaViolation {
  if decoded == 0x2F ||
    decoded == 0x5C ||
    is_ascii_iunreserved_byte(decoded) ||
    decoded >= 0x80 {
    raise @opc_errors.SchemaViolation(
      section="6.2.2.2",
      path="PartName",
      reason="percent-encoded forbidden character",
    )
  }
}

///|
/// ECMA-376 Part 2 §6.2.2.2 forbids any I18N segment from ending with a
/// literal dot.
fn validate_segment_end_dots(
  value : String,
) -> Unit raise @opc_errors.SchemaViolation {
  let pieces = value.split("/")
  for piece in pieces {
    if piece != "" && piece.has_suffix(".") {
      raise @opc_errors.SchemaViolation(
        section="6.2.2.2",
        path="PartName",
        reason="part name segment must not end with .",
      )
    }
  }
}

///|
fn is_reserved_relationship_part_name(value : String) -> Bool {
  let pieces = value.split("/")
  let segments : Array[String] = []
  for piece in pieces {
    if piece != "" {
      segments.push(piece.to_owned())
    }
  }
  if segments.length() == 2 &&
    ascii_case_eq(segments[0], "_rels") &&
    segments[1] == ".rels" {
    true
  } else if segments.length() >= 2 {
    ascii_case_eq(segments[segments.length() - 2], "_rels") &&
    segments[segments.length() - 1].has_suffix(".rels")
  } else {
    false
  }
}

///|
fn is_ascii_hex(ch : Char) -> Bool {
  ('0' <= ch && ch <= '9') ||
  ('A' <= ch && ch <= 'F') ||
  ('a' <= ch && ch <= 'f')
}

///|
fn hex_value(ch : Char) -> Int {
  if '0' <= ch && ch <= '9' {
    ch.to_int() - '0'.to_int()
  } else if 'A' <= ch && ch <= 'F' {
    ch.to_int() - 'A'.to_int() + 10
  } else {
    ch.to_int() - 'a'.to_int() + 10
  }
}

///|
fn is_ascii_iunreserved_byte(value : Int) -> Bool {
  (0x41 <= value && value <= 0x5A) ||
  (0x61 <= value && value <= 0x7A) ||
  (0x30 <= value && value <= 0x39) ||
  value == 0x2D ||
  value == 0x2E ||
  value == 0x5F ||
  value == 0x7E
}

///|
fn ascii_case_eq(left : String, right : String) -> Bool {
  if left.length() != right.length() {
    false
  } else {
    let left_chars = left.to_array()
    let right_chars = right.to_array()
    let mut ok = true
    for i in 0..<left_chars.length() {
      if ascii_lower(left_chars[i]) != ascii_lower(right_chars[i]) {
        ok = false
      }
    }
    ok
  }
}

///|
fn ascii_lower(ch : Char) -> Char {
  if 'A' <= ch && ch <= 'Z' {
    (ch.to_int() + 32).unsafe_to_char()
  } else {
    ch
  }
}

///|
/// Return the final slash offset in a string for callers that need the same
/// ECMA-376 Part 2 §6.2.2 part-name path splitting primitive as normalization.
pub fn last_slash(value : String) -> Int {
  let chars = value.to_array()
  let mut result = -1
  for i in 0..<chars.length() {
    if chars[i] == '/' {
      result = i
    }
  }
  result
}
