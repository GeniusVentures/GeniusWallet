# Handoff — News search + refresh (header pair)

**Session:** design + inline polish (claude-501) · 2026-07-24
**For:** the EXECUTOR session — please commit the items below (this session does not touch git per CLAUDE.md).

## What happened
Jakub questioned the News screen's search bar + "Updated now" refresh (screenshot).
Confirmed both are **real, wired controls** in `crypto_news_screen.dart` (debounced
`GWSearchField` filter + `_UpdatedStamp` re-fetch/stamp) — so this was a **re-skin, not a
rebuild**. Built sketch **151** (4 variants of the pair), Jakub picked **A**, then refined
it live in the running app to a **market-standard** header.

## Decisions (final)
- News header freshness control = **`Updated 3m ago  ⟳`** — plain text + a **bare** trailing
  refresh icon (no fill/border box), matching the Markets header's bare trailing action
  (`markets_screen.dart`, the magnifying glass).
- **No freshness dot.** A dot was added (variant A) then removed (variant B): a permanently
  green dot reads as a "live" signal it doesn't earn. Standard for finance/news surfaces is
  text + icon, no colored dot (Yahoo Finance, Gmail). Upgrade path if ever wanted: tint the
  timestamp by age, not a static dot.
- Refresh icon position = **trailing (right), at the corner** — confirmed standard.

## Uncommitted / untracked — EXECUTOR to commit
1. `lib/dashboard/news/view/crypto_news_screen.dart` (modified, +2/-7) — `_UpdatedStamp`:
   removed the `IconButton.styleFrom` box; removed the dot `Container` + its `SizedBox`.
2. `.planning/sketches/151-news-search-refresh/` (untracked) — sketch `index.html` + `README.md`.
3. `.planning/sketches/MANIFEST.md` (modified) — added the 151 row.

Suggested commits (split code vs docs to match repo convention):
- `refactor(news): bare trailing refresh icon, drop freshness dot (sketch 151-B)`
  — files: `lib/dashboard/news/view/crypto_news_screen.dart`
- `docs(sketch-151): news search+refresh header pair — variant A→B (market-standard)`
  — files: `.planning/sketches/151-news-search-refresh/ .planning/sketches/MANIFEST.md`

## Verification done
- `flutter analyze lib/dashboard/news/view/crypto_news_screen.dart` → **No issues found**.
- Change is **hot-reloaded live** in the running macOS app (Jakub confirmed the look).

## Notes for whoever runs next
- A macOS `flutter run` from THIS session is still live (detached, FIFO stdin at
  `…/scratchpad/gw.fifo`; hot reload via `echo r > gw.fifo`). Quit it before a fresh
  `gmac` to avoid the Hive-lock black-window trap.
- During launch there was a brief overlap with another session's `flutter run`
  (`claude-1b75`) — it caused transient CoinGecko 429s (cached fallback, harmless). Gone now.
- Sketch 151 keeps variants **C** (refresh docked inside the field) and **D** (live command
  bar) if the direction is ever revisited.
