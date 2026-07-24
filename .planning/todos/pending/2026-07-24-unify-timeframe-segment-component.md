# Extract one shared GWTimeframeSegment (two identical copies exist)

**Filed:** 2026-07-24

`_TimeframeSegment` + `_TimeframeTab` now exist as **two identical copies**:
- `lib/dashboard/home/view/dashboard_screen.dart:660` (labels `1H·1D·1W·1M·1Y`) — the original.
- `lib/dashboard/chart/markets_hero_card.dart:326` (labels `24H·7D·30D·1Y`) — made byte-identical
  to the dashboard's on 2026-07-24 so the two timeframe selectors look/behave the same (Jakub's ask).

They drifted once (markets used `GWDecorations.surface`, no gradient, no hover-lift) which is exactly
why they should be ONE widget. Extract a public `GWTimeframeSegment({required List<String> labels,
int initialIndex = 0, ValueChanged<int>? onChanged})` (e.g. `lib/components/inputs/` or
`lib/dashboard/chart/`), delete both private copies, use it in both call sites. Deletion, no new
behaviour.

Related: both are still **visual-only** (range not wired to data) — see
`2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md`. Wiring real ranges belongs on the
shared component once extracted.
