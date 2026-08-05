---
sketch: 030
name: drawer-shell
question: "What is the shared skeleton for every drawer — header, body padding, footer, and how the 420px right panel meets the window edge?"
winner: "B"
tags: [drawers, shell, responsive-drawer, chrome, padding, header, footer]
---

# Sketch 030: Drawer Shell

## Design Question
Every slide-in panel in the app routes through **one** presenter — `ResponsiveDrawer.show()`
(`lib/components/bottom_drawer/responsive_drawer.dart`). On desktop it's a fixed 420px right-edge
panel; on mobile a bottom sheet. The *shell* is fine, but callers supply bodies with no shared
convention, so some (the transaction "Escrow released" panel) pass a bare `ListView` with **zero
horizontal padding** → labels touch the left edge, values slam the right window edge. This sketch
decides the shared skeleton so fixing it once repairs ~19 drawers at once.

## How to View
open .planning/sketches/030-drawer-shell/index.html

## Variants
- **A · Framed (min-fix)** — smallest diff: keep the centered-title AppBar + close-X, add a consistent
  20px content padding and a footer divider. Ports as a `padding` + `Divider` change on the shell.
- **B · Header band + sections** — header becomes its own zone: left-aligned title, close top-right, a
  2px brand hairline under it; detail rows live in a section separated by hairlines, sticky footer.
- **C · Floating inset panel** — the panel detaches from the window edge (16px inset, full 24px radius,
  drop shadow) so it reads as a floating card instead of a slab glued to the far edge. Footer inline.

## What to Look For
- **The edge fix:** in A, compare the padded rows to the screenshot's edge-hugging values.
- **Header weight:** centered (A) vs left-aligned band (B/C) — which frames the panel better on desktop?
- **Edge relationship:** does the floating inset (C) feel more intentional on a wide window, or does the
  full-height slab (A/B) feel more native to a wallet?
- **Footer:** divider (A/B) vs inline button in the scroll body (C).
- Toggle **Dark/Light** (toolbar, bottom-right) — surfaces must hold in both.

## Round 2 — B fine-tunes (chosen 2026-07-23)
Direction **B · Header band** won (left-aligned title, close top-right, full-height, brand hairline).
`index.html` now shows three fine-tunes of B plus a `baseline · chosen B` tab for comparison:
- **B1 · Quiet band** — 1px `--brand-primary-subtle` hairline, title 18px, the CTA gradient lives ONLY on
  the button. The restrained, most reusable shell — used as the wrapper for 031–034 round 2.
- **B2 · Brand-edge band** — a subtle header wash + a 2px **real brandCta** gradient hairline
  (`#0AAEE6 → #0AD89C`), title 20px, footer floats on an elevated surface. The branded take.
- **B3 · Sticky-scroll band** — bare header; a hairline + blur appear only once content scrolls under it.
Pick one — it becomes the canonical `ResponsiveDrawer` chrome for all ~19 drawers.

## Notes
- Whichever wins becomes the canonical shell reused by sketches 031–034 (receipt, list, confirm, receive).
- Sample body is the "Escrow released" receipt so shell differences are legible against the real bug.
- Gradient stops are `--brand-cta-a #0AD89C` / `--brand-cta-b #0AAEE6` (the real `brandCta`), NOT
  brandPrimary/brandSecondary — per the theme note that earlier sketches drew the wrong pair.
