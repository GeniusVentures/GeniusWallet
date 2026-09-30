---
phase: 39-banxa-integration-hardening
plan: 13
subsystem: banxa-entry-points-ci
tags: [banxa, buy, ci, secrets, phase-gate]
requires: [39-12]
provides:
  - "Buy GNUS from Home, Assets, the GNUS coin page and the Transactions header"
  - "CI builds take the Banxa key from a secret, masked; key-logging scan covers lib/banxa"
key-files:
  created: [test/banxa/buy_entry_points_test.dart]
  modified: [lib/tokens/token_info_screen.dart, lib/dashboard/transactions/transactions_screen.dart, lib/components/coins/view/coins_screen.dart, lib/dashboard/assets/assets_screen.dart, test/dashboard/buy_orders_filter_test.dart, .github/workflows/build.yml, .planning/phases/39-banxa-integration-hardening/39-VALIDATION.md]
status: complete
actuals: {tokens: 30000, tasks: 3, commits: 3}
---
# Phase 39 Plan 13: Buy entry points, CI key wiring, phase gate Summary

Buy GNUS is one tap from every main surface, CI builds get `BANXA_API_KEY` without printing it, and the phase is green on every automated gate. The two Banxa-dependent checks are recorded as gates, not passes.

## Result
- Entry points: GNUS coin page (Buy, GNUS only, row is now a `Wrap`), Transactions header (Buy GNUS), Home and Assets origin labels fixed (both said MARKETS). 7 new tests in `test/banxa/buy_entry_points_test.dart`, including 360px overflow in dark and light; the overflow test fails with the old `Row`.
- CI: `GW_BANXA_API_KEY: ${{ secrets.BANXA_API_KEY }}` on the Flutter and AAB steps, base64 form masked, `--dart-define` on 5 build lines, key-logging scan over every `lib/banxa` file. YAML parses; no workflow was dispatched.
- Commits: 012f7297 (entry points), 9f517953 (CI). Validation file and this summary in the docs commit.

## Phase gate
- Full `flutter test`: 2341 passed, 6 skipped, 0 failed (plan 12 ended at 2334; +7 new). `flutter analyze lib test` exit 0.
- `dart format --set-exit-if-changed lib test`, `check_brace_style.sh`, `check_raw_colors.sh`, `check_no_new_key_logging.sh --scan-tree` over sdk_account_manager and all `lib/banxa` files: all exit 0. No CRLF in lib/banxa or test/banxa. Only `lib/main.dart` constructs `BanxaApiService()`. ID gate over the phase diff (base 580e4429): 0. No FittedBox/AutoSizeText in the guarded dirs.
- Windows sandbox debug build: `flutter build windows --debug --dart-define=GW_BANXA_SANDBOX=true` with the documented Release-pinned CMAKE_ARGUMENTS compiled (genius_wallet.exe, 191s), built with no key.
- `tool/verify_additive_boundary.sh` exits 1; pre-existing and identical on develop (see 39-12), not fixed.

## Live-walk gates (39-VALIDATION.md)
- GATE A, geniuswallet:// return URL: blocked on Banxa (needs a live createBuyOrder, which needs GNUS listed).
- GATE B, sandbox buy (BUY-06): blocked on Banxa (sandbox 2026-09-30: 159 coins, 32 fiats, GNUS not listed). Neither passed nor failed.
- Platform walks, permission prompts, light/dark card review, key rotation and `BANXA_API_KEY` secret: pending human.

## Deviations from Plan
- [Rule 1] The new header button duplicates "Buy GNUS" on the Transactions empty state, so `test/dashboard/buy_orders_filter_test.dart` tapped an ambiguous finder; it now scopes the tap to the empty state. Same route and origin.
- Home's Buy GNUS lived in `coins_screen.dart` labelled MARKETS; changed to HOME as planned. Wallet info already used HOME.

## Self-Check: PASSED
Both code commits and the test file exist; commit messages carry no trailer; STATE.md and ROADMAP.md untouched; no flutter_tester left.
