// === §19.5 PresentationML animation — typed complex types ================
//
// XSD complex types in `pml.xsd` annex (Part 1 §A.3) backing the
// `<p:timing>` content model. Each struct/enum mirrors the schema's
// element/attribute layout exactly so the timing engine can reason
// about animation behaviour without re-parsing raw XML.

///|
/// XSD complex type CT_TLAnimVariant — Part 1 §19.5.92 val (Value).
/// Discriminated union of the five `<p:val>` child variants:
/// `boolVal` (CT_TLAnimVariantBooleanVal §19.5.19),
/// `intVal`  (CT_TLAnimVariantIntegerVal §19.5.48),
/// `fltVal`  (CT_TLAnimVariantFloatVal §19.5.42),
/// `strVal`  (CT_TLAnimVariantStringVal §19.5.75), and
/// `clrVal`  (a:CT_Color §19.5.27 — kept as the serialised colour
///            payload so the DML colour-resolution pass owns the
///            decode of scheme/srgb/sysClr tokens).
pub(all) enum CT_TLAnimVariant {
  /// §19.5.19 boolVal — `<p:boolVal val="…"/>`.
  AnimVariantBool(Bool)
  /// §19.5.48 intVal — `<p:intVal val="…"/>`.
  AnimVariantInt(Int)
  /// §19.5.42 fltVal — `<p:fltVal val="…"/>`.
  AnimVariantFloat(Double)
  /// §19.5.75 strVal — `<p:strVal val="…"/>`.
  AnimVariantString(String)
  /// §19.5.27 clrVal — serialised `<p:clrVal>` payload; the renderer
  /// re-parses it through the DML colour resolver.
  AnimVariantColor(String)
} derive(Eq, Debug)

///|
/// Best-effort numeric extraction. `AnimVariantBool(true)` maps to
/// 1.0, `AnimVariantBool(false)` to 0.0. `AnimVariantString` and
/// `AnimVariantColor` return `None` because their semantics are
/// opaque to the timing engine.
pub fn CT_TLAnimVariant::as_double(self : CT_TLAnimVariant) -> Double? {
  match self {
    AnimVariantBool(true) => Some(1.0)
    AnimVariantBool(false) => Some(0.0)
    AnimVariantInt(n) => Some(n.to_double())
    AnimVariantFloat(d) => Some(d)
    AnimVariantString(_) => None
    AnimVariantColor(_) => None
  }
}

///|
/// XSD complex type CT_TLTimeAnimateValue — Part 1 §19.5.79 tav (Time
/// Animate Value). A single keypoint inside a `<p:tavLst>` driving
/// the `<p:anim>` interpolation curve.
///
/// `tm` is `ST_TLTimeAnimateValueTime` (§19.7.39); `None` represents
/// `indefinite`, otherwise the percentage is normalised to `[0.0, 1.0]`.
/// `value` holds the optional `<p:val>` child (CT_TLAnimVariant).
/// `fmla` is the optional formula attribute (xsd:string, default "").
pub(all) struct CT_TLTimeAnimateValue {
  /// §19.5.79 @tm — `None` ⇔ `indefinite`; otherwise the value is in
  /// `[0.0, 1.0]` (raw ST_PositiveFixedPercentage divided by 100).
  tm_percent : Double?
  /// §19.5.79 child `<p:val>` (CT_TLAnimVariant §19.5.92).
  value : CT_TLAnimVariant?
  /// §19.5.79 @fmla — optional formula string; empty when absent.
  fmla : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_TLCommonBehaviorData — Part 1 §19.5.22 cBhvr
/// (Common Behavior). The shared behaviour metadata wrapped around
/// every leaf behaviour (anim / animClr / animMotion / animRot /
/// animScale / set / cmd).
///
/// Children:
///   * `cTn` (CT_TLCommonTimeNodeData §19.5.33) — inflated separately
///     by the timing engine, not stored here to avoid the recursive
///     cycle.
///   * `tgtEl` (CT_TLTimeTargetElement §19.5.81) — surfaced as
///     `target_shape_id` (the `<p:spTgt @spid>` integer).
///   * `attrNameLst` (CT_TLBehaviorAttributeNameList §19.5.8) —
///     surfaced verbatim as `attr_names`.
///
/// Attributes:
///   * `additive` — ST_TLBehaviorAdditiveType §19.7.28.
///   * `accumulate` — ST_TLBehaviorAccumulateType §19.7.27.
///   * `from`/`to`/`by` — xsd:string. Folded into the typed
///     `CT_TLAnimVariant` endpoints by the leaf-specific decoders so
///     callers receive values matching the leaf's `valueType`.
///   * `tav_list` — `<p:tavLst>` keypoints (CT_TLTimeAnimateValueList
///     §19.5.80); lives on the leaf element rather than cBhvr but is
///     folded in for uniform downstream evaluation.
///   * `calc_mode` — ST_TLAnimateBehaviorCalcMode §19.7.20. Lives on
///     the anim leaf only; folded here so interpolation has it.
///   * `value_type` — ST_TLAnimateBehaviorValueType §19.7.21. Same.
pub(all) struct CT_TLCommonBehaviorData {
  /// `<p:tgtEl><p:spTgt @spid>` resolved to the target shape's
  /// drawing-element id; `None` when the behaviour targets a non-
  /// shape element (text run, OLE chart, …).
  target_shape_id : Int?
  /// `<p:attrNameLst><p:attrName>` text children verbatim.
  attr_names : Array[String]
  /// §19.5.22 @additive.
  additive : ST_TLBehaviorAdditiveType?
  /// §19.5.22 @accumulate.
  accumulate : ST_TLBehaviorAccumulateType?
  /// §19.5.22 @from / §19.5.1 @from (folded into typed variant).
  from_value : CT_TLAnimVariant?
  /// §19.5.22 @to / §19.5.1 @to.
  to_value : CT_TLAnimVariant?
  /// §19.5.22 @by / §19.5.1 @by.
  by_value : CT_TLAnimVariant?
  /// §19.5.80 tavLst keypoints folded into the common record.
  tav_list : Array[CT_TLTimeAnimateValue]
  /// §19.5.1 @calcmode (anim-only; None elsewhere).
  calc_mode : ST_TLAnimateBehaviorCalcMode?
  /// §19.5.1 @valueType (anim-only; None elsewhere).
  value_type : ST_TLAnimateBehaviorValueType?
  /// §19.5.6 @override (ST_TLBehaviorOverride) — "normal" /
  /// "childStyle"; `None` when absent.
  override_behavior : String?
  /// §19.5.6 @rctx (ST_TLBehaviorRuntimeContext) — runtime context
  /// ("DOM" / "session"); `None` when absent.
  runtime_context : String?
  /// §19.5.6 @xfrmType (ST_TLBehaviorTransformType) — "pt" / "img";
  /// `None` when absent.
  transform_type : String?
} derive(Eq, Debug)

///|
/// True when the cBhvr carries no animatable payload — i.e. no
/// from/to/by and no tavLst. Such a behaviour is treated as a
/// no-op during snapshot evaluation but still emits Start/End
/// events because callers may rely on those for paragraph
/// builds.
pub fn CT_TLCommonBehaviorData::is_empty(
  self : CT_TLCommonBehaviorData,
) -> Bool {
  if self.from_value is Some(_) {
    return false
  }
  if self.to_value is Some(_) {
    return false
  }
  if self.by_value is Some(_) {
    return false
  }
  if self.tav_list.length() > 0 {
    return false
  }
  true
}

///|
/// XSD complex type CT_TLAnimateBehavior — Part 1 §19.5.1 anim
/// (Animate). Generic attribute animation. The `cBhvr` shared block
/// is folded into `common`; tavLst keypoints and the
/// from/to/by/calcmode/valueType attributes are already merged into
/// the common record by the decoder.
pub(all) struct CT_TLAnimateBehavior {
  /// §19.5.22 cBhvr (CT_TLCommonBehaviorData) with anim-specific
  /// attrs already folded.
  common : CT_TLCommonBehaviorData
} derive(Eq, Debug)

///|
/// XSD complex type CT_TLAnimateColorBehavior — Part 1 §19.5.2
/// animClr (Animate Color Behavior). The `from`/`to`/`by` children
/// are colour transforms; the renderer reparses them through the
/// DML colour resolver.
pub(all) struct CT_TLAnimateColorBehavior {
  /// §19.5.22 cBhvr.
  common : CT_TLCommonBehaviorData
  /// §19.5.2 @clrSpc — ST_TLAnimateColorSpace §19.7.23 (rgb / hsl).
  color_space : ST_TLAnimateColorSpace?
  /// §19.5.2 @dir — ST_TLAnimateColorDirection §19.7.22 (cw / ccw).
  direction : ST_TLAnimateColorDirection?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TLAnimateMotionBehavior — Part 1 §19.5.4
/// animMotion (Animate Motion). The path string is kept opaque;
/// renderers parse the SVG-like grammar themselves.
pub(all) struct CT_TLAnimateMotionBehavior {
  /// §19.5.22 cBhvr.
  common : CT_TLCommonBehaviorData
  /// §19.5.4 @origin — ST_TLAnimateMotionBehaviorOrigin §19.7.25.
  origin : ST_TLAnimateMotionBehaviorOrigin?
  /// §19.5.4 @path — SVG-like motion path grammar; opaque to the engine.
  path : String?
  /// §19.5.4 @pathEditMode — ST_TLAnimateMotionPathEditMode §19.7.26.
  path_edit_mode : ST_TLAnimateMotionPathEditMode?
  /// §19.5.4 @rAng — rotation angle, ST_Angle (kept as raw decimal).
  r_ang : Double?
  /// §19.5.4 @ptsTypes — XML token list describing path control-point
  /// kinds; kept verbatim because the renderer interprets it.
  pts_types : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TLAnimateRotationBehavior — Part 1 §19.5.5
/// animRot (Animate Rotation). Rotation is animated around the
/// shape's rotation centre; `from`/`to`/`by` are angles folded into
/// the common record.
pub(all) struct CT_TLAnimateRotationBehavior {
  /// §19.5.22 cBhvr.
  common : CT_TLCommonBehaviorData
} derive(Eq, Debug)

///|
/// XSD complex type CT_TLAnimateScaleBehavior — Part 1 §19.5.6
/// animScale (Animate Scale).
pub(all) struct CT_TLAnimateScaleBehavior {
  /// §19.5.22 cBhvr.
  common : CT_TLCommonBehaviorData
  /// §19.5.6 @zoomContents — when true, nested content scales along
  /// with the shape; `None` defers to the renderer default (false).
  zoom_contents : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TLSetBehavior — Part 1 §19.5.66 set (Set Time
/// Node Behavior). Discrete fixed-value behaviour; only the `to`
/// value is meaningful (from/by/tavLst are ignored per the spec).
pub(all) struct CT_TLSetBehavior {
  /// §19.5.22 cBhvr (with `<p:to>` variant folded into `common.to_value`).
  common : CT_TLCommonBehaviorData
} derive(Eq, Debug)

///|
/// XSD complex type CT_TLCommandBehavior — Part 1 §19.5.28 cmd
/// (Command). Opaque command behaviour (call / event / verb). The
/// engine records the command type and payload so a runtime can
/// dispatch later; no execution happens here.
pub(all) struct CT_TLCommandBehavior {
  /// §19.5.22 cBhvr.
  common : CT_TLCommonBehaviorData
  /// §19.5.28 @type — ST_TLCommandType §19.7.32 (evt / call / verb).
  command_type : ST_TLCommandType?
  /// §19.5.28 @cmd — opaque command payload; renderer dispatch.
  command_value : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TLAnimateEffectBehavior — Part 1 §19.5.3
/// animEffect (Animate Effect). The schema-owned raw wrapper lives in
/// `transition_timing_types.mbt`; this runtime projection folds
/// `<p:cBhvr>` into the same `CT_TLCommonBehaviorData` SoT used by the
/// other leaf timing behaviours while preserving the effect-specific
/// attributes.
pub(all) struct CT_TLAnimateEffectRuntimeBehavior {
  /// §19.5.22 cBhvr.
  common : CT_TLCommonBehaviorData
  /// §19.5.3 child `<p:progress>` (CT_TLAnimVariant).
  progress : CT_TLAnimVariant?
  /// §19.5.3 @transition (ST_TLAnimateEffectTransition).
  transition : ST_TLAnimateEffectTransition?
  /// §19.5.3 @filter (xsd:string).
  filter : String?
  /// §19.5.3 @prLst (xsd:string).
  pr_lst : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TLTimeCondition — Part 1 §19.5.31 cond
/// (Condition). A single condition entry inside a `<p:stCondLst>`,
/// `<p:endCondLst>`, `<p:nextCondLst>`, or `<p:prevCondLst>`.
///
/// Per the schema, the choice is exactly one of `<p:tgtEl>`,
/// `<p:tn>`, `<p:rtn>`; we surface the parts the timing engine
/// actually needs (`tgtEl/spTgt/@spid` and `tn/@val`).
pub(all) struct CT_TLTimeCondition {
  /// §19.5.31 @delay — ST_TLTime §19.7.38; `None` when absent.
  delay : ST_TLTime?
  /// §19.5.31 @evt — ST_TLTriggerEvent §19.7.48; `None` when absent.
  event : ST_TLTriggerEvent?
  /// §19.5.31 `<p:tgtEl><p:spTgt @spid>` — drawing-element id of the
  /// triggering shape; `None` when the condition is not shape-bound.
  target_shape_id : Int?
  /// §19.5.31 `<p:tn @val>` — id of the runtime time-node being
  /// targeted; `None` when no `<p:tn>` child is present.
  target_runtime_node_id : Int?
} derive(Eq, Debug)

///|
/// True when the condition can be honoured at schedule time — i.e.
/// the event is None or a non-runtime (begin / end / onBegin / onEnd)
/// trigger that the engine treats as immediate.
pub fn CT_TLTimeCondition::is_static(self : CT_TLTimeCondition) -> Bool {
  match self.event {
    None => true
    Some(evt) => !st_tl_trigger_event_is_runtime(evt)
  }
}

///|
/// True when the trigger event must be resolved at runtime (the
/// user-driven events that cannot be scheduled statically).
/// §19.7.48 — `onClick`, `onDblClick`, `onMouseOver`, `onMouseOut`,
/// `onNext`, `onPrev`, `onStopAudio` are runtime events; the
/// remaining `begin`/`end`/`onBegin`/`onEnd` resolve to immediate
/// schedule offsets.
pub fn st_tl_trigger_event_is_runtime(event : ST_TLTriggerEvent) -> Bool {
  match event {
    TriggerOnClick => true
    TriggerOnDblClick => true
    TriggerOnMouseOver => true
    TriggerOnMouseOut => true
    TriggerOnNext => true
    TriggerOnPrev => true
    TriggerOnStopAudio => true
    _ => false
  }
}

///|
/// XSD complex type CT_TLCommonTimeNodeData — Part 1 §19.5.33 cTn
/// (Common Time Node Properties). Every animation node owns one cTn
/// child; this struct surfaces every attribute and child list the
/// timing engine needs.
///
/// Notes:
///   * `delay` is **not** part of the cTn schema (§19.5.33). Start
///     delays live on `<p:cond>` entries inside `start_conditions`.
///   * `repeat_count` defaults to `ST_TLTime` thousandths
///     (`TLTimeMs(1000)` ⇔ 1 iteration); use
///     `ct_tl_common_time_node_repeat_iterations` to convert into a
///     whole-iteration count.
///   * `node_kind` is the discriminator from the parent element
///     (`<p:par>` / `<p:seq>` / `<p:excl>` / leaf behaviour).
pub(all) struct CT_TLCommonTimeNodeData {
  /// §19.5.33 @id — ST_TLTimeNodeID §19.7.42 (xsd:unsignedInt).
  /// `0` when absent.
  node_id : Int
  /// §19.5.33 @nodeType — ST_TLTimeNodeType §19.7.47.
  node_type : ST_TLTimeNodeType?
  /// §19.5.33 @presetClass — ST_TLTimeNodePresetClassType §19.7.44.
  preset_class : ST_TLTimeNodePresetClassType?
  /// §19.5.33 @presetID — xsd:int.
  preset_id : Int?
  /// §19.5.33 @dur — ST_TLTime §19.7.38.
  duration : ST_TLTime?
  /// §19.5.33 @restart — ST_TLTimeNodeRestartType §19.7.45.
  restart : ST_TLTimeNodeRestartType?
  /// §19.5.33 @fill — ST_TLTimeNodeFillType §19.7.41.
  fill : ST_TLTimeNodeFillType?
  /// §19.5.33 @repeatCount — ST_TLTime §19.7.38; default
  /// `TLTimeMs(1000)` ⇔ 1 iteration.
  repeat_count : ST_TLTime?
  /// §19.5.33 @accel — ST_PositiveFixedPercentage (default 0%).
  /// Held as the unit-interval double (0.0 .. 1.0).
  accel : Double
  /// §19.5.33 @decel — ST_PositiveFixedPercentage (default 0%).
  decel : Double
  /// §19.5.33 @autoRev — xsd:boolean (default false).
  auto_reverse : Bool
  /// §19.5.33 child `<p:stCondLst>` (CT_TLTimeConditionList §19.5.73).
  start_conditions : Array[CT_TLTimeCondition]
  /// §19.5.33 child `<p:endCondLst>` (CT_TLTimeConditionList §19.5.37).
  end_conditions : Array[CT_TLTimeCondition]
  /// §19.5.65 `<p:seq>` child `<p:nextCondLst>` — only populated for
  /// sequence nodes; empty array otherwise.
  next_conditions : Array[CT_TLTimeCondition]
  /// §19.5.65 `<p:seq>` child `<p:prevCondLst>` — only populated for
  /// sequence nodes; empty array otherwise.
  prev_conditions : Array[CT_TLTimeCondition]
  /// Parent-element discriminator (par/seq/excl/leaf). The wrapped
  /// behaviour record (when present) already carries its own folded
  /// cBhvr; container kinds (Par/Seq/Excl) carry no payload.
  node_kind : CT_TLCommonTimeNodeKind
  /// §19.5.33 child `<p:childTnLst>` (CT_TimeNodeList §19.5.25) —
  /// recursively decoded child time-nodes.
  children : Array[CT_TLCommonTimeNodeData]
  /// §19.5.12 @afterEffect (xsd:boolean) — after-effect node; default false.
  after_effect : Bool
  /// §19.5.12 @display (xsd:boolean) — node is displayed; default true.
  display : Bool
  /// §19.5.12 @bldLvl (xsd:int) — build level; `None` when absent.
  bld_lvl : Int?
  /// §19.5.12 @grpId (xsd:unsignedInt) — build group id; `None` absent.
  grp_id : Int?
  /// §19.5.12 @presetSubtype (xsd:int) — preset subtype; `None` absent.
  preset_subtype : Int?
  /// §19.5.12 @evtFilter (xsd:string) — event filter; `None` absent.
  evt_filter : String?
  /// §19.5.12 @masterRel (ST_TLTimeNodeMasterRelation) — master
  /// timeline relation; `None` absent.
  master_rel : String?
  /// §19.5.12 @nodePh (xsd:boolean) — node is a placeholder; `None`
  /// when absent.
  node_ph : Bool?
  /// §19.5.12 @repeatDur (ST_TLTime) — repeat duration; `None` absent.
  repeat_dur : ST_TLTime?
  /// §19.5.12 @spd (ST_Percentage) — playback speed; `None` absent.
  spd : String?
  /// §19.5.12 @syncBehavior (ST_TLTimeNodeSyncType) — "canSlip" /
  /// "locked"; `None` absent.
  sync_behavior : String?
  /// §19.5.12 @tmFilter (xsd:string) — time filter list; `None` absent.
  tm_filter : String?
} derive(Eq, Debug)

///|
/// Parent-element discriminator for `CT_TLCommonTimeNodeData`.
/// Encodes the choice from `CT_TimeNodeList` §19.5.25 (par / seq /
/// excl / anim / animClr / animEffect / animMotion / animRot /
/// animScale / set / cmd / audio / video).
pub(all) enum CT_TLCommonTimeNodeKind {
  /// §19.5.53 par (CT_TLTimeNodeParallel).
  TimeNodePar
  /// §19.5.65 seq (CT_TLTimeNodeSequence).
  TimeNodeSeq
  /// §19.5.40 excl (CT_TLTimeNodeExclusive).
  TimeNodeExcl
  /// §19.5.1 anim (CT_TLAnimateBehavior).
  TimeNodeAnimate(CT_TLAnimateBehavior)
  /// §19.5.2 animClr (CT_TLAnimateColorBehavior).
  TimeNodeAnimateColor(CT_TLAnimateColorBehavior)
  /// §19.5.3 animEffect (CT_TLAnimateEffectBehavior).
  TimeNodeAnimateEffect(CT_TLAnimateEffectRuntimeBehavior)
  /// §19.5.4 animMotion (CT_TLAnimateMotionBehavior).
  TimeNodeAnimateMotion(CT_TLAnimateMotionBehavior)
  /// §19.5.5 animRot (CT_TLAnimateRotationBehavior).
  TimeNodeAnimateRotation(CT_TLAnimateRotationBehavior)
  /// §19.5.6 animScale (CT_TLAnimateScaleBehavior).
  TimeNodeAnimateScale(CT_TLAnimateScaleBehavior)
  /// §19.5.66 set (CT_TLSetBehavior).
  TimeNodeSet(CT_TLSetBehavior)
  /// §19.5.28 cmd (CT_TLCommandBehavior).
  TimeNodeCommand(CT_TLCommandBehavior)
  /// §19.5.49 audio (CT_TLMediaNodeAudio).
  TimeNodeAudio(CT_TLMediaNodeAudio)
  /// §19.5.85 video (CT_TLMediaNodeVideo).
  TimeNodeVideo(CT_TLMediaNodeVideo)
} derive(Eq, Debug)

///|
/// True when the cTn discriminator is a leaf behaviour (anim,
/// animClr, animMotion, animRot, animScale, set, cmd, audio,
/// video). The walker uses this to short-circuit the children
/// traversal when collecting active behaviours.
pub fn CT_TLCommonTimeNodeData::is_leaf(self : CT_TLCommonTimeNodeData) -> Bool {
  match self.node_kind {
    TimeNodePar => false
    TimeNodeSeq => false
    TimeNodeExcl => false
    _ => true
  }
}

///|
/// Extract the leaf `CT_TLCommonBehaviorData` for any leaf cTn.
/// Returns `None` for container kinds (par/seq/excl).
pub fn CT_TLCommonTimeNodeData::behavior_common(
  self : CT_TLCommonTimeNodeData,
) -> CT_TLCommonBehaviorData? {
  match self.node_kind {
    TimeNodeAnimate(b) => Some(b.common)
    TimeNodeAnimateColor(b) => Some(b.common)
    TimeNodeAnimateEffect(b) => Some(b.common)
    TimeNodeAnimateMotion(b) => Some(b.common)
    TimeNodeAnimateRotation(b) => Some(b.common)
    TimeNodeAnimateScale(b) => Some(b.common)
    TimeNodeSet(b) => Some(b.common)
    TimeNodeCommand(b) => Some(b.common)
    _ => None
  }
}

///|
/// Iteration count for `cTn/@repeatCount` (ST_TLTime in thousandths
/// per §19.5.33 default `"1000"`). Returns a sentinel `-1` for
/// `TLTimeIndefinite`; callers must treat negative values as "loop
/// forever". `None` (attribute absent) collapses to 1 iteration.
pub fn ct_tl_common_time_node_repeat_iterations(
  repeat_count : ST_TLTime?,
) -> Int {
  match repeat_count {
    None => 1
    Some(TLTimeIndefinite) => -1
    Some(TLTimeMs(thousandths)) => {
      // ST_TLTime stores `unsignedInt` thousandths; round to the
      // nearest whole iteration and clamp to >= 1 so a stray "0"
      // does not vanish a behaviour that the spec says must run at
      // least once.
      let n = (thousandths.reinterpret_as_int() + 500) / 1000
      if n < 1 {
        1
      } else {
        n
      }
    }
  }
}

///|
/// Schema pml.xsd complex type `CT_TLTimeAnimateValueList`.
/// Child elements: `tav`. Child types: `CT_TLTimeAnimateValue`.
///
/// XSD complex type CT_TLTimeAnimateValueList — Part 1 §19.5.97
/// (`tavLst`).  Sequence: zero or more `<p:tav>` (CT_TLTimeAnimateValue)
/// keyframe entries.  Wrapper preserves the source XML element so the
/// container round-trips byte-identically; the typed projection of
/// each `<p:tav>` lives on the owning `CT_TLAnimateBehavior`.
pub(all) struct CT_TLTimeAnimateValueList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// §19.5.81 — the `<p:tav>` (CT_TLTimeAnimateValue) keyframe entries
  /// in document order, retained raw.  The typed list makes the
  /// keyframe sequence queryable instead of opaque.
  tav : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn CT_TLTimeAnimateValueList::new(
  element : @xml.Element,
) -> CT_TLTimeAnimateValueList {
  let tav : Array[@xml.Element] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "tav" {
      tav.push(e)
    }
  }
  { element, tav }
}

///|
/// Schema pml.xsd complex type `CT_TLTimeConditionList`.
/// Child elements: `cond`. Child types: `CT_TLTimeCondition`.
///
/// XSD complex type CT_TLTimeConditionList — Part 1 §19.5.37 / §19.5.73
/// (`endCondLst` / `stCondLst`).  Sequence: one or more `<p:cond>`
/// (CT_TLTimeCondition) entries.  Wrapper preserves the source XML
/// element so the container round-trips byte-identically; the typed
/// projection of each `<p:cond>` lives on the owning time node's
/// start/end-condition list.
pub(all) struct CT_TLTimeConditionList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// §19.5.27 — the `<p:cond>` (CT_TLTimeCondition) entries in document
  /// order, retained raw.  The typed list makes the condition sequence
  /// queryable instead of opaque.
  cond : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn CT_TLTimeConditionList::new(
  element : @xml.Element,
) -> CT_TLTimeConditionList {
  let cond : Array[@xml.Element] = []
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == "cond" {
      cond.push(e)
    }
  }
  { element, cond }
}

///|
/// Schema pml.xsd complex type `CT_TimeNodeList`.
/// Child elements: `par`, `seq`, `excl`, `anim`, `animClr`, `animEffect`,
/// `animMotion`, `animRot`, `animScale`, `cmd`, `set`, `audio`, `video`.
///
/// XSD complex type CT_TimeNodeList — Part 1 §19.5.25 (`childTnLst`).
/// Choice (minOccurs=1, maxOccurs=unbounded) of any time-node element:
/// `par`/`seq`/`excl` containers or `anim*`/`cmd`/`set`/`audio`/`video`
/// leaf behaviors.  Element-order preserving wrapper around the source
/// XML so the choice is round-trip safe even when the typed view is
/// limited to the document-order sequence.
pub(all) struct CT_TimeNodeList {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// §19.5.84 — the time-node children (`par`/`seq`/`excl`/`anim*`/
  /// `cmd`/`set`/`audio`/`video`) in document order.  Each is retained
  /// as its raw element; the typed list makes the choice sequence
  /// queryable instead of opaque.
  time_nodes : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn CT_TimeNodeList::new(element : @xml.Element) -> CT_TimeNodeList {
  let time_nodes : Array[@xml.Element] = []
  for child in element.children {
    if child is @xml.Node::Element(e) {
      time_nodes.push(e)
    }
  }
  { element, time_nodes }
}
