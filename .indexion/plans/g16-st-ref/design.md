# G16 ST_Ref Design

The implementation lives in `src/ecma376/spreadsheet_ml/address/` as a self-contained SpreadsheetML subpackage.

Public types model normalized zero-based coordinates while retaining absolute-marker flags and an optional sheet qualifier. A1 parsing is split into sheet/body parsing and endpoint parsing so the same endpoint parser can serve `ST_CellRef` and `ST_Ref`.

Ranges normalize reversed endpoints by swapping coordinates and their corresponding absolute flags. Whole-row ranges omit column bounds, and whole-column ranges omit row bounds.

R1C1 parsing stores unbracketed axes as absolute zero-based coordinates. Bracketed or omitted axes are represented as relative offsets with the corresponding absolute flag set to `false`, matching the requested public fields without adding private state.
