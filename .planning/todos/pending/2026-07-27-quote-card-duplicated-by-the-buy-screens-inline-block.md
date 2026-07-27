---
created: 2026-07-27T00:00:00.000Z
title: quote_card.dart is duplicated by banxa_buy_screen.dart's inline quote block
area: ui
files:
  - lib/banxa/banxa_components/quote_card.dart
  - lib/screens/banxa_buy_screen.dart
---

## Problem

Two copies of the same "you will receive / gateway fee / network fee" quote
card exist in the codebase:

1. `lib/banxa/banxa_components/quote_card.dart` — a standalone `QuoteCard`
   widget, styled (re-skinned onto `GWCard`/token typography in Phase 9), but
   with **zero callers anywhere in `lib/`**.
2. `lib/screens/banxa_buy_screen.dart` — the buy screen hand-rolls an
   equivalent card inline (also re-skinned onto `GWCard`/token typography in
   Phase 9) instead of using `QuoteCard`.

Phase 9 (`09-CONTEXT.md` D-08) chose this deliberately: re-skin
`quote_card.dart` in place, rather than deleting it or repointing the buy
screen at it. Repointing the screen at the component would be
restructuring — out of scope for a re-skin phase per `PROJECT.md` §65 — and
deletion was rejected too. The accepted cost is that both copies now exist,
styled identically but maintained independently.

**Risk:** a future edit to the quote card's copy, layout, or fee logic could
easily land on `quote_card.dart` (the dead copy) while the user-visible
behavior — driven entirely by `banxa_buy_screen.dart`'s inline block — stays
unchanged. That edit would appear to do nothing, and the discrepancy would
not surface until someone diffs the two files side by side.

## Solution

This is a product decision, not a re-skin decision — one of:

- **Consolidate:** repoint `banxa_buy_screen.dart` at `QuoteCard`, deleting
  the inline block, so there is exactly one implementation.
- **Delete:** remove `quote_card.dart` outright if no other Banxa surface is
  ever expected to need a standalone quote card.

Either resolves the duplication. Until one is chosen, both files should be
kept in sync by hand if either is edited.
