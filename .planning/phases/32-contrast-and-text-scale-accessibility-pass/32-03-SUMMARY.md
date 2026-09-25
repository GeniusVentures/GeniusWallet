---
phase: 32-contrast-and-text-scale-accessibility-pass
plan: 03
status: complete
requirements: []
key-files:
  created: []
  modified: [lib/screens/pin_screen.dart, lib/components/wallet_information.dart, lib/components/wallets_overview.dart, lib/account/account_drawer.dart, lib/account/sdk_account_manager.dart, lib/components/qr/crypto_address_qr.dart, lib/settings/settings_screen.dart, lib/logs/submit_logs_screen.dart, lib/screens/banxa_buy_screen.dart]
actuals: { tokens: 2116, tasks: 3, commits: 3 }
---

# Phase 32 Plan 03: PIN, wallet, account, receive, settings, logs and Banxa status labels

Nine call sites across the PIN, wallet/account, receive, settings, logs and Banxa screens now
paint their destructive/success/error label (and any icon sitting beside it) in
`statusErrorText`/`statusSuccessText` instead of the fill-tuned `statusError`/`statusSuccess`.
Every swap was a straight token rename at a foreground read; no wash, fill, border, dot or line
was touched.

## Backdrop check

All nine sites sit on a plain surface (drawer/menu/card/screen background), not a wash — matching
RESEARCH.md Item 2's finding that the `*Text` partners clear 4.5:1 (5.16-8.31:1) on every plain
surface in the palette, so no per-site tuning was needed.

## Baseline vs. after (measured)

`flutter analyze` on all nine touched files together: "No issues found!", exit 0. `flutter test
test/theme/`: 118/118 pass. `dart format --set-exit-if-changed` on all nine files: exit 0.
`bash tool/check_brace_style.sh` (whole repo): exit 0. Raw `.statusSuccess`/`.statusError` reads
on all nine files: 0. `grep -c "mode-invariant" lib/settings/settings_screen.dart`: 0 (the stale
claim was corrected in the same edit).

## Deviations

None — plan executed exactly as written. The tracer task's `<verify>` was automated-only (no
`<human-check>`), so no interim checkpoint was raised; task 2 and 3 proceeded directly per the
plan's fully-autonomous (no `checkpoint:*` task) structure.

## Self-Check: PASSED

Commits 7a489044, 2690d704, 35a829b8 verified present in `git log`; all nine modified files
verified present on disk.
