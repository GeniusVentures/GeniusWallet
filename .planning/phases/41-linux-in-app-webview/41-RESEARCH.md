# Phase 41: Linux in-app webview - Research

**Researched:** 2026-10-11
**Domain:** Flutter Linux desktop, native WebKitGTK embedding (vendored `webview_all_linux`), go_router link routing, Banxa checkout host
**Confidence:** HIGH on stack, CI and routing (read in the worktree); MEDIUM on the focus and hide mechanisms (designed from plugin source, not yet run)

Source base: spikes 003-007 (`.planning/spikes/`), `.claude/skills/spike-findings-geniuswallet/`, and the spike's uncommitted changes in this worktree (branch `spike/linux-webview`, HEAD `e21a290e`). Spike code is spike-grade; this phase rewrites it. Nothing in this file was re-researched from scratch; every in-repo claim below was re-read in the worktree this session.

## User Constraints

No `41-CONTEXT.md` exists yet (phase dir holds only `.gitkeep`). The locked inputs are the ROADMAP goal and the `linux-inapp-webview` requirements in `.planning/spikes/MANIFEST.md`. Treat them as locked until discuss-phase says otherwise.

### Locked (from ROADMAP Phase 41 and MANIFEST)
- On Linux, news articles, the Web browser page, legal pages, explorer links and Banxa checkout open inside the wallet window.
- One bundle for every distro. No build-time WebKit link; load `libwebkit2gtk-4.1`, else `4.0`, at runtime. No WebKit: the app still runs and links open in the system browser.
- Call `isAvailable()` before creating a web view; fall back to `url_launcher` and say so.
- Route every external link through `launchWebSite`; Banxa's checkout fallback and support link stay deliberate `launchUrl` exceptions.
- Nothing draws over a web view; no rounded clip or transform above one: hide the view while an overlay or route is above it.
- Plugin hands keyboard focus back to Flutter.
- CI image needs `webkit2gtk3-devel` (headers only).

### Claude's Discretion
Fork location, Banxa dialog vs full-screen on Linux, whether the standalone page route applies on all platforms, hide-hook mechanism, probe timing. Defaults proposed under Open Questions.

### Deferred
None recorded. Candidates I recommend deferring: upstreaming the dlopen patch to `abandoft/webview_all`; cookies/auth/TLS-error walks beyond the smoke checks below.

<phase_requirements>
## Phase Requirements

ROADMAP lists `Requirements: TBD`. Proposed IDs (add to REQUIREMENTS.md under a new `Linux web (LWV)` heading before planning; the planner may rename):

| ID | Description | Research Support |
|----|-------------|------------------|
| LWV-01 | One Linux bundle, WebKit loaded at runtime (4.1 then 4.0), no WebKit link dependency | Standard Stack; 007; CI check |
| LWV-02 | No WebKit: app launches, Web tab hidden, every link goes to the system browser with a stated reason | Routing seam; fallback copy |
| LWV-03 | All external links go through `launchWebSite`; two `launchUrl` exceptions remain | Call-site table |
| LWV-04 | Articles, legal and explorer pages open as a back-able route outside the shell | Pattern 2 |
| LWV-05 | Web tab works on Linux when WebKit is present | nav/route gating |
| LWV-06 | Banxa checkout embeds on Linux with the mobile allow-list, return-URL and camera/mic policy | Pattern 4 |
| LWV-07 | Web view is hidden while any popup, drawer, menu or toast is above it; no rounded clip above it | Pattern 3 |
| LWV-08 | Keyboard focus returns to Flutter after the page had it | Plugin work |
| LWV-09 | CI builds the bundle with `webkit2gtk3-devel` and fails if WebKit becomes a link dependency; INSTALL.md says WebKitGTK is recommended | CI; Packaging |
</phase_requirements>

## Summary

The approach is proven end to end by spikes: a vendored, patched `webview_all_linux` 1.4.4 embeds a native `WebKitWebView` in a `GtkOverlay` inside `FlView`, loads WebKit via `dlopen`/`dlsym` (4.1 first, 4.0 second, API picked by symbol presence), and one EL8-built bundle launched and rendered on Ubuntu 20.04, 22.04, 24.04 and AlmaLinux 8, and launched with `isAvailable=false` on a no-WebKit system [CITED: .planning/spikes/007-webkit-runtime-loading/README.md, Results matrix]. The wallet integration rendered News, the Web page and Banxa checkout in-app and fell back cleanly without WebKit [CITED: spikes/005 README, Results].

What is left is not discovery but hardening: four plugin/wallet defects found in the 005 walk (focus stays in WebKit, overlays are cut by the native view, a rounded clip hides it, no way back from articles/legal), plus turning spike hacks into product code (remove the `GW_SPIKE_CHECKOUT_URL` hook, dedupe the browser copy, one source for the permission rule), CI headers, and packaging text. The biggest unmeasured risk is that the real wallet process (with `libGeniusWallet.so` and the SDK's native deps) was only walked against WebKit 4.0/2.38 on Ubuntu 20.04; the 4.1/libsoup3 path was only run in the small spike app. See Pitfall 1.

**Primary recommendation:** Keep the vendored plugin in `third_party/webview_all/` (import pristine `b9eac11` as its own commit, patch as the next), add a pure routing decision in `web_utils.dart`, push all articles/legal/explorer links onto one new top-level `/page` route, hide the native view by unmounting the `WebViewWidget` while `GlobalSwapFabHost.popupRoutes.anyOpen`, and add a native focus hand-back to the plugin. Prove the two unproven mechanisms (focus, unmount-hide) in a Wave 0 task before building on them.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Is WebKit usable (dlopen, symbols) | Native plugin (`webkit_runtime.cc`) | Dart probe in `web_utils.dart` | Only native code can load libs; Dart caches one bool |
| Open-in-app vs system browser decision | Dart (`web_utils.dart`, pure function) | - | Domain rule, one owner; callers only delegate |
| Page route (back, no shell) | go_router (`router.dart`) | `WebViewScreen` | Nav highlight/back stack are router concerns |
| Hide view under overlays | Dart wrapper widget over `PopupRouteObserver` | Plugin `setFrame(visible:false)` | Observer already owns "is a popup open" |
| Keyboard focus hand-back | Native plugin (`flutter_view.cc`) | Dart `releaseFocus` call as fallback | GTK focus is native state Dart cannot see |
| Banxa nav allow-list, return match, permission policy | `checkout_rules.dart` | `CheckoutWebViewLinux` | Already the owner for mobile/Windows |
| WebKit headers for build | CI image / `build.yml` | - | Runtime libs come from the user's distro |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `webview_all_linux` (vendored) | 1.4.4 @ `b9eac11`, MIT, + 007 patch (8 files, +657/-13) | Native WebKitGTK view, runtime-loaded | Only Flutter Linux webview with a working embed; spikes validated it [CITED: spikes/003, 007] |
| `webview_all` (vendored, plugin map stripped) | 1.4.4 | App-facing controller API mirroring `webview_flutter` | Lets Linux files be mobile files with one import changed |
| `webview_platform_interface` (vendored) | 1.4.4 | Interface for the two above | Required by `webview_all_linux` |
| WebKitGTK (system, runtime) | 4.1 (`libwebkit2gtk-4.1.so.0`) else 4.0 (`libwebkit2gtk-4.0.so.37`) | Rendering | Never bundled; absent is a supported state |
| `webkit2gtk3-devel` (CI image only) | 2.54.0-1.el8_10 | Headers (4.0 API, libsoup2 struct fields) | Only CI change needed [CITED: spikes/006 README, Research] |
| `go_router` `^17.2.2`, `url_launcher ^6.1.6` | existing | Routing, system-browser fallback | Already in `pubspec.yaml` |

Provenance of the vendored source: upstream `abandoft/webview_all` is MIT, pushed 2026-10-01, `b9eac11` is its 1.4.4 release commit [VERIFIED: `gh api repos/abandoft/webview_all` this session: license MIT, 161 stars, 6 open issues]. The pub.dev package `webview_all_linux` 1.4.4 has verified publisher `abandoft.com`, 14,581 downloads/30 days, 91 likes, MIT [VERIFIED: pub.dev API this session]. Upstream CMake links `webkit2gtk-4.1` at build time (`pkg_check_modules(WEBKIT REQUIRED IMPORTED_TARGET webkit2gtk-4.1)`), so our patch is a permanent divergence, not a thin shim [VERIFIED: `gh api .../contents/webview_all_linux/linux/CMakeLists.txt?ref=b9eac11`].

### Vendored copy vs GitHub fork (pick one)
| | Vendor in-repo (`third_party/`) | Fork `GeniusVentures/webview_all`, git dep pinned by SHA |
|---|---|---|
| Plugin edits this phase (focus, maybe hide param) | One PR, one review | Two repos, push fork, bump SHA, then wallet PR |
| Pinning | The commit is the pin; `UPSTREAM_COMMIT` file records base | `ref: <full sha>` in `pubspec.yaml` |
| CI/offline | No network step; `quality` job unchanged | Needs git fetch; fine on GitHub runners |
| Review noise | ~96 files, ~700 KB lands in wallet PR (Codex reviews it) | None |
| Needs authorization | None | Creating a repo in the org is outward-facing: needs Braian's go-ahead |
| Precedent | `packages/genius_api`, `packages/local_secure_storage` are in-repo path deps | `banxa/`, `squidrouter/` are separate repos but as submodules |

**Recommendation:** vendor now (default). Commit 1 = pristine `b9eac11` import (so `git diff HEAD~1` IS the patch and is reviewable); commit 2 = patch. Move to a fork only if a second app needs the plugin. Spike state already has `third_party/webview_all/{LICENSE,UPSTREAM_COMMIT(b9eac11)}` and no CRLF [VERIFIED: grep for CR, this session]. `tool/check_brace_style.sh` scans `lib/` and `test/` only, so vendored Dart is not subject to the brace rule [CITED: tool/check_brace_style.sh header]; CI runs `dart format`/`flutter analyze` on `lib test` only [CITED: .github/workflows/build.yml:1499-1503].

**Installation:**
```bash
# pubspec.yaml (already in the spike diff); no registry install
webview_all:               {path: third_party/webview_all/webview_all}
webview_all_linux:         {path: third_party/webview_all/webview_all_linux}
webview_platform_interface:{path: third_party/webview_all/webview_platform_interface}
```

## Package Legitimacy Audit

No package is installed from a registry in this phase, so the `package-legitimacy check` seam was not run. The three packages are vendored source from a GitHub repo whose provenance is verified above. The one distro package, `webkit2gtk3-devel`, comes from AlmaLinux AppStream inside the CI image.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| webview_all_linux (+ webview_all, webview_platform_interface) | pub.dev (reference only) / GitHub (vendored) | published, 1.4.4 on 2026-10-01 | 14.6k/30d | github.com/abandoft/webview_all | not run (vendored, no install) | Approved: reviewed source in-repo |
| webkit2gtk3-devel | AlmaLinux 8 AppStream | distro | distro | n/a | n/a | Approved: headers only |

**Removed (SLOP):** none. **Flagged (SUS):** none.

## Architecture Patterns

### System Architecture Diagram

```
launch -> main() -> await probeLinuxInAppWeb()
            |  Platform.isLinux? -> LinuxWebViewPlatform.isAvailable()
            |       native: dlopen 4.1 -> 4.0 -> else false (stderr line)
            v
        linuxInAppWeb (bool)  -----------------------------+
            |                                              |
  nav list / router: Web tab + /web only if                |
  !Platform.isLinux || linuxInAppWeb                       |
                                                           v
user taps link (9 call sites) -> launchWebSite(context,url) -> opensInApp(os, linuxInAppWeb)?
                                       |                                |
                                    yes|                                |no (Linux, no WebKit)
                                       v                                v
                        context.push('/page', WebViewExtras      launchUrl(uri) system browser
                          (url, includeBackButton: true))        + one-line "why" notice
                                       |
                    top-level route (outside ShellRoute) -> WebViewScreen
                                       |
          WebViewLinux  = browser chrome + WebViewWidget            Banxa: /checkout -> defaultCheckoutHost
          wrapped in OverlayGate:                                      -> checkoutHostKind('linux', linuxWebView)
          popupRoutes.anyOpen ? placeholder : WebViewWidget            -> CheckoutWebViewLinux (no rounded clip)
                                       |
                          native GtkOverlay in FlView; focus hand-back on click outside the hole
```

### Recommended structure
```
third_party/webview_all/{webview_all,webview_all_linux,webview_platform_interface}/  # vendored, LICENSE, UPSTREAM_COMMIT
lib/web/web_utils.dart        # probe, opensInApp(), launchWebSite()  (single owner of the decision)
lib/web/web_view_linux.dart   # browser chrome over webview_all (see dedupe note)
lib/web/web_overlay_gate.dart # hides the view under popups (new, small)
lib/banxa/checkout/checkout_webview_linux.dart
.github/workflows/build.yml   # dnf line + no-WebKit-link check
```

### Pattern 1: one routing decision, testable without a platform
Keep `launchWebSite(context, url)` as the only entry; add a pure function it calls, so tests pass an OS string instead of reading `Platform` (the CI `quality` job itself runs on Linux, which is how the existing recovery test noticed the Linux branch) [CITED: test/dashboard/transaction_recovery_states_test.dart:43-50].
```dart
// lib/web/web_utils.dart
bool opensInApp(String os, {required bool linuxWebKit}) =>
    os != 'linux' || linuxWebKit;
```
Current behaviour to replace [VERIFIED: lib/web/web_utils.dart:26-41, spike working tree]: `launchWebSite` does `if (Platform.isLinux && !linuxInAppWeb) { ... launchUrl(uri) ... return; }` else `context.push('/web', extra: WebViewExtras(url: url, includeBackButton: true))`. Default of `linuxInAppWeb` must stay `false` so existing tests keep taking the `launchUrl` path on Linux CI.

### Pattern 2: articles/legal/explorer as a standalone, back-able route
`/web` is inside `ShellRoute` [VERIFIED: lib/navigation/router.dart:228-240, `if (!Platform.isLinux || linuxInAppWeb) GoRoute(path: '/web', ...)` inside the shell routes list that starts at `ShellRoute(` line 157], which is why articles flip the nav highlight to Web and legal-in-onboarding shows the full app nav with no way back (005 findings 5, 6). Add a sibling top-level `GoRoute(path: '/page', ...)` building the same `WebViewScreen(includeBackButton: true)`; point `launchWebSite` at it. `/web` stays as the Web tab.
`includeBackButton` is honoured only by the Windows browser (`web_view_windows.dart:235,248`: a cancel icon calling `Navigator.of(context).pop()`); `web_view_mobile.dart` declares it (lines 13, 18) and never reads it [VERIFIED: grep of `includeBackButton` across `lib/`]. So the Linux browser and, if the route applies to all platforms, the mobile browser need a back control wired to the same flag. Colours from `GWColors` tokens, not `Colors.white` (the copied mobile chrome still uses raw colours; do not copy that into new code).
Also add `/page` (and `/web` if wanted) to `GlobalSwapFabHost._hiddenPaths` [VERIFIED: lib/components/overlay/global_swap_fab_host.dart:48-62 lists `'/checkout'` and `'/banxa/callback'`; `/web` is absent], otherwise the FAB paints under the native view and looks like a hole.

### Pattern 3: hide the view under overlays by unmounting its widget
`PopupRouteObserver` already tracks every open `PopupRoute` (dialogs, bottom sheets, menus, dropdowns) on the root navigator and notifies on change [VERIFIED: lib/components/overlay/global_swap_fab_host.dart:184-214: `bool get anyOpen => _open.isNotEmpty;` and `if (added is PopupRoute)`; registered at lib/navigation/router.dart:56-58 as `GlobalSwapFabHost.popupRoutes`]. `ResponsiveDrawer` uses `showDialog`/`showModalBottomSheet` (responsive_drawer.dart:125,162), so wallet drawers are popup routes. The checkout screen itself is a normal route, so it does not count and does not hide itself.
The plugin's widget only hides on app lifecycle, detach, unpainted, or unsupported transform/clip [VERIFIED: third_party/.../lib/src/linux_webview_widget.dart:71, 186-190, 382-412 `_hasNonRectangularClip`]; there is no app-level visible flag. Default mechanism, no plugin change:
```dart
class WebOverlayGate extends StatelessWidget {
  const WebOverlayGate({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: GlobalSwapFabHost.popupRoutes,
        builder: (_, _) =>
            GlobalSwapFabHost.popupRoutes.anyOpen ? const SizedBox.expand() : child,
      );
}
```
Unmounting calls the widget's `dispose()`, which sends `setFrame(hidden, visible:false)`; the controller (and native view) lives on until `platform.dispose()` [VERIFIED: linux_webview_widget.dart:~127-140, `dispose()` -> `_setFrameSafely(... visible:false)`]. That the page survives remount without reload/flicker is NOT yet shown: Wave 0 must prove it. Fallback if it reloads: add a `hidden` parameter to the vendored widget (touches all three vendored packages).
Toasts are `OverlayEntry`s, not routes [VERIFIED: lib/components/toast/toast_manager.dart:120-150], so they are not seen by the observer; see Open Question 5.

### Pattern 4: Banxa checkout host on Linux
Spike change, keep [VERIFIED: working-tree diff of lib/banxa/checkout/checkout_rules.dart]: `enum CheckoutHostKind { webview, windows, linux, external }` and `checkoutHostKind(String operatingSystem, {bool linuxWebView = false})` returning `'linux' when linuxWebView => CheckoutHostKind.linux`, else `'linux' => CheckoutHostKind.external`. `CheckoutWebViewLinux` reuses `isBanxaReturn`, `allowsCheckoutNavigation`, `isTrustedCheckoutUrl`. Required rewrites:
- `_CheckoutFrame` currently sets `clipBehavior: Platform.isLinux ? Clip.none : Clip.antiAlias` [VERIFIED: lib/banxa/checkout/checkout_screen.dart:376]. Make the clip decision a parameter derived from the host kind, not `Platform.isLinux` (it is wrong when Linux has no WebKit and shows the external notice; harmless but untestable). Inset the web area by the card radius so square web corners do not poke out of the rounded card.
- `_onPermissionRequest` in `checkout_webview_linux.dart` duplicates `checkoutPermissionAllowed` and is marked `ponytail:`. Make the rule take plain booleans or type names (`onTrustedPage`, `types`) and call it from mobile, Windows and Linux. Third consumer reached, so extraction is justified by the Rule of Three.
- Remove the `GW_SPIKE_CHECKOUT_URL` block in `lib/screens/banxa_buy_screen.dart` (spike diff adds it in `initState`).
- Do not touch the two `launchUrl` exceptions: `checkout_screen.dart:72` (`_openInBrowser`, used by `CheckoutExternal`) and `order_drawer_footer.dart:93` (support link).

### Anti-Patterns to Avoid
- **`ClipRRect`, rounded `Material` clip, `Transform` scale/rotate above a web view:** the plugin hides the view entirely (empty dialog in 005).
- **Opening articles as the shell `/web` tab:** wrong nav highlight, back loses the article.
- **Linking `webkit2gtk-4.0` or `PkgConfig::WEBKIT`:** bundle fails to launch on Ubuntu 24.04 (4.1 only) [CITED: spikes/006].
- **Falling back to 4.0 after a 4.1 symbol miss:** libsoup 2 and 3 abort in one process; a broken 4.1 gets `isAvailable=false` by design.
- **Registering `onSslAuthError` with a proceed action:** see Security.
- **Widgets calling the plugin/SDK directly for the probe:** keep it in `web_utils.dart`, not in a widget (AGENTS.md layering rule).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Embedding WebKit | Own FFI/GTK embed | Vendored `webview_all_linux` | Overlay, input-shape hole, geometry sync already working |
| Runtime WebKit loading | Another loader | The 007 `GwWebKitApi` table in `webkit_runtime.{h,cc}` | `-Wl,--no-undefined` makes bypasses a build error |
| "Is a popup open" | New overlay counter | `PopupRouteObserver` | One owner already exists |
| Checkout URL/return/permission rules | Linux-only copies | `checkout_rules.dart` | One source of truth for three platforms |
| Browser chrome for Linux | A third browser UI | `web_view_mobile.dart` body (37-line diff to the Linux copy) | See dedupe note |
| System-browser fallback | Custom launcher | `url_launcher` already depended on | - |

**Dedupe note.** `web_view_linux.dart` (771 lines) vs `web_view_mobile.dart` (757) differ in: import line, class names, a `_disposeController` helper, and one `_disposeController` call [VERIFIED: diff run this session, 37 diff lines]. Dart has no structural typing, so sharing the body needs a small controller interface, which is more code than the 37 lines it removes. Default: keep the Linux copy, mark it `ponytail:` (ceiling: two copies drift; upgrade path: extract the body once a third consumer appears or the two diverge), and add the back control to both. If the planner prefers true dedupe, it is a separate behaviour-preserving refactor task done before the back-button change.

## Runtime State Inventory

Not a rename/refactor phase: omitted.

## Common Pitfalls

### Pitfall 1: Real wallet process never run against WebKit 4.1 / libsoup3
**What goes wrong:** `dlopen` of `libwebkit2gtk-4.1` into the real process (which contains `libGeniusWallet.so` with libp2p, OpenSSL, boost etc.) could clash with symbols or crash; only the small spike app ran on 22.04/24.04. 005 walked the real wallet only on Ubuntu 20.04 (4.0, 2.38.6, soup2) [CITED: spikes/005 README, How to Run; spikes/007 matrix].
**How to avoid:** Wave 0 task: run the CI-built real bundle on Ubuntu 24.04 with `libwebkit2gtk-4.1-0`, expect the stderr line `webview_all_linux: loaded libwebkit2gtk-4.1.so.0 (...)`, load one page. CI already guards that `libGeniusWallet.so` exports no `SSL_`/`EVP_` symbols [VERIFIED: .github/workflows/build.yml:795-805]; extending that to other WebKit-shared library symbols is optional hardening [ASSUMED: sqlite3/zlib/png/xml interposition is plausible, unobserved].
**Warning signs:** process abort at startup right after the `loaded` line; blank view with web-process death (the plugin sends no web-process-terminated event).

### Pitfall 2: Focus stays in WebKit
After the page took GTK focus, Flutter text fields get clicks but not keys (005 steps 5; screenshots 03-05) [CITED]. Upstream already has native `release_linux_webview_focus()`: grabs focus back to `flutter_view` only if focus is on/inside the web view, and runs on hide and dispose [VERIFIED: third_party/.../linux/src/platform/flutter_view.cc:372-387; calls at linux_webview.cc:727, webview_method_handler.cc:470,1071]. It is not triggered by a click outside the hole.
**Fix (default):** native: connect `button-press-event` (connect-after) on the `flutter_view` widget to call `release_linux_webview_focus` for each live view; the input-shape hole means clicks outside the page reach `FlView`. **Fallback:** a `releaseFocus` method-channel case in `webview_method_handler.cc` calling the same function, triggered from Dart when a Flutter `FocusNode` gains focus. The native route also covers clicks on non-focusable widgets (Esc/shortcuts). Mechanism is [ASSUMED] until Wave 0 runs it.

### Pitfall 3: Promise-returning scripts
WebKit >= 2.40 `evaluate_javascript` throws `PlatformException(javascript_error, Unsupported result type)` on a Promise; end such scripts with `; undefined`. The existing browser scripts are non-promise IIFEs [VERIFIED: lib/web/web_view_linux.dart:~100-160, `(function(){ ... })();`], so nothing breaks today. Add a one-line comment/helper note where `_safeRunJavaScript` is defined and a grep gate in review for new `runJavaScript` calls.

### Pitfall 4: Controller created without `isAvailable()`
`WebViewController` calls `createWebView` in its constructor; a missed check surfaces as async `PlatformException(webview_unavailable)` [CITED: spikes/007 README]. Construct controllers only on paths guarded by `linuxInAppWeb`; `CheckoutWebViewLinux` is documented "only built after WebKitGTK loaded" - keep that true through `checkoutHostKind`.

### Pitfall 5: Build and local-environment traps
- A dev box with only Ubuntu 24.04 packages cannot build the plugin (needs `webkit2gtk-4.0` headers) [CITED: spikes/007 Remaining risks]. Document in the plugin's README/`AGENTS`-adjacent docs; builds go through the AlmaLinux 8 image.
- Local replicas: set `CC`, `CXX`, `ASM` to clang in the environment; `CMAKE_ARGUMENTS` is applied after `project()` in `linux/CMakeLists.txt`, so sentry-native's `.S` files otherwise hit gcc [CITED: spikes/005 README, How to Run]. `build.yml` sets none of `CC/CXX/ASM` and relies on `update-alternatives` plus `-DCMAKE_C_COMPILER` [VERIFIED: grep this session; build.yml:283-286, 691], so **no CI change is needed for this** (it is a local-repro note).
- `rsync --exclude banxa` unanchored also drops `lib/banxa`; anchor as `/banxa` [CITED: 005].
- `GDK_GL=gles` is needed on EL8 (GTK 3.22) containers or the Flutter surface is black once a view mounts; not on 24.04. `WEBKIT_DISABLE_COMPOSITING_MODE=1` fixes heavy sites on 2.38 under WSLg. Both unproven on real hardware; default: set neither in the app until a real-hardware walk shows need [CITED: 006, 007].

### Pitfall 6: Exit with a view alive
`main.dart` already works around a GL-teardown abort on Linux (`exitApplication` instead of `windowManager.destroy()`) [VERIFIED: lib/main.dart:~285-292]. Walk: quit the app with a page and with the checkout open; no abort/hang. Windows has a dedicated shutdown helper for its webview; Linux has none.

### Pitfall 7: Stale Banxa sandbox order
A replayed sandbox order URL ends blank in any WebKit (control-proved on 2.38 and 2.52). Do not judge the embed by one; use a fresh order from a keyed CI build [CITED: spikes/005 step 9].

## Code Examples

### Probe (keep in `web_utils.dart`, awaited in `main()` right after `ensureInitialized()`)
```dart
// Source: spikes/005 wallet-changes.diff; verified in lib/web/web_utils.dart:11-22
bool linuxInAppWeb = false;

Future<void> probeLinuxInAppWeb() async {
  if (!Platform.isLinux) {
    return;
  }
  try {
    linuxInAppWeb = await LinuxWebViewPlatform.isAvailable();
  } catch (_) {
    linuxInAppWeb = false;
  }
}
```
`main.dart` already contains `await probeLinuxInAppWeb();` after `WidgetsFlutterBinding.ensureInitialized();` in the spike diff.

### Nav and route gating (spike, keep)
```dart
// lib/components/overlay/nav_destinations.dart:68   [VERIFIED]
visible: !Platform.isLinux || linuxInAppWeb,
// lib/navigation/router.dart:228   [VERIFIED]
if (!Platform.isLinux || linuxInAppWeb)
```
Note `allDestinations` is a top-level `final` list built at first access; the probe must complete before anything reads it (it does, because `main()` awaits it before `runApp`).

### Call sites (re-counted by `git grep -n "launchWebSite("` on the worktree)
| File:line | What |
|---|---|
| `lib/onboarding/existing_wallet/view/legal_screen.dart:62`, `:73` | Privacy Policy, Terms (2) |
| `lib/dashboard/news/view/crypto_news_screen.dart:533, 683, 787, 843` | article cards (4) |
| `lib/dashboard/home/widgets/transaction_displays.dart:1143, 1179` | recovery / explorer links (2) |
| `lib/reown/swap_result_drawer.dart:92` | explorer link (1) |
| `lib/web/web_utils.dart:26` | the definition |

That is 9 calls plus the definition, matching the spike count [VERIFIED]. `launchUrl` direct uses elsewhere in `lib/`: `lib/banxa/banxa_components/order_drawer_footer.dart:93` (support link) and `lib/banxa/checkout/checkout_screen.dart:72` (checkout external fallback) - the two deliberate exceptions - plus the one inside `launchWebSite` [VERIFIED: `git grep "launchUrl\|canLaunchUrl\|url_launcher" -- lib`]. Every call site already passes `context`, so a `/page` push needs no signature change.

## Fallback messaging (LWV-02)
- No-WebKit checkout today shows `CheckoutExternal`: title `'Finish paying in your browser'`, message `'This screen updates when Banxa has your payment.'` [VERIFIED: lib/banxa/checkout/checkout_screen.dart:697-699]. Add one line saying why, e.g. "Install WebKitGTK to pay inside GeniusWallet" (copy per 005 finding 8; planner may reword in the wallet's voice).
- `launchWebSite` fallback on Linux currently opens the browser silently. Add a short toast once per session ("Opened in your browser. Install WebKitGTK to open links inside GeniusWallet.") via `showToast`; keep it Linux-and-unavailable only. Requires a `BuildContext` already present in the signature.
- Web tab stays hidden when unavailable (no copy needed).

## CI changes (LWV-09)
1. `.github/workflows/build.yml`, "Configure Linux host": the guarded safety net is `rpm -q ninja-build vulkan-loader-devel libsecret-devel libzstd-devel gtk3-devel jq` then `sudo dnf install -y ...` [VERIFIED: build.yml:296-298]. Add `webkit2gtk3-devel` to both lists. Cost measured: 62 packages, 61 MB, 226 MB installed, 75 s on the bare image [CITED: spikes/006]. Prefer adding it to the `ghcr.io/geniusventures/almalinux-8` image too, so the guard line stays a no-op. The apt (Debian Bullseye) branch at 301-325 is for non-Alma hosts; add `libwebkit2gtk-4.0-dev` only if that branch is still reachable for Linux (it is guarded by `matrix.target = Linux` inside the non-dnf path; both Linux matrix entries use the Alma container, lines 180-191, so it is dead for Linux today) [VERIFIED].
2. New step after the existing "Check libGeniusWallet.so keeps OpenSSL private (Linux)" (line 795), same inline style:
```bash
b=$(ls -d build/linux/*/release/bundle | head -1)
for f in "$b/genius_wallet" "$b"/lib/libwebview_all_linux_plugin.so; do
  if readelf -d "$f" | grep -Ei 'NEEDED.*(webkit|soup|javascriptcore)'; then
    echo "::error::$f links WebKit at build time"; exit 1; fi
done
n=$(nm -D --undefined-only "$b/lib/libwebview_all_linux_plugin.so" | grep -Ecw 'webkit_|soup_|jsc_' || true)
[ "$n" -eq 0 ] || { echo "::error::$n undefined WebKit symbols in plugin"; exit 1; }
```
Plugin library name derives from `set(PLUGIN_NAME "${PROJECT_NAME}_plugin")` with `PROJECT_NAME webview_all_linux` [VERIFIED: third_party/.../linux/CMakeLists.txt:3-6], giving `libwebview_all_linux_plugin.so` by CMake `lib<target>.so` convention [ASSUMED]; confirm the file name from a real bundle in Wave 0. Both Linux matrix rows (x86_64 and aarch64) run this.
3. aarch64: the `linux_arm` row uses the same Alma image (build.yml:186-191). No spike built or ran aarch64; `webkit2gtk3-devel` availability for aarch64 EL8 is [ASSUMED] (a Docker repoquery attempt timed out under emulation). Treat the first CI run on the ARM row as a gate; if the package is missing there, the ARM job needs `-DGW_...` style opt-out or a plugin build guard.

## Packaging (LWV-09)
Distribution is tarballs only (`Linux-x86_64-Release.tar.gz`, `Linux-aarch64-Release.tar.gz`); there is no deb/rpm/AppImage metadata in the repo [VERIFIED: INSTALL.md:22-45; `git grep` for packaging files found none]. So "WebKitGTK recommended, not required" is a documentation task: add to INSTALL.md's Linux section, e.g. "Optional: install WebKitGTK (`libwebkit2gtk-4.1-0` on Ubuntu/Debian, `webkit2gtk4.1` on Fedora, `webkit2gtk3` on RHEL/Alma 8) to open news, legal pages and checkout inside the app. Without it those open in your browser." Package names beyond Ubuntu's are [ASSUMED]; verify before publishing. Also update `.planning/REQUIREMENTS.md` BUY-07 wording ("Linux opens the system browser with a waiting screen") [VERIFIED: REQUIREMENTS.md:208] to "Linux embeds when WebKitGTK is present".

## State of the Art

| Old | Current | Impact |
|---|---|---|
| Link `webkit2gtk-4.0` at build time | `dlopen` 4.1 then 4.0 + dlsym table | One bundle for all distros; 24.04 ships 4.1 only |
| `run_javascript` | `evaluate_javascript` (>= 2.40) | Promise results throw; chosen at runtime by symbol |
| libsoup2 | libsoup3 with 4.1 | Both code paths in plugin; never both in one process |
| WebKitGTK 2.38 (Ubuntu 20.04) | 2.50-2.54 | 2.38 has no getUserMedia (built without MEDIA_STREAM) |

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Unmounting `WebViewWidget` hides the view and remount restores it without reload or visible flicker | Pattern 3 | Need plugin `hidden` param; touches 3 vendored packages |
| A2 | `button-press-event` on `FlView` fires for clicks outside the input-shape hole and calling `release_linux_webview_focus` fixes typing | Pitfall 2 | Use the Dart `releaseFocus` fallback; slightly weaker |
| A3 | Plugin lib is `libwebview_all_linux_plugin.so` in `bundle/lib` | CI | Check script path wrong; fix from a real bundle |
| A4 | `webkit2gtk3-devel` exists in aarch64 EL8 AppStream | CI | ARM row fails; needs guard |
| A5 | Distro package names for INSTALL.md beyond Ubuntu | Packaging | Wrong docs; verify per distro |
| A6 | Real wallet process loads WebKit 4.1 without symbol clashes | Pitfall 1 | Phase blocker on 22.04+/24.04; hardening or opt-out |
| A7 | Startup `dlopen` cost is small enough to await before `runApp` | Open Q 4 | Slower first frame; make probe lazy |
| A8 | TLS errors never proceed by default: with no Dart handler the native callback returns FALSE (WebKit error page) or the pending request times out | Security | Wallet pages could load with bad certs; read the timeout branch before finalising |

## Open Questions (planner must pick defaults)

1. **Fork location.** Default: vendor in `third_party/` (two commits: pristine, patch). Fork + SHA pin only if Braian wants it shared.
2. **Banxa on Linux: desktop dialog vs full screen.** Default: keep the dialog, `Clip.none`, web area inset by the card radius. Fallback if the inset looks wrong or menus over it are poor: Linux uses the phone layout (full screen, `modal: false`), which has no rounded card at all. Needs a visual decision at the walk.
3. **Standalone `/page` route on all platforms or Linux only?** The defect (no way back from legal in onboarding; nav highlight jump) exists on every platform; only Windows honours `includeBackButton`. Default: one code path, all platforms, with back control added to the mobile and Linux browsers; costs a smoke walk on Windows, macOS, Android and iOS. Alternative: gate by `Platform.isLinux` and leave others as-is (two paths).
4. **Probe timing.** Default: awaited at startup (nav list and routes read it synchronously). Measure the `dlopen` once during the walk; if it is noticeable, register `/web` and `/page` unconditionally and make only the nav `visible` flag listen to a `ValueNotifier`.
5. **Toasts over a page.** Requirement says nothing may draw over a view; toasts are `OverlayEntry`s the observer cannot see. Default: add a count/`ChangeNotifier` to `ToastManager` and include it in the gate (view hides for the toast's 2-5 s). Alternative: accept toasts rendering under the page on web surfaces (rare there). Needs Braian's call: hiding a page for seconds can look worse than a cut toast.
6. **Camera.** No camera device was ever available; the camera-typed prompt is unobserved (microphone proved the same path) [CITED: spikes/004, 006]. Default: ship; add a manual walk on a real camera. Ubuntu 20.04 (2.38.6) has no getUserMedia at all: Banxa KYC capture there must be expected to fail and should degrade to "Open in browser" (menu item already exists in the checkout header).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Docker Desktop | EL8 build image, runtime matrices | yes | 24.0.7 | none needed |
| WSL2 Ubuntu-20.04 (+ WSLg) | GUI walks, 4.0 path | yes | listed by `wsl -l` | - |
| Flutter 3.41.9 | tests, analyze | not on PATH (project note) | pinned 3.41.9 [CITED: spikes/CONVENTIONS.md] | invoke by full path |
| `gh` | repo checks | yes | - | - |
| Ubuntu 22.04/24.04 containers (4.1) | Pitfall 1, matrix | pull on demand | - | - |
| Real Linux hardware + webcam | camera prompt, GDK/compositing | not available to the agent | - | manual walk by Braian |
| Fresh Banxa sandbox order | email-screen walk | needs a keyed CI build | - | none; keep as manual gate |

Blocking with no fallback: real-hardware walk and keyed CI build for the Banxa email screen (both manual).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (Flutter 3.41.9 pinned); `mockito`, `fake_async` present |
| Config file | none (`analysis_options.yaml` at root) |
| Quick run | `flutter test test/web test/banxa/checkout_rules_test.dart test/components` |
| Full suite | `flutter test` (CI `quality` runs it with `--test-randomize-ordering-seed random`, build.yml:1550-1551) |
| Static | `dart format --output=none --set-exit-if-changed lib test`; `flutter analyze lib test`; `bash tool/check_brace_style.sh` |

The CI `quality` job runs on Linux, so every new test must pass with `Platform.isLinux == true` and with the plugin absent: inject the OS string, stub the page builder (the existing `/web` stub in the recovery test is the pattern), never construct a real `WebViewController`.

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| LWV-02 | `opensInApp('linux', linuxWebKit:false)` false; true when WebKit; true for other OSes | unit | `flutter test test/web/web_utils_test.dart` | Wave 0 |
| LWV-03 | `launchWebSite` pushes `/page` with url and `includeBackButton:true` when in-app, calls platform launcher when Linux without WebKit | widget (stub router + `_RecordingLauncher`) | `flutter test test/dashboard/transaction_recovery_states_test.dart test/web/web_utils_test.dart` | extend existing |
| LWV-03 | Only 2 direct `launchUrl` call sites remain besides `web_utils.dart` | grep gate in plan verification | `git grep -n "launchUrl(" -- lib` (expect checkout_screen.dart, order_drawer_footer.dart, web_utils.dart) | n/a |
| LWV-04 | `/page` is a top-level route, not under `ShellRoute`; back pops | unit on `geniusWalletRouter.configuration` + widget | `flutter test test/navigation/page_route_test.dart` | Wave 0 |
| LWV-05 | `/web` route and nav item present only when `!isLinux || linuxInAppWeb` | unit | `flutter test test/components` | Wave 0 |
| LWV-06 | `checkoutHostKind('linux', linuxWebView:true)` is `linux`; false is `external`; Windows unaffected | unit | `flutter test test/banxa/checkout_rules_test.dart` | partly exists (spike added 1 test) |
| LWV-06 | Single permission rule: camera/mic only on a Banxa page, everything else denied | unit | `flutter test test/banxa/checkout_rules_test.dart` | extend |
| LWV-07 | `WebOverlayGate` swaps the child for a placeholder while a dialog is open and restores it after | widget (router with `observers:[GlobalSwapFabHost.popupRoutes]`, as `global_swap_fab_host_test.dart` does) | `flutter test test/web/web_overlay_gate_test.dart` | Wave 0 |
| LWV-07 | `_hiddenPaths` contains `/page` | widget (FAB test pattern) | `flutter test test/components/global_swap_fab_host_test.dart` | extend |
| LWV-02 | `CheckoutExternal` shows the why-line | widget | `flutter test test/banxa` | extend |
| LWV-01, LWV-09 | Bundle has no WebKit/soup/JSC `NEEDED`; plugin has 0 undefined WebKit symbols | CI shell step | the `readelf`/`nm` step above (runs per Linux matrix row) | Wave 0 (build.yml) |
| LWV-09 | Linux bundle builds with `webkit2gtk3-devel` | CI build | existing Linux job | Wave 0 (dnf line) |
| LWV-01 | `ldd genius_wallet` shows no webkit/soup/javascriptcore and no "not found" on each distro | script in container | optional job; otherwise manual | optional |
| LWV-01 | Plugin with `--no-undefined` and symbol table stays in step | compile | CI build (toolchain catches drift both directions) | existing in patch |

Manual (cannot be automated by the agent):

| Req | Walk | Evidence |
|---|---|---|
| LWV-04/05 | Real render: News article, Web tab, Privacy/Terms in onboarding with back, explorer link | screenshots |
| LWV-08 | Click page, click omnibox, type; press Esc/Enter; confirm keys reach Flutter | screenshots 03-05 equivalents now fixed |
| LWV-07 | Open Accounts drawer, a menu, a toast, a dialog over a page; view hides, scrim intact, page returns without reload | screenshots |
| LWV-06 | Banxa sandbox order from a keyed CI build to the email screen; Back/return URL works | walk notes |
| LWV-06 | Camera/mic prompt on a real camera on WebKitGTK >= 2.40 (grant and deny) | log lines `request types=[camera] -> GRANT` |
| LWV-01/02 | No-WebKit launch (preload shim from 005 `nowebkit.c` or a clean container): app starts, Web tab hidden, links to browser with the notice | screenshots |
| Pitfall 1 | CI-built real bundle on Ubuntu 24.04 (4.1) and 22.04 (4.1 and forced 4.0) | stderr `loaded` line + a rendered page |
| Pitfall 6 | Quit with a page / checkout open | exit code, no abort |
| Pitfall 5 | Real-hardware check of `GDK_GL` and compositing; first aarch64 run | notes |

### Sampling Rate
- **Per task commit:** the quick command above plus `dart format` and `bash tool/check_brace_style.sh`.
- **Per wave merge:** `flutter test` and `flutter analyze lib test` (analyze exits non-zero on infos; check `$?`, not `tail`).
- **Phase gate:** full suite green, CI Linux build green on both rows with the link-check step, manual walks recorded.

### Wave 0 Gaps
- [ ] `test/web/web_utils_test.dart` - routing decision and launch fallback (LWV-02/03)
- [ ] `test/web/web_overlay_gate_test.dart` - hide under popups (LWV-07)
- [ ] `test/navigation/page_route_test.dart` - `/page` outside the shell (LWV-04)
- [ ] Spike tasks that gate the design: focus hand-back mechanism (A2), unmount-hide without reload (A1), real wallet on 4.1 (A6), plugin library filename (A3), dlopen cost (A7)
- [ ] REQUIREMENTS.md LWV entries; `41-CONTEXT.md` if discuss-phase is run (Open Questions 2, 3, 5)

## Security Domain

`security_enforcement` is enabled (ASVS level 1, block on high).

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2/V3 Authentication, Session | no | wallet auth unchanged; webview shares no wallet session |
| V4 Access Control | yes | permission requests: camera/mic only while on a trusted Banxa URL, everything else denied (`checkout_rules.dart` rule); plugin auto-denies non camera/mic requests in Dart [CITED: spikes/004] |
| V5 Input Validation | yes | `isTrustedCheckoutUrl` (https + Banxa host + plain-DNS regex), `allowsCheckoutNavigation` (https/about only), `isBanxaReturn` compares scheme/host/path; keep these as the only gate for the checkout view |
| V6 Cryptography | no | none added; TLS is WebKit/GnuTLS |
| V9 Communications | yes | no `onSslAuthError` handler may ever proceed past a bad certificate |

| Threat | STRIDE | Mitigation |
|--------|--------|------------|
| API response loads attacker URL in checkout | Spoofing | existing `isTrustedCheckoutUrl` on every nav, reused by Linux host |
| Bad certificate accepted in a wallet-adjacent page | Tampering | register no SSL-error callback; verify Assumption A8 in the native timeout branch |
| Embedded page requests camera/mic/geolocation/notifications | Elevation | Dart policy deny-by-default; only Banxa page gets camera/mic |
| Downloads from a page | Tampering | plugin cancels downloads unless enabled [VERIFIED: download_policy.cc `webkit_download_cancel`] |
| Arbitrary URL in the Web tab/omnibox | Spoofing | existing browser behaviour on other platforms; page opens only user-typed/linked URLs; no wallet keys reachable from the page |
| Secrets in logs | Info disclosure | the plugin logs only the WebKit version line; do not log URLs with order IDs |

AGENTS.md wallet-safety rules are not touched (no key, mnemonic or Cubit state is involved).

## Project Constraints (from CLAUDE.md / AGENTS.md)
- Lazy-senior ladder: reuse (`PopupRouteObserver`, `checkout_rules`, `launchWebSite`) before writing; deletion over addition; question new abstractions.
- Brace every `if` with the body on its own line; `tool/check_brace_style.sh` enforces it in `lib/` and `test/`.
- Widgets, not `_buildFoo()` helpers; Rule of Three before extracting (justifies the shared permission rule, not the browser dedupe).
- Colours from `GWColors` tokens; no `Colors.*` outside `lib/theme/`; both appearance modes, WCAG AA. The new back control and any notice copy must follow this.
- Widgets do not reach past the repository layer: the probe and platform calls live in `web_utils.dart`, not in a widget.
- Comments say WHY only, 3-line doc max; never cite plan/phase/spike numbers or test file names in source (so strip `SPIKE-ONLY (005)` and similar). Use `ponytail:` for deliberate corner-cutting with a named ceiling.
- Before done: `dart format`, `flutter analyze` (non-zero on infos), `flutter test`; quote real output. Flutter is not on PATH.
- Do not change repo-root `banxa/` or `squidrouter/`; `lib/banxa/` is edited normally.
- Do not create commits unless the GSD flow authorizes them (memory: GSD atomic commits are authorized on the working branch); no Claude attribution in commits or PRs; scrub `Co-Authored-By` from subagent commits before pushing. PLAN.md <= 150 lines, SUMMARY.md <= 40.
- Parallel sessions: only the executor session edits `lib/`, `test/`, `packages/` and commits.
- Check `git ls-files --eol` before pushing: a CRLF Dart file breaks the CI brace check.

## Sources

### Primary (HIGH)
- `.claude/skills/spike-findings-geniuswallet/SKILL.md` and `references/linux-webview-plugin.md`, `linux-webview-wallet-integration.md`
- `.planning/spikes/003..007/README.md`, `MANIFEST.md`, `WRAP-UP-SUMMARY.md`, `CONVENTIONS.md`
- Worktree files read this session: `lib/web/{web_utils,web_view_linux,web_view_mobile,web_view_windows,web_view_screen,web_chrome_helpers}.dart`, `lib/navigation/router.dart`, `lib/components/overlay/{global_swap_fab_host,nav_destinations}.dart`, `lib/banxa/checkout/{checkout_rules,checkout_screen,checkout_webview_linux}.dart`, `lib/screens/banxa_buy_screen.dart`, `lib/main.dart`, `.github/workflows/build.yml`, `INSTALL.md`, `third_party/webview_all/**` (CMake, `webkit_runtime.cc`, `linux_webview_widget.dart`, `flutter_view.cc`, `linux_webview.cc`, `download_policy.cc`)
- `gh api repos/abandoft/webview_all` (license, push date, CMake at `b9eac11`); pub.dev API for `webview_all_linux`/`webview_all`

### Secondary / Tertiary
- None. Items tagged `[ASSUMED]` above are the unverified ones.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - spikes validated on five targets; provenance checked
- Architecture / routing / CI: HIGH - call sites, router, workflow lines read directly
- Focus and hide mechanisms: MEDIUM - derived from plugin source; Wave 0 must run them
- Real-wallet-on-4.1, aarch64, real hardware: LOW - never exercised

**Research date:** 2026-10-11
**Valid until:** 2026-11-10 (upstream plugin and Flutter pin are stable; re-check if `abandoft/webview_all` ships a release or the Flutter pin moves)
