// =============================================================================
// chunk1 typed CT_* wrappers (37 types) — dml-chart.xsd lines 17..310
//
// These supersede the legacy element-only `{ element : @xml.Element }`
// holders. Every attribute and child element documented in the XSD has a
// typed field below, in declaration order. minOccurs/maxOccurs map to
// Option / Array / non-Option as per the spec.
// =============================================================================

///|
/// Namespace URI of dml-chart.xsd (`xmlns="http://purl.oclc.org/ooxml/drawingml/chart"`).
pub fn chart_namespace() -> String {
  "http://purl.oclc.org/ooxml/drawingml/chart"
}

///|
/// Namespace URI of the OPC relationships schema (`r:` prefix used by CT_RelId).
pub fn relationships_namespace() -> String {
  "http://purl.oclc.org/ooxml/officeDocument/relationships"
}

///|
/// Namespace URI of the dml-main.xsd `a:` prefix (held in this package as
/// raw `@xml.Element` because the drawingml/main package types are not
/// importable here without crossing chunk1's scope).
pub fn drawingml_main_namespace() -> String {
  "http://purl.oclc.org/ooxml/drawingml/main"
}

// -----------------------------------------------------------------------------
// Helpers — local-name child / attribute lookup. We do not switch on
// namespace for in-namespace children since dml-chart.xsd uses
// `elementFormDefault="qualified"` but qualifies them all to the chart
// namespace; readers in this package have always relied on `local_name`
// matching, matching the existing simple_types decoders.
// -----------------------------------------------------------------------------

///|
fn first_child_named(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return Some(child_element)
        }
      _ => ()
    }
  }
  None
}

///|
fn children_named(
  element : @xml.Element,
  local_name : String,
) -> Array[@xml.Element] {
  let acc : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          acc.push(child_element)
        }
      _ => ()
    }
  }
  acc
}

///|
fn attr_value(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return Some(attribute.value)
    }
  }
  None
}

///|
fn attr_value_ns(
  element : @xml.Element,
  ns : String,
  local_name : String,
) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name &&
      (match attribute.name.ns {
        Some(value) => value == ns
        None => false
      }) {
      return Some(attribute.value)
    }
  }
  None
}

///|
/// Decode the XSD lexical boolean form (`true`/`false`/`1`/`0`).
fn parse_xsd_boolean(
  path : String,
  value : String,
) -> Bool raise SchemaViolation {
  match value {
    "true" => true
    "1" => true
    "false" => false
    "0" => false
    _ =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path~,
        reason="invalid xsd:boolean: " + value,
      )
  }
}

///|
/// Decode an xsd:double attribute body.
fn parse_xsd_double(
  path : String,
  value : String,
) -> Double raise SchemaViolation {
  let bytes_ok = looks_like_number(value, allow_decimal=true) &&
    value.length() > 0
  if !bytes_ok {
    raise SchemaViolation(
      schema="dml-chart.xsd",
      path~,
      reason="invalid xsd:double: " + value,
    )
  }
  let mut i = 0
  let mut negative = false
  if value[0:1] == "-" {
    negative = true
    i = 1
  } else if value[0:1] == "+" {
    i = 1
  }
  let mut whole : Int64 = 0L
  while i < value.length() && value[i:i + 1] != "." {
    let ch = value[i:i + 1]
    let d = (ch[0].to_int() - "0"[0].to_int()).to_int64()
    whole = whole * 10L + d
    i = i + 1
  }
  let mut frac : Double = 0.0
  let mut scale : Double = 1.0
  if i < value.length() && value[i:i + 1] == "." {
    i = i + 1
    while i < value.length() {
      let ch = value[i:i + 1]
      let d = (ch[0].to_int() - "0"[0].to_int()).to_double()
      scale = scale * 10.0
      frac = frac + d / scale
      i = i + 1
    }
  }
  let magnitude = whole.to_double() + frac
  if negative {
    -magnitude
  } else {
    magnitude
  }
}

///|
/// Decode an xsd:unsignedInt attribute body (0..4_294_967_295) widened
/// to Int64 to cover the full domain.
fn parse_xsd_unsigned_int(
  path : String,
  value : String,
) -> Int64 raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-chart.xsd",
      path~,
      reason="invalid xsd:unsignedInt: empty",
    )
  }
  let mut i = 0
  let mut n : Int64 = 0L
  while i < value.length() {
    let ch = value[i:i + 1]
    if ch < "0" || ch > "9" {
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path~,
        reason="invalid xsd:unsignedInt: " + value,
      )
    }
    let d = (ch[0].to_int() - "0"[0].to_int()).to_int64()
    n = n * 10L + d
    i = i + 1
  }
  if n > 4294967295L {
    raise SchemaViolation(
      schema="dml-chart.xsd",
      path~,
      reason="xsd:unsignedInt out of range: " + value,
    )
  }
  n
}

///|
/// Decode the textual content of a child element (concatenated `Text`
/// and `CData` nodes). Empty strings come back as `""`.
fn element_text(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for child in element.children {
    match child {
      @xml.Node::Text(text) => buf.write_string(text)
      @xml.Node::CData(text) => buf.write_string(text)
      _ => ()
    }
  }
  buf.to_string()
}

// =============================================================================
// XSD complex type CT_Boolean — Part 1 §21.2 / §A.5.1
//   <xsd:attribute name="val" type="xsd:boolean" use="optional" default="true"/>
// =============================================================================

///|
/// XSD complex type CT_Boolean — Part 1 §21.2 (dml-chart.xsd) / §A.5.1.
/// Holds the optional `val` boolean (default `true`).
pub(all) struct CT_Boolean {
  /// @val (xsd:boolean) — optional, schema default `true`.
  val : Bool?
} derive(Eq, Debug)

///|
/// Parse CT_Boolean from a `<…/>` element whose only attribute is `val`.
pub fn CT_Boolean::new(
  element : @xml.Element,
) -> CT_Boolean raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(parse_xsd_boolean("CT_Boolean/@val", text))
    None => None
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_Double — Part 1 §21.2 / §A.5.1
//   <xsd:attribute name="val" type="xsd:double" use="required"/>
// =============================================================================

///|
/// XSD complex type CT_Double — Part 1 §21.2 (dml-chart.xsd) / §A.5.1.
/// `val` is required.
pub(all) struct CT_Double {
  /// @val (xsd:double) — required.
  val : Double
} derive(Eq, Debug)

///|
pub fn CT_Double::new(
  element : @xml.Element,
) -> CT_Double raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_Double/@val",
        reason="required attribute missing",
      )
  }
  let val = parse_xsd_double("CT_Double/@val", raw)
  { val, }
}

// =============================================================================
// XSD complex type CT_UnsignedInt — Part 1 §21.2 / §A.5.1
//   <xsd:attribute name="val" type="xsd:unsignedInt" use="required"/>
// =============================================================================

///|
/// XSD complex type CT_UnsignedInt — Part 1 §21.2 (dml-chart.xsd) / §A.5.1.
/// `val` is required. The value is widened to Int64 to cover xsd:unsignedInt.
pub(all) struct CT_UnsignedInt {
  /// @val (xsd:unsignedInt) — required.
  val : Int64
} derive(Eq, Debug)

///|
pub fn CT_UnsignedInt::new(
  element : @xml.Element,
) -> CT_UnsignedInt raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_UnsignedInt/@val",
        reason="required attribute missing",
      )
  }
  let val = parse_xsd_unsigned_int("CT_UnsignedInt/@val", raw)
  { val, }
}

// =============================================================================
// XSD complex type CT_RelId — Part 1 §21.2 / §A.5.1
//   <xsd:attribute ref="r:id" use="required"/>
// =============================================================================

///|
/// XSD complex type CT_RelId — Part 1 §21.2 (dml-chart.xsd) / §A.5.1.
/// Schema dml-chart.xsd complex type `CT_RelId`. Attribute groups
/// referenced: `r:id`. The OPC relationship identifier is required.
pub(all) struct CT_RelId {
  /// @r:id (`xmlns:r="http://purl.oclc.org/ooxml/officeDocument/relationships"`) — required.
  r_id : String
} derive(Eq, Debug)

///|
pub fn CT_RelId::new(element : @xml.Element) -> CT_RelId raise SchemaViolation {
  let ns = relationships_namespace()
  let raw = match attr_value_ns(element, ns, "id") {
    Some(v) => v
    // Fallback to local-name lookup for round-trip tolerance when the
    // attribute namespace is not bound on the parsed element.
    None =>
      match attr_value(element, "id") {
        Some(v) => v
        None =>
          raise SchemaViolation(
            schema="dml-chart.xsd",
            path="CT_RelId/@r:id",
            reason="required attribute missing",
          )
      }
  }
  { r_id: raw }
}

// =============================================================================
// XSD complex type CT_Extension — Part 1 §21.2.2.62 ext
//   <xsd:sequence><xsd:any processContents="lax"/></xsd:sequence>
//   <xsd:attribute name="uri" type="xsd:token"/>
// =============================================================================

///|
/// XSD complex type CT_Extension — Part 1 §21.2.2.62 (dml-chart.xsd) ext.
/// Wildcard payload is preserved as raw children so any conformant
/// extension content survives round-trip.
pub(all) struct CT_Extension {
  /// @uri (xsd:token) — optional.
  uri : String?
  /// xsd:any processContents="lax" payload (zero or more child elements
  /// in any namespace).
  any_children : Array[@xml.Element]
} derive(Eq, Debug)

///|
pub fn CT_Extension::new(element : @xml.Element) -> CT_Extension {
  let uri = attr_value(element, "uri")
  let any_children : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) => any_children.push(child_element)
      _ => ()
    }
  }
  { uri, any_children }
}

// =============================================================================
// XSD complex type CT_ExtensionList — Part 1 §21.2.2.64 extLst
//   <xsd:element name="ext" type="CT_Extension" minOccurs="0" maxOccurs="unbounded"/>
// =============================================================================

///|
/// XSD complex type CT_ExtensionList — Part 1 §21.2.2.64 (dml-chart.xsd) extLst.
pub(all) struct CT_ExtensionList {
  /// <ext> (CT_Extension) — zero or more.
  ext : Array[CT_Extension]
} derive(Eq, Debug)

///|
pub fn CT_ExtensionList::new(element : @xml.Element) -> CT_ExtensionList {
  let ext = children_named(element, "ext").map(CT_Extension::new)
  { ext, }
}

// =============================================================================
// XSD complex type CT_NumVal — Part 1 §21.2.2.150 pt (Numeric Point)
//   <xsd:sequence>
//     <xsd:element name="v" type="s:ST_Xstring" minOccurs="1" maxOccurs="1"/>
//   </xsd:sequence>
//   <xsd:attribute name="idx" type="xsd:unsignedInt" use="required"/>
//   <xsd:attribute name="formatCode" type="s:ST_Xstring" use="optional"/>
// =============================================================================

///|
/// XSD complex type CT_NumVal — Part 1 §21.2.2.150 (dml-chart.xsd) pt
/// (Numeric Point). The required `v` child carries the numeric literal as
/// xsd:string body.
pub(all) struct CT_NumVal {
  /// @idx (xsd:unsignedInt) — required.
  idx : Int64
  /// @formatCode (s:ST_Xstring) — optional.
  format_code : String?
  /// <v> (s:ST_Xstring) — required.
  v : String
} derive(Eq, Debug)

///|
pub fn CT_NumVal::new(
  element : @xml.Element,
) -> CT_NumVal raise SchemaViolation {
  let idx_raw = match attr_value(element, "idx") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_NumVal/@idx",
        reason="required attribute missing",
      )
  }
  let idx = parse_xsd_unsigned_int("CT_NumVal/@idx", idx_raw)
  let format_code = attr_value(element, "formatCode")
  let v_element = match first_child_named(element, "v") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_NumVal/v",
        reason="required child missing",
      )
  }
  let v = element_text(v_element)
  { idx, format_code, v }
}

// =============================================================================
// XSD complex type CT_NumData — Part 1 §21.2 numeric cache payload
//   <xsd:element name="formatCode" type="s:ST_Xstring" minOccurs="0" maxOccurs="1"/>
//   <xsd:element name="ptCount" type="CT_UnsignedInt" minOccurs="0" maxOccurs="1"/>
//   <xsd:element name="pt" type="CT_NumVal" minOccurs="0" maxOccurs="unbounded"/>
//   <xsd:element name="extLst" type="CT_ExtensionList" minOccurs="0" maxOccurs="1"/>
// =============================================================================

///|
/// XSD complex type CT_NumData — Part 1 §21.2.2.120 numCache /
/// §21.2.2.122 numLit (dml-chart.xsd) numeric cache payload.
pub(all) struct CT_NumData {
  /// <formatCode> (s:ST_Xstring) — optional.
  format_code : String?
  /// <ptCount> (CT_UnsignedInt) — optional.
  pt_count : CT_UnsignedInt?
  /// <pt> (CT_NumVal) — zero or more.
  pt : Array[CT_NumVal]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_NumData::new(
  element : @xml.Element,
) -> CT_NumData raise SchemaViolation {
  let format_code = first_child_named(element, "formatCode").map(element_text)
  let pt_count = match first_child_named(element, "ptCount") {
    Some(child) => Some(CT_UnsignedInt::new(child))
    None => None
  }
  let pt = []
  for child in children_named(element, "pt") {
    pt.push(CT_NumVal::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { format_code, pt_count, pt, ext_lst }
}

// =============================================================================
// XSD complex type CT_NumRef — Part 1 §21.2.2.123 numRef
//   <xsd:element name="f" type="xsd:string" minOccurs="1" maxOccurs="1"/>
//   <xsd:element name="numCache" type="CT_NumData" minOccurs="0" maxOccurs="1"/>
//   <xsd:element name="extLst" type="CT_ExtensionList" minOccurs="0" maxOccurs="1"/>
// =============================================================================

///|
/// XSD complex type CT_NumRef — Part 1 §21.2.2.123 (dml-chart.xsd) numRef.
pub(all) struct CT_NumRef {
  /// <f> (xsd:string) — required formula reference.
  f : String
  /// <numCache> (CT_NumData) — optional cached values.
  num_cache : CT_NumData?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_NumRef::new(
  element : @xml.Element,
) -> CT_NumRef raise SchemaViolation {
  let f = match first_child_named(element, "f") {
    Some(child) => element_text(child)
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_NumRef/f",
        reason="required child missing",
      )
  }
  let num_cache = match first_child_named(element, "numCache") {
    Some(child) => Some(CT_NumData::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { f, num_cache, ext_lst }
}

// =============================================================================
// XSD complex type CT_NumDataSource — Part 1 §21.2 (val/yVal/bubbleSize)
//   <xsd:choice minOccurs="1" maxOccurs="1">
//     <xsd:element name="numRef" type="CT_NumRef" minOccurs="1" maxOccurs="1"/>
//     <xsd:element name="numLit" type="CT_NumData" minOccurs="1" maxOccurs="1"/>
//   </xsd:choice>
// =============================================================================

///|
/// XSD complex type CT_NumDataSource — Part 1 §21.2 (dml-chart.xsd):
/// holder for the `val` / `yVal` / `bubbleSize` series payload, a
/// required choice between <numRef> and <numLit>.
pub(all) enum CT_NumDataSource {
  /// <numRef> (CT_NumRef) — value cell range.
  NumDataSourceRef(CT_NumRef)
  /// <numLit> (CT_NumData) — literal numeric cache.
  NumDataSourceLit(CT_NumData)
} derive(Eq, Debug)

///|
pub fn CT_NumDataSource::new(
  element : @xml.Element,
) -> CT_NumDataSource raise SchemaViolation {
  match first_child_named(element, "numRef") {
    Some(child) => NumDataSourceRef(CT_NumRef::new(child))
    None =>
      match first_child_named(element, "numLit") {
        Some(child) => NumDataSourceLit(CT_NumData::new(child))
        None =>
          raise SchemaViolation(
            schema="dml-chart.xsd",
            path="CT_NumDataSource",
            reason="required choice (numRef|numLit) missing",
          )
      }
  }
}

// =============================================================================
// XSD complex type CT_StrVal — Part 1 §21.2.2.151 pt (String Point)
//   <xsd:element name="v" type="s:ST_Xstring" minOccurs="1" maxOccurs="1"/>
//   <xsd:attribute name="idx" type="xsd:unsignedInt" use="required"/>
// =============================================================================

///|
/// XSD complex type CT_StrVal — Part 1 §21.2.2.151 (dml-chart.xsd) pt
/// (String Point).
pub(all) struct CT_StrVal {
  /// @idx (xsd:unsignedInt) — required.
  idx : Int64
  /// <v> (s:ST_Xstring) — required.
  v : String
} derive(Eq, Debug)

///|
pub fn CT_StrVal::new(
  element : @xml.Element,
) -> CT_StrVal raise SchemaViolation {
  let idx_raw = match attr_value(element, "idx") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_StrVal/@idx",
        reason="required attribute missing",
      )
  }
  let idx = parse_xsd_unsigned_int("CT_StrVal/@idx", idx_raw)
  let v_element = match first_child_named(element, "v") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_StrVal/v",
        reason="required child missing",
      )
  }
  let v = element_text(v_element)
  { idx, v }
}

// =============================================================================
// XSD complex type CT_StrData — Part 1 §21.2 string cache payload
//   <xsd:element name="ptCount" type="CT_UnsignedInt" minOccurs="0" maxOccurs="1"/>
//   <xsd:element name="pt" type="CT_StrVal" minOccurs="0" maxOccurs="unbounded"/>
//   <xsd:element name="extLst" type="CT_ExtensionList" minOccurs="0" maxOccurs="1"/>
// =============================================================================

///|
/// XSD complex type CT_StrData — Part 1 §21.2.2.199 strCache /
/// §21.2.2.200 strLit (dml-chart.xsd) string cache payload.
pub(all) struct CT_StrData {
  /// <ptCount> (CT_UnsignedInt) — optional.
  pt_count : CT_UnsignedInt?
  /// <pt> (CT_StrVal) — zero or more.
  pt : Array[CT_StrVal]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_StrData::new(
  element : @xml.Element,
) -> CT_StrData raise SchemaViolation {
  let pt_count = match first_child_named(element, "ptCount") {
    Some(child) => Some(CT_UnsignedInt::new(child))
    None => None
  }
  let pt = []
  for child in children_named(element, "pt") {
    pt.push(CT_StrVal::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { pt_count, pt, ext_lst }
}

// =============================================================================
// XSD complex type CT_StrRef — Part 1 §21.2.2.201 strRef
//   <xsd:element name="f" type="xsd:string" minOccurs="1" maxOccurs="1"/>
//   <xsd:element name="strCache" type="CT_StrData" minOccurs="0" maxOccurs="1"/>
//   <xsd:element name="extLst" type="CT_ExtensionList" minOccurs="0" maxOccurs="1"/>
// =============================================================================

///|
/// XSD complex type CT_StrRef — Part 1 §21.2.2.201 (dml-chart.xsd) strRef.
pub(all) struct CT_StrRef {
  /// <f> (xsd:string) — required.
  f : String
  /// <strCache> (CT_StrData) — optional.
  str_cache : CT_StrData?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_StrRef::new(
  element : @xml.Element,
) -> CT_StrRef raise SchemaViolation {
  let f = match first_child_named(element, "f") {
    Some(child) => element_text(child)
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_StrRef/f",
        reason="required child missing",
      )
  }
  let str_cache = match first_child_named(element, "strCache") {
    Some(child) => Some(CT_StrData::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { f, str_cache, ext_lst }
}

// =============================================================================
// XSD complex type CT_Tx — Part 1 §21.2.2.214 tx (Chart Text)
//   <xsd:choice minOccurs="1" maxOccurs="1">
//     <xsd:element name="strRef" type="CT_StrRef" minOccurs="1" maxOccurs="1"/>
//     <xsd:element name="rich" type="a:CT_TextBody" minOccurs="1" maxOccurs="1"/>
//   </xsd:choice>
// =============================================================================

///|
/// XSD complex type CT_Tx — Part 1 §21.2.2.214 tx (Chart Text).
/// Schema dml-chart.xsd complex type `CT_Tx`. Child elements: `strRef`,
/// `rich`. Child types: `CT_StrRef`, `a:CT_TextBody`.
pub(all) struct CT_Tx {
  /// <strRef> (CT_StrRef) — string reference choice branch.
  str_ref : CT_StrRef?
  /// <rich> (a:CT_TextBody) — rich text body choice branch (raw element).
  rich : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_Tx::new(element : @xml.Element) -> CT_Tx raise SchemaViolation {
  match first_child_named(element, "strRef") {
    Some(child) => { str_ref: Some(CT_StrRef::new(child)), rich: None }
    None =>
      match first_child_named(element, "rich") {
        Some(child) => { str_ref: None, rich: Some(child) }
        None =>
          raise SchemaViolation(
            schema="dml-chart.xsd",
            path="CT_Tx",
            reason="required choice (strRef|rich) missing",
          )
      }
  }
}

// =============================================================================
// XSD complex type CT_TextLanguageID — Part 1 §21.2.2.87 lang
//   <xsd:attribute name="val" type="s:ST_Lang" use="required"/>
// =============================================================================

///|
/// XSD complex type CT_TextLanguageID — Part 1 §21.2.2.87 (dml-chart.xsd) lang.
/// `val` is required and follows s:ST_Lang (BCP-47 language tag literal).
pub(all) struct CT_TextLanguageID {
  /// @val (s:ST_Lang) — required.
  val : String
} derive(Eq, Debug)

///|
pub fn CT_TextLanguageID::new(
  element : @xml.Element,
) -> CT_TextLanguageID raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_TextLanguageID/@val",
        reason="required attribute missing",
      )
  }
  if val.length() == 0 {
    raise SchemaViolation(
      schema="dml-chart.xsd",
      path="CT_TextLanguageID/@val",
      reason="ST_Lang must not be empty",
    )
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_Lvl — Part 1 §21.2.2.99 lvl
//   <xsd:element name="pt" type="CT_StrVal" minOccurs="0" maxOccurs="unbounded"/>
// =============================================================================

///|
/// XSD complex type CT_Lvl — Part 1 §21.2.2.99 (dml-chart.xsd) lvl.
pub(all) struct CT_Lvl {
  /// <pt> (CT_StrVal) — zero or more.
  pt : Array[CT_StrVal]
} derive(Eq, Debug)

///|
pub fn CT_Lvl::new(element : @xml.Element) -> CT_Lvl raise SchemaViolation {
  let pt = []
  for child in children_named(element, "pt") {
    pt.push(CT_StrVal::new(child))
  }
  { pt, }
}

// =============================================================================
// XSD complex type CT_MultiLvlStrData — Part 1 §21.2 (multiLvlStrCache)
//   <xsd:element name="ptCount" type="CT_UnsignedInt" minOccurs="0" maxOccurs="1"/>
//   <xsd:element name="lvl" type="CT_Lvl" minOccurs="0" maxOccurs="unbounded"/>
//   <xsd:element name="extLst" type="CT_ExtensionList" minOccurs="0" maxOccurs="1"/>
// =============================================================================

///|
/// XSD complex type CT_MultiLvlStrData — Part 1 §21.2.2.114 multiLvlStrCache.
pub(all) struct CT_MultiLvlStrData {
  /// <ptCount> (CT_UnsignedInt) — optional.
  pt_count : CT_UnsignedInt?
  /// <lvl> (CT_Lvl) — zero or more.
  lvl : Array[CT_Lvl]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_MultiLvlStrData::new(
  element : @xml.Element,
) -> CT_MultiLvlStrData raise SchemaViolation {
  let pt_count = match first_child_named(element, "ptCount") {
    Some(child) => Some(CT_UnsignedInt::new(child))
    None => None
  }
  let lvl = []
  for child in children_named(element, "lvl") {
    lvl.push(CT_Lvl::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { pt_count, lvl, ext_lst }
}

// =============================================================================
// XSD complex type CT_MultiLvlStrRef — Part 1 §21.2.2.115 multiLvlStrRef
//   <xsd:element name="f" type="xsd:string" minOccurs="1" maxOccurs="1"/>
//   <xsd:element name="multiLvlStrCache" type="CT_MultiLvlStrData" minOccurs="0" maxOccurs="1"/>
//   <xsd:element name="extLst" type="CT_ExtensionList" minOccurs="0" maxOccurs="1"/>
// =============================================================================

///|
/// XSD complex type CT_MultiLvlStrRef — Part 1 §21.2.2.115 (dml-chart.xsd)
/// multiLvlStrRef.
pub(all) struct CT_MultiLvlStrRef {
  /// <f> (xsd:string) — required.
  f : String
  /// <multiLvlStrCache> (CT_MultiLvlStrData) — optional.
  multi_lvl_str_cache : CT_MultiLvlStrData?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_MultiLvlStrRef::new(
  element : @xml.Element,
) -> CT_MultiLvlStrRef raise SchemaViolation {
  let f = match first_child_named(element, "f") {
    Some(child) => element_text(child)
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_MultiLvlStrRef/f",
        reason="required child missing",
      )
  }
  let multi_lvl_str_cache = match
    first_child_named(element, "multiLvlStrCache") {
    Some(child) => Some(CT_MultiLvlStrData::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { f, multi_lvl_str_cache, ext_lst }
}

// =============================================================================
// XSD complex type CT_AxDataSource — Part 1 §21.2.2.24 cat / §21.2.2.234 xVal
//   <xsd:choice minOccurs="1" maxOccurs="1">
//     multiLvlStrRef | numRef | numLit | strRef | strLit
//   </xsd:choice>
// =============================================================================

///|
/// XSD complex type CT_AxDataSource — Part 1 §21.2.2.24 (dml-chart.xsd) cat
/// / §21.2.2.234 xVal. Required 5-way choice for category axis data.
pub(all) enum CT_AxDataSource {
  /// <multiLvlStrRef> (CT_MultiLvlStrRef).
  AxDataMultiLvlStrRef(CT_MultiLvlStrRef)
  /// <numRef> (CT_NumRef).
  AxDataNumRef(CT_NumRef)
  /// <numLit> (CT_NumData).
  AxDataNumLit(CT_NumData)
  /// <strRef> (CT_StrRef).
  AxDataStrRef(CT_StrRef)
  /// <strLit> (CT_StrData).
  AxDataStrLit(CT_StrData)
} derive(Eq, Debug)

///|
pub fn CT_AxDataSource::new(
  element : @xml.Element,
) -> CT_AxDataSource raise SchemaViolation {
  match first_child_named(element, "multiLvlStrRef") {
    Some(child) => AxDataMultiLvlStrRef(CT_MultiLvlStrRef::new(child))
    None =>
      match first_child_named(element, "numRef") {
        Some(child) => AxDataNumRef(CT_NumRef::new(child))
        None =>
          match first_child_named(element, "numLit") {
            Some(child) => AxDataNumLit(CT_NumData::new(child))
            None =>
              match first_child_named(element, "strRef") {
                Some(child) => AxDataStrRef(CT_StrRef::new(child))
                None =>
                  match first_child_named(element, "strLit") {
                    Some(child) => AxDataStrLit(CT_StrData::new(child))
                    None =>
                      raise SchemaViolation(
                        schema="dml-chart.xsd",
                        path="CT_AxDataSource",
                        reason="required choice (multiLvlStrRef|numRef|numLit|strRef|strLit) missing",
                      )
                  }
              }
          }
      }
  }
}

// =============================================================================
// XSD complex type CT_SerTx — Part 1 §21.2.2.215 tx (Series Text)
//   <xsd:choice minOccurs="1" maxOccurs="1">
//     <xsd:element name="strRef" type="CT_StrRef" minOccurs="1" maxOccurs="1"/>
//     <xsd:element name="v" type="s:ST_Xstring" minOccurs="1" maxOccurs="1"/>
//   </xsd:choice>
// =============================================================================

///|
/// XSD complex type CT_SerTx — Part 1 §21.2.2.215 (dml-chart.xsd) tx
/// (Series Text). Required choice between <strRef> and a literal <v>.
pub(all) enum CT_SerTx {
  /// <strRef> (CT_StrRef).
  SerTxRef(CT_StrRef)
  /// <v> (s:ST_Xstring) literal text.
  SerTxVal(String)
} derive(Eq, Debug)

///|
pub fn CT_SerTx::new(element : @xml.Element) -> CT_SerTx raise SchemaViolation {
  match first_child_named(element, "strRef") {
    Some(child) => SerTxRef(CT_StrRef::new(child))
    None =>
      match first_child_named(element, "v") {
        Some(child) => SerTxVal(element_text(child))
        None =>
          raise SchemaViolation(
            schema="dml-chart.xsd",
            path="CT_SerTx",
            reason="required choice (strRef|v) missing",
          )
      }
  }
}

// =============================================================================
// XSD complex type CT_LayoutTarget — Part 1 §21.2.2.89 layoutTarget
//   <xsd:attribute name="val" type="ST_LayoutTarget" default="outer"/>
// =============================================================================

///|
/// XSD complex type CT_LayoutTarget — Part 1 §21.2.2.89 (dml-chart.xsd)
/// layoutTarget.
pub(all) struct CT_LayoutTarget {
  /// @val (ST_LayoutTarget) — optional, schema default `outer`.
  val : ST_LayoutTarget?
} derive(Eq, Debug)

///|
pub fn CT_LayoutTarget::new(
  element : @xml.Element,
) -> CT_LayoutTarget raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_LayoutTarget::parse(text))
    None => None
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_LayoutMode — Part 1 §21.2.2.81 hMode / xMode / yMode / wMode
//   <xsd:attribute name="val" type="ST_LayoutMode" default="factor"/>
// =============================================================================

///|
/// XSD complex type CT_LayoutMode — Part 1 §21.2.2.81 hMode /
/// §21.2.2.231 wMode / §21.2.2.233 xMode / §21.2.2.236 yMode (dml-chart.xsd).
pub(all) struct CT_LayoutMode {
  /// @val (ST_LayoutMode) — optional, schema default `factor`.
  val : ST_LayoutMode?
} derive(Eq, Debug)

///|
pub fn CT_LayoutMode::new(
  element : @xml.Element,
) -> CT_LayoutMode raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_LayoutMode::parse(text))
    None => None
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_ManualLayout — Part 1 §21.2.2.104 manualLayout
//   sequence (all optional): layoutTarget, xMode, yMode, wMode, hMode,
//   x, y, w, h, extLst.
// =============================================================================

///|
/// XSD complex type CT_ManualLayout — Part 1 §21.2.2.104 (dml-chart.xsd)
/// manualLayout.
pub(all) struct CT_ManualLayout {
  /// <layoutTarget> (CT_LayoutTarget) — optional.
  layout_target : CT_LayoutTarget?
  /// <xMode> (CT_LayoutMode) — optional.
  x_mode : CT_LayoutMode?
  /// <yMode> (CT_LayoutMode) — optional.
  y_mode : CT_LayoutMode?
  /// <wMode> (CT_LayoutMode) — optional.
  w_mode : CT_LayoutMode?
  /// <hMode> (CT_LayoutMode) — optional.
  h_mode : CT_LayoutMode?
  /// <x> (CT_Double) — optional.
  x : CT_Double?
  /// <y> (CT_Double) — optional.
  y : CT_Double?
  /// <w> (CT_Double) — optional.
  w : CT_Double?
  /// <h> (CT_Double) — optional.
  h : CT_Double?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_ManualLayout::new(
  element : @xml.Element,
) -> CT_ManualLayout raise SchemaViolation {
  let layout_target = match first_child_named(element, "layoutTarget") {
    Some(child) => Some(CT_LayoutTarget::new(child))
    None => None
  }
  let x_mode = match first_child_named(element, "xMode") {
    Some(child) => Some(CT_LayoutMode::new(child))
    None => None
  }
  let y_mode = match first_child_named(element, "yMode") {
    Some(child) => Some(CT_LayoutMode::new(child))
    None => None
  }
  let w_mode = match first_child_named(element, "wMode") {
    Some(child) => Some(CT_LayoutMode::new(child))
    None => None
  }
  let h_mode = match first_child_named(element, "hMode") {
    Some(child) => Some(CT_LayoutMode::new(child))
    None => None
  }
  let x = match first_child_named(element, "x") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let y = match first_child_named(element, "y") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let w = match first_child_named(element, "w") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let h = match first_child_named(element, "h") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { layout_target, x_mode, y_mode, w_mode, h_mode, x, y, w, h, ext_lst }
}

// =============================================================================
// XSD complex type CT_Layout — Part 1 §21.2.2.88 layout
//   <xsd:element name="manualLayout" type="CT_ManualLayout" minOccurs="0" maxOccurs="1"/>
//   <xsd:element name="extLst" type="CT_ExtensionList" minOccurs="0" maxOccurs="1"/>
// =============================================================================

///|
/// XSD complex type CT_Layout — Part 1 §21.2.2.88 (dml-chart.xsd) layout.
pub(all) struct CT_Layout {
  /// <manualLayout> (CT_ManualLayout) — optional.
  manual_layout : CT_ManualLayout?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Layout::new(
  element : @xml.Element,
) -> CT_Layout raise SchemaViolation {
  let manual_layout = match first_child_named(element, "manualLayout") {
    Some(child) => Some(CT_ManualLayout::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { manual_layout, ext_lst }
}

// =============================================================================
// XSD complex type CT_Title — Part 1 §21.2.2.210 title
//   sequence: tx, layout, overlay, spPr, txPr, extLst (all optional).
// =============================================================================

///|
/// XSD complex type CT_Title — Part 1 §21.2.2.210 (dml-chart.xsd) title.
/// `spPr` and `txPr` are drawingml/main types preserved as raw elements.
pub(all) struct CT_Title {
  /// <tx> (CT_Tx) — optional.
  tx : CT_Tx?
  /// <layout> (CT_Layout) — optional.
  layout : CT_Layout?
  /// <overlay> (CT_Boolean) — optional.
  overlay : CT_Boolean?
  /// <spPr> (a:CT_ShapeProperties, drawingml/main) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody, drawingml/main) preserved as raw element.
  tx_pr : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Title::new(element : @xml.Element) -> CT_Title raise SchemaViolation {
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_Tx::new(child))
    None => None
  }
  let layout = match first_child_named(element, "layout") {
    Some(child) => Some(CT_Layout::new(child))
    None => None
  }
  let overlay = match first_child_named(element, "overlay") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { tx, layout, overlay, sp_pr, tx_pr, ext_lst }
}

// =============================================================================
// XSD complex type CT_RotX — Part 1 §21.2.2.157 rotX
//   <xsd:attribute name="val" type="ST_RotX" default="0"/>
// =============================================================================

///|
/// XSD complex type CT_RotX — Part 1 §21.2.2.157 (dml-chart.xsd) rotX.
/// Optional X-rotation degrees (-90..90 from ST_RotX).
pub(all) struct CT_RotX {
  /// @val (ST_RotX) — optional, schema default `0` degrees.
  val : ST_RotX?
} derive(Eq, Debug)

///|
pub fn CT_RotX::new(element : @xml.Element) -> CT_RotX raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_RotX::parse(text))
    None => None
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_HPercent — Part 1 §21.2.2.83 hPercent
//   <xsd:attribute name="val" type="ST_HPercent" default="100%"/>
// =============================================================================

///|
/// XSD complex type CT_HPercent — Part 1 §21.2.2.83 (dml-chart.xsd)
/// hPercent. Optional height percentage (ST_HPercent union; default 100%).
pub(all) struct CT_HPercent {
  /// @val (ST_HPercent) — optional, schema default `100%`.
  val : ST_HPercent?
} derive(Eq, Debug)

///|
pub fn CT_HPercent::new(
  element : @xml.Element,
) -> CT_HPercent raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_HPercent::parse(text))
    None => None
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_RotY — Part 1 §21.2.2.158 rotY
//   <xsd:attribute name="val" type="ST_RotY" default="0"/>
// =============================================================================

///|
/// XSD complex type CT_RotY — Part 1 §21.2.2.158 (dml-chart.xsd) rotY.
/// Optional Y-rotation degrees (0..360 from ST_RotY).
pub(all) struct CT_RotY {
  /// @val (ST_RotY) — optional, schema default `0` degrees.
  val : ST_RotY?
} derive(Eq, Debug)

///|
pub fn CT_RotY::new(element : @xml.Element) -> CT_RotY raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_RotY::parse(text))
    None => None
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_DepthPercent — Part 1 §21.2.2.41 depthPercent
//   <xsd:attribute name="val" type="ST_DepthPercent" default="100%"/>
// =============================================================================

///|
/// XSD complex type CT_DepthPercent — Part 1 §21.2.2.41 (dml-chart.xsd)
/// depthPercent. Optional depth percentage (ST_DepthPercent; default 100%).
pub(all) struct CT_DepthPercent {
  /// @val (ST_DepthPercent) — optional, schema default `100%`.
  val : ST_DepthPercent?
} derive(Eq, Debug)

///|
pub fn CT_DepthPercent::new(
  element : @xml.Element,
) -> CT_DepthPercent raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_DepthPercent::parse(text))
    None => None
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_Perspective — Part 1 §21.2.2.136 perspective
//   <xsd:attribute name="val" type="ST_Perspective" default="30"/>
// =============================================================================

///|
/// XSD complex type CT_Perspective — Part 1 §21.2.2.136 (dml-chart.xsd)
/// perspective. Optional perspective value (ST_Perspective 0..240; default 30).
pub(all) struct CT_Perspective {
  /// @val (ST_Perspective) — optional, schema default `30`.
  val : ST_Perspective?
} derive(Eq, Debug)

///|
pub fn CT_Perspective::new(
  element : @xml.Element,
) -> CT_Perspective raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_Perspective::parse(text))
    None => None
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_View3D — Part 1 §21.2.2.228 view3D
//   sequence: rotX, hPercent, rotY, depthPercent, rAngAx, perspective, extLst.
// =============================================================================

///|
/// XSD complex type CT_View3D — Part 1 §21.2.2.228 (dml-chart.xsd) view3D.
/// Schema dml-chart.xsd complex type `CT_View3D`. Child elements: `rotX`,
/// `hPercent`, `rotY`, `depthPercent`, `rAngAx`, `perspective`, `extLst`.
/// Child types: `CT_RotX`, `CT_HPercent`, `CT_RotY`, `CT_DepthPercent`,
/// `CT_Boolean`, `CT_Perspective`, `CT_ExtensionList`.
pub(all) struct CT_View3D {
  /// <rotX> (CT_RotX) — optional.
  rot_x : CT_RotX?
  /// <hPercent> (CT_HPercent) — optional.
  h_percent : CT_HPercent?
  /// <rotY> (CT_RotY) — optional.
  rot_y : CT_RotY?
  /// <depthPercent> (CT_DepthPercent) — optional.
  depth_percent : CT_DepthPercent?
  /// <rAngAx> (CT_Boolean) — optional.
  r_ang_ax : CT_Boolean?
  /// <perspective> (CT_Perspective) — optional.
  perspective : CT_Perspective?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_View3D::new(
  element : @xml.Element,
) -> CT_View3D raise SchemaViolation {
  let rot_x = match first_child_named(element, "rotX") {
    Some(child) => Some(CT_RotX::new(child))
    None => None
  }
  let h_percent = match first_child_named(element, "hPercent") {
    Some(child) => Some(CT_HPercent::new(child))
    None => None
  }
  let rot_y = match first_child_named(element, "rotY") {
    Some(child) => Some(CT_RotY::new(child))
    None => None
  }
  let depth_percent = match first_child_named(element, "depthPercent") {
    Some(child) => Some(CT_DepthPercent::new(child))
    None => None
  }
  let r_ang_ax = match first_child_named(element, "rAngAx") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let perspective = match first_child_named(element, "perspective") {
    Some(child) => Some(CT_Perspective::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { rot_x, h_percent, rot_y, depth_percent, r_ang_ax, perspective, ext_lst }
}

// =============================================================================
// XSD complex type CT_Surface — Part 1 §21.2.2.69 floor / sideWall / backWall
//   sequence: thickness, spPr, pictureOptions, extLst.
// =============================================================================

///|
/// XSD complex type CT_Surface — Part 1 §21.2.2.69 floor / §21.2.2.11
/// backWall / §21.2.2.191 sideWall (dml-chart.xsd). `spPr` is a
/// drawingml/main element preserved raw; `pictureOptions` is a chunk2
/// wrapper kept as a raw element so chunk1 does not depend on a not-yet
/// typed wrapper.
pub(all) struct CT_Surface {
  /// <thickness> (CT_Thickness) — optional.
  thickness : CT_Thickness?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <pictureOptions> (CT_PictureOptions) preserved as raw element until
  /// the chunk2 typed wrapper lands.
  picture_options : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Surface::new(
  element : @xml.Element,
) -> CT_Surface raise SchemaViolation {
  let thickness = match first_child_named(element, "thickness") {
    Some(child) => Some(CT_Thickness::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let picture_options = first_child_named(element, "pictureOptions")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { thickness, sp_pr, picture_options, ext_lst }
}

// =============================================================================
// XSD complex type CT_Thickness — Part 1 §21.2.2.206 thickness
//   <xsd:attribute name="val" type="ST_Thickness" use="required"/>
// =============================================================================

///|
/// XSD complex type CT_Thickness — Part 1 §21.2.2.206 (dml-chart.xsd)
/// thickness. Required ST_Thickness percentage payload.
pub(all) struct CT_Thickness {
  /// @val (ST_Thickness) — required.
  val : ST_Thickness
} derive(Eq, Debug)

///|
pub fn CT_Thickness::new(
  element : @xml.Element,
) -> CT_Thickness raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_Thickness/@val",
        reason="required attribute missing",
      )
  }
  let val = ST_Thickness::parse(raw)
  { val, }
}

// =============================================================================
// XSD complex type CT_DTable — Part 1 §21.2.2.54 dTable
//   sequence: showHorzBorder, showVertBorder, showOutline, showKeys,
//             spPr, txPr, extLst (all optional).
// =============================================================================

///|
/// XSD complex type CT_DTable — Part 1 §21.2.2.54 (dml-chart.xsd) dTable.
pub(all) struct CT_DTable {
  /// <showHorzBorder> (CT_Boolean) — optional.
  show_horz_border : CT_Boolean?
  /// <showVertBorder> (CT_Boolean) — optional.
  show_vert_border : CT_Boolean?
  /// <showOutline> (CT_Boolean) — optional.
  show_outline : CT_Boolean?
  /// <showKeys> (CT_Boolean) — optional.
  show_keys : CT_Boolean?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_DTable::new(
  element : @xml.Element,
) -> CT_DTable raise SchemaViolation {
  let show_horz_border = match first_child_named(element, "showHorzBorder") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_vert_border = match first_child_named(element, "showVertBorder") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_outline = match first_child_named(element, "showOutline") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_keys = match first_child_named(element, "showKeys") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    show_horz_border,
    show_vert_border,
    show_outline,
    show_keys,
    sp_pr,
    tx_pr,
    ext_lst,
  }
}

// =============================================================================
// XSD complex type CT_GapAmount — Part 1 §21.2.2.75 gapWidth / §21.2.2.74 gapDepth
//   <xsd:attribute name="val" type="ST_GapAmount" default="150%"/>
// =============================================================================

///|
/// XSD complex type CT_GapAmount — Part 1 §21.2.2.75 gapWidth /
/// §21.2.2.74 gapDepth (dml-chart.xsd). Optional ST_GapAmount percentage
/// (schema default `150%`).
pub(all) struct CT_GapAmount {
  /// @val (ST_GapAmount) — optional, schema default `150%`.
  val : ST_GapAmount?
} derive(Eq, Debug)

///|
pub fn CT_GapAmount::new(
  element : @xml.Element,
) -> CT_GapAmount raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_GapAmount::parse(text))
    None => None
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_Overlap — Part 1 §21.2.2.131 overlap
//   <xsd:attribute name="val" type="ST_Overlap" default="0%"/>
// =============================================================================

///|
/// XSD complex type CT_Overlap — Part 1 §21.2.2.131 (dml-chart.xsd) overlap.
/// Optional ST_Overlap percent (-100%..100%; schema default `0%`).
pub(all) struct CT_Overlap {
  /// @val (ST_Overlap) — optional, schema default `0%`.
  val : ST_Overlap?
} derive(Eq, Debug)

///|
pub fn CT_Overlap::new(
  element : @xml.Element,
) -> CT_Overlap raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_Overlap::parse(text))
    None => None
  }
  { val, }
}

// =============================================================================
// XSD complex type CT_BubbleScale — Part 1 §21.2.2.21 bubbleScale
//   <xsd:attribute name="val" type="ST_BubbleScale" default="100%"/>
// =============================================================================

///|
/// XSD complex type CT_BubbleScale — Part 1 §21.2.2.21 (dml-chart.xsd)
/// bubbleScale. Optional ST_BubbleScale percent (0..300%; default 100%).
pub(all) struct CT_BubbleScale {
  /// @val (ST_BubbleScale) — optional, schema default `100%`.
  val : ST_BubbleScale?
} derive(Eq, Debug)

///|
pub fn CT_BubbleScale::new(
  element : @xml.Element,
) -> CT_BubbleScale raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_BubbleScale::parse(text))
    None => None
  }
  { val, }
}

// =============================================================================
// chunk2/3/4 wrappers — left as `{ element : @xml.Element }` holders.
// These belong to follow-up batches and must not be touched in chunk1.
// =============================================================================

///|
/// XSD complex type CT_SizeRepresents (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_SizeRepresents {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_FirstSliceAng (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_FirstSliceAng {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_HoleSize (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_HoleSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SplitType (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_SplitType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_CustSplit (§21.2, dml-chart.xsd): attributes no local attributes; children secondPiePt: CT_UnsignedInt.
pub(all) struct CT_CustSplit {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SecondPieSize (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_SecondPieSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_NumFmt (§21.2, dml-chart.xsd): attributes formatCode, sourceLinked; children no local child elements.
pub(all) struct CT_NumFmt {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LblAlgn (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_LblAlgn {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DLblPos (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_DLblPos {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DLbl (§21.2, dml-chart.xsd): attributes no local attributes; children idx: CT_UnsignedInt, delete: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_DLbl {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DLbls (§21.2, dml-chart.xsd): attributes no local attributes; children dLbl: CT_DLbl, delete: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_DLbls {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_MarkerStyle (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_MarkerStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_MarkerSize (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_MarkerSize {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Marker (§21.2, dml-chart.xsd): attributes no local attributes; children symbol: CT_MarkerStyle, size: CT_MarkerSize, spPr: a:CT_ShapeProperties, extLst: CT_ExtensionList.
pub(all) struct CT_Marker {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DPt (§21.2, dml-chart.xsd): attributes no local attributes; children idx: CT_UnsignedInt, invertIfNegative: CT_Boolean, marker: CT_Marker, bubble3D: CT_Boolean, explosion: CT_UnsignedInt, spPr: a:CT_ShapeProperties, pictureOptions: CT_PictureOptions, extLst: CT_ExtensionList.
pub(all) struct CT_DPt {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TrendlineType (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_TrendlineType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Order (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Order {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Period (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Period {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TrendlineLbl (§21.2, dml-chart.xsd): attributes no local attributes; children layout: CT_Layout, tx: CT_Tx, numFmt: CT_NumFmt, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, extLst: CT_ExtensionList.
pub(all) struct CT_TrendlineLbl {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Trendline (§21.2, dml-chart.xsd): attributes no local attributes; children name: xsd:string, spPr: a:CT_ShapeProperties, trendlineType: CT_TrendlineType, order: CT_Order, period: CT_Period, forward: CT_Double, backward: CT_Double, intercept: CT_Double, dispRSqr: CT_Boolean, dispEq: CT_Boolean, trendlineLbl: CT_TrendlineLbl, extLst: CT_ExtensionList.
pub(all) struct CT_Trendline {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ErrDir (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_ErrDir {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ErrBarType (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_ErrBarType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ErrValType (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_ErrValType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ErrBars (§21.2, dml-chart.xsd): attributes no local attributes; children errDir: CT_ErrDir, errBarType: CT_ErrBarType, errValType: CT_ErrValType, noEndCap: CT_Boolean, plus: CT_NumDataSource, minus: CT_NumDataSource, val: CT_Double, spPr: a:CT_ShapeProperties, extLst: CT_ExtensionList.
pub(all) struct CT_ErrBars {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_UpDownBar (§21.2, dml-chart.xsd): attributes no local attributes; children spPr: a:CT_ShapeProperties.
pub(all) struct CT_UpDownBar {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_UpDownBars (§21.2, dml-chart.xsd): attributes no local attributes; children gapWidth: CT_GapAmount, upBars: CT_UpDownBar, downBars: CT_UpDownBar, extLst: CT_ExtensionList.
pub(all) struct CT_UpDownBars {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LineSer (§21.2, dml-chart.xsd): attributes no local attributes; children marker: CT_Marker, dPt: CT_DPt, dLbls: CT_DLbls, trendline: CT_Trendline, errBars: CT_ErrBars, cat: CT_AxDataSource, val: CT_NumDataSource, smooth: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_LineSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ScatterSer (§21.2, dml-chart.xsd): attributes no local attributes; children marker: CT_Marker, dPt: CT_DPt, dLbls: CT_DLbls, trendline: CT_Trendline, errBars: CT_ErrBars, xVal: CT_AxDataSource, yVal: CT_NumDataSource, smooth: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_ScatterSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_RadarSer (§21.2, dml-chart.xsd): attributes no local attributes; children marker: CT_Marker, dPt: CT_DPt, dLbls: CT_DLbls, cat: CT_AxDataSource, val: CT_NumDataSource, extLst: CT_ExtensionList.
pub(all) struct CT_RadarSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BarSer (§21.2, dml-chart.xsd): attributes no local attributes; children invertIfNegative: CT_Boolean, pictureOptions: CT_PictureOptions, dPt: CT_DPt, dLbls: CT_DLbls, trendline: CT_Trendline, errBars: CT_ErrBars, cat: CT_AxDataSource, val: CT_NumDataSource, shape: CT_Shape, extLst: CT_ExtensionList.
pub(all) struct CT_BarSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AreaSer (§21.2, dml-chart.xsd): attributes no local attributes; children pictureOptions: CT_PictureOptions, dPt: CT_DPt, dLbls: CT_DLbls, trendline: CT_Trendline, errBars: CT_ErrBars, cat: CT_AxDataSource, val: CT_NumDataSource, extLst: CT_ExtensionList.
pub(all) struct CT_AreaSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PieSer (§21.2, dml-chart.xsd): attributes no local attributes; children explosion: CT_UnsignedInt, dPt: CT_DPt, dLbls: CT_DLbls, cat: CT_AxDataSource, val: CT_NumDataSource, extLst: CT_ExtensionList.
pub(all) struct CT_PieSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BubbleSer (§21.2, dml-chart.xsd): attributes no local attributes; children invertIfNegative: CT_Boolean, dPt: CT_DPt, dLbls: CT_DLbls, trendline: CT_Trendline, errBars: CT_ErrBars, xVal: CT_AxDataSource, yVal: CT_NumDataSource, bubbleSize: CT_NumDataSource, bubble3D: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_BubbleSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SurfaceSer (§21.2, dml-chart.xsd): attributes no local attributes; children cat: CT_AxDataSource, val: CT_NumDataSource, extLst: CT_ExtensionList.
pub(all) struct CT_SurfaceSer {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Grouping (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Grouping {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Chart (§21.2, dml-chart.xsd): attributes no local attributes; children title: CT_Title, autoTitleDeleted: CT_Boolean, pivotFmts: CT_PivotFmts, view3D: CT_View3D, floor: CT_Surface, sideWall: CT_Surface, backWall: CT_Surface, plotArea: CT_PlotArea, legend: CT_Legend, plotVisOnly: CT_Boolean, dispBlanksAs: CT_DispBlanksAs, showDLblsOverMax: CT_Boolean, extLst: CT_ExtensionList.
/// XSD complex type CT_Chart: dml-chart.xsd defines CT_Chart for chart
/// payload children including title, plotArea, legend, view3D, and extLst.
/// CT_Chart is the chart element payload containing plot area, title, legend,
/// 3-D view, floor, side wall, back wall, display blanks behavior, and extensions.
/// Schema dml-chart.xsd complex type `CT_Chart` children include
/// `{'name': 'title', 'type': 'CT_Title'}` and
/// `{'name': 'plotArea', 'type': 'CT_PlotArea'}`.
pub(all) struct CT_Chart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ChartLines (§21.2, dml-chart.xsd): attributes no local attributes; children spPr: a:CT_ShapeProperties.
pub(all) struct CT_ChartLines {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LineChart (§21.2, dml-chart.xsd): attributes no local attributes; children hiLowLines: CT_ChartLines, upDownBars: CT_UpDownBars, marker: CT_Boolean, smooth: CT_Boolean, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_LineChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Line3DChart (§21.2, dml-chart.xsd): attributes no local attributes; children gapDepth: CT_GapAmount, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_Line3DChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_StockChart (§21.2, dml-chart.xsd): attributes no local attributes; children ser: CT_LineSer, dLbls: CT_DLbls, dropLines: CT_ChartLines, hiLowLines: CT_ChartLines, upDownBars: CT_UpDownBars, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_StockChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ScatterStyle (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_ScatterStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ScatterChart (§21.2, dml-chart.xsd): attributes no local attributes; children scatterStyle: CT_ScatterStyle, varyColors: CT_Boolean, ser: CT_ScatterSer, dLbls: CT_DLbls, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_ScatterChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_RadarStyle (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_RadarStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_RadarChart (§21.2, dml-chart.xsd): attributes no local attributes; children radarStyle: CT_RadarStyle, varyColors: CT_Boolean, ser: CT_RadarSer, dLbls: CT_DLbls, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_RadarChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BarGrouping (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_BarGrouping {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BarDir (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_BarDir {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Shape (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Shape {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BarChart (§21.2, dml-chart.xsd): attributes no local attributes; children gapWidth: CT_GapAmount, overlap: CT_Overlap, serLines: CT_ChartLines, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_BarChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Bar3DChart (§21.2, dml-chart.xsd): attributes no local attributes; children gapWidth: CT_GapAmount, gapDepth: CT_GapAmount, shape: CT_Shape, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_Bar3DChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AreaChart (§21.2, dml-chart.xsd): attributes no local attributes; children axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_AreaChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Area3DChart (§21.2, dml-chart.xsd): attributes no local attributes; children gapDepth: CT_GapAmount, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_Area3DChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PieChart (§21.2, dml-chart.xsd): attributes no local attributes; children firstSliceAng: CT_FirstSliceAng, extLst: CT_ExtensionList.
pub(all) struct CT_PieChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Pie3DChart (§21.2, dml-chart.xsd): attributes no local attributes; children extLst: CT_ExtensionList.
pub(all) struct CT_Pie3DChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DoughnutChart (§21.2, dml-chart.xsd): attributes no local attributes; children firstSliceAng: CT_FirstSliceAng, holeSize: CT_HoleSize, extLst: CT_ExtensionList.
pub(all) struct CT_DoughnutChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_OfPieType (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_OfPieType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_OfPieChart (§21.2, dml-chart.xsd): attributes no local attributes; children ofPieType: CT_OfPieType, gapWidth: CT_GapAmount, splitType: CT_SplitType, splitPos: CT_Double, custSplit: CT_CustSplit, secondPieSize: CT_SecondPieSize, serLines: CT_ChartLines, extLst: CT_ExtensionList.
pub(all) struct CT_OfPieChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BubbleChart (§21.2, dml-chart.xsd): attributes no local attributes; children varyColors: CT_Boolean, ser: CT_BubbleSer, dLbls: CT_DLbls, bubble3D: CT_Boolean, bubbleScale: CT_BubbleScale, showNegBubbles: CT_Boolean, sizeRepresents: CT_SizeRepresents, axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_BubbleChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BandFmt (§21.2, dml-chart.xsd): attributes no local attributes; children idx: CT_UnsignedInt, spPr: a:CT_ShapeProperties.
pub(all) struct CT_BandFmt {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BandFmts (§21.2, dml-chart.xsd): attributes no local attributes; children bandFmt: CT_BandFmt.
pub(all) struct CT_BandFmts {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SurfaceChart (§21.2, dml-chart.xsd): attributes no local attributes; children axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_SurfaceChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Surface3DChart (§21.2, dml-chart.xsd): attributes no local attributes; children axId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_Surface3DChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AxPos (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_AxPos {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Crosses (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Crosses {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_CrossBetween (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_CrossBetween {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TickMark (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_TickMark {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TickLblPos (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_TickLblPos {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Skip (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Skip {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TimeUnit (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_TimeUnit {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AxisUnit (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_AxisUnit {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_BuiltInUnit (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_BuiltInUnit {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PictureFormat (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_PictureFormat {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PictureStackUnit (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_PictureStackUnit {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PictureOptions (§21.2, dml-chart.xsd): attributes no local attributes; children applyToFront: CT_Boolean, applyToSides: CT_Boolean, applyToEnd: CT_Boolean, pictureFormat: CT_PictureFormat, pictureStackUnit: CT_PictureStackUnit.
pub(all) struct CT_PictureOptions {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DispUnitsLbl (§21.2, dml-chart.xsd): attributes no local attributes; children layout: CT_Layout, tx: CT_Tx, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody.
pub(all) struct CT_DispUnitsLbl {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DispUnits (§21.2, dml-chart.xsd): attributes no local attributes; children custUnit: CT_Double, builtInUnit: CT_BuiltInUnit, dispUnitsLbl: CT_DispUnitsLbl, extLst: CT_ExtensionList.
pub(all) struct CT_DispUnits {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Orientation (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Orientation {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LogBase (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_LogBase {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Scaling (§21.2, dml-chart.xsd): attributes no local attributes; children logBase: CT_LogBase, orientation: CT_Orientation, max: CT_Double, min: CT_Double, extLst: CT_ExtensionList.
pub(all) struct CT_Scaling {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LblOffset (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_LblOffset {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_CatAx (§21.2, dml-chart.xsd): attributes no local attributes; children auto: CT_Boolean, lblAlgn: CT_LblAlgn, lblOffset: CT_LblOffset, tickLblSkip: CT_Skip, tickMarkSkip: CT_Skip, noMultiLvlLbl: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_CatAx {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DateAx (§21.2, dml-chart.xsd): attributes no local attributes; children auto: CT_Boolean, lblOffset: CT_LblOffset, baseTimeUnit: CT_TimeUnit, majorUnit: CT_AxisUnit, majorTimeUnit: CT_TimeUnit, minorUnit: CT_AxisUnit, minorTimeUnit: CT_TimeUnit, extLst: CT_ExtensionList.
pub(all) struct CT_DateAx {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_SerAx (§21.2, dml-chart.xsd): attributes no local attributes; children tickLblSkip: CT_Skip, tickMarkSkip: CT_Skip, extLst: CT_ExtensionList.
pub(all) struct CT_SerAx {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ValAx (§21.2, dml-chart.xsd): attributes no local attributes; children crossBetween: CT_CrossBetween, majorUnit: CT_AxisUnit, minorUnit: CT_AxisUnit, dispUnits: CT_DispUnits, extLst: CT_ExtensionList.
pub(all) struct CT_ValAx {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PlotArea (§21.2, dml-chart.xsd): attributes no local attributes; children layout: CT_Layout, areaChart: CT_AreaChart, area3DChart: CT_Area3DChart, lineChart: CT_LineChart, line3DChart: CT_Line3DChart, stockChart: CT_StockChart, radarChart: CT_RadarChart, scatterChart: CT_ScatterChart, pieChart: CT_PieChart, pie3DChart: CT_Pie3DChart, doughnutChart: CT_DoughnutChart, barChart: CT_BarChart, bar3DChart: CT_Bar3DChart, ofPieChart: CT_OfPieChart, surfaceChart: CT_SurfaceChart, surface3DChart: CT_Surface3DChart, bubbleChart: CT_BubbleChart, valAx: CT_ValAx, catAx: CT_CatAx, dateAx: CT_DateAx, serAx: CT_SerAx, dTable: CT_DTable, spPr: a:CT_ShapeProperties, extLst: CT_ExtensionList.
pub(all) struct CT_PlotArea {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PivotFmt (§21.2, dml-chart.xsd): attributes no local attributes; children idx: CT_UnsignedInt, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, marker: CT_Marker, dLbl: CT_DLbl, extLst: CT_ExtensionList.
pub(all) struct CT_PivotFmt {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PivotFmts (§21.2, dml-chart.xsd): attributes no local attributes; children pivotFmt: CT_PivotFmt.
pub(all) struct CT_PivotFmts {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LegendPos (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_LegendPos {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_LegendEntry (§21.2, dml-chart.xsd): attributes no local attributes; children idx: CT_UnsignedInt, delete: CT_Boolean, extLst: CT_ExtensionList.
pub(all) struct CT_LegendEntry {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Legend (§21.2, dml-chart.xsd): attributes no local attributes; children legendPos: CT_LegendPos, legendEntry: CT_LegendEntry, layout: CT_Layout, overlay: CT_Boolean, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, extLst: CT_ExtensionList.
pub(all) struct CT_Legend {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_DispBlanksAs (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_DispBlanksAs {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Chart from a parsed chart element while keeping the complete XML tree.
pub fn CT_Chart::new(element : @xml.Element) -> CT_Chart {
  if element.name.local_name.length() == 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// Parse an element already selected for XSD complex type CT_Chart.
///
/// Schema dml-chart.xsd complex type `CT_Chart` has children title,
/// autoTitleDeleted, pivotFmts, view3D, floor, sideWall, backWall, plotArea,
/// legend, plotVisOnly, dispBlanksAs, showDLblsOverMax, and extLst.
pub fn parse_ct_chart_element(element : @xml.Element) -> CT_Chart {
  CT_Chart::new(element)
}

///|
/// Return whether CT_Chart contains the required chart payload child plotArea.
pub fn CT_Chart::has_plot_area(self : CT_Chart) -> Bool {
  let mut found = false
  for child in self.element.children {
    match child {
      @xml.Node::Element(element) =>
        if element.name.local_name == "plotArea" {
          found = true
        }
      _ => ()
    }
  }
  found
}

///|
/// XSD complex type CT_Style (§21.2, dml-chart.xsd): attributes val; children no local child elements.
pub(all) struct CT_Style {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PivotSource (§21.2, dml-chart.xsd): attributes no local attributes; children name: s:ST_Xstring, fmtId: CT_UnsignedInt, extLst: CT_ExtensionList.
pub(all) struct CT_PivotSource {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Protection (§21.2, dml-chart.xsd): attributes no local attributes; children chartObject: CT_Boolean, data: CT_Boolean, formatting: CT_Boolean, selection: CT_Boolean, userInterface: CT_Boolean.
pub(all) struct CT_Protection {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_HeaderFooter (§21.2, dml-chart.xsd): attributes alignWithMargins, differentOddEven, differentFirst; children oddHeader: s:ST_Xstring, oddFooter: s:ST_Xstring, evenHeader: s:ST_Xstring, evenFooter: s:ST_Xstring, firstHeader: s:ST_Xstring, firstFooter: s:ST_Xstring.
pub(all) struct CT_HeaderFooter {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PageMargins (§21.2, dml-chart.xsd): attributes l, r, t, b, header, footer; children no local child elements.
pub(all) struct CT_PageMargins {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ExternalData (§21.2, dml-chart.xsd): attributes r:id; children autoUpdate: CT_Boolean.
pub(all) struct CT_ExternalData {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PageSetup (§21.2, dml-chart.xsd): attributes paperSize, paperHeight, paperWidth, firstPageNumber, orientation, blackAndWhite, draft, useFirstPageNumber, horizontalDpi, verticalDpi, copies; children no local child elements.
pub(all) struct CT_PageSetup {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PrintSettings (§21.2, dml-chart.xsd): attributes no local attributes; children headerFooter: CT_HeaderFooter, pageMargins: CT_PageMargins, pageSetup: CT_PageSetup.
pub(all) struct CT_PrintSettings {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ChartSpace (§21.2, dml-chart.xsd): attributes no local attributes; children date1904: CT_Boolean, lang: CT_TextLanguageID, roundedCorners: CT_Boolean, style: CT_Style, clrMapOvr: a:CT_ColorMapping, pivotSource: CT_PivotSource, protection: CT_Protection, chart: CT_Chart, spPr: a:CT_ShapeProperties, txPr: a:CT_TextBody, externalData: CT_ExternalData, printSettings: CT_PrintSettings, userShapes: CT_RelId, extLst: CT_ExtensionList.
pub(all) struct CT_ChartSpace {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ShapeNonVisual (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children cNvPr: a:CT_NonVisualDrawingProps, cNvSpPr: a:CT_NonVisualDrawingShapeProps.
pub(all) struct CT_ShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Shape is also present in dml-chartDrawing.xsd (§21.3); this shared holder captures the parsed element for both schema bundles.

///|
/// XSD complex type CT_ConnectorNonVisual (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children cNvPr: a:CT_NonVisualDrawingProps, cNvCxnSpPr: a:CT_NonVisualConnectorProperties.
pub(all) struct CT_ConnectorNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Connector (§21.3, dml-chartDrawing.xsd): attributes macro, fPublished; children nvCxnSpPr: CT_ConnectorNonVisual, spPr: a:CT_ShapeProperties, style: a:CT_ShapeStyle.
pub(all) struct CT_Connector {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PictureNonVisual (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children cNvPr: a:CT_NonVisualDrawingProps, cNvPicPr: a:CT_NonVisualPictureProperties.
pub(all) struct CT_PictureNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Picture (§21.3, dml-chartDrawing.xsd): attributes macro, fPublished; children nvPicPr: CT_PictureNonVisual, blipFill: a:CT_BlipFillProperties, spPr: a:CT_ShapeProperties, style: a:CT_ShapeStyle.
pub(all) struct CT_Picture {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GraphicFrameNonVisual (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children cNvPr: a:CT_NonVisualDrawingProps, cNvGraphicFramePr: a:CT_NonVisualGraphicFrameProperties.
pub(all) struct CT_GraphicFrameNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GraphicFrame (§21.3, dml-chartDrawing.xsd): attributes macro, fPublished; children nvGraphicFramePr: CT_GraphicFrameNonVisual, xfrm: a:CT_Transform2D, a:graphic.
pub(all) struct CT_GraphicFrame {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GroupShapeNonVisual (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children cNvPr: a:CT_NonVisualDrawingProps, cNvGrpSpPr: a:CT_NonVisualGroupDrawingShapeProps.
pub(all) struct CT_GroupShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GroupShape (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children nvGrpSpPr: CT_GroupShapeNonVisual, grpSpPr: a:CT_GroupShapeProperties, sp: CT_Shape, grpSp: CT_GroupShape, graphicFrame: CT_GraphicFrame, cxnSp: CT_Connector, pic: CT_Picture.
pub(all) struct CT_GroupShape {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Marker is also present in dml-chartDrawing.xsd (§21.3); this shared holder captures the parsed element for both schema bundles.

///|
/// XSD complex type CT_RelSizeAnchor (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children from: CT_Marker, to: CT_Marker.
pub(all) struct CT_RelSizeAnchor {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AbsSizeAnchor (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children from: CT_Marker, ext: a:CT_PositiveSize2D.
pub(all) struct CT_AbsSizeAnchor {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Drawing (§21.3, dml-chartDrawing.xsd): attributes no local attributes; children no local child elements.
pub(all) struct CT_Drawing {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD top-level element chartSpace (§21.2, dml-chart.xsd) with type CT_ChartSpace.
pub(all) struct ChartSpace {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD top-level element userShapes (§21.2, dml-chart.xsd) with type cdr:CT_Drawing.
pub(all) struct UserShapes {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD top-level element chart (§21.2, dml-chart.xsd) with type CT_RelId.
pub(all) struct Chart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Return the schema bundle names implemented by this DrawingML chart package.
pub fn chart_schema_bundles() -> Array[String] {
  let bundles = []
  bundles.push("dml-chart.xsd")
  bundles.push("dml-chartDrawing.xsd")
  bundles
}
