///|
/// Malformed ZIP structure or ZIP value outside the supported in-memory range.
pub(all) suberror ZipMalformed {
  ZipMalformed(reason~ : String)
} derive(Debug)

///|
/// Compression method other than Stored or Deflate (APPNOTE 4.4.5).
pub(all) suberror UnsupportedCompression {
  UnsupportedCompression(compression~ : Int)
} derive(Debug)

///|
/// Entry data CRC-32 does not match the central directory (APPNOTE 4.4.7).
pub(all) suberror Crc32Mismatch {
  Crc32Mismatch(name~ : String, expected~ : Int64, actual~ : Int64)
} derive(Debug)
