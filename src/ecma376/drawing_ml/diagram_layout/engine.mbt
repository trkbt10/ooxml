///|
/// Part 1 §21.4 — top-level SmartArt layout entry point. Walks
/// the layout-node tree of `definition` against `data_model` and
/// the supplied `bounds`, dispatches each `alg` node to the
/// matching layout algorithm, evaluates `choose / if / else`
/// against the current data-model context, and recurses through
/// `forEach` to fan out per-data-point. The result is one
/// `NodeBounds` per data point reached by the layout — order
/// matches the engine's traversal order (depth-first across the
/// layout tree, document order across `forEach` iterations).
pub fn DiagramLayoutEngine::apply(
  self : DiagramLayoutEngine,
  definition : DiagramDefinition,
  data_model : DataModel,
  bounds : BoundsRect,
) -> Array[NodeBounds] {
  let _ = self
  let root_id = match find_root_point_id(data_model) {
    Some(id) => id
    None =>
      // Empty data models still walk the root layout so the engine
      // can surface a stable empty result rather than crashing.
      ""
  }
  // §21.4.2.19 layoutNode/@name → computed inner bounds map. The
  // walker registers every named layoutNode's `inner` rectangle so a
  // constraint with `<constr refForName="…"/>` can resolve against the
  // named node's bounds.  A reference to a node appearing EARLIER in
  // document order resolves within a single depth-first pass; a FORWARD
  // reference (target walked later) finds nothing on the first pass.
  //
  // §21.4.2.8 — to honour forward references we iterate the walk to a
  // fixed point: each pass seeds the registry with the PREVIOUS pass's
  // resolved bounds, so a forward reference reads the target's bounds
  // from the prior pass instead of silently no-op'ing.  Iteration stops
  // once the registry stabilises.  A layout with no forward references
  // converges on the first pass and is byte-identical to the former
  // single-pass result (every reference is backward and is overwritten
  // with the same value it computed before), so existing layouts are
  // unaffected; only forward-referencing layouts change (resolving the
  // constraint rather than dropping it).
  let max_passes = 6
  let mut prev_named : Map[String, BoundsRect] = Map([], capacity=0)
  let mut final_results : Array[NodeBounds] = []
  for pass in 0..<max_passes {
    let named : Map[String, BoundsRect] = Map([], capacity=0)
    for k, v in prev_named {
      named[k] = v
    }
    let results : Array[NodeBounds] = []
    let context = {
      data_model,
      context_id: root_id,
      depth: 0,
      results,
      node_bounds_by_name: named,
    }
    walk_layout_node(definition.root, bounds, context)
    final_results = context.results
    if pass > 0 && node_bounds_maps_equal(prev_named, named) {
      break
    }
    prev_named = named
  }
  final_results
}

///|
/// Structural equality for the `layoutNode/@name → bounds` registry,
/// used to detect fixed-point convergence of the constraint solver.
fn node_bounds_maps_equal(
  a : Map[String, BoundsRect],
  b : Map[String, BoundsRect],
) -> Bool {
  if a.length() != b.length() {
    return false
  }
  for k, v in a {
    match b.get(k) {
      Some(bv) => if bv != v { return false }
      None => return false
    }
  }
  true
}

///|
/// Walk a single `LayoutNode` against the current context and
/// bounds. Constraints adjust the bounds for the children; the
/// algorithm (if any) lays the children out; if no algorithm is
/// declared, every child receives the same parent bounds (the
/// schema permits this and the canonical layout uses it for
/// pass-through wrapper nodes).
pub fn walk_layout_node(
  node : LayoutNode,
  parent_bounds : BoundsRect,
  context : EvalContext,
) -> Unit {
  // §21.4.2.8 constr — honour `self`-targeting absolute `w`/`h`/`l`/`t`
  // constraints before margins, so an explicit size override
  // re-parents the margin pass on the constrained rectangle. See
  // `constraint_solver.mbt` for the supported / deferred constraint
  // matrix. The name registry is threaded in so a constraint with
  // `refForName="other"` can resolve against a previously walked
  // sibling's bounds.
  let bounds_after_self = apply_self_geometric_constraints_with_registry(
    parent_bounds,
    node.constraints,
    context.node_bounds_by_name,
  )
  let inner = apply_margins(bounds_after_self, node.constraints)
  // §21.4.2.19 layoutNode/@name — register this node's inner
  // bounds so later siblings/descendants can resolve a
  // `<constr refForName="<this.name>" refType="w|h|l|t|r|b"/>`
  // reference. The map mutates in-place; the depth-first walker
  // guarantees a layoutNode is registered before its children
  // recurse, and earlier-document-order siblings are registered
  // before later ones.
  context.node_bounds_by_name[node.name] = inner
  let effective_children = collect_effective_children(node.children, context)
  apply_pres_of(node, inner, context)
  let alg_kind = match node.algorithm {
    Some(alg) => effective_algorithm(alg.kind)
    None => AlgLin
  }
  let algorithm = match node.algorithm {
    Some(alg) => alg
    None => { kind: AlgLin, params: [] }
  }
  dispatch_algorithm(
    alg_kind,
    algorithm,
    node.constraints,
    inner,
    effective_children,
  )
}

///|
/// Resolve the dispatched algorithm: supported algorithms (including
/// `composite`, which has a faithful constraint-driven pass) are
/// returned unchanged; the remaining unsupported types (`conn`,
/// `sp`, `tx`) fall back to `lin` per Requirement 13 so the engine
/// always produces non-empty bounds for downstream renderers.
pub fn effective_algorithm(kind : AlgorithmType) -> AlgorithmType {
  if kind.is_supported() {
    kind
  } else {
    AlgLin
  }
}

///|
/// Dispatch a layout-node algorithm to the per-algorithm helper
/// and recurse into each child with the computed bounds. For
/// hier / hierRoot the recursion is asymmetric (root vs children
/// containers); every other algorithm distributes the children
/// uniformly.
pub fn dispatch_algorithm(
  kind : AlgorithmType,
  algorithm : Algorithm,
  constraints : Array[Constraint],
  inner : BoundsRect,
  children : Array[ExpandedChild],
) -> Unit {
  let n = children.length()
  match kind {
    AlgLin => {
      let per_child = layout_lin(inner, algorithm, constraints, n)
      apply_each_child(children, per_child, constraints)
    }
    AlgSnake => {
      let per_child = layout_snake(inner, algorithm, constraints, n)
      apply_each_child(children, per_child, constraints)
    }
    AlgCycle => {
      let per_child = layout_cycle(inner, n)
      apply_each_child(children, per_child, constraints)
    }
    AlgPyra => {
      let per_child = layout_pyra(inner, constraints, n)
      apply_each_child(children, per_child, constraints)
    }
    AlgHierRoot => dispatch_hier(inner, children, constraints)
    AlgHierChild => {
      // hierChild lays its forEach output horizontally; the
      // hierRoot above it has already carved out the bottom 70 %
      // of the canvas, so we just distribute the children
      // left-to-right inside that strip.
      let per_child = layout_lin(inner, algorithm, constraints, n)
      apply_each_child(children, per_child, constraints)
    }
    // §21.4.7.1 composite — children carry NO automatic spatial
    // distribution; each is sized/positioned purely by the
    // composite node's `for="ch"` constraints (and its own
    // `<constrLst>`), measured from the composite origin. Every
    // child therefore bases off the full composite rect — see
    // `layout_composite`. `recurse_into_child` then applies the
    // child-targeting constraints to place and size each one.
    AlgComposite => {
      let per_child = layout_composite_with_algorithm(inner, algorithm, n)
      apply_each_child(children, per_child, constraints)
    }
    // §21.4.7.1 AlgorithmType — closed-10 enum. The remaining three
    // algorithms (Conn, Sp, Tx) have no dedicated pass yet; they are
    // coerced to `lin` by `effective_algorithm` BEFORE dispatch (see
    // Requirement 13), so these arms are unreachable in practice and
    // exist only to keep the match exhaustive. In canonical layouts
    // these are leaf nodes (connector / spacer / text), so the
    // child-distribution they would request never runs; the node's
    // own bounds come from its self-constraints in `walk_layout_node`.
    AlgConn => {
      let per_child = layout_lin(inner, algorithm, constraints, n)
      apply_each_child(children, per_child, constraints)
    }
    AlgSp => {
      let per_child = layout_lin(inner, algorithm, constraints, n)
      apply_each_child(children, per_child, constraints)
    }
    AlgTx => {
      let per_child = layout_lin(inner, algorithm, constraints, n)
      apply_each_child(children, per_child, constraints)
    }
  }
}

///|
/// Hierarchy dispatch. The first child becomes the hierarchy
/// root and is laid out across the top 30 % of the bounds; the
/// remaining children share the bottom 70 % equally. The engine
/// then recurses into each child with its own bounds.
///
/// `parent_constraints` is the carrying layoutNode's `<constrLst>`
/// (the one running the `hierRoot` algorithm); we pass it through
/// to `recurse_into_child` so any `<constr for="ch" forName="X" …/>`
/// override on the parent reaches the child.
fn dispatch_hier(
  inner : BoundsRect,
  children : Array[ExpandedChild],
  parent_constraints : Array[Constraint],
) -> Unit {
  let n = children.length()
  if n == 0 {
    return
  }
  let (root_bounds, child_bounds) = layout_hier(inner, n - 1)
  recurse_into_child(children[0], root_bounds, parent_constraints)
  for i in 1..<n {
    let bounds = child_bounds[i - 1]
    recurse_into_child(children[i], bounds, parent_constraints)
  }
}

///|
/// Apply the per-child bounds to the matching child layout node
/// in source order. Used by every uniform-dispatch algorithm
/// (lin, snake, cycle, pyra). Each child carries its own
/// `EvalContext` so `forEach` iteration contexts propagate
/// correctly into the layout-node walk.
///
/// `parent_constraints` carries the constraints declared on the
/// dispatching layoutNode; `recurse_into_child` filters them down
/// to the subset that targets each child by name.
fn apply_each_child(
  children : Array[ExpandedChild],
  bounds : Array[BoundsRect],
  parent_constraints : Array[Constraint],
) -> Unit {
  let n = children.length()
  let m = bounds.length()
  let limit = if n < m { n } else { m }
  for i in 0..<limit {
    recurse_into_child(children[i], bounds[i], parent_constraints)
  }
}

///|
/// §21.4.2.8 constr/@for=ch — apply the parent's child-targeting
/// constraints to `child`'s algorithm-derived bounds, then
/// recurse into the child's layoutNode walk. The two-step
/// application matches §21.4.2.8's evaluation order: the parent's
/// `for=ch forName=X` constraints adjust the child's bounds
/// before the child's own `<constrLst>` (handled inside
/// `walk_layout_node`) gets a chance to override them.
fn recurse_into_child(
  child : ExpandedChild,
  base_bounds : BoundsRect,
  parent_constraints : Array[Constraint],
) -> Unit {
  let overrides = child_targeted_constraints_for(
    parent_constraints,
    child.node.name,
  )
  let adjusted = if overrides.length() == 0 {
    base_bounds
  } else {
    apply_self_geometric_constraints_with_registry(
      base_bounds,
      overrides,
      child.context.node_bounds_by_name,
    )
  }
  walk_layout_node(child.node, adjusted, child.context)
}

///|
/// Expanded child: a concrete `LayoutNode` paired with the
/// `EvalContext` the layout-node walk should use when laying it
/// out. The pairing lets `forEach` iterations carry per-iteration
/// contexts (each iteration sets `context_id` to the iterated
/// data point) into the layout algorithm without leaking the
/// iteration state outside of `evaluate_for_each`.
pub(all) struct ExpandedChild {
  node : LayoutNode
  context : EvalContext
}

///|
/// Flatten the layout-child sequence into the concrete
/// `(LayoutNode, EvalContext)` pairs the layout algorithm
/// operates on. `forEach` nodes are expanded into one entry per
/// selected data point (each carrying its own iteration
/// context); `choose` nodes pick the matching branch and recurse
/// into its body. Direct `LcNode` children pass through with the
/// parent context.
pub fn collect_effective_children(
  children : Array[LayoutChild],
  context : EvalContext,
) -> Array[ExpandedChild] {
  let result : Array[ExpandedChild] = []
  for child in children {
    expand_child_into(child, context, result)
  }
  result
}

///|
/// Inner loop of `collect_effective_children`. Pushes the
/// resolved child entries onto `sink`; the recursion through
/// `choose` and `forEach` is bounded by the source tree depth
/// (no spec construct introduces unbounded recursion).
fn expand_child_into(
  child : LayoutChild,
  context : EvalContext,
  sink : Array[ExpandedChild],
) -> Unit {
  match child {
    LcNode(node) => sink.push({ node, context })
    LcChoose(branches) => {
      let selected = evaluate_choose(branches, context)
      for body_child in selected {
        expand_child_into(body_child, context, sink)
      }
    }
    LcForEach(spec) => evaluate_for_each(spec, context, sink)
  }
}

///|
/// Part 1 §21.4.2.6 choose — evaluate each `if` branch in
/// document order against the current context; the first
/// matching branch becomes active. If no `if` matches, the
/// `else` branch is used (if any).
pub fn evaluate_choose(
  branches : Array[ChooseBranch],
  context : EvalContext,
) -> Array[LayoutChild] {
  for branch in branches {
    if branch.is_else {
      continue
    }
    if evaluate_predicate(branch, context) {
      return branch.body
    }
  }
  for branch in branches {
    if branch.is_else {
      return branch.body
    }
  }
  []
}

///|
/// Evaluate a single `if` branch predicate against the current
/// context. The LHS is the result of the `func` applied to the
/// axis-selected set; the RHS is the literal `val` parsed as an
/// integer. `FnVar` always evaluates to `false` because variable
/// resolution is out of scope (see Requirements §"Out of scope").
fn evaluate_predicate(branch : ChooseBranch, context : EvalContext) -> Bool {
  let func = match branch.func {
    Some(value) => value
    None => return false
  }
  if func is FnVar {
    return false
  }
  let lhs = evaluate_function(func, branch.axis, branch.pt_type, context)
  let rhs = match branch.val {
    Some(text) =>
      try parse_int_string(text, "if/@val") catch {
        _ => return false
      } noraise {
        value => value
      }
    None => 0
  }
  let op = match branch.op {
    Some(value) => value
    None => OpEqu
  }
  apply_op(op, lhs, rhs)
}

///|
/// Apply a `FunctionOp` to two integer operands. Used by
/// `evaluate_predicate`; centralised so the operator table lives
/// in one place.
fn apply_op(op : FunctionOp, lhs : Int, rhs : Int) -> Bool {
  match op {
    OpEqu => lhs == rhs
    OpNeq => lhs != rhs
    OpGt => lhs > rhs
    OpGte => lhs < rhs
    OpGteValue => lhs >= rhs
    OpLte => lhs <= rhs
  }
}

///|
/// Compute the LHS of an `if/@func` predicate. `cnt` returns the
/// size of the axis-selected set; `pos` / `posEven` / `posOdd` /
/// `revPos` work on the context point's position within its
/// parent's children; `depth` / `maxDepth` work on the current
/// tree depth.
fn evaluate_function(
  func : FunctionType,
  axis : AxisType,
  pt_type : ElementType,
  context : EvalContext,
) -> Int {
  match func {
    FnCnt => axis_select(axis, pt_type, context).length()
    FnDepth => context.depth
    FnMaxDepth => max_depth_of(context.data_model, context.context_id)
    FnPos => position_of(context.context_id, context.data_model)
    FnPosEven => {
      let pos = position_of(context.context_id, context.data_model)
      if pos % 2 == 0 {
        1
      } else {
        0
      }
    }
    FnPosOdd => {
      let pos = position_of(context.context_id, context.data_model)
      if pos % 2 == 1 {
        1
      } else {
        0
      }
    }
    FnRevPos => reverse_position_of(context.context_id, context.data_model)
    FnVar => 0
  }
}

///|
/// Part 1 §21.4.2.14 forEach — iterate the body once per
/// selected data-model point. Each iteration creates a virtual
/// `LayoutNode` whose children are the body's layout children;
/// the layout-algorithm dispatch then runs against the cloned
/// node with the iterated point as the new context.
pub fn evaluate_for_each(
  spec : ForEachSpec,
  context : EvalContext,
  sink : Array[ExpandedChild],
) -> Unit {
  let selected = axis_select(spec.axis, spec.pt_type, context)
  let sliced = slice_selection(selected, spec)
  for point in sliced {
    let iteration_context = {
      data_model: context.data_model,
      context_id: point.id,
      depth: context.depth + 1,
      results: context.results,
      // Share the same registry across iterations so a later
      // forEach iteration can resolve a `refForName` against a
      // named layoutNode that an earlier iteration walked.
      node_bounds_by_name: context.node_bounds_by_name,
    }
    // Each iteration expands the body once against its own
    // context so nested `LcNode` / `LcChoose` / `LcForEach`
    // children see the iterated data point.
    for body_child in spec.body {
      expand_child_into(body_child, iteration_context, sink)
    }
  }
}

///|
/// Apply `cnt` / `st` / `step` slicing to a selected point list.
/// Mirrors the §21.4.2.14 attribute semantics: `st` is 1-based,
/// `step` advances by N entries, `cnt` truncates the output.
fn slice_selection(
  selection : Array[DiagramPoint],
  spec : ForEachSpec,
) -> Array[DiagramPoint] {
  let start = if spec.st < 1 { 0 } else { spec.st - 1 }
  let step = if spec.step <= 0 { 1 } else { spec.step }
  let mut i = start
  let result : Array[DiagramPoint] = []
  while i < selection.length() {
    result.push(selection[i])
    let limit_reached = match spec.cnt {
      Some(c) => result.length() >= c
      None => false
    }
    if limit_reached {
      break
    }
    i = i + step
  }
  result
}

///|
/// Part 1 §21.4.7.6 axis — return the data points reachable from
/// `context.context_id` via the supplied axis. The result is
/// filtered by `pt_type` (`ElAll` and `ElOther(_)` are treated as
/// "no filter").
pub fn axis_select(
  axis : AxisType,
  pt_type : ElementType,
  context : EvalContext,
) -> Array[DiagramPoint] {
  let candidates : Array[DiagramPoint] = match axis {
    AxisSelf => self_points(context)
    AxisCh => children_of(context.context_id, context.data_model)
    AxisDes => descendants_of(context.context_id, context.data_model)
    AxisDesOrSelf => {
      let acc = self_points(context)
      for d in descendants_of(context.context_id, context.data_model) {
        acc.push(d)
      }
      acc
    }
    AxisPar => parent_of(context.context_id, context.data_model)
    AxisAncst => ancestors_of(context.context_id, context.data_model)
    AxisAncstOrSelf => {
      let acc = self_points(context)
      for a in ancestors_of(context.context_id, context.data_model) {
        acc.push(a)
      }
      acc
    }
    AxisFollowSib =>
      siblings_of(context.context_id, context.data_model, after=true)
    AxisPrecedSib =>
      siblings_of(context.context_id, context.data_model, after=false)
    AxisFollow =>
      siblings_with_descendants(
        context.context_id,
        context.data_model,
        after=true,
      )
    AxisPreced =>
      siblings_with_descendants(
        context.context_id,
        context.data_model,
        after=false,
      )
    AxisRoot => root_points(context.data_model)
    AxisNone => []
  }
  filter_by_pt_type(candidates, pt_type)
}

///|
/// Return the single-element list containing the context point
/// (or empty if the context id is absent from the data model).
fn self_points(context : EvalContext) -> Array[DiagramPoint] {
  let acc : Array[DiagramPoint] = []
  for point in context.data_model.points {
    if point.id == context.context_id {
      acc.push(point)
      return acc
    }
  }
  acc
}

///|
/// Return every point whose `parent_id` matches `parent_id`, in
/// document order. The data model populates `parent_id` from the
/// `cxn/@type = parOf` connections during `decode_data_model`.
pub fn children_of(
  parent_id : String,
  data_model : DataModel,
) -> Array[DiagramPoint] {
  let acc : Array[DiagramPoint] = []
  for point in data_model.points {
    match point.parent_id {
      Some(id) => if id == parent_id { acc.push(point) }
      None => ()
    }
  }
  acc
}

///|
/// Return every descendant of `root_id` in depth-first document
/// order. The traversal walks `children_of` recursively; the
/// algorithm is naive (O(n^2) in the worst case) but data models
/// are small.
pub fn descendants_of(
  root_id : String,
  data_model : DataModel,
) -> Array[DiagramPoint] {
  let acc : Array[DiagramPoint] = []
  visit_descendants(root_id, data_model, acc)
  acc
}

///|
fn visit_descendants(
  root_id : String,
  data_model : DataModel,
  acc : Array[DiagramPoint],
) -> Unit {
  for child in children_of(root_id, data_model) {
    acc.push(child)
    visit_descendants(child.id, data_model, acc)
  }
}

///|
/// Return the parent point as a one-element list, or empty when
/// the context point has no parent (i.e. it is a root point).
fn parent_of(
  context_id : String,
  data_model : DataModel,
) -> Array[DiagramPoint] {
  let acc : Array[DiagramPoint] = []
  for point in data_model.points {
    if point.id == context_id {
      match point.parent_id {
        Some(parent_id) =>
          for candidate in data_model.points {
            if candidate.id == parent_id {
              acc.push(candidate)
              return acc
            }
          }
        None => ()
      }
      return acc
    }
  }
  acc
}

///|
/// Return every ancestor of the context point in deepest-first
/// order. The walk follows `parent_id` until it hits a root.
fn ancestors_of(
  context_id : String,
  data_model : DataModel,
) -> Array[DiagramPoint] {
  let acc : Array[DiagramPoint] = []
  let mut current = context_id
  while true {
    let parents = parent_of(current, data_model)
    if parents.length() == 0 {
      break
    }
    acc.push(parents[0])
    current = parents[0].id
  }
  acc
}

///|
/// Return the siblings of the context point. `after = true`
/// returns siblings appearing later in document order;
/// `after = false` returns the earlier siblings.
fn siblings_of(
  context_id : String,
  data_model : DataModel,
  after~ : Bool,
) -> Array[DiagramPoint] {
  let parents = parent_of(context_id, data_model)
  let acc : Array[DiagramPoint] = []
  if parents.length() == 0 {
    return acc
  }
  let parent_id = parents[0].id
  let siblings = children_of(parent_id, data_model)
  let mut found = false
  for sibling in siblings {
    if sibling.id == context_id {
      found = true
      continue
    }
    if after && found {
      acc.push(sibling)
    } else if !after && !found {
      acc.push(sibling)
    }
  }
  acc
}

///|
/// Return `siblings_of` plus their descendants — the spec's
/// `follow` / `preced` axis sense.
fn siblings_with_descendants(
  context_id : String,
  data_model : DataModel,
  after~ : Bool,
) -> Array[DiagramPoint] {
  let direct = siblings_of(context_id, data_model, after~)
  let acc : Array[DiagramPoint] = []
  for sibling in direct {
    acc.push(sibling)
    for descendant in descendants_of(sibling.id, data_model) {
      acc.push(descendant)
    }
  }
  acc
}

///|
/// Return the root data points (those with no `parent_id`). A
/// typical SmartArt data model has exactly one root carrying
/// `@type = "doc"`.
pub fn root_points(data_model : DataModel) -> Array[DiagramPoint] {
  let acc : Array[DiagramPoint] = []
  for point in data_model.points {
    if point.parent_id is None {
      acc.push(point)
    }
  }
  acc
}

///|
/// Return the id of the first root point (or `None` if the data
/// model is empty). The layout engine starts its walk with this
/// id as the initial evaluation context.
pub fn find_root_point_id(data_model : DataModel) -> String? {
  let roots = root_points(data_model)
  if roots.length() == 0 {
    None
  } else {
    Some(roots[0].id)
  }
}

///|
/// §21.4.7.41 ST_ElementType — filter the candidate point list
/// against the spec's type predicate.  `ElAll` (no filter) and
/// `ElOther(_)` (caller-supplied custom token) match every
/// candidate; the remaining concrete variants compare against
/// the canonical lexical form produced by `pt_type_lexical`.
fn filter_by_pt_type(
  candidates : Array[DiagramPoint],
  pt_type : ElementType,
) -> Array[DiagramPoint] {
  match pt_type {
    ElAll => candidates
    ElOther(_) => candidates
    // All remaining ST_ElementType variants (ElNode, ElDoc,
    // ElAsst, ElNonAsst, ElParTrans, ElSibTrans, ElPres) take
    // the per-element string-match path below.
    _ => {
      let acc : Array[DiagramPoint] = []
      let needle = pt_type_lexical(pt_type)
      for point in candidates {
        if point.point_type == needle {
          acc.push(point)
        }
      }
      acc
    }
  }
}

///|
/// Map a typed `ElementType` back to its canonical lexical form.
/// Used by `filter_by_pt_type` to match against the raw `@type`
/// attribute string of each data point.
fn pt_type_lexical(pt_type : ElementType) -> String {
  match pt_type {
    ElNode => "node"
    ElParTrans => "parTrans"
    ElSibTrans => "sibTrans"
    ElAsst => "asst"
    ElNonAsst => "nonAsst"
    ElDoc => "doc"
    ElPres => "pres"
    ElAll => "all"
    ElOther(value) => value
  }
}

///|
/// Compute the maximum depth beneath `root_id` in the data
/// model. Used by `FnMaxDepth` predicates inside `choose`
/// blocks.
fn max_depth_of(data_model : DataModel, root_id : String) -> Int {
  let mut max_depth = 0
  for child in children_of(root_id, data_model) {
    let depth = 1 + max_depth_of(data_model, child.id)
    if depth > max_depth {
      max_depth = depth
    }
  }
  max_depth
}

///|
/// Return the 1-based position of `context_id` within its
/// parent's children. Root points report position 1.
fn position_of(context_id : String, data_model : DataModel) -> Int {
  let parents = parent_of(context_id, data_model)
  if parents.length() == 0 {
    return 1
  }
  let siblings = children_of(parents[0].id, data_model)
  let mut i = 0
  while i < siblings.length() {
    if siblings[i].id == context_id {
      return i + 1
    }
    i = i + 1
  }
  0
}

///|
/// Return the reverse 1-based position of `context_id` within
/// its parent's children. The last child reports 1.
fn reverse_position_of(context_id : String, data_model : DataModel) -> Int {
  let parents = parent_of(context_id, data_model)
  if parents.length() == 0 {
    return 1
  }
  let siblings = children_of(parents[0].id, data_model)
  let mut i = 0
  while i < siblings.length() {
    if siblings[i].id == context_id {
      return siblings.length() - i
    }
    i = i + 1
  }
  0
}

///|
/// Subtract the margin constraints (`lMarg`, `rMarg`, `tMarg`,
/// `bMarg`) from `bounds`. Negative or zero results clamp to
/// zero so children always receive a non-negative box.
pub fn apply_margins(
  bounds : BoundsRect,
  constraints : Array[Constraint],
) -> BoundsRect {
  let l_marg = constraint_value(constraints, ConstrLMarg)
  let r_marg = constraint_value(constraints, ConstrRMarg)
  let t_marg = constraint_value(constraints, ConstrTMarg)
  let b_marg = constraint_value(constraints, ConstrBMarg)
  let new_width = bounds.width - l_marg - r_marg
  let new_height = bounds.height - t_marg - b_marg
  let safe_w = if new_width < 0.0 { 0.0 } else { new_width }
  let safe_h = if new_height < 0.0 { 0.0 } else { new_height }
  { x: bounds.x + l_marg, y: bounds.y + t_marg, width: safe_w, height: safe_h }
}

///|
/// Look up a constraint value by `ConstraintKind`. Returns `0.0`
/// when the constraint is absent. `ConstrOther` values are
/// ignored because they fall outside the canonical vocabulary.
pub fn constraint_value(
  constraints : Array[Constraint],
  kind : ConstraintKind,
) -> Double {
  for c in constraints {
    if constraint_kind_eq(c.kind, kind) {
      match c.val {
        Some(value) => return value
        None => ()
      }
    }
  }
  0.0
}

///|
/// Equality for `ConstraintKind`. `derive(Eq)` does not handle
/// the `ConstrOther(String)` variant the way we want here (we
/// only need equality on the discriminator), so we spell it out.
fn constraint_kind_eq(a : ConstraintKind, b : ConstraintKind) -> Bool {
  match (a, b) {
    (ConstrW, ConstrW) => true
    (ConstrH, ConstrH) => true
    (ConstrL, ConstrL) => true
    (ConstrT, ConstrT) => true
    (ConstrR, ConstrR) => true
    (ConstrB, ConstrB) => true
    (ConstrLMarg, ConstrLMarg) => true
    (ConstrRMarg, ConstrRMarg) => true
    (ConstrTMarg, ConstrTMarg) => true
    (ConstrBMarg, ConstrBMarg) => true
    (ConstrSp, ConstrSp) => true
    (ConstrSibSp, ConstrSibSp) => true
    (ConstrWOff, ConstrWOff) => true
    (ConstrHOff, ConstrHOff) => true
    (ConstrPyraAcctRatio, ConstrPyraAcctRatio) => true
    (ConstrOther(x), ConstrOther(y)) => x == y
    _ => false
  }
}

///|
/// Apply `node.pres_of` (or the implicit `presOf` default when
/// absent) — record the node's bounds against every data point
/// selected by the axis. The preset shape is taken from
/// `node.shape.preset`; a missing or unknown preset falls back to
/// `ShapeRect` so the renderer always sees a valid shape.
pub fn apply_pres_of(
  node : LayoutNode,
  bounds : BoundsRect,
  context : EvalContext,
) -> Unit {
  let shape = match node.shape {
    Some(s) =>
      match s.preset {
        Some(p) => p
        None => @preset_geometry.ShapeRect
      }
    None => @preset_geometry.ShapeRect
  }
  let targets = match node.pres_of {
    Some(spec) =>
      axis_select(spec.axis, spec.pt_type, context) |> slice_pres_of(spec)
    None => {
      let acc : Array[DiagramPoint] = []
      for point in context.data_model.points {
        if point.id == context.context_id {
          acc.push(point)
          break
        }
      }
      acc
    }
  }
  // Only emit a NodeBounds when the layout node carries an
  // explicit shape or an explicit presOf; pure layout container
  // nodes (those with neither a shape nor a presOf) should not
  // produce a NodeBounds entry of their own.
  let should_emit = node.shape is Some(_) || node.pres_of is Some(_)
  if !should_emit {
    return
  }
  for target in targets {
    context.results.push({
      point_id: target.id,
      bounds,
      shape,
      style_lbl: node.style_lbl,
    })
  }
}

///|
/// Apply `cnt` / `st` / `step` slicing to a `presOf` target
/// selection. The schema and the spec example in §21.4.2.21 use
/// the same semantics as `forEach`, so we share the helper.
fn slice_pres_of(
  selection : Array[DiagramPoint],
  spec : PresOfSpec,
) -> Array[DiagramPoint] {
  let start = if spec.st < 1 { 0 } else { spec.st - 1 }
  let step = if spec.step <= 0 { 1 } else { spec.step }
  let mut i = start
  let result : Array[DiagramPoint] = []
  while i < selection.length() {
    result.push(selection[i])
    let limit_reached = match spec.cnt {
      Some(c) => result.length() >= c
      None => false
    }
    if limit_reached {
      break
    }
    i = i + step
  }
  result
}
