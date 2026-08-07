---
status: awaiting_human_verify
trigger: "gdy robie mock transactions albo populate, to potem nagle te transakcje znikaja. Prosze zobacz dlaczego sie tak dzieje."
created: 2026-08-07T12:45:00Z
updated: 2026-08-07T13:40:00Z
---

## Current Focus

hypothesis: CONFIRMED for the HOLDINGS leg - two unguarded emits in `WalletDetailsCubit` overwrite injected mock coins. NOT reproduced for the transactions leg; its known cause was already fixed on 2026-07-31.
test: `test/dev/dev_mock_holdings_race_test.dart`, run with `--dart-define=GW_DEV_TOOLS=true`.
expecting: RED before the fix on cases 1 and 2, GREEN after, with case 3 (mock mode OFF) green throughout to prove the live path is untouched.
next_action: Jakub re-tests `Populated` on device and confirms the rows stay; and reports whether vanished mock TRANSACTIONS are still present behind `View all` (which would identify the 5-row dashboard cap rather than a state loss).

reasoning_checkpoint:
  hypothesis: "`getCoins()` checks `mockMode` before `await coinFuture` but not after, so a read already in flight when a MOCK button is pressed emits its live result over the injected fixtures. Separately, `loadInitial()` rebuilds state from the CONSTRUCTOR, dropping `coins`, with no `mockMode` guard at all."
  confirming_evidence:
    - "Live log: `[boot-timing] getCoins settled in 28517ms` - a 28.5-second in-flight window on Jakub's actual device, far wider than the time it takes to press a button."
    - "Code: `wallet_details_cubit.dart` guard at line 172 is before the await; the success emit re-checked only `isClosed`."
    - "Executable: `dev_mock_holdings_race_test.dart` case 1 failed with `Actual: [Coin(name: Super Genius, balance: 7.0)]` where the injected fixtures were expected - the overwrite, reproduced deterministically with no network."
    - "Executable: case 2 failed with `Actual: []` - `loadInitial` wiping coins outright."
  falsification_test: "If injected coins survived a `getCoins()` that was already awaiting, or if `loadInitial` preserved `coins`, the hypothesis would be dead. Both tests failed at HEAD in exactly the predicted way, and both pass after the guard was added."
  fix_rationale: "Re-reads `mockMode` AFTER the await (the `act` half of a check-then-act pair whose `check` had gone stale) and preserves `coins` across a wallet reload. Addresses the overwrite itself, not the symptom - it does not stop the fetch, does not cache the flag, and does not touch the real path, which case 3 pins by asserting the live read still wins with mock mode off."
  blind_spots: "The TRANSACTIONS half of Jakub's report is NOT explained by this fix. I could not find any live path that removes an injected transaction from either store, and the one that used to exist was fixed a week ago. The dashboard's 5-row cap remains an untested candidate for a PERCEIVED transaction vanish and needs one question answered on device."

## Symptoms

expected: Mock holdings injected via `Populated` and mock transactions injected via `Mock txns` stay on screen until `Clear` is pressed (both are documented STICKY).
actual: Rows appear, then some time later vanish on their own with no user action.
errors: No Dart-side exception near the vanish. Live log carries a continuous `SuperGeniusNode` retry loop (`Error starting blockchain: Blockchain not fully initialized`, every 5s) and a bootstrap peer disconnect/reconnect every 30s.
reproduction: Run with `--dart-define=GW_DEV_TOOLS=true`, open the dev-tools bubble, press `Populated` (or `Mock txns`), wait.
started: Not established. Both dev affordances are recent (mock txns = quick task 260720-jvr).

## Eliminated

- hypothesis: The `CoinsScreen` 1-minute periodic market-data refresh overwrites the injected holdings.
  evidence: `lib/components/coins/view/coins_screen.dart:64-70` only calls `_fetchMarketData`, and `_fetchMarketData` early-returns into `DevMockHoldings.instance.marketData` under `kDebugMode && mockMode` (lines 82-92). It writes `_marketData` local state only - it never emits to `WalletDetailsCubit` and never touches `state.coins`. The timer cannot remove a row.
  timestamp: 2026-08-07T12:50:00Z

- hypothesis: The real SGNUS poll overwrites the injected mock transactions.
  evidence: `packages/genius_api/lib/controllers/sgnus_transactions_controller.dart` keeps locally-added transactions in a SEPARATE `_locallyAdded` map. `setTransactions()` clears only `_transactions`; `_emit()` re-unions both. The 10s poll in `sgnus_transactions_screen.dart:32` therefore cannot drop a locally-added row. File is committed and clean in the working tree, so this protection is live in the running build.
  timestamp: 2026-08-07T12:52:00Z

- hypothesis: `TransactionsCubit` loses the injected batch.
  evidence: `lib/dashboard/transactions/cubit/transactions_cubit.dart` is append-only - `addTransaction`, `addTransactions` and `loadInitial` all `addAll` into a `Set` and re-emit. The ONLY removal is `clear()`, whose sole caller is the dev bubble's own Clear button (`dev_tools_bubble.dart:753`). State cannot shrink without a user press.
  timestamp: 2026-08-07T12:53:00Z

- hypothesis: The Bloc providers remount, producing fresh empty cubits.
  evidence: `MultiBlocProvider` sits at the app root in `lib/main.dart:325-357`, ABOVE `MaterialApp.router` and above the `ValueListenableBuilder<GWAppearanceMode>`. Theme/appearance changes and route changes both rebuild strictly below it, so `create:` cannot re-run.
  timestamp: 2026-08-07T12:54:00Z

## Evidence

- timestamp: 2026-08-07T12:42:00Z
  checked: Live-session log `gw.log` for Dart-side output.
  found: Three `[boot-timing] getCoins settled in ...` lines - **28517ms**, 477ms, 143ms. The network legs around them time out and fall back to cache (`TimeoutException after 0:00:03`, `Connection closed before full header was received, uri=https://eth.drpc.org`, CoinGecko 429).
  implication: `getCoins()` can stay in flight for nearly THIRTY SECONDS on this device/network. That is a very wide window for a user to press a MOCK button inside.

- timestamp: 2026-08-07T12:44:00Z
  checked: `lib/wallets/cubit/wallet_details_cubit.dart` guard placement.
  found: The `kDebugMode && kShowDevTools && mockMode` guard is at the TOP of `getCoins()` (line 172) and returns early. But the success emit at lines 224-239 is reached after `await coinFuture` and is guarded ONLY by `if (!isClosed)`. `mockMode` is never re-checked after the await.
  implication: The guard protects against a getCoins STARTED after injection. It does nothing about one already past the guard and awaiting the network. This is the classic check-then-await-then-act race.

- timestamp: 2026-08-07T12:56:00Z
  checked: `lib/bloc/app_bloc.dart:128-132` and `lib/wallets/cubit/wallet_details_cubit.dart:92-109`.
  found: `_onLoadWallets` calls `walletDetailsCubit.loadInitial(...)`, which emits a FRESH `WalletDetailsState(...)` via the constructor rather than `copyWith`, discarding `coins` entirely. `loadInitial` has no `mockMode` guard at all, and does not reset `mockMode` either.
  implication: A SECOND, independent way injected holdings are wiped. Reachable from pull-to-refresh (`dashboard_screen.dart:149`, `_onRefresh`) - easy to trigger by accident while scrolling on a phone. Worse than the race: because `mockMode` stays true afterwards, `getCoins()` is still short-circuited, so the holdings stay EMPTY rather than reverting to real data.

- timestamp: 2026-08-07T13:05:00Z
  checked: rxdart 0.27.7 `Subject.stream` identity, since `sgnus_transactions_screen.dart` builds its `StreamBuilder` stream inline on every build.
  found: `Subject.stream` returns a NEW `_SubjectStream(this)` per call, but `_SubjectStream` overrides `operator ==` and `hashCode` to compare by wrapped-subject identity. `StreamBuilder.didUpdateWidget` therefore sees an equal stream and does NOT resubscribe.
  implication: Eliminates a resubscribe-flicker explanation for transactions blanking. No frame of empty state is produced by rebuilds.

- timestamp: 2026-08-07T13:15:00Z
  checked: `git log` on `sgnus_transactions_controller.dart` and the existing `test/dev/mock_transactions_sticky_test.dart`.
  found: The transactions-vanish bug was ALREADY diagnosed and fixed in commit `8c172866` (2026-07-31). Its test states the old mechanism verbatim: `setTransactions` "opened with `_transactions.clear()`, so the fixtures lived at most ten seconds, and were gone the instant the user navigated". The `_locallyAdded` map closed it, and that test (5 cases) still passes.
  implication: The known transactions cause predates Jakub's report by a week and is not live. Either his transactions observation is the holdings panel, or it is the dashboard cap below - it is NOT a state loss in either transaction store.

- timestamp: 2026-08-07T13:20:00Z
  checked: `kDashboardTransactionsCap` in `transactions_slim_view.dart` against the injected batch size.
  found: The dashboard panel renders only the 5 most recent of the 11 injected transactions (`groupTransactionsByDay(txs, limit: 5)` sorts newest-first, then takes 5). The batch's newest row is `minutesAgo(3)`.
  implication: UNTESTED CANDIDATE for a perceived transactions vanish. If the real SGNUS feed ever returns rows newer than `minutesAgo(3)`, the 10s poll hands them to `setTransactions` and they take all five dashboard slots, pushing every mock row off the PANEL while leaving them present on the uncapped `/transactions` page. Distinguishable on device by one question - see Resolution.

## Resolution

root_cause: |
  HOLDINGS leg (`Populated` / `Long` / `No icon` / `Unpriced`) - CONFIRMED, two
  independent unguarded emits in `lib/wallets/cubit/wallet_details_cubit.dart`:

  1. `getCoins()` is a check-then-act race. The
     `kDebugMode && kShowDevTools && mockMode` guard runs BEFORE
     `await coinFuture`; the success emit after the await re-checked only
     `isClosed`. A read already in flight when a MOCK button is pressed
     therefore emits its live coin list over the injected fixtures. The delay
     the user sees is simply the fetch's remaining time - measured at 28517ms
     on Jakub's device, with the RPC timing out and CoinGecko rate-limiting.
     Race windows are opened by the splash boot, the token page, the
     transactions route, the assets screen, job submit, pull-to-refresh and
     any network/wallet switch.

  2. `loadInitial()` rebuilds state from the CONSTRUCTOR rather than
     `copyWith`, so it resets `coins` to `const []`, and had no `mockMode`
     guard. Reachable from `LoadWallets` - boot, but also the dashboard's
     pull-to-refresh, one accidental overscroll away on a phone. This one is
     worse: `mockMode` stayed true afterwards, so the `getCoins()` guard then
     blocked the refetch too and the panel sat EMPTY rather than reverting to
     real holdings.

  TRANSACTIONS leg - NOT REPRODUCED. The mechanism that caused it was fixed in
  commit 8c172866 (2026-07-31), a week before this report. No remaining path
  removes an injected transaction from either store (see Eliminated).

fix: |
  Two dev-gated guards, both led by the `kDebugMode && kShowDevTools` const
  pair so a release build constant-folds them away and the production data
  path is byte-for-byte unchanged - the same release-safety rule and ordering
  the file's existing guard documents.

  1. `getCoins()`: re-read `mockMode` AFTER `await coinFuture`, before the
     emit, and return if it is set.
  2. `loadInitial()`: when mock mode is on, do the reload's real work
     (wallet, network, initStatus) through `copyWith`, which preserves
     `coins`. Deliberately does not overwrite `selectedWalletBalance`, which
     belongs to the fixture total.

verification: |
  `test/dev/dev_mock_holdings_race_test.dart` (new), run with
  `--dart-define=GW_DEV_TOOLS=true`:
    - BEFORE: case 1 failed (injected fixtures replaced by the live GNUS
      coin), case 2 failed (`coins` reset to `[]`). Case 3 passed.
    - AFTER: all 3 pass.
  Case 3 ("with mock mode OFF the live read still wins") is the regression
  guard against a fix that gated the live read too broadly.

  Gates, measured on this branch rather than assumed:
    - `flutter analyze`: 0 issues before, 0 issues after.
    - `flutter test`: 1157 passing / 0 failing before; 1158 passing, 3 skipped,
      0 failing after. The 3 skips are the new file self-skipping without the
      define (the repo's established convention for dev-gated branches - see
      `test/dev/dev_mock_sgnus_test.dart`). The +1 passing is another agent's
      concurrent work in this shared tree, not mine.
    - `test/dev/mock_transactions_sticky_test.dart` re-run alone: 5/5 pass.

  NOT verified: on-device confirmation by Jakub, and the transactions half of
  the report.

files_changed:
  - lib/wallets/cubit/wallet_details_cubit.dart
  - test/dev/dev_mock_holdings_race_test.dart
