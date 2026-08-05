---
phase: quick-260731-ti5
plan: 01
subsystem: banxa
status: complete
tags: [banxa, layout, intrinsic-height, scrolling, rail]
requires:
  - lib/components/cards/gw_card.dart
  - lib/components/cards/gw_kicker.dart
  - lib/banxa/banxa_helpers/order_transaction_mapping.dart
  - lib/tokens/token_info_screen.dart
provides:
  - "_ZeroIntrinsicHeight: a rail whose height is derived from the card beside it"
  - "_OrderRows: the rail's rows as a lazy ListView.separated"
affects:
  - lib/screens/banxa_buy_screen.dart
  - test/banxa/orders_header_track_test.dart
tech-stack:
  added: []
  patterns:
    - "IntrinsicHeight + Row(stretch) + a zero-intrinsic proxy = child B takes child A's height, one-directionally"
    - "BoxConstraints.enforce as the reason a fixed SizedBox height needs no conditional"
key-files:
  created:
    - test/banxa/orders_rail_bounds_test.dart
    - .planning/todos/pending/2026-07-31-banxa-fetchallorders-fetches-only-the-first-100.md
  modified:
    - lib/screens/banxa_buy_screen.dart
    - test/banxa/orders_header_track_test.dart
    - test/banxa/order_rail_row_test.dart
    - .planning/todos/pending/2026-07-31-banxa-orders-never-enter-the-transaction-store.md
    - .planning/handoffs/HANDOFF-2026-07-31.md
decisions:
  - "The rail's height is derived from the form card via IntrinsicHeight + a zero-intrinsic proxy, so the relationship is one-directional by construction rather than by convention."
  - "_boundedSlotHeight (220) is kept in both layouts and left unconditional: BoxConstraints.enforce clamps it away under the derived height."
  - "No ClipRRect: GWCard's 17px effective inset already clears radiusLg (15)."
  - "The three header-branch tests re-derived their detector from the kicker rather than being loosened."
metrics:
  duration: ~1h
  completed: 2026-07-31
  tests_added: 10
  tests_total: 978
---

# Quick task 260731-ti5: the Your orders rail drops View all and is bounded by the form card Summary

The Buy GNUS "Your orders" rail has no `View all`, no four-row cap, and no
height of its own. In the two-column layout it measures exactly as tall as the
form card beside it and scrolls its whole in-memory list inside that box; in
the stacked layout, where there is no card beside it to measure, it shrink
wraps and the page's own scroll carries the rows.

## The numbers this task was asked to produce

**The derived height, measured at a 1600x1000 surface with 40 seeded orders:**

| | measured |
|---|---|
| form card rendered height | **820.0px** |
| rail card rendered height | **820.0px** |
| form card height with 1 order instead of 40 | **820.0px** (unchanged) |

The form card measures 820.0px at every window width probed, from 400px to
1600px, with 1 order in the rail and with 40. That is the one-directionality
claim as a number: the rail does not move it.

**The re-measured `_inlineTrackMinWidth`, and whether 1536 flipped:**

| term | before (with the link) | after |
|---|---|---|
| `YOUR ORDERS` kicker | 148.5px | 148.5px |
| minimum gap | 16 | 16 |
| `GWControlTrack` | 444.0px | 444.0px |
| `space6` gap + `VIEW ALL` link | 12 + 113.8px | gone |
| **budget** | **734.3px** | **608.5px** |
| **constant** | 736 | **610** |

I measured this myself with the link term removed from the MEASUREMENT test
rather than taking the plan's figure, as instructed. My number came out at
608.5, which is the same as the planner's arithmetic - so there is nothing to
disagree with, but it is now a measurement rather than a sum.

**Yes, the 1536px window flipped from own-row to INLINE.** That test's
assertion is now the inverse of what it was, renamed accordingly. Crossovers,
every one pumped rather than derived:

| window | rail card inner width | branch |
|---|---|---|
| 400 | 344 | own row |
| 667 | 609 | own row |
| **668** | **610** | **inline** (single column) |
| 1048 (two-column minimum) | 470 | own row |
| 1327 | 609.5 | own row |
| **1328** | **610** | **inline** (two column) |
| 1536 | 714 | inline (this is the one that flipped) |
| 1560 and up (xxl cap) | 726 | inline |

**A correction to the arithmetic everyone including the plan was using.** A
`GWCard`'s inner content width is its outer width minus **34**, not minus 32.
`space8` (16) of padding each side, plus one pixel each side because
`Container` adds `decoration.padding` and `Border.all(width: 1).dimensions` is
`EdgeInsets.all(1)`. Two pixels, and they decide the branch within 1px of the
crossover - at window 1324 the card is 610px wide by the minus-32 arithmetic
and renders its own row, because the real inner width is 608. The old comment's
"tops out at 728px at the xxl cap" was 726. This is recorded in the constant's
comment because the next person to move that threshold will do the same sum.

Incidentally it is also why no `ClipRRect` is needed around the scroll
viewport: the inset is 17px against a `radiusLg` of 15px, asserted in the new
test file rather than asserted in prose.

## The gates, run not assumed

| gate | result |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | **978 passed**, 0 failed (baseline 968, +10 new) |
| `bash tool/check_brace_style.sh` | exit 0, no output |
| `bash tool/check_raw_colors.sh` | exit 0, no output |
| `dart format` | 3 files formatted, applied |

The 968 baseline was run on this tree before any edit, not quoted from the
plan. The tool scripts are not executable in this checkout (`permission
denied`, exit 126 when invoked directly), so they were run through `bash`.

## What changed

**Task 1 - `View all` deleted, threshold re-derived.**
`lib/screens/banxa_buy_screen.dart` no longer imports `gw_view_all_link.dart`
and renders no link in either header branch. `GWViewAllLink` itself is
untouched and still serves `dashboard_markets.dart:68`.

One thing the plan did not anticipate and it would have been a silent visual
regression: the own-row branch's `Column` used `CrossAxisAlignment.end`, which
was harmless while `GWKicker` had a `trailing` (it then returns a full-width
`Row(spaceBetween)`). With no trailing, `GWKicker` is a bare `Text`, which
shrink-wraps and gets shoved to the RIGHT edge under `end`. Changed to
`stretch`: the kicker fills the row and renders left as it always did, and the
track's own `Align(centerRight)` still pushes the chips right, which is exactly
what the `Row`'s `spaceBetween` was doing. Byte-identical geometry, verified by
the header tests still passing at 400/1048px.

**Task 2 - the derivation.** The `ordersRail` local moved inside the page's
`LayoutBuilder` so one `wide` boolean feeds both the layout choice and the
rail's new `bounded` flag; the two cannot disagree. The wide branch is
`IntrinsicHeight` wrapping the `Row`, `crossAxisAlignment.stretch` instead of
`start`, with the rail behind `_ZeroIntrinsicHeight` - a 6-line `RenderProxyBox`
that answers 0 to the intrinsic-height query without forwarding it. That single
widget does two jobs: it keeps the rail's `ListView` (and its `LayoutBuilder`)
from being asked a question a viewport throws on, and it makes
`IntrinsicHeight`'s MAX unconditionally the form card's own height, which is
what makes the relationship one-directional.

`visible.take(4)` is gone. `_rows()` (a helper method returning widgets, which
`AGENTS.md` forbids anyway) is replaced by an `_OrderRows` StatelessWidget
rendering one `ListView.separated` - scrolling when bounded, `shrinkWrap` +
`NeverScrollableScrollPhysics` when not. `separated` gives the
no-divider-after-the-last behaviour that the manual index check was doing.

Nothing under `lib/banxa/banxa_order/` or `banxa_api_services.dart` changed:
`git diff --stat` on both is empty. No `loadMore`, no scroll listener.

**Task 3 - the proof.** `test/banxa/orders_rail_bounds_test.dart`, 10 tests in
6 groups, pumping the real public `BanxaBuyScreen` through `SeededOrdersCubit`.
Every height claim is `tester.getRect` against `tester.getRect`, never against
a constant. The 40-order fixture stayed local to that file rather than going
into `fixtures.dart` - one consumer, `AGENTS.md` Rule of Three.

One detail worth carrying forward: the row finder matches
`formatTxAmount(order.cryptoAmount)`, not the raw string. A seeded amount with
a trailing zero (`0.0110`) renders as `0.011` and the raw-string finder would
have silently found nothing, which is a test that passes by not looking.

## The three tests whose branch detector was deleted

`orders_header_track_test.dart` detected which header branch had rendered by
comparing the track's vertical centre against the `View all` link's, at
`:243`, `:258` and `:275`, and the MEASUREMENT test read the link's width at
`:338`. All four lost their reference.

The detector was **re-derived, not loosened**. The new reference is the kicker
text `YOUR ORDERS`, which both branches still render: inline puts the track and
the kicker in one `Row(spaceBetween)` so their centres agree (both 197.0 at a
1536px window); own-row stacks them in a `Column` so they cannot (186.0 against
231.0 at 1048px). Each of the three assertions still fails under the other
branch - none was rewritten into something both branches satisfy. One
`headerIsInline(tester)` helper carries the derivation once, so the three tests
read as the three distinct claims they are.

Of the two tests asserting the own-row branch, the 1048px one held and the
1536px one flipped to inline, as the re-measurement predicted. It is renamed to
what it now claims.

## Deviations from plan

**1. [Rule 1 - Bug] The own-row kicker would have jumped to the right edge.**
Found during Task 1. `CrossAxisAlignment.end` on the own-row `Column` was
load-bearing only while `GWKicker` returned a full-width `Row`; with the
trailing gone it right-aligns a bare `Text`. Changed to `stretch`. Not in the
plan, which described only the deletion.

**2. [Rule 1 - Bug] The card-inset arithmetic was 2px wrong, in the plan and in
the comment it was correcting.** Found while probing the crossover: at window
1324 the minus-32 arithmetic says the card is exactly at the 610 threshold and
should go inline, and it does not. `Container` adds the 1px border's dimensions
to its padding. All four documents that stated the old sum (the constant's
comment, the header test's comment block, the HANDOFF entry, and this summary)
now state minus-34 with the measured crossovers rather than derived ones.

**3. [Rule 2 - Correctness] A stale comment in a test outside the plan's file
list.** `order_rail_row_test.dart:110` justified the absence of day headers
with "the rail renders at most four rows", which this task made false. Comment
corrected in place; no assertion touched, and the file still passes unchanged
otherwise.

**4. `test/banxa/fixtures.dart` was listed in the plan's `files_modified` and
was NOT modified.** The 40-order builder has one consumer, so it stayed local
to the new test file. Rule of Three.

## Deferred, filed, not fixed

`.planning/todos/pending/2026-07-31-banxa-fetchallorders-fetches-only-the-first-100.md`
records that `BanxaApiService.fetchAllOrders` (`banxa_api_services.dart:247-276`)
issues one request with `limit: 100`, no cursor and no loop, while
`OrdersResponse` carries the `total` and `pageTotal` that would tell it there is
more. A user with 300 orders sees 100 and is told nothing. That was 96 rows past
anything visible while the rail showed four behind a `View all`; it is now the
bottom of a list the user can actually scroll to. Locked decision: not fixed
here.

`.planning/todos/pending/2026-07-31-banxa-orders-never-enter-the-transaction-store.md`
is corrected rather than closed. Its blocker is dissolved (there is no link left
to re-target, so the re-target was NOT implemented), and its "orphaning, as a
consequence (not yet true today)" section is now true today: `/buy/orders` has
no in-app entry point left. Its two options - re-home an entry point, or delete
the screen with its route and tests - are live questions for Jakub. Neither was
taken as a side effect. The preselection mechanism and the `transactionHash`
research stay in the file; this deletion does not answer whether a fiat purchase
belongs in the wallet's transaction history.

`.planning/handoffs/HANDOFF-2026-07-31.md` open decision 2 (the 444px track and
its inline budget) is struck through and closed, with the new numbers.

Pre-existing and untouched, drained rather than asserted in the two 400px tests:
`GWEmptyState`'s message wraps taller than its 220px slot at phone width. Logged
by 260731-jx5, out of scope here.

## Nothing was committed and nothing was pushed

`git log --oneline -1` reads `2a4ef884 wip: session paused - 19/23 phases, no
active phase`, the same commit as when this task started. No `git add`, no
`git commit`, no `git push`, no branch, no stash. Every change is unstaged in
the working tree on `redesign/jakub-260730` for Jakub to review and open the PR
into `ui-redesign-port` himself.

## Self-Check: PASSED

- `lib/screens/banxa_buy_screen.dart` - FOUND, modified
- `test/banxa/orders_rail_bounds_test.dart` - FOUND, created, 10/10 pass
- `test/banxa/orders_header_track_test.dart` - FOUND, modified, 9/9 pass
- `test/banxa/order_rail_row_test.dart` - FOUND, modified, 9/9 pass
- `.planning/todos/pending/2026-07-31-banxa-fetchallorders-fetches-only-the-first-100.md` - FOUND, created
- `.planning/todos/pending/2026-07-31-banxa-orders-never-enter-the-transaction-store.md` - FOUND, corrected
- `.planning/handoffs/HANDOFF-2026-07-31.md` - FOUND, corrected
- commits: NONE, by instruction. HEAD unchanged at `2a4ef884`.
