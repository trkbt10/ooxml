#!/usr/bin/env python3
"""Measure ECMA-376 element occurrence coverage in generated OOXML fixtures.

The XSD identifier audit proves that schema identifiers are represented in the
implementation surface. This script measures a different axis: which ECMA-376
XML element QNames actually appear in generated `.docx`, `.xlsx`, and `.pptx`
fixture packages.

The comparison is intentionally QName-based. It does not prove that every
schema declaration with the same QName is exercised in every content-model
position, nor that semantics, visual fidelity, or Office / LibreOffice
round-trips are correct.

Usage:
  python3 scripts/ooxml_fixture_element_coverage.py --all-fixtures
  python3 scripts/ooxml_fixture_element_coverage.py --all-fixtures --json
  python3 scripts/ooxml_fixture_element_coverage.py path/to/file.docx
"""

from __future__ import annotations

import argparse
import json
import sys
import zipfile
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET


REPO = Path(__file__).resolve().parents[1]
DEFAULT_CATALOG = REPO / ".snapshots" / "catalog.json"
FIXTURE_ROOT = REPO / ".snapshots" / "fixtures"

TRANSITIONAL_NS_PREFIX = "http://schemas.openxmlformats.org/"
STRICT_NS_PREFIX = "http://purl.oclc.org/ooxml/"
GENERATION_MARKER_TAILS = (
    "drawingml/2006/",
    "officeDocument/2006/",
    "presentationml/2006/",
    "schemaLibrary/2006/",
    "spreadsheetml/2006/",
    "wordprocessingml/2006/",
)

OOXML_EXTENSIONS = {".docx", ".xlsx", ".pptx"}
XML_PART_SUFFIXES = (".xml", ".rels")


@dataclass(frozen=True, order=True)
class ElementKey:
    namespace: str
    local_name: str


@dataclass(frozen=True)
class CatalogElement:
    id: str
    key: ElementKey
    element: str
    type_name: str
    format_name: str | None
    lineage: tuple[str, ...]


@dataclass
class SeenElement:
    count: int
    packages: set[str]
    parts: set[str]
    examples: list[tuple[str, str]]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="*", help="OOXML package files to scan")
    parser.add_argument(
        "--all-fixtures",
        action="store_true",
        help="scan every .docx/.xlsx/.pptx under .snapshots/fixtures",
    )
    parser.add_argument(
        "--catalog",
        default=str(DEFAULT_CATALOG),
        help="catalog.json produced by src/cmd/catalog",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="write machine-readable coverage data",
    )
    parser.add_argument(
        "--fail-on-missing",
        action="store_true",
        help="exit non-zero when any catalog QName is absent from scanned fixtures",
    )
    parser.add_argument(
        "--missing-limit",
        type=int,
        default=80,
        help="maximum missing QNames to print in text output",
    )
    return parser.parse_args()


def normalise_namespace(namespace: str) -> str:
    """Collapse Strict and Transitional ECMA namespace generations."""
    if namespace.startswith(TRANSITIONAL_NS_PREFIX):
        tail = namespace[len(TRANSITIONAL_NS_PREFIX) :]
        return "ooxml:" + normalise_ecma_namespace_tail(tail)
    if namespace.startswith(STRICT_NS_PREFIX):
        tail = namespace[len(STRICT_NS_PREFIX) :]
        return "ooxml:" + normalise_ecma_namespace_tail(tail)
    return namespace


def normalise_ecma_namespace_tail(tail: str) -> str:
    """Remove generation-only `/2006/` segments from ECMA ML namespaces."""
    for marker in GENERATION_MARKER_TAILS:
        if tail.startswith(marker):
            return marker.replace("/2006/", "/") + tail[len(marker) :]
    return tail


def element_key(namespace: str, local_name: str) -> ElementKey:
    return ElementKey(normalise_namespace(namespace), local_name)


def split_tag(tag: str) -> ElementKey:
    if tag.startswith("{"):
        namespace, local_name = tag[1:].split("}", 1)
        return element_key(namespace, local_name)
    return element_key("", tag)


def load_catalog(path: Path) -> list[CatalogElement]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except OSError as error:
        raise SystemExit(f"fixture coverage: cannot read catalog {path}: {error}")
    except json.JSONDecodeError as error:
        raise SystemExit(f"fixture coverage: cannot parse catalog {path}: {error}")

    entries = data.get("entries")
    if not isinstance(entries, list):
        raise SystemExit(f"fixture coverage: catalog {path} has no entries array")

    elements: list[CatalogElement] = []
    for entry in entries:
        if not isinstance(entry, dict):
            continue
        namespace = entry.get("namespace")
        element = entry.get("element")
        if not isinstance(namespace, str) or not isinstance(element, str):
            continue
        lineage = entry.get("lineage")
        if not isinstance(lineage, list):
            lineage_values: tuple[str, ...] = ()
        else:
            lineage_values = tuple(str(value) for value in lineage)
        format_name = entry.get("format")
        elements.append(
            CatalogElement(
                id=str(entry.get("id", element)),
                key=element_key(namespace, element),
                element=element,
                type_name=str(entry.get("type", "")),
                format_name=format_name if isinstance(format_name, str) else None,
                lineage=lineage_values,
            )
        )
    return elements


def collect_packages(args: argparse.Namespace) -> list[Path]:
    if args.all_fixtures:
        packages = sorted(
            path
            for extension in OOXML_EXTENSIONS
            for path in FIXTURE_ROOT.rglob(f"*{extension}")
        )
        if packages:
            return packages

    if args.files:
        return [Path(value).resolve() for value in args.files]

    raise SystemExit(
        "fixture coverage: pass --all-fixtures or one or more OOXML package files"
    )


def is_xml_part(part_name: str) -> bool:
    return part_name == "[Content_Types].xml" or part_name.endswith(XML_PART_SUFFIXES)


def scan_package(path: Path) -> tuple[Counter[ElementKey], list[tuple[str, str]]]:
    counts: Counter[ElementKey] = Counter()
    parse_errors: list[tuple[str, str]] = []
    try:
        with zipfile.ZipFile(path) as archive:
            for info in archive.infolist():
                if info.is_dir() or not is_xml_part(info.filename):
                    continue
                try:
                    root = ET.fromstring(archive.read(info))
                except ET.ParseError as error:
                    parse_errors.append((info.filename, str(error)))
                    continue
                for element in root.iter():
                    counts[split_tag(element.tag)] += 1
    except zipfile.BadZipFile as error:
        parse_errors.append(("(package)", str(error)))
    return counts, parse_errors


def audit(catalog_path: Path, package_paths: list[Path]) -> dict:
    catalog = load_catalog(catalog_path)
    declared_by_key: dict[ElementKey, list[CatalogElement]] = defaultdict(list)
    for entry in catalog:
        declared_by_key[entry.key].append(entry)

    seen: dict[ElementKey, SeenElement] = {}
    package_parse_errors: dict[str, list[tuple[str, str]]] = {}
    xml_part_count = 0

    for package_path in package_paths:
        counts, parse_errors = scan_package(package_path)
        if parse_errors:
            package_parse_errors[str(package_path)] = parse_errors
        if not counts:
            continue
        try:
            with zipfile.ZipFile(package_path) as archive:
                xml_part_count += sum(
                    1
                    for info in archive.infolist()
                    if not info.is_dir() and is_xml_part(info.filename)
                )
        except zipfile.BadZipFile:
            pass

        package_label = str(package_path.relative_to(REPO)) if package_path.is_relative_to(REPO) else str(package_path)
        for key, count in counts.items():
            item = seen.get(key)
            if item is None:
                item = SeenElement(0, set(), set(), [])
                seen[key] = item
            item.count += count
            item.packages.add(package_label)
            item.parts.add(package_label)
            if len(item.examples) < 3:
                item.examples.append((package_label, key.local_name))

    declared_keys = set(declared_by_key)
    seen_keys = set(seen)
    covered_keys = declared_keys & seen_keys
    missing_keys = declared_keys - seen_keys

    by_namespace: dict[str, dict[str, int]] = {}
    for namespace in sorted(key.namespace for key in declared_keys):
        declared_namespace_keys = {key for key in declared_keys if key.namespace == namespace}
        covered_namespace_keys = declared_namespace_keys & covered_keys
        by_namespace[namespace] = {
            "declared_qnames": len(declared_namespace_keys),
            "covered_qnames": len(covered_namespace_keys),
            "missing_qnames": len(declared_namespace_keys - covered_namespace_keys),
            "seen_occurrences": sum(
                seen[key].count for key in covered_namespace_keys if key in seen
            ),
        }

    declaration_entries_seen = [
        entry for entry in catalog if entry.key in covered_keys
    ]
    declaration_entries_missing = [
        entry for entry in catalog if entry.key in missing_keys
    ]

    return {
        "catalog": str(catalog_path),
        "packages_scanned": len(package_paths),
        "xml_parts_scanned": xml_part_count,
        "declared_entries": len(catalog),
        "declared_qnames": len(declared_keys),
        "covered_qnames": len(covered_keys),
        "missing_qnames": len(missing_keys),
        "declaration_entries_seen_by_qname": len(declaration_entries_seen),
        "declaration_entries_missing_by_qname": len(declaration_entries_missing),
        "observed_qnames": len(seen_keys),
        "observed_ooxml_qnames": len(seen_keys & declared_keys),
        "observed_non_catalog_qnames": len(seen_keys - declared_keys),
        "by_namespace": by_namespace,
        "missing": [
            {
                "namespace": key.namespace,
                "element": key.local_name,
                "declaration_count": len(declared_by_key[key]),
                "examples": [
                    {
                        "id": entry.id,
                        "type": entry.type_name,
                        "format": entry.format_name,
                        "lineage": list(entry.lineage),
                    }
                    for entry in declared_by_key[key][:5]
                ],
            }
            for key in sorted(missing_keys)
        ],
        "parse_errors": package_parse_errors,
    }


def percent(covered: int, total: int) -> str:
    if total == 0:
        return "-"
    return f"{100 * covered / total:.1f}%"


def print_text(result: dict, missing_limit: int) -> None:
    print("ECMA-376 fixture element occurrence coverage")
    print("")
    print(f"catalog: {result['catalog']}")
    print(f"packages scanned: {result['packages_scanned']}")
    print(f"xml parts scanned: {result['xml_parts_scanned']}")
    print("")
    print("| Measure | Covered | Total | Coverage |")
    print("|---|---:|---:|---:|")
    print(
        "| catalog QNames observed in fixtures | "
        f"{result['covered_qnames']} | {result['declared_qnames']} | "
        f"{percent(result['covered_qnames'], result['declared_qnames'])} |"
    )
    print(
        "| catalog declaration entries observed by QName | "
        f"{result['declaration_entries_seen_by_qname']} | {result['declared_entries']} | "
        f"{percent(result['declaration_entries_seen_by_qname'], result['declared_entries'])} |"
    )
    print(
        "| observed QNames that are catalog ECMA QNames | "
        f"{result['observed_ooxml_qnames']} | {result['observed_qnames']} | "
        f"{percent(result['observed_ooxml_qnames'], result['observed_qnames'])} |"
    )
    print("")
    print("| Namespace | Covered QNames | Declared QNames | Missing | Occurrences |")
    print("|---|---:|---:|---:|---:|")
    for namespace, row in sorted(
        result["by_namespace"].items(),
        key=lambda item: (-item[1]["missing_qnames"], item[0]),
    ):
        print(
            f"| {namespace or '(none)'} | {row['covered_qnames']} | "
            f"{row['declared_qnames']} | {row['missing_qnames']} | "
            f"{row['seen_occurrences']} |"
        )

    if result["parse_errors"]:
        print("")
        print("Parse errors:")
        for package, errors in result["parse_errors"].items():
            for part, message in errors[:5]:
                print(f"- {package} :: {part}: {message}")

    if missing_limit != 0 and result["missing"]:
        print("")
        print(f"Missing catalog QNames (first {missing_limit}):")
        for item in result["missing"][:missing_limit]:
            print(
                "- "
                + (item["namespace"] or "(none)")
                + " "
                + item["element"]
                + f" ({item['declaration_count']} declaration"
                + ("s" if item["declaration_count"] != 1 else "")
                + ")"
            )


def main() -> int:
    args = parse_args()
    result = audit(Path(args.catalog).resolve(), collect_packages(args))
    if args.json:
        json.dump(result, sys.stdout, indent=2, sort_keys=True)
        print()
    else:
        print_text(result, args.missing_limit)

    if args.fail_on_missing and result["missing_qnames"]:
        return 1
    if result["parse_errors"]:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
