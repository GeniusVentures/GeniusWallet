# Deferred items - 07-09

Out-of-scope discoveries found while executing 07-09-PLAN.md. Not fixed here per the
scope-boundary rule (only auto-fix issues directly caused by this task's own changes) and per
07-09-PLAN.md's explicit file constraints (`lib/chart/crypto_live_chart.dart` and `CoinConvertCard`
are both off-limits to this plan).

## Narrow-width overflow, surfaced by new test coverage at 360px

`test/tokens/coin_page_range_tile_test.dart`'s new "no rail row leaves a hole at its right edge"
test pumps the full `TokenInfoScreen` at five widths, including 360px - a width no prior test in
this file exercised (the file's only previous width was a fixed 1400px desktop viewport). At 360px
two pre-existing, unrelated `RenderFlex` overflows surface:

1. `CoinConvertCard`'s "Token price" row (`token_info_screen.dart` inside `CoinConvertCardState`,
   the read-only price row before Task 2/3 - untouched by this plan) overflows ~23px on the right.
2. `CryptoLiveChart`'s own internal no-network fallback (`GWEmptyState`, reached because widget
   tests have no real network) overflows ~14px on the bottom.

Neither is inside a file or widget this plan modified or is permitted to modify. The new test
drains these via `tester.takeException()` in a loop so it only fails on the rail's own layout,
which is what it is scoped to check.

**Next step for whoever picks this up:** both rows likely need `Flexible`/ellipsis handling for
narrow (sub-400px) windows. Neither was walked at that width before.
