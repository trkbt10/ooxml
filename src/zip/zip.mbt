///|
/// ZIP archive reader/writer package identifier.
pub fn package_name() -> String {
  "trkbt10/ooxml/zip"
}

///|
/// Compression method recorded for a ZIP entry (APPNOTE 4.4.5).
pub(all) enum CompressionMethod {
  Stored
  Deflate
} derive(Eq, Debug)

///|
/// One file entry in a ZIP archive.
pub(all) struct Entry {
  name : String
  data : Bytes
  compression : CompressionMethod
  crc32 : Int64
  compressed_size : Int
  uncompressed_size : Int
} derive(Eq, Debug)

///|
/// ZIP archive contents in central-directory order.
pub(all) struct Archive {
  entries : Array[Entry]
} derive(Eq, Debug)

///|
/// Create an archive from uncompressed entry data.
pub fn Archive::new(entries : Array[(String, Bytes)]) -> Archive {
  {
    entries: entries.map(fn(pair) {
      let (name, data) = pair
      let size = data.length()
      {
        name,
        data,
        compression: Stored,
        crc32: crc32(data),
        compressed_size: size,
        uncompressed_size: size,
      }
    }),
  }
}

///|
/// Create an uncompressed ZIP entry.
pub fn Entry::stored(name : String, data : Bytes) -> Entry {
  let size = data.length()
  {
    name,
    data,
    compression: Stored,
    crc32: crc32(data),
    compressed_size: size,
    uncompressed_size: size,
  }
}

///|
/// Read a ZIP archive from bytes.
pub fn read(bytes : Bytes) -> Archive raise {
  Reader::new(bytes).read()
}

///|
/// Write a ZIP archive using Stored entries (APPNOTE 4.3.7, 4.3.12, 4.3.16).
pub fn write(archive : Archive) -> Bytes raise {
  Writer::new().write(archive)
}

///|
fn compression_code(compression : CompressionMethod) -> Int {
  match compression {
    Stored => 0
    Deflate => 8
  }
}

///|
fn compression_method(
  code : Int,
) -> CompressionMethod raise UnsupportedCompression {
  match code {
    0 => Stored
    8 => Deflate
    _ => raise UnsupportedCompression(compression=code)
  }
}

///|
fn crc32(bytes : Bytes) -> Int64 {
  let mut crc = 0xffffffffL
  for byte in bytes {
    crc = crc ^ byte.to_int64()
    for _ in 0..<8 {
      if (crc & 1L) != 0L {
        crc = (crc >> 1) ^ 0xedb88320L
      } else {
        crc = crc >> 1
      }
    }
  }
  (crc ^ 0xffffffffL) & 0xffffffffL
}

///|
fn checked_u16(value : Int, what : String) -> Unit raise ZipMalformed {
  if value < 0 || value > 0xffff {
    raise ZipMalformed(reason="\{what} does not fit in ZIP16")
  }
}

///|
fn checked_u32(value : Int64, what : String) -> Unit raise ZipMalformed {
  if value < 0L || value > 0xffffffffL {
    raise ZipMalformed(reason="\{what} does not fit in ZIP32")
  }
}

///|
fn bytes_slice(
  bytes : Bytes,
  start : Int,
  len : Int,
) -> Bytes raise ZipMalformed {
  if start < 0 || len < 0 || start + len > bytes.length() {
    raise ZipMalformed(reason="byte range outside archive")
  }
  @buffer.from_iter(bytes[start:start + len].iter()).to_bytes()
}

///|
fn decode_utf8(bytes : Bytes) -> String raise ZipMalformed {
  @utf8.decode(bytes[:]) catch {
    @utf8.Malformed(_) =>
      raise ZipMalformed(reason="ZIP name is not valid UTF-8")
  }
}

///|
fn ensure_range(
  bytes : Bytes,
  offset : Int,
  len : Int,
) -> Unit raise ZipMalformed {
  if offset < 0 || len < 0 || offset + len > bytes.length() {
    raise ZipMalformed(reason="truncated ZIP structure")
  }
}

///|
fn read_u16(bytes : Bytes, offset : Int) -> Int raise ZipMalformed {
  ensure_range(bytes, offset, 2)
  bytes[offset].to_int() | (bytes[offset + 1].to_int() << 8)
}

///|
fn read_u32(bytes : Bytes, offset : Int) -> Int64 raise ZipMalformed {
  ensure_range(bytes, offset, 4)
  bytes[offset].to_int64() |
  (bytes[offset + 1].to_int64() << 8) |
  (bytes[offset + 2].to_int64() << 16) |
  (bytes[offset + 3].to_int64() << 24)
}

///|
fn read_u32_int(bytes : Bytes, offset : Int) -> Int raise ZipMalformed {
  let value = read_u32(bytes, offset)
  if value > 0x7fffffffL {
    raise ZipMalformed(reason="ZIP32 value exceeds supported Int range")
  }
  value.to_int()
}

///|
fn write_u16(out : @buffer.Buffer, value : Int) -> Unit {
  out.write_byte(value.to_byte())
  out.write_byte((value >> 8).to_byte())
}

///|
fn write_u32(out : @buffer.Buffer, value : Int64) -> Unit {
  out.write_byte(value.to_byte())
  out.write_byte((value >> 8).to_byte())
  out.write_byte((value >> 16).to_byte())
  out.write_byte((value >> 24).to_byte())
}

///|
fn write_bytes(out : @buffer.Buffer, bytes : Bytes) -> Unit {
  out.write_bytes(bytes[:])
}

///|
fn encode_utf8(value : String) -> Bytes {
  @utf8.encode(value[:])
}

///|
fn reverse_bits(code : Int, len : Int) -> Int {
  let mut src = code
  let mut out = 0
  for _ in 0..<len {
    out = (out << 1) | (src & 1)
    src = src >> 1
  }
  out
}

///|
fn checked_byte(value : Int) -> Byte {
  (value & 0xff).to_byte()
}

///|
fn expect_signature(
  bytes : Bytes,
  offset : Int,
  signature : Int64,
) -> Unit raise ZipMalformed {
  if read_u32(bytes, offset) != signature {
    raise ZipMalformed(reason="unexpected ZIP signature")
  }
}
