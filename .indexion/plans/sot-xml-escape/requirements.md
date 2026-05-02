# XML Escape SoT Requirements

## Goal

Promote XML escaping in `src/xml/` to the public single source of truth for XML
text, XML attribute values, Canonical XML 1.0 text, Canonical XML 1.0 attribute
values, and XML 1.0 character validity.

## Functional Requirements

- `src/xml/` exposes public XML 1.0 text escaping per XML 1.0 §2.4 and OPC
  §6.2.5.
- `src/xml/` exposes public XML 1.0 attribute escaping per XML 1.0 §2.4 /
  §3.3.3 and OPC §6.2.5.
- `src/xml/` exposes public Canonical XML 1.0 attribute escaping per W3C C14N
  §2.3 for OPC digital signature canonicalization.
- `src/xml/` exposes public Canonical XML 1.0 text escaping per W3C C14N §2.3
  for OPC digital signature canonicalization.
- `src/xml/` exposes public XML 1.0 Char production validation per XML 1.0
  §2.2.
- `src/docx/`, `src/pptx/`, and `src/xlsx/` must call `@xml.escape_text`
  instead of maintaining local duplicate text escapers.
- `src/ecma376/opc/digital_signatures/` must call the XML C14N escapers instead
  of maintaining local canonical escape helpers.

## Non-Requirements

- Do not alter ECMA-376 SDD specs under `.kiro/specs/`.
- Do not alter `*_wbtest.mbt` XML fixtures.
- Do not consolidate HTML viewer escapers.
- Do not change existing canonicalization behavior or test counts.
