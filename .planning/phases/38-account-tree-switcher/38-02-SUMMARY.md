---
phase: 38-account-tree-switcher
plan: 02
subsystem: ui
tags: [flutter_bloc, account-tree, gw_menu_item]
requires: [{phase: 38-01, provides: "buildAccountTree, one Accounts header, ChildOperationsCubit.ownRegistrations()"}]
provides: ["GWMenuItem (promoted, shared by wallet/SDK/child menus)", "buildAccountTree wallets+links merge (AccountRowKind.wallet/merged)", "_AccountRowTile: one tile per account, Selected + On node tags"]
affects: [38-03]
actuals: {tokens: 65500, tasks: 2, commits: 3}
tech-stack:
  patterns: ["wallets-first root order: own wallets (merged or plain) walk before unmerged accounts, each root's own registrations nest depth-first"]
key-files:
  created: [lib/components/overlays/gw_menu_item.dart, test/components/gw_menu_item_test.dart]
  modified: [lib/account/account_tree.dart, lib/account/account_drawer.dart, lib/account/sdk_account_manager.dart, test/account/account_tree_test.dart, test/account/sdk_account_rows_test.dart, test/account/account_drawer_show_test.dart, test/account/sdk_account_delete_coupling_test.dart, test/account/account_drawer_tree_test.dart]
key-decisions:
  - "An unmerged main's registration of an elsewhere-merged account is superseded, not nested: wallets resolve their merge before unmerged accounts get a turn, so that account surfaces once at its own top-level row (account_drawer_tree_test.dart's threeChildren case)"
  - "SDK PENDING (not SDK) hides once Selected also shows on a wallet row - the two labels together overflow a phone-width row; SDK alone is short enough to keep both"
requirements-completed: [SWT-07]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 38 Plan 02: Merged account rows and node-switch menu Summary

**SDK accounts merge onto their linked wallet's row; tapping never touches the node, "Run node as this" in the menu does.**

## Accomplishments
- `GWMenuItem` promoted (Rule of Three) from `sdk_account_manager`'s and `child_wallets_screen`'s private menu-item widgets; the four SDK dialogs became top-level functions any row can call
- `buildAccountTree` takes `wallets`/`links`: each linked account renders once, merged onto its wallet's row; unlinked/removed-wallet accounts keep their own row; merged rows nest exactly like account rows
- `_AccountRowTile` replaces `SDKAccountRow` and the drawer's row helper: "Selected" and "On node" as independent `GWRowBadge` tags, "Run node as this" is the only path that dispatches `SelectSDKAccount`

## Task Commits
1. GWMenuItem + public SDK dialogs - `83c47922` (feat)
2. Merged-row tests - `8318083d` (test)
3. Merged-row implementation - `7aa20a5f` (feat)

## Deviations from Plan
- SDK PENDING badge additionally hides when the row is Selected (not just On node) - a phone-width overflow the plan's badge list didn't anticipate; documented above.
- `account_drawer_tree_test.dart`'s inherited `threeChildren` case changed meaning: the linked sibling now surfaces at its own merged row instead of nesting under the running main, since wallets resolve merges before the unmerged-accounts pass runs.

## Verification
Full suite 2201/5/0 (2192 baseline + 9 new: 4 GWMenuItem, 5 tree-merge unit tests). Analyze/format/brace/raw-colour/key-logging clean. ID gate 0 on every commit.

## Self-Check: PASSED
