// =============================================================================
// `p:sp` shape navigation — Part 1 §19.3.1.43.
//
// The `CT_Placeholder` decoder itself lives in
// `@domain.CT_Placeholder::from_element` (XSD complex type CT_Placeholder
// — Part 1 §19.3.1.36). This file keeps the shape-tree walkers the
// resolver needs (`p:sp/nvSpPr/nvPr/ph`, `cSld/spTree/sp*`, sibling
// accessors for `spPr` / `txBody` / `nvSpPr`).
// =============================================================================

///|
/// Part 1 §19.3.1.43 sp / §19.3.1.36 ph — locate the `p:ph` child of a
/// `p:sp` element and decode it into a `@domain.CT_Placeholder`. Returns
/// `None` for ordinary (non-placeholder) shapes whose `nvSpPr/nvPr/ph`
/// is absent. Raises `SchemaViolation` when an attribute on the `p:ph`
/// element is present but malformed.
pub fn decode_shape_placeholder(
  shape : @xml.Element,
) -> @domain.CT_Placeholder? raise @domain.SchemaViolation {
  match find_shape_ph(shape) {
    Some(element) => Some(@domain.CT_Placeholder::from_element(element))
    None => None
  }
}

///|
/// Part 1 §19.3.1.43 — locate the `nvSpPr/nvPr/ph` descendant of a
/// `p:sp` element. Used by both the decoder and the resolver; returns
/// `None` for ordinary (non-placeholder) shapes.
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
/// Part 1 §19.3.1.5 cSld / §19.3.1.45 spTree — walk
/// `<root>/<cSld>/<spTree>` and return every `p:sp` element. The order
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
/// Part 1 §19.3.1.5 — locate the `p:cSld` element of any slide-like CT
/// (slide, layout, or master). Each carries exactly one `cSld`; absent
/// → None.
pub fn common_slide_data(element : @xml.Element) -> @xml.Element? {
  first_child_by_local_name(element, "cSld")
}

///|
/// Part 1 §19.3.1.44 spPr accessor — returns the `p:spPr` child of a
/// `p:sp` element or `None`.
pub fn shape_sp_pr(shape : @xml.Element) -> @xml.Element? {
  first_child_by_local_name(shape, "spPr")
}

///|
/// Part 1 §19.3.1.51 txBody accessor — returns the `p:txBody` child of
/// a `p:sp` element or `None`. Some shapes carry their text in a sibling
/// `txBody` rather than inside `nvSpPr`, so the lookup is shallow.
pub fn shape_tx_body(shape : @xml.Element) -> @xml.Element? {
  first_child_by_local_name(shape, "txBody")
}

///|
/// Part 1 §19.3.1.34 nvSpPr accessor — returns the `p:nvSpPr` child of
/// a `p:sp` element or `None`. Useful when the resolver wants to expose
/// the non-visual properties wrapper to downstream renderers.
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
