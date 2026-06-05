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
SML_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
PML_NS = "http://schemas.openxmlformats.org/presentationml/2006/main"


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


def write_docx_with_spreadsheet_styles_relationship(package: Path) -> None:
    content_types = f"""<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="{format_validate.CONTENT_TYPES_NS}">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Override PartName="/word/document.xml" ContentType="{format_validate.DOCX_MAIN_CT}"/>
  <Override PartName="/xl/styles.xml" ContentType="{format_validate.SPREADSHEET_STYLES_CT}"/>
</Types>
"""
    package_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rId1" Type="{OD_REL_NS}/officeDocument" Target="word/document.xml"/>
</Relationships>
"""
    document_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rStyles" Type="{OD_REL_NS}/styles" Target="../xl/styles.xml"/>
</Relationships>
"""
    document = f"""<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="{WML_NS}">
  <w:body><w:p/><w:sectPr/></w:body>
</w:document>
"""
    styles = f"""<?xml version="1.0" encoding="UTF-8"?>
<styleSheet xmlns="{SML_NS}"/>
"""
    with zipfile.ZipFile(package, "w") as archive:
        archive.writestr(format_validate.CONTENT_TYPES_PART, content_types)
        archive.writestr(format_validate.PACKAGE_RELS_PART, package_relationships)
        archive.writestr("word/document.xml", document)
        archive.writestr("word/_rels/document.xml.rels", document_relationships)
        archive.writestr("xl/styles.xml", styles)


def write_xlsx_with_spreadsheet_styles_relationship(package: Path) -> None:
    content_types = f"""<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="{format_validate.CONTENT_TYPES_NS}">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="{format_validate.XLSX_MAIN_CT}"/>
  <Override PartName="/xl/styles.xml" ContentType="{format_validate.SPREADSHEET_STYLES_CT}"/>
</Types>
"""
    package_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rId1" Type="{OD_REL_NS}/officeDocument" Target="xl/workbook.xml"/>
</Relationships>
"""
    workbook_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rStyles" Type="{OD_REL_NS}/styles" Target="styles.xml"/>
</Relationships>
"""
    workbook = f"""<?xml version="1.0" encoding="UTF-8"?>
<workbook xmlns="{SML_NS}"/>
"""
    styles = f"""<?xml version="1.0" encoding="UTF-8"?>
<styleSheet xmlns="{SML_NS}"/>
"""
    with zipfile.ZipFile(package, "w") as archive:
        archive.writestr(format_validate.CONTENT_TYPES_PART, content_types)
        archive.writestr(format_validate.PACKAGE_RELS_PART, package_relationships)
        archive.writestr("xl/workbook.xml", workbook)
        archive.writestr("xl/_rels/workbook.xml.rels", workbook_relationships)
        archive.writestr("xl/styles.xml", styles)


def write_xlsx_with_word_comments_relationship(package: Path) -> None:
    content_types = f"""<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="{format_validate.CONTENT_TYPES_NS}">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="{format_validate.XLSX_MAIN_CT}"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="{format_validate.WORKSHEET_CT}"/>
  <Override PartName="/word/comments.xml" ContentType="{format_validate.WORD_COMMENTS_CT}"/>
</Types>
"""
    package_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rId1" Type="{OD_REL_NS}/officeDocument" Target="xl/workbook.xml"/>
</Relationships>
"""
    workbook_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rSheet1" Type="{OD_REL_NS}/worksheet" Target="worksheets/sheet1.xml"/>
</Relationships>
"""
    worksheet_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rComments" Type="{OD_REL_NS}/comments" Target="../../word/comments.xml"/>
</Relationships>
"""
    workbook = f"""<?xml version="1.0" encoding="UTF-8"?>
<workbook xmlns="{SML_NS}" xmlns:r="{OD_REL_NS}">
  <sheets>
    <sheet name="Sheet1" sheetId="1" r:id="rSheet1"/>
  </sheets>
</workbook>
"""
    worksheet = f"""<?xml version="1.0" encoding="UTF-8"?>
<worksheet xmlns="{SML_NS}"/>
"""
    comments = f"""<?xml version="1.0" encoding="UTF-8"?>
<w:comments xmlns:w="{WML_NS}"/>
"""
    with zipfile.ZipFile(package, "w") as archive:
        archive.writestr(format_validate.CONTENT_TYPES_PART, content_types)
        archive.writestr(format_validate.PACKAGE_RELS_PART, package_relationships)
        archive.writestr("xl/workbook.xml", workbook)
        archive.writestr("xl/_rels/workbook.xml.rels", workbook_relationships)
        archive.writestr("xl/worksheets/sheet1.xml", worksheet)
        archive.writestr("xl/worksheets/_rels/sheet1.xml.rels", worksheet_relationships)
        archive.writestr("word/comments.xml", comments)


def write_xlsx_with_dialogsheet_comments_relationship(package: Path) -> None:
    content_types = f"""<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="{format_validate.CONTENT_TYPES_NS}">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="{format_validate.XLSX_MAIN_CT}"/>
  <Override PartName="/xl/dialogsheets/sheet1.xml" ContentType="{format_validate.DIALOGSHEET_CT}"/>
  <Override PartName="/xl/comments1.xml" ContentType="{format_validate.SPREADSHEET_COMMENTS_CT}"/>
</Types>
"""
    package_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rId1" Type="{OD_REL_NS}/officeDocument" Target="xl/workbook.xml"/>
</Relationships>
"""
    workbook_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rDialog1" Type="{OD_REL_NS}/dialogsheet" Target="dialogsheets/sheet1.xml"/>
</Relationships>
"""
    dialogsheet_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rComments" Type="{OD_REL_NS}/comments" Target="../comments1.xml"/>
</Relationships>
"""
    workbook = f"""<?xml version="1.0" encoding="UTF-8"?>
<workbook xmlns="{SML_NS}" xmlns:r="{OD_REL_NS}">
  <sheets>
    <sheet name="Dialog1" sheetId="1" r:id="rDialog1"/>
  </sheets>
</workbook>
"""
    dialogsheet = f"""<?xml version="1.0" encoding="UTF-8"?>
<dialogsheet xmlns="{SML_NS}"/>
"""
    comments = f"""<?xml version="1.0" encoding="UTF-8"?>
<comments xmlns="{SML_NS}"/>
"""
    with zipfile.ZipFile(package, "w") as archive:
        archive.writestr(format_validate.CONTENT_TYPES_PART, content_types)
        archive.writestr(format_validate.PACKAGE_RELS_PART, package_relationships)
        archive.writestr("xl/workbook.xml", workbook)
        archive.writestr("xl/_rels/workbook.xml.rels", workbook_relationships)
        archive.writestr("xl/dialogsheets/sheet1.xml", dialogsheet)
        archive.writestr("xl/dialogsheets/_rels/sheet1.xml.rels", dialogsheet_relationships)
        archive.writestr("xl/comments1.xml", comments)


def write_pptx_with_slide_comments_relationship(package: Path) -> None:
    content_types = f"""<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="{format_validate.CONTENT_TYPES_NS}">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Override PartName="/ppt/presentation.xml" ContentType="{format_validate.PPTX_MAIN_CT}"/>
  <Override PartName="/ppt/slides/slide1.xml" ContentType="{format_validate.SLIDE_CT}"/>
  <Override PartName="/ppt/comments/comment1.xml" ContentType="{format_validate.PRESENTATION_COMMENTS_CT}"/>
</Types>
"""
    package_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rId1" Type="{OD_REL_NS}/officeDocument" Target="ppt/presentation.xml"/>
</Relationships>
"""
    presentation_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rSlide1" Type="{OD_REL_NS}/slide" Target="slides/slide1.xml"/>
</Relationships>
"""
    slide_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rComments" Type="{OD_REL_NS}/comments" Target="../comments/comment1.xml"/>
</Relationships>
"""
    presentation = f"""<?xml version="1.0" encoding="UTF-8"?>
<p:presentation xmlns:p="{PML_NS}" xmlns:r="{OD_REL_NS}">
  <p:sldIdLst>
    <p:sldId id="256" r:id="rSlide1"/>
  </p:sldIdLst>
</p:presentation>
"""
    slide = f"""<?xml version="1.0" encoding="UTF-8"?>
<p:sld xmlns:p="{PML_NS}"/>
"""
    comments = f"""<?xml version="1.0" encoding="UTF-8"?>
<p:cmLst xmlns:p="{PML_NS}"/>
"""
    with zipfile.ZipFile(package, "w") as archive:
        archive.writestr(format_validate.CONTENT_TYPES_PART, content_types)
        archive.writestr(format_validate.PACKAGE_RELS_PART, package_relationships)
        archive.writestr("ppt/presentation.xml", presentation)
        archive.writestr("ppt/_rels/presentation.xml.rels", presentation_relationships)
        archive.writestr("ppt/slides/slide1.xml", slide)
        archive.writestr("ppt/slides/_rels/slide1.xml.rels", slide_relationships)
        archive.writestr("ppt/comments/comment1.xml", comments)


def write_docx_with_glossary_styles_and_web_settings(package: Path) -> None:
    content_types = f"""<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="{format_validate.CONTENT_TYPES_NS}">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Override PartName="/word/document.xml" ContentType="{format_validate.DOCX_MAIN_CT}"/>
  <Override PartName="/word/glossary/document.xml" ContentType="{format_validate.WORD_GLOSSARY_DOCUMENT_CT}"/>
  <Override PartName="/word/glossary/styles.xml" ContentType="{format_validate.WORD_STYLES_CT}"/>
  <Override PartName="/word/glossary/webSettings.xml" ContentType="{format_validate.WORD_WEB_SETTINGS_CT}"/>
</Types>
"""
    package_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rId1" Type="{OD_REL_NS}/officeDocument" Target="word/document.xml"/>
</Relationships>
"""
    document_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rGlossary" Type="{OD_REL_NS}/glossaryDocument" Target="glossary/document.xml"/>
</Relationships>
"""
    glossary_relationships = f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{REL_NS}">
  <Relationship Id="rStyles" Type="{OD_REL_NS}/styles" Target="styles.xml"/>
  <Relationship Id="rWebSettings" Type="{OD_REL_NS}/webSettings" Target="webSettings.xml"/>
</Relationships>
"""
    document = f"""<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="{WML_NS}">
  <w:body><w:p/><w:sectPr/></w:body>
</w:document>
"""
    glossary = f"""<?xml version="1.0" encoding="UTF-8"?>
<w:glossaryDocument xmlns:w="{WML_NS}"/>
"""
    styles = f"""<?xml version="1.0" encoding="UTF-8"?>
<w:styles xmlns:w="{WML_NS}"/>
"""
    web_settings = f"""<?xml version="1.0" encoding="UTF-8"?>
<w:webSettings xmlns:w="{WML_NS}"/>
"""
    with zipfile.ZipFile(package, "w") as archive:
        archive.writestr(format_validate.CONTENT_TYPES_PART, content_types)
        archive.writestr(format_validate.PACKAGE_RELS_PART, package_relationships)
        archive.writestr("word/document.xml", document)
        archive.writestr("word/_rels/document.xml.rels", document_relationships)
        archive.writestr("word/glossary/document.xml", glossary)
        archive.writestr("word/glossary/_rels/document.xml.rels", glossary_relationships)
        archive.writestr("word/glossary/styles.xml", styles)
        archive.writestr("word/glossary/webSettings.xml", web_settings)


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

    def test_docx_styles_relationship_rejects_spreadsheet_styles_part(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            package = Path(tempdir) / "cross-styles.docx"
            write_docx_with_spreadsheet_styles_relationship(package)

            failures = [
                (result.part, result.check, result.message)
                for result in format_validate.validate_package(package)
                if result.status == "fail"
            ]

        self.assertIn(
            (
                "/xl/styles.xml",
                "relationship-target",
                "rStyles: http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles target has unexpected content type: application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml",
            ),
            failures,
        )

    def test_xlsx_styles_relationship_accepts_spreadsheet_styles_part(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            package = Path(tempdir) / "styles.xlsx"
            write_xlsx_with_spreadsheet_styles_relationship(package)

            failures = [
                (result.part, result.check, result.message)
                for result in format_validate.validate_package(package)
                if result.status == "fail"
            ]

        self.assertEqual([], failures)

    def test_xlsx_comments_relationship_rejects_word_comments_part(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            package = Path(tempdir) / "cross-comments.xlsx"
            write_xlsx_with_word_comments_relationship(package)

            failures = [
                (result.part, result.check, result.message)
                for result in format_validate.validate_package(package)
                if result.status == "fail"
            ]

        self.assertIn(
            (
                "/word/comments.xml",
                "relationship-target",
                "rComments: http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments target has unexpected content type: application/vnd.openxmlformats-officedocument.wordprocessingml.comments+xml",
            ),
            failures,
        )

    def test_xlsx_comments_relationship_accepts_dialogsheet_source(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            package = Path(tempdir) / "dialogsheet-comments.xlsx"
            write_xlsx_with_dialogsheet_comments_relationship(package)

            failures = [
                (result.part, result.check, result.message)
                for result in format_validate.validate_package(package)
                if result.status == "fail"
            ]

        self.assertEqual([], failures)

    def test_pptx_comments_relationship_accepts_slide_source(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            package = Path(tempdir) / "slide-comments.pptx"
            write_pptx_with_slide_comments_relationship(package)

            failures = [
                (result.part, result.check, result.message)
                for result in format_validate.validate_package(package)
                if result.status == "fail"
            ]

        self.assertEqual([], failures)

    def test_docx_glossary_relationship_accepts_styles_and_web_settings(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            package = Path(tempdir) / "glossary.docx"
            write_docx_with_glossary_styles_and_web_settings(package)

            failures = [
                (result.part, result.check, result.message)
                for result in format_validate.validate_package(package)
                if result.status == "fail"
            ]

        self.assertEqual([], failures)


if __name__ == "__main__":
    unittest.main()
