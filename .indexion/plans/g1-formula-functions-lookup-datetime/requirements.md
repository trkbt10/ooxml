# G1.7 Formula Functions: Lookup, Reference, Datetime

## Requirements

- Implement the ECMA-376 Part 1 §18.17.7 lookup, reference, and datetime function families in `src/ecma376/spreadsheet_ml/formula/`.
- Use existing formula values, evaluation context, cell resolution, and workbook date system semantics.
- Use `@address` for A1/R1C1 parsing and address formatting work.
- Use `@date_serial` for serial date-time conversion under `EvalContext.date_system`.
- Register the new built-ins from `register_builtin_functions`.
- Keep implementation package-local and do not modify `.kiro/specs/ecma376/`.
- Add white-box coverage for exact and approximate lookup behavior, reference helpers, and date/time serial conversions.
- Preserve deterministic `NOW()` and `TODAY()` behavior for reproducible tests.

## Non-goals

- Financial and statistical functions are out of scope for this phase.
- Full locale-specific date parsing is out of scope; ISO `YYYY-MM-DD` date text is required.
