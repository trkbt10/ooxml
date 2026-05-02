# G1.2 SpreadsheetML Formula Parser Tasks

- [x] Read §18.17.2 syntax, constants, operators, functions, references, and
  array constant rules.
- [x] Inspect G1.1 tokenizer public API and token shapes.
- [x] Add typed formula AST enums.
- [x] Implement recursive-descent parser and `parse_formula`.
- [x] Disambiguate comma as union versus function/array separator.
- [x] Enforce §18.17.2.1 array constant restrictions.
- [x] Add white-box parser tests for AST shape, precedence, and errors.
- [x] Run native check/test and strict SpreadsheetML drift gate.
- [x] Run `moon test` on native, wasm-gc, wasm, and js.
- [x] Run final strict drift gate.
- [x] Commit completed G1.2 implementation.
