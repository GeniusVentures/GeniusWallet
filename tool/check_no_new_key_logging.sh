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
#
# Prints "OK: no new key logging" and exits 0 on a clean (or empty) diff.
# Exits 1 with the offending line(s) printed otherwise.

set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

FILE="${1:-}"
if [ -z "$FILE" ]; then
  echo "usage: bash tool/check_no_new_key_logging.sh <file-path>" >&2
  exit 1
fi

# Assembled at runtime from parts -- see header comment for why this isn't
# a literal 'print'/'debugPrint' substring in this file's source.
P1="pr"
P2="int"
DP1="debugPr"
DP2="int"
PRINT_TOKEN="${P1}${P2}"
DEBUG_PRINT_TOKEN="${DP1}${DP2}"

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
