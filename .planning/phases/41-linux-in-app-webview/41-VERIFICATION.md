---
phase: 41-linux-in-app-webview
verified: 2026-10-11T00:00:00Z
status: human_needed
score: 9/9 requirements verified by code and committed walk evidence; 5 manual-only items open
behavior_unverified: 0
gaps: []
human_verification:
  - test: "Real camera and microphone on Linux, keyed Banxa sandbox order to the ID step"
    expected: "Allow gives a camera preview, deny gives Banxa's error. On 20.04 (WebKitGTK 2.38) getUserMedia is absent, so Open in browser is the route."
    why_human: "No camera reaches the agent; local builds have no Banxa key. The Linux permission handler has no automated test."
  - test: "Fresh sandbox order from the PR CI Linux tarball: Buy, checkout in the dialog, email screen, finish or close"
    expected: "Done comes from the polled status."
    why_human: "Needs a keyed build. The walk only reached Banxa's order-less 'Hello.' page."
  - test: "First linux_arm CI run on a PR"
    expected: "webkit2gtk3-devel installs on aarch64, build passes, the 'Linux bundle loads WebKit only at runtime' step is green on both Linux rows."
    why_human: "The CI step has never run in CI. Only a local script run of it was done."
  - test: "Native Ubuntu 24.04 on real hardware"
    expected: "Pages render without GDK_GL=gles or WEBKIT_DISABLE_COMPOSITING_MODE; focus hand-back and overlay hiding behave as in the container walks."
    why_human: "All walks were WSLg or container only."
  - test: "Windows and Android camera/ID check on Banxa after the shared permission refactor; confirm More menu and spinner look unchanged on Windows and mobile"
    expected: "Camera and microphone granted on a Banxa page, denied elsewhere; no visible change."
    why_human: "windowsCheckoutPermission and the mobile CheckoutWebView were moved onto checkoutPermissionAllowed and not walked. Unit tests cover the rule."
---

# Phase 41: Linux in-app webview Verification Report

**Phase Goal:** On Linux, articles, the Web tab, legal pages, explorer links and Banxa checkout open inside the wallet window; one bundle runs on every distro with WebKitGTK loaded at runtime, and without it the app runs and links open in the system browser.
**Status:** human_needed
**Re-verification:** No, initial verification.

## Requirements

| ID | Plan | Status | Evidence |
|----|------|--------|----------|
| LWV-01 | 41-01 | VERIFIED (CI run pending) | `webkit_runtime.cc` dlopen()s 4.1 then 4.0 through a dlsym table. Plugin CMake links only `PkgConfig::GTK` and `${CMAKE_DL_LIBS}`, takes WebKit headers only, and uses `-Wl,--no-undefined`. Summary reports `readelf -d` NEEDED webkit/soup/jsc = 0 on the exe, the plugin and libGeniusWallet.so. `walk/01-u2004.log` and `walk/01-u2404.log` each have one "loaded libwebkit2gtk" line (4.0.so.37 and 4.1.so.0). |
| LWV-02 | 41-01/03/04 | VERIFIED | `probeLinuxInAppWeb()` is awaited in `main()` and failures leave `linuxInAppWeb=false`. `launchWebSite` falls back to `launchUrl`. `/web` route and nav entry are both gated on `inAppWeb`. `checkoutHostKind` returns `external` on Linux without WebKit. Walks: `01-u2404-nowebkit.png`, `03-no-webkit.png`, `04-no-webkit.png`; shim and nowebkit logs have 0 "loaded" lines. |
| LWV-03 | 41-02 | VERIFIED | `grep` over `lib/`: `launchUrl(` only in `web_utils.dart`, `checkout_screen.dart` (fallback) and `order_drawer_footer.dart` (Banxa support). All other callers go through `launchWebSite`. `url_launcher` is imported only in those three files. |
| LWV-04 | 41-03 | VERIFIED | `WebViewScreen` routes Linux to `WebViewLinux`; `includeBackButton` is honoured (`web_view_linux.dart` L596-599, `WebPageCloseButton`). `WebPageCloseButton` has 4 widget tests. `walk/03-legal.png` shows Privacy Policy in-app with the close control. D-03 held: the router change is `if (inAppWeb)`, identical on Windows, macOS and mobile. |
| LWV-05 | 41-03 | VERIFIED | `nav_destinations.dart` uses `visible: inAppWeb` and the router uses `if (inAppWeb)`, with no `Platform.isLinux` left in either. `walk/03-web-tab.png` shows the Web tab. |
| LWV-06 | 41-04 | VERIFIED (keyed order and camera are manual) | `CheckoutWebViewLinux` uses `isBanxaReturn`, `allowsCheckoutNavigation` and `checkoutPermissionAllowed`. `_CheckoutFrame(clip: hostKind != linux)` removes the rounded clip on Linux only. The shared rule is used by the Windows, mobile and Linux hosts. Rule tests, `checkout_screen_test` and `status_text_color_invariant_test` pass (re-run by me: 98 passed). `walk/04-checkout.png` shows the real Banxa page in the same dialog. |
| LWV-07 | 41-02/04 | VERIFIED | `WebOverlayGate` wraps the view in `Offstage`, which keeps it loaded, and is driven by the root and shell popup observers (`ShellRoute(observers: [shellPopupRoutes])`). The checkout menu is gated by `_menuOpen`, Linux only. `web_overlay_gate_test` passes. `walk/02-drawer.png`, `02-selector.png` and `04-menu.png` show whole overlays, and the page returns without a reload. |
| LWV-08 | 41-02 | VERIFIED by walk | Native `event` hook in `flutter_view.cc` hands focus back (the plan's `button-press-event` never fired; deviation documented and fixed). `walk/02-focus.png` evidence: omnibox click after page focus sends keys to Flutter. No automated test is possible without a native view. |
| LWV-09 | 41-01 | VERIFIED (CI run pending) | `build.yml` adds `webkit2gtk3-devel` in the shared "Configure Linux host" dnf step (both Linux rows use `almalinux-8`). A new step, gated on `matrix.target == 'Linux'`, fails on a NEEDED webkit/soup/javascriptcore entry or an undefined `webkit_/soup_/jsc_` symbol in the plugin. `INSTALL.md` says "recommended, not required". The first linux_arm CI run is still open. |

All nine IDs from the four PLAN frontmatters (LWV-01..09) are mapped in REQUIREMENTS.md, with no orphans.

## Locked decisions

| Decision | Status | Evidence |
|----------|--------|----------|
| D-01 no UI-SPEC or restyle | Honoured | No new design; the close control reuses the omnibox fill. |
| D-02 same dialog, only the clip removed | Honoured | The only frame change is `clip`. |
| D-03 no change off Linux | Honoured | `checkout_webview_windows.dart` untouched. Mobile and Windows were changed only by the shared-rule refactor (see human item 5). |
| D-04 gate only for dialog, sheet or popup menu; toasts out | Honoured | Gate observes popup routes and the checkout menu. |
| D-05 system-browser fallback | Honoured | `launchWebSite` and `CheckoutExternal`. |
| D-06 vendored, import and patch as separate commits | Honoured | `10bf5f3a` (pristine import), `c95b2877` (runtime-load patch), `de7d1260` (focus fix). `pubspec.yaml` uses path deps, with no fork. |

## Automated checks I ran

- `flutter test test/web test/banxa/checkout_rules_test.dart test/banxa/checkout_screen_test.dart test/theme/status_text_color_invariant_test.dart`: 98 passed.
- Debt-marker scan (TBD, FIXME, XXX) over the new Dart files and the runtime loader: none.
- No CRLF in `lib/web` or `lib/banxa/checkout`. The working tree is clean, so walk-only hooks are not committed.
- I did not re-run the full suite, analyze, or the container builds and walks. Those rest on the SUMMARY claims (full suite +2566, analyze rc 0), backed by the committed PNGs I spot-checked (`03-legal.png`, `04-checkout.png`).

## Anti-patterns and notes (no blockers)

- INFO: the four `walk/*.log` files are gitignored, so only the PNGs are committed. The logs exist on disk only.
- INFO: `.planning/REQUIREMENTS.md` still shows the LWV-01..09 checkboxes and traceability rows as `[ ]` / Pending. Close them when the phase is closed (hand-edit; do not use `phase.complete`).
- INFO: `LinuxWebViewController` permission handling in `CheckoutWebViewLinux` has no unit test. This is accepted in the 41-04 summary, and the rule is covered.
- INFO: the Linux dialog has square bottom corners (accepted by the plan).

## Gaps Summary

No gaps. Everything automatable passes. The phase goal is met in code and in container walks on 20.04 (WebKitGTK 4.0), 24.04 (4.1) and no-WebKit. The five human items above are manual-only per 41-VALIDATION.md.
