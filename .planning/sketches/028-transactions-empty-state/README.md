# 028 · Transactions empty state (never-transacted wallet)

**Design question:** on a wallet that has never transacted (`scoped.isEmpty`), the filter rail is correctly
hidden — so the list card stretches full-width and a 72px icon floats in ~1280×460 of empty card. It reads
as a failed load. How should the empty state sit instead?

**Status:** four states, awaiting Jakub's pick.
**Recommendation:** **E-a · narrow centred card (~520px)** — smallest change, keeps the card rhythm, box fits its contents.

## Grounded

- Copy: `emptyTransactionsTitle` = "No transactions yet", `emptyTransactionsMessage` =
  "Your sends, receives and swaps will appear here." (`transactions_slim_view.dart:137-139`).
- Icon: `Icons.sync_alt` (`transactions_slim_view.dart:442`); the 72px disc + 32px glyph is `GWEmptyState`
  (`components/feedback/gw_empty_state.dart:26-27`).
- The box today: the empty branch renders inside `Expanded(ConstrainedBox(minHeight:496, ...))`
  (`transactions_slim_view.dart:401-408`) — `Expanded` is what makes it full-width.
- Rail already hidden on empty: `if (scoped.isNotEmpty)` (`:385`) — locked 021/022 decision.

## Variants

| # | State | Change | Verdict |
|---|---|---|---|
| E0 | Today | — | Full-width card, 72px icon adrift in ~1280×460. Reads as a failed load. **The problem.** |
| **E-a** | **Narrow card** | `Expanded` → `Center(ConstrainedBox(maxWidth: 520))` | **Recommended.** Box fits its contents; keeps the card rhythm every other state uses; smallest diff; populated/filtered-empty layouts untouched. |
| E-b | No card | drop the card, centre disc+copy on the page | Airiest; but the only card-less state of the tab — can read as half-loaded against the populated/filtered-empty cards. Fallback. |
| E-c | Rail + box | keep the Type rail (all counts 0) + narrow box | Comparison only. A rail of five 0s reads more broken, and it reverses 021/022. Rejected. |

## Recommendation

**E-a.** It fixes the actual defect — a card sized for content that isn't there — with the least code and no
change to the populated or filtered-empty layouts. E-b is the clean fallback if the first-run screen should
carry no surface at all. E-c answers Jakub's "keep the rail?" question by showing why a rail of zeros is worse,
not better. Icon and copy are unchanged from what shipped.

## Process note

Real-size render per the `sketch-fidelity-real-size` bar: real 68px navbar, real 28px page header, the real
72px `GWEmptyState` disc and copy, no `transform: scale()`. E0 carries a measured red band on the void; E-a/E-b/E-c
carry a green width marker on the fitted box.
