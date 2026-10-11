---
spike: 007
idea: linux-inapp-webview
name: webkit-runtime-loading
type: standard
validates: "Given one Linux x86_64 bundle built in the AlmaLinux 8 CI image, when it runs on Ubuntu 20.04 (WebKitGTK 4.0 2.38), Ubuntu 22.04 (4.0 and 4.1), Ubuntu 24.04 (4.1 only), AlmaLinux 8 (4.0 2.54) and a distro with no WebKit, then the app always launches; where WebKit exists a page renders in-app and runJavaScriptReturningResult returns a value; where it does not, Dart gets a clean unavailable signal"
verdict: VALIDATED
related: [003, 004, 006]
tags: [linux, webview, webkitgtk, dlopen, dlsym, libsoup2, libsoup3, almalinux8, portability, webview_all, flutter-plugin]
---

# Spike 007: WebKit runtime loading

## What This Validates

**Given** one release bundle built in `ghcr.io/geniusventures/almalinux-8` (+ `webkit2gtk3-devel`
for headers), **when** it runs on Ubuntu 20.04, 22.04, 24.04, AlmaLinux 8 and an image with no
WebKit, **then** it always launches. Where WebKit exists, a page renders in-app and JS evaluation
returns a value. Where it does not, `LinuxWebViewPlatform.isAvailable()` returns `false` so the
wallet can fall back to the system browser.

## Research

Spike 006 showed two blockers: the plugin had `libwebkit2gtk-4.0.so.37` as `DT_NEEDED` (no launch on
24.04), and the 003 compat shims chose APIs at compile time (2.54-built bundle dies on 2.38 with
`undefined symbol: webkit_web_view_evaluate_javascript`).

| Approach | Cost | Verdict |
|---|---|---|
| dlopen + dlsym table, runtime API choice | 1 header + 1 .cc, no call-site edits | chosen, works |
| Two plugin .so builds (4.0, 4.1) picked at runtime | 2 build images (EL8 has no 4.1 / soup3 headers), loader shim anyway, still breaks on 2.38 vs 2.40 | not needed |
| Lazy PLT binding (link nothing, dlopen RTLD_GLOBAL early) | fewest lines | rejected: runner link needs `--allow-shlib-undefined`, dies under `-z now` / `LD_BIND_NOW`, and soup2 struct access still needs runtime branching |

Design: `webkit_runtime.h` declares `GwWebKitApi` (one function pointer per symbol, typed with
`decltype(&::symbol)` from the 4.0 headers) and `#define`s each symbol name to its table slot, so the
~3,400 lines of upstream call sites, GObject cast macros (`WEBKIT_WEB_VIEW()` -> `webkit_web_view_get_type()`)
and error quarks compile unchanged. Version-dependent symbols are typed by hand, because the 4.0/soup2
headers do not declare them. `-Wl,--no-undefined` on the plugin turns any call that bypasses the table
into a link error.

Load order: `libwebkit2gtk-4.1.so.0`, then `libwebkit2gtk-4.0.so.37`. The first one that loads wins.
There is no fallback to 4.0 after a 4.1 symbol miss, because libsoup 2 and 3 abort when mapped into one
process. Runtime choices are made by symbol presence:
- JS: `evaluate_javascript` (>= 2.40) else `run_javascript` + `javascript_result_get_js_value`.
- HTTP for custom `loadRequest` (POST, headers): soup3 getters and `send_and_read_async` when
  `soup_message_get_status` resolves, else soup2 struct fields + `soup_session_queue_message` in a GTask.
- TLS error host: `g_uri_parse` with soup3 (GLib >= 2.66 always there), else `soup_uri_new`.

Loading is lazy, on the first root-channel call (`isAvailable` or `createWebView`). Nothing WebKit is
mapped at launch.

## How to Run

Tree layout (WSL Ubuntu-20.04): `/home/braian/spike007/{webview_all (b9eac11 + webview_all_linux-runtime-webkit.diff), spike_app (app/ here)}`.
Build image is `gw-spike006` from `../006-almalinux8-build/Dockerfile`.

```
bash container-build.sh release           # EL8 build, prints NEEDED + undefined WebKit symbol count
docker build -f Dockerfile.runtime --build-arg BASE=ubuntu:22.04 \
  --build-arg PKGS="libgtk-3-0 libwebkit2gtk-4.0-37 libwebkit2gtk-4.1-0" -t gw007-u2204 .
#   24.04: PKGS="libgtk-3-0t64 libwebkit2gtk-4.1-0" -t gw007-u2404 ; no WebKit: PKGS="libgtk-3-0t64" -t gw007-nowebkit
bash run-bundle.sh 01-ubuntu2004-wk238 14 host env WEBKIT_DISABLE_COMPOSITING_MODE=1
bash run-bundle.sh 04-ubuntu2404-wk41 20 gw007-u2404 -e GDK_GL=gles
PRE='rm -f /usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.1.so.0*;' bash run-bundle.sh 05-ubuntu2204-forced-40 20 gw007-u2204 -e GDK_GL=gles
```

## What to Expect

One native line on stderr, then the Dart log:
`webview_all_linux: loaded libwebkit2gtk-4.1.so.0 (WebKitGTK 2.52.6, libsoup3, evaluate_javascript)`,
`[avail] isAvailable=true`, then for each of local page, local POST, https://example.com:
`FINISHED <url>` followed by `[jseval] result=<title> | 42`. With no WebKit:
`WebKitGTK unavailable: ...cannot open shared object file`, `[avail] isAvailable=false`, and the
"Open in system browser" card.

## Investigation Trail

1. **Symbol inventory.** `nm -D --undefined-only` on the 006 plugin: 131-132 WebKit/JSC/soup symbols.
2. **First build.** Compiled and linked first time in the EL8 image (`-Werror`, `--no-undefined`).
   No `webkit2gtk`/`soup`/`javascriptcore` in `DT_NEEDED` of the executable or plugin; 0 undefined
   WebKit symbols; `libdl.so.2` added. Plugin is 99,512 bytes (was 107 KB), bundle 50,158,561 bytes.
3. **Ubuntu 20.04, 2.38.6.** The 006 crash is gone: `run_javascript` path chosen, JS returns
   (01). WSL host run, so `WEBKIT_DISABLE_COMPOSITING_MODE=1` per 003.
4. **POST/headers through libsoup.** 003 never exercised the soup2 shims at runtime. Added a local
   POST with a custom header and body to the app: `post POST hdr1 a=1` comes back on soup2 (20.04,
   EL8, forced 4.0 on 22.04) and soup3 (22.04, 24.04).
5. **22.04 with both APIs.** 4.1 wins (03). Removing the 4.1 library inside the container forces
   4.0 2.50.4: soup2 + `evaluate_javascript`, a combination no real distro default hits (05).
6. **No WebKit.** The app launches, `isAvailable=false`, fallback card renders (06). `dlerror()` only
   names the last candidate tried (4.0); cosmetic.
7. **GDK_GL=gles.** Used on all container runs as 006 required. Control on 24.04 without it renders
   fine (07), so the black Flutter surface is specific to EL8's GTK 3.22, as 006 suspected.

## Results matrix

| Target | WebKitGTK / soup | Launches | Renders in-app | JS eval returns | soup POST | Fallback |
|---|---|---|---|---|---|---|
| Ubuntu 20.04 (WSL host) | 4.0 2.38.6 / soup2, run_javascript | yes | yes (01) | yes | yes | n/a |
| AlmaLinux 8.10 | 4.0 2.54.0 / soup2, evaluate_javascript | yes | yes (02, GDK_GL=gles) | yes | yes | n/a |
| Ubuntu 22.04 | 4.1 2.50.4 / soup3 (4.0 also present) | yes | yes (03) | yes | yes | n/a |
| Ubuntu 22.04, 4.1 removed | 4.0 2.50.4 / soup2, evaluate_javascript | yes | yes (05) | yes | yes | n/a |
| Ubuntu 24.04 | 4.1 2.52.6 / soup3 | yes | yes (04, 07 without gles) | yes | yes | n/a |
| Ubuntu 24.04, no WebKit | none | yes | n/a | n/a | n/a | `isAvailable=false` (06) |

`ldd` of the executable lists no WebKit, soup or JSC library, and no "not found", on every target (logs).

## Results

**VALIDATED.** One EL8-built bundle launches everywhere tested, renders and evaluates JS on both sides
of the 2.40 API break and both libsoup majors, and reports a clean `false` where WebKit is missing.

Shim size: `webkit_runtime.h` 521 lines (most of it one `#define` per symbol), `webkit_runtime.cc` 100
lines. 124 always-required symbols, 8 soup2-only, 10 soup3/GUri-only, 2 or 5 for JS; 134-137 resolved
per run. Full cumulative diff over upstream `b9eac11`: 8 files, +657/-13, replacing 003's `webkit_compat.h`.
Dart API added: `LinuxWebViewPlatform.isAvailable()`. Any root-channel call while unavailable fails
with `PlatformException(webview_unavailable)`.

Remaining risks:
- **Two symbol lists** (X-macro table and `#define`s) must stay in step. The toolchain catches both
  directions (missing `#define` = link error under `--no-undefined`; missing table entry = compile
  error), but a plugin upgrade means re-running the `nm` inventory.
- **Build needs webkit2gtk-4.0 headers** (soup2 struct fields). EL8 CI and 20.04/22.04 dev boxes have
  them; a 24.04-only dev box cannot build this plugin.
- **A distro with a broken 4.1** (loads, lacks a symbol) gets `isAvailable=false` rather than a 4.0
  fallback, by design (libsoup 2/3 cannot coexist).
- **Not exercised:** cookies, auth, TLS-error and permission paths after the change (they compile
  through the same table, and 006 exercised permissions on the old linking); `createWebView` on a
  no-WebKit system without first calling `isAvailable` (guarded in native, not run); real hardware.
- GDK_GL=gles is still needed on EL8 (GTK 3.22) in containers; not on 24.04.

What the wallet integration (spike 005) must handle:
- Call `LinuxWebViewPlatform.isAvailable()` before constructing a `WebViewController` on Linux; the
  controller calls `createWebView` in its constructor, so a missed check surfaces as an async
  `PlatformException(webview_unavailable)` from `_initialize`.
- Fallback to the system browser (`url_launcher`) when false, and say so in the UI.
- End JS that may produce a Promise with `; undefined` (006, applies to >= 2.40 only now).
- Keep `webkit2gtk3-devel` in the CI image for headers only; runtime packages are the user's distro's.
- Package metadata (deb/rpm/AppImage) should list WebKitGTK as recommended, not required.
- Decide how to set `GDK_GL=gles` / `WEBKIT_DISABLE_COMPOSITING_MODE` (per-distro launcher or not at all)
  only after a real-hardware check.
