---
quick_id: 261010-gbm
status: complete
completed: 2026-10-10
requirements: [GBM-01, GBM-02, GBM-03, GBM-04, GBM-05, GBM-06]
key-files:
  created: [lib/settings/developer_mode.dart, test/settings/developer_mode_test.dart, test/settings/sgns_net_test.dart]
  modified: [lib/hive/constants/cache.dart, lib/main.dart, lib/settings/settings_screen.dart, packages/genius_api/lib/src/genius_api.dart, lib/logs/submit_logs_screen.dart, lib/providers/network_provider.dart, lib/bloc/app_bloc.dart, lib/network/network_dropdown_selector.dart, test/account/account_drawer_network_section_test.dart]
actuals: {tasks: 3, commits: 3}
---
# Quick 261010-gbm: Developer mode in Settings Summary

Persisted Developer mode switch in Settings that gates the SDK diagnostics, adds a Dev/Test/Main SDK net
choice applied on the next start through a net_id-only override, and hides EVM testnets while off.

## Commits
- cd5e6a54 feat(settings): Developer mode switch gating the SDK diagnostics (D-01, D-02)
- 3591c586 feat(settings): choose the SDK network under Developer mode (D-03, D-04, D-06)
- 80c2942b feat(network): EVM testnets only in Developer mode (D-05)

## Notes
- `SgnsNet`, `readSgnsNet`, `writeSgnsNet`, `mergeSgnsConfig` are top-level in genius_api.dart; only `net_id`
  is read from overrides/sgns_config.json and only 144/963/369 are accepted (T-gbm-01).
- `jsonFilePath`/`overridesDirPath` are now `Future<String>` getters off `appDataDirectory()`; the late
  `_basePath` field is gone, so Settings opens before SDK init.
- OFF path order: persist false, move a testnet selection to the first mainnet, reset SDK net to Dev.
- NetworkDropdownSelector reads the cubit; its Hive read, local state and unused `initialSelected` are gone.
- Git identity used: braianwegmann@hotmail.com (orchestrator constraint; the plan text said gmail).
- TDD tasks committed as one commit each (plan: one commit per task), not separate RED/GREEN commits.
- STATE.md not touched; left to the orchestrator.

## Deviations
None.

## Gates (run 2026-10-10)
- dart format: 12 files, 0 changed. flutter analyze: "No issues found!", exit 0.
- flutter test: `01:04 +2540 ~6: All tests passed!` (baseline 2532/6, plus 8 new).
- check_brace_style.sh exit 0; check_raw_colors.sh exit 0; all changed files i/lf w/lf.

## Self-Check: PASSED
