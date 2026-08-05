# Deferred items — discovered during 23-01 execution, out of scope for this plan

These are pre-existing conditions in the tree, unrelated to `lib/theme/gw_colors.dart`,
`test/theme/gw_colors_parity_test.dart`, or `lib/theme/gw_context_extension.dart`. Logged per the
scope-boundary rule rather than fixed, since 23-01's files_modified is `lib/theme/` + `test/` +
`.planning/` only.

## 1. Pre-existing `dart format` drift (5 files, none touched by 23-01)

`dart format --output=none --set-exit-if-changed lib test` reports 5 files needing reformatting:
- `lib/bloc/app_state.dart`
- `lib/dashboard/compute/compute_state.dart`
- `test/dashboard/compute_feed_state_test.dart`
- `test/dashboard/compute_state_distinct_test.dart`
- `test/dashboard/compute_state_test.dart`

Confirmed via `git status --short` that none of these were touched during 23-01 (only
`lib/theme/gw_colors.dart` and `test/theme/gw_colors_parity_test.dart` are modified/untracked).
`--output=none` does not write to disk, so this was a read-only check. Not fixed here.

## 2. Pre-existing `tool/verify_additive_boundary.sh` failures (repo-wide, unrelated to theme)

Two checks fail, both outside `lib/theme/`:
- **Duplicate public class name census**: `_Section`, `_SplashState`, `_TimeframeTab`,
  `_TimeframeTabState` are not in `tool/shadow-baseline.txt`. The script explicitly warns not to
  add to the baseline without a written, reviewed justification — investigate first, so this is
  left for whoever owns that check.
- **WIRE- standing tripwire**: `lib/components/overlay/global_swap_fab_host.dart:21` still carries
  a `WIRE-02` marker comment.

Neither relates to colour tokens; both predate this plan's changes.
