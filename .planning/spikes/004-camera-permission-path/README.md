---
spike: 004
idea: linux-inapp-webview
name: camera-permission-path
type: standard
validates: "Given the embedded webview_all_linux view from spike 003, when a page calls navigator.mediaDevices.getUserMedia({video:true}), then the Dart onPermissionRequest callback fires; grant lets the call proceed (NotFound/NotReadable without a camera) and deny rejects with NotAllowedError"
verdict: PARTIAL
related: [003]
tags: [linux, webview, webkitgtk, getusermedia, camera, permissions, wsl]
---

# Spike 004: Camera permission path

## What This Validates

**Given** the spike 003 app (Ubuntu 20.04, WebKitGTK 2.38.6, patched `webview_all_linux`),
**when** a secure-context page calls `getUserMedia({video:true})`,
**then** the Dart permission callback fires. Grant lets the call proceed and deny
rejects it with `NotAllowedError`.

## Research

- The test page is served by a `dart:io` `HttpServer` inside the app at
  `http://127.0.0.1:8765/`. The page reports `isSecureContext=true`, so loopback http
  counts as secure.
- Plugin flow: the native `permission-request` signal becomes a `permissionRequest`
  event, then `LinuxWebViewController` calls the app's `onPermissionRequest`, then
  `completePermissionRequest` calls `webkit_permission_request_allow/deny`. Requests
  whose types are not camera or microphone (geolocation, notifications) are
  **auto-denied in Dart and never reach the app callback**.
- WebKitGTK `Source/cmake/OptionsGTK.cmake`: `ENABLE_MEDIA_STREAM` defaults to
  `${ENABLE_EXPERIMENTAL_FEATURES}` in 2.38.6 and to `ON` from 2.40.0.
  `ENABLE_WEB_RTC` stays experimental through 2.44.
- Upstream issue #40 is not about camera settings. It covers Flutter widgets that
  cannot draw over the web view (see spike 003). The settings patch was written here
  without an upstream issue behind it.

## How to Run

Same build as spike 003, with the same diff. To exercise the Dart round trip on a
WebKit without media stream, apply `instrumentation-only-not-for-merge.diff` instead.
Then:

```
DISPLAY=:0 GDK_BACKEND=x11 SPIKE_GEO_AS_CAMERA=1 SPIKE_URL=http://127.0.0.1:8765/ \
  build/linux/x64/debug/bundle/spike_app
```

Buttons: getUserMedia, devices, notify, geo, mode GRANT/DENY toggle, export log (writes
`/tmp/spike-log.json` with per-category counts).

## What to Expect

On Ubuntu 20.04, `mediaDevices=NO` and getUserMedia fails with `TypeError`. With the
instrumentation build: geo in GRANT mode gives `code=2` (the request proceeds and
fails to reach a location service), and in DENY mode gives `code=1 User denied`.

## Observability

On-screen event log plus stdout `SPIKE` lines, plus a JSON export with a category
summary (`spike-log.json`: `{js: 6, permission: 2, page: 4, nav: 2, server: 1}`). The
instrumentation diff adds native `SPIKEDBG` `g_message` lines for every permission
signal and frame update.

## Investigation Trail

1. **Baseline (no settings patch).** `isSecureContext=true`, `navigator.mediaDevices`
   undefined, so getUserMedia throws `TypeError`. No permission signal fires.
2. **Patch (2): `webkit_settings_set_enable_media_stream(TRUE)` at view creation.**
   No change: still undefined (01).
3. **Control, plain PyGObject WebKit2 4.0** (`control-plain-webkit-gum.py`): set
   `enable-media-stream`, `enable-mediasource`, `enable-webrtc`,
   `enable-mock-capture-devices` all TRUE. Result: `typeof navigator.mediaDevices` is
   `undefined`. This rules out the plugin.
4. **Root cause.** The library contains 0 occurrences of `enumerateDevices` or
   `GStreamerCapturer`. Ubuntu's focal `debian/rules` does not set MEDIA_STREAM, so
   the 2.38 default (experimental only, OFF) applies. **getUserMedia does not exist in
   Ubuntu 20.04's WebKitGTK.** No setting can enable it.
5. **Proxy for the permission plumbing.** Notification and geolocation requests do
   reach native `permission-request` (`listening=1`), but Dart auto-denies them
   because they are not camera or microphone. A spike-only native hack under
   `SPIKE_GEO_AS_CAMERA` tags geolocation requests as `camera` to drive the real app
   callback:
   - GRANT: `[permission] request types=[camera] -> GRANT`, then
     `geo: REJECTED code=2 Failed to connect to geolocation service` (02).
   - DENY: `-> DENY`, then `geo: REJECTED code=1 User denied Geolocation` (03).
   The JS result arrived 4-17 ms after the Dart callback logged.

## Results

**PARTIAL.**
- **Validated:** native permission signal, Dart `onPermissionRequest`,
  grant/deny, and WebKit decision, end to end in both directions, on the embedded
  view. Requests other than camera or microphone are denied by default.
- **Invalidated on Ubuntu 20.04:** WebKitGTK 2.38.6 is built without MEDIA_STREAM, so
  getUserMedia and the camera prompt cannot happen on this distro at all.
- **Unverified:** whether `enable_media_stream(TRUE)` is needed and sufficient on
  WebKitGTK 2.40 or later. It should be, since MEDIA_STREAM is compiled in there but
  the setting defaults off. The real camera NotFound/NotAllowed outcomes were never
  observed.

Next step: rerun this page on a 2.40+ WebKitGTK. AlmaLinux 8 ships webkit2gtk3 2.54.0
on the 4.0 API with soup2. Ubuntu 22.04 or later would also work.

### EL8 follow-up (2026-10-11, spike 006)

Reran the same page on AlmaLinux 8 (WebKitGTK 2.54.0, libsoup 2.62, GLib 2.56) with
the same patch, in the CI image under Docker. Full detail in `../006-almalinux8-build/`.
- `enable_media_stream(TRUE)` is **necessary and sufficient** on 2.54:
  `mediaDevices=yes` with it. Without it, getUserMedia throws `TypeError`
  (`15-no-media-stream.log`).
- **Video** with no camera rejects with `OverconstrainedError: Invalid constraint`
  **before** any permission request. WebKit checks devices first, so the result is
  neither NotFound nor NotReadable, and the Dart callback never runs. Mock capture
  devices crash the web process on GStreamer 1.16 (`13-mock-grant.log`).
- **Microphone** (WSLg exposes a PulseAudio "RDP Source") exercises the real prompt:
  GRANT logs `request types=[microphone] -> GRANT`, then `RESOLVED tracks=audio:RDP
  Source` 5 ms later. DENY logs `-> DENY`, then `NotAllowedError` 3 ms later
  (`20-grant.*`, `21-deny.*`). So the user-media permission path runs end to end on
  a real WebKit decision. The camera-typed prompt is still unobserved because no
  camera device was available.
