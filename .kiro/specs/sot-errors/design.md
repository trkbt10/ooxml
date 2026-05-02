# SoT Errors Design

## Decision

Use a dependency-leaf OPC §8 error package:
`src/ecma376/opc/errors`.

The original Option A was rejected because MoonBit type aliases expose the
aliased suberror type in signatures but do not re-export the constructor value.
That means a caller cannot continue to catch `@subpkg.SchemaViolation(...)`
through an alias.

The original Option B, direct imports of the OPC facade as `@opc`, was rejected
because `src/ecma376/opc` already imports content-types and relationships.
Having those subpackages import the facade creates an import loop.

The implemented shape keeps one declaration site without a package cycle:

- `src/ecma376/opc/errors/errors.mbt` declares `SchemaViolation`,
  `UnsupportedFeature`, and `ResourceMissing`.
- `src/ecma376/opc/errors/errors.mbt` owns `require_schema`,
  `require_supported_feature`, and `require_resource`.
- `src/ecma376/opc/errors.mbt` remains an SDD anchor file documenting the
  facade's §8 vocabulary while the concrete helpers live in `@opc_errors`.
- OPC subpackages import `trkbt10/ooxml/ecma376/opc/errors` as `@opc_errors`.
- In-repository catch-sites use `@opc_errors.SchemaViolation`,
  `@opc_errors.UnsupportedFeature`, and `@opc_errors.ResourceMissing`.

## Compatibility

Payload fields remain unchanged:

- `SchemaViolation(section~, path~, reason~)`
- `UnsupportedFeature(section~, path~, reason~)`
- `ResourceMissing(section~, path~, target~)`

The previous subpackage helper wrappers are removed because they were still
reported as the OPC errors duplicate group by `indexion plan refactor`. In-repo
helper tests call the canonical `@opc_errors` functions directly.

External package-qualified constructor patterns such as
`@content_types.SchemaViolation(...)`, and old subpackage helper names such as
`@content_types.require_resource`, cannot be preserved without duplicate
declarations or duplicate wrappers. In-repository call-sites are migrated to the
canonical `@opc_errors` constructors and helpers.
