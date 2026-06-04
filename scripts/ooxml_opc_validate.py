#!/usr/bin/env python3
"""Validate OOXML packages for OPC graph and content-type consistency.

This complements `scripts/ooxml_xsd_validate.py`. XSD validation checks each
XML part in isolation; this script checks package-level Open Packaging
Conventions rules that require looking across ZIP entries, `[Content_Types].xml`,
and `.rels` parts.

Usage:
  python3 scripts/ooxml_opc_validate.py
  python3 scripts/ooxml_opc_validate.py path/to/file.docx path/to/file.xlsx
  python3 scripts/ooxml_opc_validate.py --all-fixtures
  python3 scripts/ooxml_opc_validate.py --json --failures-only path/to/file.pptx
"""

from __future__ import annotations

import argparse
import json
import posixpath
import re
import sys
import zipfile
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit
from xml.etree import ElementTree as ET


REPO = Path(__file__).resolve().parents[1]
CONTENT_TYPES_NS = "http://schemas.openxmlformats.org/package/2006/content-types"
RELATIONSHIPS_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
RELATIONSHIPS_CONTENT_TYPE = "application/vnd.openxmlformats-package.relationships+xml"
CORE_PROPERTIES_RELATIONSHIP_TYPE = (
    "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties"
)
DIGITAL_SIGNATURE_ORIGIN_RELATIONSHIP_TYPE = (
    "http://schemas.openxmlformats.org/package/2006/relationships/digital-signature/origin"
)
DIGITAL_SIGNATURE_RELATIONSHIP_TYPE = (
    "http://schemas.openxmlformats.org/package/2006/relationships/digital-signature/signature"
)
CORE_PROPERTIES_CONTENT_TYPE = "application/vnd.openxmlformats-package.core-properties+xml"
DIGITAL_SIGNATURE_ORIGIN_CONTENT_TYPE = (
    "application/vnd.openxmlformats-package.digital-signature-origin"
)
DIGITAL_SIGNATURE_XML_SIGNATURE_CONTENT_TYPE = (
    "application/vnd.openxmlformats-package.digital-signature-xmlsignature+xml"
)
RELATIONSHIPS_ROOT = "_rels/.rels"
CONTENT_TYPES_PART = "[Content_Types].xml"

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

PERCENT_ENCODED = re.compile(r"%([0-9A-Fa-f]{2})")
MALFORMED_PERCENT_ENCODING = re.compile(r"%(?![0-9A-Fa-f]{2})")
UNRESERVED = set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
SUB_DELIMS = set("!$&'()*+,;=")
ASCII_IPCHAR = UNRESERVED | SUB_DELIMS | set("%:@")
MEDIA_TYPE_TOKEN = r"[A-Za-z0-9!#$%&'*+\-.^_`{|}~]+"
MEDIA_TYPE = re.compile(rf"^{MEDIA_TYPE_TOKEN}/{MEDIA_TYPE_TOKEN}$")
XML_ENCODING_DECL = re.compile(r"""<\?xml\s+[^?]*\bencoding\s*=\s*(['"])([^'"]+)\1""")
ALLOWED_OPC_XML_ENCODINGS = {"utf-8", "utf-16"}
OPC_DEFINED_XML_CONTENT_TYPES = {
    CORE_PROPERTIES_CONTENT_TYPE,
    DIGITAL_SIGNATURE_XML_SIGNATURE_CONTENT_TYPE,
}


@dataclass(frozen=True)
class ValidationResult:
    package: str
    part: str
    status: str
    check: str
    message: str


@dataclass(frozen=True)
class RelationshipEntry:
    relationship_id: str
    relationship_type: str
    target: str
    target_mode: str
    resolved_part: str | None


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
            "ooxml_opc_validate.py: no input files and default fixtures are absent",
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
    return ValidationResult(package_label(package), "(package)", "ok", "opc", "")


def part_name_for_item(item_name: str) -> str:
    return "/" + item_name


def item_name_for_part(part_name: str) -> str:
    return part_name[1:] if part_name.startswith("/") else part_name


def ascii_case_key(value: str) -> str:
    return "".join(
        chr(ord(character) + 32) if "A" <= character <= "Z" else character
        for character in value
    )


def is_relationships_item(item_name: str) -> bool:
    return item_name == RELATIONSHIPS_ROOT or (
        "/_rels/" in item_name and item_name.endswith(".rels")
    )


def relationships_source_part(item_name: str) -> str | None:
    if item_name == RELATIONSHIPS_ROOT:
        return None
    if not item_name.endswith(".rels") or "/_rels/" not in item_name:
        return ""
    prefix, rels_name = item_name.rsplit("/_rels/", 1)
    source_name = rels_name[: -len(".rels")]
    if prefix:
        return "/" + prefix + "/" + source_name
    return "/" + source_name


def relationships_item_for_source_part(source_part: str) -> str:
    item_name = item_name_for_part(source_part)
    if "/" in item_name:
        prefix, basename = item_name.rsplit("/", 1)
        return prefix + "/_rels/" + basename + ".rels"
    return "_rels/" + item_name + ".rels"


def is_reserved_relationship_part_name(part_name: str) -> bool:
    item_name = item_name_for_part(part_name)
    return is_relationships_item(item_name)


def validate_part_name(part_name: str) -> str | None:
    if not part_name.startswith("/"):
        return "part name must start with '/'"
    if part_name == "/":
        return "part name must contain at least one non-empty segment"
    if "//" in part_name:
        return "part name must not contain empty segments"
    if "\\" in part_name:
        return "part name must not contain backslash"

    segments = part_name.split("/")[1:]
    for segment in segments:
        if segment == "":
            return "part name must not contain empty segments"
        if segment.endswith("."):
            return "part name segment must not end with '.'"
        if MALFORMED_PERCENT_ENCODING.search(segment):
            return "part name segment must not contain malformed percent-encoding"
        for character in segment:
            if ord(character) < 0x80 and character not in ASCII_IPCHAR:
                return f"part name segment contains character outside ipchar: {character!r}"
        for match in PERCENT_ENCODED.finditer(segment):
            value = int(match.group(1), 16)
            character = chr(value)
            if character in ("/", "\\"):
                return "part name segment must not percent-encode slash or backslash"
            if character in UNRESERVED:
                return "part name segment must not percent-encode unreserved characters"
    return None


def validate_default_extension(extension: str) -> str | None:
    if extension == "":
        return "Default Extension must be non-empty"
    if extension.startswith("."):
        return "Default Extension must omit the leading dot"
    if "/" in extension or "\\" in extension:
        return "Default Extension must not contain a path separator"
    return None


def validate_content_type_value(content_type: str) -> str | None:
    if content_type == "":
        return "ContentType must be non-empty"
    if ";" in content_type:
        return "ContentType must not include parameters"
    if any(character.isspace() for character in content_type):
        return "ContentType must not contain whitespace"
    if MEDIA_TYPE.fullmatch(content_type) is None:
        return "ContentType must be a valid media type"
    return None


def validate_relationship_type_value(relationship_type: str) -> str | None:
    if relationship_type == "":
        return "relationship Type must be non-empty"
    if any(character.isspace() for character in relationship_type):
        return "relationship Type must not contain whitespace"
    parsed = urlsplit(relationship_type)
    if not parsed.scheme:
        return "relationship Type must be an absolute URI"
    if parsed.fragment:
        return "relationship Type must not contain a fragment"
    return None


def content_type_for_item(
    item_name: str,
    defaults: dict[str, str],
    overrides: dict[str, str],
) -> str | None:
    part_name = part_name_for_item(item_name)
    override_key = ascii_case_key(part_name)
    if override_key in overrides:
        return overrides[override_key]
    basename = item_name.rsplit("/", 1)[-1]
    if "." not in basename:
        return None
    extension = basename.rsplit(".", 1)[-1]
    return defaults.get(ascii_case_key(extension))


def decode_xml_prolog(xml_bytes: bytes) -> str:
    prefix = xml_bytes[:4096]
    if prefix.startswith(b"\xff\xfe") or prefix.startswith(b"\xfe\xff"):
        return prefix.decode("utf-16", errors="ignore")
    if prefix.startswith(b"\xef\xbb\xbf"):
        return prefix.decode("utf-8-sig", errors="ignore")
    if prefix.startswith(b"\x00<"):
        return prefix.decode("utf-16-be", errors="ignore")
    if prefix.startswith(b"<\x00"):
        return prefix.decode("utf-16-le", errors="ignore")
    return prefix.decode("utf-8", errors="ignore")


def has_dtd_declaration(xml_bytes: bytes) -> bool:
    text = decode_xml_prolog(xml_bytes)
    position = 0
    if text.startswith("\ufeff"):
        position = 1
    while True:
        while position < len(text) and text[position].isspace():
            position += 1
        if text.startswith("<!--", position):
            end = text.find("-->", position + 4)
            if end < 0:
                return False
            position = end + 3
            continue
        if text.startswith("<?", position):
            end = text.find("?>", position + 2)
            if end < 0:
                return False
            position = end + 2
            continue
        return text.startswith("<!DOCTYPE", position)


def declared_xml_encoding(xml_bytes: bytes) -> str | None:
    match = XML_ENCODING_DECL.search(decode_xml_prolog(xml_bytes))
    return match.group(2) if match else None


def validate_opc_xml_usage(xml_bytes: bytes) -> str | None:
    encoding = declared_xml_encoding(xml_bytes)
    if encoding is not None and encoding.casefold() not in ALLOWED_OPC_XML_ENCODINGS:
        return f"OPC XML encoding declaration must be UTF-8 or UTF-16, not {encoding!r}"
    if has_dtd_declaration(xml_bytes):
        return "OPC XML markup must not include a DTD declaration"
    return None


def parse_content_types(
    package: Path,
    archive: zipfile.ZipFile,
) -> tuple[dict[str, str], dict[str, str], list[ValidationResult]]:
    results: list[ValidationResult] = []
    defaults: dict[str, str] = {}
    overrides: dict[str, str] = {}
    try:
        content_types_xml = archive.read(CONTENT_TYPES_PART)
    except KeyError:
        return defaults, overrides, [fail(package, CONTENT_TYPES_PART, "content-types", "missing")]
    xml_usage_error = validate_opc_xml_usage(content_types_xml)
    if xml_usage_error:
        return defaults, overrides, [
            fail(package, CONTENT_TYPES_PART, "xml-usage", xml_usage_error)
        ]
    try:
        root = ET.fromstring(content_types_xml)
    except ET.ParseError as error:
        return defaults, overrides, [
            fail(package, CONTENT_TYPES_PART, "content-types", f"xml parse: {error}")
        ]

    if root.tag != f"{{{CONTENT_TYPES_NS}}}Types":
        results.append(
            fail(
                package,
                CONTENT_TYPES_PART,
                "content-types",
                f"unexpected root element: {root.tag}",
            )
        )
        return defaults, overrides, results

    for child in root:
        if child.tag == f"{{{CONTENT_TYPES_NS}}}Default":
            extension = child.get("Extension", "")
            content_type = child.get("ContentType", "")
            extension_key = ascii_case_key(extension)
            extension_error = validate_default_extension(extension)
            if extension_error:
                results.append(
                    fail(
                        package,
                        CONTENT_TYPES_PART,
                        "content-types",
                        f"invalid Default Extension {extension!r}: {extension_error}",
                    )
                )
            content_type_error = validate_content_type_value(content_type)
            if content_type_error:
                results.append(
                    fail(
                        package,
                        CONTENT_TYPES_PART,
                        "content-types",
                        f"invalid Default ContentType for {extension!r}: {content_type_error}",
                    )
                )
            if extension_key in defaults:
                results.append(
                    fail(
                        package,
                        CONTENT_TYPES_PART,
                        "content-types",
                        f"duplicate Default for extension: {extension} (ASCII-case-insensitive)",
                    )
                )
            defaults[extension_key] = content_type
        elif child.tag == f"{{{CONTENT_TYPES_NS}}}Override":
            part_name = child.get("PartName", "")
            content_type = child.get("ContentType", "")
            part_name_key = ascii_case_key(part_name)
            if not part_name:
                results.append(
                    fail(
                        package,
                        CONTENT_TYPES_PART,
                        "content-types",
                        "Override PartName must be non-empty",
                    )
                )
            content_type_error = validate_content_type_value(content_type)
            if content_type_error:
                results.append(
                    fail(
                        package,
                        CONTENT_TYPES_PART,
                        "content-types",
                        f"invalid Override ContentType for {part_name!r}: {content_type_error}",
                    )
                )
            if part_name_key in overrides:
                results.append(
                    fail(
                        package,
                        CONTENT_TYPES_PART,
                        "content-types",
                        f"duplicate Override for part: {part_name} (ASCII-case-insensitive)",
                    )
                )
            if part_name:
                error = validate_part_name(part_name)
                if error:
                    results.append(
                        fail(
                            package,
                            CONTENT_TYPES_PART,
                            "content-types",
                            f"invalid Override PartName {part_name}: {error}",
                    )
                )
            overrides[part_name_key] = content_type
        else:
            results.append(
                fail(
                    package,
                    CONTENT_TYPES_PART,
                    "content-types",
                    f"unexpected child element: {child.tag}",
                )
            )

    return defaults, overrides, results


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

    raw_segments = target_path.split("/") if target_path.startswith("/") else (base_dir + "/" + target_path).split("/")
    resolved: list[str] = []
    for segment in raw_segments:
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
    part_name = "/" + "/".join(resolved)
    error = validate_part_name(part_name)
    if error:
        return None, f"internal relationship target resolves to invalid part name {part_name}: {error}"
    return part_name, None


def validate_relationships_part(
    package: Path,
    archive: zipfile.ZipFile,
    item_name: str,
    source_part: str | None,
    ordinary_parts: set[str],
) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    relationships_xml = archive.read(item_name)
    xml_usage_error = validate_opc_xml_usage(relationships_xml)
    if xml_usage_error:
        return [fail(package, item_name, "xml-usage", xml_usage_error)]
    try:
        root = ET.fromstring(relationships_xml)
    except ET.ParseError as error:
        return [fail(package, item_name, "relationships", f"xml parse: {error}")]

    if root.tag != f"{{{RELATIONSHIPS_NS}}}Relationships":
        results.append(
            fail(
                package,
                item_name,
                "relationships",
                f"unexpected root element: {root.tag}",
            )
        )
        return results

    ids: set[str] = set()
    for relationship in root:
        if relationship.tag != f"{{{RELATIONSHIPS_NS}}}Relationship":
            results.append(
                fail(
                    package,
                    item_name,
                    "relationships",
                    f"unexpected child element: {relationship.tag}",
                )
            )
            continue
        relationship_id = relationship.get("Id", "")
        relationship_type = relationship.get("Type", "")
        target = relationship.get("Target", "")
        target_mode = relationship.get("TargetMode", "Internal")
        if list(relationship):
            results.append(
                fail(
                    package,
                    item_name,
                    "relationships",
                    f"{relationship_id or '(missing Id)'}: Relationship element must not have child elements",
                )
            )
        if not relationship_id:
            results.append(
                fail(
                    package,
                    item_name,
                    "relationships",
                    "relationship Id must be non-empty",
                )
            )
        elif relationship_id in ids:
            results.append(
                fail(
                    package,
                    item_name,
                    "relationships",
                    f"duplicate relationship Id: {relationship_id}",
                )
            )
        if relationship_id:
            ids.add(relationship_id)

        type_error = validate_relationship_type_value(relationship_type)
        if type_error:
            results.append(
                fail(
                    package,
                    item_name,
                    "relationships",
                    f"{relationship_id or '(missing Id)'}: {type_error}",
                )
            )

        if target == "":
            results.append(
                fail(
                    package,
                    item_name,
                    "relationships",
                    f"{relationship_id or '(missing Id)'}: relationship Target must be non-empty",
                )
            )
            continue

        if target_mode == "External":
            continue
        if target_mode != "Internal":
            results.append(
                fail(
                    package,
                    item_name,
                    "relationships",
                    f"invalid TargetMode for {relationship_id}: {target_mode}",
                )
            )
            continue

        resolved, error = resolve_internal_target(source_part, target)
        if error:
            results.append(
                fail(
                    package,
                    item_name,
                    "relationships",
                    f"{relationship_id}: {error}: {target}",
                )
            )
            continue
        assert resolved is not None
        if is_reserved_relationship_part_name(resolved):
            results.append(
                fail(
                    package,
                    item_name,
                    "relationships",
                    f"{relationship_id}: relationships shall not target a Relationships part: {resolved}",
                )
            )
        elif resolved not in ordinary_parts:
            results.append(
                fail(
                    package,
                    item_name,
                    "relationships",
                    f"{relationship_id}: missing internal target part: {resolved}",
                )
            )

    return results


def read_relationship_entries(
    archive: zipfile.ZipFile,
    item_name: str,
    source_part: str | None,
) -> list[RelationshipEntry]:
    try:
        relationships_xml = archive.read(item_name)
    except KeyError:
        return []
    if validate_opc_xml_usage(relationships_xml):
        return []
    try:
        root = ET.fromstring(relationships_xml)
    except ET.ParseError:
        return []
    if root.tag != f"{{{RELATIONSHIPS_NS}}}Relationships":
        return []

    entries: list[RelationshipEntry] = []
    for relationship in root:
        if relationship.tag != f"{{{RELATIONSHIPS_NS}}}Relationship":
            continue
        target = relationship.get("Target", "")
        target_mode = relationship.get("TargetMode", "Internal")
        resolved_part = None
        if target and target_mode == "Internal":
            resolved_part, _ = resolve_internal_target(source_part, target)
        entries.append(
            RelationshipEntry(
                relationship.get("Id", ""),
                relationship.get("Type", ""),
                target,
                target_mode,
                resolved_part,
            )
        )
    return entries


def validate_opc_defined_xml_part(
    package: Path,
    archive: zipfile.ZipFile,
    item_name: str,
    content_type: str,
) -> list[ValidationResult]:
    if content_type not in OPC_DEFINED_XML_CONTENT_TYPES:
        return []
    xml_usage_error = validate_opc_xml_usage(archive.read(item_name))
    if xml_usage_error is None:
        return []
    return [fail(package, item_name, "xml-usage", xml_usage_error)]


def validate_core_properties_contract(
    package: Path,
    package_relationships: list[RelationshipEntry],
    core_properties_parts: set[str],
    defaults: dict[str, str],
    overrides: dict[str, str],
) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    if len(core_properties_parts) > 1:
        results.append(
            fail(
                package,
                "(package)",
                "core-properties",
                f"package must contain at most one Core Properties part: {len(core_properties_parts)}",
            )
        )

    core_relationships = [
        relationship
        for relationship in package_relationships
        if relationship.relationship_type == CORE_PROPERTIES_RELATIONSHIP_TYPE
    ]
    if len(core_relationships) > 1:
        results.append(
            fail(
                package,
                RELATIONSHIPS_ROOT,
                "core-properties",
                f"package must contain at most one core properties relationship: {len(core_relationships)}",
            )
        )

    referenced_core_parts: set[str] = set()
    for relationship in core_relationships:
        if relationship.target_mode != "Internal":
            results.append(
                fail(
                    package,
                    RELATIONSHIPS_ROOT,
                    "core-properties",
                    f"{relationship.relationship_id or '(missing Id)'}: core properties relationship must target an internal part",
                )
            )
            continue
        target_part = relationship.resolved_part
        if target_part is None:
            continue
        target_item = item_name_for_part(target_part)
        content_type = content_type_for_item(target_item, defaults, overrides)
        if content_type != CORE_PROPERTIES_CONTENT_TYPE:
            results.append(
                fail(
                    package,
                    RELATIONSHIPS_ROOT,
                    "core-properties",
                    f"{relationship.relationship_id or '(missing Id)'}: core properties target must have content type {CORE_PROPERTIES_CONTENT_TYPE}",
                )
            )
            continue
        referenced_core_parts.add(target_part)

    for part_name in sorted(core_properties_parts - referenced_core_parts):
        results.append(
            fail(
                package,
                part_name,
                "core-properties",
                "Core Properties part must be referenced by a package core properties relationship",
            )
        )
    return results


def validate_digital_signature_contract(
    package: Path,
    archive: zipfile.ZipFile,
    package_relationships: list[RelationshipEntry],
    digital_signature_origin_parts: set[str],
    digital_signature_xml_signature_parts: set[str],
    defaults: dict[str, str],
    overrides: dict[str, str],
) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    if len(digital_signature_origin_parts) > 1:
        results.append(
            fail(
                package,
                "(package)",
                "digital-signature",
                f"package must contain at most one Digital Signature Origin part: {len(digital_signature_origin_parts)}",
            )
        )

    origin_relationships = [
        relationship
        for relationship in package_relationships
        if relationship.relationship_type == DIGITAL_SIGNATURE_ORIGIN_RELATIONSHIP_TYPE
    ]
    referenced_origins: set[str] = set()
    for relationship in origin_relationships:
        if relationship.target_mode != "Internal":
            results.append(
                fail(
                    package,
                    RELATIONSHIPS_ROOT,
                    "digital-signature",
                    f"{relationship.relationship_id or '(missing Id)'}: Digital Signature Origin relationship must target an internal part",
                )
            )
            continue
        target_part = relationship.resolved_part
        if target_part is None:
            continue
        target_item = item_name_for_part(target_part)
        content_type = content_type_for_item(target_item, defaults, overrides)
        if content_type != DIGITAL_SIGNATURE_ORIGIN_CONTENT_TYPE:
            results.append(
                fail(
                    package,
                    RELATIONSHIPS_ROOT,
                    "digital-signature",
                    f"{relationship.relationship_id or '(missing Id)'}: Digital Signature Origin relationship target must have content type {DIGITAL_SIGNATURE_ORIGIN_CONTENT_TYPE}",
                )
            )
            continue
        referenced_origins.add(target_part)

    if digital_signature_xml_signature_parts and not digital_signature_origin_parts:
        results.append(
            fail(
                package,
                "(package)",
                "digital-signature",
                "Digital Signature Origin part must exist when Digital Signature XML Signature parts exist",
            )
        )

    for origin_part in sorted(digital_signature_origin_parts - referenced_origins):
        results.append(
            fail(
                package,
                origin_part,
                "digital-signature",
                "Digital Signature Origin part must be targeted by a package Digital Signature Origin relationship",
            )
        )

    referenced_signatures: set[str] = set()
    for origin_part in sorted(digital_signature_origin_parts):
        origin_item = item_name_for_part(origin_part)
        if archive.read(origin_item):
            results.append(
                fail(
                    package,
                    origin_part,
                    "digital-signature",
                    "Digital Signature Origin part content must be empty",
                )
            )

        origin_relationship_item = relationships_item_for_source_part(origin_part)
        for relationship in read_relationship_entries(
            archive,
            origin_relationship_item,
            origin_part,
        ):
            if relationship.relationship_type != DIGITAL_SIGNATURE_RELATIONSHIP_TYPE:
                continue
            if relationship.target_mode != "Internal":
                results.append(
                    fail(
                        package,
                        origin_relationship_item,
                        "digital-signature",
                        f"{relationship.relationship_id or '(missing Id)'}: Digital Signature relationship must target an internal XML Signature part",
                    )
                )
                continue
            target_part = relationship.resolved_part
            if target_part is None:
                continue
            target_item = item_name_for_part(target_part)
            content_type = content_type_for_item(target_item, defaults, overrides)
            if content_type != DIGITAL_SIGNATURE_XML_SIGNATURE_CONTENT_TYPE:
                results.append(
                    fail(
                        package,
                        origin_relationship_item,
                        "digital-signature",
                        f"{relationship.relationship_id or '(missing Id)'}: Digital Signature relationship target must have content type {DIGITAL_SIGNATURE_XML_SIGNATURE_CONTENT_TYPE}",
                    )
                )
                continue
            referenced_signatures.add(target_part)

    for signature_part in sorted(
        digital_signature_xml_signature_parts - referenced_signatures
    ):
        results.append(
            fail(
                package,
                signature_part,
                "digital-signature",
                "Digital Signature XML Signature part must be targeted by a Digital Signature relationship from the Origin part",
            )
        )
    return results


def validate_package(package: Path) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    try:
        with zipfile.ZipFile(package) as archive:
            names = [info.filename for info in archive.infolist()]
            file_names = [name for name in names if not name.endswith("/")]

            for name in names:
                if any(ord(character) > 0x7F for character in name):
                    results.append(
                        fail(package, name, "zip", "ZIP item name must use ASCII characters")
                    )

            for name, count in Counter(names).items():
                if count > 1:
                    results.append(fail(package, name, "zip", f"duplicate ZIP item: {count} entries"))

            defaults, overrides, content_type_results = parse_content_types(package, archive)
            results.extend(content_type_results)

            ordinary_items: list[str] = []
            relationship_items: list[str] = []
            for item_name in file_names:
                if item_name == CONTENT_TYPES_PART:
                    continue
                if item_name.startswith("/") or "\\" in item_name:
                    results.append(
                        fail(package, item_name, "zip", "ZIP item name must be relative and use '/'")
                    )
                    continue
                if is_relationships_item(item_name):
                    relationship_items.append(item_name)
                else:
                    ordinary_items.append(item_name)

            ordinary_parts = {part_name_for_item(item_name) for item_name in ordinary_items}

            for part_name in sorted(ordinary_parts):
                error = validate_part_name(part_name)
                if error:
                    results.append(fail(package, part_name, "part-name", error))
                if is_reserved_relationship_part_name(part_name):
                    results.append(
                        fail(
                            package,
                            part_name,
                            "part-name",
                            "ordinary part uses reserved Relationships part name",
                        )
                    )

            folded = [ascii_case_key(part) for part in ordinary_parts]
            for part_name, count in Counter(folded).items():
                if count > 1:
                    results.append(
                        fail(
                            package,
                            "(package)",
                            "part-name",
                            f"part names are not ASCII-case-insensitively unique: {part_name}",
                        )
                    )

            sorted_parts = sorted(ordinary_parts, key=lambda value: (len(value), ascii_case_key(value)))
            for i, base in enumerate(sorted_parts):
                base_folded = ascii_case_key(base)
                for candidate in sorted_parts[i + 1 :]:
                    candidate_folded = ascii_case_key(candidate)
                    if candidate_folded.startswith(base_folded + "/"):
                        results.append(
                            fail(
                                package,
                                candidate,
                                "part-name",
                                f"part name is derivable from another part name: {base}",
                            )
                        )

            all_known_part_names = {
                ascii_case_key(part_name_for_item(item_name))
                for item_name in set(ordinary_items) | set(relationship_items)
            }
            for part_name in sorted(overrides):
                if not part_name:
                    continue
                if part_name not in all_known_part_names:
                    results.append(
                        fail(
                            package,
                            CONTENT_TYPES_PART,
                            "content-types",
                            f"Override points to missing ZIP item: {part_name}",
                        )
                    )

            for item_name in sorted(ordinary_items):
                content_type = content_type_for_item(item_name, defaults, overrides)
                if content_type is None:
                    results.append(
                        fail(
                            package,
                            item_name,
                            "content-types",
                            "missing content type Default/Override",
                        )
                    )
                else:
                    results.extend(
                        validate_opc_defined_xml_part(
                            package,
                            archive,
                            item_name,
                            content_type,
                        )
                    )

            package_relationships = read_relationship_entries(
                archive,
                RELATIONSHIPS_ROOT,
                None,
            )
            core_properties_parts = {
                part_name_for_item(item_name)
                for item_name in ordinary_items
                if content_type_for_item(item_name, defaults, overrides)
                == CORE_PROPERTIES_CONTENT_TYPE
            }
            results.extend(
                validate_core_properties_contract(
                    package,
                    package_relationships,
                    core_properties_parts,
                    defaults,
                    overrides,
                )
            )
            digital_signature_origin_parts = {
                part_name_for_item(item_name)
                for item_name in ordinary_items
                if content_type_for_item(item_name, defaults, overrides)
                == DIGITAL_SIGNATURE_ORIGIN_CONTENT_TYPE
            }
            digital_signature_xml_signature_parts = {
                part_name_for_item(item_name)
                for item_name in ordinary_items
                if content_type_for_item(item_name, defaults, overrides)
                == DIGITAL_SIGNATURE_XML_SIGNATURE_CONTENT_TYPE
            }
            results.extend(
                validate_digital_signature_contract(
                    package,
                    archive,
                    package_relationships,
                    digital_signature_origin_parts,
                    digital_signature_xml_signature_parts,
                    defaults,
                    overrides,
                )
            )

            for item_name in sorted(relationship_items):
                source_part = relationships_source_part(item_name)
                if source_part == "":
                    results.append(
                        fail(
                            package,
                            item_name,
                            "relationships",
                            "invalid Relationships part item name",
                        )
                    )
                    continue
                if source_part is not None:
                    if source_part not in ordinary_parts:
                        results.append(
                            fail(
                                package,
                                item_name,
                                "relationships",
                                f"Relationships part source does not exist: {source_part}",
                            )
                        )
                    if is_reserved_relationship_part_name(source_part):
                        results.append(
                            fail(
                                package,
                                item_name,
                                "relationships",
                                f"Relationships part source is itself reserved: {source_part}",
                            )
                        )

                content_type = content_type_for_item(item_name, defaults, overrides)
                if content_type != RELATIONSHIPS_CONTENT_TYPE:
                    results.append(
                        fail(
                            package,
                            item_name,
                            "content-types",
                            f"Relationships part content type must be {RELATIONSHIPS_CONTENT_TYPE}",
                        )
                    )

                results.extend(
                    validate_relationships_part(
                        package,
                        archive,
                        item_name,
                        source_part,
                        ordinary_parts,
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
