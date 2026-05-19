# G14 — PresentationML Placeholder Inheritance

Tracks the Tier-3 gap "PML slide layout/master placeholder inheritance"
from `.indexion/plans/shallow-audit/audit.md` (#11).

## Source sections

- Part 1 §19.3.1.36 `ph` / `CT_Placeholder` — `idx`, `type`, `sz`,
  `orient`, `hasCustomPrompt` attributes.
- Part 1 §19.7.10 `ST_PlaceholderType` — 18 enumeration values (`body`,
  `chart`, `clipArt`, `ctrTitle`, `dgm`, `dt`, `ftr`, `hdr`, `media`,
  `obj`, `pic`, `sldImg`, `sldNum`, `subTitle`, `tbl`, `title`).
  (Spec lists "body", "chart", "clipArt", "ctrTitle", "dgm", "dt",
  "ftr", "hdr", "media", "obj", "pic", "sldImg", "sldNum", "subTitle",
  "tbl", "title" — 16 distinct values per the table.)
- Part 1 §19.7.9 `ST_PlaceholderSize` — `full`, `half`, `quarter`.
- Part 1 §19.7.2 `ST_Direction` — `horz`, `vert` (for `orient`).
- Part 1 §19.3.1.38 `sld`, §19.3.1.39 `sldLayout`, §19.3.1.42
  `sldMaster` — slide / layout / master relationship.

## Functional requirements

### Requirement 1: Typed placeholder decoding

`decode_placeholder(@domain.CT_Placeholder)` shall return a typed
`Placeholder` carrying the decoded attributes:

- `idx : Int?` (XML Schema unsignedInt, absent on type-only phs)
- `ph_type : PlaceholderType?` (absent → caller treats as `Body`)
- `size : PlaceholderSize?`
- `orient : PlaceholderOrient?`
- `has_custom_prompt : Bool`

Attribute parsing failures shall raise `@opc_errors.SchemaViolation`
identifying the offending attribute.

### Requirement 2: Shape placeholder lookup

`decode_shape_placeholder(@domain.CT_Shape)` shall walk
`p:sp/p:nvSpPr/p:nvPr/p:ph` and return `Some(Placeholder)` if present
or `None` otherwise.

### Requirement 3: Slide chain construction

`SlideChain::from_slide(slide_master, slide_layout?, slide?)` shall
hold the three optional levels and expose `shapes_at(level)` that
returns the `p:sp` child elements of each level's `p:cSld/p:spTree`.

### Requirement 4: Placeholder index match

`resolve_placeholder(shape, chain)` shall match a slide shape's
`Placeholder.idx` against a layout shape with the same `idx`, then
against a master shape with the same `idx` (per Microsoft / spec
practice). The resolver records the (slide, layout, master) shapes
that participate in the resolution.

### Requirement 5: Placeholder type match

If the slide placeholder has no `idx`, or the layout/master shape with
the matching `idx` carries a non-empty `type`, the resolver shall fall
through to type matching: the layout shape's `type` (or the slide
placeholder's `type`) shall be matched against the master shape whose
`ph` has the same `type`. `ctrTitle` shapes in a layout shall match
the master's `title` placeholder (per the canonical Microsoft
mapping).

### Requirement 6: Effective placeholder

The resolved `EffectivePlaceholder` shall combine the slide / layout /
master placeholder attributes, taking the first non-`None` value
encountered when walking slide → layout → master. The `type` defaults
to `Body` and the `size` defaults to `Full` when no level supplies one
(per §19.7.9 — `full` is the canonical default).

### Requirement 7: Shape-level field merge

`resolve_shape(shape, chain)` shall return a `ResolvedShape` whose
`sp_pr`, `tx_body`, `nv_sp_pr` element handles are merged across the
chain: the resolver returns the slide-level element if present, else
the layout-level element, else the master-level element. The merge
emits the chain index of the contributing level alongside the element
so renderers can apply DML inheritance separately.

### Requirement 8: Diagnostic helpers

The package shall expose a section-name accessor
`placeholder_part1_19_3_1_36_section_name()` returning the canonical
`Part 1 §19.3.1.36` citation for use in error reports, matching the
pattern used by sibling packages.

## Non-functional requirements

- Pure functions on `@xml.Element`; no I/O.
- `pub fn` bodies satisfy the indexion SHALLOW gate (>4 lines of
  non-trivial logic) so `spec align status --fail-on any` passes for
  `ecma376/presentation_ml`.
- White-box tests cover at least: idx-match, type-match,
  ctrTitle→title fallback, size/orient inheritance, missing-layer
  fallback to master defaults, and the section-name accessor.

## Out of scope

- DML field merge (color, font, paragraph properties). The resolver
  exposes the contributing elements; DML merge sits in `drawing_ml/*`.
- Notes slide / notes master placeholders. The chain construction
  accepts only `sld / sldLayout / sldMaster`; notes can re-use the
  same primitives later (`NotesChain`) without changing this package.
- Animation timing inheritance — G15.
