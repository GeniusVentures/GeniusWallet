---
sketch: 010
name: transaction-row-anatomy
question: "What should be the headline of a transaction row — the token, the action, or the value — once every transaction type shares one skeleton?"
winner: "A"
tags: [transactions, rows, anatomy, hierarchy, empty-state, formatting]
---

# Sketch 010: Transaction Row Anatomy

## Design Question
Sketch 009 proposed four whole-system rewrites and was rejected for throwing away what already
works — chiefly the coin icon with its direction badge, which is the panel's identity. This sketch
starts from the **shipped** panel instead and asks the one question underneath it: with every
transaction type finally sharing a single row skeleton, **what should the headline be** — the token,
the action, or the value?

## How to View
```
open .planning/sketches/010-transaction-row-anatomy/index.html
```

Toggle **Dark / Light** and **Panel 520 / Narrow 376**. Hover the 123,456,789.12 amount to see the
exact value preserved in the tooltip.

## Variants
- **A · Token-first ★ CHOSEN 2026-07-22** — `ETH` is the headline, `Sent` demoted to a quiet chip. For thinking in holdings.
- **B · Action-first** — `Sent · ETH` is the headline. Closest to what ships today; cheapest to land.
- **C · Value-first** — the amount is set two sizes larger and leads. Fastest money-scanning; loudest.

## Diagnosis of the Shipped Panel
Taken from a live screenshot with the dev mock injector running (8 rows):

| Symptom | Why it matters |
|---|---|
| `Completed job` renders as a bare string in a box — no icon, no amount, no time | Three of the seven `TransactionType` values have no shared anatomy, so the list reads as several different apps |
| `Swapped` loses its coin icon entirely | Same cause; swap also has two tokens and nowhere to show both |
| `Buy - Failed` prints `$0.00` above `$0.00` | A failed transaction has no amount — printing zero twice states nothing twice |
| `- 123456789.12345679 ETH` | Unclamped, 8 decimals, sets the panel's width; no fiat context |
| `Fee: 0.001 ETH` on every row | Repeated eight times; never the reason the panel is opened |
| `a day ago` on every row | Eight identical strings carrying no information |
| No fiat value anywhere | A wallet's core job is what something is worth, not just how many tokens moved |
| Every row is its own bordered card | Reads as a stack of boxes rather than a history |

## What All Three Fix (identical across variants, so the pick is only about hierarchy)
- One row skeleton for all seven `TransactionType` values; swap shows both tokens in one identity.
- Amounts clamped (2 decimals ≥1000, else 6) with the exact value preserved on hover; tabular figures.
- Fiat value on every row; fee moved out of the resting row into detail.
- Day separators with a per-day net, replacing the repeated relative time; real timestamp per row.
- Status shown only when it is not the happy path — completed rows stay silent.
- Per-row cards replaced by one surface with hairline separators.

## What to Look For
- **Narrow 376:** the dashboard panel is the tight case. Does the headline still win against the
  amount column, or do they collide?
- **The failed row:** all three render it as `—` plus a reason. Is that clearer than `$0.00`, or does
  a missing number read as missing data?
- **The job row:** it has no amount by nature. Does `—` look deliberate or unfinished?
- **Day net totals:** genuinely useful, or a number nobody asked for?
- **Green:** received amounts are success-green in all three, while the badge already encodes
  direction. Is the colour redundant?

## Notes
- The filter is 007-C (compact icon-only segmented, title row) in all three, held constant so it does
  not confound the hierarchy comparison. 007's pick still stands separately.
- Coin icons here are CSS gradients standing in for the real token art.
