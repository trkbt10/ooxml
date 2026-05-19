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
pub fn Extension::parse(
  value : String,
) -> Extension raise @opc_errors.SchemaViolation {
  if value == "" ||
    value.contains("/") ||
    value.contains("\\") ||
    value.contains(".") ||
    value.contains(" ") ||
    value.contains("\t") ||
    value.contains("\n") ||
    value.contains("\r") {
    raise @opc_errors.SchemaViolation(
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
