---
sketch: 065
name: token-row-chain
question: "How does a token picker row show WHICH CHAIN it is on, without breaking the 032-A1 list archetype?"
winner: "C"
tags: [drawers, list, picker, token, chain, swap, phase-08]
---

# Sketch 065: Token Row — Which Chain Is This?

## Design Question

The swap token picker lists the same symbol on several chains — **ETH on 1, 137 and 80001**,
**USDT on 1 and 137** — and the shipped row (032-A1) shows logo, name, symbol and balance with
**nothing naming the chain**. Three rows can read identically and mean three different assets.

How does the chain become visible without breaking the list-picker archetype that the network
picker, the account switcher and Search Coins all share?

## Provenance

Raised by Braian at the 08-07 walk, 2026-07-27, immediately after the pay-side holdings filter
landed: *"we need a better visual design to see the token per chain."*

## How to View

open .planning/sketches/065-token-row-chain/index.html

Reuses the **030 B1 "Quiet band"** drawer shell and the **032 A1 "Comfortable"** row verbatim —
neither is reinvented here. Tabs switch variants, the toolbar toggles dark/light, and tapping a
row moves the selection and toasts which chain it belongs to.

## The honest constraint

`assets/json/networks/networks.json` knows **10 chains** with real icon assets (eth, matic, bnb,
base, sgnus + testnet variants). The Squid catalogue also carries **42161 (Arbitrum)**,
**250 (Fantom)**, **1284 (Moonbeam)** and **80001 (Mumbai)**, which it does not — `getNetworkById`
answers `'Unknown'`. Every variant has to say so out loud rather than render a hole. The mockups
use the real icon files, so an unknown chain looks exactly as unknown as it will in the app.

Content is the real pay-side list: mock balances after `heldTokens()`, including the 08-07
magnitude fixtures.

## Variants

- **A · Chain crest** — a 17px chain logo on the bottom-right of the 36px token avatar, ringed in
  the panel colour. Zero vertical cost; one `Stack` + `Positioned` in Flutter. Unknown chains get
  a `?` crest on a sunken fill.
- **B · Chain on the meta line** — the subtitle becomes `symbol · chain` with a 12px inline icon.
  The only variant where the chain is **read** rather than recognised; unknown chains read
  `Chain 42161` in the warning colour, because the id is real information.
- **C · Grouped by chain** — rows keep 032-A1 exactly and the chain becomes the *structure*:
  sticky section headers with icon, name and count, and a final **Unrecognised chains** group.
- **baseline · shipped 032-A1** — what is in the running app, for comparison.

## What to Look For

- At a glance, can you tell mainnet ETH from Polygon WETH? A's 17px crest is the smallest bet;
  B names it outright; C makes adjacency impossible.
- Does A's `?` crest read as a deliberate state, or as a broken image?
- In B, watch the ellipsis: in a 420px panel, does a long token name eat the chain you added the
  line for?
- In C, is the vertical cost worth it when the list is capped at 30 rows — and what happens when
  search filters down to two tokens across two chains (two headers, two rows)?
- Both modes: the crest ring and the group hairline are the two things most likely to vanish in
  light mode.

## Decision — C · Grouped by chain

Chosen by Braian, 2026-07-27, at the walk. C is the only variant where the chain is still on
screen after the row that named it has scrolled away, and the only one where two identically-named
tokens can never sit adjacent — which was the actual complaint.

Rows keep 032-A1 byte-for-byte; the chain becomes structure rather than an addition to the row.
A and B are not taken.

### What C still owes an answer

Three things the mockup shows but does not settle, all of which the implementation has to decide:

1. **Search versus grouping.** Filtering to two tokens on two chains leaves two headers and two
   rows — more ceremony than list. Options: collapse headers below a threshold, drop grouping
   entirely while a query is active, or accept it.
2. **The thin-wallet case.** The pay side is now filtered to holdings, so a wallet holding one
   token per chain renders as all headers and no list. This is *more* likely since the holdings
   filter landed, not less.
3. **Sticky headers in a drawer body.** The mockup uses CSS `position: sticky`; Flutter needs
   `SliverPersistentHeader` inside a `CustomScrollView`, which is a different scroll widget from
   the `ListView.builder` the drawer uses today. That is the real cost of C, and it is not
   visible in the HTML.

**Unresolved and deliberately so:** whether the *receive* side — which is NOT filtered to holdings
and carries the full catalogue across every chain — wants the same grouping. It has far more rows
and far more chains, so grouping may help more there, or may bury the search. Not decided here.
