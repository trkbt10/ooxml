///|
/// Encode a UTF-8 string into bytes for the XML parser.
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
/// Parse a raw XML string and return its root element.
fn parse_root(source : String) -> @xml.Element {
  try! @xml.parse(bytes(source)).root
}

///|
/// Build a typed `DiagramDefinition` from a layoutDef XML literal.
fn definition(source : String) -> DiagramDefinition {
  let element = parse_root(source)
  let wrapper = try! @domain.CT_DiagramDefinition::new(element)
  try! decode_diagram_definition(wrapper)
}

///|
/// Build a typed `DataModel` from a dataModel XML literal.
fn data_model(source : String) -> DataModel {
  let element = parse_root(source)
  let wrapper = try! @domain.CT_DataModel::new(element)
  try! decode_data_model(wrapper)
}

///|
/// Canonical 1000 × 500 canvas used by every algorithm test so
/// the expected coordinates can be eyeballed against the spec.
fn canvas() -> BoundsRect {
  { x: 0.0, y: 0.0, width: 1000.0, height: 500.0 }
}

///|
/// Convenience: build a data model with one root + N typed
/// children. Used by the algorithm tests where the actual
/// data-model values are irrelevant; only the cardinality
/// matters.
fn flat_data_model(child_count : Int) -> DataModel {
  let mut parts = "<dataModel><ptLst>"
  parts = parts + "<pt modelId=\"0\" type=\"doc\"/>"
  for i in 1..<=child_count {
    parts = parts + "<pt modelId=\"" + i.to_string() + "\" type=\"node\"/>"
  }
  parts = parts + "</ptLst><cxnLst>"
  for i in 1..<=child_count {
    parts = parts +
      "<cxn modelId=\"100" +
      i.to_string() +
      "\" srcId=\"0\" destId=\"" +
      i.to_string() +
      "\" srcOrd=\"0\" destOrd=\"0\" type=\"parOf\"/>"
  }
  parts = parts + "</cxnLst></dataModel>"
  data_model(parts)
}

///|
/// Build the canonical "lin children of root" layout: a wrapper
/// layoutNode whose immediate child runs a `forEach axis=ch`
/// over the children of the root, emitting a `lin` shape per
/// child. Used by the per-algorithm tests so only the algorithm
/// type varies.
fn layout_for(algorithm : String, shape_type : String) -> DiagramDefinition {
  let xml = "<layoutDef uniqueId=\"urn:test\">" +
    "<layoutNode name=\"root\">" +
    "<alg type=\"" +
    algorithm +
    "\"/>" +
    "<forEach name=\"each\" axis=\"ch\" ptType=\"node\">" +
    "<layoutNode name=\"node\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"" +
    shape_type +
    "\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "</layoutNode>" +
    "</forEach>" +
    "</layoutNode>" +
    "</layoutDef>"
  definition(xml)
}

///|
test "§21.4 section_name accessor cites Part 1 §21.4" {
  let citation = diagram_layout_part1_21_4_section_name()
  assert_eq(citation, "Part 1 §21.4")
}

///|
test "§21.4.7.1 ST_AlgorithmType decoder roundtrips canonical tokens" {
  assert_true(try! (AlgorithmType::from_attr("lin") is AlgLin))
  assert_true(try! (AlgorithmType::from_attr("snake") is AlgSnake))
  assert_true(try! (AlgorithmType::from_attr("cycle") is AlgCycle))
  assert_true(try! (AlgorithmType::from_attr("hierRoot") is AlgHierRoot))
  assert_true(try! (AlgorithmType::from_attr("hierChild") is AlgHierChild))
  assert_true(try! (AlgorithmType::from_attr("pyra") is AlgPyra))
  assert_true(try! (AlgorithmType::from_attr("composite") is AlgComposite))
  let bad = try? AlgorithmType::from_attr("definitely-not-an-alg")
  assert_true(bad is Err(_))
}

///|
test "§21.4.7.1 AlgorithmType::is_supported flags canonical layouts" {
  assert_true(AlgLin.is_supported())
  assert_true(AlgSnake.is_supported())
  assert_true(AlgCycle.is_supported())
  assert_true(AlgHierRoot.is_supported())
  assert_true(AlgHierChild.is_supported())
  assert_true(AlgPyra.is_supported())
  // Out-of-scope algorithms fall back to lin per Requirement 13.
  assert_false(AlgComposite.is_supported())
  assert_false(AlgConn.is_supported())
  assert_false(AlgSp.is_supported())
  assert_false(AlgTx.is_supported())
}

///|
test "§21.4.7.21 ConstraintKind decoder maps canonical tokens" {
  assert_true(ConstraintKind::from_attr("w") is ConstrW)
  assert_true(ConstraintKind::from_attr("sp") is ConstrSp)
  assert_true(ConstraintKind::from_attr("pyraAcctRatio") is ConstrPyraAcctRatio)
  match ConstraintKind::from_attr("ctrX") {
    ConstrOther(name) => assert_eq(name, "ctrX")
    _ => panic()
  }
}

///|
test "§21.4.2.10 decode_data_model populates parent_id from parOf cxn" {
  let dm = flat_data_model(3)
  assert_eq(dm.points.length(), 4)
  assert_eq(dm.points[0].id, "0")
  assert_eq(dm.points[0].parent_id, None)
  assert_eq(dm.points[1].parent_id, Some("0"))
  assert_eq(dm.points[2].parent_id, Some("0"))
  assert_eq(dm.points[3].parent_id, Some("0"))
  assert_eq(dm.connections.length(), 3)
  assert_eq(dm.connections[0].src_id, "0")
  assert_eq(dm.connections[0].dest_id, "1")
}

///|
test "§21.4.7.1 lin algorithm distributes 4 nodes left-to-right" {
  let engine = DiagramLayoutEngine::new()
  let def = layout_for("lin", "rect")
  let dm = flat_data_model(4)
  let result = engine.apply(def, dm, canvas())
  assert_eq(result.length(), 4)
  let widths = 1000.0 / 4.0
  for i in 0..<4 {
    assert_eq(result[i].point_id, (i + 1).to_string())
    assert_eq(result[i].bounds.x, i.to_double() * widths)
    assert_eq(result[i].bounds.y, 0.0)
    assert_eq(result[i].bounds.width, widths)
    assert_eq(result[i].bounds.height, 500.0)
    assert_true(result[i].shape is @preset_geometry.ShapeRect)
  }
}

///|
test "§21.4.7.1 snake algorithm wraps to ceil(sqrt(n)) columns" {
  let engine = DiagramLayoutEngine::new()
  let def = layout_for("snake", "rect")
  let dm = flat_data_model(4)
  let result = engine.apply(def, dm, canvas())
  // ceil(sqrt(4)) = 2 → 2x2 grid
  assert_eq(result.length(), 4)
  assert_eq(result[0].bounds.x, 0.0)
  assert_eq(result[0].bounds.y, 0.0)
  assert_eq(result[0].bounds.width, 500.0)
  assert_eq(result[0].bounds.height, 250.0)
  assert_eq(result[1].bounds.x, 500.0)
  assert_eq(result[1].bounds.y, 0.0)
  assert_eq(result[2].bounds.x, 0.0)
  assert_eq(result[2].bounds.y, 250.0)
  assert_eq(result[3].bounds.x, 500.0)
  assert_eq(result[3].bounds.y, 250.0)
}

///|
test "§21.4.7.1 cycle algorithm places 4 nodes on cardinal points" {
  let engine = DiagramLayoutEngine::new()
  let def = layout_for("cycle", "ellipse")
  let dm = flat_data_model(4)
  let result = engine.apply(def, dm, canvas())
  assert_eq(result.length(), 4)
  // Cell side: min(1000, 500) / 3 ≈ 166.667
  let cell = 500.0 / 3.0
  let half_cell = cell / 2.0
  let radius = 250.0 - half_cell
  let cx = 500.0
  let cy = 250.0
  // First child (i=0): theta=-90 → top of circle.
  // x = cx + radius*cos(-90) - half_cell = cx + 0 - half_cell
  // y = cy + radius*sin(-90) - half_cell = cy - radius - half_cell
  let first = result[0].bounds
  assert_true((first.x - (cx - half_cell)).abs() < 0.01)
  assert_true((first.y - (cy - radius - half_cell)).abs() < 0.01)
  // Second child (i=1): theta=0 → right of circle.
  let second = result[1].bounds
  assert_true((second.x - (cx + radius - half_cell)).abs() < 0.01)
  assert_true((second.y - (cy - half_cell)).abs() < 0.01)
  // Width = height = cell side.
  for nb in result {
    assert_true((nb.bounds.width - cell).abs() < 0.01)
    assert_true((nb.bounds.height - cell).abs() < 0.01)
    assert_true(nb.shape is @preset_geometry.ShapeEllipse)
  }
}

///|
test "§21.4.7.1 hier algorithm places root above children" {
  // Hier needs root + children, so use a custom layout that maps
  // the root point to a shape via presOf=self, then runs a
  // hierChild forEach over the children.
  let xml = "<layoutDef uniqueId=\"urn:test\">" +
    "<layoutNode name=\"root\">" +
    "<alg type=\"hierRoot\"/>" +
    "<layoutNode name=\"rootNode\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"rect\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "</layoutNode>" +
    "<layoutNode name=\"childContainer\">" +
    "<alg type=\"hierChild\"/>" +
    "<forEach name=\"each\" axis=\"ch\" ptType=\"node\">" +
    "<layoutNode name=\"child\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"rect\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "</layoutNode>" +
    "</forEach>" +
    "</layoutNode>" +
    "</layoutNode>" +
    "</layoutDef>"
  let def = definition(xml)
  let dm = flat_data_model(2)
  let engine = DiagramLayoutEngine::new()
  let result = engine.apply(def, dm, canvas())
  // Expect 1 root + 2 children = 3 bounds emitted.
  assert_eq(result.length(), 3)
  let root_bounds = result[0]
  assert_eq(root_bounds.point_id, "0")
  assert_eq(root_bounds.bounds.x, 0.0)
  assert_eq(root_bounds.bounds.y, 0.0)
  assert_eq(root_bounds.bounds.width, 1000.0)
  // Root height is 30 % of canvas: 0.3 * 500 = 150.
  assert_true((root_bounds.bounds.height - 150.0).abs() < 0.001)
  // Children share the remaining 350 of height, full width split.
  let first_child = result[1]
  let second_child = result[2]
  assert_eq(first_child.point_id, "1")
  assert_eq(second_child.point_id, "2")
  assert_eq(first_child.bounds.x, 0.0)
  assert_eq(second_child.bounds.x, 500.0)
  assert_eq(first_child.bounds.width, 500.0)
  assert_true((first_child.bounds.height - 350.0).abs() < 0.001)
  assert_true((first_child.bounds.y - 150.0).abs() < 0.001)
}

///|
test "§21.4.7.1 pyra algorithm stacks 3 trapezoids top-to-bottom" {
  let engine = DiagramLayoutEngine::new()
  let def = layout_for("pyra", "trapezoid")
  let dm = flat_data_model(3)
  let result = engine.apply(def, dm, canvas())
  assert_eq(result.length(), 3)
  // n = 3, default pyraAcctRatio = 0.25, row_h = 500/3 ≈ 166.67
  let row_h = 500.0 / 3.0
  // Top row (i=0) width = 1000 * 0.25 = 250
  let top = result[0]
  assert_true((top.bounds.width - 250.0).abs() < 0.001)
  assert_true((top.bounds.x - (1000.0 - 250.0) / 2.0).abs() < 0.001)
  assert_true((top.bounds.y - 0.0).abs() < 0.001)
  assert_true((top.bounds.height - row_h).abs() < 0.001)
  // Middle row (i=1) width = 1000 * (0.25 + 0.75 * 1/2) = 625
  let mid = result[1]
  assert_true((mid.bounds.width - 625.0).abs() < 0.001)
  assert_true((mid.bounds.x - (1000.0 - 625.0) / 2.0).abs() < 0.001)
  assert_true((mid.bounds.y - row_h).abs() < 0.001)
  // Bottom row (i=2) width = 1000 * 1.0 = 1000
  let base = result[2]
  assert_true((base.bounds.width - 1000.0).abs() < 0.001)
  assert_true((base.bounds.x - 0.0).abs() < 0.001)
  assert_true((base.bounds.y - 2.0 * row_h).abs() < 0.001)
}

///|
test "§21.4.2.6 choose / if cnt-bucket selects matching branch" {
  // Layout uses choose to pick between lin (≤2 children) and
  // snake (≥3 children). With 4 children, the snake branch fires.
  let xml = "<layoutDef uniqueId=\"urn:test\">" +
    "<layoutNode name=\"root\">" +
    "<choose name=\"sizeSwitch\">" +
    "<if name=\"small\" func=\"cnt\" axis=\"ch\" ptType=\"node\" op=\"lte\" val=\"2\">" +
    "<layoutNode name=\"linWrap\">" +
    "<alg type=\"lin\"/>" +
    "<forEach name=\"each\" axis=\"ch\" ptType=\"node\">" +
    "<layoutNode name=\"node\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"rect\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "</layoutNode>" +
    "</forEach>" +
    "</layoutNode>" +
    "</if>" +
    "<else name=\"big\">" +
    "<layoutNode name=\"snakeWrap\">" +
    "<alg type=\"snake\"/>" +
    "<forEach name=\"each\" axis=\"ch\" ptType=\"node\">" +
    "<layoutNode name=\"node\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"ellipse\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "</layoutNode>" +
    "</forEach>" +
    "</layoutNode>" +
    "</else>" +
    "</choose>" +
    "</layoutNode>" +
    "</layoutDef>"
  let def = definition(xml)
  let engine = DiagramLayoutEngine::new()

  // 2 children → lin branch (rect shapes).
  let small_result = engine.apply(def, flat_data_model(2), canvas())
  assert_eq(small_result.length(), 2)
  assert_true(small_result[0].shape is @preset_geometry.ShapeRect)
  assert_eq(small_result[0].bounds.width, 500.0)

  // 4 children → snake branch (ellipse shapes).
  let big_result = engine.apply(def, flat_data_model(4), canvas())
  assert_eq(big_result.length(), 4)
  assert_true(big_result[0].shape is @preset_geometry.ShapeEllipse)
  assert_eq(big_result[0].bounds.width, 500.0)
  assert_eq(big_result[0].bounds.height, 250.0)
}

///|
test "§21.4.2.14 forEach iterates over axis=ch children" {
  let engine = DiagramLayoutEngine::new()
  let def = layout_for("lin", "rect")
  let dm = flat_data_model(5)
  let result = engine.apply(def, dm, canvas())
  assert_eq(result.length(), 5)
  for i in 0..<5 {
    assert_eq(result[i].point_id, (i + 1).to_string())
  }
}

///|
test "§21.4.7.1 unknown algorithm falls back to lin" {
  // `sp` is a no-op in spec; the engine falls back to lin so the
  // children still receive bounds rather than disappearing.
  let engine = DiagramLayoutEngine::new()
  let def = layout_for("sp", "rect")
  let dm = flat_data_model(3)
  let result = engine.apply(def, dm, canvas())
  assert_eq(result.length(), 3)
  let unit = 1000.0 / 3.0
  for i in 0..<3 {
    assert_true((result[i].bounds.width - unit).abs() < 0.001)
  }
}

///|
test "§21.4 layout engine handles empty data model gracefully" {
  // No data points → no NodeBounds emitted, but the engine
  // should not crash.
  let dm = data_model("<dataModel><ptLst/><cxnLst/></dataModel>")
  let def = layout_for("lin", "rect")
  let engine = DiagramLayoutEngine::new()
  let result = engine.apply(def, dm, canvas())
  assert_eq(result.length(), 0)
}

///|
test "§21.4.2.16 decode_diagram_definition reads layoutDef attributes" {
  let def = definition(
    "<layoutDef uniqueId=\"urn:test\" minVer=\"http://schemas.openxmlformats.org/drawingml/2006/diagram\" defStyle=\"default\">" +
    "<layoutNode name=\"root\"/>" +
    "</layoutDef>",
  )
  assert_eq(def.unique_id, Some("urn:test"))
  assert_eq(
    def.min_ver,
    Some("http://schemas.openxmlformats.org/drawingml/2006/diagram"),
  )
  assert_eq(def.def_style, Some("default"))
  assert_eq(def.root.name, "root")
}

///|
test "§21.4.2.16 decode_diagram_definition rejects missing layoutNode" {
  let element = parse_root("<layoutDef uniqueId=\"urn:test\"/>")
  let wrapper = try! @domain.CT_DiagramDefinition::new(element)
  let bad = try? decode_diagram_definition(wrapper)
  assert_true(bad is Err(_))
}

///|
test "§21.4.2.8 decode_constraint preserves type / val / fact" {
  let element = parse_root(
    "<constr type=\"pyraAcctRatio\" for=\"ch\" forName=\"node1\" op=\"equ\" val=\"0.4\" fact=\"1.5\"/>",
  )
  let c = try! decode_constraint(element)
  assert_true(c.kind is ConstrPyraAcctRatio)
  assert_eq(c.for_target, Some("ch"))
  assert_eq(c.for_name, Some("node1"))
  assert_eq(c.val, Some(0.4))
  assert_eq(c.fact, Some(1.5))
  assert_true(c.op is Some(OpEqu))
}

///|
test "§21.4.7.32 FunctionOp decoder accepts every operator" {
  assert_true(try! (FunctionOp::from_attr("equ") is OpEqu))
  assert_true(try! (FunctionOp::from_attr("neq") is OpNeq))
  assert_true(try! (FunctionOp::from_attr("gt") is OpGt))
  assert_true(try! (FunctionOp::from_attr("lt") is OpGte))
  assert_true(try! (FunctionOp::from_attr("gte") is OpGteValue))
  assert_true(try! (FunctionOp::from_attr("lte") is OpLte))
  let bad = try? FunctionOp::from_attr("nope")
  assert_true(bad is Err(_))
}

///|
test "§21.4.7.6 AxisType decoder defaults unknown values to none" {
  assert_true(AxisType::from_attr("ch") is AxisCh)
  assert_true(AxisType::from_attr("des") is AxisDes)
  assert_true(AxisType::from_attr("self") is AxisSelf)
  assert_true(AxisType::from_attr("definitely-not-an-axis") is AxisNone)
}

///|
/// §21.4.7.1 — 3-level hierRoot recursion: doc → CEO → VPs → Mgrs.
/// Mirrors the catalog fixture `diagram-orgChart-with-connectors`
/// to ensure the engine emits five `NodeBounds` (CEO + 2 VPs +
/// 2 Managers) so the renderer's connector emitter has the bounds
/// it needs.
test "§21.4.7.1 hier 3-level recursion emits NodeBounds for every level" {
  // Nested hierRoot: each level emits a shape for the current
  // context and dispatches its children container.
  let layout_xml = "<layoutDef uniqueId=\"urn:test:org3\">" +
    "<layoutNode name=\"root\">" +
    "<alg type=\"hierRoot\"/>" +
    "<layoutNode name=\"rootShape\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"rect\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "</layoutNode>" +
    "<layoutNode name=\"l1Container\">" +
    "<alg type=\"hierChild\"/>" +
    "<forEach name=\"l1each\" axis=\"ch\" ptType=\"node\">" +
    "<layoutNode name=\"l1\">" +
    "<alg type=\"hierRoot\"/>" +
    "<layoutNode name=\"l1Shape\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"rect\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "</layoutNode>" +
    "<layoutNode name=\"l2Container\">" +
    "<alg type=\"hierChild\"/>" +
    "<forEach name=\"l2each\" axis=\"ch\" ptType=\"node\">" +
    "<layoutNode name=\"l2\">" +
    "<alg type=\"hierRoot\"/>" +
    "<layoutNode name=\"l2Shape\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"rect\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "</layoutNode>" +
    "<layoutNode name=\"l3Container\">" +
    "<alg type=\"hierChild\"/>" +
    "<forEach name=\"l3each\" axis=\"ch\" ptType=\"node\">" +
    "<layoutNode name=\"l3Shape\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"rect\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "</layoutNode>" +
    "</forEach>" +
    "</layoutNode>" +
    "</layoutNode>" +
    "</forEach>" +
    "</layoutNode>" +
    "</layoutNode>" +
    "</forEach>" +
    "</layoutNode>" +
    "</layoutNode>" +
    "</layoutDef>"
  let def = definition(layout_xml)
  let dm_xml = "<dataModel>" +
    "<ptLst>" +
    "<pt modelId=\"0\" type=\"doc\"/>" +
    "<pt modelId=\"1\" type=\"node\"/>" +
    "<pt modelId=\"10\" type=\"node\"/>" +
    "<pt modelId=\"20\" type=\"node\"/>" +
    "<pt modelId=\"100\" type=\"node\"/>" +
    "<pt modelId=\"200\" type=\"node\"/>" +
    "</ptLst>" +
    "<cxnLst>" +
    "<cxn modelId=\"101\" srcId=\"0\" destId=\"1\" srcOrd=\"0\" destOrd=\"0\"/>" +
    "<cxn modelId=\"102\" srcId=\"1\" destId=\"10\" srcOrd=\"0\" destOrd=\"0\"/>" +
    "<cxn modelId=\"103\" srcId=\"1\" destId=\"20\" srcOrd=\"1\" destOrd=\"0\"/>" +
    "<cxn modelId=\"104\" srcId=\"10\" destId=\"100\" srcOrd=\"0\" destOrd=\"0\"/>" +
    "<cxn modelId=\"105\" srcId=\"20\" destId=\"200\" srcOrd=\"0\" destOrd=\"0\"/>" +
    "</cxnLst>" +
    "</dataModel>"
  let dm = data_model(dm_xml)
  let engine = DiagramLayoutEngine::new()
  let result = engine.apply(def, dm, canvas())
  // Walk: rootShape emits "0"; l1Container's forEach iterates ch
  // of "0" → [CEO "1"]; l1 hierRoot{l1Shape,l2Container}:
  // l1Shape emits "1"; l2Container's forEach iterates ch of "1"
  // → [VP "10", "20"]; l2 hierRoot{l2Shape,l3Container} each:
  // l2Shape emits "10"/"20"; l3Container iterates ch of
  // "10"/"20" → [Manager "100"/"200"]; l3Shape emits each.
  // Total = 1 + 1 + 2 + 2 = 6 NodeBounds.
  assert_eq(result.length(), 6)
}

///|
/// §21.4.7.21 ST_ConstraintType — `constraint_kind_is_geometric`
/// must report every layout-driving constraint as spatial and
/// every text-fitting / catch-all constraint as non-spatial.
/// `primFontSz` is the canonical non-spatial example that the
/// renderer's gate uses to decline rendering.
test "§21.4.7.21 constraint_kind_is_geometric separates spatial vs typography" {
  // Spatial — every member of the kept ConstrW…ConstrPyraAcctRatio set.
  assert_eq(constraint_kind_is_geometric(ConstrW), true)
  assert_eq(constraint_kind_is_geometric(ConstrH), true)
  assert_eq(constraint_kind_is_geometric(ConstrL), true)
  assert_eq(constraint_kind_is_geometric(ConstrT), true)
  assert_eq(constraint_kind_is_geometric(ConstrR), true)
  assert_eq(constraint_kind_is_geometric(ConstrB), true)
  assert_eq(constraint_kind_is_geometric(ConstrLMarg), true)
  assert_eq(constraint_kind_is_geometric(ConstrSp), true)
  assert_eq(constraint_kind_is_geometric(ConstrSibSp), true)
  assert_eq(constraint_kind_is_geometric(ConstrWOff), true)
  assert_eq(constraint_kind_is_geometric(ConstrPyraAcctRatio), true)
  // Non-spatial — every catch-all (incl. the canonical `primFontSz`).
  assert_eq(constraint_kind_is_geometric(ConstrOther("primFontSz")), false)
  assert_eq(constraint_kind_is_geometric(ConstrOther("secFontSz")), false)
  assert_eq(constraint_kind_is_geometric(ConstrOther("userA")), false)
}

///|
/// §21.4.2.16 CT_DiagramDefinition — the gate predicate must report
/// `false` when the only constraint in the tree is non-spatial,
/// and `true` as soon as one spatial constraint appears anywhere
/// in the layout-node tree.
test "§21.4.2.16 definition_has_geometric_constraints gates on spatial intent" {
  // Only primFontSz — non-spatial; gate must be false.
  let only_font = definition(
    "<layoutDef uniqueId=\"urn:test\">" +
    "<layoutNode name=\"root\">" +
    "<alg type=\"lin\"/>" +
    "<constrLst>" +
    "<constr type=\"primFontSz\" val=\"65\"/>" +
    "</constrLst>" +
    "</layoutNode>" +
    "</layoutDef>",
  )
  assert_eq(definition_has_geometric_constraints(only_font), false)
  // Spatial w constraint — gate must be true.
  let with_w = definition(
    "<layoutDef uniqueId=\"urn:test\">" +
    "<layoutNode name=\"root\">" +
    "<alg type=\"lin\"/>" +
    "<constrLst>" +
    "<constr type=\"primFontSz\" val=\"65\"/>" +
    "<constr type=\"w\" val=\"500\"/>" +
    "</constrLst>" +
    "</layoutNode>" +
    "</layoutDef>",
  )
  assert_eq(definition_has_geometric_constraints(with_w), true)
  // Spatial constraint nested under a forEach body — gate must
  // still be true (recursive walk).
  let nested = definition(
    "<layoutDef uniqueId=\"urn:test\">" +
    "<layoutNode name=\"root\">" +
    "<alg type=\"lin\"/>" +
    "<forEach name=\"each\" axis=\"ch\" ptType=\"node\">" +
    "<layoutNode name=\"child\">" +
    "<alg type=\"sp\"/>" +
    "<constrLst><constr type=\"sp\" val=\"100\"/></constrLst>" +
    "</layoutNode>" +
    "</forEach>" +
    "</layoutNode>" +
    "</layoutDef>",
  )
  assert_eq(definition_has_geometric_constraints(nested), true)
}

///|
/// §21.4.2.8 constr — a `self`-targeting `w` constraint must
/// override the parent-derived width; `l` must reanchor the x
/// origin relative to the parent bounds. Used to make sure the
/// `walk_layout_node` integration in `engine.mbt` honours the
/// solver before applying margins.
test "§21.4.2.8 apply_self_geometric_constraints honours w/h/l/t" {
  let parent : BoundsRect = { x: 100.0, y: 200.0, width: 600.0, height: 400.0 }
  // No constraints — passthrough (component-wise compare; BoundsRect
  // implements Debug but not Show, so we cannot pass the struct to
  // assert_eq).
  let pass = apply_self_geometric_constraints(parent, [])
  assert_eq(pass.x, parent.x)
  assert_eq(pass.y, parent.y)
  assert_eq(pass.width, parent.width)
  assert_eq(pass.height, parent.height)
  // Explicit w/h — replace width / height (origin unchanged).
  let resized = apply_self_geometric_constraints(parent, [
    test_constraint(ConstrW, val=Some(250.0)),
    test_constraint(ConstrH, for_target=Some("self"), val=Some(150.0)),
  ])
  assert_eq(resized.x, 100.0)
  assert_eq(resized.y, 200.0)
  assert_eq(resized.width, 250.0)
  assert_eq(resized.height, 150.0)
  // l/t — re-anchor relative to parent origin.
  let moved = apply_self_geometric_constraints(parent, [
    test_constraint(ConstrL, val=Some(50.0)),
    test_constraint(ConstrT, val=Some(20.0), fact=Some(2.0)),
  ])
  // x = parent.x (100) + 50 = 150; y = parent.y (200) + 20*2 = 240.
  assert_eq(moved.x, 150.0)
  assert_eq(moved.y, 240.0)
  // Cross-node constraints (for!=self or refFor*) ignored by
  // `apply_self_geometric_constraints`; they are handled later by
  // the child-targeted pass `child_targeted_constraints_for`.
  let cross = apply_self_geometric_constraints(parent, [
    test_constraint(
      ConstrW,
      for_target=Some("ch"),
      for_name=Some("node"),
      val=Some(10.0),
    ),
  ])
  assert_eq(cross.width, parent.width)
}

///|
/// §21.4.2.8 constr — `r` (right anchor) and `b` (bottom anchor)
/// constraints should resize the rectangle so its trailing edge
/// lands at the supplied offset from `parent_bounds.x` /
/// `parent_bounds.y`. Cross-verifies the new branch added in
/// `apply_self_geometric_constraints` for §21.4.7.21 r / b.
test "§21.4.2.8 apply_self_geometric_constraints honours r/b anchors" {
  let parent : BoundsRect = { x: 100.0, y: 200.0, width: 600.0, height: 400.0 }
  // r = 500 means the right edge sits at parent.x + 500 = 600.
  // With x unchanged (= 100), width becomes 600 - 100 = 500.
  let with_r = apply_self_geometric_constraints(parent, [
    test_constraint(ConstrR, val=Some(500.0)),
  ])
  assert_eq(with_r.x, 100.0)
  assert_eq(with_r.width, 500.0)
  // b = 300 means the bottom edge sits at parent.y + 300 = 500.
  // With y unchanged (= 200), height becomes 500 - 200 = 300.
  let with_b = apply_self_geometric_constraints(parent, [
    test_constraint(ConstrB, val=Some(300.0)),
  ])
  assert_eq(with_b.y, 200.0)
  assert_eq(with_b.height, 300.0)
  // Combined l + r — the right anchor is computed after the
  // left anchor moves x, so width = (parent.x + r) - new_x.
  let lr = apply_self_geometric_constraints(parent, [
    test_constraint(ConstrL, val=Some(50.0)),
    test_constraint(ConstrR, val=Some(450.0)),
  ])
  // new_x = 100 + 50 = 150; right edge = 100 + 450 = 550;
  // width = 550 - 150 = 400.
  assert_eq(lr.x, 150.0)
  assert_eq(lr.width, 400.0)
}

///|
/// §21.4.2.8 constr — `wOff` / `hOff` additive offsets should
/// shrink or grow the rectangle without changing its origin.
test "§21.4.2.8 apply_self_geometric_constraints honours wOff/hOff" {
  let parent : BoundsRect = { x: 0.0, y: 0.0, width: 600.0, height: 400.0 }
  let grown = apply_self_geometric_constraints(parent, [
    test_constraint(ConstrWOff, val=Some(100.0)),
    test_constraint(ConstrHOff, val=Some(-50.0)),
  ])
  assert_eq(grown.x, 0.0)
  assert_eq(grown.y, 0.0)
  assert_eq(grown.width, 700.0)
  assert_eq(grown.height, 350.0)
  // Negative width clamps to 0 (so renderers never see a
  // degenerate rectangle).
  let shrunk = apply_self_geometric_constraints(parent, [
    test_constraint(ConstrWOff, val=Some(-1000.0)),
  ])
  assert_eq(shrunk.width, 0.0)
}

///|
/// §21.4.2.8 constr/@refType — a `w` constraint that references
/// `h` on the same node (`refType="h"` with `refFor="self"` /
/// absent) should compute width from the in-flight height. `l/t/r/b`
/// references also resolve against the in-flight rectangle: `l` /
/// `t` read the origin (relative to parent), `r` / `b` read
/// `origin + length`.
test "§21.4.2.8 same-node refType resolves against current rect" {
  let parent : BoundsRect = { x: 0.0, y: 0.0, width: 600.0, height: 400.0 }
  // w = h * 0.5 — width becomes 400 * 0.5 = 200, height stays.
  let scaled = apply_self_geometric_constraints(parent, [
    test_constraint(ConstrW, ref_type=Some(ConstrH), fact=Some(0.5)),
  ])
  assert_eq(scaled.width, 200.0)
  assert_eq(scaled.height, 400.0)
  // l = r * 0.5 — `r` reads the in-flight right edge (initially
  // parent.x + width = 600). new_x = parent.x + 600 * 0.5 = 300;
  // the explicit `l` then shifts x but does NOT shrink the
  // width (the spec treats `l`/`t` as origin moves; width follows
  // the existing rectangle). After the move, width stays 600.
  let l_from_r = apply_self_geometric_constraints(parent, [
    test_constraint(ConstrL, ref_type=Some(ConstrR), fact=Some(0.5)),
  ])
  assert_eq(l_from_r.x, 300.0)
  assert_eq(l_from_r.width, 600.0)
  // refType=sibSp is *not* an in-flight rectangle variable
  // (sibling spacing has no slot on a single node's bounds), and
  // no literal `val` is supplied → the constraint is a no-op.
  let noop = apply_self_geometric_constraints(parent, [
    test_constraint(ConstrL, ref_type=Some(ConstrSibSp), fact=Some(0.5)),
  ])
  assert_eq(noop.x, 0.0)
  assert_eq(noop.width, 600.0)
}

///|
/// §21.4.2.8 constr/@for=ch — `child_targeted_constraints_for`
/// must filter on `for=ch | des` and (when present) match
/// `forName` against the child's layoutNode `name`. The returned
/// constraint is rewritten as `for=self` so the caller can hand
/// it straight to `apply_self_geometric_constraints`.
test "§21.4.2.8 child_targeted_constraints_for filters by for/forName" {
  let parent_constraints = [
    // Targets every child (forName absent).
    test_constraint(ConstrW, for_target=Some("ch"), val=Some(120.0)),
    // Targets only `nodeA` by name.
    test_constraint(
      ConstrH,
      for_target=Some("ch"),
      for_name=Some("nodeA"),
      val=Some(60.0),
    ),
    // for=des matches the same way as for=ch (descendants vs
    // children — the engine recurses, so both cascade).
    test_constraint(
      ConstrL,
      for_target=Some("des"),
      for_name=Some("nodeA"),
      val=Some(15.0),
    ),
    // for=self — must NOT appear in the child-targeted subset.
    test_constraint(ConstrW, for_target=Some("self"), val=Some(999.0)),
  ]
  let for_a = child_targeted_constraints_for(parent_constraints, "nodeA")
  // nodeA receives the unnamed `w=120`, the `h=60` (forName=nodeA),
  // and the `l=15` (for=des forName=nodeA). The for=self entry is
  // filtered out.
  assert_eq(for_a.length(), 3)
  for c in for_a {
    assert_eq(c.for_target, Some("self"))
  }
  let for_b = child_targeted_constraints_for(parent_constraints, "nodeB")
  // nodeB only matches the unnamed w=120 — the forName=nodeA ones
  // and the for=self one are filtered out.
  assert_eq(for_b.length(), 1)
  assert_true(for_b[0].kind is ConstrW)
}

///|
/// §21.4.2.8 — end-to-end: a parent `lin` layout with a
/// `<constr for="ch" forName="leaf" type="w" val="…"/>` must
/// override the algorithm-derived child width when the engine
/// recurses into the named child. Validates `recurse_into_child`
/// in `engine.mbt` wires the solver through.
test "§21.4.2.8 parent for=ch forName constraint overrides child width" {
  let layout_xml = "<layoutDef uniqueId=\"urn:test:constr-ch\">" +
    "<layoutNode name=\"root\">" +
    "<alg type=\"lin\"/>" +
    // Override every `leaf` child's width to 200; height to 50.
    "<constrLst>" +
    "<constr type=\"w\" for=\"ch\" forName=\"leaf\" val=\"200\"/>" +
    "<constr type=\"h\" for=\"ch\" forName=\"leaf\" val=\"50\"/>" +
    "</constrLst>" +
    "<forEach name=\"each\" axis=\"ch\" ptType=\"node\">" +
    "<layoutNode name=\"leaf\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"rect\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "</layoutNode>" +
    "</forEach>" +
    "</layoutNode>" +
    "</layoutDef>"
  let def = definition(layout_xml)
  let engine = DiagramLayoutEngine::new()
  let result = engine.apply(def, flat_data_model(3), canvas())
  assert_eq(result.length(), 3)
  // Every leaf must land at w=200, h=50 (overrides the lin
  // algorithm's natural 1000/3 ≈ 333 width and 500 height).
  for nb in result {
    assert_eq(nb.bounds.width, 200.0)
    assert_eq(nb.bounds.height, 50.0)
  }
}

///|
/// §21.4.2.8 constr/@refForName — cross-node references resolve
/// against the engine's name registry. When the named source
/// layoutNode was already walked (depth-first prior in document
/// order), the registry-aware solver substitutes the source's
/// `refType` variable; the value is then scaled by `fact` per the
/// spec's `target = source[refType] * fact` rule.
test "§21.4.2.8 cross-node refForName resolves via name registry" {
  // Registry pre-loaded with a `frame` node whose inner bounds are
  // 800 × 400 (typical container). The carrying node's constraint
  // declares `w` from `frame.w * 0.4` → 320.
  let registry : Map[String, BoundsRect] = Map::new()
  registry["frame"] = { x: 0.0, y: 0.0, width: 800.0, height: 400.0 }
  let parent : BoundsRect = { x: 0.0, y: 0.0, width: 1000.0, height: 500.0 }
  let with_ref = apply_self_geometric_constraints_with_registry(
    parent,
    [
      test_constraint(
        ConstrW,
        ref_type=Some(ConstrW),
        ref_for_name=Some("frame"),
        fact=Some(0.4),
      ),
    ],
    registry,
  )
  assert_eq(with_ref.width, 320.0)
  // refForName pointing at an absent name (forward reference) →
  // the registry lookup misses, and the solver falls through to the
  // same-node lookup before reaching the literal `val`. With
  // refType=w, the same-node lookup reads the in-flight rectangle
  // (= parent.width 1000) and returns it scaled by fact (default
  // 1.0). The literal `val=123` therefore never fires for this
  // input — it would only matter if refType pointed at a kind
  // `read_bounds_variable` does not recognise (margins / spacing).
  let forward = apply_self_geometric_constraints_with_registry(
    parent,
    [
      test_constraint(
        ConstrW,
        ref_type=Some(ConstrW),
        ref_for_name=Some("not-yet-walked"),
        val=Some(123.0),
      ),
    ],
    registry,
  )
  assert_eq(forward.width, 1000.0)
  // refForName + refType=h reads the named source's height.
  let height_ref = apply_self_geometric_constraints_with_registry(
    parent,
    [
      test_constraint(
        ConstrH,
        ref_type=Some(ConstrH),
        ref_for_name=Some("frame"),
        fact=Some(0.25),
      ),
    ],
    registry,
  )
  assert_eq(height_ref.height, 100.0)
}

///|
/// §21.4.2.19 layoutNode/@name — end-to-end: a layoutNode whose
/// `<constr type="w" refForName="root" refType="w" fact="0.25"/>`
/// must resolve against the root's bounds the walker registered
/// before descending. Validates the full engine wiring (registry
/// population in `walk_layout_node` + lookup in
/// `apply_self_geometric_constraints_with_registry`).
test "§21.4.2.19 layoutNode/@name registry feeds refForName end-to-end" {
  // Layout: root has natural canvas bounds (1000×500). A child
  // `leaf` carries `w refForName=root refType=w fact=0.25` and
  // `h refForName=root refType=h fact=0.5`, so each leaf shrinks
  // to 250 × 250 regardless of the lin algorithm's natural per-
  // child width / height.
  let xml = "<layoutDef uniqueId=\"urn:test:cross-node\">" +
    "<layoutNode name=\"root\">" +
    "<alg type=\"lin\"/>" +
    "<forEach name=\"each\" axis=\"ch\" ptType=\"node\">" +
    "<layoutNode name=\"leaf\">" +
    "<alg type=\"sp\"/>" +
    "<shape type=\"rect\"/>" +
    "<presOf axis=\"self\" ptType=\"all\"/>" +
    "<constrLst>" +
    "<constr type=\"w\" refType=\"w\" refForName=\"root\" fact=\"0.25\"/>" +
    "<constr type=\"h\" refType=\"h\" refForName=\"root\" fact=\"0.5\"/>" +
    "</constrLst>" +
    "</layoutNode>" +
    "</forEach>" +
    "</layoutNode>" +
    "</layoutDef>"
  let def = definition(xml)
  let engine = DiagramLayoutEngine::new()
  let result = engine.apply(def, flat_data_model(3), canvas())
  assert_eq(result.length(), 3)
  // 1000 * 0.25 = 250 width; 500 * 0.5 = 250 height — applies to
  // every leaf regardless of the lin per-child slot size.
  for nb in result {
    assert_eq(nb.bounds.width, 250.0)
    assert_eq(nb.bounds.height, 250.0)
  }
}

///|
/// §21.4.2.8 constr/@refType — round-trip the decoder for the
/// `refType` / `refFor` / `refForName` / `refPtType` /
/// `ptType` attributes. Ensures the typed `Constraint` carries
/// the cross-node reference plumbing the solver consumes.
test "§21.4.2.8 decode_constraint preserves ref* / pt_type fields" {
  let element = parse_root(
    "<constr type=\"w\" for=\"ch\" forName=\"node1\" ptType=\"node\" " +
    "refType=\"h\" refFor=\"self\" refForName=\"otherNode\" refPtType=\"all\" " +
    "op=\"equ\" val=\"100\" fact=\"0.5\"/>",
  )
  let c = try! decode_constraint(element)
  assert_true(c.kind is ConstrW)
  assert_eq(c.for_target, Some("ch"))
  assert_eq(c.for_name, Some("node1"))
  assert_eq(c.pt_type, Some("node"))
  assert_true(c.ref_type is Some(ConstrH))
  assert_eq(c.ref_for_target, Some("self"))
  assert_eq(c.ref_for_name, Some("otherNode"))
  assert_eq(c.ref_pt_type, Some("all"))
  assert_eq(c.val, Some(100.0))
  assert_eq(c.fact, Some(0.5))
  // `refType="none"` is the schema default; it should decode to
  // `None`, not `Some(ConstrOther("none"))`.
  let none_ref = parse_root("<constr type=\"w\" refType=\"none\" val=\"50\"/>")
  let cn = try! decode_constraint(none_ref)
  assert_true(cn.ref_type is None)
}

///|
/// Test helper: build a `Constraint` with the supplied `kind` and
/// optional overrides for every attribute the wbtest needs to set.
/// Centralised so wbtest authors do not have to spell out the
/// 10-field struct literal on every call, and so adding a new
/// schema attribute in `types.mbt` does not cascade into every
/// existing test.
fn test_constraint(
  kind : ConstraintKind,
  for_target? : String? = None,
  for_name? : String? = None,
  pt_type? : String? = None,
  ref_type? : ConstraintKind? = None,
  ref_for_target? : String? = None,
  ref_for_name? : String? = None,
  ref_pt_type? : String? = None,
  op? : FunctionOp? = None,
  val? : Double? = None,
  fact? : Double? = None,
) -> Constraint {
  {
    kind,
    for_target,
    for_name,
    pt_type,
    ref_type,
    ref_for_target,
    ref_for_name,
    ref_pt_type,
    op,
    val,
    fact,
  }
}
