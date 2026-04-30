///|
/// ST_ContentType simple type from schema bundle opc-contentTypes.xsd, used by
/// CT_Default and CT_Override to identify package parts including the §10.4
/// digital-signature part family.
pub(all) struct ContentType {
  value : String
} derive(Eq, Debug)

///|
/// Parse ST_ContentType for Default and Override declarations.
pub fn ContentType::parse(value : String) -> ContentType raise SchemaViolation {
  if !is_content_type(value) {
    raise SchemaViolation(
      section="10.1",
      path="ST_ContentType",
      reason="content type must be a type/subtype media type without spaces",
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
/// ST_Extension simple type from schema bundle opc-contentTypes.xsd, the
/// Default rule key for extension-based content-type lookup.
pub(all) struct Extension {
  value : String
} derive(Eq, Debug)

///|
/// Parse ST_Extension for a Default declaration.
pub fn Extension::parse(value : String) -> Extension raise SchemaViolation {
  if value == "" ||
    value.contains("/") ||
    value.contains("\\") ||
    value.contains(".") ||
    value.contains(" ") ||
    value.contains("\t") ||
    value.contains("\n") ||
    value.contains("\r") {
    raise SchemaViolation(
      section="10.1",
      path="ST_Extension",
      reason="extension must be a non-empty package extension token",
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
/// Part name used by CT_Override PartName attributes. Override declarations
/// are the precise content-type lookup path for individual §10.4.2, §10.4.3,
/// and §10.4.4 digital-signature parts.
pub(all) struct PartName {
  value : String
} derive(Eq, Debug)

///|
/// Parse a package part name for an Override rule.
pub fn PartName::parse(value : String) -> PartName raise SchemaViolation {
  if !value.has_prefix("/") {
    raise SchemaViolation(
      section="10.1",
      path="Override/@PartName",
      reason="part name must start with /",
    )
  }
  if value.contains("\\") ||
    value.contains("//") ||
    value.has_suffix("/") ||
    value.contains("/../") ||
    value.contains("/./") {
    raise SchemaViolation(
      section="10.1",
      path="Override/@PartName",
      reason="part name contains a disallowed segment",
    )
  }
  { value, }
}

///|
/// Return the lexical CT_Override PartName value.
pub fn PartName::to_string(self : PartName) -> String {
  self.value
}

///|
/// Default top-level element and CT_Default complex type from the
/// opc-contentTypes Schema Facts inventory.
pub(all) struct Default {
  extension : Extension
  content_type : ContentType
} derive(Eq, Debug)

///|
/// Build CT_Default from validated ST_Extension and ST_ContentType values.
fn Default::new(extension : Extension, content_type : ContentType) -> Default {
  { extension, content_type }
}

///|
/// Override top-level element and CT_Override complex type from the
/// opc-contentTypes Schema Facts inventory.
pub(all) struct Override {
  part_name : PartName
  content_type : ContentType
} derive(Eq, Debug)

///|
/// Build CT_Override from validated PartName and ST_ContentType values.
fn Override::new(part_name : PartName, content_type : ContentType) -> Override {
  { part_name, content_type }
}

///|
/// Rule alternatives allowed inside CT_Types.
pub(all) enum ContentTypeRule {
  Default(Default)
  Override(Override)
} derive(Eq, Debug)

///|
/// Types top-level element and CT_Types complex type from the
/// opc-contentTypes Schema Facts inventory.
pub(all) struct Types {
  rules : Array[ContentTypeRule]
} derive(Eq, Debug)

///|
/// Build CT_Types while preserving declaration order and checking duplicate
/// Default/Override keys.
fn Types::new(rules : Array[ContentTypeRule]) -> Types raise SchemaViolation {
  let extensions : Array[String] = []
  let parts : Array[String] = []
  for rule in rules {
    match rule {
      Default(default) => {
        let key = default.extension.value
        if extensions.contains(key) {
          raise SchemaViolation(
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
          raise SchemaViolation(
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
/// the top-level OPC package uses before dispatching §10 digital-signature
/// parts to payload readers.
pub fn Types::content_type_for_part(
  self : Types,
  part_name : PartName,
) -> ContentType? {
  for rule in self.rules {
    match rule {
      Override(override_rule) =>
        if override_rule.part_name == part_name {
          return Some(override_rule.content_type)
        }
      _ => ()
    }
  }
  let extension = extension_from_part_name(part_name.value)
  match extension {
    Some(extension) =>
      for rule in self.rules {
        match rule {
          Default(default) =>
            if default.extension.value == extension {
              return Some(default.content_type)
            }
          _ => ()
        }
      }
    None => ()
  }
  None
}

///|
/// Validate the §10.4 digital-signature content types that `[Content_Types].xml`
/// must expose before payload markup from §10.5 and the §10.6 relationships
/// transform can be resolved by the owning OPC readers.
pub fn Types::require_digital_signature_content_types(
  self : Types,
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
pub fn Types::require_part_content_type(
  self : Types,
  part_name : PartName,
  expected : ContentType,
  section~ : String,
  path~ : String,
) -> Unit raise {
  match self.content_type_for_part(part_name) {
    Some(actual) =>
      if actual != expected {
        raise SchemaViolation(
          section~,
          path~,
          reason="part content type does not match the required OPC declaration",
        )
      }
    None => raise ResourceMissing(section~, path~, target=part_name.value)
  }
}

///|
/// Content type token for the §10.4.2 Digital Signature Origin part.
pub fn digital_signature_origin_content_type() -> ContentType {
  unsafe_content_type(
    "application/vnd.openxmlformats-package.digital-signature-origin",
  )
}

///|
/// Content type token for the §10.4.3 Digital Signature XML Signature part.
pub fn digital_signature_xml_signature_content_type() -> ContentType {
  unsafe_content_type(
    "application/vnd.openxmlformats-package.digital-signature-xmlsignature+xml",
  )
}

///|
/// Content type token for the §10.4.4 Digital Signature Certificate part.
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
  let mut slash = -1
  for i in 0..<chars.length() {
    if chars[i] == '/' {
      slash = i
    }
  }
  slash > 0 &&
  slash + 1 < value.length() &&
  !value.contains(" ") &&
  !value.contains("\t") &&
  !value.contains("\n") &&
  !value.contains("\r") &&
  !value.contains(";")
}
