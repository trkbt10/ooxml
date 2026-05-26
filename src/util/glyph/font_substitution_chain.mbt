// ECMA-376 font substitution chain.
//
// The renderer turns a document's font reference (a `<w:rFonts>`
// element, an `<a:latin typeface="...">`, an `<a:font script="...">`
// override, or just a bare family name) into a `FontFaceRequest`
// whose `stack` carries every alternative the spec lets the
// consumer try. The resolver then walks the stack in order.
//
// The chain implemented here follows ECMA-376 Part 1:
//
//   §17.8.2.10 CT_Font          — primary `<w:rFonts w:ascii>`/etc names
//   §17.8.2.1  <w:altName>      — author-supplied alternative
//   §17.8.2.13 <w:panose1>      — PANOSE-1 classification (mapped to
//                                  generic family via Latin-1 family
//                                  byte; §17.18 references)
//   §17.8.2.5  <w:family>       — typed family hint, mapped to CSS
//                                  generic per §17.18.30 ST_FontFamily
//   §17.8.2.4  <w:embedRegular> — embedded face (regular cut)
//   §17.8.2.4  <w:embedBold>    — embedded face (bold cut)
//   §17.8.2.4  <w:embedItalic>  — embedded face (italic cut)
//   §17.8.2.4  <w:embedBoldItalic>
//
//   §20.1.4.1.18 CT_FontScheme  — theme major/minor font collections
//   §20.1.4.1.9  CT_FontCollection — latin/ea/cs typefaces +
//                                    `<a:font script="...">` overrides
//
// The chain itself owns no font bytes — embedded payload, when
// present, must be looked up by the renderer (typically via the
// `<w:embedRegular w:id="rId...">` relationship) and passed in
// through the `embedded_bytes` field.

///|
/// Selector bits a caller supplies alongside the document-side font
/// reference. `bold` and `italic` come from `<w:b>` / `<w:i>` runs
/// or from typography defaults; `embedded_bytes` is the resolved
/// payload of the matching `<w:embed*>` relationship.
pub(all) struct FontResolutionRequest {
  /// Primary family name from the document (e.g.
  /// `<w:rFonts w:ascii="Calibri">.ascii`, `<a:latin typeface="Arial">`).
  primary : String?
  /// Author-supplied `<w:altName w:val="..."/>` per §17.8.2.1.
  alt_name : String?
  /// `<w:family>` (CT_FontFamily) per §17.8.2.5 mapped to a generic
  /// family. `None` when the document omitted the hint or supplied
  /// `auto`.
  family_hint : GenericFamily?
  /// `<w:panose1>` (CT_Panose) per §17.8.2.13 — the raw 10-octet
  /// hex string. The chain decodes the Latin-1 family byte into
  /// `family_hint` when no explicit hint was supplied.
  panose1 : String?
  /// Embedded font payload supplied by the renderer after resolving
  /// the matching `<w:embed*>` / `<a:embeddedFontLst>` reference.
  embedded_bytes : Bytes?
  /// `<w:b>` cascade resolved by the caller. ≥ 600 selects bold.
  weight : Int
  /// `<w:i>` cascade resolved by the caller.
  italic : Bool
}

///|
/// Build a `FontFaceRequest` whose `stack` walks the ECMA-376
/// substitution chain in spec-prescribed order:
///
///   1. primary explicit name (`<w:rFonts w:ascii>`, `<a:latin typeface>`)
///   2. author-supplied `<w:altName>`
///   3. PANOSE-derived generic family (when no explicit hint)
///   4. `<w:family>` typed generic family
///
/// Embedded bytes always win at the resolver layer regardless of
/// stack contents; they are propagated through `embedded_bytes`.
pub fn build_font_face_request(
  request : FontResolutionRequest,
) -> FontFaceRequest {
  let stack : Array[FontStackCandidate] = []
  match request.primary {
    Some(n) => stack.push(Name(n))
    None => ()
  }
  match request.alt_name {
    Some(n) => stack.push(Name(n))
    None => ()
  }
  // PANOSE-1 family-byte (offset 0, 0x01 = latin text, 0x02 = latin
  // hand-written, etc.). The renderer-side mapping here only kicks
  // in when no `<w:family>` hint was supplied — the typed hint is
  // always the more reliable signal.
  let derived_from_panose = match request.family_hint {
    Some(_) => None
    None => panose_to_generic(request.panose1)
  }
  match request.family_hint {
    Some(g) => stack.push(Generic(g))
    None =>
      match derived_from_panose {
        Some(g) => stack.push(Generic(g))
        None => ()
      }
  }
  {
    stack,
    weight: request.weight,
    italic: request.italic,
    embedded_bytes: request.embedded_bytes,
  }
}

///|
/// Decode the PANOSE-1 family byte (the first octet of the 10-byte
/// `<w:panose1>` hex string) into a CSS generic family. Returns
/// `None` when the string is missing, too short, or carries a
/// family byte the spec does not map to a generic.
///
/// PANOSE-1 family byte values (Microsoft Open Specifications):
///   0x00 Any                → no hint
///   0x01 No-Fit             → no hint
///   0x02 Latin Text         → serif / sans / mono / cursive
///                              decided by Serif-Style byte (offset 1)
///   0x03 Latin Hand Written → cursive
///   0x04 Latin Decorative   → fantasy
///   0x05 Latin Symbol       → no hint (rendered with symbol font)
fn panose_to_generic(panose1 : String?) -> GenericFamily? {
  match panose1 {
    None => None
    Some(s) => {
      let trimmed = s.trim(chars=" \t\r\n").to_owned()
      if trimmed.length() < 2 {
        return None
      }
      let chars : Array[Char] = []
      for c in trimmed {
        chars.push(c)
      }
      let family_byte = parse_hex_octet(chars, 0)
      match family_byte {
        Some(0x03) => Some(Cursive)
        Some(0x04) => Some(Fantasy)
        Some(0x02) => {
          // Latin Text — decide serif vs sans vs mono from the
          // Serif-Style byte at offset 1. PANOSE Serif-Style
          // ranges per the OpenType spec:
          //   0x00..0x01 Any/No-Fit → no hint
          //   0x02..0x09 various serif styles → Serif
          //   0x0A..0x0D various sans styles → SansSerif
          //   0x0E       Rounded → SansSerif
          //   0x0F       Script → no hint
          //   0x10       Perp/Sans → SansSerif
          // Monospace is signalled by Proportion-byte (offset 3)
          // == 0x09 (Monospaced); we apply that override below.
          let serif_style = parse_hex_octet(chars, 1)
          let proportion = parse_hex_octet(chars, 3)
          if proportion == Some(0x09) {
            return Some(Monospace)
          }
          match serif_style {
            Some(v) =>
              if v >= 0x0A && v <= 0x10 {
                Some(SansSerif)
              } else if v >= 0x02 && v <= 0x09 {
                Some(Serif)
              } else {
                None
              }
            None => None
          }
        }
        _ => None
      }
    }
  }
}

///|
/// Parse a hex octet at `chars[index * 2..index * 2 + 2]`. Returns
/// `None` when the slice contains non-hex characters or is short.
fn parse_hex_octet(chars : Array[Char], index : Int) -> Int? {
  let start = index * 2
  if start + 2 > chars.length() {
    return None
  }
  let hi = hex_digit(chars[start])
  let lo = hex_digit(chars[start + 1])
  match (hi, lo) {
    (Some(h), Some(l)) => Some(h * 16 + l)
    _ => None
  }
}

///|
fn hex_digit(c : Char) -> Int? {
  if c >= '0' && c <= '9' {
    Some(c.to_int() - '0'.to_int())
  } else if c >= 'a' && c <= 'f' {
    Some(c.to_int() - 'a'.to_int() + 10)
  } else if c >= 'A' && c <= 'F' {
    Some(c.to_int() - 'A'.to_int() + 10)
  } else {
    None
  }
}

///|
/// Resolve a substitution chain to a measurer by walking it through
/// the default font set. Wraps `measurer_for_request` so callers
/// don't have to repeat the `default_font_set()` lookup.
pub fn resolve_chain(
  request : FontResolutionRequest,
) -> FontMeasurer raise FontUnresolvedError {
  default_font_set().measurer_for_request(build_font_face_request(request))
}
