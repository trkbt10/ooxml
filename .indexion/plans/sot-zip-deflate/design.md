# SoT ZIP Deflate Design

## Writer

The writer dispatches per entry:

- `Stored`: write the original bytes.
- `Deflate`: write a raw RFC 1951 Deflate stream and record method 8.

The encoder uses one final fixed-Huffman block. It applies a bounded LZ77 search with a 32 KiB window and short hash chains, then emits literals, length/distance pairs, and the end-of-block marker using fixed Deflate codes. This keeps the implementation package-local and portable across MoonBit backends while producing real compressed streams for repetitive OOXML XML payloads.

Small inputs are not forced back to Stored. If a caller requests `Deflate`, the writer preserves that compression method even when Deflate overhead makes the compressed payload larger.

## Reader

The reader continues to use the central directory as the source of truth. When bit 3 is set, it reads the descriptor after the compressed data and checks its CRC and 32-bit size values against the central-directory entry. The optional descriptor signature is accepted.

ZIP64 support is metadata-only for in-memory archives. The reader follows the ZIP64 EOCD locator and fixed ZIP64 EOCD record when classic EOCD fields are saturated. Central-directory ZIP64 extra field id `0x0001` supplies true uncompressed size, compressed size, and local header offset in APPNOTE order. Values beyond the supported `Int` range are rejected as malformed because this package materializes archives into `Bytes`.
