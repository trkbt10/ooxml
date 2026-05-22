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
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_R by routing children into the typed slots (rPr, t).
/// Unknown child elements raise `SchemaViolation` so callers can't
/// silently round-trip schema-illegal content through this projection.
pub fn CT_R::new(element : @xml.Element) -> CT_R raise SchemaViolation {
  let mut r_pr : CT_RPR? = None
  let t : Array[CT_Text] = []
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "rPr" => r_pr = Some(CT_RPR::new(e))
          "t" => t.push(CT_Text::new(e))
          other =>
            raise SchemaViolation(
              type_name="CT_R/" + other,
              value="unknown child element in shared-math.xsd CT_R content model",
            )
        }
      _ => ()
    }
  }
  { r_pr, t, element }
}

///|
/// XSD complex type CT_CtrlPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_CtrlPr`.
/// Control properties for OMML structural objects (§22.1.2.23 ctrlPr).
/// The EG_RPrMath children belong to the wordprocessing_ml run-property
/// group whose typed projection lives in
/// `@wordprocessing_ml/domain`. Including that package here would
/// invert the dependency (WML domain imports office_math), so the
/// children are preserved as foreign-namespace raw `@xml.Element`s by
/// schema design and consumers cast through the WML projection on
/// demand.
pub(all) struct CT_CtrlPr {
  /// w:EG_RPrMath passthrough children preserved as raw XML (WML
  /// run-property group, projected by the WML domain).
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
  self.omml_elements
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
pub fn o_math_para(
  element : @xml.Element,
) -> CT_OMathPara raise SchemaViolation {
  CT_OMathPara::new(element)
}

///|
/// Construct top-level XSD element mathPr as CT_MathPr (§22.1).
pub fn math_pr(element : @xml.Element) -> CT_MathPr raise SchemaViolation {
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
// Chunk 2 typed CT_X structs.
//
// Each typed field mirrors an XSD attribute or child element from
// shared-math.xsd. The raw `element` field is preserved alongside the
// typed fields so that builder/round-trip writers can continue to emit
// the source XML verbatim, while typed callers consume the parsed
// projection.
//
// `new` parses required attributes via their ST_X simple-type parser
// (raising SchemaViolation on lexical / facet violations) and walks the
// children once, dispatching by local name into the typed slots. Required
// child elements raise SchemaViolation when missing. Optional ones bind
// to `None` / empty arrays.
// ────────────────────────────────────────────────────────────────────────────

///|
/// XSD complex type CT_GroupChrPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_GroupChrPr`. Child elements:
/// `chr`, `pos`, `vertJc`, `ctrlPr`. Child types: `CT_Char`, `CT_TopBot`,
/// `CT_CtrlPr`.
/// Group-character properties (§22.1.2.42 groupChrPr).
pub(all) struct CT_GroupChrPr {
  /// <chr> (CT_Char, optional) — group character (§22.1.2.20).
  chr : CT_Char?
  /// <pos> (CT_TopBot, optional) — group character position (§22.1.2.84).
  pos : CT_TopBot?
  /// <vertJc> (CT_TopBot, optional) — vertical justification of the
  /// argument relative to the group character (§22.1.2.119).
  vert_jc : CT_TopBot?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_GroupChrPr by routing each optional child to its slot.
pub fn CT_GroupChrPr::new(
  element : @xml.Element,
) -> CT_GroupChrPr raise SchemaViolation {
  let mut chr : CT_Char? = None
  let mut pos : CT_TopBot? = None
  let mut vert_jc : CT_TopBot? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "chr" => chr = Some(CT_Char::new(e))
          "pos" => pos = Some(CT_TopBot::new(e))
          "vertJc" => vert_jc = Some(CT_TopBot::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { chr, pos, vert_jc, ctrl_pr, element }
}

///|
/// XSD complex type CT_GroupChr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_GroupChr`. Child elements:
/// `groupChrPr`, `e`. Child types: `CT_GroupChrPr`, `CT_OMathArg`.
/// Group-character object (§22.1.2.41 groupChr) with optional properties
/// and a required CT_OMathArg base.
pub(all) struct CT_GroupChr {
  /// <groupChrPr> (CT_GroupChrPr, optional) — group-character properties.
  group_chr_pr : CT_GroupChrPr?
  /// <e> (CT_OMathArg, required) — base argument under the group character.
  e : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_GroupChr; raises SchemaViolation when the mandatory `e`
/// argument is missing.
pub fn CT_GroupChr::new(
  element : @xml.Element,
) -> CT_GroupChr raise SchemaViolation {
  let mut group_chr_pr : CT_GroupChrPr? = None
  let mut e_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "groupChrPr" => group_chr_pr = Some(CT_GroupChrPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_GroupChr/e", value="")
  }
  { group_chr_pr, e, element }
}

///|
/// XSD complex type CT_LimLowPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_LimLowPr`. Child elements:
/// `ctrlPr`. Child types: `CT_CtrlPr`.
/// Lower-limit properties (§22.1.2.60 limLowPr).
pub(all) struct CT_LimLowPr {
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimLowPr by binding the optional ctrlPr child.
pub fn CT_LimLowPr::new(element : @xml.Element) -> CT_LimLowPr {
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
/// XSD complex type CT_LimLow — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_LimLow`. Child elements:
/// `limLowPr`, `e`, `lim`. Child types: `CT_LimLowPr`, `CT_OMathArg`.
/// Lower-limit object (§22.1.2.59 limLow) with required base and limit
/// arguments.
pub(all) struct CT_LimLow {
  /// <limLowPr> (CT_LimLowPr, optional) — lower-limit properties.
  lim_low_pr : CT_LimLowPr?
  /// <e> (CT_OMathArg, required) — base argument above the limit.
  e : CT_OMathArg
  /// <lim> (CT_OMathArg, required) — limit argument below the base.
  lim : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimLow; raises SchemaViolation when either `e` or `lim`
/// is missing.
pub fn CT_LimLow::new(
  element : @xml.Element,
) -> CT_LimLow raise SchemaViolation {
  let mut lim_low_pr : CT_LimLowPr? = None
  let mut e_element : @xml.Element? = None
  let mut lim_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "limLowPr" => lim_low_pr = Some(CT_LimLowPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          "lim" => if lim_element is None { lim_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_LimLow/e", value="")
  }
  let lim = match lim_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_LimLow/lim", value="")
  }
  { lim_low_pr, e, lim, element }
}

///|
/// XSD complex type CT_LimUppPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_LimUppPr`. Child elements:
/// `ctrlPr`. Child types: `CT_CtrlPr`.
/// Upper-limit properties (§22.1.2.62 limUppPr).
pub(all) struct CT_LimUppPr {
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimUppPr by binding the optional ctrlPr child.
pub fn CT_LimUppPr::new(element : @xml.Element) -> CT_LimUppPr {
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
/// XSD complex type CT_LimUpp — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_LimUpp`. Child elements:
/// `limUppPr`, `e`, `lim`. Child types: `CT_LimUppPr`, `CT_OMathArg`.
/// Upper-limit object (§22.1.2.61 limUpp) with required base and limit
/// arguments.
pub(all) struct CT_LimUpp {
  /// <limUppPr> (CT_LimUppPr, optional) — upper-limit properties.
  lim_upp_pr : CT_LimUppPr?
  /// <e> (CT_OMathArg, required) — base argument below the limit.
  e : CT_OMathArg
  /// <lim> (CT_OMathArg, required) — limit argument above the base.
  lim : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimUpp; raises SchemaViolation when either `e` or `lim`
/// is missing.
pub fn CT_LimUpp::new(
  element : @xml.Element,
) -> CT_LimUpp raise SchemaViolation {
  let mut lim_upp_pr : CT_LimUppPr? = None
  let mut e_element : @xml.Element? = None
  let mut lim_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "limUppPr" => lim_upp_pr = Some(CT_LimUppPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          "lim" => if lim_element is None { lim_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_LimUpp/e", value="")
  }
  let lim = match lim_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_LimUpp/lim", value="")
  }
  { lim_upp_pr, e, lim, element }
}

///|
/// XSD complex type CT_MCPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_MCPr`. Child elements: `count`,
/// `mcJc`. Child types: `CT_Integer255`, `CT_XAlign`.
/// Matrix-column properties (§22.1.2.66 mcPr).
pub(all) struct CT_MCPr {
  /// <count> (CT_Integer255, optional) — matrix-column count in [1, 255]
  /// (§22.1.2.21).
  count : CT_Integer255?
  /// <mcJc> (CT_XAlign, optional) — matrix-column justification
  /// (§22.1.2.65).
  mc_jc : CT_XAlign?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MCPr by binding the optional count and mcJc children.
pub fn CT_MCPr::new(element : @xml.Element) -> CT_MCPr raise SchemaViolation {
  let mut count : CT_Integer255? = None
  let mut mc_jc : CT_XAlign? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "count" => count = Some(CT_Integer255::new(e))
          "mcJc" => mc_jc = Some(CT_XAlign::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { count, mc_jc, element }
}

///|
/// XSD complex type CT_MC — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_MC`. Child elements: `mcPr`.
/// Child types: `CT_MCPr`.
/// Matrix-column descriptor (§22.1.2.64 mc).
pub(all) struct CT_MC {
  /// <mcPr> (CT_MCPr, optional) — matrix-column properties.
  mc_pr : CT_MCPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MC by binding the optional mcPr child.
pub fn CT_MC::new(element : @xml.Element) -> CT_MC raise SchemaViolation {
  let mut mc_pr : CT_MCPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        if e.name.local_name == "mcPr" {
          mc_pr = Some(CT_MCPr::new(e))
        }
      _ => ()
    }
  }
  { mc_pr, element }
}

///|
/// XSD complex type CT_MCS — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_MCS`. Child elements: `mc`.
/// Child types: `CT_MC`.
/// Matrix-column set (§22.1.2.67 mcs) with one or more `mc` descriptors.
pub(all) struct CT_MCS {
  /// <mc>* (CT_MC, one or more by schema; preserved as Array so callers
  /// can surface zero-descriptor input rather than this constructor
  /// raising during best-effort tree construction).
  mc : Array[CT_MC]
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MCS by collecting every `mc` child into the matrix-column
/// descriptor array.
pub fn CT_MCS::new(element : @xml.Element) -> CT_MCS raise SchemaViolation {
  let mc : Array[CT_MC] = []
  for child in element.children {
    match child {
      Element(child_element) =>
        if child_element.name.local_name == "mc" {
          mc.push(CT_MC::new(child_element))
        }
      _ => ()
    }
  }
  { mc, element }
}

///|
/// XSD complex type CT_MPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_MPr`. Child elements: `baseJc`,
/// `plcHide`, `rSpRule`, `cGpRule`, `rSp`, `cSp`, `cGp`, `mcs`, `ctrlPr`.
/// Child types: `CT_YAlign`, `CT_OnOff`, `CT_SpacingRule`,
/// `CT_UnSignedInteger`, `CT_MCS`, `CT_CtrlPr`.
/// Matrix properties (§22.1.2.69 mPr).
pub(all) struct CT_MPr {
  /// <baseJc> (CT_YAlign, optional) — matrix-row base justification
  /// (§22.1.2.9).
  base_jc : CT_YAlign?
  /// <plcHide> (CT_OnOff, optional) — hide placeholder flag (§22.1.2.83).
  plc_hide : CT_OnOff?
  /// <rSpRule> (CT_SpacingRule, optional) — row-spacing rule
  /// (§22.1.2.93).
  r_sp_rule : CT_SpacingRule?
  /// <cGpRule> (CT_SpacingRule, optional) — column-gap spacing rule
  /// (§22.1.2.19).
  c_gp_rule : CT_SpacingRule?
  /// <rSp> (CT_UnSignedInteger, optional) — row-spacing value
  /// (§22.1.2.92).
  r_sp : CT_UnSignedInteger?
  /// <cSp> (CT_UnSignedInteger, optional) — column-spacing value
  /// (§22.1.2.22).
  c_sp : CT_UnSignedInteger?
  /// <cGp> (CT_UnSignedInteger, optional) — column-gap value
  /// (§22.1.2.18).
  c_gp : CT_UnSignedInteger?
  /// <mcs> (CT_MCS, optional) — matrix-column descriptor set
  /// (§22.1.2.67).
  mcs : CT_MCS?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MPr by routing each optional child to its slot.
pub fn CT_MPr::new(element : @xml.Element) -> CT_MPr raise SchemaViolation {
  let mut base_jc : CT_YAlign? = None
  let mut plc_hide : CT_OnOff? = None
  let mut r_sp_rule : CT_SpacingRule? = None
  let mut c_gp_rule : CT_SpacingRule? = None
  let mut r_sp : CT_UnSignedInteger? = None
  let mut c_sp : CT_UnSignedInteger? = None
  let mut c_gp : CT_UnSignedInteger? = None
  let mut mcs : CT_MCS? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "baseJc" => base_jc = Some(CT_YAlign::new(e))
          "plcHide" => plc_hide = Some(CT_OnOff::new(e))
          "rSpRule" => r_sp_rule = Some(CT_SpacingRule::new(e))
          "cGpRule" => c_gp_rule = Some(CT_SpacingRule::new(e))
          "rSp" => r_sp = Some(CT_UnSignedInteger::new(e))
          "cSp" => c_sp = Some(CT_UnSignedInteger::new(e))
          "cGp" => c_gp = Some(CT_UnSignedInteger::new(e))
          "mcs" => mcs = Some(CT_MCS::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  {
    base_jc,
    plc_hide,
    r_sp_rule,
    c_gp_rule,
    r_sp,
    c_sp,
    c_gp,
    mcs,
    ctrl_pr,
    element,
  }
}

///|
/// XSD complex type CT_MR — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_MR`. Child elements: `e`.
/// Child types: `CT_OMathArg`.
/// Matrix row (§22.1.2.68 mr) with one or more matrix-cell arguments.
pub(all) struct CT_MR {
  /// <e>* (CT_OMathArg, one or more by schema; preserved as Array so
  /// callers can surface zero-cell input rather than this constructor
  /// raising during best-effort tree construction).
  e : Array[CT_OMathArg]
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MR by collecting every `e` child into the cell array.
pub fn CT_MR::new(element : @xml.Element) -> CT_MR raise SchemaViolation {
  let e : Array[CT_OMathArg] = []
  for child in element.children {
    match child {
      Element(child_element) =>
        if child_element.name.local_name == "e" {
          e.push(CT_OMathArg::new(child_element))
        }
      _ => ()
    }
  }
  { e, element }
}

///|
/// XSD complex type CT_M — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_M`. Child elements: `mPr`,
/// `mr`. Child types: `CT_MPr`, `CT_MR`.
/// Matrix object (§22.1.2.63 m) with optional properties and one or more
/// matrix rows.
pub(all) struct CT_M {
  /// <mPr> (CT_MPr, optional) — matrix properties.
  m_pr : CT_MPr?
  /// <mr>* (CT_MR, one or more by schema; preserved as Array so callers
  /// can surface zero-row input rather than this constructor raising
  /// during best-effort tree construction).
  mr : Array[CT_MR]
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_M by collecting every `mr` child and binding the optional
/// mPr properties.
pub fn CT_M::new(element : @xml.Element) -> CT_M raise SchemaViolation {
  let mut m_pr : CT_MPr? = None
  let mr : Array[CT_MR] = []
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "mPr" => m_pr = Some(CT_MPr::new(child_element))
          "mr" => mr.push(CT_MR::new(child_element))
          _ => ()
        }
      _ => ()
    }
  }
  { m_pr, mr, element }
}

///|
/// XSD complex type CT_NaryPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_NaryPr`. Child elements: `chr`,
/// `limLoc`, `grow`, `subHide`, `supHide`, `ctrlPr`. Child types:
/// `CT_Char`, `CT_LimLoc`, `CT_OnOff`, `CT_CtrlPr`.
/// N-ary-operator properties (§22.1.2.71 naryPr).
pub(all) struct CT_NaryPr {
  /// <chr> (CT_Char, optional) — n-ary operator character (§22.1.2.20).
  chr : CT_Char?
  /// <limLoc> (CT_LimLoc, optional) — sub/sup limit location
  /// (§22.1.2.57).
  lim_loc : CT_LimLoc?
  /// <grow> (CT_OnOff, optional) — grow operator to enclosed argument
  /// (§22.1.2.43).
  grow : CT_OnOff?
  /// <subHide> (CT_OnOff, optional) — hide subscript flag (§22.1.2.113).
  sub_hide : CT_OnOff?
  /// <supHide> (CT_OnOff, optional) — hide superscript flag
  /// (§22.1.2.115).
  sup_hide : CT_OnOff?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_NaryPr by routing each optional child to its slot.
pub fn CT_NaryPr::new(
  element : @xml.Element,
) -> CT_NaryPr raise SchemaViolation {
  let mut chr : CT_Char? = None
  let mut lim_loc : CT_LimLoc? = None
  let mut grow : CT_OnOff? = None
  let mut sub_hide : CT_OnOff? = None
  let mut sup_hide : CT_OnOff? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "chr" => chr = Some(CT_Char::new(e))
          "limLoc" => lim_loc = Some(CT_LimLoc::new(e))
          "grow" => grow = Some(CT_OnOff::new(e))
          "subHide" => sub_hide = Some(CT_OnOff::new(e))
          "supHide" => sup_hide = Some(CT_OnOff::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { chr, lim_loc, grow, sub_hide, sup_hide, ctrl_pr, element }
}

///|
/// XSD complex type CT_Nary — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Nary`. Child elements:
/// `naryPr`, `sub`, `sup`, `e`. Child types: `CT_NaryPr`, `CT_OMathArg`.
/// N-ary-operator object (§22.1.2.70 nary) with required lower, upper,
/// and base arguments.
pub(all) struct CT_Nary {
  /// <naryPr> (CT_NaryPr, optional) — n-ary-operator properties.
  nary_pr : CT_NaryPr?
  /// <sub> (CT_OMathArg, required) — lower-bound argument
  /// (§22.1.2.112).
  sub : CT_OMathArg
  /// <sup> (CT_OMathArg, required) — upper-bound argument
  /// (§22.1.2.114).
  sup : CT_OMathArg
  /// <e> (CT_OMathArg, required) — operand argument.
  e : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Nary; raises SchemaViolation when any of `sub`, `sup`, or
/// `e` is missing.
pub fn CT_Nary::new(element : @xml.Element) -> CT_Nary raise SchemaViolation {
  let mut nary_pr : CT_NaryPr? = None
  let mut sub_element : @xml.Element? = None
  let mut sup_element : @xml.Element? = None
  let mut e_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "naryPr" => nary_pr = Some(CT_NaryPr::new(child_element))
          "sub" => if sub_element is None { sub_element = Some(child_element) }
          "sup" => if sup_element is None { sup_element = Some(child_element) }
          "e" => if e_element is None { e_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let sub = match sub_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Nary/sub", value="")
  }
  let sup = match sup_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Nary/sup", value="")
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Nary/e", value="")
  }
  { nary_pr, sub, sup, e, element }
}

///|
/// XSD complex type CT_PhantPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_PhantPr`. Child elements:
/// `show`, `zeroWid`, `zeroAsc`, `zeroDesc`, `transp`, `ctrlPr`. Child
/// types: `CT_OnOff`, `CT_CtrlPr`.
/// Phantom properties (§22.1.2.82 phantPr).
pub(all) struct CT_PhantPr {
  /// <show> (CT_OnOff, optional) — render phantom visibly (§22.1.2.98).
  show : CT_OnOff?
  /// <zeroWid> (CT_OnOff, optional) — zero-width phantom (§22.1.2.124).
  zero_wid : CT_OnOff?
  /// <zeroAsc> (CT_OnOff, optional) — zero-ascent phantom (§22.1.2.122).
  zero_asc : CT_OnOff?
  /// <zeroDesc> (CT_OnOff, optional) — zero-descent phantom
  /// (§22.1.2.123).
  zero_desc : CT_OnOff?
  /// <transp> (CT_OnOff, optional) — transparent phantom (§22.1.2.117).
  transp : CT_OnOff?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_PhantPr by routing each optional child to its slot. Every
/// child is CT_OnOff or CT_CtrlPr, whose `new` functions never raise, so
/// this constructor stays infallible.
pub fn CT_PhantPr::new(element : @xml.Element) -> CT_PhantPr {
  let mut show : CT_OnOff? = None
  let mut zero_wid : CT_OnOff? = None
  let mut zero_asc : CT_OnOff? = None
  let mut zero_desc : CT_OnOff? = None
  let mut transp : CT_OnOff? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "show" => show = Some(CT_OnOff::new(e))
          "zeroWid" => zero_wid = Some(CT_OnOff::new(e))
          "zeroAsc" => zero_asc = Some(CT_OnOff::new(e))
          "zeroDesc" => zero_desc = Some(CT_OnOff::new(e))
          "transp" => transp = Some(CT_OnOff::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { show, zero_wid, zero_asc, zero_desc, transp, ctrl_pr, element }
}

///|
/// XSD complex type CT_Phant — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Phant`. Child elements:
/// `phantPr`, `e`. Child types: `CT_PhantPr`, `CT_OMathArg`.
/// Phantom object (§22.1.2.81 phant) with optional properties and a
/// required argument.
pub(all) struct CT_Phant {
  /// <phantPr> (CT_PhantPr, optional) — phantom properties.
  phant_pr : CT_PhantPr?
  /// <e> (CT_OMathArg, required) — argument inside the phantom.
  e : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Phant; raises SchemaViolation when the mandatory `e`
/// argument is missing.
pub fn CT_Phant::new(element : @xml.Element) -> CT_Phant raise SchemaViolation {
  let mut phant_pr : CT_PhantPr? = None
  let mut e_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "phantPr" => phant_pr = Some(CT_PhantPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Phant/e", value="")
  }
  { phant_pr, e, element }
}

///|
/// XSD complex type CT_RadPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_RadPr`. Child elements:
/// `degHide`, `ctrlPr`. Child types: `CT_OnOff`, `CT_CtrlPr`.
/// Radical properties (§22.1.2.90 radPr).
pub(all) struct CT_RadPr {
  /// <degHide> (CT_OnOff, optional) — hide-degree flag (§22.1.2.27).
  deg_hide : CT_OnOff?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_RadPr by binding the optional degHide and ctrlPr
/// children. Every child is CT_OnOff or CT_CtrlPr, whose `new` functions
/// never raise, so this constructor stays infallible.
pub fn CT_RadPr::new(element : @xml.Element) -> CT_RadPr {
  let mut deg_hide : CT_OnOff? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "degHide" => deg_hide = Some(CT_OnOff::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { deg_hide, ctrl_pr, element }
}

///|
/// XSD complex type CT_Rad — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_Rad`. Child elements: `radPr`,
/// `deg`, `e`. Child types: `CT_RadPr`, `CT_OMathArg`.
/// Radical object (§22.1.2.89 rad) with required degree and radicand
/// arguments.
pub(all) struct CT_Rad {
  /// <radPr> (CT_RadPr, optional) — radical properties.
  rad_pr : CT_RadPr?
  /// <deg> (CT_OMathArg, required) — degree argument (§22.1.2.26).
  deg : CT_OMathArg
  /// <e> (CT_OMathArg, required) — radicand argument.
  e : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Rad; raises SchemaViolation when either `deg` or `e` is
/// missing.
pub fn CT_Rad::new(element : @xml.Element) -> CT_Rad raise SchemaViolation {
  let mut rad_pr : CT_RadPr? = None
  let mut deg_element : @xml.Element? = None
  let mut e_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "radPr" => rad_pr = Some(CT_RadPr::new(child_element))
          "deg" => if deg_element is None { deg_element = Some(child_element) }
          "e" => if e_element is None { e_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let deg = match deg_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Rad/deg", value="")
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_Rad/e", value="")
  }
  { rad_pr, deg, e, element }
}

///|
/// XSD complex type CT_SPrePr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_SPrePr`. Child elements:
/// `ctrlPr`. Child types: `CT_CtrlPr`.
/// Prescript-pair properties (§22.1.2.100 sPrePr).
pub(all) struct CT_SPrePr {
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SPrePr by binding the optional ctrlPr child.
pub fn CT_SPrePr::new(element : @xml.Element) -> CT_SPrePr {
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
/// XSD complex type CT_SPre — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_SPre`. Child elements:
/// `sPrePr`, `sub`, `sup`, `e`. Child types: `CT_SPrePr`, `CT_OMathArg`.
/// Prescript-pair object (§22.1.2.99 sPre) with required subscript,
/// superscript, and base arguments.
pub(all) struct CT_SPre {
  /// <sPrePr> (CT_SPrePr, optional) — prescript-pair properties.
  s_pre_pr : CT_SPrePr?
  /// <sub> (CT_OMathArg, required) — prescript subscript argument
  /// (§22.1.2.112).
  sub : CT_OMathArg
  /// <sup> (CT_OMathArg, required) — prescript superscript argument
  /// (§22.1.2.114).
  sup : CT_OMathArg
  /// <e> (CT_OMathArg, required) — base argument carrying the
  /// prescripts.
  e : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SPre; raises SchemaViolation when any of `sub`, `sup`,
/// or `e` is missing.
pub fn CT_SPre::new(element : @xml.Element) -> CT_SPre raise SchemaViolation {
  let mut s_pre_pr : CT_SPrePr? = None
  let mut sub_element : @xml.Element? = None
  let mut sup_element : @xml.Element? = None
  let mut e_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "sPrePr" => s_pre_pr = Some(CT_SPrePr::new(child_element))
          "sub" => if sub_element is None { sub_element = Some(child_element) }
          "sup" => if sup_element is None { sup_element = Some(child_element) }
          "e" => if e_element is None { e_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let sub = match sub_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_SPre/sub", value="")
  }
  let sup = match sup_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_SPre/sup", value="")
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_SPre/e", value="")
  }
  { s_pre_pr, sub, sup, e, element }
}

///|
/// XSD complex type CT_SSubPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_SSubPr`. Child elements:
/// `ctrlPr`. Child types: `CT_CtrlPr`.
/// Subscript-pair properties (§22.1.2.103 sSubPr).
pub(all) struct CT_SSubPr {
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSubPr by binding the optional ctrlPr child.
pub fn CT_SSubPr::new(element : @xml.Element) -> CT_SSubPr {
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
/// XSD complex type CT_SSub — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_SSub`. Child elements:
/// `sSubPr`, `e`, `sub`. Child types: `CT_SSubPr`, `CT_OMathArg`.
/// Subscript-pair object (§22.1.2.102 sSub) with required base and
/// subscript arguments.
pub(all) struct CT_SSub {
  /// <sSubPr> (CT_SSubPr, optional) — subscript-pair properties.
  s_sub_pr : CT_SSubPr?
  /// <e> (CT_OMathArg, required) — base argument.
  e : CT_OMathArg
  /// <sub> (CT_OMathArg, required) — subscript argument (§22.1.2.112).
  sub : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSub; raises SchemaViolation when either `e` or `sub` is
/// missing.
pub fn CT_SSub::new(element : @xml.Element) -> CT_SSub raise SchemaViolation {
  let mut s_sub_pr : CT_SSubPr? = None
  let mut e_element : @xml.Element? = None
  let mut sub_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "sSubPr" => s_sub_pr = Some(CT_SSubPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          "sub" => if sub_element is None { sub_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_SSub/e", value="")
  }
  let sub = match sub_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_SSub/sub", value="")
  }
  { s_sub_pr, e, sub, element }
}

///|
/// XSD complex type CT_SSubSupPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_SSubSupPr`. Child elements:
/// `alnScr`, `ctrlPr`. Child types: `CT_OnOff`, `CT_CtrlPr`.
/// Subscript-superscript-pair properties (§22.1.2.105 sSubSupPr).
pub(all) struct CT_SSubSupPr {
  /// <alnScr> (CT_OnOff, optional) — align-scripts flag (§22.1.2.4).
  aln_scr : CT_OnOff?
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSubSupPr by routing each optional child to its slot.
/// Every child is CT_OnOff or CT_CtrlPr, whose `new` functions never
/// raise, so this constructor stays infallible.
pub fn CT_SSubSupPr::new(element : @xml.Element) -> CT_SSubSupPr {
  let mut aln_scr : CT_OnOff? = None
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "alnScr" => aln_scr = Some(CT_OnOff::new(e))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  { aln_scr, ctrl_pr, element }
}

///|
/// XSD complex type CT_SSubSup — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_SSubSup`. Child elements:
/// `sSubSupPr`, `e`, `sub`, `sup`. Child types: `CT_SSubSupPr`,
/// `CT_OMathArg`.
/// Subscript-superscript-pair object (§22.1.2.104 sSubSup) with required
/// base, subscript, and superscript arguments.
pub(all) struct CT_SSubSup {
  /// <sSubSupPr> (CT_SSubSupPr, optional) — subscript-superscript-pair
  /// properties.
  s_sub_sup_pr : CT_SSubSupPr?
  /// <e> (CT_OMathArg, required) — base argument.
  e : CT_OMathArg
  /// <sub> (CT_OMathArg, required) — subscript argument (§22.1.2.112).
  sub : CT_OMathArg
  /// <sup> (CT_OMathArg, required) — superscript argument
  /// (§22.1.2.114).
  sup : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSubSup; raises SchemaViolation when any of `e`, `sub`,
/// or `sup` is missing.
pub fn CT_SSubSup::new(
  element : @xml.Element,
) -> CT_SSubSup raise SchemaViolation {
  let mut s_sub_sup_pr : CT_SSubSupPr? = None
  let mut e_element : @xml.Element? = None
  let mut sub_element : @xml.Element? = None
  let mut sup_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "sSubSupPr" => s_sub_sup_pr = Some(CT_SSubSupPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          "sub" => if sub_element is None { sub_element = Some(child_element) }
          "sup" => if sup_element is None { sup_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_SSubSup/e", value="")
  }
  let sub = match sub_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_SSubSup/sub", value="")
  }
  let sup = match sup_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_SSubSup/sup", value="")
  }
  { s_sub_sup_pr, e, sub, sup, element }
}

///|
/// XSD complex type CT_SSupPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_SSupPr`. Child elements:
/// `ctrlPr`. Child types: `CT_CtrlPr`.
/// Superscript-pair properties (§22.1.2.106 sSupPr).
pub(all) struct CT_SSupPr {
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSupPr by binding the optional ctrlPr child.
pub fn CT_SSupPr::new(element : @xml.Element) -> CT_SSupPr {
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
/// XSD complex type CT_SSup — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_SSup`. Child elements:
/// `sSupPr`, `e`, `sup`. Child types: `CT_SSupPr`, `CT_OMathArg`.
/// Superscript-pair object (§22.1.2.105 sSup) with required base and
/// superscript arguments.
pub(all) struct CT_SSup {
  /// <sSupPr> (CT_SSupPr, optional) — superscript-pair properties.
  s_sup_pr : CT_SSupPr?
  /// <e> (CT_OMathArg, required) — base argument.
  e : CT_OMathArg
  /// <sup> (CT_OMathArg, required) — superscript argument (§22.1.2.114).
  sup : CT_OMathArg
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSup; raises SchemaViolation when either `e` or `sup` is
/// missing.
pub fn CT_SSup::new(element : @xml.Element) -> CT_SSup raise SchemaViolation {
  let mut s_sup_pr : CT_SSupPr? = None
  let mut e_element : @xml.Element? = None
  let mut sup_element : @xml.Element? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "sSupPr" => s_sup_pr = Some(CT_SSupPr::new(child_element))
          "e" => if e_element is None { e_element = Some(child_element) }
          "sup" => if sup_element is None { sup_element = Some(child_element) }
          _ => ()
        }
      _ => ()
    }
  }
  let e = match e_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_SSup/e", value="")
  }
  let sup = match sup_element {
    Some(child_element) => CT_OMathArg::new(child_element)
    None => raise SchemaViolation(type_name="CT_SSup/sup", value="")
  }
  { s_sup_pr, e, sup, element }
}

///|
/// XSD complex type CT_OMathArgPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_OMathArgPr`. Child elements:
/// `argSz`. Child types: `CT_Integer2`.
/// Math-argument properties (§22.1.2.5 argPr).
pub(all) struct CT_OMathArgPr {
  /// <argSz> (CT_Integer2, optional) — argument size in [-2, +2]
  /// (§22.1.2.6).
  arg_sz : CT_Integer2?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathArgPr by binding the optional argSz child.
pub fn CT_OMathArgPr::new(
  element : @xml.Element,
) -> CT_OMathArgPr raise SchemaViolation {
  let mut arg_sz : CT_Integer2? = None
  for child in element.children {
    match child {
      Element(e) =>
        if e.name.local_name == "argSz" {
          arg_sz = Some(CT_Integer2::new(e))
        }
      _ => ()
    }
  }
  { arg_sz, element }
}

///|
/// XSD complex type CT_OMathArg — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_OMathArg`. Child elements:
/// `argPr`, EG_OMathElements*, `ctrlPr`. Child types: `CT_OMathArgPr`,
/// `EG_OMathElements`, `CT_CtrlPr`.
/// Math argument (§22.1.2.3 argument) carrying optional properties, a
/// repeating EG_OMathElements choice, and optional control properties.
pub(all) struct CT_OMathArg {
  /// <argPr> (CT_OMathArgPr, optional) — math-argument properties.
  arg_pr : CT_OMathArgPr?
  /// EG_OMathElements*, zero or more — the math/paragraph content of the
  /// argument, dispatched element-by-element into the model group.
  omml_elements : Array[EG_OMathElements]
  /// <ctrlPr> (CT_CtrlPr, optional) — control properties.
  ctrl_pr : CT_CtrlPr?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathArg by binding argPr / ctrlPr children and routing
/// every EG_OMathElements choice child through the model group wrapper.
pub fn CT_OMathArg::new(
  element : @xml.Element,
) -> CT_OMathArg raise SchemaViolation {
  let mut arg_pr : CT_OMathArgPr? = None
  let omml_elements : Array[EG_OMathElements] = []
  let mut ctrl_pr : CT_CtrlPr? = None
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "argPr" => arg_pr = Some(CT_OMathArgPr::new(child_element))
          "ctrlPr" => ctrl_pr = Some(CT_CtrlPr::new(child_element))
          _ => omml_elements.push(EG_OMathElements::new(child_element))
        }
      _ => ()
    }
  }
  { arg_pr, omml_elements, ctrl_pr, element }
}

///|
/// XSD complex type CT_OMathJc — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_OMathJc`. Attributes: `val`.
/// Math-paragraph justification (§22.1.2.50 jc) carrying the ST_Jc
/// enumeration of left / right / center / centerGroup.
pub(all) struct CT_OMathJc {
  /// @val (ST_Jc, optional) — None when the attribute is absent.
  val : ST_Jc?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathJc by parsing the optional `val` attribute against
/// ST_Jc.
pub fn CT_OMathJc::new(
  element : @xml.Element,
) -> CT_OMathJc raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(v) => Some(ST_Jc::parse(v))
    None => None
  }
  { val, element }
}

///|
/// XSD complex type CT_OMathParaPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_OMathParaPr`. Child elements:
/// `jc`. Child types: `CT_OMathJc`.
/// Math-paragraph properties (§22.1.2.78 oMathParaPr).
pub(all) struct CT_OMathParaPr {
  /// <jc> (CT_OMathJc, optional) — math-paragraph justification
  /// (§22.1.2.50).
  jc : CT_OMathJc?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathParaPr by binding the optional jc child.
pub fn CT_OMathParaPr::new(
  element : @xml.Element,
) -> CT_OMathParaPr raise SchemaViolation {
  let mut jc : CT_OMathJc? = None
  for child in element.children {
    match child {
      Element(e) =>
        if e.name.local_name == "jc" {
          jc = Some(CT_OMathJc::new(e))
        }
      _ => ()
    }
  }
  { jc, element }
}

///|
/// XSD complex type CT_TwipsMeasure — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_TwipsMeasure`. Attributes:
/// `val`.
/// Twips measure (§22.1.2 — used by lMargin, rMargin, preSp, postSp,
/// interSp, intraSp, wrapIndent). The `val` lexical form is preserved as
/// String because the s:ST_TwipsMeasure union lives in the shared simple
/// types package (kept out of office_math/domain to avoid a cross-package
/// import cycle).
pub(all) struct CT_TwipsMeasure {
  /// @val (s:ST_TwipsMeasure, required) — twips-measure lexical token.
  val : String
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_TwipsMeasure by capturing the required `val` attribute.
pub fn CT_TwipsMeasure::new(
  element : @xml.Element,
) -> CT_TwipsMeasure raise SchemaViolation {
  { val: require_attr(element, "val", "CT_TwipsMeasure"), element }
}

///|
/// XSD complex type CT_BreakBin — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_BreakBin`. Attributes: `val`.
/// Binary-operator break property (§22.1.2.16 brkBin) carrying the
/// ST_BreakBin enumeration of before / after / repeat.
pub(all) struct CT_BreakBin {
  /// @val (ST_BreakBin, optional) — None when the attribute is absent.
  val : ST_BreakBin?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BreakBin by parsing the optional `val` attribute against
/// ST_BreakBin.
pub fn CT_BreakBin::new(
  element : @xml.Element,
) -> CT_BreakBin raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(v) => Some(ST_BreakBin::parse(v))
    None => None
  }
  { val, element }
}

///|
/// XSD complex type CT_BreakBinSub — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_BreakBinSub`. Attributes:
/// `val`.
/// Binary-subtraction break property (§22.1.2.17 brkBinSub) carrying the
/// ST_BreakBinSub enumeration of -- / -+ / +-.
pub(all) struct CT_BreakBinSub {
  /// @val (ST_BreakBinSub, optional) — None when the attribute is
  /// absent.
  val : ST_BreakBinSub?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BreakBinSub by parsing the optional `val` attribute
/// against ST_BreakBinSub.
pub fn CT_BreakBinSub::new(
  element : @xml.Element,
) -> CT_BreakBinSub raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(v) => Some(ST_BreakBinSub::parse(v))
    None => None
  }
  { val, element }
}

///|
/// XSD complex type CT_MathPr — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_MathPr`. Child elements:
/// `mathFont`, `brkBin`, `brkBinSub`, `smallFrac`, `dispDef`, `lMargin`,
/// `rMargin`, `defJc`, `preSp`, `postSp`, `interSp`, `intraSp`,
/// `wrapIndent` | `wrapRight`, `intLim`, `naryLim`. Child types:
/// `CT_String`, `CT_BreakBin`, `CT_BreakBinSub`, `CT_OnOff`,
/// `CT_TwipsMeasure`, `CT_OMathJc`, `CT_LimLoc`.
/// Document math properties (§22.1.2.66 mathPr). The wrapIndent /
/// wrapRight pair lives in an XSD choice so both branches appear as
/// separate optional fields, with at most one of them populated per
/// document.
pub(all) struct CT_MathPr {
  /// <mathFont> (CT_String, optional) — math font (§22.1.2.62
  /// mathFont).
  math_font : CT_String?
  /// <brkBin> (CT_BreakBin, optional) — binary-operator break
  /// (§22.1.2.16).
  brk_bin : CT_BreakBin?
  /// <brkBinSub> (CT_BreakBinSub, optional) — binary-subtraction break
  /// (§22.1.2.17).
  brk_bin_sub : CT_BreakBinSub?
  /// <smallFrac> (CT_OnOff, optional) — use small fraction in inline
  /// math (§22.1.2.103).
  small_frac : CT_OnOff?
  /// <dispDef> (CT_OnOff, optional) — use display defaults
  /// (§22.1.2.30).
  disp_def : CT_OnOff?
  /// <lMargin> (CT_TwipsMeasure, optional) — left margin (§22.1.2.58).
  l_margin : CT_TwipsMeasure?
  /// <rMargin> (CT_TwipsMeasure, optional) — right margin
  /// (§22.1.2.91).
  r_margin : CT_TwipsMeasure?
  /// <defJc> (CT_OMathJc, optional) — default justification
  /// (§22.1.2.25).
  def_jc : CT_OMathJc?
  /// <preSp> (CT_TwipsMeasure, optional) — pre-equation spacing
  /// (§22.1.2.86).
  pre_sp : CT_TwipsMeasure?
  /// <postSp> (CT_TwipsMeasure, optional) — post-equation spacing
  /// (§22.1.2.85).
  post_sp : CT_TwipsMeasure?
  /// <interSp> (CT_TwipsMeasure, optional) — inter-equation spacing
  /// (§22.1.2.48).
  inter_sp : CT_TwipsMeasure?
  /// <intraSp> (CT_TwipsMeasure, optional) — intra-equation spacing
  /// (§22.1.2.49).
  intra_sp : CT_TwipsMeasure?
  /// <wrapIndent> (CT_TwipsMeasure, optional) — wrap-indent measure
  /// (§22.1.2.120). Choice branch with <wrapRight>.
  wrap_indent : CT_TwipsMeasure?
  /// <wrapRight> (CT_OnOff, optional) — wrap-right flag (§22.1.2.121).
  /// Choice branch with <wrapIndent>.
  wrap_right : CT_OnOff?
  /// <intLim> (CT_LimLoc, optional) — integral limit location
  /// (§22.1.2.51).
  int_lim : CT_LimLoc?
  /// <naryLim> (CT_LimLoc, optional) — n-ary limit location
  /// (§22.1.2.72).
  nary_lim : CT_LimLoc?
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MathPr by routing each optional child to its slot.
pub fn CT_MathPr::new(
  element : @xml.Element,
) -> CT_MathPr raise SchemaViolation {
  let mut math_font : CT_String? = None
  let mut brk_bin : CT_BreakBin? = None
  let mut brk_bin_sub : CT_BreakBinSub? = None
  let mut small_frac : CT_OnOff? = None
  let mut disp_def : CT_OnOff? = None
  let mut l_margin : CT_TwipsMeasure? = None
  let mut r_margin : CT_TwipsMeasure? = None
  let mut def_jc : CT_OMathJc? = None
  let mut pre_sp : CT_TwipsMeasure? = None
  let mut post_sp : CT_TwipsMeasure? = None
  let mut inter_sp : CT_TwipsMeasure? = None
  let mut intra_sp : CT_TwipsMeasure? = None
  let mut wrap_indent : CT_TwipsMeasure? = None
  let mut wrap_right : CT_OnOff? = None
  let mut int_lim : CT_LimLoc? = None
  let mut nary_lim : CT_LimLoc? = None
  for child in element.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "mathFont" => math_font = Some(CT_String::new(e))
          "brkBin" => brk_bin = Some(CT_BreakBin::new(e))
          "brkBinSub" => brk_bin_sub = Some(CT_BreakBinSub::new(e))
          "smallFrac" => small_frac = Some(CT_OnOff::new(e))
          "dispDef" => disp_def = Some(CT_OnOff::new(e))
          "lMargin" => l_margin = Some(CT_TwipsMeasure::new(e))
          "rMargin" => r_margin = Some(CT_TwipsMeasure::new(e))
          "defJc" => def_jc = Some(CT_OMathJc::new(e))
          "preSp" => pre_sp = Some(CT_TwipsMeasure::new(e))
          "postSp" => post_sp = Some(CT_TwipsMeasure::new(e))
          "interSp" => inter_sp = Some(CT_TwipsMeasure::new(e))
          "intraSp" => intra_sp = Some(CT_TwipsMeasure::new(e))
          "wrapIndent" => wrap_indent = Some(CT_TwipsMeasure::new(e))
          "wrapRight" => wrap_right = Some(CT_OnOff::new(e))
          "intLim" => int_lim = Some(CT_LimLoc::new(e))
          "naryLim" => nary_lim = Some(CT_LimLoc::new(e))
          _ => ()
        }
      _ => ()
    }
  }
  {
    math_font,
    brk_bin,
    brk_bin_sub,
    small_frac,
    disp_def,
    l_margin,
    r_margin,
    def_jc,
    pre_sp,
    post_sp,
    inter_sp,
    intra_sp,
    wrap_indent,
    wrap_right,
    int_lim,
    nary_lim,
    element,
  }
}

///|
/// XSD complex type CT_OMathPara — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_OMathPara`. Child elements:
/// `oMathParaPr`, `oMath`. Child types: `CT_OMathParaPr`, `CT_OMath`.
/// Math-paragraph object (§22.1.2.77 oMathPara) carrying optional
/// paragraph properties and one or more child math zones.
pub(all) struct CT_OMathPara {
  /// <oMathParaPr> (CT_OMathParaPr, optional) — math-paragraph
  /// properties.
  o_math_para_pr : CT_OMathParaPr?
  /// <oMath>* (CT_OMath, one or more by schema; preserved as Array so
  /// callers can surface zero-math-zone input rather than this
  /// constructor raising during best-effort tree construction).
  o_math : Array[CT_OMath]
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathPara by collecting every `oMath` child and binding
/// the optional `oMathParaPr` properties.
pub fn CT_OMathPara::new(
  element : @xml.Element,
) -> CT_OMathPara raise SchemaViolation {
  let mut o_math_para_pr : CT_OMathParaPr? = None
  let o_math : Array[CT_OMath] = []
  for child in element.children {
    match child {
      Element(child_element) =>
        match child_element.name.local_name {
          "oMathParaPr" =>
            o_math_para_pr = Some(CT_OMathParaPr::new(child_element))
          "oMath" => o_math.push(CT_OMath::new(child_element))
          _ => ()
        }
      _ => ()
    }
  }
  { o_math_para_pr, o_math, element }
}

///|
/// XSD complex type CT_OMath — Part 1 §22.1.
/// Schema shared-math.xsd complex type `CT_OMath`. Child elements:
/// EG_OMathElements*. Child types: `EG_OMathElements`.
/// Top-level math zone (§22.1.2.77 oMath) carrying a repeating
/// EG_OMathElements choice. The model-group classification is deferred
/// to EG_OMathElements::math_element, so this constructor stays
/// infallible.
pub(all) struct CT_OMath {
  /// EG_OMathElements*, zero or more — the math/paragraph content of the
  /// zone, dispatched element-by-element into the model group.
  omml_elements : Array[EG_OMathElements]
  /// Source XML element preserved for round-trip writers.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMath by walking every element child through the
/// EG_OMathElements wrapper.
pub fn CT_OMath::new(element : @xml.Element) -> CT_OMath {
  let omml_elements : Array[EG_OMathElements] = []
  for child in element.children {
    match child {
      Element(child_element) =>
        omml_elements.push(EG_OMathElements::new(child_element))
      _ => ()
    }
  }
  { omml_elements, element }
}
