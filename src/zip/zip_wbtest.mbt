///|
fn b(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "write and read stored entries" {
  let archive = Archive::new([
    ("word/document.xml", b("<w:document/>")),
    ("docProps/core.xml", b("core")),
  ])
  let encoded = write(archive)
  let parsed = read(encoded)
  assert_eq(parsed.entries.length(), 2)
  assert_eq(parsed.entries[0].name, "word/document.xml")
  assert_true(bytes_equal(parsed.entries[0].data, b("<w:document/>")))
  assert_eq(parsed.entries[1].name, "docProps/core.xml")
  assert_true(bytes_equal(parsed.entries[1].data, b("core")))
}

///|
test "read deflate entry with fixed huffman block" {
  let archive = read(fixed_deflate_zip()) catch {
    ZipMalformed(reason~) => fail(reason)
    err => raise err
  }
  assert_eq(archive.entries.length(), 1)
  assert_eq(archive.entries[0].name, "hello.txt")
  assert_true(bytes_equal(archive.entries[0].data, b("hello hello hello\n")))
  assert_true(archive.entries[0].compression == Deflate)
}

///|
test "write and read deflate entries" {
  let data = b(
    "<worksheet><row><c>hello hello hello</c></row><row><c>hello hello hello</c></row></worksheet>",
  )
  let archive : Archive = {
    entries: [
      {
        name: "xl/worksheets/sheet1.xml",
        data,
        compression: Deflate,
        crc32: crc32(data),
        compressed_size: data.length(),
        uncompressed_size: data.length(),
      },
    ],
  }
  let parsed = read(write(archive))
  assert_eq(parsed.entries.length(), 1)
  assert_eq(parsed.entries[0].name, "xl/worksheets/sheet1.xml")
  assert_true(parsed.entries[0].compression == Deflate)
  assert_true(parsed.entries[0].compressed_size < data.length())
  assert_eq(parsed.entries[0].crc32, crc32(data))
  assert_true(bytes_equal(parsed.entries[0].data, data))
}

///|
test "write deflate small input may expand" {
  let data = b("0123456789")
  let archive : Archive = {
    entries: [
      {
        name: "small.txt",
        data,
        compression: Deflate,
        crc32: crc32(data),
        compressed_size: data.length(),
        uncompressed_size: data.length(),
      },
    ],
  }
  let parsed = read(write(archive))
  assert_eq(parsed.entries.length(), 1)
  assert_true(parsed.entries[0].compression == Deflate)
  assert_true(bytes_equal(parsed.entries[0].data, data))
}

///|
test "read entry with data descriptor" {
  let archive = read(data_descriptor_zip()) catch {
    ZipMalformed(reason~) => fail(reason)
    err => raise err
  }
  assert_eq(archive.entries.length(), 1)
  assert_eq(archive.entries[0].name, "a.txt")
  assert_true(bytes_equal(archive.entries[0].data, b("abc")))
}

///|
test "read zip64 eocd locator and extra field" {
  let archive = read(zip64_zip()) catch {
    ZipMalformed(reason~) => fail(reason)
    err => raise err
  }
  assert_eq(archive.entries.length(), 1)
  assert_eq(archive.entries[0].name, "z.txt")
  assert_true(bytes_equal(archive.entries[0].data, b("zip64")))
}

///|
test "reject crc mismatch" {
  let archive = Archive::new([("a.txt", b("abc"))])
  let encoded = write(archive)
  let raw : Array[Byte] = []
  raw.push_iter(encoded[:].iter())
  raw[35] = b'X'
  let tampered = @buffer.from_array(raw[:]).to_bytes()
  try read(tampered) catch {
    Crc32Mismatch(_) => ()
    _ => fail("expected Crc32Mismatch")
  } noraise {
    _ => fail("expected CRC failure")
  }
}

///|
fn bytes_equal(a : Bytes, b : Bytes) -> Bool {
  if a.length() != b.length() {
    false
  } else {
    let mut ok = true
    for i in 0..<a.length() {
      if a[i] != b[i] {
        ok = false
      }
    }
    ok
  }
}

///|
fn fixed_deflate_zip() -> Bytes {
  // Created with Python zlib using a raw fixed-Huffman Deflate stream.
  let raw : Array[Byte] = [
    b'\x50', b'\x4b', b'\x03', b'\x04', b'\x14', b'\x00', b'\x00', b'\x08', b'\x08',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x3b', b'\x7c', b'\x8a', b'\xdf',
    b'\x0b', b'\x00', b'\x00', b'\x00', b'\x12', b'\x00', b'\x00', b'\x00', b'\x09',
    b'\x00', b'\x00', b'\x00', b'\x68', b'\x65', b'\x6c', b'\x6c', b'\x6f', b'\x2e',
    b'\x74', b'\x78', b'\x74', b'\xcb', b'\x48', b'\xcd', b'\xc9', b'\xc9', b'\x57',
    b'\xc8', b'\x40', b'\x90', b'\x5c', b'\x00', b'\x50', b'\x4b', b'\x01', b'\x02',
    b'\x14', b'\x00', b'\x14', b'\x00', b'\x00', b'\x08', b'\x08', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x3b', b'\x7c', b'\x8a', b'\xdf', b'\x0b', b'\x00',
    b'\x00', b'\x00', b'\x12', b'\x00', b'\x00', b'\x00', b'\x09', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x68', b'\x65', b'\x6c',
    b'\x6c', b'\x6f', b'\x2e', b'\x74', b'\x78', b'\x74', b'\x50', b'\x4b', b'\x05',
    b'\x06', b'\x00', b'\x00', b'\x00', b'\x00', b'\x01', b'\x00', b'\x01', b'\x00',
    b'\x37', b'\x00', b'\x00', b'\x00', b'\x32', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00',
  ]
  @buffer.from_array(raw[:]).to_bytes()
}

///|
fn data_descriptor_zip() -> Bytes {
  let out = Buffer()
  let name = b("a.txt")
  let data = b("abc")
  let crc = crc32(data)
  write_u32(out, 0x04034b50L)
  write_u16(out, 20)
  write_u16(out, 0x0808)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u32(out, 0L)
  write_u32(out, 0L)
  write_u32(out, 0L)
  write_u16(out, name.length())
  write_u16(out, 0)
  write_bytes(out, name)
  write_bytes(out, data)
  write_u32(out, 0x08074b50L)
  write_u32(out, crc)
  write_u32(out, data.length().to_int64())
  write_u32(out, data.length().to_int64())
  let central_offset = out.length()
  write_u32(out, 0x02014b50L)
  write_u16(out, 20)
  write_u16(out, 20)
  write_u16(out, 0x0808)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u32(out, crc)
  write_u32(out, data.length().to_int64())
  write_u32(out, data.length().to_int64())
  write_u16(out, name.length())
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u32(out, 0L)
  write_u32(out, 0L)
  write_bytes(out, name)
  let central_size = out.length() - central_offset
  write_eocd(out, 1, central_size, central_offset)
  out.to_bytes()
}

///|
fn zip64_zip() -> Bytes {
  let out = Buffer()
  let name = b("z.txt")
  let data = b("zip64")
  let crc = crc32(data)
  write_u32(out, 0x04034b50L)
  write_u16(out, 20)
  write_u16(out, 0x0800)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u32(out, crc)
  write_u32(out, data.length().to_int64())
  write_u32(out, data.length().to_int64())
  write_u16(out, name.length())
  write_u16(out, 0)
  write_bytes(out, name)
  write_bytes(out, data)
  let central_offset = out.length()
  write_u32(out, 0x02014b50L)
  write_u16(out, 45)
  write_u16(out, 45)
  write_u16(out, 0x0800)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u32(out, crc)
  write_u32(out, 0xffffffffL)
  write_u32(out, 0xffffffffL)
  write_u16(out, name.length())
  write_u16(out, 28)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u32(out, 0L)
  write_u32(out, 0xffffffffL)
  write_bytes(out, name)
  write_u16(out, 0x0001)
  write_u16(out, 24)
  write_u64(out, data.length())
  write_u64(out, data.length())
  write_u64(out, 0)
  let central_size = out.length() - central_offset
  let zip64_eocd_offset = out.length()
  write_u32(out, 0x06064b50L)
  write_u64(out, 44)
  write_u16(out, 45)
  write_u16(out, 45)
  write_u32(out, 0L)
  write_u32(out, 0L)
  write_u64(out, 1)
  write_u64(out, 1)
  write_u64(out, central_size)
  write_u64(out, central_offset)
  write_u32(out, 0x07064b50L)
  write_u32(out, 0L)
  write_u64(out, zip64_eocd_offset)
  write_u32(out, 1L)
  write_u32(out, 0x06054b50L)
  write_u16(out, 0)
  write_u16(out, 0)
  write_u16(out, 0xffff)
  write_u16(out, 0xffff)
  write_u32(out, 0xffffffffL)
  write_u32(out, 0xffffffffL)
  write_u16(out, 0)
  out.to_bytes()
}

///|
fn write_u64(out : @buffer.Buffer, value : Int) -> Unit {
  write_u32(out, value.to_int64())
  write_u32(out, 0L)
}
