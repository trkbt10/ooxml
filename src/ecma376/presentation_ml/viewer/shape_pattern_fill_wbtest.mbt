// §20.1.8.47 `<a:pattFill>` shape fill — the preset hatch families
// that previously degraded to a flat foreground fill (dashed rules,
// bricks, diamonds, confetti) now produce real tile geometry.

///|
fn marks_svg(prst : String) -> String {
  match pattern_tile_marks(prst, "#112233") {
    Some(marks) => {
      let sb = StringBuilder::new()
      for m in marks {
        match m {
          @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
          _ => ()
        }
      }
      sb.to_string()
    }
    None => ""
  }
}

///|
test "dashed pattern presets emit dashed lines" {
  for p in ["dashHorz", "dashVert", "dashDnDiag", "dashUpDiag"] {
    let svg = marks_svg(p)
    assert_true(svg.contains("<line "))
    assert_true(svg.contains("stroke-dasharray=\"3 3\""))
  }
}

///|
test "diamond pattern presets emit polygons / dots" {
  assert_true(marks_svg("solidDmnd").contains("<polygon "))
  assert_true(marks_svg("solidDmnd").contains("fill=\"#112233\""))
  let open = marks_svg("openDmnd")
  assert_true(open.contains("fill=\"none\""))
  assert_true(open.contains("stroke=\"#112233\""))
  assert_true(marks_svg("dotDmnd").contains("<circle "))
}

///|
test "brick and confetti presets are no longer flat fills" {
  assert_true(marks_svg("horzBrick").contains("<line "))
  assert_true(marks_svg("diagBrick").contains("<line "))
  assert_true(marks_svg("smConfetti").contains("<circle "))
  assert_true(marks_svg("lgConfetti").contains("<circle "))
}

///|
test "texture presets render geometry instead of degrading to flat fill" {
  // zig-zag / wave / shingle are stroked open shapes.
  for p in ["zigZag", "wave", "shingle", "divot"] {
    let svg = marks_svg(p)
    assert_true(svg.contains("<polyline ") || svg.contains("<path "))
    assert_true(svg.contains("stroke=\"#112233\""))
  }
  // trellis / weave are line lattices.
  for p in ["trellis", "weave"] {
    assert_true(marks_svg(p).contains("<line "))
  }
  // plaid layers translucent bands; sphere is a filled disc.
  assert_true(marks_svg("plaid").contains("fill-opacity=\"0.5\""))
  assert_true(marks_svg("sphere").contains("<circle "))
}

///|
test "an unknown preset name still falls back to flat fill" {
  // A value outside ST_PresetPatternVal returns None so the caller
  // paints a flat foreground.
  match pattern_tile_marks("notARealPreset", "#000000") {
    None => ()
    Some(_) => fail("unexpected geometry for an unknown preset")
  }
}
