# SoT ZIP Deflate Requirements

## Requirements

1. The ZIP writer shall emit valid APPNOTE/RFC 1951 raw Deflate streams for entries whose `CompressionMethod` is `Deflate`.
2. The ZIP writer shall continue to emit byte-for-byte stored payloads for entries whose `CompressionMethod` is `Stored`.
3. The ZIP reader shall accept central-directory entries that use general-purpose bit 3 and shall validate the following data descriptor against central-directory CRC and sizes.
4. The ZIP reader shall accept ZIP64 EOCD locator/record metadata and ZIP64 extra fields when the classic EOCD or central directory uses saturated 16-bit or 32-bit fields.
5. The ZIP package shall remain below OPC in the dependency graph and shall not import OOXML or OPC packages.
6. Existing OPC facade behavior shall remain compatible: callers that construct stored entries still write stored ZIP parts.

## Validation

- Native package checks and tests for ZIP behavior.
- OPC strict drift gate for the per-task layer gate.
- Full `moon test` across native, wasm-gc, wasm, and js.
- Full strict drift gate across generated spec TSVs.
