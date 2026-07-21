---
created: 2026-07-21T00:00:00.000Z
title: Chart zoom/pan icons are still raw Colors.white
area: ui
files:
  - lib/chart/crypto_live_chart.dart:455,463,471,480
---

## Problem

Quick task 260721-dws re-skinned the Bitcoin Chart card to sketch 006 A→ and deliberately
KEPT the zoom/pan controls (re-skin-never-restructure — deleting working behavior violates
the port's scope rule) while re-skinning everything around them. That left four
`const Icon(..., color: Colors.white)` on the zoom-in / zoom-out / pan-left / pan-right
`IconButton`s. Keeping the BEHAVIOR did not require keeping the raw color — the icons were
simply not touched during the re-skin.

These are explicitly **NOT** the documented always-dark scrim exception. That exception
covers text sitting over a dark image scrim (e.g. `crypto_news_screen.dart:173,224`), where a
raw light color is intentional because the surface underneath never flips. The zoom/pan icons
sit on the plain card surface instead, so they will wash out and lose contrast in light mode.

This is not a regression — the file was worse before 260721-dws touched it — and it has not
yet been walked in light mode (the light-mode AA pass is deferred, dark-first).

## Solution

Migrate the four icons to an appearance-aware token (`gw.textSecondary` or the equivalent)
during the deferred light-mode AA pass.

**Sequencing constraint:** this todo is linked to
`.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md`. That
todo's step 3 asks whether zoom/pan is redundant once real timeframe ranges are wired — if
zoom/pan is deleted as part of answering that question, this todo dies with it. Settle that
question first; do not spend the light-mode-pass budget re-skinning controls that may not
survive.
