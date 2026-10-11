---
spike: 003
idea: linux-inapp-webview
name: webkitgtk-40-embed
type: standard
validates: "Given Ubuntu 20.04 (webkit2gtk-4.0, WebKitGTK 2.38.6, libsoup 2.70), when a minimal Flutter Linux app uses a vendored, patched webview_all_linux, then https pages render inside the Flutter window, keep rendering after window resizes, navigation interception blocks a non-https URL, and page-finished events arrive in Dart"
verdict: VALIDATED
related: [004]
tags: [linux, webview, webkitgtk, webview_all, wsl, libsoup2, flutter-plugin]
---

# Spike 003: WebKitGTK 4.0 embed

## What This Validates

**Given** Ubuntu 20.04, which only ships webkit2gtk-4.0 (WebKitGTK 2.38.6, libsoup 2.70, GLib 2.64),
**when** a minimal Flutter 3.41.9 Linux app uses a locally vendored, patched copy of
`webview_all_linux` 1.4.4 (abandoft/webview_all @ `b9eac11`, MIT),
**then** https pages render inside the Flutter window, survive resizing, a non-https
navigation is blocked by `onNavigationRequest`, and `onPageFinished` fires.

## Research

`webview_all_linux` does not use a Flutter platform view (Flutter Linux has none). It
installs a native `GtkOverlay` inside `FlView` via a `parent-set` emission hook before
the view is realized, and places the `WebKitWebView` in a `GtkLayout` clip container on
top. Dart reports the widget's frame and clip rect each frame (`setFrame`), and the
plugin punches an input-shape hole in Flutter's event surface over the web view.

Consequences that follow from that design (read in source, not all exercised here):
- Flutter widgets cannot paint over the web view. Upstream issue #40 is exactly this
  ("not possible to have a widget that goes on top"), not a camera issue.
- The widget hides the native view when an ancestor applies a non-translation transform
  (scale/rotate) or a non-rectangular clip (`_hasNonRectangularClip`), e.g. `ClipRRect`.

Upstream issue #22 (view collapses to 0x0 after the first frame on WSL) was filed
against 0.5.4; the maintainer says it was fixed. 1.4.4 drives geometry from a
post-frame `syncGeometry()` and only hides on detach, unpainted, or unsupported
transform/clip.

## How to Run

Inside WSL Ubuntu-20.04 (`apt-get install libwebkit2gtk-4.0-dev`):

```
git clone https://github.com/abandoft/webview_all && cd webview_all
git checkout b9eac11 && git apply webview_all_linux-webkit2gtk-4.0.diff
flutter create --platforms=linux spike_app   # then copy app/pubspec.yaml and app/lib/main.dart in
cd spike_app && flutter build linux --debug
DISPLAY=:0 GDK_BACKEND=x11 WEBKIT_DISABLE_COMPOSITING_MODE=1 \
  SPIKE_URL=https://cointelegraph.com/ build/linux/x64/debug/bundle/spike_app
```

`app/pubspec.yaml` expects `webview_all/` as a sibling of `spike_app/`, and overrides all
federated packages to their local paths.

## What to Expect

A button row, the web view filling the middle, and an event log at the bottom (also
printed to stdout as `SPIKE <iso-time> [category] message`). "http (block)" logs
`[nav] BLOCK http://neverssl.com/` and the page does not change.

## Investigation Trail

1. **Unpatched build.** CMake fails: `pkg_check_modules(... webkit2gtk-4.1)` not found.
2. **CMake fallback only** (`pkg_search_module(WEBKIT ... webkit2gtk-4.1 webkit2gtk-4.0)`).
   Configures, then 19 compile errors in three groups:
   - `webkit_web_view_evaluate_javascript[_finish]` - added in WebKitGTK 2.40.
   - `GUri` / `G_URI_FLAGS_NONE` - added in GLib 2.66 (20.04 has 2.64).
   - libsoup3-only API in the custom `loadRequest` path: `soup_message_get_status/
     _get_method/_get_request_headers/_get_response_headers`,
     `soup_message_set_request_body_from_bytes`, `soup_session_send_and_read_async/_finish`.
3. **Compat header** `linux/src/webview/webkit_compat.h`: version-guarded inline shims
   with the new API names, so the call sites stay untouched (`run_javascript` +
   `webkit_javascript_result_get_js_value`; soup2 struct fields;
   `soup_session_queue_message` wrapped in a `GTask`; `SoupURI` host fallback). Builds
   clean; `ldd` shows `libwebkit2gtk-4.0.so.37` + `libsoup-2.4.so.1`.
4. **example.com.** Renders in-app on first launch (01). nav ALLOW, started, FINISHED
   all reach Dart.
5. **Navigation interception.** `loadRequest(http://neverssl.com)` -> `[nav] BLOCK`, no
   page change. Only main-frame `loadRequest` was tested, not link clicks or iframes.
6. **cointelegraph.com hangs.** `started` logged, never `FINISHED`, `WebKitWebProcess`
   pinned at ~95% CPU, blank view. **Control:** a plain PyGObject WebKit2 4.0 window
   (`control-plain-webkit.py`, no Flutter, no plugin) hangs the same way. 4 of 4 runs:
   `load-changed` stops at committed or finished, and `run_javascript` probes never
   return. With `WEBKIT_DISABLE_COMPOSITING_MODE=1`, 3 of 3 runs load in under 1 s and
   probes return. So this is WebKitGTK 2.38 accelerated compositing under WSLg, not
   the plugin. Wikipedia loads fine with compositing on.
7. **Resize.** With compositing disabled: 1280x720 -> 900x600 -> 1500x950 (or 1300x800).
   The page reflows and re-renders each time (02, 03). Tried 4 runs. The **first** run
   stayed blank after resizing, and stayed blank for 30 s. That run was before native
   logging was added, and a hung web process from step 6 may still have been alive.
   Not reproduced in 3 later runs, including one with compositing on (example.com).
8. **Issue #22 reproduction attempt.** Added `g_message` logging of every native
   `setFrame` and WebKit `size-allocate`. Every frame was correct (e.g.
   `frame=0,32 1500x748 visible=1` -> `allocated 1500x748 mapped=1`). No 0x0 or
   `visible=0` frame was ever sent. #22 does not reproduce on 1.4.4, so patch (3) was
   not needed. The logging was removed from the final diff.

## Results

**VALIDATED**, with caveats. The vendored plugin plus a 132-line patch (5 files)
builds against webkit2gtk-4.0 / libsoup2 / GLib 2.64. It renders https pages inside
the Flutter window, follows resizes, blocks non-https navigations through Dart, and
delivers page-started and page-finished events.

Caveats:
- Some heavy sites hang WebKitGTK 2.38's web process on WSLg when compositing is on.
  `WEBKIT_DISABLE_COMPOSITING_MODE=1` fixes it. Whether real hardware needs this is
  untested.
- The soup2 shims for `loadRequest` with custom method, headers or body compile, but
  no POST or headers request was made at runtime.
- 1 of 4 resize runs went blank. The cause is unconfirmed.
- No Flutter overlay can draw above the web view (#40), and rounded clips or scale
  transforms hide it entirely. This affects any wallet screen design.
