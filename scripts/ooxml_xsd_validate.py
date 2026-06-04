#!/usr/bin/env python3
"""Validate OOXML package XML parts against vendored ECMA-376 XSD schemas.

This is stricter than the identifier coverage audit: it runs each package XML
part through xmllint with the ECMA-376 Strict, Transitional, and OPC schemas.
It still is not a complete package conformance verifier; OPC graph rules,
content-type cross-checking, Markup Compatibility processing, and visual
fidelity require separate gates.

Usage:
  python3 scripts/ooxml_xsd_validate.py
  python3 scripts/ooxml_xsd_validate.py path/to/file.docx path/to/file.xlsx
  python3 scripts/ooxml_xsd_validate.py --all-fixtures
  python3 scripts/ooxml_xsd_validate.py --json --allow-unknown path/to/file.pptx
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET


REPO = Path(__file__).resolve().parents[1]
XSD_NS = "http://www.w3.org/2001/XMLSchema"
XML_NS = "http://www.w3.org/XML/1998/namespace"

STRICT_XSD = (
    REPO
    / "references"
    / "raw"
    / "ecma376-1"
    / "OfficeOpenXML-XMLSchema-Strict"
)
TRANSITIONAL_XSD = (
    REPO
    / "references"
    / "raw"
    / "ecma376-4"
    / "OfficeOpenXML-XMLSchema-Transitional"
)
OPC_XSD = (
    REPO
    / "references"
    / "raw"
    / "ecma376-2"
    / "OpenPackagingConventions-XMLSchema"
)

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

XML_XSD = f"""<?xml version="1.0" encoding="UTF-8"?>
<xs:schema targetNamespace="{XML_NS}"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xml="{XML_NS}"
  elementFormDefault="qualified"
  attributeFormDefault="unqualified">
  <xs:attribute name="lang" type="xs:language"/>
  <xs:attribute name="space" default="preserve">
    <xs:simpleType>
      <xs:restriction base="xs:NCName">
        <xs:enumeration value="default"/>
        <xs:enumeration value="preserve"/>
      </xs:restriction>
    </xs:simpleType>
  </xs:attribute>
  <xs:attribute name="base" type="xs:anyURI"/>
  <xs:attribute name="id" type="xs:ID"/>
  <xs:attributeGroup name="specialAttrs">
    <xs:attribute ref="xml:base"/>
    <xs:attribute ref="xml:lang"/>
    <xs:attribute ref="xml:space"/>
    <xs:attribute ref="xml:id"/>
  </xs:attributeGroup>
</xs:schema>
"""


@dataclass(frozen=True)
class ValidationResult:
    package: str
    part: str
    status: str
    schema: str
    message: str


@dataclass(frozen=True)
class SchemaBinding:
    report_schema: Path
    validation_schema: Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="*", help="OOXML package files to validate")
    parser.add_argument(
        "--all-fixtures",
        action="store_true",
        help="validate every .docx/.xlsx/.pptx under .snapshots/fixtures",
    )
    parser.add_argument(
        "--allow-unknown",
        action="store_true",
        help="skip XML parts whose root namespace has no vendored ECMA-376 schema",
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
        help="print status and schema summaries after text output",
    )
    parser.add_argument(
        "--keep-tmp",
        action="store_true",
        help="keep the temporary schema/part directory for debugging",
    )
    parser.add_argument(
        "--xmllint",
        default="xmllint",
        help="xmllint executable path",
    )
    return parser.parse_args()


def ensure_xmllint(executable: str) -> str:
    resolved = shutil.which(executable)
    if not resolved:
        print(f"ooxml_xsd_validate.py: xmllint not found: {executable}", file=sys.stderr)
        sys.exit(2)
    return resolved


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
            "ooxml_xsd_validate.py: no input files and default fixtures are absent",
            file=sys.stderr,
        )
        print("Run 'moon run src/cmd/catalog -- fixtures' to generate fixtures.", file=sys.stderr)
        sys.exit(2)
    return paths


def patch_xml_imports(xsd: Path) -> None:
    text = xsd.read_text(encoding="utf-8-sig")
    pattern = re.compile(
        r'(<(?:xsd|xs):import\s+namespace=["\']'
        + re.escape(XML_NS)
        + r'["\'])([^>]*?)(/?>)',
        re.DOTALL,
    )

    def add_schema_location(match: re.Match[str]) -> str:
        attrs = match.group(2)
        if "schemaLocation" in attrs:
            return match.group(0)
        return f'{match.group(1)}{attrs} schemaLocation="xml.xsd"{match.group(3)}'

    patched = pattern.sub(add_schema_location, text)
    if patched != text:
        xsd.write_text(patched, encoding="utf-8")


def write_schema_set_wrapper(
    target: Path,
    namespace_to_schema: dict[str, Path],
) -> Path:
    imports: list[str] = []
    for namespace, schema in sorted(namespace_to_schema.items()):
        imports.append(
            f'  <xs:import namespace="{namespace}" schemaLocation="{schema.name}"/>'
        )
    wrapper = target / "__all__.xsd"
    wrapper.write_text(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        "<xs:schema xmlns:xs=\"http://www.w3.org/2001/XMLSchema\">\n"
        + "\n".join(imports)
        + "\n</xs:schema>\n",
        encoding="utf-8",
    )
    return wrapper


def copy_schema_set(
    source: Path,
    target: Path,
    use_wrapper: bool,
) -> dict[str, SchemaBinding]:
    target.mkdir(parents=True, exist_ok=True)
    for xsd in source.glob("*.xsd"):
        shutil.copy2(xsd, target / xsd.name)
    (target / "xml.xsd").write_text(XML_XSD, encoding="utf-8")
    namespace_to_schema: dict[str, Path] = {}
    for xsd in sorted(target.glob("*.xsd")):
        patch_xml_imports(xsd)
        try:
            root = ET.parse(xsd).getroot()
        except ET.ParseError:
            continue
        namespace = root.get("targetNamespace")
        if namespace:
            namespace_to_schema[namespace] = xsd
    wrapper = write_schema_set_wrapper(target, namespace_to_schema) if use_wrapper else None
    return {
        namespace: SchemaBinding(
            report_schema=schema,
            validation_schema=wrapper if wrapper is not None else schema,
        )
        for namespace, schema in namespace_to_schema.items()
    }


def prepare_schemas(tmp_root: Path) -> dict[str, SchemaBinding]:
    namespace_to_schema: dict[str, SchemaBinding] = {}
    namespace_to_schema.update(copy_schema_set(STRICT_XSD, tmp_root / "strict", use_wrapper=True))
    namespace_to_schema.update(
        copy_schema_set(TRANSITIONAL_XSD, tmp_root / "transitional", use_wrapper=True)
    )
    namespace_to_schema.update(copy_schema_set(OPC_XSD, tmp_root / "opc", use_wrapper=False))
    return namespace_to_schema


def root_namespace(xml_bytes: bytes) -> tuple[str | None, str | None]:
    root = ET.fromstring(xml_bytes)
    if root.tag.startswith("{"):
        namespace, local = root.tag[1:].split("}", 1)
        return namespace, local
    return None, root.tag


def part_output_path(parts_root: Path, package: Path, part: str) -> Path:
    package_stem = package.name.replace("/", "_")
    safe_part = part.replace("/", "__").replace("[", "_").replace("]", "_")
    out = parts_root / package_stem / safe_part
    out.parent.mkdir(parents=True, exist_ok=True)
    return out


def validate_part(
    xmllint: str,
    package: Path,
    part: str,
    xml_bytes: bytes,
    binding: SchemaBinding,
    parts_root: Path,
) -> ValidationResult:
    part_file = part_output_path(parts_root, package, part)
    part_file.write_bytes(xml_bytes)
    command = [
        xmllint,
        "--noout",
        "--nonet",
        "--schema",
        str(binding.validation_schema),
        str(part_file),
    ]
    completed = subprocess.run(command, capture_output=True, text=True)
    schema_name = str(binding.report_schema.relative_to(binding.report_schema.parents[1]))
    if completed.returncode == 0:
        return ValidationResult(
            package=str(package.relative_to(REPO) if package.is_relative_to(REPO) else package),
            part=part,
            status="ok",
            schema=schema_name,
            message="",
        )
    message = (completed.stderr or completed.stdout).strip()
    return ValidationResult(
        package=str(package.relative_to(REPO) if package.is_relative_to(REPO) else package),
        part=part,
        status="fail",
        schema=schema_name,
        message=message,
    )


def validate_package(
    xmllint: str,
    package: Path,
    namespace_to_schema: dict[str, SchemaBinding],
    parts_root: Path,
    allow_unknown: bool,
) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    package_label = str(package.relative_to(REPO) if package.is_relative_to(REPO) else package)
    try:
        with zipfile.ZipFile(package) as archive:
            parts = sorted(
                name
                for name in archive.namelist()
                if not name.endswith("/")
                and (name.endswith(".xml") or name.endswith(".rels"))
            )
            for part in parts:
                try:
                    xml_bytes = archive.read(part)
                    namespace, _local = root_namespace(xml_bytes)
                except (KeyError, ET.ParseError) as error:
                    results.append(
                        ValidationResult(package_label, part, "fail", "", f"xml parse: {error}")
                    )
                    continue

                binding = namespace_to_schema.get(namespace or "")
                if not binding:
                    status = "skip" if allow_unknown else "fail"
                    results.append(
                        ValidationResult(
                            package_label,
                            part,
                            status,
                            "",
                            f"no ECMA-376 XSD for root namespace: {namespace or '(none)'}",
                        )
                    )
                    continue

                results.append(
                    validate_part(xmllint, package, part, xml_bytes, binding, parts_root)
                )
    except zipfile.BadZipFile as error:
        results.append(ValidationResult(package_label, "", "fail", "", f"zip: {error}"))
    except OSError as error:
        results.append(ValidationResult(package_label, "", "fail", "", f"file: {error}"))
    return results


def print_table(results: list[ValidationResult], failures_only: bool) -> None:
    print("package\tpart\tstatus\tschema")
    for result in results:
        if failures_only and result.status != "fail":
            continue
        print(f"{result.package}\t{result.part}\t{result.status}\t{result.schema}")
        if result.status == "fail" and result.message:
            first_line = result.message.splitlines()[0] if result.message else ""
            print(f"  {first_line}", file=sys.stderr)


def print_summary(results: list[ValidationResult]) -> None:
    by_status: dict[str, int] = {}
    failures_by_schema: dict[str, int] = {}
    failures_by_package: dict[str, int] = {}
    for result in results:
        by_status[result.status] = by_status.get(result.status, 0) + 1
        if result.status == "fail":
            schema = result.schema or "(none)"
            failures_by_schema[schema] = failures_by_schema.get(schema, 0) + 1
            failures_by_package[result.package] = failures_by_package.get(result.package, 0) + 1

    print("")
    print("summary")
    for status in sorted(by_status):
        print(f"  {status}: {by_status[status]}")
    if failures_by_schema:
        print("failures by schema")
        for schema, count in sorted(failures_by_schema.items(), key=lambda item: (-item[1], item[0])):
            print(f"  {schema}: {count}")
    if failures_by_package:
        print("top failing packages")
        for package, count in sorted(failures_by_package.items(), key=lambda item: (-item[1], item[0]))[:20]:
            print(f"  {package}: {count}")


def main() -> int:
    args = parse_args()
    xmllint = ensure_xmllint(args.xmllint)
    packages = collect_packages(args)

    tmp_dir = tempfile.TemporaryDirectory(prefix="ooxml-xsd-validate.")
    tmp_root = Path(tmp_dir.name)
    try:
        namespace_to_schema = prepare_schemas(tmp_root / "schemas")
        parts_root = tmp_root / "parts"
        results: list[ValidationResult] = []
        for package in packages:
            results.extend(
                validate_package(
                    xmllint,
                    package,
                    namespace_to_schema,
                    parts_root,
                    allow_unknown=args.allow_unknown,
                )
            )

        if args.json:
            print(json.dumps([result.__dict__ for result in results], indent=2))
        else:
            print_table(results, failures_only=args.failures_only)
            if args.summary:
                print_summary(results)

        failures = [result for result in results if result.status == "fail"]
        if failures:
            if args.keep_tmp:
                print(f"kept tmp: {tmp_root}", file=sys.stderr)
                tmp_dir = None  # type: ignore[assignment]
            return 1

        if args.keep_tmp:
            print(f"kept tmp: {tmp_root}")
            tmp_dir = None  # type: ignore[assignment]
        return 0
    finally:
        if tmp_dir is not None:
            tmp_dir.cleanup()


if __name__ == "__main__":
    raise SystemExit(main())
