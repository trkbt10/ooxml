#!/usr/bin/env python3
"""ECMA-376 / OOXML XSD identifier coverage audit.

Walk the locally vendored ECMA-376 Strict, Transitional, and OPC XSD
schema sets under references/raw/ and compare their public normative
identifiers with public MoonBit declarations under src/ecma376/.

The report is intentionally an identifier-presence audit. It does not
prove child sequence validation, cardinality validation, OPC relationship
soundness, or Microsoft Office / LibreOffice round-trip interoperability.

Usage:
  python3 scripts/ecma376_xsd_coverage.py
  python3 scripts/ecma376_xsd_coverage.py --json
  python3 scripts/ecma376_xsd_coverage.py --fail-on-missing
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from xml.etree import ElementTree as ET


REPO = Path(__file__).resolve().parents[1]
SRC_DIR = REPO / "src" / "ecma376"
DOCS = REPO / "docs"
XSD_NS = "http://www.w3.org/2001/XMLSchema"

SCHEMA_SETS = [
    {
        "key": "strict",
        "title": "ECMA-376 Part 1 Strict XSD",
        "path": REPO
        / "references"
        / "raw"
        / "ecma376-1"
        / "OfficeOpenXML-XMLSchema-Strict",
    },
    {
        "key": "transitional",
        "title": "ECMA-376 Part 4 Transitional XSD",
        "path": REPO
        / "references"
        / "raw"
        / "ecma376-4"
        / "OfficeOpenXML-XMLSchema-Transitional",
    },
    {
        "key": "opc",
        "title": "ECMA-376 Part 2 OPC XSD",
        "path": REPO
        / "references"
        / "raw"
        / "ecma376-2"
        / "OpenPackagingConventions-XMLSchema",
    },
]

PUB_PATTERN = re.compile(
    r"^pub(?:\(all\))?\s+"
    r"(?:struct|enum|type|typealias|fn)\s+"
    r"([A-Za-z_][A-Za-z_0-9]*)",
    re.MULTILINE,
)

# Per-schema synonyms for identifiers whose canonical implementation name
# is intentionally more domain-specific than the raw XSD identifier.
SYNONYMS = {
    ("dml-main.xsd", "graphic"): ("read_graphical_object",),
    ("dml-main.xsd", "tbl"): ("read_table",),
    ("dml-main.xsd", "tblStyleLst"): ("read_table_style_list",),
    ("shared-documentPropertiesCustom.xsd", "Properties"): (
        "CustomProperties",
        "read_custom_properties",
    ),
    ("shared-documentPropertiesExtended.xsd", "Properties"): (
        "ExtendedProperties",
        "read_extended_properties",
    ),
    ("opc-contentTypes.xsd", "Default"): ("CT_Default",),
    ("opc-contentTypes.xsd", "Override"): ("CT_Override",),
    ("opc-contentTypes.xsd", "Types"): ("CT_Types", "read_content_types"),
    ("opc-relationships.xsd", "Relationship"): ("CT_Relationship",),
    ("opc-relationships.xsd", "Relationships"): (
        "CT_Relationships",
        "read_relationships",
    ),
}


def xsd_ids(path: Path) -> dict:
    """Return complex type, simple type, and top-level element names."""
    try:
        tree = ET.parse(path)
    except ET.ParseError as error:
        return {
            "error": f"parse: {error}",
            "complex_types": [],
            "simple_types": [],
            "elements": [],
        }

    root = tree.getroot()
    complex_types = sorted(
        element.get("name")
        for element in root.iter(f"{{{XSD_NS}}}complexType")
        if element.get("name")
    )
    simple_types = sorted(
        element.get("name")
        for element in root.iter(f"{{{XSD_NS}}}simpleType")
        if element.get("name")
    )
    elements = sorted(
        element.get("name")
        for element in root.findall(f"{{{XSD_NS}}}element")
        if element.get("name")
    )
    return {
        "complex_types": complex_types,
        "simple_types": simple_types,
        "elements": elements,
    }


def impl_identifiers(src_dir: Path) -> set[str]:
    """Collect public declaration names across src/ecma376/."""
    names: set[str] = set()
    for mbt in src_dir.rglob("*.mbt"):
        if mbt.name.endswith("_wbtest.mbt") or mbt.name.endswith("_test.mbt"):
            continue
        try:
            text = mbt.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        names.update(match.group(1) for match in PUB_PATTERN.finditer(text))
    return names


def to_snake(value: str) -> str:
    """Convert camelCase / PascalCase to snake_case."""
    step1 = re.sub(r"(.)([A-Z][a-z]+)", r"\1_\2", value)
    step2 = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", step1)
    return step2.lower()


def matches(xsd_id: str, impl_names: set[str], schema_name: str) -> bool:
    """Return whether an XSD identifier has an implementation declaration."""
    if xsd_id in impl_names:
        return True

    for alias in SYNONYMS.get((schema_name, xsd_id), ()):
        if alias in impl_names:
            return True

    if (
        xsd_id.startswith("CT_")
        or xsd_id.startswith("ST_")
        or xsd_id.startswith("EG_")
        or xsd_id.startswith("AG_")
    ):
        return False

    if f"read_{xsd_id}" in impl_names:
        return True

    snake = to_snake(xsd_id)
    if f"read_{snake}" in impl_names:
        return True

    return False


def audit() -> dict:
    impl_names = impl_identifiers(SRC_DIR)
    schema_sets = {}
    for schema_set in SCHEMA_SETS:
        schemas = {}
        xsd_dir = schema_set["path"]
        for xsd in sorted(xsd_dir.glob("*.xsd")):
            ids = xsd_ids(xsd)
            if "error" in ids:
                schemas[xsd.name] = ids
                continue
            per_schema = {
                "complex_types": {},
                "simple_types": {},
                "elements": {},
            }
            for kind in ("complex_types", "simple_types", "elements"):
                for name in ids[kind]:
                    per_schema[kind][name] = matches(name, impl_names, xsd.name)
            schemas[xsd.name] = per_schema
        schema_sets[schema_set["key"]] = {
            "title": schema_set["title"],
            "path": str(xsd_dir.relative_to(REPO)),
            "schemas": schemas,
        }
    return {"schema_sets": schema_sets, "impl_count": len(impl_names)}


def summarise_schema_set(schema_set: dict) -> list[tuple]:
    rows = []
    for schema_name, schema in schema_set["schemas"].items():
        if "error" in schema:
            rows.append((schema_name, 0, 0, 0, 0, 0, 0, schema["error"]))
            continue
        complex_types = schema["complex_types"]
        simple_types = schema["simple_types"]
        elements = schema["elements"]
        rows.append(
            (
                schema_name,
                sum(1 for value in complex_types.values() if value),
                len(complex_types),
                sum(1 for value in simple_types.values() if value),
                len(simple_types),
                sum(1 for value in elements.values() if value),
                len(elements),
                "",
            )
        )
    return rows


def missing_identifiers(audit_data: dict) -> list[tuple[str, str, str, str]]:
    missing = []
    for set_key, schema_set in audit_data["schema_sets"].items():
        for schema_name, schema in schema_set["schemas"].items():
            if "error" in schema:
                missing.append((set_key, schema_name, "parse_error", schema["error"]))
                continue
            for kind in ("complex_types", "simple_types", "elements"):
                for name, covered in schema[kind].items():
                    if not covered:
                        missing.append((set_key, schema_name, kind, name))
    return missing


def percent(covered: int, total: int) -> str:
    if total == 0:
        return "-"
    return f"{100 * covered / total:.0f}%"


def markdown(audit_data: dict) -> str:
    lines: list[str] = []
    impl_count = audit_data["impl_count"]
    lines.append("# ECMA-376 XSD coverage audit")
    lines.append("")
    lines.append("Generated by `scripts/ecma376_xsd_coverage.py`.")
    lines.append("")
    lines.append(
        "This report walks the locally vendored ECMA-376 Strict, "
        "Transitional, and OPC XSD schemas under `references/raw/` and "
        f"the {impl_count:,} public declarations under `src/ecma376/`."
    )
    lines.append("")
    lines.append(
        "It measures identifier presence for complex types, simple types, "
        "and top-level elements. It is not a proof that every child sequence, "
        "cardinality rule, relationship rule, or Microsoft Office / "
        "LibreOffice round trip is valid."
    )
    lines.append("")
    lines.append(
        "Use this alongside `docs/ECMA376_SDD_COVERAGE.md`, parser/builder "
        "tests, package validation, and office-suite smoke tests."
    )
    lines.append("")

    grand_ct_c = grand_ct_t = 0
    grand_st_c = grand_st_t = 0
    grand_el_c = grand_el_t = 0
    for set_key, schema_set in audit_data["schema_sets"].items():
        rows = summarise_schema_set(schema_set)
        lines.append(f"## {schema_set['title']}")
        lines.append("")
        lines.append(f"Source: `{schema_set['path']}`.")
        lines.append("")
        lines.append("| Schema | CT covered | ST covered | EL covered |")
        lines.append("|---|---|---|---|")
        total_ct_c = total_ct_t = 0
        total_st_c = total_st_t = 0
        total_el_c = total_el_t = 0
        for schema_name, ct_c, ct_t, st_c, st_t, el_c, el_t, error in rows:
            if error:
                lines.append(f"| {schema_name} | parse error: {error} | | |")
                continue
            total_ct_c += ct_c
            total_ct_t += ct_t
            total_st_c += st_c
            total_st_t += st_t
            total_el_c += el_c
            total_el_t += el_t
            lines.append(
                f"| {schema_name} | {ct_c}/{ct_t} ({percent(ct_c, ct_t)}) "
                f"| {st_c}/{st_t} ({percent(st_c, st_t)}) "
                f"| {el_c}/{el_t} ({percent(el_c, el_t)}) |"
            )
        lines.append("|---|---|---|---|")
        lines.append(
            f"| **{set_key} total** "
            f"| **{total_ct_c}/{total_ct_t} ({percent(total_ct_c, total_ct_t)})** "
            f"| **{total_st_c}/{total_st_t} ({percent(total_st_c, total_st_t)})** "
            f"| **{total_el_c}/{total_el_t} ({percent(total_el_c, total_el_t)})** |"
        )
        lines.append("")
        grand_ct_c += total_ct_c
        grand_ct_t += total_ct_t
        grand_st_c += total_st_c
        grand_st_t += total_st_t
        grand_el_c += total_el_c
        grand_el_t += total_el_t

    missing = missing_identifiers(audit_data)
    lines.append("## Grand Total")
    lines.append("")
    lines.append("| CT covered | ST covered | EL covered | Missing identifiers |")
    lines.append("|---|---|---|---|")
    lines.append(
        f"| **{grand_ct_c}/{grand_ct_t} ({percent(grand_ct_c, grand_ct_t)})** "
        f"| **{grand_st_c}/{grand_st_t} ({percent(grand_st_c, grand_st_t)})** "
        f"| **{grand_el_c}/{grand_el_t} ({percent(grand_el_c, grand_el_t)})** "
        f"| **{'yes' if missing else 'no'}** |"
    )

    if missing:
        lines.append("")
        lines.append("## Missing Identifiers")
        lines.append("")
        for set_key, schema_name, kind, name in missing:
            lines.append(f"- `{set_key}` `{schema_name}` `{kind}` `{name}`")

    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help="emit JSON")
    parser.add_argument(
        "--output",
        default=str(DOCS / "ECMA376_XSD_COVERAGE.md"),
        help="markdown output path",
    )
    parser.add_argument(
        "--fail-on-missing",
        action="store_true",
        help="exit non-zero when any identifier is missing",
    )
    args = parser.parse_args()

    data = audit()
    missing = missing_identifiers(data)

    if args.json:
        json.dump(data, sys.stdout, indent=2, ensure_ascii=False)
        sys.stdout.write("\n")
    else:
        output = Path(args.output)
        output.write_text(markdown(data), encoding="utf-8")
        print(f"wrote {output}")

    if args.fail_on_missing and missing:
        print(f"{len(missing)} missing identifiers", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
