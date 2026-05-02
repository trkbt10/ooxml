# G1.3 SpreadsheetML Formula Evaluator Tasks

- [x] Run baseline native tests and package drift gate.
- [x] Inspect formula AST/parser, address parsing, date serial, cell values,
  shared string domain types, and hashmap API.
- [x] Add SDD requirements/design/tasks under `.indexion/plans`.
- [x] Add formula error and value public types.
- [x] Add evaluator context and function registry skeleton.
- [x] Add scalar coercion helpers.
- [x] Add tree-walking evaluator and reference/range helpers.
- [x] Add white-box evaluator tests for operators, coercion, references, and
  registry dispatch.
- [x] Run native check/test and strict SpreadsheetML drift gate.
- [x] Run `moon info && moon fmt` and inspect generated interface diffs.
- [x] Run `moon test` on native, wasm-gc, wasm, and js.
- [x] Run final strict drift gate.
- [x] Commit completed G1.3 implementation.
