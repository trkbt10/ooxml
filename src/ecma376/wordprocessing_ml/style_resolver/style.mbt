///|
/// §17.7 / §17.3 — typed style identifier for the `w:styleId` attribute on
/// `<w:style>`. It is equivalent to an unqualified XML token in the style table.
pub(all) struct StyleId {
  value : String
} derive(Eq, Debug)

///|
/// §17.7 / §17.3 — WordprocessingML style family discriminator used by the
/// style inheritance resolver.
pub(all) enum StyleType {
  Paragraph
  Character
  Table
  Numbering
} derive(Eq, Debug)

///|
/// §17.7 / §17.3 — extracted style metadata and direct property containers.
/// The property fields preserve raw §17.3 XML property elements for merging.
pub(all) struct Style {
  style_id : StyleId
  style_type : StyleType
  name : String?
  based_on : StyleId?
  next : StyleId?
  linked_to : StyleId?
  is_default : Bool
  p_pr : @xml.Element?
  r_pr : @xml.Element?
  tbl_pr : @xml.Element?
  tr_pr : @xml.Element?
  tc_pr : @xml.Element?
} derive(Eq, Debug)

///|
/// §17.7 / §17.3 — typed style table extracted from a `CT_Styles` element.
/// The map is keyed by `StyleId.value`; doc defaults are the implicit base.
pub(all) struct StyleTable {
  styles : @hashmap.HashMap[String, Style]
  doc_default_p_pr : @xml.Element?
  doc_default_r_pr : @xml.Element?
}

///|
/// §17.7 / §17.3 — effective property containers after applying doc defaults,
/// basedOn inheritance, and optional direct formatting overlays.
pub(all) struct EffectiveProperties {
  p_pr : @xml.Element?
  r_pr : @xml.Element?
  tbl_pr : @xml.Element?
  tr_pr : @xml.Element?
  tc_pr : @xml.Element?
} derive(Eq, Debug)

///|
/// §17.7 / §17.3 — extract a typed `Style` view from a raw `<w:style>`
/// element, validating the required style id and known style type values.
pub fn Style::from_element(
  element : @xml.Element,
) -> Style raise @opc_errors.SchemaViolation {
  require_local_name(element, "style", path="/w:style")
  let style_id = match attr_value(element, "styleId") {
    Some(value) => { value, }
    None =>
      raise @opc_errors.SchemaViolation(
        section="ECMA-376 Part 1 §17.7",
        path="/w:style/@w:styleId",
        reason="styleId is required",
      )
  }
  let style_type = parse_style_type(attr_value(element, "type"), style_id.value)
  let is_default = parse_on_off(attr_value(element, "default"))
  let name = child_val(element, "name")
  let based_on = child_style_id(element, "basedOn")
  let next = child_style_id(element, "next")
  let linked_to = first_child_val(element, ["link", "linkedTo"])
  let p_pr = child_element(element, "pPr")
  let r_pr = child_element(element, "rPr")
  let tbl_pr = child_element(element, "tblPr")
  let tr_pr = child_element(element, "trPr")
  let tc_pr = child_element(element, "tcPr")
  {
    style_id,
    style_type,
    name,
    based_on,
    next,
    linked_to,
    is_default,
    p_pr,
    r_pr,
    tbl_pr,
    tr_pr,
    tc_pr,
  }
}

///|
/// §17.7 / §17.3 — extract a `StyleTable` from a raw `CT_Styles`/`<w:styles>`
/// element, indexing style children and capturing optional doc defaults.
pub fn StyleTable::from_element(
  element : @xml.Element,
) -> StyleTable raise @opc_errors.SchemaViolation {
  require_local_name(element, "styles", path="/w:styles")
  let styles : @hashmap.HashMap[String, Style] = @hashmap.new()
  let mut doc_default_p_pr : @xml.Element? = None
  let mut doc_default_r_pr : @xml.Element? = None
  for node in element.children {
    match node {
      @xml.Element(child) =>
        if child.name.local_name == "style" {
          let style = Style::from_element(child)
          styles.set(style.style_id.value, style)
        } else if child.name.local_name == "docDefaults" {
          doc_default_p_pr = doc_default_property(child, "pPrDefault", "pPr")
          doc_default_r_pr = doc_default_property(child, "rPrDefault", "rPr")
        }
      _ => ()
    }
  }
  { styles, doc_default_p_pr, doc_default_r_pr }
}

///|
/// §17.7 / §17.3 — extract a `StyleTable` from the WordprocessingML `CT_Styles`
/// domain wrapper by walking its preserved raw XML element.
pub fn StyleTable::from_ct_styles(
  styles : @domain.CT_Styles,
) -> StyleTable raise @opc_errors.SchemaViolation {
  StyleTable::from_element(styles.to_element())
}

///|
/// §17.7 / §17.3 — return the basedOn chain for `style_id` from most-derived
/// to root, stopping at missing parents and breaking cycles with a visited map.
pub fn StyleTable::resolve_chain(
  self : StyleTable,
  style_id : StyleId,
) -> Array[Style] {
  let chain : Array[Style] = []
  let visited : @hashmap.HashMap[String, Bool] = @hashmap.new()
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
/// §17.7 / §17.3 — resolve effective style properties by applying doc defaults
/// first, then merging basedOn ancestors outward to the requested style.
pub fn StyleTable::effective_properties(
  self : StyleTable,
  style_id : StyleId,
) -> EffectiveProperties {
  let chain = self.resolve_chain(style_id)
  let mut effective = {
    p_pr: self.doc_default_p_pr,
    r_pr: self.doc_default_r_pr,
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
/// `pStyle` from direct `pPr`, applying style inheritance, then overlaying pPr.
pub fn StyleTable::resolve_paragraph(
  self : StyleTable,
  direct_p_pr : @xml.Element?,
) -> EffectiveProperties {
  let mut effective = empty_effective()
  match direct_p_pr {
    Some(p_pr) =>
      match child_style_id(p_pr, "pStyle") {
        Some(style_id) => {
          effective = self.effective_properties(style_id)
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
/// §17.7 / §17.3 — resolve a run's effective properties by reading `rStyle`
/// from direct `rPr`, applying style inheritance, then overlaying direct rPr.
pub fn StyleTable::resolve_run(
  self : StyleTable,
  direct_r_pr : @xml.Element?,
) -> EffectiveProperties {
  let mut effective = empty_effective()
  match direct_r_pr {
    Some(r_pr) =>
      match child_style_id(r_pr, "rStyle") {
        Some(style_id) => {
          effective = self.effective_properties(style_id)
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
fn require_local_name(
  element : @xml.Element,
  expected : String,
  path~ : String,
) -> Unit raise @opc_errors.SchemaViolation {
  if element.name.local_name != expected {
    raise @opc_errors.SchemaViolation(
      section="ECMA-376 Part 1 §17.7",
      path~,
      reason="expected <w:\{expected}>",
    )
  }
}

///|
fn parse_style_type(
  value : String?,
  style_id : String,
) -> StyleType raise @opc_errors.SchemaViolation {
  match value {
    Some("paragraph") => Paragraph
    Some("character") => Character
    Some("table") => Table
    Some("numbering") => Numbering
    Some(other) =>
      raise @opc_errors.SchemaViolation(
        section="ECMA-376 Part 1 §17.7",
        path="/w:style[@w:styleId='\{style_id}']/@w:type",
        reason="unknown style type '\{other}'",
      )
    None =>
      raise @opc_errors.SchemaViolation(
        section="ECMA-376 Part 1 §17.7",
        path="/w:style[@w:styleId='\{style_id}']/@w:type",
        reason="style type is required",
      )
  }
}

///|
fn parse_on_off(value : String?) -> Bool {
  match value {
    Some("1") | Some("true") | Some("on") => true
    _ => false
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
fn child_val(element : @xml.Element, child_name : String) -> String? {
  match child_element(element, child_name) {
    Some(child) => attr_value(child, "val")
    None => None
  }
}

///|
fn first_child_val(element : @xml.Element, names : Array[String]) -> StyleId? {
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
