///|
test "ST_ClrAppMethod parses and formats one valid lexical value" {
  assert_eq(ST_ClrAppMethod::parse("span").to_string(), "span")
}

///|
test "ST_ClrAppMethod rejects one invalid lexical value" {
  try {
    ST_ClrAppMethod::parse("__invalid__") |> ignore
    fail("expected ST_ClrAppMethod rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_HueDir parses and formats one valid lexical value" {
  assert_eq(ST_HueDir::parse("cw").to_string(), "cw")
}

///|
test "ST_HueDir rejects one invalid lexical value" {
  try {
    ST_HueDir::parse("__invalid__") |> ignore
    fail("expected ST_HueDir rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_PtType parses and formats one valid lexical value" {
  assert_eq(ST_PtType::parse("node").to_string(), "node")
}

///|
test "ST_PtType rejects one invalid lexical value" {
  try {
    ST_PtType::parse("__invalid__") |> ignore
    fail("expected ST_PtType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_CxnType parses and formats one valid lexical value" {
  assert_eq(ST_CxnType::parse("parOf").to_string(), "parOf")
}

///|
test "ST_CxnType rejects one invalid lexical value" {
  try {
    ST_CxnType::parse("__invalid__") |> ignore
    fail("expected ST_CxnType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_LayoutShapeType parses and formats one valid lexical value" {
  assert_eq(ST_LayoutShapeType::parse("rect").to_string(), "rect")
}

///|
test "ST_LayoutShapeType rejects one invalid lexical value" {
  try {
    ST_LayoutShapeType::parse("") |> ignore
    fail("expected ST_LayoutShapeType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_Index1 parses and formats one valid lexical value" {
  assert_eq(ST_Index1::parse("1").to_string(), "1")
}

///|
test "ST_Index1 rejects one invalid lexical value" {
  try {
    ST_Index1::parse("") |> ignore
    fail("expected ST_Index1 rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ParameterVal parses and formats one valid lexical value" {
  assert_eq(ST_ParameterVal::parse("42").to_string(), "42")
}

///|
test "ST_ParameterVal rejects one invalid lexical value" {
  try {
    ST_ParameterVal::parse("") |> ignore
    fail("expected ST_ParameterVal rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ModelId parses and formats one valid lexical value" {
  assert_eq(ST_ModelId::parse("1").to_string(), "1")
}

///|
test "ST_ModelId rejects one invalid lexical value" {
  try {
    ST_ModelId::parse("") |> ignore
    fail("expected ST_ModelId rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_PrSetCustVal parses and formats one valid lexical value" {
  assert_eq(ST_PrSetCustVal::parse("50%").to_string(), "50%")
}

///|
test "ST_PrSetCustVal rejects one invalid lexical value" {
  try {
    ST_PrSetCustVal::parse("") |> ignore
    fail("expected ST_PrSetCustVal rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_Direction parses and formats one valid lexical value" {
  assert_eq(ST_Direction::parse("norm").to_string(), "norm")
}

///|
test "ST_Direction rejects one invalid lexical value" {
  try {
    ST_Direction::parse("__invalid__") |> ignore
    fail("expected ST_Direction rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_HierBranchStyle parses and formats one valid lexical value" {
  assert_eq(ST_HierBranchStyle::parse("l").to_string(), "l")
}

///|
test "ST_HierBranchStyle rejects one invalid lexical value" {
  try {
    ST_HierBranchStyle::parse("__invalid__") |> ignore
    fail("expected ST_HierBranchStyle rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_AnimOneStr parses and formats one valid lexical value" {
  assert_eq(ST_AnimOneStr::parse("none").to_string(), "none")
}

///|
test "ST_AnimOneStr rejects one invalid lexical value" {
  try {
    ST_AnimOneStr::parse("__invalid__") |> ignore
    fail("expected ST_AnimOneStr rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_AnimLvlStr parses and formats one valid lexical value" {
  assert_eq(ST_AnimLvlStr::parse("none").to_string(), "none")
}

///|
test "ST_AnimLvlStr rejects one invalid lexical value" {
  try {
    ST_AnimLvlStr::parse("__invalid__") |> ignore
    fail("expected ST_AnimLvlStr rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_NodeCount parses and formats one valid lexical value" {
  assert_eq(ST_NodeCount::parse("-1").to_string(), "-1")
}

///|
test "ST_NodeCount rejects one invalid lexical value" {
  try {
    ST_NodeCount::parse("") |> ignore
    fail("expected ST_NodeCount rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ResizeHandlesStr parses and formats one valid lexical value" {
  assert_eq(ST_ResizeHandlesStr::parse("exact").to_string(), "exact")
}

///|
test "ST_ResizeHandlesStr rejects one invalid lexical value" {
  try {
    ST_ResizeHandlesStr::parse("__invalid__") |> ignore
    fail("expected ST_ResizeHandlesStr rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_AlgorithmType parses and formats one valid lexical value" {
  assert_eq(ST_AlgorithmType::parse("composite").to_string(), "composite")
}

///|
test "ST_AlgorithmType rejects one invalid lexical value" {
  try {
    ST_AlgorithmType::parse("__invalid__") |> ignore
    fail("expected ST_AlgorithmType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_AxisType parses and formats one valid lexical value" {
  assert_eq(ST_AxisType::parse("self").to_string(), "self")
}

///|
test "ST_AxisType rejects one invalid lexical value" {
  try {
    ST_AxisType::parse("__invalid__") |> ignore
    fail("expected ST_AxisType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_AxisTypes parses and formats one valid lexical value" {
  assert_eq(ST_AxisTypes::parse("self ch").to_string(), "self ch")
}

///|
test "ST_AxisTypes rejects one invalid lexical value" {
  try {
    ST_AxisTypes::parse("") |> ignore
    fail("expected ST_AxisTypes rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_BoolOperator parses and formats one valid lexical value" {
  assert_eq(ST_BoolOperator::parse("none").to_string(), "none")
}

///|
test "ST_BoolOperator rejects one invalid lexical value" {
  try {
    ST_BoolOperator::parse("__invalid__") |> ignore
    fail("expected ST_BoolOperator rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ChildOrderType parses and formats one valid lexical value" {
  assert_eq(ST_ChildOrderType::parse("b").to_string(), "b")
}

///|
test "ST_ChildOrderType rejects one invalid lexical value" {
  try {
    ST_ChildOrderType::parse("__invalid__") |> ignore
    fail("expected ST_ChildOrderType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ConstraintType parses and formats one valid lexical value" {
  assert_eq(ST_ConstraintType::parse("none").to_string(), "none")
}

///|
test "ST_ConstraintType rejects one invalid lexical value" {
  try {
    ST_ConstraintType::parse("__invalid__") |> ignore
    fail("expected ST_ConstraintType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ConstraintRelationship parses and formats one valid lexical value" {
  assert_eq(ST_ConstraintRelationship::parse("self").to_string(), "self")
}

///|
test "ST_ConstraintRelationship rejects one invalid lexical value" {
  try {
    ST_ConstraintRelationship::parse("__invalid__") |> ignore
    fail("expected ST_ConstraintRelationship rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ElementType parses and formats one valid lexical value" {
  assert_eq(ST_ElementType::parse("all").to_string(), "all")
}

///|
test "ST_ElementType rejects one invalid lexical value" {
  try {
    ST_ElementType::parse("__invalid__") |> ignore
    fail("expected ST_ElementType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ElementTypes parses and formats one valid lexical value" {
  assert_eq(ST_ElementTypes::parse("all node").to_string(), "all node")
}

///|
test "ST_ElementTypes rejects one invalid lexical value" {
  try {
    ST_ElementTypes::parse("") |> ignore
    fail("expected ST_ElementTypes rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ParameterId parses and formats one valid lexical value" {
  assert_eq(ST_ParameterId::parse("horzAlign").to_string(), "horzAlign")
}

///|
test "ST_ParameterId rejects one invalid lexical value" {
  try {
    ST_ParameterId::parse("__invalid__") |> ignore
    fail("expected ST_ParameterId rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_Ints parses and formats one valid lexical value" {
  assert_eq(ST_Ints::parse("1 -2 3").to_string(), "1 -2 3")
}

///|
test "ST_Ints rejects one invalid lexical value" {
  try {
    ST_Ints::parse("") |> ignore
    fail("expected ST_Ints rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_UnsignedInts parses and formats one valid lexical value" {
  assert_eq(ST_UnsignedInts::parse("0 1 2").to_string(), "0 1 2")
}

///|
test "ST_UnsignedInts rejects one invalid lexical value" {
  try {
    ST_UnsignedInts::parse("") |> ignore
    fail("expected ST_UnsignedInts rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_Booleans parses and formats one valid lexical value" {
  assert_eq(ST_Booleans::parse("true false 1 0").to_string(), "true false 1 0")
}

///|
test "ST_Booleans rejects one invalid lexical value" {
  try {
    ST_Booleans::parse("") |> ignore
    fail("expected ST_Booleans rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_FunctionType parses and formats one valid lexical value" {
  assert_eq(ST_FunctionType::parse("cnt").to_string(), "cnt")
}

///|
test "ST_FunctionType rejects one invalid lexical value" {
  try {
    ST_FunctionType::parse("__invalid__") |> ignore
    fail("expected ST_FunctionType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_FunctionOperator parses and formats one valid lexical value" {
  assert_eq(ST_FunctionOperator::parse("equ").to_string(), "equ")
}

///|
test "ST_FunctionOperator rejects one invalid lexical value" {
  try {
    ST_FunctionOperator::parse("__invalid__") |> ignore
    fail("expected ST_FunctionOperator rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_DiagramHorizontalAlignment parses and formats one valid lexical value" {
  assert_eq(ST_DiagramHorizontalAlignment::parse("l").to_string(), "l")
}

///|
test "ST_DiagramHorizontalAlignment rejects one invalid lexical value" {
  try {
    ST_DiagramHorizontalAlignment::parse("__invalid__") |> ignore
    fail("expected ST_DiagramHorizontalAlignment rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_VerticalAlignment parses and formats one valid lexical value" {
  assert_eq(ST_VerticalAlignment::parse("t").to_string(), "t")
}

///|
test "ST_VerticalAlignment rejects one invalid lexical value" {
  try {
    ST_VerticalAlignment::parse("__invalid__") |> ignore
    fail("expected ST_VerticalAlignment rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ChildDirection parses and formats one valid lexical value" {
  assert_eq(ST_ChildDirection::parse("horz").to_string(), "horz")
}

///|
test "ST_ChildDirection rejects one invalid lexical value" {
  try {
    ST_ChildDirection::parse("__invalid__") |> ignore
    fail("expected ST_ChildDirection rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ChildAlignment parses and formats one valid lexical value" {
  assert_eq(ST_ChildAlignment::parse("t").to_string(), "t")
}

///|
test "ST_ChildAlignment rejects one invalid lexical value" {
  try {
    ST_ChildAlignment::parse("__invalid__") |> ignore
    fail("expected ST_ChildAlignment rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_SecondaryChildAlignment parses and formats one valid lexical value" {
  assert_eq(ST_SecondaryChildAlignment::parse("none").to_string(), "none")
}

///|
test "ST_SecondaryChildAlignment rejects one invalid lexical value" {
  try {
    ST_SecondaryChildAlignment::parse("__invalid__") |> ignore
    fail("expected ST_SecondaryChildAlignment rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_LinearDirection parses and formats one valid lexical value" {
  assert_eq(ST_LinearDirection::parse("fromL").to_string(), "fromL")
}

///|
test "ST_LinearDirection rejects one invalid lexical value" {
  try {
    ST_LinearDirection::parse("__invalid__") |> ignore
    fail("expected ST_LinearDirection rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_SecondaryLinearDirection parses and formats one valid lexical value" {
  assert_eq(ST_SecondaryLinearDirection::parse("none").to_string(), "none")
}

///|
test "ST_SecondaryLinearDirection rejects one invalid lexical value" {
  try {
    ST_SecondaryLinearDirection::parse("__invalid__") |> ignore
    fail("expected ST_SecondaryLinearDirection rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_StartingElement parses and formats one valid lexical value" {
  assert_eq(ST_StartingElement::parse("node").to_string(), "node")
}

///|
test "ST_StartingElement rejects one invalid lexical value" {
  try {
    ST_StartingElement::parse("__invalid__") |> ignore
    fail("expected ST_StartingElement rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_RotationPath parses and formats one valid lexical value" {
  assert_eq(ST_RotationPath::parse("none").to_string(), "none")
}

///|
test "ST_RotationPath rejects one invalid lexical value" {
  try {
    ST_RotationPath::parse("__invalid__") |> ignore
    fail("expected ST_RotationPath rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_CenterShapeMapping parses and formats one valid lexical value" {
  assert_eq(ST_CenterShapeMapping::parse("none").to_string(), "none")
}

///|
test "ST_CenterShapeMapping rejects one invalid lexical value" {
  try {
    ST_CenterShapeMapping::parse("__invalid__") |> ignore
    fail("expected ST_CenterShapeMapping rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_BendPoint parses and formats one valid lexical value" {
  assert_eq(ST_BendPoint::parse("beg").to_string(), "beg")
}

///|
test "ST_BendPoint rejects one invalid lexical value" {
  try {
    ST_BendPoint::parse("__invalid__") |> ignore
    fail("expected ST_BendPoint rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ConnectorRouting parses and formats one valid lexical value" {
  assert_eq(ST_ConnectorRouting::parse("stra").to_string(), "stra")
}

///|
test "ST_ConnectorRouting rejects one invalid lexical value" {
  try {
    ST_ConnectorRouting::parse("__invalid__") |> ignore
    fail("expected ST_ConnectorRouting rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ArrowheadStyle parses and formats one valid lexical value" {
  assert_eq(ST_ArrowheadStyle::parse("auto").to_string(), "auto")
}

///|
test "ST_ArrowheadStyle rejects one invalid lexical value" {
  try {
    ST_ArrowheadStyle::parse("__invalid__") |> ignore
    fail("expected ST_ArrowheadStyle rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ConnectorDimension parses and formats one valid lexical value" {
  assert_eq(ST_ConnectorDimension::parse("1D").to_string(), "1D")
}

///|
test "ST_ConnectorDimension rejects one invalid lexical value" {
  try {
    ST_ConnectorDimension::parse("__invalid__") |> ignore
    fail("expected ST_ConnectorDimension rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ConnectorPoint parses and formats one valid lexical value" {
  assert_eq(ST_ConnectorPoint::parse("auto").to_string(), "auto")
}

///|
test "ST_ConnectorPoint rejects one invalid lexical value" {
  try {
    ST_ConnectorPoint::parse("__invalid__") |> ignore
    fail("expected ST_ConnectorPoint rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_NodeHorizontalAlignment parses and formats one valid lexical value" {
  assert_eq(ST_NodeHorizontalAlignment::parse("l").to_string(), "l")
}

///|
test "ST_NodeHorizontalAlignment rejects one invalid lexical value" {
  try {
    ST_NodeHorizontalAlignment::parse("__invalid__") |> ignore
    fail("expected ST_NodeHorizontalAlignment rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_NodeVerticalAlignment parses and formats one valid lexical value" {
  assert_eq(ST_NodeVerticalAlignment::parse("t").to_string(), "t")
}

///|
test "ST_NodeVerticalAlignment rejects one invalid lexical value" {
  try {
    ST_NodeVerticalAlignment::parse("__invalid__") |> ignore
    fail("expected ST_NodeVerticalAlignment rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_FallbackDimension parses and formats one valid lexical value" {
  assert_eq(ST_FallbackDimension::parse("1D").to_string(), "1D")
}

///|
test "ST_FallbackDimension rejects one invalid lexical value" {
  try {
    ST_FallbackDimension::parse("__invalid__") |> ignore
    fail("expected ST_FallbackDimension rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_TextDirection parses and formats one valid lexical value" {
  assert_eq(ST_TextDirection::parse("fromT").to_string(), "fromT")
}

///|
test "ST_TextDirection rejects one invalid lexical value" {
  try {
    ST_TextDirection::parse("__invalid__") |> ignore
    fail("expected ST_TextDirection rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_PyramidAccentPosition parses and formats one valid lexical value" {
  assert_eq(ST_PyramidAccentPosition::parse("bef").to_string(), "bef")
}

///|
test "ST_PyramidAccentPosition rejects one invalid lexical value" {
  try {
    ST_PyramidAccentPosition::parse("__invalid__") |> ignore
    fail("expected ST_PyramidAccentPosition rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_PyramidAccentTextMargin parses and formats one valid lexical value" {
  assert_eq(ST_PyramidAccentTextMargin::parse("step").to_string(), "step")
}

///|
test "ST_PyramidAccentTextMargin rejects one invalid lexical value" {
  try {
    ST_PyramidAccentTextMargin::parse("__invalid__") |> ignore
    fail("expected ST_PyramidAccentTextMargin rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_TextBlockDirection parses and formats one valid lexical value" {
  assert_eq(ST_TextBlockDirection::parse("horz").to_string(), "horz")
}

///|
test "ST_TextBlockDirection rejects one invalid lexical value" {
  try {
    ST_TextBlockDirection::parse("__invalid__") |> ignore
    fail("expected ST_TextBlockDirection rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_TextAnchorHorizontal parses and formats one valid lexical value" {
  assert_eq(ST_TextAnchorHorizontal::parse("none").to_string(), "none")
}

///|
test "ST_TextAnchorHorizontal rejects one invalid lexical value" {
  try {
    ST_TextAnchorHorizontal::parse("__invalid__") |> ignore
    fail("expected ST_TextAnchorHorizontal rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_TextAnchorVertical parses and formats one valid lexical value" {
  assert_eq(ST_TextAnchorVertical::parse("t").to_string(), "t")
}

///|
test "ST_TextAnchorVertical rejects one invalid lexical value" {
  try {
    ST_TextAnchorVertical::parse("__invalid__") |> ignore
    fail("expected ST_TextAnchorVertical rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_DiagramTextAlignment parses and formats one valid lexical value" {
  assert_eq(ST_DiagramTextAlignment::parse("l").to_string(), "l")
}

///|
test "ST_DiagramTextAlignment rejects one invalid lexical value" {
  try {
    ST_DiagramTextAlignment::parse("__invalid__") |> ignore
    fail("expected ST_DiagramTextAlignment rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_AutoTextRotation parses and formats one valid lexical value" {
  assert_eq(ST_AutoTextRotation::parse("none").to_string(), "none")
}

///|
test "ST_AutoTextRotation rejects one invalid lexical value" {
  try {
    ST_AutoTextRotation::parse("__invalid__") |> ignore
    fail("expected ST_AutoTextRotation rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_GrowDirection parses and formats one valid lexical value" {
  assert_eq(ST_GrowDirection::parse("tL").to_string(), "tL")
}

///|
test "ST_GrowDirection rejects one invalid lexical value" {
  try {
    ST_GrowDirection::parse("__invalid__") |> ignore
    fail("expected ST_GrowDirection rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_FlowDirection parses and formats one valid lexical value" {
  assert_eq(ST_FlowDirection::parse("row").to_string(), "row")
}

///|
test "ST_FlowDirection rejects one invalid lexical value" {
  try {
    ST_FlowDirection::parse("__invalid__") |> ignore
    fail("expected ST_FlowDirection rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_ContinueDirection parses and formats one valid lexical value" {
  assert_eq(ST_ContinueDirection::parse("revDir").to_string(), "revDir")
}

///|
test "ST_ContinueDirection rejects one invalid lexical value" {
  try {
    ST_ContinueDirection::parse("__invalid__") |> ignore
    fail("expected ST_ContinueDirection rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_Breakpoint parses and formats one valid lexical value" {
  assert_eq(ST_Breakpoint::parse("endCnv").to_string(), "endCnv")
}

///|
test "ST_Breakpoint rejects one invalid lexical value" {
  try {
    ST_Breakpoint::parse("__invalid__") |> ignore
    fail("expected ST_Breakpoint rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_Offset parses and formats one valid lexical value" {
  assert_eq(ST_Offset::parse("ctr").to_string(), "ctr")
}

///|
test "ST_Offset rejects one invalid lexical value" {
  try {
    ST_Offset::parse("__invalid__") |> ignore
    fail("expected ST_Offset rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_HierarchyAlignment parses and formats one valid lexical value" {
  assert_eq(ST_HierarchyAlignment::parse("tL").to_string(), "tL")
}

///|
test "ST_HierarchyAlignment rejects one invalid lexical value" {
  try {
    ST_HierarchyAlignment::parse("__invalid__") |> ignore
    fail("expected ST_HierarchyAlignment rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_FunctionValue parses and formats one valid lexical value" {
  assert_eq(ST_FunctionValue::parse("true").to_string(), "true")
}

///|
test "ST_FunctionValue rejects one invalid lexical value" {
  try {
    ST_FunctionValue::parse("") |> ignore
    fail("expected ST_FunctionValue rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_VariableType parses and formats one valid lexical value" {
  assert_eq(ST_VariableType::parse("none").to_string(), "none")
}

///|
test "ST_VariableType rejects one invalid lexical value" {
  try {
    ST_VariableType::parse("__invalid__") |> ignore
    fail("expected ST_VariableType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_FunctionArgument parses and formats one valid lexical value" {
  assert_eq(ST_FunctionArgument::parse("orgChart").to_string(), "orgChart")
}

///|
test "ST_FunctionArgument rejects one invalid lexical value" {
  try {
    ST_FunctionArgument::parse("") |> ignore
    fail("expected ST_FunctionArgument rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}

///|
test "ST_OutputShapeType parses and formats one valid lexical value" {
  assert_eq(ST_OutputShapeType::parse("none").to_string(), "none")
}

///|
test "ST_OutputShapeType rejects one invalid lexical value" {
  try {
    ST_OutputShapeType::parse("__invalid__") |> ignore
    fail("expected ST_OutputShapeType rejection")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
