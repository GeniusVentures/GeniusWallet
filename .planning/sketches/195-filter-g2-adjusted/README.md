---
sketch: 195
name: filter-g2-adjusted
question: "192's G2 with the four changes Jakub asked for, and nothing else moved."
winner: "G2 adjusted - SHIPPED 2026-08-10"
tags: [mobile, ios, transactions, filters, final, icons, filter-alt, drawer, responsive-drawer, gw-select-row, more-sheet, compact, wcag-1.4.11, code-grounded, follows-192, follows-193, shipped]
---

# Sketch 195 - G2, adjusted

http://localhost:8899/195-filter-g2-adjusted/

Jakub, 2026-08-09: **"Do it on the existing G2 design - make the icons different, like the ones I
actually have now; add that header saying 'Filter', a separator and a way to close the window. And
I definitely prefer the earlier filter icon."**

Four changes to 192-G2. Nothing else moved.

## 1. The earlier funnel is not taste, it is correctness

Both glyphs are already spoken for:

| glyph | already used for |
| --- | --- |
| `Icons.tune` (193's choice) | the **Swap settings** trigger, `swap_screen.dart:657` |
| `Icons.filter_alt_outlined` | **this screen's own filtered-empty mark**, `transactions_slim_view.dart:608` |

193 put the swap-settings mark on a filter, while the funnel is what the same screen already draws
when a filter matches nothing. Anything but the funnel makes the trigger and the empty state it
produces disagree with each other.

## 2. Compact rows and "use our component" were never in conflict

193 made them look like they were. `GWSelectRow` **does not fix its own height** - it pays `space6`
(12) above and below whatever LEADING the call site hands it, and the call sites disagree on
purpose:

| call site | leading | row |
| --- | --- | --- |
| token picker, both account drawers | ~36px avatar | ~60px |
| **`more_sheet.dart:51`** | **a bare 21px `Icon`** | **~45px** |

Ten rows at 45 is ~490px against 193's ~640: the difference between a sheet that nearly fits
390x844 and one that scrolls. **Compact IS the component**, used the way the More sheet already
uses it.

## 3. The header, separator and close are already ours

All three are `ResponsiveDrawer`'s, not new: an AppBar title in `titleLg` 18/w600 left-aligned at
`space10` (20), the band's own `borderSubtle` hairline, and a 44px `Icons.close` at top right inset
`space3` (6). See `responsive_drawer.dart:208`, `:247-280`.

## 4. What density does not get to spend

The label stays `bodySm` 14/w600 and selection keeps all three of its marks: the `0x2E` gradient
tint, the brand edge and `Icons.check_circle` 20 under the brandCta shader. On this panel the tint
measures **1.39:1** and the edge **1.60:1**; the check is **6.81:1** and carries WCAG 1.4.11 by
itself. It is not available as density savings.

## What shipped, and the one thing this sketch got wrong

Shipped 2026-08-10 on `/transactions`, phone only, plus three corrections found on device:

- The trigger is **48x32**, not 48x48. At 48 square it set the header row's height against the 32px
  title line, which put the page title 8px lower and the list 16px lower than Assets and Crypto
  News. 32 clears WCAG 2.2 SC 2.5.8's 24x24 floor but is under Apple's 44pt guidance vertically.
- The page background drops `GWMeshBackground` for the flat `surfaceBase` the other pages paint.
- The "No more transactions" terminus is gone.

**The sketch draws a sheet that hugs its ten rows. The real one will not.** Every mobile
`ResponsiveDrawer` is full-viewport height whatever it contains - `_ResponsiveDrawerScaffold`
returns a `Scaffold`, which takes `constraints.biggest`, and `showModalBottomSheet(isScrollControlled: true)`
hands it the whole viewport. Measured: a drawer whose entire body is `Text('one line')` still
reports `Size(390, 844)`. So on device there is roughly 180px of empty space below the last filter.
That is pre-existing and app-wide, not introduced here; fixing it means a `maxHeight` on
`ResponsiveDrawer` and ~19 call sites to re-check. Not done.

## Provenance

Glyph choices and the two collisions from `swap_screen.dart:657` and
`transactions_slim_view.dart:608`; row geometry and selection treatment from
`gw_select_row.dart:95-175`; the compact-leading precedent from `more_sheet.dart:51`; drawer header,
separator and close from `responsive_drawer.dart:208` and `:247-280`; badge marks from the shared
`badgeSpec` table in `transaction_badge.dart:42-106`, with Material outlines extracted from the
SDK's `MaterialIcons-Regular.otf` (upem 512) under the flip verified in 193. Inter inlined from the
shipping TTFs. `node --check` clean; rendered in jsdom with zero script errors.

One real bug was caught by that harness only after Jakub hit it: the base was taken from 193's
BUILT html, where the icon placeholder had already been substituted, so injecting the 14-glyph table
was a silent no-op and the funnel rendered as `<path d="undefined">` - present, 44px, clickable and
completely invisible. The checker now asserts that every `mi('X')` call site has `X` in the table
and that every rendered path begins with `M`.
