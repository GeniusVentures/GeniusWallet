---
phase: 06-onboarding
plan: 02
subsystem: ui
tags: [flutter, onboarding, gw_button, gw_checkbox, gw_wallet_card, wcag, gap-04, narrow-width-gutter, walk-outstanding]

# Dependency graph
requires:
  - phase: 06-onboarding
    plan: 01
    provides: "The space8-outside-ConstrainedBox narrow-width-gutter pattern (commit 67e2821) and the systemic-gutter todo naming legal_screen.dart/select_wallet_type_screen.dart as confirmed instances"
  - phase: 03-gw-component-library
    provides: "GWButton, GWCheckbox, GWWalletCard primitives (GWWalletCard was zero-caller before this plan)"
provides:
  - "Re-skinned shared Legal step (lib/onboarding/existing_wallet/view/legal_screen.dart) serving BOTH ExistingWalletFlow.ImportWalletStep.legal and NewWalletFlow.NewWalletStep.agreement — token typography, two GWButton secondary link buttons, GWCheckbox with its own label, GWButton gradient Continue with the accepted?onContinue:null gate preserved"
  - "GAP-04 closed as a mechanical 1:1 component swap — select_wallet_type_screen.dart's Card+ListTile row is now GWWalletCard (its first real non-gallery consumer), data/event/list-shell/commented-out-networks byte-identical"
  - "wallet_routes.dart's two preserved fallback strings token-touched (bodyMd/gw.textSecondary), NOT reconciled to GWErrorState; all 8 GoRoutes byte-identical; canonical Loading import unrepointed"
  - "Proactive gutter fix on both screens (Padding(space8) outside ConstrainedBox), applied ahead of the walk per the 06-01 carried-forward todo rather than waiting to rediscover it"
affects: [06-03, 06-04, 06-05, 06-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "GWWalletCard(walletIcon:, walletName:, onTap:) as the 1:1 replacement for Card+ListTile(leading: Image.asset, title: Text, trailing: Icon(chevron_right)) rows — first real consumer of this Phase-3 primitive"
    - "Center -> Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8)) -> ConstrainedBox(maxWidth:) applied proactively (not walk-driven) on both this plan's breakpoint-constrained screens, per the 06-01 carried-forward todo"

key-files:
  created:
    - .planning/phases/06-onboarding/deferred-items.md
  modified:
    - lib/onboarding/existing_wallet/view/legal_screen.dart
    - lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart
    - lib/onboarding/routes/wallet_routes.dart

key-decisions:
  - "Applied the space8-outside-ConstrainedBox gutter fix PROACTIVELY on both legal_screen.dart and select_wallet_type_screen.dart, per explicit instruction and the 06-01 carried-forward todo, rather than waiting for Task 3's walk to rediscover the same class of bug a second time. Recorded as a deliberate, walk-informed inclusion (Rule 2 — missing critical functionality: narrow-width usability), not silent scope creep. Wide-window centring is unchanged by construction (Padding only binds below maxWidth+32) — same argument 06-01 verified for wallet_creation_screen.dart, now confirmed to hold for these two additional screens as well."
  - "wallet_routes.dart's top import changed from package:flutter/widgets.dart to package:flutter/material.dart — a necessary, mechanical consequence of Theme.of(context) (used by the fail-soft GWColors read), not a scope violation. material.dart is a superset of widgets.dart; every existing BlocBuilder/Center/Text usage in the file is unaffected."
  - "GWCheckbox's label param used directly (dropping the CheckboxListTile wrapper) per Phase 4 §3.1's SwitchListTile->GWSwitch precedent; the agreement string preserved verbatim, apostrophe included."
  - "Neither wallet_routes.dart fallback was reconciled to GWErrorState — loadUserStatus is owned by AppBloc, not by anything this file can reach, so a retry button here would have no action behind it. Preserve, don't reconcile (UI-SPEC §2.3, mirroring Phase 5 §6's dashboard discipline)."
  - "GAP-04 confirmed closed as a mechanical 1:1 swap with ZERO IA change: same SupportedWallet model, same hardcoded single Ethereum entry, same three commented-out future networks (XRP/Stellar/Tron — grep-gate-counted, not merely eyeballed), same ListView.separated shell, same ImportWalletSelected dispatch. No product decision was owed under the GAP treatment test."
  - "wallet_routes.dart confirmed to have 8 GoRoutes (not 7 as an earlier ROADMAP estimate implied) — the scope-fenced /backup_phrase route is one of them and was left untouched, per the plan's explicit correction of that stale premise."
  - "Deferred (not fixed): a pre-existing, unrelated verify_additive_boundary.sh Check 2 failure (duplicate private class _Section in lib/dev/design_gallery_screen.dart and lib/dev/dev_tools_bubble.dart) was found while running Task 2's verify gate. Confirmed present at HEAD before this plan's changes (reproduced with this plan's edits stashed out). Out of this plan's file scope — logged to .planning/phases/06-onboarding/deferred-items.md, not fixed."

requirements-completed: []  # NOT marked complete: Task 3 (the blocking human-verify checkpoint/walk) is OUTSTANDING. GAP-04 and SCR-02's entry-half for this plan's two screens are code-complete and gate-verified, but this project's standing no-unearned-PASS rule withholds requirements-completed until the walk records pass/fail per criterion.

coverage:
  - id: D1
    description: "legal_screen.dart re-skinned: headlineLg/bodyMd token typography, two GWButton secondary link buttons (both gnus.ai URLs preserved), GWCheckbox with its own label param (agreement string verbatim), GWButton gradient Continue with the accepted?onContinue:null consent gate preserved; proactive narrow-width gutter fix applied"
    requirement: "SCR-02"
    verification:
      - kind: other
        ref: "flutter analyze lib/onboarding/existing_wallet/view/legal_screen.dart -- No issues found!"
        status: pass
      - kind: other
        ref: "plan's automated verify gate (GWColors read present, GWCheckbox( present, >=3 GWButton(, accepted ? onContinue : null gate present, both gnus.ai URLs present, no CheckboxListTile/OutlinedButton/FilledButton/headlineLarge/LayoutBuilder/app_screen_with_header on a non-comment line) -- all passed"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 checkpoint: Legal step walk (both flow callers, disabled/enabled Continue gate, checkbox dark-mode legibility, both URLs, live appearance flip, narrow-width check, both appearance modes)"
        status: unknown
    human_judgment: true
    rationale: "The consent-gate visual distinctness, checkbox dark-mode legibility (open STATE todo), live-flip correctness, and narrow-width safety require a human to judge in the running app. Task 3 is a checkpoint:human-verify (gate=blocking) and has not yet been walked."
  - id: D2
    description: "GAP-04 closed: select_wallet_type_screen.dart's Card+ListTile row swapped to GWWalletCard (icon/name/onTap byte-identical to develop's data and ImportWalletSelected dispatch); supportedNetworks list, all 3 commented-out future networks, ListView.separated shell, and outer Center/ConstrainedBox/Column unchanged; separator token-backed at space10; proactive narrow-width gutter fix applied"
    requirement: "GAP-04"
    verification:
      - kind: other
        ref: "flutter analyze lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart -- No issues found!"
        status: pass
      - kind: other
        ref: "plan's automated verify gate (GWWalletCard( present, ImportWalletSelected( present, Ethereum entry present, 3 commented SupportedWallet(name: 'XRP'|'Stellar'|'Tron' entries counted, no ListTile/chevron_right/headlineLarge on a non-comment line) -- all passed"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 checkpoint: GAP-04 walk — the wallet-type step renders as GWWalletCard AND tapping it still routes to the import-security step (routing is half of criterion 4); single-item list reads as deliberate; narrow-width check; both appearance modes"
        status: unknown
    human_judgment: true
    rationale: "A good-looking card that does not navigate fails criterion 4 — routing must be confirmed live in the running app, which only a human walk can do. Task 3 has not yet been walked."
  - id: D3
    description: "wallet_routes.dart's two identical fallback Text widgets given bodyMd/gw.textSecondary styling; string preserved verbatim, NOT reconciled to GWErrorState; all 8 GoRoutes and the canonical Loading import unchanged"
    requirement: "GAP-04"
    verification:
      - kind: other
        ref: "flutter analyze lib/onboarding/routes/wallet_routes.dart -- No issues found!"
        status: pass
      - kind: other
        ref: "plan's automated verify gate (both fallback strings present verbatim [count 2], all 8 GoRoute( present, no shadow Loading import path) -- all passed"
        status: pass
    human_judgment: false
    rationale: "n/a — auto-passes: every automated verification passed and this deliverable's fallback branch is unreachable in practice (per UI-SPEC §2.3), so no live-app walk item was assigned to it in the plan's Task 3 recipe."

duration: ~35min (Tasks 1-2; Task 3 checkpoint reached and NOT walked this session)
completed: 2026-07-21
status: outstanding
---

# Phase 06 Plan 02: Legal step + GAP-04 GWWalletCard swap Summary

**Re-skinned the shared Legal step (both flows' first step) and closed GAP-04 by swapping `select_wallet_type_screen.dart`'s row to `GWWalletCard` — Tasks 1-2 complete and gate-verified; Task 3 (the blocking human-verify walk) is OUTSTANDING, not walked this session.**

Tasks 1 and 2 (`type="auto"`) are complete, committed, and pass every automated verify gate in the plan. **Task 3 — the blocking `checkpoint:human-verify` walk — has been reached but NOT performed.** Per explicit instruction, this executor stopped at the checkpoint rather than attempting or self-approving the walk. `status: outstanding` in this SUMMARY's frontmatter reflects that; `requirements-completed` is deliberately left empty until the walk records pass/fail per criterion, per this project's standing no-unearned-PASS rule.

## Performance

- **Started:** 2026-07-21 (this session)
- **Completed (Tasks 1-2 only):** 2026-07-21
- **Duration:** ~35 min
- **Tasks:** 2 of 3 complete (Task 3 is the outstanding checkpoint)
- **Files modified:** 3 (+ 1 new deferred-items.md)

## Accomplishments
- `legal_screen.dart` — the ONE file shared by both `ExistingWalletFlow.ImportWalletStep.legal` and `NewWalletFlow.NewWalletStep.agreement` — re-skinned in place: "Legal" heading on `headlineLg`/`gw.textPrimary`, body on `bodyMd`/`gw.textSecondary`, both "Privacy Policy"/"Terms of Service" `OutlinedButton`s replaced with `GWButton(variant: secondary, size: lg, expand: true)` (both `launchWebSite` calls and both gnus.ai URLs byte-identical), the `CheckboxListTile`+`AutoSizeText` replaced with `GWCheckbox`'s own `label` param (agreement string preserved verbatim, apostrophe included), and `FilledButton` replaced with `GWButton(variant: gradient, ...)` with the `accepted ? onContinue : null` consent gate preserved exactly.
- GAP-04 closed as a mechanical 1:1 component swap: `select_wallet_type_screen.dart`'s `Card`+`ListTile` row is now `GWWalletCard(walletIcon:, walletName:, onTap:)` — `GWWalletCard`'s (Phase 3, zero callers to date) first real non-gallery consumer. The `supportedNetworks` list, the single hardcoded Ethereum entry, all THREE commented-out future networks (XRP/Stellar/Tron), the `ListView.separated` shell (`NeverScrollableScrollPhysics`, `shrinkWrap: true`), the `SupportedWallet` class, and the `ImportWalletSelected` dispatch are all byte-identical. The separator height is now token-backed `GeniusWalletConsts.space10` (20px — numerically identical to the old raw `20`).
- `wallet_routes.dart`'s two identical fallback `Text` widgets given `bodyMd`/`gw.textSecondary` styling; the string `'Something went wrong! Please reload the app.'` preserved verbatim at both sites and deliberately NOT reconciled to `GWErrorState` (no retry handler this file can wire — `loadUserStatus` is owned by `AppBloc`). All 8 `GoRoute`s (including the scope-fenced `/backup_phrase`) are byte-identical; the canonical `Loading` import is unrepointed to the shadow.
- **Proactive gutter fix (applied ahead of the walk, per explicit instruction and the 06-01 carried-forward todo):** both `legal_screen.dart` and `select_wallet_type_screen.dart` had the confirmed latent narrow-width bug (`ConstrainedBox(maxWidth:)` inert below that width, zero horizontal inset) — fixed on both by wrapping the existing `ConstrainedBox` in `Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8))`, placed OUTSIDE the `ConstrainedBox` exactly per the `wallet_creation_screen.dart`/`67e2821` pattern, so wide-window centring is unchanged by construction.
- `flutter analyze lib` holds at the 61-issue baseline; all three touched files individually analyze-clean.

## Task Commits

Each task was committed atomically:

1. **Task 1: Re-skin legal_screen.dart** - `47527bc` (feat)
2. **Task 2: GAP-04 — swap wallet-type row to GWWalletCard + token-touch wallet_routes.dart** - `ba8e412` (feat)

Task 3 (`checkpoint:human-verify`, `gate="blocking"`) has NOT been performed this session — no commit for it exists. It must be walked by a fresh agent/human session before this plan can be closed.

## Files Created/Modified
- `lib/onboarding/existing_wallet/view/legal_screen.dart` — token typography, GWButton link buttons + gradient Continue, GWCheckbox with its own label, proactive gutter fix
- `lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart` — GWWalletCard row swap, token typography, token-backed separator, proactive gutter fix
- `lib/onboarding/routes/wallet_routes.dart` — both fallback strings token-touched, import switched to `flutter/material.dart` (required for `Theme.of`)
- `.planning/phases/06-onboarding/deferred-items.md` (new) — records the pre-existing, unrelated `verify_additive_boundary.sh` Check 2 failure found during Task 2's verify gate

## Decisions Made

- **Proactive gutter fix (Rule 2 — missing critical functionality), NOT walk-driven this time:** applied the `space8`-outside-`ConstrainedBox` pattern to both screens BEFORE the walk, per explicit instruction and the 06-01 carried-forward todo (`.planning/todos/pending/2026-07-21-systemic-mobile-gutter-missing-on-onboarding-breakpoint-cons.md`), which had already confirmed both files as breakpoint-constrained with zero horizontal inset — the same class of bug 06-01 found and fixed reactively on `wallet_creation_screen.dart` (commit `67e2821`). Verified by construction (not merely asserted) that wide-window centring is unchanged: the outer `Padding` only becomes the binding constraint once available width drops below `maxWidth + 32` (~459px); above that, `ConstrainedBox`'s `maxWidth` remains the sole binding constraint exactly as before Task 3's walk must still confirm this live at narrow AND wide widths per its recipe's step 7 — the by-construction argument is necessary but the walk is still the actual verification for a visual property.
- **`wallet_routes.dart`'s import changed from `package:flutter/widgets.dart` to `package:flutter/material.dart`:** `Theme.of(context)` (needed for the fail-soft `GWColors` read the plan specifies) is only exposed via `material.dart`, not `widgets.dart`. `material.dart` is a superset, so every existing `BlocBuilder`/`Center`/`Text` usage in the file resolves identically — this is a necessary mechanical consequence of the typography-only edit the plan specifies, not a scope violation.
- **GAP-04 confirmed closed with zero IA change:** re-verified live against the plan's own claim — `SupportedWallet {name, image, coinType}` model, the single hardcoded Ethereum entry, and all three commented-out future networks are byte-identical before and after. No product decision was owed under the GAP treatment test, matching the plan's premise exactly.
- **`wallet_routes.dart` confirmed at 8 `GoRoute`s**, not 7 — verified by direct grep count before editing, matching the plan's explicit correction of the stale ROADMAP estimate. The scope-fenced `/backup_phrase` route is untouched.
- **Neither fallback reconciled to `GWErrorState`:** confirmed no retry handler exists in this file for `loadUserStatus` (owned by `AppBloc`), so a button with no action behind it would be worse than plain text — preserved per UI-SPEC §2.3.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical, proactive] Applied narrow-width gutter fix to both screens ahead of the walk**
- **Found during:** pre-execution read of the 06-01 carried-forward todo and this plan's own explicit instruction
- **Issue:** `legal_screen.dart` and `select_wallet_type_screen.dart` both had `ConstrainedBox(maxWidth: GeniusBreakpoints.small * 2/3)` inside a `Center` with zero horizontal inset — the confirmed same-class bug `wallet_creation_screen.dart` shipped with and 06-01's walk found and fixed
- **Fix:** wrapped each screen's existing `ConstrainedBox` in `Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8))`, placed OUTSIDE the `ConstrainedBox` so the gutter is additive to (never a replacement for) the max-width centring — identical pattern to commit `67e2821`
- **Files modified:** `lib/onboarding/existing_wallet/view/legal_screen.dart`, `lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart`
- **Verification:** `flutter analyze` clean on both files; `flutter analyze lib` baseline held at 61; wide-window centring behavior unchanged by construction (Padding only binds below `maxWidth + 32`) — Task 3's walk must still confirm this live per its recipe's step 7
- **Committed in:** `47527bc` (Task 1), `ba8e412` (Task 2)

---

**Total deviations:** 1 auto-fixed (1 Rule-2 proactive gutter fix, applied to both files touched by this plan).
**Impact on plan:** Necessary for correctness — applying a confirmed, already-diagnosed defect proactively rather than waiting for a second walk to rediscover it is strictly cheaper and was explicitly requested. No scope creep: confined to the two files this plan owns; the pattern and token choice were not invented here, they were carried forward verbatim from 06-01's already-verified fix.

## Issues Encountered

A pre-existing, unrelated `verify_additive_boundary.sh` Check 2 failure (duplicate private class `_Section` in `lib/dev/design_gallery_screen.dart` and `lib/dev/dev_tools_bubble.dart`, neither touched by this plan) was found while running Task 2's verify gate. Confirmed present at HEAD before this plan's changes by reproducing it with the plan's edits stashed out. Per the executor's scope-boundary rule, this is logged to `.planning/phases/06-onboarding/deferred-items.md` and NOT fixed — it is out of this plan's file scope. All of this plan's OWN grep-based verify-gate assertions (GWWalletCard presence, ImportWalletSelected dispatch, commented-network count, fallback-string count, GoRoute count, no shadow Loading import) passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Task 3 (`checkpoint:human-verify`, `gate="blocking"`) is OUTSTANDING.** A fresh session must run the walk recipe exactly as written in `06-02-PLAN.md`'s Task 3 (`<how-to-verify>`), in BOTH appearance modes, on a genuinely wallet-less profile (see 06-01 Task 3 step 0 — clear all four persistence layers; the 06-01 walk consumed the previous fresh-install profile). The walk must confirm, per criterion:

1. The Legal step renders identically from BOTH `ExistingWalletFlow` and `NewWalletFlow` entry points.
2. The disabled/enabled `Continue` consent gate is visually distinguishable in both states, both modes.
3. `GWCheckbox`'s unchecked/disabled legibility in dark mode (the open STATE todo this screen surfaces).
4. Both "Privacy Policy"/"Terms of Service" links open the correct gnus.ai URLs.
5. GAP-04's routing half: the `GWWalletCard` row actually navigates to the import-security step, not just renders correctly.
6. The single-item wallet list reads as deliberate, not broken (no stray separator, no overflow).
7. Narrow/short window safety on both screens (the proactive gutter fix, applied this session — not yet walked).
8. Live appearance-mode flip on the Legal step.
9. Re-record the inherited `GWButtonVariant.secondary` light-mode legibility observation against the CURRENT code (06-01 found the plan's premise about this being an unfixed 1.93:1 failure is now STALE — quick task `260721-fa7` already fixed it to 4.76:1 before 06-01 ran; this plan's own walk should re-verify the same way 06-01's did rather than assume either the old failure or 06-01's fix without re-checking).

No code blockers exist for `06-03` through `06-06` — the two files this plan owns are structurally complete and gate-verified. **`06-02` remains OPEN until Task 3 is walked and its outcome recorded.**

---
*Phase: 06-onboarding*
*Completed: Tasks 1-2 only, 2026-07-21. Task 3 (blocking human-verify checkpoint) OUTSTANDING — plan not yet closed.*

## Self-Check: PASSED

- FOUND: lib/onboarding/existing_wallet/view/legal_screen.dart
- FOUND: lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart
- FOUND: lib/onboarding/routes/wallet_routes.dart
- FOUND: .planning/phases/06-onboarding/deferred-items.md
- FOUND commit 47527bc (Task 1)
- FOUND commit ba8e412 (Task 2)
- Task 3 checkpoint: NOT walked this session — no commit exists for it, by design (STOP instruction honored)
