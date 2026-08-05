---
sketch: 068
name: list-picker-drawers
question: "Select Network, SDK Accounts and Your Accounts all do one job - pick one item from a list - and ship three different rows, two different headers and two different footers. None has been looked at since the shell changed. What does one archetype look like on the canvas the drawers took today, and where does it stop being one?"
winner: "A \u00b7 Loose rows - chosen by Jakub 2026-07-28 the same session it was drawn. BUILT in quick 260728-p2m: GWSelectRow promoted from _TokenRow, all four pickers on it, BottomDrawer removed from SDK Accounts, Your Accounts footer to GWButton."
tags: [drawers, list-picker, network, accounts, wallets, components, contrast, wcag, follows-032, follows-066, follows-156, follows-154]
lane: execution
---

# Sketch 068: One list-picker, three drawers

Asked by Jakub on 2026-07-28, straight after the receipt landed: *"co z Select Network / z SDK
accounts oraz Select wallet [...] zaadjustuj je na bazie naszego nowego designu, przestrzegając Base
components rule oraz jak wyglądają faktycznie obecnie drawery, które przed chwilą wprowadziliśmy"*.

This is sketch **066 archetype C** ("List picker") drawn against real code, on the canvas that
shipped the same day.

## How to view

```
open .planning/sketches/068-list-picker-drawers/index.html
```

Four variants × three drawers, each at a real 420px, dark/light. The table beside the panel names the
source component and file of every element on screen, and changes with the variant - which is the
base-components rule made visible rather than asserted.

## What ships today

| | Select Network | SDK Accounts | Your Accounts |
|---|---|---|---|
| header | shell 030-B1 ✓ | **its own** - `BottomDrawer`, centred title, ✕ on the LEFT | shell 030-B1 ✓ |
| row | bare `ListTile`, raw `fontSize: 16/12`, **title colour commented out** | `GWCard` + 2px brand border when selected | `ListTile`, `selectedTileColor: brandPrimaryStrong` |
| selected reads as | **nothing at all** | a thicker border | a solid blue block |
| footer | none | 2 × `GWButton` ✓ | raw `FilledButton.icon`, inline `fontSize: 18`, `iconSize: 28` |

## Findings from the code

1. **Select Network's selected row is invisible.** `_buildDrawerRow` passes
   `ListTile(selected: isSelected)` and nothing else - no `selectedTileColor`, no check, and the
   title's colour is literally commented out (`// color: color`). With no `ListTileTheme` behind it,
   `selected: true` paints nothing. The drawer that exists to show you which network you are on does
   not show you which network you are on.

2. **Your Accounts paints selection as a flat brand fill**, `selectedTileColor:
   GeniusWalletColors.brandPrimaryStrong`. That is the one thing `drawers-final/README.md`'s global
   rule forbids - *"no flat blue as the accent; the accent is the gradient"* - and quick 260721-0ze
   swept the rest of the app for exactly this. This row was missed.

3. **SDK Accounts is not in the shell at all.** It passes no `title` to `ResponsiveDrawer.show` -
   deliberately, with a comment - and renders `BottomDrawer` inside instead, which brings a second
   header with a centred title and the ✕ on the **left**. That was a stand-off before today. **After
   156-A it is a visible defect:** the panel is `surfaceElevated` #0C0E14 and `BottomDrawer` paints
   itself `surfaceMenu` #171A21, so the header is now a lighter block sitting inside its own drawer.

4. **066-C's "no footer - a pick is the action" is wrong for two of the three.** Your Accounts
   carries *Add Wallet*, SDK Accounts carries *Add with mnemonic* + *Add with private key*. The
   archetype needs a footer slot that is allowed to be empty, not a rule that there is none.

5. **`_TokenRow` already solved this and is private.** `token_selector_drawer.dart:206` carries the
   gradient tint, the app-wide hover recipe, the always-present transparent border (so nothing
   twitches by 1px) and the check. It is the row the other three want, and no other file can reach
   it.

## The contrast that decides the selection treatment

Measured on the 156-A panel (#0C0E14):

| boundary | ratio | carries 1.4.11? |
|---|---|---|
| row fill `surfaceMenu` | 1.11:1 | no |
| well fill `surfaceSunken` | 1.04:1 | no |
| hairline `borderSubtle` 12% | 1.30:1 | decorative, no threshold |
| selection tint (`brandCta` at `0x2E`) | 1.39:1 | no |
| selection edge `hoverEdge` (brand 24%) | 1.60:1 | no |
| **check glyph `brandPrimaryStrong` #0AAEE6** | **6.81:1** | **yes** |

**Selection is a state, and 1.4.11 covers states.** The tint and the edge are both under 2:1 - the
same finding sketch 156 made about a field's fill, pointed at a row. Neither can carry selection
alone. The glyph carries it by itself at 6.81:1.

So every variant keeps all three: tint and edge for the eye, glyph for the requirement. Today
`_TokenRow` has all three, SDK Accounts has an icon swap, and the other two have nothing that passes.

## Variants

| | Variant | New components | Reading |
|---|---|---|---|
| **A** ★ | **Loose rows** | **1** - `GWSelectRow`, promoted from `_TokenRow` | The 032-A1 row unchanged, in all three drawers. Free-standing rows, footer slot empty for Select Network. |
| **B** | **Ruled well** | 0 - `GWDetailGrid` + `GWSelectRow` | The receipt's ruled well around the same rows. One frame instead of N borders, denser. |
| **C** | **Grouped** | 0 - B plus `GWKicker(dense)` | B split into *Active* / *All*. 066-C's "kicker separating connected/active from the rest", drawn. |

## Recommendation

**★ A · Loose rows.** It is the only variant that changes the row and nothing else, and the row is
the whole defect: three implementations, two of which cannot show you what is selected. Promoting
`_TokenRow` to `GWSelectRow` deletes two hand-rolled rows and buys the tint, the hover recipe, the
non-twitching border and the check in one move. Token Selector becomes the fourth consumer of its
own row rather than its only one - which is the promotion test 065 used for `GWKicker` and 154 refused
for `_CopyRow`.

**Runner-up: C · Grouped.** It is the best-looking of the three and it answers "which one am I on"
before you read a row. Rejected as the default on cost: two of these lists are three items long, and
a group header above a single row promises a structure the data does not have. It earns its keep the
day a list is long enough to scroll - the network list, if it ever grows past a screen.

**Rejected: B · Ruled well.** Not on looks - on a real mechanic. A scrolling list inside a bordered
box has to decide where the frame lives: inside the scroll viewport, and the frame scrolls away;
outside it, and the list scrolls under its own bottom edge. `GWDetailGrid` was built for a receipt,
which never scrolls, and this is the case that breaks it. **Recording this so the grid is not reached
for again the next time a list needs grouping.**

**All three delete `BottomDrawer` from SDK Accounts** and give it the shell header. That is not a
variant choice, it is finding 3.

## What this does NOT propose

- No change to the per-row `MenuAnchor` ⋮ or to the watched-wallet eye. Both are real affordances
  with real behaviour behind them and neither is drifting.
- No change to what the three drawers *do*. The Hive writes, the toast, the cubit calls and the
  `Navigator.pop(value)` contracts are untouched by every variant.
- Nothing about the light theme beyond rendering it. The `dark-mode-first` rule stands.

## MANIFEST row

```
| 068 | list-picker-drawers | Select Network, SDK Accounts and Your Accounts all do one job - pick one from a list - and ship 3 different rows, 2 different headers and 2 different footers, none looked at since the shell changed. What does one archetype look like on today's canvas, and where does it stop being one? | **Recommended A · Loose rows** (`_TokenRow` promoted to `GWSelectRow`, 1 new component, deletes 2 hand-rolled rows); runner-up C · Grouped (B + dense kicker; rejected as default because 2 of the 3 lists are ~3 items and a group header over one row promises structure the data lacks); **B · Ruled well REJECTED on a mechanic worth remembering - a scrolling list inside a bordered box either scrolls its frame away or scrolls under its own bottom edge, so `GWDetailGrid` does not generalise off the receipt**. **Findings: Select Network's selected row is INVISIBLE** (`ListTile(selected:)` with no theme, title colour commented out); **Your Accounts paints selection as a flat brand fill**, the one thing the global accent rule forbids and which quick 260721-0ze swept everywhere else; **SDK Accounts renders a SECOND header** (`BottomDrawer` inside the shell) which 156-A turned from a stand-off into a visible defect - a `surfaceMenu` block inside a `surfaceElevated` panel; **066-C's "no footer" is wrong for 2 of the 3**. Contrast: selection tint 1.39:1 and brand edge 1.60:1 both fail 1.4.11 for a STATE - only the check glyph (6.81:1) carries it, so all three treatments stay. | drawers, list-picker, network, accounts, wallets, components, contrast, wcag, follows-032, follows-066, follows-156, follows-154 |
```

## BUILT 2026-07-28 - quick 260728-p2m

*"A tak - leć z implementacją z A"*. Built the same session, all four pickers.

`GWSelectRow` took two escape hatches that this sketch did not anticipate, both earned by a real call
site rather than designed in: `titleStyle` (SDK Accounts' title IS an address and wants mono) and
`subtitleStyle` (Your Accounts' subtitle is the address). And two trailing slots rather than one -
`trailing` for information, `action` for an overflow menu - because a balance and a ⋮ belong on
opposite sides of the check glyph.

One thing the sketch did not spot, found while rewiring: **SDK Accounts' `GWCard` row grew a 2px
border when selected**, so the row's own geometry moved by a pixel on each side every time selection
changed. `GWSelectRow`'s always-present constant-width border fixes it, and a test now pins the
width rather than the colour.

**Side effect worth recording: `BottomDrawer` now has exactly one consumer left** - the dev design
gallery, which displays it as a component. It is effectively dead code in the app. Not deleted; that
is its own decision.
