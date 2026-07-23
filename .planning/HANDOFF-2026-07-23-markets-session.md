# Session handover — 2026-07-23 · Markets (design + build + phase setup)

**Role:** design/build session (acted as executor-of-the-moment only for the planning writes below).
For the executor to fold into today's day summary.

## What this session did
1. **Sketch 103 · markets-page** — explored the Markets page: base variants A (grid+) / B (table) /
   C (featured) / D (segmented) → E/F (hero+table synthesis) → E2/E3 (mesh/rail) → refined
   **H1/H2/H3**. **Winner: H1 · Refined split** (native-token hero over a sortable All Markets table).
   `.planning/sketches/103-markets-page/` (README `winner: "H1"`).
2. **Built H1** in worktree `../GW-markets`, branch **`redesign/markets-tab-260723`** (off `efae33a`),
   **not committed**. New: `markets_hero_card.dart`, `markets_table.dart`, `markets_sort.dart` (pure);
   rewritten: `markets_screen.dart`; test: `markets_sort_test.dart`. No data/API/model changes.
   Verified: `flutter analyze` clean + `flutter test markets_sort_test.dart` 5/5.
3. **GSD phase setup** — added **Phase 16: Markets** via `gsd-phase` (ROADMAP + STATE Roadmap
   Evolution + `.planning/phases/16-markets-*/CONTEXT.md`). Confirmed `gsd-manager` init sees it
   (16 phases).
4. Wrote the integration runbook for the executor + a paste-prompt for the other terminal to create
   **Phase 17: News** from `HANDOFF-news-b2.md`.

## Files I touched in the SHARED tree (executor should be aware)
- `.planning/sketches/103-markets-page/*` (new), `.planning/sketches/MANIFEST.md` (added 103 row —
  note: MANIFEST was also edited by another session today; not re-touched after).
- `.planning/ROADMAP.md` (+Phase 16), `.planning/STATE.md` (+Roadmap Evolution line),
  `.planning/phases/16-markets-*/CONTEXT.md` (new), `.planning/HANDOFF-markets-hero.md` (new).

## Events worth noting in the summary
- **Stopped the executor's running app.** With Jakub's go, killed main-tree `flutter run` (PID 25225)
  so a worktree instance could start (shared Hive lock). Executor: restart yours.
- **macOS signing blocker in fresh worktrees.** `../GW-markets`'s `macos/…/project.pbxproj` is
  `Manual` / team `P7T32QQX5V` (fails: "requires a provisioning profile"); the config that builds on
  this machine is the main tree's `Automatic` / team `9UJNVD92ZW`. **Build in the main tree; never
  commit the worktree's pbxproj/Podfile.lock.** Same applies to `../GW-news`.

## Open / next
- Markets + News are **plan-and-integrate** phases (code exists) — integrate + walk + ship, do NOT
  rebuild. Runbook: `.planning/INTEGRATE-260723-markets-news.md` (if saved) or the steps in
  each phase's CONTEXT.md.
- Bookkeeping still owed to the executor: sketch-103 winner row confirmed in MANIFEST; News's 3
  MANIFEST rows; move News todo to `done/`.
