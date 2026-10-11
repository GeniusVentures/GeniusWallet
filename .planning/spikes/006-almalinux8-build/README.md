---
spike: 006
idea: linux-inapp-webview
name: almalinux8-build
type: standard
validates: "Given the AlmaLinux 8 CI image (ghcr.io/geniusventures/almalinux-8) plus webkit2gtk3-devel, when the spike 003/004 app with the patched webview_all_linux is built for Linux x86_64 in that container, then it compiles and links; and when the bundle runs there (WSLg X socket mounted), a page renders in-app, navigator.mediaDevices exists, and getUserMedia reaches the Dart onPermissionRequest callback (grant proceeds, deny gives NotAllowedError)"
verdict: PARTIAL
related: [003, 004]
tags: [linux, webview, webkitgtk, almalinux8, ci, docker, getusermedia, libsoup2, glib256, portability]
---

# Spike 006: AlmaLinux 8 build

## What This Validates

**Given** the CI image used by `build.yml`'s Linux job (`ghcr.io/geniusventures/almalinux-8:latest`,
AlmaLinux 8.10, clang 21.1.8) plus `webkit2gtk3-devel`, and Flutter 3.41.9 as pinned in the workflow,
**when** the spike 003/004 app is built for Linux x86_64 in that container with the unchanged
003 patch, **then** it compiles and links. **And when** the bundle runs in the container
against WSLg's X server, a page renders in-app, `navigator.mediaDevices` exists, and
getUserMedia reaches the Dart `onPermissionRequest` callback. Grant lets the call proceed,
and deny rejects it with `NotAllowedError`.

## Research

- The CI image is public. It pulled without auth, so the `almalinux:8` fallback was not needed.
- The image already has everything the workflow's dnf safety net lists, plus gtk3-devel
  3.22.30, glib2 2.56.4, libsoup 2.62.3, and gstreamer1 and plugins-base/good/bad-free 1.16.1.
  `webkit2gtk3` is **not** installed. It is in AppStream as 2.54.0-1.el8_10 (4.0 API, soup2).
- Installed versions in the test image: `webkit2gtk3-2.54.0-1.el8_10`,
  `webkit2gtk3-devel-2.54.0-1.el8_10`, `webkit2gtk3-jsc-2.54.0-1.el8_10`,
  `glib2-2.56.4-177.el8_10`, `libsoup-2.62.3-15.el8_10`, `gtk3-3.22.30-12.el8_10`.
  pkg-config reports webkit2gtk-4.0 2.54.0, libsoup-2.4 2.62.3, and glib-2.0 2.56.4.
- Ubuntu availability, checked in `ubuntu:22.04` and `ubuntu:24.04` containers: 22.04
  ships both `libwebkit2gtk-4.0-37` and `-4.1-0` (2.50.4). **24.04 ships only
  `libwebkit2gtk-4.1-0`** (2.52.6).

## How to Run

```
docker build -t gw-spike006 .              # Dockerfile in this folder
# layout: /home/braian/spike006/{webview_all (b9eac11 + 003 diff), spike_app (app/ here)}
bash container-build.sh debug              # flutter build linux inside the image
bash container-run.sh 20-grant 11 http://127.0.0.1:8765/ \
  -e PULSE_SERVER=unix:/mnt/wslg/PulseServer -e GDK_GL=gles -e SPIKE_AUTO=1
# add -e SPIKE_DENY=1 for the deny run
```

Both scripts run from WSL2 Ubuntu-20.04 using Docker Desktop's `docker`. `container-run.sh`
mounts `/tmp/.X11-unix` and `/mnt/wslg`, screenshots the window with `import`, and copies
the log and JSON export here. App env vars: `SPIKE_AUTO=1` runs devices, then video gUM,
then audio gUM, exports the log, and exits. `SPIKE_DENY=1` starts in DENY mode. `SPIKE_NOWEB=1`
mounts no web view.

## What to Expect

`devices: ["audioinput"]`, then `gum(video): REJECTED OverconstrainedError`, then
`[permission] request types=[microphone] -> GRANT|DENY`, then `RESOLVED tracks=audio:RDP Source`
or `REJECTED NotAllowedError`. Without `GDK_GL=gles`, the Flutter part of the window is
black in this environment. See the trail.

## Observability

Same log layer as 004: on-screen log, `SPIKE` stdout lines, and a JSON export with
per-category counts (`20-grant.json`, `21-deny.json`: `{js: 5, permission: 1, page: 2, nav: 1, server: 1}`).

## Investigation Trail

1. **Image.** Built `gw-spike006` from the CI image, adding `webkit2gtk3-devel`, the Flutter
   3.41.9 tarball, and walk-only extras (mesa-dri-drivers, fonts). The image build took 7 min,
   mostly the Flutter download. Measured separately on the bare CI image,
   `dnf install -y webkit2gtk3-devel` pulls **62 packages, 61 MB download, 226 MB
   installed, 75 s**.
2. **Build.** Compiled and linked first time with clang 21 and **no further patches**. The 003
   compat header's guards select the right branches: WebKit >= 2.40 uses the native
   `evaluate_javascript`, the soup2 branch is used for libsoup 2.62, and the
   `GLIB_CHECK_VERSION(2,66,0)` fallback covers GLib 2.56. The plugin builds with `-Werror`,
   so the build was warning-free. A clean release build took 12 s for the spike app and
   11 s for an empty `flutter create` app.
3. **Size and deps.** The release bundle is 50,231,961 bytes, against 49,848,632 for an
   empty app. That is **+383 KB**, of which the plugin `.so` is 107 KB. WebKit is a system
   library, not bundled. `ldd` on the plugin needs `libwebkit2gtk-4.0.so.37`,
   `libjavascriptcoregtk-4.0.so.18`, `libsoup-2.4.so.1`, `libgio/glib-2.0`, which come from the
   `webkit2gtk3`, `webkit2gtk3-jsc` and `libsoup` rpms. The executable has the plugin as
   `DT_NEEDED`, so these libraries are needed at launch, not on first use.
4. **Render: Flutter surface black.** example.com renders in the web view, and nav, started
   and FINISHED all reach Dart. But every Flutter pixel is black (01). A control
   `flutter create` app renders fine in the same container (00). Bisection is in
   `gl-black-surface-matrix.txt`:
   - Plugin loaded and overlay installed, with no web view: renders (02).
   - Clip GtkLayout mounted without the WebKitWebView inside: renders (06).
   - Skipping the input-shape update: still black.
   - Eleven env toggles had no effect: software GL, indirect GLX, ipc=host, Flutter
     software rendering, GDK_GL disable/software-draw/legacy/always, and WebKit
     compositing/DMABuf/Skia-CPU.
   - **Only `GDK_GL=gles` fixes it** (08). Dart still lays out frames, since a resize
     moves the web view (04).

   So the trigger is the WebKitWebView child under GDK's GLX path on GTK 3.22. This was not
   tried on a real EL8 desktop with a GPU.
5. **Promise results.** `runJavaScript('listDevices()')` throws
   `PlatformException(javascript_error, Unsupported result type)`. WebKit >= 2.40's
   `evaluate_javascript` refuses to serialize a Promise. The 2.38 `run_javascript` shim did
   not do this. Callers have to end scripts with `; undefined`.
6. **mediaDevices.** It exists with the 003 patch (10). With `enable_media_stream` turned off
   by an instrumentation env var, it is `undefined` and gUM throws `TypeError` (15). So the
   setting is necessary on 2.54, as 004 predicted.
7. **Video gUM.** With no camera, it rejects with `OverconstrainedError: Invalid constraint`
   **before** any permission signal (10), so the Dart callback never runs.
   `enable_mock_capture_devices` makes `WebKitWebProcess` die on the first `enumerateDevices`
   (13: the process vanishes and the view goes blank). The plugin sends no
   web-process-terminated event to Dart.
8. **Audio gUM as the real-device proxy.** WSLg exposes a PulseAudio mic. With
   `PULSE_SERVER=unix:/mnt/wslg/PulseServer`, `enumerateDevices` returns `audioinput`.
   - GRANT: `request types=[microphone] -> GRANT`, then `RESOLVED tracks=audio:RDP Source`
     after 5.6 ms (20).
   - DENY: `-> DENY`, then `NotAllowedError` after 3.2 ms (21).
9. **Portability of the EL8-built bundle.**
   - **Ubuntu 24.04:** it does not start. `libwebkit2gtk-4.0.so.37`, `libsoup-2.4.so.1` and
     `libjavascriptcoregtk-4.0.so.18` are not found (31).
   - **Ubuntu 20.04 (WebKit 2.38.6):** it starts and loads the page, then dies on the first
     JS call with `undefined symbol: webkit_web_view_evaluate_javascript`, exit 127 (30).
     The compat guards are compile-time, so a bundle built against 2.54 needs >= 2.40 at
     runtime.

## Results

**PARTIAL.**
- **Validated:**
  - The CI image builds and links the patched plugin. The only change needed is
    `webkit2gtk3-devel`, with no extra source patches, and the diff is unchanged from 003.
  - In-app rendering, navigation events, `mediaDevices`, and the full user-media
    permission round trip (Dart grant -> track, deny -> NotAllowedError) all work on
    WebKitGTK 2.54.
- **Not observed:** a camera-typed prompt, because no camera device was available. Without
  one, WebKit rejects before prompting.
- **Blocking for shipping as-is:**
  - Linking `webkit2gtk-4.0` at build time makes the whole app fail to launch where 4.0 is
    absent: Ubuntu 24.04 and later, and likely other current distros.
  - Compiling against 2.54 makes it crash on JS where WebKit is older than 2.40.
  - The real choice is a runtime `dlopen` of 4.1 or 4.0 (the plugin talks to WebKit
    through a narrow API). The alternatives are a 4.1 build on a newer image, or separate
    bundles.
- **Risk:** the Flutter surface is black under GLX on GTK 3.22 once a web view mounts. The
  only fix found is `GDK_GL=gles`. It needs a check on real EL8 hardware.

CI change needed for the build alone: `dnf install -y webkit2gtk3-devel`. Add it to the
image, or to the guarded rpm/dnf line in "Configure Linux host". No other dnf packages are
needed to compile.
