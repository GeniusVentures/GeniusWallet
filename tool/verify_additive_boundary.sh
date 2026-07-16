#!/usr/bin/env bash
#
# tool/verify_additive_boundary.sh
#
# WHAT THIS IS FOR
# ----------------
# Phase 03 (gw-component-library) ports 50 files from origin/ui-redesign-3.514 into
# lib/components/ (and a few sibling dirs) as NEW paths that don't exist on develop today.
# Three of those new files declare a public class whose NAME already exists on develop at a
# DIFFERENT path:
#
#   Loading               lib/components/loading/loading.dart   vs  lib/components/loading.dart
#   Splash                 lib/components/splash.dart             vs  lib/screens/splash.dart
#   WalletsOverview(+State) lib/components/wallets_overview.g.dart vs lib/components/wallet_overview.dart
#
# Different import paths mean the Dart compiler and `flutter analyze` see NO collision at all.
# An import silently repointed from the canonical path to the shadow path -- an IDE
# auto-import, a careless find/replace, an executor skimming a table -- swaps one widget for
# another with zero diagnostic. See 03-SHADOW-NAMES.md for the full writeup this script
# implements, including *why* each of the three pairs is dangerous.
#
# WHY THE ANALYZER CANNOT DO THIS JOB
# ------------------------------------
# `flutter analyze` resolves each file's own imports and has no "is this class name already
# declared elsewhere under a different path" check. It is also explicitly configured blind to
# `*.g.dart` files (analysis_options.yaml:5) -- and the single most dangerous shadow of the
# three (WalletsOverview) lives in exactly such a file. That is the whole reason this script
# exists instead of a lint rule.
#
# WHAT THIS SCRIPT CHECKS
# ------------------------
# Check 1 -- shadow import boundary, one pair at a time: the canonical path's importer set
#            must exactly match the recorded baseline (a literal sorted list -- a bare COUNT
#            would pass even if one legitimate caller is silently repointed and a different
#            file happens to start importing the canonical path), and the shadow path's
#            importer set must be a subset of that pair's allowlist.
# Check 2 -- the generic gate: re-derive, from the working tree, every public class name
#            declared in more than one file under lib/ (including *.g.dart -- this check must
#            NOT honor analysis_options.yaml's exclude), and assert that set is a subset of the
#            CAPTURED baseline in tool/shadow-baseline.txt. develop's census is *not* empty
#            before this phase starts (4 pre-existing legitimate parallel bloc-event
#            duplicates) -- see tool/shadow-baseline.txt and 03-SHADOW-NAMES.md for why those
#            four are not hazards. A 5th, unforeseen duplicate anywhere in lib/ trips this
#            check even if it has nothing to do with the three known pairs.
# Check 3 -- WIRE-01 standing rule: `grep -rn "WIRE-" lib/` must return nothing. Cheap
#            standing tripwire, not a live risk today.
#
# WHEN TO RE-RUN
# ---------------
# Every plan in Phase 3 runs this in its own <verify>. Re-run by hand whenever a change
# touches lib/components/, lib/screens/splash.dart, lib/navigation/router.dart, or
# lib/dashboard/home/view/dashboard_screen.dart.
#
# SCOPE HONESTY
# --------------
# This is a guard a phase must RUN, not a hook that fires unbidden. This repo has no
# pre-commit hooks, and its only CI workflow (.github/workflows/build.yml) is a build matrix
# that does not run `flutter analyze` or any check step. Wiring this into CI is a real option
# but is out of this phase's scope -- see 03-SHADOW-NAMES.md.
#
# Prints each check's result. Exits 0 if everything passes, 1 (with the offending detail
# printed) otherwise.

set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

FAIL=0

# ---------------------------------------------------------------------------------------
# Check 1: shadow import boundary, one pair at a time.
# ---------------------------------------------------------------------------------------

check_pair() {
  local label="$1" canonical_import="$2" canonical_expected="$3" shadow_import="$4" shadow_allowlist="$5"

  local actual_canonical expected_sorted
  actual_canonical=$(grep -rl -- "$canonical_import" lib/ 2>/dev/null | sort)
  expected_sorted=$(printf '%s\n' "$canonical_expected" | sort)

  if [ "$actual_canonical" != "$expected_sorted" ]; then
    echo "FAIL [$label]: canonical importer set for '$canonical_import' does not match the recorded baseline."
    echo "  --- expected ---"
    printf '%s\n' "$expected_sorted" | sed 's/^/    /'
    echo "  --- actual ---"
    printf '%s\n' "$actual_canonical" | sed 's/^/    /'
    FAIL=1
  else
    local n
    n=$(printf '%s\n' "$expected_sorted" | grep -c .)
    echo "PASS [$label]: canonical importer set for '$canonical_import' matches baseline ($n files)."
  fi

  local actual_shadow offenders
  actual_shadow=$(grep -rl -- "$shadow_import" lib/ 2>/dev/null | sort)
  offenders=""
  if [ -n "$actual_shadow" ]; then
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      if ! printf '%s\n' "$shadow_allowlist" | grep -qx -- "$f"; then
        offenders="${offenders}${f}"$'\n'
      fi
    done <<< "$actual_shadow"
  fi
  if [ -n "$offenders" ]; then
    echo "FAIL [$label]: shadow path '$shadow_import' is imported outside its allowlist by:"
    printf '%s' "$offenders" | sed 's/^/    /'
    FAIL=1
  else
    echo "PASS [$label]: shadow path '$shadow_import' has no un-allowlisted importers."
  fi
}

echo "== Check 1: shadow import boundary =="

LOADING_CANONICAL_EXPECTED='lib/banxa/banxa_orders_history.dart
lib/banxa/banxa_payment.dart
lib/banxa/checkout_qr.dart
lib/banxa/user_kyc/kyc_registration.dart
lib/components/coins/view/coins_screen.dart
lib/components/custom_future_builder.dart
lib/components/sgnus/sgnus_connection_widget.dart
lib/dashboard/chart/markets_search_bar.dart
lib/dashboard/news/view/crypto_news_screen.dart
lib/onboarding/existing_wallet/view/import_security_screen.dart
lib/onboarding/new_wallet/view/recovery_phrase_screen.dart
lib/onboarding/routes/wallet_routes.dart
lib/screens/banxa_buy_screen.dart
lib/screens/loading_screen.dart
lib/screens/splash.dart
lib/squid_router/swap_screen.dart
lib/submit_job/view/submit_job_screen.dart
lib/web/web_view_windows.dart'

check_pair \
  "Loading" \
  "package:genius_wallet/components/loading.dart" \
  "$LOADING_CANONICAL_EXPECTED" \
  "package:genius_wallet/components/loading/loading.dart" \
  "lib/dev/design_gallery_screen.dart"

check_pair \
  "Splash" \
  "package:genius_wallet/screens/splash.dart" \
  "lib/navigation/router.dart" \
  "package:genius_wallet/components/splash.dart" \
  "lib/dev/design_gallery_screen.dart"

check_pair \
  "WalletsOverview" \
  "package:genius_wallet/components/wallet_overview.dart" \
  "lib/dashboard/home/view/dashboard_screen.dart" \
  "package:genius_wallet/components/wallets_overview.g.dart" \
  "lib/dev/generated_closure_canary.dart"

# ---------------------------------------------------------------------------------------
# Check 2: duplicate-class-name census vs captured baseline (the generic gate).
# ---------------------------------------------------------------------------------------

echo ""
echo "== Check 2: duplicate public class name census (includes .g.dart -- analyzer is blind to those) =="

BASELINE_FILE="tool/shadow-baseline.txt"
if [ ! -f "$BASELINE_FILE" ]; then
  echo "FAIL: $BASELINE_FILE not found."
  FAIL=1
else
  # Deliberately does NOT honor analysis_options.yaml's *.g.dart exclude -- that blindness is
  # exactly the hole this check exists to cover. Includes `abstract class` declarations too.
  CENSUS=$(grep -rhoE "^(abstract )?class [A-Za-z_][A-Za-z0-9_]*" lib/ --include=*.dart \
    | awk '{print $NF}' | sort | uniq -d)

  # Column 1 of the baseline, skipping comments and blank lines -- a bare count over the raw
  # file would count the header/comment lines too, which is how this kind of check quietly
  # self-invalidates.
  BASELINE_NAMES=$(grep -v '^#' "$BASELINE_FILE" | grep -E '^[A-Za-z_]' | awk '{print $1}' | sort -u)

  UNBASELINED=""
  if [ -n "$CENSUS" ]; then
    while IFS= read -r cls; do
      [ -z "$cls" ] && continue
      if ! printf '%s\n' "$BASELINE_NAMES" | grep -qx -- "$cls"; then
        UNBASELINED="${UNBASELINED}${cls}"$'\n'
      fi
    done <<< "$CENSUS"
  fi

  if [ -n "$UNBASELINED" ]; then
    echo "FAIL: the following duplicate public class name(s) are NOT in the captured baseline ($BASELINE_FILE):"
    printf '%s' "$UNBASELINED" | sed 's/^/    /'
    echo "  Do NOT add them to the baseline without a written, reviewed justification -- investigate first."
    FAIL=1
  else
    local_count=$(printf '%s\n' "$CENSUS" | grep -c . || true)
    echo "PASS: duplicate-class census ($local_count name(s)) is a subset of the captured baseline."
  fi
fi

# ---------------------------------------------------------------------------------------
# Check 3: WIRE-01 standing rule.
# ---------------------------------------------------------------------------------------

echo ""
echo "== Check 3: WIRE- standing tripwire =="
WIRE_HITS=$(grep -rn "WIRE-" lib/ 2>/dev/null || true)
if [ -n "$WIRE_HITS" ]; then
  echo "FAIL: 'WIRE-' marker(s) found in lib/ (should be zero):"
  echo "$WIRE_HITS"
  FAIL=1
else
  echo "PASS: no 'WIRE-' markers in lib/."
fi

echo ""
if [ "$FAIL" -ne 0 ]; then
  echo "verify_additive_boundary.sh: FAILED"
  exit 1
else
  echo "verify_additive_boundary.sh: PASSED"
  exit 0
fi
