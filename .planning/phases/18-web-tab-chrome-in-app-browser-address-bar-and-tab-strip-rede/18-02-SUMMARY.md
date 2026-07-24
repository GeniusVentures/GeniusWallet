---
phase: 18-web-tab-chrome-in-app-browser-address-bar-and-tab-strip-rede
plan: 02
subsystem: web-browser-chrome
tags: [web, browser, tab-strip, macos, ios, re-skin, deletion]
requires: [18-01, 036-A, 037-B]
provides: [mobile-tab-strip]
affects: [lib/web/web_view_mobile.dart, pubspec.yaml]
tech-stack:
  added: []
  removed: [screenshot ^3.0.0]
  patterns: [navbar-active-mark-reuse, appearance-proxy-gradient-degrade]
key-files:
  modified:
    - lib/web/web_view_mobile.dart
    - pubspec.yaml
    - pubspec.lock
decisions: [D-04, D-05, D-06, D-07, D-08]
status: complete
---

# Phase 18 Plan 02: macOS/iOS tab strip + manager/screenshot removal Summary

Replaced the counter-button + full-screen `_buildTabManager` with the 036-A always-visible
horizontal tab strip, and deleted the dead full-screen manager, the upside-down-thumbnail
bug, and the entire `Screenshot`/`ScreenshotController` machinery plus its unused dependency.
Net code deletion; every tab mechanic preserved verbatim (D-09).

## What shipped

**Task 1 — 036-A tab strip**
- Added `_buildTabStrip()` as the FIRST child of the build Column, above the omnibox
  → `[_buildTabStrip(), _buildSearchBar(), Expanded(webview)]` (D-04/D-08, 46px band).
- Strip = horizontal `ListView.separated` of tab chips + a trailing `+`.
- Each chip (`_buildTabChip`): favicon (`_getFaviconUrl` + `Icons.language` errorBuilder) +
  title from `FutureBuilder<String?>(getTitle())` with `_tabUrls[i]` fallback ("Loading..."
  while waiting), maxLines 1 ellipsis, + a close `×`.
- Active chip (D-05): `surfaceElevated` fill + a real 2px brandCta gradient underline drawn
  as a bottom bar; inactive = transparent fill, `borderSubtle` outline, `textPrimary60` label.
- `+` → `_addNewTab("https://www.duckduckgo.com")`; tap → `_switchTab(i)`; `×` → `_closeTab(i)`.
  All three verbatim.
- Last-tab-locked (D-06): the `×` is rendered only when `webTabCanClose(_controllers.length)`
  (the shared 18-01 helper) is true; a lone tab shows no close affordance.
- `_activeUnderlineGradient()`: dark keeps `GeniusWalletGradient.brandCta`; light degrades to
  flat `brandPrimaryOnSurface` (#0A6885, 6.30:1 on white) because brandCta's blue stop is only
  2.56:1 and fails WCAG 1.4.11's 3:1. Keyed off `surfaceMenu` luminance as the appearance
  proxy — the exact routing `transactions_slim_view._activeLabelShader` uses — with NO new
  `GWColors`/`Theme.of(context)` import (per the plan-checker note).

**Task 2 — delete manager + Screenshot machinery**
- Deleted: `_buildTabManager()` (incl. `Matrix4.rotationX(pi)` upside-down thumbnails),
  `_showTabManager` field + its `Positioned.fill` overlay branch (build Column now has no
  Stack), `captureScreenshot()` + its `onPageFinished` call, the `_tabImages` list + every
  write, `screenshotController`, the `Screenshot(...)` wrapper in `_buildWebView` (now returns
  `WebViewWidget` directly), the `_showTabManager = false` line in `_switchTab`, and the
  `screenshot` + `dart:math` imports.
- Removed `screenshot: ^3.0.0` from pubspec; `flutter pub get` dropped it from the lockfile.
- Grep confirmed (pre + post) that `web_view_mobile.dart` was the SOLE consumer.

## Verification
- `grep -n "screenshot\|_tabImages\|Matrix4\|_showTabManager\|captureScreenshot\|dart:math"
  lib/web/web_view_mobile.dart` → **no matches** (CLEAN).
- `flutter pub get` → "screenshot 3.0.0 no longer depended on; Changed 1 dependency."
- `flutter analyze lib/web/web_view_mobile.dart` → 8 **pre-existing** `avoid_print` infos in the
  untouched navigation-delegate wiring (D-09); one fewer than before (the "Capturing
  screenshot" print is gone). **Zero** new issues from the tab strip.
- 18-01 helper test unchanged and still green.

## Deviations from Plan
None. Design and deletions implemented as specified.

## Token deviations (findings)
None. Strip band reuses `deepBlueCardColor` (chrome-bar token); chip fill/label/border/underline
are all `GeniusWalletColors`/`GeniusWalletConsts`/`GeniusWalletGradient` tokens.

## Deferred / light-mode findings
- Light-mode 3:1 of the active underline was NOT runtime-verified (dark-first). The gradient
  degradation to `brandPrimaryOnSurface` (6.30:1 on white) is the shipped, AA-cleared routing
  from the transactions rail, so it is expected to pass; confirm in the app-wide light pass.

## Human walk (macOS dark)
Tab strip is always visible above the omnibox. `+` opens DuckDuckGo tabs; click between them —
active chip wears `surfaceElevated` + a 2px brand underline. Close tabs; the final tab has no
`×`. No full-screen manager, no upside-down thumbnails. Real browsing (navigate, search
fallback, favicon + title populate) unregressed.

## Self-Check: PASSED
- lib/web/web_view_mobile.dart — tab strip present, manager/screenshot gone, grep CLEAN
- pubspec.yaml / pubspec.lock — screenshot removed
- Commits: N/A — session forbidden from committing (CLAUDE.md + task); changes left in the
  working tree uncommitted.
