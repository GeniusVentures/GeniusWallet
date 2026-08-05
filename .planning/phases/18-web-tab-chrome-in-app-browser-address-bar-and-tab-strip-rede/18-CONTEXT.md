# Phase 18: Web tab chrome — in-app browser address bar + tab strip - Context

**Gathered:** 2026-07-24
**Status:** Ready for planning

<domain>
## Phase Boundary

The Web tab (`Web` in the top nav) renders an in-app browser: `WebViewMobile` on macOS/iOS,
`WebViewWindows` on Windows. Its chrome is the last un-redesigned surface in the app — two crude
pieces bolted under the redesigned navbar:

1. **The address bar** (`_buildSearchBar`, `web_view_mobile.dart:289` / `web_view_windows.dart:230`) —
   a full-width unstyled strip: a bare back arrow, an `Enter URL…` `TextField` with no favicon/lock/
   controls, and a bordered `1` button that just counts open tabs. It reads as an older, different app
   than the chrome above it.
2. **The tab manager** (`_buildTabManager`, `web_view_mobile.dart:374`) — tapping the counter opens a
   *full-screen* overlay: a vertical `ListView` of screenshot thumbnails rendered **upside-down**
   (`Matrix4.rotationX(pi)`, `:396`), with `+` bottom-left and `×` bottom-right.

This phase re-skins that chrome to the sketched design. It is a **re-skin, not a re-architecture**:
every real browser behavior stays intact.

**Locked by roadmap + milestone rules — NOT open for discussion:**
- Re-skin, never restructure the browser engine wiring. `WebViewController` (mobile) / `WebviewController`
  (windows) creation, navigation delegates, the Uniswap dark-mode/localStorage injection, and the
  banner-hiding `MutationObserver` JS all stay exactly as they are.
- Design source of truth = **sketch 037-B** (`.planning/sketches/037-web-chrome-combined/`), the
  consolidated winner of **035-B** (address bar) + **036-A** (tab strip). The sketch READMEs stand in
  for a UI-SPEC — no separate UI-SPEC.md is authored for this phase.
- Reuse the shipped design tokens (`GeniusWalletColors`, `genius_wallet_consts` spacing/radii, Inter
  typography). Every colour/space/radius comes from an existing token; a deviation is a recorded finding.
- Dark-first (per project rule); light mode must hold AA contrast but light-only bugs may defer to the
  app-wide light pass.

## Platform scope
- **Primary: macOS** (Jakub's dev target) → `web_view_mobile.dart` (the `!Platform.isWindows` path).
  This is where the walk happens and where the design must land first.
- **Secondary: Windows** → `web_view_windows.dart`. Mirror the same chrome, but its tab model is a
  history list (`_showTabSwitcher` shows history, not real tabs) — porting the full tab strip there is
  a stretch goal, not a blocker. At minimum the omnibox re-skin (035-B) ports cleanly.
</domain>

<decisions>
## Implementation Decisions (locked by sketches 035/036/037, chosen 2026-07-24)

### Address bar → 035-B "Scalony toolbar" (unified omnibox)
- **D-01:** Replace `_buildSearchBar` with a single omnibox toolbar row (~54px): back / forward
  controls nested into the field's LEFT edge, then favicon + secure lock + host text, then refresh at
  the field's RIGHT edge; a `⋯` overflow menu sits outside the field on the right. One cohesive element,
  not "separate controls + separate field". This kills the "second bar under the bar" reading that was
  the core complaint.
- **D-02:** Control states trace to real methods: Back enabled/brand when `canGoBack()`, Forward
  disabled when `!canGoForward()`, refresh calls `reload`. On focus the field shows a `brandPrimary`
  focus ring (2–3px, `brandPrimarySubtle` glow). The field is the `_urlController` `TextField`; submit
  still routes through `_loadUrl` (URL-vs-search: non-URL input → `google.com/search?q=`).
- **D-03:** Field shows favicon (`_getFaviconUrl` → `google.com/s2/favicons`) + a lock glyph for https.
  Resting state shows the host; editing shows the full editable URL.

### Tabs → 036-A "Stały pasek kart" (always-visible horizontal strip)
- **D-04:** Replace the counter-button → full-screen `_buildTabManager` with an always-visible
  horizontal tab strip sitting BETWEEN the navbar and the omnibox toolbar. Each tab = favicon + title
  (`_controllers[i].getTitle()` with URL fallback) + `×` close. A `+` at the strip's end adds a tab.
- **D-05:** Active tab mark = the navbar's active-tab language reused: `surfaceElevated` fill + a 2px
  `brandCta` gradient underline (consistency with sketch 022's rail decision — do NOT invent a new
  active language). Inactive tabs are muted, hover = lift/`borderSubtle` fill.
- **D-06:** Behaviors preserved verbatim: `_addNewTab("https://www.duckduckgo.com")` for `+`,
  `_switchTab(i)` on tab click, `_closeTab(i)` on `×`, and the **last-tab-locked** rule
  (`if (_controllers.length == 1) return;` — the final tab cannot be closed; the `×` should read as
  disabled/absent on a lone tab).
- **D-07:** The full-screen `_buildTabManager` overlay and its upside-down-thumbnail bug
  (`Matrix4.rotationX(pi)`) are **removed**, not fixed — 036-A has no thumbnails. (Sketch 036-B, the
  redesigned overlay grid, is the fallback if an overflow view is ever wanted for many tabs; out of
  scope now.) The `Screenshot`/`ScreenshotController` machinery that only fed those thumbnails can go
  with it — verify nothing else depends on it before deleting.

### Chrome geometry
- **D-08:** Assembled chrome ≈ 178px (navbar 62 + tab strip 46 + omnibox 54) — the sketched three-band
  layout. This was measured against variant A (~174px); the pion cost is not a differentiator. No
  attempt to merge strip+omnibox into one row (that was an explicitly-not-taken synthesis).

### Scope fence
- **D-09:** OUT of scope: the WalletConnect clipboard-pairing poller (`web_view_windows.dart`), the
  Uniswap theme-injection JS, favicon-service choice, history/bookmarks features, and any new browser
  capability. This phase touches **chrome only**.
</decisions>

<success_criteria>
## What "done" looks like
- The Web tab's address bar reads as one omnibox toolbar (035-B), styled from GeniusWallet tokens,
  with working back/forward/refresh states and a brand focus ring on the URL field.
- Tabs are an always-visible horizontal strip (036-A) with favicon + title + close and a `+` to add;
  active tab wears the navbar's brand-underline mark.
- Every preserved behavior still works: navigate, search-fallback, add tab (DuckDuckGo), switch tab,
  close tab, last-tab-locked, favicon + title population.
- The old full-screen tab manager + upside-down thumbnails are gone; no dead `Screenshot` code left.
- `flutter analyze` clean; a human walk on macOS (dark; light AA-checked) confirms the redesign and
  no regression in real browsing.
- Windows path at minimum wears the omnibox re-skin (full tab strip there is a stretch goal).
</success_criteria>

<canonical_refs>
- Design: `.planning/sketches/037-web-chrome-combined/` (README + index.html); `035-web-address-bar/`,
  `036-web-tab-strip/` for per-part rationale.
- Code: `lib/web/web_view_mobile.dart` (primary), `lib/web/web_view_windows.dart` (secondary),
  `lib/web/web_view_screen.dart` (platform switch).
- Tokens: `lib/theme/genius_wallet_colors.dart`, `genius_wallet_consts.dart`, Inter typography.
- Active-mark precedent: sketch 022 (`rail-active-state`, navbar underline copied outright).
</canonical_refs>
