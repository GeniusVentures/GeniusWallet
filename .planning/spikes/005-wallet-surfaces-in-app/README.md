---
spike: 005
idea: linux-inapp-webview
name: wallet-surfaces-in-app
type: standard
validates: "Given the wallet's Linux build with the vendored, patched webview_all_linux, when the user opens a Crypto News article, the in-app Web page and the Banxa sandbox checkout, then each renders inside the app, a missing WebKitGTK still falls back to the system browser, and the visual and input breakages are recorded"
verdict: PARTIAL
related: [003, 004, 006, 007]
tags: [linux, webview, webkitgtk, webview_all, banxa, checkout, crypto-news, browser, focus, overlays, almalinux8]
---

# Spike 005: Wallet surfaces in-app

## What This Validates

**Given** the real wallet (develop `8cf5ddc7`) built for Linux x86_64 in the AlmaLinux 8 CI image,
with the 007 plugin vendored under `third_party/webview_all/`, **when** the user opens (1) a Crypto
News article, (2) the Web page, (3) Banxa sandbox checkout, **then** each renders inside the app;
with WebKitGTK missing each falls back to the system browser. Breakages are listed below.

## Research

How the plugin plugs in, read in `third_party/webview_all/`:

| Option | Cost | Verdict |
|---|---|---|
| Depend on upstream `webview_all` | registers its own Android/iOS/macOS/Windows/Web implementations next to `webview_flutter` and `webview_windows` | rejected |
| Adapter from `webview_flutter_platform_interface` to `LinuxWebViewPlatform` | many classes | rejected |
| Vendor `webview_all` (pure-Dart, plugin map stripped), `webview_all_linux`, `webview_platform_interface`; Linux files import `webview_all` | 3 path deps, nothing added to other platforms | chosen |

`webview_all`'s `WebViewController`, `NavigationDelegate`, `WebViewWidget` and permission request
match `webview_flutter`, so the Linux variants are copies of the mobile ones with one import changed.

Wiring (see `wallet-changes.diff`):
- `main()` awaits `probeLinuxInAppWeb()` (calls `LinuxWebViewPlatform.isAvailable()`) before the
  router and nav lists are built; result is the global `linuxInAppWeb`.
- `launchWebSite` (News, legal links, explorer links) pushes `/web` when it is true, else `launchUrl`.
- `/web` route and the Web nav item exist on Linux only when it is true.
- `checkoutHostKind('linux', linuxWebView: true)` -> new `CheckoutHostKind.linux` -> `CheckoutWebViewLinux`
  (same allow-list, return-URL match and camera/mic-only-on-Banxa permission policy as mobile).
- `_CheckoutFrame` drops its rounded clip on Linux (see problem 1).
- Spike-only: `GW_SPIKE_CHECKOUT_URL` env replays a checkout URL from the Buy screen, because a
  local build has no Banxa key.

## How to Run

All from WSL Ubuntu-20.04 (Docker Desktop). Scripts are copies of the scratchpad ones; fix the paths.

```
bash sync.sh        # worktree + main repo's submodules -> /home/braian/gw005/GeniusWallet (ext4)
bash build.sh       # flutter build linux --release in gw-spike006 (EL8 CI image + webkit2gtk3-devel)
bash run.sh         # fresh profile, unlocked throwaway keyring, WEBKIT_DISABLE_COMPOSITING_MODE=1
KEEP=1 bash run.sh GW_SPIKE_CHECKOUT_URL=<sandbox checkout url>   # keep wallet, replay checkout
KEEP=1 NOWEBKIT=1 bash run.sh   # LD_PRELOAD nowebkit.c: every dlopen of libwebkit2gtk fails
bash lx.sh click X Y | type TEXT | key KEY | shot NAME
```

Build notes: CC/CXX/ASM must be clang in the env, not only in `CMAKE_ARGUMENTS`
(`linux/CMakeLists.txt` applies those after `project()`, so sentry-native's libunwind `.S` files go
to `/usr/bin/cc` = gcc and fail on `-gline-tables-only`). Native deps come from
`-DGENIUS_DEPENDENCY_BRANCH=develop`, no token needed. Clean release build 52-87 s once deps are
cached (2.8 GB under `/home/braian/gw005`). Bundle 202 MB; plugin `.so` 160 KB with line tables.
`readelf -d genius_wallet` has no WebKit `NEEDED`.

## What to Expect

stderr at launch: `webview_all_linux: loaded libwebkit2gtk-4.0.so.37 (WebKitGTK 2.38.6, libsoup2,
run_javascript)`. Web tab in the nav. A News card opens the article under the app chrome (01). With
`NOWEBKIT=1`: `WebKitGTK unavailable: ...` once, no Web tab (09), News and checkout go to the
browser (10).

## Investigation Trail

1. First build failed in Dart: rsync `--exclude banxa` also dropped `lib/banxa`. Anchored the excludes.
2. Then `cc: error: unrecognized debug output level 'line-tables-only'`: see build notes.
3. Onboarding Legal -> Privacy Policy already uses `launchWebSite`, so it opened in-app (00) - with
   the full app nav over a wallet-less app and no way back (no back button rendered). Same code path
   as Windows/macOS today; not Linux-specific.
4. News article renders, scrolls, links work (01). Typing into a web form works (02).
5. **Keyboard focus does not come back to Flutter.** After the page has focus, one click on the
   omnibox focuses it in Flutter but keystrokes still go to the page (03: "wikipedia.org" lands in
   cointelegraph's search box; 04: Enter submits the page's search). After a click on another
   Flutter area first, text reaches the omnibox but Return still goes to the page (05 then 04-like
   result). GTK focus stays on the `WebKitWebView`.
6. Leaving the Web tab (News nav) removes the view cleanly; no ghost frame seen. Coming back
   resets the browser to the home tab (state is per-route, same as other platforms).
7. Web page itself renders gnus.ai (06). The Accounts drawer is cut where it overlaps the page,
   and the drawer's scrim does not dim the page (07). The swap FAB is hidden on the Web tab.
8. Checkout: the desktop dialog is a `Material` with `Clip.antiAlias` + rounded shape, so the plugin
   hides the view; the dialog is empty (08). `Clip.none` on Linux fixes it: Banxa's transit page
   renders in the dialog under the sandbox badge (11). The overflow menu is cut by the page (12).
9. The Banxa email screen was **not** reached. The only sandbox order URL available was made at
   10:41 by a keyed CI build; it stops after "Almost ready..." with a blank page. Control: the same
   URL in a plain PyGObject WebKit window on 2.38 **and** on WebKitGTK 2.52 (Ubuntu 24.04 container,
   `control41.sh`) ends equally blank, and so does `gnus.banxa-sandbox.com/` with no order. So it is
   the stale order, not the embed. A fresh order needs the keyed CI build and its "Before your first
   buy" dialog, which accepts Banxa's Terms; I stopped there.
10. No WebKit (`nowebkit.c` preload): app starts, Web tab hidden (09), article captured by a stub
    `x-scheme-handler/https` handler (cointelegraph URL), checkout shows "Finish paying in your
    browser" and hands the URL to the browser (10). A first try with an `unshare -rm` bind mount
    left the window black (uid 0 in the namespace); not pursued.

## UX problems found

| # | Problem | Where | Suggested fix |
|---|---|---|---|
| 1 | Rounded `Material` clip hides the whole view | checkout dialog (08) | No clip on Linux (done here), or a square web area inside the rounded card; a per-surface rule "no ClipRRect/rounded Material clip above a web view" |
| 2 | Keyboard focus stays in WebKit after clicking Flutter | omnibox, any Flutter field next to a page (03-05) | Plugin: on a button press on the FlView outside the hole, `gtk_widget_grab_focus(fl_view)`; Dart: on Flutter focus gain call a `releaseFocus` method. Must ship with this, or the omnibox is unusable |
| 3 | Flutter overlays are cut by the page; scrims do not dim it | Accounts drawer (07), checkout menu (12), swap FAB, toasts | Hide or `setFrame(visible:false)` the view while a route/overlay is above it (a `RouteAware`/overlay-count hook), or open drawers to the side the page does not cover. Toasts: place above the page area or pause showing them on web routes |
| 4 | Loading indicator under the page is never visible | `CheckoutWebViewLinux`, browser | Keep the view hidden (`visible:false`) until first `onPageFinished`, then show it |
| 5 | Opening an article switches the nav highlight to Web; back to News loses the article | News -> Web | Push the article as a full-screen route with a back button (honour `includeBackButton`) instead of the shell `/web` tab |
| 6 | Legal links in onboarding land on the full app shell with no way back | Legal screen (00) | Same as 5; a standalone route outside the shell. Affects all platforms |
| 7 | Square bottom corners on the checkout dialog | checkout (11) | Cosmetic; accept, or inset the page by the radius |
| 8 | Fallback does not say why | no-WebKit checkout (10) | One line: "Install WebKitGTK to pay inside GeniusWallet" |
| 9 | Tab title goes stale after in-page navigation | browser tab chip | Re-read title on `onUrlChange` too |

## Results

**PARTIAL.**
- News article: **in-app, works.** Scroll, links, form typing OK. Breaks on focus (2) and overlays (3).
- Web page: **in-app, works**, same two problems; the omnibox is not reliably typable (2).
- Banxa checkout: **embeds after one fix** (rounded clip, 1). Banxa's page renders under the sandbox
  badge; the email screen was not reached because the replayed order was stale (control-proved).
- WebKit missing: **falls back** for all three; app starts, Web tab hidden.

Static checks on the changed files: `dart format` (0 changed), `flutter analyze` on the touched
paths "No issues found", `checkout_rules_test.dart` 48/48, `tool/check_brace_style.sh` rc 0. Full
`flutter test` and full `flutter analyze` were not run.

What the real phase must do: plugin focus hand-back (2); an overlay/route hook that hides the view
(3, 4); no rounded clip above any web view; article and legal pages as a back-able route outside
the shell; single source for the checkout permission rule (it takes `webview_flutter` types today,
the Linux copy duplicates it - marked `ponytail:`); deduplicate `web_view_linux.dart` (a 760-line
copy of the mobile browser) by passing the controller type in; drop the `GW_SPIKE_CHECKOUT_URL`
hook; add `webkit2gtk3-devel` to the CI image; walk a fresh sandbox order to the email screen with
the keyed CI build; probe at startup costs the WebKit dlopen at launch (measure, or probe lazily).
