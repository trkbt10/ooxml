# G6 — Design

New package: `src/ecma376/spreadsheet_ml/cf_rule_eval/`.

## File layout

```
cf_rule_eval/
  moon.pkg                 -- depends on @xml, @opc_errors, @domain,
                              @address, @cell_value, @date_serial,
                              @formula
  types.mbt                -- typed enums + structs (CfType, CfOperator,
                              TimePeriod, CfRule, CfColorScale,
                              CfDataBar, CfIconSet, CfHit, ...)
  decode.mbt               -- decode_cf_rule + decode_cf_block +
                              decode_cfvo + decode_color_scale + ...
                              all raise SchemaViolation on malformed
                              attributes.
  evaluator.mbt            -- evaluate_rule (one rule, one cell),
                              evaluate_range (one rule, population),
                              evaluate_cf_block (rules + range +
                              priority/stopIfTrue ordering)
  color_scale.mbt          -- linear interpolation between cfvo
                              thresholds + colors (color → ARGB Double*3
                              + alpha).
  predicates.mbt           -- shared helpers: compare(FormulaValue,
                              op, FormulaValue), text predicates
                              (case-insensitive substring/prefix/suffix),
                              blank detection (LEN(TRIM(...))).
  population_stats.mbt     -- mean / population_std_dev / top_n /
                              percentile helpers used by aboveAverage,
                              top10, and cfvo "percentile" thresholds.
  evaluator_wbtest.mbt     -- white-box tests (≥1 positive + ≥1 negative
                              per rule type).
```

The file split mirrors `autofilter/`: a single `_wbtest.mbt` consolidates
the white-box tests so the package keeps a slim public surface.

SHALLOW resolution: each `types.mbt` enum / struct file shall include
non-trivial methods (>4 lines) so the indexion gate sees logic in the
same file as the type. Specifically:

- `CfType::from_attr(String) -> CfType raise SchemaViolation` (16-arm
  match) lives in `types.mbt`.
- `CfOperator::from_attr` (12-arm), `TimePeriod::from_attr` (10-arm),
  `CfvoType::from_attr` (6-arm) all live in `types.mbt`.
- `CfRule::matches_text` and `CfRule::matches_cellis` thin wrappers
  delegating to `predicates.mbt` are added so `CfRule` has methods in
  its own file.

## Cross-package contracts

- Cell values arrive as `@formula.FormulaValue` (already shared with
  autofilter). The evaluator does not parse `<c>` itself; the caller
  decodes via `@cell_value.decode_cell_value_with_sst` and lifts the
  result via the existing helper in `@formula` (added in G7).
- `<formula>` text is parsed and evaluated through the existing
  `@formula` pipeline (`tokenize` → `parse` → `evaluate`) with the
  cell's `(row, col)` injected as the implicit reference, so `cellIs`
  rules can use relative refs that resolve against the current cell.
- Dates use `@date_serial.CalendarDateTime` for the `timePeriod`
  semantics; the "today" anchor is supplied by the caller so tests are
  deterministic.

## CfRule struct

```
pub(all) struct CfRule {
  cf_type : CfType
  dxf_id : Int?
  priority : Int
  stop_if_true : Bool
  operator : CfOperator?
  text : String?
  time_period : TimePeriod?
  rank : Int?
  bottom : Bool
  percent : Bool
  above_average : Bool
  equal_average : Bool
  std_dev : Int?
  formulas : Array[String]
  color_scale : CfColorScale?
  data_bar : CfDataBar?
  icon_set : CfIconSet?
}
```

## Evaluator API

```
pub fn evaluate_rule(
  rule : CfRule,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
  context : EvalContext,
) -> Bool raise @opc_errors.SchemaViolation

pub fn evaluate_color_scale(
  scale : CfColorScale,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> CfArgb?

pub fn evaluate_bucket(
  thresholds : Array[CfvoThreshold],
  reverse : Bool,
  cell : @formula.FormulaValue,
  population : Array[@formula.FormulaValue],
) -> Int?

pub fn evaluate_cf_block(
  block : CfBlock,
  cells : Array[(@address.CellAddress, @formula.FormulaValue)],
  context : EvalContext,
) -> Array[CfHit] raise @opc_errors.SchemaViolation
```

`CfBlock` carries the decoded `sqref` ranges + the rule list (already
sorted ascending by priority). `EvalContext` carries the "today" date,
the `WorksheetEvaluator` for `expression` rules, and the SST when text
predicates need to resolve `SharedStringIndex`. `CfHit` is one entry
per (cell, matched rule) for the renderer.

## stopIfTrue ordering

`evaluate_cf_block` iterates each cell over the priority-sorted rules.
On the first match where `stop_if_true=true` the iteration short-circuits
for that cell. Earlier (lower-priority-number) matches are always
recorded; later ones are appended unless suppressed.

## Population statistics

`population_stats.mbt` exposes:

- `mean(Array[Double]) -> Double` (returns 0.0 on empty so callers can
  treat it as "no hit"; real callers gate on `population.length() > 0`).
- `population_std_dev(Array[Double], Double mean) -> Double` (uses the
  population formula `sqrt(sum((x - mean)^2) / n)`, per Excel's
  aboveAverage interpretation).
- `top_n_threshold(Array[Double], Int n, bottom : Bool) -> Double?`
  (sorts descending or ascending and returns the n-th element as the
  inclusive threshold).
- `percentile(Array[Double], Double p) -> Double` (linear interpolation
  per the NIST / Excel `PERCENTILE.INC` definition; used by cfvo
  `percentile`).

These helpers avoid pulling in the formula function library for what is
essentially direct computation.

## Test strategy (evaluator_wbtest.mbt)

- One block per rule type. Each block builds a tiny `CfBlock` literal,
  feeds a fixed population, and asserts the matched cell indices /
  resulting bucket / interpolated color.
- Priority + stopIfTrue: two rules covering overlapping cells with
  priorities 1 and 2; verify the priority-2 rule is suppressed when
  priority-1's `stop_if_true=true`.
- `expression`: parses `"A1>5"` via `@formula` and validates the
  WorksheetContext wiring.
- Color scale: 3-stop (`min`, `percentile=50`, `max`) over a 5-value
  population produces the expected mid-point ARGB.

## Risks

- `expression` rules need the `@formula.WorksheetEvaluator`, but the
  evaluator currently expects a worksheet snapshot. The cf evaluator
  threads the snapshot through `EvalContext`, so tests instantiate a
  3-cell sheet for that branch only.
- `top10` with `percent=true` needs `Truncate(n * count / 100)`, never
  rounded. Tests pin this against the Excel rounding direction.
- `colorScale` accepts `formula`-typed cfvos; for v1 the evaluator
  treats those as numeric literals via `Double::from_string`. A TODO
  comment cites §18.3.1.11 to allow a future upgrade to full formula
  evaluation; this is acceptable per the audit's per-tier scope.
