///|
/// OPC content-types §8 Errors E2 schema error for XML that is well-formed but
/// violates opc-contentTypes.xsd constraints in §4. Canonical type:
/// `@opc_errors.SchemaViolation`.
///
/// Content-types anchor: this package owns `[Content_Types].xml`, the
/// `Types`, `Default`, and `Override` records, and the §10.1 mapping from part
/// names to media types. Schema errors therefore keep paths such as
/// `/Types/Default` and `Override/@PartName`.

///|
/// OPC content-types §8 Errors E3 feature error for a recognised §4 element or
/// attribute this build cannot process. Canonical type:
/// `@opc_errors.UnsupportedFeature`.
///
/// Content-types anchor: capability checks are scoped to content type
/// declarations, not relationship markup or package part payloads.

///|
/// OPC content-types §8 Errors E4 resolver error for a referenced package part
/// that cannot be supplied by the surrounding OPC layer. Canonical type:
/// `@opc_errors.ResourceMissing`.
///
/// Content-types anchor: unresolved override targets use the `target~` field
/// to preserve the package part name selected by content type lookup.
