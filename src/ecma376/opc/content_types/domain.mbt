///|
/// ST_ContentType simple type from schema bundle opc-contentTypes.xsd, used by
/// CT_Default and CT_Override to identify package part media types.
pub(all) struct ContentType {
  value : String
} derive(Eq, Debug)

///|
/// Parse ST_ContentType for Default and Override declarations.
pub fn ContentType::parse(
  value : String,
) -> ContentType raise @opc_errors.SchemaViolation {
  if !is_content_type(value) {
    raise @opc_errors.SchemaViolation(
      section="10.1",
      path="ST_ContentType",
      reason="content type must match the opc-contentTypes.xsd media-type pattern",
    )
  }
  { value, }
}

///|
/// Return the lexical ST_ContentType value used by CT_Default and CT_Override.
pub fn ContentType::to_string(self : ContentType) -> String {
  self.value
}

///|
/// Schema-named alias for opc-contentTypes.xsd simple type ST_ContentType.
pub type ST_ContentType = ContentType

///|
/// ST_Extension simple type from schema bundle opc-contentTypes.xsd, the
/// Default rule key for extension-based content-type lookup.
pub(all) struct Extension {
  value : String
} derive(Eq, Debug)

///|
/// Parse ST_Extension for a Default declaration.
pub fn Extension::parse(
  value : String,
) -> Extension raise @opc_errors.SchemaViolation {
  if !is_content_type_extension(value) {
    raise @opc_errors.SchemaViolation(
      section="10.1",
      path="ST_Extension",
      reason="extension must match the opc-contentTypes.xsd ST_Extension pattern",
    )
  }
  { value, }
}

///|
/// Return the lexical ST_Extension value used by CT_Default.
pub fn Extension::to_string(self : Extension) -> String {
  self.value
}

///|
/// Schema-named alias for opc-contentTypes.xsd simple type ST_Extension.
pub type ST_Extension = Extension

///|
/// Part name used by CT_Override PartName attributes. The canonical
/// ECMA-376 Part 2 §6.2.2.2 grammar lives in `src/ecma376/opc/part_name`.
pub type PartName = @opc_part_name.PartName

///|
/// XSD complex type CT_Default — ECMA-376 Part 2 §10.1.2.2 / Annex C
/// opc-contentTypes.xsd. Default top-level rule that binds a part-name
/// extension to a registered content type.
pub(all) struct CT_Default {
  extension : Extension
  content_type : ContentType
} derive(Eq, Debug)

///|
/// Build CT_Default from validated ST_Extension and ST_ContentType values.
fn CT_Default::new(
  extension : Extension,
  content_type : ContentType,
) -> CT_Default {
  { extension, content_type }
}

///|
/// XSD complex type CT_Override — ECMA-376 Part 2 §10.1.2.3 / Annex C
/// opc-contentTypes.xsd. Override top-level rule that binds a specific part
/// name to its content type.
pub(all) struct CT_Override {
  part_name : PartName
  content_type : ContentType
} derive(Eq, Debug)

///|
/// Build CT_Override from validated PartName and ST_ContentType values.
fn CT_Override::new(
  part_name : PartName,
  content_type : ContentType,
) -> CT_Override {
  { part_name, content_type }
}

///|
/// Rule alternatives allowed inside CT_Types.
pub(all) enum ContentTypeRule {
  Default(CT_Default)
  Override(CT_Override)
} derive(Eq, Debug)

///|
/// XSD complex type CT_Types — ECMA-376 Part 2 §10.1.2.1 / Annex C
/// opc-contentTypes.xsd. Root of `[Content_Types].xml` with the schema-ordered
/// sequence of CT_Default and CT_Override children.
pub(all) struct CT_Types {
  rules : Array[ContentTypeRule]
} derive(Eq, Debug)

///|
/// Build CT_Types while preserving declaration order and checking duplicate
/// Default/Override keys.
fn CT_Types::new(
  rules : Array[ContentTypeRule],
) -> CT_Types raise @opc_errors.SchemaViolation {
  let extensions : Array[String] = []
  let parts : Array[String] = []
  for rule in rules {
    match rule {
      Default(default) => {
        let key = default.extension.value
        if extensions.contains(key) {
          raise @opc_errors.SchemaViolation(
            section="10.1",
            path="/Types/Default/@Extension",
            reason="duplicate Default extension",
          )
        }
        extensions.push(key)
      }
      Override(override_rule) => {
        let key = override_rule.part_name.value
        if parts.contains(key) {
          raise @opc_errors.SchemaViolation(
            section="10.1",
            path="/Types/Override/@PartName",
            reason="duplicate Override part name",
          )
        }
        parts.push(key)
      }
    }
  }
  { rules, }
}

///|
/// Return the content type for a part, first using CT_Override and then the
/// CT_Default extension fallback. This accessor is the typed O1 query surface
/// the top-level OPC package uses before dispatching part payload readers.
pub fn CT_Types::content_type_for_part(
  self : CT_Types,
  part_name : PartName,
) -> ContentType? {
  // Part 2 §10.1.2.2.2 — the Override `PartName` comparison
  // "shall be case-insensitive ASCII".
  let target_lower = ascii_lower(part_name.value)
  for rule in self.rules {
    match rule {
      Override(override_rule) =>
        if ascii_lower(override_rule.part_name.value) == target_lower {
          return Some(override_rule.content_type)
        }
      _ => ()
    }
  }
  // Part 2 §10.1.2.2.1 — the extension comparison against a
  // CT_Default rule "shall be case-insensitive ASCII".  A part
  // `photo.JPEG` must match `<Default Extension="jpeg">`.
  let extension = extension_from_part_name(part_name.value)
  match extension {
    Some(extension) => {
      let ext_lower = ascii_lower(extension)
      for rule in self.rules {
        match rule {
          Default(default) =>
            if ascii_lower(default.extension.value) == ext_lower {
              return Some(default.content_type)
            }
          _ => ()
        }
      }
    }
    None => ()
  }
  None
}

///|
/// Part 2 §10.1.2.2 — lowercase the ASCII letters of a string.
/// Used for the case-insensitive extension comparison; non-ASCII
/// code units are passed through unchanged.
fn ascii_lower(s : String) -> String {
  let buf = StringBuilder::new()
  let mut i = 0
  while i < s.length() {
    let c = s.code_unit_at(i).to_int()
    if c >= 0x41 && c <= 0x5A {
      buf.write_char((c + 0x20).to_char().unwrap())
    } else {
      buf.write_char(c.to_char().unwrap())
    }
    i = i + 1
  }
  buf.to_string()
}

///|
/// Media type registry helper consumed by ecma376/opc/digital_signatures to
/// validate the digital-signature content types in `[Content_Types].xml`.
pub fn CT_Types::require_digital_signature_content_types(
  self : CT_Types,
  origin_part : PartName,
  signature_part : PartName,
  certificate_part : PartName?,
) -> Unit raise {
  self.require_part_content_type(
    origin_part,
    digital_signature_origin_content_type(),
    section="10.4.2",
    path="/Types/Override[@PartName='digital-signature-origin']",
  )
  self.require_part_content_type(
    signature_part,
    digital_signature_xml_signature_content_type(),
    section="10.4.3",
    path="/Types/Override[@PartName='digital-signature-xml-signature']",
  )
  match certificate_part {
    Some(part) =>
      self.require_part_content_type(
        part,
        digital_signature_certificate_content_type(),
        section="10.4.4",
        path="/Types/Override[@PartName='digital-signature-certificate']",
      )
    None => ()
  }
}

///|
/// Require a concrete content type for a package part, surfacing E4 when the
/// part has no Default or Override rule and E2 when the resolved media type is
/// not the expected §10 package-part type.
pub fn CT_Types::require_part_content_type(
  self : CT_Types,
  part_name : PartName,
  expected : ContentType,
  section~ : String,
  path~ : String,
) -> Unit raise {
  match self.content_type_for_part(part_name) {
    Some(actual) =>
      if actual != expected {
        raise @opc_errors.SchemaViolation(
          section~,
          path~,
          reason="part content type does not match the required OPC declaration",
        )
      }
    None =>
      raise @opc_errors.ResourceMissing(section~, path~, target=part_name.value)
  }
}

///|
/// Media type registry helper consumed by ecma376/opc/digital_signatures for
/// the Digital Signature Origin part.
pub fn digital_signature_origin_content_type() -> ContentType {
  unsafe_content_type(
    "application/vnd.openxmlformats-package.digital-signature-origin",
  )
}

///|
/// Media type registry helper consumed by ecma376/opc/digital_signatures for
/// the Digital Signature XML Signature part.
pub fn digital_signature_xml_signature_content_type() -> ContentType {
  unsafe_content_type(
    "application/vnd.openxmlformats-package.digital-signature-xmlsignature+xml",
  )
}

///|
/// Media type registry helper consumed by ecma376/opc/digital_signatures for
/// the Digital Signature Certificate part.
pub fn digital_signature_certificate_content_type() -> ContentType {
  unsafe_content_type(
    "application/vnd.openxmlformats-package.digital-signature-certificate",
  )
}

///|
fn extension_from_part_name(value : String) -> String? {
  let chars = value.to_array()
  let mut dot = -1
  let mut slash = -1
  for i in 0..<chars.length() {
    if chars[i] == '/' {
      slash = i
    } else if chars[i] == '.' {
      dot = i
    }
  }
  if dot > slash && dot + 1 < value.length() {
    Some(value[dot + 1:].to_owned())
  } else {
    None
  }
}

///|
fn unsafe_content_type(value : String) -> ContentType {
  { value, }
}

///|
fn is_content_type(value : String) -> Bool {
  let chars = value.to_array()
  let len = chars.length()
  let type_end = parse_media_token(chars, 0)
  if type_end == 0 || type_end >= len || chars[type_end] != '/' {
    return false
  }
  let subtype_start = type_end + 1
  let subtype_end = parse_media_token(chars, subtype_start)
  if subtype_end == subtype_start {
    return false
  }
  let mut pos = subtype_end
  while pos < len {
    let param_sep = skip_http_spaces(chars, pos)
    if param_sep >= len || chars[param_sep] != ';' {
      return false
    }
    pos = skip_http_spaces(chars, param_sep + 1)
    let name_end = parse_media_token(chars, pos)
    if name_end == pos {
      return false
    }
    pos = skip_http_spaces(chars, name_end)
    if pos >= len || chars[pos] != '=' {
      return false
    }
    pos = skip_http_spaces(chars, pos + 1)
    if pos >= len {
      return false
    }
    if chars[pos] == '"' {
      let quoted_end = parse_quoted_parameter_value(chars, pos)
      if quoted_end == pos {
        return false
      }
      pos = quoted_end
    } else {
      let value_end = parse_media_token(chars, pos)
      if value_end == pos {
        return false
      }
      pos = value_end
    }
  }
  true
}

///|
/// opc-contentTypes.xsd `ST_ContentType` token atom: Basic Latin except
/// controls, DEL, separators, and whitespace. Used for type, subtype,
/// parameter names, and unquoted parameter values.
fn parse_media_token(chars : Array[Char], start : Int) -> Int {
  let mut pos = start
  while pos < chars.length() && is_media_token_char(chars[pos]) {
    pos += 1
  }
  pos
}

///|
fn is_media_token_char(ch : Char) -> Bool {
  let code = ch.to_int()
  code > 0x20 && code < 0x7F && !is_media_separator_char(ch)
}

///|
fn is_media_separator_char(ch : Char) -> Bool {
  ch == '(' ||
  ch == ')' ||
  ch == '<' ||
  ch == '>' ||
  ch == '@' ||
  ch == ',' ||
  ch == ';' ||
  ch == ':' ||
  ch == '\\' ||
  ch == '"' ||
  ch == '/' ||
  ch == '[' ||
  ch == ']' ||
  ch == '?' ||
  ch == '=' ||
  ch == '{' ||
  ch == '}'
}

///|
fn skip_http_spaces(chars : Array[Char], start : Int) -> Int {
  let mut pos = start
  while pos < chars.length() && (chars[pos] == ' ' || chars[pos] == '\t') {
    pos += 1
  }
  pos
}

///|
/// Return the offset after a quoted parameter value, or `start` on failure.
/// The character class follows the quoted branch of opc-contentTypes.xsd.
fn parse_quoted_parameter_value(chars : Array[Char], start : Int) -> Int {
  let mut pos = start + 1
  while pos < chars.length() {
    let ch = chars[pos]
    if ch == '"' {
      return pos + 1
    } else if ch == '\\' {
      if pos + 1 >= chars.length() || chars[pos + 1].to_int() > 0x7F {
        return start
      }
      pos += 2
    } else if is_quoted_parameter_char(ch) {
      pos += 1
    } else {
      return start
    }
  }
  start
}

///|
fn is_quoted_parameter_char(ch : Char) -> Bool {
  let code = ch.to_int()
  ch == ' ' ||
  ch == '\t' ||
  (code >= 0x20 && code <= 0x7E && ch != '"') ||
  (code >= 0x80 && code <= 0xFF)
}

///|
fn is_content_type_extension(value : String) -> Bool {
  let chars = value.to_array()
  if chars.length() == 0 {
    return false
  }
  let mut pos = 0
  while pos < chars.length() {
    if chars[pos] == '%' {
      if pos + 2 >= chars.length() ||
        !is_ascii_hex(chars[pos + 1]) ||
        !is_ascii_hex(chars[pos + 2]) {
        return false
      }
      pos += 3
    } else if is_extension_char(chars[pos]) {
      pos += 1
    } else {
      return false
    }
  }
  true
}

///|
fn is_extension_char(ch : Char) -> Bool {
  ('A' <= ch && ch <= 'Z') ||
  ('a' <= ch && ch <= 'z') ||
  ('0' <= ch && ch <= '9') ||
  ch == '-' ||
  ch == '_' ||
  ch == '~' ||
  ch == '!' ||
  ch == '$' ||
  ch == '&' ||
  ch == '\'' ||
  ch == '(' ||
  ch == ')' ||
  ch == '*' ||
  ch == '+' ||
  ch == ',' ||
  ch == ':' ||
  ch == '=' ||
  ch == '@'
}

///|
fn is_ascii_hex(ch : Char) -> Bool {
  ('0' <= ch && ch <= '9') ||
  ('A' <= ch && ch <= 'F') ||
  ('a' <= ch && ch <= 'f')
}
