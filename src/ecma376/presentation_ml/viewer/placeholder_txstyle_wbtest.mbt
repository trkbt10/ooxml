// §19.3.1.52 — placeholder text inherits its run / paragraph defaults
// from the master's `<p:txStyles>` (title / body / other style) when
// the shape itself does not specify them.

///|
fn pts_el(
  prefix : String?,
  tag : String,
  attrs : Array[(String, String)],
  children : Array[@xml.Node],
) -> @xml.Element {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: { prefix: None, local_name: k, ns: None }, value: v })
  }
  { name: { prefix, local_name: tag, ns: None }, attributes: a, children }
}

///|
/// `<p:txStyles>` with each style mapping lvl1 `<a:defRPr><a:latin>` to
/// a distinctive typeface, so we can tell which style was applied.
fn make_tx_styles() -> @xml.Element {
  fn style(name : String, face : String) -> @xml.Node {
    @xml.Node::Element(
      pts_el(Some("p"), name, [], [
        @xml.Node::Element(
          pts_el(Some("a"), "lvl1pPr", [], [
            @xml.Node::Element(
              pts_el(Some("a"), "defRPr", [], [
                @xml.Node::Element(
                  pts_el(Some("a"), "latin", [("typeface", face)], []),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    )
  }

  pts_el(Some("p"), "txStyles", [], [
    style("titleStyle", "MasterTitleFace"),
    style("bodyStyle", "MasterBodyFace"),
    style("otherStyle", "MasterOtherFace"),
  ])
}

///|
/// A `<p:sp>` carrying a placeholder of the given type (or none) and a
/// single text run with no explicit font.
fn make_ph_shape(ph_type : String?) -> @xml.Element {
  let ph_attrs = match ph_type {
    Some(t) => [("type", t)]
    None => []
  }
  let nv_sp_pr = pts_el(Some("p"), "nvSpPr", [], [
    @xml.Node::Element(
      pts_el(Some("p"), "cNvPr", [("id", "2"), ("name", "ph")], []),
    ),
    @xml.Node::Element(pts_el(Some("p"), "cNvSpPr", [], [])),
    @xml.Node::Element(
      pts_el(Some("p"), "nvPr", [], [
        @xml.Node::Element(pts_el(Some("p"), "ph", ph_attrs, [])),
      ]),
    ),
  ])
  let tx_body = pts_el(Some("p"), "txBody", [], [
    @xml.Node::Element(pts_el(Some("a"), "bodyPr", [], [])),
    @xml.Node::Element(
      pts_el(Some("a"), "p", [], [
        @xml.Node::Element(
          pts_el(Some("a"), "r", [], [
            @xml.Node::Element(
              pts_el(Some("a"), "t", [], [@xml.Node::Text("Hi")]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  pts_el(Some("p"), "sp", [], [
    @xml.Node::Element(nv_sp_pr),
    @xml.Node::Element(tx_body),
  ])
}

///|
test "select_master_lst_style picks the style for the placeholder type" {
  let txs = make_tx_styles()
  // Returns the lvl1 `<a:latin>` typeface of the selected style, or
  // "" when no style was selected — kept a plain String so the
  // assertions avoid Option's deprecated Show requirement.
  fn face_of(ph : String?) -> String {
    match select_master_lst_style(Some(txs), make_ph_shape(ph)) {
      None => ""
      Some(style) =>
        // style → lvl1pPr → defRPr → latin @typeface
        match resolve_lst_style_p_pr(Some(style), 0) {
          Some(lvl) =>
            match first_child_named(lvl, "defRPr") {
              Some(d) =>
                match first_child_named(d, "latin") {
                  Some(l) => attr_value(l, "typeface").unwrap_or("")
                  None => ""
                }
              None => ""
            }
          None => ""
        }
    }
  }

  assert_eq(face_of(Some("title")), "MasterTitleFace")
  assert_eq(face_of(Some("ctrTitle")), "MasterTitleFace")
  assert_eq(face_of(Some("body")), "MasterBodyFace")
  assert_eq(face_of(Some("subTitle")), "MasterBodyFace")
  // implicit (no @type) → body slot
  assert_eq(face_of(None), "MasterBodyFace")
  assert_eq(face_of(Some("ftr")), "MasterOtherFace")
  assert_eq(face_of(Some("sldNum")), "MasterOtherFace")
}

///|
test "non-placeholder shape gets no master text style" {
  // A shape with no `<p:ph>` is not a placeholder; the function does
  // not look one up via find_shape_ph.
  let txs = make_tx_styles()
  let sp = pts_el(Some("p"), "sp", [], [
    @xml.Node::Element(
      pts_el(Some("p"), "nvSpPr", [], [
        @xml.Node::Element(pts_el(Some("p"), "nvPr", [], [])),
      ]),
    ),
  ])
  match select_master_lst_style(Some(txs), sp) {
    None => ()
    Some(_) => fail("non-placeholder shape should not select a master style")
  }
}

///|
test "placeholder run inherits the master body typeface" {
  let txs = make_tx_styles()
  let shape = make_ph_shape(Some("body"))
  let tx_body = first_child_named(shape, "txBody").unwrap()
  let ctx = ColorResolveContext::empty()
  let master_lst = select_master_lst_style(Some(txs), shape)
  let input = build_layout_input(
    tx_body,
    5000000.0,
    2000000.0,
    ctx,
    master_lst_style=master_lst,
  )
  let span = input.paragraphs[0].spans[0]
  inspect(span.font_family, content="MasterBodyFace")
}

///|
test "partial shape lstStyle still inherits missing attrs from master" {
  // The shape's own lstStyle sets bold at lvl1 but NO typeface; the
  // master bodyStyle supplies the typeface.  A per-attribute cascade
  // must yield BOTH: bold from the shape, face from the master.
  let shape_lst_style = pts_el(Some("a"), "lstStyle", [], [
    @xml.Node::Element(
      pts_el(Some("a"), "lvl1pPr", [], [
        @xml.Node::Element(pts_el(Some("a"), "defRPr", [("b", "1")], [])),
      ]),
    ),
  ])
  let tx_body = pts_el(Some("p"), "txBody", [], [
    @xml.Node::Element(pts_el(Some("a"), "bodyPr", [], [])),
    @xml.Node::Element(shape_lst_style),
    @xml.Node::Element(
      pts_el(Some("a"), "p", [], [
        @xml.Node::Element(
          pts_el(Some("a"), "r", [], [
            @xml.Node::Element(
              pts_el(Some("a"), "t", [], [@xml.Node::Text("Hi")]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  let ctx = ColorResolveContext::empty()
  // body placeholder → master bodyStyle.
  let master_lst = first_child_named(make_tx_styles(), "bodyStyle")
  let input = build_layout_input(
    tx_body,
    5000000.0,
    2000000.0,
    ctx,
    master_lst_style=master_lst,
  )
  let span = input.paragraphs[0].spans[0]
  // typeface inherited from the master (shape lstStyle had none)…
  inspect(span.font_family, content="MasterBodyFace")
  // …while bold came from the shape's own partial lstStyle.
  assert_eq(span.font_weight, 700)
}

///|
test "without the master chain the run falls back, not to the master" {
  // Same shape, but no master list style threaded in → the run uses
  // the renderer's theme-minor / default fallback, NOT MasterBodyFace.
  let shape = make_ph_shape(Some("body"))
  let tx_body = first_child_named(shape, "txBody").unwrap()
  let ctx = ColorResolveContext::empty()
  let input = build_layout_input(tx_body, 5000000.0, 2000000.0, ctx)
  let span = input.paragraphs[0].spans[0]
  assert_true(span.font_family != "MasterBodyFace")
}
