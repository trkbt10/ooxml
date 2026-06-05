#!/usr/bin/env python3
"""Regression tests for ooxml_fixture_element_coverage.py."""

from __future__ import annotations

import importlib.util
import json
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path


SCRIPT = Path(__file__).with_name("ooxml_fixture_element_coverage.py")
SPEC = importlib.util.spec_from_file_location("fixture_coverage", SCRIPT)
assert SPEC is not None
fixture_coverage = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = fixture_coverage
SPEC.loader.exec_module(fixture_coverage)


WML_TRANSITIONAL = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
WML_STRICT = "http://purl.oclc.org/ooxml/wordprocessingml/main"
SML_TRANSITIONAL = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"


def write_catalog(path: Path) -> None:
    path.write_text(
        json.dumps(
            {
                "entries": [
                    {
                        "id": "document",
                        "element": "document",
                        "type": "CT_Document",
                        "namespace": WML_STRICT,
                        "format": "docx",
                        "lineage": ["strict"],
                    },
                    {
                        "id": "p",
                        "element": "p",
                        "type": "CT_P",
                        "namespace": WML_TRANSITIONAL,
                        "format": "docx",
                        "lineage": ["transitional"],
                    },
                    {
                        "id": "worksheet",
                        "element": "worksheet",
                        "type": "CT_Worksheet",
                        "namespace": SML_TRANSITIONAL,
                        "format": "xlsx",
                        "lineage": ["transitional"],
                    },
                ]
            }
        ),
        encoding="utf-8",
    )


def write_docx(path: Path) -> None:
    document = f"""<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="{WML_TRANSITIONAL}">
  <w:body>
    <w:p/>
  </w:body>
</w:document>
"""
    with zipfile.ZipFile(path, "w") as archive:
        archive.writestr("word/document.xml", document)


class FixtureElementCoverageTest(unittest.TestCase):
    def test_fixture_qname_coverage_normalises_strict_and_transitional_namespaces(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            root = Path(tempdir)
            catalog = root / "catalog.json"
            package = root / "sample.docx"
            write_catalog(catalog)
            write_docx(package)

            result = fixture_coverage.audit(catalog, [package])

        self.assertEqual(3, result["declared_qnames"])
        self.assertEqual(2, result["covered_qnames"])
        self.assertEqual(1, result["missing_qnames"])
        missing = {(item["namespace"], item["element"]) for item in result["missing"]}
        self.assertEqual(
            {("ooxml:spreadsheetml/main", "worksheet")},
            missing,
        )


if __name__ == "__main__":
    unittest.main()
