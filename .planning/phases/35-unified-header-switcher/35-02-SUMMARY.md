---
phase: 35-unified-header-switcher
plan: 02
subsystem: ui
tags: [flutter, bloc, wallet-safety, send, swap]

requires:
  - phase: 35-unified-header-switcher
    provides: AccountDrawer.show as the switcher entry point (35-01)
provides:
  - GWCopyRow optional caption line, additive and byte-identical when omitted
  - SendTransactionDetails fromWalletName on the From row
  - Swap's From-wallet line and Switch link above its submit button
affects: [35-03]

actuals:
  tokens: 3771
  tasks: 2
  commits: 3

tech-stack:
  added: []
  patterns:
    - "GWCopyRow.caption: an optional display-only line rendered above the mono value inside the same Flexible, never touching the clipboard write"
    - "_SwapFromWallet: a private StatelessWidget using context.select<WalletDetailsCubit, Wallet?> so only the From line rebuilds on a wallet switch"

key-files:
  created: []
  modified:
    - lib/components/data/gw_copy_row.dart
    - lib/reown/send_transaction_details.dart
    - lib/send/send_screen.dart
    - lib/squid_router/swap_screen.dart
    - test/components/gw_copy_row_test.dart
    - test/send/send_screen_test.dart
    - test/squid_router/swap_submit_test.dart

key-decisions:
  - "Send's fromWalletName is null unless the selected wallet's lowercased address equals the signing address, so a mid-review wallet switch never mislabels the address"
  - "Swap's From line placed directly above the CTA with the existing space4 gap kept, per the UI-SPEC's space6-below-line note"

requirements-completed: [SWT-05]

coverage:
  - id: D1
    description: "Send's review 'From' row shows the active wallet's name above the short address when it is genuinely the signer; address alone otherwise"
    requirement: SWT-05
    verification:
      - kind: automated_ui
        ref: "test/send/send_screen_test.dart#the review drawer names the signing wallet on the From row"
        status: pass
      - kind: unit
        ref: "test/components/gw_copy_row_test.dart#a caption renders above the value, and tapping still copies the FULL value"
        status: pass
    human_judgment: false
  - id: D2
    description: "Every other GWCopyRow caller, including the Reown dApp approval drawer, renders exactly as before"
    requirement: SWT-05
    verification:
      - kind: automated_ui
        ref: "test/reown/approve_drawer_contract_test.dart"
        status: pass
      - kind: unit
        ref: "test/components/gw_copy_row_test.dart#a null or empty caption adds no extra text"
        status: pass
    human_judgment: false
  - id: D3
    description: "Swap shows 'Sending from {name} · {short address}' (or the short address alone when unnamed) above its CTA, with a Switch link opening the account drawer and no change to the CTA's submit behaviour"
    requirement: SWT-05
    verification:
      - kind: automated_ui
        ref: "test/squid_router/swap_submit_test.dart#names the wallet the swap will spend from"
        status: pass
    human_judgment: false

duration: 35min
completed: 2026-09-29
status: complete
---

# Phase 35 Plan 02: Wrong-account guard on Send and Swap Summary

**Send's review 'From' row and Swap's submit button now both name the wallet that will actually sign, via an additive GWCopyRow.caption and a new _SwapFromWallet widget reading WalletDetailsCubit directly.**

## Performance

- **Duration:** 35 min
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- `GWCopyRow` gained an optional `caption` field, rendered as a line above the mono value inside the same cell; `null`/empty renders byte-identical to before, and the clipboard write is untouched
- `SendTransactionDetails`'s From row takes an optional `fromWalletName`, wired only from `send_screen.dart`'s own review -- `handle_dapp_requests.dart` and `dev_tools_bubble.dart` are untouched
- `send_screen.dart` names the wallet only when its lowercased address matches the address that is actually signing, so a wallet switch mid-review cannot mislabel the transaction
- `swap_screen.dart` gained `_SwapFromWallet`, a widget reading the active wallet via `context.select` and rendering `'Sending from {name} · {short address}'` (or the short address alone when unnamed) plus a `Switch ›` link that opens `AccountDrawer.show`; the CTA ladder and `_submitSwap` are unchanged

## Task Commits

Each task was committed atomically:

1. **Task 1: Send review names the From wallet** - `2700afae` (feat)
2. **Task 2: Swap names its From wallet beside the submit button** - `9dd54ffd` (test, RED) / `4148c640` (feat, GREEN)

## Files Created/Modified
- `lib/components/data/gw_copy_row.dart` - optional `caption` field, rendered above `_displayValue`
- `lib/reown/send_transaction_details.dart` - optional `fromWalletName`, passed as the From row's `caption`
- `lib/send/send_screen.dart` - `_review` computes `fromWalletName` from the selected wallet only when its address matches the signer
- `lib/squid_router/swap_screen.dart` - new `_SwapFromWallet` widget, placed above `_buildSwapCta`
- `test/components/gw_copy_row_test.dart` - caption-shown and null/empty caption cases
- `test/send/send_screen_test.dart` - the From row names 'Send Wallet' after `_openReview`
- `test/squid_router/swap_submit_test.dart` - `_SeededCubit`/`_mountReady` gained an optional `wallet` param; three new cases for the named/unnamed line and unchanged submit behaviour

## Decisions Made
- Send's `fromWalletName` is computed as null unless the selected wallet's lowercased address equals `cubit.walletAddress` lowercased (T-35-05's mitigation) -- a mismatch falls back to the address alone rather than naming the wrong wallet
- Swap's TDD RED phase intentionally left the third named behaviour ("no confirm step, CTA unchanged") to an existing-shape assertion, since it needed no new production code to pass

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
Plan 03 (desktop chip / `AccountSwitcher`) can proceed independently -- this plan touched no header or drawer trigger code. Full test suite: 1958 passed / 5 skipped / 0 failed (1952 baseline + 6 new). `flutter analyze lib test`: 0 issues. `dart format --set-exit-if-changed lib test`: clean. `check_brace_style.sh` / `check_raw_colors.sh`: clean.

## Self-Check: PASSED

All 7 modified files (4 lib + 3 test) confirmed present; all 3 commit hashes (`2700afae`, `9dd54ffd`, `4148c640`) confirmed in git log.

---
*Phase: 35-unified-header-switcher*
*Completed: 2026-09-29*
