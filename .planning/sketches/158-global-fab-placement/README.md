---
sketch: 158
name: global-fab-placement
question: "The floating swap button's bottom gap is 4x its right gap. Where should it sit - and what does it look like if only the outline is the gradient?"
winner: null
tags: [fab, swap, overlay, placement, spacing, gradient, outline, responsive, contrast]
lane: B
---

# Sketch 158: The global swap FAB - placement and the outline skin

Jakub, 2026-07-27: *"kolko - zmiana lokacji bo gap od dolu i od prawej nie jest rowny, zaproponuj design;
HTML raz zrob jeden gdzie tylko obramowka jest gradient"*.

Two questions, both answered: **placement** (six drawn options) and **skin** (four, switchable from the
toolbar so every window re-skins at once).

## The cause, measured

`lib/components/overlay/global_swap_fab_host.dart:124-128`:

```dart
Positioned(
  right: GeniusWalletConsts.space10,   // = 20
  bottom: 80 + bottomInset,            // "Clears the 60px bottom nav (+ safe-area)"
  child: GWSwapFab(...),
)
```

**20 against 80.** Not a rounding slip - two numbers chosen for two different reasons, and one of the
reasons does not apply on the desktop app:

- The bottom nav it clears is `_MobileTabBar`, mounted **only** by `MobileOverlay`
  (`responsive_overlay.dart:486`). `DesktopOverlay` has no bottom bar; navigation is the top navbar.
  **On macOS the FAB is clearing a bar that is not there** - 60 of the 80 pixels avoid nothing.
- `viewPadding.bottom` is 0 on desktop, so nothing else absorbs the difference.

Second effect, from `gw_swap_fab.dart:56-69`: two `BoxShadow` glows offset `(-2, 6)` and `(2, 6)` with a
24px blur, so the visible mass hangs ~30px **below** the box. That does not rescue the gap; it means the
shape reads ~50px off the floor and 20px off the wall (still 2.5:1) **and** the glow is clipped on the right
at only 20px of clearance while it has 80px of room underneath.

## How to View

```
open .planning/sketches/158-global-fab-placement/index.html
```

Every window is drawn at 1:1 in the corner that matters, with dashed measurement rules (**Measure** toggle).
The **Skin** buttons in the toolbar re-skin every FAB on the page at once, so placement and skin can be
judged independently. Light/Dark toggle included - the skin question has a real light-mode consequence.

## Placement variants

- **P0 · Today** - 20 / 80. The screenshot.
- **P1 · Equal gutter ★** - `right: space10`, `bottom: space10 + barHeight`, where `barHeight` is 0 on
  desktop and 60 on mobile. One rule, one token, both platforms; the mobile value stays exactly the 80 that
  ships today, but derived rather than hardcoded.
- **P2 · Page gutter (24)** - `space12` on both axes. More room for the glow, matches the dashboard's outer
  rhythm.
- **P3 · Optically equal** - 20 right / 26 bottom, paying back the 6px the glow offset pushes down. Correct
  to the eye, arbitrary on paper, and it breaks the moment the glow is retuned.
- **P4 · Mobile, unchanged** - the same rule with the tab bar present, drawn to prove P1 does not regress
  mobile.
- **P5 · Docked to the frame** - the right edge aligns with the page's content column instead of the window.
  At fullscreen the FAB stops floating in the empty margin.

## Skin variants

- **S0 · Today** - filled `brandCta` gradient, `textOnBrand` glyph, dual glow.
- **S1 · Gradient ring ★ (what was asked for)** - transparent centre, 1.5px gradient ring, brand glyph.
- **S2 · Ring + brand tint** - the ring plus a ~10% brand fill so the disc still exists over busy canvases.
- **S3 · Ring + glass** - the ring over a blurred translucent fill.

## The one technical fact this cannot be built without

**A `BorderSide` takes a single `Color`.** No Flutter border can be a gradient - which is precisely why this
project built `GWFocusRing` during Phase 20. A gradient-outline FAB is therefore not a border at all; it is
a gradient-filled circle with an inset circle of surface colour on top:

```dart
Container(                       // the ring
  width: 56, height: 56,
  decoration: BoxDecoration(gradient: GeniusWalletGradient.brandCta, shape: BoxShape.circle),
  padding: const EdgeInsets.all(1.5),
  child: Container(              // the hole
    decoration: BoxDecoration(color: gw.surfaceBase, shape: BoxShape.circle),
    child: Icon(Icons.swap_vert_rounded, color: ..., size: 26),
  ),
)
```

Two consequences, both drawn in the sketch:

1. **The hole is a specific surface colour, so the FAB stops being canvas-agnostic.** It floats over
   `surfaceBase`, over cards (`surfaceElevated`), and over the mesh. S1's hole matches exactly one of those.
   The sketch renders all three side by side; that comparison is the whole decision.
2. **The glyph colour must change.** `textOnBrand #000B18` exists for sitting *on* the gradient. On the dark
   canvas `brandSecondary #2BF5B4` measures ~12:1 and is fine; **in light mode it is ~1.6:1 and fails AA**,
   so the light branch needs the darkened brand-on-surface `#0A6885` the project already uses. Toggle Light
   in the sketch to see it.

## Recommendation

**Placement: ★ P1 · Equal gutter.** The bug is that a mobile constant leaked onto desktop; the fix is to
derive it. One expression replaces the literal `80`:

```dart
final isDesktop = MediaQuery.sizeOf(context).width >= GeniusBreakpoints.medium;
bottom: GeniusWalletConsts.space10 + (isDesktop ? 0 : 60) + bottomInset,
```

That is the same breakpoint `ResponsiveDrawer.show()` already uses, so it introduces no new concept. P2 is
the fallback if 20px turns out to clip the glow visibly at the window edge - judge it on the real screen, not
here.

**P3 is rejected on principle** even though it looks best in isolation: it hard-codes compensation for a
shadow offset, so retuning the glow silently un-centres the button.

**P5 is a separate question, not a rival.** It only matters at fullscreen, and it changes what the FAB is
anchored to. Worth revisiting with sketch 026 (page structure), not here.

**Skin: ★ S1 · Gradient ring, but only after looking at the three canvases.** It is what was asked for and it
is quieter, which suits a control that is present on every screen. Its cost is real and specific: over a
card and over the mesh, S1's hole is a disc of the wrong shade. If that reads badly on the live screen, **S2
· ring + tint** is the same idea with the failure removed, and it is the fallback to take without a second
round.

**S3 · glass** is the prettiest and the most expensive: `BackdropFilter` on a widget that is mounted above
the Navigator on *every* authenticated screen is a per-frame blur that never unmounts. Not worth it for a
56px disc.

## What to Look For

1. **Measure on, compare P0 and P1.** The 80 is the whole complaint and it is one literal.
2. **Switch to S1 and look at the three-canvas row.** Card, base, mesh. If the disc reads as a hole in the
   card, S1 needs S2's tint.
3. **Toggle Light with S1 selected.** The glyph is the thing to watch, not the ring.
4. **P4 exists to prove mobile does not regress.** If P1's derived rule is taken, that window must look
   exactly like it does today.

## Related, found while measuring

The FAB's `_hiddenPaths` (`:36-54`) hides it on `/checkout`, `/checkoutQR`, `/kyc` and `/banxa/callback` -
but **not** on `/buy`, `/createOrder` or `/orderDetails`. So the swap FAB floats over the Buy GNUS order
list, which is visible in Jakub's own screenshot. Whether a swap action belongs over a fiat purchase flow is
a product question, and it is raised in sketch **157** rather than decided here.

## MANIFEST row

Design session, so per `CLAUDE.md` this did not write `.planning/sketches/MANIFEST.md`. Row to append:

```
| 158 | global-fab-placement | The floating swap FAB sits 20px from the right and 80px from the bottom. Where should it sit, and what does it look like if only the outline is the gradient? | _pending pick_ (rec placement **P1 · Equal gutter** - `space10` + a bar height that is 0 on desktop, so the mobile 80 is derived not hardcoded; fallback **P2** at 24; rejected **P3 · optically equal** - hardcodes compensation for a shadow offset. Rec skin **S1 · Gradient ring** with **S2 · ring + tint** as the no-second-round fallback; rejected **S3 · glass** - a permanent BackdropFilter above the Navigator). Findings: `bottom: 80` clears `_MobileTabBar`, which `DesktopOverlay` never mounts, so 60 of the 80 avoid nothing; a gradient outline cannot be a `BorderSide` (one Color) so it is a gradient circle with an inset surface circle, which makes the FAB canvas-dependent; and the brand glyph fails AA in light mode at `#2BF5B4`. Also found: the FAB is NOT hidden on `/buy`, `/createOrder`, `/orderDetails`. | fab, swap, overlay, placement, spacing, gradient, outline, responsive, contrast |
```
