// ECMA-376 Part 1 §20.1.3 / §20.1.8 DrawingML media-reference and Blip
// complex types. The XSD definitions live in Annex A.4.1 lines 18..57
// (audio / video / quickTime / audioCD wrappers), line 706
// (CT_EmbeddedWAVAudioFile) and lines 1475..1501 (CT_Blip). Each typed
// projection captures the schema-mandated attributes (`r:link`,
// `r:embed`, `contentType`, `track`, `time`, `cstate`) along with the
// modelled child elements, and keeps the source `@xml.Element` for
// builder round-trip per the ct-typing protocol.

///|
/// XSD complex type CT_VideoFile — Part 1 §20.1.3.6 videoFile. Annex
/// A.4.1 lines 25..31. Required `r:link` relationship, optional
/// `contentType`, optional `extLst`.
pub(all) struct CT_VideoFile {
  /// @r:link (required) — relationship id targeting the external
  /// video payload.
  r_link : String
  /// @contentType (xsd:string, optional) — MIME content type.
  content_type : String?
  /// <extLst> child (CT_OfficeArtExtensionList, optional). Stored as
  /// raw element pending the typed extension-list projection.
  ext_lst : @xml.Element?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VideoFile::new(
  element : @xml.Element,
) -> CT_VideoFile raise SchemaViolation {
  let r_link = ct_required_string(element, "link", "CT_VideoFile/@r:link")
  let content_type = ct_attr(element, "contentType")
  let ext_lst = ct_first_child(element, "extLst")
  { r_link, content_type, ext_lst, element }
}

///|
pub fn CT_VideoFile::to_element(self : CT_VideoFile) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_QuickTimeFile — Part 1 §20.1.3.5 quickTimeFile.
/// Annex A.4.1 lines 32..37. Required `r:link` relationship, optional
/// `extLst`.
pub(all) struct CT_QuickTimeFile {
  /// @r:link (required) — relationship id targeting the QuickTime payload.
  r_link : String
  /// <extLst> (CT_OfficeArtExtensionList, optional). Raw element.
  ext_lst : @xml.Element?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_QuickTimeFile::new(
  element : @xml.Element,
) -> CT_QuickTimeFile raise SchemaViolation {
  let r_link = ct_required_string(element, "link", "CT_QuickTimeFile/@r:link")
  let ext_lst = ct_first_child(element, "extLst")
  { r_link, ext_lst, element }
}

///|
pub fn CT_QuickTimeFile::to_element(self : CT_QuickTimeFile) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AudioFile — Part 1 §20.1.3.2 audioFile. Annex
/// A.4.1 lines 18..24. Required `r:link`, optional `contentType`,
/// optional `extLst`.
pub(all) struct CT_AudioFile {
  /// @r:link (required) — relationship id for the audio payload.
  r_link : String
  /// @contentType (xsd:string, optional).
  content_type : String?
  /// <extLst> child (CT_OfficeArtExtensionList, optional).
  ext_lst : @xml.Element?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AudioFile::new(
  element : @xml.Element,
) -> CT_AudioFile raise SchemaViolation {
  let r_link = ct_required_string(element, "link", "CT_AudioFile/@r:link")
  let content_type = ct_attr(element, "contentType")
  let ext_lst = ct_first_child(element, "extLst")
  { r_link, content_type, ext_lst, element }
}

///|
pub fn CT_AudioFile::to_element(self : CT_AudioFile) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AudioCDTime — Part 1 §20.1.3.4 st / end of audio
/// CD playback. Annex A.4.1 lines 38..41. Required `track`
/// (xsd:unsignedByte), optional `time` (xsd:unsignedInt, default 0).
pub(all) struct CT_AudioCDTime {
  /// @track (xsd:unsignedByte, required) — CD track number (0..255).
  track : Int
  /// @time (xsd:unsignedInt, optional, default 0) — offset within the track.
  time : UInt
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AudioCDTime::new(
  element : @xml.Element,
) -> CT_AudioCDTime raise SchemaViolation {
  let track = ct_required_ubyte(element, "track", "CT_AudioCDTime/@track")
  let time = ct_optional_uint(
    element,
    "time",
    default=0U,
    "CT_AudioCDTime/@time",
  )
  { track, time, element }
}

///|
pub fn CT_AudioCDTime::to_element(self : CT_AudioCDTime) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AudioCD — Part 1 §20.1.3.1 audioCd. Annex A.4.1
/// lines 42..48. Sequence of required `st` and `end` CT_AudioCDTime
/// children plus optional `extLst`.
pub(all) struct CT_AudioCD {
  /// <st> child (CT_AudioCDTime, required minOccurs=1).
  st : CT_AudioCDTime?
  /// <end> child (CT_AudioCDTime, required minOccurs=1).
  end : CT_AudioCDTime?
  /// <extLst> (CT_OfficeArtExtensionList, optional). Raw element.
  ext_lst : @xml.Element?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AudioCD::new(
  element : @xml.Element,
) -> CT_AudioCD raise SchemaViolation {
  let st = match ct_first_child(element, "st") {
    Some(c) => Some(CT_AudioCDTime::new(c))
    None => None
  }
  let end = match ct_first_child(element, "end") {
    Some(c) => Some(CT_AudioCDTime::new(c))
    None => None
  }
  let ext_lst = ct_first_child(element, "extLst")
  { st, end, ext_lst, element }
}

///|
pub fn CT_AudioCD::to_element(self : CT_AudioCD) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EmbeddedWAVAudioFile — Part 1 §20.1.3.3
/// wavAudioFile. Annex A.4.1 lines 706..709. Required `r:embed`,
/// optional `name` (xsd:string, default "").
pub(all) struct CT_EmbeddedWAVAudioFile {
  /// @r:embed (required) — relationship id for the embedded WAV.
  r_embed : String
  /// @name (xsd:string, optional, default "").
  name : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedWAVAudioFile::new(
  element : @xml.Element,
) -> CT_EmbeddedWAVAudioFile raise SchemaViolation {
  let r_embed = ct_required_string(
    element, "embed", "CT_EmbeddedWAVAudioFile/@r:embed",
  )
  let name = ct_optional_string(element, "name", default="")
  { r_embed, name, element }
}

///|
pub fn CT_EmbeddedWAVAudioFile::to_element(
  self : CT_EmbeddedWAVAudioFile,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Blip — Part 1 §20.1.8.13 blip. Annex A.4.1
/// lines 1475..1501. The blip's choice is a 17-arm subset of the
/// effect-element family; we capture it via the typed `BlipEffect`
/// sum so callers branch on the exact effect arm.
pub(all) enum BlipEffect {
  AlphaBiLevel(CT_AlphaBiLevelEffect)
  AlphaCeiling(CT_AlphaCeilingEffect)
  AlphaFloor(CT_AlphaFloorEffect)
  AlphaInv(CT_AlphaInverseEffect)
  AlphaMod(CT_AlphaModulateEffect)
  AlphaModFix(CT_AlphaModulateFixedEffect)
  AlphaRepl(CT_AlphaReplaceEffect)
  BiLevel(CT_BiLevelEffect)
  Blur(CT_BlurEffect)
  ClrChange(CT_ColorChangeEffect)
  ClrRepl(CT_ColorReplaceEffect)
  Duotone(CT_DuotoneEffect)
  FillOverlay(CT_FillOverlayEffect)
  Grayscl(CT_GrayscaleEffect)
  Hsl(CT_HSLEffect)
  Lum(CT_LuminanceEffect)
  Tint(CT_TintEffect)
} derive(Eq, Debug)

///|
pub(all) struct CT_Blip {
  /// @r:embed (optional, default "").
  r_embed : String
  /// @r:link (optional, default "").
  r_link : String
  /// @cstate (ST_BlipCompression, optional, default none).
  cstate : ST_BlipCompression
  /// Effect children in document order — typed per the 17-arm
  /// CT_Blip choice (Annex A.4.1 lines 1478..1495).
  effects : Array[BlipEffect]
  /// <extLst> (CT_OfficeArtExtensionList, optional).
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
fn parse_blip_effect_child(
  element : @xml.Element,
) -> BlipEffect? raise SchemaViolation {
  match element.name.local_name {
    "alphaBiLevel" => Some(AlphaBiLevel(CT_AlphaBiLevelEffect::new(element)))
    "alphaCeiling" => Some(AlphaCeiling(CT_AlphaCeilingEffect::new(element)))
    "alphaFloor" => Some(AlphaFloor(CT_AlphaFloorEffect::new(element)))
    "alphaInv" => Some(AlphaInv(CT_AlphaInverseEffect::new(element)))
    "alphaMod" => Some(AlphaMod(CT_AlphaModulateEffect::new(element)))
    "alphaModFix" =>
      Some(AlphaModFix(CT_AlphaModulateFixedEffect::new(element)))
    "alphaRepl" => Some(AlphaRepl(CT_AlphaReplaceEffect::new(element)))
    "biLevel" => Some(BiLevel(CT_BiLevelEffect::new(element)))
    "blur" => Some(Blur(CT_BlurEffect::new(element)))
    "clrChange" => Some(ClrChange(CT_ColorChangeEffect::new(element)))
    "clrRepl" => Some(ClrRepl(CT_ColorReplaceEffect::new(element)))
    "duotone" => Some(Duotone(CT_DuotoneEffect::new(element)))
    "fillOverlay" => Some(FillOverlay(CT_FillOverlayEffect::new(element)))
    "grayscl" => Some(Grayscl(CT_GrayscaleEffect::new(element)))
    "hsl" => Some(Hsl(CT_HSLEffect::new(element)))
    "lum" => Some(Lum(CT_LuminanceEffect::new(element)))
    "tint" => Some(Tint(CT_TintEffect::new(element)))
    _ => None
  }
}

///|
pub fn CT_Blip::new(element : @xml.Element) -> CT_Blip raise SchemaViolation {
  let r_embed = ct_optional_string(element, "embed", default="")
  let r_link = ct_optional_string(element, "link", default="")
  let cstate = match ct_attr(element, "cstate") {
    Some(v) => ST_BlipCompression::parse(v)
    None => BlipCstateNone
  }
  let effects : Array[BlipEffect] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        match parse_blip_effect_child(child) {
          Some(e) => effects.push(e)
          None => ()
        }
      _ => ()
    }
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(e) => Some(CT_OfficeArtExtensionList::new(e))
    None => None
  }
  { r_embed, r_link, cstate, effects, ext_lst, element }
}

///|
pub fn CT_Blip::to_element(self : CT_Blip) -> @xml.Element {
  self.element
}

///|
pub fn read_video_file(bytes : Bytes) -> CT_VideoFile raise {
  CT_VideoFile::new(read_main_root(bytes, "videoFile"))
}

///|
pub fn write_video_file(value : CT_VideoFile) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_blip(bytes : Bytes) -> CT_Blip raise {
  CT_Blip::new(read_main_root(bytes, "blip"))
}

///|
pub fn write_blip(value : CT_Blip) -> Bytes {
  write_element(value.element)
}
