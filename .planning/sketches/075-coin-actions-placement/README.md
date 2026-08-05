---
sketch: 075
name: coin-actions-placement
question: "Jakub wants the Receive/Swap icons somewhere other than the PRICE line - above the stat rail, or beside the price top-right. Six placements against the page as it actually stands today, not the page 073 was drawn against."
winner: null
tags: [coin-detail, token-info, actions, icon-buttons, page-header, follows-074, follows-073]
lane: execution
---

# Sketch 075: Where the coin actions go

Jakub, 2026-07-28, after walking 074-C2 on screen: *"spróbuj trzy, cztery, pięć innych designów, żeby
te ikony receive i swap były w innym miejscu, może nad price table, albo gdzie indziej, albo obok ceny
po prawej stronie u góry."*

## How to view

```
open .planning/sketches/075-coin-actions-placement/index.html
```

Six placements × two routes in (Markets = **2** actions, Assets on GNUS = **3**) × covered / no market
data, dark and light. One page at 1180px, drawn 1:1.

## Why this is not a re-run of 073

073 asked the same question and its answer, A · under the price, was never built. **The page it was
drawn against no longer exists.** Since then 071-B added the stat rail and moved identity + price into
`GWPageHeader`, and 074-C2 shipped the PRICE section line. So three of 073's five placements were
drawn against geometry that has changed, and two of the six here (C · above the rail, D · a seventh
rail tile) could not have been drawn at all.

## The finding that eliminates two of the six

**The stat rail does not exist on the no-data page.** `marketData == null` - the route in from the
wallet's own Assets list for any coin CoinGecko does not cover - renders no rail at all. So **C** and
**D**, which both hang off it, either vanish or have to be re-homed: one page, two action positions,
for a reason the user cannot see. This is the same trap that decided 074 against every in-card
placement, and it is drawn in red on those two panels rather than quietly worked around.

## What each placement costs

| | Placement | Where exactly | New height | Survives no-data | Breaks when |
|---|---|---|---|---|---|
| **A** ★ | **Beside the price** | `GWPageHeader.trailing`, icons left of the price block on the same line | **0px** | **yes** - the slot holds the icons alone | the window narrows: name + icons + a 28px price on one row |
| **B** | Under the price | trailing column: price, pill, then icons | ~52px, all inside the header | yes | the trailing block grows taller than the identity beside it |
| **C** | Above the stat rail | own right-aligned line between header and rail | ~54px | **no** | immediately, on the no-data page |
| **D** | Seventh rail tile | an action cell inside the stat `Wrap` | 0px | **no** | an action sits in a grid of facts; the rail re-wraps 6→3→2 by width |
| **E** | Beside the identity | right of the coin logo + name, left half of the header | 0px | **yes** - it never touches market data | the icons read as part of the title |
| **F** | On the PRICE line *(shipped today)* | opposite `GWKicker('Price')`, above the chart card | ~44px | yes | nothing - it just spends a line the header already had room for |

## Recommendation

**★ A · Beside the price.** Where Jakub pointed, and the only one of the six that is free in **both**
directions: zero new height, and no movement on the no-data page, because the trailing slot simply
holds the icons where the price would have been. It puts the actions next to the number they act on,
and against F - which ships today - it hands back the ~44px the PRICE line spends on nothing else.

**Runner-up: E · Beside the identity.** The most robust of the six: the only placement that depends on
no market data at all, so it is pixel-identical on every route and in every state, and the best of the
six at a **single** action, because one glyph after a name is an ordinary shape. Not the pick because
actions beside a title read as being about the title, and the left of the header is where the eye
lands first - which Bridge has not earned.

**Rejected: D · Seventh rail tile.** It fits beautifully at three actions and costs nothing, which is
exactly why it is worth naming. The rail is six facts; a seventh cell of buttons says the buttons are
a seventh fact. It also disappears outright on the no-data page, and the rail re-wraps 6→3→2 by width,
so the action cell would sit somewhere different at every breakpoint.

## Honest note against the recommendation

**A is the tightest of the six on a narrow window.** At 900px the header row carries a 40px logo, a
30px name, two or three 44px circles and a 28px price. E and F both have more room. If the walk shows
A cramped, E is one `Row` away and B is a `Column` away - all three live in the same header.

## Still open

- **The three hardcoded `isGnusWalletConnected: false` call sites** (072 finding 2) still decide the
  count. From Markets the row is **two** icons; if that is an oversight rather than a decision, every
  panel gains a third and A is the placement that feels it first.
- **074-C2 is what ships until this is decided.** It is drawn here as F so the comparison is honest.

## MANIFEST row

```
| 075 | coin-actions-placement | Jakub wants the Receive/Swap icons somewhere other than the PRICE line - above the stat rail, or beside the price top-right. Six placements against the page as it stands TODAY. | **Recommended A · Beside the price** - inside `GWPageHeader.trailing`, icons left of the price block on the same line: **zero new height AND no movement on the no-data page** (the trailing slot just holds the icons instead of the price), which no other placement manages in both directions; against F (074-C2, shipped) it hands back the ~44px the PRICE line spends on nothing else. Runner-up E · beside the identity (the only placement that depends on NO market data, so it is pixel-identical on every route and state, and the best of the six at a single action; rejected because actions beside a title read as being about the title). Rejected D · seventh rail tile (fits beautifully at 3 actions and costs 0px, which is why it is worth naming - the rail is six FACTS, so a seventh cell of buttons says the buttons are a seventh fact; it also vanishes on the no-data page and the rail re-wraps 6→3→2 by width, so the cell would land somewhere different at every breakpoint). **THE FINDING THAT ELIMINATES TWO OF SIX: the stat rail does not exist on the no-data page**, so C (above the rail) and D (in the rail) both vanish or must be re-homed - the same trap that decided 074 against every in-card placement, drawn in red rather than worked around. **This is NOT a re-run of 073**: that sketch's page no longer exists - 071-B added the rail and moved identity+price into GWPageHeader, 074-C2 added the PRICE line - so three of 073's five placements were drawn against changed geometry and two of these six could not have been drawn at all. Honest note recorded: **A is the tightest of the six on a narrow window** (900px puts a 40px logo, a 30px name, 2-3 44px circles and a 28px price on one row); E and F have more room, and all three live in the same header so switching is one Row apart. Still open and it decides the count: the three hardcoded `isGnusWalletConnected: false` call sites mean the row is TWO icons from Markets. | coin-detail, token-info, actions, icon-buttons, page-header, follows-074, follows-073 |
```
