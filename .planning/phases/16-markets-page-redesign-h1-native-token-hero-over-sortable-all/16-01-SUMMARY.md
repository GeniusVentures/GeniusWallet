---
phase: 16-markets-page-redesign-h1-native-token-hero-over-sortable-all
plan: 01
subsystem: dashboard/chart
tags: [markets-page, native-token-hero, sortable-table, sketch-103-h1, fl-chart, dark-only, retroactive]
type: execute
requires:
  - "sketch 103 · H1 'Refined split' design contract (16-CONTEXT.md)"
  - "existing getMarketCoins() + fetchCoinsMarketData() chained fetch (no new data path)"
  - "existing CoinGeckoMarketData model (all fields already present)"
provides:
  - "the redesigned /markets page: native-token hero over a sortable All Markets table (MK-01..MK-09)"
retroactive: true
retroactive_note: >
  RETROACTIVE RECORD. This summary documents code that ALREADY SHIPPED outside the
  GSD plan/execute flow — committed directly in `aa78eec` (2026-07-23) and iterated
  live with Jakub on 2026-07-24. It was written after the fact (alongside 16-01-PLAN.md)
  so gsd-tools registers Phase 16 as implementation-complete. The code exists and is
  verified (16-VERIFICATION.md, 9/9). This file is documentation only and is itself
  uncommitted; it creates NO commit and touches NO `lib/` file.
affects:
  - lib/dashboard/chart/markets_screen.dart
  - lib/dashboard/chart/markets_hero_card.dart
  - lib/dashboard/chart/markets_table.dart
  - lib/dashboard/chart/markets_sort.dart
  - test/markets_sort_test.dart
key-files:
  modified:
    - lib/dashboard/chart/markets_screen.dart
  created:
    - lib/dashboard/chart/markets_hero_card.dart
    - lib/dashboard/chart/markets_table.dart
    - lib/dashboard/chart/markets_sort.dart
    - test/markets_sort_test.dart
commit: aa78eec
walk:
  date: 2026-07-24
  walker: Jakub
  build: flutter run -d macos --dart-define=GW_DEV_TOOLS=true (Flutter 3.41.9)
  mode: DARK ONLY (light deferred to the app-wide light pass)
  verdict: approved ("super")
decisions:
  - "Sketch 103 winner H1 'Refined split' shipped: native token (genius-ai) pulled out of the table and given a hero card above a CoinGecko/CMC-style sortable All Markets table."
  - "No new data / API / model — every field reads off the already-fetched CoinGeckoMarketData; the two chained fetches (coins, then market data) are unchanged."
  - "Ordering lives in a pure, Flutter-free comparator (compareMarketRows) so it can be tested without pumping a widget; 5/5 passing."
  - "Timeframe selector is visual-only and the 1h%/7d% columns are honest `-` placeholders — both carry ponytail: comments (no ranged data on the model; upgrade path = the wire-real-ranges todo). No fabricated numbers."
  - "Light NOT walked (standing dark-first project decision). Recorded as deferred, not passed."
status: complete
---

# Phase 16 Plan 01: Markets page redesign (sketch 103 · H1) — Summary

> **RETROACTIVE RECORD.** This documents work that shipped OUTSIDE the GSD plan/execute flow —
> committed directly as `aa78eec` (2026-07-23) and iterated live with Jakub on 2026-07-24. The code
> exists and is verified (16-VERIFICATION.md = passed, 9/9). This summary and its sibling
> 16-01-PLAN.md were written after the fact so gsd-tools registers the phase as
> implementation-complete. **No commit is created by this documentation, and no `lib/` file is
> touched.**

`/markets` was re-skinned to sketch 103 **H1 "Refined split"**: the native token (GENIUS AI,
`genius-ai`) is pulled out of the market list and shown as a hero card — identity, oversized 48px
price, change pill, a 2×2 stat block, and a 7d brand-gradient chart — over a CoinGecko/CMC-style
sortable "All Markets" table. The data path did not change: the page keeps its two chained fetches
(coins, then market data), each with its own error/retry, and reads every field off the existing
`CoinGeckoMarketData`. No new API, model, or Hive box.

Built in the `../GW-markets` worktree on branch `redesign/markets-tab-260723`, committed into the
tree as **`aa78eec`**, then polished live with Jakub on **2026-07-24** (six changes, below).

## Shipped files

| File | Lines | Role |
|------|-------|------|
| `lib/dashboard/chart/markets_screen.dart` | 225 | Rewritten page — chained fetch → hero + `GWSectionTitle('All Markets')` + table in a scroll column; per-fetch error/retry; Expanded-bounded states; wired at `/markets` |
| `lib/dashboard/chart/markets_hero_card.dart` | 551 | Native-token hero (H1 refined split) — identity / 48px price / change pill / 2×2 stats / 7d gradient chart / timeframe selector; responsive Row→Column |
| `lib/dashboard/chart/markets_table.dart` | 388 | Sortable table — header + data rows, sort via the pure comparator, row→`/token-info`, horizontal scroll below `_minTableWidth`, 7d sparkline |
| `lib/dashboard/chart/markets_sort.dart` | 58 | Pure Flutter-free core — `kNativeMarketCoinId`, `MarketSort`, `MarketRowData`, `compareMarketRows` |
| `test/markets_sort_test.dart` | 71 | The one runnable check — exercises `compareMarketRows` directly; **5/5 passing** (2026-07-24) |

## Per-requirement verdict (MK-01..MK-09)

| Req | What | Verdict | Evidence (shipped code) |
|-----|------|---------|-------------------------|
| MK-01 | `/markets` renders the new hero-over-table layout, not the old flat grid | **PASS** | `router.dart:237` `/markets`→`MarketsScreen`; `markets_screen.dart:199-213` builds `MarketsHeroCard` + `GWSectionTitle('All Markets')` + `MarketsTable` in a scroll column |
| MK-02 | Native token pulled OUT of the table, shown as the hero | **PASS** | `markets_sort.dart:5` `kNativeMarketCoinId='genius-ai'`; `markets_screen.dart:160-180` selects `featuredCoin`, `continue`s it out of `rows` (173), `hasHero` gates the card (202) |
| MK-03 | Hero: identity + 48px price + %-pill + absolute 24h change | **PASS** | `markets_hero_card.dart:49-68` icon(46)+name; `:73-86` fixed 48px price; `:92` `_ChangePill`; `:94-102` `${absChange} · 24h` |
| MK-04 | Hero 2×2 stat block: Rank · Market Cap · Volume 24h · ATH | **PASS** | `markets_hero_card.dart:109-121` Rank · Market Cap · Volume 24h · All-Time High |
| MK-05 | Hero 7d brand-gradient area chart + visual timeframe selector, responsive Row→Column | **PASS** | `_HeroChart` gradient line + `belowBarData` area gradient (`:334-351`); `_TimeframeSegment` 24H/7D/30D/1Y (`:138-139`); `LayoutBuilder` wide `IntrinsicHeight` Row vs narrow Column (`:147-179`) |
| MK-06 | Table renders the column set (#/Coin/Price/24h%/Market Cap/Volume/7d spark) | **PASS** | `markets_table.dart:169-182` header cells; `:206-321` data cells; `_MiniSpark` (`:310-320`, `357-388`). 1h%/7d% are honest `-` placeholders |
| MK-07 | Sortable headers; ordering correct | **PASS** (test-backed) | `markets_table.dart:66-77` `_onHeaderTap`; `:82-83` sorts via `compareMarketRows`; pure comparator test **5/5** (`markets_sort_test.dart`) |
| MK-08 | Row tap → `/token-info` with coin + market data | **PASS** | `markets_table.dart:193-194` `InkWell.onTap→onTapRow`; `markets_screen.dart:58-63` `context.push('/token-info', extra:{marketData,coin})`; route exists `router.dart:244` |
| MK-09 | Table scrolls horizontally when too narrow (no column crush) | **PASS** | `markets_table.dart:93-108` `LayoutBuilder` → below `_minTableWidth` wraps table in a horizontal `SingleChildScrollView` at fixed width |

**9/9 PASS.** Sort (MK-07) is behaviour-dependent but backed by the passing pure-comparator test the
table consumes directly, so it is verified, not present-only.

## Live-polish pass (2026-07-24, with Jakub)

Six changes made while Jakub walked the page in dark mode; all in the shipped code, all analyze-clean:

| Change | Evidence |
|--------|----------|
| Hero chart bottom-aligned to the Volume/ATH row via a single empty `Spacer` (only flex child — avoids intrinsic-measuring fl_chart) | `markets_hero_card.dart:141` `if (fill) const Spacer()` |
| Hover tooltip on the hero chart (time + price + % vs window start) | `markets_hero_card.dart:356-418` `LineTouchData`, `timeAt` maps index→last-7d |
| Sparkline column right-aligned | `markets_table.dart:310-320` `Align(centerRight)` around the fixed 72px spark |
| Gradient sort arrow | `markets_table.dart:133-138` `ShaderMask` with the `brandCta` gradient over ↑/↓ |
| Page vertical scrollbar hidden | `markets_screen.dart:187-188` `ScrollConfiguration(scrollbars:false)` |
| `RepaintBoundary` around the hero card (kill hairline flicker) | `markets_hero_card.dart:187` `RepaintBoundary` wraps the card |

## Known simplifications (ponytail)

- **Timeframe selector is visual-only** — only the 7d sparkline exists. `markets_hero_card.dart:424-480`,
  `ponytail:` comment, tied to `2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart`.
- **1h% / 7d% columns render `-`** — `CoinGeckoMarketData` has no 1h/7d %; the columns show a
  marked-absent `-`, never a fabricated number. `markets_table.dart:175,177,264,287,331`, `ponytail:`
  with ceiling + upgrade path. The one sortable change column (24h%) carries real data.
- **Coins with no market data are hidden** (`markets_screen.dart:176`), mirroring `DashboardMarkets`.

## Verification & gates

- `flutter analyze` on all five files: **No issues found**.
- `flutter test test/markets_sort_test.dart`: **5/5 passing** (2026-07-24).
- No new data / API / model; the two chained fetches are unchanged.
- Full record: `16-VERIFICATION.md` (passed, 9/9 must-haves, 0 overrides).

## Human verification

- **Dark mode — DONE.** Jakub walked `/markets` live on 2026-07-24 and approved it ("super"): hero
  split at wide/narrow, table sort, horizontal scroll, hover tooltip.
- **Light mode — DEFERRED** to the app-wide light pass (standing dark-first decision). Not a blocker.

## Follow-ups (non-blocking)

1. **Doc housekeeping** — add the sketch-103 winner (H1) row to `.planning/sketches/MANIFEST.md`
   (line 55 still reads "_pending pick_"). Documentation only, no code impact.
2. **Light-mode walk** — carried to the app-wide light pass: hero + table contrast, pill/spark
   colours, gradient sort arrow.

## Note on provenance

This work shipped ahead of the GSD flow. The commit gate is held by the user per `./CLAUDE.md`; these
two records (PLAN + SUMMARY) are documentation of already-shipped, already-verified code and were
written to register the phase as implementation-complete. They create no commit and modify no `lib/`
file.
</content>
