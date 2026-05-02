# SoT PartName Design

The canonical type lives in `src/ecma376/opc/part_name`. This keeps ECMA-376 Part 2 §6.2.2 single-name grammar and §6.4 relationship target normalization separate from concrete OPC part payload packages such as thumbnails and content types.

`opc/part` and `opc/content_types` retain their public `PartName` spelling through type aliases to avoid reintroducing duplicate structs.

`PartName::parse` is the user-facing parser. It enforces ECMA-376 Part 2 §6.2.2.2 grammar and rejects reserved relationship part names from §6.5.2.2 and §6.5.2.3. OPC internals that need to represent those reserved names use `PartName::__from_trusted`, which still validates §6.2.2.2 grammar but bypasses only the reserved-name user-creatable check.

`resolve_target` and `normalize_part_name` are also in `opc/part_name`, so the OPC facade and public format facades share one implementation.

