///|
/// Part 1 §19.7.38 ST_TLTime / §19.7.40 ST_TLTimeIndefinite —
/// duration / delay value used by every animation timing attribute.
/// `Indefinite` corresponds to the lexical token `indefinite` (a
/// value that designates an "indefinite" amount of time); `Ms` is
/// the unsignedInt millisecond value.
pub(all) enum TimeValue {
  Indefinite
  Ms(Int)
} derive(Eq, Debug)

///|
/// Decode an ST_TLTime lexical form. Returns `None` for the empty
/// string so the caller can decide whether absence is significant.
pub fn TimeValue::from_attr(
  value : String,
) -> TimeValue? raise @opc_errors.SchemaViolation {
  let trimmed = trim_whitespace(value)
  if trimmed.length() == 0 {
    return None
  }
  if trimmed == "indefinite" {
    return Some(Indefinite)
  }
  match parse_unsigned_int(trimmed) {
    Some(n) => Some(Ms(n))
    None =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="ST_TLTime",
        reason="malformed ST_TLTime lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.7.41 ST_TLTimeNodeFillType — what the effect leaves on
/// the target element's properties when it ends.
pub(all) enum FillType {
  FillHold
  FillRemove
  FillFreeze
  FillTransition
} derive(Eq, Debug)

///|
/// Decode ST_TLTimeNodeFillType lexical values.
pub fn FillType::from_attr(
  value : String,
) -> FillType raise @opc_errors.SchemaViolation {
  match value {
    "hold" => FillHold
    "remove" => FillRemove
    "freeze" => FillFreeze
    "transition" => FillTransition
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="cTn/@fill",
        reason="unknown ST_TLTimeNodeFillType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.7.45 ST_TLTimeNodeRestartType — whether a node restarts
/// when it completes its action.
pub(all) enum RestartType {
  RestartAlways
  RestartNever
  RestartWhenNotActive
} derive(Eq, Debug)

///|
/// Decode ST_TLTimeNodeRestartType lexical values.
pub fn RestartType::from_attr(
  value : String,
) -> RestartType raise @opc_errors.SchemaViolation {
  match value {
    "always" => RestartAlways
    "never" => RestartNever
    "whenNotActive" => RestartWhenNotActive
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="cTn/@restart",
        reason="unknown ST_TLTimeNodeRestartType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.5.33 cTn/@repeatCount — repeat count expressed in
/// thousandths of an iteration, or the lexical `indefinite`. The
/// engine stores the iteration count as a plain integer; callers
/// retrieve fractional iterations via `RepeatCount::iterations`.
pub(all) enum RepeatCount {
  Iterations(Int)
  RepeatIndefinite
} derive(Eq, Debug)

///|
/// Decode an `@repeatCount` lexical value. `indefinite` becomes
/// `RepeatIndefinite`; any unsignedInt is divided by 1000 (rounded
/// to the nearest integer) so callers see whole iterations.
pub fn RepeatCount::from_attr(
  value : String,
) -> RepeatCount? raise @opc_errors.SchemaViolation {
  let trimmed = trim_whitespace(value)
  if trimmed.length() == 0 {
    return None
  }
  if trimmed == "indefinite" {
    return Some(RepeatIndefinite)
  }
  match parse_unsigned_int(trimmed) {
    Some(thousandths) => {
      let iterations = (thousandths + 500) / 1000
      Some(Iterations(if iterations < 1 { 1 } else { iterations }))
    }
    None =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="cTn/@repeatCount",
        reason="malformed ST_TLTime lexical value: " + value,
      )
  }
}

///|
/// Iteration count for a RepeatCount. `RepeatIndefinite` returns a
/// sentinel `-1`; callers must treat negative values as "loop
/// forever".
pub fn RepeatCount::iterations(self : RepeatCount) -> Int {
  match self {
    Iterations(n) => n
    RepeatIndefinite => -1
  }
}

///|
/// Part 1 §19.7.47 ST_TLTimeNodeType — semantic node classification
/// carried by `cTn/@nodeType`. The engine surfaces it so callers can
/// distinguish click-triggered nodes from after-effect nodes when
/// rendering trigger UI.
pub(all) enum NodeType {
  NodeTmRoot
  NodeMainSeq
  NodeClickEffect
  NodeClickPar
  NodeWithEffect
  NodeAfterEffect
  NodeWithGroup
  NodeAfterGroup
  NodeInteractiveSeq
} derive(Eq, Debug)

///|
/// Decode ST_TLTimeNodeType lexical values.
pub fn NodeType::from_attr(
  value : String,
) -> NodeType raise @opc_errors.SchemaViolation {
  match value {
    "tmRoot" => NodeTmRoot
    "mainSeq" => NodeMainSeq
    "clickEffect" => NodeClickEffect
    "clickPar" => NodeClickPar
    "withEffect" => NodeWithEffect
    "afterEffect" => NodeAfterEffect
    "withGroup" => NodeWithGroup
    "afterGroup" => NodeAfterGroup
    "interactiveSeq" => NodeInteractiveSeq
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="cTn/@nodeType",
        reason="unknown ST_TLTimeNodeType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.7.44 ST_TLTimeNodePresetClassType — entrance / exit /
/// emphasis / path / verb / mediacall classification used by the
/// PowerPoint preset library. Recorded as-is so renderers can map
/// preset_id to an effect implementation.
pub(all) enum PresetClass {
  PresetEntrance
  PresetExit
  PresetEmphasis
  PresetPath
  PresetVerb
  PresetMediaCall
} derive(Eq, Debug)

///|
/// Decode ST_TLTimeNodePresetClassType lexical values.
pub fn PresetClass::from_attr(
  value : String,
) -> PresetClass raise @opc_errors.SchemaViolation {
  match value {
    "entr" => PresetEntrance
    "exit" => PresetExit
    "emph" => PresetEmphasis
    "path" => PresetPath
    "verb" => PresetVerb
    "mediacall" => PresetMediaCall
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="cTn/@presetClass",
        reason="unknown ST_TLTimeNodePresetClassType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.7.20 ST_TLAnimateBehaviorCalcMode — how the animation
/// flows between adjacent keypoints.
pub(all) enum CalcMode {
  CalcDiscrete
  CalcLinear
  CalcFormula
} derive(Eq, Debug)

///|
/// Decode ST_TLAnimateBehaviorCalcMode lexical values.
pub fn CalcMode::from_attr(
  value : String,
) -> CalcMode raise @opc_errors.SchemaViolation {
  match value {
    "discrete" => CalcDiscrete
    "lin" => CalcLinear
    "fmla" => CalcFormula
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="anim/@calcmode",
        reason="unknown ST_TLAnimateBehaviorCalcMode lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.7.21 ST_TLAnimateBehaviorValueType — colour / number /
/// string property type for `<p:anim>`.
pub(all) enum ValueType {
  ValColor
  ValNumber
  ValString
} derive(Eq, Debug)

///|
/// Decode ST_TLAnimateBehaviorValueType lexical values.
pub fn ValueType::from_attr(
  value : String,
) -> ValueType raise @opc_errors.SchemaViolation {
  match value {
    "clr" => ValColor
    "num" => ValNumber
    "str" => ValString
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="anim/@valueType",
        reason="unknown ST_TLAnimateBehaviorValueType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.7.28 ST_TLBehaviorAdditiveType — how the animation
/// value combines with the base property value.
pub(all) enum AdditiveType {
  AdditiveBase
  AdditiveMultiply
  AdditiveNone
  AdditiveReplace
  AdditiveSum
} derive(Eq, Debug)

///|
/// Decode ST_TLBehaviorAdditiveType lexical values.
pub fn AdditiveType::from_attr(
  value : String,
) -> AdditiveType raise @opc_errors.SchemaViolation {
  match value {
    "base" => AdditiveBase
    "mult" => AdditiveMultiply
    "none" => AdditiveNone
    "repl" => AdditiveReplace
    "sum" => AdditiveSum
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="cBhvr/@additive",
        reason="unknown ST_TLBehaviorAdditiveType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.7.27 ST_TLBehaviorAccumulateType — whether successive
/// iterations of a repeating animation build on top of each other.
pub(all) enum AccumulateType {
  AccumulateAlways
  AccumulateNone
} derive(Eq, Debug)

///|
/// Decode ST_TLBehaviorAccumulateType lexical values.
pub fn AccumulateType::from_attr(
  value : String,
) -> AccumulateType raise @opc_errors.SchemaViolation {
  match value {
    "always" => AccumulateAlways
    "none" => AccumulateNone
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="cBhvr/@accumulate",
        reason="unknown ST_TLBehaviorAccumulateType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.7.48 ST_TLTriggerEvent — discriminates the event that
/// fires a `<p:cond>` time condition.
pub(all) enum TriggerEvent {
  EvtBegin
  EvtEnd
  EvtOnBegin
  EvtOnEnd
  EvtOnClick
  EvtOnDblClick
  EvtOnMouseOver
  EvtOnMouseOut
  EvtOnNext
  EvtOnPrev
  EvtOnStopAudio
} derive(Eq, Debug)

///|
/// Decode ST_TLTriggerEvent lexical values.
pub fn TriggerEvent::from_attr(
  value : String,
) -> TriggerEvent raise @opc_errors.SchemaViolation {
  match value {
    "begin" => EvtBegin
    "end" => EvtEnd
    "onBegin" => EvtOnBegin
    "onEnd" => EvtOnEnd
    "onClick" => EvtOnClick
    "onDblClick" => EvtOnDblClick
    "onMouseOver" => EvtOnMouseOver
    "onMouseOut" => EvtOnMouseOut
    "onNext" => EvtOnNext
    "onPrev" => EvtOnPrev
    "onStopAudio" => EvtOnStopAudio
    _ =>
      raise @opc_errors.SchemaViolation(
        section=animation_section,
        path="cond/@evt",
        reason="unknown ST_TLTriggerEvent lexical value: " + value,
      )
  }
}

///|
/// TriggerEvent classification — `is_runtime` flags the user-driven
/// events that cannot be scheduled statically (the engine emits a
/// `ConditionalStart` for them).
pub fn TriggerEvent::is_runtime(self : TriggerEvent) -> Bool {
  match self {
    EvtOnClick => true
    EvtOnDblClick => true
    EvtOnMouseOver => true
    EvtOnMouseOut => true
    EvtOnNext => true
    EvtOnPrev => true
    EvtOnStopAudio => true
    _ => false
  }
}

///|
/// Part 1 §19.5.92 val (CT_TLAnimVariant) — discriminated union of
/// `boolVal`, `intVal`, `fltVal`, `strVal`, and `clrVal` children.
/// The ColorVariant payload carries the raw child XML serialised
/// back to a string because colour semantics belong to the DML
/// colour resolution pass, not this package.
pub(all) enum AnimVariant {
  BoolVariant(Bool)
  IntVariant(Int)
  FloatVariant(Double)
  StringVariant(String)
  ColorVariant(String)
} derive(Eq, Debug)

///|
/// Best-effort numeric extraction. `BoolVariant(true)` maps to 1.0,
/// `BoolVariant(false)` to 0.0. `StringVariant` and `ColorVariant`
/// return `None` because their semantics are opaque to the engine.
pub fn AnimVariant::as_double(self : AnimVariant) -> Double? {
  match self {
    BoolVariant(true) => Some(1.0)
    BoolVariant(false) => Some(0.0)
    IntVariant(n) => Some(n.to_double())
    FloatVariant(d) => Some(d)
    StringVariant(_) => None
    ColorVariant(_) => None
  }
}

///|
/// Part 1 §19.5.79 tav — keypoint for a tavLst-driven animation.
/// `tm_percent` is `None` when the spec value is `indefinite`; the
/// engine then drops the keypoint from interpolation.
pub(all) struct Tav {
  tm_percent : Double?
  value : AnimVariant?
} derive(Eq, Debug)

///|
/// Part 1 §19.5.22 cBhvr — common behaviour data shared by every
/// leaf behaviour (anim / animClr / animMotion / animRot /
/// animScale / set / cmd). `target_shape_id` is the
/// `<p:tgtEl><p:spTgt @spid>` integer; `attr_names` is the
/// `<p:attrNameLst>` text children verbatim.
pub(all) struct BehaviorCommon {
  target_shape_id : Int?
  attr_names : Array[String]
  additive : AdditiveType?
  accumulate : AccumulateType?
  from_value : AnimVariant?
  to_value : AnimVariant?
  by_value : AnimVariant?
  tav_list : Array[Tav]
  calc_mode : CalcMode?
  value_type : ValueType?
} derive(Eq, Debug)

///|
/// True when the cBhvr carries no animatable payload — i.e. no
/// from/to/by and no tavLst. Such a behaviour is treated as a
/// no-op during snapshot evaluation but still emits Start/End
/// events because callers may rely on those for paragraph
/// builds.
pub fn BehaviorCommon::is_empty(self : BehaviorCommon) -> Bool {
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
/// Part 1 §19.5.1 anim — generic attribute animation. Carries the
/// shared cBhvr plus the anim-only `from`/`to`/`by`/`calcmode`/
/// `valueType` attributes already folded into `BehaviorCommon`.
pub(all) struct AnimateBehavior {
  common : BehaviorCommon
} derive(Eq, Debug)

///|
/// Part 1 §19.5.2 animClr — color animation. `color_space` selects
/// HSL vs RGB interpolation; `direction` chooses cw vs ccw on the
/// HSL wheel.
pub(all) struct AnimateColorBehavior {
  common : BehaviorCommon
  color_space : String?
  direction : String?
} derive(Eq, Debug)

///|
/// Part 1 §19.5.4 animMotion — motion-path animation. The path data
/// is kept opaque; renderers parse the SVG-like grammar themselves.
pub(all) struct MotionBehavior {
  common : BehaviorCommon
  origin : String?
  path : String?
  path_edit_mode : String?
  r_ang : Double?
  pts_types : String?
} derive(Eq, Debug)

///|
/// Part 1 §19.5.5 animRot — rotation animation around the shape
/// centre. Angles are stored as decimals interpreted by the renderer.
pub(all) struct RotationBehavior {
  common : BehaviorCommon
} derive(Eq, Debug)

///|
/// Part 1 §19.5.6 animScale — uniform / non-uniform scale animation.
/// `zoom_contents` toggles whether nested content scales along with
/// the shape.
pub(all) struct ScaleBehavior {
  common : BehaviorCommon
  zoom_contents : Bool?
} derive(Eq, Debug)

///|
/// Part 1 §19.5.66 set — discrete fixed-value behaviour. Only the
/// `to` value is meaningful; from/by/tavLst are ignored per the
/// spec wording.
pub(all) struct SetBehavior {
  common : BehaviorCommon
} derive(Eq, Debug)

///|
/// Part 1 §19.5.28 cmd — opaque command behaviour (call / event /
/// verb). The engine records the command type and payload so a
/// runtime can dispatch later; no execution happens here.
pub(all) struct CommandBehavior {
  common : BehaviorCommon
  command_type : String?
  command_value : String?
} derive(Eq, Debug)

///|
/// Part 1 §19.5.53 par / §19.5.65 seq / §19.5.40 excl plus every
/// leaf behaviour kind. Exclusive containers are scheduled like
/// `seq` because they serialise their children too; the
/// distinction matters at runtime when a node interrupts a sibling.
pub(all) enum TimeNodeKind {
  Par
  Seq
  Excl
  AnimateLeaf(AnimateBehavior)
  AnimateColorLeaf(AnimateColorBehavior)
  AnimateMotionLeaf(MotionBehavior)
  AnimateRotationLeaf(RotationBehavior)
  AnimateScaleLeaf(ScaleBehavior)
  SetLeaf(SetBehavior)
  CommandLeaf(CommandBehavior)
} derive(Eq, Debug)

///|
/// Part 1 §19.5.31 cond — a single condition entry. Either a
/// numeric `delay` (counted from the parent's start), an `evt`
/// trigger (resolved at runtime), or both.
pub(all) struct TimeCondition {
  delay : TimeValue?
  event : TriggerEvent?
  target_shape_id : Int?
  target_runtime_node_id : Int?
} derive(Eq, Debug)

///|
/// True when the condition can be honoured at schedule time — i.e.
/// the event is None or a non-runtime (begin / end / onBegin / onEnd)
/// trigger that the engine treats as immediate.
pub fn TimeCondition::is_static(self : TimeCondition) -> Bool {
  match self.event {
    None => true
    Some(evt) => !evt.is_runtime()
  }
}

///|
/// Part 1 §19.5.33 cTn — common time-node properties plus the
/// inflated kind/children. Every animation node owns one cTn child
/// (sequence containers, behaviours, etc.); the engine pulls every
/// useful attribute up to the node level here.
pub(all) struct TimeNode {
  node_id : Int
  node_type : NodeType?
  preset_class : PresetClass?
  preset_id : Int?
  duration : TimeValue?
  delay : TimeValue?
  restart : RestartType?
  fill : FillType?
  repeat_count : RepeatCount?
  accel : Double
  decel : Double
  auto_reverse : Bool
  start_conditions : Array[TimeCondition]
  end_conditions : Array[TimeCondition]
  next_conditions : Array[TimeCondition]
  prev_conditions : Array[TimeCondition]
  kind : TimeNodeKind
  children : Array[TimeNode]
} derive(Eq, Debug)

///|
/// True when the node is a leaf behaviour (anim, animClr, …, set,
/// cmd). The walker uses this to short-circuit the children
/// traversal when collecting active behaviours.
pub fn TimeNode::is_leaf(self : TimeNode) -> Bool {
  match self.kind {
    Par => false
    Seq => false
    Excl => false
    _ => true
  }
}

///|
/// Extract the leaf BehaviorCommon for any leaf TimeNode. Returns
/// `None` for container kinds.
pub fn TimeNode::behavior_common(self : TimeNode) -> BehaviorCommon? {
  match self.kind {
    AnimateLeaf(b) => Some(b.common)
    AnimateColorLeaf(b) => Some(b.common)
    AnimateMotionLeaf(b) => Some(b.common)
    AnimateRotationLeaf(b) => Some(b.common)
    AnimateScaleLeaf(b) => Some(b.common)
    SetLeaf(b) => Some(b.common)
    CommandLeaf(b) => Some(b.common)
    _ => None
  }
}

///|
/// Part 1 §19.5 timing — the typed root of a slide's animation
/// tree. `roots` corresponds to the children of `<p:timing>/
/// <p:tnLst>` (typically exactly one root `<p:par>` per spec
/// examples).
pub(all) struct Timeline {
  roots : Array[TimeNode]
} derive(Eq, Debug)

///|
/// Flatten every leaf time-node in depth-first order. Useful for
/// callers that want to iterate behaviours without re-walking the
/// container kinds themselves.
pub fn Timeline::flatten_leaves(self : Timeline) -> Array[TimeNode] {
  let result : Array[TimeNode] = []
  for root in self.roots {
    collect_leaves(root, result)
  }
  result
}

///|
fn collect_leaves(node : TimeNode, result : Array[TimeNode]) -> Unit {
  if node.is_leaf() {
    result.push(node)
  }
  for child in node.children {
    collect_leaves(child, result)
  }
}

///|
/// Schedule event kind — emitted by `TimingEngine::schedule`.
/// `EventPropertyAt` carries the keypoint value at the scheduled
/// instant; `EventConditionalStart` represents a node whose start
/// depends on a runtime event.
pub(all) enum EventKind {
  EventStart
  EventEnd
  EventPropertyAt(String, AnimVariant, Double)
  EventConditionalStart(TimeCondition)
} derive(Eq, Debug)

///|
/// Schedule entry. `at_ms` is the absolute time (ms from timeline
/// start) for scheduled events; for `EventConditionalStart` it is
/// the earliest possible time the node could fire (typically 0 or
/// the parent's start).
pub(all) struct Event {
  node_id : Int
  at_ms : Int
  kind : EventKind
} derive(Eq, Debug)

///|
/// Snapshot row — one entry per (leaf node, attrName) combination
/// active at the queried time.
pub(all) struct ActiveBehavior {
  node_id : Int
  target_shape_id : Int?
  attr_name : String
  value : AnimVariant
  progress : Double
} derive(Eq, Debug)

///|
/// Stateful container for a decoded timeline. The engine is
/// immutable; callers construct one per `<p:timing>` and re-use it
/// for every schedule / animate query.
pub(all) struct TimingEngine {
  timeline : Timeline
} derive(Eq, Debug)

///|
let animation_section : String = "Part 1 §19.5"

///|
/// Part 1 §19.5 — citation helper exposed so callers can include
/// the canonical section anchor in their own diagnostics. Returns
/// the string "Part 1 §19.5".
pub fn animation_part1_19_5_section_name() -> String {
  animation_section
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

///|
fn parse_unsigned_int(text : String) -> Int? {
  if text.length() == 0 {
    return None
  }
  let mut value = 0
  for i in 0..<text.length() {
    let unit = text.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10 + (unit - 0x30)
  }
  Some(value)
}
