---
phase: 38-account-tree-switcher
plan: 01
subsystem: ui
tags: [flutter_bloc, account-tree, dev-mock]
requires: [{phase: 37-child-write-operations-pending-model, provides: "ChildOperationsCubit, ChildWallet, ChildWalletRow, DevMockChildWallets"}]
provides: ["buildAccountTree: pure cycle-safe nesting model", "ChildOperationsCubit.ownRegistrations(): keyed SDK/dev-mock read", "one Accounts header with the D-11 flat-list note"]
affects: [38-02, 38-03]
actuals: {tokens: 13000, tasks: 3, commits: 3}
tech-stack:
  patterns: ["one visited set across a recursive walk for cycle/dedup safety", "keyed pre-read cached on State, not per-rebuild"]
key-files:
  created: [lib/account/account_tree.dart, test/account/account_tree_test.dart, test/account/account_drawer_tree_test.dart]
  modified: [lib/account/account_drawer.dart, lib/child_wallets/child_operations_cubit.dart, test/account/account_drawer_show_test.dart, test/account/account_drawer_network_section_test.dart, test/account/sdk_account_rows_test.dart, test/child_wallets/child_operations_cubit_test.dart, test/squid_router/swap_submit_test.dart]
key-decisions:
  - "Read goes through ChildOperationsCubit, not GeniusApi from the drawer's State (AGENTS.md bars SDK calls in a widget/State); Task 2's edge-case tests exposed no bugs, committed test-only"
requirements-completed: [SWT-07]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 38 Plan 01: Account tree switcher Summary

**Registered children now nest under their main end to end -- SDK/dev-mock registrations -> ChildOperationsCubit -> buildAccountTree -> nested rows -- inside one merged "Accounts" section.**

## Accomplishments
- `buildAccountTree`: one visited set walks each own account's registrations depth-first; a cycle, self-listing or second main dedupe to first placement; foreign children become actionable `ChildWalletRow` leaves
- `ChildOperationsCubit.ownRegistrations()`: one read per own account, null when the node is down or any read fails
- Switcher merges "Sending from"/"Node running as" into one "Accounts" header, one flat-list note replacing both old empty-state notes

## Task Commits
1. Tracer: nest children under their main - `8fa53f3c` (feat)
2. Nesting edge cases and the registrations read - `0f51ac98` (test)
3. One "Accounts" section with the node-down note - `22addb51` (feat)

## Verification
Full suite 2192/5/0 (2173 baseline + 19 new). Analyze/format/brace/raw-colour clean. ID gate 0 on every commit.

## Self-Check: PASSED
