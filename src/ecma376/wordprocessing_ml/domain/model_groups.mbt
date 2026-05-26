// ECMA-376 WordprocessingML §17 model groups — wml.xsd <xsd:group>
// declarations, typed as Moonbit sum types so callers branch on
// the actual schema arm rather than re-walking raw XML.
//
// The choice / sequence semantics from xsd are encoded as:
//   choice  → `enum Foo { A(...) | B(...) ... }`
//   sequence → `struct Foo { a : CT_A? ; b : CT_B? ; ... }`
//
// Mutually recursive groups (e.g. EG_RunLevelElts contains EG_RangeMarkupElements,
// EG_PContent contains EG_ContentRunContent, ...) are encoded by
// embedding the dependent enum directly in the parent enum.

// ─────────────────────────────────────────────────────────────────────
// EG_CellMarkupElements — §17.13.5.8 (cell-level track changes).
// 3-arm choice.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_CellMarkupElements {
  CellIns(CT_TrackChange)
  CellDel(CT_TrackChange)
  CellMerge(CT_CellMergeTrackChange)
} derive(Eq, Debug)

///|
pub fn parse_cell_markup_element(
  element : @xml.Element,
) -> EG_CellMarkupElements? raise SchemaViolation {
  match element.name.local_name {
    "cellIns" => Some(CellIns(CT_TrackChange::new(element)))
    "cellDel" => Some(CellDel(CT_TrackChange::new(element)))
    "cellMerge" => Some(CellMerge(CT_CellMergeTrackChange::new(element)))
    _ => None
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_RangeMarkupElements — §17.13.5.x (bookmark / range markup).
// 16-arm choice.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_RangeMarkupElements {
  BookmarkStart(CT_Bookmark)
  BookmarkEnd(CT_MarkupRange)
  MoveFromRangeStart(CT_MoveBookmark)
  MoveFromRangeEnd(CT_MarkupRange)
  MoveToRangeStart(CT_MoveBookmark)
  MoveToRangeEnd(CT_MarkupRange)
  CommentRangeStart(CT_MarkupRange)
  CommentRangeEnd(CT_MarkupRange)
  CustomXmlInsRangeStart(CT_TrackChange)
  CustomXmlInsRangeEnd(CT_Markup)
  CustomXmlDelRangeStart(CT_TrackChange)
  CustomXmlDelRangeEnd(CT_Markup)
  CustomXmlMoveFromRangeStart(CT_TrackChange)
  CustomXmlMoveFromRangeEnd(CT_Markup)
  CustomXmlMoveToRangeStart(CT_TrackChange)
  CustomXmlMoveToRangeEnd(CT_Markup)
} derive(Eq, Debug)

///|
pub fn parse_range_markup_element(
  element : @xml.Element,
) -> EG_RangeMarkupElements? raise SchemaViolation {
  match element.name.local_name {
    "bookmarkStart" => Some(BookmarkStart(CT_Bookmark::new(element)))
    "bookmarkEnd" => Some(BookmarkEnd(CT_MarkupRange::new(element)))
    "moveFromRangeStart" =>
      Some(MoveFromRangeStart(CT_MoveBookmark::new(element)))
    "moveFromRangeEnd" => Some(MoveFromRangeEnd(CT_MarkupRange::new(element)))
    "moveToRangeStart" => Some(MoveToRangeStart(CT_MoveBookmark::new(element)))
    "moveToRangeEnd" => Some(MoveToRangeEnd(CT_MarkupRange::new(element)))
    "commentRangeStart" => Some(CommentRangeStart(CT_MarkupRange::new(element)))
    "commentRangeEnd" => Some(CommentRangeEnd(CT_MarkupRange::new(element)))
    "customXmlInsRangeStart" =>
      Some(CustomXmlInsRangeStart(CT_TrackChange::new(element)))
    "customXmlInsRangeEnd" =>
      Some(CustomXmlInsRangeEnd(CT_Markup::new(element)))
    "customXmlDelRangeStart" =>
      Some(CustomXmlDelRangeStart(CT_TrackChange::new(element)))
    "customXmlDelRangeEnd" =>
      Some(CustomXmlDelRangeEnd(CT_Markup::new(element)))
    "customXmlMoveFromRangeStart" =>
      Some(CustomXmlMoveFromRangeStart(CT_TrackChange::new(element)))
    "customXmlMoveFromRangeEnd" =>
      Some(CustomXmlMoveFromRangeEnd(CT_Markup::new(element)))
    "customXmlMoveToRangeStart" =>
      Some(CustomXmlMoveToRangeStart(CT_TrackChange::new(element)))
    "customXmlMoveToRangeEnd" =>
      Some(CustomXmlMoveToRangeEnd(CT_Markup::new(element)))
    _ => None
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_HdrFtrReferences — §17.10.2 / §17.10.5 (sectPr header/footer ref).
// 2-arm choice.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_HdrFtrReferences {
  HeaderReference(CT_HdrFtrRef)
  FooterReference(CT_HdrFtrRef)
} derive(Eq, Debug)

///|
pub fn parse_hdr_ftr_reference_element(
  element : @xml.Element,
) -> EG_HdrFtrReferences? raise SchemaViolation {
  match element.name.local_name {
    "headerReference" => Some(HeaderReference(CT_HdrFtrRef::new(element)))
    "footerReference" => Some(FooterReference(CT_HdrFtrRef::new(element)))
    _ => None
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_FtnEdnNumProps — §17.11.x (footnote/endnote numbering options).
// 2-element sequence (both optional).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_FtnEdnNumProps {
  num_start : CT_DecimalNumber?
  num_restart : CT_NumRestart?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_ParaRPrTrackChanges — §17.3.2 (paragraph mark run track changes).
// 4-element sequence (all optional).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_ParaRPrTrackChanges {
  ins : CT_TrackChange?
  del : CT_TrackChange?
  move_from : CT_TrackChange?
  move_to : CT_TrackChange?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_SectPrContents — §17.6 (section properties body).
// 20-element sequence (all optional).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_SectPrContents {
  footnote_pr : CT_FtnProps?
  endnote_pr : CT_EdnProps?
  type_ : CT_SectType?
  pg_sz : CT_PageSz?
  pg_mar : CT_PageMar?
  paper_src : CT_PaperSource?
  pg_borders : CT_PageBorders?
  ln_num_type : CT_LineNumber?
  pg_num_type : CT_PageNumber?
  cols : CT_Columns?
  form_prot : CT_OnOff?
  v_align : CT_VerticalJc?
  no_endnote : CT_OnOff?
  title_pg : CT_OnOff?
  text_direction : CT_TextDirection?
  bidi : CT_OnOff?
  rtl_gutter : CT_OnOff?
  doc_grid : CT_DocGrid?
  printer_settings : CT_Rel?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_RPrBase — §17.3.2.30 (single run-prop choice; 41 arms).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_RPrBase {
  RStyle(CT_String)
  RFonts(CT_Fonts)
  B(CT_OnOff)
  BCs(CT_OnOff)
  I(CT_OnOff)
  ICs(CT_OnOff)
  Caps(CT_OnOff)
  SmallCaps(CT_OnOff)
  Strike(CT_OnOff)
  Dstrike(CT_OnOff)
  Outline(CT_OnOff)
  Shadow(CT_OnOff)
  Emboss(CT_OnOff)
  Imprint(CT_OnOff)
  NoProof(CT_OnOff)
  SnapToGrid(CT_OnOff)
  Vanish(CT_OnOff)
  WebHidden(CT_OnOff)
  Color(CT_Color)
  Spacing(CT_SignedTwipsMeasure)
  W(CT_TextScale)
  Kern(CT_HpsMeasure)
  Position(CT_SignedHpsMeasure)
  Sz(CT_HpsMeasure)
  SzCs(CT_HpsMeasure)
  Highlight(CT_Highlight)
  U(CT_Underline)
  Effect(CT_TextEffect)
  Bdr(CT_Border)
  Shd(CT_Shd)
  FitText(CT_FitText)
  VertAlign(CT_VerticalAlignRun)
  Rtl(CT_OnOff)
  Cs(CT_OnOff)
  Em(CT_Em)
  Lang(CT_Language)
  EastAsianLayout(CT_EastAsianLayout)
  SpecVanish(CT_OnOff)
  OMath(CT_OnOff)
} derive(Eq, Debug)

///|
pub fn parse_rpr_base_element(
  element : @xml.Element,
) -> EG_RPrBase? raise SchemaViolation {
  match element.name.local_name {
    "rStyle" => Some(RStyle(CT_String::new(element)))
    "rFonts" => Some(RFonts(CT_Fonts::new(element)))
    "b" => Some(B(CT_OnOff::new(element)))
    "bCs" => Some(BCs(CT_OnOff::new(element)))
    "i" => Some(I(CT_OnOff::new(element)))
    "iCs" => Some(ICs(CT_OnOff::new(element)))
    "caps" => Some(Caps(CT_OnOff::new(element)))
    "smallCaps" => Some(SmallCaps(CT_OnOff::new(element)))
    "strike" => Some(Strike(CT_OnOff::new(element)))
    "dstrike" => Some(Dstrike(CT_OnOff::new(element)))
    "outline" => Some(Outline(CT_OnOff::new(element)))
    "shadow" => Some(Shadow(CT_OnOff::new(element)))
    "emboss" => Some(Emboss(CT_OnOff::new(element)))
    "imprint" => Some(Imprint(CT_OnOff::new(element)))
    "noProof" => Some(NoProof(CT_OnOff::new(element)))
    "snapToGrid" => Some(SnapToGrid(CT_OnOff::new(element)))
    "vanish" => Some(Vanish(CT_OnOff::new(element)))
    "webHidden" => Some(WebHidden(CT_OnOff::new(element)))
    "color" => Some(Color(CT_Color::new(element)))
    "spacing" => Some(Spacing(CT_SignedTwipsMeasure::new(element)))
    "w" => Some(W(CT_TextScale::new(element)))
    "kern" => Some(Kern(CT_HpsMeasure::new(element)))
    "position" => Some(Position(CT_SignedHpsMeasure::new(element)))
    "sz" => Some(Sz(CT_HpsMeasure::new(element)))
    "szCs" => Some(SzCs(CT_HpsMeasure::new(element)))
    "highlight" => Some(Highlight(CT_Highlight::new(element)))
    "u" => Some(U(CT_Underline::new(element)))
    "effect" => Some(Effect(CT_TextEffect::new(element)))
    "bdr" => Some(Bdr(CT_Border::new(element)))
    "shd" => Some(Shd(CT_Shd::new(element)))
    "fitText" => Some(FitText(CT_FitText::new(element)))
    "vertAlign" => Some(VertAlign(CT_VerticalAlignRun::new(element)))
    "rtl" => Some(Rtl(CT_OnOff::new(element)))
    "cs" => Some(Cs(CT_OnOff::new(element)))
    "em" => Some(Em(CT_Em::new(element)))
    "lang" => Some(Lang(CT_Language::new(element)))
    "eastAsianLayout" => Some(EastAsianLayout(CT_EastAsianLayout::new(element)))
    "specVanish" => Some(SpecVanish(CT_OnOff::new(element)))
    "oMath" => Some(OMath(CT_OnOff::new(element)))
    _ => None
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_RPrContent — sequence (EG_RPrBase* + rPrChange?).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_RPrContent {
  bases : Array[EG_RPrBase]
  r_pr_change : CT_RPrChange?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_RPr — sequence (rPr?).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) struct EG_RPr {
  r_pr : CT_RPr?
} derive(Eq, Debug)

// ─────────────────────────────────────────────────────────────────────
// EG_RPrMath — §17.3.5.x choice (rPr / ins / del).
// EG_RPr is itself optional-rPr; we mirror it directly here.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_RPrMath {
  RPr(CT_RPr)
  MathIns(CT_MathCtrlIns)
  MathDel(CT_MathCtrlDel)
} derive(Eq, Debug)

///|
pub fn parse_rpr_math_element(
  element : @xml.Element,
) -> EG_RPrMath? raise SchemaViolation {
  match element.name.local_name {
    "rPr" => Some(RPr(CT_RPr::new(element)))
    "ins" => Some(MathIns(CT_MathCtrlIns::new(element)))
    "del" => Some(MathDel(CT_MathCtrlDel::new(element)))
    _ => None
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_RunInnerContent — §17.3.1.x (run inner content; 32 arms).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_RunInnerContent {
  Br(CT_Br)
  T(CT_Text)
  ContentPart(CT_Rel)
  DelText(CT_Text)
  InstrText(CT_Text)
  DelInstrText(CT_Text)
  NoBreakHyphen(CT_Empty)
  SoftHyphen(CT_Empty)
  DayShort(CT_Empty)
  MonthShort(CT_Empty)
  YearShort(CT_Empty)
  DayLong(CT_Empty)
  MonthLong(CT_Empty)
  YearLong(CT_Empty)
  AnnotationRef(CT_Empty)
  FootnoteRef(CT_Empty)
  EndnoteRef(CT_Empty)
  Separator(CT_Empty)
  ContinuationSeparator(CT_Empty)
  Sym(CT_Sym)
  PgNum(CT_Empty)
  Cr(CT_Empty)
  Tab(CT_Empty)
  Object(CT_Object)
  Pict(CT_Picture)
  FldChar(CT_FldChar)
  Ruby(CT_Ruby)
  FootnoteReference(CT_FtnEdnRef)
  EndnoteReference(CT_FtnEdnRef)
  CommentReference(CT_Markup)
  Drawing(CT_Drawing)
  Ptab(CT_PTab)
  LastRenderedPageBreak(CT_Empty)
} derive(Eq, Debug)

///|
pub fn parse_run_inner_content_element(
  element : @xml.Element,
) -> EG_RunInnerContent? raise SchemaViolation {
  match element.name.local_name {
    "br" => Some(Br(CT_Br::new(element)))
    "t" => Some(T(CT_Text::new(element)))
    "contentPart" => Some(ContentPart(CT_Rel::new(element)))
    "delText" => Some(DelText(CT_Text::new(element)))
    "instrText" => Some(InstrText(CT_Text::new(element)))
    "delInstrText" => Some(DelInstrText(CT_Text::new(element)))
    "noBreakHyphen" => Some(NoBreakHyphen(CT_Empty::new(element)))
    "softHyphen" => Some(SoftHyphen(CT_Empty::new(element)))
    "dayShort" => Some(DayShort(CT_Empty::new(element)))
    "monthShort" => Some(MonthShort(CT_Empty::new(element)))
    "yearShort" => Some(YearShort(CT_Empty::new(element)))
    "dayLong" => Some(DayLong(CT_Empty::new(element)))
    "monthLong" => Some(MonthLong(CT_Empty::new(element)))
    "yearLong" => Some(YearLong(CT_Empty::new(element)))
    "annotationRef" => Some(AnnotationRef(CT_Empty::new(element)))
    "footnoteRef" => Some(FootnoteRef(CT_Empty::new(element)))
    "endnoteRef" => Some(EndnoteRef(CT_Empty::new(element)))
    "separator" => Some(Separator(CT_Empty::new(element)))
    "continuationSeparator" =>
      Some(ContinuationSeparator(CT_Empty::new(element)))
    "sym" => Some(Sym(CT_Sym::new(element)))
    "pgNum" => Some(PgNum(CT_Empty::new(element)))
    "cr" => Some(Cr(CT_Empty::new(element)))
    "tab" => Some(Tab(CT_Empty::new(element)))
    "object" => Some(Object(CT_Object::new(element)))
    "pict" => Some(Pict(CT_Picture::new(element)))
    "fldChar" => Some(FldChar(CT_FldChar::new(element)))
    "ruby" => Some(Ruby(CT_Ruby::new(element)))
    "footnoteReference" => Some(FootnoteReference(CT_FtnEdnRef::new(element)))
    "endnoteReference" => Some(EndnoteReference(CT_FtnEdnRef::new(element)))
    "commentReference" => Some(CommentReference(CT_Markup::new(element)))
    "drawing" => Some(Drawing(CT_Drawing::new(element)))
    "ptab" => Some(Ptab(CT_PTab::new(element)))
    "lastRenderedPageBreak" =>
      Some(LastRenderedPageBreak(CT_Empty::new(element)))
    _ => None
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_MathContent — §22.1 (m:oMathPara / m:oMath embed point).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_MathContent {
  OMathPara(@m.CT_OMathPara)
  OMath(@m.CT_OMath)
} derive(Eq, Debug)

///|
/// Branch on the OMML element's local name. The element MUST be in
/// the `m:` namespace (xsd uses element ref); we accept by local name
/// for forward compatibility.
pub fn parse_math_content_element(
  element : @xml.Element,
) -> EG_MathContent? raise SchemaViolation {
  match element.name.local_name {
    "oMathPara" =>
      Some(OMathPara(wrap_m_violation(() => @m.CT_OMathPara::new(element))))
    "oMath" => Some(OMath(wrap_m_violation(fn() { @m.CT_OMath::new(element) })))
    _ => None
  }
}

///|
fn[T] wrap_m_violation(
  body : () -> T raise @m.SchemaViolation,
) -> T raise SchemaViolation {
  body() catch {
    @m.SchemaViolation(_) =>
      raise SchemaViolation(
        type_name="EG_MathContent",
        value="",
        reason="m: namespace child failed validation",
      )
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_RunLevelElts — §17.x (mid-run control flow; 9 arms; mutual rec).
// Embeds EG_RangeMarkupElements + EG_MathContent.
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_RunLevelElts {
  ProofErr(CT_ProofErr)
  PermStart(CT_PermStart)
  PermEnd(CT_Perm)
  RangeMarkup(EG_RangeMarkupElements)
  Ins(CT_RunTrackChange)
  Del(CT_RunTrackChange)
  MoveFrom(CT_RunTrackChange)
  MoveTo(CT_RunTrackChange)
  MathContent(EG_MathContent)
} derive(Eq, Debug)

///|
pub fn parse_run_level_element(
  element : @xml.Element,
) -> EG_RunLevelElts? raise SchemaViolation {
  match element.name.local_name {
    "proofErr" => Some(ProofErr(CT_ProofErr::new(element)))
    "permStart" => Some(PermStart(CT_PermStart::new(element)))
    "permEnd" => Some(PermEnd(CT_Perm::new(element)))
    "ins" => Some(Ins(CT_RunTrackChange::new(element)))
    "del" => Some(Del(CT_RunTrackChange::new(element)))
    "moveFrom" => Some(MoveFrom(CT_RunTrackChange::new(element)))
    "moveTo" => Some(MoveTo(CT_RunTrackChange::new(element)))
    _ =>
      match parse_range_markup_element(element) {
        Some(r) => Some(RangeMarkup(r))
        None =>
          match parse_math_content_element(element) {
            Some(m) => Some(MathContent(m))
            None => None
          }
      }
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_PContentBase — §17.13.x (paragraph base content; 3 arms).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_PContentBase {
  CustomXml(CT_CustomXmlRun)
  FldSimple(CT_SimpleField)
  Hyperlink(CT_Hyperlink)
} derive(Eq, Debug)

///|
pub fn parse_pcontent_base_element(
  element : @xml.Element,
) -> EG_PContentBase? raise SchemaViolation {
  match element.name.local_name {
    "customXml" => Some(CustomXml(CT_CustomXmlRun::new(element)))
    "fldSimple" => Some(FldSimple(CT_SimpleField::new(element)))
    "hyperlink" => Some(Hyperlink(CT_Hyperlink::new(element)))
    _ => None
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_ContentRunContentBase — §17.13.x (run-content base; 3 arms).
// Embeds EG_RunLevelElts (one of the choice arms is a group ref).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_ContentRunContentBase {
  SmartTag(CT_SmartTagRun)
  Sdt(CT_SdtRun)
  RunLevel(EG_RunLevelElts)
} derive(Eq, Debug)

///|
pub fn parse_content_run_content_base_element(
  element : @xml.Element,
) -> EG_ContentRunContentBase? raise SchemaViolation {
  match element.name.local_name {
    "smartTag" => Some(SmartTag(CT_SmartTagRun::new(element)))
    "sdt" => Some(Sdt(CT_SdtRun::new(element)))
    _ =>
      match parse_run_level_element(element) {
        Some(r) => Some(RunLevel(r))
        None => None
      }
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_PContentMath — §22 (paragraph content inside oMath).
// Pure delegation choice (EG_PContentBase | EG_ContentRunContentBase).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_PContentMath {
  Base(EG_PContentBase)
  RunContentBase(EG_ContentRunContentBase)
} derive(Eq, Debug)

///|
pub fn parse_pcontent_math_element(
  element : @xml.Element,
) -> EG_PContentMath? raise SchemaViolation {
  match parse_pcontent_base_element(element) {
    Some(b) => Some(Base(b))
    None =>
      match parse_content_run_content_base_element(element) {
        Some(r) => Some(RunContentBase(r))
        None => None
      }
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_ContentRunContent — §17.13.x (run-content extended; 7 arms).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_ContentRunContent {
  CustomXml(CT_CustomXmlRun)
  SmartTag(CT_SmartTagRun)
  Sdt(CT_SdtRun)
  Dir(CT_DirContentRun)
  Bdo(CT_BdoContentRun)
  R(CT_R)
  RunLevel(EG_RunLevelElts)
} derive(Eq, Debug)

///|
pub fn parse_content_run_content_element(
  element : @xml.Element,
) -> EG_ContentRunContent? raise SchemaViolation {
  match element.name.local_name {
    "customXml" => Some(CustomXml(CT_CustomXmlRun::new(element)))
    "smartTag" => Some(SmartTag(CT_SmartTagRun::new(element)))
    "sdt" => Some(Sdt(CT_SdtRun::new(element)))
    "dir" => Some(Dir(CT_DirContentRun::new(element)))
    "bdo" => Some(Bdo(CT_BdoContentRun::new(element)))
    "r" => Some(R(CT_R::new(element)))
    _ =>
      match parse_run_level_element(element) {
        Some(r) => Some(RunLevel(r))
        None => None
      }
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_PContent — §17.3.1 (paragraph content; 4 arms).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_PContent {
  RunContent(EG_ContentRunContent)
  FldSimple(CT_SimpleField)
  Hyperlink(CT_Hyperlink)
  SubDoc(CT_Rel)
} derive(Eq, Debug)

///|
pub fn parse_pcontent_element(
  element : @xml.Element,
) -> EG_PContent? raise SchemaViolation {
  match element.name.local_name {
    "fldSimple" => Some(FldSimple(CT_SimpleField::new(element)))
    "hyperlink" => Some(Hyperlink(CT_Hyperlink::new(element)))
    "subDoc" => Some(SubDoc(CT_Rel::new(element)))
    _ =>
      match parse_content_run_content_element(element) {
        Some(r) => Some(RunContent(r))
        None => None
      }
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_ContentBlockContent — §17.2.x (block-level content; 5 arms).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_ContentBlockContent {
  CustomXml(CT_CustomXmlBlock)
  Sdt(CT_SdtBlock)
  P(CT_P)
  Tbl(CT_Tbl)
  RunLevel(EG_RunLevelElts)
} derive(Eq, Debug)

///|
pub fn parse_content_block_content_element(
  element : @xml.Element,
) -> EG_ContentBlockContent? raise SchemaViolation {
  match element.name.local_name {
    "customXml" => Some(CustomXml(CT_CustomXmlBlock::new(element)))
    "sdt" => Some(Sdt(CT_SdtBlock::new(element)))
    "p" => Some(P(CT_P::new(element)))
    "tbl" => Some(Tbl(CT_Tbl::new(element)))
    _ =>
      match parse_run_level_element(element) {
        Some(r) => Some(RunLevel(r))
        None => None
      }
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_ContentRowContent — §17.4.x (table row content; 4 arms).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_ContentRowContent {
  Tr(CT_Row)
  CustomXml(CT_CustomXmlRow)
  Sdt(CT_SdtRow)
  RunLevel(EG_RunLevelElts)
} derive(Eq, Debug)

///|
pub fn parse_content_row_content_element(
  element : @xml.Element,
) -> EG_ContentRowContent? raise SchemaViolation {
  match element.name.local_name {
    "tr" => Some(Tr(CT_Row::new(element)))
    "customXml" => Some(CustomXml(CT_CustomXmlRow::new(element)))
    "sdt" => Some(Sdt(CT_SdtRow::new(element)))
    _ =>
      match parse_run_level_element(element) {
        Some(r) => Some(RunLevel(r))
        None => None
      }
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_ContentCellContent — §17.4.x (table cell content; 4 arms).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_ContentCellContent {
  Tc(CT_Tc)
  CustomXml(CT_CustomXmlCell)
  Sdt(CT_SdtCell)
  RunLevel(EG_RunLevelElts)
} derive(Eq, Debug)

///|
pub fn parse_content_cell_content_element(
  element : @xml.Element,
) -> EG_ContentCellContent? raise SchemaViolation {
  match element.name.local_name {
    "tc" => Some(Tc(CT_Tc::new(element)))
    "customXml" => Some(CustomXml(CT_CustomXmlCell::new(element)))
    "sdt" => Some(Sdt(CT_SdtCell::new(element)))
    _ =>
      match parse_run_level_element(element) {
        Some(r) => Some(RunLevel(r))
        None => None
      }
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_BlockLevelChunkElts — §17.2.x (delegates to EG_ContentBlockContent).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_BlockLevelChunkElts {
  ContentBlock(EG_ContentBlockContent)
} derive(Eq, Debug)

///|
pub fn parse_block_level_chunk_element(
  element : @xml.Element,
) -> EG_BlockLevelChunkElts? raise SchemaViolation {
  match parse_content_block_content_element(element) {
    Some(c) => Some(ContentBlock(c))
    None => None
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_BlockLevelElts — §17.2.x (delegates to BlockLevelChunk + altChunk).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_BlockLevelElts {
  Chunk(EG_BlockLevelChunkElts)
  AltChunk(CT_AltChunk)
} derive(Eq, Debug)

///|
pub fn parse_block_level_element(
  element : @xml.Element,
) -> EG_BlockLevelElts? raise SchemaViolation {
  match element.name.local_name {
    "altChunk" => Some(AltChunk(CT_AltChunk::new(element)))
    _ =>
      match parse_block_level_chunk_element(element) {
        Some(c) => Some(Chunk(c))
        None => None
      }
  }
}

// ─────────────────────────────────────────────────────────────────────
// EG_RubyContent — §17.3.3 (ruby content; 2 arms).
// ─────────────────────────────────────────────────────────────────────

///|
pub(all) enum EG_RubyContent {
  R(CT_R)
  RunLevel(EG_RunLevelElts)
} derive(Eq, Debug)

///|
pub fn parse_ruby_content_element(
  element : @xml.Element,
) -> EG_RubyContent? raise SchemaViolation {
  match element.name.local_name {
    "r" => Some(R(CT_R::new(element)))
    _ =>
      match parse_run_level_element(element) {
        Some(r) => Some(RunLevel(r))
        None => None
      }
  }
}

// ─────────────────────────────────────────────────────────────────────
// Collect helpers — turn an `Array[@xml.Element]` (typically the
// document-order children of a CT_* container) into a typed array of
// the corresponding sum type. Used by complex_types.mbt to populate
// the `Array[EG_*]` fields on each CT_* projection.
// ─────────────────────────────────────────────────────────────────────

///|
pub fn collect_cell_markup_elements(
  elements : Array[@xml.Element],
) -> Array[EG_CellMarkupElements] raise SchemaViolation {
  let out : Array[EG_CellMarkupElements] = []
  for e in elements {
    match parse_cell_markup_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_range_markup_elements(
  elements : Array[@xml.Element],
) -> Array[EG_RangeMarkupElements] raise SchemaViolation {
  let out : Array[EG_RangeMarkupElements] = []
  for e in elements {
    match parse_range_markup_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_hdr_ftr_references(
  elements : Array[@xml.Element],
) -> Array[EG_HdrFtrReferences] raise SchemaViolation {
  let out : Array[EG_HdrFtrReferences] = []
  for e in elements {
    match parse_hdr_ftr_reference_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_rpr_base_elements(
  elements : Array[@xml.Element],
) -> Array[EG_RPrBase] raise SchemaViolation {
  let out : Array[EG_RPrBase] = []
  for e in elements {
    match parse_rpr_base_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_rpr_math_elements(
  elements : Array[@xml.Element],
) -> Array[EG_RPrMath] raise SchemaViolation {
  let out : Array[EG_RPrMath] = []
  for e in elements {
    match parse_rpr_math_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_run_inner_content(
  elements : Array[@xml.Element],
) -> Array[EG_RunInnerContent] raise SchemaViolation {
  let out : Array[EG_RunInnerContent] = []
  for e in elements {
    match parse_run_inner_content_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_math_content(
  elements : Array[@xml.Element],
) -> Array[EG_MathContent] raise SchemaViolation {
  let out : Array[EG_MathContent] = []
  for e in elements {
    match parse_math_content_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_run_level_elements(
  elements : Array[@xml.Element],
) -> Array[EG_RunLevelElts] raise SchemaViolation {
  let out : Array[EG_RunLevelElts] = []
  for e in elements {
    match parse_run_level_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_pcontent_base(
  elements : Array[@xml.Element],
) -> Array[EG_PContentBase] raise SchemaViolation {
  let out : Array[EG_PContentBase] = []
  for e in elements {
    match parse_pcontent_base_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_content_run_content_base(
  elements : Array[@xml.Element],
) -> Array[EG_ContentRunContentBase] raise SchemaViolation {
  let out : Array[EG_ContentRunContentBase] = []
  for e in elements {
    match parse_content_run_content_base_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_pcontent_math(
  elements : Array[@xml.Element],
) -> Array[EG_PContentMath] raise SchemaViolation {
  let out : Array[EG_PContentMath] = []
  for e in elements {
    match parse_pcontent_math_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_content_run_content(
  elements : Array[@xml.Element],
) -> Array[EG_ContentRunContent] raise SchemaViolation {
  let out : Array[EG_ContentRunContent] = []
  for e in elements {
    match parse_content_run_content_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_pcontent(
  elements : Array[@xml.Element],
) -> Array[EG_PContent] raise SchemaViolation {
  let out : Array[EG_PContent] = []
  for e in elements {
    match parse_pcontent_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_content_block_content(
  elements : Array[@xml.Element],
) -> Array[EG_ContentBlockContent] raise SchemaViolation {
  let out : Array[EG_ContentBlockContent] = []
  for e in elements {
    match parse_content_block_content_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_content_row_content(
  elements : Array[@xml.Element],
) -> Array[EG_ContentRowContent] raise SchemaViolation {
  let out : Array[EG_ContentRowContent] = []
  for e in elements {
    match parse_content_row_content_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_content_cell_content(
  elements : Array[@xml.Element],
) -> Array[EG_ContentCellContent] raise SchemaViolation {
  let out : Array[EG_ContentCellContent] = []
  for e in elements {
    match parse_content_cell_content_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_block_level_chunk(
  elements : Array[@xml.Element],
) -> Array[EG_BlockLevelChunkElts] raise SchemaViolation {
  let out : Array[EG_BlockLevelChunkElts] = []
  for e in elements {
    match parse_block_level_chunk_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_block_level_elements(
  elements : Array[@xml.Element],
) -> Array[EG_BlockLevelElts] raise SchemaViolation {
  let out : Array[EG_BlockLevelElts] = []
  for e in elements {
    match parse_block_level_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

///|
pub fn collect_ruby_content(
  elements : Array[@xml.Element],
) -> Array[EG_RubyContent] raise SchemaViolation {
  let out : Array[EG_RubyContent] = []
  for e in elements {
    match parse_ruby_content_element(e) {
      Some(v) => out.push(v)
      None => ()
    }
  }
  out
}

// ─────────────────────────────────────────────────────────────────────
// Round-trip element accessors. Each EG_* sum type can resurface its
// raw `@xml.Element` so callers that legitimately need the source XML
// (writers, debugging, generic walkers) don't have to switch on every
// arm. The accessor returns the element of whichever leaf was matched.
// ─────────────────────────────────────────────────────────────────────

///|
pub fn EG_BlockLevelElts::source_element(
  self : EG_BlockLevelElts,
) -> @xml.Element {
  match self {
    Chunk(c) => c.source_element()
    AltChunk(a) => a.element
  }
}

///|
pub fn EG_BlockLevelChunkElts::source_element(
  self : EG_BlockLevelChunkElts,
) -> @xml.Element {
  match self {
    ContentBlock(c) => c.source_element()
  }
}

///|
pub fn EG_ContentBlockContent::source_element(
  self : EG_ContentBlockContent,
) -> @xml.Element {
  match self {
    CustomXml(c) => c.element
    Sdt(s) => s.element
    P(p) => p.element
    Tbl(t) => t.element
    RunLevel(r) => r.source_element()
  }
}

///|
pub fn EG_RunLevelElts::source_element(self : EG_RunLevelElts) -> @xml.Element {
  match self {
    ProofErr(p) => p.element
    PermStart(p) => p.element
    PermEnd(p) => p.element
    RangeMarkup(r) => r.source_element()
    Ins(r) => r.element
    Del(r) => r.element
    MoveFrom(r) => r.element
    MoveTo(r) => r.element
    MathContent(m) => m.source_element()
  }
}

///|
pub fn EG_RangeMarkupElements::source_element(
  self : EG_RangeMarkupElements,
) -> @xml.Element {
  match self {
    BookmarkStart(c) => c.element
    BookmarkEnd(c) => c.element
    MoveFromRangeStart(c) => c.element
    MoveFromRangeEnd(c) => c.element
    MoveToRangeStart(c) => c.element
    MoveToRangeEnd(c) => c.element
    CommentRangeStart(c) => c.element
    CommentRangeEnd(c) => c.element
    CustomXmlInsRangeStart(c) => c.element
    CustomXmlInsRangeEnd(c) => c.element
    CustomXmlDelRangeStart(c) => c.element
    CustomXmlDelRangeEnd(c) => c.element
    CustomXmlMoveFromRangeStart(c) => c.element
    CustomXmlMoveFromRangeEnd(c) => c.element
    CustomXmlMoveToRangeStart(c) => c.element
    CustomXmlMoveToRangeEnd(c) => c.element
  }
}

///|
pub fn EG_MathContent::source_element(self : EG_MathContent) -> @xml.Element {
  match self {
    OMathPara(m) => m.element
    OMath(m) => m.element
  }
}

///|
/// Decode an `<w:sectPr>` (or `<w:sectPrBase>`) element into the
/// typed EG_SectPrContents sequence. Each of the 19 optional ordered
/// children (footnotePr / endnotePr / type / pgSz / pgMar /
/// paperSrc / pgBorders / lnNumType / pgNumType / cols / formProt /
/// vAlign / noEndnote / titlePg / textDirection / bidi / rtlGutter /
/// docGrid / printerSettings) is captured by its first occurrence
/// per the schema. Mirrors EG_SectPrContents at Annex A.4.3 wml.xsd.
pub fn decode_sect_pr_contents(
  element : @xml.Element,
) -> EG_SectPrContents raise SchemaViolation {
  let mut footnote_pr : CT_FtnProps? = None
  let mut endnote_pr : CT_EdnProps? = None
  let mut type_ : CT_SectType? = None
  let mut pg_sz : CT_PageSz? = None
  let mut pg_mar : CT_PageMar? = None
  let mut paper_src : CT_PaperSource? = None
  let mut pg_borders : CT_PageBorders? = None
  let mut ln_num_type : CT_LineNumber? = None
  let mut pg_num_type : CT_PageNumber? = None
  let mut cols : CT_Columns? = None
  let mut form_prot : CT_OnOff? = None
  let mut v_align : CT_VerticalJc? = None
  let mut no_endnote : CT_OnOff? = None
  let mut title_pg : CT_OnOff? = None
  let mut text_direction : CT_TextDirection? = None
  let mut bidi : CT_OnOff? = None
  let mut rtl_gutter : CT_OnOff? = None
  let mut doc_grid : CT_DocGrid? = None
  let mut printer_settings : CT_Rel? = None
  for child in element.children {
    if child is @xml.Node::Element(e) {
      match e.name.local_name {
        "footnotePr" =>
          if footnote_pr is None {
            footnote_pr = Some(CT_FtnProps::new(e))
          }
        "endnotePr" =>
          if endnote_pr is None {
            endnote_pr = Some(CT_EdnProps::new(e))
          }
        "type" => if type_ is None { type_ = Some(CT_SectType::new(e)) }
        "pgSz" => if pg_sz is None { pg_sz = Some(CT_PageSz::new(e)) }
        "pgMar" => if pg_mar is None { pg_mar = Some(CT_PageMar::new(e)) }
        "paperSrc" =>
          if paper_src is None {
            paper_src = Some(CT_PaperSource::new(e))
          }
        "pgBorders" =>
          if pg_borders is None {
            pg_borders = Some(CT_PageBorders::new(e))
          }
        "lnNumType" =>
          if ln_num_type is None {
            ln_num_type = Some(CT_LineNumber::new(e))
          }
        "pgNumType" =>
          if pg_num_type is None {
            pg_num_type = Some(CT_PageNumber::new(e))
          }
        "cols" => if cols is None { cols = Some(CT_Columns::new(e)) }
        "formProt" =>
          if form_prot is None {
            form_prot = Some(CT_OnOff::new(e))
          }
        "vAlign" => if v_align is None { v_align = Some(CT_VerticalJc::new(e)) }
        "noEndnote" =>
          if no_endnote is None {
            no_endnote = Some(CT_OnOff::new(e))
          }
        "titlePg" => if title_pg is None { title_pg = Some(CT_OnOff::new(e)) }
        "textDirection" =>
          if text_direction is None {
            text_direction = Some(CT_TextDirection::new(e))
          }
        "bidi" => if bidi is None { bidi = Some(CT_OnOff::new(e)) }
        "rtlGutter" =>
          if rtl_gutter is None {
            rtl_gutter = Some(CT_OnOff::new(e))
          }
        "docGrid" => if doc_grid is None { doc_grid = Some(CT_DocGrid::new(e)) }
        "printerSettings" =>
          if printer_settings is None {
            printer_settings = Some(CT_Rel::new(e))
          }
        _ => ()
      }
    }
  }
  {
    footnote_pr,
    endnote_pr,
    type_,
    pg_sz,
    pg_mar,
    paper_src,
    pg_borders,
    ln_num_type,
    pg_num_type,
    cols,
    form_prot,
    v_align,
    no_endnote,
    title_pg,
    text_direction,
    bidi,
    rtl_gutter,
    doc_grid,
    printer_settings,
  }
}
