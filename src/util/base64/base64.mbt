///|
/// Standard RFC 4648 §4 base64 alphabet (A-Z, a-z, 0-9, +, /).
let alphabet : Bytes = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

///|
/// Encode `bytes` to a base64 ASCII String per RFC 4648 §4. Output
/// length is `ceil(len/3) * 4`, padded with `=` so it is a multiple
/// of 4. Suitable for `data:` URIs.
pub fn encode(bytes : Bytes) -> String {
  let len = bytes.length()
  let buf = StringBuilder::new()
  let mut i = 0
  while i + 3 <= len {
    let b0 = bytes[i].to_int()
    let b1 = bytes[i + 1].to_int()
    let b2 = bytes[i + 2].to_int()
    let n = (b0 << 16) | (b1 << 8) | b2
    buf.write_char(alphabet[(n >> 18) & 0x3F].to_int().to_char().unwrap())
    buf.write_char(alphabet[(n >> 12) & 0x3F].to_int().to_char().unwrap())
    buf.write_char(alphabet[(n >> 6) & 0x3F].to_int().to_char().unwrap())
    buf.write_char(alphabet[n & 0x3F].to_int().to_char().unwrap())
    i = i + 3
  }
  let rem = len - i
  if rem == 1 {
    let b0 = bytes[i].to_int()
    let n = b0 << 16
    buf.write_char(alphabet[(n >> 18) & 0x3F].to_int().to_char().unwrap())
    buf.write_char(alphabet[(n >> 12) & 0x3F].to_int().to_char().unwrap())
    buf.write_char('=')
    buf.write_char('=')
  } else if rem == 2 {
    let b0 = bytes[i].to_int()
    let b1 = bytes[i + 1].to_int()
    let n = (b0 << 16) | (b1 << 8)
    buf.write_char(alphabet[(n >> 18) & 0x3F].to_int().to_char().unwrap())
    buf.write_char(alphabet[(n >> 12) & 0x3F].to_int().to_char().unwrap())
    buf.write_char(alphabet[(n >> 6) & 0x3F].to_int().to_char().unwrap())
    buf.write_char('=')
  }
  buf.to_string()
}
