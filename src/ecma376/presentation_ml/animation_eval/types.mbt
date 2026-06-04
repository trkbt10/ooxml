// === §19.5 timing engine — runtime-only support types ====================
//
// The schema-bound typed records (`CT_TL*` / `ST_TL*`) all live in
// `@domain`; this file holds the evaluator-private runtime values
// emitted by `TimingEngine::schedule` and `TimingEngine::animate`.

///|
/// Part 1 §19.5 timing — typed root of a slide's animation tree.
/// `roots` corresponds to the children of `<p:timing>/<p:tnLst>`
/// (typically exactly one root `<p:par>` per spec examples).
pub(all) struct Timeline {
  roots : Array[@domain.CT_TLCommonTimeNodeData]
} derive(Eq, Debug)

///|
/// Flatten every leaf time-node in depth-first order. Useful for
/// callers that want to iterate behaviours without re-walking the
/// container kinds themselves.
pub fn Timeline::flatten_leaves(
  self : Timeline,
) -> Array[@domain.CT_TLCommonTimeNodeData] {
  let result : Array[@domain.CT_TLCommonTimeNodeData] = []
  for root in self.roots {
    collect_leaves(root, result)
  }
  result
}

///|
fn collect_leaves(
  node : @domain.CT_TLCommonTimeNodeData,
  result : Array[@domain.CT_TLCommonTimeNodeData],
) -> Unit {
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
  EventPropertyAt(String, @domain.CT_TLAnimVariant, Double)
  EventConditionalStart(@domain.CT_TLTimeCondition)
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
  value : @domain.CT_TLAnimVariant
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
/// Trim ASCII whitespace from both ends of `text`. Internal helper
/// used by the lexical decoders.
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
/// Parse a decimal xsd:unsignedInt string into the evaluator's signed
/// Int storage. Returns `None` on malformed input, UInt32 overflow, or
/// values that cannot be represented by the existing evaluator fields.
fn parse_unsigned_int(text : String) -> Int? {
  if text.length() == 0 {
    return None
  }
  let mut value : UInt64 = 0UL
  for i in 0..<text.length() {
    let unit = text.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10UL + (unit - 0x30).to_uint64()
    if value > 2147483647UL {
      return None
    }
  }
  Some(value.to_int())
}
