///|
priv struct CentralEntry {
  name : String
  compression : CompressionMethod
  crc : Int64
  compressed_size : Int
  uncompressed_size : Int
  local_offset : Int
}

///|
/// Reader for ZIP archives using the end-of-central-directory record.
pub struct Reader {
  priv bytes : Bytes
}

///|
/// Create a ZIP reader from archive bytes.
pub fn Reader::new(bytes : Bytes) -> Reader {
  { bytes, }
}

///|
/// Read all entries from the ZIP central directory.
pub fn Reader::read(self : Reader) -> Archive raise {
  let eocd = self.find_eocd()
  let entry_count = read_u16(self.bytes, eocd + 10)
  let central_size = read_u32_int(self.bytes, eocd + 12)
  let central_offset = read_u32_int(self.bytes, eocd + 16)
  ensure_range(self.bytes, central_offset, central_size)
  let entries : Array[Entry] = []
  let mut offset = central_offset
  for _ in 0..<entry_count {
    let central = self.read_central_entry(offset)
    entries.push(self.read_local_entry(central))
    let name_len = read_u16(self.bytes, offset + 28)
    let extra_len = read_u16(self.bytes, offset + 30)
    let comment_len = read_u16(self.bytes, offset + 32)
    offset += 46 + name_len + extra_len + comment_len
  }
  if offset != central_offset + central_size {
    raise ZipMalformed(reason="central directory size mismatch")
  }
  { entries, }
}

///|
fn Reader::find_eocd(self : Reader) -> Int raise ZipMalformed {
  let min_len = 22
  if self.bytes.length() < min_len {
    raise ZipMalformed(reason="archive too small for EOCD")
  }
  let mut offset = self.bytes.length() - min_len
  let lowest = if self.bytes.length() > 0xffff + min_len {
    self.bytes.length() - (0xffff + min_len)
  } else {
    0
  }
  while offset >= lowest {
    if read_u32(self.bytes, offset) == 0x06054b50L {
      let comment_len = read_u16(self.bytes, offset + 20)
      if offset + min_len + comment_len == self.bytes.length() {
        return offset
      }
    }
    offset -= 1
  }
  raise ZipMalformed(reason="missing end of central directory")
}

///|
fn Reader::read_central_entry(
  self : Reader,
  offset : Int,
) -> CentralEntry raise {
  expect_signature(self.bytes, offset, 0x02014b50L)
  let flags = read_u16(self.bytes, offset + 8)
  if (flags & 0x0008) != 0 {
    raise ZipMalformed(reason="data descriptors are not supported")
  }
  let compression = compression_method(read_u16(self.bytes, offset + 10))
  let crc = read_u32(self.bytes, offset + 16)
  let compressed_size = read_u32_int(self.bytes, offset + 20)
  let uncompressed_size = read_u32_int(self.bytes, offset + 24)
  let name_len = read_u16(self.bytes, offset + 28)
  let extra_len = read_u16(self.bytes, offset + 30)
  let comment_len = read_u16(self.bytes, offset + 32)
  let local_offset = read_u32_int(self.bytes, offset + 42)
  ensure_range(self.bytes, offset, 46 + name_len + extra_len + comment_len)
  let name = decode_utf8(bytes_slice(self.bytes, offset + 46, name_len))
  { name, compression, crc, compressed_size, uncompressed_size, local_offset }
}

///|
fn Reader::read_local_entry(
  self : Reader,
  central : CentralEntry,
) -> Entry raise {
  expect_signature(self.bytes, central.local_offset, 0x04034b50L)
  let flags = read_u16(self.bytes, central.local_offset + 6)
  if (flags & 0x0008) != 0 {
    raise ZipMalformed(reason="data descriptors are not supported")
  }
  let local_compression = compression_method(
    read_u16(self.bytes, central.local_offset + 8),
  )
  if local_compression != central.compression {
    raise ZipMalformed(
      reason="local header method differs from central directory",
    )
  }
  let name_len = read_u16(self.bytes, central.local_offset + 26)
  let extra_len = read_u16(self.bytes, central.local_offset + 28)
  let name_start = central.local_offset + 30
  let data_start = name_start + name_len + extra_len
  ensure_range(self.bytes, data_start, central.compressed_size)
  let local_name = decode_utf8(bytes_slice(self.bytes, name_start, name_len))
  if local_name != central.name {
    raise ZipMalformed(
      reason="local header name differs from central directory",
    )
  }
  let compressed = bytes_slice(self.bytes, data_start, central.compressed_size)
  let data = match central.compression {
    Stored => compressed
    Deflate => inflate(compressed, central.uncompressed_size)
  }
  if data.length() != central.uncompressed_size {
    raise ZipMalformed(reason="uncompressed size mismatch")
  }
  let actual = crc32(data)
  if actual != central.crc {
    raise Crc32Mismatch(name=central.name, expected=central.crc, actual~)
  }
  {
    name: central.name,
    data,
    compression: central.compression,
    crc32: central.crc,
    compressed_size: central.compressed_size,
    uncompressed_size: central.uncompressed_size,
  }
}

///|
priv struct BitReader {
  bytes : Bytes
  mut pos : Int
  mut bits : Int
  mut bit_count : Int
}

///|
fn BitReader::new(bytes : Bytes) -> BitReader {
  { bytes, pos: 0, bits: 0, bit_count: 0 }
}

///|
fn BitReader::read_bits(
  self : BitReader,
  count : Int,
) -> Int raise ZipMalformed {
  while self.bit_count < count {
    if self.pos >= self.bytes.length() {
      raise ZipMalformed(reason="truncated deflate stream")
    }
    self.bits = self.bits | (self.bytes[self.pos].to_int() << self.bit_count)
    self.bit_count += 8
    self.pos += 1
  }
  let value = self.bits & ((1 << count) - 1)
  self.bits = self.bits >> count
  self.bit_count -= count
  value
}

///|
fn BitReader::align_byte(self : BitReader) -> Unit {
  self.bits = 0
  self.bit_count = 0
}

///|
priv struct HuffmanEntry {
  code : Int
  len : Int
  symbol : Int
}

///|
priv struct Huffman {
  entries : Array[HuffmanEntry]
  max_len : Int
}

///|
fn Huffman::new(lengths : Array[Int]) -> Huffman raise ZipMalformed {
  let counts = Array::make(16, 0)
  let mut max_len = 0
  for len in lengths {
    if len < 0 || len > 15 {
      raise ZipMalformed(reason="invalid deflate code length")
    }
    if len > 0 {
      counts[len] = counts[len] + 1
      if len > max_len {
        max_len = len
      }
    }
  }
  let next = Array::make(16, 0)
  let mut code = 0
  for bits in 1..<=15 {
    code = (code + counts[bits - 1]) << 1
    next[bits] = code
  }
  let entries : Array[HuffmanEntry] = []
  for symbol in 0..<lengths.length() {
    let len = lengths[symbol]
    if len > 0 {
      entries.push({ code: reverse_bits(next[len], len), len, symbol })
      next[len] = next[len] + 1
    }
  }
  { entries, max_len }
}

///|
fn Huffman::decode(self : Huffman, bits : BitReader) -> Int raise ZipMalformed {
  let mut code = 0
  for len in 1..<=self.max_len {
    code = code | (bits.read_bits(1) << (len - 1))
    for entry in self.entries {
      if entry.len == len && entry.code == code {
        return entry.symbol
      }
    }
  }
  raise ZipMalformed(reason="invalid deflate huffman code")
}

///|
let length_base : Array[Int] = [
  3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83,
  99, 115, 131, 163, 195, 227, 258,
]

///|
let length_extra : Array[Int] = [
  0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5,
  5, 0,
]

///|
let distance_base : Array[Int] = [
  1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769,
  1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577,
]

///|
let distance_extra : Array[Int] = [
  0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11,
  12, 12, 13, 13,
]

///|
fn inflate(bytes : Bytes, expected_size : Int) -> Bytes raise ZipMalformed {
  let bits = BitReader::new(bytes)
  let out : Array[Byte] = []
  let mut final_block = false
  while !final_block {
    final_block = bits.read_bits(1) == 1
    let block_type = bits.read_bits(2)
    match block_type {
      0 => inflate_stored_block(bits, out)
      1 =>
        inflate_compressed_block(
          bits,
          out,
          fixed_literal_huffman(),
          fixed_distance_huffman(),
        )
      2 => {
        let (lit, dist) = dynamic_huffman(bits)
        inflate_compressed_block(bits, out, lit, dist)
      }
      _ => raise ZipMalformed(reason="reserved deflate block type")
    }
    if out.length() > expected_size {
      raise ZipMalformed(reason="deflate output exceeds expected size")
    }
  }
  @buffer.from_array(out[:]).to_bytes()
}

///|
fn inflate_stored_block(
  bits : BitReader,
  out : Array[Byte],
) -> Unit raise ZipMalformed {
  bits.align_byte()
  let len = bits.read_bits(16)
  let nlen = bits.read_bits(16)
  if (len ^ 0xffff) != nlen {
    raise ZipMalformed(reason="invalid stored deflate block length")
  }
  for _ in 0..<len {
    out.push(checked_byte(bits.read_bits(8)))
  }
}

///|
fn inflate_compressed_block(
  bits : BitReader,
  out : Array[Byte],
  lit : Huffman,
  dist : Huffman,
) -> Unit raise ZipMalformed {
  let mut done = false
  while !done {
    let symbol = lit.decode(bits)
    if symbol < 256 {
      out.push(checked_byte(symbol))
    } else if symbol == 256 {
      done = true
    } else if symbol <= 285 {
      let index = symbol - 257
      let len = length_base[index] + bits.read_bits(length_extra[index])
      let dist_symbol = dist.decode(bits)
      if dist_symbol < 0 || dist_symbol >= distance_base.length() {
        raise ZipMalformed(reason="invalid deflate distance symbol")
      }
      let distance = distance_base[dist_symbol] +
        bits.read_bits(distance_extra[dist_symbol])
      if distance <= 0 || distance > out.length() {
        raise ZipMalformed(reason="invalid deflate back-reference distance")
      }
      for _ in 0..<len {
        let b = out[out.length() - distance]
        out.push(b)
      }
    } else {
      raise ZipMalformed(reason="invalid deflate literal/length symbol")
    }
  }
}

///|
fn fixed_literal_huffman() -> Huffman raise ZipMalformed {
  let lengths = Array::make(288, 0)
  for i in 0..<=143 {
    lengths[i] = 8
  }
  for i in 144..<=255 {
    lengths[i] = 9
  }
  for i in 256..<=279 {
    lengths[i] = 7
  }
  for i in 280..<=287 {
    lengths[i] = 8
  }
  Huffman::new(lengths)
}

///|
fn fixed_distance_huffman() -> Huffman raise ZipMalformed {
  Huffman::new(Array::make(32, 5))
}

///|
let code_length_order : Array[Int] = [
  16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15,
]

///|
fn dynamic_huffman(bits : BitReader) -> (Huffman, Huffman) raise ZipMalformed {
  let hlit = bits.read_bits(5) + 257
  let hdist = bits.read_bits(5) + 1
  let hclen = bits.read_bits(4) + 4
  let code_lengths = Array::make(19, 0)
  for i in 0..<hclen {
    code_lengths[code_length_order[i]] = bits.read_bits(3)
  }
  let code_huffman = Huffman::new(code_lengths)
  let lengths : Array[Int] = []
  let total = hlit + hdist
  let mut previous = 0
  while lengths.length() < total {
    let symbol = code_huffman.decode(bits)
    match symbol {
      0..=15 => {
        lengths.push(symbol)
        previous = symbol
      }
      16 => {
        if lengths.is_empty() {
          raise ZipMalformed(reason="deflate repeat has no previous length")
        }
        let repeat = bits.read_bits(2) + 3
        for _ in 0..<repeat {
          lengths.push(previous)
        }
      }
      17 => {
        let repeat = bits.read_bits(3) + 3
        for _ in 0..<repeat {
          lengths.push(0)
        }
        previous = 0
      }
      18 => {
        let repeat = bits.read_bits(7) + 11
        for _ in 0..<repeat {
          lengths.push(0)
        }
        previous = 0
      }
      _ => raise ZipMalformed(reason="invalid deflate code-length symbol")
    }
  }
  if lengths.length() != total {
    raise ZipMalformed(reason="deflate code lengths overrun")
  }
  (
    Huffman::new(lengths.view(end=hlit).to_owned()),
    Huffman::new(lengths.view(start=hlit).to_owned()),
  )
}
