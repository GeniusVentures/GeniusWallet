# WebView bridge spike: findings (2026-10-26)

## Verdict

The WebView bridge is viable on desktop. A page served from a local Next dev server, loaded inside GeniusWallet, called `window.gnus.request({method, params})` and got answers from the wallet's real, initialized GeniusSDK. Ran end to end on:

- **Windows** (this PC): WebView2 via `webview_windows`, page at `http://localhost:3001`. Port 3000 here is taken by another project's dev server, so the allowlist was set to 3001 by build flag.
- **Linux** (the `slave` box, Xvfb): WebKitGTK via the vendored `webview_all`, page at `http://localhost:3000` served by `next dev` from a gnus-dashboard clone. The bridge used the long-running processing wallet's SDK account (`0x745ce532…`).

Android, iOS and macOS were not run (see the platform table). Nothing blocks the bridge itself. The SDK issues found (below) block the dashboard features whichever UI option is chosen.

## What was built

On the spike branch, uncommitted:

- Windows worktree: `C:\Users\User\Documents\Projects\GNUS\GW-webview-spike`, branch `spike/webview-bridge`, based on develop `7b0d7a1a`.
- Slave copy: `~/gnus/GW-bridge-spike` (detached at the same commit, patch applied).

Files:

- `lib/gnus_bridge/gnus_bridge.dart`: transport-independent handler, origin allowlist, error codes, and the injected JS shim.
- `lib/gnus_bridge/gnus_bridge_screen.dart`: spike screen (route `/dev/gnus-bridge`) with Windows and webview_flutter views, the confirm dialog, and a call log with timings.
- `lib/gnus_bridge/gnus_bridge_linux_view.dart`: Linux view.
- Small hooks: the route in `router.dart`, a "Bridge spike" button in the dev tools bubble, and a `GNUS_BRIDGE_AUTO_OPEN` flag in `splash.dart` that opens the screen after startup.

Test page: `gnus-dashboard/public/bridge-test.html`, plus `public/posenet-job.json` (current SuperGenius job schema). Both untracked.

Protocol: the page posts `{id, method, params}`. Dart replies by running `window.__gnusBridgeReply({id, result | error:{code, message}})`. Errors reject the promise with `code` and `message`.

| Method | Result |
|---|---|
| `gnus_getAddress` | `GeniusApi.getSelectedAccountAddress()`, or 4900 when the SDK is not ready |
| `gnus_estimate` | `requestGeniusSDKCost(jobJson)`, returning `{cost}`. A 0 from the SDK becomes -32603 |
| `gnus_submitJob` | Native confirm dialog. Reject gives 4001. Approve returns `{stubbed:true, jobId}`. Real `GeniusSDKProcess` only with `--dart-define=GNUS_BRIDGE_REAL_PROCESS=true` (not exercised, to avoid starting real jobs) |
| Anything else | 4200 |
| Bad params | -32602 |
| Origin not in allowlist | 4100 on every method |

Build flags: `GNUS_BRIDGE_ORIGINS` (comma list, default `http://localhost:3000`), `GNUS_BRIDGE_AUTO_OPEN`, `GNUS_BRIDGE_REAL_PROCESS`.

## Results

| Check | Windows | Linux (slave) |
|---|---|---|
| Shim injected before page scripts | yes (`addScriptToExecuteOnDocumentCreated`) | yes (`addUserScript`, document start) |
| `gnus_getAddress` | real SDK address | real SDK address |
| `gnus_estimate` | SDK called, returned 0 (see SDK blockers) | same |
| Unknown method / bad params | 4200 / -32602 | 4200 / -32602 |
| `gnus_submitJob` approve / reject | not driven (no synthetic input on this PC) | stub result / 4001 |
| Blocked origin (`127.0.0.1` vs `localhost`, same server) | 4100 on all calls | 4100 on all calls |
| Real dashboard home in the WebView | renders with live testnet data, `window.gnus` present | not checked |

Screenshots are in `webview-bridge-spike-shots/` next to this note.

## Platform support

| OS | Wallet builds for it | WebView package (already a wallet dependency) | Bridge status |
|---|---|---|---|
| Windows | yes | `webview_windows` 0.4.0 (WebView2) | Verified |
| Linux | yes | vendored `webview_all` (WebKitGTK loaded at runtime). Falls back to the system browser when WebKitGTK is missing, and then there is no bridge | Verified on slave |
| Android | yes | `webview_flutter_android` | Code path written (shared with iOS/macOS), not run. No local Android build: the recipe is CI APK only |
| iOS | yes | `webview_flutter_wkwebview` | Not run, needs a Mac |
| macOS | yes | `webview_flutter_wkwebview` | Not run |

webview_flutter (Android/iOS/macOS) has no document-start script API. The shim is injected on page start and finish, and pages must wait for the `gnus#initialized` event. The test page does this.

## Latency and UX

- **Bridge overhead is negligible.** `gnus_getAddress` round trip from JS, 20 in a row:
  - Windows: median 0.8–1.5 ms, max about 20 ms.
  - Linux on Xvfb with software rendering: median 6–27 ms.
  - The Dart handler itself takes 10–60 µs.
- **`gnus_estimate` takes 100–800 ms and freezes the wallet UI meanwhile.** The cost call is synchronous FFI on the UI isolate, and the SDK does a live coin-price HTTP request inside it. The wallet's own job panel has the same freeze. Production needs the call off the UI isolate (or an async SDK call).
- **Linux: native web view paints above Flutter.** The confirm dialog was hidden under the page while the barrier dimmed the rest (`linux-dialog-hidden-before-fix.png`). Wrapping the view in the wallet's existing `WebOverlayGate` fixed it. Windows renders the web view as a texture, so dialogs already overlay it. Android/iOS platform views were not checked.
- **The SDK "address" is a 128-hex public key, not a 20-byte EVM address.** The dashboard must not treat it as an EVM address.

## Security concerns

1. **Origin comes from the host's view of the top-level URL, not from the message.**
   - `webview_windows` drops WebView2's `args->get_Source()`.
   - webview_flutter's and webview_all's `JavaScriptMessage` carry no frame or origin.
   - So a page that navigates away mid-request could race the check. The spike re-checks the origin before replying and drops the reply if it changed.
   - Production fix: patch `webview_windows` to pass the message source (a few lines; the wallet already vendors patched plugins). On Android, use `WebViewCompat.addWebMessageListener` with allowed-origin rules (androidx.webkit), which webview_flutter_android does not expose today. On iOS, use `WKScriptMessage.frameInfo.securityOrigin` / `isMainFrame`.
2. **Frames.**
   - The shim installs only in the top frame.
   - WebView2 iframe messages go to a different event, so they never reach the bridge.
   - Android `addJavascriptInterface`, which webview_flutter uses, exposes the channel to every frame including cross-origin iframes. This is the biggest gap on mobile.
3. **Every script on an allowed origin gets wallet access.** That includes third-party npm code and any XSS in the dashboard. Rules for production:
   - Every spend and every submit needs a native confirm showing the origin and cost.
   - No method may return secrets.
   - Rate-limit prompts.
   - Pin the dashboard to one https origin, or bundle the static export and serve it from a custom scheme. Set a strict CSP. Restrict top-level navigation to the allowlist. Deny popups (the spike sets this on Windows).
4. **Plain-http localhost is dev only.** The allowlist matches scheme, host and port exactly (`localhost` and `127.0.0.1` are different origins, which made the blocked-case demo trivial). Android blocks cleartext http by default, and an emulator's `localhost` is the emulator itself.

## Blockers that need SDK changes

1. **Cost always 0: hardcoded CA bundle path.** On the slave, the node logged `Failed to load CA file (/__w/SuperGenius/SuperGenius/SuperGenius/src/coinprices/certs/cacert.pem)`, then `GNUS price request failed`. So `GetProcessCost` returns 0, because cost = block size x live GNUS price. The CA path is the CI runner's build path baked into the binary. This also breaks the wallet's own job pricing. Windows (older `TestNet-Phase-3.1` SDK) also returned 0; its log was not checked for the same line.
2. **`GeniusSDKGetCost` returns a bare 0 for every failure** (no node, unparseable job, price failure). It needs error codes so the dashboard can tell "bad job" from "price service down".
3. **`GeniusSDKProcess` returns only a status code, no job or task id.** The dashboard cannot show "my job's status/results" without one. It needs a job id from Process, plus a per-job status and result query. `GeniusSDKGetProcessingStatus` is node-wide, and `GeniusSDKGetTaskResult` takes a task id that Process never returns.
4. **Job schema drift.** `gnus-dashboard/testProcess.json` is the old `data/model/input` shape. The SDK now parses the processing-definition schema (`inputs/outputs/passes`, for example SuperGenius `test/src/processing_schema/posenet-processing-job.json`). The dashboard's job builder must follow the SDK's schema.
5. **Not checked:** whether the SDK exposes "what my node processed and earned" (per-node job history and earnings) for the earnings view.

## Effort to productionise (rough)

- Bridge core, protocol and typed client for the dashboard (a small `request()` wrapper with the WalletConnect fallback): 2–3 days.
- Per-platform transport hardening, including origin from the message source (webview_windows patch, Android `addWebMessageListener` plugin work, iOS frameInfo): 4–6 days.
- Confirm/consent UX, permissions per origin, rate limiting, navigation lock, CSP, hosting decision (pinned https vs bundled export): 3–5 days.
- Moving SDK calls off the UI isolate: 1–2 days.
- Device walks on Android, iOS and macOS (none run here): 2–3 days.

Total is about 2.5–4 weeks for one developer. SDK changes 1–3 are separate and needed by either UI option.

## Not done

- Android, iOS and macOS runs.
- A real `GeniusSDKProcess` call (stubbed on purpose).
- The browser-plus-WalletConnect `gnus_*` path. The test page detects the missing `window.gnus` and says so, but no WalletConnect handler exists yet.
- Windows submit dialog clicks: synthetic input on the user's own PC is off limits. Linux covered the dialog.

## How to rerun

- **Windows.** From the spike worktree:
  ```
  CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=TestNet-Phase-3.1 -DBRANCH_IS_TAG=ON" flutter build windows --debug --dart-define=GNUS_BRIDGE_AUTO_OPEN=true --dart-define=GNUS_BRIDGE_ORIGINS=http://localhost:3001
  ```
  Start the dashboard with `npx next dev -p 3001`, then launch the exe with `WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS=--remote-debugging-port=9222` to read the page over CDP. Only Release native deps exist locally, hence `CMAKE_BUILD_TYPE=Release` with a debug Dart build. Delete `build/windows` if CMake cached Debug paths.
- **Slave.** Scripts are in `/tmp/gnusbridge/`:
  - `in-bridge.sh` is the container build, run as root in `ghcr.io/geniusventures/almalinux-8` with `~/gnus` mounted.
  - `run-bridge.sh` starts `next dev` on :3000, pauses `gwproc` and launches the spike with the processing wallet's HOME.
  - `drive.sh X Y name` clicks and takes a screenshot.
  - Restore `gwproc` with `/tmp/restart.sh` (done; it is running again).
