# Phase 15 — deferred items

Out-of-scope discoveries, logged rather than fixed. Each carries the measurement
that found it so nobody has to rediscover it live.

## 1. The panel's title row overflows below 413px (harness font)

**Found:** 15-05, Task 3, while writing the narrow-gutter test.
**Lives in:** `transactions_slim_view.dart` `_panel` — `GWSectionTitle('Transactions')`
plus the compact `_TransactionFilterBar` on one `Row`. Not touched by 15-05.

Measured through the real `/transactions` screen, non-empty scope, dark:

| content width | 320 | 328 | 336 | 344 | 360 | 380 | 400 | 413 | 419 |
|---|---|---|---|---|---|---|---|---|---|
| RenderFlex overflow | 93 | 85 | 77 | 69 | 53 | 33 | 13 | none | none |

Exactly 1:1 with width, so the row needs **413px** and gets less below that. An
empty scope has no overflow at any of these widths — 15-03's `scoped.isEmpty`
guard drops the bar, and the bar is the whole cost.

**Why it is not a 15-05 fix.** (a) It is in `_panel`, which this plan does not
touch; (b) 15-05 made it 8px *better*, not worse — the old `EdgeInsets.all(16)`
left 328px of content (85px over) against the new 12px gutter's 336 (77px over);
(c) it is very likely a harness-font artifact. The widget-test fallback font
draws roughly one em per character, so `Transactions` costs ~216px here against
real Inter's ~110 — on a device the row should clear 360 with ~30px to spare.
**That last part is arithmetic on the harness measurement, not a device
measurement.** Nobody has put this screen on a 360px window.

**For 15-06:** open `/transactions` at phone width and look at the title row. If
it is fine, this entry closes as a harness artifact. If it is not, the fix is in
`_panel` — most likely wrapping the title row rather than shrinking the bar, and
definitely not `FittedBox`/`AutoSizeText` (freeze rule, `37639d5`).

## 2. Pull-to-refresh no longer arms over the filter rail

**Found:** 15-05, measured on the real screen at 1600x900 with 30 rows.

| drag at | `RefreshProgressIndicator` appears |
|---|---|
| x=900 (the list card) | **yes** |
| x=250 (the rail card) | **no** |

The page gives `RefreshIndicator` two depth-0 scrollables where the panel gave
it one. The list's `ListView` captures the pull as before. The rail's
`SingleChildScrollView` does not, because at any normal page height its content
fits (15-04 measured the rail engaging its scroll only at a **502px** page slot
and below), and a scroll position whose min and max extents are equal refuses
the drag outright — so it emits no notification for the indicator to see.

220px of a 1280px page is dead to the gesture. The plan explicitly says not to
restructure `RefreshIndicator` speculatively, so it was not.

**For 15-06:** decide whether that matters. If it does, the one-line answer is
`AlwaysScrollableScrollPhysics` on the rail's scroll view, which makes it emit
overscroll notifications without changing what it looks like.
