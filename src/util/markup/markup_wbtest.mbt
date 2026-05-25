///|
/// A no-namespace element serialises to a bare fragment.
test "markup serialize emits a plain element fragment" {
  let root : @xml.Element = {
    name: qname("mrow"),
    attributes: [attr("class", "x")],
    children: [text("hi")],
  }
  let s = serialize(root)
  inspect(
    s,
    content=(
      #|<mrow class="x">hi</mrow>
    ),
  )
}

///|
/// An empty element serialises as a self-closing tag.
test "markup serialize emits self-closing empty element" {
  let root : @xml.Element = { name: qname("br"), attributes: [], children: [] }
  inspect(serialize(root), content="<br/>")
}

///|
/// Attribute values and text nodes are escaped: an OOXML payload
/// carrying `<`, `&`, `"` cannot break out of its context.
test "markup serialize escapes attributes and text" {
  let root : @xml.Element = {
    name: qname("text"),
    attributes: [attr("title", "a \"b\" <c> & d")],
    children: [text("x < y & \"z\"")],
  }
  let s = serialize(root)
  // The attribute value escapes all five predefined entities.
  assert_true(s.contains("title=\"a &quot;b&quot; &lt;c&gt; &amp; d\""))
  // Text content escapes `<` and `&`.
  assert_true(s.contains(">x &lt; y &amp; \"z\"<"))
  // No raw markup survives.
  assert_false(s.contains("<c>"))
}

///|
/// `strip_debug_attrs` removes every `data-*` attribute from a
/// serialised SVG while preserving every non-`data-*` attribute
/// and every text / element node.  The drop is byte-level: quoted
/// values that contain `>` and `=` are honoured, and non-`data-*`
/// attributes that merely share a `data` prefix in another token
/// position are NOT touched.
test "strip_debug_attrs removes data-* and preserves the rest" {
  let svg =
    #|<svg xmlns="http://www.w3.org/2000/svg" width="100" data-ooxml="wml" data-ooxml-pages="1"><rect x="0" data-ooxml-page="1" fill="red"/></svg>
  inspect(
    strip_debug_attrs(svg),
    content=(
      #|<svg xmlns="http://www.w3.org/2000/svg" width="100"><rect x="0" fill="red"/></svg>
    ),
  )
}

///|
/// Quoted attribute values that contain `>` survive the strip
/// unchanged.  The byte scanner must enter / leave the quote run
/// rather than terminate the tag at the embedded `>`.
test "strip_debug_attrs honours quoted > inside attribute values" {
  let svg = "<svg viewBox=\"0 0 > 10\" data-ooxml=\"x\"></svg>"
  inspect(
    strip_debug_attrs(svg),
    content=(
      #|<svg viewBox="0 0 > 10"></svg>
    ),
  )
}

///|
/// PCDATA whitespace and XML comments pass through unchanged —
/// `strip_debug_attrs` ONLY removes `data-*` attributes; it does
/// NOT collapse text or drop comments (the catalog verifier's
/// `svg_visible_skeleton` does that, but it's for diff equality,
/// not production output).
test "strip_debug_attrs preserves PCDATA and comments" {
  let svg = "<svg data-ooxml=\"x\"><!-- hi --><text>  a  b  </text></svg>"
  inspect(
    strip_debug_attrs(svg),
    content=(
      #|<svg><!-- hi --><text>  a  b  </text></svg>
    ),
  )
}

///|
/// A document with no `data-*` attributes round-trips byte-for-
/// byte through `strip_debug_attrs`.
test "strip_debug_attrs is identity when no data- attribute is present" {
  let svg =
    #|<svg xmlns="http://www.w3.org/2000/svg"><g transform="translate(1,2)"><circle r="3"/></g></svg>
  inspect(strip_debug_attrs(svg), content=svg)
}

///|
/// An SVG tree built in `svg_ns` emits exactly one `xmlns`
/// declaration — on the root — and none on the descendants.
test "markup serialize_svg declares the SVG namespace once" {
  let root : @xml.Element = {
    name: qname_ns("svg", svg_ns),
    attributes: [attr("width", "100")],
    children: [
      elem_ns("rect", svg_ns, [attr("x", "0")], []),
      elem_ns("g", svg_ns, [], [elem_ns("circle", svg_ns, [attr("r", "5")], [])]),
    ],
  }
  let s = serialize_svg(root)
  // The namespace is declared on <svg> exactly once; descendants
  // inherit it with no repeat and no `xmlns=""` reset.  Verified
  // by inspecting the whole fragment.
  inspect(
    s,
    content=(
      #|<svg xmlns="http://www.w3.org/2000/svg" width="100"><rect x="0"/><g><circle r="5"/></g></svg>
    ),
  )
}
