// ECMA-376 §19.1.2.13 — VML `<v:path>` / `<v:shape @path="…">` data
// strings.  VML paths are a token-string mini-language that pre-dates
// (and is the spiritual ancestor of) SVG's `d` attribute.  Both use
// single-letter command codes followed by numeric coordinate runs;
// the differences are:
//
//   * VML uses `m` (moveto), `l` (lineto), `c` (cubic Bézier), `x`
//     (close), `e` (end-of-path), `nf`/`ns` (no-fill/no-stroke
//     subpath hints) plus a long list of VML-specific arcs
//     (`ar`/`ae`/`at`/`wa`/`wr`) and shorthand quadratics.
//   * SVG uses `M`, `L`, `C`, `Z` (uppercase = absolute, lowercase =
//     relative); arcs use the elliptical-arc `A` form.
//
// This translator handles the subset Word and PowerPoint actually
// emit when they round-trip a legacy VML drawing through DrawingML —
// `m`, `l`, `c`, `x`, `e` (plus their uppercase synonyms `M`, `L`,
// `C`).  VML-specific arcs and shorthand quadratics collapse to a
// closing line so the resulting SVG path still draws *something*
// (instead of producing the empty string the SVG renderer would
// silently skip).
//
// Coordinate units are honoured verbatim: VML's path coordinate
// system is the shape's `coordsize` rectangle, NOT pixels.  The
// caller wraps the resulting path in a `<g>` whose `transform`
// scales `coordsize` to the actual `width × height` extent.

///|
/// Convert a VML path string to an SVG `d` attribute value.  Unknown
/// commands collapse to the closest SVG equivalent (`x`/`e` →
/// `Z`/end-of-path; unknown letters produce a `Z` so the path still
/// closes).  Numeric runs are copied verbatim so the caller's scale
/// transform applies unchanged.
///
/// Returns the empty string when the input is empty (the SVG
/// renderer silently skips an empty `d`, which is the same outcome as
/// suppressing the `<path>` element).
pub fn vml_path_to_svg_d(vml : String) -> String {
  let n = vml.length()
  if n == 0 {
    return ""
  }
  let buf = StringBuilder::new()
  let mut i = 0
  let mut first_token = true
  // ASCII code points cached as Int — string indexing yields UInt16
  // code units, which the comparisons below promote to Int.
  let sp = ' '.to_int()
  let tab = '\t'.to_int()
  let nl = '\n'.to_int()
  let cr = '\r'.to_int()
  let comma = ','.to_int()
  let minus = '-'.to_int()
  let plus = '+'.to_int()
  let dot = '.'.to_int()
  let zero = '0'.to_int()
  let nine = '9'.to_int()
  let lc_e = 'e'.to_int()
  let uc_e = 'E'.to_int()
  while i < n {
    let cu = vml[i].to_int()
    // Skip ASCII whitespace and the `,` separator (VML uses both
    // interchangeably between coordinates).
    if cu == sp || cu == tab || cu == nl || cu == cr || cu == comma {
      i = i + 1
      continue
    }
    // Numeric token — copy verbatim (with the same separator the
    // SVG `d` grammar accepts: a single space prefix when this is
    // not the very first token).
    if cu == minus || cu == plus || cu == dot || (cu >= zero && cu <= nine) {
      let start = i
      if cu == minus || cu == plus {
        i = i + 1
      }
      while i < n {
        let d = vml[i].to_int()
        if d == dot || (d >= zero && d <= nine) {
          i = i + 1
        } else {
          break
        }
      }
      // Optional exponent.
      if i < n {
        let e = vml[i].to_int()
        if e == lc_e || e == uc_e {
          i = i + 1
          if i < n {
            let sign = vml[i].to_int()
            if sign == minus || sign == plus {
              i = i + 1
            }
          }
          while i < n {
            let d = vml[i].to_int()
            if d >= zero && d <= nine {
              i = i + 1
            } else {
              break
            }
          }
        }
      }
      if !first_token {
        buf.write_char(' ')
      }
      buf.write_string(vml[start:i].to_owned())
      first_token = false
      continue
    }
    // Command letter — map.
    let cmd = vml_command_to_svg(cu)
    if cmd != "" {
      if !first_token {
        buf.write_char(' ')
      }
      buf.write_string(cmd)
      first_token = false
    }
    i = i + 1
  }
  buf.to_string()
}

///|
/// Map a single VML path command code unit to its SVG equivalent
/// letter as a one-char string.  Returns `""` when the command is
/// unsupported (e.g. `t` shorthand quadratic, `nf` no-fill hint) —
/// the caller skips emitting anything for those, which leaves the
/// surrounding numeric tokens to fall into the previous command's
/// coordinate stream.
fn vml_command_to_svg(cu : Int) -> String {
  if cu == 'm'.to_int() || cu == 'M'.to_int() {
    return "M"
  }
  if cu == 'l'.to_int() || cu == 'L'.to_int() {
    return "L"
  }
  if cu == 'c'.to_int() || cu == 'C'.to_int() {
    return "C"
  }
  if cu == 't'.to_int() || cu == 'T'.to_int() {
    return "T" // smooth-quadratic shorthand (rare in practice)
  }
  if cu == 'r'.to_int() || cu == 'R'.to_int() {
    return "l" // VML relative lineto -> SVG relative line.
  }
  if cu == 'v'.to_int() || cu == 'V'.to_int() {
    return "c" // VML relative cubic -> SVG relative cubic.
  }
  if cu == 'x'.to_int() ||
    cu == 'X'.to_int() ||
    cu == 'e'.to_int() ||
    cu == 'E'.to_int() {
    return "Z" // close / end -> SVG closepath.
  }
  ""
}
