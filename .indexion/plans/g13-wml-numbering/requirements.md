# G13 — WordprocessingML Numbering Inheritance

Tracks the Tier-3 gap "WML numbering style level inheritance" from
`.indexion/plans/shallow-audit/audit.md` (#12).

## Source sections

- Part 1 §17.9.1 `abstractNum` / `CT_AbstractNum` — abstract numbering
  definition keyed by `abstractNumId`.
- Part 1 §17.9.2 `abstractNumId` — child of `num` linking instance to
  abstract definition.
- Part 1 §17.9.5 `lvl` (override) — content of `lvlOverride`.
- Part 1 §17.9.6 `lvl` (definition) — the per-ilvl properties: `start`,
  `numFmt`, `lvlText`, `lvlJc`, `pPr`, `rPr`, `isLgl`, `lvlRestart`,
  `pStyle`, `suff`, `lvlPicBulletId`, etc.
- Part 1 §17.9.7 `lvlJc`, §17.9.10 `lvlRestart`, §17.9.11 `lvlText`,
  §17.9.17 `numFmt`, §17.9.25 `start`, §17.9.27 `suff` — typed per-lvl
  field types.
- Part 1 §17.9.8 `lvlOverride` — per-ilvl override carried on `num`.
- Part 1 §17.9.12 `multiLevelType` — abstract definition kind.
- Part 1 §17.9.15 `num` / `CT_Num` — numbering instance keyed by
  `numId`, with `abstractNumId` link and optional `lvlOverride`
  entries.
- Part 1 §17.9.16 `numbering` / `CT_Numbering` — root container.
- Part 1 §17.9.21 `numStyleLink`, §17.9.22 `pPr`, §17.9.24 `rPr`,
  §17.9.26 `styleLink` — secondary inheritance paths.
- Part 1 §17.18.59 `ST_NumberFormat` — numFmt enumeration.
- Part 1 §17.18.46 `ST_Jc` — lvlJc enumeration values.

## Functional requirements

### Requirement 1: Typed lvl decoding

`decode_lvl(@domain.CT_Lvl)` shall return a typed `Lvl` carrying:

- `ilvl : Int`
- `start : Int?` (§17.9.25 — default 0 per spec)
- `num_fmt : NumFormat?` (§17.9.17 — enum value)
- `lvl_text : String?` (§17.9.11 — template like `%1.`)
- `lvl_jc : LvlJustification?` (§17.9.7)
- `lvl_restart : Int?` (§17.9.10)
- `p_style : String?` (§17.9.23 — paragraph style id this lvl maps to)
- `suff : LvlSuffix?` (§17.9.27 — tab / space / nothing)
- `is_lgl : Bool` (§17.9.4)
- `lvl_pic_bullet_id : Int?` (§17.9.9)
- `p_pr_element : @xml.Element?` (§17.9.22 — embedded pPr handed to
  DML/wml renderers untouched)
- `r_pr_element : @xml.Element?` (§17.9.24)
- `tplc : String?` (template code, optional)

Attribute parse failures shall raise `@opc_errors.SchemaViolation`
identifying the malformed attribute path.

### Requirement 2: Typed abstractNum decoding

`decode_abstract_num(@domain.CT_AbstractNum)` shall return an
`AbstractNum` with:

- `abstract_num_id : Int`
- `multi_level_type : MultiLevelType?` (§17.9.12 — enum)
- `name : String?` (§17.9.13)
- `nsid : String?` (§17.9.14)
- `tmpl : String?`
- `style_link : String?` (§17.9.26 — references a paragraph style)
- `num_style_link : String?` (§17.9.21 — points to another abstract
  numbering definition via paragraph style indirection)
- `lvls : Array[Lvl]` (sorted ascending by `ilvl`)

### Requirement 3: Typed num decoding

`decode_num(@domain.CT_Num)` shall return a `Num` with:

- `num_id : Int`
- `abstract_num_id : Int`
- `lvl_overrides : Array[LvlOverride]` (each carrying `ilvl`,
  `start_override : Int?`, and `lvl : Lvl?` from §17.9.5)

### Requirement 4: NumberingTable construction

`NumberingTable::from_numbering(@domain.CT_Numbering)` shall decode
the `numbering` root into two indexed lookups: by `abstractNumId` and
by `numId`. Both lookups shall be O(1) (`@hashmap.HashMap`).

### Requirement 5: Level resolution

`resolve_level(table, num_id, ilvl)` shall:

1. Look up the `Num` by `num_id`. If missing, return `None`.
2. Check that `Num`'s `lvl_overrides` for an entry with matching
   `ilvl`. If the entry carries a `Lvl`, that is the base.
   If only `start_override` is present, the base is the abstract
   definition's `Lvl` with the `start` field replaced.
3. Else, look up the `AbstractNum` by `abstract_num_id` and find the
   `Lvl` whose `ilvl` matches.
4. If the abstract definition has a `num_style_link`, the resolver
   shall follow the link to the linked abstract definition (one hop
   only) and search that definition's lvls.
5. Return the resolved `Lvl` (typed) along with a record of where
   each field originated (`level_origin`: SourceOverride / SourceAbstract
   / SourceLinkedAbstract) so renderers can audit the chain.

### Requirement 6: lvlText template formatting

`format_lvl_text(lvl_text, counters)` shall apply the §17.9.11
template substitution: `%N` is replaced by the formatted counter for
1-based level `N` using the supplied numbering format. Counters are
provided as an `Array[Int]` (`counters[i]` = current value of level
`i`). Unmatched `%N` placeholders remain literally.

### Requirement 7: NumFormat::format

`NumFormat::format(value)` shall produce the formatted counter for
the canonical numbering formats: `decimal`, `upperRoman`, `lowerRoman`,
`upperLetter`, `lowerLetter`, `ordinal`, `cardinalText`, `ordinalText`,
`bullet`, `none`, `decimalZero` (per §17.18.59). Unsupported formats
shall return the decimal form as a fall-back and the resolver shall
record that the format was downgraded.

### Requirement 8: Diagnostic helpers

`numbering_part1_17_9_section_name()` shall return the canonical
section citation string `Part 1 §17.9`.

## Non-functional requirements

- Pure functions on `@xml.Element` and `@domain.CT_*` wrappers.
- `pub fn` bodies satisfy SHALLOW (>4 lines of non-trivial logic).
- White-box tests cover: lvl decode, abstractNum decode, num decode,
  basic resolution, lvlOverride wins over abstract, numStyleLink
  follow, NumFormat::format across the 11 formats, lvlText template
  substitution.

## Out of scope

- Multi-document numbering (cross-part references).
- Style-based numbering inheritance via `pStyle` → style → numId
  (handled by `style_resolver` once it learns about numbering, which
  is a separate concern).
- Counter state machine for the renderer (this package returns the
  effective level; the renderer drives counter advances).
