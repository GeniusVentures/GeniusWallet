---
quick_id: 260731-hsb
phase: quick-260731-hsb
plan: 01
subsystem: ui
tags: [flutter, go_router, coingecko, coin-page, market-data]

key-files:
  created:
    - lib/tokens/token_info_args.dart
    - test/tokens/coin_page_entry_parity_test.dart
  modified:
    - lib/tokens/token_info_screen.dart
    - lib/navigation/router.dart
    - lib/dashboard/chart/markets_screen.dart
    - lib/dashboard/chart/dashboard_markets.dart
    - lib/components/coins/view/coins_screen.dart
    - lib/dashboard/home/view/dashboard_screen.dart
    - test/tokens/coin_page_stat_rail_test.dart
    - test/tokens/coin_page_range_tile_test.dart

key-decisions:
  - "The Info card's Address/Network rows now come from TokenInfoArgs.walletCoin/network, not the wallet cubit's selectedCoin/selectedNetwork - a Markets-opened coin drops both rows instead of printing the wallet's own address on a token you don't hold (flagged for the walk, not settled)."
  - "isGnusWalletConnected is computed once, in router.dart, via a StreamBuilder on GeniusApi.getSGNUSConnectionStream() - no push site carries it any more."
  - "Retry's own re-entry into the loading state (not a manual disabled flag) is what prevents a double-fire: the button structurally does not exist while a fetch is in flight."

duration: single continuous session (not timed to the minute)
completed: 2026-07-31
status: complete
---

# Quick Task 260731-hsb: Assets coin tap must open the same coin page as Markets - Summary

**Coin page now resolves its own market data (loading -> retry -> uncovered as three distinct, honest states) instead of collapsing a rate-limited fetch into "not covered by our market data provider"; one typed `TokenInfoArgs` payload replaces three divergent untyped `extra` maps, with a source-scanning test that fails on a fourth call site.**

## Accomplishments

- **Task 1 - One typed payload, one assembler.** Added `lib/tokens/token_info_args.dart` (`TokenInfoArgs`, `TokenInfoArgs.fromExtra`). All three `/token-info` push sites (`markets_screen.dart`, `dashboard_markets.dart`, `coins_screen.dart`) now build `TokenInfoArgs` instead of an untyped map. `router.dart`'s `/token-info` route is now the only place that decides `isGnusWalletConnected` (a `StreamBuilder` on `GeniusApi.getSGNUSConnectionStream()`, safe to read fresh here because the underlying controller is a `BehaviorSubject.seeded`). `dashboard_screen.dart`'s `ContributionsDashboardView` lost the `BlocBuilder`/`StreamBuilder` pair it only carried to compute that same flag.
- **Task 2 - The page resolves its own market data.** `TokenInfoScreen` is now a `StatefulWidget` with a four-state machine (`ready` / `loading` / `failed` / `uncovered`) instead of a single `marketData == null` check. `ready` (a warm start from Markets or the dashboard Markets panel) issues zero requests, unchanged from before. `loading` and a resolver failure/empty result (`failed`) are new: `failed` renders a Retry control and is the only new user-visible surface this plan adds. `uncovered` (no id and no data at all) keeps the exact old "No market data" wording verbatim - it is now the only state allowed to say that.
- **Task 3 - The parity gate.** `test/tokens/coin_page_entry_parity_test.dart`: a hand-rolled source scan of `lib/` asserts exactly three `/token-info` push call sites exist and every one passes a `TokenInfoArgs` (a fourth site, or one passing a bare map, fails the test by name); a second scan asserts no file in `lib/` carries `isGnusWalletConnected` inside a `/token-info` extra. Plus `TokenInfoArgs.fromExtra` round-trip tests, origin-label rendering, wallet-context row presence/absence, and the loading -> failed -> Retry -> resolved sequence driven through the injected `resolveMarketData` seam (no Hive, no network). The two pre-existing coin-page tests that constructed `TokenInfoScreen` directly (`coin_page_stat_rail_test.dart`, `coin_page_range_tile_test.dart`) were updated to the new `args:`/`isGnusWalletConnected:` constructor shape, preserving what each already asserted.

## Files Created/Modified

- `lib/tokens/token_info_args.dart` - new. The `TokenInfoArgs` payload + `fromExtra` (typed pass-through / legacy map coercion / const-empty fallback).
- `lib/tokens/token_info_screen.dart` - `StatelessWidget` -> `StatefulWidget`; new `_MarketDataStatus` enum, `_fetch`/`_retry`, `_chartSlot`/`_loadingCard`/`_failedCard`; `_buildInfoSection` now reads `widget.args.walletCoin?.address` / `widget.args.network` instead of the wallet cubit's selection; back link reads `widget.args.originLabel`.
- `lib/navigation/router.dart` - `/token-info` route rebuilt around `TokenInfoArgs.fromExtra(state.extra)` and a `StreamBuilder<SGNUSConnection>` that derives `isGnusWalletConnected` once, in one place.
- `lib/dashboard/chart/markets_screen.dart`, `lib/dashboard/chart/dashboard_markets.dart` - `_openToken`/`onTap` now push `TokenInfoArgs(coinGeckoId:, symbol:, marketData:)`; the unread `"coin"` key and the hardcoded `isGnusWalletConnected: false` are both gone.
- `lib/components/coins/view/coins_screen.dart` - `CoinsScreen.isGnusWalletConnected` constructor field removed (dead - the route derives the flag now); push site builds the full `TokenInfoArgs` including `walletCoin`/`network`/`originLabel: 'ASSETS'`.
- `lib/dashboard/home/view/dashboard_screen.dart` - `ContributionsDashboardView` collapsed to `DashboardScrollContainer(child: CoinsScreen(isUseDivider: true))`; the now-dead `sgnus_connection.dart` import removed.
- `test/tokens/coin_page_entry_parity_test.dart` - new, described above.
- `test/tokens/coin_page_stat_rail_test.dart`, `test/tokens/coin_page_range_tile_test.dart` - updated to the new `TokenInfoScreen(args:, isGnusWalletConnected:)` constructor.

## Decisions Made

- **Info card's Address/Network rows now source from `TokenInfoArgs`, not the wallet cubit.** This is a visible behavior change on Markets/dashboard-Markets: those two rows disappear for a Markets-opened coin instead of printing the currently-selected wallet's address/network - which used to be a *different token's* address on a row labelled "Address" for the coin you were actually looking at. Flagged for the walk (item 3 below); not silently assumed correct.
- **`isGnusWalletConnected` derivation moved to the route**, reusing the exact expression `dashboard_screen.dart` used to compute (`(connection?.walletAddress ?? false) == selectedWallet?.address`), justified by `SGNUSConnectionController` being a `BehaviorSubject.seeded` (a late subscriber gets the current value immediately, not just future changes).
- **Retry's mitigation for a double-fire (T-hsb-04) is structural, not a disabled flag**: tapping Retry re-enters `loading` synchronously, which unmounts the Retry button on the next frame - the control a second tap would need no longer exists.

## Deviations from Plan

**None from the plan's own three tasks - all executed as written**, including the two findings the plan explicitly acted on (Info card address/network sourcing, `isGnusWalletConnected` centralization) and the one it explicitly declined to touch (Receive/Bridge on a coin you don't hold - untouched, as instructed).

### Out-of-scope side effect (flagging, not hiding)

**Verification-tooling side effect, not a plan deviation.** Per the verification instructions, I ran `dart format --set-exit-if-changed lib test` across the whole tree as a final check. `--set-exit-if-changed` only changes the *exit code* on drift - it still writes formatting changes - and this repo currently has other quick tasks' uncommitted work sitting dirty in the same working tree (per this session's file-ownership note, `260731-hrn` owns `lib/submit_job/cubit/submit_job_cubit.dart` and related test files). That one broad command reformatted three files outside this plan's scope: `lib/submit_job/cubit/submit_job_cubit.dart`, `test/submit_job/job_flow_test.dart`, `test/submit_job/submit_job_errors_test.dart`.

- **What happened:** whitespace/line-wrap normalization only - `dart format` never changes semantics. `flutter analyze` (0 issues) and `flutter test test/submit_job/` (all passing) were re-run afterward to confirm nothing broke.
- **What I did NOT do:** revert it. These files already carried real, substantive uncommitted changes from the other in-flight session before I touched anything (confirmed via `git status` at the start of this session); a `git checkout --` on them would have destroyed that other session's work, which the destructive-git rules explicitly forbid. Leaving pure-whitespace formatting in place is the lower-risk option.
- **Recommendation:** whoever finishes `260731-hrn` should expect `git diff` on those three files to show only formatting noise from this session, not content loss - worth a quick visual scan before that task's own commit, but no action should be needed.
- **Going forward this session:** every later format check was scoped to only the files this plan touches, not run tree-wide again.

## Issues Encountered

None beyond the tooling side effect above.

## Verification

Run in order, actual output:

- **`flutter analyze`** - root package: `No issues found!` (0 issues). `packages/genius_api`: `No issues found!` (0 issues).
- **`flutter test`** (full suite) - **866 passing, 0 failing.** (Plan's stated baseline was 849; the extra tests beyond this plan's own +14 in `coin_page_entry_parity_test.dart` come from other quick tasks' work already landed in the same working tree this session - not something this plan added or can explain away, reported honestly rather than reconciled to a stale number.)
- **`tool/check_brace_style.sh`** - PASS (exit 0).
- **`tool/check_raw_colors.sh`** - PASS (exit 0).
- **`dart format`** - clean on every file this plan touches (two files needed one auto-format pass, applied; re-checked clean after).

**Nothing committed, nothing pushed** - per the plan's own instruction and this project's standing rule. Every change above sits in the working tree on `redesign/jakub-260730`.

## Known Stubs

None. No hardcoded empty values, placeholder text, or unwired data sources were introduced.

## Threat Flags

None beyond what the plan's own threat model already named and mitigated (T-hsb-01 through T-hsb-05 - all addressed in Tasks 1-2, see Decisions above and the plan's threat register).

## Next Phase Readiness

Code side is done and verified by tooling. **The human walk is the one thing standing between this and being callable "finished" - see below.** No blockers for anything downstream; the `TokenInfoArgs`/route-assembly pattern is now the shape any future coin-page entry point must follow (enforced by the parity test's census, currently locked at 3).

---

## Human walk - REQUIRED, OUTSTANDING (no live app instance this session)

This plan is marked `autonomous: false` for a reason: tests prove the *mechanism* (state transitions, payload shape, row presence) but not how the page actually *looks and feels* live. None of the items below have been walked. Concrete steps, in the plan's own order:

1. **Dashboard Assets -> USD Coin.** Run the app, open the dashboard, tap USD Coin in the Assets panel. Expect the full page: price, 24h pill, stat rail, chart, real INFO numbers - not "No market data". This is the exact defect that filed this task.
2. **Dashboard Assets -> GNUS.** Regression check on the coin that already worked. Same page as before, and - this is the one thing the `isGnusWalletConnected` move could break - the Bridge button still appears when the SGNUS wallet is connected.
3. **Markets -> Bitcoin.** Expect the page visually unchanged **except that the Info card's Address and Network rows are gone.** This is deliberate, not a bug: those two rows used to print your wallet's own address and network on a page showing a token you may not even hold - e.g. opening Bitcoin from Markets would show *your Ethereum USDC address* on a row labelled "Address" for Bitcoin. **You need to judge this in place.** If the Info card reads as too thin without those rows, the alternative that was NOT built is a row that says something like "Not in your wallet" instead of silently omitting it - tell me if you want that instead and I'll build it.
4. **Dashboard Markets panel -> any row.** Same page as (3) - same judgment call applies.
5. **Back link wording.** ASSETS from (1) and (2); MARKETS from (3) and (4). Tapping it should return to exactly where you came from in every case.
6. **Airplane mode, then Assets -> a coin whose price is not already cached.** Expect the new retryable error card (not "not covered by our market data provider"). Re-enable the network and tap Retry - the page should fill in without needing a reload.
7. **Both themes**, dark first per the standing rule. The loading and Retry-error cards are the only genuinely new surfaces this plan adds - check the Retry button's contrast in both.

## Self-Check: PASSED

All files listed above under Files Created/Modified were verified present on disk after writing this summary.

---
*Quick task: 260731-hsb*
*Completed: 2026-07-31*
