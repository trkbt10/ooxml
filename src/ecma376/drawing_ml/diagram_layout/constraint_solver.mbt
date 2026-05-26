// Part 1 §21.4.2.8 constr (CT_Constraint) — solver for the canonical
// geometric constraints used by real-world SmartArt layouts.
//
// ECMA-376 §21.4.7.21 ST_ConstraintType lists 18+ constraint types.
// This solver honours the spatial subset:
//
//   * §21.4.7.21 w  — explicit width   (override parent-derived width)
//   * §21.4.7.21 h  — explicit height  (override parent-derived height)
//   * §21.4.7.21 l  — left anchor       (override x)
//   * §21.4.7.21 t  — top anchor        (override y)
//   * §21.4.7.21 r  — right anchor      (compute width = r - x)
//   * §21.4.7.21 b  — bottom anchor     (compute height = b - y)
//   * §21.4.7.21 wOff — additive width offset
//   * §21.4.7.21 hOff — additive height offset
//   * §21.4.7.21 lMarg / rMarg / tMarg / bMarg — honoured by
//     `apply_margins` in `engine.mbt` for self-targeting margins.
//   * §21.4.7.21 sp / sibSp — sibling spacing (consumed by lin / snake)
//   * §21.4.7.21 pyraAcctRatio — handled by `algorithms_pyra.mbt`
//
// Reference constraints (`refType` + optional `refFor` /
// `refForName`) are resolved in `resolve_constraint_value`:
//
//   * `<constr type="w" refType="h" fact="0.5"/>` (same-node) —
//     sets the carrying node's width to half its own height; the
//     in-flight rectangle is read so this constraint may appear
//     after a same-node `h` constraint that has already adjusted
//     the height.
//   * `<constr type="w" refType="w" refForName="root" fact="0.4"/>`
//     (cross-node) — looks up `root` in the engine's
//     `EvalContext.node_bounds_by_name` registry. The map is
//     populated by `walk_layout_node` after each layoutNode's
//     `inner` rectangle is computed, so a constraint that
//     references a named sibling/ancestor walked earlier in
//     document order resolves correctly. A constraint that
//     references a node not yet walked (forward reference) silently
//     no-ops; a fully iterative fixed-point solver that re-evaluates
//     pending constraints across multiple passes is deferred.
//
// `for=ch` / `for=des` constraints with `forName` (a name reference
// into the layout-node tree) are handled by
// `child_targeted_constraints_for`: the engine collects them from
// the parent layoutNode and applies them to each matching child
// before recursion. `for=ancst` is out of scope here (very rare on
// canonical layouts).
//
// `@op = gte | lte` inequality constraints are treated as `equ`
// (the schema's `none` default already means "use val verbatim",
// so the engine cannot do better without a fully iterative solver).
//
// Non-geometric constraints (`primFontSz`, `userE`, `userF`, …)
// are intentionally ignored — they drive text fitting and do not
// change node bounds.

///|
/// §21.4.7.21 ST_ConstraintType — return `true` for constraint kinds
/// that carry *geometric* intent (width, height, anchor, offset,
/// spacing). Returns `false` for text-fitting and user-defined
/// constraints which do not directly drive node bounds.
///
/// Used by `layout_def_has_geometric_constraints` to decide whether
/// a layoutDef has enough geometric data to run the layout engine
/// against — a layoutDef carrying only `primFontSz` constraints
/// (no width/height/anchor) does not yield a meaningful per-node
/// rendering and is treated as a "metadata only" layoutDef
/// (PowerPoint surfaces this as an empty graphicFrame).
pub fn constraint_kind_is_geometric(kind : ConstraintKind) -> Bool {
  match kind {
    ConstrW | ConstrH | ConstrL | ConstrT | ConstrR | ConstrB => true
    ConstrLMarg | ConstrRMarg | ConstrTMarg | ConstrBMarg => true
    ConstrSp | ConstrSibSp => true
    ConstrWOff | ConstrHOff => true
    ConstrPyraAcctRatio => true
    ConstrOther(_) => false
  }
}

///|
/// §21.4.2.16 CT_DiagramDefinition — walk the layout-node tree and
/// return whether any node carries at least one *geometric*
/// constraint (see `constraint_kind_is_geometric`). Used by the
/// SmartArt renderer to gate engine-driven rendering: a layoutDef
/// that carries only text-fitting constraints (e.g. `primFontSz`)
/// is treated as metadata-only and the renderer emits nothing,
/// mirroring PowerPoint's behaviour on the same inputs.
///
/// We probe the typed `LayoutNode` tree (rather than the raw XML)
/// so the decoder's normalisation — including `ConstraintKind`
/// dispatch — is applied uniformly.
pub fn definition_has_geometric_constraints(
  definition : DiagramDefinition,
) -> Bool {
  layout_node_has_geometric_constraint(definition.root)
}

///|
/// Recursive companion to `definition_has_geometric_constraints`.
/// Walks each `LayoutChild`: `LcNode` recurses directly; `LcChoose`
/// scans every branch body; `LcForEach` scans the iteration body.
/// The walk is bounded by the source-tree depth (no spec construct
/// introduces unbounded recursion).
fn layout_node_has_geometric_constraint(node : LayoutNode) -> Bool {
  for c in node.constraints {
    if constraint_kind_is_geometric(c.kind) {
      return true
    }
  }
  for child in node.children {
    if layout_child_has_geometric_constraint(child) {
      return true
    }
  }
  false
}

///|
/// Walk a single `LayoutChild` (node, choose, forEach) and return
/// whether the subtree contains any geometric constraint. Used by
/// `layout_node_has_geometric_constraint`; isolated as its own
/// helper so the three variant cases stay compact.
fn layout_child_has_geometric_constraint(child : LayoutChild) -> Bool {
  match child {
    LcNode(n) => layout_node_has_geometric_constraint(n)
    LcChoose(branches) => {
      for b in branches {
        for body_child in b.body {
          if layout_child_has_geometric_constraint(body_child) {
            return true
          }
        }
      }
      false
    }
    LcForEach(spec) => {
      for body_child in spec.body {
        if layout_child_has_geometric_constraint(body_child) {
          return true
        }
      }
      false
    }
  }
}

///|
/// §21.4.2.8 constr — apply this node's `self`-targeting absolute
/// constraints (`w`, `h`, `l`, `t`, `r`, `b`, `wOff`, `hOff`) to
/// the supplied `parent_bounds` and return the constrained
/// rectangle. A constraint qualifies as `self`-targeting when its
/// `for` attribute is absent or set to `"self"`. Reference
/// constraints (`refType` present) targeting another variable on
/// the same node are resolved using the current in-flight
/// rectangle (`w` can reference `h` and vice versa); cross-node
/// references with `refForName` no-op in this pass and are picked
/// up by `child_targeted_constraints_for` when the engine reaches
/// the source node.
///
/// Constraint semantics:
///
///   * `w` — replace the rectangle's width.
///   * `h` — replace the rectangle's height.
///   * `l` — shift the rectangle's x origin to the supplied value
///     (interpreted as offset from `parent_bounds.x`).
///   * `t` — shift the rectangle's y origin to the supplied value
///     (interpreted as offset from `parent_bounds.y`).
///   * `r` — anchor the rectangle's right edge; the width is
///     `r - x` after `l` has been applied (or `parent_bounds.x`
///     when absent).  Negative values clamp to 0.
///   * `b` — analogous to `r` along the vertical axis.
///   * `wOff` — additive width offset (width := width + wOff*fact).
///   * `hOff` — analogous to `wOff` for height.
///
/// `fact` (if present) multiplies either the literal `val` or the
/// referenced variable; this matches §21.4.2.8: `value = (val |
/// source[refType]) * fact`.
///
/// When no qualifying constraint is found the supplied bounds are
/// returned unchanged. `apply_margins` is still applied separately
/// in `walk_layout_node` so margin and absolute-size constraints
/// can co-exist (margin first, then absolute override).
pub fn apply_self_geometric_constraints(
  parent_bounds : BoundsRect,
  constraints : Array[Constraint],
) -> BoundsRect {
  // Backward-compatible wrapper: call the registry-aware helper
  // with an empty map so existing callers that have no name
  // registry (the wbtests in particular) keep the same behaviour:
  // every `refForName` cross-node reference no-ops.
  apply_self_geometric_constraints_with_registry(
    parent_bounds,
    constraints,
    Map([], capacity=0),
  )
}

///|
/// §21.4.2.8 constr — registry-aware variant of
/// `apply_self_geometric_constraints` that additionally honours
/// cross-node references (`<constr refForName="other"
/// refType="w|h|l|t|r|b" .../>`) by consulting `node_bounds_by_name`.
///
/// The engine populates this map in `walk_layout_node` with the
/// inner bounds of every named layoutNode it visits; a later
/// constraint can therefore declare e.g. `<constr type="w"
/// refType="w" refForName="root" fact="0.4"/>` and have its width
/// resolved to 40 % of the (already-walked) `root` node's width.
///
/// Forward references — where the source node is laid out *after*
/// the carrying node in document order — still no-op (the map has
/// no entry for the source name yet). A fully iterative
/// fixed-point solver is deferred.
pub fn apply_self_geometric_constraints_with_registry(
  parent_bounds : BoundsRect,
  constraints : Array[Constraint],
  node_bounds_by_name : Map[String, BoundsRect],
) -> BoundsRect {
  let mut x = parent_bounds.x
  let mut y = parent_bounds.y
  let mut w = parent_bounds.width
  let mut h = parent_bounds.height
  for c in constraints {
    if !constraint_is_self_targeted(c) {
      continue
    }
    // Reference constraints resolve in this priority order:
    //
    //   1. Cross-node lookup when `refForName` is set and the
    //      registry already carries that named layoutNode's
    //      bounds — read the requested `refType` variable on the
    //      source rect, scale by `fact`.
    //   2. Same-node reference when `refForName` is absent and
    //      `refType` is set — read the in-flight rectangle (w/h/l/t/r/b
    //      reference each other via `read_bounds_variable`).
    //   3. Literal `val * fact` when no `refType`.
    let resolved = resolve_constraint_value(
      c, x, y, w, h, parent_bounds, node_bounds_by_name,
    )
    let value = match resolved {
      Some(v) => v
      None => continue
    }
    match c.kind {
      ConstrW => w = value
      ConstrH => h = value
      ConstrL => x = parent_bounds.x + value
      ConstrT => y = parent_bounds.y + value
      ConstrR => {
        // r is the right-edge anchor measured from parent's origin
        // (matching how l / t are interpreted above). After this
        // constraint x is unchanged; width grows to land the right
        // edge exactly at the requested offset.
        let new_w = parent_bounds.x + value - x
        w = if new_w < 0.0 { 0.0 } else { new_w }
      }
      ConstrB => {
        let new_h = parent_bounds.y + value - y
        h = if new_h < 0.0 { 0.0 } else { new_h }
      }
      ConstrWOff => w = w + value
      ConstrHOff => h = h + value
      _ => ()
    }
  }
  // Clamp width/height to non-negative so downstream renderers never
  // receive a degenerate rectangle.
  let safe_w = if w < 0.0 { 0.0 } else { w }
  let safe_h = if h < 0.0 { 0.0 } else { h }
  { x, y, width: safe_w, height: safe_h }
}

///|
/// §21.4.2.8 constr — unified resolver that combines the
/// cross-node (`refForName`) and same-node (`refType` only) lookup
/// paths. The constraint is interpreted as the right-hand side of
/// `target_var = value` where `value` is one of:
///
///   * `source_node[refType] * fact` — cross-node reference,
///     read from `node_bounds_by_name` (returns `None` when the
///     source has not been laid out yet, i.e. forward reference).
///   * `self[refType] * fact` — same-node reference, read from
///     the in-flight rectangle (only `w` / `h` are tracked).
///   * `val * fact` — literal numeric constraint.
///
/// Returns `None` for underspecified constraints (no `val`, no
/// resolvable `refType`) so the caller can skip the assignment
/// and let the algorithm-derived value stand.
fn resolve_constraint_value(
  c : Constraint,
  current_x : Double,
  current_y : Double,
  current_w : Double,
  current_h : Double,
  parent_bounds : BoundsRect,
  node_bounds_by_name : Map[String, BoundsRect],
) -> Double? {
  let factor = match c.fact {
    Some(f) => f
    None => 1.0
  }
  match c.ref_type {
    None =>
      match c.val {
        Some(v) => Some(v * factor)
        None => None
      }
    Some(ref_kind) => {
      // Cross-node lookup: `refForName` names a layoutNode that may
      // already be in the registry. The `refFor` axis is treated as
      // `self` here — that is the schema default and the only
      // axis the registry semantics support without a full
      // layout-node tree walker.
      match c.ref_for_name {
        Some(source_name) =>
          match node_bounds_by_name.get(source_name) {
            Some(source_bounds) => {
              let raw = read_bounds_variable(source_bounds, ref_kind)
              match raw {
                Some(v) => return Some(v * factor)
                None => ()
              }
              // refType is not a per-rect variable (e.g. lMarg);
              // fall through to the literal-val branch.
            }
            None => ()
          }
        None => ()
      }
      // Same-node lookup: read the in-flight rectangle. Same-node
      // l/t/r/b references resolve against the offsets relative
      // to the parent origin so they match how the constraint
      // writer would have authored a `val` for them.
      let in_flight : BoundsRect = {
        x: current_x - parent_bounds.x,
        y: current_y - parent_bounds.y,
        width: current_w,
        height: current_h,
      }
      let source = read_bounds_variable(in_flight, ref_kind)
      match source {
        Some(value) => Some(value * factor)
        None =>
          // No same-node variable to read; fall back to literal val
          // if present, otherwise underspecified.
          match c.val {
            Some(v) => Some(v * factor)
            None => None
          }
      }
    }
  }
}

///|
/// §21.4.7.21 ST_ConstraintType — read a per-rectangle variable
/// (`w` / `h` / `l` / `t` / `r` / `b`) off the supplied bounds.
/// The lengths (`w` / `h`) come straight from the rectangle; the
/// anchors (`l` / `t`) are the rectangle's relative origin; `r` /
/// `b` are computed as origin + length (matching how a constraint
/// `val` is authored — see `apply_self_geometric_constraints`'s
/// handling of `ConstrR` / `ConstrB`).
///
/// Returns `None` for constraint kinds that do not map to a single
/// rectangle scalar (margins, spacing, offsets, pyraAcctRatio,
/// catch-all) so the caller can fall back to the literal `val`.
fn read_bounds_variable(bounds : BoundsRect, kind : ConstraintKind) -> Double? {
  match kind {
    ConstrW => Some(bounds.width)
    ConstrH => Some(bounds.height)
    ConstrL => Some(bounds.x)
    ConstrT => Some(bounds.y)
    ConstrR => Some(bounds.x + bounds.width)
    ConstrB => Some(bounds.y + bounds.height)
    _ => None
  }
}

///|
/// §21.4.2.8 constr/@for — return whether a constraint targets the
/// carrying node itself. The schema default for `@for` is `self`;
/// constraints with `for=ch|des|ancst` target relatives and are
/// not handled by this pass — those flow through
/// `child_targeted_constraints_for` instead.
fn constraint_is_self_targeted(c : Constraint) -> Bool {
  match c.for_target {
    None => true
    Some("self") => true
    Some(_) => false
  }
}

///|
/// §21.4.2.8 constr/@for = `ch` / `des` — collect every constraint
/// on the parent layoutNode that targets a *child* by `forName`
/// matching `child_name`. Used by `walk_layout_node` after the
/// algorithm has computed each child's per-bounds: those bounds
/// then pass through `apply_self_geometric_constraints` with the
/// collected child-targeting set so a parent can declare e.g.
/// `<constr for="ch" forName="leaf" type="w" val="100"/>` and
/// every child named `leaf` lands at width 100.
///
/// `for="des"` (descendants) is treated the same as `for="ch"`
/// here: the engine recurses through the layout-node tree and
/// re-evaluates the predicate at every level, so a `des`
/// constraint naturally cascades.  `forName` absent means
/// "all children of this parent" — every child receives the
/// constraint.
pub fn child_targeted_constraints_for(
  parent_constraints : Array[Constraint],
  child_name : String,
) -> Array[Constraint] {
  let acc : Array[Constraint] = []
  for c in parent_constraints {
    // Skip self-targeting and non-target constraints; they were
    // already handled by `apply_self_geometric_constraints` on
    // the parent node.
    let targets_child = match c.for_target {
      Some("ch") => true
      Some("des") => true
      _ => false
    }
    if !targets_child {
      continue
    }
    // `forName` absent → match every child. Otherwise the child's
    // `name` attribute must match the constraint's `forName`.
    let name_matches = match c.for_name {
      None => true
      Some(name) => name == child_name
    }
    if !name_matches {
      continue
    }
    // Re-emit the constraint as a self-targeted one so
    // `apply_self_geometric_constraints` consumes it without
    // re-checking the @for predicate. The other attributes pass
    // through verbatim so reference constraints inherit `refType`
    // / `fact` correctly.
    acc.push({
      kind: c.kind,
      for_target: Some("self"),
      for_name: None,
      pt_type: c.pt_type,
      ref_type: c.ref_type,
      ref_for_target: c.ref_for_target,
      ref_for_name: c.ref_for_name,
      ref_pt_type: c.ref_pt_type,
      op: c.op,
      val: c.val,
      fact: c.fact,
    })
  }
  acc
}
