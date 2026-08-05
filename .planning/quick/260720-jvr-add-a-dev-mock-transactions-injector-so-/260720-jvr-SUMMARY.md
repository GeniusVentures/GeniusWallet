---
phase: quick-260720-jvr
plan: 01
subsystem: ui
tags: [flutter, dev-tooling, transactions, transactions-cubit, sgnus-transactions-controller, mock-data]

requires:
  - phase: 05-dashboard
    provides: 05-06 transactions area re-skin (TransactionsSlimView, transaction_displays.dart, TransactionsCubit)
  - phase: quick-260720-bgl
    provides: DevToolsBubble draggable dev-only overlay widget
  - phase: quick-260720-cw8
    provides: DevMockHoldings fixture pattern (private-ctor singleton) mirrored by this task's DevMockTransactions
provides:
  - DevMockTransactions dev-only fixture singleton (batch(isSgnus:) -> 8 deterministic varied Transaction objects)
  - "Mock txns" button in the dev-tools bubble's MOCK section, injecting into both TransactionsCubit and the SGNUS controller
  - MOCK "Clear" extended to also clear TransactionsCubit and the SGNUS controller
affects: [05-dashboard]

tech-stack:
  added: []
  patterns:
    - "Dev-only fixture singleton (private ctor + static final instance), model-only import, mirrors DevMockHoldings' established shape"
    - "Dual-path injection: one button call writes into both the regular-wallet cubit and the SGNUS controller so it is reachable regardless of wallet type, instead of branching on wallet type at the call site"

key-files:
  created:
    - lib/dev/dev_mock_transactions.dart
  modified:
    - lib/dev/dev_tools_bubble.dart

key-decisions:
  - "batch(isSgnus:) is NOT gated on WALLET_PK / isWalletPKBypass (unlike dev_overrides.dart's auto-injectors) — it is button-driven and must always return the set when pressed, per the plan"
  - "Swap transaction's fromIconUrl/toIconUrl left null deliberately — TransactionSwappedItem guards both with `if (... != null)`, so leaving them null keeps the whole batch offline (no NetworkImage fetch)"
  - "Each of the 8 transactions gets a unique descending timeStamp (base DateTime(2026,7,20,12,0) minus an increasing minute offset) and a unique hash (0xdevmock01..08) so TransactionsCubit's Set-dedup and timeStamp-descending sort stay stable across repeated presses"

requirements-completed: [QUICK-260720-jvr]

coverage:
  - id: D1
    description: "DevMockTransactions singleton created with a single batch(isSgnus:) method returning 8 deterministic Transaction objects covering sent/received directions, transfer/mint/escrow/escrowRelease/purchase/swap types, failed AND completed statuses, and one long-value amount"
    requirement: "QUICK-260720-jvr"
    verification:
      - kind: other
        ref: "flutter analyze lib/dev/dev_mock_transactions.dart"
        status: pass
    human_judgment: false
    rationale: "Pure data fixture, fully verified by analyze (0 errors, model-only import) plus the deterministic table it encodes matching every field the plan specified."
  - id: D2
    description: "'Mock txns' button added to the bubble's MOCK section, injecting the batch into TransactionsCubit.addTransactions (regular path) and the SGNUS controller's addTransaction per tx (SGNUS path) in one press; MOCK 'Clear' extended to also call TransactionsCubit.clear() and getSGNUSTransactionsController().clear()"
    requirement: "QUICK-260720-jvr"
    verification:
      - kind: other
        ref: "flutter analyze lib/dev/dev_tools_bubble.dart"
        status: pass
    human_judgment: true
    rationale: "Whether the varied set actually renders correctly in the 05-06 transactions view (filters, count footer, failed error-state row, long-value overflow guard, Clear reset) in both light and dark can only be confirmed by exercising the running debug build — covered by the plan's Task 3 blocking human-verify checkpoint, not yet performed."

duration: ~15min
completed: 2026-07-20
status: complete
---

# Quick Task 260720-jvr: Add a dev mock-transactions injector Summary

**Dev-only `DevMockTransactions` fixture singleton feeds an 8-item varied, deterministic, offline transaction batch through a new "Mock txns" button in the dev-tools bubble, wired into both `TransactionsCubit` (regular wallet path) and the SGNUS controller (SGNUS wallet path) so the 05-06 transactions view is walkable on any wallet type.**

## Performance

- **Duration:** ~15 min
- **Tasks:** 2 of 3 (both auto tasks complete; Task 3 is a blocking human-verify checkpoint, not performed by this run per its explicit instructions)
- **Files modified:** 2 (1 created, 1 modified)

## Accomplishments

- Created `lib/dev/dev_mock_transactions.dart`: a private-ctor singleton (`DevMockTransactions.instance`) exposing `batch({required bool isSgnus})`, which returns 8 `Transaction` objects built directly against the real constructor (confirmed field-by-field against `transaction.dart`). The spread covers: (1) normal Sent, (2) normal Received, (3) Mint filter, (4) Escrow filter/pending, (5) escrow-release ("Completed job")/also Escrow filter, (6) failed purchase (the error-state row), (7) swap with null icon URLs (offline-safe), (8) a long-value amount (`123456789.123456789123456789`) stressing the row overflow guard. Imports only the `Transaction` model — no cubit/controller/widget imports.
- Wired a new "Mock txns" `_devButton` into the bubble's MOCK `Wrap`, before "Clear": on press it calls `context.read<TransactionsCubit>().addTransactions(DevMockTransactions.instance.batch(isSgnus: false))` and separately reads the SGNUS controller once and calls `.addTransaction(tx)` per tx from `batch(isSgnus: true)`, then shows a success toast (mirroring the existing "Add tx" button's pattern).
- Extended the existing MOCK "Clear" button (kept its two existing calls) to additionally call `context.read<TransactionsCubit>().clear()` and `context.read<GeniusApi>().getSGNUSTransactionsController().clear()`, so one press now resets holdings and both transaction sources.

## Task Commits

Each auto task was committed atomically:

1. **Task 1: Create the DevMockTransactions fixture singleton** - `8886d90` (feat)
2. **Task 2: Wire "Mock txns" + extend "Clear" in the bubble's MOCK section** - `e127935` (feat)

Task 3 is a `checkpoint:human-verify` gate (`gate="blocking"`) — not a commit-producing task. Per this run's instructions, the walk was intentionally NOT performed by the executor.

## Files Created/Modified

- `lib/dev/dev_mock_transactions.dart` - New dev-only fixture singleton: `batch(isSgnus:)` returning the 8-item deterministic varied transaction set.
- `lib/dev/dev_tools_bubble.dart` - New "Mock txns" button in the MOCK section; MOCK "Clear" extended to also clear `TransactionsCubit` and the SGNUS controller; new `DevMockTransactions` and `TransactionsCubit` imports.

## Decisions Made

- Not gated on `WALLET_PK`/`isWalletPKBypass` — button-driven, must always return the set when pressed (matches plan instruction, diverges intentionally from `dev_overrides.dart`'s auto-injector gating).
- Swap transaction's `fromIconUrl`/`toIconUrl` left `null` to keep the entire batch offline, per the plan's explicit OFFLINE constraint.
- Unique descending `timeStamp`s and unique `hash`es per tx (rather than reusing a single `DateTime.now()`/counter-based hash like `getFakeTransaction`) to keep `TransactionsCubit`'s `Set`-based dedup and `timeStamp`-descending sort deterministic and stable.

## Deviations from Plan

None - plan executed exactly as written for Tasks 1-2.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Outstanding

**Task 3 (`checkpoint:human-verify`, `gate="blocking"`) has NOT been performed.** Exact recipe (from `260720-jvr-PLAN.md`), to run on the ALREADY-RUNNING `GW_DEV_TOOLS=true` debug build (do NOT start a new build/run), on a REGULAR (non-SGNUS) wallet:

1. Open the dev bubble -> MOCK section -> press "Mock txns". Navigate to the Transactions view. Confirm a varied set of transactions appears (previously nothing appeared on a regular wallet).
2. Filters + footer: exercise the Sent, Received, Escrow, and Mint segmented filters — each narrows the list correctly — and confirm the "Transactions: N" count footer updates to match.
3. Failed state: confirm the failed purchase renders as a "Buy - Failed" error-state row (red/statusError).
4. Overflow: confirm the long-value amount row does NOT overflow (no RenderFlex yellow-black stripes; amount ellipsizes/fits).
5. Clear: press MOCK "Clear" and confirm transactions empty back to the "No transactions yet" empty state (and holdings clear too).
6. Repeat the light + dark check via the bubble's APPEARANCE toggle — rows, filters, failed row, and footer all read correctly in both modes.

Resume signal: "approved" or a description of issues found.

## Next Phase Readiness

- Code changes are analyze-clean and committed (`8886d90`, `e127935`); no blockers for continuing other work.
- The Task 3 walk should be run before/alongside the phase-05 transactions (05-06) walk, since it's this quick task's whole reason for existing — unblocking a varied transactions view for that walk.

---
*Quick task: 260720-jvr-add-a-dev-mock-transactions-injector-so-*
*Completed: 2026-07-20*

## Self-Check: PASSED

- FOUND: lib/dev/dev_mock_transactions.dart
- FOUND: lib/dev/dev_tools_bubble.dart
- FOUND: .planning/quick/260720-jvr-add-a-dev-mock-transactions-injector-so-/260720-jvr-SUMMARY.md
- FOUND: 8886d90
- FOUND: e127935
