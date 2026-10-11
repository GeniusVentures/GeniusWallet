---
phase: 41-linux-in-app-webview
plan: 01
provides: [vendored webview_all (runtime WebKit load), linuxInAppWeb probe, CI no-link guard]
affects: [41-02, 41-03, 41-04]
key-files:
  created: [third_party/webview_all/, .planning/phases/41-linux-in-app-webview/walk/]
  modified: [pubspec.yaml, pubspec.lock, lib/web/web_utils.dart, lib/main.dart, linux/flutter/generated_plugin_registrant.cc, linux/flutter/generated_plugins.cmake, .github/workflows/build.yml, INSTALL.md]
status: complete
actuals: {tokens: 132000, tasks: 3, commits: 5}   # includes the 473 KB byte-identical import; authored diff ~13800
---
# Phase 41 Plan 01: Vendored WebKit plugin, runtime-load walks, CI guard

One AlmaLinux 8 bundle links no WebKit, loads 4.0 or 4.1 at runtime in the real wallet, and CI fails if that changes.

Commits: 10bf5f3a pristine import b9eac11 (byte-identical) / c95b2877 runtime-load patch (the 11 expected paths) / 5c8c6003 startup probe / 1b182318 CI step + INSTALL / 84dc4146 walk evidence.

## Gates
- Build in gw-spike006 `BUILD_RC=0`; `readelf -d` NEEDED webkit|soup|javascriptcore: 0 in genius_wallet, the plugin and libGeniusWallet.so; `nm -D --undefined-only` webkit_/soup_/jsc_ in plugin: 0.
- analyze rc=0, format rc=0, brace rc=0, ID gate 0, `flutter test test/dashboard/transaction_recovery_states_test.dart test/web` passed (25).
- CI step script: bundle exit 0 ("0 undefined webkit_/soup_/jsc_ symbols"); plugin pointed at libwebkit2gtk-4.0.so.37 exit 1; fake plugin with undefined `webkit_x` exit 1; missing plugin exit 1. YAML parses; `grep -c webkit2gtk3-devel` = 2.
- Walks (3 PNGs in walk/; the 4 filtered logs are gitignored by `*.log`, on disk only):
  - 20.04: `loaded libwebkit2gtk-4.0.so.37 (WebKitGTK 2.38.6, libsoup2, run_javascript)`, Privacy Policy in-app; probe 236 ms (includes dlopen).
  - 20.04 + shim: `WebKitGTK unavailable`, no loaded line, Privacy Policy stays out of the app.
  - 24.04 container: `loaded libwebkit2gtk-4.1.so.0 (WebKitGTK 2.52.6, libsoup3, evaluate_javascript)`, Privacy Policy in-app, probe 17-45 ms, window close then exit code 0, no abort.
  - 24.04 no WebKit (0 libwebkit2gtk files): wallet UI shown, `available=false`, no loaded line.
- aarch64 AlmaLinux 8 AppStream has webkit2gtk3-devel 2.54.0-1.el8_10; the first linux_arm PR run stays the gate.
- INSTALL names confirmed: libwebkit2gtk-4.1-0 (Ubuntu 22.04/24.04, Debian 12), libwebkit2gtk-4.0-37 (20.04), webkit2gtk4.1 (Fedora), webkit2gtk3 (AlmaLinux 8).

## Deviations
- [Rule 3] Worktree submodule dirs were empty so `pub get` failed; copied the main checkout's files (same SHAs, no `.git`) in. Never staged.
- [Rule 3] `pub get` regenerated linux/flutter/generated_plugin_registrant.cc and generated_plugins.cmake; committed with the probe.
- Walk-only: 24.04 images needed libcurl4t64, xdg-user-dirs and a system D-Bus (else black window); gw041-u2404 and gw041-nowebkit add them. The launcher uses a plain-text login keyring (gnome-keyring 46 `--login` made no collection and raised a password dialog) and gives DISPLAY only to the wallet.
- launchWebSite is unchanged in the commit; the walk-only edit was reverted.

## For later plans
- Helpers in scratchpad phase41/: sync, build, run, lx, ctr (24.04 container), close (sends WM_DELETE; `xdotool windowclose` gives exit 1, no EWMH WM). Container window id is 6291459.
- Stash "phase-41 spike wallet changes" holds the spike lib/test edits (find by message).

## Self-Check: PASSED
