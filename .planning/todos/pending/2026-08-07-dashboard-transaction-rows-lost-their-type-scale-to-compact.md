# Dashboard transaction rows shrank: develop's `compact` overrides scheme C on the home page

**Raised by Jakub, 2026-08-07, on device after the merge:** font size issues and
others in the Transactions section on the HOME PAGE. His instruction: keep our
changes over Braian's, **at least for the home page**.

**Status:** not fixed. Recorded for the evening session. A screenshot is coming
and should be attached here when it arrives.

## What actually happened

`develop`'s 260806-hfe work added a phone density pass to `TransactionRow`.
It is gated on:

```dart
// transaction_displays.dart:308
final bool compact = !GeniusBreakpoints.useDesktopLayout(context);
```

and `useDesktopLayout` reads the **WINDOW**, not the row:

```dart
// breakpoints.dart:18
MediaQuery.sizeOf(context).width > medium && !isMobileApp()
```

So on a phone `compact` is **true everywhere**, including the dashboard panel.
The density pass was designed for the full `/transactions` page and is landing
on the home panel as a side effect.

## Everything it changes on the home page

| Line | What | Our value | What renders now |
| --- | --- | ---: | ---: |
| 449 | row title | `titleMd` 16 | **14** |
| 534 | subtitle paragraph | `bodySm` 13 | **11** |
| 559 | subtitle status tail | `bodySm` 13 | **11** |
| 326 | amount | 16 | **13** |
| 415 | leading identity icon | 40 | **28** |
| 457 | title to subtitle gap | `space2` = 4 | **1** |
| 422 | name block flex | 1 | **2** (`_narrowNameFlex`) |

## Why this is worse than "it looks small"

**Every measurement behind scheme C was taken at 13px and is now wrong.** The
subtitle design was argued from a measured 113.0px line: `Minted` at 48.5, the
ellipsis glyph at 12.3, the decision to separate lead from context by COLOUR
rather than a middle dot because the dot cost ~10px of a line that had none to
spare. At 11px those numbers are all different, so the comments in
`transaction_displays.dart` currently document arithmetic the code no longer
performs. Whatever we do here, those comments must be re-measured or re-stated.

Also: 11px is below the 13px floor `genius_wallet_typography.dart` records as a
**deliberate** raise from 12. That floor was set on purpose and this walks under
it without saying so.

## The trap: a naive revert breaks the /transactions page

`compact` cannot tell the panel from the page, and **neither can `wide`**:

- `wide` is `constraints.maxWidth >= _wideRowThreshold` (line 385). The panel is
  ~376px and the narrow page is ~390px. They are 14px apart, so no width test
  separates them.
- The 44pt filter-bar touch targets that came with develop's work are a real
  accessibility gain on the page and must NOT be reverted with the type scale.

So deleting `compact` fixes the home page and undoes deliberate work on the
page. That is why Jakub scoped it "at least for the home page".

## Recommended fix, to confirm in the evening

**Pass density explicitly from the call site**, because the caller is the only
thing that actually knows which surface it is. There are exactly two internal
call sites:

- `transactions_slim_view.dart:695` - knows `widget.page`
- `banxa_buy_screen.dart:1380` - the orders rail, must keep today's rendering

`TransactionsSlimView` already carries `page`, so the panel can ask for full
type scale and the page can keep the shrink, with no new heuristic and no
width guessing. Cheapest correct shape: one optional `density` (or `compact`)
parameter on `TransactionRow`, defaulted so `banxa_buy_screen.dart` does not
change.

Alternative if he wants the shrink gone everywhere: delete the type-scale half
of `compact` and keep the filter bar's 44pt chips, which live in a different
widget and are unaffected.

## Verify before touching anything

- `test/dashboard/transaction_row_test.dart`, `transaction_row_subtitle_test.dart`
- `test/dashboard/transaction_filters_test.dart` pins the bar at 52/243 - that
  is the touch-target win and must stay green.
- `test/dashboard/transactions_page_frame_test.dart` came from develop with this
  work and is the thing most likely to redden.
