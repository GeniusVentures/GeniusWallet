---
phase: 33-app-and-sdk-data-out-of-the-documents-folder
plan: 01
status: complete
key-files:
  created: [packages/genius_api/lib/src/app_data_directory.dart, test/app_data_directory_test.dart]
  modified: [packages/genius_api/lib/genius_api.dart, lib/hive/init.dart, packages/genius_api/lib/src/genius_api.dart, lib/main.dart, .planning/reference/FRESH-INSTALL-RECIPE.md]
actuals: {tokens: 9000, tasks: 3, commits: 4}
---

# Phase 33 Plan 01: App data folder resolver Summary

One memoized resolver sends Hive, the SDK base path and the Sentry log read to
`%LOCALAPPDATA%\GeniusVentures\GeniusWallet` (Linux: XDG/`~/.local/share/GeniusWallet`) on new installs,
and keeps Documents whenever it already holds `wallet.hive` or `secure_storage_id`. Nothing is moved.

## Commits
- cb4be909 test: resolver cases (RED, compile failure on missing functions)
- d236c76d feat: `pickAppDataDirectory` + `appDataDirectory`; `initHive` uses `Hive.init`
- 1eccc271 feat: `prepareConfigFiles` and `_attachSdkLogsToHint` use the resolver
- d3f9e302 docs: FRESH-INSTALL-RECIPE covers both folders and the extra Documents names

## Verification
- `flutter test`: 1853 +5 skipped before, 1864 +5 skipped after (11 new), all passed
- `flutter analyze` root and packages/genius_api: No issues, exit 0
- brace, raw-colors and key-logging checks: exit 0; new files are `i/lf`
- The new-install path and Linux are verified by the unit test only
- Windows existing-install walk PASSED 2026-09-26: log `Base path directory: C:\Users\User\Documents`,
  `%LOCALAPPDATA%\GeniusVentures` never created, Documents listing unchanged, wallets/history/SDK accounts confirmed

## Deviations
- Added: a failed resolver future clears its memo so the next call retries (plan-checker note),
  pinned by a test that mocks the path_provider channel over a temp Documents holding a marker.
- The plan's recipe grep `'GeniusVentures\\GeniusWallet'` counts 0 on Git Bash's GNU grep 3.0;
  `grep -cF 'GeniusVentures\GeniusWallet'` counts 5, so the content meets the criterion.
- Recipe lists `sgnslog.log` and `sgnslog2.log` by name (the two files the app reads), not a glob.
- STATE.md/ROADMAP not updated by instruction.
