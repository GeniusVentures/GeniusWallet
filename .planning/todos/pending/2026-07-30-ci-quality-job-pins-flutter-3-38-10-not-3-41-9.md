# CI `quality` job has never executed — the SDK-pin half is now closed

**Updated:** 2026-07-30 — **the SDK mismatch is fixed in `c9831a0`** (both pins moved 3.38.10 →
3.41.9, together, preserving the byte-identical invariant between the build and quality jobs). The
job having *never run* still stands, and is now the whole of this todo.

**Found:** 2026-07-30, during Phase 22's late verification (`22-VERIFICATION.md`).
**Source:** `22-08-SUMMARY.md` flagged it as that plan's single largest unproven risk; confirmed
against the live tree during verification.

## The gap

| | |
|---|---|
| `.github/workflows/build.yml:371` | `flutter-version: 3.38.10` |
| Local SDK, all Phase 22 and 23 verification | `3.41.9` |

The `quality` job has also **never executed once** — the workflow triggers only on push/PR to
`develop`/`main`, and `ui-redesign-port` has never touched either, so `gh run list --branch
ui-redesign-port` is empty. This is why ORG-01 is recorded PARTIAL rather than complete.

## Why it matters

Two unproven things compound. The job has never run, so a wrong path or a vacuously-passing step
would not have been caught. And when it does first run, it runs on a **different SDK minor** than
every number this project quotes — 722/0 tests, analyzer 0, the four gate scripts. A minor bump
can move analyzer output (new lints, changed inference) and test behaviour, so the first real CI
run could go red for reasons no local check can reproduce.

## What closing this looks like

One real CI run, green, on the job as written. That needs a PR into `develop` or `main` — which
needs authorization, per this project's standing rule. Do **not** reach for `workflow_dispatch`
to force one: `build.yml`'s dispatch path deletes and recreates a GitHub release.

~~Then decide whether the pin should move to 3.41.9 to match local, or whether local should move
down to match CI.~~ **Done 2026-07-30 (`c9831a0`): CI moved up to 3.41.9.** Note the trade honestly —
3.38.10 had built in CI many times and 3.41.9 never has, so this swapped a CI-proven version for a
locally-proven one. Since the workflow only triggers on develop/main, the first real signal for
either arrives at the same moment.

## The remaining root cause: no pin file exists

There is no `.flutter-version`, no fvm config, no `.tool-versions`. `pubspec.yaml`'s
`sdk: "^3.10.0"` constrains **Dart**, not Flutter. Until `c9831a0`, `.github/workflows/build.yml` was
the *only* place a Flutter version was written down — which is exactly how local and CI drifted three
minor lines apart without anyone noticing.

Adding a real pin file would stop this recurring. It was offered and not taken on 2026-07-30; noted
here so the option is not lost.

Related: `.planning/phases/22-.../22-VERIFICATION.md`, `22-08-SUMMARY.md`, ORG-01 in
`.planning/REQUIREMENTS.md`.
