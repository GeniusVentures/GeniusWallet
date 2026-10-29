---
phase: 45-47 (hardened bridge transports, in-wallet dashboard screen, dashboard over WalletConnect)
reviewed: 2026-10-28T17:42:13Z
depth: deep
commit_range: 523ecf0c..f001734e
files_reviewed: 25
files_reviewed_list:
  - lib/gnus_bridge/gnus_web_bridge.dart
  - lib/gnus_bridge/gnus_dashboard_origins.dart
  - lib/gnus_bridge/gnus_bridge_view_linux.dart
  - lib/gnus_bridge/gnus_bridge_view_windows.dart
  - lib/gnus_bridge/gnus_bridge_view_mobile.dart
  - lib/gnus_bridge/gnus_native_bridge_channel.dart
  - lib/gnus_bridge/gnus_dashboard_screen.dart
  - lib/gnus_bridge/gnus_origin.dart
  - lib/gnus_bridge/gnus_rpc_handler.dart
  - lib/gnus_consent/gnus_prompts.dart
  - lib/reown/gnus_wallet_connect.dart
  - lib/reown/wallet_connect_host.dart
  - lib/reown/handle_dapp_requests.dart
  - lib/reown/utilities.dart
  - lib/reown/approve_transaction_drawer.dart
  - lib/reown/reown_connect_button.dart
  - lib/navigation/router.dart
  - lib/components/wallet_overview.dart
  - lib/dev/gnus_bridge_test_screen.dart
  - lib/dev/dev_tools_bubble.dart
  - android/app/src/main/kotlin/ai/gnus/genius_wallet/GnusWebBridge.kt
  - ios/Runner/AppDelegate.swift
  - macos/Runner/MainFlutterWindow.swift
  - third_party/webview_windows/windows/webview.cc
  - third_party/webview_all/webview_all_linux/linux/src/webview/linux_webview.cc
findings:
  critical: 0
  warning: 10
  info: 8
  total: 18
status: issues_found
fix_status: 12 fixed (WR-05 partly, WKWebView open), 6 open (IN-01, IN-02, IN-03, IN-04, IN-06, IN-08)
fixed_at: 2026-10-28
---

# Phases 45-47: Code Review Report

**Reviewed:** 2026-10-28T17:42:13Z
**Depth:** deep (security focus), read from commits `523ecf0c..f001734e`, not the working tree
**Files Reviewed:** 25 (plus reown_sign 1.4.1 / reown_core 1.5.1 sources for Verify and request expiry)
**Status:** issues_found

## Summary

No critical finding. The core rules hold:
- The release allowlist cannot hold localhost, because `dev` is the const `kDebugMode && kShowDevTools`.
- The `.invalid` placeholder hides the entry and redirects the route.
- On Windows, Android, iOS and macOS the caller's origin comes from the platform sender.
- On Android, iOS and macOS iframes are dropped natively. On Linux they are dropped by the secret.
- Replies are guarded three ways: the generation, `location.origin` and the `docId` prefix.
- On WalletConnect, Verify fails closed. reown_sign rejects any method a session was not approved for.
- `eventsFor` sends nothing to an origin that is not connected.
- The null and error encodings are wallet-authored and use `jsonEncode`.
- Approve is armed late enough to stop a baited click.

The warnings are the gaps around those rules:
- **WalletConnect:** a plain-http verified origin is accepted in release, and a first-call submit can outlive the wallet-side request expiry.
- **Linux:** the caller's origin is the provisional URL.
- **Shim:** the secret can be read by any top-frame script and lasts for the whole view.
- **Generation bump:** a navigation that never commits drops replies.
- **Windows:** an empty allowlist turns the lock off.
- **Android:** a POST navigation skips the lock.
- **Wallet switch:** pushes the new address to every dApp.
- **tx.from:** checked before the drawer opens, not when signing.

AGENTS.md: no phase, plan or sketch IDs were added, and no `_buildX()` helpers. Every new statement `if` is braced; the ones the scan flagged are collection-ifs. One doc comment over the 3-line limit was moved without being shortened (IN-07).

## Warnings

### WR-01: WalletConnect accepts a plain-http gnus origin in release builds

**Status:** Fixed in `5ca545d2`. One function builds the WalletConnect origin for proposals and restored sessions: https only, plus http on `localhost`/`127.0.0.1` in a dev build. Contract section 2 updated.

**File:** `lib/reown/gnus_wallet_connect.dart:56-75`, `lib/gnus_bridge/gnus_origin.dart:45`
**Issue:** `gnusProposalOrigin` refuses http only for loopback in release. Any `http://` origin that Verify reports as VALID is approved. Verify only compares the attested origin with `metadata.url`, and both can be `http://dash.example`. The 44 review's fix sketch said "https only (http only for localhost in dev)". The WebView path gets that from its allowlist; the WalletConnect path has nothing equivalent.
**Scenario:** A user connects `http://jobs.example`, a domain verified in its owner's Reown project. Someone on the same café Wi-Fi rewrites the http page and drives its WalletConnect session. Reads (accounts, node account, jobs) return with no prompt. Every spend shows a confirm that names a site the user already trusts.
**Fix:**
```dart
if (origin == null ||
    (_isLoopback(origin) && !devBuild) ||
    (!_isLoopback(origin) && !origin.value.startsWith('https://'))) {
  return (origin: null, refusal: GnusRefusal.unverified);
}
```
Apply the same check in `gnusSessionOrigin` so a restored http session gets `4100`.

### WR-02: A first-call `gnus_submitJob` can outlive the raised request expiry, so the reply to a burn is lost

**Status:** Fixed in `b842d454`. The request stays answerable for the page's 900 s, the connect prompt and the confirm share that deadline, and a submit with under 3 minutes left before or after its confirm is `4001` `request_expired` with nothing spent. Contract sections 2, 3 and 5 updated.

**File:** `lib/reown/gnus_wallet_connect.dart:243-250`; `lib/gnus_bridge/gnus_rpc_handler.dart:1010,1172`
**Issue:** The expiry is raised once, to `kGnusConfirmTimeout + 60 s` (11 min). `_submitJob` first awaits `_requireConnected`, which shows a connect prompt that can stay open for 10 minutes. It then estimates and shows the spend confirm, which can stay open for another 10 minutes. reown_sign deletes the pending request at 11 minutes, so `respondSessionRequest` throws in `_isValidPendingRequest` and the error is caught and logged.
**Scenario:** The dashboard's first call is a submit. The user leaves the connect prompt open for 9 minutes, then takes 3 minutes on the confirm and approves. The GNUS burns, but the reply is dropped. The contract tells the page to allow 900 s for this call, so the page is still waiting and gets nothing.
**Fix:** Raise the expiry again just before each prompt, or once to `2 * kGnusConfirmTimeout + 60 s` for `gnus_submitJob`. Re-setting the same id is enough:
```dart
final prompts = event.method == GnusRpcMethod.submitJob ? 2 : 1;
ReownCoreUtils.calculateExpiry(prompts * kGnusConfirmTimeout.inSeconds + 60)
```
Also fix the contract's "11 minutes" line.

### WR-03: On Linux the caller's origin is the provisional URL, so the old document speaks as the next one

**Status:** Fixed in `573d850d`. The Linux plugin emits `pageCommitted`; the caller is the committed URL, and a message between start and commit is dropped. Windows, Android, iOS and macOS take the origin from the platform sender, so they do not share the flaw. The C++ change was not built here (Windows host); the Linux rig build and walk are pending.

**File:** `lib/gnus_bridge/gnus_bridge_view_linux.dart:69-70,84-88`; `third_party/webview_all/webview_all_linux/linux/src/webview/linux_webview.cc:333-355`
**Issue:** `pageStarted` and `_topUrl` are set at `WEBKIT_LOAD_STARTED`, and `notify::uri` also fires on redirect. At that point the navigation is still provisional and the old document is alive and can still post. Every message it posts after that event is attributed to the destination URL. FIFO ordering does not help, because the event really did come first. The secret does not help either, because the old top document holds it too.
**Scenario:** In a dev build both `http://localhost:3000` and the pinned origin are allowlisted. A page on one origin starts `location = <other origin>` and keeps calling `gnus.request` until the new document commits. Those calls run as the other origin, and a spend confirm shows that origin. Release has one origin per network today, so this is latent. It becomes real when a second origin is added, or if any off-list top document ever loads (see WR-07 for the Android equivalent).
**Fix:** Track the committed origin, not the provisional one. Have the plugin emit `WEBKIT_LOAD_COMMITTED` with the URI and set `_topUrl` there. Drop messages that arrive between STARTED and COMMITTED. Keep the generation bump at STARTED so replies to the old document are still dropped.

### WR-04: Any top-frame script can read the "secret", and it lasts for the whole view

**Status:** Fixed in `b84be619`. The shim binds the native `postMessage` at document start and has no call-time fallback. The secret stays per view; the comment now says so. Checked by running the shim in Node with an overridden prototype (not committed).

**File:** `lib/gnus_bridge/gnus_web_bridge.dart:34-37,236-261,317`
**Issue:** The comment says the shim "captures the post function … so a later script cannot read the secret". In fact it captures `host` (`window.webkit.messageHandlers.gnusBridge`, `window.chrome.webview` or `window.gnusBridge`) and looks up `host.postMessage` on every call. The fallback at line 317 even reads `window.gnusBridge` at call time. A page can overwrite `Object.getPrototypeOf(host).postMessage` and read `secret + ':' + payload`. The secret is also made once per `GnusWebBridge`, so it stays valid for every later document in that view, not just one load.
**Scenario:** A compromised third-party script on the dashboard reads the secret once. A sandboxed `srcdoc` frame, in this document or a later one, can then post with it. On Linux that frame is attributed to the top URL. The script already had `window.gnus`, so what this adds is persistence, and the in-code guarantee is false.
**Fix:**
```js
var call = Function.prototype.call;
var postFn = host && host.postMessage;
post = postFn ? function (m) { call.call(postFn, host, m); } : null;
```
Remove the `window.gnusBridge` fallback; with no host the request should fail. If the secret is meant to be per load, as the review brief assumes, rotate it on each main-frame start (re-add the user script). Otherwise fix the comment so it says per view.

### WR-05: Every provisional page start drops replies, even when the document never leaves

**Status:** Partly fixed in `573d850d`. The generation now bumps on commit: Linux (`LOAD_COMMITTED`), Windows (ContentLoading) and Android (`onPageStarted` fires at commit). Open: WKWebView still reports at provisional start, marked `ponytail:` in the mobile view; it needs a didCommit signal from the Swift installers.

**File:** `lib/gnus_bridge/gnus_web_bridge.dart:69-83,170-172,181-184`; callers `gnus_bridge_view_linux.dart:84-87`, `gnus_bridge_view_mobile.dart:114-117`
**Issue:** On Linux the generation bumps at `LOAD_STARTED`, and on WKWebView at `didStartProvisionalNavigation`, before anything commits. Some navigations start and never commit: a `Content-Disposition: attachment` download, a `204 No Content`, a redirect the lock blocks, or a navigation the page cancels. After any of those, every in-flight reply to the document that is still showing is dropped as stale, and there is no retry.
**Scenario:** The user approves a spend confirm. While the burn is being sent, the dashboard starts a result download. The burn completes, `_send` sees a new generation, and drops the reply. The page waits forever, because the contract tells it to use no timeout on prompting calls.
**Fix:** Bump the generation on commit (Linux `LOAD_COMMITTED`, WKWebView `didCommit`/`onUrlChange`, Windows already uses ContentLoading). Or bump at both start and commit, and only drop on a committed change. Windows needs no change.

### WR-06: On Windows an empty allowlist turns the navigation lock off

**Status:** Fixed in `695d1ccf`. An empty allowlist stops the Windows view before it loads and reports no bridge.

**File:** `lib/gnus_bridge/gnus_bridge_view_windows.dart:78-88`; `third_party/webview_windows/windows/webview.cc:358-360`
**Issue:** If `allowedOrigins()` throws, `_allowed` stays `{}` and the comment says "every top-level load is refused". But `setTopLevelAllowlist([])` calls the native "empty turns the limit off" branch, so every top-level navigation is allowed. The Dart bridge still refuses off-list callers, so this is a phishing hole, not a bridge hole. Through `/gnus-dashboard` it is hard to reach, because the screen's own `readSgnsNet` result is cached first. `/dev/gnus-bridge` reaches it directly.
**Scenario:** The SDK net read fails. The view loads, nothing locks it, and a redirect takes it to a lookalike page inside wallet chrome.
**Fix:** Fail closed in Dart. If `_allowed` is empty, call `widget.onNoBridge` (or throw) and do not call `loadUrl`. Better still, use a separate `enabled` flag in the native lock so that `[]` means "allow nothing".

### WR-07: On Android, POST navigations skip the navigation lock

**Status:** Fixed in `ead9a7eb`. The mobile view checks each page start and URL change; an off-list web page is hidden and reported as a failed load. Not walked on Android (phase 48).

**File:** `lib/gnus_bridge/gnus_bridge_view_mobile.dart:111-113,189-201`
**Issue:** webview_flutter's `onNavigationRequest` is driven by `shouldOverrideUrlLoading`, which Android does not call for POST requests. A top-level form POST to an off-list origin loads in the dashboard screen. The origin rules mean it gets no `window.gnus`, but it renders under the "Jobs and earnings" header with the pinned host shown below the title.
**Scenario:** The dashboard has `<form method="post" target="_top" action="https://evil.example/login">`, or a framed widget submits one after a user tap. The wallet then shows a seed-phrase phishing page inside its own chrome.
**Fix:** In `GnusWebBridge.kt`, also block off-list main-frame loads natively. Override `WebViewClientCompat.shouldInterceptRequest` for main-frame requests to non-allowlisted origins, or hook `onPageStarted`/`doUpdateVisitedHistory` and `stopLoading()` + `goBack()`. Alternatively, have the screen hide the view (failed state) whenever `onUrlChange` reports an off-list origin.

### WR-08: A wallet switch pushes the new address to every connected dApp

**Status:** Fixed in `d1472330`. Only gnus sessions follow a wallet switch. An ordinary dApp keeps its namespace and gets `accountsChanged` with its own account when that wallet is selected again, otherwise `[]`. This supersedes 47-CONTEXT D-11 for ordinary dApps.

**File:** `lib/reown/wallet_connect_host.dart:164-200`
**Issue:** `_syncAccounts` runs `updateSession` on every active session, including ordinary dApps approved under a different wallet. It rewrites their accounts to the newly selected wallet and emits `accountsChanged`. The user is never asked. After the update, `canTransactFrom` passes for the new wallet, because the session now lists it.
**Scenario:** A user connects a DEX while their main wallet is selected, then switches to a separate child or privacy wallet. The DEX now sees that wallet's address, can link the two identities, and can ask for transactions from it.
**Fix:** Update only sessions whose current account is the previous wallet, and only if the user agrees (a "Share this wallet with N connected sites?" prompt). Otherwise emit `accountsChanged` with `[]` and leave the namespace alone. At minimum, limit the update to gnus sessions, which already need a per-origin connect.

### WR-09: `tx.from` is checked before the drawer, but the signer is read again after approval

**Status:** Fixed in `677cf309`. After approval the wallet, the session accounts and the chain are checked again; a change is `4100` and nothing is signed.

**File:** `lib/reown/handle_dapp_requests.dart:122-136` versus `:240,264-269`
**Issue:** `canTransactFrom` checks the selected wallet before the drawer opens. After the user approves, `walletAddress` and `network` are read again from the cubit, and `from`, `walletCanSign` and the session accounts are not checked again. The drawer awaits a human, so the state can change in between.
**Scenario:** The wallet selection changes while the approve drawer is open, for example through an account-switch path that does not sit behind the barrier, or a wallet deletion. The transaction the dApp built for A is then signed by B.
**Fix:**
```dart
final selectedNow = walletDetailsCubit.state.selectedWallet;
if (!canTransactFrom(tx['from'], selectedNow, sessionAccounts ?? const []) ||
    walletDetailsCubit.state.selectedNetwork?.chainId != selectedChain) {
  await respond(error: const JsonRpcError(code: 4100, message: 'Unauthorized'));
  return;
}
```
Put this right after `shouldApprove == true`, and sign with `selectedNow.address`.

### WR-10: A message that arrives after `dispose()` still reaches the handler and can open a prompt

**Status:** Fixed in `75fa9c60`.

**File:** `lib/gnus_bridge/gnus_web_bridge.dart:111-139`
**Issue:** `dispose()` sets `_disposed` and bumps `_generation`, but `onMessage` never checks `_disposed`. A message already queued on the Linux or Windows event channel, or a `pagehide` handler firing as the view is torn down, captures the post-dispose generation. That passes every stale check, and `handle()` opens a connect prompt or spend confirm for a page the user just closed.
**Scenario:** The user taps Close. The page's `pagehide` sends `gnus_submitJob`, and a spend confirm appears over the wallet home with no page behind it.
**Fix:**
```dart
Future<void> onMessage(String raw, {required String? source}) async {
  if (_disposed) {
    return;
  }
```

## Info

### IN-01: iOS and macOS inject the shim and handler on every origin, and install with no origins

**Status:** Open. Native Swift in two files, not buildable on this host; phase 48 (Tart VM).

**File:** `ios/Runner/AppDelegate.swift:61-76`, `macos/Runner/MainFlutterWindow.swift:78-93`
**Issue:** Android limits both the document-start script and the listener to the allowlist, and refuses an empty list. The Swift installers ignore `origins` and return true for any view, so every main-frame document gets `window.gnus` and the secret. Dart's origin check is the only gate. This is safe today, but weaker than Android.
**Fix:** Read `args["origins"]`, return false when it is empty, and in the handler drop messages whose `securityOrigin` is not in that set before invoking the channel.

### IN-02: The Linux view is wrapped in `WebOverlayGate` twice

**Status:** Open by choice. The screen-level gate is the only tested proof that the Linux page steps aside for a dialog; the view-level one cannot be pumped without the platform.

**File:** `lib/gnus_bridge/gnus_dashboard_screen.dart:307-311` and `lib/gnus_bridge/gnus_bridge_view_linux.dart:151`
**Issue:** The view already gates itself, so the screen's wrapper adds a second listener and Offstage that do nothing. **Fix:** Drop the screen-level wrapper and the `hostKind` plumbing it needs.

### IN-03: Toasts are hidden behind the Linux web view

**Status:** Open. Needs the overlay gate to follow the toast manager; not trivial.

**File:** `lib/reown/wallet_connect_host.dart:120-125`, `lib/gnus_bridge/gnus_dashboard_screen.dart:113`
**Issue:** The gate reacts to popup routes only. Toasts are overlay entries, so while the Linux dashboard is open they draw under the native page. This includes "This site could not be verified" and "The selected wallet cannot sign". **Fix:** Have the gate also listen to the toast manager, or show these refusals as a drawer while a web view is mounted.

### IN-04: The Android file picker is offered to any frame

**Status:** Open. Accepted as is: the user still picks the file.

**File:** `lib/gnus_bridge/gnus_bridge_view_mobile.dart:163-166`
**Issue:** `gnusPickerAllowed` checks only the top URL, so a cross-origin iframe's `<input type=file>` gets the picker too. The user still picks the file. **Fix:** Accept it as is, or use `FileSelectorParams` to drop requests from frames that are not the main frame where the platform exposes that.

### IN-05: The gnus session drawer shows the peer's chosen name and icon next to the verified origin

**Status:** Fixed in `6b64d3f5`. A gnus proposal shows the verified host as the name and no icon.

**File:** `lib/reown/wallet_connect_host.dart:305-311`
**Issue:** `dappName` and `iconUrl` come from unverified metadata, so a verified `evil.example` can call itself "GeniusWallet Dashboard" and use the GNUS logo. The connect prompt already leaves the icon out for this reason. **Fix:** For gnus proposals, pass `iconUrl: null` and use `origin.value` as the name.

### IN-06: In dev builds, an unattested loopback peer shares the localhost connection

**Status:** Open. Dev only; requiring Verify for loopback would block local dashboard work (47-CONTEXT D-03).

**File:** `lib/reown/gnus_wallet_connect.dart:71`
**Issue:** UNKNOWN plus loopback is accepted, so any native WalletConnect client on the developer's network can claim `http://localhost:3000` and inherit that connection with no prompt. This is dev only. **Fix:** Require Verify to say VALID even for loopback, or key dev loopback connections per session topic.

### IN-07: A 7-line doc comment was moved without being shortened

**Status:** Fixed in `43a961c9`.

**File:** `lib/dev/dev_tools_bubble.dart:1476-1482`
**Issue:** This range moved the misplaced `_devButton` comment, which breaks the 3-line limit and records history ("what the light-mode walk feedback asked for"). **Fix:** Cut it to one line, or drop it.

### IN-08: Linux loads `window.open` targets in place and then relies on a URI match

**Status:** Open. A vendored-plugin change on the new-window path; for the Linux rig session.

**File:** `third_party/webview_all/webview_all_linux/linux/src/webview/linux_webview.cc:248-258,281-288`
**Issue:** `create_web_view_cb` calls `webkit_web_view_load_uri` on the main view for any scheme. It counts on the decide-policy URI match to treat that load as a new window. If the match is missed (the ponytail case), an allowlisted popup replaces the dashboard, and a stale key later sends a normal navigation to the browser. **Fix:** Do not load in place. Emit a `newWindow` event with the URI from `create_web_view_cb` and return `nullptr`, so the decision never depends on matching the URI.

---

_Reviewed: 2026-10-28T17:42:13Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: deep_
