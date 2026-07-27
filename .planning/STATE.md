---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
current_phase: 09
current_phase_name: banxa
status: verifying
stopped_at: Completed 09-03-PLAN.md
last_updated: "2026-07-27T16:23:41.593Z"
last_activity: 2026-07-27
last_activity_desc: Phase 09 execution resumed (wave continue)
progress:
  total_phases: 21
  completed_phases: 15
  total_plans: 86
  completed_plans: 76
  percent: 71
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-07-21)

**Core value:** Users can safely custody their keys and reliably perform core wallet actions.
**Current focus:** Phase 09 — banxa

## Current Position

> **DUAL-TRACK (both live on branch `ui-redesign-port`).** This project runs two parallel tracks.
> The frontmatter counters above track only the **official GSD roadmap (Phases 1-11)**.
> - **Official track:** Phase 06 (Onboarding) — **COMPLETE 6/6 (closed 2026-07-23).** Phase 07
>   (Token screens) EXECUTING, 07-03 human walk still blocking (see below). **Phase 08 (Swap &
>   bridge) execution started in parallel 2026-07-25: 08-01 (swap component family re-skin, 3/3
>   tasks) committed — `f5518e9`/`3170623`/`08fd30f`; 08-02 (GlobalSwapFabHost port + mount, 3/3
>   tasks) committed; 08-03 (swap tab assembly, 105 A1, CTA ladder, D-09 route-error state, 3/3
>   tasks) committed; **08-04 (bridge re-skin, 120 B1 swap-twin, CTA ladder, D-11 mechanics
>   preserved verbatim, 3/3 tasks) committed — `befe971`/`d3af5ed`/`8c8548f`; `08-04-SUMMARY.md`
>   written.** analyze lib holds at 59 (≤61 baseline); full test 285/1 (269 baseline + 16 new
>   bridge_cta_state_test.dart tests). Plans 08-05..08-07 NOT yet executed. D-22 descopes Phase 8's
>   human walk at Braian's instruction — do not expect walk evidence for this phase. SCR-04 stays
>   NOT marked complete in REQUIREMENTS.md per 08-04-PLAN.md's explicit instruction — it closes at
>   phase verification (08-07/08-08), not per-plan.**
> - **Redesign track:** Phases 12-18 landed in parallel. Committed status: **12 (6/6 ✓ — dark walk
>   APPROVED 2026-07-24, light deferred; 12-06-SUMMARY written, UNCOMMITTED)**,
>   **13 — WRAPPED 2026-07-24 as 13-01/02/03 (all plan+SUMMARY done). 13-03 boot walk APPROVED
>   incl. kicker→C @85%. 13-04 (per-section loader removal) and 13-05 (closeout) DELETED at
>   Jakub's call: he chose to KEEP the loaders (13-04 code was written then fully reverted). Two
>   knock-ons left in the tree by that choice: the `[boot-timing]` debugPrint stays in
>   wallet_details_cubit.dart (13-05 would have removed it), and the phase's network-down cold
>   start (SC3) was never walked. Neither is a blocker; both are conscious**,
>   **15 (6/6 ✓ — dark walk APPROVED 2026-07-24 all 3 checkpoints; 15-06-SUMMARY written, light
>   deferred)**, **16 Markets shipped (`aa78eec`), walk PENDING**, **17 News shipped (`651541c`),
>   dark walk APPROVED 2026-07-24 (17-VERIFICATION.md written, light deferred)**;
>   14 is design-only (unplanned); **18 Web tab chrome added 2026-07-24 — sketched (035-B/036-A/037-B),
>   NOT planned yet.** See ROADMAP Phases 12-18 for detail.
>   Walk order this session (Jakub): 12 → 15 → 16 → 17 (walk-only), then 13 (code). Light = one
>   dedicated app-wide pass after dark, per the light-verification-backlog todo.

Phase: 09 (banxa) — EXECUTING
Plan: 09-01 of 7 COMPLETE (`b479266`/`9c246e3`; test/banxa/ floor + shared order-status ladder;
analyze lib 59/59, test 389/1 = 376 baseline + 13 new). 09-02..09-07 not yet executed.
drifts independently of the phases dir per the project's dual-track note; verify against
`.planning/phases/08-swap-bridge/*-SUMMARY.md` rather than trusting it at face value.
fresh-install end-to-end walk PASSED all four ROADMAP criteria (RUN A create dark+light, RUN B import;
no onboarding overflow; clean seed/PIN console). See `06-06-SUMMARY.md`. **Next: Phase 07 (Token
screens), not yet planned.** Historical note preserved below records the 06-01 walk detail.
Status: Phase complete — ready for verification
2026-07-21.** Walked and APPROVED on a genuine fresh install — all four independent wallet
persistence layers cleared (it took four attempts; see
`.planning/todos/pending/2026-07-21-four-independent-wallet-persistence-layers-with-no-documente.md`).
What was walked: entry screen in dark (mesh background, branded `GWButton` CTAs, nothing clipped);
narrow/mobile width (originally FAILED — see below — then re-walked clean); wide-window regression
(confirmed unchanged); **the blocking mesh light-mode gate**; the inherited secondary-button
light-mode concern (re-verified, already closed); both flow shells' flattened AppBars and back
navigation. Console evidence across every relaunch: zero `RenderFlex overflowed`, zero exceptions,
zero `LateInitializationError`.

**Walk-driven fix (Rule 1, commit `67e2821`):** the walk found `wallet_creation_screen.dart`'s CTAs
glued to the window bezel with zero gutter at narrow widths — `ConstrainedBox(maxWidth:)` only
constrains when the viewport is *wider* than it. Fixed with `Padding(EdgeInsets.symmetric(
horizontal: GeniusWalletConsts.space8))` wrapped *outside* the existing `ConstrainedBox`, so the
gutter is additive to (never a replacement for) the max-width centring; re-walked clean, and the
wide-window layout confirmed unchanged by construction. Pre-existing desktop-first assumption, not
introduced by this plan — but this plan re-skinned the screen and the walk is its own gate.

**Design decision, recorded because it was a live gate with a real alternative, not a formality:
`GWMeshBackground` is KEPT on `/landing_screen` in light mode.** The pre-named fallback (drop the
mesh, let the wired `scaffoldBackgroundColor` stand) was NOT taken — the user judged the mesh live
in light mode and it read acceptably. This matters because this same component is one of two this
project has flagged as dark-only-by-design (see Blockers/Concerns below); this is the first time
anyone has actually looked at it live in light mode on a real screen, rather than waiving it on the
strength of the earlier finding, and it is now an explicit per-consumer decision, not an assumption.

**Carried forward for 06-02 (do not rediscover):** the systemic mobile-gutter finding —
`legal_screen.dart` and `select_wallet_type_screen.dart` (both owned by 06-02) are confirmed
breakpoint-constrained with zero horizontal inset, the same class of bug `wallet_creation_screen.dart`
just had. Apply the `space8`-outside-`ConstrainedBox` pattern proactively rather than waiting for a
walk to catch it again — see
`.planning/todos/pending/2026-07-21-systemic-mobile-gutter-missing-on-onboarding-breakpoint-cons.md`
for the full per-file breakdown (including two files needing a per-screen check rather than an
assumed fix).

**The fresh-install profile used for this walk is now CONSUMED** — a wallet was created during the
walk. Any later plan needing genuine first-run state must clear all four persistence layers again.

**Carried into Phase 4 (do not lose):** the light-mode dark-only COUNT is NOT DERIVABLE until
`theme.dart` is wired — wire it EARLY, before re-skinning any screen, then re-walk the gallery.
Branch: `ui-redesign-port` (off develop) — `branching_strategy: none`, phases land here
Last activity: 2026-07-27 — Phase 09 execution resumed (wave continue)
gate; one walk-driven Rule-1 gutter fix landed; transitioned to 06-02

Progress: [████████████████████] 36/36 plans (100%) — official track, phases 2-6 (Phase 06 closed 2026-07-23)

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
- [Phase 05 closeout, 2026-07-21]: **User closed Phase 5 with 3 explicit overrides rather than fixes.** Live-inspected the Bitcoin Chart card and confirmed the 34px `crypto_live_chart.dart:315` overflow is a dashboard-card-height limitation (not a component defect — same widget fine at `token_info_screen.dart:130`'s taller slot); rejected the considered stopgap `260721-gx1` (hiding zoom/pan below a 112px threshold) as producing "a non-overflowing broken card, not a fixed one"; directed closing the phase with the gap recorded honestly. Same decision folded in criterion 1's unwalked Release-exe comparison and criterion 2's unwalked pull-to-refresh legs as overrides rather than blockers. See `05-VERIFICATION.md`'s `overrides:`/`## Acknowledged Gaps`.
- [Phase 06-01, 2026-07-21]: **`GWMeshBackground` KEPT on `/landing_screen` in light mode — a live design decision, not a waived assumption.** The plan's Task 3 recipe hardened UI-SPEC §9.1's "if distracting, drop back" into a blocking gate specifically because this component is one of two STATE records as dark-only-by-design (never reads the appearance). The user judged it live in light mode on a genuine fresh-install profile and it read acceptably; the pre-named fallback (drop the mesh, let the wired `scaffoldBackgroundColor` stand) was available and NOT needed. Recorded explicitly so a future reader sees someone actually looked, rather than inheriting the general dark-only finding as a blanket assumption this specific consumer failed.
- [Phase 06-01, 2026-07-21]: **Walk-driven Rule-1 fix — narrow-width zero-gutter on `wallet_creation_screen.dart` (commit `67e2821`).** `ConstrainedBox(maxWidth: GeniusBreakpoints.small * 2/3)` only binds when the viewport is wider than it; below that, `Center`'s loosened constraints collapse to the raw viewport width and the stretch CTA column ran edge-to-edge with zero gutter. Fixed with `Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8))` wrapped outside the `ConstrainedBox` (additive gutter; wide-window centring unchanged by construction). Token chosen from real precedent (`submit_logs_screen.dart`'s identical structural shape, `markets_screen.dart`'s page-edge `space8` gutter) rather than invented. Same-class bug confirmed present in `legal_screen.dart` and `select_wallet_type_screen.dart` (06-02's files) — see `.planning/todos/pending/2026-07-21-systemic-mobile-gutter-missing-on-onboarding-breakpoint-cons.md`.
- [Phase 08-01, 2026-07-25]: **Swap component family re-skinned; RouteDetailsCard's four figures golden-locked before repainting.** `GWPageHeader` gained an additive, nullable `subtitle` (unused by any caller this plan — 08-03 consumes it). `TokenFlipButton` moved from a Material FAB to a 44px brandCta InkWell seam control, `AnimatedRotation`/`onFlip` untouched. `SwapField` re-skinned with the D-07-locked 38px hero amount, a new MAX affordance driving the EXISTING `onChanged` pipeline (no second quote path), and a USD line that is omitted — never zeroed — when `fiatValue()` has no price. `RouteDetailsCard` and `TokenSelectorDrawer` re-skinned; a new `test/squid_router/route_details_card_test.dart` proves the card's derived strings (`1 ETH ~ 0.995 USDT` / `0.5` / `0.51%` / `$0.30`) are unchanged by the paint job, run against the real `mockSquidRoute` constant both before and after — this is ROADMAP criterion 1's automated half (D-18b: the quote is a hardcoded mock, not a live route). `flutter analyze lib` 59 (≤61 baseline); `flutter test` 249/1 (248 baseline + this new test). See `08-01-SUMMARY.md`.
- [Phase ?]: AI-FAB half stripped from GlobalSwapFabHost port (D-18a); _ready guard and its rationale comment preserved verbatim
- [Phase 08-swap-bridge]: 08-03: CTA colour mapping followed PLAN's literal grouping (enterAmount/findingRoute/submitting share surfaceMenu+textPrimary38) over UI-SPEC's slightly more granular table, per plan's own prohibitions text
- [Phase 08-swap-bridge]: 08-03: Only ready/routeError CTA rungs use real GWButton(gradient); other four rungs use a hand-rolled fixed-size control since gw_button.dart was out of file scope and no variant matches surfaceMenu/statusError-alpha fills
- [Phase 08-swap-bridge]: 08-03: Seam flip control positioned via Stack(alignment: Alignment.center) around a Column of the two cards -- no Positioned/pixel math, eliminating the -170 offset hack per D-07's own signal
- [Phase 08-swap-bridge]: 08-04: bridge_cta_state.dart's ladder treats a null balance as insufficientBalance (not swap's "never accuse on missing data" rule) -- mirrors bridge's own precheck (`fromToken?.balance == null` already returns before any API call in develop)
- [Phase 08-swap-bridge]: 08-04: Ready CTA label locked to "Bridge" (develop's own word), not the UI-SPEC's alternative "Review bridge" -- no second confirmation step exists on this screen
- [Phase 08-swap-bridge]: 08-04: bridgeOut(... shouldMintTokens: true) and getBrigeOutGasCost(...) confirmed byte-identical to develop -- only isEstimating/isSubmitting (added state) wrap the real calls; no argument, guard, or precheck touched (D-11)
- [Phase 08-05]: Task 3 (swap_settings_drawer.dart re-skin, D-13) skipped as superseded -- sketch 063-A already landed on the file 2026-07-26, before this execution, per the plan's own banner; re-verified live (zero ElevatedButton/Ink matches, footer already GWButtonVariant.gradient)
- [Phase 08-05]: swap_screen.dart: fees blanked ('' instead of fromAmount) on the swap Transaction; transaction_displays.dart's Network Fee row now skips a blank fees, mirroring the Rate row's existing skip-empty contract
- [Phase 08-06]: bridge_receipt.dart's doc comment reworded to avoid literal tokens (BuildContext/TransactionsCubit/TransactionStorageService) its own purity grep checks for -- same meaning, doesn't trip the gate
- [Phase 08-06]: Dropped go_router, scaffold_helper.dart, and flutter/services.dart imports from bridge_screen.dart (all three were referenced only inside the deleted AlertDialog); flutter analyze confirms zero issues
- [Phase 08-06]: Failure toast surfaces bridgeTokensResponse.errorMessage when present, falling back to develop's own string -- the shared receipt has no free-text error slot
- [Phase ?]: gwBothModes declared final not const -- GWColors.dark()/.light() are non-const factories with a debug-mode assert
- [Phase ?]: 09-01: MaterialApp wraps content in an implicit AnimatedTheme -- widget tests switching GWColors host across sequential pumpWidget() calls need pumpAndSettle(), not a bare pump(), or they read the pre-transition theme value
- [Phase ?]: order_card.dart's title/pill Row and action-button Row wrapped in Expanded+Align to guard against test-font overflow while preserving all button variants/gating (D-01)
- [Phase ?]: Orders-history empty-state filter-active predicate: selectedStatus.isEmpty && startDate == null && endDate == null
- [Phase ?]: quote_card_test.dart's dark/light divergence check reads gw.textSecondary, not gw.textPrimary -- textPrimary is mode-invariant across GWColors.dark()/.light() by construction (same root-cause class as 09-01's statusWarning finding).

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
- [ui] ✅ RESOLVED 2026-07-20 — Dashboard live-chart 6.3px overflow, fixed and walked by quick task `260720-uhe` (compact-mode price text + assert in `crypto_live_chart.dart`); `.planning/todos/pending/...` → `todos/completed/`. Root cause was the inflexible price `AutoSizeText` in the two-column breakpoint, NOT `gzq` (that attribution was retracted; `gzq` is clean). Debug painted stripes; release silently clipped. `uhe` also harmonised dashboard spacing to one `space4` (8px) token.
- [ui] ⚠️ ACCEPTED AS PHASE 5 OVERRIDE 2026-07-21 — Chart zoom/pan row 34px overflow (`.planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md`) — the considered stopgap (quick `260721-gx1`) was abandoned by user decision (would have shipped "a non-overflowing broken card, not a fixed one"); recorded as an override in `05-VERIFICATION.md` instead. Stays in `todos/pending/` — the three-way convergence analysis (overflow + raw-`Colors.white` icons + zoom/pan-redundancy question) is unresolved.
- [ui] **NEW 2026-07-21** — Bitcoin Chart card has no vertical room at ordinary window sizes (`.planning/todos/pending/2026-07-21-bitcoin-chart-card-height-dashboard-vertical-budget.md`) — the actual root cause behind the overflow above; a `dashboard_screen.dart` sizing/product decision, user-confirmed by live inspection 2026-07-21. Measured: inner slot `h=6.5` where content needs ~40.5; `token_info_screen.dart:130` gives the same widget a much larger slot and is fine.
- [ui] **NEW 2026-07-21** — Systemic mobile gutter missing on onboarding breakpoint-constrained screens (`.planning/todos/pending/2026-07-21-systemic-mobile-gutter-missing-on-onboarding-breakpoint-cons.md`) — 4 screens (`legal_screen.dart`, `select_wallet_type_screen.dart`, `import_security_screen.dart`, `pin_screen.dart`) share the `ConstrainedBox(maxWidth:)`-with-no-inset defect 06-01 already found and fixed on `wallet_creation_screen.dart` (commit `67e2821`, Padding-outside-ConstrainedBox pattern). Owned by plans 06-02..06-05.
- [general] **NEW 2026-07-21** — Four independent wallet persistence layers with no documented reset (`.planning/todos/pending/2026-07-21-four-independent-wallet-persistence-layers-with-no-documente.md`) — Hive boxes, native SuperGNUSNode dir, `flutter_secure_storage.dat` (file-based on Windows, not Credential Manager), `shared_preferences.json`. Took 4 attempts to reach a genuine fresh install. Blocks 06-06's per-run cleared-profile walk requirement.
- [general] **NEW 2026-07-21** — `com.example` scaffold namespace ships as the secure-storage data directory (`.planning/todos/pending/2026-07-21-com-example-scaffold-namespace-ships-as-the-secure-storage-d.md`) — `windows/runner/Runner.rc` still has Flutter's placeholder `CompanyName`/`ProductName`, so seeds/keys/PIN live under `%APPDATA%\com.example\genius_wallet\`. Shipping-hygiene issue, not a vulnerability; any fix needs a data-directory migration or it will orphan existing users' wallets.
- [ui] **NEW 2026-07-23 (06-06)** — GWButtonVariant.secondary as text in light mode — VERIFY, don't assume 1.93:1 (`.planning/todos/pending/2026-07-23-gwbutton-secondary-variant-light-mode-text-aa.md`) — owner `gw_button.dart`, not onboarding. The plan's inherited 1.93:1 AA-failure premise is STALE: quick task `260721-fa7` already repointed the secondary foreground to appearance-aware `brandPrimaryOnSurface` (light `#0A6885`, 4.76:1). Remaining work is the LIVE light-mode walk only (06-02 walked dark), already tracked by the light-mode-verification-backlog todo item 4.
- [security] **NEW 2026-07-23 (06-06)** — No screenshot/screen-recording protection on the seed screens (`.planning/todos/pending/2026-07-23-no-screenshot-or-recording-protection-on-seed-screens.md`) — owner the platform layer / `main.dart`. develop has no secure-window flag anywhere, so the recovery-phrase/verify screens render the seed in the clear to any OS screenshot/recorder/remote-desktop whenever it is visible (the default). Phase 6's re-skin neither adds nor removes it; adding one is a new capability, no ROADMAP criterion names it. Recorded so the absence is on the record (UI-SPEC §3.5).
- [general] **NEW 2026-07-23 (06-06)** — Dead onboarding route `/backup_phrase` + unreachable `BackupPhraseScreen` (`.planning/todos/pending/2026-07-23-dead-backup-phrase-route-and-unreachable-backupphrasescreen.md`) — owner `wallet_routes.dart` + `backup_phrase_screen.dart`. Registered at `GoRoute(path: '/backup_phrase')` but reached by nothing; `NewWalletStep` has no case/enum value for it. Scope-fenced by Phase 6 (§5.1, zero diff). Future milestone: delete both, or wire it into the flow.
- [ui] **NEW 2026-07-23 (06-06)** — `PasteField.height` declared/defaulted/passed but never read (`.planning/todos/pending/2026-07-23-pastefield-height-parameter-declared-but-never-read.md`) — owner `paste_field.dart`. The Address tab passes `height: 150` with no effect. 06-04 left it inert on purpose (honouring it would be a layout change under a re-skin). Decide: wire it, or delete the parameter + its one call-site argument.
- [security] **NEW 2026-07-23 (06-06)** — Import screen's `TextEditingController`s built per-build and never disposed while holding key material (`.planning/todos/pending/2026-07-23-import-screen-controllers-per-build-never-disposed.md`) — owner `import_security_screen.dart`. Five key-bearing controllers (four paste fields + keystore password) created inside `build()`; a StatelessWidget so no `dispose()`. Pre-existing on develop; not fixed here because the fix is a StatelessWidget→StatefulWidget restructure "re-skin never restructure" forbids. Cites the 06-04 walk step 10 typed-text-preserved observation.
- [ui] **NEW 2026-07-25 (18)** — Web tab URL bar cannot overwrite a selection, macOS only (`.planning/todos/pending/2026-07-25-web-tab-url-bar-cannot-overwrite-a-selection-on-macos.md`) — owner `lib/web/web_view_mobile.dart`. Typing at a collapsed caret works; typing OVER a selection is silently dropped with zero keyboard assertions. WKWebView ↔ Flutter text-input conflict on the "replace selection" path — engine-level, not app logic. **Does NOT reproduce on Windows (WebView2); needs a macOS machine.** Two fixes already tried and FAILED (sync select-all, post-frame select-all); shipped state is a collapsed caret at end, which is a mitigation not a fix — Jakub still considers it open. Was recorded ONLY in `HANDOFF-session-260725-web-omnibox-markets.md` until captured here.
- [ui] **NEW 2026-07-25 (19)** — No dev fault injector for the feedback/Sentry failure paths (`.planning/todos/pending/2026-07-25-dev-fault-injector-for-feedback-sentry-failure-paths.md`) — owner `lib/dev/dev_fault_injector.dart` + `lib/logs/submit_logs_screen.dart`. 3 of the Feedback tab's 6 states (No-SDK, Failed-exception, Failed-emptyId) are unreachable in a normal run, so the 2026-07-25 phase-19 walk rendered only 3 of 6 and the **error-red status line was never light-mode AA-checked** (it only paints in a Failed state). Same wall as 05-08's Markets branches → mirror that fixture (`DevFaultInjector.marketsFault`, commit `3364259`). Recorded as `uncovered_by_walk` in `19-VERIFICATION.md`.
- [ux] **NEW 2026-07-25 (8)** — **PRODUCT/IA decision** — Surface the bridge entry as a first-class action (`.planning/todos/pending/2026-07-25-surface-the-bridge-entry-as-a-first-class-action.md`) — owner `token_info_screen.dart` + `router.dart`. Bridge is reachable only via GNUS token → More → "Bridge Tokens"; a back-arrow sub-screen, GNUS-only, disabled at zero balance. Raised by the sketch-120 design session, **deliberately deferred out of Phase 8 by Braian 2026-07-25** — promoting it is an IA restructure, not a re-skin, and ROADMAP's 4 Phase-8 criteria don't cover discoverability. Pairs with the deferred [ui] mobile-nav-IA item; decide them together.

### Blockers/Concerns

- ~~**No working automated test harness** (`flutter test` does not compile)~~ — **FALSE. CORRECTED 2026-07-21 by direct measurement.** `flutter test` compiles and runs on this branch: **248 tests pass, 1 fails** (re-measured 2026-07-25; was 234 on 2026-07-23, then 250 before the Phase-18 `webTabCanClose` cleanup removed 2;

the redesign track added many test files since the original 14-test snapshot). **The single failure is not a compile failure** — `local_wallet_storage_test.dart` is *entirely commented out* (every line prefixed `//`, no `main()`), so Flutter reports "Missing definition of `main` method". Someone read that one message as "the harness doesn't compile" and the belief was never re-tested.
  **Cost of the error:** this constraint was carried into every phase plan, every verification report, and every agent brief in this milestone. It is why Phase 05 needed six human walks, why `verify:` blocks were written around a human being available, why "analyze is a gate, never evidence" became doctrine, and why APP-02 was deferred to v2 as if building a harness — when it is uncommenting one file. **Real test gates are available now.** Prefer them over grep gates wherever behaviour can be asserted; keep human walks for what only eyes can judge (visual fidelity, contrast in situ, feel).
  Caveats that ARE real: `token_info_loader_test.dart` makes live network calls to a GitHub URL that intermittently 404s, so it is flaky in CI-like conditions though it passed 9/9 in isolation here; and per-file invocation (`flutter test <path>`) compiles only that file's import closure, so it is the fast path for a focused gate.
  Toolchain, also previously mis-recorded as missing: Flutter **3.41.9 / Dart 3.11.5** at `C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin\flutter.bat` (off `PATH`). `flutter analyze lib` baseline = **61 issues**.

- Nav shell has never been visually walked — Phase 4 addresses this
- 37 evidenced defects in the design-vs-develop surface (`.planning/reference/REVIEW_FINDINGS_REDESIGN.md`, 3 blockers) are assigned per phase; Phase 11 signs off the full set
- `analysis_options.yaml` excludes `lib/**/*.g.dart` — the compiler, not analyze, is the real gate for generated widgets
- **Two components are dark-only by design** (2026-07-17, from the 03-07 walk) — `GWCanvasBackground` gates its grain behind `if (!isLight)`; `GWMeshBackground` never reads the appearance and washes out on a light base. Both verified byte-identical to the reference, so **neither is a port defect**. ~~Alex's design system may have no complete light mode~~ — **CORRECTED same day: FALSE.** Alex's `theme.dart` IS appearance-aware (`brightness: isLight ? Brightness.light : Brightness.dark`); light mode is a real designed feature. These two are deliberate dark-only choices *within* a working light mode. Scope of dark-only components still unknown — 03-09's both-mode walk produces the count. Do not fix before that number exists; see the todo for why removing the gate is insufficient. **UPDATE 2026-07-21 (06-01):** `GWMeshBackground` got its first real consumer (`/landing_screen`, `wallet_creation_screen.dart`) and its light-mode readability was walked LIVE, not assumed — 06-01's Task 3 hardened this into a blocking gate with a pre-named fallback (drop the mesh). It PASSED; the mesh is KEPT on this screen in light mode. This resolves nothing about the general dark-only census (still 03-09's open item) but establishes the precedent: each new consumer of a dark-only-flagged component needs its own live light-mode judgment call, not an inherited assumption either way.
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
| 260720-jvr | Add dev Mock-transactions injector (bubble MOCK section "Mock txns": varied offline batch — sent/received/failed/long-value — into TransactionsCubit + SGNUS controller; Clear extended) so the 05-06 transactions view is walkable on any wallet | 2026-07-20 | e127935 | [260720-jvr-add-a-dev-mock-transactions-injector-so-](./quick/260720-jvr-add-a-dev-mock-transactions-injector-so-/) |
| 260720-k81 | Transaction-area polish (05-06 walk): badge white border+arrow on colored fill; row inter-spacing + shadow clearance (fixes dashboard tx card too); detail drawer shows plain data (no inner card); un-clip drawer close button (ResponsiveDrawer radius 28→24 + leading inset, shared) | 2026-07-20 | b4a6d92 **+ 2c7db8a** (badge white-border/arrow — the second commit; caused 05-VERIFICATION Gap 1, since reverted to `textOnBrand` at HEAD) | [260720-k81-polish-transaction-rows-and-detail-drawe](./quick/260720-k81-polish-transaction-rows-and-detail-drawe/) |
| 260720-uhe | Harmonise dashboard section spacing to one token + **add new `space3`=6px token** (dialed in live 16→8→4→6; 6px made an official 2-pt half-step rather than hardcoded — the one exception to the 4-pt grid) + fix the two-column live-chart RenderFlex overflow (compact-mode price text + assert). WALKED & APPROVED both modes. Touches `genius_wallet_consts.dart` (new token), `dashboard_screen.dart`, `crypto_live_chart.dart`. | 2026-07-20 | 0bcf3df (PR #210) | [260720-uhe-harmonise-dashboard-spacing-restore-chart-height](./quick/260720-uhe-harmonise-dashboard-spacing-restore-chart-height/) |
| 260726-0z4 | Control-track standard (`surfaceSunken` + hairline + radiusPill + 3px pad) filed in `.planning/codebase/CONVENTIONS.md` and the two TRIAL comments de-trialed to cite it; page titles moved to the page's left edge on Feedback (`submit_logs_screen.dart`) and Swap (`swap_screen.dart`) to match Transactions/Markets/News — the 560px card column of sketch 105 A1 is preserved by construction. Ran WITHOUT commits and WITHOUT worktree isolation: CLAUDE.md's "Do not create commits" overrides the workflow's atomic-commit gate, and worktree isolation cannot deliver changes back without them. `analyze lib` held at 59; `submit_logs_feedback_test.dart` + `route_details_card_test.dart` pass. Human walk of both tabs PENDING. | 2026-07-26 | _uncommitted (per CLAUDE.md)_ | [260726-0z4-standard-toru-kontrolek-surfacesunken-ty](./quick/260726-0z4-standard-toru-kontrolek-surfacesunken-ty/) |
| 260721-0ze | App-wide brand-consistency sweep — killed flat neon `#14C8FF` as CTA fill + highlight everywhere (validate mode: plan-checked PASS + goal-backward grep). Primary CTA variant → brand gradient (central, propagates to all primary buttons); header Buy GNUS `secondary`→`gradient`; desktop nav active underline → `brandCta` gradient + active text/icon → `brandPrimaryStrong`; mobile bottom nav selected → `brandPrimaryStrong`; theme.dart (tabBar indicator, datePicker header/selected-day, focus borders, navRail, bottomNav, checkbox) + per-widget selections (Transactions segment, GNUS/Minions toggle, account/SDK selected rows, switch, text-field/select focus, checkbox) → `brandPrimaryStrong`. 11 files, `flutter analyze` clean (2 pre-existing info deprecations). Light-mode AA for `#0AAEE6` deferred to light pass (dark-first). WALK PENDING. | 2026-07-21 | 0bcf3df (PR #210) | [260721-0ze-brand-consistency-sweep-kill-flat-neon-1](./quick/260721-0ze-brand-consistency-sweep-kill-flat-neon-1/) |
| 260720-vwj | Redesign dashboard Assets panel per approved sketch 001 (A2 market-forward + stacked header + center gap): renamed "coins"→"Assets" with new stacked header (total + 24h $·% subline, reserved 2-line height so empty/funded gaps match); A2 rows (price+24h% chip subtitle at full strength, fiat/amount right column, `networkSymbol`, NO sparkline); killed "No balance yet" (zero rows show real `0.0000`/`$0.00`, only holding numbers dimmed); empty-wallet Receive/Buy-GNUS footer; light-mode AA fixes (textSecondary/statusSuccess/statusError appearance-aware on GWColors) + gains on statusSuccess not cs.primary. `flutter analyze` clean, `assets_totals_test` passes. dark walk approved; CTA hover=brighten+cursor; light-mode pass deferred. | 2026-07-20 | 0bcf3df (PR #210) | [260720-vwj-redesign-dashboard-assets-panel-per-sket](./quick/260720-vwj-redesign-dashboard-assets-panel-per-sket/) |
| 260721-bxr | Two locked dashboard fixes: **Nav tab "C"** (sketch 002-C: inset box shrunk 52→**44px**; underline regrouped into a centered `Column(min, stretch, [Row(icon,label), SizedBox(4), AnimatedContainer])` so the gradient underline rides ~4px UNDER the label — via `IntrinsicWidth`+`CrossAxisAlignment.stretch` it still tracks icon+label width; **active tab shows NO hover box** via `InkWell.overlayColor: isSelected ? WidgetStatePropertyAll(Colors.transparent) : null`, non-active tabs keep the inset box; preserved brandCta gradient/rounded-top/gradient-XOR-color guard, `brandPrimaryStrong@0.5` blur-10 glow, white active text/icon `gw.textPrimary`, icon 23, `hideLabels` branch — no ClipRect added, glow clearance from the 4px gap, ClipRect noted walk-tunable if spill seen); **Unified section-header height** (`GWSectionTitle` Row wrapped in `ConstrainedBox(minHeight:44)` so Assets/Markets/Transactions/Bitcoin-Chart share ONE title→top + title→first-row geometry; removed the redundant call-site `ConstrainedBox(minHeight:45)` from `coins_screen` Assets header, total/24h Column passed directly as trailing — empty↔funded 2-line stability preserved). 3 files, `flutter analyze` clean ("No issues found!"). WALK PENDING (dark: nav active/hover + 4 panel headers). | 2026-07-21 | 0bcf3df (PR #210) | [260721-bxr-nav-tab-design-c-inset-box-underline-clo](./quick/260721-bxr-nav-tab-design-c-inset-box-underline-clo/) |
| 260721-ch1 | Replace the Markets panel header's dead "Top {n}·24h" filler with the approved **editorial "View all" link** (sketch 003-markets-panel, variant **D**). New reusable `GWViewAllLink({onTap, label='View all'})` in `lib/components/cards/gw_view_all_link.dart`: boxless right-aligned uppercase "VIEW ALL" (Inter 11px w600, 0.08em tracking, `gw.textSecondary`) + `arrow_right_alt` (15px). Hover (desktop): label+arrow → `brandPrimary`, arrow slides 3px right (`AnimatedContainer` transform), 1.5px `brandCta` gradient underline fades in under the LABEL width only (`AnimatedOpacity`, slot always reserved → no baseline shift); pointer cursor. `MouseRegion`+`GestureDetector` (NOT `InkWell` — its box violates "no background box"); `GeniusWalletMotion.base` 200ms; fail-soft `gw` re-skin. Wired `trailing: GWViewAllLink(onTap: () => context.go('/markets'))` (shell tab → `go` not `push`); removed old `Text` + unused `GeniusWalletTypography` import. 2 files (1 new), `flutter analyze` clean ("No issues found!"). Light-mode `#0AAEE6` deferred to light pass (dark-first). WALK PENDING (dark: hover tint/slide/underline + click → `/markets`). | 2026-07-21 | 0bcf3df (PR #210) | [260721-ch1-markets-header-trailing-replace-top-8-24](./quick/260721-ch1-markets-header-trailing-replace-top-8-24/) |
| 260721-ed9 | Re-skin the top-bar right cluster per approved sketch **005 winner B** (normalized quiet chips) — `/gsd-quick --validate`: plan-checked PASS (1st iter) + verifier 8/8 code-level must-haves. All 5 controls normalized to ONE 40px family. New shared `lib/theme/nav_chip_style.dart`: `navChipShell` (40px shell — height pinned via `minimumSize`/`maximumSize` + compact density/tapTargetSize, NOT `fixedSize`; `radiusMd`), `navContextChipStyle` (shell + quiet `surfaceMenu` fill + `borderSubtle`→`borderStrong` hover via `WidgetStateProperty.resolveWith` on `side`), and appearance-aware `connectBrandColor` (light `0xFF0B6E8F` ≈5.8:1 on white — raw `brandPrimaryStrong` was ~2:1; dark `brandPrimaryStrong`). Context chips (network/SDK/account) → `navContextChipStyle`, internal gaps → `space4`; Connect idle → `connectBrandColor` on the shell (5-state machine + status fills untouched); `gw_button` gained an **additive optional `height`** (default null → `GWButtonSize.md` still 48 app-wide) so Buy GNUS drops to 40 locally; right `Row` gained `spacing: space4`. **TRAP avoided**: theme.dart `textButtonTheme` (`vertical: space10`) untouched — local `ButtonStyle` overrides only (the height mismatch's real root cause; a global edit would regress every bare TextButton). Preserved: dropdowns, SDK `SizedBox.shrink()` collapse, Reown 5 states, breakpoint label-drops. 8 files (2 new incl. `test/theme/nav_chip_style_test.dart` → 3/3 pass asserting height-40/radiusMd/fill/hover-side + both Connect AA), `flutter analyze` clean (3 pre-existing unrelated infos). Light `#0AAEE6`-family AA handled here (Connect); broader light pass still deferred (dark-first). **Walk fix (walk 1):** chips rendered ~32px (8px shorter than Buy GNUS's hard 40) because `navChipShell`'s `VisualDensity.compact` — desktop's ambient density anyway — subtracts 8 from `minHeight` (→[32,40]) while content is short; the redundant `compact` (tap-floor already killed by `tapTargetSize.shrinkWrap`) was replaced with an EXPLICIT `VisualDensity.standard` → constraints [40,40], chips+Connect now render exactly 40 = Buy GNUS. Test strengthened: added a `getSize`-based rendered-height assert under an ambient-compact theme (the property-only check had passed at 32). 4/4 pass, analyze clean. WALK PENDING (dark+light: 5 controls one 40px family, even space4 gaps, hover, Connect 5 states, SDK-absent no hole, Buy GNUS only gradient). | 2026-07-21 | 0bcf3df (PR #210) | [260721-ed9-re-skin-top-bar-right-cluster-per-sketch](./quick/260721-ed9-re-skin-top-bar-right-cluster-per-sketch/) |
| 260721-1nk | Three locked dark-first chrome redesigns: **Navbar "B"** (002-B: active nav = 3px `brandCta` gradient underline w/ `brandPrimaryStrong` glow blur 10, rounded-top flush bottom; icons 16→23; `appBarHeight` 60→68; idle "Connect" → `brandPrimaryStrong` ghost outline, connection logic untouched — border made idle-only so red Disconnect/warn Connecting stay filled+borderless, Rule-1 deviation from the plan's unconditional `side`); **Markets "A"** (003-A: real "Markets" header row [titleLg + "Top {n}·24h" bodySm] via Column+Expanded, no more first-item hack; shared `CryptoSparkLineChart` rows now Assets-twins — 34px icon, name-over-price, filled % chip, sparkline 80×15→56×20, up/down `gw.statusSuccess/Error` [legacy mutedGreen/red/grey gone], trailing 44→50 fixes RenderFlex overflow); **secondary CTA** (`gw_button` `secondary` foreground+border `brandPrimary`→`brandPrimaryStrong`, one central edit app-wide). Removed a dead `gw` local in reown build (Rule 1, analyze-clean). `/markets` full page (2nd consumer of shared row) geometrically confirmed no clip/overflow inside its `Clip.hardEdge radiusMd` 80px cell (ListTile 72px floor unchanged; `iconSize:32` kept). 6 files, `flutter analyze` clean (2 pre-existing infos @ reown 158/403). Light-mode AA for `#0AAEE6` deferred to light pass. WALK PENDING (dark: navbar + Markets panel + `/markets` full page + a secondary CTA). | 2026-07-21 | 0bcf3df (PR #210) | [260721-1nk-navbar-b-redesign-thick-gradient-underli](./quick/260721-1nk-navbar-b-redesign-thick-gradient-underli/) |
| 260720-lyn | Soften light-mode elevated card/dialog shadows (appearance-aware) — was prose-only in this ledger, added 2026-07-21 | 2026-07-20 | 2b05cfd | (see `.planning/quick/`) |
| 260721-baz | Unified `GWSectionTitle` across all four dashboard panels (18px `titleLg`, `space4` inset, `space8` gap, optional right trailing — Assets/Markets/Transactions/Bitcoin Chart share one geometry) + desktop nav-tab vertical-centering fix (icon+label centered in the inset hover box, gradient underline pinned to box bottom and excluded from centering). New `lib/components/cards/gw_section_title.dart`; 6 files. Session 2. | 2026-07-21 | 0bcf3df (PR #210) | [260721-baz-unified-gwsectiontitle-component-18px-as](./quick/260721-baz-unified-gwsectiontitle-component-18px-as/) |
| 260721-dws | Bitcoin Chart card re-skinned to sketch **006 A→**: coin identity, top-right **visual-only** timeframe segment (`_TimeframeSegment`, private per-file), cyan-glow hero price, %-pill-only (USD delta dropped), mint (`brandSecondary`) area chart independent of up/down, styled hover crosshair + tooltip (fl_chart 1.2.0 `tooltipBorder` → real `gw.borderSubtle` hairline). Glow is a layout-neutral `Positioned`+`IgnorePointer` overlay so it cannot re-open uhe's Column overflow; zoom/pan deliberately KEPT (re-skin-never-restructure). Filed follow-up todo: wire real 1H/1D/1W/1M/1Y ranges. Session 2. | 2026-07-21 | 0bcf3df (PR #210) | [260721-dws-bitcoin-chart-section-reskin-a-arrow](./quick/260721-dws-bitcoin-chart-section-reskin-a-arrow/) |
| 260721-d5s | **Dev-only one-shot account-load fault injector** so 05-07's Task 2 walk is repeatable without hand-editing source. New `lib/dev/dev_fault_injector.dart` (singleton in the `DevMockHoldings`/`DevMockTransactions` shape): `armAccountLoadFailure()` **assigns** 1 (never increments, so a double-press cannot queue a second failure that would eat the Retry press), `consumeAccountLoadFailure()` decrements-and-returns-true exactly once, `disarm()`. Hook is a **pure insertion** into `_onFetchAccount`'s existing `try` (`app_bloc.dart`, 30 insertions / **0 deletions**) gated `kDebugMode && kShowDevTools && consume()` **in that order** — both leading operands are compile-time `const bool`, so the branch constant-folds out of release entirely. Bubble MOCK section gained `'Fail acct'` (arm → dispatch `FetchAccount()` → warning toast; one-shot semantics stated in label, tooltip AND toast); `Clear` extended to `disarm()`. 05-07 Task 2's recipe repointed at the button, with its press-Retry-expect-recovery observation and `STOP and report` clause preserved verbatim. `flutter analyze lib` held at the 61 baseline. **Replaces the old hand-edit-`app_bloc.dart`-then-remember-to-revert harness** — that shape was fragile and its "did you revert?" gate was a smell. | 2026-07-21 | 1360350, a122530, e64f33d | [260721-d5s-dev-only-account-load-fault-injector-in-](./quick/260721-d5s-dev-only-account-load-fault-injector-in-/) |
| 260721-bb3 | **Docs-only** (zero `lib/` changes) — correct three stale planning assumptions surfaced by the Phase 05 re-verification. (1) **UI-SPEC §3.1's GNUS/Minions toggle cell**, which had drifted from shipped code by TWO independent routes: 05-02 substituted the selected-label token (`textPrimary` → `textOnBrand`) and asked twice for the contract to be fixed, and then 0ze's brand sweep repointed the fill (`brandPrimary` `#14C8FF` → `brandPrimaryStrong` `#0AAEE6`, distinct constants, not aliases). Both cells now agree with `wallet_overview.dart`; ratios re-anchored to the real fill — `textPrimary` rejected at **2.56:1** (AA fail), `textOnBrand` shipped at **7.74:1** — replacing the previously mis-cited 1.96/10.12 figures, which were computed against the superseded `brandPrimary` anchor. (2) **ROADMAP Phase 7** gained an additive "Inherits from Phase 5" note: dws re-skinned `crypto_live_chart.dart` inside Phase 5, so the 05 report's whole-file deferral is superseded; residue is exactly 4 raw `Colors.white` at `:455,463,471,480`. Phase 7's 4 success criteria byte-unchanged. (3) Three todos filed + a back-link closing the timeframe-ranges dependency loop. | 2026-07-21 | 2e62516, 00edd3a, 0fe12bb, eaaeaa1 | [260721-bb3-correct-stale-planning-assumptions-from-](./quick/260721-bb3-correct-stale-planning-assumptions-from-/) |
| 05-08 (walk-time addition) | Dev-only Markets fault fixture built DURING 05-08's Task 4 human walk (not a standalone quick task — no `quick/` directory) so the plan's own Task 3 deliverable (Markets error/empty branches keeping their card) could be walked at all: CoinGecko was 429-rate-limited the whole session, so `getDashboardMarketCoins()` always fell back to cached data and the grid always rendered coins. New sticky `DevFaultInjector.marketsFault` (`ValueNotifier<DevMarketsFault?>`), hooked at `getDashboardMarketCoins()` (the one function both `initState` and `_retry` call) so the fault flows through the genuine `FutureStateWidget` branches; two new bubble buttons ("Mkt error" / "Mkt empty"); both arm/disarm trigger an immediate refetch. All 4 files pure insertions, gated `kDebugMode && kShowDevTools`. `flutter analyze` holds at 61; 26 tests pass. WALKED & APPROVED same session (05-08 Task 4 Part C). | 2026-07-21 | 3364259 | (no `quick/` dir — see `lib/dev/dev_fault_injector.dart`, `lib/dashboard/chart/dashboard_markets_util.dart`) |
| 18 (fast, verification cleanup) | Removed the orphaned `webTabCanClose()` helper from `lib/web/web_chrome_helpers.dart` and its 2-case test group. Built in 18-01 for the last-tab-locked rule (D-06), which commit `5c473d8` superseded with reset-on-close — ratified as an override in `18-VERIFICATION.md`, so the helper had **zero call sites in `lib/`** while its passing tests still implied a rule the app no longer enforces. Also dropped the stale "last-tab" mention from the file's header comment. `web_chrome_helpers_test.dart` 8/8 pass (was 10 incl. the 2 removed); `flutter analyze` on both files: no issues. `/gsd-fast`, not `/gsd-quick` — no `quick/` directory. NOTE: committed with explicit `--files` rather than the workflow's `git add -A`, because this tree carries several independent change sets plus local-only cmake patches. | 2026-07-25 | cccd20c | (no `quick/` dir — see `lib/web/web_chrome_helpers.dart`) |
| 24 | Web tab home page -> https://gnus.ai/ (was https://www.duckduckgo.com, hardcoded at 4 call sites across web_view_screen.dart + web_view_mobile.dart). Replaced with one shared const kWebHomeUrl in web_chrome_helpers.dart, so the home page is now a single edit; two stale DuckDuckGo comments corrected. analyze lib = 59, web_chrome_helpers_test 8/8 pass. Uncommitted per CLAUDE.md. | 2026-07-25 | 414fa94b | — |

> **2026-07-21 MERGED — PR #210 (`redesign/homepage-chrome-260721` → `ui-redesign-port`, merge `a34d1f1`).** Jakub gave the explicit go; the CLAUDE.md commit gate is released **for this batch only** (it still applies to new work). Code: `0bcf3df` — 29 files, +1648/-415, covering the 7 approved tasks (uhe/vwj/0ze/1nk/bxr/ch1/ed9) **plus session-2's `baz` and `dws`**. Docs/sketches: `73a09a4` — `05-VERIFICATION.md`, every quick-task PLAN/SUMMARY, sketches 001–008 + MANIFEST. Working tree clean; `ui-redesign-port` == `origin/ui-redesign-port`. **Sketch winners now locked: 001→A2, 005→B, 006→A-family (A→ shipped by dws), 008→D "Lift chip" = the design-system hover standard for all interactive chrome. 007 still unpicked (rec C · icon-only compact).**
>
> **⚠️ `05-VERIFICATION.md` is STALE.** It ran 2026-07-20T21:15Z against baseline `7a95e68` — *before* this merge — and returned `gaps_found`, 1/5 must-haves. Re-checked against HEAD 2026-07-21: **Gap 1 RESOLVED** (`transaction_displays.dart:90,97` are back on `textOnBrand`; k81's `Colors.white` revert is gone). **Gap 3 code-changed, unwalked** (uhe's compact-mode guard + dws's layout-neutral glow both touch the overflowing `crypto_live_chart.dart`; the 6.3px RenderFlex needs a re-walk, and **release builds clip it silently**). **Gap 2 STILL OPEN and unchanged** — `dashboard_screen.dart:70` is still a bare `Center(child: Text('Something went wrong!'))` with no retry. Gap 2 is a **decision, not code**: ROADMAP criterion 3 says "with a working retry", UI-SPEC §6 forbids reconciling develop's string to `GWErrorState`. Re-verify against HEAD before advancing to Phase 06.
>
> **⚠️ UI-SPEC §3.1's 1.96:1 toggle pairing is STILL in the contract.** 05-02 measured it, substituted `textOnBrand` in code, and asked twice for the source to be corrected; it was not, and the same white-on-bright-brand-fill defect then reappeared on the transaction badge by a different route (k81/Gap 1). 05-VERIFICATION calls this "the one finding that should outlive this report" — fix §3.1 or it ships a third time.

> **2026-07-21 homepage/dashboard redesign WALKED & APPROVED (dark) — Jakub, end-of-day handoff.** All 7 on-top-of-baseline quick tasks visually approved on the dashboard/homepage: `uhe` (spacing + space3), `vwj` (Assets A2), `0ze` (brand sweep → gradient), `1nk` (Navbar B + Markets A), `bxr` (Nav tab C + unified section titles), `ch1` (View All), `ed9` (right cluster). **Navbar = final.** Bitcoin/coin chart (sketch 006, session 2) approved on homepage. Still **UNCOMMITTED** (CLAUDE.md gate) — **PR deferred**, awaiting Jakub's explicit go; when authorized, stage **per-path** (7 tasks' `lib/**`+`test/**`), never `git add -A` (shared tree carries session-2 work + 6 skip-worktree signing files). Deferred on purpose: light-mode AA pass (dark-first); a few non-homepage pages; sketch 007 transaction-filter variant pick (rec **C · icon-only compact**); session-2 hover-language 008 (nav + VIEW ALL) still in progress.

> **All 2026-07-20 quick tasks WALKED & APPROVED (both light+dark): bgl, cw8, dty, eu9, gzq, ipg, jvr, k81, lyn.** jvr=dev mock-transactions injector; k81=transaction-area polish (badge white, row spacing/shadow, drawer plain-data + un-clipped close); lyn=softened light-mode card/dialog shadows (appearance-aware). gzq=clipped surface-card shadows fixed (markets grid + mobile one-column dashboard). ipg=shared GWPageHeader unifying Markets/News/Swap page titles (headlineLg, left-aligned). bgl=dev bubble; cw8=mock-holdings injector; dty=sectioned bubble + branded buttons; eu9=header/balance light-mode root fix (btnFilter appearance-aware app-wide) + branded Submit-Job/Buy-GNUS. Resolved todos: `move-dev-tooling-out-of-top-bar-into-overflow-bubble`, `top-bar-action-widgets-render-black-in-light-mode` → moved to todos/completed.

> **APPROVED 2026-07-20.** Blocking human-verify walk passed on a fresh `GW_DEV_TOOLS=true` run: top bar no longer overflows (real widgets only), bubble anchored top-right below header, drags + expands within the viewport, all dev actions reachable, and its light/dark toggle live-re-skins the app. Fix `a91aec0` (top-right anchor + viewport clamp/scroll) followed the initial off-screen-expand report.

## Reference Material

| Item | Location | Use |
|------|----------|-----|
| Original design branch | worktree `C:\Users\User\Documents\Projects\GNUS-compare\GeniusWallet-3514` | Builds + runs as a Release exe — the visual source of truth |
| Verified fixes | branch `ui-redesign-3.514-develop` | Read-only; source of the 3 BEH-02 fix commits |
| Regression audit | `.planning/reference/REVIEW_FINDINGS_REDESIGN.md` | 37 findings, assigned per phase in ROADMAP.md |

## Deferred Items

| Category | Item | Status | Deferred At |
|----------|------|--------|-------------|
| Testing | APP-02 — working `flutter test` harness | v2 | 2026-07-16 |
| Features | APP-01 — broader feature roadmap (chains, staking) | v2 | 2026-07-16 |

## Session Continuity

Last session: 2026-07-27T16:23:41.581Z
Stopped at: Completed 09-03-PLAN.md
UNCOMMITTED). Next in the walk queue: **15-06** (Transactions tab walk), then 16 + 17 walks,
then Phase 13 code (13-03 walk, 13-04, 13-05). App running single clean instance. Light deferred.
Current official-track resume point: **Phase 06 is 5/6 — 06-06 (closeout) is next.** The paragraph
below is the preserved 06-01 historical narrative; read it for context, not for the next step.

--- 06-01 historical detail (2026-07-21) ---
Stopped at: Phase 07 wave 1 executed (07-01 + 07-02 committed, analyze 61); 07-03 human walk is NEXT (blocking)
`/landing_screen` entry point + both flow shells' AppBar) was re-skinned across two auto tasks
(`3e1f432`, `b9c565f`), then Task 3's blocking human-verify checkpoint was run on a genuine
fresh-install profile (all four persistence layers cleared — took four attempts; see
`2026-07-21-four-independent-wallet-persistence-layers-with-no-documente.md`). The walk found one
real defect in Task 1's own deliverable — CTAs glued to the window bezel at narrow widths, because
`ConstrainedBox(maxWidth:)` only constrains when the viewport is wider than it — fixed per Rule 1
(`67e2821`, `Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8))` wrapped outside
the `ConstrainedBox`) and re-walked clean; the wide-window layout was confirmed unchanged by
construction. **The blocking mesh light-mode gate PASSED — `GWMeshBackground` is KEPT** on the
entry screen in light mode, judged live rather than waived (see Decisions above). The inherited
`GWButtonVariant.secondary` light-mode AA concern the plan named was re-verified and found already
closed (same-day quick task `260721-fa7`, 1.93:1 → 4.76:1). Both flow shells' flattened AppBars and
in-flow back navigation were also walked and approved. Console evidence across every relaunch: zero
`RenderFlex overflowed`, zero exceptions, zero `LateInitializationError`. **Carried forward for
06-02** (do not rediscover): `legal_screen.dart` and `select_wallet_type_screen.dart` share the same
zero-inset breakpoint bug — see
`2026-07-21-systemic-mobile-gutter-missing-on-onboarding-breakpoint-cons.md`. **The fresh-install
profile used for this walk is now CONSUMED** — a wallet was created during it; any later plan
needing genuine first-run state must clear all four persistence layers again. **Since then 06-02
through 06-05 all closed; Phase 06 is now 5/6 plans complete and 06-06 (closeout) is next.**
Preceding history: Phase 05 (Dashboard) CLOSED 2026-07-21 with 3
explicit user-authorized overrides (see prior entries in Decisions/Blockers above); also still open
from that session: a `_basePath` `LateInitializationError` thrown as an unhandled `GoException` on
every router redirect (likely pre-existing on develop — confirm before attributing it to this
milestone).
Resume file: None
`06-06-SUMMARY.md`). **Next up: Phase 07 (Token screens)** — not yet planned; run `/gsd-plan-phase 07`
(or discuss first) when ready. The `space8`-outside-`ConstrainedBox` gutter pattern was applied across
06-02..06-05 as planned. The chart-zoom-pan-row
todo remains open only as a product/UX decision (see Open decisions item 4 below), unrelated to
Phase 06.

**2026-07-21 parallel investigation — `.planning/AUDIT-260721-parallel-investigation.md` (derived at `87a7715`).** 67 agents, 6 disjoint areas, every finding adversarially refuted before surviving: **36 of 60 survived, 24 refuted (40%)**. Phase 05 gained **two** blockers beyond the already-fixed `GWEmptyState`, both now RESOLVED by plan `05-08` and walked & approved 2026-07-21: **B1** `WalletsOverview` was an unscrollable `Column(max)` in a hard `maxHeight:300` — the verifier's recount put the SGNUS branch at **~26px idle / ~55px processing**, correcting the investigator's "passes by 3px" in the *worse* direction; and **B2** the Markets error/empty branches returned bare `Center(Text)` outside `DashboardScrollContainer`, so that tile lost its card while four siblings kept theirs. B1 had **no dev fixture** (needed live SGNUS + processing) — 05-08 Task 1 shipped one (`dev_mock_sgnus.dart`), avoiding the empty-state trap a second time. Work queue Q1–Q6 with serialization points named. `_basePath` verified **pre-existing on develop** — not this milestone's. **`06-04-PLAN.md:99-100` is already superseded**: the repo has ZERO IME hardening (grep = 0 matches), and the plan prescribes 2 of the 4 needed flags for 1 of the 3 key-bearing files — `enableIMEPersonalizedLearning` is the one that actually maps to Android's `IME_FLAG_NO_PERSONALIZED_LEARNING`. Amend before executing 06-04.

**Fourth recurrence watch:** `theme.dart:103,116,355` pair `textPrimary` on `brandPrimaryStrong` = **2.56:1** in dark — the same white-on-brand-fill defect as 05-02's toggle and k81's badge, and `theme.dart:36-38` already rejects that exact pairing sixty lines above in the same file.

**Walk protocol lesson — worth applying beyond this phase:** a walk driven by fixtures verifies the fixture's state, not the product's. Zero-states, error-states and first-run states need explicit walk steps or they are silently exempted from every review. Phase 05 was walked six times and shipped a fresh-install overflow.

**The §6 "conflict" was not real.** The 07-20 report, and my own 07-21 re-verification, both framed ROADMAP criterion 3 ("working retry") and UI-SPEC §6 as documents that could not both be satisfied. Re-reading §6 at source disproved that: §6 is a *Copywriting Contract*. It locks the string `'Something went wrong!'` and forbids substituting `GWErrorState` — it says nothing about adding a retry affordance *beside* the text. `"Retry"` already ships on develop (`custom_future_builder.dart:49`, `gw_error_state.dart:14`), so no new copy is introduced either. Both documents are satisfied; **no override was recorded and criterion 3 was NOT reworded.** Lesson: the second-hand summary of a constraint is not the constraint — read the source before declaring a deadlock.

**What planning caught that the briefing got wrong** (two errors in my own hand-off to the planner, both found by reading code):

1. `_onRefresh` is a method of `OneColumnDashBoardView` (`:215`), NOT of `DashboardScreenState` (which ends `:80`) — so it was never in scope at the error branch. Resolved by hoisting it to file scope verbatim, leaving `RefreshIndicator(onRefresh: () => _onRefresh(context))` untouched.
2. **Reusing `_onRefresh` alone would have shipped a dead button.** `accountStatus` is written *only* inside `_onFetchAccount` (`app_bloc.dart:164,168,170`); `_onLoadWallets` writes only `subscribeToWalletStatus` and never emits `AppStatus.error` for it — so in shipped code the error branch is reachable *only* via `accountStatus == error`, the one leg `LoadWallets()` cannot clear. The retry therefore dispatches `FetchAccount()` **and** the shared reload. Independently re-verified by the plan-checker and again by the executor before any code was written.

Open decisions:

1. ~~**Gap 2 — dashboard retry.**~~ **DECIDED 2026-07-21 (user): add the retry, keep the string.** Implemented in 05-07 Task 1 (`64fa92d`). No override recorded, criterion 3 unchanged. **Phase 05 sign-off now waits only on the Task-2 walk**, not on a decision. Todo `2026-07-21-decision-dashboard-error-branch-retry.md` closes once the walk passes.
2. ~~**UI-SPEC §3.1** still carries the 1.96:1 pairing.~~ **RESOLVED 2026-07-21 by quick `260721-bb3`** — and the fix found a second drift on the same cell (0ze's fill repoint). Both cells now match shipped code; ratios re-anchored to `brandPrimaryStrong` (2.56:1 rejected / 7.74:1 shipped).
3. **Sketch 007** transaction-filter variant unpicked (rec **C · icon-only compact**).
4. **Does the chart's zoom/pan control row survive?** Still OPEN as a product decision — **no
   longer a Phase 5 blocker.** The 34px overflow at `crypto_live_chart.dart:315` is now recorded as
   an accepted Phase 5 override (`05-VERIFICATION.md`), not a gap this decision needs to unblock. A
   considered stopgap (`260721-gx1`, hiding the row below a 112px threshold) was planned in full but
   **abandoned by user decision 2026-07-21** — it would have shipped "a non-overflowing broken card,
   not a fixed one" per its own risk assessment, since the dashboard card's real problem is its
   vertical budget (new todo:
   `2026-07-21-bitcoin-chart-card-height-dashboard-vertical-budget.md`), not the zoom/pan row
   itself. This decision is tied to the already-filed "wire real timeframe ranges" todo: if the
   1H/1D/1W/1M/1Y tabs are meant to replace zoom/pan once wired, deleting the row closes this
   overflow, the raw-`Colors.white` finding, and the redundancy question at once. If zoom/pan
   survives, it needs both a layout fix and the same token migration.
   See `.planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md` and
   `.planning/todos/pending/2026-07-21-bitcoin-chart-card-height-dashboard-vertical-budget.md`.

**Lesson recorded in the §3.1 rule note:** contract cells are not self-maintaining. One cell drifted from HEAD twice in a single day — once by a per-plan substitution, once by a cross-cutting sweep (`0ze`) that repointed a token app-wide without touching the docs that name it. Re-check contract cells against HEAD after any sweep of that shape.

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
| Phase 08-swap-bridge P02 | 25min | 3 tasks | 3 files |
| Phase 08-swap-bridge P03 | 30min | 3 tasks | 3 files |
| Phase 08-swap-bridge P05 | 25min | 2 tasks | 7 files |
| Phase 08-swap-bridge P06 | 20min | 2 tasks | 3 files |
| Phase 09 P01 | 20min | 2 tasks | 5 files |
| Phase 09-banxa P02 | 20min | 3 tasks | 4 files |
| Phase 09-banxa P03 | 15min | 2 tasks | 5 files |

### Roadmap Evolution

- Phase 18 added 2026-07-24: Web tab chrome — in-app browser address bar + tab strip. Sketched this
  session: **035** (address bar, winner **B · Scalony toolbar**), **036** (tabs, winner **A · Stały
  pasek kart**), consolidated in **037** (winner **B · 035-B + 036-A**). Targets
  `lib/web/web_view_mobile.dart` (macOS/iOS) + `lib/web/web_view_windows.dart`. Replaces the raw
  `_buildSearchBar` + full-screen `_buildTabManager` (fixes the `Matrix4.rotationX(pi)` upside-down
  thumbnail bug). **NOT planned yet** — run `/gsd-plan-phase 18`. Design source:
  `.planning/sketches/037-web-chrome-combined/`.

- Phase 17 added 2026-07-23: News page — sketches 100-102, winner **B2 · Hero + Next up** (a lead
  hero + a "Next up" band over an even photo grid; `GWCard.hoverLift` lift-chip replaces the old
  black scrim; frozen `pubDate`, unrendered `description` and desktop-unreachable refresh all fixed;
  `flutter_staggered_grid_view` dropped). **COMMITTED 2026-07-23 in `651541c`** (integrated from the
  now-removed `redesign/news-tab-260723` worktree); `flutter analyze` clean + `gw_card_hover_test.dart` +1.
  Pending: human walk (dark+light), GSD verification record. Context:
  `.planning/handoffs/HANDOFF-news-b2.md` + `.planning/phases/17-news-page-redesign-*/CONTEXT.md`.

- Phase 16 added 2026-07-23: Markets page — sketch 103 **H1** (native-token hero over a sortable
  All Markets table). **COMMITTED 2026-07-23 in `aa78eec`** (integrated from the now-removed
  `redesign/markets-tab-260723` worktree); `flutter analyze` clean + sort test 5/5. Pending:
  human walk (dark+light), GSD verification record, macOS signing fix. Context: `.planning/handoffs/HANDOFF-markets-hero.md` +
  `.planning/phases/16-markets-page-redesign-*/CONTEXT.md`.

- Phase 12 added 2026-07-22: Transactions redesign (design contract = sketches 010-014, all decisions locked)
- Phase 13 added 2026-07-22: Boot & loading sequence — Signal Edge splash + one shared dashboard
  gate (design = sketch 015, approved). Grounded in spikes 001/002: the ~9.6 s main-isolate freeze
  during `GeniusSDKInitWithMnemonic` is NOT fixable from Dart (spike 001 INVALIDATED), and the SDK
  stalls at 52.5% forever, so the dashboard must never gate on `getInitializationStatus()`.

- Phase 14 added 2026-07-22: Compute panel & job flow — the dashboard's first section (design =
  sketches 016 **B2 Twin tiles**, 017 **A Dot+label**, 018 **A drawer, vertical steps**; all locked).
  Carries three bloc build items beyond the re-skin: a **stall detector** (the 52.5% freeze is
  currently drawn as a determinate ring), a **`RetryProcessingStatus` event** re-arming the timer
  `app_bloc.dart:194` cancels permanently, and a **public `AccountDrawer.show`** so `switch wallet ›`
  has somewhere to go. Hard constraint: the card has 276px and B2's worst state is 261px — anything
  added to the compute block breaks it first.

- Phase 15 added 2026-07-22: Transactions **tab** — page frame, filter rail, empty-state anchor,
  amount honesty (design = sketches 020-022, all locked). The route mounts the dashboard *panel*
  verbatim, so it renders as a 736px column on a 2000px page with a panel-sized title and no card.
  Three decisions worth carrying forward: (a) the active rail row uses **022-B2, the navbar's
  active-tab mark copied outright** — w700 label never recoloured, 2px gradient rule beneath, glyph
  untouched; sketch 020's `brand-fill` background was invented and is rejected. (b) `GWEmptyState`
  gets a **bounded centre** (`maxHeight: 480` under `topCenter`) rather than a hand-picked offset, so
  short panels are unchanged and tall ones stop drifting — **this is a shared component, so Assets
  and Markets change too.** (c) It **amends Phase 12's amount rules**: `process` and failed/cancelled
  rows print the real number instead of an em-dash, and the `Not charged` value line becomes
  load-bearing — it is the only thing stopping a full-weight `− 0.75 ETH` from claiming the balance
  changed. Jakub overruled the recommendation to drop the sign; the value line is what makes the
  override safe.

- Phase 13 progress 2026-07-22 (session B): 13-01 and 13-02 CLOSED; 13-03 code-complete
  with its walk NOT closed; 13-04 (the original ask — remove per-section dashboard loaders)
  and 13-05 not started. Full state, measured facts and open review items in
  `.planning/handoffs/HANDOFF-phase13-boot.md`. **13-01/02/03 COMMITTED in `29b183b`** (Signal Edge
  boot); 13-04/05 remain outstanding — the "everything uncommitted" claim was stale and is corrected.
