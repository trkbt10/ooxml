// ECMA-376 Part 1 §20.1.9 — generic DrawingML shape-guide formula
// engine for preset geometry.
//
// This is a Double-precision evaluator for the 17 ECMA-376 guide
// formula types (`*/`, `+-`, `+/`, `?:`, `abs`, `at2`, `cat2`, `cos`,
// `max`, `min`, `mod`, `pin`, `sat2`, `sin`, `sqrt`, `tan`, `val`),
// used to materialise the few preset shapes whose guide chains are too
// large (and whose intermediate products overflow 32-bit integer
// math at render scale) to transcribe by hand — `circularArrow`,
// `leftCircularArrow`, `leftRightCircularArrow`, `gear6`.
//
// The evaluation logic mirrors the proven engine in
// `presentation_ml/viewer/guide_engine.mbt` (drawing_ml is a lower
// package and cannot depend on it). The path is materialised into the
// integer `ShapeGeometry` command list (the relative `arcTo` →
// endpoint conversion matches the verified `rel_arc` helper).

///|
/// ECMA-376 60000ths-of-a-degree → radians.
let ge_angle_to_radians : Double = 3.141592653589793 / (180.0 * 60000.0)

///|
/// radians → ECMA-376 angle units.
let ge_radians_to_angle : Double = 180.0 * 60000.0 / 3.141592653589793

///|
/// Tokenise a formula by ASCII whitespace.
fn ge_tokens(formula : String) -> Array[String] {
  let tokens : Array[String] = []
  let buf = StringBuilder::new()
  let mut has_chars = false
  for c in formula {
    if c == ' ' || c == '\t' || c == '\r' || c == '\n' {
      if has_chars {
        tokens.push(buf.to_string())
        buf.reset()
        has_chars = false
      }
    } else {
      buf.write_char(c)
      has_chars = true
    }
  }
  if has_chars {
    tokens.push(buf.to_string())
  }
  tokens
}

///|
/// Parse a token as a signed integer literal (the only literal form in
/// the spec `gdLst`). Returns `None` for names like `"w"`, `"3cd4"`,
/// `"adj1"`, which are looked up in the guide context instead.
fn ge_parse_literal(s : String) -> Double? {
  if s.length() == 0 {
    return None
  }
  let mut i = 0
  let mut sign = 1.0
  if s[0] == '-' {
    sign = -1.0
    i = 1
  } else if s[0] == '+' {
    i = 1
  }
  if i >= s.length() {
    return None
  }
  let mut acc = 0.0
  while i < s.length() {
    let c = s[i]
    if c >= '0' && c <= '9' {
      acc = acc * 10.0 + (c.to_int() - '0'.to_int()).to_double()
    } else {
      return None // contains a non-digit ⇒ it is a name
    }
    i = i + 1
  }
  Some(sign * acc)
}

///|
/// Resolve a formula argument: numeric literal or a name bound in the
/// context. Unknown names resolve to 0.0 (a softer failure than abort,
/// appropriate for a renderer; valid spec data never hits this).
fn ge_resolve(arg : String, ctx : Map[String, Double]) -> Double {
  match ge_parse_literal(arg) {
    Some(v) => v
    None =>
      match ctx.get(arg) {
        Some(v) => v
        None => 0.0
      }
  }
}

///|
/// Evaluate one `op arg…` formula against `ctx`.
fn ge_eval_formula(
  op : String,
  raw_args : Array[String],
  ctx : Map[String, Double],
) -> Double {
  let a = if raw_args.length() > 0 { ge_resolve(raw_args[0], ctx) } else { 0.0 }
  let b = if raw_args.length() > 1 { ge_resolve(raw_args[1], ctx) } else { 0.0 }
  let c = if raw_args.length() > 2 { ge_resolve(raw_args[2], ctx) } else { 0.0 }
  match op {
    "*/" => if c != 0.0 { a * b / c } else { 0.0 }
    "+-" => a + b - c
    "+/" => if c != 0.0 { (a + b) / c } else { 0.0 }
    "?:" => if a > 0.0 { b } else { c }
    "abs" => if a < 0.0 { -a } else { a }
    "at2" => @math.atan2(b, a) * ge_radians_to_angle
    "cat2" => a * @math.cos(@math.atan2(c, b))
    "cos" => a * @math.cos(b * ge_angle_to_radians)
    "max" => if a > b { a } else { b }
    "min" => if a < b { a } else { b }
    "mod" => (a * a + b * b + c * c).sqrt()
    "pin" => if b < a { a } else if b > c { c } else { b }
    "sat2" => a * @math.sin(@math.atan2(c, b))
    "sin" => a * @math.sin(b * ge_angle_to_radians)
    "sqrt" => if a >= 0.0 { a.sqrt() } else { 0.0 }
    "tan" => {
      let t = @math.sin(b * ge_angle_to_radians) /
        @math.cos(b * ge_angle_to_radians)
      if t.is_nan() || t.is_pos_inf() || t.is_neg_inf() {
        0.0
      } else {
        a * t
      }
    }
    "val" => a
    _ => 0.0
  }
}

///|
/// Seed a guide context with every ECMA-376 built-in (§20.1.10.56) for
/// the given box, plus the preset's adjustment values (defaults first,
/// then any user `avLst` overrides).
fn ge_context(
  width : Double,
  height : Double,
  adj_defaults : Array[(String, Double)],
  adjustments : Array[Adjustment],
) -> Map[String, Double] {
  let ctx : Map[String, Double] = Map([], capacity=0)
  ctx["w"] = width
  ctx["h"] = height
  let ss = if width < height { width } else { height }
  let ls = if width > height { width } else { height }
  ctx["ss"] = ss
  ctx["ls"] = ls
  ctx["hc"] = width / 2.0
  ctx["vc"] = height / 2.0
  ctx["hd2"] = height / 2.0
  ctx["hd3"] = height / 3.0
  ctx["hd4"] = height / 4.0
  ctx["hd5"] = height / 5.0
  ctx["hd6"] = height / 6.0
  ctx["hd8"] = height / 8.0
  ctx["hd10"] = height / 10.0
  ctx["wd2"] = width / 2.0
  ctx["wd3"] = width / 3.0
  ctx["wd4"] = width / 4.0
  ctx["wd5"] = width / 5.0
  ctx["wd6"] = width / 6.0
  ctx["wd8"] = width / 8.0
  ctx["wd10"] = width / 10.0
  ctx["wd12"] = width / 12.0
  ctx["wd32"] = width / 32.0
  ctx["ssd2"] = ss / 2.0
  ctx["ssd4"] = ss / 4.0
  ctx["ssd6"] = ss / 6.0
  ctx["ssd8"] = ss / 8.0
  ctx["ssd16"] = ss / 16.0
  ctx["ssd32"] = ss / 32.0
  ctx["cd2"] = 10800000.0
  ctx["cd4"] = 5400000.0
  ctx["cd8"] = 2700000.0
  ctx["3cd4"] = 16200000.0
  ctx["3cd8"] = 8100000.0
  ctx["5cd8"] = 13500000.0
  ctx["7cd8"] = 18900000.0
  ctx["l"] = 0.0
  ctx["t"] = 0.0
  ctx["r"] = width
  ctx["b"] = height
  for d in adj_defaults {
    ctx[d.0] = d.1
  }
  for av in adjustments {
    match av.value {
      Some(v) => ctx[av.name] = v.to_double()
      None => ()
    }
  }
  ctx
}

///|
/// Evaluate `(name, fmla)` guides in order, binding each result back
/// into `ctx` (later guides reference earlier ones).
fn ge_evaluate(guides : Array[(String, String)], ctx : Map[String, Double]) -> Unit {
  for g in guides {
    let tokens = ge_tokens(g.1)
    if tokens.length() == 0 {
      continue
    }
    let op = tokens[0]
    let args : Array[String] = []
    for i in 1..<tokens.length() {
      args.push(tokens[i])
    }
    ctx[g.0] = ge_eval_formula(op, args, ctx)
  }
}

///|
/// One preset path command, operands as guide-name-or-literal strings.
/// (The guide-heavy presets routed through this engine use only
/// `moveTo`/`lnTo`/`arcTo`/`close`; quad/cubic Bézier ops would be
/// added here when a Bézier-bearing preset is routed.)
priv enum PresetPathCmd {
  PMoveTo(String, String)
  PLnTo(String, String)
  PArcTo(String, String, String, String) // wR, hR, stAng, swAng
  PClose
}

///|
/// Round a Double to the nearest Int (half away from zero).
fn ge_round(v : Double) -> Int {
  if v >= 0.0 {
    (v + 0.5).to_int()
  } else {
    (v - 0.5).to_int()
  }
}

///|
/// Build one SVG `ArcTo` for a DrawingML relative arc segment from the
/// current point `(cx, cy)`, returning the command plus the new
/// current point. The centre is `cur − (wR·cos stAng, hR·sin stAng)`;
/// the end is `cur + (wR·(cos(stAng+swAng) − cos stAng), …)`.
fn ge_arc_segment(
  cx : Double,
  cy : Double,
  w_r : Double,
  h_r : Double,
  st_ang : Double,
  sw_ang : Double,
) -> (PathCommand, Double, Double) {
  let st_rad = st_ang * ge_angle_to_radians
  let en_rad = (st_ang + sw_ang) * ge_angle_to_radians
  let ex = cx + w_r * (@math.cos(en_rad) - @math.cos(st_rad))
  let ey = cy + h_r * (@math.sin(en_rad) - @math.sin(st_rad))
  let large_arc = (if sw_ang < 0.0 { -sw_ang } else { sw_ang }) > 10800000.0
  let sweep = sw_ang > 0.0
  (ArcTo(ge_round(w_r), ge_round(h_r), 0, large_arc, sweep, ge_round(ex), ge_round(
    ey,
  )), ex, ey)
}

///|
/// Materialise a resolved preset path into integer `PathCommand`s. The
/// `arcTo` is the DrawingML relative form: the pen is on the implied
/// ellipse at `stAng`, the centre is `cur − (wR·cos stAng, hR·sin
/// stAng)`, and the end is `cur + (wR·(cos(stAng+swAng) − cos stAng),
/// hR·(sin(stAng+swAng) − sin stAng))` — matching the verified
/// `rel_arc` helper. `largeArc = |swAng| > 180°`, `sweep = swAng > 0`.
fn ge_materialize(
  path : Array[PresetPathCmd],
  ctx : Map[String, Double],
) -> Array[PathCommand] {
  let commands : Array[PathCommand] = []
  let mut cur_x = 0.0
  let mut cur_y = 0.0
  let rv = fn(s : String) -> Double { ge_resolve(s, ctx) }
  for cmd in path {
    match cmd {
      PMoveTo(x, y) => {
        let px = rv(x)
        let py = rv(y)
        commands.push(MoveTo(ge_round(px), ge_round(py)))
        cur_x = px
        cur_y = py
      }
      PLnTo(x, y) => {
        let px = rv(x)
        let py = rv(y)
        commands.push(LineTo(ge_round(px), ge_round(py)))
        cur_x = px
        cur_y = py
      }
      PArcTo(wr, hr, st, sw) => {
        let w_r = rv(wr)
        let h_r = rv(hr)
        let st_ang = rv(st)
        let sw_ang = rv(sw)
        // A full (or larger) revolution has coincident endpoints, which
        // SVG's `A` cannot draw, so split it into two half-sweeps.
        let abs_sw = if sw_ang < 0.0 { -sw_ang } else { sw_ang }
        if abs_sw >= 21600000.0 {
          let half = sw_ang / 2.0
          let (a1, mx, my) = ge_arc_segment(cur_x, cur_y, w_r, h_r, st_ang, half)
          commands.push(a1)
          let (a2, ex, ey) = ge_arc_segment(
            mx, my, w_r, h_r, st_ang + half, sw_ang - half,
          )
          commands.push(a2)
          cur_x = ex
          cur_y = ey
        } else {
          let (a, ex, ey) = ge_arc_segment(cur_x, cur_y, w_r, h_r, st_ang, sw_ang)
          commands.push(a)
          cur_x = ex
          cur_y = ey
        }
      }
      PClose => commands.push(ClosePath)
    }
  }
  commands
}

///|
/// A self-contained preset definition: adjustment defaults, the ordered
/// guide chain (`(name, fmla)`), and the path commands — copied
/// verbatim from `presetShapeDefinitions.xml`.
priv struct PresetGuideDef {
  adjusts : Array[(String, Double)]
  guides : Array[(String, String)]
  path : Array[PresetPathCmd]
}

///|
/// Materialise a data-driven preset definition into a `ShapeGeometry`
/// on the `width × height` box, applying any `avLst` adjustments. Used
/// by `build_geometry` / `build_geometry_with_adjustments` for the
/// guide-heavy shapes (circular arrows, gears) whose chains are
/// evaluated rather than hand-transcribed.
fn build_from_definition(
  def : PresetGuideDef,
  width : Int,
  height : Int,
  adjustments : Array[Adjustment],
) -> ShapeGeometry {
  if width <= 0 || height <= 0 {
    return rectangular_fallback(width, height)
  }
  let ctx = ge_context(
    width.to_double(),
    height.to_double(),
    def.adjusts,
    adjustments,
  )
  ge_evaluate(def.guides, ctx)
  let commands = ge_materialize(def.path, ctx)
  { commands, width, height }
}
