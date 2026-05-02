# SoT Consolidation Plan

Goal: before adding builder/renderer/cli layers (modeled on web-pptx), consolidate
duplication and close OPC §6 / XML 1.0 gaps in the foundational SoT modules.

## Audit Findings (2026-05-02)

Quantified by 3 sub-agent audits + `indexion plan refactor --threshold=0.9`:

### XML — `src/xml/`
- `escape_text` / `escape_attribute` are `fn` (private). docx/pptx/xlsx each
  reimplemented `escape_text()` (3-entity subset, missing `&quot;` and `&apos;`).
  - `docx/docx.mbt:345`, `pptx/pptx.mbt:313`, `xlsx/xlsx.mbt:271`
- 5 viewer packages each reimplement `escape_html()` (3-entity HTML escape).
  - drawing_ml/, presentation_ml/, spreadsheet_ml/, wordprocessing_ml/, office_math/ viewer.mbt
- DSig algorithms hand-build XML strings instead of using `xml.write`:
  - `ecma376/opc/digital_signatures/algorithms.mbt:456-588` (RelationshipsTransform, C14N)
  - C14N requires extra escapes (`&#x9;` `&#xA;` `&#xD;`) that the canonical
    writer does not currently emit.
- No central namespace URI registry — 8 OPC URIs scattered across files.
- No XML 1.0 control-character validation in writer.

### Path — `src/ecma376/opc/`
- `resolve_target` + `normalize_part_name` are byte-for-byte identical in 4 files:
  - `ecma376/opc/package.mbt:262-287` (canonical)
  - `xlsx/xlsx.mbt:279-304`, `docx/docx.mbt:353-377`, `pptx/pptx.mbt:321-345`
- Helper `last_slash()` duplicated in same 4 files.
- `PartName` struct duplicated:
  - `ecma376/opc/part/domain.mbt:16-35`
  - `ecma376/opc/content_types/domain.mbt:68-87`
- ECMA-376 Part 2 §6.2.2 PartName grammar gaps:
  - **No percent-encoding validation** (must reject malformed `%XX`, must reject
    percent-encoded reserved chars per RFC 3987 iunreserved).
  - **No segment-end-`.` check** (`/foo./` is forbidden).
  - **No RFC 3987 isegment-nz character class enforcement.**
  - **No reserved part name check** (`/_rels/.rels`, `*.rels` per §6.2.3 / §6.5.2).
- Pack URI (§9.1.2): `pack_uri.mbt` parses `pack://authority/part` but does not
  validate authority encoding (must be percent-encoded part name per §9.1.2.1).

### fs/zip — `src/zip/`, `src/ecma376/opc/`
- Single canonical `Archive`/`Entry`/`Package` types — no dups.
- BUT: `Package::with_part` / `with_optional_part` extension methods live in
  format facades (`docx/docx.mbt:312-325`, replicated in pptx/xlsx) instead of
  on `@opc.Package` itself. 79 lines × 3 = 237 lines of straight copy.
- ZIP writer only emits `Stored` entries (no Deflate). Real .docx/.xlsx/.pptx
  files use Deflate; current writer produces non-conformant (but readable) packages.
- ZIP reader rejects ZIP64 and data descriptors. Large pptx/xlsx files in the
  wild often have data descriptors (created by streaming writers).
- `read_optional` (134-line block) and the `OpenError` catch arm (47-line
  block) are duplicated across docx/pptx/xlsx facades.

### errors.mbt — `src/ecma376/opc/`
- `SchemaViolation` + `UnsupportedFeature` + `require_supported_feature` are
  **100% byte-identical** in 5 files:
  - `ecma376/opc/errors.mbt`
  - `ecma376/opc/content_types/errors.mbt`
  - `ecma376/opc/digital_signatures/errors.mbt`
  - `ecma376/opc/part/errors.mbt`
  - `ecma376/opc/relationships/errors.mbt`
- Each subpackage owns its own `SchemaViolation` so callers must catch a
  different type per subpackage. Should be one type re-exported.

## Target SoT Modules

### A. `src/xml/` (XML SoT — extend, don't replace)

1. Promote `escape_text` and `escape_attribute` from `fn` to `pub fn`.
2. Add `pub fn escape_attribute_c14n(value)` that additionally escapes
   `\t`→`&#x9;`, `\n`→`&#xA;`, `\r`→`&#xD;` per W3C C14N §2.3.
3. Add `pub fn escape_text_c14n(value)` that additionally escapes
   `\r`→`&#xD;` and `>`→`&gt;` per W3C C14N §2.3.
4. Add `pub fn write_c14n(doc) -> Bytes` mode (canonical XML 1.0) that
   sorts attributes lexicographically and uses C14N escapes.
5. Add `pub fn validate_xml_char(ch) -> Bool` per XML 1.0 §2.2 Char production.
   Writer rejects non-Char codepoints.
6. Replace 3 `escape_text` copies in pptx/docx/xlsx with `@xml.escape_text`.
7. Replace DSig `write_relationships_transform_entries` and
   `write_canonical_element` with calls into the new c14n writer.
8. Viewer `escape_html` is a different concept (HTML5 escape, not XML) — leave
   alone, but consolidate the 5 copies into a single `src/html/escape.mbt` SoT.

### B. `src/ecma376/opc/namespaces.mbt` (new — Namespace Registry SoT)

Single module exporting all OPC + DSig + ECMA-376 namespace URI constants
as `pub fn ns_xxx() -> String`. All 8 inline declarations replaced.

### C. `src/ecma376/opc/part_name.mbt` (Path SoT — promote and validate)

1. Move `PartName` to `src/ecma376/opc/part_name.mbt` as the **single** type.
   Re-export from `opc/part/` and `opc/content_types/` to avoid breaking imports.
2. Move `resolve_target` + `normalize_part_name` + `last_slash` into this
   module as `pub fn`. Delete from `package.mbt` and the 3 facades.
3. Implement §6.2.2 grammar validation completely:
   - Percent-encoding: `%` must be followed by 2 hex; reject percent-encoded
     unreserved chars (per RFC 3987 §2.2 iunreserved).
   - Segment-end-`.`: each `isegment-nz` must not end with `.`.
   - Character class: `isegment-nz` allows `iunreserved / pct-encoded /
     sub-delims / ":" / "@"`.
   - Reserved part names: `[Content_Types].xml`, `*.rels`, `_rels/*` paths
     must follow §6.2.3 / §6.5.2.2 / §6.5.2.3 rules.
4. ZIP-name conversion: keep `zip_name_from_part_name` (strip leading `/`)
   in this module; this is the only place that bridges PartName↔Zip.

### D. `src/ecma376/opc/package.mbt` (Package mutator API — pull up from facades)

Move the duplicated 79-line `with_part` and 30-line `required_part` from
docx/pptx/xlsx into `Package` methods:
- `pub fn Package::with_part(self, name, content_type, data) -> Package`
- `pub fn Package::with_optional_part(self, name, content_type?, data?) -> Package`
- `pub fn Package::required_part(self, name, section, source_path) -> PackagePart raise ResourceMissing`
- Generic `pub fn[T] Package::read_optional(self, name, parser) -> T?` 
  (consolidates the 134-line read_optional duplicated docx↔xlsx).

### E. `src/ecma376/opc/errors.mbt` (Errors SoT — collapse 5 copies)

Keep `SchemaViolation` + `UnsupportedFeature` + `require_supported_feature`
in `src/ecma376/opc/errors.mbt` as the only source. Delete the same
declarations from content_types/, digital_signatures/, part/, relationships/
and re-export the canonical types via each subpackage's `pub typealias` so
existing call-sites continue to compile.

### F. `src/zip/writer.mbt` (Deflate + ZIP64)

1. Implement Deflate compression (RFC 1951) for entries marked
   `CompressionMethod::Deflate`. Required for spec-conformant .docx/.xlsx/.pptx.
2. Accept ZIP64 entries on read (file size ≥ 4 GiB or entry count ≥ 65535).
3. Accept data descriptors on read (bit 3 of GP flag).
4. Writer-side ZIP64 only when needed (small files stay zip32 for compat).

## SDD Plan (per indexion-sdd protocol)

Each SoT module gets its own `.kiro/specs/sot-<name>/` directory with
requirements.md / design.md / tasks.md / spec.json. Codex implements
phases A (types) then B (logic) per indexion-sdd, with drift gate after each.

Phase order (sequential — each unblocks the next):

1. **sot-errors** — collapse 5 errors.mbt copies (smallest, validates pattern).
2. **sot-namespaces** — central namespace URI registry.
3. **sot-xml-escape** — promote escape_text/escape_attribute, add c14n variants,
   delete docx/pptx/xlsx copies.
4. **sot-part-name** — single PartName type with §6.2.2 validation.
5. **sot-path-resolve** — single resolve_target/normalize_part_name; delete
   3 facade copies.
6. **sot-package-mutator** — pull with_part/required_part/read_optional up to
   `Package` methods; delete 3 facade copies.
7. **sot-zip-deflate** — Deflate writer + ZIP64 reader.

Each phase ends with `drift.sh PASS` AND `moon test --target native/wasm-gc/wasm/js`
all green. No phase advances if drift > 0.

## Non-goals for this SoT pass

- Builder DSL (web-pptx aurochs-builder pattern) — comes after SoT is solid.
- Renderer (SVG output) — comes after builder.
- CLI dispatch (commander-style subcommands) — comes after builder.
- Restoring `cmd/{docx,pptx,xlsx}_wasm` and `cmd/ooxml_cli` — comes with builder/cli.
