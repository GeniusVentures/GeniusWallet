---
phase: 35-unified-header-switcher
plan: 01
subsystem: ui
tags: [flutter, bloc, account-switcher, sdk-accounts]
requires: [34-account-linking]
provides: [two-section AccountDrawer, public SDKAccountRow, showAddSdkAccountDialog, View balance, ACTIVE ON NODE badge]
affects: [35-02, 35-03]
key-files:
  modified: [lib/account/sdk_account_manager.dart, lib/account/account_drawer.dart]
key-decisions:
  - "AccountDrawer keeps its class name; the switcher naming lands with the desktop chip in plan 03"
  - "ACTIVE ON NODE replaces the SDK/SDK PENDING badge on the same row rather than stacking"
requirements-completed: [SWT-02, SWT-03, SWT-04, SWT-05]
duration: 55min
completed: 2026-09-29
status: complete
---

# Phase 35 Plan 01: Two-section switcher drawer

AccountDrawer shows two independent, always-rendered sections ("Sending from" / "Node running as") sharing one SDKAccountRow widget.

## Built
- "Sending from" (own wallets) above "Node running as" (SDK accounts), with explicit empty states ('No wallets yet.', 'Node not running', 'No SDK accounts yet').
- Selections are independent: own-wallet taps call WalletDetailsCubit.selectWallet, SDK taps dispatch SelectSDKAccount; re-tapping the selected SDK row is a no-op.
- Public `SDKAccountRow` and top-level `showAddSdkAccountDialog`, shared by the legacy chip drawer and the switcher; new "Add from phrase or key" button under the node section.
- "View balance" selects the linked SGNUS wallet (case-insensitive address match), disabled when none exists.
- The wallet linked to the node's active SDK account shows ACTIVE ON NODE instead of SDK.
- The four SDK account test files now open the real drawer via `AccountDrawer.show`.

## Notes
- No deviations from plan.
- TDD RED for task 2 found 3 of 5 behaviours already correct after task 1; only View balance and ACTIVE ON NODE needed new code.
- One test needed `_SelectingApi` (stubs `getSelectedAccountMnemonic`) instead of the plain fake once a real SDKAccountRow rendered.

## Verification
- Full suite: 1952 passed / 5 skipped / 0 failed (1945 baseline + 7 new).
- `flutter analyze lib test`: 0 issues.
