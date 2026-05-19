# G10 — Tasks

1. Plan files (requirements / design / tasks) — this commit.
2. `moon.pkg` declaring imports for `@xml`, `@opc_errors`,
   `@drawing_ml/domain` (the diagram stub), `@preset_geometry`,
   plus the wbtest utf8 import.
3. `types.mbt` — enums (AlgorithmType, ConstraintKind, AxisType,
   ElementType, FunctionType, FunctionOp, FlowDir, GrowDir),
   structs (Constraint, Algorithm, PresOfSpec, ForEachSpec,
   ChooseBranch, Shape, LayoutChild, LayoutNode,
   DiagramDefinition, DiagramPoint, DiagramConnection, DataModel,
   BoundsRect, NodeBounds, EvalContext, DiagramLayoutEngine),
   `from_attr` methods, section-name accessor.
4. `decode.mbt` — XML walkers and decoders for every CT_* used.
5. `algorithms_lin.mbt`, `algorithms_cycle.mbt`,
   `algorithms_hier.mbt`, `algorithms_pyra.mbt` — per-algorithm
   geometry.
6. `engine.mbt` — `DiagramLayoutEngine::apply`, layout-node
   walker, conditional dispatch, presOf binding, axis selection.
7. `engine_wbtest.mbt` — tests for each algorithm, the choose /
   forEach branch, the fallback, the data-model decoder, and the
   section-name accessor.
8. `moon check --target native`, `moon fmt`, `moon info`.
9. `moon test --target native -p
   trkbt10/ooxml/ecma376/drawing_ml/diagram_layout`.
10. `.kiro/scripts/drift.sh --pkg ecma376/drawing_ml/diagram`.
11. Single commit `g10-smartart: §21.4 SmartArt layout algorithm`.
