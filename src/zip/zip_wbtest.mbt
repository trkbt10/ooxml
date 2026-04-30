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
