---
sketch: 154
name: transaction-details-drawer
question: "Sketch 031 already decided how the transaction receipt should read and it was never ported. What does the detail drawer look like in the shipped drawer language, using only fields txRowContent already computes?"
winner: null
tags: [drawers, transaction-detail, receipt, responsive-drawer, status, copy, data-honesty, follows-031]
lane: B
---

# Sketch 154: Transaction details drawer

Continuation of **031 · receipt** (winner **B1 · Pill + sections**) and **030 · drawer-shell**
(winner **B1 · Quiet band**). Both decisions are recorded in `drawers-final/README.md`. Neither
reached this drawer.

## Design Question

`showTransactionDetails` (`lib/dashboard/home/widgets/transaction_displays.dart:430`) is the single
panel every transaction type opens into. What ships today is a bare `ListView`:

```dart
child: ListView(children: [ ...icon, amount, _buildDetailsCard(context, rows) ])
```

`_buildDetailsCard` (`:421`) is a `Padding` with **vertical padding only**. There is no horizontal
inset anywhere in the body, so labels touch the panel's left edge and values slam its right edge -
the exact defect sketch 031's design question named a year of sketches ago. The header has a 20px
title inset and the footer has 20px padding; the body is the one zone that forgot.

**So: what does this drawer look like when the decisions that were already made are actually
applied - and what else is already sitting in the data, unused?**

## What the drawer already has and throws away

Every field below is computed **on this exact call** - `showTransactionDetails:432` calls
`txRowContent(tx, prices: livePricesBySymbol())` and then uses four of its fields.

| Already computed | Where | Used by the drawer today |
|---|---|---|
| `content.amount`, `content.action`, `content.tone` | `transaction_utils.dart:194-250` | ✅ yes |
| **`content.valueLine`** - fiat, or `Not charged`, or null | `:245` | ❌ **dropped** - the resting row shows it, the receipt does not |
| **`content.exactAmount`** - the unclamped value | `:242` | ❌ **dropped** - and a receipt is precisely where the exact number belongs |
| **`content.status`** + **`_statusPill`** - a finished widget in the same file | `:216`, `transaction_displays.dart:49` | ❌ **dropped** - the pill exists and is only used on wide rows |
| **`content.subtitleBase`** - the one real context line | `:232` | ❌ dropped |

**This corrects a claim in sketch 031.** Its README says "No fiat value is shown - the receipt has
none." That was true then. `livePricesBySymbol()` is wired into this call now, so the fiat line is
`HAVE`, not `BUILD`.

**What genuinely does not exist**, and therefore appears in no variant: a confirmations count, a block
number, a gas-used breakdown, a USD fee, a token-transfer log, a "speed up / cancel" action, or any
per-transaction note. The model carries `hash`, `fees`, `coinSymbol`, `recipients`, `fromAddress`,
`timeStamp`, `transactionStatus`, `type`, and the swap quartet - nothing more.

## How to View

```
open .planning/sketches/154-transaction-details-drawer/index.html
```

Deep links: `#a`, or `#a+failed`, `#a+swap` to land on a variant in a state or type.

Top bar: six panels, the **four real `TransactionStatus` states**, three **types** (Sent / Swap / Job -
the three that actually produce different row sets in the code), Light/Dark, and an **Edge marks**
toggle that draws the panel's own edges so the padding bug in variant 0 is visible rather than
described. Status cycling recolours icon badge, pill, banner and the Status row **together**, and the
amount deliberately stays neutral - that is the 031 round-2 rule.

## Variants

All five sit inside the shipped **030-B1 "Quiet band"** shell verbatim: 420px right panel, 60px
header, left-aligned title, ✕ top-right, faint gradient hairline, 20px body padding, footer with a top
border, secondary button = gradient outline.

- **0 · Today** - literal render of what ships, with the panel edges marked. Reference, not a proposal.
- **A · 031-B1 as decided ★** - the standing decision drawn against real data: identity + amount
  centred, the existing `_statusPill` under it, rows grouped into **TRANSACTION** / **NETWORK** cards.
  Adds the fiat line and the exact amount.
- **B · Ledger** - 031-B3 "woven minimal" brought forward: no pill, no section labels, one flat card, a
  status dot + word under the amount. The shortest scroll of the five.
- **C · Banner** - 031-B2: a full-width state-coloured banner with a plain-language reason leads the
  body, then amount, then one card.
- **D · Copyable** - A's shape, but every mono value is a tap-to-copy row and the truncated middle is
  replaced by 4-character chunks with the first and last group emphasised (034-A2's eyeball-verify
  treatment).
- **E · Type-aware** - the middle section changes shape with the type: a swap gets a real From → To
  pair block with the rate under it, a job gets its reference framed as a job.

## Recommendation

**★ A · 031-B1 as decided.** This drawer has now been designed twice and ported zero times. Picking
anything else here would be the third redesign of the same panel before the second one has ever been
seen on screen. It is also the cheapest: the shell exists, `_statusPill` exists, the section cards are
`_buildDetailsCard` with a border and a label, and the two new lines are two fields already in hand.

**Runner-up: D · Copyable.** It is not a rival to A but an extension of it - same skeleton, plus the
one interaction this panel is actually opened for. If A wins, take D's copy rows with it; the only
thing to decide separately is the 4-char chunking, which is worth it for an address and arguable for a
64-character hash.

**Rejected: C · Banner.** Its reason line is genuinely better on Failed and Cancelled, but roughly
every receipt a user opens is Completed, and an alert band across the top of a transaction that simply
worked is alarm chrome for a non-alarm. Borrow the **reason sentence** into A's pill row for the two
unhappy states and leave the band behind.

**E · Type-aware** is not rejected, it is deferred: the pair block is the best thing in the sketch for
a swap, but the code has **seven** types (`transfer`, `mint`, `escrow`, `process`, `escrowRelease`,
`purchase`, `swap`) and E only draws three. Adopting it means owning a second layout for all seven.

## Findings from the code

1. **The padding bug is one line.** `_buildDetailsCard` (`:421`) has
   `EdgeInsets.symmetric(vertical: space2)`. The body needs the 20px horizontal inset that 030-B1
   already specified for every drawer - which is why `drawers-final/README.md` says the fix belongs in
   `responsive_drawer.dart`, not here: **~19 callers share this shell** and any of them can have the
   same hole.
2. **`_statusPill` is already written and already correct.** It handles all four states with the right
   tokens (`transaction_displays.dart:49-75`), including `cancelled` → slate. A's pill is a call, not
   a component.
3. **The four-state truth holds.** `TransactionStatus` is `pending / cancelled / completed / failed`
   (`packages/genius_api/lib/models/transaction.dart:14`). The drawer today only colours the Status
   row, and only for `failed`/`cancelled` (`:452`) - `pending` gets no colour at all.
4. **A job's hash is its job reference.** `:477-480` already labels it `Job` for
   `TransactionType.process` instead of printing the same value twice. Every variant keeps that.
5. **An empty explorer URL suppresses the footer button** (`:509`) rather than rendering a dead one.
   A panel with no footer is a real state - none of the variants assume the button is always there.

## MANIFEST row

Design session, so per `CLAUDE.md` this did not write `.planning/sketches/MANIFEST.md` (executor-only,
and dirty in the tree). Row to append:

```
| 154 | transaction-details-drawer | 031 decided the receipt (B1 · Pill + sections) and 030 decided the shell (B1 · Quiet band); neither reached `showTransactionDetails`. What does the transaction-detail drawer look like in the shipped drawer language, using only fields `txRowContent` already computes? | _pending pick_ (rec **A · 031-B1 as decided** - the standing decision, finally drawn; runner-up **D · Copyable** = A plus tap-to-copy rows and 4-char chunking, take it with A; **B · Ledger** = one flat card, shortest scroll; rejected **C · Banner** - alarm chrome on the happy path, borrow only its reason sentence; **E · Type-aware** deferred - the swap pair block is the best thing here but the code has 7 types and E draws 3). Findings: body padding is literally 0 (`_buildDetailsCard:421`), `_statusPill` already exists unused in the drawer, and **`valueLine` (fiat) + `exactAmount` are computed on this call and thrown away** - which corrects 031's "the receipt has no fiat". | drawers, transaction-detail, receipt, responsive-drawer, status, copy, data-honesty, follows-031 |
```

## Verified

Rendered before hand-off - headless Chrome for Testing from the Playwright cache. Variant 0 was
checked against Jakub's screenshot (same rows, same order, same flush edges). Structure: 131/131 divs,
6/6 sections, script parses, no em dashes.

## What to Look For

- **Turn Edge marks off, then compare 0 with A.** The padding is the whole reason this drawer reads
  as unfinished; everything else is a bonus.
- **Cycle all four states in A, B and C.** `Cancelled` is the one earlier rounds missed; slate has to
  read as "nothing happened", not as a second failure.
- **Is the amount staying neutral right?** 031 round-2 said colour rides on icon + pill + Status row
  only. Cycle to Failed and decide whether a red amount would say it better.
- **The exact-amount line** - useful precision, or noise under every receipt?
- **Switch to Swap in A vs E.** Three labelled rows against one pair block.
- **Light mode** is togglable, but per the dark-first rule it is not the deciding view.
