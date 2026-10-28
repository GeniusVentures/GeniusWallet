---
phase: 47-dashboard-over-walletconnect
plan: 05
subsystem: walletconnect
tags: [gate, walk]
requires: [47-03, 47-04]
provides: [phase gate numbers]
status: partial
actuals: {tokens: 600, tasks: 1, commits: 1}
key-files:
  modified: [test/components/desktop_top_bar_text_scale_test.dart]
key-decisions: [the Linux walk is run once, combined, on the slave box]
---

# Phase 47 Plan 05: Gate and walk

Task 1 (the gate) is done. Task 2 (the Linux walk against the hosted dashboard) is **pending**: Braian runs a
combined walk on the slave box, so it was not attempted here. The phase stays open until that walk passes.

## Gate (all on the final tree)
- `dart format --set-exit-if-changed` on every Dart file the phase touched: exit 0, 0 changed.
- `tool/check_brace_style.sh`: exit 0. `tool/check_raw_colors.sh`: exit 0.
- `tool/check_no_new_key_logging.sh --scan-tree`: exit 0. It checks a fixed file list; pointed at this
  phase's files it flags every `debugPrint`, old and new alike. The new logs carry method names, codes and
  exception types only, no URL, params, address or `wc:` link.
- `flutter analyze lib test packages/genius_api`: exit 0, no issues.
- `git ls-files --eol` on the touched Dart, plan and contract files: all LF, 0 CRLF.
- `flutter test`: 3190 passed, 10 skipped, 0 failed. Baseline 47-01: 3118 / 10 / 0. The 72 new tests are all
  in `test/reown`.

## Deviation
- [Rule 1] The first full run failed 7 tests in `desktop_top_bar_text_scale_test.dart`: the Connect button now
  reads a `WalletConnectHost` from the tree, and that test mounts the bar without one. The test provides a
  stub host that never starts. Fixed in its own commit; the run after it is the numbers above.

## Not run
- Windows build from the short-path copy: not part of this plan's gate.
- Walk steps 1-8 (pairing, all methods, switches, 6 minute confirm, SDK down, 800 px, disconnect, watch-only).

## Known stubs
None.

## Self-Check: PASSED
