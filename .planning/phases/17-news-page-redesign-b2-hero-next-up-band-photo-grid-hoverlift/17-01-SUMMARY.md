---
phase: 17-news-page-redesign-b2-hero-next-up-band-photo-grid-hoverlift
plan: 01
subsystem: dashboard/news
tags: [news-tab, b2-magazine, hero, next-up, photo-grid, hover-lift, retroactive, dark-only]
type: execute
requires:
  - "sketch 100 (Magazine layout, winner B)"
  - "sketch 101 (Hero + Next up tuning, winner B2)"
  - "sketch 102 (B2 ★ full photo grid reference)"
  - "sketch 008-D (lift-chip hover)"
provides:
  - "the B2 News page shipped in 651541c: hero + Next up band + even photo grid + GWCard.hoverLift + search→Results + 3 bug fixes"
affects:
  - "lib/components/cards/gw_card.dart (additive hoverLift flag — every existing call site byte-identical)"
key-files:
  modified:
    - lib/dashboard/news/view/crypto_news_screen.dart
    - lib/components/cards/gw_card.dart
    - lib/components/inputs/gw_text_field.dart
    - lib/hive/models/news_article.dart
    - lib/services/coin_telegraph/coin_telegraph_api.dart
    - test/components/gw_card_hover_test.dart
    - test/news_article_short_time_test.dart
    - pubspec.yaml
    - pubspec.lock
walk:
  date: 2026-07-24
  walker: Jakub
  build: running macOS debug instance (Flutter 3.41.9)
  mode: DARK ONLY (light deferred to the app-wide light pass)
  fixture: live CoinTelegraph feed (the B2 screen has no widget test — needs network)
decisions:
  - "B2 · Hero + Next up chosen by Jakub 2026-07-23 (sketch 101). Photo-led magazine over the old scrim-tile staggered grid."
  - "Sketch 100 variant C (rail category filter) WITHDRAWN — the live feed carries only 3 categories, 25/30 in 'Latest News'. Local search over headline + dek replaces it."
  - "Hover = sketch 008-D lift chip, promoted to a first-class GWCard.hoverLift flag (additive, default false), NOT a hand-rolled MouseRegion + black scrim."
  - "Search MISS no longer blanks the page — hero band stays frozen, the miss reports inline in 'Results' (Jakub's call)."
  - "Light NOT walked (standing dark-first policy). Recorded as deferred, not passed."
status: complete
---

# Phase 17 Plan 01: News page B2 re-skin — Summary (RETROACTIVE)

**RETROACTIVE RECORD.** This documents code that ALREADY SHIPPED outside the GSD plan/execute flow.
The News page was rebuilt to **B2 · Hero + Next up** (sketches 100-102) in the side worktree
`../GW-news` (branch `redesign/news-tab-260723`, off `efae33a`), then integrated into
`ui-redesign-port` and committed as **`651541c`** on 2026-07-23 (9 files, +972/-190). This SUMMARY
and its paired `17-01-PLAN.md` backfill the GSD record so the phase registers as
implementation-complete; nothing was built while writing them.

**No commits created.** `./CLAUDE.md` holds the commit gate.

## What shipped (commit 651541c)

The old flat staggered grid of scrim-covered photo tiles is gone. `lib/dashboard/news/view/crypto_news_screen.dart`
is now a photo-led magazine:

- **Hero + "Next up" band.** `_NewsMagazine` takes `hero = items.first`,
  `nextUp = items.skip(1).take(3)`, `rest` = the tail. A `LayoutBuilder` at **760px**: wide →
  `IntrinsicHeight(Row[ Expanded(flex:3, hero) · spacer · Expanded(flex:2, Next up) ])`; narrow → the
  "Next up" column drops beneath the hero in a single `Column`. The hero (`_HeroCard`) is photo-left /
  text-right when wide, photo-on-top `16/9` when narrow.
- **Even photo grid.** `_grid(...)` is a `GridView.builder` with
  `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 360, mainAxisExtent: 312)` — a fixed
  tile height (photo 168 + text region), stable across column widths, cannot overflow as the photo
  scales. Full-photo cards (`_NewsGridCard`).
- **hoverLift.** Every card is `GWCard(hoverLift: true)` — the sketch 008-D lift chip (+2px,
  `borderStrong`, `elevation.dialog`), promoted to an additive `GWCard` flag (default `false` → every
  existing call site byte-identical). Replaces the hand-rolled `MouseRegion` + black scrim.
- **Search → "Results".** Header `GWSearchField` runs a debounced (220ms), network-free `where()` over
  headline + `dek`. Hero + "Next up" ALWAYS come from the full feed; searching retitles the bottom
  section to "Results" and a MISS reports inline ("No headlines match …") instead of blanking the
  page.
- **Refresh + freshness stamp.** `_UpdatedStamp` — a desktop-reachable Refresh icon plus "Updated Xm
  ago" (sketch 031 · R3), owning its own 30s ticker so only the stamp re-renders as it ages.

### Three behavioural bugs fixed (not taste)

1. **Frozen relative time.** `coin_telegraph_api.dart` now stores the ISO instant in `pubDate` (was a
   frozen `timeago` string, "2 hours ago" forever) and drops the unused `timeago` import;
   `news_article.dart` formats `relativeTime` / `relativeTimeShort` at read.
2. **Unrendered description.** `news_article.dart`'s `dek` getter renders the fetched-but-never-shown
   description, HTML-stripped (handles the leading `<img>` trap), in the hero + grid cards.
3. **Hover subtracted information.** The lift chip adds emphasis; the old scrim reprinted the title
   over the photo and hid it.

### Freeze fix (load-bearing `IntrinsicHeight`)

A search narrowing to ≤1 result returned the bare hero `_HeroCard` directly into the page's vertical
scroll; its stretch `Row` then demanded height=Infinity and the whole News page threw on every layout
and froze. `_HeroCard` now self-bounds with an inner `IntrinsicHeight`, fixing it everywhere.

### Dependency dropped

`flutter_staggered_grid_view` removed from `pubspec.yaml` / `pubspec.lock` — nothing else imported it
once the grid moved to `SliverGridDelegateWithMaxCrossAxisExtent`.

## Evidence

- **Commit `651541c`** (Jakub, 2026-07-23): `feat(news): Phase 17 — B2 hero+Next up magazine,
  search→Results, freeze fix` — 9 files, +972/-190.
- **`flutter analyze`** on the changed files: clean (remaining infos are pre-existing `deprecated
  .text` in the RSS parser).
- **Unit tests pass**: `test/components/gw_card_hover_test.dart` (+1, the hoverLift flag) and
  `test/news_article_short_time_test.dart` (short/relative time formatting + graceful degrade on a
  legacy `timeago` `pubDate`). The B2 *screen* itself has no widget test — it needs network; it was
  analyzed, not unit-tested, and covered by the human walk instead.
- **Human walk — `17-VERIFICATION.md`, 2026-07-24, Jakub, DARK: APPROVED.** All items PASS: B2 layout,
  hero split responsive (<760px), photo grid, hover-lift (not scrim), search (space input, frozen hero
  band, inline miss), Refresh + stamp, and the three behavioural-bug checks.

## Uncommitted working-tree state (recorded, not hidden)

`git status` shows **`M lib/dashboard/news/view/crypto_news_screen.dart`** — the screen has
working-tree modifications on top of `651541c` (later tuning of the same News work, not yet
committed). This is expected and part of the same effort. Per `./CLAUDE.md` the commit gate is the
user's; this documentation task left it untouched and created no commit.

## Bookkeeping

- Sketch MANIFEST rows for 100 / 101 / 102 are present (`sketches/MANIFEST.md:52-54`) — done.

## Light mode — DEFERRED (recorded, not a pass)

Not walked, per the standing dark-first policy and the light-verification backlog. Carried to the
dedicated light pass, UNVERIFIED: hero / "Next up" / grid contrast, hover-lift in light, search-field
focus ring, Refresh/stamp legibility, empty/error surfaces.

## Open follow-up (not a blocker)

- **First-run Hive migration not explicitly walked.** Pre-migration cache entries hold a frozen
  `timeago` string in `pubDate`; `relativeTime` degrades gracefully (shows it raw, no crash) until the
  ~2-min cache refresh. No crash observed; a deliberate stale-cache first-run was not staged. Low risk,
  carried forward.
