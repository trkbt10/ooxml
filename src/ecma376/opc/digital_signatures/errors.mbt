///|
/// 8. Errors E2 schema error for XML that is well-formed but violates
/// the opc-digSig schema constraints. The section, path, and reason fields let
/// callers map occurrence, cardinality, required attribute, type, and pattern
/// failures back to the digital-signature contract. Canonical type:
/// `@opc_errors.SchemaViolation`.
///
/// Digital-signatures anchor: this package owns opc-digSig and XML-Signature
/// shell readers, including RelationshipReference, SignatureTime, manifests,
/// transforms, digest methods, and canonicalization inputs.

///|
/// 8. Errors E3 feature error for a valid digital-signature element or
/// attribute that this build recognizes but cannot process yet. Canonical type:
/// `@opc_errors.UnsupportedFeature`.
///
/// Digital-signatures anchor: feature checks describe signing and validation
/// algorithms recognised by the package but outside the current build.

///|
/// 8. Errors E4 resolver error for a relationship target or signature
/// resource that the surrounding OPC package cannot supply. Canonical type:
/// `@opc_errors.ResourceMissing`.
///
/// Digital-signatures anchor: missing signature origins, relationship
/// transform sources, and referenced signed objects report the missing target
/// through the canonical `target~` field.
