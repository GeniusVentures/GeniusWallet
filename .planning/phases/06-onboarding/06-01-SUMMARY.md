---
phase: 06-onboarding
plan: 01
subsystem: ui
tags: [flutter, onboarding, gw_button, gw_mesh_background, appbar, wcag, dark-only-component]

# Dependency graph
requires:
  - phase: 04-navigation-shell-chrome
    provides: "GWColors ThemeExtension wired into theme.dart (appearance-aware scaffoldBackgroundColor) — the safe fallback surface if the mesh gate goes negative"
  - phase: 03-gw-component-library
    provides: "GWButton and GWMeshBackground primitives, both previously zero-caller"
provides:
  - "Re-skinned /landing_screen entry point (wallet_creation_screen.dart): deepBlue hardcoded-dark trap deleted, GWMeshBackground(intensity: 0.7) as its first real consumer, three CTAs mapped to GWButton (secondary/gradient/ghost)"
  - "Flat, transparent, elevation-0 AppBar on both onboarding flow shells (ExistingWalletFlow, NewWalletFlow), routing/PopScope logic byte-identical"
  - "A blocking human-verify checkpoint recipe (mesh light-mode gate + fresh-install first-run walk) ready to hand to the user"
affects: [06-02, 06-03, 06-04, 06-05, 06-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "GWMeshBackground(intensity: 0.7) as a Scaffold body wrapper — its own opaque ColoredBox(surfaceBase) base means deleting Scaffold(backgroundColor:) entirely (rather than setting Colors.transparent) is a safe no-see-through degradation if the mesh is later dropped"
    - "AppBar(backgroundColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0) as the flat step-bar treatment for onboarding flow shells — the phase's one sanctioned raw Colors.* usage"

key-files:
  created: []
  modified:
    - lib/onboarding/view/wallet_creation_screen.dart
    - lib/onboarding/existing_wallet/routes/existing_wallet_flow.dart
    - lib/onboarding/new_wallet/routes/new_wallet_flow.dart

key-decisions:
  - "Scaffold(backgroundColor:) argument DELETED entirely rather than set to Colors.transparent (deviation 1, planned and intentional) — GWMeshBackground already paints an opaque base at StackFit.expand, so nothing shows through either way, but deleting leaves the Scaffold on Phase 4's wired appearance-aware scaffoldBackgroundColor so the §9.1 fallback (drop the mesh) degrades to a correct surface instead of a see-through one, and keeps zero raw Colors.* on this file"
  - "AppBar's Colors.transparent KEPT as the phase's one sanctioned raw Colors.* usage (deviation 2, planned and intentional) — there is no token for 'no fill'"
  - "STALE PREMISE FOUND: the plan/UI-SPEC's central claim that GWButtonVariant.secondary's foreground text fails WCAG AA in light mode (raw brandPrimaryStrong #0AAEE6 at 1.93:1 on light surfaceBase) is now FALSE at HEAD. Quick task 260721-fa7 (landed same day, before this plan ran) already repointed gw_button.dart's secondary foreground from GeniusWalletColors.brandPrimaryStrong to the new appearance-aware GeniusWalletColors.brandPrimaryOnSurface (light value #0A6885, measured 4.76:1 on surfaceBase — passes AA text at 4.5:1). This was NOT fixed by this plan — it was already fixed by an unrelated same-day quick task before Tasks 1-2 ran. Task 3's walk recipe step 8 instructs recording this as an unfixed inherited defect; that instruction is now stale and must be re-verified against current code during the walk rather than assumed present."

requirements-completed: []  # SCR-02 is only partially satisfied — Task 3 (the checkpoint) is outstanding; do not mark complete until the walk passes.

coverage:
  - id: D1
    description: "wallet_creation_screen.dart re-skinned: deepBlue trap gone, GWMeshBackground wraps the untouched Center/ConstrainedBox/Column tree, three CTAs mapped to GWButton (secondary/gradient/ghost) with byte-identical labels and handlers"
    requirement: "SCR-02"
    verification:
      - kind: other
        ref: "flutter analyze lib/onboarding/view/wallet_creation_screen.dart -- No issues found!"
        status: pass
      - kind: other
        ref: "plan's automated verify gate (GWMeshBackground present, >=2 GWButton(, no deepBlue/OutlinedButton/FilledButton/useDesktopLayout/LayoutBuilder/app_screen_with_header, GeniusBreakpoints.small*2/3 intact, logo_and_title.png intact) -- all passed"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 checkpoint: fresh-install first-run walk (both window sizes, both appearance modes) -- NOT YET PERFORMED"
        status: unknown
    human_judgment: true
    rationale: "Compile-time analyze and grep gates prove the code is structurally correct but cannot prove a fresh-install user sees a non-overflowing, appearance-correct landing screen, or that the mesh reads acceptably in light mode -- that is Task 3's blocking-human checkpoint, outstanding."
  - id: D2
    description: "Both onboarding flow shells (ExistingWalletFlow, NewWalletFlow) wear a flat, transparent, elevation-0, scrolledUnderElevation-0 AppBar; PopScope/BlocListener/_buildStep left byte-identical"
    requirement: "SCR-02"
    verification:
      - kind: other
        ref: "flutter analyze on both files -- No issues found!"
        status: pass
      - kind: other
        ref: "plan's automated verify gate (scrolledUnderElevation: 0 in both files, combined deletions <=2 lines [measured: 2], onPopInvokedWithResult intact in both, context.go('/dashboard') intact) -- all passed"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 checkpoint: in-flow back navigation + flat-AppBar visual check, both flows, both modes -- NOT YET PERFORMED"
        status: unknown
    human_judgment: true
    rationale: "Grep/analyze prove the AppBar expression changed and routing logic is untouched, but cannot prove PopScope still steps backward correctly in the running app or that the AppBar reads visually flat with no Material 3 tint -- that is Task 3's blocking-human checkpoint, outstanding."

duration: ~20min (Tasks 1-2 only; Task 3 is a blocking-human checkpoint, not yet performed)
completed: 2026-07-21
status: blocked
---

# Phase 06 Plan 01: Onboarding entry screen + flow AppBars Summary

**Re-skinned `/landing_screen`'s entry point (deepBlue trap deleted, `GWMeshBackground` adopted, CTAs mapped to `GWButton`) and flattened both onboarding flow shells' AppBar — Tasks 1-2 complete and committed; Task 3's blocking mesh-light-mode-gate walk is outstanding.**

Tasks 1-2 (both `type="auto"`) are complete and committed. **Task 3 — the onboarding chrome walk, including the blocking mesh light-mode gate — is a `checkpoint:human-verify` (`gate="blocking"`) and has NOT been performed.** This SUMMARY documents the auto-task work only; the walk that confirms the entry screen is appearance-correct in a genuinely fresh-install state, and that decides whether `GWMeshBackground` survives light mode, remains outstanding.

## Performance

- **Started:** 2026-07-21 (this session)
- **Completed (Tasks 1-2):** 2026-07-21
- **Duration:** ~20 min
- **Tasks:** 2 of 3 (Task 3 pending human verification)
- **Files modified:** 3

## Accomplishments
- `wallet_creation_screen.dart`'s hardcoded `Scaffold(backgroundColor: GeniusWalletColors.deepBlue)` — the dark-only-constant trap Phase 4 §8 and Phase 5 §7 each found elsewhere — is gone; the Scaffold now falls back to Phase 4's wired appearance-aware `scaffoldBackgroundColor`.
- `GWMeshBackground` (Phase 3, zero callers to date) got its first real consumer, wrapping the entry screen's untouched `Center`/`ConstrainedBox`/`Column` tree at `intensity: 0.7`.
- All three entry CTAs ("I already have a wallet", "Create new wallet", conditional "Cancel") re-skinned to `GWButton` (secondary / gradient / ghost respectively), same labels, same handlers, same `ConstrainedBox(minHeight: 50)` wrappers.
- Both onboarding flow shells (`ExistingWalletFlow`, `NewWalletFlow`) now carry a flat, transparent, elevation-0 `AppBar` instead of Material 3's default tinted surface — the phase's one sanctioned raw `Colors.transparent`.
- `PopScope.canPop`/`onPopInvokedWithResult`, both `BlocListener`s (including the `/dashboard` navigation), and both `_buildStep` switches are byte-identical — combined diff across both flow files measured at exactly 2 deletions (the two bare `AppBar()` expressions), proving no routing logic was touched.
- Develop's locked single-tree structure survives: no `LayoutBuilder`, no `GeniusBreakpoints.useDesktopLayout` branch, no `AppScreenWithHeaderDesktop`/`Mobile` import anywhere in the touched files.

## Task Commits

Each task was committed atomically:

1. **Task 1: Re-skin wallet_creation_screen.dart** - `3e1f432` (feat)
2. **Task 2: Flatten both flow shells' AppBar** - `b9c565f` (feat)

Task 3 (checkpoint:human-verify, gate="blocking") has NOT been executed — no commit for it.

## Files Created/Modified
- `lib/onboarding/view/wallet_creation_screen.dart` - deepBlue background deleted, GWMeshBackground adopted, three CTAs mapped to GWButton
- `lib/onboarding/existing_wallet/routes/existing_wallet_flow.dart` - AppBar flattened to transparent/elevation-0/scrolledUnderElevation-0
- `lib/onboarding/new_wallet/routes/new_wallet_flow.dart` - same AppBar treatment

## Decisions Made

- **Deviation 1 (planned, from the plan's own objective):** deleted `Scaffold(backgroundColor:)` entirely rather than setting it to `Colors.transparent` per UI-SPEC §4.1's literal instruction. `GWMeshBackground` already paints an opaque base, so this is behaviorally identical today, but it leaves the Scaffold on the wired appearance-aware `scaffoldBackgroundColor` so the §9.1 mesh fallback (if taken during Task 3) degrades to a correct surface rather than a see-through one. Also keeps zero raw `Colors.*` on this file.
- **Deviation 2 (planned, from the plan's own objective):** kept the flow shells' `AppBar(backgroundColor: Colors.transparent, ...)` as the phase's one sanctioned raw `Colors.*` — there is no token for "no fill."
- **Stale premise discovered, not improvised around — reported here per instruction:** the plan's must-have truth #4 and UI-SPEC §4.1/§4.3 both assert `GWButtonVariant.secondary`'s foreground text is an unfixed, inherited WCAG AA failure in light mode (raw `brandPrimaryStrong` #0AAEE6 at 1.93:1 on light `surfaceBase`). Reading `gw_button.dart` at HEAD shows this is no longer true: quick task `260721-fa7` (landed the same day, before this plan executed) already repointed the `secondary` variant's foreground from `GeniusWalletColors.brandPrimaryStrong` to the new appearance-aware `GeniusWalletColors.brandPrimaryOnSurface` (light value `#0A6885`, code-comment-measured at 4.76:1 on `surfaceBase` — passes the 4.5:1 AA text floor). This plan did NOT fix it (nothing in Tasks 1-2 touches `gw_button.dart`) — it was already fixed by unrelated same-day work. **This means Task 3 step 8 of the plan's walk recipe ("record the inherited defect, do not blame this phase") is now stale guidance** — the walker should re-verify the secondary button's light-mode legibility against current code rather than assume the described 1.93:1 failure still reproduces. Flagging this explicitly rather than silently updating the walk recipe myself, per the "STOP and report rather than improvising" instruction for plan/code contradictions.

## Deviations from Plan

None beyond the two deviations the plan itself pre-authorized (documented above under Decisions Made, not re-listed here as auto-fixes since they required no Rule 1-3 judgment call — the plan's own objective section names both explicitly).

**Total deviations:** 0 auto-fixed. The two "deviations from UI-SPEC §4.1/§4.2" were pre-authorized by the plan itself, not discovered mid-execution.
**Impact on plan:** None — both tasks executed exactly as the plan specified, including its own pre-authorized deviations from the UI-SPEC's literal text.

## Issues Encountered

None during Tasks 1-2 execution. The stale-premise discovery above (GWButtonVariant.secondary AA fix already landed) surfaced during pre-execution file reads and is reported, not treated as a blocking issue for Tasks 1-2 (neither task touches `gw_button.dart`).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Task 3 — the blocking human-verify checkpoint — is OUTSTANDING and must be performed before this plan (and therefore SCR-02's entry-screen criterion) can be marked complete.** Full recipe is in `06-01-PLAN.md`'s Task 3 `<how-to-verify>` block. Summary of what's required:

1. A genuinely wallet-less (cleared Hive/application-support data) fresh-install profile — NOT a navigated-to route. This is mandatory per the Phase 05 lesson (six walks still shipped a fresh-install overflow because fixture-driven walks never rendered the real empty state).
2. Cold debug run with `GW_DEV_TOOLS=true` on the pinned SDK (`C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`), with any other running instance closed first (Hive's single-process lock).
3. Verify the entry screen at default AND narrow/short window sizes, in both appearance modes, both CTAs entering their flows, the Cancel branch (reached via account dropdown → add another wallet), in-flow back navigation on both flow shells, and a live in-place appearance flip via the dev bubble.
4. **The blocking mesh light-mode gate (step 7):** judge `GWMeshBackground` honestly in light mode. STATE.md records this component as dark-only-by-design (painter reads no appearance, black-alpha-38 vignette over the light `surfaceBase`). If it reads muddy or washes out any CTA, the sanctioned fallback is a one-line change (drop `GWMeshBackground`, let the wired `scaffoldBackgroundColor` stand) — this is NOT optional per the user's constraints for this session; do not ship a degraded light-mode first screen.
5. **Re-verify, don't assume, the GWButtonVariant.secondary light-mode observation** (step 8) — the plan expects an inherited AA failure that the code no longer has (see Decisions Made above). Confirm the actual current contrast reads legibly in light mode rather than filing a stale defect report.

Once Task 3 is walked and its outcome (mesh keep-or-fallback decision + secondary-button re-verification) is recorded, this plan's SUMMARY should be updated (or a follow-up note added) to close out `requirements-completed: [SCR-02]` for this entry-half slice, and STATE.md's position should advance.

No code blockers exist for 06-02 through 06-06 — the chrome this plan lays (entry screen + flow AppBars) is structurally complete regardless of the walk's mesh decision, since the fallback is a one-line, already-scoped change.

---
*Phase: 06-onboarding*
*Completed: 2026-07-21 (Tasks 1-2 only; Task 3 outstanding)*

## Self-Check: PASSED

- FOUND: lib/onboarding/view/wallet_creation_screen.dart
- FOUND: lib/onboarding/existing_wallet/routes/existing_wallet_flow.dart
- FOUND: lib/onboarding/new_wallet/routes/new_wallet_flow.dart
- FOUND commit 3e1f432 (Task 1)
- FOUND commit b9c565f (Task 2)
