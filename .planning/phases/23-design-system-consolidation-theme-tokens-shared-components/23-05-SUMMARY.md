---
phase: 23-design-system-consolidation-theme-tokens-shared-components
plan: 05
subsystem: ui
tags: [flutter, hover-state, widget-refactor, mouseregion, statelesswidget]

requires:
  - phase: 23-04
    provides: prior design-system consolidation work on the shared components layer
provides:
  - "GWHoverable: a promoted, shared hover-plumbing widget (builder + cursor + no-op state guard)"
  - "Thirteen call sites migrated off hand-rolled bool _hovered + MouseRegion + setState onto GWHoverable"
  - "23-05-EXTRACTION-AUDIT.md: re-run measurement and verdict for every extraction candidate this phase considered"
affects: [23-06-closeout, future-copy-row-consolidation, future-timeframe-segment-unification]

tech-stack:
  added: []
  patterns:
    - "Builder-style hover state widget (GWHoverable) -- caller supplies paint, widget supplies only the boolean and pointer plumbing"
    - "No-op setState guard on hover transitions (only rebuild on an actual change)"

key-files:
  created:
    - lib/components/effects/gw_hoverable.dart
    - test/components/gw_hoverable_test.dart
    - .planning/phases/23-design-system-consolidation-theme-tokens-shared-components/23-05-EXTRACTION-AUDIT.md
  modified:
    - lib/components/cards/gw_card.dart
    - lib/components/cards/gw_select_row.dart
    - lib/components/cards/gw_view_all_link.dart
    - lib/components/data/gw_copy_row.dart
    - lib/components/gw_timeframe_segment.dart
    - lib/dashboard/home/widgets/transactions_slim_view.dart
    - lib/dashboard/home/widgets/transaction_displays.dart
    - lib/dashboard/chart/markets_hero_card.dart
    - lib/squid_router/swap_field.dart
    - lib/squid_router/swap_settings_drawer.dart
    - lib/tokens/token_info_screen.dart

key-decisions:
  - "GWTimeframeSegment REFUSE re-verified: the two live timeframe copies still diverge (surfaceSunken/5 ranges vs surfaceMenu/4 ranges); the border divergence claimed at planning time has closed since (both copies now carry it)"
  - "GWCopyRow already exists in the tree (built by unrelated work between planning and execution); this plan does not extend it onto its two remaining forks -- out of this plan's fence, recorded as a clean follow-up"
  - "GWHoverable migration scope grew from 12 planned sites to 13: dashboard_screen.dart's planned site was already gone (routed through GWTimeframeSegment by prior work), and gw_copy_row.dart + gw_timeframe_segment.dart carried the identical unplanned pattern and were folded in"
  - "GWHoverable's cursor parameter defaults to SystemMouseCursors.click because 10 of 13 sites set it explicitly; the 3 that didn't (GWSelectRow, swap_field.dart's two InkWell consumers, SwapSettingsDrawer's _PresetChip) all wrap InkWell, which already supplies its own click cursor -- the outer region's cursor was redundant there, not a deliberate omission"

patterns-established:
  - "GWHoverable: promote a private shim (AGENTS.md rung 4) rather than invent a component when the existing shim already has the right shape"

requirements-completed: [ORG-05]

coverage:
  - id: D1
    description: "GWHoverable exists as a real widget class (builder + cursor + no-op setState guard, nothing else); its contract (rest/enter/exit, cursor default and override, hit-area equality with the child, build-count suppression on a redundant enter/exit) is pinned by an ordinary widget test"
    requirement: ORG-05
    verification:
      - kind: unit
        ref: "test/components/gw_hoverable_test.dart#rest, enter and exit pass the right flag to the builder"
        status: pass
      - kind: unit
        ref: "test/components/gw_hoverable_test.dart#cursor reaches the pointer region, defaulting to click"
        status: pass
      - kind: unit
        ref: "test/components/gw_hoverable_test.dart#the hit area matches the child's own rect exactly"
        status: pass
      - kind: unit
        ref: "test/components/gw_hoverable_test.dart#a redundant enter does not cost an extra build"
        status: pass
    human_judgment: false
  - id: D2
    description: "Thirteen hand-rolled hover sites migrated onto GWHoverable with zero residual bool _hovered declarations outside gw_hoverable.dart itself, three green batch commits, and a net line reduction under lib/"
    requirement: ORG-05
    verification:
      - kind: other
        ref: "git grep -n 'bool _hovered' -- '*.dart' | grep -v gw_hoverable.dart  (0 matches)"
        status: pass
      - kind: unit
        ref: "flutter analyze --no-pub (0 issues) + flutter test --no-pub (722/0, 718 baseline + 4 new)"
        status: pass
      - kind: other
        ref: "git diff --shortstat bc0c8f7 HEAD -- lib/  (464 insertions, 486 deletions => net -22 lines)"
        status: pass
    human_judgment: false
  - id: D3
    description: "test/components/gw_card_hover_test.dart passes unmodified across all three migration batches, proving the card's hover reaction (brand tint + brand hairline, no lift) is unchanged by the GWHoverable migration"
    requirement: ORG-05
    verification:
      - kind: unit
        ref: "test/components/gw_card_hover_test.dart#hover paints the shared brand tint + brand hairline, no lift"
        status: pass
      - kind: other
        ref: "git diff bc0c8f7 HEAD -- test/components/gw_card_hover_test.dart  (0 lines changed)"
        status: pass
    human_judgment: false
  - id: D4
    description: "23-05-EXTRACTION-AUDIT.md re-measures every extraction candidate at execution time (not inherited from planning) and records a verdict, including the clipboard security audit and the timeframe/copy-row premise corrections"
    verification: []
    human_judgment: true
    rationale: "Whether the re-measurement is thorough and the reasoning behind each EXTRACT/REFUSE/DEFER verdict actually holds is a judgment call about a documentation artifact, not something a test can assert."
  - id: D5
    description: "Each of the three migration batches was walked live in both dark and light mode, confirming each surface's hover reaction is visually unchanged"
    verification: []
    human_judgment: true
    rationale: "This plan explicitly could not perform the live walk (no `flutter run` access in this session -- the orchestrator session owns the running app per this project's single-app-instance rule). All three batch walks are recorded OUTSTANDING below with the exact per-surface, per-mode checklist for the orchestrator to execute."

duration: ~50min
completed: 2026-07-30
status: complete
---

# Phase 23 Plan 05: GWHoverable extraction and hover-site migration Summary

**Promoted `swap_field.dart`'s private `_Hoverable` shim to a shared `GWHoverable` builder widget and migrated all 13 hand-rolled hover sites in the tree onto it, with zero residual `bool _hovered` declarations and a net line reduction under `lib/`.**

## Performance

- **Duration:** ~50 min
- **Tasks:** 3/3 completed
- **Files modified/created:** 14 (3 created, 11 modified)

## Accomplishments

- Re-measured every extraction candidate this phase was handed (`GWHoverable`, `GWTimeframeSegment`, `GWCopyRow`, `GWAppBar`, the `GWScreen` sweep, `GWPriceBlock`/`GWStatRail`) at execution time rather than inheriting planning-time verdicts, and wrote the full record to `23-05-EXTRACTION-AUDIT.md`
- Promoted `swap_field.dart`'s private `_Hoverable` shim to `lib/components/effects/gw_hoverable.dart` as `GWHoverable` -- a builder-style widget that owns only the hover flag, the pointer region, its cursor, and a no-op `setState` guard; the caller keeps full control of its paint
- Pinned `GWHoverable`'s contract in `test/components/gw_hoverable_test.dart`: rest/enter/exit, cursor default (click) and override, hit-area equality with the child, and build-count suppression on a redundant enter/exit -- the properties a visual baseline could not have checked anyway
- Migrated all 13 hover sites found in the tree (12 the plan named minus one that had already been migrated by other work, plus 2 the plan didn't name but which carried the identical pattern) across three green batch commits, each analyzer-clean, gate-clean and test-green before the next began
- Confirmed by reading every migrated diff hunk that each site's build expression moved into the builder unchanged; `test/components/gw_card_hover_test.dart` passes byte-for-byte unmodified

## Task Commits

1. **Task 1: Adjudicate every extraction candidate, and re-verify each refusal** - `bc0c8f7` (docs)
2. **Task 2: Promote the hover shim to GWHoverable, and pin its contract** - `0e8df85` (feat)
3. **Task 3: Migrate the twelve sites in batches, walking each batch** - `390e193` (Batch A), `3ead317` (Batch B), `cbf99b0` (Batch C) (refactor)

## The re-run verdict for every candidate, and where it differed from the planning-time claim

Full detail in `23-05-EXTRACTION-AUDIT.md`. Summary:

| Candidate | Verdict | Differs from planning? |
|---|---|---|
| `GWHoverable` | **EXTRACT** | Site count corrected: 13, not 12/9. One planned site (`dashboard_screen.dart`) was already gone; two unplanned sites (`gw_copy_row.dart`, `gw_timeframe_segment.dart`) were folded in. |
| `GWTimeframeSegment` | **REFUSE** | The dispatch-time claim that the two dashboard/Markets copies had "already been unified" was **wrong** -- re-grepped and confirmed `markets_hero_card.dart` still has its own private `_TimeframeSegment`. The border divergence planning claimed **has** closed (both copies now carry it); the track-fill and label-set divergence has not. |
| `GWCopyRow` | **REFUSE** (scoping, not floor) | The component now exists (built by unrelated work, for a bridge-hash row), so the two-occurrence "below the floor" premise no longer holds -- three occurrences exist today. This plan still does not extend it onto its two remaining forks: out of fence, not out of merit. |
| `GWAppBar` | **DEFER** | File count corrected: 15, not 16. |
| `GWScreen` sweep | **DEFER** | Counts corrected: 25 hand-rolled `Scaffold` (not ~28), 2 live `GWScreen` adopters (not stated at planning time). |
| `GWPriceBlock`/`GWStatRail` | **DEFER** | No file:line list exists in the planning corpus for either; the deferral is inherited unchanged because there was nothing to re-diff, not because a fresh measurement re-confirmed the count. |

## The timeframe diff and the refusal it produced

`GWTimeframeSegment` (`gw_timeframe_segment.dart`, shared by `dashboard_screen.dart` and `lib/chart/crypto_live_chart.dart`) vs. `markets_hero_card.dart`'s private `_TimeframeSegment`:

| Property | GWTimeframeSegment | Markets hero's own copy |
|---|---|---|
| Labels | 1H · 1D · 1W · 1M · 1Y (5) | 24H · 7D · 30D · 1Y (4) |
| Track fill | `gw.surfaceSunken` (the documented "Control track" standard) | `gw.surfaceMenu` |
| Border | present | present (this closed since planning) |

Refused: folding these would either drop a domain each screen expresses or force a reconciling parameter, the exact Rule-of-Three stop-signal. The track-fill divergence is recorded as a real, unfixed finding pointing at the existing `.planning/todos/pending/2026-07-24-unify-timeframe-segment-component.md`. Not repainted here.

## Clipboard per-site security verdicts and the defect found

All 10 `Clipboard.setData` write sites in the tree were audited for (a) full-value-not-truncated and (b) not-logged. **All 10 PASS** on both properties -- full detail and per-site file:line in `23-05-EXTRACTION-AUDIT.md`. The mnemonic copy (`sdk_account_manager.dart:332`) is additionally the only site gated behind an explicit confirmation dialog naming the risk.

**One defect found, adjacent to the write-site audit:** `lib/web/web_view_windows.dart:75` -- `debugPrint('📋 WalletConnect URI from clipboard: $text')` logs the content of a clipboard **read** (a WalletConnect pairing URI, polled every 2s) to the debug console. Lower severity than an account secret (a pairing URI, not a key), and `debugPrint` does not reach Sentry/telemetry in this app -- but it is a real finding, out of this plan's fence (not in Task 3's file list), recorded for follow-up.

## The cursor default and the site split behind it

`GWHoverable.cursor` defaults to `SystemMouseCursors.click`. 10 of the 13 migrated sites already set it explicitly; the 3 that didn't (`GWSelectRow`, `swap_field.dart`'s two `InkWell` consumers, `SwapSettingsDrawer`'s `_PresetChip`) all wrap an `InkWell` as their tappable child, and `InkWell` already resolves its own click cursor when it has an `onTap` -- the parent region's cursor was redundant with the child's there, not a deliberate "no cursor" choice. Defaulting to click keeps every migrated site's cursor behaviour unchanged.

## Per-site confirmation: every build expression moved verbatim

Confirmed by reading each diff hunk. Where a site's hover-dependent local (`lifted`, `fg`, `labelColor`, `_displayValue`, `short`) had to move from the enclosing `build()` method into the `builder` closure, that move is mechanical (the value depends on `hovered`, which is only available inside the closure) and does not change the value computed or the widget tree produced -- confirmed by reading the before/after side by side for each site:

- `gw_card.dart` (`_HoverLiftCard`) -- demoted to `StatelessWidget`
- `gw_select_row.dart` (`GWSelectRow`) -- demoted to `StatelessWidget`
- `gw_view_all_link.dart` (`GWViewAllLink`) -- demoted to `StatelessWidget`
- `gw_copy_row.dart` (`GWCopyRow`) -- demoted to `StatelessWidget` (new addition to scope, see below)
- `gw_timeframe_segment.dart` (`_TimeframeTab`) -- demoted to `StatelessWidget` (new addition to scope, see below)
- `markets_hero_card.dart` (`_TimeframeTab`) -- demoted to `StatelessWidget`
- `transaction_displays.dart` (`_CopyRow`) -- demoted to `StatelessWidget`
- `transactions_slim_view.dart` (`_FilterChip`, `_RailRow`) -- both demoted to `StatelessWidget`
- `swap_field.dart` -- private `_Hoverable`/`_HoverableState` deleted outright; its two `InkWell` consumers repointed to `GWHoverable`
- `swap_settings_drawer.dart` (`_PresetChip`) -- demoted to `StatelessWidget`
- `token_info_screen.dart` (`_CopyAddressRow`, `_BackToMarkets`) -- both demoted to `StatelessWidget`

No site held other state besides the hover boolean, so every migrated widget was demoted to `StatelessWidget` -- none was left stateful.

## Sites left unmigrated: none

All 13 sites found in the tree were migrated. Zero remain: `git grep -n 'bool _hovered' -- '*.dart' | grep -v gw_hoverable.dart` returns no matches.

**Scope note:** two sites were added to Task 3's scope beyond the plan's original twelve-file list, per the plan's own "legitimate migration target" instruction (measured fact #6 in the dispatch): `lib/components/data/gw_copy_row.dart` and `lib/components/gw_timeframe_segment.dart`'s `_TimeframeTab`. Both carried the identical `bool` + `MouseRegion` + `setState` pattern independent of the (separately refused) row-identity/timeframe-identity questions. One planned site, `lib/dashboard/home/view/dashboard_screen.dart`, no longer needed migration: it was already routed through `GWTimeframeSegment` by prior, unrelated work, and now declares no hover boolean of its own.

## The three batch walk results: OUTSTANDING

**This executor session could not perform the live walk.** Per this project's standing rule, only one running `flutter run` instance is safe at a time (the Hive container lock), and the orchestrator session owns the running app for this phase. Everything else in each batch's acceptance criteria (code, gates, tests, commit) is done and green; the live walk is the one item this session genuinely cannot supply. Recorded OUTSTANDING, not PASS, per this project's no-unearned-PASS rule.

### Batch A walk (commit `390e193`) — OUTSTANDING

Hover, in **both** dark and light mode:
- [ ] A dashboard card with `hoverLift: true` (`GWCard`) — reaction: the card's hairline strengthens and a brand tint paints over it (no lift, no shadow change).
- [ ] A select row inside a drawer (`GWSelectRow`, e.g. the token/network/account pickers) — reaction: unselected hover fills with the brand tint and gains the brand hairline; a selected row is unaffected by hover.
- [ ] A "view all" link (`GWViewAllLink`, dashboard panel headers) — reaction: the label and arrow light up from `textSecondary` to `textPrimary`/white and the arrow slides ~3px right.
- [ ] (New in scope) A copy row using `GWCopyRow` (`lib/submit_job/view/widgets/job_steps.dart`) — reaction: the copy glyph brightens from `textSecondary` to `textPrimary` on hover.
- [ ] The token selector trigger and the MAX chip on the Swap screen (`swap_field.dart`, now via the shared `GWHoverable` instead of the deleted private shim) — reaction unchanged: token trigger fills/borders with the hover recipe; MAX chip gains its brand hairline.

### Batch B walk (commit `3ead317`) — OUTSTANDING

Hover, in **both** dark and light mode:
- [ ] A row in the slim transactions list's filter chips (`_FilterChip`, dashboard panel) — reaction: an unselected chip lifts onto `surfaceElevated`; the active (gradient) chip is unaffected.
- [ ] A row in the transactions page's filter rail (`_RailRow`) — reaction: an unselected row's fill lifts onto `surfaceElevated`; the active row is unaffected.
- [ ] A transaction display's clipboard row (`_CopyRow`, transaction detail drawer's address/hash rows) — reaction: the copy glyph brightens on hover.
- [ ] A dashboard timeframe tab (`GWTimeframeSegment`, via `dashboard_screen.dart` or the coin-page chart header) — reaction: an unselected tab lifts onto `surfaceElevated` with a 1px rise and the card shadow; the selected (gradient) tab is unaffected.
- [ ] A Markets hero timeframe tab (`markets_hero_card.dart`'s own `_TimeframeSegment`) — same reaction as above, on the Markets hero's own 24H/7D/30D/1Y control (deliberately NOT the same widget as the dashboard's — see the audit's REFUSE verdict).

### Batch C walk (commit `cbf99b0`) — OUTSTANDING

Hover, in **both** dark and light mode:
- [ ] The Address copy row on a token detail screen (`_CopyAddressRow`, `token_info_screen.dart`) — reaction: the copy glyph brightens on hover.
- [ ] The "‹ Markets" back chip at the top of a token detail screen (`_BackToMarkets`) — reaction: fills with the brand tint and gains the brand hairline; the chevron and label brighten.
- [ ] A slippage preset chip in the Swap Settings drawer (`_PresetChip`, `swap_settings_drawer.dart`) — reaction: an unselected chip fills with the brand tint and gains the brand hairline; a selected (gradient) chip is unaffected.

## Net LOC change

`git diff --shortstat bc0c8f7 HEAD -- lib/`: **464 insertions(+), 486 deletions(-)** — net **-22 lines under `lib/`**, satisfying the plan's verification item 8. (Including the new test file, the full diff across all four commits after Task 1 is 616 insertions / 486 deletions across 13 files.)

## Decisions Made

- `GWTimeframeSegment` REFUSE re-verified on a fresh diff rather than trusted from the dispatch note, which turned out to itself be wrong about the current state of the tree.
- `GWCopyRow`'s REFUSE reclassified from "below the Rule-of-Three floor" (no longer true — the component now exists, built independently) to "out of this plan's fence" (still true — this plan's tasks never named it).
- Migration scope for `GWHoverable` expanded from the plan's 12 named sites to the tree's actual 13, per the plan's own "legitimate migration target" instruction for sites carrying the identical pattern.
- Cursor default (`SystemMouseCursors.click`) chosen and justified by an explicit majority/minority count of the 13 sites, not assumed.

## Deviations from Plan

### Auto-fixed / scope corrections

**1. [Rule 2 — plan's own instruction, not a bug] Added two unplanned hover sites to Task 3's migration**
- **Found during:** Task 1 (re-measurement)
- **Issue:** `gw_copy_row.dart` and `gw_timeframe_segment.dart`'s `_TimeframeTab` carry the identical `bool _hovered` + `MouseRegion` + `setState` pattern the plan exists to collapse, but were not in the plan's twelve-site list (they postdate the plan).
- **Fix:** Migrated both in Task 3 (Batch A and Batch B respectively), per the plan's own instruction that such sites are "legitimate migration targets."
- **Files modified:** `lib/components/data/gw_copy_row.dart`, `lib/components/gw_timeframe_segment.dart`
- **Verification:** `flutter analyze --no-pub` 0, full suite green, `git grep -n 'bool _hovered'` returns zero residual matches.
- **Committed in:** `390e193` (gw_copy_row.dart), `3ead317` (gw_timeframe_segment.dart)

**2. [Correction, not a fix] One planned site turned out to already be migrated**
- **Found during:** Task 1 (re-measurement)
- **Issue:** The plan's Task 3 file list names `lib/dashboard/home/view/dashboard_screen.dart` as a hover site. It is not one -- `GWTimeframeSegment` was already extracted out of it by prior, unrelated work, and the file declares no hover boolean at all today.
- **Fix:** No action needed; recorded in the audit and in this summary rather than silently dropped from the count.
- **Files modified:** none.

---

**Total deviations:** 2, both scope corrections driven by the plan's own re-verification instruction and its "legitimate migration target" clause. No unrequested architectural changes; no scope creep beyond what the plan itself anticipated as a live possibility.
**Impact on plan:** Net positive — the migration is more complete (13/13 real sites) than the plan's own inventory predicted, and the one apparent shortfall (dashboard_screen.dart) was already resolved by other work rather than missed.

## Issues Encountered

Widget tests initially found ambiguous `MouseRegion` matches (`MaterialApp`/`Scaffold` add their own `MouseRegion`s for app-level cursor tracking). Resolved by scoping every finder in `gw_hoverable_test.dart` to `find.descendant(of: find.byType(GWHoverable), matching: find.byType(MouseRegion))`.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- All three batch walks are OUTSTANDING and should be run by the orchestrator session (which owns the running app) before 23-06 closeout, using the exact per-surface/per-mode checklists above.
- Two clean follow-ups recorded in `23-05-EXTRACTION-AUDIT.md`, not filed as todos yet: migrating `transaction_displays._CopyRow` and `token_info_screen._CopyAddressRow` onto the existing `GWCopyRow`, and the `web_view_windows.dart:75` clipboard-read logging finding.
- `23-06` closeout can report ORG-05's coverage honestly from the audit's closing statement: one extraction (13 sites, zero repaints), five candidates refused/deferred on re-run measurement, two findings recorded for later.

---
*Phase: 23-design-system-consolidation-theme-tokens-shared-components*
*Completed: 2026-07-30*

## Self-Check: PASSED

All 4 claimed artifacts found on disk (`lib/components/effects/gw_hoverable.dart`, `test/components/gw_hoverable_test.dart`, `23-05-EXTRACTION-AUDIT.md`, this file). All 5 claimed commit hashes (`bc0c8f7`, `0e8df85`, `390e193`, `3ead317`, `cbf99b0`) found in git log.
