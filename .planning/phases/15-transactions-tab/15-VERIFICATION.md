---
phase: 15-transactions-tab
verified: 2026-07-24T00:00:00Z
status: passed
score: 6/6 must-haves verified
behavior_unverified: 0
overrides_applied: 0
human_verification_evidence:
  walk_date: 2026-07-24
  walker: Jakub
  mode: DARK ONLY (light deferred to the app-wide light pass)
  result: "All 3 checkpoints APPROVED, no defects — TT-01..TT-06 observed live"
  source: ".planning/phases/15-transactions-tab/15-06-SUMMARY.md"
deferred:
  - truth: "Pull-to-refresh arms over the whole page including the filter rail"
    addressed_in: "deferred-items.md #2 (out-of-scope discovery, logged for the walk)"
    evidence: "RefreshIndicator does not arm over the rail card (220px of a wide page); the rail's SingleChildScrollView fits its content and refuses the drag. One-line fix (AlwaysScrollableScrollPhysics on the rail) is documented; plan explicitly said not to restructure RefreshIndicator speculatively."
  - truth: "The panel title row fits at phone width"
    addressed_in: "deferred-items.md #1 (pre-existing, made 8px better by 15-05)"
    evidence: "_panel title row overflows below 413px in the harness font; empty-scope guard drops the bar; very likely a harness-font artifact (real Inter ~110px vs harness ~216px for 'Transactions'). Lives in _panel, not touched by this phase."
---

# Phase 15: Transactions tab Verification Report

**Phase Goal:** `/transactions` stops being the dashboard panel in a bigger window. It becomes a page with its own frame and a filter rail that uses the width, its empty state stops drifting to the vertical midpoint, and the two rows where money did not simply move stop printing a dash where the number belongs.
**Verified:** 2026-07-24
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

The four framed defects in the ROADMAP diagnosis (panel-width cap, panel title on a page, no surface, empty block pinned to the midpoint) plus the behavioural bug (filter bar over an empty wallet) and the amount-dash defect are all closed in the shipped code. All six ROADMAP requirements (TT-01..TT-06) are delivered, each with test-file backing, and all six were observed live in the approved dark walk (15-06).

### Observable Truths

| # | Truth (ROADMAP requirement) | Status | Evidence |
| --- | --- | --- | --- |
| TT-01 | Page frame: one 24px page title, width uses the full cap, rows on a card surface, SGNUS branch gets the same frame, dashboard panel byte-unchanged | ✓ VERIFIED | `transactions_screen.dart:114` `GWPageHeader(title:'Transactions')` (headlineLg 24px, `gw_page_header.dart:29`); `:89-91` `ConstrainedBox(maxWidth: GeniusBreakpoints.xxl)` = 1536 (`breakpoints.dart:15`); rows sit in `DashboardScrollContainer` cards (`transactions_slim_view.dart:388,404`); SGNUS branch `SgnusTransactionsScreen(page:true)` still polls every 10s (`sgnus_transactions_screen.dart:32,58`); dashboard call sites `const TransactionsStream()` / `const SgnusTransactionsScreen()` default `page:false` (`view/dashboard_screen.dart:365-366`). Note: ROADMAP §15 supersession note (99a8913) is honoured — cap is xxl/1536, not the retired xl/1280. |
| TT-02 | Filter rail: the `⋯` menu unrolled — nine filters + an All row, all visible as rows with live counts, in a two-card page layout | ✓ VERIFIED | `_FilterRail`/`_RailRow` (`transactions_slim_view.dart:871,960`); `_page` builds a two-card Row (rail + list) above 768 (`:349-413`), reuses `_panel` below 768 (`:371`); counts via `filterCounts(scoped)` over the unfiltered list (`:394,123`); All row carries the total, no footer count (`:329-334`). |
| TT-03 | Rail states: rest = `_menuItem` geometry; hover = 008 lift chip 120ms; active = 022-B2 underline (label w700, never recoloured, 2px gradient rule, glyph never changes) | ✓ VERIFIED | Rest glyph `textSecondary` 14px, labelMd, tabular count (`:997-1105`); hover `lifted = _hovered && !active` → `surfaceElevated`, 120ms (`:984,1024-1033`); active label `textPrimary` in both states, `w700` when active (`:1063-1072`); 2px rule via `_activeLabelShader(gw)` for light degradation (`:1090,573`); glyph identical active/inactive (`:986-1003`). |
| TT-04 | Empty-state anchor: bounded 480px topCenter search replacing the bare Center; unbounded gallery intact; compact tier intact | ✓ VERIFIED | `Align(topCenter) → ConstrainedBox(maxHeight: _anchorSearchHeight=480) → Center` (`gw_empty_state.dart:249-255,84`); guarded on `isHeightBounded`, unbounded slot returns plain centred (`:116,230`); two asserts pin `_anchorSearchHeight > compactHeightThreshold` so the cap never selects compact (`:132-148`). Shared component — Assets/Markets inherit the fix. |
| TT-05 | Empty-state icon `sync_alt` + the filter control hidden entirely when the scope is empty (page rail and panel chips) | ✓ VERIFIED | `icon: Icons.sync_alt` on the never-transacted state (`transactions_slim_view.dart:442`); panel trailing `scoped.isEmpty ? null : _TransactionFilterBar(...)` (`:307-314`); page rail `if (scoped.isNotEmpty)` gates the whole rail card (`:385`); filtered-empty (`txs.isEmpty`) keeps its control with a route back to All (`:301-306` comment + `onAction` reset `:457`). |
| TT-06 | Amount honesty: job prints its real fee, failed/cancelled print the real signed amount, `Not charged` stays, tones distinguish moved vs not-moved money, no em dash | ✓ VERIFIED | `process` → `− <fees> <symbol>`, tone `outgoing` (loud), value `<fiat> fee` (`transaction_utils.dart:403-411`); dead-status override keeps the type-computed signed amount, sets tone `none` (quiet) + `valueLine='Not charged'` (`:454-457`); failed receive can never render green because the override wins over direction tone (`:454-455`); every branch assigns a non-empty `amount` (`:383,403,415,424`) — no `—`. |

**Score:** 6/6 truths verified (0 present-behaviour-unverified)

### Deferred Items

Both are documented in `deferred-items.md` as conscious out-of-scope discoveries, not phase failures.

| # | Item | Source | Evidence |
| --- | --- | --- | --- |
| 1 | Pull-to-refresh does not arm over the rail card (220px dead) | deferred-items.md #2 | Rail's `SingleChildScrollView` fits its content and refuses the drag; plan explicitly declined to restructure `RefreshIndicator`. `transactions_screen.dart:29-41` documents this as a known, accepted consequence of sketch 023-V3. |
| 2 | `_panel` title row overflows below 413px (harness font) | deferred-items.md #1 | Lives in `_panel`, untouched by this phase; 15-05 made it 8px better; very likely a harness-font artifact (real Inter ~110px vs harness ~216px). Flagged for the walk; no device measurement contradicts it. |

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `lib/dashboard/transactions/transactions_screen.dart` | Page frame: GWPageHeader, xxl cap, additive gutter | ✓ VERIFIED | Padding-outside-ConstrainedBox order preserved (`:72-91`); scroll lives on the page (`:42`). |
| `lib/dashboard/transactions/view/transactions_stream.dart` | `page` pass-through | ✓ VERIFIED | `page=false` default, forwarded to slim view (`:16,22`). |
| `lib/dashboard/transactions/sgnus_transactions_screen.dart` | `page` pass-through, polling intact | ✓ VERIFIED | 10s timer (`:32`), `page: widget.page` (`:58`), conditional Center only off-page (`:66`). |
| `lib/dashboard/home/widgets/transactions_slim_view.dart` | `_FilterRail`/`_RailRow`, `page` flag, empty-scope guard, `sync_alt`, hoisted `_activeLabelShader` | ✓ VERIFIED | All present (`:167,385,442,573,871,960`). |
| `lib/dashboard/home/widgets/transaction_utils.dart` | Amount block: type-first, dead-status override second | ✓ VERIFIED | Restructured exactly as specified (`:383-457`). |
| `lib/components/feedback/gw_empty_state.dart` | Center → bounded topCenter, guarded on isHeightBounded | ✓ VERIFIED | `:249-255`, asserts `:132-148`. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| TransactionsScreen | TransactionsSlimView(page:true) | Stream/Sgnus pass-throughs | ✓ WIRED | Three-file chain all forward `page`; a second "Transactions" title would signal a break — none present. |
| `_activeLabelShader` | `_RailRow` underline + `_menuItem` | shared file-scope fn | ✓ WIRED | Hoisted in 15-03, consumed at `:755` (menu) and `:1090` (rail) — zero new colour decisions in the rail. |
| `filterCounts(scoped)` | every rail/chip count | unfiltered-list arg | ✓ WIRED | `scoped`, never `txs`, at both call sites (`:311,394`) — counts stay stable under filtering. |
| `scoped.isEmpty` | filter control (rail + chips) | guard | ✓ WIRED | Drops the control in both presentations (`:307,385`); `txs.isEmpty` (filtered-empty) keeps it. |
| type-first + dead override | amount/tone/valueLine | override, not leading gate | ✓ WIRED | Override at `:454` reuses the completed row's derivation; `amount` stays `final`, assigned once per arm. |

### Behavioral Spot-Checks

Per project constraints the app is already running (Hive lock) and the full `flutter test` suite must not be run (shared baseline drift). Behaviour was instead confirmed by (a) code inspection, (b) present, readable test files with explicit assertions, and (c) the approved dark human walk.

| Behavior | Evidence | Status |
| --- | --- | --- |
| Failed tx prints real amount + `Not charged`, tone none | `transaction_utils_test.dart:240-266` ('failed prints the real amount, quietly') | ✓ PASS (test present, asserts `valueLine=='Not charged'`, `tone==none`) |
| Cancelled behaves like failed | `transaction_utils_test.dart:268-277` | ✓ PASS (test present) |
| Failed receive never green | `transaction_utils_test.dart:279-293` (`isNot(TxAmountTone.incoming)`) | ✓ PASS (test present) |
| Every type produces a complete, non-dash amount | `transaction_utils_test.dart:158-190` + `emDash` guard const (`:48`) | ✓ PASS (test present) |
| Empty-state anchor, rail states, page frame | `gw_empty_state_anchor_test.dart`, `transaction_filter_rail_test.dart`, `transaction_filters_test.dart`, `transactions_page_frame_test.dart` all present | ✓ PASS (5/5 phase test files present) |

Full-suite / `flutter test` execution intentionally skipped (constraint). The 15-06 walk records scoped `flutter analyze lib/dashboard/transactions lib/dashboard/home/widgets lib/components/feedback` = "No issues found!" and `flutter analyze lib` at baseline (delta 0).

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| TT-01 | 15-05 | Page frame | ✓ SATISFIED | See TT-01 row above |
| TT-02 | 15-04 | Filter rail | ✓ SATISFIED | See TT-02 row above |
| TT-03 | 15-04 | Rail states | ✓ SATISFIED | See TT-03 row above |
| TT-04 | 15-02 | Empty-state anchor | ✓ SATISFIED | See TT-04 row above |
| TT-05 | 15-03 | Empty icon + hidden filter control | ✓ SATISFIED | See TT-05 row above |
| TT-06 | 15-01 | Amount honesty | ✓ SATISFIED | See TT-06 row above |

TT requirements are ROADMAP-derived (not present in REQUIREMENTS.md, as expected per the phase note "derived from a read of the shipped route in sketches 020-022"). No orphaned requirements for this phase.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| transaction_utils.dart | 450 | `ponytail:` comment (dead row reuses completed-row derivation; named ceiling + upgrade path) | ℹ️ Info | Intentional simplification per CLAUDE.md convention — correctly marked, not a defect. |
| transactions_slim_view.dart | 11,17 | `ponytail:` comment (DashboardScrollContainer import ordering) | ℹ️ Info | Intentional, marked. |

No `TBD`/`FIXME`/`XXX` debt markers in phase files. No stub returns, no hardcoded-empty data flowing to render, no placeholder text. The empty branches (`return null`, transparent containers) are deliberate layout states with documented rationale, not stubs.

### Human Verification

Completed and APPROVED. The 15-06 human walk (`15-06-SUMMARY.md`) records all three dark checkpoints APPROVED by Jakub on 2026-07-24, with a per-criterion PASS verdict for TT-01..TT-06 observed live (extended mock batch + never-transacted "Clear" state), zero `RenderFlex overflowed` / `EXCEPTION CAUGHT` in console. The one thing sketch 022 said only the live app could settle — the 022-B2 active mark loudness — was judged sufficient in situ; variant D not needed.

**Light mode:** DEFERRED, not passed — per Jakub's standing dark-first policy (`.planning/todos/pending/2026-07-22-light-mode-verification-backlog.md`). Rail rest/active/gradient, empty-state contrast, and the amount-honesty `textSecondary` grey in light remain UNVERIFIED and carried to the dedicated light pass. This is by design and, per the phase mandate, is NOT a blocker. The light-degradation machinery (`_activeLabelShader` measured 6.30:1 on white; `none` tone measured 6.3:1 light) is already built in, so the light pass is a verification task, not new implementation.

### Gaps Summary

None. Every ROADMAP success criterion for Phase 15 is delivered in the shipped code, backed by present test files with explicit behavioural assertions, and confirmed by an approved dark human walk. The two deferred items are documented, conscious out-of-scope discoveries (pull-to-refresh over the rail; sub-413px panel title overflow), not phase failures. Light-mode verification is deliberately deferred to a dedicated pass.

---

_Verified: 2026-07-24_
_Verifier: Claude (gsd-verifier)_
