---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
current_phase: 03
current_phase_name: gw-component-library
status: complete
stopped_at: Phase 3 COMPLETE. Ready to plan Phase 4 (nav shell) — wire theme.dart FIRST.
last_updated: "2026-07-17T13:33:28.280Z"
last_activity: 2026-07-17
last_activity_desc: Phase 3 closed — criterion 5 walk PASSED (3 PASS, 3 PARTIAL, 0 OUTSTANDING)
progress:
  total_phases: 11
  completed_phases: 2
  total_plans: 15
  completed_plans: 15
  percent: 18
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-07-15)

**Core value:** Users can safely custody their keys and reliably perform core wallet actions.
**Current focus:** Phase 03 — gw-component-library

## Current Position

Phase: 03 (gw-component-library) — **COMPLETE** (10/10 plans; criteria 3 PASS / 3 PARTIAL / 0 OUTSTANDING)
Plan: 10 of 10 — all complete
Status: **Phase 3 closed 2026-07-17.** Criteria 2 (DS-04), 4 (drawer), **5 (no visual change — the
phase's load-bearing claim, human-walked, all 3 shadow surfaces confirmed)** = PASS. Criteria 1, 3, 6
= PARTIAL with named accepted gaps, NOT hidden ones. See `03-VERIFICATION.md`.
**Carried into Phase 4 (do not lose):** the light-mode dark-only COUNT is NOT DERIVABLE until
`theme.dart` is wired — wire it EARLY, before re-skinning any screen, then re-walk the gallery.
Branch: `ui-redesign-port` (off develop) — `branching_strategy: none`, phases land here
Last activity: 2026-07-17 — Phase 3 closed; criterion 5 walk PASSED

Progress: [██░░░░░░░░] 18% (2 of 11 phases)

## Accumulated Context

### Decisions

Full log in PROJECT.md Key Decisions. Recent:

- **Port the design incrementally, layer by layer** (2026-07-16) — 128 of the design's 172 files collide with develop (74%); one step means reconciling all of them with nothing verifiable in between
- Sequence by dependency, not subject: tokens → `gw_*` primitives → nav shell → screen areas. Each phase lands on a layer that already exists and has been reviewed
- GAP treatment split: GAP-01 (inventory + decision) rides in Phase 3 because "extend the design language" is a design-system question that must be answered before screens land; GAP-02..06 ride in the phase that owns their surface
- Screen areas were **not** compressed despite `granularity: standard` — merging them recreates the reconcile-everything-at-once failure this milestone exists to avoid
- Keep `ui-redesign-3.514-develop` as read-only reference; port its 3 remaining fix commits with their components (BEH-02)
- Interactive mode (config is committed to the shared repo)
- [Phase 2]: google_fonts inserted next to go_router in pubspec.yaml (nearest alphabetical neighbor) rather than resorting the non-alphabetical dependency block
- [Phase 2]: gw_appearance.dart ported verbatim except the Hive import (hive_ce_flutter instead of classic hive_flutter), matching develop's data layer
- [Phase 2]: Ported f3fd16f's dev_flags.dart byte-for-byte, including its docstring, per UI-SPEC guidance.
- [Phase 2]: Only responsive_overlay.dart's Dev row is gated this phase; wallet_creation_screen.dart onboarding buttons deferred to Phase 6 (they don't exist on develop today).
- [Phase 02-design-tokens-verification-loop]: appBarHeight deferred to Phase 4: develop's 60 kept, design branch's 65 not ported (real visual change, still in live use by responsive_overlay.dart)
- [Phase 02-design-tokens-verification-loop]: genius_wallet_colors.dart and genius_wallet_gradient.dart ported as pure insertions (0 deletions); genius_wallet_consts.dart's 6 legacy aliases re-pointed after per-alias value verification
- [Phase 02-04]: All six remaining redesign theme files (motion, font-size, copy-text, elevation, typography, decorations) ported byte-identical, zero adaptation needed, zero collision — Grep-verified before planning that develop referenced none of these six class names anywhere in lib/ or packages/
- [Phase 02-04]: GWCanvasBackground ported as a dormant class, instantiated nowhere in lib/ — References assets/images/textures/noise.png, an asset owned by DS-04/Phase 3, not bundled this phase
- [Phase 02-04]: toMaterialTextTheme() ships but is not wired into theme.dart this phase — theme.dart is the 100%-collision file UI-SPEC section 1.1 excludes wholesale for the whole of Phase 2; wiring belongs to Phase 4's shell re-skin
- [Phase 02-design-tokens-verification-loop]: TokenProbeScreen wraps its body in ValueListenableBuilder on GWAppearance.instance so the appearance toggle actually rebuilds; setMode() alone persists but does not repaint
- [Phase 02-design-tokens-verification-loop]: 02-VERIFICATION.md marks criteria 1 and 3 OUTSTANDING and criterion 4 PARTIAL rather than PASS -- an unearned PASS is the exact BLD-02 failure mode (37 regressions shipped analyze-clean)
- [Phase 02-design-tokens-verification-loop]: Onboarding Mock button (ROADMAP criterion 4) recorded as an explicit Phase 6 deferral, not a pass -- it does not exist on develop today
- [Phase 03-01]: mobile_scanner inserted after qr_flutter and shimmer after app_links in pubspec.yaml — Matched the reference worktree's relative ordering where the surrounding lines still align
- [Phase 03-01]: Guard's Check 2 census uses ^(abstract )?class, not just ^class — Also catches abstract-class name collisions; verified identical 4-name result on today's tree, so no behavior gap
- [Phase 03-01]: Shadow/canonical import matching uses full package:genius_wallet/... strings, not bare filename substrings — Codebase has zero relative imports anywhere under lib/ (verified), so the stricter match has no coverage gap
- [Phase 03-02]: gw_token_row.dart ported to cards/, not data/ - DESIGN_SYSTEM.md section 5.2's table is stale; verified source path is cards/gw_token_row.dart
- [Phase 03-02]: gw_ai_fab.dart deliberately excluded - imports lib/ai/, WIRE-02 out of scope for this milestone
- [Phase 03-03]: Rule 3: added brandGreen/brandGreenStrong/brandGreenMuted/brandGreenSubtle to genius_wallet_colors.dart -- Phase 2's port omitted this alias block; gw_loading_state.dart and loading/loading.dart both reference brandGreen and would not compile without it; new names only, no existing develop token reassigned
- [Phase ?]: wallet_type_icon.dart: Icon(FontAwesomeIcons.x) -> FaIcon(FontAwesomeIcons.x) at 3 sites -- font_awesome_flutter v11 (Phase 2 bump) returns FaIconData from FontAwesomeIcons getters, incompatible with Icon's IconData param
- [Phase ?]: Added GeniusWalletColors.btnDisabled (Rule 3) -- second missing-token gap of this class found in Phase 3, following 03-03's brandGreen precedent
- [Phase ?]: [Phase 03-05]: responsive_grid.dart: GeniusBreakpoints.isNativeApp(context) -> GeniusBreakpoints.isMobileApp() (Rule 3) -- reference breakpoints.dart's isNativeApp doesn't exist on develop's version, and breakpoints.dart is this plan's own zero-diff-protected collision file, so the fix lives in the consumer
- [Phase ?]: [Phase 03-05]: Findings 13/25/26 confirmed already-correct on develop's untouched responsive_drawer.dart (useRootNavigator=true, enableDrag=true, GeniusBreakpoints.medium=768); Alex's regressed responsive_drawer.dart deliberately not ported, binding rule recorded for Phase 4
- [Phase ?]: Ported GeniusWalletColors.gray500 (alias for textSecondary), the third missing-token fix this phase, verbatim from the reference worktree -- required by sgnus_wallet.dart, zero prior references.
- [Phase ?]: Repointed the Splash shadow's Loading import from the reference's shadow path to develop's canonical loading.dart (identical constructor) to keep the Loading shadow's exposure limited to the design gallery; updated the guard's pinned canonical-importer list and 03-SHADOW-NAMES.md in the same commit as a deliberate, documented inventory update, not a guard loosening.
- [Phase ?]: wallet_information.g.dart's ResponsiveDrawer.show(children:) fixed to child: -- Alex's fork API shape vs develop's canonical protected ResponsiveDrawer.show; fixed in the consumer, not the collision file
- [Phase ?]: wallet_information.g.dart's FontAwesomeIcons.trash unwrapped via .data to satisfy SlidingDrawerButton's IconData? param (font_awesome_flutter ^11 delta) -- same precedent as 03-04's Icon->FaIcon, opposite direction
- [Phase ?]: GAP-01 whole-app inventory: 10 evidenced gaps confirmed exact match to REQUIREMENTS.md GAP-02..06 (not the ROADMAP's estimated 12), via a whole-lib/-tree diff-filter=D scan
- [Phase ?]: New finding: order_details_page.dart has a moved-path Alex analog (lib/banxa/order_details_page.dart) not named in GAP-05's list -- Phase 9 addendum, not a new GAP
- [Phase ?]: Deferred structural question for product (03-GAP-INVENTORY.md): whether transaction_displays.dart (GAP-06) should split into per-type files matching Alex's 4-file organization, or keep develop's single-file structure with a mechanical re-skin
- [Phase ?]: [Phase 03-09]: Both tasks landed in lib/dev/design_gallery_screen.dart as two separate atomic commits (302a68c, 6686be2), split by writing each task's end-state directly rather than isolating dart-format-churned hunks
- [Phase ?]: [Phase 03-09]: GWIcon.svg/.png demo assets chosen by reading pubspec.yaml's packages/genius_wallet/assets/images/* declarations (shape.svg, mask2.png) rather than assuming an arbitrary bundled asset resolves under the default package: 'genius_wallet'
- [Phase ?]: [Phase 03-09]: The gallery's human walk (criteria 1/3/4, finding 15, and the light-mode dark-only COUNT) is OUTSTANDING, not passed -- recorded as coverage item D5 status:outstanding, per this project's standing no-unearned-PASS rule
- [Phase ?]: [Phase 03-10]: Verification record: criterion 5 (no-visual-change walk) recorded OUTSTANDING -- no Windows GUI access; criteria 1/3/6 PARTIAL (theme confound + 2 unexplained findings + 2 missing gallery sections); criteria 2/4 PASS
- [Phase ?]: [Phase 03-10]: Re-derived two stale figures rather than trusting them: loading.dart's canonical importer count is 19 not 18; responsive_overlay.dart's lib/components/ modification is Phase 2's ca556e4 (BLD-03), not a Phase 3 leak
- [Phase ?]: [Phase 03-10]: Criterion 6's deferred cross-check found 2 of 15 GAP-01 primitives with no gallery section: custom_drop_down.dart/currency_dropdown.dart and wallet_type_icon.dart -- both compile clean, neither is demoed

### Pending Todos

- Phases 2–10 are UI phases (`ui_phase: true`, `ui_safety_gate: true`) — each should get a UI-SPEC design contract via `/gsd-ui-phase` before planning
- Corrected the v1 requirement count in REQUIREMENTS.md: 22 → 24 (previous count was wrong)
- [ui] Design system has no light-mode treatment (`.planning/todos/pending/2026-07-17-design-system-has-no-light-mode-treatment.md`) — scope unknown; 03-09's both-mode walk produces the count

### Blockers/Concerns

- **No working automated test harness** (`flutter test` does not compile) — every success criterion in the roadmap is phrased to be observable by running the app. `flutter analyze` is a gate, never evidence. Fixing the harness is deferred to APP-02 (v2)
- Nav shell has never been visually walked — Phase 4 addresses this
- 37 evidenced defects in the design-vs-develop surface (`.planning/REVIEW_FINDINGS_REDESIGN.md`, 3 blockers) are assigned per phase; Phase 11 signs off the full set
- `analysis_options.yaml` excludes `lib/**/*.g.dart` — the compiler, not analyze, is the real gate for generated widgets
- **Two components are dark-only by design** (2026-07-17, from the 03-07 walk) — `GWCanvasBackground` gates its grain behind `if (!isLight)`; `GWMeshBackground` never reads the appearance and washes out on a light base. Both verified byte-identical to the reference, so **neither is a port defect**. ~~Alex's design system may have no complete light mode~~ — **CORRECTED same day: FALSE.** Alex's `theme.dart` IS appearance-aware (`brightness: isLight ? Brightness.light : Brightness.dark`); light mode is a real designed feature. These two are deliberate dark-only choices *within* a working light mode. Scope of dark-only components still unknown — 03-09's both-mode walk produces the count. Do not fix before that number exists; see the todo for why removing the gate is insufficient
- **develop's `theme.dart` is NOT appearance-aware and Phase 4 must wire it — THIS IS NOW THE PHASE'S BIGGEST OPEN ITEM** (2026-07-17) — `ThemeData(brightness: Brightness.dark)`, hardcoded, zero `GWAppearance` references, no `textTheme:`, and `toMaterialTextTheme()` (defined `genius_wallet_typography.dart:133`) is referenced NOWHERE in `lib/`. Phase 2 deferred it (UI-SPEC §1.1 excludes `theme.dart` wholesale as a 100%-collision file). **Consequences already observed, both in 03-09:** (1) the gallery's faithfully-ported `Scaffold(backgroundColor: Colors.transparent)` fell through to the permanently-dark theme while `textPrimary` flipped to near-black ink → light mode unreadable. Worked around in the dev-only gallery (`244b71e` → `surfaceBase`); **revert to `Colors.transparent` when Phase 4 lands the real theme.** (2) `GeniusWalletTypography.*` styles carry NO color, so every `Text` using them inherits white from the dark theme unconditionally → 5 of the walk's 8 findings. **Every Phase 4+ screen mounting Alex's components will hit this until the theme is wired.** Wire it EARLY in Phase 4, before re-skinning any screen
- **The dark-only light-mode COUNT is NOT DERIVABLE until Phase 4 wires the theme** (2026-07-17) — the 03-09 walk established that any count taken now measures OUR missing theme, not Alex's design, and would misattribute the cause. Recorded in `03-09-SUMMARY.md` as an accepted gap, explicitly not a pass. **Re-derive after Phase 4.** See the todo for what stays genuinely open (canvas grain, mesh blobs, `GWSwitch` disabled==off, `GWSwitch` off-thumb near-black in light — all byte-identical ports, all Alex's real design choices)
- **Two 03-09 findings have NO established root cause** (2026-07-17) — `Screen wrappers` renders nothing in EITHER mode (light explained by white-text-on-light; **dark blankness unexplained**; `app_screen_view.dart` is byte-identical so not a port defect), and the disabled checkbox is invisible in dark (`btnDisabled` = `const Color.fromRGBO(188,188,188,1)`, not appearance-aware, but its role is unconfirmed). **Both need a real repro. No hypothesis has been recorded as fact**
- 03-09's human walk (criteria 1/3/4, finding 15, and the light-mode dark-only COUNT across all 30 gallery sections) is outstanding -- no code changed pending it; see 03-09-SUMMARY.md's Outstanding section for the exact recipe
- Phase 3 criterion 5 (the no-visual-change walk, GW_DEV_TOOLS unset) is OUTSTANDING -- requires a human with Windows GUI access. Exact recipe recorded in 03-VERIFICATION.md

## Reference Material

| Item | Location | Use |
|------|----------|-----|
| Original design branch | worktree `C:\Users\User\Documents\Projects\GNUS-compare\GeniusWallet-3514` | Builds + runs as a Release exe — the visual source of truth |
| Verified fixes | branch `ui-redesign-3.514-develop` | Read-only; source of the 3 BEH-02 fix commits |
| Regression audit | `.planning/REVIEW_FINDINGS_REDESIGN.md` | 37 findings, assigned per phase in ROADMAP.md |

## Deferred Items

| Category | Item | Status | Deferred At |
|----------|------|--------|-------------|
| Testing | APP-02 — working `flutter test` harness | v2 | 2026-07-16 |
| Features | APP-01 — broader feature roadmap (chains, staking) | v2 | 2026-07-16 |

## Session Continuity

Last session: 2026-07-17T13:33:28.271Z
Stopped at: 03-10 verification record written: criterion 5 OUTSTANDING (no GUI access), 2/6 PASS + 3/6 PARTIAL otherwise. Phase 3 not closed 6/6 -- needs a human walk.
Resume file: .planning/phases/03-gw-component-library/03-VERIFICATION.md

## Performance Metrics

| Phase | Plan | Duration | Notes |
|-------|------|----------|-------|
| Phase 02-design-tokens-verification-loop P01 | 10min | 3 tasks | 5 files |
| Phase 02 P02 | 15min | 2 tasks | 2 files |
| Phase 02-design-tokens-verification-loop P03 | 25min | 3 tasks | 3 files |
| Phase 02-design-tokens-verification-loop P04 | 20min | 3 tasks | 6 files |
| Phase 02-design-tokens-verification-loop P05 | 7min | 3 tasks | 5 files |
| Phase 03-gw-component-library P01 | 10min | 2 tasks | 7 files |
| Phase 03-gw-component-library P02 | 3min | 3 tasks | 12 files |
| Phase 03-gw-component-library P03 | 12min | 2 tasks | 7 files |
| Phase 03-gw-component-library P04 | 13min | 3 tasks | 16 files |
| Phase 03-gw-component-library P05 | 7min | 2 tasks | 9 files |
| Phase 03 P06 | 13min | 2 tasks | 12 files |
| Phase 03-gw-component-library P07 | 12min | 3 tasks | 4 files |
| Phase 03-gw-component-library P08 | 20min | 2 tasks | 1 files |
| Phase 03-gw-component-library P09 | 35min | 2 tasks | 1 files |
| Phase 03-gw-component-library P10 | 30min | 2 tasks | 1 files |
