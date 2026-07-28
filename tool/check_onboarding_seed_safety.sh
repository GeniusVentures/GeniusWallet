#!/usr/bin/env bash
#
# tool/check_onboarding_seed_safety.sh
#
# WHAT THIS IS FOR
# ----------------
# Phase 06 (onboarding) re-skinned the highest-consequence surface in the whole
# app -- the screens where a recovery phrase and a PIN exist in plaintext, in
# memory and on screen. 06-UI-SPEC.md Section 3 defines a SIX-ITEM SECURITY GATE
# binding on every plan that touched recovery_phrase_screen.dart,
# verify_recovery_phrase_screen.dart, paste_field.dart and pin_screen.dart. Each
# of 06-03..06-05 checked its OWN slice against its OWN diff. Nothing had ever
# checked the SET, against the FINISHED tree, after every edit landed -- and a
# property that held in every individual diff can still be false in the union.
#
# This script is that missing gate: Section 3's six properties re-asserted across
# the phase's finished scope in one runnable command, re-runnable by any later
# phase that touches these files.
#
# WHAT THIS SCRIPT CHECKS  (each maps 1:1 to a 06-UI-SPEC Section 3 property)
# --------------------------------------------------------------------------
# CHECK 1 (3.1) -- the DISPLAYED recovery phrase stays READ-ONLY: neither seed
#   screen declares a SelectableText or an editable field widget (TextField /
#   TextFormField) on a non-comment line. The only sanctioned way onto the
#   clipboard is the explicit Copy button (CHECK 4), never select/long-press.
# CHECK 2 (3.2) -- the hide-toggle still DEFAULTS TO SHOWN:
#   recovery_phrase_screen still declares `_isVisible = true`. Flipping it
#   hidden-first would be a behaviour change this re-skin does not include.
# CHECK 3 (3.3) -- NO console output in this phase's scope and NO bloc observer
#   anywhere: NewWalletState lists recoveryWords in its Equatable props, so any
#   print/debugPrint of the state, or any registered BlocObserver.onChange, would
#   put the plaintext seed on the console. Asserts zero print/debugPrint-family
#   calls under lib/onboarding/** and in lib/screens/pin_screen.dart, and zero
#   registered/declared bloc observer anywhere under lib/.
# CHECK 4 (3.4, finding 19) -- the copy handler's lifecycle guard is still
#   ADJACENT to the awaited clipboard copy: `if (!mounted) return;` (or, since
#   22-04 made AGENTS.md's brace rule universal, the braced
#   `if (!mounted) {\n  return;\n}` form) must sit within the two lines
#   immediately AFTER the awaited FlutterClipboard.copy(...) call and before
#   the ScaffoldMessenger call. This is an ADJACENCY test, not a
#   presence test -- a guard that drifted below the snackbar call would pass a
#   presence check while re-opening exactly the use-after-dispose race finding 19
#   describes.
# CHECK 5 (3.6) -- the mnemonic/key IMPORT field is IME-hardened:
#   paste_field.dart sets both `autocorrect: false` and `enableSuggestions:
#   false` on non-comment lines, so imported key material is not offered to the
#   OS predictive-text / spell-check / IME-learning stores.
# CHECK 6 (4.9) -- PIN entry stays MASKED and its error text stays
#   appearance-aware: pin_screen.dart still sets `obscureText: true`, and uses the
#   appearance-aware `gw.statusError` (which meets AA in both modes) rather than
#   the mode-invariant flat `GeniusWalletColors.statusError` (~3.4:1 in light -- an
#   AA fail).
#
# Every check STRIPS whole-line `//` comments before matching, so a header
# comment, a doc-string or a commented-out line can neither satisfy nor trip a
# check -- the grep-hygiene rule this project learned the hard way.
#
# WHY THE CONSOLE-LOGGING TOKENS ARE ASSEMBLED AT RUNTIME
# -------------------------------------------------------
# CHECK 3 greps for the print/debugPrint family. If this script's own source
# embedded those literals whole, the script would itself become a hit for the
# very tripwire it implements (and for the literal-marker class of check that
# tool/verify_additive_boundary.sh's WIRE- rule exists to catch). So -- exactly
# as tool/check_no_new_key_logging.sh does, and for the same stated reason -- the
# tokens are assembled at runtime from parts and never appear whole in this file.
#
# WHY THE ANALYZER OR A LINT RULE CANNOT DO THIS JOB
# --------------------------------------------------
# None of these six are type errors or lint violations -- they are security
# INVARIANTS expressed as the absence (or adjacency) of specific widgets and
# calls. `flutter analyze` has no "this awaited call must be followed within two
# lines by a mounted guard" rule, no "this state class must never be printed"
# rule, and no "this displayed field must stay read-only" rule. That is why this
# is a standalone gate rather than a lint.
#
# USAGE
# -----
#   bash tool/check_onboarding_seed_safety.sh
#
# Takes no arguments; checks the whole of this phase's finished scope. Prints one
# PASS/FAIL line per check, then a single summary line. Exits 0 iff all six pass,
# 1 (with the offending detail) otherwise.
#
# SCOPE HONESTY  (what this gate does NOT prove -- do not overclaim)
# -----------------------------------------------------------------
# This is a STATIC TEXT gate. It greps source; it cannot observe runtime
# behaviour. In particular it does NOT prove:
#   - that a seed never reaches the console through an INTERPOLATED error message,
#     or through a future `toString()` override on NewWalletState (3.3 binds
#     against ADDING the first such call; this gate cannot detect one that leaks
#     the state indirectly);
#   - that no screenshot / screen-recording / remote-desktop tool can capture the
#     phrase while it is shown (3.5 -- develop has NO secure-window flag; the
#     design assumes no such protection, and this gate asserts nothing about it);
#   - anything about the CORRECTNESS of the words, the PIN, or the crypto beneath.
# And it is a guard a phase must RUN, not a hook that fires unbidden: this repo
# has no pre-commit hooks, and its only CI workflow does not run check steps.
# Re-run it by hand whenever a change touches lib/onboarding/** or
# lib/screens/pin_screen.dart.

set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

# Assembled at runtime from parts -- see the header for why the console-logging
# literals never appear whole in this file's source.
P1="pr"; P2="int"
DP1="debugPr"; DP2="int"
PRINT_TOKEN="${P1}${P2}"
DEBUG_PRINT_TOKEN="${DP1}${DP2}"

# The two security-critical seed screens and the shared import + PIN files.
RECOVERY="lib/onboarding/new_wallet/view/recovery_phrase_screen.dart"
VERIFY="lib/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart"
PASTE="lib/onboarding/widgets/paste_field.dart"
PIN="lib/screens/pin_screen.dart"

FAIL=0

# strip_comments <file> -- emit the file with whole-line // comments removed, so a
# comment can neither satisfy nor trip any check.
strip_comments() { grep -vE '^[[:space:]]*//' "$1" 2>/dev/null; }

# ---------------------------------------------------------------------------
# CHECK 1 (3.1): the displayed recovery phrase stays read-only.
# ---------------------------------------------------------------------------
echo "== CHECK 1 (3.1): recovery phrase is read-only (no selectable/editable widget) =="
c1_hits=""
for f in "$RECOVERY" "$VERIFY"; do
  hit=$(strip_comments "$f" | grep -nE '\b(SelectableText|TextField|TextFormField)\b' || true)
  if [ -n "$hit" ]; then
    c1_hits="${c1_hits}${f}:"$'\n'"${hit}"$'\n'
  fi
done
if [ -n "$c1_hits" ]; then
  echo "FAIL [3.1]: a selectable/editable text widget appears on the displayed recovery phrase:"
  printf '%s' "$c1_hits" | sed 's/^/    /'
  FAIL=1
else
  echo "PASS [3.1]: neither seed screen declares SelectableText/TextField/TextFormField."
fi

# ---------------------------------------------------------------------------
# CHECK 2 (3.2): the hide-toggle still defaults to shown.
# ---------------------------------------------------------------------------
echo "== CHECK 2 (3.2): _isVisible defaults to shown =="
if strip_comments "$RECOVERY" | grep -qE '_isVisible[[:space:]]*=[[:space:]]*true'; then
  echo "PASS [3.2]: _isVisible = true (phrase shown by default) preserved."
else
  echo "FAIL [3.2]: _isVisible default is no longer 'true' in $RECOVERY."
  FAIL=1
fi

# ---------------------------------------------------------------------------
# CHECK 3 (3.3): no console output in scope, no bloc observer anywhere.
# ---------------------------------------------------------------------------
echo "== CHECK 3 (3.3): no print/debugPrint in scope, no bloc observer in lib/ =="
# 3a: print/debugPrint family across this phase's scope (lib/onboarding/** + pin).
scope_files=$( { git ls-files 'lib/onboarding/'; echo "$PIN"; } | sort -u )
log_hits=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  hit=$(strip_comments "$f" | grep -nE "(^|[^A-Za-z0-9_])(${PRINT_TOKEN}|${DEBUG_PRINT_TOKEN})[[:space:]]*\(" || true)
  if [ -n "$hit" ]; then
    log_hits="${log_hits}${f}:"$'\n'"${hit}"$'\n'
  fi
done <<< "$scope_files"
if [ -n "$log_hits" ]; then
  echo "FAIL [3.3a]: a console-logging call appears in this phase's scope:"
  printf '%s' "$log_hits" | sed 's/^/    /'
  FAIL=1
else
  echo "PASS [3.3a]: no print/debugPrint-family call under lib/onboarding/** or in pin_screen.dart."
fi
# 3b: a registered/declared bloc observer anywhere in lib/. Registration is
# `Bloc.observer =`; declaring a class that `extends BlocObserver` is the other
# half. Either would enable state-transition logging of NewWalletState.
obs_hits=$(git ls-files 'lib/' | xargs grep -nE 'Bloc\.observer[[:space:]]*=|extends[[:space:]]+BlocObserver' 2>/dev/null \
  | grep -vE '^[^:]*:[0-9]+:[[:space:]]*//' || true)
if [ -n "$obs_hits" ]; then
  echo "FAIL [3.3b]: a bloc observer is registered/declared in lib/ (can log NewWalletState):"
  printf '%s\n' "$obs_hits" | sed 's/^/    /'
  FAIL=1
else
  echo "PASS [3.3b]: no Bloc.observer registration or BlocObserver subclass in lib/."
fi

# ---------------------------------------------------------------------------
# CHECK 4 (3.4, finding 19): the mounted guard is ADJACENT to the awaited copy.
# ---------------------------------------------------------------------------
echo "== CHECK 4 (3.4): 'if (!mounted) return;' within 2 lines after the awaited copy =="
# Comment-stripped first so a commented-out guard cannot satisfy this, then
# grep -A2 on the awaited copy call and require the guard inside that 3-line
# window. ADJACENCY, not presence: a guard that drifted below the snackbar call
# would fall outside the window and fail -- finding 19's exact failure mode.
#
# The window is collapsed to a single space-joined line before matching so the
# ONE regex accepts both the historical one-line form (`if (!mounted) return;`)
# and the braced multi-line form AGENTS.md's brace rule requires everywhere
# since 22-04 (`if (!mounted) {` on the guard's own line, `return;` on the
# next) -- the optional `\{?` is the only difference between the two shapes;
# adjacency is still enforced by the -A2 window collapsed into that one line.
copy_window=$(strip_comments "$RECOVERY" | grep -A2 -E 'await[[:space:]]+FlutterClipboard\.copy\(' || true)
copy_window_collapsed=$(printf '%s\n' "$copy_window" | tr '\n' ' ' | tr -s '[:space:]' ' ')
if printf '%s' "$copy_window_collapsed" | grep -qE 'if[[:space:]]*\([[:space:]]*![[:space:]]*mounted[[:space:]]*\)[[:space:]]*\{?[[:space:]]*return;'; then
  echo "PASS [3.4]: the mounted guard is adjacent to (<=2 lines after) the awaited copy."
else
  echo "FAIL [3.4]: no 'if (!mounted) return;' within 2 lines after the awaited FlutterClipboard.copy() in $RECOVERY."
  FAIL=1
fi

# ---------------------------------------------------------------------------
# CHECK 5 (3.6): the import field is IME-hardened.
# ---------------------------------------------------------------------------
echo "== CHECK 5 (3.6): paste_field.dart sets autocorrect:false and enableSuggestions:false =="
paste_body=$(strip_comments "$PASTE")
if printf '%s\n' "$paste_body" | grep -qE 'autocorrect:[[:space:]]*false' \
   && printf '%s\n' "$paste_body" | grep -qE 'enableSuggestions:[[:space:]]*false'; then
  echo "PASS [3.6]: both autocorrect:false and enableSuggestions:false present on the import field."
else
  echo "FAIL [3.6]: import field is missing autocorrect:false and/or enableSuggestions:false in $PASTE."
  FAIL=1
fi

# ---------------------------------------------------------------------------
# CHECK 6 (4.9): PIN stays masked; error text stays appearance-aware.
# ---------------------------------------------------------------------------
echo "== CHECK 6 (4.9): pin_screen.dart masks entry and uses gw.statusError (not the flat const) =="
pin_body=$(strip_comments "$PIN")
c6_ok=1
if ! printf '%s\n' "$pin_body" | grep -qE 'obscureText:[[:space:]]*true'; then
  echo "FAIL [4.9]: pin_screen.dart no longer sets obscureText: true."
  c6_ok=0
fi
if ! printf '%s\n' "$pin_body" | grep -qE '(^|[^A-Za-z0-9_])gw\.statusError'; then
  echo "FAIL [4.9]: pin_screen.dart no longer uses the appearance-aware gw.statusError."
  c6_ok=0
fi
if printf '%s\n' "$pin_body" | grep -qE 'GeniusWalletColors\.statusError'; then
  echo "FAIL [4.9]: pin_screen.dart uses the mode-invariant flat GeniusWalletColors.statusError (~3.4:1 in light, AA fail)."
  c6_ok=0
fi
if [ "$c6_ok" -eq 1 ]; then
  echo "PASS [4.9]: obscureText:true and gw.statusError present; flat statusError const absent."
else
  FAIL=1
fi

echo ""
if [ "$FAIL" -ne 0 ]; then
  echo "check_onboarding_seed_safety.sh: FAILED"
  exit 1
else
  echo "check_onboarding_seed_safety.sh: PASSED -- all six Section 3 checks hold over the finished tree."
  exit 0
fi
