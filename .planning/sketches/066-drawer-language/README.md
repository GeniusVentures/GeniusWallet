---
sketch: 066
name: drawer-language
question: "The shell change reached nineteen drawers. Two shipped, two are slated for deletion and one is already decided (receipt 154-A). What language do the remaining fourteen share, on the 065 kicker foundation - given seven of them still ship raw OutlinedButtons in Colors.greenAccent?"
winner: "Five archetypes accepted by Jakub 2026-07-27 (\"066 - ok\"), adjusted from 065-D to 065-C at the same time. Per-archetype execution not started."
tags: [drawers, archetypes, consistency, reown, banxa, receive, menu, follows-065, follows-030, follows-032, follows-154]
lane: execution
---

# Sketch 066: One language for the remaining fourteen drawers

Nineteen `ResponsiveDrawer.show` call sites exist. Two shipped (Swap Settings 063-A, Token Selector
032-A1), two are slated for deletion (08-05 task 2), one is decided separately (receipt 154-A).
**Fourteen are left**, and they share no language at all - seven of them still ship raw
`OutlinedButton`s in `Colors.greenAccent`.

Five archetypes instead of fourteen separate designs.

## How to view

```
open .planning/sketches/066-drawer-language/index.html          # 065-C, the decision
open .planning/sketches/066-drawer-language/index-065d.html     # 065-D comparison, kicker with a rule
```

Every archetype shows **today beside new**, at a real 420px. The last tab maps all nineteen call
sites to file and line.

## The archetypes

| | Archetype | Drawers | Shape |
|---|---|---|---|
| **A** | **Consent / request** | reown transaction request, reown connection request | who is asking (origin block), what will happen (kicker sections), then two buttons. Origin on top because it is the only information a refusal can be based on. |
| **B** | **Result** | Banxa success, Banxa cancelled, reown swap result | the same hero as receipt 154-A - status icon, neutral amount, fiat line, status pill - so a purchase result, a swap result and a receipt are one picture rather than three. Cancelled takes slate, not red: nothing broke. |
| **C** | **List picker** | network picker, bridge destination, Your Accounts, SDK Accounts | the 032-A1 row unchanged, plus a `dense` kicker separating connected/active from the rest. No footer - a pick is the action. |
| **D** | **Receive / QR** | coins_screen, token_info_screen, wallet_information | code under a kicker, address in 4-character groups (034-A2), network as a row, sharing in the footer. |
| **E** | **Action menu** | two More Options drawers | rows with a description and a chevron, not a value. The kicker earns most here: it fences off the irreversible action. |

## Findings

**Receive exists three times, More Options twice.** Five files, two designs. The three receive
drawers differ in title (`Receive` / `Receive {coin}` / `Your {network} address`) and in layout,
for the same address of the same wallet. Archetypes D and E are therefore not only a style - they
reduce five implementations to two.

**Seven of the fourteen have footers from outside the design system.** reown and Banxa use raw
`OutlinedButton` with plain Material colours - `Colors.greenAccent`, `Colors.grey`, `Colors.black`,
radius 4 or 10, height 40. No tokens, no `GWButton`. Worse, `Approve` and `Reject` read as equally
important and the filled one is the green.

**`lib/banxa/` is behind a fence.** `CLAUDE.md`: *"Files under `/banxa` and `/squidrouter` are
auto-generated. Do not change them."* The two Banxa result drawers can be designed but not
implemented without lifting it - the open question for Braian.

**Body padding had to land first.** The shell passed `body: child` with no inset, so every archetype
would have added its own and one fix would have become fourteen. Done in quick 260728-0vd before
any archetype work.

## Decision - accepted 2026-07-27 (Jakub)

*"066 - ok, aczkolwiek kickers wybraliśmy inny z designu 065 (c) więc zrób adjustment"* - the five
archetypes stand; the kicker foundation moved from D (with a rule) to **C** (two steps, no rule),
and the sketch was corrected. `index-065d.html` was kept as the comparison file, since the rule is
still the open candidate for the receipt, where sections are two rather than one.

**Execution has not started on any archetype.** What exists is the shell work they all depend on.

## MANIFEST row

```
| 066 | drawer-language | The shell change reached 19 drawers: 2 shipped, 2 slated for deletion, 1 decided separately (154-A). What language do the remaining 14 share on the 065 kicker foundation, given 7 of them still ship raw OutlinedButtons in Colors.greenAccent? | **Five archetypes accepted** (Jakub 2026-07-27) - A Consent (reown x2), B Result (Banxa x2 + reown swap result, sharing 154-A's hero), C List picker (4 drawers, 032-A1 row + dense kicker grouping), D Receive/QR (3 drawers), E Action menu (2 drawers, kicker fences the irreversible action). Adjusted from 065-D to 065-C in the same review; `index-065d.html` kept as the comparison. **Findings: Receive is implemented THREE times and More Options TWICE** - 5 files, 2 designs, so D and E reduce 5 implementations to 2; **7 of the 14 have footers entirely outside the design system** (raw OutlinedButton in Colors.greenAccent/grey/black, radius 4, height 40) with Approve and Reject reading as equally important; `lib/banxa/` is fenced by CLAUDE.md so its 2 drawers cannot be implemented without lifting it. Body padding had to land in the shell first, or one fix would have become fourteen. Execution not started. | drawers, archetypes, consistency, reown, banxa, receive, menu, follows-065, follows-030, follows-032, follows-154 |
```
