# G15 — PresentationML Animation Timing Engine

Tracks the Tier-3 gap "PML slide animations timing engine" from
`.indexion/plans/shallow-audit/audit.md` (#16). Depends on the
G14 placeholder resolver only for the `spTgt @spid` resolution
helpers; the timing engine itself is self-contained.

## Source sections

- Part 1 §19.5 `timing` — the slide-level `<p:timing>` element that
  hosts every animation. Owned by `CT_SlideTiming`.
- Part 1 §19.5.33 `cTn` / `CT_TLCommonTimeNodeData` — every time-node
  carries this child. Attributes (subset honoured here):
  `id`, `dur`, `delay`, `restart`, `fill`, `repeatCount`, `accel`,
  `decel`, `autoRev`, `nodeType`, `presetClass`, `presetID`.
- Part 1 §19.5.53 `par` / `CT_TLTimeNodeParallel` — parallel container.
- Part 1 §19.5.65 `seq` / `CT_TLTimeNodeSequence` — sequence container
  (children start when the previous child ends; `nextAc` / `prevAc`).
- Part 1 §19.5.40 `excl` / `CT_TLTimeNodeExclusive` — exclusive
  container (modelled as `Seq` with `concurrent=false` semantics).
- Part 1 §19.5.1 `anim` / `CT_TLAnimateBehavior` — generic attribute
  tween (`from`, `to`, `by`, `calcmode`, `valueType`, `tavLst`).
- Part 1 §19.5.2 `animClr` / `CT_TLAnimateColorBehavior` — color tween.
- Part 1 §19.5.4 `animMotion` / `CT_TLAnimateMotionBehavior` — motion
  tween (path geometry remains opaque — the engine emits string
  values).
- Part 1 §19.5.5 `animRot` / `CT_TLAnimateRotationBehavior` — rotation.
- Part 1 §19.5.6 `animScale` / `CT_TLAnimateScaleBehavior` — scale.
- Part 1 §19.5.66 `set` / `CT_TLSetBehavior` — discrete set value.
- Part 1 §19.5.28 `cmd` / `CT_TLCommandBehavior` — opaque command
  (recorded as a Command leaf, no dispatch).
- Part 1 §19.5.22 `cBhvr` / `CT_TLCommonBehaviorData` — wrapper that
  holds the `<p:cTn>` + `<p:tgtEl>` + `<p:attrNameLst>` triple shared
  by every behavior.
- Part 1 §19.5.31 `cond` / `CT_TLTimeCondition` — `delay` + `evt`
  trigger + optional `tgtEl` / `tn` runtime references.
- Part 1 §19.5.73 `stCondLst` / §19.5.37 `endCondLst` /
  §19.5.51 `nextCondLst` / §19.5.55 `prevCondLst` — condition lists.
- Part 1 §19.5.79 `tav` / §19.5.80 `tavLst` — keypoint list with
  `tm` (`ST_TLTimeAnimateValueTime` — `%` percentage or
  `indefinite`).
- Part 1 §19.5.92 `val` / `CT_TLAnimVariant` — `boolVal`, `intVal`,
  `fltVal`, `strVal`, `clrVal` children.
- Part 1 §19.5.82 `tmAbs` / §19.5.83 `tmPct` — used inside `iterate`;
  surfaced as `IterateInterval` but iterate execution itself is out
  of scope (Requirement 8 below).
- Part 1 §19.5.81 `tgtEl` / §19.5.72 `spTgt` / §19.5.86 `tn` —
  target / trigger references.
- Part 1 §19.7.38 `ST_TLTime`, §19.7.40 `ST_TLTimeIndefinite` —
  `unsignedInt` ms or the lexical `indefinite`.
- Part 1 §19.7.41 `ST_TLTimeNodeFillType` — `freeze`, `hold`, `remove`,
  `transition`.
- Part 1 §19.7.45 `ST_TLTimeNodeRestartType` — `always`, `never`,
  `whenNotActive`.
- Part 1 §19.7.47 `ST_TLTimeNodeType` — `tmRoot`, `mainSeq`,
  `clickEffect`, `withEffect`, `afterEffect`, `clickPar`,
  `withGroup`, `afterGroup`, `interactiveSeq`.
- Part 1 §19.7.48 `ST_TLTriggerEvent` — `begin`, `end`, `onBegin`,
  `onEnd`, `onClick`, `onDblClick`, `onMouseOver`, `onMouseOut`,
  `onNext`, `onPrev`, `onStopAudio`.
- Part 1 §19.7.20 `ST_TLAnimateBehaviorCalcMode` — `discrete`, `lin`,
  `fmla`.
- Part 1 §19.7.21 `ST_TLAnimateBehaviorValueType` — `clr`, `num`,
  `str`.

## Functional requirements

### Requirement 1: Typed time-node tree

`decode_time_node_list(@xml.Element)` shall walk `<p:tnLst>` and
return an `Array[TimeNode]` where each `TimeNode` carries:

- `node_id : Int` (from `cTn/@id`, defaults to `0` when absent).
- `node_type : NodeType?` (`tmRoot`, `mainSeq`, …; absent when @nodeType
  is not on the cTn).
- `preset_class : PresetClass?` and `preset_id : Int?`.
- `duration : TimeValue?` (`Indefinite` or `Ms(Int)`).
- `delay : TimeValue?` (cTn/@delay; rare — primarily on conditions).
- `restart : RestartType?`.
- `fill : FillType?` (`hold`, `freeze`, `remove`, `transition`).
- `repeat_count : RepeatCount?` (per §19.5.33 — thousandths of a unit
  iteration, or `indefinite`).
- `accel : Double` (0..1, default 0).
- `decel : Double` (0..1, default 0).
- `auto_reverse : Bool`.
- `start_conditions / end_conditions / next_conditions /
  prev_conditions : Array[TimeCondition]`.
- `kind : TimeNodeKind` discriminating
  `Par`, `Seq`, `Excl`, `AnimateBehavior(AnimateBehavior)`,
  `AnimateColorBehavior(AnimateColorBehavior)`,
  `AnimateMotionBehavior(MotionBehavior)`,
  `AnimateRotationBehavior(RotationBehavior)`,
  `AnimateScaleBehavior(ScaleBehavior)`,
  `SetBehavior(SetBehavior)`,
  `CommandBehavior(CommandBehavior)`.
- `children : Array[TimeNode]` (from `cTn/childTnLst`).

Attribute-parse failures shall raise `@opc_errors.SchemaViolation`.

### Requirement 2: Behavior decoding

Each leaf time-node owns a `BehaviorCommon` derived from
`CT_TLCommonBehaviorData` carrying:

- `target_shape_id : Int?` (`<p:tgtEl><p:spTgt @spid>`).
- `attr_names : Array[String]` (`<p:attrNameLst>` children).
- `additive : AdditiveType?` and `accumulate : AccumulateType?`.
- `from_value : AnimVariant?` / `to_value : AnimVariant?` /
  `by_value : AnimVariant?`.
- `tav_list : Array[Tav]` — each `Tav` holding `tm_percent : Double?`
  (None when `indefinite`) and `value : AnimVariant?`.
- `calc_mode : CalcMode?` and `value_type : ValueType?`
  (anim only; defaults to `Lin` / `Str`).

### Requirement 3: Condition decoding

`decode_condition(@xml.Element)` shall return `TimeCondition` with:

- `delay : TimeValue?`.
- `event : TriggerEvent?`.
- `target_shape_id : Int?` and `target_runtime_node_id : Int?`
  (from `<p:tgtEl><p:spTgt>` and `<p:tn @val>` respectively).

### Requirement 4: decode_timing

`decode_timing(@domain.CT_SlideTiming)` shall return a `Timeline`
struct holding the root time-node list.

### Requirement 5: TimingEngine scheduling

`TimingEngine::schedule(timeline)` shall return a flat list of
`Event` records ordered by `at_ms`. Events:

- `Start { node_id, at_ms }` for every time-node whose start is
  statically resolvable.
- `End { node_id, at_ms }` for nodes that have a finite duration
  (single iteration; repeat handled by Requirement 7).
- `PropertyAt { node_id, attr_name, value, at_ms, progress }` for
  every `tav` keypoint of each behavior, plus one event for each
  endpoint of an `anim/animClr/animRot/animScale` with `from`/`to`.
- `ConditionalStart { node_id, condition }` when a node's start
  condition is event-driven (`onClick`, `onPrev`, `onNext`, etc.)
  — those nodes are not scheduled at a numeric time.

Conditions with `delay="<ms>"` and no `evt` shall contribute that
delay to the node's static start time. `tmAbs` conditions on `cond`
are not part of stCondLst (they live inside `iterate`) and are not
honoured here.

Sequence (`seq`) nodes shall offset every child's static start by
the previous child's end time. Parallel (`par`) nodes shall start
every child at the parent's start time. Exclusive (`excl`) nodes
are treated like `seq` for scheduling.

### Requirement 6: animate() snapshot

`TimingEngine::animate(timeline, target_time_ms)` shall return an
`Array[ActiveBehavior]` describing every behavior whose
`[start, end]` interval contains `target_time_ms`. Each
`ActiveBehavior` carries:

- `node_id : Int`.
- `target_shape_id : Int?`.
- `attr_name : String` (one entry per attrName in
  `attrNameLst`; behaviors with multiple attrNames emit one
  `ActiveBehavior` per attrName).
- `value : AnimVariant` — interpolated from `tavLst` (when
  present) or from `from`/`to` / `to` / `by` per §19.5.1.
- `progress : Double` — 0..1, with `accel` / `decel` ease applied
  per §19.5.33.

Interpolation rules:

- `tavLst` keypoints in ascending `tm` order. For numeric values
  (`fltVal`, `intVal`), linear interpolation between adjacent
  keypoints (or step for `calcmode="discrete"`).
- `from`/`to` without `tavLst`: linear interpolation across the
  duration. `to`-only is treated as `tav tm=100%`.
- For colour and string values, the engine returns the lower
  keypoint's value (no interpolation) — these are surfaced for
  renderers that own DML color resolution.
- Fill mode handling: when target_time_ms > end_ms, the behavior
  is still emitted if `fill = hold | freeze | transition` (with
  `progress = 1.0`); `remove` removes the behavior from the
  snapshot. Default fill is `remove`.

### Requirement 7: Repeat handling

When `repeat_count` is `Iterations(n)` and `n > 1`, the behavior
shall be evaluated at `(t - start) mod single_dur`; the engine
emits `PropertyAt` events for each cycle's endpoint. `auto_reverse`
toggles the direction every other cycle.

### Requirement 8: Diagnostic helper

`animation_part1_19_5_section_name()` shall return the canonical
citation `Part 1 §19.5` for use by callers in error reports.

## Non-functional requirements

- Pure functions on `@xml.Element` / `@domain` wrappers. No I/O.
- `pub fn` bodies satisfy the indexion SHALLOW gate (>4 lines of
  non-trivial logic).
- White-box tests in `*_wbtest.mbt` exercise every Requirement.

## Out of scope (documented exclusions)

- `iterate` / `tmAbs` / `tmPct` execution semantics. The decoder
  records the presence of `iterate` but the engine does not run
  text-build iterations; renderers can re-use the typed tree.
- `animMotion` motion-path SVG (the `path` attribute is preserved
  verbatim as a `String?`; the engine does not parse curves).
- Event dispatch for `onClick` / `onMouseOver`. Conditional starts
  are surfaced as `ConditionalStart` events; an interactive runtime
  is responsible for materialising them.
- DML color interpolation (`animClr`): the engine surfaces the
  endpoint colour tokens; theme-color → RGB resolution belongs to
  `drawing_ml/color_resolution`.
- Build elements (`bldP`, `bldDgm`, `bldOleChart`, `bldGraphic`,
  `bldLst`, `bldSub`) and template lists (`tmpl`, `tmplLst`):
  parsed as opaque containers, not expanded into per-paragraph or
  per-bullet sub-timelines.
- Slide-transition animations (`fade`, `wipe`, `wheel`, … under the
  `transition` element) — those live in §19.5 but are not part of
  the runtime timing engine.
