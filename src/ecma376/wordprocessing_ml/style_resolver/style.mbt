///|
/// §17.7 / §17.3 — effective property containers after applying doc defaults,
/// basedOn inheritance, and optional direct formatting overlays. This is an
/// evaluator runtime view with no spec-named XSD type.
pub(all) struct EffectiveProperties {
  p_pr : @xml.Element?
  r_pr : @xml.Element?
  tbl_pr : @xml.Element?
  tr_pr : @xml.Element?
  tc_pr : @xml.Element?
} derive(Eq, Debug)

///|
/// §17.7 / §17.3 — resolve effective style properties by applying doc
/// defaults first, then merging basedOn ancestors outward to the
/// requested style. Operates on `@domain.CT_Styles` (XSD complex type
/// CT_Styles — Part 1 §17.7.4.18) using its typed `<w:style>` children
/// (XSD complex type CT_Style — Part 1 §17.7.4.17).
pub fn effective_properties(
  table : @domain.CT_Styles,
  style_id : @domain.StyleId,
) -> EffectiveProperties {
  let chain = table.resolve_chain(style_id)
  let mut effective = {
    p_pr: table.doc_default_p_pr,
    r_pr: table.doc_default_r_pr,
    tbl_pr: None,
    tr_pr: None,
    tc_pr: None,
  }
  let mut index = chain.length()
  while index > 0 {
    index = index - 1
    let style = chain[index]
    effective = merge_effective(effective, {
      p_pr: style.p_pr,
      r_pr: style.r_pr,
      tbl_pr: style.tbl_pr,
      tr_pr: style.tr_pr,
      tc_pr: style.tc_pr,
    })
  }
  effective
}

///|
/// §17.7 / §17.3 — resolve a paragraph's effective properties by reading
/// `pStyle` from direct `pPr`, applying style inheritance, then
/// overlaying direct pPr (§17.3.1.26).
pub fn resolve_paragraph(
  table : @domain.CT_Styles,
  direct_p_pr : @xml.Element?,
) -> EffectiveProperties {
  let mut effective = empty_effective()
  match direct_p_pr {
    Some(p_pr) =>
      match child_style_id(p_pr, "pStyle") {
        Some(style_id) => {
          effective = effective_properties(table, style_id)
          effective = {
            p_pr: merge_property_element(effective.p_pr, Some(p_pr)),
            r_pr: effective.r_pr,
            tbl_pr: effective.tbl_pr,
            tr_pr: effective.tr_pr,
            tc_pr: effective.tc_pr,
          }
        }
        None =>
          effective = {
            p_pr: merge_property_element(effective.p_pr, Some(p_pr)),
            r_pr: effective.r_pr,
            tbl_pr: effective.tbl_pr,
            tr_pr: effective.tr_pr,
            tc_pr: effective.tc_pr,
          }
      }
    None => ()
  }
  effective
}

///|
/// §17.7 / §17.3 — resolve a run's effective properties by reading
/// `rStyle` from direct `rPr`, applying style inheritance, then
/// overlaying direct rPr (§17.3.2.28).
pub fn resolve_run(
  table : @domain.CT_Styles,
  direct_r_pr : @xml.Element?,
) -> EffectiveProperties {
  let mut effective = empty_effective()
  match direct_r_pr {
    Some(r_pr) =>
      match child_style_id(r_pr, "rStyle") {
        Some(style_id) => {
          effective = effective_properties(table, style_id)
          effective = {
            p_pr: effective.p_pr,
            r_pr: merge_property_element(effective.r_pr, Some(r_pr)),
            tbl_pr: effective.tbl_pr,
            tr_pr: effective.tr_pr,
            tc_pr: effective.tc_pr,
          }
        }
        None =>
          effective = {
            p_pr: effective.p_pr,
            r_pr: merge_property_element(effective.r_pr, Some(r_pr)),
            tbl_pr: effective.tbl_pr,
            tr_pr: effective.tr_pr,
            tc_pr: effective.tc_pr,
          }
      }
    None => ()
  }
  effective
}

///|
fn empty_effective() -> EffectiveProperties {
  { p_pr: None, r_pr: None, tbl_pr: None, tr_pr: None, tc_pr: None }
}

///|
fn merge_effective(
  base : EffectiveProperties,
  derived : EffectiveProperties,
) -> EffectiveProperties {
  {
    p_pr: merge_property_element(base.p_pr, derived.p_pr),
    r_pr: merge_property_element(base.r_pr, derived.r_pr),
    tbl_pr: merge_property_element(base.tbl_pr, derived.tbl_pr),
    tr_pr: merge_property_element(base.tr_pr, derived.tr_pr),
    tc_pr: merge_property_element(base.tc_pr, derived.tc_pr),
  }
}

///|
fn merge_property_element(
  base : @xml.Element?,
  derived : @xml.Element?,
) -> @xml.Element? {
  match (base, derived) {
    (None, None) => None
    (Some(base_element), None) => Some(base_element)
    (None, Some(derived_element)) => Some(derived_element)
    (Some(base_element), Some(derived_element)) =>
      Some(merge_property_element_unchecked(base_element, derived_element))
  }
}

///|
fn merge_property_element_unchecked(
  base : @xml.Element,
  derived : @xml.Element,
) -> @xml.Element {
  let overridden : @hashmap.HashMap[String, Bool] = @hashmap.new()
  let children : Array[@xml.Node] = []
  for node in derived.children {
    match node {
      @xml.Element(child) => overridden.set(child.name.local_name, true)
      _ => ()
    }
  }
  for node in base.children {
    match node {
      @xml.Element(child) =>
        if !overridden.contains(child.name.local_name) {
          children.push(node)
        }
      _ => children.push(node)
    }
  }
  for node in derived.children {
    children.push(node)
  }
  { name: base.name, attributes: base.attributes, children }
}

///|
fn child_style_id(
  element : @xml.Element,
  child_name : String,
) -> @domain.StyleId? {
  match child_val(element, child_name) {
    Some(value) => Some({ value, })
    None => None
  }
}

///|
fn child_val(element : @xml.Element, child_name : String) -> String? {
  match child_element(element, child_name) {
    Some(child) => attr_value(child, "val")
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
