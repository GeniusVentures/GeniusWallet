---
created: 2026-07-20T19:46:35.127Z
title: Dashboard live-chart card overflows by 6.3px
area: ui
files:
  - lib/chart/crypto_live_chart.dart:206
  - lib/dashboard/home/view/dashboard_screen.dart
---

## STATUS: fix walked and confirmed 2026-07-20 (pending final 4px re-walk)

Quick task `260720-uhe` landed the fix (`crypto_live_chart.dart` compact-mode price
text + `assert`). Human walk on macOS with 8px spacing: **overflow gone, chart "practically
perfect", nothing clipped** (developer, 2026-07-20). One trailing re-walk pending only because
the spacing token was then reduced 8→4px, which adds chart room and cannot re-introduce the
overflow. Close this todo once the 4px re-walk is confirmed.

## Problem

The dashboard live-chart card paints Flutter's yellow/black striped overflow marker.
User-visible, not just a console warning.

Observed on a fresh `flutter run -d macos --dart-define=GW_DEV_TOOLS=true`, branch
`ui-redesign-port` at `7a95e68`:

```
A RenderFlex overflowed by 6.3 pixels on the bottom.
Column  lib/chart/crypto_live_chart.dart:206:32
creator: Column <- LayoutBuilder <- MouseRegion <- CryptoLiveChart <- Expanded
         <- Column <- Padding <- Padding <- DecoratedBox <- Container
         <- DashboardScrollContainer <- ChartDashboardView
constraints: BoxConstraints(0.0<=w<=368.0, h=37.8)
size: Size(368.0, 37.8), Axis.vertical, spacing 2.0
```

**Confirmed a height problem, not a content problem.** Enlarging the window vertically
makes the stripes disappear (checked interactively 2026-07-20). So the chart's natural
height is fine; it is the room it gets that is short.

**RETRACTED HYPOTHESIS — `gzq` is NOT the cause.** This todo originally blamed quick task
260720-gzq (`655aa93`) for removing 24px of vertical room via `vertical: space6` on the
dashboard ListView. That was wrong, and the planner for quick task 260720-uhe disproved it.
`gzq` remains a clean fix; do not "revert" it.

Why it cannot be `gzq`: the ListView padding `gzq` touched is in the **mobile one-column**
layout, whose sections sit in `ConstrainedBox(maxHeight: 350)` (`dashboard_screen.dart:244`).
That chart card gets exactly 350px regardless of window height, so it cannot overflow — and
"enlarging the window vertically clears it" would be impossible there. Verified in code.

**Actual cause — the price text is inflexible.** `dashboard_screen.dart:385` passes
`priceHeight: 28`, used verbatim as `fontSize` at `crypto_live_chart.dart:214`. `AutoSizeText`
fits to **width, never height**, and a `Column` hands its children unbounded height, so the
price demands `28 × ~1.5 = 42.1`, plus the Column's `spacing: 2` = **44.1** against the 37.8
available. That is the 6.3px, exactly.

The failing layout is the **two-column desktop** breakpoint at roughly 808×500, where the
card's height is proportional to the window — which is why resizing clears it.

**Platform context:** every Phase 5 walk (05-01..05-06 plus 9 quick tasks) was performed on
Windows. This surfaced on the first macOS run. It may be macOS-specific (font metrics differ,
so the price AutoSizeText may resolve taller) or it may simply have been missed on Windows.
Worth asking whoever walked it on Windows whether the stripes were visible there.

## Solution

TBD — pick one, do not stack them:

1. Give the chart the 6.3px back: reduce the `vertical: space6` the `gzq` task added, or
   apply it only where the shadow clipping it fixed actually occurred (that fix targeted the
   mobile one-column layout).
2. Let the chart shrink: wrap the price `AutoSizeText` so it gives up height under pressure,
   or drop the `Column`'s `spacing: 2` when height is constrained — `crypto_live_chart.dart`
   already branches on `isHeightBounded`, so the hook exists.

Option 1 risks re-opening the clipped-shadow bug `gzq` closed. Option 2 is contained to the
chart. Check both layouts (mobile one-column and desktop multi-column) whichever is chosen.
