///|
/// Part 1 §19.3.1.36 ph — decode a CT_Placeholder XML element into the
/// typed `Placeholder` struct. Every attribute is optional; absent
/// attributes leave the corresponding field as `None`.
pub fn decode_placeholder(
  ph : @domain.CT_Placeholder,
) -> Placeholder raise @opc_errors.SchemaViolation {
  decode_placeholder_element(ph.element)
}

///|
/// Decode a raw `p:ph` element. Exposed so callers that already hold
/// the underlying element (e.g. while walking the shape tree) avoid a
/// `CT_Placeholder::new` round-trip.
pub fn decode_placeholder_element(
  element : @xml.Element,
) -> Placeholder raise @opc_errors.SchemaViolation {
  let idx = match attr(element, "idx") {
    Some(text) =>
      match parse_unsigned_int(text) {
        Some(n) => Some(n)
        None =>
          raise @opc_errors.SchemaViolation(
            section=placeholder_section,
            path="ph/@idx",
            reason="malformed unsignedInt: " + text,
          )
      }
    None => None
  }
  let ph_type = match attr(element, "type") {
    Some(text) => Some(PlaceholderType::from_attr(text))
    None => None
  }
  let size = match attr(element, "sz") {
    Some(text) => Some(PlaceholderSize::from_attr(text))
    None => None
  }
  let orient = match attr(element, "orient") {
    Some(text) => Some(PlaceholderOrient::from_attr(text))
    None => None
  }
  let has_custom_prompt = match attr(element, "hasCustomPrompt") {
    Some("1") => true
    Some("true") => true
    _ => false
  }
  { idx, ph_type, size, orient, has_custom_prompt }
}

///|
/// Part 1 §19.3.1.43 sp / §19.3.1.36 ph — look up the `p:ph` child of
/// a `p:sp` element. The path is `sp/nvSpPr/nvPr/ph`; missing
/// intermediate elements yield `None`.
pub fn decode_shape_placeholder(
  shape : @xml.Element,
) -> Placeholder? raise @opc_errors.SchemaViolation {
  match find_shape_ph(shape) {
    Some(element) => Some(decode_placeholder_element(element))
    None => None
  }
}

///|
/// Locate the `nvSpPr/nvPr/ph` descendant of a `p:sp` element. Used by
/// both the decoder and the resolver; returns `None` for ordinary
/// (non-placeholder) shapes.
pub fn find_shape_ph(shape : @xml.Element) -> @xml.Element? {
  let nv_sp_pr = first_child_by_local_name(shape, "nvSpPr")
  match nv_sp_pr {
    Some(nv) => {
      let nv_pr = first_child_by_local_name(nv, "nvPr")
      match nv_pr {
        Some(np) => first_child_by_local_name(np, "ph")
        None => None
      }
    }
    None => None
  }
}

///|
/// Walk a `p:cSld/p:spTree` and return every `p:sp` element. The order
/// matches document order so callers can correlate by index when no
/// `idx` attribute is present.
pub fn shape_tree_shapes(
  common_slide_data : @xml.Element,
) -> Array[@xml.Element] {
  let result : Array[@xml.Element] = []
  match first_child_by_local_name(common_slide_data, "spTree") {
    Some(sp_tree) =>
      for child in sp_tree.children {
        match child {
          @xml.Element(element) =>
            if element.name.local_name == "sp" {
              result.push(element)
            }
          _ => ()
        }
      }
    None => ()
  }
  result
}

///|
/// Locate the `p:cSld` element of any slide-like CT (slide, layout,
/// or master). Each carries exactly one cSld; absent → None.
pub fn common_slide_data(element : @xml.Element) -> @xml.Element? {
  first_child_by_local_name(element, "cSld")
}

///|
/// `spPr` accessor for a shape — returns the `p:spPr` child or `None`.
pub fn shape_sp_pr(shape : @xml.Element) -> @xml.Element? {
  first_child_by_local_name(shape, "spPr")
}

///|
/// `txBody` accessor for a shape — returns the `p:txBody` child or
/// `None`. Some shapes carry their text in a sibling `txBody` rather
/// than inside `nvSpPr`, so the lookup is shallow.
pub fn shape_tx_body(shape : @xml.Element) -> @xml.Element? {
  first_child_by_local_name(shape, "txBody")
}

///|
/// `nvSpPr` accessor for a shape — returns the `p:nvSpPr` child or
/// `None`. Useful when the resolver wants to expose the non-visual
/// properties wrapper to downstream renderers.
pub fn shape_nv_sp_pr(shape : @xml.Element) -> @xml.Element? {
  first_child_by_local_name(shape, "nvSpPr")
}

///|
fn first_child_by_local_name(
  parent : @xml.Element,
  name : String,
) -> @xml.Element? {
  for child in parent.children {
    match child {
      @xml.Element(element) =>
        if element.name.local_name == name {
          return Some(element)
        }
      _ => ()
    }
  }
  None
}

///|
fn attr(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
fn parse_unsigned_int(text : String) -> Int? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  let mut value = 0
  for i in 0..<trimmed.length() {
    let unit = trimmed.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10 + (unit - 0x30)
  }
  Some(value)
}

///|
fn trim_whitespace(text : String) -> String {
  let mut start = 0
  while start < text.length() {
    let unit = text.code_unit_at(start).to_int()
    if unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D {
      break
    }
    start = start + 1
  }
  let mut end = text.length()
  while end > start {
    let unit = text.code_unit_at(end - 1).to_int()
    if unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D {
      break
    }
    end = end - 1
  }
  text.unsafe_substring(start~, end~)
}
