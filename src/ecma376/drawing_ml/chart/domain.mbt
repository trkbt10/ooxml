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
/// Decode an xsd:int attribute body (signed 32-bit, -2_147_483_648..2_147_483_647).
fn parse_xsd_int(path : String, value : String) -> Int raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-chart.xsd",
      path~,
      reason="invalid xsd:int: empty",
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
  if i >= value.length() {
    raise SchemaViolation(
      schema="dml-chart.xsd",
      path~,
      reason="invalid xsd:int: " + value,
    )
  }
  let mut n : Int64 = 0L
  while i < value.length() {
    let ch = value[i:i + 1]
    if ch < "0" || ch > "9" {
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path~,
        reason="invalid xsd:int: " + value,
      )
    }
    let d = (ch[0].to_int() - "0"[0].to_int()).to_int64()
    n = n * 10L + d
    i = i + 1
  }
  let signed = if negative { -n } else { n }
  if signed < -2147483648L || signed > 2147483647L {
    raise SchemaViolation(
      schema="dml-chart.xsd",
      path~,
      reason="xsd:int out of range: " + value,
    )
  }
  signed.to_int()
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

// =============================================================================
// chunk2 typed CT_* wrappers (37 types) — dml-chart.xsd lines 316..730
//
// Every attribute and child element documented in the XSD has a typed field
// below, in declaration order. minOccurs/maxOccurs map to Option / Array /
// non-Option as per the spec. Children whose XSD type is `a:CT_*`
// (drawingml/main) or whose CT_* wrapper belongs to chunk3/4 are preserved
// as raw `@xml.Element` until those chunks land.
// =============================================================================

///|
/// XSD complex type CT_SizeRepresents — Part 1 §21.2.2.193 (dml-chart.xsd)
/// sizeRepresents. Optional ST_SizeRepresents enum (schema default `area`).
pub(all) struct CT_SizeRepresents {
  /// @val (ST_SizeRepresents) — optional, schema default `area`.
  val : ST_SizeRepresents?
} derive(Eq, Debug)

///|
pub fn CT_SizeRepresents::new(
  element : @xml.Element,
) -> CT_SizeRepresents raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_SizeRepresents::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_FirstSliceAng — Part 1 §21.2.2.68 (dml-chart.xsd)
/// firstSliceAng. Optional ST_FirstSliceAng degrees (schema default `0`).
pub(all) struct CT_FirstSliceAng {
  /// @val (ST_FirstSliceAng) — optional, schema default `0`.
  val : ST_FirstSliceAng?
} derive(Eq, Debug)

///|
pub fn CT_FirstSliceAng::new(
  element : @xml.Element,
) -> CT_FirstSliceAng raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_FirstSliceAng::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_HoleSize — Part 1 §21.2.2.82 (dml-chart.xsd) holeSize.
/// Optional ST_HoleSize percent (schema default `10%`).
pub(all) struct CT_HoleSize {
  /// @val (ST_HoleSize) — optional, schema default `10%`.
  val : ST_HoleSize?
} derive(Eq, Debug)

///|
pub fn CT_HoleSize::new(
  element : @xml.Element,
) -> CT_HoleSize raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_HoleSize::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_SplitType — Part 1 §21.2.2.197 (dml-chart.xsd)
/// splitType. Optional ST_SplitType (schema default `auto`).
pub(all) struct CT_SplitType {
  /// @val (ST_SplitType) — optional, schema default `auto`.
  val : ST_SplitType?
} derive(Eq, Debug)

///|
pub fn CT_SplitType::new(
  element : @xml.Element,
) -> CT_SplitType raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_SplitType::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_CustSplit — Part 1 §21.2.2.40 (dml-chart.xsd)
/// custSplit. Sequence of zero or more `secondPiePt` (CT_UnsignedInt) children.
pub(all) struct CT_CustSplit {
  /// <secondPiePt> (CT_UnsignedInt) — zero or more.
  second_pie_pt : Array[CT_UnsignedInt]
} derive(Eq, Debug)

///|
pub fn CT_CustSplit::new(
  element : @xml.Element,
) -> CT_CustSplit raise SchemaViolation {
  let second_pie_pt = []
  for child in children_named(element, "secondPiePt") {
    second_pie_pt.push(CT_UnsignedInt::new(child))
  }
  { second_pie_pt, }
}

///|
/// XSD complex type CT_SecondPieSize — Part 1 §21.2.2.181 (dml-chart.xsd)
/// secondPieSize. Optional ST_SecondPieSize percent (schema default `75%`).
pub(all) struct CT_SecondPieSize {
  /// @val (ST_SecondPieSize) — optional, schema default `75%`.
  val : ST_SecondPieSize?
} derive(Eq, Debug)

///|
pub fn CT_SecondPieSize::new(
  element : @xml.Element,
) -> CT_SecondPieSize raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_SecondPieSize::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_NumFmt — Part 1 §21.2.2.121 (dml-chart.xsd) numFmt.
/// Required `formatCode` string plus optional `sourceLinked` boolean.
pub(all) struct CT_NumFmt {
  /// @formatCode (s:ST_Xstring) — required.
  format_code : String
  /// @sourceLinked (xsd:boolean) — optional, no schema default.
  source_linked : Bool?
} derive(Eq, Debug)

///|
pub fn CT_NumFmt::new(
  element : @xml.Element,
) -> CT_NumFmt raise SchemaViolation {
  let format_code = match attr_value(element, "formatCode") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_NumFmt/@formatCode",
        reason="required attribute missing",
      )
  }
  let source_linked = match attr_value(element, "sourceLinked") {
    Some(text) => Some(parse_xsd_boolean("CT_NumFmt/@sourceLinked", text))
    None => None
  }
  { format_code, source_linked }
}

///|
/// XSD complex type CT_LblAlgn — Part 1 §21.2.2.94 (dml-chart.xsd) lblAlgn.
/// Required ST_LblAlgn enumeration.
pub(all) struct CT_LblAlgn {
  /// @val (ST_LblAlgn) — required.
  val : ST_LblAlgn
} derive(Eq, Debug)

///|
pub fn CT_LblAlgn::new(
  element : @xml.Element,
) -> CT_LblAlgn raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_LblAlgn/@val",
        reason="required attribute missing",
      )
  }
  { val: ST_LblAlgn::parse(raw) }
}

///|
/// XSD complex type CT_DLblPos — Part 1 §21.2.2.51 (dml-chart.xsd) dLblPos.
/// Required ST_DLblPos enumeration.
pub(all) struct CT_DLblPos {
  /// @val (ST_DLblPos) — required.
  val : ST_DLblPos
} derive(Eq, Debug)

///|
pub fn CT_DLblPos::new(
  element : @xml.Element,
) -> CT_DLblPos raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_DLblPos/@val",
        reason="required attribute missing",
      )
  }
  { val: ST_DLblPos::parse(raw) }
}

///|
/// XSD complex type CT_DLbl — Part 1 §21.2.2.47 (dml-chart.xsd) dLbl.
/// Required `idx`, then a choice between `delete` and the inlined
/// `Group_DLbl + EG_DLblShared` payload (layout, tx, numFmt, spPr, txPr,
/// dLblPos, showLegendKey, showVal, showCatName, showSerName, showPercent,
/// showBubbleSize, separator), then optional `extLst`.
pub(all) struct CT_DLbl {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <delete> (CT_Boolean) — set when the data label is deleted; mutually
  /// exclusive with the Group_DLbl payload.
  delete : CT_Boolean?
  /// <layout> (CT_Layout) — Group_DLbl member, optional.
  layout : CT_Layout?
  /// <tx> (CT_Tx) — Group_DLbl member, optional.
  tx : CT_Tx?
  /// <numFmt> (CT_NumFmt) — EG_DLblShared member, optional.
  num_fmt : CT_NumFmt?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <dLblPos> (CT_DLblPos) — EG_DLblShared member, optional.
  d_lbl_pos : CT_DLblPos?
  /// <showLegendKey> (CT_Boolean) — optional.
  show_legend_key : CT_Boolean?
  /// <showVal> (CT_Boolean) — optional.
  show_val : CT_Boolean?
  /// <showCatName> (CT_Boolean) — optional.
  show_cat_name : CT_Boolean?
  /// <showSerName> (CT_Boolean) — optional.
  show_ser_name : CT_Boolean?
  /// <showPercent> (CT_Boolean) — optional.
  show_percent : CT_Boolean?
  /// <showBubbleSize> (CT_Boolean) — optional.
  show_bubble_size : CT_Boolean?
  /// <separator> (xsd:string) — optional.
  separator : String?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_DLbl::new(element : @xml.Element) -> CT_DLbl raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_DLbl/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let delete = match first_child_named(element, "delete") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let layout = match first_child_named(element, "layout") {
    Some(child) => Some(CT_Layout::new(child))
    None => None
  }
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_Tx::new(child))
    None => None
  }
  let num_fmt = match first_child_named(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let d_lbl_pos = match first_child_named(element, "dLblPos") {
    Some(child) => Some(CT_DLblPos::new(child))
    None => None
  }
  let show_legend_key = match first_child_named(element, "showLegendKey") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_val = match first_child_named(element, "showVal") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_cat_name = match first_child_named(element, "showCatName") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_ser_name = match first_child_named(element, "showSerName") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_percent = match first_child_named(element, "showPercent") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_bubble_size = match first_child_named(element, "showBubbleSize") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let separator = first_child_named(element, "separator").map(element_text)
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    idx,
    delete,
    layout,
    tx,
    num_fmt,
    sp_pr,
    tx_pr,
    d_lbl_pos,
    show_legend_key,
    show_val,
    show_cat_name,
    show_ser_name,
    show_percent,
    show_bubble_size,
    separator,
    ext_lst,
  }
}

///|
/// XSD complex type CT_DLbls — Part 1 §21.2.2.49 (dml-chart.xsd) dLbls.
/// Sequence of zero-or-more `dLbl`, then a choice between `delete` and the
/// inlined `Group_DLbls + EG_DLblShared` payload, then optional `extLst`.
pub(all) struct CT_DLbls {
  /// <dLbl> (CT_DLbl) — zero or more.
  d_lbl : Array[CT_DLbl]
  /// <delete> (CT_Boolean) — set when entire label set is deleted; mutually
  /// exclusive with the Group_DLbls payload.
  delete : CT_Boolean?
  /// <numFmt> (CT_NumFmt) — EG_DLblShared member, optional.
  num_fmt : CT_NumFmt?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <dLblPos> (CT_DLblPos) — EG_DLblShared member, optional.
  d_lbl_pos : CT_DLblPos?
  /// <showLegendKey> (CT_Boolean) — optional.
  show_legend_key : CT_Boolean?
  /// <showVal> (CT_Boolean) — optional.
  show_val : CT_Boolean?
  /// <showCatName> (CT_Boolean) — optional.
  show_cat_name : CT_Boolean?
  /// <showSerName> (CT_Boolean) — optional.
  show_ser_name : CT_Boolean?
  /// <showPercent> (CT_Boolean) — optional.
  show_percent : CT_Boolean?
  /// <showBubbleSize> (CT_Boolean) — optional.
  show_bubble_size : CT_Boolean?
  /// <separator> (xsd:string) — optional.
  separator : String?
  /// <showLeaderLines> (CT_Boolean) — Group_DLbls member, optional.
  show_leader_lines : CT_Boolean?
  /// <leaderLines> (CT_ChartLines) — Group_DLbls member, optional.
  leader_lines : CT_ChartLines?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_DLbls::new(element : @xml.Element) -> CT_DLbls raise SchemaViolation {
  let d_lbl = []
  for child in children_named(element, "dLbl") {
    d_lbl.push(CT_DLbl::new(child))
  }
  let delete = match first_child_named(element, "delete") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let num_fmt = match first_child_named(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let d_lbl_pos = match first_child_named(element, "dLblPos") {
    Some(child) => Some(CT_DLblPos::new(child))
    None => None
  }
  let show_legend_key = match first_child_named(element, "showLegendKey") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_val = match first_child_named(element, "showVal") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_cat_name = match first_child_named(element, "showCatName") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_ser_name = match first_child_named(element, "showSerName") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_percent = match first_child_named(element, "showPercent") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let show_bubble_size = match first_child_named(element, "showBubbleSize") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let separator = first_child_named(element, "separator").map(element_text)
  let show_leader_lines = match first_child_named(element, "showLeaderLines") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let leader_lines = match first_child_named(element, "leaderLines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    d_lbl,
    delete,
    num_fmt,
    sp_pr,
    tx_pr,
    d_lbl_pos,
    show_legend_key,
    show_val,
    show_cat_name,
    show_ser_name,
    show_percent,
    show_bubble_size,
    separator,
    show_leader_lines,
    leader_lines,
    ext_lst,
  }
}

///|
/// XSD complex type CT_MarkerStyle — Part 1 §21.2.2.110 (dml-chart.xsd)
/// symbol. Required ST_MarkerStyle enumeration.
pub(all) struct CT_MarkerStyle {
  /// @val (ST_MarkerStyle) — required.
  val : ST_MarkerStyle
} derive(Eq, Debug)

///|
pub fn CT_MarkerStyle::new(
  element : @xml.Element,
) -> CT_MarkerStyle raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_MarkerStyle/@val",
        reason="required attribute missing",
      )
  }
  { val: ST_MarkerStyle::parse(raw) }
}

///|
/// XSD complex type CT_MarkerSize — Part 1 §21.2.2.109 (dml-chart.xsd) size.
/// Optional ST_MarkerSize (schema default `5`).
pub(all) struct CT_MarkerSize {
  /// @val (ST_MarkerSize) — optional, schema default `5`.
  val : ST_MarkerSize?
} derive(Eq, Debug)

///|
pub fn CT_MarkerSize::new(
  element : @xml.Element,
) -> CT_MarkerSize raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_MarkerSize::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_Marker — Part 1 §21.2.2.106 (dml-chart.xsd) marker.
/// Sequence of optional `symbol`, `size`, `spPr`, `extLst`.
pub(all) struct CT_Marker {
  /// <symbol> (CT_MarkerStyle) — optional.
  symbol : CT_MarkerStyle?
  /// <size> (CT_MarkerSize) — optional.
  size : CT_MarkerSize?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Marker::new(
  element : @xml.Element,
) -> CT_Marker raise SchemaViolation {
  let symbol = match first_child_named(element, "symbol") {
    Some(child) => Some(CT_MarkerStyle::new(child))
    None => None
  }
  let size = match first_child_named(element, "size") {
    Some(child) => Some(CT_MarkerSize::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { symbol, size, sp_pr, ext_lst }
}

///|
/// XSD complex type CT_DPt — Part 1 §21.2.2.52 (dml-chart.xsd) dPt.
/// Sequence: required `idx` then optional `invertIfNegative`, `marker`,
/// `bubble3D`, `explosion`, `spPr`, `pictureOptions`, `extLst`. The
/// `pictureOptions` child is a chunk3 wrapper preserved as raw element.
pub(all) struct CT_DPt {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <invertIfNegative> (CT_Boolean) — optional.
  invert_if_negative : CT_Boolean?
  /// <marker> (CT_Marker) — optional.
  marker : CT_Marker?
  /// <bubble3D> (CT_Boolean) — optional.
  bubble_3d : CT_Boolean?
  /// <explosion> (CT_UnsignedInt) — optional.
  explosion : CT_UnsignedInt?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <pictureOptions> (CT_PictureOptions, chunk3) preserved as raw element.
  picture_options : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_DPt::new(element : @xml.Element) -> CT_DPt raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_DPt/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let invert_if_negative = match
    first_child_named(element, "invertIfNegative") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let marker = match first_child_named(element, "marker") {
    Some(child) => Some(CT_Marker::new(child))
    None => None
  }
  let bubble_3d = match first_child_named(element, "bubble3D") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let explosion = match first_child_named(element, "explosion") {
    Some(child) => Some(CT_UnsignedInt::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let picture_options = first_child_named(element, "pictureOptions")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    idx,
    invert_if_negative,
    marker,
    bubble_3d,
    explosion,
    sp_pr,
    picture_options,
    ext_lst,
  }
}

///|
/// XSD complex type CT_TrendlineType — Part 1 §21.2.2.213 (dml-chart.xsd)
/// trendlineType. Optional ST_TrendlineType (schema default `linear`).
pub(all) struct CT_TrendlineType {
  /// @val (ST_TrendlineType) — optional, schema default `linear`.
  val : ST_TrendlineType?
} derive(Eq, Debug)

///|
pub fn CT_TrendlineType::new(
  element : @xml.Element,
) -> CT_TrendlineType raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_TrendlineType::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_Order — Part 1 §21.2.2.130 (dml-chart.xsd) order
/// (trendline order). Optional ST_Order (schema default `2`).
pub(all) struct CT_Order {
  /// @val (ST_Order) — optional, schema default `2`.
  val : ST_Order?
} derive(Eq, Debug)

///|
pub fn CT_Order::new(element : @xml.Element) -> CT_Order raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_Order::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_Period — Part 1 §21.2.2.135 (dml-chart.xsd) period.
/// Optional ST_Period (schema default `2`).
pub(all) struct CT_Period {
  /// @val (ST_Period) — optional, schema default `2`.
  val : ST_Period?
} derive(Eq, Debug)

///|
pub fn CT_Period::new(
  element : @xml.Element,
) -> CT_Period raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_Period::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_TrendlineLbl — Part 1 §21.2.2.212 (dml-chart.xsd)
/// trendlineLbl. Sequence of optional layout, tx, numFmt, spPr, txPr, extLst.
pub(all) struct CT_TrendlineLbl {
  /// <layout> (CT_Layout) — optional.
  layout : CT_Layout?
  /// <tx> (CT_Tx) — optional.
  tx : CT_Tx?
  /// <numFmt> (CT_NumFmt) — optional.
  num_fmt : CT_NumFmt?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_TrendlineLbl::new(
  element : @xml.Element,
) -> CT_TrendlineLbl raise SchemaViolation {
  let layout = match first_child_named(element, "layout") {
    Some(child) => Some(CT_Layout::new(child))
    None => None
  }
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_Tx::new(child))
    None => None
  }
  let num_fmt = match first_child_named(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { layout, tx, num_fmt, sp_pr, tx_pr, ext_lst }
}

///|
/// XSD complex type CT_Trendline — Part 1 §21.2.2.211 (dml-chart.xsd)
/// trendline. Sequence: optional name, spPr, then required trendlineType,
/// then optional order, period, forward, backward, intercept, dispRSqr,
/// dispEq, trendlineLbl, extLst.
pub(all) struct CT_Trendline {
  /// <name> (xsd:string) — optional.
  name : String?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <trendlineType> (CT_TrendlineType) — required.
  trendline_type : CT_TrendlineType
  /// <order> (CT_Order) — optional.
  order : CT_Order?
  /// <period> (CT_Period) — optional.
  period : CT_Period?
  /// <forward> (CT_Double) — optional.
  forward : CT_Double?
  /// <backward> (CT_Double) — optional.
  backward : CT_Double?
  /// <intercept> (CT_Double) — optional.
  intercept : CT_Double?
  /// <dispRSqr> (CT_Boolean) — optional.
  disp_r_sqr : CT_Boolean?
  /// <dispEq> (CT_Boolean) — optional.
  disp_eq : CT_Boolean?
  /// <trendlineLbl> (CT_TrendlineLbl) — optional.
  trendline_lbl : CT_TrendlineLbl?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Trendline::new(
  element : @xml.Element,
) -> CT_Trendline raise SchemaViolation {
  let name = first_child_named(element, "name").map(element_text)
  let sp_pr = first_child_named(element, "spPr")
  let trendline_type_element = match
    first_child_named(element, "trendlineType") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_Trendline/trendlineType",
        reason="required child missing",
      )
  }
  let trendline_type = CT_TrendlineType::new(trendline_type_element)
  let order = match first_child_named(element, "order") {
    Some(child) => Some(CT_Order::new(child))
    None => None
  }
  let period = match first_child_named(element, "period") {
    Some(child) => Some(CT_Period::new(child))
    None => None
  }
  let forward = match first_child_named(element, "forward") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let backward = match first_child_named(element, "backward") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let intercept = match first_child_named(element, "intercept") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let disp_r_sqr = match first_child_named(element, "dispRSqr") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let disp_eq = match first_child_named(element, "dispEq") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let trendline_lbl = match first_child_named(element, "trendlineLbl") {
    Some(child) => Some(CT_TrendlineLbl::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    name,
    sp_pr,
    trendline_type,
    order,
    period,
    forward,
    backward,
    intercept,
    disp_r_sqr,
    disp_eq,
    trendline_lbl,
    ext_lst,
  }
}

///|
/// XSD complex type CT_ErrDir — Part 1 §21.2.2.65 (dml-chart.xsd) errDir.
/// Required ST_ErrDir enumeration.
pub(all) struct CT_ErrDir {
  /// @val (ST_ErrDir) — required.
  val : ST_ErrDir
} derive(Eq, Debug)

///|
pub fn CT_ErrDir::new(
  element : @xml.Element,
) -> CT_ErrDir raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ErrDir/@val",
        reason="required attribute missing",
      )
  }
  { val: ST_ErrDir::parse(raw) }
}

///|
/// XSD complex type CT_ErrBarType — Part 1 §21.2.2.63 (dml-chart.xsd)
/// errBarType. Optional ST_ErrBarType (schema default `both`).
pub(all) struct CT_ErrBarType {
  /// @val (ST_ErrBarType) — optional, schema default `both`.
  val : ST_ErrBarType?
} derive(Eq, Debug)

///|
pub fn CT_ErrBarType::new(
  element : @xml.Element,
) -> CT_ErrBarType raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_ErrBarType::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_ErrValType — Part 1 §21.2.2.66 (dml-chart.xsd)
/// errValType. Optional ST_ErrValType (schema default `fixedVal`).
pub(all) struct CT_ErrValType {
  /// @val (ST_ErrValType) — optional, schema default `fixedVal`.
  val : ST_ErrValType?
} derive(Eq, Debug)

///|
pub fn CT_ErrValType::new(
  element : @xml.Element,
) -> CT_ErrValType raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_ErrValType::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_ErrBars — Part 1 §21.2.2.61 (dml-chart.xsd) errBars.
/// Sequence: optional errDir, required errBarType, required errValType,
/// optional noEndCap, plus, minus, val, spPr, extLst.
pub(all) struct CT_ErrBars {
  /// <errDir> (CT_ErrDir) — optional.
  err_dir : CT_ErrDir?
  /// <errBarType> (CT_ErrBarType) — required.
  err_bar_type : CT_ErrBarType
  /// <errValType> (CT_ErrValType) — required.
  err_val_type : CT_ErrValType
  /// <noEndCap> (CT_Boolean) — optional.
  no_end_cap : CT_Boolean?
  /// <plus> (CT_NumDataSource) — optional.
  plus : CT_NumDataSource?
  /// <minus> (CT_NumDataSource) — optional.
  minus : CT_NumDataSource?
  /// <val> (CT_Double) — optional.
  val : CT_Double?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_ErrBars::new(
  element : @xml.Element,
) -> CT_ErrBars raise SchemaViolation {
  let err_dir = match first_child_named(element, "errDir") {
    Some(child) => Some(CT_ErrDir::new(child))
    None => None
  }
  let err_bar_type_element = match first_child_named(element, "errBarType") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ErrBars/errBarType",
        reason="required child missing",
      )
  }
  let err_bar_type = CT_ErrBarType::new(err_bar_type_element)
  let err_val_type_element = match first_child_named(element, "errValType") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ErrBars/errValType",
        reason="required child missing",
      )
  }
  let err_val_type = CT_ErrValType::new(err_val_type_element)
  let no_end_cap = match first_child_named(element, "noEndCap") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let plus = match first_child_named(element, "plus") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let minus = match first_child_named(element, "minus") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let val = match first_child_named(element, "val") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    err_dir,
    err_bar_type,
    err_val_type,
    no_end_cap,
    plus,
    minus,
    val,
    sp_pr,
    ext_lst,
  }
}

///|
/// XSD complex type CT_UpDownBar — Part 1 §21.2.2.218 (dml-chart.xsd) upBars
/// / §21.2.2.55 downBars. Sequence with optional `spPr`.
pub(all) struct CT_UpDownBar {
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_UpDownBar::new(element : @xml.Element) -> CT_UpDownBar {
  let sp_pr = first_child_named(element, "spPr")
  { sp_pr, }
}

///|
/// XSD complex type CT_UpDownBars — Part 1 §21.2.2.219 (dml-chart.xsd)
/// upDownBars. Sequence of optional `gapWidth`, `upBars`, `downBars`, `extLst`.
pub(all) struct CT_UpDownBars {
  /// <gapWidth> (CT_GapAmount) — optional.
  gap_width : CT_GapAmount?
  /// <upBars> (CT_UpDownBar) — optional.
  up_bars : CT_UpDownBar?
  /// <downBars> (CT_UpDownBar) — optional.
  down_bars : CT_UpDownBar?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_UpDownBars::new(
  element : @xml.Element,
) -> CT_UpDownBars raise SchemaViolation {
  let gap_width = match first_child_named(element, "gapWidth") {
    Some(child) => Some(CT_GapAmount::new(child))
    None => None
  }
  let up_bars = first_child_named(element, "upBars").map(CT_UpDownBar::new)
  let down_bars = first_child_named(element, "downBars").map(CT_UpDownBar::new)
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { gap_width, up_bars, down_bars, ext_lst }
}

///|
/// XSD complex type CT_LineSer — Part 1 §21.2.2.97 (dml-chart.xsd) ser
/// (line series). Sequence: required `idx`, `order`, optional `tx`, `spPr`
/// (from EG_SerShared), then optional marker, dPt*, dLbls, trendline*,
/// errBars, cat, val, smooth, extLst.
pub(all) struct CT_LineSer {
  /// <idx> (CT_UnsignedInt) — required (EG_SerShared).
  idx : CT_UnsignedInt
  /// <order> (CT_UnsignedInt) — required (EG_SerShared).
  order : CT_UnsignedInt
  /// <tx> (CT_SerTx) — optional (EG_SerShared).
  tx : CT_SerTx?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <marker> (CT_Marker) — optional.
  marker : CT_Marker?
  /// <dPt> (CT_DPt) — zero or more.
  d_pt : Array[CT_DPt]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <trendline> (CT_Trendline) — zero or more.
  trendline : Array[CT_Trendline]
  /// <errBars> (CT_ErrBars) — optional.
  err_bars : CT_ErrBars?
  /// <cat> (CT_AxDataSource) — optional.
  cat : CT_AxDataSource?
  /// <val> (CT_NumDataSource) — optional.
  val : CT_NumDataSource?
  /// <smooth> (CT_Boolean) — optional.
  smooth : CT_Boolean?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_LineSer::new(
  element : @xml.Element,
) -> CT_LineSer raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_LineSer/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let order_element = match first_child_named(element, "order") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_LineSer/order",
        reason="required child missing",
      )
  }
  let order = CT_UnsignedInt::new(order_element)
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_SerTx::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let marker = match first_child_named(element, "marker") {
    Some(child) => Some(CT_Marker::new(child))
    None => None
  }
  let d_pt = []
  for child in children_named(element, "dPt") {
    d_pt.push(CT_DPt::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let trendline = []
  for child in children_named(element, "trendline") {
    trendline.push(CT_Trendline::new(child))
  }
  let err_bars = match first_child_named(element, "errBars") {
    Some(child) => Some(CT_ErrBars::new(child))
    None => None
  }
  let cat = match first_child_named(element, "cat") {
    Some(child) => Some(CT_AxDataSource::new(child))
    None => None
  }
  let val = match first_child_named(element, "val") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let smooth = match first_child_named(element, "smooth") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    idx,
    order,
    tx,
    sp_pr,
    marker,
    d_pt,
    d_lbls,
    trendline,
    err_bars,
    cat,
    val,
    smooth,
    ext_lst,
  }
}

///|
/// XSD complex type CT_ScatterSer — Part 1 §21.2.2.176 (dml-chart.xsd) ser
/// (scatter series). EG_SerShared followed by marker, dPt*, dLbls,
/// trendline*, errBars (0..2), xVal, yVal, smooth, extLst.
pub(all) struct CT_ScatterSer {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <order> (CT_UnsignedInt) — required.
  order : CT_UnsignedInt
  /// <tx> (CT_SerTx) — optional.
  tx : CT_SerTx?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <marker> (CT_Marker) — optional.
  marker : CT_Marker?
  /// <dPt> (CT_DPt) — zero or more.
  d_pt : Array[CT_DPt]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <trendline> (CT_Trendline) — zero or more.
  trendline : Array[CT_Trendline]
  /// <errBars> (CT_ErrBars) — zero, one, or two occurrences.
  err_bars : Array[CT_ErrBars]
  /// <xVal> (CT_AxDataSource) — optional.
  x_val : CT_AxDataSource?
  /// <yVal> (CT_NumDataSource) — optional.
  y_val : CT_NumDataSource?
  /// <smooth> (CT_Boolean) — optional.
  smooth : CT_Boolean?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_ScatterSer::new(
  element : @xml.Element,
) -> CT_ScatterSer raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ScatterSer/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let order_element = match first_child_named(element, "order") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ScatterSer/order",
        reason="required child missing",
      )
  }
  let order = CT_UnsignedInt::new(order_element)
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_SerTx::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let marker = match first_child_named(element, "marker") {
    Some(child) => Some(CT_Marker::new(child))
    None => None
  }
  let d_pt = []
  for child in children_named(element, "dPt") {
    d_pt.push(CT_DPt::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let trendline = []
  for child in children_named(element, "trendline") {
    trendline.push(CT_Trendline::new(child))
  }
  let err_bars = []
  for child in children_named(element, "errBars") {
    err_bars.push(CT_ErrBars::new(child))
  }
  let x_val = match first_child_named(element, "xVal") {
    Some(child) => Some(CT_AxDataSource::new(child))
    None => None
  }
  let y_val = match first_child_named(element, "yVal") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let smooth = match first_child_named(element, "smooth") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    idx,
    order,
    tx,
    sp_pr,
    marker,
    d_pt,
    d_lbls,
    trendline,
    err_bars,
    x_val,
    y_val,
    smooth,
    ext_lst,
  }
}

///|
/// XSD complex type CT_RadarSer — Part 1 §21.2.2.169 (dml-chart.xsd) ser
/// (radar series). EG_SerShared followed by marker, dPt*, dLbls, cat, val,
/// extLst.
pub(all) struct CT_RadarSer {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <order> (CT_UnsignedInt) — required.
  order : CT_UnsignedInt
  /// <tx> (CT_SerTx) — optional.
  tx : CT_SerTx?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <marker> (CT_Marker) — optional.
  marker : CT_Marker?
  /// <dPt> (CT_DPt) — zero or more.
  d_pt : Array[CT_DPt]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <cat> (CT_AxDataSource) — optional.
  cat : CT_AxDataSource?
  /// <val> (CT_NumDataSource) — optional.
  val : CT_NumDataSource?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_RadarSer::new(
  element : @xml.Element,
) -> CT_RadarSer raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_RadarSer/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let order_element = match first_child_named(element, "order") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_RadarSer/order",
        reason="required child missing",
      )
  }
  let order = CT_UnsignedInt::new(order_element)
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_SerTx::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let marker = match first_child_named(element, "marker") {
    Some(child) => Some(CT_Marker::new(child))
    None => None
  }
  let d_pt = []
  for child in children_named(element, "dPt") {
    d_pt.push(CT_DPt::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let cat = match first_child_named(element, "cat") {
    Some(child) => Some(CT_AxDataSource::new(child))
    None => None
  }
  let val = match first_child_named(element, "val") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { idx, order, tx, sp_pr, marker, d_pt, d_lbls, cat, val, ext_lst }
}

///|
/// XSD complex type CT_BarSer — Part 1 §21.2.2.18 (dml-chart.xsd) ser
/// (bar series). EG_SerShared followed by invertIfNegative, pictureOptions
/// (chunk3 wrapper, raw), dPt*, dLbls, trendline*, errBars, cat, val, shape
/// (chunk3 wrapper, raw), extLst.
pub(all) struct CT_BarSer {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <order> (CT_UnsignedInt) — required.
  order : CT_UnsignedInt
  /// <tx> (CT_SerTx) — optional.
  tx : CT_SerTx?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <invertIfNegative> (CT_Boolean) — optional.
  invert_if_negative : CT_Boolean?
  /// <pictureOptions> (CT_PictureOptions, chunk3) preserved as raw element.
  picture_options : @xml.Element?
  /// <dPt> (CT_DPt) — zero or more.
  d_pt : Array[CT_DPt]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <trendline> (CT_Trendline) — zero or more.
  trendline : Array[CT_Trendline]
  /// <errBars> (CT_ErrBars) — optional.
  err_bars : CT_ErrBars?
  /// <cat> (CT_AxDataSource) — optional.
  cat : CT_AxDataSource?
  /// <val> (CT_NumDataSource) — optional.
  val : CT_NumDataSource?
  /// <shape> (CT_Shape, chunk3) preserved as raw element.
  shape : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_BarSer::new(
  element : @xml.Element,
) -> CT_BarSer raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_BarSer/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let order_element = match first_child_named(element, "order") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_BarSer/order",
        reason="required child missing",
      )
  }
  let order = CT_UnsignedInt::new(order_element)
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_SerTx::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let invert_if_negative = match
    first_child_named(element, "invertIfNegative") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let picture_options = first_child_named(element, "pictureOptions")
  let d_pt = []
  for child in children_named(element, "dPt") {
    d_pt.push(CT_DPt::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let trendline = []
  for child in children_named(element, "trendline") {
    trendline.push(CT_Trendline::new(child))
  }
  let err_bars = match first_child_named(element, "errBars") {
    Some(child) => Some(CT_ErrBars::new(child))
    None => None
  }
  let cat = match first_child_named(element, "cat") {
    Some(child) => Some(CT_AxDataSource::new(child))
    None => None
  }
  let val = match first_child_named(element, "val") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let shape = first_child_named(element, "shape")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    idx,
    order,
    tx,
    sp_pr,
    invert_if_negative,
    picture_options,
    d_pt,
    d_lbls,
    trendline,
    err_bars,
    cat,
    val,
    shape,
    ext_lst,
  }
}

///|
/// XSD complex type CT_AreaSer — Part 1 §21.2.2.8 (dml-chart.xsd) ser
/// (area series). EG_SerShared followed by pictureOptions (chunk3 wrapper,
/// raw), dPt*, dLbls, trendline*, errBars (0..2), cat, val, extLst.
pub(all) struct CT_AreaSer {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <order> (CT_UnsignedInt) — required.
  order : CT_UnsignedInt
  /// <tx> (CT_SerTx) — optional.
  tx : CT_SerTx?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <pictureOptions> (CT_PictureOptions, chunk3) preserved as raw element.
  picture_options : @xml.Element?
  /// <dPt> (CT_DPt) — zero or more.
  d_pt : Array[CT_DPt]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <trendline> (CT_Trendline) — zero or more.
  trendline : Array[CT_Trendline]
  /// <errBars> (CT_ErrBars) — zero, one, or two occurrences.
  err_bars : Array[CT_ErrBars]
  /// <cat> (CT_AxDataSource) — optional.
  cat : CT_AxDataSource?
  /// <val> (CT_NumDataSource) — optional.
  val : CT_NumDataSource?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_AreaSer::new(
  element : @xml.Element,
) -> CT_AreaSer raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_AreaSer/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let order_element = match first_child_named(element, "order") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_AreaSer/order",
        reason="required child missing",
      )
  }
  let order = CT_UnsignedInt::new(order_element)
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_SerTx::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let picture_options = first_child_named(element, "pictureOptions")
  let d_pt = []
  for child in children_named(element, "dPt") {
    d_pt.push(CT_DPt::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let trendline = []
  for child in children_named(element, "trendline") {
    trendline.push(CT_Trendline::new(child))
  }
  let err_bars = []
  for child in children_named(element, "errBars") {
    err_bars.push(CT_ErrBars::new(child))
  }
  let cat = match first_child_named(element, "cat") {
    Some(child) => Some(CT_AxDataSource::new(child))
    None => None
  }
  let val = match first_child_named(element, "val") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    idx,
    order,
    tx,
    sp_pr,
    picture_options,
    d_pt,
    d_lbls,
    trendline,
    err_bars,
    cat,
    val,
    ext_lst,
  }
}

///|
/// XSD complex type CT_PieSer — Part 1 §21.2.2.143 (dml-chart.xsd) ser
/// (pie series). EG_SerShared followed by explosion, dPt*, dLbls, cat,
/// val, extLst.
pub(all) struct CT_PieSer {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <order> (CT_UnsignedInt) — required.
  order : CT_UnsignedInt
  /// <tx> (CT_SerTx) — optional.
  tx : CT_SerTx?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <explosion> (CT_UnsignedInt) — optional.
  explosion : CT_UnsignedInt?
  /// <dPt> (CT_DPt) — zero or more.
  d_pt : Array[CT_DPt]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <cat> (CT_AxDataSource) — optional.
  cat : CT_AxDataSource?
  /// <val> (CT_NumDataSource) — optional.
  val : CT_NumDataSource?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PieSer::new(
  element : @xml.Element,
) -> CT_PieSer raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PieSer/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let order_element = match first_child_named(element, "order") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PieSer/order",
        reason="required child missing",
      )
  }
  let order = CT_UnsignedInt::new(order_element)
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_SerTx::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let explosion = match first_child_named(element, "explosion") {
    Some(child) => Some(CT_UnsignedInt::new(child))
    None => None
  }
  let d_pt = []
  for child in children_named(element, "dPt") {
    d_pt.push(CT_DPt::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let cat = match first_child_named(element, "cat") {
    Some(child) => Some(CT_AxDataSource::new(child))
    None => None
  }
  let val = match first_child_named(element, "val") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { idx, order, tx, sp_pr, explosion, d_pt, d_lbls, cat, val, ext_lst }
}

///|
/// XSD complex type CT_BubbleSer — Part 1 §21.2.2.26 (dml-chart.xsd) ser
/// (bubble series). EG_SerShared followed by invertIfNegative, dPt*, dLbls,
/// trendline*, errBars (0..2), xVal, yVal, bubbleSize, bubble3D, extLst.
pub(all) struct CT_BubbleSer {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <order> (CT_UnsignedInt) — required.
  order : CT_UnsignedInt
  /// <tx> (CT_SerTx) — optional.
  tx : CT_SerTx?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <invertIfNegative> (CT_Boolean) — optional.
  invert_if_negative : CT_Boolean?
  /// <dPt> (CT_DPt) — zero or more.
  d_pt : Array[CT_DPt]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <trendline> (CT_Trendline) — zero or more.
  trendline : Array[CT_Trendline]
  /// <errBars> (CT_ErrBars) — zero, one, or two occurrences.
  err_bars : Array[CT_ErrBars]
  /// <xVal> (CT_AxDataSource) — optional.
  x_val : CT_AxDataSource?
  /// <yVal> (CT_NumDataSource) — optional.
  y_val : CT_NumDataSource?
  /// <bubbleSize> (CT_NumDataSource) — optional.
  bubble_size : CT_NumDataSource?
  /// <bubble3D> (CT_Boolean) — optional.
  bubble_3d : CT_Boolean?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_BubbleSer::new(
  element : @xml.Element,
) -> CT_BubbleSer raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_BubbleSer/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let order_element = match first_child_named(element, "order") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_BubbleSer/order",
        reason="required child missing",
      )
  }
  let order = CT_UnsignedInt::new(order_element)
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_SerTx::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let invert_if_negative = match
    first_child_named(element, "invertIfNegative") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let d_pt = []
  for child in children_named(element, "dPt") {
    d_pt.push(CT_DPt::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let trendline = []
  for child in children_named(element, "trendline") {
    trendline.push(CT_Trendline::new(child))
  }
  let err_bars = []
  for child in children_named(element, "errBars") {
    err_bars.push(CT_ErrBars::new(child))
  }
  let x_val = match first_child_named(element, "xVal") {
    Some(child) => Some(CT_AxDataSource::new(child))
    None => None
  }
  let y_val = match first_child_named(element, "yVal") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let bubble_size = match first_child_named(element, "bubbleSize") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let bubble_3d = match first_child_named(element, "bubble3D") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    idx,
    order,
    tx,
    sp_pr,
    invert_if_negative,
    d_pt,
    d_lbls,
    trendline,
    err_bars,
    x_val,
    y_val,
    bubble_size,
    bubble_3d,
    ext_lst,
  }
}

///|
/// XSD complex type CT_SurfaceSer — Part 1 §21.2.2.204 (dml-chart.xsd) ser
/// (surface series). EG_SerShared followed by cat, val, extLst.
pub(all) struct CT_SurfaceSer {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <order> (CT_UnsignedInt) — required.
  order : CT_UnsignedInt
  /// <tx> (CT_SerTx) — optional.
  tx : CT_SerTx?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <cat> (CT_AxDataSource) — optional.
  cat : CT_AxDataSource?
  /// <val> (CT_NumDataSource) — optional.
  val : CT_NumDataSource?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SurfaceSer::new(
  element : @xml.Element,
) -> CT_SurfaceSer raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_SurfaceSer/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let order_element = match first_child_named(element, "order") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_SurfaceSer/order",
        reason="required child missing",
      )
  }
  let order = CT_UnsignedInt::new(order_element)
  let tx = match first_child_named(element, "tx") {
    Some(child) => Some(CT_SerTx::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let cat = match first_child_named(element, "cat") {
    Some(child) => Some(CT_AxDataSource::new(child))
    None => None
  }
  let val = match first_child_named(element, "val") {
    Some(child) => Some(CT_NumDataSource::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { idx, order, tx, sp_pr, cat, val, ext_lst }
}

///|
/// XSD complex type CT_Grouping — Part 1 §21.2.2.76 (dml-chart.xsd) grouping.
/// Optional ST_Grouping (schema default `standard`).
pub(all) struct CT_Grouping {
  /// @val (ST_Grouping) — optional, schema default `standard`.
  val : ST_Grouping?
} derive(Eq, Debug)

///|
pub fn CT_Grouping::new(
  element : @xml.Element,
) -> CT_Grouping raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_Grouping::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_Chart — Part 1 §21.2.2.27 (dml-chart.xsd) chart.
/// Sequence: optional title, autoTitleDeleted, pivotFmts, view3D, floor,
/// sideWall, backWall, then required plotArea, then optional legend,
/// plotVisOnly, dispBlanksAs, showDLblsOverMax, extLst.
pub(all) struct CT_Chart {
  /// <title> (CT_Title) — optional.
  title : CT_Title?
  /// <autoTitleDeleted> (CT_Boolean) — optional.
  auto_title_deleted : CT_Boolean?
  /// <pivotFmts> (CT_PivotFmts) — optional.
  pivot_fmts : CT_PivotFmts?
  /// <view3D> (CT_View3D) — optional.
  view_3d : CT_View3D?
  /// <floor> (CT_Surface) — optional.
  floor : CT_Surface?
  /// <sideWall> (CT_Surface) — optional.
  side_wall : CT_Surface?
  /// <backWall> (CT_Surface) — optional.
  back_wall : CT_Surface?
  /// <plotArea> (CT_PlotArea) — required.
  plot_area : CT_PlotArea
  /// <legend> (CT_Legend) — optional.
  legend : CT_Legend?
  /// <plotVisOnly> (CT_Boolean) — optional.
  plot_vis_only : CT_Boolean?
  /// <dispBlanksAs> (CT_DispBlanksAs) — optional.
  disp_blanks_as : CT_DispBlanksAs?
  /// <showDLblsOverMax> (CT_Boolean) — optional.
  show_d_lbls_over_max : CT_Boolean?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
/// XSD complex type CT_ChartLines — Part 1 §21.2.2.31 (dml-chart.xsd)
/// chartLines (majorGridlines / minorGridlines / dropLines / hiLowLines /
/// serLines / leaderLines). Sequence with optional `spPr`.
pub(all) struct CT_ChartLines {
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_ChartLines::new(element : @xml.Element) -> CT_ChartLines {
  let sp_pr = first_child_named(element, "spPr")
  { sp_pr, }
}

///|
/// XSD complex type CT_LineChart — Part 1 §21.2.2.96 (dml-chart.xsd) lineChart.
/// EG_LineChartShared (grouping required, varyColors?, ser*, dLbls?, dropLines?)
/// followed by hiLowLines?, upDownBars?, marker?, smooth?, axId (exactly two),
/// extLst?.
pub(all) struct CT_LineChart {
  /// <grouping> (CT_Grouping) — required (EG_LineChartShared).
  grouping : CT_Grouping
  /// <varyColors> (CT_Boolean) — optional (EG_LineChartShared).
  vary_colors : CT_Boolean?
  /// <ser> (CT_LineSer) — zero or more (EG_LineChartShared).
  ser : Array[CT_LineSer]
  /// <dLbls> (CT_DLbls) — optional (EG_LineChartShared).
  d_lbls : CT_DLbls?
  /// <dropLines> (CT_ChartLines) — optional (EG_LineChartShared).
  drop_lines : CT_ChartLines?
  /// <hiLowLines> (CT_ChartLines) — optional.
  hi_low_lines : CT_ChartLines?
  /// <upDownBars> (CT_UpDownBars) — optional.
  up_down_bars : CT_UpDownBars?
  /// <marker> (CT_Boolean) — optional.
  marker : CT_Boolean?
  /// <smooth> (CT_Boolean) — optional.
  smooth : CT_Boolean?
  /// <axId> (CT_UnsignedInt) — exactly two occurrences (minOccurs=2 maxOccurs=2).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_LineChart::new(
  element : @xml.Element,
) -> CT_LineChart raise SchemaViolation {
  let grouping = match first_child_named(element, "grouping") {
    Some(child) => CT_Grouping::new(child)
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_LineChart/grouping",
        reason="required child missing",
      )
  }
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_LineSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let drop_lines = match first_child_named(element, "dropLines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let hi_low_lines = match first_child_named(element, "hiLowLines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let up_down_bars = match first_child_named(element, "upDownBars") {
    Some(child) => Some(CT_UpDownBars::new(child))
    None => None
  }
  let marker = match first_child_named(element, "marker") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let smooth = match first_child_named(element, "smooth") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    grouping,
    vary_colors,
    ser,
    d_lbls,
    drop_lines,
    hi_low_lines,
    up_down_bars,
    marker,
    smooth,
    ax_id,
    ext_lst,
  }
}

///|
/// XSD complex type CT_Line3DChart — Part 1 §21.2.2.97 (dml-chart.xsd)
/// line3DChart. EG_LineChartShared followed by gapDepth?, axId (exactly
/// three), extLst?.
pub(all) struct CT_Line3DChart {
  /// <grouping> (CT_Grouping) — required (EG_LineChartShared).
  grouping : CT_Grouping
  /// <varyColors> (CT_Boolean) — optional (EG_LineChartShared).
  vary_colors : CT_Boolean?
  /// <ser> (CT_LineSer) — zero or more (EG_LineChartShared).
  ser : Array[CT_LineSer]
  /// <dLbls> (CT_DLbls) — optional (EG_LineChartShared).
  d_lbls : CT_DLbls?
  /// <dropLines> (CT_ChartLines) — optional (EG_LineChartShared).
  drop_lines : CT_ChartLines?
  /// <gapDepth> (CT_GapAmount) — optional.
  gap_depth : CT_GapAmount?
  /// <axId> (CT_UnsignedInt) — exactly three occurrences (minOccurs=3 maxOccurs=3).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Line3DChart::new(
  element : @xml.Element,
) -> CT_Line3DChart raise SchemaViolation {
  let grouping = match first_child_named(element, "grouping") {
    Some(child) => CT_Grouping::new(child)
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_Line3DChart/grouping",
        reason="required child missing",
      )
  }
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_LineSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let drop_lines = match first_child_named(element, "dropLines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let gap_depth = match first_child_named(element, "gapDepth") {
    Some(child) => Some(CT_GapAmount::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { grouping, vary_colors, ser, d_lbls, drop_lines, gap_depth, ax_id, ext_lst }
}

///|
/// XSD complex type CT_StockChart — Part 1 §21.2.2.198 (dml-chart.xsd)
/// stockChart. ser (3..4) followed by dLbls?, dropLines?, hiLowLines?,
/// upDownBars?, axId (exactly two), extLst?.
pub(all) struct CT_StockChart {
  /// <ser> (CT_LineSer) — three or four occurrences (minOccurs=3 maxOccurs=4).
  ser : Array[CT_LineSer]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <dropLines> (CT_ChartLines) — optional.
  drop_lines : CT_ChartLines?
  /// <hiLowLines> (CT_ChartLines) — optional.
  hi_low_lines : CT_ChartLines?
  /// <upDownBars> (CT_UpDownBars) — optional.
  up_down_bars : CT_UpDownBars?
  /// <axId> (CT_UnsignedInt) — exactly two occurrences (minOccurs=2 maxOccurs=2).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_StockChart::new(
  element : @xml.Element,
) -> CT_StockChart raise SchemaViolation {
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_LineSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let drop_lines = match first_child_named(element, "dropLines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let hi_low_lines = match first_child_named(element, "hiLowLines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let up_down_bars = match first_child_named(element, "upDownBars") {
    Some(child) => Some(CT_UpDownBars::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { ser, d_lbls, drop_lines, hi_low_lines, up_down_bars, ax_id, ext_lst }
}

///|
/// XSD complex type CT_ScatterStyle — Part 1 §21.2.2.187 (dml-chart.xsd)
/// scatterStyle. Optional ST_ScatterStyle enum (schema default `marker`).
pub(all) struct CT_ScatterStyle {
  /// @val (ST_ScatterStyle) — optional, schema default `marker`.
  val : ST_ScatterStyle?
} derive(Eq, Debug)

///|
pub fn CT_ScatterStyle::new(
  element : @xml.Element,
) -> CT_ScatterStyle raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_ScatterStyle::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_ScatterChart — Part 1 §21.2.2.186 (dml-chart.xsd)
/// scatterChart. scatterStyle (required) followed by varyColors?, ser*,
/// dLbls?, axId (exactly two), extLst?.
pub(all) struct CT_ScatterChart {
  /// <scatterStyle> (CT_ScatterStyle) — required.
  scatter_style : CT_ScatterStyle
  /// <varyColors> (CT_Boolean) — optional.
  vary_colors : CT_Boolean?
  /// <ser> (CT_ScatterSer) — zero or more.
  ser : Array[CT_ScatterSer]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <axId> (CT_UnsignedInt) — exactly two occurrences (minOccurs=2 maxOccurs=2).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_ScatterChart::new(
  element : @xml.Element,
) -> CT_ScatterChart raise SchemaViolation {
  let scatter_style = match first_child_named(element, "scatterStyle") {
    Some(child) => CT_ScatterStyle::new(child)
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ScatterChart/scatterStyle",
        reason="required child missing",
      )
  }
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_ScatterSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { scatter_style, vary_colors, ser, d_lbls, ax_id, ext_lst }
}

///|
/// XSD complex type CT_RadarStyle — Part 1 §21.2.2.156 (dml-chart.xsd)
/// radarStyle. Optional ST_RadarStyle enum (schema default `standard`).
pub(all) struct CT_RadarStyle {
  /// @val (ST_RadarStyle) — optional, schema default `standard`.
  val : ST_RadarStyle?
} derive(Eq, Debug)

///|
pub fn CT_RadarStyle::new(
  element : @xml.Element,
) -> CT_RadarStyle raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_RadarStyle::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_RadarChart — Part 1 §21.2.2.155 (dml-chart.xsd)
/// radarChart. radarStyle (required) followed by varyColors?, ser*, dLbls?,
/// axId (exactly two), extLst?.
pub(all) struct CT_RadarChart {
  /// <radarStyle> (CT_RadarStyle) — required.
  radar_style : CT_RadarStyle
  /// <varyColors> (CT_Boolean) — optional.
  vary_colors : CT_Boolean?
  /// <ser> (CT_RadarSer) — zero or more.
  ser : Array[CT_RadarSer]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <axId> (CT_UnsignedInt) — exactly two occurrences (minOccurs=2 maxOccurs=2).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_RadarChart::new(
  element : @xml.Element,
) -> CT_RadarChart raise SchemaViolation {
  let radar_style = match first_child_named(element, "radarStyle") {
    Some(child) => CT_RadarStyle::new(child)
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_RadarChart/radarStyle",
        reason="required child missing",
      )
  }
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_RadarSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { radar_style, vary_colors, ser, d_lbls, ax_id, ext_lst }
}

///|
/// XSD complex type CT_BarGrouping — Part 1 §21.2.2.16 (dml-chart.xsd)
/// grouping (bar chart). Optional ST_BarGrouping enum (schema default
/// `clustered`).
pub(all) struct CT_BarGrouping {
  /// @val (ST_BarGrouping) — optional, schema default `clustered`.
  val : ST_BarGrouping?
} derive(Eq, Debug)

///|
pub fn CT_BarGrouping::new(
  element : @xml.Element,
) -> CT_BarGrouping raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_BarGrouping::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_BarDir — Part 1 §21.2.2.15 (dml-chart.xsd) barDir.
/// Optional ST_BarDir enum (schema default `col`).
pub(all) struct CT_BarDir {
  /// @val (ST_BarDir) — optional, schema default `col`.
  val : ST_BarDir?
} derive(Eq, Debug)

///|
pub fn CT_BarDir::new(
  element : @xml.Element,
) -> CT_BarDir raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_BarDir::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_Shape — Part 1 §21.2.2.192 (dml-chart.xsd) shape (3D
/// bar shape). Optional ST_Shape enum (schema default `box`).
pub(all) struct CT_Shape {
  /// @val (ST_Shape) — optional, schema default `box`.
  val : ST_Shape?
} derive(Eq, Debug)

///|
pub fn CT_Shape::new(element : @xml.Element) -> CT_Shape raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_Shape::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_BarChart — Part 1 §21.2.2.18 (dml-chart.xsd) barChart.
/// EG_BarChartShared (barDir required, grouping?, varyColors?, ser*, dLbls?)
/// followed by gapWidth?, overlap?, serLines*, axId (exactly two), extLst?.
pub(all) struct CT_BarChart {
  /// <barDir> (CT_BarDir) — required (EG_BarChartShared).
  bar_dir : CT_BarDir
  /// <grouping> (CT_BarGrouping) — optional (EG_BarChartShared).
  grouping : CT_BarGrouping?
  /// <varyColors> (CT_Boolean) — optional (EG_BarChartShared).
  vary_colors : CT_Boolean?
  /// <ser> (CT_BarSer) — zero or more (EG_BarChartShared).
  ser : Array[CT_BarSer]
  /// <dLbls> (CT_DLbls) — optional (EG_BarChartShared).
  d_lbls : CT_DLbls?
  /// <gapWidth> (CT_GapAmount) — optional.
  gap_width : CT_GapAmount?
  /// <overlap> (CT_Overlap) — optional.
  overlap : CT_Overlap?
  /// <serLines> (CT_ChartLines) — zero or more (maxOccurs=unbounded).
  ser_lines : Array[CT_ChartLines]
  /// <axId> (CT_UnsignedInt) — exactly two occurrences (minOccurs=2 maxOccurs=2).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_BarChart::new(
  element : @xml.Element,
) -> CT_BarChart raise SchemaViolation {
  let bar_dir = match first_child_named(element, "barDir") {
    Some(child) => CT_BarDir::new(child)
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_BarChart/barDir",
        reason="required child missing",
      )
  }
  let grouping = match first_child_named(element, "grouping") {
    Some(child) => Some(CT_BarGrouping::new(child))
    None => None
  }
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_BarSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let gap_width = match first_child_named(element, "gapWidth") {
    Some(child) => Some(CT_GapAmount::new(child))
    None => None
  }
  let overlap = match first_child_named(element, "overlap") {
    Some(child) => Some(CT_Overlap::new(child))
    None => None
  }
  let ser_lines = []
  for child in children_named(element, "serLines") {
    ser_lines.push(CT_ChartLines::new(child))
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    bar_dir,
    grouping,
    vary_colors,
    ser,
    d_lbls,
    gap_width,
    overlap,
    ser_lines,
    ax_id,
    ext_lst,
  }
}

///|
/// XSD complex type CT_Bar3DChart — Part 1 §21.2.2.17 (dml-chart.xsd)
/// bar3DChart. EG_BarChartShared followed by gapWidth?, gapDepth?, shape?,
/// axId (two or three), extLst?.
pub(all) struct CT_Bar3DChart {
  /// <barDir> (CT_BarDir) — required (EG_BarChartShared).
  bar_dir : CT_BarDir
  /// <grouping> (CT_BarGrouping) — optional (EG_BarChartShared).
  grouping : CT_BarGrouping?
  /// <varyColors> (CT_Boolean) — optional (EG_BarChartShared).
  vary_colors : CT_Boolean?
  /// <ser> (CT_BarSer) — zero or more (EG_BarChartShared).
  ser : Array[CT_BarSer]
  /// <dLbls> (CT_DLbls) — optional (EG_BarChartShared).
  d_lbls : CT_DLbls?
  /// <gapWidth> (CT_GapAmount) — optional.
  gap_width : CT_GapAmount?
  /// <gapDepth> (CT_GapAmount) — optional.
  gap_depth : CT_GapAmount?
  /// <shape> (CT_Shape) — optional.
  shape : CT_Shape?
  /// <axId> (CT_UnsignedInt) — two or three occurrences (minOccurs=2 maxOccurs=3).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Bar3DChart::new(
  element : @xml.Element,
) -> CT_Bar3DChart raise SchemaViolation {
  let bar_dir = match first_child_named(element, "barDir") {
    Some(child) => CT_BarDir::new(child)
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_Bar3DChart/barDir",
        reason="required child missing",
      )
  }
  let grouping = match first_child_named(element, "grouping") {
    Some(child) => Some(CT_BarGrouping::new(child))
    None => None
  }
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_BarSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let gap_width = match first_child_named(element, "gapWidth") {
    Some(child) => Some(CT_GapAmount::new(child))
    None => None
  }
  let gap_depth = match first_child_named(element, "gapDepth") {
    Some(child) => Some(CT_GapAmount::new(child))
    None => None
  }
  let shape = match first_child_named(element, "shape") {
    Some(child) => Some(CT_Shape::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    bar_dir,
    grouping,
    vary_colors,
    ser,
    d_lbls,
    gap_width,
    gap_depth,
    shape,
    ax_id,
    ext_lst,
  }
}

///|
/// XSD complex type CT_AreaChart — Part 1 §21.2.2.5 (dml-chart.xsd) areaChart.
/// EG_AreaChartShared (grouping?, varyColors?, ser*, dLbls?, dropLines?)
/// followed by axId (exactly two), extLst?.
pub(all) struct CT_AreaChart {
  /// <grouping> (CT_Grouping) — optional (EG_AreaChartShared).
  grouping : CT_Grouping?
  /// <varyColors> (CT_Boolean) — optional (EG_AreaChartShared).
  vary_colors : CT_Boolean?
  /// <ser> (CT_AreaSer) — zero or more (EG_AreaChartShared).
  ser : Array[CT_AreaSer]
  /// <dLbls> (CT_DLbls) — optional (EG_AreaChartShared).
  d_lbls : CT_DLbls?
  /// <dropLines> (CT_ChartLines) — optional (EG_AreaChartShared).
  drop_lines : CT_ChartLines?
  /// <axId> (CT_UnsignedInt) — exactly two occurrences (minOccurs=2 maxOccurs=2).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_AreaChart::new(
  element : @xml.Element,
) -> CT_AreaChart raise SchemaViolation {
  let grouping = match first_child_named(element, "grouping") {
    Some(child) => Some(CT_Grouping::new(child))
    None => None
  }
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_AreaSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let drop_lines = match first_child_named(element, "dropLines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { grouping, vary_colors, ser, d_lbls, drop_lines, ax_id, ext_lst }
}

///|
/// XSD complex type CT_Area3DChart — Part 1 §21.2.2.4 (dml-chart.xsd)
/// area3DChart. EG_AreaChartShared followed by gapDepth?, axId (two or three),
/// extLst?.
pub(all) struct CT_Area3DChart {
  /// <grouping> (CT_Grouping) — optional (EG_AreaChartShared).
  grouping : CT_Grouping?
  /// <varyColors> (CT_Boolean) — optional (EG_AreaChartShared).
  vary_colors : CT_Boolean?
  /// <ser> (CT_AreaSer) — zero or more (EG_AreaChartShared).
  ser : Array[CT_AreaSer]
  /// <dLbls> (CT_DLbls) — optional (EG_AreaChartShared).
  d_lbls : CT_DLbls?
  /// <dropLines> (CT_ChartLines) — optional (EG_AreaChartShared).
  drop_lines : CT_ChartLines?
  /// <gapDepth> (CT_GapAmount) — optional.
  gap_depth : CT_GapAmount?
  /// <axId> (CT_UnsignedInt) — two or three occurrences (minOccurs=2 maxOccurs=3).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Area3DChart::new(
  element : @xml.Element,
) -> CT_Area3DChart raise SchemaViolation {
  let grouping = match first_child_named(element, "grouping") {
    Some(child) => Some(CT_Grouping::new(child))
    None => None
  }
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_AreaSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let drop_lines = match first_child_named(element, "dropLines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let gap_depth = match first_child_named(element, "gapDepth") {
    Some(child) => Some(CT_GapAmount::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { grouping, vary_colors, ser, d_lbls, drop_lines, gap_depth, ax_id, ext_lst }
}

///|
/// XSD complex type CT_PieChart — Part 1 §21.2.2.141 (dml-chart.xsd) pieChart.
/// EG_PieChartShared (varyColors?, ser*, dLbls?) followed by firstSliceAng?,
/// extLst?.
pub(all) struct CT_PieChart {
  /// <varyColors> (CT_Boolean) — optional (EG_PieChartShared).
  vary_colors : CT_Boolean?
  /// <ser> (CT_PieSer) — zero or more (EG_PieChartShared).
  ser : Array[CT_PieSer]
  /// <dLbls> (CT_DLbls) — optional (EG_PieChartShared).
  d_lbls : CT_DLbls?
  /// <firstSliceAng> (CT_FirstSliceAng) — optional.
  first_slice_ang : CT_FirstSliceAng?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PieChart::new(
  element : @xml.Element,
) -> CT_PieChart raise SchemaViolation {
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_PieSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let first_slice_ang = match first_child_named(element, "firstSliceAng") {
    Some(child) => Some(CT_FirstSliceAng::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { vary_colors, ser, d_lbls, first_slice_ang, ext_lst }
}

///|
/// XSD complex type CT_Pie3DChart — Part 1 §21.2.2.140 (dml-chart.xsd)
/// pie3DChart. EG_PieChartShared followed by extLst?.
pub(all) struct CT_Pie3DChart {
  /// <varyColors> (CT_Boolean) — optional (EG_PieChartShared).
  vary_colors : CT_Boolean?
  /// <ser> (CT_PieSer) — zero or more (EG_PieChartShared).
  ser : Array[CT_PieSer]
  /// <dLbls> (CT_DLbls) — optional (EG_PieChartShared).
  d_lbls : CT_DLbls?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Pie3DChart::new(
  element : @xml.Element,
) -> CT_Pie3DChart raise SchemaViolation {
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_PieSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { vary_colors, ser, d_lbls, ext_lst }
}

///|
/// XSD complex type CT_DoughnutChart — Part 1 §21.2.2.57 (dml-chart.xsd)
/// doughnutChart. EG_PieChartShared followed by firstSliceAng?, holeSize?,
/// extLst?.
pub(all) struct CT_DoughnutChart {
  /// <varyColors> (CT_Boolean) — optional (EG_PieChartShared).
  vary_colors : CT_Boolean?
  /// <ser> (CT_PieSer) — zero or more (EG_PieChartShared).
  ser : Array[CT_PieSer]
  /// <dLbls> (CT_DLbls) — optional (EG_PieChartShared).
  d_lbls : CT_DLbls?
  /// <firstSliceAng> (CT_FirstSliceAng) — optional.
  first_slice_ang : CT_FirstSliceAng?
  /// <holeSize> (CT_HoleSize) — optional.
  hole_size : CT_HoleSize?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_DoughnutChart::new(
  element : @xml.Element,
) -> CT_DoughnutChart raise SchemaViolation {
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_PieSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let first_slice_ang = match first_child_named(element, "firstSliceAng") {
    Some(child) => Some(CT_FirstSliceAng::new(child))
    None => None
  }
  let hole_size = match first_child_named(element, "holeSize") {
    Some(child) => Some(CT_HoleSize::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { vary_colors, ser, d_lbls, first_slice_ang, hole_size, ext_lst }
}

///|
/// XSD complex type CT_OfPieType — Part 1 §21.2.2.127 (dml-chart.xsd)
/// ofPieType. Optional ST_OfPieType enum (schema default `pie`).
pub(all) struct CT_OfPieType {
  /// @val (ST_OfPieType) — optional, schema default `pie`.
  val : ST_OfPieType?
} derive(Eq, Debug)

///|
pub fn CT_OfPieType::new(
  element : @xml.Element,
) -> CT_OfPieType raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_OfPieType::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_OfPieChart — Part 1 §21.2.2.126 (dml-chart.xsd)
/// ofPieChart. ofPieType (required), EG_PieChartShared, gapWidth?,
/// splitType?, splitPos?, custSplit?, secondPieSize?, serLines*, extLst?.
pub(all) struct CT_OfPieChart {
  /// <ofPieType> (CT_OfPieType) — required.
  of_pie_type : CT_OfPieType
  /// <varyColors> (CT_Boolean) — optional (EG_PieChartShared).
  vary_colors : CT_Boolean?
  /// <ser> (CT_PieSer) — zero or more (EG_PieChartShared).
  ser : Array[CT_PieSer]
  /// <dLbls> (CT_DLbls) — optional (EG_PieChartShared).
  d_lbls : CT_DLbls?
  /// <gapWidth> (CT_GapAmount) — optional.
  gap_width : CT_GapAmount?
  /// <splitType> (CT_SplitType) — optional.
  split_type : CT_SplitType?
  /// <splitPos> (CT_Double) — optional.
  split_pos : CT_Double?
  /// <custSplit> (CT_CustSplit) — optional.
  cust_split : CT_CustSplit?
  /// <secondPieSize> (CT_SecondPieSize) — optional.
  second_pie_size : CT_SecondPieSize?
  /// <serLines> (CT_ChartLines) — zero or more (maxOccurs=unbounded).
  ser_lines : Array[CT_ChartLines]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_OfPieChart::new(
  element : @xml.Element,
) -> CT_OfPieChart raise SchemaViolation {
  let of_pie_type = match first_child_named(element, "ofPieType") {
    Some(child) => CT_OfPieType::new(child)
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_OfPieChart/ofPieType",
        reason="required child missing",
      )
  }
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_PieSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let gap_width = match first_child_named(element, "gapWidth") {
    Some(child) => Some(CT_GapAmount::new(child))
    None => None
  }
  let split_type = match first_child_named(element, "splitType") {
    Some(child) => Some(CT_SplitType::new(child))
    None => None
  }
  let split_pos = match first_child_named(element, "splitPos") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let cust_split = match first_child_named(element, "custSplit") {
    Some(child) => Some(CT_CustSplit::new(child))
    None => None
  }
  let second_pie_size = match first_child_named(element, "secondPieSize") {
    Some(child) => Some(CT_SecondPieSize::new(child))
    None => None
  }
  let ser_lines = []
  for child in children_named(element, "serLines") {
    ser_lines.push(CT_ChartLines::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    of_pie_type,
    vary_colors,
    ser,
    d_lbls,
    gap_width,
    split_type,
    split_pos,
    cust_split,
    second_pie_size,
    ser_lines,
    ext_lst,
  }
}

///|
/// XSD complex type CT_BubbleChart — Part 1 §21.2.2.20 (dml-chart.xsd)
/// bubbleChart. varyColors?, ser*, dLbls?, bubble3D?, bubbleScale?,
/// showNegBubbles?, sizeRepresents?, axId (exactly two), extLst?.
pub(all) struct CT_BubbleChart {
  /// <varyColors> (CT_Boolean) — optional.
  vary_colors : CT_Boolean?
  /// <ser> (CT_BubbleSer) — zero or more.
  ser : Array[CT_BubbleSer]
  /// <dLbls> (CT_DLbls) — optional.
  d_lbls : CT_DLbls?
  /// <bubble3D> (CT_Boolean) — optional.
  bubble_3d : CT_Boolean?
  /// <bubbleScale> (CT_BubbleScale) — optional.
  bubble_scale : CT_BubbleScale?
  /// <showNegBubbles> (CT_Boolean) — optional.
  show_neg_bubbles : CT_Boolean?
  /// <sizeRepresents> (CT_SizeRepresents) — optional.
  size_represents : CT_SizeRepresents?
  /// <axId> (CT_UnsignedInt) — exactly two occurrences (minOccurs=2 maxOccurs=2).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_BubbleChart::new(
  element : @xml.Element,
) -> CT_BubbleChart raise SchemaViolation {
  let vary_colors = match first_child_named(element, "varyColors") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_BubbleSer::new(child))
  }
  let d_lbls = match first_child_named(element, "dLbls") {
    Some(child) => Some(CT_DLbls::new(child))
    None => None
  }
  let bubble_3d = match first_child_named(element, "bubble3D") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let bubble_scale = match first_child_named(element, "bubbleScale") {
    Some(child) => Some(CT_BubbleScale::new(child))
    None => None
  }
  let show_neg_bubbles = match first_child_named(element, "showNegBubbles") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let size_represents = match first_child_named(element, "sizeRepresents") {
    Some(child) => Some(CT_SizeRepresents::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    vary_colors,
    ser,
    d_lbls,
    bubble_3d,
    bubble_scale,
    show_neg_bubbles,
    size_represents,
    ax_id,
    ext_lst,
  }
}

///|
/// XSD complex type CT_BandFmt — Part 1 §21.2.2.12 (dml-chart.xsd) bandFmt.
/// Sequence of idx (required CT_UnsignedInt) and spPr (optional
/// a:CT_ShapeProperties preserved as raw element).
pub(all) struct CT_BandFmt {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_BandFmt::new(
  element : @xml.Element,
) -> CT_BandFmt raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_BandFmt/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let sp_pr = first_child_named(element, "spPr")
  { idx, sp_pr }
}

///|
/// XSD complex type CT_BandFmts — Part 1 §21.2.2.13 (dml-chart.xsd) bandFmts.
/// Sequence of zero or more bandFmt (CT_BandFmt) children.
pub(all) struct CT_BandFmts {
  /// <bandFmt> (CT_BandFmt) — zero or more (maxOccurs=unbounded).
  band_fmt : Array[CT_BandFmt]
} derive(Eq, Debug)

///|
pub fn CT_BandFmts::new(
  element : @xml.Element,
) -> CT_BandFmts raise SchemaViolation {
  let band_fmt = []
  for child in children_named(element, "bandFmt") {
    band_fmt.push(CT_BandFmt::new(child))
  }
  { band_fmt, }
}

///|
/// XSD complex type CT_SurfaceChart — Part 1 §21.2.2.203 (dml-chart.xsd)
/// surfaceChart. EG_SurfaceChartShared (wireframe?, ser*, bandFmts?)
/// followed by axId (two or three), extLst?.
pub(all) struct CT_SurfaceChart {
  /// <wireframe> (CT_Boolean) — optional (EG_SurfaceChartShared).
  wireframe : CT_Boolean?
  /// <ser> (CT_SurfaceSer) — zero or more (EG_SurfaceChartShared).
  ser : Array[CT_SurfaceSer]
  /// <bandFmts> (CT_BandFmts) — optional (EG_SurfaceChartShared).
  band_fmts : CT_BandFmts?
  /// <axId> (CT_UnsignedInt) — two or three occurrences (minOccurs=2 maxOccurs=3).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SurfaceChart::new(
  element : @xml.Element,
) -> CT_SurfaceChart raise SchemaViolation {
  let wireframe = match first_child_named(element, "wireframe") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_SurfaceSer::new(child))
  }
  let band_fmts = match first_child_named(element, "bandFmts") {
    Some(child) => Some(CT_BandFmts::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { wireframe, ser, band_fmts, ax_id, ext_lst }
}

///|
/// XSD complex type CT_Surface3DChart — Part 1 §21.2.2.202 (dml-chart.xsd)
/// surface3DChart. EG_SurfaceChartShared followed by axId (exactly three),
/// extLst?.
pub(all) struct CT_Surface3DChart {
  /// <wireframe> (CT_Boolean) — optional (EG_SurfaceChartShared).
  wireframe : CT_Boolean?
  /// <ser> (CT_SurfaceSer) — zero or more (EG_SurfaceChartShared).
  ser : Array[CT_SurfaceSer]
  /// <bandFmts> (CT_BandFmts) — optional (EG_SurfaceChartShared).
  band_fmts : CT_BandFmts?
  /// <axId> (CT_UnsignedInt) — exactly three occurrences (minOccurs=3 maxOccurs=3).
  ax_id : Array[CT_UnsignedInt]
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Surface3DChart::new(
  element : @xml.Element,
) -> CT_Surface3DChart raise SchemaViolation {
  let wireframe = match first_child_named(element, "wireframe") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ser = []
  for child in children_named(element, "ser") {
    ser.push(CT_SurfaceSer::new(child))
  }
  let band_fmts = match first_child_named(element, "bandFmts") {
    Some(child) => Some(CT_BandFmts::new(child))
    None => None
  }
  let ax_id = []
  for child in children_named(element, "axId") {
    ax_id.push(CT_UnsignedInt::new(child))
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { wireframe, ser, band_fmts, ax_id, ext_lst }
}

///|
/// XSD complex type CT_AxPos — Part 1 §21.2.2.10 (dml-chart.xsd) axPos.
/// Required ST_AxPos enum (no schema default).
pub(all) struct CT_AxPos {
  /// @val (ST_AxPos) — required.
  val : ST_AxPos
} derive(Eq, Debug)

///|
pub fn CT_AxPos::new(element : @xml.Element) -> CT_AxPos raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_AxPos/@val",
        reason="required attribute missing",
      )
  }
  let val = ST_AxPos::parse(raw)
  { val, }
}

///|
/// XSD complex type CT_Crosses — Part 1 §21.2.2.36 (dml-chart.xsd) crosses.
/// Required ST_Crosses enum (no schema default).
pub(all) struct CT_Crosses {
  /// @val (ST_Crosses) — required.
  val : ST_Crosses
} derive(Eq, Debug)

///|
pub fn CT_Crosses::new(
  element : @xml.Element,
) -> CT_Crosses raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_Crosses/@val",
        reason="required attribute missing",
      )
  }
  let val = ST_Crosses::parse(raw)
  { val, }
}

///|
/// XSD complex type CT_CrossBetween — Part 1 §21.2.2.35 (dml-chart.xsd)
/// crossBetween. Required ST_CrossBetween enum (no schema default).
pub(all) struct CT_CrossBetween {
  /// @val (ST_CrossBetween) — required.
  val : ST_CrossBetween
} derive(Eq, Debug)

///|
pub fn CT_CrossBetween::new(
  element : @xml.Element,
) -> CT_CrossBetween raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_CrossBetween/@val",
        reason="required attribute missing",
      )
  }
  let val = ST_CrossBetween::parse(raw)
  { val, }
}

///|
/// XSD complex type CT_TickMark — Part 1 §21.2.2.105 / §21.2.2.122
/// (dml-chart.xsd) majorTickMark/minorTickMark. Optional ST_TickMark enum
/// (schema default `cross`).
pub(all) struct CT_TickMark {
  /// @val (ST_TickMark) — optional, schema default `cross`.
  val : ST_TickMark?
} derive(Eq, Debug)

///|
pub fn CT_TickMark::new(
  element : @xml.Element,
) -> CT_TickMark raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_TickMark::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_TickLblPos — Part 1 §21.2.2.211 (dml-chart.xsd)
/// tickLblPos. Optional ST_TickLblPos enum (schema default `nextTo`).
pub(all) struct CT_TickLblPos {
  /// @val (ST_TickLblPos) — optional, schema default `nextTo`.
  val : ST_TickLblPos?
} derive(Eq, Debug)

///|
pub fn CT_TickLblPos::new(
  element : @xml.Element,
) -> CT_TickLblPos raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_TickLblPos::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_Skip — Part 1 §21.2.2.212 / §21.2.2.213 (dml-chart.xsd)
/// tickLblSkip/tickMarkSkip. Required ST_Skip unsignedInt (minInclusive=1).
pub(all) struct CT_Skip {
  /// @val (ST_Skip) — required.
  val : ST_Skip
} derive(Eq, Debug)

///|
pub fn CT_Skip::new(element : @xml.Element) -> CT_Skip raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_Skip/@val",
        reason="required attribute missing",
      )
  }
  let val = ST_Skip::parse(raw)
  { val, }
}

///|
/// XSD complex type CT_TimeUnit — Part 1 §21.2.2.14 / §21.2.2.116 / §21.2.2.123
/// (dml-chart.xsd) baseTimeUnit/majorTimeUnit/minorTimeUnit. Optional
/// ST_TimeUnit enum (schema default `days`).
pub(all) struct CT_TimeUnit {
  /// @val (ST_TimeUnit) — optional, schema default `days`.
  val : ST_TimeUnit?
} derive(Eq, Debug)

///|
pub fn CT_TimeUnit::new(
  element : @xml.Element,
) -> CT_TimeUnit raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_TimeUnit::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_AxisUnit — Part 1 §21.2.2.115 / §21.2.2.121
/// (dml-chart.xsd) majorUnit/minorUnit. Required ST_AxisUnit double
/// (minExclusive=0).
pub(all) struct CT_AxisUnit {
  /// @val (ST_AxisUnit) — required.
  val : ST_AxisUnit
} derive(Eq, Debug)

///|
pub fn CT_AxisUnit::new(
  element : @xml.Element,
) -> CT_AxisUnit raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_AxisUnit/@val",
        reason="required attribute missing",
      )
  }
  let val = ST_AxisUnit::parse(raw)
  { val, }
}

///|
/// XSD complex type CT_BuiltInUnit — Part 1 §21.2.2.19 (dml-chart.xsd)
/// builtInUnit. Optional ST_BuiltInUnit enum (schema default `thousands`).
pub(all) struct CT_BuiltInUnit {
  /// @val (ST_BuiltInUnit) — optional, schema default `thousands`.
  val : ST_BuiltInUnit?
} derive(Eq, Debug)

///|
pub fn CT_BuiltInUnit::new(
  element : @xml.Element,
) -> CT_BuiltInUnit raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_BuiltInUnit::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_PictureFormat — Part 1 §21.2.2.146 (dml-chart.xsd)
/// pictureFormat. Required ST_PictureFormat enum (no schema default).
pub(all) struct CT_PictureFormat {
  /// @val (ST_PictureFormat) — required.
  val : ST_PictureFormat
} derive(Eq, Debug)

///|
pub fn CT_PictureFormat::new(
  element : @xml.Element,
) -> CT_PictureFormat raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PictureFormat/@val",
        reason="required attribute missing",
      )
  }
  let val = ST_PictureFormat::parse(raw)
  { val, }
}

///|
/// XSD complex type CT_PictureStackUnit — Part 1 §21.2.2.148 (dml-chart.xsd)
/// pictureStackUnit. Required ST_PictureStackUnit double (minExclusive=0).
pub(all) struct CT_PictureStackUnit {
  /// @val (ST_PictureStackUnit) — required.
  val : ST_PictureStackUnit
} derive(Eq, Debug)

///|
pub fn CT_PictureStackUnit::new(
  element : @xml.Element,
) -> CT_PictureStackUnit raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PictureStackUnit/@val",
        reason="required attribute missing",
      )
  }
  let val = ST_PictureStackUnit::parse(raw)
  { val, }
}

///|
/// XSD complex type CT_PictureOptions — Part 1 §21.2.2.147 (dml-chart.xsd)
/// pictureOptions. Sequence of applyToFront?, applyToSides?, applyToEnd?,
/// pictureFormat?, pictureStackUnit?.
pub(all) struct CT_PictureOptions {
  /// <applyToFront> (CT_Boolean) — optional.
  apply_to_front : CT_Boolean?
  /// <applyToSides> (CT_Boolean) — optional.
  apply_to_sides : CT_Boolean?
  /// <applyToEnd> (CT_Boolean) — optional.
  apply_to_end : CT_Boolean?
  /// <pictureFormat> (CT_PictureFormat) — optional.
  picture_format : CT_PictureFormat?
  /// <pictureStackUnit> (CT_PictureStackUnit) — optional.
  picture_stack_unit : CT_PictureStackUnit?
} derive(Eq, Debug)

///|
pub fn CT_PictureOptions::new(
  element : @xml.Element,
) -> CT_PictureOptions raise SchemaViolation {
  let apply_to_front = match first_child_named(element, "applyToFront") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let apply_to_sides = match first_child_named(element, "applyToSides") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let apply_to_end = match first_child_named(element, "applyToEnd") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let picture_format = match first_child_named(element, "pictureFormat") {
    Some(child) => Some(CT_PictureFormat::new(child))
    None => None
  }
  let picture_stack_unit = match
    first_child_named(element, "pictureStackUnit") {
    Some(child) => Some(CT_PictureStackUnit::new(child))
    None => None
  }
  {
    apply_to_front,
    apply_to_sides,
    apply_to_end,
    picture_format,
    picture_stack_unit,
  }
}

///|
/// XSD complex type CT_DispUnitsLbl — Part 1 §21.2.2.56 (dml-chart.xsd)
/// dispUnitsLbl. Sequence of layout?, tx?, spPr? (a:CT_ShapeProperties as raw
/// element), txPr? (a:CT_TextBody as raw element).
pub(all) struct CT_DispUnitsLbl {
  /// <layout> (CT_Layout) — optional.
  layout : CT_Layout?
  /// <tx> (CT_Tx) — optional.
  tx : CT_Tx?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
} derive(Eq, Debug)

///|
/// XSD complex type CT_DispUnits — Part 1 §21.2.2.49 (dml-chart.xsd) dispUnits.
/// Sequence: choice of `custUnit` (CT_Double) or `builtInUnit` (CT_BuiltInUnit),
/// then optional `dispUnitsLbl` and `extLst`. The XSD `<xsd:choice>` is unbounded
/// minOccurs implicit 1, but `CT_BuiltInUnit` remains a chunk3 wrapper preserved
/// as raw `@xml.Element` until that batch types it.
pub(all) struct CT_DispUnits {
  /// <custUnit> (CT_Double) — choice branch, optional in either branch.
  cust_unit : CT_Double?
  /// <builtInUnit> (CT_BuiltInUnit, chunk3 wrapper) preserved as raw element.
  built_in_unit : @xml.Element?
  /// <dispUnitsLbl> (CT_DispUnitsLbl, chunk3 wrapper) preserved as raw element.
  disp_units_lbl : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_DispUnits::new(
  element : @xml.Element,
) -> CT_DispUnits raise SchemaViolation {
  let cust_unit = match first_child_named(element, "custUnit") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let built_in_unit = first_child_named(element, "builtInUnit")
  let disp_units_lbl = first_child_named(element, "dispUnitsLbl")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { cust_unit, built_in_unit, disp_units_lbl, ext_lst }
}

///|
/// XSD complex type CT_Orientation — Part 1 §21.2.2.130 (dml-chart.xsd) orientation.
/// Single optional `val` attribute (ST_Orientation; schema default `minMax`).
pub(all) struct CT_Orientation {
  /// @val (ST_Orientation) — optional, schema default `minMax`.
  val : ST_Orientation?
} derive(Eq, Debug)

///|
pub fn CT_Orientation::new(
  element : @xml.Element,
) -> CT_Orientation raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_Orientation::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_LogBase — Part 1 §21.2.2.105 (dml-chart.xsd) logBase.
/// Required `val` (ST_LogBase; xsd:double restricted to 2..1000).
pub(all) struct CT_LogBase {
  /// @val (ST_LogBase) — required.
  val : ST_LogBase
} derive(Eq, Debug)

///|
pub fn CT_LogBase::new(
  element : @xml.Element,
) -> CT_LogBase raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_LogBase/@val",
        reason="required attribute missing",
      )
  }
  { val: ST_LogBase::parse(raw) }
}

///|
/// XSD complex type CT_Scaling — Part 1 §21.2.2.176 (dml-chart.xsd) scaling.
/// Sequence: optional logBase, orientation, max (CT_Double), min (CT_Double), extLst.
pub(all) struct CT_Scaling {
  /// <logBase> (CT_LogBase) — optional.
  log_base : CT_LogBase?
  /// <orientation> (CT_Orientation) — optional.
  orientation : CT_Orientation?
  /// <max> (CT_Double) — optional.
  max : CT_Double?
  /// <min> (CT_Double) — optional.
  min : CT_Double?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Scaling::new(
  element : @xml.Element,
) -> CT_Scaling raise SchemaViolation {
  let log_base = match first_child_named(element, "logBase") {
    Some(child) => Some(CT_LogBase::new(child))
    None => None
  }
  let orientation = match first_child_named(element, "orientation") {
    Some(child) => Some(CT_Orientation::new(child))
    None => None
  }
  let max = match first_child_named(element, "max") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let min = match first_child_named(element, "min") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { log_base, orientation, max, min, ext_lst }
}

///|
/// XSD complex type CT_LblOffset — Part 1 §21.2.2.95 (dml-chart.xsd) lblOffset.
/// Single optional `val` attribute (ST_LblOffset; default `100%`).
pub(all) struct CT_LblOffset {
  /// @val (ST_LblOffset) — optional, schema default `100%`.
  val : ST_LblOffset?
} derive(Eq, Debug)

///|
pub fn CT_LblOffset::new(
  element : @xml.Element,
) -> CT_LblOffset raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_LblOffset::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_CatAx — Part 1 §21.2.2.25 (dml-chart.xsd) catAx.
/// Sequence: EG_AxShared group (axId, scaling, delete, axPos, majorGridlines,
/// minorGridlines, title, numFmt, majorTickMark, minorTickMark, tickLblPos,
/// spPr, txPr, crossAx, then optional choice crosses/crossesAt) followed by
/// auto, lblAlgn, lblOffset, tickLblSkip, tickMarkSkip, noMultiLvlLbl, extLst.
/// `CT_AxPos`, `CT_ChartLines`, `CT_TickMark`, `CT_TickLblPos`, `CT_Skip`, and
/// `CT_Crosses` remain chunk3 wrappers preserved as raw `@xml.Element`.
pub(all) struct CT_CatAx {
  /// <axId> (CT_UnsignedInt) — required.
  ax_id : CT_UnsignedInt
  /// <scaling> (CT_Scaling) — required.
  scaling : CT_Scaling
  /// <delete> (CT_Boolean) — optional.
  delete : CT_Boolean?
  /// <axPos> (CT_AxPos, chunk3 wrapper) — required, preserved as raw element.
  ax_pos : @xml.Element
  /// <majorGridlines> (CT_ChartLines) — optional.
  major_gridlines : CT_ChartLines?
  /// <minorGridlines> (CT_ChartLines) — optional.
  minor_gridlines : CT_ChartLines?
  /// <title> (CT_Title) — optional.
  title : CT_Title?
  /// <numFmt> (CT_NumFmt) — optional.
  num_fmt : CT_NumFmt?
  /// <majorTickMark> (CT_TickMark, chunk3) preserved as raw element.
  major_tick_mark : @xml.Element?
  /// <minorTickMark> (CT_TickMark, chunk3) preserved as raw element.
  minor_tick_mark : @xml.Element?
  /// <tickLblPos> (CT_TickLblPos, chunk3) preserved as raw element.
  tick_lbl_pos : @xml.Element?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <crossAx> (CT_UnsignedInt) — required.
  cross_ax : CT_UnsignedInt
  /// <crosses> (CT_Crosses, chunk3) — choice branch, preserved as raw element.
  crosses : @xml.Element?
  /// <crossesAt> (CT_Double) — choice branch, optional.
  crosses_at : CT_Double?
  /// <auto> (CT_Boolean) — optional.
  auto : CT_Boolean?
  /// <lblAlgn> (CT_LblAlgn) — optional.
  lbl_algn : CT_LblAlgn?
  /// <lblOffset> (CT_LblOffset) — optional.
  lbl_offset : CT_LblOffset?
  /// <tickLblSkip> (CT_Skip, chunk3) preserved as raw element.
  tick_lbl_skip : @xml.Element?
  /// <tickMarkSkip> (CT_Skip, chunk3) preserved as raw element.
  tick_mark_skip : @xml.Element?
  /// <noMultiLvlLbl> (CT_Boolean) — optional.
  no_multi_lvl_lbl : CT_Boolean?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_CatAx::new(element : @xml.Element) -> CT_CatAx raise SchemaViolation {
  let ax_id_element = match first_child_named(element, "axId") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_CatAx/axId",
        reason="required child missing",
      )
  }
  let ax_id = CT_UnsignedInt::new(ax_id_element)
  let scaling_element = match first_child_named(element, "scaling") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_CatAx/scaling",
        reason="required child missing",
      )
  }
  let scaling = CT_Scaling::new(scaling_element)
  let delete = match first_child_named(element, "delete") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ax_pos = match first_child_named(element, "axPos") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_CatAx/axPos",
        reason="required child missing",
      )
  }
  let major_gridlines = match first_child_named(element, "majorGridlines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let minor_gridlines = match first_child_named(element, "minorGridlines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let title = match first_child_named(element, "title") {
    Some(child) => Some(CT_Title::new(child))
    None => None
  }
  let num_fmt = match first_child_named(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let major_tick_mark = first_child_named(element, "majorTickMark")
  let minor_tick_mark = first_child_named(element, "minorTickMark")
  let tick_lbl_pos = first_child_named(element, "tickLblPos")
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let cross_ax_element = match first_child_named(element, "crossAx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_CatAx/crossAx",
        reason="required child missing",
      )
  }
  let cross_ax = CT_UnsignedInt::new(cross_ax_element)
  let crosses = first_child_named(element, "crosses")
  let crosses_at = match first_child_named(element, "crossesAt") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let auto = match first_child_named(element, "auto") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let lbl_algn = match first_child_named(element, "lblAlgn") {
    Some(child) => Some(CT_LblAlgn::new(child))
    None => None
  }
  let lbl_offset = match first_child_named(element, "lblOffset") {
    Some(child) => Some(CT_LblOffset::new(child))
    None => None
  }
  let tick_lbl_skip = first_child_named(element, "tickLblSkip")
  let tick_mark_skip = first_child_named(element, "tickMarkSkip")
  let no_multi_lvl_lbl = match first_child_named(element, "noMultiLvlLbl") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    ax_id,
    scaling,
    delete,
    ax_pos,
    major_gridlines,
    minor_gridlines,
    title,
    num_fmt,
    major_tick_mark,
    minor_tick_mark,
    tick_lbl_pos,
    sp_pr,
    tx_pr,
    cross_ax,
    crosses,
    crosses_at,
    auto,
    lbl_algn,
    lbl_offset,
    tick_lbl_skip,
    tick_mark_skip,
    no_multi_lvl_lbl,
    ext_lst,
  }
}

///|
/// XSD complex type CT_DateAx — Part 1 §21.2.2.39 (dml-chart.xsd) dateAx.
/// Sequence: EG_AxShared followed by auto, lblOffset, baseTimeUnit, majorUnit,
/// majorTimeUnit, minorUnit, minorTimeUnit, extLst. `CT_AxPos`, `CT_TickMark`,
/// `CT_TickLblPos`, `CT_Crosses`, `CT_TimeUnit`, `CT_AxisUnit` are chunk3
/// wrappers preserved as raw `@xml.Element`.
pub(all) struct CT_DateAx {
  /// <axId> (CT_UnsignedInt) — required.
  ax_id : CT_UnsignedInt
  /// <scaling> (CT_Scaling) — required.
  scaling : CT_Scaling
  /// <delete> (CT_Boolean) — optional.
  delete : CT_Boolean?
  /// <axPos> (CT_AxPos, chunk3) — required, preserved as raw element.
  ax_pos : @xml.Element
  /// <majorGridlines> (CT_ChartLines) — optional.
  major_gridlines : CT_ChartLines?
  /// <minorGridlines> (CT_ChartLines) — optional.
  minor_gridlines : CT_ChartLines?
  /// <title> (CT_Title) — optional.
  title : CT_Title?
  /// <numFmt> (CT_NumFmt) — optional.
  num_fmt : CT_NumFmt?
  /// <majorTickMark> (CT_TickMark, chunk3) preserved as raw element.
  major_tick_mark : @xml.Element?
  /// <minorTickMark> (CT_TickMark, chunk3) preserved as raw element.
  minor_tick_mark : @xml.Element?
  /// <tickLblPos> (CT_TickLblPos, chunk3) preserved as raw element.
  tick_lbl_pos : @xml.Element?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <crossAx> (CT_UnsignedInt) — required.
  cross_ax : CT_UnsignedInt
  /// <crosses> (CT_Crosses, chunk3) — choice branch, preserved as raw element.
  crosses : @xml.Element?
  /// <crossesAt> (CT_Double) — choice branch, optional.
  crosses_at : CT_Double?
  /// <auto> (CT_Boolean) — optional.
  auto : CT_Boolean?
  /// <lblOffset> (CT_LblOffset) — optional.
  lbl_offset : CT_LblOffset?
  /// <baseTimeUnit> (CT_TimeUnit, chunk3) preserved as raw element.
  base_time_unit : @xml.Element?
  /// <majorUnit> (CT_AxisUnit, chunk3) preserved as raw element.
  major_unit : @xml.Element?
  /// <majorTimeUnit> (CT_TimeUnit, chunk3) preserved as raw element.
  major_time_unit : @xml.Element?
  /// <minorUnit> (CT_AxisUnit, chunk3) preserved as raw element.
  minor_unit : @xml.Element?
  /// <minorTimeUnit> (CT_TimeUnit, chunk3) preserved as raw element.
  minor_time_unit : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_DateAx::new(
  element : @xml.Element,
) -> CT_DateAx raise SchemaViolation {
  let ax_id_element = match first_child_named(element, "axId") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_DateAx/axId",
        reason="required child missing",
      )
  }
  let ax_id = CT_UnsignedInt::new(ax_id_element)
  let scaling_element = match first_child_named(element, "scaling") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_DateAx/scaling",
        reason="required child missing",
      )
  }
  let scaling = CT_Scaling::new(scaling_element)
  let delete = match first_child_named(element, "delete") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ax_pos = match first_child_named(element, "axPos") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_DateAx/axPos",
        reason="required child missing",
      )
  }
  let major_gridlines = match first_child_named(element, "majorGridlines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let minor_gridlines = match first_child_named(element, "minorGridlines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let title = match first_child_named(element, "title") {
    Some(child) => Some(CT_Title::new(child))
    None => None
  }
  let num_fmt = match first_child_named(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let major_tick_mark = first_child_named(element, "majorTickMark")
  let minor_tick_mark = first_child_named(element, "minorTickMark")
  let tick_lbl_pos = first_child_named(element, "tickLblPos")
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let cross_ax_element = match first_child_named(element, "crossAx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_DateAx/crossAx",
        reason="required child missing",
      )
  }
  let cross_ax = CT_UnsignedInt::new(cross_ax_element)
  let crosses = first_child_named(element, "crosses")
  let crosses_at = match first_child_named(element, "crossesAt") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let auto = match first_child_named(element, "auto") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let lbl_offset = match first_child_named(element, "lblOffset") {
    Some(child) => Some(CT_LblOffset::new(child))
    None => None
  }
  let base_time_unit = first_child_named(element, "baseTimeUnit")
  let major_unit = first_child_named(element, "majorUnit")
  let major_time_unit = first_child_named(element, "majorTimeUnit")
  let minor_unit = first_child_named(element, "minorUnit")
  let minor_time_unit = first_child_named(element, "minorTimeUnit")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    ax_id,
    scaling,
    delete,
    ax_pos,
    major_gridlines,
    minor_gridlines,
    title,
    num_fmt,
    major_tick_mark,
    minor_tick_mark,
    tick_lbl_pos,
    sp_pr,
    tx_pr,
    cross_ax,
    crosses,
    crosses_at,
    auto,
    lbl_offset,
    base_time_unit,
    major_unit,
    major_time_unit,
    minor_unit,
    minor_time_unit,
    ext_lst,
  }
}

///|
/// XSD complex type CT_SerAx — Part 1 §21.2.2.184 (dml-chart.xsd) serAx.
/// Sequence: EG_AxShared followed by tickLblSkip, tickMarkSkip, extLst. Chunk3
/// wrappers (`CT_AxPos`, `CT_TickMark`, `CT_TickLblPos`, `CT_Skip`,
/// `CT_Crosses`) are preserved as raw `@xml.Element`.
pub(all) struct CT_SerAx {
  /// <axId> (CT_UnsignedInt) — required.
  ax_id : CT_UnsignedInt
  /// <scaling> (CT_Scaling) — required.
  scaling : CT_Scaling
  /// <delete> (CT_Boolean) — optional.
  delete : CT_Boolean?
  /// <axPos> (CT_AxPos, chunk3) — required, preserved as raw element.
  ax_pos : @xml.Element
  /// <majorGridlines> (CT_ChartLines) — optional.
  major_gridlines : CT_ChartLines?
  /// <minorGridlines> (CT_ChartLines) — optional.
  minor_gridlines : CT_ChartLines?
  /// <title> (CT_Title) — optional.
  title : CT_Title?
  /// <numFmt> (CT_NumFmt) — optional.
  num_fmt : CT_NumFmt?
  /// <majorTickMark> (CT_TickMark, chunk3) preserved as raw element.
  major_tick_mark : @xml.Element?
  /// <minorTickMark> (CT_TickMark, chunk3) preserved as raw element.
  minor_tick_mark : @xml.Element?
  /// <tickLblPos> (CT_TickLblPos, chunk3) preserved as raw element.
  tick_lbl_pos : @xml.Element?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <crossAx> (CT_UnsignedInt) — required.
  cross_ax : CT_UnsignedInt
  /// <crosses> (CT_Crosses, chunk3) — choice branch, preserved as raw element.
  crosses : @xml.Element?
  /// <crossesAt> (CT_Double) — choice branch, optional.
  crosses_at : CT_Double?
  /// <tickLblSkip> (CT_Skip, chunk3) preserved as raw element.
  tick_lbl_skip : @xml.Element?
  /// <tickMarkSkip> (CT_Skip, chunk3) preserved as raw element.
  tick_mark_skip : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_SerAx::new(element : @xml.Element) -> CT_SerAx raise SchemaViolation {
  let ax_id_element = match first_child_named(element, "axId") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_SerAx/axId",
        reason="required child missing",
      )
  }
  let ax_id = CT_UnsignedInt::new(ax_id_element)
  let scaling_element = match first_child_named(element, "scaling") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_SerAx/scaling",
        reason="required child missing",
      )
  }
  let scaling = CT_Scaling::new(scaling_element)
  let delete = match first_child_named(element, "delete") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ax_pos = match first_child_named(element, "axPos") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_SerAx/axPos",
        reason="required child missing",
      )
  }
  let major_gridlines = match first_child_named(element, "majorGridlines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let minor_gridlines = match first_child_named(element, "minorGridlines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let title = match first_child_named(element, "title") {
    Some(child) => Some(CT_Title::new(child))
    None => None
  }
  let num_fmt = match first_child_named(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let major_tick_mark = first_child_named(element, "majorTickMark")
  let minor_tick_mark = first_child_named(element, "minorTickMark")
  let tick_lbl_pos = first_child_named(element, "tickLblPos")
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let cross_ax_element = match first_child_named(element, "crossAx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_SerAx/crossAx",
        reason="required child missing",
      )
  }
  let cross_ax = CT_UnsignedInt::new(cross_ax_element)
  let crosses = first_child_named(element, "crosses")
  let crosses_at = match first_child_named(element, "crossesAt") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let tick_lbl_skip = first_child_named(element, "tickLblSkip")
  let tick_mark_skip = first_child_named(element, "tickMarkSkip")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    ax_id,
    scaling,
    delete,
    ax_pos,
    major_gridlines,
    minor_gridlines,
    title,
    num_fmt,
    major_tick_mark,
    minor_tick_mark,
    tick_lbl_pos,
    sp_pr,
    tx_pr,
    cross_ax,
    crosses,
    crosses_at,
    tick_lbl_skip,
    tick_mark_skip,
    ext_lst,
  }
}

///|
/// XSD complex type CT_ValAx — Part 1 §21.2.2.226 (dml-chart.xsd) valAx.
/// Sequence: EG_AxShared followed by crossBetween, majorUnit, minorUnit,
/// dispUnits, extLst. Chunk3 wrappers (`CT_AxPos`, `CT_TickMark`,
/// `CT_TickLblPos`, `CT_CrossBetween`, `CT_Crosses`, `CT_AxisUnit`) preserved
/// as raw `@xml.Element`.
pub(all) struct CT_ValAx {
  /// <axId> (CT_UnsignedInt) — required.
  ax_id : CT_UnsignedInt
  /// <scaling> (CT_Scaling) — required.
  scaling : CT_Scaling
  /// <delete> (CT_Boolean) — optional.
  delete : CT_Boolean?
  /// <axPos> (CT_AxPos, chunk3) — required, preserved as raw element.
  ax_pos : @xml.Element
  /// <majorGridlines> (CT_ChartLines) — optional.
  major_gridlines : CT_ChartLines?
  /// <minorGridlines> (CT_ChartLines) — optional.
  minor_gridlines : CT_ChartLines?
  /// <title> (CT_Title) — optional.
  title : CT_Title?
  /// <numFmt> (CT_NumFmt) — optional.
  num_fmt : CT_NumFmt?
  /// <majorTickMark> (CT_TickMark, chunk3) preserved as raw element.
  major_tick_mark : @xml.Element?
  /// <minorTickMark> (CT_TickMark, chunk3) preserved as raw element.
  minor_tick_mark : @xml.Element?
  /// <tickLblPos> (CT_TickLblPos, chunk3) preserved as raw element.
  tick_lbl_pos : @xml.Element?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <crossAx> (CT_UnsignedInt) — required.
  cross_ax : CT_UnsignedInt
  /// <crosses> (CT_Crosses, chunk3) — choice branch, preserved as raw element.
  crosses : @xml.Element?
  /// <crossesAt> (CT_Double) — choice branch, optional.
  crosses_at : CT_Double?
  /// <crossBetween> (CT_CrossBetween, chunk3) preserved as raw element.
  cross_between : @xml.Element?
  /// <majorUnit> (CT_AxisUnit, chunk3) preserved as raw element.
  major_unit : @xml.Element?
  /// <minorUnit> (CT_AxisUnit, chunk3) preserved as raw element.
  minor_unit : @xml.Element?
  /// <dispUnits> (CT_DispUnits) — optional.
  disp_units : CT_DispUnits?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_ValAx::new(element : @xml.Element) -> CT_ValAx raise SchemaViolation {
  let ax_id_element = match first_child_named(element, "axId") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ValAx/axId",
        reason="required child missing",
      )
  }
  let ax_id = CT_UnsignedInt::new(ax_id_element)
  let scaling_element = match first_child_named(element, "scaling") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ValAx/scaling",
        reason="required child missing",
      )
  }
  let scaling = CT_Scaling::new(scaling_element)
  let delete = match first_child_named(element, "delete") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ax_pos = match first_child_named(element, "axPos") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ValAx/axPos",
        reason="required child missing",
      )
  }
  let major_gridlines = match first_child_named(element, "majorGridlines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let minor_gridlines = match first_child_named(element, "minorGridlines") {
    Some(child) => Some(CT_ChartLines::new(child))
    None => None
  }
  let title = match first_child_named(element, "title") {
    Some(child) => Some(CT_Title::new(child))
    None => None
  }
  let num_fmt = match first_child_named(element, "numFmt") {
    Some(child) => Some(CT_NumFmt::new(child))
    None => None
  }
  let major_tick_mark = first_child_named(element, "majorTickMark")
  let minor_tick_mark = first_child_named(element, "minorTickMark")
  let tick_lbl_pos = first_child_named(element, "tickLblPos")
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let cross_ax_element = match first_child_named(element, "crossAx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ValAx/crossAx",
        reason="required child missing",
      )
  }
  let cross_ax = CT_UnsignedInt::new(cross_ax_element)
  let crosses = first_child_named(element, "crosses")
  let crosses_at = match first_child_named(element, "crossesAt") {
    Some(child) => Some(CT_Double::new(child))
    None => None
  }
  let cross_between = first_child_named(element, "crossBetween")
  let major_unit = first_child_named(element, "majorUnit")
  let minor_unit = first_child_named(element, "minorUnit")
  let disp_units = match first_child_named(element, "dispUnits") {
    Some(child) => Some(CT_DispUnits::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    ax_id,
    scaling,
    delete,
    ax_pos,
    major_gridlines,
    minor_gridlines,
    title,
    num_fmt,
    major_tick_mark,
    minor_tick_mark,
    tick_lbl_pos,
    sp_pr,
    tx_pr,
    cross_ax,
    crosses,
    crosses_at,
    cross_between,
    major_unit,
    minor_unit,
    disp_units,
    ext_lst,
  }
}

///|
/// XSD complex type CT_PlotArea — Part 1 §21.2.2.145 (dml-chart.xsd) plotArea.
/// Sequence: optional layout; then a required choice of one-or-more chart
/// elements (areaChart..bubbleChart, all chunk3 wrappers preserved raw); then
/// an optional zero-or-more choice of axis elements (valAx, catAx, dateAx,
/// serAx); then optional dTable, spPr, extLst.
pub(all) struct CT_PlotArea {
  /// <layout> (CT_Layout) — optional.
  layout : CT_Layout?
  /// <areaChart> (CT_AreaChart, chunk3) zero-or-more, preserved as raw element.
  area_chart : Array[@xml.Element]
  /// <area3DChart> (CT_Area3DChart, chunk3) zero-or-more, preserved as raw element.
  area_3d_chart : Array[@xml.Element]
  /// <lineChart> (CT_LineChart, chunk3) zero-or-more, preserved as raw element.
  line_chart : Array[@xml.Element]
  /// <line3DChart> (CT_Line3DChart, chunk3) zero-or-more, preserved as raw element.
  line_3d_chart : Array[@xml.Element]
  /// <stockChart> (CT_StockChart, chunk3) zero-or-more, preserved as raw element.
  stock_chart : Array[@xml.Element]
  /// <radarChart> (CT_RadarChart, chunk3) zero-or-more, preserved as raw element.
  radar_chart : Array[@xml.Element]
  /// <scatterChart> (CT_ScatterChart, chunk3) zero-or-more, preserved as raw element.
  scatter_chart : Array[@xml.Element]
  /// <pieChart> (CT_PieChart, chunk3) zero-or-more, preserved as raw element.
  pie_chart : Array[@xml.Element]
  /// <pie3DChart> (CT_Pie3DChart, chunk3) zero-or-more, preserved as raw element.
  pie_3d_chart : Array[@xml.Element]
  /// <doughnutChart> (CT_DoughnutChart, chunk3) zero-or-more, preserved as raw element.
  doughnut_chart : Array[@xml.Element]
  /// <barChart> (CT_BarChart, chunk3) zero-or-more, preserved as raw element.
  bar_chart : Array[@xml.Element]
  /// <bar3DChart> (CT_Bar3DChart, chunk3) zero-or-more, preserved as raw element.
  bar_3d_chart : Array[@xml.Element]
  /// <ofPieChart> (CT_OfPieChart, chunk3) zero-or-more, preserved as raw element.
  of_pie_chart : Array[@xml.Element]
  /// <surfaceChart> (CT_SurfaceChart, chunk3) zero-or-more, preserved as raw element.
  surface_chart : Array[@xml.Element]
  /// <surface3DChart> (CT_Surface3DChart, chunk3) zero-or-more, preserved as raw element.
  surface_3d_chart : Array[@xml.Element]
  /// <bubbleChart> (CT_BubbleChart, chunk3) zero-or-more, preserved as raw element.
  bubble_chart : Array[@xml.Element]
  /// <valAx> (CT_ValAx) zero-or-more.
  val_ax : Array[CT_ValAx]
  /// <catAx> (CT_CatAx) zero-or-more.
  cat_ax : Array[CT_CatAx]
  /// <dateAx> (CT_DateAx) zero-or-more.
  date_ax : Array[CT_DateAx]
  /// <serAx> (CT_SerAx) zero-or-more.
  ser_ax : Array[CT_SerAx]
  /// <dTable> (CT_DTable) — optional.
  d_table : CT_DTable?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PlotArea::new(
  element : @xml.Element,
) -> CT_PlotArea raise SchemaViolation {
  let layout = match first_child_named(element, "layout") {
    Some(child) => Some(CT_Layout::new(child))
    None => None
  }
  let area_chart = children_named(element, "areaChart")
  let area_3d_chart = children_named(element, "area3DChart")
  let line_chart = children_named(element, "lineChart")
  let line_3d_chart = children_named(element, "line3DChart")
  let stock_chart = children_named(element, "stockChart")
  let radar_chart = children_named(element, "radarChart")
  let scatter_chart = children_named(element, "scatterChart")
  let pie_chart = children_named(element, "pieChart")
  let pie_3d_chart = children_named(element, "pie3DChart")
  let doughnut_chart = children_named(element, "doughnutChart")
  let bar_chart = children_named(element, "barChart")
  let bar_3d_chart = children_named(element, "bar3DChart")
  let of_pie_chart = children_named(element, "ofPieChart")
  let surface_chart = children_named(element, "surfaceChart")
  let surface_3d_chart = children_named(element, "surface3DChart")
  let bubble_chart = children_named(element, "bubbleChart")
  let val_ax = []
  for child in children_named(element, "valAx") {
    val_ax.push(CT_ValAx::new(child))
  }
  let cat_ax = []
  for child in children_named(element, "catAx") {
    cat_ax.push(CT_CatAx::new(child))
  }
  let date_ax = []
  for child in children_named(element, "dateAx") {
    date_ax.push(CT_DateAx::new(child))
  }
  let ser_ax = []
  for child in children_named(element, "serAx") {
    ser_ax.push(CT_SerAx::new(child))
  }
  let d_table = match first_child_named(element, "dTable") {
    Some(child) => Some(CT_DTable::new(child))
    None => None
  }
  let sp_pr = first_child_named(element, "spPr")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    layout,
    area_chart,
    area_3d_chart,
    line_chart,
    line_3d_chart,
    stock_chart,
    radar_chart,
    scatter_chart,
    pie_chart,
    pie_3d_chart,
    doughnut_chart,
    bar_chart,
    bar_3d_chart,
    of_pie_chart,
    surface_chart,
    surface_3d_chart,
    bubble_chart,
    val_ax,
    cat_ax,
    date_ax,
    ser_ax,
    d_table,
    sp_pr,
    ext_lst,
  }
}

///|
/// XSD complex type CT_PivotFmt — Part 1 §21.2.2.142 (dml-chart.xsd) pivotFmt.
/// Sequence: required `idx`, optional `spPr`, `txPr`, `marker`, `dLbl`, `extLst`.
pub(all) struct CT_PivotFmt {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <marker> (CT_Marker) — optional.
  marker : CT_Marker?
  /// <dLbl> (CT_DLbl) — optional.
  d_lbl : CT_DLbl?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_PivotFmt::new(
  element : @xml.Element,
) -> CT_PivotFmt raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PivotFmt/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let marker = match first_child_named(element, "marker") {
    Some(child) => Some(CT_Marker::new(child))
    None => None
  }
  let d_lbl = match first_child_named(element, "dLbl") {
    Some(child) => Some(CT_DLbl::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { idx, sp_pr, tx_pr, marker, d_lbl, ext_lst }
}

///|
/// XSD complex type CT_PivotFmts — Part 1 §21.2.2.143 (dml-chart.xsd) pivotFmts.
/// Sequence of zero-or-more `pivotFmt` children.
pub(all) struct CT_PivotFmts {
  /// <pivotFmt> (CT_PivotFmt) — zero or more.
  pivot_fmt : Array[CT_PivotFmt]
} derive(Eq, Debug)

///|
pub fn CT_PivotFmts::new(
  element : @xml.Element,
) -> CT_PivotFmts raise SchemaViolation {
  let pivot_fmt = []
  for child in children_named(element, "pivotFmt") {
    pivot_fmt.push(CT_PivotFmt::new(child))
  }
  { pivot_fmt, }
}

///|
/// XSD complex type CT_LegendPos — Part 1 §21.2.2.102 (dml-chart.xsd) legendPos.
/// Single optional `val` attribute (ST_LegendPos; schema default `r`).
pub(all) struct CT_LegendPos {
  /// @val (ST_LegendPos) — optional, schema default `r`.
  val : ST_LegendPos?
} derive(Eq, Debug)

///|
pub fn CT_LegendPos::new(
  element : @xml.Element,
) -> CT_LegendPos raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_LegendPos::parse(text))
    None => None
  }
  { val, }
}

///|
/// XSD complex type CT_LegendEntry — Part 1 §21.2.2.101 (dml-chart.xsd)
/// legendEntry. Sequence: required `idx`, then a choice of `delete` (boolean)
/// or `EG_LegendEntryData` (an inlined optional `txPr`), then optional `extLst`.
pub(all) struct CT_LegendEntry {
  /// <idx> (CT_UnsignedInt) — required.
  idx : CT_UnsignedInt
  /// <delete> (CT_Boolean) — choice branch, optional.
  delete : CT_Boolean?
  /// <txPr> (a:CT_TextBody, from EG_LegendEntryData) — choice branch,
  /// preserved as raw element.
  tx_pr : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_LegendEntry::new(
  element : @xml.Element,
) -> CT_LegendEntry raise SchemaViolation {
  let idx_element = match first_child_named(element, "idx") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_LegendEntry/idx",
        reason="required child missing",
      )
  }
  let idx = CT_UnsignedInt::new(idx_element)
  let delete = match first_child_named(element, "delete") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let tx_pr = first_child_named(element, "txPr")
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  { idx, delete, tx_pr, ext_lst }
}

///|
/// XSD complex type CT_Legend — Part 1 §21.2.2.100 (dml-chart.xsd) legend.
/// Sequence: optional legendPos, zero-or-more legendEntry, optional layout,
/// overlay, spPr, txPr, extLst.
pub(all) struct CT_Legend {
  /// <legendPos> (CT_LegendPos) — optional.
  legend_pos : CT_LegendPos?
  /// <legendEntry> (CT_LegendEntry) — zero or more.
  legend_entry : Array[CT_LegendEntry]
  /// <layout> (CT_Layout) — optional.
  layout : CT_Layout?
  /// <overlay> (CT_Boolean) — optional.
  overlay : CT_Boolean?
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Legend::new(
  element : @xml.Element,
) -> CT_Legend raise SchemaViolation {
  let legend_pos = match first_child_named(element, "legendPos") {
    Some(child) => Some(CT_LegendPos::new(child))
    None => None
  }
  let legend_entry = []
  for child in children_named(element, "legendEntry") {
    legend_entry.push(CT_LegendEntry::new(child))
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
  { legend_pos, legend_entry, layout, overlay, sp_pr, tx_pr, ext_lst }
}

///|
/// XSD complex type CT_DispBlanksAs — Part 1 §21.2.2.48 (dml-chart.xsd)
/// dispBlanksAs. Single optional `val` (ST_DispBlanksAs; schema default `zero`).
pub(all) struct CT_DispBlanksAs {
  /// @val (ST_DispBlanksAs) — optional, schema default `zero`.
  val : ST_DispBlanksAs?
} derive(Eq, Debug)

///|
pub fn CT_DispBlanksAs::new(
  element : @xml.Element,
) -> CT_DispBlanksAs raise SchemaViolation {
  let val = match attr_value(element, "val") {
    Some(text) => Some(ST_DispBlanksAs::parse(text))
    None => None
  }
  { val, }
}

///|
/// Construct CT_Chart from a parsed chart element by walking the typed
/// children defined in dml-chart.xsd. `plotArea` is required; absence
/// raises `SchemaViolation`.
pub fn CT_Chart::new(element : @xml.Element) -> CT_Chart raise SchemaViolation {
  let title = match first_child_named(element, "title") {
    Some(child) => Some(CT_Title::new(child))
    None => None
  }
  let auto_title_deleted = match
    first_child_named(element, "autoTitleDeleted") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let pivot_fmts = match first_child_named(element, "pivotFmts") {
    Some(child) => Some(CT_PivotFmts::new(child))
    None => None
  }
  let view_3d = match first_child_named(element, "view3D") {
    Some(child) => Some(CT_View3D::new(child))
    None => None
  }
  let floor = match first_child_named(element, "floor") {
    Some(child) => Some(CT_Surface::new(child))
    None => None
  }
  let side_wall = match first_child_named(element, "sideWall") {
    Some(child) => Some(CT_Surface::new(child))
    None => None
  }
  let back_wall = match first_child_named(element, "backWall") {
    Some(child) => Some(CT_Surface::new(child))
    None => None
  }
  let plot_area_element = match first_child_named(element, "plotArea") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_Chart/plotArea",
        reason="required child missing",
      )
  }
  let plot_area = CT_PlotArea::new(plot_area_element)
  let legend = match first_child_named(element, "legend") {
    Some(child) => Some(CT_Legend::new(child))
    None => None
  }
  let plot_vis_only = match first_child_named(element, "plotVisOnly") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let disp_blanks_as = match first_child_named(element, "dispBlanksAs") {
    Some(child) => Some(CT_DispBlanksAs::new(child))
    None => None
  }
  let show_d_lbls_over_max = match
    first_child_named(element, "showDLblsOverMax") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    title,
    auto_title_deleted,
    pivot_fmts,
    view_3d,
    floor,
    side_wall,
    back_wall,
    plot_area,
    legend,
    plot_vis_only,
    disp_blanks_as,
    show_d_lbls_over_max,
    ext_lst,
  }
}

///|
/// Parse an element already selected for XSD complex type CT_Chart.
///
/// Schema dml-chart.xsd complex type `CT_Chart` has children title,
/// autoTitleDeleted, pivotFmts, view3D, floor, sideWall, backWall, plotArea,
/// legend, plotVisOnly, dispBlanksAs, showDLblsOverMax, and extLst.
pub fn parse_ct_chart_element(
  element : @xml.Element,
) -> CT_Chart raise SchemaViolation {
  CT_Chart::new(element)
}

///|
/// Return whether CT_Chart contains the required chart payload child plotArea.
/// Always `true` because `CT_Chart::new` enforces the required `plotArea`
/// child; the accessor exists for spec-conformance probes.
pub fn CT_Chart::has_plot_area(self : CT_Chart) -> Bool {
  let _ = self
  true
}

///|
/// XSD complex type CT_Style — Part 1 §21.2.2.196 (dml-chart.xsd) style.
/// Single required `val` attribute (ST_Style; chart style preset 1..48).
pub(all) struct CT_Style {
  /// @val (ST_Style) — required.
  val : ST_Style
} derive(Eq, Debug)

///|
pub fn CT_Style::new(element : @xml.Element) -> CT_Style raise SchemaViolation {
  let raw = match attr_value(element, "val") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_Style/@val",
        reason="required attribute missing",
      )
  }
  { val: ST_Style::parse(raw) }
}

///|
/// XSD complex type CT_PivotSource — Part 1 §21.2.2.144 (dml-chart.xsd)
/// pivotSource. Sequence: required `name` (s:ST_Xstring text) and `fmtId`,
/// then zero-or-more `extLst` (the XSD declares `maxOccurs="unbounded"` for
/// extLst here, unusual but explicit).
pub(all) struct CT_PivotSource {
  /// <name> (s:ST_Xstring) — required text payload.
  name : String
  /// <fmtId> (CT_UnsignedInt) — required.
  fmt_id : CT_UnsignedInt
  /// <extLst> (CT_ExtensionList) — zero or more (XSD `maxOccurs="unbounded"`).
  ext_lst : Array[CT_ExtensionList]
} derive(Eq, Debug)

///|
pub fn CT_PivotSource::new(
  element : @xml.Element,
) -> CT_PivotSource raise SchemaViolation {
  let name_element = match first_child_named(element, "name") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PivotSource/name",
        reason="required child missing",
      )
  }
  let name = element_text(name_element)
  let fmt_id_element = match first_child_named(element, "fmtId") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PivotSource/fmtId",
        reason="required child missing",
      )
  }
  let fmt_id = CT_UnsignedInt::new(fmt_id_element)
  let ext_lst = []
  for child in children_named(element, "extLst") {
    ext_lst.push(CT_ExtensionList::new(child))
  }
  { name, fmt_id, ext_lst }
}

///|
/// XSD complex type CT_Protection — Part 1 §21.2.2.156 (dml-chart.xsd)
/// protection. Sequence of five optional booleans: chartObject, data,
/// formatting, selection, userInterface.
pub(all) struct CT_Protection {
  /// <chartObject> (CT_Boolean) — optional.
  chart_object : CT_Boolean?
  /// <data> (CT_Boolean) — optional.
  data : CT_Boolean?
  /// <formatting> (CT_Boolean) — optional.
  formatting : CT_Boolean?
  /// <selection> (CT_Boolean) — optional.
  selection : CT_Boolean?
  /// <userInterface> (CT_Boolean) — optional.
  user_interface : CT_Boolean?
} derive(Eq, Debug)

///|
pub fn CT_Protection::new(
  element : @xml.Element,
) -> CT_Protection raise SchemaViolation {
  let chart_object = match first_child_named(element, "chartObject") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let data = match first_child_named(element, "data") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let formatting = match first_child_named(element, "formatting") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let selection = match first_child_named(element, "selection") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let user_interface = match first_child_named(element, "userInterface") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  { chart_object, data, formatting, selection, user_interface }
}

///|
/// XSD complex type CT_HeaderFooter — Part 1 §21.2.2.81 (dml-chart.xsd)
/// headerFooter. Attributes alignWithMargins (default true), differentOddEven
/// (default false), differentFirst (default false). Sequence: optional
/// oddHeader, oddFooter, evenHeader, evenFooter, firstHeader, firstFooter
/// (all s:ST_Xstring text payloads).
pub(all) struct CT_HeaderFooter {
  /// @alignWithMargins (xsd:boolean) — optional, schema default `true`.
  align_with_margins : Bool?
  /// @differentOddEven (xsd:boolean) — optional, schema default `false`.
  different_odd_even : Bool?
  /// @differentFirst (xsd:boolean) — optional, schema default `false`.
  different_first : Bool?
  /// <oddHeader> (s:ST_Xstring) — optional text payload.
  odd_header : String?
  /// <oddFooter> (s:ST_Xstring) — optional text payload.
  odd_footer : String?
  /// <evenHeader> (s:ST_Xstring) — optional text payload.
  even_header : String?
  /// <evenFooter> (s:ST_Xstring) — optional text payload.
  even_footer : String?
  /// <firstHeader> (s:ST_Xstring) — optional text payload.
  first_header : String?
  /// <firstFooter> (s:ST_Xstring) — optional text payload.
  first_footer : String?
} derive(Eq, Debug)

///|
pub fn CT_HeaderFooter::new(
  element : @xml.Element,
) -> CT_HeaderFooter raise SchemaViolation {
  let align_with_margins = match attr_value(element, "alignWithMargins") {
    Some(text) =>
      Some(parse_xsd_boolean("CT_HeaderFooter/@alignWithMargins", text))
    None => None
  }
  let different_odd_even = match attr_value(element, "differentOddEven") {
    Some(text) =>
      Some(parse_xsd_boolean("CT_HeaderFooter/@differentOddEven", text))
    None => None
  }
  let different_first = match attr_value(element, "differentFirst") {
    Some(text) =>
      Some(parse_xsd_boolean("CT_HeaderFooter/@differentFirst", text))
    None => None
  }
  let odd_header = first_child_named(element, "oddHeader").map(element_text)
  let odd_footer = first_child_named(element, "oddFooter").map(element_text)
  let even_header = first_child_named(element, "evenHeader").map(element_text)
  let even_footer = first_child_named(element, "evenFooter").map(element_text)
  let first_header = first_child_named(element, "firstHeader").map(element_text)
  let first_footer = first_child_named(element, "firstFooter").map(element_text)
  {
    align_with_margins,
    different_odd_even,
    different_first,
    odd_header,
    odd_footer,
    even_header,
    even_footer,
    first_header,
    first_footer,
  }
}

///|
/// XSD complex type CT_PageMargins — Part 1 §21.2.2.133 (dml-chart.xsd)
/// pageMargins. Six required xsd:double attributes: l, r, t, b, header, footer.
pub(all) struct CT_PageMargins {
  /// @l (xsd:double) — required, left margin.
  l : Double
  /// @r (xsd:double) — required, right margin.
  r : Double
  /// @t (xsd:double) — required, top margin.
  t : Double
  /// @b (xsd:double) — required, bottom margin.
  b : Double
  /// @header (xsd:double) — required, header margin.
  header : Double
  /// @footer (xsd:double) — required, footer margin.
  footer : Double
} derive(Eq, Debug)

///|
pub fn CT_PageMargins::new(
  element : @xml.Element,
) -> CT_PageMargins raise SchemaViolation {
  let l_raw = match attr_value(element, "l") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PageMargins/@l",
        reason="required attribute missing",
      )
  }
  let l = parse_xsd_double("CT_PageMargins/@l", l_raw)
  let r_raw = match attr_value(element, "r") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PageMargins/@r",
        reason="required attribute missing",
      )
  }
  let r = parse_xsd_double("CT_PageMargins/@r", r_raw)
  let t_raw = match attr_value(element, "t") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PageMargins/@t",
        reason="required attribute missing",
      )
  }
  let t = parse_xsd_double("CT_PageMargins/@t", t_raw)
  let b_raw = match attr_value(element, "b") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PageMargins/@b",
        reason="required attribute missing",
      )
  }
  let b = parse_xsd_double("CT_PageMargins/@b", b_raw)
  let header_raw = match attr_value(element, "header") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PageMargins/@header",
        reason="required attribute missing",
      )
  }
  let header = parse_xsd_double("CT_PageMargins/@header", header_raw)
  let footer_raw = match attr_value(element, "footer") {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_PageMargins/@footer",
        reason="required attribute missing",
      )
  }
  let footer = parse_xsd_double("CT_PageMargins/@footer", footer_raw)
  { l, r, t, b, header, footer }
}

///|
/// XSD complex type CT_ExternalData — Part 1 §21.2.2.64 (dml-chart.xsd)
/// externalData. Required `r:id` relationship attribute; optional `autoUpdate`
/// child boolean.
pub(all) struct CT_ExternalData {
  /// @r:id (`xmlns:r="http://purl.oclc.org/ooxml/officeDocument/relationships"`) — required.
  r_id : String
  /// <autoUpdate> (CT_Boolean) — optional.
  auto_update : CT_Boolean?
} derive(Eq, Debug)

///|
pub fn CT_ExternalData::new(
  element : @xml.Element,
) -> CT_ExternalData raise SchemaViolation {
  let ns = relationships_namespace()
  let raw = match attr_value_ns(element, ns, "id") {
    Some(v) => v
    None =>
      match attr_value(element, "id") {
        Some(v) => v
        None =>
          raise SchemaViolation(
            schema="dml-chart.xsd",
            path="CT_ExternalData/@r:id",
            reason="required attribute missing",
          )
      }
  }
  let auto_update = match first_child_named(element, "autoUpdate") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  { r_id: raw, auto_update }
}

///|
/// XSD complex type CT_PageSetup — Part 1 §21.2.2.134 (dml-chart.xsd)
/// pageSetup. Eleven optional attributes (no child elements). `paperHeight`
/// and `paperWidth` use the schema simple type
/// `s:ST_PositiveUniversalMeasure`; this package keeps them as raw lexical
/// strings to avoid pulling in the shared simple_types package from chunk1.
pub(all) struct CT_PageSetup {
  /// @paperSize (xsd:unsignedInt) — optional, schema default `1`.
  paper_size : Int64?
  /// @paperHeight (s:ST_PositiveUniversalMeasure) — optional, raw lexical.
  paper_height : String?
  /// @paperWidth (s:ST_PositiveUniversalMeasure) — optional, raw lexical.
  paper_width : String?
  /// @firstPageNumber (xsd:unsignedInt) — optional, schema default `1`.
  first_page_number : Int64?
  /// @orientation (ST_PageSetupOrientation) — optional, schema default `default`.
  orientation : ST_PageSetupOrientation?
  /// @blackAndWhite (xsd:boolean) — optional, schema default `false`.
  black_and_white : Bool?
  /// @draft (xsd:boolean) — optional, schema default `false`.
  draft : Bool?
  /// @useFirstPageNumber (xsd:boolean) — optional, schema default `false`.
  use_first_page_number : Bool?
  /// @horizontalDpi (xsd:int) — optional, schema default `600`.
  horizontal_dpi : Int?
  /// @verticalDpi (xsd:int) — optional, schema default `600`.
  vertical_dpi : Int?
  /// @copies (xsd:unsignedInt) — optional, schema default `1`.
  copies : Int64?
} derive(Eq, Debug)

///|
pub fn CT_PageSetup::new(
  element : @xml.Element,
) -> CT_PageSetup raise SchemaViolation {
  let paper_size = match attr_value(element, "paperSize") {
    Some(text) => Some(parse_xsd_unsigned_int("CT_PageSetup/@paperSize", text))
    None => None
  }
  let paper_height = attr_value(element, "paperHeight")
  let paper_width = attr_value(element, "paperWidth")
  let first_page_number = match attr_value(element, "firstPageNumber") {
    Some(text) =>
      Some(parse_xsd_unsigned_int("CT_PageSetup/@firstPageNumber", text))
    None => None
  }
  let orientation = match attr_value(element, "orientation") {
    Some(text) => Some(ST_PageSetupOrientation::parse(text))
    None => None
  }
  let black_and_white = match attr_value(element, "blackAndWhite") {
    Some(text) => Some(parse_xsd_boolean("CT_PageSetup/@blackAndWhite", text))
    None => None
  }
  let draft = match attr_value(element, "draft") {
    Some(text) => Some(parse_xsd_boolean("CT_PageSetup/@draft", text))
    None => None
  }
  let use_first_page_number = match attr_value(element, "useFirstPageNumber") {
    Some(text) =>
      Some(parse_xsd_boolean("CT_PageSetup/@useFirstPageNumber", text))
    None => None
  }
  let horizontal_dpi = match attr_value(element, "horizontalDpi") {
    Some(text) => Some(parse_xsd_int("CT_PageSetup/@horizontalDpi", text))
    None => None
  }
  let vertical_dpi = match attr_value(element, "verticalDpi") {
    Some(text) => Some(parse_xsd_int("CT_PageSetup/@verticalDpi", text))
    None => None
  }
  let copies = match attr_value(element, "copies") {
    Some(text) => Some(parse_xsd_unsigned_int("CT_PageSetup/@copies", text))
    None => None
  }
  {
    paper_size,
    paper_height,
    paper_width,
    first_page_number,
    orientation,
    black_and_white,
    draft,
    use_first_page_number,
    horizontal_dpi,
    vertical_dpi,
    copies,
  }
}

///|
/// XSD complex type CT_PrintSettings — Part 1 §21.2.2.155 (dml-chart.xsd)
/// printSettings. Sequence of three optional children: headerFooter,
/// pageMargins, pageSetup.
pub(all) struct CT_PrintSettings {
  /// <headerFooter> (CT_HeaderFooter) — optional.
  header_footer : CT_HeaderFooter?
  /// <pageMargins> (CT_PageMargins) — optional.
  page_margins : CT_PageMargins?
  /// <pageSetup> (CT_PageSetup) — optional.
  page_setup : CT_PageSetup?
} derive(Eq, Debug)

///|
pub fn CT_PrintSettings::new(
  element : @xml.Element,
) -> CT_PrintSettings raise SchemaViolation {
  let header_footer = match first_child_named(element, "headerFooter") {
    Some(child) => Some(CT_HeaderFooter::new(child))
    None => None
  }
  let page_margins = match first_child_named(element, "pageMargins") {
    Some(child) => Some(CT_PageMargins::new(child))
    None => None
  }
  let page_setup = match first_child_named(element, "pageSetup") {
    Some(child) => Some(CT_PageSetup::new(child))
    None => None
  }
  { header_footer, page_margins, page_setup }
}

///|
/// XSD complex type CT_ChartSpace — Part 1 §21.2.2.29 (dml-chart.xsd)
/// chartSpace. Sequence: optional date1904, lang, roundedCorners, style,
/// clrMapOvr (a:CT_ColorMapping, raw), pivotSource, protection, then required
/// chart, then optional spPr, txPr, externalData, printSettings,
/// userShapes (CT_RelId), extLst.
pub(all) struct CT_ChartSpace {
  /// <date1904> (CT_Boolean) — optional.
  date_1904 : CT_Boolean?
  /// <lang> (CT_TextLanguageID) — optional.
  lang : CT_TextLanguageID?
  /// <roundedCorners> (CT_Boolean) — optional.
  rounded_corners : CT_Boolean?
  /// <style> (CT_Style) — optional.
  style : CT_Style?
  /// <clrMapOvr> (a:CT_ColorMapping) preserved as raw element.
  clr_map_ovr : @xml.Element?
  /// <pivotSource> (CT_PivotSource) — optional.
  pivot_source : CT_PivotSource?
  /// <protection> (CT_Protection) — optional.
  protection : CT_Protection?
  /// <chart> (CT_Chart) — required.
  chart : CT_Chart
  /// <spPr> (a:CT_ShapeProperties) preserved as raw element.
  sp_pr : @xml.Element?
  /// <txPr> (a:CT_TextBody) preserved as raw element.
  tx_pr : @xml.Element?
  /// <externalData> (CT_ExternalData) — optional.
  external_data : CT_ExternalData?
  /// <printSettings> (CT_PrintSettings) — optional.
  print_settings : CT_PrintSettings?
  /// <userShapes> (CT_RelId) — optional.
  user_shapes : CT_RelId?
  /// <extLst> (CT_ExtensionList) — optional.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_ChartSpace::new(
  element : @xml.Element,
) -> CT_ChartSpace raise SchemaViolation {
  let date_1904 = match first_child_named(element, "date1904") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let lang = match first_child_named(element, "lang") {
    Some(child) => Some(CT_TextLanguageID::new(child))
    None => None
  }
  let rounded_corners = match first_child_named(element, "roundedCorners") {
    Some(child) => Some(CT_Boolean::new(child))
    None => None
  }
  let style = match first_child_named(element, "style") {
    Some(child) => Some(CT_Style::new(child))
    None => None
  }
  let clr_map_ovr = first_child_named(element, "clrMapOvr")
  let pivot_source = match first_child_named(element, "pivotSource") {
    Some(child) => Some(CT_PivotSource::new(child))
    None => None
  }
  let protection = match first_child_named(element, "protection") {
    Some(child) => Some(CT_Protection::new(child))
    None => None
  }
  let chart_element = match first_child_named(element, "chart") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chart.xsd",
        path="CT_ChartSpace/chart",
        reason="required child missing",
      )
  }
  let chart = CT_Chart::new(chart_element)
  let sp_pr = first_child_named(element, "spPr")
  let tx_pr = first_child_named(element, "txPr")
  let external_data = match first_child_named(element, "externalData") {
    Some(child) => Some(CT_ExternalData::new(child))
    None => None
  }
  let print_settings = match first_child_named(element, "printSettings") {
    Some(child) => Some(CT_PrintSettings::new(child))
    None => None
  }
  let user_shapes = match first_child_named(element, "userShapes") {
    Some(child) => Some(CT_RelId::new(child))
    None => None
  }
  let ext_lst = first_child_named(element, "extLst").map(CT_ExtensionList::new)
  {
    date_1904,
    lang,
    rounded_corners,
    style,
    clr_map_ovr,
    pivot_source,
    protection,
    chart,
    sp_pr,
    tx_pr,
    external_data,
    print_settings,
    user_shapes,
    ext_lst,
  }
}

///|
/// XSD complex type CT_ShapeNonVisual — Part 1 §21.3.2.10 (dml-chartDrawing.xsd)
/// nvSpPr. Sequence of two required drawingml/main elements; both preserved as
/// raw `@xml.Element` since cross-package typing of `a:CT_NonVisualDrawingProps`
/// / `a:CT_NonVisualDrawingShapeProps` is out of scope here.
pub(all) struct CT_ShapeNonVisual {
  /// <cNvPr> (a:CT_NonVisualDrawingProps) — required, preserved as raw element.
  c_nv_pr : @xml.Element
  /// <cNvSpPr> (a:CT_NonVisualDrawingShapeProps) — required, preserved as raw element.
  c_nv_sp_pr : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeNonVisual::new(
  element : @xml.Element,
) -> CT_ShapeNonVisual raise SchemaViolation {
  let c_nv_pr = match first_child_named(element, "cNvPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_ShapeNonVisual/cNvPr",
        reason="required child missing",
      )
  }
  let c_nv_sp_pr = match first_child_named(element, "cNvSpPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_ShapeNonVisual/cNvSpPr",
        reason="required child missing",
      )
  }
  { c_nv_pr, c_nv_sp_pr }
}

///|
/// XSD complex type CT_Shape is also present in dml-chartDrawing.xsd (§21.3); this shared holder captures the parsed element for both schema bundles.

///|
/// XSD complex type CT_ConnectorNonVisual — Part 1 §21.3.2.7 (dml-chartDrawing.xsd)
/// nvCxnSpPr. Sequence of two required drawingml/main elements preserved raw.
pub(all) struct CT_ConnectorNonVisual {
  /// <cNvPr> (a:CT_NonVisualDrawingProps) — required, preserved as raw element.
  c_nv_pr : @xml.Element
  /// <cNvCxnSpPr> (a:CT_NonVisualConnectorProperties) — required, preserved as raw element.
  c_nv_cxn_sp_pr : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConnectorNonVisual::new(
  element : @xml.Element,
) -> CT_ConnectorNonVisual raise SchemaViolation {
  let c_nv_pr = match first_child_named(element, "cNvPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_ConnectorNonVisual/cNvPr",
        reason="required child missing",
      )
  }
  let c_nv_cxn_sp_pr = match first_child_named(element, "cNvCxnSpPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_ConnectorNonVisual/cNvCxnSpPr",
        reason="required child missing",
      )
  }
  { c_nv_pr, c_nv_cxn_sp_pr }
}

///|
/// XSD complex type CT_Connector — Part 1 §21.3.2.3 (dml-chartDrawing.xsd)
/// cxnSp. Sequence: required nvCxnSpPr, required spPr (raw), optional style
/// (raw). Optional `macro` and `fPublished` attributes (`fPublished` default
/// `false`).
pub(all) struct CT_Connector {
  /// @macro (xsd:string) — optional.
  macro_ : String?
  /// @fPublished (xsd:boolean) — optional, schema default `false`.
  f_published : Bool?
  /// <nvCxnSpPr> (CT_ConnectorNonVisual) — required.
  nv_cxn_sp_pr : CT_ConnectorNonVisual
  /// <spPr> (a:CT_ShapeProperties) — required, preserved as raw element.
  sp_pr : @xml.Element
  /// <style> (a:CT_ShapeStyle) — optional, preserved as raw element.
  style : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_Connector::new(
  element : @xml.Element,
) -> CT_Connector raise SchemaViolation {
  let macro_ = attr_value(element, "macro")
  let f_published = match attr_value(element, "fPublished") {
    Some(text) => Some(parse_xsd_boolean("CT_Connector/@fPublished", text))
    None => None
  }
  let nv_cxn_sp_pr_element = match first_child_named(element, "nvCxnSpPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_Connector/nvCxnSpPr",
        reason="required child missing",
      )
  }
  let nv_cxn_sp_pr = CT_ConnectorNonVisual::new(nv_cxn_sp_pr_element)
  let sp_pr = match first_child_named(element, "spPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_Connector/spPr",
        reason="required child missing",
      )
  }
  let style = first_child_named(element, "style")
  { macro_, f_published, nv_cxn_sp_pr, sp_pr, style }
}

///|
/// XSD complex type CT_PictureNonVisual — Part 1 §21.3.2.8 (dml-chartDrawing.xsd)
/// nvPicPr. Sequence of two required drawingml/main elements preserved raw.
pub(all) struct CT_PictureNonVisual {
  /// <cNvPr> (a:CT_NonVisualDrawingProps) — required, preserved as raw element.
  c_nv_pr : @xml.Element
  /// <cNvPicPr> (a:CT_NonVisualPictureProperties) — required, preserved as raw element.
  c_nv_pic_pr : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PictureNonVisual::new(
  element : @xml.Element,
) -> CT_PictureNonVisual raise SchemaViolation {
  let c_nv_pr = match first_child_named(element, "cNvPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_PictureNonVisual/cNvPr",
        reason="required child missing",
      )
  }
  let c_nv_pic_pr = match first_child_named(element, "cNvPicPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_PictureNonVisual/cNvPicPr",
        reason="required child missing",
      )
  }
  { c_nv_pr, c_nv_pic_pr }
}

///|
/// XSD complex type CT_Picture — Part 1 §21.3.2.11 (dml-chartDrawing.xsd)
/// pic. Sequence: required nvPicPr, required blipFill (raw), required spPr
/// (raw), optional style (raw). Optional `macro` (default empty string) and
/// `fPublished` (default `false`) attributes.
pub(all) struct CT_Picture {
  /// @macro (xsd:string) — optional, schema default `""`.
  macro_ : String?
  /// @fPublished (xsd:boolean) — optional, schema default `false`.
  f_published : Bool?
  /// <nvPicPr> (CT_PictureNonVisual) — required.
  nv_pic_pr : CT_PictureNonVisual
  /// <blipFill> (a:CT_BlipFillProperties) — required, preserved as raw element.
  blip_fill : @xml.Element
  /// <spPr> (a:CT_ShapeProperties) — required, preserved as raw element.
  sp_pr : @xml.Element
  /// <style> (a:CT_ShapeStyle) — optional, preserved as raw element.
  style : @xml.Element?
} derive(Eq, Debug)

///|
pub fn CT_Picture::new(
  element : @xml.Element,
) -> CT_Picture raise SchemaViolation {
  let macro_ = attr_value(element, "macro")
  let f_published = match attr_value(element, "fPublished") {
    Some(text) => Some(parse_xsd_boolean("CT_Picture/@fPublished", text))
    None => None
  }
  let nv_pic_pr_element = match first_child_named(element, "nvPicPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_Picture/nvPicPr",
        reason="required child missing",
      )
  }
  let nv_pic_pr = CT_PictureNonVisual::new(nv_pic_pr_element)
  let blip_fill = match first_child_named(element, "blipFill") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_Picture/blipFill",
        reason="required child missing",
      )
  }
  let sp_pr = match first_child_named(element, "spPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_Picture/spPr",
        reason="required child missing",
      )
  }
  let style = first_child_named(element, "style")
  { macro_, f_published, nv_pic_pr, blip_fill, sp_pr, style }
}

///|
/// XSD complex type CT_GraphicFrameNonVisual — Part 1 §21.3.2.6
/// (dml-chartDrawing.xsd) nvGraphicFramePr. Sequence of two required
/// drawingml/main elements preserved raw.
pub(all) struct CT_GraphicFrameNonVisual {
  /// <cNvPr> (a:CT_NonVisualDrawingProps) — required, preserved as raw element.
  c_nv_pr : @xml.Element
  /// <cNvGraphicFramePr> (a:CT_NonVisualGraphicFrameProperties) — required, preserved as raw element.
  c_nv_graphic_frame_pr : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicFrameNonVisual::new(
  element : @xml.Element,
) -> CT_GraphicFrameNonVisual raise SchemaViolation {
  let c_nv_pr = match first_child_named(element, "cNvPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_GraphicFrameNonVisual/cNvPr",
        reason="required child missing",
      )
  }
  let c_nv_graphic_frame_pr = match
    first_child_named(element, "cNvGraphicFramePr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_GraphicFrameNonVisual/cNvGraphicFramePr",
        reason="required child missing",
      )
  }
  { c_nv_pr, c_nv_graphic_frame_pr }
}

///|
/// XSD complex type CT_GraphicFrame — Part 1 §21.3.2.5 (dml-chartDrawing.xsd)
/// graphicFrame. Sequence: required nvGraphicFramePr, required xfrm (raw),
/// required a:graphic (raw). Optional `macro` and `fPublished` (default
/// `false`) attributes.
pub(all) struct CT_GraphicFrame {
  /// @macro (xsd:string) — optional.
  macro_ : String?
  /// @fPublished (xsd:boolean) — optional, schema default `false`.
  f_published : Bool?
  /// <nvGraphicFramePr> (CT_GraphicFrameNonVisual) — required.
  nv_graphic_frame_pr : CT_GraphicFrameNonVisual
  /// <xfrm> (a:CT_Transform2D) — required, preserved as raw element.
  xfrm : @xml.Element
  /// <a:graphic> (a:CT_GraphicalObject ref) — required, preserved as raw element.
  graphic : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicFrame::new(
  element : @xml.Element,
) -> CT_GraphicFrame raise SchemaViolation {
  let macro_ = attr_value(element, "macro")
  let f_published = match attr_value(element, "fPublished") {
    Some(text) => Some(parse_xsd_boolean("CT_GraphicFrame/@fPublished", text))
    None => None
  }
  let nv_graphic_frame_pr_element = match
    first_child_named(element, "nvGraphicFramePr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_GraphicFrame/nvGraphicFramePr",
        reason="required child missing",
      )
  }
  let nv_graphic_frame_pr = CT_GraphicFrameNonVisual::new(
    nv_graphic_frame_pr_element,
  )
  let xfrm = match first_child_named(element, "xfrm") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_GraphicFrame/xfrm",
        reason="required child missing",
      )
  }
  let graphic = match first_child_named(element, "graphic") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_GraphicFrame/a:graphic",
        reason="required child missing",
      )
  }
  { macro_, f_published, nv_graphic_frame_pr, xfrm, graphic }
}

///|
/// XSD complex type CT_GroupShapeNonVisual — Part 1 §21.3.2.9 (dml-chartDrawing.xsd)
/// nvGrpSpPr. Sequence of two required drawingml/main elements preserved raw.
pub(all) struct CT_GroupShapeNonVisual {
  /// <cNvPr> (a:CT_NonVisualDrawingProps) — required, preserved as raw element.
  c_nv_pr : @xml.Element
  /// <cNvGrpSpPr> (a:CT_NonVisualGroupDrawingShapeProps) — required, preserved as raw element.
  c_nv_grp_sp_pr : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupShapeNonVisual::new(
  element : @xml.Element,
) -> CT_GroupShapeNonVisual raise SchemaViolation {
  let c_nv_pr = match first_child_named(element, "cNvPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_GroupShapeNonVisual/cNvPr",
        reason="required child missing",
      )
  }
  let c_nv_grp_sp_pr = match first_child_named(element, "cNvGrpSpPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_GroupShapeNonVisual/cNvGrpSpPr",
        reason="required child missing",
      )
  }
  { c_nv_pr, c_nv_grp_sp_pr }
}

///|
/// XSD complex type CT_GroupShape — Part 1 §21.3.2.4 (dml-chartDrawing.xsd)
/// grpSp. Sequence: required nvGrpSpPr, required grpSpPr (raw), then an
/// unbounded `<xsd:choice>` of sp / grpSp / graphicFrame / cxnSp / pic. `sp`
/// (CT_Shape) is a chunk3 wrapper preserved as raw element; `grpSp`
/// (CT_GroupShape) is recursively typed.
pub(all) struct CT_GroupShape {
  /// <nvGrpSpPr> (CT_GroupShapeNonVisual) — required.
  nv_grp_sp_pr : CT_GroupShapeNonVisual
  /// <grpSpPr> (a:CT_GroupShapeProperties) — required, preserved as raw element.
  grp_sp_pr : @xml.Element
  /// <sp> (CT_Shape, chunk3 wrapper) zero-or-more, preserved as raw element.
  sp : Array[@xml.Element]
  /// <grpSp> (CT_GroupShape) zero-or-more, recursively typed.
  grp_sp : Array[CT_GroupShape]
  /// <graphicFrame> (CT_GraphicFrame) zero-or-more.
  graphic_frame : Array[CT_GraphicFrame]
  /// <cxnSp> (CT_Connector) zero-or-more.
  cxn_sp : Array[CT_Connector]
  /// <pic> (CT_Picture) zero-or-more.
  pic : Array[CT_Picture]
} derive(Eq, Debug)

///|
pub fn CT_GroupShape::new(
  element : @xml.Element,
) -> CT_GroupShape raise SchemaViolation {
  let nv_grp_sp_pr_element = match first_child_named(element, "nvGrpSpPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_GroupShape/nvGrpSpPr",
        reason="required child missing",
      )
  }
  let nv_grp_sp_pr = CT_GroupShapeNonVisual::new(nv_grp_sp_pr_element)
  let grp_sp_pr = match first_child_named(element, "grpSpPr") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_GroupShape/grpSpPr",
        reason="required child missing",
      )
  }
  let sp = children_named(element, "sp")
  let grp_sp = []
  for child in children_named(element, "grpSp") {
    grp_sp.push(CT_GroupShape::new(child))
  }
  let graphic_frame = []
  for child in children_named(element, "graphicFrame") {
    graphic_frame.push(CT_GraphicFrame::new(child))
  }
  let cxn_sp = []
  for child in children_named(element, "cxnSp") {
    cxn_sp.push(CT_Connector::new(child))
  }
  let pic = []
  for child in children_named(element, "pic") {
    pic.push(CT_Picture::new(child))
  }
  { nv_grp_sp_pr, grp_sp_pr, sp, grp_sp, graphic_frame, cxn_sp, pic }
}

///|
/// XSD complex type CT_Marker is also present in dml-chartDrawing.xsd (§21.3); this shared holder captures the parsed element for both schema bundles.

///|
/// XSD complex type CT_RelSizeAnchor — Part 1 §21.3.2.18
/// (dml-chartDrawing.xsd) relSizeAnchor. Sequence: required `from` and `to`
/// markers, followed by the EG_ObjectChoices group (a required choice of one
/// sp / grpSp / graphicFrame / cxnSp / pic). The two markers reuse the
/// chartDrawing-flavoured CT_Marker which is still a chunk3 wrapper holding
/// `x`/`y` ST_MarkerCoordinate children — preserved as raw `@xml.Element`.
pub(all) struct CT_RelSizeAnchor {
  /// <from> (CT_Marker, chartDrawing) — required, preserved as raw element.
  from_ : @xml.Element
  /// <to> (CT_Marker, chartDrawing) — required, preserved as raw element.
  to_ : @xml.Element
  /// <sp> (CT_Shape, chunk3) — choice branch, preserved as raw element.
  sp : @xml.Element?
  /// <grpSp> (CT_GroupShape) — choice branch.
  grp_sp : CT_GroupShape?
  /// <graphicFrame> (CT_GraphicFrame) — choice branch.
  graphic_frame : CT_GraphicFrame?
  /// <cxnSp> (CT_Connector) — choice branch.
  cxn_sp : CT_Connector?
  /// <pic> (CT_Picture) — choice branch.
  pic : CT_Picture?
} derive(Eq, Debug)

///|
pub fn CT_RelSizeAnchor::new(
  element : @xml.Element,
) -> CT_RelSizeAnchor raise SchemaViolation {
  let from_ = match first_child_named(element, "from") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_RelSizeAnchor/from",
        reason="required child missing",
      )
  }
  let to_ = match first_child_named(element, "to") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_RelSizeAnchor/to",
        reason="required child missing",
      )
  }
  let sp = first_child_named(element, "sp")
  let grp_sp = match first_child_named(element, "grpSp") {
    Some(child) => Some(CT_GroupShape::new(child))
    None => None
  }
  let graphic_frame = match first_child_named(element, "graphicFrame") {
    Some(child) => Some(CT_GraphicFrame::new(child))
    None => None
  }
  let cxn_sp = match first_child_named(element, "cxnSp") {
    Some(child) => Some(CT_Connector::new(child))
    None => None
  }
  let pic = match first_child_named(element, "pic") {
    Some(child) => Some(CT_Picture::new(child))
    None => None
  }
  { from_, to_, sp, grp_sp, graphic_frame, cxn_sp, pic }
}

///|
/// XSD complex type CT_AbsSizeAnchor — Part 1 §21.3.2.1 (dml-chartDrawing.xsd)
/// absSizeAnchor. Sequence: required `from` marker, required `ext`
/// (a:CT_PositiveSize2D raw), followed by the EG_ObjectChoices choice.
pub(all) struct CT_AbsSizeAnchor {
  /// <from> (CT_Marker, chartDrawing) — required, preserved as raw element.
  from_ : @xml.Element
  /// <ext> (a:CT_PositiveSize2D) — required, preserved as raw element.
  ext : @xml.Element
  /// <sp> (CT_Shape, chunk3) — choice branch, preserved as raw element.
  sp : @xml.Element?
  /// <grpSp> (CT_GroupShape) — choice branch.
  grp_sp : CT_GroupShape?
  /// <graphicFrame> (CT_GraphicFrame) — choice branch.
  graphic_frame : CT_GraphicFrame?
  /// <cxnSp> (CT_Connector) — choice branch.
  cxn_sp : CT_Connector?
  /// <pic> (CT_Picture) — choice branch.
  pic : CT_Picture?
} derive(Eq, Debug)

///|
pub fn CT_AbsSizeAnchor::new(
  element : @xml.Element,
) -> CT_AbsSizeAnchor raise SchemaViolation {
  let from_ = match first_child_named(element, "from") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_AbsSizeAnchor/from",
        reason="required child missing",
      )
  }
  let ext = match first_child_named(element, "ext") {
    Some(child) => child
    None =>
      raise SchemaViolation(
        schema="dml-chartDrawing.xsd",
        path="CT_AbsSizeAnchor/ext",
        reason="required child missing",
      )
  }
  let sp = first_child_named(element, "sp")
  let grp_sp = match first_child_named(element, "grpSp") {
    Some(child) => Some(CT_GroupShape::new(child))
    None => None
  }
  let graphic_frame = match first_child_named(element, "graphicFrame") {
    Some(child) => Some(CT_GraphicFrame::new(child))
    None => None
  }
  let cxn_sp = match first_child_named(element, "cxnSp") {
    Some(child) => Some(CT_Connector::new(child))
    None => None
  }
  let pic = match first_child_named(element, "pic") {
    Some(child) => Some(CT_Picture::new(child))
    None => None
  }
  { from_, ext, sp, grp_sp, graphic_frame, cxn_sp, pic }
}

///|
/// XSD complex type CT_Drawing — Part 1 §21.3.2.2 (dml-chartDrawing.xsd) the
/// `userShapes` payload. Sequence is an EG_Anchor group (choice of
/// `relSizeAnchor` or `absSizeAnchor`) repeated zero-or-more times. Anchor
/// occurrences preserve document order in `anchors`.
pub(all) struct CT_Drawing {
  /// <relSizeAnchor> (CT_RelSizeAnchor) zero-or-more.
  rel_size_anchor : Array[CT_RelSizeAnchor]
  /// <absSizeAnchor> (CT_AbsSizeAnchor) zero-or-more.
  abs_size_anchor : Array[CT_AbsSizeAnchor]
} derive(Eq, Debug)

///|
pub fn CT_Drawing::new(
  element : @xml.Element,
) -> CT_Drawing raise SchemaViolation {
  let rel_size_anchor = []
  for child in children_named(element, "relSizeAnchor") {
    rel_size_anchor.push(CT_RelSizeAnchor::new(child))
  }
  let abs_size_anchor = []
  for child in children_named(element, "absSizeAnchor") {
    abs_size_anchor.push(CT_AbsSizeAnchor::new(child))
  }
  { rel_size_anchor, abs_size_anchor }
}

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
