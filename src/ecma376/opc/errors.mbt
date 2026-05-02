///|
/// OPC §8 Errors E2 package-level schema error; canonical type is
/// `@opc_errors.SchemaViolation`.
///
/// Facade anchor: this package coordinates ZIP, content-types, and
/// relationships into an OPC package, so its §8 helper surface is retained for
/// callers that validate package-level §6 Pack URI and §9 package model
/// conditions through `src/ecma376/opc`.

///|
/// OPC §8 Errors E3 package feature error; canonical type is
/// `@opc_errors.UnsupportedFeature`.
///
/// Facade anchor: recognised-but-unimplemented package behaviours remain
/// reported as §8 E3 with the package path supplied by the caller.

///|
/// OPC §8 Errors E4 unresolved package resource error; canonical type is
/// `@opc_errors.ResourceMissing`.
///
/// Facade anchor: missing physical ZIP entries, relationship targets, and
/// package parts remain reported as §8 E4 by the package facade.
