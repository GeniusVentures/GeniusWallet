---
sketch: 162
name: selection-rule
question: "Underline in the nav and the rail reads fine, a fill reads better in the drawers. What is the rule that decides which mark a surface gets - and how many marks should the app have?"
winner: null
tags: [selection, active-state, design-system, rule, underline, control-track, tint, consistency, follows-161, follows-064, follows-022, resolves-handoff-rollout]
lane: B
---

# Sketch 162: Three marks, one rule

Jakub, 2026-07-27, walking the app out loud: *nav bar underline - fine. Transactions filter rail underline -
fine. Swap drawers - "podoba mi się, że ten jest fill cały", and an underline "raczej nie wchodzi w grę".
Feedback chooser underline - works.*

**Those four reactions are not four opinions. They are one rule, and the app has been following it without
writing it down.**

## The rule

**The container decides the mark.**

| The options sit... | Mark | Why |
|---|---|---|
| **on their own** - free-standing labels, nothing around the set | **3px gradient underline** | nothing else groups them, so the mark has to be the mark |
| **in a track** - a recessed pill-shaped well holding chips | **filled `brandCta` chip** | the well already groups them; the mark is a switch position inside it |
| **as rows in a list** - wide rows with an icon, a name, a value | **gradient tint + gradient check** | a solid fill would flood a row; the tint is the fill at row scale |

## It is read out of the code, not invented

- **The underline** is a 25-line `AnimatedContainer` duplicated **verbatim** in
  `responsive_overlay.dart:386` (nav tabs, 002-B) and `submit_logs_screen.dart:713` (feedback chooser,
  064-B). 3px, `brandCta`, rounded top r3, `brandPrimaryStrong` @50% blur 10, 200ms.
- **The track** is a fixed recipe in `.planning/codebase/CONVENTIONS.md`: *"Control track (segmented control /
  filter bar) ... The recipe is fixed - partial adoption reads as a different design language on the same
  screen"* - `surfaceSunken` fill, `borderSubtle` hairline, `radiusPill`, 3px track padding, 2px chip gap.
  It carries a **pairing rule** binding the markets timeframe segment and the transactions filter bar to
  change together.
- **The tint** is `_TokenRowState._selectionTint` (032-A1), `0x2E0AD89C -> 0x2E0AAEE6`, with a `ShaderMask`
  check.

All three already ship. **The rule adds nothing; it just says which one goes where.**

## How to View

```
open .planning/sketches/162-selection-rule/index.html
```

The three rule cards at the top, then **every selection surface in the app** rendered under it. The toolbar
toggles **Under the rule / As it ships today** - only one card changes.

## What changes: one thing

**The slippage presets gain the control track.** They are already a filled `brandCta` chip - the fill Jakub
likes stays exactly as it is - but they sit as three bordered boxes with **no well under them**. Under the
rule they become the **third adopter** of a recipe whose own documentation says partial adoption is the
failure mode. Small diff: wrap the `Row` in the track decoration, drop the per-chip border.

Everything else is confirmed as-is:

| Surface | Mark | Status |
|---|---|---|
| Nav tabs | underline | ships, unchanged |
| Feedback type chooser | underline | ships, unchanged |
| Transactions filter rail | underline | 022-B2, unbuilt - **confirmed** |
| Web tab strip | underline | 036-A, unbuilt - **confirmed** |
| Markets timeframe | filled chip in track | ships, unchanged |
| Transactions filter bar | filled chip in track | ships, unchanged |
| Slippage presets | filled chip in track | **gains the track** |
| Select Token / Network / Account | tint + check | ships, unchanged |

## What it settles

| Question | Answer |
|---|---|
| Vertical bar in the token list? | **No - and no bar at all.** A list row takes the tint, so the mixed-orientation worry disappears rather than being managed |
| Underline anywhere in the drawers? | **No.** Presets are a track, rows are rows. Neither container takes a bar |
| Does 064-B roll out to the transactions filter chips? | **No** - a track keeps its chip |
| ...to the markets timeframe tabs? | **No** - same |
| ...to the web tab strip? | **Yes** - free-standing tabs; 036-A already specified it |
| ...to list pickers? | **No** - confirms the note already in `HANDOFF.json`, now with a reason behind it |
| Is 022-B2 still right? | **Yes** - the rail is free-standing labels with no card and no dividers |
| Sketch 161's S2 leading bar? | **Withdrawn** - see below |

Four of those were open items in `HANDOFF.json` under *"Decide whether sketch 064-B rolls out to the other
tab/segment controls"*. This closes all four with one rule instead of four separate calls.

## Correction to sketch 161

**161's recommendation (S2 · Leading bar) is withdrawn.** It was a good answer to the wrong question: it
solved a geometric collision - a 3px underline landing on a row divider - that **only exists if a list row
takes a bar in the first place**. Under this rule it never does. 161's real value is its measurement of that
collision, which is the evidence for why the underline stops at the edge of a list; the variant board stands
as the record of what was tried.

**`HANDOFF.json`'s "NOT to list pickers" note was right**, and 032-A1's tint was right. What was missing was
the reason, which is what this sketch supplies.

## Why three marks is the right number, not a compromise

The instinct behind "one component everywhere" is sound - it is what stops an app looking like four
designers. But these are not three styles for one job. **They are three answers to three different questions
the user is being asked:**

- **Underline** answers *"which one am I looking at"*. It sits on the item's edge because the item goes on
  existing either way - a tab is still a tab when it is not active.
- **Filled chip** answers *"which position is the switch in"*. The track is a physical metaphor; the fill is
  the thing that moved.
- **Tint + check** answers *"which one did I pick out of many"*. It marks the whole object, and it is the only
  one of the three that has to survive a list of thirty.

A single mark forced across all three would have to be the weakest of them everywhere. The evidence is in the
sketch: under 161-S1 the slippage chips lose their fill, and *"0.5% is applied"* becomes quieter than any
other statement in that drawer.

## What to Look For

1. **The three rule cards.** If the rule is right, each demo should look obviously correct in its own box and
   obviously wrong in the other two.
2. **Toggle "As it ships today".** Only the slippage card moves. That is the size of the whole change.
3. **The filter rail card next to the timeframe card.** Both are "filters", both are mutually exclusive, and
   they get different marks - the rail because it is bare labels, the timeframe because it is a track. If that
   pair reads as inconsistent to you, the rule is wrong and we should talk about it before anything is built.

## Implementation, if the rule is taken

Three shared widgets, two of which are extractions rather than new code:

- **`GWSelectionUnderline()`** - extract the duplicated 25-line `AnimatedContainer` from
  `responsive_overlay.dart` and `submit_logs_screen.dart`. Deduplication regardless of this rule.
- **`GWControlTrack({children})`** - the CONVENTIONS.md recipe as a widget, so a third adopter cannot drift
  from the first two. The pairing rule then holds by construction instead of by a note.
- **The tint** stays inside `_TokenRow` until a second list picker needs it - one consumer does not earn a
  shared token, which is what that file's own comment already says.

`CONVENTIONS.md` should gain a short "Selection marks" section stating the rule; it is the right home,
because the control-track half is already there.

## MANIFEST row

Design session, so per `CLAUDE.md` this did not write `.planning/sketches/MANIFEST.md`. Row to append:

```
| 162 | selection-rule | Underline reads fine on the nav and the filter rail, a fill reads better in the drawers. What rule decides which mark a surface gets, and how many marks should the app have? | _pending pick_ (rec **the container decides the mark**, three marks: free-standing labels -> 3px gradient underline; recessed control track -> filled `brandCta` chip; rows in a list -> gradient tint + check. All three already ship and two are already documented - the underline as a 25-line `AnimatedContainer` duplicated verbatim in `responsive_overlay.dart:386` + `submit_logs_screen.dart:713`, the track as the fixed recipe in `CONVENTIONS.md`. **One change follows: the slippage presets gain the recessed track** they lack, becoming the third adopter of a recipe whose docs say partial adoption is the failure mode; the fill itself is unchanged). Closes four open `HANDOFF.json` rollout questions at once: 064-B goes to the web tab strip, NOT to the filter chips or the timeframe tabs (both tracks), NOT to list pickers. Confirms 022-B2 and 036-A. **Withdraws 161's S2 leading bar** - it solved a collision that only exists if a list row takes a bar, which the rule says it never does. | selection, active-state, design-system, rule, underline, control-track, tint, consistency, follows-161, follows-064, follows-022, resolves-handoff-rollout |
```
