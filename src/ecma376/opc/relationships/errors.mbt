///|
/// OPC relationships §8 Errors E2 schema error for XML that is well-formed but
/// violates opc-relationships.xsd constraints. Canonical type:
/// `@opc_errors.SchemaViolation`.
///
/// Relationships anchor: this package owns `.rels` parsing, relationship Id
/// uniqueness, TargetMode lexical checks, and the schema paths rooted at
/// `/Relationships`.

///|
/// OPC relationships §8 Errors E3 feature error for recognised schema content
/// this build cannot process. Canonical type:
/// `@opc_errors.UnsupportedFeature`.
///
/// Relationships anchor: feature checks here describe relationship markup and
/// target-mode behaviour, not `[Content_Types].xml` declarations.

///|
/// OPC relationships §8 Errors E4 resolver error for a relationship target the
/// surrounding OPC package cannot supply. Canonical type:
/// `@opc_errors.ResourceMissing`.
///
/// Relationships anchor: missing resources keep the relationship target in
/// `target~` so callers can map the error back to the source `.rels` item.
