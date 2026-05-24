#!/usr/bin/env bash
# Rendering-fidelity snapshot harness.
#
# Walks every OOXML fixture under .snapshots/fixtures/<fmt>/<category>/
# and, for each:
#   1. renders a reference PNG via LibreOffice (PDF export → pdftoppm),
#   2. renders our SVG via the ooxml CLI, converts that SVG to PDF
#      (rsvg-convert -f pdf), then rasterises the PDF with pdftoppm,
#   3. composites both at 1:1 onto a common page-origin canvas and
#      runs ImageMagick `compare` for a per-case RMSE distance.
#
# The "ours" pipeline is intentionally routed through PDF so the FINAL
# rasterisation step is the SAME tool (poppler's pdftoppm) that produces
# the reference image from LibreOffice's PDF export. Going direct
# SVG → PNG with rsvg-convert uses Cairo's image surface with a
# different antialias/subpixel scheme than Cairo's PDF surface, leaving
# a ~0.05 RMSE floor on text-heavy fixtures (section columns,
# paragraph wraps) that no layout tuning could close because it was
# purely a cross-rasteriser difference. Forcing both sides through
# `pdftoppm` removes that floor: section-cols-3-equal dropped 0.061 →
# 0.021, section-margins-narrow 0.070 → 0.046, etc.
#
# The reference render is the slow step (LibreOffice cold-starts), so
# it is CACHED: the reference PNG for a fixture is keyed by the
# fixture's content hash and only regenerated when the fixture
# changes.  Our SVG render is fast and always regenerated.
#
# Output: .snapshots/{ref,ours,diff}/<fmt>__<category>__<name>.* and
# a category-grouped .snapshots/report.txt.
#
# Usage:
#   scripts/snapshot.sh [--no-cache] [<filter>]
#
#   <filter> — optional category-path filter to restrict the run to
#              a subset of fixtures, given as `<fmt>` or
#              `<fmt>/<category>` (matched against the fixture's
#              path under .snapshots/fixtures/, e.g. `pptx` or
#              `pptx/shape`).  When set, only matching fixtures are
#              snapshot-compared and a per-filter report is written
#              to .snapshots/report.<filter-safe>.txt.  Without it,
#              every fixture is processed (the original behaviour).
#              This lets subagents run independently on disjoint
#              fixture subsets without contention on report.txt or
#              the shared LibreOffice cold-start.
# Requires: soffice, pdftoppm (poppler), rsvg-convert (for both
#           SVG→PDF and PDF→PNG ours-side rasterisation), ImageMagick.
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

# Use a snapshot-scoped fontconfig that maps the CSS generic
# `sans-serif` / `serif` families to the SAME faces LibreOffice
# substitutes when rendering the PDF reference. The config is
# generated once below if missing and pinned via $FONTCONFIG_FILE
# for the rsvg invocation only — the user's system fontconfig is
# untouched.
#
# Choice of face: LibreOffice substitutes Microsoft Calibri (the
# Office 2007+ body face used by every styles-less docx fixture) with
# Carlito — the metric-compatible OFL replacement bundled inside the
# app at /Applications/LibreOffice.app/Contents/Resources/fonts. The
# previous setting aliased `sans-serif` to Liberation Sans which has
# 8-15 % WIDER per-glyph advances than Carlito (LibSans 'a' = 0.5562
# em, Carlito 'a' = 0.4790 em, 'c' .50 vs .42, 's' .50 vs .39, space
# .278 vs .226). That mismatch made our SVG render's lines visibly
# wider than LO's PDF render of the same text and pushed the section
# / paragraph-wrap fixtures to a 0.10-0.14 RMSE floor that no
# page-flow tuning could fix. Aliasing to Carlito puts both pipelines
# on the same hmtx table; the matching `sans_serif_metrics` table in
# `src/util/glyph/fonts.mbt` is keyed to Carlito too so our width
# estimator and our rendered SVG agree at every point size.
# Cambria / Liberation Serif are kept for `serif` — LO does the same
# substitution there.
FONT_CONF_DIR="$SNAP/fontconfig"
mkdir -p "$FONT_CONF_DIR"
# Always regenerate so updates to this file take effect on existing
# checkouts without requiring contributors to manually clear the
# snapshot fontconfig cache.
cat > "$FONT_CONF_DIR/fonts.conf" <<'FCEOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/System/Library/Fonts</dir>
  <dir>/System/Library/Fonts/Supplemental</dir>
  <dir>/Library/Fonts</dir>
  <dir>~/Library/Fonts</dir>
  <dir>/Applications/LibreOffice.app/Contents/Resources/fonts/truetype</dir>
  <cachedir>~/.cache/fontconfig</cachedir>
  <alias>
    <family>sans-serif</family>
    <prefer><family>Carlito</family></prefer>
  </alias>
  <alias>
    <family>sans</family>
    <prefer><family>Carlito</family></prefer>
  </alias>
  <alias>
    <family>Calibri</family>
    <prefer><family>Carlito</family></prefer>
  </alias>
  <alias>
    <family>Arial</family>
    <prefer><family>Carlito</family></prefer>
  </alias>
  <alias>
    <family>Helvetica</family>
    <prefer><family>Carlito</family></prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer><family>Liberation Serif</family></prefer>
  </alias>
  <alias>
    <family>Cambria</family>
    <prefer><family>Liberation Serif</family></prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer><family>Liberation Mono</family></prefer>
  </alias>
</fontconfig>
FCEOF
export FONTCONFIG_FILE="$FONT_CONF_DIR/fonts.conf"

# Force Pango (used by rsvg-convert for SVG <text> shaping) to resolve
# font families through fontconfig instead of CoreText on macOS.
#
# Why: Pango on macOS ships TWO backends — `coretext` (the default
# when running outside an X session) and `fontconfig`. The CoreText
# backend ignores `FONTCONFIG_FILE` entirely and discovers fonts via
# the system's font activation database (~/Library/Fonts, /Library/
# Fonts, /System/Library/Fonts and any app-registered fonts). Carlito,
# our DOCX Calibri substitute, lives only inside
# /Applications/LibreOffice.app/Contents/Resources/fonts/truetype/ —
# that directory is visible to fontconfig (declared in fonts.conf
# above) but not to CoreText, so Pango silently substitutes Carlito
# with whatever Liberation Sans / Arial / Helvetica it can find via
# CoreText. Liberation Sans is 8-15% wider per-glyph than Carlito;
# the substitution makes our SVG render's lines visibly wider than
# LO's PDF reference and produced the 0.13 RMSE residual on
# section-cols-3-equal even after the font registry was rewritten to
# use real Carlito hmtx values.
#
# Verified via a diagnostic SVG `<text font-family="Carlito"
# font-size="14.667">Lorem ipsum dolor sit amet,|</text>`:
#
#   - default (CoreText):        prefix advance ≈ 181 px (Liberation
#                                Sans — Pango cannot find Carlito)
#   - PANGOCAIRO_BACKEND=fontconfig: prefix advance ≈ 168 px (real
#                                Carlito — matches our `@glyph`
#                                measurer at 167.5 px and LO's PDF
#                                glyph positions at 167.2 px)
#
# `pango-list` confirms it: under the CoreText backend Pango lists
# zero Carlito faces; under the fontconfig backend Carlito appears.
# Setting `PANGOCAIRO_BACKEND=fontconfig` aligns rsvg-convert with
# LO's metrics and is the single-character switch that closes the
# section-cols / paragraph-wrap RMSE gap without any code or font
# changes.
export PANGOCAIRO_BACKEND=fontconfig

NO_CACHE=0
FILTER=""
for arg in "$@"; do
  case "$arg" in
    --no-cache) NO_CACHE=1 ;;
    --help|-h)
      sed -n '1,30p' "$0"
      exit 0
      ;;
    -*) echo "snapshot.sh: unknown flag: $arg" >&2; exit 2 ;;
    *) FILTER="$arg" ;;
  esac
done
# Per-filter report path: report.txt for the full run, or e.g.
# report.pptx-shape.txt when filtered, so parallel category runs do
# not clobber one another's logs.
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
  local tmp; tmp="$(mktemp -d)"
  "$SOFFICE" --headless --convert-to pdf --outdir "$tmp" "$fixture" \
    >/dev/null 2>&1
  local pdf; pdf="$(find "$tmp" -name '*.pdf' | head -1)"
  if [ -z "$pdf" ]; then rm -rf "$tmp"; return 1; fi
  pdftoppm -png -r 96 -f 1 -l 1 -singlefile "$pdf" "$tmp/page" 2>/dev/null
  if [ ! -f "$tmp/page.png" ]; then rm -rf "$tmp"; return 1; fi
  cp "$tmp/page.png" "$key"
  cp "$tmp/page.png" "$out"
  rm -rf "$tmp"
  return 0
}

total=0 ; sum=0
last_category=""

while IFS= read -r fixture; do
  rel="${fixture#"$FIX"/}"            # e.g. docx/paragraph/basic.docx
  fmt="${rel%%/*}"
  rest="${rel#*/}"
  category="${rest%%/*}"
  name="$(basename "$fixture")"
  name="${name%.*}"
  tag="${fmt}__${category}__${name}"

  if [ "$category" != "$last_category" ] || [ "$fmt" != "${last_fmt:-}" ]; then
    echo "[$fmt / $category]" | tee -a "$REPORT"
    last_category="$category" ; last_fmt="$fmt"
  fi

  # --- reference (cached) ------------------------------------------
  if ! reference_png "$fixture" "$REF/$tag.png"; then
    echo "  $name: SKIP (no reference render)" | tee -a "$REPORT"
    continue
  fi

  # --- ours --------------------------------------------------------
  run_cli svg "$fixture" > "$OURS/$tag.svg" 2>/dev/null
  if [ ! -s "$OURS/$tag.svg" ]; then
    echo "  $name: FAIL (no SVG)" | tee -a "$REPORT"
    continue
  fi
  # Replace the CSS-generic font families with the SAME concrete
  # families LibreOffice substitutes when rendering the PDF
  # reference.  rsvg-convert on macOS does not honour
  # `FONTCONFIG_FILE` for generic-family resolution (it falls back
  # to CoreText and picks Verdana for `sans-serif`); the
  # substitution is done in the SVG itself so rsvg has an explicit
  # family name to resolve, which it finds via fontconfig either
  # under `~/Library/Fonts/` (Liberation Serif/Mono) or in
  # LibreOffice's bundled `Contents/Resources/fonts/truetype/`
  # (Carlito). The change is HARNESS-LOCAL — the original SVG
  # written by the viewer stays generic.
  #
  # Why Carlito for sans-serif: LO substitutes Microsoft Calibri
  # (the Office body face used by every styles-less docx fixture)
  # with the metric-compatible OFL clone Carlito for PDF export.
  # Aliasing the SVG's `sans-serif` to Liberation Sans here would
  # use a Helvetica-clone with 8-15 % WIDER per-glyph advances
  # than Carlito and re-introduce the cross-pipeline width drift
  # that the matching `sans_serif_metrics` Carlito table in
  # `src/util/glyph/fonts.mbt` was retuned to eliminate.
  sed -i.bak \
    -e 's/font-family="sans-serif"/font-family="Carlito, sans-serif"/g' \
    -e 's/font-family="serif"/font-family="Liberation Serif, serif"/g' \
    -e 's/font-family="monospace"/font-family="Liberation Mono, monospace"/g' \
    "$OURS/$tag.svg"
  rm -f "$OURS/$tag.svg.bak"
  # Two-stage rasterisation: SVG → PDF → PNG via pdftoppm.
  #
  # Why not just `rsvg-convert <svg> -o <png>`: rsvg-convert's image
  # backend (Cairo image surface) and pdftoppm (Cairo PDF surface +
  # Splash rasteriser inside poppler) disagree on subpixel/antialias
  # rounding even when text shaping and glyph metrics are identical.
  # For text-heavy WML fixtures (sections, paragraph wraps) that
  # cross-rasteriser disagreement was a ~0.05 RMSE floor — the
  # reference render also goes through pdftoppm, so any other PNG
  # backend will lose to it on identical content.
  #
  # Pipeline: rsvg-convert emits a PDF preserving the SVG's intrinsic
  # page box at 1:1, then pdftoppm at 96 dpi rasterises it with the
  # SAME settings used for the reference. Both sides now share the
  # antialias path, leaving only true layout/glyph differences.
  ours_pdf="$OURS/$tag.pdf"
  rsvg-convert -f pdf "$OURS/$tag.svg" -o "$ours_pdf" 2>/dev/null
  if [ ! -s "$ours_pdf" ]; then
    echo "  $name: FAIL (SVG → PDF conversion)" | tee -a "$REPORT"
    continue
  fi
  pdftoppm -png -r 96 -f 1 -l 1 -singlefile "$ours_pdf" \
    "$OURS/$tag" 2>/dev/null
  rm -f "$ours_pdf"
  if [ ! -f "$OURS/$tag.png" ]; then
    echo "  $name: FAIL (PDF did not rasterise)" | tee -a "$REPORT"
    continue
  fi

  # --- normalise to a common page-origin canvas (1:1, no resample) -
  # Both renders are placed on a shared white canvas at NorthWest so
  # the comparison is 1:1 with no resampling.  (A whole-content page
  # offset — e.g. LibreOffice's PDF-print margins on a spreadsheet
  # vs our screen-origin SVG — does show up here; that is a known
  # page-convention difference, reported per-fixture, not hidden.)
  read -r RW RH < <(identify -format '%w %h' "$REF/$tag.png" 2>/dev/null)
  read -r OW OH < <(identify -format '%w %h' "$OURS/$tag.png" 2>/dev/null)
  if [ -z "${RW:-}" ] || [ -z "${OW:-}" ]; then
    echo "  $name: SKIP (cannot size renders)" | tee -a "$REPORT"
    continue
  fi
  CW=$(( RW > OW ? RW : OW ))
  CH=$(( RH > OH ? RH : OH ))
  magick "$REF/$tag.png" -background white -flatten \
    -gravity NorthWest -extent "${CW}x${CH}" "$REF/$tag.norm.png"
  magick "$OURS/$tag.png" -background white -flatten \
    -gravity NorthWest -extent "${CW}x${CH}" "$OURS/$tag.norm.png"

  RMSE="$(compare -metric RMSE "$REF/$tag.norm.png" "$OURS/$tag.norm.png" \
    "$DIFF/$tag.png" 2>&1 | sed -E 's/.*\(([0-9.]+)\).*/\1/')"
  echo "  $name: RMSE=$RMSE" | tee -a "$REPORT"
  total=$(( total + 1 ))
  sum="$(awk -v s="$sum" -v r="$RMSE" 'BEGIN{printf "%.6f", s+r}')"
done < <(
  if [ -n "$FILTER" ]; then
    # Filter is `<fmt>` or `<fmt>/<category>`; both are matched as a
    # path-prefix anchor under `$FIX/`.
    find "$FIX/$FILTER" -type f 2>/dev/null | sort
  else
    find "$FIX" -type f | sort
  fi
)

echo "----" | tee -a "$REPORT"
if [ "$total" -gt 0 ]; then
  avg="$(awk -v s="$sum" -v n="$total" 'BEGIN{printf "%.6f", s/n}')"
  echo "cases=$total  mean-RMSE=$avg" | tee -a "$REPORT"
else
  echo "no cases compared" | tee -a "$REPORT"
fi
echo "report: $REPORT"
