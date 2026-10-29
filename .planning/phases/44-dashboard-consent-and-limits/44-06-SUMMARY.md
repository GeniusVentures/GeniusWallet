---
phase: 44-dashboard-consent-and-limits
plan: 06
subsystem: dev-tools
tags: [dev-bubble, gate, walk]
requires: [44-02, 44-03, 44-04, 44-05]
provides: [GNUS BRIDGE dev section, phase gate numbers]
key-files:
  created: [lib/dev/dev_gnus_bridge.dart, test/dev/dev_gnus_bridge_test.dart]
  modified: [lib/dev/dev_tools_bubble.dart]
status: complete-pending-human-walk
actuals: {tokens: 30000, tasks: 2, commits: 1}
---

# Phase 44 Plan 06: Dev bubble triggers and phase gate Summary

The dev bubble has a GNUS BRIDGE section (Connect, Other site, Submit, Preview, Sites) that reaches both prompts, both limits and the Settings list with no dashboard page. The Linux walk is NOT done: it is pending for Braian on a Linux box.

## Commits
- 04be06cb `lib/dev/dev_gnus_bridge.dart`, the bubble section, 6 tests

## Phase gate (run in this worktree)
- `dart format --set-exit-if-changed` on every touched lib and test dir: exit 0.
- `bash tool/check_brace_style.sh`, `check_raw_colors.sh`, `check_no_new_key_logging.sh --scan-tree`: all exit 0.
- `flutter analyze lib test packages/genius_api`: exit 0, no issues.
- `flutter test`: 2981 passed, 9 skipped, 0 failed. Baseline before 44-01 was 2925 / 9 / 0, so +56.
- Tests added: 01 +12, 02 +12, 03 +13, 04 +8, 05 +5, 06 +6.

## Known limits
- Live cost stays -32010 until SDK-CA, so a live Submit stops before the confirm; walk the confirm with a JOB fixture armed.
- Transports must forward only `eventsFor(origin)`; the unfiltered `events` stream is test-only.
- A submit burned before a revoke still answers 4100; the job is recorded and replays after reconnect.

## Pending human check (Linux, `--dart-define=GW_DEV_TOOLS=true`, dark then light, 800 and 1280 px)
Steps 1 to 7 of the plan's human-check, unchanged: Connect drawer; second Connect silent; Sites list, Revoke, reprompt; `confirm_open` and `rate_limited`; Preview with Escape; JOB Priced OK then Submit and Reject toasts 4001; relaunch keeps the site. No screenshots exist yet under `walk/`.

## Deviations
- No Linux walk, and `dev_tools_bubble.dart` was not touched for walk findings. Per the request, the app was not run.

## Self-Check: PASSED (no known stubs)
