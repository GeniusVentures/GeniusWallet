---
phase: quick-260731-jx5
plan: 01
subsystem: banxa-buy-screen
tags: [banxa, buy, orders, filters, control-track, gw-control-track, sketch-169]
status: complete
dependency-graph:
  requires: [GWTimeframeSegment, TransactionsSlimView._TransactionFilterBar]
  provides: [GWControlTrack, "Your orders header (scheme B)"]
  affects: [lib/components/gw_timeframe_segment.dart, lib/dashboard/home/widgets/transactions_slim_view.dart]
tech-stack:
  added: []
  patterns: ["shared control-track container (GWControlTrack)", "Align+SingleChildScrollView width-safety wrap"]
key-files:
  created:
    - lib/components/gw_control_track.dart
    - test/banxa/orders_header_track_test.dart
    - .planning/todos/pending/2026-07-31-banxa-orders-never-enter-the-transaction-store.md
    - .planning/quick/260731-jx5-buy-gnus-your-orders-header-sketch-169-s/deferred-items.md
  modified:
    - lib/components/gw_timeframe_segment.dart
    - lib/dashboard/home/widgets/transactions_slim_view.dart
    - lib/screens/banxa_buy_screen.dart
decisions:
  - "Promoted GWControlTrack (container only, no chip/selection API) and converged all three existing tracks onto it, not just the new one."
  - "Did NOT re-target View all to Transactions — Banxa orders never become Transaction objects in a normal build, so the re-target would land on an always-empty filtered list."
  - "_inlineTrackMinWidth set to the MEASURED real width (736), not the plan's ~540 estimate — real Flutter-rendered chip widths came in ~34% wider than the sketch's own numbers."
  - "Wrapped the orders track in Align+SingleChildScrollView(horizontal) because the labelled track (~444px) does not fit even the phone-width card (344px) on its own row, which the plan did not anticipate."
metrics:
  duration: "~2.5h"
  completed: 2026-07-31
---

# Quick task 260731-jx5: Buy GNUS "Your orders" header (sketch 169 scheme B) Summary

Rebuilt the Buy GNUS "Your orders" panel header as sketch 169 scheme B on a newly-shared
`GWControlTrack` container, adding the missing Issues chip and removing the selected-chip
gradient that collided with `Get quote`'s own gradient fill.

## What Shipped

**Task 1 — `GWControlTrack` extraction.** New `lib/components/gw_control_track.dart`: a
`StatelessWidget` owning exactly the five `CONVENTIONS.md` "Control track" values
(`surfaceSunken` fill, `borderSubtle` hairline, `radiusPill`, `EdgeInsets.all(3)` track padding,
`SizedBox(width: 2)` inter-child gap) and nothing else — no chip type, no selected-index API.
`GWTimeframeSegment` and `_TransactionFilterBar` (`transactions_slim_view.dart`) were migrated
onto it as their outer container, converging what `CONVENTIONS.md` already documented as a
shared recipe into one file that actually enforces it.

**Task 2 — the header rebuild.** `banxa_buy_screen.dart`'s `_OrdersRail` header: `_CountChip`
(raised `surfaceMenu` pill, `brandCta` gradient on selection) deleted outright; replaced with
`_OrderToneChip` (label + tabular count, `GWHoverable` "lift chip" hover, **no gradient in any
state** — selected is a flat `gw.surfaceMenu` fill) built on `GWControlTrack`, four chips in
fixed order: All, Pending, Done, **Issues**. Issues is wired to
`statusCounts[OrderStatusTone.error]`, which nothing rendered before — a declined or expired
order was previously invisible under every filter except All. `View all` is now `GWViewAllLink`
(matching the Markets panel), destination unchanged (`/buy/orders`) — see the finding below.

**Task 3 — measured, not estimated.** `test/banxa/orders_header_track_test.dart` (9 tests):
four-chip rendering/counts, the Issues regression guard (selecting it keeps a declined order and
drops a completed one — assertion is on the filtered list, not just the count), counts
reconciliation (Pending + Done + Issues + neutral == All), tap-active-clears-to-All, three
real-window no-overflow checks (1024px, 1048px, 1536px), a phone-width (400px) header-only
no-overflow check, and a measurement test.

**Task 4 — the blocker todo**, `2026-07-31-banxa-orders-never-enter-the-transaction-store.md`:
records why `View all` was NOT re-targeted to Transactions, the ready-to-use preselection
mechanism, and the (corrected) product question about `transactionHash`.

## The measurement, and what it changed

The plan's own pre-execution estimate (kicker ~92px, track ~332px, link ~84px, threshold ~540)
undershot reality substantially once real widget tests measured it:

**Real measured widths** (`test/banxa/orders_header_track_test.dart`'s MEASUREMENT test, 4
seeded orders spanning all four tones): kicker `~148.5px`, track `~444.0px`, link `~113.8px`.
Required inline width = `148.5 + 16 (gap) + 444.0 + 12 (space6 gap) + 113.8` = **~734.3px**.
`_inlineTrackMinWidth` is set to **736** (a few px of headroom over the measured sum), not the
plan's 540.

**Where it flips — and a real surprise this measurement uncovered.** `constraints.maxWidth`
inside the header's `LayoutBuilder` is the RAIL CARD's inner content width, not the window width,
and it does **not** move monotonically with window width in this app: the page's
`ConstrainedBox(maxWidth: GeniusBreakpoints.xxl)` sits *outside* the two-column `Row`, so widening
the window past `GeniusBreakpoints.large` (1024) actually **shrinks** the rail card (full-width
single column -> half-width two column). Measured breakpoints:

- Window `< ~792px`: single column, card too narrow — **own row** (fallback).
- `~792px <= window < ~1048px`: still single column (the two-column check is `window - 24 >=
  1024`, i.e. window `>= 1048`, not `1024`), card is full-width and roomy — **inline**.
- Window `>= ~1048px`: two columns; the rail card's inner width ranges 460-728px depending on
  window, which is **below** the ~734px the inline row needs at every value the app can reach —
  **own row, permanently**, for every two-column width, including the widest possible (1536px+
  cap, 728px inner).

**So the sketch's "inline on the kicker row" amendment is honoured only in a narrow single-column
band (roughly 800-1047px window), and never in the two-column layout — not even at the 1536px
cap.** This is a real, measured finding, not a bug in this plan's code: the `LayoutBuilder`
branch is kept (correct future-proofing — a looser page cap or narrower chips would make it
reachable), but as this app is built today, a 1536px-wide window and a 1024px-wide window both
show the track on its OWN row below the kicker (scheme B exactly as originally approved in the
sketch), not inline with `View all`.

**A second, unplanned-for overflow.** The labelled track itself measures ~444px — the sketch's
own estimate was ~332px, a 34% undershoot — and does not fit even the phone-width card's 344px
inner content on its own row. To avoid hiding a chip or clipping (both forbidden by this plan's
own success criteria), the track is wrapped in `Align(alignment: centerRight, child:
SingleChildScrollView(scrollDirection: horizontal, child: GWControlTrack(...)))`. This hugs the
track's own width (staying right-aligned) whenever it fits, and clamps to the available width —
scrollable, not overflowing, not hiding any status — at the one width (phone) where it does not.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `_TransactionFilterBar`'s `GWControlTrack` migration widened the bar by 4px, breaking a pixel-pinned test**
- **Found during:** full-suite verification after Task 1/2.
- **Issue:** `GWControlTrack` inserts its 2px gap between EVERY top-level child. The plan's Task
  1 instruction ("pass the chips as plain children; the divider and the overflow trigger... stay
  children of the track") — if followed literally — adds two 2px gaps that the pre-migration
  code never had (between the last chip and the divider, and between the divider and the
  trigger; the divider's own `space2` padding was always the entire separation). This widened the
  bar from 183px to 187px, failing `test/dashboard/transaction_filters_test.dart`'s
  `expect(bar.width, 183)` at six widths/modes.
- **Fix:** passed the pre-existing inner `Row` (chips with their own 2px gaps, then the divider,
  then the trigger) to `GWControlTrack` as a **single** child, preserving byte-identical rendered
  geometry while still routing the outer fill/border/radius/track-padding through the shared
  container.
- **Files modified:** `lib/dashboard/home/widgets/transactions_slim_view.dart`
- **Verification:** `flutter test test/dashboard/transaction_filters_test.dart` — 45/45 passing.

**2. [Rule 1 - Bug] The labelled track overflows the phone-width card on its own row**
- **Found during:** Task 3's phone-width (400px) test.
- **Issue:** the track (~444px) does not fit the phone card's 344px inner content, regardless of
  which header branch (inline/own-row) is active — a case the plan's ~332px sketch estimate did
  not anticipate.
- **Fix:** wrapped the track in `Align` + horizontal `SingleChildScrollView` (see above). No
  chip is ever hidden; it becomes reachable by horizontal scroll at the one width where it does
  not fit outright.
- **Files modified:** `lib/screens/banxa_buy_screen.dart`
- **Verification:** phone-width header test passes; see "Known deferred items" below for two
  SEPARATE, pre-existing, out-of-scope overflow bugs this same width investigation surfaced in
  widgets this plan does not touch.

**3. [Rule 1 - Correction, not a fix] `Order`/`OrderStatus` DO carry a `transactionHash` field**
- **Found during:** writing Task 4's todo.
- **Issue:** the plan's own finding claimed `OrderStatus` "has no on-chain transaction hash."
  Both `OrderStatus` (`banxa_model.dart:136`) and `Order` (`banxa_model.dart:354`) declare a
  nullable `transactionHash`, populated from Banxa's JSON when present.
- **Fix:** corrected the claim in the filed todo rather than propagate it — the real open
  question is narrower (whether every order status Banxa returns eventually carries one, or
  whether declined/cancelled/expired orders — which never settle on-chain — never get one), not
  whether the field exists at all. The underlying product question (should a fiat purchase enter
  on-chain history at all) is unchanged.
- **Files modified:** the todo file itself; no code change.

None of the three required a checkpoint — all were auto-fixable per Rule 1 (broken/incorrect
behavior directly caused by, or discovered while writing, this plan's own changes).

## Known Deferred Items (out of scope, logged not fixed)

Two SEPARATE, pre-existing overflow bugs were surfaced by Task 3's phone-width test coverage —
neither is caused by this plan (Task 2/3 only touch the header block) and neither is fixed here,
per the executor's scope boundary. Full detail in
`.planning/quick/260731-jx5-buy-gnus-your-orders-header-sketch-169-s/deferred-items.md`:

1. `_OrderRailRow`'s status+date `Row` overflows ~16-102px at a ~400px window with real order
   data present (never previously exercised at this width).
2. `GWEmptyState`'s fixed `_boundedSlotHeight` (220px) slot overflows vertically at ~400px and
   ~1048px window when there are zero (or zero matching) orders.

## Concurrent-session note

A parallel quick task (260731-kc5, Compute panel balance-unit track) was editing
`lib/components/gw_control_track.dart`'s doc comment and `lib/dashboard/compute/compute_panel.dart`
concurrently with this task. Per this task's constraint, `lib/dashboard/compute/*` and
`lib/components/wallet_overview.dart` were left untouched. The only overlap was a shared doc
comment in `gw_control_track.dart` (listing that task's `_UnitTrack` as a fourth consumer) — the
widget's actual code was unchanged by either session. The full-suite run at completion showed
exactly one failing test, `compute_balance_unit_track_test.dart`, entirely inside that other
task's in-flight scope — not touched or investigated here.

## Verification

- `flutter analyze` (whole project): **0 issues**.
- `tool/check_brace_style.sh`: **PASS**.
- `tool/check_raw_colors.sh`: **PASS**.
- `flutter test` (whole project): **923/924 passing** — the one failure
  (`compute_balance_unit_track_test.dart`) is inside the explicitly out-of-scope
  `lib/dashboard/compute/*` parallel task, not this plan's files.
- `flutter test test/banxa/`: **104/104 passing** (includes the 9 new tests in
  `orders_header_track_test.dart`).
- `flutter test test/dashboard/transaction_filters_test.dart`: **45/45 passing** (regression from
  Task 1's `GWControlTrack` migration, found and fixed — see Deviations #1).

## The walk (for Jakub)

**What was built:** the Buy GNUS "Your orders" header rebuilt as sketch 169 scheme B on the
shared `GWControlTrack` — four labelled chips (All / Pending / Done / **Issues**), no gradient on
the selected chip, `View all` as the editorial `GWViewAllLink` (destination unchanged). All three
control tracks in the app (chart timeframe, transactions filter, Buy GNUS orders) now share one
container file.

1. `flutter run -d macos --dart-define=GW_DEV_TOOLS=true`, open Buy GNUS.
2. **On a wide window (1536px or any two-column width) and on a mid-size single-column window
   (900-1024px): the track sits on its OWN ROW below "Your orders", not inline with View all —
   at every real width this app can produce in two-column mode.** The one place it DOES sit
   inline with View all is a single-column window roughly 800-1047px wide. This is the header
   working exactly as measured, not a bug: the labelled track (~444px) plus the kicker and the
   link together need ~734px, which the rail card's two-column width (460-728px) never reaches at
   any window size.
3. Narrow the window toward phone width: the track becomes horizontally scrollable rather than
   clipping or overflowing (a fix beyond the plan's own estimate — the track is wider in real
   Flutter rendering than the sketch predicted).
4. Compare the track against the chart's timeframe segment and the dashboard's transactions
   filter, side by side, in both themes: same sunken fill, same hairline, same pill, same rhythm.
5. Compare the selected chip against `Get quote`: the chip no longer carries the gradient, so it
   should read as clearly less important than the CTA — confirm that reads as a gain.
6. Tap Issues: declined/expired orders should appear. Tap Issues again: back to All, full list
   restored — same clear-to-All behaviour as the dashboard transactions filter.
7. Hover an unselected chip: it should lift onto `surfaceElevated`, exactly like the chart's
   timeframe tabs.
8. `View all` still opens `/buy/orders`, not Transactions — the reason (and the product question
   that needs your call) is in
   `.planning/todos/pending/2026-07-31-banxa-orders-never-enter-the-transaction-store.md`.

**Not committed and not pushed** — the tree is left dirty per your standing rule, for local
review and your own PR into `ui-redesign-port`.

## Self-Check: PASSED

Files:
- FOUND: lib/components/gw_control_track.dart
- FOUND: test/banxa/orders_header_track_test.dart
- FOUND: .planning/todos/pending/2026-07-31-banxa-orders-never-enter-the-transaction-store.md
- FOUND: .planning/quick/260731-jx5-buy-gnus-your-orders-header-sketch-169-s/deferred-items.md
- FOUND: lib/screens/banxa_buy_screen.dart (modified)
- FOUND: lib/components/gw_timeframe_segment.dart (modified)
- FOUND: lib/dashboard/home/widgets/transactions_slim_view.dart (modified)

No commits were made (per this task's standing rule) — there are no commit hashes to verify.
