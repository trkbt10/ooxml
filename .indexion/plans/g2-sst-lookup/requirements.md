# G2 SST Lookup Requirements

## Goal

Add semantic read-only lookup APIs to SpreadsheetML shared string domain types so callers can resolve a zero-based Shared String Table index to the plain text value displayed by a cell.

## Functional Requirements

- `CT_Sst::entries` returns `CT_Rst` entries for direct `<si>` children of `<sst>` in document order.
- `CT_Sst::lookup` returns `Some(text)` for an in-range zero-based index and `None` for out-of-range indexes.
- `CT_Sst::count` returns the number of direct `<si>` entries.
- `CT_Rst::to_plain_text` returns the display text for one rich text string by concatenating direct `<t>` text and direct `<r>` run text in document order.
- `CT_RElt::to_plain_text` returns text from the run's direct `<t>` child or children and ignores formatting markup.
- `<rPh>` phonetic runs and `<phoneticPr>` properties are ignored for display text.
- Whitespace in `<t>` is preserved, including `xml:space="preserve"` content and default text content.

## Constraints

- Keep implementation inside `src/ecma376/spreadsheet_ml/domain/`.
- Do not modify `.kiro/specs/ecma376/`.
- Do not create a new package.
- Public API doc comments must cite ECMA-376 Part 1 §18.4.
- Validate with drift gates and `moon test` across native, wasm-gc, wasm, and js.
