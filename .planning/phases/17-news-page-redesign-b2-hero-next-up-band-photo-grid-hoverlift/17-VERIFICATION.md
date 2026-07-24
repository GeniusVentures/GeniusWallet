---
phase: 17-news-page-redesign-b2-hero-next-up-band-photo-grid-hoverlift
verified: 2026-07-24T08:59:26Z
status: passed
score: walk APPROVED (dark)
behavior_unverified: 0
overrides_applied: 0
note: >
  Phase 17 (News B2) shipped in 651541c OUTSIDE the GSD plan/execute flow; the
  retro 17-01-PLAN.md + 17-01-SUMMARY.md backfill the record. Dark-mode human
  walk APPROVED by Jakub 2026-07-24 (detail below). Light mode deferred to the
  app-wide light pass.
signed_off_by: Jakub
signed_off_at: 2026-07-24T08:59:26Z
---

# Phase 17 - News page (B2 · Hero + Next up) - Walk Verification

**Walked:** 2026-07-24 by Jakub · **Build:** running macOS debug instance (Flutter 3.41.9) ·
**Mode:** DARK ONLY (light deferred to the app-wide light pass) · **Result: APPROVED.**

Phase 17 was a plan-and-integrate phase (code shipped in `651541c`, analyze clean, unit tests
pass). This closes its outstanding human-walk gate.

**No commits created.** `./CLAUDE.md` holds the commit gate.

## Walk verdict (dark) - all APPROVED

| Item | What | Verdict |
|------|------|---------|
| B2 layout | Hero (lead story) + "Next up" column + even photo grid below | PASS |
| Hero split responsive | Next up drops below the hero < ~760px; nothing clips | PASS |
| Photo grid | Even full-photo cards for the tail | PASS |
| Hover-lift | Sketch 008-D lift chip (+2px, stronger border, deeper shadow) - NOT the old black scrim reprinting the title | PASS |
| Search | `GWSearchField` accepts input incl. space (single clean instance, no keyboard wedge); hero band stays frozen; matches land in the "Results" section; a miss does not blank the page | PASS |
| Refresh + stamp | Desktop-reachable Refresh button + "Updated Xm ago" freshness stamp in the header | PASS |
| Behavioural bug 1 | Relative time is live, not a frozen "2 hours ago" string | PASS |
| Behavioural bug 2 | `dek` (description) renders in hero + grid cards, HTML stripped (no raw `<img>` markup) | PASS |
| Behavioural bug 3 | Hover no longer subtracts information (scrim gone) | PASS (same as hover-lift) |
| Empty / error | "No news right now" + Refresh | PASS (as reachable) |

## Bookkeeping

- MANIFEST rows for sketches 100 / 101 / 102 are already present (`sketches/MANIFEST.md:52-54`) - done.

## Light mode - DEFERRED (recorded, not a pass)

Not walked, per the standing dark-first policy and the light-verification-backlog todo. Carried to
the dedicated light pass: hero/Next up/grid contrast, hover-lift in light, search field focus ring,
Refresh/stamp legibility, empty/error surfaces.

## Open follow-up (not a blocker)

- **First-run Hive migration eyeball NOT explicitly walked.** Pre-migration cache entries hold a
  frozen `timeago` string in `pubDate`; `relativeTime` is documented to degrade gracefully (shows
  it raw, no crash) until the ~2-min cache refresh. No crash was observed during the walk, but a
  deliberate stale-cache first-run was not staged. Low risk; carried forward.

## Session note (not a Phase 17 defect)

The walk ran on a macOS instance owned by a concurrent (parallel-session) `flutter run`; the
executor's own relaunches failed on an Xcode `build.db` lock ("two concurrent builds"). Because the
executor did not own that process, its console could not be tailed live - Jakub was the console
watcher and reported nothing red (no `RenderFlex overflowed`, exception, or freeze). Same on-disk
code, so the walk is valid. This is the parallel-session build collision `./CLAUDE.md` warns about.
