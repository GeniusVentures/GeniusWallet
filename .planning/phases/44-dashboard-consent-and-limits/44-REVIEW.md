---
phase: 44-dashboard-consent-and-limits
reviewed: 2026-10-28T00:00:00Z
depth: deep
files_reviewed: 13
files_reviewed_list:
  - lib/gnus_bridge/gnus_rpc_handler.dart
  - lib/gnus_bridge/gnus_connection_store.dart
  - lib/gnus_bridge/gnus_rpc_contract.dart
  - lib/gnus_consent/gnus_prompts.dart
  - lib/reown/approve_transaction_drawer.dart
  - lib/settings/connected_sites_cubit.dart
  - lib/settings/connected_sites_section.dart
  - lib/settings/settings_screen.dart
  - lib/dev/dev_gnus_bridge.dart
  - lib/dev/dev_tools_bubble.dart
  - lib/main.dart
  - lib/hive/init.dart
  - lib/hive/constants/cache.dart
findings:
  critical: 2
  warning: 6
  info: 8
  total: 16
status: issues_found
fix_status: criticals and warnings fixed (WR-06 partial); IN-01/02/03/05/08 fixed
fixed_at: 2026-10-28
---

# Phase 44: Code Review Report

**Reviewed:** 2026-10-28
**Depth:** deep (commits 75b796fe..206c1d24, read with `git show`, not the working tree)
**Files Reviewed:** 13 source files; tests read where they bear on a finding (`gnus_prompt_limits_test.dart`, `gnus_secret_leak_test.dart`)
**Status:** issues_found

## Summary

The checks inside the handler hold up. All six methods call `_requireConnected` after param validation and before readiness. Same-origin prompts cannot stack. The 3-per-minute count includes declined and timed-out prompts. `eventsFor` checks the connection on every event and keeps `gnus_jobUpdated` to the origin's own jobs. A revoke while the confirm is open burns nothing. The confirm shows the exact cost: `formatTokenAmount` is BigInt-exact and the burn uses the same `minions`. The Hive store goes through a repository and a cubit. The leak sweep covers results, errors, events, `debugPrint` and Sentry.

The serious gaps are at the edges of that logic:
- The "one prompt" rule applies per origin, but every drawer shares the root navigator and its buttons pop whichever route is on top.
- The origin is a free string. Nothing ties it to a transport or puts it in canonical form, so the exact scheme+host+port rule (D-03) is not enforced anywhere.

## Critical Issues

### CR-01: Prompts from different origins stack, and Approve pops whichever route is on top
**Status:** fixed (f5e94c28 for typed keys, 9abd49b2). One prompt wallet-wide: any prompt request from any origin while one is open gets `-32005 confirm_open`; the 3/minute per-origin limit stays. Approve, Reject and the drawer's close button pop only their own route (`ResponsiveDrawer.close`). Tests: two origins racing, and a covered Approve resolving nothing. Note: the exact finger-held scenario is already blocked by Flutter, which cancels active pointers on push; the drawer fix covers any other activation that reaches a covered drawer.

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:173,556-559`; `lib/reown/approve_transaction_drawer.dart:88,98`; `lib/gnus_consent/gnus_prompts.dart:64,94`
**Issue:** `_promptOpen` is a per-origin set, so origin B can open a prompt while origin A's is on screen. Both drawers go on the root navigator (`navigatorKey.currentContext`, `useRootNavigator: true`). The footer buttons call `Navigator.of(context).pop(true)` with that root context, which pops the top route, not the drawer the button belongs to. WalletConnect and Send drawers share the same navigator.
**Scenario:** The user has their finger down on Approve in A's connect prompt, or in a WalletConnect transaction drawer. A connected origin B calls `gnus_submitJob`, and its spend confirm is pushed in the same instant. The pointer-up still reaches A's button, which pops B's route with `true`. `showGnusSpendConfirm` sees `answer == true`, so B's job burns GNUS and A's drawer stays open. Without the race there is still a confusion problem: B's "Pay for a processing job" drawer sits on top of the prompt the user was answering, and the origin appears only in small secondary text.
**Fix:** Make the open prompt wallet-wide. Make every drawer resolve only its own route.
```dart
// handler: one gnus prompt at a time, whichever origin
if (_promptOpen.isNotEmpty) {
  throw _confirmOpen();
}

// drawer: answer only for this route
onPressed: () {
  final route = ModalRoute.of(innerContext);
  if (route != null && route.isCurrent) {
    Navigator.of(innerContext).pop(true);
  }
},
```
The drawer fix is needed even with the wallet-wide lock, because a gnus prompt can still land on top of a WalletConnect or Send drawer. Add a test that pushes a second route under a pending Approve tap.

### CR-02: The origin is an unchecked, transport-blind string, so a WalletConnect peer can take over a WebView connection
**Status:** fixed (f5e94c28). `GnusOrigin` = transport (webview | walletconnect) + canonical origin, built only by `GnusOrigin.tryParse`/`parse` (4100). `handle`, `eventsFor`, both seams, the prompt limits and the connection store take it; the store keys on both. Prompts and Settings show the transport. Job records and idempotency keys stay scoped to the canonical origin string the contract exposes, not the transport: `listJobs` already shows every job of the node to any connected caller, so splitting them would protect nothing. No migration: no release ever stored a connection.

**File:** `lib/gnus_bridge/gnus_connection_store.dart:27-35`; `lib/gnus_bridge/gnus_rpc_handler.dart:350,532-537,556-574`
**Issue:** Connections, the `confirm_open` set and the rate-limit buckets all key on the raw `origin` string. Nothing records which transport the origin came from, nothing parses it, and nothing puts it in canonical form. A WalletConnect origin is just the peer's self-declared `metadata.url`.
**Scenario:**
- A dApp pairs over WalletConnect and declares `https://dashboard.gnus.ai`. `isConnected` is true from the WebView's earlier connection, so it reads accounts and jobs with no prompt. Its spend confirm shows the trusted origin.
- `https://a.com`, `https://a.com:443`, `HTTPS://A.COM` and `https://a.com/` are four separate connections, each with its own 3-per-minute bucket and its own open-prompt slot.
- `""` and `"null"` (opaque origins) are accepted and can be connected.

Today only the dev bubble calls `handle`, so this is latent. But the Hive key format `sha256(origin)` ships now, so fixing it after the transports land means migrating stored connections.
**Fix:** Parse the origin once, at `handle()`, into a value type. Reject anything that does not parse with 4100 before any other check.
```dart
final class GnusOrigin {
  GnusOrigin._(this.transport, this.value);
  final String transport; // 'webview' | 'walletconnect'
  final String value;     // scheme://host:port, lowercased, explicit port
  static GnusOrigin? parse(String transport, String raw) { /* Uri.parse; https only (http only for localhost in dev);
     no userinfo/path/query/fragment; host non-empty; port = uri.port */ }
  String get storeKey => '$transport|$value';
}
```
Key the store, `_promptOpen` and `_promptTimes` on `storeKey`, and show the transport on the prompts and in Settings.

## Warnings

### WR-01: A revoke that lands after the post-confirm recheck still burns, and the burn reply becomes 4100
**Status:** fixed (10d86648). `beforeBroadcast` refuses when the origin is no longer connected: nothing is sent, the intent is dropped, the call answers 4100. Won't fix the second half (returning `burnTxHash` to a page revoked after its burn was sent): per D-09 a revoked page gets 4100; it recovers the hash by reconnecting and calling `gnus_getJob` with its key.

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:1160-1220,355`
**Issue:** `_recheckAfterConfirm` is the last connection check. After it come `putIntent` and the whole of `bridgeOut` (nonce, gas, signing over RPC), which can take seconds, and none of it checks the connection again.
**Scenario:** The user approves, opens Settings and revokes. The burn is broadcast anyway. Then `handle()` throws away the successful result and returns `4100`, so the page never receives `burnTxHash`. It only gets it back by reconnecting and retrying the same key.
**Fix:** Check again at the last moment before sending:
```dart
beforeBroadcast: (hash) async {
  if (!_connections.isConnected(origin)) {
    throw _unauthorized;
  }
  signedHash = hash;
  ...
```
Then call `_dropIntent` on that path, since nothing was sent. For a burn that already completed, either return the reply or put `burnTxHash` in the 4100 `data` so the page can recover it.

### WR-02: Approve on the spend confirm accepts a tap the moment the drawer appears
**Status:** fixed (1c089342). Approve arms 500 ms after the drawer's entrance completes, in `ApproveTransactionDrawer`, so WalletConnect requests get it too.

**File:** `lib/reown/approve_transaction_drawer.dart:92-99`; `lib/gnus_consent/gnus_prompts.dart:102`
**Issue:** The button is live from the first frame. The page itself starts the drawer by calling `gnus_submitJob`, so it controls when the drawer appears.
**Scenario:** A connected page asks the user to "double-click to continue", with its bait placed where Approve renders on a bottom sheet. The first click calls submit, and the second click lands on Approve as the sheet slides in.
**Fix:** Disable Approve until the route's entrance animation has completed, plus about 500 ms (`ModalRoute.of(context)!.animation` status listener).

### WR-03: The connect prompt's title is the origin, and the title is cut off with an ellipsis
**Status:** fixed (4a7e4c6b). Title is "Connect a site"; the origin is the wrapping headline.

**File:** `lib/gnus_consent/gnus_prompts.dart:71`; `lib/components/bottom_drawer/responsive_drawer.dart:247-250` (`maxLines: 1, overflow: ellipsis`)
**Scenario:** `https://dashboard.gnus.ai.attacker.example` shows in bold as `https://dashboard.gnus.ai.att…` on a phone. The full origin appears only in the smaller grey line below. The comment on line 57 of the drawer says a look-alike must be readable whole, and the title undoes that.
**Fix:** Give the drawer a fixed title ("Connect a site") and pass the origin as the `DappCallDetails` headline, which wraps.

### WR-04: The dev Submit can burn real GNUS if the JOB fixture is disarmed while the confirm is open
**Status:** fixed (9a968239). The post-confirm recheck refuses with `-32603 missing_data` when the fixture that priced the job is not the one that would burn it (either direction). Its test runs only with `--dart-define=GW_DEV_TOOLS=true`; run that way it passes, and fails with the guard removed.

**File:** `lib/dev/dev_gnus_bridge.dart:32-42`; `lib/submit_job/job_submission.dart:240`
**Issue:** `devGnusSubmit` checks the fixture only when the button is pressed. `JobSubmission._submit` reads `devScenario` again at burn time, after a confirm that can stay open for up to 10 minutes.
**Scenario:** In a debug build, the developer presses Submit. With the confirm open, they disarm JOB in the bubble and then press Approve. The cost and balance came from the fixture, but `bridgeOut` really burns `DevMockJob.jobCost` GNUS from the selected wallet. The comment "nothing here can burn real GNUS" (bubble line 913) is false.
**Fix:** Carry `priced.fixtureBalance != null` into `_burnAndRecord`. After the confirm, refuse with `-32603 missing_data` when it no longer matches `_jobs.devScenario != null`.

### WR-05: A failed revoke is silent
**Status:** fixed (c9e95f05). The cubit catches the store error and returns false; Settings shows an error toast and the row stays.

**File:** `lib/settings/connected_sites_cubit.dart:22-25`; `lib/settings/connected_sites_section.dart:88-89`
**Issue:** `revoke` has no try/catch, and the button drops the returned future.
**Scenario:** A Hive delete that throws (box closed, disk full) becomes an unhandled zone error. There is no feedback, and the site stays connected on a security control the user believes they just used.
**Fix:** Catch the error in the cubit and surface it (a toast "Could not revoke this site", or an error field in the state). Add a test with a failing store.

### WR-06: The spend confirm shows no native fee and no network
**Status:** partial (23452365). Added a Network row (passed by the handler from the network the post-confirm check pins) and relabelled the row "Gas price". Won't fix the native fee: the owner (`getBrigeOutGasCost`) reports a price only, no gas limit, so a fee needs an owner change first. "Not available" stays: an estimate that fails is refused before the confirm, so this only shows when the price string does not parse, and the signer sets the price anyway.

**File:** `lib/gnus_consent/gnus_prompts.dart:99-119`
**Issue:**
- The row labelled "Bridge gas" shows a gas price (`30 Gwei (POL)`), which reads like an amount the user will pay. The actual native fee is never shown.
- When `gas` is null the row reads "Not available" and Approve still burns.
- The chain the burn happens on (Amoy or mainnet) is not shown at all.

**Scenario:** The user approves `N GNUS` without knowing which chain it burns on or what the transaction will cost in native currency.
**Fix:** Label the row "Gas price", or better, compute `gasLimit * price` in the owner and show the fee. Add a "Network" row from `selectedNetwork.name`.

## Info

### IN-01: The `eventsFor` doc comment is 4 lines, over the AGENTS.md limit of 3
**Status:** fixed (36b91717).
**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:189-192`. Trim to 3 lines.

### IN-02: `_toastBridge` sits between `_devButton`'s doc comment and `_devButton`
**Status:** fixed (36b91717).
**File:** `lib/dev/dev_tools_bubble.dart:1446-1462`. The `GWButton` doc now documents `_toastBridge`. Move `_toastBridge` above the comment.

### IN-03: The comment on `_promptTimes` is false
**Status:** fixed (9abd49b2). Buckets are pruned on every prompt.
**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:171-174,566,573`. The comment says "an origin's entry goes when it empties", but nothing ever removes an entry. With CR-02, the keys are page-chosen strings. Remove the key when `recent` is empty, or correct the comment.

### IN-04: The rate-limit window uses the wall clock
**Status:** won't fix. Optional; the tests drive the window through the injected clock.
**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:560-563`. Setting the system clock forward clears the window. Use a monotonic `Stopwatch`-backed clock for the window and keep `_now` for `connectedAt`.

### IN-05: The raw origin goes into logs and Sentry breadcrumbs
**Status:** fixed (f5e94c28, 36b91717). Logs carry the canonical origin, whose host is limited to `[a-z0-9.:-]` and 253 characters.
**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:356,362,368`. A WalletConnect `metadata.url` is chosen by the page and can contain newlines that forge log lines. Log the canonical form from CR-02, capped in length.

### IN-06: The balance is not re-checked after the confirm
**Status:** won't fix. Optional; a reverted burn is already handled as `bridge_failed` and the key stays retryable.
**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:1099-1113,1160`. If the payer spends GNUS while the confirm is open, the burn reverts on chain and costs gas. Re-read the balance in `_recheckAfterConfirm`.

### IN-07: Tests import another test file for a helper
**Status:** won't fix. Optional; not trivial enough for this pass.
**File:** `test/gnus_consent/gnus_prompts_test.dart`, `test/gnus_consent/gnus_connect_prompt_test.dart`, `test/settings/connected_sites_test.dart` (`import '../theme/theme_contrast_test.dart' show themeFor`). Move `themeFor` into a shared test helper.

### IN-08: Plan and sketch IDs survive in the drawer block this phase rewrote
**Status:** fixed (36b91717).
**File:** `lib/reown/approve_transaction_drawer.dart:30,42` (`033-B1`, `T-21-12`). AGENTS.md forbids plan IDs in source. Keep the reasons and drop the IDs while the block is open.

---

_Reviewed: 2026-10-28_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: deep_
