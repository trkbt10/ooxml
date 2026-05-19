// =============================================================================
// XSD complex types CT_*Transition* / CT_TL* / CT_BuildList / CT_SlideTiming —
// Part 1 §19.5 (PresentationML Animation) and §19.5.50 slide transitions.
//
// These were previously element-only wrappers. Each has been promoted to
// a typed struct mirroring its XSD shape (attribute / child element list)
// exactly. `element_name` preserves the source QName so the writer can
// round-trip the canonical `<p:foo/>` element regardless of which schema
// element-name slot the type is bound into (e.g. CT_OrientationTransition
// backs <p:blinds>, <p:checker>, <p:comb>, and <p:randomBar> per §19.5.50).
// =============================================================================

// === Local helpers ========================================================

///|
/// First-attribute lookup by local name. PresentationML attributes use
/// the no-namespace `attributeForm` per pml.xsd, so local-name match
/// suffices for every CT_* in this file.
fn ttt_attr(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
/// First element child whose local name equals `local_name`. The
/// PresentationML reader leaves elements in document order, so this
/// matches the XSD `xsd:choice`/`xsd:sequence` "first of name" semantics.
fn ttt_first_child(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Element(e) => if e.name.local_name == local_name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
/// All direct element children whose local name equals `local_name`,
/// in document order. Used for `maxOccurs="unbounded"` lists.
fn ttt_children(
  element : @xml.Element,
  local_name : String,
) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => if e.name.local_name == local_name { out.push(e) }
      _ => ()
    }
  }
  out
}

///|
/// Decode an xsd:boolean attribute value. xsd:boolean lexical space is
/// `true|false|1|0` per W3C XML Schema Part 2 §3.2.2.
fn ttt_parse_bool(s : String) -> Bool? {
  match s {
    "true" => Some(true)
    "1" => Some(true)
    "false" => Some(false)
    "0" => Some(false)
    _ => None
  }
}

///|
/// Decode xsd:int. ASCII decimal with optional leading sign.
fn ttt_parse_int(s : String) -> Int? {
  if s.length() == 0 {
    return None
  }
  let (sign, start) = if s.code_unit_at(0).to_int() == 0x2D {
    (-1, 1)
  } else if s.code_unit_at(0).to_int() == 0x2B {
    (1, 1)
  } else {
    (1, 0)
  }
  if start >= s.length() {
    return None
  }
  let mut value : Int = 0
  for i in start..<s.length() {
    let unit = s.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10 + (unit - 0x30)
  }
  Some(value * sign)
}

///|
/// Decode xsd:float. Delegates to `@strconv.from_str` since PML float
/// attributes use the canonical decimal form.
fn ttt_parse_float(s : String) -> Double? {
  try {
    let value : Double = @strconv.from_str(s)
    Some(value)
  } catch {
    _ => None
  }
}

///|
/// Build a no-namespace QName. Used by `to_element` defaults when the
/// caller did not preserve the source-element QName.
fn ttt_qname(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
/// Build an XML attribute with a no-namespace local name. PresentationML
/// attribute forms are unqualified in pml.xsd.
fn ttt_attribute(local_name : String, value : String) -> @xml.Attribute {
  { name: ttt_qname(local_name), value }
}

// === §19.5.50 Slide-transition direction wrappers =========================
//
// Eight CT_*Transition wrappers share the same shape (one `dir` /
// `thruBlk` / `spokes` / `orient` attribute). They are distinct typed
// structs because their attribute domains differ (side vs corner vs
// eight-direction vs orientation vs in-out vs boolean vs unsignedInt).

///|
/// XSD complex type CT_SideDirectionTransition — Part 1 §19.5.51 push
/// (Push Slide Transition) and §19.5.55 wipe. Carries the optional
/// `@dir` attribute taken from §19.7.53 ST_TransitionSideDirectionType
/// with schema default `"l"`.
pub(all) struct CT_SideDirectionTransition {
  /// §19.5.51 @dir (ST_TransitionSideDirectionType §19.7.53);
  /// `None` ⇔ attribute absent, schema default is `SideL`.
  dir : ST_TransitionSideDirectionType?
  /// Element-name slot the instance occupies (push / wipe). Preserved
  /// so `to_element` round-trips the original tag.
  element_name : @xml.QName
} derive(Eq, Debug)

///|
/// Part 1 §19.5.51 — decode a `<push>` / `<wipe>` element into a typed
/// `CT_SideDirectionTransition`.
pub fn CT_SideDirectionTransition::from_element(
  element : @xml.Element,
) -> CT_SideDirectionTransition raise SchemaViolation {
  let dir = match ttt_attr(element, "dir") {
    Some(text) => Some(ST_TransitionSideDirectionType::parse(text))
    None => None
  }
  { dir, element_name: element.name }
}

///|
pub fn CT_SideDirectionTransition::new(
  element : @xml.Element,
) -> CT_SideDirectionTransition {
  CT_SideDirectionTransition::from_element(element) catch {
    _ => { dir: None, element_name: element.name }
  }
}

///|
pub fn CT_SideDirectionTransition::parse(
  element : @xml.Element,
) -> CT_SideDirectionTransition {
  CT_SideDirectionTransition::new(element)
}

///|
pub fn CT_SideDirectionTransition::to_element(
  self : CT_SideDirectionTransition,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.dir {
    Some(d) => attrs.push(ttt_attribute("dir", d.to_string()))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

///|
/// XSD complex type CT_CornerDirectionTransition — Part 1 §19.5.54
/// strips. Carries the optional `@dir` attribute from §19.7.50
/// ST_TransitionCornerDirectionType with schema default `"lu"`.
pub(all) struct CT_CornerDirectionTransition {
  /// §19.5.54 @dir (ST_TransitionCornerDirectionType §19.7.50);
  /// `None` ⇔ attribute absent, schema default is `CornerLu`.
  dir : ST_TransitionCornerDirectionType?
  /// Source element QName for round-trip (always `<p:strips>` in pml.xsd).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_CornerDirectionTransition::from_element(
  element : @xml.Element,
) -> CT_CornerDirectionTransition raise SchemaViolation {
  let dir = match ttt_attr(element, "dir") {
    Some(text) => Some(ST_TransitionCornerDirectionType::parse(text))
    None => None
  }
  { dir, element_name: element.name }
}

///|
pub fn CT_CornerDirectionTransition::new(
  element : @xml.Element,
) -> CT_CornerDirectionTransition {
  CT_CornerDirectionTransition::from_element(element) catch {
    _ => { dir: None, element_name: element.name }
  }
}

///|
pub fn CT_CornerDirectionTransition::parse(
  element : @xml.Element,
) -> CT_CornerDirectionTransition {
  CT_CornerDirectionTransition::new(element)
}

///|
pub fn CT_CornerDirectionTransition::to_element(
  self : CT_CornerDirectionTransition,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.dir {
    Some(d) => attrs.push(ttt_attribute("dir", d.to_string()))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

///|
/// XSD complex type CT_EightDirectionTransition — Part 1 §19.5.50 cover
/// and §19.5.50 pull. Carries the optional `@dir` attribute drawn from
/// the §19.7.51 union ST_TransitionEightDirectionType (corner ∪ side);
/// schema default `"l"`.
pub(all) struct CT_EightDirectionTransition {
  /// §19.5.50 @dir (ST_TransitionEightDirectionType §19.7.51).
  dir : ST_TransitionEightDirectionType?
  /// Source element QName (`<p:cover>` / `<p:pull>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_EightDirectionTransition::from_element(
  element : @xml.Element,
) -> CT_EightDirectionTransition raise SchemaViolation {
  let dir = match ttt_attr(element, "dir") {
    Some(text) => Some(ST_TransitionEightDirectionType::parse(text))
    None => None
  }
  { dir, element_name: element.name }
}

///|
pub fn CT_EightDirectionTransition::new(
  element : @xml.Element,
) -> CT_EightDirectionTransition {
  CT_EightDirectionTransition::from_element(element) catch {
    _ => { dir: None, element_name: element.name }
  }
}

///|
pub fn CT_EightDirectionTransition::parse(
  element : @xml.Element,
) -> CT_EightDirectionTransition {
  CT_EightDirectionTransition::new(element)
}

///|
pub fn CT_EightDirectionTransition::to_element(
  self : CT_EightDirectionTransition,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.dir {
    Some(d) => attrs.push(ttt_attribute("dir", d.to_string()))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

///|
/// XSD complex type CT_OrientationTransition — Part 1 §19.5.50 blinds,
/// §19.5.50 checker, §19.5.50 comb, §19.5.50 randomBar. Carries the
/// optional `@dir` attribute drawn from §19.7.2 ST_Direction (horz /
/// vert); schema default `"horz"`.
pub(all) struct CT_OrientationTransition {
  /// §19.5.50 @dir (ST_Direction §19.7.2).
  dir : ST_Direction?
  /// Source element QName (`<p:blinds>` / `<p:checker>` / `<p:comb>` /
  /// `<p:randomBar>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_OrientationTransition::from_element(
  element : @xml.Element,
) -> CT_OrientationTransition raise SchemaViolation {
  let dir = match ttt_attr(element, "dir") {
    Some(text) => Some(ST_Direction::parse(text))
    None => None
  }
  { dir, element_name: element.name }
}

///|
pub fn CT_OrientationTransition::new(
  element : @xml.Element,
) -> CT_OrientationTransition {
  CT_OrientationTransition::from_element(element) catch {
    _ => { dir: None, element_name: element.name }
  }
}

///|
pub fn CT_OrientationTransition::parse(
  element : @xml.Element,
) -> CT_OrientationTransition {
  CT_OrientationTransition::new(element)
}

///|
pub fn CT_OrientationTransition::to_element(
  self : CT_OrientationTransition,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.dir {
    Some(d) => attrs.push(ttt_attribute("dir", d.to_string()))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

///|
/// XSD complex type CT_InOutTransition — Part 1 §19.5.50 zoom. Carries
/// the optional `@dir` attribute drawn from §19.7.52
/// ST_TransitionInOutDirectionType (out / in); schema default `"out"`.
pub(all) struct CT_InOutTransition {
  /// §19.5.50 @dir (ST_TransitionInOutDirectionType §19.7.52).
  dir : ST_TransitionInOutDirectionType?
  /// Source element QName (`<p:zoom>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_InOutTransition::from_element(
  element : @xml.Element,
) -> CT_InOutTransition raise SchemaViolation {
  let dir = match ttt_attr(element, "dir") {
    Some(text) => Some(ST_TransitionInOutDirectionType::parse(text))
    None => None
  }
  { dir, element_name: element.name }
}

///|
pub fn CT_InOutTransition::new(element : @xml.Element) -> CT_InOutTransition {
  CT_InOutTransition::from_element(element) catch {
    _ => { dir: None, element_name: element.name }
  }
}

///|
pub fn CT_InOutTransition::parse(element : @xml.Element) -> CT_InOutTransition {
  CT_InOutTransition::new(element)
}

///|
pub fn CT_InOutTransition::to_element(
  self : CT_InOutTransition,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.dir {
    Some(d) => attrs.push(ttt_attribute("dir", d.to_string()))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

///|
/// XSD complex type CT_OptionalBlackTransition — Part 1 §19.5.50 cut,
/// §19.5.50 fade. Carries the optional `@thruBlk` attribute (xsd:boolean,
/// schema default `false`) that asks the renderer to dip the screen to
/// black mid-transition.
pub(all) struct CT_OptionalBlackTransition {
  /// §19.5.50 @thruBlk (xsd:boolean, default `false`); `None` ⇔ attribute
  /// absent so callers can distinguish "explicit false" from "schema
  /// default" when round-tripping.
  thru_blk : Bool?
  /// Source element QName (`<p:cut>` / `<p:fade>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_OptionalBlackTransition::from_element(
  element : @xml.Element,
) -> CT_OptionalBlackTransition raise SchemaViolation {
  let thru_blk = match ttt_attr(element, "thruBlk") {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => Some(b)
        None =>
          invalid_simple_type(
            "CT_OptionalBlackTransition/@thruBlk", text, "expected xsd:boolean",
          )
      }
    None => None
  }
  { thru_blk, element_name: element.name }
}

///|
pub fn CT_OptionalBlackTransition::new(
  element : @xml.Element,
) -> CT_OptionalBlackTransition {
  CT_OptionalBlackTransition::from_element(element) catch {
    _ => { thru_blk: None, element_name: element.name }
  }
}

///|
pub fn CT_OptionalBlackTransition::parse(
  element : @xml.Element,
) -> CT_OptionalBlackTransition {
  CT_OptionalBlackTransition::new(element)
}

///|
pub fn CT_OptionalBlackTransition::to_element(
  self : CT_OptionalBlackTransition,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.thru_blk {
    Some(true) => attrs.push(ttt_attribute("thruBlk", "true"))
    Some(false) => attrs.push(ttt_attribute("thruBlk", "false"))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

///|
/// XSD complex type CT_SplitTransition — Part 1 §19.5.50 split. Two
/// optional attributes: `@orient` (ST_Direction §19.7.2, default
/// `"horz"`) and `@dir` (ST_TransitionInOutDirectionType §19.7.52,
/// default `"out"`).
pub(all) struct CT_SplitTransition {
  /// §19.5.50 @orient (ST_Direction).
  orient : ST_Direction?
  /// §19.5.50 @dir (ST_TransitionInOutDirectionType).
  dir : ST_TransitionInOutDirectionType?
  /// Source element QName (`<p:split>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_SplitTransition::from_element(
  element : @xml.Element,
) -> CT_SplitTransition raise SchemaViolation {
  let orient = match ttt_attr(element, "orient") {
    Some(text) => Some(ST_Direction::parse(text))
    None => None
  }
  let dir = match ttt_attr(element, "dir") {
    Some(text) => Some(ST_TransitionInOutDirectionType::parse(text))
    None => None
  }
  { orient, dir, element_name: element.name }
}

///|
pub fn CT_SplitTransition::new(element : @xml.Element) -> CT_SplitTransition {
  CT_SplitTransition::from_element(element) catch {
    _ => { orient: None, dir: None, element_name: element.name }
  }
}

///|
pub fn CT_SplitTransition::parse(element : @xml.Element) -> CT_SplitTransition {
  CT_SplitTransition::new(element)
}

///|
pub fn CT_SplitTransition::to_element(
  self : CT_SplitTransition,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.orient {
    Some(o) => attrs.push(ttt_attribute("orient", o.to_string()))
    None => ()
  }
  match self.dir {
    Some(d) => attrs.push(ttt_attribute("dir", d.to_string()))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

///|
/// XSD complex type CT_WheelTransition — Part 1 §19.5.50 wheel. Carries
/// the optional `@spokes` attribute (xsd:unsignedInt, schema default
/// `4`) controlling the number of spokes radiating from the centre of
/// the rotating wipe.
pub(all) struct CT_WheelTransition {
  /// §19.5.50 @spokes (xsd:unsignedInt). Stored as UInt; `None` ⇔
  /// attribute absent so writer can omit it.
  spokes : UInt?
  /// Source element QName (`<p:wheel>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_WheelTransition::from_element(
  element : @xml.Element,
) -> CT_WheelTransition raise SchemaViolation {
  let spokes = match ttt_attr(element, "spokes") {
    Some(text) =>
      match parse_xsd_unsigned_int(text) {
        Some(n) => Some(n)
        None =>
          invalid_simple_type(
            "CT_WheelTransition/@spokes", text, "expected xsd:unsignedInt",
          )
      }
    None => None
  }
  { spokes, element_name: element.name }
}

///|
pub fn CT_WheelTransition::new(element : @xml.Element) -> CT_WheelTransition {
  CT_WheelTransition::from_element(element) catch {
    _ => { spokes: None, element_name: element.name }
  }
}

///|
pub fn CT_WheelTransition::parse(element : @xml.Element) -> CT_WheelTransition {
  CT_WheelTransition::new(element)
}

///|
pub fn CT_WheelTransition::to_element(
  self : CT_WheelTransition,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.spokes {
    Some(n) => attrs.push(ttt_attribute("spokes", n.to_string()))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

// === §19.5.50 Transition sound actions ====================================

///|
/// XSD complex type CT_TransitionStartSoundAction — Part 1 §19.5.50
/// stSnd (Start Sound Action). Has one required `<a:snd>` child
/// (a:CT_EmbeddedWAVAudioFile, kept as the raw element so the DML
/// audio package owns its typed decode) and one optional `@loop`
/// xsd:boolean attribute (schema default `false`).
pub(all) struct CT_TransitionStartSoundAction {
  /// §19.5.50 child `<a:snd>` (a:CT_EmbeddedWAVAudioFile). Preserved
  /// verbatim because the typed DML wrapper lives in the DrawingML
  /// audio package; the PML domain only knows the wrapper exists.
  snd : @xml.Element
  /// §19.5.50 @loop (xsd:boolean, default `false`).
  loop_ : Bool?
  /// Source element QName (`<p:stSnd>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TransitionStartSoundAction::from_element(
  element : @xml.Element,
) -> CT_TransitionStartSoundAction raise SchemaViolation {
  let snd = match ttt_first_child(element, "snd") {
    Some(e) => e
    None =>
      invalid_simple_type(
        "CT_TransitionStartSoundAction", "<stSnd/>", "missing required <snd> child",
      )
  }
  let loop_ = match ttt_attr(element, "loop") {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => Some(b)
        None =>
          invalid_simple_type(
            "CT_TransitionStartSoundAction/@loop", text, "expected xsd:boolean",
          )
      }
    None => None
  }
  { snd, loop_, element_name: element.name }
}

///|
pub fn CT_TransitionStartSoundAction::new(
  element : @xml.Element,
) -> CT_TransitionStartSoundAction {
  CT_TransitionStartSoundAction::from_element(element) catch {
    _ =>
      {
        snd: { name: ttt_qname("snd"), attributes: [], children: [] },
        loop_: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TransitionStartSoundAction::parse(
  element : @xml.Element,
) -> CT_TransitionStartSoundAction {
  CT_TransitionStartSoundAction::new(element)
}

///|
pub fn CT_TransitionStartSoundAction::to_element(
  self : CT_TransitionStartSoundAction,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.loop_ {
    Some(true) => attrs.push(ttt_attribute("loop", "true"))
    Some(false) => attrs.push(ttt_attribute("loop", "false"))
    None => ()
  }
  {
    name: self.element_name,
    attributes: attrs,
    children: [@xml.Element(self.snd)],
  }
}

///|
/// XSD complex type CT_TransitionSoundAction — Part 1 §19.5.50 sndAc
/// (Sound Action). A discriminated choice: either a start-sound
/// (`<p:stSnd>` → CT_TransitionStartSoundAction) or an end-sound
/// (`<p:endSnd>` → CT_Empty).
pub(all) enum CT_TransitionSoundActionChoice {
  /// §19.5.50 stSnd branch.
  TransitionSoundStart(CT_TransitionStartSoundAction)
  /// §19.5.50 endSnd branch. The `<p:endSnd>` element is empty per
  /// pml.xsd (CT_Empty); the source QName is preserved for round-trip.
  TransitionSoundEnd(@xml.QName)
} derive(Eq, Debug)

///|
pub(all) struct CT_TransitionSoundAction {
  /// §19.5.50 xsd:choice (stSnd | endSnd); required (minOccurs=1).
  choice : CT_TransitionSoundActionChoice
  /// Source element QName (`<p:sndAc>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TransitionSoundAction::from_element(
  element : @xml.Element,
) -> CT_TransitionSoundAction raise SchemaViolation {
  let choice = match ttt_first_child(element, "stSnd") {
    Some(e) =>
      TransitionSoundStart(CT_TransitionStartSoundAction::from_element(e))
    None =>
      match ttt_first_child(element, "endSnd") {
        Some(e) => TransitionSoundEnd(e.name)
        None =>
          invalid_simple_type(
            "CT_TransitionSoundAction", "<sndAc/>", "missing required stSnd|endSnd choice",
          )
      }
  }
  { choice, element_name: element.name }
}

///|
pub fn CT_TransitionSoundAction::new(
  element : @xml.Element,
) -> CT_TransitionSoundAction {
  CT_TransitionSoundAction::from_element(element) catch {
    _ =>
      {
        choice: TransitionSoundEnd(ttt_qname("endSnd")),
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TransitionSoundAction::parse(
  element : @xml.Element,
) -> CT_TransitionSoundAction {
  CT_TransitionSoundAction::new(element)
}

///|
pub fn CT_TransitionSoundAction::to_element(
  self : CT_TransitionSoundAction,
) -> @xml.Element {
  let child : @xml.Node = match self.choice {
    TransitionSoundStart(s) => @xml.Element(s.to_element())
    TransitionSoundEnd(qn) =>
      @xml.Element({ name: qn, attributes: [], children: [] })
  }
  { name: self.element_name, attributes: [], children: [child] }
}

// === §19.5.50 CT_SlideTransition ==========================================

///|
/// XSD complex type CT_SlideTransition — Part 1 §19.5.50 transition.
/// The optional `<p:transition>` element on a slide overrides the
/// click-to-advance default. The `effect` choice picks one of 22
/// preset transitions (CT_OrientationTransition, CT_Empty,
/// CT_EightDirectionTransition, CT_OptionalBlackTransition,
/// CT_SideDirectionTransition, CT_SplitTransition,
/// CT_CornerDirectionTransition, CT_WheelTransition, or
/// CT_InOutTransition depending on the element kind).
pub(all) enum CT_SlideTransitionEffect {
  /// §19.5.50 blinds (CT_OrientationTransition).
  TransitionBlinds(CT_OrientationTransition)
  /// §19.5.50 checker (CT_OrientationTransition).
  TransitionChecker(CT_OrientationTransition)
  /// §19.5.50 circle (CT_Empty); QName carries the source tag.
  TransitionCircle(@xml.QName)
  /// §19.5.50 dissolve (CT_Empty).
  TransitionDissolve(@xml.QName)
  /// §19.5.50 comb (CT_OrientationTransition).
  TransitionComb(CT_OrientationTransition)
  /// §19.5.50 cover (CT_EightDirectionTransition).
  TransitionCover(CT_EightDirectionTransition)
  /// §19.5.50 cut (CT_OptionalBlackTransition).
  TransitionCut(CT_OptionalBlackTransition)
  /// §19.5.50 diamond (CT_Empty).
  TransitionDiamond(@xml.QName)
  /// §19.5.50 fade (CT_OptionalBlackTransition).
  TransitionFade(CT_OptionalBlackTransition)
  /// §19.5.50 newsflash (CT_Empty).
  TransitionNewsflash(@xml.QName)
  /// §19.5.50 plus (CT_Empty).
  TransitionPlus(@xml.QName)
  /// §19.5.50 pull (CT_EightDirectionTransition).
  TransitionPull(CT_EightDirectionTransition)
  /// §19.5.50 push (CT_SideDirectionTransition).
  TransitionPush(CT_SideDirectionTransition)
  /// §19.5.50 random (CT_Empty).
  TransitionRandom(@xml.QName)
  /// §19.5.50 randomBar (CT_OrientationTransition).
  TransitionRandomBar(CT_OrientationTransition)
  /// §19.5.50 split (CT_SplitTransition).
  TransitionSplit(CT_SplitTransition)
  /// §19.5.50 strips (CT_CornerDirectionTransition).
  TransitionStrips(CT_CornerDirectionTransition)
  /// §19.5.50 wedge (CT_Empty).
  TransitionWedge(@xml.QName)
  /// §19.5.50 wheel (CT_WheelTransition).
  TransitionWheel(CT_WheelTransition)
  /// §19.5.50 wipe (CT_SideDirectionTransition).
  TransitionWipe(CT_SideDirectionTransition)
  /// §19.5.50 zoom (CT_InOutTransition).
  TransitionZoom(CT_InOutTransition)
} derive(Eq, Debug)

///|
pub(all) struct CT_SlideTransition {
  /// §19.5.50 sequence — optional effect (one of 22 transitions).
  effect : CT_SlideTransitionEffect?
  /// §19.5.50 child `<p:sndAc>` (CT_TransitionSoundAction, optional).
  sndAc : CT_TransitionSoundAction?
  /// §19.5.50 child `<p:extLst>` (CT_ExtensionListModify, optional).
  /// Kept as raw element — CT_ExtensionListModify is owned by chunk2.
  extLst : @xml.Element?
  /// §19.5.50 @spd (ST_TransitionSpeed §19.7.54, default `"fast"`).
  spd : ST_TransitionSpeed?
  /// §19.5.50 @advClick (xsd:boolean, default `true`).
  adv_click : Bool?
  /// §19.5.50 @advTm (xsd:unsignedInt, no default).
  adv_tm : UInt?
  /// Source element QName (`<p:transition>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
fn decode_slide_transition_effect(
  element : @xml.Element,
) -> CT_SlideTransitionEffect? raise SchemaViolation {
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let kind = match e.name.local_name {
          "blinds" =>
            Some(TransitionBlinds(CT_OrientationTransition::from_element(e)))
          "checker" =>
            Some(TransitionChecker(CT_OrientationTransition::from_element(e)))
          "circle" => Some(TransitionCircle(e.name))
          "dissolve" => Some(TransitionDissolve(e.name))
          "comb" =>
            Some(TransitionComb(CT_OrientationTransition::from_element(e)))
          "cover" =>
            Some(TransitionCover(CT_EightDirectionTransition::from_element(e)))
          "cut" =>
            Some(TransitionCut(CT_OptionalBlackTransition::from_element(e)))
          "diamond" => Some(TransitionDiamond(e.name))
          "fade" =>
            Some(TransitionFade(CT_OptionalBlackTransition::from_element(e)))
          "newsflash" => Some(TransitionNewsflash(e.name))
          "plus" => Some(TransitionPlus(e.name))
          "pull" =>
            Some(TransitionPull(CT_EightDirectionTransition::from_element(e)))
          "push" =>
            Some(TransitionPush(CT_SideDirectionTransition::from_element(e)))
          "random" => Some(TransitionRandom(e.name))
          "randomBar" =>
            Some(TransitionRandomBar(CT_OrientationTransition::from_element(e)))
          "split" => Some(TransitionSplit(CT_SplitTransition::from_element(e)))
          "strips" =>
            Some(
              TransitionStrips(CT_CornerDirectionTransition::from_element(e)),
            )
          "wedge" => Some(TransitionWedge(e.name))
          "wheel" => Some(TransitionWheel(CT_WheelTransition::from_element(e)))
          "wipe" =>
            Some(TransitionWipe(CT_SideDirectionTransition::from_element(e)))
          "zoom" => Some(TransitionZoom(CT_InOutTransition::from_element(e)))
          _ => None
        }
        if kind is Some(_) {
          return kind
        }
      }
      _ => ()
    }
  }
  None
}

///|
pub fn CT_SlideTransition::from_element(
  element : @xml.Element,
) -> CT_SlideTransition raise SchemaViolation {
  let effect = decode_slide_transition_effect(element)
  let sndAc = match ttt_first_child(element, "sndAc") {
    Some(e) => Some(CT_TransitionSoundAction::from_element(e))
    None => None
  }
  let extLst = ttt_first_child(element, "extLst")
  let spd = match ttt_attr(element, "spd") {
    Some(text) => Some(ST_TransitionSpeed::parse(text))
    None => None
  }
  let adv_click = match ttt_attr(element, "advClick") {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => Some(b)
        None =>
          invalid_simple_type(
            "CT_SlideTransition/@advClick", text, "expected xsd:boolean",
          )
      }
    None => None
  }
  let adv_tm = match ttt_attr(element, "advTm") {
    Some(text) =>
      match parse_xsd_unsigned_int(text) {
        Some(n) => Some(n)
        None =>
          invalid_simple_type(
            "CT_SlideTransition/@advTm", text, "expected xsd:unsignedInt",
          )
      }
    None => None
  }
  { effect, sndAc, extLst, spd, adv_click, adv_tm, element_name: element.name }
}

///|
pub fn CT_SlideTransition::new(element : @xml.Element) -> CT_SlideTransition {
  CT_SlideTransition::from_element(element) catch {
    _ =>
      {
        effect: None,
        sndAc: None,
        extLst: None,
        spd: None,
        adv_click: None,
        adv_tm: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_SlideTransition::parse(element : @xml.Element) -> CT_SlideTransition {
  CT_SlideTransition::new(element)
}

///|
pub fn CT_SlideTransition::to_element(
  self : CT_SlideTransition,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.spd {
    Some(s) => attrs.push(ttt_attribute("spd", s.to_string()))
    None => ()
  }
  match self.adv_click {
    Some(true) => attrs.push(ttt_attribute("advClick", "true"))
    Some(false) => attrs.push(ttt_attribute("advClick", "false"))
    None => ()
  }
  match self.adv_tm {
    Some(n) => attrs.push(ttt_attribute("advTm", n.to_string()))
    None => ()
  }
  let children : Array[@xml.Node] = []
  match self.effect {
    Some(e) => children.push(@xml.Element(slide_transition_effect_element(e)))
    None => ()
  }
  match self.sndAc {
    Some(s) => children.push(@xml.Element(s.to_element()))
    None => ()
  }
  match self.extLst {
    Some(e) => children.push(@xml.Element(e))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children }
}

///|
fn slide_transition_effect_element(
  effect : CT_SlideTransitionEffect,
) -> @xml.Element {
  match effect {
    TransitionBlinds(t) => t.to_element()
    TransitionChecker(t) => t.to_element()
    TransitionCircle(qn) => { name: qn, attributes: [], children: [] }
    TransitionDissolve(qn) => { name: qn, attributes: [], children: [] }
    TransitionComb(t) => t.to_element()
    TransitionCover(t) => t.to_element()
    TransitionCut(t) => t.to_element()
    TransitionDiamond(qn) => { name: qn, attributes: [], children: [] }
    TransitionFade(t) => t.to_element()
    TransitionNewsflash(qn) => { name: qn, attributes: [], children: [] }
    TransitionPlus(qn) => { name: qn, attributes: [], children: [] }
    TransitionPull(t) => t.to_element()
    TransitionPush(t) => t.to_element()
    TransitionRandom(qn) => { name: qn, attributes: [], children: [] }
    TransitionRandomBar(t) => t.to_element()
    TransitionSplit(t) => t.to_element()
    TransitionStrips(t) => t.to_element()
    TransitionWedge(qn) => { name: qn, attributes: [], children: [] }
    TransitionWheel(t) => t.to_element()
    TransitionWipe(t) => t.to_element()
    TransitionZoom(t) => t.to_element()
  }
}

// === §19.5.43 iterate intervals ===========================================

///|
/// XSD complex type CT_TLIterateIntervalTime — Part 1 §19.5.43 tmAbs
/// (Absolute Time Iteration Interval). Single required `@val` attribute
/// typed §19.7.38 ST_TLTime (the `indefinite` token or an unsignedInt
/// millisecond count).
pub(all) struct CT_TLIterateIntervalTime {
  /// §19.5.43 @val (ST_TLTime, required).
  val : ST_TLTime
  /// Source element QName (`<p:tmAbs>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLIterateIntervalTime::from_element(
  element : @xml.Element,
) -> CT_TLIterateIntervalTime raise SchemaViolation {
  let val = match ttt_attr(element, "val") {
    Some(text) => ST_TLTime::parse(text)
    None =>
      invalid_simple_type(
        "CT_TLIterateIntervalTime", "<tmAbs/>", "missing required @val attribute",
      )
  }
  { val, element_name: element.name }
}

///|
pub fn CT_TLIterateIntervalTime::new(
  element : @xml.Element,
) -> CT_TLIterateIntervalTime {
  CT_TLIterateIntervalTime::from_element(element) catch {
    _ => { val: TLTimeIndefinite, element_name: element.name }
  }
}

///|
pub fn CT_TLIterateIntervalTime::parse(
  element : @xml.Element,
) -> CT_TLIterateIntervalTime {
  CT_TLIterateIntervalTime::new(element)
}

///|
pub fn CT_TLIterateIntervalTime::to_element(
  self : CT_TLIterateIntervalTime,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [ttt_attribute("val", self.val.to_string())],
    children: [],
  }
}

///|
/// XSD complex type CT_TLIterateIntervalPercentage — Part 1 §19.5.43
/// tmPct (Percentage Time Iteration Interval). Single required `@val`
/// attribute typed a:ST_PositivePercentage (DML §20.1.10.46), kept as
/// the lexical string because the typed DML percentage lives in the
/// drawing_ml domain.
pub(all) struct CT_TLIterateIntervalPercentage {
  /// §19.5.43 @val (a:ST_PositivePercentage, required). Raw lexical
  /// form (e.g. `"25%"` or `"25000"` thousandths) preserved verbatim.
  val : String
  /// Source element QName (`<p:tmPct>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLIterateIntervalPercentage::from_element(
  element : @xml.Element,
) -> CT_TLIterateIntervalPercentage raise SchemaViolation {
  let val = match ttt_attr(element, "val") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLIterateIntervalPercentage", "<tmPct/>", "missing required @val attribute",
      )
  }
  { val, element_name: element.name }
}

///|
pub fn CT_TLIterateIntervalPercentage::new(
  element : @xml.Element,
) -> CT_TLIterateIntervalPercentage {
  CT_TLIterateIntervalPercentage::from_element(element) catch {
    _ => { val: "", element_name: element.name }
  }
}

///|
pub fn CT_TLIterateIntervalPercentage::parse(
  element : @xml.Element,
) -> CT_TLIterateIntervalPercentage {
  CT_TLIterateIntervalPercentage::new(element)
}

///|
pub fn CT_TLIterateIntervalPercentage::to_element(
  self : CT_TLIterateIntervalPercentage,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [ttt_attribute("val", self.val)],
    children: [],
  }
}

///|
/// XSD complex type CT_TLIterateData — Part 1 §19.5.42 iterate (Iterate).
/// Discriminated choice between an absolute (`<p:tmAbs>`) and percentage
/// (`<p:tmPct>`) interval, plus two optional attributes: `@type`
/// (§19.7.4 ST_IterateType, schema default `"el"`) and `@backwards`
/// (xsd:boolean, schema default `false`).
pub(all) enum CT_TLIterateDataInterval {
  /// §19.5.42 tmAbs branch (CT_TLIterateIntervalTime §19.5.43).
  IterateAbs(CT_TLIterateIntervalTime)
  /// §19.5.42 tmPct branch (CT_TLIterateIntervalPercentage §19.5.43).
  IteratePct(CT_TLIterateIntervalPercentage)
} derive(Eq, Debug)

///|
pub(all) struct CT_TLIterateData {
  /// §19.5.42 xsd:choice (tmAbs | tmPct), required.
  interval : CT_TLIterateDataInterval
  /// §19.5.42 @type (ST_IterateType).
  iterate_type : ST_IterateType?
  /// §19.5.42 @backwards (xsd:boolean).
  backwards : Bool?
  /// Source element QName (`<p:iterate>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLIterateData::from_element(
  element : @xml.Element,
) -> CT_TLIterateData raise SchemaViolation {
  let interval = match ttt_first_child(element, "tmAbs") {
    Some(e) => IterateAbs(CT_TLIterateIntervalTime::from_element(e))
    None =>
      match ttt_first_child(element, "tmPct") {
        Some(e) => IteratePct(CT_TLIterateIntervalPercentage::from_element(e))
        None =>
          invalid_simple_type(
            "CT_TLIterateData", "<iterate/>", "missing required tmAbs|tmPct choice",
          )
      }
  }
  let iterate_type = match ttt_attr(element, "type") {
    Some(text) => Some(ST_IterateType::parse(text))
    None => None
  }
  let backwards = match ttt_attr(element, "backwards") {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => Some(b)
        None =>
          invalid_simple_type(
            "CT_TLIterateData/@backwards", text, "expected xsd:boolean",
          )
      }
    None => None
  }
  { interval, iterate_type, backwards, element_name: element.name }
}

///|
pub fn CT_TLIterateData::new(element : @xml.Element) -> CT_TLIterateData {
  CT_TLIterateData::from_element(element) catch {
    _ =>
      {
        interval: IterateAbs({
          val: TLTimeIndefinite,
          element_name: ttt_qname("tmAbs"),
        }),
        iterate_type: None,
        backwards: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLIterateData::parse(element : @xml.Element) -> CT_TLIterateData {
  CT_TLIterateData::new(element)
}

///|
pub fn CT_TLIterateData::to_element(self : CT_TLIterateData) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.iterate_type {
    Some(t) => attrs.push(ttt_attribute("type", t.to_string()))
    None => ()
  }
  match self.backwards {
    Some(true) => attrs.push(ttt_attribute("backwards", "true"))
    Some(false) => attrs.push(ttt_attribute("backwards", "false"))
    None => ()
  }
  let interval_el : @xml.Element = match self.interval {
    IterateAbs(a) => a.to_element()
    IteratePct(p) => p.to_element()
  }
  {
    name: self.element_name,
    attributes: attrs,
    children: [@xml.Element(interval_el)],
  }
}

// === §19.5.77 / §19.5.81 / §19.5.82 timing target elements ================

///|
/// XSD complex type CT_TLSubShapeId — Part 1 §19.5.77 subSp (Subshape).
/// Single required `@spid` attribute typed a:ST_ShapeID (Drawing
/// element id), kept as the raw lexical string because that ST_ lives
/// in DrawingML.
pub(all) struct CT_TLSubShapeId {
  /// §19.5.77 @spid (a:ST_ShapeID, required). Raw lexical string.
  spid : String
  /// Source element QName (`<p:subSp>` or `<p:inkTgt>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLSubShapeId::from_element(
  element : @xml.Element,
) -> CT_TLSubShapeId raise SchemaViolation {
  let spid = match ttt_attr(element, "spid") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLSubShapeId", "<subSp/>", "missing required @spid attribute",
      )
  }
  { spid, element_name: element.name }
}

///|
pub fn CT_TLSubShapeId::new(element : @xml.Element) -> CT_TLSubShapeId {
  CT_TLSubShapeId::from_element(element) catch {
    _ => { spid: "", element_name: element.name }
  }
}

///|
pub fn CT_TLSubShapeId::parse(element : @xml.Element) -> CT_TLSubShapeId {
  CT_TLSubShapeId::new(element)
}

///|
pub fn CT_TLSubShapeId::to_element(self : CT_TLSubShapeId) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [ttt_attribute("spid", self.spid)],
    children: [],
  }
}

///|
/// XSD complex type CT_TLTextTargetElement — Part 1 §19.5.82 txEl (Text
/// Element). Optional xsd:choice between `<p:charRg>` (character range)
/// and `<p:pRg>` (paragraph range), both typed CT_IndexRange. CT_IndexRange
/// is owned by chunk2 so the values are kept as raw elements.
pub(all) enum CT_TLTextTargetElementRange {
  /// §19.5.82 charRg branch (CT_IndexRange §19.3.1.6).
  TextTargetCharRg(@xml.Element)
  /// §19.5.82 pRg branch (CT_IndexRange §19.3.1.6).
  TextTargetPRg(@xml.Element)
} derive(Eq, Debug)

///|
pub(all) struct CT_TLTextTargetElement {
  /// §19.5.82 xsd:choice (charRg | pRg), optional (minOccurs=0).
  range : CT_TLTextTargetElementRange?
  /// Source element QName (`<p:txEl>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLTextTargetElement::from_element(
  element : @xml.Element,
) -> CT_TLTextTargetElement raise SchemaViolation {
  let range = match ttt_first_child(element, "charRg") {
    Some(e) => Some(TextTargetCharRg(e))
    None =>
      match ttt_first_child(element, "pRg") {
        Some(e) => Some(TextTargetPRg(e))
        None => None
      }
  }
  { range, element_name: element.name }
}

///|
pub fn CT_TLTextTargetElement::new(
  element : @xml.Element,
) -> CT_TLTextTargetElement {
  CT_TLTextTargetElement::from_element(element) catch {
    _ => { range: None, element_name: element.name }
  }
}

///|
pub fn CT_TLTextTargetElement::parse(
  element : @xml.Element,
) -> CT_TLTextTargetElement {
  CT_TLTextTargetElement::new(element)
}

///|
pub fn CT_TLTextTargetElement::to_element(
  self : CT_TLTextTargetElement,
) -> @xml.Element {
  let children : Array[@xml.Node] = []
  match self.range {
    Some(TextTargetCharRg(e)) => children.push(@xml.Element(e))
    Some(TextTargetPRg(e)) => children.push(@xml.Element(e))
    None => ()
  }
  { name: self.element_name, attributes: [], children }
}

///|
/// XSD complex type CT_TLOleChartTargetElement — Part 1 §19.5.51
/// oleChartEl (Embedded Chart Target Element). Required `@type`
/// (§19.7.30 ST_TLChartSubelementType) and optional `@lvl`
/// (xsd:unsignedInt, schema default `0`).
pub(all) struct CT_TLOleChartTargetElement {
  /// §19.5.51 @type (ST_TLChartSubelementType, required).
  chart_type : ST_TLChartSubelementType
  /// §19.5.51 @lvl (xsd:unsignedInt).
  lvl : UInt?
  /// Source element QName (`<p:oleChartEl>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLOleChartTargetElement::from_element(
  element : @xml.Element,
) -> CT_TLOleChartTargetElement raise SchemaViolation {
  let chart_type = match ttt_attr(element, "type") {
    Some(text) => ST_TLChartSubelementType::parse(text)
    None =>
      invalid_simple_type(
        "CT_TLOleChartTargetElement", "<oleChartEl/>", "missing required @type attribute",
      )
  }
  let lvl = match ttt_attr(element, "lvl") {
    Some(text) =>
      match parse_xsd_unsigned_int(text) {
        Some(n) => Some(n)
        None =>
          invalid_simple_type(
            "CT_TLOleChartTargetElement/@lvl", text, "expected xsd:unsignedInt",
          )
      }
    None => None
  }
  { chart_type, lvl, element_name: element.name }
}

///|
pub fn CT_TLOleChartTargetElement::new(
  element : @xml.Element,
) -> CT_TLOleChartTargetElement {
  CT_TLOleChartTargetElement::from_element(element) catch {
    _ => { chart_type: ChartGridLegend, lvl: None, element_name: element.name }
  }
}

///|
pub fn CT_TLOleChartTargetElement::parse(
  element : @xml.Element,
) -> CT_TLOleChartTargetElement {
  CT_TLOleChartTargetElement::new(element)
}

///|
pub fn CT_TLOleChartTargetElement::to_element(
  self : CT_TLOleChartTargetElement,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    ttt_attribute("type", self.chart_type.to_string()),
  ]
  match self.lvl {
    Some(n) => attrs.push(ttt_attribute("lvl", n.to_string()))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

///|
/// XSD complex type CT_TLShapeTargetElement — Part 1 §19.5.70 spTgt
/// (Shape Target). Required `@spid` (a:ST_DrawingElementId, kept as raw
/// lexical string) and an optional xsd:choice child: bg / subSp /
/// oleChartEl / txEl / graphicEl.
pub(all) enum CT_TLShapeTargetElementChild {
  /// §19.5.70 bg branch (CT_Empty).
  ShapeTargetBg(@xml.QName)
  /// §19.5.70 subSp branch (CT_TLSubShapeId §19.5.77).
  ShapeTargetSubSp(CT_TLSubShapeId)
  /// §19.5.70 oleChartEl branch (CT_TLOleChartTargetElement §19.5.51).
  ShapeTargetOleChartEl(CT_TLOleChartTargetElement)
  /// §19.5.70 txEl branch (CT_TLTextTargetElement §19.5.82).
  ShapeTargetTxEl(CT_TLTextTargetElement)
  /// §19.5.70 graphicEl branch (a:CT_AnimationElementChoice §20.1.2.2.3).
  /// Kept as raw element because that DML type lives in the drawing_ml
  /// domain.
  ShapeTargetGraphicEl(@xml.Element)
} derive(Eq, Debug)

///|
pub(all) struct CT_TLShapeTargetElement {
  /// §19.5.70 @spid (a:ST_DrawingElementId, required). Raw lexical form.
  spid : String
  /// §19.5.70 xsd:choice (bg | subSp | oleChartEl | txEl | graphicEl),
  /// optional.
  child : CT_TLShapeTargetElementChild?
  /// Source element QName (`<p:spTgt>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLShapeTargetElement::from_element(
  element : @xml.Element,
) -> CT_TLShapeTargetElement raise SchemaViolation {
  let spid = match ttt_attr(element, "spid") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLShapeTargetElement", "<spTgt/>", "missing required @spid attribute",
      )
  }
  let child = decode_shape_target_child(element)
  { spid, child, element_name: element.name }
}

///|
fn decode_shape_target_child(
  element : @xml.Element,
) -> CT_TLShapeTargetElementChild? raise SchemaViolation {
  for c in element.children {
    match c {
      @xml.Element(e) => {
        let kind = match e.name.local_name {
          "bg" => Some(ShapeTargetBg(e.name))
          "subSp" => Some(ShapeTargetSubSp(CT_TLSubShapeId::from_element(e)))
          "oleChartEl" =>
            Some(
              ShapeTargetOleChartEl(CT_TLOleChartTargetElement::from_element(e)),
            )
          "txEl" =>
            Some(ShapeTargetTxEl(CT_TLTextTargetElement::from_element(e)))
          "graphicEl" => Some(ShapeTargetGraphicEl(e))
          _ => None
        }
        if kind is Some(_) {
          return kind
        }
      }
      _ => ()
    }
  }
  None
}

///|
pub fn CT_TLShapeTargetElement::new(
  element : @xml.Element,
) -> CT_TLShapeTargetElement {
  CT_TLShapeTargetElement::from_element(element) catch {
    _ => { spid: "", child: None, element_name: element.name }
  }
}

///|
pub fn CT_TLShapeTargetElement::parse(
  element : @xml.Element,
) -> CT_TLShapeTargetElement {
  CT_TLShapeTargetElement::new(element)
}

///|
pub fn CT_TLShapeTargetElement::to_element(
  self : CT_TLShapeTargetElement,
) -> @xml.Element {
  let attrs = [ttt_attribute("spid", self.spid)]
  let children : Array[@xml.Node] = []
  match self.child {
    Some(ShapeTargetBg(qn)) =>
      children.push(@xml.Element({ name: qn, attributes: [], children: [] }))
    Some(ShapeTargetSubSp(s)) => children.push(@xml.Element(s.to_element()))
    Some(ShapeTargetOleChartEl(o)) =>
      children.push(@xml.Element(o.to_element()))
    Some(ShapeTargetTxEl(t)) => children.push(@xml.Element(t.to_element()))
    Some(ShapeTargetGraphicEl(e)) => children.push(@xml.Element(e))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children }
}

///|
/// XSD complex type CT_TLTimeTargetElement — Part 1 §19.5.81 tgtEl
/// (Target Element). Required xsd:choice between sldTgt / sndTgt /
/// spTgt / inkTgt.
pub(all) enum CT_TLTimeTargetElementChoice {
  /// §19.5.81 sldTgt branch (CT_Empty).
  TimeTargetSld(@xml.QName)
  /// §19.5.81 sndTgt branch (a:CT_EmbeddedWAVAudioFile, raw).
  TimeTargetSnd(@xml.Element)
  /// §19.5.81 spTgt branch (CT_TLShapeTargetElement §19.5.70).
  TimeTargetSp(CT_TLShapeTargetElement)
  /// §19.5.81 inkTgt branch (CT_TLSubShapeId §19.5.77).
  TimeTargetInk(CT_TLSubShapeId)
} derive(Eq, Debug)

///|
pub(all) struct CT_TLTimeTargetElement {
  /// §19.5.81 xsd:choice (sldTgt | sndTgt | spTgt | inkTgt), required.
  choice : CT_TLTimeTargetElementChoice
  /// Source element QName (`<p:tgtEl>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLTimeTargetElement::from_element(
  element : @xml.Element,
) -> CT_TLTimeTargetElement raise SchemaViolation {
  let choice = decode_time_target_choice(element)
  match choice {
    Some(c) => { choice: c, element_name: element.name }
    None =>
      invalid_simple_type(
        "CT_TLTimeTargetElement", "<tgtEl/>", "missing required sldTgt|sndTgt|spTgt|inkTgt choice",
      )
  }
}

///|
fn decode_time_target_choice(
  element : @xml.Element,
) -> CT_TLTimeTargetElementChoice? raise SchemaViolation {
  for c in element.children {
    match c {
      @xml.Element(e) => {
        let kind : CT_TLTimeTargetElementChoice? = match e.name.local_name {
          "sldTgt" => Some(TimeTargetSld(e.name))
          "sndTgt" => Some(TimeTargetSnd(e))
          "spTgt" =>
            Some(TimeTargetSp(CT_TLShapeTargetElement::from_element(e)))
          "inkTgt" => Some(TimeTargetInk(CT_TLSubShapeId::from_element(e)))
          _ => None
        }
        if kind is Some(_) {
          return kind
        }
      }
      _ => ()
    }
  }
  None
}

///|
pub fn CT_TLTimeTargetElement::new(
  element : @xml.Element,
) -> CT_TLTimeTargetElement {
  CT_TLTimeTargetElement::from_element(element) catch {
    _ =>
      { choice: TimeTargetSld(ttt_qname("sldTgt")), element_name: element.name }
  }
}

///|
pub fn CT_TLTimeTargetElement::parse(
  element : @xml.Element,
) -> CT_TLTimeTargetElement {
  CT_TLTimeTargetElement::new(element)
}

///|
pub fn CT_TLTimeTargetElement::to_element(
  self : CT_TLTimeTargetElement,
) -> @xml.Element {
  let child : @xml.Node = match self.choice {
    TimeTargetSld(qn) =>
      @xml.Element({ name: qn, attributes: [], children: [] })
    TimeTargetSnd(e) => @xml.Element(e)
    TimeTargetSp(s) => @xml.Element(s.to_element())
    TimeTargetInk(s) => @xml.Element(s.to_element())
  }
  { name: self.element_name, attributes: [], children: [child] }
}

// === §19.5.83 / §19.5.84 trigger time-node references =====================

///|
/// XSD complex type CT_TLTriggerTimeNodeID — Part 1 §19.5.84 tn (Trigger
/// Time Node). Required `@val` attribute typed §19.7.42 ST_TLTimeNodeID
/// (xsd:unsignedInt).
pub(all) struct CT_TLTriggerTimeNodeID {
  /// §19.5.84 @val (ST_TLTimeNodeID, required).
  val : ST_TLTimeNodeID
  /// Source element QName (`<p:tn>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLTriggerTimeNodeID::from_element(
  element : @xml.Element,
) -> CT_TLTriggerTimeNodeID raise SchemaViolation {
  let val = match ttt_attr(element, "val") {
    Some(text) => ST_TLTimeNodeID::parse(text)
    None =>
      invalid_simple_type(
        "CT_TLTriggerTimeNodeID", "<tn/>", "missing required @val attribute",
      )
  }
  { val, element_name: element.name }
}

///|
pub fn CT_TLTriggerTimeNodeID::new(
  element : @xml.Element,
) -> CT_TLTriggerTimeNodeID {
  CT_TLTriggerTimeNodeID::from_element(element) catch {
    _ => { val: ST_TLTimeNodeID::{ value: 0U }, element_name: element.name }
  }
}

///|
pub fn CT_TLTriggerTimeNodeID::parse(
  element : @xml.Element,
) -> CT_TLTriggerTimeNodeID {
  CT_TLTriggerTimeNodeID::new(element)
}

///|
pub fn CT_TLTriggerTimeNodeID::to_element(
  self : CT_TLTriggerTimeNodeID,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [ttt_attribute("val", self.val.to_string())],
    children: [],
  }
}

///|
/// XSD complex type CT_TLTriggerRuntimeNode — Part 1 §19.5.83 rtn
/// (Runtime Node Trigger Choice). Required `@val` typed §19.7.49
/// ST_TLTriggerRuntimeNode (first / last / all).
pub(all) struct CT_TLTriggerRuntimeNode {
  /// §19.5.83 @val (ST_TLTriggerRuntimeNode, required).
  val : ST_TLTriggerRuntimeNode
  /// Source element QName (`<p:rtn>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLTriggerRuntimeNode::from_element(
  element : @xml.Element,
) -> CT_TLTriggerRuntimeNode raise SchemaViolation {
  let val = match ttt_attr(element, "val") {
    Some(text) => ST_TLTriggerRuntimeNode::parse(text)
    None =>
      invalid_simple_type(
        "CT_TLTriggerRuntimeNode", "<rtn/>", "missing required @val attribute",
      )
  }
  { val, element_name: element.name }
}

///|
pub fn CT_TLTriggerRuntimeNode::new(
  element : @xml.Element,
) -> CT_TLTriggerRuntimeNode {
  CT_TLTriggerRuntimeNode::from_element(element) catch {
    _ => { val: RuntimeFirst, element_name: element.name }
  }
}

///|
pub fn CT_TLTriggerRuntimeNode::parse(
  element : @xml.Element,
) -> CT_TLTriggerRuntimeNode {
  CT_TLTriggerRuntimeNode::new(element)
}

///|
pub fn CT_TLTriggerRuntimeNode::to_element(
  self : CT_TLTriggerRuntimeNode,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [ttt_attribute("val", self.val.to_string())],
    children: [],
  }
}

// === §19.5.53 / §19.5.65 / §19.5.40 container time-nodes ==================
//
// par / seq / excl wrap a required `<p:cTn>` child plus, in the case of
// seq, optional `<p:prevCondLst>` and `<p:nextCondLst>` siblings. The
// children themselves are not typed yet (CT_TLCommonTimeNodeData /
// CT_TLTimeCondition typed records live in animation_types.mbt and are
// decoded by the animation_eval package); the typed wrappers below
// surface the raw cTn / prevCondLst / nextCondLst child elements so
// downstream consumers can keep using their existing decoders without
// double-parsing.

///|
/// XSD complex type CT_TLTimeNodeParallel — Part 1 §19.5.53 par
/// (Parallel Time Node). One required `<p:cTn>` child
/// (CT_TLCommonTimeNodeData §19.5.33). The cTn child is preserved as a
/// raw element so the animation engine's existing typed decoder owns
/// the field expansion.
pub(all) struct CT_TLTimeNodeParallel {
  /// §19.5.53 child `<p:cTn>` (CT_TLCommonTimeNodeData, required).
  cTn : @xml.Element
  /// Source element QName (`<p:par>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLTimeNodeParallel::from_element(
  element : @xml.Element,
) -> CT_TLTimeNodeParallel raise SchemaViolation {
  let cTn = match ttt_first_child(element, "cTn") {
    Some(e) => e
    None =>
      invalid_simple_type(
        "CT_TLTimeNodeParallel", "<par/>", "missing required <cTn> child",
      )
  }
  { cTn, element_name: element.name }
}

///|
pub fn CT_TLTimeNodeParallel::new(
  element : @xml.Element,
) -> CT_TLTimeNodeParallel {
  CT_TLTimeNodeParallel::from_element(element) catch {
    _ =>
      {
        cTn: { name: ttt_qname("cTn"), attributes: [], children: [] },
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLTimeNodeParallel::parse(
  element : @xml.Element,
) -> CT_TLTimeNodeParallel {
  CT_TLTimeNodeParallel::new(element)
}

///|
pub fn CT_TLTimeNodeParallel::to_element(
  self : CT_TLTimeNodeParallel,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [],
    children: [@xml.Element(self.cTn)],
  }
}

///|
/// XSD complex type CT_TLTimeNodeSequence — Part 1 §19.5.65 seq
/// (Sequence Time Node). One required `<p:cTn>` plus two optional
/// `<p:prevCondLst>` / `<p:nextCondLst>` children (typed
/// CT_TLTimeConditionList §19.5.74 / §19.5.52). Three optional
/// attributes: `@concurrent` (xsd:boolean), `@prevAc` (ST_TLPreviousActionType
/// §19.7.45), `@nextAc` (ST_TLNextActionType §19.7.43).
pub(all) struct CT_TLTimeNodeSequence {
  /// §19.5.65 child `<p:cTn>` (CT_TLCommonTimeNodeData, required).
  cTn : @xml.Element
  /// §19.5.65 child `<p:prevCondLst>` (optional). Raw element because
  /// CT_TLTimeConditionList is not yet a typed wrapper.
  prev_cond_lst : @xml.Element?
  /// §19.5.65 child `<p:nextCondLst>` (optional).
  next_cond_lst : @xml.Element?
  /// §19.5.65 @concurrent (xsd:boolean).
  concurrent : Bool?
  /// §19.5.65 @prevAc (ST_TLPreviousActionType §19.7.45).
  prev_ac : ST_TLPreviousActionType?
  /// §19.5.65 @nextAc (ST_TLNextActionType §19.7.43).
  next_ac : ST_TLNextActionType?
  /// Source element QName (`<p:seq>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLTimeNodeSequence::from_element(
  element : @xml.Element,
) -> CT_TLTimeNodeSequence raise SchemaViolation {
  let cTn = match ttt_first_child(element, "cTn") {
    Some(e) => e
    None =>
      invalid_simple_type(
        "CT_TLTimeNodeSequence", "<seq/>", "missing required <cTn> child",
      )
  }
  let prev_cond_lst = ttt_first_child(element, "prevCondLst")
  let next_cond_lst = ttt_first_child(element, "nextCondLst")
  let concurrent = match ttt_attr(element, "concurrent") {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => Some(b)
        None =>
          invalid_simple_type(
            "CT_TLTimeNodeSequence/@concurrent", text, "expected xsd:boolean",
          )
      }
    None => None
  }
  let prev_ac = match ttt_attr(element, "prevAc") {
    Some(text) => Some(ST_TLPreviousActionType::parse(text))
    None => None
  }
  let next_ac = match ttt_attr(element, "nextAc") {
    Some(text) => Some(ST_TLNextActionType::parse(text))
    None => None
  }
  {
    cTn,
    prev_cond_lst,
    next_cond_lst,
    concurrent,
    prev_ac,
    next_ac,
    element_name: element.name,
  }
}

///|
pub fn CT_TLTimeNodeSequence::new(
  element : @xml.Element,
) -> CT_TLTimeNodeSequence {
  CT_TLTimeNodeSequence::from_element(element) catch {
    _ =>
      {
        cTn: { name: ttt_qname("cTn"), attributes: [], children: [] },
        prev_cond_lst: None,
        next_cond_lst: None,
        concurrent: None,
        prev_ac: None,
        next_ac: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLTimeNodeSequence::parse(
  element : @xml.Element,
) -> CT_TLTimeNodeSequence {
  CT_TLTimeNodeSequence::new(element)
}

///|
pub fn CT_TLTimeNodeSequence::to_element(
  self : CT_TLTimeNodeSequence,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.concurrent {
    Some(true) => attrs.push(ttt_attribute("concurrent", "true"))
    Some(false) => attrs.push(ttt_attribute("concurrent", "false"))
    None => ()
  }
  match self.prev_ac {
    Some(p) => attrs.push(ttt_attribute("prevAc", p.to_string()))
    None => ()
  }
  match self.next_ac {
    Some(n) => attrs.push(ttt_attribute("nextAc", n.to_string()))
    None => ()
  }
  let children : Array[@xml.Node] = [@xml.Element(self.cTn)]
  match self.prev_cond_lst {
    Some(e) => children.push(@xml.Element(e))
    None => ()
  }
  match self.next_cond_lst {
    Some(e) => children.push(@xml.Element(e))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children }
}

///|
/// XSD complex type CT_TLTimeNodeExclusive — Part 1 §19.5.40 excl
/// (Exclusive Time Node). One required `<p:cTn>` child
/// (CT_TLCommonTimeNodeData).
pub(all) struct CT_TLTimeNodeExclusive {
  /// §19.5.40 child `<p:cTn>` (required).
  cTn : @xml.Element
  /// Source element QName (`<p:excl>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLTimeNodeExclusive::from_element(
  element : @xml.Element,
) -> CT_TLTimeNodeExclusive raise SchemaViolation {
  let cTn = match ttt_first_child(element, "cTn") {
    Some(e) => e
    None =>
      invalid_simple_type(
        "CT_TLTimeNodeExclusive", "<excl/>", "missing required <cTn> child",
      )
  }
  { cTn, element_name: element.name }
}

///|
pub fn CT_TLTimeNodeExclusive::new(
  element : @xml.Element,
) -> CT_TLTimeNodeExclusive {
  CT_TLTimeNodeExclusive::from_element(element) catch {
    _ =>
      {
        cTn: { name: ttt_qname("cTn"), attributes: [], children: [] },
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLTimeNodeExclusive::parse(
  element : @xml.Element,
) -> CT_TLTimeNodeExclusive {
  CT_TLTimeNodeExclusive::new(element)
}

///|
pub fn CT_TLTimeNodeExclusive::to_element(
  self : CT_TLTimeNodeExclusive,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [],
    children: [@xml.Element(self.cTn)],
  }
}

// === §19.5.8 Behavior attribute name list =================================

///|
/// XSD complex type CT_TLBehaviorAttributeNameList — Part 1 §19.5.8
/// attrNameLst (Attribute Name List). A sequence of one-or-more
/// `<p:attrName>` xsd:string children. The list captures the
/// CSS/SMIL-style attribute paths a behaviour targets (e.g.
/// `"style.visibility"`, `"ppt_x"`).
pub(all) struct CT_TLBehaviorAttributeNameList {
  /// §19.5.8 child `<p:attrName>` text values (minOccurs=1,
  /// maxOccurs=unbounded).
  attr_names : Array[String]
  /// Source element QName (`<p:attrNameLst>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
fn collect_text(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for child in element.children {
    match child {
      @xml.Text(t) => buf.write_string(t)
      @xml.CData(t) => buf.write_string(t)
      _ => ()
    }
  }
  buf.to_string()
}

///|
pub fn CT_TLBehaviorAttributeNameList::from_element(
  element : @xml.Element,
) -> CT_TLBehaviorAttributeNameList raise SchemaViolation {
  let names : Array[String] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "attrName" {
          names.push(collect_text(e))
        }
      _ => ()
    }
  }
  if names.length() == 0 {
    invalid_simple_type(
      "CT_TLBehaviorAttributeNameList", "<attrNameLst/>", "requires at least one <attrName> child (minOccurs=1)",
    )
  }
  { attr_names: names, element_name: element.name }
}

///|
pub fn CT_TLBehaviorAttributeNameList::new(
  element : @xml.Element,
) -> CT_TLBehaviorAttributeNameList {
  CT_TLBehaviorAttributeNameList::from_element(element) catch {
    _ => { attr_names: [], element_name: element.name }
  }
}

///|
pub fn CT_TLBehaviorAttributeNameList::parse(
  element : @xml.Element,
) -> CT_TLBehaviorAttributeNameList {
  CT_TLBehaviorAttributeNameList::new(element)
}

///|
pub fn CT_TLBehaviorAttributeNameList::to_element(
  self : CT_TLBehaviorAttributeNameList,
) -> @xml.Element {
  let children : Array[@xml.Node] = []
  for n in self.attr_names {
    children.push(
      @xml.Element({
        name: ttt_qname("attrName"),
        attributes: [],
        children: [@xml.Text(n)],
      }),
    )
  }
  { name: self.element_name, attributes: [], children }
}

// === §19.5.19/§19.5.48/§19.5.42/§19.5.75 anim-variant value wrappers ======

///|
/// XSD complex type CT_TLAnimVariantBooleanVal — Part 1 §19.5.19 boolVal.
/// Required `@val` xsd:boolean attribute.
pub(all) struct CT_TLAnimVariantBooleanVal {
  /// §19.5.19 @val (xsd:boolean, required).
  val : Bool
  /// Source element QName (`<p:boolVal>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLAnimVariantBooleanVal::from_element(
  element : @xml.Element,
) -> CT_TLAnimVariantBooleanVal raise SchemaViolation {
  let val = match ttt_attr(element, "val") {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => b
        None =>
          invalid_simple_type(
            "CT_TLAnimVariantBooleanVal/@val", text, "expected xsd:boolean",
          )
      }
    None =>
      invalid_simple_type(
        "CT_TLAnimVariantBooleanVal", "<boolVal/>", "missing required @val attribute",
      )
  }
  { val, element_name: element.name }
}

///|
pub fn CT_TLAnimVariantBooleanVal::new(
  element : @xml.Element,
) -> CT_TLAnimVariantBooleanVal {
  CT_TLAnimVariantBooleanVal::from_element(element) catch {
    _ => { val: false, element_name: element.name }
  }
}

///|
pub fn CT_TLAnimVariantBooleanVal::parse(
  element : @xml.Element,
) -> CT_TLAnimVariantBooleanVal {
  CT_TLAnimVariantBooleanVal::new(element)
}

///|
pub fn CT_TLAnimVariantBooleanVal::to_element(
  self : CT_TLAnimVariantBooleanVal,
) -> @xml.Element {
  let v = if self.val { "true" } else { "false" }
  {
    name: self.element_name,
    attributes: [ttt_attribute("val", v)],
    children: [],
  }
}

///|
/// XSD complex type CT_TLAnimVariantIntegerVal — Part 1 §19.5.48 intVal.
/// Required `@val` xsd:int attribute.
pub(all) struct CT_TLAnimVariantIntegerVal {
  /// §19.5.48 @val (xsd:int, required).
  val : Int
  /// Source element QName (`<p:intVal>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLAnimVariantIntegerVal::from_element(
  element : @xml.Element,
) -> CT_TLAnimVariantIntegerVal raise SchemaViolation {
  let val = match ttt_attr(element, "val") {
    Some(text) =>
      match ttt_parse_int(text) {
        Some(n) => n
        None =>
          invalid_simple_type(
            "CT_TLAnimVariantIntegerVal/@val", text, "expected xsd:int",
          )
      }
    None =>
      invalid_simple_type(
        "CT_TLAnimVariantIntegerVal", "<intVal/>", "missing required @val attribute",
      )
  }
  { val, element_name: element.name }
}

///|
pub fn CT_TLAnimVariantIntegerVal::new(
  element : @xml.Element,
) -> CT_TLAnimVariantIntegerVal {
  CT_TLAnimVariantIntegerVal::from_element(element) catch {
    _ => { val: 0, element_name: element.name }
  }
}

///|
pub fn CT_TLAnimVariantIntegerVal::parse(
  element : @xml.Element,
) -> CT_TLAnimVariantIntegerVal {
  CT_TLAnimVariantIntegerVal::new(element)
}

///|
pub fn CT_TLAnimVariantIntegerVal::to_element(
  self : CT_TLAnimVariantIntegerVal,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [ttt_attribute("val", self.val.to_string())],
    children: [],
  }
}

///|
/// XSD complex type CT_TLAnimVariantFloatVal — Part 1 §19.5.42 fltVal.
/// Required `@val` xsd:float attribute.
pub(all) struct CT_TLAnimVariantFloatVal {
  /// §19.5.42 @val (xsd:float, required).
  val : Double
  /// Source element QName (`<p:fltVal>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLAnimVariantFloatVal::from_element(
  element : @xml.Element,
) -> CT_TLAnimVariantFloatVal raise SchemaViolation {
  let val = match ttt_attr(element, "val") {
    Some(text) =>
      match ttt_parse_float(text) {
        Some(d) => d
        None =>
          invalid_simple_type(
            "CT_TLAnimVariantFloatVal/@val", text, "expected xsd:float",
          )
      }
    None =>
      invalid_simple_type(
        "CT_TLAnimVariantFloatVal", "<fltVal/>", "missing required @val attribute",
      )
  }
  { val, element_name: element.name }
}

///|
pub fn CT_TLAnimVariantFloatVal::new(
  element : @xml.Element,
) -> CT_TLAnimVariantFloatVal {
  CT_TLAnimVariantFloatVal::from_element(element) catch {
    _ => { val: 0.0, element_name: element.name }
  }
}

///|
pub fn CT_TLAnimVariantFloatVal::parse(
  element : @xml.Element,
) -> CT_TLAnimVariantFloatVal {
  CT_TLAnimVariantFloatVal::new(element)
}

///|
pub fn CT_TLAnimVariantFloatVal::to_element(
  self : CT_TLAnimVariantFloatVal,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [ttt_attribute("val", self.val.to_string())],
    children: [],
  }
}

///|
/// XSD complex type CT_TLAnimVariantStringVal — Part 1 §19.5.75 strVal.
/// Required `@val` xsd:string attribute.
pub(all) struct CT_TLAnimVariantStringVal {
  /// §19.5.75 @val (xsd:string, required).
  val : String
  /// Source element QName (`<p:strVal>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLAnimVariantStringVal::from_element(
  element : @xml.Element,
) -> CT_TLAnimVariantStringVal raise SchemaViolation {
  let val = match ttt_attr(element, "val") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLAnimVariantStringVal", "<strVal/>", "missing required @val attribute",
      )
  }
  { val, element_name: element.name }
}

///|
pub fn CT_TLAnimVariantStringVal::new(
  element : @xml.Element,
) -> CT_TLAnimVariantStringVal {
  CT_TLAnimVariantStringVal::from_element(element) catch {
    _ => { val: "", element_name: element.name }
  }
}

///|
pub fn CT_TLAnimVariantStringVal::parse(
  element : @xml.Element,
) -> CT_TLAnimVariantStringVal {
  CT_TLAnimVariantStringVal::new(element)
}

///|
pub fn CT_TLAnimVariantStringVal::to_element(
  self : CT_TLAnimVariantStringVal,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [ttt_attribute("val", self.val)],
    children: [],
  }
}

// === §19.5.10 / §19.5.18 colour-by transforms =============================

///|
/// XSD complex type CT_TLByRgbColorTransform — Part 1 §19.5.18 rgb (RGB
/// Colour Transform Float Type). Three required percentages (r/g/b)
/// typed a:ST_FixedPercentage (DML §20.1.10.16), preserved as raw
/// lexical strings.
pub(all) struct CT_TLByRgbColorTransform {
  /// §19.5.18 @r (a:ST_FixedPercentage, required).
  r : String
  /// §19.5.18 @g (a:ST_FixedPercentage, required).
  g : String
  /// §19.5.18 @b (a:ST_FixedPercentage, required).
  b : String
  /// Source element QName (`<p:rgb>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLByRgbColorTransform::from_element(
  element : @xml.Element,
) -> CT_TLByRgbColorTransform raise SchemaViolation {
  let r = match ttt_attr(element, "r") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLByRgbColorTransform", "<rgb/>", "missing required @r attribute",
      )
  }
  let g = match ttt_attr(element, "g") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLByRgbColorTransform", "<rgb/>", "missing required @g attribute",
      )
  }
  let b = match ttt_attr(element, "b") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLByRgbColorTransform", "<rgb/>", "missing required @b attribute",
      )
  }
  { r, g, b, element_name: element.name }
}

///|
pub fn CT_TLByRgbColorTransform::new(
  element : @xml.Element,
) -> CT_TLByRgbColorTransform {
  CT_TLByRgbColorTransform::from_element(element) catch {
    _ => { r: "", g: "", b: "", element_name: element.name }
  }
}

///|
pub fn CT_TLByRgbColorTransform::parse(
  element : @xml.Element,
) -> CT_TLByRgbColorTransform {
  CT_TLByRgbColorTransform::new(element)
}

///|
pub fn CT_TLByRgbColorTransform::to_element(
  self : CT_TLByRgbColorTransform,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [
      ttt_attribute("r", self.r),
      ttt_attribute("g", self.g),
      ttt_attribute("b", self.b),
    ],
    children: [],
  }
}

///|
/// XSD complex type CT_TLByHslColorTransform — Part 1 §19.5.10 hsl (HSL
/// Colour Transform). Three required attributes: `@h` (a:ST_Angle,
/// DML §20.1.10.3) plus `@s`/`@l` (a:ST_FixedPercentage, DML §20.1.10.16),
/// preserved as raw lexical strings.
pub(all) struct CT_TLByHslColorTransform {
  /// §19.5.10 @h (a:ST_Angle, required).
  h : String
  /// §19.5.10 @s (a:ST_FixedPercentage, required).
  s : String
  /// §19.5.10 @l (a:ST_FixedPercentage, required).
  l : String
  /// Source element QName (`<p:hsl>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLByHslColorTransform::from_element(
  element : @xml.Element,
) -> CT_TLByHslColorTransform raise SchemaViolation {
  let h = match ttt_attr(element, "h") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLByHslColorTransform", "<hsl/>", "missing required @h attribute",
      )
  }
  let s = match ttt_attr(element, "s") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLByHslColorTransform", "<hsl/>", "missing required @s attribute",
      )
  }
  let l = match ttt_attr(element, "l") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLByHslColorTransform", "<hsl/>", "missing required @l attribute",
      )
  }
  { h, s, l, element_name: element.name }
}

///|
pub fn CT_TLByHslColorTransform::new(
  element : @xml.Element,
) -> CT_TLByHslColorTransform {
  CT_TLByHslColorTransform::from_element(element) catch {
    _ => { h: "", s: "", l: "", element_name: element.name }
  }
}

///|
pub fn CT_TLByHslColorTransform::parse(
  element : @xml.Element,
) -> CT_TLByHslColorTransform {
  CT_TLByHslColorTransform::new(element)
}

///|
pub fn CT_TLByHslColorTransform::to_element(
  self : CT_TLByHslColorTransform,
) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [
      ttt_attribute("h", self.h),
      ttt_attribute("s", self.s),
      ttt_attribute("l", self.l),
    ],
    children: [],
  }
}

///|
/// XSD complex type CT_TLByAnimateColorTransform — Part 1 §19.5.10 by
/// (Animate Colour By). Required xsd:choice between `<p:rgb>`
/// (CT_TLByRgbColorTransform) and `<p:hsl>` (CT_TLByHslColorTransform).
pub(all) enum CT_TLByAnimateColorTransformChoice {
  /// §19.5.10 rgb branch.
  ByColorRgb(CT_TLByRgbColorTransform)
  /// §19.5.10 hsl branch.
  ByColorHsl(CT_TLByHslColorTransform)
} derive(Eq, Debug)

///|
pub(all) struct CT_TLByAnimateColorTransform {
  /// §19.5.10 xsd:choice (rgb | hsl), required.
  choice : CT_TLByAnimateColorTransformChoice
  /// Source element QName (`<p:by>` inside `<p:animClr>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLByAnimateColorTransform::from_element(
  element : @xml.Element,
) -> CT_TLByAnimateColorTransform raise SchemaViolation {
  let choice = match ttt_first_child(element, "rgb") {
    Some(e) => ByColorRgb(CT_TLByRgbColorTransform::from_element(e))
    None =>
      match ttt_first_child(element, "hsl") {
        Some(e) => ByColorHsl(CT_TLByHslColorTransform::from_element(e))
        None =>
          invalid_simple_type(
            "CT_TLByAnimateColorTransform", "<by/>", "missing required rgb|hsl choice",
          )
      }
  }
  { choice, element_name: element.name }
}

///|
pub fn CT_TLByAnimateColorTransform::new(
  element : @xml.Element,
) -> CT_TLByAnimateColorTransform {
  CT_TLByAnimateColorTransform::from_element(element) catch {
    _ =>
      {
        choice: ByColorRgb({
          r: "",
          g: "",
          b: "",
          element_name: ttt_qname("rgb"),
        }),
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLByAnimateColorTransform::parse(
  element : @xml.Element,
) -> CT_TLByAnimateColorTransform {
  CT_TLByAnimateColorTransform::new(element)
}

///|
pub fn CT_TLByAnimateColorTransform::to_element(
  self : CT_TLByAnimateColorTransform,
) -> @xml.Element {
  let child : @xml.Element = match self.choice {
    ByColorRgb(r) => r.to_element()
    ByColorHsl(h) => h.to_element()
  }
  { name: self.element_name, attributes: [], children: [@xml.Element(child)] }
}

// === §19.5.3 animEffect ===================================================

///|
/// XSD complex type CT_TLAnimateEffectBehavior — Part 1 §19.5.3
/// animEffect (Animate Effect). Required `<p:cBhvr>` (typed
/// CT_TLCommonBehaviorData, kept as raw element) plus optional
/// `<p:progress>` (typed CT_TLAnimVariant). Three optional attributes:
/// `@transition` (ST_TLAnimateEffectTransition §19.7.24, default
/// `"in"`), `@filter` (xsd:string), `@prLst` (xsd:string property list).
pub(all) struct CT_TLAnimateEffectBehavior {
  /// §19.5.3 child `<p:cBhvr>` (CT_TLCommonBehaviorData, required).
  cBhvr : @xml.Element
  /// §19.5.3 child `<p:progress>` (CT_TLAnimVariant §19.5.92, optional).
  progress : @xml.Element?
  /// §19.5.3 @transition (ST_TLAnimateEffectTransition).
  transition : ST_TLAnimateEffectTransition?
  /// §19.5.3 @filter (xsd:string).
  filter : String?
  /// §19.5.3 @prLst (xsd:string).
  pr_lst : String?
  /// Source element QName (`<p:animEffect>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLAnimateEffectBehavior::from_element(
  element : @xml.Element,
) -> CT_TLAnimateEffectBehavior raise SchemaViolation {
  let cBhvr = match ttt_first_child(element, "cBhvr") {
    Some(e) => e
    None =>
      invalid_simple_type(
        "CT_TLAnimateEffectBehavior", "<animEffect/>", "missing required <cBhvr> child",
      )
  }
  let progress = ttt_first_child(element, "progress")
  let transition = match ttt_attr(element, "transition") {
    Some(text) => Some(ST_TLAnimateEffectTransition::parse(text))
    None => None
  }
  let filter = ttt_attr(element, "filter")
  let pr_lst = ttt_attr(element, "prLst")
  { cBhvr, progress, transition, filter, pr_lst, element_name: element.name }
}

///|
pub fn CT_TLAnimateEffectBehavior::new(
  element : @xml.Element,
) -> CT_TLAnimateEffectBehavior {
  CT_TLAnimateEffectBehavior::from_element(element) catch {
    _ =>
      {
        cBhvr: { name: ttt_qname("cBhvr"), attributes: [], children: [] },
        progress: None,
        transition: None,
        filter: None,
        pr_lst: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLAnimateEffectBehavior::parse(
  element : @xml.Element,
) -> CT_TLAnimateEffectBehavior {
  CT_TLAnimateEffectBehavior::new(element)
}

///|
pub fn CT_TLAnimateEffectBehavior::to_element(
  self : CT_TLAnimateEffectBehavior,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.transition {
    Some(t) => attrs.push(ttt_attribute("transition", t.to_string()))
    None => ()
  }
  match self.filter {
    Some(s) => attrs.push(ttt_attribute("filter", s))
    None => ()
  }
  match self.pr_lst {
    Some(s) => attrs.push(ttt_attribute("prLst", s))
    None => ()
  }
  let children : Array[@xml.Node] = [@xml.Element(self.cBhvr)]
  match self.progress {
    Some(e) => children.push(@xml.Element(e))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children }
}

// === §19.5.57 / media nodes / templates / builds ==========================

///|
/// XSD complex type CT_TLPoint — Part 1 §19.5.57 (Time List Point). Used
/// as the `<p:by>`, `<p:from>`, `<p:to>`, `<p:rCtr>` endpoints of
/// `<p:animMotion>` / `<p:animScale>`. Two required percentage
/// attributes `@x` / `@y` typed a:ST_Percentage (DML §20.1.10.45);
/// preserved as raw lexical strings.
pub(all) struct CT_TLPoint {
  /// §19.5.57 @x (a:ST_Percentage, required).
  x : String
  /// §19.5.57 @y (a:ST_Percentage, required).
  y : String
  /// Source element QName.
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLPoint::from_element(
  element : @xml.Element,
) -> CT_TLPoint raise SchemaViolation {
  let x = match ttt_attr(element, "x") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLPoint", "<by|from|to|rCtr/>", "missing required @x attribute",
      )
  }
  let y = match ttt_attr(element, "y") {
    Some(text) => text
    None =>
      invalid_simple_type(
        "CT_TLPoint", "<by|from|to|rCtr/>", "missing required @y attribute",
      )
  }
  { x, y, element_name: element.name }
}

///|
pub fn CT_TLPoint::new(element : @xml.Element) -> CT_TLPoint {
  CT_TLPoint::from_element(element) catch {
    _ => { x: "", y: "", element_name: element.name }
  }
}

///|
pub fn CT_TLPoint::parse(element : @xml.Element) -> CT_TLPoint {
  CT_TLPoint::new(element)
}

///|
pub fn CT_TLPoint::to_element(self : CT_TLPoint) -> @xml.Element {
  {
    name: self.element_name,
    attributes: [ttt_attribute("x", self.x), ttt_attribute("y", self.y)],
    children: [],
  }
}

///|
/// XSD complex type CT_TLCommonMediaNodeData — Part 1 §19.5.31 cMediaNode
/// (Common Media Node Properties). One required `<p:cTn>`
/// (CT_TLCommonTimeNodeData) plus one required `<p:tgtEl>`
/// (CT_TLTimeTargetElement). Four optional attributes: `@vol`
/// (a:ST_PositiveFixedPercentage default "50%"), `@mute` (xsd:boolean
/// default false), `@numSld` (xsd:unsignedInt default 1),
/// `@showWhenStopped` (xsd:boolean default true).
pub(all) struct CT_TLCommonMediaNodeData {
  /// §19.5.31 child `<p:cTn>` (CT_TLCommonTimeNodeData, required).
  cTn : @xml.Element
  /// §19.5.31 child `<p:tgtEl>` (CT_TLTimeTargetElement, required).
  tgtEl : CT_TLTimeTargetElement
  /// §19.5.31 @vol (a:ST_PositiveFixedPercentage, default "50%"). Raw
  /// lexical string.
  vol : String?
  /// §19.5.31 @mute (xsd:boolean, default false).
  mute : Bool?
  /// §19.5.31 @numSld (xsd:unsignedInt, default 1).
  num_sld : UInt?
  /// §19.5.31 @showWhenStopped (xsd:boolean, default true).
  show_when_stopped : Bool?
  /// Source element QName (`<p:cMediaNode>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLCommonMediaNodeData::from_element(
  element : @xml.Element,
) -> CT_TLCommonMediaNodeData raise SchemaViolation {
  let cTn = match ttt_first_child(element, "cTn") {
    Some(e) => e
    None =>
      invalid_simple_type(
        "CT_TLCommonMediaNodeData", "<cMediaNode/>", "missing required <cTn> child",
      )
  }
  let tgtEl = match ttt_first_child(element, "tgtEl") {
    Some(e) => CT_TLTimeTargetElement::from_element(e)
    None =>
      invalid_simple_type(
        "CT_TLCommonMediaNodeData", "<cMediaNode/>", "missing required <tgtEl> child",
      )
  }
  let vol = ttt_attr(element, "vol")
  let mute = match ttt_attr(element, "mute") {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => Some(b)
        None =>
          invalid_simple_type(
            "CT_TLCommonMediaNodeData/@mute", text, "expected xsd:boolean",
          )
      }
    None => None
  }
  let num_sld = match ttt_attr(element, "numSld") {
    Some(text) =>
      match parse_xsd_unsigned_int(text) {
        Some(n) => Some(n)
        None =>
          invalid_simple_type(
            "CT_TLCommonMediaNodeData/@numSld", text, "expected xsd:unsignedInt",
          )
      }
    None => None
  }
  let show_when_stopped = match ttt_attr(element, "showWhenStopped") {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => Some(b)
        None =>
          invalid_simple_type(
            "CT_TLCommonMediaNodeData/@showWhenStopped", text, "expected xsd:boolean",
          )
      }
    None => None
  }
  {
    cTn,
    tgtEl,
    vol,
    mute,
    num_sld,
    show_when_stopped,
    element_name: element.name,
  }
}

///|
pub fn CT_TLCommonMediaNodeData::new(
  element : @xml.Element,
) -> CT_TLCommonMediaNodeData {
  CT_TLCommonMediaNodeData::from_element(element) catch {
    _ =>
      {
        cTn: { name: ttt_qname("cTn"), attributes: [], children: [] },
        tgtEl: {
          choice: TimeTargetSld(ttt_qname("sldTgt")),
          element_name: ttt_qname("tgtEl"),
        },
        vol: None,
        mute: None,
        num_sld: None,
        show_when_stopped: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLCommonMediaNodeData::parse(
  element : @xml.Element,
) -> CT_TLCommonMediaNodeData {
  CT_TLCommonMediaNodeData::new(element)
}

///|
pub fn CT_TLCommonMediaNodeData::to_element(
  self : CT_TLCommonMediaNodeData,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.vol {
    Some(s) => attrs.push(ttt_attribute("vol", s))
    None => ()
  }
  match self.mute {
    Some(true) => attrs.push(ttt_attribute("mute", "true"))
    Some(false) => attrs.push(ttt_attribute("mute", "false"))
    None => ()
  }
  match self.num_sld {
    Some(n) => attrs.push(ttt_attribute("numSld", n.to_string()))
    None => ()
  }
  match self.show_when_stopped {
    Some(true) => attrs.push(ttt_attribute("showWhenStopped", "true"))
    Some(false) => attrs.push(ttt_attribute("showWhenStopped", "false"))
    None => ()
  }
  {
    name: self.element_name,
    attributes: attrs,
    children: [@xml.Element(self.cTn), @xml.Element(self.tgtEl.to_element())],
  }
}

///|
/// XSD complex type CT_TLMediaNodeAudio — Part 1 §19.5.49 audio
/// (Audio). One required `<p:cMediaNode>` child plus one optional
/// `@isNarration` xsd:boolean attribute (default false).
pub(all) struct CT_TLMediaNodeAudio {
  /// §19.5.49 child `<p:cMediaNode>` (CT_TLCommonMediaNodeData, required).
  cMediaNode : CT_TLCommonMediaNodeData
  /// §19.5.49 @isNarration (xsd:boolean, default false).
  is_narration : Bool?
  /// Source element QName (`<p:audio>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLMediaNodeAudio::from_element(
  element : @xml.Element,
) -> CT_TLMediaNodeAudio raise SchemaViolation {
  let cMediaNode = match ttt_first_child(element, "cMediaNode") {
    Some(e) => CT_TLCommonMediaNodeData::from_element(e)
    None =>
      invalid_simple_type(
        "CT_TLMediaNodeAudio", "<audio/>", "missing required <cMediaNode> child",
      )
  }
  let is_narration = match ttt_attr(element, "isNarration") {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => Some(b)
        None =>
          invalid_simple_type(
            "CT_TLMediaNodeAudio/@isNarration", text, "expected xsd:boolean",
          )
      }
    None => None
  }
  { cMediaNode, is_narration, element_name: element.name }
}

///|
pub fn CT_TLMediaNodeAudio::new(element : @xml.Element) -> CT_TLMediaNodeAudio {
  CT_TLMediaNodeAudio::from_element(element) catch {
    _ =>
      {
        cMediaNode: {
          cTn: { name: ttt_qname("cTn"), attributes: [], children: [] },
          tgtEl: {
            choice: TimeTargetSld(ttt_qname("sldTgt")),
            element_name: ttt_qname("tgtEl"),
          },
          vol: None,
          mute: None,
          num_sld: None,
          show_when_stopped: None,
          element_name: ttt_qname("cMediaNode"),
        },
        is_narration: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLMediaNodeAudio::parse(
  element : @xml.Element,
) -> CT_TLMediaNodeAudio {
  CT_TLMediaNodeAudio::new(element)
}

///|
pub fn CT_TLMediaNodeAudio::to_element(
  self : CT_TLMediaNodeAudio,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.is_narration {
    Some(true) => attrs.push(ttt_attribute("isNarration", "true"))
    Some(false) => attrs.push(ttt_attribute("isNarration", "false"))
    None => ()
  }
  {
    name: self.element_name,
    attributes: attrs,
    children: [@xml.Element(self.cMediaNode.to_element())],
  }
}

///|
/// XSD complex type CT_TLMediaNodeVideo — Part 1 §19.5.85 video (Video).
/// One required `<p:cMediaNode>` child plus one optional `@fullScrn`
/// xsd:boolean attribute (default false).
pub(all) struct CT_TLMediaNodeVideo {
  /// §19.5.85 child `<p:cMediaNode>` (CT_TLCommonMediaNodeData, required).
  cMediaNode : CT_TLCommonMediaNodeData
  /// §19.5.85 @fullScrn (xsd:boolean, default false).
  full_scrn : Bool?
  /// Source element QName (`<p:video>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLMediaNodeVideo::from_element(
  element : @xml.Element,
) -> CT_TLMediaNodeVideo raise SchemaViolation {
  let cMediaNode = match ttt_first_child(element, "cMediaNode") {
    Some(e) => CT_TLCommonMediaNodeData::from_element(e)
    None =>
      invalid_simple_type(
        "CT_TLMediaNodeVideo", "<video/>", "missing required <cMediaNode> child",
      )
  }
  let full_scrn = match ttt_attr(element, "fullScrn") {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => Some(b)
        None =>
          invalid_simple_type(
            "CT_TLMediaNodeVideo/@fullScrn", text, "expected xsd:boolean",
          )
      }
    None => None
  }
  { cMediaNode, full_scrn, element_name: element.name }
}

///|
pub fn CT_TLMediaNodeVideo::new(element : @xml.Element) -> CT_TLMediaNodeVideo {
  CT_TLMediaNodeVideo::from_element(element) catch {
    _ =>
      {
        cMediaNode: {
          cTn: { name: ttt_qname("cTn"), attributes: [], children: [] },
          tgtEl: {
            choice: TimeTargetSld(ttt_qname("sldTgt")),
            element_name: ttt_qname("tgtEl"),
          },
          vol: None,
          mute: None,
          num_sld: None,
          show_when_stopped: None,
          element_name: ttt_qname("cMediaNode"),
        },
        full_scrn: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLMediaNodeVideo::parse(
  element : @xml.Element,
) -> CT_TLMediaNodeVideo {
  CT_TLMediaNodeVideo::new(element)
}

///|
pub fn CT_TLMediaNodeVideo::to_element(
  self : CT_TLMediaNodeVideo,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.full_scrn {
    Some(true) => attrs.push(ttt_attribute("fullScrn", "true"))
    Some(false) => attrs.push(ttt_attribute("fullScrn", "false"))
    None => ()
  }
  {
    name: self.element_name,
    attributes: attrs,
    children: [@xml.Element(self.cMediaNode.to_element())],
  }
}

// === §19.5.76 / §19.5.78 build templates ==================================

///|
/// XSD complex type CT_TLTemplate — Part 1 §19.5.78 tmpl (Build Template).
/// One required `<p:tnLst>` child (CT_TimeNodeList §19.5.86) preserved
/// as raw children of time-node elements. One optional `@lvl`
/// (xsd:unsignedInt, default 0).
pub(all) struct CT_TLTemplate {
  /// §19.5.78 child `<p:tnLst>` time-node children (CT_TimeNodeList).
  /// Each element is a `<p:par>` / `<p:seq>` / leaf time-node node.
  tnLst : Array[@xml.Element]
  /// §19.5.78 @lvl (xsd:unsignedInt, default 0).
  lvl : UInt?
  /// Source element QName (`<p:tmpl>`).
  element_name : @xml.QName
  /// Source `<p:tnLst>` QName (preserved for round-trip).
  tnLst_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLTemplate::from_element(
  element : @xml.Element,
) -> CT_TLTemplate raise SchemaViolation {
  let (tn_lst, tn_lst_name) = match ttt_first_child(element, "tnLst") {
    Some(e) => {
      let kids : Array[@xml.Element] = []
      for child in e.children {
        match child {
          @xml.Element(c) => kids.push(c)
          _ => ()
        }
      }
      (kids, e.name)
    }
    None =>
      invalid_simple_type(
        "CT_TLTemplate", "<tmpl/>", "missing required <tnLst> child",
      )
  }
  let lvl = match ttt_attr(element, "lvl") {
    Some(text) =>
      match parse_xsd_unsigned_int(text) {
        Some(n) => Some(n)
        None =>
          invalid_simple_type(
            "CT_TLTemplate/@lvl", text, "expected xsd:unsignedInt",
          )
      }
    None => None
  }
  { tnLst: tn_lst, lvl, element_name: element.name, tnLst_name: tn_lst_name }
}

///|
pub fn CT_TLTemplate::new(element : @xml.Element) -> CT_TLTemplate {
  CT_TLTemplate::from_element(element) catch {
    _ =>
      {
        tnLst: [],
        lvl: None,
        element_name: element.name,
        tnLst_name: ttt_qname("tnLst"),
      }
  }
}

///|
pub fn CT_TLTemplate::parse(element : @xml.Element) -> CT_TLTemplate {
  CT_TLTemplate::new(element)
}

///|
pub fn CT_TLTemplate::to_element(self : CT_TLTemplate) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  match self.lvl {
    Some(n) => attrs.push(ttt_attribute("lvl", n.to_string()))
    None => ()
  }
  let tn_children : Array[@xml.Node] = []
  for e in self.tnLst {
    tn_children.push(@xml.Element(e))
  }
  let tn_lst_el : @xml.Element = {
    name: self.tnLst_name,
    attributes: [],
    children: tn_children,
  }
  {
    name: self.element_name,
    attributes: attrs,
    children: [@xml.Element(tn_lst_el)],
  }
}

///|
/// XSD complex type CT_TLTemplateList — Part 1 §19.5.78 tmplLst (Build
/// Template List). Zero or up to nine `<p:tmpl>` children.
pub(all) struct CT_TLTemplateList {
  /// §19.5.78 child `<p:tmpl>` entries (minOccurs=0, maxOccurs=9).
  templates : Array[CT_TLTemplate]
  /// Source element QName (`<p:tmplLst>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLTemplateList::from_element(
  element : @xml.Element,
) -> CT_TLTemplateList raise SchemaViolation {
  let templates : Array[CT_TLTemplate] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "tmpl" {
          templates.push(CT_TLTemplate::from_element(e))
        }
      _ => ()
    }
  }
  if templates.length() > 9 {
    invalid_simple_type(
      "CT_TLTemplateList",
      "<tmplLst/>",
      "too many <tmpl> children: " +
      templates.length().to_string() +
      " (maxOccurs=9)",
    )
  }
  { templates, element_name: element.name }
}

///|
pub fn CT_TLTemplateList::new(element : @xml.Element) -> CT_TLTemplateList {
  CT_TLTemplateList::from_element(element) catch {
    _ => { templates: [], element_name: element.name }
  }
}

///|
pub fn CT_TLTemplateList::parse(element : @xml.Element) -> CT_TLTemplateList {
  CT_TLTemplateList::new(element)
}

///|
pub fn CT_TLTemplateList::to_element(self : CT_TLTemplateList) -> @xml.Element {
  let children : Array[@xml.Node] = []
  for t in self.templates {
    children.push(@xml.Element(t.to_element()))
  }
  { name: self.element_name, attributes: [], children }
}

///|
/// XSD complex type CT_TLBuildParagraph — Part 1 §19.5.13 bldP (Build
/// Paragraph). Optional `<p:tmplLst>` child plus the AG_TLBuild attribute
/// group (`@spid` required, `@grpId` required, `@uiExpand` optional)
/// and four bldP-specific attributes: `@build` (ST_TLParaBuildType
/// §19.7.44, default "whole"), `@bldLvl` (xsd:unsignedInt, default 1),
/// `@animBg` (xsd:boolean, default false),
/// `@autoUpdateAnimBg` (xsd:boolean, default true), `@rev`
/// (xsd:boolean, default false), `@advAuto` (ST_TLTime,
/// default "indefinite").
pub(all) struct CT_TLBuildParagraph {
  /// §19.5.13 child `<p:tmplLst>` (CT_TLTemplateList, optional).
  tmplLst : CT_TLTemplateList?
  /// §19.5.13 @spid (a:ST_DrawingElementId, required). Raw lexical form.
  spid : String
  /// §19.5.13 @grpId (xsd:unsignedInt, required).
  grp_id : UInt
  /// §19.5.13 @uiExpand (xsd:boolean, default false).
  ui_expand : Bool?
  /// §19.5.13 @build (ST_TLParaBuildType, default "whole").
  build : ST_TLParaBuildType?
  /// §19.5.13 @bldLvl (xsd:unsignedInt, default 1).
  bld_lvl : UInt?
  /// §19.5.13 @animBg (xsd:boolean, default false).
  anim_bg : Bool?
  /// §19.5.13 @autoUpdateAnimBg (xsd:boolean, default true).
  auto_update_anim_bg : Bool?
  /// §19.5.13 @rev (xsd:boolean, default false).
  rev : Bool?
  /// §19.5.13 @advAuto (ST_TLTime, default "indefinite").
  adv_auto : ST_TLTime?
  /// Source element QName (`<p:bldP>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
fn require_uint(
  element : @xml.Element,
  name : String,
  owner : String,
  tag : String,
) -> UInt raise SchemaViolation {
  match ttt_attr(element, name) {
    Some(text) =>
      match parse_xsd_unsigned_int(text) {
        Some(n) => n
        None =>
          invalid_simple_type(
            owner + "/@" + name,
            text,
            "expected xsd:unsignedInt",
          )
      }
    None =>
      invalid_simple_type(
        owner,
        tag,
        "missing required @" + name + " attribute",
      )
  }
}

///|
fn require_string(
  element : @xml.Element,
  name : String,
  owner : String,
  tag : String,
) -> String raise SchemaViolation {
  match ttt_attr(element, name) {
    Some(text) => text
    None =>
      invalid_simple_type(
        owner,
        tag,
        "missing required @" + name + " attribute",
      )
  }
}

///|
fn optional_bool(
  element : @xml.Element,
  name : String,
  owner : String,
) -> Bool? raise SchemaViolation {
  match ttt_attr(element, name) {
    Some(text) =>
      match ttt_parse_bool(text) {
        Some(b) => Some(b)
        None =>
          invalid_simple_type(owner + "/@" + name, text, "expected xsd:boolean")
      }
    None => None
  }
}

///|
fn optional_uint(
  element : @xml.Element,
  name : String,
  owner : String,
) -> UInt? raise SchemaViolation {
  match ttt_attr(element, name) {
    Some(text) =>
      match parse_xsd_unsigned_int(text) {
        Some(n) => Some(n)
        None =>
          invalid_simple_type(
            owner + "/@" + name,
            text,
            "expected xsd:unsignedInt",
          )
      }
    None => None
  }
}

///|
pub fn CT_TLBuildParagraph::from_element(
  element : @xml.Element,
) -> CT_TLBuildParagraph raise SchemaViolation {
  let tmplLst = match ttt_first_child(element, "tmplLst") {
    Some(e) => Some(CT_TLTemplateList::from_element(e))
    None => None
  }
  let spid = require_string(element, "spid", "CT_TLBuildParagraph", "<bldP/>")
  let grp_id = require_uint(element, "grpId", "CT_TLBuildParagraph", "<bldP/>")
  let ui_expand = optional_bool(element, "uiExpand", "CT_TLBuildParagraph")
  let build = match ttt_attr(element, "build") {
    Some(text) => Some(ST_TLParaBuildType::parse(text))
    None => None
  }
  let bld_lvl = optional_uint(element, "bldLvl", "CT_TLBuildParagraph")
  let anim_bg = optional_bool(element, "animBg", "CT_TLBuildParagraph")
  let auto_update_anim_bg = optional_bool(
    element, "autoUpdateAnimBg", "CT_TLBuildParagraph",
  )
  let rev = optional_bool(element, "rev", "CT_TLBuildParagraph")
  let adv_auto = match ttt_attr(element, "advAuto") {
    Some(text) => Some(ST_TLTime::parse(text))
    None => None
  }
  {
    tmplLst,
    spid,
    grp_id,
    ui_expand,
    build,
    bld_lvl,
    anim_bg,
    auto_update_anim_bg,
    rev,
    adv_auto,
    element_name: element.name,
  }
}

///|
pub fn CT_TLBuildParagraph::new(element : @xml.Element) -> CT_TLBuildParagraph {
  CT_TLBuildParagraph::from_element(element) catch {
    _ =>
      {
        tmplLst: None,
        spid: "",
        grp_id: 0U,
        ui_expand: None,
        build: None,
        bld_lvl: None,
        anim_bg: None,
        auto_update_anim_bg: None,
        rev: None,
        adv_auto: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLBuildParagraph::parse(
  element : @xml.Element,
) -> CT_TLBuildParagraph {
  CT_TLBuildParagraph::new(element)
}

///|
pub fn CT_TLBuildParagraph::to_element(
  self : CT_TLBuildParagraph,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    ttt_attribute("spid", self.spid),
    ttt_attribute("grpId", self.grp_id.to_string()),
  ]
  match self.ui_expand {
    Some(true) => attrs.push(ttt_attribute("uiExpand", "true"))
    Some(false) => attrs.push(ttt_attribute("uiExpand", "false"))
    None => ()
  }
  match self.build {
    Some(b) => attrs.push(ttt_attribute("build", b.to_string()))
    None => ()
  }
  match self.bld_lvl {
    Some(n) => attrs.push(ttt_attribute("bldLvl", n.to_string()))
    None => ()
  }
  match self.anim_bg {
    Some(true) => attrs.push(ttt_attribute("animBg", "true"))
    Some(false) => attrs.push(ttt_attribute("animBg", "false"))
    None => ()
  }
  match self.auto_update_anim_bg {
    Some(true) => attrs.push(ttt_attribute("autoUpdateAnimBg", "true"))
    Some(false) => attrs.push(ttt_attribute("autoUpdateAnimBg", "false"))
    None => ()
  }
  match self.rev {
    Some(true) => attrs.push(ttt_attribute("rev", "true"))
    Some(false) => attrs.push(ttt_attribute("rev", "false"))
    None => ()
  }
  match self.adv_auto {
    Some(t) => attrs.push(ttt_attribute("advAuto", t.to_string()))
    None => ()
  }
  let children : Array[@xml.Node] = []
  match self.tmplLst {
    Some(t) => children.push(@xml.Element(t.to_element()))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children }
}

///|
/// XSD complex type CT_TLBuildDiagram — Part 1 §19.5.14 bldDgm (Build
/// Diagram). AG_TLBuild attribute group plus `@bld` (ST_TLDiagramBuildType
/// §19.7.36, default "whole").
pub(all) struct CT_TLBuildDiagram {
  /// §19.5.14 @spid (a:ST_DrawingElementId, required).
  spid : String
  /// §19.5.14 @grpId (xsd:unsignedInt, required).
  grp_id : UInt
  /// §19.5.14 @uiExpand (xsd:boolean, default false).
  ui_expand : Bool?
  /// §19.5.14 @bld (ST_TLDiagramBuildType, default "whole").
  bld : ST_TLDiagramBuildType?
  /// Source element QName (`<p:bldDgm>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLBuildDiagram::from_element(
  element : @xml.Element,
) -> CT_TLBuildDiagram raise SchemaViolation {
  let spid = require_string(element, "spid", "CT_TLBuildDiagram", "<bldDgm/>")
  let grp_id = require_uint(element, "grpId", "CT_TLBuildDiagram", "<bldDgm/>")
  let ui_expand = optional_bool(element, "uiExpand", "CT_TLBuildDiagram")
  let bld = match ttt_attr(element, "bld") {
    Some(text) => Some(ST_TLDiagramBuildType::parse(text))
    None => None
  }
  { spid, grp_id, ui_expand, bld, element_name: element.name }
}

///|
pub fn CT_TLBuildDiagram::new(element : @xml.Element) -> CT_TLBuildDiagram {
  CT_TLBuildDiagram::from_element(element) catch {
    _ =>
      {
        spid: "",
        grp_id: 0U,
        ui_expand: None,
        bld: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLBuildDiagram::parse(element : @xml.Element) -> CT_TLBuildDiagram {
  CT_TLBuildDiagram::new(element)
}

///|
pub fn CT_TLBuildDiagram::to_element(self : CT_TLBuildDiagram) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    ttt_attribute("spid", self.spid),
    ttt_attribute("grpId", self.grp_id.to_string()),
  ]
  match self.ui_expand {
    Some(true) => attrs.push(ttt_attribute("uiExpand", "true"))
    Some(false) => attrs.push(ttt_attribute("uiExpand", "false"))
    None => ()
  }
  match self.bld {
    Some(b) => attrs.push(ttt_attribute("bld", b.to_string()))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

///|
/// XSD complex type CT_TLOleBuildChart — Part 1 §19.5.15 bldOleChart
/// (Build OLE Chart). AG_TLBuild attribute group plus `@bld`
/// (ST_TLOleChartBuildType §19.7.37, default "allAtOnce") and `@animBg`
/// (xsd:boolean, default true — distinct from the bldP default).
pub(all) struct CT_TLOleBuildChart {
  /// §19.5.15 @spid (required).
  spid : String
  /// §19.5.15 @grpId (required).
  grp_id : UInt
  /// §19.5.15 @uiExpand (default false).
  ui_expand : Bool?
  /// §19.5.15 @bld (ST_TLOleChartBuildType, default "allAtOnce").
  bld : ST_TLOleChartBuildType?
  /// §19.5.15 @animBg (xsd:boolean, default true).
  anim_bg : Bool?
  /// Source element QName (`<p:bldOleChart>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_TLOleBuildChart::from_element(
  element : @xml.Element,
) -> CT_TLOleBuildChart raise SchemaViolation {
  let spid = require_string(
    element, "spid", "CT_TLOleBuildChart", "<bldOleChart/>",
  )
  let grp_id = require_uint(
    element, "grpId", "CT_TLOleBuildChart", "<bldOleChart/>",
  )
  let ui_expand = optional_bool(element, "uiExpand", "CT_TLOleBuildChart")
  let bld = match ttt_attr(element, "bld") {
    Some(text) => Some(ST_TLOleChartBuildType::parse(text))
    None => None
  }
  let anim_bg = optional_bool(element, "animBg", "CT_TLOleBuildChart")
  { spid, grp_id, ui_expand, bld, anim_bg, element_name: element.name }
}

///|
pub fn CT_TLOleBuildChart::new(element : @xml.Element) -> CT_TLOleBuildChart {
  CT_TLOleBuildChart::from_element(element) catch {
    _ =>
      {
        spid: "",
        grp_id: 0U,
        ui_expand: None,
        bld: None,
        anim_bg: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLOleBuildChart::parse(element : @xml.Element) -> CT_TLOleBuildChart {
  CT_TLOleBuildChart::new(element)
}

///|
pub fn CT_TLOleBuildChart::to_element(
  self : CT_TLOleBuildChart,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    ttt_attribute("spid", self.spid),
    ttt_attribute("grpId", self.grp_id.to_string()),
  ]
  match self.ui_expand {
    Some(true) => attrs.push(ttt_attribute("uiExpand", "true"))
    Some(false) => attrs.push(ttt_attribute("uiExpand", "false"))
    None => ()
  }
  match self.bld {
    Some(b) => attrs.push(ttt_attribute("bld", b.to_string()))
    None => ()
  }
  match self.anim_bg {
    Some(true) => attrs.push(ttt_attribute("animBg", "true"))
    Some(false) => attrs.push(ttt_attribute("animBg", "false"))
    None => ()
  }
  { name: self.element_name, attributes: attrs, children: [] }
}

///|
/// XSD complex type CT_TLGraphicalObjectBuild — Part 1 §19.5.16
/// bldGraphic (Build Graphic). Required xsd:choice between `<p:bldAsOne>`
/// (CT_Empty, treat the graphic as one unit) and `<p:bldSub>`
/// (a:CT_AnimationGraphicalObjectBuildProperties, raw element). Plus
/// the AG_TLBuild attribute group.
pub(all) enum CT_TLGraphicalObjectBuildChoice {
  /// §19.5.16 bldAsOne branch (CT_Empty).
  GraphicBuildAsOne(@xml.QName)
  /// §19.5.16 bldSub branch
  /// (a:CT_AnimationGraphicalObjectBuildProperties, raw element).
  GraphicBuildSub(@xml.Element)
} derive(Eq, Debug)

///|
pub(all) struct CT_TLGraphicalObjectBuild {
  /// §19.5.16 xsd:choice (bldAsOne | bldSub), required.
  choice : CT_TLGraphicalObjectBuildChoice
  /// §19.5.16 @spid (required).
  spid : String
  /// §19.5.16 @grpId (required).
  grp_id : UInt
  /// §19.5.16 @uiExpand (default false).
  ui_expand : Bool?
  /// Source element QName (`<p:bldGraphic>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
fn decode_graphic_build_choice(
  element : @xml.Element,
) -> CT_TLGraphicalObjectBuildChoice? {
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let kind : CT_TLGraphicalObjectBuildChoice? = match e.name.local_name {
          "bldAsOne" => Some(GraphicBuildAsOne(e.name))
          "bldSub" => Some(GraphicBuildSub(e))
          _ => None
        }
        if kind is Some(_) {
          return kind
        }
      }
      _ => ()
    }
  }
  None
}

///|
pub fn CT_TLGraphicalObjectBuild::from_element(
  element : @xml.Element,
) -> CT_TLGraphicalObjectBuild raise SchemaViolation {
  let choice = match decode_graphic_build_choice(element) {
    Some(c) => c
    None =>
      invalid_simple_type(
        "CT_TLGraphicalObjectBuild", "<bldGraphic/>", "missing required bldAsOne|bldSub choice",
      )
  }
  let spid = require_string(
    element, "spid", "CT_TLGraphicalObjectBuild", "<bldGraphic/>",
  )
  let grp_id = require_uint(
    element, "grpId", "CT_TLGraphicalObjectBuild", "<bldGraphic/>",
  )
  let ui_expand = optional_bool(
    element, "uiExpand", "CT_TLGraphicalObjectBuild",
  )
  { choice, spid, grp_id, ui_expand, element_name: element.name }
}

///|
pub fn CT_TLGraphicalObjectBuild::new(
  element : @xml.Element,
) -> CT_TLGraphicalObjectBuild {
  CT_TLGraphicalObjectBuild::from_element(element) catch {
    _ =>
      {
        choice: GraphicBuildAsOne(ttt_qname("bldAsOne")),
        spid: "",
        grp_id: 0U,
        ui_expand: None,
        element_name: element.name,
      }
  }
}

///|
pub fn CT_TLGraphicalObjectBuild::parse(
  element : @xml.Element,
) -> CT_TLGraphicalObjectBuild {
  CT_TLGraphicalObjectBuild::new(element)
}

///|
pub fn CT_TLGraphicalObjectBuild::to_element(
  self : CT_TLGraphicalObjectBuild,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = [
    ttt_attribute("spid", self.spid),
    ttt_attribute("grpId", self.grp_id.to_string()),
  ]
  match self.ui_expand {
    Some(true) => attrs.push(ttt_attribute("uiExpand", "true"))
    Some(false) => attrs.push(ttt_attribute("uiExpand", "false"))
    None => ()
  }
  let children : Array[@xml.Node] = []
  match self.choice {
    GraphicBuildAsOne(qn) =>
      children.push(@xml.Element({ name: qn, attributes: [], children: [] }))
    GraphicBuildSub(e) => children.push(@xml.Element(e))
  }
  { name: self.element_name, attributes: attrs, children }
}

// === §19.5.12 / §19.5.71 build list and slide timing ======================

///|
/// XSD complex type CT_BuildList — Part 1 §19.5.12 bldLst (Build List).
/// A xsd:choice between bldP / bldDgm / bldOleChart / bldGraphic, with
/// minOccurs=1, maxOccurs=unbounded.
pub(all) enum CT_BuildListEntry {
  /// §19.5.12 bldP branch (CT_TLBuildParagraph §19.5.13).
  BuildEntryParagraph(CT_TLBuildParagraph)
  /// §19.5.12 bldDgm branch (CT_TLBuildDiagram §19.5.14).
  BuildEntryDiagram(CT_TLBuildDiagram)
  /// §19.5.12 bldOleChart branch (CT_TLOleBuildChart §19.5.15).
  BuildEntryOleChart(CT_TLOleBuildChart)
  /// §19.5.12 bldGraphic branch (CT_TLGraphicalObjectBuild §19.5.16).
  BuildEntryGraphic(CT_TLGraphicalObjectBuild)
} derive(Eq, Debug)

///|
pub(all) struct CT_BuildList {
  /// §19.5.12 children (minOccurs=1, maxOccurs=unbounded). Each entry
  /// is one of the four `xsd:choice` branches.
  entries : Array[CT_BuildListEntry]
  /// Source element QName (`<p:bldLst>`).
  element_name : @xml.QName
} derive(Eq, Debug)

///|
pub fn CT_BuildList::from_element(
  element : @xml.Element,
) -> CT_BuildList raise SchemaViolation {
  let entries : Array[CT_BuildListEntry] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "bldP" =>
            entries.push(
              BuildEntryParagraph(CT_TLBuildParagraph::from_element(e)),
            )
          "bldDgm" =>
            entries.push(BuildEntryDiagram(CT_TLBuildDiagram::from_element(e)))
          "bldOleChart" =>
            entries.push(
              BuildEntryOleChart(CT_TLOleBuildChart::from_element(e)),
            )
          "bldGraphic" =>
            entries.push(
              BuildEntryGraphic(CT_TLGraphicalObjectBuild::from_element(e)),
            )
          _ => ()
        }
      _ => ()
    }
  }
  if entries.length() == 0 {
    invalid_simple_type(
      "CT_BuildList", "<bldLst/>", "requires at least one bldP|bldDgm|bldOleChart|bldGraphic child (minOccurs=1)",
    )
  }
  { entries, element_name: element.name }
}

///|
pub fn CT_BuildList::new(element : @xml.Element) -> CT_BuildList {
  CT_BuildList::from_element(element) catch {
    _ => { entries: [], element_name: element.name }
  }
}

///|
pub fn CT_BuildList::parse(element : @xml.Element) -> CT_BuildList {
  CT_BuildList::new(element)
}

///|
pub fn CT_BuildList::to_element(self : CT_BuildList) -> @xml.Element {
  let children : Array[@xml.Node] = []
  for entry in self.entries {
    let el = match entry {
      BuildEntryParagraph(p) => p.to_element()
      BuildEntryDiagram(d) => d.to_element()
      BuildEntryOleChart(o) => o.to_element()
      BuildEntryGraphic(g) => g.to_element()
    }
    children.push(@xml.Element(el))
  }
  { name: self.element_name, attributes: [], children }
}

///|
/// XSD complex type CT_SlideTiming — Part 1 §19.5.71 timing (Slide
/// Timing Information). Three optional children: `<p:tnLst>`
/// (CT_TimeNodeList §19.5.86 — kept as raw time-node child elements
/// because the typed list mirrors the choice of time-node element
/// kinds), `<p:bldLst>` (CT_BuildList §19.5.12), `<p:extLst>`
/// (CT_ExtensionListModify, owned by chunk2).
pub(all) struct CT_SlideTiming {
  /// §19.5.71 child `<p:tnLst>` time-node children
  /// (CT_TimeNodeList §19.5.86). Each element is one of par / seq /
  /// excl / anim / animClr / animEffect / animMotion / animRot /
  /// animScale / cmd / set / audio / video.
  tnLst : Array[@xml.Element]
  /// §19.5.71 child `<p:bldLst>` (CT_BuildList §19.5.12).
  bldLst : CT_BuildList?
  /// §19.5.71 child `<p:extLst>` (CT_ExtensionListModify, chunk2 type).
  /// Kept as raw element because the typed wrapper lives in chunk2.
  extLst : @xml.Element?
  /// Source element QName (`<p:timing>`).
  element_name : @xml.QName
  /// Source `<p:tnLst>` QName (preserved for round-trip; `None` when
  /// `<p:tnLst>` is absent).
  tnLst_name : @xml.QName?
} derive(Eq, Debug)

///|
pub fn CT_SlideTiming::from_element(
  element : @xml.Element,
) -> CT_SlideTiming raise SchemaViolation {
  let (tn_lst, tn_lst_name) = match ttt_first_child(element, "tnLst") {
    Some(e) => {
      let kids : Array[@xml.Element] = []
      for child in e.children {
        match child {
          @xml.Element(c) => kids.push(c)
          _ => ()
        }
      }
      (kids, Some(e.name))
    }
    None => ([], None)
  }
  let bldLst = match ttt_first_child(element, "bldLst") {
    Some(e) => Some(CT_BuildList::from_element(e))
    None => None
  }
  let extLst = ttt_first_child(element, "extLst")
  {
    tnLst: tn_lst,
    bldLst,
    extLst,
    element_name: element.name,
    tnLst_name: tn_lst_name,
  }
}

///|
pub fn CT_SlideTiming::new(element : @xml.Element) -> CT_SlideTiming {
  CT_SlideTiming::from_element(element) catch {
    _ =>
      {
        tnLst: [],
        bldLst: None,
        extLst: None,
        element_name: element.name,
        tnLst_name: None,
      }
  }
}

///|
pub fn CT_SlideTiming::parse(element : @xml.Element) -> CT_SlideTiming {
  CT_SlideTiming::new(element)
}

///|
pub fn CT_SlideTiming::to_element(self : CT_SlideTiming) -> @xml.Element {
  let children : Array[@xml.Node] = []
  let qn = match self.tnLst_name {
    Some(n) => n
    None => ttt_qname("tnLst")
  }
  if self.tnLst.length() > 0 || self.tnLst_name is Some(_) {
    let tn_children : Array[@xml.Node] = []
    for e in self.tnLst {
      tn_children.push(@xml.Element(e))
    }
    children.push(
      @xml.Element({ name: qn, attributes: [], children: tn_children }),
    )
  }
  match self.bldLst {
    Some(b) => children.push(@xml.Element(b.to_element()))
    None => ()
  }
  match self.extLst {
    Some(e) => children.push(@xml.Element(e))
    None => ()
  }
  { name: self.element_name, attributes: [], children }
}
