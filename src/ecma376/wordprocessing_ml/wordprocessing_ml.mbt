///|
/// ECMA-376 Part 1 §17: WordprocessingML facade. Drives reader -> context -> (builder | viewer).
///
/// §3 Specification Sections: this overview maps the package to ECMA-376 Part 1 §11/§17 and Part 4 §14 through CT_Document, CT_Settings, CT_P, CT_R, CT_Tbl, CT_FontsList, CT_Numbering, CT_Comments, and the related ST_* and EG_* wrappers.
/// §11.2 Package Structure: Wordprocessing package parts are surfaced by CT_Document, CT_Body, CT_Settings, CT_FontsList, CT_Numbering, CT_Comments, CT_HdrFtr, and their parse/to_element methods.
/// §11.3 Part Summary: document, settings, styles, numbering, comments, font table, and header/footer parts are represented by CT_Document, CT_Settings, CT_Style, CT_Numbering, CT_Comments, CT_FontsList, and CT_HdrFtr.
/// §11.4 Document Template: attached template relationships and save-through-XSLT settings are represented by CT_Settings and CT_SaveThroughXslt.
/// §11.5 Framesets: HTML frameset settings are represented by CT_Frameset, CT_Frame, CT_FrameLayout, CT_FramesetSplitbar, and CT_FrameScrollbar.
/// §11.6 Master Documents And Subdocuments: master-document subdocument references are preserved through CT_R, CT_P, EG_BlockLevelChunkElts, and altChunk/subDoc markup round-trips.
/// §11.9 Xsl Transformation: save-through-XSLT settings are represented by CT_SaveThroughXslt inside CT_Settings.
/// §17.1 Table Of Contents: field-based tables of contents are represented by CT_SimpleField, CT_FldChar, CT_FFData, CT_Hyperlink, and run-level field content in CT_R.
/// §17.3 Paragraphs And Rich Formatting: paragraphs, runs, properties, and rich inline content are represented by CT_P, CT_R, CT_PPr, EG_PContent, EG_RPr, and CT_Fonts.
/// §17.5 Custom Markup: structured document tags and custom XML ranges are represented by CT_SdtPr, CT_SdtBlock, CT_SdtRun, CT_SdtCell, CT_SdtRow, and related content types.
/// §17.8 Fonts: font tables and font attributes are represented by CT_FontsList, CT_Font, CT_FontFamily, CT_Pitch, CT_FontSig, CT_FontRel, and ST_FontFamily.
/// §17.10 Headers And Footers: section header/footer references and part bodies are represented by CT_HdrFtrRef, EG_HdrFtrReferences, and CT_HdrFtr.
/// §17.13 Annotations: comments, bookmarks, move ranges, and revision tracking are represented by CT_Comments, CT_Bookmark, CT_BookmarkRange, CT_TrackChange, CT_TrackChangeRange, and EG_RangeMarkupElements.
/// §17.15 Settings: document and web settings are represented by CT_Settings, CT_WebSettings, CT_Compat, CT_CompatSetting, CT_DocVars, and CT_DocRsids.
/// §17.16 Fields And Hyperlinks: fields, form-field data, and hyperlinks are represented by CT_SimpleField, CT_FldChar, CT_FFData, CT_Hyperlink, and EG_RunInnerContent.
/// §17.17 Miscellaneous Topics: alternate chunks, subdocuments, frames, text boxes, and embedded objects are preserved by CT_P, CT_R, CT_FramePr, EG_BlockLevelChunkElts, and run/block content groups.
/// §17.18 Simple Types: WordprocessingML lexical value spaces are represented by ST_Jc, ST_JcTable, ST_TabJc, ST_BrType, ST_TextScale, ST_FontFamily, ST_FrameLayout, and the other ST_* wrappers.
/// §14.1 General: Part 4 WordprocessingML migration behavior is documented against the existing CT_* and ST_* domain wrappers rather than new parser entry points.
/// §14.2 Table Of Contents: legacy TOC field markup is represented by CT_SimpleField, CT_FldChar, CT_R, and CT_P.
/// §14.3 Paragraphs And Rich Formatting: legacy paragraph and run formatting is represented by CT_PPr, CT_PPrBase, CT_R, CT_Fonts, CT_Ind, CT_Border, and CT_Shd.
/// §14.3.1 Paragraphs: paragraph compatibility content is represented by CT_P, CT_PPr, CT_PPrBase, CT_PPrGeneral, and EG_PContent.
/// §14.3.1.1 Additional Attribute For Cnfstyle Element Part 1 17 3 1 8: paragraph conditional-format attributes are represented by CT_Cnf and ST_Cnf.
/// §14.3.1.2 Additional Attributes For Ind Element Part 1 17 3 1 12: paragraph indentation compatibility attributes are represented by CT_Ind.
/// §14.4 Tables: table compatibility content is represented by CT_Tbl, CT_TblPr, CT_TblPrBase, CT_TblGrid, CT_Row, CT_Cnf, and CT_TblLook.
/// §14.4.1 Left Table Cell Leading Edge Border: leading cell-border compatibility is represented by CT_TblBorders and CT_Border.
/// §14.4.2 Left Table Leading Edge Border: leading table-border compatibility is represented by CT_TblBorders and CT_Border.
/// §14.4.3 Left Table Cell Leading Margin Exception: leading cell-margin exceptions are represented by CT_TblCellMar and CT_TblWidth.
/// §14.4.4 Left Table Cell Leading Margin Default: default leading cell margins are represented by CT_TblCellMar and CT_TblWidth.
/// §14.4.5 Right Table Cell Trailing Edge Border: trailing cell-border compatibility is represented by CT_TblBorders and CT_Border.
/// §14.4.6 Right Table Trailing Edge Border: trailing table-border compatibility is represented by CT_TblBorders and CT_Border.
/// §14.4.7 Right Table Cell Trailing Margin Default: default trailing cell margins are represented by CT_TblCellMar and CT_TblWidth.
/// §14.4.8 Right Table Cell Trailing Margin Exception: trailing cell-margin exceptions are represented by CT_TblCellMar and CT_TblWidth.
/// §14.4.9 Additional Attribute For Cnfstyle Element Part 1 17 4 7: table conditional-format attributes are represented by CT_Cnf and ST_Cnf.
/// §14.4.10 Additional Attribute For Cnfstyle Element Part 1 17 4 8: table-row conditional-format attributes are represented by CT_Cnf and ST_Cnf.
/// §14.4.11 Additional Attribute For Tbllook Element Part 1 17 4 54: table-look compatibility attributes are represented by CT_TblLook.
/// §14.4.12 Additional Attribute For Tbllook Element Part 1 17 4 55: table-style look compatibility attributes are represented by CT_TblLook.
/// §14.4.13 Hmerge Horizontally Merged Cell: horizontal cell merge compatibility is represented by CT_Row, CT_Tbl, and cell content groups.
/// §14.5 Fonts: font compatibility markup is represented by CT_FontsList, CT_Font, CT_FontFamily, CT_Pitch, and CT_FontSig.
/// §14.5.1 Elements: font-table elements are represented by CT_FontsList, CT_Font, CT_FontRel, CT_Panose, and CT_FontSig.
/// §14.5.1.1 Additional Attribute For Charset Element Part 1 17 8 3 2: charset compatibility attributes are represented by CT_Font and CT_FontSig.
/// §14.6.2 Legacy Legacy Numbering Level Properties: legacy numbering level properties are represented by CT_LvlLegacy, CT_Lvl, CT_Num, and CT_Numbering.
/// §14.7 Annotations: legacy annotation and revision markup is represented by CT_Comments, CT_TrackChange, CT_TrackChangeRange, CT_Bookmark, and EG_RangeMarkupElements.
/// §14.7.1 Revisions: revision-specific compatibility markup is represented by CT_TrackChange, CT_TrackChangesView, CT_TrackChangeRange, CT_PPrChange, CT_TblPrChange, and CT_TblGridChange.
/// §14.8 Settings: document compatibility settings are represented by CT_Settings, CT_Compat, CT_CompatSetting, CT_WebSettings, and CT_SaveThroughXslt.
/// §14.8.2 Document Settings: document-level compatibility settings are represented by CT_Settings, CT_DocVars, CT_DocRsids, CT_WriteProtection, and CT_ColorSchemeMapping.
/// §14.8.2.4 Additional Attribute For Stylepaneformatfilter Element Part 1 17 15 1 85: style-pane format-filter compatibility is represented by CT_Settings and ST_StyleSort.
/// §14.8.3 Compatibility Settings: compatibility flags are represented by CT_Compat and CT_CompatSetting.
/// §14.8.3.1 Aligntablesrowbyrow Align Table Rows Independently: row-by-row table alignment is represented by CT_CompatSetting with CT_Tbl and CT_Row table structures.
/// §14.8.3.2 Allowspaceofsamestyleintable Allow Contextual Spacing Of Paragraphs In Tables: contextual table paragraph spacing is represented by CT_CompatSetting, CT_PPr, and CT_Tbl.
/// §14.8.3.5 Cachedcolbalance Use Cached Paragraph Information For Column Balancing: cached column balancing is represented by CT_CompatSetting and section content in EG_SectPrContents.
/// §14.8.3.6 Convmailmergeesc Treat Backslash Quotation Delimiter As Two Quotation Marks: mail-merge escaping compatibility is represented by CT_CompatSetting and CT_MailMerge.
/// §14.8.3.7 Displayhangulfixedwidth Always Use Fixed Width For Hangul Characters: Hangul width compatibility is represented by CT_CompatSetting and CT_CharacterSpacing.
/// §14.8.3.10 Donotbreakwrappedtables Do Not Allow Floating Tables To Break Across Pages: wrapped table page-break compatibility is represented by CT_CompatSetting, CT_TblPPr, and CT_Tbl.
/// §14.8.3.11 Donotsnaptogridincell Do Not Snap To Document Grid In Table Cells With Objects: table-cell grid snapping compatibility is represented by CT_CompatSetting and CT_Tbl.
/// §14.8.3.13 Donotsuppressparagraphborders Do Not Suppress Paragraph Borders Next To Frames: paragraph-border compatibility near frames is represented by CT_CompatSetting, CT_Border, and CT_FramePr.
/// §14.8.3.19 Donotwraptextwithpunct Do Not Allow Hanging Punctuation With Character Grid: punctuation wrapping compatibility is represented by CT_CompatSetting and CT_PPr.
/// §14.8.3.20 Footnotelayoutlikeww8 Ignore Page Break From Continuous Section Break: footnote layout compatibility is represented by CT_CompatSetting and EG_FtnEdnNumProps.
/// §14.8.3.22 Growautofit Allow Tables To Autofit Into Page Margins: table autofit compatibility is represented by CT_CompatSetting, CT_TblLayoutType, and CT_TblPr.
/// §14.8.3.24 Layouttablerowsapart Allow Table Rows To Wrap Inline Objects Independently: independent row wrapping is represented by CT_CompatSetting, CT_Row, and CT_TblPPr.
/// §14.8.3.25 Linewraplikeword6 Ignore Compression Of Full Width Punctuation Ending A Line: Word 6 line-wrapping compatibility is represented by CT_CompatSetting and CT_PPr.
/// §14.8.3.26 Mwsmallcaps Use Specific Small Caps Algorithm: small-caps compatibility is represented by CT_CompatSetting and EG_RPr.
/// §14.8.3.27 Nocolumnbalance Do Not Balance Text Columns Within A Section: column-balance compatibility is represented by CT_CompatSetting and EG_SectPrContents.
/// §14.8.3.30 Nospaceraiselower Do Not Increase Line Height For Raised Lowered Text: raised/lowered text spacing compatibility is represented by CT_CompatSetting and EG_RPr.
/// §14.8.3.31 Notabhangind Do Not Create Custom Tab Stop For Hanging Indent: hanging-indent tab compatibility is represented by CT_CompatSetting and CT_Ind.
/// §14.8.3.33 Printcolblack Print Colors As Black And White Without Dithering: black-and-white print compatibility is represented by CT_CompatSetting and CT_Settings.
/// §14.8.3.34 Selectfldwithfirstorlastchar Select Field When First Or Last Character Is Select: field selection compatibility is represented by CT_CompatSetting, CT_SimpleField, and CT_FldChar.
/// §14.8.3.35 Shapelayoutlikeww8 Ignore Text Wrapping Around Objects At Bottom Of Page: shape layout compatibility is represented by CT_CompatSetting, CT_Anchor, and EG_WrapType.
/// §14.8.3.36 Showbreaksinframes Display Page Column Breaks Present In Frames: frame break display compatibility is represented by CT_CompatSetting, CT_Frame, and CT_FramePr.
/// §14.8.3.37 Spacinginwholepoints Only Expand Condense Text By Whole Points: whole-point spacing compatibility is represented by CT_CompatSetting and CT_CharacterSpacing.
/// §14.8.3.39 Subfontbysize Require Exact Size During Font Substitution: font substitution compatibility is represented by CT_CompatSetting and CT_FontsList.
/// §14.8.3.42 Suppressspbfafterpgbrk Do Not Use Space Before On First Line After A Page Break: paragraph spacing after page breaks is represented by CT_CompatSetting and CT_PPr.
/// §14.8.3.44 Suppresstopspacingwp Use Static Text Leading: top-spacing compatibility is represented by CT_CompatSetting and CT_PPr.
/// §14.8.3.45 Swapbordersfacingpages Swap Paragraph Borders On Odd Numbered Pages: facing-page border swapping is represented by CT_CompatSetting and CT_Border.
/// §14.8.3.46 Truncatefontheightslikewp6 Use Truncated Integer Division For Font Calculation: font-height truncation compatibility is represented by CT_CompatSetting and CT_Fonts.
/// §14.8.3.49 Useansikerningpairs Use Ansi Kerning Pairs From Fonts: ANSI kerning compatibility is represented by CT_CompatSetting and CT_Font.
/// §14.8.3.52 Useprintermetrics Use Printer Metrics To Display Documents: printer metrics compatibility is represented by CT_CompatSetting and CT_Settings.
/// §14.8.3.53 Usesingleborderforcontiguouscells Use Simplified Rules For Table Border Conflict: contiguous-cell border compatibility is represented by CT_CompatSetting, CT_TblBorders, and CT_Border.
/// §14.8.3.54 Useword2002Tablestylerules Incorrectly Display Top Border Of Conditional Columns: Word 2002 table-style compatibility is represented by CT_CompatSetting, CT_TblLook, and CT_Cnf.
/// §14.8.3.56 Wpjustification Fit To Expanded Width When Performing Full Justification: WordPerfect justification compatibility is represented by CT_CompatSetting and ST_Jc.
/// §14.8.3.57 Wpspacewidth Use Specific Space Width: WordPerfect space-width compatibility is represented by CT_CompatSetting and CT_CharacterSpacing.
/// §14.8.3.58 Wraptrailspaces Line Wrap Trailing Spaces: trailing-space wrapping compatibility is represented by CT_CompatSetting and CT_PPr.
/// §14.8.4 Web Page Settings: web-page settings are represented by CT_WebSettings, CT_Frame, CT_Frameset, CT_Div, and CT_OptimizeForBrowser.
/// §14.8.4.1 Relyonvml Utilize Vml When Saving As Web Page: VML web-save compatibility is represented by CT_WebSettings and CT_OptimizeForBrowser.
/// §14.9 Miscellaneous Topics: text boxes, alternate chunks, embedded objects, and subdocuments are represented by CT_R, CT_P, EG_BlockLevelChunkElts, and EG_RunLevelElts.
/// §14.9.1 Text Box Content: text-box content is represented by CT_P, CT_R, EG_ContentBlockContent, and EG_ContentRunContent.
/// §14.10 Fields And Hyperlinks: legacy fields and hyperlinks are represented by CT_SimpleField, CT_FldChar, CT_Hyperlink, CT_FFData, and EG_RunInnerContent.
/// §14.10.1 Syntax: field syntax is represented by CT_SimpleField, CT_FldChar, and run content in CT_R.
/// §14.10.2 Legacy Language References: field language references are preserved by CT_SimpleField and CT_R run content.
/// §14.10.3 Use Of Dos File Paths: DOS path field targets are preserved by CT_Hyperlink and CT_SimpleField.
/// §14.10.4 Field Definitions: field definitions are represented by CT_SimpleField, CT_FldChar, and CT_FFData.
/// §14.10.4.1 Autonum: AUTONUM fields are preserved by CT_SimpleField and CT_R.
/// §14.10.4.3 Autonumout: AUTONUMOUT fields are preserved by CT_SimpleField and CT_R.
/// §14.10.4.4 Barcode: BARCODE fields are preserved by CT_SimpleField and CT_R.
/// §14.10.4.6 Eq: EQ fields are preserved by CT_SimpleField and CT_R.
/// §14.10.4.7 Info: INFO fields are preserved by CT_SimpleField and CT_R.
/// §14.10.4.8 Quote: QUOTE fields are preserved by CT_SimpleField and CT_R.
/// §14.11 Simple Types: Part 4 WordprocessingML lexical additions are represented by ST_Cnf, ST_TextScaleDecimal, ST_Jc, ST_JcTable, ST_TabJc, and ST_BrType.
/// §14.11.2 Additional Enumeration Values For St Jc Part 1 17 18 44: extra justification values are represented by ST_Jc.
/// §14.11.3 Additional Enumeration Values For St Jctable Part 1 17 18 45: extra table justification values are represented by ST_JcTable.
/// §14.11.6 Additional Enumeration Values For St Tabjc Part 1 17 18 84: extra tab justification values are represented by ST_TabJc.
/// §14.11.8 Additional Member Types For The Union In St Textscale Part 1 17 18 95: decimal text-scale values are represented by ST_TextScale and ST_TextScaleDecimal.
/// §14.11.9 St Cnf Conditional Formatting Bitmask: conditional-format bitmasks are represented by ST_Cnf and CT_Cnf.
/// §14.11.12 Changed Enumeration Value For St Brtype Part 1 17 18 4: break-type compatibility values are represented by ST_BrType.
/// §14.12 Changed Attributes: changed relationship and attribute targets are preserved by CT_* parse/to_element methods for the referenced elements.
/// §14.12.1 General: changed WordprocessingML attributes are represented by schema domain wrappers that preserve parsed attributes during round-trip.
/// §14.12.2 Changed Attribute For Contentpart Element Part 1 17 3 3 2: content-part relationship attributes are preserved by CT_R and run/block content groups.
/// §14.12.3 Changed Attribute For Control Element Part 1 17 3 3 3: control relationship attributes are preserved by CT_R and run-level content groups.
/// §14.12.4 Changed Attribute For Movie Element Part 1 17 3 3 17: movie relationship attributes are preserved by CT_R and run-level content groups.
/// §14.12.5 Changed Attribute For Objectembed Element Part 1 17 3 3 20: embedded-object relationship attributes are preserved by CT_R and run-level content groups.
/// §14.12.6 Changed Attribute For Objectlink Element Part 1 17 3 3 21: linked-object relationship attributes are preserved by CT_R and run-level content groups.
/// §14.12.7 Changed Attribute For Bottom Element Part 1 17 6 2: page-margin bottom attributes are preserved by EG_SectPrContents and CT_SectPr-related content.
/// §14.12.8 Changed Attribute For Left Element Part 1 17 6 7: page-margin left attributes are preserved by EG_SectPrContents and CT_SectPr-related content.
/// §14.12.9 Changed Attribute For Printersettings Element Part 1 17 6 14: printer-settings relationship attributes are preserved by CT_Settings and section properties.
/// §14.12.10 Changed Attribute For Right Element Part 1 17 6 15: page-margin right attributes are preserved by EG_SectPrContents and CT_SectPr-related content.
/// §14.12.11 Changed Attribute For Top Element Part 1 17 6 21: page-margin top attributes are preserved by EG_SectPrContents and CT_SectPr-related content.
/// §14.12.12 Changed Attribute For Embedbold Element Part 1 17 8 3 3: embedded bold font relationships are represented by CT_FontRel and CT_Font.
/// §14.12.13 Changed Attribute For Embedbolditalic Element Part 1 17 8 3 4: embedded bold-italic font relationships are represented by CT_FontRel and CT_Font.
/// §14.12.14 Changed Attribute For Embeditalic Element Part 1 17 8 3 5: embedded italic font relationships are represented by CT_FontRel and CT_Font.
/// §14.12.15 Changed Attribute For Embedregular Element Part 1 17 8 3 6: embedded regular font relationships are represented by CT_FontRel and CT_Font.
/// §14.12.16 Changed Attribute For Footerreference Element Part 1 17 10 2: footer reference relationships are represented by CT_HdrFtrRef and EG_HdrFtrReferences.
/// §14.12.17 Changed Attribute For Headerreference Element Part 1 17 10 5: header reference relationships are represented by CT_HdrFtrRef and EG_HdrFtrReferences.
/// §14.12.18 Changed Attribute For Datasource Element Part 1 17 14 9: mail-merge data-source relationships are represented by CT_MailMerge and CT_Odso.
/// §14.12.19 Changed Attribute For Headersource Element Part 1 17 14 16: mail-merge header-source relationships are represented by CT_MailMerge and CT_Odso.
/// §14.12.21 Changed Attribute For Src Element Part 1 17 14 30: mail-merge source relationships are represented by CT_MailMerge and CT_Odso.
/// §14.12.22 Changed Attribute For Attachedtemplate Element Part 1 17 15 1 6: attached-template relationships are represented by CT_Settings.
/// §14.12.23 Changed Attribute For Savethroughxslt Element Part 1 17 15 1 76: save-through-XSLT relationships are represented by CT_SaveThroughXslt and CT_Settings.
/// §14.12.24 Changed Attribute For Longdesc Element Part 1 17 15 2 23: long-description relationships are represented by CT_WebSettings and web settings content.
/// §14.12.25 Changed Attribute For Sourcefilename Element Part 1 17 15 2 39: source-file-name relationships are represented by CT_WebSettings and web settings content.
/// §14.12.26 Changed Attribute For Subdoc Element Part 1 17 17 1 1: subdocument relationships are represented by CT_R, CT_P, and EG_BlockLevelChunkElts.
/// §14.12.27 Changed Attribute For Altchunk Element Part 1 17 17 2 1: alternate-chunk relationships are represented by CT_P, CT_R, and EG_BlockLevelChunkElts.
/// XSD complex type CT_Anchor: Wordprocessing drawing anchors are represented by CT_Anchor and CT_Anchor::parse/to_element.
/// XSD simple type ST_HorizontalAnchor: horizontal anchor lexical values are represented by ST_HorizontalAnchor.
/// XSD simple type ST_VerticalAnchor: vertical anchor lexical values are represented by ST_VerticalAnchor.
/// Schema wml.xsd: the WordprocessingML schema surface is represented by the CT_*, ST_*, EG_*, and AG_* domain wrappers in this package.
/// XSD complex type CT_Border: border elements are represented by CT_Border and CT_Border::parse/to_element.
/// XSD complex type CT_Cnf: conditional-format masks are represented by CT_Cnf and ST_Cnf.
/// XSD complex type CT_Div: web-page div settings are represented by CT_Div and CT_Divs.
/// XSD complex type CT_FFData: form-field data is represented by CT_FFData.
/// XSD complex type CT_Font: font entries are represented by CT_Font and CT_FontsList.
/// XSD complex type CT_Frame: frameset frames are represented by CT_Frame and CT_Frameset.
/// XSD complex type CT_Ind: paragraph indentation is represented by CT_Ind.
/// XSD complex type CT_Lvl: numbering levels are represented by CT_Lvl and CT_LvlLegacy.
/// XSD complex type CT_Num: numbering instances are represented by CT_Num and CT_Numbering.
/// XSD complex type CT_NumFmt: numbering formats are represented by CT_NumFmt.
/// XSD complex type CT_PPrBase: paragraph property bases are represented by CT_PPrBase and CT_PPr.
/// XSD complex type CT_Row: table rows are represented by CT_Row and CT_Tbl.
/// XSD complex type CT_SdtPr: structured document tag properties are represented by CT_SdtPr.
/// XSD complex type CT_Shd: shading properties are represented by CT_Shd.
/// XSD complex type CT_TblPPr: floating table positioning properties are represented by CT_TblPPr.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml"
}
