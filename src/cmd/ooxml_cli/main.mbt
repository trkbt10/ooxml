///|
/// Native CLI entry point for trkbt10/ooxml.
///
/// Implementation pending. Target subcommands:
///   - `ooxml inspect <file>`         dump OPC parts and content types
///   - `ooxml docx render <in> <out>` render a .docx file
///   - `ooxml xlsx render <in> <out>` render a .xlsx file
///   - `ooxml pptx render <in> <out>` render a .pptx file
fn main {
  println("trkbt10/ooxml " + @ooxml.version())
}
