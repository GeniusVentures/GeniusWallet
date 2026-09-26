---
phase: 10-dapp-connectivity
plan: 03
subsystem: dapp-connectivity
tags: [reown, walletkit, responsive-drawer, walletconnect]
requires: [10-02]
provides: [PairDappDrawer.show, reown pairing link never logged]
affects: [10-04]
actuals: {tokens: 7400, tasks: 2, commits: 4}
tech-stack:
  patterns: ["dispose shared TextEditingController/ValueNotifiers in the drawer footer's own State.dispose(), not a whenComplete() on the drawer route's future"]
key-files:
  created: [lib/reown/pair_dapp_drawer.dart, test/reown/pair_dapp_drawer_test.dart]
  modified: [lib/reown/reown_connect_button.dart, test/components/drawer_padding_invariant_test.dart]
key-decisions:
  - "Dispose the drawer's controller/notifiers from the footer's State.dispose(), since the route's popped future resolves before its exit animation finishes"
requirements-completed: [SCR-06]
duration: 55min
completed: 2026-09-26
status: complete
---

# Phase 10 Plan 03: Pairing Drawer Summary

**The QR/paste-link AlertDialog is now a ResponsiveDrawer (PairDappDrawer), and both remaining pairing-catch sites log only the exception's runtimeType.**

## Accomplishments
- `PairDappDrawer.show` replaces the raw dialog in `reown_connect_button.dart`: desktop-paste/phone-QR first view and the toggle are unchanged; fixed error strings for a malformed link and a failed/throwing pair, never the link or exception text. 16 new widget tests (both modes) pin this via a real `show()`.
- `_tryPair` and `_connect`'s outer catch log `${e.runtimeType}` instead of `$e` (D-03).

## Task Commits
1. Task 1 (tracer/TDD): `cee4e16e` (RED), `a932ad25` (GREEN)
2. Task 2: `6fd0a96e`

## Deviations from Plan
- **[Rule 2] `61586317`:** the new drawer's `ResponsiveDrawer.show` call site failed the 21-06 body-padding census gate (`drawer_padding_invariant_test.dart`), which fails loudly on any uncensused call site rather than let one ship unpadded. Added `lib/reown/pair_dapp_drawer.dart` as `shellInset`.
- Disposing the drawer's `TextEditingController`/`ValueNotifier`s via `.whenComplete()` on the route's future (the pattern `swap_settings_drawer.dart`/`job_drawer.dart` already use) crashed under a real Cancel+`pumpAndSettle` test: the future resolves before the exit animation finishes, so the still-rendering field raced a disposed controller. Fixed by disposing in the footer's own `State.dispose()` instead (Rule 1).

## Verification
`flutter test`: `+1837 ~5: All tests passed!`. `flutter analyze`: no issues, exit 0. `dart format --set-exit-if-changed`: 0 changed. `check_brace_style.sh`/`check_raw_colors.sh`: exit 0. `check_no_new_key_logging.sh --scan-tree` (default file, unrelated to lib/reown): OK. EOL `i/lf` for both new files.
