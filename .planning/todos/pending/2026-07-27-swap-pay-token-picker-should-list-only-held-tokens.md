---
created: 2026-07-27T08:30:00.000Z
title: Swap "You Pay" token picker should list only tokens the wallet holds, with an empty-state
area: ui
files:
  - lib/squid_router/swap_screen.dart:82
  - lib/squid_router/swap_screen.dart:616
  - lib/squid_router/token_selector_drawer.dart:73
  - lib/squid_router/token_selector_drawer.dart:314
  - lib/squid_router/squid_token_service.dart:12
---

## Problem

Surfaced during the Phase 8 / 08-07 walk (2026-07-27), by Braian at the running
Windows app.

The swap token picker lists the **entire** Squid token catalogue on both sides of
the swap. On the "You Pay" side that offers the user tokens they cannot possibly
spend — Braian's words: *"a user can't simply swap a BNB he does not have."* The
dead end is only discovered at the CTA, which drops to the "Insufficient {SYMBOL}
balance" rung after the user has already picked a token and typed an amount.

Chain as shipped:

- `swap_screen.dart:82` calls `SquidTokenService.fetchTokens()` — every supported
  token — then merges balances in from `fetchBalances()` by symbol + chain +
  address (`swap_screen.dart:88-99`).
- The only filtering before the drawer (`swap_screen.dart:616`, and the mirrored
  block for the receive side) excludes the token already picked on the *other*
  side. Nothing filters on balance.
- `token_selector_drawer.dart` then applies the search query and a hard 30-row
  cap (`_maxRows`, line 73).

Holdings already change how a row renders — `token_selector_drawer.dart:314` draws
the balance line only when a balance exists, deliberately: *"A balance the wallet
does not hold is ABSENT, not '0'."* So the information is present; it just isn't
used to filter.

## Decision (Braian, 2026-07-27, during the 08-07 walk)

**"You Pay" only, with a designed empty-state.**

- **You Pay** — list only tokens with a non-zero balance.
- **You Receive** — keep the full catalogue. Filtering this side too would make it
  impossible to swap *into* a token you don't already own, which is most of the
  point of a swap. Explicitly considered and rejected.
- **Empty / thin state** — a wallet holding one token or none must get a designed
  state, not an empty drawer. This is not hypothetical: `fetchBalances()` is
  mocked to ~6 entries, so thin lists are the normal case in testing today.

## Notes / constraints

- **Not a Phase 8 regression.** This is pre-existing `develop` behaviour. Phase 8's
  08-01 only re-skinned this drawer to sketch 032-A1; it never touched the data
  source. Recorded as a walk finding, not a re-skin defect.
- **Both feeds are mocked** (`squid_token_service.dart:12` returns `mockTokens`,
  13 entries; `fetchBalances` returns `mockSquidBalances`, ~6 entries) with the
  real HTTP calls commented out. Same family as D-18b's hardcoded quote. Any fix
  must behave correctly once the real feeds are restored — filter on the merged
  `token.balance`, not on the mock's shape.
- Interaction with the 08-03 CTA ladder: the "Insufficient {SYMBOL} balance" rung
  does NOT become dead code — it is still reachable by typing an amount larger
  than the held balance. Only the "token you hold none of" path disappears.
- The flip control swaps `fromToken`/`toToken`. If the pay side is filtered and the
  receive side is not, flipping can seat a zero-balance token on the pay side —
  decide whether flip re-validates or is simply allowed to produce the
  insufficient-balance rung.
