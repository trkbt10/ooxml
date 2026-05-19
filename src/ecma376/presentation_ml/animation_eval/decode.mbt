///|
/// Part 1 §19.5 timing — decode a `<p:timing>` element (already
/// wrapped as `CT_SlideTiming`) into a typed `Timeline`. Walks
/// `<p:tnLst>` and turns each child time-node into a `TimeNode`.
pub fn decode_timing(
  timing : @domain.CT_SlideTiming,
) -> Timeline raise @opc_errors.SchemaViolation {
  let tn_list = first_child_by_local_name(timing.element, "tnLst")
  let roots = match tn_list {
    Some(list) => decode_time_node_list(list)
    None => []
  }
  { roots, }
}

///|
/// Decode a `<p:tnLst>` or `<p:childTnLst>` / `<p:subTnLst>` —
/// every direct element child is interpreted as a time-node. Used
/// recursively by `decode_time_node` for child time-node lists.
pub fn decode_time_node_list(
  list : @xml.Element,
) -> Array[TimeNode] raise @opc_errors.SchemaViolation {
  let result : Array[TimeNode] = []
  for child in list.children {
    match child {
      @xml.Element(element) => result.push(decode_time_node(element))
      _ => ()
    }
  }
  result
}

///|
/// Decode a single time-node element. The local name selects the
/// kind (`par`, `seq`, `excl`, `anim`, …); the cTn child supplies
/// the common attributes (id / dur / restart / fill / accel / decel
/// / repeatCount / nodeType / presetClass / presetID / autoRev).
pub fn decode_time_node(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  let kind_local = element.name.local_name
  match kind_local {
    "par" => decode_par(element)
    "seq" => decode_seq(element)
    "excl" => decode_excl(element)
    "anim" => decode_anim(element)
    "animClr" => decode_anim_clr(element)
    "animMotion" => decode_anim_motion(element)
    "animRot" => decode_anim_rot(element)
    "animScale" => decode_anim_scale(element)
    "set" => decode_set(element)
    "cmd" => decode_cmd(element)
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path=kind_local,
        reason="unsupported time-node element: " + kind_local,
      )
  }
}

///|
/// Decode a `<p:par>` (CT_TLTimeNodeParallel) element.
pub fn decode_par(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  let common = decode_common_time_node_data(element, Par)
  common
}

///|
/// Decode a `<p:seq>` (CT_TLTimeNodeSequence) element.
pub fn decode_seq(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  // seq carries prevCondLst / nextCondLst directly as siblings of
  // cTn. We merge them into the resulting node so consumers can
  // inspect the sequence-level navigation conditions.
  let mut node = decode_common_time_node_data(element, Seq)
  let prev = decode_condition_list(element, "prevCondLst")
  let next = decode_condition_list(element, "nextCondLst")
  if prev.length() > 0 {
    node = {
      node_id: node.node_id,
      node_type: node.node_type,
      preset_class: node.preset_class,
      preset_id: node.preset_id,
      duration: node.duration,
      delay: node.delay,
      restart: node.restart,
      fill: node.fill,
      repeat_count: node.repeat_count,
      accel: node.accel,
      decel: node.decel,
      auto_reverse: node.auto_reverse,
      start_conditions: node.start_conditions,
      end_conditions: node.end_conditions,
      next_conditions: node.next_conditions,
      prev_conditions: prev,
      kind: node.kind,
      children: node.children,
    }
  }
  if next.length() > 0 {
    node = {
      node_id: node.node_id,
      node_type: node.node_type,
      preset_class: node.preset_class,
      preset_id: node.preset_id,
      duration: node.duration,
      delay: node.delay,
      restart: node.restart,
      fill: node.fill,
      repeat_count: node.repeat_count,
      accel: node.accel,
      decel: node.decel,
      auto_reverse: node.auto_reverse,
      start_conditions: node.start_conditions,
      end_conditions: node.end_conditions,
      next_conditions: next,
      prev_conditions: node.prev_conditions,
      kind: node.kind,
      children: node.children,
    }
  }
  node
}

///|
/// Decode a `<p:excl>` (CT_TLTimeNodeExclusive) element.
pub fn decode_excl(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  decode_common_time_node_data(element, Excl)
}

///|
/// Decode an `<p:anim>` (CT_TLAnimateBehavior) element.
pub fn decode_anim(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  let common = decode_behavior_common(element)
  let calc = attr_local(element, "calcmode")
  let value_type = attr_local(element, "valueType")
  let merged = with_anim_attrs(common, calc, value_type, element)
  let leaf = AnimateLeaf({ common: merged })
  decode_common_time_node_data(element, leaf)
}

///|
/// Decode an `<p:animClr>` (CT_TLAnimateColorBehavior) element.
pub fn decode_anim_clr(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  let common = decode_behavior_common(element)
  let common = with_endpoint_color(common, element, "from")
  let common = with_endpoint_color(common, element, "to")
  let common = with_endpoint_color(common, element, "by")
  let color_space = attr_local(element, "clrSpc")
  let direction = attr_local(element, "dir")
  let leaf = AnimateColorLeaf({ common, color_space, direction })
  decode_common_time_node_data(element, leaf)
}

///|
/// Decode an `<p:animMotion>` (CT_TLAnimateMotionBehavior) element.
pub fn decode_anim_motion(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  let common = decode_behavior_common(element)
  let origin = attr_local(element, "origin")
  let path = attr_local(element, "path")
  let path_edit_mode = attr_local(element, "pathEditMode")
  let r_ang = match attr_local(element, "rAng") {
    Some(text) => parse_double(text)
    None => None
  }
  let pts_types = attr_local(element, "ptsTypes")
  let leaf = AnimateMotionLeaf({
    common,
    origin,
    path,
    path_edit_mode,
    r_ang,
    pts_types,
  })
  decode_common_time_node_data(element, leaf)
}

///|
/// Decode an `<p:animRot>` (CT_TLAnimateRotationBehavior) element.
pub fn decode_anim_rot(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  let common = decode_behavior_common(element)
  let merged = with_from_to_by(common, element)
  let leaf = AnimateRotationLeaf({ common: merged })
  decode_common_time_node_data(element, leaf)
}

///|
/// Decode an `<p:animScale>` (CT_TLAnimateScaleBehavior) element.
pub fn decode_anim_scale(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  let common = decode_behavior_common(element)
  let merged = with_from_to_by(common, element)
  let zoom_contents = match attr_local(element, "zoomContents") {
    Some("1") => Some(true)
    Some("true") => Some(true)
    Some("0") => Some(false)
    Some("false") => Some(false)
    _ => None
  }
  let leaf = AnimateScaleLeaf({ common: merged, zoom_contents })
  decode_common_time_node_data(element, leaf)
}

///|
/// Decode a `<p:set>` (CT_TLSetBehavior) element.
pub fn decode_set(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  let common = decode_behavior_common(element)
  let common = with_to_variant(common, element)
  let leaf = SetLeaf({ common, })
  decode_common_time_node_data(element, leaf)
}

///|
/// Decode a `<p:cmd>` (CT_TLCommandBehavior) element.
pub fn decode_cmd(
  element : @xml.Element,
) -> TimeNode raise @opc_errors.SchemaViolation {
  let common = decode_behavior_common(element)
  let command_type = attr_local(element, "type")
  let command_value = attr_local(element, "cmd")
  let leaf = CommandLeaf({ common, command_type, command_value })
  decode_common_time_node_data(element, leaf)
}

///|
/// Decode the common cTn child of a time-node element. Returns a
/// `TimeNode` whose `kind` is set to the supplied container/leaf
/// discriminator and whose attributes / children come from the cTn.
/// For container kinds (par / seq / excl) the cTn is a direct
/// child; for leaf behaviours (anim / animClr / animMotion /
/// animRot / animScale / set / cmd) the cTn lives inside the
/// `<p:cBhvr>` wrapper.
fn decode_common_time_node_data(
  element : @xml.Element,
  kind : TimeNodeKind,
) -> TimeNode raise @opc_errors.SchemaViolation {
  let c_tn = match find_ctn(element) {
    Some(t) => Some(t)
    None => first_child_by_local_name(element, "cTn")
  }
  let node_id = match c_tn {
    Some(t) =>
      match attr_local(t, "id") {
        Some(text) =>
          match parse_unsigned_int(trim_whitespace(text)) {
            Some(n) => n
            None =>
              raise @opc_errors.SchemaViolation(
                section=animation_section,
                path="cTn/@id",
                reason="malformed unsignedInt: " + text,
              )
          }
        None => 0
      }
    None => 0
  }
  let node_type = match c_tn {
    Some(t) =>
      match attr_local(t, "nodeType") {
        Some(text) => Some(NodeType::from_attr(text))
        None => None
      }
    None => None
  }
  let preset_class = match c_tn {
    Some(t) =>
      match attr_local(t, "presetClass") {
        Some(text) => Some(PresetClass::from_attr(text))
        None => None
      }
    None => None
  }
  let preset_id = match c_tn {
    Some(t) =>
      match attr_local(t, "presetID") {
        Some(text) => parse_signed_int(text)
        None => None
      }
    None => None
  }
  let duration = match c_tn {
    Some(t) =>
      match attr_local(t, "dur") {
        Some(text) => TimeValue::from_attr(text)
        None => None
      }
    None => None
  }
  let delay = match c_tn {
    Some(t) =>
      match attr_local(t, "delay") {
        Some(text) => TimeValue::from_attr(text)
        None => None
      }
    None => None
  }
  let restart = match c_tn {
    Some(t) =>
      match attr_local(t, "restart") {
        Some(text) => Some(RestartType::from_attr(text))
        None => None
      }
    None => None
  }
  let fill = match c_tn {
    Some(t) =>
      match attr_local(t, "fill") {
        Some(text) => Some(FillType::from_attr(text))
        None => None
      }
    None => None
  }
  let repeat_count = match c_tn {
    Some(t) =>
      match attr_local(t, "repeatCount") {
        Some(text) => RepeatCount::from_attr(text)
        None => None
      }
    None => None
  }
  let accel = match c_tn {
    Some(t) =>
      match attr_local(t, "accel") {
        Some(text) => parse_percentage(text).unwrap_or(0.0)
        None => 0.0
      }
    None => 0.0
  }
  let decel = match c_tn {
    Some(t) =>
      match attr_local(t, "decel") {
        Some(text) => parse_percentage(text).unwrap_or(0.0)
        None => 0.0
      }
    None => 0.0
  }
  let auto_reverse = match c_tn {
    Some(t) =>
      match attr_local(t, "autoRev") {
        Some("1") => true
        Some("true") => true
        _ => false
      }
    None => false
  }
  let (start_conditions, end_conditions, children) = match c_tn {
    Some(t) => {
      let starts = decode_condition_list(t, "stCondLst")
      let ends = decode_condition_list(t, "endCondLst")
      let kids = decode_child_time_nodes(t)
      (starts, ends, kids)
    }
    None => ([], [], [])
  }
  // par carries no prev/nextCondLst at the cTn level; seq decodes
  // them in its own helper.
  {
    node_id,
    node_type,
    preset_class,
    preset_id,
    duration,
    delay,
    restart,
    fill,
    repeat_count,
    accel,
    decel,
    auto_reverse,
    start_conditions,
    end_conditions,
    next_conditions: [],
    prev_conditions: [],
    kind,
    children,
  }
}

///|
/// Walk a cTn's `<p:childTnLst>` and return the decoded children.
fn decode_child_time_nodes(
  c_tn : @xml.Element,
) -> Array[TimeNode] raise @opc_errors.SchemaViolation {
  let list = first_child_by_local_name(c_tn, "childTnLst")
  match list {
    Some(l) => decode_time_node_list(l)
    None => []
  }
}

///|
/// Decode a named condition list child. `parent` is the cTn (for
/// stCondLst / endCondLst) or the seq element (for prev/nextCondLst).
fn decode_condition_list(
  parent : @xml.Element,
  local_name : String,
) -> Array[TimeCondition] raise @opc_errors.SchemaViolation {
  let result : Array[TimeCondition] = []
  match first_child_by_local_name(parent, local_name) {
    Some(list) =>
      for child in list.children {
        match child {
          @xml.Element(element) =>
            if element.name.local_name == "cond" {
              result.push(decode_condition(element))
            }
          _ => ()
        }
      }
    None => ()
  }
  result
}

///|
/// Decode a single `<p:cond>` element.
pub fn decode_condition(
  element : @xml.Element,
) -> TimeCondition raise @opc_errors.SchemaViolation {
  let delay = match attr_local(element, "delay") {
    Some(text) => TimeValue::from_attr(text)
    None => None
  }
  let event = match attr_local(element, "evt") {
    Some(text) => Some(TriggerEvent::from_attr(text))
    None => None
  }
  let (target_shape_id, target_runtime_node_id) = decode_cond_target(element)
  { delay, event, target_shape_id, target_runtime_node_id }
}

///|
fn decode_cond_target(
  element : @xml.Element,
) -> (Int?, Int?) raise @opc_errors.SchemaViolation {
  let tgt_el = first_child_by_local_name(element, "tgtEl")
  let shape_id = match tgt_el {
    Some(t) => decode_sp_tgt_shape_id(t)
    None => None
  }
  let tn = first_child_by_local_name(element, "tn")
  let runtime_id = match tn {
    Some(t) =>
      match attr_local(t, "val") {
        Some(text) => parse_signed_int(text)
        None => None
      }
    None => None
  }
  (shape_id, runtime_id)
}

///|
/// Decode the `<p:tgtEl><p:spTgt @spid>` value if present.
fn decode_sp_tgt_shape_id(
  tgt_el : @xml.Element,
) -> Int? raise @opc_errors.SchemaViolation {
  match first_child_by_local_name(tgt_el, "spTgt") {
    Some(sp) =>
      match attr_local(sp, "spid") {
        Some(text) =>
          match parse_signed_int(text) {
            Some(n) => Some(n)
            None =>
              raise @opc_errors.SchemaViolation(
                section=animation_section,
                path="spTgt/@spid",
                reason="malformed ST_DrawingElementId: " + text,
              )
          }
        None => None
      }
    None => None
  }
}

///|
/// Decode the shared cBhvr block carried by every leaf behaviour.
/// The cBhvr is a direct child of the behaviour element. The
/// resulting BehaviorCommon is later folded with leaf-specific
/// from/to/by attributes by `with_anim_attrs` / `with_from_to_by` /
/// `with_to_variant` helpers.
pub fn decode_cbhvr(
  element : @xml.Element,
) -> BehaviorCommon raise @opc_errors.SchemaViolation {
  decode_behavior_common(element)
}

///|
fn decode_behavior_common(
  element : @xml.Element,
) -> BehaviorCommon raise @opc_errors.SchemaViolation {
  let cbhvr = first_child_by_local_name(element, "cBhvr")
  match cbhvr {
    Some(c) => decode_cbhvr_inner(c)
    None =>
      // The cBhvr is optional only for cmd in unusual files; emit
      // an empty common record so downstream walkers do not crash.
      {
        target_shape_id: None,
        attr_names: [],
        additive: None,
        accumulate: None,
        from_value: None,
        to_value: None,
        by_value: None,
        tav_list: [],
        calc_mode: None,
        value_type: None,
      }
  }
}

///|
fn decode_cbhvr_inner(
  cbhvr : @xml.Element,
) -> BehaviorCommon raise @opc_errors.SchemaViolation {
  let additive = match attr_local(cbhvr, "additive") {
    Some(text) => Some(AdditiveType::from_attr(text))
    None => None
  }
  let accumulate = match attr_local(cbhvr, "accumulate") {
    Some(text) => Some(AccumulateType::from_attr(text))
    None => None
  }
  let target_shape_id = match first_child_by_local_name(cbhvr, "tgtEl") {
    Some(t) => decode_sp_tgt_shape_id(t)
    None => None
  }
  let attr_names = decode_attr_name_list(cbhvr)
  // cBhvr can also carry inline from/to/by as attributes on the
  // parent element; the helper that calls us folds those in.
  // tavLst lives on the behaviour element rather than on cBhvr.
  {
    target_shape_id,
    attr_names,
    additive,
    accumulate,
    from_value: None,
    to_value: None,
    by_value: None,
    tav_list: [],
    calc_mode: None,
    value_type: None,
  }
}

///|
fn decode_attr_name_list(cbhvr : @xml.Element) -> Array[String] {
  let result : Array[String] = []
  match first_child_by_local_name(cbhvr, "attrNameLst") {
    Some(list) =>
      for child in list.children {
        match child {
          @xml.Element(element) =>
            if element.name.local_name == "attrName" {
              result.push(text_of(element))
            }
          _ => ()
        }
      }
    None => ()
  }
  result
}

///|
fn text_of(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for child in element.children {
    match child {
      @xml.Text(t) => buf.write_string(t)
      @xml.CData(t) => buf.write_string(t)
      _ => ()
    }
  }
  buf.to_string()
}

///|
/// Fold the anim-specific from/to/by/calcmode/valueType attributes
/// plus the tavLst keypoints into the BehaviorCommon. Called by
/// `decode_anim` after the cBhvr is decoded.
fn with_anim_attrs(
  common : BehaviorCommon,
  calc : String?,
  value_type : String?,
  element : @xml.Element,
) -> BehaviorCommon raise @opc_errors.SchemaViolation {
  let calc_mode = match calc {
    Some(text) => Some(CalcMode::from_attr(text))
    None => None
  }
  let value_type_enum = match value_type {
    Some(text) => Some(ValueType::from_attr(text))
    None => None
  }
  let vt : ValueType = match value_type_enum {
    Some(t) => t
    None => ValString
  }
  let from_value = match attr_local(element, "from") {
    Some(text) => Some(variant_from_attr(text, vt))
    None => None
  }
  let to_value = match attr_local(element, "to") {
    Some(text) => Some(variant_from_attr(text, vt))
    None => None
  }
  let by_value = match attr_local(element, "by") {
    Some(text) => Some(variant_from_attr(text, vt))
    None => None
  }
  let tav_list = decode_tav_list(element)
  {
    target_shape_id: common.target_shape_id,
    attr_names: common.attr_names,
    additive: common.additive,
    accumulate: common.accumulate,
    from_value,
    to_value,
    by_value,
    tav_list,
    calc_mode,
    value_type: value_type_enum,
  }
}

///|
fn with_from_to_by(
  common : BehaviorCommon,
  element : @xml.Element,
) -> BehaviorCommon {
  let from_value = match attr_local(element, "from") {
    Some(text) =>
      match parse_double(text) {
        Some(d) => Some(FloatVariant(d))
        None => Some(StringVariant(text))
      }
    None => None
  }
  let to_value = match attr_local(element, "to") {
    Some(text) =>
      match parse_double(text) {
        Some(d) => Some(FloatVariant(d))
        None => Some(StringVariant(text))
      }
    None => None
  }
  let by_value = match attr_local(element, "by") {
    Some(text) =>
      match parse_double(text) {
        Some(d) => Some(FloatVariant(d))
        None => Some(StringVariant(text))
      }
    None => None
  }
  {
    target_shape_id: common.target_shape_id,
    attr_names: common.attr_names,
    additive: common.additive,
    accumulate: common.accumulate,
    from_value,
    to_value,
    by_value,
    tav_list: common.tav_list,
    calc_mode: common.calc_mode,
    value_type: common.value_type,
  }
}

///|
/// Decode the `<p:to>` child variant of a `<p:set>` element. Per
/// §19.5.66 set carries no from/by, only a single `<p:to>` whose
/// child is one of `<p:strVal>`, `<p:intVal>`, `<p:fltVal>`,
/// `<p:boolVal>`, `<p:clrVal>`.
fn with_to_variant(
  common : BehaviorCommon,
  element : @xml.Element,
) -> BehaviorCommon raise @opc_errors.SchemaViolation {
  let to_element = first_child_by_local_name(element, "to")
  let to_value = match to_element {
    Some(t) => decode_anim_variant(t)
    None => None
  }
  {
    target_shape_id: common.target_shape_id,
    attr_names: common.attr_names,
    additive: common.additive,
    accumulate: common.accumulate,
    from_value: None,
    to_value,
    by_value: None,
    tav_list: [],
    calc_mode: None,
    value_type: None,
  }
}

///|
/// animClr's from/to/by are wrapped colour elements rather than
/// scalar attributes. We capture the raw serialised text of each
/// endpoint so renderers can re-parse them through the DML colour
/// resolver.
fn with_endpoint_color(
  common : BehaviorCommon,
  element : @xml.Element,
  local_name : String,
) -> BehaviorCommon {
  let endpoint = first_child_by_local_name(element, local_name)
  match endpoint {
    None => common
    Some(e) => {
      let payload = serialise_color_endpoint(e)
      match local_name {
        "from" =>
          {
            target_shape_id: common.target_shape_id,
            attr_names: common.attr_names,
            additive: common.additive,
            accumulate: common.accumulate,
            from_value: Some(ColorVariant(payload)),
            to_value: common.to_value,
            by_value: common.by_value,
            tav_list: common.tav_list,
            calc_mode: common.calc_mode,
            value_type: common.value_type,
          }
        "to" =>
          {
            target_shape_id: common.target_shape_id,
            attr_names: common.attr_names,
            additive: common.additive,
            accumulate: common.accumulate,
            from_value: common.from_value,
            to_value: Some(ColorVariant(payload)),
            by_value: common.by_value,
            tav_list: common.tav_list,
            calc_mode: common.calc_mode,
            value_type: common.value_type,
          }
        _ =>
          {
            target_shape_id: common.target_shape_id,
            attr_names: common.attr_names,
            additive: common.additive,
            accumulate: common.accumulate,
            from_value: common.from_value,
            to_value: common.to_value,
            by_value: Some(ColorVariant(payload)),
            tav_list: common.tav_list,
            calc_mode: common.calc_mode,
            value_type: common.value_type,
          }
      }
    }
  }
}

///|
/// Best-effort serialisation of the first element child of an
/// animClr endpoint. The renderer ultimately interprets the
/// scheme/srgb/sysClr token, so we only need to preserve its local
/// name and `val` attribute.
fn serialise_color_endpoint(endpoint : @xml.Element) -> String {
  for child in endpoint.children {
    match child {
      @xml.Element(element) => {
        let tag = element.name.local_name
        let val = attr_local(element, "val")
        match val {
          Some(v) => return tag + ":" + v
          None => return tag
        }
      }
      _ => ()
    }
  }
  ""
}

///|
/// Decode a `<p:tavLst>` keypoint list under an anim/animRot/animScale
/// element. Returns an empty array when the list is absent.
fn decode_tav_list(
  element : @xml.Element,
) -> Array[Tav] raise @opc_errors.SchemaViolation {
  let list = first_child_by_local_name(element, "tavLst")
  let result : Array[Tav] = []
  match list {
    Some(l) =>
      for child in l.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "tav" {
              result.push(decode_tav(e))
            }
          _ => ()
        }
      }
    None => ()
  }
  result
}

///|
/// Decode a single `<p:tav>` keypoint. `tm` is either `indefinite`
/// or a percentage / unsignedInt; we always normalise to 0..1.
pub fn decode_tav(
  element : @xml.Element,
) -> Tav raise @opc_errors.SchemaViolation {
  let tm = attr_local(element, "tm")
  let tm_percent = match tm {
    Some(text) => parse_tav_time(text)
    None => Some(0.0)
  }
  let value_el = first_child_by_local_name(element, "val")
  let value = match value_el {
    Some(v) => decode_anim_variant(v)
    None => None
  }
  { tm_percent, value }
}

///|
/// Decode a `<p:val>` element (CT_TLAnimVariant). The child element
/// (`<p:boolVal>` / `<p:intVal>` / `<p:fltVal>` / `<p:strVal>` /
/// `<p:clrVal>`) selects the variant.
pub fn decode_anim_variant(
  val_element : @xml.Element,
) -> AnimVariant? raise @opc_errors.SchemaViolation {
  for child in val_element.children {
    match child {
      @xml.Element(element) => {
        let kind_local = element.name.local_name
        let value = attr_local(element, "val")
        return match kind_local {
          "boolVal" =>
            match value {
              Some("1") => Some(BoolVariant(true))
              Some("true") => Some(BoolVariant(true))
              Some("0") => Some(BoolVariant(false))
              Some("false") => Some(BoolVariant(false))
              _ => None
            }
          "intVal" =>
            match value {
              Some(text) =>
                match parse_signed_int(text) {
                  Some(n) => Some(IntVariant(n))
                  None =>
                    raise @opc_errors.SchemaViolation(
                      section=animation_section,
                      path="intVal/@val",
                      reason="malformed integer: " + text,
                    )
                }
              None => None
            }
          "fltVal" =>
            match value {
              Some(text) =>
                match parse_double(text) {
                  Some(d) => Some(FloatVariant(d))
                  None =>
                    raise @opc_errors.SchemaViolation(
                      section=animation_section,
                      path="fltVal/@val",
                      reason="malformed float: " + text,
                    )
                }
              None => None
            }
          "strVal" =>
            match value {
              Some(text) => Some(StringVariant(text))
              None => None
            }
          "clrVal" => Some(ColorVariant(serialise_color_endpoint(val_element)))
          _ => None
        }
      }
      _ => ()
    }
  }
  None
}

///|
fn variant_from_attr(text : String, value_type : ValueType) -> AnimVariant {
  match value_type {
    ValNumber =>
      match parse_double(text) {
        Some(d) => FloatVariant(d)
        None => StringVariant(text)
      }
    ValString => StringVariant(text)
    ValColor => ColorVariant(text)
  }
}

///|
/// Parse a tav `tm` attribute. Recognised forms:
///   - the literal `indefinite` → `None`
///   - a percentage like `25%` → 0.25
///   - an unsignedInt 0..100000 (ST_PositiveFixedPercentage in
///     thousandths) → divided by 100000.
fn parse_tav_time(text : String) -> Double? {
  let trimmed = trim_whitespace(text)
  if trimmed == "indefinite" {
    return None
  }
  if trimmed.length() == 0 {
    return Some(0.0)
  }
  let last = trimmed.code_unit_at(trimmed.length() - 1).to_int()
  if last == 0x25 {
    let body = trimmed.unsafe_substring(start=0, end=trimmed.length() - 1)
    match parse_double(body) {
      Some(d) => return Some(d / 100.0)
      None => return Some(0.0)
    }
  }
  match parse_unsigned_int(trimmed) {
    Some(n) => Some(n.to_double() / 100000.0)
    None => Some(0.0)
  }
}

///|
fn parse_percentage(text : String) -> Double? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  let last = trimmed.code_unit_at(trimmed.length() - 1).to_int()
  if last == 0x25 {
    let body = trimmed.unsafe_substring(start=0, end=trimmed.length() - 1)
    match parse_double(body) {
      Some(d) => return Some(d / 100.0)
      None => return None
    }
  }
  // ST_PositiveFixedPercentage is stored as thousandths of a percent
  // (1000 = 1%). Cap at 1.0 because accel/decel are 0..1.
  match parse_unsigned_int(trimmed) {
    Some(n) => Some((n.to_double() / 100000.0).min(1.0))
    None => parse_double(trimmed)
  }
}

///|
fn parse_double(text : String) -> Double? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  try {
    let value : Double = @strconv.from_str(trimmed)
    Some(value)
  } catch {
    _ => None
  }
}

///|
fn parse_signed_int(text : String) -> Int? {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  let (sign, start) = if trimmed.code_unit_at(0).to_int() == 0x2D {
    (-1, 1)
  } else if trimmed.code_unit_at(0).to_int() == 0x2B {
    (1, 1)
  } else {
    (1, 0)
  }
  if start >= trimmed.length() {
    return None
  }
  let mut value = 0
  for i in start..<trimmed.length() {
    let unit = trimmed.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10 + (unit - 0x30)
  }
  Some(value * sign)
}

///|
fn find_ctn(element : @xml.Element) -> @xml.Element? {
  // Leaf behaviour: cTn lives inside cBhvr.
  match first_child_by_local_name(element, "cBhvr") {
    Some(cb) => first_child_by_local_name(cb, "cTn")
    None => None
  }
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
fn attr_local(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}
