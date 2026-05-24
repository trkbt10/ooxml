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
// `refForName`) are resolved against the carrying node's own
// already-computed bounds: e.g. `<constr type="w" refType="h"
// fact="0.5"/>` sets width = height * 0.5. Cross-node reference
// lookups (where `refForName` points at a *different* layout node)
// are partially supported: when the named source node was already
// computed in an earlier dispatch pass, the solver substitutes its
// variable; otherwise the constraint silently no-ops and the
// algorithm-derived bound stays in effect.
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
/// (PowerPoint and LibreOffice both surface this as an empty
/// graphicFrame).
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
/// mirroring LibreOffice / PowerPoint's behaviour on the same
/// inputs.
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
  let mut x = parent_bounds.x
  let mut y = parent_bounds.y
  let mut w = parent_bounds.width
  let mut h = parent_bounds.height
  for c in constraints {
    if !constraint_is_self_targeted(c) {
      continue
    }
    // Same-node reference constraints (refType present, refForName
    // absent) resolve against the in-flight rectangle so a node
    // may declare e.g. `w refType="h" fact="0.5"` to compute width
    // from height.
    let resolved = resolve_self_constraint_value(c, w, h)
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
/// §21.4.2.8 constr/@refType — resolve a constraint's right-hand
/// value against either:
///
///   * a literal `val` multiplied by `fact` (no reference), or
///   * a same-node variable lookup when `refType` is present and
///     `refForName` is absent (the schema default `refFor="self"`
///     applies, so the source is the same layout node).
///
/// Returns `None` when the constraint carries neither a `val` nor a
/// resolvable `refType` source — the caller treats that as
/// "constraint underspecified, skip".  Cross-node references
/// (`refForName` set) are not handled here: they are addressed by
/// the child-targeting pass and stay as `Some(0)` would be wrong,
/// so this routine returns `None` for them too, letting the engine
/// fall back to the algorithm-derived bound.
fn resolve_self_constraint_value(
  c : Constraint,
  current_w : Double,
  current_h : Double,
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
    Some(_) => {
      // Cross-node references (`refForName` present) are out of
      // scope for the self-targeted pass; the engine will pick
      // them up when it reaches the source layoutNode.
      if c.ref_for_name is Some(_) {
        return None
      }
      let source = match c.ref_type {
        Some(ConstrW) => Some(current_w)
        Some(ConstrH) => Some(current_h)
        // Other refTypes (l/t/r/b/...) would need the in-flight
        // rectangle origin, but those are uncommon as same-node
        // references and we conservatively no-op so the algorithm
        // bound stays.
        _ => None
      }
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
