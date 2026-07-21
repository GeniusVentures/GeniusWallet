---
sketch: 008
name: hover-language
question: "What is the ONE hover treatment that makes nav tabs, timeframe tabs, and VIEW ALL feel like one interactive system?"
winner: null
tags: [hover, interaction, chrome, navbar, timeframe, consistency]
---

# Sketch 008: Unified hover language

## Design Question

Three interactive chrome elements currently hover **inconsistently**:

- **Nav bar tabs** — active tab has a green→blue gradient underline; inactive hover ≈ color/subtle fill.
- **Timeframe tabs** (chart) — selected = brand gradient chip; inactive just got a raise-onto-surfaceElevated hover.
- **VIEW ALL** (Markets header) — **no hover state at all**.

What single hover treatment, applied to all three, makes them read as one system — while VIEW ALL
(a one-shot navigation link) still doesn't imply a persistent selected state?

## How to View

`open .planning/sketches/008-hover-language/index.html` — toggle the **hover treatment** (A/B/C/D)
and **theme**, then actually hover the inactive nav tabs, inactive timeframe tabs, and VIEW ALL. The
active nav tab and the selected 1D keep their gradient so hover-vs-selected reads in context.

## Variants

- **A · Soft fill** — hover raises a subtle surface fill + label → text-primary. Calmest; what the timeframe tabs do today. Familiar "pressable surface".
- **B · Gradient underline** — hover grows a thin green→blue gradient underline: the *same* gradient the active nav tab uses. Hover becomes a lighter echo of "selected". Strongest system coherence.
- **C · Brand tint** — hover shifts label/icon to brand cyan only, no fill/motion. Most minimal. **a11y:** raw cyan is ~2–3:1 on white — a Flutter port must darken it in light mode.
- **D · Lift chip** — hover turns the element into a raised chip (elevated surface + card shadow + 1px lift). Most tactile; hover and press share a material with the gradient chip / Buy GNUS.

## What to Look For

- **Coherence with what's already selected.** B makes hover and selection speak the same gradient language; A/D lean on surface; C on color. Which reads as "one system"?
- **VIEW ALL as a link, not a toggle.** Does the treatment make VIEW ALL feel clickable *without* looking like it could be a persistent selected state? (B's underline and C's tint stay "link-like"; A/D's fill/chip lean more "button".)
- **Light-mode legibility.** C's cyan tint is the risky one — check it in light. A/B/D all keep an AA-safe resting label.
- **Restraint vs feedback.** C is quietest, D loudest. The nav bar is dense — does the treatment stay calm across a full row of tabs?
- **The nav underline nit:** the active underline here is lowered (`bottom: 2px`) so it clears the icon — confirm it no longer almost-overlaps.

## Not decided here

Pick one treatment (or a hybrid — e.g. **B**'s gradient underline for nav + link elements, **A/D**'s
surface for the segmented timeframe). Implementation is a **separate GSD task** touching the nav
(parallel session's `responsive_overlay.dart`), the timeframe (`dashboard_screen.dart`), and the
Markets VIEW ALL. Tokens only; AA-safe pairings in both modes.
