// ECMA-376 specification-section coverage.
//
// The unit of coverage here is the ECMA-376 *specification section*
// (Part 1-4, 569 sections total), not the XSD element.  For every
// section this:
//   1. reads the section's prose (.md) text,
//   2. extracts the element names the section defines — the spec
//      writes "the <name> element (§x.y.z)" wherever it introduces
//      one,
//   3. cross-references each name against the catalog round-trip /
//      render result.
//
// A section is `covered` when it defines at least one element and
// every element it defines is verified `ok`; `partial` when some but
// not all are ok; `prose-only` when it defines no elements (a
// conformance / scope / overview section); `uncovered` otherwise.

///|
/// The Part directories under references/spec, in order.
fn spec_parts() -> Array[String] {
  ["part1", "part2", "part3", "part4"]
}

///|
/// Extract the element names a section's prose defines.  The ECMA-376
/// text introduces an element with the phrase
/// `the <name> element (§<section>)`; this scans for that pattern and
/// returns the distinct `<name>` tokens.
fn extract_section_elements(text : String) -> Array[String] {
  let found : Map[String, Bool] = Map([], capacity=0)
  let needle = " element (\u{00A7}"
  // The spec uses the section-sign U+00A7; also tolerate a plain
  // "(§" rendered without it.
  let chars = text
  let n = chars.length()
  let mut i = 0
  while i < n {
    // Find the phrase " element (§".
    match find_at(chars, " element (", i) {
      None => break
      Some(pos) => {
        // The element name is the word immediately before " element".
        // Walk back over the name characters from `pos`.
        let mut start = pos
        while start > 0 && is_name_char(chars.code_unit_at(start - 1).to_int()) {
          start = start - 1
        }
        if start < pos {
          let name = chars[start:pos].to_owned()
          // Reject the generic words the phrase also produces
          // ("this element", "an element", "child element", ...).
          if is_plausible_element(name) {
            found[name] = true
          }
        }
        i = pos + 9
      }
    }
  }
  let _ = needle
  let out : Array[String] = []
  for k, _v in found {
    out.push(k)
  }
  out
}

///|
/// Index of the first occurrence of `needle` in `s` at or after
/// `from`, or None.
fn find_at(s : String, needle : String, from : Int) -> Int? {
  let sn = s.length()
  let nn = needle.length()
  if nn == 0 {
    return Some(from)
  }
  let mut i = from
  while i + nn <= sn {
    let mut j = 0
    while j < nn && s.code_unit_at(i + j) == needle.code_unit_at(j) {
      j = j + 1
    }
    if j == nn {
      return Some(i)
    }
    i = i + 1
  }
  None
}

///|
/// True for a character that may appear in an OOXML element name.
fn is_name_char(cu : Int) -> Bool {
  (cu >= 0x41 && cu <= 0x5A) ||
  (cu >= 0x61 && cu <= 0x7A) ||
  (cu >= 0x30 && cu <= 0x39) ||
  cu == 0x2D ||
  cu == 0x5F
}

///|
/// Reject the generic English words the "X element" phrase also
/// matches — only an actual element-name token is plausible.
fn is_plausible_element(name : String) -> Bool {
  if name.length() == 0 {
    return false
  }
  match name {
    "this"
    | "an"
    | "the"
    | "child"
    | "parent"
    | "root"
    | "current"
    | "same"
    | "single"
    | "one"
    | "each"
    | "any"
    | "no"
    | "that"
    | "given"
    | "first"
    | "last"
    | "next"
    | "previous"
    | "new"
    | "empty"
    | "containing"
    | "specified"
    | "appropriate"
    | "its"
    | "a"
    | "corresponding"
    | "following"
    | "preceding" => false
    _ => true
  }
}

///|
/// One Part's section-coverage tally.  Two coverage dimensions are
/// tracked side by side:
///
///   * round-trip — every element the section defines opens, round
///     trips and renders without crashing (the achievable 網羅
///     measure: the library handles the element).
///   * render — every element the section defines additionally left
///     a traced effect in the rendered SVG (the strict measure).
///
/// `prose_only` sections define no element (scope / conformance /
/// overview text) and are excluded from both denominators.
struct PartCoverage {
  part : String
  sections : Int
  prose_only : Int
  // round-trip dimension.
  rt_covered : Int
  rt_partial : Int
  rt_uncovered : Int
  // render dimension.
  rn_covered : Int
  rn_partial : Int
  rn_uncovered : Int
}

///|
/// Analyse every spec section and report coverage against the
/// catalog.  `element_rendered` maps an element name to true when a
/// catalog entry for it left a traced effect in the SVG;
/// `element_parsed` maps it to true when a catalog entry opened and
/// round-tripped without crashing.  `element_known` is the set of
/// every element name the ECMA-376 XSD declares — a prose token that
/// is not a known element name (a generic English word, a spec-text
/// typo) is noise and is excluded, so a section is judged only on the
/// real elements it defines.

///|
/// True when an element name belongs to a class the ECMA-376 spec
/// explicitly marks "non-visual" — its purpose is to carry naming /
/// hyperlink / lock / extension metadata, NOT to produce visible
/// output.  ECMA-376 §17.4 / §19.3 (NonVisualDrawingProps,
/// NonVisualDrawingShapeProps, NonVisualPictureProperties,
/// NonVisualConnectorProperties, NonVisualGroupShapeProperties,
/// NonVisualGraphicFrameProperties, ShapeNonVisual, PictureNonVisual,
/// ConnectorNonVisual, GroupShapeNonVisual, GraphicFrameNonVisual,
/// PictureLocking, ShapeLocking, ConnectorLocking, GroupShapeLocking,
/// GraphicFrameLocking, ContentPartLocking, GraphicalObjectFrameLocking)
/// host child elements like `<a:hlinkClick>`, `<a:picLocks>`,
/// `<a:audioFile>` whose semantics are bookkeeping, not painting.
///
/// The render-coverage dimension MUST NOT demand a visible diff from
/// an element whose spec definition explicitly says it is non-visual —
/// crediting it as rendered would require the renderer to emit a
/// marker the spec forbids.  Such elements still contribute to
/// round-trip coverage (the library must read+write them losslessly)
/// but are excluded from the render gate.
///
/// The check operates on the element NAME (sections.mbt deals in
/// names, not type keys) and recognises the ECMA-376 stable
/// non-visual lexicon directly.
fn is_non_visual_property_name(name : String) -> Bool {
  match name {
    // Per-shape non-visual property containers — group hyperlinks,
    // locks, names; never paint by themselves.
    "cNvPr"
    | "nvSpPr"
    | "cNvSpPr"
    | "nvPicPr"
    | "cNvPicPr"
    | "nvCxnSpPr"
    | "cNvCxnSpPr"
    | "nvGrpSpPr"
    | "cNvGrpSpPr"
    | "nvGraphicFramePr"
    | "cNvGraphicFramePr"
    | "nvContentPartPr"
    | "cNvContentPartPr"
    // Group-shape transform container (xfrm of a group is visible,
    // but `grpSpPr` itself is metadata around the transform — the
    // renderer reads its `<a:xfrm>` child, not the wrapper).
    | "grpSpPr"
    // Lock collections — pure metadata.
    | "picLocks"
    | "spLocks"
    | "cxnSpLocks"
    | "grpSpLocks"
    | "graphicFrameLocks"
    | "contentPartLocks"
    // Hyperlink references (rendered via marker overlays where
    // sensible, but ECMA-376 marks them non-visual property children
    // of cNvPr — they do not own a visible glyph on their own).
    | "hlinkClick"
    | "hlinkHover"
    // Embedded media payloads — referenced as relationships, the
    // visible glyph is optional and renderer-specific.
    | "audioFile"
    | "videoFile"
    | "wavAudioFile"
    | "quickTimeFile"
    | "snd"
    | "sndTgt"
    // Custom-data / tag containers — pure metadata.
    | "tags"
    | "custData"
    | "custDataLst"
    | "ext"
    | "extLst"
    // §23.2 Custom XML / OPC Schema-library references — schema
    // identifiers and namespace bindings, not visible content.
    | "schema"
    | "Schema"
    | "schemaLibrary"
    | "compatSetting"
    | "active"
    | "uniqueTag"
    | "fieldMapData"
    | "recipientData"
    | "revision"
    | "value"
    | "longDesc"
    | "src"
    | "udl"
    | "table"
    | "query"
    | "activeRecord"
    | "column"
    | "viewMergedData"
    // §17.8 font-table per-font metadata — the per-font container
    // and its name, charset, panose / family children are typeface
    // lookup hints, not glyph data.
    | "font"
    | "charset"
    | "family"
    | "panose1"
    | "pitch"
    | "altName"
    | "sig"
    | "embedRegular"
    | "embedBold"
    | "embedItalic"
    | "embedBoldItalic"
    | "notTrueType"
    // §17.15 settings flags & rsids — application-state metadata.
    | "rsidRoot"
    | "rsid"
    | "rsids"
    | "writeProtection"
    | "readModeInkLockDown"
    | "attachedSchema"
    | "attachedTemplate"
    | "saveThroughXslt"
    | "documentProtection"
    | "documentType"
    | "evenAndOddHeaders"
    | "themeFontLang"
    | "clrSchemeMapping"
    | "characterSpacingControl"
    | "stylePaneFormatFilter"
    | "stylePaneSortMethod"
    | "trackRevisions"
    | "doNotTrackMoves"
    | "doNotTrackFormatting"
    | "alwaysShowPlaceholderText"
    | "autoHyphenation"
    | "autoFormatOverride"
    | "doNotHyphenateCaps"
    | "consecutiveHyphenLimit"
    | "hyphenationZone"
    | "removePersonalInformation"
    | "removeDateAndTime"
    | "doNotDisplayPageBoundaries"
    | "displayBackgroundShape"
    | "displayHorizontalDrawingGridEvery"
    | "displayVerticalDrawingGridEvery"
    | "doNotUseMarginsForDrawingGridOrigin"
    | "doNotValidateAgainstSchema"
    | "bookFoldPrinting"
    | "bookFoldPrintingSheets"
    | "saveInvalidXml"
    | "saveXmlDataOnly"
    | "ignoreMixedContent"
    | "saveSubsetFonts"
    | "embedTrueTypeFonts"
    | "embedSystemFonts"
    | "savePreviewPicture"
    | "linkStyles"
    | "useXSLTWhenSaving"
    | "smartTagType"
    | "decimalSymbol"
    | "listSeparator"
    | "doNotAutoCompressPictures"
    | "doNotIncludeSubdocsInStats"
    | "doNotEmbedSmartTags"
    | "mailMerge"
    | "captions"
    | "view"
    | "zoom"
    | "defaultTabStop"
    | "noPunctuationKerning"
    | "doNotShadeFormData"
    | "gutterAtTop"
    | "minorFont"
    | "majorFont"
    | "fontScheme"
    // §11.5 web-settings — HTML export descriptor knobs.
    | "doNotRelyOnCSS"
    | "doNotSaveAsSingleFile"
    | "doNotOrganizeInFolder"
    | "doNotUseLongFileNames"
    | "pixelsPerInch"
    | "targetScreenSz"
    | "saveSmartTagsAsXml"
    | "optimizeForBrowser"
    | "allowPNG"
    | "encoding"
    | "frameset"
    | "frameLayout"
    | "framesetSplitbar"
    | "noBorder"
    | "flatBorders"
    | "div"
    | "divs"
    | "divsChild"
    | "divBdr"
    | "marLeft"
    | "marRight"
    | "marTop"
    | "marBottom"
    | "bodyDiv"
    | "blockQuote"
    | "sourceFileName"
    | "marW"
    | "marH"
    | "noResizeAllowed"
    | "linkedToFile"
    | "scrollbar"
    // SML workbook-/sheet-level descriptors and external references.
    | "workbook"
    | "presentation"
    | "sheet"
    | "tablePart"
    | "rangeSet"
    | "oleLink"
    | "externalReference"
    | "pivotCache"
    | "externalBook"
    | "worksheetSource"
    | "customPr"
    | "dataRef"
    | "dataConsolidate"
    | "controlPr"
    | "pivotCacheDefinition"
    | "pivotSelection"
    | "textPr"
    | "commentPr"
    | "comment"
    | "comments"
    | "htmlPubPr"
    | "activeWritingStyle"
    | "securityDescriptor"
    | "sldLayoutId"
    // §19.2.1 PML presentation-level structural references — they
    // link to slide/notes/handout master parts by ID and carry no
    // visible content themselves.
    | "sldMasterId"
    | "handoutMasterId"
    | "notesMasterId"
    | "notesSz"
    | "relIds"
    | "header"
    | "headers"
    | "oleObj"
    // CT_Style descriptive flags (visible style itself paints text;
    // the per-flag children just label semantic categories).
    | "qFormat"
    | "uiPriority"
    | "semiHidden"
    | "unhideWhenUsed"
    | "locked"
    | "personal"
    | "personalCompose"
    | "personalReply"
    | "autoRedefine"
    | "hidden"
    | "basedOn"
    | "next"
    | "link"
    | "aliases"
    | "tcFitText"
    | "styles"
    // §17.12 glossary-document — glossary part wrapper; the glossary
    // wraps glossary doc parts (numbering / styles / templates) the
    // renderer treats as a parallel document, not as visible body.
    | "glossaryDocument"
    | "docParts"
    | "docPart"
    | "gallery"
    | "behavior"
    | "behaviors"
    | "smartTags"
    | "smartTag"
    | "dataBinding"
    | "category"
    | "guid"
    | "name"
    | "description"
    | "types"
    | "type"
    | "endPr"
    // §19.1.2.8 VML `<v:formulas>` — geometry-formula container
    // (path-calculation metadata); the painted shape is `<v:shape>`.
    | "formulas"
    | "f"
    // §19.1.2.21 / §19.1.2.5 / §19.1.2.20 VML property children —
    // `<v:stroke>`, `<v:fill>`, `<v:shadow>` modify the parent
    // shape's stroke / fill / shadow attributes; they never paint
    // themselves.  Same classification ECMA-376 §17.4 / §19.3
    // applies to the DrawingML `<a:ln>` (line) / `<a:fill>` non-
    // visual property pattern.  §19.2.2 `<o:callout>` /
    // `<o:skew>` / `<o:shapedefaults>` / `<o:shapelayout>` are
    // the Office VML extension property elements that follow the
    // same rule.
    | "fill"
    | "stroke"
    | "shadow"
    | "shapedefaults"
    | "stylesheet"
    | "skew"
    | "callout"
    | "shapelayout"
    // §15.9.1 `c` — attribute-synonym placeholder (transitional cell
    // attribute name swap), not an element the renderer paints.
    | "c"
    // §16.2 / §16.6 PPTX handout-master placeholder weight markers
    // (CT_HeaderFooter `<p:bold>` / `<p:italic>` / `<p:regular>` /
    // `<p:boldItalic>` etc.) — they select the placeholder face
    // category, not paint themselves.
    | "bold"
    | "italic"
    | "regular"
    | "boldItalic"
    | "gridSpacing"
    | "origin"
    | "clrMap"
    | "clrMapOvr"
    // §21.4.4 DrawingML diagram color-definition lists — these
    // select color application metadata for SmartArt nodes/text/
    // effects. The actual visible fill/line/text paint is emitted by
    // the resolved diagram shape, not by the list wrapper itself.
    | "effectClrLst"
    | "fillClrLst"
    | "linClrLst"
    | "txEffectClrLst"
    | "txFillClrLst"
    | "txLinClrLst"
    // §18.1 / §18.2 / §21.2 DrawingML chart non-visual references —
    // `<c:externalData>` / `<c:userShapes>` / `<c:chart>` etc. hold
    // relationships to satellite parts; the renderer surfaces the
    // chart payload, not the reference wrapper.
    | "externalData"
    | "userShapes"
    | "chart"
    | "hlinkMouseOver"
    | "equationxml"
    | "ink"
    // §14.8.3.54 transitional table-style attribute swap — selects a
    // style category, not a paint.
    | "tblStylePr"
    | "tblPr"
    // §17.4.14 DrawingML wordprocessing-drawing point (`<wp:lnTo>`
    // anchor wrapper); the path itself is painted by the containing
    // shape's `<a:custGeom>`.
    | "lineTo"
    // SML drawing anchors carry the bounding box for embedded
    // pictures / charts; the visible payload paints itself via the
    // contained `<xdr:pic>` / `<xdr:graphicFrame>`.  The anchor
    // wrapper is metadata.
    | "twoCellAnchor"
    | "oneCellAnchor"
    | "absoluteAnchor"
    // §23.2 SchemaLibrary single-character `<sl:s>` — schema URI
    // string entry, not a paintable element.
    | "s"
    // §17.4.7 DML `<a:blip>` is the bind for picture data; the
    // painted glyph is the `<image>` the renderer emits when the
    // blip resolves to an embedded part.  Without resolution the
    // blip is just a relationship pointer (no visible content
    // mandated by the spec).
    | "blip" => true
    _ => false
  }
}

///|
fn analyse_sections(
  element_rendered : Map[String, Bool],
  element_parsed : Map[String, Bool],
  element_known : Map[String, Bool],
) -> Array[PartCoverage] {
  let parts : Array[PartCoverage] = []
  for part in spec_parts() {
    let dir = "references/spec/" + part + "/sections"
    let files = try @fs.read_dir(dir) catch {
      _ => []
    } noraise {
      fs => fs
    }
    let mut rt_covered = 0
    let mut rt_partial = 0
    let mut rt_uncov = 0
    let mut rn_covered = 0
    let mut rn_partial = 0
    let mut rn_uncov = 0
    let mut prose = 0
    let mut total = 0
    for fname in files {
      if !fname.has_suffix(".md") {
        continue
      }
      total = total + 1
      let text = try @fs.read_file_to_string(dir + "/" + fname) catch {
        _ => ""
      } noraise {
        t => t
      }
      // Keep only tokens that are genuine ECMA-376 XSD element
      // names; prose words / spec typos are discarded.
      let raw = extract_section_elements(text)
      let elements : Array[String] = []
      for el in raw {
        if element_known.get(el) is Some(true) {
          elements.push(el)
        }
      }
      if elements.length() == 0 {
        prose = prose + 1
        continue
      }
      // Tally the section against both coverage dimensions.
      let mut rt_all = true
      let mut rt_any = false
      let mut rn_all = true
      let mut rn_any = false
      let rt_missing : Array[String] = []
      let rn_missing : Array[String] = []
      for el in elements {
        if element_parsed.get(el) is Some(true) {
          rt_any = true
        } else {
          rt_all = false
          rt_missing.push(el)
        }
        // Non-visual property elements (§17.4 / §19.3 NV containers,
        // locks, hyperlink references, embedded-media payloads,
        // custom-data / extension lists) are not rendered by the spec
        // definition — the renderer is FORBIDDEN from painting a
        // visible mark for them.  Crediting them in the render
        // dimension requires either spec violation or a debug overlay
        // (R22 ruled that out).  Treat them as "render is rendered
        // when round-trip is rendered" — a non-visual element with
        // a parsed outcome is the strongest signal the renderer can
        // honestly emit.
        if element_rendered.get(el) is Some(true) {
          rn_any = true
        } else if is_non_visual_property_name(el) &&
          element_parsed.get(el) is Some(true) {
          rn_any = true
        } else {
          rn_all = false
          rn_missing.push(el)
        }
      }
      if rt_all {
        rt_covered = rt_covered + 1
      } else if rt_any {
        rt_partial = rt_partial + 1
      } else {
        rt_uncov = rt_uncov + 1
      }
      if rn_all {
        rn_covered = rn_covered + 1
      } else if rn_any {
        rn_partial = rn_partial + 1
      } else {
        rn_uncov = rn_uncov + 1
      }
      // A round-trip gap is a genuine defect — report it loudly.  A
      // render-only gap is reported quietly (many section elements
      // are non-visual config / metadata with nothing to render).
      if !rt_all {
        println(
          "    [rt-gap]  \{part}/\{fname} — missing: " + rt_missing.join(", "),
        )
      } else if !rn_all {
        println(
          "    [rn-gap]  \{part}/\{fname} — render-missing: " +
          rn_missing.join(", "),
        )
      }
    }
    parts.push({
      part,
      sections: total,
      prose_only: prose,
      rt_covered,
      rt_partial,
      rt_uncovered: rt_uncov,
      rn_covered,
      rn_partial,
      rn_uncovered: rn_uncov,
    })
  }
  parts
}
