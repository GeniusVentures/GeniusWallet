---
phase: 18-web-tab-chrome-in-app-browser-address-bar-and-tab-strip-rede
plan: 01
subsystem: web-browser-chrome
tags: [web, browser, address-bar, omnibox, macos, ios, re-skin]
requires: [035-B, 037-B]
provides: [web_chrome_helpers, mobile-omnibox-toolbar]
affects: [lib/web/web_view_mobile.dart]
tech-stack:
  added: []
  patterns: [always-mounted-TextField-with-focus-cover, FutureBuilder-nav-state]
key-files:
  created:
    - lib/web/web_chrome_helpers.dart
    - test/web/web_chrome_helpers_test.dart
  modified:
    - lib/web/web_view_mobile.dart
decisions: [D-01, D-02, D-03, D-08]
status: complete
---

# Phase 18 Plan 01: macOS/iOS omnibox address bar Summary

Re-skinned the macOS/iOS in-app browser address bar into the 035-B unified omnibox
toolbar: back/forward nested into the field's left edge, favicon + https lock + host in
the middle (editable full URL on focus), refresh at the right edge, and a `⋯` placeholder
outside the field — killing the "second bar under the bar" reading. No navigation mechanic
changed; the browser engine wiring (WebViewController, navigation delegates, Uniswap JS,
banner MutationObserver) is untouched (D-09).

## What shipped

**Task 1 — shared pure helpers + test**
- `lib/web/web_chrome_helpers.dart`: three top-level pure functions shared by both platform
  omniboxes (rung-4 reuse, marked with a ponytail comment):
  - `webDisplayHost(url)` — host for the rest display; returns raw trimmed input for
    hostless/unparseable input (about:blank, mid-typing), never throws. Recovers the host
    from a URL carrying an un-encoded query space by retrying on the pre-query slice.
  - `webIsSecure(url)` — true only for `https` scheme (drives the lock glyph).
  - `webTabCanClose(count)` — the last-tab-locked rule, extracted so it is testable.
- `test/web/web_chrome_helpers_test.dart`: 10 asserts over every behavior-block case.
  **`flutter test test/web/web_chrome_helpers_test.dart` → +10 All tests passed.**

**Task 2 — 035-B omnibox in `web_view_mobile.dart`**
- Replaced `_buildSearchBar` with `_buildSearchBar` (row = field + outside `⋯`) plus
  `_buildOmniboxField` / `_buildOmniboxCenter` / `_omniboxNavButton` / `_omniboxGhostButton`.
- Field: `surfaceSunken` fill, `radiusBase` corner, `borderSubtle` rest border. On focus →
  2px `brandPrimary` border + `brandPrimarySubtle` glow (BoxShadow) focus ring (D-02).
- Back/forward: `FutureBuilder<bool>` on `canGoBack()` / `canGoForward()`; `brandPrimaryOnSurface`
  + tappable when enabled, `textPrimary38` + inert otherwise. Wired to `_goBack` / `_goForward`
  (the previously-unused `_goForward` is now consumed).
- Center: TextField is ALWAYS mounted (keeps `_urlFocusNode` attached so the rest-display tap
  can `requestFocus()`); at rest an opaque `surfaceSunken` cover paints favicon +
  (https-only) lock + host over it. On focus the field seeds the full URL and select-alls.
- Refresh ghost button → `_reload()` wrapper calling `_controllers[i].reload()`.
- Submit unchanged: `onSubmitted → _loadUrl()` (then unfocus). Removed the old `1` tab-counter
  button and its `_showTabManager = true` setter (tab UI moves to the strip in 18-02;
  `_showTabManager`/`_buildTabManager` left intact for 18-02 to delete).
- Added a `dispose()` (the state had none) that disposes `_urlController` + `_urlFocusNode`
  and removes the focus listener — fixes a pre-existing controller leak (Rule 2 hygiene).

## Verification
- `flutter test test/web/web_chrome_helpers_test.dart` → 10/10 pass.
- `flutter analyze lib/web/web_view_mobile.dart lib/web/web_chrome_helpers.dart test/web/web_chrome_helpers_test.dart`
  → only 9 **pre-existing** `avoid_print` infos inside the untouched navigation-delegate
  engine wiring (D-09). Zero new issues from the omnibox or helpers.

## Deviations from Plan
None affecting design. Two in-scope hygiene notes:
1. **[Rule 2] Added `dispose()`** — the mobile State had no `dispose`, leaking `_urlController`
   (and now `_urlFocusNode`). Added disposal; browser wiring untouched.
2. **Always-mounted TextField + focus cover** — the plan's "swap static row ↔ TextField" is
   implemented as an always-present TextField under an opaque cover, because a `FocusNode`
   only accepts `requestFocus()` while attached to a live field. Same UX, focus works.

## Token deviations (findings)
None. Every colour/space/radius is a `GeniusWalletColors` / `GeniusWalletConsts` token. The
omnibox band background reuses `deepBlueCardColor` (the existing chrome-bar token) to sit
flush under the navbar.

## Deferred / light-mode findings
- Light AA of the rest-display was not runtime-verified (dark-first; no light walk done).
  `textPrimary`/`statusSuccess`/`brandPrimary` on `surfaceSunken` are the app's standard
  tokens; any light-only shortfall defers to the app-wide light pass per CONTEXT.

## Human walk (macOS dark)
Open Web tab: address bar is ONE omnibox field. Navigate a few pages — Back lights brand and
works, Forward is muted/inert at history end, refresh reloads. Click the field: brand ring +
full editable URL; blur collapses to favicon + lock + host. Type a non-URL, submit: Google
search fallback. `⋯` is a visible no-op placeholder (by design, D-09).

## Self-Check: PASSED
- lib/web/web_chrome_helpers.dart — FOUND
- test/web/web_chrome_helpers_test.dart — FOUND (10/10 pass)
- lib/web/web_view_mobile.dart — omnibox present, analyze clean of new issues
- Commits: N/A — this session is forbidden from committing (CLAUDE.md + task); changes left
  uncommitted in the working tree.
