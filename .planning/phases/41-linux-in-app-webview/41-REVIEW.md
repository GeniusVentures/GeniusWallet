---
phase: 41-linux-in-app-webview
reviewed: 2026-10-11T00:00:00Z
depth: standard
files_reviewed: 24
files_reviewed_list:
  - lib/banxa/checkout/checkout_rules.dart
  - lib/banxa/checkout/checkout_screen.dart
  - lib/banxa/checkout/checkout_webview.dart
  - lib/banxa/checkout/checkout_webview_linux.dart
  - lib/components/overlay/nav_destinations.dart
  - lib/main.dart
  - lib/navigation/router.dart
  - lib/web/web_overlay_gate.dart
  - lib/web/web_utils.dart
  - lib/web/web_view_linux.dart
  - lib/web/web_view_screen.dart
  - linux/flutter/generated_plugin_registrant.cc
  - linux/flutter/generated_plugins.cmake
  - test/banxa/checkout_rules_test.dart
  - test/theme/status_text_color_invariant_test.dart
  - test/web/web_overlay_gate_test.dart
  - test/web/web_page_close_button_test.dart
  - test/web/web_utils_test.dart
  - .github/workflows/build.yml
  - INSTALL.md
  - third_party/webview_all/webview_all_linux/linux/src/webview/webkit_runtime.cc
  - third_party/webview_all/webview_all_linux/linux/src/webview/webkit_runtime.h
  - third_party/webview_all/webview_all_linux/linux/src/platform/flutter_view.cc
  - third_party/webview_all/webview_all_linux/linux/CMakeLists.txt
findings:
  critical: 0
  warning: 6
  info: 9
  total: 15
status: issues
---

# Phase 41: Code Review Report

**Reviewed:** 2026-10-11
**Depth:** standard
**Files reviewed:** 24 (third_party reviewed as the two patch diffs, c95b2877 against 10bf5f3a and de7d1260 against its parent, plus the surrounding plugin code they call into)
**Status:** issues

## Summary

No critical findings. The security posture holds where it matters. No JavaScript channel is registered in either Linux view. Neither view sets an SSL-error handler, so a bad certificate is never accepted. The Linux plugin denies a permission request when no Dart callback is set, and the generic browser sets none. In checkout, camera and microphone are granted only while the last main-frame page is on a Banxa host. Windows, macOS and mobile behave as before. The only shared change is the permission refactor, and its test now covers every `WebviewPermissionKind`.

The native shim is sound. `dlopen` and `dlsym` are checked, and the load is cached in a function-local static. All WebKit calls go through the table, and the link-time `--no-undefined` plus the CI `nm` check make a direct call a build failure. I found no GObject signal leak or ref leak in the new focus handler.

The warnings are failure-mode and robustness gaps:
- A TLS failure leaves the checkout on an endless spinner.
- A rejected `loadRequest` is unhandled in the checkout.
- The popup gate can latch on a stale route.
- The startup probe can kill the process if libsoup 2 is already mapped.
- Article links reach the in-app browser unvalidated.
- The new Linux browser file breaks the project's widget and comment rules.

## Structural Findings (fallow)

None provided.

## Narrative Findings (AI reviewer)

## Warnings

### WR-01: A TLS error shows nothing and never reaches `onLoadError`; checkout spins forever

**File:** `third_party/webview_all/webview_all_linux/linux/src/webview/linux_webview.cc:651-690`
**File:** `lib/banxa/checkout/checkout_webview_linux.dart:62-71`
**Issue:** `load_failed_with_tls_errors_cb` returns TRUE whenever the Dart event channel is listening, which is always the case here. Dart then answers `proceed: false` (`linux_webview_events.dart:_handleSslAuthErrorEvent`, no handler registered), and the plugin only forgets the pending error. WebKit does not emit `load-failed` once the TLS signal is handled, and the plugin does not synthesise a `webResourceError`. The result is that no error page appears and `onWebResourceError` never fires. In `CheckoutWebViewLinux` the first load stays hidden under `WebOverlayGate(hidden: _loading)` with the spinner on top, and `widget.onLoadError()` is never called. The user never sees "Checkout didn't load / Try again / Open in browser". In the generic browser the tab goes blank with no explanation. Failing closed is correct, but the failure is invisible. Research assumption A8 (41-RESEARCH.md:327) said the callback "returns FALSE (WebKit error page)". The code does the opposite, so the assumption was not verified.
**Fix:** In `completeSslAuthError`, when `proceed` is false, emit the same `webResourceError` event that `load_failed_cb` emits, with `isForMainFrame` true and the failing URI. For example, factor the body of `load_failed_cb` into a helper and call it from the cancel branch. Alternatively return FALSE from `load_failed_with_tls_errors_cb` when Dart has no SSL handler, so WebKit shows its own error page and emits `load-failed`. Then walk a self-signed host in checkout and confirm the "Checkout didn't load" notice appears.

### WR-02: Unawaited `loadRequest` in checkout drops failures

**File:** `lib/banxa/checkout/checkout_webview_linux.dart:74`
**Issue:** `..loadRequest(widget.uri)` returns a Future that is neither awaited nor given an error handler. `LinuxWebViewController` creates its native view lazily, and `_initialize` throws `StateError('Failed to create Linux WebView instance.')` or a `PlatformException` (`creation_error`, `webview_unavailable`) if `createWebView` fails. The `isAvailable` probe only proves that `dlopen` and `dlsym` worked. It does not prove that the GTK view can be created. In that case the error goes to the zone as an uncaught exception and the user is left on a permanent spinner with no `onLoadError`. The same pattern is at `lib/web/web_view_linux.dart:243-245`, where it leaves a blank tab.
**Fix:**
```dart
..loadRequest(widget.uri).catchError((_) => widget.onLoadError());
```
Cascades return the receiver, so split the call out of the cascade:
```dart
_controller = WebViewController(onPermissionRequest: _onPermissionRequest)
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(...);
unawaited(_controller.loadRequest(widget.uri).catchError((_) => widget.onLoadError()));
```

### WR-03: `PopupRouteObserver` can latch "popup open" forever; the web view then stays hidden

**File:** `lib/web/web_overlay_gate.dart:14`
**File:** `lib/components/overlay/global_swap_fab_host.dart:187-200`
**Issue:** `WebOverlayGate.shellPopupRoutes` is a process-wide singleton, and it clears a route only on `didPop`, `didRemove` or `didReplace`. When a Navigator is disposed with a popup still open, no observer callback fires. That happens when the user leaves the shell for a non-shell route, such as a redirect or `context.go` from a dialog button that did not pop first. The route then stays in `_open`, `anyOpen` stays true, and every later `WebOverlayGate` is Offstage until restart. This is the symptom of "the Web tab went blank". The gate exists because the native view cannot be seen through, so a stuck gate hides the whole feature.
**Fix:** Drop routes that are no longer attached when reading the state.
```dart
bool get anyOpen {
  _open.removeWhere((r) => r.navigator == null);
  return _open.isNotEmpty;
}
```
Alternatively also override `didChangeTop` or listen to `route.completed`, so each route removes itself. Add a test that disposes the Navigator with a dialog open and expects `anyOpen == false`.

### WR-04: Startup probe can abort the whole app when libsoup 2 is already mapped

**File:** `third_party/webview_all/webview_all_linux/linux/src/webview/webkit_runtime.cc:19-34`
**File:** `lib/main.dart:88`
**Issue:** The comment in the loader states that libsoup 2 and 3 abort the process when both are mapped. `main()` now calls `dlopen("libwebkit2gtk-4.1.so.0")` unconditionally on every Linux start, before Sentry is initialised. If any other already-loaded library in the process has pulled in libsoup 2 (a GIO or GTK module, an SDK dependency, a future plugin), the 4.1 `dlopen` runs libsoup 3's constructor, which calls `g_error` and kills the wallet at launch. Before this phase such a user just got the system browser. A feature that is optional by design must not be able to prevent launch. The reverse case applies to the 4.0 fallback.
**Fix:** Before each `dlopen`, scan `/proc/self/maps` for the opposite soup major (`libsoup-2.4` before 4.1, `libsoup-3.0` before 4.0). Skip that candidate and log why. Cache the result as now.

### WR-05: Article and recovery links reach the in-app browser without a scheme check

**File:** `lib/web/web_utils.dart:34-47`
**Issue:** `launchWebSite` passes `article.link` (third-party RSS content, `crypto_news_screen.dart:533,683,787,843`) and recovery or explorer URLs straight into `WebViewExtras.url`. `WebViewLinux` loads it with JavaScript unrestricted and no `onNavigationRequest`. On Linux this used to go through `launchUrl`. It now loads inside the wallet process, in a shared persistent WebKit context. Nothing limits the scheme, so a feed item with `file://` or `javascript:` is handed to WebKit. WebKit blocks most cross-origin cases, but the wallet should not depend on that. The Windows and mobile browsers share this gap, so it is not a regression introduced here. It is a new exposure on Linux.
**Fix:** In `launchWebSite`, validate before routing and fall back to `launchUrl` or nothing:
```dart
final uri = Uri.tryParse(url);
if (uri == null || uri.scheme != 'https') { return; }
```
Do the same in the `/web` route builder, because deep links can set `extra`.

### WR-06: `web_view_linux.dart` breaks the project's own rules (widgets, comments, debug noise)

**File:** `lib/web/web_view_linux.dart:367,397,451,589,608,645,671,684` (helper methods); `:389,570,585,616,689,713,100` (comments); `:57,60,179,189,196,212,226,231,241,248` (debug prints)
**Issue:** AGENTS.md says "Widgets, not helper methods". Eight `Widget _build...()` methods are added, so every omnibox keystroke or hover rebuilds the whole screen. The same file also cites sketch and plan numbers ("036-A", "035-B", "sketch 022 B2", "#4, 2026-07-24") and names a person ("Jakub:"). The comment rule forbids sketch and plan numbers in source, and several comments run well past three lines. The file also ships ten `[DEBUG]` `debugPrint` lines and dead `!Platform.isMacOS` branches, since the file is Linux-only. It carries the Uniswap-specific dark-mode hack over from the mobile browser unchanged. The `ponytail:` note admits the duplication, and the mobile file already has the same defects, but a new file should not add them again.
**Fix:** Extract `_TabStrip`, `_TabChip`, `_Omnibox` and `_OmniboxCenter` as `StatelessWidget`s that take values and callbacks. Strip the sketch and person references and keep only the why. Delete the `[DEBUG]` prints and the `Platform.isMacOS` conditions. Drop the Uniswap special case unless the Linux walk showed it is needed.

## Info

### IN-01: Closing a tab can select the wrong tab

**File:** `lib/web/web_view_linux.dart:338-359`
**Issue:** `_currentTabIndex = _currentTabIndex > 0 ? _currentTabIndex - 1 : 0` ignores which tab was closed. With tabs 0, 1, 2 and the current tab at 1, closing tab 2 moves the selection to tab 0. The mobile browser has the same behaviour.
**Fix:** If `index < _currentTabIndex`, decrement. If `index == _currentTabIndex`, select `min(index, newLength - 1)`. Otherwise leave it alone.

### IN-02: Checkout permission gate is stringly typed

**File:** `lib/banxa/checkout/checkout_rules.dart:68-76`
**Issue:** The security gate now compares enum `.name` strings from three unrelated enums. A rename upstream, or a new member called `camera` with different meaning, changes what is granted with no compile error. The test (`checkout_rules_test.dart`) pins the current names, which helps. Nothing guards a future fourth host.
**Fix:** Acceptable for now. If a third consumer appears, map each host enum to one local `enum CheckoutMedia { camera, microphone }` at the edge and take that in the rule.

### IN-03: `_onBanxaPage` flips at navigation request, not at commit

**File:** `lib/banxa/checkout/checkout_webview_linux.dart:50-53`
**Issue:** The flag is set in `onNavigationRequest`, before the page commits. If a request to a Banxa URL is then cancelled or turns into a 204 or download, the flag stays true while a bank or 3-D Secure page is still displayed, and that page could be granted the camera. This is the same as the mobile host and is a narrow window. It needs the user to be on a non-Banxa page and a Banxa navigation to not commit.
**Fix:** Set the flag only in `onPageStarted` (or on page commit) and leave `onNavigationRequest` as an allow or deny decision.

### IN-04: Popup gate reveals the page at `didPop`, before the exit animation ends

**File:** `lib/components/overlay/global_swap_fab_host.dart:205`
**Issue:** `didPop` fires when the pop starts, so the native page paints over the dialog or sheet while it fades out. This is a short visual flicker, not a functional bug.
**Fix:** Optional. Remove the route on `route.completed` instead of `didPop`.

### IN-05: `Offstage` wrapper added on every platform

**File:** `lib/banxa/checkout/checkout_screen.dart:299`
**Issue:** Windows, macOS and mobile now get a no-op `Offstage(offstage: false)` around the host. It has no visible effect, but the task said no Linux change should touch other platforms.
**Fix:** `hostKind == CheckoutHostKind.linux ? Offstage(...) : keyedHost`, or keep as is and accept the extra element.

### IN-06: Focus handler only covers mouse presses and is not null-safe against `webviews`

**File:** `third_party/webview_all/webview_all_linux/linux/src/platform/flutter_view.cc:161-175,235-238`
**Issue:** `flutter_input_event_cb` returns early for anything but `GDK_BUTTON_PRESS`, so a touch or pen tap on Flutter UI does not release WebKit's keyboard focus. It also calls `g_hash_table_iter_init(&iter, self->webviews)` without checking for null. `webview_all_linux_plugin_dispose` sets `webviews = nullptr` and only then calls `detach_linux_webview_host`, which disconnects this handler. Nothing runs in between today, so it is safe, but the order is fragile. Signal connect and disconnect pair correctly through `g_signal_handlers_disconnect_by_data`, and I found no leak.
**Fix:** Also handle `GDK_TOUCH_BEGIN`. Add `if (self == nullptr || self->webviews == nullptr) { return FALSE; }` at the top. In dispose, call `detach_linux_webview_host` before destroying `webviews`.

### IN-07: Loader logs only the last `dlerror`

**File:** `third_party/webview_all/webview_all_linux/linux/src/webview/webkit_runtime.cc:24-33`
**Issue:** If both libraries fail, the warning shows only the 4.0 error. The reason 4.1 failed (often a missing libsoup 3 or a version symbol) is lost, which makes remote diagnosis harder. If 4.1 loads but lacks a required symbol, the loader returns FALSE without trying 4.0. That is intentional and documented, but not logged as a reason.
**Fix:** Log `dlerror()` after each failed candidate.

### IN-08: CI check passes silently if `readelf` cannot read the file

**File:** `.github/workflows/build.yml:817-821`
**Issue:** `if readelf -d "$f" | grep ...` treats a `readelf` failure the same as "no match". Only the plugin file has an existence check. If the runner binary is renamed, the first half of the check goes quiet.
**Fix:** Add `[ -f "$f" ] || { echo "::error::$f is missing"; exit 1; }` inside the loop.

### IN-09: Build now needs `webkit2gtk-4.0` headers, undocumented for contributors

**File:** `third_party/webview_all/webview_all_linux/linux/CMakeLists.txt:12`; `INSTALL.md:56`
**Issue:** `pkg_check_modules(WEBKIT REQUIRED webkit2gtk-4.0)` cannot be satisfied on Ubuntu 24.04 and other distros that dropped the 4.0 dev package, so a contributor build fails at configure time. `INSTALL.md` documents only the runtime library. CI is covered by `webkit2gtk3-devel`.
**Fix:** Add a build-dependencies line (`libwebkit2gtk-4.0-dev` or `webkit2gtk3-devel`, headers only) near the INSTALL.md note or in the developer docs, with the 24.04 workaround.

### Notes (no action)

- `test/web/web_utils_test.dart:24` compares `web.visible` with `inAppWeb`, which is the same expression in the source, so it cannot fail. The `opensInApp` table above it carries the real coverage.
- `lib/web/web_utils.dart:21` swallows every probe error without a log line. A `debugPrint` or a Sentry breadcrumb would help diagnose "why is the Web tab missing on my machine".

## Fixes

Applied 2026-10-11 on `spike/linux-webview`. Gates on the final tree: `dart format` 0 changed, `flutter analyze` 4 infos, all in untouched `third_party/webview_all` files (two `include_file_not_found` warnings and two infos), brace and raw-colour checks clean, `flutter test` +2576 ~6 (baseline +2566 ~6, 10 new tests), container build `BUILD_RC=0` with 0 NEEDED webkit/soup/jsc entries and 0 undefined `webkit_`/`soup_`/`jsc_` symbols in the plugin.

| Finding | Status | Commit |
|---------|--------|--------|
| WR-01 | fixed | 38c8c2bc (native), browser error panel in 0549889d |
| WR-02 | fixed | 43d727ef (checkout), 0549889d (browser) |
| WR-03 | fixed | aa559db1 |
| WR-04 | fixed | 0410a20b |
| WR-05 | fixed | 1bf17b87 |
| WR-06 | fixed for `web_view_linux.dart` | 0549889d |
| IN-07 | fixed (every `dlerror` logged) | 0410a20b |
| Note: self-comparing assertion | fixed | 1bf17b87 |
| Note: swallowed probe error | fixed (`debugPrint`) | 1bf17b87 |

- WR-01: a rejected TLS certificate now sends a main-frame `webResourceError` (`failedSslHandshake`). Checkout's existing `onWebResourceError` shows "Checkout didn't load"; the browser hides the native page and shows a retry panel. The load still fails closed.
- WR-02: both `loadRequest` calls catch failures. In the browser, `reload` and the Uniswap reload go through the same handler.
- WR-03: a popup route clears itself when its `completed` future resolves, which fires on navigator disposal. The new test disposes a navigator with a dialog open and fails without the fix.
- WR-04: each candidate carries the libsoup major it conflicts with and is skipped when `/proc/self/maps` shows it. The soname list is unchanged.
- WR-05: `isOpenableWebUrl` (https, non-empty host) guards `launchWebSite` on all platforms. The `/web` route opens the home page when `extra.url` fails it.
- WR-06: eight helpers became private widgets (`_TabStrip`, `_TabChip`, `_SearchBar`, `_NavButton`, `_OmniboxCenter`, `_LoadFailed`; hover state is a `ValueNotifier` so a hover repaints one chip). Debug prints, sketch and person references and the macOS branches are gone. The Uniswap dark-mode path is kept as it was.
- Follow-up, not done: `lib/web/web_view_mobile.dart` has the same helper methods, comments and debug prints (out of scope). IN-01 (wrong tab selected on close), IN-02..IN-06, IN-08 and IN-09 were not touched.
- Needs a new walk: WR-01 (self-signed host in checkout and in the browser), WR-04 (a start with libsoup 2 already mapped, and a normal 4.1 start), and the browser tab strip, omnibox and retry panel after the widget split.

---

_Reviewed: 2026-10-11_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
