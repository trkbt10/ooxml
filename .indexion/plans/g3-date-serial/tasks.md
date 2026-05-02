# G3 SpreadsheetML Date Serial Tasks

- [x] Read §18.17.4 and §18.17.4.1 date/time serial requirements.
- [x] Read §18.2 `CT_WorkbookPr/@date1904` selector requirements.
- [x] Add isolated `date_serial` package importing only `@opc_errors`.
- [x] Implement public date-system, calendar date-time, validation, and
  bidirectional conversion APIs.
- [x] Preserve serial `60` phantom `1900-02-29` in the 1900 system.
- [x] Add spec example, bounds, invalid case, and round-trip tests.
- [x] Run native check/test and package drift gate.
- [x] Run final four-backend test gate.
- [x] Run final strict drift gate.
- [ ] Commit implementation.
