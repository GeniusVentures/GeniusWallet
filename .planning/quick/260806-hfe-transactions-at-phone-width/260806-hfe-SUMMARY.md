# Quick Task 260806-hfe: Transactions at phone width

**Completed:** 2026-08-06 · **Branch:** `gsd/phase-25-transactions-mobile`

Mobile pass over `/transactions`, plus the frame values it shares with every other page header.
Desktop is unchanged throughout.

## The gating rule — read this before editing any of it

```dart
final bool compact = !GeniusBreakpoints.useDesktopLayout(context);
```

**Read from the WINDOW, never from the row's own constraints.** `TransactionRow` already has a
`wide` bool (row width ≥ 720) and it is the wrong signal here: the dashboard's transactions panel
is ~376px wide while sitting on a 2560px desktop, so gating on row width silently restyles the
desktop dashboard. That leak happened during this task and was caught by Braian, not by a test.

A bool satisfies the freeze rule (`37639d5`) — it bans a dimension derived *continuously* from
constraints, not a breakpoint.

## What changed

**Shared frame values** — `GeniusBreakpoints.pageTitleGap()` / `pageGutter()`, applied to all seven
pages that mount a `GWPageHeader` (Transactions, Markets, News, Swap, Feedback, Token detail,
Banxa). One place, because their whole job is that the pages agree.

| | phone | desktop |
|---|---|---|
| navbar → title | 24 | 64 |
| page gutter | 6 | 12 |
| card padding (`DashboardScrollContainer`, 11 call sites) | 6 | 12 |

The gutter never reaches 0 — content on the window bezel is the defect the 06-01 walk found in
`wallet_creation_screen.dart`.

**Duplicate title** — `_page`'s narrow branch used to `return _panel(...)`, which put **two**
"Transactions" on a phone (the route supplies `GWPageHeader`; `_panel` carries its own
`GWSectionTitle`). It now has its own presentation: filter bar, then the list on a
`DashboardScrollContainer` card. `_panel` is untouched — the dashboard still needs its title.

**Touch targets** — `_TransactionFilterBar` takes a `chipSize`; the phone page passes **44**, the
panel keeps **32**. This only became affordable *because* of the duplicate-title fix: the earlier
audit ruled 44 out against ~11px of shared-row headroom, and moving the bar onto its own row
created the width. Pinned at **320**, the stress case. **44pt iOS is met; 48dp Android is not.**

**Row density** — time column dropped and the icon leads; padding 12/8 → 6/4; gaps 12 → 6; icon
40 → 28; title 14, subtitle/chip/value-line 11, amount 13. The name+tag block takes
`_narrowNameFlex` (2) parts against the amount's 1, where it was 1:1.

**Background** — `GWMeshBackground(intensity: 0.45, dimAlpha: 60)`. Both set deliberately:
intensity alone cannot darken the field (it scales blobs and dim together). `baseColor` left null
so it resolves to `gw.surfaceBase` and stays appearance-aware.

**End of list** — `endOfTransactionsLabel`. Not the footer count Phase 12 removed: no number, so
nothing can drift against the filter counts.

## Phase 15's overflow closes with no fix

15-05 recorded 93px of overflow on `_panel`'s title row at 320px and **doubted its own number**
(harness fallback font ≈216px for `Transactions` vs real Inter's ≈110). Measured on the running
build at 320/360/390/414: **no overflow at any width.** `deferred-items.md` item 1 closes as the
harness artifact it was suspected to be. No defect was manufactured to justify the work.

## Costs, accepted

- **The mesh never settles.** Its controller `..repeat()`s forever, so any widget test rendering
  this page below 768 must use `pump()`, not `pumpAndSettle()` — it times out rather than failing
  an assertion. It also repaints continuously on the platform this targets; the `RepaintBoundary`
  keeps it off the scrolling list.
- **The minute is gone from the phone row.** The day header names the day and the receipt drawer
  keeps the full timestamp.
- **Long amounts truncate sooner** — the trade `_narrowNameFlex` buys.
- **The desktop dashboard panel** shares `TransactionRow`'s narrow branch, so it still truncates
  its tags. Out of scope here, but real, and it is a one-line change if wanted.

## Not verified

- **Real mobile.** Width branch only — see the accepted limitation in CONTEXT.
- Light mode; the SGNUS branch of this page (pre-existing gap, documented in
  `transactions_page_frame_test.dart`'s header).

## Verification

`flutter analyze lib/ test/` clean · `tool/check_brace_style.sh` 0 · `tool/check_raw_colors.sh`
clean · `flutter test` **1002/1002** (baseline 1000).

Two tests added to `transactions_page_frame_test.dart`, both at phone width:

- never-transacted empty state — renders, filter bar hidden entirely (15-03's rule), no duplicate
  `GWSectionTitle`. Passed first run: the branch was correct, just unwalked.
- the 44px chip, measured at 320 through `GWControlTrack` (public) rather than the private
  `_FilterChip`. The track is **52** tall: 44 + 3px padding each side + a 1px hairline each side.

Two existing assertions re-pinned rather than relaxed: the narrow-gutter value (12 → 6) and the
pump strategy.

## Files

`lib/utils/breakpoints.dart` · `lib/dashboard/transactions/transactions_screen.dart` ·
`lib/dashboard/home/widgets/transactions_slim_view.dart` ·
`lib/dashboard/home/widgets/transaction_displays.dart` ·
`lib/dashboard/home/view/dashboard_screen.dart` · `lib/dashboard/chart/markets_screen.dart` ·
`lib/dashboard/news/view/crypto_news_screen.dart` · `lib/squid_router/swap_screen.dart` ·
`lib/logs/submit_logs_screen.dart` · `lib/tokens/token_info_screen.dart` ·
`lib/screens/banxa_buy_screen.dart` · `test/dashboard/transactions_page_frame_test.dart`
