# Phase 45: Hardened bridge transports - Context

**Gathered:** 2026-10-28, autonomous. Scope lines D-01, D-11 and the requirement list come from Braian; decisions marked (D) are Claude's and Braian can overturn any of them.
**Status:** Ready for planning

<domain>
## Phase Boundary

The in-wallet transport for `window.gnus` on the five web views: shim injection, the caller's origin from the
platform's message source, the origin allowlist, the navigation lock, popups to the system browser, and events
via `eventsFor(origin)`. Everything opens from the dev route `/dev/gnus-bridge` with a static test page. No
dashboard entry (phase 46), no WalletConnect (phase 47), no device walks beyond Linux (phase 48).

</domain>

<decisions>
## Implementation Decisions

### Scope and order
- **D-01:** "Done" is Linux working end to end. Linux (vendored `webview_all` on WebKitGTK) is built and walked in this phase. Windows, Android, iOS and macOS must build and must not expose the bridge insecurely. Plans 01-03 are Linux; 04-06 follow and nothing in 01-03 depends on them.
- **D-02 (D):** Fail closed. A view installs the bridge only through its hardened path. No fallback to webview_flutter's JavaScript channel (reachable from every frame on Android) and no top-level-URL origin on a platform that reports a source. A platform whose hardened path is missing, or whose WebView lacks a needed feature, gets no `window.gnus`.
- **D-03 (D):** The bridge views open only from `/dev/gnus-bridge`, built only when `kDebugMode && kShowDevTools`. Release builds have no way to reach the bridge in this phase.

### Shared session (one per web view, in `lib/gnus_bridge/`)
- **D-04 (D):** One transport-independent session owns the shim source, the allowlist check, the per-view secret, the document generation, and the reply and event scripts. Platform views stay thin: inject the shim, forward `(message, source)` and main-frame page starts, run the script the session hands back. The origin is the typed `GnusOrigin.tryParse(GnusTransport.webview, source)` from the phase 44 review fix (CR-02, coordinator); no normalisation of our own.
- **D-05:** The origin comes from the platform's message source, never the payload: WebView2 `args->get_Source()`; Android `WebMessageListener` `sourceOrigin`; WKWebView `WKScriptMessage.frameInfo.securityOrigin`. Linux reports none, so it uses the top-level URL from the last main-frame page-start or URL-change event. Those events reach Dart in the same FIFO event channel as the message, so the view reads its tracked URL synchronously on receipt and never awaits.
- **D-06 (D):** Linux frame isolation uses a per-view secret: 128 bits from `Random.secure()`, baked into the top-frame-only shim and prefixed to every message. The session drops a message without it before decoding. WebKitGTK exposes a message handler to every frame and names no frame. The shim captures its post function and `JSON.stringify` at document start, so a later page script cannot read the secret. On Linux an iframe's post reaches the plugin callback and stops at that first check: no handler call, no reply. On the other four the native side drops non-main-frame messages, so they never reach Dart. Rejected: an isolated script world. It means a native patch on the platform that must land, a cross-world relay, and code Dart tests can't reach. The secret check also runs on every platform as a second guard.
- **D-07 (D):** Three guards drop stale replies: (a) a document generation that every main-frame page start bumps. A reply or event whose generation changed is dropped and logged without its payload. (b) The delivery script runs only if `location.origin` equals the request's canonical origin. The check runs inside whichever document executes the script, which closes the commit race. (c) Shim request ids carry a per-document random prefix, so a reply that lands in a new same-origin document matches nothing.
- **D-08 (D):** Events: on each page start the session subscribes to `handler.eventsFor(origin)` for an allowlisted top origin and cancels the previous subscription. Delivery uses the guards in D-07. The `disconnect` event is not sent, because the page goes away with the view.

### Shim and user agent
- **D-09:** `window.gnus` is a frozen `{isGeniusWallet: true, version: '1', request, on, removeListener}`, non-writable and non-configurable. It is top frame only (`window.top === window`), installs once, then dispatches `gnus#initialized`. It is injected at document start wherever the native side allows, which is all five: Linux user script, WebView2 `AddScriptToExecuteOnDocumentCreated`, Android `addDocumentStartJavaScript`, `WKUserScript` `.atDocumentStart` main frame only. The contract's wait for `gnus#initialized` still holds. Contract section 2 says Android/iOS/macOS inject after page start; that line is stale and needs a fix from the contract owner (this phase writes only its own folder).
- **D-10 (D):** The user-agent marker is ` GeniusWallet/<FLUTTER_BUILD_NAME> gnus/<kGnusRpcVersion>`, appended to each bridge view's default UA.

### Allowlist and navigation
- **D-11:** In release, the allowlist is one pinned https origin per `SgnsNet`, a single exhaustive switch in `lib/gnus_bridge/gnus_dashboard_origins.dart`. Until the Cloudflare Pages URL exists the value is `https://gnus-dashboard-staging.invalid` with a `ponytail:` comment. The `.invalid` TLD never resolves, so nobody can claim it; a guessed `*.pages.dev` name, which anyone can register, would be a hole in release.
- **D-12 (D):** Dev builds (`kDebugMode && kShowDevTools`) also allow one origin from `--dart-define=GNUS_DASHBOARD_DEV_ORIGIN`, default `http://localhost:3000`. A value that is not http on host `localhost` is ignored. An off-list origin gets `4100` from the session, so the handler is never called and no prompt appears. The allowlist belongs to the web-view transport; phase 47 sets its own rule for WalletConnect.
- **D-13 (D):** An allowlisted top-level navigation loads. An off-list one is blocked in the view, and if it is http(s) it opens in the system browser (`launchUrl`, `LaunchMode.externalApplication`). Popups never open in the view; http(s) ones go to the system browser. Per platform:
  - Windows: a native prefix check of the Chromium-canonical URI cancels NavigationStarting; NewWindowRequested is marked handled and emits its URL.
  - Android, iOS, macOS: webview_flutter turns popups into main-frame navigations, so the main-frame rule covers them.
  - Linux: navigation decisions come with no frame, so off-list ones are blocked in any frame and cross-origin iframes do not load. `about:blank` and `about:srcdoc` pass. Only new-window actions, flagged by a vendored-plugin patch, open externally.
  - ponytail: a redirect loop opens one browser tab per attempt.

### Per-platform mechanism
- **D-14 (D):** Windows: vendor `webview_windows` 0.4.0 into `third_party/webview_windows`. Copy it unchanged first, then patch (AGENTS.md: refactor first). The patches are additive: message source, a top-level allowlist, a new-window URL event, a user-agent getter. Banxa and the in-app browser behave as before.
- **D-15 (D):** Android: app-side Kotlin uses `WebViewFlutterAndroidExternalApi.getWebView`, plus androidx.webkit `addWebMessageListener` (allowed-origin rules = the allowlist; drop when `!isMainFrame`) and `addDocumentStartJavaScript`. If either `WebViewFeature` is missing there is no bridge (D-02). The app declares `androidx.webkit:webkit:1.15.0`, the version webview_flutter_android already pulls in.
- **D-16 (D):** iOS and macOS: app-side Swift in the existing `ios/Runner/AppDelegate.swift` and `macos/Runner/MainFlutterWindow.swift`, so there are no Xcode project edits. It uses `WebViewFlutterWKWebViewExternalAPI` to add a main-frame-only `WKUserScript` and a `WKScriptMessageHandler` that drops `!frameInfo.isMainFrame` and passes `securityOrigin` as the source. Android and Darwin share one method-channel contract and one Dart view. The two Swift copies are accepted (Rule of Three).

### Verification
- **D-17:** Every platform gets a verification row: test, build or live walk, or blocked with its reason. A check that did not run is never claimed.
  - Linux: tests, a build, and an agent walk on the Linux rig.
  - Windows: tests and a local build. A CDP-read walk on this PC is optional and uses no synthetic input.
  - Android: Dart tests, plus a build if one is possible locally, otherwise PR CI. The walk is phase 48 on `GW_Test`, which needs a debug APK carrying the dev route and cleartext localhost.
  - iOS: a build on the Tart VM. The walk is blocked: the simulator can't load the device-only SDK libraries.
  - macOS: a build, with an optional walk, on the Tart VM.
- **D-18 (D):** The test page is static HTML in `tool/gnus_bridge_test_page/`. The top page is on the dev origin. It holds a cross-origin frame from `http://127.0.0.1:<port+1>` and a sandboxed `srcdoc` frame; the srcdoc frame has an opaque origin and is the one cross-origin frame Linux loads. The page runs its checks itself and prints pass or fail.

### Requirements
- DWV-02, DWV-03 (roadmap). This phase also brings forward, per Braian's scope: the shim timing and UA marker from DWV-01, and the allowlist, navigation lock and popups from DWV-04. Phase 46 keeps the dashboard entry and DWV-05..07. The REQUIREMENTS traceability update is for the orchestrator.

### Claude's Discretion
- Class and file names, the shape of the additive vendored APIs, how the dev screen picks a platform view, the test page layout, log wording (canonical origin only, never payloads).

</decisions>

<canonical_refs>
## Canonical References

- `.planning/research/v4.0-gnus-rpc-contract.md`: sections 1, 2, 4 and 6
- `.planning/research/v4.0-webview-bridge-spike.md`: security concerns 1-4, platform table
- `.planning/phases/44-dashboard-consent-and-limits/44-REVIEW.md`: CR-01 (one prompt wallet-wide), CR-02 (`GnusOrigin`)
- `lib/gnus_bridge/gnus_origin.dart`, `lib/gnus_bridge/gnus_rpc_handler.dart` (`handle(GnusOrigin, …)`, `eventsFor(GnusOrigin)`)
- Spike code, read-only: `C:\Users\User\Documents\Projects\GNUS\GW-webview-spike\lib\gnus_bridge\` (shim, Linux view)
- `third_party/webview_all/webview_all_linux/linux/src/webview/{linux_webview.cc,webview_javascript.cc,webview_method_handler.cc}`
- `lib/web/web_utils.dart` (`linuxInAppWeb`), `lib/web/web_overlay_gate.dart`, `lib/banxa/checkout/checkout_rules.dart` (navigation-rule style)
- `AGENTS.md`: wallet safety, layering, comments

</canonical_refs>

<code_context>
## Existing Code Insights

- The vendored Linux plugin injects channel wrappers into all frames (`webview_javascript.cc` `add_user_script`) but honours `forMainFrameOnly` for `addUserScript` (TOP_FRAME). An unanswered navigation decision resolves to ignore (fail closed).
- `NavigationRequest.isMainFrame` is hard-coded `true` on Linux and must not be trusted (comment in `linux_webview.cc`).
- `webview_windows` 0.4.0 drops `get_Source`, has no navigation cancel, and only marks popups handled under Deny.
- webview_flutter_android routes `window.open` through `onCreateWindow` into a main-frame navigation; webview_flutter_wkwebview does the same in `onCreateWebView`.
- `GnusHarness` (`test/gnus_bridge/gnus_fakes.dart`) builds a real handler for session tests.

</code_context>

<deferred>
## Deferred Ideas

- Isolated script world on Linux (literal "never reaches Dart" there).
- Opening external links only on a user gesture; a per-second cap on external opens.
- CSP (a dashboard-side header), a bundled static export on a custom scheme, the `disconnect` event.
- Android, iOS and macOS walks, plus a CI debug APK with the dev route (phase 48).

</deferred>
