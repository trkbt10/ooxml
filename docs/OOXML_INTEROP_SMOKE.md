# OOXML office-suite smoke validation

`scripts/ooxml_office_smoke.sh` is the repo-level LibreOffice smoke harness for
real OOXML package health. It exercises `.docx`, `.xlsx`, and `.pptx` files
through:

1. `ooxml_cli verify` (`open -> save -> open`),
2. LibreOffice headless PDF export of the original package,
3. one format-appropriate edit through `ooxml_cli`,
4. `ooxml_cli verify` of the edited package,
5. LibreOffice headless PDF export of the edited package.

Default run:

```bash
scripts/ooxml_office_smoke.sh
```

Microsoft Office smoke:

```bash
scripts/ooxml_mso_smoke.sh
```

Custom files:

```bash
scripts/ooxml_office_smoke.sh path/to/file.docx path/to/file.xlsx path/to/file.pptx
scripts/ooxml_mso_smoke.sh path/to/file.docx path/to/file.xlsx path/to/file.pptx
```

Generated fixture categories:

```bash
scripts/ooxml_office_smoke.sh --fixture-category docx/drawing
scripts/ooxml_office_smoke.sh --fixture-category xlsx/cf --fixture-category pptx/diagram

scripts/ooxml_mso_smoke.sh --fixture-category docx/drawing
scripts/ooxml_mso_smoke.sh --fixture-category xlsx/cf --fixture-category pptx/diagram
```

All generated fixtures:

```bash
scripts/ooxml_office_smoke.sh --all-fixtures
scripts/ooxml_mso_smoke.sh --all-fixtures
```

The default inputs are generated catalog fixtures under `.snapshots/fixtures/`.
If they are absent, generate them first:

```bash
moon run src/cmd/catalog -- fixtures
```

Recent interop evidence:

| Date | Scope | Result |
|---|---|---|
| 2026-06-05 | LibreOffice default representative fixtures | `ok (3 file(s))` |
| 2026-06-05 | Microsoft Office default representative fixtures | `ok (3 file(s))` |
| 2026-06-05 | LibreOffice `docx/table`, `xlsx/{pivot,table,sparkline,external}`, `pptx/{chart,transition,master-layout,media}` selected categories | `ok (99 file(s))` |
| 2026-06-05 | Microsoft Office `docx/table`, `xlsx/{pivot,external}`, `pptx/{chart/bar,master-layout}` selected categories | `ok (61 file(s))` |
| 2026-06-04 | LibreOffice `docx/drawing`, `xlsx/cf`, `pptx/diagram` categories | `ok (59 file(s))` |

The 2026-06-05 selected-category runs cover table layout, pivot caches, table
parts, sparkline extension payloads, external workbook links, PresentationML
chart parts, transitions, slide master/layout relationships, and media
relationships. The 2026-06-04 category run covers the ECMA Transitional VML
drawing fixtures, SpreadsheetML conditional-formatting/dataBar fixtures, and
PresentationML diagram fixtures that were changed for XSD cleanliness. Each
LibreOffice-selected file passed internal `ooxml_cli verify`, LibreOffice PDF
export of the original package, a format-appropriate CLI edit, verification of
the edited package, and LibreOffice PDF export of the edited package. Each
Microsoft Office-selected file passed internal verify, matching Office-app
open/close of the original package, the format-appropriate CLI edit,
verification of the edited package, and matching Office-app open/close of the
edited package.

## What This Proves

- The package can be parsed, saved, and parsed again by this library.
- LibreOffice can open and export the original package.
- The CLI edit path can write a new OOXML package.
- LibreOffice can open and export the edited package.
- Microsoft Word, Excel, and PowerPoint can open and close temporary copies of
  the matching original and edited packages when `scripts/ooxml_mso_smoke.sh`
  is run on a machine with those apps installed.

## What This Does Not Prove

- It is not a full ECMA-376 schema validator.
- It does not prove every child sequence, cardinality, or relationship rule.
- Microsoft Office open/close is not a substitute for UI-level acceptance,
  repair-dialog detection, or visual comparison.
- It does not prove visual fidelity; use `scripts/snapshot.sh` for the
  LibreOffice-vs-renderer visual comparison path.

Do not treat either smoke as a schema conformance guarantee. They are
application-open gates that catch broken packages earlier than renderer-only or
library-only tests.
