// trkbt10/ooxml/ecma376/wordprocessing_ml/domain — style typed view
//
// Typed projection of the WordprocessingML style table that the
// `style_resolver` package consumes when computing effective formatting.
// The XSD complex types live here because §17.7 (Style Definitions Part)
// requires the implementation to carry the same names as the spec.

///|
/// §17.3.1 — typed style identifier for the `w:styleId` attribute on
/// `<w:style>`. The attribute is an xsd:string (CT_String / ST_String)
/// but the resolver gives it nominal identity for chain lookup.
pub(all) struct StyleId {
  value : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Style — ECMA-376 Part 1 §17.7.4.17 (style).
/// Typed projection of the `<w:style>` element exposing the metadata the
/// resolver needs (styleId, type, basedOn chain, link, defaults) plus the
/// raw property element fragments referenced by §17.3.1 (pPr / rPr /
/// tblPr / trPr / tcPr). `element` is preserved so round-trips through
/// the writer keep XSD content the typed view does not yet model.
///
/// `style_id` and `style_type` are both `Option` because the XSD declares
/// `@w:styleId` and `@w:type` with `use="optional"` (§17.7.4.17). When
/// absent, the style still round-trips through `element` but cannot be
/// looked up by id (no styleId) or used as a style-family discriminator
/// (no type). Such an entry contributes nothing to chain resolution.
pub(all) struct CT_Style {
  style_id : StyleId?
  style_type : ST_StyleType?
  name : String?
  based_on : StyleId?
  next : StyleId?
  linked_to : StyleId?
  is_default : Bool
  /// §17.7.4.17 `@customStyle` — user-defined (not built-in) style;
  /// default false.
  custom_style : Bool
  p_pr : @xml.Element?
  r_pr : @xml.Element?
  tbl_pr : @xml.Element?
  tr_pr : @xml.Element?
  tc_pr : @xml.Element?
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Style from its WordprocessingML XML element while
/// validating the `w:type` enumeration value (ST_StyleType — §17.18.83)
/// when present. `w:styleId` and `w:type` are both optional per the XSD
/// (§17.7.4.17).
pub fn CT_Style::new(element : @xml.Element) -> CT_Style raise SchemaViolation {
  CT_Style::parse(element)
}

///|
/// Parse CT_Style, raising SchemaViolation only when the typed contract
/// of §17.7.4.17 / §17.18.83 is broken (unknown ST_StyleType lexical
/// value). Both `@w:styleId` and `@w:type` are `use="optional"` per the
/// XSD, so a missing attribute yields `None` rather than an error.
pub fn CT_Style::parse(
  element : @xml.Element,
) -> CT_Style raise SchemaViolation {
  require_local_name(element, "style")
  let style_id : StyleId? = match attr_value(element, "styleId") {
    Some(value) => Some({ value, })
    None => None
  }
  let style_type = parse_style_type(attr_value(element, "type"))
  let is_default = parse_on_off(attr_value(element, "default"))
  let custom_style = parse_on_off(attr_value(element, "customStyle"))
  let name = child_val(element, "name")
  let based_on = child_style_id(element, "basedOn")
  let next = child_style_id(element, "next")
  let linked_to = first_child_style_id(element, ["link", "linkedTo"])
  let p_pr = child_element(element, "pPr")
  let r_pr = child_element(element, "rPr")
  let tbl_pr = child_element(element, "tblPr")
  let tr_pr = child_element(element, "trPr")
  let tc_pr = child_element(element, "tcPr")
  {
    element,
    style_id,
    style_type,
    name,
    based_on,
    next,
    linked_to,
    is_default,
    custom_style,
    p_pr,
    r_pr,
    tbl_pr,
    tr_pr,
    tc_pr,
  }
}

///|
/// Return the preserved `<w:style>` XML element for round-tripping
/// through the WordprocessingML writer.
pub fn CT_Style::to_element(self : CT_Style) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Styles — ECMA-376 Part 1 §17.7.4.18 (styles),
/// the root of the Style Definitions Part (§11.3.12). The typed view
/// indexes child `<w:style>` elements by styleId and captures the
/// optional `<w:docDefaults>` paragraph/run property containers used by
/// the §17.7.1 style inheritance algorithm.
pub(all) struct CT_Styles {
  styles : @hashmap.HashMap[String, CT_Style]
  doc_default_p_pr : @xml.Element?
  doc_default_r_pr : @xml.Element?
  element : @xml.Element
}

///|
/// CT_Styles equality compares the preserved element only — the
/// `styles` hashmap is a derived projection that is fully determined by
/// the element content, so element equality implies structural equality
/// without requiring a HashMap Eq impl.
pub impl Eq for CT_Styles with fn equal(self, other) {
  self.element == other.element
}

///|
/// CT_Styles Debug delegates to the preserved element representation.
/// The styles hashmap is a parse-derived projection of the same element
/// and would otherwise force consumers to provide a HashMap Debug impl.
pub impl @debug.Debug for CT_Styles with fn to_repr(self) {
  @debug.Repr::opaque_("CT_Styles", @debug.to_repr(self.element))
}

///|
/// Construct CT_Styles by walking the `<w:styles>` element, parsing each
/// `<w:style>` child as CT_Style and capturing the `<w:docDefaults>`
/// containers (§17.7.5.4 / §17.7.5.5).
pub fn CT_Styles::new(
  element : @xml.Element,
) -> CT_Styles raise SchemaViolation {
  CT_Styles::parse(element)
}

///|
/// Parse CT_Styles, raising SchemaViolation if the root element is not
/// `<w:styles>` or any child `<w:style>` fails CT_Style validation.
pub fn CT_Styles::parse(
  element : @xml.Element,
) -> CT_Styles raise SchemaViolation {
  require_local_name(element, "styles")
  let styles : @hashmap.HashMap[String, CT_Style] = @hashmap.HashMap(
    [],
    capacity=0,
  )
  let mut doc_default_p_pr : @xml.Element? = None
  let mut doc_default_r_pr : @xml.Element? = None
  for node in element.children {
    match node {
      @xml.Element(child) =>
        if child.name.local_name == "style" {
          let style = CT_Style::parse(child)
          // Only index styles that carry @w:styleId. The XSD declares
          // the attribute optional (§17.7.4.17); when omitted the style
          // is still preserved via `element` round-trip but cannot be
          // looked up by id.
          match style.style_id {
            Some(id) => styles.set(id.value, style)
            None => ()
          }
        } else if child.name.local_name == "docDefaults" {
          doc_default_p_pr = doc_default_property(child, "pPrDefault", "pPr")
          doc_default_r_pr = doc_default_property(child, "rPrDefault", "rPr")
        }
      _ => ()
    }
  }
  { element, styles, doc_default_p_pr, doc_default_r_pr }
}

///|
/// Return the preserved `<w:styles>` XML element for round-tripping
/// through the WordprocessingML writer.
pub fn CT_Styles::to_element(self : CT_Styles) -> @xml.Element {
  self.element
}

///|
/// Resolve the basedOn chain (§17.7.4.3) for `style_id` from most-
/// derived to root, stopping at missing parents and breaking cycles
/// with a visited map (cycles are tolerated to mirror consumer leniency
/// described by §17.7.2).
pub fn CT_Styles::resolve_chain(
  self : CT_Styles,
  style_id : StyleId,
) -> Array[CT_Style] {
  let chain : Array[CT_Style] = []
  let visited : @hashmap.HashMap[String, Bool] = @hashmap.HashMap(
    [],
    capacity=0,
  )
  let mut current = style_id
  let mut keep_going = true
  while keep_going {
    if visited.contains(current.value) {
      keep_going = false
    } else {
      match self.styles.get(current.value) {
        Some(style) => {
          chain.push(style)
          visited.set(current.value, true)
          match style.based_on {
            Some(parent) => current = parent
            None => keep_going = false
          }
        }
        None => keep_going = false
      }
    }
  }
  chain
}

///|
fn require_local_name(
  element : @xml.Element,
  expected : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != expected {
    raise_schema_violation(
      "CT_Style",
      element.name.local_name,
      "expected <w:\{expected}>",
    )
  }
}

///|
fn parse_style_type(value : String?) -> ST_StyleType? raise SchemaViolation {
  match value {
    Some(lexical) => Some(ST_StyleType::parse(lexical))
    None => None
  }
}

///|
fn parse_on_off(value : String?) -> Bool {
  match value {
    Some(lexical) =>
      try wml_st_on_off(lexical) catch {
        _ => false
      } noraise {
        parsed => parsed
      }
    None => false
  }
}

///|
fn child_style_id(element : @xml.Element, child_name : String) -> StyleId? {
  match child_val(element, child_name) {
    Some(value) => Some({ value, })
    None => None
  }
}

///|
fn first_child_style_id(
  element : @xml.Element,
  names : Array[String],
) -> StyleId? {
  let mut result : StyleId? = None
  for name in names {
    if result is None {
      match child_val(element, name) {
        Some(value) => result = Some({ value, })
        None => ()
      }
    }
  }
  result
}

///|
fn child_val(element : @xml.Element, child_name : String) -> String? {
  match child_element(element, child_name) {
    Some(child) => attr_value(child, "val")
    None => None
  }
}

///|
fn doc_default_property(
  doc_defaults : @xml.Element,
  default_name : String,
  property_name : String,
) -> @xml.Element? {
  match child_element(doc_defaults, default_name) {
    Some(default_element) => child_element(default_element, property_name)
    None => None
  }
}

///|
fn child_element(element : @xml.Element, local_name : String) -> @xml.Element? {
  let mut found : @xml.Element? = None
  for node in element.children {
    if found is None {
      match node {
        @xml.Element(child) =>
          if child.name.local_name == local_name {
            found = Some(child)
          }
        _ => ()
      }
    }
  }
  found
}

///|
fn attr_value(element : @xml.Element, local_name : String) -> String? {
  let mut found : String? = None
  for attr in element.attributes {
    if found is None && attr.name.local_name == local_name {
      found = Some(attr.value)
    }
  }
  found
}
