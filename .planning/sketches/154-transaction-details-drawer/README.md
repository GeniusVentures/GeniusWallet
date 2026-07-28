---
sketch: 154
name: transaction-details-drawer
question: "Sketch 031 already decided how the transaction receipt should read and it was never ported. What does the detail drawer look like in the shipped drawer language, using only fields txRowContent already computes?"
winner: "A \u00b7 031-B1 as decided - ONE schema for all 7 transaction types (Jakub 2026-07-27), WITH D's copy rows (Jakub 2026-07-28, closing the open question). BUILT 2026-07-28, quick 260728-r4k - the section grouping shipped bare on 067-A's reasoning and was walked back the same day into a new GWDetailGrid component - 067's arithmetic covers a box around a FORM, not a read-only table whose rules are decorative."
tags: [drawers, transaction-detail, receipt, responsive-drawer, status, copy, data-honesty, follows-031]
lane: B
---

> ## DECIDED 2026-07-27 (Jakub)
>
> **Variant A · 031-B1 as decided.** Colours, layout and structure as drawn in round 1's variant A:
> identity + amount centred, the existing `_statusPill` under it, rows grouped into **TRANSACTION** /
> **NETWORK** section cards, 20px body padding, the fiat line and the exact amount added, amount stays
> neutral (colour rides on icon + pill + Status row).
>
> **One schema for ALL transaction types.** Jakub, 2026-07-27: *"wszystkie transakcje powinny mieć ten
> schemat"*. That covers all seven `TransactionType` values - `transfer`, `mint`, `escrow`, `process`,
> `escrowRelease`, `purchase`, `swap`. The rows inside the sections still vary by type (a swap gets
> From / To / Rate, a job's hash is labelled `Job`), because `showTransactionDetails` already builds them
> that way - but **the frame does not change per type**.
>
> **This rejects variant E · Type-aware**, which was previously only deferred. No per-type layout.
>
> Round 2 (A1 / A2 / A3, `round2.html`) was drawn and **not taken** - Jakub kept round-1 A.
>
> **Still open on this sketch:** whether D's tap-to-copy rows and 4-character address chunks ride along
> with A. Recommended yes; see the round-1 recommendation below.

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

## Round 2 - A1 / A2 / A3 (2026-07-27)

Jakub chose **A** on 2026-07-27, then asked for A re-drawn in the language of the two drawers that had just
shipped. `round2.html` is that round.

```
open .planning/sketches/154-transaction-details-drawer/round2.html
```

### What the shipped drawers actually do

Read from `swap_settings_drawer.dart` (063-A) and `token_selector_drawer.dart` (032-A1), both landed
2026-07-27 in PR #216. Round 1's variant A breaks two of these:

1. **No filled cards.** `_TokenRow` is `Colors.transparent` at rest, with a comment stating that a
   `surfaceMenu` row on a `surfaceMenu` panel is decoration nobody sees. Hover brings `GWDecorations.hoverFill`
   + `hoverEdge`, and **the border is always present and transparent** so nothing twitches by 1px.
   *Round 1's A used bordered cards with a `surface-sheen-b` fill.*
2. **No uppercase kickers.** Swap Settings uses a sentence-case `labelMd`/w600 label plus a plain description
   line; Token Selector has no section labels at all. Nothing in either drawer is set in caps.
   *Round 1's A used `TRANSACTION` / `NETWORK` in caps.*
3. **The accent is the gradient, in two doses:** the full `brandCta` on a chosen preset, or a `0x2E`-alpha
   tint (`_TokenRowState._selectionTint`) plus a `ShaderMask` check. Never a flat brand fill.
4. **Constants:** body `fromLTRB(space10, space12, space10, space10)`, `radiusMd` rows, `radiusSm` fields,
   `GWFocusRing` on every input, primary action in the shell footer above a `borderSubtle` top rule.

All three variants keep every round-1 decision: 20px body padding, `_statusPill`, the fiat line, the exact
amount, a neutral amount, D's tap-to-copy rows with 4-char chunks, and the footer explorer button.

- **A1 · Flat rows ★** - the Token Selector applied literally. No labels, no containers; hero, one hairline,
  then a stack of transparent rows. **Nothing new to build** - the row is `_buildRow` plus the decoration
  already written in `_TokenRow`.
- **A2 · Labelled groups** - A's two groups kept, but said the Swap Settings way: sentence-case labels and a
  hairline container at `radiusMd` with **no fill**. Survives the Swap type best (eight rows in two groups).
- **A3 · Tinted hero** - A1's rows with the hero on 032-A1's selection tint.

### Recommendation for round 2

**★ A1.** It is the only one of the three that adds no new vocabulary at all, and on the receipt that actually
gets opened most (Sent, six rows) the groups in A2 are structure for its own sake. **A2 is the fallback and
the answer if Swap reads badly** - cycle the Type switch to Swap and judge there, that is where A1 goes to
eight undifferentiated rows.

**A3 is drawn to be rejected, and should be checked before rejecting it.** In the shipped drawers that tint
means *"this one is selected"*; spending it as decoration takes a word the design system has already assigned
a meaning. Cycle to **Failed**: a brand-green wash behind a red pill is a mixed signal.

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

## BUILT 2026-07-28 - quick 260728-r4k, with one departure

Jakub closed the open question the same week he opened it: *"wybraliśmy wcześniej D copyable"*. So
**A's frame with D's rows**, which is what this sketch's own recommendation asked for
(*"it is not a rival to A but an extension of it"*).

**The grouping went out and came straight back.** It first shipped bare - kicker and gap, 067-A -
on the grounds that a `GWCard` on the 156-A panel measures 1.00:1 and the first 1.4.11-passing edge
is white 36%. Jakub walked it the same day: *"tej siatki nie ma - chciałbym ją mieć"*.

He was right and 067 had been over-applied. **067 measured a box around a FORM**, whose frame is part
of identifying the control inside it; **A's groups are a read-only table**, whose rules carry no
information - every row reads with them removed and the text clears AA by itself. That makes them
decorative separators, the same category as the drawer header's hairline. `borderSubtle` is the
correct weight, and 36% would have made the frame louder than the contents.

So A's cards are back, as **`GWDetailGrid`** - a `surfaceSunken` well with a `borderSubtle` outline
and hairline rules between rows. It is a component rather than a private widget because Jakub asked
for one, and because archetype **B · Result** (sketch 066: the two Banxa results and the swap result)
shares this hero and will want the same table.

**The chunking question this sketch left open was answered by width.** It asked whether 4-char
chunking is "worth it for an address and arguable for a 64-character hash". Both get it, but on a
SHORT form - `0x1234·5678 … cdef·0123`, 8 + 8 characters, outer groups emphasised. A full 42-char
address chunked is ~398px of monospace against 380px of content width, and a hash is 66 characters.
The full value goes to the clipboard, which is what the row is for.

Everything else landed as drawn: the fiat line, the exact amount, `_statusPill`, the neutral amount,
the 20px body inset (from the shell, quick 260728-0vd) and the explorer button suppressed when the
chain has no URL.
