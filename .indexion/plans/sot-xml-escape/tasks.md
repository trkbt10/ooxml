# XML Escape SoT Tasks

- [x] Run baseline `indexion --version`.
- [x] Run baseline drift gate.
- [x] Run baseline `moon test --target native`.
- [x] Promote `escape_text` and `escape_attribute` in `src/xml/writer.mbt`.
- [x] Add C14N escape variants in `src/xml/writer.mbt`.
- [x] Add XML 1.0 char validation in `src/xml/writer.mbt`.
- [x] Migrate `src/docx/docx.mbt` to `@xml.escape_text`.
- [x] Migrate `src/pptx/pptx.mbt` to `@xml.escape_text`.
- [x] Migrate `src/xlsx/xlsx.mbt` to `@xml.escape_text`.
- [x] Migrate OPC digital signature canonicalization to XML C14N escapers.
- [x] Run native check/test gates.
- [x] Run `moon info && moon fmt`.
- [x] Run all four backend tests.
- [x] Run final drift gate.
- [x] Run final duplicate plan refactor check.
- [x] Commit the completed change.
