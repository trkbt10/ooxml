///|
/// Canonical citation for the §21.4 SmartArt layout section. Used
/// in `SchemaViolation` errors so callers see exactly which spec
/// chapter the engine is validating against.
let diagram_layout_section : String = "Part 1 §21.4"

///|
/// Return the canonical Part 1 §21.4 citation for diagram layout
/// errors. Centralised so audit tooling can spot-check that every
/// error string in this package cites the same section.
pub fn diagram_layout_part1_21_4_section_name() -> String {
  diagram_layout_section
}

///|
/// Part 1 §21.4.7.1 ST_AlgorithmType — the closed enumeration of
/// SmartArt layout algorithms allowed on the `alg/@type` attribute.
/// Variants follow the spec lexical forms verbatim so the decoder
/// table stays bit-for-bit aligned with §21.4.7.1.
pub(all) enum AlgorithmType {
  /// §21.4.7.1 composite — places children at fixed positions.
  AlgComposite
  /// §21.4.7.1 conn — routes connector lines between nodes.
  AlgConn
  /// §21.4.7.1 cycle — children evenly distributed on a circle.
  AlgCycle
  /// §21.4.7.1 hierChild — child layout under `hierRoot`.
  AlgHierChild
  /// §21.4.7.1 hierRoot — hierarchy tree root.
  AlgHierRoot
  /// §21.4.7.1 lin — linear (row / column) layout.
  AlgLin
  /// §21.4.7.1 pyra — pyramid (stacked trapezoid) layout.
  AlgPyra
  /// §21.4.7.1 snake — multi-row linear layout with wrap.
  AlgSnake
  /// §21.4.7.1 sp — minimum-space placeholder (no-op layout).
  AlgSp
  /// §21.4.7.1 tx — text-fitting algorithm.
  AlgTx
} derive(Eq, Debug)

///|
/// Part 1 §21.4.7.1 — decode an `alg/@type` lexical token into the
/// typed `AlgorithmType`. Unknown tokens raise `SchemaViolation`
/// so audit tooling can spot non-canonical algorithm names.
pub fn AlgorithmType::from_attr(
  value : String,
) -> AlgorithmType raise @opc_errors.SchemaViolation {
  match value {
    "composite" => AlgComposite
    "conn" => AlgConn
    "cycle" => AlgCycle
    "hierChild" => AlgHierChild
    "hierRoot" => AlgHierRoot
    "lin" => AlgLin
    "pyra" => AlgPyra
    "snake" => AlgSnake
    "sp" => AlgSp
    "tx" => AlgTx
    _ =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path="alg/@type",
        reason="unknown ST_AlgorithmType lexical value: " + value,
      )
  }
}

///|
/// Report whether the engine has a faithful (non-fallback)
/// implementation for the supplied algorithm type. `composite`,
/// `conn`, `sp`, and `tx` fall back to `lin` in this package and
/// are reported as unsupported here so callers can warn.
pub fn AlgorithmType::is_supported(self : AlgorithmType) -> Bool {
  match self {
    AlgLin | AlgSnake | AlgCycle | AlgHierRoot | AlgHierChild | AlgPyra => true
    _ => false
  }
}

///|
/// Part 1 §21.4.2.3 alg — decoded algorithm record. `params`
/// preserves the original `(type, val)` pairs in document order so
/// the per-algorithm code can look up its own keys (e.g. `bkpt`
/// for snake, `linDir` for lin) without re-walking the XML.
pub(all) struct Algorithm {
  kind : AlgorithmType
  params : Array[(String, String)]
} derive(Eq, Debug)

///|
/// Look up the first parameter value associated with the supplied
/// `type` key. Diagram parameter lists are short (rarely above
/// half a dozen entries) so the linear scan is cheaper than the
/// hash overhead.
pub fn Algorithm::param(self : Algorithm, key : String) -> String? {
  for entry in self.params {
    let (k, v) = entry
    if k == key {
      return Some(v)
    }
  }
  None
}

///|
/// Part 1 §21.4.7.21 ST_ConstraintType — the closed enumeration of
/// constraint types. The engine recognises the size / position /
/// margin / spacing values consumed by the canonical layouts;
/// everything else round-trips through `ConstrOther` so the
/// decoder never throws on a legal but unhandled constraint.
pub(all) enum ConstraintKind {
  /// §21.4.7.21 w — explicit width.
  ConstrW
  /// §21.4.7.21 h — explicit height.
  ConstrH
  /// §21.4.7.21 l — left anchor.
  ConstrL
  /// §21.4.7.21 t — top anchor.
  ConstrT
  /// §21.4.7.21 r — right anchor.
  ConstrR
  /// §21.4.7.21 b — bottom anchor.
  ConstrB
  /// §21.4.7.21 lMarg — left margin (padding).
  ConstrLMarg
  /// §21.4.7.21 rMarg — right margin (padding).
  ConstrRMarg
  /// §21.4.7.21 tMarg — top margin (padding).
  ConstrTMarg
  /// §21.4.7.21 bMarg — bottom margin (padding).
  ConstrBMarg
  /// §21.4.7.21 sp — generic spacing.
  ConstrSp
  /// §21.4.7.21 sibSp — sibling spacing.
  ConstrSibSp
  /// §21.4.7.21 wOff — additive width offset.
  ConstrWOff
  /// §21.4.7.21 hOff — additive height offset.
  ConstrHOff
  /// §21.4.7.21 pyraAcctRatio — pyramid accent (top width fraction).
  ConstrPyraAcctRatio
  /// §21.4.7.21 catch-all bucket; preserves the unmapped lexical
  /// value so audit tooling can report it.
  ConstrOther(String)
} derive(Eq, Debug)

///|
/// Decode a `constr/@type` lexical token. Out-of-table values are
/// preserved as `ConstrOther` rather than raising, so a single
/// unknown constraint cannot prevent the whole layout from
/// decoding.
pub fn ConstraintKind::from_attr(value : String) -> ConstraintKind {
  match value {
    "w" => ConstrW
    "h" => ConstrH
    "l" => ConstrL
    "t" => ConstrT
    "r" => ConstrR
    "b" => ConstrB
    "lMarg" => ConstrLMarg
    "rMarg" => ConstrRMarg
    "tMarg" => ConstrTMarg
    "bMarg" => ConstrBMarg
    "sp" => ConstrSp
    "sibSp" => ConstrSibSp
    "wOff" => ConstrWOff
    "hOff" => ConstrHOff
    "pyraAcctRatio" => ConstrPyraAcctRatio
    _ => ConstrOther(value)
  }
}

///|
/// Part 1 §21.4.7.32 ST_FunctionOperator — the comparison
/// operators usable on `if/@op` and `constr/@op`. Six values, all
/// strict comparisons; the spec defines no string-relational ops.
pub(all) enum FunctionOp {
  /// §21.4.7.32 equ — equality.
  OpEqu
  /// §21.4.7.32 neq — inequality.
  OpNeq
  /// §21.4.7.32 gt — strictly greater than.
  OpGt
  /// §21.4.7.32 lt — strictly less than.
  OpGte
  /// §21.4.7.32 gte — greater than or equal.
  OpGteValue
  /// §21.4.7.32 lte — less than or equal.
  OpLte
} derive(Eq, Debug)

///|
/// Decode a `@op` attribute lexical value into the typed
/// `FunctionOp`. Unknown lexical values raise `SchemaViolation`
/// since the spec defines a closed set and renderers must reject
/// extensions.
pub fn FunctionOp::from_attr(
  value : String,
) -> FunctionOp raise @opc_errors.SchemaViolation {
  match value {
    "equ" => OpEqu
    "neq" => OpNeq
    "gt" => OpGt
    "lt" => OpGte
    "gte" => OpGteValue
    "lte" => OpLte
    _ =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path="@op",
        reason="unknown ST_FunctionOperator lexical value: " + value,
      )
  }
}

///|
/// Part 1 §21.4.7.33 ST_FunctionType — the conditional expression
/// functions usable inside `choose/if/@func`. Used by
/// `evaluate_choose` to compute the LHS of a predicate against the
/// current evaluation context.
pub(all) enum FunctionType {
  /// §21.4.7.33 cnt — count of children selected by the axis.
  FnCnt
  /// §21.4.7.33 depth — depth of the context point in the tree.
  FnDepth
  /// §21.4.7.33 maxDepth — maximum depth beneath the context.
  FnMaxDepth
  /// §21.4.7.33 pos — 1-based position of the context point
  /// within its sibling list.
  FnPos
  /// §21.4.7.33 posEven — 1 if `pos` is even, else 0.
  FnPosEven
  /// §21.4.7.33 posOdd — 1 if `pos` is odd, else 0.
  FnPosOdd
  /// §21.4.7.33 revPos — reverse 1-based position from the end of
  /// the sibling list.
  FnRevPos
  /// §21.4.7.33 var — reference a layout variable. Always
  /// evaluates to 0 in this package; the layout-variable resolver
  /// is a separate audit gap.
  FnVar
} derive(Eq, Debug)

///|
/// Decode a `if/@func` lexical value. Unknown lexical values raise
/// `SchemaViolation` because the spec defines a closed set.
pub fn FunctionType::from_attr(
  value : String,
) -> FunctionType raise @opc_errors.SchemaViolation {
  match value {
    "cnt" => FnCnt
    "depth" => FnDepth
    "maxDepth" => FnMaxDepth
    "pos" => FnPos
    "posEven" => FnPosEven
    "posOdd" => FnPosOdd
    "revPos" => FnRevPos
    "var" => FnVar
    _ =>
      raise @opc_errors.SchemaViolation(
        section=diagram_layout_section,
        path="if/@func",
        reason="unknown ST_FunctionType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §21.4.7.6 ST_AxisType — the axes against which a
/// `forEach`, `presOf`, or `if` can select data-model points.
/// Twelve canonical values plus `AxisNone` for the
/// schema-default-absent case.
pub(all) enum AxisType {
  /// §21.4.7.6 self — the context point only.
  AxisSelf
  /// §21.4.7.6 ch — immediate children of the context point.
  AxisCh
  /// §21.4.7.6 des — every descendant of the context point.
  AxisDes
  /// §21.4.7.6 desOrSelf — the context point plus every descendant.
  AxisDesOrSelf
  /// §21.4.7.6 par — the parent of the context point.
  AxisPar
  /// §21.4.7.6 ancst — every ancestor up to the root.
  AxisAncst
  /// §21.4.7.6 ancstOrSelf — every ancestor including the context.
  AxisAncstOrSelf
  /// §21.4.7.6 followSib — siblings appearing after the context.
  AxisFollowSib
  /// §21.4.7.6 precedSib — siblings appearing before the context.
  AxisPrecedSib
  /// §21.4.7.6 follow — `followSib` plus their descendants.
  AxisFollow
  /// §21.4.7.6 preced — `precedSib` plus their descendants.
  AxisPreced
  /// §21.4.7.6 root — the data-model root point.
  AxisRoot
  /// §21.4.7.6 none — schema default when the axis is absent.
  AxisNone
} derive(Eq, Debug)

///|
/// Decode a `@axis` attribute lexical value. Unknown values fall
/// back to `AxisNone` rather than raising so a single malformed
/// axis token cannot bring down the whole layout decode.
pub fn AxisType::from_attr(value : String) -> AxisType {
  match value {
    "self" => AxisSelf
    "ch" => AxisCh
    "des" => AxisDes
    "desOrSelf" => AxisDesOrSelf
    "par" => AxisPar
    "ancst" => AxisAncst
    "ancstOrSelf" => AxisAncstOrSelf
    "followSib" => AxisFollowSib
    "precedSib" => AxisPrecedSib
    "follow" => AxisFollow
    "preced" => AxisPreced
    "root" => AxisRoot
    "none" => AxisNone
    _ => AxisNone
  }
}

///|
/// Part 1 §21.4.7.27 ST_ElementType — the point-type filter used
/// by `forEach`, `presOf`, and `if`. The closed set covers `node`,
/// `parTrans`, `sibTrans`, `asst`, `nonAsst`, `doc`, `pres`, plus
/// the catch-all `all`; out-of-table tokens are preserved via
/// `ElOther` so the decoder never throws.
pub(all) enum ElementType {
  /// §21.4.7.27 node — data-model node points.
  ElNode
  /// §21.4.7.27 parTrans — parent-transition points.
  ElParTrans
  /// §21.4.7.27 sibTrans — sibling-transition points.
  ElSibTrans
  /// §21.4.7.27 asst — assistant points.
  ElAsst
  /// §21.4.7.27 nonAsst — non-assistant points.
  ElNonAsst
  /// §21.4.7.27 doc — document-level (root) point.
  ElDoc
  /// §21.4.7.27 pres — presentation-of (binding) points.
  ElPres
  /// §21.4.7.27 all — every point regardless of type (default).
  ElAll
  /// Catch-all for non-canonical lexical values; preserved so
  /// audit tooling can surface them later.
  ElOther(String)
} derive(Eq, Debug)

///|
/// Decode a `@ptType` attribute lexical value. Multi-token lists
/// are split by the caller; this decoder handles only a single
/// token.
pub fn ElementType::from_attr(value : String) -> ElementType {
  match value {
    "node" => ElNode
    "parTrans" => ElParTrans
    "sibTrans" => ElSibTrans
    "asst" => ElAsst
    "nonAsst" => ElNonAsst
    "doc" => ElDoc
    "pres" => ElPres
    "all" => ElAll
    _ => ElOther(value)
  }
}

///|
/// Part 1 §21.4.2.8 constr — decoded constraint record. Every
/// non-required attribute is optional; the engine reads only the
/// `kind` + `val` pair for the canonical layouts and preserves the
/// rest so callers can implement reference constraints later.
pub(all) struct Constraint {
  kind : ConstraintKind
  for_target : String?
  for_name : String?
  ref_for_target : String?
  ref_for_name : String?
  op : FunctionOp?
  val : Double?
  fact : Double?
} derive(Eq, Debug)

///|
/// Part 1 §21.4.2.21 presOf — data-source binding axis. A layout
/// node carrying a `presOf` records its computed bounds against
/// every data point the axis selects (instead of the current
/// context point). The default `st = 1` matches the schema and
/// the spec example in §21.4.2.21.
pub(all) struct PresOfSpec {
  axis : AxisType
  pt_type : ElementType
  cnt : Int?
  st : Int
  step : Int
} derive(Eq, Debug)

///|
/// Part 1 §21.4.2.14 forEach — iterator over data-model points.
/// The `body` is the layout-child sequence executed once per
/// selected data point. `st` and `step` mirror the schema
/// defaults (`st = 1`, `step = 1`).
pub(all) struct ForEachSpec {
  name : String
  axis : AxisType
  pt_type : ElementType
  cnt : Int?
  st : Int
  step : Int
  body : Array[LayoutChild]
} derive(Eq, Debug)

///|
/// Part 1 §21.4.2.15 if / §21.4.2.12 else — a single branch of a
/// `choose` element. `is_else` distinguishes the catch-all
/// `<else>` branch from a regular `<if>`; predicate attributes are
/// optional on the `else` branch and absent there.
pub(all) struct ChooseBranch {
  name : String
  is_else : Bool
  func : FunctionType?
  arg : String?
  axis : AxisType
  pt_type : ElementType
  op : FunctionOp?
  val : String?
  body : Array[LayoutChild]
} derive(Eq, Debug)

///|
/// Part 1 §21.4.2.27 shape — the preset-shape reference attached
/// to a layout node. `hide_geom` controls whether the renderer
/// draws the shape at all (text-only nodes set it to `true`).
pub(all) struct Shape {
  preset : @preset_geometry.PresetShape?
  hide_geom : Bool
} derive(Eq, Debug)

///|
/// One child of a `layoutNode`: another `layoutNode`, a
/// `choose` block (sequence of `if` / `else` branches), or a
/// `forEach` iterator. The schema permits an arbitrary
/// interleaving of these three in document order.
pub(all) enum LayoutChild {
  /// §21.4.2.19 layoutNode — nested layout node child.
  LcNode(LayoutNode)
  /// §21.4.2.6 choose — ordered list of branches (`if*`, `else?`).
  LcChoose(Array[ChooseBranch])
  /// §21.4.2.14 forEach — iterator over selected data-model points.
  LcForEach(ForEachSpec)
} derive(Eq, Debug)

///|
/// Part 1 §21.4.2.19 layoutNode — decoded layout-node tree node.
/// Every field is optional except `name`, mirroring the schema
/// (the schema makes `name` required and every child element
/// optional with `minOccurs = 0`).
pub(all) struct LayoutNode {
  name : String
  style_lbl : String?
  ch_order : String?
  algorithm : Algorithm?
  shape : Shape?
  pres_of : PresOfSpec?
  constraints : Array[Constraint]
  children : Array[LayoutChild]
} derive(Eq, Debug)

///|
/// Part 1 §21.4.2.16 layoutDef — root of a SmartArt layout
/// definition. The engine reads the root layout node + the three
/// top-level attributes; the title / description / category
/// children are renderer-only metadata and are intentionally not
/// surfaced here.
pub(all) struct DiagramDefinition {
  unique_id : String?
  min_ver : String?
  def_style : String?
  root : LayoutNode
} derive(Eq, Debug)

///|
/// Part 1 §21.4.3 pt — a single data-model point. `parent_id` is
/// populated by `decode_data_model` after walking the connection
/// list, so callers can navigate the tree without re-scanning
/// `cxnLst` on every access.
pub(all) struct DiagramPoint {
  id : String
  point_type : String
  parent_id : String?
  text : String?
  pr_set : @xml.Element?
  sp_pr : @xml.Element?
} derive(Eq, Debug)

///|
/// Part 1 §21.4.3 cxn — a single connection record. `cxn_type`
/// defaults to `parOf` per the schema; other values (`presOf`,
/// `presParOf`, `unknownRelationship`) describe presentation-only
/// links that the layout engine ignores.
pub(all) struct DiagramConnection {
  id : String?
  src_id : String
  dest_id : String
  src_ord : Int
  dest_ord : Int
  cxn_type : String
} derive(Eq, Debug)

///|
/// Part 1 §21.4.2.10 dataModel — typed point + connection lists.
/// The list order matches document order, which is significant
/// for `axis = ch` selections (the iteration sequence mirrors the
/// XML source).
pub(all) struct DataModel {
  points : Array[DiagramPoint]
  connections : Array[DiagramConnection]
} derive(Eq, Debug)

///|
/// Axis-aligned bounding rectangle in the engine's coordinate
/// space. All four fields share whatever unit the caller passes
/// to `DiagramLayoutEngine::apply` (typically EMUs or pixels).
pub(all) struct BoundsRect {
  x : Double
  y : Double
  width : Double
  height : Double
} derive(Eq, Debug)

///|
/// Output record produced by `DiagramLayoutEngine::apply`. One
/// `NodeBounds` is emitted per data point that the layout reaches;
/// `shape` is the preset shape the renderer should draw at the
/// supplied `bounds`. Unknown / missing preset shapes default to
/// `ShapeRect` so a renderer never sees an empty shape.
pub(all) struct NodeBounds {
  point_id : String
  bounds : BoundsRect
  shape : @preset_geometry.PresetShape
} derive(Eq, Debug)

///|
/// Evaluation context threaded through the engine's recursive
/// walk. `results` accumulates the output `NodeBounds`; `depth`
/// is the current tree depth measured from the root (0-based) so
/// `FnDepth` / `FnMaxDepth` can be evaluated cheaply.
pub(all) struct EvalContext {
  data_model : DataModel
  context_id : String
  depth : Int
  results : Array[NodeBounds]
}

///|
/// Engine entry-point handle. Kept as a struct (rather than a
/// free function) so the public surface mirrors the engine
/// pattern used by sibling packages
/// (`@drawing_ml.color_resolution`,
/// `@wordprocessing_ml.style_resolver`). The single `tag` field
/// carries a literal `0` so the struct has a non-empty layout
/// MoonBit can derive `Eq` on.
pub(all) struct DiagramLayoutEngine {
  tag : Int
} derive(Eq, Debug)

///|
/// Construct a fresh `DiagramLayoutEngine`. The engine is
/// stateless; the helper exists so callers do not have to spell
/// out the literal struct at every call site.
pub fn DiagramLayoutEngine::new() -> DiagramLayoutEngine {
  { tag: 0 }
}
