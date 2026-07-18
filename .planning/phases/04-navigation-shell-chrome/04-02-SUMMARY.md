---
phase: 04-navigation-shell-chrome
plan: 02
subsystem: ui
tags: [flutter, theme-extension, inter-font, google_fonts, appearance-toggle, design-system]

# Dependency graph
requires:
  - phase: 04-navigation-shell-chrome
    provides: "04-01's theme-only appearance wiring (getThemeData() re-runs per toggle, GWAppearance ValueListenableBuilder rebuild) -- this plan is the corrective follow-up to the const-rebuild and offline-font bugs 04-01's D-02 re-walk surfaced"
provides:
  - "GWColors ThemeExtension attached to ThemeData in both light and dark branches of getThemeData()"
  - "11 gallery-const-instanced components migrated to read appearance-aware colors from Theme.of(context).extension<GWColors>() (fail-soft) instead of the GeniusWalletColors static getters"
  - "Bundled Inter font (4 static weights) with the google_fonts network path removed"
affects: [04-03-navigation-shell-chrome, 04-04, 04-05, 04-06, 04-07]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "GWColors ThemeExtension mirrors GeniusWalletColors appearance-aware static getters; components read it fail-soft (`Theme.of(context).extension<GWColors>() ?? GWColors.dark()`, no bang) at the top of build() to register the InheritedWidget dependency that forces const subtrees to rebuild on a live appearance toggle"
    - "Value-preservation guarded by a mode-gated debug-only equality assert inside GWColors.light()/dark() factories (zero-cost in release)"
    - "Font bundling: TextStyle(fontFamily: '<Family>', ...) + pubspec flutter: fonts: entry + GoogleFonts.config.allowRuntimeFetching = false, mirroring the existing JetBrainsMono pattern"

key-files:
  created:
    - lib/theme/gw_colors.dart
    - assets/fonts/Inter-Regular.ttf
    - assets/fonts/Inter-Medium.ttf
    - assets/fonts/Inter-SemiBold.ttf
    - assets/fonts/Inter-Bold.ttf
  modified:
    - lib/theme/theme.dart
    - lib/theme/genius_wallet_typography.dart
    - lib/components/cards/gw_token_row.dart
    - lib/components/cards/gw_wallet_card.dart
    - lib/components/feedback/gw_empty_state.dart
    - lib/components/feedback/gw_error_state.dart
    - lib/components/inputs/gw_checkbox.dart
    - lib/components/inputs/gw_switch.dart
    - lib/components/buttons/gw_button.dart
    - lib/components/inputs/gw_text_field.dart
    - lib/components/feedback/gw_loading_state.dart
    - lib/dev/design_gallery_screen.dart
    - pubspec.yaml
    - lib/main.dart

key-decisions:
  - "Sourced Inter from the official rsms/inter v4.1 GitHub release (extras/ttf/ static TTFs, SIL Open Font License 1.1), not Google Fonts' google/fonts repo, because google/fonts now only ships Inter as a variable font (Inter[opsz,wght].ttf) with no static per-weight files matching the pubspec fonts: block pattern already used for JetBrainsMono."
  - "GWColors carries only the 18 appearance-aware fields already on GeniusWalletColors (surfaces, text-primary ladder, textSecondary, borderSubtle/borderStrong) -- mode-invariant tokens (brandPrimary, statusError, textTertiary, textOnBrand, brandGreen, gradientBlue) stay on the static getters everywhere, matching the plan's explicit scope boundary."
  - "GWButton threads the context-resolved GWColors into _palette(gw) rather than making _palette() itself read Theme.of(context), keeping it a plain (testable) method."
  - "design_gallery_screen.dart's single non-const GWIcon.material(color: ...) call site was migrated to the context-resolved gw.textPrimary too, even though it already re-skinned correctly pre-migration (it's not const) -- for consistency with the migrated set, not because it was broken."

requirements-completed: [NAV-01, NAV-02]

coverage:
  - id: D1
    description: "GWColors ThemeExtension defined and attached to ThemeData in both light/dark branches of getThemeData(), with copyWith/lerp and light()/dark() factories value-checked against GeniusWalletColors via a mode-gated debug assert"
    requirement: "NAV-01"
    verification:
      - kind: other
        ref: "flutter analyze lib/theme/gw_colors.dart lib/theme/theme.dart lib/theme/genius_wallet_typography.dart -- No issues found"
        status: pass
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED after Task 1 commit 9dc7639"
        status: pass
    human_judgment: false
  - id: D2
    description: "11 gallery-const-instanced components (gw_token_row, gw_wallet_card, gw_empty_state, gw_error_state, gw_checkbox, gw_switch, gw_button, gw_text_field, gw_loading_state, + design_gallery_screen.dart's GWIcon call site) read GWColors fail-soft from context so const demo instances re-skin on a live appearance toggle"
    requirement: "NAV-01"
    verification:
      - kind: other
        ref: "flutter analyze (all 10 files) -- 0 errors, only pre-existing info-level lints unrelated to this task"
        status: pass
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED after Task 2 commit 52f212f"
        status: pass
      - kind: manual_procedural
        ref: "Task 4 D-02 gallery re-walk (BOTH modes) -- confirms the const re-skin actually happens visually, not just that the read compiles"
        status: unknown
    human_judgment: true
    rationale: "Compile-time analyze proves the code reads the right token but cannot prove a widget visually re-skins live in the running app -- that requires the Task 4 human gallery walk (blocking-human checkpoint), which is outstanding."
  - id: D3
    description: "Inter font bundled as 4 static TTF weights (400/500/600/700) with google_fonts network fetch path removed (TextStyle(fontFamily:'Inter') + allowRuntimeFetching=false)"
    requirement: "NAV-02"
    verification:
      - kind: other
        ref: "ls assets/fonts/Inter-*.ttf && grep -c 'family: Inter' pubspec.yaml && grep -c 'allowRuntimeFetching = false' lib/main.dart -- all present"
        status: pass
      - kind: other
        ref: "flutter analyze lib/theme/genius_wallet_typography.dart lib/main.dart -- No issues found"
        status: pass
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED after Task 3 commit 59fec67"
        status: pass
      - kind: manual_procedural
        ref: "Task 4 D-02 gallery re-walk -- visual confirmation Inter renders (not platform fallback) and optionally an offline run showing no HandshakeException/ClientException"
        status: unknown
    human_judgment: true
    rationale: "Analyze/grep prove the wiring exists but cannot prove the bundled glyphs actually render as Inter in a running debug build -- that is the Task 4 human verification step, which is outstanding."

duration: ~15min (Tasks 1-3 only; Task 4 is a blocking-human checkpoint, not yet performed)
completed: 2026-07-18
status: blocked
---

# Phase 04 Plan 02: GWColors ThemeExtension + bundled Inter font Summary

**Const-rebuild and offline-font fixes for the appearance toggle: a `GWColors` `ThemeExtension` attached to `ThemeData` (both modes) that 11 gallery-const-instanced components now read fail-soft from context, plus 4 bundled Inter TTF weights (sourced from rsms/inter v4.1) replacing every `GoogleFonts.inter()` call.**

Tasks 1-3 (all `type="auto"`) are complete and committed. **Task 4 — the D-02 gallery re-walk — is a `checkpoint:human-verify` (`gate="blocking-human"`) and has NOT been performed.** This SUMMARY documents the auto-task work only; the re-walk that confirms it actually fixes the bug live in the app remains outstanding.

## Performance

- **Started:** ~2026-07-18T08:35 (local)
- **Completed (Tasks 1-3):** 2026-07-18T08:50:05-03:00 (Task 3 commit timestamp)
- **Duration:** ~15 min
- **Tasks:** 3 of 4 (Task 4 pending human verification)
- **Files modified:** 14 (1 new theme file, 10 migrated components, pubspec.yaml, main.dart, typography, + 4 new font assets)

## Accomplishments
- `GWColors extends ThemeExtension<GWColors>` created mirroring the 18 appearance-aware `GeniusWalletColors` fields, with `copyWith`/`lerp` and `light()`/`dark()` factories guarded by a mode-gated debug equality assert against the retained static getters (zero-cost in release).
- `theme.dart`'s `getThemeData()` attaches `GWColors.light()`/`GWColors.dark()` to `ThemeData.extensions` for both modes in the single `ThemeData(...)` return.
- 11 gallery-const-instanced components (`gw_token_row.dart` incl. `_FallbackDot`, `gw_wallet_card.dart`, `gw_empty_state.dart`, `gw_error_state.dart`, `gw_checkbox.dart`, `gw_switch.dart`, `gw_button.dart` incl. `_palette(gw)`, `gw_text_field.dart` incl. `GWPasswordField`/`GWSearchField`, `gw_loading_state.dart` incl. `GWSkeleton`/`GWShimmerWrap`, plus `design_gallery_screen.dart`'s `GWIcon.material` call site) now read `Theme.of(context).extension<GWColors>() ?? GWColors.dark()` fail-soft and resolve their appearance-aware colors from it.
- 4 Inter static TTF weights (Regular/400, Medium/500, SemiBold/600, Bold/700) sourced from the official rsms/inter v4.1 release, bundled under `assets/fonts/`, declared in `pubspec.yaml`'s `flutter: fonts:` block.
- `genius_wallet_typography.dart`'s `_inter()` now builds `TextStyle(fontFamily: 'Inter', ...)` directly instead of calling `GoogleFonts.inter(...)`; `google_fonts` import dropped from this file.
- `main.dart` sets `GoogleFonts.config.allowRuntimeFetching = false` once during init, next to `GWAppearance.instance.load()`.

## Task Commits

Each auto task was committed atomically:

1. **Task 1: Add the GWColors ThemeExtension, attach it in both theme branches, make typography color context-resolvable** - `9dc7639` (feat)
2. **Task 2: Migrate the 11 gallery-const-instanced stale components to read GWColors from context** - `52f212f` (feat)
3. **Task 3: Bundle the Inter font and remove the runtime network path** - `59fec67` (feat)

**Task 4: D-02 gallery RE-WALK gate — NOT YET PERFORMED** (`checkpoint:human-verify`, `gate="blocking-human"`). No plan-metadata commit has been made; STATE.md/ROADMAP.md are owned by the orchestrator and not updated by this run.

## Files Created/Modified

- `lib/theme/gw_colors.dart` (new) - `GWColors extends ThemeExtension<GWColors>`, 18 fields, `copyWith`/`lerp`, `light()`/`dark()` factories with mode-gated debug value-preservation asserts
- `lib/theme/theme.dart` - attaches `GWColors.light()`/`dark()` to `ThemeData.extensions` in both mode branches; every other `GeniusWalletColors.*` read left as-is
- `lib/theme/genius_wallet_typography.dart` - `_inter()` doc comment (fallback semantics) in Task 1; `_inter()` body swapped from `GoogleFonts.inter(...)` to `TextStyle(fontFamily: 'Inter', ...)` in Task 3; `google_fonts` import removed
- `lib/components/cards/gw_token_row.dart` - `build()` + `_FallbackDot.build()` each add a fail-soft `gw` read; titleMd/bodySm/numericBody text colors and `_FallbackDot`'s surfaceMenu/textSecondary migrated
- `lib/components/cards/gw_wallet_card.dart` - fail-soft `gw` read; `CircleAvatar` surfaceMenu/textPrimary and `AutoSizeText` bodyMd color migrated
- `lib/components/feedback/gw_empty_state.dart` - fail-soft `gw` read; `borderSubtle` (icon ring) and both `textSecondary` reads (icon, message) migrated; `statusError`/title's baked default left as-is
- `lib/components/feedback/gw_error_state.dart` - fail-soft `gw` read; message `textSecondary` migrated; `statusError` (icon/banner) and title's baked default left as-is (`GWErrorBanner` untouched — not const-instanced in the gallery)
- `lib/components/inputs/gw_checkbox.dart` - fail-soft `gw` read; `borderSubtle` (side + fillColor disabled), `checkColor` (`textPrimary`), label `textPrimary`, description `textSecondary` migrated; `brandPrimary`/`textTertiary` left static
- `lib/components/inputs/gw_switch.dart` - fail-soft `gw` read; `inactiveThumbColor`/`inactiveTrackColor`/`trackOutlineColor`, label `textPrimary`, description `textSecondary` migrated; `brandPrimary`/`textTertiary` left static
- `lib/components/buttons/gw_button.dart` - `_palette()` now `_palette(GWColors gw)`, called as `_palette(gw)` from `build()`; tertiary/ghost/destructive/icon variant `surfaceElevated`/`textPrimary`/`borderSubtle` reads migrated; primary/secondary/gradient (`brandPrimary`, `textOnBrand`, `gradientBlue`) and destructive's `statusError` background left static
- `lib/components/inputs/gw_text_field.dart` - `GWTextField.build()` fail-soft `gw` read: label/hint/helper `textSecondary`, `fillColor` `surfaceElevated`, border/enabledBorder/disabledBorder `borderSubtle` migrated (`brandPrimary`/`statusError` borders left static); `_GWPasswordFieldState.build()` and `GWSearchField.build()` each add their own fail-soft `gw` read for their icon `textSecondary` colors (icons changed from `const` to non-const to allow the context read)
- `lib/components/feedback/gw_loading_state.dart` - `GWLoadingState.build()` fail-soft `gw` read: message `textSecondary` migrated (`brandGreen` spinner left static); `GWSkeleton.build()` and `GWShimmerWrap.build()` each add their own fail-soft `gw` read: `surfaceMenu`/`surfaceElevated` shimmer colors migrated
- `lib/dev/design_gallery_screen.dart` - added one `gw` local in the `ValueListenableBuilder` builder callback; the single `GWIcon.material(color: ...)` call site (Icons section) now resolves `gw.textPrimary` instead of the static getter
- `pubspec.yaml` - added `Inter` family under `flutter: fonts:` (4 weight entries mirroring the JetBrainsMono block)
- `lib/main.dart` - added `google_fonts` import + `GoogleFonts.config.allowRuntimeFetching = false;` next to `GWAppearance.instance.load()`
- `assets/fonts/Inter-Regular.ttf`, `Inter-Medium.ttf`, `Inter-SemiBold.ttf`, `Inter-Bold.ttf` (new) - static TTFs extracted from `extras/ttf/` in the rsms/inter v4.1 release zip

## GWColors Field List (all values equal their GeniusWalletColors source)

`surfaceBase`, `surfaceElevated`, `surfaceMenu`, `surfaceSunken`, `surfaceOverlay`, `textPrimary`, `textPrimary80`, `textPrimary70`, `textPrimary60`, `textPrimary54`, `textPrimary38`, `textPrimary30`, `textPrimary24`, `textPrimary12`, `textPrimary10`, `textSecondary`, `borderSubtle`, `borderStrong` (18 fields).

Every field is read directly from the matching `GeniusWalletColors` getter inside `GWColors.light()`/`GWColors.dark()` (not re-literaled), so there is no transcription surface for a value mismatch to hide in — both factories construct `GWColors(...)` by calling the static getters, then the mode-gated debug `assert` re-checks the same equality (defense-in-depth against a future refactor that inlines literals instead of calling the getters).

## Migrated vs. Left-on-Static-Getter (per file)

| File | Migrated to `gw.*` | Left on `GeniusWalletColors.*` (mode-invariant or deferred) |
|---|---|---|
| `gw_token_row.dart` | titleMd/bodySm/numericBody text colors, `_FallbackDot` surfaceMenu + icon textSecondary | — |
| `gw_wallet_card.dart` | CircleAvatar surfaceMenu + icon textPrimary, AutoSizeText bodyMd color | — |
| `gw_empty_state.dart` | borderSubtle (icon ring), icon textSecondary, message textSecondary | statusError (n/a here), title's baked-default color |
| `gw_error_state.dart` | message textSecondary | statusError (icon/circle/banner), title's baked-default color, `GWErrorBanner` (not gallery-const) |
| `gw_checkbox.dart` | borderSubtle (side + disabled fillColor), checkColor, label textPrimary, description textSecondary | brandPrimary, textTertiary |
| `gw_switch.dart` | inactiveThumbColor, inactiveTrackColor, trackOutlineColor, label textPrimary, description textSecondary | brandPrimary, textTertiary |
| `gw_button.dart` | tertiary/ghost/destructive/icon variant surfaceElevated/textPrimary/borderSubtle (via `_palette(gw)`) | primary/secondary/gradient brandPrimary/textOnBrand/gradientBlue, destructive statusError background |
| `gw_text_field.dart` | label/hint/helper textSecondary, fillColor surfaceElevated, border/enabledBorder/disabledBorder borderSubtle; `GWPasswordField`/`GWSearchField` icon textSecondary | focusedBorder brandPrimary, errorBorder/focusedErrorBorder/errorStyle statusError, cursorColor brandPrimary |
| `gw_loading_state.dart` | `GWLoadingState` message textSecondary; `GWSkeleton`/`GWShimmerWrap` surfaceMenu/surfaceElevated | brandGreen spinner color |
| `design_gallery_screen.dart` | the one `GWIcon.material(color: ...)` call site → gw.textPrimary | all other `GeniusWalletColors.*` reads in the file (canvas-grain caption, etc.) — out of this plan's 11-component scope |

## Deferred Long-Tail Boundary (unchanged, confirmed)

Per the plan's `<migration_surface>` DEFERRAL RULE, these files are NOT const-instanced inside the D-02 re-walk gallery and are left untouched for `04-03..07` to migrate in-place when those plans rebuild the surfaces: `gw_select.dart`, `gw_dialog.dart`, `gw_bottom_sheet.dart`, `bottom_drawer.dart`, `gw_screen.dart`, `gw_spinner.dart`, `gw_mesh_background.dart`, `coin_card_container.dart`, `gw_card.dart`, `gw_gradient_border_card.dart`, `genius_wallet_decorations.dart`, `genius_wallet_gradient.dart`, `token_probe_screen.dart`. Verified: none of these files were touched by this plan's commits.

## Inter Font Provenance

- **Source:** official rsms/inter GitHub release, tag `v4.1` (https://github.com/rsms/inter/releases/tag/v4.1), asset `Inter-4.1.zip`.
- **License:** SIL Open Font License 1.1 (`LICENSE.txt` present in the release zip).
- **Files extracted:** the 4 static (non-variable) TTFs from the zip's `extras/ttf/` directory — `Inter-Regular.ttf` (400), `Inter-Medium.ttf` (500), `Inter-SemiBold.ttf` (600), `Inter-Bold.ttf` (700) — matching the exact weights `GeniusWalletTypography`'s scale uses.
- **Why not google/fonts (Google Fonts' canonical repo):** as of this session, `google/fonts`'s `ofl/inter/` directory only contains the variable font (`Inter[opsz,wght].ttf` + italic), no static per-weight TTFs, so it doesn't fit the existing `pubspec.yaml` fonts: pattern (one file per weight, matching the `JetBrainsMono` block). rsms/inter is Inter's own upstream repository and ships the same static files Google Fonts used to vendor.
- **Download succeeded on the first attempt** — no network failure encountered this session (the machine's previously-observed `HandshakeException`/`ClientException` did not reproduce for this GitHub download).

## Decisions Made

- Sourced Inter from rsms/inter v4.1 rather than Google's `google/fonts` repo (see provenance above — google/fonts no longer ships static per-weight Inter TTFs).
- `_palette()` in `gw_button.dart` takes `GWColors gw` as a parameter rather than reading `Theme.of(context)` itself, keeping it side-effect-free and easy to reason about; `build()` does the one context read and threads it through.
- Migrated the single non-const `GWIcon.material` call site in `design_gallery_screen.dart` for consistency with the 11 migrated components, even though (per the 04-01 todo) it already re-skinned correctly pre-migration since it isn't `const`.
- `GWSearchField`'s `prefix`/`suffix` `Icon` widgets and `GWPasswordField`'s suffix `Icon` were changed from `const` to non-const to allow the context-resolved color read — this is required for those specific icons (they read `textSecondary`, which is appearance-aware) and does not affect layout/behavior.

## Deviations from Plan

None - plan executed exactly as written for Tasks 1-3. All migrated colors were sourced directly by calling the retained `GeniusWalletColors` getters (never re-literaled), preserving the "pure access-path change" scope boundary. Widget structure, order, padding, and behavior are unchanged throughout.

## Issues Encountered

None. `flutter analyze` and `bash tool/verify_additive_boundary.sh` passed cleanly after every auto task with no fix-attempt iterations needed.

## Verification Results

- **`flutter analyze` (per-task scoped, as specified in each task's `<verify>`):** 0 errors after every task. Task 1: "No issues found!" (3 files). Task 2: 5 pre-existing info-level lints (unnecessary underscores in an unrelated `gw_token_row.dart` errorBuilder param, a deprecated `activeColor` Switch API call, two unnecessary-const gallery lines) across all 10 files, 0 errors. Task 3: "No issues found!" (2 files).
- **`flutter analyze` (full repo, extra sanity check beyond the plan's per-task scope):** 0 errors, 410 total info/warning issues — all pre-existing noise from the vendored `packages/genius_api/lib/ffi/trust_wallet_api_ffi.dart` FFI bindings and one unrelated test file (`test/token_info_loader_test.dart`); none touch any file this plan modified. This is unrelated to the plan's ~62-issue scoped baseline (which covers `lib/theme` + `lib/components` + `lib/dev` + `lib/main.dart`, not the vendored `packages/genius_api` FFI bindings) — out of scope per the deviation-rules scope boundary (only auto-fix issues directly caused by this task's changes).
- **`bash tool/verify_additive_boundary.sh`:** PASSED after every auto task (Task 1, Task 2, Task 3) — no shadow-import drift, duplicate-class census unchanged, no `WIRE-` markers.

## Known Stubs

None — no hardcoded empty values, placeholder text, or unwired data sources were introduced.

## Threat Flags

None — all changes fall within the plan's declared `<threat_model>` (T-04-02-01 through T-04-02-05), all mitigated as specified: extension attached in both modes (T-04-02-01), fail-soft reads with no bang anywhere (T-04-02-01), values sourced by calling the static getters directly rather than re-literaling (T-04-02-02), Inter sourced from an official OFL release (T-04-02-03), network path removed via `allowRuntimeFetching = false` (T-04-02-04), additive-boundary guard green after every task (T-04-02-05).

## User Setup Required

None - no external service configuration required. The Inter TTFs are committed directly to the repo as OFL-licensed assets (no npm/package-manager dependency).

## Outstanding: Task 4 (D-02 Gallery Re-Walk — BLOCKING HUMAN GATE)

**Not performed.** Per the executor's explicit instructions, Task 4 (`type="checkpoint:human-verify"`, `gate="blocking-human"`) was not attempted or fabricated. It requires:

1. A debug build launch with `--dart-define=GW_DEV_TOOLS=true` (Dev row > Gallery).
2. **Const re-skin check:** toggle appearance and confirm the const `GWTokenRow`/`GWWalletCard` demo instances plus all 9 other migrated const demos (empty/error state, checkbox, switch, button, text field, loading state) flip live with no re-enter-gallery workaround, and the `GWIcon` call site flips.
3. **Inter offline check:** confirm button/body/heading text now renders in Inter (not the platform fallback), optionally with network blocked to prove no fetch path remains.
4. **Two still-unexplained Phase-3 findings:** get a real repro for the `Screen wrappers` (AppScreenView) blank-in-dark finding and the disabled `GWCheckbox` invisible-in-dark finding.
5. **Dark-only count:** walk all 30 gallery sections in both modes and record the dark-only component count, splitting BUGS vs. DESIGN CHOICES.
6. **OS-follow default (D-03):** confirm a fresh launch with no persisted preference follows the OS brightness setting.

This re-walk supersedes/closes the 04-01 D-02 gate and MUST close before `04-03..07` begin. **The next session must resume at Task 4, not re-execute Tasks 1-3.**

## Next Phase Readiness

Tasks 1-3 land the corrective ThemeExtension migration and the bundled Inter font — the mechanical fixes are in place and pass every automated gate (`flutter analyze`, the additive-boundary guard). What remains before `04-03..07` can safely build on this foundation is exclusively the Task 4 human re-walk: automated checks cannot prove a widget visually re-skins live or that Inter glyphs actually render, only that the code reads the right token / declares the right family. Phase 4's next plans (04-03 onward) should NOT start until Task 4 closes.

---
*Phase: 04-navigation-shell-chrome*
*Completed: 2026-07-18 (Tasks 1-3 only; Task 4 outstanding)*

## Self-Check: PASSED

All created files verified present on disk (`lib/theme/gw_colors.dart`, the 4 `assets/fonts/Inter-*.ttf` files, this SUMMARY.md). All 3 task commit hashes (`9dc7639`, `52f212f`, `59fec67`) verified present in `git log --oneline --all`.
