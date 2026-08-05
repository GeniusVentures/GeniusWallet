# 22-06 Semantic Deltas

Every change in this plan that is not strictly behaviour-identical, per the plan's
`use_build_context_synchronously` and `avoid_dynamic_calls` acceptance criteria. Nothing in
`unawaited_futures` counts as a behaviour delta (no `await` was added anywhere; every discarded
Future got `unawaited()`), but the full site-by-site table is included below for completeness and
audit -- no site was judged to genuinely need sequencing, so there are no Phase 23 candidates from
this rule family.

## `mounted` / `context.mounted` guards added (`use_build_context_synchronously`, 5 sites)

Each guard's only observable effect is on the path where the widget/State was disposed while an
`await` was in flight -- previously a throw, now a silent skip of the guarded UI-only statement(s).
No guard skips a wallet-affecting network/protocol call; each was placed to protect only the
BuildContext-touching statement, not the surrounding side effects.

| # | File:Line | Awaited operation | Guard form | What it protects | What still runs if unmounted |
|---|---|---|---|---|---|
| 1 | `lib/banxa/banxa_orders_history.dart:53` | `showDateRangePicker(...)` | `if (!context.mounted) { return; }` (added; `context` is a method parameter here) | `setState` for the picked date range + `context.read<OrdersCubit>().applyFilters(...)` | Nothing further in this branch -- the whole `if (picked != null)` body is UI-state-only, so returning early is safe |
| 2 | `lib/network/network_dropdown_selector.dart:73-75` | `ResponsiveDrawer.show<Network>(...)` | `if (!mounted) { return; }` (added; `context` here is `State.context`, a getter -- `context.mounted` alone did not satisfy the analyzer's flow check on a getter-based context, see note below) | `setState`, `widget.onNetworkSelected` callback, `walletCubit.selectNetwork(selected)`, the `ToastManager` toast, and the two `Hive` persistence writes | Nothing -- if unmounted the whole network-switch side effect (including the Hive persist) is skipped. This is a wider skip than a narrowly-scoped guard would give, but the widget being disposed mid-pick means the user navigated away from the selector entirely; the persisted network write is not safety-relevant (no key material), so the wider skip was accepted rather than fragmenting the guard around each statement |
| 3 | `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart:192-194` | `FlutterClipboard.copy(words.join(' '))` | `if (!context.mounted) { return; }` (pre-existing guard used `mounted` bare, checking the **enclosing State's** mounted flag while the actual context in scope was `BlocBuilder`'s own closure-local `context` parameter -- the analyzer correctly flagged this as an unrelated check; changed to `context.mounted` referencing the same local `context` used two lines later) | `ScaffoldMessenger.of(context).showSnackBar(...)` | N/A -- this statement was the only thing in the branch |
| 4 | `lib/reown/reown_connect_button.dart:165-171` | `ApproveDappConnectionDrawer.show(...)` | `if (mounted) { showAppSnackBar(...); }` (added, wrapping only the snackbar) | The "DApp connection was rejected" toast | **`walletKit.rejectSession(...)` still runs unconditionally** -- deliberately NOT gated on `mounted`, because skipping the WalletConnect protocol response would leave the dApp's connection request hanging with no reply. Only the UI toast (which cannot render on a disposed widget regardless) is skipped |
| 5 | `lib/reown/reown_connect_button.dart:418-420` | `_tryPair(Uri.parse(input))` | `if (!mounted) { return; }` (added, placed after `_didManualPair = true;`) | `Navigator.of(context).pop()` on the connect dialog | `_didManualPair = true` is set before the guard, so that bookkeeping happens regardless of mount state; only the dialog-pop navigation is skipped |

### Note on `context.mounted` vs bare `mounted` for `State`-owned context

During this task an inconsistency surfaced in how the analyzer's flow-sensitive check works: when
`context` is a **State's own getter** (re-evaluated on each access, e.g. `_showNetworkDrawer` and the
`reown_connect_button.dart` handler closures), `if (!context.mounted) { return; }` was **not**
recognized by the analyzer as guarding a later `context` use -- it reported "guarded by an unrelated
'mounted' check" even though the guard and the use both read `context`. Switching to the bare
`if (!mounted)` (State's own boolean field) resolved it. Conversely, when `context` is a **local
parameter or closure argument** (e.g. `_pickDateRange(BuildContext context)`, or a `BlocBuilder`'s
`builder: (context, state) => ...`), the analyzer wants `context.mounted`, not bare `mounted` -- using
bare `mounted` there checks the wrong (enclosing State's) object relative to the local context
actually used, and gets flagged as "unrelated" for the opposite reason. The rule applied throughout
this plan: match the guard to whichever `context` binding is actually used at the site --
`context.mounted` when `context` is a local/parameter, bare `mounted` when `context` is `State`'s own
getter.

## `avoid_dynamic_calls` -- parse sites needing deliberate failure-behaviour preservation

See the Task 3 commit for the full retyping; the sites below are the ones that needed active
thought to avoid changing what happens on a malformed payload (all preserved: silent null/empty
fallback, no new throw introduced).

All 20 sites preserved failure behaviour exactly: nothing that returned null/empty on malformed
data now throws, and nothing that threw before now silently swallows. The only change in *kind* of
exception is at sites that previously relied on a dynamic method/index dispatch failing with
`NoSuchMethodError` -- those now fail with `TypeError`/`CastError` from an explicit `as` cast
instead, since the cast is evaluated eagerly instead of the call being resolved (and failing) at
the point of use. This is not a behaviour change in the "does it throw" sense, only in the
exception's runtime type, which nothing in this codebase currently pattern-matches on.

Sites that needed active thought (not a mechanical `as Type` bolt-on):

- `lib/assets/read_asset.dart` `_fetchTokenData` (5 casts): `Web3.fetchTokenDetailsMulticall`
  returns `Future<Map<String, dynamic>>` with an already-known concrete shape
  (`symbol: String, decimals: int, name: String, balance: double`) -- read directly off
  `web3.dart`'s own construction of that map (`packages/genius_api/lib/web3/web3.dart`) rather than
  guessed. The `results.length < 4` early-return path there returns `{}`, so a missing key still
  produces the same throw (now `TypeError: type 'Null' is not a subtype of type 'String'` instead
  of `NoSuchMethodError` on `.isEmpty`) -- the "could not find token, skip" catch block still fires.
- `lib/banxa/banxa_model.dart` `BanxaKycResponse.fromJson`: `data`/`account` needed intermediate
  `Map<String, dynamic>?` typing (not just the leaf casts) since they are reused across two
  statements each.
- `lib/services/coin_gecko/coin_gecko_api.dart` historical-price entries: `entry[0] ~/ 1000` relied
  on `~/`'s dynamic dispatch working identically whether the CoinGecko timestamp arrives as `int` or
  `double`. `prices.cast<List<dynamic>>()` plus `(entry[0] as num) ~/ 1000` preserves that -- `num`
  still dispatches `~/` polymorphically, so an int-or-double timestamp both still work, only the
  cast on the outer `List` element is now explicit.
- `lib/reown/handle_dapp_requests.dart`: `SessionRequestEvent.params` is declared `dynamic` by the
  `reown_sign` SDK itself (not this codebase's choice), so the cast boundary is exactly at the
  SDK/app seam -- `(event.params as List<dynamic>)[0] as Map<String, dynamic>`. This is dApp
  transaction-approval input; preserving "throws on malformed params" here matters because a
  swallowed-and-defaulted malformed transaction is a worse failure mode than a visible crash.

## `unawaited_futures` -- 17 sites, all wrapped in `unawaited()`, zero `await` added

`git diff --unified=0 -- lib/ | grep '^\+' | grep -iE '\bawait\b'` returns nothing -- confirmed no
new `await` anywhere in `lib/`. Every site below is either genuine fire-and-forget UI/telemetry, or
(one case) a site where adding `await` would have introduced a real bug.

| # | File:Line | Future | Why fire-and-forget |
|---|---|---|---|
| 1 | `lib/account/sdk_account_manager.dart:333` | `HapticFeedback.lightImpact()` | Buzz feedback; sequencing it would only delay the snackbar for no benefit |
| 2 | `lib/banxa/banxa_api_services.dart:240` | `checkStatus()` (local closure) | **Awaiting this would be a bug**, not just a style choice -- see note below |
| 3 | `lib/components/wallet_information.dart:196` | `context.push('/buy')` | Fire navigation, no follow-up logic in the `onPressed` callback |
| 4 | `lib/reown/handle_dapp_requests.dart:180` | `SwapResultDrawer.show(...)` (success) | UI toast; awaiting would delay `pendingRequestIds.remove` and the Hive transaction write behind the user dismissing a dialog |
| 5 | `lib/reown/handle_dapp_requests.dart:208` (now further down after the wrap) | `SwapResultDrawer.show(...)` (failure) | Same reasoning as #4 |
| 6 | `lib/services/coin_gecko/coin_gecko_api.dart:288` | `geniusApi.updateAccountFetchDate()` | Bookkeeping timestamp write; the function returns `null` right after regardless of when the write lands |
| 7 | `lib/services/coin_gecko/coin_gecko_api.dart:298` | `geniusApi.saveAccountBalance(...)` | Persist-then-return-a-formatted-string; the UI does not need the persist to finish before showing the balance |
| 8 | `lib/submit_job/cubit/submit_job_cubit.dart:219` | `fetchGnusBalanceWithDelay()` | The function's own doc comment: a deliberate 5s-delayed background refresh; awaiting it would stall the `emit()` right after by 5 seconds |
| 9 | `lib/submit_job/cubit/submit_job_cubit.dart:228` | `fetchGnusBalance()` (inside the delayed helper) | Last statement in an already-detached helper; nothing consumes its `double?` result |
| 10 | `lib/web/web_utils.dart:16` | `context.push('/web', ...)` | Fire navigation from a `void ... async` helper with nothing after it |
| 11 | `lib/web/web_view_mobile.dart:172` | `_syncTitle(controller)` | Title-cache refresh is independent of the dark-mode JS injection that follows in the same callback |
| 12 | `lib/web/web_view_mobile.dart:185` | `controller.loadRequest(Uri.parse(url))` | Immediately followed by `return;` -- nothing to sequence against |
| 13 | `lib/web/web_view_windows.dart:89` | `_controller.loadUrl(widget.url)` | Followed by synchronous tab-list/subscription setup that must not wait on the page load |
| 14 | `test/boot_sequence_test.dart:114` | `rejecting.catchError((_) {})` | Test-harness technique (see the file's own comment): primes a second listener on the future so the zone doesn't report the deliberately-thrown error as unhandled; the priming itself must not block |
| 15-17 | `test/components/global_swap_fab_host_test.dart:115,142,175` | `router.push(...)` (GoRouter) | The returned `Future` only resolves when the pushed route is later **popped** -- awaiting it here would hang the test indefinitely; the test only needs the synchronous route-match state, read via the following `pumpAndSettle()` |

### `banxa_api_services.dart` -- confirmed a real bug would have been introduced by `await`

`pollOrderStatus`'s `checkStatus()` closure calls `timer?.cancel()` on success/failure/timeout, then
`timer = Timer.periodic(...)` is assigned on the very next line, unconditionally, after the initial
`checkStatus()` call. Tracing what `await checkStatus()` would have done: the assignment of `timer`
happens *after* the line that calls `checkStatus()`, but `checkStatus()` itself contains an
`await getOrderStatus(...)`, which is a real network round trip. With `await checkStatus();` in
place, `pollOrderStatus` would suspend at that call, and if `checkStatus()`'s first run resolved a
terminal status, its `timer?.cancel()` would fire on a **still-null `timer`** (a harmless no-op,
since it runs before line `timer = Timer.periodic(...)` ever executes) -- but then `timer =
Timer.periodic(...)` would run anyway, unconditionally, arming a live periodic poll for an already-
resolved `Completer`. On the next tick, `checkStatus()` would call `completer.complete(status)` a
second time on an already-completed `Completer`, throwing `Bad state: Future already completed`
uncaught inside the `Timer.periodic` callback (the function's own `catch` re-enters
`completer.completeError`, which throws again for the same reason). This is exactly the class of
regression the plan's "do not add `await`" rule exists to catch -- confirmed by tracing, not just
asserted. `unawaited()` is correct here for a reason beyond style: the existing "call once
synchronously, then start the interval timer" ordering is load-bearing.
