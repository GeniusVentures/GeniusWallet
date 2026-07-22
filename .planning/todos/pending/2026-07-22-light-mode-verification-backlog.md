---
created: 2026-07-22T06:40:00.000Z
title: Light mode is backlog — dark ships first, light gets one dedicated pass
area: ui
files:
  - lib/dashboard/home/widgets/transactions_slim_view.dart
  - lib/dashboard/home/widgets/transaction_badge.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - .planning/phases/12-transactions-redesign/12-06-PLAN.md
---

## The policy (confirmed by the user 2026-07-22)

**Dark mode is what ships and what gets walked. Light mode is backlog.** Do not stall a phase, a
walk, or a plan on a light-mode-only defect — record it here and keep going. Light gets **one
dedicated pass** across the whole app rather than being re-litigated panel by panel.

This is not "light mode does not matter": every colour decision is still required to clear WCAG AA
in **both** appearances, and that is enforced by unit tests where it can be. What is deferred is the
**visual walk** — the human judgement of whether light mode looks right, as opposed to whether it
measures right.

## Why record it now

Phase 12 (transactions redesign) shipped its implementation with **zero human verification in light
mode**. The whole of 12-06's walk is outstanding, and light was never opened. The same is true of
several earlier phases. Rather than each phase carrying its own quiet light-mode debt, it is
collected here.

## Known light-mode items outstanding

Carried forward from the Phase 12 summaries — these are measured, not guessed:

1. **Active filter chip's gradient fill: 1.65:1 / 2.28:1 against the light bar surface.**
   WCAG 1.4.11 wants 3:1 for a UI component boundary. Deliberately not changed by the executor,
   because "active = brandCta gradient" is a locked user decision and the ink glyph carries the
   state at 10.66:1. **This one is a design call for the user, not a bug to fix silently.**
   (`transactions_slim_view.dart`, `_FilterChip`.)
2. **Active overflow-menu label** already degrades correctly: `brandCta`'s own stops measure 1.65:1
   and 2.28:1 as text on the light `surfaceMenu`, so `_activeLabelShader` collapses to a flat
   `brandPrimaryOnSurface` (#0A6885, 5.61:1) on light. Verify this reads as intended, not as a
   "missing gradient".
3. **Day-header contrast in light mode is unmeasured** — no test asserts it
   (`transactions_slim_view.dart`, the day label).
4. **`GWButton` secondary label contrast (1.93:1)** — an inherited defect first recorded during
   06-01, visible on the Legal step's two link buttons. Belongs to `gw_button.dart`, not to any
   consuming screen.
5. **`statusWarning` (#FFC42E) is not appearance-aware** — it exists only as a static in
   `genius_wallet_colors.dart:178`, not in the `GWColors` extension. Safe as a badge FILL with a
   knocked-out glyph (which is how Phase 12 uses it); would fail AA as text on white at 1.7:1.
   Anywhere it becomes text, it needs a light-safe sibling.
6. **The badge palette is measured but never seen in light.** All 9 kinds clear 4.5:1 in both
   appearances by unit test, and three of them (`received`, `purchase`, `failed`) flip their glyph
   from ink to white between appearances — which is why the glyph colour is computed rather than
   tabled. Nobody has looked at whether that flip reads well.

## What "the light pass" should be

One walk, whole app, light mode only, with this list in hand — not a per-phase gate. Until then, a
light-mode finding is a note in this file, never a blocker.

Related: the standing preference is recorded in the assistant's memory as
`dark-mode-first-light-later`.
