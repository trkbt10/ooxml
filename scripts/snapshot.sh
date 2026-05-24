#!/usr/bin/env bash
# Rendering-fidelity snapshot harness.
#
# Walks every OOXML fixture under .snapshots/fixtures/<fmt>/<category>/
# and, for each:
#   1. renders a reference PNG via a headless office suite (PDF export
#      → pdftoppm),
#   2. renders our SVG via the ooxml CLI, converts that SVG to PDF
#      (rsvg-convert -f pdf), then rasterises the PDF with pdftoppm,
#   3. composites both at 1:1 onto a common page-origin canvas and
#      runs ImageMagick `compare` for a per-case RMSE distance.
#
# Both pipelines go through `pdftoppm` for the final raster step so
# antialias / subpixel positioning are identical on both sides.
#
# The reference render is the slow step (the office binary
# cold-starts), so it is CACHED: the reference PNG for a fixture is
# keyed by the fixture's content hash and only regenerated when the
# fixture changes. Our SVG render is fast and always regenerated.
#
# Output: .snapshots/{ref,ours,diff}/<fmt>__<category>__<name>.* and
# a category-grouped .snapshots/report.txt.
#
# Usage:
#   scripts/snapshot.sh [--no-cache] [<filter>]
#
#   <filter> — optional category-path filter to restrict the run to
#              a subset of fixtures (`<fmt>` or `<fmt>/<category>`).
#
# Requires: soffice (any headless office suite that exports PDF),
#           pdftoppm (poppler), rsvg-convert, ImageMagick.
#
# Font catalogue: the harness REQUIRES `OOXML_FONT_DIR` to be set
# (the directory `scripts/setup-test-fonts.sh` populates) so both
# the renderer and the reference office binary read the same Noto
# Sans/Serif/Mono families. Without this, font metrics drift between
# the two pipelines and RMSE numbers are meaningless.

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SNAP="$ROOT/.snapshots"
FIX="$SNAP/fixtures"
REF="$SNAP/ref"
OURS="$SNAP/ours"
DIFF="$SNAP/diff"
CACHE="$SNAP/.refcache"
REPORT="$SNAP/report.txt"
SOFFICE="${SOFFICE:-soffice}"

# Bootstrap the cross-platform test font cache. The renderer's
# FontResolver and the reference office binary both read fonts out
# of $OOXML_FONT_DIR; setup-test-fonts.sh downloads Noto Sans /
# Serif / Mono into the OS-canonical cache directory and prints the
# path. We re-run it on every invocation; the script is idempotent
# (cached files are not re-downloaded).
if [ -z "${OOXML_FONT_DIR:-}" ]; then
  case "$(uname -s)" in
    Darwin) export OOXML_FONT_DIR="${HOME}/Library/Caches/ooxml-test-fonts" ;;
    Linux)  export OOXML_FONT_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ooxml-test-fonts" ;;
    MINGW*|MSYS*|CYGWIN*) export OOXML_FONT_DIR="${LOCALAPPDATA:-$HOME/AppData/Local}/ooxml-test-fonts" ;;
    *) export OOXML_FONT_DIR="${TMPDIR:-/tmp}/ooxml-test-fonts" ;;
  esac
fi
if [ ! -f "$OOXML_FONT_DIR/NotoSans-Regular.ttf" ]; then
  bash "$ROOT/scripts/setup-test-fonts.sh"
fi

# Snapshot-scoped fontconfig that points the rasteriser at the same
# Noto catalogue as the renderer. The user's system fontconfig is
# untouched — we only set $FONTCONFIG_FILE for this script.
FONT_CONF_DIR="$SNAP/fontconfig"
mkdir -p "$FONT_CONF_DIR"
cat > "$FONT_CONF_DIR/fonts.conf" <<FCEOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>${OOXML_FONT_DIR}</dir>
  <cachedir>${SNAP}/fontconfig-cache</cachedir>
  <alias>
    <family>sans-serif</family>
    <prefer><family>Noto Sans</family></prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer><family>Noto Serif</family></prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer><family>Noto Sans Mono</family></prefer>
  </alias>
</fontconfig>
FCEOF
export FONTCONFIG_FILE="$FONT_CONF_DIR/fonts.conf"

# On macOS, Pango ships a CoreText backend by default that ignores
# $FONTCONFIG_FILE; force the fontconfig backend so the rasteriser
# walks the same catalogue the renderer measured against.
export PANGOCAIRO_BACKEND=fontconfig

NO_CACHE=0
FILTER=""
for arg in "$@"; do
  case "$arg" in
    --no-cache) NO_CACHE=1 ;;
    --help|-h)
      sed -n '1,40p' "$0"
      exit 0
      ;;
    -*) echo "snapshot.sh: unknown flag: $arg" >&2; exit 2 ;;
    *) FILTER="$arg" ;;
  esac
done
# Per-filter report path: report.txt for the full run, or e.g.
# report.pptx-shape.txt when filtered.
if [ -n "$FILTER" ]; then
  filter_safe="$(printf '%s' "$FILTER" | tr '/ ' '-')"
  REPORT="$SNAP/report.$filter_safe.txt"
fi

mkdir -p "$REF" "$OURS" "$DIFF" "$CACHE"
: > "$REPORT"

# Build the CLI once.
( cd "$ROOT" && moon build --target native --release src/cmd/ooxml_cli \
    >/dev/null 2>&1 )
CLI_BIN="$(find "$ROOT/_build/native/release" -name 'ooxml_cli*' -type f \
  -perm -u+x 2>/dev/null | head -1)"

run_cli() {
  if [ -n "${CLI_BIN:-}" ] && [ -x "$CLI_BIN" ]; then
    "$CLI_BIN" "$@"
  else
    ( cd "$ROOT" && moon run --target native src/cmd/ooxml_cli -- "$@" \
        2>/dev/null )
  fi
}

# Render a fixture's reference PNG, using the content-hash cache.
# $1 = fixture path, $2 = output PNG path.
reference_png() {
  local fixture="$1" out="$2"
  local hash key cached
  hash="$(shasum -a 256 "$fixture" | cut -d' ' -f1)"
  key="$CACHE/$hash.png"
  if [ "$NO_CACHE" -eq 0 ] && [ -f "$key" ]; then
    cp "$key" "$out"
    return 0
  fi
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap "rm -rf '$tmpdir'" RETURN
  if ! "$SOFFICE" --headless --convert-to pdf --outdir "$tmpdir" \
       "$fixture" > "$tmpdir/soffice.log" 2>&1; then
    return 1
  fi
  local pdf
  pdf="$(ls "$tmpdir"/*.pdf 2>/dev/null | head -1)"
  if [ -z "$pdf" ]; then
    return 1
  fi
  if ! pdftoppm -png -r 96 -f 1 -l 1 "$pdf" "$tmpdir/page" \
       > /dev/null 2>&1; then
    return 1
  fi
  local rendered
  rendered="$(ls "$tmpdir"/page-*.png 2>/dev/null | head -1)"
  if [ -z "$rendered" ]; then
    return 1
  fi
  cp "$rendered" "$out"
  if [ "$NO_CACHE" -eq 0 ]; then
    cp "$rendered" "$key"
  fi
}

# Render our SVG, convert through PDF, raster to PNG.
ours_png() {
  local fixture="$1" out="$2"
  local tmpdir svg pdf
  tmpdir="$(mktemp -d)"
  trap "rm -rf '$tmpdir'" RETURN
  svg="$tmpdir/out.svg"
  pdf="$tmpdir/out.pdf"
  # The CLI streams SVG to stdout via the `svg` subcommand for
  # WML/SML/PML alike; pptx slides go through `svg-for-slide` with
  # an explicit 1-based slide index. Pick whichever applies based
  # on the fixture's extension.
  case "$fixture" in
    *.pptx)
      if ! run_cli svg-for-slide "$fixture" 1 \
           > "$svg" 2> "$tmpdir/cli.log"; then
        return 1
      fi
      ;;
    *)
      if ! run_cli svg "$fixture" \
           > "$svg" 2> "$tmpdir/cli.log"; then
        return 1
      fi
      ;;
  esac
  if [ ! -s "$svg" ]; then
    return 1
  fi
  if ! rsvg-convert -f pdf "$svg" -o "$pdf" > /dev/null 2>&1; then
    return 1
  fi
  if ! pdftoppm -png -r 96 -f 1 -l 1 "$pdf" "$tmpdir/page" \
       > /dev/null 2>&1; then
    return 1
  fi
  local rendered
  rendered="$(ls "$tmpdir"/page-*.png 2>/dev/null | head -1)"
  if [ -z "$rendered" ]; then
    return 1
  fi
  cp "$rendered" "$out"
}

# Walk fixtures with `find` so the harness works under bash 3.2
# (the macOS default) — `shopt -s globstar` is bash 4+ only.
while IFS= read -r fixture; do
  rel="${fixture#$FIX/}"
  if [ -n "$FILTER" ]; then
    case "$rel" in
      "$FILTER"/*|"$FILTER"|"$FILTER".*) ;;
      *) continue ;;
    esac
  fi
  name_no_ext="${rel%.*}"
  safe="${name_no_ext//\//__}"
  ref_png="$REF/$safe.png"
  ours_png_path="$OURS/$safe.png"
  diff_png="$DIFF/$safe.png"
  if ! reference_png "$fixture" "$ref_png"; then
    printf '%s\t-\tref-fail\n' "$rel" >> "$REPORT"
    continue
  fi
  if ! ours_png "$fixture" "$ours_png_path"; then
    printf '%s\t-\tours-fail\n' "$rel" >> "$REPORT"
    continue
  fi
  # Composite both images onto a common canvas (the union of their
  # extents) so RMSE compares pixel-aligned regions.
  ref_w=$(magick identify -format '%w' "$ref_png" 2>/dev/null || echo 0)
  ref_h=$(magick identify -format '%h' "$ref_png" 2>/dev/null || echo 0)
  ours_w=$(magick identify -format '%w' "$ours_png_path" 2>/dev/null || echo 0)
  ours_h=$(magick identify -format '%h' "$ours_png_path" 2>/dev/null || echo 0)
  w=$(( ref_w > ours_w ? ref_w : ours_w ))
  h=$(( ref_h > ours_h ? ref_h : ours_h ))
  if [ "$w" -le 0 ] || [ "$h" -le 0 ]; then
    printf '%s\t-\tsize-fail\n' "$rel" >> "$REPORT"
    continue
  fi
  ref_canvas="$(mktemp).png"
  ours_canvas="$(mktemp).png"
  magick "$ref_png" -background white -extent "${w}x${h}" \
    "$ref_canvas" 2>/dev/null
  magick "$ours_png_path" -background white -extent "${w}x${h}" \
    "$ours_canvas" 2>/dev/null
  # ImageMagick's `-metric RMSE` prints `<raw> (<normalised>)`
  # where <normalised> is the 0..1 quantum-normalised value. Capture
  # the second token (inside the parens) so reports use the
  # cross-platform-portable 0..1 scale.
  rmse=$(magick compare -metric RMSE "$ref_canvas" "$ours_canvas" \
    "$diff_png" 2>&1 | awk '{print $2}' | tr -d '()')
  rm -f "$ref_canvas" "$ours_canvas"
  printf '%s\t%s\n' "$rel" "$rmse" >> "$REPORT"
done < <(find "$FIX" -type f \( -name '*.docx' -o -name '*.xlsx' -o -name '*.pptx' \) | sort)

# Summary line.
total=$(wc -l < "$REPORT" | tr -d ' ')
echo "snapshot.sh: $total fixtures → $REPORT"
