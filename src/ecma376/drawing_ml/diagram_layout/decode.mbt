///|
/// Part 1 §21.4.2.16 layoutDef — decode a `CT_DiagramDefinition`
/// element wrapper into a typed `DiagramDefinition`. The decoder
/// reads the three top-level attributes (`uniqueId`, `minVer`,
/// `defStyle`) and walks the first `layoutNode` child as the
/// definition root. A missing root `layoutNode` raises
/// `SchemaViolation` since the schema's `CT_DiagramDefinition`
/// makes `layoutNode` required (`minOccurs = 1`).
pub fn decode_diagram_definition(
  definition : @domain.CT_DiagramDefinition,
) -> DiagramDefinition raise @opc_errors.SchemaViolation {
  let element = definition.element
  let unique_id = attribute(element, "uniqueId")
  let min_ver = attribute(element, "minVer")
  let def_style = attribute(element, "defStyle")
  match first_child_by_local_name(element, "layoutNode") {
    None =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path="layoutDef/layoutNode",
        reason="layoutDef must contain at least one layoutNode child",
      )
    Some(root_element) => {
      let root = decode_layout_node(root_element)
      { unique_id, min_ver, def_style, root }
    }
  }
}

///|
/// Part 1 §21.4.2.19 layoutNode — decode a `layoutNode` XML
/// element into a typed `LayoutNode`. Child elements are walked
/// in document order so `forEach` iteration mirrors the source
/// XML; this matters because `forEach` is dispatched once per
/// data-model point and the order influences `presOf` output.
pub fn decode_layout_node(
  element : @xml.Element,
) -> LayoutNode raise @opc_errors.SchemaViolation {
  let name = match attribute(element, "name") {
    Some(value) => value
    None => ""
  }
  let style_lbl = attribute(element, "styleLbl")
  let ch_order = attribute(element, "chOrder")
  let mut algorithm : Algorithm? = None
  let mut shape : Shape? = None
  let mut pres_of : PresOfSpec? = None
  let constraints : Array[Constraint] = []
  let children : Array[LayoutChild] = []
  for child in element.children {
    match child {
      @xml.Element(node) => {
        let local = node.name.local_name
        if local == "alg" {
          algorithm = Some(decode_algorithm(node))
        } else if local == "shape" {
          shape = Some(decode_shape(node))
        } else if local == "presOf" {
          pres_of = Some(decode_pres_of(node))
        } else if local == "constrLst" {
          decode_constraint_list(node, constraints)
        } else if local == "layoutNode" {
          children.push(LcNode(decode_layout_node(node)))
        } else if local == "choose" {
          children.push(LcChoose(decode_choose(node)))
        } else if local == "forEach" {
          children.push(LcForEach(decode_for_each(node)))
        }
      }
      _ => ()
    }
  }
  {
    name,
    style_lbl,
    ch_order,
    algorithm,
    shape,
    pres_of,
    constraints,
    children,
  }
}

///|
/// Part 1 §21.4.2.3 alg — decode an `alg` element. The required
/// `@type` attribute selects the algorithm; missing or invalid
/// values raise `SchemaViolation` because `lin` fallback (per
/// Requirement 13) only kicks in for non-canonical *enum* values,
/// not for missing attributes.
pub fn decode_algorithm(
  element : @xml.Element,
) -> Algorithm raise @opc_errors.SchemaViolation {
  let raw_type = match attribute(element, "type") {
    Some(text) => text
    None =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path="alg/@type",
        reason="alg element requires the @type attribute",
      )
  }
  let kind = AlgorithmType::from_attr(raw_type)
  let params : Array[(String, String)] = []
  for child in element.children {
    match child {
      @xml.Element(node) =>
        if node.name.local_name == "param" {
          let key = attribute(node, "type").unwrap_or("")
          let val = attribute(node, "val").unwrap_or("")
          params.push((key, val))
        }
      _ => ()
    }
  }
  { kind, params }
}

///|
/// Part 1 §21.4.2.27 shape — decode a `shape` element into a
/// typed `Shape`. The preset shape reference is decoded via
/// `@preset_geometry.PresetShape::from_attr`; unknown lexical
/// values are tolerated (recorded as `None`) so the layout decode
/// does not fail when a layout references a niche shape that the
/// preset_geometry package has not catalogued yet.
pub fn decode_shape(element : @xml.Element) -> Shape {
  let preset = match attribute(element, "type") {
    Some(value) => {
      let trimmed = trim_whitespace(value)
      if trimmed.length() == 0 {
        None
      } else {
        match (try? @preset_geometry.PresetShape::from_attr(trimmed)) {
          Ok(shape) => Some(shape)
          Err(_) => None
        }
      }
    }
    None => None
  }
  let hide_geom = match attribute(element, "hideGeom") {
    Some("1") | Some("true") => true
    _ => false
  }
  { preset, hide_geom }
}

///|
/// Part 1 §21.4.2.21 presOf — decode a `presOf` element. Every
/// attribute is optional; the schema defaults are `axis = none`,
/// `ptType = all`, `st = 1`, `step = 1`. The `cnt` attribute is
/// `None` when absent (meaning "select every point").
pub fn decode_pres_of(
  element : @xml.Element,
) -> PresOfSpec raise @opc_errors.SchemaViolation {
  let axis = match attribute(element, "axis") {
    Some(value) => AxisType::from_attr(value)
    None => AxisNone
  }
  let pt_type = match attribute(element, "ptType") {
    Some(value) => ElementType::from_attr(value)
    None => ElAll
  }
  let cnt = parse_int_attr(element, "cnt")
  let st = match parse_int_attr(element, "st") {
    Some(value) => value
    None => 1
  }
  let step = match parse_int_attr(element, "step") {
    Some(value) => value
    None => 1
  }
  { axis, pt_type, cnt, st, step }
}

///|
/// Part 1 §21.4.2.14 forEach — decode a `forEach` element and
/// recursively decode its layout-child body. Missing `@axis`
/// defaults to `ch` (immediate children) — matching the spec
/// example in §21.4.2.14 where every `forEach` carries either
/// `axis="ch"` explicitly or defaults to it.
pub fn decode_for_each(
  element : @xml.Element,
) -> ForEachSpec raise @opc_errors.SchemaViolation {
  let name = attribute(element, "name").unwrap_or("")
  let axis = match attribute(element, "axis") {
    Some(value) => AxisType::from_attr(value)
    None => AxisCh
  }
  let pt_type = match attribute(element, "ptType") {
    Some(value) => ElementType::from_attr(value)
    None => ElAll
  }
  let cnt = parse_int_attr(element, "cnt")
  let st = match parse_int_attr(element, "st") {
    Some(value) => value
    None => 1
  }
  let step = match parse_int_attr(element, "step") {
    Some(value) => value
    None => 1
  }
  let body = decode_layout_child_sequence(element)
  { name, axis, pt_type, cnt, st, step, body }
}

///|
/// Part 1 §21.4.2.6 choose — decode a `choose` element into the
/// ordered list of its `if` / `else` branches. The schema enforces
/// `<if>+ <else>?` so the decoder simply walks the children and
/// records each one; predicate evaluation runs at engine time.
pub fn decode_choose(
  element : @xml.Element,
) -> Array[ChooseBranch] raise @opc_errors.SchemaViolation {
  let branches : Array[ChooseBranch] = []
  for child in element.children {
    match child {
      @xml.Element(node) => {
        let local = node.name.local_name
        if local == "if" {
          branches.push(decode_branch(node, is_else=false))
        } else if local == "else" {
          branches.push(decode_branch(node, is_else=true))
        }
      }
      _ => ()
    }
  }
  branches
}

///|
/// Part 1 §21.4.2.15 if / §21.4.2.12 else — decode one branch of
/// a `choose`. The `is_else` flag short-circuits predicate
/// decoding for the `<else>` branch (which carries no predicate
/// attributes).
fn decode_branch(
  element : @xml.Element,
  is_else~ : Bool,
) -> ChooseBranch raise @opc_errors.SchemaViolation {
  let name = attribute(element, "name").unwrap_or("")
  let func = if is_else {
    None
  } else {
    match attribute(element, "func") {
      Some(value) => Some(FunctionType::from_attr(value))
      None => None
    }
  }
  let arg = if is_else { None } else { attribute(element, "arg") }
  let axis = match attribute(element, "axis") {
    Some(value) => AxisType::from_attr(value)
    None => AxisSelf
  }
  let pt_type = match attribute(element, "ptType") {
    Some(value) => ElementType::from_attr(value)
    None => ElAll
  }
  let op = if is_else {
    None
  } else {
    match attribute(element, "op") {
      Some(value) => Some(FunctionOp::from_attr(value))
      None => None
    }
  }
  let val = if is_else { None } else { attribute(element, "val") }
  let body = decode_layout_child_sequence(element)
  { name, is_else, func, arg, axis, pt_type, op, val, body }
}

///|
/// Decode the layout-child sequence (any mix of `layoutNode`,
/// `choose`, `forEach`) under a parent element. Shared by
/// `decode_for_each` and `decode_branch` because both nest the
/// same vocabulary.
fn decode_layout_child_sequence(
  parent : @xml.Element,
) -> Array[LayoutChild] raise @opc_errors.SchemaViolation {
  let children : Array[LayoutChild] = []
  for child in parent.children {
    match child {
      @xml.Element(node) => {
        let local = node.name.local_name
        if local == "layoutNode" {
          children.push(LcNode(decode_layout_node(node)))
        } else if local == "choose" {
          children.push(LcChoose(decode_choose(node)))
        } else if local == "forEach" {
          children.push(LcForEach(decode_for_each(node)))
        }
      }
      _ => ()
    }
  }
  children
}

///|
/// Part 1 §21.4.2.9 constrLst — walk every `constr` child and
/// append its decoded constraint to `sink`. Used by
/// `decode_layout_node`; constraints accumulate in document order
/// so reference constraints can be resolved in a single pass.
pub fn decode_constraint_list(
  list_element : @xml.Element,
  sink : Array[Constraint],
) -> Unit raise @opc_errors.SchemaViolation {
  for child in list_element.children {
    match child {
      @xml.Element(node) =>
        if node.name.local_name == "constr" {
          sink.push(decode_constraint(node))
        }
      _ => ()
    }
  }
}

///|
/// Part 1 §21.4.2.8 constr — decode a single constraint. The
/// schema makes `@type` required; missing values raise
/// `SchemaViolation`. `val` / `fact` are parsed as `Double`;
/// the engine treats absent values as `None` and a missing value
/// is *not* a parse error (only an unparseable string is).
pub fn decode_constraint(
  element : @xml.Element,
) -> Constraint raise @opc_errors.SchemaViolation {
  let raw_type = match attribute(element, "type") {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path="constr/@type",
        reason="constr element requires the @type attribute",
      )
  }
  let kind = ConstraintKind::from_attr(raw_type)
  let for_target = attribute(element, "for")
  let for_name = attribute(element, "forName")
  let pt_type = attribute(element, "ptType")
  // §21.4.2.8 constr/@refType — default `none` per the schema. We
  // surface the typed `ConstraintKind` directly so the solver does
  // not have to re-decode the lexical token each time it follows a
  // reference.  Schema default `none` is absent here (mapped to
  // `None`), matching the semantics: "no reference".
  let ref_type = match attribute(element, "refType") {
    Some(raw) =>
      match raw {
        "none" => None
        other => Some(ConstraintKind::from_attr(other))
      }
    None => None
  }
  let ref_for_target = attribute(element, "refFor")
  let ref_for_name = attribute(element, "refForName")
  let ref_pt_type = attribute(element, "refPtType")
  let op = match attribute(element, "op") {
    Some(value) => Some(FunctionOp::from_attr(value))
    None => None
  }
  let val = match attribute(element, "val") {
    Some(text) => Some(parse_double_string(text, "constr/@val"))
    None => None
  }
  let fact = match attribute(element, "fact") {
    Some(text) => Some(parse_double_string(text, "constr/@fact"))
    None => None
  }
  {
    kind,
    for_target,
    for_name,
    pt_type,
    ref_type,
    ref_for_target,
    ref_for_name,
    ref_pt_type,
    op,
    val,
    fact,
  }
}

///|
/// Part 1 §21.4.2.10 dataModel — decode a `CT_DataModel` element
/// wrapper into the typed `DataModel`. The decoder first reads the
/// `ptLst/pt` list, then the `cxnLst/cxn` list, and finally walks
/// the connections to fill in each point's `parent_id` (where a
/// `cxn/@type = parOf` exists, the `srcId` is the parent of the
/// `destId`).
pub fn decode_data_model(
  data_model : @domain.CT_DataModel,
) -> DataModel raise @opc_errors.SchemaViolation {
  let element = data_model.element
  let points : Array[DiagramPoint] = []
  let connections : Array[DiagramConnection] = []
  for child in element.children {
    match child {
      @xml.Element(node) => {
        let local = node.name.local_name
        if local == "ptLst" {
          for entry in node.children {
            match entry {
              @xml.Element(pt) =>
                if pt.name.local_name == "pt" {
                  points.push(decode_point(pt))
                }
              _ => ()
            }
          }
        } else if local == "cxnLst" {
          for entry in node.children {
            match entry {
              @xml.Element(cxn) =>
                if cxn.name.local_name == "cxn" {
                  connections.push(decode_connection(cxn))
                }
              _ => ()
            }
          }
        }
      }
      _ => ()
    }
  }
  let with_parents = assign_parent_ids(points, connections)
  { points: with_parents, connections }
}

///|
/// Walk the connections list and produce a new point array whose
/// `parent_id` is populated from any `cxn/@type = parOf` link.
/// Other connection types (`presOf`, `presParOf`,
/// `unknownRelationship`) describe presentation-only links and
/// are ignored by the parent computation.
fn assign_parent_ids(
  points : Array[DiagramPoint],
  connections : Array[DiagramConnection],
) -> Array[DiagramPoint] {
  let parent_lookup : Array[(String, String)] = []
  for cxn in connections {
    if cxn.cxn_type == "parOf" {
      parent_lookup.push((cxn.dest_id, cxn.src_id))
    }
  }
  let result : Array[DiagramPoint] = []
  for point in points {
    let parent_id = lookup_string(parent_lookup, point.id)
    result.push({
      id: point.id,
      point_type: point.point_type,
      parent_id,
      text: point.text,
      pr_set: point.pr_set,
      sp_pr: point.sp_pr,
    })
  }
  result
}

///|
/// Linear-scan lookup helper for `assign_parent_ids`. Diagram
/// data models are small (rarely above a hundred points), so the
/// scan is cheaper than building a hashmap.
fn lookup_string(table : Array[(String, String)], key : String) -> String? {
  for entry in table {
    let (k, v) = entry
    if k == key {
      return Some(v)
    }
  }
  None
}

///|
/// Part 1 §21.4.3 pt — decode a single `pt` element. `@modelId`
/// is required by the schema; missing values raise
/// `SchemaViolation`. `@type` defaults to `node` per the schema
/// default.
pub fn decode_point(
  element : @xml.Element,
) -> DiagramPoint raise @opc_errors.SchemaViolation {
  let id = match attribute(element, "modelId") {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path="pt/@modelId",
        reason="pt element requires the @modelId attribute",
      )
  }
  let point_type = attribute(element, "type").unwrap_or("node")
  let mut text : String? = None
  let mut pr_set : @xml.Element? = None
  let mut sp_pr : @xml.Element? = None
  for child in element.children {
    match child {
      @xml.Element(node) => {
        let local = node.name.local_name
        if local == "t" {
          text = Some(collect_text(node))
        } else if local == "prSet" {
          pr_set = Some(node)
        } else if local == "spPr" {
          sp_pr = Some(node)
        }
      }
      _ => ()
    }
  }
  { id, point_type, parent_id: None, text, pr_set, sp_pr }
}

///|
/// Part 1 §21.4.3 cxn — decode a single `cxn` element. `@srcId`
/// and `@destId` are required; missing values raise
/// `SchemaViolation`. `@type` defaults to `parOf` per schema.
pub fn decode_connection(
  element : @xml.Element,
) -> DiagramConnection raise @opc_errors.SchemaViolation {
  let id = attribute(element, "modelId")
  let src_id = match attribute(element, "srcId") {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path="cxn/@srcId",
        reason="cxn element requires the @srcId attribute",
      )
  }
  let dest_id = match attribute(element, "destId") {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path="cxn/@destId",
        reason="cxn element requires the @destId attribute",
      )
  }
  let src_ord = match parse_int_attr(element, "srcOrd") {
    Some(value) => value
    None => 0
  }
  let dest_ord = match parse_int_attr(element, "destOrd") {
    Some(value) => value
    None => 0
  }
  let cxn_type = attribute(element, "type").unwrap_or("parOf")
  { id, src_id, dest_id, src_ord, dest_ord, cxn_type }
}

///|
/// Collect concatenated text (and CDATA) content from an
/// element's children. Used by `decode_point` to read the `<t>`
/// child's text body; matches the §21.4.3 description of `t`
/// as a CT_TextBody whose run text we concatenate for the layout
/// engine's purposes.
fn collect_text(element : @xml.Element) -> String {
  let mut out = ""
  for child in element.children {
    match child {
      @xml.Text(value) => out = out + value
      @xml.CData(value) => out = out + value
      @xml.Element(node) => out = out + collect_text(node)
      _ => ()
    }
  }
  out
}

///|
/// First-child-by-local-name helper used throughout the decoder.
/// Returns the first `@xml.Element` child whose local name
/// matches; ignores text and PI nodes.
pub fn first_child_by_local_name(
  parent : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in parent.children {
    match child {
      @xml.Element(node) =>
        if node.name.local_name == local_name {
          return Some(node)
        }
      _ => ()
    }
  }
  None
}

///|
/// Read an attribute value by local name (namespace-agnostic).
/// The diagram XSD prefixes elements with the dml-diagram
/// namespace but attributes are unprefixed, so a local-name match
/// is sufficient.
pub fn attribute(element : @xml.Element, local_name : String) -> String? {
  for entry in element.attributes {
    if entry.name.local_name == local_name {
      return Some(entry.value)
    }
  }
  None
}

///|
/// Parse an integer attribute value, returning `None` when the
/// attribute is absent and `Some(value)` when it parses cleanly.
/// Malformed numeric values raise `SchemaViolation` so the engine
/// fails fast on a typo rather than silently ignoring it.
pub fn parse_int_attr(
  element : @xml.Element,
  local_name : String,
) -> Int? raise @opc_errors.SchemaViolation {
  match attribute(element, local_name) {
    None => None
    Some(value) => Some(parse_int_string(value, local_name))
  }
}

///|
/// Parse a decimal integer string into an `Int`. Wraps
/// `@strconv.from_str` and re-raises as `SchemaViolation` with
/// the offending attribute path.
pub fn parse_int_string(
  value : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  let trimmed = trim_whitespace(value)
  try @strconv.from_str(trimmed) catch {
    _ =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path~,
        reason="value is not an integer: " + value,
      )
  } noraise {
    parsed => parsed
  }
}

///|
/// Parse a decimal floating-point string into a `Double`.
/// Returns the parsed value or raises `SchemaViolation` with the
/// offending attribute path.
pub fn parse_double_string(
  value : String,
  path : String,
) -> Double raise @opc_errors.SchemaViolation {
  let trimmed = trim_whitespace(value)
  try @strconv.from_str(trimmed) catch {
    _ =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path~,
        reason="value is not a number: " + value,
      )
  } noraise {
    parsed => parsed
  }
}

///|
/// Trim leading and trailing XML whitespace (space, tab, LF, CR)
/// from a token value. Diagram attribute values are tokens per the
/// XSD, so the canonical whitespace normalization is enough.
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
