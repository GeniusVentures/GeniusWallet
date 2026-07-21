---
created: 2026-07-21T00:00:00.000Z
title: Chart zoom/pan row overflows by 34px — and deleting it closes three findings at once
area: ui
severity: criterion-blocking
files:
  - lib/chart/crypto_live_chart.dart:315
  - lib/chart/crypto_live_chart.dart:453-482
---

## Problem

Observed live on the 2026-07-21 Windows debug walk, on the plain dashboard at ordinary window size,
with no fixture armed:

```
A RenderFlex overflowed by 34 pixels on the bottom.

The relevant error-causing widget was:
  Column  lib/chart/crypto_live_chart.dart:315:26

creator: Column ← Expanded ← Column ← LayoutBuilder ← MouseRegion
       ← CryptoLiveChart ← Expanded ← Column ← Padding ← Padding
       ← DecoratedBox ← Container ← …

constraints: BoxConstraints(0.0<=w<=597.0, h=6.5)
size:        Size(597.0, 6.5)
mainAxisSize: max
```

**The chart's inner Column is handed 6.5 pixels of height and needs ~40.5.**

Cause, confirmed by reading the widget: that Column is
`[Expanded(LineChart), Row(4 × IconButton)]`. The four zoom-in / zoom-out / pan-left / pan-right
`IconButton`s (`:453-482`) are Flutter defaults at 48×48, so the Row alone needs more than the whole
slot. `Expanded` collapses the chart to nothing and the Row overflows by exactly the difference.

**This violates Phase 5 success criterion 5** ("no RenderFlex overflow"). It fires with no fixture,
no mock, no stress case — just the dashboard as a user sees it.

### It is not the old chart overflow, and not a regression of a fix

- The **6.3px** overflow at the old `:206` was real and is **genuinely fixed** by quick `260720-uhe`'s
  compact-mode guard.
- The **19px** overflow was `GWEmptyState`, fixed by quick `260721-e3r` (`2e82ec2`) and walked clean
  on 2026-07-21.
- This **34px** one is a *third*, distinct site. It was present in the 2026-07-20 run's log but was
  recorded as "unattributed" at the time, because Flutter suppresses the creator chain for repeat
  errors and only the first few unique failures get a full dump. It surfaced here because the
  earlier two were fixed, so it became the first error of the run and finally printed its chain.

Its most likely origin is quick `260721-dws`, which re-skinned this file to sketch 006 A→ and added
the coin-identity header, the timeframe segment and the glow hero price — consuming the vertical
budget the zoom/pan row used to have. `dws` carefully made its glow overlay layout-neutral so it
could not re-open `uhe`'s compact-mode overflow, and that reasoning holds; the height went to the
*header* content, not the glow.

## Why this is worth more than a layout patch

**Three separate open findings all point at the same four buttons:**

1. **This overflow** — the Row does not fit its slot.
2. **`.planning/todos/pending/2026-07-21-chart-zoom-pan-icons-still-raw-colors-white.md`** — those same
   four `IconButton`s carry `color: Colors.white` (`:455,463,471,480`), which is invisible on a light
   card. Confirmed unreadable during the 2026-07-21 light-mode walk.
3. **`.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md`** — `dws`'s own
   follow-up asks whether zoom/pan is redundant *by design* once the timeframe tabs (1H/1D/1W/1M/1Y)
   are wired to real ranges, since sketch 006 A→'s visual language replaces zoom/pan with them.

**Deleting the zoom/pan row closes all three.** That is very likely the correct answer, and it is the
one the design already implies.

## Solution

**This needs a product decision first, not a patch.** Zoom/pan is working behaviour that ships today,
and this project's standing rule is *re-skin, never restructure* — deleting a working control is a
deliberate product change, not a layout fix.

1. **Decide whether zoom/pan survives.** Settle it together with the timeframe-ranges todo, since the
   answer to one determines the other. If the timeframe tabs are intended to replace zoom/pan, delete
   the row: overflow gone, raw whites gone, design intent honoured.
2. **If it survives**, then it needs both a layout fix (give the Row its own height, or make it
   adaptive the way `CryptoLiveChart` already handles its compact price mode) **and** the token
   migration from finding 2.
3. **Do not "fix" this by clipping or shrinking the chart further.** The chart is already collapsed to
   zero height in this state — the content that is being lost is the chart itself, which is the point
   of the card.

**Verify in both appearance modes and at more than one window height** — the slot height varies, so a
fix that clears it at one size may not at another. Release builds clip silently where debug paints
stripes.
