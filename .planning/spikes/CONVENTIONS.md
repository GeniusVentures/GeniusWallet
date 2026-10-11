# Spike Conventions

Patterns and stack choices established across spike sessions. New spikes follow these unless the
question requires otherwise.

## Stack

- Flutter 3.41.9 (the CI pin) for every spike app; Dart only, no extra frameworks.
- Linux work runs from WSL2 Ubuntu-20.04 with Docker Desktop's `docker`; the build image is the CI
  image `ghcr.io/geniusventures/almalinux-8` plus `webkit2gtk3-devel` (`gw-spike006`).
- Runtime matrices use small per-distro images built from one `Dockerfile.runtime` with
  `--build-arg BASE=... PKGS=...`.

## Structure

- `.planning/spikes/NNN-name/` holds `README.md` (frontmatter: spike, idea, name, type, validates,
  verdict, related, tags), a minimal `app/` (`pubspec.yaml` + `lib/main.dart`), the patch as a
  `.diff` against a pinned upstream commit, and the build/run scripts.
- Spike apps sit next to the vendored upstream checkout (`webview_all/` sibling of `spike_app/`)
  with `dependency_overrides` to local paths.
- Screenshots and logs are numbered by run (`01-...png`, `20-grant.log`) and cited from the README.

## Patterns

- Log-based observability: one prefixed stdout line per event (`SPIKE <iso-time> [category] msg`,
  `BOOTPROBE`, `SPIKE001`), plus an on-screen log and a JSON export with per-category counts.
- Every surprising result gets a control run that removes the suspect: a plain PyGObject WebKit
  window for plugin questions, a timer that touches nothing for isolate questions, a plain
  `flutter create` app for rendering questions.
- Instrumentation that must not ship is kept in a separate `instrumentation-only-not-for-merge.diff`
  or marked TEMPORARY in source.
- Env-var switches drive scenarios (`SPIKE_URL`, `SPIKE_AUTO`, `SPIKE_DENY`, `SPIKE_NOWEB`, `KEEP`,
  `NOWEBKIT`).
- Missing system libraries are simulated with an `LD_PRELOAD` dlopen shim or by deleting the
  library inside a throwaway container.
- Verdicts: VALIDATED / PARTIAL / INVALIDATED, with what was not exercised listed explicitly.

## Tools & Libraries

- `webview_all_linux` 1.4.4 from `abandoft/webview_all` @ `b9eac11`, vendored and patched.
- `xdotool` + ImageMagick `import` for driving and screenshotting the app window under WSLg.
- `ldd`, `readelf -d`, `nm -D --undefined-only` to prove link-time dependencies.
- Container runs mount `/tmp/.X11-unix` and `/mnt/wslg`; use `GDK_GL=gles` on EL8 (GTK 3.22) and
  `WEBKIT_DISABLE_COMPOSITING_MODE=1` for WebKitGTK 2.38 under WSLg.
- Avoid `enable_mock_capture_devices` on GStreamer 1.16 (crashes the web process).
