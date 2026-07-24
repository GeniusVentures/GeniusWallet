---
phase: 18-web-tab-chrome-in-app-browser-address-bar-and-tab-strip-rede
plan: 03
subsystem: web-browser-chrome
tags: [web, browser, address-bar, omnibox, windows, re-skin]
requires: [18-01, 035-B]
provides: [windows-omnibox-toolbar]
affects: [lib/web/web_view_windows.dart]
tech-stack:
  added: []
  patterns: [always-mounted-TextField-with-focus-cover, sync-nav-state]
key-files:
  modified:
    - lib/web/web_view_windows.dart
decisions: [D-01, D-02, D-03, D-09]
status: complete
---

# Phase 18 Plan 03: Windows omnibox re-skin Summary

Ported the 035-B omnibox re-skin to the Windows path so both platforms read as one design.
Windows is secondary: the omnibox is the deliverable; the always-visible tab strip is an
explicit stretch goal NOT attempted (the Windows "tabs" are a history list, `_showTabSwitcher`).
Chrome only — the WalletConnect clipboard poller, `_initializeWebView`, the url-stream history
wiring, and dispose logic are untouched (D-09).

## What shipped

**Task 1 — Windows 035-B omnibox (`web_view_windows.dart`)**
- Rewrote `_buildSearchBar` into `_buildSearchBar` (field + outside `⋯`) plus
  `_buildOmniboxField` / `_buildOmniboxCenter`, reusing the shared pure helpers
  (`webDisplayHost` / `webIsSecure` from 18-01). A ponytail comment records WHY the omnibox
  widget is deliberately NOT shared with mobile (sync vs async controller APIs diverge).
- Field: `surfaceSunken` fill, `radiusBase` corner, `borderSubtle` rest border; on focus →
  2px `brandPrimary` border + `brandPrimarySubtle` glow focus ring (D-02).
- Back/forward use the SYNCHRONOUS `canGoBack()` / `canGoForward()` bools (no FutureBuilder,
  unlike mobile): `brandPrimaryOnSurface` + tappable (`goBack`/`goForward`) when true,
  `textPrimary38` + inert otherwise.
- Center: always-mounted TextField (keeps `_urlFocusNode` attached for the rest-tap
  `requestFocus()`); at rest an opaque cover paints favicon + (https-only) lock + host over it.
  On focus the field seeds the full URL and select-alls.
- Refresh ghost button → `_controller.reload` (already wired).
- Outside `⋯` (`Icons.more_horiz`) replaces the old `Icons.tab` and keeps opening
  `_showTabSwitcher` (the existing history dialog) — Windows' only tab affordance, unchanged.
- `_buildIconButton` extended with optional `color` + `size` params so it is reused, retinted
  per state, for back/forward/refresh/menu (per the plan's "reuse retinted" instruction).
- Added `_getFaviconUrl` (mirrors mobile, `google.com/s2/favicons`, `Uri.tryParse` so a
  hostless URL degrades instead of throwing) and a `_currentUrl` getter (reads
  `openTabs[currentTabIndex]`, the real streamed URL, independent of the editable field text).
- Added a `FocusNode` (`_urlFocusNode`) with an `_onUrlFocusChange` listener; disposed and
  its listener removed in `_disposeWebViewResources` alongside the existing `_urlController`.
- Submit unchanged: `onSubmitted → _loadUrl()` (then unfocus).

## Verification
- `flutter analyze lib/web/web_view_windows.dart` → **No issues found.**
- No macOS/iOS runtime walk is possible for the Windows path on this dev machine; verification
  is analyze-clean + code review against 18-01's omnibox. Windows runtime confirmation is
  deferred to whoever next runs the Windows build (noted in the plan).

## Deviations from Plan
None affecting design. One hygiene note:
1. **[Rule 2] `_urlFocusNode` disposal** — added to the existing `_disposeWebViewResources`
   teardown so the new FocusNode is not leaked. Engine wiring untouched.

## Token deviations (findings)
None. Every colour/space/radius is a `GeniusWalletColors` / `GeniusWalletConsts` token. The
`_buildIconButton` hover/splash retain the existing `deepBlueCardColor`-with-alpha values.

## Deferred / light-mode findings
- Windows runtime (nav states, focus ring, favicon/lock/host, `⋯` → history dialog) is
  deferred to a Windows build; not runnable here.

## Self-Check: PASSED
- lib/web/web_view_windows.dart — omnibox present, analyze CLEAN (No issues found)
- Shared helpers (18-01) reused; `_showTabSwitcher` / clipboard poller / engine wiring untouched
- Commits: N/A — session forbidden from committing (CLAUDE.md + task); changes left in the
  working tree uncommitted.
