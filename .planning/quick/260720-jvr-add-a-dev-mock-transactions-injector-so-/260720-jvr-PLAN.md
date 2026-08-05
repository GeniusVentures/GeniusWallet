---
quick_id: 260720-jvr
type: execute
autonomous: false
files_modified:
  - lib/dev/dev_mock_transactions.dart
  - lib/dev/dev_tools_bubble.dart
requirements: []
must_haves:
  truths:
    - "On a REGULAR wallet, pressing the bubble's MOCK 'Mock txns' button makes a varied set of transactions appear in the 05-06 transactions view (previously nothing appeared — the old 'Add tx' fed only the SGNUS controller)."
    - "The injected set exercises the Sent, Received, Escrow and Mint filters, the count footer, a failed error-state row, and a long-value amount against the row overflow guard."
    - "The MOCK 'Clear' button empties transactions (both TransactionsCubit and the SGNUS controller) as well as holdings."
    - "The fixture is dev-only (imports only the Transaction model), lives in lib/dev/, and touches no production data path."
  artifacts:
    - lib/dev/dev_mock_transactions.dart
  key_links:
    - "DevMockTransactions.batch(isSgnus:) -> context.read<TransactionsCubit>().addTransactions(...) (regular wallet path via TransactionsStream/TransactionsSlimView)"
    - "DevMockTransactions.batch(isSgnus:true) -> context.read<GeniusApi>().getSGNUSTransactionsController().addTransaction(tx) per tx (SGNUS wallet path)"
    - "MOCK 'Clear' -> TransactionsCubit.clear() + getSGNUSTransactionsController().clear() (alongside existing DevMockHoldings.clear + WalletDetailsCubit.clearMock)"
---

<objective>
Add a dev-only Mock-transactions injector to the dev-tools bubble's MOCK section so the phase 05-06 transactions view is walkable on ANY wallet, offline, with a varied set of transactions.

The transactions screen branches on wallet type: SGNUS wallet -> SgnusTransactionsScreen (SGNUS controller), REGULAR wallet -> TransactionsStream -> BlocBuilder<TransactionsCubit, List<Transaction>>. The bubble's existing "Add tx" injects ONLY into the SGNUS controller via getFakeTransaction(true), so on a regular wallet nothing appears. getFakeTransaction is also always status=completed / amount "0.5" ETH — no variety for the walk (which needs sent/received/failed states, all filters, the count footer, and a long-value overflow check).

Purpose: unblock the 05-06 transactions walk without live/on-chain state; keep growing the dev Mock section per the pending todo.
Output: a new lib/dev/dev_mock_transactions.dart fixture (mirroring DevMockHoldings) + a "Mock txns" button and an extended "Clear" in the bubble's MOCK section.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@lib/dev/dev_mock_holdings.dart
@lib/dev/dev_tools_bubble.dart
@packages/genius_api/lib/models/transaction.dart
@lib/test/dev_overrides.dart
@lib/dashboard/home/widgets/transactions_slim_view.dart
@lib/dashboard/home/widgets/transaction_displays.dart
@lib/dashboard/transactions/cubit/transactions_cubit.dart
@packages/genius_api/lib/controllers/sgnus_transactions_controller.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create the DevMockTransactions fixture singleton</name>
  <files>lib/dev/dev_mock_transactions.dart</files>
  <action>
Create a dev-only fixture that mirrors the DevMockHoldings pattern (private ctor `DevMockTransactions._();` + `static final DevMockTransactions instance = DevMockTransactions._();`). Import ONLY the Transaction model (`package:genius_api/models/transaction.dart`) — NO cubit, controller, or widget imports. Open with a DEV-ONLY doc comment matching dev_mock_holdings.dart's tone (offline, deterministic, never used outside kDebugMode && kShowDevTools).

Expose one method: `List<Transaction> batch({required bool isSgnus})`. It returns a VARIED, DETERMINISTIC set of ~8 Transaction objects, each built directly with the real constructor (getFakeTransaction lacks the variety/failed/long cases). Confirm every field name against transaction.dart's constructor: required { hash, fromAddress, recipients (List<TransferRecipients>, each requires `toAddr` and `amount` — both String, non-empty), timeStamp (DateTime), transactionDirection (TransactionDirection.sent|received), fees (String), coinSymbol (String), transactionStatus (TransactionStatus.pending|cancelled|completed|failed) }; optional { isSGNUS, type (TransactionType.transfer|mint|escrow|process|escrowRelease|purchase|swap), plus swap fields fromIconUrl/fromAmount/toIconUrl/toAmount/exchangeRate/fromSymbol/toSymbol }.

Determinism + ordering: give each tx a UNIQUE, descending `timeStamp` (e.g. a fixed base `DateTime(2026, 7, 20, 12, 0)` minus an increasing number of minutes per item) and a UNIQUE `hash` (e.g. "0xdevmock01".."0xdevmock08"). Unique timestamps keep TransactionsCubit's Set-dedup + timeStamp-descending sort stable. Stamp EVERY tx's `isSGNUS` from the `isSgnus` param.

Build this exact spread so the walk exercises every branch of TransactionsSlimView (Filters: Sent, Received, Escrow=escrow+escrowRelease, Mint) and transaction_displays.dart's type switch:
  1. type transfer, direction sent, status completed, coinSymbol "ETH", recipients amount "0.75" — normal Sent row.
  2. type transfer, direction received, status completed, coinSymbol "BTC", recipients amount "0.0042" — normal Received row.
  3. type mint, direction received, status completed, coinSymbol "GNUS", recipients amount "1200" — exercises the Mint filter.
  4. type escrow, direction sent, status pending, coinSymbol "GNUS", recipients amount "500" — exercises the Escrow filter; a non-completed status for variety.
  5. type escrowRelease, direction received, status completed, coinSymbol "GNUS", recipients amount "500" — renders the "Completed job" TransactionEscrowReleaseItem; also matches the Escrow filter.
  6. type purchase, direction sent, status failed, coinSymbol "ETH", recipients amount "100" — the failed error-state row (TransactionPurchasedItem renders "Buy - Failed" in statusError red). This is the criterion-4 failed case.
  7. type swap, direction sent, status completed, coinSymbol "ETH", recipients amount "1.0", fromSymbol "ETH", toSymbol "USDC", fromAmount "1.0", toAmount "3200". Leave fromIconUrl AND toIconUrl NULL — TransactionSwappedItem guards both with `if (... != null)`, and leaving them null keeps the walk fully OFFLINE (a non-null URL would trigger a NetworkImage fetch).
  8. type transfer, direction sent, status completed, coinSymbol "ETH", recipients amount a LONG value that stresses the row overflow guard (TransactionItem's trailing amount Text has no ellipsis) — e.g. "123456789.123456789123456789". This is the criterion-5 long-value case.

Every tx MUST have a non-empty `recipients` list with a real `toAddr` (e.g. "0xToMocked...") and the `amount` above — TransactionItem, TransactionPurchasedItem, and the details drawers all read `recipients.first.amount`/`.toAddr`. Set `fees` to a plausible string (e.g. "0.001") and `fromAddress` to a mock address on every tx.

Do NOT gate on WALLET_PK / isWalletPKBypass (that guards dev_overrides' auto-injectors); this is button-driven and must always return the set when pressed.
  </action>
  <verify>
    <automated>flutter analyze lib/dev/dev_mock_transactions.dart</automated>
  </verify>
  <done>lib/dev/dev_mock_transactions.dart exists, analyzes with 0 errors, imports only the Transaction model, and batch(isSgnus:) returns ~8 deterministic txns covering sent/received directions; transfer/mint/escrow/escrowRelease/purchase/swap types; at least one failed AND completed status; and one long-value amount.</done>
</task>

<task type="auto">
  <name>Task 2: Wire "Mock txns" + extend "Clear" in the bubble's MOCK section</name>
  <files>lib/dev/dev_tools_bubble.dart</files>
  <action>
Add `import 'package:genius_wallet/dev/dev_mock_transactions.dart';` and `import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';` (GeniusApi is already imported and already used by the existing "Add tx" button). Confirmed in scope: TransactionsCubit is provided at app root (main.dart:297) and already read via `context.read<TransactionsCubit>()` in responsive_overlay.dart where DevToolsBubble mounts.

In the MOCK `_Section`'s `Wrap` (the one currently holding Populated / Long / No icon / Clear), add a `_devButton('Mock txns', ...)` BEFORE the 'Clear' button, using the existing `_devButton` helper so it matches the other Mock buttons. Its onPressed injects into BOTH paths so it shows regardless of wallet type (no wallet-type branching needed):
  - Regular path: `context.read<TransactionsCubit>().addTransactions(DevMockTransactions.instance.batch(isSgnus: false));`
  - SGNUS path: read `context.read<GeniusApi>().getSGNUSTransactionsController()` once, then for each tx in `DevMockTransactions.instance.batch(isSgnus: true)` call `.addTransaction(tx)` (mirror the existing 'Add tx' wiring, which builds the controller the same way).
  Optionally show a success ToastManager toast like the existing 'Add tx' button (e.g. "Mock transactions added"); keep it consistent with that button's pattern.

Extend the existing MOCK 'Clear' button so one press resets holdings AND transactions. Keep its current two calls (`DevMockHoldings.instance.clear();` + `context.read<WalletDetailsCubit>().clearMock();`) and ADD: `context.read<TransactionsCubit>().clear();` and `context.read<GeniusApi>().getSGNUSTransactionsController().clear();` (SGNUSTransactionsController exposes `clear()` — confirmed). Do NOT add a separate "Clear txns" button — extend the existing Clear per the locked decision.

Use only existing tokens/helpers (GWButton via `_devButton`, GeniusWalletConsts spacing) — no raw hex/px. Do not touch the TEST FLOWS 'Add tx' button or any other section.
  </action>
  <verify>
    <automated>flutter analyze lib/dev/dev_tools_bubble.dart</automated>
  </verify>
  <done>The MOCK section shows a new "Mock txns" button that injects the batch into both TransactionsCubit and the SGNUS controller; the MOCK "Clear" now also clears both transaction sources; flutter analyze reports 0 errors on the file.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>A dev-only "Mock txns" injector in the bubble's MOCK section (fixture lib/dev/dev_mock_transactions.dart) that populates the 05-06 transactions view with a varied, offline, deterministic set on any wallet, plus an extended MOCK "Clear" that empties transactions as well as holdings.</what-built>
  <how-to-verify>
Run the ALREADY-RUNNING GW_DEV_TOOLS=true debug build (do NOT start a new flutter build/run). On a REGULAR (non-SGNUS) wallet:
1. Open the dev bubble -> MOCK section -> press "Mock txns". Navigate to the Transactions view. Confirm a varied set of transactions appears (previously nothing appeared on a regular wallet).
2. Filters + footer: exercise the Sent, Received, Escrow, and Mint segmented filters — each narrows the list correctly — and confirm the "Transactions: N" count footer updates to match.
3. Failed state: confirm the failed purchase renders as a "Buy - Failed" error-state row (red/statusError).
4. Overflow: confirm the long-value amount row does NOT overflow (no RenderFlex yellow-black stripes; amount ellipsizes/fits).
5. Clear: press MOCK "Clear" and confirm transactions empty back to the "No transactions yet" empty state (and holdings clear too).
6. Repeat the light + dark check via the bubble's APPEARANCE toggle — rows, filters, failed row, and footer all read correctly in both modes.
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| (none new) | Dev-only fixture + button gated behind the bubble's existing `kDebugMode && kShowDevTools` mount (responsive_overlay.dart:318/345). No new external input, no network, no production data path. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-jvr-01 | Tampering | mock data leaking into a production path | low | mitigate | Fixture lives in lib/dev/, imports only the Transaction model, is invoked solely by the dev-gated bubble; no real transactions store is written. |
| T-jvr-SC | Tampering | package installs | low | accept | No npm/pip/cargo/pub packages added — reuses existing model + cubit/controller APIs only. |
</threat_model>

<verification>
- `flutter analyze lib/dev/dev_mock_transactions.dart lib/dev/dev_tools_bubble.dart` reports 0 errors.
- Human walk (blocking checkpoint) confirms varied txns appear on a regular wallet, filters + count footer work, the failed row shows the error state, the long-value row does not overflow, Clear empties them, in both light and dark.
- `flutter test` intentionally NOT used (does not compile — see STATE.md blocker). No flutter build/run (a debug build is already running).
</verification>

<success_criteria>
- DevMockTransactions fixture created in lib/dev/, model-only imports, deterministic varied batch (sent/received; transfer/mint/escrow/escrowRelease/purchase/swap; failed AND completed; one long-value amount).
- "Mock txns" button injects into both TransactionsCubit and the SGNUS controller; MOCK "Clear" clears both.
- Both files analyze clean; no production path or the 05-06 re-skin changed; no raw hex/px introduced.
- Human walk approved in both light and dark.
</success_criteria>

<output>
Staging: explicit paths ONLY (README.md is dirty — never `git add -A`). Do NOT commit docs or update ROADMAP.md.
Stage `lib/dev/dev_mock_transactions.dart` and `lib/dev/dev_tools_bubble.dart` for the code commit after the walk is approved.
</output>
