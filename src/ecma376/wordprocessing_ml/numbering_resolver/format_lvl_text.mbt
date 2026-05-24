///|
/// Part 1 §17.9.11 lvlText — substitute `%N` placeholders in the
/// template with the formatted counter value for 1-based level `N`.
/// `counters[i]` holds the current counter value for `ilvl = i`.
/// `formats[i]` holds the §17.18.59 ST_NumberFormat to apply to that
/// counter; absent / out-of-range formats fall back to `NumFmtDecimal`.
/// `%%` collapses to literal `%`; trailing `%` with no digit is left
/// as-is.
pub fn format_lvl_text(
  template : String,
  counters : Array[Int],
  formats : Array[@domain.ST_NumberFormat],
) -> String {
  let buf = StringBuilder::new()
  let mut i = 0
  while i < template.length() {
    let unit = template.code_unit_at(i).to_int()
    if unit == 0x25 {
      // '%'
      if i + 1 >= template.length() {
        buf.write_char('%')
        i = i + 1
      } else {
        let next = template.code_unit_at(i + 1).to_int()
        if next == 0x25 {
          buf.write_char('%')
          i = i + 2
        } else if next >= 0x31 && next <= 0x39 {
          let level_index = next - 0x30 - 1
          let value = if level_index >= 0 && level_index < counters.length() {
            counters[level_index]
          } else {
            0
          }
          let fmt = if level_index >= 0 && level_index < formats.length() {
            formats[level_index]
          } else {
            @domain.NumFmtDecimal
          }
          buf.write_string(fmt.format(value))
          i = i + 2
        } else {
          buf.write_char('%')
          i = i + 1
        }
      }
    } else {
      // §17.9.11 lvlText — the template is xsd:string, which is
      // UTF-16 in MoonBit; supplementary-plane characters (emoji
      // bullets, CJK characters above U+FFFF) are encoded as a
      // high-surrogate (0xD800..0xDBFF) + low-surrogate
      // (0xDC00..0xDFFF) pair.  When we see a high surrogate at
      // position `i`, consume the next code unit together so the
      // pair becomes a single Unicode code point.  Lone
      // surrogates (schema violation) are written verbatim so
      // the round-trip surfaces the breach upstream.
      if unit >= 0xD800 && unit <= 0xDBFF && i + 1 < template.length() {
        let low = template.code_unit_at(i + 1).to_int()
        if low >= 0xDC00 && low <= 0xDFFF {
          let code_point = 0x10000 + (unit - 0xD800) * 0x400 + (low - 0xDC00)
          buf.write_char(Char::from_int(code_point))
          i = i + 2
          continue
        }
      }
      buf.write_char(unit.to_char().unwrap())
      i = i + 1
    }
  }
  buf.to_string()
}
