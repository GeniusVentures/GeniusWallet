# `GWAppBar` extraction has no owning phase since Phase 24 was removed

**Created:** 2026-07-30. **Area:** components / design system. **Severity:** orphaned decision.

## Why this is filed now

Phase 23 **deferred** this extraction, and the reason it gave was specifically that *Phase 24's
routing work would open the same files* — extracting an app bar immediately before a routing refactor
is churn, so it should ride along with that phase. Phase 24 was removed from the roadmap on
2026-07-30 and parked in
`.planning/backlog/architecture-state-ownership-layering-routing-genius-api-split.md`.

The deferral is therefore now pointing at nothing. This is not a new proposal — it is a decision that
lost its destination and would otherwise be silently forgotten.

## What was measured (Phase 23, `23-05-EXTRACTION-AUDIT.md`)

- **16 files** contain an app bar. The claimed identical subset is **seven**.
- That subset was measured against a golden baseline **that no longer exists** — so the "identical"
  premise is itself unverified today and must be re-measured before anyone acts.
- Several of the 16 are not screens at all: a drawer host, an overlay host, two dev-only surfaces, and
  two flow shells.

## Why it was refused, and why that still holds

The payoff is tidiness. The risk spans back-behaviour and custom pop guards across seven screens,
with **no visual net** — this repo has no golden baseline and will not create one. Phase 23's rule
was that a layout-visible change with no automated proof does not ship on inspection alone.

## What closing it actually requires

1. Re-measure the seven-file "identical" claim against today's tree. Do not inherit it.
2. A functional test net for back-behaviour and pop guards — the failure mode here is navigational,
   not visual, so a widget test can genuinely cover it.
3. Ideally, ride along with whatever phase next opens the routing files, which is the original
   argument and is still the cheapest moment.

Related: `.planning/phases/23-*/23-05-EXTRACTION-AUDIT.md`, `23-06-CLOSEOUT.md`,
`.planning/backlog/architecture-state-ownership-layering-routing-genius-api-split.md`
