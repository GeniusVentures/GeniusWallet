#!/usr/bin/env bash
#
# tool/check_no_new_key_logging.sh
#
# WHAT THIS IS FOR
# ----------------
# Plan 04-06 re-skins the SDK account manager's mnemonic/private-key entry
# dialogs (GAP-03). Those dialogs handle raw key material in a
# TextEditingController -- the re-skin must be presentation-only and must
# never introduce a console-logging call anywhere in that flow (V6,
# Information Disclosure -- 04-RESEARCH §Security Domain).
#
# WHAT THIS SCRIPT CHECKS
# ------------------------
# Takes one file path argument, diffs it against the index/HEAD, and fails
# if any ADDED line ('+' prefix, never the '+++' file header) contains a
# call from the print/debug-print family. The token is assembled at runtime
# from parts so this script's own source never embeds the literal it greps
# for -- embedding it here would make this new source file itself trip the
# same class of tripwire tool/verify_additive_boundary.sh's WIRE- check
# exists to catch (a literal marker string living in tracked source).
#
# USAGE
# -----
#   bash tool/check_no_new_key_logging.sh <file-path>
#   bash tool/check_no_new_key_logging.sh --scan-tree [file-path ...]
#
# Prints "OK: no new key logging" and exits 0 on a clean (or empty) diff.
# Exits 1 with the offending line(s) printed otherwise.
#
# --scan-tree MODE (added 22-08, CI wiring)
# ------------------------------------------
# The default (single-file, no-ref) mode diffs the WORKING TREE against the
# INDEX. That is exactly right for a developer mid-edit in a plan session
# (04-06's original use case), but on a CI runner's fresh checkout the
# working tree and the index are identical -- the diff is always empty, so
# the gate would print "OK" unconditionally regardless of what the file
# actually contains. That is a vacuous pass: a check that cannot fail is
# decoration, not a gate (see 22-08-PLAN.md's quality-job acceptance
# criteria, and the same reasoning that made 22-02's --self-test mandatory).
#
# --scan-tree checks the CURRENT CONTENT of the given file(s) (comment-lines
# stripped, same convention as tool/check_onboarding_seed_safety.sh's
# strip_comments) for any print/debugPrint-family call -- a standing
# invariant over the finished tree, not a diff. If no file is given it
# defaults to lib/account/sdk_account_manager.dart, the one file this script
# has ever been run against (Phase 4-06, GAP-03: the SDK account manager's
# mnemonic/private-key entry dialogs). Exits 1 and prints the offending
# line(s) if any file contains a call; 0 otherwise.

set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

# Assembled at runtime from parts -- see header comment for why this isn't
# a literal 'print'/'debugPrint' substring in this file's source.
P1="pr"
P2="int"
DP1="debugPr"
DP2="int"
PRINT_TOKEN="${P1}${P2}"
DEBUG_PRINT_TOKEN="${DP1}${DP2}"

if [ "${1:-}" = "--scan-tree" ]; then
  shift
  FILES=("$@")
  if [ "${#FILES[@]}" -eq 0 ]; then
    FILES=("lib/account/sdk_account_manager.dart")
  fi
  FAIL=0
  for f in "${FILES[@]}"; do
    if [ ! -f "$f" ]; then
      echo "FAIL: $f not found" >&2
      FAIL=1
      continue
    fi
    BODY=$(grep -vE '^[[:space:]]*//' "$f" 2>/dev/null || true)
    OFFENDERS=$(printf '%s\n' "$BODY" | grep -nE "(^|[^A-Za-z0-9_])(${PRINT_TOKEN}|${DEBUG_PRINT_TOKEN})[[:space:]]*\(" || true)
    if [ -n "$OFFENDERS" ]; then
      echo "FAIL: console-logging call(s) detected in $f:"
      echo "$OFFENDERS"
      FAIL=1
    else
      echo "OK: no key logging in $f"
    fi
  done
  exit $FAIL
fi

FILE="${1:-}"
if [ -z "$FILE" ]; then
  echo "usage: bash tool/check_no_new_key_logging.sh <file-path>" >&2
  echo "       bash tool/check_no_new_key_logging.sh --scan-tree [file-path ...]" >&2
  exit 1
fi

DIFF=$(git diff -- "$FILE" 2>/dev/null || true)

if [ -z "$DIFF" ]; then
  echo "OK: no new key logging (no diff for $FILE)"
  exit 0
fi

# Only ADDED lines ('+' prefix), excluding the '+++' file header line.
ADDED=$(printf '%s\n' "$DIFF" | grep -E '^\+[^+]' || true)

OFFENDERS=$(printf '%s\n' "$ADDED" | grep -E "(${PRINT_TOKEN}|${DEBUG_PRINT_TOKEN})[[:space:]]*\(" || true)

if [ -n "$OFFENDERS" ]; then
  echo "FAIL: new console-logging call(s) detected in $FILE:"
  echo "$OFFENDERS"
  exit 1
fi

echo "OK: no new key logging"
exit 0
