---
sketch: 016
name: compute-panel-anatomy
question: "How does the first dashboard section split into Balance + Compute, in the 276px it actually has?"
winner: "B2 · Twin tiles (chosen 2026-07-22; fits only with the why-row merged into the sub-line)"
round: 2
tags: [dashboard, compute, balance, overview, sgnus, anatomy]
---

> **Round 1 decided the direction: B — the tile.** Round 2 (B1–B4) refines it. A and C are kept in the
> variant switcher for reference; the recommendation below has been re-scored against round 2.

# Sketch 016: Compute Panel Anatomy

## Design Question

The left card of `_OverviewContributionsRow` (`dashboard_screen.dart:233`) currently stacks six unrelated
widgets in a centred column with no section title. Jakub picked the **split** direction — a balance strip
plus a Compute panel. This sketch answers: **where does the seam go, and what does each half own?**

Sub-question it has to settle: the card shows `1,204.50 GNUS` while the Assets panel 12 px away shows
`$312.40`. **Same money, two units, two polling intervals.** Does the split resolve that or preserve it?

## How to View

```
open .planning/sketches/016-compute-panel-anatomy/index.html
```

Switch **variant** (A/B/C) and **state** (6 states) in the toolbar. **Show unit clash** annotates the two
balances. A red ring + OVERFLOW badge appears on any variant/state pair that exceeds the real 276 px budget.

## Variants

**Round 2 — refining B (the chosen direction):**

- **B1 · Sunken balance** — one sunken tile holds the balance and its toggle; compute sits flush below a compact `COMPUTE` kicker, CTA on the card floor.
- **B2 · Twin tiles** — both halves get a tile and read as siblings of equal rank. 40 px of chrome across two borders.
- **B3 · Fiat hero** — `$312.40` becomes the big number inside the tile, the token count drops to a subline. The only variant where this card and Assets measure in the same unit.
- **B4 · Raised compute** — depth inverted: static balance flush, live compute in a *raised* tile with a 2 px brand cap.

**Round 1 — kept for reference:**

- **A · Stacked strip** — balance as one compact line, hairline divider, compact `COMPUTE` kicker.
- **B · Two tiles** — the direction chosen; refined into B1–B4.
- **C · Compute-only** — balance leaves the card entirely; node identity, earnings and job progress instead.

## What to Look For

1. **Does it fit?** Cycle to *Not linked* and *Stalled 52.5%* — the tallest states. This card has already
   overflowed once in shipped code (05-08 gap B1) and needed a scroll wrapper as a workaround.
2. **Does the balance still read as the primary number** in A and B, or has the Compute block stolen it?
3. **In C, do you miss the balance?** Assets is right there with the same money in dollars.
4. **The earned readout** (`+12.4 GNUS earned`, variant C only) — worth having, given it is not derivable
   from any current API and needs a new job-reward aggregate.

## Findings

**1 · Real geometry, not guessed.** `maxHeight: 300` (`dashboard_screen.dart:207`) minus
`DashboardScrollContainer`'s `EdgeInsets.all(space6)` = **276 px** of usable height. All three variants fit
in all six states — but only because the compute block replaces four stacked widgets with one.

**2 · The zero-balance red is a shipped bug.** `wallet_overview.dart:141-147` renders `'No funds available'`
in `statusError`. MANIFEST's guiding principle for this whole round is "a wallet with no funds is not a
broken wallet". All three variants render `0.00 GNUS` in normal weight instead.

**3 · `Colors.white` hardcoded.** `genius_balance_display.dart:80` — the 48 px balance is a literal white,
not `gw.textPrimary`. It disappears on the light surface. Any port must route it through the theme extension.

**4 · The unit clash is structural, not cosmetic.** Left card polls the SDK every 10 s
(`genius_balance_display.dart:56`); Assets computes from CoinGecko every 60 s (`coins_screen.dart:243`).
They will routinely disagree. Only variant C removes the duplicate.

## Decision — B2 · Twin tiles ★

Chosen 2026-07-22. Both concerns get a container and read as siblings of equal rank.

**B2 did not fit as proposed.** 244 px base + a 38 px *Not linked* state = 282 px against a 276 px budget —
an overflow in the most common non-happy state. The fix was not shaved padding: **the centred "why" row
under the CTA was merged into the status sub-line**, so the reason and its remedy share one line
(*"Not the wallet linked to SGNUS · switch wallet ›"*). That removes 17 px of text plus a 6 px gap from four
of the six states, and reads better — the explanation and the way out are no longer separated by a button.

**Result: worst state 261 px, +15 px headroom.** It fits, and it is the tightest of the four by a wide
margin. **Standing constraint: anything added to the compute block later breaks B2 first.** The
`+12.4 GNUS earned` line is exactly such an addition — excluded from B2's measurement, stretch item only.

**Carried over from B4:** the 2 px brand cap on the *balance* tile, only while a job runs. B4's raised
surface is not carried over — two elevations inside one card fight each other.

**Unit clash: B2 keeps it**, mitigated by the `≈ $312.40` subline making the relationship explicit. B3
resolved it outright and was not chosen; it is the fallback if the 10 s SDK poll and the 60 s CoinGecko
poll visibly disagree in practice.

## Affordance audit — every link has a destination

No link in the design points at nothing. Two are build items, and they are named here so they land in the
plan rather than surfacing during execution.

| Affordance | Status | Destination |
|---|---|---|
| `Node ›` | **Exists** | `context.push('/network')` → `NetworkStatusPage` (`router.dart:188`), already used by `sgnus_connection_widget.dart:102`. The page is raw `ListTile`s — sketch 019 re-skins it, nothing blocked. |
| `see node status ›` (stalled) | **Exists** | Same `/network`. Deliberately one destination reached from two contexts. |
| `switch wallet ›` (not linked / no wallet) | **Partial** | Mechanism exists in full: `AccountDropdownSelector._showAccountDrawer()` (`account_dropdown_selector.dart:161`) → `ResponsiveDrawer<Wallet>` → `selectWallet()` (`:212`). But it is **private** and mounted only in the top-bar action row (`responsive_overlay.dart:103`). **Build item:** extract a public `AccountDrawer.show(context)`. Small, no new UI. |
| `retry ›` (telemetry dead) | **Missing** | Nothing to call. `app_bloc.dart:194` cancels `_processingTimer` permanently; no path restarts it. **Build item:** a `RetryProcessingStatus` event that re-arms the timer, plus a state flag separating "unavailable" from "idle". The only link needing real bloc work. |
| `New processing job` | **Exists** | `/submit_job` (`router.dart:280`) is live and wired. Sketch 018 moves the primary entry to a `ResponsiveDrawer` and keeps the route as full-screen host. |
| `View transaction ›` (job complete, sketch 017) | **Partial** | `showTransactionDetails(context, tx)` exists (`transaction_displays.dart:316`). **What's missing is the association** — nothing links a finished job to the mint transaction it produced. Needs a job→tx correlation before the link can carry a real `tx`. |
| Balance tile | **Non-navigating by design** | Drilling into holdings is the Assets panel's job, 12 px away. A tap target here would create two routes to the same information. |
