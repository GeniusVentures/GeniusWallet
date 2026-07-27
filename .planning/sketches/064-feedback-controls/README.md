---
sketch: 064
name: feedback-controls
question: "The Feedback type chooser has no hover at all and a FLAT mint accent. Both break a standard the project already decided. What does it look like when it carries the app's own language - and what about the Message field's border and the rail's title while we are here?"
winner: "B"
tags: [feedback, logs, submit-logs, segment-control, tabs, hover, gradient, focus-ring, follows-044, follows-030]
lane: execution
---

# Sketch 064: Feedback controls

Built during Phase 20's execution, after Jakub walked the page and asked three
questions at once. Three separate design questions, three tabs, one file.

## Design Question

The Feedback page shipped three controls that each contradict a decision the
project had already made:

1. **The type chooser** (`Bug` / `Idea` / `Question`). It has **no hover state
   at all**, while sketch **044** declares one app-wide hover recipe - brand
   tint 12% plus a brand hairline at 24%, no geometry. And its active segment
   is a **flat mint fill**, while `drawers-final/README.md` rules that the
   accent is the **gradient** (`brandCta`), never a flat brand colour.

2. **The Message field's border.** It sits at rest in the same weight it sits
   at when focused, so focus is invisible - and the app-wide `focusedBorder` at
   `theme.dart:242` paints it a flat blue that appears nowhere else in the
   redesign.

3. **The rail's title.** "What gets sent" reads like a customs declaration and
   never says the thing the user cannot know.

## Variants

### Tab 1 · Segment

| | Variant | Reading |
|---|---|---|
| **0** | **Dziś** | The shipped control, for comparison. Flat mint at 16%, a `#0AD89C` border, zero hover. |
| **A** | **Tor + gradientowa pigułka** | Track keeps its box; the active segment becomes a filled gradient pill with `textOnBrand`. Loudest of the four. Reads as a button, not a tab. |
| **B** ★ | **Gradientowe podkreślenie** | **CHOSEN.** The box dissolves to a single bottom hairline; the active segment carries a gradient underline. This is the **nav bar's exact active-tab language**, which is the argument: the app already has a word for "this one is selected", and it is this one. |
| **C** | **Tint + gradientowa włosowa krawędź** | Sketch 044's hover recipe promoted to the active state. Consistent, but it makes hover and active nearly the same picture - the control loses its ability to say which is which. |
| **D** | **Sam tekst** | Weight and colour only, no chrome. Quietest; fails at a glance on a page whose whole job is a form. |

**Recommendation: B.** Runner-up **C**, for consistency with 044 - rejected only
because hover and active collapse into one another. Rejected **A**: a filled
gradient pill is the CTA's language, and this control is not a CTA.

### Tab 2 · Pole Message

The field wears a **gradient focus ring** at 1.5px, transparent at rest. A
`BorderSide` takes a single `Color`, so this can never be an `InputBorder` - it
has to be a sibling layer. The ring reserves its width in **both** states, so
taking focus does not nudge the field's content.

The label moves **above** the field, matching `GWTextField` - the app's own
component, used by Settings, Markets search, the account manager and onboarding
across 7 files. Feedback used a raw `TextField(labelText:)`, which picks up
`theme.dart`'s `floatingLabelBehavior: always` and notches the label into the
outline, where it collides with the border.

The placeholder is `textPrimary38` and **italic**, because at full weight it
read as text the user had already typed.

### Tab 3 · Tytuł szyny

"What gets sent" → **"Attached automatically"**. It carries the one thing the
user cannot know - that they need do nothing - and recovers the sense of the
deleted "SDK logs attached automatically" header without the word *SDK*, which
means nothing to someone reporting a bug.

## Findings

- **Sketch 044's "one app-wide hover recipe" never rolled out.** At the time
  this sketch was built, `GWDecorations.hover()` was used in exactly **one**
  place in the entire app. Implementing B took it to two.
- **A `BoxDecoration` carrying a border INSETS its child.** Animating from no
  border to a 1px border twitches the label by exactly 1px. The border must be
  present in both states with only its colour changing. **The nav tabs carry
  this same latent bug.**
- **A `Stack` hands non-positioned children LOOSE constraints**, so a `Text`
  inside one shrink-wraps and `textAlign: center` centres nothing. Every label
  sat flush left while the underline spanned the full segment.

## Outcome

**B implemented** in `lib/logs/submit_logs_screen.dart` as part of Phase 20:
3px `brandCta` underline, rounded at the top, `brandPrimaryStrong` glow at 50%
/ blur 10, 200ms, with `GWDecorations.hover` on the inactive segments.

Jakub's instruction on picking it: *"to powinno być standardem"* - so the open
question this sketch leaves behind is whether B rolls out to the transactions
filter chips, the markets timeframe tabs and the web tab strip. It does **not**
roll out to list pickers; sketch **032-A1** decided those separately and
differently.
