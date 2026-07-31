# Deferred items — 260731-jx5

Out-of-scope findings surfaced while writing `test/banxa/orders_header_track_test.dart`'s
phone-width (400px) coverage. Neither is caused by this plan's changes (Task 2/3 only touch
the "Your orders" header — the `GWKicker`/`GWControlTrack`/`GWViewAllLink` block and
`_inlineTrackMinWidth`'s `LayoutBuilder`). Both are pre-existing, dormant bugs in
`banxa_buy_screen.dart` widgets this plan does not modify, never previously exercised because
no prior test pumped real seeded order data or the empty-orders state at a narrow (~400px)
window.

## 1. `_OrderRailRow`'s status+date `Row` overflows at ~400px window

With real order data present, `_OrderRailRow`'s `Row(mainAxisSize: MainAxisSize.min,
children: [OrderStatusPill(status: order.status), SizedBox(width: space4), GWKicker(dateLabel,
dense: true)])` (`banxa_buy_screen.dart`, inside `_OrderRailRow.build`) overflows by 16-102px
depending on status-string length, once the rail card's available width narrows to ~302px
(observed at a 400px window, single-column stacked layout, `EdgeInsets.symmetric(horizontal:
space4)` row padding on top of the card's own `space8` padding).

Fix shape (not applied here): wrap the pill+date `Row` in a `Flexible`/`Expanded` with
`TextOverflow.ellipsis` on the date `GWKicker`, or drop to a narrower date format
(`'MMM d'` instead of `'MMM dd, HH:mm'`) below a measured width threshold, matching the
pattern this plan's own header uses for its own responsive split.

## 2. `GWEmptyState`'s fixed `_boundedSlotHeight` (220px) overflows at ~400px / ~1048px window

With zero orders (or zero orders matching the active filter), `_OrdersRail` renders
`SizedBox(height: _boundedSlotHeight, child: GWEmptyState(...))`. At narrow widths the
title/message text wraps onto more lines than the fixed 220px slot allows, overflowing the
`Column` inside `GWEmptyState` by ~20-44px (observed at 400px and, surprisingly, also at
1048px — the exact window width where the page's two-column layout engages and the rail card
suddenly narrows, per this plan's own real-breakpoint finding in
`orders_header_track_test.dart`).

Fix shape (not applied here): either let `_boundedSlotHeight` grow with content
(`ConstrainedBox(minHeight: ...)` instead of a fixed `SizedBox`), or confirm `GWEmptyState`'s
own documented "compact tier below a 192px slot" (`_OrdersRail`'s existing comment,
`09-OUTSTANDING.md`) actually engages before 220px stops being enough at these widths — the
existing comment implies it should never need more than its compact tier inside a 220px slot,
which this finding contradicts at these two specific windows.

## Why these are deferred, not fixed

Both live in `banxa_buy_screen.dart`, a file this plan does modify — but in widgets
(`_OrderRailRow`, the empty-state branch of `_OrdersRail`) this plan's Task 2/3 do not touch.
Per the executor's scope boundary ("only auto-fix issues directly caused by the current
task's changes"), these are out of scope for 260731-jx5 and are recorded here rather than
fixed, so the header rebuild's own diff stays legible and reviewable on its own terms.
