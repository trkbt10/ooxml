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
import io
import json
import posixpath
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET
from urllib.parse import urlsplit


REPO = Path(__file__).resolve().parents[1]
XSD_NS = "http://www.w3.org/2001/XMLSchema"
XML_NS = "http://www.w3.org/XML/1998/namespace"
MC_NS = "http://schemas.openxmlformats.org/markup-compatibility/2006"
DC_NS = "http://purl.org/dc/elements/1.1/"
DCTERMS_NS = "http://purl.org/dc/terms/"
RELATIONSHIPS_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
PACKAGE_RELATIONSHIPS_ITEM = "_rels/.rels"
CUSTOM_XML_RELATIONSHIP_TYPES = {
    "http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXml",
    "http://purl.oclc.org/ooxml/officeDocument/relationships/customXml",
}

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
STRICT_DIRECT_VALIDATION_NAMESPACES = (
    "http://purl.oclc.org/ooxml/officeDocument/extendedProperties",
    "http://purl.oclc.org/ooxml/officeDocument/customProperties",
    "http://purl.oclc.org/ooxml/officeDocument/docPropsVTypes",
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
XML_PART_SUFFIXES = (".xml", ".rels", ".vml")

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

DC_XSD = f"""<?xml version="1.0" encoding="UTF-8"?>
<xs:schema targetNamespace="{DC_NS}"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dc="{DC_NS}"
  xmlns:xml="{XML_NS}"
  elementFormDefault="qualified"
  attributeFormDefault="unqualified">
  <xs:import namespace="{XML_NS}" schemaLocation="xml.xsd"/>

  <xs:complexType name="SimpleLiteral">
    <xs:simpleContent>
      <xs:extension base="xs:string">
        <xs:attribute ref="xml:lang" use="optional"/>
      </xs:extension>
    </xs:simpleContent>
  </xs:complexType>

  <xs:element name="creator" type="dc:SimpleLiteral"/>
  <xs:element name="description" type="dc:SimpleLiteral"/>
  <xs:element name="identifier" type="dc:SimpleLiteral"/>
  <xs:element name="language" type="dc:SimpleLiteral"/>
  <xs:element name="subject" type="dc:SimpleLiteral"/>
  <xs:element name="title" type="dc:SimpleLiteral"/>
</xs:schema>
"""

DCTERMS_XSD = f"""<?xml version="1.0" encoding="UTF-8"?>
<xs:schema targetNamespace="{DCTERMS_NS}"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dcterms="{DCTERMS_NS}"
  xmlns:xml="{XML_NS}"
  elementFormDefault="qualified"
  attributeFormDefault="unqualified">
  <xs:import namespace="{XML_NS}" schemaLocation="xml.xsd"/>

  <xs:complexType name="SimpleLiteral">
    <xs:simpleContent>
      <xs:extension base="xs:anySimpleType">
        <xs:attribute ref="xml:lang" use="optional"/>
      </xs:extension>
    </xs:simpleContent>
  </xs:complexType>

  <xs:simpleType name="W3CDTFValue">
    <xs:union memberTypes="xs:gYear xs:gYearMonth xs:date xs:dateTime"/>
  </xs:simpleType>

  <xs:complexType name="W3CDTF">
    <xs:simpleContent>
      <xs:restriction base="dcterms:SimpleLiteral">
        <xs:simpleType>
          <xs:restriction base="dcterms:W3CDTFValue"/>
        </xs:simpleType>
        <xs:attribute ref="xml:lang" use="prohibited"/>
      </xs:restriction>
    </xs:simpleContent>
  </xs:complexType>

  <xs:element name="created" type="dcterms:SimpleLiteral"/>
  <xs:element name="modified" type="dcterms:SimpleLiteral"/>
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


class McPreprocessError(ValueError):
    pass


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
        "--no-mc-preprocess",
        action="store_true",
        help="validate raw XML without ECMA-376 Part 3 Markup Compatibility preprocessing",
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
    patched = patch_import_location(text, XML_NS, "xml.xsd", replace_existing=False)
    if patched != text:
        xsd.write_text(patched, encoding="utf-8")


def patch_import_location(
    text: str,
    namespace: str,
    schema_location: str,
    replace_existing: bool,
) -> str:
    pattern = re.compile(
        r'(<(?:xsd|xs):import\s+namespace=["\']'
        + re.escape(namespace)
        + r'["\'])([^>]*?)(/?>)',
        re.DOTALL,
    )

    def patch_match(match: re.Match[str]) -> str:
        attrs = match.group(2)
        if "schemaLocation" in attrs:
            if not replace_existing:
                return match.group(0)
            attrs = re.sub(
                r'\s+schemaLocation=(["\'])(.*?)\1',
                f' schemaLocation="{schema_location}"',
                attrs,
                count=1,
                flags=re.DOTALL,
            )
            return f"{match.group(1)}{attrs}{match.group(3)}"
        return f'{match.group(1)}{attrs} schemaLocation="{schema_location}"{match.group(3)}'

    return pattern.sub(patch_match, text)


def patch_dublin_core_imports(xsd: Path) -> None:
    text = xsd.read_text(encoding="utf-8-sig")
    patched = patch_import_location(text, DC_NS, "dc.xsd", replace_existing=True)
    patched = patch_import_location(
        patched, DCTERMS_NS, "dcterms.xsd", replace_existing=True
    )
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
    (target / "dc.xsd").write_text(DC_XSD, encoding="utf-8")
    (target / "dcterms.xsd").write_text(DCTERMS_XSD, encoding="utf-8")
    namespace_to_schema: dict[str, Path] = {}
    for xsd in sorted(target.glob("*.xsd")):
        patch_xml_imports(xsd)
        patch_dublin_core_imports(xsd)
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


def prefer_direct_validation(
    bindings: dict[str, SchemaBinding],
    namespaces: tuple[str, ...],
) -> None:
    """Validate selected namespaces with their own schema instead of the set wrapper.

    The Strict document-property schemas have complete local imports.  Using the
    full Strict wrapper drags in unrelated WML schemas, so an unrelated schema
    compile error can mask otherwise valid docProps parts.
    """
    for namespace in namespaces:
        binding = bindings.get(namespace)
        if binding is not None:
            bindings[namespace] = SchemaBinding(
                report_schema=binding.report_schema,
                validation_schema=binding.report_schema,
            )


def prepare_schemas(tmp_root: Path) -> dict[str, SchemaBinding]:
    namespace_to_schema: dict[str, SchemaBinding] = {}
    strict_bindings = copy_schema_set(STRICT_XSD, tmp_root / "strict", use_wrapper=True)
    prefer_direct_validation(strict_bindings, STRICT_DIRECT_VALIDATION_NAMESPACES)
    namespace_to_schema.update(strict_bindings)
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


def split_tag(tag: str) -> tuple[str | None, str]:
    if tag.startswith("{"):
        namespace, local = tag[1:].split("}", 1)
        return namespace, local
    return None, tag


def attr_value(element: ET.Element, namespace: str, local_name: str) -> str:
    return element.attrib.get(f"{{{namespace}}}{local_name}", "")


def parse_token_list(value: str) -> list[str]:
    return [token for token in re.split(r"[\t\r\n ]+", value.strip()) if token]


def parse_xml_with_prefix_scopes(
    xml_bytes: bytes,
) -> tuple[ET.Element, dict[int, dict[str, str]]]:
    """Parse XML and record each element's in-scope namespace prefixes.

    ElementTree stores expanded names but drops lexical namespace declarations.
    Markup Compatibility attributes contain prefix tokens, so evaluating them
    against one document-global prefix map is wrong when a prefix is rebound in
    a nested scope.
    """

    active: dict[str, list[str]] = {}
    pending: list[tuple[str, str]] = []
    declared_stack: list[list[str]] = []
    prefix_scopes: dict[int, dict[str, str]] = {}
    root: ET.Element | None = None

    events = ("start-ns", "start", "end")
    for event, value in ET.iterparse(io.BytesIO(xml_bytes), events=events):
        if event == "start-ns":
            prefix, namespace = value
            pending.append((prefix or "", namespace))
            continue

        if event == "start":
            element = value
            declared_prefixes: list[str] = []
            for prefix, namespace in pending:
                active.setdefault(prefix, []).append(namespace)
                declared_prefixes.append(prefix)
            pending = []
            declared_stack.append(declared_prefixes)
            prefix_scopes[id(element)] = {
                prefix: namespaces[-1]
                for prefix, namespaces in active.items()
                if namespaces
            }
            if root is None:
                root = element
            continue

        if event == "end":
            declared_prefixes = declared_stack.pop() if declared_stack else []
            for prefix in reversed(declared_prefixes):
                namespaces = active.get(prefix)
                if namespaces:
                    namespaces.pop()
                if not namespaces:
                    active.pop(prefix, None)

    if root is None:
        raise ET.ParseError("missing document element")
    return root, prefix_scopes


def namespaces_for_prefixes(tokens: list[str], prefix_map: dict[str, str]) -> set[str]:
    namespaces: set[str] = set()
    for token in tokens:
        if token not in prefix_map:
            raise McPreprocessError(f"mc namespace prefix is not declared: {token}")
        namespace = prefix_map[token]
        if namespace == MC_NS:
            raise McPreprocessError(f"mc namespace cannot be declared ignorable: {token}")
        namespaces.add(namespace)
    return namespaces


def process_content_pairs(
    tokens: list[str],
    prefix_map: dict[str, str],
    ignorable_namespaces: set[str],
) -> set[tuple[str, str]]:
    pairs: set[tuple[str, str]] = set()
    for token in tokens:
        if ":" not in token:
            raise McPreprocessError(f"mc:ProcessContent token is not prefix:local: {token}")
        prefix, local_name = token.split(":", 1)
        if not prefix or not local_name:
            raise McPreprocessError(f"mc:ProcessContent token is not prefix:local: {token}")
        if prefix not in prefix_map:
            raise McPreprocessError(f"mc:ProcessContent prefix is not declared: {prefix}")
        namespace = prefix_map[prefix]
        if namespace == MC_NS:
            raise McPreprocessError("mc namespace cannot be declared process-content")
        if namespace not in ignorable_namespaces:
            raise McPreprocessError(
                f"mc:ProcessContent namespace is not ignorable: {prefix}"
            )
        pairs.add((namespace, local_name))
    return pairs


def process_content_matches(
    namespace: str | None,
    local_name: str,
    process_content: set[tuple[str, str]],
) -> bool:
    if namespace is None:
        return False
    return (namespace, local_name) in process_content or (namespace, "*") in process_content


def validate_must_understand(
    element: ET.Element,
    prefix_map: dict[str, str],
    supported_namespaces: set[str],
) -> None:
    for namespace in namespaces_for_prefixes(
        parse_token_list(attr_value(element, MC_NS, "MustUnderstand")),
        prefix_map,
    ):
        if namespace not in supported_namespaces:
            raise McPreprocessError(
                f"mc:MustUnderstand namespace is unsupported: {namespace}"
            )


def clone_without_tail(element: ET.Element) -> ET.Element:
    cloned = ET.Element(element.tag)
    cloned.text = element.text
    return cloned


def apply_mc_attributes(
    element: ET.Element,
    prefix_map: dict[str, str],
    inherited_ignorable: set[str],
    inherited_process_content: set[tuple[str, str]],
) -> tuple[set[str], set[tuple[str, str]]]:
    ignorable = set(inherited_ignorable)
    ignorable.update(
        namespaces_for_prefixes(
            parse_token_list(attr_value(element, MC_NS, "Ignorable")),
            prefix_map,
        )
    )
    process_content = set(inherited_process_content)
    process_content.update(
        process_content_pairs(
            parse_token_list(attr_value(element, MC_NS, "ProcessContent")),
            prefix_map,
            ignorable,
        )
    )
    return ignorable, process_content


def copy_output_attributes(
    source: ET.Element,
    target: ET.Element,
    ignorable: set[str],
    supported_namespaces: set[str],
) -> None:
    for name, value in source.attrib.items():
        namespace, local_name = split_tag(name)
        if namespace == MC_NS:
            continue
        if namespace in ignorable and namespace not in supported_namespaces:
            continue
        target.set(name, value)


def alternate_content_selected_children(
    element: ET.Element,
    prefix_scopes: dict[int, dict[str, str]],
    supported_namespaces: set[str],
) -> list[ET.Element]:
    for child in list(element):
        namespace, local_name = split_tag(child.tag)
        if namespace != MC_NS or local_name != "Choice":
            continue
        prefix_map = prefix_scopes.get(id(child), {})
        required_namespaces = namespaces_for_prefixes(
            parse_token_list(child.attrib.get("Requires", "")),
            prefix_map,
        )
        if required_namespaces and required_namespaces.issubset(supported_namespaces):
            return list(child)
    for child in list(element):
        namespace, local_name = split_tag(child.tag)
        if namespace == MC_NS and local_name == "Fallback":
            return list(child)
    return []


def process_mc_element(
    element: ET.Element,
    prefix_scopes: dict[int, dict[str, str]],
    supported_namespaces: set[str],
    inherited_ignorable: set[str],
    inherited_process_content: set[tuple[str, str]],
) -> list[ET.Element]:
    namespace, local_name = split_tag(element.tag)
    prefix_map = prefix_scopes.get(id(element), {})
    ignorable, process_content = apply_mc_attributes(
        element,
        prefix_map,
        inherited_ignorable,
        inherited_process_content,
    )

    if namespace == MC_NS and local_name == "AlternateContent":
        validate_must_understand(element, prefix_map, supported_namespaces)
        output: list[ET.Element] = []
        for selected in alternate_content_selected_children(
            element,
            prefix_scopes,
            supported_namespaces,
        ):
            output.extend(
                process_mc_element(
                    selected,
                    prefix_scopes,
                    supported_namespaces,
                    ignorable,
                    process_content,
                )
            )
        return output

    if namespace == MC_NS:
        return []

    if namespace in ignorable and namespace not in supported_namespaces:
        if process_content_matches(namespace, local_name, process_content):
            output: list[ET.Element] = []
            for child in list(element):
                output.extend(
                    process_mc_element(
                        child,
                        prefix_scopes,
                        supported_namespaces,
                        ignorable,
                        process_content,
                    )
                )
            return output
        return []

    validate_must_understand(element, prefix_map, supported_namespaces)
    cloned = clone_without_tail(element)
    copy_output_attributes(element, cloned, ignorable, supported_namespaces)
    for child in list(element):
        for processed in process_mc_element(
            child,
            prefix_scopes,
            supported_namespaces,
            ignorable,
            process_content,
        ):
            cloned.append(processed)
    return [cloned]


def mc_preprocess_xml(
    xml_bytes: bytes,
    supported_namespaces: set[str],
) -> bytes:
    if MC_NS.encode("utf-8") not in xml_bytes and b"AlternateContent" not in xml_bytes:
        return xml_bytes
    root, prefix_scopes = parse_xml_with_prefix_scopes(xml_bytes)
    processed_roots = process_mc_element(
        root,
        prefix_scopes,
        supported_namespaces,
        inherited_ignorable=set(),
        inherited_process_content=set(),
    )
    if len(processed_roots) != 1:
        raise McPreprocessError(
            f"Markup Compatibility preprocessing produced {len(processed_roots)} root elements"
        )
    return ET.tostring(processed_roots[0], encoding="utf-8", xml_declaration=True)


def relationships_source_part(item_name: str) -> str | None:
    if item_name == PACKAGE_RELATIONSHIPS_ITEM:
        return None
    if not item_name.endswith(".rels"):
        return ""
    if "/_rels/" in item_name:
        prefix, rels_name = item_name.rsplit("/_rels/", 1)
        source_name = rels_name[: -len(".rels")]
        return f"{prefix}/{source_name}" if prefix else source_name
    if item_name.startswith("_rels/"):
        source_name = item_name[len("_rels/") : -len(".rels")]
        return source_name
    return ""


def resolve_internal_relationship_target(source_part: str | None, target: str) -> str | None:
    if not target or "\\" in target:
        return None

    parsed = urlsplit(target)
    if parsed.scheme or parsed.netloc:
        return None

    target_path = parsed.path
    if not target_path:
        return None
    if target_path.startswith("/"):
        raw_path = target_path[1:]
    else:
        base_dir = "" if source_part is None else posixpath.dirname(source_part)
        raw_path = posixpath.join(base_dir, target_path)

    normalized = posixpath.normpath(raw_path)
    if normalized in ("", ".") or normalized == ".." or normalized.startswith("../"):
        return None
    return normalized


def custom_xml_content_part_targets(archive: zipfile.ZipFile) -> set[str]:
    targets: set[str] = set()
    for item_name in archive.namelist():
        if not item_name.endswith(".rels"):
            continue
        source_part = relationships_source_part(item_name)
        if source_part == "":
            continue
        try:
            relationships_xml = mc_preprocess_xml(
                archive.read(item_name),
                supported_namespaces={RELATIONSHIPS_NS},
            )
            root = ET.fromstring(relationships_xml)
        except (KeyError, ET.ParseError, McPreprocessError):
            continue
        if root.tag != f"{{{RELATIONSHIPS_NS}}}Relationships":
            continue
        for relationship in root:
            if relationship.tag != f"{{{RELATIONSHIPS_NS}}}Relationship":
                continue
            if relationship.get("Type", "") not in CUSTOM_XML_RELATIONSHIP_TYPES:
                continue
            if relationship.get("TargetMode", "Internal") != "Internal":
                continue
            resolved = resolve_internal_relationship_target(
                source_part,
                relationship.get("Target", ""),
            )
            if resolved:
                targets.add(resolved)
    return targets


def part_output_path(parts_root: Path, package: Path, part: str) -> Path:
    package_stem = package.name.replace("/", "_")
    safe_part = part.replace("/", "__").replace("[", "_").replace("]", "_")
    out = parts_root / package_stem / safe_part
    out.parent.mkdir(parents=True, exist_ok=True)
    return out


def is_xml_part(part_name: str) -> bool:
    return part_name == "[Content_Types].xml" or part_name.endswith(XML_PART_SUFFIXES)


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


def validate_vml_drawing_part(
    xmllint: str,
    package: Path,
    part: str,
    xml_bytes: bytes,
    namespace_to_schema: dict[str, SchemaBinding],
    parts_root: Path,
    allow_unknown: bool,
) -> list[ValidationResult]:
    package_label = str(package.relative_to(REPO) if package.is_relative_to(REPO) else package)
    try:
        root = ET.fromstring(xml_bytes)
    except ET.ParseError as error:
        return [ValidationResult(package_label, part, "fail", "", f"xml parse: {error}")]

    namespace, local = split_tag(root.tag)
    if namespace is not None or local != "xml":
        return [
            ValidationResult(
                package_label,
                part,
                "fail",
                "(vml-wrapper)",
                "VML Drawing part root must be null-namespace <xml>",
            )
        ]

    results: list[ValidationResult] = []
    child_index = 0
    for child in root:
        child_index += 1
        child_namespace, child_local = split_tag(child.tag)
        child_part = f"{part}#child{child_index}:{child_local}"
        binding = namespace_to_schema.get(child_namespace or "")
        if binding is None:
            status = "skip" if allow_unknown else "fail"
            results.append(
                ValidationResult(
                    package_label,
                    child_part,
                    status,
                    "",
                    f"no ECMA-376 XSD for VML child root namespace: {child_namespace or '(none)'}",
                )
            )
            continue
        child_bytes = ET.tostring(child, encoding="utf-8", xml_declaration=True)
        results.append(
            validate_part(xmllint, package, child_part, child_bytes, binding, parts_root)
        )
    return results


def validate_package(
    xmllint: str,
    package: Path,
    namespace_to_schema: dict[str, SchemaBinding],
    parts_root: Path,
    allow_unknown: bool,
    mc_preprocess: bool,
) -> list[ValidationResult]:
    results: list[ValidationResult] = []
    package_label = str(package.relative_to(REPO) if package.is_relative_to(REPO) else package)
    try:
        with zipfile.ZipFile(package) as archive:
            content_part_targets = custom_xml_content_part_targets(archive)
            parts = sorted(
                name
                for name in archive.namelist()
                if not name.endswith("/")
                and is_xml_part(name)
            )
            for part in parts:
                try:
                    xml_bytes = archive.read(part)
                    if part.endswith(".vml"):
                        results.extend(
                            validate_vml_drawing_part(
                                xmllint,
                                package,
                                part,
                                xml_bytes,
                                namespace_to_schema,
                                parts_root,
                                allow_unknown,
                            )
                        )
                        continue
                    if mc_preprocess:
                        xml_bytes = mc_preprocess_xml(
                            xml_bytes,
                            supported_namespaces=set(namespace_to_schema),
                        )
                    namespace, _local = root_namespace(xml_bytes)
                except (KeyError, ET.ParseError, McPreprocessError) as error:
                    results.append(
                        ValidationResult(package_label, part, "fail", "", f"xml parse: {error}")
                    )
                    continue

                binding = namespace_to_schema.get(namespace or "")
                if not binding:
                    if part in content_part_targets:
                        results.append(
                            ValidationResult(
                                package_label,
                                part,
                                "skip",
                                "(content-part)",
                                (
                                    "ECMA-376 contentPart target has no ECMA-376 XSD "
                                    f"for root namespace: {namespace or '(none)'}"
                                ),
                            )
                        )
                        continue
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
                    mc_preprocess=not args.no_mc_preprocess,
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
