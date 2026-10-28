# Phase 46: In-wallet dashboard screen - Context

**Gathered:** 2026-10-28, autonomous. D-01, D-06 and the decision list come from Braian; decisions marked (D) are Claude's and Braian can overturn any of them.
**Status:** Ready for planning

<domain>
## Phase Boundary

The production screen that hosts the phase 45 bridge views: one wallet entry point, a full-screen route pinned to the
dashboard origin, loading, failed and no-bridge states, wallet dialogs above the page, back and close, screen-reader
labels, the Android file picker and back, and the system-browser fallback. Shim, UA marker, allowlist, navigation
lock and popups are phase 45 and are reused, not rebuilt. No WalletConnect (47), no device walks beyond Linux (48).

</domain>

<decisions>
## Implementation Decisions

### Scope and order
- **D-01:** "Done" is the Linux wallet opening the dashboard in-app, walked on the Linux rig. Windows, Android, iOS and macOS reuse the same screen and route; they must build (or be recorded as blocked with the reason) and keep phase 45's fail-closed rule. Plans 01-03 are Linux; 04-05 follow and nothing in 01-03 depends on them.
- **D-02 (D):** Plans 01-03 need phase 45 plans 01-03 committed; plans 04-05 need 45-04..06 committed. No phase 46 executor runs while a phase 45 executor is active in the same worktree (one git index; both edit `gnus_dashboard_origins.dart`, the views and the dev test screen).

### Entry point
- **D-03 (D):** One entry: a ghost `GWButton` (size sm, 44 px) labelled **"Jobs and earnings"**, the trailing of the compute panel's "Earning" section title on the wallet home, in both layouts and on every platform. `GWSectionTitle` reserves a 44 px header, so the panel's height budget does not move. Not "Dashboard": the wallet's home tab already has that name. No "node", "SDK" or "processing dashboard" in the label (earn wording). No desktop tab (a ninth tab was refused before) and no More-sheet row. `GWViewAllLink` is not used: it has no button role and no 44 px target.
- **D-04 (D):** `ComputePanel` takes an optional `onOpenDashboard`; null hides the button. The panel reads no bloc, so `wallet_overview.dart` decides.
- **D-05 (D):** Release builds list the entry only when the pinned origin is real. While the staging origin is the `.invalid` placeholder, a release build shows no button, because a button that can only fail is worse than none. Dev builds always list it.

### Origin
- **D-06:** The pinned origin per network is phase 45's exhaustive switch in `lib/gnus_bridge/gnus_dashboard_origins.dart` (staging: `https://gnus-dashboard-staging.invalid` until Braian's Cloudflare domain exists). No second list. The start URL is the origin root `/`. When the domain lands, that one line changes and D-05 lists the entry.
- **D-07 (D):** Dev builds (`kDebugMode && kShowDevTools`) start on the dev origin from `GNUS_DASHBOARD_DEV_ORIGIN` (default `http://localhost:3000`, phase 45 D-12). The dev bubble's GNUS BRIDGE section gets a **Hosted** switch: on, the entry opens the pinned origin, so one debug build checks release pinning, walks the failed state on the placeholder, and later walks the real host. No custom-URL field: the allowlist is compile-time, so a free URL would be blocked by it or would need a runtime allowlist. Another port is a rebuild with the define. The `/dev/gnus-bridge` test screen keeps its URL field for test pages.
- **D-08 (D):** `/gnus-dashboard` reads no URL, query or `extra`; the start comes only from the network and the build mode, so a deep link cannot choose the page. While the entry is unlisted (D-05) the route redirects to `/dashboard`.

### Screen
- **D-09 (D):** A full-screen route on the root navigator, outside the ShellRoute (like `/bridge`). The page gets the whole window; the dashboard has its own navigation. Flutter header above the view: Close, the title "Jobs and earnings" with the start host under it, and Reload.
- **D-10 (D):** One pure function picks the bridge view kind from the OS and WebKitGTK presence (Linux view, Windows view, the shared webview_flutter view, or browser). The screen and `/dev/gnus-bridge` both use it. The in-app-or-browser rule stays `inAppWeb` in `lib/web/web_utils.dart`. The screen takes a host builder so tests swap the view, as `CheckoutScreen` does.
- **D-11 (D):** States sit in Flutter chrome or replace the view, never on top of it, because the Linux view paints above Flutter:
  - Loading: an indeterminate bar under the header until the first main-frame page finishes, announced as "Loading jobs and earnings".
  - Failed: any main-frame load error (offline, DNS, TLS) puts the view offstage and shows "Jobs and earnings didn't load" / "Check your connection, then try again." with **Try again** (a fresh view and session) and **Close**. No separate offline state and no connectivity listener: once loaded, the page talks only to the wallet.
  - No bridge (a view whose hardened path fails to install, phase 45 D-02): no page; "Open jobs and earnings in your browser" / "This device's web view can't connect to the wallet safely." with **Open in browser** and **Close**.
  - Linux without WebKitGTK: the entry opens the start URL in the system browser and pushes no screen (DWV-07). A failed launch toasts "Couldn't open your browser.", which is visible because no web view is on screen.
  - The notice is checkout's `_CheckoutNotice`, made public: this is its third copy (Rule of Three).
- **D-12 (D):** Wallet dialogs: the connect prompt, the spend confirm and WalletConnect drawers are PopupRoutes on the root navigator. For the Linux host the screen wraps the view in `WebOverlayGate`, so the page steps aside while any popup is open. Windows renders WebView2 as a texture and webview_flutter platform views composite inside Flutter, so dialogs already draw above them; there the evidence is a build here and the walk in phase 48.
- **D-13 (D):** Back and close:
  - Close always leaves at once (`Navigator.pop`, which does not consult `PopScope`); with nothing to pop it goes to `/dashboard`.
  - System back (Android Back, iOS edge swipe) steps back through the page's history first and leaves only when there is none (DWV-06). `PopScope.canPop` follows the view's `canGoBack` after each URL change, so iOS swipe-back still works when there is no history.
  - No in-header page Back on desktop: the dashboard has its own navigation.
- **D-14 (D):** Screen-reader labels: the entry "Open jobs and earnings" (contains the visible text); the title is a header; Close "Close jobs and earnings"; Reload "Reload jobs and earnings"; the view region "Jobs and earnings page, <host>"; the loading and failed notices are live regions. The entry and the screen chrome pass `textContrastGuideline` and `labeledTapTargetGuideline` in light and dark.

### Android
- **D-15 (D):** The job-file picker: `setOnShowFileSelector` on the shared mobile view, Android only, served only while the top URL is on the allowlist; extensions from the input's `accept` (`.json`), any file when it names none. No temp-file cleanup: a job definition is not sensitive, unlike Banxa's ID photos.
- **D-16 (D):** A debug-only network security config permits cleartext to `localhost` only, so a dev APK loads the dev origin through `adb reverse tcp:3000 tcp:3000`. Release stays https-only.

### Verification
- **D-17:** As phase 45 D-17, each platform and criterion gets test, build, walk, or blocked with a reason. Linux: tests, a rig build and an agent walk against the dashboard's static export (`yarn build`, `out/`) served on `http://localhost:3000`, the nearest thing to the hosted page until the https origin exists. Windows: tests and a local build. macOS and iOS: a Tart VM build or blocked. Android: tests, and a build if one is possible locally, else pending CI. Walks for the other four are phase 48.
- **D-18 (D):** Phase 45 D-03 kept every bridge view out of release. This phase opens exactly one door: release reaches a bridge view only through `/gnus-dashboard`, on the pinned origin. `/dev/gnus-bridge` stays dev-only.

### Requirements
- DWV-01 (entry on all five; shim timing and UA came from 45), DWV-04 (start and pinning; navigation lock from 45, checked on the real dashboard), DWV-05, DWV-06, DWV-07.

### Claude's Discretion
- File and class names, header layout, the names of the additive view callbacks, test layout, copy wording within the earn rule.

</decisions>

<canonical_refs>
## Canonical References

- `.planning/ROADMAP.md` Phase 46; `.planning/REQUIREMENTS.md` DWV-01, DWV-04..07
- `.planning/phases/45-hardened-bridge-transports/45-CONTEXT.md` (D-01..03, D-11..13, D-17) and plans 01-06
- `.planning/phases/44-dashboard-consent-and-limits/44-CONTEXT.md`; `44-REVIEW.md` CR-01 (one prompt wallet-wide), CR-02 (`GnusOrigin`), WR-02 (Approve arms 500 ms after the drawer opens)
- `.planning/research/v4.0-gnus-rpc-contract.md` sections 2 and 6; `v4.0-webview-bridge-spike.md` (Linux paints above Flutter)
- `lib/banxa/checkout/checkout_screen.dart` (host builder, notice, external fallback); `lib/web/web_utils.dart`, `lib/web/web_overlay_gate.dart`
- `lib/dashboard/compute/compute_panel.dart`, `lib/components/wallet_overview.dart`, `lib/components/cards/gw_section_title.dart`
- `lib/components/overlay/global_swap_fab_host.dart` (`PopupRouteObserver`), `lib/components/bottom_drawer/responsive_drawer.dart`
- gnus-dashboard `C:\Users\User\Documents\Projects\GNUS\gnus-dashboard-gsd`, branch `gsd/dashboard-v1`: CONN-01 (waits for `gnus#initialized` when the UA marker is present), DEF-02 (paste path), DEP-02 (the origin)

</canonical_refs>

<code_context>
## Existing Code Insights

- `SgnsNet` has one value (staging). `GnusRpcHandler.readSgnsNet()` caches it, so the screen needs no `GeniusApi`.
- The connect prompt and spend confirm open on `navigatorKey` with `useRootNavigator: true`; `ResponsiveDrawer` opens a dialog or a bottom sheet, both PopupRoutes, which `GlobalSwapFabHost.popupRoutes` (a root observer) counts.
- The repo's tests have no fake `WebViewPlatform`; checkout tests swap the host builder instead.
- The vendored Linux plugin does not handle `run-file-chooser`, so WebKitGTK's default GTK dialog applies (unwalked).
- `android/app/src/debug/AndroidManifest.xml` exists with no `<application>`; no cleartext config anywhere.
- Panel height and contrast are asserted in `test/dashboard/compute_panel_height_test.dart` and `test/theme/compute_contrast_test.dart`.

</code_context>

<deferred>
## Deferred Ideas

- Retiring the compute panel's native "New processing job" drawer in favour of the dashboard.
- A desktop tab or a More-sheet row for the dashboard; an in-header page Back on desktop.
- File input on macOS (WKWebView needs an open-panel delegate) and iOS: the phase 48 walk records it; the page's paste path covers it.
- Reloading the screen on a network switch (one `SgnsNet` today); a separate offline state with auto-retry.
- Showing a failed popup open in the header; CSP and the host choice (gnus-dashboard phase 7).

</deferred>
