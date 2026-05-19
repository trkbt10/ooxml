# G10 — DrawingML SmartArt Layout Algorithm

Tracks the Tier-3 gap "SmartArt diagram layout algorithm" from
`.indexion/plans/shallow-audit/audit.md` (#15).

## Source sections (Part 1 §21.4)

- §21.4.2.3   `alg` — CT_Algorithm (`@type` enumerates layout
  algorithm).
- §21.4.2.6   `choose` / §21.4.2.15 `if` / §21.4.2.12 `else` —
  CT_Choose / CT_When / CT_Otherwise conditional layout.
- §21.4.2.8   `constr` — CT_Constraint sizing constraint
  (`type`, `for`, `forName`, `refType`, `refFor`, `refForName`,
  `op`, `val`, `fact`).
- §21.4.2.9   `constrLst` — CT_Constraints sequence.
- §21.4.2.10  `dataModel` — CT_DataModel `ptLst` + `cxnLst`.
- §21.4.2.14  `forEach` — CT_ForEach (`axis`, `ptType`, `cnt`,
  `st`, `step`).
- §21.4.2.16  `layoutDef` — CT_DiagramDefinition (root).
- §21.4.2.19  `layoutNode` — CT_LayoutNode (`name`, `styleLbl`,
  `chOrder`, `moveWith`; children `alg`, `shape`, `presOf`,
  `constrLst`, `ruleLst`, `varLst`, `forEach`, `layoutNode`,
  `choose`).
- §21.4.2.20  `param` — CT_Parameter (`type`, `val`).
- §21.4.2.21  `presOf` — CT_PresentationOf (data-source binding
  axis: `axis`, `ptType`, `cnt`, `st`, `step`).
- §21.4.2.27  `shape` — CT_Shape (`type` = preset shape name from
  §20.1.10.56 ST_ShapeType).
- §21.4.3.2   `cxnLst` / §21.4.3.3 `pt` — data model point.
- §21.4.7.1   ST_AlgorithmType (`composite | conn | cycle |
  hierChild | hierRoot | lin | pyra | snake | sp | tx`).
- §21.4.7.21  ST_ConstraintType (49 values; see Constraints
  below).
- §21.4.7.32  ST_FunctionOperator (`equ | neq | gt | lt | gte |
  lte`).
- §21.4.7.33  ST_FunctionType (`cnt | depth | maxDepth | pos |
  posEven | posOdd | revPos | var`).

## Functional requirements

### Requirement 1: Layout-definition decoder

`decode_diagram_definition(@domain.CT_DiagramDefinition)` shall
return a typed `DiagramDefinition` carrying:

- the root `LayoutNode` tree (recursive across `layoutNode`,
  `choose/if/else`, `forEach`),
- the `defStyle / minVer / uniqueId` attributes.

Each `LayoutNode` shall expose its `name`, `styleLbl`, `chOrder`,
`moveWith`, optional `Algorithm`, optional `Shape`, optional
`PresentationOf`, decoded `Constraint[]`, and ordered
`LayoutChild[]` children (recursive `LayoutNode`, `Choose`,
`ForEach`).

Attribute parsing failures shall raise
`@opc_errors.SchemaViolation` identifying the offending node.

### Requirement 2: Data-model decoder

`decode_data_model(@domain.CT_DataModel)` shall return a typed
`DataModel { points, connections }`:

- `points : Array[DiagramPoint { id, point_type, parent_id, text,
  pr_set, sp_pr }]` keyed by `@modelId` (§21.4.3 pt).
- `connections : Array[DiagramConnection { id, src_id, dest_id,
  src_ord, dest_ord, cxn_type }]` (§21.4.3.3 cxn).
- `parent_id` is computed by walking `cxnLst` for `cxn/@type =
  parOf` (or the default), so every non-root point exposes its
  parent.

Missing `@modelId` raises `SchemaViolation` (§21.4.3 mandates it
on every `pt`).

### Requirement 3: Layout engine

`DiagramLayoutEngine::apply(definition, data_model, bounds)` shall
return `Array[NodeBounds { point_id, bounds, shape }]` where
`bounds = { x, y, width, height }` is in the same coordinate
space as the input `bounds`. The engine walks the layout-node
tree, evaluates `Choose/When/Otherwise`, recurses through
`ForEach`, dispatches on `Algorithm.kind`, applies the resulting
bounds back to data points named via `PresentationOf`, and emits
one `NodeBounds` per data point. The preset shape is derived
from the layout node's `Shape.preset` (via
`@preset_geometry.PresetShape::from_attr`); a missing or unknown
shape falls back to `ShapeRect`.

### Requirement 4: Algorithm — `lin`

The linear algorithm shall divide its bounds into equally-sized
boxes along the major axis (`row` flow direction → left-to-right;
`col` flow direction → top-to-bottom). Each box receives a
sibling-spacing gap controlled by the `sp` constraint when
present. The default flow direction is `row` per spec example
defaults.

### Requirement 5: Algorithm — `snake`

The snake algorithm shall wrap the linear arrangement at a
configurable column count. The column count defaults to
`ceil(sqrt(n))` and is overridden by the `bkpt` parameter when
present. Cells flow left-to-right then top-to-bottom (`grDir =
tL` default) and uniformly share the available width / height
after the gutter `sp` is subtracted.

### Requirement 6: Algorithm — `cycle`

The cycle algorithm shall place N children evenly around a
circle inscribed in the bounding box. The first child sits at
the top (12 o'clock) and children proceed clockwise. Each child
occupies a square of side `min(width, height) / 3`, centred on
its computed angle.

### Requirement 7: Algorithm — `hierChild` / `hierRoot`

The hierarchy algorithms shall lay out a root node along the top
of the bounding box and its direct children in a horizontal row
underneath, recursing for grandchildren as a sub-tree of the same
row layout. The root occupies the top 30 % of the available
height; the remaining 70 % is shared among the immediate
children, each becoming its own sub-hierarchy.

### Requirement 8: Algorithm — `pyra`

The pyramid algorithm shall produce a stacked sequence of
trapezoids from wide-at-base to narrow-at-top, with one data
point per row. Each row's height is `height / n`; the width at
row `i` (0 = top) interpolates linearly between the
`pyraAcctRatio` (top-width fraction, default 0.25) and 1.0
(bottom-width).

### Requirement 9: Conditional layout — `choose / if / else`

`Choose` nodes shall evaluate each `When` branch in document
order against the current `EvalContext` (data model + current
context point + current depth). The first branch whose `func /
op / val` triple matches becomes active; if none match, the
`Otherwise` branch is used. The engine shall support at minimum
the `cnt` function (`cnt` returns the number of children of the
current context point) and `pos / posEven / posOdd / depth /
maxDepth` functions; `var` shall always evaluate to `false`
(variables are not modelled — documented in §"Out of scope"
below).

### Requirement 10: Iteration — `forEach`

`ForEach` nodes shall iterate over the data-set selected by
their `axis` attribute relative to the current context point. The
following axis values shall be supported: `ch` (immediate
children), `des` (all descendants in depth-first order), `self`
(the context point only), and `desOrSelf` (self + descendants).
The `cnt` attribute truncates the set, `st` skips the first
`st - 1` elements (1-based), `step` keeps every `step`-th
element. Each iteration evaluates the `ForEach` body with the
context point set to the iterated data point.

### Requirement 11: PresentationOf binding

When a `LayoutNode` carries a `PresentationOf` child, the engine
shall record the layout node's computed bounds against every data
point selected by the `PresentationOf` axis (using the same
axis vocabulary as Requirement 10). If no `PresentationOf` is
present, the layout node's bounds are recorded against the
current context point, mirroring §21.4.2.21 example defaults.

### Requirement 12: Constraint vocabulary

The engine shall parse and honour the most common §21.4.7.21
constraints used by the canonical layouts:

- `w`, `h` — explicit width / height overrides.
- `l`, `t`, `r`, `b` — anchor offsets.
- `lMarg`, `rMarg`, `tMarg`, `bMarg` — bounding-box padding.
- `sp` (and synonym `sibSp`) — sibling spacing.
- `wOff`, `hOff` — additive width / height offsets.
- `primFontSz`, `secFontSz`, `secSibSp`, `pyraAcctRatio` —
  recorded but not consumed by the geometry pipeline; the
  pyramid algorithm reads `pyraAcctRatio`.

Other constraints shall decode without error and remain as
`Constraint { kind: Other, ... }` so callers can inspect them.

### Requirement 13: Algorithm-type fallback

Algorithm types outside the canonical list (`composite`, `conn`,
`sp`, `tx`) shall fall back to the `lin` algorithm to guarantee a
non-empty geometry response. The engine shall expose
`Algorithm::is_supported(AlgorithmType)` so audit tooling can
report which nodes used the fallback.

### Requirement 14: Diagnostic helpers

The package shall expose a section-name accessor
`diagram_layout_part1_21_4_section_name()` returning the
canonical `Part 1 §21.4` citation for use in error reports,
matching the pattern used by sibling DML packages.

## Non-functional requirements

- Pure functions on `@xml.Element`; no I/O.
- All `pub fn` bodies satisfy the indexion SHALLOW gate
  (>4 lines of non-trivial logic) so the existing diagram drift
  gate continues to pass.
- White-box tests cover at least: one canvas-aligned bounds
  check per algorithm (lin / snake / cycle / hier / pyra), one
  `choose / if` cnt-bucket selection, one `forEach` ch iteration,
  and one unknown-algorithm fallback.

## Out of scope

- Spacing optimisation, text-shrink-to-fit, and the iterative
  layout rebalancing that Office performs to satisfy
  inter-constraint dependencies.
- Color application from `CT_ColorTransform`
  (`drawing_ml/color_resolution` concern).
- Style application from `CT_StyleDefinition` (renderer
  concern).
- Animation timing (§21.4.7.2 / §21.4.7.3 are decoded into the
  data model but not exercised).
- The OLE / chart embedded SmartArt variant.
- `composite`, `conn`, `sp`, and `tx` algorithms; these fall back
  to `lin` per Requirement 13. A follow-up commit may add
  faithful implementations.
- `var` function evaluation in `Choose / If`. Variable bindings
  live on the `CT_LayoutVariablePropertySet` and require a full
  layout-variable resolver, which is a separate audit gap.
