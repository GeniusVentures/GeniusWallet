# Dashboard Bitcoin-chart RenderFlex overflow (33px) — pre-existing, Phase-5/dashboard

**Found:** 2026-07-24, during the Phase-7 token-screens 07-08 re-walk (console watcher caught it at boot).
**Scope:** NOT Phase 7. Pre-existing dashboard code (Phase 5). Logged here to keep the Phase-7 re-walk clean.

## Symptom
At app boot (dashboard is the landing route), the console throws:
`A RenderFlex overflowed by 33 pixels on the bottom.` (repeats)

## Location / evidence
- Overflowing widget: `lib/chart/crypto_live_chart.dart:356` (the chart's internal Column), squeezed to h=7.5 by its parent Expanded.
- Creator chain: `CryptoLiveChart ← Expanded ← Column ← Padding ← Padding ← DecoratedBox ← Container` at width ~597.
- The `const Expanded(child: CryptoLiveChart(...))` is `lib/dashboard/home/view/dashboard_screen.dart:542-543` — the dashboard Bitcoin chart card gives the chart an Expanded whose height, in some state, drops below the chart's internal min content (~40px), overflowing by ~33px.

## Why it's not Phase 7
- `dashboard_screen.dart` was last modified by Phase-5 commits (2d18b85, 64fa92d, 3364259) — no Phase-7 gap-closure commit touches it.
- `crypto_live_chart.dart`'s only Phase-7 change (07-02, 35fef28) was a `setState`-after-dispose guard, not a layout change.
- The token-detail screen wraps its chart in a `SizedBox` (fixed height, sketch 152) — a different shape; it is not the source of this trace.

## Likely fix (for a dashboard/Phase-5 pass — do NOT fold into Phase 7)
Give the dashboard chart card a floor height (or the chart area a min-height / `ClipRect`) so the chart's internal Column can't be squeezed below its min content. Mirror the token-screen fix (`token_info_screen.dart` cd2431a: floor the chart height) but in `dashboard_screen.dart`. Respect the Phase-5 chart-ownership fence — size from the dashboard side, don't edit `crypto_live_chart.dart`.
