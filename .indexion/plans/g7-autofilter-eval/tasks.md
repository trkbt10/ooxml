# G7 SpreadsheetML AutoFilter Evaluation Tasks

1. Recon existing SpreadsheetML wrapper, address, date serial, cell value, formula, XML, and test idioms.
2. Add `autofilter` package with public §18.3.2 typed rules and evaluator APIs.
3. Add white-box tests covering literal, blank, date group, custom operators, wildcard matching, dynamic filters, Top10, multi-column intersections, XML parsing, and sorted row indices.
4. Run per-task gates: native check/test and package drift.
5. Run final gates on native, wasm-gc, wasm, js and strict drift.
6. Commit as `g7-autofilter-eval: §18.3.2 row visibility for filter rules`.
