# HANDOFF — News tab B2 built (in a worktree, uncommitted)

**Session, 2026-07-23.** DESIGN/BUILD session (NOT the executor — terminal 1 owns
transactions + git). Built the News redesign **B2 · Hero + Next up** from the queued handoff
`.planning/todos/pending/2026-07-23-news-tab-redesign-B2-build.md`.

## Where the work is

- **Worktree:** `../GW-news` — branch **`redesign/news-tab-260723`** (based off `efae33a`).
- **Not committed** (CLAUDE.md: "Do not create commits"). Not merged. No `lib/` edits in the shared
  transactions tree. No `STATE.md` / `MANIFEST.md` / `ROADMAP.md` touched (executor-owned).

## What was built (6 files, +566/−161)

- `lib/components/cards/gw_card.dart` — **prerequisite:** additive `hoverLift` flag (sketch 008 D lift
  chip: +2px, `borderStrong`, `elevation.dialog` on hover). Default `false` → every existing call site
  byte-identical. Only engages with `onTap`. Discrete pointer-driven transform, clear of the 37639d5
  freeze class.
- `test/components/gw_card_hover_test.dart` — **the runnable check.** Pumps a `hoverLift` card, drives a
  synthetic mouse, asserts lift/border/shadow all change on enter and settle on exit. **Passes.**
- `lib/hive/models/news_article.dart` — bug fixes 1+2 as getters (no field change → **no `.g.dart`
  regeneration**): `relativeTime` (formats the instant at read time — kills the frozen "2 hours ago");
  `dek` (HTML-stripped `description`, handles the leading `<img>` trap).
- `lib/services/coin_telegraph/coin_telegraph_api.dart` — stores the ISO instant in `pubDate` instead of
  the `timeago` result; dropped the now-unused `timeago` import.
- `lib/dashboard/news/view/crypto_news_screen.dart` — full B2 rewrite: `GWPageHeader` + desktop Refresh
  button, `GWSearchField` (local `where()`), hero + "Next up" band (drops to a column < 760px), photo
  grid (`SliverGridDelegateWithMaxCrossAxisExtent`, fixed `mainAxisExtent`), `GWEmptyState`/`GWErrorState`
  for the empty/error branches, `GWCard(hoverLift: true)` everywhere (black scrim gone).
- `pubspec.yaml` / `pubspec.lock` — **dropped `flutter_staggered_grid_view`** (nothing else imported it).

## Verification (within lane — no app run, no full suite)

- `flutter pub get` — clean, confirms the staggered dep removed.
- `flutter analyze` on all changed files — **No issues** (4 remaining infos are pre-existing
  `deprecated .text` in the RSS parser, not mine).
- `flutter test test/components/gw_card_hover_test.dart` — **+1 passed.**
- NOT run: the app (`flutter run` — Hive lock belongs to the executor) and the full suite/baseline
  (executor-only). The B2 screen has no widget test (needs network); it was analyzed, not walked.

## Deliberately NOT done

- **Kept the `<img>`-regex fallback** in the API (handoff called it "safe to drop" = optional). It is
  harmless and more edge-case-robust than removing it; left working code alone.
- No commit, no `MANIFEST.md` rows. **Executor to-do** (rows are spelled out in the queued todo's
  "Executor bookkeeping" block) + decide how to land the branch (merge/PR/cherry-pick onto the
  transactions branch once it settles).

## For the executor to land this

```
git worktree list                      # ../GW-news = redesign/news-tab-260723
cd ../GW-news && git add -A && git commit   # when authorized
# then merge/rebase onto the integration branch, add the 3 MANIFEST rows,
# move the todo to done, and run the full suite for the real baseline.
```
