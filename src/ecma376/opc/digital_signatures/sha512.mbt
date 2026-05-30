// FIPS 180-4 SHA-512 / SHA-384 message digest.
//
// The bundled `@crypto` dependency exposes SHA-1, SHA-224, SHA-256, MD5 and
// SM3, but NOT the 64-bit SHA-2 variants.  XML-Signature §6.4 registers
// SHA-384 (RFC 4051 §2.1) and SHA-512 (xmlenc §5.7) as Reference digest
// algorithms, and Office package signatures from the 2013 generation use
// SHA-512, so this module supplies them directly.
//
// SHA-384 is SHA-512 with a distinct initial hash value and the output
// truncated to the leftmost 384 bits (48 bytes); both share the same
// 1024-bit block transform, 80 rounds, and round constants.  The
// implementation is one-shot (the whole message is available when a
// Reference digest is computed) and is verified against the NIST published
// vectors in `digital_signatures_wbtest.mbt`.

///|
/// FIPS 180-4 §4.2.3 SHA-512 round constants `K[0..79]` (fractional parts of
/// the cube roots of the first eighty primes).
let sha512_k : FixedArray[UInt64] = [
  0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc,
  0x3956c25bf348b538, 0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118,
  0xd807aa98a3030242, 0x12835b0145706fbe, 0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2,
  0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 0xc19bf174cf692694,
  0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
  0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5,
  0x983e5152ee66dfab, 0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4,
  0xc6e00bf33da88fc2, 0xd5a79147930aa725, 0x06ca6351e003826f, 0x142929670a0e6e70,
  0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 0x53380d139d95b3df,
  0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
  0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30,
  0xd192e819d6ef5218, 0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8,
  0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8,
  0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 0x682e6ff3d6b2b8a3,
  0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
  0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b,
  0xca273eceea26619c, 0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178,
  0x06f067aa72176fba, 0x0a637dc5a2c898a6, 0x113f9804bef90dae, 0x1b710b35131c471b,
  0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 0x431d67c49c100d4c,
  0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817,
]

///|
/// FIPS 180-4 §5.3.5 SHA-512 initial hash value `H(0)`.
fn sha512_iv() -> FixedArray[UInt64] {
  [
    0x6a09e667f3bcc908, 0xbb67ae8584caa73b, 0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
    0x510e527fade682d1, 0x9b05688c2b3e6c1f, 0x1f83d9abfb41bd6b, 0x5be0cd19137e2179,
  ]
}

///|
/// FIPS 180-4 §5.3.4 SHA-384 initial hash value `H(0)`.
fn sha384_iv() -> FixedArray[UInt64] {
  [
    0xcbbb9d5dc1059ed8, 0x629a292a367cd507, 0x9159015a3070dd17, 0x152fecd8f70e5939,
    0x67332667ffc00b31, 0x8eb44a8768581511, 0xdb0c2e0d64f98fa7, 0x47b5481dbefa4fa4,
  ]
}

///|
/// Right rotation of a 64-bit word (FIPS 180-4 §3.2 `ROTR^n`).
fn sha512_rotr(x : UInt64, n : Int) -> UInt64 {
  (x >> n) | (x << (64 - n))
}

///|
/// Read eight bytes big-endian into a 64-bit word.
fn sha512_be_u64(data : FixedArray[Byte], i : Int) -> UInt64 {
  (data[i].to_uint64() << 56) |
  (data[i + 1].to_uint64() << 48) |
  (data[i + 2].to_uint64() << 40) |
  (data[i + 3].to_uint64() << 32) |
  (data[i + 4].to_uint64() << 24) |
  (data[i + 5].to_uint64() << 16) |
  (data[i + 6].to_uint64() << 8) |
  data[i + 7].to_uint64()
}

///|
/// FIPS 180-4 §6.4.2 SHA-512 block transform over one 1024-bit (128-byte)
/// block at `off`, updating the eight-word working hash `h` in place.
fn sha512_transform(
  data : FixedArray[Byte],
  off : Int,
  h : FixedArray[UInt64],
) -> Unit {
  let all_ones : UInt64 = 0xffffffffffffffff
  let w = FixedArray::make(80, (0 : UInt64))
  for t in 0..<16 {
    w[t] = sha512_be_u64(data, off + 8 * t)
  }
  for t in 16..<80 {
    let s0 = sha512_rotr(w[t - 15], 1) ^
      sha512_rotr(w[t - 15], 8) ^
      (w[t - 15] >> 7)
    let s1 = sha512_rotr(w[t - 2], 19) ^
      sha512_rotr(w[t - 2], 61) ^
      (w[t - 2] >> 6)
    w[t] = w[t - 16] + s0 + w[t - 7] + s1
  }
  let mut a = h[0]
  let mut b = h[1]
  let mut c = h[2]
  let mut d = h[3]
  let mut e = h[4]
  let mut f = h[5]
  let mut g = h[6]
  let mut hh = h[7]
  for t in 0..<80 {
    let big_sigma_1 = sha512_rotr(e, 14) ^
      sha512_rotr(e, 18) ^
      sha512_rotr(e, 41)
    let ch = (e & f) ^ ((e ^ all_ones) & g)
    let temp1 = hh + big_sigma_1 + ch + sha512_k[t] + w[t]
    let big_sigma_0 = sha512_rotr(a, 28) ^
      sha512_rotr(a, 34) ^
      sha512_rotr(a, 39)
    let maj = (a & b) ^ (a & c) ^ (b & c)
    let temp2 = big_sigma_0 + maj
    hh = g
    g = f
    f = e
    e = d + temp1
    d = c
    c = b
    b = a
    a = temp1 + temp2
  }
  h[0] = h[0] + a
  h[1] = h[1] + b
  h[2] = h[2] + c
  h[3] = h[3] + d
  h[4] = h[4] + e
  h[5] = h[5] + f
  h[6] = h[6] + g
  h[7] = h[7] + hh
}

///|
/// Shared SHA-512 / SHA-384 driver: pad `input` per FIPS 180-4 §5.1.2,
/// process every 1024-bit block from the supplied initial hash value, then
/// emit the leftmost `out_bytes` of the final hash.
fn sha512_core(
  input : Bytes,
  iv : FixedArray[UInt64],
  out_bytes : Int,
) -> FixedArray[Byte] {
  let msg_len = input.length()
  // Padded length: message ‖ 0x80 ‖ k·0x00 ‖ 128-bit length, rounded up to a
  // whole number of 128-byte blocks.
  let k = (128 - (msg_len + 17) % 128) % 128
  let total = msg_len + 1 + k + 16
  let data = FixedArray::make(total, (0 : Byte))
  for i in 0..<msg_len {
    data[i] = input[i]
  }
  data[msg_len] = (0x80 : Byte)
  // The message bit length occupies the trailing 128 bits, big-endian.  The
  // high 64 bits stay zero (messages never approach 2^64 bits here); the low
  // 64 bits carry `msg_len * 8`.
  let bit_len = msg_len.to_uint64() * 8
  for j in 0..<8 {
    data[total - 1 - j] = (bit_len >> (8 * j)).to_byte()
  }
  let h = iv.copy()
  let nblocks = total / 128
  for blk in 0..<nblocks {
    sha512_transform(data, blk * 128, h)
  }
  let out = FixedArray::make(out_bytes, (0 : Byte))
  let nwords = out_bytes / 8
  for wi in 0..<nwords {
    for j in 0..<8 {
      out[wi * 8 + j] = (h[wi] >> (8 * (7 - j))).to_byte()
    }
  }
  out
}

///|
/// FIPS 180-4 SHA-512 digest of `input` (64 bytes).
fn sha512_bytes(input : Bytes) -> FixedArray[Byte] {
  sha512_core(input, sha512_iv(), 64)
}

///|
/// FIPS 180-4 SHA-384 digest of `input` (48 bytes).
fn sha384_bytes(input : Bytes) -> FixedArray[Byte] {
  sha512_core(input, sha384_iv(), 48)
}
