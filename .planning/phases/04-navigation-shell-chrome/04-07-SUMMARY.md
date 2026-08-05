---
phase: 04-navigation-shell-chrome
plan: 07
subsystem: ui
tags: [flutter, error-boundary, appearance, dark-mode, light-mode, crash-recovery, gw-button, gw-icon]

# Dependency graph
requires:
  - phase: 04-navigation-shell-chrome
    provides: "04-01's appearance-aware theme.dart + GWAppearance-driven MaterialApp rebuild; 04-02's GWColors ThemeExtension + gw_* primitives wired with static-getter fallback"
provides:
  - "lib/main.dart -- re-skinned ErrorWidget.builder recovery screen: surfaceBase background, GWIcon.material(statusError), GeniusWalletTypography.titleLg/textPrimary heading, GWButton primary 'Go to Dashboard' action -- all via GeniusWalletColors STATIC GETTERS, zero Theme.of(context) read introduced in main.dart"
affects: []

tech-stack:
  added: []
  patterns:
    - "Recovery-screen static-getter color access: unlike 04-02's live-reskin components (which read Theme.of(context).extension<GWColors>()), a screen mounted by ErrorWidget.builder has no guaranteed Theme ancestor -- it must read GeniusWalletColors' appearance-aware STATIC GETTERS directly (GWAppearance global singleton, no BuildContext dependency) so it renders even when the theme layer itself is what crashed. This is the deliberate INVERSE of the 04-02 D-02 context-read migration."

key-files:
  created: []
  modified:
    - lib/main.dart

key-decisions:
  - "Hand-rolled the Material layout per 04-UI-SPEC.md §6's explicit element mapping table, rather than building on GWErrorState -- GWErrorState/GWButton internally perform their own fail-soft Theme-extension-or-dark-fallback read for message-text/tertiary-variant colors; hand-rolling keeps the background/icon/heading fully on GeniusWalletColors static getters with zero incidental Theme dependency for those three elements, matching the plan's 'needs no BuildContext dependency' key_link most literally."
  - "The mandatory action button (GWButton primary variant, required by the plan regardless of hand-roll-vs-GWErrorState choice) still performs its own internal, pre-existing, fail-soft Theme-extension-or-dark-fallback color read (unchanged by this plan, lives inside gw_button.dart). In the rare crash-above-MaterialApp case, the button falls back to GWColors.dark()'s palette regardless of OS mode -- acceptable per the plan's explicit caveat for a crash screen; documented here per the plan's Output instruction."
  - "The `! grep -nE 'extension<GWColors>' lib/main.dart` verify gate is literal-string-matched, so an early comment draft explaining the static-getter-vs-Theme-read rationale (which quoted the literal string as prose) tripped the gate on its own explanatory comment, not on code. Reworded the comment to describe the pattern without the literal substring ('a Theme-extension context read' instead of the exact API name) -- functionally identical explanation, gate passes cleanly. No code behavior changed by this reword."
  - "Spacing tokens chosen to match develop's exact original pixel values: GeniusWalletConsts.space12 (24px) for the outer Padding.all and the pre-button gap (was literal 24 in both places), GeniusWalletConsts.space8 (16px) for the icon-to-heading gap (was literal 16) -- zero visual delta from develop's original spacing, just token-ized per §8's discipline."

requirements-completed: [BEH-02]

coverage:
  - id: D1
    description: "The ErrorWidget.builder recovery screen is re-skinned: surfaceBase background, GWIcon.material(statusError, 64px), GeniusWalletTypography.titleLg + textPrimary heading ('Something went wrong', copy unchanged), GWButton primary 'Go to Dashboard' with the identical GoRouter.of(navigatorKey.currentContext!).go('/dashboard') handler -- all via GeniusWalletColors STATIC GETTERS, no Theme.of(context).extension<GWColors>() read introduced in main.dart."
    requirement: "BEH-02"
    verification:
      - kind: other
        ref: "flutter analyze lib/main.dart -- 0 issues. flutter analyze lib -- 61 issues total (consistent with the project's ~62-issue pre-existing baseline), none attributable to main.dart. bash tool/verify_additive_boundary.sh -- PASSED (all 3 checks). ! grep -nE 'extension<GWColors>' lib/main.dart -- no match, gate passes. git diff lib/main.dart reviewed directly: the ErrorWidget.builder assignment site and FlutterError.onError block show only the intended body-content hunk; zero diff on MyWindowListener.onWindowClose (lines ~160-183, untouched, separate class)."
        status: pass
    human_judgment: false
  - id: D2
    description: "The Task 2 walk: a build-time exception renders the branded recovery screen (not the red error box) and is legible in both appearance modes (as two separate launches, not a live flip); 'Go to Dashboard' routes to /dashboard; closing the window logs the SDK shutdown line before the process exits (finding 12)."
    requirement: "BEH-02"
    verification: []
    human_judgment: true
    rationale: "No Windows GUI access from this execution environment -- this project has no working flutter test harness (APP-02), and every prior phase's own precedent (02-VERIFICATION.md, 03-VERIFICATION.md, 03-09-SUMMARY.md, 04-01-SUMMARY.md) treats a rendered-pixel/appearance-mode observation and a live debug-console log line as human-only. Recording this as PASS without a human having actually triggered the fault, observed the screen in both modes, and read the shutdown log line would be the exact unearned-PASS/BLD-02 failure mode this project's standing rule exists to prevent. See 'Outstanding: the Task 2 walk' below for the full recipe."

# Metrics
duration: ~20min
completed: 2026-07-18
status: passed
---

# Phase 4 Plan 07: Branded Build-Time-Exception Recovery Screen Summary

**Re-skinned `ErrorWidget.builder`'s recovery `Material` (`GeniusWalletColors.surfaceBase` background, `GWIcon.material(statusError)`, `GeniusWalletTypography.titleLg`/`textPrimary` heading, `GWButton` primary "Go to Dashboard") entirely on appearance-aware STATIC GETTERS -- deliberately not `Theme.of(context).extension<GWColors>()` -- so the crash-recovery screen survives a theme-layer crash; error-boundary wiring and window-close SDK shutdown left byte-unchanged.**

## Performance

- **Duration:** ~20 min
- **Tasks:** 1/1 code task complete; Task 2 (the blocking-human fault-injection walk) is OUTSTANDING, not passed
- **Files modified:** 1

## Accomplishments

- **Task 1 -- Re-skin the ErrorWidget.builder recovery screen** (`c1bba00`): Replaced the hardcoded-dark `Material(color: GeniusWalletColors.deepBlueTertiary)` recovery screen with `Material(color: GeniusWalletColors.surfaceBase)` (appearance-aware, legible in light mode per D-03). Icon: `Icon(color: Colors.redAccent)` -> `GWIcon.material(color: GeniusWalletColors.statusError)`, same 64px size. Heading: raw white/18px `Text` -> `GeniusWalletTypography.titleLg.copyWith(color: GeniusWalletColors.textPrimary)`, copy unchanged ("Something went wrong" -- matches `GWErrorState`'s own default, no rephrase). Action: `ElevatedButton` -> `GWButton` primary variant, same label ("Go to Dashboard") and the identical `GoRouter.of(navigatorKey.currentContext!).go('/dashboard')` handler. All three re-skinned elements (background/icon/heading) read `GeniusWalletColors` STATIC GETTERS directly -- no `Theme.of(context).extension<GWColors>()` read introduced into `main.dart`. Spacing tokenized (`GeniusWalletConsts.space12`/`space8`) at develop's exact original pixel values (24px/16px), zero raw hex/px remaining. `ErrorWidget.builder`'s assignment site and `FlutterError.onError` are otherwise byte-unchanged; `MyWindowListener.onWindowClose` (a separate class, ~80 lines away) was not touched at all -- confirmed by `git diff` showing zero hunks there.
- **`flutter analyze lib/main.dart`: 0 issues.** `flutter analyze lib`: 61 issues total, none in `main.dart` -- consistent with the project's ~62-issue pre-existing baseline (unrelated warnings/infos in other files, e.g. `squid_token_service.dart`, `web_view_mobile.dart`).
- **`bash tool/verify_additive_boundary.sh`: PASSED** (shadow-import boundary, duplicate-class census, `WIRE-` tripwire all unaffected).
- **`! grep -nE 'extension<GWColors>' lib/main.dart`: no match** -- confirms the recovery screen was NOT migrated to a Theme context-read (see Deviations below for one self-caught false-positive during authoring).
- **GWErrorState/GWButton fail-soft caveat, applies only to the mandatory GWButton action button** (this plan hand-rolled the layout rather than building on `GWErrorState`, so `GWErrorState`'s own fail-soft `textSecondary` read is not in play at all): `gw_button.dart`'s `build()` performs `Theme.of(context).extension<GWColors>() ?? GWColors.dark()` internally (pre-existing, unchanged by this plan). In the rare crash-ABOVE-MaterialApp case (no Theme ancestor at all), the button's variant palette resolves off `GWColors.dark()` regardless of the actual OS mode -- for the `primary` variant used here, `background`/`foreground` (`brandPrimary`/`textOnBrand`) are mode-invariant consts anyway, so this fallback has **zero visible effect for this specific button instance**; it would only matter for a variant reading `gw.textPrimary`/`gw.surfaceElevated`/`gw.borderSubtle`, none of which this screen's button uses.
- **BEH-02 `!_dirty`/`GlobalSwapFabHost` sub-clause carry-move (D-08) confirmed**: no `GlobalSwapFabHost` work was introduced or referenced by this plan; that sub-clause remains deferred to the swap-FAB phase, a carry-move not a drop.

## Task Commits

Each task was committed atomically:

1. **Task 1: Re-skin the ErrorWidget.builder recovery screen (visual only)** -- `c1bba00` (feat)

**Task 2 (the blocking-human fault-injection walk) was performed with the user (2026-07-18) and PASSED.** The orchestrator injected a temporary `throw` into `MarketsScreen.build` (non-dashboard so Go-to-Dashboard escapes), rebuilt, the user visited Markets, and confirmed: the BRANDED recovery screen rendered (surfaceBase background, error icon, "Something went wrong", "Go to Dashboard" GWButton) — NOT the red Flutter box; legible in BOTH appearance modes (set via Gallery + revisit); "Go to Dashboard" routed to a working `/dashboard`. Finding 12 (SDK shutdown on close) verified from the debug log: `Window closed. GeniusApi shutdown: GeniusNodeReturnValue.GENIUS_NODE_RET_OK`. The temporary throw was reverted (`git checkout`), tree clean. BEH-02 / criterion 6 confirmed. The "Outstanding" recipe below is retained for the record (it is how the walk was performed).

**Plan metadata:** not committed by this executor -- STATE.md/ROADMAP.md/REQUIREMENTS.md ownership belongs to the orchestrator per this execution's explicit scope restriction; this SUMMARY.md is left uncommitted on disk for the orchestrator to fold into its own commit once it decides how to sequence the outstanding walk.

## Files Modified

- `lib/main.dart` -- re-skinned `ErrorWidget.builder`'s recovery `Material` (background/icon/heading/action), added 4 imports (`components/buttons/gw_button.dart`, `components/gw_icon.dart`, `theme/genius_wallet_consts.dart`, `theme/genius_wallet_typography.dart`); `FlutterError.onError` and `MyWindowListener.onWindowClose` untouched

## Decisions Made

See `key-decisions` in frontmatter for the full rationale. The load-bearing ones:

1. **Hand-rolled the layout rather than building on `GWErrorState`** -- keeps the background/icon/heading fully on `GeniusWalletColors` static getters with zero incidental `Theme.of(context)` dependency for those three elements (the plan's key_link explicitly says the recovery screen "needs no BuildContext dependency"). `GWErrorState` itself performs a fail-soft Theme-extension-or-dark-fallback read for its optional `message` sub-text color -- unused here since this screen has no message body, but avoiding the wrapper sidesteps that read entirely rather than relying on its fail-soft path.
2. **`GWButton` (mandatory per the plan regardless of hand-roll choice) keeps its own pre-existing internal fail-soft Theme read** -- unchanged by this plan, and for the `primary` variant used here the fallback has no visible effect (its background/foreground colors are mode-invariant consts, not `gw.*` fields).
3. **Comment reworded to avoid literally spelling `extension<GWColors>`** in a code comment, after that string tripped the automated verify gate on the comment itself rather than on actual code -- see Deviations.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Verify-gate false positive from the executor's own explanatory comment**
- **Found during:** Task 1, first `verify` pass after the initial edit
- **Issue:** The plan's automated verify gate is `! grep -nE 'extension<GWColors>' lib/main.dart`, a literal grep with no comment-vs-code distinction. My first draft added a code comment explaining why the screen avoids `Theme.of(context).extension<GWColors>()`, quoting that exact API name in prose -- which matched the gate's pattern and tripped it, even though zero actual code used that API.
- **Fix:** Reworded the comment to describe the same rationale without the literal substring (e.g., "a Theme-extension context read" instead of the exact generic-method spelling). No code behavior changed; `flutter analyze` re-run clean after the reword.
- **Files modified:** `lib/main.dart`
- **Verification:** `grep -nE 'extension<GWColors>' lib/main.dart` returns no match; `flutter analyze lib/main.dart` still 0 issues after the reword.
- **Committed in:** `c1bba00` (part of the single Task 1 commit -- caught and fixed before committing, not a follow-up)

---

**Total deviations:** 1 auto-fixed (Rule 1, self-caught during the task's own verify loop before commit).
**Impact on plan:** No scope creep -- purely a comment-wording fix to satisfy the plan's own literal verify gate; zero behavioral or visual change.

## Issues Encountered

None beyond the one deviation above.

## Stub Tracking

None. No new empty/placeholder data paths introduced -- this plan touches only the recovery screen's static visual re-skin.

## Threat Flags

None beyond what the plan's own `<threat_model>` already names (T-04-07-01/02/03, all addressed per their stated mitigation -- wiring unchanged, static-getter color access confirmed by the grep gate, `verify_additive_boundary.sh` passed).

## Outstanding: the Task 2 walk

**This is the load-bearing gap in this plan's execution, matching 04-01-SUMMARY.md's precedent exactly.** Every mechanical gate available to this execution environment has run and passed (`flutter analyze`, `tool/verify_additive_boundary.sh`, the `extension<GWColors>` grep gate, direct `git diff` review confirming the wiring/`onWindowClose` are untouched). None of them can observe a rendered pixel, an appearance-mode legibility check, or a debug-console log line. This execution environment has **no Windows GUI access** -- the human walk cannot be performed here. Recording it as PASS would be the exact unearned-PASS/BLD-02 failure mode this project's standing rule exists to prevent.

**This gate must close before BEH-02 can be marked closed for Phase 4.**

### Exact walk recipe

Before starting: close the reference Release exe if running (`GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe`) -- it and the debug build share a Hive data directory and deadlock on file locks if both run at once.

```
export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true
```

1. **Trigger a deliberate build-time exception.** There is no dedicated dev-tools fault-injection button in this codebase (checked `lib/dev/` -- none exists). Simplest repro: temporarily add a single line `throw Exception('04-07 deliberate fault injection');` as the first statement inside any reachable screen's `build(BuildContext context)` method (e.g. `lib/dashboard/home/view/dashboard_screen.dart`'s top-level `DashboardScreen.build` around line 47), then hot-restart (not hot-reload -- a build-time throw needs a fresh build pass) or navigate to that route. **Do not commit this temporary throw** -- revert it with `git checkout -- <file>` once the walk is done for that launch.
2. **Confirm the BRANDED recovery screen renders** -- `surfaceBase` background, `GWIcon.material(Icons.error_outline, statusError)` at 64px, "Something went wrong" heading, "Go to Dashboard" `GWButton` (primary/`brandPrimary` fill) -- **not** the red Flutter error box. Tap/click "Go to Dashboard" and confirm it routes to `/dashboard`.
3. **Repeat as a SEPARATE launch for the other appearance mode**, not a live in-place toggle: (a) launch with the OS/persisted appearance set to light, inject the fault (per step 1), confirm the screen is legible on the light `surfaceBase` (a light-mode failure blocks close per D-03); (b) fully stop and relaunch with the OS/persisted appearance set to dark, inject the fault again, confirm legibility on the dark `surfaceBase`. This screen intentionally does NOT live-flip while displayed (robustness non-goal, static getters resolve once at mount) -- do not fail it for not flipping in place if you happen to toggle appearance while the recovery screen is up.
4. **Finding 12: close the app window** (from either launch) and confirm the debug console logs `Window closed. GeniusApi shutdown: <result>` before the process exits.
5. **Revert any temporary fault-injection edit** (`git status` should show a clean `lib/` beyond this plan's committed `main.dart` change) before ending the session.

### Report format

Record in a follow-up to this SUMMARY (or the phase's `04-VERIFICATION.md` when it is created): pass/fail per appearance mode, confirmation of the "Go to Dashboard" route, and the literal SDK-shutdown log line text observed. Type "approved" (or describe issues per mode) to close this gate.

## Next Phase Readiness

- **The mechanical/code side of BEH-02's exception-recovery-screen re-skin is complete this plan.** `main.dart`'s recovery screen is fully re-skinned on static getters; no further code changes are needed before the walk.
- **What this plan does NOT establish, and no later plan should assume closed:** the Task 2 human walk's actual observed outcome (both-mode legibility, routing confirmation, SDK-shutdown log line). Per this plan's own `<human_gate>` instruction, this is a hard gate for BEH-02 closure, not a formality.
- **No code blockers for any later Phase 4 plan.** This plan's file scope (`lib/main.dart` only) does not overlap any other plan's `files_modified`.

---
*Phase: 04-navigation-shell-chrome*
*Completed: 2026-07-18*

## Self-Check: PASSED

File verified present on disk: `lib/main.dart` (modified, confirmed via `git diff`). Task-commit hash `c1bba00` verified present in `git log --oneline --all`.
