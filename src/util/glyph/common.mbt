// @source web-pptx packages/@aurochs/glyph/src/metrics/fonts/common.ts

///|
/// Common narrow Latin characters (width ~0.2-0.35 em).
/// Mirrors `NARROW_CHARS` in `common.ts:10`.
fn narrow_chars() -> Map[Char, Double] {
  {
    'i': 0.25,
    'l': 0.25,
    'I': 0.3,
    'j': 0.28,
    'f': 0.32,
    't': 0.32,
    'r': 0.35,
    '!': 0.3,
    '.': 0.25,
    ',': 0.25,
    ':': 0.28,
    ';': 0.28,
    '\'': 0.2,
    '"': 0.35,
    '`': 0.28,
    '|': 0.25,
  }
}

///|
/// Common wide Latin characters (width ~0.65-0.95 em).
/// Mirrors `WIDE_CHARS` in `common.ts:32`.
fn wide_chars() -> Map[Char, Double] {
  {
    'w': 0.78,
    'W': 0.95,
    'm': 0.78,
    'M': 0.85,
    'O': 0.75,
    'Q': 0.78,
    'D': 0.72,
    'G': 0.75,
    'H': 0.72,
    'N': 0.72,
    'U': 0.72,
    '@': 0.9,
    '%': 0.8,
    '&': 0.72,
  }
}

///|
/// Common medium Latin characters (width ~0.45-0.6 em).
/// Mirrors `MEDIUM_CHARS` in `common.ts:52`.
fn medium_chars() -> Map[Char, Double] {
  {
    'a': 0.52,
    'b': 0.55,
    'c': 0.5,
    'd': 0.55,
    'e': 0.52,
    'g': 0.55,
    'h': 0.55,
    'k': 0.52,
    'n': 0.55,
    'o': 0.55,
    'p': 0.55,
    'q': 0.55,
    's': 0.48,
    'u': 0.55,
    'v': 0.52,
    'x': 0.52,
    'y': 0.52,
    'z': 0.48,
    'A': 0.65,
    'B': 0.65,
    'C': 0.68,
    'E': 0.62,
    'F': 0.58,
    'J': 0.52,
    'K': 0.65,
    'L': 0.55,
    'P': 0.6,
    'R': 0.65,
    'S': 0.6,
    'T': 0.58,
    'V': 0.65,
    'X': 0.65,
    'Y': 0.62,
    'Z': 0.6,
  }
}

///|
/// Number character widths.  Mirrors `NUMBER_CHARS` in `common.ts:92`.
fn number_chars() -> Map[Char, Double] {
  {
    '0': 0.55,
    '1': 0.35,
    '2': 0.55,
    '3': 0.55,
    '4': 0.55,
    '5': 0.55,
    '6': 0.55,
    '7': 0.5,
    '8': 0.55,
    '9': 0.55,
  }
}

///|
/// Default character widths combining all common categories plus a
/// handful of punctuation/operators.  Mirrors `DEFAULT_CHAR_WIDTHS`
/// in `common.ts:108`.
pub fn default_char_widths() -> Map[Char, Double] {
  let m : Map[Char, Double] = Map::new()
  for k, v in narrow_chars() {
    m[k] = v
  }
  for k, v in medium_chars() {
    m[k] = v
  }
  for k, v in wide_chars() {
    m[k] = v
  }
  for k, v in number_chars() {
    m[k] = v
  }
  m[' '] = 0.25
  m['-'] = 0.35
  m['_'] = 0.5
  m['='] = 0.55
  m['+'] = 0.55
  m['*'] = 0.4
  m['/'] = 0.35
  m['\\'] = 0.35
  m['('] = 0.35
  m[')'] = 0.35
  m['['] = 0.32
  m[']'] = 0.32
  m['{'] = 0.38
  m['}'] = 0.38
  m['<'] = 0.55
  m['>'] = 0.55
  m['?'] = 0.5
  m['#'] = 0.55
  m['$'] = 0.55
  m['^'] = 0.45
  m['~'] = 0.55
  m
}

///|
/// Common kerning pairs for Latin text.  Mirrors
/// `COMMON_KERNING_PAIRS` in `common.ts:139`.
pub fn common_kerning_pairs() -> Map[String, Double] {
  {
    "AV": -0.08,
    "AW": -0.06,
    "AT": -0.08,
    "AY": -0.08,
    "Av": -0.06,
    "Aw": -0.04,
    "Ay": -0.06,
    "FA": -0.06,
    "LT": -0.08,
    "LV": -0.08,
    "LW": -0.06,
    "LY": -0.08,
    "PA": -0.06,
    "TA": -0.08,
    "Ta": -0.06,
    "Te": -0.04,
    "To": -0.06,
    "Tr": -0.04,
    "Ty": -0.06,
    "VA": -0.08,
    "Va": -0.06,
    "Ve": -0.04,
    "Vo": -0.06,
    "Vy": -0.04,
    "WA": -0.06,
    "Wa": -0.04,
    "We": -0.02,
    "Wo": -0.04,
    "YA": -0.08,
    "Ya": -0.06,
    "Ye": -0.04,
    "Yo": -0.06,
    "ff": -0.02,
    "fi": -0.02,
    "fl": -0.02,
    "ry": -0.02,
  }
}

///|
/// Sans-serif specific kerning adjustments.  Mirrors
/// `SANS_SERIF_KERNING` in `common.ts:181` — base table with tighter
/// values for a handful of pairs.
pub fn sans_serif_kerning() -> Map[String, Double] {
  let m = common_kerning_pairs()
  m["AV"] = -0.1
  m["AT"] = -0.1
  m["AY"] = -0.1
  m["LT"] = -0.1
  m["TA"] = -0.1
  m["VA"] = -0.1
  m
}

///|
/// Serif specific kerning adjustments.  Mirrors `SERIF_KERNING` in
/// `common.ts:195`.
pub fn serif_kerning() -> Map[String, Double] {
  let m = common_kerning_pairs()
  m["AC"] = -0.02
  m["AG"] = -0.02
  m["AO"] = -0.02
  m["AQ"] = -0.02
  m["AU"] = -0.02
  m
}
