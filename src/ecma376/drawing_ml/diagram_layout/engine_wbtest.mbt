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
