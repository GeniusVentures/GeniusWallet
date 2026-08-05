---
created: 2026-07-21T00:00:00.000Z
title: DECISION NEEDED — dashboard error branch has no retry
area: ui
files:
  - lib/dashboard/home/view/dashboard_screen.dart:70
  - .planning/ROADMAP.md:228
  - .planning/phases/05-dashboard/05-UI-SPEC.md (§6)
---

## Problem

This is the SINGLE open gap in `05-VERIFICATION.md` and it BLOCKS Phase 05 sign-off. Two
project documents are in direct conflict, and no implementation resolves that without a
ruling:

- ROADMAP Phase 5 success criterion 3 (line 228) requires the failure branch to show an error
  message "with a working retry — never an endless spinner";
- UI-SPEC §6 explicitly locks develop's error string and forbids reconciling it to
  `GWErrorState`;
- the phase goal ("the dashboard wears the redesign and keeps every behavior develop
  shipped") sides with §6.

Current state, re-confirmed at HEAD: `dashboard_screen.dart:70` is a bare
`Center(child: Text('Something went wrong!'))`. The error branch returns INSTEAD OF, not
alongside, `OneColumnDashBoardView`/`ResponsiveDashboardView` — so a user whose account load
fails has no in-app recovery short of restarting the app.

Separately, and not yet exercised by any walk: a different retry DOES exist on the markets
leg (finding 8) — `FutureStateWidget`'s retry button on a forced market-data fetch failure.
That is a different code path from the dashboard account-load failure branch this todo is
about.

## Solution

Two options, their consequences, and no winner picked here — this todo proposes NO code, and
either path needs a human ruling first:

**Option 1: add a retry affordance to the dashboard failure branch.** Closes ROADMAP
criterion 3. Requires overriding UI-SPEC §6's lock, which must be recorded as a deliberate,
written override — not done silently.

**Option 2: record an override stating §6 intentionally descoped the retry, and reword
ROADMAP criterion 3 to match.** Closes the spec conflict with no code change. Requires a
ROADMAP edit and an explicit, written acceptance that the dashboard has no in-app recovery
from an account-load failure.

Also carry forward `05-VERIFICATION.md`'s second `missing` item, independent of which option
is chosen: one forced-failure observation is still needed proving a retry press on the
markets leg (finding 8) actually re-issues the fetch.
