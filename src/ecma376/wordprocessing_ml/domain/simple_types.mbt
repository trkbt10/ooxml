///|
/// Schema validation error for ECMA-376 WordprocessingML simple types (§17.18).
pub suberror SchemaViolation {
  SchemaViolation(type_name~ : String, value~ : String, reason~ : String)
} derive(Debug)

///|
fn[T] invalid_simple_type(
  type_name : String,
  value : String,
  reason : String,
) -> T raise SchemaViolation {
  raise SchemaViolation(type_name~, value~, reason~)
}

///|
fn validate_wml_simple_type(
  type_name : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    invalid_simple_type(type_name, value, "empty lexical value")
  }
  let allowed = wml_simple_type_values(type_name)
  if allowed.length() > 0 && !allowed.contains(";" + value + ";") {
    invalid_simple_type(type_name, value, "unknown enumeration value")
  }
}

///|
fn wml_simple_type_values(type_name : String) -> String {
  match type_name {
    "ST_HighlightColor" =>
      ";black;blue;cyan;green;magenta;red;yellow;white;darkBlue;darkCyan;darkGreen;darkMagenta;darkRed;darkYellow;darkGray;lightGray;none;"
    "ST_HexColorAuto" => ";auto;"
    "ST_Border" =>
      ";nil;none;single;thick;double;dotted;dashed;dotDash;dotDotDash;triple;thinThickSmallGap;thickThinSmallGap;thinThickThinSmallGap;thinThickMediumGap;thickThinMediumGap;thinThickThinMediumGap;thinThickLargeGap;thickThinLargeGap;thinThickThinLargeGap;wave;doubleWave;dashSmallGap;dashDotStroked;threeDEmboss;threeDEngrave;outset;inset;apples;archedScallops;babyPacifier;babyRattle;balloons3Colors;balloonsHotAir;basicBlackDashes;basicBlackDots;basicBlackSquares;basicThinLines;basicWhiteDashes;basicWhiteDots;basicWhiteSquares;basicWideInline;basicWideMidline;basicWideOutline;bats;birds;birdsFlight;cabins;cakeSlice;candyCorn;celticKnotwork;certificateBanner;chainLink;champagneBottle;checkedBarBlack;checkedBarColor;checkered;christmasTree;circlesLines;circlesRectangles;classicalWave;clocks;compass;confetti;confettiGrays;confettiOutline;confettiStreamers;confettiWhite;cornerTriangles;couponCutoutDashes;couponCutoutDots;crazyMaze;creaturesButterfly;creaturesFish;creaturesInsects;creaturesLadyBug;crossStitch;cup;decoArch;decoArchColor;decoBlocks;diamondsGray;doubleD;doubleDiamonds;earth1;earth2;earth3;eclipsingSquares1;eclipsingSquares2;eggsBlack;fans;film;firecrackers;flowersBlockPrint;flowersDaisies;flowersModern1;flowersModern2;flowersPansy;flowersRedRose;flowersRoses;flowersTeacup;flowersTiny;gems;gingerbreadMan;gradient;handmade1;handmade2;heartBalloon;heartGray;hearts;heebieJeebies;holly;houseFunky;hypnotic;iceCreamCones;lightBulb;lightning1;lightning2;mapPins;mapleLeaf;mapleMuffins;marquee;marqueeToothed;moons;mosaic;musicNotes;northwest;ovals;packages;palmsBlack;palmsColor;paperClips;papyrus;partyFavor;partyGlass;pencils;people;peopleWaving;peopleHats;poinsettias;postageStamp;pumpkin1;pushPinNote2;pushPinNote1;pyramids;pyramidsAbove;quadrants;rings;safari;sawtooth;sawtoothGray;scaredCat;seattle;shadowedSquares;sharksTeeth;shorebirdTracks;skyrocket;snowflakeFancy;snowflakes;sombrero;southwest;stars;starsTop;stars3d;starsBlack;starsShadowed;sun;swirligig;tornPaper;tornPaperBlack;trees;triangleParty;triangles;triangle1;triangle2;triangleCircle1;triangleCircle2;shapes1;shapes2;twistedLines1;twistedLines2;vine;waveline;weavingAngles;weavingBraid;weavingRibbon;weavingStrips;whiteFlowers;woodwork;xIllusions;zanyTriangles;zigZag;zigZagStitch;custom;"
    "ST_Em" => ";none;dot;comma;circle;underDot;"
    "ST_CombineBrackets" => ";none;round;square;angle;curly;"
    "ST_HeightRule" => ";auto;exact;atLeast;"
    "ST_HAnchor" => ";text;margin;page;"
    "ST_DropCap" => ";none;drop;margin;"
    "ST_LineSpacingRule" => ";auto;exact;atLeast;"
    "ST_Jc" =>
      ";start;center;end;both;mediumKashida;distribute;numTab;highKashida;lowKashida;thaiDistribute;"
    "ST_JcTable" => ";center;end;start;"
    "ST_Underline" =>
      ";single;words;double;thick;dotted;dottedHeavy;dash;dashedHeavy;dashLong;dashLongHeavy;dotDash;dashDotHeavy;dotDotDash;dashDotDotHeavy;wave;wavyHeavy;wavyDouble;none;"
    "ST_TextEffect" =>
      ";blinkBackground;lights;antsBlack;antsRed;shimmer;sparkle;none;"
    "ST_Shd" =>
      ";nil;clear;solid;horzStripe;vertStripe;reverseDiagStripe;diagStripe;horzCross;diagCross;thinHorzStripe;thinVertStripe;thinReverseDiagStripe;thinDiagStripe;thinHorzCross;thinDiagCross;pct5;pct10;pct12;pct15;pct20;pct25;pct30;pct35;pct37;pct40;pct45;pct50;pct55;pct60;pct62;pct65;pct70;pct75;pct80;pct85;pct87;pct90;pct95;"
    "ST_Wrap" => ";auto;notBeside;around;tight;through;none;"
    "ST_VAnchor" => ";text;margin;page;"
    // Strict + Transitional (§17.18.84) — `left`/`right` alias
    // `start`/`end`; see `ST_TabJc::parse`.
    "ST_TabJc" => ";clear;start;center;end;decimal;bar;num;left;right;"
    "ST_TabTlc" => ";none;dot;hyphen;underscore;heavy;middleDot;"
    "ST_View" => ";none;print;outline;masterPages;normal;web;"
    "ST_Zoom" => ";none;fullPage;bestFit;textFit;"
    "ST_Proof" => ";clean;dirty;"
    "ST_MailMergeDocType" =>
      ";catalog;envelopes;mailingLabels;formLetters;email;fax;"
    "ST_MailMergeDest" => ";newDocument;printer;email;fax;"
    "ST_MailMergeOdsoFMDFieldType" => ";null;dbColumn;"
    "ST_DisplacedByCustomXml" => ";next;prev;"
    "ST_AnnotationVMerge" => ";cont;rest;"
    "ST_DocProtect" => ";none;readOnly;comments;trackedChanges;forms;"
    // Both the Strict (4th edition) and the Transitional (ISO/IEC
    // 29500-1 §17.18.93, written by Word 2007 / LibreOffice) token
    // sets are accepted; see `ST_TextDirection::parse`.
    "ST_TextDirection" =>
      ";tb;rl;lr;tbV;rlV;lrV;lrTb;tbRl;btLr;lrTbV;tbRlV;tbLrV;"
    "ST_TextAlignment" => ";top;center;baseline;bottom;auto;"
    "ST_TextboxTightWrap" =>
      ";none;allLines;firstAndLastLine;firstLineOnly;lastLineOnly;"
    "ST_ObjectDrawAspect" => ";content;icon;"
    "ST_ObjectUpdateMode" => ";always;onCall;"
    "ST_InfoTextType" => ";text;autoText;"
    "ST_FFTextType" =>
      ";regular;number;date;currentTime;currentDate;calculated;"
    "ST_NumberFormat" =>
      ";decimal;upperRoman;lowerRoman;upperLetter;lowerLetter;ordinal;cardinalText;ordinalText;hex;chicago;ideographDigital;japaneseCounting;aiueo;iroha;decimalFullWidth;decimalHalfWidth;japaneseLegal;japaneseDigitalTenThousand;decimalEnclosedCircle;decimalFullWidth2;aiueoFullWidth;irohaFullWidth;decimalZero;bullet;ganada;chosung;decimalEnclosedFullstop;decimalEnclosedParen;decimalEnclosedCircleChinese;ideographEnclosedCircle;ideographTraditional;ideographZodiac;ideographZodiacTraditional;taiwaneseCounting;ideographLegalTraditional;taiwaneseCountingThousand;taiwaneseDigital;chineseCounting;chineseLegalSimplified;chineseCountingThousand;koreanDigital;koreanCounting;koreanLegal;koreanDigital2;vietnameseCounting;russianLower;russianUpper;none;numberInDash;hebrew1;hebrew2;arabicAlpha;arabicAbjad;hindiVowels;hindiConsonants;hindiNumbers;hindiCounting;thaiLetters;thaiNumbers;thaiCounting;bahtText;dollarText;custom;"
    "ST_PageOrientation" => ";portrait;landscape;"
    "ST_PageBorderZOrder" => ";front;back;"
    "ST_PageBorderDisplay" => ";allPages;firstPage;notFirstPage;"
    "ST_PageBorderOffset" => ";page;text;"
    "ST_LineNumberRestart" => ";newPage;newSection;continuous;"
    "ST_DocGrid" => ";default;lines;linesAndChars;snapToChars;"
    "ST_HdrFtr" => ";even;default;first;"
    "ST_FtnEdn" => ";normal;separator;continuationSeparator;continuationNotice;"
    "ST_BrType" => ";page;column;textWrapping;"
    "ST_BrClear" => ";none;left;right;all;"
    "ST_PTabAlignment" => ";left;center;right;"
    "ST_PTabRelativeTo" => ";margin;indent;"
    "ST_PTabLeader" => ";none;dot;hyphen;underscore;middleDot;"
    "ST_ProofErr" => ";spellStart;spellEnd;gramStart;gramEnd;"
    "ST_Hint" => ";default;eastAsia;"
    "ST_Lock" => ";sdtLocked;contentLocked;unlocked;sdtContentLocked;"
    "ST_Direction" => ";ltr;rtl;"
    "ST_Merge" => ";continue;restart;"
    "ST_FtnPos" => ";pageBottom;beneathText;sectEnd;docEnd;"
    "ST_EdnPos" => ";sectEnd;docEnd;"
    "ST_MailMergeSourceType" =>
      ";database;addressBook;document1;document2;text;email;native;legacy;master;"
    "ST_CharacterSpacing" =>
      ";doNotCompress;compressPunctuation;compressPunctuationAndJapaneseKana;"
    "ST_FrameScrollbar" => ";on;off;auto;"
    "ST_FrameLayout" => ";rows;cols;none;"
    "ST_LevelSuffix" => ";tab;space;nothing;"
    "ST_MultiLevelType" => ";singleLevel;multilevel;hybridMultilevel;"
    "ST_FontFamily" => ";decorative;modern;roman;script;swiss;auto;"
    "ST_Pitch" => ";fixed;variable;default;"
    "ST_DocPartBehavior" => ";content;p;pg;"
    "ST_DocPartType" => ";none;normal;autoExp;toolbar;speller;formFld;bbPlcHdr;"
    "ST_DocPartGallery" =>
      ";placeholder;any;default;docParts;coverPg;eq;ftrs;hdrs;pgNum;tbls;watermarks;autoTxt;txtBox;pgNumT;pgNumB;pgNumMargins;tblOfContents;bib;custQuickParts;custCoverPg;custEq;custFtrs;custHdrs;custPgNum;custTbls;custWatermarks;custAutoTxt;custTxtBox;custPgNumT;custPgNumB;custPgNumMargins;custTblOfContents;custBib;custom1;custom2;custom3;custom4;custom5;"
    "ST_CaptionPos" => ";above;below;left;right;"
    "ST_Theme" =>
      ";majorEastAsia;majorBidi;majorAscii;majorHAnsi;minorEastAsia;minorBidi;minorAscii;minorHAnsi;"
    "ST_RubyAlign" =>
      ";center;distributeLetter;distributeSpace;left;right;rightVertical;"
    "ST_SdtDateMappingType" => ";text;date;dateTime;"
    "ST_TblWidth" => ";nil;pct;dxa;auto;"
    "ST_TblLayoutType" => ";fixed;autofit;"
    "ST_TblOverlap" => ";never;overlap;"
    "ST_RestartNumber" => ";continuous;eachSect;eachPage;"
    "ST_TargetScreenSz" =>
      ";544x376;640x480;720x512;800x600;1024x768;1152x882;1152x900;1280x1024;1600x1200;1800x1440;1920x1200;"
    "ST_WmlColorSchemeIndex" =>
      ";dark1;light1;dark2;light2;accent1;accent2;accent3;accent4;accent5;accent6;hyperlink;followedHyperlink;"
    "ST_StyleSort" => ";name;priority;default;font;basedOn;type;"
    "ST_LevelSuffix" => ";tab;space;nothing;"
    "ST_MultiLevelType" => ";singleLevel;multilevel;hybridMultilevel;"
    "ST_TblStyleOverrideType" =>
      ";wholeTable;firstRow;lastRow;firstCol;lastCol;band1Vert;band2Vert;band1Horz;band2Horz;neCell;nwCell;seCell;swCell;"
    "ST_StyleType" => ";paragraph;character;table;numbering;"
    "ST_Pitch" => ";fixed;variable;default;"
    "ST_FontFamily" => ";decorative;modern;roman;script;swiss;auto;"
    "ST_ThemeColor" =>
      ";dark1;light1;dark2;light2;accent1;accent2;accent3;accent4;accent5;accent6;hyperlink;followedHyperlink;none;background1;text1;background2;text2;"
    _ => ""
  }
}

///|
/// Parse a xsd:integer lexical form (optional leading `+`/`-`, decimal
/// digits) into Int. Empty strings and non-digit characters raise.
fn parse_signed_int_lexical(
  type_name : String,
  value : String,
) -> Int raise SchemaViolation {
  if value.length() == 0 {
    invalid_simple_type(type_name, value, "empty lexical value")
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
    invalid_simple_type(type_name, value, "missing digits after sign")
  }
  let mut n = 0
  while i < value.length() {
    let ch = value[i:i + 1]
    if ch < "0" || ch > "9" {
      invalid_simple_type(type_name, value, "non-digit in integer")
    }
    let d = ch[0].to_int() - "0"[0].to_int()
    n = n * 10 + d
    i = i + 1
  }
  if negative {
    -n
  } else {
    n
  }
}

///|
/// Parse a xsd:unsignedInt / unsignedLong style lexical integer (no
/// sign, decimal digits) into UInt64 to cover the full 0..2^64 − 1
/// range. Used by ST_EighthPointMeasure and similar Part 1 §17.18.*
/// types whose base is xsd:unsignedLong.
fn parse_unsigned_int64_lexical(
  type_name : String,
  value : String,
) -> UInt64 raise SchemaViolation {
  if value.length() == 0 {
    invalid_simple_type(type_name, value, "empty lexical value")
  }
  let mut i = 0
  let mut n : UInt64 = 0UL
  while i < value.length() {
    let ch = value[i:i + 1]
    if ch < "0" || ch > "9" {
      invalid_simple_type(type_name, value, "non-digit character")
    }
    let d = (ch[0].to_int() - "0"[0].to_int()).to_uint64()
    n = n * 10UL + d
    i = i + 1
  }
  n
}

///|
/// XSD simple type ST_LongHexNumber from wml.xsd (§17.18).
pub struct ST_LongHexNumber {
  bytes : FixedArray[Byte]
} derive(Eq, Debug)

///|
/// Part 1 §17.18.50 — decode the eight-hex-digit lexical form into the
/// four classification octets.
pub fn ST_LongHexNumber::parse(
  s : String,
) -> ST_LongHexNumber raise SchemaViolation {
  if !is_fixed_hex(s, 8) {
    invalid_simple_type(
      "ST_LongHexNumber", s, "expected exactly 8 hexadecimal digits",
    )
  }
  let bytes : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  for i in 0..<4 {
    bytes[i] = hex_pair_at(s, i * 2).to_byte()
  }
  { bytes, }
}

///|
pub fn ST_LongHexNumber::new(
  s : String,
) -> ST_LongHexNumber raise SchemaViolation {
  ST_LongHexNumber::parse(s)
}

///|
/// Render the four octets back to canonical uppercase hex.
pub fn ST_LongHexNumber::to_string(self : ST_LongHexNumber) -> String {
  let buf = StringBuilder::new()
  for i in 0..<4 {
    buf.write_string(hex_byte_string(self.bytes[i].to_int()))
  }
  buf.to_string()
}

///|
/// Access the i-th raw byte (0..3).
pub fn ST_LongHexNumber::byte_at(self : ST_LongHexNumber, index : Int) -> Int {
  self.bytes[index].to_int()
}

///|
/// XSD simple type ST_ShortHexNumber — Part 1 §17.18.79.
/// xsd:hexBinary restricted to length 4 (a two-octet hexadecimal number).
pub struct ST_ShortHexNumber {
  lexical : String
} derive(Eq, Debug)

///|
/// Parse the ST_ShortHexNumber lexical value (four hex digits).
pub fn ST_ShortHexNumber::parse(
  s : String,
) -> ST_ShortHexNumber raise SchemaViolation {
  if !is_fixed_hex(s, 4) {
    invalid_simple_type(
      "ST_ShortHexNumber", s, "expected exactly 4 hexadecimal digits",
    )
  }
  { lexical: s }
}

///|
/// Construct ST_ShortHexNumber while enforcing the wml.xsd 4-hex-digit length.
pub fn ST_ShortHexNumber::new(
  s : String,
) -> ST_ShortHexNumber raise SchemaViolation {
  ST_ShortHexNumber::parse(s)
}

///|
/// Return the canonical lexical value for ST_ShortHexNumber.
pub fn ST_ShortHexNumber::to_string(self : ST_ShortHexNumber) -> String {
  self.lexical
}

///|
/// XSD simple type ST_UcharHexNumber — Part 1 §17.18.98.
/// xsd:hexBinary restricted to length 2 (a one-octet hexadecimal number).
pub struct ST_UcharHexNumber {
  lexical : String
} derive(Eq, Debug)

///|
/// Parse the ST_UcharHexNumber lexical value (two hex digits).
pub fn ST_UcharHexNumber::parse(
  s : String,
) -> ST_UcharHexNumber raise SchemaViolation {
  if !is_fixed_hex(s, 2) {
    invalid_simple_type(
      "ST_UcharHexNumber", s, "expected exactly 2 hexadecimal digits",
    )
  }
  { lexical: s }
}

///|
/// Construct ST_UcharHexNumber while enforcing the wml.xsd 2-hex-digit length.
pub fn ST_UcharHexNumber::new(
  s : String,
) -> ST_UcharHexNumber raise SchemaViolation {
  ST_UcharHexNumber::parse(s)
}

///|
/// Return the canonical lexical value for ST_UcharHexNumber.
pub fn ST_UcharHexNumber::to_string(self : ST_UcharHexNumber) -> String {
  self.lexical
}

///|
/// XSD simple type ST_DecimalNumber — Part 1 §17.18.10.
/// Restriction of xsd:integer; stored as the typed signed integer.
pub struct ST_DecimalNumber {
  value : Int
} derive(Eq, Debug)

///|
/// Parse the ST_DecimalNumber schema lexical value into the typed
/// signed integer.
pub fn ST_DecimalNumber::parse(
  s : String,
) -> ST_DecimalNumber raise SchemaViolation {
  { value: parse_signed_int_lexical("ST_DecimalNumber", s) }
}

///|
/// Construct ST_DecimalNumber while enforcing the xsd:integer lexical
/// form.
pub fn ST_DecimalNumber::new(
  s : String,
) -> ST_DecimalNumber raise SchemaViolation {
  ST_DecimalNumber::parse(s)
}

///|
/// Read the typed signed integer.
pub fn ST_DecimalNumber::value(self : ST_DecimalNumber) -> Int {
  self.value
}

///|
/// Return the canonical lexical value (no leading zeros, optional `-`).
pub fn ST_DecimalNumber::to_string(self : ST_DecimalNumber) -> String {
  self.value.to_string()
}

///|
/// XSD simple type ST_DecimalNumberOrPercent — Part 1 §17.18.11.
/// xsd:union over { ST_DecimalNumber (§17.18.10), ST_Percentage
/// (§22.9.2.9) }. Part 4 §14.11.1 adds ST_UnqualifiedPercentage
/// (transitional). Stored as a typed discriminated union of the
/// permitted member types.
pub(all) enum ST_DecimalNumberOrPercent {
  DecimalNumberOrPercentDecimal(Int)
  /// ST_Percentage lexical body `-?[0-9]+(\.[0-9]+)?%` carried as the
  /// raw lexical form (round-trip preserves the producer's precision).
  DecimalNumberOrPercentPercentage(String)
} derive(Eq, Debug)

///|
/// Parse the ST_DecimalNumberOrPercent schema lexical value into the
/// typed union. A trailing `%` selects ST_Percentage; otherwise the
/// lexical form must satisfy ST_DecimalNumber's xsd:integer.
pub fn ST_DecimalNumberOrPercent::parse(
  s : String,
) -> ST_DecimalNumberOrPercent raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_DecimalNumberOrPercent", s, "empty lexical value")
  }
  if s[s.length() - 1:s.length()] == "%" {
    // Validate ST_Percentage pattern: `-?[0-9]+(\.[0-9]+)?%`.
    let body = s[0:s.length() - 1]
    let mut i = 0
    if body.length() > 0 && body[0:1] == "-" {
      i = 1
    }
    if i >= body.length() {
      invalid_simple_type(
        "ST_DecimalNumberOrPercent", s, "missing digits before %",
      )
    }
    let mut saw_digit = false
    let mut saw_dot = false
    while i < body.length() {
      let ch = body[i:i + 1]
      if ch >= "0" && ch <= "9" {
        saw_digit = true
      } else if ch == "." && !saw_dot && saw_digit {
        saw_dot = true
        saw_digit = false
      } else {
        invalid_simple_type(
          "ST_DecimalNumberOrPercent", s, "invalid percentage lexical",
        )
      }
      i = i + 1
    }
    if !saw_digit {
      invalid_simple_type(
        "ST_DecimalNumberOrPercent", s, "missing digits in fractional part",
      )
    }
    DecimalNumberOrPercentPercentage(s)
  } else {
    DecimalNumberOrPercentDecimal(
      parse_signed_int_lexical("ST_DecimalNumberOrPercent", s),
    )
  }
}

///|
/// Construct ST_DecimalNumberOrPercent while enforcing the union
/// membership constraints.
pub fn ST_DecimalNumberOrPercent::new(
  s : String,
) -> ST_DecimalNumberOrPercent raise SchemaViolation {
  ST_DecimalNumberOrPercent::parse(s)
}

///|
/// Return the canonical lexical value matching the chosen union arm.
pub fn ST_DecimalNumberOrPercent::to_string(
  self : ST_DecimalNumberOrPercent,
) -> String {
  match self {
    DecimalNumberOrPercentDecimal(n) => n.to_string()
    DecimalNumberOrPercentPercentage(text) => text
  }
}

///|
/// XSD simple type ST_SignedTwipsMeasure — Part 1 §17.18.81.
/// xsd:union over xsd:integer (twentieths of a point) and
/// ST_UniversalMeasure (signed decimal with mm/cm/in/pt/pc/pi unit).
pub(all) enum ST_SignedTwipsMeasure {
  SignedTwipsMeasureInteger(Int)
  SignedTwipsMeasureUniversal(String)
} derive(Eq, Debug)

///|
/// Parse the ST_SignedTwipsMeasure schema lexical value as either a signed
/// integer (twips) or a ST_UniversalMeasure literal.
pub fn ST_SignedTwipsMeasure::parse(
  s : String,
) -> ST_SignedTwipsMeasure raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_SignedTwipsMeasure", s, "empty lexical value")
  }
  if is_wml_universal_measure(s, positive=false) {
    SignedTwipsMeasureUniversal(s)
  } else {
    SignedTwipsMeasureInteger(
      parse_signed_int_lexical("ST_SignedTwipsMeasure", s),
    )
  }
}

///|
/// Construct ST_SignedTwipsMeasure while enforcing the wml.xsd union members.
pub fn ST_SignedTwipsMeasure::new(
  s : String,
) -> ST_SignedTwipsMeasure raise SchemaViolation {
  ST_SignedTwipsMeasure::parse(s)
}

///|
/// Return the canonical lexical value for ST_SignedTwipsMeasure.
pub fn ST_SignedTwipsMeasure::to_string(self : ST_SignedTwipsMeasure) -> String {
  match self {
    SignedTwipsMeasureInteger(n) => n.to_string()
    SignedTwipsMeasureUniversal(s) => s
  }
}

///|
/// XSD simple type ST_PixelsMeasure — Part 1 §17.18.67 measurement in
/// pixels. Restriction of `ST_UnsignedDecimalNumber` (xsd:unsignedLong);
/// stored as a typed `UInt64` so callers can read the pixel count
/// without re-parsing the lexical form.
pub struct ST_PixelsMeasure {
  pixels : UInt64
} derive(Eq, Debug)

///|
/// Part 1 §17.18.67 — decode the unsigned-long lexical form.
pub fn ST_PixelsMeasure::parse(
  s : String,
) -> ST_PixelsMeasure raise SchemaViolation {
  if !is_wml_unsigned_long(s) {
    invalid_simple_type(
      "ST_PixelsMeasure", s, "expected xsd:unsignedLong digits-only lexical form",
    )
  }
  { pixels: parse_wml_unsigned_long(s) }
}

///|
pub fn ST_PixelsMeasure::new(
  s : String,
) -> ST_PixelsMeasure raise SchemaViolation {
  ST_PixelsMeasure::parse(s)
}

///|
/// Render the pixel count back to its canonical decimal lexical form.
pub fn ST_PixelsMeasure::to_string(self : ST_PixelsMeasure) -> String {
  self.pixels.to_string()
}

///|
/// Numeric accessor.
pub fn ST_PixelsMeasure::to_uint64(self : ST_PixelsMeasure) -> UInt64 {
  self.pixels
}

///|
/// XSD simple type ST_HpsMeasure — Part 1 §17.18.42 measurement in
/// half-points. A union of `xsd:unsignedLong` (raw half-points) and
/// `ST_PositiveUniversalMeasure` (decimal magnitude + universal unit).
/// The typed discriminator preserves the union branch so callers don't
/// lose information.
pub enum ST_HpsMeasure {
  /// §17.18.42 unsigned-long branch: raw half-points.
  HpsHalfPoints(UInt64)
  /// §17.18.42 universal-measure branch: typed magnitude + unit.
  HpsMeasure(WmlPositiveUniversalMeasure)
} derive(Eq, Debug)

///|
/// Part 1 §17.18.42 — decode the union lexical form.
pub fn ST_HpsMeasure::parse(s : String) -> ST_HpsMeasure raise SchemaViolation {
  if is_wml_unsigned_long(s) {
    HpsHalfPoints(parse_wml_unsigned_long(s))
  } else if is_wml_universal_measure(s, positive=true) {
    HpsMeasure(WmlPositiveUniversalMeasure::parse(s))
  } else {
    invalid_simple_type(
      "ST_HpsMeasure", s, "expected xsd:unsignedLong or ST_PositiveUniversalMeasure",
    )
  }
}

///|
pub fn ST_HpsMeasure::new(s : String) -> ST_HpsMeasure raise SchemaViolation {
  ST_HpsMeasure::parse(s)
}

///|
/// Render the value back to its canonical lexical form.
pub fn ST_HpsMeasure::to_string(self : ST_HpsMeasure) -> String {
  match self {
    HpsHalfPoints(value) => value.to_string()
    HpsMeasure(measure) => measure.to_string()
  }
}

///|
/// XSD simple type ST_SignedHpsMeasure — Part 1 §17.18.80.
/// xsd:union over xsd:integer (half-points) and ST_UniversalMeasure
/// (signed decimal with mm/cm/in/pt/pc/pi unit).
pub(all) enum ST_SignedHpsMeasure {
  SignedHpsMeasureInteger(Int)
  SignedHpsMeasureUniversal(String)
} derive(Eq, Debug)

///|
/// Parse the ST_SignedHpsMeasure schema lexical value as either a signed
/// integer (half-points) or a ST_UniversalMeasure literal.
pub fn ST_SignedHpsMeasure::parse(
  s : String,
) -> ST_SignedHpsMeasure raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_SignedHpsMeasure", s, "empty lexical value")
  }
  if is_wml_universal_measure(s, positive=false) {
    SignedHpsMeasureUniversal(s)
  } else {
    SignedHpsMeasureInteger(parse_signed_int_lexical("ST_SignedHpsMeasure", s))
  }
}

///|
/// Construct ST_SignedHpsMeasure while enforcing the wml.xsd union members.
pub fn ST_SignedHpsMeasure::new(
  s : String,
) -> ST_SignedHpsMeasure raise SchemaViolation {
  ST_SignedHpsMeasure::parse(s)
}

///|
/// Return the canonical lexical value for ST_SignedHpsMeasure.
pub fn ST_SignedHpsMeasure::to_string(self : ST_SignedHpsMeasure) -> String {
  match self {
    SignedHpsMeasureInteger(n) => n.to_string()
    SignedHpsMeasureUniversal(s) => s
  }
}

///|
/// XSD simple type ST_DateTime — Part 1 §17.18.9.
/// Restriction of xsd:dateTime; stored as the schema lexical form so
/// callers can preserve sub-second precision and the time-zone offset
/// chosen by the producer.
pub struct ST_DateTime {
  lexical : String
} derive(Eq, Debug)

///|
/// Parse the ST_DateTime schema lexical value. The XML Schema
/// dateTime grammar requires a `YYYY-MM-DDThh:mm:ss(.s+)?` body with
/// an optional `Z` or `±hh:mm` timezone suffix.
pub fn ST_DateTime::parse(s : String) -> ST_DateTime raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_DateTime", s, "empty lexical value")
  }
  // Minimum xsd:dateTime is "YYYY-MM-DDThh:mm:ss" (19 chars).
  if s.length() < 19 {
    invalid_simple_type("ST_DateTime", s, "too short for xsd:dateTime")
  }
  fn digit(idx : Int) -> Bool {
    let ch = s[idx:idx + 1]
    ch >= "0" && ch <= "9"
  }

  if !(digit(0) && digit(1) && digit(2) && digit(3)) ||
    s[4:5] != "-" ||
    !(digit(5) && digit(6)) ||
    s[7:8] != "-" ||
    !(digit(8) && digit(9)) ||
    s[10:11] != "T" ||
    !(digit(11) && digit(12)) ||
    s[13:14] != ":" ||
    !(digit(14) && digit(15)) ||
    s[16:17] != ":" ||
    !(digit(17) && digit(18)) {
    invalid_simple_type("ST_DateTime", s, "not an xsd:dateTime lexical form")
  }
  // After the seconds, allow `.fraction`, then optional zone.
  let mut i = 19
  if i < s.length() && s[i:i + 1] == "." {
    i = i + 1
    let mut frac = 0
    while i < s.length() {
      let ch = s[i:i + 1]
      if ch >= "0" && ch <= "9" {
        frac = frac + 1
        i = i + 1
      } else {
        break
      }
    }
    if frac == 0 {
      invalid_simple_type("ST_DateTime", s, "fractional part has no digits")
    }
  }
  if i < s.length() {
    let zone = s[i:s.length()]
    if zone == "Z" {
      ()
    } else if zone.length() == 6 &&
      (zone[0:1] == "+" || zone[0:1] == "-") &&
      zone[3:4] == ":" {
      for k in [1, 2, 4, 5] {
        let ch = zone[k:k + 1]
        if ch < "0" || ch > "9" {
          invalid_simple_type("ST_DateTime", s, "bad time-zone offset")
        }
      }
    } else {
      invalid_simple_type("ST_DateTime", s, "trailing chars after seconds")
    }
  }
  { lexical: s }
}

///|
/// Construct ST_DateTime while enforcing the xsd:dateTime lexical
/// grammar.
pub fn ST_DateTime::new(s : String) -> ST_DateTime raise SchemaViolation {
  ST_DateTime::parse(s)
}

///|
/// Return the canonical schema lexical value (round-trip preserved).
pub fn ST_DateTime::to_string(self : ST_DateTime) -> String {
  self.lexical
}

///|
/// XSD simple type ST_MacroName — Part 1 §17.18.51 script subroutine
/// name carried as an xsd:string with `maxLength` 33 Unicode scalar
/// values. Stored as the lexical form; the constructor enforces the
/// length facet (and rejects the empty string per §17.18 validation).
pub struct ST_MacroName {
  lexical : String
} derive(Eq, Debug)

///|
/// Part 1 §17.18.51 — decode a macro name lexical value, enforcing the
/// `maxLength=33` facet.
pub fn ST_MacroName::parse(s : String) -> ST_MacroName raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_MacroName", s, "empty lexical value")
  }
  if s.length() > 33 {
    invalid_simple_type(
      "ST_MacroName", s, "exceeds 33-character maximum length",
    )
  }
  { lexical: s }
}

///|
pub fn ST_MacroName::new(s : String) -> ST_MacroName raise SchemaViolation {
  ST_MacroName::parse(s)
}

///|
pub fn ST_MacroName::to_string(self : ST_MacroName) -> String {
  self.lexical
}

///|
/// XSD simple type ST_EighthPointMeasure — Part 1 §17.18.23.
/// Restriction of ST_UnsignedDecimalNumber (Part 1 §22.9.2.16); the
/// magnitude is interpreted as eighths of a point (1/576 inch). Stored
/// as the typed UInt64 count of eighths-of-a-point.
pub struct ST_EighthPointMeasure {
  eighth_points : UInt64
} derive(Eq, Debug)

///|
/// Parse the ST_EighthPointMeasure schema lexical value into the
/// typed eighth-point count.
pub fn ST_EighthPointMeasure::parse(
  s : String,
) -> ST_EighthPointMeasure raise SchemaViolation {
  { eighth_points: parse_unsigned_int64_lexical("ST_EighthPointMeasure", s) }
}

///|
/// Construct ST_EighthPointMeasure while enforcing the
/// ST_UnsignedDecimalNumber lexical form.
pub fn ST_EighthPointMeasure::new(
  s : String,
) -> ST_EighthPointMeasure raise SchemaViolation {
  ST_EighthPointMeasure::parse(s)
}

///|
/// Read the typed magnitude in eighths of a point.
pub fn ST_EighthPointMeasure::eighth_points(
  self : ST_EighthPointMeasure,
) -> UInt64 {
  self.eighth_points
}

///|
/// Return the canonical lexical value (no leading zeros, no sign).
pub fn ST_EighthPointMeasure::to_string(self : ST_EighthPointMeasure) -> String {
  self.eighth_points.to_string()
}

///|
/// XSD simple type ST_PointMeasure — Part 1 §17.18.68 measurement in
/// points. Restriction of `ST_UnsignedDecimalNumber` (xsd:unsignedLong);
/// stored as a typed `UInt64` point count.
pub struct ST_PointMeasure {
  points : UInt64
} derive(Eq, Debug)

///|
/// Part 1 §17.18.68 — decode the unsigned-long lexical form.
pub fn ST_PointMeasure::parse(
  s : String,
) -> ST_PointMeasure raise SchemaViolation {
  if !is_wml_unsigned_long(s) {
    invalid_simple_type(
      "ST_PointMeasure", s, "expected xsd:unsignedLong digits-only lexical form",
    )
  }
  { points: parse_wml_unsigned_long(s) }
}

///|
pub fn ST_PointMeasure::new(
  s : String,
) -> ST_PointMeasure raise SchemaViolation {
  ST_PointMeasure::parse(s)
}

///|
/// Render the point count back to its canonical decimal lexical form.
pub fn ST_PointMeasure::to_string(self : ST_PointMeasure) -> String {
  self.points.to_string()
}

///|
/// Numeric accessor.
pub fn ST_PointMeasure::to_uint64(self : ST_PointMeasure) -> UInt64 {
  self.points
}

///|
/// XSD simple type ST_TextScale — Part 1 §17.18.95.
/// xsd:union over ST_TextScalePercent (Part 1 §17.18.106) and the
/// Part 4 §14.11.11 ST_TextScaleDecimal additional member type.
pub(all) enum ST_TextScale {
  TextScalePercent(ST_TextScalePercent)
  TextScaleDecimal(ST_TextScaleDecimal)
} derive(Eq, Debug)

///|
/// Parse the ST_TextScale lexical value: a percent-suffixed literal is
/// interpreted as ST_TextScalePercent; an unsuffixed integer as the
/// Part 4 ST_TextScaleDecimal extension.
pub fn ST_TextScale::parse(s : String) -> ST_TextScale raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_TextScale", s, "empty lexical value")
  }
  if s[s.length() - 1:s.length()] == "%" {
    TextScalePercent(ST_TextScalePercent::parse(s))
  } else {
    TextScaleDecimal(ST_TextScaleDecimal::parse(s))
  }
}

///|
/// Construct ST_TextScale while enforcing the wml.xsd union members.
pub fn ST_TextScale::new(s : String) -> ST_TextScale raise SchemaViolation {
  ST_TextScale::parse(s)
}

///|
/// Return the canonical lexical value for ST_TextScale.
pub fn ST_TextScale::to_string(self : ST_TextScale) -> String {
  match self {
    TextScalePercent(p) => p.to_string()
    TextScaleDecimal(d) => d.to_string()
  }
}

///|
/// XSD simple type ST_TextScalePercent — Part 1 §17.18.106.
/// xsd:string restricted by the pattern `0*(600|([0-5]?[0-9]?[0-9]))%`
/// — a percent integer between 0 and 600, no sign, followed by `%`.
pub struct ST_TextScalePercent {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_TextScalePercent lexical pattern into the typed percent
/// integer (0..600).
pub fn ST_TextScalePercent::parse(
  s : String,
) -> ST_TextScalePercent raise SchemaViolation {
  let len = s.length()
  if len < 2 || s[len - 1:len] != "%" {
    invalid_simple_type(
      "ST_TextScalePercent", s, "expected percent-suffixed literal",
    )
  }
  let body = s[0:len - 1]
  let body_len = body.length()
  let mut i = 0
  let mut n = 0
  while i < body_len {
    let ch = body[i:i + 1]
    if ch < "0" || ch > "9" {
      invalid_simple_type(
        "ST_TextScalePercent", s, "non-digit in percentage body",
      )
    }
    let d = ch[0].to_int() - "0"[0].to_int()
    n = n * 10 + d
    i = i + 1
  }
  if n < 0 || n > 600 {
    invalid_simple_type(
      "ST_TextScalePercent", s, "percent outside 0..600 range",
    )
  }
  { percent: n }
}

///|
/// Construct ST_TextScalePercent while enforcing the wml.xsd pattern.
pub fn ST_TextScalePercent::new(
  s : String,
) -> ST_TextScalePercent raise SchemaViolation {
  ST_TextScalePercent::parse(s)
}

///|
/// Read the typed percentage integer (0..600).
pub fn ST_TextScalePercent::value(self : ST_TextScalePercent) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value (no leading zeros, with `%`).
pub fn ST_TextScalePercent::to_string(self : ST_TextScalePercent) -> String {
  self.percent.to_string() + "%"
}

///|
/// XSD simple type ST_HighlightColor — Part 1 §17.18.40 text highlight
/// colour enumeration. Seventeen named colours (the §17.18.40 table)
/// plus `none`.
pub(all) enum ST_HighlightColor {
  /// §17.18.40 "black"
  HlBlack
  /// §17.18.40 "blue"
  HlBlue
  /// §17.18.40 "cyan"
  HlCyan
  /// §17.18.40 "green"
  HlGreen
  /// §17.18.40 "magenta"
  HlMagenta
  /// §17.18.40 "red"
  HlRed
  /// §17.18.40 "yellow"
  HlYellow
  /// §17.18.40 "white"
  HlWhite
  /// §17.18.40 "darkBlue"
  HlDarkBlue
  /// §17.18.40 "darkCyan"
  HlDarkCyan
  /// §17.18.40 "darkGreen"
  HlDarkGreen
  /// §17.18.40 "darkMagenta"
  HlDarkMagenta
  /// §17.18.40 "darkRed"
  HlDarkRed
  /// §17.18.40 "darkYellow"
  HlDarkYellow
  /// §17.18.40 "darkGray"
  HlDarkGray
  /// §17.18.40 "lightGray"
  HlLightGray
  /// §17.18.40 "none"
  HlNone
} derive(Eq, Debug)

///|
/// Part 1 §17.18.40 — decode the highlight-colour lexical token.
pub fn ST_HighlightColor::parse(
  s : String,
) -> ST_HighlightColor raise SchemaViolation {
  match s {
    "black" => HlBlack
    "blue" => HlBlue
    "cyan" => HlCyan
    "green" => HlGreen
    "magenta" => HlMagenta
    "red" => HlRed
    "yellow" => HlYellow
    "white" => HlWhite
    "darkBlue" => HlDarkBlue
    "darkCyan" => HlDarkCyan
    "darkGreen" => HlDarkGreen
    "darkMagenta" => HlDarkMagenta
    "darkRed" => HlDarkRed
    "darkYellow" => HlDarkYellow
    "darkGray" => HlDarkGray
    "lightGray" => HlLightGray
    "none" => HlNone
    _ =>
      invalid_simple_type("ST_HighlightColor", s, "unknown enumeration value")
  }
}

///|
pub fn ST_HighlightColor::new(
  s : String,
) -> ST_HighlightColor raise SchemaViolation {
  ST_HighlightColor::parse(s)
}

///|
/// Render the highlight-colour enumeration back to its lexical token.
pub fn ST_HighlightColor::to_string(self : ST_HighlightColor) -> String {
  match self {
    HlBlack => "black"
    HlBlue => "blue"
    HlCyan => "cyan"
    HlGreen => "green"
    HlMagenta => "magenta"
    HlRed => "red"
    HlYellow => "yellow"
    HlWhite => "white"
    HlDarkBlue => "darkBlue"
    HlDarkCyan => "darkCyan"
    HlDarkGreen => "darkGreen"
    HlDarkMagenta => "darkMagenta"
    HlDarkRed => "darkRed"
    HlDarkYellow => "darkYellow"
    HlDarkGray => "darkGray"
    HlLightGray => "lightGray"
    HlNone => "none"
  }
}

///|
/// XSD simple type ST_HexColorAuto — Part 1 §17.18.39 single-token
/// enumeration `auto`. Modelled as a one-variant enum so its type
/// discriminator participates in `ST_HexColor`'s union.
pub(all) enum ST_HexColorAuto {
  /// §17.18.39 "auto"
  HexColorAutoAuto
} derive(Eq, Debug)

///|
/// Part 1 §17.18.39 — decode the lone `auto` lexical token.
pub fn ST_HexColorAuto::parse(
  s : String,
) -> ST_HexColorAuto raise SchemaViolation {
  match s {
    "auto" => HexColorAutoAuto
    _ =>
      invalid_simple_type(
        "ST_HexColorAuto", s, "expected the lexical token \"auto\"",
      )
  }
}

///|
pub fn ST_HexColorAuto::new(
  s : String,
) -> ST_HexColorAuto raise SchemaViolation {
  ST_HexColorAuto::parse(s)
}

///|
/// Render back to the lexical token.
pub fn ST_HexColorAuto::to_string(self : ST_HexColorAuto) -> String {
  match self {
    HexColorAutoAuto => "auto"
  }
}

///|
/// Part 1 §17.18.38 ST_HexColor — colour value union of the `auto`
/// keyword (ST_HexColorAuto) and a six-hex-digit RGB literal
/// (ST_HexColorRGB, Part 1 §22.9.2.5). Stored as a typed discriminated
/// enum so callers never have to re-parse a lexical string to learn
/// which branch is in play.
pub enum ST_HexColor {
  /// §17.18.38 `auto` branch.
  HexColorAuto
  /// §17.18.38 RGB branch — three 0..255 channels (R, G, B).
  HexColorRgb(Int, Int, Int)
} derive(Eq, Debug)

///|
/// Part 1 §17.18.38 — decode the colour lexical value.
pub fn ST_HexColor::parse(s : String) -> ST_HexColor raise SchemaViolation {
  if s == "auto" {
    HexColorAuto
  } else if is_fixed_hex(s, 6) {
    HexColorRgb(hex_pair_at(s, 0), hex_pair_at(s, 2), hex_pair_at(s, 4))
  } else {
    invalid_simple_type(
      "ST_HexColor", s, "expected \"auto\" or six hexadecimal digits",
    )
  }
}

///|
pub fn ST_HexColor::new(s : String) -> ST_HexColor raise SchemaViolation {
  ST_HexColor::parse(s)
}

///|
/// Render the colour back to its canonical lexical form (lowercase
/// `auto` or six uppercase hex digits).
pub fn ST_HexColor::to_string(self : ST_HexColor) -> String {
  match self {
    HexColorAuto => "auto"
    HexColorRgb(r, g, b) =>
      hex_byte_string(r) + hex_byte_string(g) + hex_byte_string(b)
  }
}

///|
/// XSD simple type ST_Underline — Part 1 §17.18.99.
/// Restriction of xsd:string to the 18-value underline pattern enumeration.
pub(all) enum ST_Underline {
  UnderlineDash
  UnderlineDashDotDotHeavy
  UnderlineDashDotHeavy
  UnderlineDashedHeavy
  UnderlineDashLong
  UnderlineDashLongHeavy
  UnderlineDotDash
  UnderlineDotDotDash
  UnderlineDotted
  UnderlineDottedHeavy
  UnderlineDouble
  UnderlineNone
  UnderlineSingle
  UnderlineThick
  UnderlineWave
  UnderlineWavyDouble
  UnderlineWavyHeavy
  UnderlineWords
} derive(Eq, Debug)

///|
/// Parse the ST_Underline schema lexical value.
pub fn ST_Underline::parse(s : String) -> ST_Underline raise SchemaViolation {
  match s {
    "dash" => UnderlineDash
    "dashDotDotHeavy" => UnderlineDashDotDotHeavy
    "dashDotHeavy" => UnderlineDashDotHeavy
    "dashedHeavy" => UnderlineDashedHeavy
    "dashLong" => UnderlineDashLong
    "dashLongHeavy" => UnderlineDashLongHeavy
    "dotDash" => UnderlineDotDash
    "dotDotDash" => UnderlineDotDotDash
    "dotted" => UnderlineDotted
    "dottedHeavy" => UnderlineDottedHeavy
    "double" => UnderlineDouble
    "none" => UnderlineNone
    "single" => UnderlineSingle
    "thick" => UnderlineThick
    "wave" => UnderlineWave
    "wavyDouble" => UnderlineWavyDouble
    "wavyHeavy" => UnderlineWavyHeavy
    "words" => UnderlineWords
    _ => invalid_simple_type("ST_Underline", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_Underline while enforcing the wml.xsd enumeration.
pub fn ST_Underline::new(s : String) -> ST_Underline raise SchemaViolation {
  ST_Underline::parse(s)
}

///|
/// Return the schema lexical value for ST_Underline.
pub fn ST_Underline::to_string(self : ST_Underline) -> String {
  match self {
    UnderlineDash => "dash"
    UnderlineDashDotDotHeavy => "dashDotDotHeavy"
    UnderlineDashDotHeavy => "dashDotHeavy"
    UnderlineDashedHeavy => "dashedHeavy"
    UnderlineDashLong => "dashLong"
    UnderlineDashLongHeavy => "dashLongHeavy"
    UnderlineDotDash => "dotDash"
    UnderlineDotDotDash => "dotDotDash"
    UnderlineDotted => "dotted"
    UnderlineDottedHeavy => "dottedHeavy"
    UnderlineDouble => "double"
    UnderlineNone => "none"
    UnderlineSingle => "single"
    UnderlineThick => "thick"
    UnderlineWave => "wave"
    UnderlineWavyDouble => "wavyDouble"
    UnderlineWavyHeavy => "wavyHeavy"
    UnderlineWords => "words"
  }
}

///|
/// XSD simple type ST_TextEffect — Part 1 §17.18.94.
/// Restriction of xsd:string to the 7-value animated text effect enumeration.
pub(all) enum ST_TextEffect {
  TextEffectAntsBlack
  TextEffectAntsRed
  TextEffectBlinkBackground
  TextEffectLights
  TextEffectNone
  TextEffectShimmer
  TextEffectSparkle
} derive(Eq, Debug)

///|
/// Parse the ST_TextEffect schema lexical value.
pub fn ST_TextEffect::parse(s : String) -> ST_TextEffect raise SchemaViolation {
  match s {
    "antsBlack" => TextEffectAntsBlack
    "antsRed" => TextEffectAntsRed
    "blinkBackground" => TextEffectBlinkBackground
    "lights" => TextEffectLights
    "none" => TextEffectNone
    "shimmer" => TextEffectShimmer
    "sparkle" => TextEffectSparkle
    _ => invalid_simple_type("ST_TextEffect", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_TextEffect while enforcing the wml.xsd enumeration.
pub fn ST_TextEffect::new(s : String) -> ST_TextEffect raise SchemaViolation {
  ST_TextEffect::parse(s)
}

///|
/// Return the schema lexical value for ST_TextEffect.
pub fn ST_TextEffect::to_string(self : ST_TextEffect) -> String {
  match self {
    TextEffectAntsBlack => "antsBlack"
    TextEffectAntsRed => "antsRed"
    TextEffectBlinkBackground => "blinkBackground"
    TextEffectLights => "lights"
    TextEffectNone => "none"
    TextEffectShimmer => "shimmer"
    TextEffectSparkle => "sparkle"
  }
}

///|
/// XSD simple type ST_Border — Part 1 §17.18.2.
/// Restriction of xsd:string covering both the line border styles
/// (`nil`..`inset`) and the page-level art border catalogue
/// (`apples`..`zigZagStitch`), plus the producer-defined `custom`
/// sentinel. Variant names use the `Border` prefix to avoid clashing
/// with similarly-named enumerations elsewhere in this package.
pub(all) enum ST_Border {
  BorderNil
  BorderNone
  BorderSingle
  BorderThick
  BorderDouble
  BorderDotted
  BorderDashed
  BorderDotDash
  BorderDotDotDash
  BorderTriple
  BorderThinThickSmallGap
  BorderThickThinSmallGap
  BorderThinThickThinSmallGap
  BorderThinThickMediumGap
  BorderThickThinMediumGap
  BorderThinThickThinMediumGap
  BorderThinThickLargeGap
  BorderThickThinLargeGap
  BorderThinThickThinLargeGap
  BorderWave
  BorderDoubleWave
  BorderDashSmallGap
  BorderDashDotStroked
  BorderThreeDEmboss
  BorderThreeDEngrave
  BorderOutset
  BorderInset
  BorderApples
  BorderArchedScallops
  BorderBabyPacifier
  BorderBabyRattle
  BorderBalloons3Colors
  BorderBalloonsHotAir
  BorderBasicBlackDashes
  BorderBasicBlackDots
  BorderBasicBlackSquares
  BorderBasicThinLines
  BorderBasicWhiteDashes
  BorderBasicWhiteDots
  BorderBasicWhiteSquares
  BorderBasicWideInline
  BorderBasicWideMidline
  BorderBasicWideOutline
  BorderBats
  BorderBirds
  BorderBirdsFlight
  BorderCabins
  BorderCakeSlice
  BorderCandyCorn
  BorderCelticKnotwork
  BorderCertificateBanner
  BorderChainLink
  BorderChampagneBottle
  BorderCheckedBarBlack
  BorderCheckedBarColor
  BorderCheckered
  BorderChristmasTree
  BorderCirclesLines
  BorderCirclesRectangles
  BorderClassicalWave
  BorderClocks
  BorderCompass
  BorderConfetti
  BorderConfettiGrays
  BorderConfettiOutline
  BorderConfettiStreamers
  BorderConfettiWhite
  BorderCornerTriangles
  BorderCouponCutoutDashes
  BorderCouponCutoutDots
  BorderCrazyMaze
  BorderCreaturesButterfly
  BorderCreaturesFish
  BorderCreaturesInsects
  BorderCreaturesLadyBug
  BorderCrossStitch
  BorderCup
  BorderDecoArch
  BorderDecoArchColor
  BorderDecoBlocks
  BorderDiamondsGray
  BorderDoubleD
  BorderDoubleDiamonds
  BorderEarth1
  BorderEarth2
  BorderEarth3
  BorderEclipsingSquares1
  BorderEclipsingSquares2
  BorderEggsBlack
  BorderFans
  BorderFilm
  BorderFirecrackers
  BorderFlowersBlockPrint
  BorderFlowersDaisies
  BorderFlowersModern1
  BorderFlowersModern2
  BorderFlowersPansy
  BorderFlowersRedRose
  BorderFlowersRoses
  BorderFlowersTeacup
  BorderFlowersTiny
  BorderGems
  BorderGingerbreadMan
  BorderGradient
  BorderHandmade1
  BorderHandmade2
  BorderHeartBalloon
  BorderHeartGray
  BorderHearts
  BorderHeebieJeebies
  BorderHolly
  BorderHouseFunky
  BorderHypnotic
  BorderIceCreamCones
  BorderLightBulb
  BorderLightning1
  BorderLightning2
  BorderMapPins
  BorderMapleLeaf
  BorderMapleMuffins
  BorderMarquee
  BorderMarqueeToothed
  BorderMoons
  BorderMosaic
  BorderMusicNotes
  BorderNorthwest
  BorderOvals
  BorderPackages
  BorderPalmsBlack
  BorderPalmsColor
  BorderPaperClips
  BorderPapyrus
  BorderPartyFavor
  BorderPartyGlass
  BorderPencils
  BorderPeople
  BorderPeopleWaving
  BorderPeopleHats
  BorderPoinsettias
  BorderPostageStamp
  BorderPumpkin1
  BorderPushPinNote2
  BorderPushPinNote1
  BorderPyramids
  BorderPyramidsAbove
  BorderQuadrants
  BorderRings
  BorderSafari
  BorderSawtooth
  BorderSawtoothGray
  BorderScaredCat
  BorderSeattle
  BorderShadowedSquares
  BorderSharksTeeth
  BorderShorebirdTracks
  BorderSkyrocket
  BorderSnowflakeFancy
  BorderSnowflakes
  BorderSombrero
  BorderSouthwest
  BorderStars
  BorderStarsTop
  BorderStars3d
  BorderStarsBlack
  BorderStarsShadowed
  BorderSun
  BorderSwirligig
  BorderTornPaper
  BorderTornPaperBlack
  BorderTrees
  BorderTriangleParty
  BorderTriangles
  BorderTriangle1
  BorderTriangle2
  BorderTriangleCircle1
  BorderTriangleCircle2
  BorderShapes1
  BorderShapes2
  BorderTwistedLines1
  BorderTwistedLines2
  BorderVine
  BorderWaveline
  BorderWeavingAngles
  BorderWeavingBraid
  BorderWeavingRibbon
  BorderWeavingStrips
  BorderWhiteFlowers
  BorderWoodwork
  BorderXIllusions
  BorderZanyTriangles
  BorderZigZag
  BorderZigZagStitch
  BorderCustom
} derive(Eq, Debug)

///|
/// Parse the ST_Border schema lexical value.
pub fn ST_Border::parse(s : String) -> ST_Border raise SchemaViolation {
  match s {
    "nil" => BorderNil
    "none" => BorderNone
    "single" => BorderSingle
    "thick" => BorderThick
    "double" => BorderDouble
    "dotted" => BorderDotted
    "dashed" => BorderDashed
    "dotDash" => BorderDotDash
    "dotDotDash" => BorderDotDotDash
    "triple" => BorderTriple
    "thinThickSmallGap" => BorderThinThickSmallGap
    "thickThinSmallGap" => BorderThickThinSmallGap
    "thinThickThinSmallGap" => BorderThinThickThinSmallGap
    "thinThickMediumGap" => BorderThinThickMediumGap
    "thickThinMediumGap" => BorderThickThinMediumGap
    "thinThickThinMediumGap" => BorderThinThickThinMediumGap
    "thinThickLargeGap" => BorderThinThickLargeGap
    "thickThinLargeGap" => BorderThickThinLargeGap
    "thinThickThinLargeGap" => BorderThinThickThinLargeGap
    "wave" => BorderWave
    "doubleWave" => BorderDoubleWave
    "dashSmallGap" => BorderDashSmallGap
    "dashDotStroked" => BorderDashDotStroked
    "threeDEmboss" => BorderThreeDEmboss
    "threeDEngrave" => BorderThreeDEngrave
    "outset" => BorderOutset
    "inset" => BorderInset
    "apples" => BorderApples
    "archedScallops" => BorderArchedScallops
    "babyPacifier" => BorderBabyPacifier
    "babyRattle" => BorderBabyRattle
    "balloons3Colors" => BorderBalloons3Colors
    "balloonsHotAir" => BorderBalloonsHotAir
    "basicBlackDashes" => BorderBasicBlackDashes
    "basicBlackDots" => BorderBasicBlackDots
    "basicBlackSquares" => BorderBasicBlackSquares
    "basicThinLines" => BorderBasicThinLines
    "basicWhiteDashes" => BorderBasicWhiteDashes
    "basicWhiteDots" => BorderBasicWhiteDots
    "basicWhiteSquares" => BorderBasicWhiteSquares
    "basicWideInline" => BorderBasicWideInline
    "basicWideMidline" => BorderBasicWideMidline
    "basicWideOutline" => BorderBasicWideOutline
    "bats" => BorderBats
    "birds" => BorderBirds
    "birdsFlight" => BorderBirdsFlight
    "cabins" => BorderCabins
    "cakeSlice" => BorderCakeSlice
    "candyCorn" => BorderCandyCorn
    "celticKnotwork" => BorderCelticKnotwork
    "certificateBanner" => BorderCertificateBanner
    "chainLink" => BorderChainLink
    "champagneBottle" => BorderChampagneBottle
    "checkedBarBlack" => BorderCheckedBarBlack
    "checkedBarColor" => BorderCheckedBarColor
    "checkered" => BorderCheckered
    "christmasTree" => BorderChristmasTree
    "circlesLines" => BorderCirclesLines
    "circlesRectangles" => BorderCirclesRectangles
    "classicalWave" => BorderClassicalWave
    "clocks" => BorderClocks
    "compass" => BorderCompass
    "confetti" => BorderConfetti
    "confettiGrays" => BorderConfettiGrays
    "confettiOutline" => BorderConfettiOutline
    "confettiStreamers" => BorderConfettiStreamers
    "confettiWhite" => BorderConfettiWhite
    "cornerTriangles" => BorderCornerTriangles
    "couponCutoutDashes" => BorderCouponCutoutDashes
    "couponCutoutDots" => BorderCouponCutoutDots
    "crazyMaze" => BorderCrazyMaze
    "creaturesButterfly" => BorderCreaturesButterfly
    "creaturesFish" => BorderCreaturesFish
    "creaturesInsects" => BorderCreaturesInsects
    "creaturesLadyBug" => BorderCreaturesLadyBug
    "crossStitch" => BorderCrossStitch
    "cup" => BorderCup
    "decoArch" => BorderDecoArch
    "decoArchColor" => BorderDecoArchColor
    "decoBlocks" => BorderDecoBlocks
    "diamondsGray" => BorderDiamondsGray
    "doubleD" => BorderDoubleD
    "doubleDiamonds" => BorderDoubleDiamonds
    "earth1" => BorderEarth1
    "earth2" => BorderEarth2
    "earth3" => BorderEarth3
    "eclipsingSquares1" => BorderEclipsingSquares1
    "eclipsingSquares2" => BorderEclipsingSquares2
    "eggsBlack" => BorderEggsBlack
    "fans" => BorderFans
    "film" => BorderFilm
    "firecrackers" => BorderFirecrackers
    "flowersBlockPrint" => BorderFlowersBlockPrint
    "flowersDaisies" => BorderFlowersDaisies
    "flowersModern1" => BorderFlowersModern1
    "flowersModern2" => BorderFlowersModern2
    "flowersPansy" => BorderFlowersPansy
    "flowersRedRose" => BorderFlowersRedRose
    "flowersRoses" => BorderFlowersRoses
    "flowersTeacup" => BorderFlowersTeacup
    "flowersTiny" => BorderFlowersTiny
    "gems" => BorderGems
    "gingerbreadMan" => BorderGingerbreadMan
    "gradient" => BorderGradient
    "handmade1" => BorderHandmade1
    "handmade2" => BorderHandmade2
    "heartBalloon" => BorderHeartBalloon
    "heartGray" => BorderHeartGray
    "hearts" => BorderHearts
    "heebieJeebies" => BorderHeebieJeebies
    "holly" => BorderHolly
    "houseFunky" => BorderHouseFunky
    "hypnotic" => BorderHypnotic
    "iceCreamCones" => BorderIceCreamCones
    "lightBulb" => BorderLightBulb
    "lightning1" => BorderLightning1
    "lightning2" => BorderLightning2
    "mapPins" => BorderMapPins
    "mapleLeaf" => BorderMapleLeaf
    "mapleMuffins" => BorderMapleMuffins
    "marquee" => BorderMarquee
    "marqueeToothed" => BorderMarqueeToothed
    "moons" => BorderMoons
    "mosaic" => BorderMosaic
    "musicNotes" => BorderMusicNotes
    "northwest" => BorderNorthwest
    "ovals" => BorderOvals
    "packages" => BorderPackages
    "palmsBlack" => BorderPalmsBlack
    "palmsColor" => BorderPalmsColor
    "paperClips" => BorderPaperClips
    "papyrus" => BorderPapyrus
    "partyFavor" => BorderPartyFavor
    "partyGlass" => BorderPartyGlass
    "pencils" => BorderPencils
    "people" => BorderPeople
    "peopleWaving" => BorderPeopleWaving
    "peopleHats" => BorderPeopleHats
    "poinsettias" => BorderPoinsettias
    "postageStamp" => BorderPostageStamp
    "pumpkin1" => BorderPumpkin1
    "pushPinNote2" => BorderPushPinNote2
    "pushPinNote1" => BorderPushPinNote1
    "pyramids" => BorderPyramids
    "pyramidsAbove" => BorderPyramidsAbove
    "quadrants" => BorderQuadrants
    "rings" => BorderRings
    "safari" => BorderSafari
    "sawtooth" => BorderSawtooth
    "sawtoothGray" => BorderSawtoothGray
    "scaredCat" => BorderScaredCat
    "seattle" => BorderSeattle
    "shadowedSquares" => BorderShadowedSquares
    "sharksTeeth" => BorderSharksTeeth
    "shorebirdTracks" => BorderShorebirdTracks
    "skyrocket" => BorderSkyrocket
    "snowflakeFancy" => BorderSnowflakeFancy
    "snowflakes" => BorderSnowflakes
    "sombrero" => BorderSombrero
    "southwest" => BorderSouthwest
    "stars" => BorderStars
    "starsTop" => BorderStarsTop
    "stars3d" => BorderStars3d
    "starsBlack" => BorderStarsBlack
    "starsShadowed" => BorderStarsShadowed
    "sun" => BorderSun
    "swirligig" => BorderSwirligig
    "tornPaper" => BorderTornPaper
    "tornPaperBlack" => BorderTornPaperBlack
    "trees" => BorderTrees
    "triangleParty" => BorderTriangleParty
    "triangles" => BorderTriangles
    "triangle1" => BorderTriangle1
    "triangle2" => BorderTriangle2
    "triangleCircle1" => BorderTriangleCircle1
    "triangleCircle2" => BorderTriangleCircle2
    "shapes1" => BorderShapes1
    "shapes2" => BorderShapes2
    "twistedLines1" => BorderTwistedLines1
    "twistedLines2" => BorderTwistedLines2
    "vine" => BorderVine
    "waveline" => BorderWaveline
    "weavingAngles" => BorderWeavingAngles
    "weavingBraid" => BorderWeavingBraid
    "weavingRibbon" => BorderWeavingRibbon
    "weavingStrips" => BorderWeavingStrips
    "whiteFlowers" => BorderWhiteFlowers
    "woodwork" => BorderWoodwork
    "xIllusions" => BorderXIllusions
    "zanyTriangles" => BorderZanyTriangles
    "zigZag" => BorderZigZag
    "zigZagStitch" => BorderZigZagStitch
    "custom" => BorderCustom
    _ => invalid_simple_type("ST_Border", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_Border while enforcing the wml.xsd enumeration.
pub fn ST_Border::new(s : String) -> ST_Border raise SchemaViolation {
  ST_Border::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_Border.
pub fn ST_Border::to_string(self : ST_Border) -> String {
  match self {
    BorderNil => "nil"
    BorderNone => "none"
    BorderSingle => "single"
    BorderThick => "thick"
    BorderDouble => "double"
    BorderDotted => "dotted"
    BorderDashed => "dashed"
    BorderDotDash => "dotDash"
    BorderDotDotDash => "dotDotDash"
    BorderTriple => "triple"
    BorderThinThickSmallGap => "thinThickSmallGap"
    BorderThickThinSmallGap => "thickThinSmallGap"
    BorderThinThickThinSmallGap => "thinThickThinSmallGap"
    BorderThinThickMediumGap => "thinThickMediumGap"
    BorderThickThinMediumGap => "thickThinMediumGap"
    BorderThinThickThinMediumGap => "thinThickThinMediumGap"
    BorderThinThickLargeGap => "thinThickLargeGap"
    BorderThickThinLargeGap => "thickThinLargeGap"
    BorderThinThickThinLargeGap => "thinThickThinLargeGap"
    BorderWave => "wave"
    BorderDoubleWave => "doubleWave"
    BorderDashSmallGap => "dashSmallGap"
    BorderDashDotStroked => "dashDotStroked"
    BorderThreeDEmboss => "threeDEmboss"
    BorderThreeDEngrave => "threeDEngrave"
    BorderOutset => "outset"
    BorderInset => "inset"
    BorderApples => "apples"
    BorderArchedScallops => "archedScallops"
    BorderBabyPacifier => "babyPacifier"
    BorderBabyRattle => "babyRattle"
    BorderBalloons3Colors => "balloons3Colors"
    BorderBalloonsHotAir => "balloonsHotAir"
    BorderBasicBlackDashes => "basicBlackDashes"
    BorderBasicBlackDots => "basicBlackDots"
    BorderBasicBlackSquares => "basicBlackSquares"
    BorderBasicThinLines => "basicThinLines"
    BorderBasicWhiteDashes => "basicWhiteDashes"
    BorderBasicWhiteDots => "basicWhiteDots"
    BorderBasicWhiteSquares => "basicWhiteSquares"
    BorderBasicWideInline => "basicWideInline"
    BorderBasicWideMidline => "basicWideMidline"
    BorderBasicWideOutline => "basicWideOutline"
    BorderBats => "bats"
    BorderBirds => "birds"
    BorderBirdsFlight => "birdsFlight"
    BorderCabins => "cabins"
    BorderCakeSlice => "cakeSlice"
    BorderCandyCorn => "candyCorn"
    BorderCelticKnotwork => "celticKnotwork"
    BorderCertificateBanner => "certificateBanner"
    BorderChainLink => "chainLink"
    BorderChampagneBottle => "champagneBottle"
    BorderCheckedBarBlack => "checkedBarBlack"
    BorderCheckedBarColor => "checkedBarColor"
    BorderCheckered => "checkered"
    BorderChristmasTree => "christmasTree"
    BorderCirclesLines => "circlesLines"
    BorderCirclesRectangles => "circlesRectangles"
    BorderClassicalWave => "classicalWave"
    BorderClocks => "clocks"
    BorderCompass => "compass"
    BorderConfetti => "confetti"
    BorderConfettiGrays => "confettiGrays"
    BorderConfettiOutline => "confettiOutline"
    BorderConfettiStreamers => "confettiStreamers"
    BorderConfettiWhite => "confettiWhite"
    BorderCornerTriangles => "cornerTriangles"
    BorderCouponCutoutDashes => "couponCutoutDashes"
    BorderCouponCutoutDots => "couponCutoutDots"
    BorderCrazyMaze => "crazyMaze"
    BorderCreaturesButterfly => "creaturesButterfly"
    BorderCreaturesFish => "creaturesFish"
    BorderCreaturesInsects => "creaturesInsects"
    BorderCreaturesLadyBug => "creaturesLadyBug"
    BorderCrossStitch => "crossStitch"
    BorderCup => "cup"
    BorderDecoArch => "decoArch"
    BorderDecoArchColor => "decoArchColor"
    BorderDecoBlocks => "decoBlocks"
    BorderDiamondsGray => "diamondsGray"
    BorderDoubleD => "doubleD"
    BorderDoubleDiamonds => "doubleDiamonds"
    BorderEarth1 => "earth1"
    BorderEarth2 => "earth2"
    BorderEarth3 => "earth3"
    BorderEclipsingSquares1 => "eclipsingSquares1"
    BorderEclipsingSquares2 => "eclipsingSquares2"
    BorderEggsBlack => "eggsBlack"
    BorderFans => "fans"
    BorderFilm => "film"
    BorderFirecrackers => "firecrackers"
    BorderFlowersBlockPrint => "flowersBlockPrint"
    BorderFlowersDaisies => "flowersDaisies"
    BorderFlowersModern1 => "flowersModern1"
    BorderFlowersModern2 => "flowersModern2"
    BorderFlowersPansy => "flowersPansy"
    BorderFlowersRedRose => "flowersRedRose"
    BorderFlowersRoses => "flowersRoses"
    BorderFlowersTeacup => "flowersTeacup"
    BorderFlowersTiny => "flowersTiny"
    BorderGems => "gems"
    BorderGingerbreadMan => "gingerbreadMan"
    BorderGradient => "gradient"
    BorderHandmade1 => "handmade1"
    BorderHandmade2 => "handmade2"
    BorderHeartBalloon => "heartBalloon"
    BorderHeartGray => "heartGray"
    BorderHearts => "hearts"
    BorderHeebieJeebies => "heebieJeebies"
    BorderHolly => "holly"
    BorderHouseFunky => "houseFunky"
    BorderHypnotic => "hypnotic"
    BorderIceCreamCones => "iceCreamCones"
    BorderLightBulb => "lightBulb"
    BorderLightning1 => "lightning1"
    BorderLightning2 => "lightning2"
    BorderMapPins => "mapPins"
    BorderMapleLeaf => "mapleLeaf"
    BorderMapleMuffins => "mapleMuffins"
    BorderMarquee => "marquee"
    BorderMarqueeToothed => "marqueeToothed"
    BorderMoons => "moons"
    BorderMosaic => "mosaic"
    BorderMusicNotes => "musicNotes"
    BorderNorthwest => "northwest"
    BorderOvals => "ovals"
    BorderPackages => "packages"
    BorderPalmsBlack => "palmsBlack"
    BorderPalmsColor => "palmsColor"
    BorderPaperClips => "paperClips"
    BorderPapyrus => "papyrus"
    BorderPartyFavor => "partyFavor"
    BorderPartyGlass => "partyGlass"
    BorderPencils => "pencils"
    BorderPeople => "people"
    BorderPeopleWaving => "peopleWaving"
    BorderPeopleHats => "peopleHats"
    BorderPoinsettias => "poinsettias"
    BorderPostageStamp => "postageStamp"
    BorderPumpkin1 => "pumpkin1"
    BorderPushPinNote2 => "pushPinNote2"
    BorderPushPinNote1 => "pushPinNote1"
    BorderPyramids => "pyramids"
    BorderPyramidsAbove => "pyramidsAbove"
    BorderQuadrants => "quadrants"
    BorderRings => "rings"
    BorderSafari => "safari"
    BorderSawtooth => "sawtooth"
    BorderSawtoothGray => "sawtoothGray"
    BorderScaredCat => "scaredCat"
    BorderSeattle => "seattle"
    BorderShadowedSquares => "shadowedSquares"
    BorderSharksTeeth => "sharksTeeth"
    BorderShorebirdTracks => "shorebirdTracks"
    BorderSkyrocket => "skyrocket"
    BorderSnowflakeFancy => "snowflakeFancy"
    BorderSnowflakes => "snowflakes"
    BorderSombrero => "sombrero"
    BorderSouthwest => "southwest"
    BorderStars => "stars"
    BorderStarsTop => "starsTop"
    BorderStars3d => "stars3d"
    BorderStarsBlack => "starsBlack"
    BorderStarsShadowed => "starsShadowed"
    BorderSun => "sun"
    BorderSwirligig => "swirligig"
    BorderTornPaper => "tornPaper"
    BorderTornPaperBlack => "tornPaperBlack"
    BorderTrees => "trees"
    BorderTriangleParty => "triangleParty"
    BorderTriangles => "triangles"
    BorderTriangle1 => "triangle1"
    BorderTriangle2 => "triangle2"
    BorderTriangleCircle1 => "triangleCircle1"
    BorderTriangleCircle2 => "triangleCircle2"
    BorderShapes1 => "shapes1"
    BorderShapes2 => "shapes2"
    BorderTwistedLines1 => "twistedLines1"
    BorderTwistedLines2 => "twistedLines2"
    BorderVine => "vine"
    BorderWaveline => "waveline"
    BorderWeavingAngles => "weavingAngles"
    BorderWeavingBraid => "weavingBraid"
    BorderWeavingRibbon => "weavingRibbon"
    BorderWeavingStrips => "weavingStrips"
    BorderWhiteFlowers => "whiteFlowers"
    BorderWoodwork => "woodwork"
    BorderXIllusions => "xIllusions"
    BorderZanyTriangles => "zanyTriangles"
    BorderZigZag => "zigZag"
    BorderZigZagStitch => "zigZagStitch"
    BorderCustom => "custom"
  }
}

///|
/// XSD simple type ST_Shd — Part 1 §17.18.78.
/// Restriction of xsd:string to the 38-value shading-pattern enumeration.
pub(all) enum ST_Shd {
  ShdClear
  ShdDiagCross
  ShdDiagStripe
  ShdHorzCross
  ShdHorzStripe
  ShdNil
  ShdPct5
  ShdPct10
  ShdPct12
  ShdPct15
  ShdPct20
  ShdPct25
  ShdPct30
  ShdPct35
  ShdPct37
  ShdPct40
  ShdPct45
  ShdPct50
  ShdPct55
  ShdPct60
  ShdPct62
  ShdPct65
  ShdPct70
  ShdPct75
  ShdPct80
  ShdPct85
  ShdPct87
  ShdPct90
  ShdPct95
  ShdReverseDiagStripe
  ShdSolid
  ShdThinDiagCross
  ShdThinDiagStripe
  ShdThinHorzCross
  ShdThinHorzStripe
  ShdThinReverseDiagStripe
  ShdThinVertStripe
  ShdVertStripe
} derive(Eq, Debug)

///|
/// Parse the ST_Shd schema lexical value.
pub fn ST_Shd::parse(s : String) -> ST_Shd raise SchemaViolation {
  match s {
    "clear" => ShdClear
    "diagCross" => ShdDiagCross
    "diagStripe" => ShdDiagStripe
    "horzCross" => ShdHorzCross
    "horzStripe" => ShdHorzStripe
    "nil" => ShdNil
    "pct5" => ShdPct5
    "pct10" => ShdPct10
    "pct12" => ShdPct12
    "pct15" => ShdPct15
    "pct20" => ShdPct20
    "pct25" => ShdPct25
    "pct30" => ShdPct30
    "pct35" => ShdPct35
    "pct37" => ShdPct37
    "pct40" => ShdPct40
    "pct45" => ShdPct45
    "pct50" => ShdPct50
    "pct55" => ShdPct55
    "pct60" => ShdPct60
    "pct62" => ShdPct62
    "pct65" => ShdPct65
    "pct70" => ShdPct70
    "pct75" => ShdPct75
    "pct80" => ShdPct80
    "pct85" => ShdPct85
    "pct87" => ShdPct87
    "pct90" => ShdPct90
    "pct95" => ShdPct95
    "reverseDiagStripe" => ShdReverseDiagStripe
    "solid" => ShdSolid
    "thinDiagCross" => ShdThinDiagCross
    "thinDiagStripe" => ShdThinDiagStripe
    "thinHorzCross" => ShdThinHorzCross
    "thinHorzStripe" => ShdThinHorzStripe
    "thinReverseDiagStripe" => ShdThinReverseDiagStripe
    "thinVertStripe" => ShdThinVertStripe
    "vertStripe" => ShdVertStripe
    _ => invalid_simple_type("ST_Shd", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_Shd while enforcing the wml.xsd enumeration.
pub fn ST_Shd::new(s : String) -> ST_Shd raise SchemaViolation {
  ST_Shd::parse(s)
}

///|
/// Return the schema lexical value for ST_Shd.
pub fn ST_Shd::to_string(self : ST_Shd) -> String {
  match self {
    ShdClear => "clear"
    ShdDiagCross => "diagCross"
    ShdDiagStripe => "diagStripe"
    ShdHorzCross => "horzCross"
    ShdHorzStripe => "horzStripe"
    ShdNil => "nil"
    ShdPct5 => "pct5"
    ShdPct10 => "pct10"
    ShdPct12 => "pct12"
    ShdPct15 => "pct15"
    ShdPct20 => "pct20"
    ShdPct25 => "pct25"
    ShdPct30 => "pct30"
    ShdPct35 => "pct35"
    ShdPct37 => "pct37"
    ShdPct40 => "pct40"
    ShdPct45 => "pct45"
    ShdPct50 => "pct50"
    ShdPct55 => "pct55"
    ShdPct60 => "pct60"
    ShdPct62 => "pct62"
    ShdPct65 => "pct65"
    ShdPct70 => "pct70"
    ShdPct75 => "pct75"
    ShdPct80 => "pct80"
    ShdPct85 => "pct85"
    ShdPct87 => "pct87"
    ShdPct90 => "pct90"
    ShdPct95 => "pct95"
    ShdReverseDiagStripe => "reverseDiagStripe"
    ShdSolid => "solid"
    ShdThinDiagCross => "thinDiagCross"
    ShdThinDiagStripe => "thinDiagStripe"
    ShdThinHorzCross => "thinHorzCross"
    ShdThinHorzStripe => "thinHorzStripe"
    ShdThinReverseDiagStripe => "thinReverseDiagStripe"
    ShdThinVertStripe => "thinVertStripe"
    ShdVertStripe => "vertStripe"
  }
}

///|
/// XSD simple type ST_Em — Part 1 §17.18.24.
/// Restriction of xsd:string to the emphasis-mark catalogue
/// {circle, comma, dot, none, underDot}.
pub(all) enum ST_Em {
  EmCircle
  EmComma
  EmDot
  EmNone
  EmUnderDot
} derive(Eq, Debug)

///|
/// Parse the ST_Em schema lexical value.
pub fn ST_Em::parse(s : String) -> ST_Em raise SchemaViolation {
  match s {
    "circle" => EmCircle
    "comma" => EmComma
    "dot" => EmDot
    "none" => EmNone
    "underDot" => EmUnderDot
    _ => invalid_simple_type("ST_Em", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_Em while enforcing the wml.xsd enumeration.
pub fn ST_Em::new(s : String) -> ST_Em raise SchemaViolation {
  ST_Em::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_Em.
pub fn ST_Em::to_string(self : ST_Em) -> String {
  match self {
    EmCircle => "circle"
    EmComma => "comma"
    EmDot => "dot"
    EmNone => "none"
    EmUnderDot => "underDot"
  }
}

///|
/// XSD simple type ST_CombineBrackets — Part 1 §17.18.8.
/// Restriction of xsd:string to the bracket catalogue
/// {none, round, square, angle, curly} used to wrap two-lines-in-one runs.
pub(all) enum ST_CombineBrackets {
  CombineBracketsNone
  CombineBracketsRound
  CombineBracketsSquare
  CombineBracketsAngle
  CombineBracketsCurly
} derive(Eq, Debug)

///|
/// Parse the ST_CombineBrackets schema lexical value.
pub fn ST_CombineBrackets::parse(
  s : String,
) -> ST_CombineBrackets raise SchemaViolation {
  match s {
    "none" => CombineBracketsNone
    "round" => CombineBracketsRound
    "square" => CombineBracketsSquare
    "angle" => CombineBracketsAngle
    "curly" => CombineBracketsCurly
    _ =>
      invalid_simple_type("ST_CombineBrackets", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_CombineBrackets while enforcing the wml.xsd
/// enumeration.
pub fn ST_CombineBrackets::new(
  s : String,
) -> ST_CombineBrackets raise SchemaViolation {
  ST_CombineBrackets::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_CombineBrackets.
pub fn ST_CombineBrackets::to_string(self : ST_CombineBrackets) -> String {
  match self {
    CombineBracketsNone => "none"
    CombineBracketsRound => "round"
    CombineBracketsSquare => "square"
    CombineBracketsAngle => "angle"
    CombineBracketsCurly => "curly"
  }
}

///|
/// XSD simple type ST_HeightRule — Part 1 §17.18.37.
/// Restriction of xsd:string to {auto, exact, atLeast}, the
/// table-row height-resolution policies.
pub(all) enum ST_HeightRule {
  HeightRuleAuto
  HeightRuleExact
  HeightRuleAtLeast
} derive(Eq, Debug)

///|
/// Parse the ST_HeightRule schema lexical value.
pub fn ST_HeightRule::parse(s : String) -> ST_HeightRule raise SchemaViolation {
  match s {
    "auto" => HeightRuleAuto
    "exact" => HeightRuleExact
    "atLeast" => HeightRuleAtLeast
    _ => invalid_simple_type("ST_HeightRule", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_HeightRule while enforcing the wml.xsd enumeration.
pub fn ST_HeightRule::new(s : String) -> ST_HeightRule raise SchemaViolation {
  ST_HeightRule::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_HeightRule.
pub fn ST_HeightRule::to_string(self : ST_HeightRule) -> String {
  match self {
    HeightRuleAuto => "auto"
    HeightRuleExact => "exact"
    HeightRuleAtLeast => "atLeast"
  }
}

///|
/// XSD simple type ST_Wrap — Part 1 §17.18.104.
/// Restriction of xsd:string to the 6-value text-frame wrapping enumeration.
pub(all) enum ST_Wrap {
  WrapAround
  WrapAuto
  WrapNone
  WrapNotBeside
  WrapThrough
  WrapTight
} derive(Eq, Debug)

///|
/// Parse the ST_Wrap schema lexical value.
pub fn ST_Wrap::parse(s : String) -> ST_Wrap raise SchemaViolation {
  match s {
    "around" => WrapAround
    "auto" => WrapAuto
    "none" => WrapNone
    "notBeside" => WrapNotBeside
    "through" => WrapThrough
    "tight" => WrapTight
    _ => invalid_simple_type("ST_Wrap", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_Wrap while enforcing the wml.xsd enumeration.
pub fn ST_Wrap::new(s : String) -> ST_Wrap raise SchemaViolation {
  ST_Wrap::parse(s)
}

///|
/// Return the schema lexical value for ST_Wrap.
pub fn ST_Wrap::to_string(self : ST_Wrap) -> String {
  match self {
    WrapAround => "around"
    WrapAuto => "auto"
    WrapNone => "none"
    WrapNotBeside => "notBeside"
    WrapThrough => "through"
    WrapTight => "tight"
  }
}

///|
/// XSD simple type ST_VAnchor — Part 1 §17.18.100.
/// Restriction of xsd:string to {margin, page, text} for vertical anchoring.
pub(all) enum ST_VAnchor {
  VAnchorMargin
  VAnchorPage
  VAnchorText
} derive(Eq, Debug)

///|
/// Parse the ST_VAnchor schema lexical value.
pub fn ST_VAnchor::parse(s : String) -> ST_VAnchor raise SchemaViolation {
  match s {
    "margin" => VAnchorMargin
    "page" => VAnchorPage
    "text" => VAnchorText
    _ => invalid_simple_type("ST_VAnchor", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_VAnchor while enforcing the wml.xsd enumeration.
pub fn ST_VAnchor::new(s : String) -> ST_VAnchor raise SchemaViolation {
  ST_VAnchor::parse(s)
}

///|
/// Return the schema lexical value for ST_VAnchor.
pub fn ST_VAnchor::to_string(self : ST_VAnchor) -> String {
  match self {
    VAnchorMargin => "margin"
    VAnchorPage => "page"
    VAnchorText => "text"
  }
}

///|
/// XSD simple type ST_HAnchor — Part 1 §17.18.35.
/// Restriction of xsd:string to {text, margin, page}, identifying the
/// horizontal anchor base for a floating object.
pub(all) enum ST_HAnchor {
  HAnchorText
  HAnchorMargin
  HAnchorPage
} derive(Eq, Debug)

///|
/// Parse the ST_HAnchor schema lexical value.
pub fn ST_HAnchor::parse(s : String) -> ST_HAnchor raise SchemaViolation {
  match s {
    "text" => HAnchorText
    "margin" => HAnchorMargin
    "page" => HAnchorPage
    _ => invalid_simple_type("ST_HAnchor", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_HAnchor while enforcing the wml.xsd enumeration.
pub fn ST_HAnchor::new(s : String) -> ST_HAnchor raise SchemaViolation {
  ST_HAnchor::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_HAnchor.
pub fn ST_HAnchor::to_string(self : ST_HAnchor) -> String {
  match self {
    HAnchorText => "text"
    HAnchorMargin => "margin"
    HAnchorPage => "page"
  }
}

///|
/// XSD simple type ST_DropCap — Part 1 §17.18.20.
/// Restriction of xsd:string to {none, drop, margin}, the drop-cap
/// frame positioning options.
pub(all) enum ST_DropCap {
  DropCapNone
  DropCapDrop
  DropCapMargin
} derive(Eq, Debug)

///|
/// Parse the ST_DropCap schema lexical value.
pub fn ST_DropCap::parse(s : String) -> ST_DropCap raise SchemaViolation {
  match s {
    "none" => DropCapNone
    "drop" => DropCapDrop
    "margin" => DropCapMargin
    _ => invalid_simple_type("ST_DropCap", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_DropCap while enforcing the wml.xsd enumeration.
pub fn ST_DropCap::new(s : String) -> ST_DropCap raise SchemaViolation {
  ST_DropCap::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_DropCap.
pub fn ST_DropCap::to_string(self : ST_DropCap) -> String {
  match self {
    DropCapNone => "none"
    DropCapDrop => "drop"
    DropCapMargin => "margin"
  }
}

///|
/// XSD simple type ST_TabJc — Part 1 §17.18.84.
/// Restriction of xsd:string to the 7-value custom tab-stop type enumeration.
pub(all) enum ST_TabJc {
  TabJcBar
  TabJcCenter
  TabJcClear
  TabJcDecimal
  TabJcEnd
  TabJcNum
  TabJcStart
} derive(Eq, Debug)

///|
/// Parse the ST_TabJc schema lexical value.
///
/// §17.18.84 — the Strict token set is `clear`/`start`/`center`/
/// `end`/`decimal`/`bar`/`num`.  The Transitional token set (written
/// by Word 2007 and LibreOffice) additionally uses `left` and
/// `right` as aliases for `start` / `end`; a conforming reader MUST
/// accept them.  They map onto the Strict variant — `CT_TabStop`
/// keeps the source element verbatim, so the lexical token still
/// round-trips and only this typed projection is normalised.
pub fn ST_TabJc::parse(s : String) -> ST_TabJc raise SchemaViolation {
  match s {
    "bar" => TabJcBar
    "center" => TabJcCenter
    "clear" => TabJcClear
    "decimal" => TabJcDecimal
    "end" => TabJcEnd
    "num" => TabJcNum
    "start" => TabJcStart
    // Transitional aliases (§17.18.84) — `left` / `right`.
    "left" => TabJcStart
    "right" => TabJcEnd
    _ => invalid_simple_type("ST_TabJc", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_TabJc while enforcing the wml.xsd enumeration.
pub fn ST_TabJc::new(s : String) -> ST_TabJc raise SchemaViolation {
  ST_TabJc::parse(s)
}

///|
/// Return the schema lexical value for ST_TabJc.
pub fn ST_TabJc::to_string(self : ST_TabJc) -> String {
  match self {
    TabJcBar => "bar"
    TabJcCenter => "center"
    TabJcClear => "clear"
    TabJcDecimal => "decimal"
    TabJcEnd => "end"
    TabJcNum => "num"
    TabJcStart => "start"
  }
}

///|
/// XSD simple type ST_TabTlc — Part 1 §17.18.85.
/// Restriction of xsd:string to the 6-value tab leader-character enumeration.
pub(all) enum ST_TabTlc {
  TabTlcDot
  TabTlcHeavy
  TabTlcHyphen
  TabTlcMiddleDot
  TabTlcNone
  TabTlcUnderscore
} derive(Eq, Debug)

///|
/// Parse the ST_TabTlc schema lexical value.
pub fn ST_TabTlc::parse(s : String) -> ST_TabTlc raise SchemaViolation {
  match s {
    "dot" => TabTlcDot
    "heavy" => TabTlcHeavy
    "hyphen" => TabTlcHyphen
    "middleDot" => TabTlcMiddleDot
    "none" => TabTlcNone
    "underscore" => TabTlcUnderscore
    _ => invalid_simple_type("ST_TabTlc", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_TabTlc while enforcing the wml.xsd enumeration.
pub fn ST_TabTlc::new(s : String) -> ST_TabTlc raise SchemaViolation {
  ST_TabTlc::parse(s)
}

///|
/// Return the schema lexical value for ST_TabTlc.
pub fn ST_TabTlc::to_string(self : ST_TabTlc) -> String {
  match self {
    TabTlcDot => "dot"
    TabTlcHeavy => "heavy"
    TabTlcHyphen => "hyphen"
    TabTlcMiddleDot => "middleDot"
    TabTlcNone => "none"
    TabTlcUnderscore => "underscore"
  }
}

///|
/// XSD simple type ST_LineSpacingRule — Part 1 §17.18.48 line-spacing
/// calculation rule enumeration.
pub(all) enum ST_LineSpacingRule {
  /// §17.18.48 "auto"
  LineSpacingAuto
  /// §17.18.48 "exact"
  LineSpacingExact
  /// §17.18.48 "atLeast"
  LineSpacingAtLeast
} derive(Eq, Debug)

///|
/// Part 1 §17.18.48 — decode the line-spacing-rule lexical token.
pub fn ST_LineSpacingRule::parse(
  s : String,
) -> ST_LineSpacingRule raise SchemaViolation {
  match s {
    "auto" => LineSpacingAuto
    "exact" => LineSpacingExact
    "atLeast" => LineSpacingAtLeast
    _ =>
      invalid_simple_type("ST_LineSpacingRule", s, "unknown enumeration value")
  }
}

///|
pub fn ST_LineSpacingRule::new(
  s : String,
) -> ST_LineSpacingRule raise SchemaViolation {
  ST_LineSpacingRule::parse(s)
}

///|
pub fn ST_LineSpacingRule::to_string(self : ST_LineSpacingRule) -> String {
  match self {
    LineSpacingAuto => "auto"
    LineSpacingExact => "exact"
    LineSpacingAtLeast => "atLeast"
  }
}

///|
/// XSD simple type ST_Jc — Part 1 §17.18.44 paragraph horizontal
/// alignment enumeration (ten lexical values).
pub(all) enum ST_Jc {
  /// §17.18.44 "start"
  JcStart
  /// §17.18.44 "center"
  JcCenter
  /// §17.18.44 "end"
  JcEnd
  /// §17.18.44 "both"
  JcBoth
  /// §17.18.44 "mediumKashida"
  JcMediumKashida
  /// §17.18.44 "distribute"
  JcDistribute
  /// §17.18.44 "numTab"
  JcNumTab
  /// §17.18.44 "highKashida"
  JcHighKashida
  /// §17.18.44 "lowKashida"
  JcLowKashida
  /// §17.18.44 "thaiDistribute"
  JcThaiDistribute
} derive(Eq, Debug)

///|
/// Part 1 §17.18.44 — decode the justification lexical token.
///
/// `left` and `right` are the legacy (Word 2003-era, deprecated in
/// §L.4.3.2.27 transitional spec note) spellings of `start` / `end`.
/// Word itself still emits them when an author saves a paragraph
/// alignment in the UI, so accepting them here lets every real-world
/// .docx survive `CT_Jc::new`. The mapping matches the canonicalisation
/// already applied to numbering-level `<w:lvlJc>` (see
/// `numbering_types.mbt::normalise_lvl_jc`).
pub fn ST_Jc::parse(s : String) -> ST_Jc raise SchemaViolation {
  match s {
    "start" | "left" => JcStart
    "center" => JcCenter
    "end" | "right" => JcEnd
    "both" => JcBoth
    "mediumKashida" => JcMediumKashida
    "distribute" => JcDistribute
    "numTab" => JcNumTab
    "highKashida" => JcHighKashida
    "lowKashida" => JcLowKashida
    "thaiDistribute" => JcThaiDistribute
    _ => invalid_simple_type("ST_Jc", s, "unknown enumeration value")
  }
}

///|
pub fn ST_Jc::new(s : String) -> ST_Jc raise SchemaViolation {
  ST_Jc::parse(s)
}

///|
pub fn ST_Jc::to_string(self : ST_Jc) -> String {
  match self {
    JcStart => "start"
    JcCenter => "center"
    JcEnd => "end"
    JcBoth => "both"
    JcMediumKashida => "mediumKashida"
    JcDistribute => "distribute"
    JcNumTab => "numTab"
    JcHighKashida => "highKashida"
    JcLowKashida => "lowKashida"
    JcThaiDistribute => "thaiDistribute"
  }
}

///|
/// XSD simple type ST_JcTable — Part 1 §17.18.45 table alignment
/// enumeration. Variant names are prefixed `JcTable` to avoid clashing
/// with ST_Jc's overlapping `start` / `center` / `end` tokens.
pub(all) enum ST_JcTable {
  /// §17.18.45 "center"
  JcTableCenter
  /// §17.18.45 "end"
  JcTableEnd
  /// §17.18.45 "start"
  JcTableStart
} derive(Eq, Debug)

///|
/// Part 1 §17.18.45 — decode the table-justification lexical token.
///
/// `left` and `right` mirror the legacy aliases accepted by ST_Jc
/// (§17.18.44). Word emits `left` / `right` on `<w:tblPr><w:jc>` /
/// `<w:trPr><w:jc>` for documents authored before the start / end
/// canonicalisation, so accepting them avoids rejecting otherwise
/// valid round-trips.
pub fn ST_JcTable::parse(s : String) -> ST_JcTable raise SchemaViolation {
  match s {
    "center" => JcTableCenter
    "end" | "right" => JcTableEnd
    "start" | "left" => JcTableStart
    _ => invalid_simple_type("ST_JcTable", s, "unknown enumeration value")
  }
}

///|
pub fn ST_JcTable::new(s : String) -> ST_JcTable raise SchemaViolation {
  ST_JcTable::parse(s)
}

///|
pub fn ST_JcTable::to_string(self : ST_JcTable) -> String {
  match self {
    JcTableCenter => "center"
    JcTableEnd => "end"
    JcTableStart => "start"
  }
}

///|
/// XSD simple type ST_View — Part 1 §17.18.102.
/// Restriction of xsd:string to the 6-value document view enumeration.
pub(all) enum ST_View {
  ViewMasterPages
  ViewNone
  ViewNormal
  ViewOutline
  ViewPrint
  ViewWeb
} derive(Eq, Debug)

///|
/// Parse the ST_View schema lexical value.
pub fn ST_View::parse(s : String) -> ST_View raise SchemaViolation {
  match s {
    "masterPages" => ViewMasterPages
    "none" => ViewNone
    "normal" => ViewNormal
    "outline" => ViewOutline
    "print" => ViewPrint
    "web" => ViewWeb
    _ => invalid_simple_type("ST_View", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_View while enforcing the wml.xsd enumeration.
pub fn ST_View::new(s : String) -> ST_View raise SchemaViolation {
  ST_View::parse(s)
}

///|
/// Return the schema lexical value for ST_View.
pub fn ST_View::to_string(self : ST_View) -> String {
  match self {
    ViewMasterPages => "masterPages"
    ViewNone => "none"
    ViewNormal => "normal"
    ViewOutline => "outline"
    ViewPrint => "print"
    ViewWeb => "web"
  }
}

///|
/// XSD simple type ST_Zoom — Part 1 §17.18.105.
/// Restriction of xsd:string to the 4-value magnification preset enumeration.
pub(all) enum ST_Zoom {
  ZoomBestFit
  ZoomFullPage
  ZoomNone
  ZoomTextFit
} derive(Eq, Debug)

///|
/// Parse the ST_Zoom schema lexical value.
pub fn ST_Zoom::parse(s : String) -> ST_Zoom raise SchemaViolation {
  match s {
    "bestFit" => ZoomBestFit
    "fullPage" => ZoomFullPage
    "none" => ZoomNone
    "textFit" => ZoomTextFit
    _ => invalid_simple_type("ST_Zoom", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_Zoom while enforcing the wml.xsd enumeration.
pub fn ST_Zoom::new(s : String) -> ST_Zoom raise SchemaViolation {
  ST_Zoom::parse(s)
}

///|
/// Return the schema lexical value for ST_Zoom.
pub fn ST_Zoom::to_string(self : ST_Zoom) -> String {
  match self {
    ZoomBestFit => "bestFit"
    ZoomFullPage => "fullPage"
    ZoomNone => "none"
    ZoomTextFit => "textFit"
  }
}

///|
/// XSD simple type ST_Proof — Part 1 §17.18.69 proofing-state
/// enumeration: a paragraph or run can be `clean` (no proofing needed)
/// or `dirty` (re-check on next pass).
pub(all) enum ST_Proof {
  /// §17.18.69 "clean"
  ProofClean
  /// §17.18.69 "dirty"
  ProofDirty
} derive(Eq, Debug)

///|
/// Part 1 §17.18.69 — decode the proof-state lexical token.
pub fn ST_Proof::parse(s : String) -> ST_Proof raise SchemaViolation {
  match s {
    "clean" => ProofClean
    "dirty" => ProofDirty
    _ => invalid_simple_type("ST_Proof", s, "unknown enumeration value")
  }
}

///|
pub fn ST_Proof::new(s : String) -> ST_Proof raise SchemaViolation {
  ST_Proof::parse(s)
}

///|
pub fn ST_Proof::to_string(self : ST_Proof) -> String {
  match self {
    ProofClean => "clean"
    ProofDirty => "dirty"
  }
}

///|
/// XSD simple type ST_DocType — Part 1 §17.18.19.
/// Restriction of xsd:string with no enumeration: the Part 1 spec
/// merely *reserves* {eMail, letter, notSpecified} as well-known
/// classifications but allows any producer-defined token (the Part 4
/// transitional XSD adds no restriction either). Stored as the raw
/// lexical form, which is preserved verbatim across round-trips.
pub struct ST_DocType {
  lexical : String
} derive(Eq, Debug)

///|
/// Parse the ST_DocType schema lexical value. The grammar is open;
/// only the non-empty restriction is enforced here.
pub fn ST_DocType::parse(s : String) -> ST_DocType raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_DocType", s, "empty lexical value")
  }
  { lexical: s }
}

///|
/// Construct ST_DocType while enforcing the xsd:string lexical
/// guarantee (non-empty).
pub fn ST_DocType::new(s : String) -> ST_DocType raise SchemaViolation {
  ST_DocType::parse(s)
}

///|
/// Return the canonical schema lexical value (round-trip preserved).
pub fn ST_DocType::to_string(self : ST_DocType) -> String {
  self.lexical
}

///|
/// XSD simple type ST_DocProtect — Part 1 §17.18.18.
/// Restriction of xsd:string to the editing-restriction catalogue
/// {none, readOnly, comments, trackedChanges, forms}.
pub(all) enum ST_DocProtect {
  DocProtectNone
  DocProtectReadOnly
  DocProtectComments
  DocProtectTrackedChanges
  DocProtectForms
} derive(Eq, Debug)

///|
/// Parse the ST_DocProtect schema lexical value.
pub fn ST_DocProtect::parse(s : String) -> ST_DocProtect raise SchemaViolation {
  match s {
    "none" => DocProtectNone
    "readOnly" => DocProtectReadOnly
    "comments" => DocProtectComments
    "trackedChanges" => DocProtectTrackedChanges
    "forms" => DocProtectForms
    _ => invalid_simple_type("ST_DocProtect", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_DocProtect while enforcing the wml.xsd enumeration.
pub fn ST_DocProtect::new(s : String) -> ST_DocProtect raise SchemaViolation {
  ST_DocProtect::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_DocProtect.
pub fn ST_DocProtect::to_string(self : ST_DocProtect) -> String {
  match self {
    DocProtectNone => "none"
    DocProtectReadOnly => "readOnly"
    DocProtectComments => "comments"
    DocProtectTrackedChanges => "trackedChanges"
    DocProtectForms => "forms"
  }
}

///|
/// XSD simple type ST_MailMergeDocType — Part 1 §17.18.54 mail merge
/// source-document type enumeration.
pub(all) enum ST_MailMergeDocType {
  /// §17.18.54 "catalog"
  MailMergeDocTypeCatalog
  /// §17.18.54 "envelopes"
  MailMergeDocTypeEnvelopes
  /// §17.18.54 "mailingLabels"
  MailMergeDocTypeMailingLabels
  /// §17.18.54 "formLetters"
  MailMergeDocTypeFormLetters
  /// §17.18.54 "email"
  MailMergeDocTypeEmail
  /// §17.18.54 "fax"
  MailMergeDocTypeFax
} derive(Eq, Debug)

///|
/// Part 1 §17.18.54 — decode the source-document type lexical token.
pub fn ST_MailMergeDocType::parse(
  s : String,
) -> ST_MailMergeDocType raise SchemaViolation {
  match s {
    "catalog" => MailMergeDocTypeCatalog
    "envelopes" => MailMergeDocTypeEnvelopes
    "mailingLabels" => MailMergeDocTypeMailingLabels
    "formLetters" => MailMergeDocTypeFormLetters
    "email" => MailMergeDocTypeEmail
    "fax" => MailMergeDocTypeFax
    _ =>
      invalid_simple_type("ST_MailMergeDocType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_MailMergeDocType::new(
  s : String,
) -> ST_MailMergeDocType raise SchemaViolation {
  ST_MailMergeDocType::parse(s)
}

///|
pub fn ST_MailMergeDocType::to_string(self : ST_MailMergeDocType) -> String {
  match self {
    MailMergeDocTypeCatalog => "catalog"
    MailMergeDocTypeEnvelopes => "envelopes"
    MailMergeDocTypeMailingLabels => "mailingLabels"
    MailMergeDocTypeFormLetters => "formLetters"
    MailMergeDocTypeEmail => "email"
    MailMergeDocTypeFax => "fax"
  }
}

///|
/// XSD simple type ST_MailMergeDataType — Part 1 §17.18.52 mail merge
/// data-source access mechanism. The XSD declares an unrestricted
/// `xsd:string`; the §17.18.52 prose lists reserved tokens such as
/// `native`, `odbc`, and `query` but does not forbid producer-defined
/// values, so the typed carrier stores the raw lexical text. Empty
/// strings are rejected per the §17.18 validation rule.
pub struct ST_MailMergeDataType {
  lexical : String
} derive(Eq, Debug)

///|
/// Part 1 §17.18.52 — wrap any data-source-type lexical value.
pub fn ST_MailMergeDataType::parse(
  s : String,
) -> ST_MailMergeDataType raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_MailMergeDataType", s, "empty lexical value")
  }
  { lexical: s }
}

///|
pub fn ST_MailMergeDataType::new(
  s : String,
) -> ST_MailMergeDataType raise SchemaViolation {
  ST_MailMergeDataType::parse(s)
}

///|
pub fn ST_MailMergeDataType::to_string(self : ST_MailMergeDataType) -> String {
  self.lexical
}

///|
/// XSD simple type ST_MailMergeDest — Part 1 §17.18.53 merged-document
/// destination enumeration.
pub(all) enum ST_MailMergeDest {
  /// §17.18.53 "newDocument"
  MailMergeDestNewDocument
  /// §17.18.53 "printer"
  MailMergeDestPrinter
  /// §17.18.53 "email"
  MailMergeDestEmail
  /// §17.18.53 "fax"
  MailMergeDestFax
} derive(Eq, Debug)

///|
/// Part 1 §17.18.53 — decode the destination lexical token.
pub fn ST_MailMergeDest::parse(
  s : String,
) -> ST_MailMergeDest raise SchemaViolation {
  match s {
    "newDocument" => MailMergeDestNewDocument
    "printer" => MailMergeDestPrinter
    "email" => MailMergeDestEmail
    "fax" => MailMergeDestFax
    _ => invalid_simple_type("ST_MailMergeDest", s, "unknown enumeration value")
  }
}

///|
pub fn ST_MailMergeDest::new(
  s : String,
) -> ST_MailMergeDest raise SchemaViolation {
  ST_MailMergeDest::parse(s)
}

///|
pub fn ST_MailMergeDest::to_string(self : ST_MailMergeDest) -> String {
  match self {
    MailMergeDestNewDocument => "newDocument"
    MailMergeDestPrinter => "printer"
    MailMergeDestEmail => "email"
    MailMergeDestFax => "fax"
  }
}

///|
/// XSD simple type ST_MailMergeOdsoFMDFieldType — Part 1 §17.18.55 ODSO
/// field-mapping data field-type enumeration. The reserved keyword
/// `null` is renamed to `MailMergeOdsoNull` to avoid clashing with
/// MoonBit reserved tokens.
pub(all) enum ST_MailMergeOdsoFMDFieldType {
  /// §17.18.55 "null"
  MailMergeOdsoNull
  /// §17.18.55 "dbColumn"
  MailMergeOdsoDbColumn
} derive(Eq, Debug)

///|
/// Part 1 §17.18.55 — decode the field-type lexical token.
pub fn ST_MailMergeOdsoFMDFieldType::parse(
  s : String,
) -> ST_MailMergeOdsoFMDFieldType raise SchemaViolation {
  match s {
    "null" => MailMergeOdsoNull
    "dbColumn" => MailMergeOdsoDbColumn
    _ =>
      invalid_simple_type(
        "ST_MailMergeOdsoFMDFieldType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_MailMergeOdsoFMDFieldType::new(
  s : String,
) -> ST_MailMergeOdsoFMDFieldType raise SchemaViolation {
  ST_MailMergeOdsoFMDFieldType::parse(s)
}

///|
pub fn ST_MailMergeOdsoFMDFieldType::to_string(
  self : ST_MailMergeOdsoFMDFieldType,
) -> String {
  match self {
    MailMergeOdsoNull => "null"
    MailMergeOdsoDbColumn => "dbColumn"
  }
}

///|
/// XSD simple type ST_TextDirection — Part 1 §17.18.93.
/// Restriction of xsd:string to the 6-value text-flow direction enumeration.
pub(all) enum ST_TextDirection {
  TextDirectionLr
  TextDirectionLrV
  TextDirectionRl
  TextDirectionRlV
  TextDirectionTb
  TextDirectionTbV
} derive(Eq, Debug)

///|
/// Parse the ST_TextDirection schema lexical value.
///
/// ECMA-376 defines this enumeration in two generations.  The
/// *Strict* (4th edition) token set is `lr`/`lrV`/`rl`/`rlV`/`tb`/
/// `tbV`.  The *Transitional* (ISO/IEC 29500-1 §17.18.93) token set
/// — written by Word 2007 and by LibreOffice — is `lrTb`/`tbRl`/
/// `btLr`/`lrTbV`/`tbRlV`/`tbLrV`.  A conforming reader MUST accept
/// both, so the transitional spellings are mapped here onto their
/// closest Strict semantic equivalent.  `CT_TextDirection` keeps the
/// source element verbatim, so the original lexical token still
/// round-trips unchanged; this typed `val` is only the semantic
/// projection.
pub fn ST_TextDirection::parse(
  s : String,
) -> ST_TextDirection raise SchemaViolation {
  match s {
    // Strict (ECMA-376 4th edition) token set.
    "lr" => TextDirectionLr
    "lrV" => TextDirectionLrV
    "rl" => TextDirectionRl
    "rlV" => TextDirectionRlV
    "tb" => TextDirectionTb
    "tbV" => TextDirectionTbV
    // Transitional (ISO/IEC 29500-1 §17.18.93) token set — mapped to
    // the Strict equivalent.  `lrTb` is ordinary horizontal flow;
    // `tbRl` is the 90°-rotated vertical flow; `btLr` and the `*V`
    // tokens are the rotated-text variants.
    "lrTb" => TextDirectionLr
    "tbRl" => TextDirectionTb
    "btLr" => TextDirectionLrV
    "lrTbV" => TextDirectionLrV
    "tbRlV" => TextDirectionTbV
    "tbLrV" => TextDirectionTbV
    _ => invalid_simple_type("ST_TextDirection", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_TextDirection while enforcing the wml.xsd enumeration.
pub fn ST_TextDirection::new(
  s : String,
) -> ST_TextDirection raise SchemaViolation {
  ST_TextDirection::parse(s)
}

///|
/// Return the schema lexical value for ST_TextDirection.
pub fn ST_TextDirection::to_string(self : ST_TextDirection) -> String {
  match self {
    TextDirectionLr => "lr"
    TextDirectionLrV => "lrV"
    TextDirectionRl => "rl"
    TextDirectionRlV => "rlV"
    TextDirectionTb => "tb"
    TextDirectionTbV => "tbV"
  }
}

///|
/// XSD simple type ST_TextAlignment — Part 1 §17.18.91.
/// Restriction of xsd:string to the 5-value vertical text alignment
/// enumeration.
pub(all) enum ST_TextAlignment {
  TextAlignmentAuto
  TextAlignmentBaseline
  TextAlignmentBottom
  TextAlignmentCenter
  TextAlignmentTop
} derive(Eq, Debug)

///|
/// Parse the ST_TextAlignment schema lexical value.
pub fn ST_TextAlignment::parse(
  s : String,
) -> ST_TextAlignment raise SchemaViolation {
  match s {
    "auto" => TextAlignmentAuto
    "baseline" => TextAlignmentBaseline
    "bottom" => TextAlignmentBottom
    "center" => TextAlignmentCenter
    "top" => TextAlignmentTop
    _ => invalid_simple_type("ST_TextAlignment", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_TextAlignment while enforcing the wml.xsd enumeration.
pub fn ST_TextAlignment::new(
  s : String,
) -> ST_TextAlignment raise SchemaViolation {
  ST_TextAlignment::parse(s)
}

///|
/// Return the schema lexical value for ST_TextAlignment.
pub fn ST_TextAlignment::to_string(self : ST_TextAlignment) -> String {
  match self {
    TextAlignmentAuto => "auto"
    TextAlignmentBaseline => "baseline"
    TextAlignmentBottom => "bottom"
    TextAlignmentCenter => "center"
    TextAlignmentTop => "top"
  }
}

///|
/// XSD simple type ST_DisplacedByCustomXml — Part 1 §17.18.13.
/// Restriction of xsd:string to {next, prev}, identifying which
/// custom-XML markup element displaces the parent annotation.
pub(all) enum ST_DisplacedByCustomXml {
  DisplacedByCustomXmlNext
  DisplacedByCustomXmlPrev
} derive(Eq, Debug)

///|
/// Parse the ST_DisplacedByCustomXml schema lexical value.
pub fn ST_DisplacedByCustomXml::parse(
  s : String,
) -> ST_DisplacedByCustomXml raise SchemaViolation {
  match s {
    "next" => DisplacedByCustomXmlNext
    "prev" => DisplacedByCustomXmlPrev
    _ =>
      invalid_simple_type(
        "ST_DisplacedByCustomXml", s, "unknown enumeration value",
      )
  }
}

///|
/// Construct ST_DisplacedByCustomXml while enforcing the wml.xsd
/// enumeration.
pub fn ST_DisplacedByCustomXml::new(
  s : String,
) -> ST_DisplacedByCustomXml raise SchemaViolation {
  ST_DisplacedByCustomXml::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_DisplacedByCustomXml.
pub fn ST_DisplacedByCustomXml::to_string(
  self : ST_DisplacedByCustomXml,
) -> String {
  match self {
    DisplacedByCustomXmlNext => "next"
    DisplacedByCustomXmlPrev => "prev"
  }
}

///|
/// XSD simple type ST_AnnotationVMerge — Part 1 §17.18.1.
/// Restriction of xsd:string to {cont, rest}, recording table-cell
/// vertical merge revision intent.
pub(all) enum ST_AnnotationVMerge {
  AnnotationVMergeCont
  AnnotationVMergeRest
} derive(Eq, Debug)

///|
/// Parse the ST_AnnotationVMerge schema lexical value.
pub fn ST_AnnotationVMerge::parse(
  s : String,
) -> ST_AnnotationVMerge raise SchemaViolation {
  match s {
    "cont" => AnnotationVMergeCont
    "rest" => AnnotationVMergeRest
    _ =>
      invalid_simple_type("ST_AnnotationVMerge", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_AnnotationVMerge while enforcing the wml.xsd
/// enumeration.
pub fn ST_AnnotationVMerge::new(
  s : String,
) -> ST_AnnotationVMerge raise SchemaViolation {
  ST_AnnotationVMerge::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_AnnotationVMerge.
pub fn ST_AnnotationVMerge::to_string(self : ST_AnnotationVMerge) -> String {
  match self {
    AnnotationVMergeCont => "cont"
    AnnotationVMergeRest => "rest"
  }
}

///|
/// XSD simple type ST_TextboxTightWrap — Part 1 §17.18.92.
/// Restriction of xsd:string to the 5-value text-box tight wrap enumeration.
pub(all) enum ST_TextboxTightWrap {
  TextboxTightWrapAllLines
  TextboxTightWrapFirstAndLastLine
  TextboxTightWrapFirstLineOnly
  TextboxTightWrapLastLineOnly
  TextboxTightWrapNone
} derive(Eq, Debug)

///|
/// Parse the ST_TextboxTightWrap schema lexical value.
pub fn ST_TextboxTightWrap::parse(
  s : String,
) -> ST_TextboxTightWrap raise SchemaViolation {
  match s {
    "allLines" => TextboxTightWrapAllLines
    "firstAndLastLine" => TextboxTightWrapFirstAndLastLine
    "firstLineOnly" => TextboxTightWrapFirstLineOnly
    "lastLineOnly" => TextboxTightWrapLastLineOnly
    "none" => TextboxTightWrapNone
    _ =>
      invalid_simple_type("ST_TextboxTightWrap", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_TextboxTightWrap while enforcing the wml.xsd enumeration.
pub fn ST_TextboxTightWrap::new(
  s : String,
) -> ST_TextboxTightWrap raise SchemaViolation {
  ST_TextboxTightWrap::parse(s)
}

///|
/// Return the schema lexical value for ST_TextboxTightWrap.
pub fn ST_TextboxTightWrap::to_string(self : ST_TextboxTightWrap) -> String {
  match self {
    TextboxTightWrapAllLines => "allLines"
    TextboxTightWrapFirstAndLastLine => "firstAndLastLine"
    TextboxTightWrapFirstLineOnly => "firstLineOnly"
    TextboxTightWrapLastLineOnly => "lastLineOnly"
    TextboxTightWrapNone => "none"
  }
}

///|
/// XSD simple type ST_ObjectDrawAspect — Part 1 §17.18.60 embedded
/// object draw-aspect enumeration.
pub(all) enum ST_ObjectDrawAspect {
  /// §17.18.60 "content"
  ObjectDrawAspectContent
  /// §17.18.60 "icon"
  ObjectDrawAspectIcon
} derive(Eq, Debug)

///|
/// Part 1 §17.18.60 — decode the draw-aspect lexical token.
pub fn ST_ObjectDrawAspect::parse(
  s : String,
) -> ST_ObjectDrawAspect raise SchemaViolation {
  match s {
    "content" => ObjectDrawAspectContent
    "icon" => ObjectDrawAspectIcon
    _ =>
      invalid_simple_type("ST_ObjectDrawAspect", s, "unknown enumeration value")
  }
}

///|
pub fn ST_ObjectDrawAspect::new(
  s : String,
) -> ST_ObjectDrawAspect raise SchemaViolation {
  ST_ObjectDrawAspect::parse(s)
}

///|
pub fn ST_ObjectDrawAspect::to_string(self : ST_ObjectDrawAspect) -> String {
  match self {
    ObjectDrawAspectContent => "content"
    ObjectDrawAspectIcon => "icon"
  }
}

///|
/// XSD simple type ST_ObjectUpdateMode — Part 1 §17.18.61 embedded
/// object update-mode enumeration.
pub(all) enum ST_ObjectUpdateMode {
  /// §17.18.61 "always"
  ObjectUpdateAlways
  /// §17.18.61 "onCall"
  ObjectUpdateOnCall
} derive(Eq, Debug)

///|
/// Part 1 §17.18.61 — decode the update-mode lexical token.
pub fn ST_ObjectUpdateMode::parse(
  s : String,
) -> ST_ObjectUpdateMode raise SchemaViolation {
  match s {
    "always" => ObjectUpdateAlways
    "onCall" => ObjectUpdateOnCall
    _ =>
      invalid_simple_type("ST_ObjectUpdateMode", s, "unknown enumeration value")
  }
}

///|
pub fn ST_ObjectUpdateMode::new(
  s : String,
) -> ST_ObjectUpdateMode raise SchemaViolation {
  ST_ObjectUpdateMode::parse(s)
}

///|
pub fn ST_ObjectUpdateMode::to_string(self : ST_ObjectUpdateMode) -> String {
  match self {
    ObjectUpdateAlways => "always"
    ObjectUpdateOnCall => "onCall"
  }
}

///|
/// XSD simple type ST_FldCharType — Part 1 §17.18.29.
/// Restriction of xsd:string to the complex-field character role
/// catalogue {begin, separate, end}.
pub(all) enum ST_FldCharType {
  FldCharTypeBegin
  FldCharTypeSeparate
  FldCharTypeEnd
} derive(Eq, Debug)

///|
/// Parse the ST_FldCharType schema lexical value.
pub fn ST_FldCharType::parse(
  s : String,
) -> ST_FldCharType raise SchemaViolation {
  match s {
    "begin" => FldCharTypeBegin
    "separate" => FldCharTypeSeparate
    "end" => FldCharTypeEnd
    _ => invalid_simple_type("ST_FldCharType", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_FldCharType while enforcing the wml.xsd enumeration.
pub fn ST_FldCharType::new(s : String) -> ST_FldCharType raise SchemaViolation {
  ST_FldCharType::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_FldCharType.
pub fn ST_FldCharType::to_string(self : ST_FldCharType) -> String {
  match self {
    FldCharTypeBegin => "begin"
    FldCharTypeSeparate => "separate"
    FldCharTypeEnd => "end"
  }
}

///|
/// XSD simple type ST_InfoTextType — Part 1 §17.18.43 form-field
/// help/status text type enumeration.
pub(all) enum ST_InfoTextType {
  /// §17.18.43 "text"
  InfoTextText
  /// §17.18.43 "autoText"
  InfoTextAutoText
} derive(Eq, Debug)

///|
/// Part 1 §17.18.43 — decode the info-text-type lexical token.
pub fn ST_InfoTextType::parse(
  s : String,
) -> ST_InfoTextType raise SchemaViolation {
  match s {
    "text" => InfoTextText
    "autoText" => InfoTextAutoText
    _ => invalid_simple_type("ST_InfoTextType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_InfoTextType::new(
  s : String,
) -> ST_InfoTextType raise SchemaViolation {
  ST_InfoTextType::parse(s)
}

///|
pub fn ST_InfoTextType::to_string(self : ST_InfoTextType) -> String {
  match self {
    InfoTextText => "text"
    InfoTextAutoText => "autoText"
  }
}

///|
/// XSD simple type ST_FFHelpTextVal — Part 1 §17.18.25.
/// Restriction of xsd:string with a maxLength of 256 Unicode scalar
/// values; stored as the schema lexical form (round-trip preserved).
pub struct ST_FFHelpTextVal {
  lexical : String
} derive(Eq, Debug)

///|
/// Parse the ST_FFHelpTextVal schema lexical value, enforcing the
/// 256-character upper bound.
pub fn ST_FFHelpTextVal::parse(
  s : String,
) -> ST_FFHelpTextVal raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_FFHelpTextVal", s, "empty lexical value")
  }
  if s.length() > 256 {
    invalid_simple_type(
      "ST_FFHelpTextVal", s, "lexical value exceeds 256 Unicode scalar values",
    )
  }
  { lexical: s }
}

///|
/// Construct ST_FFHelpTextVal while enforcing the wml.xsd maxLength
/// restriction.
pub fn ST_FFHelpTextVal::new(
  s : String,
) -> ST_FFHelpTextVal raise SchemaViolation {
  ST_FFHelpTextVal::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_FFHelpTextVal.
pub fn ST_FFHelpTextVal::to_string(self : ST_FFHelpTextVal) -> String {
  self.lexical
}

///|
/// XSD simple type ST_FFStatusTextVal — Part 1 §17.18.27.
/// Restriction of xsd:string with a maxLength of 140 characters;
/// stored as the schema lexical form (round-trip preserved).
pub struct ST_FFStatusTextVal {
  lexical : String
} derive(Eq, Debug)

///|
/// Parse the ST_FFStatusTextVal schema lexical value, enforcing the
/// 140-character upper bound.
pub fn ST_FFStatusTextVal::parse(
  s : String,
) -> ST_FFStatusTextVal raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_FFStatusTextVal", s, "empty lexical value")
  }
  if s.length() > 140 {
    invalid_simple_type(
      "ST_FFStatusTextVal", s, "lexical value exceeds 140 characters",
    )
  }
  { lexical: s }
}

///|
/// Construct ST_FFStatusTextVal while enforcing the wml.xsd maxLength
/// restriction.
pub fn ST_FFStatusTextVal::new(
  s : String,
) -> ST_FFStatusTextVal raise SchemaViolation {
  ST_FFStatusTextVal::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_FFStatusTextVal.
pub fn ST_FFStatusTextVal::to_string(self : ST_FFStatusTextVal) -> String {
  self.lexical
}

///|
/// XSD simple type ST_FFName — Part 1 §17.18.26.
/// Restriction of xsd:string with a maxLength of 65 Unicode scalar
/// values; stored as the schema lexical form (round-trip preserved).
pub struct ST_FFName {
  lexical : String
} derive(Eq, Debug)

///|
/// Parse the ST_FFName schema lexical value, enforcing the 65-character
/// upper bound.
pub fn ST_FFName::parse(s : String) -> ST_FFName raise SchemaViolation {
  if s.length() == 0 {
    invalid_simple_type("ST_FFName", s, "empty lexical value")
  }
  if s.length() > 65 {
    invalid_simple_type(
      "ST_FFName", s, "lexical value exceeds 65 Unicode scalar values",
    )
  }
  { lexical: s }
}

///|
/// Construct ST_FFName while enforcing the wml.xsd maxLength restriction.
pub fn ST_FFName::new(s : String) -> ST_FFName raise SchemaViolation {
  ST_FFName::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_FFName.
pub fn ST_FFName::to_string(self : ST_FFName) -> String {
  self.lexical
}

///|
/// XSD simple type ST_FFTextType — Part 1 §17.18.28.
/// Restriction of xsd:string to the text-box form-field type
/// catalogue {regular, number, date, currentTime, currentDate,
/// calculated}.
pub(all) enum ST_FFTextType {
  FFTextTypeRegular
  FFTextTypeNumber
  FFTextTypeDate
  FFTextTypeCurrentTime
  FFTextTypeCurrentDate
  FFTextTypeCalculated
} derive(Eq, Debug)

///|
/// Parse the ST_FFTextType schema lexical value.
pub fn ST_FFTextType::parse(s : String) -> ST_FFTextType raise SchemaViolation {
  match s {
    "regular" => FFTextTypeRegular
    "number" => FFTextTypeNumber
    "date" => FFTextTypeDate
    "currentTime" => FFTextTypeCurrentTime
    "currentDate" => FFTextTypeCurrentDate
    "calculated" => FFTextTypeCalculated
    _ => invalid_simple_type("ST_FFTextType", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_FFTextType while enforcing the wml.xsd enumeration.
pub fn ST_FFTextType::new(s : String) -> ST_FFTextType raise SchemaViolation {
  ST_FFTextType::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_FFTextType.
pub fn ST_FFTextType::to_string(self : ST_FFTextType) -> String {
  match self {
    FFTextTypeRegular => "regular"
    FFTextTypeNumber => "number"
    FFTextTypeDate => "date"
    FFTextTypeCurrentTime => "currentTime"
    FFTextTypeCurrentDate => "currentDate"
    FFTextTypeCalculated => "calculated"
  }
}

///|
/// XSD simple type ST_SectionMark — Part 1 §17.18.77.
/// Restriction of xsd:string to the 5-value section break-kind enumeration.
pub(all) enum ST_SectionMark {
  SectionMarkContinuous
  SectionMarkEvenPage
  SectionMarkNextColumn
  SectionMarkNextPage
  SectionMarkOddPage
} derive(Eq, Debug)

///|
/// Parse the ST_SectionMark schema lexical value.
pub fn ST_SectionMark::parse(
  s : String,
) -> ST_SectionMark raise SchemaViolation {
  match s {
    "continuous" => SectionMarkContinuous
    "evenPage" => SectionMarkEvenPage
    "nextColumn" => SectionMarkNextColumn
    "nextPage" => SectionMarkNextPage
    "oddPage" => SectionMarkOddPage
    _ => invalid_simple_type("ST_SectionMark", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_SectionMark while enforcing the wml.xsd enumeration.
pub fn ST_SectionMark::new(s : String) -> ST_SectionMark raise SchemaViolation {
  ST_SectionMark::parse(s)
}

///|
/// Return the schema lexical value for ST_SectionMark.
pub fn ST_SectionMark::to_string(self : ST_SectionMark) -> String {
  match self {
    SectionMarkContinuous => "continuous"
    SectionMarkEvenPage => "evenPage"
    SectionMarkNextColumn => "nextColumn"
    SectionMarkNextPage => "nextPage"
    SectionMarkOddPage => "oddPage"
  }
}

///|
/// XSD simple type ST_NumberFormat — Part 1 §17.18.59 numbering-format
/// enumeration (sixty named tokens covering numerics, regional script
/// systems, and bullet/custom sentinels).
pub(all) enum ST_NumberFormat {
  /// §17.18.59 "decimal"
  NumFmtDecimal
  /// §17.18.59 "upperRoman"
  NumFmtUpperRoman
  /// §17.18.59 "lowerRoman"
  NumFmtLowerRoman
  /// §17.18.59 "upperLetter"
  NumFmtUpperLetter
  /// §17.18.59 "lowerLetter"
  NumFmtLowerLetter
  /// §17.18.59 "ordinal"
  NumFmtOrdinal
  /// §17.18.59 "cardinalText"
  NumFmtCardinalText
  /// §17.18.59 "ordinalText"
  NumFmtOrdinalText
  /// §17.18.59 "hex"
  NumFmtHex
  /// §17.18.59 "chicago"
  NumFmtChicago
  /// §17.18.59 "ideographDigital"
  NumFmtIdeographDigital
  /// §17.18.59 "japaneseCounting"
  NumFmtJapaneseCounting
  /// §17.18.59 "aiueo"
  NumFmtAiueo
  /// §17.18.59 "iroha"
  NumFmtIroha
  /// §17.18.59 "decimalFullWidth"
  NumFmtDecimalFullWidth
  /// §17.18.59 "decimalHalfWidth"
  NumFmtDecimalHalfWidth
  /// §17.18.59 "japaneseLegal"
  NumFmtJapaneseLegal
  /// §17.18.59 "japaneseDigitalTenThousand"
  NumFmtJapaneseDigitalTenThousand
  /// §17.18.59 "decimalEnclosedCircle"
  NumFmtDecimalEnclosedCircle
  /// §17.18.59 "decimalFullWidth2"
  NumFmtDecimalFullWidth2
  /// §17.18.59 "aiueoFullWidth"
  NumFmtAiueoFullWidth
  /// §17.18.59 "irohaFullWidth"
  NumFmtIrohaFullWidth
  /// §17.18.59 "decimalZero"
  NumFmtDecimalZero
  /// §17.18.59 "bullet"
  NumFmtBullet
  /// §17.18.59 "ganada"
  NumFmtGanada
  /// §17.18.59 "chosung"
  NumFmtChosung
  /// §17.18.59 "decimalEnclosedFullstop"
  NumFmtDecimalEnclosedFullstop
  /// §17.18.59 "decimalEnclosedParen"
  NumFmtDecimalEnclosedParen
  /// §17.18.59 "decimalEnclosedCircleChinese"
  NumFmtDecimalEnclosedCircleChinese
  /// §17.18.59 "ideographEnclosedCircle"
  NumFmtIdeographEnclosedCircle
  /// §17.18.59 "ideographTraditional"
  NumFmtIdeographTraditional
  /// §17.18.59 "ideographZodiac"
  NumFmtIdeographZodiac
  /// §17.18.59 "ideographZodiacTraditional"
  NumFmtIdeographZodiacTraditional
  /// §17.18.59 "taiwaneseCounting"
  NumFmtTaiwaneseCounting
  /// §17.18.59 "ideographLegalTraditional"
  NumFmtIdeographLegalTraditional
  /// §17.18.59 "taiwaneseCountingThousand"
  NumFmtTaiwaneseCountingThousand
  /// §17.18.59 "taiwaneseDigital"
  NumFmtTaiwaneseDigital
  /// §17.18.59 "chineseCounting"
  NumFmtChineseCounting
  /// §17.18.59 "chineseLegalSimplified"
  NumFmtChineseLegalSimplified
  /// §17.18.59 "chineseCountingThousand"
  NumFmtChineseCountingThousand
  /// §17.18.59 "koreanDigital"
  NumFmtKoreanDigital
  /// §17.18.59 "koreanCounting"
  NumFmtKoreanCounting
  /// §17.18.59 "koreanLegal"
  NumFmtKoreanLegal
  /// §17.18.59 "koreanDigital2"
  NumFmtKoreanDigital2
  /// §17.18.59 "vietnameseCounting"
  NumFmtVietnameseCounting
  /// §17.18.59 "russianLower"
  NumFmtRussianLower
  /// §17.18.59 "russianUpper"
  NumFmtRussianUpper
  /// §17.18.59 "none"
  NumFmtNone
  /// §17.18.59 "numberInDash"
  NumFmtNumberInDash
  /// §17.18.59 "hebrew1"
  NumFmtHebrew1
  /// §17.18.59 "hebrew2"
  NumFmtHebrew2
  /// §17.18.59 "arabicAlpha"
  NumFmtArabicAlpha
  /// §17.18.59 "arabicAbjad"
  NumFmtArabicAbjad
  /// §17.18.59 "hindiVowels"
  NumFmtHindiVowels
  /// §17.18.59 "hindiConsonants"
  NumFmtHindiConsonants
  /// §17.18.59 "hindiNumbers"
  NumFmtHindiNumbers
  /// §17.18.59 "hindiCounting"
  NumFmtHindiCounting
  /// §17.18.59 "thaiLetters"
  NumFmtThaiLetters
  /// §17.18.59 "thaiNumbers"
  NumFmtThaiNumbers
  /// §17.18.59 "thaiCounting"
  NumFmtThaiCounting
  /// §17.18.59 "bahtText"
  NumFmtBahtText
  /// §17.18.59 "dollarText"
  NumFmtDollarText
  /// §17.18.59 "custom"
  NumFmtCustom
} derive(Eq, Debug)

///|
/// Part 1 §17.18.59 — decode the numbering-format lexical token.
pub fn ST_NumberFormat::parse(
  s : String,
) -> ST_NumberFormat raise SchemaViolation {
  match s {
    "decimal" => NumFmtDecimal
    "upperRoman" => NumFmtUpperRoman
    "lowerRoman" => NumFmtLowerRoman
    "upperLetter" => NumFmtUpperLetter
    "lowerLetter" => NumFmtLowerLetter
    "ordinal" => NumFmtOrdinal
    "cardinalText" => NumFmtCardinalText
    "ordinalText" => NumFmtOrdinalText
    "hex" => NumFmtHex
    "chicago" => NumFmtChicago
    "ideographDigital" => NumFmtIdeographDigital
    "japaneseCounting" => NumFmtJapaneseCounting
    "aiueo" => NumFmtAiueo
    "iroha" => NumFmtIroha
    "decimalFullWidth" => NumFmtDecimalFullWidth
    "decimalHalfWidth" => NumFmtDecimalHalfWidth
    "japaneseLegal" => NumFmtJapaneseLegal
    "japaneseDigitalTenThousand" => NumFmtJapaneseDigitalTenThousand
    "decimalEnclosedCircle" => NumFmtDecimalEnclosedCircle
    "decimalFullWidth2" => NumFmtDecimalFullWidth2
    "aiueoFullWidth" => NumFmtAiueoFullWidth
    "irohaFullWidth" => NumFmtIrohaFullWidth
    "decimalZero" => NumFmtDecimalZero
    "bullet" => NumFmtBullet
    "ganada" => NumFmtGanada
    "chosung" => NumFmtChosung
    "decimalEnclosedFullstop" => NumFmtDecimalEnclosedFullstop
    "decimalEnclosedParen" => NumFmtDecimalEnclosedParen
    "decimalEnclosedCircleChinese" => NumFmtDecimalEnclosedCircleChinese
    "ideographEnclosedCircle" => NumFmtIdeographEnclosedCircle
    "ideographTraditional" => NumFmtIdeographTraditional
    "ideographZodiac" => NumFmtIdeographZodiac
    "ideographZodiacTraditional" => NumFmtIdeographZodiacTraditional
    "taiwaneseCounting" => NumFmtTaiwaneseCounting
    "ideographLegalTraditional" => NumFmtIdeographLegalTraditional
    "taiwaneseCountingThousand" => NumFmtTaiwaneseCountingThousand
    "taiwaneseDigital" => NumFmtTaiwaneseDigital
    "chineseCounting" => NumFmtChineseCounting
    "chineseLegalSimplified" => NumFmtChineseLegalSimplified
    "chineseCountingThousand" => NumFmtChineseCountingThousand
    "koreanDigital" => NumFmtKoreanDigital
    "koreanCounting" => NumFmtKoreanCounting
    "koreanLegal" => NumFmtKoreanLegal
    "koreanDigital2" => NumFmtKoreanDigital2
    "vietnameseCounting" => NumFmtVietnameseCounting
    "russianLower" => NumFmtRussianLower
    "russianUpper" => NumFmtRussianUpper
    "none" => NumFmtNone
    "numberInDash" => NumFmtNumberInDash
    "hebrew1" => NumFmtHebrew1
    "hebrew2" => NumFmtHebrew2
    "arabicAlpha" => NumFmtArabicAlpha
    "arabicAbjad" => NumFmtArabicAbjad
    "hindiVowels" => NumFmtHindiVowels
    "hindiConsonants" => NumFmtHindiConsonants
    "hindiNumbers" => NumFmtHindiNumbers
    "hindiCounting" => NumFmtHindiCounting
    "thaiLetters" => NumFmtThaiLetters
    "thaiNumbers" => NumFmtThaiNumbers
    "thaiCounting" => NumFmtThaiCounting
    "bahtText" => NumFmtBahtText
    "dollarText" => NumFmtDollarText
    "custom" => NumFmtCustom
    _ => invalid_simple_type("ST_NumberFormat", s, "unknown enumeration value")
  }
}

///|
pub fn ST_NumberFormat::new(
  s : String,
) -> ST_NumberFormat raise SchemaViolation {
  ST_NumberFormat::parse(s)
}

///|
pub fn ST_NumberFormat::to_string(self : ST_NumberFormat) -> String {
  match self {
    NumFmtDecimal => "decimal"
    NumFmtUpperRoman => "upperRoman"
    NumFmtLowerRoman => "lowerRoman"
    NumFmtUpperLetter => "upperLetter"
    NumFmtLowerLetter => "lowerLetter"
    NumFmtOrdinal => "ordinal"
    NumFmtCardinalText => "cardinalText"
    NumFmtOrdinalText => "ordinalText"
    NumFmtHex => "hex"
    NumFmtChicago => "chicago"
    NumFmtIdeographDigital => "ideographDigital"
    NumFmtJapaneseCounting => "japaneseCounting"
    NumFmtAiueo => "aiueo"
    NumFmtIroha => "iroha"
    NumFmtDecimalFullWidth => "decimalFullWidth"
    NumFmtDecimalHalfWidth => "decimalHalfWidth"
    NumFmtJapaneseLegal => "japaneseLegal"
    NumFmtJapaneseDigitalTenThousand => "japaneseDigitalTenThousand"
    NumFmtDecimalEnclosedCircle => "decimalEnclosedCircle"
    NumFmtDecimalFullWidth2 => "decimalFullWidth2"
    NumFmtAiueoFullWidth => "aiueoFullWidth"
    NumFmtIrohaFullWidth => "irohaFullWidth"
    NumFmtDecimalZero => "decimalZero"
    NumFmtBullet => "bullet"
    NumFmtGanada => "ganada"
    NumFmtChosung => "chosung"
    NumFmtDecimalEnclosedFullstop => "decimalEnclosedFullstop"
    NumFmtDecimalEnclosedParen => "decimalEnclosedParen"
    NumFmtDecimalEnclosedCircleChinese => "decimalEnclosedCircleChinese"
    NumFmtIdeographEnclosedCircle => "ideographEnclosedCircle"
    NumFmtIdeographTraditional => "ideographTraditional"
    NumFmtIdeographZodiac => "ideographZodiac"
    NumFmtIdeographZodiacTraditional => "ideographZodiacTraditional"
    NumFmtTaiwaneseCounting => "taiwaneseCounting"
    NumFmtIdeographLegalTraditional => "ideographLegalTraditional"
    NumFmtTaiwaneseCountingThousand => "taiwaneseCountingThousand"
    NumFmtTaiwaneseDigital => "taiwaneseDigital"
    NumFmtChineseCounting => "chineseCounting"
    NumFmtChineseLegalSimplified => "chineseLegalSimplified"
    NumFmtChineseCountingThousand => "chineseCountingThousand"
    NumFmtKoreanDigital => "koreanDigital"
    NumFmtKoreanCounting => "koreanCounting"
    NumFmtKoreanLegal => "koreanLegal"
    NumFmtKoreanDigital2 => "koreanDigital2"
    NumFmtVietnameseCounting => "vietnameseCounting"
    NumFmtRussianLower => "russianLower"
    NumFmtRussianUpper => "russianUpper"
    NumFmtNone => "none"
    NumFmtNumberInDash => "numberInDash"
    NumFmtHebrew1 => "hebrew1"
    NumFmtHebrew2 => "hebrew2"
    NumFmtArabicAlpha => "arabicAlpha"
    NumFmtArabicAbjad => "arabicAbjad"
    NumFmtHindiVowels => "hindiVowels"
    NumFmtHindiConsonants => "hindiConsonants"
    NumFmtHindiNumbers => "hindiNumbers"
    NumFmtHindiCounting => "hindiCounting"
    NumFmtThaiLetters => "thaiLetters"
    NumFmtThaiNumbers => "thaiNumbers"
    NumFmtThaiCounting => "thaiCounting"
    NumFmtBahtText => "bahtText"
    NumFmtDollarText => "dollarText"
    NumFmtCustom => "custom"
  }
}

///|
/// XSD simple type ST_PageOrientation — Part 1 §17.18.65 page
/// orientation enumeration.
pub(all) enum ST_PageOrientation {
  /// §17.18.65 "portrait"
  PageOrientationPortrait
  /// §17.18.65 "landscape"
  PageOrientationLandscape
} derive(Eq, Debug)

///|
/// Part 1 §17.18.65 — decode the page-orientation lexical token.
pub fn ST_PageOrientation::parse(
  s : String,
) -> ST_PageOrientation raise SchemaViolation {
  match s {
    "portrait" => PageOrientationPortrait
    "landscape" => PageOrientationLandscape
    _ =>
      invalid_simple_type("ST_PageOrientation", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PageOrientation::new(
  s : String,
) -> ST_PageOrientation raise SchemaViolation {
  ST_PageOrientation::parse(s)
}

///|
pub fn ST_PageOrientation::to_string(self : ST_PageOrientation) -> String {
  match self {
    PageOrientationPortrait => "portrait"
    PageOrientationLandscape => "landscape"
  }
}

///|
/// XSD simple type ST_PageBorderZOrder — Part 1 §17.18.64 page-border
/// z-order enumeration.
pub(all) enum ST_PageBorderZOrder {
  /// §17.18.64 "front"
  PageBorderZFront
  /// §17.18.64 "back"
  PageBorderZBack
} derive(Eq, Debug)

///|
/// Part 1 §17.18.64 — decode the z-order lexical token.
pub fn ST_PageBorderZOrder::parse(
  s : String,
) -> ST_PageBorderZOrder raise SchemaViolation {
  match s {
    "front" => PageBorderZFront
    "back" => PageBorderZBack
    _ =>
      invalid_simple_type("ST_PageBorderZOrder", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PageBorderZOrder::new(
  s : String,
) -> ST_PageBorderZOrder raise SchemaViolation {
  ST_PageBorderZOrder::parse(s)
}

///|
pub fn ST_PageBorderZOrder::to_string(self : ST_PageBorderZOrder) -> String {
  match self {
    PageBorderZFront => "front"
    PageBorderZBack => "back"
  }
}

///|
/// XSD simple type ST_PageBorderDisplay — Part 1 §17.18.62 page-border
/// display-target enumeration.
pub(all) enum ST_PageBorderDisplay {
  /// §17.18.62 "allPages"
  PageBorderDisplayAllPages
  /// §17.18.62 "firstPage"
  PageBorderDisplayFirstPage
  /// §17.18.62 "notFirstPage"
  PageBorderDisplayNotFirstPage
} derive(Eq, Debug)

///|
/// Part 1 §17.18.62 — decode the page-border display lexical token.
pub fn ST_PageBorderDisplay::parse(
  s : String,
) -> ST_PageBorderDisplay raise SchemaViolation {
  match s {
    "allPages" => PageBorderDisplayAllPages
    "firstPage" => PageBorderDisplayFirstPage
    "notFirstPage" => PageBorderDisplayNotFirstPage
    _ =>
      invalid_simple_type(
        "ST_PageBorderDisplay", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_PageBorderDisplay::new(
  s : String,
) -> ST_PageBorderDisplay raise SchemaViolation {
  ST_PageBorderDisplay::parse(s)
}

///|
pub fn ST_PageBorderDisplay::to_string(self : ST_PageBorderDisplay) -> String {
  match self {
    PageBorderDisplayAllPages => "allPages"
    PageBorderDisplayFirstPage => "firstPage"
    PageBorderDisplayNotFirstPage => "notFirstPage"
  }
}

///|
/// XSD simple type ST_PageBorderOffset — Part 1 §17.18.63 page-border
/// positioning-base enumeration.
pub(all) enum ST_PageBorderOffset {
  /// §17.18.63 "page"
  PageBorderOffsetPage
  /// §17.18.63 "text"
  PageBorderOffsetText
} derive(Eq, Debug)

///|
/// Part 1 §17.18.63 — decode the page-border offset lexical token.
pub fn ST_PageBorderOffset::parse(
  s : String,
) -> ST_PageBorderOffset raise SchemaViolation {
  match s {
    "page" => PageBorderOffsetPage
    "text" => PageBorderOffsetText
    _ =>
      invalid_simple_type("ST_PageBorderOffset", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PageBorderOffset::new(
  s : String,
) -> ST_PageBorderOffset raise SchemaViolation {
  ST_PageBorderOffset::parse(s)
}

///|
pub fn ST_PageBorderOffset::to_string(self : ST_PageBorderOffset) -> String {
  match self {
    PageBorderOffsetPage => "page"
    PageBorderOffsetText => "text"
  }
}

///|
/// XSD simple type ST_ChapterSep — Part 1 §17.18.6.
/// Restriction of xsd:string to the chapter-separator catalogue
/// {hyphen, period, colon, emDash, enDash}.
pub(all) enum ST_ChapterSep {
  ChapterSepHyphen
  ChapterSepPeriod
  ChapterSepColon
  ChapterSepEmDash
  ChapterSepEnDash
} derive(Eq, Debug)

///|
/// Parse the ST_ChapterSep schema lexical value.
pub fn ST_ChapterSep::parse(s : String) -> ST_ChapterSep raise SchemaViolation {
  match s {
    "hyphen" => ChapterSepHyphen
    "period" => ChapterSepPeriod
    "colon" => ChapterSepColon
    "emDash" => ChapterSepEmDash
    "enDash" => ChapterSepEnDash
    _ => invalid_simple_type("ST_ChapterSep", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_ChapterSep while enforcing the wml.xsd enumeration.
pub fn ST_ChapterSep::new(s : String) -> ST_ChapterSep raise SchemaViolation {
  ST_ChapterSep::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_ChapterSep.
pub fn ST_ChapterSep::to_string(self : ST_ChapterSep) -> String {
  match self {
    ChapterSepHyphen => "hyphen"
    ChapterSepPeriod => "period"
    ChapterSepColon => "colon"
    ChapterSepEmDash => "emDash"
    ChapterSepEnDash => "enDash"
  }
}

///|
/// XSD simple type ST_LineNumberRestart — Part 1 §17.18.47 line-number
/// restart position enumeration.
pub(all) enum ST_LineNumberRestart {
  /// §17.18.47 "newPage"
  LineNumberRestartNewPage
  /// §17.18.47 "newSection"
  LineNumberRestartNewSection
  /// §17.18.47 "continuous"
  LineNumberRestartContinuous
} derive(Eq, Debug)

///|
/// Part 1 §17.18.47 — decode the line-number-restart lexical token.
pub fn ST_LineNumberRestart::parse(
  s : String,
) -> ST_LineNumberRestart raise SchemaViolation {
  match s {
    "newPage" => LineNumberRestartNewPage
    "newSection" => LineNumberRestartNewSection
    "continuous" => LineNumberRestartContinuous
    _ =>
      invalid_simple_type(
        "ST_LineNumberRestart", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_LineNumberRestart::new(
  s : String,
) -> ST_LineNumberRestart raise SchemaViolation {
  ST_LineNumberRestart::parse(s)
}

///|
pub fn ST_LineNumberRestart::to_string(self : ST_LineNumberRestart) -> String {
  match self {
    LineNumberRestartNewPage => "newPage"
    LineNumberRestartNewSection => "newSection"
    LineNumberRestartContinuous => "continuous"
  }
}

///|
/// XSD simple type ST_VerticalJc — Part 1 §17.18.101.
/// Restriction of xsd:string to the 4-value vertical alignment enumeration.
pub(all) enum ST_VerticalJc {
  VerticalJcBoth
  VerticalJcBottom
  VerticalJcCenter
  VerticalJcTop
} derive(Eq, Debug)

///|
/// Parse the ST_VerticalJc schema lexical value.
pub fn ST_VerticalJc::parse(s : String) -> ST_VerticalJc raise SchemaViolation {
  match s {
    "both" => VerticalJcBoth
    "bottom" => VerticalJcBottom
    "center" => VerticalJcCenter
    "top" => VerticalJcTop
    _ => invalid_simple_type("ST_VerticalJc", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_VerticalJc while enforcing the wml.xsd enumeration.
pub fn ST_VerticalJc::new(s : String) -> ST_VerticalJc raise SchemaViolation {
  ST_VerticalJc::parse(s)
}

///|
/// Return the schema lexical value for ST_VerticalJc.
pub fn ST_VerticalJc::to_string(self : ST_VerticalJc) -> String {
  match self {
    VerticalJcBoth => "both"
    VerticalJcBottom => "bottom"
    VerticalJcCenter => "center"
    VerticalJcTop => "top"
  }
}

///|
/// XSD simple type ST_DocGrid — Part 1 §17.18.14.
/// Restriction of xsd:string to the document-grid kinds
/// {default, lines, linesAndChars, snapToChars}.
pub(all) enum ST_DocGrid {
  DocGridDefault
  DocGridLines
  DocGridLinesAndChars
  DocGridSnapToChars
} derive(Eq, Debug)

///|
/// Parse the ST_DocGrid schema lexical value.
pub fn ST_DocGrid::parse(s : String) -> ST_DocGrid raise SchemaViolation {
  match s {
    "default" => DocGridDefault
    "lines" => DocGridLines
    "linesAndChars" => DocGridLinesAndChars
    "snapToChars" => DocGridSnapToChars
    _ => invalid_simple_type("ST_DocGrid", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_DocGrid while enforcing the wml.xsd enumeration.
pub fn ST_DocGrid::new(s : String) -> ST_DocGrid raise SchemaViolation {
  ST_DocGrid::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_DocGrid.
pub fn ST_DocGrid::to_string(self : ST_DocGrid) -> String {
  match self {
    DocGridDefault => "default"
    DocGridLines => "lines"
    DocGridLinesAndChars => "linesAndChars"
    DocGridSnapToChars => "snapToChars"
  }
}

///|
/// XSD simple type ST_HdrFtr — Part 1 §17.18.36.
/// Restriction of xsd:string to {even, default, first}, selecting
/// which pages of a section use the parent header/footer reference.
pub(all) enum ST_HdrFtr {
  HdrFtrEven
  HdrFtrDefault
  HdrFtrFirst
} derive(Eq, Debug)

///|
/// Parse the ST_HdrFtr schema lexical value.
pub fn ST_HdrFtr::parse(s : String) -> ST_HdrFtr raise SchemaViolation {
  match s {
    "even" => HdrFtrEven
    "default" => HdrFtrDefault
    "first" => HdrFtrFirst
    _ => invalid_simple_type("ST_HdrFtr", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_HdrFtr while enforcing the wml.xsd enumeration.
pub fn ST_HdrFtr::new(s : String) -> ST_HdrFtr raise SchemaViolation {
  ST_HdrFtr::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_HdrFtr.
pub fn ST_HdrFtr::to_string(self : ST_HdrFtr) -> String {
  match self {
    HdrFtrEven => "even"
    HdrFtrDefault => "default"
    HdrFtrFirst => "first"
  }
}

///|
/// XSD simple type ST_FtnEdn — Part 1 §17.18.33.
/// Restriction of xsd:string to the footnote/endnote role catalogue
/// {normal, separator, continuationSeparator, continuationNotice}.
pub(all) enum ST_FtnEdn {
  FtnEdnNormal
  FtnEdnSeparator
  FtnEdnContinuationSeparator
  FtnEdnContinuationNotice
} derive(Eq, Debug)

///|
/// Parse the ST_FtnEdn schema lexical value.
pub fn ST_FtnEdn::parse(s : String) -> ST_FtnEdn raise SchemaViolation {
  match s {
    "normal" => FtnEdnNormal
    "separator" => FtnEdnSeparator
    "continuationSeparator" => FtnEdnContinuationSeparator
    "continuationNotice" => FtnEdnContinuationNotice
    _ => invalid_simple_type("ST_FtnEdn", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_FtnEdn while enforcing the wml.xsd enumeration.
pub fn ST_FtnEdn::new(s : String) -> ST_FtnEdn raise SchemaViolation {
  ST_FtnEdn::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_FtnEdn.
pub fn ST_FtnEdn::to_string(self : ST_FtnEdn) -> String {
  match self {
    FtnEdnNormal => "normal"
    FtnEdnSeparator => "separator"
    FtnEdnContinuationSeparator => "continuationSeparator"
    FtnEdnContinuationNotice => "continuationNotice"
  }
}

///|
/// XSD simple type ST_BrType — Part 1 §17.18.4.
/// Restriction of xsd:string to {page, column, textWrapping}, the
/// manual line/column/page break kinds. Part 4 §14.11.12 changes the
/// transitional enumeration vocabulary slightly but those compatibility
/// aliases are absorbed by callers, not the simple type itself.
pub(all) enum ST_BrType {
  BrTypePage
  BrTypeColumn
  BrTypeTextWrapping
} derive(Eq, Debug)

///|
/// Parse the ST_BrType schema lexical value.
pub fn ST_BrType::parse(s : String) -> ST_BrType raise SchemaViolation {
  match s {
    "page" => BrTypePage
    "column" => BrTypeColumn
    "textWrapping" => BrTypeTextWrapping
    _ => invalid_simple_type("ST_BrType", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_BrType while enforcing the wml.xsd enumeration.
pub fn ST_BrType::new(s : String) -> ST_BrType raise SchemaViolation {
  ST_BrType::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_BrType.
pub fn ST_BrType::to_string(self : ST_BrType) -> String {
  match self {
    BrTypePage => "page"
    BrTypeColumn => "column"
    BrTypeTextWrapping => "textWrapping"
  }
}

///|
/// XSD simple type ST_BrClear — Part 1 §17.18.3.
/// Restriction of xsd:string to {none, left, right, all}, the text
/// wrapping break restart strategies that complement ST_BrType.
pub(all) enum ST_BrClear {
  BrClearNone
  BrClearLeft
  BrClearRight
  BrClearAll
} derive(Eq, Debug)

///|
/// Parse the ST_BrClear schema lexical value.
pub fn ST_BrClear::parse(s : String) -> ST_BrClear raise SchemaViolation {
  match s {
    "none" => BrClearNone
    "left" => BrClearLeft
    "right" => BrClearRight
    "all" => BrClearAll
    _ => invalid_simple_type("ST_BrClear", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_BrClear while enforcing the wml.xsd enumeration.
pub fn ST_BrClear::new(s : String) -> ST_BrClear raise SchemaViolation {
  ST_BrClear::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_BrClear.
pub fn ST_BrClear::to_string(self : ST_BrClear) -> String {
  match self {
    BrClearNone => "none"
    BrClearLeft => "left"
    BrClearRight => "right"
    BrClearAll => "all"
  }
}

///|
/// XSD simple type ST_PTabAlignment — Part 1 §17.18.71 absolute-position
/// tab alignment enumeration.
pub(all) enum ST_PTabAlignment {
  /// §17.18.71 "left"
  PTabAlignLeft
  /// §17.18.71 "center"
  PTabAlignCenter
  /// §17.18.71 "right"
  PTabAlignRight
} derive(Eq, Debug)

///|
/// Part 1 §17.18.71 — decode the ptab-alignment lexical token.
pub fn ST_PTabAlignment::parse(
  s : String,
) -> ST_PTabAlignment raise SchemaViolation {
  match s {
    "left" => PTabAlignLeft
    "center" => PTabAlignCenter
    "right" => PTabAlignRight
    _ => invalid_simple_type("ST_PTabAlignment", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PTabAlignment::new(
  s : String,
) -> ST_PTabAlignment raise SchemaViolation {
  ST_PTabAlignment::parse(s)
}

///|
pub fn ST_PTabAlignment::to_string(self : ST_PTabAlignment) -> String {
  match self {
    PTabAlignLeft => "left"
    PTabAlignCenter => "center"
    PTabAlignRight => "right"
  }
}

///|
/// XSD simple type ST_PTabRelativeTo — Part 1 §17.18.73 absolute-position
/// tab positioning-base enumeration.
pub(all) enum ST_PTabRelativeTo {
  /// §17.18.73 "margin"
  PTabRelMargin
  /// §17.18.73 "indent"
  PTabRelIndent
} derive(Eq, Debug)

///|
/// Part 1 §17.18.73 — decode the ptab positioning-base lexical token.
pub fn ST_PTabRelativeTo::parse(
  s : String,
) -> ST_PTabRelativeTo raise SchemaViolation {
  match s {
    "margin" => PTabRelMargin
    "indent" => PTabRelIndent
    _ =>
      invalid_simple_type("ST_PTabRelativeTo", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PTabRelativeTo::new(
  s : String,
) -> ST_PTabRelativeTo raise SchemaViolation {
  ST_PTabRelativeTo::parse(s)
}

///|
pub fn ST_PTabRelativeTo::to_string(self : ST_PTabRelativeTo) -> String {
  match self {
    PTabRelMargin => "margin"
    PTabRelIndent => "indent"
  }
}

///|
/// XSD simple type ST_PTabLeader — Part 1 §17.18.72 absolute-position
/// tab leader-character enumeration.
pub(all) enum ST_PTabLeader {
  /// §17.18.72 "none"
  PTabLeaderNone
  /// §17.18.72 "dot"
  PTabLeaderDot
  /// §17.18.72 "hyphen"
  PTabLeaderHyphen
  /// §17.18.72 "underscore"
  PTabLeaderUnderscore
  /// §17.18.72 "middleDot"
  PTabLeaderMiddleDot
} derive(Eq, Debug)

///|
/// Part 1 §17.18.72 — decode the ptab leader lexical token.
pub fn ST_PTabLeader::parse(s : String) -> ST_PTabLeader raise SchemaViolation {
  match s {
    "none" => PTabLeaderNone
    "dot" => PTabLeaderDot
    "hyphen" => PTabLeaderHyphen
    "underscore" => PTabLeaderUnderscore
    "middleDot" => PTabLeaderMiddleDot
    _ => invalid_simple_type("ST_PTabLeader", s, "unknown enumeration value")
  }
}

///|
pub fn ST_PTabLeader::new(s : String) -> ST_PTabLeader raise SchemaViolation {
  ST_PTabLeader::parse(s)
}

///|
pub fn ST_PTabLeader::to_string(self : ST_PTabLeader) -> String {
  match self {
    PTabLeaderNone => "none"
    PTabLeaderDot => "dot"
    PTabLeaderHyphen => "hyphen"
    PTabLeaderUnderscore => "underscore"
    PTabLeaderMiddleDot => "middleDot"
  }
}

///|
/// XSD simple type ST_ProofErr — Part 1 §17.18.70 proofing-error
/// enumeration (spell and grammar range markers).
pub(all) enum ST_ProofErr {
  /// §17.18.70 "spellStart"
  ProofErrSpellStart
  /// §17.18.70 "spellEnd"
  ProofErrSpellEnd
  /// §17.18.70 "gramStart"
  ProofErrGramStart
  /// §17.18.70 "gramEnd"
  ProofErrGramEnd
} derive(Eq, Debug)

///|
/// Part 1 §17.18.70 — decode the proof-error lexical token.
pub fn ST_ProofErr::parse(s : String) -> ST_ProofErr raise SchemaViolation {
  match s {
    "spellStart" => ProofErrSpellStart
    "spellEnd" => ProofErrSpellEnd
    "gramStart" => ProofErrGramStart
    "gramEnd" => ProofErrGramEnd
    _ => invalid_simple_type("ST_ProofErr", s, "unknown enumeration value")
  }
}

///|
pub fn ST_ProofErr::new(s : String) -> ST_ProofErr raise SchemaViolation {
  ST_ProofErr::parse(s)
}

///|
pub fn ST_ProofErr::to_string(self : ST_ProofErr) -> String {
  match self {
    ProofErrSpellStart => "spellStart"
    ProofErrSpellEnd => "spellEnd"
    ProofErrGramStart => "gramStart"
    ProofErrGramEnd => "gramEnd"
  }
}

///|
/// XSD simple type ST_EdGrp — Part 1 §17.18.21.
/// Restriction of xsd:string to the range-permission editing-group
/// catalogue {none, everyone, administrators, contributors, editors,
/// owners, current}.
pub(all) enum ST_EdGrp {
  EdGrpNone
  EdGrpEveryone
  EdGrpAdministrators
  EdGrpContributors
  EdGrpEditors
  EdGrpOwners
  EdGrpCurrent
} derive(Eq, Debug)

///|
/// Parse the ST_EdGrp schema lexical value.
pub fn ST_EdGrp::parse(s : String) -> ST_EdGrp raise SchemaViolation {
  match s {
    "none" => EdGrpNone
    "everyone" => EdGrpEveryone
    "administrators" => EdGrpAdministrators
    "contributors" => EdGrpContributors
    "editors" => EdGrpEditors
    "owners" => EdGrpOwners
    "current" => EdGrpCurrent
    _ => invalid_simple_type("ST_EdGrp", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_EdGrp while enforcing the wml.xsd enumeration.
pub fn ST_EdGrp::new(s : String) -> ST_EdGrp raise SchemaViolation {
  ST_EdGrp::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_EdGrp.
pub fn ST_EdGrp::to_string(self : ST_EdGrp) -> String {
  match self {
    EdGrpNone => "none"
    EdGrpEveryone => "everyone"
    EdGrpAdministrators => "administrators"
    EdGrpContributors => "contributors"
    EdGrpEditors => "editors"
    EdGrpOwners => "owners"
    EdGrpCurrent => "current"
  }
}

///|
/// XSD simple type ST_Hint — Part 1 §17.18.41 font-type hint
/// enumeration. The XSD restricts the lexical space to `default` and
/// `eastAsia` (the `cs` token in the prose appears in §17.18.41 but is
/// not part of the schema's enumeration facet).
pub(all) enum ST_Hint {
  /// §17.18.41 "default"
  HintDefault
  /// §17.18.41 "eastAsia"
  HintEastAsia
} derive(Eq, Debug)

///|
/// Part 1 §17.18.41 — decode the font hint lexical token.
pub fn ST_Hint::parse(s : String) -> ST_Hint raise SchemaViolation {
  match s {
    "default" => HintDefault
    "eastAsia" => HintEastAsia
    _ => invalid_simple_type("ST_Hint", s, "unknown enumeration value")
  }
}

///|
pub fn ST_Hint::new(s : String) -> ST_Hint raise SchemaViolation {
  ST_Hint::parse(s)
}

///|
pub fn ST_Hint::to_string(self : ST_Hint) -> String {
  match self {
    HintDefault => "default"
    HintEastAsia => "eastAsia"
  }
}

///|
/// XSD simple type ST_Theme — Part 1 §17.18.96.
/// Restriction of xsd:string to the 8-value theme font enumeration.
pub(all) enum ST_Theme {
  ThemeMajorAscii
  ThemeMajorBidi
  ThemeMajorEastAsia
  ThemeMajorHAnsi
  ThemeMinorAscii
  ThemeMinorBidi
  ThemeMinorEastAsia
  ThemeMinorHAnsi
} derive(Eq, Debug)

///|
/// Parse the ST_Theme schema lexical value.
pub fn ST_Theme::parse(s : String) -> ST_Theme raise SchemaViolation {
  match s {
    "majorAscii" => ThemeMajorAscii
    "majorBidi" => ThemeMajorBidi
    "majorEastAsia" => ThemeMajorEastAsia
    "majorHAnsi" => ThemeMajorHAnsi
    "minorAscii" => ThemeMinorAscii
    "minorBidi" => ThemeMinorBidi
    "minorEastAsia" => ThemeMinorEastAsia
    "minorHAnsi" => ThemeMinorHAnsi
    _ => invalid_simple_type("ST_Theme", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_Theme while enforcing the wml.xsd enumeration.
pub fn ST_Theme::new(s : String) -> ST_Theme raise SchemaViolation {
  ST_Theme::parse(s)
}

///|
/// Return the schema lexical value for ST_Theme.
pub fn ST_Theme::to_string(self : ST_Theme) -> String {
  match self {
    ThemeMajorAscii => "majorAscii"
    ThemeMajorBidi => "majorBidi"
    ThemeMajorEastAsia => "majorEastAsia"
    ThemeMajorHAnsi => "majorHAnsi"
    ThemeMinorAscii => "minorAscii"
    ThemeMinorBidi => "minorBidi"
    ThemeMinorEastAsia => "minorEastAsia"
    ThemeMinorHAnsi => "minorHAnsi"
  }
}

///|
/// XSD simple type ST_RubyAlign — Part 1 §17.18.75.
/// Restriction of xsd:string to the 6-value phonetic guide-text alignment
/// enumeration.
pub(all) enum ST_RubyAlign {
  RubyAlignCenter
  RubyAlignDistributeLetter
  RubyAlignDistributeSpace
  RubyAlignLeft
  RubyAlignRight
  RubyAlignRightVertical
} derive(Eq, Debug)

///|
/// Parse the ST_RubyAlign schema lexical value.
pub fn ST_RubyAlign::parse(s : String) -> ST_RubyAlign raise SchemaViolation {
  match s {
    "center" => RubyAlignCenter
    "distributeLetter" => RubyAlignDistributeLetter
    "distributeSpace" => RubyAlignDistributeSpace
    "left" => RubyAlignLeft
    "right" => RubyAlignRight
    "rightVertical" => RubyAlignRightVertical
    _ => invalid_simple_type("ST_RubyAlign", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_RubyAlign while enforcing the wml.xsd enumeration.
pub fn ST_RubyAlign::new(s : String) -> ST_RubyAlign raise SchemaViolation {
  ST_RubyAlign::parse(s)
}

///|
/// Return the schema lexical value for ST_RubyAlign.
pub fn ST_RubyAlign::to_string(self : ST_RubyAlign) -> String {
  match self {
    RubyAlignCenter => "center"
    RubyAlignDistributeLetter => "distributeLetter"
    RubyAlignDistributeSpace => "distributeSpace"
    RubyAlignLeft => "left"
    RubyAlignRight => "right"
    RubyAlignRightVertical => "rightVertical"
  }
}

///|
/// XSD simple type ST_Lock — Part 1 §17.18.49 SDT locking-behaviour
/// enumeration.
pub(all) enum ST_Lock {
  /// §17.18.49 "sdtLocked"
  LockSdtLocked
  /// §17.18.49 "contentLocked"
  LockContentLocked
  /// §17.18.49 "unlocked"
  LockUnlocked
  /// §17.18.49 "sdtContentLocked"
  LockSdtContentLocked
} derive(Eq, Debug)

///|
/// Part 1 §17.18.49 — decode the SDT lock lexical token.
pub fn ST_Lock::parse(s : String) -> ST_Lock raise SchemaViolation {
  match s {
    "sdtLocked" => LockSdtLocked
    "contentLocked" => LockContentLocked
    "unlocked" => LockUnlocked
    "sdtContentLocked" => LockSdtContentLocked
    _ => invalid_simple_type("ST_Lock", s, "unknown enumeration value")
  }
}

///|
pub fn ST_Lock::new(s : String) -> ST_Lock raise SchemaViolation {
  ST_Lock::parse(s)
}

///|
pub fn ST_Lock::to_string(self : ST_Lock) -> String {
  match self {
    LockSdtLocked => "sdtLocked"
    LockContentLocked => "contentLocked"
    LockUnlocked => "unlocked"
    LockSdtContentLocked => "sdtContentLocked"
  }
}

///|
/// XSD simple type ST_SdtDateMappingType — Part 1 §17.18.76.
/// Restriction of xsd:string to {date, dateTime, text} for SDT date storage.
pub(all) enum ST_SdtDateMappingType {
  SdtDateMappingTypeDate
  SdtDateMappingTypeDateTime
  SdtDateMappingTypeText
} derive(Eq, Debug)

///|
/// Parse the ST_SdtDateMappingType schema lexical value.
pub fn ST_SdtDateMappingType::parse(
  s : String,
) -> ST_SdtDateMappingType raise SchemaViolation {
  match s {
    "date" => SdtDateMappingTypeDate
    "dateTime" => SdtDateMappingTypeDateTime
    "text" => SdtDateMappingTypeText
    _ =>
      invalid_simple_type(
        "ST_SdtDateMappingType", s, "unknown enumeration value",
      )
  }
}

///|
/// Construct ST_SdtDateMappingType while enforcing the wml.xsd enumeration.
pub fn ST_SdtDateMappingType::new(
  s : String,
) -> ST_SdtDateMappingType raise SchemaViolation {
  ST_SdtDateMappingType::parse(s)
}

///|
/// Return the schema lexical value for ST_SdtDateMappingType.
pub fn ST_SdtDateMappingType::to_string(self : ST_SdtDateMappingType) -> String {
  match self {
    SdtDateMappingTypeDate => "date"
    SdtDateMappingTypeDateTime => "dateTime"
    SdtDateMappingTypeText => "text"
  }
}

///|
/// XSD simple type ST_Direction — Part 1 §17.18.12.
/// Restriction of xsd:string to {ltr, rtl}, encoding the bidirectional
/// reading direction selected by the parent element.
pub(all) enum ST_Direction {
  DirectionLtr
  DirectionRtl
} derive(Eq, Debug)

///|
/// Parse the ST_Direction schema lexical value.
pub fn ST_Direction::parse(s : String) -> ST_Direction raise SchemaViolation {
  match s {
    "ltr" => DirectionLtr
    "rtl" => DirectionRtl
    _ => invalid_simple_type("ST_Direction", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_Direction while enforcing the wml.xsd enumeration.
pub fn ST_Direction::new(s : String) -> ST_Direction raise SchemaViolation {
  ST_Direction::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_Direction.
pub fn ST_Direction::to_string(self : ST_Direction) -> String {
  match self {
    DirectionLtr => "ltr"
    DirectionRtl => "rtl"
  }
}

///|
/// XSD simple type ST_TblWidth — Part 1 §17.18.90.
/// Restriction of xsd:string to the 4-value table-width unit enumeration.
pub(all) enum ST_TblWidth {
  TblWidthAuto
  TblWidthDxa
  TblWidthNil
  TblWidthPct
} derive(Eq, Debug)

///|
/// Parse the ST_TblWidth schema lexical value.
pub fn ST_TblWidth::parse(s : String) -> ST_TblWidth raise SchemaViolation {
  match s {
    "auto" => TblWidthAuto
    "dxa" => TblWidthDxa
    "nil" => TblWidthNil
    "pct" => TblWidthPct
    _ => invalid_simple_type("ST_TblWidth", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_TblWidth while enforcing the wml.xsd enumeration.
pub fn ST_TblWidth::new(s : String) -> ST_TblWidth raise SchemaViolation {
  ST_TblWidth::parse(s)
}

///|
/// Return the schema lexical value for ST_TblWidth.
pub fn ST_TblWidth::to_string(self : ST_TblWidth) -> String {
  match self {
    TblWidthAuto => "auto"
    TblWidthDxa => "dxa"
    TblWidthNil => "nil"
    TblWidthPct => "pct"
  }
}

///|
/// XSD simple type ST_MeasurementOrPercent — Part 1 §17.18.107 table
/// measurement union: either an `ST_DecimalNumberOrPercent` (a signed
/// `<decimal>%` literal whose magnitude is preserved as 1000ths of a
/// percent for integer comparisons) or an `ST_UniversalMeasure` (signed
/// decimal magnitude + universal-measure unit). The typed
/// discriminator records which branch produced the value so the lexical
/// form is not lost.
pub enum ST_MeasurementOrPercent {
  /// §17.18.107 percent branch — magnitude in 1000ths of a percent
  /// (e.g. `"12.345%"` → 12345).
  MeasOrPctPercent(Int64)
  /// §17.18.107 universal-measure branch — typed magnitude + unit.
  MeasOrPctMeasure(WmlUniversalMeasure)
  /// §22.9.2.4 ST_DecimalNumberOrPercent → ST_UnqualifiedPercentage
  /// branch — a bare signed integer.  In a measurement context
  /// (e.g. `<w:tcW w:type="dxa" w:w="3000">`) the integer is a count
  /// of twentieths-of-a-point; the unit is supplied by the sibling
  /// `@type` attribute, so only the raw integer is stored here.
  MeasOrPctDecimal(Int64)
} derive(Eq, Debug)

///|
/// Part 1 §17.18.107 — decode the union lexical form.
pub fn ST_MeasurementOrPercent::parse(
  s : String,
) -> ST_MeasurementOrPercent raise SchemaViolation {
  if is_wml_percentage(s) {
    let magnitude_text = s.unsafe_substring(start=0, end=s.length() - 1)
    MeasOrPctPercent(parse_wml_decimal_scaled(magnitude_text, 3))
  } else if is_wml_universal_measure(s, positive=false) {
    MeasOrPctMeasure(WmlUniversalMeasure::parse(s))
  } else if is_wml_signed_int(s) {
    // §22.9.2.4 ST_DecimalNumberOrPercent → ST_UnqualifiedPercentage
    // — a bare signed integer.  `<w:tcW w:type="dxa" w:w="3000">`
    // and `<w:gridCol>`-style widths use this form.
    MeasOrPctDecimal(
      parse_wml_signed_int("ST_MeasurementOrPercent", s).to_int64(),
    )
  } else {
    invalid_simple_type(
      "ST_MeasurementOrPercent", s, "expected ST_DecimalNumberOrPercent or ST_UniversalMeasure",
    )
  }
}

///|
pub fn ST_MeasurementOrPercent::new(
  s : String,
) -> ST_MeasurementOrPercent raise SchemaViolation {
  ST_MeasurementOrPercent::parse(s)
}

///|
/// Render the union value back to its canonical lexical form.
pub fn ST_MeasurementOrPercent::to_string(
  self : ST_MeasurementOrPercent,
) -> String {
  match self {
    MeasOrPctPercent(thousandths) =>
      format_wml_scaled_decimal(thousandths, 3) + "%"
    MeasOrPctMeasure(measure) => measure.to_string()
    MeasOrPctDecimal(n) => n.to_string()
  }
}

///|
/// XSD simple type ST_Merge — Part 1 §17.18.57 merged-cell role
/// enumeration (continue an existing merge or restart a new one).
pub(all) enum ST_Merge {
  /// §17.18.57 "continue"
  MergeContinue
  /// §17.18.57 "restart"
  MergeRestart
} derive(Eq, Debug)

///|
/// Part 1 §17.18.57 — decode the cell-merge lexical token.
pub fn ST_Merge::parse(s : String) -> ST_Merge raise SchemaViolation {
  match s {
    "continue" => MergeContinue
    "restart" => MergeRestart
    _ => invalid_simple_type("ST_Merge", s, "unknown enumeration value")
  }
}

///|
pub fn ST_Merge::new(s : String) -> ST_Merge raise SchemaViolation {
  ST_Merge::parse(s)
}

///|
pub fn ST_Merge::to_string(self : ST_Merge) -> String {
  match self {
    MergeContinue => "continue"
    MergeRestart => "restart"
  }
}

///|
/// XSD simple type ST_TblLayoutType — Part 1 §17.18.87.
/// Restriction of xsd:string to {autofit, fixed} for table layout algorithm.
pub(all) enum ST_TblLayoutType {
  TblLayoutTypeAutofit
  TblLayoutTypeFixed
} derive(Eq, Debug)

///|
/// Parse the ST_TblLayoutType schema lexical value.
pub fn ST_TblLayoutType::parse(
  s : String,
) -> ST_TblLayoutType raise SchemaViolation {
  match s {
    "autofit" => TblLayoutTypeAutofit
    "fixed" => TblLayoutTypeFixed
    _ => invalid_simple_type("ST_TblLayoutType", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_TblLayoutType while enforcing the wml.xsd enumeration.
pub fn ST_TblLayoutType::new(
  s : String,
) -> ST_TblLayoutType raise SchemaViolation {
  ST_TblLayoutType::parse(s)
}

///|
/// Return the schema lexical value for ST_TblLayoutType.
pub fn ST_TblLayoutType::to_string(self : ST_TblLayoutType) -> String {
  match self {
    TblLayoutTypeAutofit => "autofit"
    TblLayoutTypeFixed => "fixed"
  }
}

///|
/// XSD simple type ST_TblOverlap — Part 1 §17.18.88.
/// Restriction of xsd:string to {never, overlap} for floating table overlap.
pub(all) enum ST_TblOverlap {
  TblOverlapNever
  TblOverlapOverlap
} derive(Eq, Debug)

///|
/// Parse the ST_TblOverlap schema lexical value.
pub fn ST_TblOverlap::parse(s : String) -> ST_TblOverlap raise SchemaViolation {
  match s {
    "never" => TblOverlapNever
    "overlap" => TblOverlapOverlap
    _ => invalid_simple_type("ST_TblOverlap", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_TblOverlap while enforcing the wml.xsd enumeration.
pub fn ST_TblOverlap::new(s : String) -> ST_TblOverlap raise SchemaViolation {
  ST_TblOverlap::parse(s)
}

///|
/// Return the schema lexical value for ST_TblOverlap.
pub fn ST_TblOverlap::to_string(self : ST_TblOverlap) -> String {
  match self {
    TblOverlapNever => "never"
    TblOverlapOverlap => "overlap"
  }
}

///|
/// XSD simple type ST_FtnPos — Part 1 §17.18.34.
/// Restriction of xsd:string to the footnote-positioning catalogue
/// {pageBottom, beneathText, sectEnd, docEnd}.
pub(all) enum ST_FtnPos {
  FtnPosPageBottom
  FtnPosBeneathText
  FtnPosSectEnd
  FtnPosDocEnd
} derive(Eq, Debug)

///|
/// Parse the ST_FtnPos schema lexical value.
pub fn ST_FtnPos::parse(s : String) -> ST_FtnPos raise SchemaViolation {
  match s {
    "pageBottom" => FtnPosPageBottom
    "beneathText" => FtnPosBeneathText
    "sectEnd" => FtnPosSectEnd
    "docEnd" => FtnPosDocEnd
    _ => invalid_simple_type("ST_FtnPos", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_FtnPos while enforcing the wml.xsd enumeration.
pub fn ST_FtnPos::new(s : String) -> ST_FtnPos raise SchemaViolation {
  ST_FtnPos::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_FtnPos.
pub fn ST_FtnPos::to_string(self : ST_FtnPos) -> String {
  match self {
    FtnPosPageBottom => "pageBottom"
    FtnPosBeneathText => "beneathText"
    FtnPosSectEnd => "sectEnd"
    FtnPosDocEnd => "docEnd"
  }
}

///|
/// XSD simple type ST_EdnPos — Part 1 §17.18.22.
/// Restriction of xsd:string to {sectEnd, docEnd}, identifying the
/// endnote positioning scope.
pub(all) enum ST_EdnPos {
  EdnPosSectEnd
  EdnPosDocEnd
} derive(Eq, Debug)

///|
/// Parse the ST_EdnPos schema lexical value.
pub fn ST_EdnPos::parse(s : String) -> ST_EdnPos raise SchemaViolation {
  match s {
    "sectEnd" => EdnPosSectEnd
    "docEnd" => EdnPosDocEnd
    _ => invalid_simple_type("ST_EdnPos", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_EdnPos while enforcing the wml.xsd enumeration.
pub fn ST_EdnPos::new(s : String) -> ST_EdnPos raise SchemaViolation {
  ST_EdnPos::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_EdnPos.
pub fn ST_EdnPos::to_string(self : ST_EdnPos) -> String {
  match self {
    EdnPosSectEnd => "sectEnd"
    EdnPosDocEnd => "docEnd"
  }
}

///|
/// XSD simple type ST_RestartNumber — Part 1 §17.18.74.
/// Restriction of xsd:string to {continuous, eachPage, eachSect}
/// for footnote/endnote auto-numbering restart locations.
pub(all) enum ST_RestartNumber {
  RestartNumberContinuous
  RestartNumberEachPage
  RestartNumberEachSect
} derive(Eq, Debug)

///|
/// Parse the ST_RestartNumber schema lexical value.
pub fn ST_RestartNumber::parse(
  s : String,
) -> ST_RestartNumber raise SchemaViolation {
  match s {
    "continuous" => RestartNumberContinuous
    "eachPage" => RestartNumberEachPage
    "eachSect" => RestartNumberEachSect
    _ => invalid_simple_type("ST_RestartNumber", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_RestartNumber while enforcing the wml.xsd enumeration.
pub fn ST_RestartNumber::new(
  s : String,
) -> ST_RestartNumber raise SchemaViolation {
  ST_RestartNumber::parse(s)
}

///|
/// Return the schema lexical value for ST_RestartNumber.
pub fn ST_RestartNumber::to_string(self : ST_RestartNumber) -> String {
  match self {
    RestartNumberContinuous => "continuous"
    RestartNumberEachPage => "eachPage"
    RestartNumberEachSect => "eachSect"
  }
}

///|
/// XSD simple type ST_MailMergeSourceType — Part 1 §17.18.56 ODSO
/// data-source-type enumeration (nine values).
pub(all) enum ST_MailMergeSourceType {
  /// §17.18.56 "database"
  MailMergeSrcDatabase
  /// §17.18.56 "addressBook"
  MailMergeSrcAddressBook
  /// §17.18.56 "document1"
  MailMergeSrcDocument1
  /// §17.18.56 "document2"
  MailMergeSrcDocument2
  /// §17.18.56 "text"
  MailMergeSrcText
  /// §17.18.56 "email"
  MailMergeSrcEmail
  /// §17.18.56 "native"
  MailMergeSrcNative
  /// §17.18.56 "legacy"
  MailMergeSrcLegacy
  /// §17.18.56 "master"
  MailMergeSrcMaster
} derive(Eq, Debug)

///|
/// Part 1 §17.18.56 — decode the ODSO source-type lexical token.
pub fn ST_MailMergeSourceType::parse(
  s : String,
) -> ST_MailMergeSourceType raise SchemaViolation {
  match s {
    "database" => MailMergeSrcDatabase
    "addressBook" => MailMergeSrcAddressBook
    "document1" => MailMergeSrcDocument1
    "document2" => MailMergeSrcDocument2
    "text" => MailMergeSrcText
    "email" => MailMergeSrcEmail
    "native" => MailMergeSrcNative
    "legacy" => MailMergeSrcLegacy
    "master" => MailMergeSrcMaster
    _ =>
      invalid_simple_type(
        "ST_MailMergeSourceType", s, "unknown enumeration value",
      )
  }
}

///|
pub fn ST_MailMergeSourceType::new(
  s : String,
) -> ST_MailMergeSourceType raise SchemaViolation {
  ST_MailMergeSourceType::parse(s)
}

///|
pub fn ST_MailMergeSourceType::to_string(
  self : ST_MailMergeSourceType,
) -> String {
  match self {
    MailMergeSrcDatabase => "database"
    MailMergeSrcAddressBook => "addressBook"
    MailMergeSrcDocument1 => "document1"
    MailMergeSrcDocument2 => "document2"
    MailMergeSrcText => "text"
    MailMergeSrcEmail => "email"
    MailMergeSrcNative => "native"
    MailMergeSrcLegacy => "legacy"
    MailMergeSrcMaster => "master"
  }
}

///|
/// XSD simple type ST_TargetScreenSz — Part 1 §17.18.86.
/// Restriction of xsd:string to the 11-value target screen-size enumeration
/// (width x height in pixels).
pub(all) enum ST_TargetScreenSz {
  TargetScreenSz544x376
  TargetScreenSz640x480
  TargetScreenSz720x512
  TargetScreenSz800x600
  TargetScreenSz1024x768
  TargetScreenSz1152x882
  TargetScreenSz1152x900
  TargetScreenSz1280x1024
  TargetScreenSz1600x1200
  TargetScreenSz1800x1440
  TargetScreenSz1920x1200
} derive(Eq, Debug)

///|
/// Parse the ST_TargetScreenSz schema lexical value.
pub fn ST_TargetScreenSz::parse(
  s : String,
) -> ST_TargetScreenSz raise SchemaViolation {
  match s {
    "544x376" => TargetScreenSz544x376
    "640x480" => TargetScreenSz640x480
    "720x512" => TargetScreenSz720x512
    "800x600" => TargetScreenSz800x600
    "1024x768" => TargetScreenSz1024x768
    "1152x882" => TargetScreenSz1152x882
    "1152x900" => TargetScreenSz1152x900
    "1280x1024" => TargetScreenSz1280x1024
    "1600x1200" => TargetScreenSz1600x1200
    "1800x1440" => TargetScreenSz1800x1440
    "1920x1200" => TargetScreenSz1920x1200
    _ =>
      invalid_simple_type("ST_TargetScreenSz", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_TargetScreenSz while enforcing the wml.xsd enumeration.
pub fn ST_TargetScreenSz::new(
  s : String,
) -> ST_TargetScreenSz raise SchemaViolation {
  ST_TargetScreenSz::parse(s)
}

///|
/// Return the schema lexical value for ST_TargetScreenSz.
pub fn ST_TargetScreenSz::to_string(self : ST_TargetScreenSz) -> String {
  match self {
    TargetScreenSz544x376 => "544x376"
    TargetScreenSz640x480 => "640x480"
    TargetScreenSz720x512 => "720x512"
    TargetScreenSz800x600 => "800x600"
    TargetScreenSz1024x768 => "1024x768"
    TargetScreenSz1152x882 => "1152x882"
    TargetScreenSz1152x900 => "1152x900"
    TargetScreenSz1280x1024 => "1280x1024"
    TargetScreenSz1600x1200 => "1600x1200"
    TargetScreenSz1800x1440 => "1800x1440"
    TargetScreenSz1920x1200 => "1920x1200"
  }
}

///|
/// XSD simple type ST_CharacterSpacing — Part 1 §17.18.7.
/// Restriction of xsd:string to the full-width whitespace compression
/// policies {doNotCompress, compressPunctuation,
/// compressPunctuationAndJapaneseKana}.
pub(all) enum ST_CharacterSpacing {
  CharacterSpacingDoNotCompress
  CharacterSpacingCompressPunctuation
  CharacterSpacingCompressPunctuationAndJapaneseKana
} derive(Eq, Debug)

///|
/// Parse the ST_CharacterSpacing schema lexical value.
pub fn ST_CharacterSpacing::parse(
  s : String,
) -> ST_CharacterSpacing raise SchemaViolation {
  match s {
    "doNotCompress" => CharacterSpacingDoNotCompress
    "compressPunctuation" => CharacterSpacingCompressPunctuation
    "compressPunctuationAndJapaneseKana" =>
      CharacterSpacingCompressPunctuationAndJapaneseKana
    _ =>
      invalid_simple_type("ST_CharacterSpacing", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_CharacterSpacing while enforcing the wml.xsd
/// enumeration.
pub fn ST_CharacterSpacing::new(
  s : String,
) -> ST_CharacterSpacing raise SchemaViolation {
  ST_CharacterSpacing::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_CharacterSpacing.
pub fn ST_CharacterSpacing::to_string(self : ST_CharacterSpacing) -> String {
  match self {
    CharacterSpacingDoNotCompress => "doNotCompress"
    CharacterSpacingCompressPunctuation => "compressPunctuation"
    CharacterSpacingCompressPunctuationAndJapaneseKana =>
      "compressPunctuationAndJapaneseKana"
  }
}

///|
/// XSD simple type ST_WmlColorSchemeIndex — Part 1 §17.18.103.
/// Restriction of xsd:string to the 12-value theme color reference
/// enumeration (clrSchemeMapping attribute values).
pub(all) enum ST_WmlColorSchemeIndex {
  WmlColorSchemeIndexAccent1
  WmlColorSchemeIndexAccent2
  WmlColorSchemeIndexAccent3
  WmlColorSchemeIndexAccent4
  WmlColorSchemeIndexAccent5
  WmlColorSchemeIndexAccent6
  WmlColorSchemeIndexDark1
  WmlColorSchemeIndexDark2
  WmlColorSchemeIndexFollowedHyperlink
  WmlColorSchemeIndexHyperlink
  WmlColorSchemeIndexLight1
  WmlColorSchemeIndexLight2
} derive(Eq, Debug)

///|
/// Parse the ST_WmlColorSchemeIndex schema lexical value.
pub fn ST_WmlColorSchemeIndex::parse(
  s : String,
) -> ST_WmlColorSchemeIndex raise SchemaViolation {
  match s {
    "accent1" => WmlColorSchemeIndexAccent1
    "accent2" => WmlColorSchemeIndexAccent2
    "accent3" => WmlColorSchemeIndexAccent3
    "accent4" => WmlColorSchemeIndexAccent4
    "accent5" => WmlColorSchemeIndexAccent5
    "accent6" => WmlColorSchemeIndexAccent6
    "dark1" => WmlColorSchemeIndexDark1
    "dark2" => WmlColorSchemeIndexDark2
    "followedHyperlink" => WmlColorSchemeIndexFollowedHyperlink
    "hyperlink" => WmlColorSchemeIndexHyperlink
    "light1" => WmlColorSchemeIndexLight1
    "light2" => WmlColorSchemeIndexLight2
    _ =>
      invalid_simple_type(
        "ST_WmlColorSchemeIndex", s, "unknown enumeration value",
      )
  }
}

///|
/// Construct ST_WmlColorSchemeIndex while enforcing the wml.xsd enumeration.
pub fn ST_WmlColorSchemeIndex::new(
  s : String,
) -> ST_WmlColorSchemeIndex raise SchemaViolation {
  ST_WmlColorSchemeIndex::parse(s)
}

///|
/// Return the schema lexical value for ST_WmlColorSchemeIndex.
pub fn ST_WmlColorSchemeIndex::to_string(
  self : ST_WmlColorSchemeIndex,
) -> String {
  match self {
    WmlColorSchemeIndexAccent1 => "accent1"
    WmlColorSchemeIndexAccent2 => "accent2"
    WmlColorSchemeIndexAccent3 => "accent3"
    WmlColorSchemeIndexAccent4 => "accent4"
    WmlColorSchemeIndexAccent5 => "accent5"
    WmlColorSchemeIndexAccent6 => "accent6"
    WmlColorSchemeIndexDark1 => "dark1"
    WmlColorSchemeIndexDark2 => "dark2"
    WmlColorSchemeIndexFollowedHyperlink => "followedHyperlink"
    WmlColorSchemeIndexHyperlink => "hyperlink"
    WmlColorSchemeIndexLight1 => "light1"
    WmlColorSchemeIndexLight2 => "light2"
  }
}

///|
/// XSD simple type ST_StyleSort — Part 1 §17.18.82.
/// Restriction of xsd:string to the 6-value style-pane sort method
/// enumeration.
pub(all) enum ST_StyleSort {
  StyleSortBasedOn
  StyleSortDefault
  StyleSortFont
  StyleSortName
  StyleSortPriority
  StyleSortType
} derive(Eq, Debug)

///|
/// Parse the ST_StyleSort schema lexical value.
pub fn ST_StyleSort::parse(s : String) -> ST_StyleSort raise SchemaViolation {
  match s {
    "basedOn" => StyleSortBasedOn
    "default" => StyleSortDefault
    "font" => StyleSortFont
    "name" => StyleSortName
    "priority" => StyleSortPriority
    "type" => StyleSortType
    _ => invalid_simple_type("ST_StyleSort", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_StyleSort while enforcing the wml.xsd enumeration.
pub fn ST_StyleSort::new(s : String) -> ST_StyleSort raise SchemaViolation {
  ST_StyleSort::parse(s)
}

///|
/// Return the schema lexical value for ST_StyleSort.
pub fn ST_StyleSort::to_string(self : ST_StyleSort) -> String {
  match self {
    StyleSortBasedOn => "basedOn"
    StyleSortDefault => "default"
    StyleSortFont => "font"
    StyleSortName => "name"
    StyleSortPriority => "priority"
    StyleSortType => "type"
  }
}

///|
/// XSD simple type ST_FrameScrollbar — Part 1 §17.18.32.
/// Restriction of xsd:string to {on, off, auto}, the per-frame
/// scrollbar visibility policy.
pub(all) enum ST_FrameScrollbar {
  FrameScrollbarOn
  FrameScrollbarOff
  FrameScrollbarAuto
} derive(Eq, Debug)

///|
/// Parse the ST_FrameScrollbar schema lexical value.
pub fn ST_FrameScrollbar::parse(
  s : String,
) -> ST_FrameScrollbar raise SchemaViolation {
  match s {
    "on" => FrameScrollbarOn
    "off" => FrameScrollbarOff
    "auto" => FrameScrollbarAuto
    _ =>
      invalid_simple_type("ST_FrameScrollbar", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_FrameScrollbar while enforcing the wml.xsd
/// enumeration.
pub fn ST_FrameScrollbar::new(
  s : String,
) -> ST_FrameScrollbar raise SchemaViolation {
  ST_FrameScrollbar::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_FrameScrollbar.
pub fn ST_FrameScrollbar::to_string(self : ST_FrameScrollbar) -> String {
  match self {
    FrameScrollbarOn => "on"
    FrameScrollbarOff => "off"
    FrameScrollbarAuto => "auto"
  }
}

///|
/// XSD simple type ST_FrameLayout — Part 1 §17.18.31.
/// Restriction of xsd:string to {rows, cols, none}, the frameset
/// stacking direction (or the "no frames" sentinel).
pub(all) enum ST_FrameLayout {
  FrameLayoutRows
  FrameLayoutCols
  FrameLayoutNone
} derive(Eq, Debug)

///|
/// Parse the ST_FrameLayout schema lexical value.
pub fn ST_FrameLayout::parse(
  s : String,
) -> ST_FrameLayout raise SchemaViolation {
  match s {
    "rows" => FrameLayoutRows
    "cols" => FrameLayoutCols
    "none" => FrameLayoutNone
    _ => invalid_simple_type("ST_FrameLayout", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_FrameLayout while enforcing the wml.xsd enumeration.
pub fn ST_FrameLayout::new(s : String) -> ST_FrameLayout raise SchemaViolation {
  ST_FrameLayout::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_FrameLayout.
pub fn ST_FrameLayout::to_string(self : ST_FrameLayout) -> String {
  match self {
    FrameLayoutRows => "rows"
    FrameLayoutCols => "cols"
    FrameLayoutNone => "none"
  }
}

///|
/// XSD simple type ST_LevelSuffix — Part 1 §17.18.46 numbering-level
/// suffix enumeration (tab/space/nothing between marker and text).
pub(all) enum ST_LevelSuffix {
  /// §17.18.46 "tab"
  LevelSuffixTab
  /// §17.18.46 "space"
  LevelSuffixSpace
  /// §17.18.46 "nothing"
  LevelSuffixNothing
} derive(Eq, Debug)

///|
/// Part 1 §17.18.46 — decode the level-suffix lexical token.
pub fn ST_LevelSuffix::parse(
  s : String,
) -> ST_LevelSuffix raise SchemaViolation {
  match s {
    "tab" => LevelSuffixTab
    "space" => LevelSuffixSpace
    "nothing" => LevelSuffixNothing
    _ => invalid_simple_type("ST_LevelSuffix", s, "unknown enumeration value")
  }
}

///|
pub fn ST_LevelSuffix::new(s : String) -> ST_LevelSuffix raise SchemaViolation {
  ST_LevelSuffix::parse(s)
}

///|
pub fn ST_LevelSuffix::to_string(self : ST_LevelSuffix) -> String {
  match self {
    LevelSuffixTab => "tab"
    LevelSuffixSpace => "space"
    LevelSuffixNothing => "nothing"
  }
}

///|
/// XSD simple type ST_MultiLevelType — Part 1 §17.18.58
/// abstract-numbering type-hint enumeration.
pub(all) enum ST_MultiLevelType {
  /// §17.18.58 "singleLevel"
  MultiLevelSingleLevel
  /// §17.18.58 "multilevel"
  MultiLevelMultilevel
  /// §17.18.58 "hybridMultilevel"
  MultiLevelHybridMultilevel
} derive(Eq, Debug)

///|
/// Part 1 §17.18.58 — decode the multi-level type lexical token.
pub fn ST_MultiLevelType::parse(
  s : String,
) -> ST_MultiLevelType raise SchemaViolation {
  match s {
    "singleLevel" => MultiLevelSingleLevel
    "multilevel" => MultiLevelMultilevel
    "hybridMultilevel" => MultiLevelHybridMultilevel
    _ =>
      invalid_simple_type("ST_MultiLevelType", s, "unknown enumeration value")
  }
}

///|
pub fn ST_MultiLevelType::new(
  s : String,
) -> ST_MultiLevelType raise SchemaViolation {
  ST_MultiLevelType::parse(s)
}

///|
pub fn ST_MultiLevelType::to_string(self : ST_MultiLevelType) -> String {
  match self {
    MultiLevelSingleLevel => "singleLevel"
    MultiLevelMultilevel => "multilevel"
    MultiLevelHybridMultilevel => "hybridMultilevel"
  }
}

///|
/// XSD simple type ST_TblStyleOverrideType — Part 1 §17.18.89.
/// Restriction of xsd:string to the 13-value conditional table style
/// formatting target enumeration.
pub(all) enum ST_TblStyleOverrideType {
  TblStyleOverrideTypeBand1Horz
  TblStyleOverrideTypeBand1Vert
  TblStyleOverrideTypeBand2Horz
  TblStyleOverrideTypeBand2Vert
  TblStyleOverrideTypeFirstCol
  TblStyleOverrideTypeFirstRow
  TblStyleOverrideTypeLastCol
  TblStyleOverrideTypeLastRow
  TblStyleOverrideTypeNeCell
  TblStyleOverrideTypeNwCell
  TblStyleOverrideTypeSeCell
  TblStyleOverrideTypeSwCell
  TblStyleOverrideTypeWholeTable
} derive(Eq, Debug)

///|
/// Parse the ST_TblStyleOverrideType schema lexical value.
pub fn ST_TblStyleOverrideType::parse(
  s : String,
) -> ST_TblStyleOverrideType raise SchemaViolation {
  match s {
    "band1Horz" => TblStyleOverrideTypeBand1Horz
    "band1Vert" => TblStyleOverrideTypeBand1Vert
    "band2Horz" => TblStyleOverrideTypeBand2Horz
    "band2Vert" => TblStyleOverrideTypeBand2Vert
    "firstCol" => TblStyleOverrideTypeFirstCol
    "firstRow" => TblStyleOverrideTypeFirstRow
    "lastCol" => TblStyleOverrideTypeLastCol
    "lastRow" => TblStyleOverrideTypeLastRow
    "neCell" => TblStyleOverrideTypeNeCell
    "nwCell" => TblStyleOverrideTypeNwCell
    "seCell" => TblStyleOverrideTypeSeCell
    "swCell" => TblStyleOverrideTypeSwCell
    "wholeTable" => TblStyleOverrideTypeWholeTable
    _ =>
      invalid_simple_type(
        "ST_TblStyleOverrideType", s, "unknown enumeration value",
      )
  }
}

///|
/// Construct ST_TblStyleOverrideType while enforcing the wml.xsd enumeration.
pub fn ST_TblStyleOverrideType::new(
  s : String,
) -> ST_TblStyleOverrideType raise SchemaViolation {
  ST_TblStyleOverrideType::parse(s)
}

///|
/// Return the schema lexical value for ST_TblStyleOverrideType.
pub fn ST_TblStyleOverrideType::to_string(
  self : ST_TblStyleOverrideType,
) -> String {
  match self {
    TblStyleOverrideTypeBand1Horz => "band1Horz"
    TblStyleOverrideTypeBand1Vert => "band1Vert"
    TblStyleOverrideTypeBand2Horz => "band2Horz"
    TblStyleOverrideTypeBand2Vert => "band2Vert"
    TblStyleOverrideTypeFirstCol => "firstCol"
    TblStyleOverrideTypeFirstRow => "firstRow"
    TblStyleOverrideTypeLastCol => "lastCol"
    TblStyleOverrideTypeLastRow => "lastRow"
    TblStyleOverrideTypeNeCell => "neCell"
    TblStyleOverrideTypeNwCell => "nwCell"
    TblStyleOverrideTypeSeCell => "seCell"
    TblStyleOverrideTypeSwCell => "swCell"
    TblStyleOverrideTypeWholeTable => "wholeTable"
  }
}

///|
/// XSD simple type ST_StyleType — Part 1 §17.18.83.
/// Restriction of xsd:string to the 4-value style-type enumeration.
pub(all) enum ST_StyleType {
  StyleTypeCharacter
  StyleTypeNumbering
  StyleTypeParagraph
  StyleTypeTable
} derive(Eq, Debug)

///|
/// Parse the ST_StyleType schema lexical value.
pub fn ST_StyleType::parse(s : String) -> ST_StyleType raise SchemaViolation {
  match s {
    "character" => StyleTypeCharacter
    "numbering" => StyleTypeNumbering
    "paragraph" => StyleTypeParagraph
    "table" => StyleTypeTable
    _ => invalid_simple_type("ST_StyleType", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_StyleType while enforcing the wml.xsd enumeration.
pub fn ST_StyleType::new(s : String) -> ST_StyleType raise SchemaViolation {
  ST_StyleType::parse(s)
}

///|
/// Return the schema lexical value for ST_StyleType.
pub fn ST_StyleType::to_string(self : ST_StyleType) -> String {
  match self {
    StyleTypeCharacter => "character"
    StyleTypeNumbering => "numbering"
    StyleTypeParagraph => "paragraph"
    StyleTypeTable => "table"
  }
}

///|
/// XSD simple type ST_FontFamily — Part 1 §17.18.30.
/// Restriction of xsd:string to the font-family classification
/// {decorative, modern, roman, script, swiss, auto}.
pub(all) enum ST_FontFamily {
  FontFamilyDecorative
  FontFamilyModern
  FontFamilyRoman
  FontFamilyScript
  FontFamilySwiss
  FontFamilyAuto
} derive(Eq, Debug)

///|
/// Parse the ST_FontFamily schema lexical value.
pub fn ST_FontFamily::parse(s : String) -> ST_FontFamily raise SchemaViolation {
  match s {
    "decorative" => FontFamilyDecorative
    "modern" => FontFamilyModern
    "roman" => FontFamilyRoman
    "script" => FontFamilyScript
    "swiss" => FontFamilySwiss
    "auto" => FontFamilyAuto
    _ => invalid_simple_type("ST_FontFamily", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_FontFamily while enforcing the wml.xsd enumeration.
pub fn ST_FontFamily::new(s : String) -> ST_FontFamily raise SchemaViolation {
  ST_FontFamily::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_FontFamily.
pub fn ST_FontFamily::to_string(self : ST_FontFamily) -> String {
  match self {
    FontFamilyDecorative => "decorative"
    FontFamilyModern => "modern"
    FontFamilyRoman => "roman"
    FontFamilyScript => "script"
    FontFamilySwiss => "swiss"
    FontFamilyAuto => "auto"
  }
}

///|
/// XSD simple type ST_Pitch — Part 1 §17.18.66 font pitch enumeration.
pub(all) enum ST_Pitch {
  /// §17.18.66 "fixed"
  PitchFixed
  /// §17.18.66 "variable"
  PitchVariable
  /// §17.18.66 "default"
  PitchDefault
} derive(Eq, Debug)

///|
/// Part 1 §17.18.66 — decode the pitch lexical token.
pub fn ST_Pitch::parse(s : String) -> ST_Pitch raise SchemaViolation {
  match s {
    "fixed" => PitchFixed
    "variable" => PitchVariable
    "default" => PitchDefault
    _ => invalid_simple_type("ST_Pitch", s, "unknown enumeration value")
  }
}

///|
pub fn ST_Pitch::new(s : String) -> ST_Pitch raise SchemaViolation {
  ST_Pitch::parse(s)
}

///|
pub fn ST_Pitch::to_string(self : ST_Pitch) -> String {
  match self {
    PitchFixed => "fixed"
    PitchVariable => "variable"
    PitchDefault => "default"
  }
}

///|
/// XSD simple type ST_ThemeColor — Part 1 §17.18.97.
/// Restriction of xsd:string to the 18-value theme-color enumeration.
pub(all) enum ST_ThemeColor {
  ThemeColorAccent1
  ThemeColorAccent2
  ThemeColorAccent3
  ThemeColorAccent4
  ThemeColorAccent5
  ThemeColorAccent6
  ThemeColorBackground1
  ThemeColorBackground2
  ThemeColorDark1
  ThemeColorDark2
  ThemeColorFollowedHyperlink
  ThemeColorHyperlink
  ThemeColorLight1
  ThemeColorLight2
  ThemeColorNone
  ThemeColorText1
  ThemeColorText2
} derive(Eq, Debug)

///|
/// Parse the ST_ThemeColor schema lexical value.
pub fn ST_ThemeColor::parse(s : String) -> ST_ThemeColor raise SchemaViolation {
  match s {
    "accent1" => ThemeColorAccent1
    "accent2" => ThemeColorAccent2
    "accent3" => ThemeColorAccent3
    "accent4" => ThemeColorAccent4
    "accent5" => ThemeColorAccent5
    "accent6" => ThemeColorAccent6
    "background1" => ThemeColorBackground1
    "background2" => ThemeColorBackground2
    "dark1" => ThemeColorDark1
    "dark2" => ThemeColorDark2
    "followedHyperlink" => ThemeColorFollowedHyperlink
    "hyperlink" => ThemeColorHyperlink
    "light1" => ThemeColorLight1
    "light2" => ThemeColorLight2
    "none" => ThemeColorNone
    "text1" => ThemeColorText1
    "text2" => ThemeColorText2
    _ => invalid_simple_type("ST_ThemeColor", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_ThemeColor while enforcing the wml.xsd enumeration.
pub fn ST_ThemeColor::new(s : String) -> ST_ThemeColor raise SchemaViolation {
  ST_ThemeColor::parse(s)
}

///|
/// Return the schema lexical value for ST_ThemeColor.
pub fn ST_ThemeColor::to_string(self : ST_ThemeColor) -> String {
  match self {
    ThemeColorAccent1 => "accent1"
    ThemeColorAccent2 => "accent2"
    ThemeColorAccent3 => "accent3"
    ThemeColorAccent4 => "accent4"
    ThemeColorAccent5 => "accent5"
    ThemeColorAccent6 => "accent6"
    ThemeColorBackground1 => "background1"
    ThemeColorBackground2 => "background2"
    ThemeColorDark1 => "dark1"
    ThemeColorDark2 => "dark2"
    ThemeColorFollowedHyperlink => "followedHyperlink"
    ThemeColorHyperlink => "hyperlink"
    ThemeColorLight1 => "light1"
    ThemeColorLight2 => "light2"
    ThemeColorNone => "none"
    ThemeColorText1 => "text1"
    ThemeColorText2 => "text2"
  }
}

///|
/// XSD simple type ST_DocPartBehavior — Part 1 §17.18.15.
/// Restriction of xsd:string to {content, p, pg}, the glossary-entry
/// insertion behaviors.
pub(all) enum ST_DocPartBehavior {
  DocPartBehaviorContent
  DocPartBehaviorP
  DocPartBehaviorPg
} derive(Eq, Debug)

///|
/// Parse the ST_DocPartBehavior schema lexical value.
pub fn ST_DocPartBehavior::parse(
  s : String,
) -> ST_DocPartBehavior raise SchemaViolation {
  match s {
    "content" => DocPartBehaviorContent
    "p" => DocPartBehaviorP
    "pg" => DocPartBehaviorPg
    _ =>
      invalid_simple_type("ST_DocPartBehavior", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_DocPartBehavior while enforcing the wml.xsd
/// enumeration.
pub fn ST_DocPartBehavior::new(
  s : String,
) -> ST_DocPartBehavior raise SchemaViolation {
  ST_DocPartBehavior::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_DocPartBehavior.
pub fn ST_DocPartBehavior::to_string(self : ST_DocPartBehavior) -> String {
  match self {
    DocPartBehaviorContent => "content"
    DocPartBehaviorP => "p"
    DocPartBehaviorPg => "pg"
  }
}

///|
/// XSD simple type ST_DocPartType — Part 1 §17.18.17.
/// Restriction of xsd:string to the glossary-entry type catalogue
/// {none, normal, autoExp, toolbar, speller, formFld, bbPlcHdr}.
pub(all) enum ST_DocPartType {
  DocPartTypeNone
  DocPartTypeNormal
  DocPartTypeAutoExp
  DocPartTypeToolbar
  DocPartTypeSpeller
  DocPartTypeFormFld
  DocPartTypeBbPlcHdr
} derive(Eq, Debug)

///|
/// Parse the ST_DocPartType schema lexical value.
pub fn ST_DocPartType::parse(
  s : String,
) -> ST_DocPartType raise SchemaViolation {
  match s {
    "none" => DocPartTypeNone
    "normal" => DocPartTypeNormal
    "autoExp" => DocPartTypeAutoExp
    "toolbar" => DocPartTypeToolbar
    "speller" => DocPartTypeSpeller
    "formFld" => DocPartTypeFormFld
    "bbPlcHdr" => DocPartTypeBbPlcHdr
    _ => invalid_simple_type("ST_DocPartType", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_DocPartType while enforcing the wml.xsd enumeration.
pub fn ST_DocPartType::new(s : String) -> ST_DocPartType raise SchemaViolation {
  ST_DocPartType::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_DocPartType.
pub fn ST_DocPartType::to_string(self : ST_DocPartType) -> String {
  match self {
    DocPartTypeNone => "none"
    DocPartTypeNormal => "normal"
    DocPartTypeAutoExp => "autoExp"
    DocPartTypeToolbar => "toolbar"
    DocPartTypeSpeller => "speller"
    DocPartTypeFormFld => "formFld"
    DocPartTypeBbPlcHdr => "bbPlcHdr"
  }
}

///|
/// XSD simple type ST_DocPartGallery — Part 1 §17.18.16.
/// Restriction of xsd:string to the glossary-entry gallery catalogue
/// covering well-known galleries (cover pages, equations, headers,
/// page numbers, etc.) along with the `custom1`..`custom5`
/// producer-defined slots.
pub(all) enum ST_DocPartGallery {
  DocPartGalleryPlaceholder
  DocPartGalleryAny
  DocPartGalleryDefault
  DocPartGalleryDocParts
  DocPartGalleryCoverPg
  DocPartGalleryEq
  DocPartGalleryFtrs
  DocPartGalleryHdrs
  DocPartGalleryPgNum
  DocPartGalleryTbls
  DocPartGalleryWatermarks
  DocPartGalleryAutoTxt
  DocPartGalleryTxtBox
  DocPartGalleryPgNumT
  DocPartGalleryPgNumB
  DocPartGalleryPgNumMargins
  DocPartGalleryTblOfContents
  DocPartGalleryBib
  DocPartGalleryCustQuickParts
  DocPartGalleryCustCoverPg
  DocPartGalleryCustEq
  DocPartGalleryCustFtrs
  DocPartGalleryCustHdrs
  DocPartGalleryCustPgNum
  DocPartGalleryCustTbls
  DocPartGalleryCustWatermarks
  DocPartGalleryCustAutoTxt
  DocPartGalleryCustTxtBox
  DocPartGalleryCustPgNumT
  DocPartGalleryCustPgNumB
  DocPartGalleryCustPgNumMargins
  DocPartGalleryCustTblOfContents
  DocPartGalleryCustBib
  DocPartGalleryCustom1
  DocPartGalleryCustom2
  DocPartGalleryCustom3
  DocPartGalleryCustom4
  DocPartGalleryCustom5
} derive(Eq, Debug)

///|
/// Parse the ST_DocPartGallery schema lexical value.
pub fn ST_DocPartGallery::parse(
  s : String,
) -> ST_DocPartGallery raise SchemaViolation {
  match s {
    "placeholder" => DocPartGalleryPlaceholder
    "any" => DocPartGalleryAny
    "default" => DocPartGalleryDefault
    "docParts" => DocPartGalleryDocParts
    "coverPg" => DocPartGalleryCoverPg
    "eq" => DocPartGalleryEq
    "ftrs" => DocPartGalleryFtrs
    "hdrs" => DocPartGalleryHdrs
    "pgNum" => DocPartGalleryPgNum
    "tbls" => DocPartGalleryTbls
    "watermarks" => DocPartGalleryWatermarks
    "autoTxt" => DocPartGalleryAutoTxt
    "txtBox" => DocPartGalleryTxtBox
    "pgNumT" => DocPartGalleryPgNumT
    "pgNumB" => DocPartGalleryPgNumB
    "pgNumMargins" => DocPartGalleryPgNumMargins
    "tblOfContents" => DocPartGalleryTblOfContents
    "bib" => DocPartGalleryBib
    "custQuickParts" => DocPartGalleryCustQuickParts
    "custCoverPg" => DocPartGalleryCustCoverPg
    "custEq" => DocPartGalleryCustEq
    "custFtrs" => DocPartGalleryCustFtrs
    "custHdrs" => DocPartGalleryCustHdrs
    "custPgNum" => DocPartGalleryCustPgNum
    "custTbls" => DocPartGalleryCustTbls
    "custWatermarks" => DocPartGalleryCustWatermarks
    "custAutoTxt" => DocPartGalleryCustAutoTxt
    "custTxtBox" => DocPartGalleryCustTxtBox
    "custPgNumT" => DocPartGalleryCustPgNumT
    "custPgNumB" => DocPartGalleryCustPgNumB
    "custPgNumMargins" => DocPartGalleryCustPgNumMargins
    "custTblOfContents" => DocPartGalleryCustTblOfContents
    "custBib" => DocPartGalleryCustBib
    "custom1" => DocPartGalleryCustom1
    "custom2" => DocPartGalleryCustom2
    "custom3" => DocPartGalleryCustom3
    "custom4" => DocPartGalleryCustom4
    "custom5" => DocPartGalleryCustom5
    _ =>
      invalid_simple_type("ST_DocPartGallery", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_DocPartGallery while enforcing the wml.xsd
/// enumeration.
pub fn ST_DocPartGallery::new(
  s : String,
) -> ST_DocPartGallery raise SchemaViolation {
  ST_DocPartGallery::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_DocPartGallery.
pub fn ST_DocPartGallery::to_string(self : ST_DocPartGallery) -> String {
  match self {
    DocPartGalleryPlaceholder => "placeholder"
    DocPartGalleryAny => "any"
    DocPartGalleryDefault => "default"
    DocPartGalleryDocParts => "docParts"
    DocPartGalleryCoverPg => "coverPg"
    DocPartGalleryEq => "eq"
    DocPartGalleryFtrs => "ftrs"
    DocPartGalleryHdrs => "hdrs"
    DocPartGalleryPgNum => "pgNum"
    DocPartGalleryTbls => "tbls"
    DocPartGalleryWatermarks => "watermarks"
    DocPartGalleryAutoTxt => "autoTxt"
    DocPartGalleryTxtBox => "txtBox"
    DocPartGalleryPgNumT => "pgNumT"
    DocPartGalleryPgNumB => "pgNumB"
    DocPartGalleryPgNumMargins => "pgNumMargins"
    DocPartGalleryTblOfContents => "tblOfContents"
    DocPartGalleryBib => "bib"
    DocPartGalleryCustQuickParts => "custQuickParts"
    DocPartGalleryCustCoverPg => "custCoverPg"
    DocPartGalleryCustEq => "custEq"
    DocPartGalleryCustFtrs => "custFtrs"
    DocPartGalleryCustHdrs => "custHdrs"
    DocPartGalleryCustPgNum => "custPgNum"
    DocPartGalleryCustTbls => "custTbls"
    DocPartGalleryCustWatermarks => "custWatermarks"
    DocPartGalleryCustAutoTxt => "custAutoTxt"
    DocPartGalleryCustTxtBox => "custTxtBox"
    DocPartGalleryCustPgNumT => "custPgNumT"
    DocPartGalleryCustPgNumB => "custPgNumB"
    DocPartGalleryCustPgNumMargins => "custPgNumMargins"
    DocPartGalleryCustTblOfContents => "custTblOfContents"
    DocPartGalleryCustBib => "custBib"
    DocPartGalleryCustom1 => "custom1"
    DocPartGalleryCustom2 => "custom2"
    DocPartGalleryCustom3 => "custom3"
    DocPartGalleryCustom4 => "custom4"
    DocPartGalleryCustom5 => "custom5"
  }
}

///|
/// XSD simple type ST_CaptionPos — Part 1 §17.18.5.
/// Restriction of xsd:string to {above, below, left, right}, the
/// automatic-caption positioning options relative to the captioned
/// object.
pub(all) enum ST_CaptionPos {
  CaptionPosAbove
  CaptionPosBelow
  CaptionPosLeft
  CaptionPosRight
} derive(Eq, Debug)

///|
/// Parse the ST_CaptionPos schema lexical value.
pub fn ST_CaptionPos::parse(s : String) -> ST_CaptionPos raise SchemaViolation {
  match s {
    "above" => CaptionPosAbove
    "below" => CaptionPosBelow
    "left" => CaptionPosLeft
    "right" => CaptionPosRight
    _ => invalid_simple_type("ST_CaptionPos", s, "unknown enumeration value")
  }
}

///|
/// Construct ST_CaptionPos while enforcing the wml.xsd enumeration.
pub fn ST_CaptionPos::new(s : String) -> ST_CaptionPos raise SchemaViolation {
  ST_CaptionPos::parse(s)
}

///|
/// Return the canonical schema lexical value for ST_CaptionPos.
pub fn ST_CaptionPos::to_string(self : ST_CaptionPos) -> String {
  match self {
    CaptionPosAbove => "above"
    CaptionPosBelow => "below"
    CaptionPosLeft => "left"
    CaptionPosRight => "right"
  }
}

// === Typed-measure carriers used by chunk2 unions ===

///|
/// Universal-measure unit suffix shared by ST_HpsMeasure and
/// ST_MeasurementOrPercent. Mirrors the six suffixes Part 1 §22.9.2.14
/// ST_UniversalMeasure permits — `mm`, `cm`, `in`, `pt`, `pc`, `pi`.
/// Variant names are prefixed `Wml` to keep the WordprocessingML
/// domain's namespace free of clashes with the shared
/// `UniversalMeasureUnit` enum in @simple_types.
pub(all) enum WmlUniversalMeasureUnit {
  /// §22.9.2.14 "mm"
  WmlMillimetre
  /// §22.9.2.14 "cm"
  WmlCentimetre
  /// §22.9.2.14 "in"
  WmlInch
  /// §22.9.2.14 "pt"
  WmlPoint
  /// §22.9.2.14 "pc"
  WmlPica
  /// §22.9.2.14 "pi"
  WmlPiPoint
} derive(Eq, Debug)

///|
fn parse_wml_measure_unit(
  type_name : String,
  s : String,
) -> WmlUniversalMeasureUnit raise SchemaViolation {
  match s {
    "mm" => WmlMillimetre
    "cm" => WmlCentimetre
    "in" => WmlInch
    "pt" => WmlPoint
    "pc" => WmlPica
    "pi" => WmlPiPoint
    _ => invalid_simple_type(type_name, s, "unknown universal-measure unit")
  }
}

///|
fn render_wml_measure_unit(unit : WmlUniversalMeasureUnit) -> String {
  match unit {
    WmlMillimetre => "mm"
    WmlCentimetre => "cm"
    WmlInch => "in"
    WmlPoint => "pt"
    WmlPica => "pc"
    WmlPiPoint => "pi"
  }
}

///|
/// Signed universal measure (Part 1 §22.9.2.14 ST_UniversalMeasure)
/// carried as `magnitude + unit`. Used by ST_MeasurementOrPercent's
/// measure branch so the lexical magnitude is preserved as a typed
/// `Double` rather than re-parsed each time it's read.
pub struct WmlUniversalMeasure {
  magnitude : Double
  unit : WmlUniversalMeasureUnit
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.14 — decode the lexical `<decimal><unit>` form.
pub fn WmlUniversalMeasure::parse(
  s : String,
) -> WmlUniversalMeasure raise SchemaViolation {
  if !is_wml_universal_measure(s, positive=false) {
    invalid_simple_type(
      "ST_UniversalMeasure", s, "expected signed decimal followed by mm/cm/in/pt/pc/pi",
    )
  }
  let split = s.length() - 2
  let magnitude = parse_wml_decimal_double(
    s.unsafe_substring(start=0, end=split),
  )
  let unit = parse_wml_measure_unit(
    "ST_UniversalMeasure",
    s.unsafe_substring(start=split, end=s.length()),
  )
  { magnitude, unit }
}

///|
pub fn WmlUniversalMeasure::to_string(self : WmlUniversalMeasure) -> String {
  format_wml_decimal(self.magnitude) + render_wml_measure_unit(self.unit)
}

///|
/// Magnitude accessor.
pub fn WmlUniversalMeasure::magnitude(self : WmlUniversalMeasure) -> Double {
  self.magnitude
}

///|
/// Unit accessor.
pub fn WmlUniversalMeasure::unit_of(
  self : WmlUniversalMeasure,
) -> WmlUniversalMeasureUnit {
  self.unit
}

///|
/// Non-negative universal measure (Part 1 §22.9.2.12
/// ST_PositiveUniversalMeasure). Used by ST_HpsMeasure's measure
/// branch; the constructor enforces magnitude ≥ 0.
pub struct WmlPositiveUniversalMeasure {
  magnitude : Double
  unit : WmlUniversalMeasureUnit
} derive(Eq, Debug)

///|
/// Part 1 §22.9.2.12 — decode the lexical form, raising when the
/// magnitude is negative.
pub fn WmlPositiveUniversalMeasure::parse(
  s : String,
) -> WmlPositiveUniversalMeasure raise SchemaViolation {
  if !is_wml_universal_measure(s, positive=true) {
    invalid_simple_type(
      "ST_PositiveUniversalMeasure", s, "expected non-negative decimal followed by mm/cm/in/pt/pc/pi",
    )
  }
  let split = s.length() - 2
  let magnitude = parse_wml_decimal_double(
    s.unsafe_substring(start=0, end=split),
  )
  let unit = parse_wml_measure_unit(
    "ST_PositiveUniversalMeasure",
    s.unsafe_substring(start=split, end=s.length()),
  )
  { magnitude, unit }
}

///|
pub fn WmlPositiveUniversalMeasure::to_string(
  self : WmlPositiveUniversalMeasure,
) -> String {
  format_wml_decimal(self.magnitude) + render_wml_measure_unit(self.unit)
}

///|
/// Magnitude accessor.
pub fn WmlPositiveUniversalMeasure::magnitude(
  self : WmlPositiveUniversalMeasure,
) -> Double {
  self.magnitude
}

///|
/// Unit accessor.
pub fn WmlPositiveUniversalMeasure::unit_of(
  self : WmlPositiveUniversalMeasure,
) -> WmlUniversalMeasureUnit {
  self.unit
}

// === Lexical helpers (private) ===

///|
/// `s.length() == len` and every character is an ASCII hex digit.
fn is_fixed_hex(s : String, len : Int) -> Bool {
  if s.length() != len {
    false
  } else {
    let mut ok = true
    for i in 0..<len {
      ok = ok && is_hex_at(s, i)
    }
    ok
  }
}

///|
/// Decode two hex digits at `offset` into a 0..255 integer. The caller
/// must have verified the two characters are ASCII hex.
fn hex_pair_at(s : String, offset : Int) -> Int {
  hex_digit_value_at(s, offset) * 16 + hex_digit_value_at(s, offset + 1)
}

///|
fn hex_digit_value_at(s : String, index : Int) -> Int {
  let unit = s.code_unit_at(index).to_int()
  if unit >= 0x30 && unit <= 0x39 {
    unit - 0x30
  } else if unit >= 0x41 && unit <= 0x46 {
    unit - 0x41 + 10
  } else if unit >= 0x61 && unit <= 0x66 {
    unit - 0x61 + 10
  } else {
    0
  }
}

///|
/// Render a 0..255 integer as two uppercase hex digits.
fn hex_byte_string(value : Int) -> String {
  hex_digit_string(value / 16 % 16) + hex_digit_string(value % 16)
}

///|
fn hex_digit_string(value : Int) -> String {
  match value {
    0 => "0"
    1 => "1"
    2 => "2"
    3 => "3"
    4 => "4"
    5 => "5"
    6 => "6"
    7 => "7"
    8 => "8"
    9 => "9"
    10 => "A"
    11 => "B"
    12 => "C"
    13 => "D"
    14 => "E"
    15 => "F"
    _ => "0"
  }
}

///|
fn is_hex_at(s : String, index : Int) -> Bool {
  let unit = s.code_unit_at(index).to_int()
  (unit >= 0x30 && unit <= 0x39) ||
  (unit >= 0x41 && unit <= 0x46) ||
  (unit >= 0x61 && unit <= 0x66)
}

///|
fn is_decimal_digit_at(s : String, index : Int) -> Bool {
  let unit = s.code_unit_at(index).to_int()
  unit >= 0x30 && unit <= 0x39
}

///|
fn decimal_digit_value_at(s : String, index : Int) -> Int {
  s.code_unit_at(index).to_int() - 0x30
}

///|
/// xsd:unsignedLong lexical form: one or more decimal digits, value ≤
/// 2^64 − 1.
fn is_wml_unsigned_long(s : String) -> Bool {
  if s.length() == 0 {
    false
  } else {
    let mut all_digits = true
    for i in 0..<s.length() {
      all_digits = all_digits && is_decimal_digit_at(s, i)
    }
    if !all_digits {
      false
    } else {
      let trimmed = trim_leading_zeroes(s)
      let max = "18446744073709551615"
      trimmed.length() < max.length() ||
      (trimmed.length() == max.length() && trimmed <= max)
    }
  }
}

///|
fn parse_wml_unsigned_long(s : String) -> UInt64 {
  let mut value : UInt64 = 0UL
  for i in 0..<s.length() {
    value = value * 10UL + decimal_digit_value_at(s, i).to_uint64()
  }
  value
}

///|
fn trim_leading_zeroes(s : String) -> String {
  let mut pos = 0
  while pos < s.length() - 1 && s[pos:pos + 1] == "0" {
    pos = pos + 1
  }
  s.unsafe_substring(start=pos, end=s.length())
}

///|
/// xsd:decimal lexical form check across `s[start:end]` — optional
/// sign, integer digits, optional fractional part.
fn is_wml_decimal(s : String, start : Int, end : Int) -> Bool {
  if start >= end {
    false
  } else {
    let mut pos = start
    if s[pos:pos + 1] == "-" {
      pos = pos + 1
    }
    let digits_start = pos
    while pos < end && is_decimal_digit_at(s, pos) {
      pos = pos + 1
    }
    let whole_digits = pos > digits_start
    if pos < end && s[pos:pos + 1] == "." {
      pos = pos + 1
      let fraction_start = pos
      while pos < end && is_decimal_digit_at(s, pos) {
        pos = pos + 1
      }
      whole_digits && pos > fraction_start && pos == end
    } else {
      whole_digits && pos == end
    }
  }
}

///|
/// Non-negative check on the decimal lexical form `s[start:end]`. The
/// only negative form accepted is "-0…0(.0…0)?" because the magnitude
/// equals zero.
fn wml_decimal_non_negative(s : String, start : Int, end : Int) -> Bool {
  if s[start:start + 1] != "-" {
    true
  } else {
    let mut zero = true
    for i in (start + 1)..<end {
      let ch = s[i:i + 1]
      if ch != "." && ch != "0" {
        zero = false
      }
    }
    zero
  }
}

///|
/// ST_UniversalMeasure lexical form: decimal magnitude followed by the
/// two-character unit suffix. When `positive` is set, also enforces the
/// non-negative restriction the ST_PositiveUniversalMeasure subtype
/// adds.
fn is_wml_universal_measure(s : String, positive~ : Bool) -> Bool {
  if s.length() < 3 {
    false
  } else {
    let unit = s.unsafe_substring(start=s.length() - 2, end=s.length())
    let number_end = s.length() - 2
    is_wml_measure_unit_lexical(unit) &&
    is_wml_decimal(s, 0, number_end) &&
    (!positive || wml_decimal_non_negative(s, 0, number_end))
  }
}

///|
fn is_wml_measure_unit_lexical(unit : String) -> Bool {
  unit == "mm" ||
  unit == "cm" ||
  unit == "in" ||
  unit == "pt" ||
  unit == "pc" ||
  unit == "pi"
}

///|
/// ST_DecimalNumberOrPercent / ST_Percentage lexical form check —
/// `<decimal>%`. The XSD allows any signed decimal followed by `%`; the
/// `fixed` / `positive` constraints other percent types add are
/// applied by their dedicated parsers.
fn is_wml_percentage(s : String) -> Bool {
  if s.length() < 2 || s[s.length() - 1:] != "%" {
    false
  } else {
    is_wml_decimal(s, 0, s.length() - 1)
  }
}

///|
/// Parse a decimal magnitude `s` (no trailing `%` / unit) into a fixed
/// scaled Int64 representation with `decimal_places` digits after the
/// implicit decimal point.
fn parse_wml_decimal_scaled(s : String, decimal_places : Int) -> Int64 {
  let mut sign : Int64 = 1L
  let mut pos = 0
  if pos < s.length() && s[pos:pos + 1] == "-" {
    sign = -1L
    pos = pos + 1
  }
  let mut whole : Int64 = 0L
  while pos < s.length() && is_decimal_digit_at(s, pos) {
    whole = whole * 10L + decimal_digit_value_at(s, pos).to_int64()
    pos = pos + 1
  }
  let mut multiplier : Int64 = 1L
  for _ in 0..<decimal_places {
    multiplier = multiplier * 10L
  }
  let mut scaled = whole * multiplier
  if pos < s.length() && s[pos:pos + 1] == "." {
    pos = pos + 1
    let mut consumed = 0
    while pos < s.length() &&
          is_decimal_digit_at(s, pos) &&
          consumed < decimal_places {
      multiplier = multiplier / 10L
      scaled = scaled + decimal_digit_value_at(s, pos).to_int64() * multiplier
      pos = pos + 1
      consumed = consumed + 1
    }
  }
  sign * scaled
}

///|
fn parse_wml_decimal_double(s : String) -> Double {
  let mut sign = 1.0
  let mut pos = 0
  if pos < s.length() && s[pos:pos + 1] == "-" {
    sign = -1.0
    pos = pos + 1
  }
  let mut whole = 0.0
  while pos < s.length() && is_decimal_digit_at(s, pos) {
    whole = whole * 10.0 + decimal_digit_value_at(s, pos).to_double()
    pos = pos + 1
  }
  let mut fraction = 0.0
  let mut scale = 1.0
  if pos < s.length() && s[pos:pos + 1] == "." {
    pos = pos + 1
    while pos < s.length() && is_decimal_digit_at(s, pos) {
      scale = scale * 10.0
      fraction = fraction + decimal_digit_value_at(s, pos).to_double() / scale
      pos = pos + 1
    }
  }
  sign * (whole + fraction)
}

///|
fn format_wml_decimal(value : Double) -> String {
  if value == value.trunc() && value.abs() < 1.0e15 {
    value.to_int64().to_string()
  } else {
    value.to_string()
  }
}

///|
fn format_wml_scaled_decimal(value : Int64, decimal_places : Int) -> String {
  let negative = value < 0L
  let magnitude = if negative { -value } else { value }
  let mut divisor : Int64 = 1L
  for _ in 0..<decimal_places {
    divisor = divisor * 10L
  }
  let whole = magnitude / divisor
  let fraction = magnitude - whole * divisor
  let mut frac_text = fraction.to_string()
  while frac_text.length() < decimal_places {
    frac_text = "0" + frac_text
  }
  let mut end = frac_text.length()
  while end > 0 && frac_text[end - 1:end] == "0" {
    end = end - 1
  }
  let body = if end == 0 {
    whole.to_string()
  } else {
    whole.to_string() + "." + frac_text.unsafe_substring(start=0, end~)
  }
  if negative {
    "-" + body
  } else {
    body
  }
}

///|
/// xsd:signed integer (32-bit) check.
fn is_wml_signed_int(s : String) -> Bool {
  if s.length() == 0 {
    false
  } else {
    let mut start = 0
    if s[0:1] == "-" || s[0:1] == "+" {
      start = 1
    }
    if start >= s.length() {
      false
    } else {
      let mut ok = true
      for i in start..<s.length() {
        ok = ok && is_decimal_digit_at(s, i)
      }
      ok
    }
  }
}

///|
/// Decode a signed xsd:int lexical form into a native `Int`. The caller
/// must have verified the lexical form is valid; this function performs
/// the 32-bit range check (raising on overflow) so a malformed value
/// can never silently land in storage.
fn parse_wml_signed_int(
  type_name : String,
  s : String,
) -> Int raise SchemaViolation {
  if !is_wml_signed_int(s) {
    invalid_simple_type(type_name, s, "expected xsd:int lexical value")
  }
  let mut start = 0
  let mut negative = false
  if s[0:1] == "-" {
    negative = true
    start = 1
  } else if s[0:1] == "+" {
    start = 1
  }
  let digit_count = s.length() - start
  if digit_count > 10 {
    invalid_simple_type(type_name, s, "exceeds xsd:int 32-bit range")
  }
  let mut acc : Int64 = 0L
  for i in start..<s.length() {
    acc = acc * 10L + decimal_digit_value_at(s, i).to_int64()
  }
  let limit_positive : Int64 = 2147483647L
  let limit_negative : Int64 = 2147483648L
  if negative {
    if acc > limit_negative {
      invalid_simple_type(type_name, s, "exceeds xsd:int 32-bit range")
    }
    (-acc).to_int()
  } else {
    if acc > limit_positive {
      invalid_simple_type(type_name, s, "exceeds xsd:int 32-bit range")
    }
    acc.to_int()
  }
}
