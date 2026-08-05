---
phase: 02-design-tokens-verification-loop
plan: 05
subsystem: ui
tags: [flutter, theme, design-tokens, dev-tools, go_router, verification]

# Dependency graph
requires:
  - phase: 02-02
    provides: "kShowDevTools flag, DevToolsWidget's kDebugMode && kShowDevTools gate at responsive_overlay.dart:97"
  - phase: 02-04
    provides: "GeniusWalletTypography.headlineLg/bodyMd, GWDecorations.surface(), GeniusWalletColors.textOnBrand, GeniusWalletGradient.brandCta"
provides:
  - "TokenProbeScreen (lib/dev/token_probe_screen.dart) — dev-only surface proving the token layer resolves and flips light/dark at runtime"
  - "/dev/token-probe route, registered additively at the top level of geniusWalletRouter, outside the ShellRoute"
  - "Tokens button inside DevToolsWidget, inheriting the existing kDebugMode && kShowDevTools gate with no second flag"
  - "02-VERIFICATION.md — the BLD-02 verification record for all 5 ROADMAP Phase 2 success criteria"
  - "02-UI-SPEC.md signed off: all 6 checker dimensions ticked, status draft -> approved"
affects: [Phase 3 (gw_* component library) inherits the BLD-02 loop this document establishes; Phase 4+ probe pattern for future dev surfaces]

# Tech tracking
tech-stack:
  added: []
  patterns: ["Dev-only probe surface: additive route + gated entry point, ValueListenableBuilder on a singleton ValueNotifier to make a toggle actually rebuild", "Verification record structure: one section per ROADMAP criterion, each with what-was-run/what-was-observed/status, OUTSTANDING items handed explicitly to the human rather than inferred"]

key-files:
  created:
    - lib/dev/token_probe_screen.dart
    - .planning/phases/02-design-tokens-verification-loop/02-VERIFICATION.md
  modified:
    - lib/navigation/router.dart
    - lib/test/dev_tools_widget.dart
    - .planning/phases/02-design-tokens-verification-loop/02-UI-SPEC.md

key-decisions:
  - "TokenProbeScreen uses a plain Scaffold, not AppScreenView (out of scope, has its own styling contract) — per UI-SPEC §9."
  - "Body wrapped in ValueListenableBuilder<GWAppearanceMode> on GWAppearance.instance (GWAppearance itself extends ValueNotifier<GWAppearanceMode>) — without this the toggle persists the mode via setMode() but nothing rebuilds and the flip looks broken."
  - "GWAppearance.instance.load() called once in initState — exercises the preferences Hive box plan 02-01 opened and turns it from dead code into something the human check actually proves via the reopen-and-restore round-trip."
  - "Route registered as a standalone top-level GoRoute (outside ShellRoute) so the probe does not mount into the nav shell, which is Phase 4's subject."
  - "Tokens button added inside DevToolsWidget rather than as a second gated call site — inherits kDebugMode && kShowDevTools for free, no second flag introduced (grep-gated: 0 occurrences of kShowDevTools|kDebugMode inside dev_tools_widget.dart itself)."
  - "02-VERIFICATION.md marks criteria 1 and 3 OUTSTANDING and criterion 4 PARTIAL rather than PASS, even though the probe surface exists and analyze is clean — because this agent cannot launch and observe a native Windows GUI, and an unearned PASS in this document is the exact failure mode (threat T-02-18) BLD-02 exists to prevent."
  - "Criterion 2 marked PASS on the strength of three prior human-confirmed walks (post 02-01/02-02, 02-03, 02-04) plus a fresh mechanical zero-deletion proof that this plan's own router.dart/dev_tools_widget.dart edits are additive/gated — not on a fresh human walk of this exact commit, which is called out explicitly rather than assumed."
  - "Onboarding Mock button (criterion 4) recorded as an explicit Phase 6 deferral, not a pass — it does not exist on develop today."
  - "appBarHeight 60->65 bump remains a Phase 4 deferral, unchanged from 02-03's decision — not touched or re-litigated here."

patterns-established:
  - "Probe-surface pattern for future dev-only verification screens: additive route outside ShellRoute + single gated entry point inside the existing dev-tools widget, no new flag."
  - "Verification-record honesty pattern: OUTSTANDING/PARTIAL statuses are first-class, not something to round up to PASS; every status carries either a human observation, a mechanical proof, or an explicit deferral reason."

requirements-completed: [DS-01, BLD-02]

coverage:
  - id: D1
    description: "TokenProbeScreen renders heading/body/card/gradient-button from the new additive tokens, flips live via ValueListenableBuilder on GWAppearance.instance, restores persisted mode via load(), and does not instantiate the dormant canvas-background widget or AppScreenView"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "grep gates (ValueListenableBuilder<GWAppearanceMode>, setMode, load() exactly once, headlineLg, GWDecorations.surface(, brandCta, textOnBrand all present; canvas-background widget/AppScreenView/Colors.white all absent); flutter analyze lib (0 errors, 34 pre-existing baseline issues unchanged, none in the new file)"
        status: pass
    human_judgment: false
  - id: D2
    description: "/dev/token-probe route registered additively at the top level of geniusWalletRouter, outside ShellRoute; Tokens button added inside DevToolsWidget inheriting the existing kDebugMode && kShowDevTools gate with no second flag or call site; responsive_overlay.dart/theme.dart/main.dart untouched"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "grep gates (route path + import present, button present, 0 gate-flag references inside dev_tools_widget.dart itself); git diff --stat -- responsive_overlay.dart theme.dart main.dart (empty); git diff on router.dart (7 insertions, 0 deletions); flutter analyze lib (0 errors)"
        status: pass
    human_judgment: false
  - id: D3
    description: "02-VERIFICATION.md records the standing run recipe verbatim and a real observation plus status for each of ROADMAP Phase 2's five success criteria; 02-UI-SPEC.md's six checker dimensions ticked and approval line set"
    requirement: "BLD-02"
    verification:
      - kind: other
        ref: "grep gates (recipe string present, >=5 'criterion' mentions, 0 unticked Dimension boxes in UI-SPEC.md); file existence checks"
        status: pass
    human_judgment: false
  - id: D4-runtime-probe
    description: "The probe actually opens, renders every token correctly, and flips dark/light live in a running Windows debug build (ROADMAP criterion 3); hot reload + Dart debugger breakpoint against TokenProbeScreen.build() (ROADMAP criterion 1); Dev row + Tokens button present with --dart-define=GW_DEV_TOOLS=true (second half of ROADMAP criterion 4)"
    verification: []
    human_judgment: true
    rationale: "Requires launching and visually observing a native Windows GUI window and an interactive Dart debugger session, which this agent has no capability to do. This is new surface area created entirely by this plan, so per the phase's own rule (recording an unearned PASS is the exact failure mode BLD-02 exists to prevent) it cannot be inferred from a clean flutter analyze or from code review alone. Recorded as OUTSTANDING in 02-VERIFICATION.md with the exact human walk to perform."

# Metrics
duration: ~7min
completed: 2026-07-16
status: complete
---

# Phase 2 Plan 5: Token Probe Surface & BLD-02 Verification Record Summary

**Built a dev-only TokenProbeScreen (heading/body/card/CTA-gradient, live dark/light flip via GWAppearance) behind a new gated Tokens button and additive /dev/token-probe route, then wrote 02-VERIFICATION.md recording real status — PASS, PARTIAL, or explicitly OUTSTANDING — for all 5 ROADMAP Phase 2 success criteria, closing out the phase.**

## Performance

- **Duration:** ~7 min
- **Started:** 2026-07-16T16:07:11Z
- **Completed:** 2026-07-16T16:14:19Z
- **Tasks:** 3/3 completed
- **Files modified:** 5 (2 created, 3 modified)

## Accomplishments

- **Task 1 — Token probe screen:** Built `TokenProbeScreen` at `lib/dev/token_probe_screen.dart`. Renders a heading (`GeniusWalletTypography.headlineLg`), body text (`bodyMd`), a card (`GWDecorations.surface()` with `radius2xl`), a `GeniusWalletGradient.brandCta`-filled button labelled with `GeniusWalletColors.textOnBrand` (never `Colors.white`, per `DESIGN_SYSTEM.md` §5.1), `space*` padding tokens throughout, and an appearance toggle whose label reads the mode it would switch *to*. Wrapped in `ValueListenableBuilder<GWAppearanceMode>` on `GWAppearance.instance` so the toggle actually rebuilds. Calls `GWAppearance.instance.load()` once in `initState`. Does not instantiate the dormant canvas-background decoration widget or `AppScreenView`.
- **Task 2 — Route + gated entry point:** Appended one `GoRoute('/dev/token-probe')` to `geniusWalletRouter`'s top-level `routes:` list (outside the `ShellRoute`, 7 insertions/0 deletions). Added a `Tokens` button inside `DevToolsWidget`'s `Row`, pushing the new route — inherits the existing `kDebugMode && kShowDevTools` gate from `responsive_overlay.dart:97` with no second flag or call site. `responsive_overlay.dart`, `theme.dart`, `main.dart` all confirmed zero diff.
- **Task 3 — BLD-02 verification record:** Wrote `02-VERIFICATION.md`, structured as one section per ROADMAP Phase 2 criterion (1–5), each with what was run, what was observed, and a status. Criterion 2 and 5 marked PASS on the strength of three prior human-confirmed walks plus fresh mechanical zero-deletion proofs. Criteria 1 and 3 marked OUTSTANDING — new surface this plan created that genuinely requires a human running the Windows GUI. Criterion 4 marked PARTIAL (absent-by-default observed; present-with-flag not yet re-observed; onboarding `Mock` button explicitly deferred to Phase 6). Ticked all 6 checker sign-off dimensions in `02-UI-SPEC.md` and set its approval line; frontmatter `status` moved `draft` → `approved`.

## Task Commits

Each task was committed atomically:

1. **Task 1: Build the token probe screen** - `758aa03` (feat)
2. **Task 2: Register the route and add the gated entry point** - `a27f663` (feat)
3. **Task 3: Run the BLD-02 protocol and record it** - `81b9735` (docs)

## Files Created/Modified

- `lib/dev/token_probe_screen.dart` - new dev-only probe screen (116 lines)
- `lib/navigation/router.dart` - +1 import, +1 additive top-level `GoRoute` (7 insertions, 0 deletions)
- `lib/test/dev_tools_widget.dart` - `Row` becomes non-const, +1 `Tokens` button (17 insertions, 6 deletions — reformatting of the pre-existing three lines to add `const`, no content change)
- `.planning/phases/02-design-tokens-verification-loop/02-VERIFICATION.md` - the BLD-02 deliverable
- `.planning/phases/02-design-tokens-verification-loop/02-UI-SPEC.md` - checker sign-off ticked, approval set, status approved

## Decisions Made

- See `key-decisions` in frontmatter above. The central one: this document records genuine OUTSTANDING/PARTIAL statuses rather than rounding up to PASS on the strength of a clean `flutter analyze` — that is precisely the trap that let the forward-port ship 37 regressions while reporting 0 analyze errors.
- Criterion 2 (no-visual-change) is marked PASS using the three prior plans' human-confirmed walks plus a fresh mechanical proof for this plan's own two file edits, rather than requiring a fourth full human walk before this plan could close — the two edits are provably additive (0-deletion route diff) and provably gated (0 flag references inside `dev_tools_widget.dart`), so no new risk to any existing screen was introduced.

## Deviations from Plan

**1. [Minor, not a Rule 1-4 fix] Doc-comment wording adjusted to pass the plan's own negative grep gate**

- **Found during:** Task 1 verification
- **Issue:** The plan's automated verify command greps for the literal string `GWCanvasBackground` anywhere in the file (to prove it isn't instantiated) but the initial doc comment mentioned that class name by name to explain *why* it's absent — the blunt grep can't distinguish a comment reference from an instantiation, so it failed the gate.
- **Fix:** Reworded the comment to describe the dormant class without using its literal identifier ("the dormant canvas-background decoration widget from `genius_wallet_decorations.dart`" instead of `[GWCanvasBackground]`).
- **Files modified:** `lib/dev/token_probe_screen.dart`
- **Verification:** Re-ran the grep gate, 0 matches; `flutter analyze lib` still 0 errors.
- **Committed in:** `758aa03` (part of Task 1 commit — caught before the first commit, not a separate fix commit)

---

**Total deviations:** 1 (cosmetic, no Rule 1-4 classification needed — a doc-comment wording tweak to satisfy the plan's own literal-string gate, not a bug fix, missing functionality, blocker, or architectural change)
**Impact on plan:** None. No scope creep, no behavior change.

## Issues Encountered

None beyond the deviation above. `flutter analyze` required the pinned Flutter SDK on `PATH` (`C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`), consistent with every prior plan in this phase.

## User Setup Required

**Action needed: reload the running debug session and perform the outstanding verification walk.** This plan's mechanical gates (grep proofs, zero-deletion diffs, `flutter analyze`) all pass, but three items in `02-VERIFICATION.md` are explicitly OUTSTANDING/PARTIAL and require a human running the Windows GUI:

1. **Criterion 1** (hot reload + debugger) — edit `GeniusWalletMotion.base`, hot-reload (`r`), confirm it applies; set a breakpoint in `TokenProbeScreen.build()`, open the probe, confirm the debugger hits it.
2. **Criterion 3** (token + appearance probe) — run with `--dart-define=GW_DEV_TOOLS=true`, press `Tokens`, confirm every token renders and the appearance toggle flips the probe live in both directions, and that re-entering restores the persisted mode.
3. **Criterion 4, second half** (dev-gating with the flag on) — confirm the `Dev` row + `Tokens` button are present with the define set, then stop and re-run with no define to confirm both are absent.

Reload guidance, close-the-reference-exe note, and the fastest single pass through all three items are all written out in `02-VERIFICATION.md`'s "Reload guidance for the outstanding items" section — do not re-derive it, follow that section directly.

## Next Phase Readiness

- **DS-01 closes** on the mechanical side: the full token vocabulary exists on `develop`, compiles, and is proven (0-deletion diffs + 3 human walks) not to have repointed any symbol an un-ported screen depends on.
- **BLD-02 is established** as a repeatable, honest verification loop — this document is the template every later phase's own verification record should follow: one section per success criterion, real observations or explicit deferrals, `flutter analyze` demoted to a gate.
- **This is the last plan of Phase 2.** Phase 3 (`gw_*` component library) depends on Phase 2 and can begin planning once the three outstanding human-verification items above are closed. The mechanical/additivity work (criteria 2, 5, and both halves of DS-01/BLD-03's dev-gating minus the flag-on re-check) is done; only the human GUI walk remains.
- **Blocker for phase sign-off:** criteria 1, 3, and the second half of criterion 4 in `02-VERIFICATION.md` are OUTSTANDING/PARTIAL pending the user's reload-and-walk above. Do not consider ROADMAP Phase 2 fully closed until that walk is confirmed and `02-VERIFICATION.md` is updated to reflect it.

---
*Phase: 02-design-tokens-verification-loop*
*Completed: 2026-07-16*

## Self-Check: PASSED

All 3 created/relevant files found on disk (`lib/dev/token_probe_screen.dart`, `02-VERIFICATION.md`, `02-05-SUMMARY.md`); all 3 task commits (`758aa03`, `a27f663`, `81b9735`) found in git log.
