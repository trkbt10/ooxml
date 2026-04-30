///|
/// ZIP archive reader/writer (PKWARE APPNOTE.TXT 6.3.x).
///
/// Implementation pending. Will cover:
///   - Local file headers, central directory, end-of-central-directory
///   - Stored (no compression) and Deflate (RFC 1951) entries
///   - ZIP64 extensions for OOXML packages over 4GiB
pub fn package_name() -> String {
  "trkbt10/ooxml/zip"
}
