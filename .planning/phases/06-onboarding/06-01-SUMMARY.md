---
phase: 06-onboarding
plan: 01
subsystem: ui
tags: [flutter, onboarding, gw_button, gw_mesh_background, appbar, wcag, dark-only-component, narrow-width-gutter, walk-driven-fix]

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
    - "Center -> Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8)) -> ConstrainedBox(maxWidth:) as the narrow-width-safe variant of this repo's existing Center->ConstrainedBox(maxWidth:) desktop-first pattern — the Padding sits OUTSIDE the ConstrainedBox so the gutter applies in addition to (never instead of) the max-width centring, and is only load-bearing once viewport width drops below maxWidth + 32"

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
  - "WALK-DRIVEN FIX (Rule 1): the Task 3 human walk, on a genuine fresh-install profile, found wallet_creation_screen.dart's CTAs glued to the window edge with zero gutter at narrow (mobile) window widths. Root cause: BoxConstraints(maxWidth:) on a ConstrainedBox only binds when the incoming constraint is WIDER than it -- once the window is narrower than GeniusBreakpoints.small*2/3 (~427px), Center's loosened constraints intersect down to the screen width itself, so the stretch Column renders edge-to-edge. Pre-existing desktop-first assumption (also present in legal_screen.dart, select_wallet_type_screen.dart, and every other GeniusBreakpoints.small-constrained onboarding screen -- none of which this plan owns or touched), not introduced by Task 1 -- but Task 1 re-skinned this screen and the walk is its gate, so it was fixed here rather than deferred. Fix: wrapped the existing ConstrainedBox in Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8)) (16px), chosen from house precedent (submit_logs_screen.dart's identical Center->Padding->ConstrainedBox shape at raw 16, and markets_screen.dart's page-level GridView padding at token space8) since no onboarding screen has an established mobile gutter of its own. Wide-window centring is unchanged by construction -- the Padding is only load-bearing once available width drops below maxWidth+32. Confirmed both Task 2 flow shells have no Center/ConstrainedBox of their own (Scaffold.body is _buildStep(...) directly), so this defect cannot live there and neither file needed a change."

requirements-completed: []  # SCR-02 is only partially satisfied — Task 3 (the checkpoint) is outstanding; do not mark complete until the walk passes.

coverage:
  - id: D1
    description: "wallet_creation_screen.dart re-skinned: deepBlue trap gone, GWMeshBackground wraps the untouched Center/ConstrainedBox/Column tree, three CTAs mapped to GWButton (secondary/gradient/ghost) with byte-identical labels and handlers"
    requirement: "SCR-02"
    verification:
      - kind: other
        ref: "flutter analyze lib/onboarding/view/wallet_creation_screen.dart -- No issues found! (re-run after the narrow-width gutter fix, still clean)"
        status: pass
      - kind: other
        ref: "plan's automated verify gate (GWMeshBackground present, >=2 GWButton(, no deepBlue/OutlinedButton/FilledButton/useDesktopLayout/LayoutBuilder/app_screen_with_header, GeniusBreakpoints.small*2/3 intact, logo_and_title.png intact) -- all passed"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 checkpoint: fresh-install first-run walk found the narrow-width glued-to-edge defect (now fixed, commit 67e2821); re-walk to confirm the fix and complete the remaining walk items (mesh light-mode gate, secondary-button re-verification) -- IN PROGRESS, not yet fully passed"
        status: unknown
    human_judgment: true
    rationale: "Compile-time analyze and grep gates prove the code is structurally correct but cannot prove a fresh-install user sees a non-overflowing, appearance-correct landing screen at any window size, or that the mesh reads acceptably in light mode -- that is Task 3's blocking-human checkpoint. The walk already found and this plan already fixed one genuine defect (narrow-width gutter); the re-walk confirming the fix plus the remaining checklist items is outstanding."
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

duration: ~30min (Tasks 1-2 + one walk-driven fix; Task 3's checkpoint walk is still in progress)
completed: 2026-07-21
status: blocked
---

# Phase 06 Plan 01: Onboarding entry screen + flow AppBars Summary

**Re-skinned `/landing_screen`'s entry point (deepBlue trap deleted, `GWMeshBackground` adopted, CTAs mapped to `GWButton`, then a walk-found narrow-width gutter added) and flattened both onboarding flow shells' AppBar — Tasks 1-2 complete and committed; Task 3's walk is in progress, one defect found and fixed, remaining items (mesh light-mode gate, re-walk) outstanding.**

Tasks 1-2 (both `type="auto"`) are complete and committed. **Task 3 — the onboarding chrome walk, including the blocking mesh light-mode gate — is a `checkpoint:human-verify` (`gate="blocking"`) and is IN PROGRESS on a genuine fresh-install profile.** The walk already surfaced one real defect in Task 1's deliverable — CTAs glued to the window edge at narrow (mobile) widths, a pre-existing desktop-first assumption this screen inherited — which has been fixed and committed (Rule 1) below. The walk's remaining items (both window sizes/both modes re-confirmation, the mesh light-mode gate, the secondary-button re-verification) remain outstanding.

## Performance

- **Started:** 2026-07-21 (this session)
- **Completed (Tasks 1-2 + walk-driven fix):** 2026-07-21
- **Duration:** ~30 min
- **Tasks:** 2 of 3 (Task 3 checkpoint walk in progress; 1 Rule-1 fix landed mid-walk)
- **Files modified:** 3

## Accomplishments
- `wallet_creation_screen.dart`'s hardcoded `Scaffold(backgroundColor: GeniusWalletColors.deepBlue)` — the dark-only-constant trap Phase 4 §8 and Phase 5 §7 each found elsewhere — is gone; the Scaffold now falls back to Phase 4's wired appearance-aware `scaffoldBackgroundColor`.
- `GWMeshBackground` (Phase 3, zero callers to date) got its first real consumer, wrapping the entry screen's untouched `Center`/`ConstrainedBox`/`Column` tree at `intensity: 0.7`.
- All three entry CTAs ("I already have a wallet", "Create new wallet", conditional "Cancel") re-skinned to `GWButton` (secondary / gradient / ghost respectively), same labels, same handlers, same `ConstrainedBox(minHeight: 50)` wrappers.
- Both onboarding flow shells (`ExistingWalletFlow`, `NewWalletFlow`) now carry a flat, transparent, elevation-0 `AppBar` instead of Material 3's default tinted surface — the phase's one sanctioned raw `Colors.transparent`.
- `PopScope.canPop`/`onPopInvokedWithResult`, both `BlocListener`s (including the `/dashboard` navigation), and both `_buildStep` switches are byte-identical — combined diff across both flow files measured at exactly 2 deletions (the two bare `AppBar()` expressions), proving no routing logic was touched.
- Develop's locked single-tree structure survives: no `LayoutBuilder`, no `GeniusBreakpoints.useDesktopLayout` branch, no `AppScreenWithHeaderDesktop`/`Mobile` import anywhere in the touched files.
- **Walk-driven fix:** the fresh-install walk found the entry screen's CTAs glued to the window edge at narrow widths (zero gutter). Fixed by wrapping the existing `ConstrainedBox` in `Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8))`, verified analyze-clean and baseline-holding (61 issues), and committed.

## Task Commits

Each task was committed atomically:

1. **Task 1: Re-skin wallet_creation_screen.dart** - `3e1f432` (feat)
2. **Task 2: Flatten both flow shells' AppBar** - `b9c565f` (feat)
3. **Walk-driven fix (Task 3, Rule 1): narrow-width gutter** - `67e2821` (fix)

Task 3 (checkpoint:human-verify, gate="blocking") walk itself has NOT completed — no closing commit for it yet; `67e2821` is a code fix produced *during* the walk, not the walk's own commit.

## Files Created/Modified
- `lib/onboarding/view/wallet_creation_screen.dart` - deepBlue background deleted, GWMeshBackground adopted, three CTAs mapped to GWButton, narrow-width Padding gutter added (walk-driven fix)
- `lib/onboarding/existing_wallet/routes/existing_wallet_flow.dart` - AppBar flattened to transparent/elevation-0/scrolledUnderElevation-0
- `lib/onboarding/new_wallet/routes/new_wallet_flow.dart` - same AppBar treatment

## Decisions Made

- **Deviation 1 (planned, from the plan's own objective):** deleted `Scaffold(backgroundColor:)` entirely rather than setting it to `Colors.transparent` per UI-SPEC §4.1's literal instruction. `GWMeshBackground` already paints an opaque base, so this is behaviorally identical today, but it leaves the Scaffold on the wired appearance-aware `scaffoldBackgroundColor` so the §9.1 mesh fallback (if taken during Task 3) degrades to a correct surface rather than a see-through one. Also keeps zero raw `Colors.*` on this file.
- **Deviation 2 (planned, from the plan's own objective):** kept the flow shells' `AppBar(backgroundColor: Colors.transparent, ...)` as the phase's one sanctioned raw `Colors.*` — there is no token for "no fill."
- **Stale premise discovered, not improvised around — reported here per instruction:** the plan's must-have truth #4 and UI-SPEC §4.1/§4.3 both assert `GWButtonVariant.secondary`'s foreground text is an unfixed, inherited WCAG AA failure in light mode (raw `brandPrimaryStrong` #0AAEE6 at 1.93:1 on light `surfaceBase`). Reading `gw_button.dart` at HEAD shows this is no longer true: quick task `260721-fa7` (landed the same day, before this plan executed) already repointed the `secondary` variant's foreground from `GeniusWalletColors.brandPrimaryStrong` to the new appearance-aware `GeniusWalletColors.brandPrimaryOnSurface` (light value `#0A6885`, code-comment-measured at 4.76:1 on `surfaceBase` — passes the 4.5:1 AA text floor). This plan did NOT fix it (nothing in Tasks 1-2 touches `gw_button.dart`) — it was already fixed by unrelated same-day work. **This means Task 3 step 8 of the plan's walk recipe ("record the inherited defect, do not blame this phase") is now stale guidance** — the walker should re-verify the secondary button's light-mode legibility against current code rather than assume the described 1.93:1 failure still reproduces. Flagging this explicitly rather than silently updating the walk recipe myself, per the "STOP and report rather than improvising" instruction for plan/code contradictions.
- **Walk-driven fix, applied per Rule 1 (auto-fix bugs — broken behavior found at verification):** the Task 3 walk, run on a genuinely wallet-less fresh-install profile, found `wallet_creation_screen.dart`'s three CTAs rendering flush against the window edges with zero horizontal gutter at narrow (mobile-width) windows. Confirmed by reading the file: `BoxConstraints(maxWidth:)` on a `ConstrainedBox` only binds when the *incoming* constraint is wider than it; `Center` gives its child loosened constraints derived from the ambient viewport width, so once the window is narrower than `GeniusBreakpoints.small * 2/3` (≈427px), the intersection collapses to the viewport width itself and the `stretch` `Column` fills edge-to-edge. This is a pre-existing desktop-first assumption present in every `GeniusBreakpoints.small`-constrained onboarding screen (`legal_screen.dart`, `select_wallet_type_screen.dart`, `recovery_phrase_screen.dart`, `verify_recovery_phrase_screen.dart`, `import_security_screen.dart`, `pin_screen.dart`) — **not introduced by Task 1** — but Task 1 re-skinned this specific screen and the walk is Task 1's own gate, so it was fixed here rather than deferred to whichever plan owns those other files. Fixed by wrapping the existing `ConstrainedBox` in `Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8))` (16px), placed OUTSIDE the `ConstrainedBox` so the gutter applies *in addition to* the max-width centring rather than instead of it. Token choice: `GeniusWalletConsts.space8` (16px) was picked over inventing a new value because it is the closest existing match to two real precedents in this codebase — `submit_logs_screen.dart:212-213` uses the identical `Center → Padding → ConstrainedBox` shape at a raw `EdgeInsets.all(16)`, and `markets_screen.dart`'s page-level `GridView` padding uses `space8` as its own page-edge horizontal gutter. No onboarding screen has an established mobile gutter today, so there was no in-family "house rhythm" to match exactly — `space8` is the closest existing token to the closest existing structural precedent. Verified the wide-window behavior is unchanged by construction: the outer `Padding` only becomes the binding constraint once available width drops below `maxWidth + 32` (≈459px); above that, `ConstrainedBox`'s `maxWidth` remains the sole binding constraint exactly as before. Checked both Task 2 flow shells for the same class of defect and found neither is affected — `existing_wallet_flow.dart` and `new_wallet_flow.dart` have no `Center`/`ConstrainedBox` of their own; `Scaffold.body` is `_buildStep(context, newPinCubit, state)` directly, so any narrow-width gutter issue would live inside whichever step screen is rendered (out of this plan's file scope), not in the shell itself — no change made to either flow file. `flutter analyze lib/onboarding/view/wallet_creation_screen.dart` clean; `flutter analyze lib` held at the 61-issue baseline. Committed as `67e2821`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug, walk-driven] Fixed narrow-width zero-gutter on wallet_creation_screen.dart's entry CTAs**
- **Found during:** Task 3 (the blocking human-verify checkpoint walk), on a genuine fresh-install profile
- **Issue:** `ConstrainedBox(maxWidth: GeniusBreakpoints.small * 2/3)` only constrains when the incoming viewport is wider than that value; once the window narrows below it, the constraint is inert and the CTA column stretches edge-to-edge with no inset — a pre-existing desktop-first assumption Task 1's re-skin inherited (not introduced by it), first surfaced on the phase's own first-run gate
- **Fix:** wrapped the existing `ConstrainedBox` in `Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8))` (16px), placed outside the `ConstrainedBox` so the gutter is additive to, not a replacement for, the max-width centring
- **Files modified:** `lib/onboarding/view/wallet_creation_screen.dart`
- **Verification:** `flutter analyze` clean on the file; `flutter analyze lib` baseline held at 61; wide-window centring behavior unchanged by construction (Padding only binds below `maxWidth + 32`); confirmed neither Task 2 flow shell shares the defect (no `Center`/`ConstrainedBox` of their own)
- **Committed in:** `67e2821`

---

**Total deviations:** 1 auto-fixed (1 walk-driven Rule 1 bug fix). The two "deviations from UI-SPEC §4.1/§4.2" documented above under Decisions Made were pre-authorized by the plan itself, not discovered mid-execution, and are not counted here.
**Impact on plan:** Necessary for correctness — shipping the first screen a new user sees glued to the window bezel on any narrow window is not acceptable. No scope creep: fix is confined to the one file Task 1 owns; the two files Task 2 owns were checked and confirmed unaffected, and no change was made to them.

## Issues Encountered

The stale-premise discovery (GWButtonVariant.secondary AA fix already landed, see Decisions Made) surfaced during pre-execution file reads and is reported, not treated as a blocking issue for Tasks 1-2 (neither task touches `gw_button.dart`). The narrow-width gutter defect (see Deviations above) was found and resolved mid-walk per Rule 1; it did not require a new checkpoint or user decision since it is a direct, unambiguous bug fix within Task 1's own file.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Task 3 — the blocking human-verify checkpoint — is IN PROGRESS (re-walk pending after the narrow-width fix) and must complete before this plan (and therefore SCR-02's entry-screen criterion) can be marked complete.** Full recipe is in `06-01-PLAN.md`'s Task 3 `<how-to-verify>` block. Remaining:

1. Re-confirm the entry screen at narrow/short window sizes now shows a real gutter (no longer glued to the edge) at both the default and narrow sizes, in both appearance modes.
2. Re-confirm the wide-window layout is visually unchanged from the already-approved pre-fix rendering (the fix is constraint-inert above `maxWidth + 32`).
3. Both CTAs entering their flows, the Cancel branch (reached via account dropdown → add another wallet), in-flow back navigation on both flow shells, and a live in-place appearance flip via the dev bubble.
4. **The blocking mesh light-mode gate (step 7):** judge `GWMeshBackground` honestly in light mode. STATE.md records this component as dark-only-by-design (painter reads no appearance, black-alpha-38 vignette over the light `surfaceBase`). If it reads muddy or washes out any CTA, the sanctioned fallback is a one-line change (drop `GWMeshBackground`, let the wired `scaffoldBackgroundColor` stand) — this is NOT optional per the user's constraints for this session; do not ship a degraded light-mode first screen.
5. **Re-verify, don't assume, the GWButtonVariant.secondary light-mode observation** (step 8) — the plan expects an inherited AA failure that the code no longer has (see Decisions Made above). Confirm the actual current contrast reads legibly in light mode rather than filing a stale defect report.

Once Task 3 fully passes and its outcome (mesh keep-or-fallback decision + secondary-button re-verification + narrow-width fix confirmation) is recorded, this plan's SUMMARY should be updated (or a follow-up note added) to close out `requirements-completed: [SCR-02]` for this entry-half slice, and STATE.md's position should advance.

No code blockers exist for 06-02 through 06-06 — the chrome this plan lays (entry screen + flow AppBars) is structurally complete regardless of the walk's mesh decision, since the fallback is a one-line, already-scoped change. **Note for whichever plan owns `legal_screen.dart`, `select_wallet_type_screen.dart`, `recovery_phrase_screen.dart`, `verify_recovery_phrase_screen.dart`, `import_security_screen.dart`, and `pin_screen.dart` (06-02..06-05):** each shares the same `Center`/`ConstrainedBox(maxWidth: GeniusBreakpoints.small...)` desktop-first pattern this plan just found broken at narrow widths on the entry screen. They were not touched here (out of this plan's file scope) but likely need the same `Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8))` treatment during their own re-skin walks.

---
*Phase: 06-onboarding*
*Completed: 2026-07-21 (Tasks 1-2 + 1 walk-driven fix; Task 3 walk in progress)*

## Self-Check: PASSED

- FOUND: lib/onboarding/view/wallet_creation_screen.dart
- FOUND: lib/onboarding/existing_wallet/routes/existing_wallet_flow.dart
- FOUND: lib/onboarding/new_wallet/routes/new_wallet_flow.dart
- FOUND commit 3e1f432 (Task 1)
- FOUND commit b9c565f (Task 2)
- FOUND commit 67e2821 (walk-driven fix, Rule 1)
