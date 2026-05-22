///|
test "encode empty bytes returns empty string" {
  inspect(encode(Bytes::new(0)), content="")
}

///|
test "encode three ascii bytes produces no padding" {
  inspect(encode(b"abc"), content="YWJj")
}

///|
test "encode two ascii bytes pads with single equal sign" {
  inspect(encode(b"ab"), content="YWI=")
}

///|
test "encode one ascii byte pads with two equal signs" {
  inspect(encode(b"a"), content="YQ==")
}

///|
test "encode RFC 4648 vector 'Man' encodes to TWFu" {
  inspect(encode(b"Man"), content="TWFu")
}

///|
test "encode binary bytes round-trip through alphabet" {
  inspect(encode(b"\x00\x01\x02\x03"), content="AAECAw==")
}
