// WML auxiliary-part fixtures — settings.xml, styles.xml, fontTable.xml,
// and webSettings.xml. These cases exercise ECMA-376 §17 part roots
// through the real docx OPC host rather than embedding the elements in
// the main document body.

///|
fn wml_aux_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("w"), local_name, ns: Some(NS_W) }, value }
}

///|
fn wml_aux_rel_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("r"), local_name, ns: Some(NS_OFFICE_REL) }, value }
}

///|
fn wml_aux_nodes(elements : Array[@xml.Element]) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for e in elements {
    nodes.push(Element(e))
  }
  nodes
}

///|
fn wml_aux_el(
  name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Element],
) -> @xml.Element {
  xe(NS_W, name, attrs, wml_aux_nodes(children))
}

///|
fn wml_aux_border(name : String) -> @xml.Element {
  xe(
    NS_W,
    name,
    [
      wml_aux_attr("val", "single"),
      wml_aux_attr("color", "4472C4"),
      wml_aux_attr("sz", "4"),
      wml_aux_attr("space", "1"),
    ],
    [],
  )
}

///|
fn wml_settings_core_part() -> @xml.Element {
  wml_aux_el("settings", [], [
    xe(NS_W, "writeProtection", [wml_aux_attr("recommended", "1")], []),
    w_val("view", "print"),
    xe(
      NS_W,
      "zoom",
      [wml_aux_attr("val", "bestFit"), wml_aux_attr("percent", "110")],
      [],
    ),
    w_flag("removePersonalInformation"),
    w_flag("removeDateAndTime"),
    w_flag("doNotDisplayPageBoundaries"),
    w_flag("displayBackgroundShape"),
    w_flag("printPostScriptOverText"),
    w_flag("printFractionalCharacterWidth"),
    w_flag("printFormsData"),
    w_flag("embedTrueTypeFonts"),
    w_flag("embedSystemFonts"),
    w_flag("saveSubsetFonts"),
    w_flag("saveFormsData"),
    w_flag("mirrorMargins"),
    w_flag("alignBordersAndEdges"),
    w_flag("bordersDoNotSurroundHeader"),
    w_flag("bordersDoNotSurroundFooter"),
    w_flag("gutterAtTop"),
    w_flag("hideSpellingErrors"),
    w_flag("hideGrammaticalErrors"),
    xe(
      NS_W,
      "activeWritingStyle",
      [
        wml_aux_attr("lang", "en-US"),
        wml_aux_attr("vendorID", "catalog"),
        wml_aux_attr("dllVersion", "1"),
        wml_aux_attr("checkStyle", "1"),
        wml_aux_attr("appName", "ooxml-catalog"),
      ],
      [],
    ),
    xe(
      NS_W,
      "proofState",
      [wml_aux_attr("spelling", "dirty"), wml_aux_attr("grammar", "clean")],
      [],
    ),
    w_flag("formsDesign"),
    w_flag("linkStyles"),
    xe(
      NS_W,
      "stylePaneFormatFilter",
      [
        wml_aux_attr("allStyles", "1"),
        wml_aux_attr("customStyles", "1"),
        wml_aux_attr("visibleStyles", "1"),
        wml_aux_attr("val", "0001"),
      ],
      [],
    ),
    w_val("stylePaneSortMethod", "name"),
    w_val("documentType", "catalog"),
    wml_aux_el("mailMerge", [], [
      w_val("mainDocumentType", "email"),
      w_flag("linkToQuery"),
      w_val("dataType", "native"),
      w_val("connectString", "Driver=Text"),
      w_val("query", "SELECT * FROM Contacts"),
      w_flag("doNotSuppressBlankLines"),
      w_val("destination", "email"),
      w_val("addressFieldName", "Email"),
      w_val("mailSubject", "Catalog notice"),
      w_flag("mailAsAttachment"),
      w_flag("viewMergedData"),
      w_val("activeRecord", "1"),
      w_val("checkErrors", "0"),
      wml_aux_el("odso", [], [
        w_val("udl", "Provider=Text"),
        w_val("table", "Contacts"),
        w_val("colDelim", "44"),
        w_val("type", "email"),
        w_flag("fHdr"),
        wml_aux_el("fieldMapData", [], [
          w_val("type", "dbColumn"),
          w_val("name", "Email"),
          w_val("mappedName", "EmailAddress"),
          w_val("column", "1"),
          w_val("lid", "en-US"),
          w_flag("dynamicAddress"),
        ]),
      ]),
    ]),
    xe(
      NS_W,
      "revisionView",
      [
        wml_aux_attr("markup", "1"),
        wml_aux_attr("comments", "1"),
        wml_aux_attr("insDel", "1"),
        wml_aux_attr("formatting", "1"),
      ],
      [],
    ),
    w_flag("trackRevisions"),
    w_flag("doNotTrackMoves"),
    w_flag("doNotTrackFormatting"),
    xe(
      NS_W,
      "documentProtection",
      [
        wml_aux_attr("edit", "readOnly"),
        wml_aux_attr("formatting", "1"),
        wml_aux_attr("enforcement", "1"),
      ],
      [],
    ),
    w_flag("autoFormatOverride"),
    w_flag("styleLockTheme"),
    w_flag("styleLockQFSet"),
    w_val("defaultTabStop", "720"),
    w_flag("autoHyphenation"),
    w_val("consecutiveHyphenLimit", "2"),
    w_val("hyphenationZone", "360"),
    w_flag("doNotHyphenateCaps"),
    w_flag("showEnvelope"),
    w_val("summaryLength", "100%"),
    w_val("clickAndTypeStyle", "Normal"),
    w_val("defaultTableStyle", "TableGrid"),
    w_flag("evenAndOddHeaders"),
    w_flag("bookFoldRevPrinting"),
    w_flag("bookFoldPrinting"),
    w_val("bookFoldPrintingSheets", "8"),
    w_val("drawingGridHorizontalSpacing", "180"),
    w_val("drawingGridVerticalSpacing", "180"),
    w_val("displayHorizontalDrawingGridEvery", "2"),
    w_val("displayVerticalDrawingGridEvery", "2"),
    w_flag("doNotUseMarginsForDrawingGridOrigin"),
    w_val("drawingGridHorizontalOrigin", "0"),
    w_val("drawingGridVerticalOrigin", "0"),
    w_flag("doNotShadeFormData"),
    w_flag("noPunctuationKerning"),
    w_val("characterSpacingControl", "compressPunctuation"),
    w_flag("printTwoOnOne"),
    w_flag("strictFirstAndLastChars"),
    xe(
      NS_W,
      "noLineBreaksAfter",
      [wml_aux_attr("lang", "ja-JP"), wml_aux_attr("val", "!?")],
      [],
    ),
    xe(
      NS_W,
      "noLineBreaksBefore",
      [wml_aux_attr("lang", "ja-JP"), wml_aux_attr("val", ")]")],
      [],
    ),
    w_flag("savePreviewPicture"),
    w_flag("doNotValidateAgainstSchema"),
    w_flag("saveInvalidXml"),
    w_flag("ignoreMixedContent"),
    w_flag("alwaysShowPlaceholderText"),
    w_flag("doNotDemarcateInvalidXml"),
    w_flag("saveXmlDataOnly"),
    w_flag("useXSLTWhenSaving"),
    xe(NS_W, "saveThroughXslt", [wml_aux_attr("solutionID", "catalog")], []),
    w_flag("showXMLTags"),
    w_flag("alwaysMergeEmptyNamespace"),
    w_flag("updateFields"),
    wml_aux_el("docVars", [], [
      xe(
        NS_W,
        "docVar",
        [wml_aux_attr("name", "Catalog"), wml_aux_attr("val", "WML")],
        [],
      ),
    ]),
    wml_aux_el("rsids", [], [
      w_val("rsidRoot", "00112233"),
      w_val("rsid", "44556677"),
    ]),
    w_val("attachedSchema", "urn:catalog:schema"),
    xe(
      NS_W,
      "themeFontLang",
      [
        wml_aux_attr("val", "en-US"),
        wml_aux_attr("eastAsia", "ja-JP"),
        wml_aux_attr("bidi", "ar-SA"),
      ],
      [],
    ),
    xe(
      NS_W,
      "clrSchemeMapping",
      [
        wml_aux_attr("bg1", "light1"),
        wml_aux_attr("t1", "dark1"),
        wml_aux_attr("bg2", "light2"),
        wml_aux_attr("t2", "dark2"),
        wml_aux_attr("accent1", "accent1"),
        wml_aux_attr("accent2", "accent2"),
        wml_aux_attr("accent3", "accent3"),
        wml_aux_attr("accent4", "accent4"),
        wml_aux_attr("accent5", "accent5"),
        wml_aux_attr("accent6", "accent6"),
        wml_aux_attr("hyperlink", "hyperlink"),
        wml_aux_attr("followedHyperlink", "followedHyperlink"),
      ],
      [],
    ),
    w_flag("doNotIncludeSubdocsInStats"),
    w_flag("doNotAutoCompressPictures"),
    w_flag("forceUpgrade"),
    wml_aux_el("captions", [], [
      xe(
        NS_W,
        "caption",
        [
          wml_aux_attr("name", "Figure"),
          wml_aux_attr("pos", "below"),
          wml_aux_attr("chapNum", "1"),
          wml_aux_attr("heading", "1"),
          wml_aux_attr("noLabel", "0"),
          wml_aux_attr("numFmt", "decimal"),
          wml_aux_attr("sep", "hyphen"),
        ],
        [],
      ),
      wml_aux_el("autoCaptions", [], [
        xe(
          NS_W,
          "autoCaption",
          [wml_aux_attr("name", "Table"), wml_aux_attr("caption", "Table")],
          [],
        ),
      ]),
    ]),
    xe(
      NS_W,
      "readModeInkLockDown",
      [
        wml_aux_attr("actualPg", "1"),
        wml_aux_attr("w", "1024"),
        wml_aux_attr("h", "768"),
        wml_aux_attr("fontSz", "100%"),
      ],
      [],
    ),
    xe(
      NS_W,
      "smartTagType",
      [
        wml_aux_attr("namespaceuri", "urn:catalog:smart"),
        wml_aux_attr("name", "tag"),
        wml_aux_attr("url", "https://example.invalid/smart"),
      ],
      [],
    ),
    w_flag("doNotEmbedSmartTags"),
    w_val("decimalSymbol", "."),
    w_val("listSeparator", ","),
  ])
}

///|
fn wml_settings_compat_part() -> @xml.Element {
  let toggles = [
    "useSingleBorderforContiguousCells", "wpJustification", "noTabHangInd", "noLeading",
    "spaceForUL", "noColumnBalance", "balanceSingleByteDoubleByteWidth", "noExtraLineSpacing",
    "doNotLeaveBackslashAlone", "ulTrailSpace", "doNotExpandShiftReturn", "spacingInWholePoints",
    "lineWrapLikeWord6", "printBodyTextBeforeHeader", "printColBlack", "wpSpaceWidth",
    "showBreaksInFrames", "subFontBySize", "suppressBottomSpacing", "suppressTopSpacing",
    "suppressSpacingAtTopOfPage", "suppressTopSpacingWP", "suppressSpBfAfterPgBrk",
    "swapBordersFacingPages", "convMailMergeEsc", "truncateFontHeightsLikeWP6", "mwSmallCaps",
    "usePrinterMetrics", "doNotSuppressParagraphBorders", "wrapTrailSpaces", "footnoteLayoutLikeWW8",
    "shapeLayoutLikeWW8", "alignTablesRowByRow", "forgetLastTabAlignment", "adjustLineHeightInTable",
    "autoSpaceLikeWord95", "noSpaceRaiseLower", "doNotUseHTMLParagraphAutoSpacing",
    "layoutRawTableWidth", "layoutTableRowsApart", "useWord97LineBreakRules", "doNotBreakWrappedTables",
    "doNotSnapToGridInCell", "selectFldWithFirstOrLastChar", "applyBreakingRules",
    "doNotWrapTextWithPunct", "doNotUseEastAsianBreakRules", "useWord2002TableStyleRules",
    "growAutofit", "useFELayout", "useNormalStyleForList", "doNotUseIndentAsNumberingTabStop",
    "useAltKinsokuLineBreakRules", "allowSpaceOfSameStyleInTable", "doNotSuppressIndentation",
    "doNotAutofitConstrainedTables", "autofitToFirstFixedWidthCell", "underlineTabInNumList",
    "displayHangulFixedWidth", "splitPgBreakAndParaMark", "doNotVertAlignCellWithSp",
    "doNotBreakConstrainedForcedTable", "doNotVertAlignInTxbx", "useAnsiKerningPairs",
    "cachedColBalance",
  ]
  let compat_children : Array[@xml.Element] = []
  for name in toggles {
    compat_children.push(w_flag(name))
  }
  compat_children.push(
    xe(
      NS_W,
      "compatSetting",
      [
        wml_aux_attr("name", "compatibilityMode"),
        wml_aux_attr("uri", "http://schemas.microsoft.com/office/word"),
        wml_aux_attr("val", "15"),
      ],
      [],
    ),
  )
  wml_aux_el("settings", [], [wml_aux_el("compat", [], compat_children)])
}

///|
fn wml_web_settings_part() -> @xml.Element {
  wml_aux_el("webSettings", [], [
    wml_aux_el("frameset", [], [
      w_val("sz", "50%,50%"),
      wml_aux_el("framesetSplitbar", [], [
        w_val("w", "120"),
        w_val("color", "4472C4"),
        w_flag("noBorder"),
        w_flag("flatBorders"),
      ]),
      w_val("frameLayout", "cols"),
      w_val("title", "Catalog frames"),
      wml_aux_el("frame", [], [
        w_val("sz", "50%"),
        w_val("name", "left"),
        w_val("title", "Left pane"),
        w_val("marW", "12"),
        w_val("marH", "12"),
        w_val("scrollbar", "auto"),
        w_flag("noResizeAllowed"),
        w_flag("linkedToFile"),
      ]),
    ]),
    wml_aux_el("divs", [], [
      xe(NS_W, "div", [wml_aux_attr("id", "1")], [
        Element(w_flag("blockQuote")),
        Element(w_flag("bodyDiv")),
        Element(w_val("marLeft", "120")),
        Element(w_val("marRight", "120")),
        Element(w_val("marTop", "60")),
        Element(w_val("marBottom", "60")),
        Element(
          wml_aux_el("divBdr", [], [
            wml_aux_border("top"),
            wml_aux_border("left"),
            wml_aux_border("bottom"),
            wml_aux_border("right"),
          ]),
        ),
      ]),
    ]),
    w_val("encoding", "utf-8"),
    xe(
      NS_W,
      "optimizeForBrowser",
      [wml_aux_attr("val", "1"), wml_aux_attr("target", "IE")],
      [],
    ),
    w_flag("relyOnVML"),
    w_flag("allowPNG"),
    w_flag("doNotRelyOnCSS"),
    w_flag("doNotSaveAsSingleFile"),
    w_flag("doNotOrganizeInFolder"),
    w_flag("doNotUseLongFileNames"),
    w_val("pixelsPerInch", "96"),
    w_val("targetScreenSz", "1024x768"),
    w_flag("saveSmartTagsAsXml"),
  ])
}

///|
fn wml_styles_part() -> @xml.Element {
  wml_aux_el("styles", [], [
    wml_aux_el("docDefaults", [], [
      wml_aux_el("rPrDefault", [], [w_rpr([w_val("lang", "en-US")])]),
      wml_aux_el("pPrDefault", [], [
        wml_aux_el("pPr", [], [
          xe(
            NS_W,
            "spacing",
            [
              wml_aux_attr("after", "240"),
              wml_aux_attr("line", "240"),
              wml_aux_attr("lineRule", "auto"),
            ],
            [],
          ),
        ]),
      ]),
    ]),
    xe(
      NS_W,
      "latentStyles",
      [
        wml_aux_attr("defLockedState", "0"),
        wml_aux_attr("defUIPriority", "99"),
        wml_aux_attr("defSemiHidden", "1"),
        wml_aux_attr("defUnhideWhenUsed", "1"),
        wml_aux_attr("defQFormat", "0"),
        wml_aux_attr("count", "1"),
      ],
      [
        Element(
          xe(
            NS_W,
            "lsdException",
            [
              wml_aux_attr("name", "Catalog Heading"),
              wml_aux_attr("locked", "0"),
              wml_aux_attr("uiPriority", "9"),
              wml_aux_attr("semiHidden", "0"),
              wml_aux_attr("unhideWhenUsed", "1"),
              wml_aux_attr("qFormat", "1"),
            ],
            [],
          ),
        ),
      ],
    ),
    xe(
      NS_W,
      "style",
      [
        wml_aux_attr("type", "paragraph"),
        wml_aux_attr("styleId", "CatalogHeading"),
        wml_aux_attr("default", "1"),
        wml_aux_attr("customStyle", "1"),
      ],
      [
        Element(w_val("name", "Catalog Heading")),
        Element(w_val("aliases", "Heading Alias")),
        Element(w_val("basedOn", "Normal")),
        Element(w_val("next", "Normal")),
        Element(w_val("link", "CatalogHeadingChar")),
        Element(w_flag("autoRedefine")),
        Element(w_flag("hidden")),
        Element(w_val("uiPriority", "9")),
        Element(w_flag("semiHidden")),
        Element(w_flag("unhideWhenUsed")),
        Element(w_flag("qFormat")),
        Element(w_flag("locked")),
        Element(w_flag("personal")),
        Element(w_flag("personalCompose")),
        Element(w_flag("personalReply")),
        Element(w_val("rsid", "8899AABB")),
      ],
    ),
  ])
}

///|
fn wml_font_table_part() -> @xml.Element {
  wml_aux_el("fonts", [], [
    xe(NS_W, "font", [wml_aux_attr("name", "Catalog Sans")], [
      Element(w_val("altName", "Catalog Alt")),
      Element(w_val("panose1", "020B0604020202020204")),
      Element(
        xe(
          NS_W,
          "charset",
          [wml_aux_attr("val", "00"), wml_aux_attr("characterSet", "ANSI")],
          [],
        ),
      ),
      Element(w_val("family", "swiss")),
      Element(w_flag("notTrueType")),
      Element(w_val("pitch", "variable")),
      Element(
        xe(
          NS_W,
          "sig",
          [
            wml_aux_attr("usb0", "00000001"),
            wml_aux_attr("usb1", "00000002"),
            wml_aux_attr("usb2", "00000003"),
            wml_aux_attr("usb3", "00000004"),
            wml_aux_attr("csb0", "00000005"),
            wml_aux_attr("csb1", "00000006"),
          ],
          [],
        ),
      ),
      Element(
        xe(
          NS_W,
          "embedRegular",
          [
            wml_aux_rel_attr("id", "rIdFontData0"),
            wml_aux_attr("fontKey", "{00112233-4455-6677-8899-AABBCCDDEEFF}"),
            wml_aux_attr("subsetted", "1"),
          ],
          [],
        ),
      ),
      Element(
        xe(
          NS_W,
          "embedBold",
          [
            wml_aux_rel_attr("id", "rIdFontData0"),
            wml_aux_attr("fontKey", "{00112233-4455-6677-8899-AABBCCDDEEFF}"),
            wml_aux_attr("subsetted", "1"),
          ],
          [],
        ),
      ),
      Element(
        xe(
          NS_W,
          "embedItalic",
          [
            wml_aux_rel_attr("id", "rIdFontData0"),
            wml_aux_attr("fontKey", "{00112233-4455-6677-8899-AABBCCDDEEFF}"),
            wml_aux_attr("subsetted", "1"),
          ],
          [],
        ),
      ),
      Element(
        xe(
          NS_W,
          "embedBoldItalic",
          [
            wml_aux_rel_attr("id", "rIdFontData0"),
            wml_aux_attr("fontKey", "{00112233-4455-6677-8899-AABBCCDDEEFF}"),
            wml_aux_attr("subsetted", "1"),
          ],
          [],
        ),
      ),
    ]),
  ])
}

///|
fn wml_aux_t(text : String) -> @xml.Element {
  xe(NS_W, "t", [], [Text(text)])
}

///|
fn wml_aux_run(children : Array[@xml.Element]) -> @xml.Element {
  wml_aux_el("r", [], children)
}

///|
fn wml_aux_paragraph(runs : Array[@xml.Element]) -> @xml.Element {
  wml_aux_el("p", [], runs)
}

///|
fn wml_aux_comments_part() -> @xml.Element {
  wml_aux_el("comments", [], [
    xe(
      NS_W,
      "comment",
      [
        wml_aux_attr("id", "0"),
        wml_aux_attr("author", "Catalog User"),
        wml_aux_attr("date", "2026-06-06T00:00:00Z"),
        wml_aux_attr("initials", "CU"),
      ],
      [
        Element(
          wml_aux_paragraph([
            wml_aux_run([
              xe(NS_W, "annotationRef", [], []),
              wml_aux_t("Catalog comment body"),
            ]),
          ]),
        ),
      ],
    ),
  ])
}

///|
fn wml_aux_footnotes_part() -> @xml.Element {
  wml_aux_el("footnotes", [], [
    xe(
      NS_W,
      "footnote",
      [wml_aux_attr("id", "-1"), wml_aux_attr("type", "separator")],
      [
        Element(
          wml_aux_paragraph([wml_aux_run([xe(NS_W, "separator", [], [])])]),
        ),
      ],
    ),
    xe(
      NS_W,
      "footnote",
      [wml_aux_attr("id", "0"), wml_aux_attr("type", "continuationSeparator")],
      [
        Element(
          wml_aux_paragraph([
            wml_aux_run([xe(NS_W, "continuationSeparator", [], [])]),
          ]),
        ),
      ],
    ),
    xe(NS_W, "footnote", [wml_aux_attr("id", "1")], [
      Element(
        wml_aux_paragraph([
          wml_aux_run([xe(NS_W, "footnoteRef", [], []), wml_aux_t("Footnote")]),
        ]),
      ),
    ]),
  ])
}

///|
fn wml_aux_endnotes_part() -> @xml.Element {
  wml_aux_el("endnotes", [], [
    xe(
      NS_W,
      "endnote",
      [wml_aux_attr("id", "-1"), wml_aux_attr("type", "separator")],
      [
        Element(
          wml_aux_paragraph([wml_aux_run([xe(NS_W, "separator", [], [])])]),
        ),
      ],
    ),
    xe(
      NS_W,
      "endnote",
      [wml_aux_attr("id", "0"), wml_aux_attr("type", "continuationSeparator")],
      [
        Element(
          wml_aux_paragraph([
            wml_aux_run([xe(NS_W, "continuationSeparator", [], [])]),
          ]),
        ),
      ],
    ),
    xe(NS_W, "endnote", [wml_aux_attr("id", "1")], [
      Element(
        wml_aux_paragraph([
          wml_aux_run([xe(NS_W, "endnoteRef", [], []), wml_aux_t("Endnote")]),
        ]),
      ),
    ]),
  ])
}

///|
fn wml_aux_header_part() -> @xml.Element {
  wml_aux_el("hdr", [], [
    wml_aux_paragraph([
      wml_aux_run([
        wml_aux_t("Header "),
        xe(NS_W, "noBreakHyphen", [], []),
        xe(NS_W, "softHyphen", [], []),
        xe(NS_W, "dayShort", [], []),
        xe(NS_W, "monthShort", [], []),
        xe(NS_W, "yearShort", [], []),
        xe(NS_W, "pgNum", [], []),
        xe(NS_W, "cr", [], []),
        xe(
          NS_W,
          "sym",
          [wml_aux_attr("font", "Wingdings"), wml_aux_attr("char", "F0FC")],
          [],
        ),
        xe(NS_W, "lastRenderedPageBreak", [], []),
      ]),
    ]),
  ])
}

///|
fn wml_aux_footer_part() -> @xml.Element {
  wml_aux_el("ftr", [], [
    wml_aux_paragraph([
      wml_aux_run([
        wml_aux_t("Footer "),
        xe(NS_W, "dayLong", [], []),
        xe(NS_W, "monthLong", [], []),
        xe(NS_W, "yearLong", [], []),
      ]),
    ]),
  ])
}

///|
fn wml_aux_note_doc_props(name : String, pos_value : String) -> @xml.Element {
  wml_aux_el(name, [], [
    w_val("pos", pos_value),
    w_val("numFmt", "decimal"),
    w_val("numStart", "1"),
    w_val("numRestart", "continuous"),
  ])
}

///|
fn wml_aux_annotation_refs_body() -> @xml.Element {
  wml_aux_el("body", [], [
    wml_aux_el("p", [], [
      wml_aux_run([wml_aux_t("Annotated ")]),
      xe(NS_W, "commentRangeStart", [wml_aux_attr("id", "0")], []),
      wml_aux_run([wml_aux_t("range")]),
      xe(NS_W, "commentRangeEnd", [wml_aux_attr("id", "0")], []),
      wml_aux_run([xe(NS_W, "commentReference", [wml_aux_attr("id", "0")], [])]),
      wml_aux_run([
        xe(NS_W, "footnoteReference", [wml_aux_attr("id", "1")], []),
        xe(NS_W, "endnoteReference", [wml_aux_attr("id", "1")], []),
      ]),
    ]),
    wml_aux_el("sectPr", [], [
      wml_aux_note_doc_props("footnotePr", "pageBottom"),
      wml_aux_note_doc_props("endnotePr", "docEnd"),
    ]),
  ])
}

///|
fn wml_aux_glossary_document_part() -> @xml.Element {
  wml_aux_el("glossaryDocument", [], [
    xe(NS_W, "background", [wml_aux_attr("color", "FFFFFF")], []),
    wml_aux_el("docParts", [], [
      wml_aux_el("docPart", [], [
        wml_aux_el("docPartPr", [], [
          xe(
            NS_W,
            "name",
            [
              wml_aux_attr("val", "Catalog Building Block"),
              wml_aux_attr("decorated", "1"),
            ],
            [],
          ),
          w_val("style", "Normal"),
          wml_aux_el("category", [], [
            w_val("name", "Catalog Category"),
            w_val("gallery", "docParts"),
          ]),
          xe(NS_W, "types", [wml_aux_attr("all", "0")], [
            Element(w_val("type", "normal")),
          ]),
          wml_aux_el("behaviors", [], [w_val("behavior", "content")]),
          w_val("description", "Catalog glossary coverage"),
          w_val("guid", "{11111111-2222-3333-4444-555555555555}"),
        ]),
        wml_aux_el("docPartBody", [], [
          wml_aux_paragraph([wml_aux_run([wml_aux_t("Glossary body")])]),
        ]),
      ]),
    ]),
  ])
}

///|
fn extras_wml_aux_parts(cases : Array[VisualCase]) -> Unit {
  cases.push({
    id: "settings-core",
    format: "docx:settings",
    category: "wml-aux",
    content: wml_settings_core_part(),
  })
  cases.push({
    id: "settings-compat",
    format: "docx:settings",
    category: "wml-aux",
    content: wml_settings_compat_part(),
  })
  cases.push({
    id: "web-settings",
    format: "docx:webSettings",
    category: "wml-aux",
    content: wml_web_settings_part(),
  })
  cases.push({
    id: "styles",
    format: "docx:styles",
    category: "wml-aux",
    content: wml_styles_part(),
  })
  cases.push({
    id: "font-table",
    format: "docx:fonts",
    category: "wml-aux",
    content: wml_font_table_part(),
  })
  cases.push({
    id: "comments-rich",
    format: "docx:comments",
    category: "wml-aux",
    content: wml_aux_comments_part(),
  })
  cases.push({
    id: "footnotes-rich",
    format: "docx:footnotes",
    category: "wml-aux",
    content: wml_aux_footnotes_part(),
  })
  cases.push({
    id: "endnotes-rich",
    format: "docx:endnotes",
    category: "wml-aux",
    content: wml_aux_endnotes_part(),
  })
  cases.push({
    id: "header-rich",
    format: "docx:header",
    category: "wml-aux",
    content: wml_aux_header_part(),
  })
  cases.push({
    id: "footer-rich",
    format: "docx:footer",
    category: "wml-aux",
    content: wml_aux_footer_part(),
  })
  cases.push({
    id: "annotation-refs-rich",
    format: "docx:annotationRefs",
    category: "wml-aux",
    content: wml_aux_annotation_refs_body(),
  })
  cases.push({
    id: "glossary-document-rich",
    format: "docx:glossary",
    category: "wml-aux",
    content: wml_aux_glossary_document_part(),
  })
}
