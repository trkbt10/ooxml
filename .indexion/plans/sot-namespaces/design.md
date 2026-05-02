# SoT Namespaces Design

## Registry Package

Add `src/ecma376/opc/namespaces` as an OPC-adjacent registry package. Each public function returns one canonical URI string and carries a doc comment naming the owning ECMA-376 or W3C section.

## XML Namespace Ownership

The W3C XML 1.0 `xml` prefix is foundational XML behavior, not OPC behavior. `src/xml` exposes `ns_xml_1998()`, and the OPC registry delegates to it to avoid a layering inversion.

## Migration

OPC relationships, content types, core properties, digital signatures, and public document facades import the registry as `@opc_namespaces`. Local helpers may remain only where they preserve existing package-local API shape or white-box test ergonomics, but their bodies delegate to the registry instead of carrying literals.
