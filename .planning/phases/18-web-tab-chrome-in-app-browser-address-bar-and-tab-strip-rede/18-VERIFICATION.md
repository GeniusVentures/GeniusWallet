---
phase: 18-web-tab-chrome-in-app-browser-address-bar-and-tab-strip-rede
verified: 2026-07-25T00:00:00Z
status: gaps_found
score: 10/11 must-haves verified
behavior_unverified: 0
overrides_applied: 0
gaps:
  - truth: "The last remaining tab cannot be closed (its x reads disabled/absent) — last-tab-locked rule"
    status: failed
    reason: >
      A follow-up polish commit (5c473d8, merged via PR #214, AFTER the 18-01/02/03 plans/summaries
      were written) rewrote _closeTab's last-tab behavior and the tab-chip close affordance.
      _closeTab no longer locks/no-ops on the final tab — it now calls _addNewTab("duckduckgo.com")
      and REMOVES the old one, i.e. the last tab CAN be closed (it is silently replaced). The close
      `x` is now shown on hover for EVERY chip, including a lone tab, rather than reading
      disabled/absent as D-06 and the roadmap's "preserve real mechanics" list require. The
      `webTabCanClose()` helper built in 18-01 specifically for this rule (tested 2/2 in
      test/web/web_chrome_helpers_test.dart) is never called from lib/ — it is dead/orphaned in
      production code. The 18-02-PLAN.md key_link "x close enable state -> webTabCanClose(...)" does
      not hold in the shipped code.
    artifacts:
      - path: "lib/web/web_view_mobile.dart"
        issue: "_closeTab (around line 301) resets the last tab instead of locking it; _buildTabChip's close-x (hover-gated) has no webTabCanClose/tab-count guard at all"
      - path: "lib/web/web_chrome_helpers.dart"
        issue: "webTabCanClose(int) is defined and unit-tested but has zero call sites in lib/"
    missing:
      - "Either restore the last-tab-locked mechanic (call webTabCanClose(_controllers.length) to gate the close-x, disabled/absent on a lone tab, no-op _closeTab on the last tab) to match the roadmap/plan contract, OR record an explicit override in this file accepting the reset-on-close UX as the new intended behavior (it is arguably reasonable UX, but it is an undocumented deviation from a decision the phase context marked 'locked... NOT open for discussion')."
---

# Phase 18: Web tab chrome — in-app browser address bar + tab strip redesign Verification Report

**Phase Goal:** Re-skin the in-app browser (Web tab) chrome to sketch 037-B — the consolidated winner
of 035-B (unified omnibox toolbar) + 036-A (always-visible horizontal tab strip).
**Verified:** 2026-07-25 (Windows verification host; macOS-specific runtime claims routed to human
verification per constraints)
**Status:** gaps_found
**Re-verification:** No — initial verification

## Important context discovered during verification

1. **ROADMAP.md drift.** `.planning/ROADMAP.md` still shows `[ ]` for all three of this phase's plans
   (18-01/02/03), but all three `*-SUMMARY.md` files exist, `status: complete` in their frontmatter,
   and the work is merged into `ui-redesign-port` (commit `cb78f43`, PR #214, merge commit `9dd48b9`).
   Verification below judges the actual code on `ui-redesign-port`, not the roadmap checkboxes.
2. **A follow-up commit exists on top of the three plans.** `HANDOFF-session-260725-web-omnibox-markets.md`
   documents a second executor session (branch `redesign/web-omnibox-markets-260725`, commit `5c473d8`,
   also merged in PR #214) that further polished `lib/web/web_view_mobile.dart` — real nav-state sync
   (`onUrlChange`/`onPageStarted` wiring), removal of the `⋯` no-op menu and far-left `×`, a hover-only
   tab-strip redesign, a title-caching fix, and a URL-bar white-dots fix. **This session also changed
   the last-tab-locked mechanic** (see gap above) — that change is not documented in any plan or
   SUMMARY and is the one BLOCKER finding in this report.
3. **Known, accepted open item (not re-litigated here):** the omnibox URL field cannot overwrite a
   text selection on macOS (WKWebView ↔ Flutter text-input conflict, engine-level, does not reproduce
   on Windows/WebView2). Captured at
   `.planning/todos/pending/2026-07-25-web-tab-url-bar-cannot-overwrite-a-selection-on-macos.md`.
   Recorded here as a known limitation and a human-verification item, per instruction — not scored as
   a gap.
4. **Requirements traceability:** Phase 18 has no formal REQUIREMENTS.md record — the plans list
   `requirements: [D-01, D-02, D-03, ...]`, which are `18-CONTEXT.md` design decisions, not
   REQUIREMENTS.md IDs. **Requirement coverage is N/A for this phase** (explicitly, not a gap — the
   phase itself says "Requirements: TBD (retrofit from sketch READMEs if a formal record is wanted)").

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Web tab address bar reads as ONE omnibox toolbar (~54px) — not a control-row plus separate field | ✓ VERIFIED | `_buildSearchBar`→`_buildOmniboxField` in `web_view_mobile.dart:549-595`: single `Container` (surfaceSunken fill, radiusBase) housing back/forward, favicon+lock+host / editable field, refresh. Same shape in `web_view_windows.dart:268-338`. |
| 2 | Back is brand-tinted only when `canGoBack()` true; Forward disabled when `canGoForward()` false; refresh reloads active tab | ✓ VERIFIED | Mobile: `_omniboxNavButton` (`web_view_mobile.dart:600-624`) drives color/`onPressed` off a `FutureBuilder<bool>` on `canGoBack()`/`canGoForward()`; refresh → `_reload()` → `_controllers[i].reload()` (`:93-95`, `:590`). Windows: sync `canGoBack()`/`canGoForward()` (`web_view_windows.dart:117-118`) drive `_buildIconButton` color/`onPressed` directly (`:311-326`); refresh → `_controller.reload` (`:328-333`). |
| 3 | Tapping the field shows a brand focus ring + full editable URL; unfocused collapses to favicon + https lock + host | ✓ VERIFIED | `_buildOmniboxCenter` on both platforms: focus ring via `editing` branch (mobile `:649-657`; windows border/boxShadow `:291-306`); rest-state cover shows `Image.network(_getFaviconUrl(...))` + conditional `Icons.lock` (only when `webIsSecure`) + `webDisplayHost` text (mobile `:679-725`; windows `:365-411`). |
| 4 | Submitting still routes through `_loadUrl` (non-URL input falls back to `google.com/search?q=`) | ✓ VERIFIED | `_loadUrl()` unchanged fallback logic on both platforms (mobile `:285-299`, windows `:136-154`); `TextField.onSubmitted` calls it on both (mobile `:674-677`, windows `:360-363`). |
| 5 | Windows omnibox mirrors macOS 035-B, using SYNCHRONOUS `canGoBack()`/`canGoForward()` (no FutureBuilder) | ✓ VERIFIED | `web_view_windows.dart:117-134` — plain bool getters, no `Future`; `_buildOmniboxField` (`:285-338`) consumes them directly. |
| 6 | Windows: WalletConnect clipboard poller and history-based `_showTabSwitcher` untouched | ✓ VERIFIED | `_clipboardPoller` / `_pairWalletConnectFromClipboard` (`:49-85`) and `_showTabSwitcher`/history dialog (`:434-497`) present and unchanged in shape from the plan's description; the old `Icons.tab` trigger is now `Icons.more_horiz` (`:274-282`) but still opens the same dialog — a chrome-only relabel, not a mechanic change. |
| 7 | An always-visible horizontal tab strip sits between the navbar and the omnibox (~46px) | ✓ VERIFIED | `_buildTabStrip()` (`web_view_mobile.dart:357-408`), `height: 46`, inserted as first child of the build `Column` ahead of `_buildSearchBar()` (`:338-344`). Windows: explicitly NOT attempted (stretch goal per 18-03-PLAN, `_showTabSwitcher` history dialog remains Windows' only tab affordance) — consistent with the plan, not a gap. |
| 8 | Each tab shows favicon + title (`getTitle()` w/ URL fallback) + a close `x`; `+` at the end adds a DuckDuckGo tab | ✓ VERIFIED | `_buildTabChip` (`:410-528`): `Image.network(_getFaviconUrl(...))` + `_tabTitles[index]` (cached from `getTitle()` in `_syncTitle`, `:272-283`, URL fallback at `:277`) + hover-gated `Icons.close` (`:477-499`); trailing `+` → `_addNewTab("https://www.duckduckgo.com")` (`:396-399`). |
| 9 | Active tab wears the navbar's mark: `surfaceElevated` fill + 2px `brandCta` gradient underline | ✓ VERIFIED | `_buildTabChip` decoration (`:430-440`) + `_activeUnderlineGradient()` (`:537-543`, dark keeps `GeniusWalletGradient.brandCta`, light degrades to AA-safe `brandPrimaryOnSurface` per the transactions_slim_view precedent). |
| 10 | **The last remaining tab cannot be closed (its `x` reads disabled/absent)** | ✗ **FAILED** | See Gaps below — `_closeTab` (`:301-321`) now RESETS the last tab (removes it, adds a fresh DuckDuckGo tab) instead of locking it; the tab-chip close-`x` is gated only by `hovered` (`:477`), not by tab count. `webTabCanClose()` (`web_chrome_helpers.dart:35`) is defined + unit-tested but has **zero call sites** in `lib/`. |
| 11 | The old full-screen tab manager, upside-down thumbnails (`Matrix4.rotationX`), and dead `Screenshot`/`ScreenshotController` machinery are gone; `screenshot` removed from pubspec | ✓ VERIFIED | `grep -n "screenshot\|_tabImages\|Matrix4\|_showTabManager\|captureScreenshot\|dart:math" lib/web/web_view_mobile.dart` → no matches. `screenshot: ^3.0.0` absent from `pubspec.yaml`/`pubspec.lock` (`grep screenshot pubspec.*` → no matches). |

**Score:** 10/11 truths verified (1 FAILED — last-tab-locked mechanic).

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/web/web_chrome_helpers.dart` | 3 pure helpers (`webDisplayHost`, `webIsSecure`, `webTabCanClose`) | ⚠️ PARTIALLY WIRED | All 3 functions exist and are exported. `webDisplayHost`/`webIsSecure` are consumed by both platform files. `webTabCanClose` has NO production call site — see Key Link gap below. |
| `test/web/web_chrome_helpers_test.dart` | Tests every edge case (about:blank, unparseable, single tab) | ✓ VERIFIED | Ran directly: `flutter test test/web/web_chrome_helpers_test.dart` → **10/10 pass** (all groups: webDisplayHost, webIsSecure, webTabCanClose). |
| `lib/web/web_view_mobile.dart` | Omnibox + tab strip, manager/screenshot code removed | ✓ VERIFIED (with the #10 gap) | Read in full; matches plan structurally except for the last-tab-locked deviation. |
| `lib/web/web_view_windows.dart` | Omnibox re-skin, clipboard/history untouched | ✓ VERIFIED | Read in full; matches 18-03-PLAN.md closely. |
| `pubspec.yaml` / `pubspec.lock` | `screenshot` dependency removed | ✓ VERIFIED | Confirmed absent by grep. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|----|--------|---------|
| `_buildSearchBar` (mobile) | omnibox row | `webDisplayHost`/`webIsSecure` | ✓ WIRED | `_buildOmniboxCenter` calls both (`:644-645`). |
| field submit (mobile+windows) | `_loadUrl` | `onSubmitted` | ✓ WIRED | Confirmed both platforms. |
| back/forward/refresh (mobile) | `_goBack`/`_goForward`/`reload()` | `FutureBuilder<bool>` + `onEnabled` | ✓ WIRED | Confirmed. |
| `_buildTabStrip` | `_switchTab`/`_closeTab`/`_addNewTab` | tap handlers | ✓ WIRED (mechanic present, but `_closeTab`'s own guard behavior changed — see truth #10) | Tap→`_switchTab(i)` (`:422`), `x`→`_closeTab(index)` (`:483`), `+`→`_addNewTab(...)` (`:398`). |
| `x` close enable state | `webTabCanClose(_controllers.length)` | plan-declared key link (18-02-PLAN.md frontmatter) | ✗ **NOT WIRED** | `_buildTabChip`'s close-`x` visibility is gated by `hovered` only (`:477`); `webTabCanClose` is never referenced in `lib/web/web_view_mobile.dart`. The plan's own declared key link does not hold in the shipped code. |
| active underline | `GeniusWalletGradient.brandCta` (+ light AA route) | `_activeUnderlineGradient()` | ✓ WIRED | Confirmed, luminance-keyed degrade matches `transactions_slim_view` precedent. |
| `_buildSearchBar` (windows) | omnibox | `webDisplayHost`/`webIsSecure` | ✓ WIRED | `_buildOmniboxCenter` (`:343-346`). |
| back/forward/refresh (windows) | `goBack`/`goForward`/`_controller.reload` | sync bools | ✓ WIRED | Confirmed. |

### Requirements Coverage

**N/A for this phase.** Phase 18 has no REQUIREMENTS.md IDs; `requirements:` in the PLAN frontmatter
lists `18-CONTEXT.md` design decisions (D-01..D-09), not formal requirement records. The roadmap entry
itself states `**Requirements**: TBD (retrofit from sketch READMEs if a formal record is wanted)`. This
is reported explicitly per instruction, not treated as a gap.

### Anti-Patterns Found

None of `TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/`PLACEHOLDER`/"coming soon"/"not yet implemented" found in
`lib/web/web_view_mobile.dart`, `lib/web/web_view_windows.dart`, or `lib/web/web_chrome_helpers.dart`.
No debt-marker gate triggered.

One orphaned-code finding (not a debt marker, a dead code path): `webTabCanClose()` in
`web_chrome_helpers.dart` is fully implemented and unit-tested but has zero production call sites —
directly tied to the truth #10 gap above.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| `web_chrome_helpers` unit tests (host/lock/last-tab-close predicates) | `flutter test test/web/web_chrome_helpers_test.dart` | `+10: All tests passed!` | ✓ PASS |
| Full workspace test suite (regression check, run once) | `flutter test` | `+250 -1: Some tests failed.` — the single failure is `test/local_wallet_storage_test.dart` (`Missing definition of 'main' method` — entirely commented-out file, pre-existing per task constraints) | ✓ PASS (no new failures; count is 250 pass now vs. the previously-documented 234, consistent with the 10 new helper tests plus other unrelated test growth) |
| `flutter analyze` on phase files | `flutter analyze lib/web/web_view_mobile.dart lib/web/web_view_windows.dart lib/web/web_chrome_helpers.dart` | 11 issues: 8 pre-existing `avoid_print` info + 3 pre-existing `unnecessary_non_null_assertion` warnings, all inside the untouched navigation-delegate/Uniswap-JS block (`onPageStarted`/`onPageFinished`, lines 166-229) that both plans explicitly fence as D-09 engine wiring | ✓ PASS (no new issues from omnibox/tab-strip/helper code) |
| `flutter analyze lib` (whole-project baseline) | `flutter analyze lib` | 59 issues found | ✓ PASS (below the documented 61-issue baseline — net improvement from the Screenshot-code deletion; not a regression) |

### Probe Execution

N/A — no `scripts/*/tests/probe-*.sh` declared by or applicable to this phase (UI re-skin, no migration/CLI tooling).

### Human Verification Required

Even though this report's status is `gaps_found` (the #10 finding takes precedence), the following
items still need a human/macOS pass once the gap above is resolved:

### 1. Live macOS walk of the redesigned chrome

**Test:** Open the Web tab on macOS (dark mode, then a light-mode spot check). Confirm the omnibox
reads as one field, back/forward/refresh states are correct, focus ring + host/lock display work, the
tab strip renders and is legible, tabs open/switch/close correctly, and real browsing (Uniswap
dark-mode injection, banner hiding, DuckDuckGo default tab) is unregressed.
**Expected:** Matches the sketch 037-B visual and the mechanics documented in 18-01/02/03-SUMMARY.md.
**Why human:** Visual/interactive confirmation on the actual dev target (macOS); cannot be verified
from this Windows verification host.

### 2. Windows runtime confirmation of the omnibox re-skin

**Test:** Run the app on Windows and open the Web tab; confirm the omnibox renders and behaves as
`web_view_windows.dart`'s code describes (nav states, focus ring, favicon/lock/host swap, `⋯` opening
the history dialog).
**Expected:** Matches 18-03-PLAN.md's `<done>` criteria.
**Why human:** 18-03-SUMMARY.md itself states this was never runtime-verified ("no macOS/iOS runtime
walk is possible... Windows runtime confirmation is deferred to whoever next runs the Windows build").
Static analysis + code review (done above) is the only verification possible here; a live Windows
run has not happened yet by anyone.

### 3. Known limitation: URL bar cannot overwrite a selection (macOS only)

**Test:** N/A — do not attempt to reproduce or fix; already triaged.
**Expected:** N/A.
**Why human:** Already captured and root-caused at
`.planning/todos/pending/2026-07-25-web-tab-url-bar-cannot-overwrite-a-selection-on-macos.md` as a
WKWebView ↔ Flutter text-input engine conflict, macOS-only, does not reproduce on Windows. Recorded
here as a known, accepted limitation per task instruction — not scored as a gap, not re-litigated.

## Gaps Summary

One BLOCKER: the **last-tab-locked rule**, explicitly named in `18-CONTEXT.md` (D-06, "locked... NOT
open for discussion"), in `18-02-PLAN.md`'s `must_haves.truths`/`key_links`, and in the phase's own
roadmap entry's "Preserve real mechanics (do not regress)" list, does not hold in the code currently on
`ui-redesign-port`. A follow-up polish commit (`5c473d8`, merged in the same PR #214, but not covered
by any of the three phase plans or their SUMMARYs) changed `_closeTab` to reset the last tab to a fresh
DuckDuckGo tab instead of locking it, and changed the tab-chip close-`x` to be hover-gated for every
tab (including a lone tab) instead of disabled/absent on the last tab. The `webTabCanClose()` helper
built and tested specifically to drive this rule is dead code — it is never called from `lib/`.

**This looks intentional** (the commit's own comment frames it as a deliberate reset-not-lock UX
choice, and the HANDOFF documents it as a live-walked change), but it is undocumented against the
phase's explicitly locked decision and the plan's declared key link. To accept this deviation instead
of restoring the lock, add to this file's frontmatter:

```yaml
overrides:
  - must_have: "The last remaining tab cannot be closed (its x reads disabled/absent)"
    reason: "Reset-on-close (fresh DuckDuckGo tab) is a better UX than a disabled/inert close button on a lone tab; decided live during the 2026-07-25 follow-up session (see HANDOFF-session-260725-web-omnibox-markets.md)."
    accepted_by: "<name>"
    accepted_at: "<ISO timestamp>"
```

Everything else — the omnibox re-skin on both platforms, the tab strip itself, the active-tab mark, the
manager/Screenshot deletion, and every other preserved mechanic (`_goBack`/`_goForward`, `_loadUrl`,
`_addNewTab`/`_switchTab`, `_getFaviconUrl`, the Uniswap dark-mode/localStorage injection, the
banner-hiding JS, the Windows clipboard poller and history switcher) verified cleanly against the
codebase.

---

_Verified: 2026-07-25_
_Verifier: Claude (gsd-verifier)_
