///|
/// Part 1 §20.1.9.18 prstGeom — decode a `prstGeom` XML element into
/// the typed `PresetGeometry`. The decoder reads the required `@prst`
/// attribute (§20.1.10.56) and the optional `avLst/gd` children
/// (§20.1.9.5 / §20.1.9.11), preserving every adjustment override in
/// document order so renderers can apply them later.
pub fn decode_preset_geometry(
  element : @xml.Element,
) -> PresetGeometry raise @opc_errors.SchemaViolation {
  let prst_value = match attr(element, "prst") {
    Some(text) => trim_whitespace(text)
    None =>
      raise @opc_errors.SchemaViolation(
        section=preset_shape_section,
        path="prstGeom/@prst",
        reason="required prst attribute is missing",
      )
  }
  if prst_value.length() == 0 {
    raise @opc_errors.SchemaViolation(
      section=preset_shape_section,
      path="prstGeom/@prst",
      reason="prst attribute is empty",
    )
  }
  let shape = PresetShape::from_attr(prst_value)
  let adjustments : Array[Adjustment] = []
  match first_child_by_local_name(element, "avLst") {
    Some(av) =>
      for child in av.children {
        match child {
          @xml.Element(gd) =>
            if gd.name.local_name == "gd" {
              adjustments.push(decode_adjustment(gd))
            }
          _ => ()
        }
      }
    None => ()
  }
  { shape, adjustments }
}

///|
/// Part 1 §20.1.9.11 gd — decode a single adjustment guide element.
/// Both `@name` and `@fmla` are required by the schema; missing
/// attributes raise `SchemaViolation`. The decoder additionally parses
/// the `val n` formula syntax into a typed `Int?` so callers can
/// short-circuit the common case without re-parsing the formula
/// string.
pub fn decode_adjustment(
  element : @xml.Element,
) -> Adjustment raise @opc_errors.SchemaViolation {
  let name = match attr(element, "name") {
    Some(text) => text
    None =>
      raise @opc_errors.SchemaViolation(
        section=preset_shape_section,
        path="avLst/gd/@name",
        reason="required name attribute is missing",
      )
  }
  let raw_formula = match attr(element, "fmla") {
    Some(text) => text
    None =>
      raise @opc_errors.SchemaViolation(
        section=preset_shape_section,
        path="avLst/gd/@fmla",
        reason="required fmla attribute is missing",
      )
  }
  let value = parse_val_formula(raw_formula)
  { name, raw_formula, value }
}

///|
/// Parse the `val n` form of the §20.1.9.11 formula syntax. The
/// canonical preset shape definitions only ever supply `val`-form
/// formulas in their `avLst` overrides; any other form (e.g. `*/ h 2
/// 3` or `pin 0 adj 21600`) yields `None` so renderers can decide
/// whether to evaluate it or fall back to the preset default.
pub fn parse_val_formula(formula : String) -> Int? {
  let trimmed = trim_whitespace(formula)
  let prefix = "val "
  if !starts_with(trimmed, prefix) {
    return None
  }
  let tail = trimmed.unsafe_substring(
    start=prefix.length(),
    end=trimmed.length(),
  )
  parse_signed_int(trim_whitespace(tail))
}

///|
fn starts_with(text : String, prefix : String) -> Bool {
  if text.length() < prefix.length() {
    return false
  }
  for i in 0..<prefix.length() {
    if text.code_unit_at(i) != prefix.code_unit_at(i) {
      return false
    }
  }
  true
}

///|
fn parse_signed_int(text : String) -> Int? {
  if text.length() == 0 {
    return None
  }
  let mut idx = 0
  let mut sign = 1
  let first = text.code_unit_at(0).to_int()
  if first == 0x2D {
    sign = -1
    idx = 1
  } else if first == 0x2B {
    idx = 1
  }
  if idx == text.length() {
    return None
  }
  let mut value = 0
  while idx < text.length() {
    let unit = text.code_unit_at(idx).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10 + (unit - 0x30)
    idx = idx + 1
  }
  Some(sign * value)
}

///|
fn first_child_by_local_name(
  parent : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in parent.children {
    match child {
      @xml.Element(element) =>
        if element.name.local_name == local_name {
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
