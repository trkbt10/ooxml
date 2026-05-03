# G1 Formula E2E Design

`WorksheetSnapshot` is the integration boundary between parsed SpreadsheetML
worksheet content (§18.3) and formula semantics (§18.17). It owns a mutable cell
map keyed by `A1` or `Sheet!A1`, optional `CT_Sst`, workbook date system, and a
shared-formula master registry keyed by `si`.

`evaluate_cell` resolves the requested address, dispatches literal cells to
`cell_value.decode_cell_value_with_sst`, and dispatches formula cells through
`parse_formula` plus `evaluate`. The generated `EvalContext` installs the
built-in registry for this package and resolves references by recursively
calling the worksheet evaluator.

Shared formulas follow §18.3.1.40: a shared master with body text is registered
when first evaluated, and dependent cells with only `si` expand that master text
through `expand_shared_formula_text(master, text, dependent)`.

Cycle detection is a per-call `HashMap[String, Bool]` of in-progress addresses.
When a recursive reference reaches an address already in progress, the
integration returns `VError(Ref)`. Excel exposes circular-reference state rather
than exactly `#REF!`; this phase deliberately uses `#REF!` as the stable
sentinel for integration tests.

Future work remains explicit: array-formula expansion across result cells,
defined-name registries, and external workbook reference resolution are not
wired in this phase.
