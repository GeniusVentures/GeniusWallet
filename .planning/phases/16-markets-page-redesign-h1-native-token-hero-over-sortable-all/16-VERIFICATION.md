---
phase: 16-markets-page-redesign-h1-native-token-hero-over-sortable-all
verified: 2026-07-24T08:59:26Z
status: passed
score: 9/9 must-haves verified
behavior_unverified: 0
overrides_applied: 0
note: >
  Implemented OUTSIDE the GSD plan/execute flow — shipped directly in `aa78eec`
  (2026-07-23) and iterated live with Jakub on 2026-07-24. No PLAN/SUMMARY exist;
  verified goal-backward against the ROADMAP goal + sketch-103 H1 design contract
  (16-CONTEXT.md) and the shipped code. Dark-mode human walk confirmed by Jakub
  ("super") on 2026-07-24. Light mode deferred to the app-wide light pass.
deferred:
  - truth: "Light-mode human walk of the Markets hero + table (contrast, pill/spark colours, sort arrow)"
    addressed_in: "App-wide light pass (per MEMORY: dark-mode-first-light-later)"
    evidence: "CONTEXT remaining-work item 1 (dark+light walk); light deferred per standing project decision"
follow_ups: # Non-blocking housekeeping surfaced from CONTEXT — does not affect status
  - "CONTEXT remaining-work item 2 — add the sketch-103 winner (H1) row to .planning/sketches/MANIFEST.md (line 55 still reads '_pending pick_'). Documentation only; no code impact."
---

# Phase 16: Markets page redesign (sketch 103 · H1) Verification Report

**Phase Goal:** Re-skin `/markets` to sketch 103 **H1** — a native-token (GENIUS AI) hero over a sortable "All Markets" table.
**Verified:** 2026-07-24
**Status:** passed
**Re-verification:** No — initial verification (phase shipped ahead of GSD plan flow)

## Method note

This phase has **no PLAN/SUMMARY** — it was built in a worktree and committed directly
(`aa78eec`, 2026-07-23), then iterated live on 2026-07-24. Verification is goal-backward
against the ROADMAP goal (ROADMAP.md:797-808) and the sketch-103 **H1** design contract
recorded in `16-CONTEXT.md`, checked against the four shipped source files. Truths are
derived from that contract (Option C).

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | `/markets` renders the new hero-over-table layout (not the old flat grid) | ✓ VERIFIED | `router.dart:237` `/markets` → `MarketsScreen`; `markets_screen.dart:199-213` builds `MarketsHeroCard` + `GWSectionTitle('All Markets')` + `MarketsTable` in a scroll column |
| 2 | The native token (GENIUS AI, `genius-ai`) is pulled OUT of the table and shown as the hero | ✓ VERIFIED | `markets_sort.dart:5` `kNativeMarketCoinId='genius-ai'`; `markets_screen.dart:160-180` selects `featuredCoin`, `continue`s it out of `rows` (173), `hasHero` gates the card (202) |
| 3 | Hero shows identity + 48px price + %-pill + absolute 24h change | ✓ VERIFIED | `markets_hero_card.dart:49-68` icon(46)+name; `:73-86` fixed 48px price; `:92` `_ChangePill`; `:94-102` `${_absChange} · 24h` |
| 4 | Hero shows a 2×2 stat block: Rank · Market Cap · Volume 24h · ATH | ✓ VERIFIED | `markets_hero_card.dart:109-121` Rank(111) · Market Cap(112) · Volume 24h(118) · All-Time High(119) |
| 5 | Hero shows a 7d brand-gradient area chart + a (visual) timeframe selector, responsive Row→Column | ✓ VERIFIED | `_HeroChart` gradient line + `belowBarData` area gradient (`:334-351`); `_TimeframeSegment` 24H/7D/30D/1Y right-aligned (`:138-139`); `LayoutBuilder` wide `IntrinsicHeight` Row vs narrow Column (`:147-179`) |
| 6 | "All Markets" table renders core columns: #/Coin/Price/24h%/Market Cap/Volume/7d spark | ✓ VERIFIED | `markets_table.dart:169-182` header cells; `:206-321` data cells; `_MiniSpark` sparkline (`:310-320`, `357-388`) |
| 7 | Table headers are sortable; ordering is correct | ✓ VERIFIED | `markets_table.dart:66-77` `_onHeaderTap` toggles/sets sort+dir; `:82-83` sorts via `compareMarketRows`; pure comparator test **5/5 pass** (`markets_sort_test.dart`, run 2026-07-24) |
| 8 | A row tap navigates to `/token-info` with the coin + market data | ✓ VERIFIED | `markets_table.dart:193-194` `InkWell.onTap → widget.onTapRow`; `markets_screen.dart:212 → _openToken → :58-63` `context.push('/token-info', extra:{marketData,coin})`; `/token-info` route exists `router.dart:244` |
| 9 | Table scrolls horizontally when too narrow (no column crush) | ✓ VERIFIED | `markets_table.dart:93-108` `LayoutBuilder` → below `_minTableWidth` wraps table in horizontal `SingleChildScrollView` at fixed width |

**Score:** 9/9 truths verified (0 present, behavior-unverified)

Sort (truth 7) is behavior-dependent but is backed by a passing pure-comparator test
(`compareMarketRows`, 5/5), which the table consumes directly — so it is VERIFIED, not
present-only.

### Deferred Items

| # | Item | Addressed In | Evidence |
|---|------|-------------|----------|
| 1 | Light-mode human walk (contrast, pill/spark/arrow colours) | App-wide light pass | Standing project decision "dark-mode-first-light-later"; CONTEXT walk item split dark(done)/light(deferred) |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/dashboard/chart/markets_screen.dart` | Rewritten page: chained fetch → hero+table | ✓ VERIFIED | 225 lines; wired at `/markets`; per-fetch error/retry; Expanded-bounded states |
| `lib/dashboard/chart/markets_hero_card.dart` | Native-token hero (H1 refined split) | ✓ VERIFIED | 551 lines; identity/price/pill/stats/chart/selector; imported+used in screen |
| `lib/dashboard/chart/markets_table.dart` | Sortable All Markets table + sparkline | ✓ VERIFIED | 388 lines; header/data rows, sort, h-scroll; imported+used in screen |
| `lib/dashboard/chart/markets_sort.dart` | Pure sort comparator + native-id const | ✓ VERIFIED | 58 lines; `MarketRowData` + `compareMarketRows`; consumed by table + tests |
| `test/markets_sort_test.dart` | Runnable check for ordering | ✓ VERIFIED | 5/5 passing (2026-07-24) |

### Key Link Verification

| From | To | Via | Status |
|------|-----|-----|--------|
| `router.dart` | `MarketsScreen` | `/markets` route builder (`:237`) | ✓ WIRED |
| `markets_screen.dart` | `MarketsHeroCard` / `MarketsTable` | constructed in `_buildContent` (`:203,:211`) | ✓ WIRED |
| `markets_table.dart` | `compareMarketRows` | `sort()` in `build` (`:83`) | ✓ WIRED |
| `markets_screen.dart` | `/token-info` | `_openToken → context.push` (`:58-63`) | ✓ WIRED |
| `markets_screen.dart` | `getMarketCoins` / `fetchCoinsMarketData` | existing util + API (`:40,:54,:130`) | ✓ WIRED — no new data/API/model |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|--------------|--------|--------------------|--------|
| `MarketsScreen` | `coins` / `marketData` | `getMarketCoins()` then `fetchCoinsMarketData()` (live CoinGecko) | Yes — real chained fetch, no static/empty return | ✓ FLOWING |
| `MarketsHeroCard` | `data` (CoinGeckoMarketData) | featured `genius-ai` row off fetched map | Yes — all fields read off model | ✓ FLOWING |
| `MarketsTable` | `rows` | `coins` minus featured, `d==null` hidden | Yes — real per-coin market data | ✓ FLOWING |

### Recent Live-Change Verification (2026-07-24)

| Change | Status | Evidence |
|--------|--------|----------|
| Hero chart bottom-aligned to Volume/ATH row via Spacer | ✓ VERIFIED | `markets_hero_card.dart:141` `if (fill) const Spacer()` (only flex child, empty box — avoids intrinsic-measuring fl_chart) |
| Hover tooltip on hero chart (time + price + % vs window start) | ✓ VERIFIED | `:356-418` `LineTouchData` enabled, `timeAt` maps index → last-7d, tooltip time+price+pct |
| Sparkline column right-aligned | ✓ VERIFIED | `markets_table.dart:310-320` `Align(centerRight)` around fixed 72px spark |
| Gradient sort arrow | ✓ VERIFIED | `markets_table.dart:133-138` `ShaderMask` w/ `brandCta` gradient over ↑/↓ |
| Page vertical scrollbar hidden | ✓ VERIFIED | `markets_screen.dart:187-188` `ScrollConfiguration(scrollbars:false)` |
| RepaintBoundary around hero card (kill hairline flicker) | ✓ VERIFIED | `markets_hero_card.dart:187` `RepaintBoundary` wraps the card |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `markets_table.dart` | 175,177,264,287,331 | 1h% / 7d% columns render `-` placeholder | ℹ️ Info | Documented `ponytail` — CoinGeckoMarketData has no 1h/7d %; renders marked-absent `-`, never a fabricated number; upgrade path + backlog todo cited. Additions beyond the H1 contract, honestly stubbed. |
| `markets_hero_card.dart` | 424-480 | Timeframe selector is visual-only | ℹ️ Info | Documented `ponytail`; matches design contract wording ("visual timeframe selector"); tied to existing wire-real-ranges todo |
| `markets_screen.dart` | 176 | coins with `d==null` hidden | ℹ️ Info | Documented; mirrors `DashboardMarkets` behaviour |

No `TBD`/`FIXME`/`XXX` debt markers. All shortcuts carry `ponytail:` comments with a named ceiling + upgrade path (repo convention). `flutter analyze` on all 5 files: **No issues found**.

### Human Verification

- **Dark mode — DONE.** Jakub walked `/markets` live on 2026-07-24 and confirmed it looks good ("super"): hero split at wide/narrow, table sort, horizontal scroll, hover tooltip. Recorded as the human-walk evidence.
- **Light mode — DEFERRED** to the app-wide light pass (standing "dark-mode-first" decision). Not a blocker for this phase.

### Gaps Summary

**No goal-blocking gaps.** Every ROADMAP goal element and sketch-103 H1 design-contract
element is present, wired, fed by real data, analyze-clean, and confirmed in a live dark-mode
human walk. Sort correctness is test-backed (5/5).

Two non-blocking follow-ups (neither affects the phase goal or the next phase):

1. **Doc housekeeping** — CONTEXT remaining-work item 2 (add the sketch-103 **H1** winner row
   to `.planning/sketches/MANIFEST.md`) is still open; line 55 reads "_pending pick_".
   Documentation only, no code impact.
2. **Light-mode walk** — deferred to the app-wide light pass (see Deferred Items).

The H1 table also **adds** 1h%/7d% placeholder columns beyond the contract's core column set;
these are honest `-` placeholders (no fabricated data) with a captured upgrade path, and the
one sortable change column (24h%) carries real data.

---

_Verified: 2026-07-24_
_Verifier: Claude (gsd-verifier)_
