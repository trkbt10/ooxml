# G11 — DrawingML Preset Shape Geometry Generation

Tracks the Tier-3 gap "Preset shape geometry generation" from
`.indexion/plans/shallow-audit/audit.md` (#13).

## Source sections

- Part 1 §20.1.9.18 `prstGeom` / `CT_PresetGeometry2D` — `prst` (required)
  + optional `avLst` (`CT_GeomGuideList`) for adjustment-handle overrides.
- Part 1 §20.1.9 `CT_GeomGuide` — `name` + `fmla` of the adjustment guide
  values used by preset shape definitions.
- Part 1 §20.1.10.56 `ST_ShapeType` — restriction of `xsd:token` to the
  187 preset shape lexical forms enumerated in the canonical XSD (lines
  199289..199506 of `part1.full.txt`).
- Part 1 §20.1.9.11 `gd` / formula syntax — `val n` returns the numeric
  guide value used by `avLst` overrides.

## Functional requirements

### Requirement 1: Typed preset shape

`PresetShape` shall enumerate every ST_ShapeType lexical form (187
distinct values per the XSD). The enum is the single source of truth for
"is this a recognised preset?" lookups.

### Requirement 2: from_attr decoder

`PresetShape::from_attr(value : String) -> PresetShape raise
@opc_errors.SchemaViolation` shall decode any of the 187 lexical forms.
Unknown values shall raise `SchemaViolation` citing `Part 1 §20.1.10.56`
and the offending lexical form.

### Requirement 3: Shape family classification

`PresetShape::family(self) -> PresetShapeFamily` shall classify each
preset into one of: `Rectangular`, `Arrow`, `Callout`, `Star`,
`FlowChart`, `ActionButton`, `Connector`, `Bracket`, `Math`, `Banner`,
`Misc`. The classification is used by renderers to choose a default
fill style and by the geometry resolver to dispatch into the right
shape-family file.

### Requirement 4: Adjustment decoding

`decode_adjustment(@xml.Element) -> Adjustment` shall decode a single
`a:gd` element into a typed `Adjustment { name, value }`, parsing the
`fmla="val n"` syntax for `val`-formula guides. Non-`val` formulas are
preserved as an opaque string so renderers may decline to interpret
them rather than silently dropping the override.

### Requirement 5: PresetGeometry decoder

`decode_preset_geometry(@xml.Element) -> PresetGeometry raise
@opc_errors.SchemaViolation` shall read a `prstGeom` element, decode
its `prst` attribute via `PresetShape::from_attr`, and collect any
`avLst/gd` adjustment overrides into `Array[Adjustment]`. Missing
`@prst` raises `SchemaViolation`.

### Requirement 6: Path command vocabulary

`PathCommand` shall enumerate the minimum vector-graphics primitives
needed to express every preset shape geometry on a virtual
`0..coord_max` bounding box:

- `MoveTo(x, y)`
- `LineTo(x, y)`
- `QuadTo(cpx, cpy, x, y)`
- `CurveTo(cp1x, cp1y, cp2x, cp2y, x, y)`
- `ArcTo(rx, ry, x_axis_rotation, large_arc, sweep, x, y)`
- `ClosePath`

`ShapeGeometry { commands : Array[PathCommand], width : Int, height : Int }`
collects the result. The coordinate space is the standard DrawingML
preset coordinate space normalised to `0..100000` per axis (§20.1.10.56
constants `t=0`, `l=0`, `b=h`, `r=w`).

### Requirement 7: build_geometry dispatch

`build_geometry(shape : PresetShape, width : Int, height : Int) ->
ShapeGeometry` shall return a non-empty list of path commands ending in
`ClosePath` (or `LineTo` for the open `line` / connector presets) for
every recognised preset. The dispatch routes to the per-family files:

- `shapes_rect.mbt` — `Rect`, `RoundRect`, `Ellipse`, `Triangle`,
  `RtTriangle`, `Parallelogram`, `Trapezoid`, `Diamond`, `Pentagon`,
  `Hexagon`, `Heptagon`, `Octagon`, `Decagon`, `Dodecagon`, `Plaque`,
  `Heart`, `Cloud`, `SmileyFace`, `Plus`, `MathMinus`, `MathMultiply`,
  `MathDivide`, `MathEqual`, `MathNotEqual`, `MathPlus`.
- `shapes_arrows.mbt` — `RightArrow`, `LeftArrow`, `UpArrow`,
  `DownArrow`, `LeftRightArrow`, `UpDownArrow`.
- `shapes_callouts.mbt` — `Callout1`, `Callout2`, `Callout3`.
- `shapes_stars.mbt` — `Star4`, `Star5`, `Star6`, `Star7`, `Star8`,
  `Star10`, `Star12`, `Star16`, `Star24`, `Star32`.
- `shapes_flowchart.mbt` — `FlowChartProcess`, `FlowChartDecision`,
  `FlowChartTerminator`, `FlowChartConnector`,
  `FlowChartInputOutput`.

Every preset shape outside this catalogue shall return the
`rectangular_fallback` geometry (four corners + close path) so a
renderer never sees an empty geometry. The shape's documentation
comment shall mark it as `fallback` so future commits can replace the
fallback with a faithful path.

### Requirement 8: Diagnostic helpers

The package shall expose a section-name accessor
`preset_geometry_part1_20_1_10_56_section_name()` returning
`"Part 1 §20.1.10.56"` for use in diagnostics.

## Non-functional requirements

- Pure functions on `@xml.Element`; no I/O.
- `pub fn` bodies satisfy the indexion SHALLOW gate (>4 lines of
  non-trivial logic). The 187-arm `from_attr` and the 30+ per-shape
  `build_*` functions all exceed the threshold.
- White-box tests cover at least one shape per family (rect, ellipse,
  triangle, rightArrow, star5, callout1, flowChartProcess), the
  rectangular fallback for an unimplemented preset (e.g. `funnel`),
  the decoder happy path, the decoder error path, and the section-name
  accessor.

## Out of scope

- Pixel-accurate replication of the Microsoft preset geometries. The
  in-scope shapes use the canonical aspect-preserving construction;
  future commits can refine individual shapes to match the spec's
  normative images.
- `custGeom` (CT_CustomGeometry2D) interpretation — that requires a
  formula evaluator over the §20.1.9.11 expression language and is
  filed under a future custom-geometry gap.
- `prstTxWarp` (CT_PresetTextShape) text warp paths — out-of-scope for
  the shape geometry gap; lives in a future text-warp commit.
- Adjustment-handle (`ahLst`) interaction — `avLst` overrides are
  decoded into the typed `Adjustment` list but `build_geometry` does
  not consume them in this commit.
