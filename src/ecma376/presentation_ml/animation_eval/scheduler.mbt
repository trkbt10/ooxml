///|
/// Construct a TimingEngine from a Timeline. The engine owns the
/// decoded tree by reference; it does not mutate it during
/// `schedule` / `animate`.
pub fn TimingEngine::new(timeline : Timeline) -> TimingEngine {
  { timeline, }
}

///|
/// Walk the timeline and produce a flat event list ordered by
/// `at_ms`. Conditional starts (onClick / onPrev / …) are emitted as
/// `EventConditionalStart` placeholders carrying the offending
/// condition; the children of conditional nodes are not scheduled.
pub fn TimingEngine::schedule(self : TimingEngine) -> Array[Event] {
  let events : Array[Event] = []
  let placements : Array[Placement] = []
  for root in self.timeline.roots {
    let _ = place_node(root, 0, events, false, placements)
  }
  events.sort_by(fn(a, b) {
    if a.at_ms < b.at_ms {
      return -1
    }
    if a.at_ms > b.at_ms {
      return 1
    }
    if a.node_id < b.node_id {
      return -1
    }
    if a.node_id > b.node_id {
      return 1
    }
    event_priority(a.kind) - event_priority(b.kind)
  })
  events
}

///|
/// Snapshot the timeline at `target_time_ms` and return every leaf
/// behaviour currently active. Behaviours whose `fill` is `Remove`
/// (the default) disappear after their end time; `Hold` / `Freeze` /
/// `Transition` keep emitting with `progress = 1.0`.
pub fn TimingEngine::animate(
  self : TimingEngine,
  target_time_ms : Int,
) -> Array[ActiveBehavior] {
  let active : Array[ActiveBehavior] = []
  let placements : Array[Placement] = []
  let scratch_events : Array[Event] = []
  for root in self.timeline.roots {
    let _ = place_node(root, 0, scratch_events, false, placements)
  }
  for placement in placements {
    if !placement.node.is_leaf() {
      continue
    }
    if placement.conditional {
      continue
    }
    let start = placement.start_ms
    if target_time_ms < start {
      continue
    }
    let single_dur = single_duration(placement.node)
    let fill = placement.node.fill
    let repeat = placement.node.repeat_count
    let iterations = match repeat {
      None => 1
      Some(rc) => rc.iterations()
    }
    let total_dur = if single_dur <= 0 {
      0
    } else if iterations < 0 {
      // Indefinite repeat — treat the total as the largest positive
      // integer so any finite snapshot time falls inside the
      // window.
      2147483647
    } else if placement.node.auto_reverse {
      single_dur * iterations * 2
    } else {
      single_dur * iterations
    }
    let elapsed = target_time_ms - start
    // Use the placement end when available — it already accounts for
    // the merged container/child duration; otherwise fall back to
    // the leaf single_dur × iterations product computed above.
    let effective_end = match placement.end_ms {
      Some(e) => e - start
      None => total_dur
    }
    let past_end = single_dur > 0 && elapsed > effective_end
    if past_end {
      match fill {
        Some(FillRemove) => continue
        None => continue
        _ => ()
      }
    }
    let common = match placement.node.behavior_common() {
      Some(c) => c
      None => continue
    }
    let (local_progress, eased) = compute_progress(
      placement.node,
      single_dur,
      elapsed,
      past_end,
    )
    emit_active(placement.node, common, eased, local_progress, active)
  }
  active.sort_by(fn(a, b) {
    if a.node_id < b.node_id {
      return -1
    }
    if a.node_id > b.node_id {
      return 1
    }
    if a.attr_name < b.attr_name {
      -1
    } else if a.attr_name > b.attr_name {
      1
    } else {
      0
    }
  })
  active
}

///|
/// Internal placement record — populated during the schedule walk
/// and re-used by `animate` so we only walk the tree once per
/// public call. `end_ms` is materialised for completeness even
/// when `animate` recomputes its own end from `repeat_count`.
priv struct Placement {
  node : TimeNode
  start_ms : Int
  end_ms : Int?
  conditional : Bool
}

///|
/// Walk a single time-node, push events into `events`, and append
/// the resulting placement to `placements`. Returns the end time of
/// the node (or `None` when the node has indefinite duration or its
/// start is conditional).
fn place_node(
  node : TimeNode,
  base_ms : Int,
  events : Array[Event],
  parent_conditional : Bool,
  placements : Array[Placement],
) -> Int? {
  let conditional = parent_conditional || node_is_conditional(node)
  let static_delay = static_start_delay(node)
  let start_ms = base_ms + static_delay
  if conditional {
    let cond = first_runtime_condition(node)
    events.push({
      node_id: node.node_id,
      at_ms: start_ms,
      kind: EventConditionalStart(cond),
    })
    placements.push({ node, start_ms, end_ms: None, conditional: true })
    // Children inherit the conditional flag — they cannot be
    // statically scheduled either.
    let _ = place_children(node, start_ms, events, true, placements)
    return None
  }
  events.push({ node_id: node.node_id, at_ms: start_ms, kind: EventStart })
  let single_dur = single_duration(node)
  let total_dur = total_duration_ms(node, single_dur)
  let mut end_ms = if single_dur <= 0 {
    None
  } else {
    Some(start_ms + total_dur)
  }
  let child_end = place_children(node, start_ms, events, false, placements)
  match (end_ms, child_end) {
    (Some(e), Some(c)) => if c > e { end_ms = Some(c) }
    (None, Some(c)) => end_ms = Some(c)
    _ => ()
  }
  // Leaf-behaviour keypoint events.
  if node.is_leaf() {
    emit_keypoint_events(node, start_ms, single_dur, events)
  }
  match end_ms {
    Some(e) => events.push({ node_id: node.node_id, at_ms: e, kind: EventEnd })
    None => ()
  }
  placements.push({ node, start_ms, end_ms, conditional: false })
  end_ms
}

///|
fn place_children(
  node : TimeNode,
  base_ms : Int,
  events : Array[Event],
  parent_conditional : Bool,
  placements : Array[Placement],
) -> Int? {
  if node.children.length() == 0 {
    return None
  }
  match node.kind {
    // All children start at base_ms; node end is the max child end.
    Par => {
      let mut max_end : Int? = None
      for child in node.children {
        let end = place_node(
          child, base_ms, events, parent_conditional, placements,
        )
        match (end, max_end) {
          (Some(e), Some(m)) => if e > m { max_end = Some(e) }
          (Some(e), None) => max_end = Some(e)
          _ => ()
        }
      }
      max_end
    }
    Seq | Excl => {
      let mut cursor = base_ms
      let mut last_end : Int? = None
      for child in node.children {
        let end = place_node(
          child, cursor, events, parent_conditional, placements,
        )
        match end {
          Some(e) => {
            cursor = e
            last_end = Some(e)
          }
          None => ()
        }
      }
      last_end
    }
    _ => {
      // Leaf behaviours technically do not own children, but the
      // schema allows a subTnLst on cmd / animMotion; walk them as
      // a parallel group for completeness.
      let mut max_end : Int? = None
      for child in node.children {
        let end = place_node(
          child, base_ms, events, parent_conditional, placements,
        )
        match (end, max_end) {
          (Some(e), Some(m)) => if e > m { max_end = Some(e) }
          (Some(e), None) => max_end = Some(e)
          _ => ()
        }
      }
      max_end
    }
  }
}

///|
fn emit_keypoint_events(
  node : TimeNode,
  start_ms : Int,
  single_dur : Int,
  events : Array[Event],
) -> Unit {
  let common = match node.behavior_common() {
    Some(c) => c
    None => return
  }
  if common.attr_names.length() == 0 {
    return
  }
  let endpoints = endpoint_pair(common)
  if common.tav_list.length() == 0 && endpoints is None {
    return
  }
  for attr in common.attr_names {
    if common.tav_list.length() > 0 {
      for tav in common.tav_list {
        match (tav.tm_percent, tav.value) {
          (Some(pct), Some(value)) => {
            let at = start_ms + (pct * single_dur.to_double()).to_int()
            events.push({
              node_id: node.node_id,
              at_ms: at,
              kind: EventPropertyAt(attr, value, pct),
            })
          }
          _ => ()
        }
      }
    } else {
      match endpoints {
        Some((lo, hi)) => {
          events.push({
            node_id: node.node_id,
            at_ms: start_ms,
            kind: EventPropertyAt(attr, lo, 0.0),
          })
          events.push({
            node_id: node.node_id,
            at_ms: start_ms + single_dur,
            kind: EventPropertyAt(attr, hi, 1.0),
          })
        }
        None => ()
      }
    }
  }
}

///|
fn endpoint_pair(common : BehaviorCommon) -> (AnimVariant, AnimVariant)? {
  match (common.from_value, common.to_value) {
    (Some(f), Some(t)) => Some((f, t))
    (None, Some(t)) =>
      // Treat from as "no change" — synthesise a starting value
      // that matches the type of `t` so callers see a stable
      // baseline. For numerics, zero; for strings, empty string;
      // for colours, the same value.
      Some((default_for(t), t))
    _ => None
  }
}

///|
fn default_for(value : AnimVariant) -> AnimVariant {
  match value {
    BoolVariant(_) => BoolVariant(false)
    IntVariant(_) => IntVariant(0)
    FloatVariant(_) => FloatVariant(0.0)
    StringVariant(_) => StringVariant("")
    ColorVariant(c) => ColorVariant(c)
  }
}

///|
fn emit_active(
  node : TimeNode,
  common : BehaviorCommon,
  eased_progress : Double,
  local_progress : Double,
  active : Array[ActiveBehavior],
) -> Unit {
  let _ = local_progress
  let calc_mode = match common.calc_mode {
    Some(c) => c
    None => CalcLinear
  }
  let attr_names = if common.attr_names.length() == 0 {
    [""]
  } else {
    common.attr_names
  }
  for attr in attr_names {
    let value_opt = if common.tav_list.length() > 0 {
      evaluate_tav_list(common.tav_list, eased_progress, calc_mode)
    } else {
      match endpoint_pair(common) {
        Some((lo, hi)) =>
          Some(interpolate_variant(lo, hi, eased_progress, calc_mode))
        None =>
          match common.to_value {
            Some(v) => Some(v)
            None => None
          }
      }
    }
    match value_opt {
      Some(value) =>
        active.push({
          node_id: node.node_id,
          target_shape_id: common.target_shape_id,
          attr_name: attr,
          value,
          progress: eased_progress,
        })
      None => ()
    }
  }
}

///|
fn compute_progress(
  node : TimeNode,
  single_dur : Int,
  elapsed : Int,
  past_end : Bool,
) -> (Double, Double) {
  if past_end || single_dur <= 0 {
    return (1.0, 1.0)
  }
  let raw = elapsed.to_double() / single_dur.to_double()
  let (local_t, _) = effective_progress(
    raw,
    node.repeat_count,
    node.auto_reverse,
  )
  let eased = ease_progress(local_t, node.accel, node.decel)
  (local_t, eased)
}

///|
fn single_duration(node : TimeNode) -> Int {
  match node.duration {
    Some(Ms(n)) => n
    Some(Indefinite) => 0
    None =>
      match node.kind {
        SetLeaf(_) => 0
        _ => 0
      }
  }
}

///|
fn total_duration_ms(node : TimeNode, single_dur : Int) -> Int {
  if single_dur <= 0 {
    return 0
  }
  let iterations = match node.repeat_count {
    None => 1
    Some(Iterations(n)) => n
    Some(RepeatIndefinite) => 1
  }
  let cycles = if node.auto_reverse { iterations * 2 } else { iterations }
  single_dur * cycles
}

///|
fn static_start_delay(node : TimeNode) -> Int {
  let mut delay = match node.delay {
    Some(Ms(n)) => n
    _ => 0
  }
  for cond in node.start_conditions {
    if cond.is_static() {
      match cond.delay {
        Some(Ms(n)) => if n > delay { delay = n }
        _ => ()
      }
    }
  }
  delay
}

///|
fn node_is_conditional(node : TimeNode) -> Bool {
  if node.start_conditions.length() == 0 {
    return false
  }
  // The node is conditional when every start condition is event-
  // driven (e.g. onClick). A single static condition makes the
  // start statically resolvable; the runtime conditions then act
  // as alternative triggers.
  for cond in node.start_conditions {
    if cond.is_static() {
      return false
    }
  }
  true
}

///|
fn first_runtime_condition(node : TimeNode) -> TimeCondition {
  for cond in node.start_conditions {
    if !cond.is_static() {
      return cond
    }
  }
  {
    delay: None,
    event: None,
    target_shape_id: None,
    target_runtime_node_id: None,
  }
}

///|
fn event_priority(kind : EventKind) -> Int {
  match kind {
    EventConditionalStart(_) => 0
    EventStart => 1
    EventPropertyAt(_, _, _) => 2
    EventEnd => 3
  }
}
