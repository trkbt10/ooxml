#!/usr/bin/env bash
# Provision the cross-platform test font fixture cache.
#
# Round 17 removed every bundled TTF from the repository. The
# rendering test harness needs *some* set of fonts to measure
# against, and that set must be reproducible across macOS / Linux /
# Windows so the snapshot RMSE comparisons stay deterministic.
#
# We pick the Noto family (Apache 2.0, ships from Google Fonts) for
# all three OSes because:
#   - Noto Sans / Serif / Mono cover the renderer's three generic
#     family slots without per-OS substitution.
#   - The TTFs are direct-downloadable single-file releases (no
#     per-OS packaging, no .ttc unpacking).
#   - One catalogue works for both our `@glyph` measurer and the
#     downstream rasteriser the snapshot harness drives.
#
# The cache directory follows the XDG-style temp/cache convention
# the MoonBit `trkbt10/osenv` package exposes:
#
#   macOS:   $HOME/Library/Caches/ooxml-test-fonts
#   Linux:   ${XDG_CACHE_HOME:-$HOME/.cache}/ooxml-test-fonts
#   Windows: %LOCALAPPDATA%/ooxml-test-fonts
#
# Operators export `OOXML_FONT_DIR` to the cache path before
# `moon test` / `scripts/snapshot.sh`. This script prints the
# `export` line on completion so a bare `source` integration is
# obvious.

set -euo pipefail

# Determine the cache directory using the same convention osenv
# applies on each platform. Operators can override with
# OOXML_FONT_DIR; the script still populates the indicated path.
if [[ -n "${OOXML_FONT_DIR:-}" ]]; then
  CACHE_DIR="$OOXML_FONT_DIR"
else
  case "$(uname -s)" in
    Darwin) CACHE_DIR="${HOME}/Library/Caches/ooxml-test-fonts" ;;
    Linux)  CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ooxml-test-fonts" ;;
    MINGW*|MSYS*|CYGWIN*) CACHE_DIR="${LOCALAPPDATA:-$HOME/AppData/Local}/ooxml-test-fonts" ;;
    *) CACHE_DIR="${TMPDIR:-/tmp}/ooxml-test-fonts" ;;
  esac
fi

mkdir -p "$CACHE_DIR"

# Each entry: filename | upstream URL. URLs point at the
# googlefonts/noto-fonts repository's hinted TTF tree; bumping is
# one edit per row.
declare -a FONTS=(
  "NotoSans-Regular.ttf|https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-Regular.ttf"
  "NotoSans-Bold.ttf|https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-Bold.ttf"
  "NotoSans-Italic.ttf|https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-Italic.ttf"
  "NotoSans-BoldItalic.ttf|https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-BoldItalic.ttf"
  "NotoSerif-Regular.ttf|https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSerif/NotoSerif-Regular.ttf"
  "NotoSerif-Bold.ttf|https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSerif/NotoSerif-Bold.ttf"
  "NotoSerif-Italic.ttf|https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSerif/NotoSerif-Italic.ttf"
  "NotoSerif-BoldItalic.ttf|https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSerif/NotoSerif-BoldItalic.ttf"
  # Noto Sans Mono ships only Regular and Bold cuts upstream — italic
  # variants do not exist for this family. Requests for italic mono
  # fall through the resolver chain at the renderer's discretion.
  "NotoSansMono-Regular.ttf|https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSansMono/NotoSansMono-Regular.ttf"
  "NotoSansMono-Bold.ttf|https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSansMono/NotoSansMono-Bold.ttf"
)

# Pick a downloader. curl is the macOS / most-distro default; wget
# fills in on stripped-down container images.
if command -v curl > /dev/null 2>&1; then
  DOWNLOADER=(curl --silent --show-error --fail --location --output)
elif command -v wget > /dev/null 2>&1; then
  DOWNLOADER=(wget --quiet -O)
else
  echo "setup-test-fonts.sh: neither curl nor wget is available." >&2
  exit 1
fi

count_new=0
count_skip=0
for entry in "${FONTS[@]}"; do
  filename="${entry%%|*}"
  url="${entry##*|}"
  target="$CACHE_DIR/$filename"
  if [[ -s "$target" ]]; then
    count_skip=$((count_skip + 1))
    continue
  fi
  echo "fetch: $filename"
  if ! "${DOWNLOADER[@]}" "$target" "$url"; then
    rm -f "$target"
    echo "setup-test-fonts.sh: download failed for $filename ($url)" >&2
    exit 1
  fi
  count_new=$((count_new + 1))
done

echo
echo "Done. ${count_new} new / ${count_skip} cached → ${CACHE_DIR}"
echo
echo "Export this in your shell init or before each test invocation:"
echo
echo "  export OOXML_FONT_DIR=\"${CACHE_DIR}\""
