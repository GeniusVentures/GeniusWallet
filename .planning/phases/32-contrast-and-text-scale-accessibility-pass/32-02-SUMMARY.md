---
phase: 32-contrast-and-text-scale-accessibility-pass
plan: 02
status: complete
requirements: []
key-files:
  created: [test/theme/status_text_contrast_test.dart]
  modified: [lib/components/coins/view/coin_card_row.dart, lib/chart/crypto_simple_chart.dart, lib/chart/crypto_live_chart.dart, lib/dashboard/chart/markets_table.dart, lib/dashboard/chart/markets_cards.dart, lib/dashboard/chart/markets_hero_card.dart, lib/tokens/token_info_screen.dart, lib/components/coins/assets_total_band.dart, lib/dashboard/news/view/crypto_news_screen.dart]
actuals: { tokens: 4236, tasks: 3, commits: 3 }
---

# Phase 32 Plan 02: price-change and timestamp contrast

Nine price-change/timestamp call sites (dashboard, markets, token detail, news) now paint
their label in `statusSuccessText`/`statusErrorText`; every wash, sparkline and chart line
stayed on the raw `statusSuccess`/`statusError` token. New `status_text_contrast_test.dart`
pins both partners at 4.5:1 across 4 plain surfaces and 8 wash backdrops, both modes.

## Backdrop check (per plan instruction)

Traced every edited pill's ancestor decoration: `coin_card_row`, both chart files,
`markets_table`, `markets_cards`, `markets_hero_card` and `token_info_screen` all sit on
`GWDecorations.surface()`/`GWCard`'s default (`surfaceElevated`), never `surfaceMenu`. The
dark-mode shortfall RESEARCH.md flagged (error text on a 0.15 wash over `surfaceMenu`,
4.48:1) does not occur on any of this plan's nine surfaces — nothing to record as a defect.

## Baseline vs. after (measured)

`flutter test test/theme/`: 118/118 pass. `flutter analyze`: "No issues found!", exit 0.
`dart format --set-exit-if-changed` on all 10 touched files: exit 0. `check_brace_style.sh`:
exit 0. New test file is LF (`git ls-files --eol`).

## Deviations

None — plan executed exactly as written.

## Self-Check: PASSED

Commits 3d17236b, 7e94d91a, f77f4795 verified present in `git log`; all 10
created/modified files verified present on disk.
