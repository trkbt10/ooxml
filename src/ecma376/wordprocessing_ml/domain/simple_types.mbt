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
    "ST_Underline" =>
      ";single;words;double;thick;dotted;dottedHeavy;dash;dashedHeavy;dashLong;dashLongHeavy;dotDash;dashDotHeavy;dotDotDash;dashDotDotHeavy;wave;wavyHeavy;wavyDouble;none;"
    "ST_TextEffect" =>
      ";blinkBackground;lights;antsBlack;antsRed;shimmer;sparkle;none;"
    "ST_Border" =>
      ";nil;none;single;thick;double;dotted;dashed;dotDash;dotDotDash;triple;thinThickSmallGap;thickThinSmallGap;thinThickThinSmallGap;thinThickMediumGap;thickThinMediumGap;thinThickThinMediumGap;thinThickLargeGap;thickThinLargeGap;thinThickThinLargeGap;wave;doubleWave;dashSmallGap;dashDotStroked;threeDEmboss;threeDEngrave;outset;inset;apples;archedScallops;babyPacifier;babyRattle;balloons3Colors;balloonsHotAir;basicBlackDashes;basicBlackDots;basicBlackSquares;basicThinLines;basicWhiteDashes;basicWhiteDots;basicWhiteSquares;basicWideInline;basicWideMidline;basicWideOutline;bats;birds;birdsFlight;cabins;cakeSlice;candyCorn;celticKnotwork;certificateBanner;chainLink;champagneBottle;checkedBarBlack;checkedBarColor;checkered;christmasTree;circlesLines;circlesRectangles;classicalWave;clocks;compass;confetti;confettiGrays;confettiOutline;confettiStreamers;confettiWhite;cornerTriangles;couponCutoutDashes;couponCutoutDots;crazyMaze;creaturesButterfly;creaturesFish;creaturesInsects;creaturesLadyBug;crossStitch;cup;decoArch;decoArchColor;decoBlocks;diamondsGray;doubleD;doubleDiamonds;earth1;earth2;earth3;eclipsingSquares1;eclipsingSquares2;eggsBlack;fans;film;firecrackers;flowersBlockPrint;flowersDaisies;flowersModern1;flowersModern2;flowersPansy;flowersRedRose;flowersRoses;flowersTeacup;flowersTiny;gems;gingerbreadMan;gradient;handmade1;handmade2;heartBalloon;heartGray;hearts;heebieJeebies;holly;houseFunky;hypnotic;iceCreamCones;lightBulb;lightning1;lightning2;mapPins;mapleLeaf;mapleMuffins;marquee;marqueeToothed;moons;mosaic;musicNotes;northwest;ovals;packages;palmsBlack;palmsColor;paperClips;papyrus;partyFavor;partyGlass;pencils;people;peopleWaving;peopleHats;poinsettias;postageStamp;pumpkin1;pushPinNote2;pushPinNote1;pyramids;pyramidsAbove;quadrants;rings;safari;sawtooth;sawtoothGray;scaredCat;seattle;shadowedSquares;sharksTeeth;shorebirdTracks;skyrocket;snowflakeFancy;snowflakes;sombrero;southwest;stars;starsTop;stars3d;starsBlack;starsShadowed;sun;swirligig;tornPaper;tornPaperBlack;trees;triangleParty;triangles;triangle1;triangle2;triangleCircle1;triangleCircle2;shapes1;shapes2;twistedLines1;twistedLines2;vine;waveline;weavingAngles;weavingBraid;weavingRibbon;weavingStrips;whiteFlowers;woodwork;xIllusions;zanyTriangles;zigZag;zigZagStitch;custom;"
    "ST_Shd" =>
      ";nil;clear;solid;horzStripe;vertStripe;reverseDiagStripe;diagStripe;horzCross;diagCross;thinHorzStripe;thinVertStripe;thinReverseDiagStripe;thinDiagStripe;thinHorzCross;thinDiagCross;pct5;pct10;pct12;pct15;pct20;pct25;pct30;pct35;pct37;pct40;pct45;pct50;pct55;pct60;pct62;pct65;pct70;pct75;pct80;pct85;pct87;pct90;pct95;"
    "ST_Em" => ";none;dot;comma;circle;underDot;"
    "ST_CombineBrackets" => ";none;round;square;angle;curly;"
    "ST_HeightRule" => ";auto;exact;atLeast;"
    "ST_Wrap" => ";auto;notBeside;around;tight;through;none;"
    "ST_VAnchor" => ";text;margin;page;"
    "ST_HAnchor" => ";text;margin;page;"
    "ST_DropCap" => ";none;drop;margin;"
    "ST_TabJc" => ";clear;start;center;end;decimal;bar;num;"
    "ST_TabTlc" => ";none;dot;hyphen;underscore;heavy;middleDot;"
    "ST_LineSpacingRule" => ";auto;exact;atLeast;"
    "ST_Jc" =>
      ";start;center;end;both;mediumKashida;distribute;numTab;highKashida;lowKashida;thaiDistribute;"
    "ST_JcTable" => ";center;end;start;"
    "ST_View" => ";none;print;outline;masterPages;normal;web;"
    "ST_Zoom" => ";none;fullPage;bestFit;textFit;"
    "ST_Proof" => ";clean;dirty;"
    "ST_DocProtect" => ";none;readOnly;comments;trackedChanges;forms;"
    "ST_MailMergeDocType" =>
      ";catalog;envelopes;mailingLabels;formLetters;email;fax;"
    "ST_MailMergeDest" => ";newDocument;printer;email;fax;"
    "ST_MailMergeOdsoFMDFieldType" => ";null;dbColumn;"
    "ST_TextDirection" => ";tb;rl;lr;tbV;rlV;lrV;"
    "ST_TextAlignment" => ";top;center;baseline;bottom;auto;"
    "ST_DisplacedByCustomXml" => ";next;prev;"
    "ST_AnnotationVMerge" => ";cont;rest;"
    "ST_TextboxTightWrap" =>
      ";none;allLines;firstAndLastLine;firstLineOnly;lastLineOnly;"
    "ST_ObjectDrawAspect" => ";content;icon;"
    "ST_ObjectUpdateMode" => ";always;onCall;"
    "ST_FldCharType" => ";begin;separate;end;"
    "ST_InfoTextType" => ";text;autoText;"
    "ST_FFTextType" =>
      ";regular;number;date;currentTime;currentDate;calculated;"
    "ST_SectionMark" => ";nextPage;nextColumn;continuous;evenPage;oddPage;"
    "ST_NumberFormat" =>
      ";decimal;upperRoman;lowerRoman;upperLetter;lowerLetter;ordinal;cardinalText;ordinalText;hex;chicago;ideographDigital;japaneseCounting;aiueo;iroha;decimalFullWidth;decimalHalfWidth;japaneseLegal;japaneseDigitalTenThousand;decimalEnclosedCircle;decimalFullWidth2;aiueoFullWidth;irohaFullWidth;decimalZero;bullet;ganada;chosung;decimalEnclosedFullstop;decimalEnclosedParen;decimalEnclosedCircleChinese;ideographEnclosedCircle;ideographTraditional;ideographZodiac;ideographZodiacTraditional;taiwaneseCounting;ideographLegalTraditional;taiwaneseCountingThousand;taiwaneseDigital;chineseCounting;chineseLegalSimplified;chineseCountingThousand;koreanDigital;koreanCounting;koreanLegal;koreanDigital2;vietnameseCounting;russianLower;russianUpper;none;numberInDash;hebrew1;hebrew2;arabicAlpha;arabicAbjad;hindiVowels;hindiConsonants;hindiNumbers;hindiCounting;thaiLetters;thaiNumbers;thaiCounting;bahtText;dollarText;custom;"
    "ST_PageOrientation" => ";portrait;landscape;"
    "ST_PageBorderZOrder" => ";front;back;"
    "ST_PageBorderDisplay" => ";allPages;firstPage;notFirstPage;"
    "ST_PageBorderOffset" => ";page;text;"
    "ST_ChapterSep" => ";hyphen;period;colon;emDash;enDash;"
    "ST_LineNumberRestart" => ";newPage;newSection;continuous;"
    "ST_VerticalJc" => ";top;center;both;bottom;"
    "ST_DocGrid" => ";default;lines;linesAndChars;snapToChars;"
    "ST_HdrFtr" => ";even;default;first;"
    "ST_FtnEdn" => ";normal;separator;continuationSeparator;continuationNotice;"
    "ST_BrType" => ";page;column;textWrapping;"
    "ST_BrClear" => ";none;left;right;all;"
    "ST_PTabAlignment" => ";left;center;right;"
    "ST_PTabRelativeTo" => ";margin;indent;"
    "ST_PTabLeader" => ";none;dot;hyphen;underscore;middleDot;"
    "ST_ProofErr" => ";spellStart;spellEnd;gramStart;gramEnd;"
    "ST_EdGrp" =>
      ";none;everyone;administrators;contributors;editors;owners;current;"
    "ST_Hint" => ";default;eastAsia;"
    "ST_Theme" =>
      ";majorEastAsia;majorBidi;majorAscii;majorHAnsi;minorEastAsia;minorBidi;minorAscii;minorHAnsi;"
    "ST_RubyAlign" =>
      ";center;distributeLetter;distributeSpace;left;right;rightVertical;"
    "ST_Lock" => ";sdtLocked;contentLocked;unlocked;sdtContentLocked;"
    "ST_SdtDateMappingType" => ";text;date;dateTime;"
    "ST_Direction" => ";ltr;rtl;"
    "ST_TblWidth" => ";nil;pct;dxa;auto;"
    "ST_Merge" => ";continue;restart;"
    "ST_TblLayoutType" => ";fixed;autofit;"
    "ST_TblOverlap" => ";never;overlap;"
    "ST_FtnPos" => ";pageBottom;beneathText;sectEnd;docEnd;"
    "ST_EdnPos" => ";sectEnd;docEnd;"
    "ST_RestartNumber" => ";continuous;eachSect;eachPage;"
    "ST_MailMergeSourceType" =>
      ";database;addressBook;document1;document2;text;email;native;legacy;master;"
    "ST_TargetScreenSz" =>
      ";544x376;640x480;720x512;800x600;1024x768;1152x882;1152x900;1280x1024;1600x1200;1800x1440;1920x1200;"
    "ST_CharacterSpacing" =>
      ";doNotCompress;compressPunctuation;compressPunctuationAndJapaneseKana;"
    "ST_WmlColorSchemeIndex" =>
      ";dark1;light1;dark2;light2;accent1;accent2;accent3;accent4;accent5;accent6;hyperlink;followedHyperlink;"
    "ST_StyleSort" => ";name;priority;default;font;basedOn;type;"
    "ST_FrameScrollbar" => ";on;off;auto;"
    "ST_FrameLayout" => ";rows;cols;none;"
    "ST_LevelSuffix" => ";tab;space;nothing;"
    "ST_MultiLevelType" => ";singleLevel;multilevel;hybridMultilevel;"
    "ST_TblStyleOverrideType" =>
      ";wholeTable;firstRow;lastRow;firstCol;lastCol;band1Vert;band2Vert;band1Horz;band2Horz;neCell;nwCell;seCell;swCell;"
    "ST_StyleType" => ";paragraph;character;table;numbering;"
    "ST_FontFamily" => ";decorative;modern;roman;script;swiss;auto;"
    "ST_Pitch" => ";fixed;variable;default;"
    "ST_ThemeColor" =>
      ";dark1;light1;dark2;light2;accent1;accent2;accent3;accent4;accent5;accent6;hyperlink;followedHyperlink;none;background1;text1;background2;text2;"
    "ST_DocPartBehavior" => ";content;p;pg;"
    "ST_DocPartType" => ";none;normal;autoExp;toolbar;speller;formFld;bbPlcHdr;"
    "ST_DocPartGallery" =>
      ";placeholder;any;default;docParts;coverPg;eq;ftrs;hdrs;pgNum;tbls;watermarks;autoTxt;txtBox;pgNumT;pgNumB;pgNumMargins;tblOfContents;bib;custQuickParts;custCoverPg;custEq;custFtrs;custHdrs;custPgNum;custTbls;custWatermarks;custAutoTxt;custTxtBox;custPgNumT;custPgNumB;custPgNumMargins;custTblOfContents;custBib;custom1;custom2;custom3;custom4;custom5;"
    "ST_CaptionPos" => ";above;below;left;right;"
    _ => ""
  }
}

///|
/// XSD simple type ST_LongHexNumber from wml.xsd (§17.18).
pub struct ST_LongHexNumber {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_LongHexNumber::parse(
  s : String,
) -> ST_LongHexNumber raise SchemaViolation {
  validate_wml_simple_type("ST_LongHexNumber", s)
  { value: s }
}

///|
pub fn ST_LongHexNumber::new(
  s : String,
) -> ST_LongHexNumber raise SchemaViolation {
  ST_LongHexNumber::parse(s)
}

///|
pub fn ST_LongHexNumber::to_string(self : ST_LongHexNumber) -> String {
  self.value
}

///|
/// XSD simple type ST_ShortHexNumber from wml.xsd (§17.18).
pub struct ST_ShortHexNumber {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ShortHexNumber::parse(
  s : String,
) -> ST_ShortHexNumber raise SchemaViolation {
  validate_wml_simple_type("ST_ShortHexNumber", s)
  { value: s }
}

///|
pub fn ST_ShortHexNumber::new(
  s : String,
) -> ST_ShortHexNumber raise SchemaViolation {
  ST_ShortHexNumber::parse(s)
}

///|
pub fn ST_ShortHexNumber::to_string(self : ST_ShortHexNumber) -> String {
  self.value
}

///|
/// XSD simple type ST_UcharHexNumber from wml.xsd (§17.18).
pub struct ST_UcharHexNumber {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_UcharHexNumber::parse(
  s : String,
) -> ST_UcharHexNumber raise SchemaViolation {
  validate_wml_simple_type("ST_UcharHexNumber", s)
  { value: s }
}

///|
pub fn ST_UcharHexNumber::new(
  s : String,
) -> ST_UcharHexNumber raise SchemaViolation {
  ST_UcharHexNumber::parse(s)
}

///|
pub fn ST_UcharHexNumber::to_string(self : ST_UcharHexNumber) -> String {
  self.value
}

///|
/// XSD simple type ST_DecimalNumberOrPercent from wml.xsd (§17.18).
pub struct ST_DecimalNumberOrPercent {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DecimalNumberOrPercent::parse(
  s : String,
) -> ST_DecimalNumberOrPercent raise SchemaViolation {
  validate_wml_simple_type("ST_DecimalNumberOrPercent", s)
  { value: s }
}

///|
pub fn ST_DecimalNumberOrPercent::new(
  s : String,
) -> ST_DecimalNumberOrPercent raise SchemaViolation {
  ST_DecimalNumberOrPercent::parse(s)
}

///|
pub fn ST_DecimalNumberOrPercent::to_string(
  self : ST_DecimalNumberOrPercent,
) -> String {
  self.value
}

///|
/// XSD simple type ST_DecimalNumber from wml.xsd (§17.18).
pub struct ST_DecimalNumber {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DecimalNumber::parse(
  s : String,
) -> ST_DecimalNumber raise SchemaViolation {
  validate_wml_simple_type("ST_DecimalNumber", s)
  { value: s }
}

///|
pub fn ST_DecimalNumber::new(
  s : String,
) -> ST_DecimalNumber raise SchemaViolation {
  ST_DecimalNumber::parse(s)
}

///|
pub fn ST_DecimalNumber::to_string(self : ST_DecimalNumber) -> String {
  self.value
}

///|
/// XSD simple type ST_SignedTwipsMeasure from wml.xsd (§17.18).
pub struct ST_SignedTwipsMeasure {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SignedTwipsMeasure::parse(
  s : String,
) -> ST_SignedTwipsMeasure raise SchemaViolation {
  validate_wml_simple_type("ST_SignedTwipsMeasure", s)
  { value: s }
}

///|
pub fn ST_SignedTwipsMeasure::new(
  s : String,
) -> ST_SignedTwipsMeasure raise SchemaViolation {
  ST_SignedTwipsMeasure::parse(s)
}

///|
pub fn ST_SignedTwipsMeasure::to_string(self : ST_SignedTwipsMeasure) -> String {
  self.value
}

///|
/// XSD simple type ST_PixelsMeasure from wml.xsd (§17.18).
pub struct ST_PixelsMeasure {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PixelsMeasure::parse(
  s : String,
) -> ST_PixelsMeasure raise SchemaViolation {
  validate_wml_simple_type("ST_PixelsMeasure", s)
  { value: s }
}

///|
pub fn ST_PixelsMeasure::new(
  s : String,
) -> ST_PixelsMeasure raise SchemaViolation {
  ST_PixelsMeasure::parse(s)
}

///|
pub fn ST_PixelsMeasure::to_string(self : ST_PixelsMeasure) -> String {
  self.value
}

///|
/// XSD simple type ST_HpsMeasure from wml.xsd (§17.18).
pub struct ST_HpsMeasure {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_HpsMeasure::parse(s : String) -> ST_HpsMeasure raise SchemaViolation {
  validate_wml_simple_type("ST_HpsMeasure", s)
  { value: s }
}

///|
pub fn ST_HpsMeasure::new(s : String) -> ST_HpsMeasure raise SchemaViolation {
  ST_HpsMeasure::parse(s)
}

///|
pub fn ST_HpsMeasure::to_string(self : ST_HpsMeasure) -> String {
  self.value
}

///|
/// XSD simple type ST_SignedHpsMeasure from wml.xsd (§17.18).
pub struct ST_SignedHpsMeasure {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SignedHpsMeasure::parse(
  s : String,
) -> ST_SignedHpsMeasure raise SchemaViolation {
  validate_wml_simple_type("ST_SignedHpsMeasure", s)
  { value: s }
}

///|
pub fn ST_SignedHpsMeasure::new(
  s : String,
) -> ST_SignedHpsMeasure raise SchemaViolation {
  ST_SignedHpsMeasure::parse(s)
}

///|
pub fn ST_SignedHpsMeasure::to_string(self : ST_SignedHpsMeasure) -> String {
  self.value
}

///|
/// XSD simple type ST_DateTime from wml.xsd (§17.18).
pub struct ST_DateTime {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DateTime::parse(s : String) -> ST_DateTime raise SchemaViolation {
  validate_wml_simple_type("ST_DateTime", s)
  { value: s }
}

///|
pub fn ST_DateTime::new(s : String) -> ST_DateTime raise SchemaViolation {
  ST_DateTime::parse(s)
}

///|
pub fn ST_DateTime::to_string(self : ST_DateTime) -> String {
  self.value
}

///|
/// XSD simple type ST_MacroName from wml.xsd (§17.18).
pub struct ST_MacroName {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MacroName::parse(s : String) -> ST_MacroName raise SchemaViolation {
  validate_wml_simple_type("ST_MacroName", s)
  { value: s }
}

///|
pub fn ST_MacroName::new(s : String) -> ST_MacroName raise SchemaViolation {
  ST_MacroName::parse(s)
}

///|
pub fn ST_MacroName::to_string(self : ST_MacroName) -> String {
  self.value
}

///|
/// XSD simple type ST_EighthPointMeasure from wml.xsd (§17.18).
pub struct ST_EighthPointMeasure {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_EighthPointMeasure::parse(
  s : String,
) -> ST_EighthPointMeasure raise SchemaViolation {
  validate_wml_simple_type("ST_EighthPointMeasure", s)
  { value: s }
}

///|
pub fn ST_EighthPointMeasure::new(
  s : String,
) -> ST_EighthPointMeasure raise SchemaViolation {
  ST_EighthPointMeasure::parse(s)
}

///|
pub fn ST_EighthPointMeasure::to_string(self : ST_EighthPointMeasure) -> String {
  self.value
}

///|
/// XSD simple type ST_PointMeasure from wml.xsd (§17.18).
pub struct ST_PointMeasure {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PointMeasure::parse(
  s : String,
) -> ST_PointMeasure raise SchemaViolation {
  validate_wml_simple_type("ST_PointMeasure", s)
  { value: s }
}

///|
pub fn ST_PointMeasure::new(
  s : String,
) -> ST_PointMeasure raise SchemaViolation {
  ST_PointMeasure::parse(s)
}

///|
pub fn ST_PointMeasure::to_string(self : ST_PointMeasure) -> String {
  self.value
}

///|
/// XSD simple type ST_TextScale from wml.xsd (§17.18).
pub struct ST_TextScale {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextScale::parse(s : String) -> ST_TextScale raise SchemaViolation {
  validate_wml_simple_type("ST_TextScale", s)
  { value: s }
}

///|
pub fn ST_TextScale::new(s : String) -> ST_TextScale raise SchemaViolation {
  ST_TextScale::parse(s)
}

///|
pub fn ST_TextScale::to_string(self : ST_TextScale) -> String {
  self.value
}

///|
/// XSD simple type ST_TextScalePercent from wml.xsd (§17.18).
pub struct ST_TextScalePercent {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextScalePercent::parse(
  s : String,
) -> ST_TextScalePercent raise SchemaViolation {
  validate_wml_simple_type("ST_TextScalePercent", s)
  { value: s }
}

///|
pub fn ST_TextScalePercent::new(
  s : String,
) -> ST_TextScalePercent raise SchemaViolation {
  ST_TextScalePercent::parse(s)
}

///|
pub fn ST_TextScalePercent::to_string(self : ST_TextScalePercent) -> String {
  self.value
}

///|
/// XSD simple type ST_HighlightColor from wml.xsd (§17.18).
pub struct ST_HighlightColor {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_HighlightColor::parse(
  s : String,
) -> ST_HighlightColor raise SchemaViolation {
  validate_wml_simple_type("ST_HighlightColor", s)
  { value: s }
}

///|
pub fn ST_HighlightColor::new(
  s : String,
) -> ST_HighlightColor raise SchemaViolation {
  ST_HighlightColor::parse(s)
}

///|
pub fn ST_HighlightColor::to_string(self : ST_HighlightColor) -> String {
  self.value
}

///|
/// XSD simple type ST_HexColorAuto from wml.xsd (§17.18).
pub struct ST_HexColorAuto {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_HexColorAuto::parse(
  s : String,
) -> ST_HexColorAuto raise SchemaViolation {
  validate_wml_simple_type("ST_HexColorAuto", s)
  { value: s }
}

///|
pub fn ST_HexColorAuto::new(
  s : String,
) -> ST_HexColorAuto raise SchemaViolation {
  ST_HexColorAuto::parse(s)
}

///|
pub fn ST_HexColorAuto::to_string(self : ST_HexColorAuto) -> String {
  self.value
}

///|
/// XSD simple type ST_HexColor from wml.xsd (§17.18).
pub struct ST_HexColor {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_HexColor::parse(s : String) -> ST_HexColor raise SchemaViolation {
  validate_wml_simple_type("ST_HexColor", s)
  { value: s }
}

///|
pub fn ST_HexColor::new(s : String) -> ST_HexColor raise SchemaViolation {
  ST_HexColor::parse(s)
}

///|
pub fn ST_HexColor::to_string(self : ST_HexColor) -> String {
  self.value
}

///|
/// XSD simple type ST_Underline from wml.xsd (§17.18).
pub struct ST_Underline {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Underline::parse(s : String) -> ST_Underline raise SchemaViolation {
  validate_wml_simple_type("ST_Underline", s)
  { value: s }
}

///|
pub fn ST_Underline::new(s : String) -> ST_Underline raise SchemaViolation {
  ST_Underline::parse(s)
}

///|
pub fn ST_Underline::to_string(self : ST_Underline) -> String {
  self.value
}

///|
/// XSD simple type ST_TextEffect from wml.xsd (§17.18).
pub struct ST_TextEffect {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextEffect::parse(s : String) -> ST_TextEffect raise SchemaViolation {
  validate_wml_simple_type("ST_TextEffect", s)
  { value: s }
}

///|
pub fn ST_TextEffect::new(s : String) -> ST_TextEffect raise SchemaViolation {
  ST_TextEffect::parse(s)
}

///|
pub fn ST_TextEffect::to_string(self : ST_TextEffect) -> String {
  self.value
}

///|
/// XSD simple type ST_Border from wml.xsd (§17.18).
pub struct ST_Border {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Border::parse(s : String) -> ST_Border raise SchemaViolation {
  validate_wml_simple_type("ST_Border", s)
  { value: s }
}

///|
pub fn ST_Border::new(s : String) -> ST_Border raise SchemaViolation {
  ST_Border::parse(s)
}

///|
pub fn ST_Border::to_string(self : ST_Border) -> String {
  self.value
}

///|
/// XSD simple type ST_Shd from wml.xsd (§17.18).
pub struct ST_Shd {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Shd::parse(s : String) -> ST_Shd raise SchemaViolation {
  validate_wml_simple_type("ST_Shd", s)
  { value: s }
}

///|
pub fn ST_Shd::new(s : String) -> ST_Shd raise SchemaViolation {
  ST_Shd::parse(s)
}

///|
pub fn ST_Shd::to_string(self : ST_Shd) -> String {
  self.value
}

///|
/// XSD simple type ST_Em from wml.xsd (§17.18).
pub struct ST_Em {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Em::parse(s : String) -> ST_Em raise SchemaViolation {
  validate_wml_simple_type("ST_Em", s)
  { value: s }
}

///|
pub fn ST_Em::new(s : String) -> ST_Em raise SchemaViolation {
  ST_Em::parse(s)
}

///|
pub fn ST_Em::to_string(self : ST_Em) -> String {
  self.value
}

///|
/// XSD simple type ST_CombineBrackets from wml.xsd (§17.18).
pub struct ST_CombineBrackets {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CombineBrackets::parse(
  s : String,
) -> ST_CombineBrackets raise SchemaViolation {
  validate_wml_simple_type("ST_CombineBrackets", s)
  { value: s }
}

///|
pub fn ST_CombineBrackets::new(
  s : String,
) -> ST_CombineBrackets raise SchemaViolation {
  ST_CombineBrackets::parse(s)
}

///|
pub fn ST_CombineBrackets::to_string(self : ST_CombineBrackets) -> String {
  self.value
}

///|
/// XSD simple type ST_HeightRule from wml.xsd (§17.18).
pub struct ST_HeightRule {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_HeightRule::parse(s : String) -> ST_HeightRule raise SchemaViolation {
  validate_wml_simple_type("ST_HeightRule", s)
  { value: s }
}

///|
pub fn ST_HeightRule::new(s : String) -> ST_HeightRule raise SchemaViolation {
  ST_HeightRule::parse(s)
}

///|
pub fn ST_HeightRule::to_string(self : ST_HeightRule) -> String {
  self.value
}

///|
/// XSD simple type ST_Wrap from wml.xsd (§17.18).
pub struct ST_Wrap {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Wrap::parse(s : String) -> ST_Wrap raise SchemaViolation {
  validate_wml_simple_type("ST_Wrap", s)
  { value: s }
}

///|
pub fn ST_Wrap::new(s : String) -> ST_Wrap raise SchemaViolation {
  ST_Wrap::parse(s)
}

///|
pub fn ST_Wrap::to_string(self : ST_Wrap) -> String {
  self.value
}

///|
/// XSD simple type ST_VAnchor from wml.xsd (§17.18).
pub struct ST_VAnchor {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_VAnchor::parse(s : String) -> ST_VAnchor raise SchemaViolation {
  validate_wml_simple_type("ST_VAnchor", s)
  { value: s }
}

///|
pub fn ST_VAnchor::new(s : String) -> ST_VAnchor raise SchemaViolation {
  ST_VAnchor::parse(s)
}

///|
pub fn ST_VAnchor::to_string(self : ST_VAnchor) -> String {
  self.value
}

///|
/// XSD simple type ST_HAnchor from wml.xsd (§17.18).
pub struct ST_HAnchor {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_HAnchor::parse(s : String) -> ST_HAnchor raise SchemaViolation {
  validate_wml_simple_type("ST_HAnchor", s)
  { value: s }
}

///|
pub fn ST_HAnchor::new(s : String) -> ST_HAnchor raise SchemaViolation {
  ST_HAnchor::parse(s)
}

///|
pub fn ST_HAnchor::to_string(self : ST_HAnchor) -> String {
  self.value
}

///|
/// XSD simple type ST_DropCap from wml.xsd (§17.18).
pub struct ST_DropCap {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DropCap::parse(s : String) -> ST_DropCap raise SchemaViolation {
  validate_wml_simple_type("ST_DropCap", s)
  { value: s }
}

///|
pub fn ST_DropCap::new(s : String) -> ST_DropCap raise SchemaViolation {
  ST_DropCap::parse(s)
}

///|
pub fn ST_DropCap::to_string(self : ST_DropCap) -> String {
  self.value
}

///|
/// XSD simple type ST_TabJc from wml.xsd (§17.18).
pub struct ST_TabJc {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TabJc::parse(s : String) -> ST_TabJc raise SchemaViolation {
  validate_wml_simple_type("ST_TabJc", s)
  { value: s }
}

///|
pub fn ST_TabJc::new(s : String) -> ST_TabJc raise SchemaViolation {
  ST_TabJc::parse(s)
}

///|
pub fn ST_TabJc::to_string(self : ST_TabJc) -> String {
  self.value
}

///|
/// XSD simple type ST_TabTlc from wml.xsd (§17.18).
pub struct ST_TabTlc {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TabTlc::parse(s : String) -> ST_TabTlc raise SchemaViolation {
  validate_wml_simple_type("ST_TabTlc", s)
  { value: s }
}

///|
pub fn ST_TabTlc::new(s : String) -> ST_TabTlc raise SchemaViolation {
  ST_TabTlc::parse(s)
}

///|
pub fn ST_TabTlc::to_string(self : ST_TabTlc) -> String {
  self.value
}

///|
/// XSD simple type ST_LineSpacingRule from wml.xsd (§17.18).
pub struct ST_LineSpacingRule {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_LineSpacingRule::parse(
  s : String,
) -> ST_LineSpacingRule raise SchemaViolation {
  validate_wml_simple_type("ST_LineSpacingRule", s)
  { value: s }
}

///|
pub fn ST_LineSpacingRule::new(
  s : String,
) -> ST_LineSpacingRule raise SchemaViolation {
  ST_LineSpacingRule::parse(s)
}

///|
pub fn ST_LineSpacingRule::to_string(self : ST_LineSpacingRule) -> String {
  self.value
}

///|
/// XSD simple type ST_Jc from wml.xsd (§17.18).
pub struct ST_Jc {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Jc::parse(s : String) -> ST_Jc raise SchemaViolation {
  validate_wml_simple_type("ST_Jc", s)
  { value: s }
}

///|
pub fn ST_Jc::new(s : String) -> ST_Jc raise SchemaViolation {
  ST_Jc::parse(s)
}

///|
pub fn ST_Jc::to_string(self : ST_Jc) -> String {
  self.value
}

///|
/// XSD simple type ST_JcTable from wml.xsd (§17.18).
pub struct ST_JcTable {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_JcTable::parse(s : String) -> ST_JcTable raise SchemaViolation {
  validate_wml_simple_type("ST_JcTable", s)
  { value: s }
}

///|
pub fn ST_JcTable::new(s : String) -> ST_JcTable raise SchemaViolation {
  ST_JcTable::parse(s)
}

///|
pub fn ST_JcTable::to_string(self : ST_JcTable) -> String {
  self.value
}

///|
/// XSD simple type ST_View from wml.xsd (§17.18).
pub struct ST_View {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_View::parse(s : String) -> ST_View raise SchemaViolation {
  validate_wml_simple_type("ST_View", s)
  { value: s }
}

///|
pub fn ST_View::new(s : String) -> ST_View raise SchemaViolation {
  ST_View::parse(s)
}

///|
pub fn ST_View::to_string(self : ST_View) -> String {
  self.value
}

///|
/// XSD simple type ST_Zoom from wml.xsd (§17.18).
pub struct ST_Zoom {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Zoom::parse(s : String) -> ST_Zoom raise SchemaViolation {
  validate_wml_simple_type("ST_Zoom", s)
  { value: s }
}

///|
pub fn ST_Zoom::new(s : String) -> ST_Zoom raise SchemaViolation {
  ST_Zoom::parse(s)
}

///|
pub fn ST_Zoom::to_string(self : ST_Zoom) -> String {
  self.value
}

///|
/// XSD simple type ST_Proof from wml.xsd (§17.18).
pub struct ST_Proof {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Proof::parse(s : String) -> ST_Proof raise SchemaViolation {
  validate_wml_simple_type("ST_Proof", s)
  { value: s }
}

///|
pub fn ST_Proof::new(s : String) -> ST_Proof raise SchemaViolation {
  ST_Proof::parse(s)
}

///|
pub fn ST_Proof::to_string(self : ST_Proof) -> String {
  self.value
}

///|
/// XSD simple type ST_DocType from wml.xsd (§17.18).
pub struct ST_DocType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DocType::parse(s : String) -> ST_DocType raise SchemaViolation {
  validate_wml_simple_type("ST_DocType", s)
  { value: s }
}

///|
pub fn ST_DocType::new(s : String) -> ST_DocType raise SchemaViolation {
  ST_DocType::parse(s)
}

///|
pub fn ST_DocType::to_string(self : ST_DocType) -> String {
  self.value
}

///|
/// XSD simple type ST_DocProtect from wml.xsd (§17.18).
pub struct ST_DocProtect {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DocProtect::parse(s : String) -> ST_DocProtect raise SchemaViolation {
  validate_wml_simple_type("ST_DocProtect", s)
  { value: s }
}

///|
pub fn ST_DocProtect::new(s : String) -> ST_DocProtect raise SchemaViolation {
  ST_DocProtect::parse(s)
}

///|
pub fn ST_DocProtect::to_string(self : ST_DocProtect) -> String {
  self.value
}

///|
/// XSD simple type ST_MailMergeDocType from wml.xsd (§17.18).
pub struct ST_MailMergeDocType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MailMergeDocType::parse(
  s : String,
) -> ST_MailMergeDocType raise SchemaViolation {
  validate_wml_simple_type("ST_MailMergeDocType", s)
  { value: s }
}

///|
pub fn ST_MailMergeDocType::new(
  s : String,
) -> ST_MailMergeDocType raise SchemaViolation {
  ST_MailMergeDocType::parse(s)
}

///|
pub fn ST_MailMergeDocType::to_string(self : ST_MailMergeDocType) -> String {
  self.value
}

///|
/// XSD simple type ST_MailMergeDataType from wml.xsd (§17.18).
pub struct ST_MailMergeDataType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MailMergeDataType::parse(
  s : String,
) -> ST_MailMergeDataType raise SchemaViolation {
  validate_wml_simple_type("ST_MailMergeDataType", s)
  { value: s }
}

///|
pub fn ST_MailMergeDataType::new(
  s : String,
) -> ST_MailMergeDataType raise SchemaViolation {
  ST_MailMergeDataType::parse(s)
}

///|
pub fn ST_MailMergeDataType::to_string(self : ST_MailMergeDataType) -> String {
  self.value
}

///|
/// XSD simple type ST_MailMergeDest from wml.xsd (§17.18).
pub struct ST_MailMergeDest {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MailMergeDest::parse(
  s : String,
) -> ST_MailMergeDest raise SchemaViolation {
  validate_wml_simple_type("ST_MailMergeDest", s)
  { value: s }
}

///|
pub fn ST_MailMergeDest::new(
  s : String,
) -> ST_MailMergeDest raise SchemaViolation {
  ST_MailMergeDest::parse(s)
}

///|
pub fn ST_MailMergeDest::to_string(self : ST_MailMergeDest) -> String {
  self.value
}

///|
/// XSD simple type ST_MailMergeOdsoFMDFieldType from wml.xsd (§17.18).
pub struct ST_MailMergeOdsoFMDFieldType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MailMergeOdsoFMDFieldType::parse(
  s : String,
) -> ST_MailMergeOdsoFMDFieldType raise SchemaViolation {
  validate_wml_simple_type("ST_MailMergeOdsoFMDFieldType", s)
  { value: s }
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
  self.value
}

///|
/// XSD simple type ST_TextDirection from wml.xsd (§17.18).
pub struct ST_TextDirection {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextDirection::parse(
  s : String,
) -> ST_TextDirection raise SchemaViolation {
  validate_wml_simple_type("ST_TextDirection", s)
  { value: s }
}

///|
pub fn ST_TextDirection::new(
  s : String,
) -> ST_TextDirection raise SchemaViolation {
  ST_TextDirection::parse(s)
}

///|
pub fn ST_TextDirection::to_string(self : ST_TextDirection) -> String {
  self.value
}

///|
/// XSD simple type ST_TextAlignment from wml.xsd (§17.18).
pub struct ST_TextAlignment {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextAlignment::parse(
  s : String,
) -> ST_TextAlignment raise SchemaViolation {
  validate_wml_simple_type("ST_TextAlignment", s)
  { value: s }
}

///|
pub fn ST_TextAlignment::new(
  s : String,
) -> ST_TextAlignment raise SchemaViolation {
  ST_TextAlignment::parse(s)
}

///|
pub fn ST_TextAlignment::to_string(self : ST_TextAlignment) -> String {
  self.value
}

///|
/// XSD simple type ST_DisplacedByCustomXml from wml.xsd (§17.18).
pub struct ST_DisplacedByCustomXml {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DisplacedByCustomXml::parse(
  s : String,
) -> ST_DisplacedByCustomXml raise SchemaViolation {
  validate_wml_simple_type("ST_DisplacedByCustomXml", s)
  { value: s }
}

///|
pub fn ST_DisplacedByCustomXml::new(
  s : String,
) -> ST_DisplacedByCustomXml raise SchemaViolation {
  ST_DisplacedByCustomXml::parse(s)
}

///|
pub fn ST_DisplacedByCustomXml::to_string(
  self : ST_DisplacedByCustomXml,
) -> String {
  self.value
}

///|
/// XSD simple type ST_AnnotationVMerge from wml.xsd (§17.18).
pub struct ST_AnnotationVMerge {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_AnnotationVMerge::parse(
  s : String,
) -> ST_AnnotationVMerge raise SchemaViolation {
  validate_wml_simple_type("ST_AnnotationVMerge", s)
  { value: s }
}

///|
pub fn ST_AnnotationVMerge::new(
  s : String,
) -> ST_AnnotationVMerge raise SchemaViolation {
  ST_AnnotationVMerge::parse(s)
}

///|
pub fn ST_AnnotationVMerge::to_string(self : ST_AnnotationVMerge) -> String {
  self.value
}

///|
/// XSD simple type ST_TextboxTightWrap from wml.xsd (§17.18).
pub struct ST_TextboxTightWrap {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextboxTightWrap::parse(
  s : String,
) -> ST_TextboxTightWrap raise SchemaViolation {
  validate_wml_simple_type("ST_TextboxTightWrap", s)
  { value: s }
}

///|
pub fn ST_TextboxTightWrap::new(
  s : String,
) -> ST_TextboxTightWrap raise SchemaViolation {
  ST_TextboxTightWrap::parse(s)
}

///|
pub fn ST_TextboxTightWrap::to_string(self : ST_TextboxTightWrap) -> String {
  self.value
}

///|
/// XSD simple type ST_ObjectDrawAspect from wml.xsd (§17.18).
pub struct ST_ObjectDrawAspect {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ObjectDrawAspect::parse(
  s : String,
) -> ST_ObjectDrawAspect raise SchemaViolation {
  validate_wml_simple_type("ST_ObjectDrawAspect", s)
  { value: s }
}

///|
pub fn ST_ObjectDrawAspect::new(
  s : String,
) -> ST_ObjectDrawAspect raise SchemaViolation {
  ST_ObjectDrawAspect::parse(s)
}

///|
pub fn ST_ObjectDrawAspect::to_string(self : ST_ObjectDrawAspect) -> String {
  self.value
}

///|
/// XSD simple type ST_ObjectUpdateMode from wml.xsd (§17.18).
pub struct ST_ObjectUpdateMode {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ObjectUpdateMode::parse(
  s : String,
) -> ST_ObjectUpdateMode raise SchemaViolation {
  validate_wml_simple_type("ST_ObjectUpdateMode", s)
  { value: s }
}

///|
pub fn ST_ObjectUpdateMode::new(
  s : String,
) -> ST_ObjectUpdateMode raise SchemaViolation {
  ST_ObjectUpdateMode::parse(s)
}

///|
pub fn ST_ObjectUpdateMode::to_string(self : ST_ObjectUpdateMode) -> String {
  self.value
}

///|
/// XSD simple type ST_FldCharType from wml.xsd (§17.18).
pub struct ST_FldCharType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FldCharType::parse(
  s : String,
) -> ST_FldCharType raise SchemaViolation {
  validate_wml_simple_type("ST_FldCharType", s)
  { value: s }
}

///|
pub fn ST_FldCharType::new(s : String) -> ST_FldCharType raise SchemaViolation {
  ST_FldCharType::parse(s)
}

///|
pub fn ST_FldCharType::to_string(self : ST_FldCharType) -> String {
  self.value
}

///|
/// XSD simple type ST_InfoTextType from wml.xsd (§17.18).
pub struct ST_InfoTextType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_InfoTextType::parse(
  s : String,
) -> ST_InfoTextType raise SchemaViolation {
  validate_wml_simple_type("ST_InfoTextType", s)
  { value: s }
}

///|
pub fn ST_InfoTextType::new(
  s : String,
) -> ST_InfoTextType raise SchemaViolation {
  ST_InfoTextType::parse(s)
}

///|
pub fn ST_InfoTextType::to_string(self : ST_InfoTextType) -> String {
  self.value
}

///|
/// XSD simple type ST_FFHelpTextVal from wml.xsd (§17.18).
pub struct ST_FFHelpTextVal {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FFHelpTextVal::parse(
  s : String,
) -> ST_FFHelpTextVal raise SchemaViolation {
  validate_wml_simple_type("ST_FFHelpTextVal", s)
  { value: s }
}

///|
pub fn ST_FFHelpTextVal::new(
  s : String,
) -> ST_FFHelpTextVal raise SchemaViolation {
  ST_FFHelpTextVal::parse(s)
}

///|
pub fn ST_FFHelpTextVal::to_string(self : ST_FFHelpTextVal) -> String {
  self.value
}

///|
/// XSD simple type ST_FFStatusTextVal from wml.xsd (§17.18).
pub struct ST_FFStatusTextVal {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FFStatusTextVal::parse(
  s : String,
) -> ST_FFStatusTextVal raise SchemaViolation {
  validate_wml_simple_type("ST_FFStatusTextVal", s)
  { value: s }
}

///|
pub fn ST_FFStatusTextVal::new(
  s : String,
) -> ST_FFStatusTextVal raise SchemaViolation {
  ST_FFStatusTextVal::parse(s)
}

///|
pub fn ST_FFStatusTextVal::to_string(self : ST_FFStatusTextVal) -> String {
  self.value
}

///|
/// XSD simple type ST_FFName from wml.xsd (§17.18).
pub struct ST_FFName {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FFName::parse(s : String) -> ST_FFName raise SchemaViolation {
  validate_wml_simple_type("ST_FFName", s)
  { value: s }
}

///|
pub fn ST_FFName::new(s : String) -> ST_FFName raise SchemaViolation {
  ST_FFName::parse(s)
}

///|
pub fn ST_FFName::to_string(self : ST_FFName) -> String {
  self.value
}

///|
/// XSD simple type ST_FFTextType from wml.xsd (§17.18).
pub struct ST_FFTextType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FFTextType::parse(s : String) -> ST_FFTextType raise SchemaViolation {
  validate_wml_simple_type("ST_FFTextType", s)
  { value: s }
}

///|
pub fn ST_FFTextType::new(s : String) -> ST_FFTextType raise SchemaViolation {
  ST_FFTextType::parse(s)
}

///|
pub fn ST_FFTextType::to_string(self : ST_FFTextType) -> String {
  self.value
}

///|
/// XSD simple type ST_SectionMark from wml.xsd (§17.18).
pub struct ST_SectionMark {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SectionMark::parse(
  s : String,
) -> ST_SectionMark raise SchemaViolation {
  validate_wml_simple_type("ST_SectionMark", s)
  { value: s }
}

///|
pub fn ST_SectionMark::new(s : String) -> ST_SectionMark raise SchemaViolation {
  ST_SectionMark::parse(s)
}

///|
pub fn ST_SectionMark::to_string(self : ST_SectionMark) -> String {
  self.value
}

///|
/// XSD simple type ST_NumberFormat from wml.xsd (§17.18).
pub struct ST_NumberFormat {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_NumberFormat::parse(
  s : String,
) -> ST_NumberFormat raise SchemaViolation {
  validate_wml_simple_type("ST_NumberFormat", s)
  { value: s }
}

///|
pub fn ST_NumberFormat::new(
  s : String,
) -> ST_NumberFormat raise SchemaViolation {
  ST_NumberFormat::parse(s)
}

///|
pub fn ST_NumberFormat::to_string(self : ST_NumberFormat) -> String {
  self.value
}

///|
/// XSD simple type ST_PageOrientation from wml.xsd (§17.18).
pub struct ST_PageOrientation {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PageOrientation::parse(
  s : String,
) -> ST_PageOrientation raise SchemaViolation {
  validate_wml_simple_type("ST_PageOrientation", s)
  { value: s }
}

///|
pub fn ST_PageOrientation::new(
  s : String,
) -> ST_PageOrientation raise SchemaViolation {
  ST_PageOrientation::parse(s)
}

///|
pub fn ST_PageOrientation::to_string(self : ST_PageOrientation) -> String {
  self.value
}

///|
/// XSD simple type ST_PageBorderZOrder from wml.xsd (§17.18).
pub struct ST_PageBorderZOrder {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PageBorderZOrder::parse(
  s : String,
) -> ST_PageBorderZOrder raise SchemaViolation {
  validate_wml_simple_type("ST_PageBorderZOrder", s)
  { value: s }
}

///|
pub fn ST_PageBorderZOrder::new(
  s : String,
) -> ST_PageBorderZOrder raise SchemaViolation {
  ST_PageBorderZOrder::parse(s)
}

///|
pub fn ST_PageBorderZOrder::to_string(self : ST_PageBorderZOrder) -> String {
  self.value
}

///|
/// XSD simple type ST_PageBorderDisplay from wml.xsd (§17.18).
pub struct ST_PageBorderDisplay {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PageBorderDisplay::parse(
  s : String,
) -> ST_PageBorderDisplay raise SchemaViolation {
  validate_wml_simple_type("ST_PageBorderDisplay", s)
  { value: s }
}

///|
pub fn ST_PageBorderDisplay::new(
  s : String,
) -> ST_PageBorderDisplay raise SchemaViolation {
  ST_PageBorderDisplay::parse(s)
}

///|
pub fn ST_PageBorderDisplay::to_string(self : ST_PageBorderDisplay) -> String {
  self.value
}

///|
/// XSD simple type ST_PageBorderOffset from wml.xsd (§17.18).
pub struct ST_PageBorderOffset {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PageBorderOffset::parse(
  s : String,
) -> ST_PageBorderOffset raise SchemaViolation {
  validate_wml_simple_type("ST_PageBorderOffset", s)
  { value: s }
}

///|
pub fn ST_PageBorderOffset::new(
  s : String,
) -> ST_PageBorderOffset raise SchemaViolation {
  ST_PageBorderOffset::parse(s)
}

///|
pub fn ST_PageBorderOffset::to_string(self : ST_PageBorderOffset) -> String {
  self.value
}

///|
/// XSD simple type ST_ChapterSep from wml.xsd (§17.18).
pub struct ST_ChapterSep {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ChapterSep::parse(s : String) -> ST_ChapterSep raise SchemaViolation {
  validate_wml_simple_type("ST_ChapterSep", s)
  { value: s }
}

///|
pub fn ST_ChapterSep::new(s : String) -> ST_ChapterSep raise SchemaViolation {
  ST_ChapterSep::parse(s)
}

///|
pub fn ST_ChapterSep::to_string(self : ST_ChapterSep) -> String {
  self.value
}

///|
/// XSD simple type ST_LineNumberRestart from wml.xsd (§17.18).
pub struct ST_LineNumberRestart {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_LineNumberRestart::parse(
  s : String,
) -> ST_LineNumberRestart raise SchemaViolation {
  validate_wml_simple_type("ST_LineNumberRestart", s)
  { value: s }
}

///|
pub fn ST_LineNumberRestart::new(
  s : String,
) -> ST_LineNumberRestart raise SchemaViolation {
  ST_LineNumberRestart::parse(s)
}

///|
pub fn ST_LineNumberRestart::to_string(self : ST_LineNumberRestart) -> String {
  self.value
}

///|
/// XSD simple type ST_VerticalJc from wml.xsd (§17.18).
pub struct ST_VerticalJc {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_VerticalJc::parse(s : String) -> ST_VerticalJc raise SchemaViolation {
  validate_wml_simple_type("ST_VerticalJc", s)
  { value: s }
}

///|
pub fn ST_VerticalJc::new(s : String) -> ST_VerticalJc raise SchemaViolation {
  ST_VerticalJc::parse(s)
}

///|
pub fn ST_VerticalJc::to_string(self : ST_VerticalJc) -> String {
  self.value
}

///|
/// XSD simple type ST_DocGrid from wml.xsd (§17.18).
pub struct ST_DocGrid {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DocGrid::parse(s : String) -> ST_DocGrid raise SchemaViolation {
  validate_wml_simple_type("ST_DocGrid", s)
  { value: s }
}

///|
pub fn ST_DocGrid::new(s : String) -> ST_DocGrid raise SchemaViolation {
  ST_DocGrid::parse(s)
}

///|
pub fn ST_DocGrid::to_string(self : ST_DocGrid) -> String {
  self.value
}

///|
/// XSD simple type ST_HdrFtr from wml.xsd (§17.18).
pub struct ST_HdrFtr {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_HdrFtr::parse(s : String) -> ST_HdrFtr raise SchemaViolation {
  validate_wml_simple_type("ST_HdrFtr", s)
  { value: s }
}

///|
pub fn ST_HdrFtr::new(s : String) -> ST_HdrFtr raise SchemaViolation {
  ST_HdrFtr::parse(s)
}

///|
pub fn ST_HdrFtr::to_string(self : ST_HdrFtr) -> String {
  self.value
}

///|
/// XSD simple type ST_FtnEdn from wml.xsd (§17.18).
pub struct ST_FtnEdn {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FtnEdn::parse(s : String) -> ST_FtnEdn raise SchemaViolation {
  validate_wml_simple_type("ST_FtnEdn", s)
  { value: s }
}

///|
pub fn ST_FtnEdn::new(s : String) -> ST_FtnEdn raise SchemaViolation {
  ST_FtnEdn::parse(s)
}

///|
pub fn ST_FtnEdn::to_string(self : ST_FtnEdn) -> String {
  self.value
}

///|
/// XSD simple type ST_BrType from wml.xsd (§17.18).
pub struct ST_BrType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_BrType::parse(s : String) -> ST_BrType raise SchemaViolation {
  validate_wml_simple_type("ST_BrType", s)
  { value: s }
}

///|
pub fn ST_BrType::new(s : String) -> ST_BrType raise SchemaViolation {
  ST_BrType::parse(s)
}

///|
pub fn ST_BrType::to_string(self : ST_BrType) -> String {
  self.value
}

///|
/// XSD simple type ST_BrClear from wml.xsd (§17.18).
pub struct ST_BrClear {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_BrClear::parse(s : String) -> ST_BrClear raise SchemaViolation {
  validate_wml_simple_type("ST_BrClear", s)
  { value: s }
}

///|
pub fn ST_BrClear::new(s : String) -> ST_BrClear raise SchemaViolation {
  ST_BrClear::parse(s)
}

///|
pub fn ST_BrClear::to_string(self : ST_BrClear) -> String {
  self.value
}

///|
/// XSD simple type ST_PTabAlignment from wml.xsd (§17.18).
pub struct ST_PTabAlignment {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PTabAlignment::parse(
  s : String,
) -> ST_PTabAlignment raise SchemaViolation {
  validate_wml_simple_type("ST_PTabAlignment", s)
  { value: s }
}

///|
pub fn ST_PTabAlignment::new(
  s : String,
) -> ST_PTabAlignment raise SchemaViolation {
  ST_PTabAlignment::parse(s)
}

///|
pub fn ST_PTabAlignment::to_string(self : ST_PTabAlignment) -> String {
  self.value
}

///|
/// XSD simple type ST_PTabRelativeTo from wml.xsd (§17.18).
pub struct ST_PTabRelativeTo {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PTabRelativeTo::parse(
  s : String,
) -> ST_PTabRelativeTo raise SchemaViolation {
  validate_wml_simple_type("ST_PTabRelativeTo", s)
  { value: s }
}

///|
pub fn ST_PTabRelativeTo::new(
  s : String,
) -> ST_PTabRelativeTo raise SchemaViolation {
  ST_PTabRelativeTo::parse(s)
}

///|
pub fn ST_PTabRelativeTo::to_string(self : ST_PTabRelativeTo) -> String {
  self.value
}

///|
/// XSD simple type ST_PTabLeader from wml.xsd (§17.18).
pub struct ST_PTabLeader {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_PTabLeader::parse(s : String) -> ST_PTabLeader raise SchemaViolation {
  validate_wml_simple_type("ST_PTabLeader", s)
  { value: s }
}

///|
pub fn ST_PTabLeader::new(s : String) -> ST_PTabLeader raise SchemaViolation {
  ST_PTabLeader::parse(s)
}

///|
pub fn ST_PTabLeader::to_string(self : ST_PTabLeader) -> String {
  self.value
}

///|
/// XSD simple type ST_ProofErr from wml.xsd (§17.18).
pub struct ST_ProofErr {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ProofErr::parse(s : String) -> ST_ProofErr raise SchemaViolation {
  validate_wml_simple_type("ST_ProofErr", s)
  { value: s }
}

///|
pub fn ST_ProofErr::new(s : String) -> ST_ProofErr raise SchemaViolation {
  ST_ProofErr::parse(s)
}

///|
pub fn ST_ProofErr::to_string(self : ST_ProofErr) -> String {
  self.value
}

///|
/// XSD simple type ST_EdGrp from wml.xsd (§17.18).
pub struct ST_EdGrp {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_EdGrp::parse(s : String) -> ST_EdGrp raise SchemaViolation {
  validate_wml_simple_type("ST_EdGrp", s)
  { value: s }
}

///|
pub fn ST_EdGrp::new(s : String) -> ST_EdGrp raise SchemaViolation {
  ST_EdGrp::parse(s)
}

///|
pub fn ST_EdGrp::to_string(self : ST_EdGrp) -> String {
  self.value
}

///|
/// XSD simple type ST_Hint from wml.xsd (§17.18).
pub struct ST_Hint {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Hint::parse(s : String) -> ST_Hint raise SchemaViolation {
  validate_wml_simple_type("ST_Hint", s)
  { value: s }
}

///|
pub fn ST_Hint::new(s : String) -> ST_Hint raise SchemaViolation {
  ST_Hint::parse(s)
}

///|
pub fn ST_Hint::to_string(self : ST_Hint) -> String {
  self.value
}

///|
/// XSD simple type ST_Theme from wml.xsd (§17.18).
pub struct ST_Theme {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Theme::parse(s : String) -> ST_Theme raise SchemaViolation {
  validate_wml_simple_type("ST_Theme", s)
  { value: s }
}

///|
pub fn ST_Theme::new(s : String) -> ST_Theme raise SchemaViolation {
  ST_Theme::parse(s)
}

///|
pub fn ST_Theme::to_string(self : ST_Theme) -> String {
  self.value
}

///|
/// XSD simple type ST_RubyAlign from wml.xsd (§17.18).
pub struct ST_RubyAlign {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_RubyAlign::parse(s : String) -> ST_RubyAlign raise SchemaViolation {
  validate_wml_simple_type("ST_RubyAlign", s)
  { value: s }
}

///|
pub fn ST_RubyAlign::new(s : String) -> ST_RubyAlign raise SchemaViolation {
  ST_RubyAlign::parse(s)
}

///|
pub fn ST_RubyAlign::to_string(self : ST_RubyAlign) -> String {
  self.value
}

///|
/// XSD simple type ST_Lock from wml.xsd (§17.18).
pub struct ST_Lock {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Lock::parse(s : String) -> ST_Lock raise SchemaViolation {
  validate_wml_simple_type("ST_Lock", s)
  { value: s }
}

///|
pub fn ST_Lock::new(s : String) -> ST_Lock raise SchemaViolation {
  ST_Lock::parse(s)
}

///|
pub fn ST_Lock::to_string(self : ST_Lock) -> String {
  self.value
}

///|
/// XSD simple type ST_SdtDateMappingType from wml.xsd (§17.18).
pub struct ST_SdtDateMappingType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_SdtDateMappingType::parse(
  s : String,
) -> ST_SdtDateMappingType raise SchemaViolation {
  validate_wml_simple_type("ST_SdtDateMappingType", s)
  { value: s }
}

///|
pub fn ST_SdtDateMappingType::new(
  s : String,
) -> ST_SdtDateMappingType raise SchemaViolation {
  ST_SdtDateMappingType::parse(s)
}

///|
pub fn ST_SdtDateMappingType::to_string(self : ST_SdtDateMappingType) -> String {
  self.value
}

///|
/// XSD simple type ST_Direction from wml.xsd (§17.18).
pub struct ST_Direction {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Direction::parse(s : String) -> ST_Direction raise SchemaViolation {
  validate_wml_simple_type("ST_Direction", s)
  { value: s }
}

///|
pub fn ST_Direction::new(s : String) -> ST_Direction raise SchemaViolation {
  ST_Direction::parse(s)
}

///|
pub fn ST_Direction::to_string(self : ST_Direction) -> String {
  self.value
}

///|
/// XSD simple type ST_TblWidth from wml.xsd (§17.18).
pub struct ST_TblWidth {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TblWidth::parse(s : String) -> ST_TblWidth raise SchemaViolation {
  validate_wml_simple_type("ST_TblWidth", s)
  { value: s }
}

///|
pub fn ST_TblWidth::new(s : String) -> ST_TblWidth raise SchemaViolation {
  ST_TblWidth::parse(s)
}

///|
pub fn ST_TblWidth::to_string(self : ST_TblWidth) -> String {
  self.value
}

///|
/// XSD simple type ST_MeasurementOrPercent from wml.xsd (§17.18).
pub struct ST_MeasurementOrPercent {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MeasurementOrPercent::parse(
  s : String,
) -> ST_MeasurementOrPercent raise SchemaViolation {
  validate_wml_simple_type("ST_MeasurementOrPercent", s)
  { value: s }
}

///|
pub fn ST_MeasurementOrPercent::new(
  s : String,
) -> ST_MeasurementOrPercent raise SchemaViolation {
  ST_MeasurementOrPercent::parse(s)
}

///|
pub fn ST_MeasurementOrPercent::to_string(
  self : ST_MeasurementOrPercent,
) -> String {
  self.value
}

///|
/// XSD simple type ST_Merge from wml.xsd (§17.18).
pub struct ST_Merge {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Merge::parse(s : String) -> ST_Merge raise SchemaViolation {
  validate_wml_simple_type("ST_Merge", s)
  { value: s }
}

///|
pub fn ST_Merge::new(s : String) -> ST_Merge raise SchemaViolation {
  ST_Merge::parse(s)
}

///|
pub fn ST_Merge::to_string(self : ST_Merge) -> String {
  self.value
}

///|
/// XSD simple type ST_TblLayoutType from wml.xsd (§17.18).
pub struct ST_TblLayoutType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TblLayoutType::parse(
  s : String,
) -> ST_TblLayoutType raise SchemaViolation {
  validate_wml_simple_type("ST_TblLayoutType", s)
  { value: s }
}

///|
pub fn ST_TblLayoutType::new(
  s : String,
) -> ST_TblLayoutType raise SchemaViolation {
  ST_TblLayoutType::parse(s)
}

///|
pub fn ST_TblLayoutType::to_string(self : ST_TblLayoutType) -> String {
  self.value
}

///|
/// XSD simple type ST_TblOverlap from wml.xsd (§17.18).
pub struct ST_TblOverlap {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TblOverlap::parse(s : String) -> ST_TblOverlap raise SchemaViolation {
  validate_wml_simple_type("ST_TblOverlap", s)
  { value: s }
}

///|
pub fn ST_TblOverlap::new(s : String) -> ST_TblOverlap raise SchemaViolation {
  ST_TblOverlap::parse(s)
}

///|
pub fn ST_TblOverlap::to_string(self : ST_TblOverlap) -> String {
  self.value
}

///|
/// XSD simple type ST_FtnPos from wml.xsd (§17.18).
pub struct ST_FtnPos {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FtnPos::parse(s : String) -> ST_FtnPos raise SchemaViolation {
  validate_wml_simple_type("ST_FtnPos", s)
  { value: s }
}

///|
pub fn ST_FtnPos::new(s : String) -> ST_FtnPos raise SchemaViolation {
  ST_FtnPos::parse(s)
}

///|
pub fn ST_FtnPos::to_string(self : ST_FtnPos) -> String {
  self.value
}

///|
/// XSD simple type ST_EdnPos from wml.xsd (§17.18).
pub struct ST_EdnPos {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_EdnPos::parse(s : String) -> ST_EdnPos raise SchemaViolation {
  validate_wml_simple_type("ST_EdnPos", s)
  { value: s }
}

///|
pub fn ST_EdnPos::new(s : String) -> ST_EdnPos raise SchemaViolation {
  ST_EdnPos::parse(s)
}

///|
pub fn ST_EdnPos::to_string(self : ST_EdnPos) -> String {
  self.value
}

///|
/// XSD simple type ST_RestartNumber from wml.xsd (§17.18).
pub struct ST_RestartNumber {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_RestartNumber::parse(
  s : String,
) -> ST_RestartNumber raise SchemaViolation {
  validate_wml_simple_type("ST_RestartNumber", s)
  { value: s }
}

///|
pub fn ST_RestartNumber::new(
  s : String,
) -> ST_RestartNumber raise SchemaViolation {
  ST_RestartNumber::parse(s)
}

///|
pub fn ST_RestartNumber::to_string(self : ST_RestartNumber) -> String {
  self.value
}

///|
/// XSD simple type ST_MailMergeSourceType from wml.xsd (§17.18).
pub struct ST_MailMergeSourceType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MailMergeSourceType::parse(
  s : String,
) -> ST_MailMergeSourceType raise SchemaViolation {
  validate_wml_simple_type("ST_MailMergeSourceType", s)
  { value: s }
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
  self.value
}

///|
/// XSD simple type ST_TargetScreenSz from wml.xsd (§17.18).
pub struct ST_TargetScreenSz {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TargetScreenSz::parse(
  s : String,
) -> ST_TargetScreenSz raise SchemaViolation {
  validate_wml_simple_type("ST_TargetScreenSz", s)
  { value: s }
}

///|
pub fn ST_TargetScreenSz::new(
  s : String,
) -> ST_TargetScreenSz raise SchemaViolation {
  ST_TargetScreenSz::parse(s)
}

///|
pub fn ST_TargetScreenSz::to_string(self : ST_TargetScreenSz) -> String {
  self.value
}

///|
/// XSD simple type ST_CharacterSpacing from wml.xsd (§17.18).
pub struct ST_CharacterSpacing {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CharacterSpacing::parse(
  s : String,
) -> ST_CharacterSpacing raise SchemaViolation {
  validate_wml_simple_type("ST_CharacterSpacing", s)
  { value: s }
}

///|
pub fn ST_CharacterSpacing::new(
  s : String,
) -> ST_CharacterSpacing raise SchemaViolation {
  ST_CharacterSpacing::parse(s)
}

///|
pub fn ST_CharacterSpacing::to_string(self : ST_CharacterSpacing) -> String {
  self.value
}

///|
/// XSD simple type ST_WmlColorSchemeIndex from wml.xsd (§17.18).
pub struct ST_WmlColorSchemeIndex {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_WmlColorSchemeIndex::parse(
  s : String,
) -> ST_WmlColorSchemeIndex raise SchemaViolation {
  validate_wml_simple_type("ST_WmlColorSchemeIndex", s)
  { value: s }
}

///|
pub fn ST_WmlColorSchemeIndex::new(
  s : String,
) -> ST_WmlColorSchemeIndex raise SchemaViolation {
  ST_WmlColorSchemeIndex::parse(s)
}

///|
pub fn ST_WmlColorSchemeIndex::to_string(
  self : ST_WmlColorSchemeIndex,
) -> String {
  self.value
}

///|
/// XSD simple type ST_StyleSort from wml.xsd (§17.18).
pub struct ST_StyleSort {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_StyleSort::parse(s : String) -> ST_StyleSort raise SchemaViolation {
  validate_wml_simple_type("ST_StyleSort", s)
  { value: s }
}

///|
pub fn ST_StyleSort::new(s : String) -> ST_StyleSort raise SchemaViolation {
  ST_StyleSort::parse(s)
}

///|
pub fn ST_StyleSort::to_string(self : ST_StyleSort) -> String {
  self.value
}

///|
/// XSD simple type ST_FrameScrollbar from wml.xsd (§17.18).
pub struct ST_FrameScrollbar {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FrameScrollbar::parse(
  s : String,
) -> ST_FrameScrollbar raise SchemaViolation {
  validate_wml_simple_type("ST_FrameScrollbar", s)
  { value: s }
}

///|
pub fn ST_FrameScrollbar::new(
  s : String,
) -> ST_FrameScrollbar raise SchemaViolation {
  ST_FrameScrollbar::parse(s)
}

///|
pub fn ST_FrameScrollbar::to_string(self : ST_FrameScrollbar) -> String {
  self.value
}

///|
/// XSD simple type ST_FrameLayout from wml.xsd (§17.18).
pub struct ST_FrameLayout {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FrameLayout::parse(
  s : String,
) -> ST_FrameLayout raise SchemaViolation {
  validate_wml_simple_type("ST_FrameLayout", s)
  { value: s }
}

///|
pub fn ST_FrameLayout::new(s : String) -> ST_FrameLayout raise SchemaViolation {
  ST_FrameLayout::parse(s)
}

///|
pub fn ST_FrameLayout::to_string(self : ST_FrameLayout) -> String {
  self.value
}

///|
/// XSD simple type ST_LevelSuffix from wml.xsd (§17.18).
pub struct ST_LevelSuffix {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_LevelSuffix::parse(
  s : String,
) -> ST_LevelSuffix raise SchemaViolation {
  validate_wml_simple_type("ST_LevelSuffix", s)
  { value: s }
}

///|
pub fn ST_LevelSuffix::new(s : String) -> ST_LevelSuffix raise SchemaViolation {
  ST_LevelSuffix::parse(s)
}

///|
pub fn ST_LevelSuffix::to_string(self : ST_LevelSuffix) -> String {
  self.value
}

///|
/// XSD simple type ST_MultiLevelType from wml.xsd (§17.18).
pub struct ST_MultiLevelType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_MultiLevelType::parse(
  s : String,
) -> ST_MultiLevelType raise SchemaViolation {
  validate_wml_simple_type("ST_MultiLevelType", s)
  { value: s }
}

///|
pub fn ST_MultiLevelType::new(
  s : String,
) -> ST_MultiLevelType raise SchemaViolation {
  ST_MultiLevelType::parse(s)
}

///|
pub fn ST_MultiLevelType::to_string(self : ST_MultiLevelType) -> String {
  self.value
}

///|
/// XSD simple type ST_TblStyleOverrideType from wml.xsd (§17.18).
pub struct ST_TblStyleOverrideType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TblStyleOverrideType::parse(
  s : String,
) -> ST_TblStyleOverrideType raise SchemaViolation {
  validate_wml_simple_type("ST_TblStyleOverrideType", s)
  { value: s }
}

///|
pub fn ST_TblStyleOverrideType::new(
  s : String,
) -> ST_TblStyleOverrideType raise SchemaViolation {
  ST_TblStyleOverrideType::parse(s)
}

///|
pub fn ST_TblStyleOverrideType::to_string(
  self : ST_TblStyleOverrideType,
) -> String {
  self.value
}

///|
/// XSD simple type ST_StyleType from wml.xsd (§17.18).
pub struct ST_StyleType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_StyleType::parse(s : String) -> ST_StyleType raise SchemaViolation {
  validate_wml_simple_type("ST_StyleType", s)
  { value: s }
}

///|
pub fn ST_StyleType::new(s : String) -> ST_StyleType raise SchemaViolation {
  ST_StyleType::parse(s)
}

///|
pub fn ST_StyleType::to_string(self : ST_StyleType) -> String {
  self.value
}

///|
/// XSD simple type ST_FontFamily from wml.xsd (§17.18).
pub struct ST_FontFamily {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_FontFamily::parse(s : String) -> ST_FontFamily raise SchemaViolation {
  validate_wml_simple_type("ST_FontFamily", s)
  { value: s }
}

///|
pub fn ST_FontFamily::new(s : String) -> ST_FontFamily raise SchemaViolation {
  ST_FontFamily::parse(s)
}

///|
pub fn ST_FontFamily::to_string(self : ST_FontFamily) -> String {
  self.value
}

///|
/// XSD simple type ST_Pitch from wml.xsd (§17.18).
pub struct ST_Pitch {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_Pitch::parse(s : String) -> ST_Pitch raise SchemaViolation {
  validate_wml_simple_type("ST_Pitch", s)
  { value: s }
}

///|
pub fn ST_Pitch::new(s : String) -> ST_Pitch raise SchemaViolation {
  ST_Pitch::parse(s)
}

///|
pub fn ST_Pitch::to_string(self : ST_Pitch) -> String {
  self.value
}

///|
/// XSD simple type ST_ThemeColor from wml.xsd (§17.18).
pub struct ST_ThemeColor {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_ThemeColor::parse(s : String) -> ST_ThemeColor raise SchemaViolation {
  validate_wml_simple_type("ST_ThemeColor", s)
  { value: s }
}

///|
pub fn ST_ThemeColor::new(s : String) -> ST_ThemeColor raise SchemaViolation {
  ST_ThemeColor::parse(s)
}

///|
pub fn ST_ThemeColor::to_string(self : ST_ThemeColor) -> String {
  self.value
}

///|
/// XSD simple type ST_DocPartBehavior from wml.xsd (§17.18).
pub struct ST_DocPartBehavior {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DocPartBehavior::parse(
  s : String,
) -> ST_DocPartBehavior raise SchemaViolation {
  validate_wml_simple_type("ST_DocPartBehavior", s)
  { value: s }
}

///|
pub fn ST_DocPartBehavior::new(
  s : String,
) -> ST_DocPartBehavior raise SchemaViolation {
  ST_DocPartBehavior::parse(s)
}

///|
pub fn ST_DocPartBehavior::to_string(self : ST_DocPartBehavior) -> String {
  self.value
}

///|
/// XSD simple type ST_DocPartType from wml.xsd (§17.18).
pub struct ST_DocPartType {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DocPartType::parse(
  s : String,
) -> ST_DocPartType raise SchemaViolation {
  validate_wml_simple_type("ST_DocPartType", s)
  { value: s }
}

///|
pub fn ST_DocPartType::new(s : String) -> ST_DocPartType raise SchemaViolation {
  ST_DocPartType::parse(s)
}

///|
pub fn ST_DocPartType::to_string(self : ST_DocPartType) -> String {
  self.value
}

///|
/// XSD simple type ST_DocPartGallery from wml.xsd (§17.18).
pub struct ST_DocPartGallery {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_DocPartGallery::parse(
  s : String,
) -> ST_DocPartGallery raise SchemaViolation {
  validate_wml_simple_type("ST_DocPartGallery", s)
  { value: s }
}

///|
pub fn ST_DocPartGallery::new(
  s : String,
) -> ST_DocPartGallery raise SchemaViolation {
  ST_DocPartGallery::parse(s)
}

///|
pub fn ST_DocPartGallery::to_string(self : ST_DocPartGallery) -> String {
  self.value
}

///|
/// XSD simple type ST_CaptionPos from wml.xsd (§17.18).
pub struct ST_CaptionPos {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CaptionPos::parse(s : String) -> ST_CaptionPos raise SchemaViolation {
  validate_wml_simple_type("ST_CaptionPos", s)
  { value: s }
}

///|
pub fn ST_CaptionPos::new(s : String) -> ST_CaptionPos raise SchemaViolation {
  ST_CaptionPos::parse(s)
}

///|
pub fn ST_CaptionPos::to_string(self : ST_CaptionPos) -> String {
  self.value
}
