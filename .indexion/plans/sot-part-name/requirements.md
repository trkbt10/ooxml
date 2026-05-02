# SoT PartName Requirements

- Introduce a single `PartName` source of truth under `src/ecma376/opc/`.
- Preserve existing valid part-name behavior while rejecting malformed ECMA-376 Part 2 §6.2.2.2 names.
- Reject malformed percent encoding, percent-encoded forbidden/iunreserved characters, literal segment-ending dots, and user-supplied reserved relationship part names.
- Keep relationship target resolution and part-name normalization in the same canonical package.
- Keep drift at zero and all MoonBit test backends passing.

