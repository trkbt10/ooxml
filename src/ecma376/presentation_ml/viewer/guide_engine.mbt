// @source web-pptx packages/@aurochs-office/drawing-ml/src/domain/geometry/guide-engine.ts
//
// DrawingML shape-guide formula engine.  Evaluates the 17 ECMA-376
// formula types (`*/`, `+-`, `+/`, `?:`, `abs`, `at2`, `cat2`, `cos`,
// `max`, `min`, `mod`, `pin`, `sat2`, `sin`, `sqrt`, `tan`, `val`)
// over a mutable `GuideContext` of name → number bindings.
//
// All preset-geometry generators in `preset_shapes_*.mbt` share this
// engine.  Angle arguments use ECMA-376 60000ths-of-a-degree units
// per §20.1.10.3 (ST_Angle).
//
// ECMA-376 references:
//   §20.1.9.11   Shape Guide (a:gd)
//   §20.1.10.3   ST_Angle
//   §20.1.10.56  ST_ShapeType built-in guides

///|
/// Mutable bag of name → value bindings used during guide
/// evaluation.  Mirrors `GuideContext` in `guide-engine.ts:59`.
pub type GuideContext = Map[String, Double]

///|
/// Convert ECMA-376 60000ths-of-a-degree to radians.
let angle_to_radians : Double = 3.141592653589793 / (180.0 * 60000.0)

///|
/// Convert radians back to ECMA-376 angle units.
let radians_to_angle : Double = 180.0 * 60000.0 / 3.141592653589793

///|
/// Full circle in ECMA-376 angle units (360 × 60000).
let full_circle_units : Double = 21600000.0

///|
/// Tokenise a formula string by ASCII whitespace.  Mirrors
/// `formula.trim().split(/\s+/)` in `guide-engine.ts:127`.
fn split_whitespace(formula : String) -> Array[String] {
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
/// Resolve a formula argument to a `Double`.  Arguments are either
/// numeric literals (`"100000"`) or names already present in the
/// context (`"w"`, `"adj1"`, etc.).  Unknown names abort guide
/// evaluation by returning `None` — matching the TS code's `throw`
/// path with a softer failure mode appropriate for a renderer.
fn resolve_arg(arg : String, context : GuideContext) -> Double? {
  try @string.parse_double(arg) catch {
    _ => context.get(arg)
  } noraise {
    d => Some(d)
  }
}

///|
/// `args[i] ?? fallback` helper.  Falls back when the argument is
/// missing or unresolvable (mirroring the TS destructuring defaults).
fn arg_or(args : Array[Double?], i : Int, fallback : Double) -> Double {
  if i >= args.length() {
    return fallback
  }
  args[i].unwrap_or(fallback)
}

///|
/// Math.atan2 fallback. MoonBit core has `@math.atan2`.
fn atan2(y : Double, x : Double) -> Double {
  @math.atan2(y, x)
}

///|
/// Evaluate a single formula token list against `context`.  Returns
/// `None` only when the operation is unrecognised — every supported
/// op returns `Some(value)`.  Mirrors `evaluateFormula` in
/// `guide-engine.ts:183`.
fn eval_formula(
  operation : String,
  raw_args : Array[String],
  context : GuideContext,
) -> Double? {
  let args : Array[Double?] = []
  for a in raw_args {
    args.push(resolve_arg(a, context))
  }
  match operation {
    // Multiply Divide: "*/ x y z" = (x * y) / z
    "*/" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 1.0)
      let z = arg_or(args, 2, 1.0)
      Some(if z != 0.0 { x * y / z } else { 0.0 })
    }
    // Add Subtract: "+- x y z" = (x + y) - z
    "+-" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      let z = arg_or(args, 2, 0.0)
      Some(x + y - z)
    }
    // Add Divide: "+/ x y z" = (x + y) / z
    "+/" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      let z = arg_or(args, 2, 1.0)
      Some(if z != 0.0 { (x + y) / z } else { 0.0 })
    }
    // If Else: "?: x y z" = x > 0 ? y : z
    "?:" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      let z = arg_or(args, 2, 0.0)
      Some(if x > 0.0 { y } else { z })
    }
    // Absolute Value: "abs x" = |x|
    "abs" => {
      let x = arg_or(args, 0, 0.0)
      Some(if x < 0.0 { -x } else { x })
    }
    // ArcTan2: "at2 x y" = atan2(y, x) in ECMA angle units
    "at2" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      Some(atan2(y, x) * radians_to_angle)
    }
    // Cosine ArcTan: "cat2 x y z" = x * cos(atan2(z, y))
    "cat2" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 1.0)
      let z = arg_or(args, 2, 0.0)
      Some(x * @math.cos(atan2(z, y)))
    }
    // Cosine: "cos x y" = x * cos(y in ECMA angle units)
    "cos" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      Some(x * @math.cos(y * angle_to_radians))
    }
    "max" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      Some(if x > y { x } else { y })
    }
    "min" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      Some(if x < y { x } else { y })
    }
    // Modulus (Euclidean Norm, NOT remainder): "mod x y z" = sqrt(x²+y²+z²)
    "mod" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      let z = arg_or(args, 2, 0.0)
      Some((x * x + y * y + z * z).sqrt())
    }
    // Pin To Range: "pin x y z" = clamp(y, x, z)
    "pin" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      let z = arg_or(args, 2, 0.0)
      Some(if y < x { x } else if y > z { z } else { y })
    }
    // Sine ArcTan: "sat2 x y z" = x * sin(atan2(z, y))
    "sat2" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 1.0)
      let z = arg_or(args, 2, 0.0)
      Some(x * @math.sin(atan2(z, y)))
    }
    "sin" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      Some(x * @math.sin(y * angle_to_radians))
    }
    "sqrt" => {
      let x = arg_or(args, 0, 0.0)
      Some(if x >= 0.0 { x.sqrt() } else { 0.0 })
    }
    "tan" => {
      let x = arg_or(args, 0, 0.0)
      let y = arg_or(args, 1, 0.0)
      let t = @math.sin(y * angle_to_radians) / @math.cos(y * angle_to_radians)
      // Guard against near-90° infinities.
      Some(
        if t.is_nan() || t.is_pos_inf() || t.is_neg_inf() {
          0.0
        } else {
          x * t
        },
      )
    }
    "val" => Some(arg_or(args, 0, 0.0))
    // §20.1.9.6 ST_GuideFormula — the spec enumerates exactly
    // 17 function names (*/, +-, +/, ?:, abs, at2, cat2, cos,
    // max, min, mod, pin, sat2, sin, sqrt, tan, val).  Any
    // other token is a schema violation; we return None so the
    // caller can decide whether to surface the violation or
    // leave the guide unresolved.
    _ => None
  }
}

///|
/// One guide entry — `name` is what the result is bound to, `formula`
/// is the raw `<a:gd fmla="..."/>` body.  Mirrors `GeometryGuide` in
/// `shape.ts`.
pub struct GuideEntry {
  name : String
  formula : String
}

///|
/// An (name, value) adjustment from `<a:avLst>` (the customisable
/// inputs to a preset).  Mirrors `AdjustValue` in `shape.ts`.
pub struct AdjustValue {
  name : String
  value : Double
}

///|
/// Initialise the guide context with every ECMA-376 built-in plus the
/// shape's adjust values.  Mirrors `createGuideContext` in
/// `guide-engine.ts:332`.
pub fn create_guide_context(
  width : Double,
  height : Double,
  adjust_values? : Array[AdjustValue] = [],
) -> GuideContext {
  let ctx : GuideContext = Map([], capacity=0)
  // Dimensions
  ctx["w"] = width
  ctx["h"] = height
  // Shortest / longest side
  let ss = if width < height { width } else { height }
  let ls = if width > height { width } else { height }
  ctx["ss"] = ss
  ctx["ls"] = ls
  // Centres
  ctx["hc"] = width / 2.0
  ctx["vc"] = height / 2.0
  // Height fractions
  ctx["hd2"] = height / 2.0
  ctx["hd3"] = height / 3.0
  ctx["hd4"] = height / 4.0
  ctx["hd5"] = height / 5.0
  ctx["hd6"] = height / 6.0
  ctx["hd8"] = height / 8.0
  ctx["hd10"] = height / 10.0
  // Width fractions
  ctx["wd2"] = width / 2.0
  ctx["wd3"] = width / 3.0
  ctx["wd4"] = width / 4.0
  ctx["wd5"] = width / 5.0
  ctx["wd6"] = width / 6.0
  ctx["wd8"] = width / 8.0
  ctx["wd10"] = width / 10.0
  ctx["wd12"] = width / 12.0
  ctx["wd32"] = width / 32.0
  // ss fractions
  ctx["ssd2"] = ss / 2.0
  ctx["ssd4"] = ss / 4.0
  ctx["ssd6"] = ss / 6.0
  ctx["ssd8"] = ss / 8.0
  ctx["ssd16"] = ss / 16.0
  ctx["ssd32"] = ss / 32.0
  // Circle angle constants (ECMA angle units)
  ctx["cd2"] = 10800000.0
  ctx["cd4"] = 5400000.0
  ctx["cd8"] = 2700000.0
  ctx["3cd4"] = 16200000.0
  ctx["3cd8"] = 8100000.0
  ctx["5cd8"] = 13500000.0
  ctx["7cd8"] = 18900000.0
  // Bounding box
  ctx["l"] = 0.0
  ctx["t"] = 0.0
  ctx["r"] = width
  ctx["b"] = height
  // Adjust values come last so the caller can override built-ins.
  for av in adjust_values {
    ctx[av.name] = av.value
  }
  ctx
}

///|
/// Evaluate `guides` in order, binding each result back into
/// `context`.  Order matters because later guides may reference
/// earlier ones.  Mirrors `evaluateGuides` in `guide-engine.ts:420`.
pub fn evaluate_guides(
  guides : Array[GuideEntry],
  context : GuideContext,
) -> Unit {
  for g in guides {
    let tokens = split_whitespace(g.formula)
    if tokens.length() == 0 {
      continue
    }
    let op = tokens[0]
    let args : Array[String] = []
    for i in 1..<tokens.length() {
      args.push(tokens[i])
    }
    match eval_formula(op, args, context) {
      Some(v) => context[g.name] = v
      None => ()
    }
  }
}

///|
/// Evaluate one expression that may be either a bare value/name or a
/// full formula.  Mirrors `evaluateExpression` in
/// `guide-engine.ts:441`.
pub fn evaluate_expression(expr : String, context : GuideContext) -> Double {
  let trimmed = expr.trim(chars=" \t\r\n").to_owned()
  if trimmed.find(" ") is None {
    return resolve_arg(trimmed, context).unwrap_or(0.0)
  }
  let tokens = split_whitespace(trimmed)
  if tokens.length() == 0 {
    return 0.0
  }
  let op = tokens[0]
  let args : Array[String] = []
  for i in 1..<tokens.length() {
    args.push(tokens[i])
  }
  eval_formula(op, args, context).unwrap_or(0.0)
}

///|
/// Convert ECMA-376 angle units to degrees.  Mirrors
/// `angleUnitsToDegrees` in `guide-engine.ts:470`.
pub fn angle_units_to_degrees(units : Double) -> Double {
  units / 60000.0
}

///|
/// Convert degrees to ECMA-376 angle units.  Mirrors
/// `degreesToAngleUnits` in `guide-engine.ts:482`.
pub fn degrees_to_angle_units(degrees : Double) -> Double {
  degrees * 60000.0
}

///|
/// Normalise an ECMA angle to [0, 360°).  Mirrors `normalizeAngle`
/// in `guide-engine.ts:492`.
pub fn normalize_angle(units : Double) -> Double {
  let m = units -
    (units / full_circle_units).to_int().to_double() * full_circle_units
  if m < 0.0 {
    m + full_circle_units
  } else {
    m
  }
}
