# G2 SST Lookup Design

## Scope

The existing `CT_Sst`, `CT_Rst`, and `CT_RElt` types are thin wrappers over `@xml.Element`. The lookup API stays co-located in `shared_string_types.mbt` and traverses the wrapped XML directly.

## Traversal

- Match SpreadsheetML children by local name so documents with or without resolved namespace bindings are handled.
- Traverse only the direct children relevant to the OOXML shape:
  - `CT_Sst` scans direct `<si>` children.
  - `CT_Rst` scans direct `<t>` and `<r>` children.
  - `CT_RElt` scans direct `<t>` children.
- Ignore foreign children, whitespace text nodes between elements, `<rPr>`, `<rPh>`, and `<phoneticPr>`.

## Text Semantics

The plain text value is built by concatenating `@xml.Node::Text` and `@xml.Node::CData` children of `<t>` elements. No trimming or whitespace normalization is applied because Shared String Table text is significant for cell display values.

## Tests

White-box tests construct SpreadsheetML DOM fragments and wrap roots in the domain types. Cases cover empty SSTs, plain strings, rich runs, mixed entries, preserved whitespace, and phonetic markup exclusion.
