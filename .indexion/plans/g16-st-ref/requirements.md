# G16 ST_Ref Requirements

- Implement SpreadsheetML §18.18.7 ST_CellRef parsing for A1 and R1C1 syntax.
- Implement §18.18.62 ST_Ref parsing and normalization for cell, whole-row, and whole-column ranges.
- Implement §18.18.63 ST_RefA coverage through absolute-marker support on single-cell A1 references.
- Implement §18.18.64 RefMode public enum for A1 and R1C1.
- Implement §18.18.76 ST_Sqref parsing as ASCII-space-delimited ST_Ref values.
- Enforce Excel 2007+ worksheet limits: columns A..XFD and rows 1..1048576.
- Preserve sheet qualifiers, including single-quoted names and doubled single-quote escaping.
- Raise `@opc_errors.SchemaViolation` for malformed references.
