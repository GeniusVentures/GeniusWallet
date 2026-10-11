# Linux web view plugin (vendored webview_all_linux)

## Requirements

From idea `linux-inapp-webview`:

- One Linux bundle for every distro: no build-time WebKit link; load libwebkit2gtk-4.1, else 4.0,
  at runtime; no WebKit means the app still runs and links open in the system browser.
- Call isAvailable() before creating a web view; fall back to url_launcher and say so.
- Route every external link through launchWebSite; Banxa's checkout fallback and support link
  stay deliberate exceptions.
- Nothing may draw over a web view and no rounded clip/transform may sit above one: hide the view
  while an overlay/route is above it.
- Plugin must hand keyboard focus back to Flutter.
- CI image needs webkit2gtk3-devel (headers only).

## How to Build It

1. **Vendor the plugin.** Start from `abandoft/webview_all` @ `b9eac11` (MIT), package
   `webview_all_linux` 1.4.4. Apply `sources/007-webkit-runtime-loading/webview_all_linux-runtime-webkit.diff`
   (8 files, +657/-13). It supersedes the 003 `webkit_compat.h` diff; do not apply both.
2. **What the 007 diff does.**
   - `CMakeLists.txt`: `pkg_check_modules(WEBKIT REQUIRED webkit2gtk-4.0)` for headers only, no
     `PkgConfig::WEBKIT` link, link `${CMAKE_DL_LIBS}`, and
     `target_link_options(... "-Wl,--no-undefined")` so a call that bypasses the table fails the build.
   - `webkit_runtime.h`: a `GwWebKitApi` table, one function pointer per symbol typed with
     `decltype(&::symbol)`, and a `#define` per symbol name to its slot, so ~3,400 lines of upstream
     call sites and GObject cast macros compile unchanged.
   - `webkit_runtime.cc` (100 lines): `dlopen(RTLD_NOW | RTLD_LOCAL)` of
     `libwebkit2gtk-4.1.so.0`, then `libwebkit2gtk-4.0.so.37`; first that loads wins. API chosen by
     symbol presence: `evaluate_javascript` (>= 2.40) else `run_javascript` +
     `javascript_result_get_js_value`; soup3 getters + `send_and_read_async` when
     `soup_message_get_status` resolves, else soup2 struct fields + `soup_session_queue_message` in a
     `GTask`; TLS host via `g_uri_parse` (soup3) else `soup_uri_new`.
   - Loading is lazy, on the first root-channel call. Nothing WebKit is mapped at launch.
   - Dart: `LinuxWebViewPlatform.isAvailable()`. Any root-channel call while unavailable fails
     with `PlatformException(webview_unavailable)`.
   - Logs one stderr line on load, e.g. `webview_all_linux: loaded libwebkit2gtk-4.1.so.0
     (WebKitGTK 2.52.6, libsoup3, evaluate_javascript)`.
3. **Permissions.** Keep `webkit_settings_set_enable_media_stream(TRUE)` at view creation. Native
   `permission-request` -> `permissionRequest` event -> `onPermissionRequest` ->
   `completePermissionRequest` -> `webkit_permission_request_allow/deny`. Non camera/microphone
   requests are auto-denied in Dart and never reach the app.
4. **CI.** Add `dnf install -y webkit2gtk3-devel` to the AlmaLinux 8 image or the guarded dnf line
   in "Configure Linux host" (62 packages, 61 MB download, 226 MB installed, 75 s). Nothing else.
5. **Verify a build.** `readelf -d` / `ldd` on the executable and plugin must list no webkit, soup
   or javascriptcore library; `nm -D --undefined-only` on the plugin must show 0 WebKit symbols.
6. **Package metadata** (deb/rpm/AppImage): WebKitGTK is recommended, not required.

## What to Avoid

- **Linking webkit2gtk-4.0 at build time.** The app then fails to launch where 4.0 is absent
  (Ubuntu 24.04 ships only 4.1).
- **Compile-time API choice.** A bundle built against 2.54 dies on 2.38 with
  `undefined symbol: webkit_web_view_evaluate_javascript` on the first JS call.
- **Falling back to 4.0 after a 4.1 symbol miss.** libsoup 2 and 3 abort when mapped into one
  process. A broken 4.1 gets `isAvailable=false` by design.
- **Lazy PLT binding** (link nothing, dlopen RTLD_GLOBAL early): needs `--allow-shlib-undefined`,
  dies under `-z now` / `LD_BIND_NOW`, and soup2 struct access still needs runtime branching.
- **Two plugin builds (4.0 and 4.1):** EL8 has no 4.1/soup3 headers, and it still breaks on 2.38 vs 2.40.
- **Promise results from JS.** WebKit >= 2.40 `evaluate_javascript` throws
  `PlatformException(javascript_error, Unsupported result type)`. End such scripts with `; undefined`.
- **Mock capture devices** (`enable_mock_capture_devices`) kill `WebKitWebProcess` on GStreamer 1.16.
  The plugin sends no web-process-terminated event to Dart.
- **Expecting a camera prompt with no camera.** Video gUM rejects with `OverconstrainedError`
  before any permission signal. Use a microphone to exercise the real prompt.

## Constraints

- Not a Flutter platform view: a native `GtkOverlay` inside `FlView` with the `WebKitWebView` in a
  `GtkLayout` clip on top; Dart sends frame and clip each frame (`setFrame`); the plugin punches an
  input-shape hole. Flutter cannot paint over it (upstream #40). A non-translation transform or a
  non-rectangular clip (`ClipRRect`, rounded `Material` clip) above it hides it entirely.
- GTK focus stays on the `WebKitWebView` after the page has focus; the plugin has no hand-back yet.
- Build needs webkit2gtk-4.0 headers (soup2 struct fields): EL8 CI and Ubuntu 20.04/22.04 have
  them; a 24.04-only dev box cannot build the plugin.
- Two symbol lists (X-macro table and `#define`s) must stay in step. The toolchain catches drift
  in both directions, but a plugin upgrade means re-running the `nm` inventory
  (124 always-required symbols, 8 soup2-only, 10 soup3/GUri-only, 2 or 5 for JS).
- getUserMedia does not exist on Ubuntu 20.04 (WebKitGTK 2.38.6 built without MEDIA_STREAM).
  On 2.54, `enable_media_stream(TRUE)` is necessary and sufficient.
- `GDK_GL=gles` is needed on EL8 (GTK 3.22) in containers, else the Flutter surface is black once
  a web view mounts; not needed on 24.04. Untested on real EL8 hardware.
- WebKitGTK 2.38 accelerated compositing hangs some heavy sites under WSLg;
  `WEBKIT_DISABLE_COMPOSITING_MODE=1` fixes it. Decide launcher env only after a real-hardware check.
- Validated matrix: Ubuntu 20.04 (4.0 2.38.6, soup2), AlmaLinux 8.10 (4.0 2.54.0, soup2),
  Ubuntu 22.04 (4.1 2.50.4, soup3; forced 4.0 also works), Ubuntu 24.04 (4.1 2.52.6, soup3),
  24.04 without WebKit (launches, `isAvailable=false`).
- Bundle cost: plugin `.so` ~100 KB; release bundle +~310 KB over an empty app. WebKit is never bundled.
- Not exercised after the runtime-loading change: cookies, auth, TLS-error and permission paths.

## Origin

Synthesized from spikes: 003, 004, 006, 007
Source files available in: sources/003-webkitgtk-40-embed/, sources/004-camera-permission-path/,
sources/006-almalinux8-build/, sources/007-webkit-runtime-loading/
