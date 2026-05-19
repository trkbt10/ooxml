# G15 — Design

New package: `src/ecma376/presentation_ml/animation_eval/`.

## File layout

```
animation_eval/
  moon.pkg                  -- imports @xml, @opc_errors, @domain
  types.mbt                 -- TimeValue, FillType, RestartType,
                                RepeatCount, NodeType, PresetClass,
                                CalcMode, ValueType, AdditiveType,
                                AccumulateType, TriggerEvent,
                                AnimVariant, Tav, BehaviorCommon,
                                AnimateBehavior / AnimateColorBehavior /
                                MotionBehavior / RotationBehavior /
                                ScaleBehavior / SetBehavior /
                                CommandBehavior, TimeNode + TimeNodeKind,
                                TimeCondition, Timeline,
                                Event, ActiveBehavior,
                                animation_part1_19_5_section_name
  decode.mbt                -- decode_timing, decode_time_node_list,
                                decode_time_node, decode_par,
                                decode_seq, decode_excl, decode_anim,
                                decode_anim_clr, decode_anim_motion,
                                decode_anim_rot, decode_anim_scale,
                                decode_set, decode_cmd, decode_cbhvr,
                                decode_condition, decode_anim_variant,
                                decode_tav, attribute / xml helpers
  scheduler.mbt             -- TimingEngine, schedule, animate,
                                walk_node, place_par, place_seq,
                                evaluate_behaviors
  interpolate.mbt           -- ease(progress, accel, decel),
                                interpolate_numeric,
                                interpolate_variant,
                                effective_progress (handles
                                repeat + auto_reverse)
  scheduler_wbtest.mbt      -- white-box tests (≥7 cases)
```

## Type sketch (selected)

```
pub(all) enum TimeValue {
  Indefinite
  Ms(Int)
} derive(Eq, Debug)

pub(all) enum FillType {
  FillHold; FillRemove; FillFreeze; FillTransition
} derive(Eq, Debug)

pub(all) enum RestartType {
  RestartAlways; RestartNever; RestartWhenNotActive
} derive(Eq, Debug)

pub(all) enum RepeatCount {
  Iterations(Int)         // §19.5.33 — thousandths-of-iteration
  RepeatIndefinite
} derive(Eq, Debug)

pub(all) enum CalcMode {
  CalcDiscrete; CalcLinear; CalcFormula
} derive(Eq, Debug)

pub(all) enum ValueType {
  ValColor; ValNumber; ValString
} derive(Eq, Debug)

pub(all) enum TriggerEvent {
  EvtBegin; EvtEnd; EvtOnBegin; EvtOnEnd
  EvtOnClick; EvtOnDblClick
  EvtOnMouseOver; EvtOnMouseOut
  EvtOnNext; EvtOnPrev; EvtOnStopAudio
} derive(Eq, Debug)

pub(all) enum AnimVariant {
  BoolVariant(Bool)
  IntVariant(Int)
  FloatVariant(Double)
  StringVariant(String)
  ColorVariant(String)   // raw <p:clrVal> XML serialisation (opaque)
} derive(Eq, Debug)

pub(all) struct Tav {
  tm_percent : Double?   // None when tm="indefinite"
  value : AnimVariant?
} derive(Eq, Debug)

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

pub(all) struct AnimateBehavior {
  common : BehaviorCommon
} derive(Eq, Debug)

// AnimateColorBehavior / MotionBehavior / RotationBehavior /
// ScaleBehavior / SetBehavior / CommandBehavior carry similar
// commons plus their behavior-specific attributes (clr_space, path,
// by_angle, zoom_contents, command_type, …).

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

pub(all) struct TimeCondition {
  delay : TimeValue?
  event : TriggerEvent?
  target_shape_id : Int?
  target_runtime_node_id : Int?
} derive(Eq, Debug)

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

pub(all) struct Timeline {
  roots : Array[TimeNode]
} derive(Eq, Debug)

pub(all) enum EventKind {
  EventStart
  EventEnd
  EventPropertyAt(attr_name : String, value : AnimVariant, progress : Double)
  EventConditionalStart(condition : TimeCondition)
} derive(Eq, Debug)

pub(all) struct Event {
  node_id : Int
  at_ms : Int
  kind : EventKind
} derive(Eq, Debug)

pub(all) struct ActiveBehavior {
  node_id : Int
  target_shape_id : Int?
  attr_name : String
  value : AnimVariant
  progress : Double
} derive(Eq, Debug)

pub(all) struct TimingEngine {
  timeline : Timeline
} derive(Eq, Debug)
```

## Scheduling algorithm

1. `place_node(node, base_ms)` returns
   `(start_ms : Int, end_ms : Int?, events : Array[Event])`.
2. The static start is `base_ms + first non-event start cond delay`.
   If every start condition has an event (e.g. `onClick`), emit a
   `ConditionalStart` event and treat the node's start as `None` for
   scheduling purposes (children inherit `None` too — they become
   conditional).
3. Duration:
   - explicit `dur` wins;
   - else `Par`: max of child end times;
   - else `Seq` / `Excl`: cumulative child durations;
   - else leaves with no `dur` get `0` (instantaneous, matches `<set>`
     default behaviour).
4. Emit `Start` and (if `end_ms is Some`) `End` events. For leaf
   behaviors, walk `tavLst` and emit `PropertyAt` events at
   `start_ms + tm_percent * dur`. If `tavLst` is empty but
   `from`/`to` is present, emit `PropertyAt` for tm=0 and tm=1.
5. `Seq` accumulates child positions sequentially; `Par`/`Excl` place
   each child at the parent's start; `Excl` is modelled identical to
   `Seq` for scheduling because it serialises children too.
6. After tree walk, sort the event list by `(at_ms, node_id, kind
   priority)`.

## animate(target_time_ms)

1. Walk each leaf time-node. For each leaf:
   1. Skip if the leaf has unresolved conditional start.
   2. Compute `(start, end)` via the same walker.
   3. If `target_time_ms < start`: skip.
   4. If `target_time_ms > end`: respect `fill` — `Remove` skips,
      others emit at progress=1.
   5. Else compute raw progress `(target - start) / single_dur`.
      Apply repeat / auto_reverse:
      `cycle = floor(raw)`,
      `local = raw - cycle`,
      if `cycle >= repeat_count`: clamp to end with `fill` logic;
      if `auto_reverse` and `cycle` odd: `local = 1 - local`.
   6. Apply `accel` / `decel` ease.
   7. For every attrName, evaluate `tavLst` (or `from`/`to`) at the
      eased progress to produce an `AnimVariant`.
2. Sort active behaviors by node_id for stable output.

## Cross-package contracts

- Decoder accepts both raw `@xml.Element` and the domain
  `CT_SlideTiming` wrapper. Internal helpers use `@xml.Element`.
- Schema-violation errors carry the canonical
  `Part 1 §19.5.X` citation of the offending element.

## SHALLOW resolution

`types.mbt` holds non-trivial `from_attr` decoders for every enum
(>4 lines each), `BehaviorCommon::is_empty`,
`Timeline::flatten_leaves`, `AnimVariant::as_double`, etc., so the
shallow gate sees concrete code beside every type.

## Test plan (≥7 cases)

1. Decode a `par` with two `set` children: ensure node tree, ids,
   target shape ids.
2. Decode a `seq` with two `anim` children offset 0ms / 1000ms:
   schedule produces Start/End events in order.
3. Decode `clickEffect` cTn: schedule emits
   `ConditionalStart(onClick)` event.
4. Decode `anim` with `from="0"` `to="100"` `dur=1000`: animate at
   t=0/500/1000 produces 0.0 / 50.0 / 100.0.
5. Decode `anim` with explicit `tavLst` (0%→0, 50%→25, 100%→100):
   animate at t=500 lerps to 25 / t=750 to 62.5.
6. Decode behavior with `repeatCount=3000` (3 iterations):
   animate at t = 1.5 * single_dur returns 0.5 progress.
7. Verify `fill=hold` produces a snapshot after end time, while
   default `fill=remove` does not.
8. Citation accessor returns `Part 1 §19.5`.
