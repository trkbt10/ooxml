# OOXML office-suite smoke validation

`scripts/ooxml_office_smoke.sh` is the repo-level smoke harness for real
OOXML package health. It exercises `.docx`, `.xlsx`, and `.pptx` files through:

1. `ooxml_cli verify` (`open -> save -> open`),
2. LibreOffice headless PDF export of the original package,
3. one format-appropriate edit through `ooxml_cli`,
4. `ooxml_cli verify` of the edited package,
5. LibreOffice headless PDF export of the edited package.

Default run:

```bash
scripts/ooxml_office_smoke.sh
```

Custom files:

```bash
scripts/ooxml_office_smoke.sh path/to/file.docx path/to/file.xlsx path/to/file.pptx
```

The default inputs are generated catalog fixtures under `.snapshots/fixtures/`.
If they are absent, generate them first:

```bash
moon run src/cmd/catalog -- fixtures
```

## What This Proves

- The package can be parsed, saved, and parsed again by this library.
- LibreOffice can open and export the original package.
- The CLI edit path can write a new OOXML package.
- LibreOffice can open and export the edited package.

## What This Does Not Prove

- It is not a full ECMA-376 schema validator.
- It does not prove every child sequence, cardinality, or relationship rule.
- It does not automate Microsoft Word, Excel, or PowerPoint.
- It does not prove visual fidelity; use `scripts/snapshot.sh` for the
  LibreOffice-vs-renderer visual comparison path.

Microsoft Office validation still needs a separate Word/Excel/PowerPoint
automation harness or a manual acceptance pass. Do not treat this smoke as a
Microsoft Office guarantee.
