#!/usr/bin/env python3
"""Validate OOXML format-specific package contracts.

This complements the part-level XSD and generic OPC validators. It checks the
`.docx`, `.xlsx`, and `.pptx` contracts that require connecting the package
root relationship, content types, main XML roots, and in-document relationship
references.

Usage:
  python3 scripts/ooxml_format_validate.py
  python3 scripts/ooxml_format_validate.py path/to/file.docx path/to/file.xlsx
  python3 scripts/ooxml_format_validate.py --all-fixtures --failures-only --summary
  python3 scripts/ooxml_format_validate.py --json path/to/file.pptx
"""

from __future__ import annotations

import argparse
import json
import posixpath
import sys
import zipfile
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit
from xml.etree import ElementTree as ET

from ooxml_xsd_validate import McPreprocessError, mc_preprocess_xml


REPO = Path(__file__).resolve().parents[1]
ECMA_SCHEMA_ROOTS = (
    REPO / "references" / "raw" / "ecma376-1" / "OfficeOpenXML-XMLSchema-Strict",
    REPO / "references" / "raw" / "ecma376-4" / "OfficeOpenXML-XMLSchema-Transitional",
    REPO / "references" / "raw" / "ecma376-2" / "OpenPackagingConventions-XMLSchema",
)
CONTENT_TYPES_NS = "http://schemas.openxmlformats.org/package/2006/content-types"
RELATIONSHIPS_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
CONTENT_TYPES_PART = "[Content_Types].xml"
PACKAGE_RELS_PART = "_rels/.rels"

OD_REL_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
OD_REL_NS_STRICT = "http://purl.oclc.org/ooxml/officeDocument/relationships"
OD_REL_NAMESPACES = {OD_REL_NS_TRANSITIONAL, OD_REL_NS_STRICT}
PACKAGE_CORE_PROPERTIES_REL_TYPE = f"{RELATIONSHIPS_NS}/metadata/core-properties"

WML_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
WML_NS_STRICT = "http://purl.oclc.org/ooxml/wordprocessingml/main"
SML_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
SML_NS_STRICT = "http://purl.oclc.org/ooxml/spreadsheetml/main"
PML_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/presentationml/2006/main"
PML_NS_STRICT = "http://purl.oclc.org/ooxml/presentationml/main"
DML_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/drawingml/2006/main"
DML_NS_STRICT = "http://purl.oclc.org/ooxml/drawingml/main"
DML_CHART_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/drawingml/2006/chart"
DML_CHART_NS_STRICT = "http://purl.oclc.org/ooxml/drawingml/chart"
DML_CHART_DRAWING_NS_TRANSITIONAL = (
    "http://schemas.openxmlformats.org/drawingml/2006/chartDrawing"
)
DML_CHART_DRAWING_NS_STRICT = "http://purl.oclc.org/ooxml/drawingml/chartDrawing"
DML_DIAGRAM_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/drawingml/2006/diagram"
DML_DIAGRAM_NS_STRICT = "http://purl.oclc.org/ooxml/drawingml/diagram"
DML_SPREADSHEET_DRAWING_NS_TRANSITIONAL = (
    "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing"
)
DML_SPREADSHEET_DRAWING_NS_STRICT = "http://purl.oclc.org/ooxml/drawingml/spreadsheetDrawing"
OPC_CORE_PROPERTIES_NS = "http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
EXTENDED_PROPERTIES_NS_TRANSITIONAL = (
    "http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
)
EXTENDED_PROPERTIES_NS_STRICT = "http://purl.oclc.org/ooxml/officeDocument/extendedProperties"
CUSTOM_PROPERTIES_NS_TRANSITIONAL = (
    "http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"
)
CUSTOM_PROPERTIES_NS_STRICT = "http://purl.oclc.org/ooxml/officeDocument/customProperties"
CUSTOM_XML_PROPS_NS_TRANSITIONAL = (
    "http://schemas.openxmlformats.org/officeDocument/2006/customXml"
)
CUSTOM_XML_PROPS_NS_STRICT = "http://purl.oclc.org/ooxml/officeDocument/customXml"

DOCX_MAIN_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"
XLSX_MAIN_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"
PPTX_MAIN_CT = "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"
WORKSHEET_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"
CHARTSHEET_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.chartsheet+xml"
DIALOGSHEET_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.dialogsheet+xml"
SPREADSHEET_STYLES_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"
SHARED_STRINGS_CT = (
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"
)
SPREADSHEET_COMMENTS_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.comments+xml"
SPREADSHEET_TABLE_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.table+xml"
PIVOT_TABLE_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.pivotTable+xml"
PIVOT_CACHE_DEFINITION_CT = (
    "application/vnd.openxmlformats-officedocument.spreadsheetml.pivotCacheDefinition+xml"
)
PIVOT_CACHE_RECORDS_CT = (
    "application/vnd.openxmlformats-officedocument.spreadsheetml.pivotCacheRecords+xml"
)
SPREADSHEET_EXTERNAL_LINK_CT = (
    "application/vnd.openxmlformats-officedocument.spreadsheetml.externalLink+xml"
)
SPREADSHEET_DRAWING_CT = "application/vnd.openxmlformats-officedocument.drawing+xml"
SLIDE_CT = "application/vnd.openxmlformats-officedocument.presentationml.slide+xml"
SLIDE_MASTER_CT = "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"
SLIDE_LAYOUT_CT = "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"
PRESENTATION_COMMENTS_CT = (
    "application/vnd.openxmlformats-officedocument.presentationml.comments+xml"
)
PRESENTATION_VIEW_PROPS_CT = (
    "application/vnd.openxmlformats-officedocument.presentationml.viewProps+xml"
)
PRESENTATION_PROPS_CT = (
    "application/vnd.openxmlformats-officedocument.presentationml.presProps+xml"
)
THEME_CT = "application/vnd.openxmlformats-officedocument.theme+xml"
THEME_OVERRIDE_CT = "application/vnd.openxmlformats-officedocument.themeOverride+xml"
THEME_MANAGER_CT = "application/vnd.openxmlformats-officedocument.themeManager+xml"
CHART_CT = "application/vnd.openxmlformats-officedocument.drawingml.chart+xml"
CHART_USER_SHAPES_CT = "application/vnd.openxmlformats-officedocument.drawingml.chartshapes+xml"
VML_DRAWING_CT = "application/vnd.openxmlformats-officedocument.vmlDrawing"
DIAGRAM_DATA_CT = "application/vnd.openxmlformats-officedocument.drawingml.diagramData+xml"
DIAGRAM_LAYOUT_CT = "application/vnd.openxmlformats-officedocument.drawingml.diagramLayout+xml"
DIAGRAM_STYLE_CT = "application/vnd.openxmlformats-officedocument.drawingml.diagramStyle+xml"
DIAGRAM_COLORS_CT = "application/vnd.openxmlformats-officedocument.drawingml.diagramColors+xml"
WORD_GLOSSARY_DOCUMENT_CT = (
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document.glossary+xml"
)
WORD_STYLES_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"
WORD_NUMBERING_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"
WORD_SETTINGS_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"
WORD_FONT_TABLE_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml"
WORD_COMMENTS_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.comments+xml"
WORD_FOOTNOTES_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml"
WORD_ENDNOTES_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml"
WORD_HEADER_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"
WORD_FOOTER_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"
WORD_WEB_SETTINGS_CT = (
    "application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml"
)
CORE_PROPERTIES_CT = "application/vnd.openxmlformats-package.core-properties+xml"
EXTENDED_PROPERTIES_CT = "application/vnd.openxmlformats-officedocument.extended-properties+xml"
CUSTOM_PROPERTIES_CT = "application/vnd.openxmlformats-officedocument.custom-properties+xml"
CUSTOM_XML_PROPERTIES_CT = (
    "application/vnd.openxmlformats-officedocument.customXmlProperties+xml"
)
IMAGE_CONTENT_TYPES = {
    "image/bmp",
    "image/gif",
    "image/jpeg",
    "image/png",
    "image/tiff",
    "image/x-emf",
    "image/x-wmf",
}
IMAGE_SIGNATURES = {
    "image/bmp": (b"BM",),
    "image/gif": (b"GIF87a", b"GIF89a"),
    "image/jpeg": (b"\xff\xd8\xff",),
    "image/png": (b"\x89PNG\r\n\x1a\n",),
    "image/tiff": (b"II*\x00", b"MM\x00*"),
}


def vendored_ecma_schema_namespaces() -> set[str]:
    namespaces: set[str] = set()
    for schema_root in ECMA_SCHEMA_ROOTS:
        if not schema_root.exists():
            continue
        for xsd in schema_root.glob("*.xsd"):
            try:
                namespace = ET.parse(xsd).getroot().get("targetNamespace")
            except ET.ParseError:
                continue
            if namespace:
                namespaces.add(namespace)
    return namespaces


DEFAULT_FIXTURES = [
    REPO / ".snapshots" / "fixtures" / "docx" / "paragraph" / "paragraph-alignment.docx",
    REPO / ".snapshots" / "fixtures" / "xlsx" / "cell" / "cell-values.xlsx",
    REPO
    / ".snapshots"
    / "fixtures"
    / "pptx"
    / "shape"
    / "pml-slide-grid-with-text.pptx",
]


def rel_types(local_name: str) -> set[str]:
    return {
        f"{OD_REL_NS_TRANSITIONAL}/{local_name}",
        f"{OD_REL_NS_STRICT}/{local_name}",
    }


@dataclass(frozen=True)
class ValidationResult:
    package: str
    part: str
    status: str
    check: str
    message: str


@dataclass(frozen=True)
class FormatSpec:
    label: str
    main_content_type: str
    main_root_tags: set[tuple[str, str]]


@dataclass(frozen=True)
class PartContract:
    relationship_types: set[str]
    content_types: set[str]
    root_tags: set[tuple[str, str]]


@dataclass(frozen=True)
class Relationship:
    relationship_id: str
    relationship_type: str
    target: str
    target_mode: str
    source_part: str | None
    resolved_part: str | None


FORMAT_SPECS = {
    ".docx": FormatSpec(
        "docx",
        DOCX_MAIN_CT,
        {
            (WML_NS_TRANSITIONAL, "document"),
            (WML_NS_STRICT, "document"),
        },
    ),
    ".xlsx": FormatSpec(
        "xlsx",
        XLSX_MAIN_CT,
        {
            (SML_NS_TRANSITIONAL, "workbook"),
            (SML_NS_STRICT, "workbook"),
        },
    ),
    ".pptx": FormatSpec(
        "pptx",
        PPTX_MAIN_CT,
        {
            (PML_NS_TRANSITIONAL, "presentation"),
            (PML_NS_STRICT, "presentation"),
        },
    ),
}

SPREADSHEET_SHEET_CONTRACT = PartContract(
    rel_types("worksheet") | rel_types("chartsheet") | rel_types("dialogsheet"),
    {WORKSHEET_CT, CHARTSHEET_CT, DIALOGSHEET_CT},
    {
        (SML_NS_TRANSITIONAL, "worksheet"),
        (SML_NS_STRICT, "worksheet"),
        (SML_NS_TRANSITIONAL, "chartsheet"),
        (SML_NS_STRICT, "chartsheet"),
        (SML_NS_TRANSITIONAL, "dialogsheet"),
        (SML_NS_STRICT, "dialogsheet"),
    },
)

PRESENTATION_SLIDE_CONTRACT = PartContract(
    rel_types("slide"),
    {SLIDE_CT},
    {
        (PML_NS_TRANSITIONAL, "sld"),
        (PML_NS_STRICT, "sld"),
    },
)

PRESENTATION_SLIDE_MASTER_CONTRACT = PartContract(
    rel_types("slideMaster"),
    {SLIDE_MASTER_CT},
    {
        (PML_NS_TRANSITIONAL, "sldMaster"),
        (PML_NS_STRICT, "sldMaster"),
    },
)

WORD_STYLES_CONTRACT = PartContract(
    rel_types("styles"),
    {WORD_STYLES_CT},
    {
        (WML_NS_TRANSITIONAL, "styles"),
        (WML_NS_STRICT, "styles"),
    },
)

SPREADSHEET_STYLES_CONTRACT = PartContract(
    rel_types("styles"),
    {SPREADSHEET_STYLES_CT},
    {
        (SML_NS_TRANSITIONAL, "styleSheet"),
        (SML_NS_STRICT, "styleSheet"),
    },
)

WORD_COMMENTS_CONTRACT = PartContract(
    rel_types("comments"),
    {WORD_COMMENTS_CT},
    {
        (WML_NS_TRANSITIONAL, "comments"),
        (WML_NS_STRICT, "comments"),
    },
)

SPREADSHEET_COMMENTS_CONTRACT = PartContract(
    rel_types("comments"),
    {SPREADSHEET_COMMENTS_CT},
    {
        (SML_NS_TRANSITIONAL, "comments"),
        (SML_NS_STRICT, "comments"),
    },
)

PRESENTATION_COMMENTS_CONTRACT = PartContract(
    rel_types("comments"),
    {PRESENTATION_COMMENTS_CT},
    {
        (PML_NS_TRANSITIONAL, "cmLst"),
        (PML_NS_STRICT, "cmLst"),
    },
)


CONTENT_TYPE_ROOT_TAGS: dict[str, set[tuple[str, str]]] = {
    DOCX_MAIN_CT: {
        (WML_NS_TRANSITIONAL, "document"),
        (WML_NS_STRICT, "document"),
    },
    WORD_GLOSSARY_DOCUMENT_CT: {
        (WML_NS_TRANSITIONAL, "glossaryDocument"),
        (WML_NS_STRICT, "glossaryDocument"),
    },
    WORD_STYLES_CT: {
        (WML_NS_TRANSITIONAL, "styles"),
        (WML_NS_STRICT, "styles"),
    },
    WORD_NUMBERING_CT: {
        (WML_NS_TRANSITIONAL, "numbering"),
        (WML_NS_STRICT, "numbering"),
    },
    WORD_SETTINGS_CT: {
        (WML_NS_TRANSITIONAL, "settings"),
        (WML_NS_STRICT, "settings"),
    },
    WORD_FONT_TABLE_CT: {
        (WML_NS_TRANSITIONAL, "fonts"),
        (WML_NS_STRICT, "fonts"),
    },
    WORD_COMMENTS_CT: {
        (WML_NS_TRANSITIONAL, "comments"),
        (WML_NS_STRICT, "comments"),
    },
    WORD_FOOTNOTES_CT: {
        (WML_NS_TRANSITIONAL, "footnotes"),
        (WML_NS_STRICT, "footnotes"),
    },
    WORD_ENDNOTES_CT: {
        (WML_NS_TRANSITIONAL, "endnotes"),
        (WML_NS_STRICT, "endnotes"),
    },
    WORD_HEADER_CT: {
        (WML_NS_TRANSITIONAL, "hdr"),
        (WML_NS_STRICT, "hdr"),
    },
    WORD_FOOTER_CT: {
        (WML_NS_TRANSITIONAL, "ftr"),
        (WML_NS_STRICT, "ftr"),
    },
    WORD_WEB_SETTINGS_CT: {
        (WML_NS_TRANSITIONAL, "webSettings"),
        (WML_NS_STRICT, "webSettings"),
    },
    XLSX_MAIN_CT: {
        (SML_NS_TRANSITIONAL, "workbook"),
        (SML_NS_STRICT, "workbook"),
    },
    WORKSHEET_CT: {
        (SML_NS_TRANSITIONAL, "worksheet"),
        (SML_NS_STRICT, "worksheet"),
    },
    CHARTSHEET_CT: {
        (SML_NS_TRANSITIONAL, "chartsheet"),
        (SML_NS_STRICT, "chartsheet"),
    },
    DIALOGSHEET_CT: {
        (SML_NS_TRANSITIONAL, "dialogsheet"),
        (SML_NS_STRICT, "dialogsheet"),
    },
    SPREADSHEET_STYLES_CT: {
        (SML_NS_TRANSITIONAL, "styleSheet"),
        (SML_NS_STRICT, "styleSheet"),
    },
    SHARED_STRINGS_CT: {
        (SML_NS_TRANSITIONAL, "sst"),
        (SML_NS_STRICT, "sst"),
    },
    SPREADSHEET_COMMENTS_CT: {
        (SML_NS_TRANSITIONAL, "comments"),
        (SML_NS_STRICT, "comments"),
    },
    SPREADSHEET_TABLE_CT: {
        (SML_NS_TRANSITIONAL, "table"),
        (SML_NS_STRICT, "table"),
    },
    PIVOT_TABLE_CT: {
        (SML_NS_TRANSITIONAL, "pivotTableDefinition"),
        (SML_NS_STRICT, "pivotTableDefinition"),
    },
    PIVOT_CACHE_DEFINITION_CT: {
        (SML_NS_TRANSITIONAL, "pivotCacheDefinition"),
        (SML_NS_STRICT, "pivotCacheDefinition"),
    },
    PIVOT_CACHE_RECORDS_CT: {
        (SML_NS_TRANSITIONAL, "pivotCacheRecords"),
        (SML_NS_STRICT, "pivotCacheRecords"),
    },
    SPREADSHEET_EXTERNAL_LINK_CT: {
        (SML_NS_TRANSITIONAL, "externalLink"),
        (SML_NS_STRICT, "externalLink"),
    },
    SPREADSHEET_DRAWING_CT: {
        (DML_SPREADSHEET_DRAWING_NS_TRANSITIONAL, "wsDr"),
        (DML_SPREADSHEET_DRAWING_NS_STRICT, "wsDr"),
    },
    PPTX_MAIN_CT: {
        (PML_NS_TRANSITIONAL, "presentation"),
        (PML_NS_STRICT, "presentation"),
    },
    SLIDE_CT: {
        (PML_NS_TRANSITIONAL, "sld"),
        (PML_NS_STRICT, "sld"),
    },
    SLIDE_LAYOUT_CT: {
        (PML_NS_TRANSITIONAL, "sldLayout"),
        (PML_NS_STRICT, "sldLayout"),
    },
    SLIDE_MASTER_CT: {
        (PML_NS_TRANSITIONAL, "sldMaster"),
        (PML_NS_STRICT, "sldMaster"),
    },
    PRESENTATION_COMMENTS_CT: {
        (PML_NS_TRANSITIONAL, "cmLst"),
        (PML_NS_STRICT, "cmLst"),
    },
    PRESENTATION_VIEW_PROPS_CT: {
        (PML_NS_TRANSITIONAL, "viewPr"),
        (PML_NS_STRICT, "viewPr"),
    },
    PRESENTATION_PROPS_CT: {
        (PML_NS_TRANSITIONAL, "presentationPr"),
        (PML_NS_STRICT, "presentationPr"),
    },
    THEME_CT: {
        (DML_NS_TRANSITIONAL, "theme"),
        (DML_NS_STRICT, "theme"),
    },
    THEME_OVERRIDE_CT: {
        (DML_NS_TRANSITIONAL, "themeOverride"),
        (DML_NS_STRICT, "themeOverride"),
    },
    THEME_MANAGER_CT: {
        (DML_NS_TRANSITIONAL, "themeManager"),
        (DML_NS_STRICT, "themeManager"),
    },
    CHART_CT: {
        (DML_CHART_NS_TRANSITIONAL, "chartSpace"),
        (DML_CHART_NS_STRICT, "chartSpace"),
    },
    CHART_USER_SHAPES_CT: {
        (DML_CHART_NS_TRANSITIONAL, "userShapes"),
        (DML_CHART_NS_STRICT, "userShapes"),
    },
    VML_DRAWING_CT: {
        ("", "xml"),
    },
    DIAGRAM_DATA_CT: {
        (DML_DIAGRAM_NS_TRANSITIONAL, "dataModel"),
        (DML_DIAGRAM_NS_STRICT, "dataModel"),
    },
    DIAGRAM_LAYOUT_CT: {
        (DML_DIAGRAM_NS_TRANSITIONAL, "layoutDef"),
        (DML_DIAGRAM_NS_TRANSITIONAL, "layoutDefHdr"),
        (DML_DIAGRAM_NS_TRANSITIONAL, "layoutDefHdrLst"),
        (DML_DIAGRAM_NS_STRICT, "layoutDef"),
        (DML_DIAGRAM_NS_STRICT, "layoutDefHdr"),
        (DML_DIAGRAM_NS_STRICT, "layoutDefHdrLst"),
    },
    DIAGRAM_STYLE_CT: {
        (DML_DIAGRAM_NS_TRANSITIONAL, "styleDef"),
        (DML_DIAGRAM_NS_TRANSITIONAL, "styleDefHdr"),
        (DML_DIAGRAM_NS_TRANSITIONAL, "styleDefHdrLst"),
        (DML_DIAGRAM_NS_STRICT, "styleDef"),
        (DML_DIAGRAM_NS_STRICT, "styleDefHdr"),
        (DML_DIAGRAM_NS_STRICT, "styleDefHdrLst"),
    },
    DIAGRAM_COLORS_CT: {
        (DML_DIAGRAM_NS_TRANSITIONAL, "colorsDef"),
        (DML_DIAGRAM_NS_TRANSITIONAL, "colorsDefHdr"),
        (DML_DIAGRAM_NS_TRANSITIONAL, "colorsDefHdrLst"),
        (DML_DIAGRAM_NS_STRICT, "colorsDef"),
        (DML_DIAGRAM_NS_STRICT, "colorsDefHdr"),
        (DML_DIAGRAM_NS_STRICT, "colorsDefHdrLst"),
    },
    CORE_PROPERTIES_CT: {
        (OPC_CORE_PROPERTIES_NS, "coreProperties"),
    },
    EXTENDED_PROPERTIES_CT: {
        (EXTENDED_PROPERTIES_NS_TRANSITIONAL, "Properties"),
        (EXTENDED_PROPERTIES_NS_STRICT, "Properties"),
    },
    CUSTOM_PROPERTIES_CT: {
        (CUSTOM_PROPERTIES_NS_TRANSITIONAL, "Properties"),
        (CUSTOM_PROPERTIES_NS_STRICT, "Properties"),
    },
    CUSTOM_XML_PROPERTIES_CT: {
        (CUSTOM_XML_PROPS_NS_TRANSITIONAL, "datastoreItem"),
        (CUSTOM_XML_PROPS_NS_STRICT, "datastoreItem"),
    },
}

STANDARD_XML_ROOT_NAMESPACES = {
    namespace for root_tags in CONTENT_TYPE_ROOT_TAGS.values() for namespace, _ in root_tags
}
FORMAT_MC_SUPPORTED_NAMESPACES = (
    vendored_ecma_schema_namespaces() | STANDARD_XML_ROOT_NAMESPACES | OD_REL_NAMESPACES
)


def relationship_contract(
    local_name: str,
    content_types: set[str],
    root_tags: set[tuple[str, str]],
) -> dict[str, PartContract]:
    relationship_types = rel_types(local_name)
    contract = PartContract(relationship_types, content_types, root_tags)
    return {relationship_type: contract for relationship_type in relationship_types}


RELATIONSHIP_TARGET_CONTRACTS: dict[str, PartContract] = {}
for contracts in [
    relationship_contract(
        "officeDocument",
        {DOCX_MAIN_CT, XLSX_MAIN_CT, PPTX_MAIN_CT},
        {
            (WML_NS_TRANSITIONAL, "document"),
            (WML_NS_STRICT, "document"),
            (SML_NS_TRANSITIONAL, "workbook"),
            (SML_NS_STRICT, "workbook"),
            (PML_NS_TRANSITIONAL, "presentation"),
            (PML_NS_STRICT, "presentation"),
        },
    ),
    relationship_contract(
        "glossaryDocument",
        {WORD_GLOSSARY_DOCUMENT_CT},
        {
            (WML_NS_TRANSITIONAL, "glossaryDocument"),
            (WML_NS_STRICT, "glossaryDocument"),
        },
    ),
    {
        PACKAGE_CORE_PROPERTIES_REL_TYPE: PartContract(
            {PACKAGE_CORE_PROPERTIES_REL_TYPE},
            {CORE_PROPERTIES_CT},
            CONTENT_TYPE_ROOT_TAGS[CORE_PROPERTIES_CT],
        )
    },
    relationship_contract(
        "extended-properties",
        {EXTENDED_PROPERTIES_CT},
        CONTENT_TYPE_ROOT_TAGS[EXTENDED_PROPERTIES_CT],
    ),
    relationship_contract(
        "custom-properties",
        {CUSTOM_PROPERTIES_CT},
        CONTENT_TYPE_ROOT_TAGS[CUSTOM_PROPERTIES_CT],
    ),
    relationship_contract("customXml", {"application/xml"}, set()),
    relationship_contract(
        "customXmlProps",
        {CUSTOM_XML_PROPERTIES_CT},
        CONTENT_TYPE_ROOT_TAGS[CUSTOM_XML_PROPERTIES_CT],
    ),
    relationship_contract(
        "worksheet",
        {WORKSHEET_CT},
        {
            (SML_NS_TRANSITIONAL, "worksheet"),
            (SML_NS_STRICT, "worksheet"),
        },
    ),
    relationship_contract(
        "chartsheet",
        {CHARTSHEET_CT},
        {
            (SML_NS_TRANSITIONAL, "chartsheet"),
            (SML_NS_STRICT, "chartsheet"),
        },
    ),
    relationship_contract(
        "dialogsheet",
        {DIALOGSHEET_CT},
        {
            (SML_NS_TRANSITIONAL, "dialogsheet"),
            (SML_NS_STRICT, "dialogsheet"),
        },
    ),
    relationship_contract(
        "sharedStrings",
        {SHARED_STRINGS_CT},
        {
            (SML_NS_TRANSITIONAL, "sst"),
            (SML_NS_STRICT, "sst"),
        },
    ),
    relationship_contract(
        "numbering",
        {WORD_NUMBERING_CT},
        {
            (WML_NS_TRANSITIONAL, "numbering"),
            (WML_NS_STRICT, "numbering"),
        },
    ),
    relationship_contract(
        "settings",
        {WORD_SETTINGS_CT},
        {
            (WML_NS_TRANSITIONAL, "settings"),
            (WML_NS_STRICT, "settings"),
        },
    ),
    relationship_contract(
        "fontTable",
        {WORD_FONT_TABLE_CT},
        {
            (WML_NS_TRANSITIONAL, "fonts"),
            (WML_NS_STRICT, "fonts"),
        },
    ),
    relationship_contract(
        "webSettings",
        {WORD_WEB_SETTINGS_CT},
        {
            (WML_NS_TRANSITIONAL, "webSettings"),
            (WML_NS_STRICT, "webSettings"),
        },
    ),
    relationship_contract(
        "footnotes",
        {WORD_FOOTNOTES_CT},
        {
            (WML_NS_TRANSITIONAL, "footnotes"),
            (WML_NS_STRICT, "footnotes"),
        },
    ),
    relationship_contract(
        "endnotes",
        {WORD_ENDNOTES_CT},
        {
            (WML_NS_TRANSITIONAL, "endnotes"),
            (WML_NS_STRICT, "endnotes"),
        },
    ),
    relationship_contract(
        "header",
        {WORD_HEADER_CT},
        {
            (WML_NS_TRANSITIONAL, "hdr"),
            (WML_NS_STRICT, "hdr"),
        },
    ),
    relationship_contract(
        "footer",
        {WORD_FOOTER_CT},
        {
            (WML_NS_TRANSITIONAL, "ftr"),
            (WML_NS_STRICT, "ftr"),
        },
    ),
    relationship_contract(
        "drawing",
        {SPREADSHEET_DRAWING_CT},
        {
            (DML_SPREADSHEET_DRAWING_NS_TRANSITIONAL, "wsDr"),
            (DML_SPREADSHEET_DRAWING_NS_STRICT, "wsDr"),
        },
    ),
    relationship_contract(
        "table",
        {SPREADSHEET_TABLE_CT},
        {
            (SML_NS_TRANSITIONAL, "table"),
            (SML_NS_STRICT, "table"),
        },
    ),
    relationship_contract(
        "pivotTable",
        {PIVOT_TABLE_CT},
        {
            (SML_NS_TRANSITIONAL, "pivotTableDefinition"),
            (SML_NS_STRICT, "pivotTableDefinition"),
        },
    ),
    relationship_contract(
        "pivotCacheDefinition",
        {PIVOT_CACHE_DEFINITION_CT},
        {
            (SML_NS_TRANSITIONAL, "pivotCacheDefinition"),
            (SML_NS_STRICT, "pivotCacheDefinition"),
        },
    ),
    relationship_contract(
        "pivotCacheRecords",
        {PIVOT_CACHE_RECORDS_CT},
        {
            (SML_NS_TRANSITIONAL, "pivotCacheRecords"),
            (SML_NS_STRICT, "pivotCacheRecords"),
        },
    ),
    relationship_contract(
        "externalLink",
        {SPREADSHEET_EXTERNAL_LINK_CT},
        {
            (SML_NS_TRANSITIONAL, "externalLink"),
            (SML_NS_STRICT, "externalLink"),
        },
    ),
    relationship_contract(
        "slide",
        {SLIDE_CT},
        {
            (PML_NS_TRANSITIONAL, "sld"),
            (PML_NS_STRICT, "sld"),
        },
    ),
    relationship_contract(
        "slideMaster",
        {SLIDE_MASTER_CT},
        {
            (PML_NS_TRANSITIONAL, "sldMaster"),
            (PML_NS_STRICT, "sldMaster"),
        },
    ),
    relationship_contract(
        "slideLayout",
        {SLIDE_LAYOUT_CT},
        {
            (PML_NS_TRANSITIONAL, "sldLayout"),
            (PML_NS_STRICT, "sldLayout"),
        },
    ),
    relationship_contract(
        "theme",
        {THEME_CT},
        {
            (DML_NS_TRANSITIONAL, "theme"),
            (DML_NS_STRICT, "theme"),
        },
    ),
    relationship_contract(
        "viewProps",
        {PRESENTATION_VIEW_PROPS_CT},
        CONTENT_TYPE_ROOT_TAGS[PRESENTATION_VIEW_PROPS_CT],
    ),
    relationship_contract(
        "presProps",
        {PRESENTATION_PROPS_CT},
        CONTENT_TYPE_ROOT_TAGS[PRESENTATION_PROPS_CT],
    ),
    relationship_contract(
        "themeOverride",
        {THEME_OVERRIDE_CT},
        CONTENT_TYPE_ROOT_TAGS[THEME_OVERRIDE_CT],
    ),
    relationship_contract(
        "themeManager",
        {THEME_MANAGER_CT},
        CONTENT_TYPE_ROOT_TAGS[THEME_MANAGER_CT],
    ),
    relationship_contract(
        "chart",
        {CHART_CT},
        {
            (DML_CHART_NS_TRANSITIONAL, "chartSpace"),
            (DML_CHART_NS_STRICT, "chartSpace"),
        },
    ),
    relationship_contract(
        "chartUserShapes",
        {CHART_USER_SHAPES_CT},
        {
            (DML_CHART_NS_TRANSITIONAL, "userShapes"),
            (DML_CHART_NS_STRICT, "userShapes"),
        },
    ),
    relationship_contract(
        "vmlDrawing",
        {VML_DRAWING_CT},
        {
            ("", "xml"),
        },
    ),
    relationship_contract(
        "diagramData",
        {DIAGRAM_DATA_CT},
        {
            (DML_DIAGRAM_NS_TRANSITIONAL, "dataModel"),
            (DML_DIAGRAM_NS_STRICT, "dataModel"),
        },
    ),
    relationship_contract(
        "diagramLayout",
        {DIAGRAM_LAYOUT_CT},
        {
            (DML_DIAGRAM_NS_TRANSITIONAL, "layoutDef"),
            (DML_DIAGRAM_NS_TRANSITIONAL, "layoutDefHdr"),
            (DML_DIAGRAM_NS_TRANSITIONAL, "layoutDefHdrLst"),
            (DML_DIAGRAM_NS_STRICT, "layoutDef"),
            (DML_DIAGRAM_NS_STRICT, "layoutDefHdr"),
            (DML_DIAGRAM_NS_STRICT, "layoutDefHdrLst"),
        },
    ),
    relationship_contract(
        "diagramQuickStyle",
        {DIAGRAM_STYLE_CT},
        {
            (DML_DIAGRAM_NS_TRANSITIONAL, "styleDef"),
            (DML_DIAGRAM_NS_TRANSITIONAL, "styleDefHdr"),
            (DML_DIAGRAM_NS_TRANSITIONAL, "styleDefHdrLst"),
            (DML_DIAGRAM_NS_STRICT, "styleDef"),
            (DML_DIAGRAM_NS_STRICT, "styleDefHdr"),
            (DML_DIAGRAM_NS_STRICT, "styleDefHdrLst"),
        },
    ),
    relationship_contract(
        "diagramColors",
        {DIAGRAM_COLORS_CT},
        {
            (DML_DIAGRAM_NS_TRANSITIONAL, "colorsDef"),
            (DML_DIAGRAM_NS_TRANSITIONAL, "colorsDefHdr"),
            (DML_DIAGRAM_NS_TRANSITIONAL, "colorsDefHdrLst"),
            (DML_DIAGRAM_NS_STRICT, "colorsDef"),
            (DML_DIAGRAM_NS_STRICT, "colorsDefHdr"),
            (DML_DIAGRAM_NS_STRICT, "colorsDefHdrLst"),
        },
    ),
    relationship_contract("image", IMAGE_CONTENT_TYPES, set()),
]:
    RELATIONSHIP_TARGET_CONTRACTS.update(contracts)

EXTERNAL_TARGET_RELATIONSHIP_TYPES = (
    rel_types("audio")
    | rel_types("externalLinkPath")
    | rel_types("hyperlink")
    | rel_types("image")
    | rel_types("video")
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="*", help="OOXML package files to validate")
    parser.add_argument(
        "--all-fixtures",
        action="store_true",
        help="validate every .docx/.xlsx/.pptx under .snapshots/fixtures",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="write machine-readable validation results",
    )
    parser.add_argument(
        "--failures-only",
        action="store_true",
        help="only print failed validation rows in text output",
    )
    parser.add_argument(
        "--summary",
        action="store_true",
        help="print status and check summaries after text output",
    )
    return parser.parse_args()


def collect_packages(args: argparse.Namespace) -> list[Path]:
    if args.all_fixtures:
        fixture_root = REPO / ".snapshots" / "fixtures"
        paths = sorted(
            path
            for suffix in ("*.docx", "*.xlsx", "*.pptx")
            for path in fixture_root.rglob(suffix)
        )
        if paths:
            return paths

    if args.files:
        return [Path(value).resolve() for value in args.files]

    paths = [path for path in DEFAULT_FIXTURES if path.exists()]
    if not paths:
        print(
            "ooxml_format_validate.py: no input files and default fixtures are absent",
            file=sys.stderr,
        )
        print("Run 'moon run src/cmd/catalog -- fixtures' to generate fixtures.", file=sys.stderr)
        sys.exit(2)
    return paths


def package_label(package: Path) -> str:
    return str(package.relative_to(REPO) if package.is_relative_to(REPO) else package)


def fail(package: Path, part: str, check: str, message: str) -> ValidationResult:
    return ValidationResult(package_label(package), part, "fail", check, message)


def ok(package: Path) -> ValidationResult:
    return ValidationResult(package_label(package), "(package)", "ok", "format", "")


def ascii_case_key(value: str) -> str:
    return "".join(
        chr(ord(character) + 32) if "A" <= character <= "Z" else character
        for character in value
    )


def content_type_key(content_type: str) -> str:
    return ascii_case_key(content_type)


SOURCE_SCOPED_RELATIONSHIP_TARGET_CONTRACTS: dict[str, dict[str, PartContract]] = {}


def register_source_scoped_relationship_contract(
    contract: PartContract,
    source_content_types: set[str],
) -> None:
    for relationship_type in contract.relationship_types:
        contracts = SOURCE_SCOPED_RELATIONSHIP_TARGET_CONTRACTS.setdefault(
            relationship_type,
            {},
        )
        for source_content_type in source_content_types:
            contracts[content_type_key(source_content_type)] = contract


register_source_scoped_relationship_contract(
    WORD_STYLES_CONTRACT,
    {DOCX_MAIN_CT, WORD_GLOSSARY_DOCUMENT_CT},
)
register_source_scoped_relationship_contract(
    SPREADSHEET_STYLES_CONTRACT,
    {XLSX_MAIN_CT},
)
register_source_scoped_relationship_contract(
    WORD_COMMENTS_CONTRACT,
    {DOCX_MAIN_CT, WORD_GLOSSARY_DOCUMENT_CT},
)
register_source_scoped_relationship_contract(
    SPREADSHEET_COMMENTS_CONTRACT,
    {WORKSHEET_CT, DIALOGSHEET_CT},
)
register_source_scoped_relationship_contract(
    PRESENTATION_COMMENTS_CONTRACT,
    {SLIDE_CT},
)


def part_name_for_item(item_name: str) -> str:
    return "/" + item_name


def item_name_for_part(part_name: str) -> str:
    return part_name[1:] if part_name.startswith("/") else part_name


def relationships_source_part(item_name: str) -> str | None:
    if item_name == PACKAGE_RELS_PART:
        return None
    if not item_name.endswith(".rels") or "/_rels/" not in item_name:
        return ""
    prefix, rels_name = item_name.rsplit("/_rels/", 1)
    source_name = rels_name[: -len(".rels")]
    if prefix:
        return "/" + prefix + "/" + source_name
    return "/" + source_name


def relationships_item_for_source_part(source_part: str | None) -> str:
    if source_part is None:
        return PACKAGE_RELS_PART
    item_name = item_name_for_part(source_part)
    directory, basename = posixpath.split(item_name)
    if directory:
        return f"{directory}/_rels/{basename}.rels"
    return f"_rels/{basename}.rels"


def split_tag(tag: str) -> tuple[str, str]:
    if tag.startswith("{"):
        namespace, local_name = tag[1:].split("}", 1)
        return namespace, local_name
    return "", tag


def tag_display(tag: str) -> str:
    namespace, local_name = split_tag(tag)
    if not namespace:
        return local_name
    return f"{{{namespace}}}{local_name}"


def parse_content_types(
    package: Path,
    archive: zipfile.ZipFile,
) -> tuple[dict[str, str], dict[str, str], list[ValidationResult]]:
    defaults: dict[str, str] = {}
    overrides: dict[str, str] = {}
    try:
        root = ET.fromstring(archive.read(CONTENT_TYPES_PART))
    except KeyError:
        return defaults, overrides, [fail(package, CONTENT_TYPES_PART, "content-types", "missing")]
    except ET.ParseError as error:
        return defaults, overrides, [
            fail(package, CONTENT_TYPES_PART, "content-types", f"xml parse: {error}")
        ]

    if root.tag != f"{{{CONTENT_TYPES_NS}}}Types":
        return defaults, overrides, [
            fail(package, CONTENT_TYPES_PART, "content-types", f"unexpected root element: {root.tag}")
        ]

    for child in root:
        if child.tag == f"{{{CONTENT_TYPES_NS}}}Default":
            extension = child.get("Extension", "")
            content_type = child.get("ContentType", "")
            defaults[ascii_case_key(extension)] = content_type
        elif child.tag == f"{{{CONTENT_TYPES_NS}}}Override":
            part_name = child.get("PartName", "")
            content_type = child.get("ContentType", "")
            overrides[ascii_case_key(part_name)] = content_type
    return defaults, overrides, []


def content_type_for_part(
    part_name: str,
    defaults: dict[str, str],
    overrides: dict[str, str],
) -> str | None:
    override_key = ascii_case_key(part_name)
    if override_key in overrides:
        return overrides[override_key]
    item_name = item_name_for_part(part_name)
    basename = item_name.rsplit("/", 1)[-1]
    if "." not in basename:
        return None
    extension = basename.rsplit(".", 1)[-1]
    return defaults.get(ascii_case_key(extension))


def resolve_internal_target(source_part: str | None, target: str) -> tuple[str | None, str | None]:
    parsed = urlsplit(target)
    if parsed.scheme or parsed.netloc:
        return None, "internal relationship target must be a relative reference"
    if parsed.fragment:
        return None, "internal relationship target must identify a part, not a fragment"
    if parsed.query:
        return None, "internal relationship target must identify a part, not a query resource"

    target_path = parsed.path
    if target_path == "":
        return None, "internal relationship target is empty"
    if "\\" in target_path:
        return None, "internal relationship target must not contain backslash"

    base_dir = "/"
    if source_part is not None:
        base_dir = posixpath.dirname(source_part)
        if base_dir == "":
            base_dir = "/"

    raw_path = target_path if target_path.startswith("/") else base_dir + "/" + target_path
    resolved: list[str] = []
    for segment in raw_path.split("/"):
        if segment in ("", "."):
            continue
        if segment == "..":
            if not resolved:
                return None, "internal relationship target escapes the package root"
            resolved.pop()
            continue
        resolved.append(segment)

    if not resolved:
        return None, "internal relationship target does not resolve to a part"
    return "/" + "/".join(resolved), None


def preprocess_relationships_xml(relationships_xml: bytes) -> bytes:
    return mc_preprocess_xml(
        relationships_xml,
        supported_namespaces={RELATIONSHIPS_NS},
    )


def parse_relationships(
    package: Path,
    archive: zipfile.ZipFile,
    item_name: str,
    source_part: str | None,
) -> tuple[dict[str, Relationship], list[ValidationResult]]:
    relationships: dict[str, Relationship] = {}
    try:
        relationships_xml = preprocess_relationships_xml(archive.read(item_name))
    except KeyError:
        return relationships, [fail(package, item_name, "relationships", "missing")]
    except McPreprocessError as error:
        return relationships, [
            fail(package, item_name, "relationships", f"markup compatibility: {error}")
        ]
    except ET.ParseError as error:
        return relationships, [fail(package, item_name, "relationships", f"xml parse: {error}")]
    try:
        root = ET.fromstring(relationships_xml)
    except ET.ParseError as error:
        return relationships, [fail(package, item_name, "relationships", f"xml parse: {error}")]

    if root.tag != f"{{{RELATIONSHIPS_NS}}}Relationships":
        return relationships, [
            fail(package, item_name, "relationships", f"unexpected root element: {root.tag}")
        ]

    for child in root:
        if child.tag != f"{{{RELATIONSHIPS_NS}}}Relationship":
            continue
        relationship_id = child.get("Id", "")
        target = child.get("Target", "")
        target_mode = child.get("TargetMode", "Internal")
        resolved_part = None
        if target_mode == "Internal":
            resolved_part, _ = resolve_internal_target(source_part, target)
        relationships[relationship_id] = Relationship(
            relationship_id,
            child.get("Type", ""),
            target,
            target_mode,
            source_part,
            resolved_part,
        )
    return relationships, []


def parse_xml_root(
    package: Path,
    archive: zipfile.ZipFile,
    part_name: str,
) -> tuple[ET.Element | None, list[ValidationResult]]:
    try:
        xml_bytes = mc_preprocess_xml(
            archive.read(item_name_for_part(part_name)),
            supported_namespaces=FORMAT_MC_SUPPORTED_NAMESPACES,
        )
    except KeyError:
        return None, [fail(package, part_name, "part", "missing")]
    except McPreprocessError as error:
        return None, [
            fail(package, part_name, "markup-compatibility", f"markup compatibility: {error}")
        ]
    except ET.ParseError as error:
        return None, [fail(package, part_name, "xml-parse", str(error))]
    try:
        root = ET.fromstring(xml_bytes)
    except ET.ParseError as error:
        return None, [fail(package, part_name, "xml-parse", str(error))]
    return root, []


def relationship_ref_id(element: ET.Element, local_name: str = "id") -> str | None:
    for namespace in OD_REL_NAMESPACES:
        value = element.get(f"{{{namespace}}}{local_name}")
        if value:
            return value
    return None


def office_relationship_local_name(relationship_type: str) -> str | None:
    for namespace in OD_REL_NAMESPACES:
        prefix = namespace + "/"
        if relationship_type.startswith(prefix):
            return relationship_type[len(prefix) :]
    return None


def is_standardized_ooxml_xml_content_type(content_type: str) -> bool:
    normalized = content_type_key(content_type)
    if not normalized.endswith("+xml"):
        return False
    return normalized.startswith("application/vnd.openxmlformats-officedocument.") or (
        normalized.startswith("application/vnd.openxmlformats-package.")
    )


CONTENT_TYPE_ROOT_TAGS_BY_KEY = {
    content_type_key(content_type): root_tags
    for content_type, root_tags in CONTENT_TYPE_ROOT_TAGS.items()
}
IMAGE_SIGNATURES_BY_CONTENT_TYPE_KEY = {
    content_type_key(content_type): signatures
    for content_type, signatures in IMAGE_SIGNATURES.items()
}
STANDARD_PART_CONTENT_TYPE_KEYS = set(CONTENT_TYPE_ROOT_TAGS_BY_KEY) | {
    content_type_key(content_type) for content_type in IMAGE_CONTENT_TYPES
}


def expected_root_tags_for_content_type(
    content_type: str | None,
) -> set[tuple[str, str]] | None:
    if content_type is None:
        return None
    return CONTENT_TYPE_ROOT_TAGS_BY_KEY.get(content_type_key(content_type))


def content_type_in_set(content_type: str | None, expected: set[str]) -> bool:
    if content_type is None:
        return False
    key = content_type_key(content_type)
    return any(key == content_type_key(candidate) for candidate in expected)


def is_standard_part_content_type(content_type: str | None) -> bool:
    return (
        content_type is not None
        and content_type_key(content_type) in STANDARD_PART_CONTENT_TYPE_KEYS
    )


def validate_xml_part_content_type_roots(
    package: Path,
    archive: zipfile.ZipFile,
    ordinary_parts: set[str],
    defaults: dict[str, str],
    overrides: dict[str, str],
    xml_roots: dict[str, ET.Element],
) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    for part_name in sorted(ordinary_parts):
        if not part_name.endswith(".xml"):
            continue

        content_type = content_type_for_part(part_name, defaults, overrides)
        root = xml_roots.get(part_name)
        if root is None:
            root, root_results = parse_xml_root(package, archive, part_name)
            results.extend(root_results)
            if root is None:
                continue
            xml_roots[part_name] = root

        root_tag = split_tag(root.tag)
        expected_root_tags = expected_root_tags_for_content_type(content_type)
        if expected_root_tags is not None:
            if root_tag not in expected_root_tags:
                results.append(
                    fail(
                        package,
                        part_name,
                        "content-type-root",
                        f"{content_type}: unexpected root element: {tag_display(root.tag)}",
                    )
                )
            continue

        if content_type is None:
            continue
        if (
            content_type_key(content_type) == "application/xml"
            and root_tag[0] in STANDARD_XML_ROOT_NAMESPACES
        ):
            results.append(
                fail(
                    package,
                    part_name,
                    "content-type-root",
                    f"standard OOXML root uses generic application/xml content type: {tag_display(root.tag)}",
                )
            )
            continue
        if is_standardized_ooxml_xml_content_type(content_type):
            results.append(
                fail(
                    package,
                    part_name,
                    "content-type-root",
                    f"unmapped standardized OOXML XML content type: {content_type}",
                )
            )
    return results


def validate_binary_part_content_types(
    package: Path,
    archive: zipfile.ZipFile,
    ordinary_parts: set[str],
    defaults: dict[str, str],
    overrides: dict[str, str],
) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    for part_name in sorted(ordinary_parts):
        content_type = content_type_for_part(part_name, defaults, overrides)
        signatures = (
            IMAGE_SIGNATURES_BY_CONTENT_TYPE_KEY.get(content_type_key(content_type))
            if content_type is not None
            else None
        )
        if signatures is None:
            continue

        try:
            data = archive.read(item_name_for_part(part_name))
        except KeyError:
            results.append(fail(package, part_name, "binary-content-type", "missing"))
            continue

        if not any(data.startswith(signature) for signature in signatures):
            results.append(
                fail(
                    package,
                    part_name,
                    "binary-content-type",
                    f"{content_type}: payload signature does not match declared content type",
                )
            )
    return results


def collect_reachable_parts(
    ordinary_parts: set[str],
    relationships_by_source: dict[str | None, dict[str, Relationship]],
) -> set[str]:
    reachable: set[str] = set()
    visited_sources: set[str | None] = set()
    pending: list[str | None] = [None]

    while pending:
        source_part = pending.pop()
        if source_part in visited_sources:
            continue
        visited_sources.add(source_part)

        for relationship in relationships_by_source.get(source_part, {}).values():
            if relationship.target_mode != "Internal":
                continue
            target_part = relationship.resolved_part
            if target_part is None or target_part not in ordinary_parts:
                continue
            if target_part not in reachable:
                reachable.add(target_part)
                pending.append(target_part)
    return reachable


def validate_standard_part_reachability(
    package: Path,
    ordinary_parts: set[str],
    defaults: dict[str, str],
    overrides: dict[str, str],
    relationships_by_source: dict[str | None, dict[str, Relationship]],
) -> list[ValidationResult]:
    if None not in relationships_by_source:
        return []

    results: list[ValidationResult] = []
    reachable_parts = collect_reachable_parts(ordinary_parts, relationships_by_source)
    for part_name in sorted(ordinary_parts):
        content_type = content_type_for_part(part_name, defaults, overrides)
        if not is_standard_part_content_type(content_type):
            continue
        if part_name in reachable_parts:
            continue
        results.append(
            fail(
                package,
                part_name,
                "part-reachability",
                f"{content_type}: standard OOXML part is not reachable from package root relationships",
            )
        )
    return results


def validate_linked_part(
    package: Path,
    archive: zipfile.ZipFile,
    source_part: str | None,
    relationship_id: str,
    contract: PartContract,
    defaults: dict[str, str],
    overrides: dict[str, str],
    relationships_by_source: dict[str | None, dict[str, Relationship]],
    xml_roots: dict[str, ET.Element],
    check: str,
) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    relationships = relationships_by_source.get(source_part)
    if relationships is None:
        results.append(
            fail(
                package,
                relationships_item_for_source_part(source_part),
                check,
                f"missing Relationships part for {source_part or 'package root'}",
            )
        )
        return results

    relationship = relationships.get(relationship_id)
    if relationship is None:
        results.append(
            fail(
                package,
                source_part or "(package)",
                check,
                f"missing relationship Id referenced by XML: {relationship_id}",
            )
        )
        return results

    if relationship.relationship_type not in contract.relationship_types:
        results.append(
            fail(
                package,
                source_part or "(package)",
                check,
                f"{relationship_id}: unexpected relationship type: {relationship.relationship_type}",
            )
        )

    if relationship.target_mode != "Internal":
        results.append(
            fail(
                package,
                source_part or "(package)",
                check,
                f"{relationship_id}: expected Internal target, got {relationship.target_mode}",
            )
        )
        return results

    target_part = relationship.resolved_part
    if target_part is None:
        results.append(
            fail(
                package,
                source_part or "(package)",
                check,
                f"{relationship_id}: target does not resolve to a part: {relationship.target}",
            )
        )
        return results

    content_type = content_type_for_part(target_part, defaults, overrides)
    if not content_type_in_set(content_type, contract.content_types):
        results.append(
            fail(
                package,
                target_part,
                check,
                f"{relationship_id}: unexpected content type: {content_type or '(missing)'}",
            )
        )

    if contract.root_tags:
        root = xml_roots.get(target_part)
        if root is None:
            root, root_results = parse_xml_root(package, archive, target_part)
            results.extend(root_results)
            if root is not None:
                xml_roots[target_part] = root
        if root is not None and split_tag(root.tag) not in contract.root_tags:
            results.append(
                fail(
                    package,
                    target_part,
                    check,
                    f"{relationship_id}: unexpected root element: {tag_display(root.tag)}",
                )
            )
    return results


def validate_relationship_target_contracts(
    package: Path,
    archive: zipfile.ZipFile,
    defaults: dict[str, str],
    overrides: dict[str, str],
    relationships_by_source: dict[str | None, dict[str, Relationship]],
    xml_roots: dict[str, ET.Element],
) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    for source_part, relationships in relationships_by_source.items():
        source_label = source_part or "(package)"
        for relationship in relationships.values():
            local_name = office_relationship_local_name(relationship.relationship_type)
            if relationship.target_mode == "External":
                if relationship.relationship_type in EXTERNAL_TARGET_RELATIONSHIP_TYPES:
                    continue
                if local_name is not None:
                    results.append(
                        fail(
                            package,
                            source_label,
                            "relationship-target",
                            f"{relationship.relationship_id}: unexpected External target for {local_name}",
                        )
                    )
                continue

            source_content_type = (
                None
                if source_part is None
                else content_type_for_part(source_part, defaults, overrides)
            )
            source_scoped_contracts = SOURCE_SCOPED_RELATIONSHIP_TARGET_CONTRACTS.get(
                relationship.relationship_type,
            )
            if source_scoped_contracts is not None:
                contract = (
                    source_scoped_contracts.get(content_type_key(source_content_type))
                    if source_content_type is not None
                    else None
                )
                if contract is None:
                    results.append(
                        fail(
                            package,
                            source_label,
                            "relationship-target",
                            f"{relationship.relationship_id}: {local_name} relationship is not valid from source content type {source_content_type or '(missing)'}",
                        )
                    )
                    continue
            else:
                contract = RELATIONSHIP_TARGET_CONTRACTS.get(relationship.relationship_type)
            if contract is None:
                if local_name is not None:
                    results.append(
                        fail(
                            package,
                            source_label,
                            "relationship-target",
                            f"{relationship.relationship_id}: unmapped Office relationship type: {relationship.relationship_type}",
                        )
                    )
                continue

            target_part = relationship.resolved_part
            if target_part is None:
                results.append(
                    fail(
                        package,
                        source_label,
                        "relationship-target",
                        f"{relationship.relationship_id}: target does not resolve to a part: {relationship.target}",
                    )
                )
                continue

            content_type = content_type_for_part(target_part, defaults, overrides)
            if not content_type_in_set(content_type, contract.content_types):
                results.append(
                    fail(
                        package,
                        target_part,
                        "relationship-target",
                        f"{relationship.relationship_id}: {relationship.relationship_type} target has unexpected content type: {content_type or '(missing)'}",
                    )
                )
                continue

            if not contract.root_tags:
                continue

            root = xml_roots.get(target_part)
            if root is None:
                root, root_results = parse_xml_root(package, archive, target_part)
                results.extend(root_results)
                if root is not None:
                    xml_roots[target_part] = root
            if root is not None and split_tag(root.tag) not in contract.root_tags:
                results.append(
                    fail(
                        package,
                        target_part,
                        "relationship-target",
                        f"{relationship.relationship_id}: {relationship.relationship_type} target has unexpected root element: {tag_display(root.tag)}",
                    )
                )
    return results


def validate_main_part(
    package: Path,
    archive: zipfile.ZipFile,
    defaults: dict[str, str],
    overrides: dict[str, str],
    relationships_by_source: dict[str | None, dict[str, Relationship]],
    xml_roots: dict[str, ET.Element],
) -> tuple[str | None, FormatSpec | None, list[ValidationResult]]:
    results: list[ValidationResult] = []
    spec = FORMAT_SPECS.get(package.suffix.lower())
    if spec is None:
        return None, None, [fail(package, "(package)", "format", "unsupported OOXML extension")]

    package_relationships = relationships_by_source.get(None)
    if package_relationships is None:
        return None, spec, [fail(package, PACKAGE_RELS_PART, "main-part", "missing")]

    office_document_rels = [
        relationship
        for relationship in package_relationships.values()
        if relationship.relationship_type in rel_types("officeDocument")
    ]
    if not office_document_rels:
        return None, spec, [
            fail(package, PACKAGE_RELS_PART, "main-part", "missing officeDocument relationship")
        ]
    if len(office_document_rels) > 1:
        results.append(
            fail(
                package,
                PACKAGE_RELS_PART,
                "main-part",
                f"multiple officeDocument relationships: {len(office_document_rels)}",
            )
        )

    relationship = office_document_rels[0]
    contract = PartContract(
        rel_types("officeDocument"),
        {spec.main_content_type},
        spec.main_root_tags,
    )
    results.extend(
        validate_linked_part(
            package,
            archive,
            None,
            relationship.relationship_id,
            contract,
            defaults,
            overrides,
            relationships_by_source,
            xml_roots,
            "main-part",
        )
    )
    return relationship.resolved_part, spec, results


def validate_relationship_reference_attrs(
    package: Path,
    archive: zipfile.ZipFile,
    ordinary_parts: set[str],
    relationships_by_source: dict[str | None, dict[str, Relationship]],
    xml_roots: dict[str, ET.Element],
) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    for part_name in sorted(ordinary_parts):
        if not part_name.endswith(".xml"):
            continue
        root = xml_roots.get(part_name)
        if root is None:
            root, root_results = parse_xml_root(package, archive, part_name)
            results.extend(root_results)
            if root is None:
                continue
            xml_roots[part_name] = root

        relationships = relationships_by_source.get(part_name)
        for element in root.iter():
            for attr_name, relationship_id in element.attrib.items():
                namespace, local_name = split_tag(attr_name)
                if namespace not in OD_REL_NAMESPACES:
                    continue
                if not relationship_id:
                    results.append(
                        fail(
                            package,
                            part_name,
                            "relationship-reference",
                            f"{tag_display(element.tag)}/@{local_name} is empty",
                        )
                    )
                    continue
                if relationships is None:
                    results.append(
                        fail(
                            package,
                            relationships_item_for_source_part(part_name),
                            "relationship-reference",
                            f"missing Relationships part for {part_name}; referenced {relationship_id}",
                        )
                    )
                    continue
                if relationship_id not in relationships:
                    results.append(
                        fail(
                            package,
                            part_name,
                            "relationship-reference",
                            f"{tag_display(element.tag)}/@{local_name} references missing Id {relationship_id}",
                        )
                    )
    return results


def validate_spreadsheet_contract(
    package: Path,
    archive: zipfile.ZipFile,
    main_part: str,
    defaults: dict[str, str],
    overrides: dict[str, str],
    relationships_by_source: dict[str | None, dict[str, Relationship]],
    xml_roots: dict[str, ET.Element],
) -> list[ValidationResult]:
    root = xml_roots.get(main_part)
    if root is None:
        root, root_results = parse_xml_root(package, archive, main_part)
        if root is None:
            return root_results
        xml_roots[main_part] = root

    results: list[ValidationResult] = []
    for element in root.iter():
        namespace, local_name = split_tag(element.tag)
        if namespace not in (SML_NS_TRANSITIONAL, SML_NS_STRICT) or local_name != "sheet":
            continue
        relationship_id = relationship_ref_id(element)
        if relationship_id is None:
            results.append(fail(package, main_part, "xlsx-sheet", "sheet is missing r:id"))
            continue
        results.extend(
            validate_linked_part(
                package,
                archive,
                main_part,
                relationship_id,
                SPREADSHEET_SHEET_CONTRACT,
                defaults,
                overrides,
                relationships_by_source,
                xml_roots,
                "xlsx-sheet",
            )
        )
    return results


def validate_presentation_contract(
    package: Path,
    archive: zipfile.ZipFile,
    main_part: str,
    defaults: dict[str, str],
    overrides: dict[str, str],
    relationships_by_source: dict[str | None, dict[str, Relationship]],
    xml_roots: dict[str, ET.Element],
) -> list[ValidationResult]:
    root = xml_roots.get(main_part)
    if root is None:
        root, root_results = parse_xml_root(package, archive, main_part)
        if root is None:
            return root_results
        xml_roots[main_part] = root

    results: list[ValidationResult] = []
    for element in root.iter():
        namespace, local_name = split_tag(element.tag)
        if namespace not in (PML_NS_TRANSITIONAL, PML_NS_STRICT):
            continue
        if local_name == "sldId":
            relationship_id = relationship_ref_id(element)
            if relationship_id is None:
                results.append(fail(package, main_part, "pptx-slide", "sldId is missing r:id"))
                continue
            results.extend(
                validate_linked_part(
                    package,
                    archive,
                    main_part,
                    relationship_id,
                    PRESENTATION_SLIDE_CONTRACT,
                    defaults,
                    overrides,
                    relationships_by_source,
                    xml_roots,
                    "pptx-slide",
                )
            )
        elif local_name == "sldMasterId":
            relationship_id = relationship_ref_id(element)
            if relationship_id is None:
                results.append(
                    fail(package, main_part, "pptx-slide-master", "sldMasterId is missing r:id")
                )
                continue
            results.extend(
                validate_linked_part(
                    package,
                    archive,
                    main_part,
                    relationship_id,
                    PRESENTATION_SLIDE_MASTER_CONTRACT,
                    defaults,
                    overrides,
                    relationships_by_source,
                    xml_roots,
                    "pptx-slide-master",
                )
            )
    return results


def validate_package(package: Path) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    try:
        with zipfile.ZipFile(package) as archive:
            names = [info.filename for info in archive.infolist()]
            file_names = [name for name in names if not name.endswith("/")]
            ordinary_parts = {
                part_name_for_item(name)
                for name in file_names
                if name != CONTENT_TYPES_PART and not name.endswith(".rels")
            }

            defaults, overrides, content_type_results = parse_content_types(package, archive)
            results.extend(content_type_results)

            relationship_items = [name for name in file_names if name.endswith(".rels")]
            relationships_by_source: dict[str | None, dict[str, Relationship]] = {}
            for item_name in relationship_items:
                source_part = relationships_source_part(item_name)
                if source_part == "":
                    results.append(
                        fail(package, item_name, "relationships", "invalid Relationships part item name")
                    )
                    continue
                relationships, relationship_results = parse_relationships(
                    package,
                    archive,
                    item_name,
                    source_part,
                )
                relationships_by_source[source_part] = relationships
                results.extend(relationship_results)

            xml_roots: dict[str, ET.Element] = {}
            main_part, spec, main_results = validate_main_part(
                package,
                archive,
                defaults,
                overrides,
                relationships_by_source,
                xml_roots,
            )
            results.extend(main_results)

            results.extend(
                validate_xml_part_content_type_roots(
                    package,
                    archive,
                    ordinary_parts,
                    defaults,
                    overrides,
                    xml_roots,
                )
            )

            results.extend(
                validate_binary_part_content_types(
                    package,
                    archive,
                    ordinary_parts,
                    defaults,
                    overrides,
                )
            )

            results.extend(
                validate_standard_part_reachability(
                    package,
                    ordinary_parts,
                    defaults,
                    overrides,
                    relationships_by_source,
                )
            )

            results.extend(
                validate_relationship_target_contracts(
                    package,
                    archive,
                    defaults,
                    overrides,
                    relationships_by_source,
                    xml_roots,
                )
            )

            results.extend(
                validate_relationship_reference_attrs(
                    package,
                    archive,
                    ordinary_parts,
                    relationships_by_source,
                    xml_roots,
                )
            )

            if main_part is not None and spec is not None:
                if spec.label == "xlsx":
                    results.extend(
                        validate_spreadsheet_contract(
                            package,
                            archive,
                            main_part,
                            defaults,
                            overrides,
                            relationships_by_source,
                            xml_roots,
                        )
                    )
                elif spec.label == "pptx":
                    results.extend(
                        validate_presentation_contract(
                            package,
                            archive,
                            main_part,
                            defaults,
                            overrides,
                            relationships_by_source,
                            xml_roots,
                        )
                    )

    except zipfile.BadZipFile as error:
        results.append(fail(package, "", "zip", f"bad zip: {error}"))
    except OSError as error:
        results.append(fail(package, "", "file", str(error)))

    return results if results else [ok(package)]


def print_table(results: list[ValidationResult], failures_only: bool) -> None:
    print("package\tpart\tstatus\tcheck")
    for result in results:
        if failures_only and result.status != "fail":
            continue
        print(f"{result.package}\t{result.part}\t{result.status}\t{result.check}")
        if result.status == "fail" and result.message:
            print(f"  {result.message}", file=sys.stderr)


def print_summary(results: list[ValidationResult]) -> None:
    by_status: dict[str, int] = {}
    failures_by_check: dict[str, int] = {}
    failures_by_package: dict[str, int] = {}
    for result in results:
        by_status[result.status] = by_status.get(result.status, 0) + 1
        if result.status == "fail":
            failures_by_check[result.check] = failures_by_check.get(result.check, 0) + 1
            failures_by_package[result.package] = failures_by_package.get(result.package, 0) + 1

    print("")
    print("summary")
    for status in sorted(by_status):
        print(f"  {status}: {by_status[status]}")
    if failures_by_check:
        print("failures by check")
        for check, count in sorted(failures_by_check.items(), key=lambda item: (-item[1], item[0])):
            print(f"  {check}: {count}")
    if failures_by_package:
        print("top failing packages")
        for package, count in sorted(failures_by_package.items(), key=lambda item: (-item[1], item[0]))[:20]:
            print(f"  {package}: {count}")


def main() -> int:
    args = parse_args()
    packages = collect_packages(args)
    results: list[ValidationResult] = []
    for package in packages:
        results.extend(validate_package(package))

    if args.json:
        print(json.dumps([result.__dict__ for result in results], indent=2))
    else:
        print_table(results, failures_only=args.failures_only)
        if args.summary:
            print_summary(results)

    failures = [result for result in results if result.status == "fail"]
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
