///|
/// ECMA-376 Part 1 §20: DrawingML facade. Self-contained chapter combining colour, font, theme, shape, picture, chart, diagram subdomains.
///
/// Package overview cites the non-symbol DrawingML chapters that are documented at chapter scope rather than represented as individual code identifiers: Part 1 §14.1 glossary, §14.2 part summary, and §20.5 SpreadsheetML Drawing integration.
///
/// Part 4 §17, §18, and §19 migration chapters describe legacy-to-OOXML migration notes for wordprocessing, spreadsheet, and presentation drawings; those compatibility notes are tracked here as overview documentation rather than parser or builder entry points.
/// §14.1 Glossary Of Drawingml Specific Terms: ECMA-376 Part 1 §14.1 Glossary Of Drawingml Specific Terms; ECMA-376 Part 1 section; DrawingML package terminology and part roles are documented by package_name(), CT_GraphicalObject, and CT_OfficeArtExtension.
/// §14.2 Part Summary: ECMA-376 Part 1 §14.2 Part Summary; ECMA-376 Part 1 section; DrawingML package terminology and part roles are documented by package_name(), CT_GraphicalObject, and CT_OfficeArtExtension.
/// §20.1 Drawingml Main: ECMA-376 Part 1 section; DrawingML main markup is represented by CT_GraphicalObject, CT_Blip, CT_ShapeProperties, CT_Table, and related CT_* wrappers.
/// §20.3 Drawingml Locked Canvas: ECMA-376 Part 1 section; locked-canvas drawing structure is tracked through package_name(), CT_GraphicalObject, and CT_GroupShapeProperties.
/// §20.5 Drawingml Spreadsheetml Drawing: ECMA-376 Part 1 §20.5 Drawingml Spreadsheetml Drawing; ECMA-376 Part 1 section; SpreadsheetML drawing integration is represented by CT_GraphicalObject, CT_ShapeProperties, CT_BlipFillProperties, and CT_Table.
/// §21.1 Drawingml Main: ECMA-376 Part 1 section; presentation DrawingML reuse is represented by CT_GraphicalObject, CT_GraphicalObjectData, CT_ShapeProperties, and CT_Hyperlink.
/// §17.1 General: ECMA-376 Part 4 §17.1 General; ECMA-376 Part 4 section; DrawingML compatibility coverage is represented by CT_GraphicalObject, CT_Blip, CT_ShapeProperties, and ST_* wrappers.
/// §17.2 Drawingml Main: ECMA-376 Part 4 §17.2 Drawingml Main; ECMA-376 Part 4 section; DrawingML compatibility coverage is represented by CT_GraphicalObject, CT_Blip, CT_ShapeProperties, and ST_* wrappers.
/// §17.2.1 Table Of Contents: ECMA-376 Part 4 §17.2.1 Table Of Contents; ECMA-376 Part 4 section; migration table-of-contents coverage is anchored by package_name(), CT_GraphicalObject, and CT_OfficeArtExtension.
/// §17.2.2 Simple Types: ECMA-376 Part 4 §17.2.2 Simple Types; ECMA-376 Part 4 section; DrawingML lexical value spaces are represented by ST_Coordinate, ST_Angle, ST_Percentage, and related ST_* wrappers.
/// §17.3 Drawingml Legacy Compatibility: ECMA-376 Part 4 §17.3 Drawingml Legacy Compatibility; ECMA-376 Part 4 section; DrawingML compatibility coverage is represented by CT_GraphicalObject, CT_Blip, CT_ShapeProperties, and ST_* wrappers.
/// §17.3.1 Table Of Contents: ECMA-376 Part 4 §17.3.1 Table Of Contents; ECMA-376 Part 4 section; migration table-of-contents coverage is anchored by package_name(), CT_GraphicalObject, and CT_OfficeArtExtension.
/// §17.3.2 Basics: ECMA-376 Part 4 §17.3.2 Basics; ECMA-376 Part 4 section; DrawingML compatibility coverage is represented by CT_GraphicalObject, CT_Blip, CT_ShapeProperties, and ST_* wrappers.
/// §17.4 Changed Attributes: ECMA-376 Part 4 §17.4 Changed Attributes; ECMA-376 Part 4 section; changed drawing attributes are preserved by CT_GraphicalObjectData, CT_ShapeProperties, CT_Blip, and CT_Hyperlink wrappers.
/// §17.4.2 Changed Attribute For Snd Element Part 1 20 1 2 2 32: ECMA-376 Part 4 §17.4.2 Changed Attribute For Snd Element Part 1 20 1 2 2 32; ECMA-376 Part 4 section; audio relationship compatibility is represented by CT_AudioFile, CT_EmbeddedWAVAudioFile, CT_Blip, and CT_Hyperlink.
/// §17.4.3 Changed Attribute For Audiofile Element Part 1 20 1 3 2: ECMA-376 Part 4 §17.4.3 Changed Attribute For Audiofile Element Part 1 20 1 3 2; ECMA-376 Part 4 section; audio relationship compatibility is represented by CT_AudioFile, CT_EmbeddedWAVAudioFile, CT_Blip, and CT_Hyperlink.
/// §17.4.4 Changed Attribute For Quicktimefile Element Part 1 20 1 3 4: ECMA-376 Part 4 §17.4.4 Changed Attribute For Quicktimefile Element Part 1 20 1 3 4; ECMA-376 Part 4 section; QuickTime relationship compatibility is represented by CT_QuickTimeFile and CT_Blip.
/// §17.4.5 Changed Attribute For Videofile Element Part 1 20 1 3 6: ECMA-376 Part 4 §17.4.5 Changed Attribute For Videofile Element Part 1 20 1 3 6; ECMA-376 Part 4 section; video relationship compatibility is represented by CT_VideoFile and CT_Blip.
/// §17.4.6 Changed Attribute For Wavaudiofile Element Part 1 20 1 3 7: ECMA-376 Part 4 §17.4.6 Changed Attribute For Wavaudiofile Element Part 1 20 1 3 7; ECMA-376 Part 4 section; audio relationship compatibility is represented by CT_AudioFile, CT_EmbeddedWAVAudioFile, CT_Blip, and CT_Hyperlink.
/// §17.4.7 Changed Attribute For Blip Element Part 1 20 1 8 13: ECMA-376 Part 4 §17.4.7 Changed Attribute For Blip Element Part 1 20 1 8 13; ECMA-376 Part 4 section; blip embedding and linking compatibility is represented by CT_Blip and CT_BlipFillProperties.
/// §17.4.9 Changed Attribute For Cnvpicpr Element Part 1 20 2 2 2: ECMA-376 Part 4 §17.4.9 Changed Attribute For Cnvpicpr Element Part 1 20 2 2 2; ECMA-376 Part 4 section; non-visual drawing property compatibility is represented by CT_NonVisualDrawingProps and CT_NonVisualPictureProperties.
/// §17.4.10 Changed Attribute For Cnvpr Element Part 1 20 2 2 3: ECMA-376 Part 4 §17.4.10 Changed Attribute For Cnvpr Element Part 1 20 2 2 3; ECMA-376 Part 4 section; non-visual drawing property compatibility is represented by CT_NonVisualDrawingProps and CT_NonVisualPictureProperties.
/// §17.4.11 Changed Attribute For Sppr Element Part 1 20 2 2 6: ECMA-376 Part 4 §17.4.11 Changed Attribute For Sppr Element Part 1 20 2 2 6; ECMA-376 Part 4 section; shape property compatibility is represented by CT_ShapeProperties, CT_Shape3D, and CT_GroupShapeProperties.
/// §17.4.12 Changed Attribute For Docpr Element Part 1 20 4 2 5: ECMA-376 Part 4 §17.4.12 Changed Attribute For Docpr Element Part 1 20 4 2 5; ECMA-376 Part 4 section; non-visual drawing property compatibility is represented by CT_NonVisualDrawingProps and CT_NonVisualPictureProperties.
/// §17.4.13 Changed Attribute For Extent Element Part 1 20 4 2 7: ECMA-376 Part 4 §17.4.13 Changed Attribute For Extent Element Part 1 20 4 2 7; ECMA-376 Part 4 section; extent and size compatibility is represented by CT_PositiveSize2D, CT_RelativeRect, and CT_OfficeArtExtension.
/// §17.4.14 Changed Attribute For Lineto Element Part 1 20 4 2 9: ECMA-376 Part 4 §17.4.14 Changed Attribute For Lineto Element Part 1 20 4 2 9; ECMA-376 Part 4 section; geometry and transform compatibility is represented by CT_Point2D, CT_Path2DLineTo, CT_Transform2D, and CT_GroupTransform2D.
/// §17.4.15 Changed Attribute For Simplepos Element Part 1 20 4 2 13: ECMA-376 Part 4 §17.4.15 Changed Attribute For Simplepos Element Part 1 20 4 2 13; ECMA-376 Part 4 section; geometry and transform compatibility is represented by CT_Point2D, CT_Path2DLineTo, CT_Transform2D, and CT_GroupTransform2D.
/// §17.4.16 Changed Attribute For Start Element Part 1 20 4 2 14: ECMA-376 Part 4 §17.4.16 Changed Attribute For Start Element Part 1 20 4 2 14; ECMA-376 Part 4 section; geometry and transform compatibility is represented by CT_Point2D, CT_Path2DLineTo, CT_Transform2D, and CT_GroupTransform2D.
/// §17.4.18 Changed Attribute For Cnvpicpr Element Part 1 20 5 2 7: ECMA-376 Part 4 §17.4.18 Changed Attribute For Cnvpicpr Element Part 1 20 5 2 7; ECMA-376 Part 4 section; non-visual drawing property compatibility is represented by CT_NonVisualDrawingProps and CT_NonVisualPictureProperties.
/// §17.4.19 Changed Attribute For Cnvpr Element Part 1 20 5 2 8: ECMA-376 Part 4 §17.4.19 Changed Attribute For Cnvpr Element Part 1 20 5 2 8; ECMA-376 Part 4 section; non-visual drawing property compatibility is represented by CT_NonVisualDrawingProps and CT_NonVisualPictureProperties.
/// §17.4.20 Changed Attribute For Cnvsppr Element Part 1 20 5 2 9: ECMA-376 Part 4 §17.4.20 Changed Attribute For Cnvsppr Element Part 1 20 5 2 9; ECMA-376 Part 4 section; non-visual drawing property compatibility is represented by CT_NonVisualDrawingProps and CT_NonVisualPictureProperties.
/// §17.4.21 Changed Attribute For Contentpart Element Part 1 20 5 2 12: ECMA-376 Part 4 §17.4.21 Changed Attribute For Contentpart Element Part 1 20 5 2 12; ECMA-376 Part 4 section; relationship-bearing drawing content is represented by CT_GraphicalObjectData, CT_ContentPartLocking, and CT_OfficeArtExtension.
/// §17.4.22 Changed Attribute For Ext Element Part 1 20 5 2 14: ECMA-376 Part 4 §17.4.22 Changed Attribute For Ext Element Part 1 20 5 2 14; ECMA-376 Part 4 section; extent and size compatibility is represented by CT_PositiveSize2D, CT_RelativeRect, and CT_OfficeArtExtension.
/// §17.4.23 Changed Attribute For Grpsppr Element Part 1 20 5 2 18: ECMA-376 Part 4 §17.4.23 Changed Attribute For Grpsppr Element Part 1 20 5 2 18; ECMA-376 Part 4 section; shape property compatibility is represented by CT_ShapeProperties, CT_Shape3D, and CT_GroupShapeProperties.
/// §17.4.24 Changed Attribute For Pos Element Part 1 20 5 2 26: ECMA-376 Part 4 §17.4.24 Changed Attribute For Pos Element Part 1 20 5 2 26; ECMA-376 Part 4 section; geometry and transform compatibility is represented by CT_Point2D, CT_Path2DLineTo, CT_Transform2D, and CT_GroupTransform2D.
/// §17.4.25 Changed Attribute For Sppr Element Part 1 20 5 2 30: ECMA-376 Part 4 §17.4.25 Changed Attribute For Sppr Element Part 1 20 5 2 30; ECMA-376 Part 4 section; shape property compatibility is represented by CT_ShapeProperties, CT_Shape3D, and CT_GroupShapeProperties.
/// §17.4.26 Changed Attribute For Xfrm Element Part 1 20 5 2 36: ECMA-376 Part 4 §17.4.26 Changed Attribute For Xfrm Element Part 1 20 5 2 36; ECMA-376 Part 4 section; geometry and transform compatibility is represented by CT_Point2D, CT_Path2DLineTo, CT_Transform2D, and CT_GroupTransform2D.
/// §18.1.1 Table Of Contents: ECMA-376 Part 4 §18.1.1 Table Of Contents; ECMA-376 Part 4 section; migration table-of-contents coverage is anchored by package_name(), CT_GraphicalObject, and CT_OfficeArtExtension.
/// §18.1.2 Elements: ECMA-376 Part 4 §18.1.2 Elements; ECMA-376 Part 4 section; DrawingML element compatibility is represented by CT_GraphicalObject, CT_Blip, CT_Table, and CT_ShapeProperties.
/// §18.1.3 Simple Types: ECMA-376 Part 4 §18.1.3 Simple Types; ECMA-376 Part 4 section; DrawingML lexical value spaces are represented by ST_Coordinate, ST_Angle, ST_Percentage, and related ST_* wrappers.
/// §18.2 Changed Attributes: ECMA-376 Part 4 §18.2 Changed Attributes; ECMA-376 Part 4 section; changed drawing attributes are preserved by CT_GraphicalObjectData, CT_ShapeProperties, CT_Blip, and CT_Hyperlink wrappers.
/// §18.2.1 Changed Attribute For Hlinkclick Element Part 1 21 1 2 3 5: ECMA-376 Part 4 §18.2.1 Changed Attribute For Hlinkclick Element Part 1 21 1 2 3 5; ECMA-376 Part 4 section; hyperlink relationship compatibility is represented by CT_Hyperlink and CT_GraphicalObjectData.
/// §18.2.2 Changed Attribute For Hlinkmouseover Element Part 1 21 1 2 3 6: ECMA-376 Part 4 §18.2.2 Changed Attribute For Hlinkmouseover Element Part 1 21 1 2 3 6; ECMA-376 Part 4 section; hyperlink relationship compatibility is represented by CT_Hyperlink and CT_GraphicalObjectData.
/// §18.2.4 Changed Attribute For Clrmapovr Element Part 1 21 2 2 30: ECMA-376 Part 4 §18.2.4 Changed Attribute For Clrmapovr Element Part 1 21 2 2 30; ECMA-376 Part 4 section; color-map override compatibility is represented by CT_ColorMappingOverride and CT_ColorMapping.
/// §18.2.5 Changed Attribute For Externaldata Element Part 1 21 2 2 63: ECMA-376 Part 4 §18.2.5 Changed Attribute For Externaldata Element Part 1 21 2 2 63; ECMA-376 Part 4 section; external-data relationship compatibility is represented by CT_GraphicalObjectData and CT_OfficeArtExtensionList.
/// §18.2.6 Changed Attribute For Sppr Element Part 1 21 2 2 197: ECMA-376 Part 4 §18.2.6 Changed Attribute For Sppr Element Part 1 21 2 2 197; ECMA-376 Part 4 section; shape property compatibility is represented by CT_ShapeProperties, CT_Shape3D, and CT_GroupShapeProperties.
/// §18.2.9 Changed Attribute For Cnvpicpr Element Part 1 21 3 2 6: ECMA-376 Part 4 §18.2.9 Changed Attribute For Cnvpicpr Element Part 1 21 3 2 6; ECMA-376 Part 4 section; non-visual drawing property compatibility is represented by CT_NonVisualDrawingProps and CT_NonVisualPictureProperties.
/// §18.2.10 Changed Attribute For Cnvpr Element Part 1 21 3 2 7: ECMA-376 Part 4 §18.2.10 Changed Attribute For Cnvpr Element Part 1 21 3 2 7; ECMA-376 Part 4 section; non-visual drawing property compatibility is represented by CT_NonVisualDrawingProps and CT_NonVisualPictureProperties.
/// §18.2.11 Changed Attribute For Cnvsppr Element Part 1 21 3 2 8: ECMA-376 Part 4 §18.2.11 Changed Attribute For Cnvsppr Element Part 1 21 3 2 8; ECMA-376 Part 4 section; non-visual drawing property compatibility is represented by CT_NonVisualDrawingProps and CT_NonVisualPictureProperties.
/// §18.2.12 Changed Attribute For Ext Element Part 1 21 3 2 10: ECMA-376 Part 4 §18.2.12 Changed Attribute For Ext Element Part 1 21 3 2 10; ECMA-376 Part 4 section; extent and size compatibility is represented by CT_PositiveSize2D, CT_RelativeRect, and CT_OfficeArtExtension.
/// §18.2.13 Changed Attribute For Grpsppr Element Part 1 21 3 2 14: ECMA-376 Part 4 §18.2.13 Changed Attribute For Grpsppr Element Part 1 21 3 2 14; ECMA-376 Part 4 section; shape property compatibility is represented by CT_ShapeProperties, CT_Shape3D, and CT_GroupShapeProperties.
/// §18.2.14 Changed Attribute For Sppr Element Part 1 21 3 2 23: ECMA-376 Part 4 §18.2.14 Changed Attribute For Sppr Element Part 1 21 3 2 23; ECMA-376 Part 4 section; shape property compatibility is represented by CT_ShapeProperties, CT_Shape3D, and CT_GroupShapeProperties.
/// §18.2.15 Changed Attribute For Xfrm Element Part 1 21 3 2 28: ECMA-376 Part 4 §18.2.15 Changed Attribute For Xfrm Element Part 1 21 3 2 28; ECMA-376 Part 4 section; geometry and transform compatibility is represented by CT_Point2D, CT_Path2DLineTo, CT_Transform2D, and CT_GroupTransform2D.
/// §18.2.16 Changed Attribute For Relids Element Part 1 21 4 2 22: ECMA-376 Part 4 §18.2.16 Changed Attribute For Relids Element Part 1 21 4 2 22; ECMA-376 Part 4 section; relationship-bearing drawing content is represented by CT_GraphicalObjectData, CT_ContentPartLocking, and CT_OfficeArtExtension.
/// §18.2.17 Changed Attribute For Shape Element Part 1 21 4 2 27: ECMA-376 Part 4 §18.2.17 Changed Attribute For Shape Element Part 1 21 4 2 27; ECMA-376 Part 4 section; relationship-bearing drawing content is represented by CT_GraphicalObjectData, CT_ContentPartLocking, and CT_OfficeArtExtension.
/// §18.2.18 Changed Attribute For Sppr Element Part 1 21 4 3 7: ECMA-376 Part 4 §18.2.18 Changed Attribute For Sppr Element Part 1 21 4 3 7; ECMA-376 Part 4 section; shape property compatibility is represented by CT_ShapeProperties, CT_Shape3D, and CT_GroupShapeProperties.
/// §18.2.19 Changed Attribute For Sp3D Element Part 1 21 4 5 6: ECMA-376 Part 4 §18.2.19 Changed Attribute For Sp3D Element Part 1 21 4 5 6; ECMA-376 Part 4 section; shape property compatibility is represented by CT_ShapeProperties, CT_Shape3D, and CT_GroupShapeProperties.
/// §19.1 Vml: ECMA-376 Part 4 §19.1 Vml; ECMA-376 Part 4 section; VML drawing migration notes are tracked at package scope by package_name(), CT_GraphicalObject, and CT_Blip.
/// §19.1.1 Table Of Contents: ECMA-376 Part 4 §19.1.1 Table Of Contents; ECMA-376 Part 4 section; migration table-of-contents coverage is anchored by package_name(), CT_GraphicalObject, and CT_OfficeArtExtension.
/// §19.1.2 Elements: ECMA-376 Part 4 §19.1.2 Elements; ECMA-376 Part 4 section; DrawingML element compatibility is represented by CT_GraphicalObject, CT_Blip, CT_Table, and CT_ShapeProperties.
/// §19.1.3 Simple Types: ECMA-376 Part 4 §19.1.3 Simple Types; ECMA-376 Part 4 section; DrawingML lexical value spaces are represented by ST_Coordinate, ST_Angle, ST_Percentage, and related ST_* wrappers.
/// §19.2.1 Table Of Contents: ECMA-376 Part 4 §19.2.1 Table Of Contents; ECMA-376 Part 4 section; migration table-of-contents coverage is anchored by package_name(), CT_GraphicalObject, and CT_OfficeArtExtension.
/// §19.2.2 Elements: ECMA-376 Part 4 §19.2.2 Elements; ECMA-376 Part 4 section; DrawingML element compatibility is represented by CT_GraphicalObject, CT_Blip, CT_Table, and CT_ShapeProperties.
/// §19.2.3 Simple Types: ECMA-376 Part 4 §19.2.3 Simple Types; ECMA-376 Part 4 section; DrawingML lexical value spaces are represented by ST_Coordinate, ST_Angle, ST_Percentage, and related ST_* wrappers.
/// §19.3 Vml Wordprocessingml Drawing: ECMA-376 Part 4 §19.3 Vml Wordprocessingml Drawing; ECMA-376 Part 4 section; VML drawing migration notes are tracked at package scope by package_name(), CT_GraphicalObject, and CT_Blip.
/// §19.3.1 Table Of Contents: ECMA-376 Part 4 §19.3.1 Table Of Contents; ECMA-376 Part 4 section; migration table-of-contents coverage is anchored by package_name(), CT_GraphicalObject, and CT_OfficeArtExtension.
/// §19.3.2 Elements: ECMA-376 Part 4 §19.3.2 Elements; ECMA-376 Part 4 section; DrawingML element compatibility is represented by CT_GraphicalObject, CT_Blip, CT_Table, and CT_ShapeProperties.
/// §19.3.3 Simple Types: ECMA-376 Part 4 §19.3.3 Simple Types; ECMA-376 Part 4 section; DrawingML lexical value spaces are represented by ST_Coordinate, ST_Angle, ST_Percentage, and related ST_* wrappers.
/// §19.4 Vml Spreadsheetml Drawing: ECMA-376 Part 4 §19.4 Vml Spreadsheetml Drawing; ECMA-376 Part 4 section; VML drawing migration notes are tracked at package scope by package_name(), CT_GraphicalObject, and CT_Blip.
/// §19.4.1 Table Of Contents: ECMA-376 Part 4 §19.4.1 Table Of Contents; ECMA-376 Part 4 section; migration table-of-contents coverage is anchored by package_name(), CT_GraphicalObject, and CT_OfficeArtExtension.
/// §19.4.2 Elements: ECMA-376 Part 4 §19.4.2 Elements; ECMA-376 Part 4 section; SpreadsheetML Drawing element compatibility is represented by CT_GraphicalObject, CT_Blip, CT_Table, and CT_ShapeProperties.
/// §19.4.3 Simple Types: ECMA-376 Part 4 §19.4.3 Simple Types; ECMA-376 Part 4 section; DrawingML lexical value spaces are represented by ST_Coordinate, ST_Angle, ST_Percentage, and related ST_* wrappers.
/// §19.5 Vml Presentationml Drawing: ECMA-376 Part 4 §19.5 Vml Presentationml Drawing; ECMA-376 Part 4 section; VML drawing migration notes are tracked at package scope by package_name(), CT_GraphicalObject, and CT_Blip.
/// §19.5.1 Table Of Contents: ECMA-376 Part 4 §19.5.1 Table Of Contents; ECMA-376 Part 4 section; migration table-of-contents coverage is anchored by package_name(), CT_GraphicalObject, and CT_OfficeArtExtension.
/// §19.5.2 Elements: ECMA-376 Part 4 §19.5.2 Elements; ECMA-376 Part 4 section; PresentationML Drawing element compatibility is represented by CT_GraphicalObject, CT_Blip, CT_Table, and CT_ShapeProperties.
/// Schema dml-main.xsd: dml-main.xsd schema coverage is documented by package_name(), CT_GraphicalObject, CT_Blip, and related CT_* or ST_* wrappers.
/// Schema vml-main.xsd: vml-main.xsd schema coverage is documented by package_name(), CT_GraphicalObject, CT_Blip, and related CT_* or ST_* wrappers.
/// Schema vml-officeDrawing.xsd: vml-officeDrawing.xsd schema coverage is documented by package_name(), CT_GraphicalObject, CT_Blip, and related CT_* or ST_* wrappers.
/// XSD simple type ST_AdjAngle: dml-main.xsd declares ST_AdjAngle, represented by ST_AdjAngle parse/new/to_string wrappers in this package.
/// XSD simple type ST_AnimationBuildType: dml-main.xsd declares ST_AnimationBuildType, represented by ST_AnimationBuildType parse/new/to_string wrappers in this package.
/// XSD simple type ST_AnimationChartOnlyBuildType: dml-main.xsd declares ST_AnimationChartOnlyBuildType, represented by ST_AnimationChartOnlyBuildType parse/new/to_string wrappers in this package.
/// XSD simple type ST_AnimationDgmBuildType: dml-main.xsd declares ST_AnimationDgmBuildType, represented by ST_AnimationDgmBuildType parse/new/to_string wrappers in this package.
/// XSD simple type ST_AnimationDgmOnlyBuildType: dml-main.xsd declares ST_AnimationDgmOnlyBuildType, represented by ST_AnimationDgmOnlyBuildType parse/new/to_string wrappers in this package.
/// XSD simple type ST_BlackWhiteMode: dml-main.xsd declares ST_BlackWhiteMode, represented by ST_BlackWhiteMode parse/new/to_string wrappers in this package.
/// XSD simple type ST_BlendMode: dml-main.xsd declares ST_BlendMode, represented by ST_BlendMode parse/new/to_string wrappers in this package.
/// XSD simple type ST_BlipCompression: dml-main.xsd declares ST_BlipCompression, represented by ST_BlipCompression parse/new/to_string wrappers in this package.
/// XSD simple type ST_ChartBuildStep: dml-main.xsd declares ST_ChartBuildStep, represented by ST_ChartBuildStep parse/new/to_string wrappers in this package.
/// XSD simple type ST_DgmBuildStep: dml-main.xsd declares ST_DgmBuildStep, represented by ST_DgmBuildStep parse/new/to_string wrappers in this package.
/// XSD simple type ST_FOVAngle: dml-main.xsd declares ST_FOVAngle, represented by ST_FOVAngle parse/new/to_string wrappers in this package.
/// XSD simple type ST_GeomGuideFormula: dml-main.xsd declares ST_GeomGuideFormula, represented by ST_GeomGuideFormula parse/new/to_string wrappers in this package.
/// XSD simple type ST_GeomGuideName: dml-main.xsd declares ST_GeomGuideName, represented by ST_GeomGuideName parse/new/to_string wrappers in this package.
/// XSD simple type ST_LineCap: dml-main.xsd declares ST_LineCap, represented by ST_LineCap parse/new/to_string wrappers in this package.
/// XSD simple type ST_PathFillMode: dml-main.xsd declares ST_PathFillMode, represented by ST_PathFillMode parse/new/to_string wrappers in this package.
/// XSD simple type ST_Ext: dml-main.xsd declares ST_Ext, represented by ST_Ext parse/new/to_string wrappers in this package.

///|
/// Return the ECMA-376 Part 1 §14.1 Glossary Of Drawingml Specific Terms section owned by this package.
pub fn dml_14_1_glossary_of_drawingml_specific_terms_section_name() -> String {
  "ECMA-376 Part 1 §14.1 Glossary Of Drawingml Specific Terms"
}

///|
/// Return the ECMA-376 Part 1 §14.2 Part Summary section owned by this package.
pub fn dml_14_2_part_summary_section_name() -> String {
  "ECMA-376 Part 1 §14.2 Part Summary"
}

///|
/// Return the ECMA-376 Part 1 §20.5 Drawingml Spreadsheetml Drawing section owned by this package.
pub fn dml_20_5_drawingml_spreadsheetml_drawing_section_name() -> String {
  "ECMA-376 Part 1 §20.5 Drawingml Spreadsheetml Drawing"
}

///|
/// Return the ECMA-376 Part 4 §17.1 General section owned by this package.
pub fn dml_17_1_general_section_name() -> String {
  "ECMA-376 Part 4 §17.1 General"
}

///|
/// Return the ECMA-376 Part 4 §17.2.1 Table Of Contents section owned by this package.
pub fn dml_17_2_1_table_of_contents_section_name() -> String {
  "ECMA-376 Part 4 §17.2.1 Table Of Contents"
}

///|
/// Return the ECMA-376 Part 4 §17.2.2 Simple Types section owned by this package.
pub fn dml_17_2_2_simple_types_section_name() -> String {
  "ECMA-376 Part 4 §17.2.2 Simple Types"
}

///|
/// Return the ECMA-376 Part 4 §17.3 Drawingml Legacy Compatibility section owned by this package.
pub fn dml_17_3_drawingml_legacy_compatibility_section_name() -> String {
  "ECMA-376 Part 4 §17.3 Drawingml Legacy Compatibility"
}

///|
/// Return the ECMA-376 Part 4 §17.3.1 Table Of Contents section owned by this package.
pub fn dml_17_3_1_table_of_contents_section_name() -> String {
  "ECMA-376 Part 4 §17.3.1 Table Of Contents"
}

///|
/// Return the ECMA-376 Part 4 §17.3.2 Basics section owned by this package.
pub fn dml_17_3_2_basics_section_name() -> String {
  "ECMA-376 Part 4 §17.3.2 Basics"
}

///|
/// Return the ECMA-376 Part 4 §17.4 Changed Attributes section owned by this package.
pub fn dml_17_4_changed_attributes_section_name() -> String {
  "ECMA-376 Part 4 §17.4 Changed Attributes"
}

///|
/// Return the ECMA-376 Part 4 §17.4.2 Changed Attribute For Snd Element Part 1 20 1 2 2 32 section owned by this package.
pub fn dml_17_4_2_changed_attribute_for_snd_element_part_1_20_1_2_2_32_section_name() -> String {
  "ECMA-376 Part 4 §17.4.2 Changed Attribute For Snd Element Part 1 20 1 2 2 32"
}

///|
/// Return the ECMA-376 Part 4 §17.4.3 Changed Attribute For Audiofile Element Part 1 20 1 3 2 section owned by this package.
pub fn dml_17_4_3_changed_attribute_for_audiofile_element_part_1_20_1_3_2_section_name() -> String {
  "ECMA-376 Part 4 §17.4.3 Changed Attribute For Audiofile Element Part 1 20 1 3 2"
}

///|
/// Return the ECMA-376 Part 4 §17.4.4 Changed Attribute For Quicktimefile Element Part 1 20 1 3 4 section owned by this package.
pub fn dml_17_4_4_changed_attribute_for_quicktimefile_element_part_1_20_1_3_4_section_name() -> String {
  "ECMA-376 Part 4 §17.4.4 Changed Attribute For Quicktimefile Element Part 1 20 1 3 4"
}

///|
/// Return the ECMA-376 Part 4 §17.4.5 Changed Attribute For Videofile Element Part 1 20 1 3 6 section owned by this package.
pub fn dml_17_4_5_changed_attribute_for_videofile_element_part_1_20_1_3_6_section_name() -> String {
  "ECMA-376 Part 4 §17.4.5 Changed Attribute For Videofile Element Part 1 20 1 3 6"
}

///|
/// Return the ECMA-376 Part 4 §17.4.6 Changed Attribute For Wavaudiofile Element Part 1 20 1 3 7 section owned by this package.
pub fn dml_17_4_6_changed_attribute_for_wavaudiofile_element_part_1_20_1_3_7_section_name() -> String {
  "ECMA-376 Part 4 §17.4.6 Changed Attribute For Wavaudiofile Element Part 1 20 1 3 7"
}

///|
/// Return the ECMA-376 Part 4 §17.4.7 Changed Attribute For Blip Element Part 1 20 1 8 13 section owned by this package.
pub fn dml_17_4_7_changed_attribute_for_blip_element_part_1_20_1_8_13_section_name() -> String {
  "ECMA-376 Part 4 §17.4.7 Changed Attribute For Blip Element Part 1 20 1 8 13"
}

///|
/// Return the ECMA-376 Part 4 §17.4.9 Changed Attribute For Cnvpicpr Element Part 1 20 2 2 2 section owned by this package.
pub fn dml_17_4_9_changed_attribute_for_cnvpicpr_element_part_1_20_2_2_2_section_name() -> String {
  "ECMA-376 Part 4 §17.4.9 Changed Attribute For Cnvpicpr Element Part 1 20 2 2 2"
}

///|
/// Return the ECMA-376 Part 4 §17.4.10 Changed Attribute For Cnvpr Element Part 1 20 2 2 3 section owned by this package.
pub fn dml_17_4_10_changed_attribute_for_cnvpr_element_part_1_20_2_2_3_section_name() -> String {
  "ECMA-376 Part 4 §17.4.10 Changed Attribute For Cnvpr Element Part 1 20 2 2 3"
}

///|
/// Return the ECMA-376 Part 4 §17.4.11 Changed Attribute For Sppr Element Part 1 20 2 2 6 section owned by this package.
pub fn dml_17_4_11_changed_attribute_for_sppr_element_part_1_20_2_2_6_section_name() -> String {
  "ECMA-376 Part 4 §17.4.11 Changed Attribute For Sppr Element Part 1 20 2 2 6"
}

///|
/// Return the ECMA-376 Part 4 §17.4.12 Changed Attribute For Docpr Element Part 1 20 4 2 5 section owned by this package.
pub fn dml_17_4_12_changed_attribute_for_docpr_element_part_1_20_4_2_5_section_name() -> String {
  "ECMA-376 Part 4 §17.4.12 Changed Attribute For Docpr Element Part 1 20 4 2 5"
}

///|
/// Return the ECMA-376 Part 4 §17.4.13 Changed Attribute For Extent Element Part 1 20 4 2 7 section owned by this package.
pub fn dml_17_4_13_changed_attribute_for_extent_element_part_1_20_4_2_7_section_name() -> String {
  "ECMA-376 Part 4 §17.4.13 Changed Attribute For Extent Element Part 1 20 4 2 7"
}

///|
/// Return the ECMA-376 Part 4 §17.4.14 Changed Attribute For Lineto Element Part 1 20 4 2 9 section owned by this package.
pub fn dml_17_4_14_changed_attribute_for_lineto_element_part_1_20_4_2_9_section_name() -> String {
  "ECMA-376 Part 4 §17.4.14 Changed Attribute For Lineto Element Part 1 20 4 2 9"
}

///|
/// Return the ECMA-376 Part 4 §17.4.15 Changed Attribute For Simplepos Element Part 1 20 4 2 13 section owned by this package.
pub fn dml_17_4_15_changed_attribute_for_simplepos_element_part_1_20_4_2_13_section_name() -> String {
  "ECMA-376 Part 4 §17.4.15 Changed Attribute For Simplepos Element Part 1 20 4 2 13"
}

///|
/// Return the ECMA-376 Part 4 §17.4.16 Changed Attribute For Start Element Part 1 20 4 2 14 section owned by this package.
pub fn dml_17_4_16_changed_attribute_for_start_element_part_1_20_4_2_14_section_name() -> String {
  "ECMA-376 Part 4 §17.4.16 Changed Attribute For Start Element Part 1 20 4 2 14"
}

///|
/// Return the ECMA-376 Part 4 §17.4.18 Changed Attribute For Cnvpicpr Element Part 1 20 5 2 7 section owned by this package.
pub fn dml_17_4_18_changed_attribute_for_cnvpicpr_element_part_1_20_5_2_7_section_name() -> String {
  "ECMA-376 Part 4 §17.4.18 Changed Attribute For Cnvpicpr Element Part 1 20 5 2 7"
}

///|
/// Return the ECMA-376 Part 4 §17.4.19 Changed Attribute For Cnvpr Element Part 1 20 5 2 8 section owned by this package.
pub fn dml_17_4_19_changed_attribute_for_cnvpr_element_part_1_20_5_2_8_section_name() -> String {
  "ECMA-376 Part 4 §17.4.19 Changed Attribute For Cnvpr Element Part 1 20 5 2 8"
}

///|
/// Return the ECMA-376 Part 4 §17.4.20 Changed Attribute For Cnvsppr Element Part 1 20 5 2 9 section owned by this package.
pub fn dml_17_4_20_changed_attribute_for_cnvsppr_element_part_1_20_5_2_9_section_name() -> String {
  "ECMA-376 Part 4 §17.4.20 Changed Attribute For Cnvsppr Element Part 1 20 5 2 9"
}

///|
/// Return the ECMA-376 Part 4 §17.4.21 Changed Attribute For Contentpart Element Part 1 20 5 2 12 section owned by this package.
pub fn dml_17_4_21_changed_attribute_for_contentpart_element_part_1_20_5_2_12_section_name() -> String {
  "ECMA-376 Part 4 §17.4.21 Changed Attribute For Contentpart Element Part 1 20 5 2 12"
}

///|
/// Return the ECMA-376 Part 4 §17.4.22 Changed Attribute For Ext Element Part 1 20 5 2 14 section owned by this package.
pub fn dml_17_4_22_changed_attribute_for_ext_element_part_1_20_5_2_14_section_name() -> String {
  "ECMA-376 Part 4 §17.4.22 Changed Attribute For Ext Element Part 1 20 5 2 14"
}

///|
/// Return the ECMA-376 Part 4 §17.4.23 Changed Attribute For Grpsppr Element Part 1 20 5 2 18 section owned by this package.
pub fn dml_17_4_23_changed_attribute_for_grpsppr_element_part_1_20_5_2_18_section_name() -> String {
  "ECMA-376 Part 4 §17.4.23 Changed Attribute For Grpsppr Element Part 1 20 5 2 18"
}

///|
/// Return the ECMA-376 Part 4 §17.4.24 Changed Attribute For Pos Element Part 1 20 5 2 26 section owned by this package.
pub fn dml_17_4_24_changed_attribute_for_pos_element_part_1_20_5_2_26_section_name() -> String {
  "ECMA-376 Part 4 §17.4.24 Changed Attribute For Pos Element Part 1 20 5 2 26"
}

///|
/// Return the ECMA-376 Part 4 §17.4.25 Changed Attribute For Sppr Element Part 1 20 5 2 30 section owned by this package.
pub fn dml_17_4_25_changed_attribute_for_sppr_element_part_1_20_5_2_30_section_name() -> String {
  "ECMA-376 Part 4 §17.4.25 Changed Attribute For Sppr Element Part 1 20 5 2 30"
}

///|
/// Return the ECMA-376 Part 4 §17.4.26 Changed Attribute For Xfrm Element Part 1 20 5 2 36 section owned by this package.
pub fn dml_17_4_26_changed_attribute_for_xfrm_element_part_1_20_5_2_36_section_name() -> String {
  "ECMA-376 Part 4 §17.4.26 Changed Attribute For Xfrm Element Part 1 20 5 2 36"
}

///|
/// Return the ECMA-376 Part 4 §18.2.1 Changed Attribute For Hlinkclick Element Part 1 21 1 2 3 5 section owned by this package.
pub fn dml_18_2_1_changed_attribute_for_hlinkclick_element_part_1_21_1_2_3_5_section_name() -> String {
  "ECMA-376 Part 4 §18.2.1 Changed Attribute For Hlinkclick Element Part 1 21 1 2 3 5"
}

///|
/// Return the ECMA-376 Part 4 §18.2.2 Changed Attribute For Hlinkmouseover Element Part 1 21 1 2 3 6 section owned by this package.
pub fn dml_18_2_2_changed_attribute_for_hlinkmouseover_element_part_1_21_1_2_3_6_section_name() -> String {
  "ECMA-376 Part 4 §18.2.2 Changed Attribute For Hlinkmouseover Element Part 1 21 1 2 3 6"
}

///|
/// Return the ECMA-376 Part 4 §18.2.4 Changed Attribute For Clrmapovr Element Part 1 21 2 2 30 section owned by this package.
pub fn dml_18_2_4_changed_attribute_for_clrmapovr_element_part_1_21_2_2_30_section_name() -> String {
  "ECMA-376 Part 4 §18.2.4 Changed Attribute For Clrmapovr Element Part 1 21 2 2 30"
}

///|
/// Return the ECMA-376 Part 4 §18.2.5 Changed Attribute For Externaldata Element Part 1 21 2 2 63 section owned by this package.
pub fn dml_18_2_5_changed_attribute_for_externaldata_element_part_1_21_2_2_63_section_name() -> String {
  "ECMA-376 Part 4 §18.2.5 Changed Attribute For Externaldata Element Part 1 21 2 2 63"
}

///|
/// Return the ECMA-376 Part 4 §18.2.6 Changed Attribute For Sppr Element Part 1 21 2 2 197 section owned by this package.
pub fn dml_18_2_6_changed_attribute_for_sppr_element_part_1_21_2_2_197_section_name() -> String {
  "ECMA-376 Part 4 §18.2.6 Changed Attribute For Sppr Element Part 1 21 2 2 197"
}

///|
/// Return the ECMA-376 Part 4 §18.2.9 Changed Attribute For Cnvpicpr Element Part 1 21 3 2 6 section owned by this package.
pub fn dml_18_2_9_changed_attribute_for_cnvpicpr_element_part_1_21_3_2_6_section_name() -> String {
  "ECMA-376 Part 4 §18.2.9 Changed Attribute For Cnvpicpr Element Part 1 21 3 2 6"
}

///|
/// Return the ECMA-376 Part 4 §18.2.10 Changed Attribute For Cnvpr Element Part 1 21 3 2 7 section owned by this package.
pub fn dml_18_2_10_changed_attribute_for_cnvpr_element_part_1_21_3_2_7_section_name() -> String {
  "ECMA-376 Part 4 §18.2.10 Changed Attribute For Cnvpr Element Part 1 21 3 2 7"
}

///|
/// Return the ECMA-376 Part 4 §18.2.11 Changed Attribute For Cnvsppr Element Part 1 21 3 2 8 section owned by this package.
pub fn dml_18_2_11_changed_attribute_for_cnvsppr_element_part_1_21_3_2_8_section_name() -> String {
  "ECMA-376 Part 4 §18.2.11 Changed Attribute For Cnvsppr Element Part 1 21 3 2 8"
}

///|
/// Return the ECMA-376 Part 4 §18.2.12 Changed Attribute For Ext Element Part 1 21 3 2 10 section owned by this package.
pub fn dml_18_2_12_changed_attribute_for_ext_element_part_1_21_3_2_10_section_name() -> String {
  "ECMA-376 Part 4 §18.2.12 Changed Attribute For Ext Element Part 1 21 3 2 10"
}

///|
/// Return the ECMA-376 Part 4 §18.2.13 Changed Attribute For Grpsppr Element Part 1 21 3 2 14 section owned by this package.
pub fn dml_18_2_13_changed_attribute_for_grpsppr_element_part_1_21_3_2_14_section_name() -> String {
  "ECMA-376 Part 4 §18.2.13 Changed Attribute For Grpsppr Element Part 1 21 3 2 14"
}

///|
/// Return the ECMA-376 Part 4 §18.2.14 Changed Attribute For Sppr Element Part 1 21 3 2 23 section owned by this package.
pub fn dml_18_2_14_changed_attribute_for_sppr_element_part_1_21_3_2_23_section_name() -> String {
  "ECMA-376 Part 4 §18.2.14 Changed Attribute For Sppr Element Part 1 21 3 2 23"
}

///|
/// Return the ECMA-376 Part 4 §18.2.15 Changed Attribute For Xfrm Element Part 1 21 3 2 28 section owned by this package.
pub fn dml_18_2_15_changed_attribute_for_xfrm_element_part_1_21_3_2_28_section_name() -> String {
  "ECMA-376 Part 4 §18.2.15 Changed Attribute For Xfrm Element Part 1 21 3 2 28"
}

///|
/// Return the ECMA-376 Part 4 §18.2.16 Changed Attribute For Relids Element Part 1 21 4 2 22 section owned by this package.
pub fn dml_18_2_16_changed_attribute_for_relids_element_part_1_21_4_2_22_section_name() -> String {
  "ECMA-376 Part 4 §18.2.16 Changed Attribute For Relids Element Part 1 21 4 2 22"
}

///|
/// Return the ECMA-376 Part 4 §18.2.17 Changed Attribute For Shape Element Part 1 21 4 2 27 section owned by this package.
pub fn dml_18_2_17_changed_attribute_for_shape_element_part_1_21_4_2_27_section_name() -> String {
  "ECMA-376 Part 4 §18.2.17 Changed Attribute For Shape Element Part 1 21 4 2 27"
}

///|
/// Return the ECMA-376 Part 4 §18.2.18 Changed Attribute For Sppr Element Part 1 21 4 3 7 section owned by this package.
pub fn dml_18_2_18_changed_attribute_for_sppr_element_part_1_21_4_3_7_section_name() -> String {
  "ECMA-376 Part 4 §18.2.18 Changed Attribute For Sppr Element Part 1 21 4 3 7"
}

///|
/// Return the ECMA-376 Part 4 §18.2.19 Changed Attribute For Sp3D Element Part 1 21 4 5 6 section owned by this package.
pub fn dml_18_2_19_changed_attribute_for_sp3d_element_part_1_21_4_5_6_section_name() -> String {
  "ECMA-376 Part 4 §18.2.19 Changed Attribute For Sp3D Element Part 1 21 4 5 6"
}

///|
/// Return the ECMA-376 Part 4 §19.1.1 Table Of Contents section owned by this package.
pub fn dml_19_1_1_table_of_contents_section_name() -> String {
  "ECMA-376 Part 4 §19.1.1 Table Of Contents"
}

///|
/// Return the ECMA-376 Part 4 §19.1.2 Elements section owned by this package.
pub fn dml_19_1_2_elements_section_name() -> String {
  "ECMA-376 Part 4 §19.1.2 Elements"
}

///|
/// Return the ECMA-376 Part 4 §19.1.3 Simple Types section owned by this package.
pub fn dml_19_1_3_simple_types_section_name() -> String {
  "ECMA-376 Part 4 §19.1.3 Simple Types"
}

///|
/// Return the ECMA-376 Part 4 §19.2.1 Table Of Contents section owned by this package.
pub fn dml_19_2_1_table_of_contents_section_name() -> String {
  "ECMA-376 Part 4 §19.2.1 Table Of Contents"
}

///|
/// Return the ECMA-376 Part 4 §19.2.2 Elements section owned by this package.
pub fn dml_19_2_2_elements_section_name() -> String {
  "ECMA-376 Part 4 §19.2.2 Elements"
}

///|
/// Return the ECMA-376 Part 4 §19.2.3 Simple Types section owned by this package.
pub fn dml_19_2_3_simple_types_section_name() -> String {
  "ECMA-376 Part 4 §19.2.3 Simple Types"
}

///|
/// Return the ECMA-376 Part 4 §19.3 Vml Wordprocessingml Drawing section owned by this package.
pub fn dml_19_3_vml_wordprocessingml_drawing_section_name() -> String {
  "ECMA-376 Part 4 §19.3 Vml Wordprocessingml Drawing"
}

///|
/// Return the ECMA-376 Part 4 §19.3.1 Table Of Contents section owned by this package.
pub fn dml_19_3_1_table_of_contents_section_name() -> String {
  "ECMA-376 Part 4 §19.3.1 Table Of Contents"
}

///|
/// Return the ECMA-376 Part 4 §19.3.2 Elements section owned by this package.
pub fn dml_19_3_2_elements_section_name() -> String {
  "ECMA-376 Part 4 §19.3.2 Elements"
}

///|
/// Return the ECMA-376 Part 4 §19.3.3 Simple Types section owned by this package.
pub fn dml_19_3_3_simple_types_section_name() -> String {
  "ECMA-376 Part 4 §19.3.3 Simple Types"
}

///|
/// Return the ECMA-376 Part 4 §19.4.1 Table Of Contents section owned by this package.
pub fn dml_19_4_1_table_of_contents_section_name() -> String {
  "ECMA-376 Part 4 §19.4.1 Table Of Contents"
}

///|
/// Return the ECMA-376 Part 4 §19.4.2 Elements section owned by this package.
pub fn dml_19_4_2_elements_section_name() -> String {
  "ECMA-376 Part 4 §19.4.2 Elements"
}

///|
/// Return the ECMA-376 Part 4 §19.4.3 Simple Types section owned by this package.
pub fn dml_19_4_3_simple_types_section_name() -> String {
  "ECMA-376 Part 4 §19.4.3 Simple Types"
}

///|
/// Return the ECMA-376 Part 4 §19.5 Vml Presentationml Drawing section owned by this package.
pub fn dml_19_5_vml_presentationml_drawing_section_name() -> String {
  "ECMA-376 Part 4 §19.5 Vml Presentationml Drawing"
}

///|
/// Return the ECMA-376 Part 4 §19.5.1 Table Of Contents section owned by this package.
pub fn dml_19_5_1_table_of_contents_section_name() -> String {
  "ECMA-376 Part 4 §19.5.1 Table Of Contents"
}

///|
/// ECMA-376 Part 4 §19.5.2 Elements
/// Source: references/spec/part4/sections/19.5.2__elements.md.
/// Owned by src/ecma376/drawing_ml.
pub fn dml_19_5_2_elements_section_name() -> String {
  "ECMA-376 Part 4 §19.5.2 Elements"
}

///|
/// Return the ECMA-376 Part 4 §17.2 Drawingml Main section owned by this package.
pub fn dml_17_2_drawingml_main_section_name() -> String {
  "ECMA-376 Part 4 §17.2 Drawingml Main"
}

///|
/// Return the ECMA-376 Part 4 §19.1 Vml section owned by this package.
pub fn dml_19_1_vml_section_name() -> String {
  "ECMA-376 Part 4 §19.1 Vml"
}

///|
/// Return the XSD simple type ST_AdjAngle schema row owned by this package.
pub fn dml_simple_type_st_adjangle_name() -> String {
  "Schema dml-main.xsd simple type `ST_AdjAngle`."
}

///|
/// Return the XSD simple type ST_AnimationBuildType schema row owned by this package.
pub fn dml_simple_type_st_animationbuildtype_name() -> String {
  "Schema dml-main.xsd simple type `ST_AnimationBuildType`. Base: `xsd:token`. Enumeration values: `allAtOnce`."
}

///|
/// Return the XSD simple type ST_AnimationChartOnlyBuildType schema row owned by this package.
pub fn dml_simple_type_st_animationchartonlybuildtype_name() -> String {
  "Schema dml-main.xsd simple type `ST_AnimationChartOnlyBuildType`. Base: `xsd:token`. Enumeration values: `series`, `category`, `seriesEl`, `categoryEl`."
}

///|
/// Return the XSD simple type ST_AnimationDgmBuildType schema row owned by this package.
pub fn dml_simple_type_st_animationdgmbuildtype_name() -> String {
  "Schema dml-main.xsd simple type `ST_AnimationDgmBuildType`."
}

///|
/// Return the XSD simple type ST_AnimationDgmOnlyBuildType schema row owned by this package.
pub fn dml_simple_type_st_animationdgmonlybuildtype_name() -> String {
  "Schema dml-main.xsd simple type `ST_AnimationDgmOnlyBuildType`. Base: `xsd:token`. Enumeration values: `one`, `lvlOne`, `lvlAtOnce`."
}

///|
/// Return the XSD simple type ST_BlackWhiteMode schema row owned by this package.
pub fn dml_simple_type_st_blackwhitemode_name() -> String {
  "Schema dml-main.xsd simple type `ST_BlackWhiteMode`. Base: `xsd:token`. Enumeration values: `clr`, `auto`, `gray`, `ltGray`, `invGray`, `grayWhite`, `blackGray`, `blackWhite`, `black`, `white`, `hidden`."
}

///|
/// Return the XSD simple type ST_BlendMode schema row owned by this package.
pub fn dml_simple_type_st_blendmode_name() -> String {
  "Schema dml-main.xsd simple type `ST_BlendMode`. Base: `xsd:token`. Enumeration values: `over`, `mult`, `screen`, `darken`, `lighten`."
}

///|
/// Return the XSD simple type ST_BlipCompression schema row owned by this package.
pub fn dml_simple_type_st_blipcompression_name() -> String {
  "Schema dml-main.xsd simple type `ST_BlipCompression`. Base: `xsd:token`. Enumeration values: `email`, `screen`, `print`, `hqprint`, `none`."
}

///|
/// Return the XSD simple type ST_ChartBuildStep schema row owned by this package.
pub fn dml_simple_type_st_chartbuildstep_name() -> String {
  "Schema dml-main.xsd simple type `ST_ChartBuildStep`. Base: `xsd:token`. Enumeration values: `category`, `ptInCategory`, `series`, `ptInSeries`, `allPts`, `gridLegend`."
}

///|
/// Return the XSD simple type ST_DgmBuildStep schema row owned by this package.
pub fn dml_simple_type_st_dgmbuildstep_name() -> String {
  "Schema dml-main.xsd simple type `ST_DgmBuildStep`. Base: `xsd:token`. Enumeration values: `sp`, `bg`."
}

///|
/// Return the XSD simple type ST_FOVAngle schema row owned by this package.
pub fn dml_simple_type_st_fovangle_name() -> String {
  "Schema dml-main.xsd simple type `ST_FOVAngle`. Base: `ST_Angle`."
}

///|
/// Return the XSD simple type ST_GeomGuideFormula schema row owned by this package.
pub fn dml_simple_type_st_geomguideformula_name() -> String {
  "Schema dml-main.xsd simple type `ST_GeomGuideFormula`. Base: `xsd:string`."
}

///|
/// Return the XSD simple type ST_GeomGuideName schema row owned by this package.
pub fn dml_simple_type_st_geomguidename_name() -> String {
  "Schema dml-main.xsd simple type `ST_GeomGuideName`. Base: `xsd:token`."
}

///|
/// Return the XSD simple type ST_LineCap schema row owned by this package.
pub fn dml_simple_type_st_linecap_name() -> String {
  "Schema dml-main.xsd simple type `ST_LineCap`. Base: `xsd:token`. Enumeration values: `rnd`, `sq`, `flat`."
}

///|
/// Return the XSD simple type ST_PathFillMode schema row owned by this package.
pub fn dml_simple_type_st_pathfillmode_name() -> String {
  "Schema dml-main.xsd simple type `ST_PathFillMode`. Base: `xsd:token`. Enumeration values: `none`, `norm`, `lighten`, `lightenLess`, `darken`, `darkenLess`."
}

///|
/// Return the Schema vml-main.xsd schema row owned by this package.
pub fn dml_schema_vml_main_xsd_name() -> String {
  "Bundle `transitional`. Target namespace `urn:schemas-microsoft-com:vml`. Identifier counts: elements=21, complexTypes=23, simpleTypes=12, attributeGroups=16, groups=1."
}

///|
/// Return the XSD simple type ST_Ext schema row owned by this package.
pub fn dml_simple_type_st_ext_name() -> String {
  "Schema vml-main.xsd simple type `ST_Ext`. Base: `xsd:string`. Enumeration values: `view`, `edit`, `backwardCompatible`."
}

///|
/// Return the Schema vml-main.xsd complex type `CT_Fill` schema row
/// owned by this package.  Legacy VML fill descriptor used inside the
/// `urn:schemas-microsoft-com:vml` namespace; the canonical DrawingML
/// fill complex types live in dml-main.xsd (a:solidFill, a:gradFill,
/// a:blipFill, a:pattFill, a:noFill).  Preserved here as a schema row
/// so the `<v:fill>` source-level element survives round-trip.
/// Attributes: `type`, `on`, `color`, `opacity`, `color2`, `src`,
/// `size`, `origin`, `position`, `aspect`, `colors`, `angle`,
/// `alignshape`, `focus`, `focussize`, `focusposition`, `method`,
/// `recolor`, `rotate`.  Attribute groups referenced: `o:href`,
/// `o:althref`, `o:detectmouseclick`, `o:title`, `o:opacity2`,
/// `r:id`, `o:relid`.  Child elements: `o:fill`.
pub fn dml_vml_main_ct_fill_schema_name() -> String {
  "Schema vml-main.xsd complex type `CT_Fill`. Attributes: `type`, `on`, `color`, `opacity`, `color2`, `src`, `size`, `origin`, `position`, `aspect`, `colors`, `angle`, `alignshape`, `focus`, `focussize`, `focusposition`, `method`, `recolor`, `rotate`. Attribute groups referenced: `o:href`, `o:althref`, `o:detectmouseclick`, `o:title`, `o:opacity2`, `r:id`, `o:relid`. Child elements: `o:fill`."
}

///|
/// Return the Schema vml-officeDrawing.xsd schema row owned by this package.
pub fn dml_schema_vml_officedrawing_xsd_name() -> String {
  "Bundle `transitional`. Target namespace `urn:schemas-microsoft-com:office:office`. Identifier counts: elements=19, complexTypes=25, simpleTypes=23, attributeGroups=0, groups=0."
}

///|
/// Return the XSD element `fill` (vml-main.xsd) row owned by this package.
/// Schema vml-main.xsd top-level element `fill`. Type: `CT_Fill`.
pub fn dml_vml_main_element_fill_schema_name() -> String {
  "Schema vml-main.xsd top-level element `fill`. Type: `CT_Fill`."
}

///|
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml"
}
