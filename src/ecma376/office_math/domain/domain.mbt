///|
/// OMML domain types: m:oMath, m:f, m:rad, m:nary, …
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/office_math/domain"
}

// ────────────────────────────────────────────────────────────────────────────
// Chunk 1 typed CT_X structs.
//
// All chunk1 types follow the same discipline: each typed field reflects an
// XSD attribute or child element from shared-math.xsd. The raw `element`
// field is preserved alongside the typed fields so that builder/round-trip
// code paths can continue to emit the source XML verbatim while typed
// callers consume the parsed projection.
//
// `new` parses required attributes via the corresponding ST_X simple-type
// parser, raising SchemaViolation on lexical / facet violations. Child
// elements are walked once, dispatched by local name, and stored typed.
// ────────────────────────────────────────────────────────────────────────────

///|
/// XSD complex type CT_Integer255 — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Integer255`. Attributes: `val`.
/// Wraps a single integer in the closed range [1, 255] used by §22.1.2.21
/// count and other matrix structural properties.
pub(all) struct CT_Integer255 {
  /// @val (ST_Integer255, required) — integer in closed range [1, 255].
  val : ST_Integer255
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Integer255 by parsing the required `val` attribute per
/// §22.1.3.6 (ST_Integer255 facet [1, 255]).
pub fn CT_Integer255::new(
  element : @xml.Element,
) -> CT_Integer255 raise SchemaViolation {
  let val = ST_Integer255::parse(require_attr(element, "val", "CT_Integer255"))
  { val, element }
}

///|
/// XSD complex type CT_Integer2 — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Integer2`. Attributes: `val`.
/// Wraps a signed integer in [-2, +2] used by §22.1.2.6 argSz (Argument
/// Size).
pub(all) struct CT_Integer2 {
  /// @val (ST_Integer2, required) — integer in closed range [-2, +2].
  val : ST_Integer2
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Integer2 by parsing the required `val` attribute per
/// §22.1.3.5 (ST_Integer2 facet [-2, +2]).
pub fn CT_Integer2::new(
  element : @xml.Element,
) -> CT_Integer2 raise SchemaViolation {
  let val = ST_Integer2::parse(require_attr(element, "val", "CT_Integer2"))
  { val, element }
}

///|
/// XSD complex type CT_SpacingRule — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_SpacingRule`. Attributes: `val`.
/// Wraps a spacing-rule code in [0, 4] used by §22.1.2.93 rSpRule and
/// §22.1.2.19 cGpRule for matrix row/column spacing.
pub(all) struct CT_SpacingRule {
  /// @val (ST_SpacingRule, required) — spacing-rule code in [0, 4].
  val : ST_SpacingRule
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SpacingRule by parsing the required `val` attribute per
/// §22.1.3.11 (ST_SpacingRule facet [0, 4]).
pub fn CT_SpacingRule::new(
  element : @xml.Element,
) -> CT_SpacingRule raise SchemaViolation {
  let val = ST_SpacingRule::parse(
    require_attr(element, "val", "CT_SpacingRule"),
  )
  { val, element }
}

///|
/// XSD complex type CT_UnSignedInteger — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_UnSignedInteger`. Attributes: `val`.
/// Wraps an xsd:unsignedInt value (range 0 .. 2^32 − 1) used by §22.1.2.92
/// rSp, §22.1.2.18 cGp, §22.1.2.22 cSp matrix spacing measures.
pub(all) struct CT_UnSignedInteger {
  /// @val (ST_UnSignedInteger, required) — unsigned 32-bit integer.
  val : ST_UnSignedInteger
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_UnSignedInteger by parsing the required `val` attribute per
/// §22.1.3.14 (xsd:unsignedInt).
pub fn CT_UnSignedInteger::new(
  element : @xml.Element,
) -> CT_UnSignedInteger raise SchemaViolation {
  let val = ST_UnSignedInteger::parse(
    require_attr(element, "val", "CT_UnSignedInteger"),
  )
  { val, element }
}

///|
/// XSD complex type CT_Char — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Char`. Attributes: `val`.
/// OMML character property per §22.1.2.20 chr.
pub(all) struct CT_Char {
  /// @val (ST_Char, required) — single character (xsd:string max length 1).
  val : ST_Char
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Char by parsing the required `val` attribute per
/// §22.1.3.3 (ST_Char max length 1).
pub fn CT_Char::new(element : @xml.Element) -> CT_Char raise SchemaViolation {
  let val = ST_Char::parse(require_attr(element, "val", "CT_Char"))
  { val, element }
}

///|
/// XSD complex type CT_OnOff — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_OnOff`. Attributes: `val`.
/// Wraps a tristate on/off toggle used by §22.1.2.74 nor, §22.1.2.4 alnScr,
/// §22.1.2.27 degHide, and the other OMML boolean properties. The `val`
/// attribute uses the shared ST_OnOff lexical set ({1,0,true,false,on,off});
/// it is preserved verbatim as the lexical String so the round-trip writer
/// can emit the original token, while the typed `value` carries the decoded
/// tri-state.
pub(all) struct CT_OnOff {
  /// @val (s:ST_OnOff, optional) — None when the attribute is absent (the
  /// default-true semantics defined by the OMML toggle property).
  val : String?
  /// Decoded tri-state: `Some(true)` for 1/true/on, `Some(false)` for
  /// 0/false/off, `None` when the attribute is absent or has an
  /// unrecognised token (callers treat that as the default-true state per
  /// §17.18.66 ST_OnOff).
  value : Bool?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OnOff by capturing the optional `val` attribute and
/// decoding it against s:ST_OnOff (§17.18.66 / Part 1 §22.9).
pub fn CT_OnOff::new(element : @xml.Element) -> CT_OnOff {
  let val = attr_value(element, "val")
  let value = match val {
    Some(v) => decode_on_off(v)
    None => None
  }
  { val, value, element }
}

///|
/// XSD complex type CT_String — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_String`. Attributes: `val`.
/// Wraps an optional string used by §22.1.2 mathFont and the other OMML
/// string-valued properties. The attribute is optional and stored as
/// String?.
pub(all) struct CT_String {
  /// @val (s:ST_String, optional) — None when the attribute is absent.
  val : String?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_String by capturing the optional `val` attribute.
pub fn CT_String::new(element : @xml.Element) -> CT_String {
  { val: attr_value(element, "val"), element }
}

///|
/// XSD complex type CT_XAlign — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_XAlign`. Attributes: `val`.
/// Wraps a horizontal alignment token (center / left / right) used by
/// §22.1.2 mcJc (matrix column justification). The `val` lexical form is
/// preserved as a String because the s:ST_XAlign enumeration lives in the
/// shared simple types package (kept out of office_math/domain to avoid a
/// cross-package import cycle).
pub(all) struct CT_XAlign {
  /// @val (s:ST_XAlign, required) — horizontal alignment lexical token.
  val : String
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_XAlign by capturing the required `val` attribute.
pub fn CT_XAlign::new(
  element : @xml.Element,
) -> CT_XAlign raise SchemaViolation {
  { val: require_attr(element, "val", "CT_XAlign"), element }
}

///|
/// XSD complex type CT_YAlign — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_YAlign`. Attributes: `val`.
/// Wraps a vertical alignment token (top / center / bottom / baseline)
/// used by §22.1.2.9 baseJc.
pub(all) struct CT_YAlign {
  /// @val (s:ST_YAlign, required) — vertical alignment lexical token.
  val : String
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_YAlign by capturing the required `val` attribute.
pub fn CT_YAlign::new(
  element : @xml.Element,
) -> CT_YAlign raise SchemaViolation {
  { val: require_attr(element, "val", "CT_YAlign"), element }
}

///|
/// XSD complex type CT_Shp — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Shp`. Attributes: `val`.
/// Wraps the centered/match delimiter shape enumeration used by §22.1.2.97
/// shp.
pub(all) struct CT_Shp {
  /// @val (ST_Shp, required) — delimiter shape enumeration.
  val : ST_Shp
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Shp by parsing the required `val` attribute against ST_Shp.
pub fn CT_Shp::new(element : @xml.Element) -> CT_Shp raise SchemaViolation {
  let val = ST_Shp::parse(require_attr(element, "val", "CT_Shp"))
  { val, element }
}

///|
/// XSD complex type CT_FType — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_FType`. Attributes: `val`.
/// Wraps the fraction-type enumeration (bar / skw / lin / noBar) used by
/// §22.1.2.118 type (Fraction Type).
pub(all) struct CT_FType {
  /// @val (ST_FType, required) — fraction type enumeration.
  val : ST_FType
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_FType by parsing the required `val` attribute against
/// ST_FType.
pub fn CT_FType::new(element : @xml.Element) -> CT_FType raise SchemaViolation {
  let val = ST_FType::parse(require_attr(element, "val", "CT_FType"))
  { val, element }
}

///|
/// XSD complex type CT_LimLoc — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_LimLoc`. Attributes: `val`.
/// Wraps the limit-location enumeration (undOvr / subSup) used by §22.1
/// intLim and naryLim.
pub(all) struct CT_LimLoc {
  /// @val (ST_LimLoc, required) — limit-location enumeration.
  val : ST_LimLoc
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimLoc by parsing the required `val` attribute against
/// ST_LimLoc.
pub fn CT_LimLoc::new(
  element : @xml.Element,
) -> CT_LimLoc raise SchemaViolation {
  let val = ST_LimLoc::parse(require_attr(element, "val", "CT_LimLoc"))
  { val, element }
}

///|
/// XSD complex type CT_TopBot — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_TopBot`. Attributes: `val`.
/// Wraps the top/bot enumeration used by §22.1.2.84 pos and §22.1.2.119
/// vertJc.
pub(all) struct CT_TopBot {
  /// @val (ST_TopBot, required) — top/bot enumeration.
  val : ST_TopBot
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_TopBot by parsing the required `val` attribute against
/// ST_TopBot.
pub fn CT_TopBot::new(
  element : @xml.Element,
) -> CT_TopBot raise SchemaViolation {
  let val = ST_TopBot::parse(require_attr(element, "val", "CT_TopBot"))
  { val, element }
}

///|
/// XSD complex type CT_Script — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Script`. Attributes: `val`.
/// Wraps the script-style enumeration (roman / script / fraktur /
/// double-struck / sans-serif / monospace) used by §22.1.2.94 scr.
pub(all) struct CT_Script {
  /// @val (ST_Script, optional) — script style enumeration.
  val : ST_Script?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Script by parsing the optional `val` attribute against
/// ST_Script.
pub fn CT_Script::new(
  element : @xml.Element,
) -> CT_Script raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(v) => Some(ST_Script::parse(v))
    None => None
  }
  { val, element }
}

///|
/// XSD complex type CT_Style — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Style`. Attributes: `val`.
/// Wraps the math-text style enumeration (p / b / i / bi) used by
/// §22.1.2.111 sty (style).
pub(all) struct CT_Style {
  /// @val (ST_Style, optional) — math-text style enumeration.
  val : ST_Style?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Style by parsing the optional `val` attribute against
/// ST_Style.
pub fn CT_Style::new(element : @xml.Element) -> CT_Style raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(v) => Some(ST_Style::parse(v))
    None => None
  }
  { val, element }
}

///|
/// XSD complex type CT_ManualBreak — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_ManualBreak`. Attributes: `alnAt`.
/// Used by §22.1.2.15 brk (manual line break) inside CT_RPR and CT_BoxPr.
pub(all) struct CT_ManualBreak {
  /// @alnAt (ST_Integer255, optional) — None when the attribute is absent.
  aln_at : ST_Integer255?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_ManualBreak by parsing the optional `alnAt` attribute per
/// §22.1.3.6 (ST_Integer255 facet [1, 255]).
pub fn CT_ManualBreak::new(
  element : @xml.Element,
) -> CT_ManualBreak raise SchemaViolation {
  let aln_at = match attr_value(element, "alnAt") {
    Some(v) => Some(ST_Integer255::parse(v))
    None => None
  }
  { aln_at, element }
}

///|
/// XSD complex type CT_RPR — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_RPR`. Child elements: `lit`,
/// `nor`, `brk`, `aln`. Child types: `CT_OnOff`, `CT_ManualBreak`.
/// Run properties for an OMML run (§22.1.2.91 rPr). The optional `nor`
/// child participates in a choice with EG_ScriptStyle (scr? sty?); both
/// branches are typed because XSD child names are disjoint.
pub(all) struct CT_RPR {
  /// <lit> (CT_OnOff, optional) — literal-text run flag.
  lit : CT_OnOff?
  /// <nor> (CT_OnOff, optional) — normal-text run flag (choice with
  /// EG_ScriptStyle).
  nor : CT_OnOff?
  /// <scr> (CT_Script, optional) — script style from EG_ScriptStyle.
  scr : CT_Script?
  /// <sty> (CT_Style, optional) — math-text style from EG_ScriptStyle.
  sty : CT_Style?
  /// <brk> (CT_ManualBreak, optional) — manual line break.
  brk : CT_ManualBreak?
  /// <aln> (CT_OnOff, optional) — alignment flag.
  aln : CT_OnOff?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_RPR by walking the run-property children once and binding
/// each known local name to its typed slot.
pub fn CT_RPR::new(element : @xml.Element) -> CT_RPR raise SchemaViolation {
  let mut lit : CT_OnOff? = None
  let mut nor : CT_OnOff? = None
  let mut scr : CT_Script? = None
  let mut sty : CT_Style? = None
  let mut brk : CT_ManualBreak? = None
  let mut aln : CT_OnOff? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "lit" => lit = Some(CT_OnOff::new(e))
          "nor" => nor = Some(CT_OnOff::new(e))
          "scr" => scr = Some(CT_Script::new(e))
          "sty" => sty = Some(CT_Style::new(e))
          "brk" => brk = Some(CT_ManualBreak::new(e))
          "aln" => aln = Some(CT_OnOff::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { lit, nor, scr, sty, brk, aln, element }
}

///|
/// XSD complex type CT_Text — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Text`. Base: `s:ST_String`.
/// Attribute groups referenced: `xml:space`.
/// Run text content (§22.1.2.116 t). The base text payload is stored as a
/// String along with the optional xml:space attribute.
pub(all) struct CT_Text {
  /// Simple content (s:ST_String) — the concatenated text and CDATA payload.
  value : String
  /// @xml:space (optional) — "preserve" / "default" white-space hint.
  space : String?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Text by reading the simple-content text and the optional
/// xml:space attribute. xml:space lookups consider both the bound URI
/// (http://www.w3.org/XML/1998/namespace) and the literal "xml" prefix so
/// the parser tolerates documents that don't bind the xml namespace
/// explicitly.
pub fn CT_Text::new(element : @xml.Element) -> CT_Text {
  let value = element_text(element)
  let space = xml_space(element)
  { value, space, element }
}

///|
/// XSD complex type CT_R — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_R`. Child elements: `rPr`, `t`.
/// Child types: `CT_RPR`, `CT_Text`.
/// OMML math run (§22.1.2.87 r). Beyond the typed `rPr` and the `t` text
/// children, run-inner-content nodes from w:EG_RunInnerContent are
/// preserved as their raw @xml.Element (their typed projection lives in
/// wordprocessing_ml/domain).
pub(all) struct CT_R {
  /// <rPr> (CT_RPR, optional) — run properties.
  r_pr : CT_RPR?
  /// <t>* (CT_Text, zero or more) — run text nodes from the
  /// inner-content choice.
  t : Array[CT_Text]
  /// EG_RPr and EG_RunInnerContent passthrough children preserved as raw
  /// XML; they round-trip through the writer without being typed here.
  inner_content : Array[@xml.Element]
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_R by routing children into the typed slots (rPr, t) and
/// keeping any other element children as raw passthrough nodes.
pub fn CT_R::new(element : @xml.Element) -> CT_R raise SchemaViolation {
  let mut r_pr : CT_RPR? = None
  let t : Array[CT_Text] = []
  let inner_content : Array[@xml.Element] = []
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "rPr" => r_pr = Some(CT_RPR::new(e))
          "t" => t.push(CT_Text::new(e))
          _ => inner_content.push(e)
        }
      _ => ()
    }
  }
  { r_pr, t, inner_content, element }
}

///|
/// XSD complex type CT_CtrlPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_CtrlPr`.
/// Control properties for OMML structural objects (§22.1.2.23 ctrlPr).
/// The EG_RPrMath children belong to the wordprocessing_ml run-property
/// group, so their typed projection lives in that package; here they are
/// preserved as raw XML for round-trip.
pub(all) struct CT_CtrlPr {
  /// w:EG_RPrMath passthrough children preserved as raw XML.
  r_pr_math : Array[@xml.Element]
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_CtrlPr, collecting every element child as part of the
/// EG_RPrMath passthrough payload.
pub fn CT_CtrlPr::new(element : @xml.Element) -> CT_CtrlPr {
  let r_pr_math : Array[@xml.Element] = []
  for child in element.children {
    match child {
      Element(e) => r_pr_math.push(e)
      _ => ()
    }
  }
  { r_pr_math, element }
}

///|
/// XSD complex type CT_AccPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_AccPr`. Child elements: `chr`,
/// `ctrlPr`. Child types: `CT_Char`, `CT_CtrlPr`.
/// Accent-object properties (§22.1.2.2 accPr).
pub(all) struct CT_AccPr {
  /// <chr> (CT_Char, optional) — accent character.
  chr : CT_Char?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_AccPr by binding the optional chr and ctrlPr children.
pub fn CT_AccPr::new(element : @xml.Element) -> CT_AccPr raise SchemaViolation {
  let mut chr : CT_Char? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "chr" => chr = Some(CT_Char::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { chr, ctrl_pr, element }
}

///|
/// XSD complex type CT_Acc — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Acc`. Child elements: `accPr`,
/// `e`. Child types: `CT_AccPr`, `CT_OMathArg`.
/// Accent object (§22.1.2.1 acc). The required `e` child is a CT_OMathArg
/// argument carrying the base under the accent.
pub(all) struct CT_Acc {
  /// <accPr> (CT_AccPr, optional) — accent properties.
  acc_pr : CT_AccPr?
  /// <e> (CT_OMathArg, required) — base argument under the accent.
  e : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Acc, requiring the `e` child and accepting an optional
/// accPr. Raises SchemaViolation when the mandatory `e` argument is
/// missing.
pub fn CT_Acc::new(element : @xml.Element) -> CT_Acc raise SchemaViolation {
  let mut acc_pr : CT_AccPr? = None
  let mut e_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "accPr" => acc_pr = Some(CT_AccPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Acc/e", value="")
  }
  { acc_pr, e, element }
}

///|
/// XSD complex type CT_BarPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_BarPr`. Child elements: `pos`,
/// `ctrlPr`. Child types: `CT_TopBot`, `CT_CtrlPr`.
/// Bar properties (§22.1.2.8 barPr).
pub(all) struct CT_BarPr {
  /// <pos> (CT_TopBot, optional) — bar position above/below.
  pos : CT_TopBot?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BarPr by binding the optional pos and ctrlPr children.
pub fn CT_BarPr::new(element : @xml.Element) -> CT_BarPr raise SchemaViolation {
  let mut pos : CT_TopBot? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "pos" => pos = Some(CT_TopBot::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { pos, ctrl_pr, element }
}

///|
/// XSD complex type CT_Bar — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Bar`. Child elements: `barPr`,
/// `e`. Child types: `CT_BarPr`, `CT_OMathArg`.
/// Bar object (§22.1.2.7 bar) with optional barPr and a required
/// CT_OMathArg argument under the bar.
pub(all) struct CT_Bar {
  /// <barPr> (CT_BarPr, optional) — bar properties.
  bar_pr : CT_BarPr?
  /// <e> (CT_OMathArg, required) — argument under the bar.
  e : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Bar; raises SchemaViolation when the mandatory `e`
/// argument is missing.
pub fn CT_Bar::new(element : @xml.Element) -> CT_Bar raise SchemaViolation {
  let mut bar_pr : CT_BarPr? = None
  let mut e_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "barPr" => bar_pr = Some(CT_BarPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Bar/e", value="")
  }
  { bar_pr, e, element }
}

///|
/// XSD complex type CT_BoxPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_BoxPr`. Child elements: `opEmu`,
/// `noBreak`, `diff`, `brk`, `aln`, `ctrlPr`. Child types: `CT_OnOff`,
/// `CT_ManualBreak`, `CT_CtrlPr`.
/// Box object properties (§22.1.2.14 boxPr).
pub(all) struct CT_BoxPr {
  /// <opEmu> (CT_OnOff, optional) — operator emulator flag (§22.1.2.80).
  op_emu : CT_OnOff?
  /// <noBreak> (CT_OnOff, optional) — suppress line break flag.
  no_break : CT_OnOff?
  /// <diff> (CT_OnOff, optional) — differential flag (§22.1.2.29).
  diff : CT_OnOff?
  /// <brk> (CT_ManualBreak, optional) — manual line break.
  brk : CT_ManualBreak?
  /// <aln> (CT_OnOff, optional) — alignment flag.
  aln : CT_OnOff?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BoxPr by binding each optional child slot.
pub fn CT_BoxPr::new(element : @xml.Element) -> CT_BoxPr raise SchemaViolation {
  let mut op_emu : CT_OnOff? = None
  let mut no_break : CT_OnOff? = None
  let mut diff : CT_OnOff? = None
  let mut brk : CT_ManualBreak? = None
  let mut aln : CT_OnOff? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "opEmu" => op_emu = Some(CT_OnOff::new(e))
          "noBreak" => no_break = Some(CT_OnOff::new(e))
          "diff" => diff = Some(CT_OnOff::new(e))
          "brk" => brk = Some(CT_ManualBreak::new(e))
          "aln" => aln = Some(CT_OnOff::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { op_emu, no_break, diff, brk, aln, ctrl_pr, element }
}

///|
/// XSD complex type CT_Box — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Box`. Child elements: `boxPr`,
/// `e`. Child types: `CT_BoxPr`, `CT_OMathArg`.
/// Box object (§22.1.2.13 box) with optional properties and a required
/// argument.
pub(all) struct CT_Box {
  /// <boxPr> (CT_BoxPr, optional) — box properties.
  box_pr : CT_BoxPr?
  /// <e> (CT_OMathArg, required) — argument inside the box.
  e : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Box; raises SchemaViolation when the mandatory `e`
/// argument is missing.
pub fn CT_Box::new(element : @xml.Element) -> CT_Box raise SchemaViolation {
  let mut box_pr : CT_BoxPr? = None
  let mut e_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "boxPr" => box_pr = Some(CT_BoxPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Box/e", value="")
  }
  { box_pr, e, element }
}

///|
/// XSD complex type CT_BorderBoxPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_BorderBoxPr`. Child elements:
/// `hideTop`, `hideBot`, `hideLeft`, `hideRight`, `strikeH`, `strikeV`,
/// `strikeBLTR`, `strikeTLBR`, `ctrlPr`. Child types: `CT_OnOff`,
/// `CT_CtrlPr`.
/// Border-box properties (§22.1.2.12 borderBoxPr).
pub(all) struct CT_BorderBoxPr {
  /// <hideTop> (CT_OnOff, optional) — hide top edge (§22.1.2.47).
  hide_top : CT_OnOff?
  /// <hideBot> (CT_OnOff, optional) — hide bottom edge (§22.1.2.44).
  hide_bot : CT_OnOff?
  /// <hideLeft> (CT_OnOff, optional) — hide left edge (§22.1.2.45).
  hide_left : CT_OnOff?
  /// <hideRight> (CT_OnOff, optional) — hide right edge (§22.1.2.46).
  hide_right : CT_OnOff?
  /// <strikeH> (CT_OnOff, optional) — horizontal strikethrough (§22.1.2.108).
  strike_h : CT_OnOff?
  /// <strikeV> (CT_OnOff, optional) — vertical strikethrough (§22.1.2.110).
  strike_v : CT_OnOff?
  /// <strikeBLTR> (CT_OnOff, optional) — diagonal strikethrough
  /// bottom-left to top-right (§22.1.2.107).
  strike_bltr : CT_OnOff?
  /// <strikeTLBR> (CT_OnOff, optional) — diagonal strikethrough
  /// top-left to bottom-right (§22.1.2.109).
  strike_tlbr : CT_OnOff?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BorderBoxPr by routing each optional child to its slot.
/// Every child is CT_OnOff or CT_CtrlPr, whose `new` functions never
/// raise, so this constructor stays infallible.
pub fn CT_BorderBoxPr::new(element : @xml.Element) -> CT_BorderBoxPr {
  let mut hide_top : CT_OnOff? = None
  let mut hide_bot : CT_OnOff? = None
  let mut hide_left : CT_OnOff? = None
  let mut hide_right : CT_OnOff? = None
  let mut strike_h : CT_OnOff? = None
  let mut strike_v : CT_OnOff? = None
  let mut strike_bltr : CT_OnOff? = None
  let mut strike_tlbr : CT_OnOff? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "hideTop" => hide_top = Some(CT_OnOff::new(e))
          "hideBot" => hide_bot = Some(CT_OnOff::new(e))
          "hideLeft" => hide_left = Some(CT_OnOff::new(e))
          "hideRight" => hide_right = Some(CT_OnOff::new(e))
          "strikeH" => strike_h = Some(CT_OnOff::new(e))
          "strikeV" => strike_v = Some(CT_OnOff::new(e))
          "strikeBLTR" => strike_bltr = Some(CT_OnOff::new(e))
          "strikeTLBR" => strike_tlbr = Some(CT_OnOff::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  {
    hide_top,
    hide_bot,
    hide_left,
    hide_right,
    strike_h,
    strike_v,
    strike_bltr,
    strike_tlbr,
    ctrl_pr,
    element,
  }
}

///|
/// XSD complex type CT_BorderBox — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_BorderBox`. Child elements:
/// `borderBoxPr`, `e`. Child types: `CT_BorderBoxPr`, `CT_OMathArg`.
/// Border-box object (§22.1.2.11 borderBox).
pub(all) struct CT_BorderBox {
  /// <borderBoxPr> (CT_BorderBoxPr, optional) — border-box properties.
  border_box_pr : CT_BorderBoxPr?
  /// <e> (CT_OMathArg, required) — argument inside the border box.
  e : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BorderBox; raises SchemaViolation when the mandatory `e`
/// argument is missing.
pub fn CT_BorderBox::new(
  element : @xml.Element,
) -> CT_BorderBox raise SchemaViolation {
  let mut border_box_pr : CT_BorderBoxPr? = None
  let mut e_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "borderBoxPr" =>
            border_box_pr = Some(CT_BorderBoxPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_BorderBox/e", value="")
  }
  { border_box_pr, e, element }
}

///|
/// XSD complex type CT_DPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_DPr`. Child elements: `begChr`,
/// `sepChr`, `endChr`, `grow`, `shp`, `ctrlPr`. Child types: `CT_Char`,
/// `CT_OnOff`, `CT_Shp`, `CT_CtrlPr`.
/// Delimiter properties (§22.1.2.31 dPr).
pub(all) struct CT_DPr {
  /// <begChr> (CT_Char, optional) — opening delimiter character (§22.1.2.10).
  beg_chr : CT_Char?
  /// <sepChr> (CT_Char, optional) — separator delimiter character
  /// (§22.1.2.95).
  sep_chr : CT_Char?
  /// <endChr> (CT_Char, optional) — closing delimiter character
  /// (§22.1.2.33).
  end_chr : CT_Char?
  /// <grow> (CT_OnOff, optional) — grow delimiters to enclosed argument
  /// (§22.1.2.43).
  grow : CT_OnOff?
  /// <shp> (CT_Shp, optional) — delimiter shape (§22.1.2.97).
  shp : CT_Shp?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_DPr by routing each optional child to its slot.
pub fn CT_DPr::new(element : @xml.Element) -> CT_DPr raise SchemaViolation {
  let mut beg_chr : CT_Char? = None
  let mut sep_chr : CT_Char? = None
  let mut end_chr : CT_Char? = None
  let mut grow : CT_OnOff? = None
  let mut shp : CT_Shp? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "begChr" => beg_chr = Some(CT_Char::new(e))
          "sepChr" => sep_chr = Some(CT_Char::new(e))
          "endChr" => end_chr = Some(CT_Char::new(e))
          "grow" => grow = Some(CT_OnOff::new(e))
          "shp" => shp = Some(CT_Shp::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { beg_chr, sep_chr, end_chr, grow, shp, ctrl_pr, element }
}

///|
/// XSD complex type CT_D — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_D`. Child elements: `dPr`, `e`.
/// Child types: `CT_DPr`, `CT_OMathArg`.
/// Delimiter object (§22.1.2.24 d) with one or more enclosed CT_OMathArg
/// arguments.
pub(all) struct CT_D {
  /// <dPr> (CT_DPr, optional) — delimiter properties.
  d_pr : CT_DPr?
  /// <e>* (CT_OMathArg, one or more by schema; tolerated as Array to
  /// surface zero-argument input via callers rather than raising during
  /// best-effort tree construction).
  e : Array[CT_OMathArg]
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_D by collecting every `e` child into the argument array
/// and binding the optional dPr.
pub fn CT_D::new(element : @xml.Element) -> CT_D raise SchemaViolation {
  let mut d_pr : CT_DPr? = None
  let e : Array[CT_OMathArg] = []
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "dPr" => d_pr = Some(CT_DPr::new(child_element))
          "e" => e.push(CT_OMathArg::new(child_element))
          _ => ()
        }
      _ => ()
    }
  }
  { d_pr, e, element }
}

///|
/// XSD complex type CT_EqArrPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_EqArrPr`. Child elements:
/// `baseJc`, `maxDist`, `objDist`, `rSpRule`, `rSp`, `ctrlPr`. Child
/// types: `CT_YAlign`, `CT_OnOff`, `CT_SpacingRule`, `CT_UnSignedInteger`,
/// `CT_CtrlPr`.
/// Equation-array properties (§22.1.2.35 eqArrPr).
pub(all) struct CT_EqArrPr {
  /// <baseJc> (CT_YAlign, optional) — base justification (§22.1.2.9).
  base_jc : CT_YAlign?
  /// <maxDist> (CT_OnOff, optional) — maximum-distance flag.
  max_dist : CT_OnOff?
  /// <objDist> (CT_OnOff, optional) — object-distribution flag
  /// (§22.1.2.76).
  obj_dist : CT_OnOff?
  /// <rSpRule> (CT_SpacingRule, optional) — row-spacing rule
  /// (§22.1.2.93).
  r_sp_rule : CT_SpacingRule?
  /// <rSp> (CT_UnSignedInteger, optional) — row-spacing value
  /// (§22.1.2.92).
  r_sp : CT_UnSignedInteger?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_EqArrPr by routing each optional child to its slot.
pub fn CT_EqArrPr::new(
  element : @xml.Element,
) -> CT_EqArrPr raise SchemaViolation {
  let mut base_jc : CT_YAlign? = None
  let mut max_dist : CT_OnOff? = None
  let mut obj_dist : CT_OnOff? = None
  let mut r_sp_rule : CT_SpacingRule? = None
  let mut r_sp : CT_UnSignedInteger? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "baseJc" => base_jc = Some(CT_YAlign::new(e))
          "maxDist" => max_dist = Some(CT_OnOff::new(e))
          "objDist" => obj_dist = Some(CT_OnOff::new(e))
          "rSpRule" => r_sp_rule = Some(CT_SpacingRule::new(e))
          "rSp" => r_sp = Some(CT_UnSignedInteger::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { base_jc, max_dist, obj_dist, r_sp_rule, r_sp, ctrl_pr, element }
}

///|
/// XSD complex type CT_EqArr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_EqArr`. Child elements:
/// `eqArrPr`, `e`. Child types: `CT_EqArrPr`, `CT_OMathArg`.
/// Equation-array object (§22.1.2.34 eqArr).
pub(all) struct CT_EqArr {
  /// <eqArrPr> (CT_EqArrPr, optional) — equation-array properties.
  eq_arr_pr : CT_EqArrPr?
  /// <e>* (CT_OMathArg, one or more by schema; preserved as Array).
  e : Array[CT_OMathArg]
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_EqArr by collecting every `e` child and binding eqArrPr.
pub fn CT_EqArr::new(element : @xml.Element) -> CT_EqArr raise SchemaViolation {
  let mut eq_arr_pr : CT_EqArrPr? = None
  let e : Array[CT_OMathArg] = []
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "eqArrPr" => eq_arr_pr = Some(CT_EqArrPr::new(child_element))
          "e" => e.push(CT_OMathArg::new(child_element))
          _ => ()
        }
      _ => ()
    }
  }
  { eq_arr_pr, e, element }
}

///|
/// XSD complex type CT_FPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_FPr`. Child elements: `type`,
/// `ctrlPr`. Child types: `CT_FType`, `CT_CtrlPr`.
/// Fraction properties (§22.1.2.38 fPr).
pub(all) struct CT_FPr {
  /// <type> (CT_FType, optional) — fraction type (§22.1.2.118).
  f_type : CT_FType?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_FPr by binding the optional type and ctrlPr children. The
/// XSD attribute name `type` is renamed to `f_type` in Moonbit to avoid
/// the reserved keyword.
pub fn CT_FPr::new(element : @xml.Element) -> CT_FPr raise SchemaViolation {
  let mut f_type : CT_FType? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "type" => f_type = Some(CT_FType::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { f_type, ctrl_pr, element }
}

///|
/// XSD complex type CT_F — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_F`. Child elements: `fPr`,
/// `num`, `den`. Child types: `CT_FPr`, `CT_OMathArg`.
/// Fraction object (§22.1.2.36 f) with required numerator (§22.1.2.75) and
/// denominator (§22.1.2.28) arguments.
pub(all) struct CT_F {
  /// <fPr> (CT_FPr, optional) — fraction properties.
  f_pr : CT_FPr?
  /// <num> (CT_OMathArg, required) — numerator argument.
  num : CT_OMathArg
  /// <den> (CT_OMathArg, required) — denominator argument.
  den : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_F; raises SchemaViolation when either `num` or `den` is
/// missing.
pub fn CT_F::new(element : @xml.Element) -> CT_F raise SchemaViolation {
  let mut f_pr : CT_FPr? = None
  let mut num_element : @xml.Element? = None
  let mut den_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "fPr" => f_pr = Some(CT_FPr::new(child_element))
          "num" => if num_element is None { num_element = Some(child_element) }
          "den" => if den_element is None { den_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let num = match num_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_F/num", value="")
  }
  let den = match den_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_F/den", value="")
  }
  { f_pr, num, den, element }
}

///|
/// XSD complex type CT_FuncPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_FuncPr`. Child elements:
/// `ctrlPr`. Child types: `CT_CtrlPr`.
/// Function-apply properties (§22.1.2.40 funcPr).
pub(all) struct CT_FuncPr {
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_FuncPr by binding the optional ctrlPr child.
pub fn CT_FuncPr::new(element : @xml.Element) -> CT_FuncPr {
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        if e.name.local_name == "ctrlPr" {
          ctrl_pr = Some(CT_CtrlPr::new(e))
        }
      _ => ()
    }
  }
  { ctrl_pr, element }
}

///|
/// XSD complex type CT_Func — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Func`. Child elements: `funcPr`,
/// `fName`, `e`. Child types: `CT_FuncPr`, `CT_OMathArg`.
/// Function-apply object (§22.1.2.39 func) with required function name
/// (§22.1.2.37 fName) and required argument.
pub(all) struct CT_Func {
  /// <funcPr> (CT_FuncPr, optional) — function-apply properties.
  func_pr : CT_FuncPr?
  /// <fName> (CT_OMathArg, required) — function name argument.
  f_name : CT_OMathArg
  /// <e> (CT_OMathArg, required) — function-apply argument.
  e : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Func; raises SchemaViolation when either `fName` or `e`
/// is missing.
pub fn CT_Func::new(element : @xml.Element) -> CT_Func raise SchemaViolation {
  let mut func_pr : CT_FuncPr? = None
  let mut f_name_element : @xml.Element? = None
  let mut e_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "funcPr" => func_pr = Some(CT_FuncPr::new(child_element))
          "fName" =>
            if f_name_element is None {
              f_name_element = Some(child_element)
            }
          "e" => if e_element is None { e_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let f_name = match f_name_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Func/fName", value="")
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Func/e", value="")
  }
  { func_pr, f_name, e, element }
}

// ────────────────────────────────────────────────────────────────────────────
// EG_OMathElements still walks the raw XML tree. CT_OMath::children, the
// child_names helpers, and the top-level reader entry points all live in
// the chunk2 territory; they are retained verbatim so this chunk1 commit
// only touches the 36 wrapper structs.
// ────────────────────────────────────────────────────────────────────────────

///|
/// Return child elements selected through EG_OMathElements for this oMath zone.
pub fn CT_OMath::children(self : CT_OMath) -> Array[EG_OMathElements] {
  let children : Array[EG_OMathElements] = []
  for child in self.element.children {
    match child {
      Element(element) => children.push(EG_OMathElements::new(element))
      _ => ()
    }
  }
  children
}

///|
/// Schema shared-math.xsd complex type CT_OMath.
pub fn CT_OMath::schema_type_name(_self : CT_OMath) -> String {
  "CT_OMath"
}

///|
/// Return CT_Box child names for boxPr CT_BoxPr and e CT_OMathArg.
pub fn CT_Box::child_names(self : CT_Box) -> Array[String] {
  omml_child_names(self.element, ["boxPr", "e"])
}

///|
/// Return CT_D child names for dPr CT_DPr and e CT_OMathArg.
pub fn CT_D::child_names(self : CT_D) -> Array[String] {
  omml_child_names(self.element, ["dPr", "e"])
}

///|
/// Return CT_MC child names for mcPr CT_MCPr.
pub fn CT_MC::child_names(self : CT_MC) -> Array[String] {
  omml_child_names(self.element, ["mcPr"])
}

///|
/// Return CT_R child names for rPr CT_RPR and t CT_Text.
pub fn CT_R::child_names(self : CT_R) -> Array[String] {
  omml_child_names(self.element, ["rPr", "t"])
}

///|
/// Construct top-level XSD element oMath as CT_OMath (§22.1).
pub fn o_math(element : @xml.Element) -> CT_OMath {
  CT_OMath::new(element)
}

///|
/// Construct top-level XSD element oMathPara as CT_OMathPara (§22.1).
pub fn o_math_para(element : @xml.Element) -> CT_OMathPara {
  CT_OMathPara::new(element)
}

///|
/// Construct top-level XSD element mathPr as CT_MathPr (§22.1).
pub fn math_pr(element : @xml.Element) -> CT_MathPr {
  CT_MathPr::new(element)
}

///|
/// Return CT_AccPr child names for chr CT_Char and ctrlPr CT_CtrlPr.
pub fn CT_AccPr::child_names(self : CT_AccPr) -> Array[String] {
  omml_child_names(self.element, ["chr", "ctrlPr"])
}

///|
/// Return CT_BarPr child names for pos CT_TopBot and ctrlPr CT_CtrlPr.
pub fn CT_BarPr::child_names(self : CT_BarPr) -> Array[String] {
  omml_child_names(self.element, ["pos", "ctrlPr"])
}

///|
/// Return CT_BoxPr child names for opEmu, noBreak, diff, brk, aln, and ctrlPr.
pub fn CT_BoxPr::child_names(self : CT_BoxPr) -> Array[String] {
  omml_child_names(self.element, [
    "opEmu", "noBreak", "diff", "brk", "aln", "ctrlPr",
  ])
}

///|
/// Return CT_DPr child names for begChr, sepChr, endChr, grow, shp, and ctrlPr.
pub fn CT_DPr::child_names(self : CT_DPr) -> Array[String] {
  omml_child_names(self.element, [
    "begChr", "sepChr", "endChr", "grow", "shp", "ctrlPr",
  ])
}

///|
/// Return CT_F child names for fPr CT_FPr, num CT_OMathArg, and den CT_OMathArg.
pub fn CT_F::child_names(self : CT_F) -> Array[String] {
  omml_child_names(self.element, ["fPr", "num", "den"])
}

///|
/// Return CT_Func child names for funcPr CT_FuncPr, fName CT_OMathArg, and e CT_OMathArg.
pub fn CT_Func::child_names(self : CT_Func) -> Array[String] {
  omml_child_names(self.element, ["funcPr", "fName", "e"])
}

///|
/// Return CT_M child names for mPr CT_MPr and mr CT_MR.
pub fn CT_M::child_names(self : CT_M) -> Array[String] {
  omml_child_names(self.element, ["mPr", "mr"])
}

///|
/// Return CT_MCPr child names for count CT_Integer255 and mcJc CT_XAlign.
pub fn CT_MCPr::child_names(self : CT_MCPr) -> Array[String] {
  omml_child_names(self.element, ["count", "mcJc"])
}

///|
/// Return CT_MPr child names for matrix alignment, spacing, column set, and ctrlPr.
pub fn CT_MPr::child_names(self : CT_MPr) -> Array[String] {
  omml_child_names(self.element, [
    "baseJc", "plcHide", "rSpRule", "cGpRule", "rSp", "cSp", "cGp", "mcs", "ctrlPr",
  ])
}

///|
/// Return CT_MathPr child names for mathFont, break settings, margins, spacing, and limits.
pub fn CT_MathPr::child_names(self : CT_MathPr) -> Array[String] {
  omml_child_names(self.element, [
    "mathFont", "brkBin", "brkBinSub", "smallFrac", "dispDef", "lMargin", "rMargin",
    "defJc", "preSp", "postSp", "interSp", "intraSp", "wrapIndent", "wrapRight",
    "intLim", "naryLim",
  ])
}

///|
/// Return CT_RPR child names for lit, nor, brk, and aln run properties.
pub fn CT_RPR::child_names(self : CT_RPR) -> Array[String] {
  omml_child_names(self.element, ["lit", "nor", "brk", "aln"])
}

///|
/// Return CT_RadPr child names for degHide CT_OnOff and ctrlPr CT_CtrlPr.
pub fn CT_RadPr::child_names(self : CT_RadPr) -> Array[String] {
  omml_child_names(self.element, ["degHide", "ctrlPr"])
}

///|
fn omml_child_names(
  element : @xml.Element,
  allowed : Array[String],
) -> Array[String] {
  let names : Array[String] = []
  for child in element.children {
    match child {
      Element(child_element) =>
        if omml_name_allowed(allowed, child_element.name.local_name) {
          names.push(child_element.name.local_name)
        }
      _ => ()
    }
  }
  names
}

///|
fn omml_name_allowed(allowed : Array[String], name : String) -> Bool {
  for allowed_name in allowed {
    if allowed_name == name {
      return true
    }
  }
  false
}

// ────────────────────────────────────────────────────────────────────────────
// Internal helpers shared by chunk1 CT_X constructors.
// ────────────────────────────────────────────────────────────────────────────

///|
/// Look up an attribute by local name (namespace-agnostic), returning its
/// raw lexical value. Returns the first match in source order.
fn attr_value(element : @xml.Element, local_name : String) -> String? {
  let mut found : String? = None
  for attribute in element.attributes {
    if found is None && attribute.name.local_name == local_name {
      found = Some(attribute.value)
    }
  }
  found
}

///|
/// Look up a required attribute by local name and raise SchemaViolation
/// when it is absent. `owner` identifies the parent CT_X for the diagnostic.
fn require_attr(
  element : @xml.Element,
  local_name : String,
  owner : String,
) -> String raise SchemaViolation {
  match attr_value(element, local_name) {
    Some(value) => value
    None => raise SchemaViolation(type_name=owner + "/@" + local_name, value="")
  }
}

///|
/// Decode an s:ST_OnOff lexical token to a tri-state Bool. Recognised
/// tokens follow the shared-types definition: "true"/"1"/"on" → Some(true);
/// "false"/"0"/"off" → Some(false); anything else → None (callers fall
/// back to the OMML default-true toggle semantics).
fn decode_on_off(value : String) -> Bool? {
  match value {
    "true" | "1" | "on" => Some(true)
    "false" | "0" | "off" => Some(false)
    _ => None
  }
}

///|
/// Concatenate text/CData payloads of an element, ignoring nested
/// element/PI/comment children. Used to read the simple content of
/// CT_Text.
fn element_text(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Text(s) | CData(s) => out.write_string(s)
      _ => ()
    }
  }
  out.to_string()
}

///|
/// Read the xml:space attribute, tolerating both the namespace-bound form
/// (uri = http://www.w3.org/XML/1998/namespace) and the bare "xml" prefix
/// form some producers emit without a namespace binding.
fn xml_space(element : @xml.Element) -> String? {
  let xml_ns = @xml.ns_xml_1998()
  let mut found : String? = None
  for attribute in element.attributes {
    if found is None && attribute.name.local_name == "space" {
      let by_ns = match attribute.name.ns {
        Some(uri) => uri == xml_ns
        None => false
      }
      let by_prefix = match attribute.name.prefix {
        Some(prefix) => prefix == "xml"
        None => false
      }
      if by_ns || by_prefix {
        found = Some(attribute.value)
      }
    }
  }
  found
}

// ────────────────────────────────────────────────────────────────────────────
// Chunk 2 element-only wrappers below remain untouched. They will be typed
// by the chunk2 sub-agent in a separate commit.
// ────────────────────────────────────────────────────────────────────────────

///|
/// XSD complex type CT_GroupChrPr (§22.1.x).
/// OMML group character properties.
pub(all) struct CT_GroupChrPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_GroupChrPr from its OMML XML element.
pub fn CT_GroupChrPr::new(element : @xml.Element) -> CT_GroupChrPr {
  { element, }
}

///|
/// XSD complex type CT_GroupChr (§22.1.x).
/// OMML group character object.
pub(all) struct CT_GroupChr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_GroupChr from its OMML XML element.
pub fn CT_GroupChr::new(element : @xml.Element) -> CT_GroupChr {
  { element, }
}

///|
/// XSD complex type CT_LimLowPr (§22.1.x).
/// OMML lower-limit properties.
pub(all) struct CT_LimLowPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimLowPr from its OMML XML element.
pub fn CT_LimLowPr::new(element : @xml.Element) -> CT_LimLowPr {
  { element, }
}

///|
/// XSD complex type CT_LimLow (§22.1.x).
/// OMML lower-limit object.
pub(all) struct CT_LimLow {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimLow from its OMML XML element.
pub fn CT_LimLow::new(element : @xml.Element) -> CT_LimLow {
  { element, }
}

///|
/// XSD complex type CT_LimUppPr (§22.1.x).
/// OMML upper-limit properties.
pub(all) struct CT_LimUppPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimUppPr from its OMML XML element.
pub fn CT_LimUppPr::new(element : @xml.Element) -> CT_LimUppPr {
  { element, }
}

///|
/// XSD complex type CT_LimUpp (§22.1.x).
/// OMML upper-limit object.
pub(all) struct CT_LimUpp {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimUpp from its OMML XML element.
pub fn CT_LimUpp::new(element : @xml.Element) -> CT_LimUpp {
  { element, }
}

///|
/// XSD complex type CT_MCPr with count CT_Integer255 and mcJc CT_XAlign children (§22.1.x).
/// OMML matrix column properties with count and mcJc children.
pub(all) struct CT_MCPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MCPr from its OMML XML element.
pub fn CT_MCPr::new(element : @xml.Element) -> CT_MCPr {
  { element, }
}

///|
/// Schema shared-math.xsd complex type CT_MC with mcPr CT_MCPr child (§22.1.x).
/// OMML matrix column.
pub(all) struct CT_MC {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MC from its OMML XML element.
pub fn CT_MC::new(element : @xml.Element) -> CT_MC {
  { element, }
}

///|
/// XSD complex type CT_MCS (§22.1.x).
/// OMML matrix column set with mc children.
pub(all) struct CT_MCS {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MCS from its OMML XML element.
pub fn CT_MCS::new(element : @xml.Element) -> CT_MCS {
  { element, }
}

///|
/// Schema shared-math.xsd complex type CT_MPr with baseJc CT_YAlign,
/// plcHide CT_OnOff, rSpRule CT_SpacingRule, cGpRule CT_SpacingRule,
/// rSp CT_UnSignedInteger, cSp CT_UnSignedInteger, cGp CT_UnSignedInteger,
/// mcs CT_MCS, and ctrlPr CT_CtrlPr children (§22.1.x).
/// OMML matrix properties with baseJc, plcHide, spacing, mcs, and ctrlPr children.
pub(all) struct CT_MPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MPr from its OMML XML element.
pub fn CT_MPr::new(element : @xml.Element) -> CT_MPr {
  { element, }
}

///|
/// XSD complex type CT_MR with e CT_OMathArg matrix row children (§22.1.x).
/// OMML matrix row.
pub(all) struct CT_MR {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MR from its OMML XML element.
pub fn CT_MR::new(element : @xml.Element) -> CT_MR {
  { element, }
}

///|
/// Schema shared-math.xsd complex type CT_M with mPr CT_MPr and mr CT_MR
/// children (§22.1.x).
/// OMML matrix object with mPr and mr children.
pub(all) struct CT_M {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_M from its OMML XML element.
pub fn CT_M::new(element : @xml.Element) -> CT_M {
  { element, }
}

///|
/// XSD complex type CT_NaryPr (§22.1.x).
/// OMML n-ary operator properties.
pub(all) struct CT_NaryPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_NaryPr from its OMML XML element.
pub fn CT_NaryPr::new(element : @xml.Element) -> CT_NaryPr {
  { element, }
}

///|
/// XSD complex type CT_Nary (§22.1.x).
/// OMML n-ary operator object with naryPr, sub, sup, and e children.
pub(all) struct CT_Nary {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Nary from its OMML XML element.
pub fn CT_Nary::new(element : @xml.Element) -> CT_Nary {
  { element, }
}

///|
/// XSD complex type CT_PhantPr (§22.1.x).
/// OMML phantom properties.
pub(all) struct CT_PhantPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_PhantPr from its OMML XML element.
pub fn CT_PhantPr::new(element : @xml.Element) -> CT_PhantPr {
  { element, }
}

///|
/// XSD complex type CT_Phant (§22.1.x).
/// OMML phantom object.
pub(all) struct CT_Phant {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Phant from its OMML XML element.
pub fn CT_Phant::new(element : @xml.Element) -> CT_Phant {
  { element, }
}

///|
/// XSD complex type CT_RadPr with degHide CT_OnOff and ctrlPr CT_CtrlPr children (§22.1.x).
/// OMML radical properties with degHide and ctrlPr children.
pub(all) struct CT_RadPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_RadPr from its OMML XML element.
pub fn CT_RadPr::new(element : @xml.Element) -> CT_RadPr {
  { element, }
}

///|
/// XSD complex type CT_Rad (§22.1.x).
/// OMML radical object with radPr, deg, and e children.
pub(all) struct CT_Rad {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Rad from its OMML XML element.
pub fn CT_Rad::new(element : @xml.Element) -> CT_Rad {
  { element, }
}

///|
/// XSD complex type CT_SPrePr (§22.1.x).
/// OMML prescript properties.
pub(all) struct CT_SPrePr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SPrePr from its OMML XML element.
pub fn CT_SPrePr::new(element : @xml.Element) -> CT_SPrePr {
  { element, }
}

///|
/// XSD complex type CT_SPre (§22.1.x).
/// OMML prescript object with sPrePr, sub, sup, and e children.
pub(all) struct CT_SPre {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SPre from its OMML XML element.
pub fn CT_SPre::new(element : @xml.Element) -> CT_SPre {
  { element, }
}

///|
/// XSD complex type CT_SSubPr (§22.1.x).
/// OMML subscript properties.
pub(all) struct CT_SSubPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSubPr from its OMML XML element.
pub fn CT_SSubPr::new(element : @xml.Element) -> CT_SSubPr {
  { element, }
}

///|
/// XSD complex type CT_SSub (§22.1.x).
/// OMML subscript object with sSubPr, e, and sub children.
pub(all) struct CT_SSub {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSub from its OMML XML element.
pub fn CT_SSub::new(element : @xml.Element) -> CT_SSub {
  { element, }
}

///|
/// XSD complex type CT_SSubSupPr (§22.1.x).
/// OMML sub-superscript properties.
pub(all) struct CT_SSubSupPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSubSupPr from its OMML XML element.
pub fn CT_SSubSupPr::new(element : @xml.Element) -> CT_SSubSupPr {
  { element, }
}

///|
/// XSD complex type CT_SSubSup (§22.1.x).
/// OMML sub-superscript object.
pub(all) struct CT_SSubSup {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSubSup from its OMML XML element.
pub fn CT_SSubSup::new(element : @xml.Element) -> CT_SSubSup {
  { element, }
}

///|
/// XSD complex type CT_SSupPr (§22.1.x).
/// OMML superscript properties.
pub(all) struct CT_SSupPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSupPr from its OMML XML element.
pub fn CT_SSupPr::new(element : @xml.Element) -> CT_SSupPr {
  { element, }
}

///|
/// XSD complex type CT_SSup (§22.1.x).
/// OMML superscript object with sSupPr, e, and sup children.
pub(all) struct CT_SSup {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSup from its OMML XML element.
pub fn CT_SSup::new(element : @xml.Element) -> CT_SSup {
  { element, }
}

///|
/// XSD complex type CT_OMathArgPr (§22.1.x).
/// OMML math argument properties.
pub(all) struct CT_OMathArgPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathArgPr from its OMML XML element.
pub fn CT_OMathArgPr::new(element : @xml.Element) -> CT_OMathArgPr {
  { element, }
}

///|
/// XSD complex type CT_OMathArg (§22.1.x).
/// OMML math argument.
pub(all) struct CT_OMathArg {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathArg from its OMML XML element.
pub fn CT_OMathArg::new(element : @xml.Element) -> CT_OMathArg {
  { element, }
}

///|
/// XSD complex type CT_OMathJc (§22.1.x).
/// OMML math justification property.
pub(all) struct CT_OMathJc {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathJc from its OMML XML element.
pub fn CT_OMathJc::new(element : @xml.Element) -> CT_OMathJc {
  { element, }
}

///|
/// XSD complex type CT_OMathParaPr (§22.1.x).
/// OMML math paragraph properties.
pub(all) struct CT_OMathParaPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathParaPr from its OMML XML element.
pub fn CT_OMathParaPr::new(element : @xml.Element) -> CT_OMathParaPr {
  { element, }
}

///|
/// XSD complex type CT_TwipsMeasure (§22.1.x).
/// OMML twips measure property.
pub(all) struct CT_TwipsMeasure {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_TwipsMeasure from its OMML XML element.
pub fn CT_TwipsMeasure::new(element : @xml.Element) -> CT_TwipsMeasure {
  { element, }
}

///|
/// XSD complex type CT_BreakBin (§22.1.x).
/// OMML binary operator break property.
pub(all) struct CT_BreakBin {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BreakBin from its OMML XML element.
pub fn CT_BreakBin::new(element : @xml.Element) -> CT_BreakBin {
  { element, }
}

///|
/// XSD complex type CT_BreakBinSub (§22.1.x).
/// OMML binary subtraction break property.
pub(all) struct CT_BreakBinSub {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BreakBinSub from its OMML XML element.
pub fn CT_BreakBinSub::new(element : @xml.Element) -> CT_BreakBinSub {
  { element, }
}

///|
/// Schema shared-math.xsd complex type CT_MathPr with mathFont CT_String,
/// brkBin CT_BreakBin, brkBinSub CT_BreakBinSub, smallFrac CT_OnOff,
/// dispDef CT_OnOff, margin and spacing CT_TwipsMeasure children, defJc
/// CT_OMathJc, wrapRight CT_OnOff, intLim CT_LimLoc, and naryLim CT_LimLoc
/// children (§22.1.x).
/// OMML document math properties with mathFont, margins, spacing, defaults, intLim, and naryLim children.
pub(all) struct CT_MathPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MathPr from its OMML XML element.
pub fn CT_MathPr::new(element : @xml.Element) -> CT_MathPr {
  { element, }
}

///|
/// XSD complex type CT_OMathPara (§22.1.x).
/// OMML math paragraph containing one or more math zones.
pub(all) struct CT_OMathPara {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathPara from its OMML XML element.
pub fn CT_OMathPara::new(element : @xml.Element) -> CT_OMathPara {
  { element, }
}

///|
/// Schema shared-math.xsd complex type CT_OMath for the top-level oMath
/// element, carrying EG_OMathElements children (§22.1.x).
/// OMML inline or display math zone containing EG_OMathElements children.
pub(all) struct CT_OMath {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMath from its OMML XML element.
pub fn CT_OMath::new(element : @xml.Element) -> CT_OMath {
  { element, }
}
