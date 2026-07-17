---
phase: 04-navigation-shell-chrome
plan: 01
subsystem: ui
tags: [flutter, theme, appearance, dark-mode, light-mode, material3, gw-appearance]

# Dependency graph
requires:
  - phase: 03-gw-component-library
    provides: "The full gw_* component library (inert, tokens-only) plus GeniusWalletTypography.toMaterialTextTheme() and the GWAppearance + ValueListenableBuilder mechanism already proven at the screen level (token_probe_screen.dart, design_gallery_screen.dart)"
provides:
  - "lib/theme/theme.dart -- appearance-aware getThemeData(): light AND dark ColorScheme keyed on GWAppearance.isLight, textTheme wired to GeniusWalletTypography.toMaterialTextTheme(), scaffoldBackgroundColor: GeniusWalletColors.surfaceBase (appearance-aware, was hardcoded colorScheme.surfaceDim)"
  - "lib/theme/gw_appearance.dart -- load() follows the OS light/dark setting on a genuine first launch (D-03), not an unconditional dark default"
  - "lib/main.dart -- MaterialApp.router wrapped in ValueListenableBuilder<GWAppearanceMode> so the WHOLE app (not just one screen) repaints on an appearance toggle; GWAppearance.instance.load() called once at startup"
  - "lib/dev/design_gallery_screen.dart -- the 03-09/244b71e Scaffold(backgroundColor: surfaceBase) workaround reverted to Colors.transparent now that the ambient theme supplies a correct canvas"
affects: [04-02, 04-03, 04-04, 04-05, 04-06]

tech-stack:
  added: []
  patterns:
    - "Appearance-reactive MaterialApp: ValueListenableBuilder<GWAppearanceMode> on GWAppearance.instance wraps MaterialApp.router only, inside the existing MultiBlocProvider/RepositoryProvider tree -- the same mechanism token_probe_screen.dart and design_gallery_screen.dart already use, now at the app root for the first time."
    - "First-launch OS-brightness fallback: gw_appearance.dart's load() reads PlatformDispatcher.instance.platformBrightness only when no 'light'/'dark' string is persisted in Hive -- an explicit third branch, not inferred from an unset/null check alone."

key-files:
  created: []
  modified:
    - lib/theme/theme.dart
    - lib/theme/gw_appearance.dart
    - lib/main.dart
    - lib/dev/design_gallery_screen.dart

key-decisions:
  - "theme.dart reconciled key-by-key (not a wholesale adopt of Alex's 309-line file) -- every ThemeData key present in develop's original 276 lines was given an explicit carry-forward-or-drop decision; see the full table below."
  - "onError kept as develop's original literal Colors.white in both light and dark ColorScheme, rather than Alex's GeniusWalletColors.foundationWhite (a token that does not exist anywhere in this codebase and would require editing genius_wallet_colors.dart, a file outside this theme-only plan's declared scope). Functionally equivalent: Alex's own dark-mode onError resolves to textPrimary, which equals Colors.white in dark mode anyway."
  - "outlinedButtonTheme's foregroundColor changed from develop's hardcoded Colors.white to the appearance-aware GeniusWalletColors.textPrimary -- required so sdk_account_manager.dart's two footer OutlinedButton.icon widgets (which set no inline style override, per 04-RESEARCH.md §4.2) stay legible in light mode, per D-03's 'light mode is a shipping surface, no deferred bugs' rule."
  - "colorScheme.errorContainer/onErrorContainer/scrim/surfaceDim/surfaceContainerHigh/onSurfaceVariant dropped (not carried) -- matches Alex's reference exactly, relying on Material 3's own computed defaults. The only external consumer found by grep, lib/screens/pin_screen.dart's Theme.of(context).colorScheme.errorContainer read (Incorrect PIN text color), still resolves to a non-null, reasonable tonal-red value; pin_screen.dart itself is untouched (out of this plan's file scope)."
  - "dividerTheme, menuTheme, toggleButtonsTheme, dialogTheme kept structurally identical to develop's original values (only color/typography references updated to the new appearance-aware tokens) -- these are the four of the six preserved sections that had zero live-consumer-visible behavior change beyond becoming appearance-aware."
  - "InputDecorationTheme's enabledBorder and hintStyle (both present in develop, both absent from Alex's reference) were DROPPED, matching Alex's deliberate simplification -- floatingLabelBehavior.always is the one explicitly protected key (finding 36) and was added back verbatim; enabledBorder/hintStyle are not on the six-section protected list and Alex's own redesign target omits them, so this reconciliation follows Alex's visual for those two rather than inventing a restoration research didn't ask for."
  - "outlinedButtonTheme/filledButtonTheme padding: the vertical value (16.0) exactly matches GeniusWalletConsts.space8 and was expressed via that token (see the Rule 1 self-check fix below -- the first pass used space4 by mistake); horizontal (14.0) has no exact token match in the 4pt scale and was left as develop's original literal double rather than nudging the pixel value to the nearest token, avoiding an invented visual delta beyond this reconcile's scope. dialogTheme's actionsPadding (12.0, an exact match for GeniusWalletConsts.space6) was expressed via the token."

requirements-completed: [NAV-01, NAV-02]

coverage:
  - id: D1
    description: "theme.dart's getThemeData() returns a light ThemeData when GWAppearance.isLight is true and a dark one otherwise; all six preserved sections (floatingLabelBehavior.always, toggleButtonsTheme, filledButtonTheme, outlinedButtonTheme, dialogTheme, menuTheme, dividerTheme) are present in the reconciled file; onPrimary is textOnBrand in both ColorSchemes."
    requirement: "NAV-01"
    verification:
      - kind: other
        ref: "flutter analyze lib/theme/theme.dart -- 0 errors, 0 issues. grep -c for each of the six preserved section keys plus floatingLabelBehavior and onPrimary: textOnBrand in the committed file -- all present."
        status: pass
    human_judgment: false
  - id: D2
    description: "MaterialApp.router is wrapped in ValueListenableBuilder<GWAppearanceMode> on GWAppearance.instance; GWAppearance.instance.load() is invoked exactly once at startup; ErrorWidget.builder/onWindowClose/loadStoredWallets sequencing is byte-unchanged except for the wrap itself."
    requirement: "NAV-02"
    verification:
      - kind: other
        ref: "flutter analyze lib/main.dart -- 0 errors. git diff lib/main.dart reviewed directly: only two hunks (one import + GWAppearance.instance.load() call; the MaterialApp.router wrap) -- ErrorWidget.builder (lines ~223-258) and MyWindowListener.onWindowClose (lines ~150-171) show zero diff."
        status: pass
    human_judgment: false
  - id: D3
    description: "gw_appearance.dart's load() has an explicit OS-brightness else-branch for the no-persisted-value case (D-03); the gallery Scaffold background is reverted to Colors.transparent."
    requirement: "NAV-02"
    verification:
      - kind: other
        ref: "flutter analyze lib/theme/gw_appearance.dart lib/dev/design_gallery_screen.dart -- 0 errors. grep for 'PlatformDispatcher.instance.platformBrightness' in gw_appearance.dart and 'backgroundColor: Colors.transparent' in design_gallery_screen.dart -- both present."
        status: pass
    human_judgment: false
  - id: D4
    description: "The D-02 gallery re-walk: toggle the appearance icon in the running app, confirm the WHOLE gallery repaints (not just one section), walk all 30 sections in both light and dark, confirm the 5 theme-confound findings from 03-09 have evaporated, derive the dark-only component COUNT, split remaining findings into bugs vs design choices per D-04, get a real repro for the two unexplained 03-09 findings (Screen wrappers blank in dark; disabled GWCheckbox invisible in dark), and confirm the first-launch OS default."
    requirement: "NAV-01"
    verification: []
    human_judgment: true
    rationale: "No Windows GUI access from this execution environment -- this project has no working flutter test harness (APP-02) and every prior phase's own precedent (02-VERIFICATION.md, 03-VERIFICATION.md, 03-09-SUMMARY.md) treats a rendered-pixel/appearance-toggle observation as human-only. Recording this as PASS without a human having actually run the app and toggled the appearance icon would be the exact unearned-PASS/BLD-02 failure mode this project's standing rule exists to prevent. See 'Outstanding: the D-02 re-walk' below for the full recipe."

# Metrics
duration: ~35min
completed: 2026-07-17
status: complete
---

# Phase 4 Plan 01: Theme-Only Appearance Wiring Summary

**Reconciled `theme.dart` into a live light/dark `ThemeData` (key-by-key against Alex's reference, preserving six develop-only sections research found it drops), wrapped `MaterialApp.router` in a `ValueListenableBuilder` so an appearance toggle repaints the whole app, and made a genuine first launch follow the OS light/dark setting.**

## Performance

- **Duration:** ~35 min
- **Tasks:** 2/2 code tasks complete; Task 3 (the D-02 human re-walk gate) is OUTSTANDING, not passed
- **Files modified:** 4

## Accomplishments

- **Task 1 — theme.dart reconciled key-by-key** (`953f1c7`): `getThemeData()` now builds a light and a dark `ColorScheme` from `GWAppearance.isLight`, wires `textTheme: GeniusWalletTypography.toMaterialTextTheme()` (previously referenced nowhere in `lib/`), and sets `scaffoldBackgroundColor: GeniusWalletColors.surfaceBase` (appearance-aware, replacing the permanently-dark `colorScheme.surfaceDim`). All six `ThemeData` sections Alex's reference silently drops but this repo's other files still consume — `inputDecorationTheme.floatingLabelBehavior: FloatingLabelBehavior.always` (finding 36), `toggleButtonsTheme`, `filledButtonTheme`, `outlinedButtonTheme`, `dialogTheme`, `menuTheme`, `dividerTheme` — survive the reconcile, updated only to reference the new appearance-aware color/typography tokens instead of the old hardcoded-dark scheme. The WCAG `onPrimary: GeniusWalletColors.textOnBrand` choice is preserved exactly in both `ColorScheme`s, never substituted with white/black.
- **Task 2 — OS-first-launch default + MaterialApp-level rebuild + gallery revert** (`2f3aa8a`): `gw_appearance.dart`'s `load()` gained an explicit `else` branch reading `PlatformDispatcher.instance.platformBrightness` for the no-persisted-value case (D-03) — previously it defaulted to `dark` unconditionally regardless of the OS setting. `main.dart`'s `MaterialApp.router` is now wrapped in `ValueListenableBuilder<GWAppearanceMode>` on `GWAppearance.instance`, so `getThemeData()` re-evaluates on every toggle — the first time this wrap happens at the whole-app level rather than a single screen's `Scaffold`. `GWAppearance.instance.load()` is called once at startup, next to the other one-time init calls (after `loadStoredWallets()`). `design_gallery_screen.dart`'s 03-09/`244b71e` workaround (`backgroundColor: surfaceBase`) is reverted to `Colors.transparent`, now that the ambient theme supplies a correct canvas.
- **`flutter analyze lib` on all four touched files: 0 errors.** Two pre-existing, out-of-scope `unnecessary_const` info lints remain in `design_gallery_screen.dart` (lines this plan's single-line revert did not touch) — logged to `deferred-items.md`, not fixed, per the scope-boundary rule.
- **`bash tool/verify_additive_boundary.sh`: PASSED** after both task commits — shadow-import boundary, duplicate-class census, and the `WIRE-` tripwire are all unaffected by this theme-only reconcile.
- **`ErrorWidget.builder`, `MyWindowListener.onWindowClose`, and the `loadStoredWallets()` boot sequencing are byte-unchanged** — confirmed directly by reading `git diff lib/main.dart`, not by assumption: the diff shows exactly two hunks (the `GWAppearance` import + `load()` call; the `MaterialApp.router` wrap), nothing else moved.

## Task Commits

Each task was committed atomically:

1. **Task 1: Reconcile theme.dart key-by-key into an appearance-aware ThemeData** — `953f1c7` (feat)
2. **Task 2: OS-first-launch default, MaterialApp-level appearance rebuild, gallery revert** — `2f3aa8a` (feat)
3. **Self-check fix: correct a Task-1 padding-token typo** — `029c089` (fix)

**Task 3 (the D-02 gallery re-walk checkpoint) is a human-verification gate — no code change, OUTSTANDING. See below.**

**Plan metadata:** committed separately after this summary via the standard final-commit step.

## Files Modified

- `lib/theme/theme.dart` — reconciled `getThemeData()`, appearance-aware light+dark `ColorScheme`, `textTheme`, `scaffoldBackgroundColor`, six preserved sections
- `lib/theme/gw_appearance.dart` — `load()`'s OS-brightness `else` branch
- `lib/main.dart` — `ValueListenableBuilder<GWAppearanceMode>` wrap around `MaterialApp.router`; `GWAppearance.instance.load()` call
- `lib/dev/design_gallery_screen.dart` — `backgroundColor` reverted to `Colors.transparent`

## Decisions Made

See `key-decisions` in frontmatter for the full carry/drop rationale. The load-bearing ones:

1. **Key-by-key reconcile, not a wholesale file swap** — every `ThemeData` parameter present in develop's original 276-line file was given an explicit decision (carry forward with updated tokens, or deliberately drop matching Alex's own simplification). No key was silently lost to a 3-way-merge-style omission.
2. **`onError` kept as `Colors.white`** (develop's original literal value) in both appearance modes, rather than introducing Alex's `GeniusWalletColors.foundationWhite` — that token does not exist anywhere in this codebase, and adding it would mean editing `genius_wallet_colors.dart`, a file explicitly outside this theme-only plan's declared `files_modified`. Functionally equivalent to Alex's own resolved dark-mode value.
3. **`outlinedButtonTheme.foregroundColor` made appearance-aware** (`GeniusWalletColors.textPrimary`, was hardcoded `Colors.white`) — a Rule 2 addition: without this, `sdk_account_manager.dart`'s two un-styled footer `OutlinedButton.icon` widgets would render white text on a white light-mode background, a genuine light-mode bug D-03 says cannot ship.
4. **`errorContainer`/`onErrorContainer`/`scrim`/`surfaceDim`/`surfaceContainerHigh`/`onSurfaceVariant` dropped** from the `ColorScheme`, matching Alex's reference exactly and relying on Material 3's own computed defaults. The one external consumer found by grep (`pin_screen.dart`'s `colorScheme.errorContainer` read) still resolves to a reasonable value; that file is untouched.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed a redundant `dart:ui` import in `gw_appearance.dart`**
- **Found during:** Task 2, first `flutter analyze` pass after adding the OS-brightness branch
- **Issue:** `info - unnecessary_import` — `dart:ui`'s `PlatformDispatcher`/`Brightness` are already re-exported by the already-imported `package:flutter/foundation.dart`.
- **Fix:** Removed the explicit `import 'dart:ui' show PlatformDispatcher, Brightness;` line; both symbols still resolve via `flutter/foundation.dart`.
- **Files modified:** `lib/theme/gw_appearance.dart`
- **Verification:** `flutter analyze lib/theme/gw_appearance.dart` — issue gone, 0 errors/warnings remaining.
- **Committed in:** `2f3aa8a` (Task 2 commit) — fixed before commit, not a follow-up.

**2. [Rule 2 - Missing Critical] `outlinedButtonTheme.foregroundColor` made appearance-aware**
- **Found during:** Task 1, while reconciling `outlinedButtonTheme` (one of the six preserved sections)
- **Issue:** develop's original value hardcoded `foregroundColor: Colors.white`, correct only against the old permanently-dark theme. Per 04-RESEARCH.md §1/§4.2, `sdk_account_manager.dart`'s two footer `OutlinedButton.icon` widgets set no inline style override and are fully theme-dependent — white text would be unreadable against a white light-mode surface, a light-mode bug D-03 says must not ship.
- **Fix:** Changed to `GeniusWalletColors.textPrimary` (appearance-aware: near-black ink in light, white in dark).
- **Files modified:** `lib/theme/theme.dart`
- **Verification:** `flutter analyze lib/theme/theme.dart` — 0 errors. Full visual confirmation is part of the outstanding D-02 re-walk (this specific button pair is not itself in the gallery, so it will be confirmed when `sdk_account_manager.dart` is re-skinned/walked in a later Phase 4 plan, not this one).
- **Committed in:** `953f1c7` (Task 1 commit)

**3. [Rule 1 - Bug] `outlinedButtonTheme`/`filledButtonTheme` vertical padding token typo'd**
- **Found during:** Self-check pass before finalizing this SUMMARY (re-reading the committed `theme.dart` to verify the token-mapping decisions recorded above)
- **Issue:** Both preserved button themes' vertical padding was written as `GeniusWalletConsts.space4` (8.0) instead of `GeniusWalletConsts.space8` (16.0) — silently halving develop's original 16.0px value.
- **Fix:** Corrected both occurrences to `GeniusWalletConsts.space8`, restoring the exact original pixel value.
- **Files modified:** `lib/theme/theme.dart`
- **Verification:** `flutter analyze lib/theme/theme.dart` — 0 issues, both after the original commit and after the fix.
- **Committed in:** `029c089` (follow-up fix commit, since `953f1c7` had already landed)

---

**Total deviations:** 3 auto-fixed (1 Rule 1 lint cleanup, 1 Rule 2 light-mode-legibility fix, 1 Rule 1 self-check bug fix).
**Impact on plan:** All three are narrow, necessary corrections directly inside this plan's own file scope. No scope creep, no shell/screen files touched.

## Issues Encountered

None beyond the two deviations above.

## Stub Tracking

None. No new empty/placeholder data paths introduced — this plan touches only theme wiring and one reverted background-color literal.

## Threat Flags

None beyond what the plan's own `<threat_model>` already names (T-04-01-01/02/03, all addressed per their stated mitigation — the `ValueListenableBuilder` wrap sits only around `MaterialApp.router` inside the existing provider tree; `gw_appearance.dart`'s `load()` only accepts the exact strings `'light'`/`'dark'` for the persisted branch, any other/absent value falls through to the OS-brightness branch with no unchecked cast).

## Outstanding: the D-02 gallery re-walk (Task 3)

**This is the load-bearing gap in this plan's execution, matching 03-09-SUMMARY.md's precedent exactly.** Every mechanical gate available to this execution environment has run and passed (`flutter analyze`, `tool/verify_additive_boundary.sh`, direct `git diff` review of `main.dart`'s untouched sections). None of them can observe a rendered pixel or an appearance toggle actually repainting the screen. This execution environment has **no Windows GUI access** — the human walk cannot be performed here. Recording it as PASS would be the exact unearned-PASS/BLD-02 failure mode this project's standing rule exists to prevent (per `02-VERIFICATION.md`'s precedent, reaffirmed by `03-07-SUMMARY.md` and `03-09-SUMMARY.md`).

**This gate must close (per D-01/D-02) before any 04-02+ shell/screen re-skin plan begins.**

### Exact walk recipe

Before starting: close the reference Release exe if running (`GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe`) — it and the debug build share a Hive data directory and deadlock on file locks if both run at once.

```
export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true
```

Open `Dev` → `Gallery`.

1. **Toggle the appearance icon and confirm the WHOLE gallery repaints** — surfaces, text, icons, not just one section. Walk all 30 sections in BOTH light and dark.
2. **Confirm the 5 theme-confound findings from the 03-09 walk have evaporated**: token row / wallet card / empty-error text now flip color; button font styled; icons flip. Record which, if any, remain.
3. **Record the dark-only component COUNT** (the number 03-09 marked NOT DERIVABLE). Split what remains into:
   - **BUGS** (fix in Phase 4, per D-04/D-03 — light mode is a shipping surface, no deferral)
   - **DESIGN CHOICES** (user decides): `GWCanvasBackground` grain gated `if (!isLight)`, `GWMeshBackground` blobs invariant over a flipping backdrop, `GWSwitch` disabled==off, `GWSwitch` off-thumb near-black in light.
4. **Get a real repro (not a guess)** for the two unexplained 03-09 findings: `Screen wrappers` (`AppScreenView`) blank in DARK mode, and the disabled `GWCheckbox` invisible in dark. If either is a genuine bug, it cannot be deferred past Phase 4 close (D-03).
5. **First-launch OS default (D-03):** clear the persisted appearance key (or reinstall/delete the Hive `preferences` box entry) and confirm the app boots to the OS's current light/dark setting.

### Report format

Record in a follow-up to this SUMMARY (or the phase's `04-VERIFICATION.md` when it is created): the dark-only count, the bugs-vs-design-choices split, the two repros, and the first-launch OS-follow confirmation. Type "approved" with the recorded count and split to close this gate, or describe issues found.

## Next Phase Readiness

- **The mechanical/code side of D-01 is complete this plan.** `theme.dart` is appearance-aware, the `MaterialApp` rebuild wrap is in place, and the OS-first-launch default is wired. Nothing in 04-02+ needs further theme.dart code changes to proceed on the mechanical side.
- **What this plan does NOT establish, and 04-02+ MUST NOT start before it exists:** the D-02 human re-walk's actual observed outcomes (dark-only count, findings split, the two repros, OS-default confirmation). Per this plan's own `<the_human_gate>` instruction and D-01/D-02, this is a hard gate, not a formality — no shell/screen re-skin work should begin until a human performs the walk above and the gate closes.
- **No code blockers for 04-02+ beyond the walk itself.** `theme.dart`'s reconciled structure, the `ValueListenableBuilder` wrap, and `gw_appearance.dart`'s `load()` are stable and require no further changes to be walked.

---
*Phase: 04-navigation-shell-chrome*
*Completed: 2026-07-17*

## Self-Check: PASSED

All 6 claimed files verified present on disk; all 3 task-commit hashes (`953f1c7`, `2f3aa8a`, `029c089`) verified present in `git log --oneline --all`.
