# G3 SpreadsheetML Date Serial Requirements

## Scope

Implement ECMA-376 Part 1 §18.17.4.1 serial date-time conversion for
SpreadsheetML, selected by the §18.2 `CT_WorkbookPr/@date1904` workbook
property.

## Requirements

- Provide a self-contained `src/ecma376/spreadsheet_ml/date_serial` package.
- Support both date systems:
  - 1900: base `1899-12-30T00:00:00`, serial range
    `-693593..=2958465.9999884`.
  - 1904: base `1904-01-01T00:00:00`, serial range
    `-695055..=2957003.9999884`.
- Store time-of-day as fractional days.
- Use proleptic Gregorian date arithmetic for valid calendar dates.
- Preserve the 1900-system Lotus 1-2-3 compatibility quirk:
  `1900-02-29T00:00:00` maps to serial `60`, and serial `60` maps back to
  that phantom date.
- Reject invalid dates, invalid times, and out-of-range serials with
  `@opc_errors.SchemaViolation`.
- Keep layering isolated to `@opc_errors` only.

## Verification

- Add white-box tests for spec examples, bounds, invalid cases, and modern
  round trips.
- Run `moon test` on native, wasm-gc, wasm, and js.
- Run strict drift gates.
