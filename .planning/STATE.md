---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
current_phase: 05
current_phase_name: dashboard
status: executing
stopped_at: 05-04 markets walk APPROVED (both modes, 2026-07-20); next = 05-05 news
last_updated: "2026-07-20T13:10:00.000Z"
last_activity: 2026-07-20
last_activity_desc: 05-04 markets walk approved (after value-color + search-icon fixes); next = 05-05 news
progress:
  total_phases: 4
  completed_phases: 3
  total_plans: 28
  completed_plans: 24
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-07-15)

**Core value:** Users can safely custody their keys and reliably perform core wallet actions.
**Current focus:** Phase 05 — dashboard

## Current Position

Phase: 05 (dashboard) — EXECUTING
Plan: 2 of 6
Status: Ready to execute
phase's load-bearing claim, human-walked, all 3 shadow surfaces confirmed)** = PASS. Criteria 1, 3, 6
= PARTIAL with named accepted gaps, NOT hidden ones. See `03-VERIFICATION.md`.
**Carried into Phase 4 (do not lose):** the light-mode dark-only COUNT is NOT DERIVABLE until
`theme.dart` is wired — wire it EARLY, before re-skinning any screen, then re-walk the gallery.
Branch: `ui-redesign-port` (off develop) — `branching_strategy: none`, phases land here
Last activity: 2026-07-20 — 05-04 markets walk APPROVED (both modes); next = 05-05 news

Progress: [█████████░] 86% (2 of 11 phases)

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
- [Phase ?]: theme.dart reconciled key-by-key against Alex's reference (not a wholesale swap); onError kept as develop's original Colors.white rather than adding Alex's foundationWhite token outside this plan's file scope; outlinedButtonTheme.foregroundColor made appearance-aware (textPrimary, was hardcoded white) so sdk_account_manager.dart's footer buttons stay legible in light mode
- [Phase ?]: colorScheme.errorContainer/onErrorContainer/scrim/surfaceDim/surfaceContainerHigh/onSurfaceVariant dropped from theme.dart's ColorScheme, matching Alex's reference and relying on Material 3's computed defaults; pin_screen.dart's errorContainer read still resolves to a reasonable value
- [Phase 05]: DashboardScrollContainer's mandatory GWColors read is bound to GWDecorations.surface's border: parameter — GWDecorations.surface takes no surface-color argument (fill comes from the appearance-aware surfaceSheen getter), so binding gw.borderSubtle to border: keeps the Theme dependency live-flip requires while giving the read a real consumer instead of an unused local
- [Phase 05]: Canonical loading.dart keeps develop's if (text != null) guard rather than the shadow's text ?? empty-string — The shadow renders an unconditional AutoSizeText, which would paint an empty text box on every text-less call site (most of the 19 importers); token choices ported, structure preserved
- [Phase ?]: 05-02: UI-SPEC 3.1's toggle pairing (selectedColor textPrimary over fillColor brandPrimary) fails WCAG AA at 1.96:1 in dark mode; substituted textOnBrand (10.12:1). 3.1's table should be corrected for 05-03..05-06.
- [Phase ?]: 05-02: GWAnimatedNumber currency prefix sourced from NumberFormat.simpleCurrency().currencySymbol, not hardcoded, preserving develop's locale-aware balance rendering.

### Pending Todos

- Phases 2–10 are UI phases (`ui_phase: true`, `ui_safety_gate: true`) — each should get a UI-SPEC design contract via `/gsd-ui-phase` before planning
- Corrected the v1 requirement count in REQUIREMENTS.md: 22 → 24 (previous count was wrong)
- [ui] Design system has no light-mode treatment (`.planning/todos/pending/2026-07-17-design-system-has-no-light-mode-treatment.md`) — scope unknown; 03-09's both-mode walk produces the count
- [ui] Const widgets re-skin — mechanism FIXED by 04-02 (GWColors ThemeExtension; 11 components migrated) (`.planning/todos/pending/2026-07-18-const-widgets-do-not-re-skin-on-live-appearance-toggle.md`) — stays open only for the ~13 deferred readers, migrated opportunistically during 04-03..07 re-skins.
- [ui] Bundle Inter font — RESOLVED by 04-02 Task 3 (Inter bundled, network path removed); moved to todos/completed/.
- [ui] Dark-mode disabled-state visibility — checkbox + switch (`.planning/todos/pending/2026-07-18-dark-mode-disabled-state-visibility-checkbox-switch.md`) — D-02 re-walk finding; disabled GWCheckbox invisible + disabled GWSwitch = looks off, in dark. WCAG contrast. Gap-closure.
- [ui] AppScreenView blank in dark (`.planning/todos/pending/2026-07-18-appscreenview-blank-in-dark.md`) — D-02 re-walk finding; "Screen wrappers" section renders empty in dark. Gap-closure.
- [ui] No user-facing appearance toggle (`.planning/todos/pending/2026-07-18-no-user-facing-appearance-toggle.md`) — setMode only in dev Gallery/token-probe; add an Appearance row to Settings (04-05).
- [ui] **PRODUCT/IA decision** — Mobile nav: curate bottom nav to most-used, overflow the rest (`.planning/todos/pending/2026-07-18-mobile-nav-ia-curate-bottom-nav.md`) — 04-03 kept develop's 8 destinations per "re-skin never restructure"; 8 is poor mobile UX. Restructure like Alex's Gen-B curated nav, keep all 8 reachable. Deferred product decision, NOT a re-skin.
- [ui] Account-row UX polish (`.planning/todos/pending/2026-07-18-account-row-ux-polish.md`) — 04-04 walk feedback: whole row tappable to select (don't block ⋮), truncate address, balance format ("0 minions" zero / ≤3 decimals).
- [ui] Drawer/dialog padding-spacing polish (`.planning/todos/pending/2026-07-18-drawer-dialog-padding-spacing-polish.md`) — 04-04 walk: cosmetic spacing pass.
- [ui] SDK account manager UX polish (`.planning/todos/pending/2026-07-18-sdk-account-manager-ux-polish.md`) — 04-06 walk: disable add-dialog confirm until valid mnemonic/private-key; add a drawer loading state.
- [ui] CTA hover state is over-rounded (`.planning/todos/pending/2026-07-20-cta-hover-state-is-over-rounded.md`) — 05-01 walk. Radius tokens match the Figma export exactly, so this is wrong-token-applied, not wrong-token-value. Design does not settle it: `gnus-mockups.html` defines zero `:hover` rules. Needs an answer from Alex before any code change.
- [general] Second app instance shows a silent black window (`.planning/todos/pending/2026-07-20-second-app-instance-shows-a-silent-black-window.md`) — 05-01 walk. Hive grants its container lock to one process; later ones hang before first paint with no error, no log, no dialog. Cost real debugging time — the black window was first mistaken for a rendering regression. Aggravated by the login-item entry that installs silently when a desktop build runs. Same condition tripped CoinGecko 429 (each instance runs the finding-14 60s timer); degradation to cache behaved correctly.
- [ui] ✅ RESOLVED 2026-07-20 — Dev tooling moved to draggable bubble (quick bgl, walked) → todos/completed.
- [ui] ✅ RESOLVED 2026-07-20 — Header/balance light-mode legibility fixed at the root (quick eu9: btnFilter appearance-aware app-wide + token migrations + branded CTAs, walked) → todos/completed.
- [ui] Expand dev Mock section — transactions + more injectors (`.planning/todos/pending/2026-07-20-expand-dev-mock-section-more-injectors.md`) — LATER, incremental as each screen is walked. Mock-holdings injector (quick cw8) done; add transactions (reuse dev_overrides fakes) for 05-06, etc.

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
- The D-02 gallery re-walk (04-01 Task 3) is OUTSTANDING -- no Windows GUI access from this execution environment. Must be performed by the user before any 04-02+ shell/screen re-skin plan begins. Exact recipe in 04-01-SUMMARY.md's 'Outstanding' section.
- 05-01 must_have 'container flips LIVE on an in-place appearance toggle' — was UNVERIFIABLE (setMode() only on dev screens). **UNBLOCKED for dev walks 2026-07-20** by quick task 260720-bgl: the dev-tools bubble now carries an in-place light/dark toggle usable over ANY screen, so live-flip is verifiable in `GW_DEV_TOOLS=true` builds without navigation. Used to pass 05-02's D5 clause; the same path re-verifies 05-01 / 04-02 / 04-04. NOTE: this is a DEV affordance — the **product** user-facing toggle (todo 2026-07-18-no-user-facing-appearance-toggle.md, still verification-blocker for shipping) remains open.

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 260720-bgl | Move dev tooling out of the top bar into a draggable dev-only overflow bubble | 2026-07-20 | a91aec0 | [260720-bgl-move-dev-tooling-out-of-the-desktop-top-](./quick/260720-bgl-move-dev-tooling-out-of-the-desktop-top-/) |
| 260720-cw8 | Dev-only offline mock-holdings injector (4 bubble scenarios) so the dashboard can be walked with a non-empty wallet | 2026-07-20 | 35e40d2 | [260720-cw8-add-a-dev-only-mock-holdings-injector-so](./quick/260720-cw8-add-a-dev-only-mock-holdings-injector-so/) |
| 260720-dty | Sectionize the dev-tools bubble into 4 collapsible sections (Mock/Test flows/Navigate/Appearance) + light-mode legibility fix; deleted 4 orphaned Test*/DevToolsWidget files; buttons → branded GWButton | 2026-07-20 | 2c1527f | [260720-dty-sectionize-the-dev-tools-bubble-into-col](./quick/260720-dty-sectionize-the-dev-tools-bubble-into-col/) |
| 260720-eu9 | Fix header + current-balance light-mode legibility: root theme fix (btnFilter → appearance-aware, fixes all bare TextButtons app-wide) + per-widget token migrations (reown/sgnus/network/account) + SubmitJob & Buy GNUS → branded GWButton | 2026-07-20 | 6324d09 | [260720-eu9-fix-light-mode-legibility-of-header-and-](./quick/260720-eu9-fix-light-mode-legibility-of-header-and-/) |
| 260720-gzq | Fix clipped surface-card shadows: markets grid spacing/padding + mobile one-column dashboard ListView padding/section spacing (shadow blurRadius 16 needs clearance); desktop layouts + shared decoration untouched | 2026-07-20 | 655aa93 | [260720-gzq-fix-clipped-surface-card-shadows-on-the-](./quick/260720-gzq-fix-clipped-surface-card-shadows-on-the-/) |
| 260720-ipg | Add shared GWPageHeader (headlineLg/gw.textPrimary, left-aligned, optional trailing, space8 gap) and unify Markets/News/Swap in-body page titles onto it (News was unmapped displaySmall outlier; Swap was raw centered white) | 2026-07-20 | 905a2a9 | [260720-ipg-add-a-shared-gwpageheader-and-unify-the-](./quick/260720-ipg-add-a-shared-gwpageheader-and-unify-the-/) |

> **All five 2026-07-20 dev/chrome/visual quick tasks (bgl, cw8, dty, eu9, gzq) WALKED & APPROVED (both light+dark) on 2026-07-20.** gzq=clipped surface-card shadows fixed (markets grid + mobile one-column dashboard), walked desktop + mobile breakpoint. bgl=dev bubble; cw8=mock-holdings injector; dty=sectioned bubble + branded buttons; eu9=header/balance light-mode root fix (btnFilter appearance-aware app-wide) + branded Submit-Job/Buy-GNUS. Resolved todos: `move-dev-tooling-out-of-top-bar-into-overflow-bubble`, `top-bar-action-widgets-render-black-in-light-mode` → moved to todos/completed.

> **APPROVED 2026-07-20.** Blocking human-verify walk passed on a fresh `GW_DEV_TOOLS=true` run: top bar no longer overflows (real widgets only), bubble anchored top-right below header, drags + expands within the viewport, all dev actions reachable, and its light/dark toggle live-re-skins the app. Fix `a91aec0` (top-right anchor + viewport clamp/scroll) followed the initial off-screen-expand report.

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

Last session: 2026-07-20T10:22:32.243Z
Stopped at: 05-04 markets walk APPROVED (both modes, 2026-07-20); next = 05-05 news
Resume file: .planning/phases/05-dashboard/05-02-PLAN.md

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
| Phase 04-navigation-shell-chrome P01 | ~35min | 2 tasks | 4 files |
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 05 P01 | ~20min | 2 tasks | 3 files |
