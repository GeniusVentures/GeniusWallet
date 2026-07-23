---
phase: 07-token-screens
plan: 02
subsystem: token-chart
tags: [lifecycle, setState, mounted-guard, crypto-chart]
requires: []
provides:
  - "token chart post-await setState calls guarded against setState-after-dispose"
affects:
  - lib/chart/crypto_live_chart.dart
tech-stack:
  added: []
  patterns:
    - "if (!mounted) return; before every post-await setState in a State"
key-files:
  created: []
  modified:
    - lib/chart/crypto_live_chart.dart
decisions:
  - "Placed the guard immediately before each setState (matching plan) rather than right after the await, keeping the change to exactly 2 inserted lines"
metrics:
  duration: ~4m
  completed: 2026-07-23
  tasks: 1
  files: 1
requirements: [SCR-03]
status: complete
---

# Phase 7 Plan 02: Token Chart Lifecycle Guard (Finding 24) Summary

Added `if (!mounted) return;` ahead of the two unguarded post-`await` `setState` sites in
`lib/chart/crypto_live_chart.dart` — the `_fetchHistoricalData` success path and the
timer-driven `_addNewPricePoint` — so leaving the token chart mid-fetch or during its
1-minute refresh tick no longer risks a `setState after dispose`. Pure lifecycle
correctness fix; the Phase 5 redesign skin was not touched.

## What Was Built

- **`_fetchHistoricalData` success branch** (inside `if (historicalPrices.isNotEmpty)`,
  after `await fetchHistoricalPrices(...)`): inserted `if (!mounted) return;` immediately
  before the `setState(() { ... })`.
- **`_addNewPricePoint`** (reached from the periodic `Timer` after
  `await fetchCoinsMarketData(...)`): inserted `if (!mounted) return;` as the first line,
  before its `setState(() { ... })`.

Net change: 1 file, +2 lines. `dispose()` still cancels the timer as-is. No visual, color,
layout, zoom/pan, timeframe, hover, tooltip, or data-fetch behavior changed. The 4 residual
raw `Colors.white` on the zoom/pan IconButton row were left untouched (tracked separately).

## Verification

- **`<verify>` grep gate:** `rg -c "if \(!mounted\) return;" lib/chart/crypto_live_chart.dart`
  = **2** → PASS ("both post-await setState sites guarded"). No pre-existing guard was present
  in the file (contrary to the plan's "may be ≥2" note); the two new guards bring the count to
  exactly 2, satisfying the `-ge 2` gate. No failures to quote.
- **`flutter analyze lib`:** **61 issues** — exactly the 61 baseline, no regression. The only
  reported items are pre-existing (`avoid_print` / `unused_element` in
  `lib/web/web_view_mobile.dart`), unrelated to this change.
- **Runtime proof of finding 24 is deferred to the 07-03 walk** (console watch on leaving the
  chart mid-fetch). No automated widget test was written: `_fetchHistoricalData` /
  `_addNewPricePoint` call top-level CoinGecko network functions directly (non-injectable), so
  a mount-then-dispose test would be network-flaky. No synthetic PASS was fabricated.

## Deviations from Plan

None — plan executed exactly as written. (Observation, not a deviation: the file had zero
pre-existing `if (!mounted) return;` guards; the two added satisfy the `-ge 2` gate cleanly.)

## Commits

- `35fef28` — fix(07-02): guard the token chart's two post-await setStates (finding 24)

## Self-Check: PASSED

- FOUND: lib/chart/crypto_live_chart.dart (2 guards present)
- FOUND: commit 35fef28
