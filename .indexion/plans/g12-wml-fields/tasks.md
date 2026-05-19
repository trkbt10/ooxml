# G12 — tasks

1. `src/ecma376/wordprocessing_ml/field_eval/moon.pkg` — import
   `@hashmap`, `@xml`, `@opc_errors`, `@domain`, `@date_serial`,
   `@numbering_resolver`; wbtest imports `@utf8`.
2. `types.mbt` — FieldInstruction (45 + variants), FieldSwitch,
   FieldFormat, Field, FieldContext, FieldResult, BookmarkValue,
   FieldRegistry + non-trivial methods on each (>4 lines).
3. `tokenizer.mbt` — tokenize_instruction.
4. `parser.mbt` — parse_instruction + FieldInstruction::from_name.
5. `decode.mbt` — decode_simple_field, decode_field_run_sequence.
6. `format_date_time.mbt` — §17.16.4.1 format-code engine.
7. `format_general.mbt` — §17.16.4.3 general switch + casing.
8. `builtins.mbt` — 20 evaluators (PAGE, NUMPAGES, DATE, TIME,
   AUTHOR, …).
9. `evaluator.mbt` — evaluate_field driver +
   FieldRegistry::with_builtins.
10. `evaluator_wbtest.mbt` — ≥10 test blocks per design plan.
11. `moon fmt && moon info && moon check --target native && moon test`.
12. `.kiro/scripts/drift.sh --pkg ecma376/wordprocessing_ml`.
13. Commit as `g12-wml-fields: §17.16 field code parser & evaluator`.
