# Design

## Package Scope

All implementation lives in `src/ecma376/opc/part/domain.mbt`, beside the
affected domain types. Tests live in `src/ecma376/opc/part/part_wbtest.mbt`.

## Added Helpers

- `ThumbnailPart::is_jpeg` serves §9 Thumbnails by checking the JPEG SOI
  marker.
- `ThumbnailPart::is_png` serves §9 Thumbnails by checking the PNG signature.
- `PackagePart::is_relationships_part` serves the package part and
  relationships naming requirements by combining `PartName::is_user_creatable`
  with `.rels` suffix inspection.
- `PackagePart::looks_like_thumbnail` serves §9 Thumbnails by accepting image
  media types and sniffing octet-stream image bytes.
- `CoreKeyword::matches` serves `CT_Keyword` by trimming XML whitespace and
  comparing token text.
- `CoreKeywords::iter` serves `CoreKeywords` by iterating non-empty keyword
  values in source order.
- `CoreKeywords::contains` serves searchable core keyword metadata.
- `CoreProperties::title` serves §8.3.3/§8.3.4 by walking root children for
  the Dublin Core `title` element and returning text content.
- `CoreProperties::keywords` serves `CT_CoreProperties` and the
  opc-coreProperties `keywords` element by materializing `CoreKeyword` values.
- `CoreProperties::has_property` serves the single-valued core property element
  set by scanning parsed root children.

## XML Handling

The helpers read only the parsed `@xml.Document` and `@xml.Element` structure.
The core-properties namespace is obtained through
`@opc_namespaces.ns_core_properties()`.

## Behavioral Impact

The existing constructors, readers, and writers remain unchanged. The new
functions are additive public API and are covered by whitebox tests.
