#!/usr/bin/env bash
#
# tool/check_raw_colors.sh
#
# WHAT THIS IS FOR
# ----------------
# AGENTS.md § "Dart coding standards" states a hard team rule: "No `Colors.*`
# or `Color(0x...)` outside `lib/theme/`. Every colour must be correct in
# BOTH appearance modes ... light mode is where this repo has historically
# broken." A raw colour outside the theme layer cannot be appearance-aware --
# it is, by construction, the exact class of bug 22-05/23-01/23-02/23-03
# spent four plans finding and fixing one directory at a time. This script
# is the CI enforcement that keeps a fixed directory fixed.
#
# WHY A LINT CANNOT DO THIS
# --------------------------
# No off-the-shelf lint bans hardcoded colours by itself. Checked against
# three candidates at 23-04 planning time: the Dart linter core (no such
# rule), DCM's rule set (no such rule either), and `design_system_lints`
# (the right rule shape existed, but the package is stale at v0.1.3 with an
# unverified publisher -- not adoptable per AGENTS.md's "no new dependency if
# it can be avoided" and the project's declined-package precedent
# `check_brace_style.sh`'s own header names). A CI grep gate is the
# practical answer, the same conclusion the brace rule reached -- this
# script mirrors that one's conventions exactly, on purpose: a second gate
# that behaves differently from the first is a gate people get wrong.
#
# WHAT THIS SCRIPT CHECKS
# ------------------------
# Scans every *.dart file under the COVERED directories (see COVERED_DIRS
# below -- never `lib/theme/`, where raw colours are the primitive layer and
# correct by design) for:
#   - `Colors.<member>` -- a reference into Flutter's material colour palette
#     (`Colors.white`, `Colors.black45`, `Colors.greenAccent`, ...), EXCEPT
#     `Colors.transparent`, which is permitted unconditionally: it carries no
#     hue and is appearance-neutral by definition (0 alpha reads identically
#     in every mode).
#   - `Color(0x........)` -- a raw ARGB hex literal constructor.
# `//` comments, `/* */` block comments, and single/double-quoted string
# literal contents are blanked (not deleted, so line numbers stay accurate)
# before any match is attempted -- reusing `check_brace_style.sh`'s own
# `strip_all` AWK function verbatim, so a design note that quotes a hex value
# in a doc comment, or a URL containing "Color(0x", cannot trip the gate, and
# the gate cannot invalidate itself the moment someone documents it.
#
# A line carrying the exemption marker `raw-color-ok:` followed by non-blank
# text (the reason) is permitted -- this is how a genuinely always-one-mode
# case (white text fixed on a permanently-dark scrim, say) stays in the tree
# without being flagged, and stays VISIBLE as a deliberate choice rather than
# a silent exception. A bare `raw-color-ok:` with nothing after the colon (or
# only whitespace) is NOT an exemption and does not suppress the line -- a
# marker that excuses nothing is not a marker, and this is checked by the
# self-test.
#
# COVERED DIRECTORIES
# ---------------------
# Scoped to directories MEASURED clean (0 raw references) at 23-04 planning
# time. See `.planning/phases/23-.../23-04-GATE-SCOPE.md` for the full
# covered/uncovered split, per-directory counts for every uncovered
# directory, and what closing each one would take. A repo-wide gate on day
# one would block its own migration -- that is the documented failure mode
# and the reason the gate is scoped rather than global, and widens as
# coverage grows (append a directory to COVERED_DIRS once its own count hits
# zero -- do not widen speculatively).
#
# USAGE
# -----
#   bash tool/check_raw_colors.sh                 # print offenders, exit 1 if any found
#   bash tool/check_raw_colors.sh --count          # print only the integer violation count
#   bash tool/check_raw_colors.sh --self-test      # run the built-in fixture suite, exit 0/1
#
# Prints each offender as "path:line: <source line>" and exits 1 if any are
# found, 0 otherwise (except --count, which always exits 0).

set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

# COVERED_DIRS -- directories scanned by this gate, MEASURED at exactly 0
# raw references at 23-04 planning time (2026-07-29). See
# 23-04-GATE-SCOPE.md for the measured count behind every lib/ subdirectory
# NOT in this list, and what closing each one would take.
COVERED_DIRS=(
  "lib/assets"
  "lib/bloc"
  "lib/chart"
  "lib/dev"
  "lib/hive"
  "lib/logs"
  "lib/navigation"
  "lib/onboarding"
  "lib/providers"
  "lib/services"
  "lib/settings"
  "lib/squid_router"
  "lib/submit_job"
  "lib/test"
  "lib/tokeninfo"
  "lib/tokens"
)

# COVERED_FILES -- top-level lib/*.dart files (not inside any subdirectory,
# so COVERED_DIRS's directory walk never reaches them) that also measured 0.
# Currently just main.dart -- see 23-04-GATE-SCOPE.md.
COVERED_FILES=(
  "lib/main.dart"
)

AWK_SCRIPT=""
SELFTEST_TMPDIR=""

cleanup() {
  [ -n "$AWK_SCRIPT" ] && rm -f "$AWK_SCRIPT"
  [ -n "$SELFTEST_TMPDIR" ] && rm -rf "$SELFTEST_TMPDIR"
}
trap cleanup EXIT

AWK_SCRIPT="$(mktemp)"

cat > "$AWK_SCRIPT" <<'AWKEOF'
# Raw-colour scanner for a single Dart file. Reads the file given as the sole
# ARGV entry into lines[1..NR], strips comments/strings into stripped[1..NR]
# (same length/line count, content blanked -- identical algorithm to
# check_brace_style.sh's own strip_all, kept byte-for-byte the same so the
# two gates cannot silently drift apart on what counts as "inside a string"),
# then flags every offending line.
{
  lines[NR] = $0
}
END {
  strip_all()
  scan_lines()
}

function strip_all(   i, j, c, n, line, out, instr, strch, inblock) {
  inblock = 0
  for (i = 1; i <= NR; i++) {
    line = lines[i]
    n = length(line)
    out = ""
    instr = 0
    strch = ""
    j = 1
    while (j <= n) {
      c = substr(line, j, 1)
      if (inblock) {
        if (c == "*" && substr(line, j + 1, 1) == "/") {
          out = out "  "
          j += 2
          inblock = 0
        } else {
          out = out " "
          j++
        }
        continue
      }
      if (instr) {
        if (c == "\\") {
          out = out "  "
          j += 2
          continue
        }
        if (c == strch) instr = 0
        out = out " "
        j++
        continue
      }
      if (c == "/" && substr(line, j + 1, 1) == "/") {
        while (j <= n) { out = out " "; j++ }
        continue
      }
      if (c == "/" && substr(line, j + 1, 1) == "*") {
        out = out "  "
        j += 2
        inblock = 1
        continue
      }
      if (c == "'" || c == "\"") {
        instr = 1
        strch = c
        out = out " "
        j++
        continue
      }
      out = out c
      j++
    }
    stripped[i] = out
  }
}

function is_word(ch) {
  return (ch ~ /[A-Za-z0-9_]/)
}

# has_exemption -- true if the RAW (unstripped) source line carries
# `raw-color-ok:` followed by at least one non-whitespace character. Checked
# against the raw line (not the stripped one) because the marker itself
# lives inside a `//` comment, which strip_all blanks.
function has_exemption(raw,   idx, rest) {
  idx = index(raw, "raw-color-ok:")
  if (idx == 0) return 0
  rest = substr(raw, idx + length("raw-color-ok:"))
  gsub(/[ \t]/, "", rest)
  return (rest != "")
}

# line_has_flaggable_colors -- true if the STRIPPED line references
# `Colors.<word>` for any member OTHER than `transparent`, anywhere on the
# line. Walks every occurrence of the literal "Colors." rather than stopping
# at the first, so a line with `Colors.transparent` earlier and a real
# violation later is still caught. Word-boundary checked on the character
# immediately before "Colors." so a hypothetical unrelated `MyColors.foo`
# does not false-positive.
function line_has_flaggable_colors(L,   pos, idx, before, rest, member, k, n, ch) {
  pos = 1
  while (1) {
    idx = index(substr(L, pos), "Colors.")
    if (idx == 0) return 0
    idx = pos + idx - 1
    before = (idx == 1) ? "" : substr(L, idx - 1, 1)
    if (before == "" || !is_word(before)) {
      rest = substr(L, idx + length("Colors."))
      member = ""
      n = length(rest)
      k = 1
      while (k <= n) {
        ch = substr(rest, k, 1)
        if (!is_word(ch)) break
        member = member ch
        k++
      }
      if (member != "transparent" && member != "") {
        return 1
      }
    }
    pos = idx + length("Colors.")
  }
}

function scan_lines(   i, L, raw, hasColors, hasHex) {
  for (i = 1; i <= NR; i++) {
    L = stripped[i]
    raw = lines[i]
    if (has_exemption(raw)) continue

    hasColors = line_has_flaggable_colors(L)
    hasHex = (L ~ /Color\(0x/)

    if (hasColors || hasHex) {
      printf "%s:%d: %s\n", FPATH, i, raw
    }
  }
}
AWKEOF

# is_excluded PATH -- true (0) if PATH must not be scanned. `lib/theme/` is
# NEVER covered -- that is where colours are literal by design.
is_excluded() {
  local f="$1"
  case "$f" in
    lib/theme/*) return 0 ;;
  esac
  return 1
}

# collect_offenders -- prints "path:line: source" for every violation found
# under COVERED_DIRS plus COVERED_FILES. Uses -print0/read -d '' throughout
# so no filename (however unlikely to contain whitespace in this repo) is
# word-split.
collect_offenders() {
  local f dir
  for dir in "${COVERED_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    while IFS= read -r -d '' f; do
      if is_excluded "$f"; then
        continue
      fi
      awk -v FPATH="$f" -f "$AWK_SCRIPT" "$f"
    done < <(find "$dir" -type f -name '*.dart' -print0 | sort -z)
  done
  for f in "${COVERED_FILES[@]}"; do
    [ -f "$f" ] || continue
    awk -v FPATH="$f" -f "$AWK_SCRIPT" "$f"
  done
}

# run_self_test -- the proof the gate can fail. Writes fixture files to a
# temp dir, scans each with the same awk program collect_offenders uses, and
# asserts the verdict -- mirrors check_brace_style.sh's own run_self_test
# shape (assert_case helper, PASS/FAIL lines, one overall exit code).
run_self_test() {
  SELFTEST_TMPDIR="$(mktemp -d)"
  local overall=0

  assert_case() {
    local name="$1" expect="$2" file="$3" count
    count="$(awk -v FPATH="$file" -f "$AWK_SCRIPT" "$file" | wc -l | tr -d ' ')"
    if [ "$expect" = "flag" ]; then
      if [ "$count" -gt 0 ]; then
        echo "PASS: $name"
      else
        echo "FAIL: $name (expected a violation, found none)"
        overall=1
      fi
    else
      if [ "$count" -eq 0 ]; then
        echo "PASS: $name"
      else
        echo "FAIL: $name (expected no violation, found $count)"
        overall=1
      fi
    fi
  }

  cat > "$SELFTEST_TMPDIR/case1.dart" <<'EOF'
import 'package:flutter/material.dart';
Widget f() => Container(color: Colors.white);
EOF
  assert_case "1-material-colors-reference" flag "$SELFTEST_TMPDIR/case1.dart"

  cat > "$SELFTEST_TMPDIR/case2.dart" <<'EOF'
import 'package:flutter/material.dart';
Widget f() => Container(color: Color(0xFF14C8FF));
EOF
  assert_case "2-hex-color-constructor" flag "$SELFTEST_TMPDIR/case2.dart"

  cat > "$SELFTEST_TMPDIR/case3.dart" <<'EOF'
import 'package:flutter/material.dart';
Widget f() {
  // Container(color: Colors.white, other: Color(0xFF000000)) -- an example
  // in a comment, not code.
  return Container();
}
EOF
  assert_case "3-violation-inside-line-comment" clean "$SELFTEST_TMPDIR/case3.dart"

  cat > "$SELFTEST_TMPDIR/case4.dart" <<'EOF'
void f() {
  final s = 'Colors.white and Color(0xFF14C8FF) as text';
}
EOF
  assert_case "4-violation-inside-string-literal" clean "$SELFTEST_TMPDIR/case4.dart"

  cat > "$SELFTEST_TMPDIR/case5.dart" <<'EOF'
import 'package:flutter/material.dart';
Widget f() => Container(color: Colors.transparent);
EOF
  assert_case "5-transparent-constant-permitted" clean "$SELFTEST_TMPDIR/case5.dart"

  cat > "$SELFTEST_TMPDIR/case5b.dart" <<'EOF'
import 'package:flutter/material.dart';
Widget f() => Container(color: Colors.transparent, child: Text('x', style: TextStyle(color: Colors.red)));
EOF
  assert_case "5b-transparent-does-not-mask-a-later-real-violation" flag "$SELFTEST_TMPDIR/case5b.dart"

  cat > "$SELFTEST_TMPDIR/case6.dart" <<'EOF'
import 'package:flutter/material.dart';
Widget f() => Container(
  color: Colors.white, // raw-color-ok: fixed white text on a permanently-dark scrim, never toggles
);
EOF
  assert_case "6-exempted-line-with-reason-permitted" clean "$SELFTEST_TMPDIR/case6.dart"

  cat > "$SELFTEST_TMPDIR/case7.dart" <<'EOF'
import 'package:flutter/material.dart';
Widget f() => Container(
  color: Colors.white, // raw-color-ok:
);
EOF
  assert_case "7-bare-marker-with-no-reason-still-flags" flag "$SELFTEST_TMPDIR/case7.dart"

  # is_excluded: lib/theme/ paths must never be scanned, regardless of
  # content -- tested directly against the shell predicate, not through awk
  # (awk has no notion of paths; only is_excluded/collect_offenders do).
  if is_excluded "lib/theme/gw_colors.dart"; then
    echo "PASS: 8-lib-theme-path-excluded"
  else
    echo "FAIL: 8-lib-theme-path-excluded (lib/theme/ must be excluded)"
    overall=1
  fi
  if is_excluded "lib/components/gw_icon.dart"; then
    echo "FAIL: 9-non-theme-path-not-excluded (a covered-directory path was excluded)"
    overall=1
  else
    echo "PASS: 9-non-theme-path-not-excluded"
  fi

  return "$overall"
}

main() {
  case "${1:-}" in
    --count)
      collect_offenders | wc -l | tr -d ' '
      exit 0
      ;;
    --self-test)
      run_self_test
      exit $?
      ;;
    "")
      local out
      out="$(collect_offenders)"
      if [ -n "$out" ]; then
        printf '%s\n' "$out"
        exit 1
      fi
      exit 0
      ;;
    *)
      echo "usage: bash tool/check_raw_colors.sh [--count|--self-test]" >&2
      exit 2
      ;;
  esac
}

main "$@"
