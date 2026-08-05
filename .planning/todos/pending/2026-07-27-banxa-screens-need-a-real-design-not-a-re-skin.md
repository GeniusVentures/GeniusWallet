---
created: 2026-07-27T00:00:00Z
title: Banxa screens need a real design, not a re-skin — sketch the buy form and orders page
area: ui
files:
  - lib/screens/banxa_buy_screen.dart
  - lib/banxa/banxa_orders_history.dart
  - .planning/phases/09-banxa/09-OUTSTANDING.md
---

## Problem

Braian, at the running app on 2026-07-27, after Phase 9 re-skinned all ten Banxa surfaces:
**"we need to redesign the banxa screens it's too ugly."** Asked to distinguish, he confirmed it is
**layout and structure**, not tokens failing to apply.

The tokens did apply — the 09-07 literal gate (31 tests) and the verifier's code-level grep both
confirm it independently. Phase 9 executed correctly. The problem is that it applied a design
system to a layout that had never been designed.

`PROJECT.md` line 33: the develop-era surfaces have **no mockup** — "they wear the design language
in place, structure unchanged". §65's *"Re-skin, never restructure"* then held that structure fixed
by rule. Every other surface in this milestone was sketched first (Swap: 105/040/041/060/062;
Feedback: 150/153/064; Markets: 103/107–115; Transactions: 007–014/020–030). **Banxa: none.**

## What is concretely wrong

**`banxa_buy_screen.dart`** — a bare `Column` of three stock Material `DropdownMenu`s (Fiat,
Crypto, Payment Method), a `TextField` amount, a Get Quote button, a quote `GWCard`, and a wallet
`TextField`. No grouping, no hierarchy, and stock dropdowns instead of the app's own field
language. **A re-skin structurally could not fix this** — replacing a `DropdownMenu` is
restructuring, fenced by §65.

**`banxa_orders_history.dart`** — a Status dropdown, a "Pick Date Range" button, a date string and
"Total Orders: N" stacked in a plain `Column` above the list. Filters as loose controls rather than
a designed toolbar.

## Why this is tractable rather than open-ended

Both surfaces have a precedent this app already settled:

- **Buy is Swap with one side fixed to fiat.** Sketch 105-A1: 560px column, two amount cards, a
  details card, the gradient CTA ladder. The buy form is the same shape — you pay $X, you receive
  Y GNUS — with the pay side being fiat instead of a token.
- **Orders-with-filters is Transactions.** Phases 12/15 already solved filter-above-list.

## Next step

Sketch **067 (buy form)** and **068 (orders page)**, 3 variants each, grounded in the two
precedents above. Pick winners, then implement in a follow-up phase. Those two numbers are free and
reserved.

Agreed with Braian on 2026-07-27 and deferred at end of session — **nothing has been built yet**.

## Related

- `.planning/phases/09-banxa/09-OUTSTANDING.md` — carries this as the item that should gate calling
  Banxa done, distinct from the verification debt items around it.
- A separate follow-up phase is already recommended there for the finding-1 KYC-redirect blocker
  (a behaviour fix, fenced out by D-02). That is a different piece of work from this one, though
  they touch the same feature area and could reasonably share a phase.
