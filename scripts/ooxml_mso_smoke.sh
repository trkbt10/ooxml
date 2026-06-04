#!/usr/bin/env bash
# OOXML package smoke test against Microsoft Word, Excel, and PowerPoint.
#
# For each .docx/.xlsx/.pptx input:
#   1. run ooxml_cli verify (open -> save -> open),
#   2. open a temporary copy in the matching Microsoft Office app,
#   3. apply one format-appropriate edit with ooxml_cli,
#   4. verify the edited package,
#   5. open a temporary copy of the edited package in the matching app.
#
# This is an application-open smoke test. It is not an ECMA-376 schema
# validator and does not prove visual fidelity.

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OOXML_CLI="${OOXML_CLI:-}"
KEEP_TMP=0
RUN_EDIT=1
OPEN_DELAY_SECONDS="${OPEN_DELAY_SECONDS:-3}"
MSO_TIMEOUT_SECONDS="${MSO_TIMEOUT_SECONDS:-45}"
ALL_FIXTURES=0
fixture_categories=()

usage() {
  cat <<'EOF'
Usage: scripts/ooxml_mso_smoke.sh [--keep-tmp] [--no-edit] [--all-fixtures] [--fixture-category format/category] [file...]

When no files are provided, the script uses one generated fixture per format:
  .snapshots/fixtures/docx/paragraph/paragraph-alignment.docx
  .snapshots/fixtures/xlsx/cell/cell-values.xlsx
  .snapshots/fixtures/pptx/shape/pml-slide-grid-with-text.pptx

Fixture category examples:
  scripts/ooxml_mso_smoke.sh --fixture-category docx/drawing
  scripts/ooxml_mso_smoke.sh --fixture-category xlsx/cf --fixture-category pptx/diagram

Environment:
  OOXML_CLI=/path/to/ooxml_cli      prebuilt CLI executable
  OPEN_DELAY_SECONDS=3              seconds to wait after Office open
  MSO_TIMEOUT_SECONDS=45            AppleScript timeout per open
EOF
}

fixture_extension_for_category() {
  case "$1" in
    docx/*) printf 'docx' ;;
    xlsx/*) printf 'xlsx' ;;
    pptx/*) printf 'pptx' ;;
    *)
      echo "ooxml_mso_smoke.sh: invalid fixture category: $1" >&2
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
    echo "ooxml_mso_smoke.sh: fixture category not found: $category" >&2
    echo "Run 'moon run src/cmd/catalog -- fixtures' to generate fixtures." >&2
    exit 2
  fi
  while IFS= read -r fixture; do
    files+=("$fixture")
  done < <(find "$dir" -maxdepth 1 -type f -name "*.$ext" | sort)
  if [ "${#files[@]}" -eq "$before" ]; then
    echo "ooxml_mso_smoke.sh: no .$ext fixtures in category: $category" >&2
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
    echo "ooxml_mso_smoke.sh: no generated fixtures found" >&2
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
        echo "ooxml_mso_smoke.sh: --fixture-category requires format/category" >&2
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
      echo "ooxml_mso_smoke.sh: unknown flag: $1" >&2
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
  echo "ooxml_mso_smoke.sh: no input files and default fixtures are absent" >&2
  echo "Run 'moon run src/cmd/catalog -- fixtures' to generate fixtures." >&2
  exit 2
fi

for app in "Microsoft Word" "Microsoft Excel" "Microsoft PowerPoint"; do
  if [ ! -d "/Applications/$app.app" ]; then
    echo "ooxml_mso_smoke.sh: missing app: /Applications/$app.app" >&2
    exit 2
  fi
done

if ! command -v osascript >/dev/null 2>&1; then
  echo "ooxml_mso_smoke.sh: osascript not found" >&2
  exit 2
fi

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ooxml-mso-smoke.XXXXXX")"
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
    echo "ooxml_mso_smoke.sh: could not build ooxml_cli" >&2
    echo "build log: $build_log" >&2
    KEEP_TMP=1
    exit 2
  fi
  OOXML_CLI="$(find "$ROOT/_build/native/release" -name 'ooxml_cli*' \
    -type f -perm -u+x 2>/dev/null | head -1)"
  if [ -z "$OOXML_CLI" ] || [ ! -x "$OOXML_CLI" ]; then
    echo "ooxml_mso_smoke.sh: could not build ooxml_cli" >&2
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

format_for() {
  case "$1" in
    *.docx) printf 'docx' ;;
    *.xlsx) printf 'xlsx' ;;
    *.pptx) printf 'pptx' ;;
    *) return 1 ;;
  esac
}

app_for_format() {
  case "$1" in
    docx) printf 'Microsoft Word' ;;
    xlsx) printf 'Microsoft Excel' ;;
    pptx) printf 'Microsoft PowerPoint' ;;
    *) return 1 ;;
  esac
}

safe_name() {
  printf '%s' "$1" | tr '/ :' '___'
}

copy_for_open() {
  input="$1"
  label="$2"
  base="$(basename "$input")"
  ext="${base##*.}"
  stem="${base%.*}"
  outdir="$TMP_ROOT/mso-$(safe_name "$label")"
  mkdir -p "$outdir"
  copy="$outdir/${stem}.mso-smoke.$ext"
  cp "$input" "$copy"
  printf '%s' "$copy"
}

mso_open_close() {
  format="$1"
  input="$2"
  label="$3"
  app_name="$(app_for_format "$format")"
  target_name="$(basename "$input")"
  log="$TMP_ROOT/mso-$(safe_name "$label").log"
  printf 'log: %s\n' "$log" > "$TMP_ROOT/last-mso.log"

  if ! /usr/bin/open -a "$app_name" "$input" > "$log" 2>&1; then
    cat "$log" >> "$TMP_ROOT/last-mso.log"
    return 1
  fi

  osascript - "$format" "$target_name" "$OPEN_DELAY_SECONDS" \
    "$MSO_TIMEOUT_SECONDS" >> "$log" 2>&1 <<'APPLESCRIPT'
on run argv
  set formatName to item 1 of argv
  set targetName to item 2 of argv
  set openDelay to (item 3 of argv) as integer
  set timeoutSeconds to (item 4 of argv) as integer
  set deadlineDate to (current date) + timeoutSeconds

  with timeout of (timeoutSeconds + 5) seconds
    delay openDelay
    repeat
      if formatName is "docx" then
        tell application "Microsoft Word"
          activate
          set activeName to missing value
          try
            set activeName to name of active document
          end try
          if activeName is targetName then
            close active document saving no
            return "closed " & targetName
          end if
        end tell
      else if formatName is "xlsx" then
        tell application "Microsoft Excel"
          activate
          set activeName to missing value
          try
            set activeName to name of active workbook
          end try
          if activeName is targetName then
            close active workbook
            return "closed " & targetName
          end if
        end tell
      else if formatName is "pptx" then
        tell application "Microsoft PowerPoint"
          activate
          set activeName to missing value
          try
            set activeName to name of active presentation
          end try
          if activeName is targetName then
            close active presentation
            return "closed " & targetName
          end if
        end tell
      else
        error "Unsupported format: " & formatName
      end if

      if (current date) > deadlineDate then
        error "Microsoft Office did not expose opened package: " & targetName
      end if
      delay 1
    end repeat
  end timeout
end run
APPLESCRIPT
  status=$?
  cat "$log" >> "$TMP_ROOT/last-mso.log"
  return "$status"
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
printf 'file\tinternal_verify\tmso_original_open\tedit\tedited_verify\tmso_edited_open\n'
for input in "${files[@]}"; do
  case "$input" in
    /*) path="$input" ;;
    *) path="$ROOT/$input" ;;
  esac
  rel="${path#$ROOT/}"
  internal="fail"
  mso_original="fail"
  edit_status="skip"
  edited_verify="skip"
  mso_edited="skip"

  if [ -f "$path" ] && format="$(format_for "$path")"; then
    if verify_package "$path"; then
      internal="ok"
    fi
    copy="$(copy_for_open "$path" "$rel-original")"
    if mso_open_close "$format" "$copy" "$rel-original"; then
      mso_original="ok"
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
        edited_copy="$(copy_for_open "$edited" "$rel-edited")"
        if mso_open_close "$format" "$edited_copy" "$rel-edited"; then
          mso_edited="ok"
        else
          mso_edited="fail"
        fi
      else
        edit_status="fail"
        edited_verify="fail"
        mso_edited="fail"
      fi
    fi
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$rel" "$internal" "$mso_original" "$edit_status" "$edited_verify" "$mso_edited"

  if [ "$internal" != "ok" ] || [ "$mso_original" != "ok" ]; then
    failures=$((failures + 1))
  fi
  if [ "$RUN_EDIT" -eq 1 ]; then
    if [ "$edit_status" != "ok" ] || [ "$edited_verify" != "ok" ] || [ "$mso_edited" != "ok" ]; then
      failures=$((failures + 1))
    fi
  fi
done

if [ "$failures" -gt 0 ]; then
  echo "ooxml_mso_smoke.sh: $failures failure(s)" >&2
  echo "last CLI output: $TMP_ROOT/last-cli.log" >&2
  echo "last Microsoft Office output: $TMP_ROOT/last-mso.log" >&2
  KEEP_TMP=1
  exit 1
fi

echo "ooxml_mso_smoke.sh: ok (${#files[@]} file(s))"
