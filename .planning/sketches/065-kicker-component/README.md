---
sketch: 065
name: kicker-component
question: "The uppercase section label exists in five places and was hand-written in every one of them. They agree on weight (w600) and colour (textSecondary) and disagree on size (10/11/13) and tracking (0.4/0.5/0.6/0.7/0.88). What single value serves all five, plus the transaction receipt 154-A adds?"
winner: "C · Two steps - 13 default / 11 dense, no rule. Chosen by Jakub 2026-07-27 as the foundation of the whole drawer language (sketch 066)."
tags: [typography, kicker, section-label, uppercase, components, consistency, drawers, follows-154, follows-030]
lane: execution
---

# Sketch 065: The kicker component

Built when the base-component audit for sketch 154-A found that the uppercase section label
`TRANSACTION` / `NETWORK` had nothing in the app to be written with.

## Correction to an earlier diagnosis

I first claimed that **nothing in the app is set in uppercase**. That was false, and Jakub produced
the counter-example from a screenshot: `TODAY` / `YESTERDAY` in the transaction list. Reading the
code found five such places. The uppercase kicker is **an established convention with no
component**, not new vocabulary - which inverts the decision: the question is not whether to
introduce it, but whether to stop re-typing it.

| Where | px | weight | tracking | colour |
|---|---|---|---|---|
| `TODAY` / `YESTERDAY` - `transactions_slim_view.dart:487` | 13 | w600 | 0.7 | textSecondary |
| `INFO` / `CONVERT` - `token_info_screen.dart:45` | 13 | w600 | 0.4 | textSecondary |
| Markets hero stat captions - `markets_hero_card.dart:260` | 10 | w600 | 0.5 | textSecondary |
| sortable column headers - `markets_table.dart:127` | 11 | w600 | 0.6 | textSecondary / textPrimary when active |
| `VIEW ALL` - `gw_view_all_link.dart:90` | 11 | w600 | 0.88 | white, recoloured by a ShaderMask |

One agreement (w600 + textSecondary), three sizes, five trackings.
`token_info_screen.dart:45` (`_buildSectionTitle`) does **exactly the same job** as the receipt in
154-A: a section title inside a card.

## How to view

```
open .planning/sketches/065-kicker-component/index.html
```

Every variant is shown on **all five surfaces at once**, plus on the new receipt, so "one component"
can be judged rather than assumed. The **Miary** toggle prints the values under each kicker;
**Jasny** exposes the contrast defect described below.

## Variants

| | Variant | Reading |
|---|---|---|
| **0** | **Today** | Five values, no rule. Reference. |
| **A** | **13 / 0.4** | Unify on the token card's value. Cost: the Markets hero grows 10 to 13 and the table headers 11 to 13, and `MARKET CAP` at 13px widens a fixed-width column. |
| **B** | **13 / 0.7** | The same with the transaction list's tracking. Same cost, slightly larger. |
| **C** ★ | **Two steps** | **CHOSEN.** 13/0.5 by default, 11/0.6 behind a `dense` flag. No surface changes dimension. |
| **D** | **Step with a rule** | C plus a `borderSubtle` hairline from the label to the right edge. |
| **E** | **Sentence case** | Rejects uppercase outright. At 13/w600 the label stops being distinguishable from the value row beside it. |

## Decision - C, 2026-07-27 (Jakub)

*"zrób ten C - Dwa Stopnie komponent"*, then, at the 066 review: *"kickers wybraliśmy inny z designu
065 (c)"*.

**The sequence is recorded because the decision moved.** D was picked first - *"zdecydowanie
wybierzmy D i to będzie nasz fundament dla reszty drawerów"*. After the two steps were explained the
pick moved to **C**, and was confirmed a second time during the 066 review. The "foundation for the
rest of the drawers" framing **stands**; what changed is that the foundation is the step itself,
without the rule. Sketch 066 was corrected to C.

One component, one bool, two sizes. A single size cannot serve both roles: at 13px `MARKET CAP`
widens a fixed-width column in the Markets table, and at 11px a section title goes too quiet.
Tracking rises with the step because at uppercase the optical gap between letters grows with size.

Rejected with reasons: **A and B** force a dimension change on two Markets surfaces in order to gain
one number instead of two. **E** reverses a convention working in four places, including the case
identical to the receipt. **D** is drawn and unused - the code carries no `rule` flag because
nothing renders it; if the rule is ever wanted it is one `Expanded` in the same `Row`.

## Specification - built

`lib/components/cards/gw_kicker.dart`

```
GWKicker(String label, {bool dense = false, Widget? trailing})
GWKicker.style(GWColors gw, {bool dense = false}) -> TextStyle

default  13 / w600 / letterSpacing 0.5 / lineHeight 18 / gw.textSecondary / toUpperCase
dense    11 / w600 / letterSpacing 0.6 / lineHeight 16 / same
```

Upper-casing belongs to the component - callers pass natural casing so the label does not lose its
original spelling for screen readers.

## Scope - what the component does NOT cover

Three of the five places are static labels and take the component whole: the day group, the token
card section, the receipt sections. The other two are **interactive** - `GWViewAllLink` (hover to
gradient, underline, arrow) and the sortable column header (active state, direction arrow). They
stay their own widgets and consume only the **text style**. Otherwise the component would have to
grow hover, an active state and two trailing geometries, at which point it stops being a label.

## Contrast

Dark - all pass AA (4.5:1 for normal text):

| `#8A8F9D` on | result |
|---|---|
| `surfaceBase #0B0D12` | **6.02:1** |
| `surfaceElevated #0C0E14` | **5.99:1** |
| `surfaceMenu #171A21` | **5.38:1** |

The drawer panel is the lightest of the three and still has headroom.

## Found along the way - light mode breaks AA in all five places

`textSecondary` is `static const Color(0xFF8A8F9D)` (`genius_wallet_colors.dart:154`) - **not a
getter**, so it does not change with the appearance. On a light card (`#FFFFFF`) it measures
**3.23:1**, and 13px/w600 does not qualify as large text (WCAG's threshold is 18.66px when bold).
This is an inherited defect of all five call sites, not of this component - but the component is now
the single place where it can be fixed once. Per the dark-first rule it does not block this
decision; it goes to the light pass as `gw.textSecondary` with a separate light value.

## MANIFEST row

```
| 065 | kicker-component | The uppercase section label exists in 5 places and was hand-written in every one; they agree on weight (w600) and colour (textSecondary) and disagree on size (10/11/13) and tracking (0.4-0.88). What single value serves all of them plus receipt 154-A? | **C · Two steps** (Jakub 2026-07-27, after a transient pick of D) - 13/0.5 by default, 11/0.6 when `dense`, no rule; declared the foundation of the whole drawer language, see 066. **BUILT** as `lib/components/cards/gw_kicker.dart` + `GWKicker.style()` for the 2 interactive consumers; all 5 call sites migrated, quick 260727-w58. Rejected A/B (force a dimension change on 2 Markets surfaces), E (reverses a convention working in 4 places), D (drawn, unused - no `rule` flag in the code). Found: textSecondary is `static const`, so the kicker measures 3.23:1 in light mode - breaking AA in all 5 places at once. | typography, kicker, section-label, uppercase, components, consistency, drawers, follows-154, follows-030 |
```
