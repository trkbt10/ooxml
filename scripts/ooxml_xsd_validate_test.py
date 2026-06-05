#!/usr/bin/env python3
"""Regression tests for scripts/ooxml_xsd_validate.py."""

from __future__ import annotations

import io
import unittest
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

import ooxml_xsd_validate as xsd_validate


MC_NS = xsd_validate.MC_NS
HOST_NS = "urn:host"
OUTER_NS = "urn:outer"
INNER_NS = "urn:inner"


def local_names(xml_bytes: bytes) -> list[str]:
    names: list[str] = []
    root = ET.fromstring(xml_bytes)
    for element in root.iter():
        if element.tag.startswith("{"):
            names.append(element.tag.split("}", 1)[1])
        else:
            names.append(element.tag)
    return names


class MarkupCompatibilityRegressionTest(unittest.TestCase):
    def test_strict_docprops_prefer_direct_schema_validation(self) -> None:
        namespace = "http://purl.oclc.org/ooxml/officeDocument/customProperties"
        report_schema = Path("shared-documentPropertiesCustom.xsd")
        wrapper_schema = Path("strict-wrapper.xsd")
        bindings = {
            namespace: xsd_validate.SchemaBinding(report_schema, wrapper_schema),
        }

        xsd_validate.prefer_direct_validation(
            bindings,
            xsd_validate.STRICT_DIRECT_VALIDATION_NAMESPACES,
        )

        self.assertEqual(bindings[namespace].validation_schema, report_schema)

    def test_must_understand_uses_element_scoped_prefix_binding(self) -> None:
        xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<h:root xmlns:h="{HOST_NS}" xmlns:mc="{MC_NS}" xmlns:n="{OUTER_NS}"
    mc:MustUnderstand="n">
  <h:child xmlns:n="{INNER_NS}"/>
</h:root>
""".encode()

        processed = xsd_validate.mc_preprocess_xml(xml, {OUTER_NS, HOST_NS})

        self.assertIn("root", local_names(processed))

    def test_process_content_uses_declaration_scoped_prefix_binding(self) -> None:
        xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<h:root xmlns:h="{HOST_NS}" xmlns:mc="{MC_NS}" xmlns:i="{OUTER_NS}"
    mc:Ignorable="i" mc:ProcessContent="i:wrap">
  <i:wrap>
    <h:kept/>
  </i:wrap>
  <h:scope xmlns:i="{INNER_NS}"/>
</h:root>
""".encode()

        processed = xsd_validate.mc_preprocess_xml(xml, {HOST_NS})
        names = local_names(processed)

        self.assertIn("kept", names)
        self.assertNotIn("wrap", names)

    def test_alternate_content_choice_uses_choice_scoped_prefix_binding(self) -> None:
        xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<h:root xmlns:h="{HOST_NS}" xmlns:mc="{MC_NS}" xmlns:n="{OUTER_NS}">
  <mc:AlternateContent>
    <mc:Choice xmlns:n="{INNER_NS}" Requires="n">
      <h:innerChoice/>
    </mc:Choice>
    <mc:Choice Requires="n">
      <h:outerChoice/>
    </mc:Choice>
    <mc:Fallback>
      <h:fallback/>
    </mc:Fallback>
  </mc:AlternateContent>
</h:root>
""".encode()

        processed = xsd_validate.mc_preprocess_xml(xml, {OUTER_NS, HOST_NS})
        names = local_names(processed)

        self.assertIn("outerChoice", names)
        self.assertNotIn("innerChoice", names)
        self.assertNotIn("fallback", names)


class ContentPartRelationshipTest(unittest.TestCase):
    def test_relationships_source_part_handles_package_nested_and_root_parts(self) -> None:
        self.assertIsNone(xsd_validate.relationships_source_part("_rels/.rels"))
        self.assertEqual(
            xsd_validate.relationships_source_part("xl/drawings/_rels/drawing1.xml.rels"),
            "xl/drawings/drawing1.xml",
        )
        self.assertEqual(
            xsd_validate.relationships_source_part("_rels/root.xml.rels"),
            "root.xml",
        )

    def test_resolve_internal_relationship_target_uses_source_directory(self) -> None:
        self.assertEqual(
            xsd_validate.resolve_internal_relationship_target(
                "xl/drawings/drawing1.xml",
                "svg1.xml",
            ),
            "xl/drawings/svg1.xml",
        )
        self.assertEqual(
            xsd_validate.resolve_internal_relationship_target(None, "/docProps/core.xml"),
            "docProps/core.xml",
        )
        self.assertIsNone(
            xsd_validate.resolve_internal_relationship_target(
                "xl/drawings/drawing1.xml",
                "../../../outside.xml",
            )
        )

    def test_custom_xml_content_part_targets_collects_internal_targets(self) -> None:
        package_bytes = io.BytesIO()
        with zipfile.ZipFile(package_bytes, "w") as archive:
            archive.writestr(
                "xl/drawings/_rels/drawing1.xml.rels",
                f"""<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="{xsd_validate.RELATIONSHIPS_NS}">
  <Relationship Id="svg1"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXml"
    Target="svg1.xml"/>
  <Relationship Id="external"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXml"
    Target="https://example.invalid/content.xml" TargetMode="External"/>
  <Relationship Id="image1"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image"
    Target="image1.png"/>
</Relationships>
""",
            )
            archive.writestr("xl/drawings/svg1.xml", "<svg/>")

        package_bytes.seek(0)
        with zipfile.ZipFile(package_bytes) as archive:
            self.assertEqual(
                xsd_validate.custom_xml_content_part_targets(archive),
                {"xl/drawings/svg1.xml"},
            )


if __name__ == "__main__":
    unittest.main()
