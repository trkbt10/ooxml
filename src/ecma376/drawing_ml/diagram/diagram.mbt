///|
/// ECMA-376 Part 1 §21.4 DrawingML Diagram / SmartArt.
/// Top-level elements: colorsDef, colorsDefHdr, colorsDefHdrLst, dataModel, layoutDef, layoutDefHdr, layoutDefHdrLst, relIds, styleDef, styleDefHdr, styleDefHdrLst.
/// XSD attribute group AG_IteratorAttributes: Schema dml-diagram.xsd attribute
/// group `AG_IteratorAttributes` has attributes `axis`, `ptType`,
/// `hideLastTrans`, `st`, `cnt`, and `step`; AG_IteratorAttributes,
/// AG_IteratorAttributes::empty, and new_ag_iterator_attributes own those
/// iterator traversal settings in this package.
/// Complex types: CT_CTName, CT_CTDescription, CT_CTCategory, CT_CTCategories, CT_Colors, CT_CTStyleLabel, CT_ColorTransform, CT_ColorTransformHeader, CT_ColorTransformHeaderLst, CT_Pt, CT_PtList, CT_Cxn, CT_CxnList, CT_DataModel, CT_Constraint, CT_Constraints, CT_NumericRule, CT_Rules, CT_PresentationOf, CT_Adj, CT_AdjLst, CT_Shape, CT_Parameter, CT_Algorithm, CT_LayoutNode, CT_ForEach, CT_When, CT_Otherwise, CT_Choose, CT_SampleData, CT_Category, CT_Categories, CT_Name, CT_Description, CT_DiagramDefinition, CT_DiagramDefinitionHeader, CT_DiagramDefinitionHeaderLst, CT_RelIds, CT_ElemPropSet, CT_OrgChart, CT_ChildMax, CT_ChildPref, CT_BulletEnabled, CT_Direction, CT_HierBranchStyle, CT_AnimOne, CT_AnimLvl, CT_ResizeHandles, CT_LayoutVariablePropertySet, CT_SDName, CT_SDDescription, CT_SDCategory, CT_SDCategories, CT_TextProps, CT_StyleLabel, CT_StyleDefinition, CT_StyleDefinitionHeader, CT_StyleDefinitionHeaderLst.
/// Simple types: ST_ClrAppMethod, ST_HueDir, ST_PtType, ST_CxnType, ST_LayoutShapeType, ST_Index1, ST_ParameterVal, ST_ModelId, ST_PrSetCustVal, ST_Direction, ST_HierBranchStyle, ST_AnimOneStr, ST_AnimLvlStr, ST_NodeCount, ST_ResizeHandlesStr, ST_AlgorithmType, ST_AxisType, ST_AxisTypes, ST_BoolOperator, ST_ChildOrderType, ST_ConstraintType, ST_ConstraintRelationship, ST_ElementType, ST_ElementTypes, ST_ParameterId, ST_Ints, ST_UnsignedInts, ST_Booleans, ST_FunctionType, ST_FunctionOperator, ST_DiagramHorizontalAlignment, ST_VerticalAlignment, ST_ChildDirection, ST_ChildAlignment, ST_SecondaryChildAlignment, ST_LinearDirection, ST_SecondaryLinearDirection, ST_StartingElement, ST_RotationPath, ST_CenterShapeMapping, ST_BendPoint, ST_ConnectorRouting, ST_ArrowheadStyle, ST_ConnectorDimension, ST_ConnectorPoint, ST_NodeHorizontalAlignment, ST_NodeVerticalAlignment, ST_FallbackDimension, ST_TextDirection, ST_PyramidAccentPosition, ST_PyramidAccentTextMargin, ST_TextBlockDirection, ST_TextAnchorHorizontal, ST_TextAnchorVertical, ST_DiagramTextAlignment, ST_AutoTextRotation, ST_GrowDirection, ST_FlowDirection, ST_ContinueDirection, ST_Breakpoint, ST_Offset, ST_HierarchyAlignment, ST_FunctionValue, ST_VariableType, ST_FunctionArgument, ST_OutputShapeType.
/// Attribute groups: iterator attributes, AG_ConstraintAttributes, AG_ConstraintRefAttributes.
/// §11 Errors: this package raises SchemaViolation for §4 XSD violations;
/// ResourceMissing is propagated from the OPC layer (`src/ecma376/opc`) when
/// a relationship target referenced by a SmartArt part cannot be resolved.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/diagram"
}

///|
/// ECMA-376 Part 1 §21.4 Drawingml Diagrams
pub fn diagram_part1_21_4_drawingml_diagrams_section_name() -> String {
  "ECMA-376 Part 1 §21.4 Drawingml Diagrams"
}

///|
/// ECMA-376 Part 4 §12.2.3 Diagram Colors Part Part 1 14 2 3
pub fn diagram_part4_12_2_3_diagram_colors_part_part_1_14_2_3_section_name() -> String {
  "ECMA-376 Part 4 §12.2.3 Diagram Colors Part Part 1 14 2 3"
}
