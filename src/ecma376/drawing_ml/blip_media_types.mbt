///|
/// XSD complex type CT_VideoFile (§20.1.8): relationship link, contentType, extLst.
pub(all) struct CT_VideoFile {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VideoFile::new(element : @xml.Element) -> CT_VideoFile {
  { element, }
}

///|
/// XSD complex type CT_QuickTimeFile (§20.1.8): relationship link and extLst.
pub(all) struct CT_QuickTimeFile {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_QuickTimeFile::new(element : @xml.Element) -> CT_QuickTimeFile {
  { element, }
}

///|
/// XSD complex type CT_AudioFile (§20.1.8): relationship link, contentType, extLst.
pub(all) struct CT_AudioFile {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AudioFile::new(element : @xml.Element) -> CT_AudioFile {
  { element, }
}

///|
/// XSD complex type CT_AudioCDTime (§20.1.8): attributes track and time.
pub(all) struct CT_AudioCDTime {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AudioCDTime::new(element : @xml.Element) -> CT_AudioCDTime {
  { element, }
}

///|
/// XSD complex type CT_AudioCD (§20.1.8): start/end CD times and extLst.
pub(all) struct CT_AudioCD {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AudioCD::new(element : @xml.Element) -> CT_AudioCD {
  { element, }
}

///|
/// XSD complex type CT_EmbeddedWAVAudioFile (§20.1.8): relationship embed and name.
pub(all) struct CT_EmbeddedWAVAudioFile {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EmbeddedWAVAudioFile::new(
  element : @xml.Element,
) -> CT_EmbeddedWAVAudioFile {
  { element, }
}

///|
/// XSD complex type CT_Blip (§20.1.8): attribute cstate; children alphaBiLevel,
/// alphaCeiling, alphaFloor, alphaInv, alphaMod, alphaModFix, alphaRepl,
/// biLevel, blur, clrChange, clrRepl, duotone, fillOverlay, grayscl, hsl,
/// lum, tint, extLst.
pub(all) struct CT_Blip {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Blip::new(element : @xml.Element) -> CT_Blip {
  { element, }
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
