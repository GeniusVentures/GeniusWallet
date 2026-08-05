---
created: 2026-07-21T00:00:00.000Z
title: Bitcoin Chart card has no vertical room at ordinary window sizes — dashboard_screen.dart's height budget, not the chart widget, is broken
area: ui
severity: product-decision
files:
  - lib/dashboard/home/view/dashboard_screen.dart
  - lib/chart/crypto_live_chart.dart:315
  - lib/tokeninfo/token_info_screen.dart:130
---

## Problem

This is the actual root cause behind
`.planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md` (recorded there as an
accepted Phase 5 override, 2026-07-21) and it currently lives nowhere else — filing it here so the
real fix has an owner.

**The chart widget is not the problem. The slot it is given is.** On the dashboard, the Bitcoin
Chart card's inner content Column is handed `h=6.5` and needs roughly `40.5` (the 6.5px it gets plus
the 34px the zoom/pan Row alone requires beyond that). That is not "a bit tight" — it is a slot
smaller than a single line of text.

**Confirmed by direct user inspection, 2026-07-21**, in the running app: *"it's just that the
current size of the app being opened it does not have space for the bitcoin chart, we may want to
drop that size, but again that is a todo item for later, let's close the phase 5 and set it as valid
and continue."*

**Confirmed by comparison, in code.** The same `CryptoLiveChart` widget renders correctly elsewhere:

- **Dashboard** (`dashboard_screen.dart`, `ChartDashboardView`) — inner slot measured **h=6.5** live
  during the 05-08 walk. Broken.
- **Token detail** (`token_info_screen.dart:130`) — desktop path gives it
  `SizedBox(height: constraints.maxHeight - 40)`; mobile path gives it
  `SizedBox(height: maxWidth * 0.6)` (`:500-505`). Both leave the inner slot far above the ~112px
  the widget needs for its chart plus zoom/pan controls. Fine.

The widget is not under-built for its job — it is being asked to render into a slot roughly 6x too
small on the dashboard specifically. The fix is in `dashboard_screen.dart`'s vertical budget for the
Bitcoin Chart card, not in `crypto_live_chart.dart`.

## Why this was not fixed as part of Phase 5

A stopgap (quick `260721-gx1`) considered hiding the zoom/pan row when the slot is too short, and was
planned in detail (a derived 112px threshold, a `showZoomPanControls` predicate, tests proving the
threshold is a real upper bound). It was **deliberately abandoned, not executed** — see
`.planning/quick/260721-gx1-stopgap-the-34px-chart-overflow-by-hidin/260721-gx1-SUMMARY.md`. Hiding
the row would have cleared the RenderFlex overflow but left the card with only a 6.5px hairline where
the chart should be — the stopgap plan's own text called this "a non-overflowing broken card, not a
fixed one." That is a worse outcome than an honest, visible failure: it converts a real defect into
one that looks fixed on a walk but still delivers nothing useful to the user.

The user explicitly deferred the real fix (dashboard card sizing) to a later todo rather than block
Phase 5's closeout on it, and the phase closed with this recorded as an explicit override in
`05-VERIFICATION.md` rather than a pass.

## What needs deciding

This is a product/layout decision, not a mechanical re-skin — it touches `dashboard_screen.dart`'s
overall card-height budget for however many panels sit above/around the Bitcoin Chart card, at
whatever window size the app is normally run at. Candidate directions (not mutually exclusive):

1. **Give the Bitcoin Chart card a real minimum height** in `dashboard_screen.dart`'s layout —
   likely means something else on the dashboard gets less room, or the dashboard gains internal
   scrolling at typical window sizes rather than everything trying to fit unscrolled.
2. **Change the app's practical minimum/default window size** — the user's own words floated this
   ("we may want to drop that size"), but sizing constraints affect every dashboard panel, not just
   this one, so it needs a considered pass, not a quick fix.
3. **Resolve it together with the zoom/pan-row decision** — if the four zoom/pan buttons are deleted
   once real timeframe ranges are wired (see
   `2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md`), the card needs less height to
   begin with (only `minChartHeight` ≈ 64px rather than the full 112px `zoomPanMinSlotHeight`), which
   may be enough on its own without touching `dashboard_screen.dart`'s broader budget.

## Evidence

- Live console trace (05-08 walk, 2026-07-21): `crypto_live_chart.dart:315`'s inner `Column` handed
  `BoxConstraints(0.0<=w<=597.0, h=6.5)`, needs `40.5` (`RenderFlex overflowed by 34 pixels`).
- `token_info_screen.dart:130` gives the same widget a slot of `constraints.maxHeight - 40` (desktop)
  or `maxWidth * 0.6` (mobile) — both comfortably above the ~112px floor the widget needs with
  zoom/pan controls intact, and both walk clean.
- User's direct, live confirmation of the cause, recorded above verbatim.

## Not in scope for this todo

Do not attempt a layout patch inside `crypto_live_chart.dart` itself to solve this — that file
already tried (uhe's compact-price guard) and cannot manufacture height it isn't given. The fix has
to originate in `dashboard_screen.dart`'s allocation, or in a product decision that reduces how much
height the card needs in the first place (deleting zoom/pan).
