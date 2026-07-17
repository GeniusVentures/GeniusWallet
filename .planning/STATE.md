---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
current_phase: 3
current_phase_name: GW Component Library
status: executing
stopped_at: Completed 03-06-PLAN.md
last_updated: "2026-07-16T21:57:24.349Z"
last_activity: 2026-07-16
last_activity_desc: Phase 3 execution started
progress:
  total_phases: 11
  completed_phases: 1
  total_plans: 15
  completed_plans: 12
  percent: 9
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-07-15)

**Core value:** Users can safely custody their keys and reliably perform core wallet actions.
**Current focus:** Phase 3 — GW Component Library

## Current Position

Phase: 3 (GW Component Library) — EXECUTING
Plan: 8 of 10
Status: Ready to execute
Branch: `ui-redesign-port` (off develop) — `branching_strategy: none`, phases land here
Last activity: 2026-07-16 — Phase 3 execution started

Progress: [█░░░░░░░░░] 9% (1 of 11 phases)

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

### Pending Todos

- Phases 2–10 are UI phases (`ui_phase: true`, `ui_safety_gate: true`) — each should get a UI-SPEC design contract via `/gsd-ui-phase` before planning
- Corrected the v1 requirement count in REQUIREMENTS.md: 22 → 24 (previous count was wrong)
- [ui] Design system has no light-mode treatment (`.planning/todos/pending/2026-07-17-design-system-has-no-light-mode-treatment.md`) — scope unknown; 03-09's both-mode walk produces the count

### Blockers/Concerns

- **No working automated test harness** (`flutter test` does not compile) — every success criterion in the roadmap is phrased to be observable by running the app. `flutter analyze` is a gate, never evidence. Fixing the harness is deferred to APP-02 (v2)
- Nav shell has never been visually walked — Phase 4 addresses this
- 37 evidenced defects in the design-vs-develop surface (`.planning/REVIEW_FINDINGS_REDESIGN.md`, 3 blockers) are assigned per phase; Phase 11 signs off the full set
- `analysis_options.yaml` excludes `lib/**/*.g.dart` — the compiler, not analyze, is the real gate for generated widgets
- **Alex's design system may have no complete light mode** (2026-07-17, from the 03-07 walk) — `GWCanvasBackground` gates its grain behind `if (!isLight)`; `GWMeshBackground` never reads the appearance and washes out on a light base. Both verified byte-identical to the reference, so **neither is a port defect**. If light mode ships, this hits every screen Phases 4–9 mount. Scope unknown — 03-09's both-mode walk is what produces the real count. Do not fix before that number exists; see the todo for why removing the gate is insufficient

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

Last session: 2026-07-17
Stopped at: Session resumed at Phase 3 plan 7/10 — blocked on the 03-07 gallery walk (human action)
Resume file: .planning/phases/03-gw-component-library/.continue-here.md

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
