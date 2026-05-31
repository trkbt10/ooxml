// Part 4 §6.1 VML AG_Style — parser / serialiser tests.

///|
test "parse_vml_style recognises position / size properties" {
  let v = parse_vml_style(
    "position:absolute;left:10pt;top:20pt;width:100pt;height:50pt",
  )
  @debug.debug_inspect(
    v.position,
    content=(
      #|Some("absolute")
    ),
  )
  @debug.debug_inspect(
    v.left,
    content=(
      #|Some("10pt")
    ),
  )
  @debug.debug_inspect(
    v.top,
    content=(
      #|Some("20pt")
    ),
  )
  @debug.debug_inspect(
    v.width,
    content=(
      #|Some("100pt")
    ),
  )
  @debug.debug_inspect(
    v.height,
    content=(
      #|Some("50pt")
    ),
  )
}

///|
test "parse_vml_style handles whitespace around tokens" {
  let v = parse_vml_style(" position : absolute ; left : 10pt ")
  @debug.debug_inspect(
    v.position,
    content=(
      #|Some("absolute")
    ),
  )
  @debug.debug_inspect(
    v.left,
    content=(
      #|Some("10pt")
    ),
  )
}

///|
test "parse_vml_style preserves unrecognised properties in extras" {
  let v = parse_vml_style(
    "position:absolute;v-text-anchor:middle;custom-prop:42",
  )
  @debug.debug_inspect(
    v.position,
    content=(
      #|Some("absolute")
    ),
  )
  @debug.debug_inspect(v.extras.length(), content="2")
  let (k1, v1) = v.extras[0]
  let (k2, v2) = v.extras[1]
  @debug.debug_inspect(
    k1,
    content=(
      #|"v-text-anchor"
    ),
  )
  @debug.debug_inspect(
    v1,
    content=(
      #|"middle"
    ),
  )
  @debug.debug_inspect(
    k2,
    content=(
      #|"custom-prop"
    ),
  )
  @debug.debug_inspect(
    v2,
    content=(
      #|"42"
    ),
  )
}

///|
test "format_vml_style emits declaration order then extras" {
  let style = {
    ..VmlInlineStyle::empty(),
    position: Some("absolute"),
    left: Some("10pt"),
    width: Some("100pt"),
    extras: [("v-text-anchor", "middle")],
  }
  @debug.debug_inspect(
    format_vml_style(style),
    content=(
      #|"position:absolute;left:10pt;width:100pt;v-text-anchor:middle;"
    ),
  )
}

///|
test "round-trip preserves recognised + extras" {
  let original = "position:absolute;left:0;top:0;width:50pt;v-text-anchor:middle;custom-prop:42;"
  let parsed = parse_vml_style(original)
  let serialised = format_vml_style(parsed)
  // Re-parsing the serialised form must yield the same projection.
  let reparsed = parse_vml_style(serialised)
  @debug.debug_inspect(
    reparsed.position,
    content=(
      #|Some("absolute")
    ),
  )
  @debug.debug_inspect(
    reparsed.left,
    content=(
      #|Some("0")
    ),
  )
  @debug.debug_inspect(
    reparsed.top,
    content=(
      #|Some("0")
    ),
  )
  @debug.debug_inspect(
    reparsed.width,
    content=(
      #|Some("50pt")
    ),
  )
  @debug.debug_inspect(reparsed.extras.length(), content="2")
}

///|
test "parse_vml_style handles MSO position attributes" {
  let v = parse_vml_style(
    "mso-position-horizontal:center;mso-position-vertical-relative:line;mso-wrap-distance-left:0;",
  )
  @debug.debug_inspect(
    v.mso_position_horizontal,
    content=(
      #|Some("center")
    ),
  )
  @debug.debug_inspect(
    v.mso_position_vertical_relative,
    content=(
      #|Some("line")
    ),
  )
  @debug.debug_inspect(
    v.mso_wrap_distance_left,
    content=(
      #|Some("0")
    ),
  )
}
