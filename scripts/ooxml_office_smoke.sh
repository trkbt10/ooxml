#!/usr/bin/env bash
# OOXML package smoke test against the in-tree CLI and LibreOffice.
#
# For each .docx/.xlsx/.pptx input:
#   1. run ooxml_cli verify (open -> save -> open),
#   2. ask LibreOffice headless to open/export the original as PDF,
#   3. apply one format-appropriate edit with ooxml_cli,
#   4. verify the edited package,
#   5. ask LibreOffice headless to open/export the edited package as PDF.
#
# This is a practical package-health smoke test. It is not an ECMA-376
# schema validator and does not automate Microsoft Office.

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOFFICE="${SOFFICE:-soffice}"
OOXML_CLI="${OOXML_CLI:-}"
KEEP_TMP=0
RUN_EDIT=1
ALL_FIXTURES=0
fixture_categories=()

usage() {
  cat <<'EOF'
Usage: scripts/ooxml_office_smoke.sh [--keep-tmp] [--no-edit] [--all-fixtures] [--fixture-category format/category] [file...]

When no files are provided, the script uses one generated fixture per format:
  .snapshots/fixtures/docx/paragraph/paragraph-alignment.docx
  .snapshots/fixtures/xlsx/cell/cell-values.xlsx
  .snapshots/fixtures/pptx/shape/pml-slide-grid-with-text.pptx

Fixture category examples:
  scripts/ooxml_office_smoke.sh --fixture-category docx/drawing
  scripts/ooxml_office_smoke.sh --fixture-category xlsx/cf --fixture-category pptx/diagram

Environment:
  SOFFICE=/path/to/soffice     LibreOffice executable (default: soffice)
  OOXML_CLI=/path/to/ooxml_cli prebuilt CLI executable
EOF
}

fixture_extension_for_category() {
  case "$1" in
    docx/*) printf 'docx' ;;
    xlsx/*) printf 'xlsx' ;;
    pptx/*) printf 'pptx' ;;
    *)
      echo "ooxml_office_smoke.sh: invalid fixture category: $1" >&2
      echo "expected format/category under .snapshots/fixtures/{docx,xlsx,pptx}" >&2
      exit 2
      ;;
  esac
}

add_fixture_category() {
  category="$1"
  ext="$(fixture_extension_for_category "$category")"
  dir="$ROOT/.snapshots/fixtures/$category"
  before="${#files[@]}"
  if [ ! -d "$dir" ]; then
    echo "ooxml_office_smoke.sh: fixture category not found: $category" >&2
    echo "Run 'moon run src/cmd/catalog -- fixtures' to generate fixtures." >&2
    exit 2
  fi
  while IFS= read -r fixture; do
    files+=("$fixture")
  done < <(find "$dir" -maxdepth 1 -type f -name "*.$ext" | sort)
  if [ "${#files[@]}" -eq "$before" ]; then
    echo "ooxml_office_smoke.sh: no .$ext fixtures in category: $category" >&2
    exit 2
  fi
}

add_all_fixtures() {
  before="${#files[@]}"
  for ext in docx xlsx pptx; do
    dir="$ROOT/.snapshots/fixtures/$ext"
    if [ -d "$dir" ]; then
      while IFS= read -r fixture; do
        files+=("$fixture")
      done < <(find "$dir" -type f -name "*.$ext" | sort)
    fi
  done
  if [ "${#files[@]}" -eq "$before" ]; then
    echo "ooxml_office_smoke.sh: no generated fixtures found" >&2
    echo "Run 'moon run src/cmd/catalog -- fixtures' to generate fixtures." >&2
    exit 2
  fi
}

files=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --keep-tmp)
      KEEP_TMP=1
      ;;
    --no-edit)
      RUN_EDIT=0
      ;;
    --all-fixtures)
      ALL_FIXTURES=1
      ;;
    --fixture-category)
      shift
      if [ "$#" -eq 0 ]; then
        echo "ooxml_office_smoke.sh: --fixture-category requires format/category" >&2
        usage >&2
        exit 2
      fi
      fixture_categories+=("$1")
      ;;
    --fixture-category=*)
      fixture_categories+=("${1#--fixture-category=}")
      ;;
    --)
      shift
      while [ "$#" -gt 0 ]; do
        files+=("$1")
        shift
      done
      break
      ;;
    -*)
      echo "ooxml_office_smoke.sh: unknown flag: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      files+=("$1")
      ;;
  esac
  shift
done

if [ "$ALL_FIXTURES" -eq 1 ]; then
  add_all_fixtures
fi

if [ "${#fixture_categories[@]}" -gt 0 ]; then
  for category in "${fixture_categories[@]}"; do
    add_fixture_category "$category"
  done
fi

if [ "${#files[@]}" -eq 0 ] && [ "$ALL_FIXTURES" -eq 0 ] && [ "${#fixture_categories[@]}" -eq 0 ]; then
  defaults=(
    ".snapshots/fixtures/docx/paragraph/paragraph-alignment.docx"
    ".snapshots/fixtures/xlsx/cell/cell-values.xlsx"
    ".snapshots/fixtures/pptx/shape/pml-slide-grid-with-text.pptx"
  )
  for path in "${defaults[@]}"; do
    if [ -f "$ROOT/$path" ]; then
      files+=("$ROOT/$path")
    fi
  done
fi

if [ "${#files[@]}" -eq 0 ]; then
  echo "ooxml_office_smoke.sh: no input files and default fixtures are absent" >&2
  echo "Run 'moon run src/cmd/catalog -- fixtures' to generate fixtures." >&2
  exit 2
fi

if ! command -v "$SOFFICE" >/dev/null 2>&1; then
  echo "ooxml_office_smoke.sh: soffice not found: $SOFFICE" >&2
  exit 2
fi

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ooxml-office-smoke.XXXXXX")"
cleanup() {
  if [ "$KEEP_TMP" -eq 0 ]; then
    rm -rf "$TMP_ROOT"
  else
    echo "kept tmp: $TMP_ROOT"
  fi
}
trap cleanup EXIT

build_cli() {
  if [ -n "$OOXML_CLI" ] && [ -x "$OOXML_CLI" ]; then
    return 0
  fi
  build_log="$TMP_ROOT/moon-build.log"
  if ! (cd "$ROOT" && moon build --target native --release src/cmd/ooxml_cli \
        > "$build_log" 2>&1); then
    echo "ooxml_office_smoke.sh: could not build ooxml_cli" >&2
    echo "build log: $build_log" >&2
    KEEP_TMP=1
    exit 2
  fi
  OOXML_CLI="$(find "$ROOT/_build/native/release" -name 'ooxml_cli*' \
    -type f -perm -u+x 2>/dev/null | head -1)"
  if [ -z "$OOXML_CLI" ] || [ ! -x "$OOXML_CLI" ]; then
    echo "ooxml_office_smoke.sh: could not build ooxml_cli" >&2
    exit 2
  fi
}

run_cli_expect() {
  expected="$1"
  shift
  output="$("$OOXML_CLI" "$@" 2>&1)"
  printf '%s\n' "$output" > "$TMP_ROOT/last-cli.log"
  if printf '%s\n' "$output" | grep -q "$expected"; then
    return 0
  fi
  return 1
}

safe_name() {
  printf '%s' "$1" | tr '/ :' '___'
}

lo_pdf_export() {
  input="$1"
  label="$2"
  outdir="$TMP_ROOT/lo-$(safe_name "$label")"
  profile="$outdir/profile"
  mkdir -p "$outdir"
  mkdir -p "$profile"
  if ! "$SOFFICE" --headless --nologo --nofirststartwizard --nolockcheck \
       --nodefault --norestore "-env:UserInstallation=file://$profile" \
       --convert-to pdf --outdir "$outdir" "$input" > "$outdir/soffice.log" 2>&1; then
    return 1
  fi
  pdf="$(find "$outdir" -maxdepth 1 -type f -name '*.pdf' | head -1)"
  if [ -z "$pdf" ] || [ ! -s "$pdf" ]; then
    return 1
  fi
  return 0
}

edited_path_for() {
  input="$1"
  base="$(basename "$input")"
  ext="${base##*.}"
  stem="${base%.*}"
  mkdir -p "$TMP_ROOT/edited"
  printf '%s/edited/%s.edited.%s' "$TMP_ROOT" "$stem" "$ext"
}

edit_package() {
  input="$1"
  output="$2"
  case "$input" in
    *.docx)
      run_cli_expect '^saved:' append-paragraph "$input" "OOXML smoke paragraph" "$output"
      ;;
    *.xlsx)
      run_cli_expect '^saved:' set-cell "$input" 1 A1 "OOXML smoke cell" "$output"
      ;;
    *.pptx)
      run_cli_expect '^saved:' add-textbox "$input" 1 914400 914400 3657600 685800 \
        "OOXML smoke textbox" "$output"
      ;;
    *)
      return 1
      ;;
  esac
}

verify_package() {
  input="$1"
  case "$input" in
    *.docx) run_cli_expect '^ok: docx verify$' verify "$input" ;;
    *.xlsx) run_cli_expect '^ok: xlsx verify$' verify "$input" ;;
    *.pptx) run_cli_expect '^ok: pptx verify$' verify "$input" ;;
    *) return 1 ;;
  esac
}

build_cli

failures=0
printf 'file\tinternal_verify\tlo_original_pdf\tedit\tedited_verify\tlo_edited_pdf\n'
for input in "${files[@]}"; do
  case "$input" in
    /*) path="$input" ;;
    *) path="$ROOT/$input" ;;
  esac
  rel="${path#$ROOT/}"
  internal="fail"
  lo_original="fail"
  edit_status="skip"
  edited_verify="skip"
  lo_edited="skip"

  if [ -f "$path" ]; then
    if verify_package "$path"; then
      internal="ok"
    fi
    if lo_pdf_export "$path" "$rel-original"; then
      lo_original="ok"
    fi
    if [ "$RUN_EDIT" -eq 1 ]; then
      edited="$(edited_path_for "$path")"
      if edit_package "$path" "$edited"; then
        edit_status="ok"
        if verify_package "$edited"; then
          edited_verify="ok"
        else
          edited_verify="fail"
        fi
        if lo_pdf_export "$edited" "$rel-edited"; then
          lo_edited="ok"
        else
          lo_edited="fail"
        fi
      else
        edit_status="fail"
        edited_verify="fail"
        lo_edited="fail"
      fi
    fi
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$rel" "$internal" "$lo_original" "$edit_status" "$edited_verify" "$lo_edited"

  if [ "$internal" != "ok" ] || [ "$lo_original" != "ok" ]; then
    failures=$((failures + 1))
  fi
  if [ "$RUN_EDIT" -eq 1 ]; then
    if [ "$edit_status" != "ok" ] || [ "$edited_verify" != "ok" ] || [ "$lo_edited" != "ok" ]; then
      failures=$((failures + 1))
    fi
  fi
done

if [ "$failures" -gt 0 ]; then
  echo "ooxml_office_smoke.sh: $failures failure(s)" >&2
  echo "last CLI output: $TMP_ROOT/last-cli.log" >&2
  KEEP_TMP=1
  exit 1
fi

echo "ooxml_office_smoke.sh: ok (${#files[@]} file(s))"
