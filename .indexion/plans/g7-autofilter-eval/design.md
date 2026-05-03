# G7 SpreadsheetML AutoFilter Evaluation Design

The new package is a self-contained SpreadsheetML §18.3.2 evaluator. Callers supply candidate row values already resolved as `@formula.FormulaValue`, so the evaluator does not read worksheets or shared strings directly.

`AutoFilter::from_element` maps the XML choice under each `filterColumn` into typed `FilterRule` values. Schema errors use `@opc_errors.SchemaViolation`; the source wrappers remain unchanged because they are generic DOM carriers.

`AutoFilter::row_visible` applies all non-contextual column rules as an intersection. `AutoFilter::filter_rows` handles the contextual rules that require the full candidate set: `Top10`, `AboveAverage`, and `BelowAverage`.

Dynamic date filters use a deterministic anchor for this implementation: `@date_serial.serial_to_date_time(0.0, date_system)` is treated as "today". Tests use values around that anchor, making behavior stable across machines and calendar dates.

Color and icon filters are intentionally conservative in this phase. Candidate rows carry values but no style records, dxf ids, or icon metadata, so `ColorFilter` and `IconFilter` evaluate to false rather than guessing from unavailable formatting data.
