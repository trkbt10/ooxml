# SoT Package Mutator Design

## Source Of Truth

`@opc.Package` owns package-level mutation and lookup because these operations
are defined over OPC parts rather than over `docx`, `pptx`, or `xlsx` document
models. The methods live in `src/ecma376/opc/package.mbt` beside
`Package::open`, `Package::save`, `Package::part`, and
`Package::relationships`.

## API Shape

The moved methods keep the facade-compatible signatures already used by the
codebase:

```moonbit
pub fn Package::with_part(self : Package, name : String, data : Bytes) -> Package

pub fn[T] Package::with_optional_part(
  self : Package,
  name : String,
  value : T?,
  writer : (T) -> Bytes,
) -> Package

pub fn Package::required_part(
  self : Package,
  name : String,
  section~ : String,
  source_path~ : String,
) -> PackagePart raise @opc_errors.ResourceMissing

pub fn[T] Package::read_optional(
  self : Package,
  name : String,
  reader : (Bytes) -> T raise,
) -> T? raise
```

`with_part` intentionally preserves the existing behavior: it only replaces
data for matching existing parts. It does not create new parts or content type
overrides.

## Facade Migration

The facades continue to drive file-format workflows, but delegate package
lookup and mutation to `@opc.Package`:

- `docx` uses `Package::required_part`, `Package::read_optional`,
  `Package::with_part`, and `Package::with_optional_part`.
- `xlsx` uses the same set.
- `pptx` uses `Package::required_part` and `Package::with_part`.

Local duplicate helper definitions are removed from all three facades.

## Error Model

`required_part` raises `@opc_errors.ResourceMissing`, matching the OPC package
layer error model. The public facades already catch this error and translate it
to each facade's `OpenError`, so no reverse dependency on facade errors is
introduced.
