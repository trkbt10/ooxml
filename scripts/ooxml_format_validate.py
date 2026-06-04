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


REPO = Path(__file__).resolve().parents[1]
CONTENT_TYPES_NS = "http://schemas.openxmlformats.org/package/2006/content-types"
RELATIONSHIPS_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
CONTENT_TYPES_PART = "[Content_Types].xml"
PACKAGE_RELS_PART = "_rels/.rels"

OD_REL_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
OD_REL_NS_STRICT = "http://purl.oclc.org/ooxml/officeDocument/relationships"
OD_REL_NAMESPACES = {OD_REL_NS_TRANSITIONAL, OD_REL_NS_STRICT}

WML_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
WML_NS_STRICT = "http://purl.oclc.org/ooxml/wordprocessingml/main"
SML_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
SML_NS_STRICT = "http://purl.oclc.org/ooxml/spreadsheetml/main"
PML_NS_TRANSITIONAL = "http://schemas.openxmlformats.org/presentationml/2006/main"
PML_NS_STRICT = "http://purl.oclc.org/ooxml/presentationml/main"

DOCX_MAIN_CT = "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"
XLSX_MAIN_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"
PPTX_MAIN_CT = "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"
WORKSHEET_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"
CHARTSHEET_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.chartsheet+xml"
DIALOGSHEET_CT = "application/vnd.openxmlformats-officedocument.spreadsheetml.dialogsheet+xml"
SLIDE_CT = "application/vnd.openxmlformats-officedocument.presentationml.slide+xml"
SLIDE_MASTER_CT = "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"

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
            defaults[extension] = content_type
        elif child.tag == f"{{{CONTENT_TYPES_NS}}}Override":
            part_name = child.get("PartName", "")
            content_type = child.get("ContentType", "")
            overrides[part_name] = content_type
    return defaults, overrides, []


def content_type_for_part(
    part_name: str,
    defaults: dict[str, str],
    overrides: dict[str, str],
) -> str | None:
    if part_name in overrides:
        return overrides[part_name]
    item_name = item_name_for_part(part_name)
    basename = item_name.rsplit("/", 1)[-1]
    if "." not in basename:
        return None
    extension = basename.rsplit(".", 1)[-1]
    return defaults.get(extension)


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


def parse_relationships(
    package: Path,
    archive: zipfile.ZipFile,
    item_name: str,
    source_part: str | None,
) -> tuple[dict[str, Relationship], list[ValidationResult]]:
    relationships: dict[str, Relationship] = {}
    try:
        root = ET.fromstring(archive.read(item_name))
    except KeyError:
        return relationships, [fail(package, item_name, "relationships", "missing")]
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
        root = ET.fromstring(archive.read(item_name_for_part(part_name)))
    except KeyError:
        return None, [fail(package, part_name, "part", "missing")]
    except ET.ParseError as error:
        return None, [fail(package, part_name, "xml-parse", str(error))]
    return root, []


def relationship_ref_id(element: ET.Element, local_name: str = "id") -> str | None:
    for namespace in OD_REL_NAMESPACES:
        value = element.get(f"{{{namespace}}}{local_name}")
        if value:
            return value
    return None


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
    if content_type not in contract.content_types:
        results.append(
            fail(
                package,
                target_part,
                check,
                f"{relationship_id}: unexpected content type: {content_type or '(missing)'}",
            )
        )

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
