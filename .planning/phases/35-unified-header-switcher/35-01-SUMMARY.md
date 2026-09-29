---
phase: 35-unified-header-switcher
plan: 01
subsystem: ui
tags: [flutter, bloc, account-switcher, sdk-accounts]

requires:
  - phase: 34-account-linking
    provides: sdkAccountName, linkedWallet, sdkDeleteBlock, ACTIVE ON NODE badge pattern
provides:
  - Two-section AccountDrawer ("Sending from" / "Node running as"), always rendered
  - Public SDKAccountRow widget and top-level showAddSdkAccountDialog
  - View balance menu item selecting a linked SGNUS wallet
  - ACTIVE ON NODE badge, mutually exclusive with the SDK/SDK PENDING badge
affects: [35-02, 35-03]

actuals:
  tokens: 16400
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns:
    - "SDKAccountRow: a public row widget extracted from a private _buildAccountRow method, reused by both the legacy chip drawer and the new switcher"
    - "Independent-selection drawer sections: own-wallet taps call WalletDetailsCubit.selectWallet, SDK-account taps dispatch SelectSDKAccount, neither touches the other"

key-files:
  created: []
  modified:
    - lib/account/sdk_account_manager.dart
    - lib/account/account_drawer.dart
    - test/account/account_drawer_show_test.dart
    - test/account/account_drawer_network_section_test.dart
    - test/account/sdk_account_rows_test.dart
    - test/account/sdk_add_account_test.dart
    - test/account/sdk_start_account_delete_test.dart
    - test/account/sdk_account_delete_coupling_test.dart

key-decisions:
  - "AccountDrawer keeps its class name; no new account_switcher_drawer.dart file this plan (that naming lands in plan 03 for the desktop chip)"
  - "ACTIVE ON NODE suppresses the SDK/SDK PENDING badge on the same row rather than stacking both"

patterns-established:
  - "Row-name collisions between an SDK row and its linked own wallet are resolved in tests with find.descendant(of: find.byType(SDKAccountRow), ...)"

requirements-completed: [SWT-02, SWT-03, SWT-04, SWT-05]

coverage:
  - id: D1
    description: "Two-section drawer: 'Sending from' (own wallets) above 'Node running as' (SDK accounts), both always rendered with explicit empty states"
    requirement: SWT-04
    verification:
      - kind: automated_ui
        ref: "test/account/account_drawer_show_test.dart#the guard: a drawer opened from a bare context"
        status: pass
      - kind: automated_ui
        ref: "test/account/account_drawer_show_test.dart#a running node with zero accounts reads No SDK accounts yet"
        status: pass
    human_judgment: false
  - id: D2
    description: "The two selections are independent: an own-wallet tap never calls the SDK, an SDK tap never changes the active wallet, re-tapping the selected SDK row is a no-op"
    requirement: SWT-05
    verification:
      - kind: automated_ui
        ref: "test/account/account_drawer_show_test.dart#the two selections stay independent"
        status: pass
    human_judgment: false
  - id: D3
    description: "View balance selects the linked SGNUS wallet (case-insensitive address match) and is disabled when none exists"
    requirement: SWT-03
    verification:
      - kind: automated_ui
        ref: "test/account/account_drawer_show_test.dart#View balance selects the linked sgnus wallet"
        status: pass
    human_judgment: false
  - id: D4
    description: "The own wallet linked to the node's active SDK account shows ACTIVE ON NODE instead of SDK"
    requirement: SWT-02
    verification:
      - kind: automated_ui
        ref: "test/account/account_drawer_show_test.dart#the wallet linked to the active SDK account shows ACTIVE ON NODE"
        status: pass
    human_judgment: false
  - id: D5
    description: "Create, import, select and delete for SDK accounts all proven through the real switcher drawer rather than the standalone chip host"
    verification:
      - kind: automated_ui
        ref: "test/account/sdk_account_rows_test.dart, sdk_add_account_test.dart, sdk_start_account_delete_test.dart, sdk_account_delete_coupling_test.dart"
        status: pass
    human_judgment: false

duration: 55min
completed: 2026-09-29
status: complete
---

# Phase 35 Plan 01: Two-section switcher drawer Summary

**AccountDrawer now shows two independent, always-rendered sections ("Sending from" / "Node running as") with a shared SDKAccountRow widget, View balance, and an ACTIVE ON NODE badge that replaces SDK on the node's own active row.**

## Performance

- **Duration:** 55 min
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments
- `account_drawer.dart`'s body renders "Sending from" (own wallets) above "Node running as" (SDK accounts), both always present with explicit empty states ('No wallets yet.', 'Node not running', 'No SDK accounts yet') instead of the old vanishing SDK section
- `sdk_account_manager.dart` now exposes a public `SDKAccountRow` widget and a top-level `showAddSdkAccountDialog`, shared by the legacy chip drawer and the new switcher
- SDK row menu gained "View balance" (enabled only when a linked SGNUS wallet exists) and a new "Add from phrase or key" button sits under the node section
- The own wallet linked to the node's active SDK account now shows ACTIVE ON NODE instead of SDK, with the two badges never stacking
- All four SDK account test files (`sdk_account_rows_test.dart`, `sdk_add_account_test.dart`, `sdk_start_account_delete_test.dart`, `sdk_account_delete_coupling_test.dart`) now open the real switcher via `AccountDrawer.show` instead of the standalone `SDKAccountManagerButton` host

## Task Commits

Each task was committed atomically:

1. **Task 1: Two-section drawer with SDK rows, opened from the phone pill** - `3cef42b1` (feat)
2. **Task 2: View balance, Add from phrase or key, ACTIVE ON NODE, independence tests** - `dc75607b` (feat)
3. **Task 3: SDK row tests run against the switcher drawer** - `f51e808f` (test)

## Files Created/Modified
- `lib/account/sdk_account_manager.dart` - `SDKAccountRow` widget, `showAddSdkAccountDialog`, View balance menu item
- `lib/account/account_drawer.dart` - two-section body, ACTIVE ON NODE wiring, `_sgnusWalletFor` helper, "Add from phrase or key" button
- `test/account/account_drawer_show_test.dart` - updated section-header pins, new independent-selection and View balance/ACTIVE ON NODE tests
- `test/account/account_drawer_network_section_test.dart` - updated pins, new WalletPill test proving the phone trigger opens the same two-section body
- `test/account/sdk_account_rows_test.dart`, `sdk_add_account_test.dart`, `sdk_start_account_delete_test.dart`, `sdk_account_delete_coupling_test.dart` - re-pointed at `AccountDrawer.show`

## Decisions Made
- Kept the class name `AccountDrawer` rather than introducing `AccountSwitcherDrawer` this plan, per `35-PATTERNS.md`'s override note - avoids touching `mobile_header.dart`, `more_sheet.dart`, `wallet_overview.dart`
- ACTIVE ON NODE suppresses the SDK/SDK PENDING badge on the same row instead of showing both, since a row that is the node's active account is always linked

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- The RED phase of Task 2's TDD block found 3 of 5 named behaviors already correct from Task 1's move (SDK-tap independence, re-tap no-op, "No SDK accounts yet" wording); only View balance and the ACTIVE ON NODE badge needed new production code. Documented rather than forced into an artificial failing state.
- One test (`the wallet linked to the active SDK account shows ACTIVE ON NODE`) initially crashed on a `noSuchMethod` from the plain `_FakeGeniusApi` when it rendered a real `SDKAccountRow` for the first time with a non-empty `sdkAccounts` seed; fixed by passing `_SelectingApi` (which stubs `getSelectedAccountMnemonic`) instead of the default fake.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
Plan 02 and 03 (desktop chip, `AccountSwitcher`) can now build on a stable `AccountDrawer`/`SDKAccountRow` pair. Full test suite: 1952 passed / 5 skipped / 0 failed (1945 baseline + 7 new). `flutter analyze lib test`: 0 issues.

## Self-Check: PASSED

All 9 files (8 modified + this SUMMARY) confirmed present; all 3 task commit hashes (`3cef42b1`, `dc75607b`, `f51e808f`) confirmed in git log.

---
*Phase: 35-unified-header-switcher*
*Completed: 2026-09-29*
