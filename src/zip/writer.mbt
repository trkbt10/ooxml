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
    let compressed = match entry.compression {
      Stored => entry.data
      Deflate => deflate_encode(entry.data)
    }
    let name = encode_utf8(entry.name)
    checked_u16(name.length(), "entry name length")
    checked_u32(entry.data.length().to_int64(), "entry size")
    checked_u32(compressed.length().to_int64(), "compressed entry size")
    let local_offset = out.length()
    let crc = crc32(entry.data)
    write_local_header(out, entry, name, compressed.length(), crc)
    write_bytes(out, compressed)
    central.push({
      name,
      compression: entry.compression,
      crc,
      compressed_size: compressed.length(),
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
  compressed_size : Int,
  crc : Int64,
) -> Unit {
  write_u32(out, 0x04034b50L)
  write_u16(out, 20)
  write_u16(out, 0x0800)
  write_u16(out, compression_code(entry.compression))
  write_u16(out, 0)
  write_u16(out, 0)
  write_u32(out, crc)
  write_u32(out, compressed_size.to_int64())
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

///|
/// Encode bytes as a raw RFC 1951 Deflate stream.
fn deflate_encode(input : Bytes) -> Bytes {
  let bits = BitWriter::new()
  write_deflate_fixed_block(bits, input)
  bits.to_bytes()
}

///|
priv struct BitWriter {
  out : @buffer.Buffer
  mut bits : Int
  mut bit_count : Int
}

///|
fn BitWriter::new() -> BitWriter {
  { out: @buffer.new(), bits: 0, bit_count: 0 }
}

///|
fn BitWriter::write_bits(self : BitWriter, value : Int, count : Int) -> Unit {
  self.bits = self.bits | ((value & ((1 << count) - 1)) << self.bit_count)
  self.bit_count += count
  while self.bit_count >= 8 {
    self.out.write_byte((self.bits & 0xff).to_byte())
    self.bits = self.bits >> 8
    self.bit_count -= 8
  }
}

///|
fn BitWriter::to_bytes(self : BitWriter) -> Bytes {
  if self.bit_count > 0 {
    self.out.write_byte((self.bits & 0xff).to_byte())
    self.bits = 0
    self.bit_count = 0
  }
  self.out.to_bytes()
}

///|
priv struct Match {
  len : Int
  distance : Int
}

///|
fn write_deflate_fixed_block(bits : BitWriter, input : Bytes) -> Unit {
  bits.write_bits(1, 1)
  bits.write_bits(1, 2)
  let head = Array::make(32768, -1)
  let prev = Array::make(input.length(), -1)
  let mut pos = 0
  while pos < input.length() {
    let best = find_match(input, pos, head, prev)
    if best.len >= 3 {
      write_length(bits, best.len)
      write_distance(bits, best.distance)
      for i in 0..<best.len {
        insert_hash(input, pos + i, head, prev)
      }
      pos += best.len
    } else {
      write_literal(bits, input[pos].to_int())
      insert_hash(input, pos, head, prev)
      pos += 1
    }
  }
  write_literal(bits, 256)
}

///|
fn hash_at(input : Bytes, pos : Int) -> Int {
  if pos + 2 >= input.length() {
    -1
  } else {
    (
      (input[pos].to_int() << 10) ^
      (input[pos + 1].to_int() << 5) ^
      input[pos + 2].to_int()
    ) &
    0x7fff
  }
}

///|
fn insert_hash(
  input : Bytes,
  pos : Int,
  head : Array[Int],
  prev : Array[Int],
) -> Unit {
  let hash = hash_at(input, pos)
  if hash >= 0 {
    prev[pos] = head[hash]
    head[hash] = pos
  }
}

///|
fn find_match(
  input : Bytes,
  pos : Int,
  head : Array[Int],
  prev : Array[Int],
) -> Match {
  let hash = hash_at(input, pos)
  if hash < 0 {
    { len: 0, distance: 0 }
  } else {
    let mut candidate = head[hash]
    let mut best_len = 0
    let mut best_distance = 0
    let max_len = if input.length() - pos > 258 {
      258
    } else {
      input.length() - pos
    }
    let mut searched = 0
    while candidate >= 0 && pos - candidate <= 32768 && searched < 64 {
      let mut len = 0
      while len < max_len && input[candidate + len] == input[pos + len] {
        len += 1
      }
      if len > best_len {
        best_len = len
        best_distance = pos - candidate
        if len == max_len {
          candidate = -1
        }
      }
      if candidate >= 0 {
        candidate = prev[candidate]
      }
      searched += 1
    }
    { len: best_len, distance: best_distance }
  }
}

///|
fn write_literal(bits : BitWriter, symbol : Int) -> Unit {
  if symbol <= 143 {
    bits.write_bits(reverse_bits(0x30 + symbol, 8), 8)
  } else if symbol <= 255 {
    bits.write_bits(reverse_bits(0x190 + symbol - 144, 9), 9)
  } else if symbol <= 279 {
    bits.write_bits(reverse_bits(symbol - 256, 7), 7)
  } else {
    bits.write_bits(reverse_bits(0xc0 + symbol - 280, 8), 8)
  }
}

///|
fn write_length(bits : BitWriter, len : Int) -> Unit {
  let mut index = 0
  while index + 1 < length_base.length() && len >= length_base[index + 1] {
    index += 1
  }
  let symbol = 257 + index
  write_literal(bits, symbol)
  let extra = length_extra[index]
  if extra > 0 {
    bits.write_bits(len - length_base[index], extra)
  }
}

///|
fn write_distance(bits : BitWriter, distance : Int) -> Unit {
  let mut index = 0
  while index + 1 < distance_base.length() &&
        distance >= distance_base[index + 1] {
    index += 1
  }
  bits.write_bits(reverse_bits(index, 5), 5)
  let extra = distance_extra[index]
  if extra > 0 {
    bits.write_bits(distance - distance_base[index], extra)
  }
}
