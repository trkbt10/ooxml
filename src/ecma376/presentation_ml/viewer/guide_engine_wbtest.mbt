// White-box tests for the DrawingML guide formula engine.

///|
test "create_guide_context fills built-ins" {
  let ctx = create_guide_context(100.0, 50.0)
  inspect(ctx.get("w"), content="Some(100)")
  inspect(ctx.get("h"), content="Some(50)")
  inspect(ctx.get("ss"), content="Some(50)") // min(w, h)
  inspect(ctx.get("ls"), content="Some(100)") // max(w, h)
  inspect(ctx.get("hc"), content="Some(50)") // w/2
  inspect(ctx.get("vc"), content="Some(25)") // h/2
  inspect(ctx.get("r"), content="Some(100)") // right edge
  inspect(ctx.get("b"), content="Some(50)") // bottom edge
}

///|
test "create_guide_context applies adjust values" {
  let avs = [({ name: "adj1", value: 25000.0 } : AdjustValue)]
  let ctx = create_guide_context(100.0, 50.0, adjust_values=avs)
  inspect(ctx.get("adj1"), content="Some(25000)")
}

///|
test "evaluate_guides applies *,/, +-, val" {
  let ctx = create_guide_context(200.0, 100.0)
  let guides : Array[GuideEntry] = [
    { name: "half_w", formula: "*/ w 1 2" }, // 200 * 1 / 2 = 100
    { name: "minus_one", formula: "+- half_w 0 1" }, // 100 + 0 - 1 = 99
    { name: "literal", formula: "val 42" },
  ]
  evaluate_guides(guides, ctx)
  inspect(ctx.get("half_w"), content="Some(100)")
  inspect(ctx.get("minus_one"), content="Some(99)")
  inspect(ctx.get("literal"), content="Some(42)")
}

///|
test "pin clamps value into [lo, hi]" {
  let ctx = create_guide_context(100.0, 100.0)
  let guides : Array[GuideEntry] = [
    { name: "low", formula: "pin 10 5 20" }, // 5 < 10 → 10
    { name: "mid", formula: "pin 10 15 20" }, // in range → 15
    { name: "high", formula: "pin 10 25 20" }, // 25 > 20 → 20
  ]
  evaluate_guides(guides, ctx)
  inspect(ctx.get("low"), content="Some(10)")
  inspect(ctx.get("mid"), content="Some(15)")
  inspect(ctx.get("high"), content="Some(20)")
}

///|
test "if/else picks the second arg when x > 0" {
  let ctx = create_guide_context(100.0, 100.0)
  let guides : Array[GuideEntry] = [
    { name: "pos", formula: "?: 1 10 20" }, // 1 > 0 → 10
    { name: "neg", formula: "?: -1 10 20" }, // -1 not > 0 → 20
    { name: "zero", formula: "?: 0 10 20" }, // 0 not > 0 → 20
  ]
  evaluate_guides(guides, ctx)
  inspect(ctx.get("pos"), content="Some(10)")
  inspect(ctx.get("neg"), content="Some(20)")
  inspect(ctx.get("zero"), content="Some(20)")
}

///|
test "mod is Euclidean norm" {
  let ctx = create_guide_context(100.0, 100.0)
  let guides : Array[GuideEntry] = [
    { name: "len", formula: "mod 3 4 0" }, // sqrt(9 + 16) = 5
  ]
  evaluate_guides(guides, ctx)
  inspect(ctx.get("len"), content="Some(5)")
}

///|
test "evaluate_expression handles bare literal and formula" {
  let ctx = create_guide_context(100.0, 50.0)
  inspect(evaluate_expression("w", ctx), content="100")
  inspect(evaluate_expression("42", ctx), content="42")
  inspect(evaluate_expression("*/ w 1 2", ctx), content="50")
}

///|
test "angle conversion round trips through degrees" {
  inspect(angle_units_to_degrees(5400000.0), content="90") // cd4
  inspect(degrees_to_angle_units(90.0), content="5400000")
}

///|
test "normalize_angle wraps into [0, 360°)" {
  // 360° + 90° in ECMA units → 90° in ECMA units
  let n = normalize_angle(21600000.0 + 5400000.0)
  inspect(n, content="5400000")
  // Negative wraps to positive
  let m = normalize_angle(-5400000.0)
  inspect(m, content="16200000") // 270° in ECMA units
}
