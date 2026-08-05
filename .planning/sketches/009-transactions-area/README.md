---
sketch: 009
name: transactions-area
question: "How should the transactions area read as one system — row, filter and empty states together — in both the narrow dashboard panel and the wide transactions page?"
winner: null
tags: [transactions, rows, filters, empty-state, loading, dashboard]
---

# Sketch 009: Transactions Area

## Design Question
Sketch 007 asked how the **filter** should look. This one asks the bigger question it sat inside:
what does the whole transactions surface look like — **row + filter + empty + loading** — as one
coherent system? Each variant is a complete take, not a component, so the comparison is between
whole systems rather than parts that may not survive being combined.

## How to View
```
open .planning/sketches/009-transactions-area/index.html
```

Toggle **Dark / Light**, **Narrow panel / Wide area**, and **Populated / Loading / Never used**.
Filters actually filter; clicking an active filter clears back to All. In D, rows expand in place.

## Variants
- **A · Ledger** — dense tabular rows, quiet by default; status shown *only* when pending or failed.
  Filter is 007's recommended compact icon-only segmented, riding the title row. Closest to the
  shipped widget, so the cheapest to build.
- **B · Statement** — every transaction is a card, under a received/sent summary strip. Most
  "financial product"; gives amounts weight; shows roughly half as many rows per panel.
- **C · Timeline** — grouped by day on a rail with sticky day headers. Answers *when* before *what*.
  Filter is a dropdown with live counts (007-E) — the most space-frugal of the five.
- **D · Expand-in-place** — compact rows that open inline to reveal hash, fee, and explorer actions
  without a detail drawer. Adds a search field. Densest and most self-serve.

## What to Look For
- **Narrow vs wide:** every variant must survive the 376px dashboard panel. Does the filter still
  fit on the title row (A, C) or does it need its own row (B, D) — and is that row worth the height?
- **Quiet by default:** A, C and D show no status chrome on a completed transaction. Does the list
  read calmer, or does the absence make you doubt the transaction settled?
- **Two empty states, deliberately different.** The app currently shows the same copy for "this
  wallet has never transacted" and "this filter matched nothing" — the second reads as a broken
  load. Switch to a filter with no matches to compare: the filtered empty names the filter, states
  how many transactions *do* exist, and offers "Show all" instead of "Buy GNUS".
- **Sparse vs busy:** with 8 transactions, C's day grouping is a lot of structure for very little
  content. Judge it for the history the wallet will have in six months, not today's.
- **Amount treatment:** signed +/− with received in success-green (all variants) — does the green
  carry enough meaning to keep, given the rows are already icon-coded?

## Notes
- Data shapes are the real ones from `packages/genius_api/lib/models/transaction.dart`:
  `TransactionDirection {sent, received}`, `TransactionStatus {pending, cancelled, completed,
  failed}`, `TransactionType {transfer, mint, escrow, process, escrowRelease, purchase, swap}`,
  plus `hash`, `fees`, `coinSymbol`, `timeStamp`. Escrow filter matches both `escrow` and
  `escrowRelease`; that pairing is a real decision to confirm, not a mockup shortcut.
- The loading state is a skeleton list rather than a spinner, matching `pulsing_skeleton.dart`.
- Relationship to 007: 009-A adopts 007-C, 009-C adopts 007-E, 009-B and 009-D adopt a chip
  variation of 007-B. Picking a 009 winner therefore also settles 007 — they should not be decided
  separately.
