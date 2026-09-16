---
phase: 26
plan: 01
subsystem: swap
tags: [squid, dependencies, degradation]
status: complete
requires: []
provides: [squid-client, swap-availability-gate]
affects: [lib/squid_router, pubspec.yaml]
tech-stack:
  added: [squidrouter (path), dio 5.11.1, dio_web_adapter 2.2.2, one_of 1.5.0, one_of_serializer 1.5.0, quiver 3.2.2]
  patterns: [String.fromEnvironment build flag, lazy top-level memoisation]
key-files:
  created: [lib/squid_router/squid_client.dart, test/squid_router/squid_client_test.dart]
  modified: [pubspec.yaml, pubspec.lock, lib/squid_router/swap_screen.dart, test/squid_router/swap_flip_centring_test.dart]
decisions:
  - "The availability gate sits above the CTA ladder, not inside it: swap_cta_state.dart is untouched."
  - "initState clears isLoading when unavailable — skipping the fetch alone would spin forever."
  - "one_of/one_of_serializer accepted on the grounds that neither imports any dart: library."
metrics: {duration: 55m, completed: 2026-09-16, tasks: 3, commits: 3}
actuals: {tokens: 3713, tasks: 3, commits: 3}
---

# Phase 26 Plan 01: Wire the Squid client Summary

App code now reaches the vendored Squid v2 client through one file, and a build with no integrator
ID refuses to quote instead of rendering a 401 as a route error.

`actuals.tokens` is chars/4 over the realized diff (14,854 chars). The 45,000 estimate was plainly
measured on a different scale — chars/4 over the *files touched* is 15,518 — so read the miss as a
scale mismatch, not a 12x overestimate.

## Task 1 — package legitimacy gate (blocking-human, approved)

Exactly 5 new pub.dev packages plus the local path package; `pub get` reported "Changed 6
dependencies", matching the audit precisely. No existing package was upgraded. All 5 sha256 hashes
matched pub.dev, none retracted, each locked version is current latest, none ships a build hook or
binary. Decision record: `26-CONTEXT.md` → "Dependency audit — approved 2026-09-16".

## Deviations from Plan

**[Rule 1 - Bug] `isLoading` would never clear.** The plan said only "skip `_loadTokens`". That
field starts `true` and is cleared *only* by that method, so an unavailable build would have sat on
a spinner forever and never rendered the CTA the plan asks for. `initState` now clears it
explicitly. Commit `9063608b`.

**[Rule 1 - Bug] Two flip-centring tests broke.** `swapAvailable` defaults to `squidConfigured`,
false under `flutter test`, so the form they measure no longer loads. They now pass
`swapAvailable: true` — the state they were always measuring. Commit `9063608b`.

**[Rule 3] Dropped the `built_value` import from the test** in favour of
`serializeWith(RouteRequest.serializer, …)`, which needs no direct dependency. Avoided adding a
dev-dependency purely to satisfy `depend_on_referenced_packages`. Commit `c8fd1026`.

## Known Stubs

| File | Line | Stub | Resolved by |
|---|---|---|---|
| `lib/squid_router/swap_screen.dart` | 327 | `// TODO: invoke Squid API` — `_submitSwap` still fabricates a completed transaction | 26-05 |
| `lib/squid_router/squid_token_service.dart` | 10, 33, 56 | `return mock…` on the first line of each method | 26-03 |

Both are the phase's reason for existing and are explicitly out of this plan's scope. This plan
adds a gate *above* them; it does not remove them.

## Verification

Real output, run on this machine:

- `flutter test --no-pub` → **+1239 ~3, All tests passed!**, exit 0 (baseline 1232 + 7 new)
- `flutter analyze --no-pub` → "No issues found!", exit **0**, root and `packages/genius_api` both
- `dart format --set-exit-if-changed lib test` → exit 0; `tool/check_brace_style.sh --count` → `0`
- `grep -rn GW_SQUID_INTEGRATOR_ID lib/` → 2 hits, both in `squid_client.dart` (the define and its
  doc line). The plan predicted exactly one; the second is documentation, not a second read site.
- `git status --short squidrouter` → empty. Nothing under the submodule was touched.
- No file deletions across the three commits.

## Self-Check: PASSED

Both created files exist on disk; commits `c8fd1026`, `53f602c1`, `9063608b` all resolve.
