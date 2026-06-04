///|
/// Part 1 §19.5 timing — decode a `<p:timing>` element (already
/// wrapped as `CT_SlideTiming`) into a typed `Timeline`. Walks the
/// typed `<p:tnLst>` time-node children (CT_TimeNodeList §19.5.86)
/// already surfaced on `CT_SlideTiming` and turns each into a
/// `CT_TLCommonTimeNodeData` (the schema's typed cTn).
pub fn decode_timing(
  timing : @domain.CT_SlideTiming,
) -> Timeline raise @opc_errors.SchemaViolation {
  if timing.tnLst_name is Some(_) && timing.tnLst.length() == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="timing/tnLst",
      reason="requires at least one time-node child",
    )
  }
  let roots : Array[@domain.CT_TLCommonTimeNodeData] = []
  for element in timing.tnLst {
    roots.push(decode_time_node(element))
  }
  { roots, }
}

///|
/// Decode a `<p:tnLst>` or `<p:childTnLst>` / `<p:subTnLst>` —
/// every direct element child is interpreted as a time-node. Used
/// recursively by `decode_time_node` for child time-node lists.
pub fn decode_time_node_list(
  list : @xml.Element,
) -> Array[@domain.CT_TLCommonTimeNodeData] raise @opc_errors.SchemaViolation {
  let result : Array[@domain.CT_TLCommonTimeNodeData] = []
  for child in list.children {
    match child {
      @xml.Element(element) => result.push(decode_time_node(element))
      _ => ()
    }
  }
  if result.length() == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=list.name.local_name,
      reason="requires at least one time-node child",
    )
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
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  let kind_local = element.name.local_name
  match kind_local {
    "par" => decode_par(element)
    "seq" => decode_seq(element)
    "excl" => decode_excl(element)
    "anim" => decode_anim(element)
    "animClr" => decode_anim_clr(element)
    "animEffect" => decode_anim_effect(element)
    "animMotion" => decode_anim_motion(element)
    "animRot" => decode_anim_rot(element)
    "animScale" => decode_anim_scale(element)
    "set" => decode_set(element)
    "cmd" => decode_cmd(element)
    "audio" => decode_audio(element)
    "video" => decode_video(element)
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
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  decode_common_time_node_data(element, @domain.TimeNodePar)
}

///|
/// Decode a `<p:seq>` (CT_TLTimeNodeSequence) element.
pub fn decode_seq(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  // seq carries prevCondLst / nextCondLst directly as siblings of
  // cTn. We merge them into the resulting node so consumers can
  // inspect the sequence-level navigation conditions.
  let mut node = decode_common_time_node_data(element, @domain.TimeNodeSeq)
  let prev = decode_condition_list(element, "prevCondLst")
  let next = decode_condition_list(element, "nextCondLst")
  if prev.length() > 0 {
    node = with_prev_conditions(node, prev)
  }
  if next.length() > 0 {
    node = with_next_conditions(node, next)
  }
  node
}

///|
/// Decode a `<p:excl>` (CT_TLTimeNodeExclusive) element.
pub fn decode_excl(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  decode_common_time_node_data(element, @domain.TimeNodeExcl)
}

///|
/// Decode an `<p:anim>` (CT_TLAnimateBehavior) element.
pub fn decode_anim(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  validate_required_optional_child_pair(element, "anim", "cBhvr", "tavLst")
  let common = decode_behavior_common(element)
  let calc = attr_local(element, "calcmode")
  let value_type = attr_local(element, "valueType")
  let merged = with_anim_attrs(common, calc, value_type, element)
  let behaviour : @domain.CT_TLAnimateBehavior = { common: merged }
  decode_common_time_node_data(element, @domain.TimeNodeAnimate(behaviour))
}

///|
/// Decode an `<p:animClr>` (CT_TLAnimateColorBehavior) element.
pub fn decode_anim_clr(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  validate_anim_clr_children(element)
  let common0 = decode_behavior_common(element)
  let common1 = with_endpoint_color(common0, element, "from")
  let common2 = with_endpoint_color(common1, element, "to")
  let common = with_endpoint_color(common2, element, "by")
  let color_space = match attr_local(element, "clrSpc") {
    Some(text) => Some(parse_st_color_space(text))
    None => None
  }
  let direction = match attr_local(element, "dir") {
    Some(text) => Some(parse_st_color_direction(text))
    None => None
  }
  let behaviour : @domain.CT_TLAnimateColorBehavior = {
    common,
    color_space,
    direction,
  }
  decode_common_time_node_data(element, @domain.TimeNodeAnimateColor(behaviour))
}

///|
/// Decode an `<p:animEffect>` (CT_TLAnimateEffectBehavior) element.
pub fn decode_anim_effect(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  validate_required_optional_child_pair(
    element, "animEffect", "cBhvr", "progress",
  )
  let common = decode_behavior_common(element)
  let progress = match first_child_by_local_name(element, "progress") {
    Some(p) => decode_anim_variant(p)
    None => None
  }
  let transition = match attr_local(element, "transition") {
    Some(text) => Some(parse_st_effect_transition(text))
    None => None
  }
  let behaviour : @domain.CT_TLAnimateEffectRuntimeBehavior = {
    common,
    progress,
    transition,
    filter: attr_local(element, "filter"),
    pr_lst: attr_local(element, "prLst"),
  }
  decode_common_time_node_data(
    element,
    @domain.TimeNodeAnimateEffect(behaviour),
  )
}

///|
/// Decode an `<p:animMotion>` (CT_TLAnimateMotionBehavior) element.
pub fn decode_anim_motion(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  validate_anim_point_children(element, "animMotion", true)
  let common = decode_behavior_common(element)
  let origin = match attr_local(element, "origin") {
    Some(text) => Some(parse_st_motion_origin(text))
    None => None
  }
  let path = attr_local(element, "path")
  let path_edit_mode = match attr_local(element, "pathEditMode") {
    Some(text) => Some(parse_st_path_edit_mode(text))
    None => None
  }
  let r_ang = match attr_local(element, "rAng") {
    Some(text) =>
      Some(parse_signed_int_attr(text, "animMotion/@rAng").to_double())
    None => None
  }
  let pts_types = attr_local(element, "ptsTypes")
  let behaviour : @domain.CT_TLAnimateMotionBehavior = {
    common,
    origin,
    path,
    path_edit_mode,
    r_ang,
    pts_types,
  }
  decode_common_time_node_data(
    element,
    @domain.TimeNodeAnimateMotion(behaviour),
  )
}

///|
/// Decode an `<p:animRot>` (CT_TLAnimateRotationBehavior) element.
pub fn decode_anim_rot(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  validate_required_child(element, "animRot", "cBhvr")
  let common = decode_behavior_common(element)
  let merged = with_angle_from_to_by(common, element, "animRot")
  let behaviour : @domain.CT_TLAnimateRotationBehavior = { common: merged }
  decode_common_time_node_data(
    element,
    @domain.TimeNodeAnimateRotation(behaviour),
  )
}

///|
/// Decode an `<p:animScale>` (CT_TLAnimateScaleBehavior) element.
pub fn decode_anim_scale(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  validate_anim_point_children(element, "animScale", false)
  validate_absent_attributes(element, "animScale", ["from", "to", "by"])
  let common = decode_behavior_common(element)
  let zoom_contents = match attr_local(element, "zoomContents") {
    Some(text) => Some(parse_xsd_bool(text, "animScale/@zoomContents"))
    None => None
  }
  let behaviour : @domain.CT_TLAnimateScaleBehavior = { common, zoom_contents }
  decode_common_time_node_data(element, @domain.TimeNodeAnimateScale(behaviour))
}

///|
/// Decode a `<p:set>` (CT_TLSetBehavior) element.
pub fn decode_set(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  validate_required_optional_child_pair(element, "set", "cBhvr", "to")
  let common0 = decode_behavior_common(element)
  let common = with_to_variant(common0, element)
  let behaviour : @domain.CT_TLSetBehavior = { common, }
  decode_common_time_node_data(element, @domain.TimeNodeSet(behaviour))
}

///|
/// Decode a `<p:cmd>` (CT_TLCommandBehavior) element.
pub fn decode_cmd(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  validate_required_child(element, "cmd", "cBhvr")
  let common = decode_behavior_common(element)
  let command_type = match attr_local(element, "type") {
    Some(text) => Some(parse_st_command_type(text))
    None => None
  }
  let command_value = attr_local(element, "cmd")
  let behaviour : @domain.CT_TLCommandBehavior = {
    common,
    command_type,
    command_value,
  }
  decode_common_time_node_data(element, @domain.TimeNodeCommand(behaviour))
}

///|
/// Decode a `<p:audio>` (CT_TLMediaNodeAudio) element. Media node
/// payload is parsed by the domain wrapper; the timing engine only
/// inflates the nested `<p:cMediaNode>/<p:cTn>` through the same
/// common time-node path used by other leaves.
pub fn decode_audio(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  let media = try @domain.CT_TLMediaNodeAudio::from_element(element) catch {
    e => {
      raise_schema("audio", e)
      @domain.CT_TLMediaNodeAudio::new(element)
    }
  } noraise {
    v => v
  }
  decode_common_time_node_data(element, @domain.TimeNodeAudio(media))
}

///|
/// Decode a `<p:video>` (CT_TLMediaNodeVideo) element. Media node
/// payload is parsed by the domain wrapper; the timing engine only
/// inflates the nested `<p:cMediaNode>/<p:cTn>` through the same
/// common time-node path used by other leaves.
pub fn decode_video(
  element : @xml.Element,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  let media = try @domain.CT_TLMediaNodeVideo::from_element(element) catch {
    e => {
      raise_schema("video", e)
      @domain.CT_TLMediaNodeVideo::new(element)
    }
  } noraise {
    v => v
  }
  decode_common_time_node_data(element, @domain.TimeNodeVideo(media))
}

///|
/// Decode the common cTn child of a time-node element. Returns a
/// `CT_TLCommonTimeNodeData` whose `node_kind` is set to the supplied
/// container/leaf discriminator and whose attributes / children come
/// from the cTn. For container kinds (par / seq / excl) the cTn is a
/// direct child; for leaf behaviours (anim / animClr / animMotion /
/// animRot / animScale / set / cmd) the cTn lives inside the
/// `<p:cBhvr>` wrapper; for media leaves it lives inside
/// `<p:cMediaNode>`.
fn decode_common_time_node_data(
  element : @xml.Element,
  kind : @domain.CT_TLCommonTimeNodeKind,
) -> @domain.CT_TLCommonTimeNodeData raise @opc_errors.SchemaViolation {
  let c_tn = match find_ctn(element) {
    Some(t) => Some(t)
    None => first_child_by_local_name(element, "cTn")
  }
  if c_tn is None {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=element.name.local_name + "/cTn",
      reason="missing required <cTn> child",
    )
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
        Some(text) => Some(parse_st_node_type(text))
        None => None
      }
    None => None
  }
  let preset_class = match c_tn {
    Some(t) =>
      match attr_local(t, "presetClass") {
        Some(text) => Some(parse_st_preset_class(text))
        None => None
      }
    None => None
  }
  let preset_id = match c_tn {
    Some(t) =>
      match attr_local(t, "presetID") {
        Some(text) => Some(parse_signed_int_attr(text, "cTn/@presetID"))
        None => None
      }
    None => None
  }
  let duration = match c_tn {
    Some(t) =>
      match attr_local(t, "dur") {
        Some(text) => parse_st_tl_time_opt(text, "cTn/@dur")
        None => None
      }
    None => None
  }
  let restart = match c_tn {
    Some(t) =>
      match attr_local(t, "restart") {
        Some(text) => Some(parse_st_restart_type(text))
        None => None
      }
    None => None
  }
  let fill = match c_tn {
    Some(t) =>
      match attr_local(t, "fill") {
        Some(text) => Some(parse_st_fill_type(text))
        None => None
      }
    None => None
  }
  let repeat_count = match c_tn {
    Some(t) =>
      match attr_local(t, "repeatCount") {
        Some(text) => parse_st_tl_time_opt(text, "cTn/@repeatCount")
        None => None
      }
    None => None
  }
  let accel = match c_tn {
    Some(t) =>
      match attr_local(t, "accel") {
        Some(text) => parse_percentage_attr(text, "cTn/@accel")
        None => 0.0
      }
    None => 0.0
  }
  let decel = match c_tn {
    Some(t) =>
      match attr_local(t, "decel") {
        Some(text) => parse_percentage_attr(text, "cTn/@decel")
        None => 0.0
      }
    None => 0.0
  }
  let auto_reverse = match c_tn {
    Some(t) =>
      match attr_local(t, "autoRev") {
        Some(text) => parse_xsd_bool(text, "cTn/@autoRev")
        None => false
      }
    None => false
  }
  // §19.5.12 — additional cTn attributes.
  fn cTn_bool(
    name : String,
    default : Bool,
  ) -> Bool raise @opc_errors.SchemaViolation {
    match c_tn {
      Some(t) =>
        match attr_local(t, name) {
          Some(text) => parse_xsd_bool(text, "cTn/@" + name)
          None => default
        }
      None => default
    }
  }

  fn cTn_bool_opt(name : String) -> Bool? raise @opc_errors.SchemaViolation {
    match c_tn {
      Some(t) =>
        match attr_local(t, name) {
          Some(text) => Some(parse_xsd_bool(text, "cTn/@" + name))
          None => None
        }
      None => None
    }
  }

  fn cTn_int_opt(name : String) -> Int? raise @opc_errors.SchemaViolation {
    match c_tn {
      Some(t) =>
        match attr_local(t, name) {
          Some(text) => Some(parse_signed_int_attr(text, "cTn/@" + name))
          None => None
        }
      None => None
    }
  }

  fn cTn_uint_opt(name : String) -> Int? raise @opc_errors.SchemaViolation {
    match c_tn {
      Some(t) =>
        match attr_local(t, name) {
          Some(text) => Some(parse_unsigned_int_attr(text, "cTn/@" + name))
          None => None
        }
      None => None
    }
  }

  fn cTn_str_opt(name : String) -> String? {
    match c_tn {
      Some(t) => attr_local(t, name)
      None => None
    }
  }

  let after_effect = cTn_bool("afterEffect", false)
  let display = cTn_bool("display", true)
  let bld_lvl = cTn_int_opt("bldLvl")
  let grp_id = cTn_uint_opt("grpId")
  let preset_subtype = cTn_int_opt("presetSubtype")
  let evt_filter = cTn_str_opt("evtFilter")
  let master_rel = cTn_str_opt("masterRel")
  let node_ph = cTn_bool_opt("nodePh")
  let repeat_dur = match c_tn {
    Some(t) =>
      match attr_local(t, "repeatDur") {
        Some(text) => parse_st_tl_time_opt(text, "cTn/@repeatDur")
        None => None
      }
    None => None
  }
  let spd = cTn_str_opt("spd")
  let sync_behavior = cTn_str_opt("syncBehavior")
  let tm_filter = cTn_str_opt("tmFilter")
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
    node_kind: kind,
    children,
    after_effect,
    display,
    bld_lvl,
    grp_id,
    preset_subtype,
    evt_filter,
    master_rel,
    node_ph,
    repeat_dur,
    spd,
    sync_behavior,
    tm_filter,
  }
}

///|
/// Re-create a `CT_TLCommonTimeNodeData` with the supplied
/// `prev_conditions` and all other fields preserved.
fn with_prev_conditions(
  node : @domain.CT_TLCommonTimeNodeData,
  prev : Array[@domain.CT_TLTimeCondition],
) -> @domain.CT_TLCommonTimeNodeData {
  { ..node, prev_conditions: prev }
}

///|
/// Re-create a `CT_TLCommonTimeNodeData` with the supplied
/// `next_conditions` and all other fields preserved.
fn with_next_conditions(
  node : @domain.CT_TLCommonTimeNodeData,
  next : Array[@domain.CT_TLTimeCondition],
) -> @domain.CT_TLCommonTimeNodeData {
  { ..node, next_conditions: next }
}

///|
/// Walk a cTn's `<p:childTnLst>` and return the decoded children.
fn decode_child_time_nodes(
  c_tn : @xml.Element,
) -> Array[@domain.CT_TLCommonTimeNodeData] raise @opc_errors.SchemaViolation {
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
) -> Array[@domain.CT_TLTimeCondition] raise @opc_errors.SchemaViolation {
  let result : Array[@domain.CT_TLTimeCondition] = []
  match first_child_by_local_name(parent, local_name) {
    Some(list) => {
      validate_list_element_children(list, local_name, "cond")
      for child in list.children {
        match child {
          @xml.Element(element) =>
            if element.name.local_name == "cond" {
              result.push(decode_condition(element))
            }
          _ => ()
        }
      }
      if result.length() == 0 {
        raise @opc_errors.SchemaViolation(
          section=animation_section,
          path=local_name,
          reason="requires at least one <cond> child",
        )
      }
    }
    None => ()
  }
  result
}

///|
fn validate_list_element_children(
  list : @xml.Element,
  path : String,
  expected_local_name : String,
) -> Unit raise @opc_errors.SchemaViolation {
  for child in list.children {
    match child {
      @xml.Element(element) =>
        if element.name.local_name != expected_local_name {
          raise @opc_errors.SchemaViolation(
            section=animation_section,
            path~,
            reason="unsupported child element: " + element.name.local_name,
          )
        }
      _ => ()
    }
  }
}

///|
/// Decode a single `<p:cond>` (CT_TLTimeCondition §19.5.31) element.
pub fn decode_condition(
  element : @xml.Element,
) -> @domain.CT_TLTimeCondition raise @opc_errors.SchemaViolation {
  let delay = match attr_local(element, "delay") {
    Some(text) => parse_st_tl_time_opt(text, "cond/@delay")
    None => None
  }
  let event = match attr_local(element, "evt") {
    Some(text) => Some(parse_st_trigger_event(text))
    None => None
  }
  let (target_shape_id, target_runtime_node_id) = decode_cond_target(element)
  { delay, event, target_shape_id, target_runtime_node_id }
}

///|
fn decode_cond_target(
  element : @xml.Element,
) -> (Int?, Int?) raise @opc_errors.SchemaViolation {
  let choice_count = count_cond_target_choices(element)
  let element_count = count_element_children(element)
  if choice_count == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="cond",
      reason="missing required tgtEl|tn|rtn choice",
    )
  }
  if element_count != 1 || choice_count != 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="cond",
      reason="expected exactly one tgtEl|tn|rtn choice",
    )
  }
  let tgt_el = first_child_by_local_name(element, "tgtEl")
  let shape_id = match tgt_el {
    Some(t) => {
      validate_time_target_element(t)
      decode_sp_tgt_shape_id(t)
    }
    None => None
  }
  let tn = first_child_by_local_name(element, "tn")
  let runtime_id = match tn {
    Some(t) =>
      match attr_local(t, "val") {
        Some(text) => Some(parse_unsigned_int_attr(text, "tn/@val"))
        None =>
          raise @opc_errors.SchemaViolation(
            section=animation_section,
            path="tn/@val",
            reason="missing required @val attribute",
          )
      }
    None => None
  }
  match first_child_by_local_name(element, "rtn") {
    Some(r) =>
      match attr_local(r, "val") {
        Some(text) => ignore(parse_st_runtime_node(text))
        None =>
          raise @opc_errors.SchemaViolation(
            section=animation_section,
            path="rtn/@val",
            reason="missing required @val attribute",
          )
      }
    None => ()
  }
  (shape_id, runtime_id)
}

///|
fn count_cond_target_choices(element : @xml.Element) -> Int {
  let mut count = 0
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "tgtEl" | "tn" | "rtn" => count = count + 1
          _ => ()
        }
      _ => ()
    }
  }
  count
}

///|
fn validate_time_target_element(
  tgt_el : @xml.Element,
) -> Unit raise @opc_errors.SchemaViolation {
  let choice_count = count_time_target_choices(tgt_el)
  let element_count = count_element_children(tgt_el)
  if choice_count == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="tgtEl",
      reason="missing required sldTgt|sndTgt|spTgt|inkTgt choice",
    )
  }
  if element_count != 1 || choice_count != 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="tgtEl",
      reason="expected exactly one sldTgt|sndTgt|spTgt|inkTgt choice",
    )
  }
  try @domain.CT_TLTimeTargetElement::from_element(tgt_el) catch {
    e => raise_domain_schema("tgtEl", e)
  } noraise {
    _ => ()
  }
}

///|
fn count_time_target_choices(tgt_el : @xml.Element) -> Int {
  let mut count = 0
  for child in tgt_el.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "sldTgt" | "sndTgt" | "spTgt" | "inkTgt" => count = count + 1
          _ => ()
        }
      _ => ()
    }
  }
  count
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
        None =>
          raise @opc_errors.SchemaViolation(
            section=animation_section,
            path="spTgt/@spid",
            reason="missing required @spid attribute",
          )
      }
    None => None
  }
}

///|
/// Decode the shared cBhvr block carried by every leaf behaviour.
/// The cBhvr is a direct child of the behaviour element. The
/// resulting `CT_TLCommonBehaviorData` is later folded with leaf-
/// specific from/to/by attributes by `with_anim_attrs` /
/// `with_from_to_by` / `with_to_variant` helpers.
pub fn decode_cbhvr(
  element : @xml.Element,
) -> @domain.CT_TLCommonBehaviorData raise @opc_errors.SchemaViolation {
  decode_behavior_common(element)
}

///|
fn decode_behavior_common(
  element : @xml.Element,
) -> @domain.CT_TLCommonBehaviorData raise @opc_errors.SchemaViolation {
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
        override_behavior: None,
        runtime_context: None,
        transform_type: None,
      }
  }
}

///|
fn decode_cbhvr_inner(
  cbhvr : @xml.Element,
) -> @domain.CT_TLCommonBehaviorData raise @opc_errors.SchemaViolation {
  validate_cbhvr_children(cbhvr)
  let additive = match attr_local(cbhvr, "additive") {
    Some(text) => Some(parse_st_additive_type(text))
    None => None
  }
  let accumulate = match attr_local(cbhvr, "accumulate") {
    Some(text) => Some(parse_st_accumulate_type(text))
    None => None
  }
  let target_shape_id = match first_child_by_local_name(cbhvr, "tgtEl") {
    Some(t) => {
      validate_time_target_element(t)
      decode_sp_tgt_shape_id(t)
    }
    None => None
  }
  let attr_names = decode_attr_name_list(cbhvr)
  // §19.5.6 — runtime/override/transform behaviour attributes on cBhvr.
  let override_behavior = attr_local(cbhvr, "override")
  let runtime_context = attr_local(cbhvr, "rctx")
  let transform_type = attr_local(cbhvr, "xfrmType")
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
    override_behavior,
    runtime_context,
    transform_type,
  }
}

///|
fn validate_cbhvr_children(
  cbhvr : @xml.Element,
) -> Unit raise @opc_errors.SchemaViolation {
  let mut ctn_count = 0
  let mut target_count = 0
  let mut attr_name_list_count = 0
  let mut last_rank = 0
  for child in cbhvr.children {
    match child {
      @xml.Element(e) => {
        let rank = match e.name.local_name {
          "cTn" => {
            ctn_count = ctn_count + 1
            0
          }
          "tgtEl" => {
            target_count = target_count + 1
            1
          }
          "attrNameLst" => {
            attr_name_list_count = attr_name_list_count + 1
            2
          }
          _ =>
            raise @opc_errors.SchemaViolation(
              section=animation_section,
              path="cBhvr",
              reason="unsupported child element: " + e.name.local_name,
            )
        }
        if rank < last_rank {
          raise @opc_errors.SchemaViolation(
            section=animation_section,
            path="cBhvr",
            reason="child element out of sequence: " + e.name.local_name,
          )
        }
        last_rank = rank
      }
      _ => ()
    }
  }
  if ctn_count == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="cBhvr/cTn",
      reason="missing required <cTn> child",
    )
  }
  if ctn_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="cBhvr/cTn",
      reason="allows exactly one <cTn> child",
    )
  }
  if target_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="cBhvr/tgtEl",
      reason="allows at most one <tgtEl> child",
    )
  }
  if attr_name_list_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="cBhvr/attrNameLst",
      reason="allows at most one <attrNameLst> child",
    )
  }
}

///|
fn decode_attr_name_list(
  cbhvr : @xml.Element,
) -> Array[String] raise @opc_errors.SchemaViolation {
  match first_child_by_local_name(cbhvr, "attrNameLst") {
    Some(list) => {
      validate_list_element_children(list, "attrNameLst", "attrName")
      try @domain.CT_TLBehaviorAttributeNameList::from_element(list) catch {
        e => {
          raise_domain_schema("attrNameLst", e)
          []
        }
      } noraise {
        attr_list => attr_list.attr_names
      }
    }
    None => []
  }
}

///|
/// Fold the anim-specific from/to/by/calcmode/valueType attributes
/// plus the tavLst keypoints into the common record. Called by
/// `decode_anim` after the cBhvr is decoded.
fn with_anim_attrs(
  common : @domain.CT_TLCommonBehaviorData,
  calc : String?,
  value_type : String?,
  element : @xml.Element,
) -> @domain.CT_TLCommonBehaviorData raise @opc_errors.SchemaViolation {
  let calc_mode = match calc {
    Some(text) => Some(parse_st_calc_mode(text))
    None => None
  }
  let value_type_enum = match value_type {
    Some(text) => Some(parse_st_value_type(text))
    None => None
  }
  let vt : @domain.ST_TLAnimateBehaviorValueType = match value_type_enum {
    Some(t) => t
    None => ValueTypeStr
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
    override_behavior: common.override_behavior,
    runtime_context: common.runtime_context,
    transform_type: common.transform_type,
  }
}

///|
fn with_angle_from_to_by(
  common : @domain.CT_TLCommonBehaviorData,
  element : @xml.Element,
  path : String,
) -> @domain.CT_TLCommonBehaviorData raise @opc_errors.SchemaViolation {
  let from_value = angle_variant_attr(element, "from", path + "/@from")
  let to_value = angle_variant_attr(element, "to", path + "/@to")
  let by_value = angle_variant_attr(element, "by", path + "/@by")
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
    override_behavior: common.override_behavior,
    runtime_context: common.runtime_context,
    transform_type: common.transform_type,
  }
}

///|
fn angle_variant_attr(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> @domain.CT_TLAnimVariant? raise @opc_errors.SchemaViolation {
  match attr_local(element, local_name) {
    Some(text) =>
      Some(@domain.AnimVariantInt(parse_signed_int_attr(text, path)))
    None => None
  }
}

///|
/// Decode the `<p:to>` child variant of a `<p:set>` element. Per
/// §19.5.66 set carries no from/by, only a single `<p:to>` whose
/// child is one of `<p:strVal>`, `<p:intVal>`, `<p:fltVal>`,
/// `<p:boolVal>`, `<p:clrVal>`.
fn with_to_variant(
  common : @domain.CT_TLCommonBehaviorData,
  element : @xml.Element,
) -> @domain.CT_TLCommonBehaviorData raise @opc_errors.SchemaViolation {
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
    override_behavior: None,
    runtime_context: None,
    transform_type: None,
  }
}

///|
fn validate_absent_attributes(
  element : @xml.Element,
  path : String,
  names : Array[String],
) -> Unit raise @opc_errors.SchemaViolation {
  for name in names {
    match attr_local(element, name) {
      Some(_) =>
        raise @opc_errors.SchemaViolation(
          section=animation_section,
          path=path + "/@" + name,
          reason="unsupported attribute: " + name,
        )
      None => ()
    }
  }
}

///|
fn validate_required_child(
  element : @xml.Element,
  path : String,
  required_local_name : String,
) -> Unit raise @opc_errors.SchemaViolation {
  let mut required_count = 0
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          name if name == required_local_name =>
            required_count = required_count + 1
          _ =>
            raise @opc_errors.SchemaViolation(
              section=animation_section,
              path~,
              reason="unsupported child element: " + e.name.local_name,
            )
        }
      _ => ()
    }
  }
  if required_count == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/" + required_local_name,
      reason="missing required <" + required_local_name + "> child",
    )
  }
  if required_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/" + required_local_name,
      reason="allows exactly one <" + required_local_name + "> child",
    )
  }
}

///|
fn validate_required_optional_child_pair(
  element : @xml.Element,
  path : String,
  required_local_name : String,
  optional_local_name : String,
) -> Unit raise @opc_errors.SchemaViolation {
  let mut required_count = 0
  let mut optional_count = 0
  let mut seen_optional = false
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          name if name == required_local_name => {
            if seen_optional {
              raise @opc_errors.SchemaViolation(
                section=animation_section,
                path~,
                reason="child element out of sequence: " + name,
              )
            }
            required_count = required_count + 1
          }
          name if name == optional_local_name => {
            seen_optional = true
            optional_count = optional_count + 1
          }
          _ =>
            raise @opc_errors.SchemaViolation(
              section=animation_section,
              path~,
              reason="unsupported child element: " + e.name.local_name,
            )
        }
      _ => ()
    }
  }
  if required_count == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/" + required_local_name,
      reason="missing required <" + required_local_name + "> child",
    )
  }
  if required_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/" + required_local_name,
      reason="allows exactly one <" + required_local_name + "> child",
    )
  }
  if optional_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/" + optional_local_name,
      reason="allows at most one <" + optional_local_name + "> child",
    )
  }
}

///|
fn validate_anim_clr_children(
  element : @xml.Element,
) -> Unit raise @opc_errors.SchemaViolation {
  let mut cbhvr_count = 0
  let mut by_count = 0
  let mut from_count = 0
  let mut to_count = 0
  let mut last_rank = 0
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let rank = match e.name.local_name {
          "cBhvr" => {
            cbhvr_count = cbhvr_count + 1
            0
          }
          "by" => {
            by_count = by_count + 1
            1
          }
          "from" => {
            from_count = from_count + 1
            2
          }
          "to" => {
            to_count = to_count + 1
            3
          }
          _ =>
            raise @opc_errors.SchemaViolation(
              section=animation_section,
              path="animClr",
              reason="unsupported child element: " + e.name.local_name,
            )
        }
        if rank < last_rank {
          raise @opc_errors.SchemaViolation(
            section=animation_section,
            path="animClr",
            reason="child element out of sequence: " + e.name.local_name,
          )
        }
        last_rank = rank
      }
      _ => ()
    }
  }
  if cbhvr_count == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="animClr/cBhvr",
      reason="missing required <cBhvr> child",
    )
  }
  if cbhvr_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="animClr/cBhvr",
      reason="allows exactly one <cBhvr> child",
    )
  }
  if by_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="animClr/by",
      reason="allows at most one <by> child",
    )
  }
  if from_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="animClr/from",
      reason="allows at most one <from> child",
    )
  }
  if to_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="animClr/to",
      reason="allows at most one <to> child",
    )
  }
}

///|
fn validate_anim_point_children(
  element : @xml.Element,
  path : String,
  allow_r_ctr : Bool,
) -> Unit raise @opc_errors.SchemaViolation {
  let mut cbhvr_count = 0
  let mut by_count = 0
  let mut from_count = 0
  let mut to_count = 0
  let mut r_ctr_count = 0
  let mut last_rank = 0
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let rank = match e.name.local_name {
          "cBhvr" => {
            cbhvr_count = cbhvr_count + 1
            0
          }
          "by" => {
            validate_tl_point_child(e, path + "/by")
            by_count = by_count + 1
            1
          }
          "from" => {
            validate_tl_point_child(e, path + "/from")
            from_count = from_count + 1
            2
          }
          "to" => {
            validate_tl_point_child(e, path + "/to")
            to_count = to_count + 1
            3
          }
          "rCtr" if allow_r_ctr => {
            validate_tl_point_child(e, path + "/rCtr")
            r_ctr_count = r_ctr_count + 1
            4
          }
          _ =>
            raise @opc_errors.SchemaViolation(
              section=animation_section,
              path~,
              reason="unsupported child element: " + e.name.local_name,
            )
        }
        if rank < last_rank {
          raise @opc_errors.SchemaViolation(
            section=animation_section,
            path~,
            reason="child element out of sequence: " + e.name.local_name,
          )
        }
        last_rank = rank
      }
      _ => ()
    }
  }
  if cbhvr_count == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/cBhvr",
      reason="missing required <cBhvr> child",
    )
  }
  if cbhvr_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/cBhvr",
      reason="allows exactly one <cBhvr> child",
    )
  }
  if by_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/by",
      reason="allows at most one <by> child",
    )
  }
  if from_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/from",
      reason="allows at most one <from> child",
    )
  }
  if to_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/to",
      reason="allows at most one <to> child",
    )
  }
  if r_ctr_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path=path + "/rCtr",
      reason="allows at most one <rCtr> child",
    )
  }
}

///|
fn validate_tl_point_child(
  element : @xml.Element,
  path : String,
) -> Unit raise @opc_errors.SchemaViolation {
  for child in element.children {
    match child {
      @xml.Element(e) =>
        raise @opc_errors.SchemaViolation(
          section=animation_section,
          path~,
          reason="unsupported child element: " + e.name.local_name,
        )
      _ => ()
    }
  }
  try @domain.CT_TLPoint::from_element(element) catch {
    e => raise_domain_schema(path, e)
  } noraise {
    _ => ()
  }
}

///|
/// animClr's from/to/by are wrapped colour elements rather than
/// scalar attributes. We capture the raw serialised text of each
/// endpoint so renderers can re-parse them through the DML colour
/// resolver.
fn with_endpoint_color(
  common : @domain.CT_TLCommonBehaviorData,
  element : @xml.Element,
  local_name : String,
) -> @domain.CT_TLCommonBehaviorData raise @opc_errors.SchemaViolation {
  let endpoint = first_child_by_local_name(element, local_name)
  match endpoint {
    None => common
    Some(e) => {
      if local_name == "by" {
        validate_by_color_transform(e, local_name)
      } else {
        validate_color_choice_endpoint(e, local_name)
      }
      let payload = serialise_color_endpoint(e)
      match local_name {
        "from" =>
          {
            target_shape_id: common.target_shape_id,
            attr_names: common.attr_names,
            additive: common.additive,
            accumulate: common.accumulate,
            from_value: Some(@domain.AnimVariantColor(payload)),
            to_value: common.to_value,
            by_value: common.by_value,
            tav_list: common.tav_list,
            calc_mode: common.calc_mode,
            value_type: common.value_type,
            override_behavior: common.override_behavior,
            runtime_context: common.runtime_context,
            transform_type: common.transform_type,
          }
        "to" =>
          {
            target_shape_id: common.target_shape_id,
            attr_names: common.attr_names,
            additive: common.additive,
            accumulate: common.accumulate,
            from_value: common.from_value,
            to_value: Some(@domain.AnimVariantColor(payload)),
            by_value: common.by_value,
            tav_list: common.tav_list,
            calc_mode: common.calc_mode,
            value_type: common.value_type,
            override_behavior: common.override_behavior,
            runtime_context: common.runtime_context,
            transform_type: common.transform_type,
          }
        _ =>
          {
            target_shape_id: common.target_shape_id,
            attr_names: common.attr_names,
            additive: common.additive,
            accumulate: common.accumulate,
            from_value: common.from_value,
            to_value: common.to_value,
            by_value: Some(@domain.AnimVariantColor(payload)),
            tav_list: common.tav_list,
            calc_mode: common.calc_mode,
            value_type: common.value_type,
            override_behavior: common.override_behavior,
            runtime_context: common.runtime_context,
            transform_type: common.transform_type,
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
          None => {
            let attrs = serialise_element_attributes(element)
            if attrs.length() == 0 {
              return tag
            }
            return tag + ":" + attrs
          }
        }
      }
      _ => ()
    }
  }
  ""
}

///|
fn serialise_element_attributes(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for i, attr in element.attributes {
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string(attr.name.local_name)
    buf.write_string("=")
    buf.write_string(attr.value)
  }
  buf.to_string()
}

///|
/// Decode a `<p:tavLst>` (CT_TLTimeAnimateValueList §19.5.80)
/// keypoint list under an anim/animRot/animScale element. Returns an
/// empty array when the list is absent.
fn decode_tav_list(
  element : @xml.Element,
) -> Array[@domain.CT_TLTimeAnimateValue] raise @opc_errors.SchemaViolation {
  let list = first_child_by_local_name(element, "tavLst")
  let result : Array[@domain.CT_TLTimeAnimateValue] = []
  match list {
    Some(l) => {
      validate_list_element_children(l, "tavLst", "tav")
      for child in l.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "tav" {
              result.push(decode_tav(e))
            }
          _ => ()
        }
      }
    }
    None => ()
  }
  result
}

///|
/// Decode a single `<p:tav>` (CT_TLTimeAnimateValue §19.5.79)
/// keypoint. Optional `tm` defaults to `indefinite`; present values
/// are either `indefinite`, a percentage, or an unsignedInt. Numeric
/// values are normalised to `[0.0, 1.0]`.
pub fn decode_tav(
  element : @xml.Element,
) -> @domain.CT_TLTimeAnimateValue raise @opc_errors.SchemaViolation {
  let tm = attr_local(element, "tm")
  let tm_percent = match tm {
    Some(text) => parse_tav_time(text)
    None => None
  }
  validate_optional_child_element(element, "tav", "val")
  let value_el = first_child_by_local_name(element, "val")
  let value = match value_el {
    Some(v) => decode_anim_variant(v)
    None => None
  }
  let fmla = match attr_local(element, "fmla") {
    Some(text) => text
    None => ""
  }
  { tm_percent, value, fmla }
}

///|
fn validate_optional_child_element(
  element : @xml.Element,
  path : String,
  expected_local_name : String,
) -> Unit raise @opc_errors.SchemaViolation {
  let mut expected_count = 0
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == expected_local_name {
          expected_count = expected_count + 1
        } else {
          raise @opc_errors.SchemaViolation(
            section=animation_section,
            path~,
            reason="unsupported child element: " + e.name.local_name,
          )
        }
      _ => ()
    }
  }
  if expected_count > 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path~,
      reason="allows at most one <" + expected_local_name + "> child",
    )
  }
}

///|
/// Decode a `<p:val>` (CT_TLAnimVariant §19.5.92) element. The child
/// element (`<p:boolVal>` / `<p:intVal>` / `<p:fltVal>` / `<p:strVal>`
/// / `<p:clrVal>`) selects the variant.
pub fn decode_anim_variant(
  val_element : @xml.Element,
) -> @domain.CT_TLAnimVariant? raise @opc_errors.SchemaViolation {
  validate_anim_variant_choice(val_element)
  for child in val_element.children {
    match child {
      @xml.Element(element) => {
        let kind_local = element.name.local_name
        let value = attr_local(element, "val")
        match kind_local {
          "boolVal" => {
            let text = require_anim_variant_val(value, "boolVal/@val")
            return Some(
              @domain.AnimVariantBool(parse_xsd_bool(text, "boolVal/@val")),
            )
          }
          "intVal" => {
            let text = require_anim_variant_val(value, "intVal/@val")
            match parse_signed_int(text) {
              Some(n) => return Some(@domain.AnimVariantInt(n))
              None =>
                raise @opc_errors.SchemaViolation(
                  section=animation_section,
                  path="intVal/@val",
                  reason="malformed integer: " + text,
                )
            }
          }
          "fltVal" => {
            let text = require_anim_variant_val(value, "fltVal/@val")
            match parse_double(text) {
              Some(d) => return Some(@domain.AnimVariantFloat(d))
              None =>
                raise @opc_errors.SchemaViolation(
                  section=animation_section,
                  path="fltVal/@val",
                  reason="malformed float: " + text,
                )
            }
          }
          "strVal" => {
            let text = require_anim_variant_val(value, "strVal/@val")
            return Some(@domain.AnimVariantString(text))
          }
          "clrVal" => {
            validate_color_choice_endpoint(element, "clrVal")
            let payload = serialise_color_endpoint(element)
            return Some(@domain.AnimVariantColor(payload))
          }
          _ => ()
        }
      }
      _ => ()
    }
  }
  None
}

///|
fn validate_anim_variant_choice(
  val_element : @xml.Element,
) -> Unit raise @opc_errors.SchemaViolation {
  let element_count = count_element_children(val_element)
  let choice_count = count_anim_variant_choices(val_element)
  let path = val_element.name.local_name
  if choice_count == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path~,
      reason="missing required boolVal|intVal|fltVal|strVal|clrVal choice",
    )
  }
  if element_count != 1 || choice_count != 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path~,
      reason="expected exactly one boolVal|intVal|fltVal|strVal|clrVal choice",
    )
  }
}

///|
fn count_element_children(element : @xml.Element) -> Int {
  let mut count = 0
  for child in element.children {
    match child {
      @xml.Element(_) => count = count + 1
      _ => ()
    }
  }
  count
}

///|
fn count_anim_variant_choices(element : @xml.Element) -> Int {
  let mut count = 0
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "boolVal" | "intVal" | "fltVal" | "strVal" | "clrVal" =>
            count = count + 1
          _ => ()
        }
      _ => ()
    }
  }
  count
}

///|
fn validate_color_choice_endpoint(
  endpoint : @xml.Element,
  path : String,
) -> Unit raise @opc_errors.SchemaViolation {
  let element_count = count_element_children(endpoint)
  let choice_count = count_color_choice_children(endpoint)
  if choice_count == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path~,
      reason="missing required color choice",
    )
  }
  if element_count != 1 || choice_count != 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path~,
      reason="expected exactly one color choice",
    )
  }
}

///|
fn validate_by_color_transform(
  endpoint : @xml.Element,
  path : String,
) -> Unit raise @opc_errors.SchemaViolation {
  let element_count = count_element_children(endpoint)
  let choice_count = count_by_color_transform_children(endpoint)
  if choice_count == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path~,
      reason="missing required rgb|hsl choice",
    )
  }
  if element_count != 1 || choice_count != 1 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path~,
      reason="expected exactly one rgb|hsl choice",
    )
  }
  try @domain.CT_TLByAnimateColorTransform::from_element(endpoint) catch {
    e => raise_domain_schema(path, e)
  } noraise {
    _ => ()
  }
}

///|
fn count_color_choice_children(element : @xml.Element) -> Int {
  let mut count = 0
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "scrgbClr"
          | "srgbClr"
          | "hslClr"
          | "sysClr"
          | "schemeClr"
          | "prstClr" => count = count + 1
          _ => ()
        }
      _ => ()
    }
  }
  count
}

///|
fn count_by_color_transform_children(element : @xml.Element) -> Int {
  let mut count = 0
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "rgb" | "hsl" => count = count + 1
          _ => ()
        }
      _ => ()
    }
  }
  count
}

///|
fn require_anim_variant_val(
  value : String?,
  path : String,
) -> String raise @opc_errors.SchemaViolation {
  match value {
    Some(text) => text
    None =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path~,
        reason="missing required @val attribute",
      )
  }
}

///|
fn variant_from_attr(
  text : String,
  value_type : @domain.ST_TLAnimateBehaviorValueType,
) -> @domain.CT_TLAnimVariant {
  match value_type {
    ValueTypeNum =>
      match parse_double(text) {
        Some(d) => @domain.AnimVariantFloat(d)
        None => @domain.AnimVariantString(text)
      }
    ValueTypeStr => @domain.AnimVariantString(text)
    ValueTypeClr => @domain.AnimVariantColor(text)
  }
}

///|
/// Parse a tav `tm` attribute. Recognised forms:
///   - the literal `indefinite` → `None`
///   - a percentage like `25%` → 0.25
///   - an unsignedInt 0..100000 (ST_PositiveFixedPercentage in
///     thousandths) → divided by 100000.
fn parse_tav_time(text : String) -> Double? raise @opc_errors.SchemaViolation {
  let trimmed = trim_whitespace(text)
  if trimmed == "indefinite" {
    return None
  }
  if trimmed.length() == 0 {
    raise @opc_errors.SchemaViolation(
      section=animation_section,
      path="tav/@tm",
      reason="malformed ST_TLTimeAnimateValueTime: " + text,
    )
  }
  let last = trimmed.code_unit_at(trimmed.length() - 1).to_int()
  if last == 0x25 {
    let body = trimmed.unsafe_substring(start=0, end=trimmed.length() - 1)
    match parse_double(body) {
      Some(d) => return Some(d / 100.0)
      None =>
        raise @opc_errors.SchemaViolation(
          section=animation_section,
          path="tav/@tm",
          reason="malformed ST_TLTimeAnimateValueTime: " + text,
        )
    }
  }
  match parse_unsigned_int(trimmed) {
    Some(n) => Some(n.to_double() / 100000.0)
    None =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="tav/@tm",
        reason="malformed ST_TLTimeAnimateValueTime: " + text,
      )
  }
}

///|
fn parse_percentage_attr(
  text : String,
  path : String,
) -> Double raise @opc_errors.SchemaViolation {
  match parse_percentage(text) {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path~,
        reason="malformed ST_PositiveFixedPercentage: " + text,
      )
  }
}

///|
fn parse_xsd_bool(
  text : String,
  path : String,
) -> Bool raise @opc_errors.SchemaViolation {
  match text {
    "1" | "true" => true
    "0" | "false" => false
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path~,
        reason="invalid xsd:boolean lexical form: " + text,
      )
  }
}

///|
fn parse_signed_int_attr(
  text : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  match parse_signed_int(text) {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path~,
        reason="malformed xsd:int: " + text,
      )
  }
}

///|
fn parse_unsigned_int_attr(
  text : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  match parse_unsigned_int(trim_whitespace(text)) {
    Some(value) => value
    None =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path~,
        reason="malformed xsd:unsignedInt: " + text,
      )
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
  // Behaviour leaves: cTn lives inside cBhvr.
  let behaviour_ctn = match first_child_by_local_name(element, "cBhvr") {
    Some(cb) => first_child_by_local_name(cb, "cTn")
    None => None
  }
  match behaviour_ctn {
    Some(_) => behaviour_ctn
    None =>
      // Media leaves: cTn lives inside cMediaNode.
      match first_child_by_local_name(element, "cMediaNode") {
        Some(media) => first_child_by_local_name(media, "cTn")
        None => None
      }
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

// === ST_* lexical wrappers ================================================
//
// Bridge from the `@domain.SchemaViolation` raised by the typed ST_*
// parsers to the `@opc_errors.SchemaViolation` the timing engine
// surfaces. Each helper re-raises with the spec section anchor and
// the originating attribute path.

///|
fn raise_schema(
  path : String,
  err : @domain.SchemaViolation,
) -> Unit raise @opc_errors.SchemaViolation {
  let @domain.SchemaViolation(type_name~, value~, reason~) = err
  raise @opc_errors.SchemaViolation(
    section=animation_section,
    path~,
    reason=reason + " (ST=" + type_name + ", value=" + value + ")",
  )
}

///|
fn raise_domain_schema(
  path : String,
  err : @domain.SchemaViolation,
) -> Unit raise @opc_errors.SchemaViolation {
  let @domain.SchemaViolation(type_name~, value~, reason~) = err
  raise @opc_errors.SchemaViolation(
    section=animation_section,
    path~,
    reason=reason + " (type=" + type_name + ", value=" + value + ")",
  )
}

///|
fn parse_st_tl_time_opt(
  text : String,
  path : String,
) -> @domain.ST_TLTime? raise @opc_errors.SchemaViolation {
  let trimmed = trim_whitespace(text)
  if trimmed.length() == 0 {
    return None
  }
  try @domain.ST_TLTime::parse(trimmed) catch {
    e => {
      raise_schema(path, e)
      None
    }
  } noraise {
    v => Some(v)
  }
}

///|
fn parse_st_fill_type(
  text : String,
) -> @domain.ST_TLTimeNodeFillType raise @opc_errors.SchemaViolation {
  try @domain.ST_TLTimeNodeFillType::parse(text) catch {
    e => {
      raise_schema("cTn/@fill", e)
      @domain.NodeFillRemove
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_restart_type(
  text : String,
) -> @domain.ST_TLTimeNodeRestartType raise @opc_errors.SchemaViolation {
  try @domain.ST_TLTimeNodeRestartType::parse(text) catch {
    e => {
      raise_schema("cTn/@restart", e)
      @domain.RestartAlways
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_node_type(
  text : String,
) -> @domain.ST_TLTimeNodeType raise @opc_errors.SchemaViolation {
  try @domain.ST_TLTimeNodeType::parse(text) catch {
    e => {
      raise_schema("cTn/@nodeType", e)
      @domain.NodeTmRoot
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_preset_class(
  text : String,
) -> @domain.ST_TLTimeNodePresetClassType raise @opc_errors.SchemaViolation {
  try @domain.ST_TLTimeNodePresetClassType::parse(text) catch {
    e => {
      raise_schema("cTn/@presetClass", e)
      @domain.PresetEntr
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_calc_mode(
  text : String,
) -> @domain.ST_TLAnimateBehaviorCalcMode raise @opc_errors.SchemaViolation {
  try @domain.ST_TLAnimateBehaviorCalcMode::parse(text) catch {
    e => {
      raise_schema("anim/@calcmode", e)
      @domain.CalcModeLin
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_value_type(
  text : String,
) -> @domain.ST_TLAnimateBehaviorValueType raise @opc_errors.SchemaViolation {
  try @domain.ST_TLAnimateBehaviorValueType::parse(text) catch {
    e => {
      raise_schema("anim/@valueType", e)
      @domain.ValueTypeStr
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_additive_type(
  text : String,
) -> @domain.ST_TLBehaviorAdditiveType raise @opc_errors.SchemaViolation {
  try @domain.ST_TLBehaviorAdditiveType::parse(text) catch {
    e => {
      raise_schema("cBhvr/@additive", e)
      @domain.AdditiveNone
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_accumulate_type(
  text : String,
) -> @domain.ST_TLBehaviorAccumulateType raise @opc_errors.SchemaViolation {
  try @domain.ST_TLBehaviorAccumulateType::parse(text) catch {
    e => {
      raise_schema("cBhvr/@accumulate", e)
      @domain.AccumulateNone
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_trigger_event(
  text : String,
) -> @domain.ST_TLTriggerEvent raise @opc_errors.SchemaViolation {
  try @domain.ST_TLTriggerEvent::parse(text) catch {
    e => {
      raise_schema("cond/@evt", e)
      @domain.TriggerBegin
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_runtime_node(
  text : String,
) -> @domain.ST_TLTriggerRuntimeNode raise @opc_errors.SchemaViolation {
  try @domain.ST_TLTriggerRuntimeNode::parse(text) catch {
    e => {
      raise_schema("rtn/@val", e)
      @domain.RuntimeFirst
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_color_space(
  text : String,
) -> @domain.ST_TLAnimateColorSpace raise @opc_errors.SchemaViolation {
  try @domain.ST_TLAnimateColorSpace::parse(text) catch {
    e => {
      raise_schema("animClr/@clrSpc", e)
      @domain.ColorSpaceRgb
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_color_direction(
  text : String,
) -> @domain.ST_TLAnimateColorDirection raise @opc_errors.SchemaViolation {
  try @domain.ST_TLAnimateColorDirection::parse(text) catch {
    e => {
      raise_schema("animClr/@dir", e)
      @domain.ColorDirCw
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_motion_origin(
  text : String,
) -> @domain.ST_TLAnimateMotionBehaviorOrigin raise @opc_errors.SchemaViolation {
  try @domain.ST_TLAnimateMotionBehaviorOrigin::parse(text) catch {
    e => {
      raise_schema("animMotion/@origin", e)
      @domain.MotionOriginParent
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_path_edit_mode(
  text : String,
) -> @domain.ST_TLAnimateMotionPathEditMode raise @opc_errors.SchemaViolation {
  try @domain.ST_TLAnimateMotionPathEditMode::parse(text) catch {
    e => {
      raise_schema("animMotion/@pathEditMode", e)
      @domain.PathEditRelative
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_command_type(
  text : String,
) -> @domain.ST_TLCommandType raise @opc_errors.SchemaViolation {
  try @domain.ST_TLCommandType::parse(text) catch {
    e => {
      raise_schema("cmd/@type", e)
      @domain.CommandCall
    }
  } noraise {
    v => v
  }
}

///|
fn parse_st_effect_transition(
  text : String,
) -> @domain.ST_TLAnimateEffectTransition raise @opc_errors.SchemaViolation {
  try @domain.ST_TLAnimateEffectTransition::parse(text) catch {
    e => {
      raise_schema("animEffect/@transition", e)
      @domain.EffectTransitionIn
    }
  } noraise {
    v => v
  }
}
