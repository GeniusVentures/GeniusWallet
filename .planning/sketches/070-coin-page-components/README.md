---
sketch: 070
name: coin-page-components
question: "Sketch 061 owns the coin page's chrome and leaves the internal layout alone. One layer down: what do the Convert card and the Info card look like when every element maps to a component the app already ships - given two of their defects were fixed elsewhere in the app on the same day?"
winner: "A · On components - chosen by Jakub 2026-07-28 (\"wez A na existing componentach bazowych\"), with the glyph sub-question answered the same day: ONE ACCENT (brandPrimaryOnSurface on all six rows), zero new tokens."
tags: [coin-detail, token-info, convert, detail-grid, text-field, focus-ring, base-components, light-mode, contrast, follows-061, follows-152, follows-154]
lane: execution
---

# Sketch 070: The coin page, on the components the app already ships

Jakub, 2026-07-28, from a live walk with the coin page on screen: *"lets come up with the design
using base components we have to match the rest of the app"*.

## Scope, and what 061 already owns

Sketch **061** answers the *chrome* question for this page - it has no navbar because
`GoRoute('/token-info')` sits outside `ShellRoute`, its header is a Material `AppBar` rather than
`GWPageHeader`, and its frame is 1200-centred rather than the app's 1536 with a 12px gutter. Its
recommendation is **A**, it is still `winner: null`, and **A explicitly leaves the internal layout
alone**. So 070 composes with it instead of competing.

Two things are deliberately **out of scope** because they are already right:

- `TokenActionBar` (`tokens/widgets/token_action_bar.dart`) is a proper component with three real
  states, and Send/Swap are genuinely disabled (D-01/D-02) with More GNUS-gated. It is drawn in the
  "Both + actions" tab for context only.
- `_buildSectionTitle` is already `GWKicker` (migrated in quick 260727-w58).

## How to view

```
open .planning/sketches/070-coin-page-components/index.html
```

Four variants x three views (Convert / Info / both), dark and light, at the right column's real
396px. **The Glyphs toggle is the open question - see below.**

## Findings from the code

**1 · Both Convert fields use the notched Material floating label.** `label:` on the price,
`labelText: "Token Amount"` on the amount (`token_info_screen.dart:527,561`). This is the only
pattern of its kind in the app besides `custom_drop_down.dart`; everywhere else the label sits
**above** the box at `labelMd`/`textSecondary`/`space4`. The field-drift todo filed earlier the same
day names both files.

**2 · Token Amount lights a FLAT `brandPrimaryStrong` on focus.** Visible in the shipped screenshot
as a blue notch and a blue border. This is structural, not an oversight: **a `BorderSide` takes a
single `Color`, so no `InputBorder` can be a gradient** - which is why `GWFocusRing` exists and why
`GWTextField` grew a `focusRing` flag on **2026-07-28** for the SDK dialogs. This screen has the same
defect and was not in that task's scope.

**3 · The Info card is `GWDetailGrid` written by hand.** `_MarketDataInfo.statRow` is padding 11/12,
a 22px leading glyph slot, key at 14/`textSecondary`, value at 14/tabular/`textPrimary` - the
component that shipped the same day for the transaction receipt, minus the recessed well and the
hairline rules.

**4 · Copy-address exists twice, one day apart.** Here it is an inline compact `IconButton` at the
end of the value; the receipt shipped `_CopyRow` with the **whole row** as the target and the glyph
present at rest. Same idea, two implementations, and the smaller target is the older one.

**5 · `Total: $63,504.00` is a bare right-aligned `bodyLarge`** - the one computed result on the
card and the only element with no structure around it.

## The open question: the info glyphs

**Drawn both ways, decided by nobody here.** The code comment records that a single restrained accent
was there first and was replaced with per-row colours *"per user request"*. So this is a measurement,
not a reversal.

**The rainbow was tuned on the dark canvas and collapses on the light one.** Against the light well
(`#CFD4DB`):

| Row | Colour | Dark | Light |
|---|---|---|---|
| Market Cap | `statusSuccess` #0AD89C | 10.80 | **1.25** |
| Circulating Supply | `brandTertiary` #C28FFF | 8.27 | **1.63** |
| Address | `brandPrimaryStrong` #0AAEE6 | 7.84 | **1.72** |
| Total Supply | `statusError` #FF4D4D | 6.13 | **2.19** |
| Volume | `statusNeutral` #64748B | 4.21 | 3.19 |
| Network | `brandPrimaryOnSurface` | 10.25 | **4.23** |

**Network is the tell.** It is the only glyph in the set that flips with the canvas (`#14C8FF` dark
to `#0A6885` light), and the only one that still reads in light mode. The other five are raw
constants. So the choice is not "rainbow or not", it is:

- **(a)** keep the rainbow and give every colour a light counterpart the way `brandPrimaryOnSurface`
  already has one - **five new tokens**; or
- **(b)** one accent, which is `brandPrimaryOnSurface` and is already correct in both modes -
  **zero new tokens**.

**None of this is a WCAG failure.** Every row is fully identified by its label, so the glyphs are
decorative under 1.4.11. It is a legibility question, plus one semantic one: `statusError` red is the
app's error tone and it is being spent on Total Supply, where nothing is wrong.

### Decision - 2026-07-28 (Jakub)

**One accent.** All six glyphs take `brandPrimaryOnSurface`: 10.25:1 dark, 4.23:1 light, and **zero
new tokens**, because it is the one colour in the set that already carries both appearances.

The rainbow was Jakub's own earlier request, so it was shown side by side and measured rather than
reverted - the four-panel comparison in `index.html` is what the decision was made on. The accepted
cost is stated: **the card reads quieter**, and rows lose their per-row colour coding.

Two things fall out of this for free: `statusError` stops being spent on Total Supply, where nothing
is wrong, and the light pass inherits one less item.

## Variants

| | Variant | Convert fields | Info card | Total | Cost |
|---|---|---|---|---|---|
| **A** ★ | **On components** | `GWTextField`, label above, `focusRing` | `GWDetailGrid` + the receipt's copy row | a one-row `GWDetailGrid` | zero new components |
| **B** | **One well** | fields live inside the grid as editable cells | `GWDetailGrid` | the grid's last row | a grid that is no longer read-only |
| **C** | **Minimum** | `GWTextField`, label above, `focusRing` | untouched | untouched | leaves findings 3 and 4 open |

**Findings 1 and 2 are fixed in all three** - they are defects, not design choices.

## Contrast, both modes

| Pairing | Dark | Light | Needs | |
|---|---|---|---|---|
| field edge `borderControl` on the card | 3.30 | 3.11 | 3.0 | pass |
| field edge `borderControl` on a grid well (B) | 3.23 | **2.85** | 3.0 | **FAILS light** |
| label `textSecondary` on the card | 5.97 | 6.30 | 4.5 | pass |
| key `textSecondary` on the well | 6.20 | **4.23** | 4.5 | inherited, see below |
| value `textPrimary` on the well | 20.04 | 12.47 | 4.5 | pass |
| well vs card | 1.04 | 1.49 | - | the hairline separates, not the fill |
| hairline `borderSubtle` on the well | 1.32 | 1.27 | - | decorative, same as the receipt |

**Two measured results decide between A and B.**

**(1) B puts an input inside the grid well, and the field edge fails there in light: 2.85:1 against
3.0.** A control's border is what identifies the control, so 1.4.11 applies at 3:1 - this is a real
failure, not an aesthetic one. B would need a fourth border token to exist. That is what kills it.

**(2) The key text on the light well is 4.23:1, under 4.5.** **Inherited, not introduced here** - the
transaction receipt shipped the same pairing today, so this applies to `GWDetailGrid` everywhere.
Recorded for the dedicated light pass per the standing dark-first order, not fixed in this sketch.

## Recommendation

**★ A · On components.** Closes all four defects with **zero new components** - `GWTextField(focusRing,
fill)`, `GWDetailGrid` and the receipt's copy row all shipped this week and all already have
consumers. The Convert and Info cards end up speaking the same language as the transaction receipt,
which is a screen the user reaches from this same page.

**Runner-up: C · Minimum.** The right answer if the coin page should not be reopened beyond its
defects: it fixes the two things that are actually wrong and touches nothing else, including the
mobile 152-D stacking. Not the pick only because finding 3 leaves a hand-written copy of a component
that exists - the exact drift this week has been spent removing.

**Rejected: B · One well.** The best-looking of the three. The contrast table rejects it: an input
inside the well is **2.85:1 in light**, so it ships a control whose boundary is not identifiable, or
forces a fourth border token into the system to serve one card.

## What this does NOT propose

- No change to `TokenActionBar`, to the chart, or to the page's route/chrome (that is 061).
- No change to which fields the Info card shows - 061 finding 3 already records that
  `CoinGeckoMarketData` carries far more than the six rows displayed.
- The glyph question is **presented, not decided**.

## MANIFEST row

```
| 070 | coin-page-components | Sketch 061 owns the coin page's chrome and its A leaves the internal layout alone. One layer down: what do the Convert and Info cards look like when every element maps to a component the app already ships - given 2 of their defects were fixed elsewhere in the app the same day? | **Recommended A · On components** - `GWTextField(label above, fill, focusRing)`, `GWDetailGrid` for Info, the receipt's whole-row copy affordance, Total as a one-row grid; **zero new components**. Runner-up C · Minimum (fix only the 2 field defects, leave Info hand-written). **Rejected B · One well** - best-looking, but an input inside the grid well measures **2.85:1 in light** against 1.4.11's 3.0, so it would need a fourth border token for one card. **Findings: both Convert fields use the notched Material floating label** (the only such pattern besides `custom_drop_down.dart`); **Token Amount lights a FLAT brandPrimaryStrong on focus** - structural, since a `BorderSide` takes one Color so no `InputBorder` can be a gradient, which is why `GWFocusRing` and the new `focusRing` flag exist; **`_MarketDataInfo.statRow` is GWDetailGrid hand-written** (11/12 padding, 22px glyph slot) days after the component shipped; **copy-address exists twice one day apart** (15px inline IconButton here vs the receipt's whole-row target with the glyph at rest); Total is a bare bodyLarge. **OPEN QUESTION drawn both ways, not decided: the rainbow info glyphs collapse in light mode** - statusSuccess 1.25:1, brandTertiary 1.63:1, brandPrimaryStrong 1.72:1, statusError 2.19:1 on the light well; only `brandPrimaryOnSurface` (Network) survives at 4.23:1 because it is the only appearance-aware one. So: 5 new light-mode tokens, or 1 accent that is already correct. Not a WCAG failure (labels identify every row) but red is spent on Total Supply where nothing is wrong. Also recorded: **key text on the light well is 4.23:1 vs 4.5 - inherited from the receipt, applies to GWDetailGrid everywhere**, deferred to the light pass. | coin-detail, token-info, convert, detail-grid, text-field, focus-ring, base-components, light-mode, contrast, follows-061, follows-152, follows-154 |
```
