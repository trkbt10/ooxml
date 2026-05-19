# G6 — tasks

1. Create `src/ecma376/spreadsheet_ml/cf_rule_eval/` with `moon.pkg`
   importing `@xml`, `@opc_errors`, `@domain`, `@address`,
   `@cell_value`, `@date_serial`, `@formula`.
2. `types.mbt` — `CfType`, `CfOperator`, `TimePeriod`, `CfvoType`,
   `CfRule`, `CfColorScale`, `CfDataBar`, `CfIconSet`, `CfvoThreshold`,
   `CfArgb`, `CfHit`, `CfBlock`, `EvalContext` + non-trivial
   `from_attr` methods (>4 lines each) on the enums and the
   `CfRule::matches_*` wrappers — satisfies SHALLOW gate.
3. `predicates.mbt` — `compare(FormulaValue, CfOperator, FormulaValue)`,
   `text_predicate`, `is_blank`, `is_error`, `to_number_opt`,
   `to_string_display`.
4. `population_stats.mbt` — `mean`, `population_std_dev`,
   `top_n_threshold`, `percentile`, `count_duplicates`.
5. `decode.mbt` — `decode_cf_rule(@domain.CT_CfRule)`,
   `decode_cf_block(@domain.CT_ConditionalFormatting)`,
   `decode_cfvo`, `decode_color_scale`, `decode_data_bar`,
   `decode_icon_set`. All raise `@opc_errors.SchemaViolation` on
   malformed attribute / missing child.
6. `color_scale.mbt` — `evaluate_color_scale`, `resolve_cfvo_value`,
   `interp_argb`.
7. `evaluator.mbt` — `evaluate_rule`, `evaluate_bucket`,
   `evaluate_cf_block`. Priority sort + `stopIfTrue` short-circuit.
8. `evaluator_wbtest.mbt` — one test block per rule type plus the
   priority/stopIfTrue case and the color-scale interpolation case.
9. Run `moon fmt && moon info && moon check --target native &&
   moon test`. Inspect generated `pkg.generated.mbti` for the new
   surface. Commit as `g6-cf-rule-eval: §18.3.1.10/§18.3.1.18 CT_CfRule
   evaluator`.
10. Run `.kiro/scripts/drift.sh --pkg ecma376/spreadsheet_ml --strict`
    (or the closest scoped invocation it supports). The package vocab
    around `cfRule`, `conditionalFormatting`, `colorScale`, `dataBar`,
    `iconSet`, `top10`, `aboveAverage`, `timePeriod` must move from
    SPEC_ONLY/SHALLOW to MATCHED.
