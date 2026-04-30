///|
priv struct CentralRecord {
  name : Bytes
  compression : CompressionMethod
  crc : Int64
  compressed_size : Int
  uncompressed_size : Int
  local_offset : Int
}

///|
/// Writer for ZIP archives.
pub struct Writer {}

///|
/// Create a ZIP writer.
pub fn Writer::new() -> Writer {
  Writer::{  }
}

///|
/// Write an archive using local headers, central directory, and EOCD.
pub fn Writer::write(self : Writer, archive : Archive) -> Bytes raise {
  let _ = self
  checked_u16(archive.entries.length(), "entry count")
  let out = @buffer.new()
  let central : Array[CentralRecord] = []
  for entry in archive.entries {
    if entry.compression != Stored {
      raise UnsupportedCompression(
        compression=compression_code(entry.compression),
      )
    }
    let name = encode_utf8(entry.name)
    checked_u16(name.length(), "entry name length")
    checked_u32(entry.data.length().to_int64(), "entry size")
    let local_offset = out.length()
    write_local_header(out, entry, name)
    write_bytes(out, entry.data)
    central.push({
      name,
      compression: Stored,
      crc: crc32(entry.data),
      compressed_size: entry.data.length(),
      uncompressed_size: entry.data.length(),
      local_offset,
    })
  }
  let central_offset = out.length()
  for record in central {
    write_central_header(out, record)
  }
  let central_size = out.length() - central_offset
  checked_u32(central_offset.to_int64(), "central directory offset")
  checked_u32(central_size.to_int64(), "central directory size")
  write_eocd(out, archive.entries.length(), central_size, central_offset)
  out.to_bytes()
}

///|
fn write_local_header(
  out : @buffer.Buffer,
  entry : Entry,
  name : Bytes,
) -> Unit {
  let crc = crc32(entry.data)
  write_u32(out, 0x04034b50L)
  write_u16(out, 20)
  write_u16(out, 0x0800)
  write_u16(out, compression_code(Stored))
  write_u16(out, 0)
  write_u16(out, 0)
  write_u32(out, crc)
  write_u32(out, entry.data.length().to_int64())
  write_u32(out, entry.data.length().to_int64())
  write_u16(out, name.length())
  write_u16(out, 0)
  write_bytes(out, name)
}

///|
fn write_central_header(out : @buffer.Buffer, record : CentralRecord) -> Unit {
  write_u32(out, 0x02014b50L)
  write_u16(out, 20)
  write_u16(out, 20)
  write_u16(out, 0x0800)
  write_u16(out, compression_code(record.compression))
  write_u16(out, 0)
  write_u16(out, 0)
  write_u32(out, record.crc)
  write_u32(out, record.compressed_size.to_int64())
  write_u32(out, record.uncompressed_size.to_int64())
  write_u16(out, record.name.length())
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u32(out, 0L)
  write_u32(out, record.local_offset.to_int64())
  write_bytes(out, record.name)
}

///|
fn write_eocd(
  out : @buffer.Buffer,
  count : Int,
  central_size : Int,
  central_offset : Int,
) -> Unit {
  write_u32(out, 0x06054b50L)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, count)
  write_u16(out, count)
  write_u32(out, central_size.to_int64())
  write_u32(out, central_offset.to_int64())
  write_u16(out, 0)
}
