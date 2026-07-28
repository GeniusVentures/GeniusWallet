#!/usr/bin/env bash
#
# tool/check_brace_style.sh
#
# WHAT THIS IS FOR
# ----------------
# AGENTS.md § "Dart coding standards" states a hard team rule: every `if` gets
# braces AND the body on its own line. Same-line `{` is correct (Allman style
# is not wanted); `if (x) { return; }` collapsed onto one line is NOT
# acceptable, and neither is a braceless `if` whose body sits on the next
# line unbraced. Rationale: you cannot set a breakpoint on the true-branch
# otherwise, and a log() call almost always ends up in there later.
#
# WHY A LINT CANNOT DO THIS
# --------------------------
# `curly_braces_in_flow_control_structures` is already enabled via
# flutter_lints (analysis_options.yaml) and reports 0, because it explicitly
# permits omitting braces when the statement fits on one line with no
# `else`. Every known violation in this repo sits inside that carve-out.
# `custom_lint` was offered and declined by the user in 22-CONTEXT.md, and is
# in any case retired upstream. This script is the enforcement mechanism;
# there is no analyzer fallback behind it.
#
# WHAT THIS SCRIPT CHECKS
# ------------------------
# Scans every *.dart file under lib/ and test/ (minus the excludes below) for
# `if (...)` statements and classifies each one:
#   - COMPLIANT   -- `{` immediately follows the closing paren with nothing
#                     else on that line, OR a braceless body whose first
#                     depth-0 terminator is not `;` (see below).
#   - VIOLATION   -- anything other than a bare `{` follows the closing paren
#                     on the same line (Class A -- includes the collapsed
#                     `if (x) { return; }` form), or a braceless body whose
#                     first depth-0 terminator is `;` (Class B -- an unbraced
#                     statement, whether on the if's own line or the next).
# Matching is paren-aware (an awk depth counter, not a regex grabbing the
# last `)` on a line), so `if (a && (b || c))` and `if (a) doThing(x);` are
# told apart correctly. `//` comments, `/* */` block comments, and the
# contents of single/double-quoted string literals are blanked (not deleted,
# so line numbers stay accurate) before any `if` is matched, so a rule
# example inside a doc comment or an `if (` inside a string cannot trip the
# gate.
#
# Flutter's collection-`if` (`[if (x) a, b]`, or the spread form
# `if (x) ...[a, b]`) is a list/map element, not a statement, and can span
# many lines as a full widget expression (`if (cond)\n  Widget(...),`) with
# nothing on the `if` line itself -- indistinguishable from a braceless
# statement by looking at that line alone. This script tells the two apart
# by depth-tracking `()`/`[]`/`{}` forward from wherever the body starts
# (same line or next) to its first depth-0 terminator: `;` means an unbraced
# statement (VIOLATION); a `,` or a bracket-close that takes the depth
# negative (i.e. it closed the *enclosing* literal, not one the body itself
# opened) means the body was a list/map element (compliant -- not a
# statement to begin with, so the brace rule does not apply to it).
#
# EXCLUDED PATHS
# ---------------
# The same set analysis_options.yaml excludes, plus generated code that
# lives outside the analyzer's *.g.dart glob-of-convenience:
#   - banxa/, squidrouter/ (top-level, auto-generated -- AGENTS.md)
#   - packages/genius_api/lib/ffi/, packages/genius_api/lib/proto/ (outside
#     the lib/+test/ scan scope anyway; listed for documentation parity)
#   - any *.freezed.dart
#   - lib/hive/models/*.g.dart, lib/hive_registrar.g.dart,
#     lib/tokeninfo/token_model.g.dart -- codegen output at known locations
# Deliberately NOT excluded by a blanket `*.g.dart` pattern: 9 hand-written
# production widgets under lib/components/ carry that suffix (the analyzer's
# `lib/**/*.g.dart` exclude is blind to them today). ponytail: this
# path-based exclusion list narrows automatically once 22-03 renames those
# 9 files off the `.g.dart` suffix.
#
# USAGE
# -----
#   bash tool/check_brace_style.sh              # print offenders, exit 1 if any found
#   bash tool/check_brace_style.sh --count       # print only the integer violation count
#   bash tool/check_brace_style.sh --self-test   # run the built-in fixture suite, exit 0/1
#
# Prints each offender as "path:line: <source line>" and exits 1 if any are
# found, 0 otherwise (except --count, which always exits 0).

set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

AWK_SCRIPT=""
SELFTEST_TMPDIR=""

cleanup() {
  [ -n "$AWK_SCRIPT" ] && rm -f "$AWK_SCRIPT"
  [ -n "$SELFTEST_TMPDIR" ] && rm -rf "$SELFTEST_TMPDIR"
}
trap cleanup EXIT

AWK_SCRIPT="$(mktemp)"

cat > "$AWK_SCRIPT" <<'AWKEOF'
# Paren-aware brace-style scanner for a single Dart file.
# Reads the file given as the sole ARGV entry into lines[1..NR], strips
# comments/strings into stripped[1..NR] (same length/line count, content
# blanked), then walks every `if (...)` token and prints
# "<FPATH>:<line>: <source>" for each violation. FPATH is passed via -v.
{
  lines[NR] = $0
}
END {
  strip_all()
  scan_ifs()
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

# Depth-counts forward from (row, col) -- col MUST point at an opening "(" --
# to its matching close paren. Returns row*100000+col of that close paren,
# or -1 if the file ends first (malformed input; never happens on valid Dart).
function find_matching_paren(row, col,   depth, r, c, ch, L, n) {
  depth = 0
  r = row
  c = col
  while (r <= NR) {
    L = stripped[r]
    n = length(L)
    while (c <= n) {
      ch = substr(L, c, 1)
      if (ch == "(") {
        depth++
      } else if (ch == ")") {
        depth--
        if (depth == 0) return r * 100000 + c
      }
      c++
    }
    r++
    c = 1
  }
  return -1
}

function trim(s) {
  gsub(/^[ \t]+/, "", s)
  gsub(/[ \t]+$/, "", s)
  return s
}

function scan_ifs(   i, L, n, col, idx, abs, before, nextch, p, code, mrow, mcol, verdict) {
  for (i = 1; i <= NR; i++) {
    L = stripped[i]
    n = length(L)
    col = 1
    while (col <= n) {
      idx = index(substr(L, col), "if")
      if (idx == 0) break
      abs = col + idx - 1
      before = (abs == 1) ? "" : substr(L, abs - 1, 1)
      nextch = substr(L, abs + 2, 1)
      # Word-boundary check: "if" must not be part of a longer identifier
      # (differs, verify, iffy, ...). "if" is a reserved word in Dart, so
      # any token match that survives this boundary check is a real if.
      if ((before == "" || !is_word(before)) && (nextch == "" || !is_word(nextch))) {
        p = abs + 2
        while (p <= n && substr(L, p, 1) ~ /[ \t]/) p++
        if (p <= n && substr(L, p, 1) == "(") {
          code = find_matching_paren(i, p)
          if (code > 0) {
            mrow = int(code / 100000)
            mcol = code - mrow * 100000
            verdict = classify_if(mrow, mcol)
            if (verdict == "violation") {
              printf "%s:%d: %s\n", FPATH, i, lines[i]
            }
          }
        }
      }
      col = abs + 2
    }
  }
}

# classify_if -- given the (row, col) of an if-condition's matching close
# paren, returns "compliant" or "violation". See the "WHAT THIS SCRIPT
# CHECKS" header comment for the full rule and the collection-if rationale.
function classify_if(mrow, mcol,   tail, nr, nl, found) {
  tail = trim(substr(stripped[mrow], mcol + 1))
  if (tail == "{") return "compliant"
  if (tail != "" && substr(tail, 1, 1) == "{") return "violation"
  if (tail == "") {
    # Nothing follows the closing paren on this line. Compliant (Allman
    # brace-on-its-own-line) if the next non-blank line opens with "{";
    # otherwise defer to the terminator scan to tell a braceless statement
    # apart from a multi-line collection-if element.
    nr = mrow + 1
    found = 0
    nl = ""
    while (nr <= NR) {
      nl = trim(stripped[nr])
      if (nl != "") { found = 1; break }
      nr++
    }
    if (found && substr(nl, 1, 1) == "{") return "compliant"
    return terminator_scan(mrow + 1, 1)
  }
  return terminator_scan(mrow, mcol + 1)
}

# terminator_scan -- depth-tracks "()"/"[]"/"{}" forward from (row, col),
# which points just past a braceless if-condition, to the first depth-0
# terminator of the body that follows:
#   ";"  at depth 0                     -> "violation" (unbraced statement)
#   ","  at depth 0                     -> "compliant" (collection-if element)
#   a close bracket that takes depth    -> "compliant" (element was the last
#     negative (closed the ENCLOSING       one in its list/map literal, so
#     literal, not one the body opened)    there was no trailing comma)
# A Dart statement body always reaches its own terminating ";" before any
# enclosing block's "}" -- only a list/map literal element can hit a
# negative-depth close first. That is the whole basis for this distinction.
function terminator_scan(row, col,   r, c, ch, L, n, depth) {
  depth = 0
  r = row
  c = col
  while (r <= NR) {
    L = stripped[r]
    n = length(L)
    while (c <= n) {
      ch = substr(L, c, 1)
      if (ch == "(" || ch == "[" || ch == "{") {
        depth++
      } else if (ch == ")" || ch == "]" || ch == "}") {
        depth--
        if (depth < 0) return "compliant"
      } else if (ch == ";" && depth == 0) {
        return "violation"
      } else if (ch == "," && depth == 0) {
        return "compliant"
      }
      c++
    }
    r++
    c = 1
  }
  return "violation"
}
AWKEOF

# is_excluded PATH -- true (0) if PATH must not be scanned. See the "EXCLUDED
# PATHS" header comment above for the rationale behind each entry.
is_excluded() {
  local f="$1"
  case "$f" in
    banxa/*|squidrouter/*) return 0 ;;
    packages/genius_api/lib/ffi/*|packages/genius_api/lib/proto/*) return 0 ;;
    *.freezed.dart) return 0 ;;
    lib/hive/models/*.g.dart) return 0 ;;
    lib/hive_registrar.g.dart) return 0 ;;
    lib/tokeninfo/token_model.g.dart) return 0 ;;
  esac
  return 1
}

# collect_offenders -- prints "path:line: source" for every violation found
# under lib/ and test/. Uses -print0/read -d '' throughout so no filename
# (however unlikely to contain whitespace in this repo) is word-split.
collect_offenders() {
  local f
  while IFS= read -r -d '' f; do
    if is_excluded "$f"; then
      continue
    fi
    awk -v FPATH="$f" -f "$AWK_SCRIPT" "$f"
  done < <(find lib test -type f -name '*.dart' -print0 | sort -z)
}

# run_self_test -- the proof the gate can fail. Writes 9 fixture files to a
# temp dir (4 must-flag, 5 must-not-flag per 22-02-PLAN.md), scans each with
# the same awk program collect_offenders uses, and asserts the verdict.
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
void f(bool mounted) {
  if (mounted) { return; }
}
EOF
  assert_case "1-collapsed-one-liner-with-braces" flag "$SELFTEST_TMPDIR/case1.dart"

  cat > "$SELFTEST_TMPDIR/case2.dart" <<'EOF'
void f(bool mounted) {
  if (mounted)
    return;
}
EOF
  assert_case "2-braceless-body-on-next-line" flag "$SELFTEST_TMPDIR/case2.dart"

  cat > "$SELFTEST_TMPDIR/case3.dart" <<'EOF'
void f(bool a, bool b, bool c) {
  if (a && (b || c))
    return;
}
EOF
  assert_case "3-braceless-nested-paren-condition" flag "$SELFTEST_TMPDIR/case3.dart"

  cat > "$SELFTEST_TMPDIR/case4.dart" <<'EOF'
void f(bool x, bool y) {
  if (x) {
    doThing();
  }
  if (y) return;
}
EOF
  assert_case "4-compliant-then-violating-in-same-file" flag "$SELFTEST_TMPDIR/case4.dart"

  cat > "$SELFTEST_TMPDIR/case5.dart" <<'EOF'
void f(bool mounted) {
  if (mounted) {
    return;
  }
}
EOF
  assert_case "5-compliant-form" clean "$SELFTEST_TMPDIR/case5.dart"

  cat > "$SELFTEST_TMPDIR/case6.dart" <<'EOF'
void f(bool a, bool b) {
  if (a) {
    doA();
  } else if (b) {
    doB();
  } else {
    doC();
  }
}
EOF
  assert_case "6-else-if-chain-all-compliant" clean "$SELFTEST_TMPDIR/case6.dart"

  cat > "$SELFTEST_TMPDIR/case7.dart" <<'EOF'
void f() {
  // if (x) { return; }
  doNothing();
}
EOF
  assert_case "7-violation-inside-line-comment" clean "$SELFTEST_TMPDIR/case7.dart"

  cat > "$SELFTEST_TMPDIR/case8.dart" <<'EOF'
void f() {
  final s = 'if (x) { return; }';
}
EOF
  assert_case "8-violation-inside-string-literal" clean "$SELFTEST_TMPDIR/case8.dart"

  cat > "$SELFTEST_TMPDIR/case9.dart" <<'EOF'
Widget build(BuildContext context) {
  return Column(
    children: [
      if (isVisible) const Text('Hello'),
      const SizedBox(height: 8),
    ],
  );
}
EOF
  assert_case "9-collection-if-inside-list-literal" clean "$SELFTEST_TMPDIR/case9.dart"

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
      echo "usage: bash tool/check_brace_style.sh [--count|--self-test]" >&2
      exit 2
      ;;
  esac
}

main "$@"
