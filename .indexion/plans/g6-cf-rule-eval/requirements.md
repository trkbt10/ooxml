# G6 — Conditional Formatting Rule Evaluator

Tracks the Tier-2 gap "Conditional formatting rule evaluation" from
`.indexion/plans/shallow-audit/audit.md`. Depends on G1 (formula
evaluator) and G4 (theme color), both completed.

## Source sections

- Part 1 §18.3.1.10 `cfRule` (Conditional Formatting Rule) — attribute
  list (`type`, `dxfId`, `priority`, `stopIfTrue`, `aboveAverage`,
  `percent`, `bottom`, `operator`, `text`, `timePeriod`, `rank`,
  `stdDev`, `equalAverage`) and child elements (`formula`, `colorScale`,
  `dataBar`, `iconSet`, `extLst`).
- Part 1 §18.3.1.18 `conditionalFormatting` — outer collection: `pivot`
  attribute, `sqref` attribute (`ST_Sqref`), child `cfRule` list.
- Part 1 §18.18.12 `ST_CfType` — rule type enumeration (16 values).
- Part 1 §18.18.15 `ST_ConditionalFormattingOperator` — comparison
  operator enumeration (12 values) for `cellIs` rules.
- Part 1 §18.18.82 `ST_TimePeriod` — dynamic time-period enumeration
  (10 values) for `timePeriod` rules.
- Part 1 §18.3.1.11 `cfvo` and §18.3.1.16 `colorScale` — gradient
  thresholds for `colorScale`, `dataBar`, `iconSet` rules.

## Functional requirements

### Requirement 1: Typed CT_CfRule attribute decoder

The package shall expose `decode_cf_rule(@domain.CT_CfRule)` returning a
typed `CfRule` struct in which the spec attributes are decoded according
to §18.3.1.10:

- `cf_type : CfType` (§18.18.12 — 16 enum variants)
- `dxf_id : Int?` (§18.18.25 ST_DxfId — index into Styles dxf collection)
- `priority : Int` (lower numeric = higher priority, 1 is highest)
- `stop_if_true : Bool` (default false)
- `operator : CfOperator?` (§18.18.15 — only meaningful when `type = cellIs`)
- `text : String?` (only meaningful when `type = containsText` /
  `notContainsText` / `beginsWith` / `endsWith`)
- `time_period : TimePeriod?` (§18.18.82 — only when `type = timePeriod`)
- `rank : Int?`, `bottom : Bool`, `percent : Bool` (only when
  `type = top10`)
- `above_average : Bool`, `equal_average : Bool`, `std_dev : Int?` (only
  when `type = aboveAverage`)
- `formulas : Array[String]` (raw `<formula>` text in document order;
  most rule types need 0–2 entries, expression / cellIs Between needs
  the corresponding count)
- `color_scale : CfColorScale?`, `data_bar : CfDataBar?`,
  `icon_set : CfIconSet?` (parsed from §18.3.1.16 / §18.3.1.28 /
  §18.3.1.49 children when present)

Attribute parsing failures shall raise `@opc_errors.SchemaViolation`
with the offending attribute name.

### Requirement 2: cellIs comparison evaluation

For rules with `cf_type = CellIs`, the evaluator shall, given the cell
value under evaluation (a `@formula.FormulaValue`) and the rule's
`formulas` evaluated to `FormulaValue`s, apply the §18.18.15 operator:

- `equal`, `notEqual`, `greaterThan`, `greaterThanOrEqual`, `lessThan`,
  `lessThanOrEqual` — single comparand against `formulas[0]`.
- `between`, `notBetween` — two comparands `formulas[0]` and
  `formulas[1]`, inclusive bounds (per Excel semantics).
- `containsText`, `notContains`, `beginsWith`, `endsWith` — string
  predicates against `formulas[0]` (or the rule's `text` attribute when
  no formula is present).

Number vs. string comparison shall follow §18.17 type coercion (numbers
sort below text; booleans treated by spec as ordinal).

### Requirement 3: text-predicate rule evaluation

For rule types `containsText`, `notContainsText`, `beginsWith`, and
`endsWith` (§18.18.12), the evaluator shall apply the case-insensitive
substring / prefix / suffix predicate from the rule's `text` attribute
to the cell's display string.

### Requirement 4: containsBlanks / notContainsBlanks / containsErrors
/ notContainsErrors / duplicateValues / uniqueValues

Per §18.18.12:

- `containsBlanks` / `notContainsBlanks` match cells whose
  `LEN(TRIM(value))` is 0 / non-0.
- `containsErrors` / `notContainsErrors` match cells whose
  `FormulaValue is VError(_)`.
- `duplicateValues` / `uniqueValues` require the full range population
  to be passed; the evaluator shall compute hits over a supplied
  `Array[FormulaValue]` and return per-cell booleans.

### Requirement 5: top10 rule evaluation

For `top10` rules (§18.18.12), the evaluator shall return the set of
cell indices that fall in the top (or bottom, when `bottom=true`) N
positions of the population. When `percent=true`, N is interpreted as a
percentage of the population (rounded down per Excel).

### Requirement 6: aboveAverage rule evaluation

For `aboveAverage` rules (§18.18.12), the evaluator shall compute the
arithmetic mean of the supplied population and return the cell indices
that satisfy:

- `aboveAverage=1, equalAverage=0` → `value > mean`
- `aboveAverage=0, equalAverage=0` → `value < mean`
- `aboveAverage=1, equalAverage=1` → `value >= mean`
- `aboveAverage=0, equalAverage=1` → `value <= mean`

When `stdDev` is present, the threshold shifts by `stdDev` population
standard deviations from the mean in the indicated direction.

### Requirement 7: timePeriod rule evaluation

For `timePeriod` rules (§18.18.82), the evaluator shall compare each
cell's serial-date value (decoded via `@date_serial`) against the
supplied "today" reference date and report a hit for any of the ten
dynamic windows: `today`, `yesterday`, `tomorrow`, `last7Days`,
`lastWeek`, `thisWeek`, `nextWeek`, `lastMonth`, `thisMonth`,
`nextMonth`.

### Requirement 8: expression rule evaluation

For `expression` rules (§18.18.12), the evaluator shall feed the rule's
`formulas[0]` text into the `@formula` evaluator with the supplied
`@formula.WorksheetContext` and treat any non-zero / non-empty / TRUE
result as a hit.

### Requirement 9: colorScale gradient mapping

For `colorScale` rules, the evaluator shall compute per-cell ARGB
colors by linearly interpolating between the supplied `CT_Cfvo`
thresholds (§18.3.1.11) and `CT_Color` entries (§18.3.1.15), using
percent / number / percentile / formula thresholds resolved against the
range population.

### Requirement 10: dataBar / iconSet bucket assignment

For `dataBar` and `iconSet` rules, the evaluator shall assign each cell
to a bucket index (0..k-1, where k is the number of cfvo thresholds)
suitable for the renderer to draw a bar length or pick an icon, per
§18.3.1.28 and §18.3.1.49.

### Requirement 11: Priority and stopIfTrue ordering

`evaluate_rules` shall accept a list of `CfRule`s, sort them ascending
by `priority` (lower number = higher precedence per §18.3.1.10), and
for each cell return the ordered list of matching `(rule, dxfId)`
entries. When `stop_if_true=true` and a rule matches, no
lower-precedence rule shall be reported for that cell.

### Requirement 12: sqref resolution

`evaluate_cf_block` shall accept a parsed `CT_ConditionalFormatting`
and the worksheet row/column population, resolve the `sqref` attribute
into `@address.CellRange`s, and evaluate the contained rules over the
intersected cells only.

## Non-functional requirements

- All public types live in `src/ecma376/spreadsheet_ml/cf_rule_eval/`
  and carry doc comments citing the specific §-section that defines
  each construct.
- `pub fn` bodies satisfy the indexion SHALLOW gate (>4 lines of
  non-trivial logic) so `spec align status --fail-on any` passes.
- White-box tests cover at least one positive and one negative case per
  rule type (cellIs comparison, text predicates, blanks/errors,
  duplicate/unique, top10 with percent flag, aboveAverage with stdDev,
  timePeriod windows, expression, colorScale interpolation, dataBar
  bucketing, priority ordering with stopIfTrue).

## Out of scope

- Wiring evaluator output into a renderer (handled later, depends on
  G17 effects + a dxf-to-style resolver).
- PivotTable conditional formatting (`pivot=true`) — flagged but no
  rule-level differences beyond range source, which is G8.
