---
sketch: 163
name: swap-settings-track
question: "160-1 is picked. Now the presets move onto the recessed control track, as 162 proposed - what happens to the custom field, and to the state where no preset is selected?"
winner: null
tags: [drawers, swap-settings, control-track, slippage, presets, states, follows-160, follows-162, follows-063]
lane: B
---

# Sketch 163: Swap Settings on the control track

Jakub, 2026-07-27, pointing at 162's slippage card: *"musisz to jeszcze raz redesign troszeczkę i zrobić coś
podobnego, jak tutaj zaprezentowałeś"*.

So: **160-1 stays** (the form wrapped in one 154-A section kicker) and **the three presets move into the
recessed control track**. That change is small; it opens one state question that is not.

## The track, verbatim

`.planning/codebase/CONVENTIONS.md` fixes the recipe and warns that partial adoption reads as a different
design language on the same screen. Used exactly:

| Part | Value |
|---|---|
| Fill | `gw.surfaceSunken` |
| Border | `Border.all(gw.borderSubtle)` hairline |
| Radius | `radiusPill` |
| Track padding | `EdgeInsets.all(3)` |
| Chip gap | `SizedBox(width: 2)` |
| Selected chip | filled `brandCta` gradient, `textOnBrand` |

**One stated deviation:** the dashboard's two tracks use **32px** chips; these are **40px**. The recipe fixes
padding, gap, fill, border and radius - **not chip height** - and a drawer is a touch surface where 40 is the
floor. Same recipe, taller chips. Fallback if it reads as drift on the live screen: 36.

The chips lose their individual 1px borders. That is the visible difference from 160-1: three objects that
happen to be adjacent become one control.

## The state this exposes

**A track is a switch, and a switch always has a position.** Today, typing a custom value leaves **no preset
selected** - fine when the presets were three loose boxes, but an empty well reads as broken rather than as
"custom".

Cycle to **Custom 2%** and compare A with B. That single frame is the whole argument between them.

## Variants

- **0 · 160-1** - what was picked before this round. Reference.
- **A · Track + field ★** - 162's proposal literally: presets in the well, the custom field below as the
  escape hatch 063-A designed it to be.
- **B · Custom slot** - a fourth chip, `Custom`, joins the track; the field appears only when Custom is the
  position. The well always has a position.
- **C · Inline** - track and field on one row, the live value always visible.

## Recommendation

**★ A · Track + field.** It is the change that was asked for and nothing more: one wrapper around the
existing `Row`, the per-chip borders deleted, everything else - validation, message, `GWFocusRing`, footer
`Apply` - untouched. It also preserves 063-A's premise, which is the reason that drawer was redesigned in the
first place: **presets are the primary path and the field is the way out**, in that reading order.

Its one weak frame is the empty well on a custom value. Two ways to close it without taking B:

1. **Leave it.** No preset *is* selected; an unlit track is the truth. This is the cheapest and it is
   defensible.
2. **Light the nearest preset as a "from" state** - no. Do not do this: it would claim a value that is not
   applied. Recorded here so nobody proposes it later.

**Runner-up: B · Custom slot**, and it is genuinely tempting - it removes the empty state entirely and makes
the panel one control instead of two. Its cost is motion: the field appears and disappears with the Custom
chip, so **the drawer changes height as you switch**, and on `High 12%` / `Invalid 0` the validation message
arrives with it. Take B **only if** the empty well reads badly on the live screen; it is a bigger change than
it looks.

**Rejected: C · Inline.** It reads well and it reverses the premise: the field stops being an escape hatch
and becomes a peer of the presets, which is exactly the arrangement 063-A replaced. It also strands the
validation message under a row rather than under the control it belongs to. Worth 20 seconds because the
always-visible value is a real advantage - then leave it.

## What to Look For

1. **Custom 2%, on A and then B.** The empty well against the lit Custom chip.
2. **High 12% and Invalid 0.** Both are `slippageState()` outputs. In B they only exist while Custom is
   active - correct, but watch the panel jump.
3. **0 against A.** Three bordered boxes against one well. This is the whole visual change.
4. **The 40px chips.** Against the dashboard's 32px, on the real screen, side by side if possible.

## Carried forward unchanged

Everything 063-A settled stays: `kSlippagePresets = [0.1, 0.5, 1.0]`, the `0 < x <= 50` bounds with advice
above 5% and below 0.05%, `Apply` disabled when `canApply` is false, the `ValueNotifier` bridge to the footer,
and the description line under the label.

## MANIFEST row

Design session, so per `CLAUDE.md` this did not write `.planning/sketches/MANIFEST.md`. Row to append:

```
| 163 | swap-settings-track | 160-1 is picked; now the presets move onto the recessed control track as 162 proposed. What happens to the custom field, and to the state where no preset is selected? | _pending pick_ (rec **A · Track + field** - the track verbatim per `CONVENTIONS.md`, per-chip borders deleted, field stays below as 063-A's escape hatch, everything else untouched; runner-up **B · Custom slot** removes the empty-well state but makes the drawer change height as the field appears/disappears - take it only if the empty well reads badly live; rejected **C · Inline** - promotes the field to a peer of the presets, reversing 063-A's premise). One stated deviation: 40px chips against the dashboard's 32px, because the recipe fixes padding/gap/fill/border/radius but not chip height and a drawer is a touch surface. **New state exposed: a track is a switch and a switch always has a position** - a custom value leaves the well unlit, which is honest but weak. | drawers, swap-settings, control-track, slippage, presets, states, follows-160, follows-162, follows-063 |
```
