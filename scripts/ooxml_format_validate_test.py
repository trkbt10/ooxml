#!/usr/bin/env python3
"""Regression tests for scripts/ooxml_format_validate.py."""

from __future__ import annotations

import tempfile
import unittest
import zipfile
from pathlib import Path

import ooxml_format_validate as format_validate


REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
OD_REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
WML_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"


def write_docx_with_case_mixed_content_types(package: Path) -> None:
    content_types = f"""<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="{format_validate.CONTENT_TYPES_NS}">
  <Default Extension="RELS" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Override PartName="/WORD/DOCUMENT.XML" ContentType="APPLICATION/VND.OPENXMLFORMATS-OFFICEDOCUMENT.WORDPROCESSINGML.DOCUMENT.MAIN+XML"/>
</Types>
"""
    relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rId1" Type="{OD_REL_NS}/officeDocument" Target="word/document.xml"/>
</Relationships>
"""
    document = f"""<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="{WML_NS}">
  <w:body><w:p/><w:sectPr/></w:body>
</w:document>
"""
    with zipfile.ZipFile(package, "w") as archive:
        archive.writestr(format_validate.CONTENT_TYPES_PART, content_types)
        archive.writestr(format_validate.PACKAGE_RELS_PART, relationships)
        archive.writestr("word/document.xml", document)


class FormatValidatorRegressionTest(unittest.TestCase):
    def test_content_types_mapping_uses_ascii_case_insensitive_opc_rules(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            package = Path(tempdir) / "case-mixed.docx"
            write_docx_with_case_mixed_content_types(package)

            failures = [
                (result.part, result.check, result.message)
                for result in format_validate.validate_package(package)
                if result.status == "fail"
            ]

        self.assertEqual([], failures)


if __name__ == "__main__":
    unittest.main()
