# Phase 17 — News page (sketches 100-102 · B2)

**Status:** implementation already built in worktree, **not committed**. This is a
*plan-and-integrate* phase, not a from-scratch build — the code exists and is verified; it needs
review, integration into the main tree, and the human walk.

## Goal
Replace the flat staggered grid of scrim-covered photo tiles with **B2 · Hero + Next up** (chosen by
Jakub 2026-07-23): a lead hero + a "Next up" band over an even photo grid, photo-led and scannable.

## Design contract
- Sketches: `.planning/sketches/100-news-page-layout/` (winner **B · Magazine**; rail-filter variant C
  withdrawn — the live feed carries only 3 categories, 25/30 in one), `101-news-magazine-tuning/`
  (winner **B2 · Hero + Next up**), `102-news-hero-band/` (**B2 ★** reference — full photo grid wanted).
- Hover = the sketch **008 D "lift chip"**, now a first-class `GWCard.hoverLift` flag, not a hand-rolled
  MouseRegion + black scrim.
- Header owns a desktop-reachable **Refresh** (pull-to-refresh alone is unreachable with a mouse) and a
  local **search** (`GWSearchField`, a network-free `where()` over headline + dek).
- No category/topic filter — measured 2026-07-23: 3 categories, 25/30 in "Latest News" (this is why
  sketch 100 C was withdrawn).

## Where the implementation lives
- Worktree `../GW-news`, branch **`redesign/news-tab-260723`** (off `efae33a`), **not committed**.
- 6 files (see handoff):
  - `lib/components/cards/gw_card.dart` — additive `hoverLift` flag (default `false` → every existing
    call site byte-identical; +2px, `borderStrong`, `elevation.dialog` on hover).
  - `test/components/gw_card_hover_test.dart` — new widget test for the flag.
  - `lib/hive/models/news_article.dart` — `relativeTime` + `dek` getters (no field change → **no
    `.g.dart` regeneration**).
  - `lib/services/coin_telegraph/coin_telegraph_api.dart` — stores the ISO instant in `pubDate`
    instead of the frozen `timeago` string; dropped the unused `timeago` import.
  - `lib/dashboard/news/view/crypto_news_screen.dart` — full B2 rewrite.
  - `pubspec.yaml` / `pubspec.lock` — dropped `flutter_staggered_grid_view`.

## Three behavioural bugs fixed (not taste)
1. `pubDate` was a frozen `timeago` string ("2 hours ago" forever) → stores the instant, formats at read.
2. `description` was fetched, cached, never rendered → `dek` getter (HTML-stripped, handles the leading
   `<img>` trap) renders it in the hero + grid cards.
3. Hover subtracted information (black scrim reprinting the title) → replaced by the `GWCard` lift chip.

## Verified
- `flutter analyze` on all changed files — clean (remaining infos are pre-existing `deprecated .text`
  in the RSS parser).
- `flutter test test/components/gw_card_hover_test.dart` — **+1 passed**.
- NOT run: `flutter run` (executor-only; Hive lock), full suite. The B2 screen has no widget test
  (needs network) — it was analyzed, not walked.

## Remaining work (what this phase must close)
1. Integrate `redesign/news-tab-260723` into the main tree (news files are disjoint from transactions,
   so the merge should be clean).
2. Human walk — **dark + light**; check hero split at wide/narrow (Next up drops below the hero
   < 760px), the photo grid, hover-lift (not scrim), search, Refresh, and empty/error states.
3. Add the **3 sketch rows (100/101/102) to `.planning/sketches/MANIFEST.md`** — row text is spelled
   out in the todo's "Executor bookkeeping" block.
4. First-run eyeball of the Hive migration: pre-migration cache entries hold a frozen `timeago` string
   in `pubDate`; `relativeTime` degrades gracefully (shows it raw) with no crash until the 2-min cache
   refresh.

## Known simplifications (ponytail)
- The `<img>`-regex fallback in the API was **deliberately kept** — the handoff called it optional
  ("safe to drop"); it is harmless and more edge-case-robust than removing it.
- **`flutter_staggered_grid_view` removed** — nothing else imported it; the grid uses
  `SliverGridDelegateWithMaxCrossAxisExtent` with a fixed `mainAxisExtent`.

Full handoff: `.planning/HANDOFF-news-b2.md`.
