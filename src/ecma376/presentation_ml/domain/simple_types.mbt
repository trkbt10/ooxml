///|
/// Schema validation error for PresentationML simple types (§19).
pub suberror SchemaViolation {
  SchemaViolation(type_name~ : String, value~ : String, reason~ : String)
} derive(Debug)

///|
pub fn raise_schema_violation(
  type_name : String,
  value : String,
  reason : String,
) -> Unit raise SchemaViolation {
  raise SchemaViolation(type_name~, value~, reason~)
}

///|
/// Generic-return variant of `raise_schema_violation` for use inside
/// `match`/`catch` arms whose context expects a value of type `T`.
pub fn[T] schema_violation(
  type_name : String,
  value : String,
  reason : String,
) -> T raise SchemaViolation {
  raise SchemaViolation(type_name~, value~, reason~)
}

///|
fn[T] invalid_simple_type(
  type_name : String,
  value : String,
  reason : String,
) -> T raise SchemaViolation {
  raise SchemaViolation(type_name~, value~, reason~)
}

// === Numeric helpers (private) ============================================

///|
/// Decode `s` as a decimal xsd:unsignedInt (0..2^32 − 1). `s` must be
/// non-empty and composed solely of ASCII decimal digits. Returns
/// `None` if the input violates the lexical form or overflows UInt.
fn parse_xsd_unsigned_int(s : String) -> UInt? {
  if s.length() == 0 {
    return None
  }
  let mut value : UInt64 = 0UL
  for i in 0..<s.length() {
    let unit = s.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10UL + (unit - 0x30).to_uint64()
    if value > 4294967295UL {
      return None
    }
  }
  Some(value.to_uint())
}

// === §19.7.1 ST_BookmarkIdSeed ============================================

///|
/// XSD simple type ST_BookmarkIdSeed — Part 1 §19.7.1. xsd:unsignedInt
/// restricted to the half-open range [1, 2147483648). Stored as a
/// UInt so callers can do arithmetic without re-parsing the lexical
/// form.
pub struct ST_BookmarkIdSeed {
  value : UInt
} derive(Eq, Debug)

///|
/// Part 1 §19.7.1 — decode an unsignedInt seed. Raises if the value is
/// 0 or ≥ 2147483648 (Int32 max + 1).
pub fn ST_BookmarkIdSeed::parse(
  s : String,
) -> ST_BookmarkIdSeed raise SchemaViolation {
  match parse_xsd_unsigned_int(s) {
    None => invalid_simple_type("ST_BookmarkIdSeed", s, "not an unsignedInt")
    Some(n) =>
      if n < 1U || n >= 2147483648U {
        invalid_simple_type(
          "ST_BookmarkIdSeed", s, "outside the [1, 2147483648) range",
        )
      } else {
        { value: n }
      }
  }
}

///|
pub fn ST_BookmarkIdSeed::new(
  s : String,
) -> ST_BookmarkIdSeed raise SchemaViolation {
  ST_BookmarkIdSeed::parse(s)
}

///|
/// Render back to the canonical decimal lexical form.
pub fn ST_BookmarkIdSeed::to_string(self : ST_BookmarkIdSeed) -> String {
  self.value.to_string()
}

///|
/// Numeric accessor.
pub fn ST_BookmarkIdSeed::to_uint(self : ST_BookmarkIdSeed) -> UInt {
  self.value
}

// === §19.7.2 ST_Direction =================================================

///|
/// XSD simple type ST_Direction — Part 1 §19.7.2. Two-value xsd:token
/// enumeration: horizontal vs vertical.
pub(all) enum ST_Direction {
  /// §19.7.2 "horz" (Horizontal).
  DirectionHorz
  /// §19.7.2 "vert" (Vertical).
  DirectionVert
} derive(Eq, Debug)

///|
pub fn ST_Direction::parse(s : String) -> ST_Direction raise SchemaViolation {
  match s {
    "horz" => DirectionHorz
    "vert" => DirectionVert
    _ => invalid_simple_type("ST_Direction", s, "unknown enumeration value")
  }
}

///|
pub fn ST_Direction::new(s : String) -> ST_Direction raise SchemaViolation {
  ST_Direction::parse(s)
}

///|
pub fn ST_Direction::to_string(self : ST_Direction) -> String {
  match self {
    DirectionHorz => "horz"
    DirectionVert => "vert"
  }
}

// === §19.7.3 ST_Index =====================================================

///|
/// XSD simple type ST_Index — Part 1 §19.7.3. Plain xsd:unsignedInt
/// used to position an object in an ordered list.
pub struct ST_Index {
  value : UInt
} derive(Eq, Debug)

///|
pub fn ST_Index::parse(s : String) -> ST_Index raise SchemaViolation {
  match parse_xsd_unsigned_int(s) {
    None => invalid_simple_type("ST_Index", s, "not an unsignedInt")
    Some(n) => { value: n }
  }
}

///|
pub fn ST_Index::new(s : String) -> ST_Index raise SchemaViolation {
  ST_Index::parse(s)
}

///|
pub fn ST_Index::to_string(self : ST_Index) -> String {
  self.value.to_string()
}

///|
pub fn ST_Index::to_uint(self : ST_Index) -> UInt {
  self.value
}

// === §19.7.4 ST_IterateType ===============================================

///|
/// XSD simple type ST_IterateType — Part 1 §19.7.4. Three-value
/// xsd:token enumeration: element / word / letter iteration.
pub(all) enum ST_IterateType {
  /// §19.7.4 "el" (Element).
  IterateEl
  /// §19.7.4 "wd" (Word).
  IterateWd
  /// §19.7.4 "lt" (Letter).
  IterateLt
} derive(Eq, Debug)

///|
pub fn ST_IterateType::parse(
  s : String,
) -> ST_IterateType raise SchemaViolation {
  match s {
    "el" => IterateEl
    "wd" => IterateWd
    "lt" => IterateLt
    _ => invalid_simple_type("ST_IterateType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_IterateType::new(s : String) -> ST_IterateType raise SchemaViolation {
  ST_IterateType::parse(s)
}

///|
pub fn ST_IterateType::to_string(self : ST_IterateType) -> String {
  match self {
    IterateEl => "el"
    IterateWd => "wd"
    IterateLt => "lt"
  }
}

// === §19.7.5 ST_Name ======================================================

///|
/// XSD simple type ST_Name — Part 1 §19.7.5. Unconstrained xsd:string
/// used for author/custom-show names. Kept as a typed wrapper so the
/// schema's identity is preserved through the codebase.
pub struct ST_Name {
  lexical : String
} derive(Eq, Debug)

///|
pub fn ST_Name::parse(s : String) -> ST_Name {
  { lexical: s }
}

///|
pub fn ST_Name::new(s : String) -> ST_Name {
  ST_Name::parse(s)
}

///|
pub fn ST_Name::to_string(self : ST_Name) -> String {
  self.lexical
}

// === §19.7.6 ST_OleObjectFollowColorScheme ================================

///|
/// XSD simple type ST_OleObjectFollowColorScheme — Part 1 §19.7.6.
/// Three-value xsd:token enumeration describing how an embedded
/// object follows the presentation's color scheme.
pub(all) enum ST_OleObjectFollowColorScheme {
  /// §19.7.6 "none".
  OleColorNone
  /// §19.7.6 "full".
  OleColorFull
  /// §19.7.6 "textAndBackground".
  OleColorTextAndBackground
} derive(Eq, Debug)

///|
pub fn ST_OleObjectFollowColorScheme::parse(
  s : String,
) -> ST_OleObjectFollowColorScheme raise SchemaViolation {
  match s {
    "none" => OleColorNone
    "full" => OleColorFull
    "textAndBackground" => OleColorTextAndBackground
    _ =>
      invalid_simple_type(
        "ST_OleObjectFollowColorScheme", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_OleObjectFollowColorScheme::new(
  s : String,
) -> ST_OleObjectFollowColorScheme raise SchemaViolation {
  ST_OleObjectFollowColorScheme::parse(s)
}

///|
pub fn ST_OleObjectFollowColorScheme::to_string(
  self : ST_OleObjectFollowColorScheme,
) -> String {
  match self {
    OleColorNone => "none"
    OleColorFull => "full"
    OleColorTextAndBackground => "textAndBackground"
  }
}

// === §19.7.7 ST_PhotoAlbumFrameShape ======================================

///|
/// XSD simple type ST_PhotoAlbumFrameShape — Part 1 §19.7.7. Seven
/// pre-defined photo-frame styles.
pub(all) enum ST_PhotoAlbumFrameShape {
  /// §19.7.7 "frameStyle1" (Rectangle).
  FrameStyle1
  /// §19.7.7 "frameStyle2" (Rounded Rectangle).
  FrameStyle2
  /// §19.7.7 "frameStyle3" (Simple White).
  FrameStyle3
  /// §19.7.7 "frameStyle4" (Simple Black).
  FrameStyle4
  /// §19.7.7 "frameStyle5" (Compound Black).
  FrameStyle5
  /// §19.7.7 "frameStyle6" (Center Shadow).
  FrameStyle6
  /// §19.7.7 "frameStyle7" (Soft Edge).
  FrameStyle7
} derive(Eq, Debug)

///|
pub fn ST_PhotoAlbumFrameShape::parse(
  s : String,
) -> ST_PhotoAlbumFrameShape raise SchemaViolation {
  match s {
    "frameStyle1" => FrameStyle1
    "frameStyle2" => FrameStyle2
    "frameStyle3" => FrameStyle3
    "frameStyle4" => FrameStyle4
    "frameStyle5" => FrameStyle5
    "frameStyle6" => FrameStyle6
    "frameStyle7" => FrameStyle7
    _ =>
      invalid_simple_type(
        "ST_PhotoAlbumFrameShape", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_PhotoAlbumFrameShape::new(
  s : String,
) -> ST_PhotoAlbumFrameShape raise SchemaViolation {
  ST_PhotoAlbumFrameShape::parse(s)
}

///|
pub fn ST_PhotoAlbumFrameShape::to_string(
  self : ST_PhotoAlbumFrameShape,
) -> String {
  match self {
    FrameStyle1 => "frameStyle1"
    FrameStyle2 => "frameStyle2"
    FrameStyle3 => "frameStyle3"
    FrameStyle4 => "frameStyle4"
    FrameStyle5 => "frameStyle5"
    FrameStyle6 => "frameStyle6"
    FrameStyle7 => "frameStyle7"
  }
}

// === §19.7.8 ST_PhotoAlbumLayout ==========================================

///|
/// XSD simple type ST_PhotoAlbumLayout — Part 1 §19.7.8. Seven photo
/// album per-slide layouts.
pub(all) enum ST_PhotoAlbumLayout {
  /// §19.7.8 "fitToSlide".
  AlbumFitToSlide
  /// §19.7.8 "1pic".
  Album1Pic
  /// §19.7.8 "2pic".
  Album2Pic
  /// §19.7.8 "4pic".
  Album4Pic
  /// §19.7.8 "1picTitle".
  Album1PicTitle
  /// §19.7.8 "2picTitle".
  Album2PicTitle
  /// §19.7.8 "4picTitle".
  Album4PicTitle
} derive(Eq, Debug)

///|
pub fn ST_PhotoAlbumLayout::parse(
  s : String,
) -> ST_PhotoAlbumLayout raise SchemaViolation {
  match s {
    "fitToSlide" => AlbumFitToSlide
    "1pic" => Album1Pic
    "2pic" => Album2Pic
    "4pic" => Album4Pic
    "1picTitle" => Album1PicTitle
    "2picTitle" => Album2PicTitle
    "4picTitle" => Album4PicTitle
    _ =>
      invalid_simple_type("ST_PhotoAlbumLayout", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PhotoAlbumLayout::new(
  s : String,
) -> ST_PhotoAlbumLayout raise SchemaViolation {
  ST_PhotoAlbumLayout::parse(s)
}

///|
pub fn ST_PhotoAlbumLayout::to_string(self : ST_PhotoAlbumLayout) -> String {
  match self {
    AlbumFitToSlide => "fitToSlide"
    Album1Pic => "1pic"
    Album2Pic => "2pic"
    Album4Pic => "4pic"
    Album1PicTitle => "1picTitle"
    Album2PicTitle => "2picTitle"
    Album4PicTitle => "4picTitle"
  }
}

// === §19.7.9 ST_PlaceholderSize ===========================================

///|
/// XSD simple type ST_PlaceholderSize — Part 1 §19.7.9. Three-value
/// xsd:token enumeration for placeholder size relative to the body
/// placeholder on the master.
pub(all) enum ST_PlaceholderSize {
  /// §19.7.9 "full".
  PlaceholderFull
  /// §19.7.9 "half".
  PlaceholderHalf
  /// §19.7.9 "quarter".
  PlaceholderQuarter
} derive(Eq, Debug)

///|
pub fn ST_PlaceholderSize::parse(
  s : String,
) -> ST_PlaceholderSize raise SchemaViolation {
  match s {
    "full" => PlaceholderFull
    "half" => PlaceholderHalf
    "quarter" => PlaceholderQuarter
    _ =>
      invalid_simple_type("ST_PlaceholderSize", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PlaceholderSize::new(
  s : String,
) -> ST_PlaceholderSize raise SchemaViolation {
  ST_PlaceholderSize::parse(s)
}

///|
pub fn ST_PlaceholderSize::to_string(self : ST_PlaceholderSize) -> String {
  match self {
    PlaceholderFull => "full"
    PlaceholderHalf => "half"
    PlaceholderQuarter => "quarter"
  }
}

// === §19.7.10 ST_PlaceholderType ==========================================

///|
/// XSD simple type ST_PlaceholderType — Part 1 §19.7.10. Sixteen-value
/// xsd:token enumeration identifying placeholder content kind.
pub(all) enum ST_PlaceholderType {
  /// §19.7.10 "title".
  PhTitle
  /// §19.7.10 "body".
  PhBody
  /// §19.7.10 "ctrTitle" (Centered Title).
  PhCtrTitle
  /// §19.7.10 "subTitle".
  PhSubTitle
  /// §19.7.10 "dt" (Date and Time).
  PhDt
  /// §19.7.10 "sldNum" (Slide Number).
  PhSldNum
  /// §19.7.10 "ftr" (Footer).
  PhFtr
  /// §19.7.10 "hdr" (Header).
  PhHdr
  /// §19.7.10 "obj" (Object).
  PhObj
  /// §19.7.10 "chart".
  PhChart
  /// §19.7.10 "tbl" (Table).
  PhTbl
  /// §19.7.10 "clipArt".
  PhClipArt
  /// §19.7.10 "dgm" (Diagram).
  PhDgm
  /// §19.7.10 "media".
  PhMedia
  /// §19.7.10 "sldImg" (Slide Image).
  PhSldImg
  /// §19.7.10 "pic" (Picture).
  PhPic
} derive(Eq, Debug)

///|
pub fn ST_PlaceholderType::parse(
  s : String,
) -> ST_PlaceholderType raise SchemaViolation {
  match s {
    "title" => PhTitle
    "body" => PhBody
    "ctrTitle" => PhCtrTitle
    "subTitle" => PhSubTitle
    "dt" => PhDt
    "sldNum" => PhSldNum
    "ftr" => PhFtr
    "hdr" => PhHdr
    "obj" => PhObj
    "chart" => PhChart
    "tbl" => PhTbl
    "clipArt" => PhClipArt
    "dgm" => PhDgm
    "media" => PhMedia
    "sldImg" => PhSldImg
    "pic" => PhPic
    _ =>
      invalid_simple_type("ST_PlaceholderType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PlaceholderType::new(
  s : String,
) -> ST_PlaceholderType raise SchemaViolation {
  ST_PlaceholderType::parse(s)
}

///|
pub fn ST_PlaceholderType::to_string(self : ST_PlaceholderType) -> String {
  match self {
    PhTitle => "title"
    PhBody => "body"
    PhCtrTitle => "ctrTitle"
    PhSubTitle => "subTitle"
    PhDt => "dt"
    PhSldNum => "sldNum"
    PhFtr => "ftr"
    PhHdr => "hdr"
    PhObj => "obj"
    PhChart => "chart"
    PhTbl => "tbl"
    PhClipArt => "clipArt"
    PhDgm => "dgm"
    PhMedia => "media"
    PhSldImg => "sldImg"
    PhPic => "pic"
  }
}

// === §19.7.11 ST_PrintColorMode ===========================================

///|
/// XSD simple type ST_PrintColorMode — Part 1 §19.7.11. Three-value
/// xsd:token enumeration for the print colour mode.
pub(all) enum ST_PrintColorMode {
  /// §19.7.11 "bw" (Black and White).
  PrintBw
  /// §19.7.11 "gray" (Grayscale).
  PrintGray
  /// §19.7.11 "clr" (Color).
  PrintClr
} derive(Eq, Debug)

///|
pub fn ST_PrintColorMode::parse(
  s : String,
) -> ST_PrintColorMode raise SchemaViolation {
  match s {
    "bw" => PrintBw
    "gray" => PrintGray
    "clr" => PrintClr
    _ =>
      invalid_simple_type("ST_PrintColorMode", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PrintColorMode::new(
  s : String,
) -> ST_PrintColorMode raise SchemaViolation {
  ST_PrintColorMode::parse(s)
}

///|
pub fn ST_PrintColorMode::to_string(self : ST_PrintColorMode) -> String {
  match self {
    PrintBw => "bw"
    PrintGray => "gray"
    PrintClr => "clr"
  }
}

// === §19.7.12 ST_PrintWhat ================================================

///|
/// XSD simple type ST_PrintWhat — Part 1 §19.7.12. Nine-value
/// xsd:token enumeration for the default print layout.
pub(all) enum ST_PrintWhat {
  /// §19.7.12 "slides".
  PrintSlides
  /// §19.7.12 "handouts1" (1 Slide / Handout Page).
  PrintHandouts1
  /// §19.7.12 "handouts2".
  PrintHandouts2
  /// §19.7.12 "handouts3".
  PrintHandouts3
  /// §19.7.12 "handouts4".
  PrintHandouts4
  /// §19.7.12 "handouts6".
  PrintHandouts6
  /// §19.7.12 "handouts9".
  PrintHandouts9
  /// §19.7.12 "notes".
  PrintNotes
  /// §19.7.12 "outline".
  PrintOutline
} derive(Eq, Debug)

///|
pub fn ST_PrintWhat::parse(s : String) -> ST_PrintWhat raise SchemaViolation {
  match s {
    "slides" => PrintSlides
    "handouts1" => PrintHandouts1
    "handouts2" => PrintHandouts2
    "handouts3" => PrintHandouts3
    "handouts4" => PrintHandouts4
    "handouts6" => PrintHandouts6
    "handouts9" => PrintHandouts9
    "notes" => PrintNotes
    "outline" => PrintOutline
    _ => invalid_simple_type("ST_PrintWhat", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PrintWhat::new(s : String) -> ST_PrintWhat raise SchemaViolation {
  ST_PrintWhat::parse(s)
}

///|
pub fn ST_PrintWhat::to_string(self : ST_PrintWhat) -> String {
  match self {
    PrintSlides => "slides"
    PrintHandouts1 => "handouts1"
    PrintHandouts2 => "handouts2"
    PrintHandouts3 => "handouts3"
    PrintHandouts4 => "handouts4"
    PrintHandouts6 => "handouts6"
    PrintHandouts9 => "handouts9"
    PrintNotes => "notes"
    PrintOutline => "outline"
  }
}

// === §19.7.13 ST_SlideId ==================================================

///|
/// XSD simple type ST_SlideId — Part 1 §19.7.13. xsd:unsignedInt
/// restricted to [256, 2147483648).
pub struct ST_SlideId {
  value : UInt
} derive(Eq, Debug)

///|
pub fn ST_SlideId::parse(s : String) -> ST_SlideId raise SchemaViolation {
  match parse_xsd_unsigned_int(s) {
    None => invalid_simple_type("ST_SlideId", s, "not an unsignedInt")
    Some(n) =>
      if n < 256U || n >= 2147483648U {
        invalid_simple_type(
          "ST_SlideId", s, "outside the [256, 2147483648) range",
        )
      } else {
        { value: n }
      }
  }
}

///|
pub fn ST_SlideId::new(s : String) -> ST_SlideId raise SchemaViolation {
  ST_SlideId::parse(s)
}

///|
pub fn ST_SlideId::to_string(self : ST_SlideId) -> String {
  self.value.to_string()
}

///|
pub fn ST_SlideId::to_uint(self : ST_SlideId) -> UInt {
  self.value
}

// === §19.7.14 ST_SlideLayoutId ============================================

///|
/// XSD simple type ST_SlideLayoutId — Part 1 §19.7.14. xsd:unsignedInt
/// restricted to ≥ 2147483648 (i.e. the upper half of the UInt32
/// range). Held as a UInt.
pub struct ST_SlideLayoutId {
  value : UInt
} derive(Eq, Debug)

///|
pub fn ST_SlideLayoutId::parse(
  s : String,
) -> ST_SlideLayoutId raise SchemaViolation {
  match parse_xsd_unsigned_int(s) {
    None => invalid_simple_type("ST_SlideLayoutId", s, "not an unsignedInt")
    Some(n) =>
      if n < 2147483648U {
        invalid_simple_type(
          "ST_SlideLayoutId", s, "below the 2147483648 minimum",
        )
      } else {
        { value: n }
      }
  }
}

///|
pub fn ST_SlideLayoutId::new(
  s : String,
) -> ST_SlideLayoutId raise SchemaViolation {
  ST_SlideLayoutId::parse(s)
}

///|
pub fn ST_SlideLayoutId::to_string(self : ST_SlideLayoutId) -> String {
  self.value.to_string()
}

///|
pub fn ST_SlideLayoutId::to_uint(self : ST_SlideLayoutId) -> UInt {
  self.value
}

// === §19.7.15 ST_SlideLayoutType ==========================================

///|
/// XSD simple type ST_SlideLayoutType — Part 1 §19.7.15. Thirty-six
/// xsd:token values describing the layout's arrangement of content.
pub(all) enum ST_SlideLayoutType {
  /// §19.7.15 "title".
  LayoutTitle
  /// §19.7.15 "tx" (Text).
  LayoutTx
  /// §19.7.15 "twoColTx" (Two Column Text).
  LayoutTwoColTx
  /// §19.7.15 "tbl" (Table).
  LayoutTbl
  /// §19.7.15 "txAndChart".
  LayoutTxAndChart
  /// §19.7.15 "chartAndTx".
  LayoutChartAndTx
  /// §19.7.15 "dgm" (Diagram).
  LayoutDgm
  /// §19.7.15 "chart".
  LayoutChart
  /// §19.7.15 "txAndClipArt".
  LayoutTxAndClipArt
  /// §19.7.15 "clipArtAndTx".
  LayoutClipArtAndTx
  /// §19.7.15 "titleOnly".
  LayoutTitleOnly
  /// §19.7.15 "blank".
  LayoutBlank
  /// §19.7.15 "txAndObj".
  LayoutTxAndObj
  /// §19.7.15 "objAndTx".
  LayoutObjAndTx
  /// §19.7.15 "objOnly".
  LayoutObjOnly
  /// §19.7.15 "obj" (Title and Object).
  LayoutObj
  /// §19.7.15 "txAndMedia".
  LayoutTxAndMedia
  /// §19.7.15 "mediaAndTx".
  LayoutMediaAndTx
  /// §19.7.15 "objOverTx".
  LayoutObjOverTx
  /// §19.7.15 "txOverObj".
  LayoutTxOverObj
  /// §19.7.15 "txAndTwoObj".
  LayoutTxAndTwoObj
  /// §19.7.15 "twoObjAndTx".
  LayoutTwoObjAndTx
  /// §19.7.15 "twoObjOverTx".
  LayoutTwoObjOverTx
  /// §19.7.15 "fourObj".
  LayoutFourObj
  /// §19.7.15 "vertTx" (Vertical Text).
  LayoutVertTx
  /// §19.7.15 "clipArtAndVertTx".
  LayoutClipArtAndVertTx
  /// §19.7.15 "vertTitleAndTx".
  LayoutVertTitleAndTx
  /// §19.7.15 "vertTitleAndTxOverChart".
  LayoutVertTitleAndTxOverChart
  /// §19.7.15 "twoObj".
  LayoutTwoObj
  /// §19.7.15 "objAndTwoObj".
  LayoutObjAndTwoObj
  /// §19.7.15 "twoObjAndObj".
  LayoutTwoObjAndObj
  /// §19.7.15 "cust" (Custom).
  LayoutCust
  /// §19.7.15 "secHead" (Section Header).
  LayoutSecHead
  /// §19.7.15 "twoTxTwoObj".
  LayoutTwoTxTwoObj
  /// §19.7.15 "objTx".
  LayoutObjTx
  /// §19.7.15 "picTx" (Picture and Caption).
  LayoutPicTx
} derive(Eq, Debug)

///|
pub fn ST_SlideLayoutType::parse(
  s : String,
) -> ST_SlideLayoutType raise SchemaViolation {
  match s {
    "title" => LayoutTitle
    "tx" => LayoutTx
    "twoColTx" => LayoutTwoColTx
    "tbl" => LayoutTbl
    "txAndChart" => LayoutTxAndChart
    "chartAndTx" => LayoutChartAndTx
    "dgm" => LayoutDgm
    "chart" => LayoutChart
    "txAndClipArt" => LayoutTxAndClipArt
    "clipArtAndTx" => LayoutClipArtAndTx
    "titleOnly" => LayoutTitleOnly
    "blank" => LayoutBlank
    "txAndObj" => LayoutTxAndObj
    "objAndTx" => LayoutObjAndTx
    "objOnly" => LayoutObjOnly
    "obj" => LayoutObj
    "txAndMedia" => LayoutTxAndMedia
    "mediaAndTx" => LayoutMediaAndTx
    "objOverTx" => LayoutObjOverTx
    "txOverObj" => LayoutTxOverObj
    "txAndTwoObj" => LayoutTxAndTwoObj
    "twoObjAndTx" => LayoutTwoObjAndTx
    "twoObjOverTx" => LayoutTwoObjOverTx
    "fourObj" => LayoutFourObj
    "vertTx" => LayoutVertTx
    "clipArtAndVertTx" => LayoutClipArtAndVertTx
    "vertTitleAndTx" => LayoutVertTitleAndTx
    "vertTitleAndTxOverChart" => LayoutVertTitleAndTxOverChart
    "twoObj" => LayoutTwoObj
    "objAndTwoObj" => LayoutObjAndTwoObj
    "twoObjAndObj" => LayoutTwoObjAndObj
    "cust" => LayoutCust
    "secHead" => LayoutSecHead
    "twoTxTwoObj" => LayoutTwoTxTwoObj
    "objTx" => LayoutObjTx
    "picTx" => LayoutPicTx
    _ =>
      invalid_simple_type("ST_SlideLayoutType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_SlideLayoutType::new(
  s : String,
) -> ST_SlideLayoutType raise SchemaViolation {
  ST_SlideLayoutType::parse(s)
}

///|
pub fn ST_SlideLayoutType::to_string(self : ST_SlideLayoutType) -> String {
  match self {
    LayoutTitle => "title"
    LayoutTx => "tx"
    LayoutTwoColTx => "twoColTx"
    LayoutTbl => "tbl"
    LayoutTxAndChart => "txAndChart"
    LayoutChartAndTx => "chartAndTx"
    LayoutDgm => "dgm"
    LayoutChart => "chart"
    LayoutTxAndClipArt => "txAndClipArt"
    LayoutClipArtAndTx => "clipArtAndTx"
    LayoutTitleOnly => "titleOnly"
    LayoutBlank => "blank"
    LayoutTxAndObj => "txAndObj"
    LayoutObjAndTx => "objAndTx"
    LayoutObjOnly => "objOnly"
    LayoutObj => "obj"
    LayoutTxAndMedia => "txAndMedia"
    LayoutMediaAndTx => "mediaAndTx"
    LayoutObjOverTx => "objOverTx"
    LayoutTxOverObj => "txOverObj"
    LayoutTxAndTwoObj => "txAndTwoObj"
    LayoutTwoObjAndTx => "twoObjAndTx"
    LayoutTwoObjOverTx => "twoObjOverTx"
    LayoutFourObj => "fourObj"
    LayoutVertTx => "vertTx"
    LayoutClipArtAndVertTx => "clipArtAndVertTx"
    LayoutVertTitleAndTx => "vertTitleAndTx"
    LayoutVertTitleAndTxOverChart => "vertTitleAndTxOverChart"
    LayoutTwoObj => "twoObj"
    LayoutObjAndTwoObj => "objAndTwoObj"
    LayoutTwoObjAndObj => "twoObjAndObj"
    LayoutCust => "cust"
    LayoutSecHead => "secHead"
    LayoutTwoTxTwoObj => "twoTxTwoObj"
    LayoutObjTx => "objTx"
    LayoutPicTx => "picTx"
  }
}

// === §19.7.16 ST_SlideMasterId ============================================

///|
/// XSD simple type ST_SlideMasterId — Part 1 §19.7.16. xsd:unsignedInt
/// restricted to ≥ 2147483648.
pub struct ST_SlideMasterId {
  value : UInt
} derive(Eq, Debug)

///|
pub fn ST_SlideMasterId::parse(
  s : String,
) -> ST_SlideMasterId raise SchemaViolation {
  match parse_xsd_unsigned_int(s) {
    None => invalid_simple_type("ST_SlideMasterId", s, "not an unsignedInt")
    Some(n) =>
      if n < 2147483648U {
        invalid_simple_type(
          "ST_SlideMasterId", s, "below the 2147483648 minimum",
        )
      } else {
        { value: n }
      }
  }
}

///|
pub fn ST_SlideMasterId::new(
  s : String,
) -> ST_SlideMasterId raise SchemaViolation {
  ST_SlideMasterId::parse(s)
}

///|
pub fn ST_SlideMasterId::to_string(self : ST_SlideMasterId) -> String {
  self.value.to_string()
}

///|
pub fn ST_SlideMasterId::to_uint(self : ST_SlideMasterId) -> UInt {
  self.value
}

// === §19.7.17 ST_SlideSizeCoordinate ======================================

///|
/// XSD simple type ST_SlideSizeCoordinate — Part 1 §19.7.17.
/// Restriction of ST_PositiveCoordinate32 (DrawingML §20.1.10.43) to
/// the EMU range [914400, 51206400] (1 inch up to 56 inches). Held as
/// an Int (EMU values comfortably fit in a 32-bit signed integer).
pub struct ST_SlideSizeCoordinate {
  emu : Int
} derive(Eq, Debug)

///|
pub fn ST_SlideSizeCoordinate::parse(
  s : String,
) -> ST_SlideSizeCoordinate raise SchemaViolation {
  match parse_xsd_unsigned_int(s) {
    None =>
      invalid_simple_type("ST_SlideSizeCoordinate", s, "not an EMU coordinate")
    Some(n) =>
      if n < 914400U || n > 51206400U {
        invalid_simple_type(
          "ST_SlideSizeCoordinate", s, "outside the [914400, 51206400] EMU range",
        )
      } else {
        { emu: n.reinterpret_as_int() }
      }
  }
}

///|
pub fn ST_SlideSizeCoordinate::new(
  s : String,
) -> ST_SlideSizeCoordinate raise SchemaViolation {
  ST_SlideSizeCoordinate::parse(s)
}

///|
pub fn ST_SlideSizeCoordinate::to_string(
  self : ST_SlideSizeCoordinate,
) -> String {
  self.emu.to_string()
}

///|
pub fn ST_SlideSizeCoordinate::to_emu(self : ST_SlideSizeCoordinate) -> Int {
  self.emu
}

// === §19.7.18 ST_SlideSizeType ============================================

///|
/// XSD simple type ST_SlideSizeType — Part 1 §19.7.18. Sixteen-value
/// xsd:token enumeration of slide-size presets.
pub(all) enum ST_SlideSizeType {
  /// §19.7.18 "screen4x3".
  SlideSizeScreen4x3
  /// §19.7.18 "letter".
  SlideSizeLetter
  /// §19.7.18 "A4".
  SlideSizeA4
  /// §19.7.18 "35mm".
  SlideSize35mm
  /// §19.7.18 "overhead".
  SlideSizeOverhead
  /// §19.7.18 "banner".
  SlideSizeBanner
  /// §19.7.18 "custom".
  SlideSizeCustom
  /// §19.7.18 "ledger".
  SlideSizeLedger
  /// §19.7.18 "A3".
  SlideSizeA3
  /// §19.7.18 "B4ISO".
  SlideSizeB4ISO
  /// §19.7.18 "B5ISO".
  SlideSizeB5ISO
  /// §19.7.18 "B4JIS".
  SlideSizeB4JIS
  /// §19.7.18 "B5JIS".
  SlideSizeB5JIS
  /// §19.7.18 "hagakiCard".
  SlideSizeHagakiCard
  /// §19.7.18 "screen16x9".
  SlideSizeScreen16x9
  /// §19.7.18 "screen16x10".
  SlideSizeScreen16x10
} derive(Eq, Debug)

///|
pub fn ST_SlideSizeType::parse(
  s : String,
) -> ST_SlideSizeType raise SchemaViolation {
  match s {
    "screen4x3" => SlideSizeScreen4x3
    "letter" => SlideSizeLetter
    "A4" => SlideSizeA4
    "35mm" => SlideSize35mm
    "overhead" => SlideSizeOverhead
    "banner" => SlideSizeBanner
    "custom" => SlideSizeCustom
    "ledger" => SlideSizeLedger
    "A3" => SlideSizeA3
    "B4ISO" => SlideSizeB4ISO
    "B5ISO" => SlideSizeB5ISO
    "B4JIS" => SlideSizeB4JIS
    "B5JIS" => SlideSizeB5JIS
    "hagakiCard" => SlideSizeHagakiCard
    "screen16x9" => SlideSizeScreen16x9
    "screen16x10" => SlideSizeScreen16x10
    _ => invalid_simple_type("ST_SlideSizeType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_SlideSizeType::new(
  s : String,
) -> ST_SlideSizeType raise SchemaViolation {
  ST_SlideSizeType::parse(s)
}

///|
pub fn ST_SlideSizeType::to_string(self : ST_SlideSizeType) -> String {
  match self {
    SlideSizeScreen4x3 => "screen4x3"
    SlideSizeLetter => "letter"
    SlideSizeA4 => "A4"
    SlideSize35mm => "35mm"
    SlideSizeOverhead => "overhead"
    SlideSizeBanner => "banner"
    SlideSizeCustom => "custom"
    SlideSizeLedger => "ledger"
    SlideSizeA3 => "A3"
    SlideSizeB4ISO => "B4ISO"
    SlideSizeB5ISO => "B5ISO"
    SlideSizeB4JIS => "B4JIS"
    SlideSizeB5JIS => "B5JIS"
    SlideSizeHagakiCard => "hagakiCard"
    SlideSizeScreen16x9 => "screen16x9"
    SlideSizeScreen16x10 => "screen16x10"
  }
}

// === §19.7.19 ST_SplitterBarState =========================================

///|
/// XSD simple type ST_SplitterBarState — Part 1 §19.7.19. Three-value
/// xsd:token enumeration: minimized / restored / maximized.
pub(all) enum ST_SplitterBarState {
  /// §19.7.19 "minimized".
  SplitterMinimized
  /// §19.7.19 "restored".
  SplitterRestored
  /// §19.7.19 "maximized".
  SplitterMaximized
} derive(Eq, Debug)

///|
pub fn ST_SplitterBarState::parse(
  s : String,
) -> ST_SplitterBarState raise SchemaViolation {
  match s {
    "minimized" => SplitterMinimized
    "restored" => SplitterRestored
    "maximized" => SplitterMaximized
    _ =>
      invalid_simple_type("ST_SplitterBarState", s, "unknown enumeration value")
  }
}

///|
pub fn ST_SplitterBarState::new(
  s : String,
) -> ST_SplitterBarState raise SchemaViolation {
  ST_SplitterBarState::parse(s)
}

///|
pub fn ST_SplitterBarState::to_string(self : ST_SplitterBarState) -> String {
  match self {
    SplitterMinimized => "minimized"
    SplitterRestored => "restored"
    SplitterMaximized => "maximized"
  }
}

// === §19.7.20 ST_TLAnimateBehaviorCalcMode ================================

///|
/// XSD simple type ST_TLAnimateBehaviorCalcMode — Part 1 §19.7.20.
/// Three-value xsd:token enumeration: discrete / linear / formula.
pub(all) enum ST_TLAnimateBehaviorCalcMode {
  /// §19.7.20 "discrete".
  CalcModeDiscrete
  /// §19.7.20 "lin" (Linear).
  CalcModeLin
  /// §19.7.20 "fmla" (Formula).
  CalcModeFmla
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateBehaviorCalcMode::parse(
  s : String,
) -> ST_TLAnimateBehaviorCalcMode raise SchemaViolation {
  match s {
    "discrete" => CalcModeDiscrete
    "lin" => CalcModeLin
    "fmla" => CalcModeFmla
    _ =>
      invalid_simple_type(
        "ST_TLAnimateBehaviorCalcMode", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLAnimateBehaviorCalcMode::new(
  s : String,
) -> ST_TLAnimateBehaviorCalcMode raise SchemaViolation {
  ST_TLAnimateBehaviorCalcMode::parse(s)
}

///|
pub fn ST_TLAnimateBehaviorCalcMode::to_string(
  self : ST_TLAnimateBehaviorCalcMode,
) -> String {
  match self {
    CalcModeDiscrete => "discrete"
    CalcModeLin => "lin"
    CalcModeFmla => "fmla"
  }
}

// === §19.7.21 ST_TLAnimateBehaviorValueType ===============================

///|
/// XSD simple type ST_TLAnimateBehaviorValueType — Part 1 §19.7.21.
/// Three-value xsd:token enumeration: string / number / colour.
pub(all) enum ST_TLAnimateBehaviorValueType {
  /// §19.7.21 "str" (String).
  ValueTypeStr
  /// §19.7.21 "num" (Number).
  ValueTypeNum
  /// §19.7.21 "clr" (Color).
  ValueTypeClr
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateBehaviorValueType::parse(
  s : String,
) -> ST_TLAnimateBehaviorValueType raise SchemaViolation {
  match s {
    "str" => ValueTypeStr
    "num" => ValueTypeNum
    "clr" => ValueTypeClr
    _ =>
      invalid_simple_type(
        "ST_TLAnimateBehaviorValueType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLAnimateBehaviorValueType::new(
  s : String,
) -> ST_TLAnimateBehaviorValueType raise SchemaViolation {
  ST_TLAnimateBehaviorValueType::parse(s)
}

///|
pub fn ST_TLAnimateBehaviorValueType::to_string(
  self : ST_TLAnimateBehaviorValueType,
) -> String {
  match self {
    ValueTypeStr => "str"
    ValueTypeNum => "num"
    ValueTypeClr => "clr"
  }
}

// === §19.7.22 ST_TLAnimateColorDirection ==================================

///|
/// XSD simple type ST_TLAnimateColorDirection — Part 1 §19.7.22.
/// Two-value xsd:token enumeration: clockwise / counter-clockwise.
pub(all) enum ST_TLAnimateColorDirection {
  /// §19.7.22 "cw" (Clockwise).
  ColorDirCw
  /// §19.7.22 "ccw" (Counter-Clockwise).
  ColorDirCcw
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateColorDirection::parse(
  s : String,
) -> ST_TLAnimateColorDirection raise SchemaViolation {
  match s {
    "cw" => ColorDirCw
    "ccw" => ColorDirCcw
    _ =>
      invalid_simple_type(
        "ST_TLAnimateColorDirection", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLAnimateColorDirection::new(
  s : String,
) -> ST_TLAnimateColorDirection raise SchemaViolation {
  ST_TLAnimateColorDirection::parse(s)
}

///|
pub fn ST_TLAnimateColorDirection::to_string(
  self : ST_TLAnimateColorDirection,
) -> String {
  match self {
    ColorDirCw => "cw"
    ColorDirCcw => "ccw"
  }
}

// === §19.7.23 ST_TLAnimateColorSpace ======================================

///|
/// XSD simple type ST_TLAnimateColorSpace — Part 1 §19.7.23. Two-value
/// xsd:token enumeration: RGB / HSL.
pub(all) enum ST_TLAnimateColorSpace {
  /// §19.7.23 "rgb" (Red, Green, Blue).
  ColorSpaceRgb
  /// §19.7.23 "hsl" (Hue, Saturation, Luminance).
  ColorSpaceHsl
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateColorSpace::parse(
  s : String,
) -> ST_TLAnimateColorSpace raise SchemaViolation {
  match s {
    "rgb" => ColorSpaceRgb
    "hsl" => ColorSpaceHsl
    _ =>
      invalid_simple_type(
        "ST_TLAnimateColorSpace", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLAnimateColorSpace::new(
  s : String,
) -> ST_TLAnimateColorSpace raise SchemaViolation {
  ST_TLAnimateColorSpace::parse(s)
}

///|
pub fn ST_TLAnimateColorSpace::to_string(
  self : ST_TLAnimateColorSpace,
) -> String {
  match self {
    ColorSpaceRgb => "rgb"
    ColorSpaceHsl => "hsl"
  }
}

// === §19.7.24 ST_TLAnimateEffectTransition ================================

///|
/// XSD simple type ST_TLAnimateEffectTransition — Part 1 §19.7.24.
/// Three-value xsd:token enumeration: in / out / none.
pub(all) enum ST_TLAnimateEffectTransition {
  /// §19.7.24 "in".
  EffectTransitionIn
  /// §19.7.24 "out".
  EffectTransitionOut
  /// §19.7.24 "none".
  EffectTransitionNone
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateEffectTransition::parse(
  s : String,
) -> ST_TLAnimateEffectTransition raise SchemaViolation {
  match s {
    "in" => EffectTransitionIn
    "out" => EffectTransitionOut
    "none" => EffectTransitionNone
    _ =>
      invalid_simple_type(
        "ST_TLAnimateEffectTransition", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLAnimateEffectTransition::new(
  s : String,
) -> ST_TLAnimateEffectTransition raise SchemaViolation {
  ST_TLAnimateEffectTransition::parse(s)
}

///|
pub fn ST_TLAnimateEffectTransition::to_string(
  self : ST_TLAnimateEffectTransition,
) -> String {
  match self {
    EffectTransitionIn => "in"
    EffectTransitionOut => "out"
    EffectTransitionNone => "none"
  }
}

// === §19.7.25 ST_TLAnimateMotionBehaviorOrigin ============================

///|
/// XSD simple type ST_TLAnimateMotionBehaviorOrigin — Part 1 §19.7.25.
/// Two-value xsd:token enumeration: parent / layout.
pub(all) enum ST_TLAnimateMotionBehaviorOrigin {
  /// §19.7.25 "parent".
  MotionOriginParent
  /// §19.7.25 "layout".
  MotionOriginLayout
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateMotionBehaviorOrigin::parse(
  s : String,
) -> ST_TLAnimateMotionBehaviorOrigin raise SchemaViolation {
  match s {
    "parent" => MotionOriginParent
    "layout" => MotionOriginLayout
    _ =>
      invalid_simple_type(
        "ST_TLAnimateMotionBehaviorOrigin", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLAnimateMotionBehaviorOrigin::new(
  s : String,
) -> ST_TLAnimateMotionBehaviorOrigin raise SchemaViolation {
  ST_TLAnimateMotionBehaviorOrigin::parse(s)
}

///|
pub fn ST_TLAnimateMotionBehaviorOrigin::to_string(
  self : ST_TLAnimateMotionBehaviorOrigin,
) -> String {
  match self {
    MotionOriginParent => "parent"
    MotionOriginLayout => "layout"
  }
}

// === §19.7.26 ST_TLAnimateMotionPathEditMode ==============================

///|
/// XSD simple type ST_TLAnimateMotionPathEditMode — Part 1 §19.7.26.
/// Two-value xsd:token enumeration: relative / fixed.
pub(all) enum ST_TLAnimateMotionPathEditMode {
  /// §19.7.26 "relative".
  PathEditRelative
  /// §19.7.26 "fixed".
  PathEditFixed
} derive(Eq, Debug)

///|
pub fn ST_TLAnimateMotionPathEditMode::parse(
  s : String,
) -> ST_TLAnimateMotionPathEditMode raise SchemaViolation {
  match s {
    "relative" => PathEditRelative
    "fixed" => PathEditFixed
    _ =>
      invalid_simple_type(
        "ST_TLAnimateMotionPathEditMode", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLAnimateMotionPathEditMode::new(
  s : String,
) -> ST_TLAnimateMotionPathEditMode raise SchemaViolation {
  ST_TLAnimateMotionPathEditMode::parse(s)
}

///|
pub fn ST_TLAnimateMotionPathEditMode::to_string(
  self : ST_TLAnimateMotionPathEditMode,
) -> String {
  match self {
    PathEditRelative => "relative"
    PathEditFixed => "fixed"
  }
}

// === §19.7.27 ST_TLBehaviorAccumulateType =================================

///|
/// XSD simple type ST_TLBehaviorAccumulateType — Part 1 §19.7.27.
/// Two-value xsd:token enumeration: none / always.
pub(all) enum ST_TLBehaviorAccumulateType {
  /// §19.7.27 "none".
  AccumulateNone
  /// §19.7.27 "always".
  AccumulateAlways
} derive(Eq, Debug)

///|
pub fn ST_TLBehaviorAccumulateType::parse(
  s : String,
) -> ST_TLBehaviorAccumulateType raise SchemaViolation {
  match s {
    "none" => AccumulateNone
    "always" => AccumulateAlways
    _ =>
      invalid_simple_type(
        "ST_TLBehaviorAccumulateType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLBehaviorAccumulateType::new(
  s : String,
) -> ST_TLBehaviorAccumulateType raise SchemaViolation {
  ST_TLBehaviorAccumulateType::parse(s)
}

///|
pub fn ST_TLBehaviorAccumulateType::to_string(
  self : ST_TLBehaviorAccumulateType,
) -> String {
  match self {
    AccumulateNone => "none"
    AccumulateAlways => "always"
  }
}

// === §19.7.28 ST_TLBehaviorAdditiveType ===================================

///|
/// XSD simple type ST_TLBehaviorAdditiveType — Part 1 §19.7.28. Five
/// xsd:token values describing how animated values combine with the
/// original property.
pub(all) enum ST_TLBehaviorAdditiveType {
  /// §19.7.28 "base".
  AdditiveBase
  /// §19.7.28 "sum".
  AdditiveSum
  /// §19.7.28 "repl" (Replace).
  AdditiveRepl
  /// §19.7.28 "mult" (Multiply).
  AdditiveMult
  /// §19.7.28 "none".
  AdditiveNone
} derive(Eq, Debug)

///|
pub fn ST_TLBehaviorAdditiveType::parse(
  s : String,
) -> ST_TLBehaviorAdditiveType raise SchemaViolation {
  match s {
    "base" => AdditiveBase
    "sum" => AdditiveSum
    "repl" => AdditiveRepl
    "mult" => AdditiveMult
    "none" => AdditiveNone
    _ =>
      invalid_simple_type(
        "ST_TLBehaviorAdditiveType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLBehaviorAdditiveType::new(
  s : String,
) -> ST_TLBehaviorAdditiveType raise SchemaViolation {
  ST_TLBehaviorAdditiveType::parse(s)
}

///|
pub fn ST_TLBehaviorAdditiveType::to_string(
  self : ST_TLBehaviorAdditiveType,
) -> String {
  match self {
    AdditiveBase => "base"
    AdditiveSum => "sum"
    AdditiveRepl => "repl"
    AdditiveMult => "mult"
    AdditiveNone => "none"
  }
}

// === §19.7.29 ST_TLBehaviorOverrideType ===================================

///|
/// XSD simple type ST_TLBehaviorOverrideType — Part 1 §19.7.29.
/// Two-value xsd:token enumeration: normal / childStyle.
pub(all) enum ST_TLBehaviorOverrideType {
  /// §19.7.29 "normal".
  OverrideNormal
  /// §19.7.29 "childStyle".
  OverrideChildStyle
} derive(Eq, Debug)

///|
pub fn ST_TLBehaviorOverrideType::parse(
  s : String,
) -> ST_TLBehaviorOverrideType raise SchemaViolation {
  match s {
    "normal" => OverrideNormal
    "childStyle" => OverrideChildStyle
    _ =>
      invalid_simple_type(
        "ST_TLBehaviorOverrideType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLBehaviorOverrideType::new(
  s : String,
) -> ST_TLBehaviorOverrideType raise SchemaViolation {
  ST_TLBehaviorOverrideType::parse(s)
}

///|
pub fn ST_TLBehaviorOverrideType::to_string(
  self : ST_TLBehaviorOverrideType,
) -> String {
  match self {
    OverrideNormal => "normal"
    OverrideChildStyle => "childStyle"
  }
}

// === §19.7.30 ST_TLBehaviorTransformType ==================================

///|
/// XSD simple type ST_TLBehaviorTransformType — Part 1 §19.7.30.
/// Two-value xsd:token enumeration: pt / img.
pub(all) enum ST_TLBehaviorTransformType {
  /// §19.7.30 "pt" (Point).
  TransformPt
  /// §19.7.30 "img" (Image).
  TransformImg
} derive(Eq, Debug)

///|
pub fn ST_TLBehaviorTransformType::parse(
  s : String,
) -> ST_TLBehaviorTransformType raise SchemaViolation {
  match s {
    "pt" => TransformPt
    "img" => TransformImg
    _ =>
      invalid_simple_type(
        "ST_TLBehaviorTransformType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLBehaviorTransformType::new(
  s : String,
) -> ST_TLBehaviorTransformType raise SchemaViolation {
  ST_TLBehaviorTransformType::parse(s)
}

///|
pub fn ST_TLBehaviorTransformType::to_string(
  self : ST_TLBehaviorTransformType,
) -> String {
  match self {
    TransformPt => "pt"
    TransformImg => "img"
  }
}

// === §19.7.31 ST_TLChartSubelementType ====================================

///|
/// XSD simple type ST_TLChartSubelementType — Part 1 §19.7.31. Five
/// xsd:token values describing a chart's animation sub-target.
pub(all) enum ST_TLChartSubelementType {
  /// §19.7.31 "gridLegend".
  ChartGridLegend
  /// §19.7.31 "series".
  ChartSeries
  /// §19.7.31 "category".
  ChartCategory
  /// §19.7.31 "ptInSeries".
  ChartPtInSeries
  /// §19.7.31 "ptInCategory".
  ChartPtInCategory
} derive(Eq, Debug)

///|
pub fn ST_TLChartSubelementType::parse(
  s : String,
) -> ST_TLChartSubelementType raise SchemaViolation {
  match s {
    "gridLegend" => ChartGridLegend
    "series" => ChartSeries
    "category" => ChartCategory
    "ptInSeries" => ChartPtInSeries
    "ptInCategory" => ChartPtInCategory
    _ =>
      invalid_simple_type(
        "ST_TLChartSubelementType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLChartSubelementType::new(
  s : String,
) -> ST_TLChartSubelementType raise SchemaViolation {
  ST_TLChartSubelementType::parse(s)
}

///|
pub fn ST_TLChartSubelementType::to_string(
  self : ST_TLChartSubelementType,
) -> String {
  match self {
    ChartGridLegend => "gridLegend"
    ChartSeries => "series"
    ChartCategory => "category"
    ChartPtInSeries => "ptInSeries"
    ChartPtInCategory => "ptInCategory"
  }
}

// === §19.7.32 ST_TLCommandType ============================================

///|
/// XSD simple type ST_TLCommandType — Part 1 §19.7.32. Three-value
/// xsd:token enumeration: evt / call / verb.
pub(all) enum ST_TLCommandType {
  /// §19.7.32 "evt" (Event).
  CommandEvt
  /// §19.7.32 "call".
  CommandCall
  /// §19.7.32 "verb".
  CommandVerb
} derive(Eq, Debug)

///|
pub fn ST_TLCommandType::parse(
  s : String,
) -> ST_TLCommandType raise SchemaViolation {
  match s {
    "evt" => CommandEvt
    "call" => CommandCall
    "verb" => CommandVerb
    _ => invalid_simple_type("ST_TLCommandType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_TLCommandType::new(
  s : String,
) -> ST_TLCommandType raise SchemaViolation {
  ST_TLCommandType::parse(s)
}

///|
pub fn ST_TLCommandType::to_string(self : ST_TLCommandType) -> String {
  match self {
    CommandEvt => "evt"
    CommandCall => "call"
    CommandVerb => "verb"
  }
}

// === §19.7.33 ST_TLDiagramBuildType =======================================

///|
/// XSD simple type ST_TLDiagramBuildType — Part 1 §19.7.33. Seventeen
/// xsd:token values describing how a diagram is built up.
pub(all) enum ST_TLDiagramBuildType {
  /// §19.7.33 "whole".
  DiagramWhole
  /// §19.7.33 "depthByNode".
  DiagramDepthByNode
  /// §19.7.33 "depthByBranch".
  DiagramDepthByBranch
  /// §19.7.33 "breadthByNode".
  DiagramBreadthByNode
  /// §19.7.33 "breadthByLvl".
  DiagramBreadthByLvl
  /// §19.7.33 "cw" (Clockwise).
  DiagramCw
  /// §19.7.33 "cwIn".
  DiagramCwIn
  /// §19.7.33 "cwOut".
  DiagramCwOut
  /// §19.7.33 "ccw" (Counter-Clockwise).
  DiagramCcw
  /// §19.7.33 "ccwIn".
  DiagramCcwIn
  /// §19.7.33 "ccwOut".
  DiagramCcwOut
  /// §19.7.33 "inByRing".
  DiagramInByRing
  /// §19.7.33 "outByRing".
  DiagramOutByRing
  /// §19.7.33 "up".
  DiagramUp
  /// §19.7.33 "down".
  DiagramDown
  /// §19.7.33 "allAtOnce".
  DiagramAllAtOnce
  /// §19.7.33 "cust" (Custom).
  DiagramCust
} derive(Eq, Debug)

///|
pub fn ST_TLDiagramBuildType::parse(
  s : String,
) -> ST_TLDiagramBuildType raise SchemaViolation {
  match s {
    "whole" => DiagramWhole
    "depthByNode" => DiagramDepthByNode
    "depthByBranch" => DiagramDepthByBranch
    "breadthByNode" => DiagramBreadthByNode
    "breadthByLvl" => DiagramBreadthByLvl
    "cw" => DiagramCw
    "cwIn" => DiagramCwIn
    "cwOut" => DiagramCwOut
    "ccw" => DiagramCcw
    "ccwIn" => DiagramCcwIn
    "ccwOut" => DiagramCcwOut
    "inByRing" => DiagramInByRing
    "outByRing" => DiagramOutByRing
    "up" => DiagramUp
    "down" => DiagramDown
    "allAtOnce" => DiagramAllAtOnce
    "cust" => DiagramCust
    _ =>
      invalid_simple_type(
        "ST_TLDiagramBuildType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLDiagramBuildType::new(
  s : String,
) -> ST_TLDiagramBuildType raise SchemaViolation {
  ST_TLDiagramBuildType::parse(s)
}

///|
pub fn ST_TLDiagramBuildType::to_string(self : ST_TLDiagramBuildType) -> String {
  match self {
    DiagramWhole => "whole"
    DiagramDepthByNode => "depthByNode"
    DiagramDepthByBranch => "depthByBranch"
    DiagramBreadthByNode => "breadthByNode"
    DiagramBreadthByLvl => "breadthByLvl"
    DiagramCw => "cw"
    DiagramCwIn => "cwIn"
    DiagramCwOut => "cwOut"
    DiagramCcw => "ccw"
    DiagramCcwIn => "ccwIn"
    DiagramCcwOut => "ccwOut"
    DiagramInByRing => "inByRing"
    DiagramOutByRing => "outByRing"
    DiagramUp => "up"
    DiagramDown => "down"
    DiagramAllAtOnce => "allAtOnce"
    DiagramCust => "cust"
  }
}

// === §19.7.34 ST_TLNextActionType =========================================

///|
/// XSD simple type ST_TLNextActionType — Part 1 §19.7.34. Two-value
/// xsd:token enumeration: none / seek.
pub(all) enum ST_TLNextActionType {
  /// §19.7.34 "none".
  NextActionNone
  /// §19.7.34 "seek".
  NextActionSeek
} derive(Eq, Debug)

///|
pub fn ST_TLNextActionType::parse(
  s : String,
) -> ST_TLNextActionType raise SchemaViolation {
  match s {
    "none" => NextActionNone
    "seek" => NextActionSeek
    _ =>
      invalid_simple_type("ST_TLNextActionType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_TLNextActionType::new(
  s : String,
) -> ST_TLNextActionType raise SchemaViolation {
  ST_TLNextActionType::parse(s)
}

///|
pub fn ST_TLNextActionType::to_string(self : ST_TLNextActionType) -> String {
  match self {
    NextActionNone => "none"
    NextActionSeek => "seek"
  }
}

// === §19.7.35 ST_TLOleChartBuildType ======================================

///|
/// XSD simple type ST_TLOleChartBuildType — Part 1 §19.7.35. Five
/// xsd:token values for embedded-chart build strategies.
pub(all) enum ST_TLOleChartBuildType {
  /// §19.7.35 "allAtOnce".
  OleChartAllAtOnce
  /// §19.7.35 "series" (By Series).
  OleChartSeries
  /// §19.7.35 "category" (By Category).
  OleChartCategory
  /// §19.7.35 "seriesEl" (By Series Element).
  OleChartSeriesEl
  /// §19.7.35 "categoryEl" (By Category Element).
  OleChartCategoryEl
} derive(Eq, Debug)

///|
pub fn ST_TLOleChartBuildType::parse(
  s : String,
) -> ST_TLOleChartBuildType raise SchemaViolation {
  match s {
    "allAtOnce" => OleChartAllAtOnce
    "series" => OleChartSeries
    "category" => OleChartCategory
    "seriesEl" => OleChartSeriesEl
    "categoryEl" => OleChartCategoryEl
    _ =>
      invalid_simple_type(
        "ST_TLOleChartBuildType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLOleChartBuildType::new(
  s : String,
) -> ST_TLOleChartBuildType raise SchemaViolation {
  ST_TLOleChartBuildType::parse(s)
}

///|
pub fn ST_TLOleChartBuildType::to_string(
  self : ST_TLOleChartBuildType,
) -> String {
  match self {
    OleChartAllAtOnce => "allAtOnce"
    OleChartSeries => "series"
    OleChartCategory => "category"
    OleChartSeriesEl => "seriesEl"
    OleChartCategoryEl => "categoryEl"
  }
}

// === §19.7.36 ST_TLParaBuildType ==========================================

///|
/// XSD simple type ST_TLParaBuildType — Part 1 §19.7.36. Four
/// xsd:token values describing paragraph build strategy.
pub(all) enum ST_TLParaBuildType {
  /// §19.7.36 "allAtOnce".
  ParaAllAtOnce
  /// §19.7.36 "p" (Paragraph).
  ParaP
  /// §19.7.36 "cust" (Custom).
  ParaCust
  /// §19.7.36 "whole".
  ParaWhole
} derive(Eq, Debug)

///|
pub fn ST_TLParaBuildType::parse(
  s : String,
) -> ST_TLParaBuildType raise SchemaViolation {
  match s {
    "allAtOnce" => ParaAllAtOnce
    "p" => ParaP
    "cust" => ParaCust
    "whole" => ParaWhole
    _ =>
      invalid_simple_type("ST_TLParaBuildType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_TLParaBuildType::new(
  s : String,
) -> ST_TLParaBuildType raise SchemaViolation {
  ST_TLParaBuildType::parse(s)
}

///|
pub fn ST_TLParaBuildType::to_string(self : ST_TLParaBuildType) -> String {
  match self {
    ParaAllAtOnce => "allAtOnce"
    ParaP => "p"
    ParaCust => "cust"
    ParaWhole => "whole"
  }
}

// === §19.7.37 ST_TLPreviousActionType =====================================

///|
/// XSD simple type ST_TLPreviousActionType — Part 1 §19.7.37.
/// Two-value xsd:token enumeration: none / skipTimed.
pub(all) enum ST_TLPreviousActionType {
  /// §19.7.37 "none".
  PrevActionNone
  /// §19.7.37 "skipTimed".
  PrevActionSkipTimed
} derive(Eq, Debug)

///|
pub fn ST_TLPreviousActionType::parse(
  s : String,
) -> ST_TLPreviousActionType raise SchemaViolation {
  match s {
    "none" => PrevActionNone
    "skipTimed" => PrevActionSkipTimed
    _ =>
      invalid_simple_type(
        "ST_TLPreviousActionType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLPreviousActionType::new(
  s : String,
) -> ST_TLPreviousActionType raise SchemaViolation {
  ST_TLPreviousActionType::parse(s)
}

///|
pub fn ST_TLPreviousActionType::to_string(
  self : ST_TLPreviousActionType,
) -> String {
  match self {
    PrevActionNone => "none"
    PrevActionSkipTimed => "skipTimed"
  }
}

// === §19.7.40 ST_TLTimeIndefinite (defined before union §19.7.38) =========

///|
/// XSD simple type ST_TLTimeIndefinite — Part 1 §19.7.40. Single-value
/// xsd:token enumeration: the literal `indefinite`. Held as a unit
/// enum so the type witness is preserved.
pub(all) enum ST_TLTimeIndefinite {
  /// §19.7.40 "indefinite".
  Indefinite
} derive(Eq, Debug)

///|
pub fn ST_TLTimeIndefinite::parse(
  s : String,
) -> ST_TLTimeIndefinite raise SchemaViolation {
  if s == "indefinite" {
    Indefinite
  } else {
    invalid_simple_type(
      "ST_TLTimeIndefinite", s, "the only allowed lexical value is `indefinite`",
    )
  }
}

///|
pub fn ST_TLTimeIndefinite::new(
  s : String,
) -> ST_TLTimeIndefinite raise SchemaViolation {
  ST_TLTimeIndefinite::parse(s)
}

///|
pub fn ST_TLTimeIndefinite::to_string(self : ST_TLTimeIndefinite) -> String {
  match self {
    Indefinite => "indefinite"
  }
}

// === §19.7.38 ST_TLTime ===================================================

///|
/// XSD simple type ST_TLTime — Part 1 §19.7.38. Union of
/// ST_TLTimeIndefinite (§19.7.40) and xsd:unsignedInt (a duration in
/// milliseconds).
pub enum ST_TLTime {
  /// §19.7.38 — the lexical token `indefinite`.
  TLTimeIndefinite
  /// §19.7.38 — duration in milliseconds (unsignedInt branch).
  TLTimeMs(UInt)
} derive(Eq, Debug)

///|
pub fn ST_TLTime::parse(s : String) -> ST_TLTime raise SchemaViolation {
  if s == "indefinite" {
    TLTimeIndefinite
  } else {
    match parse_xsd_unsigned_int(s) {
      Some(n) => TLTimeMs(n)
      None =>
        invalid_simple_type(
          "ST_TLTime", s, "must be `indefinite` or an unsignedInt millisecond count",
        )
    }
  }
}

///|
pub fn ST_TLTime::new(s : String) -> ST_TLTime raise SchemaViolation {
  ST_TLTime::parse(s)
}

///|
pub fn ST_TLTime::to_string(self : ST_TLTime) -> String {
  match self {
    TLTimeIndefinite => "indefinite"
    TLTimeMs(n) => n.to_string()
  }
}

// === §19.7.39 ST_TLTimeAnimateValueTime ===================================

///|
/// XSD simple type ST_TLTimeAnimateValueTime — Part 1 §19.7.39. Union
/// of ST_PositiveFixedPercentage (DrawingML §20.1.10.45) and
/// ST_TLTimeIndefinite (§19.7.40).
///
/// The percentage is held in 1000ths of a percent so callers compare
/// without re-parsing the lexical form (matching the encoding
/// ST_PositiveFixedPercentage uses in `src/ecma376/simple_types`).
pub enum ST_TLTimeAnimateValueTime {
  /// §19.7.39 — ST_PositiveFixedPercentage branch. The Int64 holds
  /// 1000ths of a percent (e.g. "12.345%" → 12345). Non-negative and
  /// ≤ 100000.
  AnimValuePercentage(Int64)
  /// §19.7.39 — the lexical token `indefinite`.
  AnimValueIndefinite
} derive(Eq, Debug)

///|
pub fn ST_TLTimeAnimateValueTime::parse(
  s : String,
) -> ST_TLTimeAnimateValueTime raise SchemaViolation {
  if s == "indefinite" {
    AnimValueIndefinite
  } else if s.length() >= 2 && s.code_unit_at(s.length() - 1).to_int() == 0x25 {
    // percentage lexical form: <decimal>%
    let magnitude_end = s.length() - 1
    match parse_fixed_positive_percentage(s, magnitude_end) {
      Some(thousandths) => AnimValuePercentage(thousandths)
      None =>
        invalid_simple_type(
          "ST_TLTimeAnimateValueTime", s, "percentage outside the [0%, 100%] range or malformed",
        )
    }
  } else {
    invalid_simple_type(
      "ST_TLTimeAnimateValueTime", s, "must be `indefinite` or a positive fixed percentage (e.g. `50%`)",
    )
  }
}

///|
pub fn ST_TLTimeAnimateValueTime::new(
  s : String,
) -> ST_TLTimeAnimateValueTime raise SchemaViolation {
  ST_TLTimeAnimateValueTime::parse(s)
}

///|
pub fn ST_TLTimeAnimateValueTime::to_string(
  self : ST_TLTimeAnimateValueTime,
) -> String {
  match self {
    AnimValueIndefinite => "indefinite"
    AnimValuePercentage(thousandths) => format_thousandths_percent(thousandths)
  }
}

///|
/// Parse a non-negative decimal magnitude in [0, 100] into 1000ths of
/// a percent, scanning `s[0:end]`. Returns None on malformed input or
/// when the value exceeds 100.
fn parse_fixed_positive_percentage(s : String, end : Int) -> Int64? {
  if end <= 0 {
    return None
  }
  let mut pos = 0
  let mut whole : Int64 = 0L
  let mut whole_digits = 0
  while pos < end {
    let unit = s.code_unit_at(pos).to_int()
    if unit < 0x30 || unit > 0x39 {
      break
    }
    whole = whole * 10L + (unit - 0x30).to_int64()
    whole_digits = whole_digits + 1
    pos = pos + 1
    if whole > 100L {
      return None
    }
  }
  if whole_digits == 0 {
    return None
  }
  let mut fraction_thousandths : Int64 = 0L
  if pos < end && s.code_unit_at(pos).to_int() == 0x2E {
    // '.' fractional part
    pos = pos + 1
    let mut multiplier : Int64 = 100L
    let mut frac_digits = 0
    while pos < end {
      let unit = s.code_unit_at(pos).to_int()
      if unit < 0x30 || unit > 0x39 {
        return None
      }
      let digit = (unit - 0x30).to_int64()
      if multiplier > 0L {
        fraction_thousandths = fraction_thousandths + digit * multiplier
        multiplier = multiplier / 10L
      }
      frac_digits = frac_digits + 1
      pos = pos + 1
    }
    if frac_digits == 0 {
      return None
    }
  }
  if pos != end {
    return None
  }
  let total = whole * 1000L + fraction_thousandths
  if total > 100000L {
    None
  } else {
    Some(total)
  }
}

///|
/// Render a 1000ths-of-a-percent integer as `<decimal>%`. Trailing
/// zeros in the fractional part are trimmed.
fn format_thousandths_percent(thousandths : Int64) -> String {
  let whole = thousandths / 1000L
  let fraction = thousandths - whole * 1000L
  if fraction == 0L {
    whole.to_string() + "%"
  } else {
    let mut frac_text = fraction.to_string()
    while frac_text.length() < 3 {
      frac_text = "0" + frac_text
    }
    let mut end = frac_text.length()
    while end > 0 && frac_text.code_unit_at(end - 1).to_int() == 0x30 {
      end = end - 1
    }
    whole.to_string() + "." + frac_text.unsafe_substring(start=0, end~) + "%"
  }
}

// === §19.7.41 ST_TLTimeNodeFillType =======================================

///|
/// XSD simple type ST_TLTimeNodeFillType — Part 1 §19.7.41. Four
/// xsd:token values describing what an effect leaves on the target
/// when it ends.
pub(all) enum ST_TLTimeNodeFillType {
  /// §19.7.41 "remove".
  NodeFillRemove
  /// §19.7.41 "freeze".
  NodeFillFreeze
  /// §19.7.41 "hold".
  NodeFillHold
  /// §19.7.41 "transition".
  NodeFillTransition
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeFillType::parse(
  s : String,
) -> ST_TLTimeNodeFillType raise SchemaViolation {
  match s {
    "remove" => NodeFillRemove
    "freeze" => NodeFillFreeze
    "hold" => NodeFillHold
    "transition" => NodeFillTransition
    _ =>
      invalid_simple_type(
        "ST_TLTimeNodeFillType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLTimeNodeFillType::new(
  s : String,
) -> ST_TLTimeNodeFillType raise SchemaViolation {
  ST_TLTimeNodeFillType::parse(s)
}

///|
pub fn ST_TLTimeNodeFillType::to_string(self : ST_TLTimeNodeFillType) -> String {
  match self {
    NodeFillRemove => "remove"
    NodeFillFreeze => "freeze"
    NodeFillHold => "hold"
    NodeFillTransition => "transition"
  }
}

// === §19.7.42 ST_TLTimeNodeID =============================================

///|
/// XSD simple type ST_TLTimeNodeID — Part 1 §19.7.42. Plain
/// xsd:unsignedInt that identifies a time-node on the timeline.
pub struct ST_TLTimeNodeID {
  value : UInt
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeID::parse(
  s : String,
) -> ST_TLTimeNodeID raise SchemaViolation {
  match parse_xsd_unsigned_int(s) {
    None => invalid_simple_type("ST_TLTimeNodeID", s, "not an unsignedInt")
    Some(n) => { value: n }
  }
}

///|
pub fn ST_TLTimeNodeID::new(
  s : String,
) -> ST_TLTimeNodeID raise SchemaViolation {
  ST_TLTimeNodeID::parse(s)
}

///|
pub fn ST_TLTimeNodeID::to_string(self : ST_TLTimeNodeID) -> String {
  self.value.to_string()
}

///|
pub fn ST_TLTimeNodeID::to_uint(self : ST_TLTimeNodeID) -> UInt {
  self.value
}

// === §19.7.43 ST_TLTimeNodeMasterRelation =================================

///|
/// XSD simple type ST_TLTimeNodeMasterRelation — Part 1 §19.7.43.
/// Three-value xsd:token enumeration: sameClick / lastClick /
/// nextClick.
pub(all) enum ST_TLTimeNodeMasterRelation {
  /// §19.7.43 "sameClick".
  MasterRelSameClick
  /// §19.7.43 "lastClick".
  MasterRelLastClick
  /// §19.7.43 "nextClick".
  MasterRelNextClick
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeMasterRelation::parse(
  s : String,
) -> ST_TLTimeNodeMasterRelation raise SchemaViolation {
  match s {
    "sameClick" => MasterRelSameClick
    "lastClick" => MasterRelLastClick
    "nextClick" => MasterRelNextClick
    _ =>
      invalid_simple_type(
        "ST_TLTimeNodeMasterRelation", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLTimeNodeMasterRelation::new(
  s : String,
) -> ST_TLTimeNodeMasterRelation raise SchemaViolation {
  ST_TLTimeNodeMasterRelation::parse(s)
}

///|
pub fn ST_TLTimeNodeMasterRelation::to_string(
  self : ST_TLTimeNodeMasterRelation,
) -> String {
  match self {
    MasterRelSameClick => "sameClick"
    MasterRelLastClick => "lastClick"
    MasterRelNextClick => "nextClick"
  }
}

// === §19.7.44 ST_TLTimeNodePresetClassType ================================

///|
/// XSD simple type ST_TLTimeNodePresetClassType — Part 1 §19.7.44.
/// Six xsd:token values for the preset class of an effect.
pub(all) enum ST_TLTimeNodePresetClassType {
  /// §19.7.44 "entr" (Entrance).
  PresetEntr
  /// §19.7.44 "exit".
  PresetExit
  /// §19.7.44 "emph" (Emphasis).
  PresetEmph
  /// §19.7.44 "path".
  PresetPath
  /// §19.7.44 "verb".
  PresetVerb
  /// §19.7.44 "mediacall" (Media Call).
  PresetMediacall
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodePresetClassType::parse(
  s : String,
) -> ST_TLTimeNodePresetClassType raise SchemaViolation {
  match s {
    "entr" => PresetEntr
    "exit" => PresetExit
    "emph" => PresetEmph
    "path" => PresetPath
    "verb" => PresetVerb
    "mediacall" => PresetMediacall
    _ =>
      invalid_simple_type(
        "ST_TLTimeNodePresetClassType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLTimeNodePresetClassType::new(
  s : String,
) -> ST_TLTimeNodePresetClassType raise SchemaViolation {
  ST_TLTimeNodePresetClassType::parse(s)
}

///|
pub fn ST_TLTimeNodePresetClassType::to_string(
  self : ST_TLTimeNodePresetClassType,
) -> String {
  match self {
    PresetEntr => "entr"
    PresetExit => "exit"
    PresetEmph => "emph"
    PresetPath => "path"
    PresetVerb => "verb"
    PresetMediacall => "mediacall"
  }
}

// === §19.7.45 ST_TLTimeNodeRestartType ====================================

///|
/// XSD simple type ST_TLTimeNodeRestartType — Part 1 §19.7.45. Three
/// xsd:token values: always / whenNotActive / never.
pub(all) enum ST_TLTimeNodeRestartType {
  /// §19.7.45 "always".
  RestartAlways
  /// §19.7.45 "whenNotActive".
  RestartWhenNotActive
  /// §19.7.45 "never".
  RestartNever
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeRestartType::parse(
  s : String,
) -> ST_TLTimeNodeRestartType raise SchemaViolation {
  match s {
    "always" => RestartAlways
    "whenNotActive" => RestartWhenNotActive
    "never" => RestartNever
    _ =>
      invalid_simple_type(
        "ST_TLTimeNodeRestartType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLTimeNodeRestartType::new(
  s : String,
) -> ST_TLTimeNodeRestartType raise SchemaViolation {
  ST_TLTimeNodeRestartType::parse(s)
}

///|
pub fn ST_TLTimeNodeRestartType::to_string(
  self : ST_TLTimeNodeRestartType,
) -> String {
  match self {
    RestartAlways => "always"
    RestartWhenNotActive => "whenNotActive"
    RestartNever => "never"
  }
}

// === §19.7.46 ST_TLTimeNodeSyncType =======================================

///|
/// XSD simple type ST_TLTimeNodeSyncType — Part 1 §19.7.46. Two
/// xsd:token values: canSlip / locked.
pub(all) enum ST_TLTimeNodeSyncType {
  /// §19.7.46 "canSlip".
  SyncCanSlip
  /// §19.7.46 "locked".
  SyncLocked
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeSyncType::parse(
  s : String,
) -> ST_TLTimeNodeSyncType raise SchemaViolation {
  match s {
    "canSlip" => SyncCanSlip
    "locked" => SyncLocked
    _ =>
      invalid_simple_type(
        "ST_TLTimeNodeSyncType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLTimeNodeSyncType::new(
  s : String,
) -> ST_TLTimeNodeSyncType raise SchemaViolation {
  ST_TLTimeNodeSyncType::parse(s)
}

///|
pub fn ST_TLTimeNodeSyncType::to_string(self : ST_TLTimeNodeSyncType) -> String {
  match self {
    SyncCanSlip => "canSlip"
    SyncLocked => "locked"
  }
}

// === §19.7.47 ST_TLTimeNodeType ===========================================

///|
/// XSD simple type ST_TLTimeNodeType — Part 1 §19.7.47. Nine
/// xsd:token values for time-node semantic classification.
pub(all) enum ST_TLTimeNodeType {
  /// §19.7.47 "clickEffect".
  NodeClickEffect
  /// §19.7.47 "withEffect".
  NodeWithEffect
  /// §19.7.47 "afterEffect".
  NodeAfterEffect
  /// §19.7.47 "mainSeq".
  NodeMainSeq
  /// §19.7.47 "interactiveSeq".
  NodeInteractiveSeq
  /// §19.7.47 "clickPar" (Click Paragraph).
  NodeClickPar
  /// §19.7.47 "withGroup".
  NodeWithGroup
  /// §19.7.47 "afterGroup".
  NodeAfterGroup
  /// §19.7.47 "tmRoot" (Timing Root).
  NodeTmRoot
} derive(Eq, Debug)

///|
pub fn ST_TLTimeNodeType::parse(
  s : String,
) -> ST_TLTimeNodeType raise SchemaViolation {
  match s {
    "clickEffect" => NodeClickEffect
    "withEffect" => NodeWithEffect
    "afterEffect" => NodeAfterEffect
    "mainSeq" => NodeMainSeq
    "interactiveSeq" => NodeInteractiveSeq
    "clickPar" => NodeClickPar
    "withGroup" => NodeWithGroup
    "afterGroup" => NodeAfterGroup
    "tmRoot" => NodeTmRoot
    _ =>
      invalid_simple_type("ST_TLTimeNodeType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_TLTimeNodeType::new(
  s : String,
) -> ST_TLTimeNodeType raise SchemaViolation {
  ST_TLTimeNodeType::parse(s)
}

///|
pub fn ST_TLTimeNodeType::to_string(self : ST_TLTimeNodeType) -> String {
  match self {
    NodeClickEffect => "clickEffect"
    NodeWithEffect => "withEffect"
    NodeAfterEffect => "afterEffect"
    NodeMainSeq => "mainSeq"
    NodeInteractiveSeq => "interactiveSeq"
    NodeClickPar => "clickPar"
    NodeWithGroup => "withGroup"
    NodeAfterGroup => "afterGroup"
    NodeTmRoot => "tmRoot"
  }
}

// === §19.7.48 ST_TLTriggerEvent ===========================================

///|
/// XSD simple type ST_TLTriggerEvent — Part 1 §19.7.48. Eleven
/// xsd:token values describing the event that fires a trigger.
pub(all) enum ST_TLTriggerEvent {
  /// §19.7.48 "onBegin".
  TriggerOnBegin
  /// §19.7.48 "onEnd".
  TriggerOnEnd
  /// §19.7.48 "begin".
  TriggerBegin
  /// §19.7.48 "end".
  TriggerEnd
  /// §19.7.48 "onClick".
  TriggerOnClick
  /// §19.7.48 "onDblClick".
  TriggerOnDblClick
  /// §19.7.48 "onMouseOver".
  TriggerOnMouseOver
  /// §19.7.48 "onMouseOut".
  TriggerOnMouseOut
  /// §19.7.48 "onNext".
  TriggerOnNext
  /// §19.7.48 "onPrev".
  TriggerOnPrev
  /// §19.7.48 "onStopAudio".
  TriggerOnStopAudio
} derive(Eq, Debug)

///|
pub fn ST_TLTriggerEvent::parse(
  s : String,
) -> ST_TLTriggerEvent raise SchemaViolation {
  match s {
    "onBegin" => TriggerOnBegin
    "onEnd" => TriggerOnEnd
    "begin" => TriggerBegin
    "end" => TriggerEnd
    "onClick" => TriggerOnClick
    "onDblClick" => TriggerOnDblClick
    "onMouseOver" => TriggerOnMouseOver
    "onMouseOut" => TriggerOnMouseOut
    "onNext" => TriggerOnNext
    "onPrev" => TriggerOnPrev
    "onStopAudio" => TriggerOnStopAudio
    _ =>
      invalid_simple_type("ST_TLTriggerEvent", s, "unknown enumeration value")
  }
}

///|
pub fn ST_TLTriggerEvent::new(
  s : String,
) -> ST_TLTriggerEvent raise SchemaViolation {
  ST_TLTriggerEvent::parse(s)
}

///|
pub fn ST_TLTriggerEvent::to_string(self : ST_TLTriggerEvent) -> String {
  match self {
    TriggerOnBegin => "onBegin"
    TriggerOnEnd => "onEnd"
    TriggerBegin => "begin"
    TriggerEnd => "end"
    TriggerOnClick => "onClick"
    TriggerOnDblClick => "onDblClick"
    TriggerOnMouseOver => "onMouseOver"
    TriggerOnMouseOut => "onMouseOut"
    TriggerOnNext => "onNext"
    TriggerOnPrev => "onPrev"
    TriggerOnStopAudio => "onStopAudio"
  }
}

// === §19.7.49 ST_TLTriggerRuntimeNode =====================================

///|
/// XSD simple type ST_TLTriggerRuntimeNode — Part 1 §19.7.49. Three
/// xsd:token values: first / last / all.
pub(all) enum ST_TLTriggerRuntimeNode {
  /// §19.7.49 "first".
  RuntimeFirst
  /// §19.7.49 "last".
  RuntimeLast
  /// §19.7.49 "all".
  RuntimeAll
} derive(Eq, Debug)

///|
pub fn ST_TLTriggerRuntimeNode::parse(
  s : String,
) -> ST_TLTriggerRuntimeNode raise SchemaViolation {
  match s {
    "first" => RuntimeFirst
    "last" => RuntimeLast
    "all" => RuntimeAll
    _ =>
      invalid_simple_type(
        "ST_TLTriggerRuntimeNode", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TLTriggerRuntimeNode::new(
  s : String,
) -> ST_TLTriggerRuntimeNode raise SchemaViolation {
  ST_TLTriggerRuntimeNode::parse(s)
}

///|
pub fn ST_TLTriggerRuntimeNode::to_string(
  self : ST_TLTriggerRuntimeNode,
) -> String {
  match self {
    RuntimeFirst => "first"
    RuntimeLast => "last"
    RuntimeAll => "all"
  }
}

// === §19.7.50 ST_TransitionCornerDirectionType ============================

///|
/// XSD simple type ST_TransitionCornerDirectionType — Part 1 §19.7.50.
/// Four xsd:token values for diagonal transition directions.
pub(all) enum ST_TransitionCornerDirectionType {
  /// §19.7.50 "lu" (Left-Up).
  CornerLu
  /// §19.7.50 "ru" (Right-Up).
  CornerRu
  /// §19.7.50 "ld" (Left-Down).
  CornerLd
  /// §19.7.50 "rd" (Right-Down).
  CornerRd
} derive(Eq, Debug)

///|
pub fn ST_TransitionCornerDirectionType::parse(
  s : String,
) -> ST_TransitionCornerDirectionType raise SchemaViolation {
  match s {
    "lu" => CornerLu
    "ru" => CornerRu
    "ld" => CornerLd
    "rd" => CornerRd
    _ =>
      invalid_simple_type(
        "ST_TransitionCornerDirectionType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TransitionCornerDirectionType::new(
  s : String,
) -> ST_TransitionCornerDirectionType raise SchemaViolation {
  ST_TransitionCornerDirectionType::parse(s)
}

///|
pub fn ST_TransitionCornerDirectionType::to_string(
  self : ST_TransitionCornerDirectionType,
) -> String {
  match self {
    CornerLu => "lu"
    CornerRu => "ru"
    CornerLd => "ld"
    CornerRd => "rd"
  }
}

// === §19.7.53 ST_TransitionSideDirectionType (before union §19.7.51) ======

///|
/// XSD simple type ST_TransitionSideDirectionType — Part 1 §19.7.53.
/// Four xsd:token values for cardinal slide-transition directions.
pub(all) enum ST_TransitionSideDirectionType {
  /// §19.7.53 "l" (Left).
  SideL
  /// §19.7.53 "u" (Up).
  SideU
  /// §19.7.53 "r" (Right).
  SideR
  /// §19.7.53 "d" (Down).
  SideD
} derive(Eq, Debug)

///|
pub fn ST_TransitionSideDirectionType::parse(
  s : String,
) -> ST_TransitionSideDirectionType raise SchemaViolation {
  match s {
    "l" => SideL
    "u" => SideU
    "r" => SideR
    "d" => SideD
    _ =>
      invalid_simple_type(
        "ST_TransitionSideDirectionType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TransitionSideDirectionType::new(
  s : String,
) -> ST_TransitionSideDirectionType raise SchemaViolation {
  ST_TransitionSideDirectionType::parse(s)
}

///|
pub fn ST_TransitionSideDirectionType::to_string(
  self : ST_TransitionSideDirectionType,
) -> String {
  match self {
    SideL => "l"
    SideU => "u"
    SideR => "r"
    SideD => "d"
  }
}

// === §19.7.51 ST_TransitionEightDirectionType =============================

///|
/// XSD simple type ST_TransitionEightDirectionType — Part 1 §19.7.51.
/// Union of ST_TransitionCornerDirectionType (§19.7.50) and
/// ST_TransitionSideDirectionType (§19.7.53). The "eight" comes from
/// 4 corners + 4 sides.
pub enum ST_TransitionEightDirectionType {
  /// §19.7.51 — corner branch (lu/ru/ld/rd).
  EightCorner(ST_TransitionCornerDirectionType)
  /// §19.7.51 — side branch (l/u/r/d).
  EightSide(ST_TransitionSideDirectionType)
} derive(Eq, Debug)

///|
pub fn ST_TransitionEightDirectionType::parse(
  s : String,
) -> ST_TransitionEightDirectionType raise SchemaViolation {
  // Try corner first (lu/ru/ld/rd are two characters); fall back to
  // single-character side directions.
  match s {
    "lu" | "ru" | "ld" | "rd" =>
      EightCorner(ST_TransitionCornerDirectionType::parse(s))
    "l" | "u" | "r" | "d" => EightSide(ST_TransitionSideDirectionType::parse(s))
    _ =>
      invalid_simple_type(
        "ST_TransitionEightDirectionType", s, "expected one of l/u/r/d/lu/ru/ld/rd",
      )
  }
}

///|
pub fn ST_TransitionEightDirectionType::new(
  s : String,
) -> ST_TransitionEightDirectionType raise SchemaViolation {
  ST_TransitionEightDirectionType::parse(s)
}

///|
pub fn ST_TransitionEightDirectionType::to_string(
  self : ST_TransitionEightDirectionType,
) -> String {
  match self {
    EightCorner(c) => c.to_string()
    EightSide(s) => s.to_string()
  }
}

// === §19.7.52 ST_TransitionInOutDirectionType =============================

///|
/// XSD simple type ST_TransitionInOutDirectionType — Part 1 §19.7.52.
/// Two-value xsd:token enumeration: out / in.
pub(all) enum ST_TransitionInOutDirectionType {
  /// §19.7.52 "out".
  InOutOut
  /// §19.7.52 "in".
  InOutIn
} derive(Eq, Debug)

///|
pub fn ST_TransitionInOutDirectionType::parse(
  s : String,
) -> ST_TransitionInOutDirectionType raise SchemaViolation {
  match s {
    "out" => InOutOut
    "in" => InOutIn
    _ =>
      invalid_simple_type(
        "ST_TransitionInOutDirectionType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_TransitionInOutDirectionType::new(
  s : String,
) -> ST_TransitionInOutDirectionType raise SchemaViolation {
  ST_TransitionInOutDirectionType::parse(s)
}

///|
pub fn ST_TransitionInOutDirectionType::to_string(
  self : ST_TransitionInOutDirectionType,
) -> String {
  match self {
    InOutOut => "out"
    InOutIn => "in"
  }
}

// === §19.7.54 ST_TransitionSpeed ==========================================

///|
/// XSD simple type ST_TransitionSpeed — Part 1 §19.7.54. Three-value
/// xsd:token enumeration: slow / medium / fast.
pub(all) enum ST_TransitionSpeed {
  /// §19.7.54 "slow".
  SpeedSlow
  /// §19.7.54 "med" (Medium).
  SpeedMed
  /// §19.7.54 "fast".
  SpeedFast
} derive(Eq, Debug)

///|
pub fn ST_TransitionSpeed::parse(
  s : String,
) -> ST_TransitionSpeed raise SchemaViolation {
  match s {
    "slow" => SpeedSlow
    "med" => SpeedMed
    "fast" => SpeedFast
    _ =>
      invalid_simple_type("ST_TransitionSpeed", s, "unknown enumeration value")
  }
}

///|
pub fn ST_TransitionSpeed::new(
  s : String,
) -> ST_TransitionSpeed raise SchemaViolation {
  ST_TransitionSpeed::parse(s)
}

///|
pub fn ST_TransitionSpeed::to_string(self : ST_TransitionSpeed) -> String {
  match self {
    SpeedSlow => "slow"
    SpeedMed => "med"
    SpeedFast => "fast"
  }
}

// === §19.7.55 ST_ViewType =================================================

///|
/// XSD simple type ST_ViewType — Part 1 §19.7.55. Eight xsd:token
/// values listing the kinds of view available when rendering a
/// PresentationML document.
pub(all) enum ST_ViewType {
  /// §19.7.55 "sldView" (Normal Slide View).
  ViewSld
  /// §19.7.55 "sldMasterView".
  ViewSldMaster
  /// §19.7.55 "notesView".
  ViewNotes
  /// §19.7.55 "handoutView".
  ViewHandout
  /// §19.7.55 "notesMasterView".
  ViewNotesMaster
  /// §19.7.55 "outlineView".
  ViewOutline
  /// §19.7.55 "sldSorterView".
  ViewSldSorter
  /// §19.7.55 "sldThumbnailView".
  ViewSldThumbnail
} derive(Eq, Debug)

///|
pub fn ST_ViewType::parse(s : String) -> ST_ViewType raise SchemaViolation {
  match s {
    "sldView" => ViewSld
    "sldMasterView" => ViewSldMaster
    "notesView" => ViewNotes
    "handoutView" => ViewHandout
    "notesMasterView" => ViewNotesMaster
    "outlineView" => ViewOutline
    "sldSorterView" => ViewSldSorter
    "sldThumbnailView" => ViewSldThumbnail
    _ => invalid_simple_type("ST_ViewType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_ViewType::new(s : String) -> ST_ViewType raise SchemaViolation {
  ST_ViewType::parse(s)
}

///|
pub fn ST_ViewType::to_string(self : ST_ViewType) -> String {
  match self {
    ViewSld => "sldView"
    ViewSldMaster => "sldMasterView"
    ViewNotes => "notesView"
    ViewHandout => "handoutView"
    ViewNotesMaster => "notesMasterView"
    ViewOutline => "outlineView"
    ViewSldSorter => "sldSorterView"
    ViewSldThumbnail => "sldThumbnailView"
  }
}

// === Part 4 §16.5.1 ST_WebColorType =======================================

///|
/// XSD simple type ST_WebColorType — Part 4 §16.5.1. Six-value
/// xsd:token enumeration for HTML slide navigation control colors.
pub(all) enum ST_WebColorType {
  /// §16.5.1 "none".
  WebColorNone
  /// §16.5.1 "browser".
  WebColorBrowser
  /// §16.5.1 "presentationText".
  WebColorPresentationText
  /// §16.5.1 "presentationAccent".
  WebColorPresentationAccent
  /// §16.5.1 "whiteTextOnBlack".
  WebColorWhiteTextOnBlack
  /// §16.5.1 "blackTextOnWhite".
  WebColorBlackTextOnWhite
} derive(Eq, Debug)

///|
pub fn ST_WebColorType::parse(
  s : String,
) -> ST_WebColorType raise SchemaViolation {
  match s {
    "none" => WebColorNone
    "browser" => WebColorBrowser
    "presentationText" => WebColorPresentationText
    "presentationAccent" => WebColorPresentationAccent
    "whiteTextOnBlack" => WebColorWhiteTextOnBlack
    "blackTextOnWhite" => WebColorBlackTextOnWhite
    _ => invalid_simple_type("ST_WebColorType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_WebColorType::new(
  s : String,
) -> ST_WebColorType raise SchemaViolation {
  ST_WebColorType::parse(s)
}

///|
pub fn ST_WebColorType::to_string(self : ST_WebColorType) -> String {
  match self {
    WebColorNone => "none"
    WebColorBrowser => "browser"
    WebColorPresentationText => "presentationText"
    WebColorPresentationAccent => "presentationAccent"
    WebColorWhiteTextOnBlack => "whiteTextOnBlack"
    WebColorBlackTextOnWhite => "blackTextOnWhite"
  }
}

// === Part 4 §16.5.2 ST_WebEncoding ========================================

///|
/// XSD simple type ST_WebEncoding — Part 4 §16.5.2. Unconstrained
/// xsd:string holding the HTML character set name.
pub struct ST_WebEncoding {
  lexical : String
} derive(Eq, Debug)

///|
pub fn ST_WebEncoding::parse(s : String) -> ST_WebEncoding {
  { lexical: s }
}

///|
pub fn ST_WebEncoding::new(s : String) -> ST_WebEncoding {
  ST_WebEncoding::parse(s)
}

///|
pub fn ST_WebEncoding::to_string(self : ST_WebEncoding) -> String {
  self.lexical
}

// === Part 4 §16.5.3 ST_WebScreenSize ======================================

///|
/// XSD simple type ST_WebScreenSize — Part 4 §16.5.3. Eleven-value
/// xsd:token enumeration of HTML/Web screen-resolution presets.
pub(all) enum ST_WebScreenSize {
  /// §16.5.3 "544x376".
  WebSize544x376
  /// §16.5.3 "640x480".
  WebSize640x480
  /// §16.5.3 "720x512".
  WebSize720x512
  /// §16.5.3 "800x600".
  WebSize800x600
  /// §16.5.3 "1024x768".
  WebSize1024x768
  /// §16.5.3 "1152x882".
  WebSize1152x882
  /// §16.5.3 "1152x900".
  WebSize1152x900
  /// §16.5.3 "1280x1024".
  WebSize1280x1024
  /// §16.5.3 "1600x1200".
  WebSize1600x1200
  /// §16.5.3 "1800x1400".
  WebSize1800x1400
  /// §16.5.3 "1920x1200".
  WebSize1920x1200
} derive(Eq, Debug)

///|
pub fn ST_WebScreenSize::parse(
  s : String,
) -> ST_WebScreenSize raise SchemaViolation {
  match s {
    "544x376" => WebSize544x376
    "640x480" => WebSize640x480
    "720x512" => WebSize720x512
    "800x600" => WebSize800x600
    "1024x768" => WebSize1024x768
    "1152x882" => WebSize1152x882
    "1152x900" => WebSize1152x900
    "1280x1024" => WebSize1280x1024
    "1600x1200" => WebSize1600x1200
    "1800x1400" => WebSize1800x1400
    "1920x1200" => WebSize1920x1200
    _ => invalid_simple_type("ST_WebScreenSize", s, "unknown enumeration value")
  }
}

///|
pub fn ST_WebScreenSize::new(
  s : String,
) -> ST_WebScreenSize raise SchemaViolation {
  ST_WebScreenSize::parse(s)
}

///|
pub fn ST_WebScreenSize::to_string(self : ST_WebScreenSize) -> String {
  match self {
    WebSize544x376 => "544x376"
    WebSize640x480 => "640x480"
    WebSize720x512 => "720x512"
    WebSize800x600 => "800x600"
    WebSize1024x768 => "1024x768"
    WebSize1152x882 => "1152x882"
    WebSize1152x900 => "1152x900"
    WebSize1280x1024 => "1280x1024"
    WebSize1600x1200 => "1600x1200"
    WebSize1800x1400 => "1800x1400"
    WebSize1920x1200 => "1920x1200"
  }
}
