---
phase: 32-contrast-and-text-scale-accessibility-pass
plan: 04
status: complete
requirements: []
key-files:
  created: [test/theme/status_text_color_invariant_test.dart]
  modified: [lib/components/inputs/gw_text_field.dart, lib/components/inputs/gw_select.dart, lib/components/feedback/gw_error_state.dart, lib/squid_router/swap_screen.dart, lib/dashboard/bridge/bridge_screen.dart, lib/squid_router/swap_settings_drawer.dart, lib/reown/reown_connect_button.dart, lib/squid_router/route_details_card.dart, lib/dashboard/home/widgets/transaction_displays.dart]
actuals: { tokens: 3906, tasks: 3, commits: 5 }
---

# Phase 32 Plan 04: form errors, banners, CTAs, WalletConnect and the census gate

Nine call sites (form field errors, error banners, swap/bridge refusal CTAs, the slippage
message, WalletConnect's disconnect/error states, the route's Price Impact, the receipt's
Not charged) now paint `statusSuccessText`/`statusErrorText` instead of the fill-tuned
raw token. A new source-scan test, `status_text_color_invariant_test.dart`, locks every
remaining raw read in `lib/` (outside `lib/theme/`) to a hand-written census — 25 files,
50 reads — via RED/GREEN TDD (test written first, failed exactly at the two un-swapped
sites, passed once fixed). Independently re-scanned `lib/` before trusting the plan's
figure; it matched exactly, no discrepancy. Confirmed both open-question sites at
execution: `swap_settings_drawer.dart:149`'s `edge` feeds the field border (:241, stays
raw); `reown_connect_button.dart:547,559`'s `stateColor` feeds icon+dot+overlay+label as
one colour (both swapped).

## Baseline vs. after (measured)

Full `flutter analyze`: "No issues found!", exit 0. `flutter test`: 1787 passed, 5 skipped,
0 failed. `dart format --set-exit-if-changed`: exit 0. `check_brace_style.sh`: exit 0. New
test file is LF. Regression check: a raw `.statusError` read appended to an uncensused
file failed the census test immediately; reverted.

## Deviations

None — plan executed exactly as written.

## Self-Check: PASSED

Commits 41f2a1df, 2b4bdb68, 21a5df3d, ca0a965b verified present in `git log`; all created/
modified files verified present on disk.
