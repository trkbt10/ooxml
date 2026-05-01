///|
/// ECMA-376 Part 1 §17: WordprocessingML facade. Drives reader -> context -> (builder | viewer).
///
/// §3 Specification Sections: this overview maps the package to ECMA-376 Part 1 §11/§17 and Part 4 §14 through CT_Document, CT_Settings, CT_P, CT_R, CT_Tbl, CT_FontsList, CT_Numbering, CT_Comments, and the related ST_* and EG_* wrappers.
/// §11.1 Glossary Of Wordprocessingml Specific Terms: WordprocessingML package terms are represented by CT_Document, CT_Body, CT_P, CT_R, CT_Tbl, and the related document-part wrappers.
/// §11.2 Package Structure: ECMA-376 Part 1 section; Wordprocessing package parts are surfaced by CT_Document, CT_Body, CT_Settings, CT_FontsList, CT_Numbering, CT_Comments, CT_HdrFtr, and their parse/to_element methods.
/// §11.3 Part Summary: ECMA-376 Part 1 section; document, settings, styles, numbering, comments, font table, and header/footer parts are represented by CT_Document, CT_Settings, CT_Style, CT_Numbering, CT_Comments, CT_FontsList, and CT_HdrFtr.
/// §11.4 Document Template: ECMA-376 Part 1 section; attached template relationships and save-through-XSLT settings are represented by CT_Settings and CT_SaveThroughXslt.
/// §11.5 Framesets: ECMA-376 Part 1 section; HTML frameset settings are represented by CT_Frameset, CT_Frame, CT_FrameLayout, CT_FramesetSplitbar, and CT_FrameScrollbar.
/// §11.6 Master Documents And Subdocuments: ECMA-376 Part 1 section; master-document subdocument references are preserved through CT_R, CT_P, EG_BlockLevelChunkElts, and altChunk/subDoc markup round-trips.
/// §11.7 Mail Merge Data Source: mail-merge data-source settings and ODSO field maps are represented by CT_MailMerge, CT_Odso, and CT_OdsoFieldMapData.
/// §11.8 Mail Merge Header Data Source: mail-merge header-source relationships are represented by CT_MailMerge and CT_Odso alongside CT_MailMergeSourceType.
/// §11.9 Xsl Transformation: ECMA-376 Part 1 section; save-through-XSLT settings are represented by CT_SaveThroughXslt inside CT_Settings.
/// §17.1 Table Of Contents: ECMA-376 Part 1 section; field-based tables of contents are represented by CT_SimpleField, CT_FldChar, CT_FFData, CT_Hyperlink, and run-level field content in CT_R.
/// §17.3 Paragraphs And Rich Formatting: ECMA-376 Part 1 section; paragraphs, runs, properties, and rich inline content are represented by CT_P, CT_R, CT_PPr, EG_PContent, EG_RPr, and CT_Fonts.
/// §17.5 Custom Markup: structured document tags and custom XML ranges are represented by CT_SdtPr, CT_SdtBlock, CT_SdtRun, CT_SdtCell, CT_SdtRow, and related content types.
/// §17.8 Fonts: ECMA-376 Part 1 section; font tables and font attributes are represented by CT_FontsList, CT_Font, CT_FontFamily, CT_Pitch, CT_FontSig, CT_FontRel, and ST_FontFamily.
/// §17.9 Numbering: numbering definitions, abstract numbering, levels, and instances are represented by CT_Numbering, CT_AbstractNum, CT_Lvl, CT_Num, and CT_NumPr.
/// §17.10 Headers And Footers: section header/footer references and part bodies are represented by CT_HdrFtrRef, EG_HdrFtrReferences, and CT_HdrFtr.
/// §17.11 Footnotes And Endnotes: note reference properties and note parts are represented by CT_Footnotes, CT_Endnotes, CT_FtnEdn, CT_FtnProps, and CT_EdnProps.
/// §17.12 Glossary Document: glossary document building blocks are represented by CT_GlossaryDocument, CT_DocParts, CT_DocPart, and CT_DocPartPr.
/// §17.13 Annotations: ECMA-376 Part 1 section; comments, bookmarks, move ranges, and revision tracking are represented by CT_Comments, CT_Bookmark, CT_BookmarkRange, CT_TrackChange, CT_TrackChangeRange, and EG_RangeMarkupElements.
/// §17.14 Mail Merge: mail-merge document settings, recipients, ODSO data, and mapped fields are represented by CT_MailMerge, CT_Recipients, CT_RecipientData, and CT_Odso.
/// §17.15 Settings: ECMA-376 Part 1 section; document and web settings are represented by CT_Settings, CT_WebSettings, CT_Compat, CT_CompatSetting, CT_DocVars, and CT_DocRsids.
/// §17.16 Fields And Hyperlinks: ECMA-376 Part 1 section; fields, form-field data, and hyperlinks are represented by CT_SimpleField, CT_FldChar, CT_FFData, CT_Hyperlink, and EG_RunInnerContent.
/// §17.17 Miscellaneous Topics: ECMA-376 Part 1 section; alternate chunks, subdocuments, frames, text boxes, and embedded objects are preserved by CT_P, CT_R, CT_FramePr, EG_BlockLevelChunkElts, and run/block content groups.
/// §17.18 Simple Types: ECMA-376 Part 1 section; WordprocessingML lexical value spaces are represented by ST_Jc, ST_JcTable, ST_TabJc, ST_BrType, ST_TextScale, ST_FontFamily, ST_FrameLayout, and the other ST_* wrappers.
/// §14.1 General: ECMA-376 Part 4 section; Part 4 WordprocessingML migration behavior is documented against the existing CT_* and ST_* domain wrappers rather than new parser entry points.
/// §14.2 Table Of Contents: ECMA-376 Part 4 section; legacy TOC field markup is represented by CT_SimpleField, CT_FldChar, CT_R, and CT_P.
/// §14.3 Paragraphs And Rich Formatting: ECMA-376 Part 4 section; legacy paragraph and run formatting is represented by CT_PPr, CT_PPrBase, CT_R, CT_Fonts, CT_Ind, CT_Border, and CT_Shd.
/// §14.3.1 Paragraphs: ECMA-376 Part 4 section; paragraph compatibility content is represented by CT_P, CT_PPr, CT_PPrBase, CT_PPrGeneral, and EG_PContent.
/// §14.3.1.1 Additional Attribute For Cnfstyle Element Part 1 17 3 1 8: ECMA-376 Part 4 section; paragraph conditional-format attributes are represented by CT_Cnf and ST_Cnf.
/// §14.3.1.2 Additional Attributes For Ind Element Part 1 17 3 1 12: ECMA-376 Part 4 section; paragraph indentation compatibility attributes are represented by CT_Ind.
/// §14.3.2 Run Content: transitional run-level content is represented by CT_R, EG_RunInnerContent, CT_Control, CT_Object, and CT_Drawing.
/// §14.3.2.1 Control Floating Embedded Control: floating embedded controls are represented by CT_Control inside run-level content handled by CT_R.
/// §14.3.2.2 Pict Vml Object: VML picture and object compatibility content is represented by CT_Object, CT_Picture, and run-level CT_R content.
/// §14.4 Tables: ECMA-376 Part 4 section; table compatibility content is represented by CT_Tbl, CT_TblPr, CT_TblPrBase, CT_TblGrid, CT_Row, CT_Cnf, and CT_TblLook.
/// §14.4.1 Left Table Cell Leading Edge Border: ECMA-376 Part 4 section; leading cell-border compatibility is represented by CT_TblBorders and CT_Border.
/// §14.4.2 Left Table Leading Edge Border: ECMA-376 Part 4 section; leading table-border compatibility is represented by CT_TblBorders and CT_Border.
/// §14.4.3 Left Table Cell Leading Margin Exception: ECMA-376 Part 4 section; leading cell-margin exceptions are represented by CT_TblCellMar and CT_TblWidth.
/// §14.4.4 Left Table Cell Leading Margin Default: ECMA-376 Part 4 section; default leading cell margins are represented by CT_TblCellMar and CT_TblWidth.
/// §14.4.5 Right Table Cell Trailing Edge Border: ECMA-376 Part 4 section; trailing cell-border compatibility is represented by CT_TblBorders and CT_Border.
/// §14.4.6 Right Table Trailing Edge Border: ECMA-376 Part 4 section; trailing table-border compatibility is represented by CT_TblBorders and CT_Border.
/// §14.4.7 Right Table Cell Trailing Margin Default: ECMA-376 Part 4 section; default trailing cell margins are represented by CT_TblCellMar and CT_TblWidth.
/// §14.4.8 Right Table Cell Trailing Margin Exception: ECMA-376 Part 4 section; trailing cell-margin exceptions are represented by CT_TblCellMar and CT_TblWidth.
/// §14.4.9 Additional Attribute For Cnfstyle Element Part 1 17 4 7: ECMA-376 Part 4 section; table conditional-format attributes are represented by CT_Cnf and ST_Cnf.
/// §14.4.10 Additional Attribute For Cnfstyle Element Part 1 17 4 8: ECMA-376 Part 4 section; table-row conditional-format attributes are represented by CT_Cnf and ST_Cnf.
/// §14.4.11 Additional Attribute For Tbllook Element Part 1 17 4 54: ECMA-376 Part 4 section; table-look compatibility attributes are represented by CT_TblLook.
/// §14.4.12 Additional Attribute For Tbllook Element Part 1 17 4 55: ECMA-376 Part 4 section; table-style look compatibility attributes are represented by CT_TblLook.
/// §14.4.13 Hmerge Horizontally Merged Cell: ECMA-376 Part 4 section; horizontal cell merge compatibility is represented by CT_Row, CT_Tbl, and cell content groups.
/// §14.5 Fonts: ECMA-376 Part 4 section; font compatibility markup is represented by CT_FontsList, CT_Font, CT_FontFamily, CT_Pitch, and CT_FontSig.
/// §14.5.1 Elements: ECMA-376 Part 4 section; font-table elements are represented by CT_FontsList, CT_Font, CT_FontRel, CT_Panose, and CT_FontSig.
/// §14.5.1.1 Additional Attribute For Charset Element Part 1 17 8 3 2: ECMA-376 Part 4 section; charset compatibility attributes are represented by CT_Font and CT_FontSig.
/// §14.6 Numbering: transitional numbering compatibility is represented by CT_Numbering, CT_AbstractNum, CT_Num, CT_Lvl, and CT_NumPicBullet.
/// §14.6.1 Pict Picture Numbering Symbol Properties: picture numbering symbols are represented by CT_NumPicBullet and CT_Picture.
/// §14.6.2 Legacy Legacy Numbering Level Properties: ECMA-376 Part 4 section; legacy numbering level properties are represented by CT_LvlLegacy, CT_Lvl, CT_Num, and CT_Numbering.
/// §14.7 Annotations: ECMA-376 Part 4 section; legacy annotation and revision markup is represented by CT_Comments, CT_TrackChange, CT_TrackChangeRange, CT_Bookmark, and EG_RangeMarkupElements.
/// §14.7.1 Revisions: ECMA-376 Part 4 section; revision-specific compatibility markup is represented by CT_TrackChange, CT_TrackChangesView, CT_TrackChangeRange, CT_PPrChange, CT_TblPrChange, and CT_TblGridChange.
/// §14.7.1.1 Numberingchange Previous Numbering Field Properties: prior numbering field properties are represented by CT_TrackChangeNumbering and CT_NumPr.
/// §14.7.1.2 Numberingchange Previous Paragraph Numbering Properties: previous paragraph numbering revisions are represented by CT_TrackChangeNumbering and CT_PPrChange.
/// §14.8 Settings: ECMA-376 Part 4 section; document compatibility settings are represented by CT_Settings, CT_Compat, CT_CompatSetting, CT_WebSettings, and CT_SaveThroughXslt.
/// §14.8.1 Legacy Password Hash Algorithm: legacy password-hash attributes are represented by AG_TransitionalPassword with CT_WriteProtection and CT_DocProtect settings.
/// §14.8.2 Document Settings: ECMA-376 Part 4 section; document-level compatibility settings are represented by CT_Settings, CT_DocVars, CT_DocRsids, CT_WriteProtection, and CT_ColorSchemeMapping.
/// §14.8.2.1 Hdrshapedefaults Default Properties For Vml Objects In Header And Footer: header/footer VML defaults are represented by CT_ShapeDefaults and CT_HdrFtr.
/// §14.8.2.2 Shapedefaults Default Properties For Vml Objects In Main Document: main-document VML defaults are represented by CT_ShapeDefaults and CT_Settings.
/// §14.8.2.4 Additional Attribute For Stylepaneformatfilter Element Part 1 17 15 1 85: ECMA-376 Part 4 section; style-pane format-filter compatibility is represented by CT_Settings and ST_StyleSort.
/// §14.8.3 Compatibility Settings: ECMA-376 Part 4 section; compatibility flags are represented by CT_Compat and CT_CompatSetting.
/// §14.8.3.1 Aligntablesrowbyrow Align Table Rows Independently: ECMA-376 Part 4 section; row-by-row table alignment is represented by CT_CompatSetting with CT_Tbl and CT_Row table structures.
/// §14.8.3.2 Allowspaceofsamestyleintable Allow Contextual Spacing Of Paragraphs In Tables: ECMA-376 Part 4 section; contextual table paragraph spacing is represented by CT_CompatSetting, CT_PPr, and CT_Tbl.
/// §14.8.3.4 Autospacelikeword95 Incorrectly Adjust Text Spacing For Specific Unicode Ranges: automatic spacing compatibility is represented by CT_CompatSetting and CT_CharacterSpacing.
/// §14.8.3.5 Cachedcolbalance Use Cached Paragraph Information For Column Balancing: ECMA-376 Part 4 section; cached column balancing is represented by CT_CompatSetting and section content in EG_SectPrContents.
/// §14.8.3.6 Convmailmergeesc Treat Backslash Quotation Delimiter As Two Quotation Marks: ECMA-376 Part 4 section; mail-merge escaping compatibility is represented by CT_CompatSetting and CT_MailMerge.
/// §14.8.3.7 Displayhangulfixedwidth Always Use Fixed Width For Hangul Characters: ECMA-376 Part 4 section; Hangul width compatibility is represented by CT_CompatSetting and CT_CharacterSpacing.
/// §14.8.3.10 Donotbreakwrappedtables Do Not Allow Floating Tables To Break Across Pages: ECMA-376 Part 4 section; wrapped table page-break compatibility is represented by CT_CompatSetting, CT_TblPPr, and CT_Tbl.
/// §14.8.3.11 Donotsnaptogridincell Do Not Snap To Document Grid In Table Cells With Objects: ECMA-376 Part 4 section; table-cell grid snapping compatibility is represented by CT_CompatSetting and CT_Tbl.
/// §14.8.3.13 Donotsuppressparagraphborders Do Not Suppress Paragraph Borders Next To Frames: ECMA-376 Part 4 section; paragraph-border compatibility near frames is represented by CT_CompatSetting, CT_Border, and CT_FramePr.
/// §14.8.3.17 Donotvertaligncellwithsp Don T Vertically Align Cells Containing Floating Object: floating-object table-cell alignment is represented by CT_CompatSetting and CT_TcPr.
/// §14.8.3.18 Donotvertalignintxbx Ignore Vertical Alignment In Textboxes: textbox vertical-alignment compatibility is represented by CT_CompatSetting and CT_TxbxContent.
/// §14.8.3.19 Donotwraptextwithpunct Do Not Allow Hanging Punctuation With Character Grid: ECMA-376 Part 4 section; punctuation wrapping compatibility is represented by CT_CompatSetting and CT_PPr.
/// §14.8.3.20 Footnotelayoutlikeww8 Ignore Page Break From Continuous Section Break: ECMA-376 Part 4 section; footnote layout compatibility is represented by CT_CompatSetting and EG_FtnEdnNumProps.
/// §14.8.3.22 Growautofit Allow Tables To Autofit Into Page Margins: ECMA-376 Part 4 section; table autofit compatibility is represented by CT_CompatSetting, CT_TblLayoutType, and CT_TblPr.
/// §14.8.3.24 Layouttablerowsapart Allow Table Rows To Wrap Inline Objects Independently: ECMA-376 Part 4 section; independent row wrapping is represented by CT_CompatSetting, CT_Row, and CT_TblPPr.
/// §14.8.3.25 Linewraplikeword6 Ignore Compression Of Full Width Punctuation Ending A Line: ECMA-376 Part 4 section; Word 6 line-wrapping compatibility is represented by CT_CompatSetting and CT_PPr.
/// §14.8.3.26 Mwsmallcaps Use Specific Small Caps Algorithm: ECMA-376 Part 4 section; small-caps compatibility is represented by CT_CompatSetting and EG_RPr.
/// §14.8.3.27 Nocolumnbalance Do Not Balance Text Columns Within A Section: ECMA-376 Part 4 section; column-balance compatibility is represented by CT_CompatSetting and EG_SectPrContents.
/// §14.8.3.30 Nospaceraiselower Do Not Increase Line Height For Raised Lowered Text: ECMA-376 Part 4 section; raised/lowered text spacing compatibility is represented by CT_CompatSetting and EG_RPr.
/// §14.8.3.31 Notabhangind Do Not Create Custom Tab Stop For Hanging Indent: ECMA-376 Part 4 section; hanging-indent tab compatibility is represented by CT_CompatSetting and CT_Ind.
/// §14.8.3.33 Printcolblack Print Colors As Black And White Without Dithering: ECMA-376 Part 4 section; black-and-white print compatibility is represented by CT_CompatSetting and CT_Settings.
/// §14.8.3.34 Selectfldwithfirstorlastchar Select Field When First Or Last Character Is Select: ECMA-376 Part 4 section; field selection compatibility is represented by CT_CompatSetting, CT_SimpleField, and CT_FldChar.
/// §14.8.3.35 Shapelayoutlikeww8 Ignore Text Wrapping Around Objects At Bottom Of Page: ECMA-376 Part 4 section; shape layout compatibility is represented by CT_CompatSetting, CT_Anchor, and EG_WrapType.
/// §14.8.3.36 Showbreaksinframes Display Page Column Breaks Present In Frames: ECMA-376 Part 4 section; frame break display compatibility is represented by CT_CompatSetting, CT_Frame, and CT_FramePr.
/// §14.8.3.37 Spacinginwholepoints Only Expand Condense Text By Whole Points: ECMA-376 Part 4 section; whole-point spacing compatibility is represented by CT_CompatSetting and CT_CharacterSpacing.
/// §14.8.3.38 Splitpgbreakandparamark Always Move Paragraph Mark To Page After A Page Break: page-break paragraph-mark compatibility is represented by CT_CompatSetting and CT_P.
/// §14.8.3.39 Subfontbysize Require Exact Size During Font Substitution: ECMA-376 Part 4 section; font substitution compatibility is represented by CT_CompatSetting and CT_FontsList.
/// §14.8.3.40 Suppressbottomspacing Ignore Exact Line Height For Last Line On Page: bottom-line spacing compatibility is represented by CT_CompatSetting and CT_Spacing.
/// §14.8.3.41 Suppressspacingattopofpage Ignore Minimum Line Height For First Line On Page: top-of-page spacing compatibility is represented by CT_CompatSetting and CT_Spacing.
/// §14.8.3.42 Suppressspbfafterpgbrk Do Not Use Space Before On First Line After A Page Break: ECMA-376 Part 4 section; paragraph spacing after page breaks is represented by CT_CompatSetting and CT_PPr.
/// §14.8.3.44 Suppresstopspacingwp Use Static Text Leading: ECMA-376 Part 4 section; top-spacing compatibility is represented by CT_CompatSetting and CT_PPr.
/// §14.8.3.45 Swapbordersfacingpages Swap Paragraph Borders On Odd Numbered Pages: ECMA-376 Part 4 section; facing-page border swapping is represented by CT_CompatSetting and CT_Border.
/// §14.8.3.46 Truncatefontheightslikewp6 Use Truncated Integer Division For Font Calculation: ECMA-376 Part 4 section; font-height truncation compatibility is represented by CT_CompatSetting and CT_Fonts.
/// §14.8.3.47 Underlinetabinnumlist Underline Following Character Following Numbering: numbering-list underline compatibility is represented by CT_CompatSetting, CT_NumPr, and CT_Underline.
/// §14.8.3.49 Useansikerningpairs Use Ansi Kerning Pairs From Fonts: ECMA-376 Part 4 section; ANSI kerning compatibility is represented by CT_CompatSetting and CT_Font.
/// §14.8.3.50 Usefelayout Do Not Bypass East Asian Complex Script Layout Code: East Asian layout compatibility is represented by CT_CompatSetting and CT_EastAsianLayout.
/// §14.8.3.52 Useprintermetrics Use Printer Metrics To Display Documents: ECMA-376 Part 4 section; printer metrics compatibility is represented by CT_CompatSetting and CT_Settings.
/// §14.8.3.53 Usesingleborderforcontiguouscells Use Simplified Rules For Table Border Conflict: ECMA-376 Part 4 section; contiguous-cell border compatibility is represented by CT_CompatSetting, CT_TblBorders, and CT_Border.
/// §14.8.3.54 Useword2002Tablestylerules Incorrectly Display Top Border Of Conditional Columns: ECMA-376 Part 4 section; Word 2002 table-style compatibility is represented by CT_CompatSetting, CT_TblLook, and CT_Cnf.
/// §14.8.3.55 Useword97Linebreakrules Use Incorrect Inter Character Spacing Rules: Word 97 line-break compatibility is represented by CT_CompatSetting and CT_PPr.
/// §14.8.3.56 Wpjustification Fit To Expanded Width When Performing Full Justification: ECMA-376 Part 4 section; WordPerfect justification compatibility is represented by CT_CompatSetting and ST_Jc.
/// §14.8.3.57 Wpspacewidth Use Specific Space Width: ECMA-376 Part 4 section; WordPerfect space-width compatibility is represented by CT_CompatSetting and CT_CharacterSpacing.
/// §14.8.3.58 Wraptrailspaces Line Wrap Trailing Spaces: ECMA-376 Part 4 section; trailing-space wrapping compatibility is represented by CT_CompatSetting and CT_PPr.
/// §14.8.4 Web Page Settings: ECMA-376 Part 4 section; web-page settings are represented by CT_WebSettings, CT_Frame, CT_Frameset, CT_Div, and CT_OptimizeForBrowser.
/// §14.8.4.1 Relyonvml Utilize Vml When Saving As Web Page: ECMA-376 Part 4 section; VML web-save compatibility is represented by CT_WebSettings and CT_OptimizeForBrowser.
/// §14.9 Miscellaneous Topics: ECMA-376 Part 4 section; text boxes, alternate chunks, embedded objects, and subdocuments are represented by CT_R, CT_P, EG_BlockLevelChunkElts, and EG_RunLevelElts.
/// §14.9.1 Text Box Content: ECMA-376 Part 4 section; text-box content is represented by CT_P, CT_R, EG_ContentBlockContent, and EG_ContentRunContent.
/// §14.9.1.1 Txbxcontent Rich Text Box Content Container: rich text-box content is represented by CT_TxbxContent and EG_ContentBlockContent.
/// §14.10 Fields And Hyperlinks: ECMA-376 Part 4 section; legacy fields and hyperlinks are represented by CT_SimpleField, CT_FldChar, CT_Hyperlink, CT_FFData, and EG_RunInnerContent.
/// §14.10.1 Syntax: ECMA-376 Part 4 section; field syntax is represented by CT_SimpleField, CT_FldChar, and run content in CT_R.
/// §14.10.2 Legacy Language References: ECMA-376 Part 4 section; field language references are preserved by CT_SimpleField and CT_R run content.
/// §14.10.3 Use Of Dos File Paths: ECMA-376 Part 4 section; DOS path field targets are preserved by CT_Hyperlink and CT_SimpleField.
/// §14.10.4 Field Definitions: ECMA-376 Part 4 section; field definitions are represented by CT_SimpleField, CT_FldChar, and CT_FFData.
/// §14.10.4.1 Autonum: ECMA-376 Part 4 section; AUTONUM fields are preserved by CT_SimpleField and CT_R.
/// §14.10.4.3 Autonumout: ECMA-376 Part 4 section; AUTONUMOUT fields are preserved by CT_SimpleField and CT_R.
/// §14.10.4.4 Barcode: ECMA-376 Part 4 section; BARCODE fields are preserved by CT_SimpleField and CT_R.
/// §14.10.4.6 Eq: ECMA-376 Part 4 section; EQ fields are preserved by CT_SimpleField and CT_R.
/// §14.10.4.7 Info: ECMA-376 Part 4 section; INFO fields are preserved by CT_SimpleField and CT_R.
/// §14.10.4.8 Quote: ECMA-376 Part 4 section; QUOTE fields are preserved by CT_SimpleField and CT_R.
/// §14.10.5 Flddata Custom Field Data: custom field data is represented by CT_FFData and CT_FldChar in run-level field content.
/// §14.10.6 Flddata Custom Field Data: alternate custom field-data markup is represented by CT_FFData and CT_SimpleField.
/// §14.10.7 Hyperlink Hyperlink Part 1 17 16 22: hyperlink compatibility is represented by CT_Hyperlink and EG_RunInnerContent.
/// §14.11 Simple Types: ECMA-376 Part 4 section; Part 4 WordprocessingML lexical additions are represented by ST_Cnf, ST_TextScaleDecimal, ST_Jc, ST_JcTable, ST_TabJc, and ST_BrType.
/// §14.11.1 Additional Member Types For The Union In St Decimalnumberorpercent Part 1 17 18: decimal-number-or-percent additions are represented by ST_DecimalNumberOrPercent and ST_UnqualifiedPercentage.
/// §14.11.2 Additional Enumeration Values For St Jc Part 1 17 18 44: ECMA-376 Part 4 section; extra justification values are represented by ST_Jc.
/// §14.11.3 Additional Enumeration Values For St Jctable Part 1 17 18 45: ECMA-376 Part 4 section; extra table justification values are represented by ST_JcTable.
/// §14.11.4 Additional Enumeration Values For St Numberformat Part 1 17 18 59: extra numbering format values are represented by ST_NumberFormat.
/// §14.11.5 Additional Enumeration Values For St Stylesort Part 1 17 18 82: extra style-sort values are represented by ST_StyleSort.
/// §14.11.6 Additional Enumeration Values For St Tabjc Part 1 17 18 84: ECMA-376 Part 4 section; extra tab justification values are represented by ST_TabJc.
/// §14.11.7 Additional Enumeration Values For St Textdirection Part 1 17 18 93: extra text-direction values are represented by ST_TextDirection.
/// §14.11.8 Additional Member Types For The Union In St Textscale Part 1 17 18 95: ECMA-376 Part 4 section; decimal text-scale values are represented by ST_TextScale and ST_TextScaleDecimal.
/// §14.11.9 St Cnf Conditional Formatting Bitmask: ECMA-376 Part 4 section; conditional-format bitmasks are represented by ST_Cnf and CT_Cnf.
/// §14.11.10 St Unqualifiedpercentage Percentage Value Without Percent Sign: unqualified percentages are represented by ST_UnqualifiedPercentage.
/// §14.11.11 St Textscaledecimal Text Expansion Compression Percentage: decimal text scaling is represented by ST_TextScaleDecimal and ST_TextScale.
/// §14.11.12 Changed Enumeration Value For St Brtype Part 1 17 18 4: ECMA-376 Part 4 section; break-type compatibility values are represented by ST_BrType.
/// §14.12 Changed Attributes: ECMA-376 Part 4 section; changed relationship and attribute targets are preserved by CT_* parse/to_element methods for the referenced elements.
/// §14.12.1 General: ECMA-376 Part 4 section; changed WordprocessingML attributes are represented by schema domain wrappers that preserve parsed attributes during round-trip.
/// §14.12.2 Changed Attribute For Contentpart Element Part 1 17 3 3 2: ECMA-376 Part 4 section; content-part relationship attributes are preserved by CT_R and run/block content groups.
/// §14.12.3 Changed Attribute For Control Element Part 1 17 3 3 3: ECMA-376 Part 4 section; control relationship attributes are preserved by CT_R and run-level content groups.
/// §14.12.4 Changed Attribute For Movie Element Part 1 17 3 3 17: ECMA-376 Part 4 section; movie relationship attributes are preserved by CT_R and run-level content groups.
/// §14.12.5 Changed Attribute For Objectembed Element Part 1 17 3 3 20: ECMA-376 Part 4 section; embedded-object relationship attributes are preserved by CT_R and run-level content groups.
/// §14.12.6 Changed Attribute For Objectlink Element Part 1 17 3 3 21: ECMA-376 Part 4 section; linked-object relationship attributes are preserved by CT_R and run-level content groups.
/// §14.12.7 Changed Attribute For Bottom Element Part 1 17 6 2: ECMA-376 Part 4 section; page-margin bottom attributes are preserved by EG_SectPrContents and CT_SectPr-related content.
/// §14.12.8 Changed Attribute For Left Element Part 1 17 6 7: ECMA-376 Part 4 section; page-margin left attributes are preserved by EG_SectPrContents and CT_SectPr-related content.
/// §14.12.9 Changed Attribute For Printersettings Element Part 1 17 6 14: ECMA-376 Part 4 section; printer-settings relationship attributes are preserved by CT_Settings and section properties.
/// §14.12.10 Changed Attribute For Right Element Part 1 17 6 15: ECMA-376 Part 4 section; page-margin right attributes are preserved by EG_SectPrContents and CT_SectPr-related content.
/// §14.12.11 Changed Attribute For Top Element Part 1 17 6 21: ECMA-376 Part 4 section; page-margin top attributes are preserved by EG_SectPrContents and CT_SectPr-related content.
/// §14.12.12 Changed Attribute For Embedbold Element Part 1 17 8 3 3: ECMA-376 Part 4 section; embedded bold font relationships are represented by CT_FontRel and CT_Font.
/// §14.12.13 Changed Attribute For Embedbolditalic Element Part 1 17 8 3 4: ECMA-376 Part 4 section; embedded bold-italic font relationships are represented by CT_FontRel and CT_Font.
/// §14.12.14 Changed Attribute For Embeditalic Element Part 1 17 8 3 5: ECMA-376 Part 4 section; embedded italic font relationships are represented by CT_FontRel and CT_Font.
/// §14.12.15 Changed Attribute For Embedregular Element Part 1 17 8 3 6: ECMA-376 Part 4 section; embedded regular font relationships are represented by CT_FontRel and CT_Font.
/// §14.12.16 Changed Attribute For Footerreference Element Part 1 17 10 2: ECMA-376 Part 4 section; footer reference relationships are represented by CT_HdrFtrRef and EG_HdrFtrReferences.
/// §14.12.17 Changed Attribute For Headerreference Element Part 1 17 10 5: ECMA-376 Part 4 section; header reference relationships are represented by CT_HdrFtrRef and EG_HdrFtrReferences.
/// §14.12.18 Changed Attribute For Datasource Element Part 1 17 14 9: ECMA-376 Part 4 section; mail-merge data-source relationships are represented by CT_MailMerge and CT_Odso.
/// §14.12.19 Changed Attribute For Headersource Element Part 1 17 14 16: ECMA-376 Part 4 section; mail-merge header-source relationships are represented by CT_MailMerge and CT_Odso.
/// §14.12.20 Changed Attribute For Recipientdata Element Part 1 17 14 28: recipient-data relationships are represented by CT_RecipientData and CT_Recipients.
/// §14.12.21 Changed Attribute For Src Element Part 1 17 14 30: ECMA-376 Part 4 section; mail-merge source relationships are represented by CT_MailMerge and CT_Odso.
/// §14.12.22 Changed Attribute For Attachedtemplate Element Part 1 17 15 1 6: ECMA-376 Part 4 section; attached-template relationships are represented by CT_Settings.
/// §14.12.23 Changed Attribute For Savethroughxslt Element Part 1 17 15 1 76: ECMA-376 Part 4 section; save-through-XSLT relationships are represented by CT_SaveThroughXslt and CT_Settings.
/// §14.12.24 Changed Attribute For Longdesc Element Part 1 17 15 2 23: ECMA-376 Part 4 section; long-description relationships are represented by CT_WebSettings and web settings content.
/// §14.12.25 Changed Attribute For Sourcefilename Element Part 1 17 15 2 39: ECMA-376 Part 4 section; source-file-name relationships are represented by CT_WebSettings and web settings content.
/// §14.12.26 Changed Attribute For Subdoc Element Part 1 17 17 1 1: ECMA-376 Part 4 section; subdocument relationships are represented by CT_R, CT_P, and EG_BlockLevelChunkElts.
/// §14.12.27 Changed Attribute For Altchunk Element Part 1 17 17 2 1: ECMA-376 Part 4 section; alternate-chunk relationships are represented by CT_P, CT_R, and EG_BlockLevelChunkElts.
/// XSD complex type CT_Anchor: wordprocessing drawing schema declares this complex type; Wordprocessing drawing anchors are represented by CT_Anchor and CT_Anchor::parse/to_element.
/// XSD simple type ST_HorizontalAnchor: wordprocessing drawing schema declares this simple type; horizontal anchor lexical values are represented by ST_HorizontalAnchor.
/// XSD simple type ST_VerticalAnchor: wordprocessing drawing schema declares this simple type; vertical anchor lexical values are represented by ST_VerticalAnchor.
/// Schema wml.xsd: the WordprocessingML schema surface is represented by the CT_*, ST_*, EG_*, and AG_* domain wrappers in this package.
/// XSD complex type CT_Border: wml.xsd declares this complex type; border elements are represented by CT_Border and CT_Border::parse/to_element.
/// XSD complex type CT_Cnf: wml.xsd declares this complex type; conditional-format masks are represented by CT_Cnf and ST_Cnf.
/// XSD complex type CT_Div: wml.xsd declares this complex type; web-page div settings are represented by CT_Div and CT_Divs.
/// XSD complex type CT_FFData: wml.xsd declares this complex type; form-field data is represented by CT_FFData.
/// XSD complex type CT_Font: wml.xsd declares this complex type; font entries are represented by CT_Font and CT_FontsList.
/// XSD complex type CT_Frame: wml.xsd declares this complex type; frameset frames are represented by CT_Frame and CT_Frameset.
/// XSD complex type CT_Ind: wml.xsd declares this complex type; paragraph indentation is represented by CT_Ind.
/// XSD complex type CT_Lvl: wml.xsd declares this complex type; numbering levels are represented by CT_Lvl and CT_LvlLegacy.
/// XSD complex type CT_Num: wml.xsd declares this complex type; numbering instances are represented by CT_Num and CT_Numbering.
/// XSD complex type CT_NumFmt: wml.xsd declares this complex type; numbering formats are represented by CT_NumFmt.
/// XSD complex type CT_PPrBase: wml.xsd declares this complex type; paragraph property bases are represented by CT_PPrBase and CT_PPr.
/// XSD complex type CT_Row: wml.xsd declares this complex type; table rows are represented by CT_Row and CT_Tbl.
/// XSD complex type CT_SdtPr: wml.xsd declares this complex type; structured document tag properties are represented by CT_SdtPr.
/// XSD complex type CT_Shd: wml.xsd declares this complex type; shading properties are represented by CT_Shd.
/// XSD complex type CT_TblPPr: wml.xsd declares this complex type; floating table positioning properties are represented by CT_TblPPr.
///
/// §11.2 Package Structure: read_document and CT_Document cover the main document part, while CT_Settings, CT_Style, CT_Numbering, CT_Comments, CT_FontsList, and CT_HdrFtr cover the package-level WordprocessingML parts.
/// §11.3 Part Summary: CT_Document, CT_Body, CT_Settings, CT_Style, CT_Numbering, CT_Comments, CT_FontsList, and CT_HdrFtr identify the WordprocessingML parts summarized for a word-processing package.
/// §11.4 Document Template: CT_Settings and CT_SaveThroughXslt preserve attached-template and transformation settings carried by a document package.
/// §11.5 Framesets: CT_Frameset, CT_Frame, CT_FrameLayout, CT_FramesetSplitbar, and CT_FrameScrollbar represent the frameset structures used by WordprocessingML web documents.
/// §11.6 Master Documents And Subdocuments: CT_P, CT_R, and EG_BlockLevelChunkElts preserve subdocument and alternate content references used by master documents.
/// §11.9 Xsl Transformation: CT_SaveThroughXslt and CT_Settings represent save-through-XSLT document settings and their package relationships.
/// §17.1 Table Of Contents: CT_SimpleField, CT_FldChar, CT_Hyperlink, CT_FFData, and CT_R preserve the field-coded TOC content model.
/// §17.3 Paragraphs And Rich Formatting: CT_P, CT_R, CT_PPr, CT_RPr, CT_Fonts, CT_Ind, CT_Border, and CT_Shd model paragraph and run content with direct formatting.
/// §17.8 Fonts: CT_FontsList, CT_Font, CT_FontRel, CT_FontFamily, CT_Pitch, and CT_FontSig model font-table entries and embedded font relationships.
/// §17.10 Headers And Footers: CT_HdrFtrRef, EG_HdrFtrReferences, and CT_HdrFtr model section header/footer references and the header/footer part body.
/// §17.13 Annotations: CT_Comments, CT_Bookmark, CT_BookmarkRange, CT_TrackChange, CT_TrackChangeRange, and EG_RangeMarkupElements model comments, bookmarks, and revisions.
/// §17.15 Settings: CT_Settings, CT_WebSettings, CT_Compat, CT_CompatSetting, CT_DocVars, and CT_DocRsids model document-wide settings and compatibility options.
/// §17.16 Fields And Hyperlinks: CT_SimpleField, CT_FldChar, CT_FFData, CT_Hyperlink, and EG_RunInnerContent model fields, form fields, and hyperlink run content.
/// §17.17 Miscellaneous Topics: CT_P, CT_R, CT_FramePr, EG_BlockLevelChunkElts, and EG_RunLevelElts preserve alternate chunks, frames, objects, and subdocument references.
/// §17.18 Simple Types: ST_Jc, ST_JcTable, ST_TabJc, ST_BrType, ST_TextScale, ST_FontFamily, and ST_FrameLayout provide WordprocessingML lexical value wrappers.
/// §14.1 General: CT_Document and the package CT_* and ST_* wrappers preserve Part 4 transitional WordprocessingML markup during parse and serialization.
/// §14.2 Table Of Contents: CT_SimpleField, CT_FldChar, CT_R, and CT_P preserve legacy TOC fields as WordprocessingML run and paragraph content.
/// §14.3 Paragraphs And Rich Formatting: CT_PPr, CT_PPrBase, CT_R, CT_Fonts, CT_Ind, CT_Border, and CT_Shd represent transitional paragraph and run formatting.
/// §14.3.1 Paragraphs: CT_P, CT_PPr, CT_PPrBase, CT_PPrGeneral, and EG_PContent represent paragraph content and compatibility properties.
/// §14.3.1.1 Additional Attribute For Cnfstyle Element Part 1 17 3 1 8: CT_Cnf and ST_Cnf preserve conditional-format bit attributes on paragraph cnfStyle markup.
/// §14.3.1.2 Additional Attributes For Ind Element Part 1 17 3 1 12: CT_Ind preserves transitional paragraph indentation attributes.
/// §14.4 Tables: CT_Tbl, CT_TblPr, CT_TblPrBase, CT_TblGrid, CT_Row, CT_Cnf, and CT_TblLook represent table compatibility markup.
/// §14.4.1 Left Table Cell Leading Edge Border: CT_TblBorders and CT_Border preserve leading cell border compatibility markup.
/// §14.4.2 Left Table Leading Edge Border: CT_TblBorders and CT_Border preserve leading table border compatibility markup.
/// §14.4.3 Left Table Cell Leading Margin Exception: CT_TblCellMar and CT_TblWidth preserve leading cell-margin exception widths.
/// §14.4.4 Left Table Cell Leading Margin Default: CT_TblCellMar and CT_TblWidth preserve default leading cell margins.
/// §14.4.5 Right Table Cell Trailing Edge Border: CT_TblBorders and CT_Border preserve trailing cell border compatibility markup.
/// §14.4.6 Right Table Trailing Edge Border: CT_TblBorders and CT_Border preserve trailing table border compatibility markup.
/// §14.4.7 Right Table Cell Trailing Margin Default: CT_TblCellMar and CT_TblWidth preserve default trailing cell margins.
/// §14.4.8 Right Table Cell Trailing Margin Exception: CT_TblCellMar and CT_TblWidth preserve trailing cell-margin exception widths.
/// §14.4.9 Additional Attribute For Cnfstyle Element Part 1 17 4 7: CT_Cnf and ST_Cnf preserve conditional-format attributes for table property markup.
/// §14.4.10 Additional Attribute For Cnfstyle Element Part 1 17 4 8: CT_Cnf and ST_Cnf preserve conditional-format attributes for row property markup.
/// §14.4.11 Additional Attribute For Tbllook Element Part 1 17 4 54: CT_TblLook preserves table-look compatibility attributes on table styles.
/// §14.4.12 Additional Attribute For Tbllook Element Part 1 17 4 55: CT_TblLook preserves table-look compatibility attributes on table properties.
/// §14.4.13 Hmerge Horizontally Merged Cell: CT_Row, CT_Tbl, and CT_TcPr preserve horizontally merged table-cell markup.
/// §14.5 Fonts: CT_FontsList, CT_Font, CT_FontFamily, CT_Pitch, and CT_FontSig represent transitional font-table markup.
/// §14.5.1 Elements: CT_FontsList, CT_Font, CT_FontRel, CT_Panose, and CT_FontSig represent font-table child elements.
/// §14.5.1.1 Additional Attribute For Charset Element Part 1 17 8 3 2: CT_Font and CT_FontSig preserve charset-related font compatibility attributes.
/// §14.6.2 Legacy Legacy Numbering Level Properties: CT_LvlLegacy, CT_Lvl, CT_Num, and CT_Numbering preserve legacy numbering level properties.
/// §14.7.1 Revisions: CT_TrackChange, CT_TrackChangesView, CT_TrackChangeRange, CT_PPrChange, CT_TblPrChange, and CT_TblGridChange model revision markup.
/// §14.8 Settings: CT_Settings, CT_Compat, CT_CompatSetting, CT_WebSettings, and CT_SaveThroughXslt model transitional document settings.
/// §14.8.2 Document Settings: CT_Settings, CT_DocVars, CT_DocRsids, CT_WriteProtection, and CT_ColorSchemeMapping represent document-level settings.
/// §14.8.2.4 Additional Attribute For Stylepaneformatfilter Element Part 1 17 15 1 85: CT_Settings and ST_StyleSort preserve style-pane format-filter compatibility values.
/// §14.8.3 Compatibility Settings: CT_Compat and CT_CompatSetting preserve named compatibility settings and their values.
/// §14.8.3.1 Aligntablesrowbyrow Align Table Rows Independently: CT_CompatSetting, CT_Tbl, and CT_Row represent row-independent table alignment behavior.
/// §14.8.3.2 Allowspaceofsamestyleintable Allow Contextual Spacing Of Paragraphs In Tables: CT_CompatSetting, CT_PPr, and CT_Tbl represent contextual spacing inside tables.
/// §14.8.3.5 Cachedcolbalance Use Cached Paragraph Information For Column Balancing: CT_CompatSetting and EG_SectPrContents preserve cached column balancing behavior.
/// §14.8.3.6 Convmailmergeesc Treat Backslash Quotation Delimiter As Two Quotation Marks: CT_CompatSetting and CT_MailMerge preserve mail-merge escape compatibility.
/// §14.8.3.7 Displayhangulfixedwidth Always Use Fixed Width For Hangul Characters: CT_CompatSetting and CT_CharacterSpacing preserve fixed-width Hangul behavior.
/// §14.8.3.10 Donotbreakwrappedtables Do Not Allow Floating Tables To Break Across Pages: CT_CompatSetting, CT_TblPPr, and CT_Tbl preserve wrapped-table pagination behavior.
/// §14.8.3.11 Donotsnaptogridincell Do Not Snap To Document Grid In Table Cells With Objects: CT_CompatSetting and CT_Tbl preserve table-cell grid snapping behavior.
/// §14.8.3.13 Donotsuppressparagraphborders Do Not Suppress Paragraph Borders Next To Frames: CT_CompatSetting, CT_Border, and CT_FramePr preserve frame-adjacent paragraph borders.
/// §14.8.3.19 Donotwraptextwithpunct Do Not Allow Hanging Punctuation With Character Grid: CT_CompatSetting and CT_PPr preserve punctuation wrapping behavior.
/// §14.8.3.20 Footnotelayoutlikeww8 Ignore Page Break From Continuous Section Break: CT_CompatSetting and EG_FtnEdnNumProps preserve legacy footnote layout behavior.
/// §14.8.3.22 Growautofit Allow Tables To Autofit Into Page Margins: CT_CompatSetting, CT_TblLayoutType, and CT_TblPr preserve table autofit behavior.
/// §14.8.3.24 Layouttablerowsapart Allow Table Rows To Wrap Inline Objects Independently: CT_CompatSetting, CT_Row, and CT_TblPPr preserve independent row wrapping behavior.
/// §14.8.3.25 Linewraplikeword6 Ignore Compression Of Full Width Punctuation Ending A Line: CT_CompatSetting and CT_PPr preserve legacy line-wrapping behavior.
/// §14.8.3.26 Mwsmallcaps Use Specific Small Caps Algorithm: CT_CompatSetting and EG_RPr preserve small-caps compatibility behavior.
/// §14.8.3.27 Nocolumnbalance Do Not Balance Text Columns Within A Section: CT_CompatSetting and EG_SectPrContents preserve unbalanced section columns.
/// §14.8.3.30 Nospaceraiselower Do Not Increase Line Height For Raised Lowered Text: CT_CompatSetting and EG_RPr preserve raised/lowered text line-height behavior.
/// §14.8.3.31 Notabhangind Do Not Create Custom Tab Stop For Hanging Indent: CT_CompatSetting and CT_Ind preserve hanging-indent tab behavior.
/// §14.8.3.33 Printcolblack Print Colors As Black And White Without Dithering: CT_CompatSetting and CT_Settings preserve black-and-white print compatibility.
/// §14.8.3.34 Selectfldwithfirstorlastchar Select Field When First Or Last Character Is Select: CT_CompatSetting, CT_SimpleField, and CT_FldChar preserve field-selection behavior.
/// §14.8.3.35 Shapelayoutlikeww8 Ignore Text Wrapping Around Objects At Bottom Of Page: CT_CompatSetting, CT_Anchor, and EG_WrapType preserve legacy floating-shape layout behavior.
/// §14.8.3.36 Showbreaksinframes Display Page Column Breaks Present In Frames: CT_CompatSetting, CT_Frame, and CT_FramePr preserve frame break display behavior.
/// §14.8.3.37 Spacinginwholepoints Only Expand Condense Text By Whole Points: CT_CompatSetting and CT_CharacterSpacing preserve whole-point character spacing.
/// §14.8.3.39 Subfontbysize Require Exact Size During Font Substitution: CT_CompatSetting and CT_FontsList preserve exact-size font substitution behavior.
/// §14.8.3.42 Suppressspbfafterpgbrk Do Not Use Space Before On First Line After A Page Break: CT_CompatSetting and CT_PPr preserve page-break paragraph spacing behavior.
/// §14.8.3.44 Suppresstopspacingwp Use Static Text Leading: CT_CompatSetting and CT_PPr preserve static text-leading behavior.
/// §14.8.3.45 Swapbordersfacingpages Swap Paragraph Borders On Odd Numbered Pages: CT_CompatSetting and CT_Border preserve facing-page paragraph border swapping.
/// §14.8.3.46 Truncatefontheightslikewp6 Use Truncated Integer Division For Font Calculation: CT_CompatSetting and CT_Fonts preserve font-height truncation behavior.
/// §14.8.3.49 Useansikerningpairs Use Ansi Kerning Pairs From Fonts: CT_CompatSetting and CT_Font preserve ANSI kerning pair behavior.
/// §14.8.3.52 Useprintermetrics Use Printer Metrics To Display Documents: CT_CompatSetting and CT_Settings preserve printer-metric display behavior.
/// §14.8.3.53 Usesingleborderforcontiguouscells Use Simplified Rules For Table Border Conflict: CT_CompatSetting, CT_TblBorders, and CT_Border preserve contiguous-cell border rules.
/// §14.8.3.54 Useword2002Tablestylerules Incorrectly Display Top Border Of Conditional Columns: CT_CompatSetting, CT_TblLook, and CT_Cnf preserve Word 2002 table-style border behavior.
/// §14.8.3.56 Wpjustification Fit To Expanded Width When Performing Full Justification: CT_CompatSetting and ST_Jc preserve WordPerfect full-justification behavior.
/// §14.8.3.57 Wpspacewidth Use Specific Space Width: CT_CompatSetting and CT_CharacterSpacing preserve WordPerfect space-width behavior.
/// §14.8.3.58 Wraptrailspaces Line Wrap Trailing Spaces: CT_CompatSetting and CT_PPr preserve trailing-space line wrapping.
/// §14.8.4 Web Page Settings: CT_WebSettings, CT_Frame, CT_Frameset, CT_Div, and CT_OptimizeForBrowser represent web-page settings.
/// §14.8.4.1 Relyonvml Utilize Vml When Saving As Web Page: CT_WebSettings and CT_OptimizeForBrowser preserve VML use during web-page save.
/// §14.9 Miscellaneous Topics: CT_R, CT_P, EG_BlockLevelChunkElts, and EG_RunLevelElts preserve text boxes, alternate chunks, objects, and subdocuments.
/// §14.10 Fields And Hyperlinks: CT_SimpleField, CT_FldChar, CT_Hyperlink, CT_FFData, and EG_RunInnerContent model legacy fields and hyperlinks.
/// §14.10.1 Syntax: CT_SimpleField, CT_FldChar, and CT_R preserve field syntax as simple or complex run content.
/// §14.10.2 Legacy Language References: CT_SimpleField and CT_R preserve legacy field language references in run content.
/// §14.10.3 Use Of Dos File Paths: CT_Hyperlink and CT_SimpleField preserve DOS-style paths used by field targets.
/// §14.10.4 Field Definitions: CT_SimpleField, CT_FldChar, and CT_FFData preserve field definitions and form-field data.
/// §14.10.4.1 Autonum: CT_SimpleField and CT_R preserve AUTONUM fields in run content.
/// §14.10.4.3 Autonumout: CT_SimpleField and CT_R preserve AUTONUMOUT fields in run content.
/// §14.10.4.4 Barcode: CT_SimpleField and CT_R preserve BARCODE fields in run content.
/// §14.10.4.6 Eq: CT_SimpleField and CT_R preserve EQ fields in run content.
/// §14.10.4.7 Info: CT_SimpleField and CT_R preserve INFO fields in run content.
/// §14.10.4.8 Quote: CT_SimpleField and CT_R preserve QUOTE fields in run content.
/// §14.11 Simple Types: ST_Cnf, ST_TextScaleDecimal, ST_Jc, ST_JcTable, ST_TabJc, and ST_BrType preserve Part 4 lexical additions.
/// §14.11.2 Additional Enumeration Values For St Jc Part 1 17 18 44: ST_Jc preserves additional paragraph justification values.
/// §14.11.3 Additional Enumeration Values For St Jctable Part 1 17 18 45: ST_JcTable preserves additional table justification values.
/// §14.11.6 Additional Enumeration Values For St Tabjc Part 1 17 18 84: ST_TabJc preserves additional tab justification values.
/// §14.11.8 Additional Member Types For The Union In St Textscale Part 1 17 18 95: ST_TextScale and ST_TextScaleDecimal preserve decimal text-scale values.
/// §14.11.9 St Cnf Conditional Formatting Bitmask: ST_Cnf and CT_Cnf preserve conditional-format bitmask values.
/// §14.11.12 Changed Enumeration Value For St Brtype Part 1 17 18 4: ST_BrType preserves the changed break-type enumeration value.
/// §14.12 Changed Attributes: CT_Document and CT_* parse/to_element methods preserve changed relationship attributes on transitional elements.
/// §14.12.1 General: CT_* and ST_* wrappers preserve changed WordprocessingML attributes for round-trip serialization.
/// §14.12.2 Changed Attribute For Contentpart Element Part 1 17 3 3 2: CT_R and EG_RunLevelElts preserve content part relationship attributes.
/// §14.12.3 Changed Attribute For Control Element Part 1 17 3 3 3: CT_R and CT_Control preserve embedded-control relationship attributes.
/// §14.12.4 Changed Attribute For Movie Element Part 1 17 3 3 17: CT_R and EG_RunInnerContent preserve movie relationship attributes.
/// §14.12.5 Changed Attribute For Objectembed Element Part 1 17 3 3 20: CT_R and CT_Object preserve embedded-object relationship attributes.
/// §14.12.6 Changed Attribute For Objectlink Element Part 1 17 3 3 21: CT_R and CT_Object preserve linked-object relationship attributes.
/// §14.12.7 Changed Attribute For Bottom Element Part 1 17 6 2: EG_SectPrContents and CT_SectPr preserve bottom page-margin attributes.
/// §14.12.8 Changed Attribute For Left Element Part 1 17 6 7: EG_SectPrContents and CT_SectPr preserve left page-margin attributes.
/// §14.12.9 Changed Attribute For Printersettings Element Part 1 17 6 14: CT_Settings and CT_SectPr preserve printer-settings relationship attributes.
/// §14.12.10 Changed Attribute For Right Element Part 1 17 6 15: EG_SectPrContents and CT_SectPr preserve right page-margin attributes.
/// §14.12.11 Changed Attribute For Top Element Part 1 17 6 21: EG_SectPrContents and CT_SectPr preserve top page-margin attributes.
/// §14.12.12 Changed Attribute For Embedbold Element Part 1 17 8 3 3: CT_FontRel and CT_Font preserve embedded bold font relationships.
/// §14.12.13 Changed Attribute For Embedbolditalic Element Part 1 17 8 3 4: CT_FontRel and CT_Font preserve embedded bold-italic font relationships.
/// §14.12.14 Changed Attribute For Embeditalic Element Part 1 17 8 3 5: CT_FontRel and CT_Font preserve embedded italic font relationships.
/// §14.12.15 Changed Attribute For Embedregular Element Part 1 17 8 3 6: CT_FontRel and CT_Font preserve embedded regular font relationships.
/// §14.12.16 Changed Attribute For Footerreference Element Part 1 17 10 2: CT_HdrFtrRef and EG_HdrFtrReferences preserve footer relationship attributes.
/// §14.12.17 Changed Attribute For Headerreference Element Part 1 17 10 5: CT_HdrFtrRef and EG_HdrFtrReferences preserve header relationship attributes.
/// §14.12.18 Changed Attribute For Datasource Element Part 1 17 14 9: CT_MailMerge and CT_Odso preserve mail-merge data-source relationships.
/// §14.12.19 Changed Attribute For Headersource Element Part 1 17 14 16: CT_MailMerge and CT_Odso preserve mail-merge header-source relationships.
/// §14.12.21 Changed Attribute For Src Element Part 1 17 14 30: CT_MailMerge and CT_Odso preserve mail-merge source relationships.
/// §14.12.22 Changed Attribute For Attachedtemplate Element Part 1 17 15 1 6: CT_Settings preserves attached-template relationship attributes.
/// §14.12.23 Changed Attribute For Savethroughxslt Element Part 1 17 15 1 76: CT_SaveThroughXslt and CT_Settings preserve save-through-XSLT relationship attributes.
/// §14.12.24 Changed Attribute For Longdesc Element Part 1 17 15 2 23: CT_WebSettings preserves long-description relationship attributes.
/// §14.12.25 Changed Attribute For Sourcefilename Element Part 1 17 15 2 39: CT_WebSettings preserves source-file-name relationship attributes.
/// §14.12.26 Changed Attribute For Subdoc Element Part 1 17 17 1 1: CT_R, CT_P, and EG_BlockLevelChunkElts preserve subdocument relationship attributes.
/// §14.12.27 Changed Attribute For Altchunk Element Part 1 17 17 2 1: CT_P, CT_R, and EG_BlockLevelChunkElts preserve alternate-chunk relationship attributes.
/// XSD complex type CT_Anchor: CT_Anchor and CT_Anchor::parse/to_element represent positioned word-processing drawing anchors.
/// XSD simple type ST_HorizontalAnchor: ST_HorizontalAnchor represents horizontal anchor lexical values for word-processing drawings.
/// XSD simple type ST_VerticalAnchor: ST_VerticalAnchor represents vertical anchor lexical values for word-processing drawings.
/// Schema wml.xsd: CT_*, ST_*, EG_*, and AG_* wrappers represent the WordprocessingML schema surface exposed by this package.
/// XSD complex type CT_Border: CT_Border and CT_Border::parse/to_element represent border elements and their attributes.
/// XSD complex type CT_Cnf: CT_Cnf and ST_Cnf represent conditional-format structures and bitmasks.
/// XSD complex type CT_Div: CT_Div and CT_Divs represent web-page div settings.
/// XSD complex type CT_FFData: CT_FFData represents form-field data for field content.
/// XSD complex type CT_Font: CT_Font and CT_FontsList represent font-table entries.
/// XSD complex type CT_Frame: CT_Frame and CT_Frameset represent frameset frame definitions.
/// XSD complex type CT_Ind: CT_Ind represents paragraph indentation settings.
/// XSD complex type CT_Lvl: CT_Lvl and CT_LvlLegacy represent numbering levels.
/// XSD complex type CT_Num: CT_Num and CT_Numbering represent numbering instances.
/// XSD complex type CT_NumFmt: CT_NumFmt represents numbering format settings.
/// XSD complex type CT_PPrBase: CT_PPrBase and CT_PPr represent paragraph property bases.
/// XSD complex type CT_Row: CT_Row and CT_Tbl represent table rows.
/// XSD complex type CT_SdtPr: CT_SdtPr represents structured document tag properties.
/// XSD complex type CT_Shd: CT_Shd represents shading properties.
/// XSD complex type CT_TblPPr: CT_TblPPr represents floating table positioning properties.
/// §11 Errors: this package raises SchemaViolation for §4 XSD violations;
/// ResourceMissing is propagated from the OPC layer (`src/ecma376/opc`)
/// when a relationship target referenced by a document part cannot be
/// resolved.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml"
}

///|
/// ECMA-376 Part 1 §11.2 Package Structure
/// Source: references/spec/part1/sections/11.2__package-structure.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_11_2_package_structure_section_name() -> String {
  "ECMA-376 Part 1 §11.2 Package Structure"
}

///|
/// ECMA-376 Part 1 §11.3 Part Summary
/// Source: references/spec/part1/sections/11.3__part-summary.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_11_3_part_summary_section_name() -> String {
  "ECMA-376 Part 1 §11.3 Part Summary"
}

///|
/// ECMA-376 Part 1 §11.4 Document Template
/// Source: references/spec/part1/sections/11.4__document-template.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_11_4_document_template_section_name() -> String {
  "ECMA-376 Part 1 §11.4 Document Template"
}

///|
/// ECMA-376 Part 1 §11.5 Framesets
/// Source: references/spec/part1/sections/11.5__framesets.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_11_5_framesets_section_name() -> String {
  "ECMA-376 Part 1 §11.5 Framesets"
}

///|
/// ECMA-376 Part 1 §11.6 Master Documents And Subdocuments
/// Source: references/spec/part1/sections/11.6__master-documents-and-subdocuments.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_11_6_master_documents_and_subdocuments_section_name() -> String {
  "ECMA-376 Part 1 §11.6 Master Documents And Subdocuments"
}

///|
/// ECMA-376 Part 1 §11.9 Xsl Transformation
/// Source: references/spec/part1/sections/11.9__xsl-transformation.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_11_9_xsl_transformation_section_name() -> String {
  "ECMA-376 Part 1 §11.9 Xsl Transformation"
}

///|
/// ECMA-376 Part 1 §17.1 Table Of Contents
/// Source: references/spec/part1/sections/17.1__table-of-contents.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_17_1_table_of_contents_section_name() -> String {
  "ECMA-376 Part 1 §17.1 Table Of Contents"
}

///|
/// ECMA-376 Part 1 §17.3 Paragraphs And Rich Formatting
/// Source: references/spec/part1/sections/17.3__paragraphs-and-rich-formatting.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_17_3_paragraphs_and_rich_formatting_section_name() -> String {
  "ECMA-376 Part 1 §17.3 Paragraphs And Rich Formatting"
}

///|
/// ECMA-376 Part 1 §17.8 Fonts
/// Source: references/spec/part1/sections/17.8__fonts.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_17_8_fonts_section_name() -> String {
  "ECMA-376 Part 1 §17.8 Fonts"
}

///|
/// ECMA-376 Part 1 §17.10 Headers And Footers
/// Source: references/spec/part1/sections/17.10__headers-and-footers.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_17_10_headers_and_footers_section_name() -> String {
  "ECMA-376 Part 1 §17.10 Headers And Footers"
}

///|
/// ECMA-376 Part 1 §17.13 Annotations
/// Source: references/spec/part1/sections/17.13__annotations.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_17_13_annotations_section_name() -> String {
  "ECMA-376 Part 1 §17.13 Annotations"
}

///|
/// ECMA-376 Part 1 §17.15 Settings
/// Source: references/spec/part1/sections/17.15__settings.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_17_15_settings_section_name() -> String {
  "ECMA-376 Part 1 §17.15 Settings"
}

///|
/// ECMA-376 Part 1 §17.16 Fields And Hyperlinks
/// Source: references/spec/part1/sections/17.16__fields-and-hyperlinks.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_17_16_fields_and_hyperlinks_section_name() -> String {
  "ECMA-376 Part 1 §17.16 Fields And Hyperlinks"
}

///|
/// ECMA-376 Part 1 §17.17 Miscellaneous Topics
/// Source: references/spec/part1/sections/17.17__miscellaneous-topics.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_17_17_miscellaneous_topics_section_name() -> String {
  "ECMA-376 Part 1 §17.17 Miscellaneous Topics"
}

///|
/// ECMA-376 Part 1 §17.18 Simple Types
/// Source: references/spec/part1/sections/17.18__simple-types.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part1_17_18_simple_types_section_name() -> String {
  "ECMA-376 Part 1 §17.18 Simple Types"
}

///|
/// ECMA-376 Part 4 §14.1 General
/// Source: references/spec/part4/sections/14.1__general.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_1_general_section_name() -> String {
  "ECMA-376 Part 4 §14.1 General"
}

///|
/// ECMA-376 Part 4 §14.2 Table Of Contents
/// Source: references/spec/part4/sections/14.2__table-of-contents.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_2_table_of_contents_section_name() -> String {
  "ECMA-376 Part 4 §14.2 Table Of Contents"
}

///|
/// ECMA-376 Part 4 §14.3 Paragraphs And Rich Formatting
/// Source: references/spec/part4/sections/14.3__paragraphs-and-rich-formatting.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_3_paragraphs_and_rich_formatting_section_name() -> String {
  "ECMA-376 Part 4 §14.3 Paragraphs And Rich Formatting"
}

///|
/// ECMA-376 Part 4 §14.3.1 Paragraphs
/// Source: references/spec/part4/sections/14.3.1__paragraphs.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_3_1_paragraphs_section_name() -> String {
  "ECMA-376 Part 4 §14.3.1 Paragraphs"
}

///|
/// ECMA-376 Part 4 §14.3.1.1 Additional Attribute For Cnfstyle Element Part 1 17 3 1 8
/// Source: references/spec/part4/sections/14.3.1.1__additional-attribute-for-cnfstyle-element-part-1-17-3-1-8.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_3_1_1_additional_attribute_for_cnfstyle_element_part_1_17_3_1_8_section_name() -> String {
  "ECMA-376 Part 4 §14.3.1.1 Additional Attribute For Cnfstyle Element Part 1 17 3 1 8"
}

///|
/// ECMA-376 Part 4 §14.3.1.2 Additional Attributes For Ind Element Part 1 17 3 1 12
/// Source: references/spec/part4/sections/14.3.1.2__additional-attributes-for-ind-element-part-1-17-3-1-12.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_3_1_2_additional_attributes_for_ind_element_part_1_17_3_1_12_section_name() -> String {
  "ECMA-376 Part 4 §14.3.1.2 Additional Attributes For Ind Element Part 1 17 3 1 12"
}

///|
/// ECMA-376 Part 4 §14.4 Tables
/// Source: references/spec/part4/sections/14.4__tables.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_tables_section_name() -> String {
  "ECMA-376 Part 4 §14.4 Tables"
}

///|
/// ECMA-376 Part 4 §14.4.1 Left Table Cell Leading Edge Border
/// Source: references/spec/part4/sections/14.4.1__left-table-cell-leading-edge-border.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_1_left_table_cell_leading_edge_border_section_name() -> String {
  "ECMA-376 Part 4 §14.4.1 Left Table Cell Leading Edge Border"
}

///|
/// ECMA-376 Part 4 §14.4.2 Left Table Leading Edge Border
/// Source: references/spec/part4/sections/14.4.2__left-table-leading-edge-border.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_2_left_table_leading_edge_border_section_name() -> String {
  "ECMA-376 Part 4 §14.4.2 Left Table Leading Edge Border"
}

///|
/// ECMA-376 Part 4 §14.4.3 Left Table Cell Leading Margin Exception
/// Source: references/spec/part4/sections/14.4.3__left-table-cell-leading-margin-exception.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_3_left_table_cell_leading_margin_exception_section_name() -> String {
  "ECMA-376 Part 4 §14.4.3 Left Table Cell Leading Margin Exception"
}

///|
/// ECMA-376 Part 4 §14.4.4 Left Table Cell Leading Margin Default
/// Source: references/spec/part4/sections/14.4.4__left-table-cell-leading-margin-default.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_4_left_table_cell_leading_margin_default_section_name() -> String {
  "ECMA-376 Part 4 §14.4.4 Left Table Cell Leading Margin Default"
}

///|
/// ECMA-376 Part 4 §14.4.5 Right Table Cell Trailing Edge Border
/// Source: references/spec/part4/sections/14.4.5__right-table-cell-trailing-edge-border.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_5_right_table_cell_trailing_edge_border_section_name() -> String {
  "ECMA-376 Part 4 §14.4.5 Right Table Cell Trailing Edge Border"
}

///|
/// ECMA-376 Part 4 §14.4.6 Right Table Trailing Edge Border
/// Source: references/spec/part4/sections/14.4.6__right-table-trailing-edge-border.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_6_right_table_trailing_edge_border_section_name() -> String {
  "ECMA-376 Part 4 §14.4.6 Right Table Trailing Edge Border"
}

///|
/// ECMA-376 Part 4 §14.4.7 Right Table Cell Trailing Margin Default
/// Source: references/spec/part4/sections/14.4.7__right-table-cell-trailing-margin-default.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_7_right_table_cell_trailing_margin_default_section_name() -> String {
  "ECMA-376 Part 4 §14.4.7 Right Table Cell Trailing Margin Default"
}

///|
/// ECMA-376 Part 4 §14.4.8 Right Table Cell Trailing Margin Exception
/// Source: references/spec/part4/sections/14.4.8__right-table-cell-trailing-margin-exception.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_8_right_table_cell_trailing_margin_exception_section_name() -> String {
  "ECMA-376 Part 4 §14.4.8 Right Table Cell Trailing Margin Exception"
}

///|
/// ECMA-376 Part 4 §14.4.9 Additional Attribute For Cnfstyle Element Part 1 17 4 7
/// Source: references/spec/part4/sections/14.4.9__additional-attribute-for-cnfstyle-element-part-1-17-4-7.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_9_additional_attribute_for_cnfstyle_element_part_1_17_4_7_section_name() -> String {
  "ECMA-376 Part 4 §14.4.9 Additional Attribute For Cnfstyle Element Part 1 17 4 7"
}

///|
/// ECMA-376 Part 4 §14.4.10 Additional Attribute For Cnfstyle Element Part 1 17 4 8
/// Source: references/spec/part4/sections/14.4.10__additional-attribute-for-cnfstyle-element-part-1-17-4-8.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_10_additional_attribute_for_cnfstyle_element_part_1_17_4_8_section_name() -> String {
  "ECMA-376 Part 4 §14.4.10 Additional Attribute For Cnfstyle Element Part 1 17 4 8"
}

///|
/// ECMA-376 Part 4 §14.4.11 Additional Attribute For Tbllook Element Part 1 17 4 54
/// Source: references/spec/part4/sections/14.4.11__additional-attribute-for-tbllook-element-part-1-17-4-54.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_11_additional_attribute_for_tbllook_element_part_1_17_4_54_section_name() -> String {
  "ECMA-376 Part 4 §14.4.11 Additional Attribute For Tbllook Element Part 1 17 4 54"
}

///|
/// ECMA-376 Part 4 §14.4.12 Additional Attribute For Tbllook Element Part 1 17 4 55
/// Source: references/spec/part4/sections/14.4.12__additional-attribute-for-tbllook-element-part-1-17-4-55.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_12_additional_attribute_for_tbllook_element_part_1_17_4_55_section_name() -> String {
  "ECMA-376 Part 4 §14.4.12 Additional Attribute For Tbllook Element Part 1 17 4 55"
}

///|
/// ECMA-376 Part 4 §14.4.13 Hmerge Horizontally Merged Cell
/// Source: references/spec/part4/sections/14.4.13__hmerge-horizontally-merged-cell.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_4_13_hmerge_horizontally_merged_cell_section_name() -> String {
  "ECMA-376 Part 4 §14.4.13 Hmerge Horizontally Merged Cell"
}

///|
/// ECMA-376 Part 4 §14.5 Fonts
/// Source: references/spec/part4/sections/14.5__fonts.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_5_fonts_section_name() -> String {
  "ECMA-376 Part 4 §14.5 Fonts"
}

///|
/// ECMA-376 Part 4 §14.5.1 Elements
/// Source: references/spec/part4/sections/14.5.1__elements.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_5_1_elements_section_name() -> String {
  "ECMA-376 Part 4 §14.5.1 Elements"
}

///|
/// ECMA-376 Part 4 §14.5.1.1 Additional Attribute For Charset Element Part 1 17 8 3 2
/// Source: references/spec/part4/sections/14.5.1.1__additional-attribute-for-charset-element-part-1-17-8-3-2.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_5_1_1_additional_attribute_for_charset_element_part_1_17_8_3_2_section_name() -> String {
  "ECMA-376 Part 4 §14.5.1.1 Additional Attribute For Charset Element Part 1 17 8 3 2"
}

///|
/// ECMA-376 Part 4 §14.6.2 Legacy Legacy Numbering Level Properties
/// Source: references/spec/part4/sections/14.6.2__legacy-legacy-numbering-level-properties.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_6_2_legacy_legacy_numbering_level_properties_section_name() -> String {
  "ECMA-376 Part 4 §14.6.2 Legacy Legacy Numbering Level Properties"
}

///|
/// ECMA-376 Part 4 §14.7.1 Revisions
/// Source: references/spec/part4/sections/14.7.1__revisions.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_7_1_revisions_section_name() -> String {
  "ECMA-376 Part 4 §14.7.1 Revisions"
}

///|
/// ECMA-376 Part 4 §14.8 Settings
/// Source: references/spec/part4/sections/14.8__settings.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_settings_section_name() -> String {
  "ECMA-376 Part 4 §14.8 Settings"
}

///|
/// ECMA-376 Part 4 §14.8.2 Document Settings
/// Source: references/spec/part4/sections/14.8.2__document-settings.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_2_document_settings_section_name() -> String {
  "ECMA-376 Part 4 §14.8.2 Document Settings"
}

///|
/// ECMA-376 Part 4 §14.8.2.4 Additional Attribute For Stylepaneformatfilter Element Part 1 17 15 1 85
/// Source: references/spec/part4/sections/14.8.2.4__additional-attribute-for-stylepaneformatfilter-element-part-1-17-15-1-85.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_2_4_additional_attribute_for_stylepaneformatfilter_element_part_1_17_15_1_85_section_name() -> String {
  "ECMA-376 Part 4 §14.8.2.4 Additional Attribute For Stylepaneformatfilter Element Part 1 17 15 1 85"
}

///|
/// ECMA-376 Part 4 §14.8.3 Compatibility Settings
/// Source: references/spec/part4/sections/14.8.3__compatibility-settings.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_compatibility_settings_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3 Compatibility Settings"
}

///|
/// ECMA-376 Part 4 §14.8.3.1 Aligntablesrowbyrow Align Table Rows Independently
/// Source: references/spec/part4/sections/14.8.3.1__aligntablesrowbyrow-align-table-rows-independently.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_1_aligntablesrowbyrow_align_table_rows_independently_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.1 Aligntablesrowbyrow Align Table Rows Independently"
}

///|
/// ECMA-376 Part 4 §14.8.3.2 Allowspaceofsamestyleintable Allow Contextual Spacing Of Paragraphs In Tables
/// Source: references/spec/part4/sections/14.8.3.2__allowspaceofsamestyleintable-allow-contextual-spacing-of-paragraphs-in-tables.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_2_allowspaceofsamestyleintable_allow_contextual_spacing_of_paragraphs_in_tables_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.2 Allowspaceofsamestyleintable Allow Contextual Spacing Of Paragraphs In Tables"
}

///|
/// ECMA-376 Part 4 §14.8.3.5 Cachedcolbalance Use Cached Paragraph Information For Column Balancing
/// Source: references/spec/part4/sections/14.8.3.5__cachedcolbalance-use-cached-paragraph-information-for-column-balancing.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_5_cachedcolbalance_use_cached_paragraph_information_for_column_balancing_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.5 Cachedcolbalance Use Cached Paragraph Information For Column Balancing"
}

///|
/// ECMA-376 Part 4 §14.8.3.6 Convmailmergeesc Treat Backslash Quotation Delimiter As Two Quotation Marks
/// Source: references/spec/part4/sections/14.8.3.6__convmailmergeesc-treat-backslash-quotation-delimiter-as-two-quotation-marks.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_6_convmailmergeesc_treat_backslash_quotation_delimiter_as_two_quotation_marks_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.6 Convmailmergeesc Treat Backslash Quotation Delimiter As Two Quotation Marks"
}

///|
/// ECMA-376 Part 4 §14.8.3.7 Displayhangulfixedwidth Always Use Fixed Width For Hangul Characters
/// Source: references/spec/part4/sections/14.8.3.7__displayhangulfixedwidth-always-use-fixed-width-for-hangul-characters.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_7_displayhangulfixedwidth_always_use_fixed_width_for_hangul_characters_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.7 Displayhangulfixedwidth Always Use Fixed Width For Hangul Characters"
}

///|
/// ECMA-376 Part 4 §14.8.3.10 Donotbreakwrappedtables Do Not Allow Floating Tables To Break Across Pages
/// Source: references/spec/part4/sections/14.8.3.10__donotbreakwrappedtables-do-not-allow-floating-tables-to-break-across-pages.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_10_donotbreakwrappedtables_do_not_allow_floating_tables_to_break_across_pages_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.10 Donotbreakwrappedtables Do Not Allow Floating Tables To Break Across Pages"
}

///|
/// ECMA-376 Part 4 §14.8.3.11 Donotsnaptogridincell Do Not Snap To Document Grid In Table Cells With Objects
/// Source: references/spec/part4/sections/14.8.3.11__donotsnaptogridincell-do-not-snap-to-document-grid-in-table-cells-with-objects.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_11_donotsnaptogridincell_do_not_snap_to_document_grid_in_table_cells_with_objects_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.11 Donotsnaptogridincell Do Not Snap To Document Grid In Table Cells With Objects"
}

///|
/// ECMA-376 Part 4 §14.8.3.13 Donotsuppressparagraphborders Do Not Suppress Paragraph Borders Next To Frames
/// Source: references/spec/part4/sections/14.8.3.13__donotsuppressparagraphborders-do-not-suppress-paragraph-borders-next-to-frames.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_13_donotsuppressparagraphborders_do_not_suppress_paragraph_borders_next_to_frames_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.13 Donotsuppressparagraphborders Do Not Suppress Paragraph Borders Next To Frames"
}

///|
/// ECMA-376 Part 4 §14.8.3.19 Donotwraptextwithpunct Do Not Allow Hanging Punctuation With Character Grid
/// Source: references/spec/part4/sections/14.8.3.19__donotwraptextwithpunct-do-not-allow-hanging-punctuation-with-character-grid.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_19_donotwraptextwithpunct_do_not_allow_hanging_punctuation_with_character_grid_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.19 Donotwraptextwithpunct Do Not Allow Hanging Punctuation With Character Grid"
}

///|
/// ECMA-376 Part 4 §14.8.3.20 Footnotelayoutlikeww8 Ignore Page Break From Continuous Section Break
/// Source: references/spec/part4/sections/14.8.3.20__footnotelayoutlikeww8-ignore-page-break-from-continuous-section-break.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_20_footnotelayoutlikeww8_ignore_page_break_from_continuous_section_break_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.20 Footnotelayoutlikeww8 Ignore Page Break From Continuous Section Break"
}

///|
/// ECMA-376 Part 4 §14.8.3.22 Growautofit Allow Tables To Autofit Into Page Margins
/// Source: references/spec/part4/sections/14.8.3.22__growautofit-allow-tables-to-autofit-into-page-margins.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_22_growautofit_allow_tables_to_autofit_into_page_margins_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.22 Growautofit Allow Tables To Autofit Into Page Margins"
}

///|
/// ECMA-376 Part 4 §14.8.3.24 Layouttablerowsapart Allow Table Rows To Wrap Inline Objects Independently
/// Source: references/spec/part4/sections/14.8.3.24__layouttablerowsapart-allow-table-rows-to-wrap-inline-objects-independently.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_24_layouttablerowsapart_allow_table_rows_to_wrap_inline_objects_independently_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.24 Layouttablerowsapart Allow Table Rows To Wrap Inline Objects Independently"
}

///|
/// ECMA-376 Part 4 §14.8.3.25 Linewraplikeword6 Ignore Compression Of Full Width Punctuation Ending A Line
/// Source: references/spec/part4/sections/14.8.3.25__linewraplikeword6-ignore-compression-of-full-width-punctuation-ending-a-line.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_25_linewraplikeword6_ignore_compression_of_full_width_punctuation_ending_a_line_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.25 Linewraplikeword6 Ignore Compression Of Full Width Punctuation Ending A Line"
}

///|
/// ECMA-376 Part 4 §14.8.3.26 Mwsmallcaps Use Specific Small Caps Algorithm
/// Source: references/spec/part4/sections/14.8.3.26__mwsmallcaps-use-specific-small-caps-algorithm.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_26_mwsmallcaps_use_specific_small_caps_algorithm_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.26 Mwsmallcaps Use Specific Small Caps Algorithm"
}

///|
/// ECMA-376 Part 4 §14.8.3.27 Nocolumnbalance Do Not Balance Text Columns Within A Section
/// Source: references/spec/part4/sections/14.8.3.27__nocolumnbalance-do-not-balance-text-columns-within-a-section.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_27_nocolumnbalance_do_not_balance_text_columns_within_a_section_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.27 Nocolumnbalance Do Not Balance Text Columns Within A Section"
}

///|
/// ECMA-376 Part 4 §14.8.3.30 Nospaceraiselower Do Not Increase Line Height For Raised Lowered Text
/// Source: references/spec/part4/sections/14.8.3.30__nospaceraiselower-do-not-increase-line-height-for-raised-lowered-text.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_30_nospaceraiselower_do_not_increase_line_height_for_raised_lowered_text_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.30 Nospaceraiselower Do Not Increase Line Height For Raised Lowered Text"
}

///|
/// ECMA-376 Part 4 §14.8.3.31 Notabhangind Do Not Create Custom Tab Stop For Hanging Indent
/// Source: references/spec/part4/sections/14.8.3.31__notabhangind-do-not-create-custom-tab-stop-for-hanging-indent.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_31_notabhangind_do_not_create_custom_tab_stop_for_hanging_indent_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.31 Notabhangind Do Not Create Custom Tab Stop For Hanging Indent"
}

///|
/// ECMA-376 Part 4 §14.8.3.33 Printcolblack Print Colors As Black And White Without Dithering
/// Source: references/spec/part4/sections/14.8.3.33__printcolblack-print-colors-as-black-and-white-without-dithering.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_33_printcolblack_print_colors_as_black_and_white_without_dithering_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.33 Printcolblack Print Colors As Black And White Without Dithering"
}

///|
/// ECMA-376 Part 4 §14.8.3.34 Selectfldwithfirstorlastchar Select Field When First Or Last Character Is Select
/// Source: references/spec/part4/sections/14.8.3.34__selectfldwithfirstorlastchar-select-field-when-first-or-last-character-is-select.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_34_selectfldwithfirstorlastchar_select_field_when_first_or_last_character_is_select_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.34 Selectfldwithfirstorlastchar Select Field When First Or Last Character Is Select"
}

///|
/// ECMA-376 Part 4 §14.8.3.35 Shapelayoutlikeww8 Ignore Text Wrapping Around Objects At Bottom Of Page
/// Source: references/spec/part4/sections/14.8.3.35__shapelayoutlikeww8-ignore-text-wrapping-around-objects-at-bottom-of-page.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_35_shapelayoutlikeww8_ignore_text_wrapping_around_objects_at_bottom_of_page_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.35 Shapelayoutlikeww8 Ignore Text Wrapping Around Objects At Bottom Of Page"
}

///|
/// ECMA-376 Part 4 §14.8.3.36 Showbreaksinframes Display Page Column Breaks Present In Frames
/// Source: references/spec/part4/sections/14.8.3.36__showbreaksinframes-display-page-column-breaks-present-in-frames.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_36_showbreaksinframes_display_page_column_breaks_present_in_frames_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.36 Showbreaksinframes Display Page Column Breaks Present In Frames"
}

///|
/// ECMA-376 Part 4 §14.8.3.37 Spacinginwholepoints Only Expand Condense Text By Whole Points
/// Source: references/spec/part4/sections/14.8.3.37__spacinginwholepoints-only-expand-condense-text-by-whole-points.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_37_spacinginwholepoints_only_expand_condense_text_by_whole_points_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.37 Spacinginwholepoints Only Expand Condense Text By Whole Points"
}

///|
/// ECMA-376 Part 4 §14.8.3.39 Subfontbysize Require Exact Size During Font Substitution
/// Source: references/spec/part4/sections/14.8.3.39__subfontbysize-require-exact-size-during-font-substitution.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_39_subfontbysize_require_exact_size_during_font_substitution_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.39 Subfontbysize Require Exact Size During Font Substitution"
}

///|
/// ECMA-376 Part 4 §14.8.3.42 Suppressspbfafterpgbrk Do Not Use Space Before On First Line After A Page Break
/// Source: references/spec/part4/sections/14.8.3.42__suppressspbfafterpgbrk-do-not-use-space-before-on-first-line-after-a-page-break.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_42_suppressspbfafterpgbrk_do_not_use_space_before_on_first_line_after_a_page_break_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.42 Suppressspbfafterpgbrk Do Not Use Space Before On First Line After A Page Break"
}

///|
/// ECMA-376 Part 4 §14.8.3.44 Suppresstopspacingwp Use Static Text Leading
/// Source: references/spec/part4/sections/14.8.3.44__suppresstopspacingwp-use-static-text-leading.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_44_suppresstopspacingwp_use_static_text_leading_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.44 Suppresstopspacingwp Use Static Text Leading"
}

///|
/// ECMA-376 Part 4 §14.8.3.45 Swapbordersfacingpages Swap Paragraph Borders On Odd Numbered Pages
/// Source: references/spec/part4/sections/14.8.3.45__swapbordersfacingpages-swap-paragraph-borders-on-odd-numbered-pages.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_45_swapbordersfacingpages_swap_paragraph_borders_on_odd_numbered_pages_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.45 Swapbordersfacingpages Swap Paragraph Borders On Odd Numbered Pages"
}

///|
/// ECMA-376 Part 4 §14.8.3.46 Truncatefontheightslikewp6 Use Truncated Integer Division For Font Calculation
/// Source: references/spec/part4/sections/14.8.3.46__truncatefontheightslikewp6-use-truncated-integer-division-for-font-calculation.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_46_truncatefontheightslikewp6_use_truncated_integer_division_for_font_calculation_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.46 Truncatefontheightslikewp6 Use Truncated Integer Division For Font Calculation"
}

///|
/// ECMA-376 Part 4 §14.8.3.49 Useansikerningpairs Use Ansi Kerning Pairs From Fonts
/// Source: references/spec/part4/sections/14.8.3.49__useansikerningpairs-use-ansi-kerning-pairs-from-fonts.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_49_useansikerningpairs_use_ansi_kerning_pairs_from_fonts_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.49 Useansikerningpairs Use Ansi Kerning Pairs From Fonts"
}

///|
/// ECMA-376 Part 4 §14.8.3.52 Useprintermetrics Use Printer Metrics To Display Documents
/// Source: references/spec/part4/sections/14.8.3.52__useprintermetrics-use-printer-metrics-to-display-documents.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_52_useprintermetrics_use_printer_metrics_to_display_documents_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.52 Useprintermetrics Use Printer Metrics To Display Documents"
}

///|
/// ECMA-376 Part 4 §14.8.3.53 Usesingleborderforcontiguouscells Use Simplified Rules For Table Border Conflict
/// Source: references/spec/part4/sections/14.8.3.53__usesingleborderforcontiguouscells-use-simplified-rules-for-table-border-conflict.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_53_usesingleborderforcontiguouscells_use_simplified_rules_for_table_border_conflict_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.53 Usesingleborderforcontiguouscells Use Simplified Rules For Table Border Conflict"
}

///|
/// ECMA-376 Part 4 §14.8.3.54 Useword2002Tablestylerules Incorrectly Display Top Border Of Conditional Columns
/// Source: references/spec/part4/sections/14.8.3.54__useword2002tablestylerules-incorrectly-display-top-border-of-conditional-columns.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_54_useword2002tablestylerules_incorrectly_display_top_border_of_conditional_columns_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.54 Useword2002Tablestylerules Incorrectly Display Top Border Of Conditional Columns"
}

///|
/// ECMA-376 Part 4 §14.8.3.56 Wpjustification Fit To Expanded Width When Performing Full Justification
/// Source: references/spec/part4/sections/14.8.3.56__wpjustification-fit-to-expanded-width-when-performing-full-justification.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_56_wpjustification_fit_to_expanded_width_when_performing_full_justification_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.56 Wpjustification Fit To Expanded Width When Performing Full Justification"
}

///|
/// ECMA-376 Part 4 §14.8.3.57 Wpspacewidth Use Specific Space Width
/// Source: references/spec/part4/sections/14.8.3.57__wpspacewidth-use-specific-space-width.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_57_wpspacewidth_use_specific_space_width_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.57 Wpspacewidth Use Specific Space Width"
}

///|
/// ECMA-376 Part 4 §14.8.3.58 Wraptrailspaces Line Wrap Trailing Spaces
/// Source: references/spec/part4/sections/14.8.3.58__wraptrailspaces-line-wrap-trailing-spaces.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_3_58_wraptrailspaces_line_wrap_trailing_spaces_section_name() -> String {
  "ECMA-376 Part 4 §14.8.3.58 Wraptrailspaces Line Wrap Trailing Spaces"
}

///|
/// ECMA-376 Part 4 §14.8.4 Web Page Settings
/// Source: references/spec/part4/sections/14.8.4__web-page-settings.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_4_web_page_settings_section_name() -> String {
  "ECMA-376 Part 4 §14.8.4 Web Page Settings"
}

///|
/// ECMA-376 Part 4 §14.8.4.1 Relyonvml Utilize Vml When Saving As Web Page
/// Source: references/spec/part4/sections/14.8.4.1__relyonvml-utilize-vml-when-saving-as-web-page.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_8_4_1_relyonvml_utilize_vml_when_saving_as_web_page_section_name() -> String {
  "ECMA-376 Part 4 §14.8.4.1 Relyonvml Utilize Vml When Saving As Web Page"
}

///|
/// ECMA-376 Part 4 §14.9 Miscellaneous Topics
/// Source: references/spec/part4/sections/14.9__miscellaneous-topics.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_9_miscellaneous_topics_section_name() -> String {
  "ECMA-376 Part 4 §14.9 Miscellaneous Topics"
}

///|
/// ECMA-376 Part 4 §14.10 Fields And Hyperlinks
/// Source: references/spec/part4/sections/14.10__fields-and-hyperlinks.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_fields_and_hyperlinks_section_name() -> String {
  "ECMA-376 Part 4 §14.10 Fields And Hyperlinks"
}

///|
/// ECMA-376 Part 4 §14.10.1 Syntax
/// Source: references/spec/part4/sections/14.10.1__syntax.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_1_syntax_section_name() -> String {
  "ECMA-376 Part 4 §14.10.1 Syntax"
}

///|
/// ECMA-376 Part 4 §14.10.2 Legacy Language References
/// Source: references/spec/part4/sections/14.10.2__legacy-language-references.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_2_legacy_language_references_section_name() -> String {
  "ECMA-376 Part 4 §14.10.2 Legacy Language References"
}

///|
/// ECMA-376 Part 4 §14.10.3 Use Of Dos File Paths
/// Source: references/spec/part4/sections/14.10.3__use-of-dos-file-paths.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_3_use_of_dos_file_paths_section_name() -> String {
  "ECMA-376 Part 4 §14.10.3 Use Of Dos File Paths"
}

///|
/// ECMA-376 Part 4 §14.10.4 Field Definitions
/// Source: references/spec/part4/sections/14.10.4__field-definitions.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_4_field_definitions_section_name() -> String {
  "ECMA-376 Part 4 §14.10.4 Field Definitions"
}

///|
/// ECMA-376 Part 4 §14.10.4.1 Autonum
/// Source: references/spec/part4/sections/14.10.4.1__autonum.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_4_1_autonum_section_name() -> String {
  "ECMA-376 Part 4 §14.10.4.1 Autonum"
}

///|
/// ECMA-376 Part 4 §14.10.4.3 Autonumout
/// Source: references/spec/part4/sections/14.10.4.3__autonumout.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_4_3_autonumout_section_name() -> String {
  "ECMA-376 Part 4 §14.10.4.3 Autonumout"
}

///|
/// ECMA-376 Part 4 §14.10.4.4 Barcode
/// Source: references/spec/part4/sections/14.10.4.4__barcode.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_4_4_barcode_section_name() -> String {
  "ECMA-376 Part 4 §14.10.4.4 Barcode"
}

///|
/// ECMA-376 Part 4 §14.10.4.6 Eq
/// Source: references/spec/part4/sections/14.10.4.6__eq.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_4_6_eq_section_name() -> String {
  "ECMA-376 Part 4 §14.10.4.6 Eq"
}

///|
/// ECMA-376 Part 4 §14.10.4.7 Info
/// Source: references/spec/part4/sections/14.10.4.7__info.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_4_7_info_section_name() -> String {
  "ECMA-376 Part 4 §14.10.4.7 Info"
}

///|
/// ECMA-376 Part 4 §14.10.4.8 Quote
/// Source: references/spec/part4/sections/14.10.4.8__quote.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_10_4_8_quote_section_name() -> String {
  "ECMA-376 Part 4 §14.10.4.8 Quote"
}

///|
/// ECMA-376 Part 4 §14.11 Simple Types
/// Source: references/spec/part4/sections/14.11__simple-types.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_11_simple_types_section_name() -> String {
  "ECMA-376 Part 4 §14.11 Simple Types"
}

///|
/// ECMA-376 Part 4 §14.11.2 Additional Enumeration Values For St Jc Part 1 17 18 44
/// Source: references/spec/part4/sections/14.11.2__additional-enumeration-values-for-st-jc-part-1-17-18-44.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_11_2_additional_enumeration_values_for_st_jc_part_1_17_18_44_section_name() -> String {
  "ECMA-376 Part 4 §14.11.2 Additional Enumeration Values For St Jc Part 1 17 18 44"
}

///|
/// ECMA-376 Part 4 §14.11.3 Additional Enumeration Values For St Jctable Part 1 17 18 45
/// Source: references/spec/part4/sections/14.11.3__additional-enumeration-values-for-st-jctable-part-1-17-18-45.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_11_3_additional_enumeration_values_for_st_jctable_part_1_17_18_45_section_name() -> String {
  "ECMA-376 Part 4 §14.11.3 Additional Enumeration Values For St Jctable Part 1 17 18 45"
}

///|
/// ECMA-376 Part 4 §14.11.6 Additional Enumeration Values For St Tabjc Part 1 17 18 84
/// Source: references/spec/part4/sections/14.11.6__additional-enumeration-values-for-st-tabjc-part-1-17-18-84.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_11_6_additional_enumeration_values_for_st_tabjc_part_1_17_18_84_section_name() -> String {
  "ECMA-376 Part 4 §14.11.6 Additional Enumeration Values For St Tabjc Part 1 17 18 84"
}

///|
/// ECMA-376 Part 4 §14.11.8 Additional Member Types For The Union In St Textscale Part 1 17 18 95
/// Source: references/spec/part4/sections/14.11.8__additional-member-types-for-the-union-in-st-textscale-part-1-17-18-95.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_11_8_additional_member_types_for_the_union_in_st_textscale_part_1_17_18_95_section_name() -> String {
  "ECMA-376 Part 4 §14.11.8 Additional Member Types For The Union In St Textscale Part 1 17 18 95"
}

///|
/// ECMA-376 Part 4 §14.11.9 St Cnf Conditional Formatting Bitmask
/// Source: references/spec/part4/sections/14.11.9__st-cnf-conditional-formatting-bitmask.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_11_9_st_cnf_conditional_formatting_bitmask_section_name() -> String {
  "ECMA-376 Part 4 §14.11.9 St Cnf Conditional Formatting Bitmask"
}

///|
/// ECMA-376 Part 4 §14.11.12 Changed Enumeration Value For St Brtype Part 1 17 18 4
/// Source: references/spec/part4/sections/14.11.12__changed-enumeration-value-for-st-brtype-part-1-17-18-4.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_11_12_changed_enumeration_value_for_st_brtype_part_1_17_18_4_section_name() -> String {
  "ECMA-376 Part 4 §14.11.12 Changed Enumeration Value For St Brtype Part 1 17 18 4"
}

///|
/// ECMA-376 Part 4 §14.12 Changed Attributes
/// Source: references/spec/part4/sections/14.12__changed-attributes.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_changed_attributes_section_name() -> String {
  "ECMA-376 Part 4 §14.12 Changed Attributes"
}

///|
/// ECMA-376 Part 4 §14.12.1 General
/// Source: references/spec/part4/sections/14.12.1__general.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_1_general_section_name() -> String {
  "ECMA-376 Part 4 §14.12.1 General"
}

///|
/// ECMA-376 Part 4 §14.12.2 Changed Attribute For Contentpart Element Part 1 17 3 3 2
/// Source: references/spec/part4/sections/14.12.2__changed-attribute-for-contentpart-element-part-1-17-3-3-2.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_2_changed_attribute_for_contentpart_element_part_1_17_3_3_2_section_name() -> String {
  "ECMA-376 Part 4 §14.12.2 Changed Attribute For Contentpart Element Part 1 17 3 3 2"
}

///|
/// ECMA-376 Part 4 §14.12.3 Changed Attribute For Control Element Part 1 17 3 3 3
/// Source: references/spec/part4/sections/14.12.3__changed-attribute-for-control-element-part-1-17-3-3-3.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_3_changed_attribute_for_control_element_part_1_17_3_3_3_section_name() -> String {
  "ECMA-376 Part 4 §14.12.3 Changed Attribute For Control Element Part 1 17 3 3 3"
}

///|
/// ECMA-376 Part 4 §14.12.4 Changed Attribute For Movie Element Part 1 17 3 3 17
/// Source: references/spec/part4/sections/14.12.4__changed-attribute-for-movie-element-part-1-17-3-3-17.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_4_changed_attribute_for_movie_element_part_1_17_3_3_17_section_name() -> String {
  "ECMA-376 Part 4 §14.12.4 Changed Attribute For Movie Element Part 1 17 3 3 17"
}

///|
/// ECMA-376 Part 4 §14.12.5 Changed Attribute For Objectembed Element Part 1 17 3 3 20
/// Source: references/spec/part4/sections/14.12.5__changed-attribute-for-objectembed-element-part-1-17-3-3-20.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_5_changed_attribute_for_objectembed_element_part_1_17_3_3_20_section_name() -> String {
  "ECMA-376 Part 4 §14.12.5 Changed Attribute For Objectembed Element Part 1 17 3 3 20"
}

///|
/// ECMA-376 Part 4 §14.12.6 Changed Attribute For Objectlink Element Part 1 17 3 3 21
/// Source: references/spec/part4/sections/14.12.6__changed-attribute-for-objectlink-element-part-1-17-3-3-21.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_6_changed_attribute_for_objectlink_element_part_1_17_3_3_21_section_name() -> String {
  "ECMA-376 Part 4 §14.12.6 Changed Attribute For Objectlink Element Part 1 17 3 3 21"
}

///|
/// ECMA-376 Part 4 §14.12.7 Changed Attribute For Bottom Element Part 1 17 6 2
/// Source: references/spec/part4/sections/14.12.7__changed-attribute-for-bottom-element-part-1-17-6-2.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_7_changed_attribute_for_bottom_element_part_1_17_6_2_section_name() -> String {
  "ECMA-376 Part 4 §14.12.7 Changed Attribute For Bottom Element Part 1 17 6 2"
}

///|
/// ECMA-376 Part 4 §14.12.8 Changed Attribute For Left Element Part 1 17 6 7
/// Source: references/spec/part4/sections/14.12.8__changed-attribute-for-left-element-part-1-17-6-7.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_8_changed_attribute_for_left_element_part_1_17_6_7_section_name() -> String {
  "ECMA-376 Part 4 §14.12.8 Changed Attribute For Left Element Part 1 17 6 7"
}

///|
/// ECMA-376 Part 4 §14.12.9 Changed Attribute For Printersettings Element Part 1 17 6 14
/// Source: references/spec/part4/sections/14.12.9__changed-attribute-for-printersettings-element-part-1-17-6-14.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_9_changed_attribute_for_printersettings_element_part_1_17_6_14_section_name() -> String {
  "ECMA-376 Part 4 §14.12.9 Changed Attribute For Printersettings Element Part 1 17 6 14"
}

///|
/// ECMA-376 Part 4 §14.12.10 Changed Attribute For Right Element Part 1 17 6 15
/// Source: references/spec/part4/sections/14.12.10__changed-attribute-for-right-element-part-1-17-6-15.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_10_changed_attribute_for_right_element_part_1_17_6_15_section_name() -> String {
  "ECMA-376 Part 4 §14.12.10 Changed Attribute For Right Element Part 1 17 6 15"
}

///|
/// ECMA-376 Part 4 §14.12.11 Changed Attribute For Top Element Part 1 17 6 21
/// Source: references/spec/part4/sections/14.12.11__changed-attribute-for-top-element-part-1-17-6-21.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_11_changed_attribute_for_top_element_part_1_17_6_21_section_name() -> String {
  "ECMA-376 Part 4 §14.12.11 Changed Attribute For Top Element Part 1 17 6 21"
}

///|
/// ECMA-376 Part 4 §14.12.12 Changed Attribute For Embedbold Element Part 1 17 8 3 3
/// Source: references/spec/part4/sections/14.12.12__changed-attribute-for-embedbold-element-part-1-17-8-3-3.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_12_changed_attribute_for_embedbold_element_part_1_17_8_3_3_section_name() -> String {
  "ECMA-376 Part 4 §14.12.12 Changed Attribute For Embedbold Element Part 1 17 8 3 3"
}

///|
/// ECMA-376 Part 4 §14.12.13 Changed Attribute For Embedbolditalic Element Part 1 17 8 3 4
/// Source: references/spec/part4/sections/14.12.13__changed-attribute-for-embedbolditalic-element-part-1-17-8-3-4.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_13_changed_attribute_for_embedbolditalic_element_part_1_17_8_3_4_section_name() -> String {
  "ECMA-376 Part 4 §14.12.13 Changed Attribute For Embedbolditalic Element Part 1 17 8 3 4"
}

///|
/// ECMA-376 Part 4 §14.12.14 Changed Attribute For Embeditalic Element Part 1 17 8 3 5
/// Source: references/spec/part4/sections/14.12.14__changed-attribute-for-embeditalic-element-part-1-17-8-3-5.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_14_changed_attribute_for_embeditalic_element_part_1_17_8_3_5_section_name() -> String {
  "ECMA-376 Part 4 §14.12.14 Changed Attribute For Embeditalic Element Part 1 17 8 3 5"
}

///|
/// ECMA-376 Part 4 §14.12.15 Changed Attribute For Embedregular Element Part 1 17 8 3 6
/// Source: references/spec/part4/sections/14.12.15__changed-attribute-for-embedregular-element-part-1-17-8-3-6.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_15_changed_attribute_for_embedregular_element_part_1_17_8_3_6_section_name() -> String {
  "ECMA-376 Part 4 §14.12.15 Changed Attribute For Embedregular Element Part 1 17 8 3 6"
}

///|
/// ECMA-376 Part 4 §14.12.16 Changed Attribute For Footerreference Element Part 1 17 10 2
/// Source: references/spec/part4/sections/14.12.16__changed-attribute-for-footerreference-element-part-1-17-10-2.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_16_changed_attribute_for_footerreference_element_part_1_17_10_2_section_name() -> String {
  "ECMA-376 Part 4 §14.12.16 Changed Attribute For Footerreference Element Part 1 17 10 2"
}

///|
/// ECMA-376 Part 4 §14.12.17 Changed Attribute For Headerreference Element Part 1 17 10 5
/// Source: references/spec/part4/sections/14.12.17__changed-attribute-for-headerreference-element-part-1-17-10-5.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_17_changed_attribute_for_headerreference_element_part_1_17_10_5_section_name() -> String {
  "ECMA-376 Part 4 §14.12.17 Changed Attribute For Headerreference Element Part 1 17 10 5"
}

///|
/// ECMA-376 Part 4 §14.12.18 Changed Attribute For Datasource Element Part 1 17 14 9
/// Source: references/spec/part4/sections/14.12.18__changed-attribute-for-datasource-element-part-1-17-14-9.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_18_changed_attribute_for_datasource_element_part_1_17_14_9_section_name() -> String {
  "ECMA-376 Part 4 §14.12.18 Changed Attribute For Datasource Element Part 1 17 14 9"
}

///|
/// ECMA-376 Part 4 §14.12.19 Changed Attribute For Headersource Element Part 1 17 14 16
/// Source: references/spec/part4/sections/14.12.19__changed-attribute-for-headersource-element-part-1-17-14-16.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_19_changed_attribute_for_headersource_element_part_1_17_14_16_section_name() -> String {
  "ECMA-376 Part 4 §14.12.19 Changed Attribute For Headersource Element Part 1 17 14 16"
}

///|
/// ECMA-376 Part 4 §14.12.21 Changed Attribute For Src Element Part 1 17 14 30
/// Source: references/spec/part4/sections/14.12.21__changed-attribute-for-src-element-part-1-17-14-30.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_21_changed_attribute_for_src_element_part_1_17_14_30_section_name() -> String {
  "ECMA-376 Part 4 §14.12.21 Changed Attribute For Src Element Part 1 17 14 30"
}

///|
/// ECMA-376 Part 4 §14.12.22 Changed Attribute For Attachedtemplate Element Part 1 17 15 1 6
/// Source: references/spec/part4/sections/14.12.22__changed-attribute-for-attachedtemplate-element-part-1-17-15-1-6.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_22_changed_attribute_for_attachedtemplate_element_part_1_17_15_1_6_section_name() -> String {
  "ECMA-376 Part 4 §14.12.22 Changed Attribute For Attachedtemplate Element Part 1 17 15 1 6"
}

///|
/// ECMA-376 Part 4 §14.12.23 Changed Attribute For Savethroughxslt Element Part 1 17 15 1 76
/// Source: references/spec/part4/sections/14.12.23__changed-attribute-for-savethroughxslt-element-part-1-17-15-1-76.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_23_changed_attribute_for_savethroughxslt_element_part_1_17_15_1_76_section_name() -> String {
  "ECMA-376 Part 4 §14.12.23 Changed Attribute For Savethroughxslt Element Part 1 17 15 1 76"
}

///|
/// ECMA-376 Part 4 §14.12.24 Changed Attribute For Longdesc Element Part 1 17 15 2 23
/// Source: references/spec/part4/sections/14.12.24__changed-attribute-for-longdesc-element-part-1-17-15-2-23.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_24_changed_attribute_for_longdesc_element_part_1_17_15_2_23_section_name() -> String {
  "ECMA-376 Part 4 §14.12.24 Changed Attribute For Longdesc Element Part 1 17 15 2 23"
}

///|
/// ECMA-376 Part 4 §14.12.25 Changed Attribute For Sourcefilename Element Part 1 17 15 2 39
/// Source: references/spec/part4/sections/14.12.25__changed-attribute-for-sourcefilename-element-part-1-17-15-2-39.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_25_changed_attribute_for_sourcefilename_element_part_1_17_15_2_39_section_name() -> String {
  "ECMA-376 Part 4 §14.12.25 Changed Attribute For Sourcefilename Element Part 1 17 15 2 39"
}

///|
/// ECMA-376 Part 4 §14.12.26 Changed Attribute For Subdoc Element Part 1 17 17 1 1
/// Source: references/spec/part4/sections/14.12.26__changed-attribute-for-subdoc-element-part-1-17-17-1-1.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_26_changed_attribute_for_subdoc_element_part_1_17_17_1_1_section_name() -> String {
  "ECMA-376 Part 4 §14.12.26 Changed Attribute For Subdoc Element Part 1 17 17 1 1"
}

///|
/// ECMA-376 Part 4 §14.12.27 Changed Attribute For Altchunk Element Part 1 17 17 2 1
/// Source: references/spec/part4/sections/14.12.27__changed-attribute-for-altchunk-element-part-1-17-17-2-1.md.
/// Owned by src/ecma376/wordprocessing_ml.
pub fn wml_part4_14_12_27_changed_attribute_for_altchunk_element_part_1_17_17_2_1_section_name() -> String {
  "ECMA-376 Part 4 §14.12.27 Changed Attribute For Altchunk Element Part 1 17 17 2 1"
}

///|
/// XSD model group EG_SectPrContents.
/// Schema wml.xsd model group `EG_SectPrContents`.
/// Children include footnotePr, endnotePr, type, pgSz, pgMar, paperSrc,
/// pgBorders, lnNumType, pgNumType, cols, formProt, vAlign, noEndnote,
/// titlePg, textDirection, bidi, rtlGutter, docGrid, and printerSettings
/// (type CT_Rel). The printerSettings child carries an OPC relationship
/// id whose resolution failure surfaces as ResourceMissing from the OPC
/// layer. The same data, in machine-readable form, is in `coverage.json`.
/// Originating section number §3.
pub fn wml_xsd_eg_sectprcontents_schema_name() -> String {
  "Schema wml.xsd model group `EG_SectPrContents`. Children include printerSettings (CT_Rel). ResourceMissing is raised by the OPC layer when printerSettings references an unresolved relationship target. Originating §3."
}

///|
/// XSD complex type CT_Anchor.
/// Schema dml-wordprocessingDrawing.xsd complex type `CT_Anchor`. Attributes: `distT`, `distB`, `distL`, `distR`, `simplePos`, `relativeHeight`, `behindDoc`, `locked`, `layoutInCell`, `hidden`, `allowOverlap`. Child elements: `simplePos`, `positionH`, `positionV`, `extent`, `effectExtent`, `docPr`, `cNvGraphicFramePr`. Child types: `a:CT_Point2D`, `CT_PosH`, `CT_PosV`, `a:CT_PositiveSize2D`, `CT_Effe...
pub fn wml_xsd_ct_anchor_schema_name() -> String {
  "XSD complex type CT_Anchor. Schema dml-wordprocessingDrawing.xsd complex type `CT_Anchor`. Attributes: `distT`, `distB`, `distL`, `distR`, `simplePos`, `relativeHeight`, `behindDoc`, `locked`, `layoutInCell`, `hidden`, `allowOverlap`. Child elements: `simplePos`, `positionH`, `positionV`, `extent`, `effectExtent`, `docPr`, `cNvGraphicFramePr`. Child types: `a:CT_Point2D`, `CT_PosH`, `CT_PosV`, `a:CT_PositiveSize2D`, `CT_EffectExtent`, `a:CT_NonVisualDrawingProps`, `a:CT_NonVisualGraphicFrameProperties`."
}

///|
/// XSD simple type ST_HorizontalAnchor.
/// Schema vml-wordprocessingDrawing.xsd simple type `ST_HorizontalAnchor`. Base: `xsd:string`. Enumeration values: `margin`, `page`, `text`, `char`.
pub fn wml_xsd_st_horizontalanchor_schema_name() -> String {
  "XSD simple type ST_HorizontalAnchor. Schema vml-wordprocessingDrawing.xsd simple type `ST_HorizontalAnchor`. Base: `xsd:string`. Enumeration values: `margin`, `page`, `text`, `char`."
}

///|
/// XSD simple type ST_VerticalAnchor.
/// Schema vml-wordprocessingDrawing.xsd simple type `ST_VerticalAnchor`. Base: `xsd:string`. Enumeration values: `margin`, `page`, `text`, `line`.
pub fn wml_xsd_st_verticalanchor_schema_name() -> String {
  "XSD simple type ST_VerticalAnchor. Schema vml-wordprocessingDrawing.xsd simple type `ST_VerticalAnchor`. Base: `xsd:string`. Enumeration values: `margin`, `page`, `text`, `line`."
}

///|
/// XSD complex type CT_Cnf.
/// Schema wml.xsd complex type `CT_Cnf`. Attributes: `firstRow`, `lastRow`, `firstColumn`, `lastColumn`, `oddVBand`, `evenVBand`, `oddHBand`, `evenHBand`, `firstRowFirstColumn`, `firstRowLastColumn`, `lastRowFirstColumn`, `lastRowLastColumn`.
pub fn wml_xsd_ct_cnf_schema_name() -> String {
  "XSD complex type CT_Cnf. Schema wml.xsd complex type `CT_Cnf`. Attributes: `firstRow`, `lastRow`, `firstColumn`, `lastColumn`, `oddVBand`, `evenVBand`, `oddHBand`, `evenHBand`, `firstRowFirstColumn`, `firstRowLastColumn`, `lastRowFirstColumn`, `lastRowLastColumn`."
}

///|
/// XSD complex type CT_Div.
/// Schema wml.xsd complex type `CT_Div`. Attributes: `id`. Child elements: `blockQuote`, `bodyDiv`, `marLeft`, `marRight`, `marTop`, `marBottom`, `divBdr`, `divsChild`. Child types: `CT_OnOff`, `CT_SignedTwipsMeasure`, `CT_DivBdr`, `CT_Divs`.
pub fn wml_xsd_ct_div_schema_name() -> String {
  "XSD complex type CT_Div. Schema wml.xsd complex type `CT_Div`. Attributes: `id`. Child elements: `blockQuote`, `bodyDiv`, `marLeft`, `marRight`, `marTop`, `marBottom`, `divBdr`, `divsChild`. Child types: `CT_OnOff`, `CT_SignedTwipsMeasure`, `CT_DivBdr`, `CT_Divs`."
}

///|
/// XSD complex type CT_FFData.
/// Schema wml.xsd complex type `CT_FFData`. Child elements: `name`, `label`, `tabIndex`, `enabled`, `calcOnExit`, `entryMacro`, `exitMacro`, `helpText`, `statusText`, `checkBox`, `ddList`, `textInput`. Child types: `CT_FFName`, `CT_DecimalNumber`, `CT_UnsignedDecimalNumber`, `CT_OnOff`, `CT_MacroName`, `CT_FFHelpText`, `CT_FFStatusText`, `CT_FFCheckBox`, `CT_FFDDList`, `CT_FFTextInput`.
pub fn wml_xsd_ct_ffdata_schema_name() -> String {
  "XSD complex type CT_FFData. Schema wml.xsd complex type `CT_FFData`. Child elements: `name`, `label`, `tabIndex`, `enabled`, `calcOnExit`, `entryMacro`, `exitMacro`, `helpText`, `statusText`, `checkBox`, `ddList`, `textInput`. Child types: `CT_FFName`, `CT_DecimalNumber`, `CT_UnsignedDecimalNumber`, `CT_OnOff`, `CT_MacroName`, `CT_FFHelpText`, `CT_FFStatusText`, `CT_FFCheckBox`, `CT_FFDDList`, `CT_FFTextInput`."
}

///|
/// XSD complex type CT_Font.
/// Schema wml.xsd complex type `CT_Font`. Attributes: `name`. Child elements: `altName`, `panose1`, `charset`, `family`, `notTrueType`, `pitch`, `sig`, `embedRegular`, `embedBold`, `embedItalic`, `embedBoldItalic`. Child types: `CT_String`, `CT_Panose`, `CT_Charset`, `CT_FontFamily`, `CT_OnOff`, `CT_Pitch`, `CT_FontSig`, `CT_FontRel`.
pub fn wml_xsd_ct_font_schema_name() -> String {
  "XSD complex type CT_Font. Schema wml.xsd complex type `CT_Font`. Attributes: `name`. Child elements: `altName`, `panose1`, `charset`, `family`, `notTrueType`, `pitch`, `sig`, `embedRegular`, `embedBold`, `embedItalic`, `embedBoldItalic`. Child types: `CT_String`, `CT_Panose`, `CT_Charset`, `CT_FontFamily`, `CT_OnOff`, `CT_Pitch`, `CT_FontSig`, `CT_FontRel`."
}

///|
/// XSD complex type CT_Frame.
/// Schema wml.xsd complex type `CT_Frame`. Child elements: `sz`, `name`, `title`, `longDesc`, `sourceFileName`, `marW`, `marH`, `scrollbar`, `noResizeAllowed`, `linkedToFile`. Child types: `CT_String`, `CT_Rel`, `CT_PixelsMeasure`, `CT_FrameScrollbar`, `CT_OnOff`.
pub fn wml_xsd_ct_frame_schema_name() -> String {
  "XSD complex type CT_Frame. Schema wml.xsd complex type `CT_Frame`. Child elements: `sz`, `name`, `title`, `longDesc`, `sourceFileName`, `marW`, `marH`, `scrollbar`, `noResizeAllowed`, `linkedToFile`. Child types: `CT_String`, `CT_Rel`, `CT_PixelsMeasure`, `CT_FrameScrollbar`, `CT_OnOff`."
}

///|
/// XSD complex type CT_Ind.
/// Schema wml.xsd complex type `CT_Ind`. Attributes: `start`, `startChars`, `end`, `endChars`, `hanging`, `hangingChars`, `firstLine`, `firstLineChars`.
pub fn wml_xsd_ct_ind_schema_name() -> String {
  "XSD complex type CT_Ind. Schema wml.xsd complex type `CT_Ind`. Attributes: `start`, `startChars`, `end`, `endChars`, `hanging`, `hangingChars`, `firstLine`, `firstLineChars`."
}

///|
/// XSD complex type CT_Lvl.
/// Schema wml.xsd complex type `CT_Lvl`. Attributes: `ilvl`, `tplc`, `tentative`. Child elements: `start`, `numFmt`, `lvlRestart`, `pStyle`, `isLgl`, `suff`, `lvlText`, `lvlPicBulletId`, `lvlJc`, `pPr`, `rPr`. Child types: `CT_DecimalNumber`, `CT_NumFmt`, `CT_String`, `CT_OnOff`, `CT_LevelSuffix`, `CT_LevelText`, `CT_Jc`, `CT_PPrGeneral`, `CT_RPr`.
pub fn wml_xsd_ct_lvl_schema_name() -> String {
  "XSD complex type CT_Lvl. Schema wml.xsd complex type `CT_Lvl`. Attributes: `ilvl`, `tplc`, `tentative`. Child elements: `start`, `numFmt`, `lvlRestart`, `pStyle`, `isLgl`, `suff`, `lvlText`, `lvlPicBulletId`, `lvlJc`, `pPr`, `rPr`. Child types: `CT_DecimalNumber`, `CT_NumFmt`, `CT_String`, `CT_OnOff`, `CT_LevelSuffix`, `CT_LevelText`, `CT_Jc`, `CT_PPrGeneral`, `CT_RPr`."
}

///|
/// XSD complex type CT_Num.
/// Schema wml.xsd complex type `CT_Num`. Attributes: `numId`. Child elements: `abstractNumId`, `lvlOverride`. Child types: `CT_DecimalNumber`, `CT_NumLvl`.
pub fn wml_xsd_ct_num_schema_name() -> String {
  "XSD complex type CT_Num. Schema wml.xsd complex type `CT_Num`. Attributes: `numId`. Child elements: `abstractNumId`, `lvlOverride`. Child types: `CT_DecimalNumber`, `CT_NumLvl`."
}

///|
/// XSD complex type CT_NumFmt.
/// Schema wml.xsd complex type `CT_NumFmt`. Attributes: `val`, `format`.
pub fn wml_xsd_ct_numfmt_schema_name() -> String {
  "XSD complex type CT_NumFmt. Schema wml.xsd complex type `CT_NumFmt`. Attributes: `val`, `format`."
}

///|
/// XSD complex type CT_PPrBase.
/// Schema wml.xsd complex type `CT_PPrBase`. Child elements: `pStyle`, `keepNext`, `keepLines`, `pageBreakBefore`, `framePr`, `widowControl`, `numPr`, `suppressLineNumbers`, `pBdr`, `shd`, `tabs`, `suppressAutoHyphens`, `kinsoku`, `wordWrap`, `overflowPunct`, `topLinePunct`, `autoSpaceDE`, `autoSpaceDN`, `bidi`, `adjustRightInd`, `snapToGrid`, `spacing`, `ind`, `contextualSpacing`, `mirrorIndents`, `...
pub fn wml_xsd_ct_pprbase_schema_name() -> String {
  "XSD complex type CT_PPrBase. Schema wml.xsd complex type `CT_PPrBase`. Child elements: `pStyle`, `keepNext`, `keepLines`, `pageBreakBefore`, `framePr`, `widowControl`, `numPr`, `suppressLineNumbers`, `pBdr`, `shd`, `tabs`, `suppressAutoHyphens`, `kinsoku`, `wordWrap`, `overflowPunct`, `topLinePunct`, `autoSpaceDE`, `autoSpaceDN`, `bidi`, `adjustRightInd`, `snapToGrid`, `spacing`, `ind`, `contextualSpacing`, `mirrorIndents`, `suppressOverlap`, `jc`, `textDirection`, `textAlignment`, `textboxTightWrap`, `outlineLvl`, `divId`, `cnfStyle`. Child types: `CT_String`, `CT_OnOff`, `CT_FramePr`, `CT_NumPr`, `CT_PBdr`, `CT_Shd`, `CT_Tabs`, `CT_Spacing`, `CT_Ind`, `CT_Jc`, `CT_TextDirection`, `CT_TextAlignment`, `CT_TextboxTightWrap`, `CT_DecimalNumber`, `CT_Cnf`."
}

///|
/// XSD complex type CT_Row.
/// Schema wml.xsd complex type `CT_Row`. Attributes: `rsidRPr`, `rsidR`, `rsidDel`, `rsidTr`. Child elements: `tblPrEx`, `trPr`. Child types: `CT_TblPrEx`, `CT_TrPr`.
pub fn wml_xsd_ct_row_schema_name() -> String {
  "XSD complex type CT_Row. Schema wml.xsd complex type `CT_Row`. Attributes: `rsidRPr`, `rsidR`, `rsidDel`, `rsidTr`. Child elements: `tblPrEx`, `trPr`. Child types: `CT_TblPrEx`, `CT_TrPr`."
}

///|
/// XSD complex type CT_SdtPr.
/// Schema wml.xsd complex type `CT_SdtPr`. Child elements: `rPr`, `alias`, `tag`, `id`, `lock`, `placeholder`, `temporary`, `showingPlcHdr`, `dataBinding`, `label`, `tabIndex`, `equation`, `comboBox`, `date`, `docPartObj`, `docPartList`, `dropDownList`, `picture`, `richText`, `text`, `citation`, `group`, `bibliography`. Child types: `CT_RPr`, `CT_String`, `CT_DecimalNumber`, `CT_Lock`, `CT_Placeholde...
pub fn wml_xsd_ct_sdtpr_schema_name() -> String {
  "XSD complex type CT_SdtPr. Schema wml.xsd complex type `CT_SdtPr`. Child elements: `rPr`, `alias`, `tag`, `id`, `lock`, `placeholder`, `temporary`, `showingPlcHdr`, `dataBinding`, `label`, `tabIndex`, `equation`, `comboBox`, `date`, `docPartObj`, `docPartList`, `dropDownList`, `picture`, `richText`, `text`, `citation`, `group`, `bibliography`. Child types: `CT_RPr`, `CT_String`, `CT_DecimalNumber`, `CT_Lock`, `CT_Placeholder`, `CT_OnOff`, `CT_DataBinding`, `CT_UnsignedDecimalNumber`, `CT_Empty`, `CT_SdtComboBox`, `CT_SdtDate`, `CT_SdtDocPart`, `CT_SdtDropDownList`, `CT_SdtText`."
}

///|
/// XSD complex type CT_Shd.
/// Schema wml.xsd complex type `CT_Shd`. Attributes: `val`, `color`, `themeColor`, `themeTint`, `themeShade`, `fill`, `themeFill`, `themeFillTint`, `themeFillShade`.
pub fn wml_xsd_ct_shd_schema_name() -> String {
  "XSD complex type CT_Shd. Schema wml.xsd complex type `CT_Shd`. Attributes: `val`, `color`, `themeColor`, `themeTint`, `themeShade`, `fill`, `themeFill`, `themeFillTint`, `themeFillShade`."
}

///|
/// XSD complex type CT_TblPPr.
/// Schema wml.xsd complex type `CT_TblPPr`. Attributes: `leftFromText`, `rightFromText`, `topFromText`, `bottomFromText`, `vertAnchor`, `horzAnchor`, `tblpXSpec`, `tblpX`, `tblpYSpec`, `tblpY`.
pub fn wml_xsd_ct_tblppr_schema_name() -> String {
  "XSD complex type CT_TblPPr. Schema wml.xsd complex type `CT_TblPPr`. Attributes: `leftFromText`, `rightFromText`, `topFromText`, `bottomFromText`, `vertAnchor`, `horzAnchor`, `tblpXSpec`, `tblpX`, `tblpYSpec`, `tblpY`."
}
