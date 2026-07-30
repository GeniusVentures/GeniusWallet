# The `GWScreen` scaffold sweep has no owning phase since Phase 24 was removed

**Created:** 2026-07-30. **Area:** components / layout. **Severity:** orphaned decision.

## Why this is filed now

Phase 23 deferred this sweep **whole**, and it was carried into Phase 24's scope. Phase 24 was
removed from the roadmap on 2026-07-30 and parked in
`.planning/backlog/architecture-state-ownership-layering-routing-genius-api-split.md`. The deferral
now points at nothing.

## The measured position (Phase 23, `23-05-EXTRACTION-AUDIT.md`)

Roughly **28 files** hand-roll a scaffold.

**`GWScreen` is not a transparent wrapper.** It imposes a safe area, a scroll view, a 1200px width
cap, centring, fixed padding and a background. So adopting it on a screen that does not *already*
have exactly that shape **is a layout change** — not a refactor. Phase 23 forbade layout changes, and
that is the whole reason this was deferred rather than done.

## Why this one is harder than it looks

The per-site audit is real work whose only verification is a two-width, two-mode eyeball per screen —
precisely the case the missing golden baseline was for. And this repo has already shipped the exact
bug this sweep can cause: **a zero-gutter edge-to-edge layout went out once**, because a width cap
only binds *above* its own maximum, so it is invisible at desktop width. It was found by a walk, not
by a test.

## What closing it actually requires

1. A functional test net first. `integration_test` and `patrol` are the Flutter-native candidates
   already named as someday items. A browser driver is technically wrong here — Flutter renders to a
   single canvas with no DOM to select.
2. A per-site audit classifying each of the ~28 files as *already GWScreen-shaped* (safe) vs *would
   change layout* (needs its own justification).
3. Narrow-width checks are mandatory per site, not a spot-check — see the shipped bug above.

Until 1 exists, deferring again is the correct answer, and saying so is not procrastination.

Related: `.planning/phases/23-*/23-05-EXTRACTION-AUDIT.md`, `23-06-CLOSEOUT.md`,
`.planning/backlog/architecture-state-ownership-layering-routing-genius-api-split.md`
