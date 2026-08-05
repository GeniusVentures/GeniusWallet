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
#   bash tool/check_brace_style.sh                    # print offenders, exit 1 if any found
#   bash tool/check_brace_style.sh --count             # print only the integer violation count
#   bash tool/check_brace_style.sh --self-test         # run the built-in fixture suite, exit 0/1
#   bash tool/check_brace_style.sh --fix               # rewrite in-scope violations in place
#   bash tool/check_brace_style.sh --fix --dry-run     # report what --fix would do, write nothing
#
# Prints each offender as "path:line: <source line>" and exits 1 if any are
# found, 0 otherwise (except --count, which always exits 0).
#
# --fix MODE
# ----------
# --fix shares the exact same classify_if/terminator_scan detector the gate
# itself uses -- it does not re-decide what a violation is. It only rewrites
# the one shape it can prove is safe: `if (cond) stmt;` where the condition,
# the body statement, and its terminating `;` all sit on one physical line
# and nothing but that statement follows the `;` (a trailing line comment is
# tolerated -- comment content is blanked by strip_all, so it reads as empty
# after trimming). Everything else -- an `else` on the same line, a body that
# starts on a later line, a body that spans multiple physical lines, or an
# already-braced-but-collapsed one-liner (`if (x) { return; }`) -- is
# reported as refused and never rewritten. Refused sites are printed as
# "path:line: REFUSE: <reason> -- <source line>". `--fix` is idempotent:
# running it again on its own output finds nothing left to do.

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
  if (FIXMODE == 1) {
    fix_scan()
  } else {
    scan_ifs()
  }
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

# terminator_scan_pos -- depth-tracks "()"/"[]"/"{}" forward from (row, col),
# which points just past a braceless if-condition, to the first depth-0
# terminator of the body that follows, returning its exact position and
# kind as "row,col,kind":
#   kind="semi"         a ";" at depth 0            (unbraced statement)
#   kind="comma"        a "," at depth 0             (collection-if element)
#   kind="comma_close"  a close bracket that takes    (collection-if element:
#                        depth negative (closed the    the last one in its
#                        ENCLOSING literal, not one     list/map literal, so
#                        the body opened)               there was no comma)
#   kind="eof"           file ended before any of the above (malformed input;
#                         treated the same as "semi" by the one caller below)
# A Dart statement body always reaches its own terminating ";" before any
# enclosing block's "}" -- only a list/map literal element can hit a
# negative-depth close first. That is the whole basis for this distinction.
# This is the ONE place that walks the body looking for where it ends --
# both classify_if (via terminator_scan) and try_fix (via the raw position)
# call this, so gate and --fix can never disagree about where a statement
# stops.
function terminator_scan_pos(row, col,   r, c, ch, L, n, depth) {
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
        if (depth < 0) return r "," c ",comma_close"
      } else if (ch == ";" && depth == 0) {
        return r "," c ",semi"
      } else if (ch == "," && depth == 0) {
        return r "," c ",comma"
      }
      c++
    }
    r++
    c = 1
  }
  return "0,0,eof"
}

# terminator_scan -- thin compliant/violation wrapper around
# terminator_scan_pos, kept so classify_if's call site reads exactly as it
# did before this file gained a --fix mode.
function terminator_scan(row, col,   pos, parts) {
  pos = terminator_scan_pos(row, col)
  split(pos, parts, ",")
  if (parts[3] == "semi" || parts[3] == "eof") return "violation"
  return "compliant"
}

# try_fix -- given the (if_row) an "if" keyword was found on and the
# (mrow, mcol) of its condition's matching close paren, for a violation
# classify_if has ALREADY confirmed, decides whether --fix can safely
# rewrite it. Returns "OK" or "REFUSE:<reason>". Uses classify_if's own
# terminator_scan_pos -- no separate notion of "where does this statement
# end" exists anywhere in this file.
function try_fix(if_row, mrow, mcol,    tail, pos, parts, term_row, term_col, term_type, after) {
  if (if_row != mrow) return "REFUSE:if-condition spans multiple physical lines"
  tail = trim(substr(stripped[mrow], mcol + 1))
  if (tail == "") return "REFUSE:braceless body starts on a later physical line"
  if (substr(tail, 1, 1) == "{") return "REFUSE:already braced but collapsed onto one line"
  pos = terminator_scan_pos(mrow, mcol + 1)
  split(pos, parts, ",")
  term_row = parts[1] + 0
  term_col = parts[2] + 0
  term_type = parts[3]
  if (term_type != "semi") return "REFUSE:could not find a single terminating statement"
  if (term_row != mrow) return "REFUSE:braceless body spans multiple physical lines"
  after = trim(substr(stripped[mrow], term_col + 1))
  if (after ~ /^else([^A-Za-z0-9_]|$)/) return "REFUSE:else on the same line"
  if (after != "") return "REFUSE:trailing content after the terminator"
  return "OK"
}

# fix_scan -- the --fix counterpart of scan_ifs: walks the same "if" tokens
# scan_ifs finds, but for each confirmed violation calls try_fix instead of
# printing it, then emits the rewritten file via emit_fixed(). Refusals and
# the per-file fixed-site count go to stderr (kept off stdout, which is the
# file content itself).
function fix_scan(   i, L, n, col, idx, abs, before, nextch, p, code, mrow, mcol, verdict, fixresult, reason, fixed_count) {
  fixed_count = 0
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
              fixresult = try_fix(i, mrow, mcol)
              if (fixresult == "OK") {
                if (mrow in fix_row) {
                  print FPATH ":" i ": REFUSE: multiple if-statements share one physical line -- " lines[i] > "/dev/stderr"
                } else {
                  fix_row[mrow] = mcol
                  fixed_count++
                }
              } else {
                reason = fixresult
                sub(/^REFUSE:/, "", reason)
                print FPATH ":" i ": REFUSE: " reason " -- " lines[i] > "/dev/stderr"
              }
            }
          }
        }
      }
      col = abs + 2
    }
  }
  print FPATH ":FIXCOUNT:" fixed_count > "/dev/stderr"
  emit_fixed()
}

# emit_fixed -- prints the whole file to stdout, rewriting only the lines
# fix_scan recorded in fix_row[]. Indentation is deliberately approximate
# (the if-line's own leading whitespace, +2 for the body); dart format is
# the authority on final indentation, run immediately after --fix in Task 2.
function emit_fixed(   i, raw, indent, head, body, mcol) {
  for (i = 1; i <= NR; i++) {
    if (i in fix_row) {
      mcol = fix_row[i]
      raw = lines[i]
      indent = raw
      sub(/[^ \t].*/, "", indent)
      head = substr(raw, 1, mcol)
      body = substr(raw, mcol + 1)
      sub(/^[ \t]+/, "", body)
      print head " {"
      print indent "  " body
      print indent "}"
    } else {
      print lines[i]
    }
  }
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

# apply_fix DRY_RUN -- runs fix_scan (via the awk program) over every
# non-excluded *.dart file under lib/ and test/. DRY_RUN="1" reports what
# would change without writing; DRY_RUN="0" writes rewritten files in place.
# Prints the refusal report (grouped, as printed by fix_scan) followed by a
# summary line, and always exits 0 -- inspect the printed counts, this is a
# workflow tool, not a gate.
apply_fix() {
  local dry_run="$1"
  local f tmpout refusal_log total_fixed total_files_changed
  refusal_log="$(mktemp)"
  total_files_changed=0

  while IFS= read -r -d '' f; do
    if is_excluded "$f"; then
      continue
    fi
    tmpout="$(mktemp)"
    awk -v FPATH="$f" -v FIXMODE=1 -f "$AWK_SCRIPT" "$f" > "$tmpout" 2>>"$refusal_log"
    if ! cmp -s "$tmpout" "$f"; then
      total_files_changed=$((total_files_changed + 1))
      if [ "$dry_run" = "1" ]; then
        rm -f "$tmpout"
      else
        mv "$tmpout" "$f"
      fi
    else
      rm -f "$tmpout"
    fi
  done < <(find lib test -type f -name '*.dart' -print0 | sort -z)

  grep ': REFUSE: ' "$refusal_log" || true
  total_fixed="$(awk -F: '/:FIXCOUNT:/{s+=$NF} END{print s+0}' "$refusal_log")"
  rm -f "$refusal_log"

  echo ""
  if [ "$dry_run" = "1" ]; then
    echo "DRY RUN -- no files written."
  fi
  echo "Sites auto-fixed: $total_fixed"
  echo "Files changed: $total_files_changed"
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

  # assert_fix_case NAME INPUT_FILE EXPECTED_FILE -- asserts --fix rewrites
  # INPUT_FILE to exactly EXPECTED_FILE's content, then re-runs --fix on that
  # rewritten output and asserts it is unchanged (idempotence).
  assert_fix_case() {
    local name="$1" file="$2" expected_file="$3" actual expected refixed
    actual="$(awk -v FPATH="$file" -v FIXMODE=1 -f "$AWK_SCRIPT" "$file" 2>/dev/null)"
    expected="$(cat "$expected_file")"
    if [ "$actual" = "$expected" ]; then
      echo "PASS: $name"
    else
      echo "FAIL: $name (rewritten output did not match expected)"
      overall=1
    fi
    printf '%s\n' "$actual" > "$SELFTEST_TMPDIR/__refix_input.dart"
    refixed="$(awk -v FPATH="$SELFTEST_TMPDIR/__refix_input.dart" -v FIXMODE=1 -f "$AWK_SCRIPT" "$SELFTEST_TMPDIR/__refix_input.dart" 2>/dev/null)"
    if [ "$refixed" = "$actual" ]; then
      echo "PASS: $name-idempotent"
    else
      echo "FAIL: $name-idempotent (second --fix pass changed already-fixed output)"
      overall=1
    fi
  }

  # assert_fix_refuse_case NAME FILE REASON_SUBSTR -- asserts --fix leaves
  # FILE byte-identical and reports a refusal mentioning REASON_SUBSTR.
  assert_fix_refuse_case() {
    local name="$1" file="$2" reason_substr="$3" original actual stderr_out
    original="$(cat "$file")"
    stderr_out="$SELFTEST_TMPDIR/__stderr_out"
    actual="$(awk -v FPATH="$file" -v FIXMODE=1 -f "$AWK_SCRIPT" "$file" 2>"$stderr_out")"
    if [ "$actual" = "$original" ]; then
      echo "PASS: $name-byte-identical"
    else
      echo "FAIL: $name-byte-identical (file was rewritten but should have been refused)"
      overall=1
    fi
    if grep -q "$reason_substr" "$stderr_out"; then
      echo "PASS: $name-refusal-reported"
    else
      echo "FAIL: $name-refusal-reported (expected refusal mentioning '$reason_substr')"
      overall=1
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

  # --fix mode: in-scope rewrite cases (each also proves idempotence).
  cat > "$SELFTEST_TMPDIR/fix_case_a.dart" <<'EOF'
void f(bool mounted) {
  if (!mounted) return;
}
EOF
  cat > "$SELFTEST_TMPDIR/fix_case_a_expected.dart" <<'EOF'
void f(bool mounted) {
  if (!mounted) {
    return;
  }
}
EOF
  assert_fix_case "fix-A-simple-guard-clause" "$SELFTEST_TMPDIR/fix_case_a.dart" "$SELFTEST_TMPDIR/fix_case_a_expected.dart"

  cat > "$SELFTEST_TMPDIR/fix_case_b.dart" <<'EOF'
void f(bool mounted) {
  if (mounted) doThing(() {});
}
EOF
  cat > "$SELFTEST_TMPDIR/fix_case_b_expected.dart" <<'EOF'
void f(bool mounted) {
  if (mounted) {
    doThing(() {});
  }
}
EOF
  assert_fix_case "fix-B-closure-body" "$SELFTEST_TMPDIR/fix_case_b.dart" "$SELFTEST_TMPDIR/fix_case_b_expected.dart"

  # --fix mode: out-of-scope refusal cases (byte-identical + reason reported).
  cat > "$SELFTEST_TMPDIR/fix_case_c.dart" <<'EOF'
void f(bool a) {
  if (a) return; else return;
}
EOF
  assert_fix_refuse_case "fix-C-else-same-line" "$SELFTEST_TMPDIR/fix_case_c.dart" "else on the same line"

  cat > "$SELFTEST_TMPDIR/fix_case_d.dart" <<'EOF'
void f(bool mounted) {
  if (mounted)
    return;
}
EOF
  assert_fix_refuse_case "fix-D-body-on-later-line" "$SELFTEST_TMPDIR/fix_case_d.dart" "later physical line"

  cat > "$SELFTEST_TMPDIR/fix_case_e.dart" <<'EOF'
void f() {
  if (true) doSomething(
    1,
    2,
  );
}
EOF
  assert_fix_refuse_case "fix-E-multiline-body" "$SELFTEST_TMPDIR/fix_case_e.dart" "spans multiple physical lines"

  cat > "$SELFTEST_TMPDIR/fix_case_f.dart" <<'EOF'
void f(bool mounted) {
  if (mounted) { return; }
}
EOF
  assert_fix_refuse_case "fix-F-collapsed-with-braces" "$SELFTEST_TMPDIR/fix_case_f.dart" "already braced but collapsed"

  # --fix mode: a collection-if is never a violation in the first place, so
  # --fix must leave it byte-identical AND must not emit any refusal for it.
  cat > "$SELFTEST_TMPDIR/fix_case_g.dart" <<'EOF'
Widget build(BuildContext context) {
  return Column(
    children: [
      if (isVisible) const Text('Hello'),
      const SizedBox(height: 8),
    ],
  );
}
EOF
  local fix_g_stderr fix_g_actual
  fix_g_stderr="$SELFTEST_TMPDIR/__fix_g_stderr"
  fix_g_actual="$(awk -v FPATH="$SELFTEST_TMPDIR/fix_case_g.dart" -v FIXMODE=1 -f "$AWK_SCRIPT" "$SELFTEST_TMPDIR/fix_case_g.dart" 2>"$fix_g_stderr")"
  if [ "$fix_g_actual" = "$(cat "$SELFTEST_TMPDIR/fix_case_g.dart")" ]; then
    echo "PASS: fix-G-collection-if-untouched"
  else
    echo "FAIL: fix-G-collection-if-untouched (collection-if was rewritten)"
    overall=1
  fi
  if grep -q ': REFUSE: ' "$fix_g_stderr"; then
    echo "FAIL: fix-G-no-spurious-refusal (collection-if should never be reported as refused)"
    overall=1
  else
    echo "PASS: fix-G-no-spurious-refusal"
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
    --fix)
      local dry=0
      if [ "${2:-}" = "--dry-run" ]; then
        dry=1
      fi
      apply_fix "$dry"
      exit 0
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
      echo "usage: bash tool/check_brace_style.sh [--count|--self-test|--fix [--dry-run]]" >&2
      exit 2
      ;;
  esac
}

main "$@"
