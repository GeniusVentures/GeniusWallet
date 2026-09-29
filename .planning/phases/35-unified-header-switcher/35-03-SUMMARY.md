---
phase: 35-unified-header-switcher
plan: 03
subsystem: ui
requires:
  - phase: 35-unified-header-switcher
    provides: AccountDrawer.show as the switcher entry point (35-01)
provides:
  - AccountSwitcher, the one desktop chip naming the active wallet and the SDK account
actuals: {tokens: 4600, tasks: 2, commits: 2}
key-files:
  modified: [lib/account/account_switcher.dart, lib/components/overlay/responsive_overlay.dart, lib/account/sdk_account_manager.dart, test/components/wallet_identity_test.dart, test/components/desktop_top_bar_text_scale_test.dart, test/components/drawer_padding_invariant_test.dart]
key-decisions:
  - "Chip label prefers walletName, falling back to the short address only when empty; SDKAccountManagerButton deleted outright since the switcher drawer already covers every SDK action (35-01)"
requirements-completed: [SWT-01, SWT-04, SWT-05]
duration: 25min
completed: 2026-09-29
status: complete
---

# Phase 35 Plan 03: Unified desktop chip Summary

**One `AccountSwitcher` chip replaces the separate wallet and SDK-account chips, naming both in its label and tooltip and opening the same switcher drawer.**

## Accomplishments
- `account_dropdown_selector.dart` renamed to `account_switcher.dart`/`AccountSwitcher`; tooltip reads "Sending from {wallet} · Node running as {sdk account}" or "Node not running"
- `responsive_overlay.dart` holds one chip instead of two, no emptiness guard, closing the old phantom-gap ponytail note
- `SDKAccountManagerButton` and its private drawer deleted; the stale drawer-census entry removed with it

## Task Commits
1. One desktop chip naming both selections - `d163b9c0` (feat)
2. Delete the old SDK chip; full phase gate - `a8238861` (feat)

## Verification
No deviations. Full suite 1958 passed / 5 skipped / 0 failed (net zero: +1 tooltip test, -1 stale census test). Analyze/format/brace/raw-colour/key-logging scripts clean. Windows debug build compiles (not run). VER-02 (live-node switcher walk, desktop and phone) pending for the end-of-milestone manual UAT.

## Self-Check: PASSED
All modified files present; both commit hashes confirmed in git log.
