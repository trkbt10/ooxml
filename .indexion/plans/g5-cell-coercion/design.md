# G5 Cell Coercion Design

## Package

Add `src/ecma376/spreadsheet_ml/cell_value/` as a self-contained SpreadsheetML semantic layer package. It depends only on SpreadsheetML domain types, serial date conversion, OPC errors, address, and XML traversal support.

## API

Expose `CellValue` as a public enum with variants for the seven `ST_CellType` values plus `Empty`.

Expose two decoders:

- `decode_cell_value(cell)` returns typed values and leaves shared strings as `SharedStringIndex`.
- `decode_cell_value_with_sst(cell, sst)` optionally resolves shared string indices to `InlineString` using `CT_Sst::lookup`.

Expose coercion methods:

- `CellValue::to_display_text` maps typed values to Excel-style default text.
- `CellValue::to_number` maps numeric-compatible values to `Double` and raises `SchemaViolation` for string and error values.

## Implementation Notes

The decoder walks the XML child nodes of `CT_Cell` directly, selecting `<v>` and `<is>` by local name. Inline strings reuse `CT_Rst::to_plain_text`; SST resolution reuses `CT_Sst::lookup`; date-to-number delegates to `date_time_to_serial`.

