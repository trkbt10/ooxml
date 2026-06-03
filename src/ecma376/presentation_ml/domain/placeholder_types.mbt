// =============================================================================
// XSD complex type CT_Placeholder — Part 1 §19.3.1.36 (pml.xsd).
//
// `p:ph` shape attributes resolved into a typed view. Every attribute is
// optional per §19.3.1.36; absent attributes leave the corresponding
// field as `None`. The typed view uses the §19.7.10 ST_PlaceholderType,
// §19.7.9 ST_PlaceholderSize, and §19.7.2 ST_Direction simple types from
// `simple_types.mbt` rather than re-declaring lexical-form enums.
// =============================================================================

///|
/// Section anchor for §19.3.1.36 ph diagnostics. Exposed so callers can
/// emit the canonical citation in their own error messages.
let ct_placeholder_section : String = "Part 1 §19.3.1.36"

///|
/// Part 1 §19.3.1.36 — citation helper returning the canonical anchor
/// string "Part 1 §19.3.1.36".
pub fn ct_placeholder_section_name() -> String {
  ct_placeholder_section
}

///|
/// XSD complex type CT_Placeholder — Part 1 §19.3.1.36 ph. Holds the
/// typed shape of the `p:ph` element: `idx` is the optional
/// xsd:unsignedInt placeholder index (§19.3.1.36), `ph_type` is the
/// optional §19.7.10 ST_PlaceholderType content discriminator, `size`
/// is the optional §19.7.9 ST_PlaceholderSize modifier, `orient` is
/// the optional §19.7.2 ST_Direction modifier, and `has_custom_prompt`
/// is the §19.3.1.36 xsd:boolean (default false).
pub(all) struct CT_Placeholder {
  idx : Int?
  ph_type : ST_PlaceholderType?
  size : ST_PlaceholderSize?
  orient : ST_Direction?
  has_custom_prompt : Bool
} derive(Eq, Debug)

///|
/// Part 1 §19.3.1.36 — true when every attribute is at its schema
/// default (no idx, no type, no size, no orient, no custom prompt).
/// Useful for renderers that want to skip emitting a `<ph/>` element
/// when nothing distinguishes the shape.
pub fn CT_Placeholder::is_default(self : CT_Placeholder) -> Bool {
  if self.idx is Some(_) {
    return false
  }
  if self.ph_type is Some(_) {
    return false
  }
  if self.size is Some(_) {
    return false
  }
  if self.orient is Some(_) {
    return false
  }
  if self.has_custom_prompt {
    return false
  }
  true
}

///|
/// Part 1 §19.3.1.36 — decode a `p:ph` element into a typed
/// `CT_Placeholder`. Every attribute is optional; absent attributes
/// leave the corresponding field as `None`. Raises `SchemaViolation`
/// when an attribute is present but malformed (e.g. non-numeric `@idx`,
/// or a §19.7.10 lexical value not in the spec table).
pub fn CT_Placeholder::from_element(
  element : @xml.Element,
) -> CT_Placeholder raise SchemaViolation {
  let idx = match ct_placeholder_attr(element, "idx") {
    Some(text) =>
      match parse_xsd_unsigned_int(text) {
        Some(n) =>
          // §19.3.1.36 @idx is xsd:unsignedInt; downstream stores Int
          // for compatibility with existing shape-tree consumers. The
          // typed range check below mirrors that contract.
          if n > 2147483647U {
            invalid_simple_type("ST_Index", text, "outside Int range (>= 2^31)")
          } else {
            Some(n.reinterpret_as_int())
          }
        None =>
          invalid_simple_type(
            "ST_Index", text, "malformed xsd:unsignedInt (§19.3.1.36 @idx)",
          )
      }
    None => None
  }
  let ph_type = match ct_placeholder_attr(element, "type") {
    Some(text) => Some(ST_PlaceholderType::parse(text))
    None => None
  }
  let size = match ct_placeholder_attr(element, "sz") {
    Some(text) => Some(ST_PlaceholderSize::parse(text))
    None => None
  }
  let orient = match ct_placeholder_attr(element, "orient") {
    Some(text) => Some(ST_Direction::parse(text))
    None => None
  }
  let has_custom_prompt = match
    ct_placeholder_attr(element, "hasCustomPrompt") {
    Some("1") => true
    Some("true") => true
    Some("0") => false
    Some("false") => false
    Some(text) =>
      invalid_simple_type(
        "CT_Placeholder/@hasCustomPrompt", text, "expected xsd:boolean",
      )
    None => false
  }
  { idx, ph_type, size, orient, has_custom_prompt }
}

///|
/// First attribute on `element` whose local name equals `local_name`.
/// `p:ph` attributes are always in the no-namespace XSD `attributeForm`
/// per pml.xsd, so a local-name lookup suffices.
fn ct_placeholder_attr(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}
